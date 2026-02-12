/*
  Macro           Settings
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE Pro 4.0 upwards
  Version         1.3.1   2 Oct 2022


  FUNCTIONALITY

  This TSE extension has two main functions:
  - It automatically logs changes of your TSE settings,
    and when executed it can create a report of the history of those changes.
  - THIS SECOND FUNCTION IS NOW OPTIONAL AND WILL PROBABLY BE OBSOLETE (*):
    When you upgrade TSE, i.e. apply a Semware upgrade to an existing TSE
    folder, then Semware's upgrade will overwrite many settings and files,
    and this macro will afterwards automatically restore many of them:
    - The configuration settings.                    (1)
    - The window and font position and sizes.        (2)
    - The descriptions of your own Potpourri macros. (3)
    - Your own user interface if you had one.        (3)
    By executing this macro you can set automatically restoring TSE settings
    after a TSE upgrade to  "No" (the new default) or "Yes".

  (*) It is my expectation that somewhere in the near future new TSE versions
      will themselves retain user settings during a TSE upgrade.
      Therefore as of 7 August 2020 this macro will default no longer
      restore TSE settings after a TSE upgrade.
      By executing this macro you can toggle that functionality on and off.
  (1) With the exception of the SyntaxHilite Mapping Sets.
  (2) Only if they were configured in "Display/Color Options -> Startup options"
      with the value "Last Saved Settings".
  (3) Only if your macro or user interface has a non-Semware name.


  What gets restored:
    I have tried to find a balance between what can usually be restored safely
    and usefully after a TSE upgrade, and not interfering with what users
    themselves might have modified.
    This is my least-bad and reasonnable solution:
    - If a file or macro Potpourri description has a Semware name,
      then it gets updated by the upgrade.
      After all, we upgrade to get Semware updates.
    - If an active UI file or macro Potpourri description has a non-Semware
      name, then it is reinstalled after the TSE upgrade the first time you
      restart TSE.

    If you did make changes in a file with a Semware name, then this macro will
    not help you to automatically restore it, but the Semware upgrade will have
    made a backup of such files in a new "bak999" folder.


  NOTA BENE !!!

  When you upgrade TSE to a new version, this macro needs to be already
  installed in your old TSE version, which had to be restarted at least once.

  Up to TSE Pro v4.41.18 Semware only supplied an installation with a setup.exe
  file: The Settings macro relies on this for restoring Potpourri descriptions!

  As of TSE Pro v4.41.18 Semware intends to also supply a plain installation
  folder that you can copy over your existing folder: This way of upgrading TSE
  makes it impossible for the Settings macro to restore old Potpourri
  descriptions.


  INSTALLATION

  Just compile this macro, add its name "Settings" to the Macro AutoLoad List,
  and restart TSE at least once to create the first log of your settings.


  TSE UPGRADES

  Here a TSE upgrade means when you execute the setup.exe of a new TSE Pro
  release from Semware, and, when asked, you supply it with the folder of an
  existing TSE Pro installation. If you get both the GUI and console versions
  of TSE, then the GUI version g32.exe gets updated automatically, and you
  might need to copy the separately supplied console version e32.exe manually.

  This macro needs to be installed in your old TSE installation, which had to
  be restarted at least once, for it to work when you upgrade that TSE
  installation.

  User interface particulars:
  The TSE upgrade itself still forces you to select a user interface with
  a Semware name.
  If your user interface has a non-Semware name AND your old TSE version is at
  least TSE v4.4, then this macro will restore your user interface the first
  time TSE is restarted after the upgrade.
  If your old TSE version is older than TSE v4.4, then your new user interface
  will become whatever the Semware upgrade makes it. Beware, when you must copy
  an e32.exe as described below, then it retains its old user interface.

  Be warned if you have/use/get both the GUI and console (g32.exe and e32.exe)
  versions of TSE:
  You must first execute setup.exe, which upgrades the TSE folder including
  g32.exe, and only then must you copy the separate e32.exe to the upgraded
  folder.
  If you do it the other way around, then your settings will not be restored.
  If you do setup.exe and forget to copy e32.exe, then you will get annoying
  but harmless warnings about your settings being down- and upgraded every time
  you switch between the new GUI and the old console version.


  UPGRADE TIPS

  When you want to maintain your own version of an existing TSE file, make and
  maintain a renamed copy of that file. For instance rename
    <filename>.<extension>
  to
    <filename>_<yourname>.<extension>

  The main benefit is, that you can easily switch between to your and Semware's
  version, and you can at your leisure compare the two for changes that Semware
  made.

  Note that the Macro AutoLoad List and the syntax highlighting associations
  are (currently) not changed by a TSE upgrade: After an upgrade YOUR autoload
  macros keep running and YOUR syntax highlighting keeps highlighting IF you
  gave your macro files and syntax highlighting files a non-Semware name.


  INNER WORKINGS (for macro programmers)

  When TSE starts, the macro first does a quick check if the date/time of one
  of these files changed:
    g32.exe or e32.exe (only the currently started one is checked)
    tsecfg.dat
    tseui.dat
  Only if that is so, it generates a temporary new settings file.
  It generates a fingerprint of the temporary settings file and compares it to
  the saved fingerprint of the last permanently saved settings file.
  If the fingerprints differ, then at least one setting was changed, and the
  temporary file is saved as a permanent settings file.

  Semware's own "iconfig" macro is used to generate "settings files".
  Here these serve as log files.
  A nice side effect of using the iconfig macro is, that it apparently deletes
  obsolete settings and sets defaults for new settings.
  For TSE versions v4.4 upwards this macro adds the last installed user
  interface to it as a comment.
  A settings file can be compiled and executed as a macro to set (but not save)
  all the settings it contains.

  The settings files get elaborate significant names, that consist of:
  - The date: YYYY_MM_DD
  - The time: HH_MM_SS
  - A unique number just in case two TSE sessions close in the same second.
  - The TSE version string.
  - The .s extension because it is a macro source file and needs to be
    hilited as such. And a little bit because it is a settings file.

  About Semware's broken RemoveTrailingWhite setting.
  In a range of TSE beta versions that stretched over six years
  the RemoveTrailingWhite setting was broken:
    Query(RemoveTrailingWhite) always returns FALSE during hooks.
  So we could not log changed settings at the end of a TSE session because that
  would require a hook.
  Instead we had to postpone it to the start of the next TSE session
  where we can use the WhenLoaded() procedure.
  The TSE bug has been solved, but for backwards compatibility the Settings
  macro still uses the work-around.

  About the user interface file getting lower cased in the settings file.
  This is caused by a Semware bug in its "compile" macro.
  I have supplied a fix for the compile macro to SemWare, and it will be
  resolved in new TSE versions.


  TODO
    MUST
    SHOULD
    COULD
    WONT


  HISTORY

  0.1    13 May 2019
    Automatically restores TSE configuration settings after a TSE upgrade.

  0.2    15 May 2019
    Automatically restores non-Semware Potpourri descriptions too.

  0.3    25 May 2019
    Log changed settings at the start of the next TSE session instead of at
    the end of a TSE session. This is all to log Semware's broken
    RemoveTrailingWhite setting correctly too.

  0.4    27 May 2019
    Restore window position and size after upgrade.

  0.5    29 May 2019
    Add compitibility with TSE 4.0 and 4.2.

  0.6    29 May 2019
    When executed it creates a nice report of the history of changes in your
    settings.

  0.7    17 Jun 2019
    For TSE Pro v4.4 and above it now also logs user interface filename changes
    in the settings log files.

    When you upgrade TSE, the upgrade only lets you select one of Semware's
    standard user interfaces:
      UI DESCRIPTION                UI FILE
      Windows-like defaults         win.ui
      Classic defaults              tse.ui
      Customize
        TSE Pro Windows-like        win.ui
        TSE Pro Standard (Classic)  tse.ui
        TSE Jr (formerly Qedit)     tsejr.ui
        Brief                       brief.ui
        WordStar                    ws.ui
    The benefit is that these user interfaces have been brought up-to-date
    by Semware.

    However, if you were using a your own user interface and had gave it a
    non-Semware name, then after Semware's upgrade finishes this macro now
    assumes that you will want your own interface back, and reinstalls it.

  0.8     8 Jul 2019
    Fixed:
      The logging of the installed TSE user interface filename for TSE Pro v4.4
      and above did not work if the screen was maximized.

  0.9    27 Ju 2019
    Fixed:
    - If a TSE installation folder was copied and the copy was upgraded, then a
      user's ui file from the original folder could be reinstalled.
    - The macro was using TSE's Warn() command to give multi-line warnings,
      which does not work in the console version of TSE.
      Now the macro gives GUI-like Warn()s in TSE's console version too.
    - Upgrading from TSE v4.0 revealed:
      - Compiling settings from an older TSE version in a newer TSE version
        might give compiler warnings (not errors), which the macro erroneously
        saw as an error, which made it stop restoring settings.
      - VideoMode _MAXIMIZED_ is an undocumented but occurring value.
        It was even undocumented in the TSE v4.0 instance in which it occurred.
        Because it is undocumented, the macro saw it as an erroneous value,
        which made it stop restoring settings.

  0.10   29 Ju 2019
    Fixed:
    - The version string of the console version of TSE Pro v4.0 was not
      recognized.

  0.11    4 Aug 2019
    Fixed:
    - Error introduced in v0.10: The ui file was (un)quoted incorrectly, which
      caused it to be logged and restored incorrectly.
    - It is now handled correctly if the user has both the GUI and console
      version (g32.exe and e32.exe) of TSE in the same folder, and the user
      upgrades the folder (which upgrades g32.exe), but the user forgets to
      copy the new e32.exe.
      The improved result will be the still necessary but now harmless
      downgrading and upgrading of the TSE settings when the user switches
      between using the new GUI and the old console version.
    - If immediately after a TSE upgrade or downgrade the settings were not
      changed, then they would not be resaved, but to keep track of TSE
      versions they must be resaved under the new version's name.

  1.0     5 Aug 2019
    Mainstream release.

  1.1    28 Sep 2019
    Compensate for a TSE bug in TSE v4.41.16 - ... ?
      TSE bug in TSE menu termilogy: "Write settings to ASCII file" writes a
      "Max History Entries" above 32767 as a negative number. Internally this
      setting is called "MaxHistorySize".
      When this macro restores TSE's settings, it replaces a
      negative MaxHistorySize with 32767.

  1.2    18 Oct 2019
    Documented the Settings macro's dependency on using setup.exe for TSE
    upgrades, if you want Settings to also restore Potpourri descriptions.

  1.3     7 Aug 2020
    Made the automatically restoring of TSE settings after a TSE upgrade
    optional, configurable and default set to "No".

  1.3.1   2 Oct 2022
    Now calls the iConfig macro correctly as "iconfig", in lower-case.
    Settings is not a Linux macro, but Windows TSE can be installed on a
    network drive, that is implemented by a Linux machine that enforces
    case-sensitive filename addressing.

*/





