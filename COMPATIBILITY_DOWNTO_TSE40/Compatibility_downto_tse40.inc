/*
  Include file    Compatibility_downto_tse40.inc
  Author          Carlo.Hogeveen@xs4all.nl
  Compatibility   TSE Pro 4.0 upwards
  Version         1.7 - 13 Apr 2020

  This "include file" supports macro writers to make their macros compatible
  across TSE versions from TSE v4.0 upwards.

  It solves various compatibility issues:

  1 It makes some macros that contain "TSE 4.2 or above"-specific commands
    compatible with "TSE 4.0 and above".

    It does that by implementing TSE 4.2 and TSE 4.4 macro COMMANDS as macro
    PROCEDURES, and by using compiler directives to only use those macro
    procedures for the TSE versions that do not support the macro commands,
    and to use the faster macro commands for the TSE versions that support them.

    Additionally this file starts with a group of compiler directives that make
    the compiler give a clear and specific message if someone compiles the macro
    with a TSE version before TSE 4.0.

  2 compare_versions() can compare VersionStr() values,
    and thus allows us to do more detailed version determination than the
    compiler directives are capable of.
    Unlike compiler directives compare_versions() is used in run-time.

  3 QueryEditState()'s return values.
    In TSE versions newer than v4.4 built-in constant names are defined
    for the components of the return values of the QueryEditState() command.
    The values already existed, only the names are new in TSE versions > v4.4.
    In this include file names are provided in a way that will work for all TSE
    versions from at least v4.0 upwards.

  4 wurn() does not have Warn()'s functionality difference between TSE's GUI
    and console versions. Wurn() displays like the GUI version of Warn() in
    both the GUI and console versions of TSE.

  All the compatibility solutions are documented in more detail further on in
  this file where they are implemented.

  Implemented TSE commands:                                     Macro versions:
    integer proc isAutoLoaded()                                     v1.0
    integer proc MkDir       (string dir)                           v1.0
    integer proc RmDir       (string dir)                           v1.0
    integer proc StartPgm    (string pgm_name, string args,         v1.0
                              string start_dir,
                              integer startup_flags)
    integer proc StrCount    (string needle, string haystack)       v1.0
    integer proc StrFind     (string needle, string haystack,       v1.0
                              string options)
    integer proc StrFind5    (string needle, string haystack,       v1.0
                              string options, integer occurrence,
                              var integer found_length)
    string  proc StrReplace  (string needle, string haystack,       v1.0
                              string replacer, string options)
    string  proc VersionStr  ()                                     v1.1

  Added supporting procedures:
    integer proc compare_versions (string version1,                 v2.0
                                   string version2)

    integer wurn                  (string text)                     v1.0


  NOTA BENE
  As you can see only a very limited number of the newer macro commands have
  been implemented, and of those not all parameters have been implemented.

  Theoretically this file could be included with the include statement
  in macros intended for TSE 4.0 and above.

  Personally I do not include this file, but I manually copy only the TSE
  compatibility check and relevant procedures to those macros for two reasons:
  - To avoid macro compiler Notes about the other procedures not being used.
  - To avoid other users having to install multiple files, risking
    incompatibilities between file versions.

  My purpose for this include file is to have a single, versioned source of truth
  for the latest versions of the implemented procedures.

  Note that out in the wild there are old unversioned versions of these implemented
  procedures: Theoretically they have a version below 1.0.

  The implemented procedures were checked against their use in these macros:
    EolType
    HiliteAll
    KeyboardLogger
    Keys
    Lengths
    Settings
    Status
    Syncase
    Unicode

  History:
    1.0 - 25 Nov 2018
      Initial version.
    1.1 - 25 Jan 2019
      StrFind5() added.
    1.2 - 25 Apr 2019
      StartPgm() added.
      Fixed: Compiler directive for RmDir() was wrong.
    1.3 - 27 Apr 2019
      Backward compatible names for the components of the return values
      of QueryEditState() added.
    1.4 - 8 Jul 2019
      32-bits compiler directive for Linux added.
      compare_versions() added.
    1.5 - 27 Jul 2019
      wurn() added.
    1.6 - 29 Jul 2019
      Fixed VersionStr() for the TSE Pro v4.0 console version of TSE.
    1.7 - 13 Apr 2020
      Added StrCount().
    1.7.1 - 28 Aug 2021
      Bug fixed: For Linux WIN32 should be defined as FALSE instead of TRUE.
*/





