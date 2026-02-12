/*
  Macro           eHelp
  Author          Carlo Hogeveen
  Website         ecarlo.nl/tse
  Compatibility   TSE v4 upwards, all TSE variants
  Version         v0.9   2 Nov 2022


  IN DEVELOPMENT !!!
    This is just a baby extension.
    It does not do a lot yet, and what it does is probably flawed.


  CAVEAT
    .ehelp files are not syntax checked yet AND are blindly processed as if
    they are correct. Therefore "garbage in, garbage out" applies.


  RULES for .ehelp   (roughly)
  - Do not use physical tab characters: They are not treated as whitespace.
  - Outer opening and closing tags must start on column 1 without indentation:
      <EHELP>, </EHELP>, <META>, </META>, <REDIRECTS>, </REDIRECTS>,
      <REDIRECT>, </REDIRECT>, <TOPICS>, </TOPICS>, <TOPIC>, </TOPIC>, <TEXT>,
      </TEXT>.
  - Each outer opening or closing tags must be the only thing in its line.
  - Redirects may refer to redirects, but not infinitly.
  - Each inner opening and closing tag must occur in the same line.
    Inner tags are tags between <TEXT> and </TEXT>,
    i.e. the BOLD, ITALIC, SUBTOPIC, INFO and LINK tags.
  - Tags cannot include non-significant spaces.
      For example, <TOPIC> MyTopic</TOPIC> defines topic " MyTopic".
      For example, < TOPIC> is unrecognized syntax.
  - From the inner tags, only BOLD and ITALIC can enclose other tags,
    and they cannot enclose each other.


  TODO
  - Integrate eHelp in Help history.
    It works now for simple topic requests.
    Semware's bindhelp.si needed a small adjustment for that.
    It has not been tested for subtopic and redirected requests,
    nor when jumping back to a not-line-1 help text position.


  Current functionality:
  - When eHelp is (auto)loaded, it (re)creates tsehelp.ehelp if it does not
    exist, or is out of date, or is modified.
  - If eHelp is loaded, and the user opens a .ehelp file, then it is shown
    in _DISPLAY_HELP_ display mode, which shows the file's and environment's
    OEM characters, and is editable.
    However, _DISPLAY_HELP_ display mode has disadvantages: It grays out the
    line drawing tool, the ASCII Chart still shows ANSI characters if it did
    before, block marking happens invisibly, and OEM is a mess (*) for
    non-ASCII non-line-drawing characters.
  - Toggling read-only mode (un)sets preview mode for .eHelp files.
    I defined a key for toggling read-only mode, and this works great!
      <Ctrl B>  BrowseMode(not BrowseMode())

  (*)
    - Non-ASCII characters can differ across computers, that are configured to
      use different code pages.
    - GUI TSE's Help only displays ASCII and line-drawing characters, and a
      space for everything else, so characters with diacritics are not possible
      any more.
      This occurs since GUI TSE beta v4.40.98 or v4.40.99, which according to
      the read.me is between 13 Sep 2017 and 28 Apr 2018.


  HISTORY

  v0.3    19 Oct 2022
    Toggling read-only mode (un)sets preview mode for .eHelp files.

  v0.4    21 Oct 2022
    Show the source of the help page and its topic in the inner window's title.
    TSE's Help should have done the latter itself, but does not.

  v0.5    25 Oct 2022
    Got TSE's history working for the simplest use case. Semware's Help macro
    bindhelp.si needed a tiny improvement for that. A side-effect was, that TSE
    setting the Help title now works too, so I honored that by removing my own
    code for that, including the reference to the used Help file, so we need
    something new for that later on.

    Implemented retrieving Help for a subtopic that is requested without its
    topic. For example: searcing for "for" positions me in the "Statements" at
    the "for" subtopic as defined in the tsehelp_eCarlo.ehelp file.

    Cleaned up the code a bit and added more documentation.

  v0.6    26 Oct 2022
    Implemented retrieving a specific subtopic from a spcific topic.

    Implemented retrieving through redirects.
    TSE's Help only implements redirecting the topic (part) of a request, but
    eHelp also allows and even prioritizes redirecting a topic plus subtopic.
    A request may be redirected a seemingly infinite number of times, but an
    infinite loop of redirects will quickly result in a failed request.

  v0.7    29 Oct 2022
    Fixed help history not working any more.

  v0.8    30 Oct 2022
    Fixed a seeming harmless error in the Help's Control buffer.

    An infinite redirect now "succeeds" in retrieving a "help screen" that
    reports the infinite redirection with the guilty .ehelp file as an error,
    rather than moving on to querying the next Help source.

    To communicate retrieved topic information back to TSE's Help,
    buffer strings are used that now more logically use the Help's topic buffer
    instead of the Help's control buffer.

    If the help topic's source is not TSE itself and it fits before the topic
    title, then the help topic's source is displayed in the top left help
    border.

    Marked text is now shown if you edit a .ehelp file.

  v0.9     2 Nov 2022
    _DISPLAY_HELP_ mode does not allow horizontal scrolling.
    Unfortunately TSE keeps the visible cursor blinking at the window width
    if the current column position is to the right of it, outside the window,
    which is confusing to someone editing the help.
    Therefore eHelp now turns the visible cursor off in that situation.

*/





