/****************************************************************************\

    DialogP.S

    Paint module for CUA style Dialog package.

    Version         v2.21/19.11.03
    Copyright       (c) 1995-2003 by DiK

    Overview:

    This macro is a run time library which is part of Dialog.S and
    is not meant to be directly executed by the user. Neither is it
    meant to be explicitly used by any dialog macro.

    Usage notes:

    See Program.Doc for instructions on how to use Dialog.S from within
    your own macros.

    History

    v2.21/19.11.03  adaption to TSE32 v4.2
                    + fixed painting titles (oem bug)

    v2.20/17.04.02  adaption to TSE32 v4.0
                    + moved close box (v4.0 only)
                    + fixed painting oem characters
                    + some cleanup of source code

    v2.10/30.11.00  adaption to TSE32 v3.0
                    + fixed painting hints
                    + fixed painting edit controls (text > 127)

    v2.02/07.01.99  bug fix
                    + added querying of TracePointKey
                    + optimzed usage of macro stack
                    + fixed drop down arrow painting (non-437 CP)

    v2.01/22.04.97  bug fix
                    + fixed painting of hint line
                    + fixed video output (GotoXY -> VGotoXY)

    v2.00/24.10.96  first version

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
    communication with main module

    note:   The global variable DlgPaintState is used to communicate
            integer values between Dialog and DialogP in order to
            minimize the impact on TSE's macro stack. It helps to
            save from 257 to 771 bytes of temporary variable space
            per nested dynamic call.
\****************************************************************************/

string DlgPaintState[] = "DlgPaintState"

/****************************************************************************\
    buffer id's

    note:   these are references only. buffers are allocated by dialog.
\****************************************************************************/

integer dlg_data                        // buffer id (dialog data)
integer lst_null                        // ditto (painting empty lists)
integer dlg_setup                       // ditto (dialog configuration info)

/****************************************************************************\
    global string buffer

    note:   the following global variable is used by the painting
            routines to minimize their impact on TSE's macro stack.
            This helps to save 257 bytes of temporary variable space
            per nested dynamic call.
\****************************************************************************/

string text_buffer[255]

/****************************************************************************\
    color values
\****************************************************************************/

integer  CLR_DLG_NORMAL     = Color( bright white on white )
integer  CLR_DLG_CLOSE      = Color( bright green on white )
integer  CLR_DLG_DRAGGING   = Color( bright green on white )
integer  CLR_FRM_NORMAL     = Color( bright white on white )
integer  CLR_FRM_HOTKEY     = Color( bright yellow on white )
integer  CLR_FRM_DISABLE    = Color( bright black on white )
integer  CLR_TXT_NORMAL     = Color( black on white )
integer  CLR_TXT_HOTKEY     = Color( bright yellow on white )
integer  CLR_TXT_DISABLE    = Color( bright black on white )
integer  CLR_HST_PANEL      = Color( white on green )
integer  CLR_HST_ARROW      = Color( black on green )
integer  CLR_HST_DISABLE    = Color( white on green )
integer  CLR_EDT_NORMAL     = Color( bright white on blue )
integer  CLR_EDT_MARKED     = Color( black on green )
integer  CLR_EDT_DISABLE    = Color( bright black on blue )
integer  CLR_CHK_NORMAL     = Color( black on cyan )
integer  CLR_CHK_ACTIVE     = Color( bright white on cyan )
integer  CLR_CHK_HOTKEY     = Color( bright yellow on cyan )
integer  CLR_CHK_DISABLE    = Color( bright black on cyan )
integer  CLR_BTN_NORMAL     = Color( black on green )
integer  CLR_BTN_ACTIVE     = Color( bright white on green )
integer  CLR_BTN_DEFAULT    = Color( bright cyan on green )
integer  CLR_BTN_HOTKEY     = Color( bright yellow on green )
integer  CLR_BTN_SHADE      = Color( black on white )
integer  CLR_BTN_DISABLE    = Color( bright black on green )
integer  CLR_CMB_NORMAL     = Color( bright white on blue )
integer  CLR_CMB_ACTIVE     = Color( bright cyan on blue )
integer  CLR_CMB_DISABLE    = Color( bright black on blue )
integer  CLR_LST_NORMAL     = Color( black on cyan )
integer  CLR_LST_CURRENT    = Color( bright yellow on cyan )
integer  CLR_LST_SELECT     = Color( bright white on green )
integer  CLR_LST_MARKED     = Color( bright red on green )
integer  CLR_LST_DISABLE    = Color( bright black on cyan )
integer  CLR_SCR_NORMAL     = Color( bright white on blue )
integer  CLR_SCR_DISABLE    = Color( bright black on blue )
integer  CLR_DRP_NORMAL     = Color( bright white on blue )
integer  CLR_DRP_SELECT     = Color( bright white on green )
integer  CLR_DRP_MARKED     = Color( bright red on green )

