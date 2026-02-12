/*
  Macro           TSEfilVrs
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   TSE Pro v4 upwards
  Version         v1.0.1   17 Sep 2022

  This tool lists TSE's internal editor version number for one file or for
  files in a folder.

  Fair warning: Even for uber-TSE-nerds it would take an exceptional situation
  for this tool to be of any practical use.

  Context:
  For different but close TSE releases, the editor and compiler executables
  and .mac files might be compatible with each other.
  This means that macros do not always need to be recompiled for a new release,
  as is currently sometimes skipped for .si macros.
  Whether this is the case is administratively determined by the
  "internal editor version number" of these executables and .mac files.
  This tool can list the internal editor version numbers of these files.


  USAGE

  You can execute the tool as a macro, optionally with a file or folder as
  parameter. Wildcards "*" and "?" are allowed for file names.
  If no parameter is supplied, then the tool prompts for one.

  It returns a new file buffer with a list of the found files' properties:
    <date> <time> <attributes> <internal editor version numer> <full file name>
  The list is sorted on <internal editor version number>
  Files that do not have a TSE internal editor version are listed with a zero.
  If a folder was supplied, then files in subfolders are listed too.

  Example input:
    d:\tse                  (lists subfolders too)
    d:\tse\                    ,,
    d:\tse\*                   ,,
    d:\tse\mac\*.mac        (just lists .mac files the mac folder itself)
    d:\tse\mac\adjust.mac

  Example output:
    2012-01-26  3:57:16 _____a          0 d:\tse\mac\adjust.s
    2020-03-26  0:29:20 _____a      12340 d:\tse\bak001\adjust.mac
    2020-04-30 11:44:16 _____a      12341 d:\tse\bak005\adjust.mac
    2020-10-17 12:45:30 _____a      12346 d:\tse\mac\adjust.mac


  INSTALLATION

  Just put this file in TSE's "mac" folder and compile it there, for example
  by opening it in TSE and using the Macro Compile menu.


  BACKGROUND

  Here a TSE executable means
    a TSE editor executable like g32.exe and e32.exe, and
    a TSE compiler executable like sc32.exe.

  Each TSE release has an "editor version number" and an "internal editor
  version number".

  The "editor version number" is a period-separated string.
  It varies being displayed with and without a "v" prefix.
  The editor displays it in the start-up screen and in the Help About menu.
  The compiler displays it when started from the command line.
  As of TSE v4.4 it is returned by the VersionStr() function.

  The compiler directive EDITOR_VERSION is a not-detailed number representing
  a group of main editor version numbers: for example editor versions "v4.00"
  and "v4.00e" both have EDITOR_VERSION value 4000h, and all TSE Beta editor
  versions after v4.4 have EDITOR_VERSION value 4500h. There exist no
  intervening EDITOR_VERSION values between 4000h, 4200h, 4400h and 4500h.

  The "internal editor version number" is a number.
  It is not displayed by the editor or the compiler.
  It is returned by the Version() function.
  TSE internally uses it as follows:
    When a TSE release has new macro syntax, the editor and compiler
    executables get a new internal editor version number.
    So note that especially not every TSE Beta release gets a new one.
    When a macro is compiled, the compiler passes its internal TSE version
    number on to the .mac file.
    When the editor executes a macro, it checks whether its own internal editor
    version number matches the macro's, and reports "Macro compiled with wrong
    sc" when the numbers do not match.

  Aside: Help files seem to have an internal editor version number too, but it
  differs from the rest of the editor. Its purpose, if any, is unknown.


  HISTORY

  v1       21 Oct 2020
    Initial release.

  v1.0.1   17 Sep 2022
    Fixed incompatibility with TSE's '-i' command line option
    and the TSELOADDIR environment variable.

*/





// Start of compatibility restrictions and mitigations



/*
  When compiled with a TSE version below TSE 4.0 the compiler reports
  a syntax error and hilights the first applicable line below.

  There is a beta Linux version of TSE that is not bug-free and in which some
  significant features do not work, but all its Linux versions are above
  TSE 4.0, and they all are 32-bits which is what WIN32 actually signifies.
*/

