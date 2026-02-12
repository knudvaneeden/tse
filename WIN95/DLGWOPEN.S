/****************************************************************************\

    DlgWOpen.S

    Enhanced OpenFile command.

    Overview:

    This macro implements EditFile as a Windows 95 style dialog box. It
    allows you to load and save files using long names while running TSE
    in a DOS session in Windows 95. See on-line help for a more detailed
    description.

    Keys:
            <none>

    Command Line Format:

    DlgWOpen [-s|-i|-b] [-f] [-n]

    where:

        none    EditFile
        -s      SaveFileAs
        -i      InsertBlock
        -b      SaveBlock
        -f      list only files (don't list folders)
        -n      list only names (don't list file date/time and file size)

    Version         v1.00/08.05.96
    Copyright       (c) 1996 by DiK

    History

    v1.00/08.05.96  first release

    Limitations

    DlgWOpen uses SAL strings to store path names, e.g. the longest path it
    can handle is 254 characters long. On the other hand, Windows 95 allows
    path names which are up to 260 characters long. This means you MUST NOT
    use path names which exceed the limit imposed by DlgWOpen or the macro
    will fail utterly most probably hanging TSE. The dialog library imposes
    another limit yet. The maximum length of the text within an edit control
    is 128 characters which limits the size of filenames.

    Using DlgWOpen as "Save File As" closes the current file and re-opens
    it with its new name. The reason for this is that ChangeCurrFilename()
    doesn't work properly within the context of long filenames.

\****************************************************************************/

/****************************************************************************\
    mode constants
\****************************************************************************/

constant MODE_OPEN      =  0
constant MODE_SAVEAS    =  1
constant MODE_INSERT    =  2
constant MODE_SAVEBLOCK =  3

/****************************************************************************\
    events constants
\****************************************************************************/

constant KEY_MENU       =  0xFFF0
constant KEY_HELP       =  0xFFF1

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"
#include "msgbox.si"
#include "dlgwopen.si"
#include "dlgwopn1.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "dlgwopen.dlg"
#include "dlgwopn1.dlg"

/****************************************************************************\
    shared code
\****************************************************************************/

#include "dlgver.si"
#include "dlgrun.si"

/****************************************************************************\
    predefined file types
\****************************************************************************/

datadef FileTypes
    "*    All Files"
    "txt  Text"
    "doc  Text"
    "s    SAL"
    "d    SAL Dialog"
    "si   SAL Include"
    "pas  Pascal"
    "inc  Pascal Include"
    "c    C"
    "cpp  C++"
    "h    C Header"
    "asm  Assembler"
    "for  Fortran"
    "rc   Win Resource"
    "bat  Batch Files"
    "btm  Batch Files"
end

/****************************************************************************\
    global varibale
\****************************************************************************/

integer resource                        // buffer id (dialog resource)
integer filebuff                        // ditto (name list)
integer dirsbuff                        // ditto (dir list)
integer typebuff                        // ditto (ext list)
integer tempbuff                        // ditto (temp storage)

integer rightclk                        // flag (right click in file list)
integer dirty                           // ditto (options changed)
integer mode = MODE_OPEN                // ditto (mode of operation)

integer chk_bin                         // check (load binary)
integer chk_hex                         // ditto (display as hex list)
integer chk_chdir                       // ditto (change dir after load)
integer chk_wild                        // ditto (load wild from inside)

integer chk_noinfo                      // check (don't list additional info)
integer chk_nodirs                      // ditto (don't list directories)

string dir[254]                         // saved directory (global)
string dir1[254]                        // saved directory (folder combo)
string file[254] = "*.*"                // file name

string errmsg[] = "DlgWOpen: Invalid command line. Using defaults."

/****************************************************************************\
    forward definitions
\****************************************************************************/

forward proc IdCmbTypes( integer paint )

/****************************************************************************\
    help screens
\****************************************************************************/

helpdef DlgWOpenHelp
    title = "Help on Open File Dialog"
    width = 80
    height = 23
    x = 1
    y = 1

    ""
    " This dialog is used to load and save files."
    ""
    " Summary of commands:"
    ""
    " Ok          load or save the specified file"
    " Cancel      close the dialog box"
    ""
    "            go to parent directory (BackSpace)"
    "            insert a new folder (Ins)"
    " +           open options dialog (Ctrl Tab)"
    ""
    " To quickly load a file enter its name and press <Enter>. Alternatively, you"
    " can back-tab to the file list and select a file to be opened. If you enter"
    " an incomplete filename (a name that contains * and ?), the file list will be"
    " rescanned and will thereafter display only those entries in the current"
    " directory which match your wildcard specification. You can also use the"
    " Types drop down list to choose from some predefined file types to narrow"
    " your search. Names entered into the filename field can include full or"
    " partial paths and a drive letter."
    ""
    " Changing directories and drives:"
    ""
    " On default the dialog displays the contents of the current folder. If you"
    " want to open a file in some other folder, enter its name and press <Enter>."
    " The dialog will then display the contents of the specified folder."
    " Alternatively, you can tab to the folder drop down list and choose one of"
    " the listed folders. To expand the tree at a different branch right click"
    " the respective folder or use the GreyPlus key."
    ""
    " File management:"
    ""
    " The files list allows for a limited amount of file management. You can"
    " delete and rename files and insert new folders. To access the file"
    " management commands right click an item within the list box or press"
    " Alt-F10. (This works only while the files list box has the input focus.)"
    " The Load command loads a file into the editor without closing the dialog."
    " The View command, finally, allows you view a file before you load it."
    ""
