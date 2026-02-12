/****************************************************************************\

    DlgFndDo.S

    Search for specified string and execute some action.

    Version         v2.20/25.02.02
    Copyright       (c) 1995-2002 by DiK

    Overview:

    This macro searches for a specified string and applies one of
    several options to the found string.

    Keys:       (none)

    History

    v2.20/25.02.02  adaption to TSE32 v4.0
                    þ fixed version checking
    v2.10/07.06.01  adaption to TSE32 v3.0
                    þ added prompting
                    þ added new find&do stuff
                    þ added get marked text as default
                    þ added optional use of Windows clipboard
                    þ fixed local searching
                    þ fixed hot keys
    v2.02/20.01.98  bug fix
                    þ fixed inversion of lines when copying and appending
    v2.01/17.03.97  bug fix
                    þ fixed help screen
    v2.00/24.10.96  adaption to TSE32
                    þ version number only
    v1.23/04.07.96  bug fix
                    þ fixed local searching
                    þ fixed infinite loop when searching all files
    v1.20/25.03.96  first version

    Remarks:

    Original FindAndDo routine taken from SemWare find&do macro.
    The macro depends on the order of the ID_RAD_xxxx constants.

\****************************************************************************/

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"
#include "msgbox.si"
#include "dlgfnddo.si"

/****************************************************************************\
    use the windows clipboard
\****************************************************************************/

#include "scwinclp.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "dlgfnddo.dlg"

/****************************************************************************\
    shared code
\****************************************************************************/

#include "scver.si"
#include "scrun.si"

/****************************************************************************\
    global variables
\****************************************************************************/

integer resource                        // dialog resource buffer
integer linebuff                        // working buffer

integer action = ID_RAD_COUNT           // action to apply to found strings
integer dontask                         // do not prompt for each apply
integer addnum                          // add line numbers to saved lines
integer count                           // number of occurences of string
integer ascii                           // flag (ascii chart called)
integer index                           // saved index of find field
integer mark_beg                        // saved mark of find field
integer mark_end                        // ditto

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

    bid = GotoBufferId(linebuff)
    AddLine(GetHistoryStr(_FINDOPTIONS_HISTORY_,1))

    SetCheck("a",ID_CHK_ALL)
    SetCheck("g",ID_CHK_GLOBAL)
    SetCheck("l",ID_CHK_LOCAL)
    SetCheck("n",ID_CHK_PRMPT)
    SetCheck("i",ID_CHK_CASE)
    SetCheck("w",ID_CHK_WORDS)
    SetCheck("x",ID_CHK_EXPR)

    EmptyBuffer()
    GotoBufferId(bid)
end

public proc FindDoDataInit()

    // check dialog version

    if CheckVersion("DlgFndDo",2,0)
        ExecMacro("DlgTerminate")
        return ()
    endif

    // init data

    if not Length(text)
        text = GetHistoryStr(_FIND_HISTORY_,1)
    endif
    ExecMacro(Format("DlgSetTitle ",ID_EDT_FIND," ",text))
    ExecMacro(Format("DlgSetData ",ID_EDT_FIND," ",_FIND_HISTORY_))
    ExecMacro(Format("DlgSetData ",ID_RAD_COUNT," 1"))
    ExecMacro(Format("DlgSetEnable ",ID_CHK_NUM," 0"))
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

public proc FindDoDataDone()
    opts = ""

    GetCheck("a",ID_CHK_ALL)
    GetCheck("g",ID_CHK_GLOBAL)
    GetCheck("l",ID_CHK_LOCAL)
    GetCheck("n",ID_CHK_PRMPT)
    GetCheck("i",ID_CHK_CASE)
    GetCheck("w",ID_CHK_WORDS)
    GetCheck("x",ID_CHK_EXPR)

    ExecMacro(Format("DlgGetTitle ",ID_EDT_FIND))
    text = Query(MacroCmdLine)

    ExecMacro(Format("DlgGetData ",ID_CHK_NUM))
    addnum = addnum and Val(Query(MacroCmdLine))
end

/****************************************************************************\
    options display
\****************************************************************************/

proc IdBtnOpts()
    opts = GetHistoryStr(_FINDOPTIONS_HISTORY_,1)
    ExecDialog(Format(
        "InpBox ",
        _FINDOPTIONS_HISTORY_,Chr(13),
        "Find Options",Chr(13),
        "Options [BGLIWX]",Chr(13),
        GetHistoryStr(_FINDOPTIONS_HISTORY_,1),Chr(13),
        "FindDoHelp"
    ))
    opts = Query(MacroCmdLine)
    if Asc(opts[1]) == ID_OK
        opts = opts[2..Length(opts)]
        AddHistoryStr(opts,_FINDOPTIONS_HISTORY_)
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

public proc FindDoSetFocus()
    integer en
    integer focus = CurrChar(POS_ID)

    if focus in ID_RAD_COUNT..ID_RAD_COPY
        action = focus
        addnum = action in ID_RAD_CUT,ID_RAD_COPY
    endif

    en = focus == ID_EDT_FIND
    if en
        if ascii
            ascii = FALSE
        else
            index = 0
            mark_beg = 0
        endif
    endif

    ExecMacro(Format("DlgSetEnable ",ID_CHK_NUM,addnum:2))
    ExecMacro(Format("DlgSetEnable ",ID_BTN_ASCII,en:2))
end

public proc FindDoEditSetIndex()
    Set(MacroCmdLine,Str(index))
end

public proc FindDoEditSetMark()
    Set(MacroCmdLine,Format(mark_beg," ",mark_end))
