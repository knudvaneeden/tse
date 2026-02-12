/*
  Macro           CaseFilename
  Author          Carlo.Hogeveen@xs4all.nl
  Version         v1.0 - 8 Sep 2019
  Compatibility   Windows TSE Pro v4.0 upwards,
                  Linux TSE Pro Beta v4.41.12 upwards

  SHORT DESCRIPTION

  For Windows it changes an opened file's path to its actual case on disk.

  For Linux it implements two features:
  - Trying to open a folder or file with an incorrectly cased name now might
    open the intended one.
  - Renaming only the case of a file in the editor and saving it, will now
    rename the disk file too (just like Windows).


  INSTALLATION

  - Compile this macro, for instance by opening this file in TSE and then using
    the Macro Compile menu.
  - Add its name "CaseFilename" to the BOTTOM (!) of the Macro AutoLoad List
    menu.
  - Restart TSE.
  - Done.

  (!) The lower a macro's position is in the Macro AutoLoad List, the earlier
      its hooks get executed.
      The desired result is that this macro can change the case of a folder and
      file's name before any other AutoLoaded macro sees it and acts upon it.


  DETAILED DESCRIPTION

  - For Windows:
    - TSE itself already case-insensitively opens a file, and afterwards shows
      an editor buffer with the file name cased as it occurs on disk but with
      the buffer path cased as provided by the file's opener.

      This extension changes the shown buffer path to its disk casing.

      Example: Opening "tse\MAC\adjust.s" shows you "tse\mac\adjust.s".

  - For Linux:
    - What it does NOT do:

      It never interferes with opening a correctly cased disk folder or file.

    - If a folder or file is opened with an incorrectly cased name,
      then TSE itself either returns an error or opens an empty editor buffer.
      (Which one it does for a folder depends on the TSE version.)

      If TSE does not return an error, then just before you would start editing
      the empty editor buffer this extension respectively opens or loads a
      case-insensitively matching disk folder or file if such does exist.

      In the unlikely event that no case-sensitive match exists and multiple
      case-insensitive matches exist, you get to choose one from a list.

      Examples: Opening "tse/MaC/Adjust.S" gives you "tse/mac/adjust.s".
                Opening "tse/MAC" might execute File Open for "tse/mac".

    - If you opened a file, and then in the editor renamed only the case of
      its buffer name, then when saving the file to disk TSE itself will just
      save the new disk file alongside the old one.

      This extension will also delete the old file.

      This is done safely by first checking if the save succeeded,
      and by only then deleting the old file.

      Example: Opening and renaming "tse/mac/adjust.s" to "tse/mac/Adjust.s"
               in the editor, and then saving it, will save the disk file
               "tse/mac/Adjust.s" and upon success delete the disk file
               "tse/mac/adjust.s".


  TODO
    MUST
    SHOULD
    COULD
    - In Windows the drive letter does not get cased.
    WONT


  TECHNICAL NOTES
    To the end user this macro appears to implement some overlapping
    functionality in Windows and Linux, while in its implementation there is
    hardly any overlap between what it does for Windows TSE and Linux TSE.

    For communicating with end users about partially unifying Windows and Linux
    functionality, and to have one common "source of truth" to maintain, it
    still makes sense to implement this as one macro.

    Lesson learned: The _ON_FILE_LOAD_ hook only triggers for existing files,
    so in Linux it cannot be used to rename an incorrectly cased file before
    loading it.


  HISTORY
    v0.2 - 8 Jul 2019
      Initial beta release.

    v1.0 - 8 Sep 2019
      Focused the macro's purpose on casing folder and file names,
      and removed obsolete and fringe features.
      Renamed the macro from "FqnAdapter" to "CaseFilename".

*/





// Compatibility restriction and mitigations



/*
  When compiled with a TSE version below TSE 4.0 the compiler reports
  a syntax error and hilights the first applicable line below.
*/

#ifdef LINUX
  #define WIN32 TRUE
#endif

#ifdef WIN32
#else
   16-bit versions of TSE are not supported. You need at least TSE 4.0.
#endif

#ifdef EDITOR_VERSION
#else
   Editor Version is older than TSE 3.0. You need at least TSE 4.0.
#endif

#if EDITOR_VERSION < 4000h
   Editor Version is older than TSE 4.0. You need at least TSE 4.0.
#endif



