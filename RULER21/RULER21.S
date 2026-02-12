/*  mRuler. Orriginally by Peter Birch, March 17, 1993

    I often could use an on-screen ruler, this macro will give a
    virtual ruler on the line below the current cursor line.

    I give this to SemWare and everyone else that finds it of any value.

    Changed by Ray Asbury and M. W. Hulse. Version: 2.0, March 26, 1993

    Checked with TSE V2.0, October 16, 1994 Named versio 2.1

    Features:
        þ   Places ruler under line of interest.
        þ   Works when screen is horizontally scrolled.
        þ   Supports offset starting column.
        þ   Default offset column is cursor column.
        þ   User can shift screen while retaining ruler by
            cursoring, tabbing, rolling, and Home/End.
        þ   Allows user configured ruler attribute.
        þ   Ruler margin shows text.

    Set variable RuleAttr to desired ruler color. Set KeyDef to
    desired keys.

    Call with mRuler(n) where:
        n = TRUE    - Use offset
        n = FALSE   - Start at right column

    To use offset ruler, put cursor on the column where you want
    to start ruler.  Press key bound to mRuler(TRUE). Status line
    column is the default at the prompt.  Enter another column if
    desired.

    To erase ruler, cursor down to it.

*/
Integer ofs

PROC DrawRuler()

    INTEGER i,
            j = Query(WindowCols),
            k = CurrXOffSet() + 1,
            l = ofs,
            nRow = CurrRow() + Query(Windowy1),
            RuleAttr = Color(Bright White ON Blue)  // set desired rule colors

    If l >= CurrXOffset()               // ruler index for right scroll
        k =  1                          // offset as big or bigger than scroll
    Else
        k =  k - l                      // offset less than scroll
    EndIf

    l = l - CurrXOffset()               // ruler start for right scroll
    l = iIf(l < 0, 0, l)                // set ruler indent amount

    ClrScr()                            // clean up old rullers
    UpdateDisplay(_All_Windows_Refresh_)
    VGotoXY(Query(Windowx1) + l, nRow)  // goto ruler Line

    i = l + 1                           // set up drawing incrementing var
    WHILE (i <= j)                      // draw ruler
        IF (k MOD 10 == 0)              // write tens number
            Write(SubStr(Format(k:4:'0'), 3, 1))
        ELSEIF (k MOD 5 == 0)           // write 5's mark
            Write("Å")
        ELSE                            // write 1's mark
            Write("Â")
        ENDIF
        i = i + 1                       // increment writing position
        k = k + 1                       // increment ruler index
    ENDWHILE

    VGotoXY(Query(Windowx1) + l, nRow)  // goto beginning of ruler
    PutAttr(RuleAttr, j - l)            // and color it
    If (CurrCol() - ofs) / 100 > 0
        Message("Add ", (CurrCol() - ofs) / 100, "00 to the ruler reading...")
    EndIf
END

PROC CLeft()
    Left()
    If WhereX() <= Query(Windowx1)
        DrawRuler()
    EndIf
END

PROC CRight()
    Right()
    If CurrPos() >= Query(WindowCols) - 1
        DrawRuler()
    EndIf
END

KeyDef Shift
    <CursorLeft>            CLeft()
    <CursorRight>           CRight()
    <Alt GreyCursorLeft>    RollLeft(4)  DrawRuler()
    <Alt GreyCursorRight>   RollRight(4) DrawRuler()
    <Home>                  BegLine()    DrawRuler()
    <End>                   EndLine()    DrawRuler()
    <Shift Tab>             TabLeft()    DrawRuler()
    <Tab>                   TabRight()   DrawRuler()
    <CursorDown>            EndProcess()
END

PROC mRuler(INTEGER Offset)
    STRING os[3] = STR(CurrCol())

    If CurrRow() == Query(WindowRows)   // is last window row?
        Warn("No room for ruler...")    // forget it
        Halt
    EndIf

    If Offset == TRUE                   // for offset processing,
        Ask("Starting Column: ", os)    // ...get ofset
        ofs = Val(os) - 1               // turn into a offset integer
    Else
        ofs = 0
    EndIf

    DrawRuler()
    Enable (Shift)
    Message("Press 'Down' to clear ruler...")
    Process()
    Disable(Shift)
    ClrScr()
    UpdateDisplay(_All_Windows_Refresh_)

END mRuler

<alt r><r>         mRuler(False)
<alt r><o>         mRuler(True)
