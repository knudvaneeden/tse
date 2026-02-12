
#include ["ss.h"]

constant    GunWidth        = 5,
            GunHeight       = 2,
            BulletChar      = 219,
            InvaderChar     = 157,
            InvadersPerLine = 15

integer GunPos = 37,
        gameID,
        DelayFactor,
        Firing,
        FireY,
        InvadersLeft,
        Invaded,
        Level,
        Score,
        BombsLeft

string  GunStr1[]   = ' ÜÛÜ',
        GunStr2[]   = 'ßßßßß',
        GroundStr[] = 'ÄÄÄÄÄ'

proc mDelay(integer hs)
    integer i = hs * DelayFactor

    while i
        i = i - 1
    endwhile
end

proc PopMessage(string msg, integer dlay)
    integer x1, y1, len = Length(msg)

    x1 = (Query(ScreenCols) / 2) - (len / 2) - 2
    y1 = Query(ScreenRows) / 2 - 5

    if PopWinOpen(x1, y1, x1 + len + 3, y1 + 4, 2, '', Query(MenuBorderAttr))
        Set(Attr, Query(MenuTextAttr))
        ClrScr()
        WriteLine('')
        WriteLine(' ',msg)
        mDelay(dlay)
        PopWinClose()
    else
        Message(msg)
        mDelay(dlay)
    endif
end

proc DrawGun(integer erase)
    integer a = Query(Attr)

    if erase
        Set(Attr, 0)
    endif
    VGotoXYAbs(GunPos,Query(ScreenRows)-1)
    PutStr(GunStr1)
    VGotoXYAbs(GunPos,Query(ScreenRows))
    if erase
        Set(Attr, Color(Bright Green on Black))
        PutStr(GroundStr)
    else
        PutStr(GunStr2)
    endif
    Set(Attr, a)
end

integer proc GetHSecs()
    integer hh, mm, ss, hs

    GetTime(hh,mm,ss,hs)
    return (hh * 360000 + mm * 6000 + ss * 100 + hs)
end

proc Initialize()
    integer time

    gameID = CreateTempBuffer()
    Window(1,1,Query(ScreenCols),Query(ScreenRows))
    Set(Attr, Color(Bright Cyan on Black))
    ClrScr()
    VGotoXYAbs(1,2)
    PutCharH('Ä',Query(ScreenCols))
    Window(1,3,Query(ScreenCols),Query(ScreenRows)-GunHeight)
    VGotoXYAbs(1, Query(ScreenRows))
    Set(Attr, Color(Bright Green on Black))
    PutCharH('Ä', Query(ScreenCols))
    Set(Attr, Color(Bright Yellow on Black))
    DrawGun(0)

    DelayFactor = 0
    time = GetHSecs()
    repeat
        DelayFactor = DelayFactor + 1
    until DelayFactor > 5000
    time = GetHSecs() - time
    DelayFactor = DelayFactor / time

    Invaded = FALSE
    Firing = FALSE
    Level = 0
    Score = 0
    BombsLeft = 2
end

constant    mLEFT   = -1,
            mRIGHT  =  1

proc MoveGun(integer dir)
    integer newpos = GunPos + dir

    if newpos > 0 and newpos <= Query(ScreenCols) - GunWidth + 1
        DrawGun(1)
        GunPos = newpos
        Set(Attr, Color(Bright Yellow on Black))
        DrawGun(0)
    endif
    while KeyPressed()
        GetKey()
    endwhile
end

integer proc InvaderAt(integer x, integer y)
    GotoLine(y)
    GotoColumn(x)
    return (CurrChar() == InvaderChar)
end

proc DestroyInvader(integer x, integer y)
    integer i = 15, a = Query(Attr)
    GotoLine(y)
    GotoColumn(x)
    InsertText(' ',_OVERWRITE_)
    repeat
        VGotoXYAbs(x, y)
        Set(Attr, i)
        PutChar('')
        mDelay(1)
        i = i - 1
    until i < 0
    InvadersLeft = InvadersLeft - 1
    Score = Score + (Level * 10)
    Set(Attr, a)
end

proc CheckFire()
    integer a = Set(Attr, Color(Bright Red on Black)),
            x = GunPos+(GunWidth/2)

    if Firing
        FireY = FireY - 1
        if FireY > 2
            Fire_It:
            if InvaderAt(x, FireY)
                DestroyInvader(x, FireY)
                Firing = FALSE
                FireY = Query(ScreenRows) - GunHeight
            else
                VGotoXYAbs(x, FireY)
                PutChar(Chr(BulletChar))
                mDelay(1)
                VGotoXYAbs(x, FireY)
                PutChar(' ')
            endif
        else
            Firing = FALSE
            FireY = Query(ScreenRows) - GunHeight
        endif
    endif
    Set(Attr, a)
