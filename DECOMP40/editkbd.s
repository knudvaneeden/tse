/****************************************************************************\

    EditKbd.S

    Edit keyboard macros interactively.

    Overview:

    EditKbd is used to interactively edit the currently defined
    key macros. It can also be used to edit a key listing generated
    by the DeComp macro.

    Keys:   (none)

    Usage notes:

    EditKbd generates a list of the currently defined key macros.
    Within this list key macros can be deleted, manually added and
    their hot keys can be changed. Moreover, the recorded keys of
    the macro can also be changed. This pops up another list which
    allows you to delete, add and change keys of the macro. After
    closing the list the changed macros will be compiled and loaded
    and all changes will immediately be available. To permanently
    save any changes, the key macros must be saved manually.


    Version         v4.00/05.06.01
    Copyright       (c) 1993-2001 by DiK, portions (c) SemWare

    History

    v4.00/05.06.01  new for this version

    Acknowledgment

    I have to thank Sammy Mitchell of SemWare Co. for pointing out
    some important details of the macro file format, which have not
    been handled correctly in early versions of these programs.

    Thanks to Chris Antos for suggestions and finding some bugs.

\****************************************************************************/


/****************************************************************************\
    global constants and variables
\****************************************************************************/


constant KEY_WIDTH  = 32                // width of key lists

constant KBD_BUFF   = 5                 // buffer id, keyboard macros

constant CMD_QUIT   = 0                 // actions taken after closing lists
constant CMD_OK     = 1
constant CMD_ADD    = 2
constant CMD_DEL    = 3
constant CMD_HOTKEY = 4
constant CMD_UNDO   = 11
constant CMD_REDO   = 12
constant CMD_SETKEY = 99

string HOT_KEY[] = "^{<.*>}$"           // reg.expr. for macro hot keys

integer buff_user                       // buffer id, user file
integer buff_macs                       // ditto, macro hot keys
integer buff_keys                       // ditto, keys of current macro
integer buff_list                       // ditto, decompiled macro listing

integer macro_count                     // number of def. macros (w/o scrap macro)
integer scrap_found                     // switch, scrap macro defined

#ifdef WIN32

integer last_code                       // most recently pressed key

#else

integer key_file                        // key code translation table
string key_table[]  = "keytable.dat"    // name of file containing key table

#endif


/****************************************************************************\
    help screens
\****************************************************************************/


helpdef KeysHelp
    title = "Help on Macro Editor"
    x = 2
    y = 3
    width = 56
    height = 20

    ""
    "This list is used to edit a key macro. You can change,"
    "insert and delete keys."
    ""
    "Commands:"
    ""
    "Edit       edit the selected key"
    "Add        add a new key"
    "Delete     delete the selected key"
    "Undo/Redo  undo/redo previous changes (TSE v3.0 only)"
    ""
    "Key assignments are shown within the pop up menu."
    ""
    "TSE Pro-32 only:"
    "To change a key simply press the new key on your"
    "keyboard. This works for almost any key or key"
    "combination. Exceptions are the basic list navigation"
    "keys and the command keys. In this case you must"
    "explicitly enter editing mode using <Enter>."
    ""
end


helpdef MacsHelp
    title = "Help on Macro Editor"
    x = 2
    y = 3
    width = 56
    height = 21

    ""
    "EditKbd is used to visually edit keyboard macros. If"
    "the current file is a decompiled key listing (c.f. help"
    "on DeComp), its contents will be displayed for editing."
    "Otherwise, the currently defined key macros will be"
    "decompiled and listed. In this case, the changed macros"
    "will automatically be recompiled and loaded into the"
    "editor after you have finished editing."
    ""
    "Commands:"
    ""
    "Edit       edit the selected key macro"
    "Add        add a new macro"
    "Delete     delete the selected macro"
    "Hot Key    change the hot key of the selected macro"
    "Undo/Redo  undo/redo previous changes (TSE v3.0 only)"
    ""
    "Key assignments are shown within the pop up menu."
    ""
    "Note: the scrap macro is listed as the <Enter> macro."
    ""
end


/****************************************************************************\
    forward definitions
\****************************************************************************/


forward proc DelMacro(string key)


/****************************************************************************\
    displaying messages

    version dependencies:
    þ   2.8+    use message boxes
\****************************************************************************/


