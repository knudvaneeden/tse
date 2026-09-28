// SEARCHHELPTSE 1.0.0.0.2 - GPT-6 (OpenAI)
// Search disk files and browse matching lines in a TSE List() picker.
string GSPattern[255] = ""
string GSOptions[40] = ""
integer GIResults = 0
integer GIMap = 0
integer GICount = 0
integer GIMissing = 0
integer GIHasResults = FALSE

string proc FNResolveFile(string suppliedS)
    string candidateS[255] = ""
    string macroDirectoryS[255] = ""
    // Resolve each entry independently. An explicit path is tried first.
    // For a bare name, prefer the macro directory to the current directory.
    if SplitPath(suppliedS, _DRIVE_ | _PATH_) <> ""
        if FileExists(suppliedS)
            return(ExpandPath(suppliedS))
        endif
        if SplitPath(suppliedS, _DRIVE_) <> "" or SubStr(suppliedS, 1, 1) == Chr(92) or SubStr(suppliedS, 1, 1) == "/"
            return("")
        endif
    endif
    macroDirectoryS = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    candidateS = macroDirectoryS + suppliedS
    if FileExists(candidateS)
        return(ExpandPath(candidateS))
    endif
    if FileExists(suppliedS)
        return(ExpandPath(suppliedS))
    endif
    return("")
end

proc PROCSearchFile(string filenameS)
    integer sourceI = 0
    integer lineI = 0
    integer columnI = 0
    integer previousI = GetBufferId()
    string previewS[255] = ""
    string optionsS[40] = GSOptions + "g"
    if not FileExists(filenameS)
        GIMissing = GIMissing + 1
        GotoBufferId(previousI)
        return()
    endif
    sourceI = CreateTempBuffer()
    if sourceI == 0
        return()
    endif
    BufferType(_HIDDEN_)
    if LoadBuffer(filenameS)
        BegFile()
        while Find(GSPattern, optionsS)
            lineI = CurrLine()
            columnI = CurrPos()
            previewS = GetText(1, 160)
            GotoBufferId(GIResults)
            EndFile()
            AddLine(SplitPath(filenameS, _NAME_ | _EXT_) + " (" + Str(lineI) + "," + Str(columnI) + "): " + previewS)
            GotoBufferId(GIMap)
            EndFile()
            AddLine(filenameS + "|" + Str(lineI) + "|" + Str(columnI))
            GICount = GICount + 1
            GotoBufferId(sourceI)
            optionsS = GSOptions + "+"
        endwhile
    else
        GIMissing = GIMissing + 1
    endif
    GotoBufferId(sourceI)
    AbandonFile()
    GotoBufferId(previousI)
end

proc PROCShowResults()
    integer destinationI = GetBufferId()
    integer originalI = destinationI
    string filenameS[255] = ""
    string mapS[255] = ""
    integer separatorI = 0
    integer nextI = 0
    integer selectedI = 0
    if not GIHasResults
        Warn("SEARCHHELPTSE: No previous search results are available.")
        return()
    endif
    GotoBufferId(GIResults)
    BegFile()
    if List("SEARCHHELPTSE: " + Str(GICount) + " hits (Enter opens file)", Query(ScreenCols)) and GICount > 0
        selectedI = CurrLine()
        GotoBufferId(GIMap)
        if selectedI <= NumLines()
            GotoLine(selectedI)
            mapS = GetText(1, 255)
            separatorI = Pos("|", mapS)
            filenameS = SubStr(mapS, 1, separatorI - 1)
            mapS = SubStr(mapS, separatorI + 1, 255)
            nextI = Pos("|", mapS)
            selectedI = Val(SubStr(mapS, 1, nextI - 1))
            nextI = Val(SubStr(mapS, nextI + 1, 255))
            GotoBufferId(originalI)
            if EditFile(filenameS, _DONT_PROMPT_)
                GotoLine(selectedI)
                GotoPos(nextI)
                destinationI = GetBufferId()
            endif
        endif
    endif
    GotoBufferId(destinationI)
    if GIMissing > 0
        Warn(Str(GIMissing) + " input file(s) could not be read.")
        GIMissing = 0
    endif
end

keydef SearchHelpKeys
    <CtrlAlt H> PROCShowResults()
end

proc Main()
    string locationsS[255] = ""
    string filenameS[255] = ""
    string resolvedS[255] = ""
    integer separatorI = 0
    integer originalI = GetBufferId()
    integer silentI = FALSE
    silentI = Lower(GetProfileStr("searchhelptse", "silent", "false", "searchhelptse.ini")) == "true"
    GSPattern = GetProfileStr("searchhelptse", "searchstring", "", "searchhelptse.ini")
    GSOptions = GetProfileStr("searchhelptse", "searchoptions", "ix", "searchhelptse.ini")
    locationsS = GetProfileStr("searchhelptse", "searchlocations", "tsehelp.s", "searchhelptse.ini")
    if not silentI
        Warn("SEARCHHELPTSE 1.0.0.0.2 (GPT-6): search help files; Enter opens a selected hit.")
    endif
    if not Ask("Search string:", GSPattern, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("Search options (e.g. ix):", GSOptions, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("Files to search (semicolon separated):", locationsS, _EDIT_HISTORY_)
        return()
    endif
    if GSPattern == "" or locationsS == ""
        Warn("Enter a search string and at least one file.")
        return()
    endif
    GSOptions = Lower(GSOptions)
    if Pos("a", GSOptions) or Pos("b", GSOptions) or Pos("g", GSOptions) or Pos("l", GSOptions) or Pos("v", GSOptions) or Pos("c", GSOptions) or Pos("+", GSOptions)
        Warn("Use only forward single-file search options such as i, x or w.")
        return()
    endif
    if GIHasResults
        GotoBufferId(GIMap)
        AbandonFile()
        GotoBufferId(GIResults)
        AbandonFile()
        GotoBufferId(originalI)
        GIHasResults = FALSE
    endif
    GIResults = CreateTempBuffer()
    if GIResults == 0
        Warn("Could not create a results buffer.")
        return()
    endif
    GIMap = CreateTempBuffer()
    if GIMap == 0
        GotoBufferId(GIResults)
        AbandonFile()
        GotoBufferId(originalI)
        Warn("Could not create a selection buffer.")
        return()
    endif
    GICount = 0
    GIMissing = 0
    while locationsS <> ""
        separatorI = Pos(";", locationsS)
        if separatorI == 0
            filenameS = Trim(locationsS)
            locationsS = ""
        else
            filenameS = Trim(SubStr(locationsS, 1, separatorI - 1))
            locationsS = SubStr(locationsS, separatorI + 1, 255)
        endif
        if filenameS <> ""
            resolvedS = FNResolveFile(filenameS)
            if resolvedS == ""
                GotoBufferId(GIMap)
                AbandonFile()
                GotoBufferId(GIResults)
                AbandonFile()
                GotoBufferId(originalI)
                Disable(SearchHelpKeys)
                Warn("SEARCHHELPTSE: File not found: " + filenameS)
                return()
            endif
            PROCSearchFile(resolvedS)
        endif
    endwhile
    if GICount == 0
        GotoBufferId(GIResults)
        EndFile()
        AddLine("No matches found.")
    endif
    GIHasResults = TRUE
    Enable(SearchHelpKeys)
    PROCShowResults()
end
