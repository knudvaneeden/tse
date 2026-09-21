/*****************************************************************************
  SEARCHCOMPILE

  Search compiler definitions in a SemWare/TSE compile.dat file.

  Version : 1.0.0.0.6
  Date    : 2026-09-21
  Time    : 19:03:11 CEST
  LLM     : OpenAI GPT-5 Codex

  Keep searchcompile.s and searchcompile.ini in the same directory.
*****************************************************************************/

#define RECORD_START 30
#define RECORD_END   31

string GSVersionText[]   = "1.0.0.0.6"
string GSIniName[]       = "searchcompile.ini"
string GSDataEye[]       = "Semware compile macro data file"
string GSCompileDat[255] = ""
string GSSearch[255]     = "Borland"
string GSOptions[20]     = "ix"
string GSExtension[40]   = ".c"
integer GIField          = 1

proc PROCReadLine(var string lineS)
    lineS = GetText(1, CurrLineLen())
    Down()
end

string proc FNIniValue(string keyS, string defaultS)
    string lineS[255]
    integer equalsI

    BegFile()
    repeat
        lineS = GetText(1, CurrLineLen())
        equalsI = Pos("=", lineS)
        if equalsI > 0
            if Lower(Trim(SubStr(lineS, 1, equalsI - 1))) == Lower(keyS)
                return(Trim(SubStr(lineS, equalsI + 1, 255)))
            endif
        endif
    until not Down()
    return(defaultS)
end

proc PROCReadIni()
    string iniS[255]
    integer oldBufferI, iniBufferI

    iniS = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + GSIniName
    if FileExists(iniS)
        oldBufferI = GetBufferId()
        iniBufferI = CreateTempBuffer()
        if iniBufferI
            if InsertFile(iniS, _DONT_PROMPT_)
                GSCompileDat = FNIniValue("compile_dat", GSCompileDat)
                GSSearch     = FNIniValue("search_string", GSSearch)
                GSOptions    = FNIniValue("search_options", GSOptions)
                GSExtension  = FNIniValue("file_extension", GSExtension)
            endif
            GotoBufferId(oldBufferI)
            AbandonFile(iniBufferI)
        endif
    endif

    if GSCompileDat == ""
        GSCompileDat = LoadDir() + "compile.dat"
    endif
end

proc PROCSetSearchField(integer fieldI)
    GIField = fieldI
end

menu SearchFieldMenu()
    title = "Select compile option field"
    history = GIField
    command = PROCSetSearchField(MenuOption())

    "Compiler Extension"    , , CloseBefore
    "Compiler Description"  , , CloseBefore
    "Compiler Command"      , , CloseBefore
    "Compiler Output"       , , CloseBefore
    "Compiler Rules"        , , CloseBefore
    "Error"                 , , CloseBefore
    "Error Options"         , , CloseBefore
    "Filename"              , , CloseBefore
    "Filename Options"      , , CloseBefore
    "Filename Tag"          , , CloseBefore
    "Line"                  , , CloseBefore
    "Line Options"          , , CloseBefore
    "Line Tag"              , , CloseBefore
    "Column"                , , CloseBefore
    "Column Options"        , , CloseBefore
    "Column Tag"            , , CloseBefore
    "Message"               , , CloseBefore
    "Message Options"       , , CloseBefore
    "Message Tag"           , , CloseBefore
end

string proc FNFieldName(integer fieldI)
    case fieldI
        when 1  return("Compiler Extension")
        when 2  return("Compiler Description")
        when 3  return("Compiler Command")
        when 4  return("Compiler Output")
        when 5  return("Compiler Rules")
        when 6  return("Error")
        when 7  return("Error Options")
        when 8  return("Filename")
        when 9  return("Filename Options")
        when 10 return("Filename Tag")
        when 11 return("Line")
        when 12 return("Line Options")
        when 13 return("Line Tag")
        when 14 return("Column")
        when 15 return("Column Options")
        when 16 return("Column Tag")
        when 17 return("Message")
        when 18 return("Message Options")
        when 19 return("Message Tag")
    endcase
    return("")
end

string proc FNOutputName(string flagsS)
    integer outputI

    if Length(flagsS) < 2
        return("")
    endif
    outputI = Asc(flagsS[2])
    case outputI
        when 1 return("Clear Screen and Prompt After Shell")
        when 2 return("Clear Screen but Don't Prompt After Shell")
        when 3 return("Don't Clear Screen or Prompt After Shell")
        when 4 return("Tee Output and Don't Prompt After Shell")
        when 5 return("Tee Output, Run Hidden and Don't Prompt After Shell")
        when 6 return("Run Hidden, Don't Clear Screen or Prompt After Shell")
    endcase
    return(Str(outputI))
end

integer proc FNMatches(string textS)
    integer tempI, foundI

    if GSSearch == ""
        return(TRUE)
    endif

    tempI = CreateTempBuffer()
    if not tempI
        return(FALSE)
    endif
    AddLine(textS)
    BegFile()
    foundI = lFind(GSSearch, GSOptions)
    AbandonFile(tempI)
    return(foundI)
end

integer proc FNExtensionMatches(string recordExtS)
    if Trim(GSExtension) == ""
        return(TRUE)
    endif
    return(Lower(recordExtS) == Lower(Trim(GSExtension)))
end

proc PROCAddResult(integer resultBufferI, string extS, string descS,
                   string valueS, integer recordLineI)
    GotoBufferId(resultBufferI)
    AddLine(Format(recordLineI:6, "  ", extS:-12, "  ", descS))
    AddLine("        " + FNFieldName(GIField) + ": " + valueS)
    AddLine("")
end