/****************************************************************************\
    shared code (also used by Dialog.S)
\****************************************************************************/

#include "scpaint.si"

/****************************************************************************\
    tracing data
\****************************************************************************/

#ifdef TRACE

integer TracePointKey
string DbgTraceArgs[] = "DbgTraceArgs"

#endif

/****************************************************************************\
    helper: painting routines
\****************************************************************************/

proc PaintTitle( integer cntrl_type,
    integer x1, integer x2, integer text_attr, integer hotkey_attr )

    integer beg, len
    integer y1 = CurrChar(POS_Y1)
    integer hk = CurrChar(POS_HKPOS)

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintTitle')
    PressKey(TracePointKey)
#endif

#ifdef WIN32
    BufferVideo()
#endif

    GetCntrlTitle(text_buffer)

    len = x2 - x1
    case cntrl_type
        when CNTRL_LTEXT    beg = 0
        when CNTRL_RTEXT    beg = len - Length(text_buffer)
        otherwise           beg = (len - Length(text_buffer)) / 2
    endcase
    if beg < 0
        beg = 0
    endif
    len = len - beg

    Set(Attr,text_attr)
    VGotoXY(x1,y1)
    PutCharH(" ",beg)
    PutLine(text_buffer,len)

    if hk and CurrChar(POS_ENABLE)
        hk = x1 + beg + hk - 1
        VGotoXY(hk,y1)
        PutAttr(hotkey_attr,1)
    endif

#ifdef WIN32
    UnBufferVideo()
#endif

end

/****************************************************************************/

proc PaintRadioCheck( integer state )
    integer x1 = CurrChar(POS_X1)
    integer x2 = CurrChar(POS_X2)

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintRadioCheck')
    PressKey(TracePointKey)
#endif

#ifdef WIN32
    BufferVideo()
#endif

    case state
        when STATE_DISABLE  Set(Attr,CLR_CHK_DISABLE)
        when STATE_ACTIVE   Set(Attr,CLR_CHK_ACTIVE)
        otherwise           Set(Attr,CLR_CHK_NORMAL)
    endcase

    if GetCntrlDataInt() <> 1
        text_buffer[2] = " "
    endif

    VGotoXY(x1, CurrChar(POS_Y1))
#if EDITOR_VERSION <= 0x3000
    PutStr(text_buffer)
#else
    PutOemLine(text_buffer, Length(text_buffer))
#endif
    PutChar(" ")
    PaintTitle(CNTRL_LTEXT, VWhereX(), x2, Query(Attr), CLR_CHK_HOTKEY)

#ifdef WIN32
    UnBufferVideo()
#endif

end

/****************************************************************************\
    paint routine: dialog
\****************************************************************************/

proc PaintDialog()

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintDialog')
    PressKey(TracePointKey)
#endif

    PushPosition()
    if FindCntrlWithId(Str(ID_CANCEL))
        BegFile() // goto dialog control

#ifdef WIN32
        BufferVideo()
#endif

#if EDITOR_VERSION <= 0x3000
        VGotoXY(2,0)
        Set(Attr,CLR_DLG_NORMAL)
        PutChar("[")
        Set(Attr,CLR_DLG_CLOSE)
        PutChar("þ")
        Set(Attr,CLR_DLG_NORMAL)
        PutChar("]")
#else
        VGotoXY(CurrChar(POS_X2) - CurrChar(POS_X1) - 3, 0)
        Set(Attr,CLR_DLG_NORMAL)
        PutStr("[x]")
#endif

#ifdef WIN32
        UnBufferVideo()
