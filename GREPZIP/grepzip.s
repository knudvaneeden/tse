// GREPZIP - recursive TSE regular-expression search, including nested ZIP files
// Version : 1.0.0.0.7
// Date    : 2026-09-08
// LLM     : OpenAI Codex

string searchSpecS[255] = ""
string expressionS[255] = ""
string searchOptionsS[20] = "ix"
string findOptionsS[24] = ""
string helperS[255] = ""
string manifestS[255] = ""
string commandS[255] = ""
integer resultBufferI = 0
integer manifestBufferI = 0
integer matchCountI = 0
integer fileCountI = 0

proc PROCAddResult(string displayNameS, integer lineI, integer columnI,
                   string textS)
    string outputS[255] = ""
    outputS = Format(displayNameS, "(", lineI, ",", columnI, "): ", textS)
    AddLine(outputS, resultBufferI)
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
            PROCAddResult(displayNameS, CurrLine(), CurrCol(), lineS)
            foundI = lRepeatFind()
        endwhile
        AbandonFile(sourceBufferI)
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
                Message(displayNameS)
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
    manifestS = GetEnvStr("TEMP") + "\\grepzip_manifest.txt"
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
    if (not Ask("Directory or file specification:", searchSpecS, _EDIT_HISTORY_))
        return()
    endif
    if (not Length(searchSpecS))
        return()
    endif

    PROCNormalizeSpecification()
    findOptionsS = Lower(searchOptionsS)
    PROCBuildNames()
    commandS = Format('powershell.exe -NoP -NonI -W Hidden -ExecutionPolicy Bypass -File "',
                      helperS, '" -Specification "', searchSpecS, '"')
    Dos(commandS, _DONT_PROMPT_)

    resultBufferI = CreateTempBuffer()
    GotoBufferId(resultBufferI)
    EmptyBuffer()
    AddLine(Format("GREPZIP results - search string: ", expressionS))
    AddLine(Format("Search options: ", searchOptionsS))
    AddLine(Format("Source: ", searchSpecS))
    AddLine("")
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
    commandS = Format('powershell.exe -NoP -NonI -W Hidden -ExecutionPolicy Bypass -File "',
                      helperS, '" -Cleanup')
    Dos(commandS, _DONT_PROMPT_)
    Warn(Format(matchCountI, " matching line(s) found in ",
                fileCountI, " file(s) examined."))
end

<CtrlAltShift G> Main()
<CtrlAltShift R> PROCRegexHelp()