#ifdef LINUX
  #define WIN32 TRUE
  string SLASH [1] = '/'
#else
  string SLASH [1] = '\'
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
    StrFind() 1.0

    If you have TSE Pro 4.0 or 4.2, then this proc implements the core of the
    built-in StrFind() function of TSE Pro 4.4.
    The StrFind() function searches a string or pattern inside another string
    and returns the position of the found string or zero.
    It works for strings like the regular Find() function does for files,
    so read the Help for the regular Find() function for the usage of the
    options, but apply these differences while reading:
    - Where the Find() (related) documentation refers to "file" and "line",
      StrFind() refers to "string".
    - The search option "g" ("global", meaning "from the start of the string")
      is implicit and can therefore always be omitted.
    As with the regular Find() function all characters are allowed as options,
    but here only these are acted upon: b, i, w, x, ^, $.

    Notable differences between the procedure below with TSE 4.4's built-in
    function:
    - The third parameter "options" is mandatory.
    - No fourth parameter "start" (actually occurrence: which one to search).
    - No fifth  parameter "len" (returning the length of the found text).

    Technical implementation notes:
    - To be reuseable elsewhere the procedure's source code is written to work
      independently of the rest of the source code.
      That said, it is intentionally not implemented as an include file, both
      for ease of installation and because one day another macro might need its
      omitted parameters, which would be an include file nightmare.
    - A tiny downside of the independent part is, that StrFind's buffer is not
      purged with the macro. To partially compensate for that if the macro is
      restarted, StrFind's possibly pre-existing buffer is searched for.
    - The fourth and fifth parameter are not implemented.
      - The first reason was that I estimated the tiny but actual performance
        gain and the easier function call to be more beneficial than the
        slight chance of a future use of these extra parameters.
      - The main reason turned out to be that in TSE 4.4 the fourth parameter
        "start" is erroneously documented and implemented.
        While this might be corrected in newer versions of TSE, it neither
        makes sense to me to faithfully reproduce these errors here, nor to
        make a correct implementation that will be replaced by an incorrect
        one if you upgrade to TSE 4.4.
  */
  integer strfind_id = 0
  integer proc StrFind(string needle, string haystack, string options)
    integer i                           = 0
    string  option                  [1] = ''
    integer org_id                      = GetBufferId()
    integer result                      = FALSE  // Zero.
    string  strfind_name [MAXSTRINGLEN] = ''
    string  validated_options       [7] = 'g'
    for i = 1 to Length(options)
      option = Lower(SubStr(options, i, 1))
      if      (option in 'b', 'i', 'w', 'x', '^', '$')
      and not Pos(option, validated_options)
        validated_options = validated_options + option
      endif
    endfor
    if strfind_id
      GotoBufferId(strfind_id)
      EmptyBuffer()
    else
      strfind_name = SplitPath(CurrMacroFilename(), _NAME_) + ':StrFind'
      strfind_id   = GetBufferId(strfind_name)
      if strfind_id
        GotoBufferId(strfind_id)
        EmptyBuffer()
      else
        strfind_id = CreateTempBuffer()
        ChangeCurrFilename(strfind_name, _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
      endif
    endif
    InsertText(haystack, _INSERT_)
    if lFind(needle, validated_options)
      result = CurrPos()
    endif
    GotoBufferId(org_id)
    return(result)
  end StrFind
#endif



// End of compatibility restrictions and mitigations





// Global constants

#define FIND_ALL_FILES  -1
#define FIND_FILE_ERROR -1



// Global variables
string macro_name [MAXSTRINGLEN] = ''





/*
  Return TSE's original LoadDir() if LoadDir() has been redirected
  by TSE's "-i" commandline option or a TSELOADDIR environment variable.
*/
string proc original_LoadDir()
  return(SplitPath(LoadDir(TRUE), _DRIVE_|_PATH_))
end original_LoadDir



/*
  Frequency defines how many times to do a next_char().
*/
integer proc next_char(integer frequency)
  integer f  = frequency
  integer ok = TRUE
  while ok
  and   f > 0
    ok = NextChar()
    if  ok
    and CurrChar() == _AT_EOL_
      ok = NextChar()
    endif
    f = f - 1
  endwhile
  return(ok)
end next_char



/*
  find_across_lines is a very simplified version from what the name suggests.
  It works here in a known context; it will not work in other contexts.
*/

string VERSION_SEACRH_STRING [7] = Chr(255) + Chr(255) + 'Bobbi'

integer find_across_lines_id = 0

integer proc find_across_lines(string search_string)
  integer found                   = FALSE
  integer old_RemoveTrailingWhite = 0
  integer org_id                  = GetBufferId()
  integer p                       = 0
  found = lFind(search_string, 'gi')
  if not found
    if not find_across_lines_id
      find_across_lines_id = CreateTempBuffer()
      GotoBufferId(org_id)
    endif
    old_RemoveTrailingWhite = Set(RemoveTrailingWhite, OFF)
    PushBlock()
    PushLocation()
    BegFile()
    while not found
    and   CurrLine() < NumLines()
      MarkColumn(CurrLine(), 1, CurrLine(), CurrLineLen())
      GotoBufferId(find_across_lines_id)
      EmptyBuffer()
      CopyBlock()
      GotoBufferId(org_id)
      Down()
      MarkColumn(CurrLine(), 1, CurrLine(), CurrLineLen())
      GotoBufferId(find_across_lines_id)
      EndLine()
      CopyBlock()
      BegLine()
      found = lFind(search_string, 'gi')
      p     = CurrPos()
      GotoBufferId(org_id)
    endwhile
    if found
      KillLocation()
      Up()
      GotoPos(p)
    else
      PopLocation()
    endif
    PopBlock()
    Set(RemoveTrailingWhite, old_RemoveTrailingWhite)
  endif
  return(found)
end find_across_lines



integer proc get_tse_version(string file_fqn)
  // find_across_lines() and next_char() because the search string or the
  // value behind it could occur across two "binary lines".
  integer file_id       = 0
  integer file_tse_vrs  = 0
  integer org_id        = GetBufferId()
  if FileExists(file_fqn)
    file_id = CreateTempBuffer()
    if file_id
      if LoadBuffer(file_fqn, 8192)
        if find_across_lines(VERSION_SEACRH_STRING)
          if next_char(Length(VERSION_SEACRH_STRING))
            file_tse_vrs = CurrChar()
            if next_char(1)
              file_tse_vrs = CurrChar() * 256 + file_tse_vrs
            else
              file_tse_vrs = 0
            endif
          endif
        endif
      endif
      GotoBufferId(org_id)
      AbandonFile (file_id)
    endif
  endif
  // Alas, we need an explicit exception for two macro source files.
  if (Lower(SplitPath(file_fqn, _NAME_|_EXT_)) in 'decomp.s', 'recomp.s')
    file_tse_vrs = 0
  endif
  return(file_tse_vrs)
end get_tse_version

string proc strip_path(string file_fqn)
  string result [MAXSTRINGLEN] = file_fqn
  if StrFind('[\*\?]', SplitPath(result, _NAME_|_EXT_), 'x')
    result = SplitPath(result, _DRIVE_|_PATH_)
  endif
  result = RemoveTrailingSlash(result)
  return(result)
end strip_path

string proc ffattr_to_str(integer attrs)
  string result [6] = '______'
  if attrs & _READ_ONLY_
    result[1] = 'r'
  endif
  if attrs & _HIDDEN_
    result[2] = 'h'
  endif
  if attrs & _SYSTEM_
    result[3] = 's'
  endif
  if attrs & _VOLUME_
    result[4] = 'v'
  endif
  if attrs & _DIRECTORY_
    result[5] = 'd'
  endif
  if attrs & _ARCHIVE_
    result[6] = 'a'
  endif
  return(result)
end ffattr_to_str

proc list_tse_file_version(string search_fqn)
  string  file_attr              [6] = ''
  string  file_date             [10] = ''
  string  file_fqn    [MAXSTRINGLEN] = ''
  string  file_path   [MAXSTRINGLEN] = ''
  string  file_time              [8] = ''
  integer file_tse_version           = 0
  string  folder_path [MAXSTRINGLEN] = ''
  integer search_handle              = 0
  search_handle = FindFirstFile(search_fqn, FIND_ALL_FILES)
  if search_handle == FIND_FILE_ERROR
    Warn('Could not list "', search_fqn, '".')
  else
    folder_path = strip_path(search_fqn) + SLASH
    file_path   = SplitPath(search_fqn, _DRIVE_|_PATH_)
    repeat
      if FFAttribute() & _DIRECTORY_
        if not (FFName() in '.', '..')
          list_tse_file_version(folder_path + FFName() + SLASH + '*')
        endif
      else
        // First save the FF function values into variables.
        file_fqn  = file_path + FFName()
        file_date = FFDateStr()
        file_time = FFTimeStr()
        file_attr = ffattr_to_str(FFAttribute())
        // Show progress
        KeyPressed()
        Message(file_fqn)
        KeyPressed()
        // Last, because it might overwrite the previous FF function values.
        file_tse_version = get_tse_version(file_path + FFName())
        // Add the line in > 1 step so it can become > 255 characters.
        AddLine(Format(file_date; file_time; file_attr, file_tse_version:11))
        EndLine()
        InsertText(' ')
        InsertText(file_fqn)
      endif
    until not FindNextFile(search_handle, FIND_ALL_FILES)
    FindFileClose(search_handle)
  endif
end list_tse_file_version

proc WhenLoaded()
  macro_name = SplitPath(CurrMacroFilename(), _NAME_)
end WhenLoaded

proc Main()
  integer file_attr               = 0
  string  file_fqn [MAXSTRINGLEN] = Query(MacroCmdLine)
  integer history_no              = 0
  integer old_DateFormat          = Set(DateFormat, 6)
  integer old_Insert              = Set(Insert    ,ON)
  integer old_TimeFormat          = Set(TimeFormat, 1)
  string  prev_file_vrs      [10] = ''
  file_attr = FileExists(file_fqn)
  if file_attr == 0
    history_no = GetFreeHistory(macro_name + ':Input')
    if not FindHistoryStr(original_LoadDir(), history_no)
      AddHistoryStr(original_LoadDir(), history_no)
    endif
    if Ask('List TSE file version numbers for which file or folder:',
           file_fqn, history_no)
      file_fqn  = Trim(file_fqn)
      file_attr = FileExists(file_fqn)
    endif
  endif
  if file_attr
    if      file_attr & _DIRECTORY_
    and not StrFind('[\*\?]', SplitPath(file_fqn, _NAME_|_EXT_), 'x')
      file_fqn = strip_path(file_fqn) + SLASH + '*'
    endif
    NewFile()
    list_tse_file_version(file_fqn)
    // Sort the list on the files' internal editor version number.
    MarkColumn(1, 28, NumLines(), 37)
    ExecMacro('sort')
    UnMarkBlock()
    // Add an empty line between files with different internal editor versions.
    BegFile()
    prev_file_vrs = GetText(28, 10)
    while Down()
      if GetText(28, 10) <> prev_file_vrs
        InsertLine()
        Down()
      endif
      prev_file_vrs = GetText(28, 10)
    endwhile
    // Position the cursor at the first interesting point.
    BegFile()
    prev_file_vrs = GetText(28, 10)
    while Down()
    and   GetText(28, 10) == prev_file_vrs
    endwhile
    GotoColumn(37)
    ScrollToCenter()
    if CurrLine() == NumLines()
      BegFile()
    endif
  else
    if Query(Beep)
      Alarm()
    endif
    Warn('No valid folder or file supplied.')
  endif
  Set(DateFormat, old_DateFormat )
  Set(Insert    , old_Insert     )
  Set(TimeFormat, old_TimeFormat )
  PurgeMacro(macro_name)
end Main

