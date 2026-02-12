/****************************************************************************\

    DlgRplc.S

    Search for a specified string and replace it with another.

    Version         v2.10/30.11.00
    Copyright       (c) 1995-2000 by DiK

    Overview:

    This macro searches for a specified string and and replaces it with
    another string. It allows you to enter all the search and replace
    options in one screen.

    Keys:       (none)

    Command Line Format:

    DlgRplc  [-x]

    where:

        -x      do nothing, but return result

    History

    v2.10/30.11.00  adaption to TSE32 v3.0
                    þ added get marked text as default
    v2.00/24.10.96  adaption to TSE32
                    þ version number only
    v1.20/25.03.96  maintenance
                    þ enhanced ascii chart handling
                    þ some clean up of source code
    v1.10/12.01.96  maintenance
                    þ added ascii chart
    v1.00/11.10.95  first version

\****************************************************************************/

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"
#include "msgbox.si"
#include "dlgrplc.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "dlgrplc.dlg"

/****************************************************************************\
    shared code
\****************************************************************************/

#include "scver.si"
#include "scrun.si"

/****************************************************************************\
    global variables
\****************************************************************************/

integer tempbuff                        // work buffer
integer resource                        // dialog resource buffer

integer cntrl = ID_EDT_FIND             // id of active edit field
integer ascii                           // flag (ascii chart called)
integer index                           // saved index of edit field
integer mark_beg                        // saved mark of find field
integer mark_end                        // ditto

string opts[16]                         // replace options
string text[254]                        // text to find
string rplc[254]                        // replacement

/****************************************************************************\
    set dialog data
\****************************************************************************/

proc SetCheck( string opt, integer cid )
    integer rc

    rc = lFind(opt,"cgi")
    ExecMacro(Format("DlgSetData ",cid," ",rc))
end

proc SetOptions()
    integer bid

    bid = GotoBufferId(tempbuff)
    AddLine(GetHistoryStr(_REPLACEOPTIONS_HISTORY_,1))

    SetCheck("a",ID_CHK_ALL)
    SetCheck("g",ID_CHK_GLOBAL)
    SetCheck("l",ID_CHK_LOCAL)
    SetCheck("c",ID_CHK_CURR)
    SetCheck("^",ID_CHK_BOL)
    SetCheck("$",ID_CHK_EOL)
    SetCheck("b",ID_CHK_BACK)
    SetCheck("n",ID_CHK_PRMT)
    SetCheck("i",ID_CHK_CASE)
    SetCheck("w",ID_CHK_WORDS)
    SetCheck("x",ID_CHK_EXPR)

    EmptyBuffer()
    GotoBufferId(bid)
end

public proc RplcDataInit()

    // check dialog version

    if CheckVersion("DlgRplc",2,0)
        ExecMacro("DlgTerminate")
        return ()
    endif

    // init data

    if not Length(text)
        text = GetHistoryStr(_FIND_HISTORY_,1)
    endif
    rplc = GetHistoryStr(_REPLACE_HISTORY_,1)
    ExecMacro(Format("DlgSetTitle ",ID_EDT_FIND," ",text))
    ExecMacro(Format("DlgSetTitle ",ID_EDT_RPLC," ",rplc))
    ExecMacro(Format("DlgSetData ",ID_EDT_FIND," ",_FIND_HISTORY_))
    ExecMacro(Format("DlgSetData ",ID_EDT_RPLC," ",_REPLACE_HISTORY_))
    SetOptions()
end

/****************************************************************************\
    get dialog data
\****************************************************************************/

proc GetCheck( string opt, integer cid )
    ExecMacro(Format("DlgGetData ",cid))
    if Val(Query(MacroCmdLine))
        opts = opts + opt
    endif
end

public proc RplcDataDone()
    opts = ""

    GetCheck("a",ID_CHK_ALL)
    GetCheck("g",ID_CHK_GLOBAL)
    GetCheck("l",ID_CHK_LOCAL)
    GetCheck("c",ID_CHK_CURR)
    GetCheck("^",ID_CHK_BOL)
    GetCheck("$",ID_CHK_EOL)
    GetCheck("b",ID_CHK_BACK)
    GetCheck("n",ID_CHK_PRMT)
    GetCheck("i",ID_CHK_CASE)
    GetCheck("w",ID_CHK_WORDS)
    GetCheck("x",ID_CHK_EXPR)

    ExecMacro(Format("DlgGetTitle ",ID_EDT_FIND))
    text = Query(MacroCmdLine)
    ExecMacro(Format("DlgGetTitle ",ID_EDT_RPLC))
    rplc = Query(MacroCmdLine)
