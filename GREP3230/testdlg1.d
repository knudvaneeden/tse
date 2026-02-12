
// dialog control MUST be first

dialog  0               1 10  5 65 17 "Test Dialog"

// include statements are most useful here

#include "testdlg1.si"
#include "dialog.si"

// now let's define some controls

ltext   id_text1        1  5  2 25  3 "&Edit Control"
edit    id_edit1        1  5  3 22 11 "some extremely long and completely irrelevant example text"
open    id_hist1        1 22  3 25  4 ""

rtext   id_text03       0 30  2 50  3 "&Disabled"
check   id_check03      0 30  3 50  4 "Check box &0"

ltext   0               1  5  5 25  6 "&Radio Buttons"
group
radio   id_radio50      1  5  6 25  7 "Radio button &A"
radio   id_radio51      1  5  7 25  8 "Radio button &B"
radio   id_radio52      1  5  8 25  9 "Radio button &C"
group

ltext   0               1 30  5 50  6 "Chec&k boxes"
group
check   id_check60      1 30  6 50  7 "Check box &1"
check   id_check61      1 30  7 50  8 "Check box &2"
check   id_check62      1 30  8 50  9 "Check box &3"
group

// push buttons usually come at last

group
defbtn  id_btn_exec     1 10 10 20 11 "E&xec"
button  id_btn_test     1 25 10 35 11 "&Test"
button  id_cancel       1 40 10 50 11 "Cancel"
group

