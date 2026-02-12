/****************************************************************************\

    DlgFind.S

    Search for a specified string.

    Version         v2.10/30.11.00
    Copyright       (c) 1995-2000 by DiK

    Overview:

    This macro searches for a specified string and allows you to enter
    all the search options in one screen.

    Keys:       (none)

    Command Line Format:

    DlgFind [-v] [-x]

    where:

        none    Find
        -v      CompressView
        -x      do nothing, but return result

    History

    v2.10/30.11.00  adaption to TSE32 v3.0
                    þ added get marked text as default
    v2.01/17.03.97  bug fix
                    þ fixed help screen
    v2.00/24.10.96  adaption to TSE32
                    þ version number only
    v1.20/25.03.96  maintenance
                    þ added compress view history (-v)
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
#include "dlgfind.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "dlgfind.dlg"

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

integer view                            // flag (compress view)
integer ascii                           // ditto (ascii chart called)
integer index                           // saved index of find field
integer mark_beg                        // saved mark of find field
integer mark_end                        // ditto

integer find_hist                       // history number (find string)
integer opts_hist                       // ditto (find options)

string opts[16]                         // find options
string text[80]                         // text to find

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
    AddLine(GetHistoryStr(opts_hist,1))

    SetCheck("a",ID_CHK_ALL)
    SetCheck("g",ID_CHK_GLOBAL)
    SetCheck("l",ID_CHK_LOCAL)
    SetCheck("c",ID_CHK_CURR)
    SetCheck("^",ID_CHK_BOL)
    SetCheck("$",ID_CHK_EOL)
    SetCheck("b",ID_CHK_BACK)
    SetCheck("v",ID_CHK_VIEW)
    SetCheck("i",ID_CHK_CASE)
    SetCheck("w",ID_CHK_WORDS)
    SetCheck("x",ID_CHK_EXPR)

    EmptyBuffer()
    GotoBufferId(bid)
end

public proc FindDataInit()

    // check dialog version

    if CheckVersion("DlgFind",2,0)
        ExecMacro("DlgTerminate")
        return ()
    endif

    // init data

    if not Length(text)
        text = GetHistoryStr(find_hist,1)
    endif
    ExecMacro(Format("DlgSetTitle ",ID_EDT_FIND," ",text))
    ExecMacro(Format("DlgSetData ",ID_EDT_FIND," ",find_hist))
    SetOptions()
    if view
        ExecMacro(Format("DlgSetTitle 0 Compress View"))
        ExecMacro(Format("DlgSetData ",ID_CHK_GLOBAL," 0"))
        ExecMacro(Format("DlgSetData ",ID_CHK_CURR," 0"))
        ExecMacro(Format("DlgSetData ",ID_CHK_VIEW," 1"))
        ExecMacro(Format("DlgSetEnable ",ID_CHK_GLOBAL," 0"))
        ExecMacro(Format("DlgSetEnable ",ID_CHK_CURR," 0"))
        ExecMacro(Format("DlgSetEnable ",ID_CHK_VIEW," 0"))
    endif
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

public proc FindDataDone()
    opts = ""

    GetCheck("a",ID_CHK_ALL)
    GetCheck("g",ID_CHK_GLOBAL)
    GetCheck("l",ID_CHK_LOCAL)
    GetCheck("c",ID_CHK_CURR)
    GetCheck("^",ID_CHK_BOL)
    GetCheck("$",ID_CHK_EOL)
    GetCheck("b",ID_CHK_BACK)
    GetCheck("i",ID_CHK_CASE)
    GetCheck("w",ID_CHK_WORDS)
    GetCheck("x",ID_CHK_EXPR)
    if view
        opts = opts + "v"
    else
        GetCheck("v",ID_CHK_VIEW)
    endif

    ExecMacro(Format("DlgGetTitle ",ID_EDT_FIND))
    text = Query(MacroCmdLine)
end

/****************************************************************************\
    options display
\****************************************************************************/

proc IdBtnOpts()
    opts = GetHistoryStr(opts_hist,1)
    ExecDialog(Format(
        "InpBox ",
        opts_hist,Chr(13),
        "Find Options",Chr(13),
        "Options [BGLIWX]",Chr(13),
        opts,Chr(13),
        "FindHelp"
    ))
    opts = Query(MacroCmdLine)
    if Asc(opts[1]) == ID_OK
        opts = opts[2..Length(opts)]
        AddHistoryStr(opts,opts_hist)
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
        ExecMacro(Format("DlgGetTitle ",ID_EDT_FIND))
        text = Query(MacroCmdLine)

        if mark_beg
            index = mark_beg
            text = DelStr(text,mark_beg,mark_end-mark_beg)
        endif
        text = InsStr(char,text,index)
        mark_beg = index
        mark_end = index + Length(char)
        index = mark_end

        ExecMacro(Format("DlgSetTitle ",ID_EDT_FIND," ",text))
    endif

    ExecMacro(Format("DlgExecCntrl ",ID_EDT_FIND))
end

/****************************************************************************\
    message response functions
\****************************************************************************/

public proc FindSetFocus()
    integer en = CurrChar(POS_ID) == ID_EDT_FIND

    if en
        if ascii
            ascii = FALSE
        else
            index = 0
            mark_beg = 0
        endif
    endif
    ExecMacro(Format("DlgSetEnable ",ID_BTN_ASCII,en:2))
end

public proc FindEditSetIndex()
    Set(MacroCmdLine,Str(index))
end

public proc FindEditSetMark()
    Set(MacroCmdLine,Format(mark_beg," ",mark_end))
end

public proc FindEditKill()
    string info[64] = Query(MacroCmdLine)

    index = Val(GetToken(info," ",1))
    mark_beg = Val(GetToken(info," ",2))
    mark_end = Val(GetToken(info," ",3))
end

public proc FindHelp()
    if view
#IFDEF WIN32
        Help("Listing All Occurrences of a Specified Text String")
#ELSE
        Help("Compress View")
#ENDIF
    else
        Help("prompt->Search for:")
    endif
end

public proc FindBtnDown()
    case CurrChar(POS_ID)
        when ID_OK          ExecMacro("DlgTerminate")
        when ID_BTN_OPTS    IdBtnOpts()
        when ID_BTN_ASCII   IdBtnAscii()
        when ID_BTN_XHELP   Help("Summary List of Regular Expression Operators")
        when ID_HELP        FindHelp()
    endcase
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer i, rc
    integer run = TRUE
    string cmd[16] = Query(MacroCmdLine)

    // check command line

    for i = 1 to NumTokens(cmd," ")
        case GetToken(cmd," ",i)
            when "-x"   run = FALSE
            when "-v"   view = TRUE
            otherwise   Warn("DlgFind: Invalid command line. Using defaults.")
        endcase
    endfor

    // determine history lists

    if view
        find_hist = GetFreeHistory("UI:CompressViewFind")
        opts_hist = GetFreeHistory("UI:CompressViewFindOptions")
    else
        find_hist = _FIND_HISTORY_
        opts_hist = _FINDOPTIONS_HISTORY_
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
        and InsertData(dlgfind)
        and ExecDialog("dialog find")
    AbandonFile(resource)
    AbandonFile(tempbuff)
    PopBlock()
    UpdateDisplay(_HELPLINE_REFRESH_)

    // check return code and search text

    if rc
        if Val(Query(MacroCmdLine)) == ID_OK
            AddHistoryStr(text,find_hist)
            AddHistoryStr(opts,opts_hist)
            if run
                if not Find(text,opts)
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
        Warn("DlgFind: Error executing find dialog")
    endif

    // purge self

    PurgeMacro(CurrMacroFilename())
end

