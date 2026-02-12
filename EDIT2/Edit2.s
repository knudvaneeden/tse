/*
  Tool            Edit2
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows 10, Windows GUI TSE v4.0 upwards
  Version         v1   13 May 2022


  SUMMARY
    This tool can not only browse and edit ordinary folders and files,
    but it can browse and edit alternate data streams (ADS) too,
    and it can browse and edit names with non-ANSI characters too.

    It shows non-ANSI characters in names as quoted hexadecimal Unicode
    codepoints, with character 127 (usually a square) as the quoting
    character.

    Luckily you can browse to such files from a parent folder, and the browser
    shows a display line which uses a configurable font's full character range.

    ADS and non-ANSI are explained in more detail further on in the section
    "B A C K G R O U N D   I N F O R M A T I O N".


  DISCAIMER
    This tool is provided "as is". I cannot and do not garantee, that the tool
    is error free, nor that my intentions will meet your expectations.
    The tool may contain errors and it may damage files and thereby anything
    depending on those files.
    Either use the tool at your own risk, or do not use it.


  INSTALLATION
    Copy this file to TSE's "mac" folder and compile it there, for example by
    opening it there with TSE and applying the Macro Compile menu.

    Typically it is not necessary to add this tool to TSE's Macro AutoLoad List.
    Only in the exceptional case, that you create a new ADS or non-ANSI name
    in TSE, then this tool needs to be loaded to save the ADS or non-ANSI name.


  CONFIGURATION
    Windows language and region settings:
      This tool uses Windows' command prompt's "dir" command.
      Windows uses its language and region configuration settings to format the
      output of the "dir" command. For date and time it uses their short format.
      This tool does not support all Windows language and region settings, but
      it does support lots of them.
      The tool does work for all the Windows region settings of English,
      Dutch, French and German without specifically referencing them,
      so hopefully this flexibility extends to other languages as well.
      If you want to enable this tool to sort on date, then you might want to
      change Windows' "Setting -> Time & Language -> Region -> Change data
      formats -> Short date" to the "YYYY-MM-DD" format.

    This tool uses these TSE settings:
      Load Wild from Inside
        If a wildcard or "-s" is used and this setting is On, then do not list
        but load the specified files and ADSes.
      Show Directories at Top
        Exception: Folder ".." is always shown at the top.
      Sort order
        Ascending or descending.
      Sort key
        Exception: Sorting on extensions and attributes is not supported.
        Exception: This tool "sorts on date" (including time) alphabetically,
                   so sorting on date only makes sense if Windows' Region's
                   short date is configured to display dates in a numerical
                   "year month day" order.


  USAGE

  The tool has these capabilities:
  - You start the tool by executing it as a macro.
    When executing it you can provide parameters after the macro name or get
    a prompt.
  - For its input parameters and for its output it requires and displays
    non-ANSI characters as their hexadecimal Unicode codepoint quoted with
    character 127 (usually a square).
  - As its parameters you can enter zero or more parameter groups, their
    combined length's limitation being TSE's maximum string size of 255
    characters.
    - If you do not supply a parameter group, then the current folder with no
      prompt options is assumed.
    - If you do supply parameter groups, then each must consist of one
      file specification, optionally preceded by space-separated options.
      - A file specification must contain at least one of these parts:
        - A path
        - A file name
        - An ADS name
        All these parts may contain non-ANSI characters.
        A file name and an ADS name may contain the wildcard characters
        "*" and "?", but note that:
        - Folders and folder-ADSes do not adhere to wildcards.
        - "?" is treated as "*" (match any sequence of characters) for better
          compatibility with multi-byte non-ANSI characters.
      - A parameter option can be:
        - "-a" : Do not list but load the specified files and ADSes.
        - "-a-": Do not load but list the specified files and ADSes.
        - "-c" : Configure an alternative font for the display line. (*1)
        - "-d" : From the specified files and ADSes, only find the ADSes.
        - "-f" : Load files from list in file or current buffer.     (*2)
        - "-s" : The file specification also applies to subfolders.  (*3)
        Default the TSE configuration option "Load Wild From Inside" applies.
        The "-s" option implies the possibility of a group of files, and when
        browsing will not list folders, and will list files and ADSes with
        their fully qualified names.
        The "-a-" and "-d" options do not apply if one specific file or ADS
        is specified.
    - Each parameter group either loads the specified files and ADSes,
      or starts a browser.
      - The browser:
        - If "-s" was specified, then it will just list the specified files
          and ADSes with their fully qualified names.
        - if "-s" was not specified, then it will also list the file
          specification's path's subfolders, and list its parent folder as
          "..".
        - You can browse to listed folders, and open listed files and ADSes.
        - The browser redisplays its current list line above the list using a
          font's full character range.
          - This tool displays an invalid Unicode character as a "?".
            In practice this should not occur.
          - For a character that it does not support, the "Courier New" font
            displays a square. For example, it does this for a check mark,
            an emoji and a Chinese character.

  (*1)  The "-c" parameter
    If you enter the "-c" parameter by itsef, then an interaction starts to
    configure a new font for the tool's browser's display line.
    If you do not configure an alternative font, then TSE's default font is
    used, which is often Courier New, and often good enough.
    Whether the following fonts are installed on your system or not, the font
    prompt's history is pre-filled with these fonts:
      Courier New
      Unifont
      Arial Unicode MS
    You can also type in the name of another font.
    Font names are case-insensitive.
    Typing or selecting a font that is not installes on your system,
    mistyping its name, or typing in garbage does not fail!
    In such a case the closest matching font or a default font is set.
    One way to check your Windows' fonts and their characters is by pressing
    the Windows-key + R, and entering "CharMap".
    Courier New
      TSE itself only uses this font's ANSI characters, but the display line
      uses all its characters, including Greek, Cyrillic and Arabic.
    Unifont
      Despite it being a bit grainy I like the Unifont font, because it looks
      good enough, supports Unicode's "combining" characters, and it supports
      an immens amount of characters, including Chinese, Japanese and Korean.
      I downloaded the Unifont font from:
        https://unifoundry.com/unifont
      I tried both the older, larger file-sized TrueType version and the newer,
      smaller file-sized OpenType version, and saw no difference in usage.
      I downloaded the files, clicked on them, and selected "Install" to
      install them in Windows 10.
    Arial Unicode MS
      Nowadays this is a commercial font, and is not installed with Windows 10.
      However, by causes unknown it was installed on my Windows 10 pc, perhaps
      by some tool, so perhaps you have it too.
      It is like Unifont, but better looking.

  (*2)  The "-f" parameter
    The "-f" parameter is optionally followed and space-separated by a filename.
    This filename must be ANSI-compatible.
    if a filename is supplied: if it is already loaded, then it is reloaded
    and remains loaded, otherwise it is temporarily loaded.
    If no filename is supplied, then the current buffer is used.
    For the filename or current buffer the "-f" parameter will load all those
    listed files and ADSes found in its content that adhere to these rules:
    - It has a fully qualified name, e.g. by starting with a drive letter.
    - It is not quoted.
    - It is the last thing on its line.
    - It is not preceded by " <DIR> ".
    The name of a listed file or ADS may contain non-ANSI characters,
    provided they are encoded in Edit2's ANSI-encoding for such characters.
    An already loaded file or ADS is not reloaded (just like TSE works).
    A folder-ADSes, that is listed multiple times with different names, is only
    loaded under one name.
    Each no longer or otherwise not existing file or ADS will show an
    interactive error message.
    For example, the expected list format is compaitble with both Edit2's
    browser's <Elt E> list, as with my LstOpen tool's List.
    For another example, the action
      Macro Execute:
        Edit2 -a C:\Users\Bob\Tse\mac\*.s
    is almost equivalent to this sequence of steps
      Macro Execute:
        Edit2 C:\Users\Bob\Tse\mac\*.s
      Key:
        <Alt E>
      Macro Execute:
        Edit2 -f
    the difference being that in the second case files and ADSes may have been
    added and deleted between steps.

  (*3)  The "-s" parameter
    An oddity of the "-s" parameter is, that it will possibly match each
    folder-ADS many times: Once for the folder it is attached to, and once for
    each of its folder's subfolder.
    This odd behaviour is inherited from the Windows "dir /r" command.
    I guess this is the "reason":
    - A drive's root folder is not a normal folder, in that "dir" lists no "."
      folder and folder-ADSes for it, so the only way to see the drive's
      folder-ADSes is through its subfolders.
    - It would not make sense to only show folder-ADSes through a folder's
      subfolders, because then we could not access a folder-ADS for which the
      folder has no subfolders.
    This already minor problem has even less priority, because,
    unlike file-ADSes, in practice folder-ADSes do not occur.





  EXAMPLES
    ExecMacro('Edit2')
      Will prompt you for parameters.
    ExecMacro('Edit2 -c')
      Allows you to configure an alternative font for the tool's browser's
      display line.
    ExecMacro('Edit2 C:\Users\<username>\Downloads')
      Is likely to show an ADS for each downloaded file.
    ExecMacro('Edit2 -s c:\*')
      Will show a picklist of all files on drive C, including ADSes.
      Unlike TSE itself it will not crash on too deep or inaccessible folders,
      but skip them.
      WARNING: Edit2 is slow: On my pc this command took 6 hours.
    ExecMacro('Edit2 -a -d -s c:\')
      Will load all alternate data streams on drive C.
    ExecMacro('Edit2 -a -d -s c:\ -a -d -s d:\')
      Will load all alternate data streams on drives C and D.


  KNOWN LIMITATIONS
    This tool performs roughly 30 times slower than the normal File Open,
    which is especially noticeable when using the "-s" parameter.

    Like TSE this tool has limitations concerning folder and file depth and
    name length around 255 characters.
    For this tool the limit might even be a bit tighter due to character length
    differences during conversions between ANSI and UTF-8.

    The tool heavily depends on the output format of the Windows command
    prompt's "dir" command.
    Therefore this tool might fail for old, future and not-tested Windows
    (language) versions, or if an alternative command line interface is
    installed that disables the use of cmd.exe.
    It was tested with all the Windows 10 language and region options for
    English, Dutch, French and German without depending on them specifically,
    so hopefully this flexibility extends to other Windows languages and region
    options as well.
    If not, then you could send me an example of your cmd.exe's "dir" output,
    mentioning your Windows version and language.

    It is a known oddity, that a folder-ADS is displayed in two places by the
    browser; once as a member in the browser listing of the folder itself,
    and once as a member in the listing of the folder's parent folder.
    This is caused by Windows' "dir /r" command doing the same.


  WARNING
    Do not frivolously create a drive- or folder-ADS, because they are riskier,
    harder, or even impossible to delete.
    You can usually delete all a folder's (and its subfolders' and files')
    ADSes, but it is risky:
      One way is to move the folder to a non-NTFS drive and back.
        Note: This worked with a USB stick but not with an apparently NTFS
              formatted USB drive I tested.
      Another way is to add the folder to an archive (zip, 7z, rar), delete the
      original folder, and extract the folder back from the archive.
      Beware: Both these ways do not just delete one specific ADS: They also
      delete all the ADSes of the folder itsef and recursively delete all ADSes
      of the folder's subfolders and files.
    There is no way to delete a drive-ADS that I currently know of.


  TODO
    MUST
      -
    SHOULD
      Add more browser keys and functions.
      Allow "~" and ".." as folders in a path parameter.
    COULD
      Add eList's functionality to the browser.
      Programming:
        Recheck robustness of UTF-8 recognition. See "recheck" comment.
        Split too long procedures to clarify code, notably process_arg_group()
        and get_dir().
        Refactor duplicate source code, notably around the Dos() function.
        Improve error handling.
    WONT
      Improve speed about thirtyfold or add the capability to edit "too long"
      filenames by using Windows APIs instead of command line commands.
        Because that would cross my threshold for augmenting TSE into it making
        more sense to start creating a new editor from scratch.
      Display the whole browser page using a font's full character range.
        Because that would negate the browser's capability to show the
        difference between different (combinations of) Unicode character codes
        that are seemingly or actually displayed as the same character.
      List each folder-ADS only once.
        Because besides it already being a minor issue, in practice
        folder-ADSes do not occur.


  HISTORY

  v0.0.0.1   10 Apr 2022
    Supports inputting a folder, opionally -d and -s and a filename with
    wildcards.
    Known bug: Crash on "-s c:\".

  v0.0.0.2   12 Apr 2022
    Solved known bugs.
    Did an Edit2 of "-s C:\", which ran 5 hours and produced a file of over
    500,000 lines, which included ADSes and files with non-ANSI characters in
    their name.

  v0.0.0.3   15 Apr 2022
    Now works: Opening a normal file or an ADS from the prompt .
    Does not work yet: Opening a file with non-ANSI characters in its name.

  v0.0.0.4   20 Apr 2022
    From the prompt it can now open a non-ANSI filename, provided it is
    entered in the list's filename format.

  v0.0.0.5   21 Apr 2022
    You can now save a file with a non-ANSI name or an ADS.

  v0.0.0.6   22 Apr 2022
    You can now save an ADS with a non-ANSI name.

  v0.0.0.7   23 Apr 2022
    Documentation and source code improved, and bugs fixed.

  v0.0.0.8   24 Apr 2022
    Like TSE itself works, trying to reload an already loaded file or ADS now
    does nothing.

  v0.0.0.9   28 Apr 2022
    For a folder it now shows a proper list instead of an editable buffer.
    All you can currently do is open a file or ADS from this list.

  v0.0.0.10   28 Apr 2022
    You can now browse folders.

  v0.0.0.11   29 Apr 2022
    Fixed: The "-d" option was broken.
    Fixed: Folders were listed in reverse order.

  v0.0.0.12   1 May 2022
    Fixed: Wildcards work better.

  v0.0.0.13   2 May 2022
    Implemented the "-a" option to load all specified files.
    Found and fixed more bugs.

  v0.0.0.14   2 May 2022
    You can now open and save a folder ADS too.

  v0.0.0.15   3 May 2022
    Made the tool backwards compatible down to GUI TSE 4.0.

    Improved the documentation and made it appropriate for a BETA
    release candidate.

  v0.1   BETA   4 May 2022
    Beta release as a minimum viable product (MVP).

  v0.2   BETA   7 May 2022
    Redisplays the browser's current line above the list using the current
    font's full character range.
    For "Courier New" I see more symbols, and Greek, Cyrillic and Arabic
    characters, but not Chinees, Japanes or Korean characters.

  v0.3   BETA   10 May 2022
    In the browser <Alt E> edits its list. Path are fully extended.
    I added an example file that TSE itself cannot edit, but Edit2 can.

  v0.4   BETA   12 May 2022
    Fixed: Cleaned up a screen line showing a path after browsing.

    "-f [filename]" will load all files and ADSes listed either in the optional
    file or in the current buffer. See (*3) for list format rules for "-f".

  v1   13 May 2022
    Added the "-c" parameter to configure an alternative font for the tool's
    browser's display line.





  B A C K G R O U N D  I N F O R M A T I O N



  ALTERNATE DATA STREAMS

    An alternate data stream (ADS) is a "file" that exists as an attachment to
    a normal file or folder in an NTFS file system.
    The NTFS file system is commonly used with the Windows operating system.
    Normal file system browsing tools do not show ADSes.

    Typical example: If you download a file "Edit2.zip", common web browsers
    also create an ADS "Edit2.zip:Zone.Identifier" in the download folder.

    Note that an ADS name is the name of the file (or folder) the ADS is
    attached to, followed by a ":", followed by a summplemental name.

    Within NTFS renaming, copying, moving, or deleting a file or folder also
    renames, copies, moves and deletes its ADSes.

    Without using Windows programming and just using Windows commands:
      There is a simple way to list ADSes.
      There are doable tricks to create, edit or otherwise modify any
      specific ADS.
      There is a slightly risky trick to delete a file's ADS.
      There is no way to delete a folder's ADS.

    A simple Windows way to see ADSes is from the command prompt with "dir /r".
    An ADS name is the name of the file or folder it is attached to, followed
    by a colon and a supplemental name.
    For example:
      file_name.txt:supplemental_ads_name.txt

    For unknown reasons "dir /r" also adds a redundant ":$DATA" postfix.
    For example:
      file_name.txt:supplemental_ads_name.txt:$DATA
    This is a default that is optional when accessing an ADS, so tools need
    not show or use the ":$DATA" part, and this tool does not.
    A benefit of not using the ":$DATA" part is, that TSE recognizes a
    supplemental name's extension as such. For example, you can define TSE-
    properties for the common ADS extension ".Identifier".

    Folder-ADSes are shown weirdly by "dir /r":
    - The folder's own ADSes are for example shown as
        .:supplemental_ads_name
      Exception: A drive's root folder's ADSes are not shown.
    - The folder's parent folder's ADSes are also shown, for example as
        ..:supplemental_ads_name

    Some command prompt examples of working with ADSes:
      "dir /r" shows a folder's folders, files, and ADSes.
      "notepad ADSname" opens the ADS in Notepad. TSE cannot do this.
      "more < ADSname" shows its contents in the console.
      "more < ADSname > NormalFileName" copies its contents to a normal file.
      "more < ADSname | g32" shows its contents in TSE as "[<stdin>]".
      "echo HelloWorld > a.txt:b.txt"
        creates the ADS "a.txt:b.txt" if the file "a.txt" exists.
      "echo HelloWorld  > .\a:b.txt"
        creates the ADS "a:b.txt" if the folder "a" exists.

    This tool offers a user-friendlier alternative to most of these tricks.



  NON-ANSI CHARACTERS IN FILENAMES

    ANSI supports only 218 characters, encoded with one byte per character.
    Windows nowadays defaults to UTF-16LE, a Unicode character encoding.
    Luckily Windows still offers support for ANSI and conversions from and to
    it on a low level, which allows TSE to still seamlessly operate on a
    Windows system that is used for natural languages that use ANSI-compatible
    characters, like Danish, Dutch, English, Finnish, French, German,
    Hungarian, Icelandic, Indonesian, Italian, Norwegian, Portuguese, Spanish,
    and Swedish.
    But even on such Windows system we nowadays occasionally encounter
    filenames with math symbols, Greek letters, or files that were originally
    created an Apple machine.
    Microsoft and Apple use different Unicode encoding for characters with a
    diacritical symbol, like "é": Windows uses a single Unicode character that
    includes both, while Apple uses separate Unicode characters for the base
    character and the diacritical character.
    Windows seamlessly converts their Microsoft Unicode encoding for such
    characters to and from ANSI for apps like TSE, but not Apple's Unicode
    encoding (for a technically good and logical reason).

    This tool intends to mitigate all that.
    Theoretically it would have been possible to let it browse the filesystem
    with a Unicode-rich font, but that would have technical obstacles and would
    not allow the user to see the difference between Microsoft and Apple
    diacritics.
    So instead it identifies non-ANSI characters precisely by showing them as a
    hexadecimal Unicode codepoints quoted by character 127 (usually a square).
    My intention is to let a future version of this tool show the current
    browser line also as a display line that does attempt to show non-ANSI
    characters visually.

*/





