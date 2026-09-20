/*
    screenshotwindowtse.s
    Version 1.0.0.0.18
    2026-09-20

    All configuration/input handling is done in TSE SAL.
    The DLL receives the final output path, file type, and optional
    target-window title one character at a time where applicable.

    Supported types:
      png  default
      jpg  jpeg is accepted as an alias
      bmp

    Structure:
      - Main() handles INI, MacroCmdLine, and Ask().
      - Ask() order: file type, filename, directory.
      - Macro parameter 4 controls silent or not.
      - Macro parameter 5 optionally selects another window by title.
      - PROCDoScreenshotWithValues() performs the actual implementation.
*/

string GSVersion[16] = "1.0.0.0.18"

dll "screenshotwindowtse.dll"
    integer proc SWTSResetOutputPath() : "SWTSResetOutputPath"
    integer proc SWTSAddOutputChar(integer charI) : "SWTSAddOutputChar"
    integer proc SWTSSetFileType(integer fileTypeI) : "SWTSSetFileType"
    integer proc SWTSResetWindowTitle() : "SWTSResetWindowTitle"
    integer proc SWTSAddWindowTitleChar(integer charI) : "SWTSAddWindowTitleChar"
    integer proc SWTSCaptureWindow() : "SWTSCaptureWindow"
end

string proc FNNormalizeFileTypeS(string fileTypeInS)
    string fileTypeS[8] = ""

    fileTypeS = Lower(Trim(fileTypeInS))

    if Length(fileTypeS) > 0
        if fileTypeS[1] == "."
            fileTypeS = SubStr(fileTypeS, 2, Length(fileTypeS) - 1)
        endif
    endif

    if fileTypeS == "jpeg"
        fileTypeS = "jpg"
    endif

    if (fileTypeS <> "png") and (fileTypeS <> "jpg") and (fileTypeS <> "bmp")
        fileTypeS = "png"
    endif

    return(fileTypeS)
end

integer proc FNShowFinalResultB(string valueInS)
    string valueS[16] = ""

    valueS = Lower(Trim(valueInS))

    if (valueS == "false") or (valueS == "no") or (valueS == "0") or (valueS == "off") or (valueS == "silent")
        return(FALSE)
    endif

    if (valueS == "true") or (valueS == "yes") or (valueS == "1") or (valueS == "on") or (valueS == "nosilent")
        return(TRUE)
    endif

    return(TRUE)
end

string proc FNStripOuterQuotesS(string valueInS)
    string valueS[255] = ""
    integer lenI = 0
    integer firstI = 0
    integer lastI = 0

    valueS = Trim(valueInS)
    lenI = Length(valueS)

    if lenI >= 2
        firstI = Asc(valueS[1])
        lastI = Asc(valueS[lenI])

        if ((firstI == 34) and (lastI == 34)) or ((firstI == 39) and (lastI == 39))
            valueS = SubStr(valueS, 2, lenI - 2)
        endif
    endif

    return(Trim(valueS))
end

string proc FNMacroDirectoryS()
    return(SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_))
end

string proc FNDefaultFilenameS(string fileTypeS)
    integer monthI = 0
    integer dayI = 0
    integer yearI = 0
    integer dowI = 0
    integer hourI = 0
    integer minuteI = 0
    integer secondI = 0
    string timeS[20] = ""
    string amPmS[2] = ""
    string resultS[255] = ""

    GetDate(monthI, dayI, yearI, dowI)
    timeS = Upper(Trim(GetTimeStr()))

    hourI = Val(GetToken(timeS, ":", 1))
    minuteI = Val(GetToken(timeS, ":", 2))

    if Pos(":", timeS) > 0
        secondI = Val(GetToken(timeS, ":", 3))
    endif

    if Pos("AM", timeS) > 0
        amPmS = "AM"
    elseif Pos("PM", timeS) > 0
        amPmS = "PM"
    endif

    if amPmS == "AM"
        if hourI == 12
            hourI = 0
        endif
    elseif amPmS == "PM"
        if hourI < 12
            hourI = hourI + 12
        endif
    endif

    resultS = "screenshotwindowtse_" +
              Format(yearI:4:"0") +
              Format(monthI:2:"0") +
              Format(dayI:2:"0") + "_" +
              Format(hourI:2:"0") +
              Format(minuteI:2:"0") +
              Format(secondI:2:"0") + "." + fileTypeS

    return(resultS)
end

string proc FNApplyFileTypeS(string filenameInS, string fileTypeInS)
    string filenameS[255] = ""
    string fileTypeS[8] = ""
    string lowerS[255] = ""
    integer lenI = 0

    filenameS = Trim(filenameInS)
    fileTypeS = FNNormalizeFileTypeS(fileTypeInS)
    lowerS = Lower(filenameS)
    lenI = Length(lowerS)

    if lenI >= 5
        if SubStr(lowerS, lenI - 4, 5) == ".jpeg"
            filenameS = SubStr(filenameS, 1, lenI - 5)
            lenI = Length(filenameS)
            lowerS = Lower(filenameS)
        endif
    endif

    if lenI >= 4
        if (SubStr(lowerS, lenI - 3, 4) == ".png") or
           (SubStr(lowerS, lenI - 3, 4) == ".jpg") or
           (SubStr(lowerS, lenI - 3, 4) == ".bmp")
            filenameS = SubStr(filenameS, 1, lenI - 4)
        endif
    endif

    return(filenameS + "." + fileTypeS)
