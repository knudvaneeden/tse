/**************************************************************************
               TSGREP ... A regular expression line extractor ... 6.5

 File TSGREP2: Main menu and all string & flag settings
               13,616 bytes, compiled (10-24-95)
 **************************************************************************/

#INCLUDE ['tsgrep.inc']

/**************************************************************************
    DECLARATIONS - Constant, Integer, String
 **************************************************************************/

STRING
    /*
        Definitions for special characters in search string
    */
    space_char[1]       = '_',         // :U: represents   in search string
    less_than[2]        =   '[[',      // :U: represents < in search string
    greater_than[2]     = ']]',        // :U: represents > in search string
    eq_char[2]          = '\-',        // :U: represents = in search string
    or_operator[4] = '-or-',           // :U:
    and_operator[5] = '-and-',         // :U:
    line[255]='',
    opt[1],
    last_ini_file[MAXFN],
    inifile [MAXFN] = '',

    /*
        Definitions for TSGREP option characters
    */
             ini_file_opt[1]         = '!',   // :U: flag for inifile to use
             files_after_opt[1]      = 'a',   // :U: flag for dates after xx-xx-xx
             files_before_opt[1]     = 'b',   // :U: flag for dates before xx-xx-xx
             context_lines_opt[1]    = 'c',   // :U: flag for specifying lines of CONTEXT
             create_dir_list_opt[1]  = 'd',   // :U: flag for directory list only
             exclude_excluded_opt[1] = 'e',   // :U: flag for excluding excluded files
             file_list_only_opt[1]   = 'f',   // :U: flag for file listing only
             recount_hits_opt[1]     = 'h',   // :U: flag for recounting hits at end
             incl_line_numbers_opt[1]= 'i',   // :U: flag for NOT writing hits in outfile
             press_any_key_flag[1]   = 'k',   // :U: flag for 'press any key' when done //     (command line operation only)
             list_matches_opt[1]     = 'l',   // :U: flag for NOT writing hits in outfile
    list_only_files_w_matches_opt[1] = 'm',   // :U: flag for only listing filenames with hits
      query_unload_after_view_opt[1] = 'n',
             one_match_only_opt[1]   = 'o',   // :U: flag for stop after 1 hit
         pause_after_messages_opt[1] = 'p',   // :U: flag for delay interval
          search_across_lines_opt[1] = 'r',   // :U: flag for search across lines
        suppress_TSE_messages_opt[1] = 's',   // :U: flag for NOT showing any TSE msgs
             load_outfile_opt[1]     = 't',   // :U: flag for loading output file //     (command line operation only)
          unload_loaded_files_opt[1] = 'u',   // :U: flag for unloading loaded files
             save_loaded_files_opt[1]= 'v',   // :U: flag for saving load files before unl
             show_help_line_opt[1]   = 'w',   // :U: flag for showing help lines
         auto_reg_expr_search_opt[1] = 'x',   // :U: flag for auto regexp mode
             dont_decode_spacechar[1]= '_'    // :U: flag for NOT decoding space_char //     (command line operation only)

INTEGER
    context_num = 0,
    save_loaded_num = 0,
    flag = 0,
    initial_save_setting = TRUE,
    sstring_hist_buff = 0,             // history buffers for Ask()s
    infile_hist_buff = 0,              // history buffers for Ask()s
    options_hist_buff = 0,             // history buffers for Ask()s
    before_date_hist_buff = 0,         // history buffers for Ask()s
    after_date_hist_buff = 0,          // history buffers for Ask()s
    context_hist_buff = 0,
    pause_hist_buff = 0,
    inifile_hist_buff = 0,
    outfile_hist_buff = 0              // history buffers for Ask()s

/**************************************************************************
    DECLARATIONS - Forward Procedures and Menus
 **************************************************************************/

forward integer proc          ask_input()
forward proc                  change_ini_file(INTEGER file_to_use)
forward string proc           get_context(INTEGER arg)
forward proc                  get_initial_values_helper(STRING envvar, VAR STRING xstring, INTEGER biff)
forward proc                  get_initial_values()
forward integer proc          menuRead(var string s, integer len, integer h)
forward integer proc          min_positive(integer a, integer b)
forward integer proc          pos_of_whitespace()
forward proc                  process_and()
forward proc                  process_options()
forward proc                  process_searchstring()
forward proc                  process_search_x()
forward proc                  process_ts_options()
forward string proc           repl_char(STRING find_string, STRING repl_string, VAR STRING target, INTEGER extra_chars_to_replace)
forward proc                  restore_settings(integer arg)
forward proc                  save_settings()
forward proc                  set_args(integer arg)
forward menu                  TSGREP_menu()
forward string proc           ts_option(integer arg)
forward proc                  whenLoaded()

