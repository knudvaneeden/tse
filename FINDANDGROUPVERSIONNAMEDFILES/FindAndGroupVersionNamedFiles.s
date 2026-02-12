/*
  Macro           FindAndGroupVersionNamedFiles
  Author          Carlo.Hogeveen@xs4all.nl
  Version         v2.0 - 21 Mar 2020
  Compatibility   TSE Pro v4.0 upwards

  This tool creates a list of groups of those files, the names of which at most
  differ by a (version) suffix at the end of the name.

  This would also create groups of files containing only identical filenames.
  So first it asks if you want those groups reported too.

  Then it asks for a folder or a space separated list of folders, like
    C:\Users\MyName
  or
    C:\ D:\



  For example, if the folder D:\SimilarFiles contains these files

    D:\SimilarFiles\a\1.txt
    D:\SimilarFiles\a\a.txt
    D:\SimilarFiles\a\b.txt
    D:\SimilarFiles\a\c.txt
    D:\SimilarFiles\a\d.txt
    D:\SimilarFiles\a\e.txt
    D:\SimilarFiles\a\f.txt
    D:\SimilarFiles\b\2.txt
    D:\SimilarFiles\b\a.txt
    D:\SimilarFiles\b\c(1).txt
    D:\SimilarFiles\b\c1.txt
    D:\SimilarFiles\b\c[xyz].txt
    D:\SimilarFiles\b\c_1a.txt
    D:\SimilarFiles\b\c_1_a.txt
    D:\SimilarFiles\b\c_1_b.txt
    D:\SimilarFiles\b\e.txt
    D:\SimilarFiles\b\fs.txt

  and if this tool is run with the first question answered "Yes"
  for folder "D:\SimilarFiles", then the tool would report:

    2020-03-17 13:56:10                 0 D:\SimilarFiles\a\a.txt
    2020-03-17 13:56:10                 0 D:\SimilarFiles\b\a.txt

    2020-03-17 13:56:34                 0 D:\SimilarFiles\a\c.txt
    2020-03-17 13:56:34                 0 D:\SimilarFiles\b\c(1).txt
    2020-03-17 13:56:34                 0 D:\SimilarFiles\b\c1.txt
    2020-03-17 13:56:34                 0 D:\SimilarFiles\b\c[xyz].txt
    2020-03-17 13:56:34                 0 D:\SimilarFiles\b\c_1_a.txt
    2020-03-17 13:56:34                 0 D:\SimilarFiles\b\c_1_b.txt
    2020-03-17 13:56:34                 0 D:\SimilarFiles\b\c_1a.txt

    2020-03-17 13:56:48                 0 D:\SimilarFiles\a\e.txt
    2020-03-17 13:56:48                 0 D:\SimilarFiles\b\e.txt



  Known problems:

  - Ironically, sorting with the current implementation of the QuickSort
    algorithm is surprisingly slow, which becomes annoying when sorting
    large folders or worse, a whole disk.
    Aside, weirdly, the sort goes a few times faster when TSE is minimized,
    which may be a Windows thing, not a TSE thing.
    But we cannot simply use TSE's sort command instead, because our sort key
    is not column-based.

  - When testing with sorting a whole disk, the macro sometimes aborted with
      "Stack overflow in macro interpreter"
    and other error messages.
    Just restarting TSE and rerunning the macro solved the problem.
    Debugging revealed that in that specific test-case the macro itself uses
    only about half of the available macro stack size, so what happened?
    So far I have not been able to reproduceably pin the cause down: It might
    or might not have to do with minimizing and maximizing TSE during the sort.
*/





// General compatibility restrictions and mitigations

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

// End of general compatibility restrictions and mitigations



forward integer proc quicksort_compare(var integer line1, var integer line2)



