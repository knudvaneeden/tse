/****************************************************************************\

    ToDo.S

    Manages todo items.

    Overview:

    This macro is TSE's todo manager. It can list, insert and edit
    todo items. These items are stored within the file using tagged
    comments.

    Keys:   (none)

    Usage notes:

    This macro is bound to TSE's user interface.

    Version         v2.00/28.04.05
    Copyright       (c) 2001-2005 by DiK

    History
    v2.00/28.04.05  added interface to windlgs (detects windlgs)
                    uses new synhi interface (v4.2 and later only)
                    fixed writing config file
    v1.20/03.02.04  uses new language macro interface
    v1.10/14.10.03  fixed handling empty text
                    fixed non-language todo
                    added list menu
                    added configuration file
    v1.01/08.05.03  fixed key assignments
    v1.00/15.05.01  first version

\****************************************************************************/

#define USE_DIKUI 1

/****************************************************************************\
    user definable keys
\****************************************************************************/

constant ListTodo = <Shift F2>
constant EditTodo = <CtrlShift T>

/****************************************************************************\
    todo list command IDs
\****************************************************************************/

constant TODO_ESCAPE = 0
constant TODO_GOTO   = 1
constant TODO_CANCEL = 2
constant TODO_HELP   = 9
constant TODO_UPDATE = 101
constant TODO_EDIT   = 102
constant TODO_DONE   = 103
constant TODO_TODO   = 104
constant TODO_REMOVE = 105
constant TODO_SORT1  = 111
constant TODO_SORT2  = 112
constant TODO_SORT3  = 113
constant TODO_SORT4  = 114
constant TODO_SORT5  = 115
constant TODO_SETUP  = 121

/****************************************************************************\
    global constants
\****************************************************************************/

string CONF_MAGIC[] = "*Todo Configuration Data*"

string DEF_PRIOR[2]     = "1"           // default priority
string DEF_OWNER[16]    = ""            // default owner
string DEF_CATEG[16]    = "bug"         // default category

string DEF_CMT[8]   = "#"               // line comment used for unknown extensions

string CHR_SWITCH[] = "-"               // switch character for tokens
string CHR_COLON[]  = ":"               // character to start text field

string TOC_TODO[]   = "TODO"            // marks a comment as todo item
string TOC_DONE[]   = "DONE"            // ditto, finished todo
string TOC_OWNER[]  = " -o"             // owner tag, must use CHR_SWITCH
string TOC_CATEG[]  = " -c"             // category tag, ditto
string TOC_TEXT[]   = " :"              // start of text field, must use CHR_COLON

/****************************************************************************\
    global variables
\****************************************************************************/

integer buff_list                       // buffer id: todo list
integer buff_todo                       // ditto: to edit text field
integer buff_user                       // ditto: user file

string CmtBeg[8]                        // start of comment
string CmtEnd[8]                        // end of comment
string CmtExpr[48]                      // start of comment as reg. expr.

integer LineNum                         // fields of current item
integer Completed
string Priority[2]
string Owner[16]
string Category[16]
string TodoText[240]                    // start of first line only

/****************************************************************************\
    help screen
\****************************************************************************/

helpdef ListHelp
    title = "Help on Todo List"
    height = 22
    width = 70
    x = 2
    y = 3

    ""
    "To insert a new item, close the list and press Ctrl-Shift-T."
    "If the cursor is inside an item, it will be edited instead."
    ""
    "Enter          close list and go to the current item"
    "Escape         close list and return to previous position"
    ""
    "F2             edit the current item"
    "F5             display the current item without closing the list"
    ""
    "Alt-D          mark the item as DONE"
    "Alt-T          mark the item as still TODO"
    "Alt-R          completely remove the current item"
    ""
    "Alt-L          sort list by line number"
    "Alt-P          sort list by priority"
    "Alt-O          sort list by owner"
    "Alt-C          sort list by category"
    "Alt-I          sort list by item"
    ""
    "Alt-S          change default settings"
    ""
end

/****************************************************************************\
    helper routines
\****************************************************************************/

proc Error(string msg)
    MsgBox("Todo", msg)
end

proc GetField(var string field)
    string old_field[32] = field

    loop
        if Read(field)
            if Pos(CHR_SWITCH, field) > 0 or Pos(CHR_COLON, field) > 0
                Error("Field contains invalid characters")
                field = old_field
            else
                return()
            endif
        else
            return()
        endif
    endloop
end

/****************************************************************************\
    manage configuration data
\****************************************************************************/

