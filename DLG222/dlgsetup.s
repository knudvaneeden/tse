/****************************************************************************\

    DlgSetup.S

    Interactive setup for Dialog.S.

    Version         v2.20/09.04.02
    Copyright       (c) 1995-2002 by DiK

    Overview:

    This macro allows you to interactively change Dialog options.
    It also includes an editor for the Dialog color scheme.

    Keys:       (none)

    History

    v2.20/09.04.02  adaption to TSE32 v4.0
                    + fixed painting oem characters
    v2.11/08.01.02  maintenance
                    + added bright background colors
    v2.10/30.11.00  adaption to TSE32 v3.0
                    + centered dialogs and help
    v2.01/17.03.97  maintenance
                    + fixed video output
    v2.00/24.10.96  adaption to TSE32
                    + added buffered video output
    v1.23/28.06.96  maintenance
                    + position of color editor
    v1.20/25.03.96  maintenance
                    + some cleanup of source code
    v1.00/12.01.96  first version

\****************************************************************************/

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"
#include "msgbox.si"
#include "dlgsetu1.si"
#include "dlgsetu2.si"

/****************************************************************************\
    dialog resources
\****************************************************************************/

#include "dlgsetu1.dlg"
#include "dlgsetu2.dlg"

/****************************************************************************\
    shared code
\****************************************************************************/

#include "scver.si"
#include "scrun.si"
#include "schelp.si"

/****************************************************************************\
    global variables
\****************************************************************************/

integer ressetup                        // dialog resource buffer
integer resclred                        // ditto
integer clr_buff                        // dialog color file
integer ctrl_typ                        // list box buffer
integer ctrl_clr                        // ditto

integer dirty                           // flag (colors have been changed)
integer curr_clr                        // current color attribute
integer saved_clr                       // saved color attribute

integer new_delay, old_delay            // double click delay
integer new_purge, old_purge            // unload library after exit
integer switched                        // flag (test panel clicked)

string ver[8]                           // dialogs version

string title[] = "Dialog Setup"

/****************************************************************************\
    help screens
\****************************************************************************/

constant HLP_WIDTH = 80

helpdef SetupHelp
    title = "Help on Dialog Setup"
    width = HLP_WIDTH
    height = 18
    y = 3

    ""
    "   This dialog is used to change the dialog options and colors."
    ""
    "   Summary of commands:"
    ""
    "   Ok              save changes and close"
    "   Cancel          abort changes"
    "   Edit Colors     execute the color editor"
    "   Restore         delete custom configuration and use defaults"
    "   Version         display the Dialogs version number"
    ""
    "   Double Click Delay:"
    ""
    "   This value is the time (measured in clock ticks or 1/18th of"
    "   a second) which may pass between two mouse clicks and still"
    "   qualifies the second click as a double click. Use the cursor"
    "   keys or the mouse to move the dial. You can use the color panel"
    "   just below the dial to test double click timing. The panel will"
    "   beep and change its color if you double click on it. If nothing"
    "   happens the double click delay is probably too short."
    "   "
    "   Other Options:"
    "   "
    "   Check Always Unload if you want Dialogs to unload itself each"
    "   time a dialog is closed. This saves macro space, but also slows"
    "   down loading dialog boxes. You should probably leave this one"
    "   unchecked unless you start running out of memory or macro space."
    "   "
    "   Restore:"
    "   "
    "   Simply deletes the configuration file and aborts Setup, which"
    "   restores the default configuration. It does warn you about its"
    "   activities beforehand though."
    "   "
    "   Version:"
    "   "
    "   Pops up a message box which shows the version number of the"
    "   dialog run time library."
    ""
end

helpdef ClrEdHelp
    title = "Help on Dialog Color Editor"
    width = HLP_WIDTH
    height = 21
    y = 2

    ""
    "   This dialog is used to edit the color palette of the dialog library."
    ""
    "   Summary of commands:"
    ""
    "   Ok                  accept changes and close"
    "   Cancel              abort changes"
    "   Display Colors      activate and show new colors"
    ""
    "   Control Types lists the names of all predefined control types and"
    "   probably also the names of some custom controls (everything below"
    "   DropDown is a custom control). The colors which each control type"
    "   utilizes are listed under Control Colors. The contents of this list"
    "   changes when you move the selection bar within the Control Types"
    "   list box. The Color Panel displays the currently chosen color for"
    "   the selected control and color item. To change the current color"
    "   use the cursor keys or simply click the panel with the mouse. The"
    "   color editor displays the attribute value of the current color both"
    "   in hex and decimal and it also includes some example text. You cannot"
    "   interact with these fields in any way."
    ""
