/****************************************************************************\

    Dialog.S

    CUA style dialog boxes for SAL.

    Version         v2.22/20.04.05
    Copyright       (c) 1995-2005 by DiK

    Overview:

    This macro is a run time library which implements CUA style dialog
    boxes for SAL macros. This macro is not meant to be directly executed
    by the user.

    Usage notes:

    See Program.Doc for instructions on how to use Dialog.S from within
    your own macros.

    History

    v2.22/20.04.05  bug fix
                    + removed additional key-hook for drop-down lists
    v2.21/19.11.03  adaption to TSE32 v4.2
                    + fixed painting titles (oem bug)
    v2.20/24.10.02  adaption to TSE32 v4.0
                    + moved close box (v4.0 only)
                    + fixed version checking
                    + fixed mouse wheel support
                    + fixed restoring line in drop down list
                    + fixed computing mouse coordinates in listbox
    v2.11/15.01.02  maintenance (started 08.01.2002)
                    + added support for mswheel (macro by Chris Antos)
    v2.10/07.06.01  adaption to TSE32 v3.0 (started 28.07.99)
                    + added API functions
                        SetTitleEx
                    + added global variable DlgMsgText
                    + added checking for dialog boundaries
                    + added horizontal centering of window
                    + added automatic context menu handling for the keyboard
                    + added optional use of Windows clipboard for edit controls
                    + fixed error messages
                    + fixed hotkey handling
                    + fixed context menu handling
                    + fixed scrolling keys in list boxes
                    + fixed combo boxes
                    + fixed size of drop down lists
                    + fixed painting edit controls
                    + fixed error handling in DlgShowWindow
                    + fixed terminating incremental searches
                    + fixed spurious null events at shutdown (finally)

    v2.02/07.01.99  maintenance
                    + added querying of TracePointKey
                    + optimzed usage of macro stack
                    + fixed EditControl (deleting w/o block)
                    + fixed WIN and APP key events (ignore them)

    v2.01/02.04.97  maintenance
                    + added callback
                        FixedList
                    + fixed video output (GotoXY -> VGotoXY)

    v2.00/24.10.96  adaption to TSE32
                    + moved painting related stuff to external module
                        (dialog.s finally became too big for TSE16)
                    + added API functions
                        MoveCntrl
                    + added conditional trace code (c.f. DbgTrace.S)
                    + added buffered video output (TSE32 only)
                    + restored error messages
                    + enhanced string sizes (255 characters)
                    + optimzed usage of macro stack
                    + fixed some key definitions
                    + fixed EquateEnhancedKbd settings
                    + some cleanup of source code
                        mainly compatibility
                        conditional use of TSE's new features

    v1.22/18.06.96  maintenance
                    + fixed handling of rejected events
                    + shortened error messages to accommodate new code

    v1.21/29.05.96  maintenance
                    + added callbacks
                        RightClk, Context
                    + added optional right button context menus
                    + shortened error messages to accommodate new code

    v1.20/25.03.96  maintenance
                    + added callbacks
                        EditSetMark, EditKill
                    + added API functions
                        GetEvent
                        InitMouseLoop
                        MouseClick, MouseDoubleClick
                        MouseXOffset, MouseYOffset
                    + enhanced EditControl
                        full mouse and clipboard support
                        CUA style shift marking and pop up menu
                    + enhanced ComboBox
                        automatically opens when clicked with the mouse
                    + added and fixed event keys
                    + fixed CallBack routine (buffer positioning)
                    + fixed Frame (zero length titles)
                    + fixed ScrEdge (state normal painting)
                    + fixed RadioButton (focus messages)
                    + fixed EditControl (even more quirks)
                    + fixed DlgPaintWindow and DlgShowWindow (lost focus)
                    + fixed mouse dragging (return to previous control)
                    + fixed handling of horizontal scroll parameters
                    + fixed main event loop (handling of unresolved events)
                    + fixed activating first control (could not be disabled)
                    + some cleanup of source code

    v1.10/12.01.96  maintenance
                    + enhanced re-entrance
                        lib stays resident after ref-count drops to zero
                    + added and enchanced callbacks
                        Idle, Event, EditSetIndex, EditChanged
                    + added API functions
                        GetVersion, ShowWindow, PaintWindow,
                        GetHint, Get/SetHScroll, GetRefCount
                    + added configuration interface
                        double click delay, unload library, colors
                    + added history items deletion (<Del>)
                    + fixed SelChanged message (elevator scrolling)
                    + fixed quirks of EditControl
                    + some cleanup of source code

    v1.00/11.10.95  first version
                    + fully re-entrant
                    + fully mouse driven
                    + predefined control types
                        + static text and frames
                        + edit controls and history lists
                        + radio buttons, check boxes and push buttons
                        + drop down lists, list boxes and scroll bars
                    + user defined controls
                    + automatic hints at help line
                    + disable and re-enable controls
                    + change control titles and data
                    + all basic notification messages

    Limitations:

    + works in color mode only
    + mouse scrolling is hard coded (18 lines per second)

    Acknowledgements:

    + thanks to Chris Antos for suggestions and finding some bugs

\****************************************************************************/

/****************************************************************************\
    use global variable DlgMsgText
\****************************************************************************/

#define INC_MSGTEXT 1

/****************************************************************************\
    symbolic constants
\****************************************************************************/

#include "dialog.si"

/****************************************************************************\
    use the windows clipboard copy & paste
\****************************************************************************/

#include "scwinclp.si"

/****************************************************************************\
    version dependant constants

    note:   cannot use new constants due to bug in sc v2.50
\****************************************************************************/

constant _ALT_KEY                   = 4         // new sc32 constant
constant _ON_NONEDIT_UNASSIGNED_KEY = 26        // ditto

#ifdef WIN32

constant _SHIFT_KEY         = _LEFT_SHIFT_KEY_
constant _ALT_CURSOR_UP     = <Alt CursorUp>
constant _ALT_CURSOR_DOWN   = <Alt CursorDown>

#else

constant _SHIFT_KEY         = _LEFT_SHIFT_KEY_ | _RIGHT_SHIFT_KEY_
constant _ALT_CURSOR_UP     = <Alt GreyCursorUp>
constant _ALT_CURSOR_DOWN   = <Alt GreyCursorDown>

#endif

#if EDITOR_VERSION < 0x3000

constant _WHEEL_UP          = <CtrlAlt GreyCursorUp>
constant _WHEEL_DOWN        = <CtrlAlt GreyCursorDown>

#else
#if EDITOR_VERSION < 0x4000

constant _WHEEL_UP          = <CtrlAlt CursorUp>
constant _WHEEL_DOWN        = <CtrlAlt CursorDown>

#else

constant _WHEEL_UP          = <WheelUp>
constant _WHEEL_DOWN        = <WheelDown>

#endif
#endif

/****************************************************************************\
    communication with paint module

    note:   The global variable DlgPaintState is used to communicate
            integer values between Dialog and DialogP in order to
            minimize dialogs impact on TSE's macro stack. It helps
            to save from 257 to 771 bytes of temporary stack space
            per nested dynamic call.
\****************************************************************************/

string Paint[] = "DialogP"                      // name of paint module
string DlgPaintState[] = "DlgPaintState"        // name of argument var

/****************************************************************************\
    configuration info
\****************************************************************************/

integer  MOUSE_DBL_TIME = 9             // double click threshold
integer  UNLOAD_LIBRARY = FALSE         // unload when dialog terminates

/****************************************************************************\
    global variables
\****************************************************************************/

integer dlg_stack                       // buffer id (recursion stack)
integer dlg_setup                       // ditto (dialog configuration info)
integer lst_null                        // ditto (painting empty lists)
integer ref_count                       // depth of nested calls

#ifndef WIN32

integer alt_keys                        // buffer id (hot key translation)

#endif

/****************************************************************************\
    stacked variables
\****************************************************************************/

string  dlg_name[16]                    // name of parent macro
integer resource                        // buffer id (dialog resource)
integer dlg_data                        // ditto (dialog data)
integer edt_hist                        // ditto (edit history)

integer ret_code                        // return code
integer terminate                       // flag (user terminated dialog)
integer dlg_open                        // ditto (dialog window is open)
integer prev_cntrl                      // previously focused control type
integer prev_focus                      // previously focused control
integer curr_event                      // most recent user input

integer hscroll_page                    // horizontal list page
integer hscroll_size                    // maximum horizontal list length

/****************************************************************************\
    global temps (not stacked)
\****************************************************************************/

integer drop_down                       // flag (drop down list message count)
integer glob_hist                       // ditto (hist-id for drop down list)

integer double                          // mouse double click flag
integer ticks                           // clock ticks (mouse double clicks)
integer center = TRUE                   // center dialogs horizontally

/****************************************************************************\
    hot key translation table
\****************************************************************************/

#ifndef WIN32

datadef alt_key_table
    "810"
    "781"
    "792"
    "7A3"
    "7B4"
    "7C5"
    "7D6"
    "7E7"
    "7F8"
    "809"
    "1EA"
    "30B"
    "2EC"
    "20D"
    "12E"
    "21F"
    "22G"
    "23H"
    "17I"
    "24J"
    "25K"
    "26L"
    "32M"
    "31N"
    "18O"
    "19P"
    "10Q"
    "13R"
    "1FS"
    "14T"
    "16U"
    "2FV"
    "11W"
    "2DX"
    "15Y"
    "2CZ"
end

#endif

/****************************************************************************\
    forward definitions
\****************************************************************************/

forward integer proc Open(integer init)
forward proc Close()
forward proc PaintControl(integer state)
forward proc ExecControl()
forward public proc DlgInitMouseLoop()
forward public proc DlgMouseClick()
forward public proc DlgMouseDoubleClick()

/****************************************************************************\
    shared code (also used by DialogP.S)
\****************************************************************************/

#include "scpaint.si"

/****************************************************************************\
    helper: isTypeableKey
\****************************************************************************/

#ifndef WIN32

integer proc isTypeableKey( integer code )
    integer char = LoByte(code)

    return( 31 < char and char < 240 or HiByte(code) == 0 )
end

#endif

/****************************************************************************\
    tracing data and helper routines
\****************************************************************************/

#ifdef TRACE

integer TracePointKey
string DbgTraceArgs[] = "DbgTraceArgs"