// Start of compatibility restrictions and mitigations



#ifdef LINUX
  #define WIN32 FALSE
  string SLASH [1] = '/'
#else
  string SLASH [1] = '\'
#endif


integer proc edit_this_file(string filename, integer edit_flags)
  #if EDITOR_VERSION >= 4200h
    return(EditThisFile(filename, edit_flags))
  #else
    return(EditFile(filename, edit_flags))
  #endif
end edit_this_file


integer proc key_pressed()
  // Compensate for a bug that was fixed in TSE v4.40.81.
  // The next TSE version we can test for is v4.41.44,
  // which finally introduced INTERNAL_VERSION.
  #ifdef INTERNAL_VERSION
    return(KeyPressed())
  #else
    return(KeyPressed() or KeyPressed())
  #endif
end key_pressed


// End of compatibility restrictions and mitigations




// Global constants and semi-constants
#define CHANGECURRFILENAME_OPTIONS              _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
#define DOS_SYNC_CALL_FLAGS                     _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_
string  EDIT_MODE_SEARCH_STRING[MAXSTRINGLEN] = '<{BOLD}|{INFO}|{ITALIC}|{LINK}|{SUBTOPIC}>.*</{BOLD}|{INFO}|{ITALIC}|{LINK}|{SUBTOPIC}>'
#define HELP_CONTROL_ID                         9
#define HELP_TOPIC_ID                           8
string  INVALID_FILE_NAME_CHARS           [9] = '\/:*?"<>|'
#define MAX_REDIRECTS                           100   // Allow lots, but not infinite loops.
string  MY_MACRO_NAME          [MAXSTRINGLEN] = ''
string  USER                   [MAXSTRINGLEN] = ''



// Global variables
integer display_block_timer           = 0
integer ehelp_turned_cursor_off       = FALSE
string  help_topic     [MAXSTRINGLEN] = ''
string  user_ehelp_fqn [MAXSTRINGLEN] = ''
integer user_ehelp_id                 = 0



