===

1. -To install

     1. -Take the file quicksort_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallquicksort.bat

     4. -That will create a new file quicksort_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          quicksorttest.mac

2. -The .ini file is the local file 'quicksort.ini'
    (thus not using tse.ini)

===

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
