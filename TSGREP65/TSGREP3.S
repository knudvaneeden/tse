/**************************************************************************
               TSGREP ... A regular expression line extractor ... 6.5

 File TSGREP3: Display hit list and do all keystroke execution.
               10,434 bytes, compiled (10-24-95)
 **************************************************************************/

#INCLUDE ['tsgrep.inc']

/**************************************************************************
    DECLARATIONS - Constant, Integer, String
 **************************************************************************/

CONSTANT
    NEXT_HIT_IN_FILE = 1,
    PREV_HIT_IN_FILE = 2,
    GOING_TO_LAST_MATCH = 101

STRING
    line[255]

INTEGER
    always_save_and_unload = 0,
    col = 1,
    first_file_line = 13,
    goto_hit_hit_file = 0,
    it_was_loaded = TRUE,
    linenumber

/**************************************************************************
    DECLARATIONS - Forward Procedures and Menus
 **************************************************************************/

forward proc                  call_goto_hit_list(INTEGER MODE)
forward proc                  goto_first_file_in_hit_list()
forward proc                  goto_first_match_in_hit_list()
forward proc                  goto_first_match_for_this_file()
forward proc                  goto_hit()
forward proc                  goto_hit_list(INTEGER mode)
forward proc                  goto_last_file_in_hit_list()
forward proc                  goto_last_match_in_hit_list()
forward proc                  goto_last_match_for_this_file()
forward integer proc          goto_next_file_in_hit_list(INTEGER from)
forward proc                  goto_next_match_in_hit_list()
forward integer proc          goto_prev_file_in_hit_list()
forward proc                  goto_prev_match_in_hit_list()
forward proc                  hilite_filename()
forward proc                  key_enable()
forward proc                  main()
forward proc                  move_around(INTEGER dir)
forward menu                  query_save()
forward proc                  remove_file_from_hit_List()
forward proc                  scroll()
forward proc                  toggle_show_detail()
forward proc                  undo_all_removes()
forward proc                  whenloaded()
forward integer proc          x_line_search(integer dir)

/**************************************************************************
    KEY DEFINITIONS
 **************************************************************************/
keydef file         // for while in  searched files
     <alt enter>    call_goto_hit_list(1)
    <ctrl enter>    call_goto_hit_list(1)
    <alt n>         move_around(NEXT_HIT_IN_FILE)
    <alt p>         move_around(PREV_HIT_IN_FILE)

         <HelpLine>  '  {Alt N}/{P} Next/Prev Hit {Alt Enter} Goto List {Ctrl Enter} Goto List'
     <Alt HelpLine>  '  {Alt N}/{P} Next/Prev Hit {Enter} Goto List {Shift -} Unload TSGREP'
<AltShift HelpLine>  '  {Alt Shift -} Unload TSGREP'
    <Ctrl HelpLine>  '  {Ctrl} {Enter} Goto List {-} Deactivate {Shift -} Unload TSGREP'
<CtrlShift HelpLine> '  {Ctrl Shift -} Unload TSGREP'
    <Shift HelpLine> '  {Shift} {Ctrl -} Unload TSGREP {Alt -} Unload TSGREP'
end

keydef hit_file     // for while in the hit list
      <alt enter>    goto_hit()
     <ctrl enter>    goto_hit()

       <GreyHome>    goto_first_match_for_this_file()
           <Home>    goto_first_match_for_this_file()
        <GreyEnd>    goto_last_match_for_this_file()
            <End>    goto_last_match_for_this_file()

     <CursorDown>    goto_next_match_in_hit_list()
 <GreyCursorDown>    goto_next_match_in_hit_list()
     <Alt      N>    goto_next_match_in_hit_list()
       <CursorUp>    goto_prev_match_in_hit_list()
   <GreyCursorUp>    goto_prev_match_in_hit_list()
       <Alt    P>    goto_prev_match_in_hit_list()

           <PgDn>    goto_next_file_in_hit_list(NORMAL)
       <GreyPgDn>    goto_next_file_in_hit_list(NORMAL)
     <Shift PgDn>    goto_last_file_in_hit_list()
           <PgUp>    goto_prev_file_in_hit_list()
       <GreyPgUp>    goto_prev_file_in_hit_list()
     <Shift PgUp>    goto_first_file_in_hit_list()

          <alt R>    remove_file_from_hit_List()
          <alt D>    toggle_show_detail()
          <alt U>    undo_all_removes()

      <HelpLine>    '  {} Next/Prev Hit {Home}/{End} First/Last Match for File {PgUp}/{Dn} Prev/Next File'
