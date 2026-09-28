// GIFANIM 1.0.0.0.16 - TSE SAL launcher, ASCII only.
// Resolve companion files beside the running gifanim.mac (compiled from gifanim.s).
proc Main()
    string macroDirS[255] = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    string packageDirS[255] = macroDirS
    string iniFileS[255] = ""
    string scriptFileS[255] = ""
    string directoryS[255]
    string sequenceS[255]
    string outputS[255]
    string outputDirS[255]
    string delayS[16]
    string commandS[255]
    string noPngFileS[255]
    string errorFileS[255]
    string errorMessageS[255]
    integer dosStartedI
    integer exitCodeI
    iniFileS = packageDirS + "gifanim.ini"
    scriptFileS = packageDirS + "gifanim.ps1"
    if not FileExists(iniFileS) or not FileExists(scriptFileS)
        Warn("GIFANIM: put gifanim.ini and gifanim.ps1 beside gifanim.mac.")
        return()
    endif
    directoryS = GetProfileStr("GifAnim", "directory", "", iniFileS)
    sequenceS = GetProfileStr("GifAnim", "sequence", "*.png", iniFileS)
    outputS = GetProfileStr("GifAnim", "output", "01.gif", iniFileS)
    outputDirS = GetProfileStr("GifAnim", "outputdirectory", "", iniFileS)
    delayS = GetProfileStr("GifAnim", "delay_cs", "10", iniFileS)
    if not Ask("Numbered PNG selection (e.g. *.png):", sequenceS, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("INPUT directory for PNG files (blank = macro directory):", directoryS, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("Output GIF filename:", outputS, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("GIF output directory (blank = PNG directory):", outputDirS, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("Delay per frame in hundredths (1 to 100):", delayS, _EDIT_HISTORY_)
        return()
    endif
    if Val(delayS) < 1 or Val(delayS) > 100 or sequenceS == "" or outputS == ""
        Warn("GIFANIM: check delay, PNG selection, and output filename.")
        return()
    endif
    // A trailing backslash immediately before a closing quote breaks Windows
    // argument parsing. Append a dot: F:\dir\ becomes F:\dir\.
    if Length(directoryS) and RightStr(directoryS, 1) == "\"
        directoryS = directoryS + "."
    endif
    if Length(outputDirS) and RightStr(outputDirS, 1) == "\"
        outputDirS = outputDirS + "."
    endif
    // PowerShell handles empty directory as the package directory.
    // Use ordinary trusted filenames without embedded double quotes.
    commandS = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + scriptFileS + '" -FrameDirectory "' + directoryS + '" -Sequence "' + sequenceS + '" -OutputFile "' + outputS + '" -OutputDirectory "' + outputDirS + '" -DelayCs ' + delayS
    noPngFileS = packageDirS + "gifanim_no_png.flag"
    errorFileS = packageDirS + "gifanim_error.flag"
    if FileExists(noPngFileS)
        EraseDiskFile(noPngFileS)
    endif
    if FileExists(errorFileS)
        EraseDiskFile(errorFileS)
    endif
    dosStartedI = Dos(commandS, _DONT_PROMPT_ | _RETURN_CODE_)
    if dosStartedI
        exitCodeI = DosIOResult()
    endif
    if not dosStartedI
        Warn("GIFANIM: TSE could not start PowerShell (Dos returned zero).")
    elseif FileExists(noPngFileS)
        errorMessageS = GetProfileStr("GifAnimError", "message", "No numbered PNG files match the selection.", noPngFileS)
        Warn("GIFANIM: " + errorMessageS)
    elseif FileExists(errorFileS)
        errorMessageS = GetProfileStr("GifAnimError", "message", "Could not create the GIF.", errorFileS)
        Warn("GIFANIM: " + errorMessageS)
    elseif exitCodeI <> 0
        Warn("GIFANIM: PowerShell returned a nonzero exit code. Check its output.")
    else
        Warn("GIFANIM: encoding completed. Check the GIF in the output directory.")
    endif
end