#ifdef WIN32

integer proc AskYesNo(string question)
    return( MsgBox("EditKbd", question, _YES_NO_) == 1 )
end

proc Error(string msg)
    MsgBox("EditKbd", msg)
end

#else

integer proc AskYesNo(string question)
    Set(X1,2)
    Set(Y1,3)
    return( YesNo(question) == 1 )
end

proc Error(string msg)
    Warn(msg)
end

#endif


integer proc AskSave()
    return(AskYesNo("Save changes?"))
end


proc ShowTitle(string msg)
    VGotoXY(0, -1)
    Set(Attr, Query(MenuTextLtrAttr))
    PutLine(msg, Query(ScreenCols))
end


proc ShowMsg(string msg)
    VGotoXY(0, Query(ScreenRows)-2)
    Set(Attr, Query(MenuTextLtrAttr))
    PutLine(msg, Query(ScreenCols))
end


/****************************************************************************\
    executing external macros
\****************************************************************************/


integer proc FancyExecMacro(string cmd)
    integer rc, msg

    msg = Set(MsgLevel,_NONE_)
    rc = ExecMacro(cmd)
    Set(MsgLevel,msg)

    if not rc
        Error("Cannot execute macro: " + GetToken(cmd, " ", 1))
    endif

    return(rc)
end


/****************************************************************************\
    reading and interpreting keystrokes

    version dependencies:
    þ   2.8+    getting key names
\****************************************************************************/


integer proc FancyGetKey()
    constant CLR = Color(bright yellow on red)
    integer cs
    integer key = 0
    integer pwleft = (Query(ScreenCols) - KEY_WIDTH) / 2 + 1

    cs = Set(Cursor, OFF)
    if PopWinOpen(pwleft, 3, pwleft+KEY_WIDTH+1, 9, 1, "", CLR)
        Set(Attr, CLR)
        ClrScr()
        PutCtrStr("press a key", 2)
        PutCtrStr("<RightBtn> to cancel", 4)
        key = GetKey()
        PopWinClose()
    else
        Warn("out of memory")
    endif
    Set(Cursor, cs)
    return(key)
end


#ifdef WIN32


string proc mKeyName(integer key)
    return("<" + KeyName(key) + ">")
end


#else


integer proc FindCode(integer key, integer width, integer col)
    string hex_name[4]

    hex_name = Format(key:width:'0':16)
    if lFind(hex_name,"g")
        repeat
            if col == 0
                if (CurrPos() - 1) mod 4 == 0
                    return (TRUE)
                endif
            else
                if CurrPos() == col
                    return (TRUE)
                endif
            endif
        until not lRepeatFind()
    endif
    return (FALSE)
end


string proc mKeyName(integer key)
    integer bid, n
    string key_name[KEY_WIDTH] = ""
    string cols[4] = Chr(9) + Chr(9) + Chr(5) + Chr(1)

    bid = GotoBufferId(key_file)

    if FindCode(key,4,0)
        key_name = SubStr(
            "Shift Ctrl  Alt ",
            ((CurrPos() - 1)/4) * 6 + 1, 6 - CurrPos() /4)
        key_name = key_name + GetText(17,KEY_WIDTH)
    else
        n = (key & 0xFF) - 0xFA
        if 0 <= n and n <= 3
            if FindCode(key shr 8, 2, Asc(cols[n+1]))
                key_name = SubStr(
                    "CtrlAlt    AltShift   CtrlShift  ShiftShift ",
                    n * 11 + 1, n + 8)
                key_name = key_name + GetText(17,KEY_WIDTH)
            endif
        endif
    endif

    GotoBufferId(bid)

    if key_name == ""
        key_name = Str(key,16)
    endif

    return("<" + key_name + ">")
end


#endif


/****************************************************************************\
    helper routines: finding and editing macros
\****************************************************************************/


integer proc FindKeyMacro(string key)
    if key == ""
        return(FALSE)
    endif
    if lFind(key, "gi^$")
        return(TRUE)
    endif
    Error("Cannot find key macro! Key list is invalid!")
    return(FALSE)
end