<ctrl helpline>     '  {Ctrl} {Enter} Goto Hit {Ctrl Shift -} Unload TSGREP'
 <alt helpline>     '  {Alt} {Enter}  Goto Hit {R} Remove file from list {U} Undo removes {D} Hide Detail {N},{P},{-}'
<Shift HelpLine>    '  {Shift} {PgUp}/{PgDn} First/Last File {Alt -} Unload TSGREP {Ctrl -} Unload TSGREP '
end

keydef no_hit_file     // for while in the copy of hit list without hits
      <alt enter>    goto_hit()
     <ctrl enter>    goto_hit()

          <alt D>    toggle_show_detail()

      <HelpLine>    '  {Ctrl} {Enter} Goto File {Ctrl Shift -} Unload TSGREP'
<ctrl helpline>     '  {Ctrl} {Enter} Goto File {Ctrl Shift -} Unload TSGREP {D} Show Matches'
 <alt helpline>     '  {Alt} {Enter}  Goto File {D} Show Detail {-} Deactivate'
end

keydef deactivate
    <ctrlshift ->        //PurgeMacro(currmacrofilename())
    <ctrlshift ->        Execmacro('tsgrep unload')
    <altshift  ->        //PurgeMacro(currmacrofilename())
    <altshift  ->        Execmacro('tsgrep unload')
end

/**************************************************************************
 **************************************************************************
    PROCEDURES
 **************************************************************************
 **************************************************************************/

proc                          call_goto_hit_list(INTEGER MODE)
    goto_hit_list(MODE)
end

/****************************************************************************
    goto_first_match_for_this_file()
 ****************************************************************************/
proc                          goto_first_match_for_this_file()
    if goto_prev_file_in_hit_list()
        goto_next_match_in_hit_list()
    endif
end

/****************************************************************************
    goto_last_match_for_this_file()
 ****************************************************************************/
proc                          goto_last_match_for_this_file()
    if NOT goto_next_file_in_hit_list(GOING_TO_LAST_MATCH)
        EndFile()
    endif
    goto_prev_match_in_hit_list()
end

/****************************************************************************
    goto_next_match_in_hit_list()
 ****************************************************************************/
proc                          goto_next_match_in_hit_list()
    if GetBufferID() == oid and lFind(sstring, options)
        scroll()
        hiLiteFoundText()
    else
        ChainCmd()
    endif
end

/****************************************************************************
    goto_first_match_in_hit_list()
 ****************************************************************************/
proc                          goto_first_match_in_hit_list()
    BegFile()
    GotoLine(first_file_line - 1)
    goto_next_match_in_hit_list()
end

/****************************************************************************
    goto_first_file_in_hit_list()
 ****************************************************************************/
proc                          goto_first_file_in_hit_list()
    BegFile()
    if lFind(name_prefix, '^+')
        scroll()
        hiLite_FileName()
    else
        ChainCmd()
    endif
end

/****************************************************************************
    goto_prev_match_in_hit_list()
 ****************************************************************************/
proc                          goto_prev_match_in_hit_list()
    PrevChar()
    if GetBufferID() == oid and lFind(sstring, options + 'b' + '+')
        scroll()
        hiLiteFoundText()
    else
        ChainCmd()
    endif
end

/****************************************************************************
    goto_next_file_in_hit_list()
 ****************************************************************************/
