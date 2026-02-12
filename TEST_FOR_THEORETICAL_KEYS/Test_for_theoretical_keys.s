/*
  Macro           Test_for_theoretical_keys
  Author          Carlo.Hogeveen@xs4all.nl
  Compatibility   TSE Pro v4.0 upwards
  Version         1.0

  This macro lists keys that THEORETICALLY can be understood by TSE.
  The rub is that your keyboard cannot produce all of these keys,
  and that your OS does not pass all of them on to TSE.

  Just compile and execute the macro: It creates a new file.

  TSE's own Sort crahses TSE when sorting results,
  so I am using my own QuickSort instead.
*/

#define MAX_KEY_CODE            65535

#define QUICKSORT_WHOLE_LINES       1
#define QUICKSORT_MAIN_KEYNAME_PART 2

integer quicksort_type = 0

integer proc quicksort_compare(var integer line1, var integer line2)
  integer p                 = 0
  integer result            = 0
  string  s1 [MAXSTRINGLEN] = ''
  string  s2 [MAXSTRINGLEN] = ''
  GotoLine(line1)
  s1 = GetText(1, MAXSTRINGLEN)
  GotoLine(line2)
  s2 = GetText(1, MAXSTRINGLEN)
  if quicksort_type == QUICKSORT_MAIN_KEYNAME_PART
    // Sort on the second token, subsort on the whole string.

    /*
    Cannot use GetToken() here: It makes QuickSort run out of macro stackspace.
    s1 = GetToken(s1, ' ', 2) + ' ' + s1
    s1 = GetToken(s2, ' ', 2) + ' ' + s2
    */

    p = Pos(' ', s1)
    if p
      s1 = SubStr(s1, p + 1, MAXSTRINGLEN) + s1
    endif
    p = Pos(' ', s2)
    if p
      s2 = SubStr(s2, p + 1, MAXSTRINGLEN) + s2
    endif
  endif
  if     s1 > s2
    result = 1
  elseif s1 < s2
    result = -1
  endif
  return(result)
end quicksort_compare



// Start of QuickSort code.

/*
  Include         QuickSort.inc
  Author          Carlo.Hogeveen@xs4all.nl
  Version         1.0.1
  Date            21 apr 2017
  Compatibility   TSE 4.0 upwards



  This is not a macro but an include file for a macro!

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

  - This file needs to be installed in TSE's macro directory.

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



  KNOWN PROBLEMS

  - Ironically, (this implementation of ?) QuickSort is surprisingly slow for
    sorting (very) large files. I have ideas on how to remediate that, but I am
    not going to until I encounter a case where speed matters that much in
    practice.

  - When doing some heavy testing with sorting a whole disk of filenames,
    the macro sometimes aborted with
      "Stack overflow in macro interpreter"
    and once with
      "Menu too large".
    Just restarting TSE and rerunning the macro solved the problem.
    Debugging revealed that in that specific test-case the macro itself uses
    only about half of the available macro stack size, and the only menu used
    in the calling program was already closed, so I doubt the error messages.
    So far I have not been able to reproduceably pin the cause down: It might
    or might not have to do with minimizing and maximizing TSE or switching
    between applications during the sort.



  HISTORY

  v1.0    - 21 Apr 2019
    Initial release.

  v1.0.1  - 23 Mar 2020
    Documented two known problems.

*/

#ifndef QUICKSORT_DEBUG
  #define QUICKSORT_DEBUG FALSE
#endif

#if QUICKSORT_DEBUG
  integer quicksort_recur_depth       = 0
  integer quicksort_recur_depth_1_MSA = 0
  integer quicksort_recur_depth_m     = 0
  integer quicksort_recur_depth_m_MSA = 0
  integer quicksort_start_time        = 0
#endif

proc quicksort_order(var integer current_line, var integer pivot_line)
  if                    current_line < pivot_line
  and quicksort_compare(current_line , pivot_line) == 1
    MarkLine(current_line, current_line)
    Cut()
    current_line = current_line - 1
    pivot_line   = pivot_line   - 1
    GotoLine(pivot_line)
    Set(InsertLineBlocksAbove, OFF)
    Paste()
  elseif                   current_line > pivot_line
  and    quicksort_compare(current_line , pivot_line) == -1
    MarkLine(current_line, current_line)
    Cut()
    GotoLine(pivot_line)
    Set(InsertLineBlocksAbove, ON)
    Paste()
    pivot_line = pivot_line + 1
  endif
