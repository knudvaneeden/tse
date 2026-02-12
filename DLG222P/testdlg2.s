/****************************************************************************\

    TestDlg2.S

    Example dialog

    Version         v2.01/17.03.97
    Copyright       (c) 1995-97 by DiK

    History

    v2.01/17.03.97  maintenance
    v2.00/24.10.96  maintenance
    v1.20/25.03.96  maintenance
    v1.10/12.01.96  maintenance
    v1.00/11.10.95  first version

\****************************************************************************/

/****************************************************************************\
    global constants
\****************************************************************************/

#include "testdlg2.si"
#include "msgbox.si"
#include "dialog.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "testdlg2.dlg"

/****************************************************************************\
    internal data
\****************************************************************************/

integer text_pos

/****************************************************************************\
    scroller
\****************************************************************************/

proc PaintText( integer state )
    integer x1 = CurrChar(POS_X1)
    integer y1 = CurrChar(POS_Y1)

    VGotoXY(x1,y1)
    Set(Attr,Color(black on green))
    PutStr("0123456789ABCDEF")
    VGotoXY(x1 + text_pos - 1, y1)
    if state == STATE_ACTIVE
        PutAttr(Color(bright red on green),1)
    else
        PutAttr(Color(bright white on green),1)
    endif
end

proc ExecText()
    integer code

    ExecMacro("DlgInitMouseLoop")

    loop
        PaintText(STATE_ACTIVE)
        ExecMacro(Format("DlgPaintCntrl ",id_scroll))

        ExecMacro("DlgGetEvent")
        code = Val(Query(MacroCmdLine))

        case code
            when <LeftBtn>
                ExecMacro("DlgMouseClick")
                if Val(Query(MacroCmdLine))
                    ExecMacro("DlgMouseXOffset")
                    text_pos = Val(Query(MacroCmdLine)) + 1
                else
                    break
                endif
            when <CursorLeft>
                text_pos = Max(1,text_pos-1)
            when <CursorRight>
                text_pos = Min(16,text_pos+1)
            when <Ctrl CursorLeft>
                text_pos = Max(1,text_pos-4)
            when <Ctrl CursorRight>
                text_pos = Min(16,text_pos+4)
            when <Home>
                text_pos = 1
            when <End>
                text_pos = 16
            otherwise
                break
        endcase
    endloop

    PushKey(code)
end

public proc Test2GetListLen()
    Set(MacroCmdLine,"16")
end

public proc Test2GetListPos()
    Set(MacroCmdLine,Str(text_pos))
end

public proc Test2SetListPos()
    text_pos = Val(GetToken(Query(MacroCmdLine)," ",2))
end

/****************************************************************************\
    click panel
\****************************************************************************/

proc PaintClick( integer state )
    integer l,a
    integer x1 = CurrChar(POS_X1)
    integer x2 = CurrChar(POS_X2)
    integer y1 = CurrChar(POS_Y1)
    integer y2 = CurrChar(POS_Y2)

    case state
        when STATE_NORMAL   a = Color( black on cyan )
        when STATE_ACTIVE   a = Color( bright yellow on red )
        otherwise           a = Color( black on white )
    endcase

    Set(Attr,a)
    for l = y1 to y2-1
        VGotoXY(x1,l)
        PutAttr(a,x2-x1)
    endfor
    PutCtrStr("click here",y1)
    PutCtrStr("or use the spacebar",y1+1)
end

proc ExecClick()
    integer move_focus = Val(Query(MacroCmdLine))

    Set(MacroCmdLine,Str(STATE_ACTIVE))
    PaintClick(STATE_ACTIVE)
    case move_focus
        when EVENT_MOUSE
            Alarm()
        when EVENT_OTHER
            if Query(Key) == <Spacebar>
                Alarm()
            endif
    endcase
end

/****************************************************************************\
    user defined controls
\****************************************************************************/

public proc Test2PaintCntrl()
    integer state = Val(Query(MacroCmdLine))

    if CurrChar(POS_ID) == id_text
        PaintText(state)
    else
        PaintClick(state)
    endif
end

public proc Test2GotoCntrl()
    integer move_focus = Val(Query(MacroCmdLine))

    Set(MacroCmdLine,Str(move_focus <> EVENT_GROUP))
end

public proc Test2ExecCntrl()
    if CurrChar(POS_ID) == id_click
        ExecClick()
    else
        ExecText()
    endif
end

/****************************************************************************\
    focus changes
\****************************************************************************/

public proc Test2SetFocus()
    if CurrChar(POS_ID) == id_click
        Message("just got the focus")
    endif
end

public proc Test2KillFocus()
    if CurrChar(POS_ID) == id_click
        Message("just lost the focus")
    endif
end

/****************************************************************************\
    button clicks
\****************************************************************************/

public proc Test2BtnDown()
    if CurrChar(POS_ID) == id_beep
        Alarm()
        ExecMacro(Format(
            "MsgBox ",
            Chr(MB_WARN),
            Chr(MB_YESNOCANCEL),
            Chr(CNTRL_CTEXT),"too much noise"
        ))
        Message("return code = ",Query(MacroCmdLine))
        Set(MacroCmdLine,"0")
    endif
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer dlg

    Set(break,ON)

    text_pos = 1

    dlg = CreateTempBuffer()
    InsertData(testdlg2)
    ExecMacro("dialog test2")
    AbandonFile(dlg)

    Message("return code = ",Query(MacroCmdLine))
    PurgeMacro(CurrMacroFilename())
end

