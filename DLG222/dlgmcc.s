/****************************************************************************\

    DlgMCC.S

    Macro Control Center.

    Version         v2.20/17.06.02
    Copyright       (c) 1995-2002 by DiK

    Overview:

    This dialog allows you to execute all macro related tasks from
    one place. See on-line help for a more detailed description.

    Keys:       (none)

    History

    v2.20/17.06.02  adaption to TSE32 v4.0
                    + fixed listing ui macro
    v2.10/30.11.00  adaption to TSE32 v3.0
                    + centered dialogs and help
                    + fixed size of edit control
    v2.01/03.04.97  bug fix
                    + close dialog while purging macros
    v2.00/24.10.96  adaption TSE32
                    + added hiding of dialogp
                    + fixed quoting long filenames
                    + fixed getting macro list (new format)
    v1.21/29.05.96  maintenance
                    + use Set(MsgLevel) instead of PushKey(<Escape>)
    v1.20/25.03.96  maintenance
                    + added hint lines
                    + moved GotoMacDir to DlgOpen
                    + changed MakeMacroList (faster and without flicker)
                    + fixed version checking
                    + some clean up of source code
    v1.10/12.01.96  maintenance
                    + added <del> translation
                    + added <ins> translation
                    + added new Unload button
                    + renamed previous Unload to Purge
    v1.00/11.10.95  first version

    Remarks:

    This macro uses internal, undocumented data structures of TSE.
    E.g., it works with versions 2.5 through 3.0 of TSE, but
    there is absolutely no guarantee that it will also work with
    any future version of the editor.

\****************************************************************************/

/****************************************************************************\
    macro list format (version dependant)
\****************************************************************************/

#ifdef WIN32
    constant SIZE_POS  = 12
    constant START_COL = 13
#else
    constant SIZE_POS  = 8
    constant START_COL = 9
#endif

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"
#include "msgbox.si"
#include "dlgmcc.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "dlgmcc.dlg"

/****************************************************************************\
    shared code
\****************************************************************************/

#define INC_QUOTE 1
#define INC_GETTOKEN 1

#include "scver.si"
#include "scrun.si"
#include "sctoken.si"
#include "schelp.si"

/****************************************************************************\
    global variables
\****************************************************************************/

integer resource                        // buffer id (dialog resource)
integer macslist                        // ditto (list of loaded macros)
integer userfile                        // ditto (current file at startup)

string mac[255]

/****************************************************************************\
    help screen
\****************************************************************************/

constant HLP_WIDTH = 70

helpdef DlgMCCHelp
    title = "Help on Macro Control Center"
    width = HLP_WIDTH
    height = 18
    y = 3

    ""
    "   This dialog allows you to execute all SAL macro related tasks"
    "   from one central place."
    ""
    "   Summary of commands:"
    ""
    "   Exec        execute the specified macro"
    "   Cancel      close the dialog"
    "   Search      search and execute a macro"
    "   Load        load a macro (<ins>)"
    "   Purge       purge the specified macro (<del>)"
    "   Unload      unload the dialog run time library"
    ""
    "   Executing macros:"
    ""
    "   To immediately execute a macro after the dialog has popped up,"
    "   just enter its name and press <Enter>. Alternatively, you can "
    "   tab to the list of loaded macros and select one of them to be"
    "   executed. Finally, you can push the Search button to pop up the"
    "   Execute Macro dialog and search your disk for macros to be"
    "   executed."
    ""
    "   Loading and purging macros:"
    ""
    "   To load a macro without immediately executing it push the Load"
    "   button. This will pop up the Load Macro dialog, which allows"
    "   you to search your disk for macros to be loaded. To purge a"
    "   macro you do not need any longer, mark it within the list of"
    "   loaded macros and push the Purge button."
    ""
    "   Unloading the dialog library:"
    ""
    "   On default, the dialog library remains loaded after the first"
    "   dialog has been executed. If you want to unload the library for"
    "   some reason, push the Unload button."
    ""
