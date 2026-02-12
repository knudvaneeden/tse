/*
  Macro           Close_button_test
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE Pro GUI v4.2 upwards
  Version         v1   13 Dec 2021


  The GUI version of TSE has a functional close button "X" in its upper right
  corner.

  This TSE extension helps to demonstrate the bug,
  that using the close button does not call the _ON_ABANDON_EDITOR_ hook
  if the TSE option "Empty Command-Line Action" has one of these values:
    Menu   (default)
    Restore State
    Also Restore State


  CAVEAT

  When closing the editor a Warn() statement from a proc hooked to the
  _LOSING_FOCUS_ event will not show, and the "closed" editor will actually
  remain as a hidden process that hangs on the warning.

  Such a hidden process can be seen in Windows' Task Manager,
  and from the Windows command prompt with the command
    wmic process list status|findstr /i g32.exe

  In the Task Manager I could sometimes view the warning by right-clicking
  the task, "Expand" it, right-click its subtask(?), and "Bring to front".
*/



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

integer log_id                  = 0
string  log_file [MAXSTRINGLEN] = ''

proc log(string log_message)
  PushLocation()
  if not log_id
    log_id = CreateTempBuffer()
    ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_) + ':log',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
    log_file = RemoveTrailingSlash(GetEnvStr('TMP'))
    if log_file == ''
      log_file = '.'
    endif
    log_file = log_file + '/Tse_' + SplitPath(CurrMacroFilename(), _NAME_)
               + '.log'
  endif
  GotoBufferId(log_id)
  EmptyBuffer()
  AddLine(Format(get_current_process_id():10;
                 GetDateStr(); GetTimeStr(); (GetTime() mod 10000000):7;
                 log_message))
  SaveAs(log_file, _APPEND_|_DONT_PROMPT_)
  PopLocation()
end log

proc losing_focus()
  // - Note that minimizing the TSE window or switching
  //   to another application calls _LOSING_FOCUS_ too.
  log('losing_focus')
  Warn('losing_focus')
end losing_focus

proc nonedit_losing_focus()
  log('nonedit_losing_focus')
end nonedit_losing_focus

proc on_abandon_editor()
  log('on_abandon_editor')
end on_abandon_editor

proc on_exit_called()
  // Note that Exit() calls the _ON_EXIT_CALLED_ hook too,
  // but can be stopped by the user from abandoning the editor.
  log('on_exit_called')
  Warn('on_exit_called')
end on_exit_called

proc WhenPurged()
  log('WhenPurged')
end WhenPurged

proc Main()
  log('Main')
end Main

proc WhenLoaded()
  log('WhenLoaded')
  Hook(_LOSING_FOCUS_        , losing_focus        )
  Hook(_NONEDIT_LOSING_FOCUS_, nonedit_losing_focus)
  Hook(_ON_ABANDON_EDITOR_   , on_abandon_editor   )
  Hook(_ON_EXIT_CALLED_      , on_exit_called      )
end WhenLoaded

