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




/*
  N O N - U S E R    D O C U M E N T A T I O N


  TODO INTERNAL MACRO STUFF
    MUST
    SHOULD
    COULD
    - Simplify most of the Warn() statements.
    - No need to administrate a backup file's name in fully qualified
      format.
    - Don't do a consecutive backup of a file if its new version was changed
      but has the same checksum again. This does not occur often, so it has no
      high prio.
    WONT


  TESTING

    I tested UnCrash by loading and creating a set of files in TSE, changing
    some of them, waiting until the configured UnCrash period had passed,
    and by then using Windows' Task Manager to "End task" the TSE session.


  BACKUP UNRELIABILITY

    UnCrash is not perfect.
    It is limited by TSE's limitations and by factors outside TSE.

    For example, Windows, a drive, and other solutions each might implement
    write-buffering. Data in such write-buffers might be lost in a Windows
    crash or a power outage.

    Worse, a disk buffer might do write order optimization, which increases
    write performance at the cost of maintaining the order in which files are
    written to disk.

    There is nothing this macro can do about that.

    It does try to minimize the effect of
      1. a crash occurring at an inopportune moment,
      2. partial or corrupt backup data.

    1.
      UnCrash gives each backup of a TSE buffer a new name and does not
      immediately delete previous backups of the same buffer.

      For the same reason UnCrash logs changes to its session information
      by adding them to a countinuously expanding journal file, never
      overwriting previous entries.

      So even if the latest session backup information itself gets lost or
      corrupted, there is always an earlier version available.

    2.
      When making a backup of a file UnCrash logs a checksum for the file's
      content, allowing a restore to ignore partial or otherwise corrupt
      backup files.


  CURRENT SESSION INFORMATION

    Uncrash maintains three _SYSTEM_ buffers:
    - A "session buffer" with each file's previous FileChanged() value.
      Its purpose is to be able to check if FileChanged() has changed.
    - A "journal buffer" containing one journal entry at a time.
      Its purpose is to log each _NORMAL_ buffer's new state.
    - A "backups buffer" with created, not yet deleted backup filenames.
      Its purpose is to be able to delete the current TSE session's old backups
      based on their creation date, time and file size.

    The journal buffer ususally contains one journal line at a time,
    always containing:
      current date and time,
      buffer id,
      FileChanged() or -1,  (-1 here means not-loaded)
    and if the file is still loaded, then also containing:
      BinaryMode(),
      fully qualified name,
    and if the file is FileChanged() or saved, then also containing:
      fingersmudge, otherwise an empty string,
    and if the file is FileChanged(), then also containing:
      backup name, otherwise an empty string.

    The session buffer maintains the following information for each _NORMAL_
    buffer:
      buffer id,
      FileChanged(),
      checkmark (0/1) for temporary use by the session check process.

    The backups buffer maintains one or more entries for each existing backup
    file of a _NORMAL_ buffer:
      buffer id,              (For debugging, may have a future use.)
      date and time,
      file size,
      backup name,
      fully qualified name.   (For debugging.)
    So this buffer might contain multiple entries with the same buffer id.


  DIRECTORY STRUCTURE

    UnCrash uses a root directory, in which it stores all its information.

    The location of this root directory can be configured in UnCrash.
    If the directory is not configured in UnCrash, then the subdirectory
    "Tse_UnCrash" in the Windows' directory for temporary files (as referred
    to by the TMP environment variable) is used.

    In its root directory UnCrash stores one day journal file per day and a
    session directory per TSE session.

    A session directory's name consists of the date and and time UnCrash was
    started (typically with the TSE session) plus the Windows process id
    of the TSE session, in the format
      YYYYMMDD_HHMMSSHH_P   (where process id P can be 1 to 10 digits)

    Each session directory contains a session journal file and renamed versions
    of backed up files for each backup of each logged change of each file.


    DAY JOURNAL FILE

      Each TSE session logs its changes in the day journal of the day that the
      session was started.

      A day journal file name has the format
        YYYYMMDD.log

      A day journal file's content has the format
        <session status change>*<session id>*<date time of status change>

        where
          <session status> is one of these value
            "Begin"
              The TSE session was started.
            "End"
              The TSE session was stopped normally without using
              the Windows TSE GUI version's close button.
            "Ignore"
              If the TSE session was aborted, e.g. by a Windows crash,
              and the user chose to delete the TSE session,
              then a status change "Ignore" is added in the journal.
          <session id> has format
            YYYYMMDD_HHMMSSHH_P   (where P is the 1 to 10 digit process id)
          <date time of status change> has format
            YYYYMMDD_HHMMSSHH

    SESSION JOURNAL FILE

      UnCrash administrates TSE sessions by continuously adding the information
      about session changes to a journal file "Journal.log".

      TSE session changes are:
      - A buffer was added to the session.
      - A buffer has a new, positive FileChanged() value.
      - A buffer's FileChanged() value has changed to 0 (_AFTER_FILE_SAVE_).
      - A buffer is no longer part of the session ("abandoned").

      For each newly changed buffer the journal file logs the buffer's
        buffer id,
        FileChanged() value, -1 for an abandoned buffer,
        BinaryMode(),
        fully qualified name,
        if FileChanged() > 0, then checksum of content, otherwise empty string,
        renamed backup filename.


    BACKUP FILE

      A backup file is named with the date and time the backup was created
      plus a counter to make certain the name is unique.

      Note that each backup, even of the same file, creates a new, newly named
      backup file.

      The backup filename has the format
        YYYYMMDD_HHMMSSHH_C
      where C can be 1 to 10 digits.

*/





// Start of compatibility restrictions and mitigations

#ifdef LINUX
  This macro is not Linux-compatible.
  Send a request if you would like it to be.
#endif

#ifdef LINUX
  #define WIN32 TRUE
#endif

#ifdef LINUX
  string SLASH [1] = '/'
#else
  string SLASH [1] = '\'
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



#if EDITOR_VERSION < 4200h
  /*
    MkDir() 1.0

    This procedure implements the MkDir() command of TSE 4.2 upwards.
  */
  integer proc MkDir(string dir)
    Dos('MkDir ' + QuotePath(dir),
        _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_)
    return(not DosIOResult())
  end MkDir
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

integer proc edit_this_file(string filename, integer flags)
  integer return_value = FALSE
  #if EDITOR_VERSION < 4200h
    return_value = EditFile(QuotePath(filename), flags)
  #else
    return_value = EditThisFile(filename, flags)
  #endif
  return(return_value)
end edit_this_file



// End of compatibility restrictions and mitigations.





/*
  Start of copy of code of v1.0.1 of the eList macro.
*/

integer eList_lst_linenos_id        = 0
integer eList_lst_text_id           = 0
integer eList_org_id                = 0
string  eList_typed  [MAXSTRINGLEN] = ''

