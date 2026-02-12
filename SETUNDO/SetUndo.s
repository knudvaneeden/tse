
/*
   Macro    SetUndo
   Author   Carlo.Hogeveen@xs4all.nl
   Date     11 June 2003

   Installation:
      Put this file in TSE's "mac" directory and compile it.
      Execute this macro by adding it to the Potpourri menu,
      or by assigning execmacro("SetUndo") to a key.
*/

Datadef help_data
   "Since version 3.0 TSE supports Undo and Redo."
   ""
   "To support this, TSE does undo logging for all changes you make."
   ""
   "However, when you are handling really large or really numerous"
   "files or otherwise do a really big bulk of changes, then this undo"
   "logging can make TSE eat memory to the point of slowing it down"
   "or even choking it."
   ""
   "This macro allows you to control TSE's undo logging by setting it ON or OFF"
   "for the current file, the current TSE session, or all future TSE sessions."
   ""
   'TSE checkboxes: a ">" means a checkbox option is ON, otherwise it is OFF.'
end

integer autoload_id  = 0
integer session_logging = ON
integer help_id

proc show_help()
   integer org_id = GetBufferId()
   GotoBufferId(help_id)
   EmptyBuffer()
   PushBlock()
   InsertData(help_data)
   PopBlock()
   GotoBufferId(org_id)
   MsgBoxBuff("Help", _ok_, help_id)
end

proc ToggleLoadedFiles()
   integer answer
   integer ok = TRUE
   integer org_id = 0
   integer start_id = 0
   repeat
      if session_logging
         answer = YesNo("Set undo logging on for already loaded files too?")
      else
         answer = YesNo("Set undo logging off for already loaded files too?")
      endif
      if not answer
         if Query(Beep)
            Alarm()
         endif
         Message("I don't know either, so make up your mind ... ")
         Delay(36)
         Message(Format(CurrFilename():Query(ScreenCols)))
      endif
   until answer
   if answer == 1 // Yes.
      org_id = GetBufferId()
      if BufferType() <> _NORMAL_
         ok = NextFile(_DONT_LOAD_)
      endif
      if ok
         start_id = GetBufferId()
         repeat
            NextFile(_DONT_LOAD_)
            if session_logging
               SetUndoOn()
            else
               SetUndoOff()
            endif
         until GetBufferId() == start_id
      endif
      GotoBufferId(org_id)
   endif
   // Make the menu update the current file status.
   PushKey(<CursorDown>)
   PushKey(<Enter>)
   PushKey(<Enter>)
   PushKey(<CursorUp>)
end

integer proc GetCurrentFileStatus()
   integer result
   integer old_filechanged = FileChanged()
   if UndoCount()
      result = ON
   else
      PushPosition()
      AddLine(SplitPath(CurrMacroFilename(), _NAME_) + "_Test")
      if UndoCount()
         result = ON
         repeat
            Undo()
         until not UndoCount()
      else
         result = OFF
         KillLine()
         FileChanged(old_filechanged)
      endif
      PopPosition()
   endif
   return(result)
end

proc ToggleCurrentFileStatus()
   if GetCurrentFileStatus()
      SetUndoOff()
   else
      SetUndoOn()
   endif
end

integer proc GetCurrentFileFlags()
   integer result
   if GetCurrentFileStatus()
      result = _MF_DONT_CLOSE_|_MF_CHECKED_
   else
      result = _MF_DONT_CLOSE_|_MF_UNCHECKED_
   endif
   return(result)
end

integer proc GetCurrentSessionStatus()
   integer result = session_logging
   return(result)
end

proc ToggleCurrentSessionStatus()
   session_logging = not GetCurrentSessionStatus()
   ToggleLoadedFiles()
end

integer proc GetCurrentSessionFlags()
   integer result
   if GetCurrentSessionStatus()
      result = _MF_DONT_CLOSE_|_MF_CHECKED_
   else
      result = _MF_DONT_CLOSE_|_MF_UNCHECKED_
   endif
   return(result)
end

integer proc GetNewSessionStatus()
   integer result
   integer org_id = GetBufferId()
   GotoBufferId(autoload_id)
   EmptyBuffer()
   PushBlock()
   InsertFile(LoadDir() + "tseload.dat")
   PopBlock()
   result = not lFind(SplitPath(CurrMacroFilename(), _NAME_), "giw")
   GotoBufferId(org_id)
   return(result)
end

proc ToggleNewSessionStatus()
   if GetNewSessionStatus()
      AddAutoLoadMacro(SplitPath(CurrMacroFilename(), _NAME_))
   else
      DelAutoLoadMacro(SplitPath(CurrMacroFilename(), _NAME_))
   endif
end

integer proc GetNewSessionFlags()
   integer result
   if GetNewSessionStatus()
      result = _MF_DONT_CLOSE_|_MF_CHECKED_
   else
      result = _MF_DONT_CLOSE_|_MF_UNCHECKED_
   endif
   return(result)
end

menu UndoMenu()
   TITLE = "Undo logging"
   CheckBoxes
   "For the &current file",
      ToggleCurrentFileStatus(),
      GetCurrentFileFlags(),
      "Undo logging on/off for the current file"
   "For files in &this TSE session",
      ToggleCurrentSessionStatus(),
      GetCurrentSessionFlags(),
      "Undo logging on/off for files in the current TSE session"
   "For files in &new  TSE sessions",
      ToggleNewSessionStatus(),
      GetNewSessionFlags(),
      "Undo logging on/off for files in new TSE sessions"
   "",
      ,
      _MF_DIVIDE_
   "&Help",
      show_help(),
      _MF_ENABLED_|_MF_DONT_CLOSE_
end

proc on_file_load()
   if  not session_logging
   and BufferType() == _NORMAL_
      SetUndoOff()
   endif
end

proc WhenLoaded()
   integer org_id = GetBufferId()
   autoload_id = CreateTempBuffer()
   help_id = CreateTempBuffer()
   session_logging = GetNewSessionStatus()
   Hook(_ON_FILE_LOAD_, on_file_load)
   GotoBufferId(org_id)
end

proc WhenPurged()
   AbandonFile(autoload_id)
end

proc Main()
   UndoMenu()
   if  GetCurrentSessionStatus()
   and GetNewSessionStatus()
      PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
   endif
end