#if EDITOR_VERSION < 4400h
  /*
    StrReplace() 1.0

    If you have TSE Pro 4.0 or 4.2, then this proc almost completely implements
    the built-in StrReplace() function of TSE Pro 4.4.
    The StrReplace() function replaces a string (pattern) inside a string.
    It works for strings like the Replace() function does for files, so read
    the Help for the Replace() function for the usage of the options, but apply
    these differences while reading:
    - Where Replace() refers to "file" and "line", StrReplace() refers to
      "string".
    - The options "g" ("global", meaning "from the start of the string")
      and "n" ("no questions", meaning "do not ask for confirmation on
      replacements") are implicitly always active, and can therefore be omitted.
    Notable differences between the procedure below with TSE 4.4's built-in
    function are, that here the fourth parameter "options" is mandatory
    and that the fifth parameter "start position" is not allowed.
  */
  integer strreplace_id = 0
  string proc StrReplace(string needle, string haystack, string replacer, string options)
    integer i                      = 0
    integer org_id                 = GetBufferId()
    string  result  [MAXSTRINGLEN] = haystack
    string  validated_options [20] = 'gn'
    for i = 1 to Length(options)
      if (Lower(SubStr(options, i, 1)) in '0'..'9', 'b', 'i','w', 'x', '^', '$')
        validated_options = validated_options + SubStr(options, i, 1)
      endif
    endfor
    if strreplace_id == 0
      strreplace_id = CreateTempBuffer()
    else
      GotoBufferId(strreplace_id)
      EmptyBuffer()
    endif
    InsertText(haystack, _INSERT_)
    lReplace(needle, replacer, validated_options)
    result = GetText(1, CurrLineLen())
    GotoBufferId(org_id)
    return(result)
  end StrReplace
#endif



// End of compatibility restriction and mitigations





// Global constants

#define   CCF_FLAGS    _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_

#ifdef LINUX
  #define IS_NOT_LINUX FALSE
  string  SLASH [1]  = '/'
#else
  #define IS_NOT_LINUX TRUE
  string  SLASH [1]  = '\'
#endif



// Global variables

string    macro_name               [MAXSTRINGLEN] = ''

#ifdef LINUX
  integer old_dateformat                          = 0
  integer old_dateseparator                       = 0
  integer old_timeformat                          = 0
  integer old_timeseparator                       = 0
  integer tmp_id                                  = 0
  string  varname_disk_name        [MAXSTRINGLEN] = ''
  string  varname_disk_path        [MAXSTRINGLEN] = ''
  string  varname_new_disk_fqn     [MAXSTRINGLEN] = ''
  string  varname_old_disk_fqn     [MAXSTRINGLEN] = ''
  string  varname_rename_date_time [MAXSTRINGLEN] = ''
#endif



// Local procedures


