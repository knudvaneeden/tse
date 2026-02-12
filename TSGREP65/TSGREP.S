/**************************************************************************
               TSGREP ... A regular expression line extractor ... 6.5

 File TSGREP: Main routines.
              14,708 bytes, compiled (10-24-95)
 **************************************************************************/

/*************************************************************************
 File TSGREP1:      TSGREP options menu.
 File TSGREP2:      Main menu and all string & flag settings
 File TSGREP3:      Display hit list and do all keystroke execution.
 File TSGREP4:      Opens screen windows, paints them, and puts header in
                    output file.
 File TSGREP5:      Does all file loading, including recursive and
                    list loads.
 File TSGREP.INC:   Common definitions and routines.
 File TSGREP.BAT:   Sets environment strings and executes the editor with
                    -eTSGREP
 File TSGREPSC.BAT: Compiles all TSGREP?.S files.
 File WPTSGREP.BIN: FF Routines used by TSGREP.
***************************************************************************/

/*
Changes for version 6.5:
************************
10-24-95    Changed code to use native TSE functions for getting
            file date and size. WPTSGREP.BIN no longer used.

10-21-95    Changed code to use buildpickbuffer() as a way to get
            **significantly** faster loading of recursive files.
            Moved all messages showing counts, etc. in a routine
            in tsgrep.inc.

10-20-95    Changed code to take advantage of some new 2.5 features.
            Made sure 'a' option will not interfere with TSGREP.

Changes for version 6.4:
************************
10-09-95    Made sure not to try to load "[unnamed]".

Changes for version 6.3:
************************
08-06-95    Changed all SaveFile() to SaveAs(CurrFileName, _OVERWRITE_)
            as a bug workaround.
07-24-95    Fixed bug that required hitting ctrl- twice to unload.
07-24-95    Removed references to ++unnamed++ - no longer needed.

Changes for version 6.1:
************************
12-28-94    Fixed bug that always excluded files without an extension.
12-28-94    Fixed bug that left you in ++unnamed++ buffer if starting
                TSGREP from command line and pressing <Esc> at menu.
01-02-95    Fixed (non-reproducible) bug that caused a users system to
            hang if a filespec lacked both an extension and a terminating
            '.'.
01-02-95    Fixed problem with recount_hits option and use of ^ or $.
01-04-95    Added Show Help Lines option to "other options" menu.
            Added corresponding command line option (w) for this.
            Default = TRUE. Note that this overrides TSE's setting for
            this while TSGREP is loaded.

Known Bugs:
***********
        -- none --

Pending Suggestions (comments welcome):
***************************************

>>> choice of  mouse/keyboard helpline a la semqwk

AM> It is not to seldom, that I have to search for two expressions ("two",
AM> "line") in a source file. The first expression is very often in the
AM> files, the second, near by the first one, makes the exact match. But
AM> normaly you can't say, the second search expression will be found in the
AM> same or maybe in the next line.
AM>
AM> You only know "It is somewhere around the first one".
AM>
AM> Or, and this is also very often, you know the first expression is very
AM> often in the files and the second one also. But only, if the appear BOTH
AM> anywhere in the source files, you hit the searched file.
AM>

AWÞI find TSGREP very useful, but can't do one simple thing I would like.
  ÞI want to aim the TSGREP.TMP temporary file into whatever is the current
  Þ%TEMP% environmental variable.  Depending on my configuration, that can
  Þbe g:\, i:\, or l:\.  Something like %temp%tsgrep.tmp does not work.

Other Changes:
**************
        See TSGREP.DOC.

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³NOTES FOR v5 USERS:                                                      ³
³                                                                         ³
³   1. TSGREP.BAT HAS CHANGED; BE SURE TO USE THE NEW ONE.                ³
³                                                                         ³
³      Arguments are now:                                                 ³
³       TSGREP string file_spec search_options TSGREP_options outfile_name³
³                                                                         ³
³   2. All options are now stated in the positive. For instance:          ³
³        i now means 'include line numbers'                               ³
³       -i now means 'do not ...'                                         ³
³                                                                         ³
³   3. Many option codes have changed. All option codes now conform to the³
³      hot key for the option on the TSGREP options menu.  You can, if    ³
³      you want, change these option codes. They're defined in TSGREP2.s  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#INCLUDE ['tsgrep.inc']     // constants, strings

/**************************************************************************
    DECLARATIONS - Constant, Integer, String
 **************************************************************************/

INTEGER
    //  ** editor states ** //
    AI,                                 // holds initial AutoIndent state
    ILBA,                               // holds initial InsertLineBlocksAbove value
    Ins,                                // holds initial insert state
    IsCh,                               // holds initial IsChanged value
    KM,                                 // holds initial killbuffmax state
    LW,                                 // holds initial loadwild state
    ML,                                 // holds initial MsgLevel value
    ML2,                                // holds temp msg level state
    RTW,                                // holds initial Remove Trailing white
    Ww,                                 // holds initial WordWrap state
    ShHlpLine,                          // holds initial ShowHelpLine state
    color1,
    //  ** buffers ** //
    cid = 0,                            // first file loaded
    excl_id = 0,                        // list of excluded files
    no_hit_id = 0,                      // list of files w/o hits
    copy_of_list,                       // id for copy of above
    cfid = 0,                           // id for buffer with current files
    cfid2 = 0,                          // id for buffer with current files
    id = 0,                             // id of file being processed
    files_only_list,                    // a buffer to this list
    //  ** counters & misc. flags ** //
    abort,
    total_hits = 0,                     // hits counter
    curr_file_hits = 0,                 // hits counter
    name_line,                          // line filename placed on
    files = 0,                          // file counter
    bytes = 0,
    total_bytes =0,
    linenumber = 0,                     // line number of find,
    last_line_gotten = 0,               // last line copied to outfile
    first_line_gotten = 0,              // first line copied to outfile
    isloaded = 0,                       // for restoring curr files
    val2 = 0,
    last_write = 0,                     // last line written to output file
    last_write_len = 0                  // last line written to output file

