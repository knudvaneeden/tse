/*
  Macro           EventLogger
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Version         v1.1   19 Jan 2022
  Compatibility   Windows TSE Pro v4.0 upwards,
                  Linux TSE Beta v4.41.44 upwards

  //
  1. -The directory where the log file is stored is: <c:\users\<yourwindowsusername>\log\tse\eventlogger\
  2. -This is a hidden directory
  3. -This log files is written and closed when you abandon the TSE editor completely
  //

  This TSE extension logs occurrences of selected TSE events to a file, to the
  window title bar, to the TSE message line, or any combination thereof.

  You turn on how and what you want to log in EventLogger's configuration menu.
  The configuration menus use check marks to show which log types and events
  are enabled for logging. Windows TSE uses a ">" check mark.
  The short menu option for the log directory shows it fully in the helpline.
  Logging is temporarily disabled during EventLogger's configuration.
  Logging is persistent across TSE sessions.
  You turn logging off quickly by deselecting the enabled log type.


  FILE LOGGING
    This is technically the best way, because it works fast and gives
    detailed timing information.
    You need to afterwards match your actions with the log entries.

  WINDOW TITLE BAR AND TSE MESSAGE LINE LOGGING
    Both these types of visual logging are problematical, because they
    interfere with and are interfered by the editor.
    Window title bar logging interferes less with what happens in the editor
    than TSE message line logging.
    For example, TSE message line logging can overwrite something you want to
    see, and is more likely to have problems or interfere with display events.
    Both types of visual logging suffer from not always being visually updated,
    which you can notice by the prefix message number not being updated.
    They don't suffer the same way, so sometimes even TSE message line logging
    can be the better visual solution.

    Both types of visual logging make the editor very slow, because it
    continuously has to pause for you, the slow user, to read the visual
    logging, but they have the great advantage that they (try to!) show events
    as they occur.

    The length of the pause between visually logged events can be configured
    to match the situation and your reading speed.

    Given the way Semware's CUAmark extension works and depending on for which
    events you have enabled logging, CUAmark can really slow down opening a
    prompt.
    You might want to temporarily purge CUAmark, or not, depending on whether
    it is relevant to your test. Usually it is relevant.   :-(

    In Linux via Putty, for me, window title bar logging does appear in
    the Putty title bar, but it works very badly.


  INSTALLATION

  Copy this file to TSE's "mac" folder and compile it there, for example by
  opening the file in TSE and applying the Macro -> Compile menu.

  Default the extension does nothing.

  Execute it as a macro to configure what you want it to do.
  For example use the menu Macro -> Execute, and enter its name: EventLogger.


  HISTORY

  v1      30 Dec 2021
    Initial non-beta release.

  v1.1    19 Jan 2022
    Now uses the editor's process id instead of its Windows handle, because:
    - Linux TSE does not have a Windows handle and does have a process id.
    - Log files can now be linked to processes in Windows' Task Manager
      and to processes shown by Linux commands like "top", "ps", etc.
*/





/*
  I N T E R N A L   M A C R O   T E C H N I C A L   I N F O



  VARIABLE MENU OPTION HELPLINE

  In the configuration menu I wanted to show the configured log directory as
  fully as possible, but a TSE menu option that is that wide would make all
  other menu options look ugly.

  Unfortunatly TSE menu options have a static helpline, so the helpline could
  not be used. Not as is.

  Theoretically there are other, cleaner solutions to this problem,
  but I chose to trick TSE's static helpline into making it modifyable.

  This trick is documented in the Demo_variable_menu_helpline tool,
  which can be found on my website.



  INTERNAL_VERSION

  This is the first time I applied INTERNAL_VERSION in a distributed macro,
  so I had to think about how to do that.

  INTERNAL_VERSION was added in TSE Beta v4.41.44.
  INTERNAL_VERSION and Version() have the same value,
  and represent TSE's compiler version.
  Unlike Version(), INTERNAL_VERSION can be used as a compiler directive!
  INTERNAL_VERSION and Version() are increased by 1 for each new TSE compiler
  version.
  ( Except in rare cases when Semware got sloppy: For example, a compiler bug
    was fixed in TSE v4.41.46, but the compiler has Version() = 12348
    in TSE v4.41.44 through v4.41.46. )
  Close TSE editor versions will have a different VersionStr(), but they might
  still use the same compiler version.
  Therefore such different editor versions can share the same INTERNAL_VERSION
  and Version().

  The events _POPMENU_STARTUP_ and _POPMENU_CLEANUP_ were added in TSE Beta
  v4.40.42.
  However, because TSE Beta v4.40.42 has no INTERNAL_VERSION yet, its specific
  TSE version cannot be tested for at compile time.
  I chose what I consider to be the least bad solution, namely to only show
  logging capability for the _POPMENU_STARTUP_ and _POPMENU_CLEANUP_ events in
  the later TSE Beta versions that can be tested for at compile time.
  That way nobody gets a compiler error, and beta users, who cannot be bothered
  to upgrade to the latest beta to get the latest features, they get their wish.

  For a likewise reason, in Linux the editor's process id will only be shown
  for Linux TSE v4.41.44 upwards.



  DELAY_CLOSE

  The editor's close button ("X") functions differently depending on the editor
  type and version:
    Console versions of the editor just abort: no files are saved.
    GUI versions before v4.41.46 do not call the _ON_ABANDON_EDITOR_ hook.
    GUI versions from v4.2 onwards do call the _LOSING_FOCUS_ hook last.

  This extension wants to always close properly, and as late as possible.
  From TSE GUI v4.2 onwards it will not do so from the _ON_ABANDON_EDITOR_ hook
  but from the later occurring _LOSING_FOCUS_ hook instead.
  To distinguish it from a _LOSING_FOCUS_ that is not the result of closing the
  editor, the global variable delay_close is used to check whether
  _ON_EXIT_CALLED_  or _ON_ABANDON_EDITOR_ were called just before it.
  Because _ON_EXIT_CALLED_ can also *not* close the editor, namely when the
  user cancels the action when asked to save a changed file, the _IDLE_ event
  resets delay_close.
  Because of all this, all the mentioned events must always be hooked, even
  when they are not selected for logging.


  CHECK MARK

  Modern Windows and Linux TSE versions default use the ANSI character set.
  ANSI does not have a check mark character.
  Linux TSE's OEM character set contains a "square root" character that looks a
  lot like a check mark, so Linux TSE falls back on that.
  Windows TSE's OEM character set has no check mark-like character, so Semware
  chose ">".

*/





// Compatibility restrictions and mitigations



/*
  When compiled with a TSE version below TSE 4.0 the compiler reports
  a syntax error and hilights the first applicable line below.

  There is a beta Linux version of TSE that is not bug-free and in which some
  significant features do not work, but all its Linux versions are above
  TSE 4.0, and they all are 32-bits which is what WIN32 actually signifies.
*/

#ifdef LINUX
  #define WIN32 FALSE
#endif

#ifdef WIN32
#else
   16-bit versions of TSE are not supported. You need at least TSE 4.0.
#endif

#ifdef EDITOR_VERSION
#else
   Editor Version is older than TSE 3.0. You need at least TSE 4.0.
#endif

#if EDITOR_VERSION < 4000h
   Editor Version is older than TSE 4.0. You need at least TSE 4.0.
#endif



#ifndef INTERNAL_VERSION
  #define INTERNAL_VERSION 0
#endif

#ifdef LINUX
  string NEWLINE           [1] = Chr(10)
  string SLASH             [1] = '/'
#else
  string NEWLINE           [2] = Chr(13) + Chr(10)
  string SLASH             [1] = '\'
#endif



