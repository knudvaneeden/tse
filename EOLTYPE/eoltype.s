/*
  Macro           EolType
  Author          Carlo.Hogeveen@xs4all.nl
  Compatibility   Windows TSE Pro  v4.0     upwards,
                  Linux   TSE Beta v4.41.34 upwards
  Version         7.1.1   17 Sep 2022


  Purpose:

    This macro helps you avoid, detect, and repair end of line type (*)
    errors (**) when editing non-Windows files with TSE.

    TSE itself already does a reasonable job of editing those non-Windows files
    that exist on disc AND are not empty AND have a correct end-of-line-type.
    It does so implicitly: You don't know a file's end of line type.
    This macro fills the remaining gap: It also lets you CREATE non-Windows
    files, adds the correct end of line type to files that were empty, and
    detects and corrects files with the wrong end of line type. It does so
    explicitly: Default it shows you and warns you about everything concerning
    a file's end of line type.

    You might edit non-Windows files for instance:
    - on a network drive that is mapped to a Unix, Linux or Mac machine.
    - by using a remote-machine-browsing-tool like WinSCP or Total Commander,
      which you have configured to use TSE as its editor.
    - when editing a file you downloaded from the internet.

    Such errors are mitigated and resolved as follows:
    - More non-Windows files are recognized by using configuration rules.
      Rules are a prioritized list of a search strings/options, that when the
      first one matches a full filename, it defines its (new) end of line type.
    - End of line type(s) of the current file can be shown as a status.
      Plural if the loaded and the to-be-saved-with end of line type differ.
    - You can be explicitly warned when a file's end of line type will change,
      both when a file is loaded, as when a file is saved.
    - You can temporarily override a changing end of line type when saving a
      file.

    But with the following restriction:
    - Binary, hidden and system files are completely ignored.

    A side effect of this macro:
      While TSE saves any file in your Windows temporary folder or any
      non-Windows file, TSE's "Create Backups" and "Protected Saves" settings
      are temporarily turned OFF. (***)

    Knowledge:
    - You can think of a file as having:
      - An OLD end of line type if it was loaded from disc.
        - Exception: A disc file with zero length has no end of line type.
        - See TSE's Help for EOLType for how TSE determines the OLD value.
        - This macro bases the OLD value on the first newline in the file.
      - NO end of line type while it exists as a TSE buffer.
        - A non-binary TSE buffer does not contain any end of line characters.
          Internally lines are stored with their lengths.
      - A NEW end of line type it will/would be saved with to disc.
        - Default TSE's "Line-Termination String" setting determines the NEW
          value; when it is defined as "As Loaded" then based on the OLD value.
        - These macro's configuration rules, when they match, overrule the TSE
          setting.
    - When opening a group of files TSE only loads the first file immediately,
      so any load-warnings are only given for the first file until you actually
      access and thus load the rest.


  Installation:
    This macro requires the Status macro to be installed first!
    It requires at least version 1.2 of the Status macro.
    It should be downloadable from the same site as this macro.

    Copy this file (the one you are now reading) to TSE's "mac" folder,
    open the file in TSE, and compile it with TSE's Macro -> Compile menu.

    Execute this macro (menu -> Macro -> Execute) "EOLType" at least once
    to activate it. Optionally you can configure it this way too.


  Configuration:

    Status color
      Its main purpose is to let you change the color of ALL statuses that are
      displayed at the right hand side in the editing window.

    Show statuses
      When enabled, the end of line type(s) of the current file is/are shown on
      the right hand side of the screen. There can be two end of line types:
      the one the file is loaded or created with, and the one the file will be
      saved with. The first one will be unknown "?" when the file was newly
      created or had zero bytes when it was loaded.

    File load warnings
      When enabled AND a file's initial end of line type is known AND its
      initial end of line type differs from the one it will be saved with,
      then you will get a warning of the pending change as soon as the file
      has been loaded.

    File save warnings
      When enabled AND a file's initial end of line type is known AND its
      initial end of line type differs from the one it will be saved with,
      then you will get a warning of the change when the file is saved.
      This warning will not let you abort or override the change,
      and is shown independent of the next configuration option.

    Overridable changes
      When enabled AND a file's initial end of line type is known AND its
      initial end of line type differs from the one it will be saved with,
      then when the file is saved you will be presented with a menu that will
      highlight the proposed new end of line type, and lets you override it.

    Rules for end of line type identification of files:
      For each drive, folder or file that always contains (files with) a
      certain end of line type, you should configure a rule.

      A rule says that when a file's fully qualified name matches the search
      string with search options you define, then its end of line type will
      become the end of line type you define.

      You can configure a whole list of such rules.
      The same rules as for TSE's regular Find apply, but for a file's full
      drive:/path/filename.extension instead of a line.
      While all Find options are allowed, only these are used: b, i, w, x, ^, $.
      For each file you edit the list is processed top-to-bottom, and the first
      match determines the end of line type definition.
      You can explicitly order the list.
      Tip/trick:
        You can configure the last rule as a regular expression search for an
        empty string: This always succeeds, and thus allows you to define your
        own overall default end of line type.

      The assumption is that from a Windows machine TSE will access a file
      from/for a Unix/Linux/Mac machine in one of these three ways:
      - You have configured a specific Windows network drive to point to a
        remote non-Windows machine.
      - You manually copy Unix/Linux/Mac files to a specific folder on your
        local Windows machine, and back.
      - You have configured a tool, that can browse the filesystem of a remote
        Unix, Linux or Mac machine, to use TSE as its external editor.
        When such a tool (WinSCP, Total Commander, ...) edits a browsed-to
        remote file, it first transfers the remote file to a specific local
        folder which this macro can use as an identifier, and then it calls an
        external editor (which you configured to be TSE) to edit the local
        file, and when you are done the tool automatically transfers the
        local file back to the remote folder.

      Example rules for drive and folder identification:
      - "U:\" if that is your network drive mapped to a remote Unix machine.
      - "C:\Unix" if that is your manually maintained folder.
      - "\Temp\scp" or "\\Temp\\scp[0-9]#\\sessionname" when you have
        configured WinSCP's SFTP browser to use TSE as its external editor and
        optionally have its "Storage" configured to use the session name too.
        Note that the second search string needs an "x" in its search options.
        Note that what WinSCP's "Login" screen calls a "site", WinSCP's
        "Storage" preference calls a "session name"; by using it you can
        configure site-specific end of line types.
      - "\Temp\_tc" and "\Temp\_tcx\" when you have configured Total Commander's
        SFTP browser and use <Enter> to edit a file.
      - "\Secure FTP\sitename\" when you have configured Total Commander's
        SFTP browser to use TSE as it's external editor and use "F4 - Edit".
        This last way is site-specific: It lets you configure different
        end of line types for different sites.
        NB: SFTP <> FTPS, and I did not test Total Commander's FTPS browser.


  (*) What is an end of line type?

    When a plain text file is saved on a Windows machine, then Notepad, TSE,
    and all other Windows plain text editors add two invisible characters to
    the end of each line.

    For typewriter-historical reasons these two characters are called a
    carriage return and a line feed.

    The standard abbrevitions for these character names are CR and LF.

    Their character codes are 13 and 10 in decimal, and 0D and 0A in hexadecimal
    notation.

    However, when a file is saved on a Unix or Linux or modern MAC OS machine,
    then their editors only add an invisible line feed character to the end of
    each line. No carriage return.

    And editors on old Mac(intosch) machines used to add only an invisible
    carriage return character to the end of each line. No line feed.

    If you open a TSE file in both binary and hexadecimal mode by prefixing the
    filename with "-b -h ", then you can see these otherwise invisible
    characters as 0D and 0A in the hexadecimal pane.

    There is an article on Wikipedia about newline implementations:
      https://en.wikipedia.org/wiki/Newline

    Like TSE itself, this macro does not understand other newlines
    than CR, LF and CR+LF.


  (**) End of line type errors

    It differs per application how aware it is of handling non-native
    end of line types. My main errors used to be in unix scripts: they will
    not run if they contain a Windows carriage return character.

    TSE itself has no problem with EXISTING non-Windows files.

    After loading and thus recognizing an existing non-Windows file, TSE also
    has no problem automatically saving it back with its original end of line
    type, provided that TSE's menu "Options -> Full Configuration -> System/File
    Options -> Line-Termination String" is set to "As Loaded".

    Therefore the most obvious occurrences of an end of line type error happen,
    when an empty file is loaded and when TSE itself creates a file.
    Empty files have no lines yet, so TSE itself has no way of determining what
    end of line type to use, so it defaults to the Windows end of line type,
    which might be wrong.
    When TSE itself creates a file then there is no source file to determine
    the end of line type from, so the same default is applied, which might
    likewise be wrong.

    By using this macro you can configure a solution.

    In practice non-Windows files are typically located on certain network
    drives, or viewed and edited in the temporary folder of an application
    that accesses the non-Windows files. The temporary folder typically
    contains (an abbreviation of) the name of the application, and likely
    even contains a reference to the remote system you are accessing.

    By configuring this macro to recognize these non-Windows network drives
    and/or temporary folders, TSE can save (formerly) empty and new files
    with their correct end of line type, and even report and repair existing
    files which had an incorrect end of line type.


  (***) No "Create Backups" and "Protected Saves" for temporary and non_windows
        files:

    Problem:
      When a remote system browsing tool like WinSCP or Total Commander uses
      TSE to edit a temporarily transferred file in a temporary folder, then
      the TSE setting "Create backups" does not make sense, and the TSE
      setting "Protected Saves" MUST temporarily be turned off. The latter
      because "Protected Saves" would actually create a NEW file that would
      not be transferred back after editing it, thus ignoring our editing.
      I currently cannot test if, while "Protected Saves" is on, TSE can save
      non-Windows files to a network drive that is mapped to a non-Windows
      machine, but this macro's history makes me suspect it cannot.

    Solution:
      While TSE saves any file in the Windows temporary folder or any
      non-Windows file, TSE's "Create Backups" and "Protected Saves"
      settings are turned OFF. In practice this solves the problem.

    Solution notes:
      To determine any temporary folders the existing values of the
      standard Windows environment variables TEMP and TMP are used,
      just like e.g. WinSCP and Total Commander do.
      Strictly speaking the solution is inaccurate: only "Protected Saves"
      needs to be turned off, and only when needed for this macro. However,
      a totally correct solution would need complex user configuration that
      would be hard to understand. IMHO the current solution is simple,
      elegant, and just what I would want to happen anyway.



  History:
    First release: 5 July 1999

    In version 1 you could only specify filename parts starting with a drive
    letter, in version 2 you can specify any part of a filename that
    indicates that it is a unix file.

    In version 2 the EolType.dat file is created in TSE's "mac" folder
    instead of in the TSE folder.

    Version 3 cleans up some code, and displays a warning when the saved
    end of line type will differ from the loaded end of line type.

    Version 4 makes everything configurable and adds optionally overriding
    the EndOfLineType default.

    In version 5 EolType.dat was changed to EolType.cfg, and the default
    configuration was changed to not give info or ask questions about
    the end of line type.

    In version 5.1 EolType uses TSE's Beep variable to determine whether to
    make a sound.

    6.0.0 - 9 march 2018
      This is a complete rewrite to take advantage of the new Status macro.
      Major changes:
      - It can display a file's previous and next end of line type as statuses.
      - The strings that identify a non-Windows file now have search options,
        may now contain spaces, may now be regular expressions, and may now be
        provided for all end of line types, including the "As Loaded" pseudo-type.
      - The old macro's own .cfg configuration file is no longer used.
        Instead two sections in TSE's .ini profile file are used.
        Any old configuration settings are automatically converted.

    6.0.1 - 12 March 2018
      Textual tweaks only.

    6.0.2 - 15 April 2018
      Small bug fix:
        Did not supply the callback parameter when calling the Status macro,
        which went unnoticed because of a bug in the Status macro.
        Fixed in Status macro 1.1.1.

    6.0.3 - 19 Nov 2018
      Documentation only: Versioned the isAutoLoaded() and StrFind() procedures.

    6.0.4 - 4 Jan 2019
      Tiny code improvement: moved stop_processing_my_key() up a statement.

    7.0     6 Feb 2019
      Correctly recognizing the end-of-line-type of UTF-16 and UTF-32 files.

    7.1     26 Apr 2020
      Added support for Linux TSE Beta v4.41.34 upwards.

    7.1.1   17 Sep 2022
      Fixed incompatibility with TSE's '-i' command line option
      and the TSELOADDIR environment variable.

  Todo:
  - Must:
  - Should:
    - There might in some cases be a problem if both TSE and this macro
      configured a file's new end of line type as "As Loaded".
  - Could:
    - Add explicitly changing the current end of line type as a callback action?
  - Would/won't.
    - Implement a completely correct solution for "Create Backups"
      and "Protected Saves" for temporary files.



  Technical notes for the maintenance of this macro:

    Note to self:
    TSE's EOLType variable has NO impact on loading or editing a file.
    TSE's EOLType variable has NO impact on loading or editing a file.
    TSE's EOLType variable has NO impact on loading or editing a file.
    I told you so three times.

    In TSE, in a loaded non-binary file, newline characters do not exist. They
    have been stripped. Internally TSE works with line lengths and therefore
    has no need for newline characters. When loading the file TSE did determine
    one end of line type for the whole file, but that value is inaccessible
    from the macro language.

    The only way this macro has to determine an existing file's end of line
    type, is to read part of the file again but with low-level commands that
    allow it to see newline characters. Because we do not want it to read the
    whole file again, the first newline determines the file's old end of line
    type. Note that this algorithm differs from TSE's documented algorithm,
    but the results should only differ for files with mixed newline types,
    which and should be extremely rare and does not really matter anyway.

    Both TSE and this macro cannot determine an existing end of line type for
    files with zero length and files that are newly created in TSE.
    In this situation TSE just defaults to CR+LF. This macro first applies the
    rules you configured, and when they do not apply defaults to CR+LF.

    The search strings and options that define a file's new end of line type
    are maintained in a file and two buffers, and have a slightly different
    format in each to balance performance, readability and robustness where
    needed. All three use fixed length columns.
    Noteworthy subtle (!) differences:
    - The profile file (tse.ini) should normally not be edited by a user, so
      performance has some claim over readability, but it can be edited by a
      user nonetheless, so some concessions are needed:
      - The end of line type is represented as a single digit.
      - The search option is unquoted.
      - The search string is necessarily quoted, because the user-editable
        profile file does not necessarily retain spaces at the end of a line.
    - The rules_id buffer (used by the running macro, so performace is king):
      - The end of line type is represented as a single digit.
      - The search option is unquoted.
      - The search string is unquoted.
    - The lst_id buffer that is only used during configuration by the user.
      The user views this buffer, so here readable is more important:
      - The end of line type is represented by its character representation.
      - The search option is only quoted if empty.
      - The search string is only quoted if empty or containing spaces.
*/