STRING
    // ** user-settable file names, etc ** //
    ramdrive[3] = '',                  // :U: format:  'd:\'  OR '\'
    // ** other major strings ** //
    dir_list_name[MAXFN]="",            // name for dirs-only list
    // ** misc strings ** //
    name[MAXFN] = '',                   // used for name of file being processed
    line[255] = '',                     // used variously
    file_date[8] = '',                  // used for date checking
    ffblk[43]='',                       // used by file size/date routines
    fattrstring[50]='',                 // used by file size/date routines
    ad[12] = '00-00-00',
    bd[12] = '99-12-31',
    padchar[1] = 'Ä',
    exclude1[255] = ' .img .exe .com .dll .tif .pcx .$hp .$sc .cif'
                  + ' .vgr .mac .zip .bin .hlp .bak .ps .bmp',
    exclude2[255] = ''                  // set in main

/**************************************************************************
    DECLARATIONS - Forward Procedures and Menus
 **************************************************************************/

forward         proc          check_for_abort       // aborts between file loads // if <escape>
                                     (INTEGER MODE)
forward         proc          create_buffers()      // build all needed buffers
forward         proc          close_buffers()       // close 'em
forward         proc          end_processing        // cleanup AND view
                                    (INTEGER MODE)
forward string  proc          fileDate()            // date of found file
forward integer proc          getflag               // returns value from string called flags
                                    (INTEGER flag)
forward integer proc          is_file_excluded      // Checks dates, extension, etc.
                                    (STRING name)
forward integer proc          JustYesNo             // YesNo w/o escape, cancel
                                    (STRING s)
forward         menu          JYN()                 // see above
forward integer proc          list_loaded_files()   // builds a list, with flags
forward integer proc          list_remaining_files()// builds a list, with flags
forward         proc          make_other_hit_lists()// for use by toggle_hists
forward         proc          maybe_save_changes()  // queries user
forward proc                  reset_editor()
forward string  proc          mSubStr               // substring ops
        (STRING haystack, STRING needle, INTEGER op, INTEGER extra)
forward         proc          reload_files()        // interactive mode : reload files
forward         proc          QSB()                 // quick statusbar
forward         proc          search_and_write()    // main processing loop
forward         proc          terminate()           // deactivates various events
forward proc                  unload_tsgrep()
forward         proc          write_hits_in_outfile(INTEGER arg)
forward         proc          x_line_search()

/**************************************************************************
    KEYDEFS
 **************************************************************************/
<AltShift S> <AltShift G>   Main()

keydef                      unload
    <AltShift ->    unload_TSGREP()
    <CtrlShift ->   unload_TSGREP()
    <HelpLine>       ' {AltShift-} or {CtrlShift-} to unload TSGREP    {Alt S}+{G} to restart it'
    <Alt HelpLine>   ' {AltShift-} unload TSGREP    {Alt S}+{G} to restart it'
    <Shift HelpLine> ' {ShiftAlt-} Unload TSGREP {ShiftCtrl-} Unload TSGREP'
end

/**************************************************************************
 **************************************************************************
    PROCEDURES
 **************************************************************************
 **************************************************************************/

/**************************************************************************
        Check for Abort
 **************************************************************************/
proc                        check_for_abort(INTEGER mode)
    time = timer(GET_TIME)
    paint_message(time_line, 0, time+']',14, 0)
    if KeyPressed() AND GetKey() == <escape>
        if pause                                // if Delay is set...
            statusBar('setting Delay to 0',0,0,IN_WINDOW)
            Delay(pause)
            setFlag(PAUSE_LENGTH, 0)
            pause = FALSE
        else
            if (mode == 1 or mode == 2) and getFlag(LOAD_OUT_FILE)
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

            if mode == 8
                abort = TRUE
                return()
            endif

            end_processing(INTERRUPTED)
            halt                     // Avoid going back to where
                                     // check_for_abort was called
        endif
    endif
end

proc                        create_buffer_helper1(VAR STRING fn,
                                                  VAR INTEGER bid,
                                                  INTEGER attrib)
    if getBufferID(fn)
        bid = GetBufferID(fn)
        EmptyBuffer(bid)
    else
        bid = CreateBuffer(fn, attrib)
    endif
end

proc                        create_buffer_helper2(VAR INTEGER id)
    PushPosition()
    if id and GotoBufferID(id)
        EmptyBuffer(id)
    else
        id = CreateTempBuffer()
    endif
    PopPosition()
end

/**************************************************************************
        Create All Buffers
 *************************************************************************/
proc                        create_buffers()
    statusBar('Creating buffers...',0,0,AS_MESSAGE)
    PushPosition()
    create_buffer_helper1(outfile,          oid,          _NORMAL_)
    create_buffer_helper1(dir_list_name,    list_of_dirs, _NORMAL_)

    create_buffer_helper1(outfile_copy,     copy_of_list, _HIDDEN_)
    create_buffer_helper1(default_name_2,   files_only,   _HIDDEN_)

    create_buffer_helper2(cfid)
    create_buffer_helper2(cfid2)
    create_buffer_helper2(dirs_to_be_processed)
    create_buffer_helper2(list_of_filespecs)
    create_buffer_helper2(excl_id)
    create_buffer_helper2(no_hit_id)

    SetGlobalInt('TSGREP dirs_to_be_processed' ,dirs_to_be_processed )
    SetGlobalInt('TSGREP dirs_with_extensions' ,dirs_with_extensions )
    SetGlobalInt('TSGREP list_of_filespecs'    ,list_of_filespecs    )
    SetGlobalInt('TSGREP oid', oid)
    SetGlobalInt('TSGREP list_of_dirs', list_of_dirs)
    SetGlobalInt('TSGREP files_only', files_only)
end

/**************************************************************************
        close buffers
 **************************************************************************/
