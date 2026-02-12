===

1. -To install

     1. -Take the file syncase_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallsyncase.bat

     4. -That will create a new file syncase_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          syncase.mac

2. -The .ini file is the local file 'syncase.ini'
    (thus not using tse.ini)

===

/*
  Macro           SynCase
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows and Linux TSE v4.41.19 upwards
  Version         7.0.1   19 Apr 2022


  INTRO

    Out of the box this TSE extension sets the keywords of TSE's macro language
    to their default Upper, lower, and CamelCase based on TSE's syntax hiliting
    configuration.

    You can enable this for SAL, and configure this for other languages.
    For either you can set non-keyword casing to UPPER or lower case.


  DISCLAIMER 1

    This TSE extension might contain unknown errors and damage your files and
    anything depending on those files.

    Use this TSE extension at your own risk or not at all.


  DISCLAIMER 2

    If you ever set one of TSE's "SyntaxHilite mapping Set" configuration
    options for "Ignore Case" to "On", then setting it back "Off" again will
    not work, and any case-sensitive syntax hiliting definitions are lost.

    This is a TSE design flaw. See this extension's Help for more info.

    SAL is an exception to this irreversability, in that this extension's
    configuration menu can "Set SAL to default case ..." again.

    Note: I have noticed that newer TSE versions do not even come with
          cased SAL syntax hiliting any more.


  QUICK INSTALL

    If your TSE version is lower than TSE v4.41.19, then do not install this
    file, but install the included SynCaseOld instead.

    Otherwise put this file and its auxiliary files in TSE's "mac" folder, open
    this file in TSE, and compile and execute it using the Macro, Compile menu.

    The first time SynCase is run after installing it you get the question:
      "Do you want automatic UPPER/lower/CamelCase for TSE macros?"
    Select "Yes", "OK" the Message, "Escape" the menu, and restart TSE.

    Later you can repeat this choice by executing "SynCase" as a macro and
    selecting "Set SAL to default case ...".


  DETAILED DESCRIPTION

    See: TSE menu -> Macro -> Execute "SynCase" -> Help.


  MAJOR VERSION CHANGE

    In version 7 SynCase's core functionality was rewritten to fix bugs,
    increase performance and accuracy, and extend capabilities.

    However, one capability was downgraded:
      SynCase v7 is no longer compatible with TSE versions before v4.41.19,
      which was released 14 December 2019.
      SynCase v7 increases its performance and accuracy by using TSE v4.41.19's
      new built-in CurrLineMultiLineDelimiterType() function.
      This function cannot be easily and efficiently emulated for older
      versions of TSE.
      Therefore SynCaseOld, which is a v6 version of of SynCase, is available
      for TSE v4 through v.4.41.18.

    Changes for users:
    - Increased performance and accuracy.
    - SynCase now uses all relevant syntax highlighting definitions:
      - Delimiters are now cased too, as if they were keywords.
        For example, in Windows batch scripts "rem" is a to-end-of-line
        delimiter, which can now be cased.
      - SynCase now recognizes quotes and escaped quotes.
        - It fixes Syncase not working after "/*" occurs in a quoted string.
        - It will no longer case a word after an escaped quote when such word
          is therefore still inside the quoted string.
      - SynCase now recognizes the Starting Column of a to-end-of-line
        delimiter.
        For example, in traditional COBOL a "*" character is only a
        to-end-of-line delimiter if it occurs on position 7, which can be
        configured in TSE's syntax hiliting. Using this, SynCase can now not
        case a COBOL comment line, and now does case words after a "*" in
        a COBOL "compute" statement.

    Technical changes:
    - Reindented this macro's source code from tab size 3 to 2.
    - To make SynCase debuggable it needed to be smaller, so two huge blocks
      of text (Sal definitions and Help text) were moved from datadefs to
      external files. The files are compressed, both to make them smaller and
      to prevent a user from arbitrarily changing their "factory" content.
    - Rewrote SynCase's core code, instigated by now using TSE v4.41.19's more
      efficient and accurate built-in CurrLineMultiLineDelimiterType() function.


  HISTORY
    6.0.0     11 jul 2017
      Re-release after major rewrite.
    6.0.1     19 Nov 2018
      Updated the isAutoLoaded() procedure to perform a tiny bit better
      with older TSE versions.

    7.0.0.0 BETA   28 Apr 2021
    - Reindented this macro's source code from tab size 3 to 2.
    - To make SynCase debuggable it needed to be smaller, so I moved two large
      blocks of text (Sal definitions and Help text) from datadefs to external
      files. I compressed the files, both to make them smaller and to prevent
      a user from arbitrarily changing their "factory" content.
    - Fixed Syncase not working after "/*" occurs in a quoted string.
      The technically efficient solution was to completely rewrite this macro's
      syntax_case_the_current_line() proc to use TSE v4.41.19's (14 Dec 2019)
      new, built-in CurrLineMultiLineDelimiterType() function.
    - Delimiters are now cased too, as if they were keywords.
    - SynCase now recognizes escaped quotes.
    - SynCase now recognizes a Starting Column for a to-end-of-line delimiter.
    - Tried to make SynCase compatible with the new sal.syn in TSE v4.41.45
      which wants to support "<" in Sal's syntax hiliting WordSet,
      but Sal.syn, syncfg.si an syncfg2.si are broken in TSE v4.41.45,
      so there is no way to test this until TSE is fixed.

    7.0.0.1 BETA   22 Jan 2022
      Semware fixed syncfg2 in v4.41.46, so I can pick this up again.
      Fixed major bugs in recognizing keywords and non-keywords.

    7.0.0.2 BETA   22 Jan 2022
      Removed superfluous code.

    7.0.0.3 BETA   23 Jan 2022
      Added new SAL keywords to SynCase.def.
      Made SynCase's built-in Help show as a buffer instead of a list.

    7.0.0.4        17 Feb 2022
      Did some final tweaks before release.

    7.0.1          19 Apr 2022
      Bug fix for a reported error, caused by SynCase sloppily using EditFile()
      to create a temporary file, which caused other macros' _ON_CHANGING_FILES_
      hook to be called for the temporary file, which caused havoc.
*/
