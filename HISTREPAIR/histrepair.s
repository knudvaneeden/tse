/*
  Macro          HistRepair
  Author         Carlo Hogeveen
  Website        eCarlo.nl/tse
  Compatibility  Windows TSE v4.50 RC 19 ( 9 Mar 2024) upwards
                 Linux   TSE v4.50 RC 15 (14 Dec 2023) upwards
  Version        v1.1   12 Sep 2026


  This macro repairs and optimizes TSE's history lists,
  as well as lets you browse and manually delete history lists.

  To not interfere with running macros and other TSE sessions,
  it does its actual work only when and if TSE closes as the only TSE session.

  Changes are only made after the following succeeds in TSE's load directory:
  - Backups of relevant states of tsehist.dat and the history buffer were made.
  - A description of the changes was added to file tsehist_HistRepair.log.

  My experience is, that history optimizations will be rare, but will occur and
  recur, and that, except for the first time, repairs will be extremely rare.


  INSTALLATION & USE

    Copy this file to TSE's "mac" directory and compile it there, for example
    by opening it there in TSE and applying the Macro -> Compile menu.

    To fix errors and do optimizations pick one of the following methods:

    - The typically best method is to make HistRepair an autoloaded macro.
      While this is also a safety guard against future history errors,
      its main purpose will probably be keeping the history lists optimized.
      How to install:
      - Add "HistRepair" to TSE's Macro AutoLoad List.
      - Execute HistRepair to set how frequently it should check for errors.
        The default "every time" means at most once every TSE session.
        Once repairs and optimizations are checked for, you can set it to a
        lower frequency to catch and do future errors and optimizations.
        HistRepair's check adds about 1 second to TSE's closure time.
        You can make this 0 most of the time by lowering the check frequency.
      - Optionally change the "Check for errors if N <= ...".
        If your check frequency is too long, then this option will still catch
        errors when the history lists are getting full.
      If autoloaded, next TSE sessions will automatically pop up a link
      to the log file if errors were fixed or optimizations were made.

    - Alternatively you can check for errors and optimizations once:
      - Make your TSE session the only one.
      - Execute "HistRepair".
      - Set "Check once" to "On".
      - Close the TSE session.
      - In a new TSE session you will either have to:
        - Manually check file tsehist_HistRepair.log in TSE's root directory.
        - Reload HistRepair so it can provide a link if errors or optimizations
          were found.

    Done!


  BACKGROUND INFO: RECURRING OPTIMIZATION OF UNUSED HISTORY LISTS

    Since TSE v4.50.23, which fixed TSE-errors in maintaining history lists,
    the most frequently recurring HistRepair-report is the optimization
    of unused history lists.

    Some macros create empty history lists without adding values to them,
    and HistRepair deletes those history lists.
    This kept happening in a pointless loop.

    Some TSE macros did this too: I submitted updates for those macros
    to Semware, and in later TSE versions this no longer happens in those of
    their macros that I use.

    Please report it if HistRepair still keeps deleting empty history lists
    in the latest TSE version: This can be fixed.


  BACKGROUND INFO: ONLY 127 MACRO-CREATED history LISTS CAN EXIST

    In practice this limit was not reported as a problem by anyone but me.
    Ideally the reason is that the average user never reached that limit.
    Unfortunately, in TSE versions up to and including TSE v4.50.22
    errors occurred silently when that limit was approached or reached.

    TSE deletes old history list values when their limits in TSE's
    configuration menu are exceeded.
    This can (not a certainty!) eventually create an empty history list if all
    its values were deleted for being too old.
    TSE does not automatically delete empty history lists.
    HistRepair will.

    You can configure HistRepair to check for errors and optimizations
    when there are too few free macro-created history lists.
    That might free up macro-created history lists, or not.
    At some point there might be nothing to free up any more.

    You can examine the "fullness" of the number of macro-created history lists
    by executing HistRepair: The main menu shows "fullness" numbers.

    You can manually view history lists and values by executing HistRepair
    and selecting "View history lists ...".
    In this view you can select and delete a macro-created history list.
    This will implicitly set the "Check for errors once" setting to "On"
    in order to free up high numbers for macro-created history lists.

    Please report it if all the measures above still result in almost 127
    macro-created history lists, i.e. almost no free history lists.
    Both can be checked in the HistRepair menu.

    Theoretically I think it is doable to rewrite TSE's history commands to
    have unlimited macro-created history lists.
    In practice there is currently no sign that there will ever be a need for
    this.


  BACKGROUND INFO: VARIOUS DETAILS

    Across TSE sessions TSE remembers its history lists and their values
    in its tsehist.dat file in TSE's load directory.
    During TSE sessions TSE maintains its history lists and their values
    in a dedicated TSE buffer.
    TSE overwrites the tsehist.dat file every time TSE closes.
    ( See the "technical background info" section further on for a desciption
      of its data formatting. )

    To read HistRepair's log file it helps to know the following.

    All history lists are identified by a number from 1 through 255.
    There are two types of history lists:
    - A TSE built-in history list.
      It has a fixed number between 128 and 255, most of which are unused.
      It does not have a name, but it has a built-in synonym for its number.
      Examples of such synonyms are _EDIT_HISTORY_ and _FIND_HISTORY_.
      See TSE's Help's AddHistoryStr() topic for more synonyms.
    - A macro-created history list.
      It is assigned a number from 1 through 127 by macros that use
      the GetFreeHistory(<name>) statement.
      GetFreeHistory() either returns an existing number for an existing name,
      or a free number in the range 1 through 127 for a non-yet-existing name,
      or 0 if there are no free numbers or an error occurred.
      In the last case GetFreeHistory() also returns a suppressable warning
      since TSE v4.50.23.

    In practice there are 3 known problems with macro-created history lists:
    - There are only 127 numbers available, so when heavily used they run out.
    - GetFreeHistory() had several bugs, the last of which will be fixed
      in TSE v4.50.23.
    - Macros do not check if GetFreeHistory() succeeds.   :-(
      All Semware's and my macros have this flaw.
      As of TSE v4.50.23 GetFreeHistory() itself shows a suppressable warning
      if an error occurs.

    Because the bugs typically occurred when the number of macro-created
    history lists approached its maximum of 127, there is reason to hope
    that the average TSE user will not have encountered them.

    HistRepair knowns the format rules that TSE expects for tsehist.dat
    and its history buffer.
    Typically errors do not occur for TSE's built-in history lists.
    Typically errors do occur for macro-created history lists,
    and might necessitate deleting one or some macro-created history lists.
    There is one worst-case error that necessitates deleting all macro-created
    history lists.

    When checking for errors HistRepair also checks for optimizations.


  BACKGROUND INFO: REPAIR AND OPTIMIZATION DETAILS

    The extension repairs and optimizes TSE's history lists
    when and if ALL of these conditions apply:
    - The extension is (auto)loaded.
    - TSE is closing.
    - There are no other TSE sessions.
    Otherwise it just does nothing.

    Possible repairs:
    - Delete empty file lines. (Not the same as empty history names or values.)
    - Delete all macro-created history lists if their names also occur in their
      values, because this means all their other values are also corrupted.
      This worst-case error only occurred during testing.
    - Delete illegal history list 0.
    - Delete macro-created history lists with a number >= 128.
    - Delete any names for TSE's built-in history lists.
      They have synonyms for their numbers and should not have names.
    - Delete mixed-up lists, a.k.a. lists with multiple names.
      This relatively common error was caused by a bug in GetFreeHistory()
      that was fixed in TSE v4.50.22 (28 Mar 2026).
    - Delete macro-created history lists with an empty name.
    - Delete macro-created history lists with no name.

    Possible optimizations:
    - Delete empty macro-created history lists, i.e. ones with no values.
    - Sort the history-name lines descending on their history number.
      ( TSE's GetFreeHistory() statement depends on this sort order to function
        correctly. As of TSE v4.50.23 TSE avoids related errors by doing the
        sort itself. )
    - Renumber macro-created history list numbers to be as low as possible
      while preserving their order.
      ( E.g. the numbering "10, 9, 7, 5" becomes "4, 3, 2, 1".
        This frees up high macro-created history list numbers.
        This is not to avoid an error, but to support TSE's internal convention
        that higher macro-created history list numbers indicate a newer list. )

    Exception:
      - In TSE <= v4.50.22 (28 Mar 2026) TSE's debugger created empty history
        lists named "Debug:...".
      - The "Search -> Function List" can create empty history lists with names
        "UI:CompressViewFind" and "UI:CompressViewFindOptions".
      It would be annoying to have HistRepair repair and report them after
      every use of the debugger or the function list.
      Therefore these two exceptions are not optimized.


  TODO
    MUST
    SHOULD
    COULD
    - Make the warning optional that history lists were repaired/optimized.
    - Make history values deletable too.
    WONT


  HISTORY

  v1.1       12 Sep 2026
  - Major bug fix for HistRepair in Windows TSE:
    Windows 11's September 2026 update deleted the wmic command.
    This broke HistRepair, which called wmic and processed its output.
    HistRepair now calls Windows functions directly instead.

  v1          1 May 2026
  - The first non-beta release.
  - Optimized the layout of the history lists view a bit.
  - Made tiny documentation improvements.
  - Added a description of tsehist.dat's file and buffer format in the
    "technical background info" section.

  v0.1.0.15  16 Apr 2026
  - In the view of history lists: Added each history list's number of values.

  v0.1.0.14  15 Apr 2026
  - Added a repair for macro-created history lists with a history number > 127.

  v0.1.0.13   3 Apr 2026
  - Manually deleting a history with HistRepair now triggers a one-time
    error/optimization check.
  - Several minor optimizations.

  v0.1.0.12   2 Apr 2026
  - Never gray the frequency option.
  - Improved the documentation.

  v0.1.0.11   1 Apr 2026
  - Add 3 display menu options with stats for macro-created history lists.
  - Added a configurable free-high-history_numbers threshold,
    below which to start an error check.
  - Added a message to turning the "check once" menu option On
    to make the menu-option more user-friendly.
  - Added a help option to the menu.

  v0.1.0.10  30 Mar 2026
  - Added a menu option to manually view history lists and values,
    and to delete a history list.
  - Now makes the worst-case repair, namely deleting all macro-created history
    lists, if the worst-case error is found, which is basically totally corrupt
    history lists.
  - Now makes a "backup before <del>" of tsehist.dat
    just before the first manually deletion of a list in a day.
  - Added more exceptions to not deleting empty history lists, namely
    "UI:CompressViewFind" and "UI:CompressViewFindOptions".
  - Now aborts if the signature of tsehist.dat is incorrect.

  v0.1.0.9   23 Mar 2026 (2)
  - Removed test code.
  - Changed an internal configuration name.

  v0.1.0.8   23 Mar 2026
  - Improved the documentation for the upcoming non-beta release.
  - Optimized bits of code.

  v0.1.0.7   22 Mar 2026
  - Fixed that sometimes an unnecessary sort was done.
  - Added the exception to not delete the 3 empty history lists that TSE's
    debugger creates, because a HistRepair report after every debugging session
    gets annoying.

  v0.1.0.6   21 Mar 2026 (2)
    Added a pop-up in the next TSE session if errors were repaired,
    with an offer to view the log file.

  v0.1.0.5   21 Mar 2026
    Added a clarifying message after "Check once" is turned on.

  v0.1.0.4   20 Mar 2026
  - Added configuration options to either check for errors once,
    or to check for errors once every <period>.
  - Now reports sorting history names as a repair.
  - Now only backward compatible to TSE v4.50 RC 15 (14 Dec 2023)
    to be able to use its new CompareLines() sort-flags.
  - Minor bugs fixed.

  v0.1.0.3   16 Mar 2026 (2)
    Fixed the bug that it always reported repairing an empty linbe.

  v0.1.0.2   16 Mar 2026
    Rewrote HistRepair's outer logic to make it much more efficient,
    especially by using TSE's "new" NumHistoryNames() statement.

  v0.1       17 Jul 2023
    Made the tool compatible with TSE's Console and Linux variants.
    Made the tool backwards compatible with TSE v4.0 upwards.

  v0.0.0.3   15 Jul 2023
    It now maintains a cumulative "tsehist_HistRepair.log" history of errors.

    It now distinguishes the filenames of tsehist.dat's backup and new version
    by adding a "_bak" and "_new" filename part respectively.

  v0.0.0.2   13 Jul 2023
    Done:
      Extra error checks.
      More condensed error reporting.
      It now also works as an extension:
        It is ready enough, that I added it to my Macro AutoLoad List.
      It now updates tsehist.dat after two user confirmations:
        When it starts and when TSE closes.
      It creates its own backups of tsehist.dat, so what could go wrong?

  v0.0.0.1   10 Jul 2023
    Initial "in development" release.
    The purpose of this release is to pre-inform Semware,
    who are working on other sides of the same problem.

*/





