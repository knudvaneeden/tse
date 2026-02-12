/*
  Macro           Log
  Author          Carlo Hogeveen
  Compatibility   TSE v4 upwards, Windows and Linux
  Version         v1   14 Mar 2022

  This macro helps another macro to log lines to a log file.

  Log lines are prefixed with the date and time.

  USAGE
    The macro is used by executing it as follows:
      log open <filename>
      log write <any text>
      log close

    If <filename> already exists, then logging is appended to it.

  INSTALLATION
    Copy this file to TSE's "mac" folder, and compile it there.

  TODO
    MUST
    SHOULD
    COULD   (Let me know if you want any of these.)
    - An extra parameter <handle>, so macros can write to multiple log files
      at the same time.
      Example usage:
        log open <filename>           Returns <handle> in MacroCmdLine.
        log [handle] write [text]     A handle must be before write and close
        log [handle] close            to make it distinguishable from <text>.
    - If <filename> is a folder, create a new uniquely named log file in that
      folder.
    - If no <filename> is supplied, create a new uniquely named file in a
      default folder.
    WONT


  HISTORY

  v1   14 Mar 2022
    Initial release.

*/

integer log_handle                   = -1
string  mcl           [MAXSTRINGLEN] = ''
string  my_macro_name [MAXSTRINGLEN] = ''

proc wrn(string msg)
  Warn('MacroCmdLine:'; mcl, Chr(13),
       'Error       :'; msg)
end wrn

proc WhenLoaded()
  my_macro_name = SplitPath(CurrMacroFilename(), _NAME_)
end WhenLoaded

proc WhenPurged()
  if log_handle <> -1
    fClose(log_handle)
    log_handle = -1
  endif
end WhenPurged

proc Main()
  integer log_attrs              = 0
  string  log_cmd [MAXSTRINGLEN] = ''
  string  log_dir [MAXSTRINGLEN] = ''
  string  log_fqn [MAXSTRINGLEN] = ''
  string  log_msg [MAXSTRINGLEN] = ''
  integer old_DateFormat = Set(DateFormat, 6)
  integer old_timeFormat = Set(TimeFormat, 1)
  mcl     = Query(MacroCmdLine)
  log_cmd = GetFileToken(mcl, 1)
  if EquiStr(log_cmd, 'open')
    log_fqn = GetFileToken(mcl, 2)
    if log_handle <> -1
      wrn('Already a log open.')
    else
      log_attrs = FileExists(log_fqn)
      if log_attrs
        if log_attrs & _DIRECTORY_
          wrn(Format('Cannot log to a directory (', QuotePath(log_fqn), '".'))
        else
          log_handle = fOpen(log_fqn, _OPEN_READWRITE_)
          if log_handle == -1
            wrn(Format('Opening log ', QuotePath(log_fqn), ' failed.'))
          else
            if fSeek(log_handle, 0, _SEEK_END_) == -1
              wrn('First fSeek failed.')
            else
              if fWrite(log_handle, Chr(13) + Chr(10)) == -1
                wrn('First fWrite after fOpen/fSeek failed.')
              endif
            endif
          endif
        endif
      else
        log_dir = SplitPath(log_fqn, _DRIVE_|_PATH_)
        if FileExists(log_dir) & _DIRECTORY_
          log_handle = fCreate(log_fqn)
          if log_handle == -1
            wrn(Format('Creating log ', QuotePath(log_fqn), ' failed.'))
          else
            if fWrite(log_handle, Chr(13) + Chr(10)) == -1
              wrn('First fWrite after fCreate failed.')
            endif
          endif
        else
          wrn(Format('Cannot create log in non-existing directory ';
                     QuotePath(log_dir), ' .'))
        endif
      endif
    endif
  elseif EquiStr(log_cmd, 'write')
    if log_handle == -1
      wrn('There is no open log to write to.')
    else
      log_msg = Format(GetDateStr(); GetTimeStr();
                       Trim(SubStr(mcl, 7, MAXSTRINGLEN)),
                       Chr(13), Chr(10))
      if fSeek(log_handle, 0, _SEEK_END_) == -1
        wrn('Subsequent fSeek failed.')
      else
        if fWrite(log_handle, log_msg) == -1
          wrn('Subsequent fWrite failed.')
        endif
      endif
    endif
  elseif EquiStr(log_cmd, 'close')
    if log_handle == -1
      wrn('There is no open log to close.')
    else
      if fWrite(log_handle, Chr(13) + Chr(10)) == -1
        wrn('Failed to write a closing empty log line.')
      else
        if fClose(log_handle)
          log_handle = -1
          PurgeMacro(my_macro_name)
        else
          wrn('Failed to close log.')
        endif
      endif
    endif
  else
    wrn(Format('Log command "', log_cmd, '" is not "open", "write" or "close".'))
  endif
  Set(DateFormat, old_DateFormat)
  Set(TimeFormat, old_timeFormat)
end Main

