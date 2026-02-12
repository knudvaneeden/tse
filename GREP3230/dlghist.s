/****************************************************************************\

    DlgHist.S

    Maintenance for TSE history lists.

    Version         v2.20/09.04.02
    Copyright       (c) 1995-2002 by DiK

    Overview:

    This macro allows you to view and maintain the history lists of TSE.
    See on-line help for instructions.

    Keys:       (none)

    History

    v2.20/09.04.02  adaption to TSE32 v4.0
                    + fixed version checking
    v2.10/30.03.01  adaption to TSE32 v3.0
                    + use new SaveHistory function (v3.0 only)
                    + centered dialogs and help
    v2.00/24.10.96  adaption to TSE32
                    + version number only
    v1.20/25.03.96  maintenance
                    + added user history dialog
                        (low level hist file compression)
                    + added double click handling in main list
                    + fixed version checking
                    + some cleanup of source code
    v1.10/12.01.96  maintenance
                    + added <del> translation
                    + fixed splash box color
                    + fixed some minor bugs
                    + some cleanup of source code
    v1.00/12.10.95  first version

    Remarks:

    This macro uses internal, undocumented data structures of TSE.
    E.g., it works with the current version (?.??) of TSE32, but
    there is absolutely no guarantee that it will also work with
    any future version of the editor.

    Acknowledgement:

    Thanks to Sammy Mitchell for pointing out some details about the
    tsehist.dat file format.

\****************************************************************************/

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"
#include "msgbox.si"
#include "dlghist1.si"
#include "dlghist2.si"
#include "dlghist3.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "dlghist1.dlg"
#include "dlghist2.dlg"
#include "dlghist3.dlg"

/****************************************************************************\
    shared code
\****************************************************************************/

#include "scver.si"
#include "scrun.si"
#include "schelp.si"

/****************************************************************************\
    additional constants
\****************************************************************************/

constant HISTORY    = 6

constant FW_STRID   = 30
constant FW_INTID   = 5
constant FW_COUNT   = 7
constant FS_INTID   = FW_STRID + 1
constant FS_COUNT   = FW_STRID + FW_INTID + 1

constant HLP_WIDTH  = 70

/****************************************************************************\
    global variables
\****************************************************************************/

integer splash_color                    // color of scanning message

integer rc_hist1                        // buffer id (dialog resource)
integer rc_hist2                        // ditto (dialog resource)
integer rc_hist3                        // ditto (dialog resource)
integer histlist                        // ditto (list of history id's)
integer itemlist                        // ditto (list of history items)
integer editlist                        // ditto (list of user histories)
integer editbuff                        // ditto (copy of internal buffer)
integer userfile                        // ditto (current file at startup)

integer box                             // flag (notification box open)
integer crs                             // ditto (saved cursor state)

integer currhist                        // id of current history
string  currname[64]                    // name of current history

string  orphan[] = "[*** orphaned history id ***]"
string  magic_header[] = "®TSE History¯"

/****************************************************************************\
    maintenance help
\****************************************************************************/

helpdef DlgMaintHelp
    title = "Help on History Maintenance"
    width = HLP_WIDTH
    height = 15
    y = 4

    ""
    "   This dialog displays all the history lists, which currently"
    "   contain any items. The leftmost column shows the name of the"
    "   history list. The id and items columns display the numerical"
    "   identifier of the history list and the number of items each"
    "   list contains, respectively."
    ""
    '   If the list of history names includes "orphaned history id"'
    "   entries, press the UserHist button to repair the history list."
    "   These entries are not harmful in any way, but waste memory."
    "   Moreover, they will only appear, if you have tampered with"
    "   the history file (either manually or using DlgHist)."
    ""
    "   Summary of commands:"
    ""
    "   List        list contents of current history"
    "   Close       close the dialog box"
    "   Delete      empty current history (<Del>)"
    "   Scan        rescan the history lists"
    "   UserHist    user history maintenance"
    ""
end

/****************************************************************************\
    history list help
\****************************************************************************/

helpdef DlgHistHelp
    title = "Help on History List"
    width = HLP_WIDTH
    height = 15
    y = 4

    ""
    "   This dialog displays the items within the current history list."
    ""
    "   Summary of commands:"
    ""
    "   Close           close dialog box"
    "   Delete          delete current history entry (<Del>)"
    "   Delete All      delete all history entries"
    ""
end

/****************************************************************************\
    user history help
\****************************************************************************/

