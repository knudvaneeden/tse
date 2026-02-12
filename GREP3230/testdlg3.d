
// dialog control MUST be first

dialog  0               1 10  5 65 15 "Test Dialog"

// include statements are most useful here

#include "testdlg3.si"
#include "dialog.si"

// now let's define some controls

ltext   id_text1        1  5  2 25  3 "&Combo Box"
combo   id_combo        1  5  3 22  9 "","Select a captial"
open    id_open1        1 22  3 25  4 ""
ltext   id_text2        1 30  2 50  3 "&List Box"
list    id_list         1 30  3 49  9 "","Select a country"
vscroll id_scroll       1 49  3 50  9 ""

// push buttons usually come at last

button  id_enable       1  5  8 14  9 "&Disable","Disable the lists"
defbtn  id_ok           1 17  8 25  9 "&Quit","Quit"

