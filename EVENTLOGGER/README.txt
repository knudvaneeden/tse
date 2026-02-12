===

1. -To install

     1. -Take the file eventlogger_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstalleventlogger.bat

     4. -That will create a new file eventlogger_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          eventlogger.mac

2. -The .ini file is the local file 'eventlogger.ini'
    (thus not using tse.ini)

===

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