// Compatibility restriction and mitigations

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

#if EDITOR_VERSION < 4400h
  /*
    isAutoLoaded() 1.0

    This proc implements TSE 4.4's isAutoLoaded() function for older TSE
    versions. This proc differs in that here no parameter is allowed,
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
      StrReplace() refers to "string".
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


// Compatibility restriction and mitigations





// Global constants

string BOM_UTF8     [3] = Chr(239) + Chr(187) + Chr(191)            // EF BB BF
string BOM_UTF16_BE [2] = Chr(254) + Chr(255)                       // FE FF
string BOM_UTF16_LE [2] = Chr(255) + Chr(254)                       // FF FE
string BOM_UTF32_BE [4] = Chr(  0) + Chr(  0) + Chr(254) + Chr(255) // 00 00 FE FF
string BOM_UTF32_LE [4] = Chr(255) + Chr(254) + Chr(0  ) + Chr(0  ) // FF FE 00 00

string my_macro_version              [5] = '7.1.1'
string status_macro_name             [6] = 'Status'
string status_macro_required_version [3] = '1.1'





// Global variables

integer are_save_settings_changed                  = FALSE
integer check_id                                   = 0
integer current_column                             = 0
integer current_id                                 = 0
integer current_line                               = 0
integer delay_time                                 = 0
string  env_temp                    [MAXSTRINGLEN] = ''
string  env_tmp                     [MAXSTRINGLEN] = ''
string  warning_buttons             [MAXSTRINGLEN] = '[&OK]'
integer warnings_skip_rest                         = FALSE
integer files_id                                   = 0
integer have_load_warnings                         = TRUE
integer have_save_warnings                         = TRUE
integer have_overridable_changes                   = TRUE
string  list_action                 [MAXSTRINGLEN] = ''
integer menu_history_selector                      = 0
string  my_macro_name               [MAXSTRINGLEN] = ''
integer no_override_choice                         = 0
integer old_makebackups                            = 0
integer old_protectedsaves                         = 0
integer old_tse_eoltype                            = 0
integer overriding_eoltype                         = 0
integer show_statuses                              = TRUE
integer rules_id                                   = 0
string  varname_cfg_choices_section [MAXSTRINGLEN] = ''
string  varname_cfg_rules_section   [MAXSTRINGLEN] = ''
string  varname_load_warning_given  [MAXSTRINGLEN] = ''
string  varname_new_eoltype         [MAXSTRINGLEN] = ''
string  varname_old_eoltype         [MAXSTRINGLEN] = ''
string  varname_prev_path           [MAXSTRINGLEN] = ''



// Procedures

integer proc is_eligible_file()
  integer result = TRUE
  if BufferType() <> _NORMAL_
  or BinaryMode()
    result = FALSE
  endif
  return(result)
end is_eligible_file

proc config_the_autoload()
  if show_statuses
  or have_load_warnings
  or have_save_warnings
  or have_overridable_changes
    if not isAutoLoaded()
      AddAutoLoadMacro(my_macro_name)
    endif
  else
    if isAutoLoaded()
      DelAutoLoadMacro(my_macro_name)
    endif
  endif
end config_the_autoload

string proc quote(string s)
  string result [MAXSTRINGLEN] = s
  if result == ''
    result = '""'
  else
    result = QuotePath(result)
  endif
  return(result)
end quote

string proc unquote(string s)
  string result [MAXSTRINGLEN] = s
  if  SubStr(result,              1, 1) == '"'
  and SubStr(result, Length(result), 1) == '"'
    result = SubStr(result, 2, Length(result) -2)
  endif
  return(result)
end unquote

proc exec_macro(string macro_cmd_line)
  string  status_macro_current_version [MAXSTRINGLEN] = ''
  string  extra_version_text           [MAXSTRINGLEN] = ''
  integer ok                                          = TRUE
  ok = ExecMacro(macro_cmd_line)
  if ok
    status_macro_current_version = GetGlobalStr(status_macro_name + ':Version')
    if compare_versions(status_macro_current_version,
                        status_macro_required_version) == -1
      ok                 = FALSE
      extra_version_text = 'at least version ' +
                           status_macro_required_version + ' of '
    endif
  endif
  if not ok
    Warn('The "', my_macro_name, '" macro needs ', extra_version_text, 'the "',
         status_macro_name, '" macro to be installed!')
    PurgeMacro(my_macro_name)
  endif
end exec_macro

string proc eoltype_num_to_txt(integer num, integer for_new_eoltype)
  string txt [9] = 'Error!'
  case num
    when 3
      txt = 'CR+LF'
    when 2
      txt = 'LF'
    when 1
      txt = 'CR'
    when 0
      txt = iif(for_new_eoltype, 'As Loaded', '?')
  endcase
  return(txt)
end eoltype_num_to_txt

integer proc eoltype_txt_to_num(string txt)
  integer num = 0   // Unknown or As Loaded.
  case txt
    when 'CR+LF'
      num = 3
    when 'LF'
      num = 2
    when 'CR'
      num = 1
  endcase
  return(num)
end eoltype_txt_to_num

proc set_file_src_dst_types(var string file_src_type, var string file_dst_type)
    integer max_length = 0
    if FileExists(CurrFilename())
      file_src_type = 'LOAD'
    else
      file_src_type = 'CREATE'
    endif
    if BrowseMode()
    or Query(BufferFlags) & _READ_ONLY_LOCKING_
      file_dst_type = 'CONFIGURED'
    else
      file_dst_type = 'SAVE'
    endif
    max_length = Max(Length(file_src_type), Length(file_dst_type))
    file_src_type = Format(file_src_type:max_length)
    file_dst_type = Format(file_dst_type:max_length)
end set_file_src_dst_types

proc give_warning(string  warning_title,
                  integer old_eoltype,
                  integer new_eoltype)
  string  file_dst_type [10] = ''
  string  file_src_type [10] = ''
  integer response           = 0
  if  not warnings_skip_rest
  and     old_eoltype  > 0
  and     old_eoltype <> new_eoltype
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    if Query(Beep)
      Alarm()
    endif
    set_file_src_dst_types(file_src_type, file_dst_type)
//  Set(X1,  5)
//  Set(Y1, 10)
    response = MsgBoxEx(warning_title,
                        'File ' + file_src_type + ' format: '
                        + eoltype_num_to_txt(old_eoltype, FALSE)
                        + Chr(13)
                        + 'File SAVE format: '
                        + eoltype_num_to_txt(new_eoltype, TRUE ),
                        warning_buttons)
    if response == 2
      warnings_skip_rest = TRUE
    endif
    warning_buttons = '[&OK];[&All OK]'
  endif
end give_warning

integer proc get_new_eoltype()
  string  curr_file_name [MAXSTRINGLEN] = CurrFilename()
  integer eoltype_int                   = -1
  string  eoltype_str    [MAXSTRINGLEN] = ''
  integer org_id                        = GetBufferId()
  string  search_options            [6] = ''
  string  search_string  [MAXSTRINGLEN] = ''
  if Lower(SplitPath(curr_file_name, _DRIVE_|_PATH_)) == GetBufferStr(varname_prev_path)
    eoltype_str = GetBufferStr(varname_new_eoltype)
  else
    eoltype_str = ''
    SetBufferStr(varname_prev_path, SplitPath(curr_file_name, _DRIVE_|_PATH_))
  endif
  if eoltype_str == ''
    GotoBufferId(rules_id)
    BegFile()
    repeat
      search_options = Trim(GetText( 3, 6))
      search_string  = Trim(GetText(10, MAXSTRINGLEN))
      if  StrFind(search_string, curr_file_name, search_options)
      and (GetText(1, 1) in '0' .. '3')
        eoltype_int = Val(GetText(1, 1))
      endif
    until eoltype_int <> -1
       or not Down()
    if eoltype_int == -1
      eoltype_int = 3
    endif
    SetBufferStr(varname_new_eoltype, Str(eoltype_int))
    GotoBufferId(org_id)
  else
    eoltype_int = Val(eoltype_str)
  endif
  return(eoltype_int)
end get_new_eoltype

proc del_old_eoltype()
  DelBufferVar(varname_old_eoltype)
end del_old_eoltype

integer proc determine_old_eoltype()
  integer bytes_read                 = 0
  string  character_code_format [13] = ''
  integer char_size                  = 0
  integer codepointish               = 0
  integer cr_counter                 = 0
  string  data                 [255] = ''
  integer eol_type                   = 0
  integer first_low_byte_pos         = 0
  integer handle                     = 0
  integer i                          = 0
  integer j                          = 0
  integer lf_counter                 = 0
  string  org_fqn     [MAXSTRINGLEN] = CurrFilename()
  integer org_id                     = GetBufferId()
  integer seventy_percent_for_mod_2  = 0
  integer seventy_percent_for_mod_4  = 0
  integer signifier                  = 0
  integer step                       = 0
  integer zeros_at_mod_2_is_0        = 0
  integer zeros_at_mod_2_is_1        = 0
  integer zeros_at_mod_4_is_0        = 0
  integer zeros_at_mod_4_is_1        = 0
  integer zeros_at_mod_4_is_2        = 0
  integer zeros_at_mod_4_is_3        = 0
  // Read a line of binary data without setting of any hooks.
  GotoBufferId(check_id)
  EmptyBuffer()
  handle = fOpen(org_fqn, _OPEN_READONLY_)
  if handle <> -1
    bytes_read = fRead(handle, data, 255)
    while bytes_read > 0
    and   CurrLineLen() + bytes_read < MAXLINELEN
      InsertText(data, _INSERT_)
      bytes_read = fRead(handle, data, 255)
    endwhile
    fClose(handle)
  endif
  // Try determining the character code format the easy way
  if     GetText(1, 4) == BOM_UTF32_BE
    character_code_format = 'UTF-32BE'
  elseif GetText(1, 4) == BOM_UTF32_LE
    character_code_format = 'UTF-32LE'
  elseif GetText(1, 3) == BOM_UTF8
    character_code_format = 'UTF-8'
  elseif GetText(1, 2) == BOM_UTF16_BE
    character_code_format = 'UTF-16BE'
  elseif GetText(1, 2) == BOM_UTF16_LE
    character_code_format = 'UTF-32LE'
  endif
  // Else try determining the character code format the hard way
  if character_code_format == ''
    for i = 1 to CurrLineLen()
      if CurrChar(i) == 0
        if i mod 2 == 0
          zeros_at_mod_2_is_0 = zeros_at_mod_2_is_0 + 1
        else
          zeros_at_mod_2_is_1 = zeros_at_mod_2_is_1 + 1
        endif
        case i mod 4
          when 0
            zeros_at_mod_4_is_0 = zeros_at_mod_4_is_0 + 1
          when 1
            zeros_at_mod_4_is_1 = zeros_at_mod_4_is_1 + 1
          when 2
            zeros_at_mod_4_is_2 = zeros_at_mod_4_is_2 + 1
          when 3
            zeros_at_mod_4_is_3 = zeros_at_mod_4_is_3 + 1
        endcase
      endif
    endfor
    seventy_percent_for_mod_2 = (((CurrLineLen() * 70) / 100) / 2)
    seventy_percent_for_mod_4 = (((CurrLineLen() * 70) / 100) / 4)
    if     zeros_at_mod_4_is_1 > seventy_percent_for_mod_4
    and    zeros_at_mod_4_is_2 > seventy_percent_for_mod_4
    and    zeros_at_mod_4_is_3 > seventy_percent_for_mod_4
      character_code_format = 'UTF-32BE'
    elseif zeros_at_mod_4_is_2 > seventy_percent_for_mod_4
    and    zeros_at_mod_4_is_3 > seventy_percent_for_mod_4
    and    zeros_at_mod_4_is_0 > seventy_percent_for_mod_4
      character_code_format = 'UTF-32LE'
    elseif zeros_at_mod_2_is_1 > seventy_percent_for_mod_2
      character_code_format = 'UTF-16BE'
    elseif zeros_at_mod_2_is_0 > seventy_percent_for_mod_2
      character_code_format = 'UTF-16LE'
    else
      character_code_format = 'ASCII_ANSI_UTF8'
    endif
  endif
  case character_code_format
    when 'UTF32BE'
      first_low_byte_pos =  4
      char_size          =  4
      step               = -1
    when 'UTF32LE'
      first_low_byte_pos =  1
      char_size          =  4
      step               =  1
    when 'UTF16BE'
      first_low_byte_pos =  2
      char_size          =  2
      step               = -1
    when 'UTF16LE'
      first_low_byte_pos =  1
      char_size          =  2
      step               =  1
    otherwise
      first_low_byte_pos =  1
      char_size          =  1  // Here this works for UTF-8 too.
      step               =  1
  endcase
  for i = first_low_byte_pos to CurrLineLen() by char_size
    codepointish = 0 // Not real codepoint, but surrogates irrelevant here.
    signifier    = 1
    for j = i to (i + (char_size * step) - step) by step
      codepointish = CurrChar(j) * signifier + codepointish
      signifier    = signifier * 256
    endfor
    case codepointish
      when 13
        cr_counter = cr_counter + 1
      when 10
        lf_counter = lf_counter + 1
    endcase
  endfor
  eol_type = iif(cr_counter, 1, 0) + iif(lf_counter, 2, 0)
  GotoBufferId(org_id)
  SetBufferStr(varname_old_eoltype, Str(eol_type))
  return(eol_type)
end determine_old_eoltype

integer proc get_old_eoltype()
  integer result_int      = 0
  string  result_str [12] = GetBufferStr(varname_old_eoltype)
  if result_str == ''
    result_int = determine_old_eoltype()
  else
    result_int = Val(result_str)
  endif
  return(result_int)
end get_old_eoltype

proc set_override_choice()
  /*
    Menu choices 1, 5 and 10 are unchoosable.
    Therefore this proc translates choices 2, 3, 4, 6, 7, 8, 9
                    to overriding_eoltypes 1, 2, 3, 4, 5, 6, 7.
  */
  overriding_eoltype = MenuOption() - 1
  if overriding_eoltype > 4
    overriding_eoltype = overriding_eoltype - 1
  endif