#if WIN32
  dll "<kernel32.dll>"

    integer proc CreateFile(string  lpFileName:cstrval,
                            integer dwDesiredAccess,
                            integer dwShareMode,
                            integer lpSecurityAttributes,
                            integer dwCreationDisposition,
                            integer dwFlagsAndAttributes,
                            integer hTemplateFile
                            ): "CreateFileA"

    integer proc CloseHandle(integer handle): "CloseHandle"

    integer proc DosDateTimeToFileTime(integer wFatDate:word,
                                       integer wFatTime:word,
                                       string  lpFileTime:StrPtr
                                       ): "DosDateTimeToFileTime"

    integer proc GetLastError(): "GetLastError"

    integer proc LocalFileTimeToFileTime(string in_time:StrPtr,
                                         string out_time:StrPtr
                                         ): "LocalFileTimeToFileTime"

    integer proc SetFileTime(integer handle,
                             integer lpCreationTime,
                             integer lpLastAccessTime,
                             string  lpLastWriteTime:StrPtr
                             ): "SetFileTime"
  end


  /*
    This is an IMHO optimized version of the "f" macro's LoSetDateTime() proc.
    It has a higher-level date-time input and better documentation.
  */
  integer proc set_windows_file_date_time(string fn, string yyyy_mm_dd_hh_mm_ss)
    integer ff_date             = 0
    integer ff_time             = 0
    integer handle              = -1
    string  local_file_time [8] = "        "  // Needs to be at least 64 bits long.
    integer ok                  = FALSE
    string  utc_file_time   [8] = "        "  // Needs to be at least 64 bits long.

    //  Bitfields for file date, bits counted right-to-left, starting at 0:
    //    15-9   year-1980
    //     8-5   month
    //     4-0   day
    ff_date = ( ((Val(yyyy_mm_dd_hh_mm_ss[1:4]) - 1980) shl  9) |
                 (Val(yyyy_mm_dd_hh_mm_ss[6:2])         shl  5) |
                  Val(yyyy_mm_dd_hh_mm_ss[9:2])                 )

    //  Bitfields for file time, bits counted right-to-left, starting at 0:
    //    15-11  hours (0-23)
    //    10-5   minutes
    //     4-0   seconds/2
    ff_time = (  (Val(yyyy_mm_dd_hh_mm_ss[12:2])         shl 11) |
                 (Val(yyyy_mm_dd_hh_mm_ss[15:2])         shl  5) |
                 (Val(yyyy_mm_dd_hh_mm_ss[18:2]) /   2)          )

    if not DosDateTimeToFileTime(ff_date, ff_time, local_file_time)
      Warn(MY_MACRO_NAME, ': Error ON DosDateTimeToFileTime()')
      return(FALSE)
    endif

    // The 2nd parameter, "dwDesiredAccess" in the Microsoft documentation,
    // has the value GENERIC_WRITE, which is 0x40000000.
    // The 5th parameter, "dwCreationDisposition" in the Microsoft documentation,
    // has the value OPEN_EXISTING, which is 3.
    handle = CreateFile(fn, 0x40000000, 0, 0, 3, 0, 0)

    if handle == -1
      Warn(MY_MACRO_NAME, ': Error ', GetLastError(), ' opening file ', fn)
      return(FALSE)
    endif

    // The handle is open, so from here on we cannot simply return().

    ok = LocalFileTimeToFileTime(local_file_time, utc_file_time)
    if not ok
      Warn(MY_MACRO_NAME, ': Error ', GetLastError(), ' converting local to UTC time.')
    endif

    // The two 0's are lpCreationTime and lpLastAccessTime,
    // but to pass 0 they have to have been declared as integers,
    // as was done in their DLL declaration above.
    ok = ok and SetFileTime(handle, 0, 0, utc_file_time)
    if not ok
      Warn(MY_MACRO_NAME, ': Error ', GetLastError(), ' setting time, handle:', handle)
    endif

    CloseHandle(handle)

    return(ok)
  end set_windows_file_date_time
#endif


#ifdef LINUX
  integer proc set_linux_file_date_time(string fn, string yyyy_mm_dd_hh_mm_ss)
    string  cmd  [MAXSTRINGLEN] = ''
    integer ok                  = FALSE
    integer command_return_code = 0
    integer dos_errorlevel      = 0
    integer dos_io_result       = 0
    integer dos_result          = 0

    cmd = Format('touch -t ',
                 yyyy_mm_dd_hh_mm_ss[ 1:4],
                 yyyy_mm_dd_hh_mm_ss[ 6:2],
                 yyyy_mm_dd_hh_mm_ss[ 9:2],
                 yyyy_mm_dd_hh_mm_ss[12:2],
                 yyyy_mm_dd_hh_mm_ss[15:2],
                 '.',
                 yyyy_mm_dd_hh_mm_ss[18:2],
                 ' ',
                 fn)

    dos_result          = Dos(cmd, DOS_SYNC_CALL_FLAGS)
    dos_io_result       = DosIOResult()
    command_return_code = HiByte(dos_io_result)
    dos_errorlevel      = LoByte(dos_io_result)

    if      dos_result
    and not command_return_code
    and not dos_errorlevel
      ok = TRUE
    else
      Warn(MY_MACRO_NAME, ' error executing:'; cmd)
    endif

    return(ok)
  end set_linux_file_date_time
#endif


integer proc set_file_date_time(string fn, string yyyy_mm_dd_hh_mm_ss)
  integer ok = FALSE
  #ifdef LINUX
    ok = set_linux_file_date_time(fn, yyyy_mm_dd_hh_mm_ss)
  #endif
  #if WIN32
    ok = set_windows_file_date_time(fn, yyyy_mm_dd_hh_mm_ss)
  #endif
  return(ok)
end set_file_date_time


/*
  If the text is longer than the new length, then is is cut off,
  otherwise it is lengthened by putting spaces around it.
*/
string proc center_text(string text, integer new_length)
  string centered_text [MAXSTRINGLEN] = ''
  if Length(text) >= new_length
    centered_text = SubStr(text, 1, new_length)
  else
    centered_text = Format('':((new_length - Length(text)) / 2), text)
    centered_text = Format(centered_text: -new_length)
  endif
  return(centered_text)
end center_text


