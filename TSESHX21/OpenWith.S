/****************************************************************************\

    OpenWith.S

    Create windows shell extensions for TSE.

    Overview:

    This macro registers "Open With TSE" shell extensions
    which integrate TSE into the windows shell (NT and 95/98).

    Keys:   (none)

    Usage notes:

    This macro will be built and executed by openwith.bat. There is
    no reason to compile or execute it manually.

    !!! WARNING !!!

    Changing this macro requires some fundamental knowledge about
    the windows application programming interface and especially
    about inf files and the windows registry. Changing the macro
    without proper knowledge could disable the operating system,
    lead to data loss or could force you to re-install the system
    from scratch.

    Version         v2.10/09.07.99
    Copyright       (c) 1997-99 by DiK

    History
    v2.10/09.07.99  enhanced user interface
                    þ added refresh command
                    þ added user friendly file type
                    þ added editing of menu item
                    þ added auto-update to new format
                    þ added auto-update of changed shell info
                    þ enhanced file type display (ddeexec)
                    þ fixed message boxes
                    þ fixed quoting of filenames
                    þ fixed adding and deleting keys (error handling)
    v2.00/19.04.99  new for version 2.0

\****************************************************************************/

/****************************************************************************\
    global variables
\****************************************************************************/

constant LIST_OPTS  = _ENABLE_SEARCH_ | _ENABLE_HSCROLL_

constant NAME_COL =   0 + 1     // user friendly file type
constant EXTS_COL =  50 + 1     // extensions
constant TYPE_COL = 100 + 1     // file type (as programmers see it)
constant STOP_COL = 150 + 1     // end-of-list

constant NAME_LEN = EXTS_COL - NAME_COL
constant EXTS_LEN = TYPE_COL - EXTS_COL
constant TYPE_LEN = STOP_COL - TYPE_COL

constant NAME_FMT = NAME_LEN - 2
constant EXTS_FMT = EXTS_LEN - 2
constant TYPE_FMT = TYPE_LEN - 2

integer from_batch              // switch, macro called from batch file

integer types_buff              // buffer id, windows file types
integer compr_buff              // ditto, finding "open with" entries
integer shcmd_buff              // ditto, shell commands of file type

string TseCmd[255]
string TseItem[48] = "Open &With TSE"
string OpenWithTse[16]

string OPEN_WITH_TSE_V210[] = "OpenWithTSE"
string OPEN_WITH_TSE_V200[] = "Open With TSE"

string CAPTION[] = "Open With TSE"
string WIN_TITLE[] = "Windows File Types"

/****************************************************************************\
    help package
\****************************************************************************/

#include "ShowHelp.SI"

/****************************************************************************\
    helper functions
\****************************************************************************/

// get the currently selected file type

string proc GetFileType()
    return(RTrim(GetText(TYPE_COL,TYPE_LEN)))
end

// get the currently selected file extensions

string proc GetFileExts()
    return(RTrim(GetText(EXTS_COL,EXTS_LEN)))
end

// get the currently selected "user friendly" type

string proc GetTypeName()
    return(RTrim(GetText(NAME_COL,NAME_LEN)))
end

/****************************************************************************\
    helper functions (translate string to oem)
\****************************************************************************/

dll "<user32.dll>"

integer proc CharToOemBuffA(
    var string lpszSrc: StrPtr,
    var string lpszDst: StrPtr,
    integer cchDstLength)
end

string proc CharToOem(string src)
    string dst[255] = src

    CharToOemBuffA(src,dst,Length(src))
    return (dst)
end

/****************************************************************************\
    registry api wrappers (low level)
\****************************************************************************/

#include "RegApi.SI"

//  get subkey count (key must be open)

