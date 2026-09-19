// LOOKUP 1.0.0.0.4
// Updated 2026-09-19 11:01:53 UTC by OpenAI Codex

string proc FNReadCommandList()
    integer current_id = GetBufferId()
           ,ini_was_loaded
           ,equals_pos

    string  command_list[255] = "tse.260"
           ,ini_line[255] = ""
           ,ini_name[255] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_) + "lookup.ini"

    if FileExists(ini_name)
        ini_was_loaded = GetBufferId(ini_name)

        if EditFile(ini_name)
            BegFile()

            if lFind("^commandlist=", "ix")
                ini_line = GetText(1, 255)
                equals_pos = Pos("=", ini_line)

                if equals_pos
                    ini_line = Trim(SubStr(ini_line, equals_pos + 1, 255))

                    if ini_line <> ""
                        command_list = ini_line
                    endif
                endif
            endif

            if not ini_was_loaded
                AbandonFile()
            endif
        endif

        GotoBufferId(current_id)
    endif

    return(command_list)
end

proc local_look_up()
    integer procs_id
           ,current_id = GetBufferId()
           ,str_size
//         ,save_help_msg_sw
           ,zoom_stat

    string  proc_str[32]       = ""

    zoom_stat = isZoomed()

    if not zoom_stat
        ZoomWindow()
    endif

//  save_help_msg_sw = Query(ShowHelpLine)
//  Set(ShowHelpLine,on)
//  Enable(help_msg)
//  UpdateDisplay(_REFRESH_THIS_ONLY_|_HELPLINE_REFRESH_)
    procs_id = CreateTempBuffer()
    GotoBufferId(current_id)
    PushPosition()
    PushBlock()
    UnMarkBlock()
    lFind("^{menu}|{{public #}?{{integer #}|{string #}}@proc} +[a-zA-Z_]","gix")

    repeat
        Wordright()
        MarkColumn()
        lFind("(","")
        Left()
        MarkColumn()
        proc_str = GetText(Query(BlockBegCol),Query(BlockEndCol) - Query(BlockBegCol) + 1) + "()"
        UnMarkBlock()
        GotoBufferId(procs_id)
        AddLine(proc_str)
        GotoBufferId(current_id)
    until not lFind("^{menu}|{{public #}?{{integer #}|{string #}}@proc} +[a-zA-Z_]","ix")

    PopBlock()
    PopPosition()
    GotoBufferId(procs_id)
    BegFile()

    GotoBufferId(procs_id)

    Set(Y1,2)

    if lList("Local Commands", SizeOf(proc_str), Query(ScreenRows) - 4
             ,_ENABLE_SEARCH_)
        proc_str = GetText(1, SizeOf(proc_str))
        GotoBufferId(current_id)
        str_size = SizeOf(proc_str)

        while proc_str[str_size] == ' '
            str_size = str_size - 1
        endwhile

        InsertText(Substr(proc_str,1,str_size),_INSERT_)
    else
        GotoBufferId(current_id)
    endif

    AbandonFile(procs_id)

    if not zoom_stat
        ZoomWindow()
    endif

//  Disable(help_msg)
//  Set(ShowHelpLine,save_help_msg_sw)
end

keydef help_msg
    <helpline> "Search mode active. Pick a command and press {<ENTER>} to insert it into the text."
end

proc look_up()
    integer current_id = GetBufferId()
           ,library_was_loaded
           ,str_size
//         ,save_help_msg_sw
           ,save_msg_lvl
           ,zoom_stat

    string  proc_str[32] = ""
           ,library_name[255] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_) + FNReadCommandList()

    zoom_stat = isZoomed()

    if not zoom_stat
        ZoomWindow()
    endif

//  save_help_msg_sw = Query(ShowHelpLine)
//  Set(ShowHelpLine,on)
//  Enable(help_msg)
//  UpdateDisplay(_REFRESH_THIS_ONLY_|_HELPLINE_REFRESH_)
    if not FileExists(library_name)
        GotoBufferId(current_id)
        if not zoom_stat
            ZoomWindow()
        endif
        Warn("Cannot find command list: " + library_name)
        return()
    endif

    library_was_loaded = GetBufferId(library_name)
    save_msg_lvl = Query(MsgLevel)
    Set(MsgLevel,_WARNINGS_ONLY_)

    if not Editfile(library_name)
        Set(MsgLevel,save_msg_lvl)
//          Set(ShowHelpLine,save_help_msg_sw)
//          Disable(help_msg)
        GotoBufferId(current_id)
        if not zoom_stat
            ZoomWindow()
        endif
        Warn("Cannot open " + library_name + "; aborting.")
        return()
    endif

    Set(MsgLevel,save_msg_lvl)
    BegFile()

    Set(Y1,2)

    if lList("TSE Commands", SizeOf(proc_str), Query(ScreenRows) - 4
             ,_ENABLE_SEARCH_)
        proc_str = GetText(1, SizeOf(proc_str))

        if not library_was_loaded
            AbandonFile()
        endif

        GotoBufferId(current_id)
        str_size = SizeOf(proc_str)

        while proc_str[str_size] == ' '
            str_size = str_size - 1
        endwhile

        InsertText(Substr(proc_str,1,str_size),_INSERT_)
    else
        if not library_was_loaded
            AbandonFile()
        endif

        GotoBufferId(current_id)
    endif


    if not zoom_stat
        ZoomWindow()
    endif

//  Disable(help_msg)
//  Set(ShowHelpLine,save_help_msg_sw)
end

proc main()
    Set(X1,25)
    Set(Y1,2)
    look_up()
end

<shift f12> local_look_up()
<f12> main()