end set_override_choice

menu override_menu()
  title = "Saving file: Optionally override its End Of Line type"
  x = 5
  y = 10
  history = no_override_choice
  command = set_override_choice()
  '',, Skip
  'This file with only &CR     (Old operating systems)'
  'This file with only &LF     (Unix, Linux, Mac)'
  'This file with &Both CR+LF  (Microsoft)'
  '',, Skip
  'All files with only CR      (&Old operating systems)'
  'All files with only LF      (&Unix/Linux/Mac)'
  'All files with Both CR+LF   (&Microsoft)'
  'All files      &As loaded'
end override_menu

proc on_file_save()
  integer old_eoltype  = 0
  integer new_eoltype  = 0
  are_save_settings_changed = FALSE
  if is_eligible_file()
    old_tse_eoltype = Query(EOLType)
    old_eoltype     = get_old_eoltype()
    new_eoltype     = get_new_eoltype()
    Set(EOLType, new_eoltype)
    if  old_eoltype  >  0
    and new_eoltype  <> old_eoltype
    and BufferType() == _NORMAL_
      if have_save_warnings
        give_warning('Saving file', old_eoltype, new_eoltype)
      endif
      if have_overridable_changes
        if overriding_eoltype == 0
          UpdateDisplay()
          no_override_choice = new_eoltype + 1
          override_menu()
        endif
        if overriding_eoltype < 4
          Set(EOLType, overriding_eoltype)
          overriding_eoltype = 0
        else
          if overriding_eoltype == 7
            Set(EOLType, 0)
          else
            Set(EOLType, overriding_eoltype - 3)
          endif
        endif
      endif
    endif
    if (Query(EOLType) in 1, 2)
    or Pos(env_temp, Lower(CurrFilename())) == 1
    or Pos(env_tmp , Lower(CurrFilename())) == 1
      old_makebackups    = Set(MakeBackups   , OFF)
      old_protectedsaves = Set(ProtectedSaves, OFF)
      are_save_settings_changed = TRUE
    endif
    del_old_eoltype()
    current_id = 0
  endif