/*
  T E C H N I C A L   B A C K G R O U N D   I N F O


  TSEHIST.DAT FORMAT

  Between TSE sessions TSE's history lists are stored in file "tsehist.dat"
  in TSE's binary format "-2" in TSE's load directory.

  During TSE sessions TSE's history lists are stored in TSE buffer 6.

  TSE supports BUILT-IN history lists and MACRO-CREATED history lists.

  Built-in history lists have a number in the range 128 to 255.
  Those numbers have synonyms: See TSE's AddHistoryStr's topic and this
  macro's "Datadef HISTORY_SYNONYMS".
  As of 28 April 2026 there are 15 built-in history lists.

  Macro-created history lists have a number in the range 1 to 127,
  and a name that is determined by the macro that created it.
  By convention a typical name has format <macro-name>:<prompt-name>.
  By using macro-name as a prefix macros avoid using the same history name.
  Macros use GetFreeHistory(<name>) to either get its existing history number
  or to get a free history number.
  By convention newer macro-created history lists get a higher number.

  tsehist.dat's file and buffer contain 3 consecutive blocks of lines:
  - Block 1 / the meta-data-block consists of just line 1.
    In the file tsehist.dat:
    - Byte 1's value is the number of lines in block 2.
    - The rest of the line contains the signature string "®TSE History¯",
      which TSE uses to check if it has the correct file.
    In buffer 6:
    - The line is undefined.
      Initially it will be empty, but there is an internal TSE function that
      uses it as temporary storage.
      Do not be alarmed when line 1 seemingly contains history during a TSE
      session.
      During a TSE session the number of lines in block 2 can be retrieved with
      the macro function NumHistoryNames() as of TSE v4.50 rc 6 (18 Jul 2023).
  - In block 2 / the names-block each line contains the number (as a
    byte-value) and name (as a string) of a macro-created history list.
    Before TSE v4.50.23 block 2 is imperfectly sorted descending on number.
    TSE v4.50.23 upwards maintains that sort order.
    To find a new free number TSE will first try if the top number + 1 is free,
    and otherwise will top-down try to find a free number.
    This macro (HistRepair) optimizes block 2:
    - It deletes empty macro-created history lists.
    - It sorts block 2 for older TSE versions.
    - It renumbers the numbers of the names (and their related values) to
      remove "gaps" in the numbers and free up high numbers.
  - In block 3 / the values-block each line contains the number (as a
    byte-value) and value (as a string) of a history list.
    Block 3 is not sorted on history number, value, or type (built-in or
    macro-created).
    New and reused values are placed at the top of block 3, implicitly pushing
    not-reused values to the bottom, where eventually they will be deleted
    based on TSE's configured history limits.

*/





// Start of compatibility restrictions and mitigations.


#ifndef INTERNAL_VERSION
  #define INTERNAL_VERSION 0
#endif

#ifdef LINUX
  #if INTERNAL_VERSION < 12377
    Error: This macro requires at least LINUX TSE v4.50rc15 (14 Dec 2023).
  #endif
#else
  #if INTERNAL_VERSION < 12385
    Error: This macro requires at least Windows TSE v4.50rc19 (9 Mar 2024).
  #endif
#endif




// End of compatibility restrictions and mitigations.





// Constants and semi-constants

#define BACKUP_TYPE_1                1
#define BACKUP_TYPE_2                2
#define CCF_FLAGS                    _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
#define DOS_ASYNC_CALL_FLAGS         _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_|_RUN_DETACHED_|_DONT_WAIT_
#define DOS_SYNC_CALL_FLAGS          _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_
string  HISTORY_SIGNATURE     [13] = '®TSE History¯'
integer LOAD_TIME                  = 0
string  LOG_DETAIL_INDENTATION [2] = '  '
string  LOG_FQN     [MAXSTRINGLEN] = ''
string  MACRO_NAME  [MAXSTRINGLEN] = ''
#define SPACE                        32
integer SYNONYMS_ID                = 0
string  TSEHIST_FQN [MAXSTRINGLEN] = ''
#define TSE_HIST_ID                  6


