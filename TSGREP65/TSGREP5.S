 /*************************************************************************
               TSGREP ... A regular expression line extractor ... 6.5

 File TSGREP5: Does all file loading, including recursive and list loads.
               7861 bytes, compiled (10-24-95)
 **************************************************************************/

#INCLUDE ['tsgrep.inc']

/**************************************************************************
    DECLARATIONS - Constant, Integer, String
 **************************************************************************/

STRING
    line[255],
    name[MAXFN],
    file_sep_char[1]  = '^'         // :U: file separator character
                                    //     for cmd line operation
                                    // WARNING: Do not set to ' '.
                                    // ' ' is automatically supported
                                    // for interactive operation.)
INTEGER
    abort = FALSE

/**************************************************************************
    DECLARATIONS - Forward Procedures and Menus
 **************************************************************************/

forward integer proc          JustYesNo             // YesNo w/o escape, cancel
                                    (STRING s)
forward         menu          JYN()                 // see above
forward         proc          build_list_of_filespecs()
forward integer proc          load_files()
forward integer proc          load_recursively(STRING arg)
forward integer proc          mFileExists(STRING line)
forward proc                  check_for_abort(INTEGER from)

/**************************************************************************
 **************************************************************************
    PROCEDURES
 **************************************************************************
 **************************************************************************/

/**************************************************************************
        Build List of File Specs
 **************************************************************************/
proc                        build_list_of_filespecs()
    STRING
        filespec[MAXSPEC] = infile,
        prev_path[MAXFN - 12]='',
        prev_drive[2]=''

    statusBar('Building filespec list...',0,0,IN_WINDOW)
    if pause
        Delay(pause)
    endif

    filespec = Trim(filespec)

    while pos(' ', filespec)                        // convert spaces to file sep char
        line = mSubStr(filespec, ' ', -1, 0)
        line = line + file_sep_char
        filespec = line + mSubStr(filespec, ' ', +1, 0)
    endwhile

    while Length(filespec)
        line = mSubStr(filespec, file_sep_char, -1, 0) // first spec
        /*
           Assign previous filespec's path and drive if none
        */
        if SplitPath(line, _drive_ | _path_) == ''
            line = prev_drive + prev_path + line
        endif
        if SplitPath(line , _drive_) == ''
            line = prev_drive + line
        endif

        prev_drive = SplitPath(line , _drive_)
        prev_path =  SplitPath(line , _path_)
        /*
            Add . to end of filespec without extensions.
            To fix problem with TSGREP hanging up reported
            by Eric Stork, 01-02-95
        */
        if not Pos('.', line)           // 01-02-95
            line = trim(line) + '.'     // 01-02-95
        endif                           // 01-02-95
        AddLine(line, list_of_filespecs)

        filespec = mSubStr(filespec, file_sep_char, +1, 0)
        filespec = trim(filespec)
    endwhile
end

/***********************************************************************
 The following commands are taken from release v1.00a of SemWare's wp.s:
binary ['wptsgrep.bin']
    integer proc _CD(string dir) : 0
//    integer proc CurrDir(var string s) : 3
    integer proc _ff(string path, var string ffblk, integer attribs) : 6
    integer proc _fn(var string ffblk) : 9
    integer proc _SetAttrib(string file, integer attrib) : 12
    integer proc _Rename(string oldname, string newname) : 15
end
 ***********************************************************************/


/**************************************************************************
        Check for Abort
 **************************************************************************/