end quicksort_order

integer proc quicksort_partition(var integer line_from, var integer line_to)
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

integer quicksort_ok = TRUE

proc quicksort_macro_stack_warning()
  if quicksort_ok
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    Warn('File only partially sorted because of a lack of macro stack space.')
    quicksort_ok = FALSE
  endif
end quicksort_macro_stack_warning

/*
  A global quicksort_pivot_line is used to reduce the stack size for the only
  recursing procedure.
  Note that the debugging code unavoidably adds to the recursion stack size
  it should measure. The not debugged code will do better.
*/
integer quicksort_pivot_line = 0
proc quicksort_body(integer line_from, integer line_to)
  #if QUICKSORT_DEBUG
    quicksort_recur_depth = quicksort_recur_depth + 1
    if quicksort_recur_depth == 1
      quicksort_recur_depth_1_MSA = MacroStackAvail()
    elseif quicksort_recur_depth > quicksort_recur_depth_m
      quicksort_recur_depth_m = quicksort_recur_depth
      quicksort_recur_depth_m_MSA = MacroStackAvail()
    endif
  #endif

  if MacroStackAvail() < 5000
    quicksort_macro_stack_warning()
  else
    if line_from < line_to
      quicksort_pivot_line = quicksort_partition(line_from, line_to)
      quicksort_body(line_from, quicksort_pivot_line - 1)
      quicksort_body(quicksort_pivot_line + 1, line_to)
    endif
  endif

  #if QUICKSORT_DEBUG
    quicksort_recur_depth = quicksort_recur_depth - 1
  #endif
end quicksort_body

integer proc quicksort(integer line_from, integer line_to)
  integer old_UndoMode = UndoMode(OFF)
  integer old_InsertLineBlocksAbove = Query(InsertLineBlocksAbove)
  integer old_UnMarkAfterPaste      = Set(UnMarkAfterPaste, ON)

  #if QUICKSORT_DEBUG
    quicksort_start_time = GetClockTicks()
  #endif

  PushBlock()
  PushPosition()
  quicksort_ok = TRUE
  quicksort_body(line_from, line_to)
  PopPosition()
  PopBlock()

  #if QUICKSORT_DEBUG
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    Warn('Runtime                       = ', ( GetClockTicks()
                                             - quicksort_start_time) / 18,
                                             ' (s)', Chr(13),
         'Max recurred depth            = ', quicksort_recur_depth_m, Chr(13),
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

// End of QuickSort code.

proc Main()
  integer duplicate_lines      = 0
  integer theoretical_key_code = 0
  integer real_key_code        = 0
  string  s [MAXSTRINGLEN]     = ''

  NewFile()

  for theoretical_key_code = 0 to MAX_KEY_CODE
    KeyPressed()
    Message('Testing for theoretical keys'; theoretical_key_code * 100 / 65535, '%')
    KeyPressed()
    PushKey(theoretical_key_code)
    real_key_code = GetKey()
    AddLine(KeyName(real_key_code))
  endfor

  Alarm()
  KeyPressed()
  Message('Sorting theoretical keys ...')
  KeyPressed()
  quicksort_type = QUICKSORT_WHOLE_LINES
  QuickSort(1, NumLines())

  Alarm()
  KeyPressed()
  Message('Removing duplicate keys ... ')
  Delay(36)
  KeyPressed()
  BegFile()
  repeat
    KeyPressed()
    Message('Removing duplicate keys ... ',
            (CurrLine() + duplicate_lines) * 100 / MAX_KEY_CODE,
            '% ...')
    KeyPressed()
    s = GetText(1, MAXSTRINGLEN)
    PushLocation()
    if Down()
      while GetText(1, MAXSTRINGLEN) == s
        KillLine()
        duplicate_lines = duplicate_lines + 1
      endwhile
    endif
    PopLocation()
  until not Down()
  KeyPressed()
  Message('Removed'; duplicate_lines; 'duplicate keys.')
  KeyPressed()
  Delay(36)

  Alarm()
  KeyPressed()
  Message('Sorting theoretical keys on their main name part ...')
  KeyPressed()
  quicksort_type = QUICKSORT_MAIN_KEYNAME_PART
  QuickSort(1, NumLines())

  BegFile()
  Alarm()
  KeyPressed()
  Message('Ready')
  KeyPressed()

  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

