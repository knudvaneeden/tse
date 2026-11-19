// LOGOPARSER 1.0.0.0.1 - LOGO lexer, parser, interpreter in TSE SAL
// 2026-11-19. Standalone; no external executable or DLL.
// Integer arithmetic and fixed-point turtle coordinates.

integer gTokensGI, gOutputGI, gTokenCountGI, gIndexGI, gErrorGB
integer gLineGI, gColGI, gHeadingGI, gXGI, gYGI, gPenGB
integer gVariablesGI, gStepsGI, gShowTokensGB, gTraceGB
string gKindGS[12], gValueGS[255], gErrGS[255]
string gMacroDirGS[255], gProgramGS[255], gResultGS[255]

proc LPLog(string messageS)
    AddLine(messageS, gOutputGI)
end

proc LPFail(string messageS)
    if not gErrorGB
        gErrGS = Format("Error ", gLineGI, ":", gColGI, ": ", messageS)
        LPLog(gErrGS)
        gErrorGB = TRUE
    endif
end

proc LPAddToken(string kindS, string valueS, integer lineI, integer columnI)
    AddLine(kindS + Chr(9) + Str(lineI) + Chr(9) + Str(columnI) + Chr(9) + valueS, gTokensGI)
    gTokenCountGI = gTokenCountGI + 1
end

integer proc LPIsLetter(string charS)
    return(Pos(Upper(charS), "ABCDEFGHIJKLMNOPQRSTUVWXYZ_") > 0)
end

integer proc LPIsDigit(string charS)
    return(Pos(charS, "0123456789") > 0)
end

// Read token record at 1-based position, including the explicit EOF token.
proc LPRead(integer positionI)
    integer previousI
    string recordS[255]
    if positionI < 1
        positionI = 1
    endif
    if positionI > gTokenCountGI
        positionI = gTokenCountGI
    endif
    previousI = GetBufferId()
    GotoBufferId(gTokensGI)
    GotoLine(positionI)
    recordS = GetText(1, 255)
    GotoBufferId(previousI)
    gKindGS = GetToken(recordS, Chr(9), 1)
    gLineGI = Val(GetToken(recordS, Chr(9), 2))
    gColGI = Val(GetToken(recordS, Chr(9), 3))
    gValueGS = GetToken(recordS, Chr(9), 4)
end

proc LPNext()
    gIndexGI = gIndexGI + 1
    LPRead(gIndexGI)
end

integer proc LPMatch(string symbolS)
    if gValueGS == symbolS
        LPNext()
        return(TRUE)
    endif
    return(FALSE)
end

proc LPRequire(string symbolS)
    if not gErrorGB
        if not LPMatch(symbolS)
            LPFail("Expected '" + symbolS + "', found '" + gValueGS + "'")
        endif
    endif
end

// Lexer: comments start with ;, variables are :name, quoted names are "name.
// Physical newline is significant for LOGO command boundaries.
proc LPLex(integer sourceI)
    integer oldI, lineI, colI, startI, lenI
    string lineS[255], charS[1], valueS[255], kindS[12]
    oldI = GetBufferId()
    GotoBufferId(sourceI)
    BegFile()
    lineI = 0
    repeat
        lineI = lineI + 1
        lineS = GetText(1, 255)
        lenI = Length(lineS)
        colI = 1
        while colI <= lenI
            charS = SubStr(lineS, colI, 1)
            if charS == ";"
                break
            elseif (charS == " ") or (charS == Chr(9)) or (charS == Chr(13))
                colI = colI + 1
            elseif LPIsDigit(charS)
                startI = colI
                while colI <= lenI
                    if not LPIsDigit(SubStr(lineS, colI, 1))
                        break
                    endif
                    colI = colI + 1
                endwhile
                LPAddToken("NUMBER", SubStr(lineS, startI, colI - startI), lineI, startI)
            elseif LPIsLetter(charS) or (charS == ":") or (charS == '"')
                startI = colI
                if (charS == ":") or (charS == '"')
                    colI = colI + 1
                    if (colI > lenI) or not LPIsLetter(SubStr(lineS, colI, 1))
                        LPAddToken("BAD", charS, lineI, startI)
                    endif
                endif
                while colI <= lenI
                    charS = SubStr(lineS, colI, 1)
                    if not (LPIsLetter(charS) or LPIsDigit(charS))
                        break
                    endif
                    colI = colI + 1
                endwhile
                valueS = Upper(SubStr(lineS, startI, colI - startI))
                kindS = "WORD"
                if SubStr(valueS, 1, 1) == ":"
                    kindS = "VARIABLE"
                elseif SubStr(valueS, 1, 1) == '"'
                    kindS = "QUOTED"
                endif
                LPAddToken(kindS, valueS, lineI, startI)
            elseif Pos(charS, "[]()+-*/") > 0
                LPAddToken("SYMBOL", charS, lineI, colI)
                colI = colI + 1
            else
                LPAddToken("BAD", charS, lineI, colI)
                colI = colI + 1
            endif
        endwhile
        LPAddToken("EOL", "<EOL>", lineI, lenI + 1)
    until not Down()
    GotoBufferId(oldI)
    LPAddToken("EOF", "<EOF>", lineI + 1, 1)
