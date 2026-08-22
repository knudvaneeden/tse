/*
  Macro           Git
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE PRo v4.0
  Version         v1.4.4   17 Sep 2022


  This TSE extension integrates some basic git functionality into TSE.

  If the current file is in a git directory, then its git status (the output
  from "git status -s") is shown on the right-hand side of the screen.

  By right-clicking this status or by executing the macro Git you get a menu:

    You can add and commit the current file or its whole working tree.
    You are asked for a mandatory commit message.
    These commits will also succeed if there is nothing to commit.

    You can get a list of commits that is a combination of
    - commits of the current file and
    - commits that have a commit message.
    ( The reason for this combination-list is, that when messageless automatic
      commits are enabled, then manual messaged commits are often not for a
      changed version of the current file, and therefore become commits that
      according to git are not related to the current file. )
    You can select a listed commit to retrieve its version of the current file.

    You can configure the extension to after each save of a file to automatically
    do an action for that specific file.
    Current "after file save" configuration options are:
      Do nothing
      git add
      git add + commit

    About the "git add + commit" option for the "after file save" configuration:
      It only commits the current file, so such commits are per file.
      It only commits files with changed content.
      No commit message is used in order to keep such a commit as small as
      possible.
      An added commit will noticeably slow down saving a file.

  Example git statusses for the current file and some usual meanings:
    None      Current file is not in a git directory.
    "Git ??"  Is in a git directory, but is unversioned (never a "git add").
    "Git A"   Was never committed and just had its first "git add".
    "Git AM"  Had its very first "git add" and since then had changes on disk.
    "Git  M"  Had changes on disk since its last commit and had no "git add".
    "Git M"   Had a "git add" and since then had no changes on disk.
    "Git MM"  Had a "git add" and since then had changes on disk.
    "Git"     Was committed and since then had no changes.

  This is a good resource for git:
    https://git-scm.com


  RQUIREMENTS

  Git must be pre-installed on the computer.

  The "Status" macro (v1.2 upwards) must be pre-installed in TSE.


  INSTALLATION

  Put this file Git.s in TSE's "mac" folder.

  Compile it there, for instance by opening the file in TSE and then applying
  the Macro -> Compile menu.

  Add the macro's name "Git" to the Macro -> AutoLoad List menu.

  Execute the macro "Git" or right-click on its status to configure it.
  - Mandatory configuration:
    - The "Git executable" configuration requires one of these actions:
      - My advice, based on (*), is to leave the value simply "Git",
        and add git.exe's folder to Windows' "Path" environment variable (**).
      - Otherwise you need to change the extension's configuration value
        for its Git executable to git.exe's full path and name, for example
        "C:\Program Files\Git\bin\git.exe" (without quotes).
  - Optional configuration:
    - Configure an automatic "git add" or "git add + commit" after each file
      is saved. Committing will be one commit per file, without a message.
    - Default the git menu is accessable by right-clicking the status or by
      manually executing the "Git" macro with TSE menu "Macro, Execute".
      Additionally you can add "Git" to the Potpourri menu,
      and/or assign it a key in the UI file that your TSE uses.

  (*)
    For small git commands (less than 255 characters) the Git extension can and
    does use a faster and more robust way to execute the command.
    By configuring "git" instead of "C:\Program Files\Git\bin\git.exe" as its
    executable, git commands are likelier to be executed the optimal way.

  (**)
    In the currently latest Windows 10 version you can set the Path environment
    variable through the Windows menu Start -> Settings -> System -> About
    -> Advanced System Settings -> Environment Variables.
    You probably only need to change the Path in the "User variables for ..."
    pane, and not the one in the "System Variables" pane.
    Double-click on "Path", select "New", and add the folder where git.exe
    was installed, possibly "C:\Program Files\Git\bin" (without the quotes).


  KNOWN ERRORS
    Git files on "\\" drives are treated as non-git files.
      This is done because the extension currently cannot handle them as git
      files. Logically that is an error. I currently do not know if this can
      be fixed, nor if it should. It has a very low priority in my view.


  TODO
    MUST
    SHOULD
    COULD
    - If possible, handle git files on "\\" drives.
    - You tell me.
    WONT


  HISTORY

  v1        3 Jun 2021
    Initial version based on a user request on 22 May 2021.
    This version is intended as a minimal viable product, that just shows a git
    status and can do an automatic "git add" after each file save.

  v1.0.1    3 Jun 2021
    Fixed: The backwards compatibility with Windows TSE v4.0 did not work.

  v1.0.2   15 Jun 2021
    Fixed:
      A bug that intermittently made TSE mis a key stroke.
      The fix is not Linux compatible, therefore the extension's claim to Linux
      compatibility is hereby retracted.
    Fixed:
      Show the difference between short statuses "M " and " M" by making the
      extension show "Git M" and "Git  M" respectively.
    Fixed:
      The status refreshes faster after a file save, which is relevant if an
      after-file-save action is configured.
    Fixed:
      Improved the extension's documentation a lot, especially the example git
      statuses, the installation documentation, and the addition of a "known
      errors" section.

  v1.0.3   15 Jun 2021
    Fixed:
      No status was shown for a committed unchanged file. It should be "Git"
      because the file is versioned, without a value because "git status -s"
      returns no status for such a file.

  v1.0.4   19 Jun 2021
    Fixed:
      The extension limited the git commands it used to 255 characters.
      The extension no longer imposes a command length limit.
      Note that TSE itself still limits prompts and filenames to 255 characters,
      and those building blocks cannot create a git command that is too long
      for the operating system to handle.
      Tested: Windows 10's maximum command line length is 8196 characters.
    Optimized:
      Error handling.

  v1.1     20 Jun 2021
    New:
      You can now configure an "After file save: git add + commit" action.

  v1.2     20 Jun 2021
    New:
      A menu action to add and commit the whole working tree.

  v1.3     21 Jun 2021
    New:
      A menu action to add and commit the current file.
      A menu action to list a combination of the commits of the current file
      and of other commits that have a commit message.

  v1.4     22 Jun 2021
    New:
      Open an old version of the current file from its commit list.

  v1.4.1   22 Jun 2021
    Fixed:
      Backwards compatibility down to TSE Pro v4.0.

  v1.4.2   23 Jun 2021
    Fixed:
      Compatible again with Linux TSE Pro v4.41.43 upwards.
    Fixed:
      Giving the extension's own temporary files a unique name did not work
      in Linux (because TSE's GetWinHandle() function always returns 0 there),
      which in theory could cause concurrent TSE sessions to use each other's
      temporary file contents.
    Partial fix:
      The git extension aborted on git files on "\\" drives.
      The extension now treats them as not being git files.

  v1.4.3   2 Jul 2021
    Fixed:
      The git extension sometimes randomly aborted on a configured "git add"
      after a File Save.
      Theoretically the most likely cause was, that the git status was being
      updated at the same time, and they both used the same temporary file.
      That theoretical cause has been fixed. I have not had an abort since.

  v1.4.4   17 Sep 2022
    Fixed incompatibility with TSE's '-i' command line option
    and the TSELOADDIR environment variable.
*/