end

/****************************************************************************\
    options display
\****************************************************************************/

proc IdBtnOpts()
    opts = GetHistoryStr(_REPLACEOPTIONS_HISTORY_,1)
    ExecDialog(Format(
        "InpBox ",
        _REPLACEOPTIONS_HISTORY_,Chr(13),
        "Replace Options",Chr(13),
        "Options [BGLIWNX]",Chr(13),
        GetHistoryStr(_REPLACEOPTIONS_HISTORY_,1),Chr(13),
        "RplcHelp"
    ))
    opts = Query(MacroCmdLine)
    if Asc(opts[1]) == ID_OK
        opts = opts[2..Length(opts)]
        AddHistoryStr(opts,_REPLACEOPTIONS_HISTORY_)
        SetOptions()
    endif
end

/****************************************************************************\
    ascii chart
\****************************************************************************/

proc IdBtnAscii()
    string char[128]
    string text[128]

    if not ExecDialog("DlgAscii -x")
        return ()
    endif

    char = Query(MacroCmdLine)
    ascii = Length(char)

    if ascii
        ExecMacro(Format("DlgGetTitle ",cntrl))
        text = Query(MacroCmdLine)

        if mark_beg
            index = mark_beg
            text = DelStr(text,mark_beg,mark_end-mark_beg)
        endif
        text = InsStr(char,text,index)
        mark_beg = index
        mark_end = index + Length(char)
        index = mark_end

        ExecMacro(Format("DlgSetTitle ",cntrl," ",text))
    endif

    ExecMacro(Format("DlgExecCntrl ",cntrl))
end

/****************************************************************************\
    message response functions
\****************************************************************************/

public proc RplcSetFocus()
    integer en = CurrChar(POS_ID) in ID_EDT_FIND,ID_EDT_RPLC

    if en
        if ascii
            ascii = FALSE
        else
            index = 0
            mark_beg = 0
        endif
        cntrl = CurrChar(POS_ID)
    endif
    ExecMacro(Format("DlgSetEnable ",ID_BTN_ASCII,en:2))
end

public proc RplcEditSetIndex()
    Set(MacroCmdLine,Str(index))
end

public proc RplcEditSetMark()
    Set(MacroCmdLine,Format(mark_beg," ",mark_end))
end

public proc RplcEditKill()
    string info[64] = Query(MacroCmdLine)

    index = Val(GetToken(info," ",1))
    mark_beg = Val(GetToken(info," ",2))
    mark_end = Val(GetToken(info," ",3))
end

public proc RplcHelp()
    Help("prompt->Replace with:")
end

public proc RplcBtnDown()
    case CurrChar(POS_ID)
        when ID_OK          ExecMacro("DlgTerminate")
        when ID_BTN_OPTS    IdBtnOpts()
        when ID_BTN_ASCII   IdBtnAscii()
        when ID_BTN_XHELP   Help("Summary List of Regular Expression Operators")
        when ID_HELP        RplcHelp()
        otherwise           return()
    endcase
    Set(MacroCmdLine,"0")
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer rc
    string cmd[8] = Query(MacroCmdLine)

    // check command line

    if Length(cmd) and cmd <> "-x"
        Warn("DlgRplc: Invalid command line. Using defaults.")
    endif

    // get marked text or current word as default

    if isBlockInCurrFile()
        text = GetMarkedText()
    else
        text = GetWord()
    endif

    // allocate work space and exec dialog

    PushBlock()
    tempbuff = CreateTempBuffer()
    resource = CreateTempBuffer()
    rc = tempbuff
        and resource
        and InsertData(dlgrplc)
        and ExecDialog("dialog rplc")
    AbandonFile(resource)
    AbandonFile(tempbuff)
    PopBlock()
    UpdateDisplay(_HELPLINE_REFRESH_)

    // check return code and search text

    if rc
        if Val(Query(MacroCmdLine)) == ID_OK
            AddHistoryStr(text,_FIND_HISTORY_)
            AddHistoryStr(rplc,_REPLACE_HISTORY_)
            AddHistoryStr(opts,_REPLACEOPTIONS_HISTORY_)
            if not Length(cmd)
                if not Replace(text,rplc,opts)
                    ExecDialog(Format(
                        "MsgBox ",
                        Chr(MB_OK),
                        Chr(MB_ERROR),
                        Chr(CNTRL_CTEXT),'"',text[1:20],'" not found'
                    ))
                endif
            endif
        endif
    else
        Warn("DlgRplc: Error executing replace dialog")
    endif

    // purge self

    PurgeMacro(CurrMacroFilename())
end

