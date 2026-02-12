//  stub macro for explorer context menu
//  purpose: compile TSE macro

proc main()
    string fn[_MAXPATH_] = CurrFilename()

    if ChDir(SplitPath(fn,_DRIVE_|_PATH_))
        LogDrive(fn[1])
    endif
    PushKey(<Escape>)
    ExecMacro("compile "+CurrFilename())
    if NumWindows() == 1
        Exit()
    else
        PurgeMacro(CurrMacroFilename())
    endif
end
