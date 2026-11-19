// forthparser.s - 1.0.0.0.5 - 2026-11-19
// Small integer FORTH lexer, syntax parser, and semantic interpreter.
// Pure TSE SAL. The EBNF file documents the implemented syntax.

string MacroDirGS[255], IniFileGS[255], InputFileGS[255], ActionGS[20], ErrorGS[255]
string WordGS[255], RawGS[255], LastGS[255]
integer OriginalBufferGI, SourceBufferGI, TokenBufferGI, OutputBufferGI, StackBufferGI
integer TokenCountGI, StackDepthGI, FailedGB, CallDepthGI, StepCountGI
integer DefinitionCountGI

string proc FNMacroDir()
    string PromptS[255]
    integer IndexI
    PromptS = CurrMacroFilename()
    for IndexI = Length(PromptS) downto 1
        if SubStr(PromptS,IndexI,1) == Chr(92) or SubStr(PromptS,IndexI,1) == "/"
            return(SubStr(PromptS,1,IndexI))
        endif
    endfor
    return("")
end

string proc FNPath(string PathS)
    if Length(PathS) >= 2
        if SubStr(PathS,2,1) == ":"
            return(PathS)
        endif
    endif
    if SubStr(PathS,1,1) == Chr(92) or SubStr(PathS,1,1) == "/"
        return(PathS)
    endif
    return(MacroDirGS + PathS)
end

proc FNReport(string TextS)
    GotoBufferId(OutputBufferGI)
    EndFile()
    AddLine(TextS)
end

proc FNFail(string TextS)
    if not FailedGB
        ErrorGS = TextS
        FailedGB = TRUE
        FNReport("ERROR: " + TextS)
    endif
end

// Token records are line|column|text. Buffer line 1 is an explicit header.
// This makes FNToken(N) == token buffer line N+1 independent of TSE's
// behavior when AddLine() is used on a newly created empty buffer.
proc FNEmit(string TokenS, integer LineI, integer ColumnI)
    if TokenCountGI >= 12000
        FNFail("Token limit reached (12000)")
        return()
    endif
    GotoBufferId(TokenBufferGI)
    EndFile()
    AddLine(Str(LineI) + "|" + Str(ColumnI) + "|" + TokenS)
    TokenCountGI = TokenCountGI + 1
end

string proc FNToken(integer NumberI)
    string TextS[255]
    integer IndexI, BarsI
    if NumberI < 1 or NumberI > TokenCountGI
        return("")
    endif
    GotoBufferId(TokenBufferGI)
    GotoLine(NumberI + 1)
    TextS = GetText(1,255)
    BarsI = 0
    for IndexI = 1 to Length(TextS)
        if SubStr(TextS,IndexI,1) == "|"
            BarsI = BarsI + 1
            if BarsI == 2
                return(SubStr(TextS,IndexI+1,255))
            endif
        endif
    endfor
    return("")
end

string proc FNTokenLocation(integer NumberI)
    string TextS[255]
    integer IndexI, BarsI
    GotoBufferId(TokenBufferGI)
    GotoLine(NumberI + 1)
    TextS = GetText(1,255)
    BarsI = 0
    for IndexI = 1 to Length(TextS)
        if SubStr(TextS,IndexI,1) == "|"
            BarsI = BarsI + 1
            if BarsI == 2
                return(SubStr(TextS,1,IndexI-1))
            endif
        endif
    endfor
    return("?:?")
end

integer proc FNWhite(string CharacterS)
    return(CharacterS == " " or CharacterS == Chr(9) or CharacterS == Chr(10) or CharacterS == Chr(13))
end

proc FNLex()
    integer LineI, PositionI, FirstI, StopI, InCommentB
    string TextS[255], CharacterS[1], TokenS[255]
    InCommentB = FALSE
    GotoBufferId(SourceBufferGI)
    for LineI = 1 to NumLines()
        GotoBufferId(SourceBufferGI)
        GotoLine(LineI)
        TextS = GetText(1,255)
        PositionI = 1
        while PositionI <= Length(TextS) and not FailedGB
            CharacterS = SubStr(TextS,PositionI,1)
            if InCommentB
                if CharacterS == ")"
                    InCommentB = FALSE
                endif
                PositionI = PositionI + 1
            elseif FNWhite(CharacterS)
                PositionI = PositionI + 1
            elseif CharacterS == Chr(92)
                PositionI = Length(TextS) + 1
            elseif CharacterS == "("
                InCommentB = TRUE
                PositionI = PositionI + 1
            elseif CharacterS == ":" or CharacterS == ";"
                FNEmit(CharacterS,LineI,PositionI)
                PositionI = PositionI + 1
            elseif SubStr(TextS,PositionI,2) == '."'
                FirstI = PositionI + 2
                StopI = FirstI
                while StopI <= Length(TextS) and SubStr(TextS,StopI,1) <> '"'
                    StopI = StopI + 1
                endwhile
                if StopI > Length(TextS)
                    FNFail("Unterminated string at " + Str(LineI) + ":" + Str(PositionI))
                else
                    FNEmit("@STRING@" + SubStr(TextS,FirstI,StopI-FirstI),LineI,PositionI)
                    PositionI = StopI + 1
                endif
            else
                FirstI = PositionI
                while PositionI <= Length(TextS)
                    CharacterS = SubStr(TextS,PositionI,1)
                    if FNWhite(CharacterS) or CharacterS == ":" or CharacterS == ";" or CharacterS == Chr(92) or CharacterS == "("
                        break
                    endif
                    PositionI = PositionI + 1
                endwhile
                TokenS = SubStr(TextS,FirstI,PositionI-FirstI)
                FNEmit(TokenS,LineI,FirstI)
            endif
        endwhile
    endfor
    if InCommentB and not FailedGB
        FNFail("Unterminated parenthesized comment")
    endif
