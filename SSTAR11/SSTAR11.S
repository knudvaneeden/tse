/*
    ScreenStar v1.1
    Norton Commander like screen saver
    v1.00 written by Luca Salvini, Bologna (ITALY) 1994
    v1.1 by Miguel Farah - adds non-white stars

 ** Screen does instant blank if mouse is at bottom right corner, or with
    <CtrlAlt A>
 ** Screen won't blank (disable) if mouse is at top left corner
 ** PopUp menu with <CtrlAlt S>
 ** Works in any screen mode (132x44 too!)
*/

constant MAX_STARS= 100
constant BLANKERTIME= 120 // seconds
constant BLANKERSTAR= 30
constant BLANKERSTEP= 8
constant BLANKERDELAY= 18
constant NOVARANDOM=  3
constant WHIITE= 70       // wh*ii*te, not "white"
constant BLANKERCOLOR= Color(White On Black)
constant BLANKERHIDE= Color(Black On Black)

integer  No_BlankX, No_BlankY, BlankX, BlankY

integer z = 1
integer Total
integer Rx, Ry                              // Row and Column
integer Blanker_Interval= BLANKERTIME       // # of seconds between saves
integer Blanker_Star= BLANKERSTAR           // # of stars
integer Blanker_Nova= NOVARANDOM            // frequency of Nova
integer Blanker_White= WHIITE               // frequency of white stars

/* returns number in [1 .. 2147483646] */
integer proc Random()
    integer lo, hi, Test
    hi= z / 127773
    lo = z mod 127773
    Test = 16807 * lo - (2147483647 mod 16807) * hi
    if (Test > 0)
        z = Test
    else
        z = Test + 2147483647
    endif
    return(z)
end

/* set the seed */
proc Srandom(integer Seed)
    if (Seed == 0)
        Seed = 1
    endif
    z = Seed
end

integer proc Rand(integer i1, integer i2)
    integer i, t, v
    t= Random()
    i= i2-i1
    v= (t mod i)+i1
    return(v)
end

integer proc CurrTimeInSeconds()
    integer Hours, Minutes, Seconds, Hundredths, SubTotal
    GetTime(Hours, Minutes, Seconds, Hundredths)
    SubTotal = (((Hours * 60) + Minutes) * 60) + Seconds
    return(SubTotal)
end

proc BlankScreen()
    integer row
    row= Ry
    while row
        vGotoXY(1, row)
        PutAttr(BLANKERHIDE, rx)
        row= row - 1
    endwhile
end

proc PutBlankerColor(string charAtScreen)
    integer collor=Rand(1,7)
    integer whiteOrColored=Rand(1,100)

    if (whiteOrColored>=Blanker_White) and (charAtScreen=="ъ")
       case collor
           when 1 PutAttr(Color(Blue   on Black), 1)
           when 2 PutAttr(Color(Cyan   on Black), 1)
           when 3 PutAttr(Color(Red    on Black), 1)
           when 4 PutAttr(Color(Yellow on Black), 1)
           when 5 PutAttr(Color(Bright Black on Black), 1)
           when 6 PutAttr(Color(Bright White on Black), 1)
        otherwise PutAttr(BLANKERCOLOR, 1)
       endcase
    elseif (whiteOrColored>=Blanker_White) and (charAtScreen=="щ")
       case collor
           when 1 PutAttr(Color(Blue   on Black), 1)
           when 2 PutAttr(Color(Cyan   on Black), 1)
           when 3 PutAttr(Color(Red    on Black), 1)
           when 4 PutAttr(Color(Yellow on Black), 1)
           when 5 PutAttr(Color(Bright Yellow on Black), 1)
           when 6 PutAttr(Color(Bright White  on Black), 1)
        otherwise PutAttr(BLANKERCOLOR, 1)
       endcase
    else PutAttr(BLANKERCOLOR, 1)
    endif
end