helpdef DlgUserHelp
    title = "Help on User History Maintenance"
    width = HLP_WIDTH
    height = 15
    y = 4

    ""
    "   This dialog displays the available user histories as stored"
    "   within the internal history list. This includes empty and"
    "   orphaned history lists. Orphaned history id's are generated"
    "   when you remove entire history lists using DlgHist, since TSE"
    "   does not reuse freed history id's. You can use the compress"
    "   command to clear all orphaned lists and consecutively renumber"
    "   the remaining lists."
#if EDITOR_VERSION >= 0x3000
    ""
    "   Summary of commands:"
    ""
    "   Save        save changes (terminates DlgHist)"
#else
    ""
    "   Warning. Saving the history lists abandons the editor. You"
    "   will not loose any data, however, since DlgHist refuses to"
    "   save the history list, whenever it finds files within the"
    "   ring which have not been saved."
    ""
    "   Summary of commands:"
    ""
    "   Save        save changes (abandons editor)"
#endif
    "   Cancel      abort all changes"
    "   Delete      remove entire history list (<Del>)"
    "   Compress    remove orphaned history id's and renumber"
    ""
end

/****************************************************************************\
    helper: notification box
\****************************************************************************/

proc OpenBox( string title )
    box = PopWinOpen(16,7,65,11,4,"",splash_color)
    if box
        crs = Set(Cursor,OFF)
        Set(Attr,splash_color)
        ClrScr()
        PutCtrStr(title,2)
    endif
end

proc CloseBox()
    if box
        PopWinClose()
        Set(Cursor,crs)
    endif
end

/****************************************************************************\
    helper: return list info
\****************************************************************************/

string proc GetStrId()
    return (RTrim(GetText(1,FW_STRID)))
end

integer proc GetIntId()
    return (Val(GetText(FS_INTID,FW_INTID)))
end

integer proc GetCount()
    return (Val(GetText(FS_COUNT,FW_COUNT)))
end

/****************************************************************************\
    helper: determine number of user entries
\****************************************************************************/

integer proc NumUserEntries()
    integer num, bid

    bid = GotoBufferId(HISTORY)
    PushPosition()
    GotoLine(2)
    num = CurrChar(1)
    PopPosition()
    GotoBufferId(bid)
    return (num)
end

/****************************************************************************\
    helper: kill entire history list (high level)
\****************************************************************************/

integer proc KillCurrHist()
    integer i, rc

    ExecDialog(Format(
        "MsgBox ",
        Chr(MB_OKCANCEL),
        Chr(MB_PROMPT),
        Chr(CNTRL_CTEXT),"Remove all entries from history list?"
    ))
    rc = Val(Query(MacroCmdLine)) == ID_OK
    if rc
        for i = NumHistoryItems(currhist) downto 1
            DelHistoryStr(currhist,i)
        endfor
    endif
    return (rc)
end

/****************************************************************************\
    helper: kill entire history list (low level and history file only)
\****************************************************************************/

proc KillUserHist()
    integer bid, rc = TRUE
    integer hist

    bid = GotoBufferId(editlist)
    hist = GetIntId()

    if GetCount() and GetStrId() <> orphan
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_YESNO),
            Chr(MB_PROMPT),
            Chr(CNTRL_CTEXT),"History list is not empty!",Chr(13),
            Chr(CNTRL_CTEXT),"Delete it anyway?"
        ))
        rc = Val(Query(MacroCmdLine)) == ID_YES
    endif

    if rc
        BegLine()
        KillToEol()
        InsertText(Format(orphan:-FW_STRID,hist:FW_INTID,"-":FW_COUNT))
        GotoBufferId(editbuff)
        while lFind(Chr(hist),"g^")
            KillLine()
        endwhile
    endif

    GotoBufferId(bid)
end

/****************************************************************************\
    create history id list
\****************************************************************************/

string proc GetHistIdName( integer id )
    integer bid
    string hist[128]

    case id
        when _EDIT_HISTORY_             return("Edit")
        when _NEWNAME_HISTORY_          return("NewName")
        when _EXECMACRO_HISTORY_        return("ExecMacro")
        when _LOADMACRO_HISTORY_        return("LoadMacro")
        when _KEYMACRO_HISTORY_         return("KeyMacro")
        when _GOTOLINE_HISTORY_         return("GotoLine")
        when _GOTOCOLUMN_HISTORY_       return("GotoColumn")
        when _REPEATCMD_HISTORY_        return("RepeatCmd")
        when _DOS_HISTORY_              return("Dos")
        when _FINDOPTIONS_HISTORY_      return("FindOptions")
        when _REPLACEOPTIONS_HISTORY_   return("ReplaceOptions")
        when _FIND_HISTORY_             return("Find")
        when _REPLACE_HISTORY_          return("Replace")
        when _FILLBLOCK_HISTORY_        return("FillBlock")
        when 184                        return("[HelpSearch]")
    endcase

    hist = Format("#",id,"#")

    bid = GotoBufferId(HISTORY)
    PushPosition()
    if lFind(Chr(id),"g^")
        if CurrLine() <= currhist
            hist = "[" + GetText(2,CurrLineLen()-1) + "]"
        elseif id < 128
            hist = orphan
        endif
    endif
    PopPosition()
    GotoBufferId(bid)

    return (hist)
