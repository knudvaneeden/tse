dialog  0               1  5  4 76 20 ""
#include "dlghist2.si"
#include "dialog.si"
ltext   0               1  5  2 50  3 "&History Entries"
list    ID_LST2_ITEMS   1  5  3 50 14 ""
vscroll 0               1 50  3 51 14 ""
hscroll 0               1  5 14 50 15 ""
scredge 0               1 50 14 51 15 ""
group
defbtn  ID_CANCEL       1 55  3 67  4 "Cancel"
button  ID_BTN2_DEL     1 55  5 67  6 "&Delete"
button  ID_BTN2_ALL     1 55  7 67  8 "Delete &All"
button  ID_HELP         1 55  9 67 10 "Help"
group