/*
  The following function determines the minimum amount of characters that a
  given regular expression can match. For the practical purpose that they are
  valid matches too, "^" and "$" are pretended to have length 1.
  The purpose of this procedure is, to be able to beforehand avoid searching
  for an empty string, which is logically pointless because it always succeeds
  (with one exception: past the end of the last line).
  Searching for an empty string in a loop makes it infinate and hangs a macro.
  Properly applied, using this procedure can avoid that.
*/
integer proc eList_minimum_regexp_length(string s)
  integer addition           = 0
  integer i                  = 0
  integer NEXT_TIME          = 2
  integer orred_addition     = 0
  integer prev_addition      = 0
  integer prev_i             = 0
  integer result             = 0
  integer tag_level          = 0
  integer THIS_TIME          = 1
  integer use_orred_addition = FALSE
  // for each character.
  for i = 1 to Length(s)
    // Ignore this zero-length "character".
    if Lower(SubStr(s,i,2)) == "\c"
      i = i + 1
    else
      // Skip index for all these cases so they will be counted as one
      // character.
      case SubStr(s,i,1)
        when "["
          while i < Length(s)
          and   SubStr(s,i,1) <> "]"
            i = i + 1
          endwhile
        when "\"
          i = i + 1
          case Lower(SubStr(s,i,1))
            when "x"
              i = i + 2
            when "d", "o"
              i = i + 3
          endcase
      endcase
      // Now start counting.
      if use_orred_addition == NEXT_TIME
         use_orred_addition =  THIS_TIME
      endif
      // Count a Literal character as one:
      if SubStr(s,i-1,1) == "\" // (Using the robustness of SubStr!)
        addition = 1
      // Count a tagged string as the Length of its subexpression:
      elseif SubStr(s,i,1) == "{"
        prev_i = i
        tag_level = 1
        while i < Length(s)
        and   (tag_level <> 0 or SubStr(s,i,1) <> "}")
          i = i + 1
          if SubStr(s,i,1) == "{"
            tag_level = tag_level + 1
          elseif SubStr(s,i,1) == "}"
            tag_level = tag_level - 1
          endif
        endwhile
        addition = eList_minimum_regexp_length(SubStr(s,prev_i+1,i-prev_i-1))
      // for a "previous character or tagged string may occur zero
      // times" operator: since it was already counted, subtract it.
      elseif SubStr(s,i,1) in "*", "@", "?"
        addition = -1 * Abs(prev_addition)
      // This is a tough one: the "or" operator.
      // for now subtract the Length of the previous character or
      // tagged string, but remember doing so, because you might have
      // to add it again instead of the Length of the character or
      // tagged string after the "or" operator.
      elseif SubStr(s,i,1) == "|"
        addition           = -1 * Abs(prev_addition)
        orred_addition     = Abs(prev_addition)
        use_orred_addition = NEXT_TIME
      else
      // Count ordinary characters as 1 character.
        addition = 1
      endif
      if use_orred_addition == THIS_TIME
        if orred_addition < addition
          addition = orred_addition
        endif
        use_orred_addition = FALSE
      endif
      result        = result + addition
      prev_addition = addition
    endif
  endfor
  return(result)
end eList_minimum_regexp_length

proc eList_after_nonedit_command()
  string  find_options [3] = 'gix'
  integer last_key                = Query(Key)
  integer old_ilba                = Query(InsertLineBlocksAbove)
  integer old_uap                 = Query(UnMarkAfterPaste)
  integer old_msglevel            = Query(MsgLevel)
  integer org_lineno              = 0
  integer org_num_lines           = 0
  integer resized                 = FALSE
  if last_key in 32 .. 126
    eList_typed = eList_typed + Chr(last_key)
    resized     = TRUE
  elseif last_key == <BackSpace>
    if Length(eList_typed) > 0
      eList_typed = SubStr(eList_typed, 1, Length(eList_typed) - 1)
      resized     = TRUE
    endif
  endif
  if resized
    EmptyBuffer()
    GotoBufferId(eList_lst_linenos_id)
    EmptyBuffer()
    GotoBufferId(eList_org_id)
    PushPosition()
    PushBlock()
    UnMarkBlock()
    if Length(eList_typed) == 0
      Message('Start typing letters and digits or a TSE regular expression to shrink this list.')
      org_num_lines = NumLines()
      MarkLine(1, org_num_lines)
      Copy()
      GotoBufferId(eList_lst_text_id)
      Paste()
      GotoBufferId(eList_org_id)
    else
      Message('Lines matching with (reg exp) "', eList_typed,
              '".          Type more or <Backspace>.')
      old_ilba     = Set(InsertLineBlocksAbove, FALSE)
      old_msglevel = Set(MsgLevel             , _NONE_)
      old_uap      = Set(UnMarkAfterPaste     , TRUE)
      if eList_minimum_regexp_length(eList_typed) <= 0
        BegFile()
        EndLine()
        find_options = 'ix+'
      endif
      while lFind(eList_typed, find_options)
        org_lineno = CurrLine()
        MarkLine(org_lineno, org_lineno)
        Copy()
        GotoBufferId(eList_lst_text_id)
        Paste()
        Down()
        GotoBufferId(eList_lst_linenos_id)
        AddLine(Str(org_lineno))
        GotoBufferId(eList_org_id)
        EndLine()
        find_options = 'ix+'
      endwhile
      Set(InsertLineBlocksAbove, old_ilba)
      Set(MsgLevel             , old_msglevel)
      Set(UnMarkAfterPaste     , old_uap)
    endif
    PopPosition()
    PopBlock()
    GotoBufferId(eList_lst_text_id)
    BegFile()
  endif
end eList_after_nonedit_command

integer proc eList(string eList_title)
  integer lst_selected_lineno = 0
  integer org_selected_lineno = 0
  eList_org_id = GetBufferId()
  eList_typed  = ''
  PushPosition()
  PushBlock()
  MarkLine(1, NumLines())
  Copy()
  if eList_lst_linenos_id
    GotoBufferId(eList_lst_linenos_id)
    EmptyBuffer()
  else
    eList_lst_linenos_id = CreateTempBuffer()
    ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_) + ':lst_linenos',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  endif
  if eList_lst_text_id
    GotoBufferId(eList_lst_text_id)
    EmptyBuffer()
  else
    eList_lst_text_id = CreateTempBuffer()
    ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_) + ':lst_text',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  endif
  Paste()
  UnMarkBlock()
  Message('Start typing letters and digits or a TSE regular expression to shrink this list.')
  Set(Y1, 3)
  Hook(_AFTER_NONEDIT_COMMAND_, eList_after_nonedit_command)
  if lList(eList_title, LongestLineInBuffer(), Query(ScreenRows) - 3, _ENABLE_HSCROLL_)
    lst_selected_lineno = CurrLine()
  endif
  UnHook(eList_after_nonedit_command)
  if lst_selected_lineno <> 0
    GotoBufferId(eList_lst_linenos_id)
    GotoLine(lst_selected_lineno)
    org_selected_lineno = Val(GetText(1, MAXSTRINGLEN))
    if org_selected_lineno == 0
      org_selected_lineno = lst_selected_lineno
    endif
  endif
  GotoBufferId(eList_org_id)
  PopPosition()
  PopBlock()
  if org_selected_lineno
    GotoLine(org_selected_lineno)
    ScrollToCenter()
    BegLine()
    if eList_typed <> ''
      lFind(eList_typed, 'cgix')
      // in case of a regexp it can be nice to see what it actually matched:
      MarkFoundText()
    endif
    UpdateDisplay()
  endif
  Message('')
  return(org_selected_lineno)
end eList

/*
  End of copy of code of v1.0.1 of the eList macro.
*/





// Global constants
#define ALL_FILE_TYPES                       -1
#define CHANGE_CURR_FILENAME_FLAGS           _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
string  CHECKMARK                      [1] = 'v'
string  DATE_TIME_NUMBER_FORMAT       [89] = '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9]#$'
string  DELIMITER                      [1] = '*'  // Never part of filename.
#define DOS_SYNC_CALL_FLAGS                  _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_
#define DOS_ASYNC_CALL_FLAGS                 _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_|_RUN_DETACHED_|_DONT_WAIT_
#define FIRST_EQUAL_TO_SECOND                0
#define FIRST_NEWER_THAN_SECOND              1
#define FIRST_OLDER_THAN_SECOND              -1
#define MINIMUM_FINGERPRINT_BYTES            1000000
string  MY_MACRO_VERSION               [3] = '1.1'
#define NO_FILE_HANDLE                       -1
#define SESSION_DELETE                       1
#define SESSION_DELETE_ALL                   2
string  SESSION_LIST_FOOTER           [48] = '{Del}-Delete {Ctrl A}-delete All {Enter}-Restore'
#define SESSION_RESTORE                      3
#define SAVEAS_APPEND_FLAGS                  _DONT_PROMPT_|_APPEND_
#define SAVEAS_OVERWRITE_FLAGS               _DONT_PROMPT_|_OVERWRITE_
string  UNCHECKEDMARK                  [1] = '-'
string  UPGRADE_URL                   [40] = 'https://ecarlo.nl/tse/index.html#UnCrash'