#endif

    endif
    PopPosition()
end

/****************************************************************************\
    paint routine: frame
\****************************************************************************/

proc PaintFrame( integer state )
    integer x1 = CurrChar(POS_X1)
    integer x2 = CurrChar(POS_X2)
    integer y1 = CurrChar(POS_Y1)
    integer y2 = CurrChar(POS_Y2)
    integer hlen = x2 - x1 - 2
    integer vlen = y2 - y1 - 2
    integer attr
    integer hk = CurrChar(POS_HKPOS)

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintFrame')
    PressKey(TracePointKey)
#endif

    GetCntrlTitle(text_buffer)
    case state
        when STATE_DISABLE  attr = CLR_FRM_DISABLE
        otherwise           attr = CLR_FRM_NORMAL
    endcase

#ifdef WIN32
    BufferVideo()
#endif

#if EDITOR_VERSION <= 0x3000

    VGotoXY(x1,y1)
    Set(Attr,attr)
    PutStr("ÚÄ")
    if Length(text_buffer)
        PutChar(" ")
        PutStr(text_buffer)
        PutChar(" ")
    else
        PutStr("ÄÄ")
    endif
    PutCharH("Ä",hlen-Length(text_buffer)-3)
    PutChar("¿")
    if hk and CurrChar(POS_ENABLE)
        VGotoXY(x1+hk+2,y1)
        PutAttr(CLR_FRM_HOTKEY,1)
    endif
    VGotoXY(x1,y1+1)
    PutCharV("³",vlen)
    VGotoXY(x2-1,y1+1)
    PutCharV("³",vlen)
    VGotoXY(x1,y2-1)
    PutChar("À")
    PutCharH("Ä",hlen)
    PutChar("Ù")

#else

    VGotoXY(x1,y1)
    Set(Attr,attr)
    PutOemLine("ÚÄ", 2)
    if Length(text_buffer)
        PutChar(" ")
        PutStr(text_buffer)
        PutChar(" ")
    else
        PutOemLine("ÄÄ", 2)
    endif
    PutOemCharH("Ä",hlen-Length(text_buffer)-3)
    PutOemChar("¿")
    if hk and CurrChar(POS_ENABLE)
        VGotoXY(x1+hk+2,y1)
        PutAttr(CLR_FRM_HOTKEY,1)
    endif
    VGotoXY(x1,y1+1)
    PutOemCharV("³",vlen)
    VGotoXY(x2-1,y1+1)
    PutOemCharV("³",vlen)
    VGotoXY(x1,y2-1)
    PutOemChar("À")
    PutOemCharH("Ä",hlen)
    PutOemChar("Ù")

#endif

#ifdef WIN32
    UnBufferVideo()
#endif

end

/****************************************************************************\
    paint routine: plain text
\****************************************************************************/

proc PaintText( integer state, integer cntrl )
    integer attr

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintText')
    PressKey(TracePointKey)
#endif

    case state
        when STATE_DISABLE  attr = CLR_TXT_DISABLE
        otherwise           attr = CLR_TXT_NORMAL
    endcase

    PaintTitle(cntrl, CurrChar(POS_X1), CurrChar(POS_X2), attr, CLR_TXT_HOTKEY)
end

/****************************************************************************\
    paint routine: open list
\****************************************************************************/

proc PaintOpen( integer state )

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintOpen')
    PressKey(TracePointKey)
#endif

#ifdef WIN32
    BufferVideo()
#endif

#if EDITOR_VERSION <= 0x3000

    VGotoXY(CurrChar(POS_X1),CurrChar(POS_Y1))
    if state == STATE_DISABLE
        Set(Attr,CLR_HST_DISABLE)
        PutStr("  ")
    else
        Set(Attr,CLR_HST_PANEL)
        PutChar(" ")
        Set(Attr,CLR_HST_ARROW)
        PutChar("")
        Set(Attr,CLR_HST_PANEL)
        PutChar(" ")
    endif

#else

    VGotoXY(CurrChar(POS_X1),CurrChar(POS_Y1))
    if state == STATE_DISABLE
        Set(Attr,CLR_HST_DISABLE)
        PutChar(" ")
        PutOemChar("")
        PutChar(" ")
    else
        Set(Attr,CLR_HST_PANEL)
        PutChar(" ")
        Set(Attr,CLR_HST_ARROW)
        PutOemChar("")
        Set(Attr,CLR_HST_PANEL)
        PutChar(" ")
    endif

