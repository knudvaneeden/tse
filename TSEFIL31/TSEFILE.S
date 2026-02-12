/****************************************************************************\

    TSEFile.S

    File manager

    See on-line help or doc-file for instructions.

    Version         v3.10/28.04.95
    Copyright       (c) 1994,95 by DiK

    History

    v3.10/28.04.95  extended version (file compare)
                    þ moved CopyDiskFile to external file (TSEFile1)
                    þ added file comparison (binary)
                    þ added TSEComp interface
                    þ fixed DupDesc (emptied wrong buffer)
                    þ fixed ForAllFiles (break MsgBox)
                    þ fixed some minor quirks

    v3.00/09.04.95  extended version (subtree support)
                    þ added menus and added key bindings
                    þ changed confirmation logic
                    þ changed browsing mode (use hooked list)
                    þ changed speed search (search backward)
                    þ moved input functions to external file (TSEFile1)
                    þ moved menus to external file (TSEFile2)
                    þ moved quick help to external file (TSEFile2)
                    þ added quick help for pick and browsing lists
                    þ added DateFormat handling
                    þ added more configuration variables
                    þ added command hook (speed search)
                    þ added dirlist printing
                    þ added quit to current dir
                    þ added file descriptions
                    þ added application launching
                    þ added subtree management (TSEFile1)
                    þ added file and text searching (TSEFile1)
                    þ added tree listing and directory searching (TSEFile1)
                    þ fixed highlight positioning
                    þ fixed entry/exit code quirks
                    þ fixed MessageBox (YN-bug,open_box)
                    þ fixed ExpandTabs (garbles files list)
                    þ general clean up of program code

    v2.01/29.12.94  new version for TSE 2.0
                    þ fixed file loading quirks

    v2.00/16.11.94  new version for TSE 2.0
                    þ changed menus and some key bindings
                    þ changed drag & drop (move=LeftBtn, copy=CtrlLeftBtn)
                    þ added current directory display
                    þ added speed search feature
                    þ added execute macro feature
                    þ added file duplication
                    þ added restore directory and directory info
                    þ added goto mark commands and wildcard marking
                    þ added options saving and configuration file
                    þ added sorting for tag marks
                    þ added help lines for menus
                    þ removed hidden and system file support
                    þ removed sort menu (now Options.SortField)
                    þ removed most binaries (used new SAL features instead)

    v1.1x/04.10.94  first update
                    þ fixed some minor bugs
                    þ added multiple file load
                    þ included new browsing mode
                    þ included directory reading message

    v1.00/07.01.94  primary release
                    þ load current file into editor
                    þ browse current file or directory
                    þ choose files (wildcards,attributes)
                    þ sort directory lists (name,ext,size,date)
                    þ directory operations (cd,mkdir,rmdir)
                    þ file operations (copy,move,del,rename)
                    þ drag & drop (copy or move files)

\****************************************************************************/

/****************************************************************************\

    Additional comments
    -------------------

    Public functions
    ----------------
    Due to the size of the code TSEFile had to be split into three
    parts. Public functions are used to transfer program control between
    the different modules and data is passed via three session global
    variables. Furthermore, all the configuration variables are stored
    in session global variables, so that they may be easily accessed
    from all the modules. Public functions are prefixed with a "TF_" for
    ease of reference. All session global variables are cleared during
    program shutdown.

    Global variables
    ----------------
    Since TSEFile uses various levels of variables, all global and
    session global variables, which are used within a routine, are now
    indicated in the comments prior to the function body. The following
    notation is used:
        þ IN    variable is used as input and must be defined
        þ OUT   variable is set as result of the function
        þ IO    variable is both input and output (var parameter)
        þ USE   variable is changed (neither input nor output)
    The prefixes G and S denote global and session global variables,
    respectively.

    Chained commands
    ----------------
    A few commands must be executed delayed, because their input is
    edited inline within the menus, e.g. the menus must not be closed
    until the input is completed. The commands, on the other hand,
    should be executed only after the menu system is closed. This is
    achieved by putting one character codes into the global variable
    chain and executing the corresponding action in the _after_command_
    hook. The following keys are used with this version of the program.
        þ L     refresh both file lists
        þ S     sort current file listing (sfield)
        þ M     set tag marks via expression (tmask)
        þ T     read trees of all configured drives (drives)
        þ X     launch the file provided by "source"

    Speed search
    ------------
    In order for the speed search feature to work properly, it is
    important that no key with a normal ascii code leaks through to the
    _after_command_ hook. This means in particular, that each menu
    command must be passed through a filter which sets the internal key
    variable to -1. Key bindings using ctrl and alt combinations and
    special keys are harmless in most cases, e.g. they can be used
    unfiltered.

\****************************************************************************/

/****************************************************************************\
  ú Global constants
\****************************************************************************/

#include ["tsefile.src"]

/****************************************************************************\
  ú Constants and variables
\****************************************************************************/

constant    MAX_DESC    = 254           // maximum length of descriptions

/****************************************************************************\
  ú Constants strings
\****************************************************************************/

string  TC_ALL[]    = Chr(TC_DIR) + Chr(TC_NODIR)

/****************************************************************************\
  ú Global variables
\****************************************************************************/

integer file, buff                  // buffer id's (user file & temp)
integer ldir, rdir                  // dito (left & right dir lists)
integer ldsc, rdsc                  // dito (left & right descriptions)
integer tdsc                        // dito (descriptions)
integer h_desc                      // history id (file descriptions)
integer msg_key                     // last key pressed within a MsgBox
integer undo_line                   // line number for undo operation
string  chain[8]                    // chained commands
string  start[80]                   // current directory at startup
string  other[80]                   // directory of inactive window
string  macro[128]                  // launched macro
string  undo[MAX_DESC]              // undo buffer for description editing
string  clip[MAX_DESC]              // clipboard for description editing

/****************************************************************************\
  ú Editor environment changes
\****************************************************************************/

integer fmExpandTabs,
        fmTabWidth,
        fmTabType,
        fmCurrVideoMode,
        fmShowEOFMarker,
        fmTextAttr,
        fmCursorAttr,
        fmCurrWinBorderAttr,
        fmOtherWinBorderAttr,
        fmMenuTextAttr,
        fmMenuTextLtrAttr,
        fmMenuSelectAttr,
        fmMenuSelectLtrAttr,
        fmMenuBorderAttr

/****************************************************************************\
  ú Forward definitions
\****************************************************************************/

forward string proc GetDir()
forward integer proc LogDir( string dir )
forward integer proc IsDir()
forward integer proc ThisFile( var string name )
forward integer proc BuildFileList( string dir )

/****************************************************************************\
  ú Library calls

    þ Call              no argument call
    þ CallInt           switch only call
    þ CallSrc           source only call
    þ CallSrcInt        source & switch call
    þ CallSrcTgt        source & target call
\****************************************************************************/

integer proc Call( string mac )
    ExecMacro("TF_"+mac)
    Set(Key,-1)
    return (GetGlobalInt(switch))
end

integer proc CallInt( string mac, integer int )
    SetGlobalInt(switch,int)
    return (Call(mac))
end

integer proc CallSrc( string mac, string src )
    SetGlobalStr(source,src)
    return (Call(mac))
end

integer proc CallSrcInt( string mac, string src, integer int )
    SetGlobalInt(switch,int)
    SetGlobalStr(source,src)
    return (Call(mac))
end

integer proc CallSrcTgt( string mac, string src, string tgt )
    SetGlobalStr(source,src)
    SetGlobalStr(target,tgt)
    return (Call(mac))
end

/****************************************************************************\
  ú Communication

    þ MsgBox            message popup window
        ù GOUT  msg_key     return code
    þ AskText           read text via input box
        ù USE   switch      operation flag
                source      user input
                target      prompt string
    þ DontDestroy       confirm destructive actions
        ù SIN   confirm     confirmation level

    PRECONDITION for MsgBox: Length(msg) <= 46
\****************************************************************************/

