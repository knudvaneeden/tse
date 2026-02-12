/*
  Include         QuickSort.inc
  Author          Carlo.Hogeveen@xs4all.nl
  Version         1.0
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