end

/****************************************************************************\
    load and save setup file
\****************************************************************************/

integer proc LoadSetupFile()
    integer bid
    string name[128]

    name = SearchPath("dialog.cfg",Query(TsePath),"mac")

    if FileExists(name) == 0
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_YESNO),
            Chr(MB_TITLE),title,Chr(13),
            Chr(CNTRL_CTEXT),"Setup file does not exist! Create?"
        ))
        if Val(Query(MacroCmdLine)) == ID_NO
            return (TRUE)
        endif
        ExecMacro("DlgSaveSetup")
        name = SearchPath("dialog.cfg",Query(TsePath),"mac")
    endif

    bid = GotoBufferId(clr_buff)
    EmptyBuffer()
    InsertFile(name)
    UnmarkBlock()
    GotoBufferId(bid)

    dirty = FALSE
    return (FALSE)
end

proc SaveSetupFile()
    integer bid
    string name[128]

    name = SearchPath("dialog.cfg",Query(TsePath),"mac")

    bid = GotoBufferId(clr_buff)
    SaveAs(name,_OVERWRITE_|_DONT_PROMPT_)
    GotoBufferId(bid)
end

/****************************************************************************\
    parse general configuration info
\****************************************************************************/

integer proc GetCfgVar( string name )
    if lFind(name,"gi^")
        return (CurrChar(CurrLineLen()))
    endif
    return (-1)
end

proc PutCfgVar( string name, integer value )
    if lFind(name,"gi^")
        GotoPos(CurrLineLen())
        InsertText(Chr(value),_OVERWRITE_)
    endif
end

proc ParseConfigInfo()
    integer bid

    bid = GotoBufferId(clr_buff)
    old_delay = GetCfgVar("MD")
    old_purge = GetCfgVar("UL")
    new_delay = old_delay
    new_purge = old_purge
    GotoBufferId(bid)
end

integer proc SaveConfigInfo()
    integer bid

    if new_delay == old_delay and new_purge == old_purge
        return (FALSE)
    endif

    bid = GotoBufferId(clr_buff)
    PutCfgVar("MD",new_delay)
    PutCfgVar("UL",new_purge)
    GotoBufferId(bid)
    return (TRUE)
end

/****************************************************************************\
    parse colors within setup file
\****************************************************************************/

proc ParseCntrlTypes()
    integer bid
    string cntrl_type[32]

    bid = GotoBufferId(clr_buff)
    EndFile()
    repeat
        cntrl_type = GetText(1,CurrLineLen())
        if cntrl_type[Length(cntrl_type)-1] == ""
            cntrl_type = GetToken(cntrl_type,"_",1)
            GotoBufferId(ctrl_typ)
            if not lFind(cntrl_type,"^g")
                BegFile()
                InsertLine(cntrl_type)
            endif
            GotoBufferId(clr_buff)
        endif
    until not Up()
    GotoBufferId(bid)
end

proc ParseColorTypes()
    integer bid
    string cntrl_type[32]
    string color_type[32]

    EmptyBuffer(ctrl_clr)
    bid = GotoBufferId(ctrl_typ)
    cntrl_type = GetText(1,CurrLineLen())
    GotoBufferId(clr_buff)
    EndFile()
    lFind(cntrl_type,"^gb")
    repeat
        color_type = GetToken(GetText(1,CurrLineLen()),"_",2)
        InsertLine(color_type,ctrl_clr)
    until not lRepeatFind()
    GotoBufferId(bid)
end

/****************************************************************************\
    color editor: get and set color data
\****************************************************************************/