// Start of compatibility restrictions and mitigations



/*
  When compiled with a TSE version below TSE 4.0 the compiler reports
  a syntax error and hilights the first applicable line below.

  There is a beta Linux version of TSE that is not bug-free and in which some
  significant features do not work, but all its Linux versions are above
  TSE 4.0, and they all are 32-bits which is what WIN32 actually signifies,
  so for Linux WIN32 should be defined but not TRUE.
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



/*
  From TSE versions newer than v4.4 onwards the edit states that
  QueryEditState() returns are available as names instead of values.

  The below bit of code allows you to use the names on the left
  in at least any version from TSE v4.0 onwards.
*/
#if EDITOR_VERSION > 4400h
  #define STATE_TWOKEY            _STATE_TWOKEY_
  #define STATE_WARN              _STATE_WARN_
  #define STATE_EDITOR_PAUSED     _STATE_EDITOR_PAUSED_
  #define STATE_POPWINDOW         _STATE_POPWINDOW_
  #define STATE_PROCESS_IN_WINDOW _STATE_PROCESS_IN_WINDOW_
  #define STATE_MENU              _STATE_MENU_
  #define STATE_PROMPTED          _STATE_PROMPTED_
#else
  #define STATE_TWOKEY            0x0200
  #define STATE_WARN              0x0400
  #define STATE_EDITOR_PAUSED     0x0800
  #define STATE_POPWINDOW         0x1000
  #define STATE_PROCESS_IN_WINDOW 0x2000
  #define STATE_MENU              0x4000
  #define STATE_PROMPTED          0x3000
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



#if EDITOR_VERSION < 4200h
  integer proc RmDir(string dir)
    Dos('RmDir ' + QuotePath(dir), _START_HIDDEN_)
    return(not DosIOResult())
  end RmDir
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
    StrCount()  v1.0

    Note about TSE's and this StrCount():
    It also counts overlapping strings, so StrCount('aa', 'aaa') returns 2.
  */
  integer proc StrCount(string needle, string haystack)
    integer i      = 0
    integer result = 0
    for i = 1 to Length(haystack)
      if SubStr(haystack, i, Length(needle)) == needle
        result = result + 1
      endif
    endfor
    return(result)
  end StrCount
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



