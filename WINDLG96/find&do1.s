/***********************************************************************
  Find and do.

  Applies one of several options to a found string.

    copyright (c) 1998-2005 by SemWare
    interface for WinDlgs 01.06.2005 by DiK

  April 5, 2004 SEM - Don't allow Find&Do to run if potential file
        changing options are selected and the editor is in Browse Mode.
        Thanks to Carlo Hogeveen for the report.

  March 25, 2004 SEM
        Changed after-applying-macro logic to move right one character.
        Previously, we moved right the size of the found string.  But
        what if the found string was deleted?

  February 2004 SEM - in the mlRepeatFind(), change the code to
        call the lRepeatFind() if no lines were deleted.
        Previously, lRepeatFind() was only called if the number
        of lines did not change.  I'm not sure which is correct.

  July 2003 SEM - Implement speed-up involving 'G'lobal option.
        Thanks to Bruce Riggins for the tip.

  June 2003 SEM - Remove 'v' option if found.  Remove 'a' option
        if any of the 'all files' options were selected. Thanks
        to Jose Adriano Baltieri for the fix.

  February 7, 2003 - SEM:
        Add Find & Keep File option.  Will unload files where the find
            string is *not* found.
        Add Find & Quit File option.  Will unload files where the find
            string *is* found.
        Add Find & Apply Macro.  Allows an arbitrary macro to be run against
            each found string.
        Add Find & Apply Key.  Allows an arbitrary key to be pressed against
            each found string.  Key could be assigned to a keyboard macro,
            for instance.

  12/12/2002 - SEM: Use EmptyBuffer(id) to empty clipboard

  07/23/02 - SEM: If delete or cut was specified, and the
        target was found on the first line, the 2nd line is
        skipped.  The problem was with RepeatFind.  An old
        work-around did not handle the first line.

  06/22/00 - SEM: Whoops! previous change was broken.

  08/24/98 - SEM: if no prompting is NOT specified, will now prompt for
                  confirmation.
  07/29/98 - SEM: increase the find string maxlen to 200 characters.
 ***********************************************************************/

// order is important, specifically, we rely on multi-file options being last
constant dofDELLINE = 1, dofCUTAPPEND, dofCOPYAPPEND,
        dofCOUNT, dofMACRO, dofKEYMACRO, dofALLFILES, dofKEEP,
        dofQUIT

menu FindAndDoMenu()
    History
    Title = "After Find, Do"
    width = 17

    "&Delete Line"
    "C&ut Append"
    "&Copy Append"
    "Cou&nt"
    "&Apply Macro by Name"
    "Apply Key"
    "All Files", , Divide
    "&Keep File"
    "&Quit File"
end

integer buffer_id  // to determine if the first find in current file

integer proc NumFilesAndSystemKludge()
    return (NumFiles() + (BufferType() <> _NORMAL_))
end

/**************************************************************************
  Use n and num_lines to determine if a line was deleted, which invokes
  special case code.
 **************************************************************************/
integer proc mlRepeatFind(string find_st, string find_option_st0, integer n, integer num_lines)
    string find_option_st[12]
    integer p

    // if no lines where deleted, just repeat the find
    if n <= num_lines
        return (lRepeatFind())
    endif

    find_option_st = find_option_st0

    if GetBufferId() <> buffer_id
        buffer_id = GetBufferId()
    else
        // not first find, remove the G)lobal option
        p = Pos('G', Upper(find_option_st))
        if p > 0
            find_option_st = DelStr(find_option_st, p, 1)
        endif
    endif

    return (lFind(find_st, find_option_st))
end

/*************************************************************************
  March 25, 2004 SEM
  I'm not sure where to move the cursor after a macro has been executed.
  Some choices are:

  Do nothing, assume the macro positions it correctly

  If the number of lines has changed, move to the beginning of the
  current line.

  If the number of lines has not changed:

    Move right 1.

    Move right the length of the found string.
 *************************************************************************/
proc handleCursorPosition(integer num_lines, integer cur_line, integer cur_pos)
    if num_lines == NumLines()
        // no lines deleted
        if CurrLine() <= cur_line
            GotoLine(cur_line)
            if CurrPos() == cur_pos
                Right()
            endif
        endif
        elseif CurrLine()
    else
        // line was deleted
        BegLine()
    endif
end

proc ApplyDo(integer choice, string macro_name, integer macro_key, integer found_len)
    integer num_lines = NumLines()
    integer cur_line = CurrLine()
    integer cur_pos = CurrPos()

    if found_len    // just to keep the compiler happy - we don't use it for now
    endif

    case choice
        when dofDELLINE
            DelLine()
            BegLine()
        when dofCUTAPPEND, dofCOPYAPPEND
            PushBlock()
            MarkLine()
            MarkLine()
            if choice == dofCUTAPPEND
                Cut(_APPEND_)
            else
                Copy(_APPEND_)
            endif
            PopBlock()
            BegLine()
            if choice == dofCOPYAPPEND
                EndLine()
            endif
        when dofMACRO
            ExecMacro(macro_name)
            handleCursorPosition(num_lines, cur_line, cur_pos)
        when dofKEYMACRO
            PressKey(macro_key)
            handleCursorPosition(num_lines, cur_line, cur_pos)
    endcase
end

/**************************************************************************
  keep:
    Remove any files where find_st is _not_ found.
  not keep:
    Remove any files where find_st _is_ found.

  Notes:
    QuitFile() causes the previous file (ring-wise) to load.
 **************************************************************************/