string proc GetConfigName()
    return( SplitPath(LoadDir(),_DRIVE_|_PATH_) + "todo.dat" )
end

string proc ReadLine()
    string result[128] = GetText(1,CurrLineLen())
    Down()
    return(result)
end

proc ReadConfig()
    string magic[32]

    if EditFile(GetConfigName())
        magic = ReadLine()
        if magic == CONF_MAGIC
            DEF_CMT = ReadLine()
            DEF_PRIOR = ReadLine()
            DEF_OWNER = ReadLine()
            DEF_CATEG = ReadLine()
        endif
        AbandonFile()
    endif
end

proc WriteConfig()
    if EditFile(GetConfigName())
        EmptyBuffer()
        AddLine(CONF_MAGIC)
        AddLine(DEF_CMT)
        AddLine(DEF_PRIOR)
        AddLine(DEF_OWNER)
        AddLine(DEF_CATEG)
        SaveFile()
        AbandonFile()
    endif
end

menu ConfigMenu()
    title = "Setup Todo Defaults"
    x = 2
    y = 3

    "Co&mment"  [DEF_CMT  : 8],  GetField(DEF_CMT),         DONTCLOSE
    "",,    DIVIDE
    "&Priority" [DEF_PRIOR: 2],  GetField(DEF_PRIOR),       DONTCLOSE
    "&Owner"    [DEF_OWNER:16],  GetField(DEF_OWNER),       DONTCLOSE
    "&Category" [DEF_CATEG:16],  GetField(DEF_CATEG),       DONTCLOSE
end

proc SetupDefaults()
    string cmd[128]

    if isMacroLoaded("windlgs")
        cmd = Format(DEF_CMT, Chr(9), DEF_PRIOR, Chr(9), DEF_OWNER, Chr(9), DEF_CATEG)
        ExecMacro("dlgtodosetup " + cmd)
        cmd = Query(MacroCmdLine)
        DEF_CMT = GetToken(cmd, Chr(9), 1)
        DEF_PRIOR = GetToken(cmd, Chr(9), 2)
        DEF_OWNER = GetToken(cmd, Chr(9), 3)
        DEF_CATEG = GetToken(cmd, Chr(9), 4)
    else
        ConfigMenu()
    endif
end

/****************************************************************************\
    finding todo items
\****************************************************************************/

integer proc FindEndOfItem()
    integer rc = TRUE

    if CmtEnd == ""
        EndLine()
    elseif lFind(CmtEnd, "")
        Right(Length(CmtEnd))
    else
        rc = FALSE
    endif
    if rc and CurrChar() < 0
        NextChar()
    endif
    return(rc)
end

integer proc FindBeginOfItem()
    integer rc
    integer first_line = 0
    integer last_line = 0

    if lFind(CmtExpr, "cgx")
        return(TRUE)
    endif

    PushPosition()
    if lFind(CmtExpr, "xb")
        first_line = CurrLine()
        if FindEndOfItem()
            last_line = CurrLine()
        endif
    endif
    PopPosition()

    rc = first_line < CurrLine() and CurrLine() <= last_line
    if rc
        GotoLine(first_line)
        BegLine()
    endif
    return(rc)
end

/****************************************************************************\
    inserting and parsing todo items
\****************************************************************************/

proc InsertTodoItem()
    integer bid, umap

    BegLine()
    InsertLine()
    InsertText(CmtBeg)
    InsertText(" ")
    InsertText(TOC_TODO)
    InsertText(" ")
    InsertText(Priority)
    InsertText(TOC_OWNER)
    InsertText(Owner)
    InsertText(TOC_CATEG)
    InsertText(Category)
    InsertText(TOC_TEXT)
    InsertText(" ")

    bid = GotoBufferId(buff_todo)
    BegFile()
    MarkChar()
    EndFile()
    MarkChar()
    GotoBufferId(bid)
    if isBlockMarked()
        umap = Set(UnMarkAfterPaste, OFF)
        CopyBlock()
        GotoBlockEnd()
        Set(UnMarkAfterPaste, umap)
        UnMarkBlock()
    endif

    InsertText(" ")
    InsertText(CmtEnd)
    BegLine()
end

