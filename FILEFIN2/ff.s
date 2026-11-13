// FILEFIN2 - recursive Win32 file finder for TSE Pro
// Version : 1.0.0.0.44
// Date    : 2026-11-13
// LLM     : OpenAI Codex
//
// TSE 4.50 / Windows 11 port using ff.dll and zip.dll.

string cTmpLine[255]
string fileInput[255]
string directoryInput[255]
string startPath[255]
string fileToFind[255]
string searchArchiveInput[15]
string file_date[8]
string file_time[8]
integer lLookInZip = TRUE
integer origId
integer resultCount = 0
integer firstResultLineI = 0
integer resultHighlightActiveB = FALSE
integer searchStartTicksI = 0
integer searchElapsedTicksI = 0
integer iniWarningCountI = 0
string iniWarningsS[255] = ""
integer createLogB = FALSE
integer logHandleI = -1
string logPathS[255] = ""
string logDirectoryS[255] = ""

string proc FNElapsedText(integer ticksI)
    integer hoursI = ticksI / 360000
    integer remainderI = ticksI mod 360000
    integer minutesI = remainderI / 6000
    integer secondsI = (remainderI mod 6000) / 100
    integer hundredthsI = ticksI mod 100

    return(Format(hoursI:2:'0', ":", minutesI:2:'0', ":",
                  secondsI:2:'0', ".", hundredthsI:2:'0'))
end

dll "ff.dll"
    integer proc FF_TreeOpen(string directoryS, string maskS,
                             integer includeZipI, var string stateS)
    integer proc FF_TreeNext(var string stateS)
    integer proc FF_TreeMatches(string stateS)
    integer proc FF_TreeIsZip(string stateS)
    integer proc FF_TreeGetPath(string stateS, var string pathS)
    integer proc FF_TreeGetSize(string stateS)
    integer proc FF_TreeGetDate(string stateS, var string dateS)
    integer proc FF_TreeGetTime(string stateS, var string timeS)
    integer proc FF_TreeClose(var string stateS)
end

string proc FNLogStamp()
    integer monthI = 0
    integer dayI = 0
    integer yearI = 0
    integer dayOfWeekI = 0
    integer hourI = 0
    integer minuteI = 0
    integer secondI = 0
    integer hundredthI = 0

    GetDate(monthI, dayI, yearI, dayOfWeekI)
    GetTime(hourI, minuteI, secondI, hundredthI)
    return(Format(yearI:4:'0', monthI:2:'0', dayI:2:'0',
                  hourI:2:'0', minuteI:2:'0', secondI:2:'0'))
end

proc PROCLog(string messageS)
    if (logHandleI <> -1)
        fWrite(logHandleI, messageS + Chr(13) + Chr(10))
    endif
end

string proc FNDirectoryWithSlash(string directoryS)
    integer lengthI = Length(directoryS)

    if (lengthI and (directoryS[lengthI] <> Chr(92)) and
        (directoryS[lengthI] <> "/"))
        return(directoryS + Chr(92))
    endif
    return(directoryS)
end

integer proc FNTryOpenLog(string directoryS, string fileNameS)
    logPathS = FNDirectoryWithSlash(directoryS) + fileNameS
    logHandleI = fCreate(logPathS)
    return(logHandleI <> -1)
end

proc PROCOpenLog()
    string macroDirectoryS[255] = ""
    string requestedDirectoryS[255] = ""
    string fileNameS[45] = ""

    logHandleI = -1
    logPathS = ""
    if (not createLogB)
        return()
    endif
    macroDirectoryS = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_)
    fileNameS = "filefin2_" + FNLogStamp() + ".log"

    if (Length(logDirectoryS))
        requestedDirectoryS = logDirectoryS
        if (not (((Length(requestedDirectoryS) >= 2) and
                  (requestedDirectoryS[2] == ":")) or
                 ((Length(requestedDirectoryS) >= 2) and
                  (requestedDirectoryS[1] == Chr(92)) and
                  (requestedDirectoryS[2] == Chr(92)))))
            requestedDirectoryS = macroDirectoryS + requestedDirectoryS
        endif
        if (FNTryOpenLog(requestedDirectoryS, fileNameS))
            return()
        endif
    endif
    if (FNTryOpenLog(macroDirectoryS, fileNameS))
        return()
    endif
    if (FNTryOpenLog(CurrDir(), fileNameS))
        return()
    endif
    Warn(Format("FILEFIN2 could not create its log in the configured, macro, ",
                "or current directory."))
    logPathS = ""
