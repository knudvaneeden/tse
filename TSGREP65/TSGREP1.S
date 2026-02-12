/**************************************************************************
           TSGREP ... A regular expression line extractor ... 6.4

 File TSGREP1: TSGREP options menu.
               11,100 bytes, compiled (10-14-95)
 **************************************************************************/

#INCLUDE ['tsgrep.inc']

/**************************************************************************
    DECLARATIONS - Constant, Integer, String
 **************************************************************************/

INTEGER
    flag = 0,
    after_date_hist_buff,
    before_date_hist_buff,
    context_hist_buff,
    inifile_hist_buff,
    pause_hist_buff,

    pause_num,
    context_num,
    save_loaded_num,
    search_x_num

STRING
    opt[1] = ''

STRING
    /*
        Definitions for TSGREP option characters
    */
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
             dont_decode_spacechar[1]= '_'    // :U: flag for NOT decoding space_char
                                     //     (command line operation only)

/**************************************************************************
    DECLARATIONS - Forward Procedures and Menus
 **************************************************************************/

forward proc                get_date(INTEGER which)
forward string proc         get_pause(INTEGER arg)
forward string proc         get_context(INTEGER arg)
forward string proc         get_saveLoaded(INTEGER arg)
forward string proc         get_search_x(INTEGER arg)
forward proc                main()
forward integer proc        menuRead(var string s, integer len, integer h)
forward proc                restore_defaults()
forward proc                set_args(integer arg)
forward proc                toggle_ts_opt(integer arg)
forward string proc         ts_option(integer arg)
forward menu                ts_options_menu()
forward proc                whenloaded()

/**************************************************************************
 **************************************************************************
    PROCEDURES
 **************************************************************************
 **************************************************************************/

proc                        get_date(INTEGER which)
    integer
        hb = iif(which == BEFORE, before_date_hist_buff, after_date_hist_buff)
    string
        opt[1] = iif(which == BEFORE, files_before_opt, files_after_opt),
       date[8]= iif(which == BEFORE, before_date, after_date)

    if pos(opt, ts_options)
        ts_options = mSubStr(ts_options, opt, 0, 8)
    endif
    if not menuRead(date, 9, 0)
        return()
    endif
    if length(date) and (length(date) <> 8 or
             Val(SubStr(date,1,2)) < 1 or
             Val(SubStr(date,1,2)) > 12 or
             Val(SubStr(date,4,2)) < 1  or
             Val(SubStr(date,4,2)) > 31 )
        alarm()
        Message('MM-DD-YY please')
        PushKey(<enter>)
        return()
    endif
    if length(date)
        ts_options = ts_options + opt + date
        if which == AFTER and date <> '00-00-00'
            after_date = date
            setFlag(check_dates, TRUE)
        elseif which == BEFORE and date <> '99-12-31'
            before_date = date
            setFlag(check_dates, TRUE)
        else
            setFlag(check_dates, FALSE)
        endif
        AddHistoryStr(date, hb)
    endif
end

string proc                 get_pause(INTEGER arg)
    string s[1]=''
    if pos(pause_after_messages_opt, ts_options)
        pause_num = Val(SubStr(ts_options, Pos(pause_after_messages_opt, ts_options) + 1, 1))
    else
        pause_num = getFlag(Pause_LENGTH)
    endif
    s = str(pause_num)
    if arg == 0
        return(s)
    else
        menuRead(s, 1, pause_hist_buff)
        pause_num = val(s)
        if pos(pause_after_messages_opt, ts_options)
            ts_options = mSubStr(ts_options, pause_after_messages_opt, -1, 0)
                        + SubStr(ts_options,    Pos(pause_after_messages_opt, ts_options) + 2, 255)
        endif
        ts_options = ts_options + pause_after_messages_opt + str(pause_num)
        setFlag(Pause_length, pause_num)
    endif
    return('')
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