/*
  Include         QuickSort.inc
  Author          Carlo.Hogeveen@xs4all.nl
  Version         1.0
  Date            21 apr 2017
  Compatibility   TSE 4.0 upwards

  This is not a macro but an include file for a macro!

  [ Actually, I copied the content of the include file into SimilarFiles.s
    to avoid burdening the end user with file versions. ]

  Using this include file you can create a macro to sort on any criteria,
  as long as they are line-based.

  For instance, using this you can easily create macros to:
  - Sort a file list on fully qualified names, but with files before dirs.
  - Sort a CSV file on any field(s).

  All you as a macro programmer have to do, is provide a quicksort_compare
  function which accepts two line numbers, and returns -1, 0 or 1 if the
  first line should be before, anywhere or after the second line.

  Based on your comparison function for TWO lines, the provided
    quicksort(<line_number_from>, <line_number_to>)
  function in this include file will sort ALL requested lines.



  This include-file implements a QuickSort procedure,
  which can be used by a TSE macro the following way:

  - This file needs to be installed in TSE's macro folder.

  - The TSE macro must contain the line:
    #include ['QuickSort.inc']

  - Above that, the TSE macro should provide its own "quicksort_compare"
    function:

      integer proc quicksort_compare(integer line1, integer line2)
        integer result = 0
        if <line1 should be before line2>
          result = -1
        elseif <line1 should be after line2>
          result = 1
        endif
        return(result)
      end quicksort_compare

    in which the "< ... >" conditions may be as simple or complex as the
    macro programmer whishes, as long as they adhere to the boolean test
    specifications between the "< ... >".

  - To avoid name clashes the TSE macro should not define any procedures
    or variables with names starting with "quicksort" except the
    "quicksort_compare" function and optionally a QUICKSORT_DEBUG constant.

  - Optionally the TSE macro may define its own QUICKSORT_DEBUG constant,
    which when set to TRUE will make the sort show some statistics.

  - The TSE macro contains a call to
      quicksort(<line number from>, <line number to>)
    when the lines to be sorted are in the current TSE buffer.

*/



#define QUICKSORT_SHOW_PROGRESS TRUE

#define QUICKSORT_DEBUG_STACK   FALSE
#define QUICKSORT_DEBUG_TIME    FALSE

#if QUICKSORT_DEBUG_TIME
  integer quicksort_debug_start_time  = 0
  integer quicksort_debug_run_time    = 0
  integer quicksort_debug_run_time_hh = 0
  integer quicksort_debug_run_time_mm = 0
  integer quicksort_debug_run_time_ss = 0
  integer quicksort_debug_run_time_dd = 0
#endif

#if QUICKSORT_DEBUG_STACK
  integer quicksort_recur_depth       = 0
  integer quicksort_recur_depth_1_MSA = 0
  integer quicksort_recur_depth_m     = 0
  integer quicksort_recur_depth_m_MSA = 0
#endif

/*
  Specifically for FindAndGroupVersionNamedFiles several global progres
  variables and a proc were added here in order to be able to report
  on QuickSort's progress.
*/
integer quicksort_progress_counter        = 0
integer quicksort_progress_line_from      = 0
integer quicksort_progress_line_to        = 0
integer quicksort_progress_numlines       = 0
integer quicksort_progress_start_line     = 0

proc quicksort_progress_report()
  integer maximum_progress_percentage = 0
  integer minimum_progress_percentage = 0
  quicksort_progress_counter  = 0
  minimum_progress_percentage = (   quicksort_progress_line_from
                              - quicksort_progress_start_line)
                            * 100 / quicksort_progress_numlines
  maximum_progress_percentage = (   quicksort_progress_line_to
                              - quicksort_progress_start_line)
                            * 100 / quicksort_progress_numlines
/*
QuickSort progress between 100 %  and 100 %  (Currently sorting line 1234567890)
*/
  KeyPressed()
  Message('QuickSort progress between';
          minimum_progress_percentage:3;
          '%  and';
          maximum_progress_percentage:3;
          '%  (Currently sorting line';
          CurrLine():Length(Str(NumLines())),
          ') ')
  KeyPressed()
end quicksort_progress_report

proc quicksort_order(var integer current_line, var integer pivot_line)
  integer quicksort_comparison = quicksort_compare(current_line , pivot_line)

  quicksort_progress_counter = quicksort_progress_counter + 1
  if quicksort_progress_counter == 10000
    quicksort_progress_report()
  endif

  if  current_line         <  pivot_line
  and quicksort_comparison == 1
    MarkLine(current_line, current_line)
    Cut()
    current_line = current_line - 1
    pivot_line   = pivot_line   - 1
    GotoLine(pivot_line)
    Set(InsertLineBlocksAbove, OFF)
    Paste()
  elseif current_line         >  pivot_line
  and    quicksort_comparison == -1
    MarkLine(current_line, current_line)
    Cut()
    GotoLine(pivot_line)
    Set(InsertLineBlocksAbove, ON)
    Paste()
    pivot_line = pivot_line + 1
  endif