integer proc MarkKeyMacro(string key)
    if FindKeyMacro(key)
        MarkLine()
        if lFind(HOT_KEY, "x+")
            Up()
        else
            EndFile()
        endif
        MarkLine()
        return(TRUE)
    endif
    return(FALSE)
end


integer proc GetHotKey()
    integer code

    code = FancyGetKey()
    if code == <GreyEnter>
        code = <Enter>
    endif
    return(code)
end


integer proc HotKeyExists(string key)
    string new_key[KEY_WIDTH] = Lower(key)
    string curr_key[KEY_WIDTH]

    if lFind(HOT_KEY, "gx")
        repeat
            curr_key = Lower(GetFoundText())
            if curr_key == new_key
                Error("Duplicate macro hot key")
                return(TRUE)
            endif
        until not lRepeatFind()
    endif
    return(FALSE)
end


/****************************************************************************\
    helper routines: counting macros
\****************************************************************************/


integer proc isMacroDefined()
    return( macro_count > 0 or scrap_found > 0 )
end


proc ResetMacroCount()
    macro_count = 0
    scrap_found = 0
end


integer proc ChangeMacroCount(string key, integer delta)
    integer rc = TRUE
    string lkey[KEY_WIDTH]
    string msg[32] = "Maximum macro capacity reached!"

    lkey = Lower(key)
    if lkey == "<enter>" or lkey == "<greyenter>"
        if delta > 0 and scrap_found >= 1
            Error(msg)
            rc = FALSE
        else
            scrap_found = scrap_found + delta
        endif
    else
        if delta > 0 and macro_count >= 20
            Error(msg)
            rc = FALSE
        else
            macro_count = macro_count + delta
        endif
    endif
    return(rc)
end


/****************************************************************************\
    menus

    version dependencies:
    þ   3.0+    undo/redo
\****************************************************************************/


#ifdef EDITOR_VERSION

menu KeysMenu()
    history

    "&Edit    <Enter>",     EndProcess(CMD_OK)
    "",, _MF_DIVIDE_
    "&Add       <Ins>",     EndProcess(CMD_ADD)
    "&Delete    <Del>",     EndProcess(CMD_DEL)
    "",, _MF_DIVIDE_
    "&Undo   <Ctrl Z>",     EndProcess(CMD_UNDO)
    "&Redo   <Ctrl Y>",     EndProcess(CMD_REDO)
    "",, _MF_DIVIDE_
    "&Help",                QuickHelp(KeysHelp)
    "",, _MF_DIVIDE_
    "E&xit",                EndProcess(CMD_QUIT)
end

menu MacsMenu()
    history

    "&Edit    <Enter>",     EndProcess(CMD_OK)
    "",, _MF_DIVIDE_
    "&Add       <Ins>",     EndProcess(CMD_ADD)
    "&Delete    <Del>",     EndProcess(CMD_DEL)
    "Hot &Key    <F2>",     EndProcess(CMD_HOTKEY)
    "",, _MF_DIVIDE_
    "&Undo   <Ctrl Z>",     EndProcess(CMD_UNDO)
    "&Redo   <Ctrl Y>",     EndProcess(CMD_REDO)
    "",, _MF_DIVIDE_
    "&Help",                QuickHelp(MacsHelp)
    "",, _MF_DIVIDE_
    "E&xit",                EndProcess(CMD_QUIT)
end

#else

menu KeysMenu()
    history

    "&Edit    <Enter>",     EndProcess(CMD_OK)
    "",, DIVIDE
    "&Add       <Ins>",     EndProcess(CMD_ADD)
    "&Delete    <Del>",     EndProcess(CMD_DEL)
    "",, DIVIDE
    "&Help",                QuickHelp(KeysHelp)
    "",, DIVIDE
    "E&xit",                EndProcess(CMD_QUIT)
end

menu MacsMenu()
    history

    "&Edit    <Enter>",     EndProcess(CMD_OK)
    "",, DIVIDE
    "&Add       <Ins>",     EndProcess(CMD_ADD)
    "&Delete    <Del>",     EndProcess(CMD_DEL)
    "Hot &Key    <F2>",     EndProcess(CMD_HOTKEY)
    "",, DIVIDE
    "&Help",                QuickHelp(MacsHelp)
    "",, DIVIDE
    "E&xit",                EndProcess(CMD_QUIT)
end

#endif


