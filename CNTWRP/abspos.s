/************************************************************************
  A pair of macros to save and restore absolute cursor position
  within the current window.
  Also the global variables to save the stack buffer information.
 ************************************************************************/

integer AbsPosBuffer   = 0                  // buffer id
integer AbsPosDebug    = 0                  // buffer debugging flag
string _AbsPosName[13] = "+AbsPosition+"    // buffer name

proc PushAbsPos()
    integer
        currbuf,
        saveline,
        savecol,
        saverow

    currbuf  = GetBufferId()
    if (AbsPosBuffer == 0)
        AbsPosBuffer = CreateBuffer(_AbsPosName, _SYSTEM_)
        if (AbsPosBuffer == 0)
            Warn("No memory for PushAbsPos()!")
            return()
        endif
    endif
    // Now save the current position information
    GoToBufferId(currbuf)
    if AbsPosDebug
        Warn("PushStart:CurrBuffer = " + Str(currbuf) + ", Row:Line:Col " + Str(CurrRow()) + ":" + Str(CurrLine()) + ":" + Str(CurrCol()))
    endif
    saveline = CurrLine()
    savecol  = CurrCol()
    saverow  = CurrRow()
    GoToBufferId(AbsPosBuffer)
    InsertLine(Str(saveline))
    InsertLine(Str(savecol ))
    InsertLine(Str(saverow ))
    if AbsPosDebug
        Warn("PushEnd:AbsBuffer = " + Str(AbsPosBuffer) + ", Row:Line:Col " + Str(saverow) + ":" + Str(saveline) + ":" + Str(savecol))
    endif
    // Return to the prior buffer
    GoToBufferId(currbuf)
end PushAbsPos

proc PopAbsPos()
    integer
        currbuf,
        currkm,
        saveline,
        savecol,
        saverow

    if (AbsPosBuffer == 0)
        Warn("No buffer for PopAbsPos()!")
        return()
    endif
    // Now retrieve the current position information
    currbuf  = GetBufferId()
    if AbsPosDebug
        Warn("PopStart:CurrBuffer = " + Str(currbuf) + ", Row:Line:Col " + Str(CurrRow()) + ":" + Str(CurrLine()) + ":" + Str(CurrCol()))
    endif
    GoToBufferId(AbsPosBuffer)
    currkm = Set(KillMax, 0)            // Set KillMax to 0 & save prior value
    saverow  = Val(GetText(1, CurrLineLen()))
    DelLine()
    savecol  = Val(GetText(1, CurrLineLen()))
    DelLine()
    saveline = Val(GetText(1, CurrLineLen()))
    DelLine()
    Set(KillMax, currkm)                // Restore prior KillMax value
    // Return to the prior buffer and restore the position there
    GoToBufferId(currbuf)
    GoToRow(saverow)
    GoToLine(saveline)
    GoToColumn(savecol)
    if AbsPosDebug
        Warn("PopEnd:AbsBuffer = " + Str(AbsPosBuffer) + ", Row:Line:Col " + Str(saverow) + ":" + Str(saveline) + ":" + Str(savecol))
    endif
end PopAbsPos