string DBG_ERROR[] = "Cannot load trace macro. Terminating."

integer proc LoadDbgTrace()
    if not isMacroLoaded("DbgTrace")
        if not LoadMacro("DbgTrace")
            Warn(DBG_ERROR)
            PurgeMacro(CurrMacroFilename())
            return(TRUE)
        endif
    endif
    ExecMacro(Format("SetTraceCharPos ",POS_ID))
    ExecMacro("GetTracePointKey")
    TracePointKey = Val(Query(MacroCmdLine))
    return(FALSE)
end

proc StartDbgTrace()
    SetGlobalStr(DbgTraceArgs,'Dialog_Main '+Query(MacroCmdLine))
    PressKey(TracePointKey)
end

#endif

/****************************************************************************\
    helper: error messages
\****************************************************************************/

constant ERR_WIN  = 1
constant ERR_MEM  = 2
constant ERR_NAME = 3
constant ERR_RES  = 4
constant ERR_CTRL = 5
constant ERR_MOD  = 6

proc ErrorMessage( integer msg )
    string text[64]

    case msg
        when ERR_WIN    text = "Cannot open dialog window."
        when ERR_MEM    text = "Cannot create working buffer."
        when ERR_NAME   text = "No parent name provided."
        when ERR_RES    text = "Invalid dialog resource."
        when ERR_CTRL   text = "No active control found."
        when ERR_MOD    text = "Cannot load modules."
    endcase
    Alarm()
    Warn("Dialog: ",text)
end

/****************************************************************************\
    helper: stack saving routines

    note:   The following routines are used only to minimize the impact of
            dialogs on TSE's macro stack. Catenating strings (+, Format)
            and executing macros (ExecMacro) always force temporary
            string variables on TSE's macro stack. Using these routines
            saves 257 to 514 bytes per recursive callback in many cases.
            This is especially true for the Exec and PaintControl routines.
            Stack savings can amount to several kBytes in the case of
            nested dialogs.
\****************************************************************************/

string catenated_string[255]

proc CatStrInt( string s, integer i )
    catenated_string = Format(s," ",i)
end

proc DlgExecMacro( string call )
    ExecMacro(call)
end

/****************************************************************************\
    helper: call back parent macro

    note:   This routine has been optimized to minimize its impact
            on TSE's macro stack and as such isn't designed to win
            an award for good structured programming.

    note:   Do NOT use catenated_string instead of cb_text_buff.
            It gets overwritten by recursive callbacks.
\****************************************************************************/

string cb_text_buff[255]

integer proc CallBack( string call )
    integer bid, rc

    bid = GotoBufferId(resource)
    cb_text_buff = dlg_name + call
    rc = Pos(" ",cb_text_buff)
    if rc
        cb_text_buff = cb_text_buff[1..rc-1]
    endif
    rc = isMacroLoaded(cb_text_buff)
    cb_text_buff = dlg_name + call
    rc = rc and ExecMacro(cb_text_buff)
    GotoBufferId(bid)
    return (rc)
end

/****************************************************************************\
    helper: get next event
\****************************************************************************/

integer proc GetEvent( integer level )
    repeat
        if KeyPressed() or Query(KbdMacroRunning)

            // fix drop down count

            drop_down = Max(0,drop_down-1)

            // get, filter and return event

            GetKey()
            if Query(Key) <> 0x8000
                CatStrInt("Event",level)
                CallBack(catenated_string)
                return (Query(Key))
            endif

        else

            // idle call to enable background activities

            CatStrInt("Idle",level)
            CallBack(catenated_string)

        endif
    until terminate
    return (KEY_NOTHING)
end

/****************************************************************************\
    helper: find specific control
\****************************************************************************/

integer proc FindCntrl( integer cntrl, string opts )
    integer rc

    MarkColumn(1,POS_CNTRL,NumLines(),POS_CNTRL)
    rc = lFind(Chr(cntrl),opts)
    UnmarkBlock()
    return (rc)
end

/****************************************************************************\
    helper: set control data
\****************************************************************************/

proc SetCntrlData( string data )
    integer line = CurrLine()

    GotoBufferId(dlg_data)
    GotoLine(line)
    BegLine()
    KillToEol()
    InsertText(data)
    GotoBufferId(resource)
end

/****************************************************************************\
    helper: get and set control title and hint
\****************************************************************************/

proc GetHotKey( var string title, var string htkey, var integer hkpos )
    hkpos = Pos("&",title)
    if hkpos
        htkey = title[hkpos+1]
        title = DelStr(title,hkpos,1)
    else
        htkey = " "
    endif
end

proc SetCntrlTitle( string title, string htkey, integer hkpos )
    string hint[255] = ""

    GetCntrlHint(hint)
    GotoPos(POS_HKPOS)
    KillToEol()
    InsertText(Format(Chr(hkpos),htkey[1],title,Chr(END_OF_TITLE),hint))
end

proc SetCntrlHint( string hint )
    string title[255] = ""

    GetCntrlTitle(title)
    GotoPos(POS_TITLE)
    KillToEol()
    InsertText(Format(title,Chr(END_OF_TITLE),hint))
end

/****************************************************************************\
    helper: mouse control
\****************************************************************************/

integer proc MouseDoubleClick()
    double = ticks
        and Query(MouseX) == Query(LastMouseX)
        and Query(MouseY) == Query(LastMouseY)
        and GetClockTicks() - ticks <= MOUSE_DBL_TIME
    if double
        ticks = 0
    else
        ticks = GetClockTicks()
    endif
    return (double)
end

integer proc MouseHitTitleBar()
    integer xm = Query(MouseX)
    integer ym = Query(MouseY)

    return (
        CurrChar(POS_Y1) == ym and
        CurrChar(POS_X1) <= xm and xm <= CurrChar(POS_X2)
    )
end

integer proc MouseHitFirstLine()
    integer xm = Query(MouseX) - Query(PopWinX1) + 1
    integer ym = Query(MouseY) - Query(PopWinY1) + 1

    return (
        CurrChar(POS_Y1) == ym and
        CurrChar(POS_X1) <= xm and xm < CurrChar(POS_X2)
    )
end

integer proc MouseHit()
    integer xm = Query(MouseX) - Query(PopWinX1) + 1
    integer ym = Query(MouseY) - Query(PopWinY1) + 1

    return (
        CurrChar(POS_X1) <= xm and xm < CurrChar(POS_X2) and
        CurrChar(POS_Y1) <= ym and ym < CurrChar(POS_Y2)
    )
end

integer proc MouseDrag()
    integer clr_drag
    integer dx, dy
    integer x1 = Query(PopWinX1) - 1
    integer y1 = Query(PopWinY1) - 1
    integer xl = Query(PopWinCols) + 1
    integer yl = Query(PopWinRows) + 1

    // get color value

    DlgExecMacro("DlgPaintGetColorDragging")
    clr_drag = Val(Query(MacroCmdLine))

    // show and move dummy frame

    if not PopWinOpen(x1,y1,x1+xl,y1+yl,1,"",clr_drag)
        ErrorMessage(ERR_WIN)
        return (TRUE)
    endif
    while MouseKeyHeld()
        if KeyPressed() and GetKey() == <Escape>
            PopWinClose()
            return (TRUE)
        endif
        dx = Query(MouseX) - Query(LastMouseX)
        dy = Query(MouseY) - Query(LastMouseY)
        if dx or dy
            x1 = Min(Max(1,x1+dx),Query(ScreenCols)-xl)
            y1 = Min(Max(1,y1+dy),Query(ScreenRows)-yl)
            PopWinClose()
            if not PopWinOpen(x1,y1,x1+xl,y1+yl,1,"",clr_drag)
                ErrorMessage(ERR_WIN)
                return (TRUE)
            endif
        endif
    endwhile
    PopWinClose()

    // close and re-open dialog

    Close()
    GotoPos(POS_X1)
    InsertText(Chr(x1)+Chr(y1)+Chr(x1+xl)+Chr(y1+yl),_OVERWRITE_)
    return (Open(FALSE))
end

/****************************************************************************\
    helper: scroll bar movement
\****************************************************************************/

integer proc ScrollElevator()
    if CurrChar(POS_CNTRL) == CNTRL_VSCROLL
        return (Query(MouseY) <> Query(LastMouseY))
    endif
    return (Query(MouseX) <> Query(LastMouseX))
end

integer proc GetScrollEvent( integer event )
    if CurrChar(POS_CNTRL) == CNTRL_VSCROLL
        case event
            when SCROLL_UP      return(<CursorUp>)
            when SCROLL_DN      return(<CursorDown>)
            when SCROLL_PGUP    return(<PgUp>)
        endcase
        return(<PgDn>)
    endif
    case event
        when SCROLL_UP      return(<CursorLeft>)
        when SCROLL_DN      return(<CursorRight>)
        when SCROLL_PGUP    return(<Ctrl CursorLeft>)
    endcase
    return(<Ctrl CursorRight>)
end

integer proc CalcScrollPos( integer olen, integer ipos, integer ilen )
    if ipos == ilen
        return (olen)
    endif
    return (olen * (ipos-1) / ilen + 1)
end

proc FindList()
    PushPosition()
    Up()
    if CurrChar(POS_CNTRL) in CNTRL_VSCROLL,CNTRL_HSCROLL
        Up()
    endif
end

integer proc GetScrollPos( integer slen )
    integer dpos = 1
    integer dlen = 1
    integer scroll = CurrChar(POS_CNTRL)

    if slen > 0
        FindList()
        if CurrChar(POS_CNTRL) == CNTRL_LIST
            if GotoBufferId(GetCntrlDataInt())
                if scroll == CNTRL_VSCROLL
                    dpos = CurrLine()
                    dlen = NumLines()
                else
                    dpos = CurrXOffset()
                    dlen = hscroll_size
                endif
            endif
        else
            if CallBack(Format("GetListPos ",scroll))
                dpos = Val(Query(MacroCmdLine))
            endif
            if CallBack(Format("GetListLen ",scroll))
                dlen = Val(Query(MacroCmdLine))
            endif
        endif
        PopPosition()
    endif
    return ( CalcScrollPos(slen,dpos,dlen) )
end

