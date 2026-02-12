/***************************************************************************
2WINDOW.MAC
This macro sets up 2 windows, with the current file in the larger upper
window, and a lower smaller window in which it opens a 2nd file with the
same root name + extension "hil".  It then inserts an explanatory header in
the lower window stating the "hil" file contains 'hilites' from (filename
in upper window) and a current date stamp.  (If this "hil" file already
exists from a previous 'session', a new header and time stamp will simply
be appended at the end where you last left off.) It then returns you to the
top window, where you are now ready to start scrolling through the original
file, and where you can quickly pick out any lines of interest, with a
single keystroke, and continue scrolling.

The 'magic keystroke' is <Ctrl CenterCursor>:

which I find very handy since, (in the standard key configuration),
<Ctrl CursorUp/Down> is already used for scrolling up/down, and the
CenterCursor key is right in the middle of the up/down arrows (on the
numeric keypad).  This way, I rest my left 'pinkie' on the Ctrl key,
and very quickly scroll and 'hilite' with my right hand on the numeric
keypad. (Numlock Off)
I have also added a 2nd key assignment that allows the hilited line to
also be printed in addition to being copied to the lower window.  You will
probably want to set "Send FormFeed after printing..." (Esc O F P O) to "OFF"
if you make use of this feature.
Also added 'QuickHelp'  <AltShift F1>

FANCY ADDITION:  After 2WINDOW is set up, assign the three following
                 KEYBOARD Macros:  Numeric Keypad Keys: (Numlock Off):

                                          = Ctrl      //ie RollUp
                                          = Ctrl      //ie RollDown()
                                         CenterCursor = Ctrl CenterCursor

        Now save your keyboard macros (ESC M S) and name "2WINDOW".  Now you
        can load the keyboard macro "2WINDOW.KBD" (ESC M D) and you won't
        need to rest your left "pinkie" on the Left Ctrl key anymore!
        (It is handy if you have assigned the following in your UI file:
        <Alt GREYCursorUp>   ScrollUp()
        <Alt GREYCursorDown> ScrollDown()
        This helps to adjust the position of the current line up or down
        once you have assigned or loaded the 3 above keyboard macros.

TIP:    If you assign 'ExecMacro("RecordKeyMacro") to a key before
        recording any of your keymacros, you won't get the macro menu screen
        'bleed thru' flash that can become quite annoying to the eyes.
NOTE: The key assignments are at the bottom of this file, so you can easily
      change them to whatever you wish.  As well, you can easily adjust the
      preset sizes of the windows by simply adding or deleting some
      "PushKey(<CursorDown>) lines from the procedure below.  If you make
      any changes, be sure to recompile for them to take effect. (Ctrl F9)
      (You can do almost ANYTHING with "Tessie"...!  If you spend a little
      time with her, you will find her very willing and ABLE!!!)

2WINDOW.MAC
created by Rob Howse, Saskatoon, SK (Canada) Dec 14, 1994
***************************************************************************/

helpdef TwoWindowHelp
Title = "2 Window `Hilite Picker'  by Rob Howse, Saskatoon, SK"
x = 20
y = 3
"Copy Current Line to Window 2 (.hil file)   <Ctrl CenterCursor>"
"Copy Current Line to Window 2  + Print      <Ctrl Shift CenterCursor>"
"This `Reminder' help screen:                <Alt Shift F1>"
""
'Reminder: Set "FormFeed After Print" to OFF  ( ESC P O O )'
end

proc main()
        OneWindow()            //in case more than one open
        Hwindow()              //now open 2nd window
        pushkey(<enter>)
        pushkey(<cursordown>)  //and resize 2nd window smaller
        pushkey(<cursordown>)
        pushkey(<cursordown>)
        pushkey(<cursordown>)
        pushkey(<cursordown>)
        pushkey(<cursorup>)
        resizewindow()

//now open file in lower window with same name as file in upper window,
//but with extension "hil".  This is where we will copy anything of interest
//from the first file.
        EditFile(SplitPath(CurrFileName(), _NAME_) + ".hil")
        EndFile()  AddLine()  AddLine()  BegLine()
        InsertText("The following are 'hilites' from: ")
        GoToWindow(1)
        InsertText(CurrFileName(),_INSERT_)
        MarkChar()  BegLine()                    //get filename from top
        GoToWindow(2)  MoveBlock()               //window and place it
        EndLine()  UnMarkBlock()  Right()        //in lower window
        InsertText(" " + GetDateStr())           //along with date, as part
        AddLine()  BegLine()                     //of explanatory header.
        InsertText(GetTimeStr())
        GoToWindow(1)
        FileChanged(FALSE)
        UpDateDisplay()
        QuickHelp(TwoWindowHelp)
end

proc mHilite()
    MarkLine()  GoToWindow(2)  EndFile()  ScrollToRow(4) //hilites line and
    BegLine()  CopyBlock()  GoToWindow(1)  RollDown()    //copies to 'hilite'
end                                                     //file in lower window

proc mHiliteprint()
    MarkLine()  PrintBlock()  GoToWindow(2)  EndFile()  ScrollToRow(4)
    BegLine()  CopyBlock()  GoToWindow(1)  RollDown()   //same as above plus
end                                                     //also prints line

<Ctrl CenterCursor>       mHilite()
<CtrlShift CenterCursor>  mHilitePrint()
<AltShift F1>             QuickHelp(TwoWindowHelp)