/*
  T E C H N I C A L   N O T E S

  Fellow macro programmers beware, that this macro is in some parts programmed
  sloppily, in that I sometimes chose what I could implement quickly over the
  macro's maintainability and speed.

  Initial user stories (simplified):
    Story start points:
      1 A user inputs a folder.
        The tool starts folder browsing(4).
      2 A user inputs a file without wildcards nor using "-s".
        The tool opens it.
      3 A user inputs a file either with wildcards or using "-s".
        The tool creates a matching list, and
        either shows it as a selection list (5)
        or opens all files in it.
    Subsequent stories:
      4 Folder browsing. (Has a lot in common with a selection list.)
      5 Showing a selection list.

  With one exception TSE's own functions do not work for names containing
  non-ANSI character nor for ADSes.

  TSE itself has no problem saving an ADS from a buffer!

  InsertFile() no longer works for an alternate data stream (ADS).
    This is not a bug report, but a write-up of a discovered and then
    researched TSE change.
    Up to and including TSE Beta 4.40.97 (2016 Oct 22) the command
      InsertFile("my_text.txt:my_ads")
    loaded that ADS if it existed.
    Versions from and after TSE Beta v4.40.99 (2018 Apr 28) return
      "Open error: <filename>"
    for the same command.
    It was handy that InsertFile() worked for ADSes, but it is not a documented
    or required capability.

  This tool uses "dir /r" to list folders.
  This creates a dependency on dir's output format.
  I fear non-English Windows systems, past and future Windows systems,
  and users who installed an alternative command line interface.
  I tried some non-English "dir" formats with regional field formats,
  and so far discovered these rules across languages and region options:
  - The folder and file detail lines have a non-space character at column 1,
    ADSes and the header and footer lines do not.
  - A folder always has the string "<DIR>" as its third field.
  - Different date field formats can have different widths, influencing the
    positions of fields on its right.
  - The time field's format is always 99:99 with leading zeros.
  - The size field's format can have a space as group separator! (E.g. French.)

  This tool cannot use "dir /s", because "dir /s" stops when it encounters a
  folder it has no access permissions for, instead of just skipping it.   :-(

  These are two of the ways to get "dir" output in Unicode:
  - In a "cmd" shell first give the command "chcp 65001".
    This makes subsequent commands accept input and produce output in UTF-8.
  - Start a "cmd" shell with "cmd /u".
    This makes commands in the shell produce output in UTF-16LE.
  This tool uses the UTF-8 way.
  For TSE users, who typically use ANSI-compatible natural languages, UTF-8
  will most of the time use less bytes and be faster to convert to and from.

  Wondering and pondering about the possibility and usability of checking which
  characters are implemented by a font, I found these references:
    https://docs.microsoft.com/en-us/windows/win32/intl/using-international-fonts-and-text
      Refers to the getfontunicoderanges API, stating:
      "Note that this API does not support Unicode supplementary planes."
    https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getfontunicoderanges
      Its usability will depend on in what way it does not support Unicode
      supplementary planes.
  Currently the tool does not use this API.

  A future version of this tool will attempt to show the browser's current line
  also as a display line that shows non-ANSI characters visually.
  However, this is limited to a font's support for Unicode.
  There are no fonts that support all Unicode characters.

  "Courier New"
    which is GUI TSE's default font, is a monospace font that seems to
    contain symbols plus characters for "common languages with an linear
    alphabet" (my imprecise layman interpretation).
    The latter e.g. means support for Greek, Cyrillic and Arabic characters,
    but not support for Chinese, Japanese and Korean characters.
    Aside: Within these limitations it would be possible to create an extension
    that seamlessly overlays Unicode characters over a text that contains
    non-ANSI characters, but this makes a shown line shorter than its actual
    length, creating challlenges for editing and marking text.
    The font does not support Unicode's "combining" characters, meaning that it
    shows them as a separate character instead.

  "Unifont", informally aka "GNU Unifont"
    This is a downloadable, money-wise free, grainy, non-proportional font,
    that supports even more characters and supports Unicode's "combining"
    characters.
    The font being grainy is a downside, but for the display line for this tool
    it might be good enough.
    Actually, so far I like it a lot!
    Grasping at understanding fonts:
      My understanding so far is, that the implementaion of a font is limited
      by a technical restriction on its file size.
      So Unifont implementing so many characters might cause it to have limited
      space for defining each character, making the characters grainy.
    TSE itself does not allow Unifont's selection. It looks like a monospace
    font, but based on comments on its website it is not.
    Aside: Unifont's character width cannot be set to Courier New's character
    width, which makes sense for a non-monospace and a monospace font.

  "Arial Unicode MS"
    This is a commercially available, beautiful, character-rich, proportional
    font, that also supports Chinese, Japanese and Korean characters, and
    supports Unicode's "combining" characters.
    TSE itself does not allow its selection, which makes sense because it is a
    proportional font (e.g. the "m" is wider than the "i").
    I mention this font because I found it already installed on my main Windows
    pc.
    As far as I have been able to determine, Microsoft no longer supports nor
    wants to support a character-rich Unicode font.
    "Arial Unicode MS" was a Windows font, but Windows 10 no longer installs it.
    I found it on one Windows 10 computer, but not on another, so it was
    probably installed by some tool I installed. Probably not by Office.
    While TSE does not natively support proportional fonts, and while the
    font's variable character width makes it unusable to overwrite TSE's
    screen characters with Unicode characters, a proportional font could be
    used to overwrite a whole separate line of charcters if the line's
    overwritten information is deemed irrelevant and if character alignment
    with other lines is not an issue.

*/