integer proc RegNumSubKeys(integer hKey)
    integer code
    integer NumKeys, NumValues
    integer d1, d2, d3, d4, d5
    integer LenClass = 255
    string Class[255] = "" , LastWriteTime[8] = ""

    code = RegQueryInfoKeyA(hKey, Class, LenClass, 0,
        NumKeys, d1, d2, NumValues, d3, d4, d5, LastWriteTime)

    if code == ERROR_SUCCESS
        return(NumKeys)
    endif
    return(-1)
end

//  get the name of a subkey by index (key must be open)

string proc RegSubKeyName(integer hKey, integer Index)
    integer code
    integer LenName = 255, LenClass = 255
    string Name[255] = "", Class[255] = "" , LastWriteTime[8] = ""

    code = RegEnumKeyExA(hKey, Index,
        Name, LenName, 0, Class, LenClass, LastWriteTime)

    if code == ERROR_SUCCESS
        PokeWord(Addr(Name),LenName)
        return(Name)
    endif
    return("")
end

// read the default value of a named subkey

string proc RegGetDefaultValue(integer hKey, string SubKeyName)
    integer code
    integer hSubKey
    integer ValType
    integer LenValue = 255
    string Value[255] = ""

    code = RegOpenKeyExA(hKey, SubKeyName, 0, KEY_READ, hSubKey)
    if code == ERROR_SUCCESS
        code = RegQueryValueExA(hSubKey, "", 0, ValType, Value, LenValue)
        if code == ERROR_SUCCESS and ValType == REG_SZ or ValType == REG_EXPAND_SZ
            PokeWord(Addr(Value),LenValue-1)
            return(Value)
        endif
        RegCloseKey(hSubKey)
    endif
    return("")
end

/****************************************************************************\
    registry api wrappers (high level)
\****************************************************************************/

// opens a named key

integer proc RegOpenKey(string SubKeyName, integer ErrMsg, var integer hKey)
    integer code

    code = RegOpenKeyExA(HKEY_CLASSES_ROOT,SubKeyName,0,KEY_ALL_ACCESS,hKey)
    if code <> ERROR_SUCCESS
        if ErrMsg
            MsgBox("Error","Cannot open key: "+SubKeyName,0)
        endif
        return(FALSE)
    endif
    return(TRUE)
end

// gets selected file type and opens corresponding _shell_ key

integer proc RegOpenCurrKey(integer ErrMsg, var integer hKey)
    return(RegOpenKey( GetFileType() + "\Shell", ErrMsg, hKey ))
end

/****************************************************************************\
    adding and removing "open with" entries
\****************************************************************************/

// delete "Open With TSE" entry (low level, no error messages)

integer proc lDelOpenWithTse(integer hKey)
    integer code
    integer hSubKey

    code = RegOpenKeyExA(hKey, OpenWithTse, 0, KEY_ALL_ACCESS, hSubKey)

    if code == ERROR_SUCCESS
        RegDeleteKeyA(hSubKey,"command")
        RegCloseKey(hSubKey)
        code = RegDeleteKeyA(hKey,OpenWithTse)
    endif

    return(code)
end

// add new "Open With TSE" entry (high level, from list interface)

proc AddOpenWithTse()
    integer code
    integer hKey
    integer hSubKey
    integer Disposition

    if not RegOpenCurrKey(TRUE,hKey)
        return()
    endif

    // add OpenWithTse entry and set standard value (menu item)

    code = RegCreateKeyExA(hKey, OpenWithTse, 0,
            "", REG_OPTION_NON_VOLATILE, KEY_WRITE, 0, hSubKey, Disposition)

    if code == ERROR_SUCCESS
        code = RegSetValueExA(hSubKey,"",0,REG_SZ,TseItem,Length(TseItem)+1)
        RegCloseKey(hSubKey)
    endif

    // add command sub-key and set standard value ()

    if code == ERROR_SUCCESS

        code = RegCreateKeyExA(hKey, OpenWithTse + "\command", 0,
                "", REG_OPTION_NON_VOLATILE, KEY_WRITE, 0, hSubKey, Disposition)

        if code == ERROR_SUCCESS
            code = RegSetValueExA(hSubKey,"",0,REG_SZ,TseCmd,Length(TseCmd)+1)
            RegCloseKey(hSubKey)
        endif

    endif

    // check for errors and kill item in case of error

    if code <> ERROR_SUCCESS
        MsgBox('Error','Cannot create "Open With TSE" entry',0)
        lDelOpenWithTse(hKey)
    endif

    RegCloseKey(hKey)