integer proc MsgBox( string msg, integer flags )
    msg_key = CallSrcInt("MsgBox",msg,flags)
    return (msg_key)
end

integer proc AskText( string prompt, var string text, integer flags )
    integer rc

    SetGlobalInt(switch,flags)
    rc = CallSrcTgt("AskText",text,prompt)
    text = GetGlobalStr(source)
    return (rc)
end

integer proc DontDestroy( integer level, string prompt )
    integer conf = GetGlobalInt(confirm)

    if (conf == WARN_ALL) or (level == WARN_TREE) or (level == conf)
        loop
            case MsgBox(prompt,MB_INPBOX)
                when <Escape>   return (TRUE)
                when <Enter>    break
                otherwise       Alarm()
            endcase
        endloop
    endif
    return (FALSE)
end

/****************************************************************************\
  ú Screen funtions

    þ UpdateScreen      display current directory
    þ SplitScreen       split screen for dual list display
    þ SwitchWindow      activate other window
        ù GOUT  undo_line   clear line number
    þ TF_VideoMode      change the current display mode
        ù IN    switch      number of video mode
\****************************************************************************/

proc UpdateScreen()
    string where[12]

    if GetBufferId() == ldir
        where = "Left:"
    else
        where = "Right:"
    endif
    Message(where:-8,GetDir())
end

proc SplitScreen( integer id )
    UpdateDisplay()
    GotoBufferId(ldir)
    OneWindow()
    VWindow()
    PushKey(<Enter>)
    PushKey(<CursorLeft>)
    ResizeWindow()
    GotoBufferId(rdir)
    GotoWindow(id)
    Set(StatusLineUpdating,OFF)
    Set(Cursor,OFF)
    UpdateDisplay()
end

integer proc SwitchWindow()
    integer rc
    integer zoomed = isZoomed()
    string current[80] = GetDir()

    undo_line = 0
    if zoomed
        ZoomWindow()
    endif
    NextWindow()
    if zoomed
        ZoomWindow()
    endif
    rc = LogDir(other)
    other = current
    if not rc
        BuildFileList("")
    endif
    return (rc)
end

public proc TF_VideoMode()
    integer id = WindowId()
    integer zoomed = isZoomed()

    Set(CurrVideoMode,GetGlobalInt(switch))
    SplitScreen(id)
    if zoomed
        ZoomWindow()
    endif
end

/****************************************************************************\
  ú File list helper functions

    þ MakeWild          translate dos wildcards to regular expression
        ù GUSE  buff        translation buffer
    þ MakeWild1         same as above, but for raw directory listings
        ù GUSE  buff        translation buffer
    þ TestWild          test current name against wildcard specification
        ù GUSE  buff        scanning buffer
    þ CountItems        count characters in a specified column
    þ TotalSize         sum the file sizes
    þ GetFileMask       determine the current file mask
        ù SIN   lmask       file listing mask
                rmask       dito
\****************************************************************************/

string proc MakeWild( string wildcard )
    integer id
    string res[32]

    id = GotoBufferId(buff)
    AddLine(wildcard)
    lReplace("{[.^$+@#{}]}","\\\1","cgxn")      // escape special characters
    lReplace("*",".*","cgn")                    // replace dos wildcards
    lReplace("?",".","cgn")                     // with regular expression
    res = GetText(1,CurrLineLen())
    EmptyBuffer()
    GotoBufferId(id)
    return (res)
end

string proc MakeWild1( string wildcard )
    integer id
    string res[32]

    id = GotoBufferId(buff)
    AddLine(wildcard)
    lReplace("{[^$+@#{}]}","\\\1","cgxn")       // escape special characters
    lReplace("."," #\.","cgn")                  // dot with leading spaces
    lReplace("*",".*","cgn")                    // replace dos wildcards
    lReplace("?",".","cgn")                     // with regular expression
    res = "\\?" + GetText(1,CurrLineLen()) + "\\"
    EmptyBuffer()
    GotoBufferId(id)
    return (res)
end

integer proc TestWild( string wildcard )
    integer rc, id
    string name[16]

    name = GetText(3,12)
    id = GotoBufferId(buff)
    AddLine(Trim(name))
    lReplace(" #","\.","cgxn")                  // blanks to dot
    lReplace("^{[~\.]#}$","\1.","cgxn")         // add trailing dot
    rc = lFind(wildcard,"cgix")
    EmptyBuffer()
    GotoBufferId(id)
    return(rc)
end

integer proc CountItems( integer column, integer item )
    integer count = 0

    PushPosition()
    BegFile()
    repeat
        if CurrChar(column) == item
            count = count + 1
        endif
    until not Down()
    PopPosition()
    return (count)
end

proc TotalSize( var integer total, var integer tagged )
    integer size

    total = 0
    tagged = 0
    PushPosition()
    BegFile()
    repeat
        size = Val(GetText(16,8))
        total = total + size
        if CurrChar(1) == TC_TAG
            tagged = tagged + size
        endif
    until not Down()
    PopPosition()
end

string proc GetFileMask()
    if GetBufferId() == ldir
        return (GetGlobalStr(lmask))
    endif
    return (GetGlobalStr(rmask))
end

/****************************************************************************\
  ú Low level file description functions

    þ DescId            id of current description buffer
    þ ReadDesc          read current description from buffer
        ù GUSE  buff        scanning buffer
    þ WriteDesc         write descriptions to buffer
        ù GUSE  buff        scanning buffer
    þ InsertDesc        insert description into file list
    þ PutDesc           insert description into file list and buffer
    þ DupDesc           copy description to renamed or new file
        ù GUSE  tdsc        temporary description buffer
    þ LoadDesc          read and insert descriptions file
\****************************************************************************/

integer proc DescId()
    return (iif( GetBufferId() == ldir, ldsc, rdsc ))
end

integer proc ReadDesc( var string desc, string name, integer buffer )
    integer id, rc = 0

    id = GotoBufferId(buffer)
    lFind("^"+MakeWild(name)+" #{[~]@}","gix")
    MarkFoundText(1)
    if isBlockInCurrFile()
        desc = GetMarkedText()
        rc = Query(BlockEndCol) - Query(BlockBegCol)
        UnmarkBlock()
    else
        desc = ""
    endif
    GotoBufferId(id)
    return (rc)
end

proc WriteDesc( string desc, string name, integer buffer )
    integer id

    id = GotoBufferId(buffer)
    if lFind("^"+MakeWild(name)+"$|{ #\c{[~]@}}","gix")
        if Length(desc)
            MarkFoundText(2)
            KillBlock()
            InsertText(desc,_INSERT_)
        else
            KillLine()
        endif
    else
        if Length(desc)
            BegLine()
            AddLine(name+" "+desc)
        endif
    endif
    GotoBufferId(id)
end

proc InsertDesc( string desc )
    GotoPos(41)
    KillToEol()
    if Length(desc) > 36
        InsertText(SubStr(desc,1,35)+"")
    else
        InsertText(desc)
    endif
    BegLine()
end

proc PutDesc( string desc, string name )
    WriteDesc(desc,name,DescId())
    InsertDesc(desc)
end

proc DupDesc( string name, string newname )
    string new[12]
    string path[80]
    string curr[80] = GetDir()
    string desc[MAX_DESC] = ""

    if ReadDesc(desc,name,DescId())
        new = SplitPath(newname,_NAME_|_EXT_)
        path = SplitPath(ExpandPath(newname),_DRIVE_|_PATH_)
        if path == curr
            PutDesc(desc,new)
        elseif path == other
            if SwitchWindow()
                PutDesc(desc,new)
            endif
            SwitchWindow()
        else
            if LogDir(path)
                CallInt("ReadDesc",tdsc)
                WriteDesc(desc,new,tdsc)
                CallInt("WriteDesc",tdsc)
                EmptyBuffer(tdsc)
                LogDir(curr)
            endif
        endif
    endif