proc PROCSearch(integer dataBufferI, integer resultBufferI)
    string startS[40]            = ""
    string extS[40]              = ""
    string descS[255]            = ""
    string flagsS[20]            = ""
    string commandS[255]         = ""
    string errorS[255]           = ""
    string errorOptionsS[40]     = ""
    string errorTagS[40]         = ""
    string filenameS[255]        = ""
    string filenameOptionsS[40]  = ""
    string filenameTagS[40]      = ""
    string lineS[255]            = ""
    string lineOptionsS[40]      = ""
    string lineTagS[40]          = ""
    string columnS[255]          = ""
    string columnOptionsS[40]    = ""
    string columnTagS[40]        = ""
    string messageS[255]         = ""
    string messageOptionsS[40]   = ""
    string messageTagS[40]       = ""
    string ruleMacroS[255]       = ""
    string valueS[255]           = ""
    integer recordLineI

    GotoBufferId(dataBufferI)
    BegFile()
    repeat
        if GetText(1, 1) == Chr(RECORD_START)
            recordLineI = CurrLine()
            PROCReadLine(startS)
            extS = SubStr(startS, 2, 39)
            PROCReadLine(descS)
            PROCReadLine(flagsS)
            PROCReadLine(commandS)
            PROCReadLine(errorS)
            PROCReadLine(errorOptionsS)
            PROCReadLine(errorTagS)
            PROCReadLine(filenameS)
            PROCReadLine(filenameOptionsS)
            PROCReadLine(filenameTagS)
            PROCReadLine(lineS)
            PROCReadLine(lineOptionsS)
            PROCReadLine(lineTagS)
            PROCReadLine(columnS)
            PROCReadLine(columnOptionsS)
            PROCReadLine(columnTagS)
            PROCReadLine(messageS)
            PROCReadLine(messageOptionsS)
            PROCReadLine(messageTagS)
            ruleMacroS = ""
            if GetText(1, 1) <> Chr(RECORD_END)
                PROCReadLine(ruleMacroS)
            endif

            case GIField
                when 1  valueS = extS
                when 2  valueS = descS
                when 3  valueS = commandS
                when 4  valueS = FNOutputName(flagsS)
                when 5
                    valueS = errorS + " " + errorOptionsS + " " + errorTagS
                    valueS = valueS + " " + filenameS + " " + filenameOptionsS
                    valueS = valueS + " " + filenameTagS + " " + lineS
                    valueS = valueS + " " + lineOptionsS + " " + lineTagS
                    valueS = valueS + " " + columnS + " " + columnOptionsS
                    valueS = valueS + " " + columnTagS + " " + messageS
                    valueS = valueS + " " + messageOptionsS + " " + messageTagS
                    valueS = valueS + " " + ruleMacroS
                when 6  valueS = errorS
                when 7  valueS = errorOptionsS
                when 8  valueS = filenameS
                when 9  valueS = filenameOptionsS
                when 10 valueS = filenameTagS
                when 11 valueS = lineS
                when 12 valueS = lineOptionsS
                when 13 valueS = lineTagS
                when 14 valueS = columnS
                when 15 valueS = columnOptionsS
                when 16 valueS = columnTagS
                when 17 valueS = messageS
                when 18 valueS = messageOptionsS
                when 19 valueS = messageTagS
            endcase

            if FNExtensionMatches(extS) and FNMatches(valueS)
                PROCAddResult(resultBufferI, extS, descS, valueS, recordLineI)
            endif
            GotoBufferId(dataBufferI)
        endif
    until not Down()
end

proc Main()
    integer originalBufferI, dataBufferI, resultBufferI, matchesI

    PROCReadIni()

    if not Ask("Search string", GSSearch, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("Search options (i=ignore case, x=regular expression)", GSOptions, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("File extension (blank means all)", GSExtension, _EDIT_HISTORY_)
        return()
    endif
    if not Ask("Full path to compile.dat", GSCompileDat, _EDIT_HISTORY_)
        return()
    endif
    SearchFieldMenu()

    if not FileExists(GSCompileDat)
        Warn("File not found: ", GSCompileDat)
        return()
    endif

    originalBufferI = GetBufferId()
    dataBufferI = CreateTempBuffer()
    if not dataBufferI
        Warn("Unable to create the compile.dat work buffer.")
        return()
    endif
    if not InsertFile(GSCompileDat, _DONT_PROMPT_)
        GotoBufferId(originalBufferI)
        AbandonFile(dataBufferI)
        Warn("Unable to read: ", GSCompileDat)
        return()
    endif
    BegFile()
    if GetText(1, CurrLineLen()) <> GSDataEye
        GotoBufferId(originalBufferI)
        AbandonFile(dataBufferI)
        Warn("This is not a valid compile.dat file: ", GSCompileDat)
        return()
    endif

    resultBufferI = CreateTempBuffer()
    AddLine("SEARCHCOMPILE " + GSVersionText)
    AddLine("File: " + GSCompileDat)
    AddLine("Search: " + GSSearch + "   Options: " + GSOptions)
    AddLine("Extension: " + iif(Trim(GSExtension) == "", "<all>", GSExtension))
    AddLine("Field: " + FNFieldName(GIField))
    AddLine("")

    PROCSearch(dataBufferI, resultBufferI)
    GotoBufferId(resultBufferI)
    matchesI = (NumLines() - 6) / 3
    GotoLine(1)
    ChangeCurrFilename("*SEARCHCOMPILE RESULTS*", _DONT_PROMPT_)
    GotoBufferId(dataBufferI)
    AbandonFile(dataBufferI)
    GotoBufferId(resultBufferI)
    Warn(Str(matchesI), " matching compiler option(s) found.")
end
