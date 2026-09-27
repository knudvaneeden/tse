// GIFANIM 1.0.0.0.9 - TSE SAL launcher, ASCII only.
// First try GIFANIM under the working directory, then beside the compiled macro.
proc Main()
    string macroDirS[255] = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    string packageDirS[255] = "GIFANIM\"
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
    if not FileExists(packageDirS + "gifanim.ini") or not FileExists(packageDirS + "gifanim.ps1")
        packageDirS = macroDirS
    endif
    iniFileS = packageDirS + "gifanim.ini"
    scriptFileS = packageDirS + "gifanim.ps1"
    if not FileExists(iniFileS) or not FileExists(scriptFileS)
        Warn("GIFANIM: gifanim.ini and gifanim.ps1 were not found together.")
        return()
    endif
    directoryS = GetProfileStr("GifAnim", "directory", "", iniFileS)
    sequenceS = GetProfileStr("GifAnim", "sequence", "*.png", iniFileS)
    outputS = GetProfileStr("GifAnim", "output", "01.gif", iniFileS)
    outputDirS = GetProfileStr("GifAnim", "outputdirectory", "", iniFileS)
    delayS = GetProfileStr("GifAnim", "delay_cs", "10", iniFileS)
    if not Ask("PNG directory (blank = package directory):", directoryS, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("Numbered PNG selection (e.g. *.png):", sequenceS, _EDIT_HISTORY_)
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
    Dos(commandS, _DONT_PROMPT_)
    if FileExists(noPngFileS)
        Warn("GIFANIM: No numbered PNG files match the selection in the PNG directory.")
    elseif FileExists(errorFileS)
        Warn("GIFANIM: Could not create the GIF. Check PowerShell error output.")
    else
        Warn("GIFANIM: encoding completed. Check the GIF in the output directory.")
    endif
end
