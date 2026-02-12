/****************************************************************************\

    W95Edit.S

    Windows 95 replacement for the internal EditFile command.

    Overview:

    W95Edit allows you to load and save files using long filenames
    while running TSE in a DOS session in Windows 95.

    Keys:
            <none>

    Command Line Format:

    W95Edit [-s|-i|-w] [TSE-Switches] [name]

    where:
        none    EditFile
        -s      SaveAs
        -i      InsertBlock
        -w      SaveBlock
        name    name of file to be opened

    Usage notes:

    Command line switches must be passed in correct order, e.g.,
    W95Edit switches first, then TSE-switches, finally filename.

    Version         v1.00/10.05.96
    Copyright       (c) 1996 by DiK

    History
    v1.00/10.05.96  first release

    Limitations

    þ Cannot work with multiple filenames
    þ Filename completion not included (TAB on incomplete filename)

    W95Edit uses SAL strings to store path names, e.g. the longest path it
    can handle is 254 characters long. On the other hand, Windows 95 allows
    path names which are up to 260 characters long. This means you MUST NOT
    use path names which exceed the limit imposed by W95Edit or the macro
    will fail utterly most probably hanging TSE.

\****************************************************************************/

/****************************************************************************\
    mode constants
\****************************************************************************/

constant MODE_OPEN      =  0
constant MODE_SAVEAS    =  1
constant MODE_INSERT    =  2
constant MODE_SAVEBLOCK =  3

/****************************************************************************\
    global varibale
\****************************************************************************/

integer filelist                        // buffer (file list)
integer mode = MODE_OPEN                // flag (mode of operation)

string opts[64]                         // TSE command line options

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

integer proc ListFiles( string wild, integer dirs )
    integer rc
    integer attr
    string buff[23] = " "
    string info[50]
    string name[254] = ""

    // determine search attribute

    attr = _READONLY_
    if dirs
        attr = attr | _DIRECTORY_
    endif

    // find file names

    EmptyBuffer()
    if NewFindFirst(wild,attr,buff,name)
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
        return(FALSE)
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
        InsertText(info)
        InsertText(name)
    until not Up()

    // goto first non-directory entry

    MarkColumn(1,19,NumLines(),19)
    rc = lFind("[~<]","lgx")
    UnmarkBlock()

    return(rc)
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

string proc GetShortPathName( string name )
    register r
    integer len
    integer pntr_name, pntr_short
    string _name[255], _short[255] = ""

    _name = name + Chr(0)
    pntr_name = Addr(_name)
    pntr_short = Addr(_short)

    r.ax = 0x7160                       // Get Short Path Name
    r.cx = 0x8001                       // subst'ed short path names
    r.si = LoWord(pntr_name+2)
    r.ds = HiWord(pntr_name)
    r.di = LoWord(pntr_short+2)         // this _should_ be shorter than 80
    r.es = HiWord(pntr_short)
    Intr(0x21,r)

    PokeByte(pntr_short,255)
    len = Pos(Chr(0),_short)
    PokeByte(pntr_short,len-1)

    return(_short)
end

/****************************************************************************\
    helper macros
\****************************************************************************/

integer proc WriteFile( string name )
    integer rc, handle

    handle = fOpenEx(name)
    rc = handle > 0
    if rc
        fClose(handle)
    endif
    if rc
        Message("Creating new file...")
    else
        Alarm()
        Warn("Could not create new file")
    endif
    return(rc)
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

/****************************************************************************\
    load file(s)
\****************************************************************************/

proc LoadFile( string name )
    integer attr

    // load existing files

    attr = FileExistsEx(name)
    if attr == 0 or attr > 0 and (attr & ~_DIRECTORY_)
        EditFile(opts+GetShortPathName(name))
        return()
    endif

    // check name of new file

    if Length(GetToken(name," +,;=[]",1)) == Length(name)
    and Length(GetToken(name,".",1)) <= 8
    and Length(GetToken(name,".",2)) <= 3
    and Length(GetToken(name,".",3)) == 0
        EditFile(opts+name)
        return()
    endif

    // this is a new, long filename, e.g. create file

    if WriteFile(name)
        EditFile(opts+GetShortPathName(name))
        return()
    endif
end

proc LoadWild( string name )
    integer bid
    string file[254]

    if Query(LoadWildFromInside)
        bid = GotoBufferId(filelist)
        ListFiles(name,FALSE)
        BegFile()
        repeat
            file = GetText(29,CurrLineLen())
            GotoBufferId(bid)
            LoadFile(file)
            bid = GotoBufferId(filelist)
        until not Down()
        GotoBufferId(bid)
    else
        LoadFile(name)
    endif
end

/****************************************************************************\
    save file or block
\****************************************************************************/

proc SaveBlockAs( string name )
    integer attr

    attr = FileExistsEx(name)
    if attr == 0 or attr > 0 and (attr & ~_DIRECTORY_)
        SaveBlock(GetShortPathName(name))
    else
        if WriteFile(name)
            SaveBlock(GetShortPathName(name),_OVERWRITE_)
        endif
    endif
end

