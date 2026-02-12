/**************************************************************************
               TSGREP ... A regular expression line extractor ... v6.5

 File TSGREP: Common routines
 **************************************************************************/

CONSTANT
    use_tsgrep_colors = TRUE,
    dirs_with_extensions = TRUE,       // :U: set to TRUE if you have directories
                                       //     that include extensions (.xxx)
                                       //     as part of their name.
                                       // :U: set to FALSE if you don't.
                                       //     (slightly faster)
    ffNORMAL    = 0x00,                // Used by ffAttr()
    ffSUBDIR    = 0x10,                // Used by ffAttr()

    MAXFN = 60,                         // :U: largest file name TSGREP can handle
    MAXSPEC = 120,                      // :U: largest input file spec
    MAX_LINE = 2032,                    // TSE MAX

    CMDLINE = 0,
    INTERACTIVE = 1,

    NEVER = 0,
    ALWAYS = 1,
    ASKSAVE = 2,
    NEVER_UNLOAD = 4,
    ALWAYS_S_U = 5,

    WAS_LOADED = 1,                    // flags in CFID for load/unload
    WAS_LOADED_BUT_IS_EXCLUDED = 2,
    LOADED_BY_TSGREP = 3,
    EXCLUDED = 4,
    TSGREP_WORK_FILE = 5,

    AUTO = 1,                          // values for x_line searching
    FAST = 2,
    SLOW = 3,
    AUTO_FAST = 4,
    AUTO_SLOW = 5,
    AUTO_OFF = 6,

    IN_WINDOW = 1,                      // statusbar
    AS_MESSAGE = 2,

    F = 1,
    B = 2,

    NORMAL = 1,
    INTERRUPTED = 2,
    NOT_LOADING_OUTFILE = 3,

    BEFORE = 1,                         // for get_date
    AFTER = 2

INTEGER
    //  ** display line numbers ** //
    getting_dirs_line =     9,         // display lines
    loading_files_line =    9,         // display lines
    getting_files_line =    9,         // display lines
    processing_line =       9,         // display lines
    files_loaded_line =    10,         // display lines
    files_processed_line = 10,         // display lines
    dirs_found_line =      10,         // display lines
    hits_line =            11,         // display lines
    time_line =            12,         // display lines
    abort_line =           14,         // display lines
    press_any_key_line =   14,         // display lines

    break_point = 0,                   // for mJoinLine, mBeakLine
    files_only = 0,                    // id for copy with only files
    goto_hit_list_mode,
    join_line = 0,
    list_of_dirs = 0,                  // buffer for dirs_only file
    list_of_filespecs,                 // a buffer to hold multiple file specs
    dirs_to_be_processed,              // a buffer to hold this list
    pause = 0,
    oid = 0                            // buffer to become output file

STRING
    after_date[12] = '' ,               // used for date checking
    before_date[12] = '',               // used for date checking
    default_ext_2[4]    =      ".$MP", // :U: ext for files-only list
    default_name[MAXFN] ="TSGREP.TMP", // :U: default for above
    default_name_2[MAXFN] ='',
    dir_list_ext[4]     =      ".D$$", // :U: name for dirs-only list
    flags[30] = '',
    infile[MAXSPEC]  ='',              // filespec for input
    name_prefix[5] = '°±² ',          // :U: inserted into outfile before name
    name_suffix[1] = ':',              // :U: inserted into outfile after name
    old_white_at_bol[64]='',           // mSplitLine, mJoinLine()
    old_white_at_eol[64]='',           // mSplitLine, mJoinLine()
    options[58],
    outfile[MAXFN]  ='',               // filespec for output
    outfile_copy[MAXFN]  ='',          // filespec for output
    short_string[254] ='',             // search STRING - 1st part
    sstring[255],
    ts_options[255],
    v[3]= '6.5',                       // TSGREP version
    /*
        Definitions for special characters in filespec
    */
    recurse_char[1]   = '+' ,          // :U: recursive search indicator
    list_file_char[1] = '@'            // :U: list file flag

