/*
  ÚÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒ¿
  ³º Macro Title: BoxIt!                                                 º³
  ³º Version....: 0.11 for TSE 2.0                                       º³
  ³º Author.....: George J. De Bruin (SemWare)                           º³
  ÀĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÙ
*/

constant MaxColumn = 2032               // Current Maximum in TSE

integer GlobalGap = 0,                  // Gap between block and box
        TopGap = 0,
        BottomGap = 0,
        LeftGap = 0,
        RightGap = 0,
        BoxGlobal = TRUE,
        BoxTop = TRUE,                  // Draw Top Line? (True or false)
        BoxRight = TRUE,                // Draw Right Side? (T/f)
        BoxLeft = TRUE,                 // Draw Left Side? (T/f)
        BoxBottom = TRUE                // Draw Bottom Line? (T/f)

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
proc OptToggle( VAR integer opt)
    opt = iif( opt, FALSE, TRUE )
    return()
end OptToggle

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
proc NumRead( VAR integer n)
    string s[5] = str(n)

    n = iif(Read(s), val(s), n)
    return()
end NumRead

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
string proc StrOnOff(integer i)
    return (iif(i, "On", "Off"))
end StrOnOff

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
string proc StrBoxGlobal(integer i)
    string ret[3]
    if i < 3
        ret = StrOnOff(i)
    else
        ret = "Inv"
    endif
    return( ret )
end StrBoxGlobal

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
proc GotoRC(integer row, integer col)
    GotoLine( row )
    GotoColumn( col )
end GotoRC

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
proc VLine(integer row1, integer col1, integer row2)

    integer direct = iif( row1 > row2, _UP_, _DOWN_ ) // Set Line Drawing
                                                      // Direction
    GotoRC( row1, col1 )                // Goto Starting Row & Column
    while row2 <> CurrLine()            // Draw the line
        LineDraw(direct)
    endwhile
    LineDraw( iif( direct == _UP_, _DOWN_, _UP_ ) ) // Make sure there is
    LineDraw( iif( direct == _UP_, _DOWN_, _UP_ ) ) // a character in the
end Vline

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
proc Hline(integer row1, integer col1, integer col2)

    integer direct = iif( col1 > col2, _LEFT_, _RIGHT_ ) // Set Line Drawing
                                                         // Direction
    GotoRC( row1, col1 )                // Goto Starting Row & Column
    while col2 <> CurrCol()             // Draw the Line
        LineDraw(direct)
    endwhile
    LineDraw( iif( direct == _LEFT_, _RIGHT_, _LEFT_ ) ) // Make sure there is
    LineDraw( iif( direct == _LEFT_, _RIGHT_, _LEFT_ ) ) // a character in the
end Hline

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
proc SetAllGaps()
    NumRead(GlobalGap)                  // Get Global Gap Setting
    TopGap = GlobalGap                  // Assign Global Gap to each side
    BottomGap = GlobalGap
    RightGap = GlobalGap
    LeftGap = GlobalGap
    pushkey(<enter>)                    // Update the menu
end SetAllGaps

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
menu SideOnOff()
    history
    "&On",,CloseBefore
    "O&ff",,CloseBefore
    "&Invert",,CloseBefore
end SideOnOff

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
proc SetAllSides()
    SideOnOff()                         // Get Global Sides On / Off
    BoxGlobal = MenuOption()            // Which Option was selected?
    If BoxGlobal <> 3                   // If invert, don't do this
        BoxGlobal = iif(BoxGlobal - 2, TRUE, FALSE) // On or Off?
        BoxTop = BoxGlobal              // Assign value for each side
        BoxBottom = BoxGlobal
        BoxRight = BoxGlobal
        BoxLeft = BoxGlobal
    else
        BoxTop = not BoxTop             // Invert current values
        BoxBottom = not BoxBottom
        BoxRight = not BoxRight
        BoxLeft = not BoxLeft
    endif
    pushkey(<enter>)                    // Update the menu
end SetAllSides

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
proc BoxIt()
    integer ULC = 0,                    // Upper left column of block
            ULR = 0,                    // Upper left row of block
            LRC = 0,                    // Lower right column of block
            LRR = 0,                    // Lower right row of block
            InsLines = 0,
            Insrt = Set(Insert, On)     // Turn Insert Mode on and Save
                                        // Previous setting

    set(MsgLevel, _WARNINGS_ONLY_)      // Turn off display updates

    if isBlockInCurrFile() <> _COLUMN_  // Is there a column block in current
        message("No Column Block In File.") // buffer? If not, then return.
        return()
    endif

    if isCursorInBlock() <> _COLUMN_    // Is the cursor in the block?
        message("Cursor Not In Block.") // If not, then return.
        return()
    endif

    PushPosition()                      // Store Starting Location
    GotoBlockBegin()

    ULC = CurrCol()
    if (ULC - LeftGap <= 1) and (LeftGap >= 1) // If in first column, or left side
                                        // is past the first column, return.
        PopPosition()                   // Restore Starting position
        message("Cannot Insert Box At or Before Beginning of Line.")
        return()
    endif

    ULR = CurrLine()
    if (ULR == 1)                       // If first line of file,
        PushPosition()                  // insert enough lines to permit
        Begline()                       // drawing the box
        while InsLines < TopGap + 1
            SplitLine()
            InsLines = InsLines + 1
        endwhile
        PopPosition()
        ULR = CurrLine()
    endif

    GotoBlockEnd()

    LRC = CurrCol()
    if LRC == MaxColumn                 // If last column of buffer, return
        PopPosition()                   // Restore Starting position
        return()
    endif

    LRR = CurrLine()

    if BoxTop                           // If BoxTop == TRUE, Draw Line
        Hline( (ULR - (TopGap)), (ULC - (LeftGap)), (LRC + (RightGap)))
    endif

    if BoxRight                         // If BoxRight == TRUE, Draw Line
        VLine( (ULR - (TopGap)), (LRC + (RightGap)), (LRR + (BottomGap)))
    endif

    if BoxBottom                        // If BoxBottom == TRUE, Draw Line
        HLine( (LRR + (BottomGap)), (LRC + (RightGap)), (ULC - (LeftGap)))
    endif

    if BoxLeft                          // If BoxLeft == TRUE, Draw Line
        VLine( (LRR + (BottomGap)), (ULC - (LeftGap)), (ULR - (TopGap)))
    endif

    PopPosition()                       // Restore Starting position
    UnmarkBlock()                       // Get rid of block
    Set(Insert, Insrt)                  // Restore Initial Insert Value
    ScrollToRow(Query(WindowRows)/2)
    return()                            // Exit -- ALL DONE!