/****************************************************************************\
    key assignments

    version dependencies:
    þ   3.0+    undo/redo
    þ   2.8+    changing non-editing keys
\****************************************************************************/


#ifdef WIN32

proc GetKeyHook()
    last_code = Query(Key)

#ifdef EDITOR_VERSION
    case last_code
        when <Ctrl Z>
            Set(Key, 0)
            EndProcess(CMD_UNDO)
            return()
        when <Ctrl Y>
            Set(Key, 0)
            EndProcess(CMD_REDO)
            return()
    endcase
#endif

    if GetBufferId() == buff_keys
        if not (last_code in
                    <F1>, <F10>,
                    <Enter>, <Escape>, <Ins>, <Del>,
                    <CursorUp>, <CursorDown>, <PgUp>, <PgDn>, <Home>, <End>)
            Set(Key, 0)
            EndProcess(CMD_SETKEY)
        endif
    endif
end

#endif


proc CmdListMenu()
#IFDEF WIN32
    integer agk = SetHookState(OFF, _AFTER_GETKEY_)
#ENDIF

    Set(X1, (Query(ScreenCols) - 16) / 2)
    Set(Y1, 1)
    if GetBufferId() == buff_keys
        KeysMenu()
    else
        MacsMenu()
    endif

#IFDEF WIN32
    SetHookState(agk, _AFTER_GETKEY_)
#ENDIF
end


proc CmdHotKey()
    if GetBufferId() <> buff_keys
        EndProcess(CMD_HOTKEY)
    endif
end


proc CmdShowHelp()
    if GetBufferId() == buff_keys
        QuickHelp(KeysHelp)
    else
        QuickHelp(MacsHelp)
    endif
end


keydef ListKeys
    <F1>        CmdShowHelp()
    <F10>       CmdListMenu()
    <Ins>       EndProcess(CMD_ADD)
    <Del>       EndProcess(CMD_DEL)
    <F2>        CmdHotKey()
end


proc ListHook()
    UnHook(ListHook)
    Enable(ListKeys)
    ListFooter(" {Enter}-Edit {F1}-Help {F10}-Menu ")
end


/****************************************************************************\
    editing keys within a macro

    version dependencies:
    þ   3.0+    undo/redo
    þ   2.8+    changing non-editing keys
\****************************************************************************/


proc ChangeKey(integer code)
#ifdef EDITOR_VERSION
    PushUndoMark()
#endif

    BegLine()
    KillToEol()
    InsertText(mKeyName(code))
    BegLine()

#ifdef EDITOR_VERSION
    PopUndoMark()
#endif
end


proc EditKey()
    integer code

    if CurrLineLen() > 0
        code = FancyGetKey()
        if code <> <RightBtn>
            ChangeKey(code)
        endif
    endif
end


#ifdef WIN32

proc SetLastKey()
    if CurrLineLen() > 0
        ChangeKey(last_code)
    endif
end

#endif


/****************************************************************************\
    adding and deleting keys within a macro

    version dependencies:
    þ   3.0+    undo/redo
\****************************************************************************/


proc AddKey()
    integer code

#ifdef EDITOR_VERSION
    PushUndoMark()
#endif

    code = FancyGetKey()
    if code <> <RightBtn>
        InsertLine(mKeyName(code))
    endif

#ifdef EDITOR_VERSION
    PopUndoMark()
#endif
end

/****************************************************************************/

proc DelKey()
#ifdef EDITOR_VERSION
    PushUndoMark()
#endif

    if CurrLineLen() > 0
        KillLine()
    endif

#ifdef EDITOR_VERSION
    PopUndoMark()
#endif
end


/****************************************************************************\
    edit a key macro

    version dependencies:
    þ   3.0+    undo/redo
    þ   2.8+    changing non-editing keys
\****************************************************************************/


proc EditMacro(string key)
    integer cmd, ilba

    // copy macro into working buffer

    if not MarkKeyMacro(key)
        return()
    endif

    GotoBufferId(buff_keys)
    EmptyBuffer()
    CopyBlock()
    UnMarkBlock()

    // format macro keys (remove hot-key and spaces)

    BegFile()
    KillLine()
    loop
        GotoLine(NumLines())
        if CurrChar() < 0
            KillLine()
        else
            break
        endif
    endloop
    AddLine()
    repeat
        DelRightWord()
    until not Up()

    // intialize list display

    FileChanged(FALSE)