CONSTANT
    AUTO_RE_FLAG = 1,
    CHECK_DATES = 2,
    CONTEXT = 3,
    DIRFILE = 4,
    EXCLUDE_FILES = 5,
    EXECUTED_ONCE = 6,
    FILES_ONLY_NO_SEARCH = 7,
    LINE_NUMBERS = 8,
    LIST_FILES_W_HITS_ONLY = 9,
    LNDIGITS = 10,
    LOAD_OUT_FILE = 11,
    MAKE_LIST_OF_DIRS = 12,
    NO_WARNING_FLAG = 13,
    ONE_HIT_ONLY_PER_FILE = 14,
    PAUSE_LENGTH = 15,
    PRESS_ANY_KEY = 16,
    SAVE_CHANGED_FILES = 17,
    SAVE_HIT_LIST = 18,
    SAVE_LOADED_FLAG = 19,
    SEARCH_ACROSS_LINES = 20,
    TSGREP_MODE = 21,
    UNLOAD_FILES_WITH_HITS_AFTER_VIEWING = 22,
    UNLOAD_LOADED_FILES = 23,
    WRITE_HITS = 24,
    RECOUNT_HITS_FLAG = 25,
    SAVE_SETTINGS_WHEN_UNLOADED = 26,
    INIFILE_NUMBER = 27,
    SHOW_HELP_LINE = 28

forward integer proc          mJoinLine()           // joins with ' ' betw.
forward         proc          mSplitLine()          // breaks two line joined by mJoinLine()
forward         proc          paint_message(INTEGER line_number,
                                            INTEGER spaces,
                                            STRING the_message,
                                            INTEGER how_wide,
                                            INTEGER delay_after)

proc                          setFlag(INTEGER position, INTEGER value)
    string
        oldflags[SizeOf(flags)] = flags
    if position > length(flags)
        warn('cannot set flag in position ', value)
        return()
    endif
    flags = SubStr(oldflags, 1, position - 1)
    flags = flags + Str(value)
    flags = flags + SubStr(oldflags, position + 1, Length(oldflags) - position)
end

/**************************************************************************
        getFlag
            Queries flags
 *************************************************************************/
integer proc                  getFlag(INTEGER position)
    return(Val(flags[position]))
end

/**************************************************************************
        mSubStr
 **************************************************************************/
string proc                   mSubstr(STRING s, STRING t, INTEGER op, INTEGER extra)
     /*
     s = string
     t = target
     op -1 = return string up to target
        +1 = return string from past target to end
        0  = return string without target
     extra = # of extra chars to remove
     */
     string
        rc[255] = ''
     integer
        p = Pos(t,s),           // starting char of target in string
        lt = Length(t),         // length of target
        plt = p + lt,           // ending char of target
        plte = plt + extra,     // ending char of target + extra chars
        suffix_lt = Length(s) - lt - extra
                                //
     if p                       // if target is indeed part of string
        case op
            when -1 return (substr(s, 1, p-1))
            when +1 return (substr(s, plte, suffix_lt))
            when  0 rc = substr(s, 1, p-1)
                    return( rc + substr(s, plte, suffix_lt))
        endcase
        return(rc)
    else
        case op
            when 0   return(s)
            when  -1 return(s)
            when +1  return(' ')
        endcase
    endif
    return(rc)
end
/*
<f1> message(msubstr('1234567890', '45', -1, 0))
<f2> message(msubstr('1234567890', '45', 00, 0))
<f3> message(msubstr('1234567890', '45', +1, 0))
<f4> message(msubstr('1234567890', '45', -1, 2))
<f5> message(msubstr('1234567890', '45', 00, 2))
<f6> message(msubstr('1234567890', '45', +1, 2))
*/
 /**************************************************************************
        Year-Month-Day
            reverses order ffrom Dd-Yy-MM to MM-YY-DD
 **************************************************************************/
STRING proc                   YMD(VAR string olddate)
    string newdate[12]= ''
    newdate = SubStr(olddate, 7, 2)
    newdate = newdate + olddate[6]
    return( newdate + SubStr(olddate, 1, 5) )
end

CONSTANT
    INIT_TIMER = 1,
    GET_TIME = 0

INTEGER
    timer_not_set = TRUE,
    hr2 = 00, //  12    0
    m2  = 00, // 118
    s2  = 00, // 119
    h2  = 00, //

    hr1 = 00,
    m1  = 00,
    s1  = 00,
    h1  = 00,

    hr3 = 00,
    m3  = 00,
    s3  = 00,
    h3  = 00

integer proc convert_to_hundreths(INTEGER hr,   INTEGER mins,
                                  INTEGER s,    INTEGER h)
    return(
           h +
           100 * s
           + 100 * 60 * mins
           + 100 * 60 * 60 * hr
           )