end quicksort_order

integer proc quicksort_partition(integer line_from, integer line_to)
  integer current_line
  integer pivot_line = line_from
  if line_from < line_to
    pivot_line = (line_from + line_to) / 2
    for current_line = line_from to line_to
      quicksort_order(current_line, pivot_line)
    endfor
  endif
  return(pivot_line)
end quicksort_partition


integer quicksort_stack_warning_given = FALSE

proc quicksort_macro_stack_warning()
  if not quicksort_stack_warning_given
    quicksort_stack_warning_given = TRUE
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    Warn('WARNING:  MacroStackAvail ='; MacroStackAvail())
  endif
end quicksort_macro_stack_warning


/*
  A global quicksort_pivot_line is used to reduce the stack size for the only
  recursing procedure.
  Note that the debugging code unavoidably adds to the recursion stack size
  it should measure. SO not debugged code will do better stack size-wise.
*/
integer quicksort_pivot_line = 0

proc quicksort_body(integer line_from, integer line_to)
  #if QUICKSORT_DEBUG_STACK
    quicksort_recur_depth = quicksort_recur_depth + 1
    if quicksort_recur_depth == 1
      quicksort_recur_depth_1_MSA = MacroStackAvail()
    elseif quicksort_recur_depth > quicksort_recur_depth_m
      quicksort_recur_depth_m = quicksort_recur_depth
      quicksort_recur_depth_m_MSA = MacroStackAvail()
    endif
  #endif

  quicksort_progress_line_from = line_from
  quicksort_progress_line_to   = line_to

  if MacroStackAvail() < 1000
    quicksort_macro_stack_warning()
  else
    if line_from < line_to
      quicksort_pivot_line = quicksort_partition(line_from, line_to)
      quicksort_body(line_from, quicksort_pivot_line - 1)
      quicksort_body(quicksort_pivot_line + 1, line_to)
    endif
  endif

  #if QUICKSORT_DEBUG_STACK
    quicksort_recur_depth = quicksort_recur_depth - 1
  #endif
end quicksort_body

integer proc quicksort(integer line_from, integer line_to)
  integer old_UndoMode              = UndoMode(OFF)
  integer old_InsertLineBlocksAbove = Query(InsertLineBlocksAbove)
  integer old_UnMarkAfterPaste      = Set(UnMarkAfterPaste, ON)
  integer quicksort_ok              = TRUE

  #if QUICKSORT_DEBUG_TIME
    quicksort_debug_start_time = GetTime()
  #endif

  quicksort_progress_counter         = 0
  quicksort_progress_numlines        = Max(line_to - line_from, 1) // Avoid /0 .
  quicksort_progress_start_line      = line_from

  PushBlock()
  PushPosition()
  quicksort_body(line_from, line_to)
  PopPosition()
  PopBlock()

  #if QUICKSORT_DEBUG_TIME
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    quicksort_debug_run_time     = GetTime() - quicksort_debug_start_time
    quicksort_debug_run_time_dd  = quicksort_debug_run_time mod 100
    quicksort_debug_run_time     = quicksort_debug_run_time  /  100
    quicksort_debug_run_time_ss  = quicksort_debug_run_time mod  60
    quicksort_debug_run_time     = quicksort_debug_run_time  /   60
    quicksort_debug_run_time_mm  = quicksort_debug_run_time mod  60
    quicksort_debug_run_time     = quicksort_debug_run_time  /   60
    quicksort_debug_run_time_hh  = quicksort_debug_run_time
    Warn('Runtime = ',
         quicksort_debug_run_time_hh      , ':',
         quicksort_debug_run_time_mm:2:'0', ':',
         quicksort_debug_run_time_ss:2:'0', '.',
         quicksort_debug_run_time_dd:2:'0',
         ' (hours:minutes:seconds.decimals)')
  #endif

  #if QUICKSORT_DEBUG_STACK
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    Warn('Max recurred depth            = ', quicksort_recur_depth_m, Chr(13),
         'MacroStackAvail at depth 1    = ', quicksort_recur_depth_1_MSA, Chr(13),
         'MacroStackAvail at max depth  = ', quicksort_recur_depth_m_MSA, Chr(13),
         'MacroStackAvail per recursion = ',   ( quicksort_recur_depth_1_MSA
                                               - quicksort_recur_depth_m_MSA)
                                             / (quicksort_recur_depth_m - 1))
  #endif

  UndoMode(old_UndoMode)
  Set(InsertLineBlocksAbove, old_InsertLineBlocksAbove)
  Set(UnMarkAfterPaste     , old_UnMarkAfterPaste)
  return(quicksort_ok)