// Global semi-constants, initialized only once.
integer BACKUPS_ID                         = 0
string  BACKUP_WORDSET                [32] = ''
string  MY_SESSION_ID                 [30] = ''
string  MY_DAY_JOURNAL_FQN  [MAXSTRINGLEN] = ''
string  MY_MACRO_NAME       [MAXSTRINGLEN] = ''
string  SESSION_JOURNAL_FQN [MAXSTRINGLEN] = ''
integer SESSION_JOURNAL_ID                 = 0
string  SESSION_PROCESS_ID            [12] = ''
string  SESSION_START_DATE_TIME       [17] = ''
integer SESSION_STATUS_ID                  = 0
string  SESSION_UNCRASH_DIR [MAXSTRINGLEN] = ''
string  TODAY                          [8] = ''
string  VARNAME_CFG_SECTION [MAXSTRINGLEN] = ''
string  YESTERDAY                      [8] = ''


// Global variables
integer backup_counter                     = 0
integer cfg_backup_period_in_minutes       = 0
integer cfg_no_typing_period_in_seconds    = 0
string  cfg_uncrash_dir     [MAXSTRINGLEN] = ''
integer last_key_time                      = 0
integer ok                                 = TRUE
integer prev_time                          = 0
integer reported_profile_error             = FALSE
integer checked_for_tse_crashes            = FALSE
integer session_action                     = _NONE_



#ifdef LINUX
  not implemented for linux.
#else
  dll "<Kernel32.dll>"
    integer proc GetCurrentProcessId(integer void)
  end

  integer proc get_current_process_id()
    return(GetCurrentProcessId(0))
  end get_current_process_id
#endif

integer proc rm_dir(string dir)
  string  cmd [MAXSTRINGLEN] = Format('rmdir /s /q'; QuotePath(dir))
  integer result             = FALSE
  Dos(cmd, DOS_ASYNC_CALL_FLAGS)
  result = DosIOResult()  // Note: Does not work correctly in Linux.
  return(result)
end rm_dir

/*
  A "fingersmudge" is a performance-optimized, accuracy-weakened version of a
  fingerprint, also known as a checksum.
  It turned out that SAL is too slow to determine the full fingerprint of very
  large files in real-time.
  A fingersmudge is less precise for files larger than N bytes, which in (my)
  practice means binary files and log files. Those are typically not files we
  modify in TSE, so for those files a weaker checksum in favor of much improved
  performance was deemed a very good solution for UnCrash.
  I have documented versions of get_buffer_fingerprint() and
  get_buffer_fingersmudge(), but dd 28 Jul 2021 have not published them.
  I will do so upon request.
*/
string proc get_buffer_fingersmudge(integer minimum_fingerprint_bytes)
  integer block_value            = 0
  integer byte_count             = 0
  integer byte_gig_count         = 0
  integer byte_position          = 0
  integer byte_value             = 0
  integer crc_value              = 0
  integer end_block_first_line   = 0
  integer fletcher_1st_sum       = 0
  integer fletcher_2nd_sum       = 0
  integer front_block_last_line  = 0
  integer half_fingerprint_bytes = minimum_fingerprint_bytes / 2 + 1
  integer newline_len            = 0
  string  result            [34] = ''
  if NumLines()
    // The newline length is determined crudely in favor of cheaply.
    #ifdef LINUX
      newline_len = iif(BinaryMode(), 0, 1)
    #else
      newline_len = iif(BinaryMode(), 0, 2)
    #endif
    PushLocation()
    BegFile()
    byte_count = 0
    repeat
      byte_count = byte_count + CurrLineLen() + newline_len
    until not Down()
       or byte_count >= half_fingerprint_bytes
    front_block_last_line = CurrLine()
    EndFile()
    byte_count = 0
    repeat
      byte_count = byte_count + CurrLineLen() + newline_len
    until not Up()
       or byte_count >= half_fingerprint_bytes
    end_block_first_line = CurrLine()
    if end_block_first_line <= front_block_last_line
      end_block_first_line = NumLines()
    endif
    BegFile()
    byte_count = 0
    repeat
      byte_count = byte_count + CurrLineLen() + newline_len
      if byte_count == 1000000000
        byte_count = 0
        byte_gig_count = iif(byte_gig_count == 9, 5, byte_gig_count + 1)
      endif
    until not Down()
    BegFile()
    repeat
      byte_value = CurrChar()
      if  byte_value == _AT_EOL_
      and not BinaryMode()
        byte_value = 10
      endif
      if byte_value <> _AT_EOL_
        byte_position = byte_position + 1
        block_value   = block_value * 256 + byte_value
        if byte_position == 3
          crc_value        = crc_value ^ block_value
          fletcher_1st_sum = (fletcher_1st_sum + block_value     ) mod 16777215
          fletcher_2nd_sum = (fletcher_2nd_sum + fletcher_1st_sum) mod 16777215
          block_value      = 0
          byte_position    = 0
        endif
      endif
    until CurrLine() > front_block_last_line
       or not NextChar()
    if CurrLine() > front_block_last_line
      GotoLine(end_block_first_line)
      repeat
        byte_value = CurrChar()
        if  byte_value == _AT_EOL_
        and not BinaryMode()
          byte_value = 10
        endif
        if byte_value <> _AT_EOL_
          byte_position = byte_position + 1
          block_value   = block_value * 256 + byte_value
          if byte_position == 3
            crc_value        = crc_value ^ block_value
            fletcher_1st_sum = (fletcher_1st_sum + block_value     ) mod 16777215
            fletcher_2nd_sum = (fletcher_2nd_sum + fletcher_1st_sum) mod 16777215
            block_value      = 0
            byte_position    = 0
          endif
        endif
      until not NextChar()
    endif
    PopLocation()
    if byte_position <> 0
      crc_value        = crc_value ^ block_value
      fletcher_1st_sum = (fletcher_1st_sum + block_value     ) mod 16777215
      fletcher_2nd_sum = (fletcher_2nd_sum + fletcher_1st_sum) mod 16777215
    endif
  endif
  result = Format(fletcher_2nd_sum:8:'0',
                  fletcher_1st_sum:8:'0',
                  crc_value:8:'0',
                  byte_gig_count,
                  byte_count:9:'0')
  return(result)
end get_buffer_fingersmudge

proc write_profile_error()
  if not reported_profile_error
    Alarm()
    Warn(MY_MACRO_NAME; 'abort when writing configuration to "tse.ini".')
    reported_profile_error = TRUE
  endif
  PurgeMacro(MY_MACRO_NAME)
  ok = FALSE
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

proc show_help()
  string  full_macro_source_name [MAXSTRINGLEN] = LoadDir() + 'mac' + SLASH + MY_MACRO_NAME + '.s'
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
        Warn(MY_MACRO_NAME; 'file'; QuotePath(full_macro_source_name); 'has no multi-line comment block.')
      endif
    else
      GotoBufferId(org_id)
      Warn(MY_MACRO_NAME; 'file'; QuotePath(full_macro_source_name); 'not found.')
    endif
    AbandonFile(tmp_id)
  endif
end show_help

proc browse_website()
  #ifdef LINUX
    // Reportedly this is the most cross-Linux compatible way.
    // It worked out of the box for me: No Linux configuration was necessary.
    // Obviously it will only work for Linux installations with a GUI that can
    // run a web browser, so typically Linux workstation-type installations.
    Dos('python -m webbrowser "' + UPGRADE_URL + '"', DOS_SYNC_CALL_FLAGS)
  #else
    StartPgm(UPGRADE_URL, '', '', _DEFAULT_)
  #endif