Datadef HISTORY_SYNONYMS
  '128 _EDIT_HISTORY_'
  '136 _NEWNAME_HISTORY_'
  '137 _EXECMACRO_HISTORY_'
  '138 _LOADMACRO_HISTORY_'
  '139 _KEYMACRO_HISTORY_'
  '144 _GOTOLINE_HISTORY_'
  '145 _GOTOCOLUMN_HISTORY_'
  '146 _REPEATCMD_HISTORY_'
  '152 _DOS_HISTORY_'
  '160 _FINDOPTIONS_HISTORY_'
  '161 _REPLACEOPTIONS_HISTORY_'
  '168 _FIND_HISTORY_'
  '169 _REPLACE_HISTORY_'
  '176 _FILLBLOCK_HISTORY_'
  '184 _HELP_SEARCH_HISTORY_'
end HISTORY_SYNONYMS


// Global variables

integer cfg_frequency_part_length           = 15
integer cfg_free_hist_threshold             = 10

integer g_list_action                       = FALSE
integer g_ok                                = TRUE
string  g_repair_start_date_time       [20] = ''
string  g_repair_start_yyyymmdd_hhmmss [15] = ''
integer g_stop_history_lists                = TRUE


proc to_beep_or_not_to_beep()
  if Query(Beep)
    Alarm()
  endif
end to_beep_or_not_to_beep


proc profile_error(string section_name,
                   string item_name,
                   string item_value)
  to_beep_or_not_to_beep()
  MsgBox(MACRO_NAME,
         Format('ERROR:'                                      , Chr(13),
                '  Could not write item  "', item_name   , '"', Chr(13),
                '  with value            "', item_value  , '"', Chr(13),
                '  to section            "', section_name, '"', Chr(13),
                '  of configuration file "tse.ini".'))
end profile_error


integer proc write_profile_str(string section_name,
                               string item_name,
                               string item_value)
  integer ok = WriteProfileStr(section_name,
                               item_name,
                               item_value)
  if not ok
    profile_error(section_name, item_name, item_value)
  endif

  return(ok)
end write_profile_str


integer proc write_profile_int(string  section_name,
                               string  item_name,
                               integer item_value)
  integer ok = WriteProfileInt(section_name, item_name, item_value)

  if not ok
    profile_error(section_name, item_name, Str(item_value))
  endif

  return(ok)
end write_profile_int


string proc get_date_time_str()
  integer old_TimeFormat = Set(TimeFormat, 1)
  string  result    [20] = ''

  result = GetDateStr() + ' ' + GetTimeStr()

  Set(TimeFormat, old_TimeFormat)
  return(result)
end get_date_time_str


string proc get_yyyymmdd_hhmmss()
  integer old_DateFormat = Set(DateFormat, 6)
  integer old_TimeFormat = Set(TimeFormat, 3)
  string  result    [18] = ''

  result = GetDateStr() + GetTimeStr()
  result =   result[ 1 ..  4]
           + result[ 6 ..  7]
           + result[ 9 .. 10]
           + '_'
           + result[11 .. 12]
           + result[14 .. 15]
           + result[17 .. 18]

  Set(DateFormat, old_DateFormat)
  Set(TimeFormat, old_TimeFormat)
  return(result)
end get_yyyymmdd_hhmmss


#ifdef LINUX

  integer proc num_tse_sessions()
    integer result                  = 0
    string  tse_name [MAXSTRINGLEN] = SplitPath(LoadDir(TRUE), _NAME_|_EXT_)

    PushLocation()
    EmptyBuffer(Query(CaptureId))

    if Capture('ps -e', _STDOUT_|_STDERR_)
      BegFile()
      repeat
        if (GetToken(GetText(1, MAXSTRINGLEN), ' ', 4) in 'e', tse_name)
          result = result + 1
        endif
      until not Down()
    else
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      MsgBox(MACRO_NAME, 'Program error: Capture("ps -e") failed.')
    endif

    PopLocation()
    return(result)
  end num_tse_sessions

#else

  #ifndef INTERNAL_VERSION
    #define INTERNAL_VERSION 0
  #endif

  #if INTERNAL_VERSION < 12385
    Error: This macro part requires at least Windows TSE v4.50rc19 (9 Mar 2024).
  #endif


  //  Constants and semi-constants.

  #define ERROR_BAD_LENGTH      24
  #define ERROR_FILE_NOT_FOUND   2
  #define ERROR_INVALID_HANDLE   6
  #define ERROR_NO_MORE_FILES   18

  #define INVALID_HANDLE_VALUE  -1
  #define MAX_PATH              260                   // Characters.
  #define LPPE_SIZE             MAX_PATH     + 4 * 9  // In ansi 32-bit context.
  #define LPPE_SIZE_W           MAX_PATH * 2 + 4 * 9  // In wide 32-bit context.

  // dwFlags
  #define TH32CS_SNAPHEAPLIST 0x00000001
  #define TH32CS_SNAPPROCESS  0x00000002
  #define TH32CS_SNAPTHREAD   0x00000004
  #define TH32CS_SNAPMODULE   0x00000008
  #define TH32CS_SNAPALL      (TH32CS_SNAPHEAPLIST | TH32CS_SNAPPROCESS | TH32CS_SNAPTHREAD | TH32CS_SNAPMODULE)
  #define TH32CS_INHERIT      0x80000000


  //  Global variables

  integer memory_blocks_id = 0
  integer lppe_address     = 0


  dll "<Kernel32.dll>"
    /*
      https://learn.microsoft.com/en-us/windows/win32/api/tlhelp32/nf-tlhelp32-createtoolhelp32snapshot

      HANDLE CreateToolhelp32Snapshot(
        [in] DWORD dwFlags,
        [in] DWORD th32ProcessID
        );
    */
    integer proc CreateToolhelp32Snapshot(
      integer dwFlags,
      integer th32ProcessID
      )

    /*
      https://learn.microsoft.com/en-us/windows/win32/api/tlhelp32/nf-tlhelp32-process32firstw

      BOOL Process32FirstW(
        [in]      HANDLE            hSnapshot,
        [in, out] LPPROCESSENTRY32W lppe
      );
    */
    integer proc Process32First(
      integer hSnapshot,
      integer lppe
      )

    /*
      https://learn.microsoft.com/en-us/windows/win32/api/tlhelp32/nf-tlhelp32-process32nextw

      BOOL Process32NextW(
        [in]  HANDLE            hSnapshot,
        [out] LPPROCESSENTRY32W lppe
        );
    */
    integer proc Process32Next(
      integer hSnapshot,
      integer lppe
      )

    //  https://learn.microsoft.com/en-us/windows/win32/api/errhandlingapi/nf-errhandlingapi-getlasterror
    integer proc GetLastError()

    /*
      https://learn.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle

      BOOL CloseHandle(
        [in] HANDLE hObject
        );
    */
    integer proc CloseHandle(
      integer hObject
      )
  end


  /*
    create_memory_block()'s functionality is based on the assumption, that all
    memory blocks are created at the start of the calling macro and deleted at
    the purging of the calling macro.
    The calling macro has to define a global variable, say memory_blocks_id,
    its definition initializing it to 0.
    The calling macro has to pass this memory_blocks_id to the blocks_id
    parameter.
    Each call to create_memory_block() crates a new memory block with the
    requested size, and returns the created memory block's address.
    The size cannot be larger than TSE's MAXLINELEN.
    When the calling macro is purged, its WhenPurged() proc needs
    to AbandonFile(memory_blocks_id), which deletes all created memory blocks.
  */
  integer proc create_memory_block(var integer blocks_id,
                                       integer block_size,
                                   var integer block_address)
    string s [MAXSTRINGLEN] = Format('': MAXSTRINGLEN: Chr(0))

    if block_size > MAXLINELEN
      MsgBox(SplitPath(CurrMacroFilename(), _NAME_),
             Format('create_memory_block abort: Block size > MAXLINELEN.'))
      return(FALSE)
    endif

    if blocks_id == 0
      PushLocation()
      blocks_id = CreateTempBuffer()
      ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_) +
                         ':MemoryBlocks',
                         _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
      PopLocation()
    endif

    PushLocation()
    GotoBufferId(blocks_id)
    EndFile()
    AddLine()
    BegLine()
    do block_size / MAXSTRINGLEN times
      InsertText(s)
    enddo
    if CurrLineLen() < block_size
      InsertText(s[1: block_size - CurrLineLen()])
    endif

    block_address = CurrLinePtr()
    PopLocation()
    return(TRUE)
  end create_memory_block


  string proc get_null_terminated_memory_string(integer address,
                                                integer max_string_length)
    integer c                = 0
    integer i                = 0
    string  s [MAXSTRINGLEN] = ''

    for i = 0 to max_string_length - 1
      c = PeekByte(AdjPtr(address, i))
      if c
        s = s + Chr(c)
      else
        break
      endif
    endfor

    return(s)
  end get_null_terminated_memory_string


  integer proc num_tse_sessions()
    string  process_name        [MAXSTRINGLEN] = ''
    integer result                             = 0
    integer snapshot_handle                    = 0
    string  tse_exe_name_regexp [MAXSTRINGLEN] = ''

    tse_exe_name_regexp = '^{g32.exe}|{e32.exe}'
                          + iif((Lower(SplitPath(LoadDir(TRUE), _NAME_|_EXT_))
                                 in 'g32.exe', 'e32.exe'),
                                '',
                                '|{' + SplitPath(LoadDir(TRUE), _NAME_|_EXT_) + '}')
                          + '$'
    snapshot_handle = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    if snapshot_handle <> INVALID_HANDLE_VALUE
      if create_memory_block(memory_blocks_id, LPPE_SIZE, lppe_address)
        PokeLong(lppe_address, LPPE_SIZE)
        if Process32First(snapshot_handle, lppe_address)
            repeat
            process_name = get_null_terminated_memory_string(lppe_address + 36,
                                                             260)
            if StrFind(tse_exe_name_regexp, process_name, 'ix')
              result = result + 1
            endif
          until not Process32Next(snapshot_handle, lppe_address)
          if GetLastError() <> ERROR_NO_MORE_FILES
            Warn('Process32First() error: GetLastError() returns'; GetLastError())
          endif
        else
          if GetLastError() <> ERROR_NO_MORE_FILES
            Warn('Process32First() error: GetLastError() returns'; GetLastError())
          endif
        endif
        CloseHandle(snapshot_handle)
      else
        Warn('Error: create_memory_block() returned FALSE.')
      endif
      AbandonFile(memory_blocks_id)
    else
      Warn('Error: CreateToolhelp32Snapshot() returned an invalid handle.')
    endif
    AbandonFile(memory_blocks_id)

    return(result)
  end num_tse_sessions