// Start of compatibility restrictions and mitigations



#ifdef LINUX
  This tool is not compatible with Linux TSE.
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



// End of compatibility restrictions and mitigations.





// Global constants and semi-constants. Semi-constants are set in WhenLoaded().

#define CHANGE_CURR_FILENAME_FLAGS _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
#define COL_TIME_LENGTH            5
#define DOS_ASYNC_CALL_FLAGS       _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_|_RUN_DETACHED_|_DONT_WAIT_
#define DOS_SYNC_CALL_FLAGS        _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_
#define DOUBLE_QUOTE               34
#define FIND_ALL_FILES             -1
#define FOUND_NO_FILE              -1
#define SAVEAS_FLAGS               _DONT_PROMPT_|_OVERWRITE_
#define SINGLE_QUOTE               39
#define SPACE                      32

//    Numbers are left-justified (!) on position n * 5, 1 <= n <= 27.
//    The four leading spaces are vital.
//    The odd format facilitates a simpler and fast search-and-retrieve
//    algorithm.
string ANSI_CODEPOINTS [138] = '    8364 8218 402  8222 8230 8224 8225 ' +
                                   '710  8240 352  8249 338  381  8216 ' +
                                   '8217 8220 8221 8226 8211 8212 732  ' +
                                   '8482 353  8250 339  382  376 '
string ANSI_CODES      [138] = '    128  130  131  132  133  134  135  ' +
                                   '136  137  138  139  140  142  145  ' +
                                   '146  147  148  149  150  151  152  ' +
                                   '153  154  155  156  158  159 '

integer ANSI_ID                            = 0
string  BAT_FILE            [MAXSTRINGLEN] = ''
integer BAT_ID                             = 0
integer CONV_ID                            = 0
string  ERR_FILE            [MAXSTRINGLEN] = ''
integer ERR_ID                             = 0
string  FIND_POSSIBLE_UTF8_MULTI_BYTE [11] = '[\xC0-\xFF]'   // >= 11000000b
integer LIST_ID                            = 0
string  MACRO_NAME          [MAXSTRINGLEN] = ''
string  OUT_FILE            [MAXSTRINGLEN] = ''
integer OUT_ID                             = 0
string  SLASH                          [1] = '\'
string  TMP_FILE            [MAXSTRINGLEN] = ''
string  UTF8_FIRST_BYTE_FILTERS       [33] = '1111111b 11111b 1111b 111b 11b 1b'



// Global variables

string  browse_action               [25] = ''
integer col_date_from                    = 1
integer col_date_to                      = 0
integer col_dir_or_size_from             = 0
integer col_dir_or_size_length           = 0
integer col_dir_or_size_to               = 0
integer col_file_from                    = 0
integer col_file_length                  = 0
integer col_file_to                      = 0
integer col_time_from                    = 0
integer col_time_to                      = 0
integer no_utf8_to_ansi_errors           = TRUE
integer ok                               = TRUE
string  on_save_filename  [MAXSTRINGLEN] = ''
integer unicode_background_color         = 0x00000000
integer unicode_device_context_handle    = 0
integer unicode_font_flags               = 0
integer unicode_font_handle              = 0
integer unicode_font_height              = 0
string  unicode_font_name [MAXSTRINGLEN] = ''
integer unicode_font_size                = 0
integer unicode_font_width               = 0
integer unicode_text_color               = 0x00ffffff



// Start of Windows DLL APIs

dll "<user32.dll>"
  integer proc GetDC(integer hWnd)
  integer proc ReleaseDC(integer hWnd, integer hDC)
end

dll "<gdi32.dll>"

  integer proc TextOutW(
    integer hdc,
    integer x,
    integer y,
    integer lpString,   // Type LPCWSTR.
    integer c)          // lpString's length in 16-bit characters.

    // An LPCWSTR is a 32-bit pointer to a constant string of UTF-16LE
    // characters, which MAY be null-terminated.

  integer proc CreateFontA(
    integer cHeight,
    integer cWidth,
    integer cEscapement,
    integer cOrientation,
    integer cWeight,
    integer bItalic,
    integer bUnderline,
    integer bStrikeOut,
    integer iCharSet,
    integer iOutPrecision,
    integer iClipPrecision,
    integer iQuality,
    integer iPitchAndFamily,
    string  pszFaceName:cstrval)

  integer proc SelectObject(
    integer hdc,
    integer h)

  integer proc DeleteObject(
    integer h)

  integer proc SetBkColor(
    integer hdc,
    integer colour)

    // Color has hex RGB format: 0x00bbggrr. Note the reversed byte order.

  integer proc SetTextColor(
    integer hdc,
    integer colour)
end

// End of Windows DLL APIs



// Start of get_process_id() implementations

// #include ['get_process_id.inc']

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



proc abort(string msg)
  Warn('ERROR: ', msg)
  ok = FALSE
end abort

proc open_file_abort(integer error_nr, string filename)
  abort('Error ' + Str(error_nr) + ' opening file "' + filename + '".')
end open_file_abort

string proc unquote(string s)
  string result [MAXSTRINGLEN] = s
  if (result[1:1] in '"', "'")
  and result[1:1] == result[1:Length(result)]
    result = result[2: Length(result) - 2]
  endif
  return(result)
end unquote

// Insert a quoted string of up to 255 instead of 253 characters.
proc insert_quoted_text(string s)
  if Pos(' ', s)
    InsertText('"')
    InsertText(s)
    InsertText('"')
  else
    InsertText(s)
  endif
end insert_quoted_text

string proc codepoint_hex_string_to_utf8_string(string codepoint_string)
  integer codepoint                       = Val(codepoint_string, 16)
  integer first_byte_upper_bits           = 0
  integer lower_6_bits                    = 0
  integer placeable_amount_1st_byte_bits  = 0
  integer upper_bits                      = 0
  string  utf8_bytes                  [6] = ''
  if codepoint <= 127
    utf8_bytes                     = Chr(codepoint)
  else
    utf8_bytes                     = ''
    upper_bits                     = codepoint
    first_byte_upper_bits          = 128
    placeable_amount_1st_byte_bits = 6
    repeat
      first_byte_upper_bits          = 128 + (first_byte_upper_bits shr 1)
      placeable_amount_1st_byte_bits = placeable_amount_1st_byte_bits - 1
      lower_6_bits                   = upper_bits mod 64
      upper_bits                     = upper_bits  /  64
      utf8_bytes                     = Chr(128 + lower_6_bits) + utf8_bytes
    until placeable_amount_1st_byte_bits == 0
       or Length(Str(upper_bits, 2))     <= placeable_amount_1st_byte_bits
    if placeable_amount_1st_byte_bits == 0
      utf8_bytes = '?'
    else
      utf8_bytes = Chr(first_byte_upper_bits + upper_bits) + utf8_bytes
    endif
  endif
  return(utf8_bytes)
end codepoint_hex_string_to_utf8_string

string proc string_ansi_to_utf8(string ansi_name)
  string  codepoint_string [MAXSTRINGLEN] = ''
  integer i                               = 0
  integer p                               = 0
  string  utf8_name        [MAXSTRINGLEN] = ''
  string  utf8_string      [MAXSTRINGLEN] = ''
  for i = 1 to Length(ansi_name)
    if ansi_name[i] == Chr(127)
      codepoint_string = ansi_name[i + 1: MAXSTRINGLEN]
      p = Pos(Chr(127), codepoint_string)
      if p
        codepoint_string = codepoint_string[1: p - 1]
        utf8_string      = codepoint_hex_string_to_utf8_string(codepoint_string)
        utf8_name        = utf8_name + utf8_string
        i                = i + p
      else
        utf8_name = utf8_name + ansi_name[i]
      endif
    else
      utf8_name = utf8_name + ansi_name[i]
    endif
  endfor
  return(utf8_name)