integer proc ParseTodoItem()
    integer bid

    Completed = FALSE
    Priority = DEF_PRIOR
    Owner = DEF_OWNER
    Category = DEF_CATEG
    TodoText = ""
    EmptyBuffer(buff_todo)

    if not FindBeginOfItem()
        return(FALSE)
    endif

    if lFind(CmtExpr + "{[0-9]#}", "cgx")
        LineNum = CurrLine()
        Completed = GetFoundText(2) == TOC_DONE
        Priority = GetFoundText(3)
    else
        return(FALSE)
    endif

    if lFind(TOC_OWNER + "{.*}" + TOC_CATEG, "cgx")
        Owner = GetFoundText(1)
    endif

    if lFind(TOC_CATEG + "{.*}" + TOC_TEXT, "cgx")
        Category = GetFoundText(1)
    endif

    if lFind(TOC_TEXT + " @\c", "cgx")
        UnMarkBlock()
        MarkChar()
        if FindEndOfItem()
            lFind(CmtEnd, "b")
            bid = GotoBufferId(buff_todo)
            if isBlockMarked()
                CopyBlock()
            else
                EmptyBuffer()
            endif
            ClearUndoRedoList()
            MarkLine(1,1)
            TodoText = GetMarkedText()
            GotoBufferId(bid)
        endif
        UnMarkBlock()
    endif

    return(TRUE)
end

/****************************************************************************\
    edit todo text (with kudos to potpouri)
\****************************************************************************/

proc mDelChar()
    if CurrChar() >= 0
        DelChar()
    else
        JoinLine()
    endif
end

proc mBackSpace()
    if not BackSpace() and PrevChar()
        JoinLine()
    endif
end

proc mCReturn()
    if CmtEnd == ""
        Error("Cannot use multi-line text with single-line comments")
        return()
    endif
    CReturn()
end

proc mProcessMouse()
    case MouseHotSpot()
        when _MOUSE_MARKING_,_MOUSE_VWINDOW_,_MOUSE_HWINDOW_,_MOUSE_VRESIZE_,_MOUSE_HRESIZE_
            // nop
        when _MOUSE_CLOSE_,_NONE_
            EndProcess()
        otherwise
            ProcessHotSpot()
    endcase
end

keydef EditKeys
    <CursorUp>              Up()
    <CursorDown>            Down()
    <CursorLeft>            Left()
    <CursorRight>           Right()
    <Ctrl CursorLeft>       WordLeft()
    <Ctrl CursorRight>      WordRight()
    <Home>                  BegLine()
    <End>                   EndLine()
    <PgUp>                  PageUp()
    <PgDn>                  PageDown()
    <Ctrl Home>             BegFile()
    <Ctrl End>              EndFile()
    <Ctrl PgUp>             BegFile()
    <Ctrl PgDn>             EndFile()
    <Enter>                 mCReturn()
    <Ins>                   Toggle(Insert)
    <Del>                   mDelChar()
    <BackSpace>             mBackSpace()
    <Tab>                   TabRight()
    <Shift Tab>             TabLeft()
    <Ctrl BackSpace>        DelLeftWord()
    <Ctrl T>                DelRightWord()
    <Ctrl Y>                DelLine()
    <Ctrl Z>                Undo()
    <CtrlShift Z>           Redo()
    <Alt BackSpace>         Undo()
    <AltShift BackSpace>    Redo()
    <LeftBtn>               mProcessMouse()
    <RightBtn>              EndProcess()
    <Escape>                EndProcess()
end

proc EditHook()
    UnHook(EditHook)
    Set(Cursor, ON)
    Enable(EditKeys, _EXCLUSIVE_|_TYPEABLES_)
    Process()
    EndProcess()
    BreakHookChain()
end

proc EditTodoText()
    integer bid, msa

    bid = GotoBufferId(buff_todo)
    BegFile()

    msa = Set(MenuSelectAttr, Query(MenuTextAttr))
    Set(X1, Query(PopWinX1))
    Set(Y1, Query(PopWinY1))
    Hook(_LIST_STARTUP_, EditHook)
    lList("Editing Todo Text", 40, 10, _ENABLE_HSCROLL_|_FIXED_HEIGHT_)
    Set(Cursor, OFF)
    Set(MenuSelectAttr, msa)

    BegFile()
    TodoText = GetText(1,32)
    GotoBufferId(bid)
end

/****************************************************************************\
    edit todo item
\****************************************************************************/

integer hist = 4

menu EditMenu()
    title = "Edit Todo Item"
    history = hist
    x = 2
    y = 3

    "&Priority" [Priority:2],   ReadNumeric(Priority),      DONTCLOSE
    "&Owner"    [Owner   :16],  GetField(Owner),            DONTCLOSE
    "&Category" [Category:16],  GetField(Category),         DONTCLOSE
    "&Text"     [TodoText:16],  EditTodoText(),             DONTCLOSE
    "",,    DIVIDE
    "O&k"
    "Cancel"
end