proc                        check_for_abort(INTEGER mode)
    abort = FALSE
    if KeyPressed() AND GetKey() == <escape>
        if getFlag(PAUSE_LENGTH) <> 0          // if Delay is set...
            statusBar('setting Delay to 0',0,0,IN_WINDOW)
            Delay(pause)
            setFlag(PAUSE_LENGTH, 0)
            pause = FALSE
        else
            if mode == 1 or mode == 2
                Set(X1,3) Set(Y1,3)
                a = Query(attr)
                if NOT JustYesNo('Abort at this stage will leave extra files loaded. Abort?')
                    Set(Attr,a)
                    return()
                endif
                Set(Attr,a)
                abort = TRUE
                return()
            endif
            if getFlag(TSGREP_MODE) == CMDLINE
                PushKey(<enter>)         // bypasses 'press any key'
            endif
            abort = TRUE
                                     // Avoid going back to where
        endif                        // check_for_abort was called
    endif
end

/**************************************************************************
        JustYesNo()
 **************************************************************************/
menu                        JYN()
    /*
        A YesNo that allows no Escape or Cancel.
    */
    NoEscape
    '&Yes'
    '&No'
end

/**************************************************************************
        Load_Files()
 **************************************************************************/
integer proc                load_files()
    integer
        ttl,
        ttlloaded
    statusBar('Adding files to ring', 0, 0,IN_WINDOW)
    GotoBufferID(list_of_filespecs)
    BegFile()
    ttl = NumLines()
    PushBlock()
    repeat
        check_for_abort(1)
        if abort == TRUE
            PopBlock()
            return(FALSE)
        endif
        BegFile()
        Statusbar('Adding files to ring', ttl - NumLines(), ttl, IN_WINDOW)
        line = GetText(1, CurrLineLen())    // get spec
        DelLine()
        if Pos(recurse_char, line)          // do recursive loading
            ttlloaded = ttl - NumLines()
            PushPosition()
            if not load_recursively(line)          // (adds more lines to l_o_f)
                return(FALSE)
            endif
            PopPosition()
            ttl = NumLines() + ttlloaded
        elseif Pos(list_file_char, line)    // read in the list file
            AddLine()                       // to l_o_f
            if not InsertFile(line)
                warn('Cannot find ' , line)
            else
                /*
                    increase total by number of lines added
                */
                ttl = ttl + Query(BlockEndLine) - Query(BlockBegLine) + 1
            endif
            paint_message(getting_files_line, 4, "Getting list from: [" + name + ']' ,42, 1)
        else
            if mFileExists(line)

                paint_message(loading_files_line, 0, "Loading files from: [" +  line + ']' ,54, 1)
                AddFiletoRing(line)
                paint_message(files_loaded_line, 1, "Files Inventoried: ["+Str(NumFiles())+"] ",54, 1)
                if pause
                    Delay(pause)
                endif
            endif
        endif
        if pause
            Delay(pause)
        endif
        GotoBufferID(list_of_filespecs)
    until NumLines() == 0
    paint_message(loading_files_line, 0, "Loading files from: [ ]" ,54, 0)
    PopBlock()

    return(TRUE)
end

/**************************************************************************
        Load_Recursively(arg)   Arg is filespec
 **************************************************************************/
integer proc                load_recursively(STRING arg)
    /*
        Add fully-qualified file specs to the list_of_files
        buffers.
        Does this for every sub of the specified directory
        that has any files meeting the file spec.
    */
    STRING
        dir[MAXSPEC]        = SplitPath(arg, _DRIVE_ | _PATH_ ),
        filespec[MAXSPEC+1] = '\' + SubStr(SplitPath(arg, _NAME_  | _EXT_  ),
                                           1,
                                           Length(SplitPath(arg, _NAME_  | _EXT_  ))-1),
        pfso[7] = Set(PickFileSortOrder, 'f')
    INTEGER
        dir_counter = 0,
        temp_id,            // for picklist build
        pff = Set(PickFileFlags, _ADD_DIRS_ | _ADD_SLASH_ | _DIRS_AT_TOP_)

    PushPosition()
    temp_id = CreateTempBuffer()
    statusBar('Recursive loading...',0,0,IN_WINDOW)
    AddLine(mSubStr(arg, recurse_char, -1, 0), list_of_filespecs)