#endif

#ifdef WIN32
    UnBufferVideo()
#endif

end

/****************************************************************************\
    paint routine: edit control
\****************************************************************************/

proc PaintEdit( integer state )
    integer x1 = CurrChar(POS_X1)
    integer y1 = CurrChar(POS_Y1)
    integer len = CurrChar(POS_X2) - x1

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintEdit')
    PressKey(TracePointKey)
#endif

    GetCntrlTitle(text_buffer)

#ifdef WIN32
    BufferVideo()
#endif

    VGotoXY(x1,y1)
    case state
        when STATE_DISABLE  Set(Attr,CLR_EDT_DISABLE)
        otherwise           Set(Attr,CLR_EDT_NORMAL)
    endcase
    PutLine(text_buffer,len)

#ifdef WIN32
    UnBufferVideo()
#endif

end

/****************************************************************************\
    paint routine: edit control (while executing)

    note:   DlgPaintState   low word  = mark_beg
                            high word = mark_end
\****************************************************************************/

public proc DlgPaintEditInput()
    integer mark_beg
    integer mark_end
    integer x1 = CurrChar(POS_X1)
    integer y1 = CurrChar(POS_Y1)
    integer field = CurrChar(POS_X2) - x1

    text_buffer = GetGlobalStr(DlgMsgText)
    mark_beg = GetGlobalInt(DlgPaintState)
    mark_end = mark_beg shr 16
    mark_beg = mark_beg & 0xFFFF

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgPaintEditInput')
    PressKey(TracePointKey)
#endif

#ifdef WIN32
    BufferVideo()
#endif

    VGotoXY(x1,y1)
    Set(Attr,CLR_EDT_NORMAL)
    PutLine(text_buffer,field)
    if mark_end > mark_beg
        VGotoXY(x1+mark_beg,y1)
        PutAttr(CLR_EDT_MARKED,mark_end-mark_beg)
    endif

#ifdef WIN32
    UnBufferVideo()
#endif

end

/****************************************************************************\
    paint routine: radio buttons
\****************************************************************************/

proc PaintRadio( integer state )

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintRadio')
    PressKey(TracePointKey)
#endif

#if EDITOR_VERSION <= 0x3000
    text_buffer = "()"
#else
    text_buffer = "(ú)"
#endif
    PaintRadioCheck(state)
end

/****************************************************************************\
    paint routine: check boxes
\****************************************************************************/

proc PaintCheck( integer state )

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintCheck')
    PressKey(TracePointKey)
#endif

    text_buffer = "[X]"
    PaintRadioCheck(state)
end

/****************************************************************************\
    paint routine: push buttons
\****************************************************************************/

proc PaintButton( integer state, integer default )
    integer len, attr
    integer x1 = CurrChar(POS_X1)
    integer x2 = CurrChar(POS_X2)
    integer y1 = CurrChar(POS_Y1)

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintButton')
    PressKey(TracePointKey)
#endif

    if default and state == STATE_NORMAL
        state = STATE_DEFAULT
    endif

#ifdef WIN32
    BufferVideo()
#endif

    len = x2 - x1
    VGotoXY(x1,y1)
    if state == STATE_PRESSED
        Set(Attr,CLR_DLG_NORMAL)
        PutChar(" ")
        PaintTitle(CNTRL_CTEXT, x1+1, x2+1, CLR_BTN_ACTIVE, CLR_BTN_HOTKEY)
        VGotoXY(x1,y1+1)
        Set(Attr,CLR_BTN_SHADE)
        PutCharH(" ",len+1)
    else
        case state
            when STATE_DISABLE  attr = CLR_BTN_DISABLE
            when STATE_DEFAULT  attr = CLR_BTN_DEFAULT
            when STATE_ACTIVE   attr = CLR_BTN_ACTIVE
            otherwise           attr = CLR_BTN_NORMAL
        endcase
        PaintTitle(CNTRL_CTEXT, x1, x2, attr, CLR_BTN_HOTKEY)
        Set(Attr,CLR_BTN_SHADE)