end browse_website

// Returns the current date and time as YYYYMMDD_HHMMSSHH.
string proc get_date_time_str()
  integer day             = 0
  integer day_of_week     = 0
  integer hour            = 0
  integer hundreth        = 0
  integer minute          = 0
  integer month           = 0
  integer second          = 0
  string  date_time  [17] = ''
  integer year            = 0
  if FALSE
    day_of_week = day_of_week // Pacify compiler
  endif
  GetDate(month, day, year, day_of_week)
  GetTime(hour, minute, second, hundreth)
  date_time = Format(year    :4:'0',
                     month   :2:'0',
                     day     :2:'0',
                     '_',
                     hour    :2:'0',
                     minute  :2:'0',
                     second  :2:'0',
                     hundreth:2:'0')
  return(date_time)
end get_date_time_str

proc sort_buffer()
  integer old_MsgLevel = 0
  PushBlock()
  MarkLine(1, NumLines())
  old_MsgLevel = Set(MsgLevel, _NONE_)
  Sort()
  Set(MsgLevel, old_MsgLevel)
  PopBlock()
end sort_buffer

proc insert_non_empty_text(string s)
  if s == ''
    InsertText(' ', _INSERT_)
  else
    InsertText(s  , _INSERT_)
  endif
end insert_non_empty_text

integer proc backup_newly_changed_files()
  string  backup_fqn [MAXSTRINGLEN] = ''
  integer curr_binarymode           = 0
  integer curr_filechanged          = 0
  string  curr_fingersmudge    [34] = ''
  string  curr_fqn   [MAXSTRINGLEN] = ''
  string  curr_file_size       [20] = ''
  integer curr_id                   = 0
  string  date_time            [17] = ''  // YYYYMMDD_HHMMSSHH
  integer loop_completed            = FALSE
  integer loop_interrupted          = FALSE
  integer loop_start_id             = 0
  string  old_wordset          [32] = Set(WordSet, BACKUP_WORDSET)
  integer org_id                    = GetBufferId()
  integer prev_filechanged          = 0
  if BufferType() == _NORMAL_
  or NextFile(_DONT_LOAD_)
    backup_counter = 0
    loop_start_id  = GetBufferId()
    GotoBufferId(SESSION_STATUS_ID)
    lReplace(CHECKMARK, UNCHECKEDMARK, 'gn$')
    GotoBufferId(loop_start_id)
    repeat
      if KeyPressed()
        last_key_time    = GetTime()
        loop_interrupted = TRUE
      else
        curr_id          = GetBufferId()
        curr_filechanged = FileChanged()
        curr_binarymode  = BinaryMode()
        curr_fqn         = CurrFilename()
        GotoBufferId(SESSION_STATUS_ID)
        if lFind(Format(curr_id, DELIMITER), '^g')
          WordRight()
          prev_filechanged = Val(GetWord())
          if curr_filechanged == prev_filechanged
            EndLine()
            Left()
            InsertText(CHECKMARK, _OVERWRITE_)
          else
            KillToEol()
            InsertText(Str(curr_filechanged) + DELIMITER + CHECKMARK, _INSERT_)
          endif
        else
          EndFile()
          AddLine(Format(curr_id, DELIMITER, curr_filechanged, DELIMITER,
                  CHECKMARK))
          prev_filechanged = -1  // Made-up value for a new buffer.
        endif
        if curr_filechanged <> prev_filechanged
          backup_fqn        = ''
          curr_fingersmudge = ''
          date_time         = get_date_time_str()
          if curr_filechanged
          or prev_filechanged <> -1
            GotoBufferId(curr_id)
            if Query(BufferFlags) & _LOADED_  // Just to be extra sure.
              curr_fingersmudge = get_buffer_fingersmudge(MINIMUM_FINGERPRINT_BYTES)
            endif
            if curr_filechanged
              backup_counter = backup_counter + 1
              backup_fqn     = SESSION_UNCRASH_DIR + SLASH + date_time + '_' +
                               Str(backup_counter)
            endif
          endif
          GotoBufferId(SESSION_JOURNAL_ID)
          EmptyBuffer()
          AddLine(Format(date_time       , DELIMITER,
                         curr_id         , DELIMITER,
                         curr_filechanged, DELIMITER,
                         curr_binarymode , DELIMITER))
          EndLine()
          // Note: To be able to later easily process fields as "words",
          // any but the last field should not be empty.
          insert_non_empty_text(curr_fqn)
          InsertText           (DELIMITER       , _INSERT_)
          insert_non_empty_text(curr_fingersmudge)
          InsertText           (DELIMITER       , _INSERT_)
          InsertText           (backup_fqn      , _INSERT_)
          if SaveAs(SESSION_JOURNAL_FQN, SAVEAS_APPEND_FLAGS)
            if curr_filechanged
              GotoBufferId(curr_id)
              // The backup file should never exist, but an extra check is
              // warranted because of an unexplained abort.
              if FileExists(backup_fqn)
                Warn(MY_MACRO_NAME; 'aborts: Backing up';
                     QuotePath(CurrFilename()); 'backup';
                     QuotePath(backup_fqn); 'already exists.')
                loop_interrupted = TRUE
                ok               = FALSE
              else
                if SaveAs(backup_fqn, _DONT_PROMPT_) // Nor overwrite nor append.
                  GotoBufferId(BACKUPS_ID)
                  if FindThisFile(backup_fqn)
                    #if EDITOR_VERSION > 4400h
                      // FFSizeStr() needs TSE Beta v4.41.37a upwards.
                      curr_file_size = FFSizeStr()
                    #else
                      curr_file_size = Str(FFSize())
                      if curr_file_size [1] == '-'
                        curr_file_size = Str(MAXINT)
                      endif
                    #endif
                  else
                    curr_file_size = ''
                  endif
                  EndFile()
                  AddLine(Format(curr_id       , DELIMITER,
                                 date_time     , DELIMITER,
                                 curr_file_size, DELIMITER))
                  EndLine()
                  InsertText(DELIMITER , _INSERT_)
                  InsertText(backup_fqn, _INSERT_)
                  InsertText(DELIMITER , _INSERT_)
                  InsertText(curr_fqn  , _INSERT_)
                else
                  Warn(MY_MACRO_NAME; 'aborts on backing';
                       QuotePath(CurrFilename()); 'up to';
                       QuotePath(backup_fqn))
                  loop_interrupted = TRUE
                  ok               = FALSE
                endif
              endif
            endif
          else
            Warn(MY_MACRO_NAME; 'aborts on journalling changes to';
                 QuotePath(SESSION_JOURNAL_FQN))
            loop_interrupted = TRUE
            ok               = FALSE
          endif
        endif
        GotoBufferId(curr_id)
      endif
      NextFile(_DONT_LOAD_)
    until loop_interrupted
       or GetBufferId() == loop_start_id
    loop_completed = not loop_interrupted
    if loop_completed
      GotoBufferId(SESSION_JOURNAL_ID)
      EmptyBuffer()
      GotoBufferId(SESSION_STATUS_ID)
      if NumLines()
        date_time = get_date_time_str()
        BegFile()
        while lFind(UNCHECKEDMARK, '$')
          BegLine()
          AddLine(date_time + DELIMITER + GetWord() + DELIMITER + '-1',
                  SESSION_JOURNAL_ID)
          KillLine()
          Up()
        endwhile
        GotoBufferId(SESSION_JOURNAL_ID)
        if NumLines()
          if not SaveAs(SESSION_JOURNAL_FQN, SAVEAS_APPEND_FLAGS)
            Warn(MY_MACRO_NAME; 'aborts on journalling unloads to';
                 QuotePath(SESSION_JOURNAL_FQN))
          endif
        endif
      endif
    endif
  else
    loop_completed = TRUE
  endif
  Set(WordSet, old_wordset)
  GotoBufferId(org_id)
  return(loop_completed)