#ifdef LINUX

  proc set_my_date_time_format()
    old_dateformat    = Set(DateFormat   , 6       ) // yyyy-mm-dd.
    old_dateseparator = Set(DateSeparator, Asc('-'))
    old_timeformat    = Set(TimeFormat   , 1       ) // hh:mm:ss, 24h, fixed length.
    old_timeseparator = Set(TimeSeparator, Asc(':'))
  end set_my_date_time_format

  proc restore_old_date_time_format()
    Set(DateFormat   , old_dateformat   )
    Set(DateSeparator, old_dateseparator)
    Set(TimeFormat   , old_timeformat   )
    Set(TimeSeparator, old_timeseparator)
  end restore_old_date_time_format

  integer proc seconds_in_previous_months(integer year, integer month)
    string  days_list   [42] = '0 31 59 90 120 151 181 212 243 273 304 334'
    integer days_upto_month  = 0
    integer result           = 0
    days_upto_month = Val(GetToken(days_list, ' ', month))
    if month > 2
      if  year mod 400 == 0
      or (    year mod   4 == 0
          and year mod 100 <> 0)
        days_upto_month = days_upto_month + 1
      endif
    endif
    result = days_upto_month * 86400
    return(result)
  end seconds_in_previous_months

  integer proc date_time_to_seconds(string date_time)
    integer result = 0

    integer year   = Val(date_time[ 1: 4])
    integer month  = Val(date_time[ 6: 2])
    integer day    = Val(date_time[ 9: 2])
    integer hour   = Val(date_time[12: 2])
    integer minute = Val(date_time[15: 2])
    integer second = Val(date_time[18: 2])

    result = second         +
             minute *    60 +
             hour   *  3600 +
             day    * 86400 +
             seconds_in_previous_months(year, month)
    return(result)
  end date_time_to_seconds

  /*
    In the context of this macro this proc fails 100% of the time for dates
    with different years. But also in the context of this macro the two
    date/times are normally within a second of each other, so that is extremely
    unlikely to occur, and then would result in a harmless error:

    If you rename only the case of a file in the editor, and save the file
    on December 31 between 23:59:99 and 24:00:00, then the old filename runs
    a high risk of not be deleted from disk.
  */
  integer proc subtract_date_times(string p1_date_time, string p2_date_time)
    integer result     = 0
    integer sign       = 0
    integer t1_seconds = 0
    integer t2_seconds = 0
    if p1_date_time >= p2_date_time
      sign       = 1
      t1_seconds = date_time_to_seconds(p1_date_time)
      t2_seconds = date_time_to_seconds(p2_date_time)
    else
      sign       = -1
      t1_seconds = date_time_to_seconds(p2_date_time)
      t2_seconds = date_time_to_seconds(p1_date_time)
    endif
    result = (t1_seconds - t2_seconds) * sign
    return(result)
  end subtract_date_times

  string proc get_system_date_time()
    string result [19] = ''
    set_my_date_time_format()
    result = GetDateStr() + ' ' + GetTimeStr()
    restore_old_date_time_format()
    return(result)
  end get_system_date_time

  string proc get_file_date_time(string fqn)
    string result [19] = ''
    if FindThisFile(fqn)
      set_my_date_time_format()
      result = FFDateStr() + ' ' + FFTimeStr()
      restore_old_date_time_format()
    endif
    return(result)
  end get_file_date_time

  proc linux_remember_buffer_name()
    SetBufferStr(varname_disk_path, SplitPath(CurrFilename(), _DRIVE_|_PATH_))
    SetBufferStr(varname_disk_name, SplitPath(CurrFilename(),  _NAME_|_EXT_ ))
  end linux_remember_buffer_name

  proc linux_adapt_buffer_name_action()
    string buffer_path [MAXSTRINGLEN] = SplitPath(CurrFilename(), _DRIVE_|_PATH_)
    string buffer_name [MAXSTRINGLEN] = SplitPath(CurrFilename(), _NAME_ |_EXT_ )