end

integer proc LPVariableGet(string nameS, integer executeB)
    integer oldI, answerI, foundB
    string recordS[255]
    answerI = 0
    if not executeB
        return(0)
    endif
    foundB = FALSE
    oldI = GetBufferId()
    GotoBufferId(gVariablesGI)
    BegFile()
    if NumLines() > 0
        repeat
            recordS = GetText(1, 255)
            if GetToken(recordS, Chr(9), 1) == nameS
                answerI = Val(GetToken(recordS, Chr(9), 2))
                foundB = TRUE
                break
            endif
        until not Down()
    endif
    GotoBufferId(oldI)
    if not foundB
        LPFail("Undefined variable '" + nameS + "'")
    endif
    return(answerI)
end

proc LPVariableSet(string nameS, integer valueI)
    integer oldI, foundB
    string recordS[255]
    oldI = GetBufferId()
    GotoBufferId(gVariablesGI)
    BegFile()
    foundB = FALSE
    if NumLines() > 0
        repeat
            recordS = GetText(1, 255)
            if GetToken(recordS, Chr(9), 1) == nameS
                BegLine()
                KillToEol()
                InsertText(nameS + Chr(9) + Str(valueI), _INSERT_)
                foundB = TRUE
                break
            endif
        until not Down()
    endif
    GotoBufferId(oldI)
    if not foundB
        AddLine(nameS + Chr(9) + Str(valueI), gVariablesGI)
    endif
end

// Signed sin(angle), scaled by 1000, using Bhaskara's approximation.
integer proc LPSin1000(integer angleI)
    integer xI, signI, numeratorI, denominatorI
    xI = angleI mod 360
    if xI < 0
        xI = xI + 360
    endif
    signI = 1
    if xI > 180
        xI = xI - 180
        signI = -1
    endif
    numeratorI = 4 * xI * (180 - xI) * 1000
    denominatorI = 40500 - xI * (180 - xI)
    if denominatorI == 0
        return(0)
    endif
    return(signI * (numeratorI / denominatorI))
end

proc LPMove(integer amountI)
    integer sineI, cosineI
    sineI = LPSin1000(gHeadingGI)
    cosineI = LPSin1000(gHeadingGI + 90)
    gXGI = gXGI + amountI * sineI
    gYGI = gYGI + amountI * cosineI
    if gTraceGB
        LPLog(Format("MOVE ", amountI, " -> (", gXGI / 1000, ", ", gYGI / 1000,
                     ") heading=", gHeadingGI, " pen=", gPenGB))
    endif
end

// Recursive descent: factor, term, expression. Values are signed 32-bit integers.
forward integer proc LPExpression(integer executeB, integer depthI)

integer proc LPFactor(integer executeB, integer depthI)
    integer resultI
    string nameS[255]
    resultI = 0
    if (depthI > 64) or gErrorGB
        LPFail("Expression nesting limit exceeded")
        return(0)
    endif
    if gKindGS == "NUMBER"
        resultI = Val(gValueGS)
        LPNext()
    elseif gKindGS == "VARIABLE"
        nameS = SubStr(gValueGS, 2, Length(gValueGS) - 1)
        LPNext()
        resultI = LPVariableGet(nameS, executeB)
    elseif LPMatch("(")
        resultI = LPExpression(executeB, depthI + 1)
        LPRequire(")")
    elseif LPMatch("-")
        resultI = -LPFactor(executeB, depthI + 1)
    elseif LPMatch("+")
        resultI = LPFactor(executeB, depthI + 1)
    else
        LPFail("Expected number, :variable or parenthesized expression")
    endif
    return(resultI)