#if EDITOR_VERSION < 4400h
  /*
    isAutoLoaded() 1.0

    This procedure implements TSE 4.4's isAutoLoaded() function for older TSE
    versions. This procedure differs in that here no parameter is allowed,
    so it can only examine the currently running macro's autoload status.
  */
  integer isAutoLoaded_id                    = 0
  string  isAutoLoaded_file_name_chrset [44] = "- !#$%&'()+,.0-9;=@A-Z[]^_`a-z{}~\d127-\d255"
  integer proc isAutoLoaded()
    string  autoload_name [255] = ''
    string  old_wordset    [32] = Set(WordSet, ChrSet(isAutoLoaded_file_name_chrset))
    integer org_id              = GetBufferId()
    integer result              = FALSE
    if isAutoLoaded_id
      GotoBufferId(isAutoLoaded_id)
    else
      autoload_name = SplitPath(CurrMacroFilename(), _NAME_) + ':isAutoLoaded'
      isAutoLoaded_id   = GetBufferId(autoload_name)
      if isAutoLoaded_id
        GotoBufferId(isAutoLoaded_id)
      else
        isAutoLoaded_id = CreateTempBuffer()
        ChangeCurrFilename(autoload_name, _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
      endif
    endif
    LoadBuffer(LoadDir() + 'tseload.dat')
    result = lFind(SplitPath(CurrMacroFilename(), _NAME_), "giw")
    Set(WordSet, old_wordset)
    GotoBufferId(org_id)
    return(result)
  end isAutoLoaded
#endif



#if EDITOR_VERSION < 4200h
  /*
    MkDir() 1.0

    This procedure implements the MkDir() command of TSE 4.2 upwards.
  */
  integer proc MkDir(string dir)
    Dos('MkDir ' + QuotePath(dir), _START_HIDDEN_)
    return(not DosIOResult())
  end MkDir
#endif



#if EDITOR_VERSION < 4400h
  /*
    StrReplace() 1.0

    If you have TSE Pro 4.0 or 4.2, then this proc almost completely implements
    the built-in StrReplace() function of TSE Pro 4.4.
    The StrReplace() function replaces a string (pattern) inside a string.
    It works for strings like the Replace() function does for files, so read
    the Help for the Replace() function for the usage of the options, but apply
    these differences while reading:
    - Where Replace() refers to "file" and "line", StrReplace() refers to
      "string".
    - The options "g" ("global", meaning "from the start of the string")
      and "n" ("no questions", meaning "do not ask for confirmation on
      replacements") are implicitly always active, and can therefore be omitted.
    Notable differences between the procedure below with TSE 4.4's built-in
    function are, that here the fourth parameter "options" is mandatory
    and that the fifth parameter "start position" does not exist.
  */
  integer strreplace_id = 0
  string proc StrReplace(string needle, string haystack, string replacer, string options)
    integer i                      = 0
    integer org_id                 = GetBufferId()
    string  result  [MAXSTRINGLEN] = haystack
    string  validated_options [20] = 'gn'
    for i = 1 to Length(options)
      if (Lower(SubStr(options, i, 1)) in '0'..'9', 'b', 'i','w', 'x', '^', '$')
        validated_options = validated_options + SubStr(options, i, 1)
      endif
    endfor
    if strreplace_id == 0
      strreplace_id = CreateTempBuffer()
    else
      GotoBufferId(strreplace_id)
      EmptyBuffer()
    endif
    InsertText(haystack, _INSERT_)
    lReplace(needle, replacer, validated_options)
    result = GetText(1, CurrLineLen())
    GotoBufferId(org_id)
    return(result)
  end StrReplace
#endif



#if EDITOR_VERSION < 4400h
  /*
    VersionStr()  v1.1

    This procedure implements TSE Pro 4.4 and above's VersionStr() command
    for lower versions of TSE.
    It returns a string containing TSE's version number in the same format
    as you see in the Help -> About menu, starting with the " v".

    Examples of relevant About lines:
      The SemWare Editor Professional v4.00e
      The SemWare Editor Professional/32 v4.00    [the console version]
      The SemWare Editor Professional v4.20
      The SemWare Editor Professional v4.40a

    v1.1 fixes recognition of the TSE Pro v4.0 console version.
  */
  string versionstr_value [MAXSTRINGLEN] = ''

  proc versionstr_screen_scraper()
    string  attributes [MAXSTRINGLEN] = ''
    string  characters [MAXSTRINGLEN] = ''
    integer position                  = 0
    integer window_row                = 1
    while versionstr_value == ''
    and   window_row       <= Query(WindowRows)
      GetStrAttrXY(1, window_row, characters, attributes, MAXSTRINGLEN)
      position = Pos('The SemWare Editor Professional', characters)
      if position
        position = Pos(' v', characters)
        if position
          versionstr_value = SubStr(characters, position + 1, MAXSTRINGLEN)
          versionstr_value = GetToken(versionstr_value, ' ', 1)
        endif
      endif
      window_row = window_row + 1
    endwhile
  end versionstr_screen_scraper

  string proc VersionStr()
    versionstr_value = ''
    Hook(_BEFORE_GETKEY_, versionstr_screen_scraper)
    PushKey(<Enter>)
    PushKey(<Enter>)
    BufferVideo()
    lVersion()
    UnBufferVideo()
    UnHook(versionstr_screen_scraper)
    return(versionstr_value)
  end VersionStr
#endif



// End of compatibility restrictions and mitigations





// Global constants and semi-constants

// Stop logging idle after N consecutive times until another event happens.
#define LOG_IDLE_TIMES          3
#define LOG_NONEDIT_IDLE_TIMES  3

#define INTERNAL_VERSION_V4_41_44 12348

#if INTERNAL_VERSION >= INTERNAL_VERSION_V4_41_44
  #define SUMMARY_SIZE 5
#else
  #define SUMMARY_SIZE 3
#endif

string DIR_HELPLINE_REF_STR [MAXSTRINGLEN] =
  'MQFP9YVKCV3IDOBE0WZ84MT9JDQVO29KBNNQXUJBQLF623W7JCRIYAIJU3JOF4VIXZYP339NJRNFWSJC4O875I6XFQ3I08FS64I5HBDHA65T87UU45NA9EJK3FTX1WIDL2BMFCOXGWLT2DT2K8G2ZKL8R7BLI92NHOVPN2KQEO84KU4EXSSALHAATEB35JMP7ACVXO9RSQFF5I5EDQ0XCMRW5C9DLC6FDF3DSYS12RFOGENIE9VPLV85FTNUDLM'

#if INTERNAL_VERSION >= INTERNAL_VERSION_V4_41_44
string STARTUP_CLEANUP_EVENT_GROUP [MAXSTRINGLEN] =
  '_ON_EDITOR_STARTUP_' + ' ' +
  '_ON_EXIT_CALLED_'    + ' ' +
  '_ON_ABANDON_EDITOR_' + ' ' +
  '_LIST_STARTUP_'      + ' ' +
  '_LIST_CLEANUP_'      + ' ' +
  '_PICKFILE_STARTUP_'  + ' ' +
  '_PICKFILE_CLEANUP_'  + ' ' +
  '_PROMPT_STARTUP_'    + ' ' +
  '_PROMPT_CLEANUP_'    + ' ' +
  '_POPMENU_STARTUP_'   + ' ' +
  '_POPMENU_CLEANUP_'
#else
string STARTUP_CLEANUP_EVENT_GROUP [MAXSTRINGLEN] =
  '_ON_EDITOR_STARTUP_' + ' ' +
  '_ON_EXIT_CALLED_'    + ' ' +
  '_ON_ABANDON_EDITOR_' + ' ' +
  '_LIST_STARTUP_'      + ' ' +
  '_LIST_CLEANUP_'      + ' ' +
  '_PICKFILE_STARTUP_'  + ' ' +
  '_PICKFILE_CLEANUP_'  + ' ' +
  '_PROMPT_STARTUP_'    + ' ' +
  '_PROMPT_CLEANUP_'
#endif

string FILE_EVENT_GROUP [MAXSTRINGLEN] =
  '_ON_CHANGING_FILES_' + ' ' +
  '_ON_FIRST_EDIT_'     + ' ' +
  '_ON_FILE_LOAD_'      + ' ' +
  '_ON_FILE_SAVE_'      + ' ' +
  '_AFTER_FILE_SAVE_'   + ' ' +
  '_ON_FILE_QUIT_'

string IDLE_EVENT_GROUP [MAXSTRINGLEN] =
  '_IDLE_'         + ' ' +
  '_NONEDIT_IDLE_'

string DISPLAY_EVENT_GROUP [MAXSTRINGLEN] =
  '_BEFORE_UPDATE_DISPLAY_'   + ' ' +
  '_AFTER_UPDATE_DISPLAY_'    + ' ' +
  '_AFTER_UPDATE_STATUSLINE_' + ' ' +
  '_PRE_UPDATE_ALL_WINDOWS_'  + ' ' +
  '_POST_UPDATE_ALL_WINDOWS_'

string COMMAND_EVENT_GROUP [MAXSTRINGLEN] =
  '_BEFORE_COMMAND_'         + ' ' +
  '_AFTER_COMMAND_'          + ' ' +
  '_BEFORE_NONEDIT_COMMAND_' + ' ' +
  '_AFTER_NONEDIT_COMMAND_'  + ' ' +
  '_ON_SELFINSERT_'          + ' ' +
  '_ON_DELCHAR_'

string KEY_EVENT_GROUP [MAXSTRINGLEN] =
  '_ON_UNASSIGNED_KEY_'         + ' ' +
  '_ON_NONEDIT_UNASSIGNED_KEY_' + ' ' +
  '_BEFORE_GETKEY_'             + ' ' +
  '_AFTER_GETKEY_'

#if EDITOR_VERSION >= 4200h
string FOCUS_EVENT_GROUP [MAXSTRINGLEN] =
  '_GAINING_FOCUS_'         + ' ' +
  '_LOSING_FOCUS_'          + ' ' +
  '_NONEDIT_GAINING_FOCUS_' + ' ' +
  '_NONEDIT_LOSING_FOCUS_'
#endif

string MACRO_NAME   [MAXSTRINGLEN] = ''
string SECTION_NAME [MAXSTRINGLEN] = ''





// Global variables
integer dir_helpline_menu_addr    = 0
integer delay_close               = FALSE
integer event_counter             = 0
string  log_dir    [MAXSTRINGLEN] = ''
string  log_file   [MAXSTRINGLEN] = ''
integer log_handle                = -1
integer log_idle_counter          = 0
integer log_nonedit_idle_counter  = 0
integer log_to_file               = FALSE
integer log_to_message            = FALSE
integer log_to_title              = FALSE
integer ok                        = TRUE
integer old_DateFormat            = 0
integer old_DateSeparator         = 0
integer old_TimeFormat            = 0
integer old_TimeSeparator         = 0
integer stop_main_menu_loop       = TRUE
integer visual_pause              = 0


integer logging_ON_EDITOR_STARTUP_         = FALSE
integer logging_ON_EXIT_CALLED_            = FALSE
integer logging_ON_ABANDON_EDITOR_         = FALSE
integer logging_LIST_STARTUP_              = FALSE
integer logging_LIST_CLEANUP_              = FALSE
integer logging_PICKFILE_STARTUP_          = FALSE
integer logging_PICKFILE_CLEANUP_          = FALSE
integer logging_PROMPT_STARTUP_            = FALSE
integer logging_PROMPT_CLEANUP_            = FALSE
#if INTERNAL_VERSION >= INTERNAL_VERSION_V4_41_44
integer logging_POPMENU_STARTUP_           = FALSE
integer logging_POPMENU_CLEANUP_           = FALSE
#endif

integer logging_ON_CHANGING_FILES_         = FALSE
integer logging_ON_FIRST_EDIT_             = FALSE
integer logging_ON_FILE_LOAD_              = FALSE
integer logging_ON_FILE_SAVE_              = FALSE
integer logging_AFTER_FILE_SAVE_           = FALSE
integer logging_ON_FILE_QUIT_              = FALSE

integer logging_IDLE_                      = FALSE
integer logging_NONEDIT_IDLE_              = FALSE

integer logging_BEFORE_UPDATE_DISPLAY_     = FALSE
integer logging_AFTER_UPDATE_DISPLAY_      = FALSE
integer logging_AFTER_UPDATE_STATUSLINE_   = FALSE
integer logging_PRE_UPDATE_ALL_WINDOWS_    = FALSE
integer logging_POST_UPDATE_ALL_WINDOWS_   = FALSE

integer logging_BEFORE_COMMAND_            = FALSE
integer logging_AFTER_COMMAND_             = FALSE
integer logging_BEFORE_NONEDIT_COMMAND_    = FALSE
integer logging_AFTER_NONEDIT_COMMAND_     = FALSE
integer logging_ON_SELFINSERT_             = FALSE
integer logging_ON_DELCHAR_                = FALSE

integer logging_ON_UNASSIGNED_KEY_         = FALSE
integer logging_ON_NONEDIT_UNASSIGNED_KEY_ = FALSE
integer logging_BEFORE_GETKEY_             = FALSE
integer logging_AFTER_GETKEY_              = FALSE

#if EDITOR_VERSION >= 4200h
integer logging_GAINING_FOCUS_             = FALSE
integer logging_LOSING_FOCUS_              = FALSE
integer logging_NONEDIT_GAINING_FOCUS_     = FALSE
integer logging_NONEDIT_LOSING_FOCUS_      = FALSE
#endif



// Start of variable menu helper functions

proc write_helpline(integer helpline_addr, string new_helpline)
  integer byte_addr        = helpline_addr
  integer max_helpline_len = PeekByte(AdjPtr(helpline_addr, -1))
  integer i                = 0
  if helpline_addr
    for i = 1 to Min(Length(new_helpline), max_helpline_len)
      PokeByte(byte_addr, Asc(new_helpline[i]))
      byte_addr = AdjPtr(byte_addr, 1)
    endfor
    for i = Length(new_helpline) + 1 to max_helpline_len
      PokeByte(byte_addr, 32) // Overwrite old content with trailing spaces.
      byte_addr = AdjPtr(byte_addr, 1)
    endfor
  endif
end write_helpline

/*  Commented this proc, because it is not used in this macro.
string proc get_helpline(integer helpline_addr)
  integer byte_addr                   = helpline_addr
  string  cur_helpline [MAXSTRINGLEN] = ''
  integer helpline_len                = PeekByte(AdjPtr(helpline_addr, -1))
  integer i                           = 0
  if helpline_addr
    for i = 1 to helpline_len
      cur_helpline = cur_helpline + Chr(PeekByte(byte_addr))
      byte_addr    = AdjPtr(byte_addr, 1)
    endfor
  endif
  cur_helpline = RTrim(cur_helpline)
  return(cur_helpline)
end get_helpline
*/

// This proc should not be called directly.
// It is a helper proc for the get_helpline_address proc.
integer proc get_helpline_address_match(integer mem_addr, var string target_str)
  integer byte_addr             = mem_addr
  integer i                     = 0
  integer matched               = TRUE
  string  mem_char         [1] = ''
  string  str_char          [1] = ''
  for i = 1 to Length(target_str)
    mem_char = Chr(PeekByte(byte_addr))
    str_char  = target_str[i]
    if mem_char == str_char
      byte_addr = AdjPtr(byte_addr, 1)
    else
      matched = FALSE
      break
    endif
  endfor
  return(matched)
end get_helpline_address_match

integer proc get_helpline_address(var string  helpline_search_str)
  integer i                  = 0
  integer menu_helpline_addr = 0
  integer search_addr        = 0
  search_addr = Addr(helpline_search_str) + Length(helpline_search_str)
  for i = 1 to 65536
    if get_helpline_address_match(search_addr, helpline_search_str)
      menu_helpline_addr = search_addr
      break
    else
      search_addr = AdjPtr(search_addr, 1)
    endif
  endfor
  return(menu_helpline_addr)
end get_helpline_address

// End of variable menu helper functions



// Start of get_process_id() implementations

#ifdef LINUX
  integer proc get_process_id()
    #if INTERNAL_VERSION >= INTERNAL_VERSION_V4_41_44
      // I have implemented two methods for getting the editor's process id
      // from Linux. Both methods work on my Linux distros.
      string  cmd       [MAXSTRINGLEN] = ''
      string  cmd_shell [MAXSTRINGLEN] = '/bin/bash'
      integer process_id               = 0
      integer rc                       = 0
      // Try Method 1, with a shell
      if not FileExists(cmd_shell)
        cmd_shell = GetEnvStr('SHELL')
        if not FileExists(cmd_shell)
          cmd_shell = ''
        endif
      endif
      if cmd_shell <> ''
        PushLocation()
        EmptyBuffer(Query(CaptureId))
        Capture(cmd_shell + ' -c "ps -p $$ --no-headers -o ppid"')
        rc = DosIOResult()
        if      LoByte(rc)
        and not HiByte(rc)
        and     NumLines() == 1
          process_id = Val(Trim(GetText(1, MAXSTRINGLEN)))
        endif
        PopLocation()
      endif
      if process_id == 0
        // Try method 2, without a shell
        PushLocation()
        EmptyBuffer(Query(CaptureId))
        Capture('ps T --no-headers -o pid,cmd')
        rc = DosIOResult()
        if      LoByte(rc)
        and not HiByte(rc)
        and     NumLines()
          BegFile()
          repeat
            if lFind('^[ \d009]*[0-9]#[ \d009]#\c', 'cgx')
              cmd = GetText(CurrPos(), MAXSTRINGLEN)
              cmd = GetFileToken(cmd, 1)
              cmd = GetToken(cmd, '/', NumTokens(cmd, '/'))
              if SplitPath(LoadDir(TRUE), _NAME_|_EXT_) == cmd
                process_id = Val(GetToken(GetText(1, MAXSTRINGLEN), ' ', 1))
              endif
            endif
          until not Down()
        endif
        PopLocation()
      endif
      return(process_id)
    #else
      return(0)
    #endif
  end get_process_id
#else
  dll "<Kernel32.dll>"
    integer proc GetCurrentProcessId(integer void)
  end

  integer proc get_process_id()
    return(GetCurrentProcessId(0))
  end get_process_id
#endif

// End of get_process_id() implementations



string proc unquote(string s)
  if (s[1:1] in '"', "'")
  and s[1:1] == s[1:Length(s)]
    return(s[2 .. Length(s) - 1])
  endif
  return(s)
end unquote

integer proc mk_dir(string dir) // Including subdirs
  integer i                          = 0
  string  partial_dir [MAXSTRINGLEN] = ''
  integer partial_result             = TRUE
  integer result                     = FALSE
  if FileExists(dir) & _DIRECTORY_
    result = TRUE
  else
    i = 1
    while partial_result
    and   i <= NumTokens(dir, SLASH)
      if GetToken(dir, SLASH, i) <> ''
        if i == 1
          partial_dir = GetToken(dir, SLASH, i)
        else
          partial_dir = partial_dir + SLASH + GetToken(dir, SLASH, i)
        endif
        if not (FileExists(partial_dir) & _DIRECTORY_)
          partial_result = MkDir(partial_dir)
        endif
      endif
      i = i + 1
    endwhile
    if  partial_result
    and FileExists(dir) & _DIRECTORY_
      result = TRUE
    endif
  endif
  return(result)
end mk_dir

proc programming_error(integer error)
  Warn(MACRO_NAME; 'programming error'; error, '.')
  ok = FALSE
end programming_error

proc show_help()
  string  full_macro_source_name [MAXSTRINGLEN] = LoadDir() + 'mac' + SLASH + MACRO_NAME + '.s'
  string  help_file_name         [MAXSTRINGLEN] = '*** ' + MACRO_NAME + ' Help ***'
  integer hlp_id                                = GetBufferId(help_file_name)
  integer org_id                                = GetBufferId()
  integer tmp_id                                = 0
  if hlp_id
    GotoBufferId(hlp_id)
    UpdateDisplay()
  else
    tmp_id = CreateTempBuffer()
    if LoadBuffer(full_macro_source_name)
      // Separate characters, otherwise my SynCase macro gets confused.
      if lFind('/' + '*', 'g')
        PushBlock()
        UnMarkBlock()
        Right(2)
        MarkChar()
        if not lFind('*' + '/', '')
          EndFile()
        endif
        MarkChar()
        Copy()
        CreateTempBuffer()
        Paste()
        UnMarkBlock()
        PopBlock()
        BegFile()
        ChangeCurrFilename(help_file_name, _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
        BufferType(_NORMAL_)
        FileChanged(FALSE)
        BrowseMode(TRUE)
        UpdateDisplay()
      else
        GotoBufferId(org_id)
        Warn('File "', full_macro_source_name, '" has no multi-line comment block.')
      endif
    else
      GotoBufferId(org_id)
      Warn('File "', full_macro_source_name, '" not found.')
    endif
    AbandonFile(tmp_id)
  endif
end show_help

integer proc get_profile_int(string item_name)
  integer value         = 0
  integer default_value = FALSE

  value = GetProfileInt(SECTION_NAME, item_name, default_value)

  case item_name
    when '_ON_EDITOR_STARTUP_'         logging_ON_EDITOR_STARTUP_         = value
    when '_ON_EXIT_CALLED_'            logging_ON_EXIT_CALLED_            = value
    when '_ON_ABANDON_EDITOR_'         logging_ON_ABANDON_EDITOR_         = value
    when '_LIST_STARTUP_'              logging_LIST_STARTUP_              = value
    when '_LIST_CLEANUP_'              logging_LIST_CLEANUP_              = value
    when '_PICKFILE_STARTUP_'          logging_PICKFILE_STARTUP_          = value
    when '_PICKFILE_CLEANUP_'          logging_PICKFILE_CLEANUP_          = value
    when '_PROMPT_STARTUP_'            logging_PROMPT_STARTUP_            = value
    when '_PROMPT_CLEANUP_'            logging_PROMPT_CLEANUP_            = value

#if INTERNAL_VERSION >= INTERNAL_VERSION_V4_41_44
    when '_POPMENU_STARTUP_'           logging_POPMENU_STARTUP_           = value
    when '_POPMENU_CLEANUP_'           logging_POPMENU_CLEANUP_           = value
#endif

    when '_ON_CHANGING_FILES_'         logging_ON_CHANGING_FILES_         = value
    when '_ON_FIRST_EDIT_'             logging_ON_FIRST_EDIT_             = value
    when '_ON_FILE_LOAD_'              logging_ON_FILE_LOAD_              = value
    when '_ON_FILE_SAVE_'              logging_ON_FILE_SAVE_              = value
    when '_AFTER_FILE_SAVE_'           logging_AFTER_FILE_SAVE_           = value
    when '_ON_FILE_QUIT_'              logging_ON_FILE_QUIT_              = value

    when '_IDLE_'                      logging_IDLE_                      = value
    when '_NONEDIT_IDLE_'              logging_NONEDIT_IDLE_              = value

    when '_BEFORE_UPDATE_DISPLAY_'     logging_BEFORE_UPDATE_DISPLAY_     = value
    when '_AFTER_UPDATE_DISPLAY_'      logging_AFTER_UPDATE_DISPLAY_      = value
    when '_AFTER_UPDATE_STATUSLINE_'   logging_AFTER_UPDATE_STATUSLINE_   = value
    when '_PRE_UPDATE_ALL_WINDOWS_'    logging_PRE_UPDATE_ALL_WINDOWS_    = value
    when '_POST_UPDATE_ALL_WINDOWS_'   logging_POST_UPDATE_ALL_WINDOWS_   = value

    when '_BEFORE_COMMAND_'            logging_BEFORE_COMMAND_            = value
    when '_AFTER_COMMAND_'             logging_AFTER_COMMAND_             = value
    when '_BEFORE_NONEDIT_COMMAND_'    logging_BEFORE_NONEDIT_COMMAND_    = value
    when '_AFTER_NONEDIT_COMMAND_'     logging_AFTER_NONEDIT_COMMAND_     = value
    when '_ON_SELFINSERT_'             logging_ON_SELFINSERT_             = value
    when '_ON_DELCHAR_'                logging_ON_DELCHAR_                = value

    when '_ON_UNASSIGNED_KEY_'         logging_ON_UNASSIGNED_KEY_         = value
    when '_ON_NONEDIT_UNASSIGNED_KEY_' logging_ON_NONEDIT_UNASSIGNED_KEY_ = value
    when '_BEFORE_GETKEY_'             logging_BEFORE_GETKEY_             = value
    when '_AFTER_GETKEY_'              logging_AFTER_GETKEY_              = value

#if EDITOR_VERSION >= 4200h
    when '_GAINING_FOCUS_'             logging_GAINING_FOCUS_             = value
    when '_LOSING_FOCUS_'              logging_LOSING_FOCUS_              = value
    when '_NONEDIT_GAINING_FOCUS_'     logging_NONEDIT_GAINING_FOCUS_     = value
    when '_NONEDIT_LOSING_FOCUS_'      logging_NONEDIT_LOSING_FOCUS_      = value
#endif

    when 'log_to_file'                 log_to_file                        = value
    when 'log_to_title'                log_to_title                       = value
    when 'log_to_message'              log_to_message                     = value

    when 'visual_pause'                visual_pause                       = value

    otherwise
      programming_error(1)
  endcase

  return(value)
end get_profile_int

proc write_profile_str(string item_name, string item_value)
  if not  WriteProfileStr(SECTION_NAME, item_name, item_value)
    Warn(MACRO_NAME; 'abort: Could not write profile file. (Default tse.ini.)')
    ok = FALSE
  endif
end write_profile_str

proc write_profile_int(string item_name, integer value)

  case item_name
    when '_ON_EDITOR_STARTUP_'         logging_ON_EDITOR_STARTUP_         = value
    when '_ON_EXIT_CALLED_'            logging_ON_EXIT_CALLED_            = value
    when '_ON_ABANDON_EDITOR_'         logging_ON_ABANDON_EDITOR_         = value
    when '_LIST_STARTUP_'              logging_LIST_STARTUP_              = value
    when '_LIST_CLEANUP_'              logging_LIST_CLEANUP_              = value
    when '_PICKFILE_STARTUP_'          logging_PICKFILE_STARTUP_          = value
    when '_PICKFILE_CLEANUP_'          logging_PICKFILE_CLEANUP_          = value
    when '_PROMPT_STARTUP_'            logging_PROMPT_STARTUP_            = value
    when '_PROMPT_CLEANUP_'            logging_PROMPT_CLEANUP_            = value

#if INTERNAL_VERSION >= INTERNAL_VERSION_V4_41_44
    when '_POPMENU_STARTUP_'           logging_POPMENU_STARTUP_           = value
    when '_POPMENU_CLEANUP_'           logging_POPMENU_CLEANUP_           = value
#endif

    when '_ON_CHANGING_FILES_'         logging_ON_CHANGING_FILES_         = value
    when '_ON_FIRST_EDIT_'             logging_ON_FIRST_EDIT_             = value
    when '_ON_FILE_LOAD_'              logging_ON_FILE_LOAD_              = value
    when '_ON_FILE_SAVE_'              logging_ON_FILE_SAVE_              = value
    when '_AFTER_FILE_SAVE_'           logging_AFTER_FILE_SAVE_           = value
    when '_ON_FILE_QUIT_'              logging_ON_FILE_QUIT_              = value

    when '_IDLE_'                      logging_IDLE_                      = value
    when '_NONEDIT_IDLE_'              logging_NONEDIT_IDLE_              = value

    when '_BEFORE_UPDATE_DISPLAY_'     logging_BEFORE_UPDATE_DISPLAY_     = value
    when '_AFTER_UPDATE_DISPLAY_'      logging_AFTER_UPDATE_DISPLAY_      = value
    when '_AFTER_UPDATE_STATUSLINE_'   logging_AFTER_UPDATE_STATUSLINE_   = value
    when '_PRE_UPDATE_ALL_WINDOWS_'    logging_PRE_UPDATE_ALL_WINDOWS_    = value
    when '_POST_UPDATE_ALL_WINDOWS_'   logging_POST_UPDATE_ALL_WINDOWS_   = value

    when '_BEFORE_COMMAND_'            logging_BEFORE_COMMAND_            = value
    when '_AFTER_COMMAND_'             logging_AFTER_COMMAND_             = value
    when '_BEFORE_NONEDIT_COMMAND_'    logging_BEFORE_NONEDIT_COMMAND_    = value
    when '_AFTER_NONEDIT_COMMAND_'     logging_AFTER_NONEDIT_COMMAND_     = value
    when '_ON_SELFINSERT_'             logging_ON_SELFINSERT_             = value
    when '_ON_DELCHAR_'                logging_ON_DELCHAR_                = value

    when '_ON_UNASSIGNED_KEY_'         logging_ON_UNASSIGNED_KEY_         = value
    when '_ON_NONEDIT_UNASSIGNED_KEY_' logging_ON_NONEDIT_UNASSIGNED_KEY_ = value
    when '_BEFORE_GETKEY_'             logging_BEFORE_GETKEY_             = value
    when '_AFTER_GETKEY_'              logging_AFTER_GETKEY_              = value

#if EDITOR_VERSION >= 4200h
    when '_GAINING_FOCUS_'             logging_GAINING_FOCUS_             = value
    when '_LOSING_FOCUS_'              logging_LOSING_FOCUS_              = value
    when '_NONEDIT_GAINING_FOCUS_'     logging_NONEDIT_GAINING_FOCUS_     = value
    when '_NONEDIT_LOSING_FOCUS_'      logging_NONEDIT_LOSING_FOCUS_      = value
#endif

    when 'log_to_file'                 log_to_file                        = value
    when 'log_to_title'                log_to_title                       = value
    when 'log_to_message'              log_to_message                     = value

    when 'visual_pause'                visual_pause                       = value

    otherwise
      programming_error(2)
  endcase

  ok = ok and WriteProfileInt(SECTION_NAME, item_name, value)
  if not ok
    Warn(MACRO_NAME, ' abort: Could not write profile file. (Default tse.ini.)')
  endif
end write_profile_int

proc set_log_dir()
  string old_log_dir [MAXSTRINGLEN] = GetProfileStr(SECTION_NAME, 'log_dir', '')

  if log_dir == ''
    log_dir = old_log_dir
  endif

  if      log_dir <> ''
  and not (FileExists(log_dir) & _DIRECTORY_)
    Warn(MACRO_NAME; 'warning: No such log dir: "', log_dir, '":', Chr(13),
         'Log dir is set to default value.')
    log_dir = ''
  endif

  if log_dir == ''
    #ifdef LINUX
      log_dir = GetEnvStr('HOME')
    #else
      log_dir = GetEnvStr('USERPROFILE')
    #endif
    if  log_dir <> ''
    and (FileExists(log_dir) & _DIRECTORY_)
      log_dir = log_dir + SLASH + 'Log' + SLASH + 'Tse' + SLASH + MACRO_NAME
      if not mk_dir(log_dir)
        Warn(MACRO_NAME; 'warning: Could not create log dir "', log_dir, '".')
        log_dir = ''
      endif
    else
      log_dir = ''
    endif
  endif

  if log_dir == ''
    #ifdef LINUX
      log_dir = '/tmp'
    #else
      log_dir = GetEnvStr('TMP')
      if log_dir == ''
        log_dir = GetEnvStr('TEMP')
      endif
      log_dir = RemoveTrailingSlash(log_dir)
    #endif
    if  log_dir <> ''
    and (FileExists(log_dir) & _DIRECTORY_)
      log_dir = log_dir + SLASH + 'Log' + SLASH + 'Tse' + SLASH + MACRO_NAME
      if not mk_dir(log_dir)
        Warn(MACRO_NAME; 'warning: Could not create log dir "', log_dir, '".')
        log_dir = ''
      endif
    else
      log_dir = ''
    endif
  endif

  if  log_dir <> ''
  and log_dir <> old_log_dir
  and (FileExists(log_dir) & _DIRECTORY_)
    write_profile_str('log_dir', log_dir)
  endif
end set_log_dir

proc init_config_variables()

  get_profile_int('_ON_EDITOR_STARTUP_')
  get_profile_int('_ON_EXIT_CALLED_')
  get_profile_int('_ON_ABANDON_EDITOR_')
  get_profile_int('_LIST_STARTUP_')
  get_profile_int('_LIST_CLEANUP_')
  get_profile_int('_PICKFILE_STARTUP_')
  get_profile_int('_PICKFILE_CLEANUP_')
  get_profile_int('_PROMPT_STARTUP_')
  get_profile_int('_PROMPT_CLEANUP_')

  get_profile_int('_ON_CHANGING_FILES_')
  get_profile_int('_ON_FIRST_EDIT_')
  get_profile_int('_ON_FILE_LOAD_')
  get_profile_int('_ON_FILE_SAVE_')
  get_profile_int('_AFTER_FILE_SAVE_')
  get_profile_int('_ON_FILE_QUIT_')

  get_profile_int('_IDLE_')
  get_profile_int('_NONEDIT_IDLE_')

  get_profile_int('_BEFORE_UPDATE_DISPLAY_')
  get_profile_int('_AFTER_UPDATE_DISPLAY_')
  get_profile_int('_AFTER_UPDATE_STATUSLINE_')
  get_profile_int('_PRE_UPDATE_ALL_WINDOWS_')
  get_profile_int('_POST_UPDATE_ALL_WINDOWS_')

  get_profile_int('_BEFORE_COMMAND_')
  get_profile_int('_AFTER_COMMAND_')
  get_profile_int('_BEFORE_NONEDIT_COMMAND_')
  get_profile_int('_AFTER_NONEDIT_COMMAND_')
  get_profile_int('_ON_SELFINSERT_')
  get_profile_int('_ON_DELCHAR_')

  get_profile_int('_ON_UNASSIGNED_KEY_')
  get_profile_int('_ON_NONEDIT_UNASSIGNED_KEY_')
  get_profile_int('_BEFORE_GETKEY_')
  get_profile_int('_AFTER_GETKEY_')

#if EDITOR_VERSION >= 4200h
  get_profile_int('_GAINING_FOCUS_')
  get_profile_int('_LOSING_FOCUS_')
  get_profile_int('_NONEDIT_GAINING_FOCUS_')
  get_profile_int('_NONEDIT_LOSING_FOCUS_')
#endif

  get_profile_int('log_to_file')
  get_profile_int('log_to_title')
  get_profile_int('log_to_message')

  get_profile_int('visual_pause')

  if not visual_pause
    visual_pause = 18
  endif

  set_log_dir()
end init_config_variables

proc restore_window_title()
  if log_to_title
    SetWindowTitle(Format(SplitPath(CurrFilename(), _NAME_|_EXT_),
                          '': MAXSTRINGLEN))
  endif
end restore_window_title

proc customise_date_time_formats()
  old_DateFormat    = Set(DateFormat   , 6 )
  old_DateSeparator = Set(DateSeparator, Asc('*'))
  old_TimeFormat    = Set(TimeFormat   , 1 )
  old_TimeSeparator = Set(TimeSeparator, Asc('*'))
end customise_date_time_formats

proc restore_date_time_formats()
  Set(DateFormat   , old_DateFormat   )
  Set(DateSeparator, old_DateSeparator)
  Set(TimeFormat   , old_TimeFormat   )
  Set(TimeSeparator, old_TimeSeparator)
end restore_date_time_formats

proc write_log_line(string log_line)
  integer bytes_written       = 0
  string  data [MAXSTRINGLEN] = ''
  integer old_DateFormat      = Set(DateFormat, 6)
  integer old_TimeFormat      = Set(TimeFormat, 1)
  if log_handle <> -1
    data          = Format(GetDateStr(); GetTimeStr(), '.',
                           GetTime() mod 100 : 2: '0';
                           log_line, NEWLINE)
    bytes_written = fWrite(log_handle, data)
    if bytes_written <> Length(data)
      programming_error(4)
    endif
  endif
  Set(DateFormat, old_DateFormat)
  Set(TimeFormat, old_TimeFormat)
end write_log_line

proc close_log_file()
  if log_handle == -1
    programming_error(7)
  else
    write_log_line('Logfile closed.')
    if not fClose(log_handle)
      programming_error(5)
    endif
    log_handle = -1
  endif
end close_log_file

proc open_log_file()
  if log_handle <> -1
    programming_error(8)
    close_log_file()
  endif

  if ok
    customise_date_time_formats()
    log_file   = Format(GetDateStr(), '_', GetTimeStr())
    restore_date_time_formats()
    log_file   = StrReplace(' ', log_file, '0', '')
    log_file   = StrReplace('*', log_file, '' , '')

    if not Pos(Lower(SLASH + MACRO_NAME + SLASH), Lower(log_dir))
    and   Lower(SLASH + MACRO_NAME) <>
          Lower(log_dir[Length(log_dir) - Length(MACRO_NAME): MAXSTRINGLEN])
      log_file = MACRO_NAME + '_' + log_file
    endif

    log_file   = Format(log_dir, SLASH, log_file, '_', get_process_id(), '.txt')
    log_handle = fCreate(log_file)
    if log_handle == -1
      programming_error(6)
    else
      write_log_line(       'Logfile opened.')
      write_log_line(Format('Process id        :'; get_process_id()))
      write_log_line(Format('TSE folder        :'; LoadDir()))
      write_log_line(Format('TSE EDITOR_VERSION:'; Str(EDITOR_VERSION, 16),
                            ' (hex)'))
      write_log_line(Format('TSE Version()     :'; Str(Version()     , 16),
                            ' (hex), ', Version(), ' (dec).'))
      write_log_line(Format('TSE VersionStr()  :'; VersionStr(), '.'))
      write_log_line(Format('This is the ', iif(isGUI(), 'GUI', 'Console'),
                            ' version of the editor.'))
      case WhichOS()
        when _WINDOWS_
          write_log_line('The OS is Windows 95, 98, Millennium or older.')
        when _WINDOWSNT_
          write_log_line('The OS is Windows NT or newer.')
  #if EDITOR_VERSION >= 4400h
        when _LINUX_
          write_log_line('The OS is Linux.')
  #endif
        otherwise
          write_log_line('The OS is unknown.')
      endcase
    endif
  endif
end open_log_file

proc generic_message(string msg)
  event_counter = event_counter + 1
  if log_to_file
    write_log_line(Format(event_counter; msg))
  endif
  if log_to_title
    SetWindowTitle(Format(MACRO_NAME, '   ', event_counter, '   ', msg,
                          '':MAXSTRINGLEN))
  endif
  if log_to_message
    Message(MACRO_NAME, '   ', event_counter, '   ', msg, '':MAXSTRINGLEN)
  endif
  if log_to_title
  or log_to_message
    Delay(visual_pause)
  endif
  if msg <> '_IDLE_'
    log_idle_counter = 0
  endif
  if msg <> '_NONEDIT_IDLE_'
    log_nonedit_idle_counter = 0
  endif
end generic_message

proc on_editor_startup()
  generic_message('_ON_EDITOR_STARTUP_')
end on_editor_startup

proc on_exit_called()
  if logging_ON_EXIT_CALLED_
    generic_message('_ON_EXIT_CALLED_')
  endif
  #if EDITOR_VERSION >= 4200h
    if isGUI()
      delay_close = TRUE
    endif
  #endif
end on_exit_called

proc on_abandon_editor()
  if logging_ON_ABANDON_EDITOR_
    generic_message('_ON_ABANDON_EDITOR_')
  endif
  if not delay_close
    WhenPurged()
  endif
end on_abandon_editor

proc list_startup()
  generic_message('_LIST_STARTUP_')
end list_startup

proc list_cleanup()
  generic_message('_LIST_CLEANUP_')
end list_cleanup

proc pickfile_startup()
  generic_message('_PICKFILE_STARTUP_')
end pickfile_startup

proc pickfile_cleanup()
  generic_message('_PICKFILE_CLEANUP_')
end pickfile_cleanup

proc prompt_startup()
  generic_message('_PROMPT_STARTUP_')
end prompt_startup

proc prompt_cleanup()
  generic_message('_PROMPT_CLEANUP_')
end prompt_cleanup

#if INTERNAL_VERSION >= INTERNAL_VERSION_V4_41_44

proc popmenu_startup()
  generic_message('_POPMENU_STARTUP_')
end popmenu_startup

proc popmenu_cleanup()
  generic_message('_POPMENU_CLEANUP_')
end popmenu_cleanup

#endif

proc on_changing_files()
  generic_message('_ON_CHANGING_FILES_ to "' + CurrFilename() + '"')
end on_changing_files

proc on_first_edit()
  generic_message('_ON_FIRST_EDIT_ "' + CurrFilename() + '"')
end on_first_edit

proc on_file_load()
  generic_message('_ON_FILE_LOAD_ "' + CurrFilename() + '"')
end on_file_load

proc on_file_save()
  generic_message('_ON_FILE_SAVE_ "' + CurrFilename() + '"')
end on_file_save

proc after_file_save()
  generic_message('_AFTER_FILE_SAVE_ "' + CurrFilename() + '"')
end after_file_save

proc on_file_quit()
  generic_message('_ON_FILE_QUIT_ "' + CurrFilename() + '"')
end on_file_quit



proc idle()
  if logging_IDLE_
    log_idle_counter = log_idle_counter + 1
    if log_idle_counter <= LOG_IDLE_TIMES
      generic_message('_IDLE_')
    elseif log_idle_counter == LOG_IDLE_TIMES + visual_pause
      restore_window_title()
    endif
  endif
  delay_close = FALSE
  if not ok
    PurgeMacro(MACRO_NAME)
  endif
end idle

proc nonedit_idle()
  log_nonedit_idle_counter = log_nonedit_idle_counter + 1
  if log_nonedit_idle_counter <= LOG_NONEDIT_IDLE_TIMES
    generic_message('_NONEDIT_IDLE_')
  elseif log_nonedit_idle_counter == LOG_NONEDIT_IDLE_TIMES + visual_pause
    restore_window_title()
  endif
end nonedit_idle



proc before_update_display()
  generic_message('_BEFORE_UPDATE_DISPLAY_')
end before_update_display

proc after_update_display()
  generic_message('_AFTER_UPDATE_DISPLAY_')
end after_update_display

proc after_update_statusline()
  generic_message('_AFTER_UPDATE_STATUSLINE_')
end after_update_statusline

proc pre_update_all_windows()
  generic_message('_PRE_UPDATE_ALL_WINDOWS_')
end pre_update_all_windows

proc post_update_all_windows()
  generic_message('_POST_UPDATE_ALL_WINDOWS_')
end post_update_all_windows



proc before_command()
  generic_message('_BEFORE_COMMAND_')
end before_command

proc after_command()
  generic_message('_AFTER_COMMAND_')
end after_command

proc before_nonedit_command()
  generic_message('_BEFORE_NONEDIT_COMMAND_')
end before_nonedit_command

proc after_nonedit_command()
  generic_message('_AFTER_NONEDIT_COMMAND_')
end after_nonedit_command

proc on_selfinsert()
  generic_message('_ON_SELFINSERT_' + ' <' + KeyName(CurrChar(CurrPos() - 1)) + '>')
end on_selfinsert

proc on_delchar()
  generic_message('_ON_DELCHAR_')
end on_delchar



proc on_unassigned_key()
  generic_message('_ON_UNASSIGNED_KEY_' + ' <' + KeyName(Query(Key)) + '>')
end on_unassigned_key

proc on_nonedit_unassigned_key()
  generic_message('_ON_NONEDIT_UNASSIGNED_KEY_' + ' <' + KeyName(Query(Key)) + '>')
end on_nonedit_unassigned_key

proc before_getkey()
  generic_message('_BEFORE_GETKEY_')
end before_getkey

proc after_getkey()
  generic_message('_AFTER_GETKEY_' + ' <' + KeyName(Query(Key)) + '>')
end after_getkey



#if EDITOR_VERSION >= 4200h
  proc gaining_focus()
    generic_message('_GAINING_FOCUS_')
  end gaining_focus

  proc losing_focus()
    if logging_LOSING_FOCUS_
      generic_message('_LOSING_FOCUS_')
    endif
    if delay_close
      WhenPurged()
    endif
  end losing_focus

  proc nonedit_gaining_focus()
    generic_message('_NONEDIT_GAINING_FOCUS_')
  end nonedit_gaining_focus

  proc nonedit_losing_focus()
    generic_message('_NONEDIT_LOSING_FOCUS_')
  end nonedit_losing_focus
#endif



proc enable_and_disable_events()
  integer h_ok            = TRUE
  string  item_name  [30] = ''
  string  item_value  [1] = ''

  // These events are always hooked, because they are needed for this macro
  // to function, but their logging is still enabled/disabled according to
  // the configuration:
  //    _IDLE_
  //    _LOSING_FOCUS_        (for TSE GUI v4.2 upwards)
  //    _ON_ABANDON_EDITOR_
  //    _ON_EXIT_CALLED_

  UnHook(on_editor_startup)
  if logging_ON_EDITOR_STARTUP_
    h_ok = h_ok and Hook(_ON_EDITOR_STARTUP_, on_editor_startup)
  endif
  UnHook(on_exit_called)
  h_ok = h_ok and Hook(_ON_EXIT_CALLED_, on_exit_called)
  UnHook(on_abandon_editor)
  h_ok = h_ok and Hook(_ON_ABANDON_EDITOR_, on_abandon_editor)
  UnHook(list_startup)
  if logging_LIST_STARTUP_
    h_ok = h_ok and Hook(_LIST_STARTUP_, list_startup)
  endif
  UnHook(list_cleanup)
  if logging_LIST_CLEANUP_
    h_ok = h_ok and Hook(_LIST_CLEANUP_, list_cleanup)
  endif
  UnHook(pickfile_startup)
  if logging_PICKFILE_STARTUP_
    h_ok = h_ok and Hook(_PICKFILE_STARTUP_, pickfile_startup)
  endif
  UnHook(pickfile_cleanup)
  if logging_PICKFILE_CLEANUP_
    h_ok = h_ok and Hook(_PICKFILE_CLEANUP_, pickfile_cleanup)
  endif
  UnHook(prompt_startup)
  if logging_PROMPT_STARTUP_
    h_ok = h_ok and Hook(_PROMPT_STARTUP_, prompt_startup)
  endif
  UnHook(prompt_cleanup)
  if logging_PROMPT_CLEANUP_
    h_ok = h_ok and Hook(_PROMPT_CLEANUP_, prompt_cleanup)
  endif
#if INTERNAL_VERSION >= INTERNAL_VERSION_V4_41_44
  UnHook(popmenu_startup)
  if logging_POPMENU_STARTUP_
    h_ok = h_ok and Hook(_POPMENU_STARTUP_, popmenu_startup)
  endif
  UnHook(popmenu_cleanup)
  if logging_POPMENU_CLEANUP_
    h_ok = h_ok and Hook(_POPMENU_CLEANUP_, popmenu_cleanup)
  endif
#endif

  UnHook(on_changing_files)
  if logging_ON_CHANGING_FILES_
    h_ok = h_ok and Hook(_ON_CHANGING_FILES_, on_changing_files)
  endif
  UnHook(on_first_edit)
  if logging_ON_FIRST_EDIT_
    h_ok = h_ok and Hook(_ON_FIRST_EDIT_, on_first_edit)
  endif
  UnHook(on_file_load)
  if logging_ON_FILE_LOAD_
    h_ok = h_ok and Hook(_ON_FILE_LOAD_, on_file_load)
  endif
  UnHook(on_file_save)
  if logging_ON_FILE_SAVE_
    h_ok = h_ok and Hook(_ON_FILE_SAVE_, on_file_save)
  endif
  UnHook(after_file_save)
  if logging_AFTER_FILE_SAVE_
    h_ok = h_ok and Hook(_AFTER_FILE_SAVE_, after_file_save)
  endif
    UnHook(on_file_quit)
  if logging_ON_FILE_QUIT_
    h_ok = h_ok and Hook(_ON_FILE_QUIT_, on_file_quit)
  endif

  UnHook(idle)
  h_ok = h_ok and Hook(_IDLE_, idle)
  UnHook(nonedit_idle)
  if logging_NONEDIT_IDLE_
    h_ok = h_ok and Hook(_NONEDIT_IDLE_, nonedit_idle)
  endif

  UnHook(before_update_display)
  if logging_BEFORE_UPDATE_DISPLAY_
    h_ok = h_ok and Hook(_BEFORE_UPDATE_DISPLAY_, before_update_display)
  endif
  UnHook(after_update_display)
  if logging_AFTER_UPDATE_DISPLAY_
    h_ok = h_ok and Hook(_AFTER_UPDATE_DISPLAY_, after_update_display)
  endif
  UnHook(after_update_statusline)
  if logging_AFTER_UPDATE_STATUSLINE_
    h_ok = h_ok and Hook(_AFTER_UPDATE_STATUSLINE_, after_update_statusline)
  endif
  UnHook(pre_update_all_windows)
  if logging_PRE_UPDATE_ALL_WINDOWS_
    h_ok = h_ok and Hook(_PRE_UPDATE_ALL_WINDOWS_, pre_update_all_windows)
  endif
    UnHook(post_update_all_windows)
  if logging_POST_UPDATE_ALL_WINDOWS_
    h_ok = h_ok and Hook(_POST_UPDATE_ALL_WINDOWS_, post_update_all_windows)
  endif

  UnHook(before_command)
  if logging_BEFORE_COMMAND_
    h_ok = h_ok and Hook(_BEFORE_COMMAND_, before_command)
  endif
  UnHook(after_command)
  if logging_AFTER_COMMAND_
    h_ok = h_ok and Hook(_AFTER_COMMAND_, after_command)
  endif
  UnHook(before_nonedit_command)
  if logging_BEFORE_NONEDIT_COMMAND_
    h_ok = h_ok and Hook(_BEFORE_NONEDIT_COMMAND_, before_nonedit_command)
  endif
  UnHook(after_nonedit_command)
  if logging_AFTER_NONEDIT_COMMAND_
    h_ok = h_ok and Hook(_AFTER_NONEDIT_COMMAND_, after_nonedit_command)
  endif
  UnHook(on_selfinsert)
  if logging_ON_SELFINSERT_
    h_ok = h_ok and Hook(_ON_SELFINSERT_, on_selfinsert)
  endif
  UnHook(on_delchar)
  if logging_ON_DELCHAR_
    h_ok = h_ok and Hook(_ON_DELCHAR_, on_delchar)
  endif

  UnHook(on_unassigned_key)
  if logging_ON_UNASSIGNED_KEY_
    h_ok = h_ok and Hook(_ON_UNASSIGNED_KEY_, on_unassigned_key)
  endif
  UnHook(on_nonedit_unassigned_key)
  if logging_ON_NONEDIT_UNASSIGNED_KEY_
    h_ok = h_ok and Hook(_ON_NONEDIT_UNASSIGNED_KEY_, on_nonedit_unassigned_key)
  endif
  UnHook(before_getkey)
  if logging_BEFORE_GETKEY_
    h_ok = h_ok and Hook(_BEFORE_GETKEY_, before_getkey)
  endif
  UnHook(after_getkey)
  if logging_AFTER_GETKEY_
    h_ok = h_ok and Hook(_AFTER_GETKEY_, after_getkey)
  endif

#if EDITOR_VERSION >= 4200h
  UnHook(gaining_focus)
  if logging_GAINING_FOCUS_
    h_ok = h_ok and Hook(_GAINING_FOCUS_, gaining_focus)
  endif
  UnHook(losing_focus)
  if logging_LOSING_FOCUS_
    h_ok = h_ok and Hook(_LOSING_FOCUS_, losing_focus)
  endif
  UnHook(nonedit_gaining_focus)
  if logging_NONEDIT_GAINING_FOCUS_
    h_ok = h_ok and Hook(_NONEDIT_GAINING_FOCUS_, nonedit_gaining_focus)
  endif
  UnHook(nonedit_losing_focus)
  if logging_NONEDIT_LOSING_FOCUS_
    h_ok = h_ok and Hook(_NONEDIT_LOSING_FOCUS_, nonedit_losing_focus)
  endif
#endif

  if not h_ok
    Warn(MACRO_NAME, ' abort: Maximum number of hooks reached.', Chr(13),
         'Unsetting all hooks to make'; MACRO_NAME; 'restartable.')
    ok = FALSE
    LoadProfileSection(SECTION_NAME)
    while GetNextProfileItem(item_name, item_value)
      if item_name[1] == '_'
        RemoveProfileItem(SECTION_NAME, item_name)
      endif
    endwhile
  endif
end enable_and_disable_events


proc WhenPurged()
  generic_message('WhenPurged ' + MACRO_NAME)
  restore_window_title()
  if log_handle <> -1
    close_log_file()
  endif
end WhenPurged

proc WhenLoaded()
  // Initialize semi-constants
  MACRO_NAME   = SplitPath(CurrMacroFilename(), _NAME_)
  SECTION_NAME = MACRO_NAME + ':Config'

  #ifdef LINUX
    PushLocation() // Work-around for bug in Linux TSE v4.41.46.
    FlushProfile()
    PopLocation()
  #else
    FlushProfile()
  #endif

  init_config_variables()

  dir_helpline_menu_addr = get_helpline_address(DIR_HELPLINE_REF_STR)
  write_helpline(dir_helpline_menu_addr, 'Log directory is to be shown here')

  if log_to_file
    if  ok
    and log_dir <> ''
      open_log_file()
    endif
  endif
  if ok
    generic_message('WhenLoaded ' + MACRO_NAME)
    enable_and_disable_events()
  endif
  if not ok
    PurgeMacro(MACRO_NAME)
  endif
end WhenLoaded

proc toggle_event_logging(string event_name)
  write_profile_int(event_name, not get_profile_int(event_name))
end toggle_event_logging

integer proc get_event_logging_menu_flags(string event_name)
  integer flags = _MF_ENABLED_|_MF_DONT_CLOSE_
  if get_profile_int(event_name)
    flags = flags|_MF_CHECKED_
  else
    flags = flags|_MF_UNCHECKED_
  endif
  return(flags)
end get_event_logging_menu_flags

string proc get_event_list_for_group(string event_group_name)
  string event_group_list [MAXSTRINGLEN] = ''
  case event_group_name
    when 'startup_cleanup'
      event_group_list = STARTUP_CLEANUP_EVENT_GROUP
    when 'file'
      event_group_list = FILE_EVENT_GROUP
    when 'idle'
      event_group_list = IDLE_EVENT_GROUP
    when 'display'
      event_group_list = DISPLAY_EVENT_GROUP
    when 'command'
      event_group_list = COMMAND_EVENT_GROUP
    when 'key'
      event_group_list = KEY_EVENT_GROUP
#if EDITOR_VERSION >= 4200h
    when 'focus'
      event_group_list = FOCUS_EVENT_GROUP
#endif
    otherwise
      event_group_list = ''
  endcase
  return(event_group_list)
end get_event_list_for_group

integer proc count_enabled_event_logs(string event_group_name)
  integer enabled_events                  = 0
  string  event_group_list [MAXSTRINGLEN] = ''
  string  event_name                 [30] = ''
  integer i                               = 0
  event_group_list = get_event_list_for_group(event_group_name)
  for i = 1 to NumTokens(event_group_list, ' ')
    event_name     = GetToken(event_group_list, ' ', i)
    enabled_events = enabled_events + get_profile_int(event_name)
  endfor
  return(enabled_events)
end count_enabled_event_logs

string proc summarize_enabled_event_logs(string p_event_group_name)
  integer enabled_events                  = 0
  integer events_in_group                 = 0
  string  event_group_list [MAXSTRINGLEN] = ''
  string  event_group_names          [51] = 'startup_cleanup file idle display command key focus'
  integer i                               = 0
  string  l_event_group_name         [15] = ''
  string  summary                     [5] = ''
  integer total_enabled_events            = 0
  integer total_events                    = 0
  if p_event_group_name <> 'all'
    event_group_names = p_event_group_name
  endif
  for i = 1 to NumTokens(event_group_names, ' ')
    l_event_group_name   = GetToken(event_group_names, ' ', i)
    event_group_list     = get_event_list_for_group(l_event_group_name)
    events_in_group      = NumTokens(event_group_list, ' ')
    enabled_events       = count_enabled_event_logs(l_event_group_name)
    total_events         = total_events         + events_in_group
    total_enabled_events = total_enabled_events + enabled_events
  endfor
  summary = Format(total_enabled_events, '/', total_events)
  if Length(summary) > 3
    summary = Format(summary:5)
  endif
  return(summary)
end summarize_enabled_event_logs

menu startup_cleanup_events_menu()
  title = 'Log which startup/cleanup events?'
  history
  CheckBoxes
  '_ON_EDITOR_STARTUP_',
    toggle_event_logging('_ON_EDITOR_STARTUP_'),
    get_event_logging_menu_flags('_ON_EDITOR_STARTUP_'),
    'Toggle the ">" prefix on/off to do/not log the _ON_EDITOR_STARTUP_ event'
  '_ON_EXIT_CALLED_',
    toggle_event_logging('_ON_EXIT_CALLED_'),
    get_event_logging_menu_flags('_ON_EXIT_CALLED_'),
    'Toggle the ">" prefix on/off to do/not log the _ON_EXIT_CALLED_ event'
  '_ON_ABANDON_EDITOR_',
    toggle_event_logging('_ON_ABANDON_EDITOR_'),
    get_event_logging_menu_flags('_ON_ABANDON_EDITOR_'),
    'Toggle the ">" prefix on/off to do/not log the _ON_ABANDON_EDITOR_ event'
  '_LIST_STARTUP_',
    toggle_event_logging('_LIST_STARTUP_'),
    get_event_logging_menu_flags('_LIST_STARTUP_'),
    'Toggle the ">" prefix on/off to do/not log the _LIST_STARTUP_ event'
  '_LIST_CLEANUP_',
    toggle_event_logging('_LIST_CLEANUP_'),
    get_event_logging_menu_flags('_LIST_CLEANUP_'),
    'Toggle the ">" prefix on/off to do/not log the _LIST_CLEANUP_ event'
  '_PICKFILE_STARTUP_',
    toggle_event_logging('_PICKFILE_STARTUP_'),
    get_event_logging_menu_flags('_PICKFILE_STARTUP_'),
    'Toggle the ">" prefix on/off to do/not log the _PICKFILE_STARTUP_ event'
  '_PICKFILE_CLEANUP_',
    toggle_event_logging('_PICKFILE_CLEANUP_'),
    get_event_logging_menu_flags('_PICKFILE_CLEANUP_'),
    'Toggle the ">" prefix on/off to do/not log the _PICKFILE_CLEANUP_ event'
  '_PROMPT_STARTUP_',
    toggle_event_logging('_PROMPT_STARTUP_'),
    get_event_logging_menu_flags('_PROMPT_STARTUP_'),
    'Toggle the ">" prefix on/off to do/not log the _PROMPT_STARTUP_ event'
  '_PROMPT_CLEANUP_',
    toggle_event_logging('_PROMPT_CLEANUP_'),
    get_event_logging_menu_flags('_PROMPT_CLEANUP_'),
    'Toggle the ">" prefix on/off to do/not log the _PROMPT_CLEANUP_ event'
#if INTERNAL_VERSION >= INTERNAL_VERSION_V4_41_44
  '_POPMENU_STARTUP_',
    toggle_event_logging('_POPMENU_STARTUP_'),
    get_event_logging_menu_flags('_POPMENU_STARTUP_'),
    'Toggle the ">" prefix on/off to do/not log the _POPMENU_STARTUP_ event'
  '_POPMENU_CLEANUP_',
    toggle_event_logging('_POPMENU_CLEANUP_'),
    get_event_logging_menu_flags('_POPMENU_CLEANUP_'),
    'Toggle the ">" prefix on/off to do/not log the _POPMENU_CLEANUP_ event'
#endif
end startup_cleanup_events_menu

menu file_events_menu()
  title = 'Log which file events?'
  history
  CheckBoxes
  '_ON_CHANGING_FILES_',
    toggle_event_logging('_ON_CHANGING_FILES_'),
    get_event_logging_menu_flags('_ON_CHANGING_FILES_'),
    'Toggle the ">" prefix on/off to do/not log the _ON_CHANGING_FILES_ event'
  '_ON_FIRST_EDIT_',
    toggle_event_logging('_ON_FIRST_EDIT_'),
    get_event_logging_menu_flags('_ON_FIRST_EDIT_'),
    'Toggle the ">" prefix on/off to do/not log the _ON_FIRST_EDIT_ event'
  '_ON_FILE_LOAD_',
    toggle_event_logging('_ON_FILE_LOAD_'),
    get_event_logging_menu_flags('_ON_FILE_LOAD_'),
    'Toggle the ">" prefix on/off to do/not log the _ON_FILE_LOAD_ event'
  '_ON_FILE_SAVE_',
    toggle_event_logging('_ON_FILE_SAVE_'),
    get_event_logging_menu_flags('_ON_FILE_SAVE_'),
    'Toggle the ">" prefix on/off to do/not log the _ON_FILE_SAVE_ event'
  '_AFTER_FILE_SAVE_',
    toggle_event_logging('_AFTER_FILE_SAVE_'),
    get_event_logging_menu_flags('_AFTER_FILE_SAVE_'),
    'Toggle the ">" prefix on/off to do/not log the _AFTER_FILE_SAVE_ event'
  '_ON_FILE_QUIT_',
    toggle_event_logging('_ON_FILE_QUIT_'),
    get_event_logging_menu_flags('_ON_FILE_QUIT_'),
    'Toggle the ">" prefix on/off to do/not log the _ON_FILE_QUIT_ event'
end file_events_menu

menu idle_events_menu()
  title = 'Log which idle events?'
  history
  CheckBoxes
  '_IDLE_',
    toggle_event_logging('_IDLE_'),
    get_event_logging_menu_flags('_IDLE_'),
    'Toggle the ">" prefix on/off to do/not log the _IDLE_ event'
  '_NONEDIT_IDLE_',
    toggle_event_logging('_NONEDIT_IDLE_'),
    get_event_logging_menu_flags('_NONEDIT_IDLE_'),
    'Toggle the ">" prefix on/off to do/not log the _NONEDIT_IDLE_ event'
end idle_events_menu

menu display_events_menu()
  title = 'Log which display events?'
  history
  CheckBoxes
  '_BEFORE_UPDATE_DISPLAY_',
    toggle_event_logging('_BEFORE_UPDATE_DISPLAY_'),
    get_event_logging_menu_flags('_BEFORE_UPDATE_DISPLAY_'),
    'Toggle the ">" prefix on/off to do/not log the _BEFORE_UPDATE_DISPLAY_ event'
  '_AFTER_UPDATE_DISPLAY_',
    toggle_event_logging('_AFTER_UPDATE_DISPLAY_'),
    get_event_logging_menu_flags('_AFTER_UPDATE_DISPLAY_'),
    'Toggle the ">" prefix on/off to do/not log the _AFTER_UPDATE_DISPLAY_ event'
  '_AFTER_UPDATE_STATUSLINE_',
    toggle_event_logging('_AFTER_UPDATE_STATUSLINE_'),
    get_event_logging_menu_flags('_AFTER_UPDATE_STATUSLINE_'),
    'Toggle the ">" prefix on/off to do/not log the _AFTER_UPDATE_STATUSLINE_ event'
  '_PRE_UPDATE_ALL_WINDOWS_',
    toggle_event_logging('_PRE_UPDATE_ALL_WINDOWS_'),
    get_event_logging_menu_flags('_PRE_UPDATE_ALL_WINDOWS_'),
    'Toggle the ">" prefix on/off to do/not log the _PRE_UPDATE_ALL_WINDOWS_ event'
  '_POST_UPDATE_ALL_WINDOWS_',
    toggle_event_logging('_POST_UPDATE_ALL_WINDOWS_'),
    get_event_logging_menu_flags('_POST_UPDATE_ALL_WINDOWS_'),
    'Toggle the ">" prefix on/off to do/not log the _POST_UPDATE_ALL_WINDOWS_ event'
end display_events_menu

menu command_events_menu()
  title = 'Log which command events?'
  history
  CheckBoxes
  '_BEFORE_COMMAND_',
    toggle_event_logging('_BEFORE_COMMAND_'),
    get_event_logging_menu_flags('_BEFORE_COMMAND_'),
    'Toggle the ">" prefix on/off to do/not log the _BEFORE_COMMAND_ event'
  '_AFTER_COMMAND_',
    toggle_event_logging('_AFTER_COMMAND_'),
    get_event_logging_menu_flags('_AFTER_COMMAND_'),
    'Toggle the ">" prefix on/off to do/not log the _AFTER_COMMAND_ event'
  '_BEFORE_NONEDIT_COMMAND_',
    toggle_event_logging('_BEFORE_NONEDIT_COMMAND_'),
    get_event_logging_menu_flags('_BEFORE_NONEDIT_COMMAND_'),
    'Toggle the ">" prefix on/off to do/not log the _BEFORE_NONEDIT_COMMAND_ event'
  '_AFTER_NONEDIT_COMMAND_',
    toggle_event_logging('_AFTER_NONEDIT_COMMAND_'),
    get_event_logging_menu_flags('_AFTER_NONEDIT_COMMAND_'),
    'Toggle the ">" prefix on/off to do/not log the _AFTER_NONEDIT_COMMAND_ event'
  '_ON_SELFINSERT_',
    toggle_event_logging('_ON_SELFINSERT_'),
    get_event_logging_menu_flags('_ON_SELFINSERT_'),
    'Toggle the ">" prefix on/off to do/not log the _ON_SELFINSERT_ event'
  '_ON_DELCHAR_',
    toggle_event_logging('_ON_DELCHAR_'),
    get_event_logging_menu_flags('_ON_DELCHAR_'),
    'Toggle the ">" prefix on/off to do/not log the _ON_DELCHAR_ event'
end command_events_menu

menu key_events_menu()
  title = 'Log which key events?'
  history
  CheckBoxes
  '_ON_UNASSIGNED_KEY_',
    toggle_event_logging('_ON_UNASSIGNED_KEY_'),
    get_event_logging_menu_flags('_ON_UNASSIGNED_KEY_'),
    'Toggle the ">" prefix on/off to do/not log the _ON_UNASSIGNED_KEY_ event'
  '_ON_NONEDIT_UNASSIGNED_KEY_',
    toggle_event_logging('_ON_NONEDIT_UNASSIGNED_KEY_'),
    get_event_logging_menu_flags('_ON_NONEDIT_UNASSIGNED_KEY_'),
    'Toggle the ">" prefix on/off to do/not log the _ON_NONEDIT_UNASSIGNED_KEY_ event'
  '_BEFORE_GETKEY_',
    toggle_event_logging('_BEFORE_GETKEY_'),
    get_event_logging_menu_flags('_BEFORE_GETKEY_'),
    'Toggle the ">" prefix on/off to do/not log the _BEFORE_GETKEY_ event'
  '_AFTER_GETKEY_',
    toggle_event_logging('_AFTER_GETKEY_'),
    get_event_logging_menu_flags('_AFTER_GETKEY_'),
    'Toggle the ">" prefix on/off to do/not log the _AFTER_GETKEY_ event'
end key_events_menu

#if EDITOR_VERSION >= 4200h

menu focus_events_menu()
  title = 'Log which focus events?'
  history
  CheckBoxes
  '_GAINING_FOCUS_',
    toggle_event_logging('_GAINING_FOCUS_'),
    get_event_logging_menu_flags('_GAINING_FOCUS_'),
    'Toggle the ">" prefix on/off to do/not log the _GAINING_FOCUS_ event'
  '_LOSING_FOCUS_',
    toggle_event_logging('_LOSING_FOCUS_'),
    get_event_logging_menu_flags('_LOSING_FOCUS_'),
    'Toggle the ">" prefix on/off to do/not log the _LOSING_FOCUS_ event'
  '_NONEDIT_GAINING_FOCUS_',
    toggle_event_logging('_NONEDIT_GAINING_FOCUS_'),
    get_event_logging_menu_flags('_NONEDIT_GAINING_FOCUS_'),
    'Toggle the ">" prefix on/off to do/not log the _NONEDIT_GAINING_FOCUS_ event'
  '_NONEDIT_LOSING_FOCUS_',
    toggle_event_logging('_NONEDIT_LOSING_FOCUS_'),
    get_event_logging_menu_flags('_NONEDIT_LOSING_FOCUS_'),
    'Toggle the ">" prefix on/off to do/not log the _NONEDIT_LOSING_FOCUS_ event'
end focus_events_menu

#endif

menu main_events_menu()
  title = 'Log which events?'
  history
  '&Escape',,_MF_ENABLED_|_MF_CLOSE_AFTER_
  '&Startup/cleanup events ...'
    [summarize_enabled_event_logs('startup_cleanup'):SUMMARY_SIZE],
    startup_cleanup_events_menu(),
    _MF_ENABLED_|_MF_DONT_CLOSE_
  '&File events ...'
    [summarize_enabled_event_logs('file'):3],
    file_events_menu(),
    _MF_ENABLED_|_MF_DONT_CLOSE_
  '&Idle events ...'
    [summarize_enabled_event_logs('idle'):3],
    idle_events_menu(),
    _MF_ENABLED_|_MF_DONT_CLOSE_
  '&Display events ...'
    [summarize_enabled_event_logs('display'):3],
    display_events_menu(),
    _MF_ENABLED_|_MF_DONT_CLOSE_
  '&Command events ...'
    [summarize_enabled_event_logs('command'):3],
    command_events_menu(),
    _MF_ENABLED_|_MF_DONT_CLOSE_
  '&Key events ...'
    [summarize_enabled_event_logs('key'):3],
    key_events_menu(),
    _MF_ENABLED_|_MF_DONT_CLOSE_
#if EDITOR_VERSION >= 4200h
  'F&ocus events ...'
    [summarize_enabled_event_logs('focus'):3],
    focus_events_menu(),
    _MF_ENABLED_|_MF_DONT_CLOSE_
#endif
end main_events_menu

proc toggle_log_type(string log_type)
  write_profile_int(log_type, not get_profile_int(log_type))
  stop_main_menu_loop = FALSE
  PushKey(<t>)
  PushKey(<Escape>)
  PushKey(<Escape>)
end toggle_log_type

integer proc get_log_type_menu_flags(string log_type)
  integer flags = _MF_ENABLED_|_MF_DONT_CLOSE_
  if get_profile_int(log_type)
    flags = flags|_MF_CHECKED_
  else
    flags = flags|_MF_UNCHECKED_
  endif
  return(flags)
end get_log_type_menu_flags

menu log_types_menu()
  title = 'Which type of logging?'
  history
  CheckBoxes
  '&Escape',,_MF_ENABLED_|_MF_CLOSE_AFTER_
  'To a &file',
    toggle_log_type('log_to_file'),
    get_log_type_menu_flags('log_to_file'),
    'Toggle the ">" prefix on/off to do/not log to a file'
  'To the window &title bar',
    toggle_log_type('log_to_title'),
    get_log_type_menu_flags('log_to_title'),
    'Toggle the ">" prefix on/off to do/not log to the window title bar'
  'To the TSE &message line',
    toggle_log_type('log_to_message'),
    get_log_type_menu_flags('log_to_message'),
    'Toggle the ">" prefix on/off to do/not log to the TSE message line'
end log_types_menu

string proc summarize_log_types()
  string summary [18] = ''
  if log_to_file
    summary = 'file'
  endif
  if log_to_title
    summary = summary + iif(Length(summary), '+', '') + 'title'
  endif
  if log_to_message
    summary = summary + iif(Length(summary), '+', '') + 'message'
  endif
  summary = Format(summary:18)
  return(summary)
end summarize_log_types

string proc show_log_dir()
  return(log_dir)
end show_log_dir

proc change_log_dir()
  string answer [MAXSTRINGLEN] = log_dir
  if Ask('Log dir:', answer, GetFreeHistory(MACRO_NAME + ':log_dir'))
    answer = unquote(Trim(answer))
    #ifdef LINUX
      if answer <> SLASH
        answer = RemoveTrailingSlash(answer)
      endif
    #else
      answer = RemoveTrailingSlash(answer)
    #endif
    if FileExists(answer) & _DIRECTORY_
      if answer <> log_dir
        if log_handle == -1
          log_dir = answer
          set_log_dir()
        else
          close_log_file()
          log_dir = answer
          set_log_dir()
          open_log_file()
        endif
      endif
    else
      if YesNo('Create directory "' + answer + '"?') == 1
        if mk_dir(answer)
          if log_handle == -1
            log_dir = answer
            set_log_dir()
          else
            close_log_file()
            log_dir = answer
            set_log_dir()
            open_log_file()
          endif
        endif
      endif
    endif
  endif
end change_log_dir

integer proc get_log_dir_menu_flags()
  integer flags = _MF_ENABLED_|_MF_DONT_CLOSE_
  if not log_to_file
    flags = flags|_MF_SKIP_|_MF_GRAYED_
  endif
  return(flags)
end get_log_dir_menu_flags

integer proc get_main_events_menu_flags()
  integer flags = _MF_ENABLED_|_MF_DONT_CLOSE_
  if not (log_to_file or log_to_title or log_to_message)
    flags = flags|_MF_SKIP_|_MF_GRAYED_
  endif
  return(flags)
end get_main_events_menu_flags

string proc get_visual_pause()
  return(Format(visual_pause: 2))
end get_visual_pause

integer proc set_visual_pause()
  string new_visual_pause [2] = ''
  if ReadNumeric(new_visual_pause)
    if Val(new_visual_pause) > 0
      visual_pause = Val(new_visual_pause)
      write_profile_int('visual_pause', visual_pause)
    else
      if Query(Beep)
        Alarm()
      endif
      Warn('Visual pause must be greater than zero.')
    endif
  endif
  return(visual_pause)
end set_visual_pause

integer proc get_visual_pause_flags()
  integer flags = _MF_ENABLED_|_MF_DONT_CLOSE_
  if not (log_to_title or log_to_message)
    flags = flags|_MF_SKIP_|_MF_GRAYED_
  endif
  return(flags)
end get_visual_pause_flags

menu main_menu()
  title = 'EventLogger'
  history
  '&Escape',,_MF_ENABLED_|_MF_CLOSE_AFTER_
  '&Help ...',
    show_help(),
    _MF_ENABLED_|_MF_CLOSE_AFTER_,
    'Read the documentation'
  'Log &type ...'
    [summarize_log_types():18],
    log_types_menu(),
    _MF_ENABLED_|_MF_DONT_CLOSE_,
    'Log to file, title, message line, any combination thereof, or none.'
  'Log which &events ...'
    [summarize_enabled_event_logs('all'):5],
    main_events_menu(),
    get_main_events_menu_flags(),
    'Which events do you want to log?'
  'Log &dir'
    [show_log_dir():18],
    change_log_dir(),
    get_log_dir_menu_flags(),
    'MQFP9YVKCV3IDOBE0WZ84MT9JDQVO29KBNNQXUJBQLF623W7JCRIYAIJU3JOF4VIXZYP339NJRNFWSJC4O875I6XFQ3I08FS64I5HBDHA65T87UU45NA9EJK3FTX1WIDL2BMFCOXGWLT2DT2K8G2ZKL8R7BLI92NHOVPN2KQEO84KU4EXSSALHAATEB35JMP7ACVXO9RSQFF5I5EDQ0XCMRW5C9DLC6FDF3DSYS12RFOGENIE9VPLV85FTNUDLM'
  'Visual &pause (18ths/s)'
    [get_visual_pause():2],
    set_visual_pause(),
    get_visual_pause_flags(),
    'How long to pause in 1/18ths of a second between visual log messages?'
end main_menu

proc Main()
  integer old_HookState            = 0
  integer total_enabled_event_logs = 0

  // Disable hooks during configuration.
  old_HookState = SetHookState(FALSE)

  if ok
    repeat
      stop_main_menu_loop = TRUE
      write_helpline(dir_helpline_menu_addr, log_dir)
      main_menu()
    until not ok
       or stop_main_menu_loop
  endif
  if ok
    enable_and_disable_events()
  endif
  if ok
    total_enabled_event_logs = count_enabled_event_logs('startup_cleanup')
                             + count_enabled_event_logs('file')
                             + count_enabled_event_logs('idle')
                             + count_enabled_event_logs('display')
                             + count_enabled_event_logs('command')
                             + count_enabled_event_logs('key')
#if EDITOR_VERSION >= 4200h
    total_enabled_event_logs = total_enabled_event_logs
                             + count_enabled_event_logs('focus')
#endif
  endif
  if ok
    if  total_enabled_event_logs
    and Trim(summarize_log_types()) <> ''
      if not isAutoLoaded()
        AddAutoLoadMacro(MACRO_NAME)
      endif
    else
      if isAutoLoaded()
        DelAutoLoadMacro(MACRO_NAME)
      endif
      PurgeMacro(MACRO_NAME)
    endif
  endif
  if not ok
    PurgeMacro(MACRO_NAME)
  endif

  SetHookState(old_HookState)
end Main

