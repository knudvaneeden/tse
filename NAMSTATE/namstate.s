/* NAMSTATE standalone macro, version 1.0.0.0.1 (2026-09-23).
   Original named-state routines: Dave Guyer, 1995. */

public proc mSaveState()
    string fn[255] = SplitPath(CurrMacroFilename(), _DRIVE_) + SplitPath(CurrMacroFilename(), _PATH_) + "tsestate.dat"
    if Ask("Save state to file: ", fn, _EDIT_HISTORY_) and Length(fn)
        ExecMacro("state -s -f" + fn)
        Message("State saved to " + fn)
    endif
end

public proc mRestoreState()
    string macroDir[255] = SplitPath(CurrMacroFilename(), _DRIVE_) + SplitPath(CurrMacroFilename(), _PATH_)
    string fn[255] = macroDir + "tsestate.dat"
    if Ask("Restore state from: ", fn, _EDIT_HISTORY_)
        if not Length(fn)
            fn = PickFile(macroDir)
        endif
        if Length(fn)
            ExecMacro("state -r -f" + fn)
        endif
    endif
end

proc Main()
    string iniFile[255] = SplitPath(CurrMacroFilename(), _DRIVE_) + SplitPath(CurrMacroFilename(), _PATH_) + "namstate.ini"
    string silentSetting[20] = Lower(GetProfileStr("namstate", "silent", "false", iniFile))
    string action[2] = "S"
    if silentSetting <> "true"
        Warn("NAMSTATE 1.0.0.0.1: Save or restore a named editor state. Choose S or R at the next prompt. See namstate_readme.md.")
    endif
    if Ask("Save or restore state (S/R): ", action, _EDIT_HISTORY_)
        if Lower(action) == "s"
            mSaveState()
        elseif Lower(action) == "r"
            mRestoreState()
        else
            Warn("Enter S to save or R to restore a state.")
        endif
    endif
end

<CtrlAltShift N> Main()
