/****************************************************************************\

    ASCII Chart using a Win32 DLL

    Version         1.0.0.0.4
    LLM             OpenAI Codex (GPT-5)

    This is a Win32 TSE SAL adaptation of DiK's public-domain Ascii.S
    version 1.20.  Its former embedded 16-bit assembler routine is replaced
    by GetChar() in asciidll.dll, buildable with Borland C++ 5.5.

\****************************************************************************/

string Title[11] = "Ascii Chart"

constant    ClrW = Color(Black on White),
            ClrB = Color(Bright White on White),
            ClrC = Color(Bright Yellow on Red)

constant    Cols = 32,
            Line = 256 / Cols,
            WinW = Cols + 2,
            WinH = Line + 4,
            OfsX = 3,
            OfsY = 5

integer     WinL = 22,
            WinT = 7,
            LimL, LimT,
            CurX, CurY,
            CatX, CatY,
            FromPrompt

dll "asciidll.dll"
    integer proc GetChar(integer x, integer y): "GetChar"
end

integer proc Limit(integer numI, integer minI, integer maxI)
    return(iif(numI < minI, minI, iif(numI > maxI, maxI, numI)))
end

proc GetCat()
    CatX = Query(MouseX)
    CatY = Query(MouseY)
    if FromPrompt
        if CatX > 32767 CatX = CatX - 65536 endif
        if CatY > 32767 CatY = CatY - 65536 endif
    else
        CatX = CatX - WinL
        CatY = CatY - WinT
    endif
end

proc PaintStatus()
    integer charI

    PutAttr(ClrW, 1)
    GotoXY(CurX, CurY)
    PutAttr(ClrC, 1)
    charI = (CurY - OfsY) * Cols + (CurX - OfsX)
    GotoXY(1, 1)
    Write("Dec-Code:":12, charI:4, "Hex-Code:":12, charI:3:" ":16, "":3)
    GotoXY(CurX, CurY)
end

proc PaintChart()
    integer iI, jI
    string lineS[Cols + 2]

    GotoXY(1, 2) Write("+") PutCharH("-", Cols)
    lineS = "| "
    jI = 0
    while jI < Cols
        lineS = lineS + Format(jI & 0x0F :1:"0":16)
        jI = jI + 1
    endwhile
    GotoXY(1, 3) PutStr(lineS)
    GotoXY(1, 4) Write("+") PutCharH("-", Cols)

    iI = 0
    while iI < Line
        lineS = Format(2 * iI :1:"0":16, "|")
        jI = 0
        while jI < Cols
            lineS = lineS + Chr(iI * Cols + jI)
            jI = jI + 1
        endwhile
        GotoXY(1, iI + 5) PutStr(lineS)
        iI = iI + 1
    endwhile
    GotoXY(CurX, CurY)
end

proc WinOpen()
    if not PopWinOpen(WinL, WinT, WinL + WinW + 1, WinT + WinH + 1,
                      4, Title, ClrB)
        Warn("Error opening popup window")
        Alarm()
        Halt
    endif
    Set(Cursor, OFF)
    Set(Attr, ClrW)
    GotoXY(13, WinH + 1)
    PutHelpLine(" {F1}-Help ")
end

proc WinMove(integer delLI, integer delTI)
    integer oldLI = WinL
    integer oldTI = WinT

    WinL = Limit(WinL + delLI, 1, LimL)
    WinT = Limit(WinT + delTI, 1, LimT)
    if WinL <> oldLI or WinT <> oldTI
        PopWinClose()
        WinOpen()
    endif
end

proc WinDrag()
    integer x0I = CatX

    while MouseKeyHeld()
        GetCat()
        WinMove(CatX - x0I, CatY)
    endwhile
    PaintChart()
end

proc CursorSet(integer keyI)
    keyI = keyI & 0xFF
    CurX = keyI mod Cols + OfsX
    CurY = keyI / Cols + OfsY
end

proc CursorMove(integer delXI, integer delYI)
    CurX = Limit(CurX + delXI, OfsX, WinW)
    CurY = Limit(CurY + delYI, OfsY, WinH)