end

helpdef DlgWOpenOptsHelp
    title = "Help on Open File Dialog Options"
    width = 80
    height = 23
    x = 1
    y = 1

    ""
    " This dialog is used to set additional options while loading or saving files."
    ""
    " Summary of commands:"
    ""
    " Ok          accept options"
    " Cancel      cancel changes"
    " Curr Dir    return to the current directory (also cancels changes)"
    " "
    " File Loading Option:"
    " "
    " These check boxes determine the kind of information displayed within the"
    " files list box. You can use the command line arguments -n and/or -f to check"
    " these switches at startup."
    " "
    " Names Only      do not display file creation date/time and file size"
    " Files Only      do not display folders, display files only"
    " "
    " File Loading Option:"
    " "
    " Some or all of the additional check boxes may be greyed. This means that they"
    " are currently not available because those options are meaningless within the"
    " current context."
    " "
    " Binary          load file in binary mode"
    " Hex Edit        switch to hex display after file is loaded"
    " Change Folder   make the directory which contains the file the current one"
    " Load Wild       do not narrow down file list, but load all matching files"
    ""
end

/****************************************************************************\
  ú binary module
\****************************************************************************/

binary "listfile.bin"
    integer proc NewFindFirst(
        string wild: cstrval,
        integer attr: word, string dta, string name )           : 0
    integer proc NewFindNext( string dta, string name )         : 3
    proc NewFindClose()                                         : 6
end

/****************************************************************************\
    list contents of current directory
\****************************************************************************/

proc ListFiles()
    integer bid
    integer attr
    string buff[23] = " "
    string info[50]
    string name[254] = ""

    // determine attributes

    bid = GotoBufferId(filebuff)
    attr = _READONLY_
    if not chk_nodirs
        attr = attr | _DIRECTORY_
    endif

    // find file names

    EmptyBuffer()
    if NewFindFirst(file,attr,buff,name)
        repeat
            if name <> "."
                AddLine(buff)
                GotoPos(24)
                if CurrChar(2) & _DIRECTORY_
                    InsertText(Chr(0))
                else
                    InsertText(Chr(1))
                endif
                InsertText(name)
            endif
        until not NewFindNext(buff,name)
    else
        return()
    endif
    NewFindClose()

    // sort pick buffer (_PICKSORT_ doesn't sort long filename field)

    MarkColumn(1,25,NumLines(),104)
    Sort(_IGNORE_CASE_)
    MarkColumn(1,24,NumLines(),24)
    Sort()

    // format list of filenames

    EndFile()
    repeat
        BegLine()
        info = DecodePickBuffer(GetText(1,23))
        info = Format(
            info[26:8],
            "  ",
            info[35:5],
            "  ",
            info[16:9],
            "  "
        )
        name = GetText(25,CurrLineLen()-24)
        KillToEol()
        if not chk_noinfo
            InsertText(info)
        endif
        InsertText(name)
    until not Up()

    // return to resource buffer

    GotoBufferId(bid)
end

/****************************************************************************\
    directory functions

    REMARK:
    this is sound, since maximum path size (minus name) is 246
\****************************************************************************/

string proc GetDirEx()
    register r
    integer len
    integer pntr
    string _name[255]

    _name = GetDrive() + ":\"
    pntr = Addr(_name)

    r.ax = 0x7147
    r.dx = 0
    r.si = LoWord(pntr+5)
    r.ds = HiWord(pntr)
    Intr(0x21,r)

    PokeByte(pntr,255)
    len = Pos(Chr(0),_name)
    PokeByte(pntr,len-1)

    return(_name)
end

integer proc SetDirEx( string name )
    register r
    integer pntr
    string _name[255]

    _name = name + Chr(0)
    pntr = Addr(_name)

    r.ax = 0x713B
    r.dx = LoWord(pntr+2)
    r.ds = HiWord(pntr)
    Intr(0x21,r)

    return (not (r.flags & _flCARRY_))
end

integer proc MakeDirEx( string name )
    register r
    integer pntr
    string _name[255]

    _name = name + Chr(0)
    pntr = Addr(_name)

    r.ax = 0x7139
    r.dx = LoWord(pntr+2)
    r.ds = HiWord(pntr)
    Intr(0x21,r)

    return (not (r.flags & _flCARRY_))
end

/****************************************************************************\
    file management functions

    REMARK:
    these functions will fail, if the long name is 255 characters plus
\****************************************************************************/

integer proc fOpenEx( string name )
    register r
    integer pntr
    string _name[255]

    _name = name + Chr(0)
    pntr = Addr(_name)

    r.ax = 0x716C                       // Extended Create or Open File
    r.bx = _OPEN_WRITEONLY_
    r.cx = _ARCHIVE_
    r.dx = 0x0012                       // truncate or create file
    r.si = LoWord(pntr+2)
    r.ds = HiWord(pntr)
    Intr(0x21,r)

    return(iif((r.flags & _flCARRY_),0,r.ax))
end

integer proc FileExistsEx( string name )
    register r
    integer pntr
    string _name[255]

    _name = name + Chr(0)
    pntr = Addr(_name)

    r.ax = 0x7143                       // Get or Set File Attributes
    r.bx = 0                            // GetFileAttributes
    r.dx = LoWord(pntr+2)
    r.ds = HiWord(pntr)
    Intr(0x21,r)

    if r.flags & _flCARRY_
        if r.ax == 5
            return(-2)
        else
            return(-1)
        endif
    endif
    return(r.cx)
