// riemannhypothesisgraph.s - version 1.0.0.0.9
// TSE SAL 4.50.x; graphical computation performed by Windows PowerShell 5.1.
// All resources and results live beside the executing compiled .mac file.

string gIniS[255]

string proc AskSettingS(string keyS, string defaultS, string questionS)
    string valueS[255]
    valueS = GetProfileStr("graph", keyS, defaultS, gIniS)
    if NOT Ask(questionS, valueS, _EDIT_HISTORY_)
        return("")
    endif
    if Length(valueS) == 0
        Warn("A value is required for ", keyS)
        return("")
    endif
    WriteProfileStr("graph", keyS, valueS, gIniS)
    return(valueS)
end

proc Main()
    string baseS[255]
    string scriptS[255]
    string commandS[255]
    string valueS[255]
    integer resultI

    baseS = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    gIniS = baseS + "riemannhypothesisgraph.ini"
    scriptS = baseS + "riemannhypothesisgraph.ps1"

    if NOT FileExists(scriptS)
        Warn("Missing PowerShell script: ", scriptS)
        return()
    endif
    if NOT FileExists(gIniS)
        Warn("Missing INI file: ", gIniS)
        return()
    endif

    valueS = AskSettingS("theme", "dark", "Graph theme: light or dark:")
    if valueS == "" return() endif
    valueS = AskSettingS("default_view", "image", "Initial view: image, plane or surface:")
    if valueS == "" return() endif
    valueS = AskSettingS("real_min", "-6", "Real axis: minimum (-6):")
    if valueS == "" return() endif
    valueS = AskSettingS("real_max", "4", "Real axis: maximum (2):")
    if valueS == "" return() endif
    valueS = AskSettingS("imag_min", "-18", "Imaginary axis: minimum (0):")
    if valueS == "" return() endif
    valueS = AskSettingS("imag_max", "18", "Imaginary axis: maximum (35):")
    if valueS == "" return() endif
    valueS = AskSettingS("real_samples", "121", "Real-axis sample points (49):")
    if valueS == "" return() endif
    valueS = AskSettingS("imag_samples", "151", "Imaginary-axis sample points (71):")
    if valueS == "" return() endif
    valueS = AskSettingS("image_sigma_lines", "15", "Mapped curves: fixed real(s) lines (2..32):")
    if valueS == "" return() endif
    valueS = AskSettingS("image_t_lines", "13", "Mapped curves: fixed imag(s) lines (2..32):")
    if valueS == "" return() endif
    valueS = AskSettingS("height_cap", "8", "Maximum displayed magnitude (8):")
    if valueS == "" return() endif
    valueS = AskSettingS("open_browser", "1", "Open graph in browser? 1=yes 0=no:")
    if valueS == "" return() endif

    // CMD START is a built-in command of cmd.exe, not an external program.
    // Empty quoted title is required by START; /MIN minimizes PowerShell.
    // Dos() only waits for CMD to issue START, not for the zeta calculation.
    // PowerShell resolves the INI and output files relative to its own script.
    // One script path keeps the SAL command shorter than 255 characters.
    commandS = "cmd.exe /d /c start " + Chr(34) + Chr(34) + " /min powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File " + Chr(34) + scriptS + Chr(34)
    resultI = Dos(commandS, _DONT_PROMPT_ | _RETURN_CODE_)
    // TSE Dos() returns nonzero on successful invocation and zero on failure.
    // It does NOT directly return the Windows command's exit code.
    // With _RETURN_CODE_, Windows command status is available separately
    // through DosIOResult(). Do not mistake Dos() == 1 for CMD exit code 1.
    if NOT resultI
        Warn("TSE could not invoke the PowerShell launch command.")
        return()
    endif

    Message("PowerShell launch command executed; TSE is free. Status: ",
            baseS, "riemannhypothesisgraph_status.txt")
end