proc                        close_buffers()

    PushPosition()
    AbandonFile(cfid)                   // Current Files
    AbandonFile(cfid2)                  // Current Files
    AbandonFile(excl_id)                // excluded files
    AbandonFile(no_hit_id)              // no hit files
    AbandonFile(dirs_to_be_processed)   // Dirs to be processed buffer
    AbandonFile(list_of_filespecs)      // List of file specs
    GotoBufferID(copy_of_list)          // Copy of List
    SaveAs(CurrFileName(), _OVERWRITE_)
    AbandonFile()

    GotoBufferID(files_only_list)       // Files-only list
    FileChanged(FALSE)

    GotoBufferID(list_of_dirs)          // List of directories
    if NumLines() <= 1
        AbandonFile(list_of_dirs)
    else
        case getFlag(SAVE_HIT_LIST)
            when ALWAYS     SaveAs(CurrFileName(), _OVERWRITE_)
            when NEVER      FileChanged(FALSE)
            when ASKSAVE    FileChanged(TRUE)
        endcase
        BegFile()
    endif

    GotoBufferID(oid)                   // Output file (hit list)
    case getFlag(SAVE_HIT_LIST)
        when ALWAYS     SaveAs(CurrFileName(), _OVERWRITE_)
        when NEVER      FileChanged(FALSE)
        when ASKSAVE    FileChanged(TRUE)
    endcase

    AbandonFile(GetBufferID(ExpandPath('tsgrep.$$$'))) // Misc
    PopPosition()
end

/**************************************************************************
        end processing
 **************************************************************************/
proc                        end_processing(INTEGER mode)
    INTEGER
        counter = 0,
        stat = 0

    if mode == INTERRUPTED
        GotoBufferID(cfid)
        BegFile()
        repeat
            StatusBar('Unloading',0,0,IN_WINDOW)
            stat = Val(GetText(MAXFN+1,1))
            if  stat == LOADED_BY_TSGREP OR
                stat == EXCLUDED
                paint_message(processing_line, 9,'Unloading: ['+ Trim(GetText(1,MAXFN)) + ']',54,0)
            AbandonFile(GetBufferID(Trim(GetText(1,MAXFN))))
            endif
        until not Down()
    endif

    bytes = total_bytes/1024
    total_bytes = (total_bytes - bytes*1024)*1000/102400
    line = '= ' + str(bytes) + '.' + str(total_bytes) + ' kb'

    GotoBufferId(oid) GotoLine(9)  GotoPos(25)
    DeltoEol()
    InsertText(Format(files:8, '] ',
                      iif(mode == INTERRUPTED, name_prefix + 'interrupted' + name_suffix, line)
                      ))

    //  01-02-95
    //  Note: no recound necessary if bol or eol search

    if Pos('^', options) or Pos('$', options)   // 01-02-95
       OR ((Pos('^', sstring) or Pos('$', sstring)) and Pos('x', options))
        counter = total_hits                    // 01-02-95
        goto did_bol_or_eol_search              // 01-02-95
    endif                                       // 01-02-95

    GotoLine(10) GotoPos(25)
    DelToEol()
    InsertText(Format(
        iif(total_hits,'~'+str(total_hits), '0'):8,
        iif(total_hits, ']  Use Recount Hits option for exact count. ', ']')
        ))
    if getFlag(WRITE_HITS) and getFlag(RECOUNT_HITS_FLAG)
        GotoLine(13)
        EndLine()
        while lfind(sstring, options)
            StatusBar('ReCounting hits',0,0,IN_WINDOW)
            check_for_abort(8)
            if abort
                goto no_count
            endif
            if not (GetText(1, Length(name_prefix)) == name_prefix)
                counter = counter + 1
            endif
            NextChar()
        endwhile
  did_bol_or_eol_search:                               // 01-02-95
        GotoLine(10) GotoPos(25)
        DeltoEol()
        InsertText(Format(counter:8,'] (matches)' ))
    endif
  no_count:
    EndFile()
    if getFlag(TSGREP_MODE) == CMDLINE
        statusBar('Saving ' + outfile,0,0,IN_WINDOW)
        SaveAs(CurrFileName(), _OVERWRITE_)

    endif

    if getFlag(TSGREP_MODE) == INTERACTIVE and
       getFlag(LOAD_OUT_FILE)
       getFlag(UNLOAD_LOADED_FILES)
            reload_files()
    endif

    if getFlag(LIST_FILES_W_HITS_ONLY) == FALSE
        PushBlock()
        GotoBufferID(no_hit_id)
        if NumLines()
            MarkLine(1, NumLines())
            GotoBufferID(oid)
            EndFile()
            AddLine(Format('': 29 : padchar,  'Other Files Searched', '' : 29 : padchar) )
            AddLine()
            CopyBlock()
            GotoBlockBegin()
        endif

        GotoBufferID(excl_id)
        if NumLines()
            MarkLine(1, NumLines())
            GotoBufferID(oid)
            EndFile()
            AddLine(Format('' : 29 : padchar, '   Excluded Files   ', '' : 29 : padchar) )
            AddLine()
            CopyBlock()
        endif
        PopBlock()
    endif

    if getFlag(LOAD_OUT_FILE)
        make_other_hit_lists()
        close_buffers()
    endif

    if use_tsgrep_colors == TRUE
        Set(TextAttr, color1)
    endif

     if (not getFlag(LOAD_OUT_FILE)) and getFlag(PRESS_ANY_KEY)
        Set(Attr,Query(HiLiteAttr))
        PushPosition()
        gotobufferid(oid)
