/****************************************************************************\

    DlgComp.S

    Compare text files.

    Version         v2.20/25.02.02
    Copyright       (c) 1996-2002 by DiK

    Overview:

    This macro compares two files using DlgCompX a.k.a. TseComp.

    Keys:       (none)

    Command Line Format:

    DlgComp  [first_file [second_file]]

    History
    v2.20/25.02.02  adaption to TSE32 v4.0
                    þ fixed version checking
    v2.10/28.03.01  adaption to TSE32 v3.0
                    þ centered dialogs and help
                    þ use DlgMsgText variable
                    þ fixed name of unnamed file
    v2.00/24.10.96  first version

\****************************************************************************/

/****************************************************************************\
    use global variable DlgMsgText
\****************************************************************************/

#define INC_MSGTEXT 1

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"
#include "msgbox.si"
#include "dlgcomp.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "dlgcomp.dlg"

/****************************************************************************\
    shared code
\****************************************************************************/

#define INC_QUOTE    1
#define INC_UNQUOTE  1
#define INC_NUMTOKEN 1
#define INC_GETTOKEN 1

#include "scver.si"
#include "scrun.si"
#include "sctoken.si"
#include "schelp.si"

/****************************************************************************\
    global variables
\****************************************************************************/

integer resource                        // dialog resource buffer

integer cmp_hist1                       // history number
integer cmp_hist2                       // ditto
integer cntrl = ID_EDT_FILE1            // id of active edit field

string  name1[255]                      // filename
string  name2[255]                      // ditto

#if EDITOR_VERSION >= 0x3000
string unnamed[] = "<unnamed-1>"
#else
string unnamed[] = "[unnamed-1]"
#endif

/****************************************************************************\
    help screen
\****************************************************************************/

constant HLP_WIDTH = 70

helpdef DlgCompHelp
    title = "Help on Comparing Text Files"
    width = HLP_WIDTH
    height = 11
    y = 5

    ""
    "   This dialog is used to enter the names of the files which"
    "   should be compared. Additional help is available, especially"
    "   on key assignments, while comparing the files."
    ""
    "   Summary of commands:"
    ""
    "   Compare     start comparing files"
    "   Cancel      abort file comparison"
    "   Search      search file using Open File dialog"
    ""
end

/****************************************************************************\
    helper routines
\****************************************************************************/

proc MissingFile( string the_name )
    string name[44]

    name = SplitPath(the_name,_NAME_|_EXT_)
    if Length(name) > 42
        name = name[1..39] + "..."
    endif

    ExecDialog(Format(
        "MsgBox ",
        Chr(MB_OK),
        Chr(MB_ERROR),
        Chr(CNTRL_CTEXT),"File not found",Chr(13),Chr(13),
        Chr(CNTRL_CTEXT),name,Chr(13)," "
    ))
end

/****************************************************************************\
    set dialog data
\****************************************************************************/

public proc CompDataInit()

    // check dialog version

    if CheckVersion("DlgComp",2,3)
        ExecMacro("DlgTerminate")
        return ()
    endif

    // init data

    SetGlobalStr(DlgMsgText,name1)
    ExecMacro(Format("DlgSetTitleEx ",ID_EDT_FILE1))
    SetGlobalStr(DlgMsgText,name2)
    ExecMacro(Format("DlgSetTitleEx ",ID_EDT_FILE2))
    ExecMacro(Format("DlgSetData ",ID_EDT_FILE1," ",cmp_hist1))
    ExecMacro(Format("DlgSetData ",ID_EDT_FILE2," ",cmp_hist2))
end

/****************************************************************************\
    message response functions
\****************************************************************************/

proc IdSearch()
    string current[255]

    ExecDialog("DlgOpen -x -t")

    if Val(Query(MacroCmdLine)) == ID_OK
        current = UnQuotePath(GetHistoryStr(_EDIT_HISTORY_,1))
        DelHistoryStr(_EDIT_HISTORY_,1)
        ExecMacro(Format("DlgSetTitle ",cntrl," ",current))
    endif
    ExecMacro(Format("DlgExecCntrl ",cntrl))
end

proc IdOk()
    ExecMacro(Format("DlgGetTitle ",ID_EDT_FILE1))
    name1 = GetGlobalStr(DlgMsgText)
    ExecMacro(Format("DlgGetTitle ",ID_EDT_FILE2))
    name2 = GetGlobalStr(DlgMsgText)

    if not FileExists(name1)
        MissingFile(name1)
        ExecMacro(Format("DlgExecCntrl ",ID_EDT_FILE1))
        return ()
    endif
    if not FileExists(name2)
        MissingFile(name2)
        ExecMacro(Format("DlgExecCntrl ",ID_EDT_FILE2))
        return ()
    endif

    ExecMacro("DlgTerminate")
end

/****************************************************************************\
    message response functions
\****************************************************************************/

public proc CompSetFocus()
    integer en = CurrChar(POS_ID) in ID_EDT_FILE1,ID_EDT_FILE2

    if en
        cntrl = CurrChar(POS_ID)
    endif
    ExecMacro(Format("DlgSetEnable ",ID_BTN_SEARCH,en:2))
end

public proc CompBtnDown()
    case CurrChar(POS_ID)
        when ID_OK          IdOk()
        when ID_BTN_SEARCH  IdSearch()
        when ID_HELP        InitHelp(HLP_WIDTH) QuickHelp(DlgCompHelp)
    endcase
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer i, rc
    integer batch, dialog
    string token[255]
    string cmdline[255] = Query(MacroCmdLine)

    // check command line

    if Length(cmdline) == 0

        batch = GetEnvStr("TSECOMPBATCHED") == "1"
        if batch
            name1 = GetEnvStr("TSECOMPCMDARG1")
            name2 = GetEnvStr("TSECOMPCMDARG2")
        endif

    else

        for i=1 to NumQuotedTokens(cmdline)
            token = GetQuotedToken(cmdline,i)
            if Length(name1) == 0
                name1 = token
            else
                name2 = token
            endif
        endfor

    endif

    dialog = not (batch and Length(name1) and Length(name2))

    // determine initial filenames

    cmp_hist1 = GetFreeHistory("DlgComp:FileName1")
    cmp_hist2 = GetFreeHistory("DlgComp:FileName2")

    if dialog
        if Length(name1) == 0
            if CurrFileName() == unnamed
                name1 = GetHistoryStr(cmp_hist1,1)
            else
                name1 = CurrFilename()
            endif
        endif
        if Length(name2) == 0
            name2 = GetHistoryStr(cmp_hist2,1)
        endif
    endif

    // allocate work space and exec dialog

    if dialog
        PushBlock()
        resource = CreateTempBuffer()
        rc = resource
            and InsertData(dlgcomp)
            and ExecDialog("dialog comp")
        AbandonFile(resource)
        PopBlock()
        UpdateDisplay(_HELPLINE_REFRESH_)
    else
        rc = TRUE
        Set(MacroCmdLine,Str(ID_OK))
    endif

    // check return code and search text

    if rc
        if Val(Query(MacroCmdLine)) == ID_OK
            AddHistoryStr(name1,cmp_hist1)
            AddHistoryStr(name2,cmp_hist2)
            ExecDialog(Format(
                'DlgCompX ',QuotePath(name1),' ',QuotePath(name2)))
        endif
    else
        Warn("DlgComp: Error executing compare dialog.")
    endif

    // purge self

    if batch and NumFiles() == 1 and CurrFileName() == unnamed
        AbandonEditor()
    else
        UpdateDisplay()
        PurgeMacro(CurrMacroFilename())
    endif
end

