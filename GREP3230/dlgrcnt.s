/****************************************************************************\

    DlgRcnt.S

    Display the recent files list.

    Version         v2.21/13.05.03
    Copyright       (c) 1995-2003 by DiK

    Overview:

    This dialog displays a list of the files that were most recently
    accessed, and allows you to select a file from the list to be edited.
    Besides that, you can remove entries no longer needed (Remove) and
    start the OpenFile dialog, when you cannot find the item you wanted.

    Keys:       (none)

    Usage Notes:

    This macro must be called from the burned in user interface.
    Call: ExecMacro("DlgRcnt "+Str(GotoRecentFileBuffer()))

    Version Notes:

    The GotoRecentFileBuffer function cannot be used as implemented in
    TSE.UI v2.6, since this no longer returns the current buffer id.
    But this issue is easily fixed, c.f. DLG.UI which includes a slightly
    enhanced version of GotoRecentFileBuffer.


    History

    v2.21/13.05.03  maintenance
                    + changed recent list startup
    v2.10/04.05.01  adaption to TSE32 v3.0
                    + centered dialogs and help
                    + added "goto buffer list" button
                    + added "empty" button
                    + added "clean" button
                    + added "delete" button
                    + fixed size of dialog
                    + fixed size of strings
    v2.01/17.03.97  bug fix
                    + fixed help screen
    v2.00/24.10.96  adaption to TSE32
                    + fixed quoting long filenames
    v1.20/25.03.96  maintenance
                    + added hint lines
                    + fixed version checking
    v1.10/12.01.96  maintenance
                    + added <ins> translation
                    + added <del> translation
    v1.00/11.10.95  first version

\****************************************************************************/

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"
#include "msgbox.si"
#include "dlgrcnt.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "dlgrcnt.dlg"

/****************************************************************************\
    shared code
\****************************************************************************/

#define INC_QUOTE 1

#include "scver.si"
#include "scrun.si"
#include "sctoken.si"

/****************************************************************************\
    global variables
\****************************************************************************/

integer resource                        // buffer id (dialog resource)
integer rcntlist                        // ditto (list of recent files)
integer userfile                        // ditto (current file at startup)

/****************************************************************************\
    helper
\****************************************************************************/

proc SetRecentList()
    GotoBufferId(rcntlist)
    BegFile()
    if NumLines() > 1
        Down()
    endif
    GotoBufferId(resource)
end

/****************************************************************************\
    set dialog data
\****************************************************************************/

public proc RcntDataInit()
    if CheckVersion("DlgRcnt",2,0)
        ExecMacro("DlgTerminate")
        return ()
    endif
    ExecMacro(Format("DlgSetData ",ID_LST_BUFF," ",rcntlist))
    SetRecentList()
end

/****************************************************************************\
    control response functions
\****************************************************************************/

proc IdOk()
    string name[255]

    GotoBufferId(rcntlist)
    name = GetText(1,CurrLineLen())
    if FileExists(name) and EditFile(QuotePath(name),_DONT_PROMPT_)
        userfile = GetBufferId()
        ExecMacro("DlgTerminate")
    else
        Alarm()
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_OK),
            Chr(MB_ERROR),
            Chr(CNTRL_CTEXT),"File does not exist!"
        ))
        ExecMacro(Format("DlgExecCntrl ",ID_LST_BUFF))
    endif
    GotoBufferId(resource)
end

proc IdBtnDel()
    GotoBufferId(rcntlist)
    KillLine()
    if CurrLine() > NumLines()
        Up()
    endif
    GotoBufferId(resource)
    ExecMacro(Format("DlgExecCntrl ",ID_LST_BUFF))
end

proc IdBtnEmpty()
    ExecDialog(Format(
        "MsgBox ",
        Chr(MB_YESNO),
        Chr(MB_PROMPT),
        Chr(CNTRL_CTEXT),"Remove all history entries?"
    ))
    if Val(Query(MacroCmdLine)) == ID_YES
        GotoBufferId(rcntlist)
        MarkLine(1,NumLines())
        KillBlock()
        GotoBufferId(resource)
        ExecMacro(Format("DlgExecCntrl ",ID_LST_BUFF))
    endif
end

proc IdBtnClean()
    integer id
    string name[255]

    id = GotoBufferId(rcntlist)
    if NumLines() > 0
        PushPosition()
        BegFile()
        loop
            name = GetText(1,CurrLineLen())
            if not FileExists(name)
                KillLine()
                if CurrLine() > NumLines()
                    break
                endif
            else
                if not Down()
                    break
                endif
            endif
        endloop
        PopPosition()
    endif
    GotoBufferId(id)
    ExecMacro(Format("DlgExecCntrl ",ID_LST_BUFF))

    ExecDialog(Format(
        "MsgBox ",
        Chr(MB_OK),
        Chr(MB_INFO),
        Chr(CNTRL_CTEXT),"Invalid entries have been removed"
    ))
end

/****************************************************************************\
    message response functions
\****************************************************************************/

public proc RcntEvent()
    case Query(Key)
        when <Ins>  Set(Key,<Alt O>)
        when <Del>  Set(Key,<Alt D>)
    endcase
end

public proc RcntDblClick()
    IdOk()
end

public proc RcntBtnDown()
    case CurrChar(POS_ID)
        when ID_OK          IdOk()
        when ID_BTN_DEL     IdBtnDel()
        when ID_BTN_LIST    ExecMacro("DlgTerminate")
        when ID_BTN_EMPTY   IdBtnEmpty()
        when ID_BTN_CLEAN   IdBtnClean()
        when ID_BTN_OPEN    ExecMacro("DlgTerminate")
        when ID_HELP        Help("Moving Between Files in the Ring")
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
    rcntlist = Val(Query(MacroCmdLine))
    resource = CreateTempBuffer()
    rc = rcntlist
        and resource
        and InsertData(dlgrcnt)
        and ExecDialog("dialog rcnt")
    AbandonFile(resource)
    GotoBufferId(userfile)
    PopBlock()
    UpdateDisplay(_HELPLINE_REFRESH_)

    // check for errors and user action

    if rc
        case Val(Query(MacroCmdLine))
            when ID_OK
                ExecHook(_ON_CHANGING_FILES_)
            when ID_BTN_LIST
                GotoBufferId(userfile)
                ExecDialog(Format("dlgbuff ",rcntlist))
            when ID_BTN_OPEN
                GotoBufferId(userfile)
                ExecDialog("dlgopen")
        endcase
    else
        Warn("DlgRcnt: Error executing recent files dialog")
    endif

    // purge self

    PurgeMacro(CurrMacroFilename())
end