//      SaveAndQuitFile()
        SaveAs(CurrFileName(), _OVERWRITE_)
        AbandonFile()
        PopPosition()
        Alarm()
        counter = 63
        loop
            counter = counter * -1
            Set(Attr,
            iif(Query(Attr)<>Query(HiliteAttr),
                Query(HiLiteAttr),
                Query(TextAttr)
                )
            )
            VGotoXY(1,press_any_key_line)

            PutLine(Format(" Press any key to continue ":counter), 63)
            Delay(6)
            if KeyPressed()
                break
            endif
        endloop
    endif

    PopWinClose()                           // output area
    PopWinClose()                           // output area
    PopWinClose()                           // output area

    /*
        Reset editor
    */
    Set(InsertLineBlocksAbove, ILBA)
    Set(RemoveTrailingWhite, RTW)
    Set(MsgLevel, ML)
    Set(LoadWildFromInside, LW)
    Set(AutoIndent,AI)
    Set(WordWrap,WW)
    Set(Insert,Ins)
    PopBlock()
    goto_hit_list_mode = 0

    GotoBufferID(oid)
    GotoLine(11)
    GotoPos(25)
    InsertText(Format(time :8, ']'))

    if not getFlag(LOAD_OUT_FILE)
        AbandonEditor()
    endif

    set_globals()
    if NOT ExecMacro('tsgrep3')
        warn('failure executing tsgrep3')
    endif
    reset_editor()
    UpDateDisplay(_ALL_WINDOWS_REFRESH_)
end

/**************************************************************************
        returns file size from ffblk
 **************************************************************************/
integer proc                FileSize()
    return(Val(Trim(fattrstring[16:9])))
end
/**************************************************************************
        returns file date from ffblk
 **************************************************************************/
string         proc         FileDate()
    return(fattrstring[26:8])
end


/**************************************************************************
        justYesNo
            helper to do a YesNo without Esc or Cancel
 **************************************************************************/
integer         proc        JustYesNo(STRING s)
    JYN(s)
    return(iif(MenuOption()==1,TRUE,FALSE))
end

menu                        JYN()
    /*
        A YesNo that allows no Escape or Cancel.
    */
    NoEscape
    '&Yes'
    '&No'
end

/**************************************************************************
        Adds an entry for each file to cfid buffer
 **************************************************************************/
integer proc                list_loaded_files()
    INTEGER
        counter = 0
    /*
        List currently-loaded files
    */
    PrevFile(_DONT_LOAD_)                   // currently-loaded files
    NextFile(_DONT_LOAD_)                   // start from a file
    cid = GetBufferID()
    repeat                                  // make list of loaded files
        check_for_abort(2)
        if abort == TRUE
            return(FALSE)
        endif
        counter = counter + 1
        StatusBar('Listing loaded files', counter, NumFiles(),IN_WINDOW)
        id = GetBufferID()
        if    id == copy_of_list
           or id == files_only
           or id == list_of_dirs
           or id == oid
           or pos('unnamed',currfilename()) and
              pos('[',      currfilename())
           or id == GetBufferID(ExpandPath('tsgrep.$$$'))
           or id == GetBufferID(ExpandPath(SplitPath( LoadDir(), _DRIVE_|_DIRECTORY_) + 'tsgrep.aud'))

            isloaded = TSGREP_WORK_FILE
        else
            isloaded = WAS_LOADED
        endif
        name = ExpandPath(CurrFileName())   // file name
        AddLine( Format(name : -MAXFN,      // to cfid
                 isloaded : 1,
                 CurrLine() : -GetFlag(LNDIGITS),
                 NumLines() : -GetFlag(LNDIGITS)
               ) , cfid )
        NextFile(_DONT_LOAD_)
    until GetBufferID() == cid
    return(TRUE)
end

/**************************************************************************
        Adds an entry for each add'l file to cfid2 buffer
 **************************************************************************/
integer proc                list_remaining_files()
    /*
        Adds to list
    */
    INTEGER
        counter = 0,
//      a = GetBufferID('++unnamed++'),
        aa = GetBufferID('[unnamed]'),
        b = GetBufferID(ExpandPath('tsgrep.$$$')),
        c = GetBufferID(ExpandPath(SplitPath( LoadDir(), _DRIVE_|_DIRECTORY_) + 'tsgrep.aud'))
    PushPosition()
    gotoBufferID(files_only)
    PrevFile(_DONT_LOAD_)                   // start from a file
    cid = GetBufferID()
    repeat                                  // make list of loaded files
        counter = counter + 1
        StatusBar('Listing/excluding files', counter, numfiles(), IN_WINDOW)
        check_for_abort(2)
        if abort == TRUE
            return(FALSE)
        endif
        id = GetBufferID()
        name = ExpandPath(CurrFileName())   // file name
        if    id == copy_of_list
           or id == files_only
           or id == list_of_dirs
           or id == oid
//         or id == a
           or id == aa
           or id == b
           or id == c
            isloaded = TSGREP_WORK_FILE
        elseif getFlag(EXCLUDE_FILES) == TRUE and
               is_file_excluded(name)
            isloaded = EXCLUDED
        else
            isloaded = LOADED_BY_TSGREP
        endif
        AddLine( Format(name : -MAXFN,      // to cfid
                 isloaded : 1,
                 0 : -GetFlag(LNDIGITS), file_date : 8) , cfid2 )
        PrevFile(_DONT_LOAD_)
    until GetBufferID() == cid

    GotoBufferID(cfid)
    BegFile()
    repeat
        StatusBar('Merging lists',0,0,IN_WINDOW)
        name = Trim(GetText(1, MAXFN))
        GotoBufferID(cfid2)
        if lFind(name, 'g^')
            DelLine()
        endif
        GotoBufferID(cfid)
    until not Down()
    GotoBufferID(cfid2)
    MarkLine(1,NumLines())
    GotoBufferID(cfid)
    PushBlock()
    CopyBlock()
    MarkColumn(1,       iif(GetFlag(CHECK_DATES), MAXFN+1+GetFlag(LNDIGITS)+1, 1),
            NumLines(), iif(GetFlag(CHECK_DATES), MAXFN+1+GetFlag(LNDIGITS)+9, MAXFN))
    StatusBar('Sorting files...', 0, 0,IN_WINDOW)
    Sort()
    PopBlock()
    BegFile()
    if not PosFirstnonWhite()
        DelLine()
    endif
    PopPosition()
    return(TRUE)