end on_file_save

proc after_file_save()
  if is_eligible_file()
    Set(EOLType       , old_tse_eoltype   )
  endif
  if are_save_settings_changed
    Set(MakeBackups   , old_makebackups   )
    Set(ProtectedSaves, old_protectedsaves)
    are_save_settings_changed = FALSE
  endif
end after_file_save

proc on_first_edit()
  integer new_eoltype = 0
  integer old_eoltype = 0
  if is_eligible_file()
    old_eoltype = get_old_eoltype()
    new_eoltype = get_new_eoltype()
    if  have_load_warnings
    and not GetBufferInt(varname_load_warning_given)
      SetBufferInt(varname_load_warning_given, TRUE)
      give_warning('Loaded file', old_eoltype, new_eoltype)
    endif
  endif
end on_first_edit

string proc eol_types_to_status_text(integer old_eoltype, integer new_eoltype)
  string result [30] = ''
  if old_eoltype == new_eoltype
    result = eoltype_num_to_txt(new_eoltype, TRUE)
  else
    result = eoltype_num_to_txt(old_eoltype, FALSE) +
             ' -> '                                 +
             eoltype_num_to_txt(new_eoltype, TRUE )
  endif
  return(result)
end eol_types_to_status_text

proc idle()
  integer old_eoltype = 0
  integer new_eoltype = 0
  warnings_skip_rest = FALSE
  warning_buttons    = '[&OK]'
  overriding_eoltype = 0
  if is_eligible_file()
    if  GetBufferId() == current_id
    and CurrLine()    == current_line
    and CurrCol()     == current_column
      delay_time         = delay_time - 1
      if delay_time <= 0
        old_eoltype = get_old_eoltype()
        new_eoltype = get_new_eoltype()
        if show_statuses
          exec_macro(status_macro_name + ' ' + my_macro_name + ':EOLType,callback ' +
                    eol_types_to_status_text(old_eoltype, new_eoltype))
        endif
        delay_time = 90   // 5 seconds till next idle update.
      endif
    else
      current_id     = GetBufferId()
      current_line   = CurrLine()
      current_column = CurrCol()
      delay_time     = 1  // ASAP update because there was an action.
    endif
  endif