proc SetScrollPos( integer spos, integer slen )
    integer dlen = 1
    integer scroll = CurrChar(POS_CNTRL)

    if slen > 0
        FindList()
        if CurrChar(POS_CNTRL) == CNTRL_LIST
            if GotoBufferId(GetCntrlDataInt())
                if scroll == CNTRL_VSCROLL
                    dlen = CalcScrollPos(NumLines(),spos,slen)
                    GotoLine(dlen)
                else
                    dlen = CalcScrollPos(hscroll_size,spos,slen)
                    GotoPos(dlen+Query(ScreenCols))
                    GotoPos(dlen)
                endif
            endif
        else
            if CallBack(Format("GetListLen ",scroll))
                dlen = Val(Query(MacroCmdLine))
            endif
            dlen = CalcScrollPos(dlen,spos,slen)
            CallBack(Format("SetListPos ",scroll," ",dlen))
        endif
        PopPosition()
    endif
end

proc MouseScroll( integer len )
    integer first_loc, mouse_loc, elevator
    integer wait, event

    if CurrLine() <= 2
        return ()
    endif
    FindList()
    DlgExecMacro("DlgPaintHint")
    PopPosition()

    wait = Query(MouseHoldTime)
    first_loc = MouseLocation()
    elevator = GetScrollPos(len) + 1

    if first_loc == elevator

        PaintControl(STATE_ACTIVE)
        repeat
            mouse_loc = first_loc
            first_loc = MouseLocation()
            if ScrollElevator() and 1 < first_loc and first_loc < len+2
                SetScrollPos(first_loc-1,len)
                FindList()
                PaintControl(STATE_ACTIVE)
                PopPosition()
                PaintControl(STATE_ACTIVE)
            endif
        until not MouseKeyHeld()
        PaintControl(STATE_NORMAL)

        FindList()
        CallBack("SelChanged")
        PopPosition()

    else

        if first_loc == 1
            event = GetScrollEvent(SCROLL_UP)
        elseif first_loc == len+2
            event = GetScrollEvent(SCROLL_DN)
        elseif first_loc < elevator
            event = GetScrollEvent(SCROLL_PGUP)
        elseif first_loc > elevator
            event = GetScrollEvent(SCROLL_PGDN)
        endif

        repeat
            mouse_loc = MouseLocation()
            if MouseHit() and mouse_loc == first_loc
                curr_event = EVENT_OTHER
                PushKey(KEY_BREAK)
                PushKey(event)
                FindList()
                ExecControl()
                PopPosition()
                Delay(wait)
                if wait > 1
                    wait = 1
                endif
            endif
        until not MouseKeyHeld()

    endif

    FindList()
    KillPosition()

    PushKey(KEY_NOTHING)
end

/****************************************************************************\
    helper: group movement
\****************************************************************************/

integer proc GroupUp()
    integer move, group

    move = Up()
    group = CurrChar(POS_CNTRL) == CNTRL_GROUP
    if move and group
        Down()
    endif
    return (move and not group)
end

integer proc GroupDown()
    integer move, group

    move = Down()
    group = CurrChar(POS_CNTRL) == CNTRL_GROUP
    if move and group
        Up()
    endif
    return (move and not group)
end

proc GroupBeg( integer skip )
    FindCntrl(CNTRL_GROUP,"lb")
    if skip
        Down()
    endif
end

proc GroupEnd( integer skip )
    FindCntrl(CNTRL_GROUP,"l")
    if skip
        Up()
    endif
end

/****************************************************************************\
    helper: drop down list
\****************************************************************************/

proc KillHistItem()
    if glob_hist
        DelHistoryStr(glob_hist,CurrLine())
        KillLine()
    endif
end

proc CloseList()
    EndProcess(TRUE)
    PushKey(Query(Key))
end

keydef DropDownKeys
    <Del>                   KillHistItem()
    <Ctrl L>                RepeatFind()
    <Ctrl N>                RepeatFind()
    <Tab>                   CloseList()
    <Shift Tab>             CloseList()
    <_ALT_CURSOR_UP>        EndProcess(TRUE)
    <_ALT_CURSOR_DOWN>      EndProcess(TRUE)
    <Alt 0>                 CloseList()
    <Alt 1>                 CloseList()
    <Alt 2>                 CloseList()
    <Alt 3>                 CloseList()
    <Alt 4>                 CloseList()
    <Alt 5>                 CloseList()
    <Alt 6>                 CloseList()
    <Alt 7>                 CloseList()
    <Alt 8>                 CloseList()
    <Alt 9>                 CloseList()
    <Alt A>                 CloseList()
    <Alt B>                 CloseList()
    <Alt C>                 CloseList()
    <Alt D>                 CloseList()
    <Alt E>                 CloseList()
    <Alt F>                 CloseList()
    <Alt G>                 CloseList()
    <Alt H>                 CloseList()
    <Alt I>                 CloseList()
    <Alt J>                 CloseList()
    <Alt K>                 CloseList()
    <Alt L>                 CloseList()
    <Alt M>                 CloseList()
    <Alt N>                 CloseList()
    <Alt O>                 CloseList()
    <Alt P>                 CloseList()
    <Alt Q>                 CloseList()
    <Alt R>                 CloseList()
    <Alt S>                 CloseList()
    <Alt T>                 CloseList()
    <Alt U>                 CloseList()
    <Alt V>                 CloseList()
    <Alt W>                 CloseList()
    <Alt X>                 CloseList()
    <Alt Y>                 CloseList()
    <Alt Z>                 CloseList()
end

proc DropDownHook()
    Enable(DropDownKeys)
    Unhook(DropDownHook)
end

integer proc ShowDropDown( integer x1, integer y1, integer x2, integer y2 )
    integer opts = _ENABLE_HSCROLL_|_ENABLE_SEARCH_
    integer cl, rc
    integer top, len, lft, wdt
    string cmd[64]

    DlgExecMacro("DlgPaintDropInit")

    wdt = x2 - x1 + 1
    len = y2 - y1 - 3
    lft = Query(PopWinX1) + x1 - 1
    top = Query(PopWinY1) + y1
    if top+len > Query(ScreenRows)
        top = Query(ScreenRows) - len - 1
    endif

    if CallBack("AnchorList") and Query(MacroCmdLine) == "1"
        opts = opts | _ANCHOR_SEARCH_
    endif

    if CallBack("FixedList") and Query(MacroCmdLine) == "1"
        opts = opts | _FIXED_HEIGHT_
    endif

    if CallBack(Format("DropDown ",lft," ",top," ",wdt," ",len))
        cmd = Query(MacroCmdLine)
        lft = Val(GetToken(cmd," ",1))
        top = Val(GetToken(cmd," ",2))
        wdt = Val(GetToken(cmd," ",3))
        len = Val(GetToken(cmd," ",4))
    endif

    Set(X1,lft)
    Set(Y1,top)
    Hook(_LIST_STARTUP_,DropDownHook)

    cl = CurrLine()
    rc = lList("",wdt,len,opts)
    if not rc
        GotoLine(cl)
        if Query(Key) == <LeftBtn>
            drop_down = 2
            MouseStatus()
            PushKey(<LeftBtn>)
        endif
    endif

    if rc
        CallBack("SelChanged")
    endif
    CallBack("CloseUp")

    DlgExecMacro("DlgPaintDropDone")

    return (rc)
end

/****************************************************************************\
    control: dialog
\****************************************************************************/

integer proc CloseBoxHit()
    integer rc
    integer xp
    integer xm = Query(MouseX)

    PushPosition()
    rc = FindCntrlWithId(Str(ID_CANCEL))
    BegFile() // goto dialog control

#if EDITOR_VERSION <= 0x3000
    xp = CurrChar(POS_X1)
    rc = rc and xp+2 <= xm and xm <= xp+4
#else
    xp = CurrChar(POS_X2) - 3
    rc = rc and xp <= xm and xm <= xp+2
#endif

    PopPosition()
    return(rc)
end

integer proc GotoDialog()
    return ( curr_event in EVENT_TAB,EVENT_MOUSE )
end

proc ExecDialog()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'ExecDialog')
    PressKey(TracePointKey)
#endif

    case curr_event
        when EVENT_MOUSE
            if CloseBoxHit()
                terminate = TRUE
                ret_code = ID_CANCEL
            else
                MouseDrag()
                PushKey(KEY_RETURN)
            endif
        when EVENT_TAB
            PushKey(Query(Key))
    endcase
end

/****************************************************************************\
    control: plain text
\****************************************************************************/

integer proc GotoText()
    return (curr_event in EVENT_TAB,EVENT_HTKEY)
end

proc ExecText()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'ExecText')
    PressKey(TracePointKey)
#endif

    case curr_event
        when EVENT_TAB
            PushKey(Query(Key))
        when EVENT_HTKEY
            PushKey(<Tab>)
    endcase
end

/****************************************************************************\
    control: open list
\****************************************************************************/

integer proc GotoOpen()
    return (curr_event in EVENT_TAB,EVENT_MOUSE)
end

proc ExecOpen()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'ExecOpen')
    PressKey(TracePointKey)
#endif

    case curr_event
        when EVENT_TAB
            PushKey(Query(Key))
        when EVENT_MOUSE
            if not (drop_down and prev_focus == CurrLine()-1)
                PushKey(_ALT_CURSOR_DOWN)
            endif
            PushKey(<Shift Tab>)
    endcase
end

/****************************************************************************\
    control: edit control
\****************************************************************************/

integer proc GotoEdit()
    return (curr_event <> EVENT_GROUP)
end

proc ShowHistory( var string text )
    integer i, hist
    integer x1 = CurrChar(POS_X1)
    integer x2 = CurrChar(POS_X2)
    integer y1 = CurrChar(POS_Y1)
    integer y2 = CurrChar(POS_Y2)

    hist = GetCntrlDataInt()
    if not hist
        return ()
    endif

    GotoBufferId(edt_hist)
    for i = NumHistoryItems(hist) downto 1
        InsertLine(GetHistoryStr(hist,i))
    endfor
    lFind(text,"gi")

    glob_hist = hist
    if ShowDropDown(x1,y1,x2,y2)
        text = GetText(1,CurrLineLen())
    endif
    glob_hist = 0

    EmptyBuffer()
    GotoBufferId(resource)
end

proc GetClipboard( var string text, var integer index )
    GotoBufferId(Query(ClipBoardId))