//  string disk_name   [MAXSTRINGLEN] = ''
    if GetBufferStr(varname_disk_name) == ''
      // This happens if a buffer is not the direct result of opening a disk
      // file. Either a non-existing disk file was opened, or a macro created
      // a same-name editing buffer for an existing disk file.
      // In v0.2 of this macro I used to think it should do something in one of
      // these cases, but I cannot reproduce a good reason, so I deleted it.
    else
      if  EquiStr(GetBufferStr(varname_disk_name) ,  buffer_name)
      and         GetBufferStr(varname_disk_name) <> buffer_name
        // We loaded a buffer file and then only changed the case of its name.
        // In this situation we save the file with the new buffer name
        // and afterwards on success delete the disk file with the old name.
        SetBufferStr(varname_old_disk_fqn,
                     Format(GetBufferStr(varname_disk_path),
                            GetBufferStr(varname_disk_name)))
        SetBufferStr(varname_new_disk_fqn,
                     Format(buffer_path,
                            buffer_name))
        SetBufferStr(varname_rename_date_time, get_system_date_time())
      endif
    endif
    SetBufferStr(varname_disk_path       , buffer_path)
    SetBufferStr(varname_disk_name       , buffer_name)
  end linux_adapt_buffer_name_action

  proc linux_adapt_buffer_name_cleanup()
    string file_date_time         [19] = ''
    string new_disk_fqn [MAXSTRINGLEN] = GetBufferStr(varname_new_disk_fqn)
    string old_disk_fqn [MAXSTRINGLEN] = GetBufferStr(varname_old_disk_fqn)
    string rename_date_time       [19] = GetBufferStr(varname_rename_date_time)
    if  rename_date_time <> ''
    and old_disk_fqn     <> ''
    and new_disk_fqn     <> ''
      if  FileExists(old_disk_fqn)
      and FileExists(new_disk_fqn)
        file_date_time = get_file_date_time(new_disk_fqn)
        // In the real world the saved file date/time can sometimes be a second
        // older than the system date/time when the save was initiated. Bummer.
        if subtract_date_times(file_date_time, rename_date_time) >= -1
          EraseDiskFile(old_disk_fqn)
        endif
      endif
    endif
    DelBufferVar(varname_rename_date_time)
    DelBufferVar(varname_old_disk_fqn)
    DelBufferVar(varname_new_disk_fqn)
  end linux_adapt_buffer_name_cleanup

  proc linux_create_disk_match_list(string p_complete_fqn,
                                    string p_matched_fqn)
    integer handle                     = 0
    string  match_name  [MAXSTRINGLEN] = ''
    string  matched_fqn [MAXSTRINGLEN] = p_matched_fqn
    integer matched_tokens             = NumTokens(p_matched_fqn , SLASH)
    integer total_tokens               = NumTokens(p_complete_fqn, SLASH)

    // Linux fqn's start with a slash, which for consistency forces us to set
    // the number of slash separated tokens for an empty string from 0 to 1.
    matched_tokens = iif(matched_tokens, matched_tokens, 1)
    total_tokens   = iif(total_tokens  , total_tokens  , 1)

    // Proc preconditions
    if  (  p_matched_fqn == ''
        or Pos(Lower(p_matched_fqn), Lower(p_complete_fqn)) == 1)
    and matched_tokens < total_tokens
    and (  p_matched_fqn == ''
        or FileExists(p_matched_fqn))
      match_name = GetToken(p_complete_fqn, SLASH, matched_tokens + 1)
      handle     = FindFirstFile(matched_fqn + SLASH + '*', -1)
      if handle <> -1
        repeat
          if (FFAttribute() & _DIRECTORY_)
            if  not (FFName() in '.', '..')
            and EquiStr(FFName(), match_name)
              if matched_tokens + 1 == total_tokens
                AddLine(matched_fqn + SLASH + FFName() + SLASH, tmp_id)
              else
                linux_create_disk_match_list(p_complete_fqn,
                                             matched_fqn + SLASH + FFName())
              endif
            endif
          else
            if  EquiStr(FFName(), match_name)
            and matched_tokens + 1 == total_tokens
              AddLine(matched_fqn + SLASH + FFName(), tmp_id)
            endif
          endif
        until not FindNextFile(handle, -1)
        FindFileClose(handle)
      endif
    endif
  end linux_create_disk_match_list

  proc linux_find_best_disk_match()
    string  new_filename [MAXSTRINGLEN] = ''
    integer org_id                      = GetBufferId()
    GotoBufferId(tmp_id)
    EmptyBuffer()
    GotoBufferId(org_id)
    linux_create_disk_match_list(CurrFilename(), '')
    GotoBufferId(tmp_id)
    if NumLines() == 1
      new_filename = GetText(1, CurrLineLen())
    elseif NumLines() > 1
      BegFile()
      if List('No case-sensitive match exists; pick a case-insensitive match:',
              LongestLineInBuffer())
        new_filename = GetText(1, CurrLineLen())
      endif
    endif
    GotoBufferId(org_id)
    if new_filename <> ''
      if new_filename[Length(new_filename): 1] == SLASH
        if EquiStr(new_filename, CurrFilename() + SLASH)
          // Show the directory's picklist.
          if EditFile(QuotePath(new_filename))
            AbandonFile(org_id)
          endif
        else
          Warn(macro_name, ': Program error 1.')
        endif
      else
        if EquiStr(new_filename, CurrFilename())
          if LoadBuffer(new_filename)
            ChangeCurrFilename(new_filename, CCF_FLAGS)
            FileChanged(FALSE)
            BegFile()
            linux_remember_buffer_name()
          else
            Warn(macro_name, ': Error loading "', new_filename, '".')
          endif
        else
          Warn(macro_name, ': Program error 2.')
        endif
      endif
    endif
  end linux_find_best_disk_match

  proc linux_on_file_load()
    linux_remember_buffer_name()
  end linux_on_file_load

  proc linux_on_first_edit()
    if      BufferType() == _NORMAL_
    and not BinaryMode()
    and     NumLines()   == 0
    and not FileExists(CurrFilename())
      linux_find_best_disk_match()
    endif
  end linux_on_first_edit

  proc linux_on_file_save()
    linux_adapt_buffer_name_action()
  end linux_on_file_save

  proc linux_after_file_save()
    linux_adapt_buffer_name_cleanup()
  end linux_after_file_save

