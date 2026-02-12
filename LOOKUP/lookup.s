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

menu local_look_up_menu()
    "", local_look_up() ,CloseAfter,
    "Search mode active. Pick a command and press <ENTER> to insert it into the text."
end

proc local_lookup()
    Set(X1,25)
    Set(Y1,2)
    PushKey(<Enter>)
    local_look_up_menu()
end

keydef help_msg
    <helpline> "Search mode active. Pick a command and press {<ENTER>} to insert it into the text."
end

proc look_up()
    integer procs_id
           ,libry_id
           ,current_id = GetBufferId()
           ,str_size
//         ,save_help_msg_sw
           ,save_msg_lvl
           ,zoom_stat

    string  proc_str[32]       = ""
           ,procs_buff_name[7] = "[procs]"

    zoom_stat = isZoomed()

    if not zoom_stat
        ZoomWindow()
    endif

//  save_help_msg_sw = Query(ShowHelpLine)
//  Set(ShowHelpLine,on)
//  Enable(help_msg)
//  UpdateDisplay(_REFRESH_THIS_ONLY_|_HELPLINE_REFRESH_)
    procs_id = CreateBuffer(procs_buff_name,_HIDDEN_)

    if procs_id
        save_msg_lvl = Query(MsgLevel)
        Set(MsgLevel,_WARNINGS_ONLY_)

        if not Editfile(LoadDir() + "tse.260")
            Set(MsgLevel,save_msg_lvl)
//          Set(ShowHelpLine,save_help_msg_sw)
//          Disable(help_msg)
            Warn("LAN not available; Aborting...")
            PurgeMacro("LookUp")
            return()
        endif

        Set(MsgLevel,save_msg_lvl)
        libry_id = GetBufferId(CurrFilename())
        BegFile()

        repeat
            proc_str = GetText(1, SizeOf(proc_str))
            GotoBufferId(procs_id)
            AddLine(proc_str)
            GotoBufferId(libry_id)
        until not Down()

        AbandonFile()
        GotoBufferId(procs_id)
        BegFile()
    else
        procs_id = GetBufferId(procs_buff_name)
    endif

    GotoBufferId(procs_id)

    Set(Y1,2)

    if lList("TSE Commands", SizeOf(proc_str), Query(ScreenRows) - 4
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


    if not zoom_stat
        ZoomWindow()
    endif

//  Disable(help_msg)
//  Set(ShowHelpLine,save_help_msg_sw)
end

menu look_up_menu()
    "", look_up() ,CloseAfter,
    "Search mode active. Pick a command and press <ENTER> to insert it into the text."
end

proc main()
    Set(X1,25)
    Set(Y1,2)
    PushKey(<Enter>)
    look_up_menu()
    //local_look_up_menu()
end

<shift f12> local_lookup()
<f12> main()


