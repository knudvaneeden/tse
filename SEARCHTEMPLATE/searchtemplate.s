/*****************************************************************************
  Filename: searchtemplate.s
  Version:  1.0.0.0.3
  Date:     2026-09-17
  Time:     20:05:20 UTC
  LLM:      OpenAI GPT-5 Codex

  Searches a SemWare template.dat file by abbreviation and file extension.
  Search option "i" ignores case. Search option "x" enables TSE regular
  expression syntax. Search option "w" searches for a complete word. A
  template with a blank extension is valid for all extensions.
*****************************************************************************/

string GSVersionText[10] = "1.0.0.0.3"
#define HEADER_COUNT_COL 1
#define HEADER_COUNT_LEN 4
#define HEADER_EXT_COL 5
#define HEADER_EXT_LEN 13
#define HEADER_ABBR_COL 18
#define MAX_TEXT_LEN 255

string proc PROCReadIniValue(string iniFilenameS, string keyNameS)
    integer oldBufferI = GetBufferId()
    integer iniBufferI = 0
    integer equalsI = 0
    string lineS[MAX_TEXT_LEN] = ""
    string resultS[MAX_TEXT_LEN] = ""

    iniBufferI = CreateTempBuffer()
    if iniBufferI
        GotoBufferId(iniBufferI)
        if InsertFile(iniFilenameS, _DONT_PROMPT_)
            BegFile()
            loop
                lineS = Trim(GetText(1, MAX_TEXT_LEN))
                equalsI = Pos("=", lineS)
                if equalsI > 0
                    if Upper(Trim(SubStr(lineS, 1, equalsI - 1))) == Upper(keyNameS)
                        resultS = Trim(SubStr(lineS, equalsI + 1, MAX_TEXT_LEN))
                        break
                    endif
                endif
                if not Down()
                    break
                endif
            endloop
        endif
        AbandonFile(iniBufferI)
    endif
    GotoBufferId(oldBufferI)
    return (resultS)
end

string proc PROCMakeSearchOptions(string userOptionsS)
    string resultS[8] = ""

    if Pos("i", userOptionsS) or Pos("I", userOptionsS)
        resultS = resultS + "i"
    endif
    if Pos("x", userOptionsS) or Pos("X", userOptionsS)
        resultS = resultS + "x"
    endif
    if Pos("w", userOptionsS) or Pos("W", userOptionsS)
        resultS = resultS + "w"
    endif
    return (resultS)
end

integer proc PROCAbbreviationMatches(integer searchBufferI,
                                     string abbreviationS,
                                     string searchTextS,
                                     string searchOptionsS)
    integer oldBufferI = GetBufferId()
    integer foundI = FALSE

    GotoBufferId(searchBufferI)
    EmptyBuffer()
    AddLine(abbreviationS)
    BegFile()
    BegLine()
    foundI = lFind(searchTextS, searchOptionsS)
    GotoBufferId(oldBufferI)
    return (foundI)
end