end string_ansi_to_utf8

proc report_one_utf8_to_ansi_error()
  if no_utf8_to_ansi_errors
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    Warn('One-time warning: There are errors converting UTF-8 to ANSI.')
    no_utf8_to_ansi_errors = FALSE
  endif
end report_one_utf8_to_ansi_error

proc codepoint_to_ansi(integer codepoint, var string ansi_string)
  integer ansi_code = -1
  case codepoint
    when    0 .. 126
      ansi_code = codepoint
    when  160 .. 255
      ansi_code = codepoint
    otherwise
      ansi_code = Val(SubStr(ANSI_CODES,
                             Pos(' ' + Str(codepoint) + ' ',
                                 ANSI_CODEPOINTS           ) + 1,
                             3))
      if ansi_code == 0
        ansi_code = -1
      endif
  endcase
  if ansi_code >= 0
    ansi_string = Chr(ansi_code)
  else
    ansi_string = Chr(127) + Upper(Str(codepoint, 16)) + Chr(127)
  endif
end codepoint_to_ansi

integer proc buffer_utf8_to_codepoint(var integer utf8_length)
  integer codepoint              = 0
  integer length_bits_filter     = 11100000b
  integer bits_indicating_length = 11000000b
  integer offset                 = 0
  if CurrChar() < 128
    utf8_length = 1
    codepoint   = CurrChar()
  else
    // Determine utf8-character's length in bytes based on first byte.
    utf8_length            = 2
    while utf8_length      < 5
    and   (CurrChar() & length_bits_filter) <> bits_indicating_length
      utf8_length            = utf8_length + 1
      length_bits_filter     = (length_bits_filter     shr 1) + 10000000b
      bits_indicating_length = (bits_indicating_length shr 1) + 10000000b
    endwhile
    if utf8_length == 5
      report_one_utf8_to_ansi_error()
      utf8_length = 1
      codepoint   = CurrChar()
    else
      codepoint = CurrChar() & Val(GetToken(utf8_first_byte_filters, ' ', utf8_length))
      offset = 1
      while offset < utf8_length
        if (CurrChar(CurrPos() + offset) & 11000000b) == 10000000b
          codepoint = (codepoint shl 6) + (CurrChar(CurrPos() + offset) & 00111111b)
        else
          report_one_utf8_to_ansi_error()
          utf8_length = 1
          codepoint   = CurrChar()
        endif
        offset = offset + 1
      endwhile
    endif
  endif
  return(codepoint)
end buffer_utf8_to_codepoint

proc buffer_utf8_to_ansi()
  string  ansi_string  [14] = ''
  integer codepoint         = 0
  string  find_options  [3] = 'gx'
  integer old_filechanged   = FileChanged()
  integer old_undomode      = UndoMode(OFF)
  integer utf8_length       = 0
  no_utf8_to_ansi_errors = TRUE
  PushPosition()
  BegFile()
  while lFind(FIND_POSSIBLE_UTF8_MULTI_BYTE, find_options)
    codepoint = buffer_utf8_to_codepoint(utf8_length)
    codepoint_to_ansi(codepoint, ansi_string)
    if        utf8_length  <> 1
    or Length(ansi_string) <> 1
      DelChar(utf8_length)
      InsertText(ansi_string, _INSERT_)
      PrevChar()
    endif
    find_options = 'x+'
  endwhile
  PopPosition()
  FileChanged(old_filechanged)
  UndoMode(old_undomode)
end buffer_utf8_to_ansi



string proc string_utf8_to_ansi(string utf8_string)
  string ansi_string [MAXSTRINGLEN] = utf8_string
  PushLocation()
  GotoBufferId(CONV_ID)
  EmptyBuffer()
  InsertText(utf8_string)
  buffer_utf8_to_ansi()
  BegFile()
  if CurrLineLen() > MAXSTRINGLEN   // "Solution" for too long ANSI strings.
    lReplace('\d127[0-9A-Fa-f]#\d127', '?', 'gnx')
  endif
  if CurrLineLen()
    MarkColumn(1, 1, 1, CurrLineLen())
    ansi_string = GetMarkedText()
    UnMarkBlock()
  endif
  PopLocation()
  return(ansi_string)
end string_utf8_to_ansi



integer proc utf8_dir_exists(string dir)
  integer command_return_code      = 0
  integer dos_errorlevel           = 0
  integer dos_io_result            = 0
  integer dos_result               = 0
  integer result = FALSE

  PushLocation()
  GotoBufferId(BAT_ID)
  EmptyBuffer()
  AddLine('chcp 65001')
  AddLine('dir /ad ')
  EndLine()
  insert_quoted_text(dir)
  InsertText(' > ')
  insert_quoted_text(OUT_FILE)
  InsertText(' 2>&1')
  if not SaveAs(BAT_FILE, SAVEAS_FLAGS)
    abort('Saving "' + QuotePath(BAT_FILE) + '".')
  endif

  if  ok
  and KeyPressed()
  and GetKey() == <Escape>
    abort('You escaped!')
  endif

  if ok
    dos_result          = Dos(BAT_FILE, DOS_SYNC_CALL_FLAGS)
    dos_io_result       = DosIOResult()
    command_return_code = HiByte(dos_io_result)
    dos_errorlevel      = LoByte(dos_io_result)
    if      dos_result
    and not command_return_code
    and not dos_errorlevel
      result = TRUE
    endif
  endif

  PopLocation()
  return(result)
end utf8_dir_exists



// Note: We need to use the Edit(This)File() function, because we need its
// hooks to go off for the benefit of other macros, e.g. the Unicode extension.
integer proc edit_this_file(string fn, integer load_binary)
  string  fs [MAXSTRINGLEN] = fn
  integer result            = FALSE
  #if EDITOR_VERSION >= 4200h
    if load_binary
      fs = Str(load_binary) + ' ' + fs
    endif
    result = EditThisFile(fs, _DONT_PROMPT_)
  #else
    if load_binary
      fs = Str(load_binary) + ' ' + QuotePath(fs)
    endif
    result = EditFile(fs), _DONT_PROMPT_)
  #endif
  return(result)
end edit_this_file



