// FILEFIN2 - recursive Win32 file finder for TSE Pro
// Version : 1.0.0.0.42
// Date    : 2026-11-12
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
integer iniWarningCountI = 0
string iniWarningsS[255] = ""
integer createLogB = FALSE
integer logHandleI = -1
string logPathS[255] = ""
string logDirectoryS[255] = ""

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
            else
                Message(pathS)
            endif
            UpdateDisplay(_DEFAULT_)

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
        GotoBufferId(origId)
    else
        Warn("No FILEFIN2 results are available.")
    endif
end

proc Main()
    string iniFilenameS[255] = ""
    integer filenameHistoryI = 0
    integer topDirectoriesHistoryI = 0

    // Built-in FF.S defaults. Blank INI values do not replace them.
    fileInput = ""
    directoryInput = ""
    searchArchiveInput = ""
    createLogB = FALSE
    logDirectoryS = ""
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
    if ((not Length(fileInput)) and filenameHistoryI)
        fileInput = GetHistoryStr(filenameHistoryI, 1)
    endif
    if ((not Length(directoryInput)) and topDirectoriesHistoryI)
        directoryInput = GetHistoryStr(topDirectoriesHistoryI, 1)
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

    PROCSetFileMask(fileInput)
    if (Length(fileToFind) and Length(directoryInput))
        fileToFind = Upper(fileToFind)
        if (Length(searchArchiveInput))
            PushKey(Asc(searchArchiveInput[1]))
        endif
        ZipSearch()

        PROCOpenLog()
        PROCLog("FILEFIN2 version 1.0.0.0.42 started")
        PROCLog(Format("File mask=", fileToFind,
                       "; top directories=", directoryInput,
                       "; search archives=", lLookInZip))

        origId = CreateTempBuffer()
        GotoBufferId(origId)
        EmptyBuffer()
        AddLine(Format("FILEFIN2 results for filename: ", fileToFind), origId)
        AddLine("Filename matching: DOS wildcards, case-insensitive", origId)
        if (lLookInZip)
            AddLine("Search archive files: Yes", origId)
        else
            AddLine("Search archive files: No", origId)
        endif
        AddLine(Format("Starting directories: ", directoryInput), origId)
        AddLine(Format("File mask: ", fileToFind), origId)
        AddLine("", origId)
        resultCount = 0

        PROCSearchDirectoryList(directoryInput)
        UpdateDisplay(_DEFAULT_)

        if (not resultCount)
            AddLine("No matching files were found.", origId)
        endif
        PROCLog(Format("SUMMARY matches=", resultCount))
        PROCCloseLog()
        GotoBufferId(origId)
        GotoLine(1)
        GotoColumn(1)
    endif
end

<CtrlAltShift F> Main()
<CtrlAlt G> PROCGoToResults()
