/*
  Macro           QuickSortTest
  Author          Carlo.Hogeveen@xs4all.nl
  Version         1.0
  Date            21 apr 2017
  Compatibility   TSE 4.0 upwards

  This macro assumes the current file solely consists of a list of fully
  qualified filenames (*), and sorts them on their fully qualified names
  with the exception that files are placed before same-depth subdirectories.
  For example: "c:\z.txt" before "c:\a\z.txt".

  (*) One way to create such a list is with the DirList macro on my website,
      and deleting the first line and the block text with file information.

  The purpose is to test the implementation of the QuickSort algorith,
  espeacially for worst-case scenarios.

  Test plan:
    Create a large list of fully qualified filenames, e.g. a list of all
    all files on all drives.
    Then with a conventional sort tool sort the list in some reverse order.
    Then open the list in TSE and run this macro.
    Optionally set QUICKSORT_DEBUG to TRUE to see runtime and stack usage.

  Test results:
    Given a 23 MB file containing 228 k lines of fully qualified filenames,
    sorted descendingly with TSE's sort menu, and then sorted with this
    macro with QUICKSORT_DEBUG set to TRUE (using TSE 4.0 on Windows 10),
    the debug warning at the end reports the following:

      Runtime                       = 66 (s)
      Max recurred depth            = 162
      MacroStackAvail at depth 1    = 61031
      MacroStackAvail at max depth  = 57811
      MacroStackAvail per recursion = 20

    Awesome!
*/



// Optional:
#define QUICKSORT_DEBUG TRUE



string proc get_text(integer line)
  string result [MAXSTRINGLEN] = ''
  GotoLine(line)
  if CurrLine() == line
    result = GetText(1, MAXSTRINGLEN)
  endif
  return(result)
end         get_text



/*
  The quicksort order for 2 lines is defined by this proc.

  The proc should return -1 if line1 should be before line2, 1 if line1
  should be after line2, and 0 if their sort order is considered equal.

  Here the chosen comparison is to sort on fully qualified filenames,
  but with files before their equal-depth subdirectories.
  For example: "C:\z.txt" before "C:\a\z.txt".
*/
integer proc quicksort_compare(integer line1, integer line2)
  integer result = 0
  string text1 [MAXSTRINGLEN] = get_text(line1)
  string text2 [MAXSTRINGLEN] = get_text(line2)
  if Lower(SplitPath(text1, _DRIVE_|_PATH_)) < Lower(SplitPath(text2, _DRIVE_|_PATH_))
    result = -1
  elseif Lower(SplitPath(text1, _DRIVE_|_PATH_)) > Lower(SplitPath(text2, _DRIVE_|_PATH_))
    result = 1
  elseif Lower(SplitPath(text1, _NAME_|_EXT_)) < Lower(SplitPath(text2, _NAME_|_EXT_))
    result = -1
  elseif Lower(SplitPath(text1, _NAME_|_EXT_)) > Lower(SplitPath(text2, _NAME_|_EXT_))
    result = 1
  endif
  return(result)
end quicksort_compare

#include ['QuickSort.inc']





proc Main()
  quicksort(1, NumLines())
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main