end

proc PROCCloseLog()
    if (logHandleI <> -1)
        fClose(logHandleI)
        logHandleI = -1
    endif
end

proc PROCAddIniWarning(integer lineI, string warningS)
    string entryS[255] = ""

    iniWarningCountI = iniWarningCountI + 1
    entryS = Format("Line ", lineI, ": ", warningS)
    if (Length(iniWarningsS) + Length(entryS) < 220)
        if (Length(iniWarningsS))
            iniWarningsS = iniWarningsS + " | "
        endif
        iniWarningsS = iniWarningsS + entryS
    endif
end

proc PROCLoadIniDefaults(string iniFilenameS)
    integer oldBufferI = GetBufferId()
    integer iniBufferI = 0
    integer lineI = 1
    integer linesI = 0
    integer separatorI = 0
    string lineS[255] = ""
    string keyS[40] = ""
    string valueS[255] = ""
    string sectionS[40] = ""
    integer seenFilenameB = FALSE
    integer seenTopDirectoriesB = FALSE
    integer seenSearchArchivesB = FALSE
    integer seenSevenZipB = FALSE
    integer seenRarB = FALSE
    integer seenCreateLogB = FALSE
    integer seenLogDirectoryB = FALSE

    iniWarningCountI = 0
    iniWarningsS = ""

    if (not FileExists(iniFilenameS))
        return()
    endif

    iniBufferI = CreateTempBuffer()
    if (not iniBufferI)
        return()
    endif
    GotoBufferId(iniBufferI)
    if (not InsertFile(iniFilenameS, _DONT_PROMPT_))
        AbandonFile(iniBufferI)
        GotoBufferId(oldBufferI)
        return()
    endif

    linesI = NumLines()
    while (lineI <= linesI)
        GotoBufferId(iniBufferI)
        GotoLine(lineI)
        lineS = Trim(GetText(1, 255))
        if ((Length(lineS) > 1) and (lineS[1] == "[") and
            (lineS[Length(lineS)] == "]"))
            sectionS = Lower(Trim(SubStr(lineS, 2,
                                         Length(lineS) - 2)))
            if ((sectionS <> "searchdefaults") and
                (sectionS <> "archivetools") and
                (sectionS <> "logging"))
                PROCAddIniWarning(lineI, Format("unknown section [",
                                                sectionS, "]"))
            endif
        elseif (Length(lineS) and (lineS[1] <> ";"))
            separatorI = Pos("=", lineS)
            if (not separatorI)
                PROCAddIniWarning(lineI, "missing '='")
            elseif (separatorI == 1)
                PROCAddIniWarning(lineI, "empty parameter name")
            else
                keyS = Lower(Trim(SubStr(lineS, 1, separatorI - 1)))
                valueS = ""
                if (separatorI < Length(lineS))
                    valueS = Trim(SubStr(lineS, separatorI + 1,
                                         Length(lineS) - separatorI))
                endif
                if (not Length(keyS))
                    PROCAddIniWarning(lineI, "empty parameter name")
                elseif (keyS == "filename")
                    if (sectionS <> "searchdefaults")
                        PROCAddIniWarning(lineI,
                            "filename is outside [SearchDefaults]")
                    elseif (seenFilenameB)
                        PROCAddIniWarning(lineI, "duplicate filename")
                    elseif (Length(valueS))
                        fileInput = valueS
                    endif
                    if (sectionS == "searchdefaults")
                        seenFilenameB = TRUE
                    endif
                elseif (keyS == "topdirectories")
                    if (sectionS <> "searchdefaults")
                        PROCAddIniWarning(lineI,
                            "topdirectories is outside [SearchDefaults]")
                    elseif (seenTopDirectoriesB)
                        PROCAddIniWarning(lineI, "duplicate topdirectories")
                    elseif (Length(valueS))
                        directoryInput = valueS
                    endif
                    if (sectionS == "searchdefaults")
                        seenTopDirectoriesB = TRUE
                    endif
                elseif (keyS == "searcharchives")
                    if (sectionS <> "searchdefaults")
                        PROCAddIniWarning(lineI,
                            "searcharchives is outside [SearchDefaults]")
                    elseif (seenSearchArchivesB)
                        PROCAddIniWarning(lineI, "duplicate searcharchives")
                    elseif ((Lower(valueS) == "yes") or
                            (Lower(valueS) == "y") or
                            (Lower(valueS) == "no") or
                            (Lower(valueS) == "n"))
                        searchArchiveInput = Lower(valueS)
                    elseif (Length(valueS))
                        PROCAddIniWarning(lineI,
                                          "invalid searcharchives value")
                    endif
                    if (sectionS == "searchdefaults")
                        seenSearchArchivesB = TRUE
                    endif
                elseif (keyS == "sevenzipexecutable")
                    if (sectionS <> "archivetools")
                        PROCAddIniWarning(lineI,
                            "SevenZipExecutable is outside [ArchiveTools]")
                    elseif (seenSevenZipB)
                        PROCAddIniWarning(lineI,
                                          "duplicate SevenZipExecutable")
                    else
                        seenSevenZipB = TRUE
                    endif
                elseif (keyS == "rarexecutable")
                    if (sectionS <> "archivetools")
                        PROCAddIniWarning(lineI,
                            "RarExecutable is outside [ArchiveTools]")
                    elseif (seenRarB)
                        PROCAddIniWarning(lineI,
                                          "duplicate RarExecutable")
                    else
                        seenRarB = TRUE
                    endif
                elseif (keyS == "createlog")
                    if (sectionS <> "logging")
                        PROCAddIniWarning(lineI,
                            "CreateLog is outside [Logging]")
                    elseif (seenCreateLogB)
                        PROCAddIniWarning(lineI, "duplicate CreateLog")
                    else
                        valueS = Lower(valueS)
                        if ((valueS == "true") or (valueS == "yes") or
                            (valueS == "1") or (valueS == "on"))
                            createLogB = TRUE
                        elseif ((valueS == "false") or (valueS == "no") or
                                (valueS == "0") or (valueS == "off") or
                                (not Length(valueS)))
                            createLogB = FALSE
                        else
                            PROCAddIniWarning(lineI,
                                              "invalid CreateLog value")
                        endif
                    endif
                    if (sectionS == "logging")
                        seenCreateLogB = TRUE
                    endif
                elseif (keyS == "logdirectory")
                    if (sectionS <> "logging")
                        PROCAddIniWarning(lineI,
                            "LogDirectory is outside [Logging]")
                    elseif (seenLogDirectoryB)
                        PROCAddIniWarning(lineI, "duplicate LogDirectory")
                    else
                        logDirectoryS = valueS
                    endif
                    if (sectionS == "logging")
                        seenLogDirectoryB = TRUE
                    endif
                elseif (keyS == "opdirectory")
                    PROCAddIniWarning(lineI,
                        "unknown 'opdirectory'; use 'topdirectories'")
                elseif (keyS == "topdirectory")
                    PROCAddIniWarning(lineI,
                        "unknown 'topdirectory'; use 'topdirectories'")
                elseif (keyS == "searcharchive")
                    PROCAddIniWarning(lineI,
                        "unknown 'searcharchive'; use 'searcharchives'")
                else
                    PROCAddIniWarning(lineI, Format("unknown parameter '",
                                                    keyS, "'"))
                endif
            endif
        endif
        lineI = lineI + 1
    endwhile
    GotoBufferId(iniBufferI)
    AbandonFile(iniBufferI)
    GotoBufferId(oldBufferI)