end quicksort



// TSE version compatibility mitigations for DirList.

#if EDITOR_VERSION < 4500h

  // A few intermediate TSE versions after v4.40 and before v4.40.95
  // are not supportable and will raise a compiler error on FFSizeStr().

  string proc FFSizeStr()
    return(Str(FFSize()))
  end FFSizeStr

  #define FILE_SIZE_COLUMN_WIDTH 15
#else
  #define FILE_SIZE_COLUMN_WIDTH 18
#endif

// End of TSE version compatibility mitigations for DirList.



// Global DirList constants

#define DIGIT_GROUPING_CHARACTER Asc(',')   // American style.



// Global DirList variables

integer inaccessible_files     = 0
integer inaccessible_folders   = 0
integer progress               = 0
string  digit_grouping_chr [1] = Chr(DIGIT_GROUPING_CHARACTER)
string  windmill           [4] = '/-\|'

string proc formatted_FFSizeStr()
  integer i                               = 0
  string  result [FILE_SIZE_COLUMN_WIDTH] = ''
  result = FFSizeStr()
  for i = Length(result) - 3 downto 1 by 3
    if result[i] <> ''
      result = result[1     :            i] +
               digit_grouping_chr           +
               result[i + 1 : MAXSTRINGLEN]
    endif
  endfor
  return(result)
end formatted_FFSizeStr

integer proc DirList(string dirname)
  integer handle        = -1
  integer ok            = TRUE
  string  separator [1] = '\'
  if not (Lower(SubStr(dirname, 1, 1)) in 'c', 'd')
    Delay(1)
  endif
  if dirname[Length(dirname)] == '\'
    separator = ''
  endif
  if progress >= 4
    progress = 1
  else
    progress = progress + 1
  endif
  if  KeyPressed()
  and GetKey() == <Escape>
    ok = FALSE
  endif
  if  ok
    Message(windmill[progress], ' ', dirname, ' ... ')
    handle = FindFirstFile(dirname + separator + '*', -1)
    if handle <> -1
      repeat
        if (FFAttribute() & _DIRECTORY_)
          if not (FFName() in  '.',
                               '..')
            // "> MAXSTRINGLEN - 2" means "inaccessible to DirList".
            if  Length(dirname + separator + FFName()) <= MAXSTRINGLEN - 2
            and FileExists(dirname + separator + FFName())
              DirList(dirname + separator + FFName())
            else
              inaccessible_folders = inaccessible_folders + 1
              AddLine('')
              EndLine()
              InsertText(Format(FFDateStr():                     11,
                                FFTimeStr():                      9,
                                ''         :FILE_SIZE_COLUMN_WIDTH), _INSERT_)
              InsertText(' '      , _INSERT_)
              InsertText(dirname  , _INSERT_)
              InsertText(separator, _INSERT_)
              InsertText(FFName() , _INSERT_)
              InsertText(separator, _INSERT_)
              InsertText(' <inaccessible folder>', _INSERT_)
            endif
          endif
        else
          AddLine('')
          EndLine()
          InsertText(Format(FFDateStr()          :                     11,
                            FFTimeStr()          :                      9,
                            formatted_FFSizeStr():FILE_SIZE_COLUMN_WIDTH),
                                _INSERT_)
          InsertText(' '      , _INSERT_)
          InsertText(dirname  , _INSERT_)
          InsertText(separator, _INSERT_)
          InsertText(FFName() , _INSERT_)
          if not FileExists(dirname + separator + FFName())
            inaccessible_files = inaccessible_files + 1
            InsertText(' <inaccessible file>', _INSERT_)
          endif
        endif
      until not ok
        or not FindNextFile(handle, -1)
      FindFileClose(handle)
    endif
  endif
  return(ok)
