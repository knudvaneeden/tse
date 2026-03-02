/**************************************************************************
Check to see if an edited file has been changed by someone else
or another process.

Jul 02, 2010:   GetTime() - of course this wraps around after midnight :-)
                Take that into account.
Mar 03, 2026:   OpenAI (for Knud van Eeden) - version 1.0.1
                Fix external-change detection so one failed/ignored reload
                does not permanently stop future change detection.
May 16, 2001:   Sammy Mitchell - initial version

OnIdle:
    goal:  check each file for disk changes, but no more than once every
    5 seconds.  check the current file once every 3 seconds.  Make these
    parms tunable.

    if appropriate,
        check current file
        remember when we last checked
    else
        save position
        try to go to last file checked
        nextfile
        check
        restore position
    endif

 **************************************************************************/
string last_time_check_buffer_var[32]

constant
    SECOND = 100,                                   // hundreds of a second
    CHECK_CURRENT_BUFFER_TIME = SECOND * 10,        // time to wait before checking current buffer again
    CHECK_ANY_BUFFER_TIME = SECOND * 5,             // time to wait before rechecking non-current buffer again
    MAX_TIME_USED = SECOND / 4,                     // longest time we'll keep checking before yeilding control
    MIN_TIME_IDLE = SECOND                          // how long we have to be idle before we start checking

integer last_checked_buffer_id, last_checked_time

/**************************************************************************
  return the name of the buffer variable, composed of our macro filename,
  plus a pithy string.
 **************************************************************************/
string proc GetLastTimeVarName()
    return (last_time_check_buffer_var + "last time checked")
end

/**************************************************************************
  return the name of the buffer variable, composed of our macro filename,
  plus a pithy string.
 **************************************************************************/
string proc GetDontCheckTimeVarName()
    return (last_time_check_buffer_var + "don't check time")
end

string proc GetIgnoredHighVarName()
    return (last_time_check_buffer_var + "ignored high")
end

string proc GetIgnoredLowVarName()
    return (last_time_check_buffer_var + "ignored low")
end

string proc GetIgnoredSizeVarName()
    return (last_time_check_buffer_var + "ignored size")
end

integer proc AskReload(string fn)
    return (MsgBox(fn, "File has been updated by another process. Reload it?", _YES_NO_CANCEL_) == 1)
end

integer proc replace_file(string fn)
    integer line, row, column, xoffset

    line    = CurrLine()
    row     = CurrRow()
    column  = CurrCol()
    xoffset = CurrXOffset()
    PushBlock()
    if ReplaceFile(fn)
        GotoLine(line)
        GotoRow(row)
        GotoColumn(column)
        GotoXOffset(xoffset)
        PopBlock()
        return (True)
    endif
    PopBlock()
    return (False)
end

/**************************************************************************
  See if the user wants to reload a file that was changed by another process
 **************************************************************************/
proc MaybeReload(string fn, var integer file_reloaded)
    file_reloaded = FALSE
    while not file_reloaded and AskReload(fn)
        if EquiStr(fn, CurrFilename())
            file_reloaded = replace_file(fn)
        else
            PushPosition()
            EditThisFile(fn)
            file_reloaded = replace_file(fn)
            PopPosition()
        endif
    endwhile
end

/**************************************************************************
  Check a file to see if the disk version has been changed.  Note that
  the file is the current file, but it is not necessarily the file that
  was current when this macro gained control.
 **************************************************************************/
