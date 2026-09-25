// SEARCHFILEEXECMACROINCLUDE 1.0.0.0.7 - GPT-6 (OpenAI)
// Depth-first, source-order search of SAL include/macro references.
string GSPattern[255] = ""
string GSOptions[40] = ""
string GSDirectories[255] = ""
integer GIVisited = 0
integer GIOriginal = 0
integer GIBlockComment = FALSE
string GSMacroDir[255] = ""
integer GIResults = 0
integer GICount = 0
integer GISkipped = 0

string proc FNTrim(string sourceS)
    return(Trim(sourceS))
end

string proc FNResolve(string nameS, string parentS, integer macroI)
    string candidateS[255] = ""
    string pathS[255] = ""
    string entryS[255] = ""
    string listS[255] = ""
    integer cutI = 0
    string localS[255] = FNTrim(nameS)
    if localS == ""
        return("")
    endif
    if macroI
        if Lower(SplitPath(localS, _EXT_)) == ".mac"
            localS = SplitPath(localS, _DRIVE_ | _PATH_ | _NAME_) + ".s"
        elseif SplitPath(localS, _EXT_) == ""
            localS = localS + ".s"
        endif
    endif
    if SplitPath(localS, _DRIVE_ | _PATH_) <> ""
        if FileExists(localS)
            return(ExpandPath(localS))
        endif
        return("")
    endif
    candidateS = GSMacroDir + localS
    if FileExists(candidateS)
        return(ExpandPath(candidateS))
    endif
    candidateS = SplitPath(parentS, _DRIVE_ | _PATH_) + localS
    if FileExists(candidateS)
        return(ExpandPath(candidateS))
    endif
    listS = GSDirectories
    while listS <> ""
        cutI = Pos(";", listS)
        if cutI == 0
            entryS = FNTrim(listS)
            listS = ""
        else
            entryS = FNTrim(SubStr(listS, 1, cutI - 1))
            listS = SubStr(listS, cutI + 1, 255)
        endif
        if entryS <> ""
            pathS = AddTrailingSlash(entryS)
            candidateS = pathS + localS
            if FileExists(candidateS)
                return(ExpandPath(candidateS))
            endif
        endif
    endwhile
    if macroI
        // TSE's macro order: current dir, each TSEPath dir and its MAC
        // subdir, then LoadDir() and its MAC subdir.
        candidateS = SearchPath(localS, Query(TSEPath), "mac")
    else
        candidateS = SearchPath(localS, Query(TSEPath), ".")
    endif
    if candidateS <> "" and FileExists(candidateS)
        return(ExpandPath(candidateS))
    endif
    return("")
end

string proc FNReference(string lineS, integer macroI)
    string restS[255] = ""
    integer startI = 0
    integer finishI = 0
    if macroI
        startI = Pos("EXECMACRO(", Upper(lineS))
        if startI == 0
            startI = Pos("PROCMACRORUNPURGE(", Upper(lineS))
        endif
        if startI == 0
            startI = Pos("PROCMACRORUNKEEP(", Upper(lineS))
        endif
    else
        startI = Pos("#INCLUDE", Upper(lineS))
    endif
    if startI == 0
        return("")
    endif
    restS = SubStr(lineS, startI, 255)
    startI = Pos('"', restS)
    if startI == 0
        return("")
    endif
    restS = SubStr(restS, startI + 1, 255)
    finishI = Pos('"', restS)
    if finishI < 2
        return("")
    endif
    restS = SubStr(restS, 1, finishI - 1)
    if macroI
        startI = Pos(" ", restS)
        if startI == 0
            startI = Pos(Chr(9), restS)
        endif
        if startI > 0
            restS = SubStr(restS, 1, startI - 1)
        endif
    endif
    return(restS)
end