end DirList

integer proc set_specialeffects_with_center_popups_on()
  integer old_SpecialEffects = Query(SpecialEffects)
  #if EDITOR_VERSION >= 4400h
    // The flag _CENTER_POPUPS_ exists as of TSE v4.40 .
    old_SpecialEffects = Set(SpecialEffects,
                             Query(SpecialEffects) & _CENTER_POPUPS_)
  #endif
  return(old_SpecialEffects)
end set_specialeffects_with_center_popups_on

integer proc DirList_Main()
  string  dirnames [MAXSTRINGLEN] = Query(MacroCmdLine)
  integer ok                      = TRUE
  integer old_dateformat          = Set(DateFormat, 6) // Sortable dateformat.
  integer old_timeformat          = Query(TimeFormat)
  integer old_CenterFinds         = 0
  integer old_SpecialEffects      = 0
  integer counter                 = 0
  if (old_timeformat in 2, 4)
    old_timeformat = Set(TimeFormat, old_timeformat - 1) // Sortable timeformat.
  endif
  if GetToken(dirnames, ' ', 1) == ''
    if Ask('For which folders do you want a list of groups of version-named files:',
           dirnames,
           GetFreeHistory(SplitPath(CurrMacroFilename(), _NAME_) + ':dirnames'))
    else
      ok = FALSE
    endif
  endif
  if  ok
  and Lower(Trim(dirnames)) == 'all'
    dirnames = ''
    for counter = Asc('a') to Asc('z')
      if FileExists(Chr(counter) + ':\')
        if dirnames == ''
          dirnames = Chr(counter) + ':'
        else
          dirnames = dirnames + ' ' + Chr(counter) + ':'
        endif
      endif
    endfor
  endif
  if  ok
  and NumFileTokens(dirnames) > 0
    repeat
      counter = counter + 1
    until not GetBufferId('DirList.' + Str(counter))
    if CreateBuffer('DirList.' + Str(counter))
      SetUndoOff()
      for counter = 1 to NumFileTokens(dirnames)
        ok = DirList(GetFileToken(dirnames, counter))
        if not ok
          break
        endif
      endfor
      SetUndoOn()
    else
      Warn('DirList could not create buffer: ', 'DirList.' + Str(counter))
      ok = FALSE
    endif
  endif
  if ok
    BegFile()
    if inaccessible_folders
    or inaccessible_files
      old_CenterFinds    = Set(CenterFinds, OFF)
      old_SpecialEffects = set_SpecialEffects_with_center_popups_on()
      lFind('<inaccessible {file}|{folder}>', 'bgx')
      EndLine()
      MarkFoundText()
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      Message('Ready: Marked ', inaccessible_folders, ' folders and ',
           inaccessible_files, ' files as "inaccessible" to TSE.')
      Set(CenterFinds   , old_CenterFinds)
      Set(SpecialEffects, old_SpecialEffects)
      BegFile()
    else
      Message('DirList Ready.')
    endif
  else
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    Warn('DirList aborted.')
    ok = FALSE
  endif
  Set(DateFormat, old_dateformat)
  Set(TimeFormat, old_timeformat)
  return(ok)
end DirList_Main



// Global constants for this macro.

string OPENING_BRACKETS [3] = '({['
string CLOSING_BRACKETS [3] = ')}]'

// Global variables for this macro.
string my_macro_name [MAXSTRINGLEN] = ''

integer proc bracketed_suffix_length(string file_name)
  string  between_brackets [MAXSTRINGLEN] = ''
  integer bracket_level                   = 1
  string  closing_bracket             [1] = ''
  integer file_name_length                = Length(file_name)
  integer i                               = file_name_length - 1
  integer last_char_bracket_type          = 0
  string  opening_bracket             [1] = ''
  integer result                          = 0

  closing_bracket = file_name[file_name_length]
  opening_bracket = OPENING_BRACKETS[Pos(closing_bracket, CLOSING_BRACKETS)]

  while i             > 0
  and   bracket_level > 0
    case file_name[i]
      when closing_bracket
        bracket_level = bracket_level + 1
      when opening_bracket
        bracket_level = bracket_level - 1
    endcase
    i = i - 1
  endwhile

  if bracket_level == 0
    between_brackets = file_name[i + 2 .. file_name_length - 1]
    last_char_bracket_type =  Pos(between_brackets[Length(between_brackets)],
                                  CLOSING_BRACKETS)
    if  last_char_bracket_type > 0
    and between_brackets[1]   == OPENING_BRACKETS[last_char_bracket_type]
      // We recurse for double-bracketed suffixes, like "((1))"
      if bracketed_suffix_length(between_brackets) == Length(between_brackets)
        result = Length(between_brackets) + 2
      endif
    else
      // Our practice-based rule is that a bracketed string is a valid suffix
      // if it only contains zero or more letters and digits.
      if not StrFind('[~0-9A-Za-z]', between_brackets, 'x')
        result = Length(between_brackets) + 2
      endif
    endif
  endif

  return(result)
end bracketed_suffix_length

string proc strip_suffix(string filename)
  string  file_name [MAXSTRINGLEN] = filename
  integer file_name_length         = Length(file_name)
  integer file_name_minimum_length = iif(Length(file_name), Pos('*', file_name) + 1, 1)
  integer searching_for_suffixes   = TRUE

  while searching_for_suffixes
  and   file_name_length > file_name_minimum_length
    case file_name [file_name_length]
      when ')', '}', ']'
        file_name = file_name[1 : file_name_length
                                  - bracketed_suffix_length(file_name)]
      when 'A' .. 'Z', 'a' .. 'z'
        if not (file_name[file_name_length - 1] in 'A' .. 'Z', 'a' .. 'z', '*')
          file_name = file_name[1 : file_name_length - 1]
        endif
      when '*'
        NoOp()
      otherwise
        file_name = file_name[1 : file_name_length - 1]
    endcase
    if Length(file_name) == file_name_length
      searching_for_suffixes = FALSE
    else
      file_name_length = Length(file_name)
    endif
  endwhile

  return(file_name)
end strip_suffix

string proc get_filename_from_line()
  string filename [MAXSTRINGLEN] = ''
  if lFind(SLASH, 'bcg')
    filename = GetText(CurrPos() + 1, MAXSTRINGLEN)
  endif
  return(filename)
end get_filename_from_line

string proc get_sort_key_from_line()
  string sort_key [MAXSTRINGLEN] = ''
  sort_key = get_filename_from_line()
  sort_key = SubStr(SplitPath(sort_key, _EXT_), 2, MAXSTRINGLEN)
             + '*'
             + SplitPath(sort_key, _NAME_)
  sort_key = strip_suffix(sort_key)
  return(sort_key)
end get_sort_key_from_line

/*
  The quicksort order for 2 lines is defined by this proc.

  The proc should return -1 if line1 should be before line2, 1 if line1
  should be after line2, and 0 if their sort order is considered equal.

  Here the chosen comparison is to sort on fully qualified filenames,
  but with files before their equal-depth subdirectories.
  For example: "C:\z.txt" before "C:\a\z.txt".
*/

integer proc quicksort_compare(var integer line1, var integer line2)
  integer result                    = 0
  string  sort_key_1 [MAXSTRINGLEN] = ''
  string  sort_key_2 [MAXSTRINGLEN] = ''
  GotoLine(line1)
  sort_key_1 = get_sort_key_from_line()
  GotoLine(line2)
  sort_key_2 = get_sort_key_from_line()
  result = CmpiStr(sort_key_1, sort_key_2)
  return(result)
end quicksort_compare

integer proc are_similar_filenames(string filename1, string filename2)
  string  filename1_significant_part [MAXSTRINGLEN] = ''
  string  filename2_significant_part [MAXSTRINGLEN] = ''
  integer result                                    = FALSE
  filename1_significant_part = strip_suffix(filename1)
  filename2_significant_part = strip_suffix(filename2)
  result = EquiStr(filename1_significant_part, filename2_significant_part)
  return(result)
end are_similar_filenames

proc WhenLoaded()
  my_macro_name = SplitPath(CurrMacroFilename(), _NAME_)
end WhenLoaded

proc Main()
  string  curr_filename [MAXSTRINGLEN] = ''
  string  curr_sort_key [MAXSTRINGLEN] = ''
  integer group_line_from              = 0
  integer group_line_to                = 0
  integer i                            = 0
  integer identicals_yn                = 0
  integer identical_filenames_in_group = FALSE
  integer ok                           = TRUE
  string  prev_filename [MAXSTRINGLEN] = ''
  string  prev_sort_key [MAXSTRINGLEN] = ''
  integer similar_filenames_in_group   = FALSE
  identicals_yn = YesNo('Also report groups containing only identical filenames?')
  ok = (identicals_yn > 0)
  ok = ok and DirList_Main()
  if ok
    BegFile()
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    Message('Renaming report ... ')
    repeat
      i  = i + 1
      ok = ChangeCurrFilename(my_macro_name + Str(i) + '.txt',
                              _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
    until ok
       or i > 1000000
    if ok
      BegFile()
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      KeyPressed()
      Message('Ignoring inaccessible folders ... ')
      KeyPressed()
      if lFind(' <inaccessible folder>', '$')
        Delay(36)
        BegFile()
        while lFind(' <inaccessible folder>', '$')
          KillLine()
          Up()
        endwhile
      endif
      BegFile()
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      KeyPressed()
      Message('Ignoring it when files are inaccessible ... ')
      KeyPressed()
      if lFind(' <inaccessible file>', '$')
        Delay(36)
        lReplace(' <inaccessible file>', '', 'gn$')
      endif
      BegFile()
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      KeyPressed()
      Message('Deleting empty lines ... ')
      KeyPressed()
      // Not expecting one: Just to be sure.
      while lFind('^[ \d009]@$', 'gx')
        KillLine()
      endwhile
      BegFile()
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      KeyPressed()
      Message('Sorting files on their sort keys (using QuickSort) ... ')
      KeyPressed()
      if NumLines() > 1000
        Delay(36)
      endif
      ok = QuickSort(1, NumLines())
      if ok
        BegFile()
        UpdateDisplay(_ALL_WINDOWS_REFRESH_)
        KeyPressed()
        Message('Selecting groups of filenames that only differ in suffix ... ')
        KeyPressed()
        // This is the same as files having the same sort key.
        curr_sort_key = get_sort_key_from_line()
        if Down()
          repeat
            prev_sort_key = curr_sort_key
            curr_sort_key = get_sort_key_from_line()
            if are_similar_filenames(prev_sort_key, curr_sort_key)
              similar_filenames_in_group = similar_filenames_in_group + 1
            else
              if similar_filenames_in_group
                InsertLine('')
                Down()
              else
                Up()
                KillLine()
              endif
              similar_filenames_in_group = 0
            endif
          until not Down()
          if not similar_filenames_in_group
            KillLine()
          endif
        endif
        if identicals_yn <> 1
          BegFile()
          InsertLine('') // Necessary for loop.
          UpdateDisplay(_ALL_WINDOWS_REFRESH_)
          KeyPressed()
          Message('Ignoring groups containing only identical filenames ... ')
          KeyPressed()
          repeat
            prev_filename = curr_filename
            curr_filename = get_filename_from_line()
            if curr_filename == ''
              group_line_to = CurrLine()
              if identical_filenames_in_group
                MarkLine(group_line_from, group_line_to)
                KillBlock()
                Up()
              endif
            else
              if prev_filename == ''
                group_line_from = CurrLine()
                identical_filenames_in_group = TRUE
              elseif curr_filename <> prev_filename
                identical_filenames_in_group = FALSE
              endif
            endif
          until not Down()
        endif
      endif
      BegFile()
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      KeyPressed()
      Message('Done: OK.')
      KeyPressed()
      Alarm()
    else
      Warn('Could not rename intermediate folder list. Scan aborted.')
    endif
  endif
  PurgeMacro(my_macro_name)
end Main