end idle

proc save_old_config_toggle_item(integer is_item_true, string item_name)
  string old_item_value [9] = GetProfileStr(varname_cfg_choices_section, item_name, 'Enabled')
  if not (old_item_value in 'Enabled', 'Disabled')
  or     (is_item_true <> (old_item_value == 'Enabled'))
    WriteProfileStr(varname_cfg_choices_section, item_name, iif(is_item_true, 'Enabled', 'Disabled'))
  endif
end save_old_config_toggle_item

proc save_old_config()
  integer i                      = 0
  integer max_item_number_length = 10
  integer org_id                 = GetBufferId()
  save_old_config_toggle_item(show_statuses           , 'ShowStatuses')
  save_old_config_toggle_item(have_load_warnings     , 'EarlyWarnings')
  save_old_config_toggle_item(have_save_warnings      , 'LateWarnings')
  save_old_config_toggle_item(have_overridable_changes, 'OverridableChanges')
  GotoBufferId(rules_id)
  if FileChanged()
    max_item_number_length = Length(Str(NumLines()))
    RemoveProfileSection(varname_cfg_rules_section)
    BegFile()
    repeat
      if CurrLineLen()
        i = i + 1
        WriteProfileStr(varname_cfg_rules_section,
                        Format('Item', i:max_item_number_length:'0'),
                        GetText(1, CurrLineLen()))
      endif
    until not Down()
  endif
  GotoBufferId(org_id)