proc SaveFileAs( string name )
    PushBlock()
    UnmarkBlock()
    SaveBlockAs(name)
    PopBlock()
end

/****************************************************************************\
    file pick list
\****************************************************************************/

string proc AddPath( string name )
    string path[254]

    path = GetDirEx()
    if path[Length(path)] <> "\"
        path = path + "\"
    endif
    return( path + name )
end

integer proc ShowList( var string name )
    integer ok = FALSE
    integer width
    integer height
    string title[64]
    string old_name[254] = name

    AddLine(name)
    if lFind("{.@}\\","cgx")
        MarkFoundText()
        SetDir(GetMarkedText())
    endif
    KillLine()

    loop
        ListFiles(name,TRUE)
        title = AddPath(name)
        width = Query(ScreenCols)
        if NumLines() > Query(ScreenRows)
            height = Query(ScreenRows)
        else
            height = NumLines()
        endif
        ok = lList(title,width,height,_ENABLE_SEARCH_|_ENABLE_HSCROLL_)
        if ok
            name = GetText(29,CurrLineLen())
        endif
        if ok and CurrChar(19) == Asc("<")
            SetDir(name)
            name = "*.*"
        else
            break
        endif
    endloop

    if ok
        name = AddPath(name)
    else
        name = old_name
    endif

    return(ok)
end

/****************************************************************************\
    ask file name
\****************************************************************************/

integer proc IsWild( var string name )
    integer attr
    integer tokens
    string path[254]
    string file[254]

    name = Trim(name)

    if Length(name) == 0 or Length(name) == 2 and name[2] == ":"
        name = name + "*.*"
        return(TRUE)
    endif

    if Query(LoadWildFromInside)
        return(FALSE)
    endif

    if Pos("*",name) or Pos("?",name)
        if Pos(":",name) or Pos("\",name)
            tokens = NumTokens(name,"\")
            if tokens > 1
                file = GetToken(name,"\",tokens)
                path = SubStr(name,1,Pos(file,name)-1)
            else
                file = GetToken(name,":",2)
                path = GetToken(name,":",1) + ":"
            endif
            name = file
            if not SetDir(path)
                name = "*.*"
                Warn("Invalid directory")
            endif
        endif
        return(TRUE)
    endif

    attr = FileExistsEx(name)
    if attr == -2 or attr > 0 and (attr & _DIRECTORY_)
        if not SetDir(name)
            Warn("Directory does not exist!")
        endif
        name = "*.*"
        return(TRUE)
    endif

    return(FALSE)
end

integer proc AskName( var string name )
    string prompt[80]

    name = GetHistoryStr(_EDIT_HISTORY_,1)
    loop
        prompt = "File(s) to edit: [" + GetDirEx() + "]"
        if not Ask(prompt,name,_EDIT_HISTORY_)
            return(TRUE)
        endif
        if IsWild(name)
            if ShowList(name)
                return(FALSE)
            endif
        else
            break
        endif
    endloop
    return(FALSE)
end

/****************************************************************************\
    main program (helper)
\****************************************************************************/

integer proc Test( integer new_mode )
    if mode
        mode = MODE_OPEN
        Warn("W95Edit: Invalid command line. Using defaults.")
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
    integer rc
    integer bid = GetBufferId()
    string switch[32]
    string dir[254] = GetDirEx()
    string name[254] = Query(MacroCmdLine)

    // check command line

    while Length(name)
        switch = GetToken(name," ",1)
        case switch
            when "-s","/s"  Test(MODE_SAVEAS)
            when "-i","/i"  Test(MODE_INSERT)
            when "-w","/w"  Test(MODE_SAVEBLOCK)
            otherwise       break
        endcase
        name = LTrim(DelStr(LTrim(name),1,Length(switch)))
    endwhile

    while Length(name)
        switch = GetToken(name," ",1)
        if switch[1] in "-","/"
            opts = opts + switch + " "
        else
            break
        endif
        name = LTrim(DelStr(LTrim(name),1,Length(switch)))
    endwhile

    // check os version

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

    // call internal functions, if dos mode or old dos

    if not rc
        name = opts + name
        case mode
            when MODE_OPEN          EditFile(name)
            when MODE_SAVEAS        SaveAs(name)
            when MODE_INSERT        InsertFile(name)
            when MODE_SAVEBLOCK     SaveBlock(name)
        endcase
        return()
    endif

    // create buffer for file list

    filelist = CreateTempBuffer()
    if not filelist
        Warn("W95Edit: Cannot allocate work space")
        return()
    endif

    // determine file name

    rc = IsWild(name) and AskName(name)

    // clear work space

    GotoBufferId(bid)

    // file io

    if not rc
        case mode
            when MODE_OPEN          LoadWild(name)
            when MODE_SAVEAS        SaveFileAs(name)
            when MODE_INSERT        InsertFile(GetShortPathName(name))
            when MODE_SAVEBLOCK     SaveBlockAs(name)
        endcase
    endif

    // handle directories and clean up

    if not Query(PickFileChangesDir)
        SetDir(dir)
    endif
    AbandonFile(filelist)
    PurgeMacro(CurrMacroFilename())
end