top:
    paint_message(getting_dirs_line, 0, "Finding Dirs Under: [" + dir + ']' ,54, 1)
    time = timer(GET_TIME)
    paint_message(time_line, 0, time+']',14, 0)
    BuildPickBuffer(dir + iif(dirs_with_extensions, '*.*', '*.')
                     , _DIRECTORY_)
    BegFile()
    while GetText(11,1) == '\'
        if GetTexT(12,2) == '..'        // avoid parent
           goto dont_do_it
        endif
        dir_counter = dir_counter + 1
        check_for_abort(1)
        if abort == TRUE
            AbandonFile(temp_ID)
            PopPosition()
            pfso = Set(PickFileSortOrder, pfso)
            pff = Set(PickFileFlags, pff)
            return(FALSE)
        endif
        line = dir + trim(GetText(12,8)) + iif(GetText(21,1)<>' ', '.'+trim(GetText(21,3)), '')
        paint_message(dirs_found_line, 8, "Dirs Found: ["+Str(dir_counter)+"] " + line, 54,0)
        AddLine(line, dirs_to_be_processed)
        AddLine(line + filespec, list_of_filespecs)
        if getFlag(MAKE_LIST_OF_DIRS)
           addline(line, list_of_dirs )
        endif
     dont_do_it:
        if not Down()
           goto no_more
        endif
    endwhile

  no_more:
    /*
        repeat for any directories left
        to process
    */
    GotoBufferId(dirs_to_be_processed)
    if NumLines()
        BegFile()
        dir = GetText(1,CurrLineLen()) + '\'    // set next dir to process
        DelLine()                               // delete it from list
        Gotobufferid(temp_ID)
        EmptyBuffer()
        goto top                                // loop around
    endif

    AbandonFile(temp_ID)
    PopPosition()

    pfso = Set(PickFileSortOrder, pfso)
    pff = Set(PickFileFlags, pff)
    return(TRUE)

end

/**************************************************************************
        mFileExists()
            checks default extensions
 **************************************************************************/
integer         proc        mFileExists(STRING fn)
    STRING
        exts[39] = Query(DefaultExt) + Chr(0)
    if FileExists(fn)
        return(TRUE)
    elseif NOT Pos('.', fn)                 // if no '.', try
        while length(exts)                  //  default extensions
            if FileExists(fn + SubStr(exts, 1, Pos(Chr(0), exts)))             // if shoe fits ...
                Return(TRUE)
            endif
            exts = mSubStr(exts, Chr(0), + 1, 0)
        endwhile
    else
        return(FALSE)
    endif
    return(FALSE)
end

/**************************************************************************
        justYesNo
            helper to do a YesNo without Esc or Cancel
 **************************************************************************/
integer         proc          JustYesNo(STRING s)
    JYN(s)
    return(iif(MenuOption()==1,TRUE,FALSE))
end

proc                        main()
    get_globals()
    abort = FALSE
    dirs_to_be_processed = GetGlobalInt('TSGREP dirs_to_be_processed' )
    list_of_filespecs    = GetGlobalInt('TSGREP list_of_filespecs'    )
    build_list_of_filespecs()
    if load_files()
        SetGlobalInt('TSGREP 5 return code', TRUE)
    else
        SetGlobalInt('TSGREP 5 return code', FALSE)
    endif
    set_globals()
end

proc                        whenloaded()
    if file_sep_char == ' '
        warn('You have set variable file_sep_char to be a space. This is illegal')
        warn('Changing file_sep_char to be a ^.')
    endif
    /*
        Remainder of this proc present only to
        avoid compiler messages.
    */
    if 'foo' == 'oof'
        a = processing_line +
        files_processed_line +
        files_only +
        oid +
        hits_line +
        abort_line +
        press_any_key_line +
        val(default_ext_2)+
        val(dir_list_ext)
        mjoinline()
        msplitline()
        ymd(line)
        set_flags_to_defaults()
    endif
end