end

dll "zip.dll"
    integer proc ZIP_Open(string pathS, var string stateS)
    integer proc ZIP_Next(var string stateS)
    integer proc ZIP_GetName(string stateS, var string nameS)
    integer proc ZIP_GetSize(string stateS)
    integer proc ZIP_NameMatches(string stateS, string patternS)
    integer proc ZIP_GetDate(string stateS, var string dateS)
    integer proc ZIP_GetTime(string stateS, var string timeS)
    integer proc ZIP_Close(var string stateS)
end

proc PROCSetZip(integer setI)
    lLookInZip = setI
end

// Results-only display highlighting. The highlighted text is the filename
// that was actually found, rather than the wildcard entered by the user.
proc PROCDrawResultLine(integer isCursorLineB)
    string fullTextS[255] = ""
    string visibleS[255] = ""
    string runS[255] = ""
    integer horizontalI = CurrXoffset() + 1
    integer delimiterI = 0
    integer nameStartI = 0
    integer nameEndI = 0
    integer indexI = 0
    integer positionI = 0
    integer oldAttrI = Query(Attr)
    integer wantedAttrI = Query(TextAttr)
    integer runAttrI = -1

    if ((GetBufferId() <> origId) or (not origId))
        return()
    endif
    fullTextS = GetText(1, 255)
    visibleS = GetText(horizontalI, Query(WindowCols))
    if ((CurrLine() >= firstResultLineI) and
        (CurrLine() < firstResultLineI + resultCount))
        delimiterI = Pos("  <-  ", fullTextS)
        if (delimiterI)
            nameEndI = delimiterI - 1
        else
            nameEndI = Length(fullTextS)
        endif
        nameStartI = 33
        for indexI = 33 to nameEndI
            if ((SubStr(fullTextS, indexI, 1) == Chr(92)) or
                (SubStr(fullTextS, indexI, 1) == "/"))
                nameStartI = indexI + 1
            endif
        endfor
    endif
    for indexI = 1 to Length(visibleS)
        positionI = horizontalI + indexI - 1
        wantedAttrI = Query(TextAttr)
        if ((positionI >= nameStartI) and (positionI <= nameEndI) and
            (nameStartI > 0))
            wantedAttrI = Query(HiLiteAttr)
        elseif (isCursorLineB)
            wantedAttrI = Query(CursorAttr)
        endif
        if (runAttrI <> wantedAttrI)
            if (Length(runS))
                Set(Attr, runAttrI)
                PutStr(runS)
            endif
            runS = ""
            runAttrI = wantedAttrI
        endif
        runS = runS + SubStr(visibleS, indexI, 1)
    endfor
    if (Length(runS))
        Set(Attr, runAttrI)
        PutStr(runS)
    endif
    // As in GREPZIPTSE, paint through the end of every screen row. This
    // removes remnants of a previously longer result line.
    Set(Attr, Query(TextAttr))
    ClrEol()
    Set(Attr, oldAttrI)