#ifdef USE_WIN_CLIP
    if isWinClipAvailable()
        EmptyBuffer()
        PushBlock()
        PasteFromWinClip()
        PopBlock()
    endif
#endif
    BegFile()
    text = InsStr(GetText(1,CurrLineLen()),text,index)
    index = index + CurrLineLen()
    GotoBufferId(resource)
end

proc SetClipboard( string text )
    GotoBufferId(Query(ClipBoardId))
    EmptyBuffer()
    InsertText(text)
#ifdef USE_WIN_CLIP
    PushBlock()
    MarkChar()
    BegLine()
    CopyToWinClip()
    EndLine()
    PopBlock()
#endif
    GotoBufferId(resource)
end

integer proc ScanWordLeft( integer index, string text )
    string wordset[32] = Query(WordSet)

    if index > 1
        repeat
            index = index - 1
        until index == 1 or GetBit(wordset,Asc(text[index]))
        if index > 1
            while index > 1 and GetBit(wordset,Asc(text[index]))
                index = index - 1
            endwhile
            if not GetBit(wordset,Asc(text[index]))
                index = index + 1
            endif
        endif
    endif
    return (index)
end

integer proc ScanWordRight( integer index, string text )
    string wordset[32] = Query(WordSet)

    if index <= Length(text)
        while index <= Length(text) and GetBit(wordset,Asc(text[index]))
            index = index + 1
        endwhile
        while index <= Length(text) and not GetBit(wordset,Asc(text[index]))
            index = index + 1
        endwhile
    endif
    return (index)
end

proc SetCaret( var integer caret, var integer start,
                            integer field, integer index )
    field = field - 1
    caret = index - start
    if caret < 0
        caret = 0
        start = Max(1,index)
    elseif caret > field
        caret = field
        start = index - field
    endif
end

integer proc MouseIndex( integer textlen, integer start )
    integer index

    index = start + Query(MouseX) - Query(PopWinX1) - CurrChar(POS_X1) + 1
    return( Max(1, Min( index, textlen+1 )))
end

integer proc CuaMark( var integer mark_beg, var integer mark_end,
                            integer old_mark_beg, integer old_mark_end,
                            integer index, integer new_index )

    if MouseKeyHeld() or (GetKeyFlags() & _SHIFT_KEY)
        if old_mark_beg <> old_mark_end
            if index == old_mark_beg
                mark_beg = new_index
                mark_end = old_mark_end
            else
                mark_beg = old_mark_beg
                mark_end = new_index
            endif
        else
            mark_beg = index
            mark_end = new_index
        endif
        if mark_beg > mark_end
            index = mark_beg
            mark_beg = mark_end
            mark_end = index
        endif
    endif
    return (new_index)
end

integer proc DelMark( var string new_text, var string old_text,
                            integer mark_beg, integer mark_end,
                            integer def_beg, integer def_end)

    if mark_beg == mark_end
        mark_beg = def_beg
        mark_end = def_end
    endif
    mark_end = mark_end - mark_beg
    old_text = SubStr(new_text,mark_beg,mark_end)
    new_text = DelStr(new_text,mark_beg,mark_end)
    return (mark_beg)
end

menu EditMenu()
    "C&ut"
    "&Copy"
    "&Paste"
    "&Delete"
end

proc DoEditMenu(integer is_key)
    if is_key
        Set(X1, Query(PopWinX1) + CurrChar(POS_X1) - 1)
        Set(Y1, Query(PopWinY1) + CurrChar(POS_Y1) - 1)
    else
        Set(X1, Query(MouseX) - 1)
        Set(Y1, Query(MouseY) - 1)
    endif
    EditMenu()
    case MenuOption()
        when 1  PushKey(<Shift Del>)
        when 2  PushKey(<Ctrl Ins>)
        when 3  PushKey(<Shift Ins>)
        when 4  PushKey(<Del>)
    endcase
end

proc ExecEdit()
    integer code, char
    integer mark_beg, mark_end
    integer old_mark_beg, old_mark_end
    integer caret, start, field, index, new_index
    integer x1 = CurrChar(POS_X1)
    integer y1 = CurrChar(POS_Y1)
    string text[255] = "", new_text[255], undo_text[255] = ""

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'ExecEdit')
    PressKey(TracePointKey)
#endif

    // init data

    GetCntrlTitle(text)
    field = CurrChar(POS_X2) - x1
    index = Length(text) + 1
    start = 1
    mark_beg = 1
    mark_end = index

    // ask caller for initial indexes

    if CallBack("EditSetIndex")
        new_index = Val(Query(MacroCmdLine))
        if 1 <= new_index and new_index <= index
            index = new_index
            mark_beg = mark_end
        endif
    endif

    if CallBack("EditSetMark")
        new_text = Query(MacroCmdLine)
        old_mark_beg = Val(GetToken(new_text," ",1))
        if old_mark_beg
            mark_beg = old_mark_beg
            mark_end = Val(GetToken(new_text," ",2))
        endif
    endif

    // let's go

    Set(Cursor,ON)
    DlgInitMouseLoop()

    loop

        // set caret and paint string

        SetCaret(caret,start,field,index)
        GotoXY(x1+caret,y1)

        SetGlobalInt(DlgPaintState,
            Max(0,mark_beg-start) |
            Min(mark_end-start,field) shl 16 )
        SetGlobalStr(DlgMsgText,text[start:field])
        DlgExecMacro("DlgPaintEditInput")

        // backup and prepare data

        old_mark_beg = mark_beg
        old_mark_end = mark_end
        mark_beg = mark_end

        index = start + caret
        new_text = text
        new_index = index

        // get next event

        code = GetEvent(1)
        char = -code

        case code

        // termination codes

            when KEY_BREAK,KEY_NOTHING,<Escape>,<Enter>,<Tab>,<Shift Tab>
                break

        // history drop down

            when <CursorUp>,<CursorDown>,<_ALT_CURSOR_UP>,<_ALT_CURSOR_DOWN>
                ShowHistory(new_text)
                mark_beg = 1
                mark_end = Length(new_text) + 1
                new_index = mark_end

        // moving, marking and editing via rodent

            when <LeftBtn>
                if MouseHitFirstLine()
                    new_index = MouseIndex(Length(text),start)
                    PushKey(MOUSE_MARK)
                else
                    break
                endif
            when MOUSE_MARK
                if MouseKeyHeld()
                    new_index = CuaMark(
                        mark_beg,mark_end,
                        old_mark_beg,old_mark_end,index,
                        MouseIndex(Length(text),start))
                    PushKey(MOUSE_MARK)
                    Delay(1)
                else
                    mark_beg = old_mark_beg
                endif

        // context menu

            when <RightBtn>
                if MouseHitFirstLine()
                    DoEditMenu(FALSE)
                    mark_beg = old_mark_beg
                else
                    break
                endif
            when <Alt F10>, <Shift F10>
                DoEditMenu(TRUE)
                mark_beg = old_mark_beg

        // cursor movement and cua style marking

            when <Home>,<Shift Home>
                new_index = CuaMark(
                    mark_beg,mark_end,
                    old_mark_beg,old_mark_end,index,
                    1)
            when <End>,<Shift End>
                new_index = CuaMark(
                    mark_beg,mark_end,
                    old_mark_beg,old_mark_end,index,
                    Length(new_text) + 1)
            when <CursorLeft>,<Shift CursorLeft>
                if index > 1
                    new_index = CuaMark(
                        mark_beg,mark_end,
                        old_mark_beg,old_mark_end,index,
                        index - 1)
                elseif GetKeyFlags() & _SHIFT_KEY
                    mark_beg = old_mark_beg
                endif
            when <CursorRight>,<Shift CursorRight>
                if index <= Length(new_text)
                    new_index = CuaMark(
                        mark_beg,mark_end,
                        old_mark_beg,old_mark_end,index,
                        index + 1)
                elseif GetKeyFlags() & _SHIFT_KEY
                    mark_beg = old_mark_beg
                endif
            when <Ctrl CursorLeft>,<CtrlShift CursorLeft>
                new_index = CuaMark(
                    mark_beg,mark_end,
                    old_mark_beg,old_mark_end,index,
                    ScanWordLeft(index,new_text))
            when <Ctrl CursorRight>,<CtrlShift CursorRight>
                new_index = CuaMark(
                    mark_beg,mark_end,
                    old_mark_beg,old_mark_end,index,
                    ScanWordRight(index,new_text))

        // basic editor operations

            when <GreyIns>,<Ins>
                Toggle(Insert)
            when <Alt Backspace>
                new_text = InsStr(undo_text,new_text,index)
                new_index = Min(SizeOf(new_text), index + Length(undo_text))
                mark_beg = index
                mark_end = new_index
            when <Del>
                new_index = DelMark(
                    new_text,undo_text,
                    old_mark_beg,old_mark_end,
                    index,index+1)
            when <BackSpace>
                new_index = DelMark(
                    new_text,undo_text,
                    old_mark_beg,old_mark_end,
                    index-1,index)
            when <Ctrl Home>
                new_index = DelMark(
                    new_text,undo_text,
                    old_mark_beg,old_mark_end,
                    1,index)
            when <Ctrl End>
                new_index = DelMark(
                    new_text,undo_text,
                    old_mark_beg,old_mark_end,
                    index,255)
            when <Ctrl BackSpace>
                new_index = ScanWordLeft(index,new_text)
                new_index = DelMark(
                    new_text,undo_text,
                    old_mark_beg,old_mark_end,
                    new_index,index)
            when <Ctrl Del>
                new_index = ScanWordRight(index,new_text)
                new_index = DelMark(
                    new_text,undo_text,
                    old_mark_beg,old_mark_end,
                    index,new_index)

        // clipboard access

            when <Shift Del>,<Ctrl X>
                new_index = DelMark(
                    new_text,undo_text,
                    old_mark_beg,old_mark_end,
                    1,Length(new_text)+1)
                SetClipboard(undo_text)
            when <Ctrl GreyIns>,<Ctrl Ins>,<Ctrl C>
                if old_mark_beg
                    SetClipboard(SubStr(new_text,old_mark_beg,old_mark_end-1))
                else
                    SetClipboard(text)
                endif
            when <Shift GreyIns>,<Shift Ins>,<Ctrl V>
                new_index = DelMark(
                    new_text,undo_text,
                    old_mark_beg,old_mark_end,
                    index,index)
                GetClipboard(new_text,new_index)

        // insert/overtype characters

            otherwise
                char = LoByte(code)
                if isTypeableKey(code)
                    new_index = DelMark(
                        new_text,undo_text,
                        old_mark_beg,old_mark_end,
                        index, index + (not Query(Insert)))
                    new_text = InsStr(Chr(char),new_text,new_index)
                    new_index = new_index + 1
                else
                    break
                endif
        endcase

        // ask, if changes are acceptable

        new_index = Min(new_index,SizeOf(new_text))
        SetGlobalStr(DlgMsgText,text)
        code = CallBack(Format("EditChanged ",index," ",char," ",text))
        if not code or Query(MacroCmdLine) == "1"
            text = new_text
            index = new_index
        else
            mark_beg = old_mark_beg
            mark_end = old_mark_end
        endif
    endloop

    // inform caller about state of indexes

    CallBack(Format("EditKill ",index," ",old_mark_beg," ",old_mark_end))

    // let's call it quits

    Set(Cursor,OFF)
    if code <> <Escape>
        SetCntrlTitle(text," ",0)
    endif
    if code <> KEY_BREAK
        PushKey(code)
    endif