proc GetCurrColor()
    integer bid
    string clr[64]

    bid = GotoBufferId(ctrl_typ)
    clr = GetText(1,CurrLineLen())
    GotoBufferId(ctrl_clr)
    clr = clr + "_" + GetText(1,CurrLineLen()) + ""
    GotoBufferId(clr_buff)
    lFind(clr,"^g")
    curr_clr = CurrChar(CurrLineLen())
    GotoBufferId(bid)

    ExecMacro(Format("DlgSetTitle ",ID_TXT_HEX," ",Str(curr_clr,16)))
    ExecMacro(Format("DlgSetTitle ",ID_TXT_DEC," ",Str(curr_clr)))
    ExecMacro(Format("DlgPaintCntrl ",ID_CTL_COLORS))
    ExecMacro(Format("DlgPaintCntrl ",ID_CTL_EXAMPLE))
end

proc SetCurrColor()
    integer bid
    string clr[64]

    bid = GotoBufferId(ctrl_typ)
    clr = GetText(1,CurrLineLen())
    GotoBufferId(ctrl_clr)
    clr = clr + "_" + GetText(1,CurrLineLen()) + ""
    GotoBufferId(clr_buff)
    lFind(clr,"^g")
    GotoColumn(CurrLineLen())
    InsertText(Chr(curr_clr),_OVERWRITE_)
    GotoBufferId(bid)
end

/****************************************************************************\
    color editor: example text
\****************************************************************************/

proc PaintExample()
    integer x1 = CurrChar(POS_X1)
    integer y1 = CurrChar(POS_Y1)
    string text[32] = "text text text"

#ifdef WIN32
    BufferVideo()
#endif

    Set(Attr,curr_clr)
    do 3 times
        VGotoXY(x1,y1)
        PutStr(text)
        y1 = y1 + 1
    enddo

#ifdef WIN32
    UnBufferVideo()
#endif

end

/****************************************************************************\
    color editor: color panel
\****************************************************************************/

proc PaintPanel()
    integer fr, bk
    integer x1 = CurrChar(POS_X1)
    integer y1 = CurrChar(POS_Y1) + 1

#ifdef WIN32
    BufferVideo()
#endif

    ExecMacro(Format("DlgPaintCntrl ",ID_FRM_COLORS))

    for bk = 0 to 15
        Set( Attr, bk shl 4 | bk )
        VGotoXY( 2*bk + x1, y1 - 1 )
        PutStr("  ")
    endfor

    for fr = 0 to 15
        for bk = 0 to 15
            Set( Attr, bk shl 4 | fr )
            VGotoXY( 2*bk + x1, fr + y1 )
            PutStr("++")
        endfor
    endfor

    for bk = 0 to 15
        Set( Attr, bk shl 4 | bk )
        VGotoXY( 2*bk + x1, y1 + 16 )
        PutStr("  ")
    endfor

    fr = curr_clr & 0xF
    bk = curr_clr shr 4
    Set( Attr, bk shl 4 | iif( bk > 10, 0, 12) )

#if EDITOR_VERSION <= 0x3000

    VGotoXY( 2*bk + x1 - 1, fr + y1 - 1 )
    PutStr("ÛßßÛ")
    VGotoXY( 2*bk + x1 - 1, fr + y1 )
    PutChar("Û")
    VGotoXY( 2*bk + x1 + 2, fr + y1 )
    PutChar("Û")
    VGotoXY( 2*bk + x1 - 1, fr + y1 + 1 )
    PutStr("ÛÜÜÛ")

#else

    VGotoXY( 2*bk + x1 - 1, fr + y1 - 1 )
    PutOemLine("ÛßßÛ", 4)
    VGotoXY( 2*bk + x1 - 1, fr + y1 )
    PutOemChar("Û")
    VGotoXY( 2*bk + x1 + 2, fr + y1 )
    PutOemChar("Û")
    VGotoXY( 2*bk + x1 - 1, fr + y1 + 1 )
    PutOemLine("ÛÜÜÛ", 4)

#endif

#ifdef WIN32
    UnBufferVideo()
#endif

end

