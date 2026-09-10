//   GrepDlg.D
//   Dialog resource for Grep.S

dialog  0               1  9  3 71 16 "Grep"

#include "dialog.si"
#include "grepdlg.si"

// text field

ltext   0               1  2  1 20  2 "&Search for:"
edit    ID_EDT_EXPR     1 21  1 57 11 "","Enter string to search for."
open    0               1 58  1 60  2 ""

ltext   0               1  2  2 20  3 "&Files to search:"
edit    ID_EDT_FILES    1 21  2 57 12 "","Enter filenames to search (wildcards and paths can be used)."
open    0               1 58  2 60  3 ""

ltext   0               1  2  3 20  4 "Files to excl&ude:"
edit    ID_EDT_EXCL     1 21  3 57 13 "","Enter filenames to NOT search in (wildcards and paths can be used)."
open    0               1 58  3 60  4 ""

ltext   0               1  2  4 20  5 "Director&y:"
edit    ID_EDT_DIR      1 21  4 57 14 "","Enter directory in which to start the search."
open    0               1 58  4 60  5 ""

// option boxes

ltext   0               1  2  6 22  7 "Search Options"
check   ID_CHK_BACK     1  2  7 22  8 "&Backward","Search backwards through the file."
check   ID_CHK_CASE     1  2  8 22  9 "&Ignore Case","Ignore case; case insensitive."
check   ID_CHK_WORDS    1  2  9 22 10 "&Words Only","Whole word matches only."
check   ID_CHK_EXPR     1  2 10 22 11 "Reg. E&xpression","Search using regular expressions."
check   ID_CHK_BOL      1  2 11 22 12 "B&eg-Line","Anchors search string to beginning of line."
check   ID_CHK_EOL      1  2 12 22 13 "E&nd-Line","Anchors search string to end of line."

ltext   0               1 25  6 45  7 "Grep Options"
check   ID_CHK_MEM      1 25  7 45  8 "Files in &memory","Search loaded files."
check   ID_CHK_SUBDIRS  1 25  8 45  9 "Sub&directories","Search all subdirectories."
check   ID_CHK_FNAMES   1 25  9 45 10 "Fi&lenames only","Only list matching filenames, not each matching line."
check   ID_CHK_VERBOSE  1 25 10 45 11 "&Verbose","List each match as it is found (slows the search a little)."
check   ID_CHK_CTXWIN   1 25 11 45 12 "&Context window","Provides window that shows the matching line and its context in the file."

ltext   0               1 25 12 40 13 "Context Line&s:"
edit    ID_EDT_CTX      1 40 12 45 13 "","For each match, show this many lines of context in the output file."

// push buttons

defbtn  ID_OK           1 48  7 60  8 "O&k","Begin the search."
button  ID_CANCEL       1 48  9 60 10 "Cancel","Close this dialog without searching."
button  ID_HELP         1 48 11 60 12 "&Help","Display help."

