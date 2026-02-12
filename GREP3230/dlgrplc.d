dialog  0               1  5  4 76 21 "Replace Text"
#include "dlgrplc.si"
#include "dialog.si"
ltext   0               1  5  2 50  3 "&Search For"
edit    ID_EDT_FIND     1  5  3 47 12 ""
open    0               1 47  3 50  4 ""
ltext   0               1  5  5 50  6 "&Replace With"
edit    ID_EDT_RPLC     1  5  6 47 15 ""
open    0               1 47  6 50  7 ""
ltext   0               1  5  8 25  9 "Scope"
group
check   ID_CHK_ALL      1  5  9 25 10 "&All Files"
check   ID_CHK_GLOBAL   1  5 10 25 11 "&Global"
check   ID_CHK_LOCAL    1  5 11 25 12 "&Local (Block)"
check   ID_CHK_CURR     1  5 12 25 13 "&Current Line"
group
group
check   ID_CHK_BOL      1  5 14 25 15 "B&eg-Line"
check   ID_CHK_EOL      1  5 15 25 16 "En&d-Line"
group
ltext   0               1 30  8 50  9 "Direction"
check   ID_CHK_BACK     1 30  9 50 10 "&Backward"
ltext   0               1 30 11 50 12 "Options"
group
check   ID_CHK_PRMT     1 30 12 50 13 "Do&nt Prompt"
check   ID_CHK_CASE     1 30 13 50 14 "&Ignore Case"
check   ID_CHK_WORDS    1 30 14 50 15 "&Words Only"
check   ID_CHK_EXPR     1 30 15 50 16 "Reg. E&xpression"
group
group
defbtn  ID_OK           1 55  3 67  4 "O&k"
button  ID_CANCEL       1 55  5 67  6 "Cancel"
button  ID_BTN_OPTS     1 55  7 67  8 "&Options"
button  ID_BTN_ASCII    1 55  9 67 10 "AsciiChar&t"
button  ID_BTN_XHELP    1 55 11 67 12 "RegEx &Help"
button  ID_HELP         1 55 13 67 14 "Help"
group