end backup_newly_changed_files

proc ignore_crashed_session(string session_id)
  string  crash_day_journal_fqn [MAXSTRINGLEN] = ''
  integer tmp_id                               = 0
  crash_day_journal_fqn = cfg_uncrash_dir + SLASH + GetText(1, 8) + '.log'
  PushLocation()
  tmp_id = CreateTempBuffer()
  AddLine('Ignore ' + DELIMITER + session_id + DELIMITER +
          SESSION_START_DATE_TIME)
  if not SaveAs(crash_day_journal_fqn, SAVEAS_APPEND_FLAGS)
    Warn(MY_MACRO_NAME; 'abort: Could not save';
         QuotePath(crash_day_journal_fqn))
    ok = FALSE
  endif
  PopLocation()
  AbandonFile(tmp_id)
end ignore_crashed_session

proc restore_session(string session_id)
  integer abandonment_found                  = FALSE
  string  backup_file         [MAXSTRINGLEN] = ''
  string  backup_fingersmudge           [34] = ''
  integer binary_mode                        = 0
  integer buffers_id                         = 0
  string  buffer_id                     [12] = ''
  string  entry               [MAXSTRINGLEN] = ''
  integer file_changed                       = 0
  integer first_restored_id                  = 0
  integer last_restored_id                   = 0
  string  old_WordSet                   [32] = Set(WordSet, BACKUP_WORDSET)
  string  origin_file         [MAXSTRINGLEN] = ''
  string  restore_file        [MAXSTRINGLEN] = ''
  integer restore_found                      = FALSE
  string  session_journal_fqn [MAXSTRINGLEN] = ''
  integer session_journal_id                 = 0
  string  test_fingersmudge             [34] = ''
  integer test_id                            = 0
  buffers_id         = CreateTempBuffer()
  test_id            = CreateTempBuffer()
  session_journal_id = CreateTempBuffer()
  BufferType(_NORMAL_)
  while NextFile(_DONT_LOAD_)
  and   GetBufferId() <> session_journal_id
    AbandonFile()
  endwhile
  GotoBufferId(session_journal_id)
  session_journal_fqn = cfg_uncrash_dir + SLASH + session_id + SLASH +
                        'Journal.log'
  if LoadBuffer(session_journal_fqn)
    if NumLines()
      // Reproduce the _NORMAL_ buffer ids that were open at the crash
      // by processing the session logged opening and closing of buffers.
      // In the session log file_changed -1 represents a closed buffer.
      BegFile()
      repeat
        entry        = GetText(1, MAXSTRINGLEN)
        buffer_id    =     GetToken(entry, DELIMITER, 2)
        file_changed = Val(GetToken(entry, DELIMITER, 3))
        GotoBufferId(buffers_id)
        if lFind(Format(buffer_id:10), '^g$')   // Leading spaces for sorting.
          if file_changed == -1
            KillLine()
          endif
        else
          if file_changed <> -1
            AddLine(Format(buffer_id:10))       // Leading spaces for sorting.
          endif
        endif
        GotoBufferId(session_journal_id)
      until not Down()
      // Sort the generated list of crashed buffers.
      GotoBufferId(buffers_id)
      sort_buffer()
      // For each crashed buffer restore its last non-corrupt state.
      BegFile()
      repeat
        buffer_id         = Str(Val(GetText(1, MAXSTRINGLEN)))
        abandonment_found = FALSE
        restore_found     = FALSE
        restore_file      = ''
        // Search the session journal backwards for the last valid backup.
        GotoBufferId(session_journal_id)
        EndFile()
        repeat
          entry = GetText(1, MAXSTRINGLEN)
          if GetToken(entry, DELIMITER, 2) == buffer_id
            file_changed = Val(GetToken(entry, DELIMITER, 3))
            if file_changed == -1
              abandonment_found = TRUE
            else
              binary_mode         = Val(GetToken(entry, DELIMITER, 4))
              BegLine()
              WordRight(4)
              origin_file         = Trim(GetWord())
              WordRight()
              backup_fingersmudge = Trim(GetWord())
              WordRight()
              backup_file         = Trim(GetWord())
              if restore_file == ''
                restore_file = origin_file
              endif
              if backup_file == ''
                // File was never modified and therefore never backed up.
                restore_found = TRUE
                if FileExists(origin_file)
                  GotoBufferId(last_restored_id)
                  if edit_this_file(origin_file, _DONT_PROMPT_|_DONT_LOAD_)
                    if not first_restored_id
                      first_restored_id = GetBufferId()
                    endif
                    last_restored_id = GetBufferId()
                    FileChanged(file_changed)
                  else
                    Warn('Could not open:'; origin_file)
                  endif
                else
                  GotoBufferId(last_restored_id)
                  CreateTempBuffer()
                  if not first_restored_id
                    first_restored_id = GetBufferId()
                  endif
                  last_restored_id = GetBufferId()
                  ChangeCurrFilename(origin_file, CHANGE_CURR_FILENAME_FLAGS)
                  BufferType(_NORMAL_)
                endif
              else
                GotoBufferId(test_id)
                if LoadBuffer(backup_file, binary_mode)
                  test_fingersmudge = get_buffer_fingersmudge(MINIMUM_FINGERPRINT_BYTES)
                  if test_fingersmudge == backup_fingersmudge
                    restore_found = TRUE
                    GotoBufferId(last_restored_id)
                    CreateTempBuffer()
                    if not first_restored_id
                      first_restored_id = GetBufferId()
                    endif
                    last_restored_id = GetBufferId()
                    ChangeCurrFilename(origin_file, CHANGE_CURR_FILENAME_FLAGS)
                    LoadBuffer(backup_file, binary_mode)
                    FileChanged(file_changed)
                    BufferType(_NORMAL_)
                  else
                    Warn('Skipped corrupted backup'; backup_file; 'of';
                         origin_file)
                  endif
                else
                  Warn('Skipped unloadable backup'; backup_file; 'of';
                       origin_file)
                endif
              endif
              GotoBufferId(session_journal_id)
            endif
          endif
        until restore_found
           or abandonment_found
           or not Up()
        if not restore_found
          Warn('Could not restore:'; QuotePath(restore_file))
        endif
        GotoBufferId(buffers_id)
      until not Down()
    else
      Warn(MY_MACRO_NAME; 'abort: Nothing to restore.')
      ok = FALSE
    endif
  else
    Warn(MY_MACRO_NAME; 'abort: Could not load: ',
         QuotePath(session_journal_fqn))
    ok = FALSE
  endif
  GotoBufferId(first_restored_id)
  AbandonFile(session_journal_id)
  Set(WordSet, old_WordSet)
end restore_session

Keydef restore_list_keys
  <Del>           session_action = SESSION_DELETE     PushKey(<Enter>)
  <GreyDel>       session_action = SESSION_DELETE     PushKey(<Enter>)
  <Ctrl Del>      session_action = SESSION_DELETE_ALL PushKey(<Enter>)
  <Ctrl GreyDel>  session_action = SESSION_DELETE_ALL PushKey(<Enter>)
  <Ctrl A>        session_action = SESSION_DELETE_ALL PushKey(<Enter>)
end restore_list_keys

proc restore_list_cleanup()
  UnHook(restore_list_cleanup)
  Disable(restore_list_keys)
end restore_list_cleanup

proc restore_list_startup()
  UnHook(restore_list_startup)
  ListFooter(SESSION_LIST_FOOTER)
  Enable(restore_list_keys)
  Hook(_LIST_CLEANUP_, restore_list_cleanup)
end restore_list_startup

