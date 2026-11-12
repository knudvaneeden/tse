// GREPZIP - recursive TSE search, including nested archives
// Version : 1.0.0.0.30
// Date    : 2026-11-12
// LLM     : OpenAI Codex

string searchSpecS[255] = ""
string expressionS[255] = ""
string searchOptionsS[20] = "ix"
string searchArchivesS[10] = "yes"
string findOptionsS[24] = ""
string helperS[255] = ""
string manifestS[255] = ""
string iniS[255] = ""
string commandS[255] = ""
integer resultBufferI = 0
integer resultMapBufferI = 0
integer manifestBufferI = 0
integer originalBufferI = 0
integer matchCountI = 0
integer fileCountI = 0
integer firstResultLineI = 0
integer helperEnumeratedCountI = 0
integer helperManifestCountI = 0
integer helperErrorCountI = 0
integer showFileNamesB = TRUE
integer iniWarningCountI = 0
string iniWarningsS[255] = ""
string helperFirstErrorS[255] = ""
integer createLogB = FALSE
integer logHandleI = -1
string logPathS[255] = ""
string logDirectoryS[255] = ""

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
    string fileNameS[40] = ""

    logHandleI = -1
    logPathS = ""
    if (not createLogB)
        return()
    endif
    macroDirectoryS = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_)
    fileNameS = "grepzip_" + FNLogStamp() + ".log"

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
    Warn(Format("GREPZIP could not create its log in the configured, macro, ",
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

proc PROCAddResult(string diskNameS, string displayNameS, integer lineI,
                   integer columnI, string textS)
    string outputS[255] = ""
    outputS = Format(displayNameS, "(", lineI, ",", columnI, "): ", textS)
    AddLine(outputS, resultBufferI)
    AddLine(Format(diskNameS, Chr(9), lineI, Chr(9), columnI),
            resultMapBufferI)
    matchCountI = matchCountI + 1
end

proc PROCSearchOneFile(string diskNameS, string displayNameS)
    integer sourceBufferI = 0
    integer foundI = FALSE
    string lineS[255] = ""

    sourceBufferI = EditBuffer(diskNameS, _SYSTEM_)
    if (sourceBufferI)
        BegFile()
        foundI = lFind(expressionS, findOptionsS)
        while (foundI)
            lineS = GetText(1, CurrLineLen())
            PROCAddResult(diskNameS, displayNameS, CurrLine(), CurrCol(), lineS)
            PROCLog(Format(displayNameS, "(", CurrLine(), ",", CurrCol(),
                           "): ", lineS))
            foundI = lRepeatFind()
        endwhile
        AbandonFile(sourceBufferI)
    endif
end

proc PROCOpenResult()
    integer mapLineI = 0
    integer firstTabI = 0
    integer secondTabI = 0
    integer targetLineI = 0
    integer targetColumnI = 0
    string mapS[255] = ""
    string remainderS[255] = ""
    string diskNameS[255] = ""

    if ((GetBufferId() <> resultBufferI) or
        (CurrLine() < firstResultLineI) or
        (CurrLine() >= firstResultLineI + matchCountI))
        return()
    endif
    mapLineI = CurrLine() - firstResultLineI + 1
    GotoBufferId(resultMapBufferI)
    GotoLine(mapLineI)
    mapS = GetText(1, CurrLineLen())
    firstTabI = Pos(Chr(9), mapS)
    if (firstTabI <= 1)
        GotoBufferId(resultBufferI)
        return()
    endif
    diskNameS = SubStr(mapS, 1, firstTabI - 1)
    remainderS = SubStr(mapS, firstTabI + 1,
                         Length(mapS) - firstTabI)
    secondTabI = Pos(Chr(9), remainderS)
    if (secondTabI <= 1)
        GotoBufferId(resultBufferI)
        return()
    endif
    targetLineI = Val(SubStr(remainderS, 1, secondTabI - 1))
    targetColumnI = Val(SubStr(remainderS, secondTabI + 1,
                                Length(remainderS) - secondTabI))
    if (EditFile(Format('"', diskNameS, '"'), _DONT_PROMPT_))
        GotoLine(targetLineI)
        GotoColumn(targetColumnI)
    else
        GotoBufferId(resultBufferI)
        Warn("The selected result file is no longer available.")
    endif
end

proc PROCResultEnter()
    if (GetBufferId() == resultBufferI)
        PROCOpenResult()
    else
        ChainCmd()
    endif
end

proc PROCResultLeftClick()
    ChainCmd()
    if (GetBufferId() == resultBufferI)
        PROCOpenResult()
    endif
end

proc PROCGoToResults()
    if (resultBufferI)
        GotoBufferId(resultBufferI)
    else
        Warn("No GREPZIP results are available.")
    endif
end

proc PROCParseHelperStats(string statsLineS)
    string remainderS[255] = ""
    integer separatorI = 0

    remainderS = SubStr(statsLineS, 8, Length(statsLineS) - 7)
    separatorI = Pos("|", remainderS)
    if (separatorI)
        helperEnumeratedCountI = Val(SubStr(remainderS, 1, separatorI - 1))
        remainderS = SubStr(remainderS, separatorI + 1,
                            Length(remainderS) - separatorI)
        separatorI = Pos("|", remainderS)
        if (separatorI)
            helperManifestCountI = Val(SubStr(remainderS, 1, separatorI - 1))
            remainderS = SubStr(remainderS, separatorI + 1,
                                Length(remainderS) - separatorI)
            separatorI = Pos("|", remainderS)
            if (separatorI)
                helperErrorCountI = Val(SubStr(remainderS, 1, separatorI - 1))
                helperFirstErrorS = SubStr(remainderS, separatorI + 1,
                                            Length(remainderS) - separatorI)
            endif
        endif
    endif
end

proc PROCSearchManifest()
    string manifestLineS[255] = ""
    string diskNameS[255] = ""
    string displayNameS[255] = ""
    integer separatorI = 0
    integer manifestLineI = 1
    integer manifestLinesI = 0

    manifestBufferI = EditBuffer(manifestS, _SYSTEM_)
    if (manifestBufferI)
        manifestLinesI = NumLines()
        while (manifestLineI <= manifestLinesI)
            GotoBufferId(manifestBufferI)
            GotoLine(manifestLineI)
            manifestLineS = GetText(1, CurrLineLen())
            separatorI = Pos(Chr(9), manifestLineS)
            if (SubStr(manifestLineS, 1, 7) == "#STATS=")
                PROCParseHelperStats(manifestLineS)
            elseif ((separatorI > 1) and
                    (SubStr(manifestLineS, 1, 6) <> "#WORK="))
                diskNameS = SubStr(manifestLineS, 1, separatorI - 1)
                displayNameS = SubStr(manifestLineS, separatorI + 1,
                                      Length(manifestLineS) - separatorI)
                if (showFileNamesB)
                    GotoBufferId(originalBufferI)
                    Message(displayNameS)
                    UpdateDisplay(_DEFAULT_)
                endif
                fileCountI = fileCountI + 1
                PROCSearchOneFile(diskNameS, displayNameS)
            endif
            manifestLineI = manifestLineI + 1
        endwhile
        GotoBufferId(manifestBufferI)
        AbandonFile(manifestBufferI)
    endif
end

proc PROCBuildNames()
    string macroNameS[255] = ""

    macroNameS = CurrMacroFilename()
    helperS = SplitPath(macroNameS, _DRIVE_|_PATH_) + "grepzip_helper.ps1"
    iniS = SplitPath(macroNameS, _DRIVE_|_PATH_) + "grepzip.ini"
    manifestS = GetEnvStr("TEMP") + "\\grepzip_manifest.txt"
end

integer proc FNManifestHasCurrentStats()
    integer checkBufferI = 0
    integer checkLineI = 0
    integer firstLineI = 0
    integer foundB = FALSE
    string checkLineS[255] = ""

    checkBufferI = EditBuffer(manifestS, _SYSTEM_)
    if (checkBufferI)
        checkLineI = NumLines()
        firstLineI = checkLineI - 4
        if (firstLineI < 1)
            firstLineI = 1
        endif
        while ((checkLineI >= firstLineI) and (not foundB))
            GotoLine(checkLineI)
            checkLineS = GetText(1, CurrLineLen())
            if (SubStr(checkLineS, 1, 7) == "#STATS=")
                foundB = TRUE
            endif
            checkLineI = checkLineI - 1
        endwhile
        GotoBufferId(checkBufferI)
        AbandonFile(checkBufferI)
        GotoBufferId(originalBufferI)
    endif
    return(foundB)
end

proc PROCLoadIniDefaults()
    integer iniBufferI = 0
    integer lineI = 1
    integer linesI = 0
    integer separatorI = 0
    string lineS[255] = ""
    string keyS[40] = ""
    string valueS[255] = ""
    string sectionS[40] = ""
    integer seenSevenZipB = FALSE
    integer seenRarB = FALSE
    integer seenSearchStringB = FALSE
    integer seenSearchOptionsB = FALSE
    integer seenTopDirectoriesB = FALSE
    integer seenShowFileNamesB = FALSE
    integer seenSearchArchivesB = FALSE
    integer seenCreateLogB = FALSE
    integer seenLogDirectoryB = FALSE

    iniWarningCountI = 0
    iniWarningsS = ""

    if (not FileExists(iniS))
        return()
    endif

    iniBufferI = EditBuffer(iniS, _SYSTEM_)
    if (not iniBufferI)
        return()
    endif

    linesI = NumLines()
    while (lineI <= linesI)
        GotoBufferId(iniBufferI)
        GotoLine(lineI)
        lineS = GetText(1, CurrLineLen())
        if ((Length(lineS) > 1) and (lineS[1] == "[") and
            (lineS[Length(lineS)] == "]"))
            sectionS = Lower(SubStr(lineS, 2, Length(lineS) - 2))
            if ((sectionS <> "archivetools") and
                (sectionS <> "searchdefaults") and
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
                keyS = Lower(SubStr(lineS, 1, separatorI - 1))
                valueS = ""
                if (separatorI < Length(lineS))
                    valueS = SubStr(lineS, separatorI + 1,
                                     Length(lineS) - separatorI)
                endif
                if (keyS == "sevenzipexecutable")
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
                        PROCAddIniWarning(lineI, "duplicate RarExecutable")
                    else
                        seenRarB = TRUE
                    endif
                elseif (keyS == "searchstring")
                    if (sectionS <> "searchdefaults")
                        PROCAddIniWarning(lineI,
                            "searchstring is outside [SearchDefaults]")
                    elseif (seenSearchStringB)
                        PROCAddIniWarning(lineI, "duplicate searchstring")
                    elseif (Length(valueS))
                        expressionS = valueS
                    endif
                    if (sectionS == "searchdefaults")
                        seenSearchStringB = TRUE
                    endif
                elseif (keyS == "searchoptions")
                    if (sectionS <> "searchdefaults")
                        PROCAddIniWarning(lineI,
                            "searchoptions is outside [SearchDefaults]")
                    elseif (seenSearchOptionsB)
                        PROCAddIniWarning(lineI, "duplicate searchoptions")
                    elseif (Length(valueS))
                        searchOptionsS = valueS
                    endif
                    if (sectionS == "searchdefaults")
                        seenSearchOptionsB = TRUE
                    endif
                elseif (keyS == "topdirectories")
                    if (sectionS <> "searchdefaults")
                        PROCAddIniWarning(lineI,
                            "topdirectories is outside [SearchDefaults]")
                    elseif (seenTopDirectoriesB)
                        PROCAddIniWarning(lineI, "duplicate topdirectories")
                    elseif (Length(valueS))
                        searchSpecS = valueS
                    endif
                    if (sectionS == "searchdefaults")
                        seenTopDirectoriesB = TRUE
                    endif
                elseif (keyS == "showfilenames")
                    if (sectionS <> "searchdefaults")
                        PROCAddIniWarning(lineI,
                            "showfilenames is outside [SearchDefaults]")
                    elseif (seenShowFileNamesB)
                        PROCAddIniWarning(lineI, "duplicate showfilenames")
                    else
                        valueS = Lower(valueS)
                        if ((valueS == "true") or (valueS == "yes") or
                            (valueS == "1") or (valueS == "on"))
                            showFileNamesB = TRUE
                        elseif ((valueS == "false") or (valueS == "no") or
                                (valueS == "0") or (valueS == "off") or
                                (not Length(valueS)))
                            showFileNamesB = FALSE
                        else
                            PROCAddIniWarning(lineI,
                                              "invalid showfilenames value")
                        endif
                    endif
                    if (sectionS == "searchdefaults")
                        seenShowFileNamesB = TRUE
                    endif
                elseif (keyS == "searcharchives")
                    if (sectionS <> "searchdefaults")
                        PROCAddIniWarning(lineI,
                            "searcharchives is outside [SearchDefaults]")
                    elseif (seenSearchArchivesB)
                        PROCAddIniWarning(lineI, "duplicate searcharchives")
                    else
                        valueS = Lower(valueS)
                        if ((valueS == "yes") or (valueS == "y") or
                            (valueS == "true") or (valueS == "1") or
                            (valueS == "on"))
                            searchArchivesS = "yes"
                        elseif ((valueS == "no") or (valueS == "n") or
                                (valueS == "false") or (valueS == "0") or
                                (valueS == "off"))
                            searchArchivesS = "no"
                        else
                            PROCAddIniWarning(lineI,
                                              "invalid searcharchives value")
                        endif
                    endif
                    if (sectionS == "searchdefaults")
                        seenSearchArchivesB = TRUE
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
end

proc PROCNormalizeSpecification()
    string normalizedS[255] = ""
    integer indexI = 1
    integer lengthI = Length(searchSpecS)

    while (indexI <= lengthI)
        if (Asc(searchSpecS[indexI]) <> 34)
            if (Asc(searchSpecS[indexI]) == 47)
                normalizedS = normalizedS + Chr(92)
            else
                normalizedS = normalizedS + searchSpecS[indexI]
            endif
        endif
        indexI = indexI + 1
    endwhile
    searchSpecS = normalizedS
    lengthI = Length(searchSpecS)
    if ((lengthI > 3) and ((Asc(searchSpecS[lengthI]) == 92) or
        (Asc(searchSpecS[lengthI]) == 47)))
        searchSpecS = SubStr(searchSpecS, 1, lengthI - 1)
    endif
end

proc PROCRegexHelp()
    Help("Regular Expression Operators")
end

proc Main()
    integer searchStringHistoryI = 0
    integer searchOptionsHistoryI = 0
    integer searchSpecificationsHistoryI = 0
    integer searchArchivesHistoryI = 0

    originalBufferI = GetBufferId()
    PROCBuildNames()

    // Built-in GREPZIP defaults. Blank INI values do not replace them.
    expressionS = ""
    searchOptionsS = "ix"
    searchArchivesS = "yes"
    searchSpecS = ""
    createLogB = FALSE
    logDirectoryS = ""
    PROCLoadIniDefaults()
    if (iniWarningCountI)
        Warn(Format("GREPZIP.INI has ", iniWarningCountI,
                    " warning(s): ", iniWarningsS))
    endif

    searchStringHistoryI = GetFreeHistory("GREPZIP:searchstring")
    searchOptionsHistoryI = GetFreeHistory("GREPZIP:searchoptions")
    searchSpecificationsHistoryI = GetFreeHistory("GREPZIP:searchspecifications")
    searchArchivesHistoryI = GetFreeHistory("GREPZIP:searcharchives")
    if ((not searchStringHistoryI) or (not searchOptionsHistoryI) or
        (not searchSpecificationsHistoryI) or (not searchArchivesHistoryI))
        Warn("GREPZIP could not allocate all dedicated input histories.")
        return()
    endif
    if (not Length(expressionS))
        expressionS = GetHistoryStr(searchStringHistoryI, 1)
    endif
    if (not Length(searchOptionsS))
        searchOptionsS = GetHistoryStr(searchOptionsHistoryI, 1)
    endif
    if (not Length(searchSpecS))
        searchSpecS = GetHistoryStr(searchSpecificationsHistoryI, 1)
    endif
    if (not Length(searchArchivesS))
        searchArchivesS = GetHistoryStr(searchArchivesHistoryI, 1)
    endif

    if (not Ask(Format("Search string (TSE regex: . ^ $ | ? [] [~] * + @ # {} ",
                      Chr(92), "):"),
                expressionS, searchStringHistoryI))
        return()
    endif
    if (not Length(expressionS))
        return()
    endif
    if (not Ask("Search options (for example i or ix):", searchOptionsS,
                searchOptionsHistoryI))
        return()
    endif
    if (not Ask("Directories or file specifications (; separated):",
                searchSpecS, searchSpecificationsHistoryI))
        return()
    endif
    if (not Length(searchSpecS))
        return()
    endif
    if (not Ask("Search archived files (yes/no):", searchArchivesS,
                searchArchivesHistoryI))
        return()
    endif
    searchArchivesS = Lower(searchArchivesS)
    if ((searchArchivesS == "yes") or (searchArchivesS == "y") or
        (searchArchivesS == "true") or (searchArchivesS == "1") or
        (searchArchivesS == "on"))
        searchArchivesS = "yes"
    elseif ((searchArchivesS == "no") or (searchArchivesS == "n") or
            (searchArchivesS == "false") or (searchArchivesS == "0") or
            (searchArchivesS == "off"))
        searchArchivesS = "no"
    else
        Warn("Search archived files must be yes or no.")
        return()
    endif

    PROCNormalizeSpecification()
    findOptionsS = Lower(searchOptionsS)
    if (not FileExists(helperS))
        Warn(Format("GREPZIP_HELPER.PS1 was not found beside the running ",
                    "GREPZIP macro.", Chr(13), helperS, Chr(13),
                    "Keep GREPZIP.MAC and GREPZIP_HELPER.PS1 together."))
        return()
    endif

    PROCOpenLog()
    PROCLog("GREPZIP version 1.0.0.0.30 started")
    PROCLog(Format("Search expression=", expressionS,
                   "; options=", searchOptionsS,
                   "; specifications=", searchSpecS,
                   "; search archives=", searchArchivesS))

    // Never permit a failed helper launch to reuse an earlier search manifest.
    commandS = Format('cmd.exe /c del /q "', manifestS, '" 2>nul')
    Dos(commandS, _DONT_PROMPT_)
    if (FileExists(manifestS))
        PROCLog("ERROR Could not remove the previous manifest.")
        PROCCloseLog()
        Warn(Format("GREPZIP could not remove its previous manifest:",
                    Chr(13), manifestS, Chr(13),
                    "The search was stopped to prevent stale results."))
        return()
    endif

    Message("GREPZIP: Enumerating files and expanding archives...")
    UpdateDisplay(_DEFAULT_)
    commandS = Format('powershell.exe -NoP -NonI -W Hidden -ExecutionPolicy Bypass -File "',
                      helperS, '" -SearchArchives "', searchArchivesS,
                      '" -Specification "', searchSpecS, '"')
    Dos(commandS, _DONT_PROMPT_)

    if (not FileExists(manifestS))
        PROCLog("ERROR PowerShell did not create a new manifest.")
        PROCCloseLog()
        Warn(Format("PowerShell did not create a new GREPZIP manifest.",
                    Chr(13), "Check that GREPZIP_HELPER.PS1 can run and ",
                    "that PowerShell reports no error."))
        return()
    endif
    if (not FNManifestHasCurrentStats())
        PROCLog("ERROR Manifest has no current #STATS marker.")
        PROCCloseLog()
        Warn(Format("The new GREPZIP manifest has no current #STATS marker.",
                    Chr(13), "The helper may be an older or mismatched version.",
                    Chr(13), "Reinstall all files from the same GREPZIP ZIP."))
        return()
    endif

    resultBufferI = CreateTempBuffer()
    resultMapBufferI = CreateTempBuffer()
    GotoBufferId(resultMapBufferI)
    EmptyBuffer()
    GotoBufferId(resultBufferI)
    EmptyBuffer()
    AddLine(Format("GREPZIP results - search string: ", expressionS))
    AddLine(Format("Search options: ", searchOptionsS))
    AddLine(Format("Search archived files: ", searchArchivesS))
    AddLine(Format("Source: ", searchSpecS))
    AddLine("Enter/Left click: open result; Ctrl+Alt+G: return here")
    AddLine("")
    firstResultLineI = NumLines() + 1
    matchCountI = 0
    fileCountI = 0
    helperEnumeratedCountI = 0
    helperManifestCountI = 0
    helperErrorCountI = 0
    helperFirstErrorS = ""
    PROCSearchManifest()
    GotoBufferId(resultBufferI)
    AddLine(Format("PowerShell source files enumerated: ",
                   helperEnumeratedCountI))
    AddLine(Format("PowerShell manifest entries written: ",
                   helperManifestCountI))
    AddLine(Format("Files examined: ", fileCountI))
    if (helperErrorCountI)
        AddLine(Format("PowerShell helper errors: ", helperErrorCountI))
        if (Length(helperFirstErrorS))
            AddLine(Format("First helper error: ", helperFirstErrorS))
        endif
    endif
    if (not matchCountI)
        AddLine("No matching text was found.")
    endif
    PROCLog(Format("SUMMARY matches=", matchCountI,
                   "; files examined=", fileCountI,
                   "; source files enumerated=", helperEnumeratedCountI,
                   "; manifest entries=", helperManifestCountI,
                   "; helper errors=", helperErrorCountI))
    if (helperErrorCountI and Length(helperFirstErrorS))
        PROCLog(Format("FIRST HELPER ERROR ", helperFirstErrorS))
    endif
    PROCCloseLog()
    BegFile()
    UpdateDisplay(_DEFAULT_)
    Warn(Format(matchCountI, " matching line(s) found in ",
                fileCountI, " file(s) examined.", Chr(13),
                Chr(13),
                "Click a found line or press Enter to open its file ",
                "at that line and column.", Chr(13),
                "Press Ctrl+Alt+G to return to the search results."))
end

<CtrlAltShift F> Main()
<CtrlAlt G> PROCGoToResults()
<CtrlAltShift R> PROCRegexHelp()
<Enter> PROCResultEnter()
<LeftBtn> PROCResultLeftClick()