end

proc ScanHistData()
    integer bid
    integer id, rc

    // show splash box and prepare buffer

    OpenBox("Scanning history lists. Please wait.")
    bid = GotoBufferId(histlist)
    EmptyBuffer()
    currhist = NumUserEntries() + 1

    // get history list id's

    for id = 255 downto 1
        rc = NumHistoryItems(id)
        if rc
            InsertLine(Format(
                GetHistIdName(id):-FW_STRID,id:FW_INTID,rc:FW_COUNT))
        endif
    endfor

    // return to resource buffer

    GotoBufferId(bid)
    CloseBox()
end

/****************************************************************************\
    make user history list
\****************************************************************************/

proc CopyUserList()
    integer bid

    bid = GotoBufferId(HISTORY)
    MarkLine(1,NumLines())
    GotoBufferId(editbuff)
    EmptyBuffer()
    CopyBlock()
    UnmarkBlock()
    GotoBufferId(bid)
end

proc MakeUserList( integer scan_upper )
    integer bid, id, num_ids, entries

    // show splash box and prepare list

    OpenBox("Scanning history lists. Please wait.")

    EmptyBuffer(editlist)

    bid = GotoBufferId(editbuff)
    GotoLine(2)
    num_ids = CurrChar(1)

    // scan unnamed user entries

    if scan_upper
        GotoBufferId(editlist)

        for id = 127 downto num_ids+1
            entries = NumHistoryItems(id)
            if entries
                InsertLine(Format(
                    orphan:-FW_STRID,id:FW_INTID,entries:FW_COUNT
                ))
            endif
        endfor
    endif

    // scan named user entries

    GotoBufferId(editbuff)

    for id = num_ids downto 1
        if id == CurrChar(1) and lFind(":","gc")
            currname = GetText(2,CurrLineLen()-1)
            Down()
        else
            currname = orphan
        endif
        currname = Format(currname:-FW_STRID,id:FW_INTID)
        entries = NumHistoryItems(id)
        if entries
            currname = Format(currname,entries:FW_COUNT)
        else
            currname = Format(currname,"-":FW_COUNT)
        endif
        InsertLine(currname,editlist)
    endfor

    // return to resource buffer

    GotoBufferId(bid)
    CloseBox()
end

/****************************************************************************\
    hist1: set dialog data
\****************************************************************************/

public proc Hist1DataInit()
    if CheckVersion("DlgHist",2,0)
        ExecMacro("DlgTerminate")
        return ()
    endif

    ExecMacro("DlgGetColor Dialog_Normal")
    splash_color = Val(Query(MacroCmdLine))

    ScanHistData()
    ExecMacro(Format("DlgSetData ",ID_LST1_HIST," ",histlist))
end

/****************************************************************************\
    hist1: control response functions
\****************************************************************************/

proc IdBtn1Scan()
    ScanHistData()
    ExecMacro(Format("DlgExecCntrl ",ID_LST1_HIST))
end

proc IdBtn1Kill()
    integer bid

    bid = GotoBufferId(histlist)
    currhist = GetIntId()
    if KillCurrHist()
        IdBtn1Scan()
    endif
    GotoBufferId(bid)
    ExecMacro(Format("DlgExecCntrl ",ID_LST1_HIST))
end

proc IdBtn1User()
    integer bid
    integer quit = FALSE

    bid = GotoBufferId(rc_hist3)
    if ExecDialog("dialog hist3")
        if Val(Query(MacroCmdLine)) == ID_OK
            quit = TRUE
        endif
    endif

    GotoBufferId(bid)
    if quit
        ExecMacro("DlgTerminate")
    else
        ExecMacro(Format("DlgExecCntrl ",ID_LST1_HIST))
    endif
end