string proc FNCode(string lineS)
    string resultS[255] = ""
    string charS[1] = ""
    string nextS[1] = ""
    integer positionI = 1
    integer quotedI = FALSE
    integer escapedI = FALSE
    integer lineCommentI = FALSE
    while positionI <= Length(lineS)
        charS = SubStr(lineS, positionI, 1)
        nextS = SubStr(lineS, positionI + 1, 1)
        if lineCommentI
            resultS = resultS + " "
        elseif GIBlockComment
            if charS == "*" and nextS == "/"
                GIBlockComment = FALSE
                resultS = resultS + "  "
                positionI = positionI + 1
            else
                resultS = resultS + " "
            endif
        elseif quotedI
            resultS = resultS + charS
            if escapedI
                escapedI = FALSE
            elseif charS == Chr(92)
                escapedI = TRUE
            elseif charS == '"'
                quotedI = FALSE
            endif
        elseif charS == '"'
            quotedI = TRUE
            resultS = resultS + charS
        elseif charS == "/" and nextS == "/"
            lineCommentI = TRUE
            resultS = resultS + " "
        elseif charS == "/" and nextS == "*"
            GIBlockComment = TRUE
            resultS = resultS + "  "
            positionI = positionI + 1
        else
            resultS = resultS + charS
        endif
        positionI = positionI + 1
    endwhile
    return(resultS)
end

proc PROCOutput(string messageS)
    integer previousI = GetBufferId()
    GotoBufferId(GIResults)
    EndFile()
    AddLine(messageS)
    GotoBufferId(previousI)
end

proc PROCProgress(string filenameS)
    integer previousI = GetBufferId()
    GotoBufferId(GIOriginal)
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    UnBufferVideo()
    Message("Searching: " + filenameS)
    BufferVideo()
    GotoBufferId(previousI)
end

proc PROCWalk(string filenameS, integer depthI)
    integer sourceI = 0
    integer cleanI = 0
    integer lineI = 0
    integer maximumI = 0
    integer hitLineI = 0
    integer hitPosI = 0
    integer visitI = 0
    integer seenI = FALSE
    integer previousI = GetBufferId()
    string lineS[255] = ""
    string codeS[255] = ""
    string childS[255] = ""
    string resolvedS[255] = ""
    if depthI > 24
        PROCOutput("SKIPPED (depth limit): " + filenameS)
        GISkipped = GISkipped + 1
        return()
    endif
    GotoBufferId(GIVisited)
    visitI = 1
    while visitI <= NumLines() and not seenI
        GotoLine(visitI)
        if Lower(GetText(1, 255)) == Lower(filenameS)
            seenI = TRUE
        endif
        visitI = visitI + 1
    endwhile
    if seenI
        GotoBufferId(previousI)
        return()
    endif
    EndFile()
    AddLine(filenameS)
    sourceI = CreateTempBuffer()
    if sourceI == 0
        GotoBufferId(previousI)
        GISkipped = GISkipped + 1
        return()
    endif
    BufferType(_HIDDEN_)
    PROCProgress(filenameS)
    if not LoadBuffer(filenameS)
        PROCOutput("MISSING: " + filenameS)
        GISkipped = GISkipped + 1
        GotoBufferId(sourceI)
        AbandonFile()
        GotoBufferId(previousI)
        return()
    endif
    maximumI = NumLines()
    cleanI = CreateTempBuffer()
    if cleanI == 0
        GotoBufferId(sourceI)
        AbandonFile()
        GotoBufferId(previousI)
        GISkipped = GISkipped + 1
        return()
    endif
    BufferType(_HIDDEN_)
    GIBlockComment = FALSE
    lineI = 1
    while lineI <= maximumI
        GotoBufferId(sourceI)
        GotoLine(lineI)
        lineS = GetText(1, 255)
        codeS = FNCode(lineS)
        GotoBufferId(cleanI)
        EndFile()
        AddLine(codeS)
        lineI = lineI + 1
    endwhile
    GotoBufferId(cleanI)
    if maximumI > 0
        BegFile()
        if Find(GSPattern, GSOptions)
            hitLineI = CurrLine()
            hitPosI = CurrPos()
        endif
    endif
    lineI = 1
    while lineI <= maximumI
        GotoBufferId(cleanI)
        GotoLine(lineI)
        codeS = GetText(1, 255)
        GotoBufferId(sourceI)
        GotoLine(lineI)
        lineS = GetText(1, 255)
        while hitLineI == lineI
            PROCOutput(filenameS + "(" + Str(lineI) + "," + Str(hitPosI) + "): " + lineS)
            GICount = GICount + 1
            GotoBufferId(cleanI)
            GotoLine(hitLineI)
            GotoPos(hitPosI)
            hitLineI = 0
            if Find(GSPattern, GSOptions + "+")
                hitLineI = CurrLine()
                hitPosI = CurrPos()
            endif
        endwhile
        childS = FNReference(codeS, FALSE)
        if childS <> ""
            resolvedS = FNResolve(childS, filenameS, FALSE)
            if resolvedS == ""
                PROCOutput("UNRESOLVED from " + filenameS + "(" + Str(lineI) + "): " + childS)
                GISkipped = GISkipped + 1
            else
                PROCWalk(resolvedS, depthI + 1)
            endif
        endif
        childS = FNReference(codeS, TRUE)
        if childS <> ""
            resolvedS = FNResolve(childS, filenameS, TRUE)
            if resolvedS == ""
                PROCOutput("UNRESOLVED source from " + filenameS + "(" + Str(lineI) + "): " + childS)
                GISkipped = GISkipped + 1
            else
                PROCWalk(resolvedS, depthI + 1)
            endif
        endif
        lineI = lineI + 1
    endwhile
    GotoBufferId(cleanI)
    AbandonFile()
    GotoBufferId(sourceI)
    AbandonFile()
    GotoBufferId(previousI)
