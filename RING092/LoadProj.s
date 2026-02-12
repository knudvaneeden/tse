
 /*
    LoadProj.s

    Simple project loader.  Given a file containing a list of files,
    it will load all of those files into the editor.

    See LoadProj.txt for details

    Originally inspired by Semware's ldflist macro which ships with TSE.

 */

#ifndef MAXSTRINGLEN
#define MAXSTRINGLEN 255
#endif

#ifndef MAXPATH
#ifdef _MAXPATH_
#define MAXPATH _MAXPATH_
#else
#define MAXPATH MAXSTRINGLEN
#endif
#endif

integer First_Buffer_Loaded   = 0
integer Scratch_Buffer        = 0
integer Is_Ringlets_Available = FALSE


proc Debug_LoadedInfo(integer buffer_id, string tag)
    if 0 Debug_LoadedInfo(0,'') endif
    PushPosition()
    GotoBufferId(buffer_id)
    warn(tag + ' file: ' + CurrFileName() +'('+Str(GetBufferId())+') loaded:' + Str(Query(BufferFlags) & _LOADED_))
    PopPosition()
end


integer proc TryLoadMacro (string macro_name)
    if isMacroLoaded(macro_name) or LoadMacro(macro_name)
        return(1)
    endif
    return(0)
end

integer proc mEditFile(string filename)
    integer ret
    integer buffer_id
    if Length(filename) and FileExists(filename)
        PushPosition()

        ret = EditFile(filename, _DONT_LOAD_)
        buffer_id = GetBufferId()

        // Going to the scratch buffer
        // avoids current buffer being loaded
        GotoBufferId(Scratch_Buffer)
        if Is_Ringlets_Available
            ExecMacro('ringlets -a ' + Str(buffer_id))
        endif

        if not First_Buffer_Loaded
            First_Buffer_Loaded = buffer_id
        endif
        PopPosition()
    endif
    return(ret)
end


string proc GetTempDir()
    string temp_dir[MAXPATH] = ''
    temp_dir = GetEnvStr('TEMP')
    if not Length(temp_dir)
        temp_dir = GetEnvStr('TMP')
    endif
    if not Length(temp_dir)
        temp_dir = LoadDir()
    endif
    return(temp_dir)
end

proc LoadWildSpec (string passed_spec)
    integer temp_buffer           = CreateTempBuffer()
    string  tempfile[MAXPATH]     = MakeTempName(GetTempDir())
    string  cmd[MAXPATH]          = GetEnvStr('COMSPEC') + ' /c dir /b/a-d'
    integer dos_flags             = _DONT_CLEAR_
    integer recursive             = FALSE
    string  path_prefix[MAXPATH]  = ''
    string  spec[MAXPATH]         = passed_spec

    #ifdef WIN32
    dos_flags = _DONT_CLEAR_|_RUN_DETACHED_|_START_HIDDEN_
    #endif

    if spec[1] == '@'
        cmd       = cmd + '/s'
        spec      = Trim(spec[2..Length(spec)])
        recursive = TRUE
    endif

    cmd = cmd + ' '

    PushPosition()
    if GotoBufferId(temp_buffer) and Length(tempfile)

        Dos(cmd + spec + ' > ' + tempfile, dos_flags)

        EmptyBuffer()

        PushBlock()
        if InsertFile(tempfile)

            // The "dir /b" command returns files relative to the directory
            // specified on its command line.  To get absolute paths, we insert
            // that path at the beginning of every every line of the file

            if not recursive
                path_prefix = SplitPath(spec, _DRIVE_|_PATH_)
            endif

            BegFile()

            repeat
                if CurrLineLen()
                    mEditFile(path_prefix + GetText(1, CurrLineLen()))
                endif
            until not Down()

            AbandonFile(temp_buffer)
            EraseDiskFile(tempfile)

        endif
        PopBlock()
    endif
    PopPosition()
end

proc LoadSpec(string spec)
    if isWildPath(spec) or spec[1] == '@'
        LoadWildSpec(spec)
    else
        mEditFile(spec)
    endif
end

proc LoadProject (string passed_project_file)
    integer in_editfiles_section          = TRUE
    string  ring_properties[MAXSTRINGLEN] = ''
    string  project_file[MAXSTRINGLEN]    = passed_project_file
    string  ring_name[MAXSTRINGLEN]       = ''

    PushPosition()
    if Length(project_file)

        BegFile()

        repeat
            // See if the current line is an INI-File [section]
            if lFind('^[\t ]*\[[\t ]*{.*}[\t ]*\][\t ]*$', 'xcg')

                in_editfiles_section     = FALSE

                if Trim(Lower(GetFoundText(1))) == 'editfiles'
                    in_editfiles_section = TRUE
                endif

            else
                if in_editfiles_section
                    if lFind('^[\t ]*;*[\t ]*ring[\t ]*:[\t ]*{.+}[\t ]*$', 'xcgi')
                        ring_name = Trim(GetFoundText(1))
                        PushPosition()
                        if Is_Ringlets_Available
                            ExecMacro('ringlets -R ' + ring_name)
                        endif
                        PopPosition()

                        // Lookup the properties for this ring in the [rings] section of
                        // the project file.

                        // Since this file is an INI file, we can use the GetProfile* commands
                        // to read it!  Why not?

                        ring_properties = GetProfileStr('rings', ring_name, '', project_file)

                        if Length(ring_properties)
                            if Is_Ringlets_Available
                                ExecMacro('ringlets -s ' + ring_properties)
                            endif
                        endif

                    else
                        PushPosition()
                        LoadSpec(GetText(1, CurrLineLen()))
                        PopPosition()
                    endif
                endif
            endif
        until not Down()
    endif
    PopPosition()
end

proc WhenLoaded()
    Is_Ringlets_Available = TryLoadMacro('ringlets')
    PushPosition()
    Scratch_Buffer        = CreateTempBuffer()
    PopPosition()
end

proc WhenPurged()
    AbandonFile(Scratch_Buffer)
end

proc Main()
    string cmd[3]             = Query(MacroCmdLine)
    string spec[MAXSTRINGLEN] = Query(MacroCmdLine)

    cmd = Trim(cmd)
    if cmd[1] == '-'
        spec = Trim(spec[3..Length(spec)])
    endif

    First_Buffer_Loaded = 0

    if cmd == '-s'
        LoadSpec(spec)
    else
        if not Length(spec)
            spec = CurrFileName()
        endif
        // Turn off file loading in Ringlets
        // for quick loads
        if Is_Ringlets_Available
            ExecMacro('ringlets -P')
        endif
        LoadProject(spec)
        // Turn back on file loading in Ringlets
        if Is_Ringlets_Available
            ExecMacro('ringlets -F')
        endif
        if GotoBufferId(GetBufferId(spec))
            AbandonFile()
        endif
    endif

    if First_Buffer_Loaded
        GotoBufferId(First_Buffer_Loaded)
        // Loading may have been suspended
        // so now we have to explicitly load the file.
        EditFile(CurrFileName())
    endif

end