end

integer proc FNIsNumber(string TextS)
    integer IndexI, FirstI
    FirstI = 1
    if SubStr(TextS,1,1) == "-" or SubStr(TextS,1,1) == "+"
        FirstI = 2
    endif
    if Length(TextS) < FirstI
        return(FALSE)
    endif
    for IndexI = FirstI to Length(TextS)
        if SubStr(TextS,IndexI,1) < "0" or SubStr(TextS,IndexI,1) > "9"
            return(FALSE)
        endif
    endfor
    return(TRUE)
end

// Definition lookup returns the first token of its body (after the name).
integer proc FNDefinition(string NameS)
    integer IndexI
    IndexI = 1
    while IndexI <= TokenCountGI
        if FNToken(IndexI) == ":" and Upper(FNToken(IndexI+1)) == Upper(NameS)
            return(IndexI+2)
        endif
        IndexI = IndexI + 1
    endwhile
    return(0)
end

// Parser: definition := ':' name { item } ';'; top level executes items.
// A definition body may contain integers, strings, and names; no nested ':'.
proc FNParse()
    integer IndexI, InsideDefinitionB
    string TokenS[255], NameS[255]
    IndexI = 1
    InsideDefinitionB = FALSE
    while IndexI <= TokenCountGI and not FailedGB
        TokenS = FNToken(IndexI)
        if TokenS == ":"
            if InsideDefinitionB
                FNFail("Nested definition at " + FNTokenLocation(IndexI))
            elseif IndexI == TokenCountGI
                FNFail("Missing word name at " + FNTokenLocation(IndexI))
            elseif FNToken(IndexI+1) == ";" or FNToken(IndexI+1) == ":"
                FNFail("Invalid word name at " + FNTokenLocation(IndexI+1))
            else
                NameS = FNToken(IndexI+1)
                if FNIsNumber(NameS)
                    FNFail("Numeric word name at " + FNTokenLocation(IndexI+1))
                elseif FNDefinition(NameS) <> IndexI+2
                    FNFail("Duplicate definition: " + NameS)
                else
                    InsideDefinitionB = TRUE
                    DefinitionCountGI = DefinitionCountGI + 1
                    IndexI = IndexI + 1
                endif
            endif
        elseif TokenS == ";"
            if not InsideDefinitionB
                FNFail("Unexpected ; at " + FNTokenLocation(IndexI))
            else
                InsideDefinitionB = FALSE
            endif
        endif
        IndexI = IndexI + 1
    endwhile
    if InsideDefinitionB and not FailedGB
        FNFail("Missing ; at end of definition")
    endif
end

proc FNPush(integer NumberI)
    if StackDepthGI >= 1024
        FNFail("Stack overflow")
        return()
    endif
    GotoBufferId(StackBufferGI)
    EndFile()
    AddLine(Str(NumberI))
    StackDepthGI = StackDepthGI + 1
end

integer proc FNPop()
    integer NumberI
    if StackDepthGI < 1
        FNFail("Stack underflow")
        return(0)
    endif
    GotoBufferId(StackBufferGI)
    GotoLine(StackDepthGI+1)
    NumberI = Val(GetText(1,255))
    DelLine()
    StackDepthGI = StackDepthGI - 1
    return(NumberI)
end

integer proc FNPeek()
    if StackDepthGI < 1
        FNFail("Stack underflow")
        return(0)
    endif
    GotoBufferId(StackBufferGI)
    GotoLine(StackDepthGI+1)
    return(Val(GetText(1,255)))
end