end

proc convert_from_hundreths(INTEGER input,
                            VAR INTEGER hr,     VAR INTEGER mins,
                            VAR INTEGER sec,    VAR INTEGER h)
        INTEGER
            hs_used = 0
        if input < 0
            input = input + convert_to_hundreths(24,0,0,0)
        endif
        hr = input / 360000             hs_used = (hr * 360000)
        mins = (input - hs_used) / 6000  hs_used = hs_used + (mins * 6000)
        sec = (input - hs_used) / 100   hs_used = hs_used + (sec * 100)
        h = input - hs_used
end

string proc timer(INTEGER arg)
    //
    // arg == INIT_TIMER or
    //        GET_TIME
    //
    STRING
        interval[14] = ''
    GetTime(hr2, m2, s2, h2)
    convert_from_hundreths(
        convert_to_hundreths(hr2, m2, s2, h2) -
        convert_to_hundreths(hr1, m1, s1, h1),
        hr3, m3, s3, h3)
    interval = format(
              m3      , ':',
              s3:2:'0', '.',
              h3/10:1:'0'
             )
    if substr(interval,1,2) == '0:'
        interval = mSubstr(interval, ':', +1 ,0)
        if interval[1] == '0'
            interval = mSubstr(interval, '0', +1 ,0)
        endif
    endif
    if arg == INIT_TIMER
      GetTime(hr1, m1, s1, h1)
    endif
    return(interval)
end

/**************************************************************************
 **************************************************************************/
integer
    statusbar_last_num=-1,              // for statusbar()
    statusbar_last_ml=-1,
    statusbar_last_curr=-1,
    a
string
    time[14]= ' '

proc                          StatusBar(sTRING msg, INTEGER a, INTEGER b, INTEGER mode)
    integer
        ml = length(msg),
        cl = iif(a==0, CurrLine(), a),
        nl = iif(b==0, NumLines(), b),
        pct = (100000 * cl / nl ),
        l  = - (Query(ScreenCols) - length(msg))
        if mode == IN_WINDOW
            l  = 70 -  length(msg)
        else
            l  = - (Query(ScreenCols) - length(msg))
        endif
    if nl <> statusbar_last_num OR
       cl <> statusbar_last_curr OR
       ml <> statusbar_last_ml
        if mode == IN_WINDOW
            time = timer(GET_TIME)
            paint_message(time_line, 0, time+']',14, 0)
            VGotoXY(-2, -2)
            a = Set(attr,(Query(textattr) & 0x07) shl 4) | ((Query(textattr) & 0x70) shr 4)
            PutLine(format(msg, '' : (l * pct / 100000) : '.' ),69)
            Set(attr,a)
/*          AddLine(Format(time:14, hr3:3, m3:3, s3:3, h3:3, ' ³ ',
                                    hr2:3, m2:3, s2:3, h2:3, ' ³ ',
                                    hr1:3, m1:3, s1:3, h1:3), oid)
*/      else
            Message(format(msg), '' : (l * pct / 100000) : '.' )
        endif
        if MacroStackAvail() < 2000
            message('Macro stack avail = ', MacroStackAvail(), ' while ', msg)
        endif
        statusbar_last_num =  nl
        statusbar_last_curr = cl
    endif
end

/**************************************************************************
        mJoinLine()
 **************************************************************************/
integer         proc        mJoinLine()
    integer
        RTW = Set(RemoveTrailingWhite, FALSE),
        p = CurrPos(),
        l = CurrLine(),
        r = -1                          // default; causes a joinline()

    old_white_at_eol = ''
    old_white_at_bol = ''
    join_line = CurrLine()

    PushBlock()
    break_point = CurrLineLen()

    // CHECK CURRENT LINE'S CONDITIONS
    if not PosLastNonWhite()                // blank line
        r = 1 goto ending                   // no join performed
    endif                                   // but not a 'failure' condition

    if CurrLine() == NumLines()             // at EOF
        r = 0 goto ending                   // return(0)
    endif

    // DEL TRAILING WHITE
    if PosLastNonWhite() < break_point      // if trailing whitespace
        MarkColumn(CurrLine(), PosLastNonWhite()+1, CurrLine(), CurrLineLen())
        old_white_at_eol = GetMarkedText()
