dialog  0               1  5  4 76 20 "Find And Do"
#include "dlgfnddo.si"
#include "dialog.si"
ltext   0               1  5  2 50  3 "&Search For"
edit    ID_EDT_FIND     1  5  3 47 13 ""
open    0               1 47  3 50  4 ""
ltext   0               1  5  5 25  6 "Actions"
group
radio   ID_RAD_COUNT    1  5  6 25  7 "Count Onl&y"
radio   ID_RAD_DELETE   1  5  7 25  8 "&Delete Line"
radio   ID_RAD_CUT      1  5  8 25  9 "C&ut Append"
radio   ID_RAD_COPY     1  5  9 25 10 "&Copy Append"
group
check   ID_CHK_NUM      1  5 14 25 15 "Lin&e Numbers"
ltext   0               1 30  5 50  6 "Scope"
group
check   ID_CHK_ALL      1 30  6 50  7 "&All Files"
check   ID_CHK_GLOBAL   1 30  7 50  8 "&Global"
check   ID_CHK_LOCAL    1 30  8 50  9 "&Local (Block)"
group
ltext   0               1 30 10 50 11 "Options"
group
check   ID_CHK_PRMPT    1 30 11 50 12 "Do&nt Prompt"
check   ID_CHK_CASE     1 30 12 50 13 "&Ignore Case"
check   ID_CHK_WORDS    1 30 13 50 14 "&Words Only"
check   ID_CHK_EXPR     1 30 14 50 15 "Reg. E&xpression"
group
group
defbtn  ID_OK           1 55  2 67  3 "O&k"
button  ID_CANCEL       1 55  4 67  5 "Cancel"
button  ID_BTN_OPTS     1 55  6 67  7 "&Options"
button  ID_BTN_ASCII    1 55  8 67  9 "AsciiChar&t"
button  ID_BTN_XHELP    1 55 10 67 11 "RegEx &Help"
button  ID_HELP         1 55 12 67 13 "Help"
group
ltext   0               1  5 13 17 14 "Extras"