end

/**************************************************************************
        MAIN
 **************************************************************************/
proc                        MAIN()
    if Query(macroCmdLine) == 'unload'
        unload_tsgrep()
        return()
    endif

    Message('TSGREP '+ v + ' initializing...')
    Hook(_AFTER_UPDATE_DISPLAY_, Terminate)
    Hook(_ON_CHANGING_FILES_, Terminate)
    Hook(_ON_FIRST_EDIT_, Terminate)
    Hook(_IDLE_, Terminate)

    abort = FALSE
    timer_not_set = TRUE
    total_hits = 0
    total_bytes = 0
    files = 0
    last_line_gotten = 0
    color1 = Query(TextAttr)
    cid = GetBufferID()

    /*
        Set editor states
    */
    Set(Break, ON)
    AI  =  Set(AutoIndent,OFF)
    WW  =  Set(WordWrap, OFF)
    Ins =  Set(Insert,ON)
    ILBA = Set(InsertLineBlocksAbove, ON)
    KM  =  Set(KillMax, 0)
    LW  =  Set(LoadWildFromInside, ON)
    ML  =  Query(MsgLevel)
    ML2 =  Set(MsgLevel,_none_)
    RTW =  Set(RemoveTrailingWhite, OFF)
    if getFlag(NO_WARNING_FLAG)
        Set(MsgLevel,_NONE_)
    else
        Set(MsgLevel,_ALL_MESSAGES_)
    endif

    set_globals()
  p2:
    SetGlobalInt('TSGREP exe 2 again',FALSE)
    if NOT ExecMacro('tsgrep2')
        warn('failure executing tsgrep2')
    endif
    if NOT GetGlobalInt('TSGREP 2 return code')
        get_globals()
        reset_editor()
        halt
    endif
    if GetGlobalInt('TSGREP exe 2 again') == TRUE
        goto p2
    endif
    get_globals()

    ad = YMD(after_date)
    bd = YMD(before_date)

    PushBlock()

    if getFlag(UNLOAD_LOADED_FILES)     // If unloading files as we go
        maybe_save_changes()            // query about save
    endif

    if Length(outfile) == 0             // none entered
        outfile = default_name
    endif
    if SplitPath(outfile, _drive_ | _path_) == ''
        if Length(ramdrive)
            outfile = ramdrive + outfile
        else
            outfile = LoadDir() + outfile
        endif
    endif

    outfile        = ExpandPath(outfile)
    outfile_copy   = ExpandPath(SplitPath(outfile, _DRIVE_ | _NAME_) + '.$$$')
    default_name_2 = ExpandPath(SplitPath(outfile, _DRIVE_ | _NAME_) + default_ext_2)
    dir_list_name  = ExpandPath(SplitPath(outfile, _DRIVE_ | _NAME_) + dir_list_ext)

    create_buffers()
    if use_tsgrep_colors == TRUE
        color1 = Set(TextAttr, COLOR (BRIGHT WHITE ON RED ))
    endif
    set_globals()
    if not execmacro('tsgrep4')
        warn('failure not execute tsgrep4')
        halt
    endif
    get_globals()

    list_loaded_files()

    set_globals()
    if not execmacro('tsgrep5')
        // build_list_of_filespecs()           // creates buffer list_of_filespecs
        // load_files()
        warn('failure executing tsgrep5')
    endif
    if not GetGlobalInt('TSGREP 5 return code')
        get_globals()
        end_processing(INTERRUPTED)
        halt
    endif
    get_globals()

    if NOT list_remaining_files()              // adds to above list
        end_processing(INTERRUPTED)
        halt
    endif
    search_and_write()
    end_processing(NORMAL)
end

/**************************************************************************
        Create Files-Only List AND Create Backup Complete List
 **************************************************************************/
proc                        make_other_hit_lists()
    statusBar('Creating copy of list buffer...',0,0,IN_WINDOW)
    PushPosition()
    ML2 = Set(MsgLevel, _ALL_MESSAGES_)
    GotoBufferID(oid)
    PushBlock()
    MarkLine(1, NumLines())
    GotoBufferID(copy_of_list) CopyBlock()
    Set(MsgLevel,ML2)
    PopBlock()
    PopPosition()
end

/**************************************************************************
        maybe_save_changes()
            if unloading files, check for save changes
 **************************************************************************/
proc                        maybe_save_changes()
    repeat
        if not FileChanged() or NumLines() <= 1
            goto skip_this_file
        endif
        if getFlag(SAVE_LOADED_FLAG) == ASKSAVE
            UpdateDisplay()
            if JustYesNo( 'Save changes?')
//              SaveFile()
                SaveAs(CurrFileName(), _OVERWRITE_)
            else
                if getBufferID() == cid    // reset cid
                    PrevFile(_DONT_LOAD_)
                    cid = GetBufferID()
                    NextFile(_DONT_LOAD_)
                endif
                name = CurrFileName()
                linenumber = CurrLine()
                statusBar('Abandoning changes to ' + name,0,0,IN_WINDOW)
                AbandonFile()
                EditFile(name)
                GoToLine(linenumber)
                UpdateDisplay(_STATUSLINE_REFRESH_)
            endif
        elseif getFlag(SAVE_LOADED_FLAG) == NEVER
            UpdateDisplay()
            if getBufferID() == cid    // reset cid
                PrevFile(_DONT_LOAD_)
                cid = GetBufferID()
                NextFile(_DONT_LOAD_)
            endif
            name = CurrFileName()
            linenumber = CurrLine()
            statusBar('Abandoning changes to ' + name,0,0,IN_WINDOW)
            AbandonFile()
            if Pause
                Delay(pause)
            endif
            EditFile(name)
            GoToLine(linenumber)
            UpdateDisplay(_STATUSLINE_REFRESH_)
        else                                    // invalid SAVE_CHANGED_FILES
            statusBar('Saving' + name,0,0,IN_WINDOW)            // value goes here
            SaveAs(CurrFileName(), _OVERWRITE_)

        endif
      skip_this_file:
        NextFile(_DONT_LOAD_) until cid == GetBufferID()