proc ExecPanel()
    integer code
    integer fr, bk

    ExecMacro("DlgInitMouseLoop")

    loop
        ExecMacro(Format("DlgSetTitle ",ID_TXT_HEX," ",curr_clr:2:"0":16))
        ExecMacro(Format("DlgSetTitle ",ID_TXT_DEC," ",curr_clr))
        ExecMacro(Format("DlgPaintCntrl ",ID_CTL_EXAMPLE))
        PaintPanel()

        fr = curr_clr & 0xF
        bk = curr_clr shr 4

        ExecMacro("DlgGetEvent")
        code = Val(Query(MacroCmdLine))

        case code
            when <PgUp>         fr = 0
            when <PgDn>         fr = 15
            when <Home>         bk = 0
            when <End>          bk = 15
            when <CursorUp>     fr = fr-1   if fr < 0   fr = 15  endif
            when <CursorDown>   fr = fr+1   if fr > 15  fr = 0   endif
            when <CursorLeft>   bk = bk-1   if bk < 0   bk = 15  endif
            when <CursorRight>  bk = bk+1   if bk > 15  bk = 0   endif

            when <LeftBtn>
                ExecMacro("DlgMouseClick")
                if Val(Query(MacroCmdLine))
                    ExecMacro("DlgMouseXOffset")
                    bk = Val(Query(MacroCmdLine)) / 2
                    ExecMacro("DlgMouseYOffset")
                    fr = Val(Query(MacroCmdLine)) - 1
                    fr = Max(0,Min(fr,15))
                else
                    break
                endif

            otherwise
                break
        endcase

        curr_clr = bk shl 4 | fr
    endloop

    PushKey(code)
end

/****************************************************************************\
    color editor: custom control response functions

    remark: don't need to exec color example, it's disabled
\****************************************************************************/

public proc ClrEdPaintCntrl()
    if CurrChar(POS_ID) == ID_CTL_COLORS
        PaintPanel()
    else
        PaintExample()
    endif
end

public proc ClrEdGotoCntrl()
    integer move_focus = Val(Query(MacroCmdLine))

    Set(MacroCmdLine,Str(move_focus <> EVENT_GROUP))
end

public proc ClrEdExecCntrl()
    ExecPanel()
end

/****************************************************************************\
    color editor: activate colors
\****************************************************************************/

proc IdBtnApply()
    integer bid

    bid = GotoBufferId(clr_buff)
    BegFile()
    repeat
        if CurrChar(CurrLineLen()-1) == Asc("")
            ExecMacro(Format("DlgSetColor ",
                GetText(1,CurrLineLen()-2)," ",CurrChar(CurrLineLen())))
        endif
    until not Down()
    ExecMacro("DlgPaintWindow")
    GotoBufferId(bid)
end

/****************************************************************************\
    color editor: init dialog data
\****************************************************************************/

public proc ClrEdDataInit()
    GetCurrColor()
    ExecMacro(Format("DlgSetData ",ID_LST_CONTROL," ",ctrl_typ))
    ExecMacro(Format("DlgSetData ",ID_LST_CLRTYPE," ",ctrl_clr))
end

/****************************************************************************\
    color editor: message response functions
\****************************************************************************/

public proc ClrEdSelChanged()
    if CurrChar(POS_ID) == ID_LST_CONTROL
        ParseColorTypes()
        ExecMacro(Format("DlgPaintCntrl ",ID_LST_CLRTYPE))
    endif
    if CurrChar(POS_ID) in ID_LST_CONTROL,ID_LST_CLRTYPE
        GetCurrColor()
    endif
end

public proc ClrEdSetFocus()
    if CurrChar(POS_ID) == ID_CTL_COLORS
        saved_clr = curr_clr
    endif
end

public proc ClrEdKillFocus()
    if CurrChar(POS_ID) == ID_CTL_COLORS
        if saved_clr <> curr_clr
            SetCurrColor()
        endif
    endif
end

public proc ClrEdBtnDown()
    case CurrChar(POS_ID)
        when ID_OK          ExecMacro("DlgTerminate")
        when ID_BTN_APPLY   IdBtnApply()
        when ID_HELP        InitHelp(HLP_WIDTH) QuickHelp("ClrEdHelp")
    endcase
end

/****************************************************************************\
    setup: double click delay
\****************************************************************************/

proc PaintMeter( integer state )
    integer x1 = CurrChar(POS_X1)
    integer y1 = CurrChar(POS_Y1)

    ExecMacro("DlgGetColor Check_Normal")
    Set(Attr,Val(Query(MacroCmdLine)))

#ifdef WIN32
    BufferVideo()
#endif

    VGotoXY(x1,y1)

#if EDITOR_VERSION <= 0x3000
    PutStr(" 1úúúþúúú10úúúúþúúú20úú ")
#else
    PutOemLine(" 1úúúþúúú10úúúúþúúú20úú ", 24)