end

string proc FNResolveDirectoryS(string directoryInS, string macroDirS)
    string directoryS[255] = ""

    directoryS = Trim(directoryInS)

    if Length(directoryS) == 0
        directoryS = macroDirS + "screenshots"
    elseif (Pos(":", directoryS) == 0) and (directoryS[1] <> "\")
        directoryS = macroDirS + directoryS
    endif

    while (Length(directoryS) > 3) and (directoryS[Length(directoryS)] == "\")
        directoryS = SubStr(directoryS, 1, Length(directoryS) - 1)
    endwhile

    return(directoryS)
end

integer proc FNFileTypeToIntegerI(string fileTypeInS)
    string fileTypeS[8] = ""

    fileTypeS = FNNormalizeFileTypeS(fileTypeInS)

    if fileTypeS == "bmp"
        return(2)
    elseif fileTypeS == "jpg"
        return(3)
    endif

    return(1)
end

proc PROCCreateDirectory(string directoryS)
    string commandS[255] = ""

    commandS = 'if not exist "' + directoryS + '" mkdir "' + directoryS + '"'
    Dos(commandS, _DONT_PROMPT_)
end

integer proc FNSendOutputPathB(string fullPathS)
    integer I = 0

    if SWTSResetOutputPath() <> 1
        return(FALSE)
    endif

    for I = 1 to Length(fullPathS)
        if SWTSAddOutputChar(Asc(fullPathS[I])) <> 1
            return(FALSE)
        endif
    endfor

    return(TRUE)
end

integer proc FNSendWindowTitleB(string windowTitleS)
    integer I = 0

    if SWTSResetWindowTitle() <> 1
        return(FALSE)
    endif

    for I = 1 to Length(windowTitleS)
        if SWTSAddWindowTitleChar(Asc(windowTitleS[I])) <> 1
            return(FALSE)
        endif
    endfor

    return(TRUE)
end

proc PROCShowFinalResult(integer resultI, string fullPathS, integer showFinalResultB)
    if not showFinalResultB
        return()
    endif

    if resultI == 1
        Warn("Screenshot saved: "; fullPathS; ". screenshotwindowtse version "; GSVersion; " - GPT-5.6 Sol")
    elseif resultI == -1
        Warn("Screenshot failed: no foreground window. screenshotwindowtse version "; GSVersion; " - GPT-5.6 Sol")
    elseif resultI == -2
        Warn("Screenshot failed: cannot determine window rectangle. screenshotwindowtse version "; GSVersion; " - GPT-5.6 Sol")
    elseif resultI == -3
        Warn("Screenshot failed: capture/GDI failure. screenshotwindowtse version "; GSVersion; " - GPT-5.6 Sol")
    elseif resultI == -4
        Warn("Screenshot failed: cannot create output file. screenshotwindowtse version "; GSVersion; " - GPT-5.6 Sol")
    elseif resultI == -5
        Warn("Screenshot failed: image encoding failed. screenshotwindowtse version "; GSVersion; " - GPT-5.6 Sol")
    elseif resultI == -6
        Warn("Screenshot failed: target window title not found. screenshotwindowtse version "; GSVersion; " - GPT-5.6 Sol")
    elseif resultI == -100
        Warn("Cannot set screenshot type. screenshotwindowtse version "; GSVersion; " - GPT-5.6 Sol")
    elseif resultI == -101
        Warn("Cannot pass screenshot pathname to DLL. screenshotwindowtse version "; GSVersion; " - GPT-5.6 Sol")
    elseif resultI == -102
        Warn("Cannot pass target window title to DLL. screenshotwindowtse version "; GSVersion; " - GPT-5.6 Sol")
    else
        Warn("Screenshot failed. Error code "; resultI; ". screenshotwindowtse version "; GSVersion; " - GPT-5.6 Sol")
    endif
end

proc PROCDoScreenshotWithValues(string filenameS, string directoryS, string fileTypeS, integer showFinalResultB, string windowTitleS)
    string macroDirS[255] = ""
    string localFileTypeS[8] = ""
    string localFilenameS[255] = ""
    string localDirectoryS[255] = ""
    string localWindowTitleS[255] = ""
    string fullPathS[255] = ""
    integer fileTypeI = 1
    integer resultI = 0

    macroDirS = FNMacroDirectoryS()
    localFileTypeS = FNNormalizeFileTypeS(fileTypeS)
    localDirectoryS = FNResolveDirectoryS(directoryS, macroDirS)
    localFilenameS = Trim(filenameS)
    localWindowTitleS = FNStripOuterQuotesS(windowTitleS)

    if Length(localFilenameS) == 0
        localFilenameS = FNDefaultFilenameS(localFileTypeS)
    else
        localFilenameS = FNApplyFileTypeS(localFilenameS, localFileTypeS)
    endif

    PROCCreateDirectory(localDirectoryS)

    fullPathS = localDirectoryS + "\" + localFilenameS
    fileTypeI = FNFileTypeToIntegerI(localFileTypeS)

    if SWTSSetFileType(fileTypeI) <> 1
        PROCShowFinalResult(-100, fullPathS, showFinalResultB)
        return()
    endif

    if not FNSendOutputPathB(fullPathS)
        PROCShowFinalResult(-101, fullPathS, showFinalResultB)
        return()
    endif

    if not FNSendWindowTitleB(localWindowTitleS)
        PROCShowFinalResult(-102, fullPathS, showFinalResultB)
        return()
    endif

    resultI = SWTSCaptureWindow()
    PROCShowFinalResult(resultI, fullPathS, showFinalResultB)
end

proc Main()
    string macroDirS[255] = ""
    string iniFileS[255] = ""
    string fileTypeS[8] = ""
    string filenameS[255] = ""
    string directoryS[255] = ""
    string windowTitleS[255] = ""
    string cmdLineS[255] = ""
    string paramFilenameS[255] = ""
    string paramDirectoryS[255] = ""
    string paramFileTypeS[8] = ""
    string paramSilentS[16] = ""
    string paramWindowTitleS[255] = ""
    integer showFinalResultB = TRUE

    macroDirS = FNMacroDirectoryS()
    iniFileS = macroDirS + "screenshotwindowtse.ini"

    fileTypeS = FNNormalizeFileTypeS(GetProfileStr("Save", "filetype", "png", iniFileS))
    directoryS = FNResolveDirectoryS(GetProfileStr("Save", "directory", "screenshots", iniFileS), macroDirS)
    filenameS = GetProfileStr("Save", "filename", "", iniFileS)
    showFinalResultB = FNShowFinalResultB(GetProfileStr("Save", "showfinalresult", "true", iniFileS))
    windowTitleS = FNStripOuterQuotesS(GetProfileStr("Save", "windowtitle", "", iniFileS))

    cmdLineS = Trim(Query(MacroCmdLine))

    if Length(cmdLineS) > 0
        paramFilenameS = Trim(GetToken(cmdLineS, "|", 1))
        paramDirectoryS = Trim(GetToken(cmdLineS, "|", 2))
        paramFileTypeS = Trim(GetToken(cmdLineS, "|", 3))
        paramSilentS = Trim(GetToken(cmdLineS, "|", 4))
        paramWindowTitleS = FNStripOuterQuotesS(GetToken(cmdLineS, "|", 5))
    endif

    if Length(paramSilentS) > 0
        showFinalResultB = FNShowFinalResultB(paramSilentS)
    endif

    if Length(paramWindowTitleS) > 0
        windowTitleS = paramWindowTitleS
    endif

    if Length(paramFileTypeS) > 0
        fileTypeS = FNNormalizeFileTypeS(paramFileTypeS)
    else
        if not Ask("Screenshot file type (png/jpg/bmp):", fileTypeS, _EDIT_HISTORY_)
            return()
        endif
        fileTypeS = FNNormalizeFileTypeS(fileTypeS)
    endif

    if Length(Trim(filenameS)) == 0
        filenameS = FNDefaultFilenameS(fileTypeS)
    else
        filenameS = FNApplyFileTypeS(filenameS, fileTypeS)
    endif

    if Length(paramFilenameS) > 0
        filenameS = FNApplyFileTypeS(paramFilenameS, fileTypeS)
    else
        if not Ask("Screenshot filename:", filenameS, _EDIT_HISTORY_)
            return()
        endif
        if Length(Trim(filenameS)) == 0
            return()
        endif
        filenameS = FNApplyFileTypeS(filenameS, fileTypeS)
    endif

    if Length(paramDirectoryS) > 0
        directoryS = FNResolveDirectoryS(paramDirectoryS, macroDirS)
    else
        if not Ask("Screenshot directory:", directoryS, _EDIT_HISTORY_)
            return()
        endif
        if Length(Trim(directoryS)) == 0
            return()
        endif
        directoryS = FNResolveDirectoryS(directoryS, macroDirS)
    endif

    if Length(paramWindowTitleS) > 0
        windowTitleS = paramWindowTitleS
    else
        if not Ask("Window title to capture (empty = current foreground window):", windowTitleS, _EDIT_HISTORY_)
            return()
        endif
        windowTitleS = FNStripOuterQuotesS(windowTitleS)
    endif

    PROCDoScreenshotWithValues(filenameS, directoryS, fileTypeS, showFinalResultB, windowTitleS)
end