end save_old_config

integer proc load_old_version_config()
  integer i                              = 0
  integer old_cfg_id                     = 0
  integer org_id                         = GetBufferId()
  string  unix_substrings [MAXSTRINGLEN] = ''
  old_cfg_id = CreateTempBuffer()
  if old_cfg_id
    show_statuses = TRUE // Didn't exist in old config: The default is Enabled.
    if LoadBuffer(SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + '.cfg')
      BegFile()
      unix_substrings = Lower(GetText(1,CurrLineLen()))
      if Down()
        // The disable_eoltype_macro_yn setting is implicit in the new version.
        if Down()
          have_load_warnings = (Lower(GetText(1,CurrLineLen())) == 'y')
          if Down()
            have_save_warnings = (Lower(GetText(1,CurrLineLen())) == 'y')
            if Down()
              have_overridable_changes = (Lower(GetText(1,CurrLineLen())) == 'y')
            endif
          endif
        endif
      endif
      if unix_substrings <> ''
        GotoBufferId(rules_id)
        for i = 1 to NumTokens(unix_substrings, ' ')
          AddLine('2 i      ' + GetToken(unix_substrings, ' ', i))
        endfor
      endif
    endif
    save_old_config()
    GotoBufferId(org_id)
    AbandonFile(old_cfg_id)
  else
    Warn('EOLType error: Could not create temp buffer 2.')
  endif
  return(old_cfg_id)
end load_old_version_config

integer proc load_config()
  string  item_name  [MAXSTRINGLEN] = ''
  string  item_value [MAXSTRINGLEN] = ''
  integer org_id                    = GetBufferId()
  integer result                    = TRUE
  // Suppress correct compiler warning for deliberately not using "item_name".
  item_name = item_name
  if GetProfileStr(varname_cfg_choices_section, 'ShowStatuses', '') == ''
    WriteProfileStr(varname_cfg_choices_section, 'ShowStatuses', 'Enabled')
    result = load_old_version_config()

  else
    show_statuses            = (GetProfileStr(varname_cfg_choices_section,
                                              'ShowStatuses',
                                              'Enabled')          == 'Enabled')
    have_load_warnings      = (GetProfileStr(varname_cfg_choices_section,
                                              'EarlyWarnings',
                                              'Enabled')          == 'Enabled')
    have_save_warnings       = (GetProfileStr(varname_cfg_choices_section,
                                              'LateWarnings',
                                              'Enabled')          == 'Enabled')
    have_overridable_changes = (GetProfileStr(varname_cfg_choices_section,
                                              'OverridableChanges',
                                              'Enabled')          == 'Enabled')
    GotoBufferId(rules_id)
    LoadProfileSection(varname_cfg_rules_section)
    while GetNextProfileItem(item_name, item_value)
      AddLine(Format(        SubStr(item_value,  1,            9),
                     unquote(SubStr(item_value, 10, MAXSTRINGLEN))))
    endwhile
    GotoBufferId(org_id)
  endif
  config_the_autoload()
  return(result)
end load_config

string proc validate_search_options(string search_options)
  integer i                 = 0
  string  result        [7] = ''
  string  search_option [1] = ''
  for i = 1 to Length(search_options)
    search_option = Lower(SubStr(search_options, i, 1))
    if      Pos(search_option, 'biwx^$')
    and not Pos(search_option, result)
      result = result + search_option
    endif
  endfor
  return(result)
end validate_search_options

Datadef list_help_text
  "If a file's full name matches with any search strings and search options"
  "in these rules, then, when saved, the file will get the end of line type"
  "of the top-most matching rule."
  " "
  "F1             Show this help text."
  "Ctrl Ins       Add a new rule above the current one."
  "Ins            Add a new rule below the current one."
  "Del            Delete the current rule."
  "Enter          Modify the current rule."
  "Arrows         Go to the previous/next rule."
  "Ctrl Arrows    Move the rule up/down, in/decreasing its priority."
  "Escape         Exit the list of rules."
end list_help_text