#endif


string proc get_history_signature()
  string  result [MAXSTRINGLEN] = ''
  integer handle                = -1
  integer first_line_length     = 0

  handle = fOpen(TSEHIST_FQN, _OPEN_READONLY_|_OPEN_COMPATIBILITY_)
  if handle <> -1
    if fRead(handle, result, MAXSTRINGLEN) >= 2
      first_line_length = Asc(result[1]) + Asc(result[2]) * 256
      result            = result[3: first_line_length]
      result            = result[2: MAXSTRINGLEN]
    else
      result = ''
    endif
    fClose(handle)
  endif
  return(result)
end get_history_signature


proc show_help()
  string  full_macro_source_name [MAXSTRINGLEN] =  SplitPath(CurrMacroFilename(),
                                                   _DRIVE_|_PATH_|_NAME_) + '.s'
  string  help_file_name         [MAXSTRINGLEN] = '*** ' + MACRO_NAME +
                                                  ' Help ***'
  integer hlp_id                                = GetBufferId(help_file_name)
  integer org_id                                = GetBufferId()
  integer tmp_id                                = 0
  if hlp_id
    GotoBufferId(hlp_id)
    UpdateDisplay()
  else
    tmp_id = CreateTempBuffer()
    if LoadBuffer(full_macro_source_name)
      // Separate characters, otherwise the old version of my SynCase macro gets confused.
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
        ChangeCurrFilename(help_file_name, CCF_FLAGS)
        BufferType(_NORMAL_)
        FileChanged(FALSE)
        BrowseMode(TRUE)
        UpdateDisplay()
      else
        GotoBufferId(org_id)
        Warn(MACRO_NAME; 'file'; QuotePath(full_macro_source_name);
             'has no multi-line comment block.')
      endif
    else
      GotoBufferId(org_id)
      Warn(MACRO_NAME; 'file'; QuotePath(full_macro_source_name);
           'not found.')
    endif
    AbandonFile(tmp_id)
  endif
end show_help


//  Checks if all current block lines are sorted descending, case-sensitively.
integer proc is_line_block_sorted(integer sort_flags)
  integer result = TRUE

  if isBlockInCurrFile() == _LINE_
    PushLocation()
    GotoBlockBegin()
    while result
    and   Down()
    and   CurrLine() <= Query(BlockEndLine)
      if CompareLines(CurrLine() - 1,
                      CurrLine()    ,
                      sort_flags    ) == 1
        result = FALSE
      endif
    endwhile
    PopLocation()
  endif
  return(result)
end is_line_block_sorted


string proc ff_compressed_date_time_str()
  integer old_DateFormat = Set(DateFormat, 6)
  integer old_TimeFormat = Set(TimeFormat, 3)
  string  result    [18] = ''
  result = FFDateStr() + FFTimeStr()
  result =   result[ 1 ..  4]
           + result[ 6 ..  7]
           + result[ 9 .. 10]
           + '_'
           + result[11 .. 12]
           + result[14 .. 15]
           + result[17 .. 18]
  Set(DateFormat, old_DateFormat)
  Set(TimeFormat, old_TimeFormat)
  return(result)
end ff_compressed_date_time_str


integer proc backup_tsehist_file(integer backup_type)
  integer do_backup                         = FALSE
  integer ok                                = FALSE
  string  tsehist_backup_fqn [MAXSTRINGLEN] = SplitPath(TSEHIST_FQN, _DRIVE_|_PATH_|_NAME_) + '_'

  if FindThisFile(tsehist_fqn)
    case backup_type
      when BACKUP_TYPE_1
        tsehist_backup_fqn = tsehist_backup_fqn
                             + ff_compressed_date_time_str()
                             + '_file_before_repairs'
                             + SplitPath(TSEHIST_FQN, _EXT_)
        do_backup = TRUE
      when BACKUP_TYPE_2
        //  Here "first" means "only the first time in a day".
        tsehist_backup_fqn = tsehist_backup_fqn
                             + SubStr(get_yyyymmdd_hhmmss(), 1, 8)
                             + 'file_before_first_del'
                             + SplitPath(TSEHIST_FQN, _EXT_)
        if FileExists(tsehist_backup_fqn)
          ok = TRUE
        else
          do_backup = TRUE
        endif
    endcase

    if do_backup
      if  backup_type == BACKUP_TYPE_1
      and FileExists(tsehist_backup_fqn)
        //  This can typically happen for BACKUP_TYPE_1 after an already
        //  backed up tsehist.dat is manually restored for test purposes.
        ok = TRUE
      else
        ok = CopyFile(TSEHIST_FQN, tsehist_backup_fqn)
        if not ok
          to_beep_or_not_to_beep()
          MsgBox(MACRO_NAME,
                 Format('Failed to backup', Chr(13),
                        '  ', QuotePath(TSEHIST_FQN),  Chr(13),
                        'to', Chr(13),
                        '  ', QuotePath(tsehist_backup_fqn)))
        endif
      endif
    endif
  endif

  return(ok)
end backup_tsehist_file


integer proc backup_hist_buffer(    integer hist_id,
                                    integer num_history_names,
                                var string  save_hist_fqn)
  integer ok = FALSE

  if FileExists(TSEHIST_FQN)
    save_hist_fqn = SplitPath(TSEHIST_FQN, _DRIVE_|_PATH_|_NAME_)
                    + '_'
                    + iif(hist_id == TSE_HIST_ID,
                          g_repair_start_yyyymmdd_hhmmss,
                          get_yyyymmdd_hhmmss())
                    + '_buffer_'
                    + iif(hist_id == TSE_HIST_ID, 'broken', 'repaired')
                    + SplitPath(TSEHIST_FQN, _EXT_)
    PushLocation()
    GotoBufferId(hist_id)
    BegFile()
    InsertText(Chr(num_history_names) + HISTORY_SIGNATURE, _OVERWRITE_)
    BinaryMode(-2)
    ok = SaveAs(save_hist_fqn, _DONT_PROMPT_|_OVERWRITE_)
    PopLocation()
  endif

  return(ok)
end backup_hist_buffer


