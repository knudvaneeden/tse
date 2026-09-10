/****************************************************************************\

    HlpLnClk.S

    Mouse interface for help line.

    Overview:

    This macro hilites a key definition within TSE's help line and
    pushes the corresponding key onto the key stack executing the
    command bound to that key.

    Keys:
            <none>

    Usage notes:

    You must add HlpLnClk to TSE's autoload list.

    Version         v2.00/21.10.96
    Copyright       (c) 1996 by DiK

    History
    v2.00/21.10.96  merged with version 1.0 (TSE 2.5)
    v1.91/12.07.96  bug fixes
    v1.90/03.07.96  adaption to TSE32
    v1.00/29.03.96  first release

    Limitations
    þ help line items must be blank delimited
    þ can handle only key-dash-description items

    Acknowledgements:
    þ thanks to Chris Antos for suggestions and finding a bug

\****************************************************************************/

/****************************************************************************\
    version dependant constants

    note:   used only to work around sc (2.5) bug
\****************************************************************************/

#ifdef WIN32
constant _ON_UNASSIGNED_KEY = 25
#else
constant _ON_UNASSIGNED_KEY = 0
#endif

/****************************************************************************\
    global constants
\****************************************************************************/

constant FLASH = 3                      // delay for help line flash
constant SPACE = 32                     // ascii code: space
constant DASH  = 45                     // ascii code: dash

/****************************************************************************\
    global variables
\****************************************************************************/

#ifndef WIN32

integer bid                             // note: defined global to fix sc
integer keys                            // buffer id of translation buffer

#endif

/****************************************************************************\
    key translation (dos only)
\****************************************************************************/

#ifndef WIN32

datadef table
    "54005E0068003B00F1"
    "5D00670071004400F10"
    "870089008B008500F11"
    "88008A008C008600F12"
    "55005F0069003C00F2"
    "560060006A003D00F3"
    "570061006B003E00F4"
    "580062006C003F00F5"
    "590063006D004000F6"
    "5A0064006E004100F7"
    "5B0065006F004200F8"
    "5C00660070004300F9"
    "0B290B0081000B300"
    "02210200780002311"
    "03400300790003322"
    "042304007A0004333"
    "052405007B0005344"
    "062506007C0006355"
    "075E071E7D0007366"
    "082608007E0008377"
    "092A09007F0009388"
    "0A280A0080000A399"
    "1E411E011E001E61A"
    "3042300230003062B"
    "2E432E032E002E63C"
    "2044200420002064D"
    "1245120512001265E"
    "2146210621002166F"
    "2247220722002267G"
    "2348230823002368H"
    "1749170917001769I"
    "244A240A2400246AJ"
    "254B250B2500256BK"
    "264C260C2600266CL"
    "324D320D3200326DM"
    "314E310E3100316EN"
    "184F180F1800186FO"
    "1950191019001970P"
    "1051101110001071Q"
    "1352131213001372R"
    "1F531F131F001F73S"
    "1454141414001474T"
    "1655161516001675U"
    "2F562F162F002F76V"
    "1157111711001177W"
    "2D582D182D002D78X"
    "1559151915001579Y"
    "2C5A2C1A2C002C7AZ"
    "01F400000100011BEsc"
    "01F400000100011BEscape"
    "0EF40E7F0E000E08BkSpc"
    "0EF40E7F0E000E08Backspace"
    "0F009400A5000F09Tab"
    "1CF41C0A1C001C0DEnter"
    "39F439F539F93920Space"
    "39F439F539F93920Spacebar"
end

#endif

/****************************************************************************\
    read characters from screen (dos only)
\****************************************************************************/

#ifndef WIN32

integer proc GetStrXY( integer x, integer y, var string s, integer max_len )
    register r
    integer len

    s = ""
    len = 0

    while x <= Query(ScreenCols) and len < max_len
        GotoXY(x,y)
        r.ax = 0x0800
        r.bx = 0
        Intr(0x10,r)
        s = s + Chr(r.ax & 0xFF)
        x = x + 1
    endwhile

    return(len)
end

#endif

/****************************************************************************\
    help line handler
\****************************************************************************/

integer proc HandleHelpLine()
    integer Y, X1, X2
    integer len
    integer attr
    integer code
    integer flags
    string key[32]
    string line[255] = ""

#ifdef WIN32
    string shift[32]
