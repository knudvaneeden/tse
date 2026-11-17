// GIFANIM 1.0.0.0.24 - TSE SAL launcher, ASCII only.
// Resolve companion files beside the running gifanim.mac (compiled from gifanim.s).
// Dedicated histories are saved beside the macro, including across TSE restarts.
integer proc FNAskPersistent(string promptS, var string replyS, string keyS, string iniS)
    integer historyI = GetFreeHistory("GIFANIM:" + keyS)
    integer itemI
    string sectionS[80] = "History_" + keyS
    string entryS[255]
    if historyI == 0
        historyI = _EDIT_HISTORY_
    endif
    for itemI = 20 to 1 by -1
        entryS = GetProfileStr(sectionS, Str(itemI), "", iniS)
        if entryS <> ""
            AddHistoryStr(entryS, historyI)
        endif
    endfor
    if not Ask(promptS, replyS, historyI)
        return(FALSE)
    endif
    AddHistoryStr(replyS, historyI)
    for itemI = 1 to 20
        entryS = ""
        if itemI <= NumHistoryItems(historyI)
            entryS = GetHistoryStr(historyI, itemI)
        endif
        WriteProfileStr(sectionS, Str(itemI), entryS, iniS)
    endfor
    FlushProfile(iniS)
    return(TRUE)
end