/**************************************************************************
 **************************************************************************
    PROCEDURES
 **************************************************************************
 **************************************************************************/

/**************************************************************************
        Sets some defaults, starts menu.
 **************************************************************************/
integer proc                ask_input()
    Message('TSGREP ' + v)

    /*
        SET DEFAULTS
    */
    if options == ''
        options = 'i'
    elseif options == '-i'
        options = ' '
    endif

    if outfile == ''
        outfile = default_name
    endif

    if infile == 'none.$$$'
        infile = ''
    endif

 ask_it:
    if TSGREP_menu()
        if NumFiles() == 1
           AND infile == ''
           AND CurrFileName() == '[unnamed]'
            Warn('No files are loaded. Specify files.')
            goto ask_it
        endif
        return(TRUE)
    endif
    return(FALSE)
end

proc                        save_settings()
    INTEGER
        tid = CreateTempBuffer(),
        ml = Set(MsgLevel, _WARNINGS_ONLY_)
    Message('Saving TSGREP settings...')
    AddLine('*** TSGREP Settings ' +  GetDateStr()+' '+GetTimeStr() + ' ***')
    AddLine('TSGREP_Search_String = ' + sstring)
    AddLine('TSGREP_Infile(s) = '     + infile)
    AddLine('TSGREP_Search_Options = '+ options)
    AddLine('TSGREP_Options_1 (current flags) = '     + flags)
    AddLine('TSGREP_Options_2 (options) = '     + ts_options)
    AddLine('TSGREP_Output_File = '   + outfile)
    AddLine('TSGREP_After_Date = '    + after_date)
    AddLine('TSGREP_Before_Date = '   + before_date)
    AddLine("Don't Postpone Joy!")
    SaveAs(inifile, _OVERWRITE_)
    AbandonFile(tid)
    Set(MsgLevel, ml)
    Message('TSGREP settings saved')
end

proc                        restore_settings_helper(VAR STRING what)
    line = GetText(1,PosLastNonWhite())
    what = Trim(mSubStr(line, '=', +1, 0))
    Down()
end

proc                        restore_settings(integer arg)
    integer
        tid = 0,
        eo = GetFlag(EXECUTED_ONCE),
        tm = GetFlag(TSGREP_MODE),
        ml = Set(MsgLevel, _WARNINGS_ONLY_)

    if not FileExists(inifile)
        warn("Can't find ", inifile)
        Set(MsgLevel, ML)
        return()
    endif

    tid = CreateTempBuffer()
    PushBlock()
    InsertFile(inifile)
    PopBlock()
    GotoLine(2)
    restore_settings_helper(sstring)
    restore_settings_helper(infile)
    restore_settings_helper(options)
    restore_settings_helper(flags)
        SetFlag(EXECUTED_ONCE, eo)              // don't want these
        SetFlag(TSGREP_MODE, tm)                // restored
    restore_settings_helper(ts_options)
    restore_settings_helper(outfile)
    restore_settings_helper(after_date)
    restore_settings_helper(before_date)
    AbandonFile(tid)
    if GetGlobalInt('TSGREP EO') == TRUE
        setFlag(EXECUTED_ONCE, TRUE)
    endif
    set_globals()
    if arg == 2
        SetGlobalInt('TSGREP exe 2 again', TRUE)
    endif
    Set(MsgLevel, ML)
end

proc                        get_initial_values_helper(STRING global_name,
                               VAR STRING string_to_set,
                               INTEGER hist_buffer)
    if getFlag(TSGREP_MODE) == CMDLINE
        string_to_set = GetEnvStr(global_name)
        if hist_buffer
            AddHistoryStr(string_to_set, hist_buffer)
        endif
    else
        string_to_set = GetGlobalStr('TSGREP ' + global_name)
    endif
end

/**************************************************************************
        get_initial_values
 **************************************************************************/