#if EDITOR_VERSION <= 0x3000

        VGotoXY(x2,y1)
        PutChar("Ü")
        VGotoXY(x1,y1+1)
        PutChar(" ")
        PutCharH("ß",len)

#else

        VGotoXY(x2,y1)
        PutOemChar("Ü")
        VGotoXY(x1,y1+1)
        PutOemChar(" ")
        PutOemCharH("ß",len)

#endif

    endif

#ifdef WIN32
    UnBufferVideo()
#endif

end

/****************************************************************************\
    paint routine: combo box
\****************************************************************************/

proc PaintCombo( integer state )
    integer x1 = CurrChar(POS_X1)
    integer x2 = CurrChar(POS_X2)
    integer y1 = CurrChar(POS_Y1)
    integer bid

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintCombo')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(GetCntrlDataInt())
    if bid
        text_buffer = GetText(1,CurrLineLen())
        GotoBufferId(bid)
    else
        text_buffer = ""
    endif

    case state
        when STATE_DISABLE  Set(Attr,CLR_CMB_DISABLE)
        when STATE_ACTIVE   Set(Attr,CLR_CMB_ACTIVE)
        otherwise           Set(Attr,CLR_CMB_NORMAL)
    endcase

#ifdef WIN32
    BufferVideo()
#endif

    VGotoXY(x1,y1)
    PutLine(text_buffer,x2-x1)

#ifdef WIN32
    UnBufferVideo()
#endif

end

/****************************************************************************\
    paint routine: list box
\****************************************************************************/

proc PaintList( integer state )
    integer buff
    integer x1 = CurrChar(POS_X1)
    integer y1 = CurrChar(POS_Y1)
    integer y2 = CurrChar(POS_Y2)
    integer hlen = CurrChar(POS_X2) - x1 - 1
    integer ofst, curr, col1, col2

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintList')
    PressKey(TracePointKey)
#endif

    buff = GetBufferId()
    if not GotoBufferId(GetCntrlDataInt())
        GotoBufferId(lst_null)
    endif

    case state
        when STATE_DISABLE  col1 = CLR_LST_DISABLE
        otherwise           col1 = CLR_LST_NORMAL
    endcase

    case state
        when STATE_DISABLE  col2 = CLR_LST_DISABLE
        when STATE_ACTIVE   col2 = CLR_LST_SELECT
        otherwise           col2 = CLR_LST_CURRENT
    endcase

    ofst = CurrXOffset() + 1
    curr = CurrLine()
    PushPosition()
    BegWindow()

#ifdef WIN32
    BufferVideo()
#endif

    if NumLines()
        repeat
            text_buffer = GetText(1,CurrLineLen())
            Set(Attr, iif( curr == CurrLine(), col2, col1 ))
            VGotoXY(x1,y1)
            PutChar(" ")
            PutLine(text_buffer[ofst:hlen],hlen)
            if curr == CurrLine() and isBlockMarked()
                VGotoXY(x1+Query(BlockBegCol)-ofst+1,y1)
                PutAttr(CLR_LST_MARKED,Query(BlockEndCol)-Query(BlockBegCol)+1)
            endif
            y1 = y1 + 1
        until y1 >= y2 or not Down()
    endif

    hlen = hlen + 1
    Set(Attr,col1)
    while y1 < y2
        VGotoXY(x1,y1)
        PutCharH(" ",hlen)
        y1 = y1 + 1
    endwhile

#ifdef WIN32
    UnBufferVideo()
#endif

    PopPosition()
    GotoBufferId(buff)
end

/****************************************************************************\
    paint routine: vertical scroll bar
\****************************************************************************/

proc PaintVScroll( integer state )
    integer x1 = CurrChar(POS_X1)
    integer y1 = CurrChar(POS_Y1)
    integer y2 = CurrChar(POS_Y2)
    integer len = y2 - y1 - 2

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintVScroll')
    PressKey(TracePointKey)
#endif

    case state
        when STATE_DISABLE  Set(Attr,CLR_SCR_DISABLE)
        otherwise           Set(Attr,CLR_SCR_NORMAL)
    endcase

#ifdef WIN32
    BufferVideo()
#endif

