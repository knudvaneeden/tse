===

1. -To install

     1. -Take the file efind_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallefind.bat

     4. -That will create a new file efind_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          efind.mac

2. -The .ini file is the local file 'efind.ini'
    (thus not using tse.ini)

===

/*
   Macro          EFind
   Author         Carlo.Hogeveen@xs4all.nl
   Date           13 October 2000
   Version        2.0.2
   Date           1 July 2006
   Compatibility  TSE Pro 2.5e upwards

   This macro allows you to search in a gigantic amount of open files.

   When more files are opened in TSE than fit in memory, then this
   macro can search across them without running into the memory limit.

   EFind relies on TSE's standard ability to open but not load files.
   For example, if you open multiple files in TSE using wildcards and the
   "-a" and "-s" options, then TSE only actually loads the file that becomes
   the new current file. The other files are "opened but not loaded", until
   you give a command that accesses their content. TSE's standard Find is
   such a command. When eFind searches across files, it only temporarily
   loads each unloaded file and then immediately unloads each of those those
   from memory again.

   Tip:
      Also see the AbanName macro, which can Abandon or Keep opened files
      based on their name, also without permanently loading unloaded files.

   Caveats:
   -  In TSE versions below 3.0 this macro changes each file's bufferid,
      which might upset other macros which depend on files always keeping
      their original bufferid.
   -  While this macro keeps files unloaded when possible, there are other
      macros and TSE commands which load all files anyway, getting your
      memory limit problem right back. It is your own responsibility not to
      use those other commands while using eFind on more files than fit in
      memory.

   There are some differences with the standard Find command, among which:
   -  Found words are not highlighted.
   -  In a View Finds list the file lines are not colored.
   -  The "n" option is assumed, it's absence will be ignored.

   Limitations:
      Because this macro's functionality encourages you to open enormous
      amounts of files in TSE, it is necessary to be aware of the following
      TSE-limitations.
      While according to its documentation from TSE Pro 3.0 upwards you can
      open up to 2,147,483,647 files, it is not safe to do so until TSE Pro
      versions after 4.4.
      Details in macro language:
      -  In TSE Pro version 3.0 thru 4.4 the AbandonFile() command only works
         for the first 32768 files.
      -  In TSE versions up to and including 4.4 bufferids above 65535 are not
         supported.
      -  Both TSE itself and macros rely heavily on both these features.
      Details in English:
      -  TSE Pro versions below 3.0 are unstable if you have
         loaded more than 65536 files during a TSE session.
      -  TSE Pro versions from  3.0 through 4.4 are unstable if you have
         loaded more than 32768 files during a TSE session.
      EFind checks for these limitations, and refuses to run if you have
      exceeded them.

   Formats:
      efind             (interactive mode)
      efind find        (interactive mode)
      efind find&do     (interactive mode)
      efind again
      efind find search_value search_options

      efind l           (low-level interactive mode)
      efind lfind       (low-level interactive mode)
      efind lfind&do    (low-level interactive mode)
      efind lagain
      efind lfind search_value search_options

   Installation:
      Copy this macro's source to TSE's "mac" directory and compile it there.
      It can be executed from the menu or attached to keys with the formats
      above.

   The beta versions of my macros can be found at:
      http://www.xs4all.nl/~hyphen/tse

   Wishlist (in random order):
      Integrate the bFind macro and add the "o" option to
      add Logical/Boolean Finds to the functionality.
      Replace.
      Extra "Find & Do" choices:
      -  Tse commands.
      S option to make searches span across lines.
      S option to replace across lines (also joining and splitting lines).
      <Ctrl E> to edit found lines in all files at once.
      Implementing TSE's standard N option.
      Adding a P option to Preview replacements.
      To hilight found strings.


   History:

   v0.00    Multiple not public releases from 13 October 2000 onwards.

      14 November 2000.
         Solved a bug, and added the <alt e> key to edit the found list.
      15 November 2000.
         The macro now returns the number of found lines as a string
         in TSE's MacroCmdLine variable.
         Note: If the user presses Escape in the found list we get after using
         the "v" option, then zero is returned.
         Added the "l" functions to emulate TSE's low-level lFind and lReplace
         commands: no messages and no beeps.
      16 November 2000.
         Bug solved: the "a" option should only cause a search to start at the
         begin or end of the current file when combined with the "v" option.
         Also a close current line for the view list is determined.
      19 November 2000.
         Bug solved: When using option "a", it changed the cursor position
         in files it traversed.
         Very nasty bug solved: TSE has a limit of 65535 bufferids.
         Solution: reduced bufferids by reusing adminfinds_id and
         viewfinds_id instead of creating them anew for each call to eFind.
         Bug anticipated: now using an id-independent push_position, etc.
      12 March 2001.
         Adding optimizations for TSE 3.00.
      24 June 2005.
         Abandon File and Keep File implemented.
         Showing a progress percentage.

   v1.00    18 August 2005    First public release.

      Programmed a warning about the "number of files limitation" existing
      in TSE itself.

   v2.00    29 April 2006

      Altered checking TSE's version number.

      Removed eFind's dependency on Global.zip and MacPar3.zip: the cost
      is the loss in some functionality when passing parameters to the
      macro, for which functionality I have a strong indication that
      nobody was using it anyway.

      Removed very annoying warnings about split lines, at the risk of
      possibly removing some significant TSE-warnings warnings too.

   v2.01    4 May 2006

      Removed the not implemented "Replace" option from the menu and from
      the documentation.

      Added a pre-emptive check (including for regular expressions) to warn
      the user, that it is pointless to search for an empty string.

   v2.0.2   1 July 2007
      Solved a bug in and improved the way that the macro determines whether
      too many files were opened.

*/

/*

File: Source: FILE_ID.DIZ]

(Jul 1, 2007) - eFind v2.0.2 for TSE Pro v2.5e upwards.
This macro allows you to search in a gigantic amount of files.
TSE lets you open more files than fit in memory, and then this macro can
search across them without running into the memory limit.
It can also keep or abandon files which contain a certain string: you can do
this multiple times to step by step zero in on a selection of files.
v2.0.2 Improves the warning if too many files were opened.
Author: Carlo Hogeveen.

*/