// Find matching ELSE or THEN for a false IF / taken ELSE.
integer proc FNSkipBranch(integer StartI, integer SkipElseB)
    integer IndexI, NestedDepthI
    string TokenS[255]
    NestedDepthI = 0
    for IndexI = StartI to TokenCountGI
        TokenS = Upper(FNToken(IndexI))
        if TokenS == "IF"
            NestedDepthI = NestedDepthI + 1
        elseif TokenS == "THEN"
            if NestedDepthI == 0
                return(IndexI+1)
            endif
            NestedDepthI = NestedDepthI - 1
        elseif TokenS == "ELSE" and NestedDepthI == 0 and not SkipElseB
            return(IndexI+1)
        endif
    endfor
    FNFail("Unmatched IF / ELSE")
    return(TokenCountGI+1)
end

// Every call executes a token interval; recursion cap prevents runaway calls.
proc FNExecute(integer FirstI, integer LastI)
    integer ProgramCounterI, LeftI, RightI, BodyI, FinishI, NestedDepthI, DoneB
    string TokenS[255], UpperTokenS[255]
    if CallDepthGI >= 50
        FNFail("Call depth exceeds 50")
        return()
    endif
    CallDepthGI = CallDepthGI + 1
    ProgramCounterI = FirstI
    while ProgramCounterI <= LastI and not FailedGB
        StepCountGI = StepCountGI + 1
        if StepCountGI > 100000
            FNFail("Execution step limit reached")
            break
        endif
        TokenS = FNToken(ProgramCounterI)
        UpperTokenS = Upper(TokenS)
        if TokenS == ":"
            ProgramCounterI = ProgramCounterI + 2
            while ProgramCounterI <= LastI and FNToken(ProgramCounterI) <> ";"
                ProgramCounterI = ProgramCounterI + 1
            endwhile
        elseif TokenS == ";"
            // Definitions are never executed by falling through top level.
        elseif FNIsNumber(TokenS)
            FNPush(Val(TokenS))
        elseif SubStr(TokenS,1,8) == "@STRING@"
            FNReport(SubStr(TokenS,9,255))
        elseif UpperTokenS == "."
            LeftI = FNPop()
            if not FailedGB
                FNReport(Str(LeftI))
            endif
        elseif UpperTokenS == ".S"
            FNReport("Stack depth: " + Str(StackDepthGI))
        elseif UpperTokenS == "CR"
            FNReport("")
        elseif UpperTokenS == "DUP"
            LeftI = FNPeek()
            if not FailedGB
                FNPush(LeftI)
            endif
        elseif UpperTokenS == "DROP"
            LeftI = FNPop()
        elseif UpperTokenS == "SWAP"
            RightI = FNPop()
            LeftI = FNPop()
            if not FailedGB
                FNPush(RightI)
                FNPush(LeftI)
            endif
        elseif UpperTokenS == "OVER"
            RightI = FNPop()
            LeftI = FNPop()
            if not FailedGB
                FNPush(LeftI)
                FNPush(RightI)
                FNPush(LeftI)
            endif
        elseif UpperTokenS == "+" or UpperTokenS == "-" or UpperTokenS == "*" or UpperTokenS == "/" or UpperTokenS == "MOD" or UpperTokenS == "=" or UpperTokenS == "<" or UpperTokenS == ">"
            RightI = FNPop()
            LeftI = FNPop()
            if not FailedGB
                if UpperTokenS == "+"
                    FNPush(LeftI+RightI)
                elseif UpperTokenS == "-"
                    FNPush(LeftI-RightI)
                elseif UpperTokenS == "*"
                    FNPush(LeftI*RightI)
                elseif UpperTokenS == "/" or UpperTokenS == "MOD"
                    if RightI == 0
                        FNFail("Division by zero at " + FNTokenLocation(ProgramCounterI))
                    elseif UpperTokenS == "/"
                        FNPush(LeftI / RightI)
                    else
                        FNPush(LeftI mod RightI)
                    endif
                elseif UpperTokenS == "="
                    FNPush(-(LeftI == RightI))
                elseif UpperTokenS == "<"
                    FNPush(-(LeftI < RightI))
                else
                    FNPush(-(LeftI > RightI))
                endif
            endif
        elseif UpperTokenS == "IF"
            LeftI = FNPop()
            if not FailedGB and LeftI == 0
                ProgramCounterI = FNSkipBranch(ProgramCounterI+1,FALSE)-1
            endif
        elseif UpperTokenS == "ELSE"
            ProgramCounterI = FNSkipBranch(ProgramCounterI+1,TRUE)-1
        elseif UpperTokenS == "THEN"
            // No action; branch terminator.
        else
            BodyI = FNDefinition(TokenS)
            if BodyI == 0
                FNFail("Unknown word '" + TokenS + "' at " + FNTokenLocation(ProgramCounterI))
            else
                FinishI = BodyI
                while FinishI <= TokenCountGI and FNToken(FinishI) <> ";"
                    FinishI = FinishI + 1
                endwhile
                FNExecute(BodyI,FinishI-1)
            endif
        endif
        ProgramCounterI = ProgramCounterI + 1
    endwhile
    CallDepthGI = CallDepthGI - 1