end

/****************************************************************************\
    control: radio buttons
\****************************************************************************/

integer proc GotoRadio()
    return (TRUE)
end

proc FindStation()
    GroupEnd(TRUE)
    while not GetCntrlDataInt() and GroupUp()
    endwhile
end

proc ExecRadio()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'ExecRadio')
    PressKey(TracePointKey)
#endif

    case curr_event
        when EVENT_HTKEY, EVENT_MOUSE, EVENT_GROUP
            PushPosition()
            FindStation()
            SetCntrlData("0")
            PaintControl(STATE_NORMAL)
            PopPosition()
            SetCntrlData("1")
            CallBack("SetFocus")
            CallBack("SelChanged")
            PaintControl(STATE_ACTIVE)
        when EVENT_TAB
            if prev_cntrl == CNTRL_RADIO
                if Query(Key) == <Tab>
                    GroupEnd(FALSE)
                else
                    GroupBeg(FALSE)
                endif
                PushKey(Query(Key))
            else
                FindStation()
                if not CurrChar(POS_ENABLE)
                    PushKey(<CursorDown>)
                    return ()
                endif
                CallBack("SetFocus")
                PaintControl(STATE_ACTIVE)
            endif
    endcase
end

/****************************************************************************\
    control: check boxes
\****************************************************************************/

integer proc GotoCheck()
    return (TRUE)
end

proc ToggleCheck()
    SetCntrlData(Str(not GetCntrlDataInt()))
    PaintControl(STATE_ACTIVE)
    CallBack("BtnDown")
end

proc ExecCheck()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'ExecCheck')
    PressKey(TracePointKey)
#endif

    PaintControl(STATE_ACTIVE)
    case curr_event
        when EVENT_HTKEY, EVENT_MOUSE
            ToggleCheck()
        when EVENT_OTHER
            if Query(Key) == <Spacebar>
                ToggleCheck()
            endif
    endcase
end

/****************************************************************************\
    control: push buttons
\****************************************************************************/

integer proc GotoButton()
    return (TRUE)
end

proc PushButton( integer wait )
    PaintControl(STATE_PRESSED)
    Delay(wait)
    PaintControl(STATE_ACTIVE)
    CallBack("BtnDown")
    if CurrChar(POS_ID) == ID_CANCEL
        terminate = TRUE
    endif
end

proc ExecButton()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'ExecButton')
    PressKey(TracePointKey)
#endif

    PaintControl(STATE_ACTIVE)
    case curr_event
        when EVENT_MOUSE
            while MouseKeyHeld()
                if MouseHit()
                    PaintControl(STATE_PRESSED)
                else
                    PaintControl(STATE_ACTIVE)
                endif
            endwhile
            if MouseHit()
                PushButton(0)
            endif
        when EVENT_HTKEY
            PushButton(2)
        when EVENT_OTHER
            if Query(Key) == <SpaceBar>
                PushButton(2)
            endif
    endcase
end

/****************************************************************************\
    control: combo box
\****************************************************************************/

integer proc GotoCombo()
    return (curr_event <> EVENT_GROUP)
end

proc OpenDropDown()
    integer x1 = CurrChar(POS_X1)
    integer x2 = CurrChar(POS_X2)
    integer y1 = CurrChar(POS_Y1)
    integer y2 = CurrChar(POS_Y2)

    if GotoBufferId(GetCntrlDataInt())
        ShowDropDown(x1,y1,x2,y2)
        GotoBufferId(resource)
    endif
    PaintControl(STATE_ACTIVE)
end

proc ExecCombo()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'ExecCombo')
    PressKey(TracePointKey)
#endif

    PaintControl(STATE_ACTIVE)
    case Query(Key)
        when <LeftBtn>
            if not (drop_down and prev_focus == CurrLine())
                OpenDropDown()
            endif
        when <CursorUp>,<CursorDown>,<_ALT_CURSOR_UP>,<_ALT_CURSOR_DOWN>
            OpenDropDown()
    endcase
end

/****************************************************************************\
    control: list box
\****************************************************************************/

integer proc GotoList()
    return (curr_event <> EVENT_GROUP)
end

proc IncrementalSearch()
    integer id
    integer code = Query(Key)
    string s[32] = ""
    string opts[4] = "i"
    string options[4]

    if CallBack("AnchorList") and Query(MacroCmdLine) == "1"
        opts = opts + "^"
    endif

    PushPosition()
    loop
        options = opts
        if code == <BackSpace>
            PopPosition()
            s = s[1:Length(s)-1]
            PushPosition()
        elseif code in <Ctrl N>,<Ctrl L>
            options = "+" + options
        elseif not isTypeableKey(code)
            break
        else
            s = s + Chr(LoByte(code))
        endif
        if Length(s)
            if not lFind(s,options)
                if Query(Beep)
                    Alarm()
                endif
                if options[1] <> "+"
                    s = s[1:Length(s)-1]
                endif
                lFind(s,opts)
            endif
            MarkFoundText()
        endif
        id = GotoBufferId(resource)
        PaintControl(STATE_ACTIVE)
        GotoBufferId(id)
        UnmarkBlock()
        CallBack("SelChanged")
        code = GetEvent(2)
        if Length(s) == 0
            break
        endif
    endloop
    KillPosition()

    PushKey(code)
end

proc ExecList()
    integer code, buff
    integer scrollbar1 = 0
    integer scrollbar2 = 0
    integer y1 = CurrChar(POS_Y1)
    integer vlen = CurrChar(POS_Y2) - y1
    integer zoomed = isZoomed()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'ExecList')
    PressKey(TracePointKey)
#endif

    // maximize editing window (to correctly compute mouse coordinates)

    if not zoomed
        ZoomWindow()
    endif

    // init mouse

    DlgInitMouseLoop()

    // search scroll bars

    PushPosition()
    scrollbar1 = Down() and CurrChar(POS_CNTRL) in CNTRL_VSCROLL,CNTRL_HSCROLL
    scrollbar2 = Down() and CurrChar(POS_CNTRL) in CNTRL_VSCROLL,CNTRL_HSCROLL
    PopPosition()

    // init data

    buff = GetCntrlDataInt()
    if not GotoBufferId(buff)
        buff = lst_null
    endif

    loop

        // paint list and scroll bars

        GotoBufferId(resource)
        PaintControl(STATE_ACTIVE)
        PushPosition()
        if scrollbar1
            Down()
            PaintControl(STATE_NORMAL)
        endif
        if scrollbar2
            Down()
            PaintControl(STATE_NORMAL)
        endif
        PopPosition()

        // goto list buffer and update row position

        GotoBufferId(buff)
        ScrollToRow(CurrRow())

        // get next event

        code = GetEvent(1)
        case code

        // termination codes

            when KEY_BREAK,KEY_NOTHING
                break

        // mouse handler

            when <LeftBtn>
                DlgMouseClick()
                if Val(Query(MacroCmdLine))
                    GotoRow(Query(MouseY) - Query(PopWinY1) - y1 + 2)
                    if double
                        CallBack("DblClick")
                        code = KEY_BREAK
                        break
                    endif
                else
                    break
                endif

        // vertical movement

            when <CursorUp>, <Ctrl CursorUp>, <_WHEEL_UP>
                Up()
            when <CursorDown>, <Ctrl CursorDown>, <_WHEEL_DOWN>
                if CurrRow() == vlen
                    RollDown()
                else
                    Down()
                endif
            when <PgUp>
                if CurrLine() == CurrRow()
                    BegFile()
                else
                    RollUp(vlen-1)
                endif
            when <PgDn>
                RollDown(vlen-1)
            when <Home>, <Ctrl PgUp>
                BegFile()
            when <End>, <Ctrl PgDn>
                if GotoLine(NumLines()-vlen+1)
                    ScrollToTop()
                endif
                EndFile()

            otherwise

        // incremental search

                if isTypeableKey(code)
                    IncrementalSearch()

        // horizontal movement

                elseif scrollbar2
                    case code
                        when <CursorLeft>
                            RollLeft()
                        when <CursorRight>
                            if CurrXOffset() < hscroll_size-1
                                RollRight()
                            endif
                        when <Ctrl CursorLeft>
                            RollLeft(hscroll_page)
                        when <Ctrl CursorRight>
                            if CurrXOffset() < hscroll_size-1
                                RollRight(hscroll_page)
                            endif
                        when <Ctrl Home>
                            BegLine()
                        otherwise
                            break
                    endcase
                else
                    break
                endif
        endcase

        // inform user about changes

        CallBack("SelChanged")
    endloop

    // let's call it quits

    if code <> KEY_BREAK
        PushKey(code)
    endif
    GotoBufferId(resource)

    // restore editing window

    if not zoomed
        ZoomWindow()
    endif
end

/****************************************************************************\
    control: vertical scroll bar
\****************************************************************************/

integer proc GotoVScroll()
    return (curr_event in EVENT_TAB,EVENT_MOUSE)
end


proc ExecVScroll()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'ExecVScroll')
    PressKey(TracePointKey)
#endif

    case curr_event
        when EVENT_TAB
            PushKey(Query(Key))
        when EVENT_MOUSE
            MouseScroll(CurrChar(POS_Y2) - CurrChar(POS_Y1) - 2)
    endcase