end

proc LoadDesc()
    integer dsc = DescId()
    string name[32] = ""
    string desc[MAX_DESC] = ""

    if CallInt("ReadDesc",dsc)
        PushPosition()
        BegFile()
        repeat
            if ThisFile(name) and ReadDesc(desc,name,dsc)
                InsertDesc(desc)
            endif
        until not Down()
        PopPosition()
    endif
end

/****************************************************************************\
  ú High level file description functions

    þ TF_UndoDesc       undo last change of description
        ù GIN   undo        undo buffer
                undo_line   number of most recently changed line
    þ TF_CutCopyDesc    cut or copy description to clipboard
        ù IN    switch      operation flag
        ù GOUT  clip        clipboard
    þ TF_DelPasteDesc   delete or paste description from clipboard
        ù IN    switch      operation flag
        ù GIN   clip        clipboard
        ù GOUT  undo        undo buffer
                undo_line   number of most recently changed line
    þ TF_SetAllDesc     set the descriptions of all directory entries
        ù IN    switch      tagged files flag
    þ TF_EditDesc       edit description of current file
        ù IN    switch      inline editing flag
        ù GIN   h_desc      history id
        ù GOUT  undo        undo buffer
                undo_line   number of most recently changed line
    þ TF_SaveDesc       save description files on disk
        ù IN    savedsc
    þ CheckHook         alter garbage list
    þ GarbageText       format strings for TF_CheckDesc
    þ TF_CheckDesc      check description file for garbage
        ù GUSE  tdsc        temporary description buffer
\****************************************************************************/

public proc TF_UndoDesc()
    string name[32] = ""
    string desc[MAX_DESC] = ""

    if isZoomed() and 1 <= undo_line and undo_line <= NumLines()
        GotoLine(undo_line)
        if ThisFile(name)
            ReadDesc(desc,name,DescId())
            PutDesc(undo,name)
            undo = desc
        endif
    else
        Alarm()
    endif
end

public proc TF_CutCopyDesc()
    integer cutdesc = GetGlobalInt(switch)
    string name[32] = ""

    if isZoomed()
        if ThisFile(name)
            ReadDesc(clip,name,DescId())
            if cutdesc
                PutDesc("",name)
            endif
        endif
    else
        Alarm()
    endif
end

public proc TF_DelPasteDesc()
    integer deldesc = GetGlobalInt(switch)
    string name[32] = ""

    if isZoomed()
        if ThisFile(name)
            undo_line = CurrLine()
            ReadDesc(undo,name,DescId())
            if deldesc
                PutDesc("",name)
            else
                PutDesc(clip,name)
            endif
        endif
    else
        Alarm()
    endif
end

public proc TF_SetAllDesc()
    integer all = GetGlobalInt(switch)
    string name[32] = ""
    string desc[MAX_DESC] = ""

    if AskText("Enter description:",desc,IB_DESC|IB_NULL)
        PushPosition()
        BegFile()
        repeat
            if ThisFile(name) and (all or CurrChar(1) == TC_TAG)
                PutDesc(desc,name)
            endif
        until not Down()
        PopPosition()
    endif
end

public proc TF_EditDesc()
    integer len, rc, ba, ma
    string name[32] = ""
    string desc[MAX_DESC] = ""
    string msg[36] = "More than "+Str(MAX_DESC)+" characters! Truncate?"

    if ThisFile(name)
        len = ReadDesc(desc,name,DescId())
        if len <= 36 and isZoomed() and GetGlobalInt(switch)
            UpdateDisplay()
            GotoPos(41)
            UpdateDisplay()
            ma = Set(MsgAttr,CC_PROMPT)
            ba = Set(BlockAttr,CC_BLOCK)
            rc = lRead(desc,36,h_desc)
            Set(MsgAttr,ma)
            Set(BlockAttr,ba)
        else
            if len > MAX_DESC and MsgBox(msg,MB_INPBOX) == <Escape>
                return ()
            endif
            rc = AskText("Enter new description:",desc,IB_DESC|IB_NULL)
        endif
        if rc
            undo_line = CurrLine()
            ReadDesc(undo,name,DescId())
            PutDesc(Trim(desc),name)
        endif
        BegLine()
        UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    endif
end

public proc TF_SaveDesc()
    CallInt("WriteDesc",DescId())
    if SwitchWindow()
        CallInt("WriteDesc",DescId())
    endif
    SwitchWindow()
end

proc CheckHook()
    WindowFooter("  {Enter}-Delete Garbage  {Escape}-Quit  ")
    Unhook(CheckHook)
    BreakHookChain()
end

string proc GarbageText( integer part )
    MarkFoundText(part)
    if isBlockInCurrFile()
        return (GetMarkedText())
    endif
    return ("<none>")
end

public proc TF_CheckDesc()
    integer id, did, rc
    string name[32] = ""
    string desc[80] = ""

    // check appropriate file mask

    if GetFileMask() <> "*.*"
        MsgBox("File list is incomplete! Reset file mask!",MB_ERRBOX)
        return()
    endif

    // copy descriptions

    MsgBox("Checking descriptions",MB_OPEN)
    did = DescId()
    id = GotoBufferId(did)
    rc = NumLines()
    if rc
        MarkLine(1,NumLines())
        GotoBufferId(tdsc)
        CopyBlock()
        UnmarkBlock()
    endif

    // compress copy

    GotoBufferId(id)
    if rc
        PushPosition()
        BegFile()
        repeat
            if ThisFile(name) and ReadDesc(desc,name,tdsc)
                WriteDesc("",name,tdsc)
            endif
        until not Down()
        PopPosition()
    endif

    // format garbage

    GotoBufferId(tdsc)
    if NumLines()
        EndFile()
        repeat
            lFind("^{[~ ]#} @{[~]@}","cgx")
            name = GarbageText(1)
            desc = GarbageText(2)
            BegLine()
            KillToEol()
            InsertText(Format(name:-15,desc))
        until not Up()
    endif
    MsgBox("",MB_CLOSE)

    // display garbage

    if rc and NumLines()
        Hook(_LIST_STARTUP_,CheckHook)
        rc = List("Garbage collection",80)
    else
        MsgBox("No garbage found",MB_INFBOX)
        rc = FALSE
    endif

    // remove garbage

    if rc
        MsgBox("Removing garbage",MB_OPEN)
        BegFile()
        repeat
            if lFind("^[~ ]#","cgx")
                MarkFoundText()
                name = GetMarkedText()
                WriteDesc("",name,did)
            endif
        until not Down()
        GotoBufferId(did)
        while lFind("{^$}|{^ }","gx")
            KillLine()
        endwhile
        MsgBox("",MB_CLOSE)
    endif

    // clean up

    EmptyBuffer(tdsc)
    GotoBufferId(id)
end

/****************************************************************************\
  ú Low level file listing functions

    þ SortTime          sort time field
        ù SIN   sorder
    þ SortFileList      sort directory listing
        ù SIN   sfield
                sorder
    þ SortBothLists     sort both directory listings
    þ DateStr           format date
    þ BuildFileList     build directory listing
\****************************************************************************/

proc SortTime()
    integer order = GetGlobalInt(sorder)

    MarkColumn(1,34,NumLines(),38)              // sort time
    Sort(order)
    case Query(DateFormat)
        when 1
            MarkColumn(1,25,NumLines(),29)
            Sort(order)
            MarkColumn(1,31,NumLines(),32)
        when 2
            MarkColumn(1,25,NumLines(),26)
            Sort(order)
            MarkColumn(1,28,NumLines(),29)
            Sort(order)
            MarkColumn(1,31,NumLines(),32)
        otherwise
            MarkColumn(1,25,NumLines(),32)      // last sort in SortFileList
    endcase
