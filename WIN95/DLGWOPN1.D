dialog  0               1 15  4 66 16 "Options"
#include "dlgwopn1.si"
#include "dialog.si"
ltext   0               1  4  2 28  3 "Display Format"
group
check   ID_CHK_NOINFO   1  4  3 28  4 "&Names only","Do not list additional file info (date, time and size)"
check   ID_CHK_NODIRS   1  4  4 28  5 "&Files only","Do not list folders"
group
ltext   0               1  4  6 28  7 "File Loading Options"
group
check   ID_CHK_BIN      1  4  7 28  8 "&Binary","Load file in binary mode"
check   ID_CHK_HEX      1  4  8 28  9 "&Hex Edit","Switch to hexadecimal display"
check   ID_CHK_CHDIR    1  4  9 28 10 "&Change Folder","Change directory after loading file"
check   ID_CHK_LDWILD   1  4 10 28 11 "&Load Wild","Load all files specified by wildcard"
group
group
defbtn  ID_OK           1 34  2 48  3 "O&k","Accept changes and close dialog"
button  ID_CANCEL       1 34  4 48  5 "Cancel","Abort dialog"
button  ID_BTN_DRIVES   1 34  6 48  7 "List Drives","Re-scan available drives"
button  ID_BTN_CURRDIR  1 34  8 48  9 "C&urr Dir","Return to current directory (also aborts dialog)"
button  ID_HELP         1 34 10 48 11 "Help","Help screen"
group