integer proc write_log_file(integer log_id,
                            integer num_history_names_old,
                            integer num_history_names_new)
  integer handle   = -1
  integer result   = FALSE
  integer num_size = 0

  num_size = Length(Str(Max(num_history_names_old, num_history_names_new)))

  PushLocation()

  GotoBufferId(log_id)

  BegFile()
  InsertLine()
  AddLine(Format('History list repairs & optimizations started  at';
                 g_repair_start_date_time, '.'))
  AddLine(Format('There were'; num_history_names_old: num_size;
                 'macro-created history lists.'))

  EndFile()
  AddLine(Format('There are '; num_history_names_new: num_size;
                 'macro-created history lists.'))
  AddLine(Format('History list repairs & optimizations finished at';
                 get_date_time_str(), '.'))
  AddLine()

  if FileExists(LOG_FQN)
    handle = fOpen(LOG_FQN, _OPEN_READWRITE_)
  else
    handle = fCreate(LOG_FQN)
  endif

  if handle <> -1
    result = fWriteFile(handle, _APPEND_)
    if result
      result = fClose(handle)
    else
      fClose(handle)
    endif
  endif

  PopLocation()
  return(result)
end write_log_file


string proc get_history_list_synonym(integer history_list_number)
  string synonym [30] = ''

  PushLocation()
  GotoBufferId(SYNONYMS_ID)
  if lFind('^' + Chr(history_list_number), 'gx')
    synonym = GetText(2, MAXSTRINGLEN)
  endif
  PopLocation()
  return(synonym)
end get_history_list_synonym


proc check_tsehist()
  integer deletions                     = 0
  integer empty_name_lines              = 0
  integer empty_value_lines             = 0
  integer exception_for_history_name    = FALSE
  integer hist_num                      = 0
  integer hist_num_highest_new          = 0
  integer hist_num_highest_old          = 0
  integer hist_num_new                  = 0
  integer hist_num_old                  = 0
  integer hist_num_shift                = 0
  integer log_id                        = 0
  string  names_for_list [MAXSTRINGLEN] = ''
  string  new_hist_fqn   [MAXSTRINGLEN] = ''
  integer new_hist_id                   = 0
  integer num_history_names_new         = 0
  integer num_history_names_old         = 0
  integer num_hist_0_lines              = 0
  integer num_names_for_list            = 0
  integer num_values_for_list           = 0
  string  search_options           [11] = ''
  string  search_string  [MAXSTRINGLEN] = ''
  integer worst_case_error              = FALSE

  PushLocation()
  PushBlock()

  log_id      = CreateTempBuffer()
  ChangeCurrFilename(MACRO_NAME + ':Actions'         , CCF_FLAGS)
  new_hist_id = CreateTempBuffer()
  ChangeCurrFilename(MACRO_NAME + ':CopyOfTseHistDat', CCF_FLAGS)
  GotoBufferId(TSE_HIST_ID)
  MarkLine(1, NumLines())
  GotoBufferId(new_hist_id)
  CopyBlock()

  FileChanged(FALSE)

  num_history_names_old = NumHistoryNames()
  num_history_names_new = num_history_names_old

  if num_history_names_old
    MarkLine(2, num_history_names_old + 1) // Mark the name lines.
  else
    UnMarkBlock()
  endif

  //  Repair error: Empty file lines.
  //  ( This is not the same as empty history list values. )
  //  Here just count them, later remove them.
  BegFile()
  while lFind('^$', 'x+')
    if isCursorInBlock()
      num_history_names_new = num_history_names_new - 1
      empty_name_lines      = empty_name_lines + 1
    else
      empty_value_lines     = empty_value_lines + 1
    endif
  endwhile
  if empty_value_lines
    AddLine(Format(LOG_DETAIL_INDENTATION, 'Deleted'; empty_value_lines;
                   'empty lines from history list values.'),
            log_id)
  endif
  if empty_name_lines
    AddLine(Format(LOG_DETAIL_INDENTATION, 'Deleted'; empty_name_lines;
                   'empty lines from history list names. They counted as names.'),
            log_id)
  endif

  //  Repair error: History list names also occur as one of their values.
  //    This is the worst case error, because it is accompanied by an
  //    undetectable error, namely that of values massively occurring in wrong
  //    lists.
  //    Values in wrong lists cannot be repaired automatically.
  //    The best solution I can come up with is to delete all macro-created
  //    history lists, and to advise the user to restore an old-enough version
  //    of tsehist.dat.
  if NumHistoryNames()
    GotoBlockBegin()
    BegLine()
    repeat
      search_string = GetText(1, MAXSTRINGLEN)
      PushLocation()
      GotoLine(NumHistoryNames() + 1)
      EndLine()
      if lFind(search_string, '^$')
        PopLocation()
        worst_case_error = TRUE
        AddLine(Format(LOG_DETAIL_INDENTATION,
                       'Worst-case error: History list'; CurrChar(1), "'s",
                       ' name "', GetText(2, MAXSTRINGLEN),
                       '" also occurs as one of its list values.'),
                log_id)
      else
        PopLocation()
      endif
    until not Down()
       or isCurrLineInBlock() <> _LINE_
    if worst_case_error
      BegFile()
      Down()
      repeat
        if isCursorInBlock()
          KillToEol()
        elseif CurrChar() in 0 .. 127
          KillToEol()
        endif
      until not Down()
      num_history_names_new = 0
      AddLine(Format(LOG_DETAIL_INDENTATION,
                     'Deleted all macro-created history lists to repair the worst-case error.'),
              log_id)
      AddLine(Format(LOG_DETAIL_INDENTATION,
                     'Maybe you can restore an old-enough, not-yet-corrupted tsehist.dat.'),
              log_id)
    endif
  endif

  //  Repair error: History list 0.
  search_options = 'gx'
  while lFind('^\d000', search_options)
    if isCursorInBlock()
      AddLine(Format(LOG_DETAIL_INDENTATION,
                     'Deleted illegal history list 0. It had name "';
                     GetText(2, MAXSTRINGLEN), '".'),
              log_id)
      num_history_names_new = num_history_names_new - 1
    else
      num_hist_0_lines = num_hist_0_lines + 1
    endif
    KillToEol() // Later delete as empty line.
    search_options = 'x+'
  endwhile
  if num_hist_0_lines
    AddLine(Format(LOG_DETAIL_INDENTATION,
                   'For illegal history list 0: Deleted its';
                   num_hist_0_lines; 'values.'),
            log_id)
  endif

  //  Repair error: A macro-created history name with a number >= 128.
  search_options = 'glx'
  while lFind('^[\d128-\d255]', search_options)
    AddLine(Format(LOG_DETAIL_INDENTATION,
                   'Deleted history name "', GetText(2, MAXSTRINGLEN),
                   '" because it had illegal number';
                   CurrChar(1), '.'),
            log_id)
    num_history_names_new = num_history_names_new - 1
    KillToEol() // Later delete as empty line.
    search_options = 'lx+'
  endwhile

  //  Repair error: A name for a built-in history list.
  while lFind('^[\d128-\d255]', 'glx')
    num_history_names_new = num_history_names_new - 1
    AddLine(Format(LOG_DETAIL_INDENTATION, 'For built-in history list';
                   CurrChar(); 'with synonym "',
                   get_history_list_synonym(CurrChar()),
                   '" deleted its illegal name "',
                   GetText(2, MAXSTRINGLEN), '".'),
            log_id)
    KillToEol() // Later delete as empty line.
  endwhile

  //  Repair error: History lists with multiple names.
  if num_history_names_old
    for hist_num = 1 to 127
      names_for_list      = ''
      num_names_for_list  = 0
      num_values_for_list = 0
      search_options      = 'glx'
      while lFind(Format('^\d', hist_num:3:'0'), search_options)
        num_names_for_list = num_names_for_list + 1
        if names_for_list <> ''
          names_for_list = names_for_list + ' and '
        endif
        names_for_list = names_for_list + '"' + GetText(2, MAXSTRINGLEN) + '"'
        search_options = 'lx+'
      endwhile
      if num_names_for_list >= 2
        search_options = 'gx'
        while lFind(Format('^\d', hist_num:3:'0'), search_options)
          if isCursorInBlock()
            num_history_names_new = num_history_names_new - 1
          else
            num_values_for_list = num_values_for_list + 1
          endif
          KillToEol() // Later delete as empty line.
          search_options = 'x+'
        endwhile
        AddLine(Format(LOG_DETAIL_INDENTATION, 'Deleted'; num_names_for_list;
                       'history lists which illegally shared number';
                       hist_num, ', named'; names_for_list, ', and with';
                       num_values_for_list; 'values.'),
                log_id)
      endif
    endfor
  endif

  //  Repair error: Named history lists with an empty name.
  if num_history_names_old
    for hist_num = 1 to 127
      if lFind(Format('^\d', hist_num:3:'0', ' *$'), 'glx')
        names_for_list        = GetText(2, MAXSTRINGLEN)
        num_history_names_new = num_history_names_new - 1
        KillToEol() // Later delete as empty line.
        GotoLine(num_history_names_old + 2) // Go to first value line.
        BegLine()
        deletions      = 0
        search_options = 'x'
        while lFind(Format('^\d', hist_num:3:'0'), search_options)
          deletions = deletions + 1
          KillToEol() // Later delete as empty line.
          search_options = 'x+'
        endwhile
        AddLine(Format(LOG_DETAIL_INDENTATION,
                       'Deleted history list'; hist_num; 'with illegal name "',
                       names_for_list, '" and'; deletions; 'values.'),
                log_id)
      endif
    endfor
  endif

  //  Repair error: Named history lists with no name.
  //  ( This one is theoretical. I have not seen this occur in the wild. )
  for hist_num = 1 to 127
    GotoLine(num_history_names_old + 2)   // Go to first value line.
    BegLine()
    if      lFind(Format('^\d', hist_num:3:'0'), 'x')
    and not lFind(Format('^\d', hist_num:3:'0'), 'glx')
      deletions = 0
      while lFind(Format('^\d', hist_num:3:'0'), 'gx')
        deletions = deletions + 1
        KillToEol() // Later delete as empty line.
      endwhile
      AddLine(Format(LOG_DETAIL_INDENTATION,
                     'For illegally nameless history list'; hist_num;
                     'deleted its'; deletions; 'values.'),
              log_id)
    endif
  endfor

  //  Repair error: Named history lists with no values.
  if num_history_names_old
    for hist_num = 1 to 127
      GotoLine(num_history_names_old + 2) // Go to first value line.
      BegLine()
      if not lFind(Format('^\d', hist_num:3:'0'), 'x')
        names_for_list = ''
        BegFile()
        while lFind(Format('^\d', hist_num:3:'0'), 'lx+')
          if GetText(2, 19) == 'UI:CompressViewFind'
            exception_for_history_name = TRUE
          else
            exception_for_history_name = FALSE
          endif
          // The debug macro was optimized in TSE > v4.50.22 (28 Mar 2026).
          #if INTERNAL_VERSION <= 12434
            if GetText(2,  6) == 'Debug:'
              exception_for_history_name = TRUE
            endif
          #endif
          if not exception_for_history_name
            num_history_names_new = num_history_names_new - 1
            if names_for_list <> ''
              names_for_list = names_for_list + ' and '
            endif
            names_for_list = names_for_list + '"' + GetText(2, MAXSTRINGLEN) +
                             '"'
            KillToEol() // Later delete as empty line.
          endif
        endwhile
        if names_for_list <> ''
          AddLine(Format(LOG_DETAIL_INDENTATION, 'Deleted empty history list';
                         hist_num; 'with name'; names_for_list, '.'),
                  log_id)
        endif
      endif
    endfor
  endif

  //  Now delete all empty lines except the first line.
  BegFile()
  while lFind('^$', 'x+')   // Skips first line and empty lines.
    KillLine()
    Up()
  endwhile

  //  Repair error: Named history lists not sorted descending on number.
  //  ( It does not matter that any empty lines will be sorted too. )
  //
  //  Note 17 Mar 2026:
  //    Sort() erroneously also changes FileChanged() if there is nothing
  //    to sort and the line block contains more than 4 lines.
  //    Therefore we need to program our own is_line_block_sorted() proc.
  if not is_line_block_sorted(_DESCENDING_)
    Sort(_DESCENDING_)
    AddLine(Format(LOG_DETAIL_INDENTATION,
                   'Sorted the history list names descending on their number, as per TSE default.'),
            log_id)
  endif

  //  Repair error: Renumber not-consecutively numbered named history lists.
  //  ( By doing this future named history lists keep getting a high number to
  //    reflect their newness.
  //    If we do not do this, then TSE will use the holes in the numbers if
  //    high numbers are used up, making the names-order no longer age-based.
  //    Having an aged-based names-list helps with its maintenance. )
  for hist_num_new = 1 to 126
    if  not lFind(Format('^\d' , hist_num_new    : 3: '0'           ), 'glx')
    and     lFind(Format('^[\d', hist_num_new + 1: 3: '0', '-\d127]'),'bglx')
      hist_num_old   = CurrChar()
      hist_num_shift = hist_num_old - hist_num_new
      BegFile()
      lFind('^.', 'x+')   // Skips first line and empty lines.
      hist_num_highest_old = CurrChar()
      BegFile()
      while Down()
        if   CurrLineLen()
        and (CurrChar() in hist_num_old .. 127)
          InsertText(Chr(CurrChar() - hist_num_shift), _OVERWRITE_)
          BegLine()
        endif
      endwhile
      BegFile()
      lFind('^.', 'x+')   // Skips first line and empty lines.
      hist_num_highest_new = CurrChar()
      AddLine(Format(LOG_DETAIL_INDENTATION,
                     iif(hist_num_shift == 1,
                         Format('List '; hist_num_new: 3; 'is  unused.': 17),
                         Format('Lists'; hist_num_new: 3; '-';
                                hist_num_old - 1: 3; 'are unused.'));
                     'Renumbered lists';
                     hist_num_old: 3; '-'; hist_num_highest_old: 3;
                     'to';
                     hist_num_new: 3; '-'; hist_num_highest_new: 3;
                     'to free up high numbers for new history lists.'),
              log_id)
    endif
  endfor

  if  FileChanged()   // If any errors were repaired
  and backup_tsehist_file(BACKUP_TYPE_1)
  and backup_hist_buffer(TSE_HIST_ID, num_history_names_old, new_hist_fqn)
  and backup_hist_buffer(new_hist_id, num_history_names_new, new_hist_fqn)
  and write_log_file(log_id,
                     num_history_names_old,
                     num_history_names_new)
    LoadHistory(new_hist_fqn)
    //  TSE itself will save its now updated history buffer to tsehist.dat.

    write_profile_int(MACRO_NAME + ':History', 'ThereAreRepairsToReport', TRUE)
    if GetProfileInt(MACRO_NAME + ':History','CheckOnce', FALSE)
      write_profile_int(MACRO_NAME + ':History','CheckOnce', FALSE)
    endif
  endif

  PopLocation()
  PopBlock()

  AbandonFile(log_id)
  AbandonFile(new_hist_id)
