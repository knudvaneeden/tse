/****************************************************************************\

    DlgBuff.S

    List the files placed in the editor's internal ring of files.

    Version         v2.21/07.05.03
    Copyright       (c) 1995-2003 by DiK

    Overview:

    This dialog displays a list of all files that have been selected for
    editing (and have not been closed) during the current session. You can
    choose a file from this list and make it the current file by pressing
    <Enter>. Besides that, you can add files to the ring (Open), remove
    them from the ring (Remove) and save changed files (Save).

    Keys:       (none)

    Usage Notes:

    This macro must be called from the burned in user interface
    to enable the access of the recent files buffer.
    Call: ExecMacro("DlgBuff "+Str(GotoRecentFileBuffer()))
    DlgBuff will also function as a stand alone macro. In this case,
    however, the "recent" button will be disabled.

    History

    v2.21/07.05.03  maintenance
                    + changed recent list startup
    v2.10/30.11.00  adaption to TSE32 v3.0
                    + centered dialogs
                    + fixed size of dialog
                    + fixed size of strings
                    + fixed selecting most recent file
    v2.00/24.10.96  adaption to TSE32
                    + fixed quoting long filenames
    v1.20/25.03.96  maintenance
                    + added access to recent files
                    + added hint lines
                    + fixed version checking
    v1.10/12.01.96  maintenance
                    + added <ins> translation
                    + added <del> translation
                    + some cleanup of source code
    v1.00/11.10.95  first version

\****************************************************************************/

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"
#include "msgbox.si"
#include "dlgbuff.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "dlgbuff.dlg"

/****************************************************************************\
    shared code
\****************************************************************************/

#define INC_QUOTE 1

#include "scver.si"
#include "scrun.si"
#include "sctoken.si"

/****************************************************************************\
    additional constants
\****************************************************************************/

constant QUIT_LAST_FILE = 255

/****************************************************************************\
    global variables
\****************************************************************************/

integer resource                        // buffer id (dialog resource)
integer rcntlist                        // ditto (list of recent files)
integer bufflist                        // ditto (list of open files)
integer userfile                        // ditto (current file at startup)

/****************************************************************************\
    create buffer list
\****************************************************************************/

proc MakeBufferList()
    integer ilba
    string name[255] = "|"  // invalid file name, in case recent files list is empty

    EmptyBuffer(bufflist)
    GotoBufferId(userfile)

    do NumFiles() + (BufferType()<>_NORMAL_) times
        AddLine(Format(iif(FileChanged(),"* ","  "),CurrFilename()),bufflist)
        NextFile(_DONT_LOAD_)
    enddo

    GotoBufferId(rcntlist)
    BegFile()
    if NumLines() > 1
        Down()
        name = GetText(1,CurrLineLen())
    endif

    GotoBufferId(bufflist)
    BegFile()
    if NumLines() > 1
        if lFind(name,"gi$")
            MarkLine(CurrLine(),CurrLine())
            BegFile()
            ilba = Set(InsertLineBlocksAbove, FALSE)
            MoveBlock()
            Set(InsertLineBlocksAbove, ilba)
        endif
        Down()
    endif

    GotoBufferId(resource)
end

/****************************************************************************\
    retrieve full file name
\****************************************************************************/

string proc GetCurrName()
    string name[255]

    GotoBufferId(bufflist)
    name = GetText(3,CurrLineLen()-2)
    GotoBufferId(resource)
    return (name)
end

/****************************************************************************\
    set dialog data
\****************************************************************************/

public proc BuffDataInit()
    if CheckVersion("DlgBuff",2,0)
        ExecMacro("DlgTerminate")
        return ()
    endif
    MakeBufferList()
    ExecMacro(Format("DlgSetData ",ID_LST_BUFF," ",bufflist))
    ExecMacro(Format("DlgSetEnable ",ID_BTN_RCNT," ",rcntlist))
end

/****************************************************************************\
    button response functions
\****************************************************************************/

proc IdOk()
    userfile = EditFile(QuotePath(GetCurrName()))
    ExecMacro("DlgTerminate")
end

proc IdBtnOpen()
    GotoBufferId(userfile)
    ExecDialog("DlgOpen")
    ExecHook(_ON_CHANGING_FILES_)   // update recent files list
    MakeBufferList()
    ExecMacro(Format("DlgExecCntrl ",ID_LST_BUFF))
end

proc IdBtnSave()
    GotoBufferId(GetBufferId(GetCurrName()))
    if FileChanged()
        SaveFile()
        GotoBufferId(bufflist)
        BegLine()
        InsertText(" ",_OVERWRITE_)
    endif
    GotoBufferId(resource)
    ExecMacro(Format("DlgExecCntrl ",ID_LST_BUFF))
end

proc IdBtnClose()
    integer rc = TRUE

    // check for last file

    GotoBufferId(bufflist)
    if NumLines() == 1
        Alarm()
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_OKCANCEL),
            Chr(MB_WARN),
            Chr(CNTRL_CTEXT),"This will exit the editor!"
        ))
        rc = Val(Query(MacroCmdLine)) == ID_OK
        if rc
            ExecMacro(Format("DlgTerminate ",QUIT_LAST_FILE))
        endif
    endif

    // check for changed files

    if rc and GotoBufferId(GetBufferId(GetCurrName())) and FileChanged()
        Alarm()
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_YESNOCANCEL),
            Chr(MB_PROMPT),
            Chr(CNTRL_CTEXT),"File has been changed! Save now?"
        ))
        case Val(Query(MacroCmdLine))
            when ID_YES
                SaveFile()
            when ID_CANCEL
                rc = FALSE
        endcase
    endif

    // quit the file

    if rc
        AbandonFile()
        GotoBufferId(bufflist)
        KillLine()
        if CurrLine() > NumLines()
            Up()
        endif
    endif

    // clean up

    GotoBufferId(resource)
    ExecMacro(Format("DlgExecCntrl ",ID_LST_BUFF))
end

/****************************************************************************\
    message response functions
\****************************************************************************/

public proc BuffEvent()
    case Query(Key)
        when <Ins>  Set(Key,<Alt O>)
        when <Del>  Set(Key,<Alt R>)
    endcase
end

public proc BuffDblClick()
    IdOk()
end

public proc BuffBtnDown()
    case CurrChar(POS_ID)
        when ID_OK          IdOk()
        when ID_BTN_RCNT    ExecMacro("DlgTerminate")
        when ID_BTN_OPEN    IdBtnOpen()
        when ID_BTN_SAVE    IdBtnSave()
        when ID_BTN_CLOSE   IdBtnClose()
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
    bufflist = CreateTempBuffer()
    resource = CreateTempBuffer()
    rc = bufflist
        and resource
        and InsertData(dlgbuff)
        and ExecDialog("dialog buff")
    AbandonFile(resource)
    AbandonFile(bufflist)
    GotoBufferId(userfile)
    PopBlock()
    UpdateDisplay(_HELPLINE_REFRESH_)

    // check for errors

    if rc
        case Val(Query(MacroCmdLine))
            when ID_OK
                ExecHook(_ON_CHANGING_FILES_)
            when ID_BTN_RCNT
                GotoBufferId(userfile)
                ExecDialog(Format("DlgRcnt ", rcntlist))
            when QUIT_LAST_FILE
                UpdateDisplay()
                AbandonEditor()
        endcase
    else
        Warn("DlgBuff: Error executing buffer list dialog")
    endif

    // purge self

    PurgeMacro(CurrMacroFilename())
end