proc list_crashed_sessions()
  sort_buffer()
  // Temporarily format the list to be more user-friendly.
  // YYYYMMDD_HHMMSSHH_WWWWW -> YYYY-MM-DD HH:MM:SS.HH (WWWWW)
  lReplace('{....}{..}{..}_{..}{..}{..}{..}_{.#}',
           '\1-\2-\3 \4:\5:\6.\7 (\8)', 'gnx')
  BegFile()
  session_action = SESSION_RESTORE
  Hook(_LIST_STARTUP_, restore_list_startup)
  if List('Crashed TSE session(s)', 50)
    lReplace('{....}-{..}-{..} {..}:{..}:{..}\.{..} ({[0-9]#})',
             '\1\2\3_\4\5\6\7_\8', 'gnx')
    case session_action
      when SESSION_DELETE
        ignore_crashed_session(GetText(1, MAXSTRINGLEN))
      when SESSION_DELETE_ALL
        if YesNo('Delete all ' + Str(NumLines()) +
                 ' crashed TSE sessions?') == 1
          BegFile()
          repeat
            ignore_crashed_session(GetText(1, MAXSTRINGLEN))
          until not Down()
        endif
      when SESSION_RESTORE
        if YesNo('The restore will abandon all curently loaded files. Continue?')
            == 1
          restore_session(GetText(1, MAXSTRINGLEN))
        endif
    endcase
  endif
end list_crashed_sessions

proc delete_old_sessions()
  integer backups_handle = 0
  backups_handle = FindFirstFile(cfg_uncrash_dir + SLASH + '*', ALL_FILE_TYPES)
  if backups_handle <> NO_FILE_HANDLE
    repeat
      if not (SubStr(FFName(), 1, 8) in TODAY, YESTERDAY)
        if FFAttribute() & _DIRECTORY_
          if not (FFName() in '.', '..')
            rm_dir(cfg_uncrash_dir + SLASH + FFName())
          endif
        else
          EraseDiskFile(cfg_uncrash_dir + SLASH + FFName())
        endif
      endif
    until not FindNextFile(backups_handle, ALL_FILE_TYPES)
    FindFileClose(backups_handle)
  endif
end delete_old_sessions

integer proc is_date(string s)
  integer result = FALSE
  if  Length(s) == 8
  and (Val(s[1:4]) in 2021 .. 9999)
  and (Val(s[5:2]) in    1 ..   12)
  and (Val(s[7:2]) in    1 ..   31)
    result = TRUE
  endif
  return(result)
end is_date

integer proc is_leap_year(integer year)
  integer result = FALSE
  if year mod 4 == 0
    result = TRUE
    if year mod 100 == 0
      result = FALSE
      if year mod 400 == 0
        result = TRUE
      endif
    endif
  endif
  return(result)
end is_leap_year

string proc subtract_one_day(string old_date)
  integer dd           = Val(old_date[7:2])
  integer mm           = Val(old_date[5:2])
  string  new_date [8] = ''
  integer yyyy         = Val(old_date[1:4])
  if dd == 1
    case mm
      when 1
        yyyy = yyyy - 1
        mm   = 12
        dd   = 31
      when 3
        mm = 2
        if is_leap_year(yyyy)
          dd = 29
        else
          dd = 28
        endif
      when 5, 7, 10, 12
        mm = mm - 1
        dd = 30
      otherwise
        mm = mm - 1
        dd = 31
    endcase
  else
    dd = dd - 1
  endif
  new_date = Format(yyyy:4:'0', mm:2:'0', dd:2:'0')
  return(new_date)
end subtract_one_day

/*
  Tests show, that if you write a not pre-existing log file from a Dos()
  command, then the log's file size will not exceed zero until it is completely
  written. That allow us to easily test for when it is ready.

  The file_fqn parameter must be a previously not existing file.

  The max_wait_time parameter is roughly in 18ths of a second.
  So e.g., value 90 waits at most 5 seconds for the file to be written.
*/
integer proc wait_for_file(string file_fqn, integer max_wait_time)
  integer file_found   = FALSE
  integer keep_waiting = Max(max_wait_time, 0)
  while keep_waiting
  and   not FileExists(file_fqn)
    Delay(1)
    keep_waiting = keep_waiting - 1
  endwhile
  if FileExists(file_fqn)
    keep_waiting = Max(max_wait_time, 0)
    FindThisFile(file_fqn)
    while keep_waiting
    and   not FFSize()
      Delay(1)
      FindThisFile(file_fqn)
      keep_waiting = keep_waiting - 1
    endwhile
    file_found = FFSize()
  endif
  return(file_found)
end wait_for_file

integer proc get_running_tse_processes()
  string  cmd       [MAXSTRINGLEN] = ''
  string  process_id          [12] = ''
  integer running_tse_processes_id = 0
  string  search_phase         [1] = 'g'
  string  tmp_fqn   [MAXSTRINGLEN] = ''
  integer tmp_id                   = 0
  string  tse_exe   [MAXSTRINGLEN] = ''
  PushLocation()

  // This buffer is named because there was a bug related to it.
  running_tse_processes_id = CreateTempBuffer()
  ChangeCurrFilename(MY_MACRO_NAME + ':RunningTseProcesses',
                     CHANGE_CURR_FILENAME_FLAGS)

  tmp_id                   = CreateTempBuffer()
  tmp_fqn = session_uncrash_dir + SLASH + 'tmp.log'
  cmd     = 'wmic process list status > ' + QuotePath(tmp_fqn) + ' 2>&1'
  EraseDiskFile(tmp_fqn)
  Dos(cmd, DOS_ASYNC_CALL_FLAGS)
  if DosIOResult() == 0
    // On my system WMIC takes 0.37 seconds when nothing else is running.
    // But Windows could be busy running a processor consuming task.
    // We can afford to be generous, as long as there is some time limit.
    if wait_for_file(tmp_fqn, 90)
      GotoBufferId(tmp_id)
      if LoadBuffer(tmp_fqn)
        // Note:
        //   WMIC's STDOUT created a UTF-16LE+BOM file.
        //   TSE's LoadBuffer() command converts the buffer to an ANSI file.
        tse_exe = SplitPath(LoadDir(TRUE), _NAME_|_EXT_)
        while lFind(tse_exe, '^' + search_phase)
          process_id   = GetToken(GetText(1, MAXSTRINGLEN), ' ', 2)
          AddLine(process_id, running_tse_processes_id)
          search_phase = '+'
        endwhile
        EraseDiskFile(tmp_fqn)
      else
        Warn(MY_MACRO_NAME; 'abort: Could not load:'; QuotePath(tmp_fqn))
        ok = FALSE
      endif
    else
      Warn(MY_MACRO_NAME; 'abort: Could not create:'; QuotePath(tmp_fqn))
      ok = FALSE
    endif
  else
    Warn(MY_MACRO_NAME; 'abort: Could not execute:', Chr(13), cmd)
    ok = FALSE
  endif
  PopLocation()
  AbandonFile(tmp_id)
  return(running_tse_processes_id)
end get_running_tse_processes

integer proc is_running_tse_process(integer running_tse_processes_id,
                                    string  process_id)
  integer result = FALSE
  PushLocation()
  GotoBufferId(running_tse_processes_id)
  result = lFind(process_id, '^g$')
  PopLocation()
  return(result)
end is_running_tse_process