end

/**************************************************************************
        process file?
 **************************************************************************/
integer         proc        is_file_excluded(string NAME)

    STRING
//         fn[8] = '',
//         fe[4] = ''                           // OLD
           fe[5] = ''                           // NEW 12-28-94

    /*
        TRUE if excluded by date or extension
    */
//  fn = lower(SplitPath(name,_NAME_))
    fe = lower(SplitPath(name,_EXT_ )) + ' '
    if fe == ' '                                // ADDED 12-28-94
        fe = '.' + fe                           // ADDED 12-28-94
    endif                                       // ADDED 12-28-94
    if  GetFlag(EXCLUDE_FILES) and
        ( Pos(fe, exclude1 + ' ')
          or Pos(fe, exclude2 + ' ') )
        return(TRUE)
    elseif getFlag(CHECK_DATES)
        ffblk = ''
        setDTA(ffblk)
        findFirst(name, ffSUBDIR)
        fattrstring = DeCodeDTA(ffblk)
        file_date= fileDate()
        if file_date[1] == ' '
            file_date= '0' + SubStr(file_date, 2, Length(file_date))
        endif
        file_date = YMD(file_date)
        if (file_date <= ad)  OR (file_date >= bd)
            return(TRUE)
        endif
    endif
    return(FALSE)
end

proc                        reset_editor()
    UnHook(Terminate)
    Set(KillMax,KM)
    Set(MsgLevel, ML2)
end

/**************************************************************************
    Quickie StatusBar
 **************************************************************************/
proc                        QSB()
    if pause
        StatusBar('Searching...<esc> for higher speed',0,0,IN_WINDOW)
    else
        StatusBar('Searching',0,0,IN_WINDOW)
    endif
end

/**************************************************************************
        Reload Files (Interactive Mode)
 **************************************************************************/
proc                        reload_files()
    INTEGER count = 0
    cid = GetBufferID()
    if NOT cfid                   // in case current file list NOT built
        return()
    endif
    GotoBufferId(cfid)
    BegFile()
    repeat
        StatusBar('Reloading files',0,0,IN_WINDOW)
        count = count + 1
        GotoBufferId(cfid)
        if Val(GetText(MAXFN + 1, 1)) == WAS_LOADED
            statusBar('Reloading ' + GetText(1,MAXFN),0,0,IN_WINDOW)
            if Val(GetText(MAXFN+1, GetFlag(LNDIGITS))) > 0
                EditFile(mSubStr(GetText(1,MAXFN), ' ', -1, 0) +
                         ' -n' + GetText(MAXFN + 2, GetFlag(LNDIGITS))
                        )
            else
                EditFile(outfile + ' ' + mSubStr(GetText(1,MAXFN), ' ', -1, 0))
            endif
        endif
        GotoBufferId(cfid)
    until NOT Down()
    AbandonFile(cfid)
end

/**************************************************************************
        Replace character with a string -- utility proc
        Replace character with a string -- utility proc
 **************************************************************************/
/*
string         proc           repl_char(STRING find_string,
                                        STRING repl_string,
                                        VAR STRING target,
                                        INTEGER extra_chars_to_replace)
    if Pos(find_string, target)
        while Pos(find_string, target)
        target = SubStr(target,
                        1,
                        Pos(find_string, target)-1 )
                 + repl_string
                 + SubStr(target,
                          Pos(find_string, target)
                            +Length(find_string)
                            +extra_chars_to_replace,
                          Length(target) )
        endwhile
    endif
    return(target)
end
*/

/**************************************************************************
 **************************************************************************/