integer proc                  goto_next_file_in_hit_list(INTEGER from)
    if GetBufferID() == oid and lFind(name_prefix, '^+')
        scroll()
        hilite_filename()
        return(TRUE)
    else
        if from <> GOING_TO_LAST_MATCH
            Message('no more files')
            ChainCmd()
        endif
        return(FALSE)
    endif
    return(42)
end

/****************************************************************************
    goto_prev_file_in_hit_list()
 ****************************************************************************/
integer proc                  goto_prev_file_in_hit_list()
    if GetBufferID() == oid and Up() and lFind(name_prefix, '^b')
        scroll()
        hilite_filename()
        return(TRUE)
    else
        ChainCmd()
        return(FALSE)
    endif
    return(42)
end

/****************************************************************************
    goto_last_file_in_hit_list()
 ****************************************************************************/
proc                          goto_last_file_in_hit_list()
    EndFile()
    if lFind(name_prefix, '^b')
        scroll()
        hiLite_FileName()
    else
        ChainCmd()
    endif
end

/****************************************************************************
    goto_last_match_in_hit_list()
 ****************************************************************************/
proc                          goto_last_match_in_hit_list()
    EndFile()
    goto_prev_match_in_hit_list()
end

/**************************************************************************
        Go To Hit
 **************************************************************************/
proc                          goto_hit()
    STRING
        fn[MAXFN] = ''
top:
    /*
        Get to oid
    */
    if GetBufferID() == files_only
        toggle_show_detail()
    else
        GotoBufferID(oid)
    endif

    /*
        if no files...
    */
    if NumLines() < first_file_line
        Warn('No files matched file spec ....')
        return()
    endif

    /*
        if positioned before entries
        go to that line.
    */
    if (CurrLine() < first_file_line)
        OR (CurrLineLen() == 0)
        GotoLine(first_file_line)
    endif

    /*
        If on a divider, go to next name
    */
    while (GetText(1,1) == 'Ä') OR (CurrLineLen() == 0)
        if not Down()
            goto z42
        endif

    endwhile
    z42:

    /*
        if at EOF, go to last file with finds
    */
    if NumLines() == CurrLine()
        repeat
            Up()
        until GetText(1,Length(name_prefix)) == name_prefix OR
             (CurrLine() <= first_file_line)
    endif

    lfind(sstring, options + 'c') // to get column
    col = CurrPos()
    PushPosition()                // remember line

    /*
        if on a name in found section, use line 0
        as the line to which to go -- will trigger a find_next
    */
    if GetText(1,Length(name_prefix)) == name_prefix
        linenumber = 0
    /*
        elseif on a name in 'no hits'
        use linenumber 0
    */
    elseif FileExists(GetText(1, PosLastnonWhite()-1))  // in 'no hits'
        fn = GetText(1, PosLastnonWhite()-1)
        linenumber = 1
        goto got_fn

    /*
        else get line number to go to
        and go to file name
    */
    else
        linenumber = Val( GetText(1,getFlag(LNDIGITS)))
        while NOT (GetText(1,Length(name_prefix)) == name_prefix)
              AND (CurrLine() >= first_file_line)
            Up()
        endwhile
    endif

    /*
        get file name
    */
    fn = GetText( Length(name_prefix) + 1,
                  PosLastNonWhite() - Length(name_prefix) - Length(trim(name_suffix))
                )
    fn = Trim(fn)

  got_fn:
    PopPosition()                           // go back to line
    if FileExists(fn) or GetBufferID(fn)
        it_was_loaded = iif(GetBufferID(fn), TRUE, FALSE)
        EditFile( fn )                      // forces all hooks
        goto_hit_hit_file = GetBufferID()
        if linenumber
            GotoLine(linenumber)
            Scroll()
        else
            BegFile()
            move_around(NEXT_HIT_IN_FILE)
        endif
        GotoColumn(col - getFlag(lndigits) - 3 )
        Set(ShowHelpLine, GetFlag(SHOW_HELP_LINE))
        Disable(hit_file)
        Enable(file)
    else
        if Length(fn)
            Warn("Can't find file [" , fn, ']    '  )
            Return()
        endif
        goto top
    endif