end

proc AttrScr(integer a)
    integer y = 3

    while y <= Query(ScreenRows) - GunHeight
        VGotoXYAbs(1, y)
        PutAttr(a, Query(ScreenCols))
        y = y + 1
    endwhile
end

proc Bomb()
    integer i = 10

    if BombsLeft
        BombsLeft = BombsLeft - 1
        while i
            AttrScr(Color(Black on White))
            mDelay(10)
            AttrScr(Color(White on Black))
            mDelay(10)
            i = i - 1
        endwhile
        ClrScr()
        PopMessage(Format(BombsLeft,' Bombs left!'), 300)
        Score = Score + (10 * InvadersLeft)
        InvadersLeft = 0
        Firing = FALSE
        FireY = Query(ScreenRows) - GunHeight
    endif
end

proc PutInvader(integer x, integer y)
    GotoLine(y)
    GotoColumn(x)
    InsertText(Chr(InvaderChar),_OVERWRITE_)
    VGotoXYAbs(x, y)
    Set(Attr, (x mod 15) + 1)
    PutChar(Chr(InvaderChar))
end

proc UpdateInvaders()
    integer x, y, i

    if InvadersLeft <= 0
        EmptyBuffer()
        i = Query(ScreenRows)
        while i
            AddLine()
            i = i - 1
        endwhile
        x = 25
        y = 3
        while y < 7
            i = y mod 2
            while i < (InvadersPerLine * 2)
                PutInvader(x+i, y)
                i = i + 2
            endwhile
            y = y + 1
        endwhile
        Level = Level + 1
        if (Level mod 5) == 0
            BombsLeft = BombsLeft + 1
        endif
        InvadersLeft = InvadersPerLine * 4
    else
        GotoLine(Query(ScreenRows)-GunHeight)
        MarkLine()
        MarkLine()
        if lFind(Chr(InvaderChar),'gl')
            Invaded = TRUE
        else
            DelLine()
            BegFile()
            InsertLine()
            if lFind(Chr(InvaderChar),'g')
                ClrScr()
                repeat
                    VGotoXYAbs(CurrCol(), CurrLine())
                    Set(Attr, (CurrCol() mod 15) + 1)
                    PutChar(Chr(InvaderChar))
                until not lRepeatFind()
            else
                Warn('Fatal Error 101')
            endif
        endif
        UnMarkBlock()
    endif
end

proc main()
    integer cursor = Set(Cursor, Off), eek = Set(EquateEnhancedKbd, On),
            lasttime = 0

    HideMouse()

    Initialize()
    loop
        if (InvadersLeft == 0) or ((GetHSecs() - lasttime) > (205 - (Level * 5)))
            UpdateInvaders()
            lasttime = GetHSecs()
        endif
        if Invaded
            Set(Attr, Color(Blink Bright White on Black))
            VGotoXY(28, 8)
            PutStr('YOU HAVE BEEN INVADED!!!')
            Set(Attr, Color(Bright Red on Black))
            VGotoXY(29, 10)
            PutStr('Press <Escape> to exit')
            repeat until GetKey() == <Escape>
            break
        endif
        VGotoXYAbs(1,1)
        Set(Attr, Color(Bright White on Black))
        PutStr(Format(' Bombs = ',BombsLeft:3,'Score = ':26,Score:9,'Level = ':28,Level:2))
        if BIOSShiftState() & sSHIFT
            Firing = TRUE
        endif
        CheckFire()
        if KeyPressed()
            case GetKey()
                when <CursorLeft>,  <Shift CursorLeft>      MoveGun(mLEFT)
                when <CursorRight>, <Shift CursorRight>     MoveGun(mRIGHT)
                when <Spacebar>                             Bomb()
                when <Escape>                               break
            endcase
        endif
    endloop
    AbandonFile(gameID)
    Set(Cursor, cursor)
    Set(EquateEnhancedKbd, eek)
    ShowMouse()
    Window(1,1,Query(ScreenCols),Query(ScreenRows))
    UpdateDisplay(_ALL_WINDOWS_REFRESH_|_HELPLINE_REFRESH_)
end