proc                        search_and_write()
    paint_message(files_processed_line, 3, "Files Completed: [ ]", 54, 0)
    GotoBufferID(cfid)
    BegFile()
    repeat
        isloaded = Val(GetText(MAXFN +1, 1))
        name = Trim(GetText(1,MAXFN))
        if isloaded == TSGREP_WORK_FILE
            goto skip_this_file
        elseif isloaded == EXCLUDED
            AddLine(name, excl_id)
            goto skip_this_file
        elseif getFlag(FILES_ONLY_NO_SEARCH)
            AddLine(name, no_hit_id)
            files = files + 1
            goto skip_this_file
        endif
        file_date = GetText(MAXFN+1+GetFlag(LNDIGITS)+1,8)
        paint_message(processing_line, 11, "Loading: [" + Trim(GetText(1,MAXFN)) + ']' ,54, 1)
        EditFile(Trim(GetText(1,MAXFN)))
        QSB()
        id = GetBufferID()
        curr_file_hits = FALSE
        last_write = 0              // used by write_hits_in_outfile
        last_write_len = 0          // used by write_hits_in_outfile
        last_line_gotten = 0
        name = CurrFileName()               // get name of file
        ffblk = ''
        setDTA(ffblk)
        if findFirst(ExpandPath(CurrFileName()), ffSUBDIR)
            fattrstring = DeCodeDTA(ffblk)
            bytes = filesize()
        else
            bytes = 0
        endif
        total_bytes = total_bytes + bytes
        paint_message(processing_line, 8, "Processing: [" + name + ']' ,54,0)
        GotoBufferId(oid)                   // go to output buffer
        name_line = CurrLine()              // later, go back to this line
        GotoColumn(1)
        InsertText(format(name_prefix + name + name_suffix : -64))
        CReturn()                          // AND creturn

        GotoBufferId(id)                   // goto file being processed
        PushPosition()
        BegFile()                          // to BOF
        IsCh = FileChanged()
        if getFlag(SEARCH_ACROSS_LINES) <> OFF and
           getFlag(SEARCH_ACROSS_LINES) <> AUTO_OFF
            x_line_search()
        else
            while lFind(sstring, options)
                QSB()
                total_hits = total_hits + 1
                curr_file_hits = TRUE
                paint_message(hits_line, 0, Str(total_hits)+']',10, 0)
                if getFlag(WRITE_HITS)
                    write_hits_in_outfile(1)
                    if getFlag(ONE_HIT_ONLY_PER_FILE)
                       or CurrLine() == NumLines()
                        goto end_this_file
                    endif
                else
                    goto end_this_file
                endif
                Down()
                BegLine()                // to beginning of next line
                check_for_abort(3)
            endwhile
        endif

      end_this_file:
        PopPosition()
        FileChanged(IsCh)

        files = files + 1
        paint_message(files_processed_line, 0, Format(files , '] ~', NumFiles()-3 , ' to go'), 15, 1)

        if curr_file_hits == FALSE          // if no hits
            GotoBufferId(oid)               //
            DelLine()                       // get rid of blank line bottom
            GotoLine(NumLines())
            line = GetText(1,CurrLineLen())
            line = mSubStr(line, ' ', +1, 0)
            AddLine( trim(line), no_hit_id)

            DeltoEol()
            GotoLine(name_line)
            GotoBufferID(id)
        endif

        /*
            Unload processed File       // this processing unloads processed
        */                              // files so we don't get VM slows
        check_for_abort(4)
        GotoBufferID(cfid)
      skip_this_file:
        if ( getFlag(UNLOAD_LOADED_FILES)
             and Val(GetText(MAXFN+1,1)) <> TSGREP_WORK_FILE)
           or Val(GetText(MAXFN+1,1)) == LOADED_BY_TSGREP
           or Val(GetText(MAXFN+1,1)) == EXCLUDED
            paint_message(processing_line, 9, "Unloading: [" + Trim(GetText(1,MAXFN)) + ']',54,0)
            AbandonFile(GetBufferID(Trim(GetText(1,MAXFN))))
        endif
    until not Down()
    paint_message(files_processed_line, 0, Str(files)+']', 10, 1)
end
/**************************************************************************
        Suppress event that calls this macro
 **************************************************************************/
proc                        terminate()
    BreakHookChain()
end

/**************************************************************************
        Unload Routine
 **************************************************************************/
proc                        unload_TSGREP()
    INTEGER
        cid = GetBufferID()
    PushPosition()
    AbandonFile(files_only)
    AbandonFile(GetbufferID('++unnamed++'))
    if FileExists(default_name_2)
      EraseDiskFile(default_name_2)
    endif
    if FileExists(outfile_copy)
      EraseDiskFile(outfile_copy)
    endif
    if oid and gotobufferid(oid)
        if getFlag(LOAD_OUT_FILE)
            SaveAs(CurrFileName(), _OVERWRITE_)
        else
            if FileChanged()
                UpdateDisplay()
            endif
        endif
        QuitFile()
    endif
    if list_of_dirs and gotobufferid(list_of_dirs)
        if FileChanged()
            UpdateDisplay()
        endif
        QuitFile()
        GotoBufferID(cid)
    endif
    if getFlag(LOAD_OUT_FILE)
        set_globals()
        SetGlobalStr('TSGREP2 action', 'SaveSettingsOnly')
        ExecMacro('tsgrep2')
        SetGlobalStr('TSGREP2 action', '_NORMAL_')
        PopPosition()
        PurgeMacro(CurrMacroFileName()) // !!!must be last line!!!!
    endif
end

proc                        whenloaded()
    ShHlpLine = Set(ShowHelpLine, ON)
    Enable(unload)
    exclude2 = GetEnvStr('EXCLUDE')      // File Extensions to exclude
    flags = Format(flags : sizeof(flags) : '0')     //
    set_flags_to_defaults()
    SetFlag(CHECK_DATES,            FALSE)          //  don't change!
    SetFlag(TSGREP_MODE,            CMDLINE)        //  don't change!
    SetFlag(EXECUTED_ONCE,          FALSE)          //  don't change!
    Hook(_ON_ABANDON_EDITOR_, unload_tsgrep)
    Message('TSGREP '+ v + ' loaded!')

    /*
        Remainder of this proc present only to
        avoid compiler messages.
    */
    if 'foo' == 'oof'
        a = getting_dirs_line + files_only + list_of_dirs +
        loading_files_line + dirs_to_be_processed + oid +
        getting_files_line +
        files_loaded_line +
        dirs_found_line +
        abort_line
        a = a
    endif
end

proc                        whenpurged()
    Set(ShowHelpLine, ShHlpLine)
    PurgeMacro('tsgrep5')
    PurgeMacro('tsgrep4')
    PurgeMacro('tsgrep3')
    PurgeMacro('tsgrep2')
    PurgeMacro('tsgrep1')
    Message('TSGREP purged!')
end

