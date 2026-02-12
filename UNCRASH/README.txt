===

1. -To install

     1. -Take the file uncrash_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstalluncrash.bat

     4. -That will create a new file uncrash_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          uncrash.mac

2. -The .ini file is the local file 'uncrash.ini'
    (thus not using tse.ini)

===

/*
  Macro           UnCrash
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE Pro  v4.0      upwards
                  Windows TSE Beta v4.41.37a upwards
  Version         v1.1   19 Jan 2022


  SUMMARY

  UnCrash now has two functions.

  1.  If Windows crashed during any open TSE sessions, then,
      when you have restarted Windows and you restart TSE sessions,
      UnCrash will offer to restore the crashed TSE sessions until you
      explicitly "delete" them. (No backups are deleted.)

      Here "TSE session" only refers to its pre-crash _NORMAL_ buffers'
      content, FileChanged() status, and binary mode,
      not to any other buffer or editor properties.

  2.  UnCrash works by continously making backups of versions of files.
      At any time you can list those backups by executing UnCrash.
      In the list you can type part of a filename to reduce the list.
      By selecting a version of a file you "undelete" it: The new file gets the
      original file's name with a date, time and sequence number added to it.


  DISCLAIMER

  UnCrash is not and will never be perfect.
  It has limited ambitions and is limited by factors it has no control over.
  You still need to check the files in a restored session before saving them.

  UnCrash might contain unknown errors and thereby damage files and anything
  depending on those files.

  Use UnCrash at your own risk, or simply do not use it at all.


  CLAIMER

  I use UnCrash in my everyday editing with TSE, and have in practice
  successfully restored crashed TSE sessions with it after Windows crashes.


  INSTALLATION

  Put this file in TSE's "mac" folder.

  Compile it there, for example by opening the file in TSE and applying
  the Macro Compile menu.

  Add this file's name "UnCrash" to TSE's Macro AutoLoad List menu.

  Optionally execute the macro UnCrash to configure:
  - A non-default backup folder.
  - Every how many minutes to check for changes.
  - To only check after how many seconds of no typing.


  DESCRIPTION

  After you start TSE and it reaches its editing mode, UnCrash will offer to
  restore any previously crashed "TSE session".

  Here a "TSE session" only refers to its pre-crash _NORMAL_ buffers' content,
  FileChanged() status, and binarymode.

  A TSE crash is typically caused by Windows crashing. Just closing TSE,
  even after a TSE error, does usually not constitute a crash. Ending a TSE
  session from Windows' Task Mananager does count as a crash.

  Uncrash works by every N minutes checking all _NORMAL_ buffers for changes,
  and if there are new changes since the last check by making a new backup.
  So on average you might still lose the last N/2 minutes of changes.
  You can configure N, weighing the amounts of backups (and where they are
  created) against how many minutes of changes you can accept to lose.

  UnCrash is efficient in these ways:
  - Never changed buffers are remembered but not backed-up.
  - It only backs up changed buffers that are changed since the last check.
  - It stops backing up for a few seconds when you start/are typing.
  - It automatically cleans up backed up TSE sessions if there are no crashed
    sessions and the backup files are older than yesterday.

  UnCrash is as safe as possible:
  - Each backup action writes to a new backup file, and a previous backup file
    is not immediately deleted, so a crash at the wrong time will not corrupt
    all a buffer's backup information.
  - For each backup file a checksum is logged, so a restore can avoid restoring
    a partially written or otherwise corrupt backup file, and will restore a
    previous version instead.

  UnCrash has these further advantages over Semware's AutoSave solution:
  - Same-named files in different directories are not backed up to the same
    backup file.
  - It also backs up and restores changed buffers with an unsavable name
    like "<unnamed-1>".
  - It restores a buffer to its pre-crash normal or binary mode.
  - It is session-based, meaning it restores *all* _NORMAL_ buffers from a
    crashed TSE session in one automatically offered action,
    including restoring unchanged buffers.
    This has you ASAP up and running again.

  UnCrash does NOT:
  - Back up buffers that are not changed.
    (In such a case it just restores the original disk files.)
  - Back up or restore TSE's _HIDDEN_ and _SYSTEM_ buffers.
  - Restore cursor positions.
  - Restore the current block, any clipboard, or the current folder.
  - Restore TSE settings.
  - Restore undo-history. After a session's restore you cannot undo changed
    buffers to a state before the restore.


  HISTORY

  v0.1        2 Jul 2021   ALPHA
    Initial version that continuously makes backups of the current TSE session,
    and does nothing else.

  v0.2   3 Jul 2021   ALPHA
    At the start-up of each TSE session UnCrash asks which old sessions to
    delete.

  v0.3   3 Jul 2021   ALPHA
    Now also journals when a TSE session abandoned files.

  v0.4   7 Jul 2021   ALPHA
    Now also keeps a day journal of started and closed sessions.
    A session writes its closing to the journal of the day it started in.
    These day journals can later be used to differentiate crashed TSE sessions
    from properly closed ones.

  v0.5   14 Jul 2021   BETA
    Now seems to perform its basic function of sufficient logging and backups,
    and after a crash offering to restore the crashed TSE session.
    If there are no crashed TSE sessions, then it automatically deletes logging
    and backups older than two days.

  v0.5.1   24 Jul 2021   BETA
    Fixed: UnCrash saw still open concurrent TSE sessions as not-closed and
    therefore as crashed, and offered to restore them.

  v0.5.2   26 Jul 2021   BETA
    Fixed:
      Before each backup of an extremely large buffer UnCrash froze TSE
      from many seconds to up to a few minutes. This was fixed by making the
      determination of a checksum a lot faster and a bit less precise for
      buffers larger than 1 MB. In (my) practice those are typically binary
      files and log files, which are usually not modified and therefore not
      backed up by UnCrash anyway.

      During each backup of an extremely large buffer UnCrash might still
      freeze TSE for a few seconds: this is simply the time TSE needs to
      save a new backup of the file.

  v0.5.3   27 Jul 2021   BETA
    Fixed: A bug caused UnCrash to make way more backups than configured.

  v0.6     29 Jul 2021   BETA
    Improved:
    - A restore now recreates buffers in the order they were CREATED prior to
      the crash, instead of in a somewhat random reverse order.
      Note that this is closer to but might still differ from their pre-crash
      order in TSE's ring of files.
      For example, if pre-crash file-1 and file-2 were opened, and then file-3
      was opened from file-1, then their pre-crash order will be
      file-1, file-3, file-2, but their restored post-crash order will be
      file-1, file-2, file-3.
    - The documentation.
    Fixed:
    - Buffers named "<unnamed-N>", like the ones created by the File New menu,
      were sometimes restored with a different "N" name-part.
    - Pre-crash abandoned buffers were reported as unrestorable.
      They should not be restored, so it was just an annoying message.

  v1        30 Jul 2021
    First production version.
    UnCrash no longer has any known errors or problems,
    and there are no longer any significant outstanding requirements.

  v1.0.1    26 Nov 2021
    Fixed that if you started typing immediately after starting TSE,
    then UnCrash could "eat" some of those keystrokes, making TSE ignore them.

  v1.0.2    28 Nov 2021
    Documented the now known error, that sometimes UnCrash offers to restore
    a crashed session when there has been no crash.

  v1.0.3    4 Dec 2021
    Fixed a bug which probably sometimes caused a not crashed TSE session to be
    reported as crashed.

  v1.0.4    5 Dec 2021
    Fixed an additional and more specific case, that if you started TSE the
    first time of a day and started typing immediately, then UnCrash could
    "eat" some of those keystrokes, making TSE ignore them. This fix has the
    additional benefit, that it makes TSE start faster the first time of a day.

    Alas, it turns out that, while v1.0.3 fixed a bug, it did not fix the
    occasional unwarranted report of a crashed TSE session.

  v1.0.5    5 Dec 2021
    Solved an unwarranted TSE crash report.

  v1.0.6    8 Dec 2021
    Solved that crash reports from previous days could not be deleted.

  v1.0.7   10 Dec 2021
    Solved that UnCrash interpreted and reported a TSE session as crashed,
    if the Windows TSE GUI version's close button was used to exit the editor.

    Macro programmer note:
    On 9 Dec 2021 I reported this TSE bug in the beta mailing list:
    TSE GUI's close button does not call the _ON_ABANDON_EDITOR_ hook.
    The way UnCrash now circumvents this bug is not applicable to other macros.

    Later macro programmer note:
    In TSE v4.41.46 upwards this TSE bug was fixed.
    Uncrash needs no adaptation for that.

  v1.1     19 Jan 2022
    Added a user-friendly interface to at any time list and retrieve UnCrash's
    backup files.

    Fixed Uncrash v1.0.7 showing a system buffer if it was started manually.

    Undid the change in v1.0.7 to not report a crash if the Close button of the
    GUI version of an older TSE version than v4.41.46 was used.
    Semware improved the Close button in TSE v4.41.46, so UnCrash's fix is no
    longer necessary for newer versions of TSE and even hampered it, and it was
    too much work to make UnCrash support both the fixed and older versions of
    TSE when there is a free public newer TSE version available.

*/