end BoxIt

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
menu BoxItAbout()

    "      BoxIt! 0.11", , dontclose, "See Documentation for details."
    "      For TSE 2.0 ", , skip
    "    Released: 11/23/94", , skip
    "", , divide
    "Author: George J. De Bruin", , dontclose, "See Documentation for details."

end BoxItAbout

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
menu BoxSides()
    History

    "&Global" [StrBoxGlobal(BoxGlobal):4],
        SetAllSides(),
        CloseAfter,
        "Set all sides On or Off."

    "",,divide

    "&Top"    [StrOnOff(BoxTop):3],
        OptToggle(BoxTop),
        DontClose,
        "Toggle Top side On or Off."

    "&Bottom" [StrOnOff(BoxBottom):3],
        OptToggle(BoxBottom),
        DontClose,
        "Toggle Bottom side On or Off."

    "&Left"   [StrOnOff(BoxLeft):3],
        OptToggle(BoxLeft),
        DontClose,
        "Toggle Left side On or Off."

    "&Right"  [StrOnOff(BoxRight):3],
        OptToggle(BoxRight),
        DontClose,
        "Toggle Right side On or Off."

end BoxSides

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
menu BoxGaps()
    History

    "&Global"  [GlobalGap:5],
        SetAllGaps(),
        CloseAfter,
        "Set Gap for all sides of box."

    "",,divide

    "&Top"     [TopGap:5],
        NumRead(TopGap),
        DontClose,
        "Set gap between top of block and top of box."

    "&Bottom"  [BottomGap:5],
        NumRead(BottomGap),
        DontClose,
        "Set gap between bottom of block and bottom of box."

    "&Left"    [LeftGap:5],
        NumRead(LeftGap),
        DontClose,
        "Set gap between left side of block and left side of box."

    "&Right"   [RightGap:5],
        NumRead(RightGap),
        DontClose,
        "Set gap between right side of block and right side of box."

end BoxGaps

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
menu BoxItMnu()
    "&BoxIt!    ", BoxIt(), CloseAllBefore, "Draw box NOW!"
end BoxItMnu

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
menu BoxLine()
    "&Line Type ", LineTypeMenu(), dontclose, "Select Line Type."
end BoxLine

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
menubar BoxItMnuBar()
    History

    "ğ", BoxItAbout()
    "&BoxIt!", BoxItMnu()
    "&Side Toggles", BoxSides()
    "&Gap Settings", BoxGaps()
    "&Line Type", BoxLine()
end BoxItMnuBar

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Main Keys
   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
<F12>           BoxIt()                             // Execute BoxIt!
<Alt F12>       BoxItMnuBar()                       // Menu Bar

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Quick Two-Keys
   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
<Ctrl G><G>   PushKey(<G>) PushKey(<G>) BoxItMnuBar()   // Set Global Gap
<Ctrl G><T>   PushKey(<T>) PushKey(<G>) BoxItMnuBar()   // Set Top Gap
<Ctrl G><B>   PushKey(<B>) PushKey(<G>) BoxItMnuBar()   // Set Bottom Gap
<Ctrl G><L>   PushKey(<L>) PushKey(<G>) BoxItMnuBar()   // Set Left Gap
<Ctrl G><R>   PushKey(<R>) PushKey(<G>) BoxItMnuBar()   // Set RightGap

<Ctrl S><G>   PushKey(<G>) PushKey(<S>) BoxItMnuBar()   // Side Global Setting
<Ctrl S><T>   PushKey(<T>) PushKey(<S>) BoxItMnuBar()   // Side Top Toggle
<Ctrl S><B>   PushKey(<B>) PushKey(<S>) BoxItMnuBar()   // Side Bottom Toggle
<Ctrl S><L>   PushKey(<L>) PushKey(<S>) BoxItMnuBar()   // Side Left Toggle
<Ctrl S><R>   PushKey(<R>) PushKey(<S>) BoxItMnuBar()   // Side Right Toggle