end

// delete "Open With TSE" entry (high level, from list interface)

proc DeleteOpenWithTse()
    integer hKey

    if not RegOpenCurrKey(TRUE,hKey)
        return()
    endif

    if lDelOpenWithTse(hKey) <> ERROR_SUCCESS
        MsgBox('Error','Cannot delete "Open With TSE" entry',0)
    endif

    RegCloseKey(hKey)
end

/****************************************************************************\
    searching "open with" entries
\****************************************************************************/

integer proc FindOpenWithTse(integer find_next)
    integer found
    integer code
    integer hKey
    integer hSubKey

    if not find_next
        BegFile()
    endif

    found = FALSE
    repeat
        if RegOpenCurrKey(FALSE,hKey)
            code = RegOpenKeyExA(hKey,OpenWithTse,0,KEY_READ,hSubKey)
            if code == ERROR_SUCCESS
                RegCloseKey(hSubKey)
                found = not find_next
            endif
            RegCloseKey(hKey)
            find_next = FALSE
        endif
    until found or not Down()

    return(found)
end

/****************************************************************************\
    remove all "open with" entries
\****************************************************************************/

proc Uninstall()
    integer code

    Set(Attr,Query(MenuTextAttr))
    ClrScr()
    code = MsgBox(CAPTION,'Remove all entries?',_YES_NO_)
    UpdateDisplay(_WINDOW_REFRESH_)

    if code <> 1
        return()
    endif

    PushPosition()
    code = FindOpenWithTse(FALSE)
    while code
        DeleteOpenWithTse()
        code = FindOpenWithTse(TRUE)
    endwhile
    PopPosition()
end

/****************************************************************************\
    update version 2.00 to version 2.10
\****************************************************************************/

proc UpdateFrom200To210()
    integer code

    OpenWithTse = OPEN_WITH_TSE_V200

    code = FindOpenWithTse(FALSE)
    if code
        MsgBox(CAPTION,"Version 2.0 entries will now be updated to 2.1",_OK_)
    else
        goto finally
    endif

    while code
        DeleteOpenWithTse()
        OpenWithTse = OPEN_WITH_TSE_V210
        AddOpenWithTse()
        OpenWithTse = OPEN_WITH_TSE_V200
        code = FindOpenWithTse(TRUE)
    endwhile

finally:
    BegFile()
    OpenWithTse = OPEN_WITH_TSE_V210
end

/****************************************************************************\
    update changes to editor path and/or menu item
\****************************************************************************/

proc UpdateShellInfo(string NewCmd, string NewItem)
    integer code
    string OldCmd[255] = TseCmd
    string OldItem[48] = TseItem

    MsgBox(CAPTION,"Shell information will now be updated",_OK_)

    PushPosition()

    code = FindOpenWithTse(FALSE)
    while code
        DeleteOpenWithTse()
        TseCmd = NewCmd
        TseItem = NewItem
        AddOpenWithTse()
        TseCmd = OldCmd
        TseItem = OldItem
        code = FindOpenWithTse(TRUE)
    endwhile

    TseCmd = NewCmd
    TseItem = NewItem

    PopPosition()
end

/****************************************************************************\
    change path to editor executable
\****************************************************************************/