end

/****************************************************************************\
    control: horizontal scroll bar
\****************************************************************************/

integer proc GotoHScroll()
    return (curr_event in EVENT_TAB,EVENT_MOUSE)
end

proc ExecHScroll()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'ExecHScroll')
    PressKey(TracePointKey)
#endif

    case curr_event
        when EVENT_TAB
            PushKey(Query(Key))
        when EVENT_MOUSE
            MouseScroll(CurrChar(POS_X2) - CurrChar(POS_X1) - 2)
    endcase
end

/****************************************************************************\
    paint and execute controls
\****************************************************************************/

proc PaintControl( integer state )
    integer cntrl = CurrChar(POS_CNTRL)

    if not dlg_open
        return ()
    endif
    if not CurrChar(POS_ENABLE)
        state = STATE_DISABLE
    endif
    if cntrl == CNTRL_CONTROL
        CatStrInt("PaintCntrl",state)
        CallBack(catenated_string)
    else
        SetGlobalInt(DlgPaintState,state)
        DlgExecMacro("DlgPaintStdCntrl")
    endif
end

integer proc GotoControl()
    case CurrChar(POS_CNTRL)
        when CNTRL_DIALOG               return (GotoDialog())
        when CNTRL_FRAME,CNTRL_LTEXT,
             CNTRL_RTEXT,CNTRL_CTEXT,
             CNTRL_SCREDGE,CNTRL_GROUP  return (GotoText())
        when CNTRL_OPEN                 return (GotoOpen())
        when CNTRL_EDIT                 return (GotoEdit())
        when CNTRL_DEFBTN,CNTRL_BUTTON  return (GotoButton())
        when CNTRL_RADIO                return (GotoRadio())
        when CNTRL_CHECK                return (GotoCheck())
        when CNTRL_COMBO                return (GotoCombo())
        when CNTRL_LIST                 return (GotoList())
        when CNTRL_VSCROLL              return (GotoVScroll())
        when CNTRL_HSCROLL              return (GotoHScroll())
    endcase
    CatStrInt("GotoCntrl",curr_event)
    CallBack(catenated_string)
    return (Query(MacroCmdLine) == "1")
end

proc ExecControl()
    case CurrChar(POS_CNTRL)
        when CNTRL_DIALOG               ExecDialog()
        when CNTRL_FRAME,CNTRL_LTEXT,
             CNTRL_RTEXT,CNTRL_CTEXT,
             CNTRL_SCREDGE,CNTRL_GROUP  ExecText()
        when CNTRL_OPEN                 ExecOpen()
        when CNTRL_EDIT                 ExecEdit()
        when CNTRL_DEFBTN,CNTRL_BUTTON  ExecButton()
        when CNTRL_RADIO                ExecRadio()
        when CNTRL_CHECK                ExecCheck()
        when CNTRL_COMBO                ExecCombo()
        when CNTRL_LIST                 ExecList()
        when CNTRL_VSCROLL              ExecVScroll()
        when CNTRL_HSCROLL              ExecHScroll()
    otherwise
        CatStrInt("ExecCntrl",curr_event)
        CallBack(catenated_string)
    endcase
end

/****************************************************************************\
    moving the focus
\****************************************************************************/

integer proc GoBack()
    GotoLine(prev_focus)
    return (EVENT_OTHER)
end

integer proc GotoHelp()
    PushPosition()
    if FindCntrlWithId(Str(ID_HELP)) and CurrChar(POS_ENABLE)
        CallBack("BtnDown")
    endif
    PopPosition()
    Set(Key,KEY_NOTHING)
    return (EVENT_OTHER)
end

integer proc GotoHotKey()
    integer rc = EVENT_OTHER
    integer code, char, scan
    string alt_key[1] = ""

    code = Query(Key)
    char = LoByte(code)
    scan = HiByte(code)

#ifdef WIN32

    alt_key = Lower(Chr(char))
    if not ((scan in 0,_ALT_KEY) and (char in 48..57,65..90,97..122))
        alt_key = ""
    endif

#else

    if char
        if char in Asc("0")..Asc("9"),Asc("a")..Asc("z")
            alt_key = Chr(char)
        endif
    else
        GotoBufferId(alt_keys)
        MarkColumn(1,1,NumLines(),2)
        if lFind(Format(scan:2:"0":16),"lg")
            alt_key = Chr(CurrChar(3))
        endif
        UnmarkBlock()
        GotoBufferId(resource)
    endif

#endif

    if Length(alt_key)
        MarkColumn(1,POS_HTKEY,NumLines(),POS_HTKEY)
        PushPosition()
        if lFind(alt_key,"lgi") and CurrChar(POS_ENABLE)
            KillPosition()
            rc = EVENT_HTKEY
        else
            PopPosition()
        endif
        UnmarkBlock()
    endif

    return (rc)
end

integer proc GotoMouse()
    integer hit

    PushPosition()
    BegFile()
    repeat
        case CurrChar(POS_CNTRL)
            when CNTRL_DIALOG
                hit = MouseHitTitleBar()
            when CNTRL_FRAME,CNTRL_EDIT,CNTRL_COMBO
                hit = MouseHitFirstLine()
            when CNTRL_CONTROL
                if CallBack("MouseHit")
                    hit = Query(MacroCmdLine) == "1"
                else
                    hit = MouseHit()
                endif
            otherwise
                hit = MouseHit()
        endcase
        if hit
            if CurrChar(POS_ENABLE)
                KillPosition()
                return (EVENT_MOUSE)
            else
                break
            endif
        endif
    until not Down()
    PopPosition()
    Set(Key,KEY_NOTHING)
    return (EVENT_OTHER)
end

integer proc GotoContext(integer is_key)
    integer rc

    PushPosition()
    if is_key or GotoMouse()
        if CurrChar(POS_CNTRL) == CNTRL_EDIT
            rc = TRUE
        else
            CallBack("RightClk")
            rc = Query(MacroCmdLine) == "1"
        endif
        if rc
            KillPosition()
            return (EVENT_CONTEXT)
        endif
    endif
    PopPosition()
    Set(Key,KEY_NOTHING)
    return (EVENT_OTHER)
end

integer proc GotoDefBtn()
    if CurrChar(POS_CNTRL) == CNTRL_BUTTON
        return (EVENT_HTKEY)
    endif
    PushPosition()
    if FindCntrl(CNTRL_DEFBTN,"gl") and CurrChar(POS_ENABLE)
        KillPosition()
        return (EVENT_HTKEY)
    endif
    PopPosition()
    Set(Key,KEY_NOTHING)
    return (EVENT_OTHER)
end

integer proc GotoEscBtn()
    PushPosition()
    if FindCntrlWithId(Str(ID_CANCEL)) and CurrChar(POS_ENABLE)
        KillPosition()
        return (EVENT_HTKEY)
    endif
    PopPosition()
    Set(Key,KEY_NOTHING)
    return (EVENT_OTHER)
end

integer proc GoTab( integer back )
    integer line = CurrLine()

    repeat
        if back
            if not Up()
                EndFile()
            endif
        else
            if not Down()
                BegFile()
            endif
        endif
        if CurrChar(POS_ENABLE)
            return (EVENT_TAB)
        endif
    until line == CurrLine()
    Set(Key,KEY_NOTHING)
    return (EVENT_OTHER)
end

integer proc GoGroup( integer back )
    integer line = CurrLine()

    if CurrChar(POS_GROUP)
        repeat
            if back
                if not GroupUp()
                    GroupEnd(TRUE)
                endif
            else
                if not GroupDown()
                    GroupBeg(TRUE)
                endif
            endif
            if CurrChar(POS_ENABLE)
                return (EVENT_GROUP)
            endif
        until line == CurrLine()
        Set(Key,KEY_NOTHING)
    endif
    return (EVENT_OTHER)
end

/****************************************************************************\
    moving the focus
\****************************************************************************/

integer proc MoveFocus()
    case GetEvent(0)
        when KEY_NOTHING                    return (EVENT_OTHER)
        when KEY_RETURN                     return (GoBack())
        when <F1>                           return (GotoHelp())
        when <LeftBtn>                      return (GotoMouse())
        when <RightBtn>                     return (GotoContext(FALSE))
        when <Alt F10>, <Shift F10>         return (GotoContext(TRUE))
        when <Enter>                        return (GotoDefBtn())
        when <Escape>                       return (GotoEscBtn())
        when <Tab>                          return (GoTab(FALSE))
        when <Shift Tab>                    return (GoTab(TRUE))
        when <CursorUp>,<CursorLeft>        return (GoGroup(TRUE))
        when <CursorDown>,<CursorRight>     return (GoGroup(FALSE))
    endcase
    return (GotoHotKey())
end

/****************************************************************************\
    execute dialog
\****************************************************************************/

proc Exec()
    integer temp_cntrl, temp_focus

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'Exec')
    PressKey(TracePointKey)
#endif

    // kick off the game

    PushKey(KEY_NOTHING)
    GotoLine(prev_focus)

    // main event loop

    repeat

        // reset tick count and save type of previous control

        ticks = 0
        temp_focus = CurrLine()
        temp_cntrl = CurrChar(POS_CNTRL)

        // get an event and move the focus

        curr_event = MoveFocus()
        prev_cntrl = temp_cntrl
        prev_focus = temp_focus

        // ask the control, if it accepts the event

        if GotoControl()

            // if accepted: repaint and send focus messages

            if prev_focus <> CurrLine()
                PushPosition()
                GotoLine(prev_focus)
                PaintControl(STATE_NORMAL)
                CallBack("KillFocus")
                PopPosition()
                if CurrChar(POS_CNTRL) <> CNTRL_RADIO
                    CallBack("SetFocus")
                endif
            endif

        else

            // otherwise: reset focus and clear event

            GotoLine(prev_focus)
            Set(Key,KEY_NOTHING)
            curr_event = EVENT_OTHER

        endif

        // pain hint and execute control

        DlgExecMacro("DlgPaintHint")

        if curr_event <> EVENT_CONTEXT or (CurrChar(POS_CNTRL) == CNTRL_EDIT)
            ExecControl()
        else
            CallBack("Context")
            PushKey(KEY_NOTHING)    // re-activate secondary event loops
        endif

    // repeat until user is satisfied

    until terminate

    // fix return code

    if ret_code == -1
        ret_code = CurrChar(POS_ID)
    endif