#endif

    VGotoXY(x1+new_delay,y1)
    if state == STATE_ACTIVE
        ExecMacro("DlgGetColor Edit_Normal")
    else
        ExecMacro("DlgGetColor Edit_Disabled")
    endif
    PutAttr(Val(Query(MacroCmdLine)),1)

#ifdef WIN32
    UnBufferVideo()
#endif

end

proc ExecMeter()
    integer code
    integer xl = CurrChar(POS_X2) - CurrChar(POS_X1) - 1

    ExecMacro("DlgInitMouseLoop")

    loop
        PaintMeter(STATE_ACTIVE)

        ExecMacro("DlgGetEvent")
        code = Val(Query(MacroCmdLine))

        case code
            when <LeftBtn>
                ExecMacro("DlgMouseClick")
                if Val(Query(MacroCmdLine))
                    ExecMacro("DlgMouseXOffset")
                    new_delay = Val(Query(MacroCmdLine))
                else
                    break
                endif
            when <CursorLeft>
                new_delay = Max(0,new_delay-1)
            when <CursorRight>
                new_delay = Min(xl,new_delay+1)
            when <PgUp>
                new_delay = Max(0,new_delay-5)
            when <PgDn>
                new_delay = Min(xl,new_delay+5)
            when <Home>
                new_delay = 0
            when <End>
                new_delay = xl
            otherwise
                break
        endcase
    endloop

    ExecMacro(Format("DlgSetDblTime ",new_delay))
    PushKey(code)
end

/****************************************************************************\
    setup: double click panel
\****************************************************************************/

proc PaintTest()
    integer attr
    integer x1 = CurrChar(POS_X1)
    integer y1 = CurrChar(POS_Y1)
    integer xl = CurrChar(POS_X2) - x1
    integer yl = CurrChar(POS_Y2) - y1

    if switched
        ExecMacro("DlgGetColor Button_Normal")
    else
        ExecMacro("DlgGetColor Check_Normal")
    endif
    attr = Val(Query(MacroCmdLine))

#ifdef WIN32
    BufferVideo()
#endif

    do yl times
        VGotoXY(x1,y1)
        PutAttr(attr,xl)
        y1 = y1 + 1
    enddo

#ifdef WIN32
    UnBufferVideo()
#endif

end

proc ExecTest()
    integer move_focus = Val(Query(MacroCmdLine))
    integer code

    if move_focus == EVENT_TAB
        PushKey(Query(Key))
        return ()
    endif

    ExecMacro("DlgInitMouseLoop")

    loop
        ExecMacro("DlgGetEvent")
        code = Val(Query(MacroCmdLine))

        if code == <LeftBtn>
            ExecMacro("DlgMouseClick")
            if Val(Query(MacroCmdLine))
                ExecMacro("DlgMouseDoubleClick")
                if Val(Query(MacroCmdLine))
                    switched = not switched
                    PaintTest()
                    Alarm()
                endif
            else
                break
            endif
        else
            break
        endif
    endloop

    PushKey(code)
end

/****************************************************************************\
    setup: custom control response functions
\****************************************************************************/

public proc SetupPaintCntrl()
    if CurrChar(POS_ID) == ID_CTL_TEST
        PaintTest()
    else
        PaintMeter(Val(Query(MacroCmdLine)))
    endif
end

public proc SetupGotoCntrl()
    integer move_focus = Val(Query(MacroCmdLine))

    Set(MacroCmdLine,Str(move_focus <> EVENT_GROUP))
end

public proc SetupExecCntrl()
    if CurrChar(POS_ID) == ID_CTL_TEST
        ExecTest()
    else
        ExecMeter()
    endif
end

/****************************************************************************\
    setup: init dialog data
\****************************************************************************/

public proc SetupDataInit()

    // check dialog version

    if CheckVersion("DlgSetup",2,0)
        ExecMacro("DlgTerminate")
        return ()
    endif

    ExecMacro("DlgGetVersion")
    ver = Query(MacroCmdLine)

    // load and parse setup information

    if LoadSetupFile()
        ExecMacro(Format("DlgTerminate ",ID_CANCEL))
        return ()
    endif
    ParseConfigInfo()
    ParseCntrlTypes()
    ParseColorTypes()

    // set dialog data

    ExecMacro(Format("DlgSetData ",ID_CHK_PURGE," ",new_purge))