end

string proc GetPathName( string name, integer sub )
    register r
    integer len
    integer pntr_name, pntr_full
    string _name[255], _full[255] = ""

    _name = name + Chr(0)
    pntr_name = Addr(_name)
    pntr_full = Addr(_full)

    r.ax = 0x7160                       // Get Path Name
    r.cx = sub                          // sub function: long or short names
    r.si = LoWord(pntr_name+2)
    r.ds = HiWord(pntr_name)
    r.di = LoWord(pntr_full+2)
    r.es = HiWord(pntr_full)
    Intr(0x21,r)

    if r.flags & _flCARRY_
        _full = ""
    else
        PokeByte(pntr_full,255)
        len = Pos(Chr(0),_full)
        PokeByte(pntr_full,len-1)
    endif

    return(_full)
end

string proc GetShortPathName( string name )
    return(GetPathName(name,0x8001))       // subst'ed short path names
end

string proc GetLongPathName( string name )
    return(GetPathName(name,0x8002))       // subst'ed long path names
end

integer proc DeleteFileEx( string name )
    register r
    integer pntr
    string _name[255]

    _name = name + Chr(0)
    pntr = Addr(_name)

    r.ax = 0x7141                       // Delete File
    r.cx = 0
    r.si = 0                            // no wildcards
    r.dx = LoWord(pntr+2)
    r.ds = HiWord(pntr)
    Intr(0x21,r)

    return (not (r.flags & _flCARRY_))
end

integer proc RenameFileEx( string new_name )
    register r
    integer old_pntr
    integer new_pntr
    string _old_name[255]
    string _new_name[255]

    _old_name = file + Chr(0)
    _new_name = new_name + Chr(0)
    old_pntr = Addr(_old_name)
    new_pntr = Addr(_new_name)

    r.ax = 0x7156                       // Rename File
    r.dx = LoWord(old_pntr+2)
    r.ds = HiWord(old_pntr)
    r.di = LoWord(new_pntr+2)
    r.es = HiWord(new_pntr)
    Intr(0x21,r)

    return (not (r.flags & _flCARRY_))
end

/****************************************************************************\
    helper functions
\****************************************************************************/

string proc GetName()
    if chk_noinfo
        return(GetText(1,CurrLineLen()))
    endif
    return(GetText(29,CurrLineLen()-28))
end

integer proc IsRoot()
    return(Length(GetDirEx()) == 3)
end

proc SetFolder()
    integer bid
    string dir[254]

    bid = GotoBufferId(dirsbuff)
    EmptyBuffer()
    dir = GetDirEx()
    if dir[Length(dir)] <> "\"
        dir = GetToken(dir,"\",NumTokens(dir,"\"))
    endif
    AddLine(dir)
    GotoBufferId(bid)
    ExecMacro(Format("DlgPaintCntrl ",ID_CMB_FOLDER))
end

integer proc SetDir( string name )
    if SetDirEx(name)
        if Length(name) > 1 and name[2] == ":"
            LogDrive(name[1])
        endif
        return(TRUE)
    endif
    return(FALSE)
end

integer proc GoDir( string name )
    if SetDir(name)
        SetFolder()
        IdCmbTypes(TRUE)
        ExecMacro(Format("DlgSetEnable ",ID_BTN_DIRUP," ",not IsRoot()))
        return(TRUE)
    endif
    ExecDialog(Format(
        "MsgBox ",
        Chr(MB_OK),
        Chr(MB_ERROR),
        Chr(CNTRL_CTEXT),"Directory does not exist!"
    ))
    return(FALSE)
end

integer proc WriteFile( integer save_buffer )
    integer rc, handle

    handle = fOpenEx(file)
    rc = handle > 0
    if rc
        if save_buffer
            rc = fWriteFile(handle,_OVERWRITE_)
        endif
        fClose(handle)
    endif
    if rc
        Message("Creating new file...")
    else
        Alarm()
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_OK),
            Chr(MB_ERROR),
            Chr(CNTRL_CTEXT),"Cannot create new file!"
        ))
    endif
    return(rc)
end

/****************************************************************************\
    load file(s)
\****************************************************************************/

integer proc LoadFile()
    integer rc = TRUE
    integer attr
    string opts[16] = ""

    if chk_bin
        opts = Format("-b",iif(chk_hex,16,64)," ")
    endif

    // load existing files

    attr = FileExistsEx(file)
    if attr == 0 or attr > 0 and (attr & ~_DIRECTORY_)
        EditFile(opts+GetShortPathName(file))
        goto common_exit
    endif

    // check name of new file

    if Length(GetToken(file," +,;=[]",1)) == Length(file)
    and Length(GetToken(file,".",1)) <= 8
    and Length(GetToken(file,".",2)) <= 3
    and Length(GetToken(file,".",3)) == 0
        EditFile(opts+file)
        goto common_exit
    endif

    // this is a new, long filename, e.g. create file

    if WriteFile(FALSE)
        EditFile(opts+GetShortPathName(file))
        goto common_exit
    endif

    rc = FALSE

common_exit:

    if rc and chk_hex
        DisplayMode(_DISPLAY_HEX_)
    endif

    return(rc)
end

