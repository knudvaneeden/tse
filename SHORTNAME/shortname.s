// SHORTNAME 1.0.0.0.2 - GPT-6 (OpenAI)
// Updated 2026-10-08 17:32 +02:00. ASCII SAL source.
// 32-bit Windows TSE. Unicode enumeration; no external helpers.
dll "<kernel32.dll>"
    integer proc FNGlobalAlloc(integer flagsI, integer bytesI) : "GlobalAlloc"
    integer proc FNGlobalFree(integer memoryI) : "GlobalFree"
    integer proc FNMultiByteToWideChar(integer pageI, integer flagsI,
        string inputS:cstrval, integer lengthI, integer outputI,
        integer capacityI) : "MultiByteToWideChar"
    integer proc FNFindFirstFileW(integer patternI, integer dataI) : "FindFirstFileW"
    integer proc FNFindNextFileW(integer handleI, integer dataI) : "FindNextFileW"
    integer proc FNFindClose(integer handleI) : "FindClose"
    integer proc FNGetLastError() : "GetLastError"
    integer proc FNGetShortPathNameA(string inputS:cstrval,
        var string outputS:strptr, integer capacityI) : "GetShortPathNameA"
end

// Read UTF-16 directly. Unicode is displayed as ASCII escapes because
// traditional TSE cannot reliably render Chinese filenames.
// Only printable ASCII is eligible for insertion as a workaround name.
string proc FNReadWide(integer pointerI, integer maximumI, integer escapeB)
    integer indexI = 0
    integer wordI = 0
    string outputS[255] = ""
    string pieceS[6] = ""
    string hexS[4] = ""
    for indexI = 0 to maximumI - 1
        wordI = PeekWord(AdjPtr(pointerI, indexI * 2))
        if wordI == 0
            return(outputS)
        endif
        if wordI >= 32 and wordI <= 126
            pieceS = Chr(wordI)
        elseif escapeB
            hexS = Upper(Str(wordI, 16))
            pieceS = Chr(92) + "u" + SubStr("0000", 1, 4 - Length(hexS)) + hexS
        else
            return("")
        endif
        if Length(outputS) + Length(pieceS) > 250
            if escapeB
                return(outputS + "...")
            endif
            return("")
        endif
        outputS = outputS + pieceS
    endfor
    return(outputS)
end

integer proc FNIsShortName(string nameS)
    integer indexI = 0
    integer dotI = 0
    string charS[1] = ""
    if Length(nameS) == 0 or Length(nameS) > 12
        return(FALSE)
    endif
    for indexI = 1 to Length(nameS)
        charS = SubStr(nameS, indexI, 1)
        if charS == "."
            if dotI <> 0 or indexI == 1 or indexI > 9
                return(FALSE)
            endif
            dotI = indexI
        elseif Asc(charS) <= 32 or Pos(charS, Chr(34) + "+,;=[]" + Chr(92) + "/:*?<>|") > 0
            return(FALSE)
        endif
    endfor
    if dotI == 0
        return(Length(nameS) <= 8)
    endif
    return(Length(nameS) > dotI and Length(nameS) - dotI <= 3)
end

