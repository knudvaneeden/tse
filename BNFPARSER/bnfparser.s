// BNF/EBNF parser generator project - version 1.0.0.0.14
// Initial milestone: EBNF lexer, syntax validator, rule/reference checks.
// Pure TSE SAL. No external executable/DLL.

integer gTokBuf, gDefBuf, gRefBuf, gErrBuf, gSrcBuf, gIRBuf, gGenBuf
integer gTokCount, gErrCount, gRules, gRefs
integer gTokLine, gTokCol
string gTokKind[12], gTokValue[255]
string gGrammarFile[255], gIniFile[255]

// Macro-relative paths. No CurrDir(), ChDir(), or hardcoded install path.
// CurrMacroFilename() identifies the actual executing .mac file.
string proc BNFMacroDirectory()
    return (SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_))
end

// Preserve explicit absolute Windows, UNC, and Unix paths.
integer proc BNFIsAbsolutePath(string fileName)
    if Length(fileName) == 0
        return (FALSE)
    endif
    if (SubStr(fileName, 1, 1) == "/") or (SubStr(fileName, 1, 1) == "\\")
        return (TRUE)
    endif
    if (Length(fileName) >= 2) and (SubStr(fileName, 2, 1) == ":")
        return (TRUE)
    endif
    return (FALSE)
end

string proc BNFResolvePath(string fileName)
    if BNFIsAbsolutePath(fileName)
        return (fileName)
    endif
    return (BNFMacroDirectory() + fileName)
end

proc BNFError(integer lineNo, integer colNo, string explanation)
    gErrCount = gErrCount + 1
    AddLine(Str(lineNo) + ":" + Str(colNo) + ": ERROR: " + explanation, gErrBuf)
end