#if EDITOR_VERSION <= 0x3000

    VGotoXY(x1,y1)
    PutChar("")
    VGotoXY(x1,y1+1)
    PutCharV("°",len)
    VGotoXY(x1,y2-1)
    PutChar("")
    case state
        when STATE_ACTIVE
            VGotoXY(x1, y1 + MouseLocation() - 1)
            PutChar("")
        otherwise
            SetGlobalInt(DlgPaintState,len)
            ExecMacro("DlgPaintGetScrollPos")
            VGotoXY(x1, y1 + GetGlobalInt(DlgPaintState))
            PutChar("Û")
    endcase

#else

    VGotoXY(x1,y1)
    PutOemChar("")
    VGotoXY(x1,y1+1)
    PutOemCharV("°",len)
    VGotoXY(x1,y2-1)
    PutOemChar("")
    case state
        when STATE_ACTIVE
            VGotoXY(x1, y1 + MouseLocation() - 1)
            PutOemChar("")
        otherwise
            SetGlobalInt(DlgPaintState,len)
            ExecMacro("DlgPaintGetScrollPos")
            VGotoXY(x1, y1 + GetGlobalInt(DlgPaintState))
            PutOemChar("Û")
    endcase

#endif

#ifdef WIN32
    UnBufferVideo()
#endif

end

/****************************************************************************\
    paint routine: horizontal scroll bar
\****************************************************************************/

proc PaintHScroll( integer state )
    integer x1 = CurrChar(POS_X1)
    integer x2 = CurrChar(POS_X2)
    integer y1 = CurrChar(POS_Y1)
    integer len = x2 - x1 - 2

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintHScroll')
    PressKey(TracePointKey)
#endif

    case state
        when STATE_DISABLE  Set(Attr,CLR_SCR_DISABLE)
        otherwise           Set(Attr,CLR_SCR_NORMAL)
    endcase

#ifdef WIN32
    BufferVideo()
#endif

#if EDITOR_VERSION <= 0x3000

    VGotoXY(x1,y1)
    PutChar("")
    VGotoXY(x1+1,y1)
    PutCharH("°",len)
    VGotoXY(x2-1,y1)
    PutChar("")
    case state
        when STATE_ACTIVE
            VGotoXY(x1 + MouseLocation() - 1, y1)
            PutChar("")
        otherwise
            SetGlobalInt(DlgPaintState,len)
            ExecMacro("DlgPaintGetScrollPos")
            VGotoXY(x1 + GetGlobalInt(DlgPaintState), y1)
            PutChar("Û")
    endcase

#else

    VGotoXY(x1,y1)
    PutOemChar("")
    VGotoXY(x1+1,y1)
    PutOemCharH("°",len)
    VGotoXY(x2-1,y1)
    PutOemChar("")
    case state
        when STATE_ACTIVE
            VGotoXY(x1 + MouseLocation() - 1, y1)
            PutOemChar("")
        otherwise
            SetGlobalInt(DlgPaintState,len)
            ExecMacro("DlgPaintGetScrollPos")
            VGotoXY(x1 + GetGlobalInt(DlgPaintState), y1)
            PutOemChar("Û")
    endcase

#endif

#ifdef WIN32
    UnBufferVideo()
#endif

end

/****************************************************************************\
    paint routine: connector piece
\****************************************************************************/

proc PaintScrEdge( integer state )
    case state
        when STATE_DISABLE  Set(Attr,CLR_SCR_DISABLE)
        otherwise           Set(Attr,CLR_SCR_NORMAL)
    endcase

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'PaintScrEdge')
    PressKey(TracePointKey)
#endif

#ifdef WIN32
    BufferVideo()
#endif

    VGotoXY(CurrChar(POS_X1),CurrChar(POS_Y1))

#if EDITOR_VERSION <= 0x3000
    PutChar("¼")
#else
    PutOemChar("¼")
#endif

#ifdef WIN32
    UnBufferVideo()
#endif

end

/****************************************************************************\
    initialize and finalize drop down colors (internal interface)
\****************************************************************************/

integer ta, ba, sa, hl

public proc DlgPaintDropInit()
    ta = Set(MenuTextAttr,CLR_DRP_NORMAL)
    ba = Set(MenuBorderAttr,CLR_DRP_NORMAL)
    sa = Set(MenuSelectAttr,CLR_DRP_SELECT)
    hl = Set(HiLiteAttr,CLR_DRP_MARKED)
