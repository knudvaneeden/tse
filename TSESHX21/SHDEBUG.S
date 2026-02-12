//  stub macro for explorer context menu
//  purpose: execute TSE macro debugger

proc main()
    string fn[_MAXPATH_] = CurrFilename()

    if ChDir(SplitPath(fn,_DRIVE_|_PATH_))
        LogDrive(fn[1])
    endif
    ExecMacro("debug "+CurrFilename())
    PurgeMacro(CurrMacroFilename())
end