integer proc EditItem()
    integer rc
    string cmd[64]

    if isMacroLoaded("windlgs")
        PushPosition()
        cmd = Format(buff_todo, Chr(9), Priority, Chr(9), Owner, Chr(9), Category)
        ExecMacro("dlgaddtodo " + cmd)
        cmd = Query(MacroCmdLine)
        rc = Val(GetToken(cmd, Chr(9), 1)) == 2
        if rc
            Priority = GetToken(cmd, Chr(9), 2)
            Owner = GetToken(cmd, Chr(9), 3)
            Category = GetToken(cmd, Chr(9), 4)
        endif
        PopPosition()
    else
        rc = EditMenu() == 6
    endif
    return(rc)
end

/****************************************************************************\
    manage items
\****************************************************************************/

proc MarkItem(string toc)
    if FindBeginOfItem()
        GotoColumn(Length(CmtBeg) + 2)
        InsertText(toc, _OVERWRITE_)
        BegLine()
    endif
end

proc DeleteItem()
    if FindBeginOfItem()
        MarkChar()
        if FindEndOfItem()
            MarkChar()
            KillBlock()
        endif
        UnMarkBlock()
    endif
end

proc ChangeItem()
    PushPosition()
    ParseTodoItem()
    PopPosition()
    if EditItem()
        DeleteItem()
        InsertTodoItem()
    endif
end

/****************************************************************************\
    display list of todo items
\****************************************************************************/

proc BuildTodoList(integer sort_field)
    string line[255]
    integer fw = Query(ScreenCols) - 41

    EmptyBuffer(buff_list)

    BegFile()
    if lFind(CmtExpr, "gx")
        repeat
            ParseTodoItem()

            line = Format(LineNum:5, ":")
            if Completed
                line = line + " DONE "
            else
                line = line + Format( ("  " + Priority + " "): -6)
            endif
            line = line + Format(Owner:-8, " ", Category:-16, " ", TodoText:-fw)

            AddLine(line, buff_list)
        until not lFind(CmtExpr, "x")
    endif

    GotoBufferId(buff_list)
    case sort_field
        when 1
            return()
        when 2
            MarkColumn(1,  7, NumLines(), 12)
        when 3
            MarkColumn(1, 13, NumLines(), 20)
        when 4
            MarkColumn(1, 22, NumLines(), 37)
        when 5
            MarkColumn(1, 39, NumLines(), 80)
    endcase
    Sort()
    UnMarkBlock()
end

menu ListMenu()
    "&Edit Item             <F2>",      PushKey(<F2>)
    "S&croll To Item        <F5>",      PushKey(<F5>)
    "",,    DIVIDE
    "Mark &Done          <Alt-D>",      PushKey(<Alt D>)
    "Mark &Todo          <Alt-T>",      PushKey(<Alt T>)
    "&Remove Item        <Alt-R>",      PushKey(<Alt R>)
    "",,    DIVIDE
    "Sort by &Line       <Alt-L>",      PushKey(<Alt L>)
    "Sort by &Priority   <Alt-P>",      PushKey(<Alt P>)
    "Sort by &Owner      <Alt-O>",      PushKey(<Alt O>)
    "Sort by &Category   <Alt-C>",      PushKey(<Alt C>)
    "",,    DIVIDE
    "&Setup Defaults     <Alt-S>",      PushKey(<Alt S>)
    "",,    DIVIDE
    "&Goto Item          <Enter>",      PushKey(<Enter>)
    "E&xit List         <Escape>",      PushKey(<Escape>)
end

proc ShowListMenu()
    Set(X1, 2)
    Set(Y1, CurrLine() + 2)
    ListMenu()
end

keydef ListKeys
    <Enter>         EndProcess(TODO_GOTO)
    <SpaceBar>      EndProcess(TODO_UPDATE)
    <F5>            EndProcess(TODO_UPDATE)
    <F2>            EndProcess(TODO_EDIT)
    <Alt D>         EndProcess(TODO_DONE)
    <Alt T>         EndProcess(TODO_TODO)
    <Alt R>         EndProcess(TODO_REMOVE)
    <Alt L>         EndProcess(TODO_SORT1)
    <Alt P>         EndProcess(TODO_SORT2)
    <Alt O>         EndProcess(TODO_SORT3)
    <Alt C>         EndProcess(TODO_SORT4)
    <Alt I>         EndProcess(TODO_SORT5)
    <Alt S>         EndProcess(TODO_SETUP)
    <F1>            EndProcess(TODO_HELP)
    <F10>           ShowListMenu()
end