// Compatibility restrictions and mitigations


#ifdef LINUX
  Settings is not a Linux-compatible extension.
  Let me know if you want it to be.
#endif


/*
  When compiled with a TSE version below TSE 4.0 the compiler reports
  a syntax error and hilights the first applicable line below.
*/

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
  integer result                        = FALSE
  if isGUI()
    result = Warn(warning_text)
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
  return(result)
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
    there here versioning of compare_versions() starts at v2.0.
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



// End of compatibility restrictions and mitigations





// Global constants

#define DATE_TIME_LENGTH 21     // YYYY_MM_DD___HH_MM_SS
#define MY_DATE_FORMAT    6
#define SLASH            47
#define UNDERSCORE       95

#if EDITOR_VERSION < 4400h
  #define MY_TIME_FORMAT  1     // Used to be only prefixable with spaces
#else
  #define MY_TIME_FORMAT  3     // Can now be prefixed with zeros
#endif





// Global variables

string  cfg_dir         [MAXSTRINGLEN] = ''
string  cfg_section     [MAXSTRINGLEN] = ''
integer my_clipboard_id                = 0
string  my_macro_name   [MAXSTRINGLEN] = ''
integer old_dateformat                 = 0
integer old_dateseparator              = 0
integer old_timeformat                 = 0
integer old_timeseparator              = 0
string  tmp_dir         [MAXSTRINGLEN] = ''
integer tmp_id                         = 0
string  warning_header  [MAXSTRINGLEN] = ''

#if EDITOR_VERSION >= 4400h
  string  restored_ui_fqn [MAXSTRINGLEN] = ''
#endif


// General procedures

#define SWP_NOSIZE 1  // Retains the current size (ignores the cx and cy parameters).
#define HWND_TOP   0  // Place window at top of Z order.

dll "<user32.dll>"
  integer proc SetWindowPos(
    integer handle, // Window handle
    integer place,  // HWND_TOP
    integer x,      // The new position of the left side of the window, in client coordinates.
    integer y,      // The new position of the top of the window, in client coordinates.
    integer cx,     // The new width of the window, in pixels.
    integer cy,     // The new height of the window, in pixels.
    integer flags   // SWP_NOSIZE
    ) : "SetWindowPos"
