[kn, ri, su, 11-12-2022 10:45:44]

Always save your work first (as I experienced already at least one crash without warning when trying to run proj.mac)

===

What needs to be done:

1. -copy the DLL file 'msbsc60.dll' to your TSE main directory
    (otherwise you will see the error 'Cannot load DLL')

2. -edit and save the file proj0200.inc and change the path to where you installed this project (e.g. location of proj.si)
    and where the file 'pjfile.mac' is located.
    (otherwise you will see the error 'Cannot load macro')

     E.g.

      f:\bbc\taal\proj0200\pjfile.mac

3. -You must create a new directory called 'PJ'
    in your TSE main directory

4. -To install

     1. -Take the file proj0200_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallproj0200.bat

     4. -That will create a new file proj0200_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

5. -To run the menu start

     proj.mac -m

     or press <ALT P> to see the menu

6. -Note: The keys (e.g. <ALT P>) are defined in the file 'keys.si'

7. -The .ini file is the file proj0200.ini in the same directory
    (so you are not using tse.ini anymore, so keeping everything
    as much independent as possible.

===


Info for PROJ macro v2.00 (05/19/2002).
by Chris Antos, chrisant@premier1.net



Description:

    Project manager for keeping track of projects with many files.



DOS vs Windows:  PROJ is designed for use with TSE 2.8 and higher.
                 You can also get it to work with TSE 2.6 if you edit
                 the macro source (particularly CTAGS.SI) on your own.
                 It does not work with TSE 2.5 or earlier, period.



-- SETUP --------------------------------------------------------------

1.  Copy the following files to your Mac\ directory:
        - PROJ.MAC
        - PJFILE.MAC
        - PROJDLL.DLL
        - PROJ.HLP
        - GETHELP.MAC
        - HELPHELP.MAC

2.  Start TSE

3.  PROJ will automatically set itself up the first time you load it:
        - Select "Macro" from TSE's main menu
        - Select "Execute..."
        - Type "proj" and press <Enter>


That's all!  PROJ will display a welcome message and walk you through
the simple setup process (it's short).



* Note: if TSE complains "Macro compiled with wrong version", then see
  the "NOTES" section below.

* CTags: there is now support for CTags!  Just make sure CTAGS.EXE is in
  the same directory as your TSE executable.  CTags is available from
  http://home.hiwaay.net/~darren/ctags/

* BSC: Microsoft's BSC (source browse info) files are now supported!
  You can download the necessary DLL from
  http://support.microsoft.com/download/support/mslfiles/BSCKIT60.EXE
  (substitute 50, 41, 40, etc if you need the kit for VC5, VC4.1, VC4,
  etc).  If the link does not work, visit http://www.microsoft.com and
  do a search for "bsc toolkit".



-- NOTES --------------------------------------------------------------

- PROJ comes pre-configured for use with TSE 4.0, but it's pretty easy
  to get it to work with TSE 2.8 or TSE 3.0:

        1.  Unzip all the files from the .Zip file
        2.  Enter the following commands at the DOS prompt:
                SC32 PROJ.SI
                SC32 PJFILE.SI
                SC32 GETHELP.SI
                SC32 HELPHELP.S
        3.  Follow the Setup instructions above.



-- MACRO INTEGRATION --------------------------------------------------

- SetGlobalInt("PROJ_FlatFilePrompt", TRUE) before displaying a prompt
  to force enable the flat file list.

- ExecMacro("PROJ_GetFilePath filename.ext") looks up "filename.ext" in
  the current project's file list.  If an exact match is found,
  MacroCmdLine is set to the full pathname of the match.  If multiple
  matches are found, MacroCmdLine is set to "-1".  If no matches are
  found, MacroCmdLine is set to "".

- SetGlobalStr("PROJ_Prefix", <prefix>) is the prefix used in search
  result files, such as from Find() and from popular Grep macros.  If
  this variable is not set, the default is "File:".  [NOT USED 06/05/97]

- SetGlobalStr("PROJ_OpenPath", <searchpath>) is the search path used to
  find files when using the Open File At Cursor command (<F12>).

- ExecMacro("PROJ_OpenFileAtCursor") opens file at cursor.

- ExecMacro("PROJ_GrepWholeProject") greps all files in the project for
  the specified word/phrase.




-- HISTORY ------------------------------------------------------------

v2.00 (released 05/19/2002) -----------------------------------

- NEW: supports TSE4.0 (also still supports TSE2.8 and higher).

- The last official release was PROJ v1.10 in 1998.  Since then all
  kinds of improvements and fixes have gone into the PROJ macro.  Most
  are listed below, but there are probably some that didn't make it into
  this list; sorry, I've lost track.

- Sadly, the help has remained essentially unchanged, so it's still
  "under construction".


v1.50 (never released) ----------------------------------------

- NEW: added .BSC support for MSVC browse files!

- uses new TSE3.0 SaveHistory/LoadHistory commands

- NEW: supports new TSE3.0 ReadOnlyBuffer command (saves/restores
  buffer's readonly state -- not same as a file's readonly attribute)

- done: commands to save/load clipboard (public procs, even!)

- NEW: supports autoloading Local projects, i.e. "local.pj" in the
  current directory

- lots of other miscellaneous changes and fixes.


v1.11 (never released) ----------------------------------------

- fixed: oops, compiling for TSE2.6 left out CTags support!

- fixed: two commands were trying to display listboxes 82 characters
  wide, so if the "screen" was not at least 82 characters wide, they
  failed.

- done: BACKGROUND THREAD for building file list!  MUCH faster and
  smoother!

- done: PgUp/Dn and Ctrl-PgUp/Dn now work in the file list


v1.10 ---------------------------------------------------------

- CTags support!  <F11> jumps to tag definition, <AltShift F11> displays
  Tags menu (from here you can generate tags file for a directory or
  reload a tags file, or use several other handy commands).  even if the
  current file is not in a project, you can still use CTags for that
  file's directory!  Make sure CTAGS.EXE is located in the same
  directory as your TSE executable.  CTags is available from
  http://home.hiwaay.net/~darren/ctags/

- fixed: if project filename contained a period (eg, "MyThing v1.0") the
  keyboard macros were saved to an incorrect filename and were not able
  to be reloaded

- fixed: default extensions got erased if you went to open a project and
  then canceled (or went to create a new project and canceled, etc)

- done: fully qualify paths entered in the "include files in this
  path" prompt

- fixed: "include loaded files in project?" prompt was pretty
  misleading, changed to "close all open files?"

- fixed: adding paths to the project was not clearing the file list
  before rebuilding it, resulting in duplicates

- done: can add paths to exclude; all files in that path and subdirs
  are excluded from the project (can be overridden on specific
  directories by explicitly listing the directory to include; cannot
  override subdir behavior, though)

- fixed: for some users crash could happen (was trying up to 32 windows,
  but GotoWindow didn't have error checking to fail when appropriate)

- fixed: cancel when creating new project did not cancel correctly


v1.00 ---------------------------------------------------------

- done: initial version with flat file list.  also saves list of files
  in use, windows in use, keyboard macros, marked block.

- done: auto load directories; automatically load associated project
  when started from matching directory.

- removed: when user opens a .PJ file, automatically open it as a
  project (see PROJECTS.S for example).  [REMOVED: causes bug where
  syntax hiliting does not work]

- done: do matching on "foo\foo" in flat file list.

- done: when saving list of open files, it saves several TSE settings
  with each filename, in case user is running a macro that remembers TSE
  settings on a per-file basis, such as FS.MAC.

- done: '-P' dos command line option forces not to load a project.

- done: '-Pproject_file' dos command line option loads project
  "project_file".

- fixed: when compile macro, reload, open project again, why does it
  not go to the file i was last editing??  [FIX: only try to load a
  project in WhenLoaded if NumFiles() == 0]

- fixed: why no OnFirstEdit for files we load in initial project??
  [FIX: because the loading was occurring in an OnFirstEdit hook]

- added: project-wide grep command, requires Grep v2.2.

- done: saves/restores TSE clipboard

- done: Open Project gives a menu of all known projects, plus an "Open
  other project..." command.

- done: before opening a project, prompts to save loaded files.

- done: after opening a project, closes files that were not open last
  time project was saved.

- done: database is stored in LoadDir, project files are stored in
  user-configurable subdirectory of LoadDir.

- done: first time you execute PROJ on your machine, it automatically
  steps you thru getting it set up.

- done: if TSE clipboard is > 500 lines, prompt before saving it.

- done: if you enter a filename (with no drive or path) that does not
  match a filename in the project, and the file is not found in the
  current directory, the OpenPath is searched (the same path used by
  OpenFileAtCursor).

- done: you can specify what file extensions are recognized by each
  project.  hit <Alt P>, "Project Settings", "Known File Types".

- fixed: when opening a project, if a file wasn't found, user could be
  left in an empty system file.

- fixed: when opening a project, if an error occurred while saving a
  file that was open, it was not aborting the open, so the new project
  still got opened.  now it aborts, so the new project is not opened.



-- WISH LIST ----------------------------------------------------------

- see comments scattered thru the .SI source files.  (look for "//$")