//      warn(currline(), '.', length(old_white_at_eol), '.', break_point)
        DelBlock()
        break_point = break_point - length(old_white_at_eol)
    endif

    // CHECK NEXT LINE
    Down()                              // next line
    if not PosLastNonWhite()            // is blank line
        Up()                            // go back to first line
        EndLine()                       // go to end of it
        InsertText( old_white_at_eol )  // replace trailing white
        r = 1 goto ending               // but not a fatal error condition
    endif

    // CHECK COMBINATION LINE LENGTHS
    if CurrLineLen() - (PosFirstNonWhite() -1) + break_point + 1 > MAX_LINE
        Warn('lines at ', CurrLine(), ' are too long to join')
        Up()
        EndLine()
        InsertText( old_white_at_eol )
        r = 1   goto ending
    endif

    // DELETE LEADING WHITE
    if PosFirstNonWhite() <> 1
        MarkColumn(CurrLine(), 1, CurrLine(), PosFirstNonWhite()-1 )
        old_white_at_bol = GetMarkedText()
        DelBlock()
    endif

    BegLine()
    GotoLine(l)
    EndLine()           // add a single space to end
    if not InsertText(' ', _INSERT_)
        r = 0 goto ending
    endif

  ending:
    GotoLine(l)
    GotoPos(p)
    PopBlock()
    Set(RemoveTrailingWhite, RTW)

    if r == -1          // if no problem, join
        return(JoinLine())
    endif               // else return r

    break_point = 0
    return(r)
end

/**************************************************************************
        mSplitLine()
 **************************************************************************/
proc                        mSplitLine()
    integer
        p = CurrPos(),
        l = CurrLine(),
        rtw = Set(RemoveTrailingWhite, OFF)
    if join_line AND break_point            // i.e., if a join was done
        GotoLine(join_line)
        GotoPos(break_point + 1)
        if length(old_white_at_eol)
            InsertText( old_white_at_eol, _INSERT_ )
        endif
        SplitLine()
        BegLine()
        Down()
        DelChar()
        if length(old_white_at_bol)
            InsertText( old_white_at_bol )
        endif
        BegLine()
        GotoLine(l)
        GotoPos(p)
        join_line = 0
        break_point = 0
    endif
    Set(RemoveTrailingWhite,RTW)
end

proc set_flags_to_defaults()
    SetFlag(AUTO_RE_FLAG,           TRUE)           // :U: TRUE/FALSE
    SetFlag(CONTEXT,                0)              // :U: 0-9
    SetFlag(EXCLUDE_FILES,          TRUE)           // :U: TRUE/FALSE
    SetFlag(FILES_ONLY_NO_SEARCH,   FALSE)          // :U: TRUE/FALSE
    SetFlag(LINE_NUMBERS,           TRUE)           // :U: TRUE/FALSE
    SetFlag(LIST_FILES_W_HITS_ONLY, FALSE)          // :U: TRUE/FALSE
    SetFlag(LNDIGITS,               5)              // :U: max digits in a line ##
    SetFlag(LOAD_OUT_FILE,          TRUE)           // :U: TRUE/FALSE
    SetFlag(MAKE_LIST_OF_DIRS,      TRUE)           // :U: TRUE/FALSE
    SetFlag(NO_WARNING_FLAG,        FALSE)          // :U: TRUE/FALSE
    SetFlag(ONE_HIT_ONLY_PER_FILE,  FALSE)          // :U: TRUE/FALSE
    SetFlag(PAUSE_LENGTH,           0)              // :U: 0-9
    SetFlag(PRESS_ANY_KEY,          TRUE)           // :U: TRUE/FALSE
    SetFlag(RECOUNT_HITS_FLAG,      FALSE)          // :U: TRUE/FALSE
    SetFlag(SAVE_CHANGED_FILES,     ALWAYS)         // :U: ALWAYS/NEVER/ASKSAVE
    SetFlag(SAVE_HIT_LIST,          NEVER)          // :U:
    SetFlag(SAVE_LOADED_FLAG,       ASKSAVE)        // :U: ASKSAVE/ALWAYS/NEVER
    SetFlag(SEARCH_ACROSS_LINES,    AUTO)           // :U: AUTO/SLOW/dFAST/OFF
    SetFlag(SHOW_HELP_LINE,         TRUE)           // :U: TRUE/FALSE
    SetFlag(UNLOAD_FILES_WITH_HITS_AFTER_VIEWING, TRUE) // :U: TRU /FALSE
    SetFlag(UNLOAD_LOADED_FILES,    FALSE)          // :U: TRUE/FALSE
    SetFlag(WRITE_HITS,             TRUE)           // :U: TRUE/FALSE
    SetFlag(SAVE_SETTINGS_WHEN_UNLOADED, TRUE)      // :U: TRUE/FALSE
