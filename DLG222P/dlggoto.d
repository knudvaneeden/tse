dialog  0               1 20  6 60 14 "Goto Line/Column"
#include "dlggoto.si"
#include "dialog.si"
ltext   0               1  5  2 13  3 "&Line"
edit    ID_EDT_LINE     1 15  2 33 10 ""
open    0               1 33  2 36  3 ""
ltext   0               1  5  4 13  5 "&Column"
edit    ID_EDT_COLUMN   1 15  4 33 12 ""
open    0               1 33  4 36  5 ""
group
defbtn  ID_OK           1  5  6 13  7 "O&k"
button  ID_CANCEL       1 16  6 24  7 "Cancel"
button  ID_HELP         1 27  6 35  7 "Help"
group