end

proc write_profile_error()
  wurn('ERROR writing configuration to file "tse.ini"')
end write_profile_error

integer proc write_profile_int(string  section_name,
                               string  item_name,
                               integer item_value)
  integer result = WriteProfileInt(section_name,
                                   item_name,
                                   item_value)
  if not result
    write_profile_error()
  endif
  return(result)
end write_profile_int

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

string proc get_fingerprint()
/*
  This proc returns a fingerprint for the content of the current buffer.

  NOTA BENE:
  This version of get_fingerprint() has been optimized for Settings files,
  and therefor contains code that is specific to Settings files.

  The fingerprint consists of three parts, separated by a space:
  - A Flecher-48 checksum, returned as 16 decimal digits.
  - A XOR of all 24-bit blocks, returned as 8 decimal digits.
  - A byte count modulo MAXINT, returned as 10 decimal digits.

  The sizes are chosen to get a good performance within the limitations
  of TSE's maximum integer value MAXINT ( == (2**31)-1 == 2147483647 ).

  Therefore for both the 24-bits (XOR) Cyclic Redundancy Check as the
  Fletcher-48 checksum, bytes are grouped in threesomes to blocks of 24 bits.

  Conventionally for Fletcher-48 a modulus value of ((2 ** 24) - 1) == 16777215
  is chosen.

  Because a normal TSE buffer has no end-of-line characters, all newlines are
  pragmatically pretended to be one LF character.

  The result for the number of bytes is actually the modulo of the number of
  bytes and TSE's maximum integer value MAXINT. This is theoretically incorrect,
  but for our purpose a very practical choice, because we are not interested in
  the real number of bytes, but just in an extra as unique as possible number
  to check.

  For better performance a small piece of algorithm is duplicated at the end.

  The fingerprinting has been adapted for this macro to skip single-line
  comments, because one of those contains an always different date/time.
*/
  integer byte_position    = 0  // Is a byte the 1st, 2nd or 3rd in a block.
  integer block_value      = 0
  integer byte_value       = 0
  integer crc_value        = 0
  string  fingerprint [36] = ''
  integer fletcher_1st_sum = 0
  integer fletcher_2nd_sum = 0
  integer number_of_bytes  = 0
  // PushPosition()
  BegFile()
  if NumLines()
    repeat
      byte_value = CurrChar()
      // Skip comments, one of which contains an alwast different date/time.
      if byte_value == SLASH
        if GetText(CurrPos(), 2) == '//'
          EndLine()
          byte_value = CurrChar()
        endif
      endif
      if byte_value == _AT_EOL_
        byte_value = 10  // All newlines are pretended to be one LF character.
      endif
      number_of_bytes = (number_of_bytes + 1) mod MAXINT
      byte_position   = byte_position + 1
      block_value     = block_value * 256 + byte_value
      if byte_position == 3
        crc_value        = crc_value ^ block_value
        fletcher_1st_sum = (fletcher_1st_sum + block_value     ) mod 16777215
        fletcher_2nd_sum = (fletcher_2nd_sum + fletcher_1st_sum) mod 16777215
        block_value      = 0
        byte_position    = 0
      endif
    until not NextChar()
    if byte_position <> 0
      crc_value        = crc_value ^ block_value
      fletcher_1st_sum = (fletcher_1st_sum + block_value     ) mod 16777215
      fletcher_2nd_sum = (fletcher_2nd_sum + fletcher_1st_sum) mod 16777215
    endif
  endif
  // PopPosition()
  fingerprint = Format(fletcher_2nd_sum:8:'0',
                       fletcher_1st_sum:8:'0',
                       ' ',
                       crc_value:8:'0',
                       ' ',
                       number_of_bytes:10:'0')
  return(fingerprint)
end get_fingerprint

