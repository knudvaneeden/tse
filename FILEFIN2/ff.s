// FILEFIN2 - recursive Win32 file finder for TSE Pro
// Version : 1.0.0.0.13
// Date    : 2026-09-08
// LLM     : OpenAI Codex
//
// TSE 4.50 / Windows 11 port using ff.dll and zip.dll.

string cTmpLine[255]
string searchInput[255]
string startPath[255]
string fileToFind[80]
string file_date[8]
string file_time[8]
integer lLookInZip = TRUE
integer origId
integer resultCount = 0

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
    "Search Zip Files?", , Divide
    "&Yes", PROCSetZip(TRUE)
    "&No",  PROCSetZip(FALSE)
end

proc PROCParseSearchInput(string inputS)
    string normalizedS[255] = ""
    integer indexI = 1
    integer lengthI = Length(inputS)
    integer lastSeparatorI = 0

    repeat
        if (Asc(inputS[indexI]) <> 34)
            case inputS[indexI]
                when "/"
                    normalizedS = normalizedS + "\"
                    lastSeparatorI = Length(normalizedS)
                when "\"
                    normalizedS = normalizedS + "\"
                    lastSeparatorI = Length(normalizedS)
                when ":"
                    normalizedS = normalizedS + ":"
                    if (Length(normalizedS) == 2)
                        lastSeparatorI = Length(normalizedS)
                    endif
                otherwise
                    normalizedS = normalizedS + inputS[indexI]
            endcase
        endif
        indexI = indexI + 1
    until (indexI > lengthI)

    if (lastSeparatorI)
        startPath = SubStr(normalizedS, 1, lastSeparatorI)
        fileToFind = SubStr(normalizedS, lastSeparatorI + 1,
                            Length(normalizedS) - lastSeparatorI)
    else
        startPath = "\"
        fileToFind = normalizedS
    endif

    if (not Length(fileToFind))
        fileToFind = "*.*"
    endif
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
                cTmpLine = Format(sizeI:9, dateS:10, timeS:10,
                                  "  ", nameS, "  <-  ", pathS)
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
            Message(pathS)

            if (FF_TreeMatches(stateS))
                file_date = ""
                file_time = ""
                FF_TreeGetDate(stateS, file_date)
                FF_TreeGetTime(stateS, file_time)
                cTmpLine = Format(FF_TreeGetSize(stateS):9,
                                  file_date:-10,
                                  file_time:-10,
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

proc Main()
    if (Ask("Enter path and file mask (*, .*, ?):", searchInput, _EDIT_HISTORY_) and Length(searchInput))
        PROCParseSearchInput(searchInput)
        fileToFind = Upper(fileToFind)
        ZipSearch()

        origId = CreateTempBuffer()
        GotoBufferId(origId)
        EmptyBuffer()
        AddLine(Format("FILEFIN2 results for: ", searchInput), origId)
        AddLine(Format("Starting directory: ", startPath), origId)
        AddLine(Format("File mask: ", fileToFind), origId)
        AddLine("", origId)
        resultCount = 0

        PROCSearchTree()
        UpdateDisplay(_DEFAULT_)

        if (not resultCount)
            AddLine("No matching files were found.", origId)
        endif
        GotoBufferId(origId)
        GotoLine(1)
        GotoColumn(1)
    endif
end

<CtrlAltShift F> Main()