end

/**************************************************************************
        Goto Hit List
 **************************************************************************/
proc                          goto_hit_list(INTEGER mode)
    integer
        bid = GetBufferID()

    if mode == 0                                    // initial call only
        /*
            don't know why this is HERE ...
            it is performed when TSGREP3 first starts ...
            after the TSGREP processing ...
        */
        always_save_and_unload = -42
        BegFile()
        linenumber = 1
        col = 1
        GotoLine(1)
        if lFind(name_prefix,'')
            first_file_line = CurrLine()
        else
            first_file_line = 13
        endif
        FileChanged(FALSE)
        goto exit_goto_hit_list
    endif

    /*
        File being viewed was loaded before viewing started.
        Or, menu opt 6 (never unload) was previously chosen.
        Or, we're not unloading after viewing.
    */
    if it_was_loaded
       or always_save_and_unload == NEVER_UNLOAD
       or UNLOAD_FILES_WITH_HITS_AFTER_VIEWING == FALSE
        GotoBufferID(oid)
        goto exit_goto_hit_list
    endif

    /*
        File being viewed was loaded by request to view it.
        UNLOAD_FILES_WITH_HITS_AFTER_VIEWING == TRUE;
        menuopt 5 (always save and unload) previously selected
    */
    if always_save_and_unload == ALWAYS_S_U
        if FileChanged()
            SaveAs(CurrFileName(), _OVERWRITE_)            
        endif
        GotoBufferID(oid)
        AbandonFile(bid)                          // only get here if
        goto exit_goto_hit_list
    endif

    /*
        File being viewed was loaded by request to view it.
        UNLOAD_FILES_WITH_HITS_AFTER_VIEWING == TRUE;
        file was not changed;
        no previous selection of menu opt 5 or 6
    */
    if getFlag(UNLOAD_FILES_WITH_HITS_AFTER_VIEWING) == TRUE
       and not FileChanged()
            GotoBufferID(oid)
            AbandonFile(bid)
        goto exit_goto_hit_list
    endif

    /*
        File being viewed was loaded by request to view it.
        UNLOAD_FILES_WITH_HITS_AFTER_VIEWING == TRUE;
        file was changed;
        no previous selection of menu opt 5 or 6
    */
    if getFlag(UNLOAD_FILES_WITH_HITS_AFTER_VIEWING) == TRUE
       and FileChanged()
        query_save()
        case menuOption()
            when 0  return()            // <esc> == no action
            when 1  
                    SaveAs(CurrFileName(), _OVERWRITE_)
                    GotoBufferID(oid)
                    Abandonfile(bid)
            when 2  GotoBufferID(oid)   // No Save
                    Abandonfile(bid)
            when 3  GotoBufferID(oid)   // Don't Unload
            when 4                      // Divide
            when 5  always_save_and_unload = ALWAYS_S_U
                    SaveAs(CurrFileName(), _OVERWRITE_)
                    GotoBufferID(oid)
                    Abandonfile(bid)
            when 6  always_save_and_unload = NEVER_UNLOAD
                    GotoBufferID(oid)
        endcase
        GotoBufferID(oid)
        goto exit_goto_hit_list
    endif

  exit_goto_hit_list:
    case mode
    when 0
        GotoLine(first_file_line)
        ScrolltoRow(first_file_line)
        if GetText(1, length(name_prefix)) == name_prefix
            hilite_filename()
        endif
    when 1
        if lFind(sstring, options + '+')
            scroll()
            HiLiteFoundText()
        endif
    when 3
        goto_next_file_in_hit_list(NORMAL)
    endcase

    Disable(file)
    Enable(hit_file)
end

/**************************************************************************
        hilite the filename
 **************************************************************************/