proc Main()
    string macroDirS[255] = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    string packageDirS[255] = macroDirS
    string iniFileS[255] = ""
    string scriptFileS[255] = ""
    string batchFileS[255] = ""
    string runIniFileS[255] = ""
    string directoryS[255]
    string sequenceS[255]
    string outputS[255]
    string outputDirS[255]
    string currentDirS[255]
    string widthS[16]
    string heightS[16]
    string delayS[16]
    string qualityS[16]
    string commandS[255]
    string noPngFileS[255]
    string errorFileS[255]
    string errorMessageS[255]
    integer dosStartedI
    integer exitCodeI
    iniFileS = packageDirS + "gifanim.ini"
    scriptFileS = packageDirS + "gifanim.ps1"
    batchFileS = packageDirS + "gifanim.bat"
    runIniFileS = packageDirS + "gifanim_run.ini"
    if not FileExists(iniFileS) or not FileExists(scriptFileS) or not FileExists(batchFileS)
        Warn("GIFANIM: put gifanim.ini, gifanim.ps1 and gifanim.bat beside gifanim.mac.")
        return()
    endif
    directoryS = GetProfileStr("GifAnim", "directory", "", iniFileS)
    sequenceS = GetProfileStr("GifAnim", "sequence", "*.png", iniFileS)
    outputS = GetProfileStr("GifAnim", "output", "01.gif", iniFileS)
    outputDirS = GetProfileStr("GifAnim", "outputdirectory", "", iniFileS)
    delayS = GetProfileStr("GifAnim", "delay_cs", "10", iniFileS)
    widthS = GetProfileStr("GifAnim", "width", "0", iniFileS)
    heightS = GetProfileStr("GifAnim", "height", "0", iniFileS)
    qualityS = GetProfileStr("GifAnim", "quality", "sharp", iniFileS)
    if not FNAskPersistent("Numbered PNG selection (e.g. *.png):", sequenceS, "sequenceS", iniFileS)
        return()
    endif
    if not FNAskPersistent("INPUT PNG directory (blank = macro; relative = CurrDir):", directoryS, "directoryS", iniFileS)
        return()
    endif
    if not FNAskPersistent("Output GIF filename:", outputS, "outputS", iniFileS)
        return()
    endif
    if not FNAskPersistent("GIF output directory (blank = PNG; relative = CurrDir):", outputDirS, "outputDirS", iniFileS)
        return()
    endif
    if not FNAskPersistent("Delay per frame (hundredths of a second; 100 = 1 second; max 65535):", delayS, "delayS", iniFileS)
        return()
    endif
    if not FNAskPersistent("Resize quality (sharp, smooth, fast):", qualityS, "qualityS", iniFileS)
        return()
    endif
    if not FNAskPersistent("GIF width in pixels (0 = automatic):", widthS, "width", iniFileS)
        return()
    endif
    if not FNAskPersistent("GIF height in pixels (0 = automatic):", heightS, "height", iniFileS)
        return()
    endif
    if Val(widthS) < 0 or Val(widthS) > 65535 or Val(heightS) < 0 or Val(heightS) > 65535
        Warn("GIFANIM: width and height must be 0 through 65535.")
        return()
    endif
    qualityS = Lower(qualityS)
    if qualityS <> "sharp" and qualityS <> "smooth" and qualityS <> "fast"
        Warn("GIFANIM: quality must be sharp, smooth, or fast.")
        return()
    endif
    if Val(delayS) < 1 or Val(delayS) > 65535 or sequenceS == "" or outputS == ""
        Warn("GIFANIM: check delay, PNG selection, and output filename.")
        return()
    endif
    // CurrDir() is evaluated by TSE now; do not store it as an INI setting.
    currentDirS = AddTrailingSlash(CurrDir())
    if directoryS <> "" and SubStr(directoryS, 2, 1) <> ":" and LeftStr(directoryS, 1) <> "\"
        if Length(currentDirS) + Length(directoryS) > 255
            Warn("GIFANIM: resolved PNG directory exceeds TSE's string limit.")
            return()
        endif
        directoryS = currentDirS + directoryS
    endif
    if outputDirS <> "" and SubStr(outputDirS, 2, 1) <> ":" and LeftStr(outputDirS, 1) <> "\"
        if Length(currentDirS) + Length(outputDirS) > 255
            Warn("GIFANIM: resolved output directory exceeds TSE's string limit.")
            return()
        endif
        outputDirS = currentDirS + outputDirS
    endif
    // Keep the command short: pass Ask() values through a separate run INI.
    // The batch job passes only that INI filename to PowerShell.
    // Remove the key left by version 1.0.0.0.21, if present.
    RemoveProfileItem("GifAnim", "currentdirectory", runIniFileS)
    if not WriteProfileStr("GifAnim", "directory", directoryS, runIniFileS)
        Warn("GIFANIM: could not write gifanim_run.ini beside gifanim.mac.")
        return()
    endif
    if not WriteProfileStr("GifAnim", "sequence", sequenceS, runIniFileS)
        Warn("GIFANIM: could not write gifanim_run.ini beside gifanim.mac.")
        return()
    endif
    if not WriteProfileStr("GifAnim", "output", outputS, runIniFileS)
        Warn("GIFANIM: could not write gifanim_run.ini beside gifanim.mac.")
        return()
    endif
    if not WriteProfileStr("GifAnim", "outputdirectory", outputDirS, runIniFileS)
        Warn("GIFANIM: could not write gifanim_run.ini beside gifanim.mac.")
        return()
    endif
    if not WriteProfileStr("GifAnim", "delay_cs", delayS, runIniFileS)
        Warn("GIFANIM: could not write gifanim_run.ini beside gifanim.mac.")
        return()
    endif
    if not WriteProfileStr("GifAnim", "quality", qualityS, runIniFileS)
        Warn("GIFANIM: could not write gifanim_run.ini beside gifanim.mac.")
        return()
    endif
    if not WriteProfileStr("GifAnim", "width", widthS, runIniFileS)
        Warn("GIFANIM: could not write gifanim_run.ini.")
        return()
    endif
    if not WriteProfileStr("GifAnim", "height", heightS, runIniFileS)
        Warn("GIFANIM: could not write gifanim_run.ini.")
        return()
    endif
    FlushProfile(runIniFileS)
    if Length(batchFileS) + Length('cmd.exe /d /c """"') > 254
        Warn("GIFANIM: macro path is too long for the TSE command string.")
        return()
    endif
    commandS = 'cmd.exe /d /c ""' + batchFileS + '""'
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