proc ChangeTsePath()
    string NewCmd[255]

    Set(Attr,Query(MenuTextAttr))
    ClrScr()

    NewCmd = SubStr(TseCmd,1,Length(TseCmd)-5)
    Set(Y1,2)
    if Ask("Enter TSE command (use fully qualified path)",NewCmd)
        if Length(NewCmd) and FileExists(NewCmd)
            UpdateShellInfo(NewCmd+'" %1"',TseItem)
        else
            MsgBox("Error","TSE command not found",0)
        endif
    endif

    UpdateDisplay(_WINDOW_REFRESH_)
end

/****************************************************************************\
    change menu item
\****************************************************************************/

proc ChangeMenuItem()
    string NewItem[48]

    Set(Attr,Query(MenuTextAttr))
    ClrScr()

    NewItem = TseItem
    Set(Y1,2)
    if Ask('Menu entry (use "&" to designate shortcut key)',NewItem)
        if Length(NewItem) > 0
            UpdateShellInfo(TseCmd,NewItem)
        else
            MsgBox("Error","Empty menu item not allowed",0)
        endif
    endif

    UpdateDisplay(_WINDOW_REFRESH_)
end

/****************************************************************************\
    enumerate shell commands (information only)
\****************************************************************************/

proc EnumerateShellCommands()
    integer bid
    integer hKey
    integer Index
    string FileType[TYPE_LEN]
    string FileExts[EXTS_LEN]
    string TypeName[NAME_LEN]
    string SubKeyName[255], Action[255]

    FileType = GetFileType()
    FileExts = GetFileExts()
    TypeName = GetTypeName()

    // enumerate subkeys of selected file type
    // get and format command entries of subkeys

    if not RegOpenCurrKey(TRUE,hKey)
        return()
    endif

    EmptyBuffer(shcmd_buff)

    for Index = 0 to RegNumSubKeys(hKey) - 1
        SubKeyName = RegSubKeyName(hKey,Index)
        if Length(SubKeyName) > 0
            Action = RegGetDefaultValue(hKey, SubKeyName+"\command")
            if Length(Action) == 0
                Action = "<command not defined>"
            endif
            Action = Format(SubKeyName:-20,Action)
        else
            Action = "<cannot access sub key>"
        endif
        AddLine(Action,shcmd_buff)
    endfor

    for Index = 0 to RegNumSubKeys(hKey) - 1
        SubKeyName = RegSubKeyName(hKey,Index)
        if Length(SubKeyName) > 0
            Action = RegGetDefaultValue(hKey, SubKeyName+"\ddeexec")
            if Length(Action) > 0
                SubKeyName = "DDE: " + SubKeyName
                Action = Format(SubKeyName:-20,CharToOem(Action))
                AddLine(Action,shcmd_buff)
            endif
        endif
    endfor

    RegCloseKey(hKey)

    // add more information

    bid = GotoBufferId(shcmd_buff)
    BegFile()
    InsertLine()
    AddLine(Format("file type":-20,TypeName))
    AddLine(Format("internal type":-20,FileType))
    AddLine(Format("associated ext's":-20,FileExts))
    AddLine()
    AddLine("actions and commands defined for this file type")
    AddLine()
    EndFile()
    AddLine()
    BegFile()
    GotoBufferId(bid)
end

/****************************************************************************\
    file type info
\****************************************************************************/

proc Dummy()
end

proc ParentAction()
    PushKey(Query(Key))
    EndProcess(0)
end

keydef ListTypeInfoKeys
    <Enter>     Dummy()
    <Ins>       ParentAction()
    <Del>       ParentAction()
end

proc ListTypeInfoInit()
    ListFooter(' {Ins}-Insert  {Del}-Delete "Open With TSE" ')
    Enable(ListTypeInfoKeys)
    UnHook(ListTypeInfoInit)
end

proc ListTypeInfo()
    integer bid

    EnumerateShellCommands()

    bid = GotoBufferId(shcmd_buff)
    Set(Attr,Query(MenuTextAttr))
    ClrScr()
    Hook(_LIST_STARTUP_,ListTypeInfoInit)
    lList("",80,Query(ScreenRows),LIST_OPTS)
    GotoBufferId(bid)
    UpdateDisplay(_WINDOW_REFRESH_)