end

public proc DlgPaintDropDone()
    Set(MenuTextAttr,ta)
    Set(MenuBorderAttr,ba)
    Set(MenuSelectAttr,sa)
    Set(HiLiteAttr,hl)
end

/****************************************************************************\
    paint standard controls (internal interface)
\****************************************************************************/

public proc DlgPaintStdCntrl()
    integer cntrl = CurrChar(POS_CNTRL)
    integer state = GetGlobalInt(DlgPaintState)

    case cntrl
        when CNTRL_DIALOG               PaintDialog()
        when CNTRL_FRAME                PaintFrame(state)
        when CNTRL_LTEXT,
             CNTRL_RTEXT,CNTRL_CTEXT    PaintText(state,cntrl)
        when CNTRL_OPEN                 PaintOpen(state)
        when CNTRL_EDIT                 PaintEdit(state)
        when CNTRL_BUTTON               PaintButton(state,FALSE)
        when CNTRL_DEFBTN               PaintButton(state,TRUE)
        when CNTRL_RADIO                PaintRadio(state)
        when CNTRL_CHECK                PaintCheck(state)
        when CNTRL_COMBO                PaintCombo(state)
        when CNTRL_LIST                 PaintList(state)
        when CNTRL_VSCROLL              PaintVScroll(state)
        when CNTRL_HSCROLL              PaintHScroll(state)
        when CNTRL_SCREDGE              PaintScrEdge(state)
    endcase
end

/****************************************************************************\
    paint hint lines (internal interface)
\****************************************************************************/

public proc DlgPaintHint()
    integer help_line_pos

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgPaintHint')
    PressKey(TracePointKey)
#endif

    GetCntrlHint(text_buffer)

    if Length(text_buffer)

        if Query(ShowHelpLine)
            if Query(StatusLineAtTop)
                help_line_pos = Query(ScreenRows)
            else
                help_line_pos = 1
            endif
        else
            help_line_pos = Query(StatusLineRow)
        endif

#ifdef WIN32
        BufferVideo()
#endif

        VGotoXYAbs(1,help_line_pos)
        Set(Attr,Query(MenuTextAttr))
        PutLine(text_buffer,Query(ScreenCols))

#ifdef WIN32
        UnBufferVideo()
#endif

    endif
end

/****************************************************************************\
    color api (internal interface)

    note:   dlg_setup must be current buffer when calling functions
\****************************************************************************/

proc AccessColor( var integer clr, integer get, string name )
    integer rc

    rc = lFind(name+"","gi^")
    if get
        if rc
            clr = CurrChar(CurrLineLen())
        else
            clr = -1
        endif
    else
        if rc
            GotoPos(CurrLineLen())
            InsertText(Chr(clr),_OVERWRITE_)
        else
            EndFile()
            AddLine(Format(name,"",Chr(clr)))
        endif
    endif
end