proc                        get_initial_values()
    if getFlag(EXECUTED_ONCE) == FALSE and Length(GetEnvStr('SSTRING') )
        setFlag(TSGREP_MODE, CMDLINE)
    else
        setFlag(TSGREP_MODE, INTERACTIVE)
        short_string = GetGlobalStr('TSGREP short_string')
    endif
    if getFlag(EXECUTED_ONCE) == FALSE
        //
        //                         global name   string      buffer
        //                         ------------  ----------- -------------------
        get_initial_values_helper ('SSTRING',    sstring,    sstring_hist_buff)
        get_initial_values_helper ('INFILE',     infile,     infile_hist_buff)
        get_initial_values_helper ('OPTIONS',    options,    options_hist_buff)
        get_initial_values_helper ('TS_OPTIONS', ts_options, 0)
        get_initial_values_helper ('OUTFILE',    outfile,    outfile_hist_buff)
    endif
end

/**************************************************************************
        Main() processing
 **************************************************************************/
proc                        main()
    get_globals()

    if GetGlobalStr('TSGREP2 action') == 'SaveSettingsOnly'
        if getFlag(SAVE_SETTINGS_WHEN_UNLOADED) == TRUE
            save_settings()
        elseif getFlag(SAVE_SETTINGS_WHEN_UNLOADED) == FALSE and initial_save_setting == TRUE
            restore_settings(2)
            setFlag(SAVE_SETTINGS_WHEN_UNLOADED, FALSE)
            save_settings()
        endif
        return()
    endif

    get_initial_values()
    /*
        Make sure date values initialized.
    */
    if not length(before_date)
        before_date = '12-31-99'
    endif
    if not length(after_date)
        after_date = '00-00-00'
    endif

    /*
        Return SEARCH_ACROSS_LINES to AUTO state.
    */
    if getFlag(SEARCH_ACROSS_LINES) == AUTO_SLOW or
       getFlag(SEARCH_ACROSS_LINES) == AUTO_FAST or
       getFlag(SEARCH_ACROSS_LINES) == AUTO_OFF
       setFlag(SEARCH_ACROSS_LINES, AUTO)
    endif

    if getFlag(tsgrep_mode) == INTERACTIVE or
       getFlag(EXECUTED_ONCE) == TRUE
        SetGlobalInt( 'TSGREP 2 return code', ask_input() )
    else
        SetGlobalInt( 'TSGREP 2 return code', TRUE )
    endif

    timer(INIT_TIMER)

    if GetGlobalInt('TSGREP 2 return code') == TRUE
        process_ts_options()
        process_options()
        process_searchstring()
        process_search_x()
    endif
    setFlag(EXECUTED_ONCE, TRUE)
    setFlag(TSGREP_MODE, INTERACTIVE)
    set_globals()
    SetGlobalInt('TSGREP EO', TRUE)
    return()
end

/**************************************************************************
        MenuRead - from SemWare's Compile.s, version 1.51o
        modified to add history, other actions
 **************************************************************************/
integer proc                menuRead(var string s, integer len, integer h)
    integer
        x = WhereXAbs(),
        y = WhereYAbs(),
        rc,
        BA,
        MA
    case h
        when sstring_hist_buff      Message(or_operator, ' == |    ',                         and_operator,' == AND. (Braces are supplied by TSGREP.)')
        when options_hist_buff      Message( '^wix$')
        when infile_hist_buff       Message(list_file_char, ' == list file;  ',                         recurse_char, ' == search subdirectories')
        when after_date_hist_buff   Message('MM-DD-YY')
        when before_date_hist_buff  Message('MM-DD-YY')
    endcase
    BA = Set(BlockAttr, Query(TextAttr))
    MA = Set(MsgAttr,   Query(CursorAttr))
    Window(X, Y, X + len - 1, Y + 1)
    rc = Read(s, h)
    FullWindow()
    Set(BlockAttr, BA)
    Set(MsgAttr, MA)
    Message('TSGREP ' + v)
    return(rc)
end

/**************************************************************************
        Min positive number of two numbers.
        Returns -1 if both args are <1
 **************************************************************************/
integer proc                min_positive(integer a, integer b)
    if b < 1 and a < 1
        return(-1)
    elseif a >= 1 and b < 1
        return(a)
    elseif b >= 1 and a < 1
        return(b)
    elseif a < b
        return(b)
    endif
    return(a)
end

/**************************************************************************
        Position of WhiteSpace
            This procedure determines the position of the
            the character at which sstring could be split
            over two lines (if any).
 **************************************************************************/