end

proc PROCDisplayBegin()
end
proc PROCDisplayEnd()
end
proc PROCHighlightNativeFound()
    HiLiteFoundText()
end

proc PROCStartResultHighlight()
    if ((not resultHighlightActiveB) and (GetBufferId() == origId))
        HookDisplay(PROCDrawResultLine, PROCDisplayBegin,
                    PROCDisplayEnd, PROCHighlightNativeFound)
        resultHighlightActiveB = TRUE
    endif
end

proc PROCStopResultHighlight()
    if (resultHighlightActiveB)
        UnHookDisplay()
        resultHighlightActiveB = FALSE
    endif
end

forward proc PROCResultLeftClick()
forward proc PROCGoToResults()

keydef FILEFIN2ResultKeys
    <LeftBtn> PROCResultLeftClick()
end

keydef FILEFIN2SourceKeys
    <RightBtn> PROCGoToResults()
    <CtrlAlt G> PROCGoToResults()
end

menu ZipSearch()
    history
    "Search Archive Files?", , Divide
    "&Yes", PROCSetZip(TRUE)
    "&No",  PROCSetZip(FALSE)
end

proc PROCSetFileMask(string inputS)
    string normalizedS[255] = ""
    integer indexI = 1
    integer lengthI = Length(inputS)

    repeat
        if (Asc(inputS[indexI]) <> 34)
            normalizedS = normalizedS + inputS[indexI]
        endif
        indexI = indexI + 1
    until (indexI > lengthI)

    fileToFind = normalizedS
end