proc ListProc()
    UnHook(ListProc)
    Enable(ListKeys)
    Set(Attr, Query(MenuTextLtrAttr))
    VGotoXY(5,0)
    PutStr("#")
    VGotoXY(9,0)
    PutStr("!")
    VGotoXY(13,0)
    PutStr("Owner")
    VGotoXY(22,0)
    PutStr("Category")
    VGotoXY(39,0)
    PutStr("Todo Item")
end

proc ViewItems()
    integer rc
    integer sort_field = 1
    integer line = CurrLine()

    buff_user = GetBufferId()
    PushPosition()
    PushBlock()
    UnMarkBlock()

    loop
        BuildTodoList(sort_field)

        if NumLines() == 0
            Error("No todo items defined")
            PopPosition()
            break
        endif

        BegFile()
        lFind("^ *" + Str(line) + ":", "gx")

        if isMacroLoaded("windlgs")
            ExecMacro("dlgtodolist")
            rc = Val(Query(MacroCmdLine))
        else
            Hook(_LIST_STARTUP_, ListProc)
            rc = List("", Query(ScreenCols))
        endif

        line = Val(GetText(1,6))
        GotoBufferId(buff_user)
        GotoLine(line)
        BegLine()
        ScrollToCenter()
        UpdateDisplay(_ALL_WINDOWS_REFRESH_)

        case rc
            when TODO_GOTO
                KillPosition()
                break
            when TODO_CANCEL, TODO_ESCAPE
                PopPosition()
                break
            when TODO_UPDATE
                // nop
            when TODO_EDIT
                ChangeItem()
            when TODO_DONE
                MarkItem(TOC_DONE)
            when TODO_TODO
                MarkItem(TOC_TODO)
            when TODO_REMOVE
                DeleteItem()
            when TODO_SORT1
                sort_field = 1
            when TODO_SORT2
                sort_field = 2
            when TODO_SORT3
                sort_field = 3
            when TODO_SORT4
                sort_field = 4
            when TODO_SORT5
                sort_field = 5
            when TODO_SETUP
                SetupDefaults()
            when TODO_HELP
                QuickHelp(ListHelp)
        endcase

        UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    endloop

    PopBlock()
end

/****************************************************************************\
    manage file extension
\****************************************************************************/

proc GetLanguageInfo()
    integer i
    string CmtChr[8] = ""

    GetSynToEol(CmtChr)
    GetSynMultiLnDlmt(CmtBeg, CmtEnd)

    if CmtChr == ""
        CmtChr = DEF_CMT
    endif
    if CmtBeg == "" or CmtEnd == ""
        CmtBeg = CmtChr
        CmtEnd = ""
    endif

    CmtExpr = "^"
    for i=1 to Length(CmtBeg)
        if CmtBeg[i] in 'a'..'z', 'A'..'Z', '0'..'9'
            CmtExpr = CmtExpr + CmtBeg[i]
        else
            CmtExpr = CmtExpr + "\" + CmtBeg[i]
        endif
    endfor
    CmtExpr = CmtExpr + " *{" + TOC_TODO + "}|{" + TOC_DONE + "} +"
end

proc AfterUpdateDislplay()
    UnHook(AfterUpdateDislplay)
    GetLanguageInfo()
end

proc OnChangingFiles()
    Hook(_AFTER_UPDATE_DISPLAY_, AfterUpdateDislplay)
end

/****************************************************************************\
    initialization and finalization
\****************************************************************************/

proc WhenPurged()
    WriteConfig()
    AbandonFile(buff_list)
    AbandonFile(buff_todo)
    UnHook(OnChangingFiles)
end

proc WhenLoaded()
    integer bid = GetBufferId()

    ReadConfig()

    buff_list = CreateBuffer("*todo list*", _HIDDEN_)
    buff_todo = CreateBuffer("*todo text*", _HIDDEN_)
    if buff_list == 0 or buff_todo == 0
        Warn("cannot allocate work space")
        PurgeMacro(CurrMacroFilename())
    endif
    GotoBufferId(bid)

    GetLanguageInfo()
    Hook(_ON_CHANGING_FILES_, OnChangingFiles)
    Hook(_ON_ABANDON_EDITOR_, WhenPurged)
end

/****************************************************************************\
    main program and key assignments
\****************************************************************************/

proc main()
    case Query(MacroCmdLine)
        when "-c"   SetupDefaults()
        when "-t"   ChangeItem()
        otherwise   ViewItems()
    endcase
end

#ifndef USE_DIKUI
<ListTodo>      ViewItems()
<EditTodo>      ChangeItem()
#endif