end

proc SortFileList()

    // sort names first

    MarkColumn(1,3,NumLines(),14)
    Sort(_DEFAULT_)

    // sort specified field

    case GetGlobalInt(sfield)
        when DS_NAME   MarkColumn(1, 3,NumLines(),10)
        when DS_EXT    MarkColumn(1,12,NumLines(),14)
        when DS_SIZE   MarkColumn(1,16,NumLines(),23)
        when DS_TIME   SortTime()
        when DS_DESC   MarkColumn(1,41,NumLines(),80)
        when DS_MARK   MarkColumn(1, 1,NumLines(), 1)
    endcase
    Sort(GetGlobalInt(sorder))

    // always put directories on top

    MarkColumn(1,2,NumLines(),2)
    Sort(_DEFAULT_)
    UnmarkBlock()
end

proc SortBothLists()
    SortFileList()
    if SwitchWindow()
        SortFileList()
    endif
    SwitchWindow()
end

string proc DateStr( integer date )
    case Query(DateFormat)
        when 1
            return (Format(
                (date shr 5 & 0x0F) :2:"0",     Chr(Query(DateSeparator)),
                (date & 0x1F)       :2:"0",     Chr(Query(DateSeparator)),
                (date shr 9) + 80   :2:"0",     " "
            ))
        when 2
            return (Format(
                (date & 0x1F)       :2:"0",     Chr(Query(DateSeparator)),
                (date shr 5 & 0x0F) :2:"0",     Chr(Query(DateSeparator)),
                (date shr 9) + 80   :2:"0",     " "
            ))
    endcase
    return (Format(
        (date shr 9) + 80   :2:"0",     Chr(Query(DateSeparator)),
        (date shr 5 & 0x0F) :2:"0",     Chr(Query(DateSeparator)),
        (date & 0x1F)       :2:"0",     " "
    ))
end