/*
  TECHNICAL INFO ABOUT THE INNER WORKINGS FOR MACRO PROGRAMMERS AND FUTURE ME

  Timers
    The macro uses timers to refresh the git status and when necessary time out
    a request-response.
    These timers measure time in occurring idle events.
    A TSE idle event can happen at most 18 times per second.
    In practice this event happens less often, depending on how busy TSE is.
    For example, when a user is typing, depending on how fast they are typing,
    idle events may occur less frequently or even not at all during typing.
    This is a good thing!



  Write-up of the "TSE intermittently ignores a key stroke" bug.
    The problem
      Using Git.s v1.0.1, I found that TSE intermittently ignored key strokes,
      rarely enough that it was not immediately clear that my fumbling fingers
      were not the single cause this time.
    The cause
      In general programming terminology, a synchronous call sends a request
      and waits to receive the response during the same event.
      The nice thing about a synchronous call is, that it is simple to
      implement and maintain; in your program you can process the response in
      the next statement after the call.
      During an _idle_ event Git.s used a synchronous Dos() call to do
      a "git status -s" of a file.
      Here in TSE terminology synchronous means Dos() makes TSE wait until the
      command finishes.
      As I experimentally found out, TSE can mis key strokes during a
      synchronous Dos() call, even if it runs in the background.
    The solution
      In general programming terminology, an asynchronous call sends a request
      during one event and receives its response during another event.
      The nice thing about an asynchronous call is, that after sending the
      request your program can continue doing other things until the response
      is available.
      Experimentally I established that an "asynchronous Dos() call" does not
      make TSE mis key strokes.
      Here in TSE terminology asynchronous means making a Dos() call that
      immediately returns control back to TSE, while the command it started
      runs in a parellel background process. Git.s then periodically checks
      (here: during next _idle_ events) when the started command's output is
      available.
    Cool debugging trick
      TSE events sometimes take some extra work to debug with TSE's debugger,
      so as a shortcut I often use sound as a quick alternative to find out
      whether an event fires and what it is doing.
      In this case I placed a sound where the _idle_ event "sends a request"
      and another sound where a next _idle_ event "receives the response".
      While typing it was cool to hear the request-sound go off and a few typed
      characters later hear the response-sound!
      I left the two sound-commands commented in the code.
    The test
      I used Microsoft's Power Automate Desktop, which is a limited free
      version of Power Automate, to create an automated test, that simulated a
      fast typer and a slow typer each typing 446 key stroke long
      "lorem ipsum ..." lines.
      If one such typed line differs even one missed character from the other
      lines then that is very visible.
      Now knowing the bug's cause, I tweaked both the old and the new Git.s's
      internal parameters to make them more susceptible to the bug by
      requesting the current file's git status more frequently than will be
      needed in practice.
      The sound-debugging-trick confirmed that statusses were being requested
      and received every few characters during slow typing.
      In a final overnight test I made each typer type 100 such lines, which
      took the slow typer 6 hours and 18 minutes: hooray for automated testing!
      No Git.s version failed for the fast typer. This is because during fast
      typing TSE's _idle_ event never even fires. Points for TSE!
      During slow typing Git.s v1.0.1 nicely failed immediately and frequently,
      while Git.s v1.0.2 worked flawlessly. Yippee!

      So, in a controlled, automated, long endurance test the old git.s failed
      miserably and the new one performed flawlessly, so a bug is reproduceably
      solved.

      But. I am a messy typer. Among my messes I still occasionally see
      a missing character. Maybe that is me, and maybe there still is a
      remaining bug? Let me know if you find evidence of the latter!
*/



// Compatibility restrictions and mitigations

#ifdef LINUX
  #define WIN32 FALSE
#endif

#ifdef WIN32
#else
  16-bit versions of TSE are not supported. You need at least TSE Pro 4.0.
#endif

#ifdef EDITOR_VERSION
#else
  Editor Version is older than TSE Pro 3.0. You need at least TSE Pro 4.0.
#endif

#if EDITOR_VERSION < 4000h
  Editor Version is older than TSE Pro 4.0. You need at least TSE Pro 4.0.
#endif



#if EDITOR_VERSION < 4400h
  /*
    StartPgm()  1.0

    Below the line is StartPgm's TSE v4.4 documentation.

    When you make your macro backwards compatible downto TSE v4.0,
    then all four parameters become mandatory for all calls to StartPgm().

    If you do not need the 2nd, 3rd and 4th parameter, then you must use
    their default values: '', '' and _DEFAULT_.

    Tip:
      A practical use for StartPgm is that it lets you "start" a data file too,
      *if* Windows knows what program to run for the file's file type.

      For instance, you can "start" a URL, and StartPgm will start your default
      web browser for that URL.

    ---------------------------------------------------------------------------

    StartPgm

    Runs a program using the Windows ShellExecute function.

    Syntax:     INTEGER StartPgm(STRING pgm_name [, STRING args
                        [, STRING start_dir [, INTEGER startup_flags]]])

                - pgm_name is the name of the program to run.

                - args are optional command line arguments that should be passed
                  to pgm_name.

                - start_dir is an optional starting directory.

                - startup_flags are optional flags that control how pgm_name is
                  started.  Values can be: _START_HIDDEN_, _START_MINIMIZED_,
                  _START_MAXIMIZED_.

    Returns:    Non-zero if successful; zero (FALSE) on failure.

    Notes:      This function is the preferred way to run Win32 GUI programs
                from the editor.

    Examples:

                //Cause the editor to run g32.exe, editing the file "some.file"
                StartPgm("g32.exe", "some.file")

    See Also:   lDos(), Dos(), Shell()
  */
  #define SW_HIDE             0
  #define SW_SHOWNORMAL       1
  #define SW_NORMAL           1
  #define SW_SHOWMINIMIZED    2
  #define SW_SHOWMAXIMIZED    3
  #define SW_MAXIMIZE         3
  #define SW_SHOWNOACTIVATE   4
  #define SW_SHOW             5
  #define SW_MINIMIZE         6
  #define SW_SHOWMINNOACTIVE  7
  #define SW_SHOWNA           8
  #define SW_RESTORE          9
  #define SW_SHOWDEFAULT      10
  #define SW_MAX              10

  dll "<shell32.dll>"
    integer proc ShellExecute(
      integer h,          // handle to parent window
      string op:cstrval,  // specifies operation to perform
      string file:cstrval,// filename string
      string parm:cstrval,// specifies executable-file parameters
      string dir:cstrval, // specifies default directory
      integer show)       // whether file is shown when opened
      :"ShellExecuteA"
  end

  integer proc StartPgm(string  pgm_name,
                        string  args,
                        string  start_dir,
                        integer startup_flags)
    integer result              = FALSE
    integer return_code         = 0
    integer shell_startup_flags = 0
    case startup_flags
      when _DEFAULT_
        shell_startup_flags = SW_SHOWNORMAL
      when _START_HIDDEN_
        shell_startup_flags = SW_HIDE
      when _START_MAXIMIZED_
        shell_startup_flags = SW_SHOWMAXIMIZED
      when _START_MINIMIZED_
        shell_startup_flags = SW_SHOWMINIMIZED
      otherwise
        shell_startup_flags = SW_SHOWNORMAL
    endcase
    return_code = ShellExecute(0, 'open', pgm_name, args, start_dir,
                               shell_startup_flags)
    result = (return_code > 32)
    return(result)
  end StartPgm
#endif



