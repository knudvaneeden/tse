// bellcurve.s - TSE SAL 4.50 - version 1.0.0.0.2
// Locate companion files beside the executing compiled macro, not CurrDir().
// Dedicated persistent TSE Ask histories are used for each input.

proc Main()
    string folder[255] = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    string iniFile[255]
    string scriptFile[255]
    string countText[20]
    string pointsText[255]
    string command[255]
    integer countHist, pointsHist
    integer n

    // Macro location is independent of the TSE working directory.
    // Handle a missing trailing slash defensively.
    if Length(folder) > 0
        if SubStr(folder, Length(folder), 1) <> "\\"
            folder = folder + "\\"
        endif
    endif

    if Length(folder) == 0
        Warn("Cannot determine the BELLCURVE macro directory.")
        return()
    endif

    iniFile = folder + "bellcurve.ini"
    scriptFile = folder + "bellcurve.ps1"
    countText = GetProfileStr("Parameters", "N", "8", iniFile)
    pointsText = GetProfileStr("Parameters", "datapoints", "2, 4, 4, 4, 5, 5, 7, 9", iniFile)

    countHist = GetFreeHistory("BELLCURVE:N")
    pointsHist = GetFreeHistory("BELLCURVE:datapoints")

    if not Ask("Number of data points (N):", countText, countHist)
        return()
    endif
    if Length(Trim(countText)) == 0
        return()
    endif
    n = Val(countText)
    if n < 2 or Str(n) <> Trim(countText)
        Warn("N must be an integer of at least 2.")
        return()
    endif

    if not Ask("Data points (comma separated):", pointsText, pointsHist)
        return()
    endif
    if Length(Trim(pointsText)) == 0
        return()
    endif

    if not FileExists(scriptFile)
        Warn("Cannot find ", scriptFile)
        return()
    endif

    // Quotes in data are not accepted; PowerShell validates all numbers and N.
    if Pos('"', pointsText)
        Warn("Double quote characters are not allowed in data points.")
        return()
    endif

    // Windows PowerShell 5.1; STA is required for Windows Forms.
    // No cmd /k or additional persistent TCC console.
    command = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "' +
              scriptFile + '" -N ' + countText + ' -Data "' + pointsText + '"'

    if Length(command) >= 255
        Warn("Command line too long for SAL (255 characters).")
        return()
    endif
    Dos(command, _DONT_PROMPT_)
end