proc IdOk1()
    integer bid

    bid = GotoBufferId(histlist)
    currname = GetStrId()
    currhist = GetIntId()

    GotoBufferId(rc_hist2)
    if ExecDialog("dialog hist2")
        if Val(Query(MacroCmdLine)) == ID_BTN2_ALL
            IdBtn1Scan()
        endif
    endif

    GotoBufferId(bid)
    ExecMacro(Format("DlgExecCntrl ",ID_LST1_HIST))
end

/****************************************************************************\
    hist1: message response functions
\****************************************************************************/

public proc Hist1Event()
    if Query(Key) == <Del>
        Set(Key,<Alt D>)
    endif
end

public proc Hist1DblClick()
    IdOk1()
end

public proc Hist1BtnDown()
    case CurrChar(POS_ID)
        when ID_OK          IdOk1()
        when ID_BTN1_KILL   IdBtn1Kill()
        when ID_BTN1_SCAN   IdBtn1Scan()
        when ID_BTN1_USER   IdBtn1User()
        when ID_HELP        InitHelp(HLP_WIDTH) QuickHelp(DlgMaintHelp)
    endcase
end

/****************************************************************************\
    hist2: set dialog data
\****************************************************************************/

public proc Hist2DataInit()
    integer i, bid

    bid = GotoBufferId(itemlist)
    EmptyBuffer()
    for i = NumHistoryItems(currhist) downto 1
        InsertLine(GetHistoryStr(currhist,i))
    endfor
    GotoBufferId(bid)

    ExecMacro(Format("DlgSetTitle 0 ",currname))
    ExecMacro(Format("DlgSetData ",ID_LST2_ITEMS," ",itemlist))
end

/****************************************************************************\
    hist2: control response functions
\****************************************************************************/

proc IdBtn2Del()
    integer rc, bid

    bid = GotoBufferId(itemlist)
    DelHistoryStr(currhist,CurrLine())
    KillLine()
    if CurrLine() > NumLines()
        Up()
    endif
    rc = NumLines()
    GotoBufferId(bid)
    if rc
        ExecMacro(Format("DlgExecCntrl ",ID_LST2_ITEMS))
    else
        ExecMacro(Format("DlgTerminate ",ID_BTN2_ALL))
    endif
end

proc IdBtn2All()
    if KillCurrHist()
        ExecMacro("DlgTerminate")
    else
        ExecMacro(Format("DlgExecCntrl ",ID_LST2_ITEMS))
    endif
end

/****************************************************************************\
    hist2: message response functions
\****************************************************************************/

public proc Hist2Event()
    if Query(Key) == <Del>
        Set(Key,<Alt D>)
    endif
end

public proc Hist2BtnDown()
    case CurrChar(POS_ID)
        when ID_BTN2_DEL    IdBtn2Del()
        when ID_BTN2_ALL    IdBtn2All()
        when ID_HELP        InitHelp(HLP_WIDTH) QuickHelp(DlgHistHelp)
    endcase
end

/****************************************************************************\
    hist3: set dialog data
\****************************************************************************/

public proc Hist3DataInit()
    CopyUserList()
    MakeUserList(TRUE)
    ExecMacro(Format("DlgSetData ",ID_LST3_USER," ",editlist))
end

/****************************************************************************\
    hist3: control response functions
\****************************************************************************/

proc IdBtn3Del()
    KillUserHist()
    ExecMacro(Format("DlgExecCntrl ",ID_LST3_USER))
end

proc IdBtn3Cmp()
    integer bid, num_items, new_num, old_num

    // goto history list

    OpenBox("Compressing history lists. Please wait.")
    bid = GotoBufferId(editlist)

    // remove orphans

    while lFind(orphan,"g^")
        KillUserHist()
        KillLine()
    endwhile

    // filter user list to id's only

    MarkColumn(1,FS_COUNT,NumLines(),FS_COUNT+FW_COUNT-1)
    KillBlock()
    MarkColumn(1,1,NumLines(),FW_STRID)
    KillBlock()
    lReplace(" ","","gn")

    // renumber hist names and entries within history file

    num_items = NumLines()
    for new_num = 1 to num_items
        GotoLine(new_num)
        old_num = Val(GetText(1,CurrLineLen()))
        GotoBufferId(editbuff)
        MarkColumn(1,1,NumLines(),1)
        lReplace(Chr(old_num),Chr(new_num),"lgn")
        UnmarkBlock()
        GotoBufferId(editlist)
    endfor

    // rescan user file and return to resource

    MakeUserList(FALSE)
    CloseBox()
    GotoBufferId(bid)
    ExecMacro(Format("DlgExecCntrl ",ID_LST3_USER))
end

#if EDITOR_VERSION >= 0x3000