proc Star()
    string ax[MAX_STARS], ay[MAX_STARS], as[MAX_STARS]
    string s[BLANKERSTEP]="ъщю "
    integer i, c, x, y, mx, my
    i= 1
    ax= ''
    ay= ''
    as= ''
    while i <= Blanker_Star
        ax= ax + chr(Rand(1, Rx))
        ay= ay + chr(Rand(1, Ry))
        as= as + chr((Rand(1, 100) mod 2) + 1)
        i= i+1
    endwhile
    MouseStatus()
    mx= Query(MouseX)
    my= Query(MouseY)
    while not (KeyPressed() or Query(MouseKey))
        MouseStatus()
        if (mx <> Query(MouseX) or my <> Query(MouseY))
            PushKey(<Enter>)    // to balance GetKey()
            break
        endif
        i= 1
        while i <= Blanker_Star
            c= asc(SubStr(as, i, 1)) + 1
            if (c > 0)
                if (c == 3) and Rand(1, 100) > Blanker_Nova
                    c= BLANKERSTEP-1
                endif
                if (c == BLANKERSTEP)
                    c= (rand(1, 100) mod 2) + 1
                    ax= SubStr(ax, 1, i-1) + chr(Rand(1, Rx)) + SubStr(ax, i+1, Blanker_Star-i)
                    ay= SubStr(ay, 1, i-1) + chr(Rand(1, Ry)) + SubStr(ay, i+1, Blanker_Star-i)
                endif
                as= SubStr(as, 1, i-1) + chr(c) + SubStr(as, i+1, Blanker_Star-i)
            endif
            i=i+1
        endwhile
        i= 1
        while i <= Blanker_Star
            x= asc(SubStr(ax, i, 1))
            y= asc(SubStr(ay, i, 1))
            GotoXY(x, y)
            PutChar(SubStr(s, asc(SubStr(as, i, 1)), 1))
            GotoXY(x, y)
            PutBlankerColor(SubStr(s, asc(SubStr(as, i, 1)), 1))
            i=i+1
        endwhile
        Delay(BLANKERDELAY)
    endwhile
    GetKey()
end

proc ScreenSaver()
    PushPosition()
    HideMouse()
    Set(Cursor, OFF)
    BlankScreen()
    Star()
    UpdateDisplay(_ALL_WINDOWS_REFRESH_ | _HELPLINE_REFRESH_)
    Set(Cursor, ON)
    ShowMouse()
    Total= CurrTimeInSeconds()
    PopPosition()
end

proc Idle()
    MouseStatus()
    Ry= Query(ScreenRows)
    Rx= Query(ScreenCols)
    // No blank if mouse is at (1, Rx) (normally 1, 80)
    // V1.1: I say 1,1 (top-left)
    No_BlankX= 1
    No_BlankY= 1
    // Istant blank if mouse is at (Ry, Rx) (normally 25, 80)
    BlankX= Rx
    BlankY= Ry
    if (Query(MouseX) <> No_BlankX or Query(MouseY) <> No_BlankY)
        if (Blanker_Interval and ((Total + Blanker_Interval) < CurrTimeInSeconds())) or (Query(MouseX) == BlankX and Query(MouseY) == BlankY)
            ScreenSaver()
        endif
    else
        Total= CurrTimeInSeconds()
    endif
    // Handle shift at midnight
    if Total > CurrTimeInSeconds()
        Total= CurrTimeInSeconds()
    endif
end

proc AfterCommand()
    Total= CurrTimeInSeconds()
end

proc WhenLoaded()
    Hook(_AFTER_COMMAND_, AfterCommand)
    Hook(_IDLE_, Idle)
    AfterCommand()     // force initialization of blanker
    SRandom(CurrTimeInSeconds())
end

proc GetNumber(var integer n)
    string s[2] = Str(n)
    if Read(s)
        n = val(s)
    endif
end

proc GetSecond(var integer n)
    string s[5] = Str(n)
    if Read(s)
        n = val(s)
    endif
end

Menu MenuSS()
    Title= "Screen Saver Control"
    History=5

    "blanker &Interval"       [Blanker_Interval : 5], GetSecond(Blanker_Interval), DontClose
    "blanker &Stars"          [Blanker_Star : 2],     GetNumber(Blanker_Star),     DontClose
    "supernova &Probability"  [Blanker_Nova : 2],     GetNumber(Blanker_Nova),     DontClose
    "&White star probability" [Blanker_White : 2],    GetNumber(Blanker_White),    DontClose
    "", , Divide
    "&Blank NOW", ScreenSaver()
end

<CtrlAlt S> MenuSS()
<CtrlAlt A> ScreenSaver()