end

public proc FindDoEditKill()
    string info[64] = Query(MacroCmdLine)

    index = Val(GetToken(info," ",1))
    mark_beg = Val(GetToken(info," ",2))
    mark_end = Val(GetToken(info," ",3))
end

public proc FindDoHelp()
    Help("prompt->Search for:")
end

public proc FindDoBtnDown()
    case CurrChar(POS_ID)
        when ID_OK          ExecMacro("DlgTerminate")
        when ID_BTN_OPTS    IdBtnOpts()
        when ID_BTN_ASCII   IdBtnAscii()
        when ID_BTN_XHELP   Help("Summary List of Regular Expression Operators")
#ifdef WIN32
        when ID_HELP        Help("Other Special-Purpose Search Features")
#else
        when ID_HELP        Help("Find And Do")
#endif
    endcase
end

/****************************************************************************\
    work horse (find&do)

    notes:    Taken from find&do.s by SemWare, enhancements by DiK.
\****************************************************************************/

proc ApplyDo()
    integer addin = 0
    integer num = NumLines()
    integer line = CurrLine()

    case action
        when ID_RAD_DELETE
            DelLine()
        when ID_RAD_CUT
            addin = count
            Cut(_APPEND_)
        when ID_RAD_COPY
            Copy(_APPEND_)
    endcase

    if addnum
        AddLine(Format(line+addin:6,":"),linebuff)
    endif

    if NumLines() < num
        BegLine()
        PrevChar()
    endif
end

/****************************************************************************/

integer proc PromptDo()
    string name[255] = SplitPath(CurrFilename(), _NAME_|_EXT_)
    integer key

    Message("L ", CurrLine(), " ", name, "   Apply (Yes/No/Only/Rest/Quit)")
    repeat
        key = GetKey()
    until key in <Y>, <y>, <N>, <n>, <O>, <o>, <R>, <r>, <Q>, <q>, <Escape>
    return (key)
end

/****************************************************************************/

proc FindAndDo()
    integer check_id, first_id, this_id
    integer hook_state, osnd, clnb, mkng

    // initialize

    count = 0

    PushPosition()
    osnd = Set(Beep,OFF)
    mkng = Set(Marking,OFF)
    clnb = Set(UseCurrLineIfNoBlock,ON)
    hook_state = SetHookState(OFF)

    // search and do

    dontask = Pos("n", opts)

    if action in ID_RAD_CUT, ID_RAD_COPY
         EmptyBuffer(Query(ClipboardId))
    endif

    if lFind(text,opts)

        check_id = FALSE
        first_id = GetBufferId()

        repeat

            this_id = GetBufferId()
            if check_id and first_id == this_id
                break
            endif
            if first_id <> this_id
                check_id = TRUE
            endif

            if dontask
                ApplyDo()
            else
                UpdateDisplay()
                HiLiteFoundText()
                case PromptDo()
                    when <Y>, <y>
                        ApplyDo()
                    when <N>, <n>
                        // just skip this one, go on to next
                    when <O>, <o>
                        ApplyDo()
                        break
                    when <R>, <r>
                        ApplyDo()
                        dontask = TRUE
                    when <Q>, <q>, <Escape>
                        break
                endcase
            endif

            count = count + 1

        until not lRepeatFind()

    endif

    // save block

    PushBlock()
    UnMarkBlock()

    // copy line numbers

    if addnum
        GotoBufferId(linebuff)
        MarkColumn(1,1,NumLines(),8)
        GotoBufferId(Query(ClipboardId))
        BegFile()
        CopyBlock()
        GotoBufferId(linebuff)
    endif

    // optionally copy clipboard to winclip

#ifdef USE_WIN_CLIP
    if action in ID_RAD_CUT, ID_RAD_COPY
        GotoBufferId(Query(ClipboardId))
        MarkLine(1,NumLines())
        CopyToWinClip()
        GotoBufferId(linebuff)
    endif
#endif

    // restore block

    PopBlock()

    // finalize

    PopPosition()
    SetHookState(hook_state)
    Set(Beep,osnd)
    Set(Marking,mkng)
    Set(UseCurrLineIfNoBlock,clnb)

    UpdateDisplay()
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer rc, userfile

    // get marked text or current word as default

    if isBlockInCurrFile()
        text = GetMarkedText()
    else
        text = GetWord()
    endif

    // allocate work space and exec dialog

    PushBlock()
    userfile = GetBufferId()
    linebuff = CreateTempBuffer()
    resource = CreateTempBuffer()
    rc = linebuff
        and resource
        and InsertData(dlgfnddo)
        and ExecDialog("dialog finddo")
    GotoBufferId(userfile)
    UpdateDisplay()
    PopBlock()

    // check return code and search text

    if rc
        if Val(Query(MacroCmdLine)) == ID_OK
            AddHistoryStr(text,_FIND_HISTORY_)
            AddHistoryStr(opts,_FINDOPTIONS_HISTORY_)
            FindAndDo()
            ExecDialog(Format(
                "MsgBox ",
                Chr(MB_OK),
                Chr(MB_INFO),
                Chr(CNTRL_CTEXT),count," occurrence(s) found"
            ))
        endif
    else
        Warn("DlgFndDo: Error executing find dialog")
    endif

    // purge self

    AbandonFile(resource)
    AbandonFile(linebuff)
    GotoBufferId(userfile)
    UpdateDisplay(_HELPLINE_REFRESH_)
    PurgeMacro(CurrMacroFilename())
end
