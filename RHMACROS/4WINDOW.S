/**************************************************************************
4WINDOW.MAC
This macro sets up 4 windows, with the current file in the larger upper
window, plus 3 smaller windows below.  In these windows, it opens additional
files with the same root name + extensions "1", "2" and "3". (If these files
already exist from a previous 'session', anything new will be appended at
the end where you last left off.) The files can be renamed any time to
whatever might be more meaningful for the particular situation. You are
then returned to the top window (1), where you are now ready to start
scrolling through the original file, and where you can quickly pick out any
lines of interest, 'sorting' them to windows 2, 3 or 4 as you continue to
scroll.  Plus <CtrlShift CenterCursor> simply prints the line.  (I have this
permanently set in my UI file.)

WHEN WOULD I USE THIS SETUP???
Example:  I download a FileList from a 'BBS' and want to sort thru it
        picking out interesting sounding GAMES to one window,  UTILITIES
        to a second window and MISCellaneous items of interest to the
        third window.
Another:  I download mail from the "Buy & Sell" area, and sort 'POOTER
        items to one window, 'WHEELS for sale to another window, and
        OTHER DEALS too good to pass up to the third window.  (You get
        the idea...)
Key Assignments:

<Ctrl  CenterCursor>     Copy current line to Window 2
<      CenterCursor>     Copy current line to Window 3
<Shift CenterCursor>     Copy current line to Window 4
<CtrlShift CenterCursor> PrintLine
<AltShift F1>            QuickHelp

NOTE: The key assignments are at the bottom of this file, so if you find
      this arrangement too 'tricky' for you, you can easily change them to
      whatever you wish.  As well, you can easily adjust the sizes of the
      windows by simply adding or deleting some "PushKey(<CursorDown>)
      lines from the procedure below.  If you make any changes, be sure to
      recompile for them to take effect. (Ctrl F9) (You can do almost
      ANYTHING with "Tessie"...!  If you spend a little time with her, you
      will find her very willing and ABLE!!!)

4WINDOW.MAC
created by Rob Howse, Saskatoon, SK (Canada) Dec 14, 1994
***************************************************************************/

helpdef FourWindowHelp
Title = "HiLite Line & Copy (Sort) to Window 1-3"
x = 25
y = 3
"Copy Current Line to Window 2:            <Ctrl CenterCursor>"
"Copy Current Line to Window 3:            <CenterCursor>     "
"Copy Current Line to Window 4:            <Shift CenterCursor>"
"Simply Print Line                         <Ctrl Shift CenterCursor>"
"This help screen:                         <Alt Shift F1>"
""
'Reminder: Set "FormFeed After Print" to OFF  (ESC P O O)'
end

proc main()
        OneWindow()
        HWindow()            //open window 2
        EditFile(SplitPath(CurrFileName(), _NAME_) + ".1")
        Pushkey(<enter>)
        Pushkey(<cursorup>)
        Pushkey(<cursorup>)
        Pushkey(<cursorup>)
        Pushkey(<cursorup>)
        ResizeWindow() AddLine()
        HWindow()            //open window 3
        EditFile(SplitPath(CurrFileName(), _NAME_) + ".2")
        Pushkey(<enter>)
        Pushkey(<cursorup>)
        Pushkey(<cursorup>)
        Pushkey(<cursorup>)
        Pushkey(<cursorup>)
        Pushkey(<cursorup>)
        ResizeWindow() AddLine()
        HWindow()            //open window 4
        EditFile(SplitPath(CurrFileName(), _NAME_) + ".3")
        Pushkey(<enter>)
        Pushkey(<cursorup>)
        Pushkey(<cursorup>)
        ResizeWindow() AddLine()
        GoToWindow(1)
        UpDateDisplay()
        QuickHelp(FourWindowHelp)
end

proc mHilite1()
    MarkLine()  GoToWindow(2)  EndFile()  ScrollToRow(3) //hilites line and
    BegLine()  CopyBlock()  GoToWindow(1)  RollDown()    //copies to file
end                                                      //in window 2

proc mHilite2()
    MarkLine()  GoToWindow(3)  EndFile()  ScrollToRow(3) //hilites line and
    BegLine()  CopyBlock()  GoToWindow(1)  RollDown()    //copies to file
end                                                      //in window 3

proc mHilite3()
    MarkLine()  GoToWindow(4)  EndFile()  ScrollToRow(3) //hilites line and
    BegLine()  CopyBlock()  GoToWindow(1)  RollDown()    //copies to file
end                                                      //in window 4

proc mMarkLinePrint()
    MarkLine()  PrintBlock()  UnMarkBlock()  RollDown()
end

<Ctrl  CenterCursor>     mHilite1()
<      CenterCursor>     mHilite2()
<Shift CenterCursor>     mHilite3()
<CtrlShift CenterCursor> mMarkLinePrint()
<AltShift F1>            QuickHelp(FourWindowHelp)