proc                          hilite_filename()
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    VGotoXY(1 + Length(name_prefix)
            + iif(Query(DisplayBoxed) == 2 or
                 (Query(DisplayBoxed) == 1 and Query(MouseEnabled)),
                  1, 0),
            CurrRow()
            + iif(Query(StatusLineAtTop) or Query(ShowHelpLine), 1, 0)
            + iif(Query(DisplayBoxed) == 2 or
                 (Query(DisplayBoxed) == 1 and Query(MouseEnabled)),
                 1, 0)
           )
    if PosLastNonWhite() - CurrPos() + 1
       PutAttr(Query(HiLiteAttr),
               PosLastNonWhite() -  CurrPos())
               // - Length(name_prefix))
    endif
end

/**************************************************************************
        Key enable
            Disables TSGREP keys when in non-tSGREP-selected files.
 **************************************************************************/
proc                          key_enable()
    disable(file)
    disable(hit_file)
    disable(no_hit_file)
    if GetBufferID() == goto_hit_hit_file
        Enable(file)
    elseif GetBufferID() == oid
        Enable(hit_file)
    elseif GetBufferID() == files_only
        Enable(no_hit_file) 
    endif
end

/**************************************************************************
        Main
 **************************************************************************/
proc                          main()
        goto_hit_hit_file = 0
        get_globals()
        hook(_ON_CHANGING_FILES_, key_enable)
        call_goto_hit_list(GetGlobalInt('TSGREP goto_hit_list mode'))
        ExecHook(_ON_CHANGING_FILES_)
        ExecHook(_ON_FIRST_EDIT_)
        ExecHook(_IDLE_)
        Set(Cursor,On)
        ShowMouse()
end

/****************************************************************************
    move_around(INTEGER arg)
 ****************************************************************************/
proc                          move_around(INTEGER arg)
    string
        old_opts[SizeOf(Options)+1] = options
    case arg
        when NEXT_HIT_IN_FILE
            if GetFlag(SEARCH_ACROSS_LINES) <> OFF and
               GetFlag(SEARCH_ACROSS_LINES) <> AUTO_OFF and
                x_line_search(F)
                scroll()
                gotoblockbegin()
                return()
            elseif lFind(sstring, options + '+')
                scroll()
                HiLiteFoundText()
                return()
            endif

            // not found!
            Alarm()
            call_goto_hit_list(3)
        when PREV_HIT_IN_FILE
            old_opts = options
            WordLeft()
            options = options + 'b' + '+'
            if GetFlag(SEARCH_ACROSS_LINES) == FAST
               or GetFlag(SEARCH_ACROSS_LINES) == SLOW
               or GetFlag(SEARCH_ACROSS_LINES) == AUTO_FAST
               or GetFlag(SEARCH_ACROSS_LINES) == AUTO_SLOW
                if not x_line_search(B)
                    Alarm()
                else
                    scroll()
                    gotoblockbegin()
                endif
            elseif lFind(sstring, options)
                scroll()
                HiLiteFoundText()
            else
                Alarm()
            endif
            options = old_opts
    endcase
end

/**************************************************************************
        Query_save()
 **************************************************************************/
menu                          query_save()
    Title ="Unloading file ... save changes?"
    "&Yes", , ," Yes: TSGREP will save changes, then unload this file."
    "&No" , , ," No: TSGREP will unload the file WITHOUT saving changes."
    "&Don't Unload File", , , " Don't: TSGREP will leave this file loaded."
    "", , divide
    "&Always Save and Unload", , , " Always: TSGREP saves and then unload files. No further prompt."
    "N&ever Unload", , , " Never: TSGREP leaves files loaded after you view them. No further prompt."
end

/**************************************************************************
        Remove File From Hit List
 **************************************************************************/
