/***************************************************************
 Program: autosave.s
 Author : Bruce Riggins
 Date   : 02/05/94
 Purpose: Timed saves for TSE v.1.51a.

 Documentation:
          The automatic saving of files is a desirable effect, yet you
          do not necessarily want to save the latest changes.  Saving to
          a temporary backup file accomplishes this and is what this
          macro is designed to do.

          All changed files are saved in the same directory as their
          originals, with a different extension.  The extension is built
          from the character '$' plus the first 2 characters of the
          original extension.  This allows the editing of files with the
          same name, but different extensions (eg. AUTOSAVE.S and
          AUTOSAVE.INC).

          If the editor is left abnormally (eg. re-booting), the
          autosave file will be left.  On loading the original file,
          this will be sensed and you are given the option of loading
          the backup file.  This would allow you to compare with the
          original to get any changes you made, or to rename the backup
          as the original (after unloading the original, of course.)

          On exiting or saving any file, it's backup file is deleted.

          This allows a configurable time period by executing the public
          macro, Set_Save_Interval().  It will keep the new time period
          for only the current session, or, on exit, will indicate if
          you have changed it and ask if you wish to save it.

          The time is found in the AUTOSAVE.INI file in the LoadDir() +
          "\mac\" subdirectory, and is in minutes.  The macro actually
          maintains the time internally in seconds, though.

****************************************************************/

integer Save_Interval = 600,       // # of seconds between saves
        TimeChanged = FALSE,
        lasttime

integer proc TimeInSeconds()
  integer hour,min,sec,hund
  GetTime(hour,min,sec,hund)
  return (hour * 3600 + min * 60 + sec)
end

string proc GetBackupName()
  string path[80] = GetEnvStr("AUTOSAVE"),
         fn[12] = SplitPath(CurrFileName(),_NAME_)

  if (Length(path))
    if FileExists(path + "\*.*")
      path = path + "\" + fn
    elseif FileExists(path + "*.*")
      path = path + fn
    else
      warn("Invalid AUTOSAVE path! Change path and restart AUTOSAVE macro.")
      Save_Interval = 0
    endif
  else
    path = SplitPath(CurrFileName(),_DRIVE_ | _PATH_ | _NAME_)
  endif

  // Get first 2 characters of the extension
  fn = SubStr(SplitPath(CurrFileName(),_EXT_),2,2)

  return (path + ".$" + fn)
end

proc Timed_Save()
  integer StartBufID = GetBufferID(),
          SavSLU = Set(StatusLineUpdating,OFF)

  repeat
    if FileChanged() and (BufferType() == _NORMAL_)
      SaveAs( GetBackupName(), _OVERWRITE_)
    endif
    NextFile(_DONT_LOAD_)
  until StartBufID == GetBufferID()

  Set(StatusLineUpdating,SavSLU)
  lasttime = TimeInSeconds()
end

proc Idle()
  if lasttime + Save_Interval < TimeInSeconds() and Save_Interval
      and (BufferType() == _NORMAL_)
    message("AutoSaving changed files...")
    Timed_Save()
    UpdateDisplay(_STATUSLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
  endif
end

// save last auto save time interval to control file
proc SaveAutoSaveTime()
  integer setbak = Set(MakeBackups,OFF)

  if CreateBuffer(loaddir()+"\mac\autosave.ini")
    InsertText(Format(Save_Interval/60))
    SaveAndQuitFile()
  endif
  Set(MakeBackups,setbak)
end

// load last auto save time interval from control file
proc LoadAutoSaveTime()
  string fn[80] = loaddir()+"\mac\autosave.ini"

  if FileExists(fn) and EditFile(fn)
    Save_Interval = Val(GetText(PosFirstNonWhite(),CurrLineLen())) * 60
    AbandonFile()
  endif
end

public proc Set_Save_Interval()
  string Save_Interval_Min[3] = Str(Save_Interval / 60)

  if Ask("Interval for Timed Save (in minutes): ",Save_Interval_Min)
    Save_Interval = Val(Save_Interval_Min) * 60
    TimeChanged = TRUE
  endif
end

proc OnFileSave()
  if FileExists(GetBackupName())
    EraseDiskFile(GetBackupName())
  endif
end

proc OnFirstEdit()
  integer bufid

  if FileExists(GetBackupName())
    if YesNo("AutoSave backup exists for this file.  Do you wish to load it?") == 1
      bufid = GetBufferID()
      EditFile(GetBackupName())
      GotoBufferID(bufid)
    endif
  endif
end

proc WhenLoaded()
  lasttime = TimeInSeconds()
  Hook(_IDLE_,idle)
  Hook(_ON_ABANDON_EDITOR_,WhenPurged)
  Hook(_ON_FILE_SAVE_,OnFileSave)
  Hook(_ON_FILE_QUIT_,OnFileSave)     // catch both quit and save
  Hook(_ON_FIRST_EDIT_,OnFirstEdit)
  LoadAutoSaveTime()
end

proc WhenPurged()
  if TimeChanged and
      YesNo("Auto Save time has changed.  Do you wish to save?") == 1
    SaveAutoSaveTime()
  endif
end