proc Main()
    string iniS[255] = "shortname.ini"
    string directoryS[255] = ""
    string maskS[255] = "*"
    string searchS[255] = ""
    string longS[255] = ""
    string shortS[255] = ""
    string displayS[255] = ""
    string outputS[255] = ""
    string statusS[255] = ""
    string shortDirectoryS[255] = ""
    integer silentB = FALSE
    integer fullPathB = FALSE
    integer doneB = FALSE
    integer listI = 0
    integer mapI = 0
    integer patternI = 0
    integer dataI = 0
    integer handleI = -1
    integer resultI = 0
    integer errorI = 0
    integer countI = 0
    integer selectedI = 0
    integer widthI = 14

    if not FileExists(iniS)
        iniS = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + iniS
    endif
    silentB = Lower(GetProfileStr("shortname", "silent", "false", iniS)) == "true"
    if not silentB
        Warn("SHORTNAME 1.0.0.0.2 - GPT-6",
            "Lists long and short filenames, including Unicode names. " +
            "Chinese characters appear as Unicode escapes. " +
            "Enter inserts a usable short filename; Escape cancels.")
    endif
    fullPathB = Lower(GetProfileStr("shortname", "insertfullpath", "false", iniS)) == "true"
    directoryS = GetProfileStr("shortname", "directory", "", iniS)
    maskS = GetProfileStr("shortname", "filemask", "*", iniS)
    if directoryS == ""
        directoryS = CurrDir()
    endif
    if not Ask("Directory (use its short path if it contains Chinese)", directoryS, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("File mask (* lists all names, including Chinese)", maskS, _EDIT_HISTORY_)
        return()
    endif
    directoryS = Trim(directoryS)
    maskS = Trim(maskS)
    if SubStr(directoryS, 1, 1) == Chr(34) and SubStr(directoryS, Length(directoryS), 1) == Chr(34)
        directoryS = SubStr(directoryS, 2, Length(directoryS) - 2)
    endif
    if directoryS == "" or maskS == ""
        statusS = "Directory and file mask must not be empty."
    else
        directoryS = ExpandPath(directoryS, TRUE)
        // TSE appends a wildcard filename when expanding a directory.
        if SplitPath(directoryS, _NAME_ | _EXT_) == "*.*" or SplitPath(directoryS, _NAME_ | _EXT_) == "*"
            directoryS = SplitPath(directoryS, _DRIVE_ | _PATH_)
        endif
        if directoryS == ""
            statusS = "Could not resolve the directory."
        elseif Length(directoryS) + Length(maskS) > 253
            statusS = "Directory and mask exceed the supported path length."
        else
            if SubStr(directoryS, Length(directoryS), 1) <> Chr(92)
                directoryS = directoryS + Chr(92)
            endif
            searchS = directoryS + maskS
        endif
    endif
    if statusS == ""
        shortDirectoryS = Format("":255:Chr(0))
        resultI = FNGetShortPathNameA(directoryS, shortDirectoryS, 255)
        if resultI > 0 and resultI < 255
            shortDirectoryS = SubStr(shortDirectoryS, 1, resultI)
        else
            shortDirectoryS = directoryS
        endif
        PushLocation()
        listI = CreateTempBuffer()
        mapI = CreateTempBuffer()
        // GMEM_FIXED: return values are directly usable pointers.
        patternI = FNGlobalAlloc(0, 512)
        // WIN32_FIND_DATAW: 44-byte header + 260 WCHAR + 14 WCHAR.
        dataI = FNGlobalAlloc(0, 592)
        if listI == 0 or mapI == 0 or patternI == 0 or dataI == 0
            statusS = "Could not allocate the filename list."
        else
            resultI = FNMultiByteToWideChar(0, 0, searchS, -1, patternI, 256)
            if resultI == 0
                statusS = "Cannot convert the directory and mask to Unicode."
            else
                handleI = FNFindFirstFileW(patternI, dataI)
                if handleI == -1
                    errorI = FNGetLastError()
                    statusS = "No files found. Windows error " + Str(errorI) + ". Search: " + searchS
                else
                    repeat
                        if not (PeekLong(dataI) & _DIRECTORY_)
                            longS = FNReadWide(AdjPtr(dataI, 44), 260, TRUE)
                            shortS = FNReadWide(AdjPtr(dataI, 564), 14, FALSE)
                            if shortS == ""
                                // An already-short ASCII filename needs no alias.
                                shortS = FNReadWide(AdjPtr(dataI, 44), 260, FALSE)
                            endif
                            outputS = ""
                            displayS = "<no usable ASCII short name>"
                            if FNIsShortName(shortS)
                                displayS = shortS
                                outputS = shortS
                                if fullPathB
                                    if Length(shortDirectoryS) + Length(shortS) <= 254
                                        outputS = shortDirectoryS + shortS
                                    else
                                        outputS = ""
                                        displayS = "<short path too long>"
                                    endif
                                endif
                            endif
                            GotoBufferId(listI)
                            EndFile()
                            AddLine(longS)
                            widthI = Max(widthI, Length(longS))
                            GotoBufferId(mapI)
                            EndFile()
                            AddLine(outputS)
                            countI = countI + 1
                        endif
                    until not FNFindNextFileW(handleI, dataI)
                    errorI = FNGetLastError()
                    FNFindClose(handleI)
                    handleI = -1
                    if errorI <> 18
                        statusS = "Windows enumeration error " + Str(errorI) + ". Search: " + searchS
                    elseif countI == 0
                        statusS = "No files matched. Search: " + searchS
                    endif
                endif
            endif
            outputS = ""
            if statusS == ""
                // Append the second column after measuring all long names.
                for selectedI = 1 to countI
                    GotoBufferId(mapI)
                    GotoLine(selectedI)
                    shortS = GetText(1, 255)
                    displayS = "<no usable ASCII short name>"
                    if shortS <> ""
                        displayS = SplitPath(shortS, _NAME_ | _EXT_)
                    endif
                    GotoBufferId(listI)
                    GotoLine(selectedI)
                    longS = GetText(1, 255)
                    EndLine()
                    InsertText(Format("":widthI - Length(longS)), _INSERT_)
                    InsertText("  |  " + displayS, _INSERT_)
                endfor
                GotoBufferId(listI)
                BegFile()
                while not doneB
                    if lList("Long filename | Short filename - Enter inserts; Esc cancels",
                        Min(Query(ScreenCols) - 2, Max(widthI + 35, 65)),
                        Query(ScreenRows) - 4, _ENABLE_HSCROLL_ | _ENABLE_SEARCH_)
                        selectedI = CurrLine()
                        GotoBufferId(mapI)
                        GotoLine(selectedI)
                        outputS = GetText(1, 255)
                        GotoBufferId(listI)
                        GotoLine(selectedI)
                        if outputS <> ""
                            doneB = TRUE
                        else
                            Message("No usable ASCII short name. Select another file or press Escape.")
                        endif
                    else
                        outputS = ""
                        doneB = TRUE
                    endif
                endwhile
            endif
        endif
        if dataI <> 0
            FNGlobalFree(dataI)
        endif
        if patternI <> 0
            FNGlobalFree(patternI)
        endif
        if mapI <> 0
            GotoBufferId(mapI)
            AbandonFile()
        endif
        if listI <> 0
            GotoBufferId(listI)
            AbandonFile()
        endif
        PopLocation()
        if statusS == "" and outputS <> ""
            if InsertText(outputS, _INSERT_)
                Message("SHORTNAME: inserted " + outputS)
            else
                statusS = "Could not insert the selected filename."
            endif
        endif
    endif
    if not silentB and statusS <> ""
        Warn("SHORTNAME 1.0.0.0.2 - GPT-6", statusS)
    endif
end