proc list_help()
  integer hlp_id    = 0
  integer old_attr  = 0
  integer org_id    = GetBufferId()
  hlp_id = CreateTempBuffer()
  InsertData(list_help_text)
  BegFile()
  old_attr = Set(MenuSelectAttr, Query(MenuTextAttr))
  List('Help', LongestLineInBuffer())
  Set(MenuSelectAttr, old_attr)
  GotoBufferId(org_id)
  AbandonFile(hlp_id)
end list_help

menu ask_new_eoltype_menu()
  title = 'For matching filenames set end of line type to:'
  history = menu_history_selector
  '&As Loaded'
  '&CR               (Old operating systems)'
  '&LF               (Unix, Linux, Mac, ...)'
  'CR+LF   (&Both)   (Microsoft)'
end ask_new_eoltype_menu

integer proc ask_new_eoltype(string old_eoltype)
  case old_eoltype
    when 'CR'
      menu_history_selector = 2
    when 'LF'
      menu_history_selector = 3
    when 'CR+LF'
      menu_history_selector = 4
    otherwise
      menu_history_selector = 1
  endcase
  ask_new_eoltype_menu()
  return(MenuOption())
end ask_new_eoltype

proc list_modify_rule()
  string  defined_eoltype            [9] = Trim(GetText(1, 9))
  integer new_eoltype                    = 0
  string  search_options  [MAXSTRINGLEN] = unquote(Trim(GetText(13, 6)))
  string  search_string   [MAXSTRINGLEN] = unquote(Trim(GetText(22, MAXSTRINGLEN)))
  Message('Search which STRING in full filenames')
  if Ask('Search which STRING in full filenames:', search_string)
    search_string = unquote(search_string)
    Message('Search "', search_string, '" in filenames with which search options:')
    if Ask('with which search OPTIONS [biwx^$]:', search_options)
      search_options = validate_search_options(search_options) // Unquotes too.
      Message('For files matching "', search_string,
              '" with options "', search_options, '", set end of line type to:')
      if ask_new_eoltype(defined_eoltype)
        new_eoltype = MenuOption() - 1
        BegLine()
        KillToEol()
        InsertText(Format(eoltype_num_to_txt(new_eoltype, TRUE):-12,
                          quote(search_options):-9,
                          quote(search_string)))
      endif
    endif
  endif
  Message('')
end list_modify_rule

proc list_delete_rule(integer afterwards_go_up_or_down)
  if NumLines()
    if CurrLine() == NumLines()
      if CurrLine() == 1
        EmptyBuffer()
      else
        KillLine()
        Up()
      endif
    else
      KillLine()
      if afterwards_go_up_or_down == _UP_
        Up()
      endif
    endif
  endif
end list_delete_rule

proc list_add_rule_above()
  InsertLine()
  list_modify_rule()
  if not CurrLineLen()
    list_delete_rule(_DOWN_)
  endif
end list_add_rule_above

proc list_add_rule_below()
  AddLine()
  list_modify_rule()
  if not CurrLineLen()
    list_delete_rule(_UP_)
  endif
end list_add_rule_below

proc list_move_rule_up()
  integer old_ilba = 0
  if CurrLine() > 1
    old_ilba = Set(InsertLineBlocksAbove, ON)
    PushBlock()
    MarkLine(CurrLine(), CurrLine())
    Cut()
    Up()
    Paste()
    PopBlock()
    Set(InsertLineBlocksAbove, old_ilba)
  endif
end list_move_rule_up

proc list_move_rule_down()
  integer old_ilba = 0
  if CurrLine() < NumLines()
    old_ilba = Set(InsertLineBlocksAbove, OFF)
    PushBlock()
    MarkLine(CurrLine(), CurrLine())
    Cut()
    Paste()
    Down()
    PopBlock()
    Set(InsertLineBlocksAbove, old_ilba)
  endif
end list_move_rule_down

proc set_list_action(string action)
  list_action = action
  PushKey(<Escape>)
end set_list_action

Keydef list_keys
  <F1>                  set_list_action('help')
  <Ctrl Ins>            set_list_action('add_above')
  <Ins>                 set_list_action('add_below')
  <Ctrl GreyIns>        set_list_action('add_above')
  <GreyIns>             set_list_action('add_below')
  <Del>                 set_list_action('delete')
  <GreyDel>             set_list_action('delete')
  <Ctrl CursorUp>       set_list_action('up')
  <Ctrl GreyCursorUp>   set_list_action('up')
  <Ctrl CursorDown>     set_list_action('down')
  <Ctrl GreyCursorDown> set_list_action('down')
end list_keys

proc list_startup()
  UnHook(list_startup)
  Enable(list_keys)
  ListFooter('{F1}  {Ins}  {Ctrl Ins}  {Del}  {Enter}  {Arrows}  {Ctrl Arrows}  {Escape}')
end list_startup

proc list_cleanup()
  UnHook(list_cleanup)
  Disable(list_keys)
end list_cleanup

proc configure_eoltypes_for_files()
  string  defined_eoltype          [1] = ''
  integer i                            = 0
  integer lst_id                       = 0
  integer max_item_number_length       = 0
  integer org_id                       = GetBufferId()
  string  search_options           [6] = ''
  string  search_string [MAXSTRINGLEN] = ''
  lst_id = CreateTempBuffer()
  GotoBufferId(rules_id)
  BegFile()
  repeat
    defined_eoltype = GetText( 1, 1)
    search_options  = GetText( 3, 6)
    search_string   = GetText(10, MAXSTRINGLEN)
    if  (defined_eoltype    in '0' .. '3')
    and GetText(2, 1)       == ' '
    and GetText(9, 1)       == ' '
    and Trim(search_string) <> ''
      AddLine(Format(eoltype_num_to_txt(Val(defined_eoltype), TRUE):-12,
                     quote(validate_search_options(search_options)): -9,
                     quote(search_string)),
              lst_id)
    endif
  until not Down()
  GotoBufferId(lst_id)
  BegFile()
  repeat
    list_action = ''
    Hook(_LIST_STARTUP_, list_startup)
    Hook(_LIST_CLEANUP_, list_cleanup)
    if List('End of line types for filenames matching these search options/strings:',
            LongestLineInBuffer())
      list_action = 'modify'
    endif
    case list_action
      when 'help'       list_help()
      when 'add_above'  list_add_rule_above()
      when 'add_below'  list_add_rule_below()
      when 'delete'     list_delete_rule(_DOWN_)
      when 'modify'     list_modify_rule()
      when 'up'         list_move_rule_up()
      when 'down'       list_move_rule_down()
    endcase
  until list_action == ''
  GotoBufferId(rules_id)
  EmptyBuffer()
  GotoBufferId(lst_id)
  if NumLines()
    BegFile()
    repeat
      AddLine(Format(eoltype_txt_to_num(Trim(GetText(1, 12))):-2,
                     unquote(Trim(GetText(13, 9))):-7,
                     unquote(Trim(GetText(22, MAXSTRINGLEN)))),
              rules_id)
    until not Down()
  endif
  GotoBufferId(rules_id)
  if NumLines()
    max_item_number_length = Length(Str(NumLines()))
    RemoveProfileSection(varname_cfg_rules_section)
    BegFile()
    repeat
      i = i + 1
      WriteProfileStr(varname_cfg_rules_section,
                      Format('Item', i:max_item_number_length:'0'),
                      Format(      GetText( 1, 9),
                             quote(GetText(10, MAXSTRINGLEN))))
    until not Down()
  endif
  GotoBufferId(org_id)
  AbandonFile(lst_id)