#ifdef EDITOR_VERSION
    ClearUndoRedoList()
#endif

    loop
        ShowTitle("Listing key macro " + key)

        // display list of macro keys

#ifdef WIN32
        Hook(_AFTER_GETKEY_, GetKeyHook)
#endif

        Hook(_LIST_STARTUP_, ListHook)
        Set(Y1, 3)
        cmd = List(key, KEY_WIDTH)

#ifdef WIN32
        UnHook(GetKeyHook)
#endif

        // execute selected action

        case cmd
            when CMD_QUIT       break
            when CMD_OK         EditKey()
            when CMD_ADD        AddKey()
            when CMD_DEL        DelKey()

#ifdef EDITOR_VERSION
            when CMD_REDO       Redo()
            when CMD_UNDO       Undo()
#endif

#ifdef WIN32
            when CMD_SETKEY     SetLastKey()
#endif

        endcase
    endloop

    // check for empty list

    if NumLines() == 1
        GotoBufferId(buff_list)
        if AskYesNo("Macro is empty! Delete it?")
            DelMacro(key)
        endif
        return()
    endif

    // ask user to save changes

    if not (FileChanged() and AskSave())
        GotoBufferId(buff_list)
        return()
    endif

    // format key listing

    BegFile()
    repeat
        BegLine()
        InsertText("    ", _INSERT_)
    until not Down()

    // delete previously defined macro keys

    GotoBufferId(buff_list)
    MarkKeyMacro(key)
    MarkLine(Query(BlockBegLine) + 1, Query(BlockEndLine))
    KillBlock()

    // insert edited keys into listing

    GotoBufferId(buff_keys)
    MarkLine(1, NumLines())
    GotoBufferId(buff_list)
    ilba = Set(InsertLineBlocksAbove, TRUE)
    CopyBlock()
    Set(InsertLineBlocksAbove, ilba)
    UnMarkBlock()
end


/****************************************************************************\
    adding, deleting and changing macros

    version dependencies:
    þ   3.0+    undo/redo
\****************************************************************************/


proc AddMacro()
    integer code
    string key[KEY_WIDTH]

    ShowMsg("Press hot key for new macro...")
    code = GetHotKey()
    if code == <RightBtn>
        return()
    endif
    key = mKeyName(code)

    if HotKeyExists(key)
        return()
    endif

    if not ChangeMacroCount(key, +1)
        return()
    endif

#ifdef EDITOR_VERSION
    PushUndoMark()
#endif

    BegFile()
    AddLine()
    AddLine(key)
    AddLine("    <Escape>")
    AddLine()

#ifdef EDITOR_VERSION
    PopUndoMark()
#endif
end

/****************************************************************************/

proc DelMacro(string key)
#ifdef EDITOR_VERSION
    PushUndoMark()
#endif

    if MarkKeyMacro(key)
        KillBlock()
        ChangeMacroCount(key, -1)
    endif

#ifdef EDITOR_VERSION
    PopUndoMark()
#endif
end

/****************************************************************************/

proc EditHotKey(string key)
    integer code
    string new_key[KEY_WIDTH]

    ShowMsg("Press new hot key for " + key + "...")
    code = GetHotKey()
    if code == <RightBtn>
        return()
    endif
    new_key = mKeyName(code)

    if HotKeyExists(new_key)
        return()
    endif

#ifdef EDITOR_VERSION
    PushUndoMark()
#endif

    if FindKeyMacro(key)
        ChangeKey(code)
    endif

#ifdef EDITOR_VERSION
    PopUndoMark()
#endif
end


/****************************************************************************\
    edit the key listing in the current buffer

    version dependencies:
    þ   3.0+    undo/redo
\****************************************************************************/


proc EditList()
    integer cmd
    string key[KEY_WIDTH]

    // store buffer id of key listing

    buff_list = GetBufferId()

    // main editing loop

    loop
        ShowTitle("Listing hot keys of all key macros...")
        ShowMsg("")

        // extract macro hot-keys from key listing

        ResetMacroCount()
        EmptyBuffer(buff_macs)

        if lFind(HOT_KEY, "gx")
            repeat
                key = GetFoundText()
                AddLine(key, buff_macs)
            until not (ChangeMacroCount(key, +1) and lRepeatFind())
        endif

        // intialize list of hot keys

        GotoBufferId(buff_macs)
        BegFile()