end

/****************************************************************************\
    create list of loaded macros
\****************************************************************************/

proc RemoveEntryFromList( string mac )
    if lFind(mac,"gi^$")
        MarkLine()
        if lFind("^[~ ]","x+")
            Up()
        else
            EndFile()
        endif
        KillBlock()
    endif
end

proc MakeMacroList()

    // copy list of loaded macros

    GotoBufferId(4)
    MarkLine(1,NumLines())
    GotoBufferId(macslist)
    EmptyBuffer()
    CopyBlock()
    UnmarkBlock()

    // remove binary info from list

    BegFile()
    repeat
        if CurrChar(3)
            GotoPos(START_COL+CurrChar(SIZE_POS))
            KillToEol()
        else
            GotoPos(START_COL)
            InsertText("    ",_INSERT_)
        endif
    until not Down()
    MarkColumn(1,1,NumLines(),START_COL-1)
    KillBlock()

    // remove self and dialog from list

    RemoveEntryFromList(".ui")
    RemoveEntryFromList("dlgmcc")
    RemoveEntryFromList("dialog")
    RemoveEntryFromList("dialogp")
    BegFile()

    // return to resource

    GotoBufferId(resource)
end

/****************************************************************************\
    set dialog data
\****************************************************************************/

public proc MCCDataInit()
    if CheckVersion("DlgMCC",2,0)
        ExecMacro("DlgTerminate")
        return ()
    endif
    MakeMacroList()
    mac = GetHistoryStr(_EXECMACRO_HISTORY_,1)
    ExecMacro(Format("DlgSetData ",ID_LST_MAC," ",macslist))
    ExecMacro(Format("DlgSetData ",ID_EDT_MAC," ",_EXECMACRO_HISTORY_))
    ExecMacro(Format("DlgSetTitle ",ID_EDT_MAC," ",mac))
end

/****************************************************************************\
    message response functions
\****************************************************************************/

proc IdLstMac()
    integer bid

    bid = GotoBufferId(macslist)
    mac = QuotePath(LTrim(GetText(1,CurrLineLen())))
    GotoBufferId(bid)
    ExecMacro(Format("DlgSetTitle ",ID_EDT_MAC," ",mac))
end

/****************************************************************************\
    button response functions
\****************************************************************************/

proc IdBtnFind()
    ExecDialog("dlgopen -x -e")
    if Val(Query(MacroCmdLine)) == ID_OK
        mac = GetHistoryStr(_EXECMACRO_HISTORY_,1)
        ExecMacro(Format("DlgTerminate ",ID_OK))
    else
        MakeMacroList()
        ExecMacro(Format("DlgExecCntrl ",ID_LST_MAC))
    endif
end

proc IdBtnLoad()
    ExecDialog("dlgopen -l")
    MakeMacroList()
    ExecMacro(Format("DlgExecCntrl ",ID_LST_MAC))
end

proc IdBtnUnload()
    ExecDialog(Format(
        "MsgBox ",
        Chr(MB_OKCANCEL),
        Chr(MB_PROMPT),
        Chr(CNTRL_CTEXT),"Close MCC and undload Dialog library?"
    ))
    if Val(Query(MacroCmdLine)) == ID_OK
        ExecMacro("DlgSetUnload 1")
        ExecMacro("DlgTerminate")
    endif
end

/****************************************************************************\
    Purge button

    remark:
    dialog (popup) window is closed before macros is actually purged,
    since WhenPurged function might alter TSE's window layout (OneWindow)
\****************************************************************************/