#if EDITOR_VERSION < 4400h
  /*
    StrFind() 1.0

    If you have TSE Pro 4.0 or 4.2, then this proc implements the core of the
    built-in StrFind() function of TSE Pro 4.4.
    The StrFind() function searches a string or pattern inside another string
    and returns the position of the found string or zero.
    It works for strings like the regular Find() function does for files,
    so read the Help for the regular Find() function for the usage of the
    options, but apply these differences while reading:
    - Where the Find() (related) documentation refers to "file" and "line",
      StrFind() refers to "string".
    - The search option "g" ("global", meaning "from the start of the string")
      is implicit and can therefore always be omitted.
    As with the regular Find() function all characters are allowed as options,
    but here only these are acted upon: b, i, w, x, ^, $.

    Notable differences between the procedure below with TSE 4.4's built-in
    function:
    - The third parameter "options" is mandatory.
    - No fourth parameter "start" (actually occurrence: which one to search).
    - No fifth  parameter "len" (returning the length of the found text).

    Technical implementation notes:
    - To be reuseable elsewhere the procedure's source code is written to work
      independently of the rest of the source code.
      That said, it is intentionally not implemented as an include file, both
      for ease of installation and because one day another macro might need its
      omitted parameters, which would be an include file nightmare.
    - A tiny downside of the independent part is, that StrFind's buffer is not
      purged with the macro. To partially compensate for that if the macro is
      restarted, StrFind's possibly pre-existing buffer is searched for.
    - The fourth and fifth parameter are not implemented.
      - The first reason was that I estimated the tiny but actual performance
        gain and the easier function call to be more beneficial than the
        slight chance of a future use of these extra parameters.
      - The main reason turned out to be that in TSE 4.4 the fourth parameter
        "start" is erroneously documented and implemented.
        While this might be corrected in newer versions of TSE, it neither
        makes sense to me to faithfully reproduce these errors here, nor to
        make a correct implementation that will be replaced by an incorrect
        one if you upgrade to TSE 4.4.
  */
  integer strfind_id = 0
  integer proc StrFind(string needle, string haystack, string options)
    integer i                           = 0
    string  option                  [1] = ''
    integer org_id                      = GetBufferId()
    integer result                      = FALSE  // Zero.
    string  strfind_name [MAXSTRINGLEN] = ''
    string  validated_options       [7] = 'g'
    for i = 1 to Length(options)
      option = Lower(SubStr(options, i, 1))
      if      (option in 'b', 'i', 'w', 'x', '^', '$')
      and not Pos(option, validated_options)
        validated_options = validated_options + option
      endif
    endfor
    if strfind_id
      GotoBufferId(strfind_id)
      EmptyBuffer()
    else
      strfind_name = SplitPath(CurrMacroFilename(), _NAME_) + ':StrFind'
      strfind_id   = GetBufferId(strfind_name)
      if strfind_id
        GotoBufferId(strfind_id)
        EmptyBuffer()
      else
        strfind_id = CreateTempBuffer()
        ChangeCurrFilename(strfind_name, _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
      endif
    endif
    InsertText(haystack, _INSERT_)
    if lFind(needle, validated_options)
      result = CurrPos()
    endif
    GotoBufferId(org_id)
    return(result)
  end StrFind
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



/*
  compare_versions()  v2.0

  This proc compares two version strings version1 and version2, and returns
  -1, 0 or 1 if version1 is smaller, equal, or greater than/to version2.

  For the comparison a version string is split into parts:
  - Explicitly by separating parts by a period.
  - Implicitly:
    - Any uninterrupted sequence of digits is a "number part".
    - Any uninterrupted sequence of other characters is a "string part".

  Spaces are mostly ignored. They are only significant:
  - Between two digits they signify that the digits belong to different parts.
  - Between two "other characters" they belong to the same string part.

  If the first version part is a single "v" or "V" then it is ignored.

  Two version strings are compared by comparing their respective version parts
  from left to right.

  Two number parts are compared numerically, e.g: "1" < "2" < "11" < "012".

  Any other combination of version parts is case-insensitively compared as
  strings, e.g: "12" < "one" < "three" < "two", or "a" < "B" < "c" < "d".

  Examples: See the included unit tests further on.

  v2.0
    Out in the wild there is an unversioned version of compare_versions(),
    that is more restricted in what version formats it can recognize,
    therefore here versioning of compare_versions() starts at v2.0.
*/

// compare_versions_standardize() is a helper proc for compare_versions().

string proc compare_versions_standardize(string p_version)
  integer char_nr                  = 0
  string  n_version [MAXSTRINGLEN] = Trim(p_version)

  // Replace any spaces between digits by one period. Needs two StrReplace()s.
  n_version = StrReplace('{[0-9]} #{[0-9]}', n_version, '\1.\2', 'x')
  n_version = StrReplace('{[0-9]} #{[0-9]}', n_version, '\1.\2', 'x')

  // Remove any spaces before and after digits.
  n_version = StrReplace(' #{[0-9]}', n_version, '\1', 'x')
  n_version = StrReplace('{[0-9]} #', n_version, '\1', 'x')

  // Remove any spaces before and after periods.
  n_version = StrReplace(' #{\.}', n_version, '\1', 'x')
  n_version = StrReplace('{\.} #', n_version, '\1', 'x')

  // Separate version parts by periods if they aren't yet.
  char_nr = 1
  while char_nr < Length(n_version)
    case n_version[char_nr:1]
      when '.'
        NoOp()
      when '0' .. '9'
        if not (n_version[char_nr+1:1] in '0' .. '9', '.')
          n_version = n_version[1:char_nr] + '.' + n_version[char_nr+1:MAXSTRINGLEN]
        endif
      otherwise
        if (n_version[char_nr+1:1] in '0' .. '9')
          n_version = n_version[1:char_nr] + '.' + n_version[char_nr+1:MAXSTRINGLEN]
        endif
    endcase
    char_nr = char_nr + 1
  endwhile
  // Remove a leading 'v' if it is by itself, i.e not part of a non-numeric string.
  if  (n_version[1:2] in 'v.', 'V.')
    n_version = n_version[3:MAXSTRINGLEN]
  endif
  return(n_version)
end compare_versions_standardize

integer proc compare_versions(string version1, string version2)
  integer result                 = 0
  string  v1_part [MAXSTRINGLEN] = ''
  string  v1_str  [MAXSTRINGLEN] = ''
  string  v2_part [MAXSTRINGLEN] = ''
  string  v2_str  [MAXSTRINGLEN] = ''
  integer v_num_parts            = 0
  integer v_part_nr              = 0
  v1_str      = compare_versions_standardize(version1)
  v2_str      = compare_versions_standardize(version2)
  v_num_parts = Max(NumTokens(v1_str, '.'), NumTokens(v2_str, '.'))
  repeat
    v_part_nr = v_part_nr + 1
    v1_part   = Trim(GetToken(v1_str, '.', v_part_nr))
    v2_part   = Trim(GetToken(v2_str, '.', v_part_nr))
    if  v1_part == ''
    and isDigit(v2_part)
      v1_part = '0'
    endif
    if v2_part == ''
    and isDigit(v1_part)
      v2_part = '0'
    endif
    if  isDigit(v1_part)
    and isDigit(v2_part)
      if     Val(v1_part) < Val(v2_part)
        result = -1
      elseif Val(v1_part) > Val(v2_part)
        result =  1
      endif
    else
      result = CmpiStr(v1_part, v2_part)
    endif
  until result    <> 0
     or v_part_nr >= v_num_parts
  return(result)
end compare_versions



// End of compatibility restrictions and mitigations





// Global constants

#define CHANGE_CURR_FILENAME_FLAGS          _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
#define GIT_COMMIT_LENGTH                   40
string  CMD_CLOSING_QUOTEPATH         [9] = 'QuotePath'
string  CMD_CLOSING_STDERR            [4] = '2>&1'
string  CMD_CLOSING_STDOUT            [1] = '>'
string  CMD_CLOSING_STRING            [7] = ' string'
#define DOS_ASYNC_CALL_FLAGS                _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_|_RUN_DETACHED_|_DONT_WAIT_
#define DOS_SYNC_CALL_FLAGS                 _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_
#define FIRST_EQUAL_TO_SECOND               0
#define FIRST_NEWER_THAN_SECOND             1
#define FIRST_OLDER_THAN_SECOND             -1
#define ISO_DATE_LENGTH                     25
string  MY_MACRO_VERSION              [5] = '1.4.4'
#define REQUEST_RESPONSE_TIMEOUT            36  // As a fail-safe.
#define SAVEAS_FLAGS                        _DONT_PROMPT_|_OVERWRITE_
#define STATUS_SHORT_REFRESH_PERIOD         9   // After changing to/saving a file.
string  STATUS_MACRO_NAME             [6] = 'Status'
string  STATUS_MACRO_REQUIRED_VERSION [3] = '1.2'
#define STATUS_LONG_REFRESH_PERIOD          90  // While editing a file.
string  UPGRADE_URL                  [36] = 'https://ecarlo.nl/tse/index.html#Git'

#ifdef LINUX
  string SLASH [1] = '/'
#else
  string SLASH [1] = '\'
#endif



// Global semi-constants, only initialized once.

string  MY_MACRO_NAME       [MAXSTRINGLEN] = ''
string  TMP_ASYNC_CMD_FQN   [MAXSTRINGLEN] = ''
integer TMP_ASYNC_CMD_ID                   = 0
string  TMP_ASYNC_OUT_FQN   [MAXSTRINGLEN] = ''
integer TMP_ASYNC_OUT_ID                   = 0
string  TMP_SYNC_CMD_FQN    [MAXSTRINGLEN] = ''
integer TMP_SYNC_CMD_ID                    = 0
string  TMP_SYNC_OUT_FQN    [MAXSTRINGLEN] = ''
integer TMP_SYNC_OUT_ID                    = 0
string  VARNAME_CFG_SECTION [MAXSTRINGLEN] = ''



// Global variables

integer abort_issued                         = FALSE
string  cfg_after_file_save   [MAXSTRINGLEN] = ''
string  cfg_git_exe           [MAXSTRINGLEN] = ''
integer idle_id                              = 0
integer menu_history_number                  = 0
integer profile_error                        = FALSE
string  request_response_file [MAXSTRINGLEN] = ''
integer request_response_stopwatch           = 0
integer status_refresh_timer                 = 0
integer temporary_cmd_file_created           = FALSE
integer times_status_output_found            = 0
integer waiting_for_response                 = FALSE



// Generic code

proc abort(string msg)
  if Query(Beep)
    Alarm()
  endif
  Warn(MY_MACRO_NAME; 'aborts!', Chr(13), msg)
  abort_issued = TRUE
end abort

integer proc get_process_id()
  integer process_id = 0
  #ifdef LINUX
    integer org_id = GetBufferId()
    EmptyBuffer(Query(CaptureId))
    if Capture('/bin/bash -c "ps -o ppid= `echo $$`"')
      BegFile()
      process_id = Val(Trim(GetText(1, MAXSTRINGLEN)))
    endif
    GotoBufferId(org_id)
  #else
    process_id = GetWinHandle()
  #endif
  return(process_id)
end get_process_id

proc erase_disk_file(string file_to_erase)
  #ifdef LINUX
    // Dummy statements to pacify compiler.
    if  FALSE
    and Length(file_to_erase)
      NoOp()
    endif
  #else
    EraseDiskFile(file_to_erase)
  #endif
end erase_disk_file

proc show_help()
  string  full_macro_source_name [MAXSTRINGLEN] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + '.s'
  string  help_file_name         [MAXSTRINGLEN] = '*** ' + MY_MACRO_NAME + ' Help ***'
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
        ChangeCurrFilename(help_file_name, CHANGE_CURR_FILENAME_FLAGS)
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

/*
  An ExecMacro that eventually stops this macro if the Status macro is not
  installed, thereby avoiding an infinite loop.
*/
proc exec_macro(string macro_cmd_line)
  string  status_macro_current_version [MAXSTRINGLEN] = ''
  string  extra_version_text           [MAXSTRINGLEN] = ''
  integer ok                                          = TRUE
  ok = ExecMacro(macro_cmd_line)
  if ok
    status_macro_current_version = GetGlobalStr(status_macro_name + ':Version')
    if compare_versions(status_macro_current_version,
                        status_macro_required_version)
                        == FIRST_OLDER_THAN_SECOND
      ok                 = FALSE
      extra_version_text = 'at least version ' +
                           STATUS_MACRO_REQUIRED_VERSION + ' of '
    endif
  endif
  if not ok
    abort('It requires ' + extra_version_text + 'macro "' + status_macro_name
          + '" to be installed.')
  endif
end exec_macro

proc change_status_color()
  exec_macro(status_macro_name + ' ConfigureStatusColor')
end change_status_color



// Specific code

proc browse_website()
  #ifdef LINUX
    // Reportedly this is the most cross-Linux compatible way.
    // It worked out of the box for me: No Linux configuration was necessary.
    // Obviously it will only work for Linux installations with a GUI that can
    // run a web browser.
    Dos('python -m webbrowser "' + UPGRADE_URL + '"', DOS_SYNC_CALL_FLAGS)
  #else
    StartPgm(UPGRADE_URL, '', '', _DEFAULT_)
  #endif
end browse_website

/*
  This proc's input implicitly is the current file.
  If the current file is located in a git working tree,
  then the function returns TRUE and git_root and git_file return the working
  tree and the file's relative location in git_root,
  otherwise the function returns FALSE and git_root and git_file return an
  empty string.
  Exception:
    A git file on a "\\" drive is pretended not to be a git file,
    because this extension cannot handle git action for such files.
*/
integer proc get_current_file_git_parts(var string git_root,
                                        var string git_file)
  string  ancester_path [MAXSTRINGLEN] = ''
  integer dir_level                    = 1
  string  curr_file_fqn [MAXSTRINGLEN] = CurrFilename()
  integer in_git_working_tree          = FALSE
  git_root = ''
  git_file = ''
  if  curr_file_fqn[1: 2] <> '\\'
  and NumTokens(curr_file_fqn, SLASH) > 1
    #ifdef LINUX
      ancester_path = SLASH
    #else
      ancester_path = GetToken(curr_file_fqn, SLASH, 1) + SLASH
    #endif
    while git_root == ''
    and   NumTokens(ancester_path, SLASH) <= NumTokens(curr_file_fqn, SLASH)
      if FileExists(ancester_path + '.git')
        git_root      = ancester_path
      else
        dir_level     = dir_level + 1
        ancester_path = ancester_path + GetToken(curr_file_fqn, SLASH, dir_level) + SLASH
      endif
    endwhile
    if git_root <> ''
      git_file = curr_file_fqn[Length(git_root) + 1: MAXSTRINGLEN]
      git_file = StrReplace('\', git_file, '/', '')
      #ifdef LINUX
        git_root = git_root[1: Length(git_root) - 1]
      #else
        if NumTokens(git_root, SLASH) > 2
          git_root = git_root[1: Length(git_root) - 1]
        else
          git_root = git_root + '.' // Makes git root at root of drive work.
        endif
      #endif
      in_git_working_tree = TRUE
    endif
  endif
  return(in_git_working_tree)
end get_current_file_git_parts

integer proc dos_call(integer show_error, string cmd, integer dos_flags)
  integer command_return_code        = 0
  integer dos_errorlevel             = 0
  integer dos_io_result              = 0
  integer dos_result                 = 0
  integer ok                         = TRUE
  integer org_id                     = GetBufferId()
  integer tmp_out_id                 = 0
  string  tmp_out_fqn [MAXSTRINGLEN] = ''

  dos_result          = Dos(cmd, dos_flags)
  dos_io_result       = DosIOResult()
  command_return_code = HiByte(dos_io_result)
  dos_errorlevel      = LoByte(dos_io_result)

  #ifdef LINUX
    // Linux erroneously returns errorlevel 1 for a succesful detached command.
    if dos_flags & _RUN_DETACHED_
      dos_errorlevel = 0
    endif
  #endif

  if not dos_result
  or     command_return_code
  or     dos_errorlevel
    ok = FALSE
    if show_error
      Alarm()
      if dos_flags == DOS_ASYNC_CALL_FLAGS
        tmp_out_id  = TMP_ASYNC_OUT_ID
        tmp_out_fqn = TMP_ASYNC_OUT_FQN
      else
        tmp_out_id  = TMP_SYNC_OUT_ID
        tmp_out_fqn = TMP_SYNC_OUT_FQN
      endif
      GotoBufferId(tmp_out_id)
      LoadBuffer(tmp_out_fqn)
      erase_disk_file(tmp_out_fqn)
      BegFile()
      UpdateDisplay()
      Warn(cmd, Chr(13), 'ERROR!')
      Delay(9)
      Message('Dos(), command and errorlevel returned';
              dos_result, ','; command_return_code; 'and'; dos_errorlevel,
              '. Press any key ...')
      GetKey()
      Message('')
      GotoBufferId(org_id)
      UpdateDisplay()
    endif
  endif
  return(ok)
end dos_call

integer proc dos_request_response(    integer show_error,
                                      string  cmd,
                                  var string  first_output_line)
  integer ok     = TRUE
  integer org_id = GetBufferId()
  first_output_line   = ''
  ok = dos_call(show_error, cmd, DOS_SYNC_CALL_FLAGS)
  if ok
    GotoBufferId(TMP_SYNC_OUT_ID)
    LoadBuffer(TMP_SYNC_OUT_FQN)
    erase_disk_file(TMP_SYNC_OUT_FQN)
    if temporary_cmd_file_created
      erase_disk_file(TMP_SYNC_CMD_FQN)
      temporary_cmd_file_created = FALSE
    endif
    BegFile()
    first_output_line = GetText(1, MAXSTRINGLEN)
  endif
  GotoBufferId(org_id)
  return(ok)
end dos_request_response

integer proc dos_request(integer show_error, string cmd)
  integer ok = TRUE
  ok = dos_call(show_error, cmd, DOS_ASYNC_CALL_FLAGS)
  // Due to its nature an asynchronous request does not return most errors,
  // so later on the response output needs to be examined for errors.
  return(ok)
end dos_request

integer proc dos_response(var string first_output_line)
  integer file_found = FALSE
  integer org_id     = GetBufferId()
  first_output_line = ''
  if FileExists(TMP_ASYNC_OUT_FQN)
    GotoBufferId(TMP_ASYNC_OUT_ID)
    if LoadBuffer(TMP_ASYNC_OUT_FQN)
      BegFile()
      if  NumLines()
      and CurrLineLen()
        first_output_line = GetText(1, MAXSTRINGLEN)
        file_found        = TRUE
        erase_disk_file(TMP_ASYNC_OUT_FQN)
        if temporary_cmd_file_created
          erase_disk_file(TMP_ASYNC_CMD_FQN)
          temporary_cmd_file_created = FALSE
        endif
      endif
    endif
  endif
  GotoBufferId(org_id)
  return(file_found)
end dos_response

string proc compress_date(string s)
  string r [ISO_DATE_LENGTH] = s
  r = StrReplace('-', r,  '', '')
  r = StrReplace(':', r,  '', '')
  r = StrReplace(' ', r,  '', '')
  r = StrReplace('+', r, '_', '')
  return(r)
end compress_date

proc create_string_cmd(var string cmd, string t, string s)
  string type [10] = t
  if type <> ''
    if type[1] == ' '
      cmd  = cmd + ' '
      type = type[2: MAXSTRINGLEN]
    endif
    case type
      when 'QuotePath'
        cmd = cmd + QuotePath(s)  // Length(s) > 253 is corrected for later.
      when 'string'
        cmd = cmd + s
    endcase
  endif
end create_string_cmd

proc create_buffer_cmd(string t, string s)
  string type [10] = t
  if type <> ''
    if type[1] == ' '
      InsertText(' ', _INSERT_)
      type = type[2: MAXSTRINGLEN]
    endif
    case type
      when 'QuotePath'
        if Pos(' ', s)
          InsertText('"', _INSERT_)   // This "QuotePath" also correctly handles
          InsertText(s  , _INSERT_)   // strings of lengths 254 and 255.
          InsertText('"', _INSERT_)   // Note: here strings are never pre-quoted.
        else
          InsertText(s, _INSERT_)
        endif
      when 'string'
        InsertText(s, _INSERT_)
    endcase
  endif
end create_buffer_cmd

string proc create_cmd(integer run_type,
                       string t1, string s1,
                       string t2, string s2,
                       string t3, string s3,
                       string t4, string s4,
                       string t5, string s5,
                       string t6, string s6,
                       string t7, string s7)
  string  cmd         [MAXSTRINGLEN] = ''
  integer org_id                     = GetBufferId()
  string  tmp_cmd_fqn [MAXSTRINGLEN] = ''
  integer tmp_cmd_id                 = 0
  string  tmp_out_fqn [MAXSTRINGLEN] = ''

  if run_type == _RUN_DETACHED_
    tmp_cmd_id  = TMP_ASYNC_CMD_ID
    tmp_cmd_fqn = TMP_ASYNC_CMD_FQN
    tmp_out_fqn = TMP_ASYNC_OUT_FQN
  else
    tmp_cmd_id  = TMP_SYNC_CMD_ID
    tmp_cmd_fqn = TMP_SYNC_CMD_FQN
    tmp_out_fqn = TMP_SYNC_OUT_FQN
  endif

  // First try the more efficient approach of assembling the command in a
  // string so we can call the command directly.

  // Except in Linux for a command that is to be run detached.
  // Bug, reported dd 22 Jun 2021:
  //   In Linux: Dos(<not a script>, _RUN_DETACHED_) messes up the screen.
  if WIN32
  or run_type <> _RUN_DETACHED_
    create_string_cmd(cmd, t1, s1)
    create_string_cmd(cmd, t2, s2)
    create_string_cmd(cmd, t3, s3)
    create_string_cmd(cmd, t4, s4)
    create_string_cmd(cmd, t5, s5)
    create_string_cmd(cmd, t6, s6)
    create_string_cmd(cmd, t7, s7)
    create_string_cmd(cmd, CMD_CLOSING_STRING   , CMD_CLOSING_STDOUT)
    create_string_cmd(cmd, CMD_CLOSING_QUOTEPATH, tmp_out_fqn)
    create_string_cmd(cmd, CMD_CLOSING_STRING   , CMD_CLOSING_STDERR)
  else
    cmd[MAXSTRINGLEN] = '!'
  endif

  // If avoiding the Linux bug or the command probably does not fit
  if cmd[MAXSTRINGLEN] <> ''
    // then assemble the requested command in a script
    // and make our command the call to the script.
    GotoBufferId(tmp_cmd_id)
    EmptyBuffer()
    BegFile()
    create_buffer_cmd(t1, s1)
    create_buffer_cmd(t2, s2)
    create_buffer_cmd(t3, s3)
    create_buffer_cmd(t4, s4)
    create_buffer_cmd(t5, s5)
    create_buffer_cmd(t6, s6)
    create_buffer_cmd(t7, s7)
    create_buffer_cmd(CMD_CLOSING_STRING   , CMD_CLOSING_STDOUT)
    create_buffer_cmd(CMD_CLOSING_QUOTEPATH, tmp_out_fqn)
    create_buffer_cmd(CMD_CLOSING_STRING   , CMD_CLOSING_STDERR)
    if SaveAs(tmp_cmd_fqn, SAVEAS_FLAGS)
      temporary_cmd_file_created = TRUE
      cmd = QuotePath(tmp_cmd_fqn)
    else
      cmd = ''
      abort('Could not Write: ' + tmp_cmd_fqn)
    endif
    GotoBufferId(org_id)
  endif
  return(cmd)
end create_cmd

proc show_git_status()
  string  git_status             [2] = ''
  string  output_line [MAXSTRINGLEN] = ''
  if dos_response(output_line)
    // Because the response comes from an asynchronous request,
    // we need to check the response for errors.
    if  Pos('error: ', output_line) == 0
    and (  StrFind(' '  + request_response_file      , output_line, '$')
        or StrFind(' "' + request_response_file + '"', output_line, '$'))
      // Sound(1500, 200)   // Debug response-sound.
      git_status = output_line[1: 2]
    else
      abort('"git status -s <file>" returned this first line:' + Chr(13)
            + output_line)
    endif
  endif
  exec_macro(STATUS_MACRO_NAME + ' ' + MY_MACRO_NAME +
             ':Status,callback Git' + RTrim(' ' + git_status))
end show_git_status

integer proc request_git_status()
  string  cmd         [MAXSTRINGLEN] = ''
  string  git_file    [MAXSTRINGLEN] = ''
  string  git_root    [MAXSTRINGLEN] = ''
  integer ok                         = FALSE
  if get_current_file_git_parts(git_root, git_file)
    cmd = create_cmd(_RUN_DETACHED_,
                     'QuotePath' , cfg_git_exe,
                     ' string'   , '-C',
                     ' QuotePath', git_root,
                     ' string'   , 'status -s',
                     ' QuotePath', git_file,
                     ''          , '',
                     ''          , '')
    if dos_request(TRUE, cmd)
      request_response_file = git_file
      ok    = TRUE
    else
      abort('Asynchronously executed git status command failed.')
    endif
  endif
  return(ok)
end request_git_status

proc idle()
  if abort_issued
    PurgeMacro(MY_MACRO_NAME)
  else
    if GetBufferId() == idle_id
      if waiting_for_response
        request_response_stopwatch = request_response_stopwatch + 1
        if request_response_stopwatch >= REQUEST_RESPONSE_TIMEOUT
          // The time-out period is long and only applies to simple asynchronous
          // requests, like for "git status -s".
          // Practice showed this occurring about once a day.
          // I decided to just ignore it.
          // if Query(Beep)
          //   Alarm()
          // endif
          // Message('Ignorable: waiting for a git response timed out.')
          waiting_for_response = FALSE
          erase_disk_file(TMP_ASYNC_OUT_FQN)
        else
          if FileExists(TMP_ASYNC_OUT_FQN)
            // Just to be sure give the command an extra clocktick
            // to finish logging its output to the temp file.
            times_status_output_found = times_status_output_found + 1
            if times_status_output_found >= 2
              show_git_status()
              erase_disk_file(TMP_ASYNC_OUT_FQN)
              waiting_for_response = FALSE
              status_refresh_timer = STATUS_LONG_REFRESH_PERIOD
            endif
          endif
        endif
      else
        status_refresh_timer = status_refresh_timer - 1
        if status_refresh_timer < 1
          // Sound(1000, 200)   // Debug request-sound.
          if request_git_status()
            waiting_for_response       = TRUE
            times_status_output_found  = 0
            request_response_stopwatch = 0
          else
            status_refresh_timer       = STATUS_LONG_REFRESH_PERIOD
          endif
        endif
      endif
    else
      idle_id              = GetBufferId()
      status_refresh_timer = STATUS_SHORT_REFRESH_PERIOD
      waiting_for_response = FALSE
      erase_disk_file(TMP_ASYNC_OUT_FQN)
    endif
  endif
end idle

proc after_file_save()
  string  cmd         [MAXSTRINGLEN] = ''
  string  output_line [MAXSTRINGLEN] = ''
  string  git_file    [MAXSTRINGLEN] = ''
  string  git_root    [MAXSTRINGLEN] = ''
  if  not abort_issued
  and cfg_after_file_save <> ''
  and get_current_file_git_parts(git_root, git_file)
    if (cfg_after_file_save in 'git add', 'git add + commit')
      cmd = create_cmd(_DEFAULT_,
                       'QuotePath' , cfg_git_exe,
                       ' string'   , '-C',
                       ' QuotePath', git_root,
                       ' string'   , 'add',
                       ' QuotePath', git_file,
                       ''          , '',
                       ''          , '')
      if dos_request_response(TRUE, cmd, output_line)
        status_refresh_timer = STATUS_SHORT_REFRESH_PERIOD
      else
        abort('"git add" after file save failed.')
      endif
    endif
    if  not abort_issued
    and cfg_after_file_save == 'git add + commit'
      // A commit of an unchanged file will raise an error too.
      // We do not want to miss other errors.
      // So before a commit we should determine the file's git status.
      cmd = create_cmd(_DEFAULT_,
                       'QuotePath' , cfg_git_exe,
                       ' string'   , '-C',
                       ' QuotePath', git_root,
                       ' string'   , 'status -s',
                       ' QuotePath', git_file,
                       ''          , '',
                       ''          , '')
      if  dos_request_response(TRUE, cmd, output_line)
        if Trim(output_line) <> ''  // Only commit a changed file.
          cmd = create_cmd(_DEFAULT_,
                           'QuotePath' , cfg_git_exe,
                           ' string'   , '-C',
                           ' QuotePath', git_root,
                           ' string'   , 'commit --allow-empty-message -m ""',
                           ' QuotePath', git_file,
                           ''          , '',
                           ''          , '')
          if dos_request_response(TRUE, cmd, output_line)
            status_refresh_timer = STATUS_SHORT_REFRESH_PERIOD
          else
            abort('"git commit" after "git add" after file save failed.')
          endif
        endif
      else
        abort('"git status" after "git add" after file save failed.')
      endif
    endif
  endif
end after_file_save

proc add_and_commit_working_tree()
  string cmd            [MAXSTRINGLEN] = ''
  string commit_message [MAXSTRINGLEN] = ''
  string git_file       [MAXSTRINGLEN] = ''
  string git_root       [MAXSTRINGLEN] = ''
  string output_line    [MAXSTRINGLEN] = ''

  if get_current_file_git_parts(git_root, git_file)
    if Ask('Commit message for ' + git_root + ':', commit_message)
      commit_message = Trim(commit_message)
      if commit_message == ''
        Warn('A commit message is mandatory.')
      else
        cmd = create_cmd(_DEFAULT_,
                         'QuotePath' , cfg_git_exe,
                         ' string'   , '-C',
                         ' QuotePath', git_root,
                         ' string'   , 'add .',
                         ''          , '',
                         ''          , '',
                         ''          , '')
        if dos_request_response(TRUE, cmd, output_line)
          cmd = create_cmd(_DEFAULT_,
                           'QuotePath' , cfg_git_exe,
                           ' string'   , '-C',
                           ' QuotePath', git_root,
                           ' string'   , 'commit --allow-empty -m "',
                           'string'    , commit_message,
                           'string'    , '"',
                           ''          , '')
          output_line = ''
          if dos_request_response(TRUE, cmd, output_line)
            Warn('Done.' + Chr(13)  + Chr(13)
                 + 'Added and committed the working tree.')
          endif
        endif
      endif
    endif
  else
    Warn('The current file is not in a git working tree.')
  endif
end add_and_commit_working_tree

proc add_and_commit_current_file()
  string cmd            [MAXSTRINGLEN] = ''
  string commit_message [MAXSTRINGLEN] = ''
  string git_file       [MAXSTRINGLEN] = ''
  string git_root       [MAXSTRINGLEN] = ''
  string output_line    [MAXSTRINGLEN] = ''

  if get_current_file_git_parts(git_root, git_file)
    if Ask('Commit message for ' + CurrFilename() + ':', commit_message)
      commit_message = Trim(commit_message)
      if commit_message == ''
        Warn('A commit message is mandatory.')
      else
        if FileChanged()
          // SaveAs() does not trigger hooks with automatic actions.
          SaveAs(CurrFilename(), SAVEAS_FLAGS)
        endif
        cmd = create_cmd(_DEFAULT_,
                         'QuotePath' , cfg_git_exe,
                         ' string'   , '-C',
                         ' QuotePath', git_root,
                         ' string'   , 'add',
                         ' QuotePath', git_file,
                         ''          , '',
                         ''          , '')
        if dos_request_response(TRUE, cmd, output_line)
          cmd = create_cmd(_DEFAULT_,
                           'QuotePath' , cfg_git_exe,
                           ' string'   , '-C',
                           ' QuotePath', git_root,
                           ' string'   , 'commit --allow-empty -m "',
                           'string'    , commit_message,
                           'string'    , '"',
                           ' QuotePath', git_file)
          output_line = ''
          if dos_request_response(TRUE, cmd, output_line)
            Warn('Done.' + Chr(13)  + Chr(13)
                 + 'Added and committed the current file.')
          endif
        endif
      endif
    endif
  else
    Warn('The current file is not in a git working tree.')
  endif
end add_and_commit_current_file

proc add_log_to_lst(integer log_id, integer lst_id, string selector)
  string field [MAXSTRINGLEN] = ''
  GotoBufferId(log_id)
  BegFile()
  repeat
    case PosFirstNonWhite()
      when 0
        NoOp()
      when 1
        if GetText(1, 5) == 'Date:'
          GotoPos(6)
          lFind('[~\x09\x20]', 'cx')
          field = Trim(GetText(CurrPos(), MAXSTRINGLEN))
          GotoBufferId(lst_id)
          AddLine(field)
          EndLine()
          InsertText('  '    , _INSERT_)
          InsertText(selector, _INSERT_)
          GotoBufferId(log_id)
        endif
      otherwise
        field = Trim(GetText(PosFirstNonWhite(), MAXSTRINGLEN))
        GotoBufferId(lst_id)
        EndLine()
        InsertText('  ' , _INSERT_)
        InsertText(field, _INSERT_)
        GotoBufferId(log_id)
    endcase
  until not Down()
end add_log_to_lst

integer proc open_selected_file(integer org_id,
                                integer cur_id,
                                integer msg_id,
                                integer lst_id)
  string  cmd                  [MAXSTRINGLEN] = ''
  integer date_found                          = FALSE
  string  first_output_line               [1] = ''
  string  git_file             [MAXSTRINGLEN] = ''
  string  git_root             [MAXSTRINGLEN] = ''
  integer ok                                  = TRUE
  string  selected_commit [GIT_COMMIT_LENGTH] = ''
  string  selected_date     [ISO_DATE_LENGTH] = ''
  GotoBufferId(lst_id)
  selected_date = GetText(1, ISO_DATE_LENGTH)
  GotoBufferId(cur_id)
  if lFind(selected_date, 'g')
    date_found = TRUE
  else
    GotoBufferId(msg_id)
    if lFind(selected_date, 'g')
      date_found = TRUE
    endif
  endif
  if  date_found
  and lFind('commit', '^b')
    selected_commit = Trim(GetText(8, GIT_COMMIT_LENGTH))
  endif
  if Length(selected_commit) <> GIT_COMMIT_LENGTH
    Warn('Selected commit not found.')
    ok = FALSE
  endif
  if ok
    GotoBufferId(org_id)
    if get_current_file_git_parts(git_root, git_file)
      cmd = create_cmd(_DEFAULT_,
                       'QuotePath' , cfg_git_exe,
                       ' string'   , '-P -C',
                       ' QuotePath', git_root,
                       ' string'   , 'show',
                       ' string'   , selected_commit,
                       'string'    , ':',
                       'QuotePath' , git_file)
      if dos_request_response(true, cmd, first_output_line)
        GotoBufferId(TMP_SYNC_OUT_ID)
        PushBlock()
        MarkLine(1, NumLines())
        NewFile()
        // The "*" as delimitors also make the file not savable by accident.
        if ChangeCurrFilename(  SplitPath(git_file, _NAME_)
                              + '*' + compress_date(selected_date) + '*'
                              + SplitPath(git_file, _EXT_),
                              CHANGE_CURR_FILENAME_FLAGS)
          // If the new longer filename succeeds, then try adding the original
          // path too.
          ChangeCurrFilename(  git_root
                             + SLASH
                             + RemoveTrailingSlash(SplitPath(git_file, _PATH_))
                             + SLASH
                             + CurrFilename(),
                             CHANGE_CURR_FILENAME_FLAGS)
        endif
        MoveBlock()
        UnMarkBlock()
        PopBlock()
        FileChanged(FALSE)
      else
        Warn('Could not retrieve selected file.')
        ok = FALSE
      endif
    else
      Warn('Current file no longer in git.')
      ok = FALSE
    endif
  endif
  if not ok
    GotoBufferId(org_id)
  endif
  return(ok)
end open_selected_file

proc list_current_file_versions()
  string  cmd          [MAXSTRINGLEN] = ''
  integer cur_id                      = 0
  string  first_output_line       [1] = ''
  string  git_file     [MAXSTRINGLEN] = ''
  string  git_root     [MAXSTRINGLEN] = ''
  integer lst_id                      = 0
  integer msg_id                      = 0
  integer old_MsgLevel                = 0
  integer old_y1                      = 0
  integer org_id                      = GetBufferId()
  string  prev_date [ISO_DATE_LENGTH] = ''
  if get_current_file_git_parts(git_root, git_file)
    // Create a list of all commits that have changes for the current file.
    cmd = create_cmd(_DEFAULT_,
                     'QuotePath' , cfg_git_exe,
                     ' string'   , '-P -C',
                     ' QuotePath', git_root,
                     ' string'   , 'log --reverse --date=iso --follow',
                     ' QuotePath', git_file,
                     ''          , '',
                     ''          , '')
    if dos_request_response(true, cmd, first_output_line)
      GotoBufferId(TMP_SYNC_OUT_ID)
      PushBlock()
      MarkLine(1, NumLines())
      cur_id = CreateTempBuffer()
      ChangeCurrFilename(MY_MACRO_NAME + ':TmpCur', CHANGE_CURR_FILENAME_FLAGS)
      MoveBlock()
      UnMarkBlock()
      PopBlock()
      // Create a list of all commits that have a commit message.
      cmd = create_cmd(_DEFAULT_,
                       'QuotePath' , cfg_git_exe,
                       ' string'   , '-P -C',
                       ' QuotePath', git_root,
                       ' string'   , 'log --reverse --date=iso --grep="."',
                       ''          , '',
                       ''          , '',
                       ''          , '')
      if dos_request_response(true, cmd, first_output_line)
        GotoBufferId(TMP_SYNC_OUT_ID)
        PushBlock()
        MarkLine(1, NumLines())
        msg_id = CreateTempBuffer()
        ChangeCurrFilename(MY_MACRO_NAME + ':TmpMsg', CHANGE_CURR_FILENAME_FLAGS)
        MoveBlock()
        UnMarkBlock()
        PopBlock()
        lst_id = CreateTempBuffer()
        ChangeCurrFilename(MY_MACRO_NAME + ':TmpLst', CHANGE_CURR_FILENAME_FLAGS)
        // Select info from both git logs to create a formatted list
        GotoBufferId(lst_id)
        EmptyBuffer()
        add_log_to_lst(cur_id, lst_id, 'file')
        add_log_to_lst(msg_id, lst_id, 'mesg')
        GotoBufferId(lst_id)
        // Sort the list
        PushBlock()
        MarkLine(1, NumLines())
        old_MsgLevel = Set(MsgLevel, _NONE_)
        ExecMacro('sort')
        Set(MsgLevel, old_MsgLevel)
        UnMarkBlock()
        PopBlock()
        // Remove duplicates. Usually "file" and "mesg" are each others
        // duplicate; then "mesg" is removed.
        BegFile()
        prev_date = GetText(1, ISO_DATE_LENGTH)
        while Down()
          if GetText(1, ISO_DATE_LENGTH) == prev_date
            KillLine()
            Up()
          endif
          prev_date = GetText(1, ISO_DATE_LENGTH)
        endwhile
        // Show the list to the user.
        EndFile()
        old_y1 = Set(Y1, 4)
        if lList('File/mesg: Commits of the current file plus other commits with a message',
                 LongestLineInBuffer(),
                 Query(ScreenRows) - 5,
                 _ENABLE_SEARCH_|_ENABLE_HSCROLL_)
          open_selected_file(org_id, cur_id, msg_id, lst_id)
        else
          GotoBufferId(org_id)
        endif
        Set(Y1, old_y1 )
      endif
      AbandonFile(cur_id)
      AbandonFile(msg_id)
      AbandonFile(lst_id)
    endif
  else
    Warn('Current file not in git working tree.')
  endif
end list_current_file_versions

integer proc get_windows_or_linux_menu_flag()
  // return(_MF_GRAYED_|_MF_SKIP_)
  return(_MF_CLOSE_ALL_BEFORE_|_MF_ENABLED_)
end get_windows_or_linux_menu_flag

integer proc get_git_menu_flag()
  string  git_file [MAXSTRINGLEN] = ''
  integer git_menu_flag           = 0
  string  git_root [MAXSTRINGLEN] = ''
  if get_current_file_git_parts(git_root, git_file)
    git_menu_flag = _MF_CLOSE_ALL_BEFORE_|_MF_ENABLED_
  else
    git_menu_flag = _MF_GRAYED_|_MF_SKIP_
  endif
  return(git_menu_flag)
end get_git_menu_flag


proc write_profile_error()
  if not profile_error
    Alarm()
    Warn('ERROR writing Git configuration to file "tse.ini": Git will stop ASAP.')
    profile_error = TRUE
  endif
  PurgeMacro(MY_MACRO_NAME)
  abort_issued = TRUE
end write_profile_error

integer proc write_profile_str(string section_name,
                               string item_name,
                               string item_value)
  integer result = WriteProfileStr(section_name,
                                   item_name,
                                   item_value)
  if not result
    write_profile_error()
  endif
  return(result)
end write_profile_str

string proc profile_get(string item)
  string value [MAXSTRINGLEN] = GetProfileStr(VARNAME_CFG_SECTION, item, '')
  case item
    when 'GitExecutable'
      if value == ''
        value = 'git'
      endif
  endcase
  return(value)
end profile_get

menu after_file_save_menu()
  title   = 'Extra action after file save:'
  x       = 10
  y       = 5
  history = menu_history_number
  '&No action'       ,, _MF_CLOSE_AFTER_|_MF_ENABLED_,
    'Do nothing extra after saving a file.'
  'git &add'         ,, _MF_CLOSE_AFTER_|_MF_ENABLED_,
    'Stage the changed version of the current file for the next git commit.'
  'git add + &commit',, _MF_CLOSE_AFTER_|_MF_ENABLED_,
    'Stage and commit the current file if changed (with an empty message).'
end after_file_save_menu

proc profile_set(string item)
  string  cmd         [MAXSTRINGLEN] = ''
  string  new_value   [MAXSTRINGLEN] = ''
  string  old_value   [MAXSTRINGLEN] = GetProfileStr(VARNAME_CFG_SECTION, item, '')
  string  output_line [MAXSTRINGLEN] = ''
  string  response    [MAXSTRINGLEN] = ''
  integer stop                       = FALSE
  new_value = old_value
  case item
    when 'AfterFileSave'
      case old_value
        when 'git add'
          menu_history_number = 2
        when 'git add + commit'
          menu_history_number = 3
        otherwise
          menu_history_number = 1
      endcase
      after_file_save_menu()
      case MenuOption()
        when 1
          new_value = ''
        when 2
          new_value = 'git add'
        when 3
          new_value = 'git add + commit'
      endcase
      cfg_after_file_save = new_value
    when 'GitExecutable'
      new_value = iif(new_value == '', 'git', new_value)
      response  = new_value
      repeat
        stop = not Ask('Git executable to use:', response)
        if not stop
          response = iif(response == '', 'git', response)
          if (response[1]                in '"', "'")
          or (response[length(response)] in '"', "'")
            Warn('DENIED: Supply the git executable without quotes.')
          else
            cmd = create_cmd(_DEFAULT_,
                             'QuotePath', response,
                             ' string'  , '--version',
                             ''         , '',
                             ''         , '',
                             ''         , '',
                             ''         , '',
                             ''         , '')
            if  (   response == 'git'
                 or FileExists(response))
            and (  (GetToken(response, '\', NumTokens(response, '\')) in 'git', 'git.exe')
                or (GetToken(response, '/', NumTokens(response, '/')) in 'git', 'git.exe'))
            and dos_request_response(FALSE, cmd, output_line)
            and Pos('git version ', output_line) == 1
              new_value = response
              stop      = TRUE
            else
              Warn('DENIED: This is not a valid git executable.')
            endif
          endif
        endif
      until stop
      cfg_git_exe = new_value
  endcase
  if new_value <> old_value
    write_profile_str(VARNAME_CFG_SECTION, item, new_value)
  endif
  // config_the_autoload()
end profile_set

menu main_menu()
  title       = 'Git Integration'
  x           = 5
  y           = 5
  history     = menu_history_number

  '&Help ...'  ,
    show_help(),,
    'Read the documentation'
  '&Version ...' [MY_MACRO_VERSION:54],
    browse_website(),
    get_windows_or_linux_menu_flag(),
    'Check the website for a newer version'
  '&Status color ...'  ,
    change_status_color(),,
    'Change the status color'
  'Actions',, _MF_DIVIDE_
  "&List current file's versions ...",
    list_current_file_versions(),
    get_git_menu_flag(),
    "List the current file's git versions."
  'Add and commit &current file ...',
    add_and_commit_current_file(),
    get_git_menu_flag(),
    'Add and commit the current file with a commit message.'
  'Add and commit &working tree ...',
    add_and_commit_working_tree(),
    get_git_menu_flag(),
    'Add and commit the whole working tree with a commit message.'
  'Config',, _MF_DIVIDE_
  '&Git executable ' [profile_get('GitExecutable'):54],
    profile_set('GitExecutable'),
    _MF_DONT_CLOSE_|_MF_ENABLED_,
    'Set which git executable to use. Default assumes "git" in PATH.'
  '&After file save' [profile_get('AfterFileSave'):54],
    profile_set('AfterFileSave'),
    _MF_DONT_CLOSE_|_MF_ENABLED_,
    'Set an "after file save" action'
end main_menu

proc stop_processing_my_key()
  PushKey(-1)
  GetKey()
end stop_processing_my_key

proc WhenPurged()
  // Theoretically I should compensate for the TSE GUI close button bug here,
  // bug in practice the rest of the macro already cleans up temporary disk
  // files properly, so I decided compensating for the bug is not necessary.
  EraseDiskFile(TMP_ASYNC_CMD_FQN)
  EraseDiskFile(TMP_ASYNC_OUT_FQN)
  EraseDiskFile(TMP_SYNC_CMD_FQN)
  EraseDiskFile(TMP_SYNC_OUT_FQN)
  AbandonFile(TMP_ASYNC_CMD_ID)
  AbandonFile(TMP_ASYNC_OUT_ID)
  AbandonFile(TMP_SYNC_CMD_ID)
  AbandonFile(TMP_SYNC_OUT_ID)
end WhenPurged

#ifdef LINUX
  proc setup_tmp_file(string filename)
    integer org_id = GetBufferId()
    integer tmp_id = 0
    tmp_id = CreateTempBuffer()
    if SaveAs(filename, SAVEAS_FLAGS)
      if not Capture('chmod u+rwx,go-rwx ' + QuotePath(filename))
        Warn('Could not set file permissions for'; QuotePath(filename))
      endif
    else
      Warn('Could not write'; QuotePath(filename))
    endif
    GotoBufferId(org_id)
    AbandonFile(tmp_id)
  end setup_tmp_file
#endif

proc WhenLoaded()
  integer org_id                 = GetBufferId()
  string  tmp_dir [MAXSTRINGLEN] = ''

  MY_MACRO_NAME = SplitPath(CurrMacroFilename(), _NAME_)

  #ifdef LINUX
    if compare_versions(VersionStr(), '4.41.35') == FIRST_OLDER_THAN_SECOND
      Alarm()
      Warn('ERROR: In Linux the Git extension needs at least TSE v4.41.35.')
      PurgeMacro(MY_MACRO_NAME)
      abort_issued = TRUE
    endif
  #endif

  if not abort_issued
    VARNAME_CFG_SECTION = MY_MACRO_NAME + ':Config'

    cfg_git_exe         = profile_get('GitExecutable')
    cfg_after_file_save = profile_get('AfterFileSave')

    TMP_ASYNC_CMD_ID = CreateTempBuffer()
    ChangeCurrFilename(MY_MACRO_NAME + ':TmpAsyncCmd', CHANGE_CURR_FILENAME_FLAGS)
    TMP_ASYNC_OUT_ID = CreateTempBuffer()
    ChangeCurrFilename(MY_MACRO_NAME + ':TmpAsyncOut', CHANGE_CURR_FILENAME_FLAGS)
    TMP_SYNC_CMD_ID = CreateTempBuffer()
    ChangeCurrFilename(MY_MACRO_NAME + ':TmpSyncCmd' , CHANGE_CURR_FILENAME_FLAGS)
    TMP_SYNC_OUT_ID = CreateTempBuffer()
    ChangeCurrFilename(MY_MACRO_NAME + ':TmpSyncOut' , CHANGE_CURR_FILENAME_FLAGS)
    GotoBufferId(org_id)

    tmp_dir = GetEnvStr('TMP')
    if tmp_dir == ''
    or not (FileExists(tmp_dir) & _DIRECTORY_)
      tmp_dir = GetEnvStr('TEMP')
      if tmp_dir == ''
      or not (FileExists(tmp_dir) & _DIRECTORY_)
        tmp_dir = ''
      endif
    endif
    if  tmp_dir == ''
    and not WIN32
    and (FileExists('/tmp') & _DIRECTORY_)
      tmp_dir = '/tmp'
    endif
    tmp_dir = RemoveTrailingSlash(tmp_dir)
    if FileExists(tmp_dir) & _DIRECTORY_
      TMP_ASYNC_CMD_FQN = tmp_dir + SLASH + 'Tse_' + MY_MACRO_NAME + '_Async_' + Str(get_process_id()) + '.cmd'
      TMP_ASYNC_OUT_FQN = tmp_dir + SLASH + 'Tse_' + MY_MACRO_NAME + '_Async_' + Str(get_process_id()) + '.log'
      TMP_SYNC_CMD_FQN  = tmp_dir + SLASH + 'Tse_' + MY_MACRO_NAME + '_Sync_'  + Str(get_process_id()) + '.cmd'
      TMP_SYNC_OUT_FQN  = tmp_dir + SLASH + 'Tse_' + MY_MACRO_NAME + '_Sync_'  + Str(get_process_id()) + '.log'
      #ifdef LINUX
        // Because of the Linux-TSE bug for Dos(<not a script>, _RUN_DETACHED_)
        // we can logically not synchronously set a temporary file's
        // permissions when setting up an asynchronous Dos() call.
        // The Linux work-around is to create the temporary files and their
        // permissions at the macro's start-up, and to not delete them during
        // the macro's load time.
        setup_tmp_file(TMP_ASYNC_CMD_FQN)
        setup_tmp_file(TMP_ASYNC_OUT_FQN)
        setup_tmp_file(TMP_SYNC_CMD_FQN )
        setup_tmp_file(TMP_SYNC_OUT_FQN )
      #endif
    else
      abort('No valid folder in TMP or TEMP environment variable.')
    endif
  endif
  if abort_issued
    PurgeMacro(MY_MACRO_NAME)
  else
    Hook(_ON_ABANDON_EDITOR_, WhenPurged     ) // Clean-up when closing editor.
    Hook(_IDLE_             , idle           )
    Hook(_AFTER_FILE_SAVE_  , after_file_save)
  endif
end WhenLoaded

proc Main()
  string key_name [26] = ''
  if not abort_issued
    // Is this a callback from the Status macro?
    if        GetToken(Query(MacroCmdLine), ' ', 1)  == 'callback'
    and Lower(GetToken(Query(MacroCmdLine), ' ', 2)) == 'status'
      // Yes, the user interacted while the cursor was on the status,
      // so now the status macro calls us back reporting the specific action.
      // Note that a KeyName may contain a space, so also get any 5th parameter.
      key_name = Trim(GetToken(Query(MacroCmdLine), ' ', 4) + ' ' +
                      GetToken(Query(MacroCmdLine), ' ', 5))
      case key_name
        when 'F1'
          stop_processing_my_key()
          show_help()
          stop_processing_my_key()
        when 'RightBtn', 'F10', 'Shift F10'
          stop_processing_my_key()
          menu_history_number = 5
          main_menu()
          stop_processing_my_key()
        otherwise
          NoOp()  // Not my key: Let the editor or some other macro process it.
      endcase
    else
      // No, the user executed the macro.
      menu_history_number = 1
      main_menu()
    endif
  endif
end Main