end

/****************************************************************************\
    open and close dialog window
\****************************************************************************/

integer proc Open(integer init)
    integer xx, x1, x2, y1, y2
    integer clr_normal
    string title[80] = ""

    // get color value

    DlgExecMacro("DlgPaintGetColorNormal")
    clr_normal = Val(Query(MacroCmdLine))

    // activate main dialog control

    BegFile()

    // check for height and width of editor

    x1 = CurrChar(POS_X1)
    x2 = CurrChar(POS_X2)
    y1 = CurrChar(POS_Y1)
    y2 = CurrChar(POS_Y2)

    // center dialog windows horizontally

    if init and center and not (dlg_name in "DlgEd", "DlgRes")
        xx = (Query(ScreenCols) - (x2 - x1)) / 2 + 1
        x2 = x2 + (xx - x1)
        x1 = xx
    endif

    // check for height and width of editor

    if x2 > Query(ScreenCols)
        x2 = Min(x2 - x1 + 1, Query(ScreenCols))
        x1 = 1
    endif
    if y2 > Query(ScreenRows)
        y2 = Min(y2 - y1 + 1, Query(ScreenRows))
        y1 = 1
    endif

    // store changed coordinates

    GotoPos(POS_X1)
    InsertText(Chr(x1)+Chr(y1)+Chr(x2)+Chr(y2),_OVERWRITE_)

    // open and clear pop up window

    GetCntrlTitle(title)
    if not PopWinOpen(x1, y1, x2, y2, 4, title, clr_normal)
        ErrorMessage(ERR_WIN)
        return (FALSE)
    endif

    Set(Cursor,OFF)
    Set(Attr,clr_normal)
    ClrScr()
    dlg_open = TRUE

    // paint controls and init data

#ifdef WIN32
    BufferVideo()
#endif

    repeat
        if prev_focus == CurrLine()
            PaintControl(STATE_ACTIVE)
        else
            PaintControl(STATE_NORMAL)
        endif
    until not Down()

#ifdef WIN32
    UnBufferVideo()
#endif

    // indicate success

    return (TRUE)
end

proc Close()
    PopWinClose()
    dlg_open = FALSE
end

/****************************************************************************\
    setup work space

    note:   set EquateEnhancedKbd ON and save previous value onto stack
\****************************************************************************/

integer proc Load()
    integer id, size

    // save global data onto run time stack

    id = GotoBufferId(dlg_stack)
    InsertLine(dlg_name)
    InsertLine(Str(resource))
    InsertLine(Str(dlg_data))
    InsertLine(Str(edt_hist))
    InsertLine(Str(ret_code))
    InsertLine(Str(terminate))
    InsertLine(Str(dlg_open))
    InsertLine(Str(prev_cntrl))
    InsertLine(Str(prev_focus))
    InsertLine(Str(curr_event))
    InsertLine(Str(hscroll_page))
    InsertLine(Str(hscroll_size))
    InsertLine(Str(Set(EquateEnhancedKbd,ON)))
    GotoBufferId(id)

    // save resource id and parent name and init global data

    size = NumLines()

    dlg_name = Query(MacroCmdLine)
    resource = GetBufferId()
    dlg_open = FALSE
    ret_code = -1
    terminate = FALSE

    glob_hist = 0
    drop_down = 0
    ref_count = ref_count + 1

    hscroll_page =   8
    hscroll_size = 128

    // parse macro command line

    if Length(dlg_name) == 0
        ErrorMessage(ERR_NAME)
        return (FALSE)
    endif

    // test dialog resource

    PushPosition()
    BegFile()
    if CurrChar(POS_CNTRL) <> CNTRL_DIALOG or CurrChar(POS_ID) <> 0
        ErrorMessage(ERR_RES)
        PopPosition()
        return (FALSE)
    endif
    KillPosition()

    // create work space

    dlg_data = CreateTempBuffer()
    edt_hist = CreateTempBuffer()
    if not (dlg_data and edt_hist)
        ErrorMessage(ERR_MEM)
        return (FALSE)
    endif

    // set data of paint module

    DlgExecMacro("DlgPaintSetData "+Str(dlg_data))

    // search control to activate first

    GotoBufferId(resource)
    curr_event = EVENT_MOUSE
    prev_focus = 0
    while Down()
        if CurrChar(POS_ENABLE) and GotoControl()
            prev_focus = CurrLine()
            break
        endif
    endwhile
    if not prev_focus
        ErrorMessage(ERR_CTRL)
        return (FALSE)
    endif

    // initialize data buffer

    GotoBufferId(dlg_data)
    do size times
        AddLine("0")
    enddo
    GotoBufferId(resource)
    CallBack("DataInit")

    // get intially focused control

    prev_cntrl = CurrChar(POS_CNTRL)
    prev_focus = CurrLine()

    // indicate success

    return (not terminate)
end

/****************************************************************************\
    clean up work space
\****************************************************************************/

string proc PopStack()
    string line[64]

    line = GetText(1,CurrLineLen())
    KillLine()
    return (line)
end

proc DoneEvents()
    while KeyPressed()
        if GetKey() <> KEY_NOTHING
            PushKey(Query(Key))
            break
        endif
    endwhile
end

proc Done()
    integer bid
    integer this_code = ret_code

    // return dialog data

    CallBack("DataDone")

    // clear work space

    AbandonFile(dlg_data)
    AbandonFile(edt_hist)

    // restore stacked data

    bid = GotoBufferId(dlg_stack)
    Set(EquateEnhancedKbd,Val(PopStack()))
    hscroll_size = Val(PopStack())
    hscroll_page = Val(PopStack())
    curr_event   = Val(PopStack())
    prev_focus   = Val(PopStack())
    prev_cntrl   = Val(PopStack())
    dlg_open     = Val(PopStack())
    terminate    = Val(PopStack())
    ret_code     = Val(PopStack())
    edt_hist     = Val(PopStack())
    dlg_data     = Val(PopStack())
    resource     = Val(PopStack())
    dlg_name     = PopStack()
    GotoBufferId(bid)

    // reset data of paint module

    DlgExecMacro("DlgPaintSetData "+Str(dlg_data))

    // reset dialog or clean up on last exit

    ref_count = ref_count - 1
    if ref_count
        Set(Key,KEY_NOTHING)
        PushKey(KEY_NOTHING)
        GotoBufferId(resource)
    else
        DoneEvents()
        Set(Cursor,ON)
        if UNLOAD_LIBRARY
            PurgeMacro(CurrMacroFilename())
        endif
    endif

    // set return code

    Set(MacroCmdLine,Str(this_code))
end

/****************************************************************************\
    helper: exported functions
\****************************************************************************/

proc RePaintCntrl( integer line )
    if dlg_open
        if line == CurrLine()
            PaintControl(STATE_ACTIVE)
        else
            PaintControl(STATE_NORMAL)
        endif
        if CurrChar(POS_CNTRL) == CNTRL_LIST
            do 2 times
                if Down() and CurrChar(POS_CNTRL) in CNTRL_VSCROLL,CNTRL_HSCROLL
                    PaintControl(STATE_NORMAL)
                endif
            enddo
        endif
    endif
end

integer proc GetCfgVar( string name )
    if lFind(name,"gi^")
        return (CurrChar(CurrLineLen()))
    endif
    return (0)
end

/****************************************************************************\
    dialog api
\****************************************************************************/

public proc DlgGetVersion()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgGetVersion')
    PressKey(TracePointKey)
#endif

    Set(MacroCmdLine,"2.22")
end

/*--------------------------------------------------------------------------*/

public proc DlgGetUnload()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgGetUnload')
    PressKey(TracePointKey)
#endif

    Set(MacroCmdLine,Str(UNLOAD_LIBRARY))
end

/*--------------------------------------------------------------------------*/

public proc DlgSetUnload()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgSetUnload')
    PressKey(TracePointKey)
#endif

    UNLOAD_LIBRARY = Val(Query(MacroCmdLine))
end

/*--------------------------------------------------------------------------*/

public proc DlgGetDblTime()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgGetDblTime')
    PressKey(TracePointKey)
#endif

    Set(MacroCmdLine,Str(MOUSE_DBL_TIME))
end

/*--------------------------------------------------------------------------*/

public proc DlgSetDblTime()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgSetDblTime')
    PressKey(TracePointKey)
#endif

    MOUSE_DBL_TIME = Val(Query(MacroCmdLine))
end

/*--------------------------------------------------------------------------*/

public proc DlgLoadSetup()
    integer bid
    string name[255]

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgLoadSetup')
    PressKey(TracePointKey)
#endif

    name = SplitPath(CurrMacroFilename(),_DRIVE_|_PATH_|_NAME_) + ".cfg"
    bid = GotoBufferId(dlg_setup)
    EmptyBuffer()
    if InsertFile(name,_DONT_PROMPT_)
        UnmarkBlock()
        UNLOAD_LIBRARY = GetCfgVar("UL")
        MOUSE_DBL_TIME = GetCfgVar("MD")
        DlgExecMacro("DlgPaintGetColors")
    else
        AddLine("UL"+Chr(0))
        AddLine("MD"+Chr(9))
        DlgExecMacro("DlgPaintSetColors")
    endif
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgSaveSetup()
    integer bid
    string name[255]

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgSaveSetup')
    PressKey(TracePointKey)
#endif

    name = SplitPath(CurrMacroFilename(),_DRIVE_|_PATH_|_NAME_) + ".cfg"
    bid = GotoBufferId(dlg_setup)
    SaveAs(name,_OVERWRITE_|_DONT_PROMPT_)
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgShowWindow()
    integer bid
    integer show = Query(MacroCmdLine) == "1"

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgShowWindow')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    if show and not dlg_open
        if Open(FALSE)
            PopPosition()
        else
            KillPosition()
            terminate = TRUE
        endif
    elseif not show and dlg_open
        PushPosition()
        Close()
    endif
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgPaintWindow()
    integer bid

    bid = GotoBufferId(dlg_setup)
    DlgExecMacro("DlgPaintGetColors")
    GotoBufferId(resource)
    PushPosition()

#ifdef WIN32
    BufferVideo()
#endif

    Close()
    Open(FALSE)

#ifdef WIN32
    UnBufferVideo()
