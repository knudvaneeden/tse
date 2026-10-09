// PROJSTART.S - portable launcher for PROJ v2.00
// Package version 1.0.0.0.168 - OpenAI Codex (GPT-6)
// Compile with the same SAL compiler used for proj.si.

dll "<kernel32.dll>"
    integer proc PROJSetDllDirectory(string directory:cstrval) : "SetDllDirectoryA"
end

proc Main()
    string installDir[255] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_)

    if not Length(installDir)
        Warn("Cannot find the PROJ installation directory.")
        return()
    endif
    if installDir[Length(installDir)] <> "\" and
            installDir[Length(installDir)] <> "/"
        installDir = installDir + "\"
    endif

    if not PROJSetDllDirectory(installDir)
        Warn("Cannot set the DLL search directory: " + installDir)
        return()
    endif

    if not FileExists(installDir + "proj.mac")
        Warn("Cannot find proj.mac in " + installDir)
        return()
    endif
    if not FileExists(installDir + "ProjDLL.dll") or
            not FileExists(installDir + "msbsc60.dll")
        Warn("Put ProjDLL.dll and msbsc60.dll beside projstart.mac.")
        return()
    endif

    SetGlobalStr("PROJ0200_FromLauncher", "true")
    ExecMacro(QuotePath(installDir + "proj.mac"))
    SetGlobalStr("PROJ0200_FromLauncher", "")
end