end

proc FNDumpTokens()
    integer IndexI
    FNReport("FORTH LEXER - 1.0.0.0.5")
    for IndexI = 1 to TokenCountGI
        FNReport(FNTokenLocation(IndexI) + "  " + FNToken(IndexI))
    endfor
end

proc FNDumpParse()
    integer IndexI, IndentI
    string TokenS[255]
    IndentI = 0
    FNReport("FORTH PARSER - 1.0.0.0.5")
    FNReport("PROGRAM")
    for IndexI = 1 to TokenCountGI
        TokenS = FNToken(IndexI)
        if TokenS == ":"
            FNReport("  DEFINITION  " + FNToken(IndexI+1) + " [" + FNTokenLocation(IndexI) + "]")
            IndentI = 1
            IndexI = IndexI + 1
        elseif TokenS == ";"
            FNReport("  END-DEFINITION")
            IndentI = 0
        elseif IndentI
            FNReport("    ITEM  " + TokenS)
        else
            FNReport("  ITEM  " + TokenS)
        endif
    endfor
    FNReport("Definitions: " + Str(DefinitionCountGI) + "  Tokens: " + Str(TokenCountGI))
end

proc Main()
    integer HistoryI, IndexI
    string ChoiceS[20]
    OriginalBufferGI = GetBufferId()
    MacroDirGS = FNMacroDir()
    IniFileGS = MacroDirGS + "forthparser.ini"
    InputFileGS = GetProfileStr("ForthParser","input","example.fth",IniFileGS)
    ChoiceS = Upper(GetProfileStr("ForthParser","action","E",IniFileGS))
    // The INI supplies the default. Named Ask history remains available.
    HistoryI = GetFreeHistory("FORTHPARSER:InputFile")
    if not Ask("FORTH file: ",InputFileGS,HistoryI)
        return()
    endif
    HistoryI = GetFreeHistory("FORTHPARSER:Action")
    if not Ask("Action (L lexer, P parser, E execute): ",ChoiceS,HistoryI)
        return()
    endif
    ChoiceS = Upper(ChoiceS)
    WriteProfileStr("ForthParser","input",InputFileGS,IniFileGS)
    WriteProfileStr("ForthParser","action",ChoiceS,IniFileGS)
    InputFileGS = FNPath(InputFileGS)
    if not FileExists(InputFileGS)
        Warn("FORTH file not found: ",InputFileGS)
        return()
    endif
    SourceBufferGI = CreateTempBuffer()
    GotoBufferId(SourceBufferGI)
    if not InsertFile(InputFileGS,_DONT_PROMPT_)
        Warn("Cannot read: ",InputFileGS)
        AbandonFile(SourceBufferGI)
        return()
    endif
    TokenBufferGI = CreateTempBuffer()
    // The reader accesses token N at line N+1: create line 1 explicitly.
    GotoBufferId(TokenBufferGI)
    BegFile()
    InsertText("0|0|@TOKEN_HEADER@")
    StackBufferGI = CreateTempBuffer()
    // FNPop() and FNPeek() access stack element N at line N+1.
    GotoBufferId(StackBufferGI)
    BegFile()
    InsertText("@STACK_HEADER@")
    OutputBufferGI = CreateTempBuffer()
    TokenCountGI = 0
    StackDepthGI = 0
    FailedGB = FALSE
    DefinitionCountGI = 0
    CallDepthGI = 0
    StepCountGI = 0
    FNLex()
    // Always emit a diagnostic header, including on lexical/parse errors.
    // FNFail() writes the error to the same output buffer.
    if not FailedGB
        FNParse()
    endif
    if not FailedGB
        if ChoiceS == "L"
            FNDumpTokens()
        elseif ChoiceS == "P"
            FNDumpParse()
        elseif ChoiceS == "E"
            FNReport("FORTH EXECUTION - 1.0.0.0.5")
            FNExecute(1,TokenCountGI)
            if not FailedGB
                FNReport("Execution complete. Stack depth: " + Str(StackDepthGI))
            endif
        else
            FNFail("Unknown action: " + ChoiceS)
        endif
    endif
    GotoBufferId(OutputBufferGI)
    BegFile()
    // Text results are written beside the compiled .mac, not CurrDir().
    SaveAs(MacroDirGS + "forthparser_output.txt",_OVERWRITE_)
    GotoBufferId(OriginalBufferGI)
    AbandonFile(SourceBufferGI)
    AbandonFile(TokenBufferGI)
    AbandonFile(StackBufferGI)
    AbandonFile(OutputBufferGI)
    EditFile(MacroDirGS + "forthparser_output.txt")
end