proc LoadWild()
    integer bid

    if chk_wild
        bid = GotoBufferId(filebuff)
        chk_nodirs = TRUE
        ListFiles()
        BegFile()
        repeat
            file = GetName()
            GotoBufferId(bid)
            LoadFile()
            bid = GotoBufferId(filebuff)
        until not Down()
        GotoBufferId(bid)
    else
        LoadFile()
    endif
end

/****************************************************************************\
    save file or block
\****************************************************************************/

proc SaveFileAs()
    integer rc = TRUE
    integer attr
    integer line, col, row, xofs

    attr = FileExistsEx(file)
    if attr == 0 or attr > 0 and (attr & ~_DIRECTORY_)
        rc = YesNo("Overwrite existing file?") == 1
    endif
    if rc
        if WriteFile(TRUE)
            line = CurrLine()
            col  = CurrCol()
            row  = CurrRow()
            xofs = CurrXOffset()
            AbandonFile()
            EditFile(GetShortPathName(file))
            GotoLine(line)
            GotoColumn(col)
            ScrollToRow(row)
            GotoXOffset(xofs)
        endif
    endif
end

proc SaveBlockAs()
    integer attr

    attr = FileExistsEx(file)
    if attr == 0 or attr > 0 and (attr & ~_DIRECTORY_)
        SaveBlock(GetShortPathName(file))
    else
        if WriteFile(FALSE)
            SaveBlock(GetShortPathName(file),_OVERWRITE_)
        endif
    endif
end

/****************************************************************************\
    sub-class folder drop down list
    þ   GetSub              split directory string
    þ   GetListDir          compute chosen directory
    þ   AddSubDirs          insert sub-dirs into drop down list
    þ   ExpandThis          change current dir within drop down list
    þ   FolderKeys          additional hot keys
    þ   FolderHook          ditto
    þ   FolderComboInit     setup sub-class
    þ   FolderComboDone     cleanup (selection changed)
    þ   FolderComboClose    ditto (selection NOT changed)

    Remark: empty lines are inserted (and removed) only to prevent
            dialogs from reducing the length of the drop down list.
\****************************************************************************/

proc GetSub( var string sub, var string dir )
    integer p

    p = Pos("\",dir)
    if p == 0
        p = Length(dir) + 1
    endif
    sub = dir[1..p-1]
    dir = dir[p+1..Length(dir)]
end

string proc GetListDir()
    integer bid
    integer p
    integer level = 256
    string dir[254] = ""

    bid = GotoBufferId(dirsbuff)
    PushPosition()
    loop
        p = PosFirstNonWhite()
        if p == 1
            dir = GetText(1,2) + dir
            break
        endif
        if p < level
            level = p
            dir = "\" + GetText(p,CurrLineLen()-p+1) + dir
        endif
        Up()
    endloop
    if Length(dir) == 2
        dir = dir + "\"
    endif
    PopPosition()
    GotoBufferId(bid)
    return(dir)
end

proc AddSubDirs()
    integer rc = FALSE
    integer ilba
    integer first
    string lead[254]
    string buff[23] = " ", name[254] = ""

    first = PosFirstNonWhite()+1
    lead = Format("":first)

    GotoBufferId(tempbuff)
    EmptyBuffer()
    if NewFindFirst("*.*",_DIRECTORY_,buff,name)
        repeat
            if name[1] <> "." and (Asc(buff[2]) & _DIRECTORY_)
                rc = TRUE
                AddLine(Format(lead,name))
            endif
        until not NewFindNext(buff,name)
    endif
    NewFindClose()

    MarkColumn(1,first+1,NumLines(),first+80)
    Sort()
    MarkLine(1,NumLines())
    GotoBufferId(dirsbuff)

    if rc
        ilba = Set(InsertLineBlocksAbove,FALSE)
        MoveBlock()
        UnmarkBlock()
        Set(InsertLineBlocksAbove,ilba)
    endif
end

proc ExpandThis( integer mouse )
    integer level
    string dir[254]
    string curr[254]

    // get current dir

    if mouse
        GotoMouseCursor()
    endif
    dir = GetListDir()
    curr = GetText(1,CurrLineLen())

    // remove sub-tree and siblings

    level = PosFirstNonWhite()
    PushPosition()
    EndFile()
    repeat
        if level < PosFirstNonWhite()
        or level > 1 and level == PosFirstNonWhite()
            KillLine()
        endif
    until not Up()
    PopPosition()
    if level > 1
        InsertLine(curr)
    endif

    // add sub dirs

    if SetDir(dir)
        PushPosition()
        AddSubDirs()
        PopPosition()
    endif
end

keydef FolderKeys
    <Grey+>         ExpandThis(FALSE)
    <RightBtn>      ExpandThis(TRUE)
end

proc FolderHook()
    PushPosition()
    BegFile()
    while CurrChar() < 0
        KillLine()
    endwhile
    PopPosition()
    Enable(FolderKeys)
    Unhook(FolderHook)
end

proc FolderComboInit()
    integer bid
    integer level
    integer top, lft, wdt
    string dir[254], sub[254] = ""

    // save list position

    dir = Query(MacroCmdLine)
    lft = Val(GetToken(dir," ",1)) - 9
    top = Val(GetToken(dir," ",2))
    wdt = Val(GetToken(dir," ",3)) + 9

    // copy drive list

    ExecDialog("DriveLst")
    bid = GotoBufferId(Val(Query(MacroCmdLine)))
    MarkLine(1,NumLines())
    GotoBufferId(dirsbuff)
    EmptyBuffer()
    CopyBlock()
    UnmarkBlock()

    // add directory tree of current drive

    dir1 = GetDirEx()
    dir = dir1
    lFind(dir[1],"gi^")
    level = 0
    GetSub(sub,dir)
    while Length(dir)
        GetSub(sub,dir)
        level = level + 2
        AddLine(Format("":level,sub))
    endwhile
    AddSubDirs()

    // fill buffer

    if NumLines() < 12
        PushPosition()
        BegFile()
        do 12-NumLines() times
            InsertLine("")
        enddo
        PopPosition()
    endif

    // set list position

    Set(MacroCmdLine,Format(lft," ",top," ",wdt," ",12))
    GotoBufferId(bid)

    // add custom keys to drop down list

    Hook(_LIST_STARTUP_,FolderHook)
end

proc FolderComboDone()
    if GoDir(GetListDir())
        dir1 = ""
    endif
end

proc FolderComboClose()
    if Length(dir1)
        GoDir(dir1)
    endif
end

/****************************************************************************\
    sub-class files list box
    þ   ViewFile            pre-view a file
    þ   DeleteFile          delete current file
    þ   RenameFile          rename current file
    þ   ListMenu            menu definition
    þ   IdListMenu          pop up local list menu
    þ   FilesBoxFunction    sub-class function
\****************************************************************************/

proc ViewFile()
    integer fileid
    integer attr
    integer rc = TRUE
    integer bid = GetBufferId()

    fileid = GetBufferId(GetShortPathName(file))
    if fileid
        GotoBufferId(fileid)
    else
        attr = FileExistsEx(file)
        rc = attr == 0 or attr > 0 and (attr & ~_DIRECTORY_)
        rc = rc and LoadFile()
    endif

    if rc
        PushPosition()
        lList(CurrFilename(),Query(ScreenCols),
            Query(ScreenRows),_ENABLE_SEARCH_|_ENABLE_HSCROLL_)
        PopPosition()
        if fileid == 0
            AbandonFile()
        endif
    else
        Alarm()
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_OK),
            Chr(MB_ERROR),
            Chr(CNTRL_CTEXT),"Cannot load file!"
        ))
    endif

    GotoBufferId(bid)