#if TRUE
  /*
    StrFind5() 1.0

    In TSE 4.4 the new function StrFind() was introduced that searches for a
    string in a string.
    However, the fourth parameter "start" was erroneously documented and
    implemented.
    If you use just the first three parameters then there is no problem and you
    can use TSE's StrFind() function and its downward compatibility replacement.
    If you do want to use the 4th and 5th parameter and have it work the same
    way across TSE versions, then use this StrFind5() procedure instead.

    StrFind5()
      Syntax:
        INTEGER StrFind(STRING needle, STRING haystack, STRING options,
                        INTEGER occurrence, VAR INTEGER found_length)
        All parameters are mandatory:
        - "needle" is the string to search for.
        - "haystack" is the string in which to search.
        - "options" control the way needle is interpreted and searched for.

 Invalid options are ignored.
          Valid options are:
            b i w x ^ $
          See the Find() command for a description of these options.
          The presence or absence of the "b" option implies that the search
          starts at the front or the end of the haystack respectively.
        - "occurence" says which occurrence of needle to find (1st, 2nd, ...).
          Any value lower than 1 is treated as 1.
        - "len" is passed back to the caller as the length of the found text,
          or zero.
      Returns:
        The position that needle occurs at in haystack, or zero (FALSE).
      Notes:
        StrFind5() uses the editor's Find() functionality, and therefore
        inherits its behaviour and bugs.
        In TSE's Help see the topics "Find()" and "Searching With Regular
        Expressions" for a description of this behaviour.
        Known bug in StrFind5() caused by TSE's Find() functionality:
          Searching backwards with a regular expression only matches strings
          that are completely before the previous cursor position.
          Examples:
            When the cursor is on the "y" of "cemetery",
            then searching for "y" with options "bx" will not find it.
            When the cursor is on the 3rd "e" of "cemetery",
            then searching for "c.#e" with options "bx" will find "ceme".
            When the cursor is after the "y" of "the cemetery", then searching
            twice (!) for "c.@e" with options "bx" will find "the ceme".
      Examples:
        string haystack[39] = "Now is the time for all good creatures."
        integer r, len
        r = StrFind5('o', haystack, '', 2, len)      // r = 18, len = 1
        r = StrFind5('o', haystack, '', 4, len)      // r = 27, len = 1
        r = StrFind5('o', haystack, '', 5, len)      // r =  0, len = 0
        r = StrFind5('t.#e', haystack, 'x', 2, len)  // r = 12, len = 26
        r = StrFind5('t.#e', haystack, 'bx', 2, len) // r = 12, len = 21
  */
  integer StrFind5_id = 0
  integer proc StrFind5(string needle, string haystack, string options,
                        integer occurrence, var integer found_length)
    integer found_position               = 0
    integer i                            = 0
    string  option                   [1] = ''
    integer org_id                       = GetBufferId()
    string  StrFind5_name [MAXSTRINGLEN] = ''
    integer validated_occurrence         = iif(occurrence < 1, 1, occurrence)
    string  validated_options        [8] = 'g'
    found_length = 0
    for i = 1 to Length(options)
      option = Lower(SubStr(options, i, 1))
      if      (option in 'b', 'i', 'w', 'x', '^', '$')
      and not Pos(option, validated_options)
        validated_options = validated_options + option
      endif
    endfor
    if StrFind5_id
      GotoBufferId(StrFind5_id)
      EmptyBuffer()
    else
      StrFind5_name = SplitPath(CurrMacroFilename(), _NAME_) + ':StrFind5'
      StrFind5_id   = GetBufferId(StrFind5_name)
      if StrFind5_id
        GotoBufferId(StrFind5_id)
        EmptyBuffer()
      else
        StrFind5_id = CreateTempBuffer()
        ChangeCurrFilename(StrFind5_name, _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
      endif
    endif
    InsertText(haystack, _INSERT_)
    for i = 1 to validated_occurrence
      if lFind(needle, validated_options)
        found_position = CurrPos()
        found_length   = Length(GetFoundText())
      else
        found_position = 0
        found_length   = 0
      endif
      if SubStr(validated_options, 1, 1) == 'g'
        validated_options = SubStr(validated_options, 2, MAXSTRINGLEN)
        if Pos('x', validated_options)
          validated_options = validated_options + '+'
        endif
      endif
      if  not Pos('x', validated_options)
      and not Pos('b', validated_options)
        Right()
      endif
    endfor
    GotoBufferId(org_id)
    return(found_position)
  end StrFind5
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

    Newer versions of TSE do not use the "v" any more, but they also do not
    use this pre-TSE v4.4 of VersionStr().

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

/*

// Unit tests for compare_versions().
proc Main()
  if not (compare_versions(''         , ''           ) ==  0) Warn('Test  1 failed.') endif
  if not (compare_versions('.'        , ''           ) ==  0) Warn('Test  2 failed.') endif
  if not (compare_versions('0.0'      , ''           ) ==  0) Warn('Test  3 failed.') endif
  if not (compare_versions('v0.0'     , ''           ) ==  0) Warn('Test  4 failed.') endif
  if not (compare_versions(' v 0 . 0 ', ''           ) ==  0) Warn('Test  5 failed.') endif
  if not (compare_versions(' v 0 . 0 ', 'V0.0'       ) ==  0) Warn('Test  6 failed.') endif
  if not (compare_versions(' v 0 . 0 ', 'V.0'        ) ==  0) Warn('Test  7 failed.') endif
  if not (compare_versions(' v 0 . 0 ', 'V.'         ) ==  0) Warn('Test  8 failed.') endif
  if not (compare_versions('v 1 2'    , 'v1.2'       ) ==  0) Warn('Test  9 failed.') endif
  if not (compare_versions('v a b'    , 'a b'        ) ==  1) Warn('Test 10 failed.') endif
  if not (compare_versions('a b'      , 'v a b'      ) == -1) Warn('Test 11 failed.') endif
  if not (compare_versions('1'        , '3'          ) == -1) Warn('Test 12 failed.') endif
  if not (compare_versions('2'        , '2'          ) ==  0) Warn('Test 13 failed.') endif
  if not (compare_versions('3'        , '1'          ) ==  1) Warn('Test 14 failed.') endif
  if not (compare_versions('1.1'      , '1.01'       ) ==  0) Warn('Test 15 failed.') endif
  if not (compare_versions('1.0'      , '1'          ) ==  0) Warn('Test 16 failed.') endif
  if not (compare_versions('1.1'      , '1'          ) ==  1) Warn('Test 17 failed.') endif
  if not (compare_versions('1.2'      , '2.1'        ) == -1) Warn('Test 18 failed.') endif
  if not (compare_versions('1.20'     , '1.3'        ) ==  1) Warn('Test 19 failed.') endif
  if not (compare_versions('1.2.3.4'  , '01.02.03.04') ==  0) Warn('Test 10 failed.') endif
  if not (compare_versions('1.2.3.4'  , '1.2.4.3'    ) == -1) Warn('Test 21 failed.') endif
  if not (compare_versions('.1'       , '0.1'        ) ==  0) Warn('Test 22 failed.') endif
  if not (compare_versions('..1'      , '0.0.1'      ) ==  0) Warn('Test 23 failed.') endif
  if not (compare_versions('1.'       , '1.0'        ) ==  0) Warn('Test 24 failed.') endif
  if not (compare_versions('1..'      , '1.0.00.000' ) ==  0) Warn('Test 25 failed.') endif
  if not (compare_versions('1.0.00.00', '1..'        ) ==  0) Warn('Test 26 failed.') endif
  if not (compare_versions('1'        , '1 0 00 000' ) ==  0) Warn('Test 27 failed.') endif
  if not (compare_versions('1 0 00 00', '1'          ) ==  0) Warn('Test 28 failed.') endif
  if not (compare_versions('1a'       , '1a'         ) ==  0) Warn('Test 29 failed.') endif
  if not (compare_versions('1 a'      , '1 a'        ) ==  0) Warn('Test 30 failed.') endif
  if not (compare_versions('1.a'      , '1a'         ) ==  0) Warn('Test 31 failed.') endif
  if not (compare_versions(' v 1 . a ', '1a'         ) ==  0) Warn('Test 32 failed.') endif
  if not (compare_versions(' v . 1 a ', '1a'         ) ==  0) Warn('Test 33 failed.') endif
  if not (compare_versions('1a'       , '1b'         ) == -1) Warn('Test 34 failed.') endif
  if not (compare_versions('1b'       , '1a'         ) ==  1) Warn('Test 35 failed.') endif
  if not (compare_versions('v4.00'    , 'v4.00a'     ) == -1) Warn('Test 36 failed.') endif
  if not (compare_versions('v4.00a'   , 'v4.00e'     ) == -1) Warn('Test 37 failed.') endif
  if not (compare_versions('v4.00'    , 'v4.41.10'   ) == -1) Warn('Test 38 failed.') endif
  if not (compare_versions('v4.00e'   , 'v4.41.10'   ) == -1) Warn('Test 39 failed.') endif
  if not (compare_versions('v4.20'    , 'v4.41.10'   ) == -1) Warn('Test 40 failed.') endif
  if not (compare_versions('v4.40'    , 'v4.41.10'   ) == -1) Warn('Test 41 failed.') endif
  if not (compare_versions('v4.40a'   , 'v4.41.10'   ) == -1) Warn('Test 42 failed.') endif
  if not (compare_versions('v4.41.00' , 'v4.41.10'   ) == -1) Warn('Test 43 failed.') endif
  if not (compare_versions('v4.41.01' , 'v4.41.10'   ) == -1) Warn('Test 44 failed.') endif
  if not (compare_versions('one'      , 'two'        ) == -1) Warn('Test 45 failed.') endif
  if not (compare_versions('two'      , 'three'      ) ==  1) Warn('Test 46 failed.') endif
  if not (compare_versions('the first', 'the second' ) == -1) Warn('Test 47 failed.') endif
  if not (compare_versions('the third', 'the fourth' ) ==  1) Warn('Test 48 failed.') endif
  if not (compare_versions('a'        , 'a'          ) ==  0) Warn('Test 49 failed.') endif
  if not (compare_versions('a'        , 'ab'         ) == -1) Warn('Test 50 failed.') endif
  if not (compare_versions('ab'       , 'abc'        ) == -1) Warn('Test 51 failed.') endif
  if not (compare_versions('abc'      , 'ab'         ) ==  1) Warn('Test 52 failed.') endif
  if not (compare_versions('a'        , 'B'          ) == -1) Warn('Test 53 failed.') endif
  if not (compare_versions('B'        , 'c'          ) == -1) Warn('Test 54 failed.') endif
  Warn('The end.')
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

*/



/*
  wurn()  v1.0

  TSE's GUI version displays TSE's Warn() message in a possibly multi-line
  pop-up window, whereas TSE's console version would display it in the single
  status line.

  The wurn() procedure uses Warn() in TSE's GUI version and emulates the GUI's
  Warn() in TSE's console version, so the message looks the same across TSE
  versions.

  wurn() does not implement Warn()'s expression formatting,
  so use wurn(Format( ... )) if you need expression formatting.

  wurn() vs Warn():
  If  you don't need multi-line capability or long-line-wrapping capability,
  and you think the status line is just fine for TSE's console version,
  and you need expression formatting,
  then Warn() is the best option,
  otherwise wurn() or wurn(Format()) is a better choice.

  In the GUI version of TSE the Warn() command displays the formatted result
  string in this undocumented manner:
  - Not on the status line but in a pop-up window.
  - A carriage-return (CR, Chr(13)) character starts a new line.
  - A too long line is wrapped to a new line.
    Taking the pop-up window border and a separating space into account,
    the maximum displayable line length is the screen width minus 4.

  Examples:
    A GUI version of TSE with a screen width of 40 characters would display
      Warn('He sissed:', Chr(13), '':40:'s')
    and
      wurn(Format('He sissed:', Chr(13), '':40:'s'))
    in a pop-up windows as
      He sissed:
      ssssssssssssssssssssssssssssssssssss
      ssss

    A console version of TSE with a screen width of 40 characters would display
      wurn(Format('He sissed:', Chr(13), '':40:'s'))
    the same as the GUI version, but it would display
      Warn('He sissed:', Chr(13), '':40:'s')
    as the single status line:
      He sissed:Xssssssssssssss Press <Escape>
    where X is whatever your console version of TSE displays for a
    carriage-return character (possibly a music symbol)
    and where 26 "s" characters are cut off.
*/

integer wurn_id = 0

integer proc wurn(string warning_text)
  integer line_nr                       = 0
  integer line_parts                    = 0
  integer line_part_nr                  = 0
  string  line_part_text [MAXSTRINGLEN] = ''
  string  line_text      [MAXSTRINGLEN] = ''
  integer max_line_part_length          = 0
  integer org_id                        = 0
  if isGUI()
    Warn(warning_text)
  else
    if wurn_id
      EmptyBuffer(wurn_id)
    else
      org_id  = GetBufferId()
      wurn_id = CreateTempBuffer()
      GotoBufferId(org_id)
    endif
    if wurn_id
      max_line_part_length = Query(ScreenCols) - 4
      for line_nr = 1 to NumTokens(warning_text, Chr(13))
        line_text  = GetToken(warning_text, Chr(13), line_nr)
        line_parts = Length(line_text) / max_line_part_length + 1
        for line_part_nr = 1 to line_parts
          line_part_text = SubStr(line_text,
                                  (line_part_nr - 1) * max_line_part_length + 1,
                                  max_line_part_length)
          AddLine(line_part_text, wurn_id)
        endfor
      endfor
      MsgBoxBuff('Warning', _OK_, wurn_id)
    else
      Warn(warning_text)
    endif
  endif
  return(FALSE)
end wurn

/*

// Test for wurn():

proc Main()
  integer i                = 0
  string  p [MAXSTRINGLEN] = ''
  for i = 10 to 150 by 10
    p = p + Format(i:10:'.')
  endfor
  wurn(Format('Hello world!', Chr(13), p))
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

*/



// End of compatibility restrictions and mitigations.



