// GREPZIP - recursive TSE search, including nested archives
// Version : 1.0.0.0.20
// Date    : 2026-10-16
// LLM     : OpenAI Codex

string searchSpecS[255] = ""
string expressionS[255] = ""
string searchOptionsS[20] = "ix"
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
integer showFileNamesB = TRUE
integer iniWarningCountI = 0
string iniWarningsS[255] = ""

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
            if ((separatorI > 1) and (SubStr(manifestLineS, 1, 6) <> "#WORK="))
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
    integer seenTopDirectoryB = FALSE
    integer seenShowFileNamesB = FALSE

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
                (sectionS <> "searchdefaults"))
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
                elseif (keyS == "topdirectory")
                    if (sectionS <> "searchdefaults")
                        PROCAddIniWarning(lineI,
                            "topdirectory is outside [SearchDefaults]")
                    elseif (seenTopDirectoryB)
                        PROCAddIniWarning(lineI, "duplicate topdirectory")
                    elseif (Length(valueS))
                        searchSpecS = valueS
                    endif
                    if (sectionS == "searchdefaults")
                        seenTopDirectoryB = TRUE
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
end

proc PROCNormalizeSpecification()
    string normalizedS[255] = ""
    integer indexI = 1
    integer lengthI = Length(searchSpecS)

    while (indexI <= lengthI)
        if (Asc(searchSpecS[indexI]) <> 34)
            if (searchSpecS[indexI] == "/")
                normalizedS = normalizedS + "\\"
            else
                normalizedS = normalizedS + searchSpecS[indexI]
            endif
        endif
        indexI = indexI + 1
    endwhile
    searchSpecS = normalizedS
    lengthI = Length(searchSpecS)
    if ((lengthI > 3) and ((searchSpecS[lengthI] == "\\") or
        (searchSpecS[lengthI] == "/")))
        searchSpecS = SubStr(searchSpecS, 1, lengthI - 1)
    endif
end

proc PROCRegexHelp()
    Help("Regular Expression Operators")
end

proc Main()
    originalBufferI = GetBufferId()
    PROCBuildNames()
    PROCLoadIniDefaults()
    if (iniWarningCountI)
        Warn(Format("GREPZIP.INI has ", iniWarningCountI,
                    " warning(s): ", iniWarningsS))
    endif

    if (not Ask(Format("Search string (TSE regex: . ^ $ | ? [] [~] * + @ # {} ",
                      Chr(92), "):"),
                expressionS, _EDIT_HISTORY_))
        return()
    endif
    if (not Length(expressionS))
        return()
    endif
    if (not Ask("Search options (for example i or ix):", searchOptionsS,
                _EDIT_HISTORY_))
        return()
    endif
    if (not Ask("Directories or file specifications (; separated):",
                searchSpecS, _EDIT_HISTORY_))
        return()
    endif
    if (not Length(searchSpecS))
        return()
    endif

    PROCNormalizeSpecification()
    findOptionsS = Lower(searchOptionsS)
    Message("GREPZIP: Enumerating files and expanding archives...")
    UpdateDisplay(_DEFAULT_)
    commandS = Format('powershell.exe -NoP -NonI -W Hidden -ExecutionPolicy Bypass -File "',
                      helperS, '" -Specification "', searchSpecS, '"')
    Dos(commandS, _DONT_PROMPT_)

    resultBufferI = CreateTempBuffer()
    resultMapBufferI = CreateTempBuffer()
    GotoBufferId(resultMapBufferI)
    EmptyBuffer()
    GotoBufferId(resultBufferI)
    EmptyBuffer()
    AddLine(Format("GREPZIP results - search string: ", expressionS))
    AddLine(Format("Search options: ", searchOptionsS))
    AddLine(Format("Source: ", searchSpecS))
    AddLine("Enter/Left click: open result; Ctrl+Alt+Shift+G: return here")
    AddLine("")
    firstResultLineI = NumLines() + 1
    matchCountI = 0
    fileCountI = 0
    PROCSearchManifest()
    GotoBufferId(resultBufferI)
    AddLine(Format("Files examined: ", fileCountI))
    if (not matchCountI)
        AddLine("No matching text was found.")
    endif
    BegFile()
    UpdateDisplay(_DEFAULT_)
    Warn(Format(matchCountI, " matching line(s) found in ",
                fileCountI, " file(s) examined."))
end

<CtrlAltShift F> Main()
<CtrlAltShift G> PROCGoToResults()
<CtrlAltShift R> PROCRegexHelp()
<Enter> PROCResultEnter()
<LeftBtn> PROCResultLeftClick()