end

proc DeleteFile()
    integer bid
    integer line, row

    bid = GotoBufferId(filebuff)
    row = CurrRow()
    line = CurrLine()
    GotoBufferId(bid)

    ExecDialog(Format(
        "MsgBox ",
        Chr(MB_YESNO),
        Chr(MB_PROMPT),
        Chr(CNTRL_CTEXT),"Do you really want to delete the file?"
    ))
    if Val(Query(MacroCmdLine)) == ID_YES
        if not DeleteFileEx(file)
            Alarm()
            ExecDialog(Format(
                "MsgBox ",
                Chr(MB_OK),
                Chr(MB_ERROR),
                Chr(CNTRL_CTEXT),"Cannot delete file!"
            ))
        endif
    endif

    IdCmbTypes(FALSE)
    bid = GotoBufferId(filebuff)
    if line > NumLines()
        line = NumLines()
    endif
    GotoLine(line)
    ScrollToRow(row)
    file = GetName()
    GotoBufferId(bid)
    ExecMacro(Format("DlgPaintCntrl ",ID_LST_FILES))
    ExecMacro(Format("DlgSetTitle ",ID_EDT_NAME," ",file))
end

proc RenameFile()
    integer bid, ok
    string name[254] = file

    ExecDialog(Format(
        "InpBox ",
        0,Chr(13),
        "Rename File",Chr(13),
        "Enter new filename:",Chr(13),
        name,Chr(13)
    ))
    name = Query(MacroCmdLine)
    ok = name[1] == Chr(ID_OK)
    if ok
        name = name[2..Length(name)]
        if not RenameFileEx(name)
            Alarm()
            ExecDialog(Format(
                "MsgBox ",
                Chr(MB_OK),
                Chr(MB_ERROR),
                Chr(CNTRL_CTEXT),"Cannot rename file!"
            ))
            return()
        endif
    else
        return()
    endif

    IdCmbTypes(FALSE)
    bid = GotoBufferId(filebuff)
    if lFind("  "+name+"$","gx")
        ScrollToRow(5)
    endif
    file = GetName()
    GotoBufferId(bid)
    ExecMacro(Format("DlgPaintCntrl ",ID_LST_FILES))
    ExecMacro(Format("DlgSetTitle ",ID_EDT_NAME," ",file))
end

menu ListMenu()
    "&Open   <Enter>",      PushKey(<Enter>)
    "",, divide
    "&View",                ViewFile()
    "&Load",                LoadFile()
    "",, divide
    "&Delete",              DeleteFile()
    "&Rename",              RenameFile()
end

proc IdListMenu()
    integer bid = GetBufferId()

    if rightclk
        Set(X1,Query(MouseX))
        Set(Y1,Query(MouseY))
    else
        Set(X1,10)
        Set(Y1,7)
    endif
    Set(Key,<RightBtn>)
    ListMenu()
    GotoBufferId(bid)
    Set(Key,KEY_NOTHING)
end