#ifdef EDITOR_VERSION
        ClearUndoRedoList()
#endif

        // display a list of hot-keys to edit

#ifdef EDITOR_VERSION
        Hook(_AFTER_GETKEY_, GetKeyHook)
#endif

        Hook(_LIST_STARTUP_, ListHook)
        Set(Y1, 3)
        cmd = List("Key Macros", KEY_WIDTH)

#ifdef EDITOR_VERSION
        UnHook(GetKeyHook)
#endif

        // get selected hot-key and return to key listing

        key = GetText(1, CurrLineLen())
        GotoBufferId(buff_list)

        // execute selected action

        case cmd
            when CMD_QUIT       break
            when CMD_OK         EditMacro(key)
            when CMD_ADD        AddMacro()
            when CMD_DEL        DelMacro(key)
            when CMD_HOTKEY     EditHotKey(key)

#ifdef EDITOR_VERSION
            when CMD_REDO       Redo()
            when CMD_UNDO       Undo()
#endif

        endcase
    endloop
end


/****************************************************************************\
    edit current macros
\****************************************************************************/


proc EditMacros()
    integer rc, bid
    string kbd_name[255]
    string key_name[255]

    // check, if macros are defined

    bid = GotoBufferId(KBD_BUFF)
    rc = NumLines() == 0
    GotoBufferId(bid)
    if rc
        Error("No key macros defined!")
        return()
    endif

    // make temporary file names

    kbd_name = MakeTempName(GetEnvStr("TEMP"), "KBD")
    key_name = SplitPath(kbd_name, _DRIVE_|_PATH_|_NAME_) + ".k"

    // save, decompile, edit, recompile and load key macros

    if SaveKeyMacro(kbd_name)
        if FancyExecMacro("decomp " + kbd_name)
            if FileExists(key_name)
                EditList()
                if FileChanged() and AskSave()
                    if isMacroDefined()
                        FancyExecMacro("recomp -load")
                    else
                        PurgeKeyMacro()
                    endif
                endif
                AbandonFile()
            else
                Error("Error while decompiling key macros.")
            endif
        endif
    endif

    // remove temp files

    EraseDiskFile(kbd_name)
    EraseDiskFile(key_name)
end


/****************************************************************************\
    initialization
\****************************************************************************/


proc WhenLoaded()
#ifndef WIN32
    string key_name[255]
#endif

    // store current position

    buff_user = GetBufferId()

#ifndef WIN32

    // load translation table

    key_name = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_) + key_table
    key_file = CreateTempBuffer()
    if not (key_file and InsertFile(key_name, _DONT_PROMPT_))
        Error("Cannot load key translation table")
        return()
    endif
    UnmarkBlock()

    // remove comments from translation table

    while lFind("{^$}|{^//}","gx")
        KillLine()
    endwhile

#endif

    // create working buffers

    buff_macs = CreateBuffer("+macs+")
    buff_keys = CreateBuffer("+keys+")
    GotoBufferId(buff_user)

    // check for errors

    if buff_macs == 0 or buff_keys == 0
        Error("Cannot allocate work space")
        PurgeMacro(CurrMacroFilename())
    endif
end


/****************************************************************************\
    finalization
\****************************************************************************/


proc WhenPurged()
#ifndef WIN32
    AbandonFile(key_file)
#endif
    AbandonFile(buff_macs)
    AbandonFile(buff_keys)
end


/****************************************************************************\
    main program
\****************************************************************************/


proc main()
    integer rc
    integer clr = Query(MenuTextAttr)

    // clear screen

    rc = PopWinOpen(1, 2, Query(ScreenCols), Query(ScreenRows)-1, 4, "", clr)
    if rc
        Set(Attr, clr)
        ClrScr()
    endif

    // edit current file or create and edit temporary listing

    PushBlock()
    if CurrExt() == ".k"
        EditList()
    else
        EditMacros()
    endif
    PopBlock()

    // restore screen

    if rc
        PopWinClose()
    endif
    PurgeMacro(CurrMacroFileName())
end