string proc                 get_saveLoaded(INTEGER arg)
    string s[1]=''
    if pos(save_loaded_files_opt, ts_options)
        s = SubStr(ts_options, Pos(save_loaded_files_opt, ts_options) + 1, 1)
    else
        s = str(getFlag(SAVE_LOADED_FLAG))
    endif
    if arg == 0
        if ts_option(10) == 'No'
            return ('n/a')
        endif
        case val(s)
            when ALWAYS return('Always')
            when NEVER  return('Never')
            otherwise   return('Prompt')
        endcase
    endif
    if arg == 1
        case val(s)
            when ALWAYS save_loaded_num = NEVER
            when NEVER  save_loaded_num = ASKSAVE
            otherwise   save_loaded_num = ALWAYS
        endcase

        if pos(save_loaded_files_opt, ts_options)
            ts_options = mSubStr(ts_options, save_loaded_files_opt, -1, 0)
                        + SubStr(ts_options,    Pos(save_loaded_files_opt, ts_options) + 2, 255)
        endif
        ts_options = ts_options + save_loaded_files_opt + str(save_loaded_num)
    endif
    return('')
end

string proc                 get_search_x(INTEGER arg)
    if pos(search_across_lines_opt, ts_options)
        search_x_num = Val(SubStr(ts_options,
                                  Pos(search_across_lines_opt, ts_options) + 1, 1
                                  )
                          )
    else
        search_x_num = getFlag(SEARCH_ACROSS_LINES)
    endif

    if arg == 0
        case search_x_num
            when AUTO return("Auto")
            when FAST return("Fast")
            when SLOW return("Slow")
            when 0    return("Off")
            otherwise return("Hmm")
        endcase
    else
        search_x_num = iif (search_x_num == 3, 0, search_x_num + 1)
        if pos(search_across_lines_opt, ts_options)
            ts_options = mSubStr(ts_options, search_across_lines_opt, -1, 0)
                        + SubStr(ts_options, Pos(search_across_lines_opt, ts_options) + 2, 255)
        endif
        ts_options = ts_options + search_across_lines_opt + str(search_x_num)
        setFlag(SEARCH_ACROSS_LINES, search_x_num)
    endif
    return('')
end

proc                        main()
    get_globals()
    SetGlobalInt('TSGREP 6 return code', ts_options_menu())
    Set(ShowHelpLine, GetFlag(SHOW_HELP_LINE))
    set_globals()
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

menu                        other_menu()
    Title = 'Other TSGREP Options'
    History
    '&Unload Loaded Files'        [ts_option(10): 3], toggle_ts_opt(10)  , closebefore,
                                  ' If Yes, TSGREP may run a little faster when searching lots of large files.'
    'Sa&ve Loaded Files'          [get_saveLoaded(0):6],get_saveLoaded(1), dontclose,
                                  ' If Yes to "Unload Loaded", this entry controls the saving of changed files.'
    'Create &Directory List'      [ts_option(2) : 3], toggle_ts_opt(2)   , dontclose,
                                  ' If Yes, TSGREP creates a list of directories it searched (if >1).'
    '&Pause After Messages'       [get_pause(0) :1],get_pause(1),dontclose,
                                  ' Delay, in 1/16th seconds, after screen messages.'
    'Recount &Hits'               [ts_option(15): 3], toggle_ts_opt(15)  , dontclose,
                                  ' YES adds extra processing at the end, but is more accurate.'
    'Query U&nload After View'    [ts_option(6) : 3], toggle_ts_opt(6)   , dontclose,
                                  ' If you go to & change a file with matches, query for save/unload it?'
    '&Suppress TSE Messages'      [ts_option(14): 3], toggle_ts_opt(14)  , dontclose,
                                  ' If set to Yes, all warnings and messages from TSE are suppressed.'
    'Sh&ow Help Line'             [ts_option(17): 3], toggle_ts_opt(17)  , dontclose,
                                  ' Determines whether the TSE help line is enabled while TSGREP is loaded.'
    '&Go'                         , PushKey(<g>), closebefore, ' Start searching'
end

proc                        restore_defaults()
    ts_options = ''
    before_date = ''
    after_date = ''
    set_flags_to_defaults()
    PushKey(<T>)
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
        when 17 opt  = show_help_line_opt            flag = SHOW_HELP_LINE
    endcase
end

proc                        toggle_ts_opt(integer arg)
    set_args(arg)
    if Pos('-'+opt, ts_options)
        ts_options = SubStr(ts_options, 1, Pos('-'+opt, ts_options) - 1) +
                     SubStr(ts_options, Pos('-'+opt, ts_options) + 2, 255) +
                     opt
        setFlag(flag, TRUE)
    elseif Pos(opt, ts_options)
        ts_options = mSubStr(ts_options, opt, 0, 0) + '-' + opt
        setFlag(flag, FALSE)
    elseif getFlag(flag) == TRUE
        ts_options = mSubStr(ts_options, opt, 0, 0) + '-' + opt
        setFlag(flag, FALSE)
    elseif getFlag(flag) == FALSE
        ts_options = ts_options + opt
        setFlag(flag, TRUE)
    endif
    case arg
        when 4, 10, 11
             PushKey(<T>)
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