integer proc BuildFileList( string dir )
    string intro1[2] = Chr(TC_NOTAG) + Chr(TC_DIR)
    string intro2[2] = Chr(TC_NOTAG) + Chr(TC_NODIR)
    string line[40]
    string curr[12]
    string name[12], ext[3]
    integer row, isdir, time, date, size

    // save current position and name

    row = CurrRow()
    curr = GetText(3,12)

    // clear buffer, save current descriptions and change directory

    EmptyBuffer()
    CallInt("WriteDesc",DescId())
    if Length(dir) and not LogDir(dir)
        return (FALSE)
    endif

    // get and filter contents of current directory

    BuildPickBuffer("*.*")
    if NumLines() == 0
        return (TRUE)
    endif

    MarkColumn(1,10,NumLines(),10)
    FillBlock(".")
    MarkColumn(1,14,NumLines(),14)
    FillBlock("\")
    UnmarkBlock()
    line = GetFileMask()
    if line <> "*.*"
        line = MakeWild1(line)
        repeat
            if not lFind(line,"^cgix")
                KillLine()
            endif
        until not Up()
    endif
    if NumLines() == 0
        return (TRUE)
    endif

    // format file list (binary to decimal)

    BegFile()
    repeat
        line = GetText(1,22)
        time = Asc(line[15]) + (Asc(line[16]) shl 8)
        date = Asc(line[17]) + (Asc(line[18]) shl 8)
        size = Asc(line[19]) + (Asc(line[20]) shl 8)
               + (Asc(line[21]) shl 16) + (Asc(line[22]) shl 24)
        isdir = line[1] == "\"
        if isdir
            name = SubStr(line,2,8)
        else
            name = SubStr(line,1,8)
        endif
        ext = SubStr(line,11,3)
        line = Format(
            iif( isdir, intro1, intro2 ),
            name,   " ",
            ext,    Chr(TC_NOTAG),
            iif( isdir, "<DIR>", Str(size) ):8,   " ",
            DateStr(date),
            (time shr 11)       :2:"0",     Chr(Query(TimeSeparator)),
            (time shr 5 & 0x3F) :2:"0"
        )
        InsertText(line,_OVERWRITE_)
        BegLine()
    until not Down()
    BegFile()

    // get file descriptions

    LoadDesc()

    // sort and position the file list

    SortFileList()
    if Length(dir) == 0 and lFind("^.."+MakeWild(curr),"gx")
        ScrollToRow(row)
    else
        BegFile()
    endif

    return (TRUE)
end

/****************************************************************************\
  ú High level file listing functions

    þ ListFiles         build file list with current sorting
        ù GOUT  undo_line   clear line number
    þ TF_Refresh        re-reads the directory listings
\****************************************************************************/

integer proc ListFiles( integer flags, string dir )
    integer rc
    string old[80]
    string new[80]

    Message(banner)
    MsgBox("Updating directory",MB_OPEN|MB_LOAD)
    undo_line = 0

    old = GetDir()
    if flags & LF_THIS
        rc = BuildFileList(dir)
    endif
    new = GetDir()

    if (flags & LF_OTHER) or old == other or new == other
        if SwitchWindow()
            BuildFileList("")
        endif
        SwitchWindow()
    endif

    MsgBox("",MB_CLOSE)
    return (rc)
end

public proc TF_Refresh()
    ListFiles(LF_BOTH,"")
end

/****************************************************************************\
  ú Marking commands

    þ GotoTag           search tag marks
    þ TagMask           set tags via expression
        ù IN    target      tagging mask
    þ TagBlock          set tags in a block
    þ TagExtend         set or extend tags
    þ TF_TagFiles       set tags on all files or directories
        ù SIN   switch      tagging operation (on,off,toggle)
                source      tagging mask (files,dirs,all)
\****************************************************************************/

proc GotoTag( string option )
    MarkColumn(1,1,NumLines(),1)
    if lFind(Chr(TC_TAG),option)
        ScrollToRow(10)
    else
        Alarm()
    endif
    UnmarkBlock()
end

proc TagMask()
    string wildcard[64] = GetGlobalStr(target)

    MsgBox("Placing marks",MB_OPEN)
    PushPosition()
    BegFile()
    wildcard = "^" + MakeWild(wildcard) + "$"
    repeat
        if TestWild(wildcard) and CurrChar(3) <> Asc(".")
            lReplace("^.",Chr(TC_TAG),"cgxn")
        endif
    until not Down()
    PopPosition()
    MsgBox("",MB_CLOSE)
end

proc TagBlock( integer tag, string mask )
    string expr[16]

    expr = "{[" + mask + "][~\.]}"
    case tag
        when TM_OFF
            lReplace("."+expr,Chr(TC_NOTAG)+"\1","lgxn")
        when TM_ON
            lReplace("."+expr,Chr(TC_TAG)+"\1","lgxn")
        when TM_TOGGLE
            lReplace(Chr(TC_TAG)+expr,Chr(TC_TOGGLE)+"\1","lgxn")
            lReplace(Chr(TC_NOTAG)+expr,Chr(TC_TAG)+"\1","lgxn")
            lReplace(Chr(TC_TOGGLE)+expr,Chr(TC_NOTAG)+"\1","lgxn")
    endcase
    UnmarkBlock()
end

proc TagExtend( integer tag )
    integer start, stop = CurrLine()

    PushPosition()
    if tag & TM_EXTEND
        tag = TM_ON
        MarkColumn(1,1,NumLines(),1)
        if not lFind(Chr(TC_TAG),"lb")
            lFind(Chr(TC_TAG),"l+")
        endif
    endif
    start = CurrLine()
    PopPosition()
    MarkColumn(start,1,stop,3)
    TagBlock(tag,TC_ALL)
end

public proc TF_TagFiles()
    MarkColumn(1,1,NumLines(),3)
    TagBlock(GetGlobalInt(switch),GetGlobalStr(source))
end

/****************************************************************************\
  ú Low level directory functions

    þ GetDir            get current directory
    þ LogDir            change dos directory
\****************************************************************************/

string proc GetDir()
    return (SplitPath(ExpandPath(""),_DRIVE_|_PATH_))
end

integer proc LogDir( string dir )
    integer rc

    rc = ChDir(dir)
    if rc
        if Length(dir) > 2 and dir[2] == ":"
            LogDrive(dir[1])
        endif
    else
        MsgBox("Invalid directory name",MB_ERRBOX)
    endif
    return (rc)
end

/****************************************************************************\
  ú High level directory functions

    þ TF_TreeCmd        execute tree command
        ù IN    switch      tree listing flag (passed on to TF_TreeCommand)
        ù USE   source      directory names for changing dirs
    þ TF_ChangeDrv      change current drive
    þ TF_MakeDir        create a new directory
    þ TF_ChangeDir      change current directory
    þ TF_RestoreDir     return to startup directory
    þ TF_DirInfo        display info about current directory
\****************************************************************************/

public proc TF_TreeCmd()
    if Call("TreeCommand")
        ListFiles(LF_THIS,GetGlobalStr(source))
    endif
end

public proc TF_ChangeDrv()
    integer RC

    loop
        RC = MsgBox("Press drive letter or Escape",MB_RAWINP)
        if RC == <Escape>
            break
        elseif ListFiles(LF_THIS,Chr(RC)+":.")
            break
        endif
    endloop
end

public proc TF_CreateDir()
    integer flags = LF_THIS
    string dir[80] = ""

    if AskText("Enter directory name:",dir,IB_DIRS)
        if other == GetDir()
            flags = flags | LF_OTHER
        endif
        if CallSrc("MakeDir",dir)
            ListFiles(flags,dir)
        endif
    endif
end

public proc TF_ChangeDir()
    string dir[80] = ""

    if AskText("Enter directory name:",dir,IB_DIRS)
        if FileExists(dir) & _DIRECTORY_
            ListFiles(LF_THIS,dir)
        else
            CallSrcInt("TreeCmd",dir,TC_CHDIR)
        endif
    endif
end

public proc TF_RemoveDir()
    string dir[32] = ""

    if ThisFile(dir)
        if CallSrc("RmDir",dir)
            ListFiles(LF_THIS,"")
        endif
    endif
end

public proc TF_RestoreDir()
    if FileExists(start) & _DIRECTORY_
        ListFiles(LF_THIS,start)
    else
        MsgBox("Startup directory not found",MB_ERRBOX)
    endif
end

public proc TF_DirInfo()
    integer tags = CountItems(1,TC_TAG)
    integer dirs = CountItems(2,TC_DIR)
    integer total, tagged

    TotalSize(total,tagged)
    if PopWinOpen(21,6,60,18,1,"Directory Info",CC_INFO)
        Set(Cursor,OFF)
        Set(Attr,CC_INFO)
        ClrScr()
        VGotoXY( 4, 2) PutStr("File display mask")
        VGotoXY( 4, 4) PutStr("Subdirectories")
        VGotoXY( 4, 6) PutStr("Marked files")
        VGotoXY( 4, 7) PutStr("Marked file size")
        VGotoXY( 4, 9) PutStr("Files")
        VGotoXY( 4,10) PutStr("Total file size")
        VGotoXY(26, 2) Write(GetFileMask():10)
        VGotoXY(26, 4) Write(dirs:10)
        VGotoXY(26, 6) Write(tags:10)
        VGotoXY(26, 7) Write(tagged:10)
        VGotoXY(26, 9) Write(NumLines()-dirs:10)
        VGotoXY(26,10) Write(total:10)
        Set(Cursor,OFF)
        GetKey()
        Set(Key,0)
        PopWinClose()
    endif
end

/****************************************************************************\
  ú Low level file functions

    þ IsDir             determine if current file is a directory
    þ ThisFile          return current filename
\****************************************************************************/

integer proc IsDir()
    return (CurrChar(2) == TC_DIR)
end

integer proc ThisFile( var string name )

    // extract and format name

    if lFind("^..{[~ ]+} +{[~ ]*} *"+Chr(TC_NOTAG),"cgx")
        MarkFoundText(1)
        name = GetMarkedText()
        MarkFoundText(2)
        if isBlockInCurrFile()
            name = name + "." + GetMarkedText()
        endif
        UnmarkBlock()
    else
        name = ""
    endif

    // verify existence of file

    if Length(name) and FileExists(name)
        return (TRUE)
    endif
    MsgBox("File '"+name+"' does not exist",MB_ERRBOX)
    name = ""
    return (FALSE)
end

/****************************************************************************\
  ú High level file functions

    þ TF_FindFile       searches files by name and contents
        ù IN    switch      find options (passed on to TF_ExecFind)
        ù USE   source      directory name for changing dirs
    þ TF_BrowseThis     browse a file or display a new directory
        ù IN    switch      hex display (passed on to TF_BrowseFile)
    þ TF_LaunchThis     execute file of associated application
    þ TF_TseComp        load and execute TSEComp
\****************************************************************************/

public proc TF_FindFile()
    case Call("ExecFind")
        when FF_LIST    ListFiles(LF_THIS,"")
        when FF_CHDIR   ListFiles(LF_THIS,GetGlobalStr(source))
    endcase
end

public proc TF_BrowseThis()
    string ext[4]
    string name[32] = ""

    if ThisFile(name)
        ext = SplitPath(name,_EXT_)
        if IsDir()
            ListFiles(LF_THIS,name)
        elseif GetGlobalInt(switch)
            CallSrc("BrowseFile",ExpandPath(name))
        elseif ext == ".mac"
            macro = ExpandPath(name)
            CallInt("Terminate",TRUE)
        elseif Length(ext) == 4 and Pos(ext,".btm.bat.com.exe")
            Dos(name)
        elseif CallSrcInt("Launch",name,FALSE)
            CallSrcInt("BrowseFile",ExpandPath(name),BF_TEXT)
        endif
    endif
end

public proc TF_LaunchThis()
    string name[32] = ""

    if ThisFile(name)
        if IsDir()
            MsgBox("Cannot launch directories",MB_ERRBOX)
        else
            CallSrcInt("Launch",name,TRUE)
        endif
    endif
end

public proc TF_TseComp()
    integer rc
    integer id = WindowId()
    integer zoomed = isZoomed()
    string name[32] = ""

    if ThisFile(name)
        if IsDir()
            MsgBox("Cannot compare directories",MB_ERRBOX)
            return()
        else
            PushKey(<Escape>)
            rc = LoadMacro("TSEComp")
            if KeyPressed() GetKey() endif
            if rc
                SetGlobalStr(target,name)
                ExecMacro("TC_SetFirstName")
                ExecMacro("TSEComp")
                PurgeMacro("TSEComp")
                rc = GetGlobalInt(switch)
            else
                MsgBox("Cannot load TSEComp",MB_ERRBOX)
                rc = 0
            endif
        endif
    endif

    SplitScreen(id)
    if zoomed
        ZoomWindow()
    endif
    if rc
        file = rc
        SetGlobalInt(quitmsg,FALSE)
        CallInt("Terminate",TRUE)
    endif
end

/****************************************************************************\
  ú File management commands

    þ LoadFile          edit chosen files
    þ CompFile          compares files
    þ DelFile           delete files
    þ RenFile           rename files
    þ CopyMove          duplicate, copy or move files
\****************************************************************************/

proc LoadFile( string name )
    integer id

    id = GetBufferId()
    if IsDir()
        MsgBox("Cannot edit directories",MB_ERRBOX)
    else
        if FileExists(name)
            file = EditFile(name)
            GotoBufferId(id)
        else
            MsgBox("File does not exist",MB_ERRBOX)
        endif
    endif
end

proc CompFile( string name )
    if IsDir()
        CallSrcTgt("CompDir",name,other+name)
    else
        if FileExists(name)
            CallSrcTgt("CompDiskFile",name,other)
        else
            MsgBox("File does not exist",MB_ERRBOX)
        endif
    endif
end

proc DelFile( string name )
    if IsDir()
        if not DontDestroy(WARN_TREE,"Remove directory "+name+" ?")
            if not CallSrc("DelDir",name)
                PutDesc("",name)
            endif
        endif
    else
        if EraseDiskFile(name)
            PutDesc("",name)
        else
            MsgBox("Could not erase file: "+name,MB_ERRBOX)
        endif
    endif
end

proc RenFile( string name )
    string  newname[80] = name

    if AskText("Enter target filename:",newname,IB_FILE)
        if RenameDiskFile(name,newname)
            if IsDir()
                CallSrcTgt("RenDir",name,newname)
            endif
            DupDesc(name,newname)
            PutDesc("",name)
        else
            MsgBox("Could not rename file: "+name,MB_ERRBOX)
        endif
    endif
end

proc CopyMove( string name, integer action )
    integer attr
    string path[80]
    string newname[128] = name

    // determine target filename

    if action == FM_DUP
        if IsDir()
            MsgBox("Cannot duplicate trees",MB_ERRBOX)
            return ()
        endif
        if AskText("Enter target filename:",newname,IB_FILE)
            path = SplitPath(ExpandPath(newname),_DRIVE_|_PATH_)
            if (FileExists(path) & _DIRECTORY_) == 0
                MsgBox("Target directory does not exist",MB_ERRBOX)
                return ()
            endif
        else
            return ()
        endif
    else
        if GetDir() == other
            MsgBox("Cannot copy or move files to themselfs",MB_ERRBOX)
            return ()
        endif
        newname = other + name
    endif

    // check for an existing target

    attr = FileExists(newname)
    if attr & _DIRECTORY_
        MsgBox("Cannot overwrite directories",MB_ERRBOX)
        return ()
    endif
    if attr and DontDestroy(WARN_OVER,
    "Overwrite file "+SplitPath(newname,_NAME_|_EXT_)+" ?")
        return ()
    endif

    // copy/move directories or files

    if IsDir()
        if action == FM_MOVE
            if DontDestroy(WARN_TREE,"Move directory "+name+" ?")
                return ()
            else
                if CallSrcTgt("MoveDir",name,newname)
                    return()
                endif
            endif
        else
            if CallSrcTgt("CopyDir",name,newname)
                return()
            endif
        endif
    else
        if action == FM_MOVE
            if not RenameDiskFile(name,newname)
                if CallSrcTgt("CopyDiskFile",name,newname)
                    if not EraseDiskFile(name)
                        MsgBox("Could not erase file: "+name,MB_ERRBOX)
                        return ()
                    endif
                else
                    MsgBox("Could not move file: "+name,MB_ERRBOX)
                    return ()
                endif
            endif
        else
            if not CallSrcTgt("CopyDiskFile",name,newname)
                MsgBox("Could not copy file: "+name,MB_ERRBOX)
                return ()
            endif
        endif
    endif

    // handle file descriptions

    DupDesc(name,newname)
    if action == FM_MOVE
        PutDesc("",name)
    endif
end

/****************************************************************************\
  ú File iterator

    þ ForFile           execute action for current file
    þ TF_ForAll         iterate over marked files
        ù IN    switch      file iterator action
:       ù GUSE  msg_key     MsgBox return code
\****************************************************************************/

integer proc ForFile( integer action )
    string name[32] = ""

    if ThisFile(name)
        if name == ".."
            MsgBox("Cannot handle the parent directory",MB_ERRBOX)
        else
            MsgBox(name,MB_SHOW)
            PushPosition()
            case action
                when FM_EDIT    LoadFile(name)
                when FM_MOVE    CopyMove(name,FM_MOVE)
                when FM_COPY    CopyMove(name,FM_COPY)
                when FM_DUP     CopyMove(name,FM_DUP)
                when FM_REN     RenFile(name)
                when FM_DEL     DelFile(name)
                when FM_COMP    CompFile(name)
            endcase
            PopPosition()
        endif
        return (TRUE)
    endif
    return (FALSE)
end

public proc TF_ForAll()
    integer quit, multi, rc
    integer action = GetGlobalInt(switch)

    // verify other directory

    if (FileExists(other) & _DIRECTORY_) == 0
        MsgBox("Inactive directory does not exist",MB_ERRBOX)
        return ()
    endif

    // determine first mark and confirm deletions

    PushPosition()
    multi = lFind(Chr(TC_TAG),"^g")

    if (action & FM_DEL)
    and (multi or not IsDir())
    and DontDestroy(WARN_DEL,"Delete file(s) ?")
        PopPosition()
        return ()
    endif

    // prepare

    quit = action & FM_QUIT
    action = action & ~FM_QUIT
    HideMouse()
    MsgBox("",MB_OPEN|MB_FILE)

    // iterate over marks or use current file

    if multi
        rc = FALSE
        msg_key = 0
        repeat
            rc = ForFile(action) or rc
            if KeyPressed() and GetKey() == <Escape>
                if MsgBox("Cancel operation ?",MB_INPBOX) == <Enter>
                    break
                endif
            endif
        until not lFind(Chr(TC_TAG),"^+") or msg_key == <Ctrl C>
    else
        rc = ForFile(action)
    endif

    // update windows

    PopPosition()
    if rc
        if action & FM_OTHER
            ListFiles(LF_BOTH,"")
        elseif action & FM_THIS
            ListFiles(LF_THIS,"")
        endif
    endif

    // clean up

    MsgBox("",MB_CLOSE)
    ShowMouse()
    if CurrLine() > NumLines()
        GotoLine(NumLines())
    endif
    if action & FM_COMP
        Call("ShowCompResult")
    elseif quit
        CallInt("Terminate",TRUE)
    endif
end

/****************************************************************************\
  ú Basic command processing

    þ TF_Terminate      program termination routine
        ù IN    switch      dir restore flag overwrite
        ù SIN   quitmsg     prompt on quit
        ù SIO   restore     dir restore flag
    þ TF_ExecChain      set command chain
        ù IN    source      chained commands
        ù GOUT  chain       dito
    þ ExecChain         execute all chained commands
        ù IN    source      name of launched file
        ù GIN   chain       chained commands
    þ SpeedSearch       search first character of filename
    þ CommandHook       activate ExecChain or SpeedSearch
\****************************************************************************/

public proc TF_Terminate()
    integer rc = GetGlobalInt(switch)

    if not GetGlobalInt(quitmsg)
    or MsgBox("Close file manager?",MB_INPBOX) == <Enter>
        EndProcess()
        rc = rc and GetGlobalInt(restore)
        SetGlobalInt(restore,rc)
    else
        macro = ""
    endif
end

public proc TF_ExecChain()
    chain = chain + GetGlobalStr(source)
end

proc ExecChain()
    while Length(chain)
        UpdateScreen()
        case chain[1]
            when "L"    ListFiles(LF_BOTH,"")
            when "S"    SortBothLists()
            when "M"    TagMask()
            when "T"    CallInt("TreeCmd",TC_NEW)
            when "X"    CallSrcInt("Launch",GetGlobalStr(target),TRUE)
        endcase
        chain = SubStr(chain,2,255)
    endwhile
end

proc SpeedSearch( integer ascii )
    string char[1] = Chr(ascii)
    string back[1] = ""

    if Asc("A") <= ascii and ascii <= Asc("Z")
        char = Lower(char)
        back = "b"
    endif
    MarkColumn(1,3,NumLines(),3)
    if lFind(char,"l+"+back) or lFind(char,"lg"+back)
        ScrollToRow(10)
    else
        Alarm()
    endif
    UnmarkBlock()
end

proc CommandHook()
    integer scan, ascii

    scan = Query(key) shr 8
    ascii = Query(key) & 0xFF
    if 0x00 < scan and scan < 0x37 and 0x20 < ascii and ascii < 0xF0
        SpeedSearch(ascii)
    else
        ExecChain()                     // comment
    endif                               // ScanCodeOf(Grey*) == 0x37
    UpdateScreen()
    BreakHookChain()
end

/****************************************************************************\
  ú Mouse functions

    þ MouseDragging     left button dragging, copy/move files
    þ LeftButton        left button click, hotspots and toggle marks
    þ ShiftButton       shift left button, extend markings
    þ RightButton       right button click, browse files
\****************************************************************************/

proc MouseDragging( integer action, integer shifted )
    string  msg[15]
    integer open = FALSE
    integer untag = TRUE
    integer startX, oldX, X, startY, oldY, Y

    GotoMouseCursor()
    if shifted or CurrChar(1) <> TC_TAG
        TagExtend(TM_ON)
        UpdateDisplay()
        untag = FALSE
    endif
    if action == FM_MOVE
        msg = "move "
    else
        msg = "copy "
    endif
    msg = msg + Str(CountItems(1,TC_TAG))

    oldX = Query(MouseX)
    oldY = Query(MouseY)
    startX = oldX
    startY = oldY

    while MouseKeyHeld()
        X = Query(MouseX)
        Y = Query(MouseY)
        if X <> oldX or Y <> oldY
            oldX = X
            oldY = Y
            if open
                open = FALSE
                PopWinClose()
            endif
            if startX < 41 and X > 41
            or startX > 41 and X < 41
                open = TRUE
                if X > 79-Length(msg)  X = 79-Length(msg)  endif
                if Y > 23  Y = 23  endif
                PopWinOpen(X,Y,X+Length(msg)+1,Y+2,1,"",CC_PROMPT)
                Set(Attr,CC_PROMPT)
                GotoXY(1,1)
                PutStr(msg)
            endif
        endif
    endwhile

    if open
        PopWinClose()
        CallInt("ForAll",action)
    elseif untag and startX == X and startY == Y
        TagExtend(TM_OFF)
    endif
end

proc LeftButton( integer action )
    if MouseHotSpot() == _NONE_
        Call("Menu")
    else
        if WindowId() == MouseWindowId()
            case MouseHotSpot()
                when _MOUSE_MARKING_
                    MouseDragging(action,FALSE)
                when _MOUSE_CLOSE_
                    CallInt("Terminate",TRUE)
                when _MOUSE_ZOOM_, _MOUSE_UP_, _MOUSE_DOWN_,
                     _MOUSE_PAGEUP_, _MOUSE_PAGEDOWN_, _MOUSE_VELEVATOR_
                    ProcessHotSpot()
            endcase
        else
            SwitchWindow()
        endif
    endif
end

proc ShiftButton( integer action )
    if MouseHotSpot() == _MOUSE_MARKING_
        if WindowId() == MouseWindowId()
            GotoMouseCursor()
            TagExtend(TM_EXTEND)
            MouseDragging(action,TRUE)
        else
            SwitchWindow()
        endif
    endif
end

proc RightButton()
    if MouseHotSpot() == _MOUSE_MARKING_
        if WindowId() == MouseWindowId()
            GotoMouseCursor()
            UpdateDisplay()
            CallInt("BrowseThis",BF_DEFAULT)
        else
            SwitchWindow()
        endif
    endif
end

/****************************************************************************\
  ú Keyboard functions

    þ PullDownMenu      hot key for pull down menus
\****************************************************************************/

proc PullDownMenu( integer key )
    PushKey(key)
    Call("Menu")
end

/****************************************************************************\
  ú Additional menu functions

    þ TF_DosShell       execute a shell
\****************************************************************************/

public proc TF_DosShell()
    TF_SaveDesc()
    Shell()
    ListFiles(LF_BOTH,"")
end

/****************************************************************************\
  ú Key assignment

    þ TSEFileKeys       keyboard definitions
\****************************************************************************/

keydef TSEFileKeys

    <HelpLine>          "{Enter}-Browse {F2}-Desc {F3}-Load {F5}-Refresh {F6}-ChDir {F7}-Ren {F8}-Dup {F9}-Tree {F12}-Zoom"
    <Alt HelpLine>      "{F}-File {D}-Directory {I}-Describe {M}-Mark {O}-Options {H}-Help"
    <Ctrl HelpLine>     "{Enter}-Launch {C}-CopyTo {M}-MoveTo {O}-Compare {F}-First {L}-Last {N}-Next {P}-Prev"
    <Shift HelpLine>    "{Enter}-BrowseHex {F2}-AskDesc {F3}-LoadAndQuit {F6}-ChDrv {F9}-GlobalTree {Esc}-QuitToCurr"

    // windows

    <Tab>               SwitchWindow()
    <Shift F12>         SwitchWindow()
    <F12>               ZoomWindow()

    // movement

    <Home>              BegFile()
    <End>               EndFile() BegLine()
    <PgUp>              PageUp()
    <PgDn>              PageDown()
    <CursorUp>          Up()
    <CursorDown>        Down()
    <Ctrl R>            RepeatFind()

    // marking

    <Ctrl F>            GotoTag("lg")
    <Ctrl L>            GotoTag("lgb")
    <Ctrl N>            GotoTag("l+")
    <Ctrl P>            GotoTag("lb")
    <Grey->             TagExtend(TM_OFF)    Down()
    <Grey+>             TagExtend(TM_ON)     Down()
    <Spacebar>          TagExtend(TM_TOGGLE) Down()
    <Grey/>             CallSrcInt("TagFiles",TC_ALL,TM_OFF)
    <Grey*>             CallSrcInt("TagFiles",TC_ALL,TM_ON)
    <GreyEnter>         CallSrcInt("TagFiles",TC_ALL,TM_TOGGLE)

    // descriptions

    <Alt BackSpace>     Call("UndoDesc")
    <Ctrl Del>          CallInt("DelPasteDesc",TRUE)
    <Shift Del>         CallInt("CutCopyDesc",TRUE)
    <Ctrl Ins>          CallInt("CutCopyDesc",FALSE)
    <Shift Ins>         CallInt("DelPasteDesc",FALSE)
    <F2>                CallInt("EditDesc",TRUE)
    <Shift F2>          CallInt("EditDesc",FALSE)

    // files

    <F4>                Call("TseComp")
    <F7>                CallInt("ForAll",FM_REN)
    <F8>                CallInt("ForAll",FM_DUP)
    <Del>               CallInt("ForAll",FM_DEL)
    <Ctrl C>            CallInt("ForAll",FM_COPY)
    <Ctrl M>            CallInt("ForAll",FM_MOVE)
    <Ctrl O>            CallInt("ForAll",FM_COMP)

    // directories

    <Ins>               TF_CreateDir()
    <F5>                TF_Refresh()
    <F6>                TF_ChangeDir()
    <Shift F6>          TF_ChangeDrv()
    <F9>                CallInt("TreeCmd",TC_SUB)
    <Shift F9>          CallInt("TreeCmd",TC_TREE)

    // miscellaneous

    <F1>                Call("MainHelp")
    <F3>                CallInt("ForAll",FM_EDIT)
    <Shift F3>          CallInt("ForAll",FM_EDIT|FM_QUIT)
    <Enter>             CallInt("BrowseThis",BF_DEFAULT)
    <Shift Enter>       CallInt("BrowseThis",BF_HEX)
    <Ctrl Enter>        Call("LaunchThis")
    <Escape>            CallInt("Terminate",TRUE)
    <Shift Escape>      CallInt("Terminate",FALSE)

    // menus

    <Alt F>             PullDownMenu(Asc("f"))
    <Alt D>             PullDownMenu(Asc("d"))
    <Alt I>             PullDownMenu(Asc("i"))
    <Alt M>             PullDownMenu(Asc("m"))
    <Alt O>             PullDownMenu(Asc("o"))
    <Alt H>             PullDownMenu(Asc("h"))
    <F10>               Call("Menu")

    // mouse

    <LeftBtn>           LeftButton(FM_MOVE)
    <Ctrl LeftBtn>      LeftButton(FM_COPY)
    <Shift LeftBtn>     ShiftButton(FM_MOVE)
    <59489>             ShiftButton(FM_COPY)    // <CtrlShift LeftBtn>
    <RightBtn>          RightButton()

end

/****************************************************************************\
  ú Entry code

    þ LoadLib           load run time libraries
    þ Enter             set up screen, buffers, etc.
        ù USE   target
        ù SUSE  inisave
        ù GOUT  ******      buffer id's
                ******      editor configuration variables
                start       startup directory
                other       other (inactive) directory
\****************************************************************************/

integer proc LoadLib( string name )
    integer rc

    PushKey(<Escape>)
    rc = not ( LoadMacro(name) and isMacroLoaded(name) )
    if KeyPressed() GetKey() endif
    if rc
        Warn("Cannot load library " + name)
    endif
    return (rc)
end

integer proc Enter()

    // save editor state and create working buffers

    PushBlock()
    file = GetBufferId()
    buff = CreateBuffer("",_HIDDEN_)
    ldir = CreateBuffer("",_HIDDEN_)
    rdir = CreateBuffer("",_HIDDEN_)
    ldsc = CreateBuffer("",_HIDDEN_)
    rdsc = CreateBuffer("",_HIDDEN_)
    tdsc = CreateBuffer("",_HIDDEN_)
    if not (buff and ldir and rdir and ldsc and rdsc and tdsc)
        Alarm()
        Warn("Cannot create buffers")
        return (FALSE)
    endif

    // load and init run-time libraries

    SetGlobalStr(target,target)
    if LoadLib("TSEFile1") or LoadLib("TSEFile2")
        return (FALSE)
    endif
    h_desc = CallInt("GetHist",IB_DESC)

    // change environment

    fmExpandTabs = Set(ExpandTabs,OFF)
    fmTabWidth = Set(TabWidth,8)
    fmTabType = Set(TabType,_HARD_)
    fmCurrVideoMode = Query(CurrVideoMode)
    fmShowEOFMarker = Set(ShowEOFMarker,OFF)
    fmTextAttr = Set(TextAttr,CC_TEXT)
    fmCursorAttr = Set(CursorAttr,CC_CURSOR)
    fmCurrWinBorderAttr = Set(CurrWinBorderAttr,CC_CURR)
    fmOtherWinBorderAttr = Set(OtherWinBorderAttr,CC_TEXT)
    fmMenuTextAttr = Set(MenuTextAttr,CC_MENU)
    fmMenuTextLtrAttr = Set(MenuTextLtrAttr,CC_HOTKEY)
    fmMenuSelectAttr = Set(MenuSelectAttr,CC_SELECT)
    fmMenuSelectLtrAttr = Set(MenuSelectLtrAttr,CC_SELKEY)
    fmMenuBorderAttr = Set(MenuBorderAttr,CC_MENU)

    // get saved options

    Call("ReadConfig")

    // save changed files

    if GetGlobalInt(inisave)
        MsgBox("Saving changed files",MB_OPEN|MB_LOAD)
        SaveAllFiles()
        MsgBox("",MB_CLOSE)
    endif

    // list files of current directory

    SplitScreen(1)
    start = GetDir()
    other = start
    ListFiles(LF_BOTH,"")
    UpdateScreen()
    return (TRUE)
end

/****************************************************************************\
  ú Exit code

    þ Leave             shut down screen, buffer, etc.
        ù OUT   switch      reset
                source      reset
                target      reset
        ù SIN   restore
        ù GIN   ******      buffer id's
                ******      editor configuration variables
                start       startup directory

    at exit all session global variables are cleared
\****************************************************************************/

proc Leave( integer started )
    if started

        // save descriptions and restore current directory

        TF_SaveDesc()
        if GetGlobalInt(restore)
            if ChDir(start)
                LogDrive(start[1])
            else
                MsgBox("Startup directory not found",MB_ERRBOX)
            endif
        endif

        // save options

        CallInt("SaveConfig",FALSE)

        // restore environment

        Set(ExpandTabs,fmExpandTabs)
        Set(TabWidth,fmTabWidth)
        Set(TabType,fmTabType)
        Set(CurrVideoMode,fmCurrVideoMode)
        Set(ShowEOFMarker,fmShowEOFMarker)
        Set(TextAttr,fmTextAttr)
        Set(CursorAttr,fmCursorAttr)
        Set(CurrWinBorderAttr,fmCurrWinBorderAttr)
        Set(OtherWinBorderAttr,fmOtherWinBorderAttr)
        Set(MenuTextAttr,fmMenuTextAttr)
        Set(MenuTextLtrAttr,fmMenuTextLtrAttr)
        Set(MenuSelectAttr,fmMenuSelectAttr)
        Set(MenuSelectLtrAttr,fmMenuSelectLtrAttr)
        Set(MenuBorderAttr,fmMenuBorderAttr)
    endif

    // unload run-time libraries

    PurgeMacro("TSEFile1")
    PurgeMacro("TSEFile2")

    // clear all session global variables

    SetGlobalInt(switch,0)
    SetGlobalStr(target,"")
    SetGlobalStr(source,"")

    SetGlobalStr(lmask,"")
    SetGlobalStr(rmask,"")
    SetGlobalInt(sfield,0)
    SetGlobalInt(sorder,0)
    SetGlobalInt(quitmsg,0)
    SetGlobalInt(inisave,0)
    SetGlobalInt(describe,0)
    SetGlobalInt(savedsc,0)
    SetGlobalInt(confirm,0)
    SetGlobalInt(restore,0)
    SetGlobalInt(autosave,0)
    SetGlobalStr(drives,"")
    SetGlobalStr(device,"")
    SetGlobalStr(prtini,"")

    // remove buffers and restore editor state

    GotoBufferId(file)
    PopBlock()
    AbandonFile(buff)
    AbandonFile(ldir)
    AbandonFile(rdir)
    AbandonFile(ldsc)
    AbandonFile(rdsc)
    AbandonFile(tdsc)

    // set screen back to normal

    Set(StatusLineUpdating,ON)
    Set(Cursor,ON)
    OneWindow()
    UpdateDisplay()
    UpdateDisplay(_STATUSLINE_REFRESH_)
end

/****************************************************************************\
  ú Main programm

    þ main
        ù GUSE  macro       name of launched macro
\****************************************************************************/

proc main()
    integer RC

//  Set(Break,ON)                       // debugging only

    // prepare and run file manager

    Message(banner)
    RC = Enter()
    if RC and Enable(TSEFileKeys,_EXCLUSIVE_)
        Hook(_AFTER_COMMAND_,CommandHook)
        Process()
        UnHook(CommandHook)
        Disable(TSEFileKeys)
    endif
    Leave(RC)

    // check for and execute launched macro

    if Length(macro)
        if SplitPath(macro,_NAME_|_EXT_)
        == SplitPath(CurrMacroFilename(),_NAME_|_EXT_)
            Alarm()
            Warn("Cannot start file manager recursively")
        else
            ExecMacro(macro)
        endif
    endif

    // purge self

    PurgeMacro(CurrMacroFilename())
end

