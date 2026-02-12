
// dialog control MUST be first

dialog  0               1 20 10 51 22 "Test Dialog"

// include statements are most useful here

#include "testdlg2.si"
#include "dialog.si"

// now let's define some controls

control id_text         1  8  2 24  3 "","Scroller for hex digits"
hscroll id_scroll       1  8  3 24  4 ""
frame   0               1  4  5 28  9 "&Alarm"
control id_click        1  5  6 27  8 "","A user defined click panel"

// push buttons usually come at last

defbtn  id_beep         1  5 10 14 11 "&Beep","Pop up a message box"
button  id_cancel       1 18 10 27 11 "&Close","Quit the example"