proc Main()
    integer originalBufferI = GetBufferId()
    integer templateBufferI = 0
    integer resultBufferI = 0
    integer searchBufferI = 0
    integer bodyLinesI = 0
    integer bodyIndexI = 0
    integer headerLineI = 0
    integer matchesI = 0
    integer successI = FALSE
    string macroDirS[MAX_TEXT_LEN] = ""
    string iniFilenameS[MAX_TEXT_LEN] = ""
    string templateFilenameS[MAX_TEXT_LEN] = ""
    string searchTextS[MAX_TEXT_LEN] = ""
    string userOptionsS[16] = ""
    string searchOptionsS[8] = ""
    string wantedExtS[32] = ""
    string templateExtS[32] = ""
    string abbreviationS[MAX_TEXT_LEN] = ""
    string finalMessageS[MAX_TEXT_LEN] = "Search cancelled."

    macroDirS = SplitPath(CurrMacroFileName(), _DRIVE_|_PATH_)
    iniFilenameS = macroDirS + "searchtemplate.ini"
    templateFilenameS = PROCReadIniValue(iniFilenameS, "template")
    searchTextS = PROCReadIniValue(iniFilenameS, "searchstring")
    userOptionsS = PROCReadIniValue(iniFilenameS, "searchoption")
    wantedExtS = PROCReadIniValue(iniFilenameS, "searchfileextension")

    if Ask("Full path to template.dat:", templateFilenameS, _EDIT_HISTORY_)
        if Ask("Abbreviation search string:", searchTextS, _EDIT_HISTORY_)
            if Ask("Search options (i=ignore case, x=regular expression, w=word):", userOptionsS, _EDIT_HISTORY_)
                if Ask("File extension (for example .java):", wantedExtS, _EDIT_HISTORY_)
                    searchTextS = Trim(searchTextS)
                    wantedExtS = Trim(wantedExtS)
                    if wantedExtS <> "" and wantedExtS[1] <> "."
                        wantedExtS = "." + wantedExtS
                    endif
                    searchOptionsS = PROCMakeSearchOptions(userOptionsS)

                    templateBufferI = CreateTempBuffer()
                    resultBufferI = CreateTempBuffer()
                    searchBufferI = CreateTempBuffer()

                    if templateBufferI and resultBufferI and searchBufferI
                        GotoBufferId(templateBufferI)
                        if InsertFile(templateFilenameS, _DONT_PROMPT_)
                            GotoBufferId(resultBufferI)
                            AddLine("SEARCHTEMPLATE results")
                            AddLine("Version: " + GSVersionText)
                            AddLine("Template file: " + templateFilenameS)
                            AddLine("Abbreviation search: " + searchTextS)
                            AddLine("Options: " + searchOptionsS)
                            AddLine("File extension: " + wantedExtS)
                            AddLine("")

                            GotoBufferId(templateBufferI)
                            if NumLines() > 1
                                GotoLine(2)
                                loop
                                    bodyLinesI = Val(GetText(HEADER_COUNT_COL, HEADER_COUNT_LEN))
                                    if bodyLinesI < 1
                                        break
                                    endif
                                    templateExtS = Trim(GetText(HEADER_EXT_COL, HEADER_EXT_LEN))
                                    abbreviationS = Trim(GetText(HEADER_ABBR_COL, MAX_TEXT_LEN))
                                    headerLineI = CurrLine()

                                    if templateExtS == "" or Upper(templateExtS) == Upper(wantedExtS)
                                        if PROCAbbreviationMatches(searchBufferI, abbreviationS,
                                                                   searchTextS, searchOptionsS)
                                            matchesI = matchesI + 1
                                            AddLine("Abbreviation: " + abbreviationS, resultBufferI)
                                            if templateExtS == ""
                                                AddLine("Extension: <all>", resultBufferI)
                                            else
                                                AddLine("Extension: " + templateExtS, resultBufferI)
                                            endif
                                            AddLine("Body lines: " + Str(bodyLinesI), resultBufferI)
                                            bodyIndexI = 1
                                            while bodyIndexI <= bodyLinesI
                                                GotoBufferId(templateBufferI)
                                                GotoLine(headerLineI + bodyIndexI)
                                                AddLine(GetText(1, MAX_TEXT_LEN), resultBufferI)
                                                bodyIndexI = bodyIndexI + 1
                                            endwhile
                                            AddLine("", resultBufferI)
                                            GotoBufferId(templateBufferI)
                                        endif
                                    endif

                                    GotoLine(headerLineI + bodyLinesI + 1)
                                    if CurrLine() <= headerLineI or CurrLine() > NumLines()
                                        break
                                    endif
                                endloop
                            endif

                            GotoBufferId(resultBufferI)
                            AddLine("Matches: " + Str(matchesI))
                            BegFile()
                            successI = TRUE
                            finalMessageS = Str(matchesI) + " matching template(s) found."
                        else
                            finalMessageS = "Cannot read template file: " + templateFilenameS
                        endif
                    else
                        finalMessageS = "Not enough memory to create search buffers."
                    endif
                endif
            endif
        endif
    endif

    if templateBufferI
        AbandonFile(templateBufferI)
    endif
    if searchBufferI
        AbandonFile(searchBufferI)
    endif
    if not successI
        if resultBufferI
            AbandonFile(resultBufferI)
        endif
        GotoBufferId(originalBufferI)
    endif
    Warn(finalMessageS)
end