menu                        ts_options_menu()
    history Title= 'TSGREP Options'
    X = 46
    Y = 2
    'Restore &Defaults'            , restore_defaults(), closebefore,
                                  ' Restores burned-in settings.'
                                  'Search Parameters',, divide
    '&File List OnlyÄNo Search'   [ts_option(4) : 3], toggle_ts_opt(4)   , closebefore,
                                  ' If Yes, the TSGREP outfile is a list of all files matching the filespec.'
    '&One Match Only'             [ts_option(7) : 3], toggle_ts_opt(7)   , dontclose,
                                  ' If Yes, TSGREP stops searching each file after the first match in the file.'
    'Search Ac&ross Lines'        [get_search_x(0) : 4], get_search_x(1)   , dontclose,
                                  ' If used, TSGREP ignores line boundaries but operates a little to very slower.'
    'Auto Reg. E&xpr. Search'     [ts_option(12): 3], toggle_ts_opt(12)  , dontclose,
                                  ' If Yes, TSGREP adds an x to the search options when it seems appropriate.'
                                  'Outfile Contents',,divide
    '&List Matches'               [ts_option(11): 3], toggle_ts_opt(11)  , closebefore,
                                  ' If No, the TSGREP outfile is only a list of the files that contain matches.'
    '&Include Line Numbers'       [ts_option(1) : 3], toggle_ts_opt(1)   , dontclose,
                                  ' If Yes, line numbers are included in the outfile.'
    '&Context Lines'              [get_context(0):3], get_context(1) , dontclose,
                                  ' Sets the number of lines before/after each match to include in outfile.'
    'List Only Files w/&Matches'  [ts_option(5) : 3], toggle_ts_opt(5)   , dontclose,
                                  ' If Yes, excluded files and files without matches are omitted.'

                                  ' Files to Exclude'                  ,, divide
    'Files &After'                [iif(after_date =='00-00-00', '', after_date): 8], get_date(AFTER) , dontclose,
                                  ' Files are excluded unless dated after this date.'
    'Files &Before'               [iif(before_date  =='12-31-99', '', before_date): 8], get_date(BEFORE) , dontclose,
                                  ' Files are excluded unless dated before this date.'
    '&Exclude Excluded Files'     [ts_option(3) : 3], toggle_ts_opt(3)   , dontclose,
                                  ' If No, files that should be excluded due to date or extension are included,'
                                  '',, divide
    '&Save All Settings On Exit' [ts_option(16):3 ], setFlag(flag, NOT getFlag(flag)), dontclose,
                            ' Save settings to .ini file when unloading TSGREP.'
    'O&ther'                       , other_menu(),    dontclose, 'Additional options'
                                  '',, divide
    '&Go!'                        , PushKey(<g>), closeafter, ' Start searching'

end

proc                        whenloaded() after_date_hist_buff =
    GetGlobalInt('TSGREP after_date_hist_buff') before_date_hist_buff =
    GetGlobalInt('TSGREP before_date_hist_buff') context_hist_buff =
    GetGlobalInt('TSGREP context_hist_buff') inifile_hist_buff =
    GetGlobalInt('TSGREP inifile_hist_buff') pause_hist_buff =
    GetGlobalInt('TSGREP pause_hist_buff') return()

    /*
        Remainder of this proc present only to
        avoid compiler messages.
    */
    if 'foo' == 'oof'

        a = files_only + list_of_dirs + list_of_filespecs + dirs_to_be_processed +
        pause + oid + getting_dirs_line + loading_files_line + getting_files_line +
        processing_line + files_loaded_line + files_processed_line + dirs_found_line +
        hits_line + abort_line + press_any_key_line + val(default_ext_2) + val(dir_list_ext) +
        val(press_any_key_flag) + val(load_outfile_opt) + Val(dont_decode_spacechar) +
        inifile_hist_buff
        a = a
        statusbar('foo',0,0,0)
        mjoinline()
        msplitline()
        ymd(opt)
    endif
end