#endif

    // check help line and get the mouse coordinates

    if not Query(ShowHelpLine)
        return (FALSE)
    endif
    if Query(StatusLineAtTop)
        Y = Query(ScreenRows)
    else
        Y = 1
    endif
    if Y <> Query(MouseY)
        return (FALSE)
    endif
    X1 = Query(MouseX)

    // get the help line and check for null events

    len = GetStrXY(1,Y,line,250)
    if line[X1] == " "
        return (TRUE)
    endif
    line = " " + line + " -"

    // search boundaries and key string of current item

    X1 = X1 + 1
    while line[X1] <> " "
        X1 = X1 - 1
    endwhile
    X1 = X1 + 1
    X2 = X1
    while line[X2] <> "-"
        X2 = X2 + 1
    endwhile
    if X2 == len+3
        return (TRUE)
    endif
    key = SubStr(line,X1,X2-X1)
    while line[X2] <> " "
        X2 = X2 + 1
    endwhile

    // determine shift state

    flags = GetKeyFlags()

#ifndef WIN32
    if flags & (_RIGHT_SHIFT_KEY_|_LEFT_SHIFT_KEY_)
        code = 1
    elseif flags & _CTRL_KEY_
        code = 5
    elseif flags & _ALT_KEY_
        code = 9
    else
        code = 13
    endif
#else
    shift = ""
    if flags & _CTRL_KEY_
        shift = shift + "ctrl"
    endif
    if flags & _ALT_KEY_
        shift = shift + "alt"
    endif
    if flags & _LEFT_SHIFT_KEY_
        shift = shift + "shift"
    endif
#endif

    // make and push key code

#ifdef WIN32
    code = KeyCode(shift+" "+key)
#else
    bid = GotoBufferId(keys)
    PushBlock()
    MarkColumn(1,17,NumLines(),48)
    if lFind(key,"lgi")
        code = Val(GetText(code,4),16)
    else
        code = 0
    endif
    PopBlock()
    GotoBufferId(bid)
#endif

    if code
        PushKey(code)
        attr = Query(MenuSelectAttr)
    else
        Alarm()
        attr = Color(Red on Red)
    endif

    // flash the help line entry

    VGotoXY(X1-1,Y)
    PutAttr(attr,X2-X1)
    Delay(FLASH)
    UpdateDisplay(_HELPLINE_REFRESH_)

    // indicate success

    return (TRUE)
end

/****************************************************************************\
    mouse handler
\****************************************************************************/

integer idle = TRUE

proc HandleMouse()
    if idle
        idle = FALSE
        if MouseHotSpot() == _NONE_ and HandleHelpLine()
            Set(Key,0)
        else
            ChainCmd()
        endif
        idle = TRUE
    endif
end

#ifndef WIN32                                       // don't change this
#else                                               // sc (2.5) needs it

proc OnUnassignedKey()
    integer key = Query(Key) & 0xF0FF               // mask shift state

    if key == <LeftBtn>
        HandleMouse()
    endif
end

#endif

/****************************************************************************\
    setup and shutdown
\****************************************************************************/

proc WhenLoaded()

#ifndef WIN32
    bid = GetBufferId()
    keys = CreateTempBuffer()
    if not (keys and InsertData(table))
        Warn("HlpLnClk: Cannot allocate work space")
        PurgeMacro(CurrMacrofilename())
        return ()
    endif
    GotoBufferId(bid)
#else
    Hook(_ON_UNASSIGNED_KEY,OnUnassignedKey)
#endif

end

proc WhenPurged()

#ifndef WIN32
    AbandonFile(keys)
#else
    UnHook(OnUnassignedKey)
#endif

end

/****************************************************************************\
    key assignments
\****************************************************************************/

<LeftBtn>                   HandleMouse()
<Alt LeftBtn>               HandleMouse()
<Ctrl LeftBtn>              HandleMouse()
<Shift LeftBtn>             HandleMouse()

#ifndef WIN32

<0xE861>                    HandleMouse()       // <CtrlShift LeftBtn>
<0xE8A1>                    HandleMouse()       // <AltShift LeftBtn>
<0xE8C1>                    HandleMouse()       // <CtrlAlt LeftBtn>
<0xE8E1>                    HandleMouse()       // <CtrlAltShift LeftBtn>

#else

<CtrlShift LeftBtn>         HandleMouse()
<AltShift LeftBtn>          HandleMouse()
<CtrlAlt LeftBtn>           HandleMouse()
<CtrlAltShift LeftBtn>      HandleMouse()

#endif

