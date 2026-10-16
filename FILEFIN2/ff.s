// FILEFIN2 - recursive Win32 file finder for TSE Pro
// Version : 1.0.0.0.32
// Date    : 2026-10-16
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
    integer seenTopDirectoryB = FALSE
    integer seenSearchArchiveB = FALSE
    integer seenSevenZipB = FALSE
    integer seenRarB = FALSE

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
            if ((sectionS <> "search") and
                (sectionS <> "archivetools"))
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
                    if (sectionS <> "search")
                        PROCAddIniWarning(lineI,
                            "filename is outside [Search]")
                    elseif (seenFilenameB)
                        PROCAddIniWarning(lineI, "duplicate filename")
                    elseif (Length(valueS))
                        fileInput = valueS
                    endif
                    if (sectionS == "search")
                        seenFilenameB = TRUE
                    endif
                elseif (keyS == "topdirectory")
                    if (sectionS <> "search")
                        PROCAddIniWarning(lineI,
                            "topdirectory is outside [Search]")
                    elseif (seenTopDirectoryB)
                        PROCAddIniWarning(lineI, "duplicate topdirectory")
                    elseif (Length(valueS))
                        directoryInput = valueS
                    endif
                    if (sectionS == "search")
                        seenTopDirectoryB = TRUE
                    endif
                elseif (keyS == "searcharchive")
                    if (sectionS <> "search")
                        PROCAddIniWarning(lineI,
                            "searcharchive is outside [Search]")
                    elseif (seenSearchArchiveB)
                        PROCAddIniWarning(lineI, "duplicate searcharchive")
                    elseif ((Lower(valueS) == "yes") or
                            (Lower(valueS) == "y") or
                            (Lower(valueS) == "no") or
                            (Lower(valueS) == "n"))
                        searchArchiveInput = Lower(valueS)
                    elseif (Length(valueS))
                        PROCAddIniWarning(lineI,
                                          "invalid searcharchive value")
                    endif
                    if (sectionS == "search")
                        seenSearchArchiveB = TRUE
                    endif
                elseif (keyS == "sevenzipexe")
                    if (sectionS <> "archivetools")
                        PROCAddIniWarning(lineI,
                            "SevenZipExe is outside [ArchiveTools]")
                    elseif (seenSevenZipB)
                        PROCAddIniWarning(lineI, "duplicate SevenZipExe")
                    else
                        seenSevenZipB = TRUE
                    endif
                elseif (keyS == "rarexe")
                    if (sectionS <> "archivetools")
                        PROCAddIniWarning(lineI,
                            "RarExe is outside [ArchiveTools]")
                    elseif (seenRarB)
                        PROCAddIniWarning(lineI, "duplicate RarExe")
                    else
                        seenRarB = TRUE
                    endif
                elseif (keyS == "opdirectory")
                    PROCAddIniWarning(lineI,
                        "unknown 'opdirectory'; use 'topdirectory'")
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

proc Main()
    string iniFilenameS[255] = ""

    // Built-in FF.S defaults. Blank INI values do not replace them.
    fileInput = ""
    directoryInput = ""
    searchArchiveInput = ""
    iniFilenameS = SplitPath(CurrMacroFileName(), _DRIVE_|_PATH_) +
                   "filefin2.ini"
    PROCLoadIniDefaults(iniFilenameS)
    if (iniWarningCountI)
        Warn(Format("FILEFIN2.INI has ", iniWarningCountI,
                    " warning(s): ", iniWarningsS))
    endif

    if (Ask("Enter filename or file mask (*, .*, ?):", fileInput, _EDIT_HISTORY_) and Length(fileInput))
        if (Ask("Enter top directories (; separated):", directoryInput, _EDIT_HISTORY_) and Length(directoryInput))
            PROCSetFileMask(fileInput)

            if (Length(fileToFind) and Length(directoryInput))
                fileToFind = Upper(fileToFind)
                if (Length(searchArchiveInput))
                    PushKey(Asc(searchArchiveInput[1]))
                endif
                ZipSearch()

                origId = CreateTempBuffer()
                GotoBufferId(origId)
                EmptyBuffer()
                AddLine(Format("FILEFIN2 results for filename: ", fileToFind), origId)
                AddLine(Format("Starting directories: ", directoryInput), origId)
                AddLine(Format("File mask: ", fileToFind), origId)
                AddLine("", origId)
                resultCount = 0

                PROCSearchDirectoryList(directoryInput)
                UpdateDisplay(_DEFAULT_)

                if (not resultCount)
                    AddLine("No matching files were found.", origId)
                endif
                GotoBufferId(origId)
                GotoLine(1)
                GotoColumn(1)
            endif
        endif
    endif
end

<CtrlAltShift F> Main()