integer proc                pos_of_whitespace()
    integer
        r = -1,
        w,
        e

    r = min_positive( Pos(' ', sstring), Pos(chr(9), sstring) )
    if NOT Pos('x', options)
        return(r)
    endif

    /*
        Constructs below valid for regular expression
        searches only.
    */
    r = min_positive( r, Pos('\d032', sstring) )        // space
    r = min_positive( r, Pos('\o040', sstring) )
    r = min_positive( r, Pos('\x20',  sstring) )
    r = min_positive( r, Pos('\d009', sstring) )        // tab
    r = min_positive( r, Pos('\o011', sstring) )
    r = min_positive( r, Pos('\x09',  sstring) )
    w = Pos('.', sstring)
    e = Pos('\', sstring)
    r = min_positive( r,                                // non-escaped wildcard
                      iif ( w and not e,
                            w,
                            iif( w and e and ((e + 1) <> w),
                                 w,
                                 0 )
                           )
                    )
    return(r)
end

/**************************************************************************
        Helper for Process Options
 **************************************************************************/
integer proc                process_ts_options_helper(STRING opt, INTEGER flag)
    if pos('-'+ opt, ts_options)
        setFlag(flag, FALSE)
        return(FALSE)
    elseif pos(opt, ts_options)
        setFlag(flag, TRUE)
        return(TRUE)
    endif
    return(-1)
end

/**************************************************************************
        Helper 2 for Process Options
 **************************************************************************/
proc                        process_ts_options_helper2(STRING opt, INTEGER flag)
    if pos(opt, ts_options)
        setFlag(flag,
                Val(SubStr(ts_options,
                           Pos(opt,ts_options) + 1, 1)))
    else
        setFlag(flag, 0)
    endif
end

/**************************************************************************
        Helper 3 for Process Options
 **************************************************************************/
integer proc                process_ts_options_helper3(STRING opt,
                                                       VAR STRING date,
                                                       INTEGER which)
    if Pos(opt, ts_options)
        date = SubStr(ts_options, Pos(opt, ts_options) + 1, 8)
        return(TRUE)
    endif

    if which == AFTER
        date = '00-00-00'
    else
        date = '12-31-99'
    endif
    return(FALSE)
end

/**************************************************************************
        Process Options
 **************************************************************************/
proc                        process_options()
    StatusBar('Processing options...',0,0, AS_MESSAGE)
    if Length(options) == 0                 // set default options
        options = 'i'
    endif
    /*
        Get rid of unusable/problematic TSE options.
    */
    options = repl_char('g', '', options, 0)
    options = repl_char('b', '', options, 0)
    options = repl_char('c', '', options, 0)
    options = repl_char('+', '', options, 0)
    options = repl_char('l', '', options, 0)
    options = repl_char('a', '', options, 0)
    /*
        Set reg exp mode if certain STRINGs in search STRING,
        unless no_re_opt option used.
        :U: Edit here to change to string used to cause automatic re search
    */
    line = Lower(sstring)
    and_operator = Lower(and_operator)
    or_operator = Lower(or_operator)        // in case someone defines
    if (                                    // variable with upper case
        Pos (or_operator,    line)
        OR Pos(and_operator, line)
        OR Pos(".*",         line)
        OR Pos("|",          line)
        OR (
           Pos("[" ,         line)
           AND Pos("]" ,     line)
          )
       )
       AND GetFlag(AUTO_RE_FLAG)    // if NOT overridden
       AND NOT Pos('x', options)           // if NOT present already
        options = options + 'x'
    endif
end

proc                        process_ts_options()
    StatusBar('Processing TSGREP options...',0,0, AS_MESSAGE)

    process_ts_options_helper(create_dir_list_opt, MAKE_LIST_OF_DIRS)
    /*
        If not doing a recursive search,
        do not create a dir_list
    */
    if NOT Pos(recurse_char, infile)
        setFlag(MAKE_LIST_OF_DIRS, FALSE)
    endif

    process_ts_options_helper(auto_reg_expr_search_opt, AUTO_RE_FLAG)

    process_ts_options_helper(list_only_files_w_matches_opt, LIST_FILES_W_HITS_ONLY)
    /*
        If doing a file list only operation (no search),
        make sure that LIST_FILES_W_HITS_ONLY is FALSE
    */
    set_Args(4)
    if ts_option(4) == 'Yes'                    // file list only
        setFlag(LIST_FILES_W_HITS_ONLY, FALSE)
    endif

    process_ts_options_helper(recount_hits_opt, RECOUNT_HITS_FLAG)
    process_ts_options_helper(unload_loaded_files_opt, UNLOAD_LOADED_FILES)
    process_ts_options_helper(press_any_key_flag, PRESS_ANY_KEY)
    process_ts_options_helper(query_unload_after_view_opt, UNLOAD_FILES_WITH_HITS_AFTER_VIEWING)
    process_ts_options_helper2(pause_after_messages_opt, PAUSE_LENGTH)

    process_ts_options_helper(one_match_only_opt, ONE_HIT_ONLY_PER_FILE)
    if process_ts_options_helper3(files_after_opt, after_date, AFTER) or
       process_ts_options_helper3(files_before_opt, before_date, BEFORE)
        setFlag(CHECK_DATES, TRUE)
    endif

    if process_ts_options_helper(file_list_only_opt, FILES_ONLY_NO_SEARCH) == TRUE
        sstring = ''
        options = ''
    endif

    process_ts_options_helper(list_matches_opt, WRITE_HITS)
    process_ts_options_helper(create_dir_list_opt, MAKE_LIST_OF_DIRS)
    process_ts_options_helper(load_outfile_opt, LOAD_OUT_FILE)
    process_ts_options_helper(incl_line_numbers_opt, LINE_NUMBERS)
    process_ts_options_helper(suppress_TSE_messages_opt, NO_WARNING_FLAG)

    if Pos(save_loaded_files_opt, ts_options)
        save_loaded_num = Val(SubStr(ts_options,Pos(save_loaded_files_opt,ts_options)+1,1))
        if save_loaded_num <> NEVER and
           save_loaded_num <> ALWAYS
           save_loaded_num = ASKSAVE
        endif
        setFlag(SAVE_LOADED_FLAG, save_loaded_num)
    else
        //  no set -- keep default
    endif

    process_ts_options_helper2(context_lines_opt, CONTEXT)
    if getFlag(CONTEXT) == 1
        warn('Setting CONTEXT to 2 (minimum value)')
        setFlag(CONTEXT, 2)
    endif

    process_ts_options_helper2(ini_file_opt, INIFILE_NUMBER)
    if GetFlag(INIFILE_NUMBER)
        change_ini_file(getFlag(INIFILE_NUMBER))
    endif
end

/**************************************************************************
        Process the 'and' operator in search string
 **************************************************************************/
proc                        process_and()
    STRING
        part1[MAXSPEC] = '',
        part2[MAXSPEC] = ''

    part1 = mSubStr(sstring, and_operator, - 1, 0)
    part2 = mSubStr(sstring, and_operator, + 1, 0)
    sstring = '{'+ part1 + '.*' + part2 + '}|{' + part2 + '.*' + part1 + '}'
end

/**************************************************************************
        Process Search String
 **************************************************************************/
proc                        process_searchstring()
    integer tid
    Statusbar('Processing search string...', 0,0, AS_MESSAGE)
    /*
    Decode Searchstring

        Substitute < for less_than
        Substitute > for greater_than
    */
    sstring = repl_char(less_than, '<', sstring, 0)
    sstring = repl_char(greater_than, '>', sstring, 0)

    /*
        Substitute | for or_operator
    */
    if Pos('x', options)                    // regexp only
       and GetFlag(AUTO_RE_FLAG)
        sstring = repl_char(or_operator, '|', sstring, 0)
    endif

    /*
        Substitute = for eq_char
    */
    sstring = repl_char(eq_char, '=', sstring, 0) // decode equal signs

    /*
        Set up AND
    */
    if Pos(and_operator, sstring)
       and GetFlag(AUTO_RE_FLAG)
        process_and()
    endif

    /*
        Substitute spaces for space char
    */
    if NOT Pos(dont_decode_spacechar, ts_options)             // decode spaces
       AND getFlag(TSGREP_MODE) == CMDLINE
        sstring = repl_char(space_char,  ' ', sstring, 0)
    endif

    /*
        Provide Default Braces if | is used with regular expr.
    */
    if Pos('|', sstring) and GetFlag(AUTO_RE_FLAG)
        tid = CreateTempBuffer()
        InsertText(sstring)                // put STRING in buffer
        BegFile()
        while lFind ('[\}]\|\c[~\{]', 'gx') // process {...}|...
            InsertText('{')               // becomes {...}|{...}
            EndLine()
            InsertText('}')
        endwhile
        while lFind ('[~\}]\c\|[\{]', 'gx')// process ...|{...}
            InsertText('}')               // becomes {...}|{...}
            BegLine()
            InsertText('{')
        endwhile
        if lFind ('[~\}]\|[~\{]', 'x')     // process ...|...
           Replace('{[~\}]}{\|}{[~\{]}', '\1}\2{\3', 'gnx')
           BegLine()                       // becomes {...}|{...}
           InsertText('{')
           EndLine()
           InsertText('}')
        endif
        BegLine()
        sstring = GetText(1,CurrLineLen())
        AbandonFile(tid)
    endif
end

/**************************************************************************
    process_search_x()
        Set the correct search across lines option
 **************************************************************************/
proc                        process_search_x()
    INTEGER
        w = pos_of_whitespace()

    if GetFlag(SEARCH_ACROSS_LINES) == AUTO             // AUTO MODE
        if  w >= 0
            if Pos('x', options)                    // if "or"
               and
                  ( Pos( '}|{', sstring )
                    OR
                    (
                        (Pos('[', sstring)
                         and (w > Pos('[', sstring))
                         and (w < Pos(']', sstring))
                        )
                    )
                   )
                SetFlag(SEARCH_ACROSS_LINES, AUTO_SLOW)
            else
                SetFlag(SEARCH_ACROSS_LINES, AUTO_FAST)
                short_string = SubStr( sstring, 1, w - 1)
            endif
        else                                                // No whitespace
            SetFlag(SEARCH_ACROSS_LINES ,AUTO_OFF)          // can't cross line
        endif
    elseif GetFlag(SEARCH_ACROSS_LINES) == FAST
        if w >=0
            short_string = SubStr( sstring, 1, w - 1)
        else
            Warn('No whitespace character ... turning off across line search')
            SetFlag(SEARCH_ACROSS_LINES , OFF)              // can't cross line
        endif
    endif

    if GetFlag(CONTEXT) and GetFlag(SEARCH_ACROSS_LINES) >= FAST and
                            GetFlag(SEARCH_ACROSS_LINES) <= AUTO_SLOW
        Warn('Context & Search X Lines are incompatible; turning off context')
        get_context(-1)
    endif
end

/**************************************************************************
    repl_char()
        Replace character with a string -- utility proc
 **************************************************************************/
string proc                 repl_char(STRING find_string,
                                      STRING repl_string,
                                      VAR STRING target,
                                      INTEGER extra_chars_to_replace)
    if not Pos(find_string, target)
        return(target)
    endif

    while Pos(find_string, target)
        target = mSubStr(target, find_string, -1, extra_chars_to_replace) +
                 repl_string +
                 mSubStr(target, find_string, +1 , extra_chars_to_replace)
    endwhile
    return(target)
end

proc                        whenLoaded()
    last_ini_file[MAXFN] = SplitPath( LoadDir(), _DRIVE_|_DIRECTORY_) + 'tsgrep'
    if sstring_hist_buff == 0               // set up histories for Asks
        sstring_hist_buff = _FIND_HISTORY_
        options_hist_buff = _FIND_OPTIONS_HISTORY_
        infile_hist_buff  = GetFreeHistory('TSGREP:infile')
        outfile_hist_buff = GetFreeHistory('TSGREP:outfile')
        after_date_hist_buff =  GetFreeHistory('TSGREP:afterdate')
            SetGlobalInt('TSGREP after_date_hist_buff', after_date_hist_buff)
        before_date_hist_buff = GetFreeHistory('TSGREP:beforedate')
            SetGlobalInt('TSGREP before_date_hist_buff', before_date_hist_buff)
        context_hist_buff =     GetFreeHistory('TSGREP:context')
            SetGlobalInt('TSGREP context_hist_buff', context_hist_buff)
            AddHistoryStr('0', context_hist_buff)
        inifile_hist_buff =     GetFreeHistory('TSGREP:inifile')
            SetGlobalInt('TSGREP inifile_hist_buff', inifile_hist_buff)
        pause_hist_buff =       GetFreeHistory('TSGREP:pause')
            SetGlobalInt('TSGREP pause_hist_buff', pause_hist_buff)
            AddHistoryStr('0', pause_hist_buff)
    endif

    inifile = GetEnvStr('TSGREP_INI_FILE')
    if not length(inifile)
         inifile = lower(LoadDir() + 'tsgrep.ini')
    endif
    AddHistoryStr(inifile, inifile_hist_buff)
    if FileExists(inifile)
        restore_settings(1)
        initial_save_setting = GetFlag(SAVE_SETTINGS_WHEN_UNLOADED)
    endif
    return()

    /*
        Remainder of this proc present only to
        avoid compiler messages.
    */
    if 'foo' == 'oof'
        set_flags_to_defaults()
        mSplitLine()
        mJoinLine()
        YMD(default_ext_2)
        line = dir_list_ext
        a = getting_dirs_line +
        pause +
        loading_files_line +
        getting_files_line +
        processing_line +
        files_loaded_line +
        files_processed_line +
        dirs_found_line +
        hits_line +
        abort_line +
        press_any_key_line +
        files_only + list_of_dirs + list_of_filespecs + dirs_to_be_processed +
        oid
        a = a + asc(show_help_line_opt)
    endif
end

proc                        set_args(integer arg)
    case arg
        when  1 opt  = incl_line_numbers_opt         flag = LINE_NUMBERS
        when  2 opt  = create_dir_list_opt           flag = MAKE_LIST_OF_DIRS
        when  3 opt  = exclude_excluded_opt          flag = EXCLUDE_FILES
        when  4 opt  = file_list_only_opt            flag = FILES_ONLY_NO_SEARCH
        when  5 opt  = list_only_files_w_matches_opt flag = LIST_FILES_W_HITS_ONLY
        when  6 opt  = query_unload_after_view_opt   flag = UNLOAD_FILES_WITH_HITS_AFTER_VIEWING
        when  7 opt  = one_match_only_opt            flag = ONE_HIT_ONLY_PER_FILE
        when  9 opt  = search_across_lines_opt       flag = SEARCH_ACROSS_LINES
        when 10 opt  = unload_loaded_files_opt       flag = UNLOAD_LOADED_FILES
        when 11 opt  = list_matches_opt              flag = WRITE_HITS
        when 12 opt  = auto_reg_expr_search_opt      flag = AUTO_RE_FLAG
        when 13 opt  = save_loaded_files_opt         flag = SAVE_LOADED_FLAG
        when 14 opt  = suppress_TSE_messages_opt     flag = NO_WARNING_FLAG
        when 15 opt  = recount_hits_opt              flag = RECOUNT_HITS_FLAG
        when 16 opt  = ''                            flag = SAVE_SETTINGS_WHEN_UNLOADED
    endcase
end

string proc                 ts_option(integer arg)
    set_args(arg)
    if (arg == 7 or
        arg == 11 or
        arg == 1)
       and ts_option(4) == 'Yes'
        return('n/a')
    endif

    set_args(arg)
    if arg == 15 and ts_option(11) == 'No'
        return('n/a')
    endif

    set_args(arg)
    if arg == 1 and ts_option(11) == 'No'
        return('n/a')
    endif
    set_args(arg)
    if arg == 5 and ts_option(4) == 'Yes'
        return('n/a')
    endif
    set_args(arg)

    if Pos('-'+opt, ts_options)
        return('No')
    elseif Pos(opt, ts_options)
        return('Yes')
    endif
    return( iif (getFlag(flag),'Yes','No'))
end

string proc                 get_context(INTEGER arg)
    // 0 = return present value
    // -1 = set to 0
    // other = Prompt for value.
    string s[1]=''
    if pos(context_lines_opt, ts_options)
        context_num = Val(SubStr(ts_options, Pos(context_lines_opt, ts_options) + 1, 1))
    else
        context_num = getFlag(CONTEXT)
    endif
    s = str(context_num)
    if arg == 0
        if ts_option(11) == 'No' or
           ts_option(11) == 'n/a'
            return('n/a')
        else
            return(s)
        endif
    else
        if arg == -1                // for forcing it off
            context_num = 0
        else
            menuRead(s, 1, context_hist_buff)
            context_num = val(s)
        endif
        if pos(context_lines_opt, ts_options)
            ts_options = mSubStr(ts_options, context_lines_opt, -1, 0)
                        + SubStr(ts_options,    Pos(context_lines_opt, ts_options) + 2, 255)
        endif
        ts_options = ts_options + context_lines_opt + str(context_num)
        setFlag(CONTEXT, context_num)
    endif
    return('')
end

proc                        execute_tsgrep_1()
    set_globals()
    execmacro('tsgrep1')
    get_globals()
end

/**************************************************************************
        Interface menu
 **************************************************************************/
menu                        TSGREP_menu()
    x = 1
    y = 2
    '&Search String'  [format(sstring:-59) : 59]   , MenuRead(sstring, 59, sstring_hist_buff) , dontclose,
                      ' String to search for.'
    'Search &Files'   [format(infile:-59)  : 59]   , MenuRead(infile, 59, infile_hist_buff),    dontclose,
                      ' Files to search (in addition to loaded files).'
    'Search &Options' [format(options:-59) : 59]   , MenuRead(options, 59, options_hist_buff),  dontclose,
                      ' TSE search options.'
    '&TSGREP Options' [format(ts_options:-59) : 59],  execute_TSGREP_1(), dontclose,
                      ' Options controlling TSGREP operations.'
    '&Output File'    [format(outfile:-59) : 59]   , MenuRead(outfile, 59, outfile_hist_buff),  dontclose,
                      ' File to create.'
    '', , divide
    '&Go!', , closeallbefore,  ' Start searching.'
    '', , divide
    'Sa&ve Settings'                                  , save_settings()                  ,  dontclose,
                            ' Save settings to .ini file.'
    '&Restore Settings'                            , restore_settings(2)                     ,  closeafter,
                            ' Load settings from .ini file.'
    '&Change .ini File Name'  [format(inifile:-52) : 52], change_ini_file(0), dontclose,
                            ' Name of .ini file.'

end

    


string proc next_ini_file()
    integer
        x,
        l = Length(SplitPath(last_ini_file, _EXT_))

    if l == 0
        last_ini_file = last_ini_file + '. '
        l = 2
    elseif l == 1
        last_ini_file = last_ini_file + '.'
        l = 2
    endif

    if substr( SplitPath(last_ini_file, _EXT_),l,1) > '0'  and
       substr( SplitPath(last_ini_file, _EXT_),l,1) < '9'
        x = val(substr( SplitPath(last_ini_file, _EXT_),l,1)) + 1
    else
        x = 1
    endif
    last_ini_file = SubStr(last_ini_file, 1, length(last_ini_file) - 1)
                    + Str(x)
    return(last_ini_file)
end

menu change_ini_menu()
    History
    '&0' [ format(last_ini_file  :-52):52],, closeafter
    '&1' [ format(next_ini_file():-52):52],, closeafter
    '&2' [ format(next_ini_file():-52):52],, closeafter
    '&3' [ format(next_ini_file():-52):52],, closeafter
    '&4' [ format(next_ini_file():-52):52],, closeafter
    '&5' [ format(next_ini_file():-52):52],, closeafter
    '&6' [ format(next_ini_file():-52):52],, closeafter
    '&7' [ format(next_ini_file():-52):52],, closeafter
    '&8' [ format(next_ini_file():-52):52],, closeafter
    '&9' [ format(next_ini_file():-52):52],, closeafter
    '&Other' [format('':52:' '):52], MenuRead(inifile, 52, inifile_hist_buff), closeafter
end

proc change_ini_file(INTEGER file_to_use)
    // mode is either 0 (menu mode)
    // or 1-9 (ini file to use)
    INTEGER
        x = file_to_use,
        l
    last_ini_file = inifile
    l = Length(SplitPath(last_ini_file, _EXT_))
    if l == 0
        last_ini_file = last_ini_file + '. '
        l = 2
    elseif l == 1
        last_ini_file = last_ini_file + '.'
        l = 2
    endif
    if substr( SplitPath(last_ini_file, _EXT_),l,1) >= '0'  and
       substr( SplitPath(last_ini_file, _EXT_),l,1) <= '9'
        last_ini_file = SubStr(last_ini_file, 1, length(last_ini_file) - 1)
                    + ' '
    endif
    if NOT file_to_use
        change_ini_menu()
        case MenuOption()
            when 0,1     return()  // leave as is
            when 11      return()  // leave as is
            when 2..10   x = MenuOption() - 1
        endcase
    endif
    case Pos('.', inifile)
        when length(inifile)
            inifile = inifile + str(x)
        when 0
            inifile = inifile + '.' + str(x)
        otherwise
            inifile = SubStr(inifile, 1, length(inifile) - 1) + Str(x)
    endcase
    AddHistoryStr(inifile, inifile_hist_buff)
end
