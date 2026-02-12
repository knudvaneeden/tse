//  stub macro for explorer context menu
//  purpose: restore previously saved editor state

string state_filename[] = "tsestate.dat"

proc main()
    string name[255]

    name = SplitPath(CurrFilename(),_NAME_|_EXT_)
    if Lower(name) == state_filename
        name = SplitPath(CurrFilename(),_DRIVE_|_PATH_)
        if Length(name) and ChDir(name)
            LogDrive(name[1])
        endif
        AbandonFile()
        ExecMacro("state -q -r -f" + state_filename)
    endif
    PurgeMacro(CurrMacroFilename())
end