end

integer proc LPTerm(integer executeB, integer depthI)
    integer resultI, otherI
    string opS[1]
    resultI = LPFactor(executeB, depthI + 1)
    while (not gErrorGB) and ((gValueGS == "*") or (gValueGS == "/"))
        opS = gValueGS
        LPNext()
        otherI = LPFactor(executeB, depthI + 1)
        if opS == "*"
            if executeB
                resultI = resultI * otherI
            endif
        else
            if (otherI == 0) and executeB
                LPFail("Division by zero")
            elseif executeB
                resultI = resultI / otherI
            endif
        endif
    endwhile
    return(resultI)
end

integer proc LPExpression(integer executeB, integer depthI)
    integer resultI, otherI
    string opS[1]
    resultI = LPTerm(executeB, depthI + 1)
    while (not gErrorGB) and ((gValueGS == "+") or (gValueGS == "-"))
        opS = gValueGS
        LPNext()
        otherI = LPTerm(executeB, depthI + 1)
        if executeB
            if opS == "+"
                resultI = resultI + otherI
            else
                resultI = resultI - otherI
            endif
        endif
    endwhile
    return(resultI)
end

forward proc LPStatement(integer executeB, integer depthI)

proc LPBlock(integer executeB, integer depthI)
    if depthI > 32
        LPFail("REPEAT nesting exceeds 32")
        return()
    endif
    LPRequire("[")
    while (not gErrorGB) and (gKindGS <> "EOF") and (gValueGS <> "]")
        if gKindGS == "EOL"
            LPNext()
        else
            LPStatement(executeB, depthI + 1)
        endif
    endwhile
    LPRequire("]")
end

proc LPStatement(integer executeB, integer depthI)
    string commandS[32], nameS[255]
    integer valueI, countI, firstI, afterI, iterationI
    if gKindGS <> "WORD"
        LPFail("Expected LOGO command")
        return()
    endif
    commandS = gValueGS
    LPNext()
    if (commandS == "FORWARD") or (commandS == "FD") or
       (commandS == "BACK") or (commandS == "BK") or
       (commandS == "RIGHT") or (commandS == "RT") or
       (commandS == "LEFT") or (commandS == "LT") or
       (commandS == "PRINT") or (commandS == "PR")
        valueI = LPExpression(executeB, 0)
        if executeB and not gErrorGB
            if (commandS == "FORWARD") or (commandS == "FD")
                LPMove(valueI)
            elseif (commandS == "BACK") or (commandS == "BK")
                LPMove(-valueI)
            elseif (commandS == "RIGHT") or (commandS == "RT")
                gHeadingGI = (gHeadingGI + valueI) mod 360
            elseif (commandS == "LEFT") or (commandS == "LT")
                gHeadingGI = (gHeadingGI - valueI) mod 360
            else
                LPLog(Format("PRINT ", valueI))
            endif
        endif
    elseif commandS == "MAKE"
        if gKindGS <> "QUOTED"
            LPFail("MAKE requires a quoted variable name, e.g. MAKE " + '"SIDE' + " 80")
            return()
        endif
        nameS = SubStr(gValueGS, 2, Length(gValueGS) - 1)
        LPNext()
        valueI = LPExpression(executeB, 0)
        if executeB and not gErrorGB
            LPVariableSet(nameS, valueI)
        endif
    elseif commandS == "REPEAT"
        countI = LPExpression(executeB, 0)
        if executeB and ((countI < 0) or (countI > 10000))
            LPFail("REPEAT count must be between 0 and 10000")
            return()
        endif
        firstI = gIndexGI
        LPBlock(FALSE, depthI + 1)
        afterI = gIndexGI
        if executeB and not gErrorGB
            for iterationI = 1 to countI
                if gErrorGB or (gStepsGI > 100000)
                    break
                endif
                gIndexGI = firstI
                LPRead(gIndexGI)
                LPBlock(TRUE, depthI + 1)
            endfor
        endif
        gIndexGI = afterI
        LPRead(gIndexGI)
    elseif (commandS == "PENUP") or (commandS == "PU")
        if executeB
            gPenGB = FALSE
            if gTraceGB
                LPLog("PEN UP")
            endif
        endif
    elseif (commandS == "PENDOWN") or (commandS == "PD")
        if executeB
            gPenGB = TRUE
            if gTraceGB
                LPLog("PEN DOWN")
            endif
        endif
    elseif commandS == "HOME"
        if executeB
            gXGI = 0
            gYGI = 0
            gHeadingGI = 0
            if gTraceGB
                LPLog("HOME (0, 0), heading 0")
            endif
        endif
    elseif commandS == "CLEARSCREEN" or commandS == "CS"
        if executeB
            gXGI = 0
            gYGI = 0
            gHeadingGI = 0
            if gTraceGB
                LPLog("CLEARSCREEN -> HOME")
            endif
        endif
    else
        LPFail("Unknown LOGO command '" + commandS + "'")
        return()
    endif
    if gErrorGB
        return()
    endif
    gStepsGI = gStepsGI + 1
    if gStepsGI > 100000
        LPFail("Execution step limit (100000) exceeded")
        return()
    endif
    if (gKindGS <> "EOL") and (gKindGS <> "EOF") and (gValueGS <> "]")
        LPFail("Expected end of command, found '" + gValueGS + "'")
    endif