#else

  /*
    Given a searched object type (directory or file) in a given parent directory
    return the object on disk that exactly matches the old object name,
    or otherwise the first one that matches it except for case,
    or otherwise an empty string.
  */
  string proc get_disk_name(integer p_disk_object_type,
                            string  p_parent_path,
                            string  p_old_name)
    integer disk_object_type           = p_disk_object_type
    integer found                      = FALSE
    integer handle                     = 0
    string  new_name    [MAXSTRINGLEN] = ''
    string  parent_path [MAXSTRINGLEN] = p_parent_path
    if parent_path == ''
      parent_path = CurrDir()
    endif
    if      Length(parent_path)
    and not (parent_path[Length(parent_path): 1] in '/', '\')
      parent_path = parent_path + SLASH
    endif
    if p_disk_object_type <> _DIRECTORY_
      disk_object_type = -1  // All
    endif
    handle = FindFirstFile(parent_path + '*', disk_object_type)
    if handle <> -1
      repeat
        if EquiStr(FFName(), p_old_name)
          // We have at least a case-insensitive match ...
          if disk_object_type              == _DIRECTORY_ // We searched for that.
          or (FFAttribute() & _DIRECTORY_) == 0 // Searched all, now limit to file.
            // ... now of an object of the searched-for type ...
            if IS_NOT_LINUX
            or FFName() == p_old_name
              // A Windows match or a case-sensitive match:
              // Pick it and stop searching.
              new_name = FFName()
              found    = TRUE
            else
              // A case-insensitive Linux match:
              // Pick the first one, keep searching for a case-sensitive match.
              if new_name == ''
                new_name = FFName()
              endif
            endif
          endif
        endif
      until found
         or not FindNextFile(handle, -1)
      FindFileClose(handle)
    endif
    return(new_name)
  end get_disk_name

  // This proc cases an existing Windows file's fully qualified editor buffer
  // path based on its disk equivalent.
  // It does does not have to do so for the file's name, because TSE already
  // does that.
  proc windows_case_existing_file()
    string  buffer_dir        [MAXSTRINGLEN] = ''
    integer dir_level                        = 0
    integer dir_level_from                   = 1
    integer dir_level_to                     = 0
    string  disk_CurrFileName [MAXSTRINGLEN] = ''
    string  disk_dir          [MAXSTRINGLEN] = ''
    string  disk_path         [MAXSTRINGLEN] = ''
    if Pos(':\', CurrFilename())
      disk_path       = GetToken(CurrFilename(), '\', 1)
      dir_level_from = 2
    endif
    dir_level_to = NumTokens(CurrFilename(), SLASH) - 1
    for dir_level = dir_level_from to dir_level_to
      buffer_dir = GetToken(CurrFilename(), SLASH, dir_level)
      disk_dir   = get_disk_name(_DIRECTORY_, disk_path, buffer_dir)
      if disk_dir == ''
        disk_dir = buffer_dir
      endif
      disk_path = disk_path + SLASH + disk_dir
    endfor
    disk_CurrFileName = disk_path + SLASH +
                        GetToken(CurrFilename(), SLASH, dir_level_to + 1)
    if EquiStr(CurrFilename(), disk_CurrFileName)
      ChangeCurrFilename(disk_CurrFileName, CCF_FLAGS)
    else
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      Warn(macro_name, ': Program error 3 ...')
      Warn(CurrFilename(), ' <> ', disk_CurrFilename)
    endif
  end windows_case_existing_file

  proc windows_on_file_load()
    windows_case_existing_file()
  end windows_on_file_load

#endif


proc WhenLoaded()
  integer org_id = GetBufferId()
  macro_name = SplitPath(CurrMacroFilename(), _NAME_)
  #ifdef LINUX
    varname_rename_date_time = macro_name + ':rename_date_time'
    varname_disk_path        = macro_name + ':disk_path'
    varname_disk_name        = macro_name + ':disk_name'
    varname_new_disk_fqn     = macro_name + ':new_disk_fqn'
    varname_old_disk_fqn     = macro_name + ':old_disk_fqn'
    tmp_id = CreateTempBuffer()
    Hook(_ON_FILE_LOAD_   , linux_on_file_load   )
    Hook(_ON_FIRST_EDIT_  , linux_on_first_edit  )
    Hook(_ON_FILE_SAVE_   , linux_on_file_save   )
    Hook(_AFTER_FILE_SAVE_, linux_after_file_save)
  #else
    Hook(_ON_FILE_LOAD_   , windows_on_file_load )
  #endif
  GotoBufferId(org_id)
end WhenLoaded

