// EIGENVECTORCIRCLE 1.0.0.0.2
// TSE Pro SAL launcher for eigenvectorcircle.ps1 (Windows)
// All user input is collected by TSE Ask(), not by PowerShell.

#define EVC_H_R   71
#define EVC_H_11  72
#define EVC_H_12  73
#define EVC_H_21  74
#define EVC_H_22  75
#define EVC_H_STEP 76

proc Main()
    string folder[_MAXPATH_]
    string iniFile[_MAXPATH_]
    string psFile[_MAXPATH_]
    string radius[32]
    string a11[32]
    string a12[32]
    string a21[32]
    string a22[32]
    string stepDegrees[32]
    string args[255]

    folder = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    iniFile = folder + "eigenvectorcircle.ini"
    psFile  = folder + "eigenvectorcircle.ps1"

    if not FileExists(psFile)
        Warn("Missing PowerShell script: ", psFile)
        return()
    endif

    radius = GetProfileStr("EigenvectorCircle", "R", "1", iniFile)
    a11 = GetProfileStr("EigenvectorCircle", "a11", "2", iniFile)
    a12 = GetProfileStr("EigenvectorCircle", "a12", "1", iniFile)
    a21 = GetProfileStr("EigenvectorCircle", "a21", "1", iniFile)
    a22 = GetProfileStr("EigenvectorCircle", "a22", "2", iniFile)
    stepDegrees = GetProfileStr("EigenvectorCircle", "StepDegrees", "5", iniFile)

    if not Ask("Vector length R:", radius, EVC_H_R)
        return()
    endif
    if not Ask("Matrix a11 (row 1, column 1):", a11, EVC_H_11)
        return()
    endif
    if not Ask("Matrix a12 (row 1, column 2):", a12, EVC_H_12)
        return()
    endif
    if not Ask("Matrix a21 (row 2, column 1):", a21, EVC_H_21)
        return()
    endif
    if not Ask("Matrix a22 (row 2, column 2):", a22, EVC_H_22)
        return()
    endif

    if not Ask("Angular step in degrees:", stepDegrees, EVC_H_STEP)
        return()
    endif

    radius = Trim(radius)
    a11 = Trim(a11)
    a12 = Trim(a12)
    a21 = Trim(a21)
    a22 = Trim(a22)
    stepDegrees = Trim(stepDegrees)
    if not Length(radius) or not Length(a11) or not Length(a12) or not Length(a21) or not Length(a22) or not Length(stepDegrees)
        Warn("All six numeric inputs are required.")
        return()
    endif
    // Numerical validation is performed by the PowerShell program.
    // Store the latest values in the INI, in addition to TSE Ask history.
    WriteProfileStr("EigenvectorCircle", "R", radius, iniFile)
    WriteProfileStr("EigenvectorCircle", "a11", a11, iniFile)
    WriteProfileStr("EigenvectorCircle", "a12", a12, iniFile)
    WriteProfileStr("EigenvectorCircle", "a21", a21, iniFile)
    WriteProfileStr("EigenvectorCircle", "a22", a22, iniFile)
    WriteProfileStr("EigenvectorCircle", "StepDegrees", stepDegrees, iniFile)

    // Pass simple, quoted values; the PowerShell program receives named args.
    // Use the complete script path; no need to change TSE's directory.
    args = '-NoProfile -STA -ExecutionPolicy Bypass -File "' + psFile + '"'
    args = args + ' -Radius "' + radius + '"'
    args = args + ' -A11 "' + a11 + '"'
    args = args + ' -A12 "' + a12 + '"'
    args = args + ' -A21 "' + a21 + '"'
    args = args + ' -A22 "' + a22 + '"'
    args = args + ' -StepDegrees "' + stepDegrees + '"'

    if not StartPgm("powershell.exe", args, folder)
        Warn("Could not start Windows PowerShell. Check powershell.exe.")
    endif
end