end check_tsehist


Keydef history_lists_keys
  <Del>       Set(Key, -1)
              g_list_action = <Del>
              PushKey(<Enter>)

  <GreyDel>   Set(Key, -1)
              g_list_action = <Del>
              PushKey(<Enter>)
end history_lists_keys


proc history_lists_cleanup()
  UnHook(history_lists_cleanup)
  Disable(history_lists_keys)
end history_lists_cleanup


proc history_lists_startup()
  UnHook(history_lists_startup)
  Hook(_LIST_CLEANUP_, history_lists_cleanup)
  Enable(history_lists_keys)
  ListFooter('{Enter}-View values  {Del}-Delete history list')
end history_lists_startup


proc view_history_list_values(integer history_number,
                              string  history_name_or_synonym)
  integer values_id = 0

  PushLocation()
  PushBlock()

  values_id = CreateTempBuffer()
  GotoBufferId(TSE_HIST_ID)
  GotoLine(1 + NumHistoryNames())
  BegLine()
  while Down()
    if CurrChar() == history_number
      AddLine(GetText(2, MAXSTRINGLEN), values_id)
    endif
  endwhile

  GotoBufferId(values_id)
  BegFile()
  List(Format('Values of history list';
               history_number,
               '  ',
               StrReplace('   #', history_name_or_synonym, '  ', 'x')),
       LongestLineInBuffer())

  PopBlock()
  PopLocation()
  AbandonFile(values_id)
end view_history_list_values


