 /*************************************************************************
  SyncAll.s

  This program gives The SemWare Editor  An  Sync  for  Up  to  Four
  Windows.

  Author: James Coffer

  Date:       June 18, 1995

  Overview: No Comments

 *************************************************************************/
proc mRollLeft()
    if CurrCol() == 1 and CurrXoffset() == 0
        return()
    endif
    if CurrCol() == 1
        Right()
    endif
    RollLeft()
end mRollLeft

proc mRollRight()
    // get the next xoffset position
    integer NewXoffset = CurrXoffset() + 1

    GotoXoffset(NewXoffset)
    if CurrXoffset() == NewXoffset
        Left()
        if CurrXoffset() <> NewXoffset
            Right()
            GotoXoffset(NewXoffset)
        endif
    else
        Right()
        GotoXoffset(NewXoffset)
        Left()
        if CurrXoffset() <> NewXoffset
            Right()
            GotoXoffset(NewXoffset)
        endif
    endif
end mRollRight

integer proc mSyncFourScreenKeys(integer keystroke, integer win)
    integer CurrentWinID = WindowID(), ReturnCode = TRUE

    GotoWindow(win)
    if WindowID() <> win
        ReturnCode = FALSE
        return(ReturnCode)
    endif
    case keystroke
        when <CursorUp>
            if CurrLine() > (Query(WindowRows) / 2)
                RollUp()
            else
                Up()
            endif
        when <CursorDown>
            if CurrLine() > (Query(WindowRows) / 2)
                RollDown()
            else
                Down()
            endif
        when <Ctrl PgUp>
            BegFile()
        when <Ctrl PgDn>
            EndFile()
            BegLine()
        when <CursorRight>
            mRollRight()
        when <CursorLeft>
            mRollLeft()
        when <PgUp>
            PageUp()
        when <PgDn>
            PageDown()
        when <Home>
            BegLine()
        when <End>
            EndLine()
        otherwise
            ReturnCode = FALSE
    endcase
    ScrollToRow(Query(WindowRows) / 2)
    GotoWindow(CurrentWinID)
    return(ReturnCode)
end mSyncFourScreenKeys

proc MultiCursor(integer keystroke)
mSyncFourScreenKeys(keystroke, 1)
mSyncFourScreenKeys(keystroke, 2)
mSyncFourScreenKeys(keystroke, 3)
mSyncFourScreenKeys(keystroke, 4)
end MultiCursor

<Shift CursorUp>        MultiCursor(<CursorUp>)
<Shift CursorDown>      MultiCursor(<CursorDown>)
<Shift CursorRight>     MultiCursor(<CursorRight>)
<Shift CursorLeft>      MultiCursor(<CursorLeft>)

<CtrlShift PgUp>        MultiCursor(<Ctrl PgUp>)
<CtrlShift PgDn>        MultiCursor(<Ctrl PgDn>)

<Shift PgUp>            MultiCursor(<PgUp>)
<Shift PgDn>            MultiCursor(<PgDn>)

<Shift Home>            MultiCursor(<Home>)
<Shift End>             MultiCursor(<End>)

