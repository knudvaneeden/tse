/*
    Base version:
        Sammy Mitchell's posting on Saterday 6 December 2003 at 19:53
        in the TSE Beta list.

    Changes by Carlo Hogeveen on 7 December 2003:
    -   Mouse changes:
        -   Single-click on +/- to expand/collaps directories.
        -   Single-click on a directory to hilite it.
        -   Double-click on a directory to select it.
        -   Coudn't solve the existing scrollbar/closebutton bug.
    -   Don't show full directory paths on each line. It is too much redundant
        information, and directories sooner become too deep or long to show.
    -   To compensate, try to show the full path above the list. If the full
        path is too long, then show the right hand side of it.
    -   Added a message for possibly slow situations: when searching for
        drives and when expanding root directories. The latter is handy
        for cdrom drives and other slow external drives.
    -   Extended the Left key to collaps a parent directory from any of its
        child directories, and to collaps all drives when used from a drive.
        This also enables the user to quickly get a list of only drives
        from anywhere by just pressing the Left key repeatedly.
    -   Added a Help screen, which alas made it necessary to increase screen
        flickering.
    -   Changed the word "contract" to "collaps", because other software
        calls it so.

    Changes by Carlo Hogeveen on 9 December 2003:
    -   Solved the scrollbar/closebutton bug. The (acceptable?) downside is,
        that BrwsDr no longer works for TSE versions below 4.0.
        Sparked by Sammy's elaborate explanation why our existing solution
        did not work, I thought of an alternative solution which does work.
    -   Tiny bug solved: no longer collaps a directory if the user clicks
        on a "-" in a directoryname.

    Changes by Sammy Mitchell on 11 December 2003:
    -   Solved the screen flickering problem.

    Changes by Carlo Hogeveen on 12 December 2003:
    -   Made clicking on the help-line execute its functions.
*/

constant LEVEL_WIDTH = 3
constant ENTER_PRESSED = -2, OTHER_KEYS = -1

integer dont_show_dir = FALSE
integer from_help = FALSE

proc show_help()
    dont_show_dir = TRUE
    from_help = TRUE
    BufferVideo()
    PopWinOpen(1, 1, Query(ScreenCols), Query(ScreenRows), 1,
               " Help for browsing directories", Query(MenuBorderAttr))
    Set(Attr, Query(HelpTextAttr))
    ClrScr()
    VGotoXY(1,2)
    WriteLine("")
    WriteLine("In this Help screen:")
    WriteLine("")
    WriteLine("    Press or click anything to leave this Help screen.")
    WriteLine("")
    WriteLine("When browsing directories:")
    WriteLine("")
    WriteLine("    Mouse actions:")
    WriteLine("")
    WriteLine("        Single-left-click on +/-            Expand/collaps directories.")
    WriteLine("        Single-left-click on a directory    Hilite the directory.")
    WriteLine("        Double-left-click on a directory    Select the directory.")
    WriteLine("        Single-right-click                  Stop browsing directories.")
    WriteLine("")
    WriteLine("    Keyboard actions:")
    WriteLine("")
    WriteLine("        F1      Show this Help screen")
    WriteLine("        Right   Expand the current directory.")
    WriteLine("        Left    Collaps the current or another expanded directory.")
    WriteLine("        Enter   Select the current directory.")
    WriteLine("        Escape  Stop browsing directories.")
    UnBufferVideo()
    GetKey()
    PopWinClose()
end

integer proc is_real_dir()
    return ((FFAttribute() & _DIRECTORY_) and not (FFName() in ".", ".."))
end

integer proc has_subdirs(string dir)
    integer result = FALSE
    integer handle = FindFirstFile(dir + "\*", -1)
    if handle <> -1
        repeat
            if is_real_dir()
                result = TRUE
            endif
        until result or not FindNextFile(handle, -1)
        FindFileClose(handle)
    endif
    return (result)
end

integer proc get_level()
    integer level = PosFirstNonWhite()
    if not (GetText(level, 1) in '+', '-')
        level = level - 2
    endif
    return (level)
end

string proc normalize_drive(string path)
    return (iif(path[2:3] == ": [", path[1:2], path))
end

proc add_line(integer level, string pf_path, string fn)
    AddLine(Format("":level-1:' ',
                   iif(has_subdirs(pf_path + normalize_drive(fn)), "+", " "),
                   " ",
                   fn))
end

proc add_drives()
    string drivestr[_MAXPATH_] = ""
    Message("Searching for drives ... ")
    while NextDiskConnection(drivestr, 0) // 0 = _INCLUDE_REMOVEABLE_DRIVES_
        drivestr[1] = Lower(drivestr[1])
        add_line(2, "", drivestr)
    endwhile
end