string proc de_regexp(string regexp)
  integer i                     = 1
  string  result [MAXSTRINGLEN] = regexp
  while i <= Length(result)
    if Pos(result[i], '.^$|?[]-~*+@#{}\')
      result = result[1 .. i - 1] + '\' + result[i .. MAXSTRINGLEN]
      i = i + 2
    else
      i = i + 1
    endif
  endwhile
  return(result)
end


/*
  Give a warning if WriteProfileStr() fails.
*/
integer proc write_profile_str(string section_name,
                               string item_name,
                               string item_value)
  integer result = WriteProfileStr(section_name,
                                   item_name,
                                   item_value)
  if not result
    Warn('Failed to write'; MY_MACRO_NAME; 'configuration to .ini file.')
  endif
  return(result)
end write_profile_str


/*
  search_path works like SearchPath, but without looking in the current
  directory too if subdir is supplied.
  For example, if subdir is supplied, and paths is "path1;path2", then these
  directories are searched in this order by search_path:
    path1
    path1\subdir
    path2
    path2\subdir
    LoadDir()
    LoadDir()\subdir
    SplitPath(LoadDir(TRUE), _DRIVE_|_PATH_)
    SplitPath(LoadDir(TRUE), _DRIVE_|_PATH_)\subdir

  search_path_helper() should not be called directly.
  It is a helper proc for search_path().
*/
string proc search_path_helper(string filename, string path , string subdir)
  string result [MAXSTRINGLEN] = ''

  if FileExists(path + filename)
    result = path + filename
  elseif FileExists(path + subdir + SLASH + filename)
    result = path + subdir + SLASH + filename
  endif

  return(result)
end search_path_helper


string proc search_path(string filename, string paths, string subdir)
  integer i                          = 0
  string  path        [MAXSTRINGLEN] = ''
  string  program_dir [MAXSTRINGLEN] = ''
  string  result      [MAXSTRINGLEN] = ''

  for i = 1 to NumTokens(paths, ';')
    path   = GetToken(paths, ';', i)
    result = search_path_helper(filename, path + SLASH, subdir)
    if result <> ''
      break
    endif
  endfor

  if result == ''
    path   = LoadDir()
    result = search_path_helper(filename, path, subdir)
  endif

  if result == ''
    program_dir = SplitPath(LoadDir(TRUE), _DRIVE_|_PATH_)
    if program_dir <> path
      result = search_path_helper(filename, program_dir, subdir)
    endif
  endif

  return(result)
end search_path


integer proc exec_macro(string cmd)
  #ifdef LINUX
    // In TSE v4.46 downwards the Linux ExecMacro() command erroneously
    // returns TRUE if the called macro's .mac does not exist.
    // Here we fix that, faithfully reproducing the warning.
    if search_path(GetToken(cmd, ' ', 1) + '.mac', '', 'mac') == ''
      if Query(MsgLevel) <> _NONE_
        Warn('File not found:'; GetToken(cmd, ' ', 1) + '.mac')
      endif
      return(FALSE)
    endif
  #endif
  return(ExecMacro(cmd))
end exec_macro


integer proc recompile(string p_macro_name)
  integer compilation_ok             = FALSE
  string  macro_s_fqn [MAXSTRINGLEN] = ''
  integer macro_s_id                 = 0

  if SplitPath(p_macro_name, _DRIVE_|_PATH_) == ''
    if SplitPath(p_macro_name, _EXT_) == ''
      // This is the preferred input.
      macro_s_fqn = search_path(p_macro_name + '.s', Query(TSEPath), 'mac')
      if macro_s_fqn == ''
        macro_s_fqn = search_path(p_macro_name + '.si', Query(TSEPath), 'mac')
      endif
    else
      macro_s_fqn = search_path(p_macro_name, Query(TSEPath), 'mac')
    endif
  else
    if SplitPath(p_macro_name, _EXT_) == ''
      if FileExists(p_macro_name + '.s')
        macro_s_fqn = p_macro_name + '.s'
      elseif FileExists(p_macro_name + '.si')
        macro_s_fqn = p_macro_name + '.si'
      endif
    elseif FileExists(p_macro_name)
      macro_s_fqn = p_macro_name
    endif
  endif

  if macro_s_fqn <> ''
    PushLocation()
    macro_s_id = edit_this_file(macro_s_fqn, _DONT_PROMPT_)
    if macro_s_id
      // Start of pushed keys part: When debugging you cannot step through here.
      PushKey(<Enter>)
      PushKey(<c>)
      //   Macro must be both current and a parameter to get the response windows we
      //   want for a successful and not successful compilation in all TSE versions.
      ExecMacro('compile ' + CurrFilename())
      if  key_pressed()
      and GetKey() == <Enter>
        compilation_ok = TRUE
      endif
      // End of pushed keys part: Debug breakpoint could be put hereafter.
    endif
    PopLocation()
    AbandonFile(macro_s_id)
    Delay(36)
  endif

  return(compilation_ok)
end recompile


proc check_tsehelp_dot_ehelp_file()
  integer eHelp_ok                          = FALSE
  integer execmacro_ok                      = FALSE
  integer old_DateFormat                    = Set(DateFormat, 6)
  integer old_MsgLevel                      = 0
  integer old_TimeFormat                    = Set(TimeFormat, 1)
  string  tsehelp_ehelp_date_time      [19] = ''
  string  tsehelp_ehelp_file [MAXSTRINGLEN] = ''
  string  tsehelp_hlp_date_time        [19] = ''
  string  tsehelp_hlp_file   [MAXSTRINGLEN] = ''

  tsehelp_hlp_file = search_path('tsehelp.hlp'  , '', 'help')
  if tsehelp_hlp_file <> ''
    FindThisFile(tsehelp_hlp_file)
    tsehelp_hlp_date_time = FFDateStr() + ' ' + FFTimeStr()
    tsehelp_ehelp_file    = search_path('tsehelp.ehelp', '', 'help')
    if tsehelp_ehelp_file <> ''
      FindThisFile(tsehelp_ehelp_file)
      tsehelp_ehelp_date_time = FFDateStr() + ' ' + FFTimeStr()

      eHelp_ok = (tsehelp_ehelp_date_time == tsehelp_hlp_date_time)
    endif
  else
    Warn(MY_MACRO_NAME; "error: Cannot find TSE's tsehelp.hlp file!")
  endif

  if  tsehelp_hlp_file <> ''
  and not eHelp_ok
    old_MsgLevel = Set(MsgLevel, _NONE_)
    execmacro_ok = exec_macro('eHelp_Hlp2eHelp')
    Set(MsgLevel, old_MsgLevel)
    if not execmacro_ok
      if recompile('eHelp_Hlp2eHelp')
        old_MsgLevel = Set(MsgLevel, _NONE_)
        execmacro_ok = exec_macro('eHelp_Hlp2eHelp')
        Set(MsgLevel, old_MsgLevel)
      endif
    endif

    if execmacro_ok
      tsehelp_ehelp_file = search_path('tsehelp.ehelp', '', 'help')
      if tsehelp_ehelp_file == ''
        Warn(MY_MACRO_NAME, ' error: Failed to create "tsehelp.ehelp".')
      else
        set_file_date_time(tsehelp_ehelp_file, tsehelp_hlp_date_time)
      endif
    else
      Warn(MY_MACRO_NAME; 'error: Failed to execute macro "eHelp_Hlp2eHelp". Install it!')
    endif
  endif

  Set(DateFormat, old_DateFormat)
  Set(TimeFormat, old_TimeFormat)
end check_tsehelp_dot_ehelp_file

/*
  A nice side of the DisplayMode() solution is, that it also works in Linux.
*/
proc change_ehelp_display()
  if CurrExt() == '.ehelp'
    if DisplayMode() <> _DISPLAY_HELP_
      DisplayMode(_DISPLAY_HELP_)
    endif
  endif
end change_ehelp_display


proc replace_inner_xml_by_codes()
  // Here we just use regexps with minimum closure.
  // Bold and italic last, so they have a smaller string to replace.
  lReplace('<INFO>{.*}</INFO>'           , '®LI¯\1®/L¯'  , 'ginx')
  lReplace('<LINK>{.*}\^{.*}</LINK>'     , '®L \1¯\2®/L¯', 'ginx')
  lReplace('<LINK>{.*}</LINK>'           , '®L¯\1®/L¯'   , 'ginx')
  lReplace('<SUBTOPIC>{.*}</SUBTOPIC>'   , '®S¯\1®/S¯'   , 'ginx')
  lReplace('<BOLD>{[ \d009]*}</BOLD>'    , '\1'          , 'ginx')
  lReplace('<BOLD>{.*}</BOLD>'           , '®B¯\1®/B¯'   , 'ginx')
  lReplace('<ITALIC>{[ \d009]*}</ITALIC>', '\1'          , 'ginx')
  lReplace('<ITALIC>{.*}</ITALIC>'       , '®I¯\1®/I¯'   , 'ginx')
end replace_inner_xml_by_codes


proc check_read_only_preview_mode()
  PushPosition()
  if BrowseMode()
    if lFind(EDIT_MODE_SEARCH_STRING, 'gix')
      BrowseMode(OFF)
      replace_inner_xml_by_codes()
      BrowseMode(ON)
    endif
  else
    if lFind('®[BILSbils]#¯.*®/[BILSbils]¯', 'gx')
      // The "[~®]" ensures that multiple syntax phrases on the same line are
      // not matched as one, despite the regexp use of maximum closure.
      // The order of replacements matters a lot.
      // Links and subtopics can occur within bold/italic tags; not the other
      // way around.
      // Bold italic text is not supported in the real world, nor in TSE's
      // Help.
      // Semware sometimes uses empty bold tags in tables. I can see why, but
      // do not want to support this Semware-specific editing crutch going
      // forward, so I delete them.
      // Bold and italic first, so they have a smaller string to replace.
      lReplace('®B¯{[ \d009]*}®/B¯'        , '\1'                     , 'gnx')
      lReplace('®I¯{[ \d009]*}®/I¯'        , '\1'                     , 'gnx')
      lReplace('®B¯{[~®]#}®/B¯'            , '<BOLD>\1</BOLD>'        , 'gnx')
      lReplace('®I¯{[~®]#}®/I¯'            , '<ITALIC>\1</ITALIC>'    , 'gnx')
      lReplace('®LI¯{[~®]#}®/L¯'           , '<INFO>\1</INFO>'        , 'gnx')
      lReplace('®L \{{[~®]#}\}¯{[~®]#}®/L¯', '<LINK>\1^\2</LINK>'     , 'gnx')
      lReplace('®L¯{[~®]#}®/L¯'            , '<LINK>\1</LINK>'        , 'gnx')
      lReplace('®S¯{[~®]#}®/S¯'            , '<SUBTOPIC>\1</SUBTOPIC>', 'gnx')
    endif
  endif
  PopPosition()
end check_read_only_preview_mode


proc display_marked_text_in_help_mode()
  integer buffer_column = 0
  integer buffer_line   = 0
  integer curr_x_offset = CurrXoffset()
  integer old_Cursor    = 0
  integer old_Marking   = 0
  integer window_col    = 0
  integer window_row    = 0

  UnHook(display_marked_text_in_help_mode)

  if      isBlockInCurrFile()
  and not BrowseMode()
    PushLocation()
    old_Cursor  = Set(Cursor , OFF)
    old_Marking = Set(Marking, OFF)
    buffer_line = CurrLine() - CurrRow() + 1  // The window's 1st buffer line.
    for window_row = Query(WindowY1) to Query(WindowY1) + Query(WindowRows) - 1
      GotoLine(buffer_line)
      buffer_column = 1 + curr_x_offset
      for window_col = Query(WindowX1) to Query(WindowX1) + Query(WindowCols) - 1
        GotoColumn(buffer_column)
        if isCursorInBlock()
          PutOemStrXY(window_col, window_row, Chr(CurrChar()),
                      Query(BlockAttr))
        endif
        buffer_column = buffer_column + 1
      endfor
      buffer_line = buffer_line + 1
    endfor
    PopLocation()
    Set(Marking, old_Marking)
    Set(Cursor , old_Cursor )
  endif
end display_marked_text_in_help_mode


proc idle()
  display_block_timer = display_block_timer - 1
  if display_block_timer == 0
    UnHook(idle)
    display_marked_text_in_help_mode()
  endif
end idle


proc after_command()
  integer curr_col = 0

  if CurrExt() == '.ehelp'
    check_read_only_preview_mode()

    if      isBlockInCurrFile()
    and not BrowseMode()
      display_block_timer = 2  // Experimentally: 2 is the minimum delay.
      Hook(_IDLE_, idle)
    endif

    if Query(Cursor) <> (CurrCol() <= Query(WindowCols))
      if Query(Cursor)
        Set(Cursor, OFF)
        ehelp_turned_cursor_off = TRUE
      else
        // In _DISPLAY_HELP_ mode the visible cursor gets confused
        // if it is turned on after a cursor-left command.
        // Turning it on at the start of the line unconfuses it.
        curr_col = CurrCol()
        BegLine()
        Set(Cursor, ON)
        GotoColumn(curr_col)
        ehelp_turned_cursor_off = FALSE
      endif
    endif
  else
    // Known flaw:
    // In theory the code below can incorrectly turn the cursor on if someone,
    // from editing a .ehelp file past its window width, switches to a
    // non-.ehelp file for which the cursor was already turned off too.
    // In practice the chance of this occurring needs two unlikely scenarios
    // to occur simultaneously, the chance of which is near infinitly small.
    // And I see no full-proof and fool-proof way to fix this.
    if ehelp_turned_cursor_off
      Set(Cursor, ON)
      ehelp_turned_cursor_off = FALSE
    endif
  endif
end after_command


integer proc is_valid_file_name_part(string name)
  integer i                 = 0
  integer result            = TRUE
  for i = 1 to Length(INVALID_FILE_NAME_CHARS)
    if Pos(INVALID_FILE_NAME_CHARS[i], name)
      Warn('Characters'; INVALID_FILE_NAME_CHARS; 'are not allowed in a (file) name.')
      result = FALSE
      break
    endif
  endfor
  return(result)
end is_valid_file_name_part


string proc get_user(integer when_loaded)
  integer name_ok               = FALSE
  string  result [MAXSTRINGLEN] = ''

  result = GetProfileStr(MY_MACRO_NAME + ':Config', 'User', '')

  if result == ''
  or not when_loaded
    if result == ''
      result = GetEnvStr('USERNAME')
    endif
    while not name_ok
      if Ask('Set a user name to use in tsehelp_<username>.ehelp:', result)
        result = Trim(result)
        if  Length(result)
        and is_valid_file_name_part(result)
        and write_profile_str(MY_MACRO_NAME + ':Config', 'User', result)
          name_ok = TRUE
        endif
      else
        result  = ''
        name_ok = TRUE  // Allow temporarily not setting a name yet.
      endif
    endwhile
  endif
  return(result)
end get_user


proc get_user_ehelp_file()
  user_ehelp_fqn = search_path('tsehelp_' + USER + '.ehelp', '', 'help')
  if user_ehelp_fqn == ''
    user_ehelp_id = 0
  else
    PushLocation()
    user_ehelp_id = CreateTempBuffer()
    if LoadBuffer(user_ehelp_fqn)
      ChangeCurrFilename(MY_MACRO_NAME + ':' +
                         SplitPath(user_ehelp_fqn, _NAME_|_EXT_),
                         CHANGECURRFILENAME_OPTIONS)
    else
      user_ehelp_id = 0
    endif
    PopLocation()
  endif
end get_user_ehelp_file


proc configure()
  get_user(FALSE)
  get_user_ehelp_file()
end configure


proc copy_text_to_topic_buffer()
  integer line_from = 0
  integer line_to   = 0
  lFind('^<TEXT> *$', 'xi')
  line_from = CurrLine() + 1
  lFind('^</TEXT> *$', 'xi')
  line_to = CurrLine() - 1
  PushBlock()
  MarkLine(line_from, line_to)
  Copy()
  GotoBufferId(HELP_TOPIC_ID)
  EmptyBuffer()
  Paste()
  PopBlock()
  BegFile()
end copy_text_to_topic_buffer


forward proc stop_augmenting_inner_window_title()


proc augment_inner_window_title()
  integer max_display_length = Max(Query(WindowCols) - 4, 0)
  integer separator_length   = 0


  UnHook(augment_inner_window_title)
  UnHook(stop_augmenting_inner_window_title)

  if Length(USER) + 1 + Length(help_topic) <= max_display_length
    // Clear previous title with horizontal line over full display length.
    Delay(36) // Delay to show previous title for debugging.
    PutOemStrXY(1,
                0,
                Format('': max_display_length: Chr(196)),
                Query(MenuBorderAttr))

    // Display the user subdued in the top left border.
    PutOemStrXY(1,
                0,
                user,
                Query(MenuBorderAttr))

    // Display the title prominently and centered.
    separator_length = Max(max_display_length
                           - Length(USER)
                           - Length(help_topic),
                           2) / 2
    PutOemStrXY(1 + Length(USER) + separator_length,
                0,
                help_topic,
                Query(MenuTextAttr))
  endif
end augment_inner_window_title


proc stop_augmenting_inner_window_title()
  UnHook(stop_augmenting_inner_window_title)
  UnHook(augment_inner_window_title        )
end stop_augmenting_inner_window_title


proc augment_next_inner_window_title()
  Hook(_NONEDIT_IDLE_, augment_inner_window_title)
  Hook(_IDLE_        , stop_augmenting_inner_window_title)
end augment_next_inner_window_title


integer proc retrieve_request(string p_request)
  integer help_id                 = GetBufferId() // Expected: HELP_TOPIC_ID.
  integer rc                      = FALSE
  integer redirects               = 0
  string  request  [MAXSTRINGLEN] = ''
  string  subtopic [MAXSTRINGLEN] = ''
  string  topic    [MAXSTRINGLEN] = ''

  request    = iif(Pos('|', p_request), GetToken(p_request, '|', 2), p_request)
  topic      = GetToken(request, ';', 1)
  subtopic   = GetToken(request, ';', 2)
  help_topic = ''

  GotoBufferId(user_ehelp_id)

  while redirects <= MAX_REDIRECTS
  and   (  lFind('^<REDIRECT>' + de_regexp(request) + '\^.#</REDIRECT> *$', 'gix')
        or lFind('^<REDIRECT>' + de_regexp(topic)   + '\^.#</REDIRECT> *$', 'gix'))
    redirects = redirects + 1
    if lFind('^<REDIRECT>' + de_regexp(request) + '\^{.#}</REDIRECT> *$', 'cgix')
      request  = GetFoundText(1)
      topic    = GetToken(request, ';', 1)
      subtopic = GetToken(request, ';', 2)
    elseif lFind('^<REDIRECT>' + de_regexp(topic) + '\^{.#}</REDIRECT> *$', 'cgix')
      topic    = GetFoundText(1)
      request  = topic + ';' + subtopic
    endif
  endwhile

  if redirects > MAX_REDIRECTS
    GotoBufferId(HELP_TOPIC_ID)
    EmptyBuffer()
    do 10 times
      AddLine()
    enddo
    AddLine(center_text('ERROR: The help request was redirected infinitely by:',
                        Query(WindowCols)))
    AddLine(center_text(user_ehelp_fqn,
                        Query(WindowCols)))
    BegFile()
    help_topic = p_request
    rc         = TRUE
  else
    if subtopic == ''
      if lFind('^<TOPIC>' + de_regexp(request) + '</TOPIC> *$', '^gix')
        copy_text_to_topic_buffer()
        replace_inner_xml_by_codes()
        help_topic = request
        rc         = TRUE
      elseif lFind('<SUBTOPIC>' + request + '</SUBTOPIC>', 'gi')
        lFind('^<TOPIC>{.#}</TOPIC> *$', 'bix')
        topic = GetFoundText(1)
        copy_text_to_topic_buffer()
        lFind('<SUBTOPIC>' + request + '</SUBTOPIC>', 'gi')
        PushPosition()
        replace_inner_xml_by_codes()
        PopPosition()
        help_topic = topic
        rc         = TRUE
      endif
    else
      if lFind('^<TOPIC>' + de_regexp(topic) + '</TOPIC> *$', '^gix')
        copy_text_to_topic_buffer()
        if lFind('<SUBTOPIC>' + subtopic + '</SUBTOPIC>', 'gi')
          replace_inner_xml_by_codes()
          help_topic = topic + ';' + subtopic
          rc         = TRUE
        else
          EmptyBuffer()
        endif
      endif
    endif
  endif

  if rc
    SetBufferStr('help_topic', help_topic    , HELP_TOPIC_ID)
    SetBufferStr('help_fn'   , user_ehelp_fqn, HELP_TOPIC_ID)
    augment_next_inner_window_title()
  else
    DelBufferVar('help_topic', HELP_TOPIC_ID)
    DelBufferVar('help_fn'   , HELP_TOPIC_ID)
  endif

  GotoBufferId(help_id)
  return(rc)
end retrieve_request


proc WhenLoaded()
  MY_MACRO_NAME = SplitPath(CurrMacroFilename(), _NAME_)

  check_tsehelp_dot_ehelp_file()

  USER = get_user(TRUE)
  get_user_ehelp_file()

  Hook(_AFTER_COMMAND_    , after_command)
  Hook(_ON_CHANGING_FILES_, change_ehelp_display)

  /*
  user_eHelp_file = search_path('tsehelp_eCarlo.ehelp', '', 'help')
  if user_eHelp_id == 0
    user_eHelp_id = GetBufferId(user_eHelp_file)
    if  user_eHelp_id == 0
    and FileExists(user_eHelp_file)
      PushLocation()
      user_eHelp_id = CreateTempBuffer()
      LoadBuffer(user_eHelp_file)
      ChangeCurrFilename(user_eHelp_file, CHANGECURRFILENAME_OPTIONS)
      PopLocation()
    endif
  endif
  */
end WhenLoaded


proc Main()
  string  cmd [MAXSTRINGLEN] = Query(MacroCmdLine)
  integer rc                 = FALSE

  if cmd == ''
    configure()
  elseif   user_ehelp_id
  and      cmd[1:            2]  == '-r'
  and Trim(cmd[3: MAXSTRINGLEN]) <> ''
    rc = retrieve_request(Trim(cmd[3: MAXSTRINGLEN]))
  endif

  Set(MacroCmdLine, Str(rc))
end Main