end

proc set_globals()
    SetGlobalStr('TSGREP after_date', after_date)
    SetGlobalStr('TSGREP before_date', before_date)
    SetGlobalStr('TSGREP default_name', default_name)
    SetGlobalStr('TSGREP default_name_2', default_name_2)
    // SetGlobalInt('TSGREP files_only', files_only)
    SetGlobalStr('TSGREP flags', flags)
    SetGlobalInt('TSGREP goto_hit_list mode', goto_hit_list_mode)
    SetGlobalStr('TSGREP infile', infile)
    SetGlobalStr('TSGREP list_file_char', list_file_char)
    // SetGlobalInt('TSGREP list_of_dirs', list_of_dirs)
    SetGlobalStr('TSGREP name_prefix', name_prefix)
    SetGlobalStr('TSGREP name_suffix', name_suffix)
    // SetGlobalInt('TSGREP oid', oid)
    SetGlobalStr('TSGREP options', options)
    SetGlobalStr('TSGREP outfile', outfile)
    SetGlobalStr('TSGREP outfile_copy', outfile_copy)
    SetGlobalStr('TSGREP recurse_char', recurse_char)
    SetGlobalStr('TSGREP short_string', short_string)
    SetGlobalStr('TSGREP sstring', sstring)
    SetGlobalStr('TSGREP ts_options', ts_options)
    SetGlobalStr('TSGREP v', v)
    SetGlobalInt('TSGREP TIMER START TIME', convert_to_hundreths(hr1, m1, s1, h1))
    SetGlobalInt('TSGREP timer_not_set', timer_not_set)
end

proc get_globals()
    after_date      = GetGlobalStr('TSGREP after_date')
    before_date     = GetGlobalStr('TSGREP before_date')
    default_name    = GetGlobalStr('TSGREP default_name')
    default_name_2  = GetGlobalStr('TSGREP default_name_2')
    dirs_to_be_processed = GetGlobalInt('TSGREP dirs_to_be_processed')
    files_only      = GetGlobalInt('TSGREP files_only')
    flags           = GetGlobalStr('TSGREP flags')
    pause           = getFlag(PAUSE_LENGTH)
    goto_hit_list_mode = GetGlobalInt('TSGREP goto_hit_list mode')
    infile          = GetGlobalStr('TSGREP infile')
    list_file_char  = GetGlobalStr('TSGREP list_file_char')
    list_of_dirs    = GetGlobalInt('TSGREP list_of_dirs')
    list_of_filespecs = GetGlobalInt('TSGREP list_of_filespecs')
    name_prefix     = GetGlobalStr('TSGREP name_prefix')
    name_suffix     = GetGlobalStr('TSGREP name_suffix')
    oid             = GetGlobalInt('TSGREP oid')
    options         = GetGlobalStr('TSGREP options')
    outfile         = GetGlobalStr('TSGREP outfile')
    outfile_copy    = GetGlobalStr('TSGREP outfile_copy')
    recurse_char    = GetGlobalStr('TSGREP recurse_char')
    short_string    = GetGlobalStr('TSGREP short_string')
    sstring         = GetGlobalStr('TSGREP sstring')
    ts_options      = GetGlobalStr('TSGREP ts_options')
    v               = GetGlobalStr('TSGREP v')
    convert_from_hundreths( GetglobalInt('TSGREP TIMER START TIME'), hr1, m1, s1, h1)
    timer_not_set   = GetGlobalInt('TSGREP timer_not_set')
end

proc paint_message(INTEGER line_number,
                INTEGER spaces,
                STRING the_message,
                INTEGER how_wide,
                INTEGER delay_after)
        VGotoXY(iif(how_wide == 54, 1, 25), line_number)
        PutLine(format('':spaces+3:' ') + the_message, how_wide)
        if pause and delay_after
            Delay(pause)            // set by user option
        endif


end