end

proc CursorDrag()
    while MouseKeyHeld()
        GetCat()
        CurX = Limit(CatX, OfsX, WinW)
        CurY = Limit(CatY, OfsY, WinH)
        PaintStatus()
    endwhile
end

proc LeftBtnDown()
    integer oldXI = CurX
    integer oldYI = CurY

    GetCat()
    if 0 <= CatX and CatX <= WinW + 1 and 0 <= CatY and CatY <= WinH + 1
        if CatY == 0
            WinDrag()
        else
            CursorDrag()
            if oldXI == CurX and oldYI == CurY
                PushKey(<Enter>)
            endif
        endif
    else
        CursorSet(GetChar(WinL + CatX, WinT + CatY))
    endif
end

helpdef AsciiHelp
    title = "Help on Ascii Chart"
    x = 10
    y = 4
    width = 60
    height = 16

    ""
    " Escape or Right Click"
    "   close the chart"
    ""
    " Enter or Left Double Click"
    "   close the chart and insert the highlighted character"
    ""
    " Cursor Keys or Left Click"
    "   position the highlight"
    ""
    " Ctrl-Cursor Keys or Dragging Chart at Title"
    "   move the chart"
    ""
    " Any other key"
    "   position the highlight at the corresponding character"
    ""
end

integer proc CtrlKeyLoop(integer eventI)
    loop
        case eventI
            when <Ctrl CursorUp>        WinMove(0, -1)
            when <Ctrl CursorDown>      WinMove(0, +1)
            when <Ctrl CursorLeft>      WinMove(-1, 0)
            when <Ctrl CursorRight>     WinMove(+1, 0)
            when <Ctrl PgUp>            WinMove(0, -999)
            when <Ctrl PgDn>            WinMove(0, +999)
            when <Ctrl Home>            WinMove(-999, 0)
            when <Ctrl End>             WinMove(+999, 0)
            otherwise                   break
        endcase
        repeat
            if (GetKeyFlags() & _CTRL_KEY_) == 0
                PaintChart()
                PaintStatus()
                break
            endif
        until KeyPressed()
        eventI = GetKey()
    endloop
    PaintChart()
    return(eventI)
end

integer proc EventLoop()
    integer eventI

    loop
        PaintStatus()
        eventI = GetKey()
        if (GetKeyFlags() & _CTRL_KEY_) <> 0
            eventI = CtrlKeyLoop(eventI)
        endif
        case eventI
            when <F1>                   QuickHelp(AsciiHelp)
            when <Enter>                break
            when <Escape>               break
            when <LeftBtn>              LeftBtnDown()
            when <RightBtn>             PushKey(<Escape>)
            when <CursorUp>             CursorMove(0, -1)
            when <CursorDown>           CursorMove(0, +1)
            when <CursorLeft>           CursorMove(-1, 0)
            when <CursorRight>          CursorMove(+1, 0)
            when <PgUp>                 CursorMove(0, -Line)
            when <PgDn>                 CursorMove(0, +Line)
            when <Home>                 CursorMove(-Cols, 0)
            when <End>                  CursorMove(+Cols, 0)
            otherwise                   CursorSet(eventI)
        endcase
    endloop
    return(eventI)
end

proc Init()
    LimL = Query(ScreenCols) - WinW - 1
    LimT = Query(ScreenRows) - WinH - 1
    CursorSet(iif(CurrChar() < 0, 32, CurrChar()))
    WinOpen()
    PaintChart()
end

proc Done(integer eventI)
    integer charI

    PopWinClose()
    Set(Cursor, ON)
    if eventI == <Enter>
        charI = (CurY - OfsY) * Cols + (CurX - OfsX)
        InsertText(Chr(charI))
    endif
    PurgeMacro(CurrMacroFilename())
end

proc Main()
    Init()
    Done(EventLoop())
end

public proc RunFromPrompt()
    FromPrompt = TRUE
    Main()
end