proc GetDirs(string mask, integer level)
    integer handle, attribute, start_line, msg_level
    string fn[_MAXPATH_], pf_path[_MAXPATH_]

    PushBlock()
    if level == 1
        level = level + 1
    else
        level = level + 2
    endif
    start_line = 0
    // now store any directories found in mask
    attribute = -1
    fn = ExpandPath(mask)
    handle = FindFirstFile(SplitPath(fn, _DRIVE_|_PATH_) + "*", attribute)
    if handle <> -1
        pf_path = SplitPath(fn, _DRIVE_|_PATH_)
        repeat
            if is_real_dir()
                fn = FFName()
                add_line(level, pf_path, fn)
                if start_line == 0
                    start_line = CurrLine()
                endif
            endif
        until not FindNextFile(handle, attribute)
        FindFileClose(handle)
    endif

    if start_line
        MarkColumn(start_line, level + 2, CurrLine(), level + 2 + 255)
        msg_level = Set(MsgLevel, _WARNINGS_ONLY_)
        Sort(_IGNORE_CASE_)
        Set(MsgLevel, msg_level)
    endif
    PopBlock()
end

string proc GetListSubDir()
    string result [_MAXPATH_] = GetText(get_level() + 2, CurrLineLen())
    result = normalize_drive(result)
    return(result)
end

string proc GetListDir()
    string result  [_MAXPATH_] = GetListSubDir()
    integer level = get_level()
    PushPosition()
    repeat
        Up()
        if get_level() < level
            level  = get_level()
            result = GetListSubDir() + "\" + result
        endif
    until get_level() < LEVEL_WIDTH
    PopPosition()
    return(result)
end

proc DoOpen()
    integer level
    string c_open[1]

    level = get_level()
    c_open = GetText(level, 1)

    if c_open == '+'
        if level == 2
            Message("Expanding ", GetListDir(), " ... ")
        endif
        // closed level, open it
        PushLocation()
        GetDirs(GetListDir() + "\*", level + 1)
        PopLocation()
        GotoPos(level)
        InsertText('-', _OVERWRITE_)
    endif

    BegLine()
end

proc DoClose()
    integer level = get_level()

    if GetText(level, 1) <> '-'
        if level == 2
            lFind("^ +- ", "gx")
        else
            lFind("^ +- ", "bx")
        endif
    endif

    level = get_level()

    if GetText(level, 1) == '-'
        // open level, close it
        PushPosition()
        if Down()
            while get_level() > level and KillLine()
            endwhile
        endif
        PopPosition()
        GotoPos(level)
        InsertText('+', _OVERWRITE_)
    endif

    BegLine()
end

proc DoEnter()
    integer level
    string c_open[1]

    level = get_level()
    c_open = GetText(level, 1)

    if c_open == '-'
        DoClose()
    elseif c_open == '+'
        DoOpen()
    endif
end