proc view_history_lists()
  integer history_number                 = 0
  string  history_number_str         [3] = ''
  integer max_count                      = 0
  integer names_id                       = 0
  integer new_count                      = 0
  integer old_MsgLevel                   = Set(MsgLevel, _WARNINGS_ONLY_)
  integer pre_justification              = 0
  integer prev_history_list_number       = 0
  string  synonym         [MAXSTRINGLEN] = ''

  //  The seemingly inefficient code below helps to list any errors
  //  and undocumented built-in history lists.
  PushLocation()
  PushBlock()
  names_id = CreateTempBuffer()
  GotoBufferId(TSE_HIST_ID)
  if NumLines() <= 1
    GotoBufferId(names_id)
  else
    MarkLine(2, NumLines())
    GotoBufferId(names_id)
    CopyBlock()

    if NumLines() > NumHistoryNames()
      MarkColumn(NumHistoryNames() + 1, 2, NumLines(), LongestLineInBuffer())
      KillBlock()

      GotoLine(NumHistoryNames())
      while Down()
        if CurrChar(1) > 0
          history_number_str = Str(CurrChar(1))
          new_count          = GetBufferInt(history_number_str) + 1
          SetBufferInt(history_number_str, new_count)
          if new_count > max_count
            max_count = new_count
          endif
        endif
      endwhile
    endif

    BegFile()
    repeat
      InsertText(Format(' ', CurrChar():3, '  '), _INSERT_)
      DelChar()
      BegLine()
    until not Down()

    if NumLines() > NumHistoryNames()
      //  Sort history values on their history number.
      MarkLine(NumHistoryNames() + 1, NumLines())
      Sort()
      UnMarkBlock()

      //  Remove values with duplicate history numbers.
      GotoLine(NumHistoryNames() + 1)
      prev_history_list_number = Val(GetText(2, 3))
      while Down()
        if Val(GetText(2, 3)) == prev_history_list_number
          KillLine()
          Up()
        else
          prev_history_list_number = Val(GetText(2, 3))
        endif
      endwhile

      //  Remove values for histories 0 to 127.
      GotoLine(NumHistoryNames() + 1)
      repeat
        if (Val(GetText(2, 3)) in 0 .. 127)
          KillLine()
          Up()
        endif
      until not Down()

      if NumLines() > NumHistoryNames()

        //  Add history numbers of built-in history lists that had no values.
        MarkLine(NumHistoryNames() + 1, NumLines())
        for history_number = 128 to 255
          if      get_history_list_synonym(history_number) <> ''
          and not lFind(Format(' ', history_number: 3), '^gl')
            EndFile()
            AddLine(Format(' ', history_number:3))
          endif
        endfor

        //  Sort the built-in history numbers.
        MarkLine(NumHistoryNames() + 1, NumLines())
        Sort()
        UnMarkBlock()

        //  Add their synonyms to the built-in history lists.
        GotoLine(NumHistoryNames() + 1)
        repeat
          GotoPos(7)
          synonym = get_history_list_synonym(Val(GetText(2, 3)))
          InsertText(iif(synonym == '', '<no synonym>', synonym))
        until not Down()

        //  Add header.
        GotoLine(NumHistoryNames() + 1)
        InsertLine(Format('Built-in history lists (',
                          NumLines() - NumHistoryNames(),
                          '):'))
      endif

      //  Add header.
      if NumHistoryNames()
        BegFile()
        InsertLine(Format('Macro-created history lists (',
                          NumHistoryNames(),
                          '):'))
      endif
    endif

    //  Add their number of values to each history list.
    pre_justification = LongestLineInBuffer() + Length(Str(max_count)) + 2
    BegFile()
    repeat
      if CurrChar(1) == SPACE
        EndLine()
        InsertText(Format(Format('(',
                                 GetBufferInt(Trim(GetText(2, 3))),
                                     ')'): pre_justification - CurrLineLen()))
      endif
    until not Down()
  endif

  BegFile()
  repeat
    g_list_action        = FALSE
    g_stop_history_lists = TRUE
    Hook(_LIST_STARTUP_, history_lists_startup)
    if  List('', LongestLineInBuffer() + 1)
    and CurrChar(1)        == SPACE
    and Val(GetText(2, 3)) <> 0
      if g_list_action == <Del>
        case Val(GetText(2, 3))
          when   1 .. 127
            if backup_tsehist_file(BACKUP_TYPE_2)
              DelHistory(Val(GetText(2, 3)))
              KillLine()
              ScrollToCenter()
              write_profile_int(MACRO_NAME + ':History', 'CheckOnce', TRUE)
            endif
          when 128 .. 255
            to_beep_or_not_to_beep()
            MsgBox(MACRO_NAME,
                   Format("You cannot delete one of TSE's built-in history lists.",
                          Chr(13), Chr(13),
                          GetText(2, MAXSTRINGLEN)))
        endcase
      else
        view_history_list_values(Val(GetText(2, 3)), GetText(7, MAXSTRINGLEN))
        g_stop_history_lists = FALSE
      endif
    endif
  until g_stop_history_lists
    and Query(Key) == <Escape>

  PopBlock()
  PopLocation()
  AbandonFile(names_id)
  Set(MsgLevel, old_MsgLevel)
end view_history_lists


string proc create_msg(string msg_template,
                       string msg_tag,
                       string file_ref)
  string result [MAXSTRINGLEN] = ''

  result = StrReplace(msg_tag, msg_template, file_ref)

  if result[MAXSTRINGLEN] <> ''
    result = StrReplace(msg_tag, msg_template, SplitPath(file_ref, _NAME_|_EXT_))
  endif

  return(result)
end create_msg


proc idle_report_repairs()
  integer choice             = 0
  string  msg [MAXSTRINGLEN] = ''

  UnHook(idle_report_repairs)

  msg = create_msg(Format('History list repairs were made!',
                          Chr(13),
                          'They were logged in',
                          Chr(13),
                          '  zzz',
                          Chr(13),
                          'Do you want to view the log?'),
                   'zzz',
                   LOG_FQN)

  choice = MsgBoxEx(MACRO_NAME, msg, '[&Later];[&Yes];[&No]')

  if  choice == 2
  and EditFile(LOG_FQN)
    EndFile()
    if lFind('^$', 'bx+')
      ScrollToTop()
    endif
  endif

  if choice in 2, 3
    write_profile_int(MACRO_NAME + ':History',
                      'ThereAreRepairsToReport',
                      FALSE)
  endif
end idle_report_repairs


proc show_macro_load_error_message(string macro1, string macro2)
  to_beep_or_not_to_beep()
  MsgBox(Format(MACRO_NAME; 'abort'),
         Format('Error in macro load order:',
                Chr(13),
                'Macro "', macro1, '" is loaded after macro "', macro2, '".',
                Chr(13),
                'Therefore macro "', macro1, '" will not run.',
                Chr(13),
                "You can adjust the macro load order in TSE's Macro AutoLoad List menu."))
  Delay(9)
end show_macro_load_error_message