proc FilesBoxFunction()
    case Query(Key)
        when KEY_MENU
            IdListMenu()
        when <RightBtn>
            rightclk = 3
            Set(Key,<LeftBtn>)
            PushKey(<Alt F10>)
        when <Del>
            Set(Key,KEY_BREAK)
            DeleteFile()
        when <F2>
            Set(Key,KEY_BREAK)
            RenameFile()
        when <Alt F10>
            Set(Key,KEY_BREAK)
            PushKey(KEY_MENU)
    endcase
    rightclk = Max(0,rightclk-1)
end

/****************************************************************************\
    options dialog
\****************************************************************************/

public proc WOpenOptsDataInit()
    ExecMacro(Format("DlgSetData ",ID_CHK_NOINFO," ",chk_noinfo))
    ExecMacro(Format("DlgSetData ",ID_CHK_NODIRS," ",chk_nodirs))
    ExecMacro(Format("DlgSetData ",ID_CHK_BIN," ",chk_bin))
    ExecMacro(Format("DlgSetData ",ID_CHK_HEX," ",chk_hex))
    ExecMacro(Format("DlgSetData ",ID_CHK_CHDIR," ",chk_chdir))
    ExecMacro(Format("DlgSetData ",ID_CHK_LDWILD," ",chk_wild))

    if mode <> MODE_OPEN
        ExecMacro(Format("DlgSetEnable ",ID_CHK_BIN," ",0))
        ExecMacro(Format("DlgSetEnable ",ID_CHK_HEX," ",0))
        ExecMacro(Format("DlgSetEnable ",ID_CHK_LDWILD," ",0))
        if mode <> MODE_SAVEAS
            ExecMacro(Format("DlgSetEnable ",ID_CHK_CHDIR," ",0))
        endif
    endif
end

integer proc GetOpt( integer id )
    ExecMacro(Format("DlgGetData ",id))
    return(Val(Query(MacroCmdLine)))
end

public proc WOpenOptsDataDone()
    integer new_noinfo
    integer new_nodirs

    if CurrChar(POS_ID) == ID_OK
        new_noinfo = GetOpt(ID_CHK_NOINFO)
        new_nodirs = GetOpt(ID_CHK_NODIRS)
        chk_bin    = GetOpt(ID_CHK_BIN)
        chk_hex    = GetOpt(ID_CHK_HEX)
        chk_chdir  = GetOpt(ID_CHK_CHDIR)
        chk_wild   = GetOpt(ID_CHK_LDWILD)
        dirty = new_noinfo <> chk_noinfo or new_nodirs <> chk_nodirs
        chk_noinfo = new_noinfo
        chk_nodirs = new_nodirs
    endif
end

proc IdBtnCurrDir()
    dirty = TRUE
    SetDir(dir)
    ExecMacro("DlgTerminate")
end

proc IdBtnDrives()
    ExecDialog("ScanDrives")
    ExecMacro("DlgTerminate")
end

public proc WOpenOptsBtnDown()
    case CurrChar(POS_ID)
        when ID_OK              ExecMacro("DlgTerminate")
        when ID_BTN_DRIVES      IdBtnDrives()
        when ID_BTN_CURRDIR     IdBtnCurrDir()
        when ID_HELP            QuickHelp(DlgWOpenOptsHelp)
    endcase
end

proc IdOpts()
    integer resource
    integer rc
    integer bid
    integer line, row

    bid = GotoBufferId(filebuff)
    row = CurrRow()
    line = CurrLine()
    GotoBufferId(bid)

    dirty = FALSE
    resource = CreateTempBuffer()
    rc = resource and InsertData(dlgwopn1) and ExecDialog("dialog wopenopts")
    GotoBufferId(bid)
    AbandonFile(resource)

    if rc
        if dirty
            SetFolder()
            IdCmbTypes(FALSE)
            bid = GotoBufferId(filebuff)
            if Val(Query(MacroCmdLine)) == ID_BTN_CURRDIR
                BegFile()
            else
                if line > NumLines()
                    line = NumLines()
                endif
                GotoLine(line)
                ScrollToRow(row)
            endif
            file = GetName()
            GotoBufferId(bid)
            ExecMacro(Format("DlgPaintCntrl ",ID_LST_FILES))
            ExecMacro(Format("DlgSetTitle ",ID_EDT_NAME," ",file))
        endif
    else
        Warn("DlgWOpen: Error executing options dialog")
    endif
end

/****************************************************************************\
    control response functions
    þ   IdCmbTypes      set wildcard according to file type
    þ   IdLstFiles      update edit control with current filename
    þ   IdDirUp         go to parent folder
    þ   IdDirNew        make a new folder
\****************************************************************************/

proc IdCmbTypes( integer paint )
    integer bid

    bid = GotoBufferId(typebuff)
    file = "*." + RTrim(GetText(1,3))
    GotoBufferId(bid)
    ListFiles()
    if paint
        ExecMacro(Format("DlgPaintCntrl ",ID_LST_FILES))
        ExecMacro(Format("DlgSetTitle ",ID_EDT_NAME," ",file))
    endif
end

proc IdLstFiles()
    integer bid

    bid = GotoBufferId(filebuff)
    file = GetName()
    GotoBufferId(bid)
    ExecMacro(Format("DlgSetTitle ",ID_EDT_NAME," ",file))
end

proc IdDirUp()
    GoDir("..")
    if IsRoot()
        ExecMacro(Format("DlgExecCntrl ",ID_LST_FILES))
    endif
end