proc IdBtnPurge()
    integer rc, bid

    ExecMacro(Format("DlgGetTitle ",ID_EDT_MAC))
    mac = Lower(SplitPath(Query(MacroCmdLine),_NAME_))

    if isMacroLoaded(mac)
        if mac in "dialog","dlgmcc"
            Alarm()
            ExecDialog(Format(
                "MsgBox ",
                Chr(MB_OK),
                Chr(MB_ERROR),
                Chr(CNTRL_CTEXT),"Cannot unload running macro!"
            ))
        else
            ExecMacro("DlgShowWindow 0")
            bid = GotoBufferId(userfile)    // just in case that
            rc = PurgeMacro(mac)            // purging updates the screen
            GotoBufferId(macslist)
            if rc
                RemoveEntryFromList(mac)
            else
                Alarm()
            endif
            if CurrLine() > NumLines()
                EndFile()
            endif
            GotoBufferId(bid)
            ExecMacro("DlgShowWindow 1")
        endif
    else
        Alarm()
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_OK),
            Chr(MB_ERROR),
            Chr(CNTRL_CTEXT),"Macro is not loaded!"
        ))
    endif

    ExecMacro(Format("DlgExecCntrl ",ID_LST_MAC))
end

/****************************************************************************\
    Ok button
\****************************************************************************/

proc IdOk()
    integer rc, ml
    string cmd[255]

    ExecMacro(Format("DlgGetTitle ",ID_EDT_MAC))
    mac = Query(MacroCmdLine)

    cmd = GetQuotedToken(mac,1)
    rc = isMacroLoaded(cmd)
    if not rc
        ml = Set(MsgLevel,_NONE_)
        rc = LoadMacro(QuotePath(cmd))
        Set(MsgLevel,ml)
    endif

    if rc
        ExecMacro(Format("DlgTerminate ",ID_OK))
        return ()
    endif

    Alarm()
    ExecDialog(Format(
        "MsgBox ",
        Chr(MB_OKCANCEL),
        Chr(MB_ERROR),
        Chr(CNTRL_CTEXT),"Macro not found! Search it?"
    ))
    if Val(Query(MacroCmdLine)) == ID_OK
        IdBtnFind()
        return ()
    endif

    ExecMacro(Format("DlgExecCntrl ",ID_EDT_MAC))
end

/****************************************************************************\
    message response functions
\****************************************************************************/

public proc MCCEvent()
    if CurrChar(POS_ID) <> ID_EDT_MAC
        if Query(Key) == <Del>
            Set(Key,<Alt P>)
        elseif Query(Key) == <Ins>
            Set(Key,<Alt L>)
        endif
    endif
end

public proc MCCSetFocus()
    case CurrChar(POS_ID)
        when ID_LST_MAC     IdLstMac()
    endcase
end

public proc MCCSelChanged()
    MCCSetFocus()
end

public proc MCCDblClick()
    IdOk()
end

public proc MCCBtnDown()
    case CurrChar(POS_ID)
        when ID_OK          IdOk()
        when ID_BTN_FIND    IdBtnFind()
        when ID_BTN_LOAD    IdBtnLoad()
        when ID_BTN_PURGE   IdBtnPurge()
        when ID_BTN_UNLOAD  IdBtnUnload()
        when ID_HELP        InitHelp(HLP_WIDTH) QuickHelp(DlgMCCHelp)
    endcase
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer rc

    // run dialog

    PushBlock()
    userfile = GetBufferId()
    macslist = CreateTempBuffer()
    resource = CreateTempBuffer()
    rc = macslist
        and resource
        and InsertData(dlgmcc)
        and ExecDialog("dialog mcc")
    AbandonFile(resource)
    AbandonFile(macslist)
    GotoBufferId(userfile)
    PopBlock()
    UpdateDisplay(_HELPLINE_REFRESH_)

    // check for errors and execute macro

    if rc
        if Val(Query(MacroCmdLine)) == ID_OK
            AddHistoryStr(mac,_EXECMACRO_HISTORY_)
            ExecMacro(mac)
        endif
    else
        Warn("DlgMCC: Error executing Macro Control Center")
    endif

    // purge self

    PurgeMacro(CurrMacroFilename())
end