end

/****************************************************************************\
    compressed file types list
\****************************************************************************/

keydef ComprListKeys
    <Enter>     ListTypeInfo()
    <Ctrl L>    RepeatFind()
    <Ctrl N>    RepeatFind()
    <Del>       EndProcess(42)
end

proc ComprListInit()
    ListFooter(" {Enter}-Info  {Del}-Delete ")
    Enable(ComprListKeys)
    UnHook(ComprListInit)
end

/****************************************************************************\
    list all "open with" entries
\****************************************************************************/

proc ListOpenWithTse()
    integer code
    string line[255]

    PushPosition()
    Set(Attr,Query(MenuTextAttr))
    ClrScr()

    repeat

        // search "open with" entries

        if not FindOpenWithTse(FALSE)
            MsgBox(CAPTION,'No entries found',0)
            break
        endif
        repeat
            line = GetText(1,255)
            AddLine(line,compr_buff)
        until not FindOpenWithTse(TRUE)

        // display finds

        GotoBufferId(compr_buff)
        BegFile()
        Hook(_LIST_STARTUP_,ComprListInit)
        code = List("Open With TSE",80)
        if code == 42
            DeleteOpenWithTse()
        endif
        EmptyBuffer()
        GotoBufferId(types_buff)

    until code <> 42

    PopPosition()
    UpdateDisplay(_WINDOW_REFRESH_)
end

/****************************************************************************\
    enumerate file types
\****************************************************************************/

integer proc EnumerateFileTypes()
    integer hKey
    integer Index
    string Extension[63]
    string FileType[255]
    string NextFileType[255]
    string SubKeyName[255]

    // prepare

    if not PopWinOpen(20,5,60,9,1,"",Query(MenuTextAttr))
        return(FALSE)
    endif
    Set(Attr,Query(MenuTextAttr))
    EmptyBuffer()

    // enumerate file extensions and get associated file types
    // (one line per extension, left col = type, right col = ext)

    ClrScr()
    PutCtrStr("reading registry",2)

    for Index = 0 to RegNumSubKeys(HKEY_CLASSES_ROOT) - 1

        SubKeyName = RegSubKeyName(HKEY_CLASSES_ROOT,Index)
        if Length(SubKeyName) > 0 and SubKeyName[1] == "."

            FileType = RegGetDefaultValue(HKEY_CLASSES_ROOT,SubKeyName)
            SubKeyName = DelStr(SubKeyName,1,1)

            if Length(FileType) > 0
                AddLine(Format("":-NAME_LEN,SubKeyName:-EXTS_LEN,FileType))
            endif
        endif
    endfor

    // sort list; extensions first, then by file type

    ClrScr()
    PutCtrStr("sorting",2)

    MarkColumn(1,EXTS_COL,NumLines(),EXTS_COL+EXTS_LEN)
    Sort(_IGNORE_CASE_)
    MarkColumn(1,TYPE_COL,NumLines(),TYPE_COL+TYPE_LEN)
    Sort(_IGNORE_CASE_)
    UnMarkBlock()

    // copy extensions belonging to the same file type to first line
    // when finished only one line per file type remains

    ClrScr()
    PutCtrStr("compressing result",2)

    BegFile()
    FileType = GetFileType()
    while Down()
        NextFileType = GetFileType()
        if NextFileType[1..5] == "CLSID"
            KillLine()
            Up()
        elseif FileType == NextFileType
            Extension = GetFileExts()
            KillLine()
            Up()
            Extension = GetFileExts() + " " + Extension
            Extension = SubStr(Extension,1,EXTS_FMT)
            GotoColumn(EXTS_COL)
            InsertText(Extension,_OVERWRITE_)
            BegLine()
        else
            FileType = NextFileType
        endif
    endwhile

    // remove file types that do not have shell entries (subkeys)

    ClrScr()
    PutCtrStr("removing non-shell entries",2)

    BegFile()
    loop
        if RegOpenCurrKey(FALSE,hKey)
            RegCloseKey(hKey)
            FileType = RegGetDefaultValue(HKEY_CLASSES_ROOT,GetFileType())
            if Length(FileType) > 0
                FileType = CharToOem(FileType)
            else
                FileType = "[[[" + GetFileType() + "]]]"
            endif
            InsertText(Format(FileType:-NAME_FMT),_OVERWRITE_)
            BegLine()
            if not Down()
                break
            endif
        else
            KillLine()
            if CurrLine() > NumLines()
                break
            endif
        endif
    endloop

    // clean up

    BegFile()
    PopWinClose()
    UpdateDisplay()
    if from_batch
        SetWindowTitle("TSE Pro-32 - " + WIN_TITLE)
    endif
    return (TRUE)