proc PROCSetStartPath(string inputS)
    string normalizedS[255] = ""
    integer indexI = 1
    integer lengthI = Length(inputS)

    repeat
        if (Asc(inputS[indexI]) <> 34)
            if (inputS[indexI] == "/")
                normalizedS = normalizedS + "\"
            else
                normalizedS = normalizedS + inputS[indexI]
            endif
        endif
        indexI = indexI + 1
    until (indexI > lengthI)

    if (Length(normalizedS))
        if (normalizedS[Length(normalizedS)] <> "\")
            normalizedS = normalizedS + "\"
        endif
    endif

    startPath = normalizedS
end

proc PROCZipLook(string pathS)
    string stateS[15] = ""
    string nameS[255] = ""
    string dateS[8] = ""
    string timeS[8] = ""
    integer sizeI = 0

    if (ZIP_Open(pathS, stateS))
        while (ZIP_Next(stateS))
            if (ZIP_NameMatches(stateS, fileToFind))
                nameS = ""
                dateS = ""
                timeS = ""
                ZIP_GetName(stateS, nameS)
                ZIP_GetDate(stateS, dateS)
                ZIP_GetTime(stateS, timeS)
                sizeI = ZIP_GetSize(stateS)
                cTmpLine = Format(sizeI:10, "  ", dateS, "  ",
                                  timeS, "  ", nameS, "  <-  ", pathS)
                AddLine(cTmpLine, origId)
                PROCLog(Format("MATCH ", cTmpLine))
                resultCount = resultCount + 1
            endif
        endwhile
        ZIP_Close(stateS)
    endif
end

proc PROCSearchTree()
    string stateS[15] = ""
    string pathS[255] = ""

    if (FF_TreeOpen(startPath, fileToFind, lLookInZip, stateS))
        while (FF_TreeNext(stateS))
            pathS = ""
            FF_TreeGetPath(stateS, pathS)

            if (lLookInZip and FF_TreeIsZip(stateS))
                Message(Format("Scanning archive: ", pathS))
                // Refresh before a potentially long archive operation.
                UpdateDisplay(_DEFAULT_)
            else
                Message(pathS)
            endif

            if (FF_TreeMatches(stateS))
                file_date = ""
                file_time = ""
                FF_TreeGetDate(stateS, file_date)
                FF_TreeGetTime(stateS, file_time)
                cTmpLine = Format(FF_TreeGetSize(stateS):10, "  ",
                                  file_date, "  ", file_time, "  ",
                                  pathS)
                AddLine(cTmpLine, origId)
                PROCLog(Format("MATCH ", cTmpLine))
                resultCount = resultCount + 1
            endif

            if (lLookInZip and FF_TreeIsZip(stateS))
                PROCZipLook(pathS)
            endif
        endwhile
        FF_TreeClose(stateS)
    endif
end

proc PROCSearchDirectoryList(string inputS)
    string directoryS[255] = ""
    integer indexI = 1
    integer lengthI = Length(inputS)

    while (indexI <= lengthI)
        if (inputS[indexI] == ";")
            directoryS = Trim(directoryS)
            if (Length(directoryS))
                PROCSetStartPath(directoryS)
                if (Length(startPath))
                    PROCSearchTree()
                endif
            endif
            directoryS = ""
        else
            directoryS = directoryS + inputS[indexI]
        endif
        indexI = indexI + 1
    endwhile

    directoryS = Trim(directoryS)
    if (Length(directoryS))
        PROCSetStartPath(directoryS)
        if (Length(startPath))
            PROCSearchTree()
        endif
    endif
end

proc PROCGoToResults()
    if (origId)
        PROCStopResultHighlight()
        if (GotoBufferId(origId))
            Disable(FILEFIN2SourceKeys)
            Enable(FILEFIN2ResultKeys)
            UpdateDisplay(_DEFAULT_)
            PROCStartResultHighlight()
        endif
    else
        Warn("No FILEFIN2 results are available.")
    endif
end


proc PROCResultLeftClick()
    if (GetBufferId() == origId)
        // Allow the user's existing result-click command to run. Unhook the
        // result-only renderer first, then make right-click available for
        // returning from whichever buffer that command opens.
        PROCStopResultHighlight()
        Disable(FILEFIN2ResultKeys)
        Enable(FILEFIN2SourceKeys)
        ChainCmd()
    else
        ChainCmd()
    endif
end

proc Main()
    string iniFilenameS[255] = ""
    integer filenameHistoryI = 0
    integer topDirectoriesHistoryI = 0
    string historyValueS[255] = ""

    // Built-in ff.s defaults. Blank INI values do not replace them.
    fileInput = ""
    directoryInput = ""
    searchArchiveInput = ""
    createLogB = FALSE
    logDirectoryS = ""
    PROCStopResultHighlight()
    Disable(FILEFIN2ResultKeys)
    Disable(FILEFIN2SourceKeys)
    PROCCloseLog()
    iniFilenameS = SplitPath(CurrMacroFileName(), _DRIVE_|_PATH_) +
                   "filefin2.ini"
    PROCLoadIniDefaults(iniFilenameS)
    if (iniWarningCountI)
        Warn(Format("FILEFIN2.INI has ", iniWarningCountI,
                    " warning(s): ", iniWarningsS))
    endif

    filenameHistoryI = GetFreeHistory("FILEFIN2:filename")
    topDirectoriesHistoryI = GetFreeHistory("FILEFIN2:topdirectories")
    if ((not filenameHistoryI) or (not topDirectoriesHistoryI))
        Warn("FILEFIN2 could not allocate its dedicated input histories.")
        return()
    endif
    // Seed empty histories from the INI once. The newest accepted Ask() value
    // then always has priority over the INI default.
    if ((NumHistoryItems(filenameHistoryI) == 0) and Length(fileInput))
        AddHistoryStr(fileInput, filenameHistoryI)
    endif
    if ((NumHistoryItems(topDirectoriesHistoryI) == 0) and
        Length(directoryInput))
        AddHistoryStr(directoryInput, topDirectoriesHistoryI)
    endif
    historyValueS = GetHistoryStr(filenameHistoryI, 1)
    if (Length(historyValueS))
        fileInput = historyValueS
    endif
    historyValueS = GetHistoryStr(topDirectoriesHistoryI, 1)
    if (Length(historyValueS))
        directoryInput = historyValueS
    endif

    if (not Ask("Enter filename or file mask (*, .*, ?):", fileInput,
                filenameHistoryI))
        return()
    endif
    if (not Length(fileInput))
        return()
    endif
    if (not Ask("Enter top directories (; separated):", directoryInput,
                topDirectoriesHistoryI))
        return()
    endif
    if (not Length(directoryInput))
        return()
    endif

    // Explicitly promote accepted values: some TSE configurations do not
    // reliably update custom Ask() histories themselves.
    if (GetHistoryStr(filenameHistoryI, 1) <> fileInput)
        AddHistoryStr(fileInput, filenameHistoryI)
    endif
    if (GetHistoryStr(topDirectoriesHistoryI, 1) <> directoryInput)
        AddHistoryStr(directoryInput, topDirectoriesHistoryI)
    endif

    PROCSetFileMask(fileInput)
    if (Length(fileToFind) and Length(directoryInput))
        fileToFind = Upper(fileToFind)
        if (Length(searchArchiveInput))
            PushKey(Asc(searchArchiveInput[1]))
        endif
        ZipSearch()

        PROCOpenLog()
        PROCLog("FILEFIN2 version 1.0.0.0.44 started")
        PROCLog(Format("File mask=", fileToFind,
                       "; top directories=", directoryInput,
                       "; search archives=", lLookInZip))

        origId = CreateTempBuffer()
        GotoBufferId(origId)
        EmptyBuffer()
        AddLine("FILEFIN2 version 1.0.0.0.44 - found results", origId)
        AddLine(Format("File mask: ", fileToFind), origId)
        AddLine("Elapsed search time: 00:00:00.00", origId)
        AddLine("Filename matching: DOS wildcards, case-insensitive", origId)
        if (lLookInZip)
            AddLine("Search archive files: Yes", origId)
        else
            AddLine("Search archive files: No", origId)
        endif
        AddLine(Format("Starting directories: ", directoryInput), origId)
        AddLine("Right click/Ctrl+Alt+G: return to results", origId)
        AddLine("", origId)
        firstResultLineI = NumLines() + 1
        resultCount = 0

        searchStartTicksI = GetTime()
        searchElapsedTicksI = 0
        PROCSearchDirectoryList(directoryInput)
        searchElapsedTicksI = GetTime() - searchStartTicksI
        if (searchElapsedTicksI < 0)
            searchElapsedTicksI = searchElapsedTicksI + 8640000
        endif

        if (not resultCount)
            AddLine("No matching files were found.", origId)
        endif
        GotoBufferId(origId)
        GotoLine(3)
        BegLine()
        KillToEol()
        InsertText(Format("Elapsed search time: ",
                          FNElapsedText(searchElapsedTicksI)), _INSERT_)
        PROCLog(Format("SUMMARY elapsed=", FNElapsedText(searchElapsedTicksI),
                       "; matches=", resultCount))
        PROCCloseLog()
        GotoBufferId(origId)
        if (resultCount)
            GotoLine(firstResultLineI)
        else
            EndFile()
        endif
        GotoColumn(1)
        UpdateDisplay(_DEFAULT_)
        PROCStartResultHighlight()
        Enable(FILEFIN2ResultKeys)
    endif
end

<CtrlAltShift F> Main()
<CtrlAlt G> PROCGoToResults()
