// leastsquaresline.s - version 1.0.0.0.5
// TSE Pro SAL front end. All interactive input is obtained with Ask().

#define HIST_LSL_N       231
#define HIST_LSL_POINTS  232
#define HIST_LSL_XPRED   233

proc Main()
    string macroDir[255] = ""
    string iniFile[255] = ""
    string psFile[255] = ""
    string numberText[32] = ""
    string pointsText[255] = ""
    string xPredictionText[64] = ""
    string cmdLine[255] = ""
    integer pointCount = 0
    integer oldPersistent = 0

    macroDir = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    if Length(macroDir) == 0
        macroDir = CurrDir()
    endif
    if SubStr(macroDir, Length(macroDir), 1) <> "\" and
       SubStr(macroDir, Length(macroDir), 1) <> "/"
        macroDir = macroDir + "\"
    endif

    iniFile = macroDir + "leastsquaresline.ini"
    psFile = macroDir + "leastsquaresline.ps1"

    if not FileExists(psFile)
        Warn("Missing PowerShell file: ", psFile)
        return()
    endif
    if not FileExists(iniFile)
        Warn("Missing INI file: ", iniFile)
        return()
    endif

    numberText = GetProfileStr("parameters", "N", "4", iniFile)
    pointsText = GetProfileStr("parameters", "xypoints", "(1,2) (2,3) (3,5) (4,6)", iniFile)
    xPredictionText = GetProfileStr("parameters", "xpredictionvalue", "8", iniFile)

    // Dedicated Ask history lists; preserved across sessions in TSEHIST.DAT.
    oldPersistent = Query(PersistentHistory)
    Set(PersistentHistory, ON)

    if not Ask("Number of XY points (N):", numberText, HIST_LSL_N)
        Set(PersistentHistory, oldPersistent)
        return()
    endif
    pointCount = Val(numberText)
    if pointCount < 2
        Warn("N must be a whole number of at least 2.")
        Set(PersistentHistory, oldPersistent)
        return()
    endif

    if not Ask("XY points (x,y) (x,y) ...:", pointsText, HIST_LSL_POINTS)
        Set(PersistentHistory, oldPersistent)
        return()
    endif
    if Length(pointsText) == 0
        Warn("At least two XY pairs are required.")
        Set(PersistentHistory, oldPersistent)
        return()
    endif

    if not Ask("X value for least-squares prediction:", xPredictionText, HIST_LSL_XPRED)
        Set(PersistentHistory, oldPersistent)
        return()
    endif
    Set(PersistentHistory, oldPersistent)
    if Length(xPredictionText) == 0
        Warn("The prediction X value must not be empty.")
        return()
    endif

    // Save the values only AFTER all dialogs succeed; PowerShell reads these.
    if not WriteProfileStr("parameters", "N", numberText, iniFile)
        Warn("Could not write N to ", iniFile)
        return()
    endif
    if not WriteProfileStr("parameters", "xypoints", pointsText, iniFile)
        Warn("Could not write xypoints to ", iniFile)
        return()
    endif
    if not WriteProfileStr("parameters", "xpredictionvalue", xPredictionText, iniFile)
        Warn("Could not write xpredictionvalue to ", iniFile)
        return()
    endif
    FlushProfile(iniFile)

    // Launch through Windows CMD START so the PowerShell GUI process is detached
    // from TSE/TCC. -WindowStyle Hidden hides PowerShell's own console window;
    // the WinForms graph window created by the script remains visible.
    cmdLine = "cmd.exe /D /C start " + Chr(34) + Chr(34) +
              " powershell.exe -NoProfile -STA -WindowStyle Hidden -ExecutionPolicy Bypass -File " +
              Chr(34) + psFile + Chr(34) + " -IniPath " + Chr(34) + iniFile + Chr(34)
    if Length(cmdLine) >= 255
        Warn("PowerShell command is too long. Use a shorter macro folder path.")
        return()
    endif

    // CMD exits immediately after START; PowerShell/graph continues independently.
    Dos(cmdLine, _DONT_CLEAR_ | _DONT_PROMPT_ | _DONT_WAIT_)
end