proc                          remove_file_from_hit_List()
    INTEGER
        startbuffer = GetBufferID(),
        km = Set(KillMax, 0)
    PushBlock()
    PushPosition()
    UnMarkBlock()
    EndLine()

    if startbuffer == files_only
        if GetText(1,Length(name_prefix)) <> name_prefix
            Warn('NOT on file name')
            goto exit_remove
        endif
        line = GetText(1,80)
        DelLine()
        FileChanged(FALSE)
        GotoBufferId(oid)
        begfile()
        if NOT lFind(line, '^')
            Warn("can't find ", line)
            goto exit_remove
        endif
    endif

    /*
        get to first name
    */

    if CurrLine() < first_file_line
        GotoLine(first_file_line - 1)
        if not lFind(name_prefix,'^')
            warn('No files with hits to delete')
            goto exit_remove
        endif
    endif
    while GetText(1,Length(name_prefix)) <> name_prefix
        Up()
        if CurrLine() == 1
            warn('No files with hits to delete?')
        endif
    endwhile
    MarkLine()

    /*
        get to name to delete
    */
    EndLine()
    if lFind(name_prefix, '^')
        Up()
        MarkLine()
    else
        repeat
            Down()
        until GetText(1,1) == 'Ä'
              or CurrLine() == NumLines()
        Up()
        MarkLine()
    endif

    GotoBlockBegin()
    line = GetText(1,80)
    GotoBlockEnd()
    Down()
    DelBlock()

    if startbuffer == oid
        GotoBufferId(files_only)
        if lFind(line, '^')
            DelLine()
            FileChanged(FALSE)
        endif
        GotoBufferid(oid)
    endif

    BegLine()
    case Val(flags[SAVE_HIT_LIST])
        when NEVER     FileChanged(FALSE)
    endcase
    hilite_filename()

  exit_remove:
    PopBlock()
    PopPosition()
    Set(KillMax, km)
end

proc                          scroll()
    // Reduces the scroll amount until (a) it is zero or (b) block end
    // is at the right edge of the screen.
    // Centers find if that TSE variable
    // is set.
    //
    //
    integer
        cc,
        cxo,
        cScrC,
        scr,
        desired_scroll,
        max_scroll

    if Query(CenterFinds)
        scrolltorow(query(windowrows)/2)
    endif
    PushBlock()
    MarkFoundText()

    GotoBlockEnd()
    cc = CurrPos()
    cxo = CurrXOffset()
    cScrC = cc - cxo
    GotoPos(cc)
    desired_scroll = CurrXOffset()
    max_scroll = Query(WindowCols) - cScrC
    scr = iif (max_scroll < desired_scroll, max_scroll, desired_scroll)
    if scr > 0
        repeat
            ScrollLeft()
            scr = scr -1
        until not scr
    endif
    PopBlock()
end

/**************************************************************************
        Toggle From Showing Detail to NOT Showing It
 **************************************************************************/
proc                          toggle_show_detail()
    INTEGER
        row = CurrRow(),
        km
    if GetBufferID() == oid
        if GotoBufferID(files_only) and NumLines() < first_file_line
            km = Set(KillMax,0)
            GotoBufferID(oid)
            PushPosition()
            PushBlock()
            MarkLine(1,NumLines())
            GotoBufferID(files_only)
            CopyBlock()
            repeat
                StatusBar('Creating filename-only list', 0, 0, AS_MESSAGE)
                if ( Val(GetText(1, GetFlag(LNDIGITS))))
                    DelLine()
                else
                    Down()
                endif
            until NumLines() == CurrLine()
            PopBlock()
            PopPosition()
            set(KillMax, km)
        endif

        PushPosition()
        EndLine()
        if not lFind(name_prefix, '^b')
            lFind(name_prefix, '^')
        endif
        row = CurrRow()
        line=GetText(1,CurrLineLen())
        PopPosition()
        GotoBufferId(files_only)
        BegFile()
        lFind(line,'^')
        ScrollToRow(row)
    elseif GetBufferID() == files_only
        EndLine()
        lFind(name_prefix, '^b')
        line=GetText(1,CurrLineLen())
        FileChanged(FALSE)
        GotoBufferId(oid) BegFile()
        if lFind(line,'^')
            hilite_filename()
        endif
        ScrollToRow(row)
    else
        ChainCmd()
    endif
    key_enable()
    UpdateDisplay()
end