proc findAndKeepOrQuit(string find_st, string find_option_st, integer keep)
    integer
        found,
        old_sound,
        hook_state,
        removed = 0,
        n = NumFilesAndSystemKludge()

    PushPosition()
    old_sound = Set(beep, off)
    hook_state = SetHookState(OFF)
    do n times
        PushPosition()
        found = lFind(find_st, find_option_st)
        PopPosition()

        if (keep and not found) or (not keep and found)
            if not QuitFile()
                break
            endif
            removed = removed + 1
        endif
        NextFile()
    enddo

    SetHookState(hook_state)
    Set(beep, old_sound)
    // restore position after turning hooks on, so _ON_CHANGING_FILES_ will run
    PopPosition()
    // and force hooks to fire, in case original file was quit
    if FileExists(CurrFilename())
        EditFile(QuotePath(CurrFilename()))
    endif
    Message(removed, " file(s) unloaded")
end

/**************************************************************************
    DiK:
    to use from macro
        put find_st and find_option_st on top of respective history
        set macro command line to choice (c.f. dof-constants)
    this completely disables user interface of find&do
        e.g. you must display count of found strings by yourself
            (count is put into MacroCmdLine variable)
 **************************************************************************/
proc main()
    integer
        choice, curr_id, count, n, old_sound, hook_state, check_buff,
        this_id, prompted, macro_key, reply_key, found_len
    string find_st[200] = '', find_option_st[12] = '', macro_name[_MAXPATH_] = ''

    buffer_id = 0       // we need initialize this global var each time

    choice = Val(Query(MacroCmdLine))
    find_st = GetHistoryStr(_FIND_HISTORY_, 1)
    find_option_st = GetHistoryStr(_FIND_OPTIONS_HISTORY_, 1)

    if choice <> 0 or
        Ask("Search for:",
            find_st,
            _FIND_HISTORY_)
            and Ask(
            "Options [BGLIWNX] (Back Global Local Ignore-case Words No-promp reg-eXp):",
            find_option_st, _FIND_OPTIONS_HISTORY_)
        count = 0

        prompted = Pos('N', Upper(find_option_st)) == 0
        if Pos('V', Upper(find_option_st))
            find_option_st = DelStr(find_option_st, Pos('V', Upper(find_option_st)), 1)
        endif

        curr_id = GetBufferId()
        if choice == 0
            choice = FindAndDoMenu()
        endif
        if choice > dofALLFILES
            if Pos('A', Upper(find_option_st))
                find_option_st = DelStr(find_option_st, Pos('A', Upper(find_option_st)), 1)
            endif
        endif


        case choice
            when 0
                return ()

            when dofCUTAPPEND, dofCOPYAPPEND    // cut/copy to buffer
                EmptyBuffer(Query(ClipBoardId))

            when dofMACRO
                repeat
                    if not Ask("Macro to run on each found string:",
                            macro_name) or Trim(macro_name) == ""
                        return ()
                    endif
                until isMacroLoaded(macro_name) or LoadMacro(macro_name)

            when dofKEYMACRO
                Message("Press the Key you want to apply on each found string, <esc> to cancel")
                macro_key = GetKey()
                if macro_key == <escape>
                    return ()
                endif

            when dofKEEP
                findAndKeepOrQuit(find_st, find_option_st, TRUE)
                return ()

            when dofQUIT
                findAndKeepOrQuit(find_st, find_option_st, FALSE)
                return ()

        endcase
        PushPosition()
        old_sound = Set(beep, off)
        hook_state = SetHookState(OFF)
        if lFind(find_st, find_option_st)
            curr_id = GetBufferId()
            check_buff = FALSE
            repeat
                found_len = Length(GetFoundText())
                this_id = GetBufferId()

                if check_buff and curr_id == this_id
                    break
                endif

                if BrowseMode() and (choice in dofDELLINE, dofCUTAPPEND, dofMACRO, dofKEYMACRO)
                    if MsgBoxEx("Buffer is in Browse Mode",
                            "The current operation cannot be performed because the current buffer is in Browse Mode",
                            "[&Skip current buffer];[&Halt operation]") == 1
                        EndFile()
                    else
                        break
                    endif
                endif

                if curr_id <> this_id
                    check_buff = TRUE
                endif

                count = count + 1
                n = NumLines()

                if not prompted
                    ApplyDo(choice, macro_name, macro_key, found_len)
                else
                    ScrollToCenter()
                    UpdateDisplay()
                    HiLiteFoundText()
                    Message("L ",
                        CurrLine(), " ", SplitPath(CurrFilename(), _NAME_|_EXT_),
                        "   Apply (Yes/No/Only/Rest/Quit)")
                    repeat
                        reply_key = GetKey()
                    until reply_key in
                            <Y>, <y>,
                            <N>, <n>,
                            <O>, <o>,
                            <R>, <r>,
                            <Q>, <q>,
                            <Escape>
                    case reply_key
                        when <Y>, <y>
                            ApplyDo(choice, macro_name, macro_key, found_len)
                        when <N>, <n>
                            // just skip this one, go on to next
                        when <O>, <o>
                            ApplyDo(choice, macro_name, macro_key, found_len)
                            break

                        when <R>, <r>
                            ApplyDo(choice, macro_name, macro_key, found_len)
                            prompted = FALSE

                        when <Q>, <q>, <Escape>
                            break
                    endcase
                endif
            until not mlRepeatFind(find_st, find_option_st, n, NumLines())
        endif
        SetHookState(hook_state)
        Set(beep, old_sound)
        // restore position after turning hooks on, so _ON_CHANGING_FILES_ will run
        PopPosition()
        if Query(MacroCmdLine) == ""
            Message(count, " occurrence(s) found")
        else
            Set(MacroCmdLine, Str(count))
            PurgeMacro(CurrMacroFilename())
        endif
    endif
end