/*
  There are typically two reasons why a UI file might be relocated.
  - When we copy a TSE installation folder and upgrade the copied folder,
    then references to the UI file might still be to the one in the original
    folder.
  - During a TSE upgrade from Semware a temporary folder might be used.
    Afterwards references to the UI file might be to a file in the temporary
    folder.

  Even if the UI file in the original folder still exists and might even be
  valid, we stil want the equivalent UI file in current TSE folder, because
  that is the file we want to work on from now on.
*/
string proc relocated_ui(string ui_fqn_old)
  integer ui_dir_pos                = 0
  string  ui_fqn_new [MAXSTRINGLEN] = ui_fqn_old
  string  ui_fqn_tmp [MAXSTRINGLEN] = ''
  if not EquiStr(LoadDir(), ui_fqn_new[1: Length(LoadDir())])
    // Fancy attempt: Search file in corresponding (subfolder of) "ui" folder.
    ui_dir_pos = Pos('\ui\', Lower(ui_fqn_old))
    if ui_dir_pos
      ui_fqn_tmp = LoadDir() + ui_fqn_old[ui_dir_pos + 1: MAXSTRINGLEN]
      if FileExists(ui_fqn_tmp)
        ui_fqn_new = ui_fqn_tmp
      endif
    endif
  endif
  if not EquiStr(LoadDir(), ui_fqn_new[1: Length(LoadDir())])
    // Straightforward attempt: Search file with same name in standard folder.
    ui_fqn_tmp = LoadDir() + 'ui\' + SplitPath(ui_fqn_old, _NAME_|_EXT_)
    if FileExists(ui_fqn_tmp)
      ui_fqn_new = ui_fqn_tmp
    endif
  endif
  return(ui_fqn_new)
end relocated_ui

#if EDITOR_VERSION >= 4400h
  string proc get_current_ui()
    string ui_file_name [MAXSTRINGLEN] = ''
    if restored_ui_fqn == ''
      ui_file_name = relocated_ui(Query(UIFilename))
    else
      ui_file_name = relocated_ui(restored_ui_fqn)
    endif
    return(ui_file_name)
  end get_current_ui
#endif

string proc unquote(string s)
  string result [MAXSTRINGLEN] = s
  if (s[1:1] in '"', "'")
  and s[1:1] == s[Length(s)]
    result = s[2:(Length(s) - 2)]
  endif
  return(result)
end unquote



// End of general procedures





// This macro's specific procedures

proc set_my_date_time_format()
  old_dateformat    = Set(DateFormat   , MY_DATE_FORMAT)
  old_dateseparator = Set(DateSeparator, UNDERSCORE    )
  old_timeformat    = Set(TimeFormat   , MY_TIME_FORMAT)
  old_timeseparator = Set(TimeSeparator, UNDERSCORE    )
end set_my_date_time_format

proc restore_old_date_time_format()
  Set(DateFormat   , old_dateformat   )
  Set(DateSeparator, old_dateseparator)
  Set(TimeFormat   , old_timeformat   )
  Set(TimeSeparator, old_timeseparator)
end restore_old_date_time_format

string proc format_date_time(string yyyy_mm_dd, string hh_mm_ss)
  string yyyy_mm_dd___hh_mm_ss [DATE_TIME_LENGTH] = yyyy_mm_dd + '___' + hh_mm_ss
  return(yyyy_mm_dd___hh_mm_ss)
end format_date_time

string proc get_file_date_time(string file_fqn)
  string file_date_time [DATE_TIME_LENGTH] = ''
  if FindThisFile(file_fqn)
    file_date_time = format_date_time(FFDateStr(), FFTimeStr())
  endif
  return(file_date_time)
end get_file_date_time

string proc get_win_handle()
  /*
    This proc returns the current windows handle as a string possibly prefixed
    with zeros to make the string at least as long as the longest previously
    returned string. The purpose is, that the string, which is used in
    filenames, does not cause the filenames to be jumpy in size, but to at
    most initially grow a bit in length.
  */
  integer largest_window_handle_size = GetProfileInt(cfg_section, 'largest_window_handle_size', 0)
  string  window_handle         [12] = Str(GetWinHandle())
  if Length(window_handle) > largest_window_handle_size
    largest_window_handle_size = Length(window_handle)
    write_profile_int(cfg_section, 'largest_window_handle_size', largest_window_handle_size)
  endif
  window_handle = Format(window_handle:largest_window_handle_size:'0')
  return(window_handle)
end get_win_handle

string proc find_next_pp_macro(integer pp_id)
  string  macro_name [12] = ''
  integer org_id          = GetBufferId()
  GotoBufferId(pp_id)
  if lFind('^[~ \d009]', 'x+')
    macro_name = Lower(Trim(GetText(1, 12)))
  endif
  GotoBufferId(org_id)
  return(macro_name)
end find_next_pp_macro

integer proc copy_pp_macro(string macro_name, integer old_pp_id, integer new_pp_id)
  integer description_begin = 0
  integer description_end   = 0
  integer ok                = TRUE
  integer old_clipboard_id  = Set(ClipBoardId, my_clipboard_id)
  integer old_ilba          = Set(InsertLineBlocksAbove, ON)
  integer org_id            = GetBufferId()
  GotoBufferId(old_pp_id)
  PushPosition()
  Set(ClipBoardId, my_clipboard_id)
  if  lFind(macro_name + ' ', '^gi')
  or  lFind(macro_name      , '^gi')
  and Lower(Trim(GetText(1, 12))) == macro_name
    description_begin = CurrLine()
    if lFind('^[~ \d009]', 'x+')
      description_end = CurrLine() - 1
    else
      description_end = NumLines()
    endif
    PushBlock()
    MarkLine(description_begin, description_end)
    Copy()
    GotoBufferId(new_pp_id)
    PushPosition()
    BegFile()
    while lFind('^[~ \d009]', 'x+')
    and   Lower(Trim(GetText(1,12))) <= macro_name
    endwhile
    if Lower(Trim(GetText(1,12))) <= macro_name
      EndFile()
      AddLine()
    endif
    Paste()
    PopPosition()
    GotoBufferId(old_pp_id)
    PopBlock()
  else
    ok = FALSE
  endif
  PopPosition()
  GotoBufferId(org_id)
  Set(ClipBoardId          , old_clipboard_id)
  Set(InsertLineBlocksAbove, old_ilba)
  return(ok)
end copy_pp_macro

integer proc restore_potpourri_descriptions()
  integer handle                              = 0
  integer macros_added                        = 0
  string  newest_bak_dir       [MAXSTRINGLEN] = ''
  string  newest_date_time [DATE_TIME_LENGTH] = ''
  string  new_macro_name                 [12] = ''
  integer ok                                  = TRUE
  string  old_macro_name                 [12] = ''
  integer org_id                              = GetBufferId()
  string  pp_new_fqn           [MAXSTRINGLEN] = LoadDir() + 'potpourr.dat'
  integer pp_new_id                           = 0
  string  pp_old_fqn           [MAXSTRINGLEN] = ''
  integer pp_old_id                           = 0
  // When upgrading, TSE first copies old files it will replace
  // to a 'bak{001-999}' folder in TSE's main folder.
  // So first we search for the newest such 'bak...' folder.
  handle = FindFirstFile(LoadDir() + 'bak*.*', -1)
  if handle <> -1
    repeat
      if  FFAttribute() & _DIRECTORY_
      and StrFind('^bak[0-9]#$', FFName(), 'x')
        // Elaborate date/time formatting for macro consistency.
        if format_date_time(FFDateStr(), FFTimeStr()) > newest_date_time
          newest_date_time = format_date_time(FFDateStr(), FFTimeStr())
          newest_bak_dir   = FFName()
        endif
      endif
    until not FindNextFile(handle, -1)
    FindFileClose(handle)
  endif
  if newest_bak_dir <> ''
    pp_old_fqn = LoadDir() + newest_bak_dir + '\potpourr.dat'
    if  FileExists(pp_old_fqn)
    and FileExists(pp_new_fqn)
      pp_old_id = EditBuffer(pp_old_fqn)
      pp_new_id = EditBuffer(pp_new_fqn)
      if  pp_old_id
      and pp_new_id
        // Macro names are returned in lower case.
        old_macro_name = find_next_pp_macro(pp_old_id)
        new_macro_name = find_next_pp_macro(pp_new_id)
        repeat
          if     old_macro_name == ''
            // We are done. No need to check the rest of the new Potpourri.
            new_macro_name = ''
          elseif new_macro_name == ''
          or     old_macro_name < new_macro_name
            // The old Potpourri has extra macro descriptions at the end,
            // or our old macro description is missing from the middle.
            copy_pp_macro(old_macro_name, pp_old_id, pp_new_id)
            old_macro_name = find_next_pp_macro(pp_old_id)
            macros_added   = macros_added + 1
            Message('Restored ', macros_added, ' macros to the new Potpourri ...')
          elseif old_macro_name == new_macro_name
            // Both old and new contain the same macro. Semware's description
            // prevales in that case, so nothing to do for us.
            old_macro_name = find_next_pp_macro(pp_old_id)
            new_macro_name = find_next_pp_macro(pp_new_id)
          else //old_macro_name > new_macro_name
            // Semware added a macro description. Nothing to do for us.
            new_macro_name = find_next_pp_macro(pp_new_id)
          endif
        until old_macro_name == ''
          and new_macro_name == ''
        if macros_added
          GotoBufferId(pp_new_id)
          if SaveAs(pp_new_fqn, _DONT_PROMPT_|_OVERWRITE_)
            wurn(Format(warning_header, 'Added ', macros_added,
                        " old macro descriptions back to Semware's new Potpourri."))
          else
            wurn(Format(warning_header, 'ERROR writing potpourr.dat to add ',
                        macros_added,
                        " old macro descriptions back to Semware's new Potpourri." ))
            ok = FALSE
          endif
        endif
      endif
      GotoBufferId(org_id)
      AbandonFile(pp_old_id)
      AbandonFile(pp_new_id)
    endif
  endif
  return(ok)
end restore_potpourri_descriptions

integer proc save_settings(integer always)
  string  current_date_time [DATE_TIME_LENGTH] = format_date_time(GetDateStr(), GetTimeStr())
  string  new_fingerprint                 [36] = ''
  string  new_settings_fqn      [MAXSTRINGLEN] = ''
  integer ok                                   = TRUE
  string  old_fingerprint                 [36] = ''
  integer org_id                               = GetBufferId()
  string  tmp_fqn               [MAXSTRINGLEN] = tmp_dir + '\TSE_' + my_macro_name + '_' + Str(GetWinHandle()) + '.s'
  restore_old_date_time_format()
  if ExecMacro('iconfig writecfg ' + QuotePath(tmp_fqn))
    set_my_date_time_format()
    GotoBufferId(tmp_id)
    if LoadBuffer(tmp_fqn)
      #if EDITOR_VERSION >= 4400h
        EndFile()
        AddLine('')
        AddLine('')
        AddLine('/* Additional settings logged by ' + my_macro_name + ' macro:')
        AddLine('')
        AddLine('UserInterface           = "' + get_current_ui() + '"')
        AddLine('')
        AddLine('*/')
        AddLine('')
      #endif
      old_fingerprint = GetProfileStr(cfg_section, 'last_settings_fingerprint', '')
      new_fingerprint = get_fingerprint() // Also for "always", see after "SaveAs".
      if always
      or new_fingerprint <> old_fingerprint
        if not (FileExists(cfg_dir) & _DIRECTORY_)
          if not MkDir(cfg_dir)
            wurn(Format(my_macro_name, ' error: Could not create settings dir "', cfg_dir, '".'))
            ok = FALSE
          endif
        endif
        if ok
          new_settings_fqn = cfg_dir + '\' + current_date_time + '___' + get_win_handle() + '___' + VersionStr() + '___.s'
          if SaveAs(new_settings_fqn, _DONT_PROMPT_)
            ok = write_profile_str(cfg_section, 'last_settings_fingerprint', new_fingerprint)
          else
            wurn(Format(my_macro_name, ' error: Could not save new settings to "', new_settings_fqn, '".'))
            ok = FALSE
          endif
        endif
      endif
    else
      wurn(Format(my_macro_name, ' error: Could not write temp file "', tmp_fqn, '".'))
      ok = FALSE
    endif
    EraseDiskFile(tmp_fqn)
  else
    set_my_date_time_format()
    wurn(Format(my_macro_name, ' error: Executing iconfig macro failed.'))
    ok = FALSE
  endif
  GotoBufferId(org_id)
  return(ok)
end save_settings

proc check_if_settings_need_saving()
  string  new_cfg_date_time [DATE_TIME_LENGTH] = ''
  string  new_cfg_fqn           [MAXSTRINGLEN] = LoadDir() + 'tsecfg.dat'
  string  new_exe_date_time [DATE_TIME_LENGTH] = ''
  string  new_exe_fqn           [MAXSTRINGLEN] = LoadDir(TRUE) // TSE's executable
  string  new_uid_date_time [DATE_TIME_LENGTH] = ''
  string  new_uid_fqn           [MAXSTRINGLEN] = LoadDir() + 'tseui.dat'
  integer ok                                   = TRUE
  string  old_cfg_date_time [DATE_TIME_LENGTH] = GetProfileStr(cfg_section, 'cfg_date_time' , '' )
  string  old_cfg_fqn           [MAXSTRINGLEN] = GetProfileStr(cfg_section, 'cfg_fqn'       , '' )
  string  old_exe_date_time [DATE_TIME_LENGTH] = GetProfileStr(cfg_section, 'exe_date_time' , '' )
  string  old_exe_fqn           [MAXSTRINGLEN] = GetProfileStr(cfg_section, 'exe_fqn'       , '' )
  string  old_uid_date_time [DATE_TIME_LENGTH] = GetProfileStr(cfg_section, 'uid_date_time' , '' )
  string  old_uid_fqn           [MAXSTRINGLEN] = GetProfileStr(cfg_section, 'uid_fqn'       , '' )

  new_cfg_date_time = get_file_date_time(new_cfg_fqn)
  new_exe_date_time = get_file_date_time(new_exe_fqn)
  new_uid_date_time = get_file_date_time(new_uid_fqn)

  if new_cfg_fqn       <> old_cfg_fqn
  or new_cfg_date_time <> old_cfg_date_time
  or new_exe_fqn       <> old_exe_fqn
  or new_exe_date_time <> old_exe_date_time
  or new_uid_fqn       <> old_uid_fqn
  or new_uid_date_time <> old_uid_date_time
    ok = ok and save_settings(FALSE)
    ok = ok and write_profile_str(cfg_section, 'cfg_fqn'      , new_cfg_fqn      )
    ok = ok and write_profile_str(cfg_section, 'cfg_date_time', new_cfg_date_time)
    ok = ok and write_profile_str(cfg_section, 'exe_fqn'      , new_exe_fqn      )
    ok = ok and write_profile_str(cfg_section, 'exe_date_time', new_exe_date_time)
    ok = ok and write_profile_str(cfg_section, 'uid_fqn'      , new_uid_fqn      )
    ok = ok and write_profile_str(cfg_section, 'uid_date_time', new_uid_date_time)
    if  ok
    and GetProfileStr(cfg_section, 'VersionStr', '') == ''
      ok = ok and write_profile_str(cfg_section, 'VersionStr', VersionStr())
    endif
  endif
end check_if_settings_need_saving

integer proc create_settings_list()
  //  If successful then returns the new bufferid with a descending sorted list
  //  of settings filenames.
  //  On failure it does nothing and returns zero.
  integer handle = 0
  integer lst_id = 0
  integer ok     = TRUE
  integer org_id = GetBufferId()
  lst_id = CreateTempBuffer()
  if lst_id
    handle = FindFirstFile(cfg_dir + '\*.s', -1)
    if handle <> -1
      repeat
        AddLine(FFName())
      until not FindNextFile(handle, -1)
      FindFileClose(handle)
    endif
    if     NumLines() == 0
      ok = FALSE
    elseif NumLines() <= 65535
      PushBlock()
      MarkLine(1, NumLines())
      Sort(_DESCENDING_)
      PopBlock()
      BegFile()
    else
      wurn(Format(my_macro_name, ': More than 65535 files: Cannot sort that many lines. Clean up old files in the ', my_macro_name, ' folder.'))
      ok = FALSE
    endif
    if not ok
      GotoBufferId(org_id)
      AbandonFile(lst_id)
      lst_id = 0
    endif
  else
    wurn(Format(my_macro_name, ': CreateTempBuffer failed.'))
  endif
  return(lst_id)
end create_settings_list


integer proc video_mode_name_to_value(    string  startup_video_mode,
                                      var integer video_mode_value  )
  integer p  = 0
  integer ok = TRUE

  /*
    The below string concatenations are not efficient, but easier to maintain.
    Here getting it right is more important than performance.

    _MAXIMIZED_ is a value that one of my old TSE v4.0 installations was using.
    I cannot find documentation for it in any of the 32-bits TSE versions.
    To this day TSE knows it as value 19 and does not give a compiler or
    run-time error on it when used to set CurrVideoMode or StartupVideoMode,
    which is great for upgrading TSE.
  */

  string fixed_video_mode_names [MAXSTRINGLEN] =
                    ' ' +
    '_AUTO_DETECT_    ' +
    '_25_LINES_       ' +
    '_28_LINES_       ' +
    '_30_LINES_       ' +
    '_33_LINES_       ' +
    '_36_LINES_       ' +
    '_40_LINES_       ' +
    '_43_LINES_       ' +
    '_44_LINES_       ' +
    '_50_LINES_       ' +
    '_MAX_LINES_      ' +
    '_MAX_COLS_       ' +
    '_MAX_LINES_COLS_ ' +
    '_MAXIMIZED_      '

  string fixed_video_mode_values [MAXSTRINGLEN] =
    '00' +
    '01' +
    '02' +
    '05' +
    '06' +
    '07' +
    '08' +
    '03' +
    '09' +
    '04' +
    '16' +
    '17' +
    '18' +
    '19'

  p = Pos(' ' + Upper(startup_video_mode) + ' ', fixed_video_mode_names) // 1, 18, 35, ...
  if p > 0
    p = ((p - 1) / 17) // 0, 1, 2, ...
    p = (p * 2) + 1    // 1, 3, 5, ...
    video_mode_value = Val(fixed_video_mode_values[p:2]) // 0, 1, 2, 5, 6, ...
  else
    ok = FALSE
  endif
  return(ok)
end video_mode_name_to_value

integer proc restore_window_pos_size(string settings_fqn)
  integer ok                                = TRUE
  string  startup_video_mode [MAXSTRINGLEN] = ''
  integer video_mode_value                  = 0
  integer win_pos_left                      = MAXINT
  integer win_pos_top                       = MAXINT
  GotoBufferId(tmp_id)
  ok = LoadBuffer(settings_fqn)
  if ok
    if lFind('^WinPosLeft @= @{[0-9-]#}', 'gix')
      win_pos_left = Val(GetFoundText(1))
    endif
    if lFind('^WinPosTop @= @{[0-9-]#}', 'gix')
      win_pos_top  = Val(GetFoundText(1))
    endif
    if lFind('^StartupVideoMode @=', 'gix')
      startup_video_mode = GetFileToken(GetText(1, MAXSTRINGLEN), 3)
    endif
    if  win_pos_left <> MAXINT
    and win_pos_top  <> MAXINT
      SetWindowPos(GetWinHandle(), HWND_TOP, win_pos_left, win_pos_top, 0, 0, SWP_NOSIZE)
    else
      wurn(Format(warning_header, 'Could not restore window position.'))
    endif
    if     isDigit(startup_video_mode)
      video_mode_value = Val(startup_video_mode)
    elseif Lower(startup_video_mode[1:2]) == '0x'
    and    isDigit(startup_video_mode[3:MAXSTRINGLEN])
      video_mode_value = Val(startup_video_mode[3:MAXSTRINGLEN], 16)
    elseif video_mode_name_to_value(startup_video_mode, video_mode_value)
      video_mode_value = video_mode_value
    else
      wurn(Format(warning_header,
                  'Unknown format for StartupVideoMode in settings file ',
                  Chr(13), Chr(13), '"', settings_fqn, '"'))
      ok = FALSE
    endif
    if ok
      Set(StartupVideoMode, video_mode_value)
      Set(CurrVideoMode   , video_mode_value)
    endif
  else
    wurn(Format(warning_header, 'ERROR loading file "', settings_fqn, '".'))
    ok = FALSE
  endif
  return(ok)
end restore_window_pos_size

proc repair_settings_file(string settings_fqn)
  string  old_MaxHistorySize [MAXSTRINGLEN] = ''
  integer org_id                            = GetBufferId()
  integer repair_id                         = CreateTempBuffer()
  if LoadBuffer(settings_fqn)
    if lFind('^ *MaxHistorySize *= *-[0-9]', 'gix')
      lFind('-[0-9]#', 'cgx')
      old_MaxHistorySize = GetFoundText()
      DelChar(Length(old_MaxHistorySize))
      InsertText('32767', _INSERT_)
      SaveAs(settings_fqn, _DONT_PROMPT_|_OVERWRITE_)
      Warn('TSE bug saved MaxHistorySize as ',
           old_MaxHistorySize, '. Settings macro repaired it as 32767.')
    endif
  endif
  GotoBufferId(org_id)
  AbandonFile(repair_id)
end repair_settings_file

integer proc restore_settings(string settings_name_ext)
  string  settings_fqn [MAXSTRINGLEN] = cfg_dir + '\' + settings_name_ext
  string  settings_mac [MAXSTRINGLEN] = my_macro_name + '\' + SplitPath(settings_name_ext, _NAME_)
  integer ok                          = TRUE
  repair_settings_file(settings_fqn)
  // Compile the settings source file as the TSE macro it is.
  lDos(QuotePath(LoadDir() + 'sc32.exe'),
       QuotePath(settings_fqn),
       _DONT_PROMPT_|_START_HIDDEN_|_RETURN_CODE_)
  // No compilation errors  -> lDos = 0, DosIOResult = 0.
  // Only compiler warnings -> lDos = 1, DosIOResult = 1.
  // Compilation errors!    -> lDos = 1, DosIOResult = 2.
  ok = (DosIOResult() in 0, 1)
  if ok
    // Execute the compiled settings macro, thereby restoring its settings.
    ok = ExecMacro(settings_mac)
    if ok
      // Restoring window settings needs to be done more explicitly.
      ok = ok and restore_window_pos_size(settings_fqn)
      ok = ok and SaveSettings()
    else
      wurn(Format(warning_header, 'ERROR executing macro:', Chr(13), Chr(13), settings_mac))
    endif
  else
    wurn(Format(warning_header, 'ERROR compiling macro:', Chr(13), Chr(13), settings_fqn))
  endif
  // Reset this macro's inner date/time format again,
  // saving the newly restored date/time format.
  set_my_date_time_format()
  return(ok)
end restore_settings

integer proc restore_ui(string settings_name_ext)
  integer ok                                   = TRUE
  integer org_id                               = GetBufferId()
  string  settings_fqn          [MAXSTRINGLEN] = cfg_dir + '\' + settings_name_ext
  string  uid_date_time_new [DATE_TIME_LENGTH] = ''
  string  uid_date_time_old [DATE_TIME_LENGTH] = ''
  string  uid_fqn               [MAXSTRINGLEN] = LoadDir() + 'tseui.dat'
  string  ui_fqn_old            [MAXSTRINGLEN] = ''
  string  ui_fqn_new            [MAXSTRINGLEN] = ''
  integer ui_id                                = 0
  GotoBufferId(tmp_id)
  if not LoadBuffer(settings_fqn)
    wurn(Format(warning_header, 'ERROR loading settings file "', settings_fqn, '".'))
    ok = FALSE
  endif
  if  ok
  and lFind('^UserInterface[ \d009]@=[ \d009]@.', 'gix')
    ui_fqn_old = Trim(GetToken(GetText(1, MAXSTRINGLEN), '=', 2))
    ui_fqn_new = unquote(ui_fqn_old)
    ui_fqn_new = relocated_ui(ui_fqn_new)
    if not FileExists(ui_fqn_new)
      wurn(Format(warning_header,
                  'ERROR: Cannot find original UI', Chr(13),
                  ui_fqn_old, Chr(13),
                  'as new UI', Chr(13),
                  ui_fqn_new))
      ok = FALSE
    endif
    if  ok
    and Lower(SplitPath(ui_fqn_new, _EXT_)) <> '.ui'
      wurn(Format(warning_header, 'ERROR referencing a UI file without a .ui extension: "', ui_fqn_new, '".'))
      ok = FALSE
    endif
    if  ok
    and not (Lower(SplitPath(ui_fqn_new, _NAME_)) in 'win', 'tse', 'tsejr', 'brief', 'ws')
      if GetBufferId(ui_fqn_new)
        AbandonFile(GetBufferId(ui_fqn_new))
      endif
      ui_id = EditFile(QuotePath(ui_fqn_new))
      if not ui_id
        wurn(Format(warning_header, 'ERROR loading UI file: "', ui_fqn_new, '".'))
        ok = FALSE
      endif
      if ok
        uid_date_time_old = get_file_date_time(uid_fqn)
        PushKey(<Escape>)
        PushKey(<Escape>)
        ExecMacro('compile ' + QuotePath(CurrFilename()))
        GotoBufferId(org_id)
        AbandonFile(ui_id)
        uid_date_time_new = get_file_date_time(uid_fqn)
        if uid_date_time_new == uid_date_time_old
          wurn(Format(warning_header, 'ERROR compiling UI file: "', ui_fqn_new, '".'))
          ok = FALSE
        else
          wurn(Format(warning_header, 'Reinstalled your user interface:', Chr(13),
                      ui_fqn_new, Chr(13), Chr(13),
                      'Restart TSE to fully activate the new user interface.'))
          #if EDITOR_VERSION >= 4400h
            restored_ui_fqn = ui_fqn_new
          #endif
        endif
      endif
    endif
  endif
  return(ok)
end restore_ui

integer proc check_if_settings_need_restoring()
  string  folder_version_str          [80] = GetProfileStr(cfg_section, 'FolderVersionStr', '')
  integer lst_id                           = 0
  string  new_version_str             [80] = VersionStr()
  integer ok                               = TRUE
  string  old_version_str             [80] = GetProfileStr(cfg_section, 'VersionStr', '')
  integer org_id                           = GetBufferId()
  string  settings_name_ext [MAXSTRINGLEN] = ''
  integer version_comparison               = 0
  string  version_direction            [5] = ''
  string  warning_prefix    [MAXSTRINGLEN] = ''
  if old_version_str <> ''
    version_comparison = compare_versions(old_version_str, new_version_str)
    if version_comparison
      version_direction = iif(version_comparison < 0, 'up', 'down')
      Alarm()
      warning_prefix = warning_header +
                       'TSE ' + version_direction + 'grade ' +
                       old_version_str + ' -> ' + new_version_str +
                       ' detected.' + Chr(13) + Chr(13)
      lst_id = create_settings_list()
      if lst_id
        // The list is already sorted descending on date/time.
        if lFind('___' + old_version_str + '___', 'g')
          settings_name_ext = GetText(1, MAXSTRINGLEN)
          if restore_settings(settings_name_ext)
            wurn(Format(warning_prefix,
                        'Configuration settings were restored from ',
                        Chr(13), settings_name_ext, '.'))
          else
            wurn(Format(warning_prefix,
                        'Failed to restore configuration settings from ',
                        Chr(13), settings_name_ext, '.'))
            ok = FALSE
          endif
          ok = ok and restore_ui(settings_name_ext)
        else
          wurn(Format(warning_prefix, 'No ', old_version_str,
                      ' configuration settings found to restore.'))
        endif
        GotoBufferId(org_id)
        AbandonFile(lst_id)
      else
        wurn(Format(warning_prefix,
                    'No logged configuration settings found to restore.'))
      endif
      if  ok
      and compare_versions(folder_version_str, new_version_str) < 0
        ok = restore_potpourri_descriptions()
        // Always try to write FolderVersionStr.
        if not write_profile_str(cfg_section, 'FolderVersionStr', new_version_str)
          ok = FALSE
        endif
      endif
      // Always try to write VersionStr.
      if not write_profile_str(cfg_section, 'VersionStr', new_version_str)
        ok = FALSE
      endif
      // The (hopefully restored) settings always need to be logged
      // using the new version name.
      if not save_settings(TRUE)
        ok = FALSE
      endif
    endif
  endif
  return(ok)
end check_if_settings_need_restoring

string proc get_auto_restore_setting()
  string result [4] = ''
  result = GetProfileStr(cfg_section,
                         'AutoRestoreAfterTseUpgrade',
                         'No')
  return(result)
end get_auto_restore_setting

proc toggle_auto_restore_setting()
  string new_auto_restore_setting [4] = ''
  if get_auto_restore_setting() == 'Yes'
    new_auto_restore_setting = 'No'
  else
    new_auto_restore_setting = 'Yes'
  endif
  write_profile_str(cfg_section,
                  'AutoRestoreAfterTseUpgrade',
                  new_auto_restore_setting)
end toggle_auto_restore_setting

proc WhenPurged()
  AbandonFile(my_clipboard_id)
  AbandonFile(tmp_id)
end WhenPurged

proc idle()
  PurgeMacro(my_macro_name)
end idle

proc WhenLoaded()
  integer org_id = GetBufferId()

  my_macro_name  = SplitPath(CurrMacroFilename(), _NAME_)
  warning_header = my_macro_name + ':' + Chr(13) + Chr(13)
  cfg_section    = my_macro_name + ':Config'
  cfg_dir        = GetProfileStr(cfg_section, 'cfg_dir', LoadDir() + my_macro_name)

  my_clipboard_id = CreateTempBuffer()
  tmp_id          = CreateTempBuffer()
  GotoBufferId(org_id)

  tmp_dir = GetEnvStr('TMP')
  if tmp_dir == ''
    tmp_dir = GetEnvStr('TEMP')
  endif

  if not (FileExists(tmp_dir) & _DIRECTORY_)
    wurn(Format(my_macro_name,
                ' abort: No TMP or TEMP environment variable pointing to an existing folder.'))
  else
    // Save settings before restore settings, so outside changes of settings
    // like by a TSE upgrade are logged too.
    set_my_date_time_format()
    check_if_settings_need_saving()
    if get_auto_restore_setting() == 'Yes'
      check_if_settings_need_restoring()
    endif
    restore_old_date_time_format()
  endif
  Hook(_IDLE_, idle)
end WhenLoaded

proc add_one_way_diff(integer first_id, integer second_id, integer diff_id, string diff_marker)
  string line_text [MAXSTRINGLEN] = ''
  GotoBufferId(first_id)
  BegFile()
  repeat
    line_text = RTrim(GetText(1, CurrLineLen()))
    if      Length(line_text)
    and     line_text[1:2] <> '/*'
    and     line_text[1:2] <> '*/'
    and not lFind('^ @\/\/', 'cgx')
      GotoBufferId(second_id)
      if not lFind(line_text, '^gi')
      or line_text <> RTrim(GetText(1, CurrLineLen()))
        AddLine('    ' + diff_marker + '    ' + line_text, diff_id)
      endif
      GotoBufferId(first_id)
    endif
  until not Down()
end add_one_way_diff

proc add_diff(integer old_id, integer new_id, string new_fqn,
              integer diff_id, integer report_id)
  integer setting_line                = 0
  string  setting_name [MAXSTRINGLEN] = ''
  GotoBufferId(diff_id)
  EmptyBuffer()
  add_one_way_diff(old_id, new_id, diff_id, '-')
  add_one_way_diff(new_id, old_id, diff_id, '+')
  GotoBufferId(diff_id)
  BegFile()
  repeat
    if CurrLineLen()
      setting_line = CurrLine()
      setting_name = GetToken(GetText(1, CurrLineLen()), ' ', 2)
      EndLine()
      if lFind(' ' + setting_name + ' ', 'ix')
        MarkLine(CurrLine(), CurrLine())
        Cut()
        GotoLine(setting_line)
        Paste()
        UnMarkBlock()
        Down()
      endif
      AddLine()
    endif
  until not Down()
  MarkLine(1, NumLines())
  Copy()
  GotoBufferId(report_id)
  AddLine('File: ' + new_fqn)
  Paste()
  UnMarkBlock()
  EndFile()
end add_diff

proc create_report()
  integer diff_id                = 0
  integer first_diff             = TRUE
  integer lst_id                 = 0
  string  new_fqn [MAXSTRINGLEN] = ''
  integer new_id                 = 0
  integer old_clipboard_id       = Set(ClipBoardId, my_clipboard_id)
  integer old_id                 = 0
  integer old_ilba               = Set(InsertLineBlocksAbove, OFF)
  integer org_id                 = GetBufferId()
  integer report_id              = 0
  integer tmp                    = 0
  PushBlock()
  lst_id = create_settings_list()
  if lst_id
    // We now have a list of settings files downwards sorted from new to old.
    report_id       = NewFile()
    old_id          = CreateTempBuffer()
    new_id          = CreateTempBuffer()
    diff_id         = CreateTempBuffer()
    GotoBufferId(lst_id)
    EndFile()
    while first_diff or Up()
      tmp     = old_id
      old_id  = new_id
      new_id  = tmp
      new_fqn = cfg_dir + '\' + GetText(1, CurrLineLen())
      GotoBufferId(new_id)
      LoadBuffer(new_fqn)
      add_diff(old_id, new_id, new_fqn, diff_id, report_id)
      GotoBufferId(lst_id)
      first_diff = FALSE
    endwhile
    Set(ClipBoardId, old_clipboard_id)
    GotoBufferId(report_id)
    AbandonFile(diff_id)
    AbandonFile(lst_id)
    AbandonFile(new_id)
    AbandonFile(old_id)
  else
    wurn('Nothing to report.')
    GotoBufferId(org_id)
  endif
  Set(ClipBoardId          , old_clipboard_id)
  Set(InsertLineBlocksAbove, old_ilba)
  PopBlock()
end create_report

menu main_menu()
  title = 'Settings menu'
  x     = 5
  y     = 5
  'Actions',, _MF_DIVIDE_
    '&Report changed TSE settings ...',
      create_report(),,
      'Report changed TSE settings.'
    '&Escape this menu',
      NoOp(),,
      'Exit this menu'
  'Configuration',, _MF_DIVIDE_
    '&Automatically restore settings after TSE upgrade'
      [get_auto_restore_setting():3],
      toggle_auto_restore_setting(),
      _MF_DONT_CLOSE_,
      "Toggle automatically restoring TSE's settings after a TSE upgrade."
end main_menu

proc Main()
  main_menu()
end Main