/**************************************************************************
        Undo All "Remove File From Hit List"
 **************************************************************************/
proc                          undo_all_removes()
    INTEGER
        row = 0,
        km = Set(KillMax,0)
    PushBlock()
    UnMarkBlock()
    GotoBufferId(oid)
    repeat
    until PosFirstNonWhite() or NOT Up()
    line = GetText(1,80)
    row = CurrRow()
    col = CurrPos()
    MarkLine(1,NumLines())
    DelBlock()
    Set(KillMax,km)
    GotoBufferId(oid)
    InsertFile(outfile_copy)
    PopBlock()
    lFind(line, '^')
    ScrollToRow(row)
    GotoColumn(col)
    if SAVE_HIT_LIST == NEVER
            FileChanged(FALSE)
    endif
    UpdateDisplay()
    if GetText(1, Length(name_prefix)) == name_prefix
        BegLine()
        hilite_filename()
    else
        goto_next_match_in_hit_list()
        goto_prev_match_in_hit_list()
    endif
end


/****************************************************************************
    whenloaded()
 ****************************************************************************/
proc                          whenloaded()
    enable(deactivate)
    return()

    /*
        Remainder of this proc present only to
        avoid compiler messages.
    */
    if 'foo' == 'oof'
        YMD(line)
        goto_first_match_in_hit_list()
        goto_last_match_in_hit_list()
        set_flags_to_defaults()
        line = default_ext_2
        line = dir_list_ext
        set_globals()
        a = getting_dirs_line +
        pause + list_of_dirs + list_of_filespecs + dirs_to_be_processed +
        loading_files_line +
        getting_files_line +
        processing_line +
        files_loaded_line +
        files_processed_line +
        dirs_found_line +
        hits_line +
        abort_line +
        press_any_key_line
        a = a

    endif
end

integer proc                  x_line_search(integer dir)
    integer
        rc = FALSE,
        isCh = FileChanged(),
        r = CurrRow(),
        c = CurrCol(),
        l = CurrLine()
    case getFlag(SEARCH_ACROSS_LINES)
        when FAST, AUTO_FAST    goto fast
        when SLOW, AUTO_SLOW    goto slow
    endcase
  fast:
    while lfind (short_string, options + iif(dir == B, 'b', '+') )
        statusBar('Searching (fast x_line) ', 0, 0, AS_MESSAGE)
        mJoinLine()
        if CurrPos() <> 1 and dir <> B
            PrevChar()
        endif
        if dir == B
            MarkColumn(CurrLine(), CurrPos(), CurrLine(), CurrLineLen())
        endif
        if lFind(sstring,
                 mSubStr(options, 'b', 0, 0)    // strip 'b' from options
                 + 'c'                          // add 'c'
                 + iif(dir == B, 'l^', '')      // if Backwards searching
                 )                              // only check from curr find

            MarkFoundText()
            mSplitLine()
            rc = TRUE
            goto end_x_line
        else
            mSplitLine()
            if dir == B
                PrevChar()
            else
                NextChar()
            endif
        endif
    endwhile
    goto end_x_line
  slow:
    mJoinLine()
    loop
        statusBar('Searching (slow x_line) ', 0, 0, AS_MESSAGE)
        if lFind(sstring, options + 'c' + '+' + iif(dir == B, 'b', ''))
            MarkFoundText()
            mSplitLine()
            rc = TRUE
            goto end_x_line
        else
            mSplitLine()
            BegLine()
            if dir == B
                Up()
            else
                Down()
            endif
        endif
        if ( (dir <> B) and ( CurrLine() == NumLines() ) ) or
           ( (dir == B) and ( CurrLine() == 1 ) )
           break
        endif
        mJoinLine()
        if dir == B
            EndLine()
        endif
    endloop
  end_x_line:
    if rc
        scroll()
    else
        GotoLine(l)
        GotoColumn(c)
        ScrollToRow(r)
    endif
    UpdateDisplay(_STATUSLINE_REFRESH_)
    FileChanged(isCH)
    return(RC)
end