proc AccessAllColors( integer get )
    AccessColor( CLR_DLG_NORMAL  , get, "Dialog_Normal"  )
    AccessColor( CLR_DLG_CLOSE   , get, "Dialog_Close"   )
    AccessColor( CLR_DLG_DRAGGING, get, "Dialog_Dragging")
    AccessColor( CLR_FRM_NORMAL  , get, "Frame_Normal"   )
    AccessColor( CLR_FRM_HOTKEY  , get, "Frame_Hotkey"   )
    AccessColor( CLR_FRM_DISABLE , get, "Frame_Disabled" )
    AccessColor( CLR_TXT_NORMAL  , get, "Text_Normal"    )
    AccessColor( CLR_TXT_HOTKEY  , get, "Text_Hotkey"    )
    AccessColor( CLR_TXT_DISABLE , get, "Text_Disabled"  )
    AccessColor( CLR_HST_PANEL   , get, "Hist_Panel"     )
    AccessColor( CLR_HST_ARROW   , get, "Hist_Arrow"     )
    AccessColor( CLR_HST_DISABLE , get, "Hist_Disabled"  )
    AccessColor( CLR_EDT_NORMAL  , get, "Edit_Normal"    )
    AccessColor( CLR_EDT_MARKED  , get, "Edit_Marked"    )
    AccessColor( CLR_EDT_DISABLE , get, "Edit_Disabled"  )
    AccessColor( CLR_CHK_NORMAL  , get, "Check_Normal"   )
    AccessColor( CLR_CHK_ACTIVE  , get, "Check_Active"   )
    AccessColor( CLR_CHK_HOTKEY  , get, "Check_Hotkey"   )
    AccessColor( CLR_CHK_DISABLE , get, "Check_Disabled" )
    AccessColor( CLR_BTN_NORMAL  , get, "Button_Normal"  )
    AccessColor( CLR_BTN_ACTIVE  , get, "Button_Active"  )
    AccessColor( CLR_BTN_DEFAULT , get, "Button_Default" )
    AccessColor( CLR_BTN_HOTKEY  , get, "Button_Hotkey"  )
    AccessColor( CLR_BTN_SHADE   , get, "Button_Shade"   )
    AccessColor( CLR_BTN_DISABLE , get, "Button_Disabled")
    AccessColor( CLR_CMB_NORMAL  , get, "Combo_Normal"   )
    AccessColor( CLR_CMB_ACTIVE  , get, "Combo_Active"   )
    AccessColor( CLR_CMB_DISABLE , get, "Combo_Disabled" )
    AccessColor( CLR_LST_NORMAL  , get, "List_Normal"    )
    AccessColor( CLR_LST_CURRENT , get, "List_Current"   )
    AccessColor( CLR_LST_SELECT  , get, "List_Select"    )
    AccessColor( CLR_LST_MARKED  , get, "List_Marked"    )
    AccessColor( CLR_LST_DISABLE , get, "List_Disabled"  )
    AccessColor( CLR_SCR_NORMAL  , get, "Scroll_Normal"  )
    AccessColor( CLR_SCR_DISABLE , get, "Scroll_Disabled")
    AccessColor( CLR_DRP_NORMAL  , get, "DropDown_Normal")
    AccessColor( CLR_DRP_SELECT  , get, "DropDown_Select")
    AccessColor( CLR_DRP_MARKED  , get, "DropDown_Marked")
end

public proc DlgPaintGetColors()
    AccessAllColors(TRUE)
end

public proc DlgPaintSetColors()
    AccessAllColors(FALSE)
end

public proc DlgPaintGetColorNormal()
    Set(MacroCmdLine,Str(CLR_DLG_NORMAL))
end

public proc DlgPaintGetColorDragging()
    Set(MacroCmdLine,Str(CLR_DLG_DRAGGING))
end

/****************************************************************************\
    color api (external interface)
\****************************************************************************/

public proc DlgGetColor()
    integer bid
    integer clr

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgGetColor')
    PressKey(TracePointKey)
#endif

    bid = GotoBufferId(dlg_setup)
    AccessColor(clr,TRUE,Query(MacroCmdLine))
    Set(MacroCmdLine,Str(clr))
    GotoBufferId(bid)
end

/*--------------------------------------------------------------------------*/

public proc DlgSetColor()
    integer bid
    integer clr

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgSetColor')
    PressKey(TracePointKey)
#endif

    text_buffer = Query(MacroCmdLine)
    clr = Val(GetToken(text_buffer," ",2))
    text_buffer = GetToken(text_buffer," ",1)

    bid = GotoBufferId(dlg_setup)
    AccessColor(clr,FALSE,text_buffer)
    GotoBufferId(bid)
end

/****************************************************************************\
    set buffer pointers (internal interface)
\****************************************************************************/

public proc DlgPaintInitData()
    string data[64] = Query(MacroCmdLine)

#ifdef TRACE
    ExecMacro("GetTracePointKey")
    TracePointKey = Val(Query(MacroCmdLine))
#endif

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgPaintInitData')
    PressKey(TracePointKey)
#endif

    lst_null = Val(GetToken(data," ",1))
    dlg_setup = Val(GetToken(data," ",2))
end

public proc DlgPaintSetData()
    dlg_data = Val(Query(MacroCmdLine))

#ifdef TRACE
    SetGlobalStr(DbgTraceArgs,'DlgPaintSetData')
    PressKey(TracePointKey)
#endif
end