end configure_eoltypes_for_files

proc show_help()
  string  full_macro_source_name [MAXSTRINGLEN] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + '.s'
  string  help_file_name         [MAXSTRINGLEN] = '*** ' + my_macro_name + ' Help ***'
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
        ChangeCurrFilename(help_file_name,
                           _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
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

proc menu_set(string object, string state)
  case object
    when 'ShowStatuses'
      show_statuses            = (state == 'Enabled')
    when 'EarlyWarnings'
      have_load_warnings      = (state == 'Enabled')
    when 'LateWarnings'
      have_save_warnings       = (state == 'Enabled')
    when 'OverridableChanges'
      have_overridable_changes = (state == 'Enabled')
  endcase
  if  GetProfileStr(varname_cfg_choices_section, object, 'Enabled') <> state
    WriteProfileStr(varname_cfg_choices_section, object, state)
  endif
  config_the_autoload()
end menu_set

string proc menu_get(string object)
  string result [9] = GetProfileStr(varname_cfg_choices_section, object, 'Enabled')
  result = iif((result in 'Enabled', 'Disabled'), result, 'Enabled')
  return(result)
end menu_get

proc menu_toggle(string object)
  string result [9] = GetProfileStr(varname_cfg_choices_section, object, 'Enabled')
  result = iif(result == 'Enabled', 'Disabled', 'Enabled')
  menu_set(object, result)
end menu_toggle

menu config_menu()
  title       = 'EolType Configuration'
  x           = 5
  y           = 5

  '&Escape', NoOp(), _MF_CLOSE_ALL_BEFORE_, 'Exit this menu'
  '&Help ...'  , show_help(), _MF_CLOSE_ALL_BEFORE_, 'Read the documentation'
  '&General status properties ...'  , exec_macro('Status'),
    _MF_CLOSE_ALL_BEFORE_, 'For instance change the status text colour ...'
  '',, _MF_DIVIDE_
  '&Show statuses ' [menu_get('ShowStatuses'):8],
    menu_toggle('ShowStatuses'), _MF_DONT_CLOSE_,
    'Show end of line type status(es) on the right hand side of the window.'
  '&Load file warnings' [menu_get('EarlyWarnings'):8],
    menu_toggle('EarlyWarnings'), _MF_DONT_CLOSE_,
    'Be warned when loading a file with a changing end of line type.'
  'S&ave file warnings ' [menu_get('LateWarnings'):8],
    menu_toggle('LateWarnings'), _MF_DONT_CLOSE_,
    'Be warned when saving a file with a changed end of line type.'
  '&Overridable changes' [menu_get('OverridableChanges'):8],
    menu_toggle('OverridableChanges'), _MF_DONT_CLOSE_,
    'At each end of line type change warning, get the choice to override it.'
  '',, _MF_DIVIDE_
  '&Rules for end of line types of files ...', configure_eoltypes_for_files(),,
    'Configure which files should be saved with which end of line type.'
end config_menu

proc stop_processing_my_key()
  PushKey(-1)
  GetKey()
end stop_processing_my_key

proc WhenPurged()
  UnHook(on_file_save)
  UnHook(after_file_save)
  UnHook(idle)
  AbandonFile(files_id)
  AbandonFile(rules_id)
  AbandonFile(check_id)
end WhenPurged

proc WhenLoaded()
  integer ok     = TRUE
  integer org_id = GetBufferId()

  #ifdef LINUX
    if compare_versions(VersionStr(), '4.41.34') == -1
      Warn('ERROR: In Linux the EOLtype extension needs at least TSE v4.41.34.')
      PurgeMacro(my_macro_name)
      ok = FALSE
    endif
  #endif

  if ok
    env_temp                    = Lower(GetEnvStr('TEMP'))
    env_tmp                     = Lower(GetEnvStr('TMP'))
    my_macro_name               = SplitPath(CurrMacroFilename(), _NAME_)
    varname_cfg_choices_section = my_macro_name + ':choices'
    varname_cfg_rules_section   = my_macro_name + ':rules'
    varname_load_warning_given  = my_macro_name + ':early_warning_given'
    varname_old_eoltype         = my_macro_name + ':old_eoltype'
    varname_new_eoltype         = my_macro_name + ':new_eoltype'
    varname_prev_path           = my_macro_name + ':prev_path'
    SetGlobalStr(my_macro_name + ':Version', my_macro_version)
    files_id                    = CreateTempBuffer()
    ChangeCurrFilename(my_macro_name + ':files',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
    rules_id                    = CreateTempBuffer()
    ChangeCurrFilename(my_macro_name + ':rules',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
    check_id                    = CreateTempBuffer()
    ChangeCurrFilename(my_macro_name + ':check',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
    BinaryMode(MAXLINELEN)
    GotoBufferId(org_id)
    if load_config()
      Hook(_AFTER_FILE_SAVE_  , after_file_save  )
      Hook(_IDLE_             , idle             )
      Hook(_ON_FILE_SAVE_     , on_file_save     )
      Hook(_ON_FIRST_EDIT_    , on_first_edit    )
    else
      PurgeMacro(my_macro_name)
    endif
  endif
end WhenLoaded

proc Main()
  string key_name [26] = ''
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
        config_menu()
        current_id = 0  // Trigger a status update.
        stop_processing_my_key()
      otherwise
        NoOp()  // Not my key: Let the editor or some other macro process it.
    endcase
  else
    // No, the user executed the macro.
    config_menu()
    current_id = 0  // Trigger a status update.
  endif
end Main