end

/****************************************************************************\
    file types list
\****************************************************************************/

proc ReallyQuit()
    if MsgBox(CAPTION,"Quit installation program?",_YES_NO_) == 1
        EndProcess(0)
    endif
end

menu TypesListMenu()
    x = 24
    y = 3
    history

    '&Info About File Type',            ListTypeInfo()
    '',,                                _MF_DIVIDE_
    '&Add Entry',                       AddOpenWithTse()
    '&Delete Entry',                    DeleteOpenWithTse()
    '&Find All Entries',                ListOpenWithTse()
    '',,                                _MF_DIVIDE_
    '&Uninstall',                       Uninstall()
    '',,                                _MF_DIVIDE_
    'Change &Menu Item',                ChangeMenuItem()
    'Change &TSE Command',              ChangeTsePath()
    '',,                                _MF_DIVIDE_
    '&Refresh',                         EnumerateFileTypes()
    '',,                                _MF_DIVIDE_
    "&Help",                            ShowDocFile("OpenWith.DOC")
    'E&xit',                            EndProcess()
end

keydef TypesListKeys
    <Escape>    ReallyQuit()
    <Enter>     ListTypeInfo()
    <Ctrl L>    RepeatFind()
    <Ctrl N>    RepeatFind()
    <Ins>       AddOpenWithTse()
    <Del>       DeleteOpenWithTse()
    <F1>        ShowDocFile("OpenWith.DOC")
    <F3>        ListOpenWithTse()
    <F5>        EnumerateFileTypes()
    <F10>       TypesListMenu()
end

proc TypesListInit()
    ListFooter(" {Enter}-Info  {Ins}-Ins  {F3}-Find  {F5}-Refresh  {F10}-Menu ")
    Enable(TypesListKeys)
    UnHook(TypesListInit)
end

/****************************************************************************\
    main program
\****************************************************************************/

proc main()
    integer bid

    // initialize

    from_batch = GetEnvStr("CalledFromBatch") == "YES"
    TseCmd = LoadDir(True) + ' "%1"'

    PushBlock()
    bid = GetBufferId()
    shcmd_buff = CreateTempBuffer()
    compr_buff = CreateTempBuffer()
    types_buff = CreateTempBuffer()

    // enum and display file types

    if shcmd_buff and compr_buff and types_buff
        EnumerateFileTypes()
        UpdateFrom200To210()
        Hook(_LIST_STARTUP_,TypesListInit)
        lList(WIN_TITLE,80,Query(ScreenRows),LIST_OPTS)
    else
        MsgBox("Error","Cannot allocate buffers",0)
    endif

    // clean up

    AbandonFile(shcmd_buff)
    AbandonFile(compr_buff)
    AbandonFile(types_buff)
    GotoBufferId(bid)
    PopBlock()

    if from_batch
        EraseDiskFile(CurrMacroFilename())
        AbandonEditor()
    else
        UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    endif
end