proc check_for_tse_crashes()
  integer crashes_id                               = 0
  integer day_journals_handle                      = 0
  string  day_journal_fqn           [MAXSTRINGLEN] = ''
  integer day_journal_id                           = 0
  string  entry                     [MAXSTRINGLEN] = ''
  string  entry_process_id                    [12] = ''
  string  entry_session_id                    [30] = ''
  string  entry_session_journal_fqn [MAXSTRINGLEN] = ''
  string  entry_type                           [8] = ''
  string  old_WordSet                         [32] = ''
  integer org_id                                   = GetBufferId()
  integer running_tse_processes_id                 = 0
  running_tse_processes_id = get_running_tse_processes()
  if ok
    crashes_id          = CreateTempBuffer()
    day_journal_id      = CreateTempBuffer()
    day_journals_handle = FindFirstFile(cfg_uncrash_dir + SLASH + '*',
                                        ALL_FILE_TYPES)
    if day_journals_handle <> NO_FILE_HANDLE
      old_WordSet = Set(WordSet, BACKUP_WORDSET)
      repeat
        if  not (FFAttribute() & _DIRECTORY_)
        and     is_date(SplitPath(FFName(), _NAME_))
        and       Lower(SplitPath(FFName(), _EXT_ )) == '.log'
          day_journal_fqn = cfg_uncrash_dir + SLASH + FFName()
          GotoBufferId(day_journal_id)
          if LoadBuffer(day_journal_fqn)
            if NumLines()
              BegFile()
              repeat
                entry      = GetText(1, MAXSTRINGLEN)
                entry_type = Trim(GetToken(entry, DELIMITER, 1))
                if entry_type == 'Begin'
                  entry_session_id  = Trim(GetToken(entry, DELIMITER, 2))
                  PushLocation()
                  lFind(entry_session_id, 'bgw')
                  if (  Trim(GetToken(GetText(1, MAXSTRINGLEN), DELIMITER, 1))
                     == 'Begin')
                    // The found crashed TSE session was started and not ended.
                    entry_session_journal_fqn = cfg_uncrash_dir + SLASH +
                                                entry_session_id + SLASH +
                                                'Journal.log'
                    // We cannot restore a session that had/has no logging yet.
                    if FileExists(entry_session_journal_fqn)
                      entry_process_id = GetToken(entry_session_id, '_', 3)
                      // We do not restore a currently running TSE process.
                      if not is_running_tse_process(running_tse_processes_id,
                                                    entry_process_id)
                        AddLine(entry_session_id, crashes_id)
                      endif
                    endif
                  endif
                  PopLocation()
                endif
              until not Down()
            endif
          else
            Warn(MY_MACRO_NAME; 'abort: Could not load:';
                 QuotePath(day_journal_fqn))
            ok = FALSE
          endif
        endif
      until not ok
         or not FindNextFile(day_journals_handle, ALL_FILE_TYPES)
      FindFileClose(day_journals_handle)
      Set(WordSet, old_WordSet)
      GotoBufferId(crashes_id)
      if NumLines()
        list_crashed_sessions()
      else
        delete_old_sessions()
      endif
    endif
    GotoBufferId(org_id)
    AbandonFile(day_journal_id)
    AbandonFile(crashes_id)
    AbandonFile(running_tse_processes_id)
  endif
  checked_for_tse_crashes = TRUE
end check_for_tse_crashes

proc log_to_day_journal(string status_change)
  integer tmp_id = 0
  PushLocation()
  tmp_id = CreateTempBuffer()
  AddLine(Format(status_change:-7, DELIMITER, MY_SESSION_ID, DELIMITER,
                 get_date_time_str()))
  SaveAs(MY_DAY_JOURNAL_FQN, SAVEAS_APPEND_FLAGS)
  PopLocation()
  AbandonFile(tmp_id)
end log_to_day_journal

proc idle()
  integer curr_time = GetTime()
  if ok
    if checked_for_tse_crashes
      if  Abs(curr_time - prev_time    ) > cfg_backup_period_in_minutes    * 6000
      and Abs(curr_time - last_key_time) > cfg_no_typing_period_in_seconds *  100
        if backup_newly_changed_files()
          prev_time = curr_time
        endif
      endif
    else
      check_for_tse_crashes()
      checked_for_tse_crashes = TRUE
    endif
  else
    PurgeMacro(MY_MACRO_NAME)
  endif
end idle

proc after_command()
  last_key_time = GetTime()
end after_command

string proc get_uncrash_dir()
  if cfg_uncrash_dir == ''
    GetProfileStr(VARNAME_CFG_SECTION, 'Folder', '')
    if cfg_uncrash_dir == ''
      cfg_uncrash_dir = GetEnvStr('TMP')
      if cfg_uncrash_dir == ''
        Warn(MY_MACRO_NAME; 'aborts: No environment variable TMP exists.')
        ok = FALSE
      elseif not (FileExists(cfg_uncrash_dir) & _DIRECTORY_)
        Warn(MY_MACRO_NAME; 'aborts: TMP is not a folder:'; QuotePath(cfg_uncrash_dir))
        ok = FALSE
      else
        cfg_uncrash_dir = cfg_uncrash_dir + SLASH + 'Tse_' + MY_MACRO_NAME
        if not (FileExists(cfg_uncrash_dir) & _DIRECTORY_)
          MkDir(cfg_uncrash_dir)
        endif
      endif
    endif
  endif
  if ok
    if not (FileExists(cfg_uncrash_dir) & _DIRECTORY_)
      Warn(MY_MACRO_NAME; 'aborts: Configured folder non-existent:';
           QuotePath(cfg_uncrash_dir))
      ok = FALSE
    endif
  endif
  return(cfg_uncrash_dir)
end get_uncrash_dir

proc set_uncrash_dir()
  string  new_uncrash_dir [MAXSTRINGLEN] = cfg_uncrash_dir
  integer stop = FALSE
  repeat
    if Ask('UnCrash folder:', new_uncrash_dir)
      new_uncrash_dir = RemoveTrailingSlash(Trim(new_uncrash_dir))
      if FileExists(new_uncrash_dir) & _DIRECTORY_
        if write_profile_str(MY_MACRO_NAME + ':Config', 'Folder', new_uncrash_dir)
          cfg_uncrash_dir = new_uncrash_dir
          stop            = TRUE
        endif
      endif
    else
      stop = TRUE
    endif
  until stop
end set_uncrash_dir

integer proc get_backup_period()
  cfg_backup_period_in_minutes = GetProfileInt(VARNAME_CFG_SECTION,
                                               'BackupPeriodInMinutes',
                                               1)
  return(cfg_backup_period_in_minutes)
end get_backup_period

proc set_backup_period()
  string  answer [3] = Str(cfg_backup_period_in_minutes)
  integer stop       = FALSE
  repeat
    if Ask('Backup changed files every how many minutes?', answer)
      if Val(answer) in 1 .. 999
        cfg_backup_period_in_minutes = Val(answer)
        write_profile_int(VARNAME_CFG_SECTION,
                          'BackupPeriodInMinutes',
                          cfg_backup_period_in_minutes)
        stop = TRUE
      else
        Message('')
        Delay(9)
        if Query(Beep)
          Alarm()
        endif
        Message('That is not a number from 1 to 999.')
      endif
    else
      stop = TRUE
    endif
  until stop
end set_backup_period

integer proc get_no_typing_period()
  cfg_no_typing_period_in_seconds = GetProfileInt(VARNAME_CFG_SECTION,
                                                  'NoTypingPeriodInSeconds',
                                                  5)
  return(cfg_no_typing_period_in_seconds)
end get_no_typing_period

proc set_no_typing_period()
  string  answer [3] = Str(cfg_no_typing_period_in_seconds)
  integer stop = FALSE
  repeat
    if Ask('Backup after no typing for how many seconds?', answer)
      if Val(answer) in 1 .. 999
        cfg_no_typing_period_in_seconds = Val(answer)
        write_profile_int(VARNAME_CFG_SECTION,
                          'NoTypingPeriodInSeconds',
                          cfg_no_typing_period_in_seconds)
        stop = TRUE
      else
        Message('')
        Delay(9)
        if Query(Beep)
          Alarm()
        endif
        Message('That is not a number from 1 to 999.')
      endif
    else
      stop = TRUE
    endif
  until stop
end set_no_typing_period