proc                        write_hits_in_outfile(INTEGER arg)
    integer
        digits = GetFlag(LNDIGITS)

    /*
        Check that this line was not already written.
    */
    if CurrLine() == last_write and
       CurrLineLen() == last_write_len
        return()
    endif

    PushBlock()
    UnMarkBlock()
    PushPosition()                     // remember start
    linenumber = CurrLine()            // remember line number

    /*
        Mark lines of context as block
    */
    GotoLine(CurrLine() - GetFlag(CONTEXT))     // goto top of CONTEXT
    if CurrLine() <= last_line_gotten  // don't repeat CONTEXT
        GotoLine(last_line_gotten + 1)
    endif
    first_line_gotten = CurrLine()     // for numbering
    MarkLine()                         // mark beg of block
    PopPosition()
    PushPosition()

    GotoLine(CurrLine() + GetFlag(CONTEXT))     // goto end of CONTEXT
    MarkLine()                         // mark end of block
    EndLine()

    /*
        If there is a hit within the block
        expand it (to allow more context).

        Note: this is one thing that does not work for
              search across lines. Fix someday?
    */
    while NOT getFlag(ONE_HIT_ONLY_PER_FILE)
          AND lFind(sstring, options + 'b')   // i.e., if >1 hit
          AND CurrLine() > linenumber   // in block
        linenumber = currline()       // need to
        GotoLine(CurrLine() + GetFlag(CONTEXT))// add more lines
        MarkLine()
        EndLine()
    endwhile
    GotoBlockEnd()

    last_line_gotten = CurrLine()           // remember for next time
    if getFlag(CONTEXT)
        GotoBlockBegin()                    // adjust hits counter
        total_hits = total_hits - 1         // for all hits in block
        while lFind(sstring, options + 'l')
            total_hits = total_hits + 1
            endline()
        endwhile
    endif
    linenumber = CurrLine()       // remember line number

    GotoBufferId(oid)             // goto output buffer
    CopyBlock()                   // copy block

    /*
        Insert line numbers
        Note that with search x lines, line numbers after
        any hit x line are off by a line.
    */
    GotoBlockBegin()
    BegLine()                     // insert line number
    if getFlag(LINE_NUMBERS)      // if so flagged
        InsertText(Format(first_line_gotten:digits) +
            iif(arg == 1, ' ³ ', ' ³ý'))
        Down()
        BegLine()
        while IsCursorInBlock()
            first_line_gotten = first_line_gotten + 1
            InsertText(Format(first_line_gotten:digits) +  ' ³ ')
            Down()
            BegLine()
        endwhile
    endif

    if getFlag(CONTEXT) and getFlag(LINE_NUMBERS)    // flag actual hits
                                                     // if line numbers used
        GotoBlockBegin()
        Up()
        while Down()
              and IsCursorInBlock()
              and lFind(iif(Pos('^', options),
                            Format('':digits:'.') + '...' + sstring,
                            sstring
                           ),
                           iif(Pos('^', options),
                               options + 'lx',
                               options + 'l'
                              )
                          )
            BegLine()
            InsertText(GetText(1,digits) +
                iif(arg == 1, ' * ', ' *ý'), _OVERWRITE_)
        endwhile

        GotoBlockBegin()
        if getText(digits + 1, 2) == ' ³'
            BegLine()
            InsertText(GetText(1,digits) + ' ¸ ', _OVERWRITE_)
        endif

        GotoBlockEnd()
        BegLine()
            if getText(digits + 1, 3) == ' ³ '
                InsertText(GetText(1,digits) + ' ¾ ', _OVERWRITE_)
            endif
        GotoBlockBegin()
        BegLine()
        val2 = val(gettext(1, digits))
        Up()
        if val(gettext(1, digits)) == val2 + 1
            Down()
            InsertText(GetText(1,digits) + ' ³ ', _OVERWRITE_)
        endif
    endif
    GotoBlockEnd()
    Down()
    GotoBufferId(id)             // goto file being processed
    PopBlock()
    PopPosition()
    last_write = CurrLine()
    last_write_len = CurrLineLen()
end

proc                        x_line_search()
    case getFlag(SEARCH_ACROSS_LINES)
        when FAST, AUTO_FAST    goto fast
        when SLOW, AUTO_SLOW    goto slow
    endcase
  fast:
    while lfind (short_string, options)
        check_for_abort(7)
        MarkFoundText()
        mJoinLine()
        if CurrPos() <> 1
            PrevChar()
        endif
        check_for_abort(5)
        QSB()
        if lFind(sstring, options + 'c' ) MarkFoundText()
            total_hits = total_hits + 1
            curr_file_hits = TRUE
            paint_message(hits_line, 0, Str(total_hits)+']',10, 0)

            if not getFlag(WRITE_HITS)
                mSplitLine()        // no find so split
                return()
            endif

            if break_point and                      // join occurred and
               Query(BlockBegCol) >  break_point    // find is on line 2
                mSplitLine()
                goto no_write
            elseif Query(BlockEndCol) <=  break_point    // find is on line 1
                or not break_point                       // or no join occurred

                mSplitLine()
                write_hits_in_outfile(1)
                NextChar()
            else
                write_hits_in_outfile(2)
                mSplitLine()
            endif

            if getFlag(ONE_HIT_ONLY_PER_FILE)
                return()
            endif
        else
            mSplitLine()
            NextChar()
        endif
      no_write:
        if Currline()==NumLines()
            return()
        endif
        UnMarkBlock()
        nextchar()
    endwhile
    return()

  slow:
    while CurrLine() <= NumLines()
        check_for_abort(6)
        mJoinLine()
        QSB()
        if lFind(sstring, options + 'c' )
            MarkFoundText()
            curr_file_hits = TRUE
            paint_message(hits_line, 0, Str(total_hits)+']', 10, 0)
            total_hits = total_hits + 1

            if not getFlag(WRITE_HITS)
                mSplitLine()        // no write so split, return
                return()
            endif

            if break_point and                      // join occurred and
               Query(BlockBegCol) >  break_point    // find is on line 2
                mSplitLine()
                BegLine()
                Down()
                total_hits = total_hits - 1
                goto no_write2
            elseif Query(BlockEndCol) <=  break_point    // find is on line 1
                or not break_point                       // or no join occurred
                mSplitLine()
                write_hits_in_outfile(1)
                if currline() >= numlines()
                    return()
                endif
                NextChar()
            else
                write_hits_in_outfile(2)
                mSplitLine()
                BegLine()
                if currline() >= numlines()
                    return()
                endif
                Down()
            endif
            if getFlag(ONE_HIT_ONLY_PER_FILE)
                return()
            endif
        else
            mSplitLine()
            BegLine()
            if not Down()
                return()
            endif
        endif
      no_write2:
        if Currline() > NumLines()
            return()
        endif
        UnMarkBlock()
    endwhile
    return()
end