proc IdDirNew()
    integer ok
    string dir[254] = ""

    ExecDialog(Format(
        "InpBox ",
        0,Chr(13),
        "New Folder",Chr(13),
        "Enter name of new folder:",Chr(13),
        Chr(13)
    ))
    dir = Query(MacroCmdLine)
    ok = dir[1] == Chr(ID_OK)
    if ok
        dir = dir[2..Length(dir)]
        if MakeDirEx(dir)
            GoDir(dir)
        else
            Alarm()
            ExecDialog(Format(
                "MsgBox ",
                Chr(MB_OK),
                Chr(MB_ERROR),
                Chr(CNTRL_CTEXT),"Cannot create new folder!"
            ))
        endif
    endif
end

/****************************************************************************\
    ok button
\****************************************************************************/

proc IdOk()
    integer attr
    integer tokens
    string dir[254], name[254]

    // get the specified file name

    ExecMacro(Format("DlgGetTitle ",ID_EDT_NAME))
    file = Trim(Query(MacroCmdLine))

    // check for an empty line

    if Length(file) == 0
        ExecMacro(Format("DlgExecCntrl ",ID_EDT_NAME))
        Alarm()
        return()
    endif

    // check for wildcards and narrow down file list

    if Pos("*",file) or Pos("?",file)
        if Pos(":",file) or Pos("\",file)
            tokens = NumTokens(file,"\")
            if tokens > 1
                name = GetToken(file,"\",tokens)
                dir = SubStr(file,1,Pos(name,file)-1)
            else
                name = GetToken(file,":",2)
                dir = GetToken(file,":",1) + ":"
            endif
            file = name
            if GoDir(dir)
                file = name
                ExecMacro(Format("DlgSetTitle ",ID_EDT_NAME," ",file))
            else
                ExecMacro(Format("DlgExecCntrl ",ID_EDT_NAME))
                return()
            endif
        endif
        if chk_wild
            ExecMacro(Format("DlgTerminate ",ID_OK))
        else
            ListFiles()
            ExecMacro(Format("DlgPaintCntrl ",ID_LST_FILES))
            ExecMacro(Format("DlgExecCntrl ",ID_EDT_NAME))
        endif
        return()
    endif

    // if the file name is a directory, let's go there

    if Length(file) == 2 and file[2] == ":"
        file = file + "."
    endif

    attr = FileExistsEx(file)
    if attr == -2 or attr > 0 and (attr & _DIRECTORY_)
        if GoDir(file)
            ExecMacro(Format("DlgExecCntrl ",ID_LST_FILES))
        else
            ExecMacro(Format("DlgExecCntrl ",ID_EDT_NAME))
        endif
        return()
    endif

    // otherwise, say bye and go home

    ExecMacro(Format("DlgTerminate ",ID_OK))
end

/****************************************************************************\
    custom hot keys
\****************************************************************************/

integer proc CheckHotKeys()
    integer cntrl

    if Query(Key) == <Ctrl Tab>
        IdOpts()
        Set(Key,KEY_NOTHING)
        return(FALSE)
    endif

    if CurrChar(POS_ID) <> ID_EDT_NAME
        if LoByte(Query(Key)) == Asc("?")
            Set(Key,KEY_HELP)
        endif
        if Query(Key) in <Backspace>,<Ins>,<KEY_HELP>
            case Query(Key)
                when <Backspace>
                    if IsRoot()
                        return(FALSE)
                    endif
                    cntrl = ID_BTN_DIRUP
                when <Ins>
                    cntrl = ID_BTN_DIRNEW
                when KEY_HELP
                    cntrl = ID_HELP
            endcase
            ExecMacro(Format("DlgExecCntrl ",cntrl))
            Set(Key,KEY_BREAK)
            PushKey(<Enter>)
            return(FALSE)
        endif
    endif

    return(TRUE)
end

/****************************************************************************\
    message response functions
    þ   Event           custom hot keys
    þ   AnchorList      anchor search in type and drive lists
    þ   DropDown        fill folder drop down list
    þ   CloseUp         reset folder drop down list
    þ   SetFocus        ok in dir list and open type drive lists
    þ   SelChanged      handle selection changes in file list
    þ   DblClick        double clicks within list boxes
    þ   BtnDown         push button actions
\****************************************************************************/

public proc WOpenEvent()
    if CheckHotKeys() and CurrChar(POS_ID) == ID_LST_FILES
        FilesBoxFunction()
    endif
end

public proc WOpenAnchorList()
    if CurrChar(POS_ID) == ID_CMB_TYPES
        Set(MacroCmdLine,"1")
    endif
end

public proc WOpenDropDown()
    if CurrChar(POS_ID) == ID_CMB_FOLDER
        FolderComboInit()
    endif
end

public proc WOpenCloseUp()
    if CurrChar(POS_ID) == ID_CMB_FOLDER
        FolderComboClose()
    endif
end

public proc WOpenSetFocus()
    if CurrChar(POS_ID) == ID_LST_FILES
        IdLstFiles()
    endif
end

public proc WOpenSelChanged()
    case CurrChar(POS_ID)
        when ID_LST_FILES   IdLstFiles()
        when ID_CMB_TYPES   IdCmbTypes(TRUE)
        when ID_CMB_FOLDER  FolderComboDone()
    endcase
end

public proc WOpenDblClick()
    if CurrChar(POS_ID) == ID_LST_FILES and rightclk == 0
        IdOk()
    endif
end

public proc WOpenBtnDown()
    case CurrChar(POS_ID)
        when ID_OK              IdOk()
        when ID_BTN_DIRUP       IdDirUp()
        when ID_BTN_DIRNEW      IdDirNew()
        when ID_BTN_OPTS        IdOpts()
        when ID_HELP            QuickHelp(DlgWOpenHelp)
    endcase
end

/****************************************************************************\
    initialize dialog data
\****************************************************************************/

public proc WOpenDataInit()
    string name[254] = file

    if CheckVersion("DlgWOpen",1,20)
        ExecMacro("DlgTerminate")
        return()
    endif

    if not (ExecDialog("DriveLst") and Val(Query(MacroCmdLine)))
        ExecMacro("DlgTerminate")
        return()
    endif

    file = "*.*"
    ListFiles()
    SetFolder()
    file = name

    ExecMacro(Format("DlgSetTitle ",ID_EDT_NAME," ",file))
    ExecMacro(Format("DlgSetData ",ID_EDT_NAME," ",_EDIT_HISTORY_))
    ExecMacro(Format("DlgSetData ",ID_LST_FILES," ",filebuff))
    ExecMacro(Format("DlgSetData ",ID_CMB_TYPES," ",typebuff))
    ExecMacro(Format("DlgSetData ",ID_CMB_FOLDER," ",dirsbuff))
    ExecMacro(Format("DlgSetEnable ",ID_BTN_DIRUP," ",not IsRoot()))

    if mode <> MODE_OPEN
        case mode
            when MODE_SAVEAS
                ExecMacro("DlgSetTitle 0 Save File As")
            when MODE_INSERT
                ExecMacro("DlgSetTitle 0 Insert File As Block")
            when MODE_SAVEBLOCK
                ExecMacro("DlgSetTitle 0 Save Block To File")
        endcase
    endif

    ExecMacro(Format("DlgExecCntrl ",ID_EDT_NAME))
end

/****************************************************************************\
    retrieve dialog data
\****************************************************************************/

public proc WOpenDataDone()
    ExecMacro(Format("DlgGetTitle ",ID_EDT_NAME))
end

/****************************************************************************\
    main program (helper)
\****************************************************************************/

integer proc Test( integer new_mode )
    if mode
        mode = MODE_OPEN
        Warn(errmsg)
        return(FALSE)
    endif
    mode = new_mode
    return(TRUE)
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    register r
    integer i, rc
    integer bid = GetBufferId()
    string cmd[16] = Query(MacroCmdLine)

    // check dos version

    r.ax = 0x3000                           // get dos version
    Intr(0x21,r)
    rc = LoByte(r.ax) >= 7
    if rc
        r.ax = 0x4A33                       // check for ms-dos
        Intr(0x2F,r)
        rc = r.ax == 0
        if rc
            r.ax = 0x1600                   // get windows version
            Intr(0x2F,r)
            rc = r.ax <> 0x1600 and LoByte(r.ax) < 0x80 and LoByte(r.ax) >= 4
        endif
    endif

    // call old dialog, if dos mode or old dos

    if not rc
        ExecDialog("dlgopen "+Query(MacroCmdLine))
        PurgeMacro(CurrMacroFilename())
        return()
    endif

    // init global vars

    PushBlock()
    dir = GetDirEx()
    chk_wild = Query(LoadWildFromInside)
    chk_chdir = Query(PickFileChangesDir)
    file = GetLongPathName(CurrFilename())
    file = GetToken(file,"\",NumTokens(file,"\"))

    // check command line

    for i = 1 to NumTokens(cmd," ")
        case GetToken(cmd," ",i)
            when "-s"   Test(MODE_SAVEAS)
            when "-i"   Test(MODE_INSERT)
            when "-b"   Test(MODE_SAVEBLOCK)
            when "-n"   chk_noinfo = TRUE
            when "-f"   chk_nodirs = TRUE
            otherwise   Warn(errmsg) break
        endcase
    endfor

    // allocate work space and exec dialog

    filebuff = CreateTempBuffer()
    dirsbuff = CreateTempBuffer()
    tempbuff = CreateTempBuffer()
    typebuff = CreateTempBuffer()

    if filebuff and dirsbuff and tempbuff and typebuff
        rc = InsertData(FileTypes)
        if rc
            resource = CreateTempBuffer()
            rc = resource
                and InsertData(dlgwopen) and ExecDialog("dialog wopen")
        endif
    endif

    GotoBufferId(bid)
    PopBlock()

    // check return code and open/save file

    if rc
        rc = Val(Query(MacroCmdLine)) == ID_OK
    else
        Warn("DlgWOpen: Error executing open dialog")
    endif

    if rc
        AddHistoryStr(file,_EDIT_HISTORY_)
        case mode
            when MODE_OPEN          LoadWild()
            when MODE_SAVEAS        SaveFileAs()
            when MODE_INSERT        InsertFile(GetShortPathName(file))
            when MODE_SAVEBLOCK     SaveBlockAs()
        endcase
        if not chk_chdir
            SetDir(dir)
        endif
    endif

    // clear work space

    AbandonFile(resource)
    AbandonFile(typebuff)
    AbandonFile(tempbuff)
    AbandonFile(dirsbuff)
    AbandonFile(filebuff)

    // purge self

    PurgeMacro(CurrMacroFilename())
    UpdateDisplay(_HELPLINE_REFRESH_)
end

