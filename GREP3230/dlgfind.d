dialog  0               1  5  4 76 19 "Find Text"
#include "dlgfind.si"
#include "dialog.si"
ltext   0               1  5  2 50  3 "&Search For"
edit    ID_EDT_FIND     1  5  3 47 13 ""
open    0               1 47  3 50  4 ""
ltext   0               1  5  5 25  6 "Scope"
group
check   ID_CHK_ALL      1  5  6 25  7 "&All Files"
check   ID_CHK_GLOBAL   1  5  7 25  8 "&Global"
check   ID_CHK_LOCAL    1  5  8 25  9 "&Local (Block)"
check   ID_CHK_CURR     1  5  9 25 10 "&Current Line"
group
group
check   ID_CHK_BOL      1  5 11 25 12 "B&eg-Line"
check   ID_CHK_EOL      1  5 12 25 13 "En&d-Line"
group
ltext   0               1 30  5 50  6 "Direction"
check   ID_CHK_BACK     1 30  6 50  7 "&Backward"
ltext   0               1 30  8 50  9 "Options"
group
check   ID_CHK_VIEW     1 30  9 50 10 "&View Result"
check   ID_CHK_CASE     1 30 10 50 11 "&Ignore Case"
check   ID_CHK_WORDS    1 30 11 50 12 "&Words Only"
check   ID_CHK_EXPR     1 30 12 50 13 "Reg. E&xpression"
group
group
defbtn  ID_OK           1 55  2 67  3 "O&k"
button  ID_CANCEL       1 55  4 67  5 "Cancel"
button  ID_BTN_OPTS     1 55  6 67  7 "&Options"
button  ID_BTN_ASCII    1 55  8 67  9 "AsciiChar&t"
button  ID_BTN_XHELP    1 55 10 67 11 "RegEx &Help"
button  ID_HELP         1 55 12 67 13 "Help"
group