#endif

    PopPosition()
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgPaintCntrl()
    integer bid, line

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgPaintCntrl')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    line = CurrLine()
    if FindCntrlWithId(Query(MacroCmdLine))
        RePaintCntrl(line)
        GotoLine(line)
    endif
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgMoveCntrl()
    integer bid
    integer x1, y1, x2, y2
    string params[32] = Query(MacroCmdLine)

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgMoveCntrl')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    x1 = Val(GetToken(params," ",1))
    y1 = Val(GetToken(params," ",2))
    x2 = Val(GetToken(params," ",3))
    y2 = Val(GetToken(params," ",4))
    GotoPos(POS_X1) InsertText(Chr(x1),_OVERWRITE_)
    GotoPos(POS_Y1) InsertText(Chr(y1),_OVERWRITE_)
    GotoPos(POS_X2) InsertText(Chr(x2),_OVERWRITE_)
    GotoPos(POS_Y2) InsertText(Chr(y2),_OVERWRITE_)
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgExecCntrl()
    integer bid, line

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgExecCntrl')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    line = CurrLine()
    if FindCntrlWithId(Query(MacroCmdLine))
        PushPosition()
        GotoLine(line)
        PaintControl(STATE_NORMAL)
        CallBack("KillFocus")
        PopPosition()
        CallBack("SetFocus")
        PushKey(KEY_NOTHING)
    endif
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgGetEnable()
    integer bid, en

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgGetEnable')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    PushPosition()
    if FindCntrlWithId(Query(MacroCmdLine))
        en = CurrChar(POS_ENABLE)
    endif
    Set(MacroCmdLine,Str(en))
    PopPosition()
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgSetEnable()
    integer bid, line
    string id[8]
    string en[8]

    en = Query(MacroCmdLine)
    id = GetToken(en," ",1)
    en = Chr(Val(GetToken(en," ",2)))

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgSetEnable')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    line = CurrLine()
    if FindCntrlWithId(id)
        GotoPos(POS_ENABLE)
        InsertText(en,_OVERWRITE_)
        RePaintCntrl(line)
        GotoLine(line)
    endif
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgGetTitle()
    integer bid
    integer hkpos
    string text[255] = ""

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgGetTitle')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    PushPosition()
    if FindCntrlWithId(Query(MacroCmdLine))
        GetCntrlTitle(text)
        hkpos = CurrChar(POS_HKPOS)
        if hkpos
            text = InsStr("&",text,hkpos)
        endif
    endif
    SetGlobalStr(DlgMsgText,text)
    Set(MacroCmdLine,text)
    PopPosition()
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

proc InternalSetTitle(string id, var string text)
    integer bid
    integer line, hkpos
    string htkey[1] = ""

    bid = GotoBufferId(resource)
    line = CurrLine()
    if FindCntrlWithId(id)
        if CurrChar(POS_CNTRL) in CNTRL_DIALOG,CNTRL_EDIT
            hkpos = 0
            htkey = " "
        else
            GetHotKey(text,htkey,hkpos)
        endif
        SetCntrlTitle(text,htkey,hkpos)
        RePaintCntrl(line)
        GotoLine(line)
    endif
    GotoBufferId(bid)
end

public proc DlgSetTitle()
    integer sp
    string id[8]
    string text[255]

    text = Query(MacroCmdLine)
    sp = Pos(" ",text)
    id = text[1..sp-1]
    text = text[sp+1..Length(text)]

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgSetTitle')
    PressKey(TracePointKey)
#endif

    InternalSetTitle(id,text)
end

public proc DlgSetTitleEx()
    string id[8]
    string text[255]

    id = Query(MacroCmdLine)
    text = GetGlobalStr(DlgMsgText)

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgSetTitleEx')
    PressKey(TracePointKey)
#endif

    InternalSetTitle(id,text)
end

/*--------------------------------------------------------------------------*/

public proc DlgGetHint()
    integer bid
    string text[255] = ""

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgGetHint')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    PushPosition()
    if FindCntrlWithId(Query(MacroCmdLine))
        GetCntrlHint(text)
    endif
    Set(MacroCmdLine,text)
    PopPosition()
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgSetHint()
    integer bid
    integer sp, line
    string id[8]
    string text[255]

    text = Query(MacroCmdLine)
    sp   = Pos(" ",text)
    id   = text[1..sp-1]
    text = text[sp+1..Length(text)]

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgSetHint')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    line = CurrLine()
    if FindCntrlWithId(id)
        SetCntrlHint(text)
        if line == CurrLine()
            DlgExecMacro("DlgPaintHint")
        endif
        GotoLine(line)
    endif
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgGetData()
    integer bid
    string text[255] = ""

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgGetData')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    PushPosition()
    if FindCntrlWithId(Query(MacroCmdLine))
        GetCntrlData(text)
    endif
    Set(MacroCmdLine,text)
    PopPosition()
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgSetData()
    integer bid
    integer sp, line
    string id[8]
    string text[255]

    text = Query(MacroCmdLine)
    sp   = Pos(" ",text)
    id   = text[1..sp-1]
    text = text[sp+1..Length(text)]

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgSetData')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    line = CurrLine()
    if FindCntrlWithId(id)
        SetCntrlData(text)
        RePaintCntrl(line)
        GotoLine(line)
    endif
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgGetHScroll()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgGetHScroll')
    PressKey(TracePointKey)
#endif

    Set(MacroCmdLine,Format(hscroll_page," ",hscroll_size))
end

/*--------------------------------------------------------------------------*/

public proc DlgSetHScroll()
    string params[32] = Query(MacroCmdLine)

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgSetHScroll')
    PressKey(TracePointKey)
#endif

    hscroll_page = Val(GetToken(params," ",1))
    hscroll_size = Val(GetToken(params," ",2))
end

/*--------------------------------------------------------------------------*/

public proc DlgInitMouseLoop()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgInitMouseLoop')
    PressKey(TracePointKey)
#endif

    if curr_event in EVENT_MOUSE,EVENT_CONTEXT
        PushKey(Query(Key))
    endif
end

/*--------------------------------------------------------------------------*/

public proc DlgMouseClick()
    integer bid

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgMouseClick')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    if CallBack("MouseHit") and Query(MacroCmdLine) == "1"
        ticks = 0
    else
        MouseDoubleClick()
        Set(MacroCmdLine,Str(MouseHit()))
    endif
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgMouseDoubleClick()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgMouseDoubleClick')
    PressKey(TracePointKey)
#endif

    Set(MacroCmdLine,Str(double))
end

/*--------------------------------------------------------------------------*/

public proc DlgMouseXOffset()
    integer bid

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgMouseXOffset')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    Set(MacroCmdLine,Str(
        Query(MouseX) - Query(PopWinX1) + 1 - CurrChar(POS_X1)))
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgMouseYOffset()
    integer bid

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgMouseYOffset')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(resource)
    Set(MacroCmdLine,Str(
        Query(MouseY) - Query(PopWinY1) + 1 - CurrChar(POS_Y1)))
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgGetEvent()
    integer level = Val(Query(MacroCmdLine))

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgGetEvent')
    PressKey(TracePointKey)
#endif

    if level == 0
        level = 1
    endif
    Set(MacroCmdLine,Str(GetEvent(level)))
end

/*--------------------------------------------------------------------------*/

public proc DlgGetRefCount()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgGetRefCount')
    PressKey(TracePointKey)
#endif

    Set(MacroCmdLine,Str(ref_count))
end

/*--------------------------------------------------------------------------*/

public proc DlgTerminate()
    string code[16] = Query(MacroCmdLine)

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgTerminate')
    PressKey(TracePointKey)
#endif

    code = Query(MacroCmdLine)
    if Length(code)
        ret_code = Val(code)
    endif
    terminate = TRUE
end

/****************************************************************************\
    exported functions (communication with DialogP)
\****************************************************************************/

public proc DlgPaintGetScrollPos()
    integer len = GetGlobalInt(DlgPaintState)

    SetGlobalInt(DlgPaintState,GetScrollPos(len))
end

/****************************************************************************\
    setup (recursion stack, load configuration and paint module)
\****************************************************************************/

proc WhenLoaded()
    integer msg, ok
    integer bid = GetBufferId()
    string cmd[32] = Query(MacroCmdLine)

    // load trace module

#ifdef TRACE
    if LoadDbgTrace()
        PurgeMacro(CurrMacroFilename())
    endif
    SetGlobalStr(DbgTraceArgs,'Dialog_WhenLoaded')
    PressKey(TracePointKey)
#endif

    // create global work space

    dlg_stack = CreateTempBuffer()
    dlg_setup = CreateTempBuffer()
    lst_null  = CreateTempBuffer()
    ok = dlg_stack and dlg_setup and lst_null

#ifndef WIN32
    alt_keys  = CreateTempBuffer()
    ok = ok and alt_keys and InsertData(alt_key_table)
#endif

    if not ok
        ErrorMessage(ERR_MEM)
        PurgeMacro(CurrMacroFilename())
        return ()
    endif

    // load paint module

    msg = Set(MsgLevel,_NONE_)
    ok = LoadMacro(Paint)
    Set(MsgLevel,msg)
    if ok
        DlgExecMacro(Format("DlgPaintInitData ",lst_null," ",dlg_setup))
    else
        ErrorMessage(ERR_MOD)
        PurgeMacro(CurrMacroFilename())
        return ()
    endif

    // load configuration info

    GotoBufferId(dlg_setup)
    BinaryMode(-1)
    ExecMacro("DlgLoadSetup")

    // restore state

    GotoBufferId(bid)
    Set(MacroCmdLine,cmd)
end

/****************************************************************************\
    shutdown (buffers, global variables and unload paint module)
\****************************************************************************/

proc WhenPurged()

    // clear work space

    AbandonFile(dlg_stack)
    AbandonFile(dlg_setup)
    AbandonFile(lst_null)

#ifndef WIN32
    AbandonFile(alt_keys)
#endif

    // unload paint module

    PurgeMacro(Paint)

    // clear global variables

    DelGlobalVar(DlgMsgText)
    DelGlobalVar(DlgPaintState)
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'Dialog_Main')
    PressKey(TracePointKey)
    StartDbgTrace()
#endif

    if Load() and Open(TRUE)
        Exec()
        Close()
    endif
    Done()
end

