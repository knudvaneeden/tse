// determinantarea.s - version 1.0.0.0.1
// TSE SAL launcher for determinantarea.ps1
// Four independent, persistent Ask() histories.

string proc DAAskValue(string prompt, string initialValue, string historyName)
    string value[80]
    integer historyId
    integer position

    value = initialValue
    historyId = GetFreeHistory(historyName)
    if historyId > 0
        if NumHistoryItems(historyId) > 0
            value = GetHistoryStr(historyId, 1)
        endif
    endif
    if not Ask(prompt, value, historyId)
        return("")
    endif
    if Length(value) == 0
        return("")
    endif
    if historyId > 0
        // Put the accepted value at the front without duplicate entries.
        position = FindHistoryStr(value, historyId)
        if position > 0
            DelHistoryStr(historyId, position)
        endif
        AddHistoryStr(value, historyId)
    endif
    return(value)
end

proc Main()
    string home[_MAXPATH_]
    string ini[_MAXPATH_]
    string ps[_MAXPATH_]
    string a11[80]
    string a12[80]
    string a21[80]
    string a22[80]
    string cmd[255]

    home = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    ini = home + "determinantarea.ini"
    ps = home + "determinantarea.ps1"

    a11 = DAAskValue("Matrix a11:", GetProfileStr("Matrix", "a11", "3", ini), "DETERMINANTAREA:a11")
    if Length(a11) == 0
        return()
    endif
    a12 = DAAskValue("Matrix a12:", GetProfileStr("Matrix", "a12", "1", ini), "DETERMINANTAREA:a12")
    if Length(a12) == 0
        return()
    endif
    a21 = DAAskValue("Matrix a21:", GetProfileStr("Matrix", "a21", "1", ini), "DETERMINANTAREA:a21")
    if Length(a21) == 0
        return()
    endif
    a22 = DAAskValue("Matrix a22:", GetProfileStr("Matrix", "a22", "2", ini), "DETERMINANTAREA:a22")
    if Length(a22) == 0
        return()
    endif

    // The PowerShell script handles floating-point validation and displays errors.
    // Store the current selection separately from the original Matrix defaults.
    WriteProfileStr("LastUsed", "a11", a11, ini)
    WriteProfileStr("LastUsed", "a12", a12, ini)
    WriteProfileStr("LastUsed", "a21", a21, ini)
    WriteProfileStr("LastUsed", "a22", a22, ini)
    FlushProfile(ini)

    // Use a separate, short command that reads the values from the same INI.
    // This avoids SAL's 255-character string/command limitations.
    cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File " + QuotePath(ps) + " -IniPath " + QuotePath(ini)
    Dos(cmd)
end