proc IdOk3()
    integer bid, num

    // insert magic header

    bid = GotoBufferId(editbuff)
    GotoLine(2)
    num = CurrChar(1)
    BegFile()
    InsertText(Chr(num)+magic_header)
    BinaryMode(-2)
    SaveAs(LoadDir()+"tsehist.dat",_OVERWRITE_|_DONT_PROMPT_)
    LoadHistory()

    // terminate

    GotoBufferId(bid)
    ExecMacro("DlgTerminate")
end

#else

proc IdOk3()
    integer bid, num, count

    // search ring of files for unsaved items

    bid = GetBufferId()                 // this is the resource buffer
    num = NumFiles()                    // it's temporary => don't count it
    count = 0

    do num times
        NextFile(_DONT_LOAD_)           // first thing, quit resource buffer
        if FileChanged()
            count = count + 1
        endif
    enddo

    GotoBufferId(bid)

    // check for unsaved files and warn user

    Alarm()
    if count
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_OK),
            Chr(MB_ERROR),
            Chr(CNTRL_CTEXT),count," file(s) have not been saved!",Chr(13),
            Chr(CNTRL_CTEXT),Chr(13),
            Chr(CNTRL_CTEXT),"Cannot continue, since saving",Chr(13),
            Chr(CNTRL_CTEXT),"the history abandons the editor"
        ))
        return ()
    endif
    ExecDialog(Format(
        "MsgBox ",
        Chr(MB_YESNO),
        Chr(MB_WARN),
        Chr(CNTRL_CTEXT),"The editor must be",Chr(13),
        Chr(CNTRL_CTEXT),"ABANDONED",Chr(13),
        Chr(CNTRL_CTEXT),"after saving the history lists",Chr(13),
        Chr(CNTRL_CTEXT),Chr(13),
        Chr(CNTRL_CTEXT),"Do you wish to continue?"
    ))
    if Val(Query(MacroCmdLine)) <> ID_YES
        return()
    endif

    // insert magic header

    GotoBufferId(editbuff)
    GotoLine(2)
    num = CurrChar(1)
    BegFile()
    InsertText(Chr(num)+magic_header)
    BinaryMode(-2)
    SaveAs(LoadDir()+"tsehist.dat",_OVERWRITE_|_DONT_PROMPT_)

    // terminate

    GotoBufferId(bid)
    ExecMacro("DlgTerminate")
end

#endif

/****************************************************************************\
    hist3: message response functions
\****************************************************************************/

public proc Hist3Event()
    if Query(Key) == <Del>
        Set(Key,<Alt D>)
    endif
end

public proc Hist3BtnDown()
    case CurrChar(POS_ID)
        when ID_OK          IdOk3()
        when ID_BTN3_DEL    IdBtn3Del()
        when ID_BTN3_CMP    IdBtn3Cmp()
        when ID_HELP        InitHelp(HLP_WIDTH) QuickHelp(DlgUserHelp)
    endcase
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer rc
    integer quit = FALSE

    // save user file

    PushBlock()
    userfile = GetBufferId()

    // allocate list buffers

    histlist = CreateTempBuffer()
    itemlist = CreateTempBuffer()
    editlist = CreateTempBuffer()
    editbuff = CreateTempBuffer()
    rc = histlist and itemlist and editlist and editbuff

    // load dialog resources

    rc_hist3 = CreateTempBuffer()
    rc = rc and rc_hist3 and InsertData(dlghist3)
    rc_hist2 = CreateTempBuffer()
    rc = rc and rc_hist2 and InsertData(dlghist2)
    rc_hist1 = CreateTempBuffer()
    rc = rc and rc_hist1 and InsertData(dlghist1)

    // run dialog main dialog

    if rc and ExecDialog("dialog hist1")
#if EDITOR_VERSION < 0x3000
        quit = Val(Query(MacroCmdLine)) == ID_BTN1_USER
#endif
    else
        Warn("DlgHist: Error executing history dialog")
    endif

    // clean up data

    AbandonFile(rc_hist1)
    AbandonFile(rc_hist2)
    AbandonFile(rc_hist3)
    AbandonFile(editbuff)
    AbandonFile(editlist)
    AbandonFile(itemlist)
    AbandonFile(histlist)

    // restore user file

    GotoBufferId(userfile)
    PopBlock()
    UpdateDisplay(_HELPLINE_REFRESH_)

    // purge self

    if quit
        Set(PersistentHistory,OFF)
        UpdateDisplay()
        AbandonEditor()
    else
        PurgeMacro(CurrMacroFilename())
    endif
end