proc FindPlace(string curr_dir)
    integer n, i
    string s[_MAXPATH_]

    n = NumTokens(curr_dir, '\')
    s = GetToken(curr_dir, '\', 2)
    i = 3
    while lFind(s, "giw$")
        DoEnter()
        if i > n
            break
        endif
        s = GetToken(curr_dir, '\', i)
        i = i + 1
    endwhile
end

string proc get_helpline_word()
    string result [_MAXPATH_] = ""
    string character [2] = ""
    string attribute [2] = ""
    string clicked_attribute[2] = ""
    integer x = Query(MouseX)
    integer y = Query(MouseY)
    integer x_from = 0
    if  GetStrAttrXY(x, y, character, clicked_attribute, 1)
    and (character in Chr(33) .. Chr(128))
        while GetStrAttrXY(x, y, character, attribute, 1)
        and   (character in Chr(32) .. Chr(128))
        and   attribute == clicked_attribute
            x = x - 1
        endwhile
        x_from = x + 1
        x = Query(MouseX) + 1
        while GetStrAttrXY(x, y, character, attribute, 1)
        and   (character in Chr(32) .. Chr(128))
        and   attribute == clicked_attribute
            x = x + 1
        endwhile
        GetStrXY(x_from, y, result, x - x_from)
        result = Trim(result)
    endif
    return(result)
end

proc do_key(integer key_name)
    PushKey(-1)
    GetKey()
    PushKey(key_name)
end

integer prev_clockticks = 0

proc left_btn()
    if  Query(MouseX) >= Query(WindowX1)
    and Query(MouseX) <= Query(WindowX1) + Query(WindowCols) - 1
    and Query(MouseY) >= Query(WindowY1)
    and Query(MouseY) <= Query(WindowY1) + Query(WindowRows) - 1
        GotoRow(Query(MouseY))
        case GetText(Query(MouseX), 1)
            when '+'        DoOpen()
            when '-'        if get_level() == Query(MouseX)
                                DoClose()
                            endif
            when '', ' '    NoOp()
            otherwise       if  Query(LastMouseX) == Query(MouseX)
                            and Query(LastMouseY) == Query(MouseY)
                            and GetClockTicks() - prev_clockticks < 18
                                EndProcess(ENTER_PRESSED)
                            endif
                            prev_clockticks = GetClockTicks()
        endcase
    else
        if (   Query(MouseX) == Query(WindowX1) + Query(WindowCols)
           and Query(MouseY) >= Query(WindowY1)
           and Query(MouseY) <= Query(WindowY1) + Query(WindowRows) - 1)
        or (   Query(MouseX) >= Query(WindowX1)
           and Query(MouseX) <= Query(WindowX1) + Query(WindowCols) - 1
           and Query(MouseY) == Query(WindowY1) - 1)
            NoOp() // Don't interfere with upper and right border.
        else
            if  Query(MouseX) >= Query(WindowX1)
            and Query(MouseX) <= Query(WindowX1) + Query(WindowCols) - 1
            and Query(MouseY) == Query(WindowY1) + Query(WindowRows)
                case get_helpline_word()
                    when "F1", "-Help"
                        do_key(<f1>)
                    when "Right", "-Expand"
                        do_key(<cursorright>)
                    when "Left", "-Collapse"
                        do_key(<cursorleft>)
                    when "Enter", "-Select"
                        do_key(<enter>)
                    when "Esc", "-Quit"
                        do_key(<Escape>)
                endcase
            else
                if Query(Beep)
                    Alarm() // The user is way out of line: beep at him!
                endif
            endif
            EndProcess(other_keys)
        endif
    endif
end

string browse_footer[] = "{F1}-Help {Right}-Expand {Left}-Collapse {Enter}-Select {Esc}-Quit"

keydef browsekeys
    <enter>                                 EndProcess(ENTER_PRESSED)
    <cursorright>   DoOpen()                EndProcess(OTHER_KEYS)
    <cursorleft>    DoClose()               EndProcess(OTHER_KEYS)
    <f1>            show_help()
end

proc show_dir()
    string curr_dir[_MAXPATH_] = ""
    if dont_show_dir
        dont_show_dir = FALSE
    else
        curr_dir = GetListDir()
        if Length(curr_dir) <= Query(ScreenCols) - 2
           Message(curr_dir)
        else
           Message(SubStr(curr_dir,
                          Length(curr_dir) - Query(ScreenCols) + 1,
                          Query(ScreenCols)))
        endif
    endif
end

proc BrowseStartup()
    UnHook(BrowseStartup)
    Enable(browsekeys)
    ListFooter(browse_footer)
end

proc BrowseCleanup()
   Disable(browsekeys)
end

proc Set_Y1()
   integer new_y1 = 2
   if Query(ShowMainMenu)
      new_y1 = new_y1 + 1
   endif
   Set(Y1, new_y1)
end

proc after_nonedit_command()
    if from_help
        from_help = FALSE
    else
        if Query(Key) == <leftbtn>
            left_btn()
        endif
    endif
end

proc list_before_command()
    show_dir()
end

string proc browse_for_dir()
    integer id, pickbuf, choice, WIDTH
    integer old_StatusLineAtTop = Set(StatusLineAtTop, ON)
    integer old_ShowStatusLine  = Set(ShowStatusLine , ON)
    string dir     [_MAXPATH_] = ""

    Hook(_AFTER_NONEDIT_COMMAND_, after_nonedit_command)
//    Hook(_LIST_BEFORE_COMMAND_, list_before_command)  // in 4.00.49
    Hook(_BEFORE_GETKEY_, list_before_command)

    id = GetBufferId()
    pickbuf = CreateTempBuffer()

    add_drives()
    BegFile()
    if lFind(' ' + GetDrive() + ': ', 'i')
        DoOpen()
    endif
    FindPlace(CurrDir())

    BufferVideo()
    loop
        Hook(_LIST_STARTUP_, BrowseStartup)
        Hook(_LIST_CLEANUP_, BrowseCleanup)
        WIDTH = LongestLineInBuffer() + 8
        Set_Y1()
        choice = List("Browse Dir", Max(WIDTH, Length(browse_footer)))
        UnHook(BrowseCleanup)
        case choice
            when 0
                break
            when ENTER_PRESSED
                dir = GetListDir()
                break
        endcase
    endloop
    UnBufferVideo()

    GotoBufferId(id)
    AbandonFile(pickbuf)
    Set(StatusLineAtTop, old_StatusLineAtTop)
    Set(ShowStatusLine , old_ShowStatusLine)

    UnHook(after_nonedit_command)
    UnHook(list_before_command)
    return (dir)
end

proc Main()
    Warn(browse_for_dir())
    PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