integer proc is_macro_load_order_ok(string macro1, string macro2)
  integer ok     = TRUE
  integer org_id = GetBufferId()

  GotoBufferId(4) // TSE's "Loaded and public macros" buffer.
  PushLocation()

  //  Beware of the triple reverse!
  //    This proc's parameters are ordered in the correct macro load order.
  //    Across macros same hooks are called in reverse load order,
  //    the "Loaded Macros" buffer contains macros in reverse load order,
  //    and below we search for the wrong load order.

  if  lFind('\' + macro1 + '.mac', 'gi$')
  and lFind('\' + macro2 + '.mac', 'i$+')
    ok = FALSE
  endif

  PopLocation()
  GotoBufferId(org_id)
  return(ok)
end is_macro_load_order_ok


proc check_macro_load_order(string macro1, string macro2)
  if not is_macro_load_order_ok(macro1, macro2)
    g_ok = FALSE
    show_macro_load_error_message(macro1, macro2)
    PurgeMacro(MACRO_NAME)
  endif
end check_macro_load_order


proc idle_check_macro_load_order()
  UnHook(idle_check_macro_load_order)
  check_macro_load_order(MACRO_NAME, 'HistMerge')
end idle_check_macro_load_order


string proc get_period()
  string result [5] = ''

  case cfg_frequency_part_length
    when  4
      result = 'year'
    when  6
      result = 'month'
    when  8
      result = 'day'
    when 11
      result = 'hour'
    otherwise
      result = 'time'
  endcase

  return(result)
end get_period


menu set_period_menu()
  '&time' ,, _MF_CLOSE_BEFORE_|_MF_ENABLED_
  '&hour' ,, _MF_CLOSE_BEFORE_|_MF_ENABLED_
  '&day'  ,, _MF_CLOSE_BEFORE_|_MF_ENABLED_
  '&month',, _MF_CLOSE_BEFORE_|_MF_ENABLED_
  '&year' ,, _MF_CLOSE_BEFORE_|_MF_ENABLED_
end set_period_menu


proc set_period()
  set_period_menu()

  case MenuOption()
    when 1
      cfg_frequency_part_length = 15
    when 2
      cfg_frequency_part_length = 11
    when 3
      cfg_frequency_part_length =  8
    when 4
      cfg_frequency_part_length =  6
    when 5
      cfg_frequency_part_length =  4
  endcase

  write_profile_int(MACRO_NAME + ':Config',
                    'FrequencyDateTimePartLength',
                    cfg_frequency_part_length)
end set_period


string proc get_check_once()
  string result [3] = ''

  result = iif(GetProfileInt(MACRO_NAME + ':History', 'CheckOnce', FALSE),
               'On',
               'Off')

  return(result)
end get_check_once


proc toggle_check_once()
  write_profile_int(MACRO_NAME + ':History',
                    'CheckOnce',
                    not GetProfileInt(MACRO_NAME + ':History',
                                      'CheckOnce',
                                      FALSE))
end toggle_check_once


integer proc get_highest_hist_num()
  integer result = 0
  PushLocation()
  GotoBufferId(TSE_HIST_ID)
  BegFile()
  while Down()
    if (CurrChar() in result + 1 .. 127)
      result = CurrChar()
    endif
  endwhile
  PopLocation()
  return(result)
end get_highest_hist_num


integer proc ReadNum3(integer n)
  string s[3] = Str(n)
  return (iif(ReadNumeric(s), Val(s), n))
end ReadNum3


proc set_free_hist_threshold()
  integer old_value = cfg_free_hist_threshold

  cfg_free_hist_threshold = ReadNum3(cfg_free_hist_threshold)

  if (cfg_free_hist_threshold in 1 .. 127)
    write_profile_int(MACRO_NAME + ':Config',
                      'FreeHistThreshold',
                      cfg_free_hist_threshold)
  else
    Message('The entered value'; cfg_free_hist_threshold;
            'was not between 1 and 127.')
    to_beep_or_not_to_beep()
    cfg_free_hist_threshold = old_value
  endif
end set_free_hist_threshold


menu main_menu()
  history

  '&View history lists ...',
    view_history_lists(),
    _MF_CLOSE_ALL_BEFORE_|_MF_ENABLED_,
    'View history lists, their values, and optionally delete a list.'

  '',, _MF_DIVIDE_

  'Check for errors &every'
    [get_period():5],
    set_period(),
    _MF_DONT_CLOSE_|_MF_ENABLED_,
    'Check TSE history lists for errors during TSE closing once every <period>.'

  'Check for errors &once'
    [get_check_once():3],
    toggle_check_once(),
    _MF_DONT_CLOSE_|_MF_ENABLED_,
    'Check TSE history lists for errors when this TSE session closes.'

  'Macro-created histories',, _MF_DIVIDE_

  'Highest history number'
    [get_highest_hist_num():3],,
    _MF_DISABLED_|_MF_DONT_CLOSE_|_MF_GRAYED_,
    'Macro-created histories are identified by a number from 1 to 127.'

  'Free numbers'
    [Str(127 - NumHistoryNames()):3],,
    _MF_DISABLED_|_MF_DONT_CLOSE_|_MF_GRAYED_,
    'TSE has room for 127 macro-created history lists. This shows how many are free.'

  'Free high numbers  (N)'
    [Str(127 - get_highest_hist_num()):3],,
    _MF_DISABLED_|_MF_DONT_CLOSE_|_MF_GRAYED_,
    'Free high numbers can be lees than free numbers because of unused middle numbers.'

  'Check for errors &if N <='
    [Str(cfg_free_hist_threshold):3],
    set_free_hist_threshold(),
    _MF_DONT_CLOSE_,
    'Checking for errors also optimizes for more free high history list numbers.'

  '',, _MF_DIVIDE_

  '&Help ...',
    show_help(),
    _MF_CLOSE_ALL_BEFORE_|_MF_ENABLED_,
    'Help! Hilfe! Au secours! Auxilio! Socorro! Jiu ming a!'
end main_menu


proc do_main_menu()
  string  msg [MAXSTRINGLEN] = ''
  integer new_check_once     = 0
  integer old_check_once     = 0

  old_check_once = GetProfileInt(MACRO_NAME + ':History', 'CheckOnce', FALSE)

  main_menu(MACRO_NAME)

  new_check_once = GetProfileInt(MACRO_NAME + ':History', 'CheckOnce', FALSE)

  if  new_check_once
  and new_check_once <> old_check_once
    msg = create_msg(Format("TSE's history lists will be checked and repaired",
                            Chr(13),
                            '  when this TSE session closes', Chr(13),
                            'and', Chr(13),
                            '  if it is the only TSE session.',
                            Chr(13), Chr(13),
                            'Any repairs will be logged in', Chr(13),
                            '  zzz'),
                     'zzz',
                     LOG_FQN)
    MsgBox(MACRO_NAME, msg)
  endif
end do_main_menu


proc on_abandon_editor()
  g_repair_start_date_time       = get_date_time_str()
  g_repair_start_yyyymmdd_hhmmss = get_yyyymmdd_hhmmss()

  //  Replaced "<>" by "not ==" to avoid a compiler bug in TSE <= v4.50.21.
  if  g_ok
  and FileExists(LoadDir() + 'tsehist.dat')
  and (  GetProfileInt(MACRO_NAME + ':History', 'CheckOnce', FALSE)
      or 127 - get_highest_hist_num() <= cfg_free_hist_threshold
      or not (   SubStr(GetProfileStr(MACRO_NAME + ':History',
                                      'LastChecked',
                                      ''),
                                               1, cfg_frequency_part_length)
              == SubStr(get_yyyymmdd_hhmmss(), 1, cfg_frequency_part_length)))
  and num_tse_sessions() == 1
      check_tsehist()
      write_profile_str(MACRO_NAME + ':History',
                        'LastChecked',
                        get_yyyymmdd_hhmmss())
  endif
end on_abandon_editor


proc WhenPurged()
  AbandonFile(SYNONYMS_ID)
end WhenPurged


proc WhenLoaded()
  string found_history_signature [MAXSTRINGLEN] = ''

  LOAD_TIME                 = GetTime()
  MACRO_NAME                = SplitPath(CurrMacroFilename(), _NAME_)
  TSEHIST_FQN               = LoadDir() + 'tsehist.dat'
  LOG_FQN                   = LoadDir() + 'tsehist_' + MACRO_NAME + '.log'
  cfg_frequency_part_length = GetProfileInt(MACRO_NAME + ':Config',
                                            'FrequencyDateTimePartLength',
                                            15)
  cfg_free_hist_threshold   = GetProfileInt(MACRO_NAME + ':Config',
                                           'FreeHistThreshold',
                                           10)
  PushLocation()

  found_history_signature = get_history_signature()
  if (found_history_signature in HISTORY_SIGNATURE, '')
    PushBlock()
    SYNONYMS_ID = CreateTempBuffer()
    ChangeCurrFilename(MACRO_NAME + ':HistorySynonyms', CCF_FLAGS)
    InsertData(HISTORY_SYNONYMS)
    UnMarkBlock()
    BegFile()
    repeat
      BegLine()
      InsertText(Chr(Val(GetText(1, 3))), _INSERT_)
      DelChar(4)
    until not Down()
    PopBlock()

    Hook(_IDLE_             , idle_check_macro_load_order)
    Hook(_ON_ABANDON_EDITOR_, on_abandon_editor)

    if GetProfileInt(MACRO_NAME + ':History', 'ThereAreRepairsToReport', FALSE)
      Hook(_IDLE_, idle_report_repairs)
    endif
  else
    g_ok = FALSE
    to_beep_or_not_to_beep()
    Warn(Format(MACRO_NAME; 'ERROR:', Chr(13),
                'Cannot check tsehist.dat because it has an unknown history signature:',
                Chr(13),
                '  Expected: "', HISTORY_SIGNATURE      , '"', Chr(13),
                '  Found   : "', found_history_signature, '"', Chr(13),
                TSEHIST_FQN))
  endif

  PopLocation()
end WhenLoaded


proc Main()
  integer load_to_execute_duration = GetTime() - LOAD_TIME

  if load_to_execute_duration < 0
    load_to_execute_duration = 24 * 60 * 60 * 100 + load_to_execute_duration
  endif

  if not is_macro_load_order_ok(MACRO_NAME, 'HistMerge')
    g_ok = FALSE
    show_macro_load_error_message(MACRO_NAME, 'HistMerge')
  endif

  if g_ok
    do_main_menu()
  endif

  if g_ok
    if      load_to_execute_duration < 100
    and not GetProfileInt(MACRO_NAME + ':History', 'CheckOnce', FALSE)
      PurgeMacro(MACRO_NAME)
    endif
  else
    PurgeMacro(MACRO_NAME)
  endif
end Main