integer proc is_fqn(string fn)
  integer result = FALSE
  if fn[1: 2] == '\\'
  or (    isAlpha(fn[1])
      and fn[2: 2] == ':\')
    result = TRUE
  endif
  return(result)
end is_fqn



integer proc has_parent_path(string path)
  integer result = FALSE
  if (    path[2: 2] == ':\'
      and NumTokens(path, SLASH) >= 2)
  or (    path[1: 2] == '\\'
      and NumTokens(path, SLASH) >= 5)
    result = TRUE
  endif
  return(result)
end has_parent_path



integer proc open_file(string path_in, string name_in, integer load_binary)
  integer command_return_code          = 0
  integer dos_errorlevel               = 0
  integer dos_io_result                = 0
  integer dos_result                   = 0
  string  file_arg_ansi [MAXSTRINGLEN] = ''
  string  file_arg_utf8 [MAXSTRINGLEN] = ''
  string  name          [MAXSTRINGLEN] = name_in
  integer new_id                       = 0
  integer open_file_error              = 0
  string  path          [MAXSTRINGLEN] = path_in

  if name[1: 2] == '.:'
    name = name[2: MAXSTRINGLEN]
  elseif name[1: 3] == '..:'
    // Can we travel up the path?
    if has_parent_path(path)
      path = RemoveTrailingSlash(SplitPath(path, _DRIVE_|_PATH_))
      name = name[3: MAXSTRINGLEN]
    endif
  endif

  file_arg_utf8 = path + SLASH + name
  file_arg_ansi = string_utf8_to_ansi(file_arg_utf8)

  if not GetBufferId(file_arg_ansi) // Like TSE, never reload a loaded file.
    PushLocation()
    new_id = CreateTempBuffer()

    if Pos(':', name)
    or StrFind('[\d128-\d255]', name, 'x')  // Todo: Recheck this UTF-8 check.
      GotoBufferId(BAT_ID)
      EmptyBuffer()
      AddLine('chcp 65001')
      AddLine('cd /d ')
      EndLine()
      insert_quoted_text(path)
      AddLine('if errorlevel 1 exit %errorlevel%')
      AddLine('more < ')
      EndLine()
      insert_quoted_text('.\' + name)   // ".\" needed for a folder ADS.
      InsertText(' > ')
      insert_quoted_text(TMP_FILE)
      InsertText(' 2> ')
      insert_quoted_text(OUT_FILE)
      if not SaveAs(BAT_FILE, SAVEAS_FLAGS)
        abort('Saving "' + QuotePath(BAT_FILE) + '".')
      endif
      GotoBufferId(new_id)

      if  ok
      and KeyPressed()
      and GetKey() == <Escape>
        abort('You escaped!')
      endif

      if ok
        dos_result          = Dos(BAT_FILE, DOS_SYNC_CALL_FLAGS)
        dos_io_result       = DosIOResult()
        command_return_code = HiByte(dos_io_result)
        dos_errorlevel      = LoByte(dos_io_result)
        if not dos_result
        or     command_return_code
        or     dos_errorlevel
          open_file_error = 1
        elseif not edit_this_file(TMP_FILE, load_binary)
          open_file_error = 2
        endif
        if open_file_error
          GotoBufferId(OUT_ID)
          LoadBuffer(OUT_FILE)
          UpdateDisplay(_ALL_WINDOWS_REFRESH_)
          open_file_abort(open_file_error, file_arg_utf8)
          GotoBufferId(new_id)
        endif
      endif
    else
      if not edit_this_file(file_arg_utf8, load_binary)
        open_file_abort(3, file_arg_utf8)
      endif
    endif

    if ok
      KillLocation()
      BegFile()
      BufferType(_NORMAL_)
      ChangeCurrFilename(file_arg_ansi, CHANGE_CURR_FILENAME_FLAGS)
      FileChanged(FALSE)
    else
      PopLocation()
      AbandonFile(new_id)
    endif
  endif

  return(ok)
end open_file



/*
  Input:
    The path to a folder.
    A file name filter, which often defaults to "*".

  Output:
    A buffer containing all subfolders and only the files specified by name.
    The output is sorted on TSE settings, but with '..' always on top.

  Notes:
  - This proc has exceptional rules for error handling, because we do not want
    all low-level errors make this tool abort:
    - Wildcards not matching anything makes "dir" return an error, but the proc
      should just return TRUE with the buffer containing an empty directory
      that still contains the ".." reference.
    - A too deep directory and one for which the user does not have access
      permissions make "dir" return an error, but the proc should not abort but
      just return FALSE.
  - A single "dir" command is incapable of applying supplied wildcards to
    files without applying them to subdirectories.
    This is solved by actually executing two "dir" commands: one for
    directories and one for files.
  - A directory-ADS is shown by the "dir" for directories. A side-effect of
    this is, that for this tool wildcards do not apply to directory-ADSes.
*/
integer proc get_dir(string path, string name)
  integer command_return_code   = 0
  integer dirs_at_top           = Query(PickFileFlags) & _DIRS_AT_TOP_
  integer dos_errorlevel        = 0
  integer dos_io_result         = 0
  integer dos_result            = 0
  integer first_file_line       = 0
  integer old_dir_line          = 0
  integer sort_col_from         = 0
  integer sort_col_to           = 0
  integer sort_descending       = isUpper(SubStr(Query(PickFileSortOrder), 1, 1))
  string  sort_order        [7] =                Query(PickFileSortOrder)

  Message(path + SLASH + name)

  EraseDiskFile(BAT_FILE)
  EraseDiskFile(OUT_FILE)

  GotoBufferId(OUT_ID)
  EmptyBuffer()

  GotoBufferId(BAT_ID)
  EmptyBuffer()

  AddLine('chcp 65001 > nul 2> ')  // Outputs a line we do not want to see.
  EndLine()
  insert_quoted_text(ERR_FILE)

  AddLine('if errorlevel 1 exit 65001') // A made-up DosIoResult error.

  AddLine('cd /d ')
  EndLine()
  insert_quoted_text(path)
  if  Length(path) == 2
  and isAlpha(path[1])
  and path[2] == ':'
    InsertText(SLASH)
  endif
  InsertText(' >> ')
  insert_quoted_text(OUT_FILE)
  InsertText(' 2>> ')
  insert_quoted_text(ERR_FILE)

  AddLine('if errorlevel 1 exit %errorlevel%')

  AddLine('dir /r /ad >> ')
  EndLine()
  insert_quoted_text(OUT_FILE)
  InsertText(' 2>> ')
  insert_quoted_text(ERR_FILE)

  AddLine('if errorlevel 1 exit %errorlevel%')

  AddLine('dir /r /a-d ')
  EndLine()
  insert_quoted_text(name)
  InsertText(' >> ')
  insert_quoted_text(OUT_FILE)
  InsertText(' 2>> ')
  insert_quoted_text(ERR_FILE)

  AddLine('if errorlevel 1 exit 0') // Never return an error for listing files.

  if not SaveAs(BAT_FILE, SAVEAS_FLAGS)
    abort('Saving "' + BAT_FILE + '".')
    return(ok)
  endif

  if  KeyPressed()
  and GetKey() == <Escape>
    abort('You escaped!')
    return(ok)
  endif

  dos_result          = Dos(BAT_FILE, DOS_SYNC_CALL_FLAGS)
  dos_io_result       = DosIOResult()
  command_return_code = HiByte(dos_io_result)
  dos_errorlevel      = LoByte(dos_io_result)
  if dos_io_result == 65001
    // Setting "chcp 65001" failed.
    abort('Unicode UTF-8 code page 65001 is not supported.')
    return(ok)
  elseif not dos_result
  or         command_return_code
  or         dos_errorlevel
    // Changing the current directory with "cd /d" failed.
    return(FALSE)
  endif

  GotoBufferId(OUT_ID)
  if not LoadBuffer(OUT_FILE)
    abort('Loading "' + OUT_FILE + '".')
    return(ok)
  endif

  // Delete the dir's empty lines.
  while lFind('^ *$', 'gx' )
    KillLine()
  endwhile

  // Delete the dir's header lines.
  while lFind('^ [~ ]', 'gx' )    // ADS lines have spaces for date and time.
    KillLine()
  endwhile

  // Delete the dir's footer lines.
  if lFind('^ #\c[0-9]', 'gx')
    repeat
      if CurrCol() < 19   // If footer line, not ADS line.
        KillLine()
        Up()
      endif
    until not lFind('^ #\c[0-9]', 'x+')
  endif

  // Delete the line for the "." folder.
  if lFind(' <DIR> #\.$', 'gx')
    KillLine()
  endif

  // Remove superfluous and inconvenient ADS name postfix.
  lReplace(':$DATA', '', 'gn$')

  BegFile()
  if NumLines()    == 0
  or CurrLineLen() == 0
    return(ok)
  endif

  // If fields' edge columns have not be determined yet, then do so.
  if col_file_from == 0
    if lFind('^[~ ]# #\c[~ ]', 'gx')
      col_time_from        = CurrCol()
      col_time_to          = col_time_from + 4  // Time format is always 99:99.
      col_date_to          = col_time_from - 2
      col_date_to          = col_date_to        // Pacify compiler.
      col_dir_or_size_from = col_time_to   + 2
    endif

    if lFind('^[~ ]# #[~ ]# #<DIR> #\c[~ ]', 'gx')
      col_file_from      = CurrCol()
      col_file_to        = col_file_from + MAXSTRINGLEN - 1
      col_dir_or_size_to = col_file_from - 2
    else
      // This situation is tough, because
      //   the root of a drive has no parent folders,
      //   and could have no subfolders,
      //   and e.g. French allows a space as a file size's group separator,
      //   and a filename could be just digits and spaces too.
      // We make a best effort, and otherwise abort.
      col_file_from = MAXINT
      // Find the start column of the leftest non-space string after the date
      // that contains a character that is not a digit group separator.
      BegFile()
      repeat
        GotoColumn(col_dir_or_size_from)
        if  lFind("[~0-9\., _']", 'cx')
        and lFind(' ', 'bc')
          Right()
          if CurrCol() < col_file_from
            col_file_from = CurrCol()
          endif
        endif
      until not Down()
      if col_file_from <> MAXINT
        // Check that all lines start a column on the found column.
        BegFile()
        repeat
          if  GetText(col_file_from - 1, 1) <> ' '
          or (GetText(col_file_from    , 1) in ' ', '')
            col_file_from = MAXINT
          endif
        until not Down()
      endif
      if col_file_from == MAXINT
        abort('Unknown field format from dir "' + path + '".')
        return(ok)
      else
        col_dir_or_size_to = col_file_from - 1
      endif
    endif

    if col_time_from == 0
    or col_file_from == 0
      abort('Wrong field format from dir "' + path + '".')
      return(ok)
    else
      col_dir_or_size_length = col_dir_or_size_to - col_dir_or_size_from + 1
      col_file_length        = col_file_to        - col_file_from        + 1
    endif
  endif

  // Sort the folder on TSE's picklist settings
  case Lower(sort_order[1: 1])
    when 'd', 't'
      sort_col_from = col_date_from
      sort_col_to   = col_time_to
    when 's'
      sort_col_from = col_dir_or_size_from
      sort_col_to   = col_dir_or_size_to
    when 'n', 'e', 'f', 'p'
      sort_col_from = col_file_from
      sort_col_to   = col_file_to
  endcase
  if sort_col_from
    MarkColumn(1, sort_col_from, NumLines(), sort_col_to)
    ExecMacro('sort -i' + iif(sort_descending, ' -d', ''))
    UnMarkBlock()
  endif

  if dirs_at_top
    // Find the first non-dir line
    BegFile()
    repeat
      if Trim(GetText(col_dir_or_size_from, col_dir_or_size_length)) <> '<DIR>'
        first_file_line  = CurrLine()
      endif
    until first_file_line
       or not Down()
    if first_file_line
      while Down()
        if Trim(GetText(col_dir_or_size_from, col_dir_or_size_length)) == '<DIR>'
          old_dir_line = CurrLine()
          MarkLine(old_dir_line, old_dir_line)
          GotoLine(first_file_line)
          MoveBlock()
          UnMarkBlock()
          first_file_line = first_file_line + 1
          GotoLine(old_dir_line)
        endif
      endwhile
    endif
  endif

  // Always move the ".." folder to the top.
  if lFind(' <DIR> #\.\.$', 'gx')
    MarkLine(CurrLine(), CurrLine())
    BegFile()
    MoveBlock()
    UnMarkBlock()
  endif

  BegFile()
  GotoColumn(col_file_from)
  return(ok)
end get_dir



integer proc get_list_dir(string path, string name, integer ads_only, integer search_subdirs)
  string s [MAXSTRINGLEN] = ''

  if not get_dir(path, name)
    return(FALSE)
  endif

  BegFile()
  if not NumLines()
  or not CurrLineLen()
    return(FALSE)
  endif

  // If ads_only, then delete lines for files not containing a ":" in the name.
  if ads_only
    BegFile()
    repeat
      s = Trim(GetText(col_dir_or_size_from, col_dir_or_size_length))
      if s <> '<DIR>'
        s = Trim(GetText(col_file_from, col_file_length))
        if is_fqn(s)  // If is a fully qualified name ...
          s = SplitPath(s, _NAME_|_EXT_)
        endif
        if not StrFind(':', s, '')
          KillLine()
          Up()
        endif
      endif
    until not Down()
  endif

  // Stop if the list is empty.
  BegFile()
  if not NumLines()
  or not CurrLineLen()
    return(FALSE)
  endif

  // If search_subdirs, then:
  //   Delete the line for the parent dir.
  //   Prefix the parent dir to the listed names.
  //   Do not delete dirs from the list yet, because create_list() might still
  //   need to recurs them. If search_subdirs, then our calling function
  //   create_list() will delete dirs from the list.
  if search_subdirs
    if lFind(' <DIR> #\.\.', 'gx')
      KillLine()

      // Stop if the list is empty.
      BegFile()
      if not NumLines()
      or not CurrLineLen()
        return(FALSE)
      endif
    endif

    BegFile()
    repeat
      GotoColumn(col_file_from)
      InsertText(path)
      InsertText(SLASH)
    until not Down()
  endif

  return(ok)
end get_list_dir



// Note: Searching subdirs also means no dirs in the List.

integer proc create_list(string  path,
                         string  name,
                         integer ads_only,
                         integer search_subdirs)
  string  field [MAXSTRINGLEN] = ''
  string  search_options   [2] = ''

  PushLocation()

  GotoBufferId(LIST_ID)
  EmptyBuffer()
  AddLine()   // Add a last empty line to simplify processing.

  // Get the requested dir output, and copy it to LIST_ID.
  if get_list_dir(path, name, ads_only, search_subdirs)
    GotoBufferId(OUT_ID)
    BegFile()
    if  NumLines()
    and CurrLineLen()
      MarkLine(1, NumLines())

      GotoBufferId(LIST_ID)
      CopyBlock()
      UnMarkBlock()
    else
      GotoBufferId(LIST_ID)
    endif
  else
    GotoBufferId(LIST_ID)
  endif

  // If search_subdirs, then recursively add the dir output of subdirectories.
  if search_subdirs
    BegFile()
    while ok
    and   CurrLine() < NumLines()
      field = Trim(GetText(col_dir_or_size_from, col_dir_or_size_length))
      if field == '<DIR>'
        // If search_subdirs, then subdirs are listed with their full path.
        field = Trim(GetText(col_file_from, col_file_length))
        if get_list_dir(field, name, ads_only, search_subdirs)
          GotoBufferId(OUT_ID)
          MarkLine(1, NumLines())

          GotoBufferId(LIST_ID)
          if Down()
            CopyBlock()
            UnMarkBlock()
            Up()
          endif
        else
          GotoBufferId(LIST_ID)
        endif
      endif
      Down()
    endwhile
  endif

  if search_subdirs
    MarkColumn(1, col_dir_or_size_from, NumLines(), col_dir_or_size_to)
    GotoBlockBegin()
    search_options = 'gl'
    while lFind('<DIR>', search_options)
      KillLine()
      Up()
      GotoBlockBeginCol()
      search_options = 'l+'
    endwhile
    UnMarkBlock()
  endif

  if ok
    EndFile()
    KillLine() // Remove the last empty line.
    BegFile()
  endif

  PopLocation()
  return(ok)
end create_list



integer proc standardize_file_specification(    string ansi_arg_in,
                                            var string utf8_path,
                                            var string utf8_name)
  string ansi_arg [MAXSTRINGLEN] = ansi_arg_in
  string utf8_arg [MAXSTRINGLEN] = ''

  if  Pos('*', ansi_arg)
  and Pos('*', ansi_arg) < Pos(SLASH, ansi_arg)
    abort('Wildcard in folder name.')
  endif

  // Make the file specification fully qualified, i.e. files on a drive have
  // or get a path that starts with the drive letter.
  if  ok
  and ansi_arg[1: 2] <> '\\'
    if ansi_arg[1] == SLASH
      ansi_arg = SplitPath(CurrDir(), _DRIVE_) + ansi_arg
    else
      if  isAlpha(ansi_arg[1])
      and ansi_arg[2] == ':'
      and (FileExists(ansi_arg[1: 2] + SLASH) & _DIRECTORY_)
        // Assume ansi_arg starts with a drive, though it could be an ADS.
        // An extra check makes our assumption explicit to the user.
        if  Length(ansi_arg) > 2
        and ansi_arg[3] <> SLASH
          abort('Argument Format: Drive without backslash not supported.')
        endif
      else
        // ansi_arg does not start with a drive yet.
        ansi_arg = CurrDir() + ansi_arg
      endif
    endif
  endif

  if ok
    utf8_arg = string_ansi_to_utf8(ansi_arg)
  endif

  if ok
    if Pos('*', utf8_arg)
      utf8_path = SplitPath(utf8_arg, _DRIVE_|_PATH_)
      utf8_name = SplitPath(utf8_arg, _NAME_|_EXT_)
    else
      if utf8_dir_exists(utf8_arg)
        utf8_path = utf8_arg
        utf8_name = '*'
      else
        utf8_path = SplitPath(utf8_arg, _DRIVE_|_PATH_)
        utf8_name = SplitPath(utf8_arg, _NAME_|_EXT_)
      endif
    endif
    utf8_path = RemoveTrailingSlash(utf8_path)
  endif

  if ok
    if (    Length(utf8_path) > 2
        and not utf8_dir_exists(utf8_path))
    or not utf8_dir_exists(utf8_path + SLASH)
      abort('Invalid arg folder "' + utf8_path + '".')
    endif
  endif

  return(ok)
end standardize_file_specification



integer proc load_list(string utf8_path, integer load_binary)
  string  dir_or_size [MAXSTRINGLEN] = ''
  string  list_file   [MAXSTRINGLEN] = ''
  string  file_name   [MAXSTRINGLEN] = ''
  string  file_path   [MAXSTRINGLEN] = ''
  integer first_new_id               = 0
  integer last_buffer_id             = GetBufferId()
  integer result                     = FALSE

  GotoBufferId(LIST_ID)
  BegFile()
  if  NumLines()
  and CurrLineLen()
    repeat
      if Trim(GetText(1, CurrLineLen())) <> ''  // Just to be sure.
        dir_or_size = Trim(GetText(col_dir_or_size_from, col_dir_or_size_length))
        if dir_or_size <> '<DIR>'
          list_file = Trim(GetText(col_file_from, col_file_length))
          if is_fqn(list_file)
            file_path = RemoveTrailingSlash(SplitPath(list_file, _DRIVE_|_PATH_))
            file_name =                     SplitPath(list_file, _NAME_ |_EXT_ )
          else
            file_path = utf8_path
            file_name = list_file
          endif
          PushLocation()
          GotoBufferId(last_buffer_id)  // So list order becomes buffer order.
          if open_file(file_path, file_name, load_binary)
            first_new_id   = iif(first_new_id, first_new_id, GetBufferId())
            last_buffer_id = GetBufferId()
          endif
          PopLocation()
        endif
      endif
    until not ok
       or not Down()
  endif

  if first_new_id
    GotoBufferId(first_new_id)
  else
    GotoBufferId(last_buffer_id)
  endif

  return (result)
end load_list



// When utf8_to_codepoint() encounters an invalid (sequence of) byte(s),
// it sets codepoint to "?", advances the character position by one byte,
// and returns FALSE.
// This gives the function's caller a choice whether to continue processing
// the rest of the UTF-8 string.

integer proc utf8_to_codepoint(var string  utf8_string,       // In
                               var integer utf8_char_pos,     // in/out
                               var integer unicode_codepoint) // Out
  integer bits_indicating_length = 11000000b
  integer length_bits_filter     = 11100000b
  integer offset                 = 0
  integer utf8_asc_at_pos        = 0
  integer utf8_length            = 0

  if utf8_char_pos > Length(utf8_string)
    unicode_codepoint = 0
    return(FALSE)
  endif

  if utf8_char_pos < 1
    utf8_char_pos = 1
  endif

  utf8_asc_at_pos = Asc(utf8_string[utf8_char_pos])

  if utf8_asc_at_pos < 128
    unicode_codepoint = utf8_asc_at_pos
    utf8_char_pos     = utf8_char_pos + 1
    return(TRUE)
  endif

  // Determine the alledged UTF-8 character's length in bytes based on its
  // first byte. At this stage this length must be at least 2.
  utf8_length            = 2
  while utf8_length      < 5
  and   (utf8_asc_at_pos & length_bits_filter) <> bits_indicating_length
    utf8_length            = utf8_length + 1
    length_bits_filter     = (length_bits_filter     shr 1) + 10000000b
    bits_indicating_length = (bits_indicating_length shr 1) + 10000000b
  endwhile

  // An UTF-8 encoding cannot be more than 4 bytes.
  if utf8_length == 5
    unicode_codepoint = Asc('?')
    utf8_char_pos     = utf8_char_pos + 1
    return(FALSE)
  endif

  unicode_codepoint = utf8_asc_at_pos & Val(GetToken(UTF8_FIRST_BYTE_FILTERS, ' ', utf8_length))

  offset = 1
  while offset < utf8_length
    if (Asc(utf8_string[utf8_char_pos + offset]) & 11000000b) == 10000000b
      unicode_codepoint = (unicode_codepoint shl 6) + (Asc(utf8_string[utf8_char_pos + offset]) & 00111111b)
      offset            = offset + 1
    else
      unicode_codepoint = Asc('?')
      utf8_char_pos     = utf8_char_pos + 1
      return(FALSE)
    endif
  endwhile

  utf8_char_pos = utf8_char_pos + offset
  return(TRUE)
end utf8_to_codepoint


// Potention debugging catcher for garbage in, garbage out.
proc gigo()
  NoOp()
end gigo


proc codepoint_to_utf16be(integer codepoint, var string utf16be_char)
  integer high_6x          = 0
  integer high_surrogate   = 0
  integer low_10x          = 0
  integer low_surrogate    = 0
  integer uuuuu            = 0
  integer wwww             = 0
  if     codepoint <= 0xD7FF
  or (   codepoint >= 0xE000
     and codepoint <= 0xFFFF)
    utf16be_char = Chr(codepoint / 256) + Chr(codepoint mod 256)
  elseif codepoint >    0xFFFF
  and    codepoint <= 0x10FFFF
    low_10x =  codepoint &            1111111111b
    high_6x = (codepoint &      1111110000000000b) shr 10
    uuuuu   = (codepoint & 111110000000000000000b) shr 16
    wwww    = (uuuuu - 1                         ) shl  6

    high_surrogate = 1101100000000000b + wwww + high_6x
    low_surrogate  = 1101110000000000b +        low_10x

    utf16be_char = Chr(high_surrogate  /  256) +
                   Chr(high_surrogate mod 256) +
                   Chr( low_surrogate  /  256) +
                   Chr( low_surrogate mod 256)
  else
    gigo()
    utf16be_char = Chr(0) + '?'
  endif
end codepoint_to_utf16be


proc codepoint_to_utf16le(integer codepoint, var string utf16le_char)
  string utf16be_char [4] = ''
  codepoint_to_utf16be(codepoint, utf16be_char)
  if Length(utf16be_char) == 2
    utf16le_char = utf16be_char[2:1] +
                   utf16be_char[1:1]
  else
    utf16le_char = utf16be_char[2:1] +
                   utf16be_char[1:1] +
                   utf16be_char[4:1] +
                   utf16be_char[3:1]
  endif
end codepoint_to_utf16le


string proc utf8_to_utf16le(string utf8_string_in)
  integer unicode_codepoint               = 0
  string  utf16le_char                [4] = ''
  string  utf16le_string   [MAXSTRINGLEN] = ''
  integer utf8_char_pos                   = 1
  integer utf8_string_length              = Length(utf8_string_in)
  string  utf8_string      [MAXSTRINGLEN] = utf8_string_in

  while utf8_char_pos <= utf8_string_length
    utf8_to_codepoint(utf8_string, utf8_char_pos, unicode_codepoint)
    codepoint_to_utf16le(unicode_codepoint, utf16le_char) // (in, out)
    utf16le_string = utf16le_string + utf16le_char
  endwhile

  return(utf16le_string)
end utf8_to_utf16le


proc edit_list(string utf8_path)
  integer add_path                     = FALSE
  string  ansi_path     [MAXSTRINGLEN] = ''
  string  ansi_filename [MAXSTRINGLEN] = ''
  string  utf8_filename [MAXSTRINGLEN] = ''

  GotoBufferId(LIST_ID)
  MarkLine(1, NumLines())

  NewFile()
  SetUndoOff()
  CopyBlock()
  UnMarkBlock()

  if lFind(' <DIR> #\.\.$', 'gx')
    KillLine()
  endif

  BegFile()

  if col_file_from == 0
  or NumLines()    == 0
  or (    NumLines()    == 1
      and CurrLineLen() == 0)
    return()
  endif

  GotoColumn(col_file_from)
  ansi_filename = GetText(CurrCol(), MAXSTRINGLEN)

  if not is_fqn(ansi_filename)
    add_path  = TRUE
    ansi_path = string_utf8_to_ansi(utf8_path)
  endif

  repeat
    utf8_filename = GetText(CurrCol(), MAXSTRINGLEN)
    ansi_filename = string_utf8_to_ansi(utf8_filename)
    if ansi_filename <> utf8_filename
      KillToEol()
      InsertText(ansi_filename)
      GotoColumn(col_file_from)
    endif
    if add_path
      InsertText(ansi_path)
      InsertText(SLASH)
      GotoColumn(col_file_from)
    endif
  until not Down()

  BegFile()
  SetUndoOn()
end edit_list


proc load_listed_files(string file)
  string  ansi_name   [MAXSTRINGLEN] = ''
  string  ansi_path   [MAXSTRINGLEN] = ''
  integer first_new_id               = 0
  integer last_new_id                = 0
  string  listed_file [MAXSTRINGLEN] = ''
  integer list_of_files_id           = 0
  integer org_id                     = GetBufferId()
  string  utf8_name   [MAXSTRINGLEN] = ''
  string  utf8_path   [MAXSTRINGLEN] = ''

  if file == ''
    list_of_files_id = GetBufferId()
  else
    // The line below will not match anything when wildcards are used,
    // will not match a directory, and will match an existing file.
    if  (FileExists(file) & (_NORMAL_|_DIRECTORY_)) == _NORMAL_
    and (  (                 GetBufferId(file)
            and GotoBufferId(GetBufferId(file)))
        or CreateBuffer(file, _SYSTEM_))
    and LoadBuffer(file)
      list_of_files_id = GetBufferId()
    else
      Warn('Error loading file: "', file, '".')
      GotoBufferId(org_id)
      AbandonFile(list_of_files_id)
      list_of_files_id = 0
    endif
  endif

  if list_of_files_id
    last_new_id = org_id
    PushLocation()
    BegFile()
    repeat
      if not lFind(' <DIR> ', 'cg')
        BegLine()
        repeat
          if CurrChar() > SPACE
            listed_file = GetText(CurrPos(), MAXSTRINGLEN)
            if is_fqn(listed_file)
              ansi_path   = RemoveTrailingSlash(SplitPath(listed_file, _DRIVE_|_PATH_))
              ansi_name   =                     SplitPath(listed_file,  _NAME_|_EXT_ )
              utf8_path   = string_ansi_to_utf8(ansi_path)
              utf8_name   = string_ansi_to_utf8(ansi_name)
              PushLocation()
              GotoBufferId(last_new_id)
              if open_file(utf8_path, utf8_name, FALSE)
                if not first_new_id
                  first_new_id = GetBufferId()
                endif
                if GetBufferId() <> last_new_id
                  last_new_id = GetBufferId()
                endif
                PopLocation()
              else
                ok = TRUE
                PopLocation()
              endif
              EndLine()
            else
              Right()
            endif
          else
            Right()
          endif
        until CurrPos() > CurrLineLen() - 3
      endif
    until not Down()
    PopLocation()
    if first_new_id
      GotoBufferId(first_new_id)
    else
      GotoBufferId(org_id)
    endif
  else
    GotoBufferId(org_id)
  endif
end load_listed_files


proc after_nonedit_command()
  integer curr_line                        = CurrLine()
  string  utf16le_list_file [MAXSTRINGLEN] = ''
  string  utf8_list_file    [MAXSTRINGLEN] = ''

//PutStrAttrXY(1, 1, GetText(1, MAXSTRINGLEN), '', Color(bright yellow ON blue))

  GotoBufferId(LIST_ID)
  GotoLine(curr_line)
  utf8_list_file    = Trim(GetText(col_file_from, col_file_length))
  utf8_list_file    = utf8_list_file + Format('': MAXSTRINGLEN)

  GotoBufferId(ANSI_ID)
  utf16le_list_file = utf8_to_utf16le(utf8_list_file)

//TextOutw(device_context_handle,
//         10 * font_width,
//         10 * font_height,
//         AdjPtr(Addr(text), 2),
//         Length(text) / 2)

  // The font width and height times a factor determine the text's starting
  // position.
  // So the factors determine the position expressed in character size.
  // The content of a TSE string variable starts 2 bytes after its address.
  // unicode_font_width is the 0 we set it too, which luckily does not matter.
  // Displaying a UTF-16LE encoded character requires half its encoded lenth.
  TextOutw(unicode_device_context_handle,
           0 * unicode_font_width,
           0 * unicode_font_height,
           AdjPtr(Addr(utf16le_list_file), 2),
           Length(     utf16le_list_file    ) / 2)

end after_nonedit_command


Keydef browse_keys
  <Alt e>
    browse_action = 'EditList'
    PushKey(<Enter>)
end browse_keys


proc browse_list_cleanup()
  UnHook(browse_list_cleanup)
  UnHook(after_nonedit_command)
  Disable(browse_keys)
end browse_list_cleanup


proc browse_list_startup()
  UnHook(browse_list_startup)
  Hook(_LIST_CLEANUP_         , browse_list_cleanup)
  Hook(_AFTER_NONEDIT_COMMAND_, after_nonedit_command)
  ListFooter('{Alt E}-Edit list')
  Enable(browse_keys)
end browse_list_startup



integer proc browse_list(string list_title, var string selected_list_file)
  integer selected_line = 0

  PushLocation()
  browse_action      = ''
  selected_list_file = ''

  GotoBufferId(LIST_ID)
  MarkLine(1, NumLines())

  GotoBufferId(ANSI_ID)
  EmptyBuffer()
  CopyBlock()
  UnMarkBlock()

  buffer_utf8_to_ansi()
  lReplace('^', '  ', 'gnx')
  BegFile()
  Hook(_LIST_STARTUP_, browse_list_startup)
  Set(Y1, 2)
  PushKey(<CursorLeft>)

//if  List(list_title, LongestLineInBuffer())
  if lList(list_title, LongestLineInBuffer(), Query(ScreenRows) - 3, _ENABLE_SEARCH_|_ENABLE_HSCROLL_)
    selected_line = CurrLine()

    GotoBufferId(LIST_ID)
    GotoLine(selected_line)
    selected_list_file = Trim(GetText(col_file_from, col_file_length))
    if browse_action <> 'EditList'
      if Trim(GetText(col_dir_or_size_from, col_dir_or_size_length)) == '<DIR>'
        browse_action = 'BrowseToDir'
      else
        browse_action = 'OpenFile'
      endif
    endif
  else
    GotoBufferId(LIST_ID)
  endif

  PopLocation()

  // Trick to remove the browser's display line and refresh whatever TSE showed
  // there, for example TSE's menu bar.
  #if EDITOR_VERSION >= 4400h
    Set(Transparency, Query(Transparency))
    UpdateDisplay()
  #endif

  return(ok)
end browse_list


integer proc write_profile_str(string section_name,
                               string item_name,
                               string item_value)
  integer result = FALSE
  result = WriteProfileStr(section_name,
                                   item_name,
                                   item_value)
  if not result
    Warn('ERROR: Unable to write new font to TSE configuration.')
  endif
  return(result)
end write_profile_str


integer proc add_new_font_to_device_context()
  integer new_font_handle = 0
  // Select the font width the specified name, width and height for the
  // Unicode line. Because width is zero, the requested height is leading.
  // In practice this function always returns a font handle, either of the
  // requested font or of a closest matching font, or of a default font.
  new_font_handle = CreateFontA(unicode_font_height,
                                unicode_font_width,
                                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                unicode_font_name)

  // In theory the returned handle can be NULL, in tests it never was.
  if new_font_handle
    if unicode_font_handle
      DeleteObject(unicode_font_handle)
    endif
    unicode_font_handle = new_font_handle

    // Attach the selected font to our Unicode device context.
    SelectObject(unicode_device_context_handle, unicode_font_handle)

    // Set the Unlicode line's foreground text and background line color.
    SetTextColor(unicode_device_context_handle, unicode_text_color)
    SetBkColor  (unicode_device_context_handle, unicode_background_color)
  endif

  return(unicode_font_handle)
end add_new_font_to_device_context


proc configure()
  if NumHistoryItems(GetFreeHistory(MACRO_NAME + ':UnicodeFont')) == 0
    AddHistoryStr('Arial Unicode MS', GetFreeHistory(MACRO_NAME + ':UnicodeFont'))
    AddHistoryStr('Unifont'         , GetFreeHistory(MACRO_NAME + ':UnicodeFont'))
    AddHistoryStr('Courier New'     , GetFreeHistory(MACRO_NAME + ':UnicodeFont'))
    Warn("Possibly not-installed fonts have been added to the prompt's history.")
  endif

  Message("You are selecting a new font for the browser's display line ...")
  if Ask('New font:   (Mistyping or a non-existing font selects a closest default font.)',
         unicode_font_name,
         GetFreeHistory(MACRO_NAME + ':UnicodeFont'))
    if add_new_font_to_device_context()
      Warn('A new font for the display line has been set, and is effective immediately.')
      Warn('If "', unicode_font_name, '" is not installed, then the closest matching font was set.')
      write_profile_str(MACRO_NAME + ':Config', 'FontName', unicode_font_name)
    else
      Warn('ERROR: Failed to set the requested font for the display line.')
    endif
  endif
end configure


integer proc process_arg_group(string  ansi_arg_in,
                               integer ads_only,
                               integer load_all,
                               integer load_binary,
                               integer search_subdirs)
  integer again                             = FALSE
  string  ansi_arg           [MAXSTRINGLEN] = ansi_arg_in
  string  selected_list_file [MAXSTRINGLEN] = ''
  string  utf8_name          [MAXSTRINGLEN] = ''
  string  utf8_path          [MAXSTRINGLEN] = ''
  string  utf8_selected      [MAXSTRINGLEN] = ''

  if standardize_file_specification(ansi_arg,              // In.
                                    utf8_path, utf8_name)  // Out.
    if search_subdirs
    or Pos('*', utf8_name)
      // There was not one specific file requested.
      repeat
        again = FALSE
        if create_list(utf8_path, utf8_name, ads_only, search_subdirs)
          if load_all
            load_list(utf8_path, load_binary)
          else
            ansi_arg = string_utf8_to_ansi(utf8_path + SLASH + utf8_name)
            if browse_list(ansi_arg, selected_list_file)
              case browse_action
                when ''
                  NoOp()
                when 'BrowseToDir'
                  // Currently requires a pathless name.
                  utf8_selected = selected_list_file
                  if utf8_selected == '..'
                    if has_parent_path(utf8_path)
                      utf8_path = RemoveTrailingSlash(SplitPath(utf8_path, _DRIVE_|_PATH_))
                      again     = TRUE
                    endif
                  else
                    if is_fqn(utf8_selected)
                      utf8_path = utf8_selected
                    else
                      utf8_path = utf8_path + SLASH + utf8_selected
                    endif
                    again = TRUE
                  endif
                when 'EditList'
                  edit_list(utf8_path)
                when 'OpenFile'
                  utf8_name = selected_list_file
                  if is_fqn(utf8_name)
                    utf8_path = RemoveTrailingSlash(SplitPath(utf8_name, _DRIVE_|_PATH_))
                    utf8_name = SplitPath(utf8_name, _NAME_ |_EXT_ )
                  endif
                  open_file(utf8_path, utf8_name, load_binary)
                otherwise
                  Warn('Action "', browse_action, '" is not supported yet.')
              endcase
            endif
          endif
        endif
      until not ok
         or not again
    else
      // One specific file was requested.
      open_file(utf8_path, utf8_name, load_binary)
    endif
  endif

  return(ok)
end process_arg_group

integer proc process_user_input(string user_input)
  integer ads_only                 = FALSE
  string  arg       [MAXSTRINGLEN] = ''
  string  arg_group [MAXSTRINGLEN] = ''
  integer configuration            = FALSE
  integer i                        = 1
  integer load_all                 = Query(LoadWildFromInside)
  integer load_binary              = 0
  integer load_list                = FALSE
  integer num_args                 = 0
  integer search_subdirs           = FALSE
  while ok
  and   i <= NumFileTokens(user_input)
    num_args  = num_args + 1
    arg       = GetFileToken(user_input, i)
    arg_group = Trim(arg_group + ' ' + arg)
    arg       = unquote(arg)
    if     Lower(arg) == '-a'
      load_all = TRUE
    elseif Lower(arg) == '-a-'
      load_all = FALSE
    elseif Lower(arg) == '-b'
      load_binary = 64
    elseif Lower(arg[1:2]) == '-b'
    and    Val(arg[3:MAXSTRINGLEN]) <> 0
      load_binary = Val(arg[3:MAXSTRINGLEN])
    elseif Lower(arg) == '-c'
      configuration = TRUE
    elseif Lower(arg) == '-d'
      ads_only = TRUE
    elseif Lower(arg) == '-f'
      load_list = TRUE
    elseif Lower(arg) == '-s'
      search_subdirs = TRUE
    else
      arg            = RemoveTrailingSlash(arg)
      arg            = StrReplace('?', arg, '*', '')
      if load_list
        load_listed_files(arg)
      else
        process_arg_group(arg, ads_only, load_all, load_binary, search_subdirs)
      endif

      // Reset group properties.
      arg_group      = ''
      num_args       = 0
      ads_only       = FALSE
      load_all       = Query(LoadWildFromInside)
      load_binary    = 0
      load_list      = FALSE
      search_subdirs = FALSE
    endif
    i = i + 1
  endwhile
  if ok
    if configuration
      configure()
    elseif load_list
      load_listed_files('')
    elseif arg_group <> ''
      abort('No file after "' + arg_group + '".')
    endif
  endif
  return(ok)
end process_user_input

proc get_user_input()
  string user_input [MAXSTRINGLEN] = Trim(Query(MacroCmdLine))
  if user_input == ''
    if Ask(MACRO_NAME + ': [' + RemoveTrailingSlash(CurrDir()) + ']',
           user_input,
           GetFreeHistory(MACRO_NAME + ':Prompt'))
      // ExecMacro('log open Edit2_' + Str(GetTime()) +'.log')
      // ExecMacro('Log write Start ...')
      user_input = Trim(user_input)
      if user_input == ''
        user_input = RemoveTrailingSlash(CurrDir())
      endif
      process_user_input(user_input)
      // ExecMacro('Log write End.')
      // ExecMacro('log close')
    endif
  else
    process_user_input(user_input)
  endif
end get_user_input

proc after_file_save()
  integer command_return_code          = 0
  integer dos_errorlevel               = 0
  integer dos_io_result                = 0
  integer dos_result                   = 0
  integer is_ADS                       = FALSE
  integer old_FileChanged              = 0
  integer old_Insert                   = 0
  integer org_id                       = 0
  string  utf8_filename [MAXSTRINGLEN] = ''

  if on_save_filename <> ''
    old_FileChanged  = FileChanged()
    ChangeCurrFilename(on_save_filename, CHANGE_CURR_FILENAME_FLAGS)
    FileChanged(old_FileChanged)

    is_ADS           = (NumTokens(SplitPath(on_save_filename, _NAME_|_EXT_), ':') > 1)
    utf8_filename    = string_ansi_to_utf8(on_save_filename)
    on_save_filename = ''
    old_Insert       = Set(Insert, ON)
    org_id           = GetBufferId()

    GotoBufferId(BAT_ID)
    EmptyBuffer()
    AddLine('chcp 65001')
    if is_ADS
      AddLine('more < ')
      EndLine()
      insert_quoted_text(TMP_FILE)
      InsertText(' > ')
      insert_quoted_text(utf8_filename)
      EmptyBuffer(OUT_ID)
    else
      AddLine('move /y ')
      EndLine()
      insert_quoted_text(TMP_FILE)
      InsertText(' ')
      insert_quoted_text(utf8_filename)
      InsertText(' > ')
      insert_quoted_text(out_file)
      InsertText(' 2>&1')
    endif
    if not SaveAs(BAT_FILE, SAVEAS_FLAGS)
      abort('Saving "' + BAT_FILE + '".')
      GotoBufferId(org_id)
    endif

    if  ok
    and KeyPressed()
    and GetKey() == <Escape>
      abort('You escaped!')
      GotoBufferId(org_id)
    endif

    if ok
      dos_result          = Dos(BAT_FILE, DOS_SYNC_CALL_FLAGS)
      dos_io_result       = DosIOResult()
      command_return_code = HiByte(dos_io_result)
      dos_errorlevel      = LoByte(dos_io_result)
      if not dos_result
      or     command_return_code
      or     dos_errorlevel
        GotoBufferId(OUT_ID)
        EmptyBuffer()
        LoadBuffer(OUT_FILE)
        UpdateDisplay(_ALL_WINDOWS_REFRESH_)
        abort('Saving non-ANSI filename failed.')
        GotoBufferId(org_id)
      endif
    endif

    ok = TRUE
    GotoBufferId(org_id)
    Set(Insert, old_Insert)
  endif
end after_file_save

proc on_file_save()
  if StrFind('\d127[0-9A-Fa-f]#\d127', CurrFilename(), 'x')
    on_save_filename = CurrFilename()
    ChangeCurrFilename(TMP_FILE, CHANGE_CURR_FILENAME_FLAGS)
  endif
end on_file_save

proc WhenPurged()
  if ok
    EraseDiskFile(BAT_FILE)
    EraseDiskFile(ERR_FILE)
    EraseDiskFile(OUT_FILE)
    EraseDiskFile(TMP_FILE)
    AbandonFile(BAT_ID)
    AbandonFile(ERR_ID)
    AbandonFile(CONV_ID)
    AbandonFile(LIST_ID)
    AbandonFile(OUT_ID)
  endif

  if isGUI()
    // xx Maybe: DeleteObject(unicode_font_handle)
    ReleaseDC(GetWinHandle(), unicode_device_context_handle)
  endif
end WhenPurged

proc WhenLoaded()
  string  tmp_dir [MAXSTRINGLEN] = RemoveTrailingSlash(GetEnvStr('TMP'))
  integer process_id             = 0

  MACRO_NAME = SplitPath(CurrMacroFilename(), _NAME_)

  if not isGUI()
    abort('The tool ' + MACRO_NAME + ' is not compatibel with the Console version of TSE.')
  elseif not (FileExists(tmp_dir) & _DIRECTORY_)
    abort('Environmont variable TMP refers to "' + tmp_dir + '".')
  endif

  if ok
    process_id = get_process_id()

    BAT_FILE = tmp_dir + SLASH + 'Tse_' + MACRO_NAME + '_' + Str(process_id) + '.bat'
    ERR_FILE = tmp_dir + SLASH + 'Tse_' + MACRO_NAME + '_' + Str(process_id) + '.err'
    OUT_FILE = tmp_dir + SLASH + 'Tse_' + MACRO_NAME + '_' + Str(process_id) + '.out'
    TMP_FILE = tmp_dir + SLASH + 'Tse_' + MACRO_NAME + '_' + Str(process_id) + '.tmp'

    PushLocation()
    BAT_ID   = CreateTempBuffer()
    ChangeCurrFilename(MACRO_NAME + ':bat' , CHANGE_CURR_FILENAME_FLAGS)
    CONV_ID  = CreateTempBuffer()
    ChangeCurrFilename(MACRO_NAME + ':conv', CHANGE_CURR_FILENAME_FLAGS)
    ERR_ID   = CreateTempBuffer()
    ChangeCurrFilename(MACRO_NAME + ':err' , CHANGE_CURR_FILENAME_FLAGS)
    OUT_ID   = CreateTempBuffer()
    ChangeCurrFilename(MACRO_NAME + ':out' , CHANGE_CURR_FILENAME_FLAGS)
    LIST_ID  = CreateTempBuffer()
    ChangeCurrFilename(MACRO_NAME + ':list', CHANGE_CURR_FILENAME_FLAGS)
    ANSI_ID  = CreateTempBuffer()
    ChangeCurrFilename(MACRO_NAME + ':ansi', CHANGE_CURR_FILENAME_FLAGS)
    PopLocation()

    Hook(_ON_ABANDON_EDITOR_, WhenPurged)
    Hook(_ON_FILE_SAVE_     , on_file_save)
    Hook(_AFTER_FILE_SAVE_  , after_file_save)

    // Default to the TSE's font and its properties for the display line.
    GetFont(unicode_font_name, unicode_font_size, unicode_font_flags)
    GetCharWidthHeight(unicode_font_width, unicode_font_height)

    // Override TSE's font for the display line if the user configured a font.
    unicode_font_name = GetProfileStr(MACRO_NAME + ':Config', 'FontName', unicode_font_name)

    // Create the Unicode line's own device context for this TSE session.
    unicode_device_context_handle = GetDC(GetWinHandle())

    // For the Unicode line we do not care about CreateFont's font width.
    // We do care about its height!
    unicode_font_width = 0

    add_new_font_to_device_context()
  else
    PurgeMacro(MACRO_NAME)
  endif
end WhenLoaded

proc Main()
  integer old_Insert                = Set(Insert               , ON)
  integer old_InsertLineBlocksAbove = Set(InsertLineBlocksAbove, ON)
  integer old_MsgLevel              = Set(MsgLevel             , _WARNINGS_ONLY_)
  if ok
    PushBlock()
    get_user_input()
    PopBlock()
  endif
  ok = TRUE
  Set(InsertLineBlocksAbove, old_InsertLineBlocksAbove)
  Set(Insert               , old_Insert               )
  Set(MsgLevel             , old_MsgLevel             )
end Main