end

proc Main()
    string filenameS[255] = ""
    string pathS[255] = ""
    integer silentI = FALSE
    integer visitI = 1
    GIOriginal = GetBufferId()
    silentI = Lower(GetProfileStr("searchfileexecmacroinclude", "silent", "false", "searchfileexecmacroinclude.ini")) == "true"
    GSPattern = GetProfileStr("SearchDefaults", "searchstring", "", "searchfileexecmacroinclude.ini")
    GSOptions = GetProfileStr("SearchDefaults", "searchoptions", "", "searchfileexecmacroinclude.ini")
    filenameS = GetProfileStr("SearchDefaults", "searchfilename", "", "searchfileexecmacroinclude.ini")
    GSDirectories = GetProfileStr("SearchDefaults", "additionaldirectories", "", "searchfileexecmacroinclude.ini")
    if not silentI
        Warn("SEARCHFILEEXECMACROINCLUDE 1.0.0.0.7 (GPT-6): search a file and its SAL includes/macro sources recursively.")
    endif
    if not Ask("TSE search expression:", GSPattern, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("Search options (e.g. ix):", GSOptions, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("Input filename:", filenameS, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("Optional additional directories to search in (semi colon ';' separated):", GSDirectories, _EDIT_HISTORY_)
        return()
    endif
    if GSPattern == ""
        Warn("The search expression is empty.")
        return()
    endif
    // Force regular expressions and prevent global, backward, all-buffers,
    // and wrap options from escaping the currently scanned source file.
    GSOptions = Lower(GSOptions)
    if Pos("x", GSOptions) == 0
        GSOptions = GSOptions + "x"
    endif
    if Pos("a", GSOptions) or Pos("b", GSOptions) or Pos("g", GSOptions) or Pos("v", GSOptions)
        Warn("Options a, b, g and v are incompatible with source-order traversal.")
        return()
    endif
    GSMacroDir = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    pathS = FNResolve(filenameS, GSMacroDir, FALSE)
    if pathS == ""
        Warn("Input file not found: " + filenameS)
        return()
    endif
    BufferVideo()
    GIResults = CreateBuffer("[Search results - searchfileexecmacroinclude]", _NORMAL_)
    if GIResults == 0
        UnBufferVideo()
        Warn("Close the previous search results buffer and try again.")
        GotoBufferId(GIOriginal)
        return()
    endif
    GotoBufferId(GIOriginal)
    GIVisited = CreateTempBuffer()
    if GIVisited == 0
        UnBufferVideo()
        Warn("Could not allocate a visited-files buffer.")
        GotoBufferId(GIOriginal)
        return()
    endif
    GotoBufferId(GIOriginal)
    PROCOutput("SEARCHFILEEXECMACROINCLUDE 1.0.0.0.7 | " + GSPattern + " | " + GSOptions)
    PROCWalk(pathS, 0)
    PROCOutput("Matches: " + Str(GICount) + "   Unresolved/skipped: " + Str(GISkipped))
    // Load every searched source into the normal TSE file ring.
    GotoBufferId(GIVisited)
    while visitI <= NumLines()
        GotoLine(visitI)
        filenameS = GetText(1, 255)
        if filenameS <> ""
            EditFile(filenameS, _DONT_PROMPT_)
        endif
        GotoBufferId(GIVisited)
        visitI = visitI + 1
    endwhile
    GotoBufferId(GIVisited)
    AbandonFile()
    GotoBufferId(GIResults)
    BegFile()
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    UnBufferVideo()
    Message("Search complete: " + Str(GICount) + " matches.")
end