proc collect_session_backups(string  session_dir,
                             integer presentation_id,
                             integer translation_id,
                             integer session_journal_id)
  string  backup_filename [MAXSTRINGLEN] = ''
  string  date_time                 [17] = ''
  integer field_separator_nr             = 0
  string  fingersmudge              [34] = ''
  string  real_filename   [MAXSTRINGLEN] = ''

  GotoBufferId(session_journal_id)
  if  LoadBuffer(session_dir + SLASH + 'Journal.log')
  and NumLines()
    BegFile()
    repeat
      real_filename      = ''
      backup_filename    = ''
      fingersmudge       = ''
      field_separator_nr = 0
      BegLine()
      while lFind('*', 'c+')
        field_separator_nr = field_separator_nr + 1
        case field_separator_nr
          when 1
            date_time       = GetToken(GetText(1            , MAXSTRINGLEN), '*', 1)
          when 4
            real_filename   = GetToken(GetText(CurrPos() + 1, MAXSTRINGLEN), '*', 1)
          when 5
            fingersmudge    = GetToken(GetText(CurrPos() + 1, MAXSTRINGLEN), '*', 1)
          when 6
            backup_filename = GetToken(GetText(CurrPos() + 1, MAXSTRINGLEN), '*', 1)
        endcase
      endwhile
      if  real_filename   <> ''
      and fingersmudge    <> ''
      and backup_filename <> ''
      // and StrFind(DATE_TIME_NUMBER_FORMAT, backup_filename, 'x')
      and FileExists(backup_filename)
        // xx For now skip using fingersmudge here.
        InsertLine(Format(date_time[ 1:4],
                          Chr(Query(DateSeparator)),
                          date_time[ 5:2],
                          Chr(Query(DateSeparator)),
                          date_time[ 7:2];

                          date_time[10:2],
                          Chr(Query(TimeSeparator)),
                          date_time[12:2],
                          Chr(Query(TimeSeparator)),
                          date_time[14:2],
                          '.',
                          date_time[16:2];

                          real_filename),
                   presentation_id)
        InsertLine(backup_filename, translation_id)
      endif
    until not Down()
  endif
end collect_session_backups

proc collect_backups(integer presentation_id,
                     integer translation_id,
                     integer session_journal_id)
  integer handle = FindFirstFile(cfg_uncrash_dir + SLASH + '*', ALL_FILE_TYPES)
  if handle <> NO_FILE_HANDLE
    repeat
      if  FFAttribute() & _DIRECTORY_
      and StrFind(DATE_TIME_NUMBER_FORMAT, FFName(), 'x')
        collect_session_backups(cfg_uncrash_dir + SLASH + FFName(),
                                presentation_id,
                                translation_id,
                                session_journal_id)
      endif
    until not FindNextFile(handle, ALL_FILE_TYPES)
    FindFileClose(handle)
  endif
end collect_backups

proc list_backups()
  integer presentation_id                     = 0
  string  selected_backup_file [MAXSTRINGLEN] = ''
  integer selected_line                       = 0
  string  selected_real_file   [MAXSTRINGLEN] = ''
  integer translation_id                      = 0
  integer session_journal_id                  = 0

  PushLocation()

  presentation_id    = CreateTempBuffer()
  translation_id     = CreateTempBuffer()
  session_journal_id = CreateTempBuffer()

  collect_backups(presentation_id, translation_id, session_journal_id)

  GotoBufferId(presentation_id)
  if eList('Available file versions')
    selected_line        = CurrLine()
    selected_real_file   = GetText(24, MAXSTRINGLEN)
    GotoBufferId(translation_id)
    GotoLine(selected_line)
    selected_backup_file = GetText( 1, MAXSTRINGLEN)
    NewFile()
    ChangeCurrFilename(  SplitPath(selected_real_file, _DRIVE_|_PATH_|_NAME_)
                       + '_'
                       + SplitPath(selected_backup_file, _NAME_)
                       + SplitPath(selected_real_file, _EXT_),
                       CHANGE_CURR_FILENAME_FLAGS)
    LoadBuffer(selected_backup_file)
    KillLocation()
  else
    PopLocation()
  endif

  AbandonFile(presentation_id)
  AbandonFile(translation_id)
  AbandonFile(session_journal_id)
end list_backups

menu main_menu()
  title       = 'UnCrash'
  x           = 5
  y           = 5

  '&Help ...',
    show_help(),,
    'Read the documentation'
  '&Version ...' [MY_MACRO_VERSION:7],
    browse_website(),,
    'Check the website for a newer version'
  '&List backups ...',
    list_backups(),,
    'List the not yet deleted backups that UnCrash made.'
  'Config',, _MF_DIVIDE_
  '&UnCrash folder ' [get_uncrash_dir():54],
    set_uncrash_dir(),
    _MF_DONT_CLOSE_|_MF_ENABLED_,
    'Set which UnCrash folder to use.'
  'Backup every ... minutes' [get_backup_period():3],
    set_backup_period(),
    _MF_DONT_CLOSE_|_MF_ENABLED_,
    'Backup changed files every ... minutes'
  'after not typing for ... seconds' [get_no_typing_period():3],
    set_no_typing_period(),
    _MF_DONT_CLOSE_|_MF_ENABLED_,
    'then keep trying each time after the user did not type for ... seconds.'
end main_menu

proc Main()
  main_menu()
end Main

proc WhenLoaded()
  BACKUP_WORDSET          = ChrSet('~' + DELIMITER)
  MY_MACRO_NAME           = SplitPath(CurrMacroFilename(), _NAME_)
  SESSION_PROCESS_ID      = Str(get_current_process_id())
  SESSION_START_DATE_TIME = get_date_time_str()
  TODAY                   = SESSION_START_DATE_TIME[1:8]
  YESTERDAY               = subtract_one_day(TODAY)
  VARNAME_CFG_SECTION     = MY_MACRO_NAME + ':Config'
  MY_SESSION_ID           = SESSION_START_DATE_TIME + '_' + SESSION_PROCESS_ID
  cfg_uncrash_dir         = get_uncrash_dir()
  SESSION_UNCRASH_DIR     = cfg_uncrash_dir + SLASH + MY_SESSION_ID
  MY_DAY_JOURNAL_FQN      = cfg_uncrash_dir + SLASH +
                            GetToken(SESSION_START_DATE_TIME, '_', 1) + '.log'
  SESSION_JOURNAL_FQN     = SESSION_UNCRASH_DIR + SLASH + 'Journal.log'

  get_backup_period()
  get_no_typing_period()

  PushLocation()
  BACKUPS_ID         = CreateTempBuffer()
  ChangeCurrFilename(MY_MACRO_NAME + ':Backups',
                     CHANGE_CURR_FILENAME_FLAGS)
  SESSION_JOURNAL_ID = CreateTempBuffer()
  ChangeCurrFilename(MY_MACRO_NAME + ':SessionJournal',
                     CHANGE_CURR_FILENAME_FLAGS)
  SESSION_STATUS_ID  = CreateTempBuffer()
  ChangeCurrFilename(MY_MACRO_NAME + ':SessionStatus',
                     CHANGE_CURR_FILENAME_FLAGS)
  PopLocation()

  log_to_day_journal('Begin')

  if      ok
  and not MkDir(SESSION_UNCRASH_DIR)
    Warn(MY_MACRO_NAME; 'aborts: Could not mkdir'; QuotePath(SESSION_UNCRASH_DIR))
    ok = FALSE
  endif

  prev_time = GetTime()

  Hook(_AFTER_COMMAND_    , after_command )
  Hook(_IDLE_             , idle          )
  Hook(_ON_ABANDON_EDITOR_, WhenPurged    )
end WhenLoaded

proc WhenPurged()
  log_to_day_journal('End')

  AbandonFile(BACKUPS_ID)
  AbandonFile(SESSION_STATUS_ID)
  AbandonFile(SESSION_JOURNAL_ID)
end WhenPurged