integer proc CheckFile(integer current_time, integer check_period, var integer file_reloaded)
    integer buf_high, buf_low, buf_attributes, buf_size
    integer disk_high, disk_low, disk_size
    integer checked = FALSE

    file_reloaded = FALSE

    if BufferType() <> _NORMAL_ or CurrFileName() == "" or (Query(BufferFlags) & _LOADED_) == 0
        return (FALSE)
    endif

    if Abs(current_time - GetBufferInt(GetLastTimeVarName())) >= check_period
        if FindThisFile(CurrFileName())
            GetBufferDaTmAttr(buf_high, buf_low, buf_attributes, buf_size)
            disk_high = FFHighDateTime()
            disk_low  = FFLowDateTime()
            disk_size = FFSize()

            if disk_high <> buf_high or disk_low <> buf_low or disk_size <> buf_size
                if GetBufferInt(GetIgnoredHighVarName()) == disk_high and GetBufferInt(GetIgnoredLowVarName()) == disk_low and GetBufferInt(GetIgnoredSizeVarName()) == disk_size

                    // already asked for this exact external version; do not ask again
                else
                    MaybeReload(CurrFileName(), file_reloaded)
                    if file_reloaded
                        DelBufferVar(GetDontCheckTimeVarName())
                        DelBufferVar(GetIgnoredHighVarName())
                        DelBufferVar(GetIgnoredLowVarName())
                        DelBufferVar(GetIgnoredSizeVarName())
                    else
                        // keep compatibility with older logic, but remember *which* version was ignored
                        SetBufferInt(GetDontCheckTimeVarName(), TRUE)
                        SetBufferInt(GetIgnoredHighVarName(), disk_high)
                        SetBufferInt(GetIgnoredLowVarName(),  disk_low)
                        SetBufferInt(GetIgnoredSizeVarName(), disk_size)
                    endif
                endif
            else
                // disk version now matches buffer again
                DelBufferVar(GetDontCheckTimeVarName())
                DelBufferVar(GetIgnoredHighVarName())
                DelBufferVar(GetIgnoredLowVarName())
                DelBufferVar(GetIgnoredSizeVarName())
            endif
        endif
        SetBufferInt(GetLastTimeVarName(), GetTime())
        checked = TRUE
    endif
    return (checked)
end

public proc CheckCurrentFile()
    integer file_reloaded = FALSE
    integer checked = CheckFile(GetTime(), 0, file_reloaded)
    warn(checked; file_reloaded)
end

/**************************************************************************
  Check the current file for updates on disk.

  If it has already been checked within the check period, check other
  loaded files, until our time period expires, or a key is pressed.

  Notes:

  In v3 and later, PopPosition causes _ON_CHANGING_FILES_ event to be
  called only when necessary.  Therefore, if we change files via
  NextFile(_DONT_LOAD_), which does not cause any events to be called,
  and we do not load a file, we can safely use PopPosition to restore
  the current file, without any events being called.

  Likewise, if a file is reloaded, the appropriate events are called,
  and so PopPosition will also cause the appropriate events to be called.
 **************************************************************************/
proc OnIdle()
    integer current_time = GetTime(), current_buffer_id, file_reloaded = FALSE, time_between_checks

    time_between_checks = current_time - last_checked_time
    if Query(IdleTime) < MIN_TIME_IDLE or  (time_between_checks > 0 and time_between_checks < MIN_TIME_IDLE)
        return ()
    endif

    if not CheckFile(current_time, CHECK_CURRENT_BUFFER_TIME, file_reloaded)
        PushPosition()
        current_buffer_id = GotoBufferId(last_checked_buffer_id)
        if current_buffer_id == 0
            current_buffer_id = GetBufferId()
        endif

        loop
            NextFile(_DONT_LOAD_)
            if GetBufferId() == current_buffer_id
                break
            endif
            if CheckFile(current_time, CHECK_ANY_BUFFER_TIME, file_reloaded)
                break
            endif
            if KeyPressed() or GetTime() - current_time >= MAX_TIME_USED
                break
            endif
        endloop
        last_checked_buffer_id = GetBufferId()
        PopPosition()
    endif
    if file_reloaded
        UpdateDisplay(_STATUSLINE_REFRESH_)
    endif
    last_checked_time = GetTime()
end

proc OnAfterFileSave()
    DelBufferVar(GetDontCheckTimeVarName())
    DelBufferVar(GetIgnoredHighVarName())
    DelBufferVar(GetIgnoredLowVarName())
    DelBufferVar(GetIgnoredSizeVarName())
end

proc WhenLoaded()
    last_time_check_buffer_var = SplitPath(CurrMacroFilename(), _NAME_) + ':'
    Hook(_IDLE_, OnIdle)
    Hook(_AFTER_FILE_SAVE_, OnAfterFileSave)
end