end

proc LPProgram(integer executeB)
    gIndexGI = 1
    LPRead(gIndexGI)
    while (not gErrorGB) and (gKindGS <> "EOF")
        if gKindGS == "EOL"
            LPNext()
        elseif gValueGS == "]"
            LPFail("Unexpected closing bracket ]")
        else
            LPStatement(executeB, 0)
        endif
    endwhile
end

proc Main()
    integer oldI, sourceI, iI
    string inputS[255], tokensS[255], recordS[255]
    gMacroDirGS = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
    gProgramGS = GetProfileStr("Defaults", "Program", "example.logo", gMacroDirGS + "logoparser.ini")
    gResultGS = GetProfileStr("Defaults", "Output", "logoparser_output.txt", gMacroDirGS + "logoparser.ini")
    gTraceGB = Val(GetProfileStr("Defaults", "Trace", "1", gMacroDirGS + "logoparser.ini"))
    gShowTokensGB = Val(GetProfileStr("Defaults", "ShowTokens", "1", gMacroDirGS + "logoparser.ini"))
    Set(PersistentHistory, ON)
    inputS = gProgramGS
    if not Ask("LOGO program file:", inputS, 231)
        return()
    endif
    if not (Pos(":", inputS) or (SubStr(inputS, 1, 1) == "\"))
        inputS = gMacroDirGS + inputS
    endif
    oldI = GetBufferId()
    if not FileExists(inputS)
        Warn("LOGO input file not found: ", inputS)
        return()
    endif
    sourceI = EditFile(inputS, _DONT_PROMPT_)
    if not sourceI
        Warn("Unable to open LOGO program: ", inputS)
        return()
    endif
    gTokensGI = CreateTempBuffer()
    gOutputGI = CreateTempBuffer()
    gVariablesGI = CreateTempBuffer()
    gTokenCountGI = 0
    gErrorGB = FALSE
    gErrGS = ""
    gStepsGI = 0
    gXGI = 0
    gYGI = 0
    gHeadingGI = 0
    gPenGB = TRUE
    LPLog("LOGOPARSER 1.0.0.0.1 - " + inputS)
    LPLex(sourceI)
    if gShowTokensGB
        LPLog("--- LEXICAL TOKENS ---")
        for iI = 1 to gTokenCountGI
            LPRead(iI)
            if gKindGS <> "EOL"
                LPLog(Format(gLineGI, ":", gColGI, " ", gKindGS, " ", gValueGS))
            endif
        endfor
    endif
    LPLog("--- PARSER ---")
    LPProgram(FALSE)
    if not gErrorGB
        LPLog("PARSE OK")
        LPLog("--- SEMANTIC EXECUTION ---")
        gStepsGI = 0
        LPProgram(TRUE)
        if not gErrorGB
            LPLog(Format("DONE. x=", gXGI / 1000, " y=", gYGI / 1000,
                         " heading=", gHeadingGI, " pen=", gPenGB))
        endif
    endif
    GotoBufferId(gOutputGI)
    if (Pos(":", gResultGS) == 0) and (SubStr(gResultGS, 1, 1) <> "\")
        gResultGS = gMacroDirGS + gResultGS
    endif
    SaveAs(gResultGS, _DONT_PROMPT_ | _OVERWRITE_)
    GotoBufferId(oldI)
    if gErrorGB
        Warn(gErrGS, " -- see ", gResultGS)
    else
        Warn("LOGO parse and execution OK. Output: ", gResultGS)
    endif
end