integer proc BNFIsStart(string ch)
    return (Pos(ch, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_") > 0)
end

integer proc BNFIsRest(string ch)
    return (BNFIsStart(ch) or Pos(ch, "0123456789") > 0)
end

proc BNFPush(string kind, string value, integer lineNo, integer colNo)
    // Tab-delimited fields; literal contents may include vertical bar.
    AddLine(kind + Chr(9) + value + Chr(9) + Str(lineNo) + Chr(9) + Str(colNo), gTokBuf)
    gTokCount = gTokCount + 1
end

proc BNFLex()
    integer n, i, j, size, inComment, commentLine, commentCol
    string lineText[255], ch[1], lookAheadChar[1], word[255], quoteChar[1]
    inComment = FALSE
    for n = 1 to NumLines()
        GotoLine(n)
        size = CurrLineLen()
        if size > 255
            BNFError(n, 256, "Line exceeds initial lexer limit of 255 characters")
            size = 255
        endif
        lineText = GetText(1, size)
        i = 1
        while i <= size
            ch = SubStr(lineText, i, 1)
            lookAheadChar = ""
            if i < size
                lookAheadChar = SubStr(lineText, i + 1, 1)
            endif
            if inComment
                if (ch == "*") and (lookAheadChar == ")")
                    inComment = FALSE
                    i = i + 2
                else
                    i = i + 1
                endif
            elseif (ch == "(") and (lookAheadChar == "*")
                inComment = TRUE
                commentLine = n
                commentCol = i
                i = i + 2
            elseif (ch == "/") and (lookAheadChar == "/")
                i = size + 1
            elseif (ch == " ") or (ch == Chr(9)) or (ch == Chr(13))
                i = i + 1
            elseif BNFIsStart(ch)
                j = i + 1
                while (j <= size) and BNFIsRest(SubStr(lineText, j, 1))
                    j = j + 1
                endwhile
                word = SubStr(lineText, i, j - i)
                BNFPush("ID", word, n, i)
                i = j
            elseif (ch == Chr(34)) or (ch == "'")
                quoteChar = ch
                word = ""
                j = i + 1
                while (j <= size) and (SubStr(lineText, j, 1) <> quoteChar)
                    word = word + SubStr(lineText, j, 1)
                    j = j + 1
                endwhile
                if j > size
                    BNFError(n, i, "Unterminated quoted terminal")
                    i = size + 1
                else
                    BNFPush("LIT", word, n, i)
                    i = j + 1
                endif
            elseif (ch == ":") and (i + 2 <= size) and (SubStr(lineText, i, 3) == "::=")
                BNFPush("=", "=", n, i)
                i = i + 3
            elseif Pos(ch, "=;,|()[]{}") > 0
                BNFPush(ch, ch, n, i)
                i = i + 1
            else
                BNFError(n, i, "Unexpected character: " + ch)
                i = i + 1
            endif
        endwhile
    endfor
    if inComment
        BNFError(commentLine, commentCol, "Unterminated (* ... *) comment")
    endif
end

proc BNFReadToken(integer tokenNo)
    integer old, a, b, c
    string lineText[255], rest[255]
    old = GetBufferId()
    GotoBufferId(gTokBuf)
    GotoLine(tokenNo)
    lineText = GetText(1, 255)
    a = Pos(Chr(9), lineText)
    gTokKind = SubStr(lineText, 1, a - 1)
    rest = SubStr(lineText, a + 1, Length(lineText) - a)
    b = Pos(Chr(9), rest)
    gTokValue = SubStr(rest, 1, b - 1)
    rest = SubStr(rest, b + 1, Length(rest) - b)
    c = Pos(Chr(9), rest)
    gTokLine = Val(SubStr(rest, 1, c - 1))
    gTokCol = Val(SubStr(rest, c + 1, Length(rest) - c))
    GotoBufferId(old)
end

integer proc BNFDefined(string name)
    integer old, i, found
    old = GetBufferId()
    found = FALSE
    GotoBufferId(gDefBuf)
    for i = 1 to NumLines()
        GotoLine(i)
        if GetText(1, 255) == name
            found = TRUE
            break
        endif
    endfor
    GotoBufferId(old)
    return (found)
end

proc BNFValidate()
    integer t, state, depth, ln, cn, i
    string stack[255], k[12], v[255], expected[1], top[1], rule[255]
    // 0: lhs identifier; 1: assignment; 2: operand; 3: operator/close/end
    state = 0
    depth = 0
    stack = ""
    rule = ""
    for t = 1 to gTokCount
        BNFReadToken(t)
        k = gTokKind
        v = gTokValue
        ln = gTokLine
        cn = gTokCol
        if state == 0
            if k == "ID"
                if BNFDefined(v)
                    BNFError(ln, cn, "Duplicate production: " + v)
                else
                    AddLine(v, gDefBuf)
                    gRules = gRules + 1
                endif
                rule = v
                state = 1
            else
                BNFError(ln, cn, "Expected production name")
            endif
        elseif state == 1
            if k == "="
                state = 2
            else
                BNFError(ln, cn, "Expected = or ::= after " + rule)
                state = 2
            endif
        elseif state == 2
            if (k == "ID") or (k == "LIT")
                if k == "ID"
                    AddLine(v + Chr(9) + Str(ln) + Chr(9) + Str(cn), gRefBuf)
                    gRefs = gRefs + 1
                endif
                state = 3
            elseif (k == "(") or (k == "[") or (k == "{")
                stack = stack + k
                depth = depth + 1
            else
                BNFError(ln, cn, "Expected terminal, rule name, or opening group")
            endif
        else
            if (k == ",") or (k == "|")
                state = 2
            elseif (k == ")") or (k == "]") or (k == "}")
                if depth == 0
                    BNFError(ln, cn, "Closing group without opener: " + k)
                else
                    top = SubStr(stack, depth, 1)
                    expected = ")"
                    if top == "["
                        expected = "]"
                    elseif top == "{"
                        expected = "}"
                    endif
                    if k <> expected
                        BNFError(ln, cn, "Mismatched group: expected " + expected)
                    endif
                    stack = SubStr(stack, 1, depth - 1)
                    depth = depth - 1
                endif
            elseif k == ";"
                if depth <> 0
                    BNFError(ln, cn, "Production ended with unclosed group")
                    depth = 0
                    stack = ""
                endif
                state = 0
            else
                BNFError(ln, cn, "Expected comma, alternative, closing group, or semicolon")
            endif
        endif
    endfor
    if state <> 0
        BNFError(gTokLine, gTokCol, "Incomplete production at end of grammar")
    endif
    if gRules == 0
        BNFError(1, 1, "No productions found")
    endif
    GotoBufferId(gRefBuf)
    for i = 1 to NumLines()
        GotoLine(i)
        v = GetText(1, 255)
        t = Pos(Chr(9), v)
        rule = SubStr(v, 1, t - 1)
        v = SubStr(v, t + 1, Length(v) - t)
        t = Pos(Chr(9), v)
        ln = Val(SubStr(v, 1, t - 1))
        cn = Val(SubStr(v, t + 1, Length(v) - t))
        if not BNFDefined(rule)
            BNFError(ln, cn, "Undefined production: " + rule)
        endif
    endfor
end


// Store grammar token records as a simple, reusable intermediate form.
proc BNFWriteIR(string outputFile)
    integer old, i
    string kind[12], value[255]
    old = GetBufferId()
    gIRBuf = CreateTempBuffer()
    AddLine("BNFPARSER IR v1 | rules=" + Str(gRules) + " | tokens=" + Str(gTokCount), gIRBuf)
    for i = 1 to gTokCount
        BNFReadToken(i)
        kind = gTokKind
        value = gTokValue
        AddLine(Str(i) + Chr(9) + kind + Chr(9) + value + Chr(9) + Str(gTokLine) + ":" + Str(gTokCol), gIRBuf)
    endfor
    GotoBufferId(gIRBuf)
    SaveAs(outputFile, _OVERWRITE_)
    GotoBufferId(old)
end

// Inject validated grammar records into a pure SAL runtime template.
// The generated program requires no .ini or external source at runtime.
proc BNFGenerate(string templateFile, string outputFile)
    integer old, sourceTemplate, lineNo, tokenNo, characterNo, charCode, markerFound
    integer semanticBuf, semanticLine, semanticChosen, semanticsFound
    string sourceLine[255], tokenKind[12], tokenValue[255], semanticMode[255], semanticFile[255]
    old = GetBufferId()
    if not FileExists(templateFile)
        BNFError(1, 1, "Missing generator template: " + templateFile)
        return()
    endif
    if not EditFile(templateFile)
        BNFError(1, 1, "Unable to open generator template")
        return()
    endif
    sourceTemplate = GetBufferId()
    // General-purpose by default; arithmetic evaluation is opt-in.
    semanticMode = Lower(GetProfileStr("Generator", "SemanticModule", "none", gIniFile))
    semanticChosen = FALSE
    semanticBuf = 0
    if semanticMode == "arithmetic"
        semanticFile = BNFResolvePath("bnfparser_semantics_arithmetic.txt")
        if not FileExists(semanticFile)
            BNFError(1, 1, "Missing optional arithmetic semantic template: " + semanticFile)
            GotoBufferId(old)
            return()
        endif
        if not EditFile(semanticFile)
            BNFError(1, 1, "Unable to open arithmetic semantic template")
            GotoBufferId(old)
            return()
        endif
        semanticBuf = GetBufferId()
        semanticChosen = TRUE
    elseif semanticMode <> "none"
        BNFError(1, 1, "Unknown semantic module: " + semanticMode)
        GotoBufferId(old)
        return()
    endif
    gGenBuf = CreateTempBuffer()
    // Explicit version header on every generated .s file.
    // Always emit this before copying the runtime template.
    AddLine("// generatedparser.s - version 1.0.0.0.14", gGenBuf)
    AddLine("// Generated by BNFPARSER version 1.0.0.0.14", gGenBuf)
    AddLine("// Source grammar: " + gGrammarFile, gGenBuf)
    AddLine("// Pure TSE SAL generated parser - do not edit manually", gGenBuf)
    AddLine("", gGenBuf)
    markerFound = FALSE
    semanticsFound = FALSE
    GotoBufferId(sourceTemplate)
    for lineNo = 1 to NumLines()
        GotoBufferId(sourceTemplate)
        GotoLine(lineNo)
        sourceLine = GetText(1, 255)
        if Pos("// @@GRAMMAR@@", sourceLine) > 0
            markerFound = TRUE
            for tokenNo = 1 to gTokCount
                BNFReadToken(tokenNo)
                tokenKind = gTokKind
                tokenValue = gTokValue
                AddLine("    gBuildText = " + Chr(34) + Chr(34), gGenBuf)
                for characterNo = 1 to Length(tokenValue)
                    charCode = Asc(SubStr(tokenValue, characterNo, 1))
                    AddLine("    gBuildText = gBuildText + Chr(" + Str(charCode) + ")", gGenBuf)
                endfor
                AddLine("    AddLine(" + Chr(34) + tokenKind + Chr(34) + " + Chr(9) + gBuildText, gGrammarBuf)", gGenBuf)
                AddLine("    gGrammarCount = gGrammarCount + 1", gGenBuf)
            endfor
        elseif Pos("// @@SEMANTICS@@", sourceLine) > 0
            semanticsFound = TRUE
            if semanticChosen
                GotoBufferId(semanticBuf)
                for semanticLine = 1 to NumLines()
                    GotoLine(semanticLine)
                    AddLine(GetText(1, 255), gGenBuf)
                endfor
            else
                AddLine("string proc GPPostParse()", gGenBuf)
                AddLine("    return (" + Chr(34) + Chr(34) + ")", gGenBuf)
                AddLine("end", gGenBuf)
            endif
        else
            AddLine(sourceLine, gGenBuf)
        endif
    endfor
    if not semanticsFound
        BNFError(1, 1, "Runtime semantics marker not found")
    endif
    if not markerFound
        BNFError(1, 1, "Runtime template marker not found")
    elseif semanticsFound
        GotoBufferId(gGenBuf)
        SaveAs(outputFile, _OVERWRITE_)
    endif
    GotoBufferId(old)
end

proc Main()
    string tokensFile[255], errorsFile[255], irFile[255], parserFile[255], templateFile[255]
    gIniFile = BNFResolvePath("bnfparser.ini")
    // INI supplies the fallback when this Ask history has no saved entry.
    // The unique history number keeps grammar filenames persistent across runs.
    gGrammarFile = GetProfileStr("Files", "Grammar", "example.ebnf", gIniFile)
    if Length(gGrammarFile) == 0
        gGrammarFile = "example.ebnf"
    endif
    tokensFile = BNFResolvePath(GetProfileStr("Files", "Tokens", "bnfparser_tokens.txt", gIniFile))
    errorsFile = BNFResolvePath(GetProfileStr("Files", "Errors", "bnfparser_errors.txt", gIniFile))
    irFile = BNFResolvePath(GetProfileStr("Files", "IR", "bnfparser_ir.txt", gIniFile))
    parserFile = BNFResolvePath(GetProfileStr("Files", "GeneratedParser", "generatedparser.s", gIniFile))
    templateFile = BNFResolvePath(GetProfileStr("Files", "RuntimeTemplate", "bnfparser_runtime.txt", gIniFile))
    Set(PersistentHistory, ON)
    // Ask retains previous values in persistent history list 211.
    // gGrammarFile, initialized from the INI above, is the fallback value.
    if not Ask("BNF/EBNF grammar file:", gGrammarFile, 211)
        return()
    endif
    gGrammarFile = BNFResolvePath(gGrammarFile)
    if not FileExists(gGrammarFile)
        Warn("Grammar file not found: ", gGrammarFile)
        return()
    endif
    if not EditFile(gGrammarFile)
        Warn("Unable to read grammar: ", gGrammarFile)
        return()
    endif
    gSrcBuf = GetBufferId()
    gTokBuf = CreateTempBuffer()
    gDefBuf = CreateTempBuffer()
    gRefBuf = CreateTempBuffer()
    gErrBuf = CreateTempBuffer()
    gTokCount = 0
    gErrCount = 0
    gRules = 0
    gRefs = 0
    GotoBufferId(gSrcBuf)
    BNFLex()
    if gTokCount > 0
        BNFValidate()
    else
        BNFError(1, 1, "Empty grammar")
    endif
    if gErrCount == 0
        BNFWriteIR(irFile)
        BNFGenerate(templateFile, parserFile)
    endif
    GotoBufferId(gTokBuf)
    SaveAs(tokensFile, _OVERWRITE_)
    GotoBufferId(gErrBuf)
    AddLine("BNFPARSER 1.0.0.0.14 - Grammar validation", gErrBuf)
    AddLine("Grammar: " + gGrammarFile, gErrBuf)
    AddLine("Rules: " + Str(gRules) + " Tokens: " + Str(gTokCount) + " References: " + Str(gRefs), gErrBuf)
    if gErrCount == 0
        AddLine("OK: no errors detected within the supported EBNF subset", gErrBuf)
    endif
    SaveAs(errorsFile, _OVERWRITE_)
    GotoBufferId(gSrcBuf)
    Warn("BNFPARSER: ", gRules, " rules, ", gTokCount, " tokens, ", gErrCount, " errors. See ", errorsFile)
end
