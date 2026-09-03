/*  COMPARE.S - Macro to compare the first 255 characters of
    lines in two files and highlight the lines that are different
    between them.  Allows the slave file to be changed by the
    user.

    M. W. Hulse, v.1.4, April 4, 1993

    v.1.4   Find differences that are off the screen. Allow roll
            left/right in lock step.  Depart master on file
            <Escape>.

    v.1.3   Fixed <Escape> while looping.  Enabled linked
            horizontal roll.  Cleaned up messages.

    v.1.2   Made finding line differences automatic; ie. files
            roll up or down continuously until a difference is
            found.  Thanks to Ray Asbury for the suggestion.

    Setup: Set the NoCompare color attribute as you wish it.

    Use:  Open the slave file with TSE.  Execute the macro.
    Respond to the prompt with the name of the master file. Color
    attribute will change if there is a difference between the
    master and slave file cursor lines.  Cursor column stays
    where you put it.

    Adjust the cursor line in the master file for differences on
    line spacing with the alt cursor keys.

    Special key assignments:
        <Ctrl Grey Cursor Up>         Find diff between two files vertically
        <Ctrl Grey Cursor Down>                  "
        <Alt Grey Cursor Right>       Move the two files in sync horizontally
        <Alt Grey Cursor Left>                   "
        <Alt Grey Cursor Up>          Move the master file only
        <Alt Grey Cursor Down>                   "
        <Escape>                      Quit

    All other keys affect the slave file only.

*/
INTEGER SWindow,
        MWindow,
        NoCompare = Color(Bright White on Red)  // Set your color scheme

STRING  MLine[255] = "",                    // To hold 1st 255 char of Master
        SLine[255] = ""                     //              "          Slave

PROC Msg()
    Message("L ", CurrLine(), " C ", CurrCol(), " Press <Esc> to exit...")
END

STRING PROC GetALine()                      // Get 1st 255 characters of line
    Return(Gettext(1,255))
END

INTEGER PROC FindDiff()

INTEGER i = length(MLine),
        j = length(SLine),
        k,
        l = 0

    k = iIF(i > j, i,j)                         // find longest line

    Repeat                                      // find start of discrepancy
        l = l + 1
    Until (SubStr(MLine, l, 1) <> SubStr(SLine, l, 1)) // compare lines
    Return(l)
END

PROC Paintit()

INTEGER l = FindDiff()

    Integer m

    If l >= Query(WindowCols)               // handle differences off to the right
        GotoColumn(l + (Query(WindowCols) / 2)) // get into the right context
        GotoColumn(l + 3)                   // put the cursor there
        GotoWindow(MWindow)                 // same for the master window
        GotoColumn(l + (Query(WindowCols) / 2))
        GotoColumn(l + 3)
        l = (Query(WindowCols) / 2) + 4         // set the beginning of highlight
        m = l - 2                               // and the end
    Else                                        // when in left margin window
        GotoColumn(l)                           // put cursor there
        GotoWindow(MWindow)                     // same for the master window
        GotoColumn(l)
        m = l - 1                               // and the end
        l = l + 1                               // set the beginning of highlight
    EndIf

        GotoWindow(SWindow)                     // Get in slave window
        UpdateDisplay()                         // clean up
        VGotoXY((l), (WhereY()))                // Got to Window line beginning
        PutAttr(NoCompare, Query(WindowCols) - m) // color line
        Msg()                                   // reminds user
END

PROC _CompareLines(INTEGER Direction)            // Compares lines in files and
    INTEGER i,
    Done = FALSE                                // paints those that are different

    Loop
        If Direction                            // Roll both lines down and get
            If RollDown()
                SLine = GetALine()              // ...1st 255 char. of line in
                GotoWindow(MWindow)
                If RollDown()
                    MLine = GetALine()          // ...each file
                Else
                    Done = TRUE
                EndIf
                GotoWindow(SWindow)
            Else
                Done = TRUE
            EndIf
        Else                                    // same for going up
            If RollUp()                         // roll up in Slave Window
                SLine = GetALine()              // call user PROC to get line data
                GotoWindow(MWindow)             // change windows
                If RollUp()                     // roll up in Master Window
                    MLine = GetALine()
                Else
                    Done = TRUE
                EndIf
                GotoWindow(SWindow)             // change windows back
            Else
                Done = TRUE
            EndIf
        EndIf
        Message("L ", CurrLine(), " C ", CurrCol())
        If SLine <> MLine                       // if lines in the 2 files different
            PaintIt()
            Break
        Else                                // next command reminds user
            Msg()                           // remind user
        EndIf
        If Done == TRUE
            Break
        EndIf

        If (KeyPressed() AND GetKey() == <Escape>)
            EndProcess()                    // get out while rolling
        EndIf
    EndLoop
END

KEYDEF CKeys                                // special keys for this app
    <Ctrl CursorUp>         _CompareLines(0) // call PROC. 0 = UP
    <Ctrl CursorDown>       _CompareLines(1) //     "      1 = Down

    <Alt GreyCursorRight>   RollRight(4) GotoWindow(MWindow) RollRight(4) GotoWindow(SWindow)
    <Alt GreyCursorLeft>    RollLeft(4)  GotoWindow(MWindow) RollLeft(4)  GotoWindow(SWindow)

// next 2 commands move in master
    <Alt GreyCursorUp>      GotoWindow(MWindow) RollUp() GotoWindow(SWindow)
    <Alt GreyCursorDown>    GotoWindow(MWindow) RollDown() GotoWindow(SWindow)
    <Escape>                EndProcess()    // Done
END

PROC mCompare()

    Set(Break, On)                          // debug only
    SWindow = WindowID()                    // get current (slave) window id
    Message("Enter master filename...")
    HWindow()                               // ask user to load master file
    EditFile()                              // ...into a window
    UpdateDisplay(_STATUSLINE_REFRESH_)
    MWindow = WindowID()                    // get that window ID
    GotoWindow(SWindow)                     // go to slave window

    Enable(CKeys)                           // Make special keys effective
    Process()                               // and act on them
    Disable(CKeys)                          // quit when done
    GotoWindow(MWindow)
    AbandonFile()                           // Leave the master file
    CloseWindow()
    UpdateDisplay(_All_Windows_Refresh_)    // cleanup display
    Message("Exited Compare...")
END

<Alt Q><C> mCompare()