end

/****************************************************************************\
    setup: unload library when done
\****************************************************************************/

public proc SetupDataDone()

    // get dialog data

    ExecMacro(Format("DlgGetData ",ID_CHK_PURGE))
    new_purge = Val(Query(MacroCmdLine))

    // save canfiguration if necessary

    if CurrChar(POS_ID) == ID_OK and (dirty or SaveConfigInfo())
        SaveSetupFile()
    endif

    // unconditionally unload library

    ExecMacro("DlgSetUnload 1")
end

/****************************************************************************\
    setup: button actions
\****************************************************************************/

proc IdBtnClr()
    integer bid

    bid = GotoBufferId(resclred)
    if ExecDialog("dialog clred")
        if Val(Query(MacroCmdLine)) == ID_OK
            dirty = TRUE
            IdBtnApply()
        endif
    endif
    GotoBufferId(bid)
end

proc IdBtnDef()
    string name[128]

    name = SearchPath("dialog.cfg",Query(TsePath),"mac")

    Alarm()
    PushKey(<Tab>)
    ExecDialog(Format(
        "MsgBox ",
        Chr(MB_YESNO),
        Chr(MB_NOTITLE),
        Chr(CNTRL_CTEXT),"Restore default config and colors?"
    ))
    if Val(Query(MacroCmdLine)) == ID_YES
        EraseDiskFile(name)
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_OK),
            Chr(MB_NOTITLE),
            Chr(CNTRL_CTEXT),"Setup will be closed",Chr(13),
            Chr(CNTRL_CTEXT),"Reload to create and edit a new cfg file"
        ))
        ExecMacro(Format("DlgTerminate"))
    endif
end

proc IdBtnVer()
    ExecDialog(Format(
        "MsgBox ",
        Chr(MB_OK),
        Chr(MB_NOTITLE),
        Chr(CNTRL_CTEXT),"Dialog Runtime Library",Chr(13),
        Chr(CNTRL_CTEXT),"Version ",ver
    ))
end

/****************************************************************************\
    setup: message response functions
\****************************************************************************/

public proc SetupBtnDown()
    case CurrChar(POS_ID)
        when ID_OK              ExecMacro("DlgTerminate")
        when ID_BTN_CLR         IdBtnClr()
        when ID_BTN_DEF         IdBtnDef()
        when ID_BTN_VER         IdBtnVer()
        when ID_HELP            InitHelp(HLP_WIDTH) QuickHelp("SetupHelp")
    endcase
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer rc, loaded

    // allocate work space

    PushBlock()

    ctrl_typ = CreateTempBuffer()               // color data
    ctrl_clr = CreateTempBuffer()
    clr_buff = CreateTempBuffer()
    rc = ctrl_typ
        and ctrl_clr
        and clr_buff
    if rc
        BinaryMode(-1)
    endif
    resclred = CreateTempBuffer()               // color editor
    rc = rc
        and resclred
        and InsertData(dlgsetu2)
    ressetup = CreateTempBuffer()
    rc = rc                                     // main setup dialog
        and ressetup
        and InsertData(dlgsetu1)

    // execute setup

    if rc
        loaded = isMacroLoaded("dialog")
        if loaded
        and ExecMacro("DlgGetRefCount") and Val(Query(MacroCmdLine)) > 0
            ExecDialog(Format(
                "MsgBox ",
                Chr(MB_OK),
                Chr(MB_TITLE),title,Chr(13),
                Chr(CNTRL_CTEXT),"Cannot execut Setup.",Chr(13),
                Chr(CNTRL_CTEXT),"Close all other dialogs first."
            ))
        else
            if loaded
                rc = PurgeMacro("dialog")
            endif
            if rc
                GotoBufferId(ressetup)
                rc = ExecDialog("dialog setup")
            endif
        endif
    endif

    // check for errors

    if not rc
        Warn("DlgSetup: Error executing setup dialog")
    endif

    // clean up

    AbandonFile(ressetup)
    AbandonFile(resclred)
    AbandonFile(ctrl_typ)
    AbandonFile(ctrl_clr)
    AbandonFile(clr_buff)

    PopBlock()
    PurgeMacro(CurrMacroFilename())
    UpdateDisplay(_HELPLINE_REFRESH_)
end

