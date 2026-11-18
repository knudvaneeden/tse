// lispparser.s - LISP lexer and recursive-descent parser for TSE SAL
// Version 1.0.0.0.3 - 2026-11-18
// Parses the CURRENT buffer. E mode interprets a small integer Lisp subset.
// Build: sc32 lispparser.s

#define LP_EOF     0
#define LP_LPAREN  1
#define LP_RPAREN  2
#define LP_QUOTE   3
#define LP_NUMBER  4
#define LP_SYMBOL  5
#define LP_STRING  6

integer lpLine = 1
integer lpPos = 1
integer lpLines = 0
integer lpType = LP_EOF
integer lpTokenLine = 1
integer lpTokenPos = 1
integer lpError = FALSE
integer lpErrorLine = 1
integer lpErrorPos = 1
integer lpDepth = 0
integer lpMaxDepth = 128
integer lpTokens = 0
integer lpForms = 0
string lpValue[255] = ""
string lpErrorText[255] = ""
integer lpSourceBuffer = 0
integer lpOutputBuffer = 0
integer lpTreeLevel = 0
string lpViewMode[8] = "P"
integer lpEnvBuffer = 0
integer lpActiveCall = 0
integer lpNextCall = 0
integer lpEvalSteps = 0
integer lpFuncLine = 0
integer lpFuncPos = 0
integer lpFuncArgc = 0
string lpFuncParam1[80] = ""
string lpFuncParam2[80] = ""
string lpFuncParam3[80] = ""
string lpLookupValue[255] = ""
string lpResult[255] = ""

// Output is placed in an ordinary TSE buffer, never in the source.
// GotoBufferId() preserves the lexer's source-buffer selection.
proc LPOutput(string s)
    if lpOutputBuffer <> 0
        GotoBufferId(lpOutputBuffer)
        EndFile()
        AddLine(s)
        GotoBufferId(lpSourceBuffer)
    endif
end

string proc LPTokenName(integer t)
    if t == LP_LPAREN
        return ("LPAREN")
    elseif t == LP_RPAREN
        return ("RPAREN")
    elseif t == LP_QUOTE
        return ("QUOTE")
    elseif t == LP_NUMBER
        return ("NUMBER")
    elseif t == LP_SYMBOL
        return ("SYMBOL")
    elseif t == LP_STRING
        return ("STRING")
    endif
    return ("EOF")
end

proc LPTokenRow()
    string v[255]
    v = lpValue
    if lpType == LP_LPAREN
        v = "("
    elseif lpType == LP_RPAREN
        v = ")"
    elseif lpType == LP_QUOTE
        v = "'"
    elseif lpType == LP_STRING
        v = Chr(34) + v + Chr(34)
    endif
    if Length(v) > 175
        v = SubStr(v, 1, 175) + "..."
    endif
    LPOutput(Str(lpTokenLine) + ":" + Str(lpTokenPos) + "  " + LPTokenName(lpType) + "  " + v)
end

// This is a hierarchical syntax-tree representation. Nodes show source
// coordinates and distinguish lists, quoted expressions, and atomic values.
proc LPTreeRow(string kind, string value, integer lineNo, integer colNo)
    string prefix[180] = ""
    string row[255]
    integer i = 0
    while i < lpTreeLevel and i < 48
        prefix = prefix + "  "
        i = i + 1
    endwhile
    row = prefix + kind + "  [" + Str(lineNo) + ":" + Str(colNo) + "]"
    if Length(value) > 0
        row = row + "  " + SubStr(value, 1, 100)
    endif
    LPOutput(row)
end

integer proc LPOpenView(string viewname)
    integer n = 1
    string candidate[80]
    candidate = "[LISP " + viewname + "]"
    lpSourceBuffer = GetBufferId()
    lpOutputBuffer = CreateBuffer(candidate)
    while lpOutputBuffer == 0 and n < 100
        candidate = "[LISP " + viewname + " " + Str(n) + "]"
        lpOutputBuffer = CreateBuffer(candidate)
        n = n + 1
    endwhile
    if lpOutputBuffer == 0
        return (FALSE)
    endif
    InsertText("LISP " + viewname + " - version 1.0.0.0.3", _INSERT_)
    GotoBufferId(lpSourceBuffer)
    return (TRUE)
end

integer proc LPIsDigit(integer c)
    return (c >= 48 and c <= 57)
end

// Read one raw character without changing the scanner position.
// LF (10) is synthesized at the end of each physical line.
integer proc LPPeek()
    string s[2]
    if lpLine > lpLines
        return (0)
    endif
    if CurrLine() <> lpLine
        GotoLine(lpLine)
    endif
    if lpPos > CurrLineLen()
        return (10)
    endif
    s = GetText(lpPos, 1)
    if Length(s) == 0
        return (10)
    endif
    return (Asc(s))
end

proc LPSkipChar()
    if lpLine > lpLines
        return ()
    endif
    if CurrLine() <> lpLine
        GotoLine(lpLine)
    endif
    if lpPos > CurrLineLen()
        lpLine = lpLine + 1
        lpPos = 1
    else
        lpPos = lpPos + 1
    endif
end

proc LPFail(string reason)
    if not lpError
        lpError = TRUE
        lpErrorText = reason
        lpErrorLine = lpTokenLine
        lpErrorPos = lpTokenPos
    endif
end

// This recognises integer and decimal literals, optionally signed.
// All other non-delimiter atoms become LISP symbols.
integer proc LPIsNumber(string s)
    integer p = 1
    integer ndigits = 0
    integer dots = 0
    integer c
    if Length(s) == 0
        return (FALSE)
    endif
    if SubStr(s, 1, 1) == "-" or SubStr(s, 1, 1) == "+"
        p = 2
    endif
    while p <= Length(s)
        c = Asc(SubStr(s, p, 1))
        if LPIsDigit(c)
            ndigits = ndigits + 1
        elseif c == 46 and dots == 0
            dots = 1
        else
            return (FALSE)
        endif
        p = p + 1
    endwhile
    return (ndigits > 0)
end

proc LPAppend(integer c)
    if Length(lpValue) >= 240
        LPFail("Token exceeds 240 characters")
    else
        lpValue = lpValue + Chr(c)
    endif
end

proc LPNextToken()
    integer c
    integer escaped
    lpValue = ""
    if lpError
        return ()
    endif
    // Whitespace and Lisp line comments.
    c = LPPeek()
    while c == 9 or c == 10 or c == 13 or c == 32 or c == 59
        if c == 59
            while c <> 0 and c <> 10
                LPSkipChar()
                c = LPPeek()
            endwhile
        else
            LPSkipChar()
            c = LPPeek()
        endif
    endwhile
    lpTokenLine = lpLine
    lpTokenPos = lpPos
    if c == 0
        lpType = LP_EOF
        return ()
    endif
    lpTokens = lpTokens + 1
    if c == 40
        lpType = LP_LPAREN
        LPSkipChar()
        return ()
    elseif c == 41
        lpType = LP_RPAREN
        LPSkipChar()
        return ()
    elseif c == 39
        lpType = LP_QUOTE
        LPSkipChar()
        return ()
    elseif c == 34
        lpType = LP_STRING
        LPSkipChar()
        c = LPPeek()
        escaped = FALSE
        while c <> 0 and c <> 10
            if escaped
                // Preserve the character after a backslash as source text.
                LPAppend(c)
                escaped = FALSE
            elseif c == 92
                escaped = TRUE
            elseif c == 34
                LPSkipChar()
                return ()
            else
                LPAppend(c)
            endif
            if lpError
                return ()
            endif
            LPSkipChar()
            c = LPPeek()
        endwhile
        LPFail("Unterminated string (strings must end on the same line)")
        return ()
    endif
    // LISP symbols may contain punctuation such as +, -, *, /, ?, !.
    lpType = LP_SYMBOL
    while c <> 0 and c <> 9 and c <> 10 and c <> 13 and c <> 32 and c <> 40 and c <> 41 and c <> 39 and c <> 34 and c <> 59
        LPAppend(c)
        if lpError
            return ()
        endif
        LPSkipChar()
        c = LPPeek()
    endwhile
    if Length(lpValue) == 0
        LPFail("Unexpected character")
    elseif LPIsNumber(lpValue)
        lpType = LP_NUMBER
    endif
end

// EBNF:
// program    = { expression } ;
// expression = atom | '(' { expression } ')' | "'" expression ;
// atom       = number | symbol | string ;
// Note: no dotted pairs, quasiquote, unquote or reader macros in v1.
integer proc LPParseExpression()
    if lpError
        return (FALSE)
    endif
    lpEvalSteps = lpEvalSteps + 1
    if lpEvalSteps > 2000
        LPFail("Evaluation step limit exceeded (possible recursion)")
        return (FALSE)
    endif
    if lpType == LP_NUMBER or lpType == LP_SYMBOL or lpType == LP_STRING
        if lpViewMode == "T"
            LPTreeRow(LPTokenName(lpType), lpValue, lpTokenLine, lpTokenPos)
        endif
        LPNextToken()
        return (not lpError)
    endif
    if lpType == LP_QUOTE
        if lpViewMode == "T"
            LPTreeRow("QUOTE", "", lpTokenLine, lpTokenPos)
            lpTreeLevel = lpTreeLevel + 1
        endif
        LPNextToken()
        if lpType == LP_EOF
            LPFail("Expected expression after quote")
            return (FALSE)
        endif
        if not LPParseExpression()
            return (FALSE)
        endif
        if lpViewMode == "T"
            lpTreeLevel = lpTreeLevel - 1
        endif
        return (TRUE)
    endif
    if lpType == LP_LPAREN
        if lpViewMode == "T"
            LPTreeRow("LIST", "", lpTokenLine, lpTokenPos)
            lpTreeLevel = lpTreeLevel + 1
        endif
        lpDepth = lpDepth + 1
        if lpDepth > lpMaxDepth
            LPFail("Maximum nesting depth exceeded")
            return (FALSE)
        endif
        LPNextToken()
        while lpType <> LP_RPAREN and lpType <> LP_EOF and not lpError
            if not LPParseExpression()
                return (FALSE)
            endif
        endwhile
        if lpError
            return (FALSE)
        endif
        if lpType == LP_EOF
            LPFail("Expected ')' before end of file")
            return (FALSE)
        endif
        lpDepth = lpDepth - 1
        if lpViewMode == "T"
            lpTreeLevel = lpTreeLevel - 1
        endif
        LPNextToken()
        return (not lpError)
    endif
    if lpType == LP_RPAREN
        LPFail("Unexpected ')' without matching '('")
    else
        LPFail("Expected a LISP expression")
    endif
    return (FALSE)
end

// Runtime records live in a private TSE buffer. No external executables.
// Records: B|call-id|symbol|value  or F|name|line|column|argc|p1|p2|p3.
string proc LPField(string record, integer index)
    string part[255] = ""
    integer i = 1
    integer field = 1
    string ch[2]
    while i <= Length(record)
        ch = SubStr(record, i, 1)
        if ch == "|"
            if field == index
                return (part)
            endif
            field = field + 1
            part = ""
        elseif field == index and Length(part) < 250
            part = part + ch
        endif
        i = i + 1
    endwhile
    if field == index
        return (part)
    endif
    return ("")
end

proc LPRecord(string record)
    GotoBufferId(lpEnvBuffer)
    EndFile()
    AddLine(record)
    GotoBufferId(lpSourceBuffer)
end

integer proc LPFindBinding(string symbol)
    integer n
    string record[255]
    GotoBufferId(lpEnvBuffer)
    n = NumLines()
    while n > 0
        GotoLine(n)
        record = GetText(1, CurrLineLen())
        if LPField(record, 1) == "B" and LPField(record, 3) == symbol
            if Val(LPField(record, 2)) == lpActiveCall
                lpLookupValue = LPField(record, 4)
                GotoBufferId(lpSourceBuffer)
                return (TRUE)
            endif
            if Val(LPField(record, 2)) == 0 and lpActiveCall == 0
                lpLookupValue = LPField(record, 4)
                GotoBufferId(lpSourceBuffer)
                return (TRUE)
            endif
        endif
        n = n - 1
    endwhile
    GotoBufferId(lpSourceBuffer)
    return (FALSE)
end

integer proc LPFindFunction(string symbol)
    integer n
    string record[255]
    GotoBufferId(lpEnvBuffer)
    n = NumLines()
    while n > 0
        GotoLine(n)
        record = GetText(1, CurrLineLen())
        if LPField(record, 1) == "F" and LPField(record, 2) == symbol
            lpFuncLine = Val(LPField(record, 3))
            lpFuncPos = Val(LPField(record, 4))
            lpFuncArgc = Val(LPField(record, 5))
            lpFuncParam1 = LPField(record, 6)
            lpFuncParam2 = LPField(record, 7)
            lpFuncParam3 = LPField(record, 8)
            GotoBufferId(lpSourceBuffer)
            return (TRUE)
        endif
        n = n - 1
    endwhile
    GotoBufferId(lpSourceBuffer)
    return (FALSE)
end

integer proc LPIntegerLiteral(string s)
    integer i = 1
    string c[2]
    if Length(s) == 0
        return (FALSE)
    endif
    if SubStr(s, 1, 1) == "-" or SubStr(s, 1, 1) == "+"
        i = 2
    endif
    if i > Length(s)
        return (FALSE)
    endif
    while i <= Length(s)
        c = SubStr(s, i, 1)
        if c < "0" or c > "9"
            return (FALSE)
        endif
        i = i + 1
    endwhile
    return (TRUE)
end

// The evaluator consumes the same lexer stream used by P and T modes.
// v0.3 semantics: integer numbers, parameters, define, lambda, + - * /.
integer proc LPEvalExpression()
    string op[80] = ""
    string sym[80] = ""
    string p1[80] = ""
    string p2[80] = ""
    string p3[80] = ""
    string savedValue[255] = ""
    integer first = TRUE
    integer acc = 0
    integer value = 0
    integer argc = 0
    integer arg1 = 0
    integer arg2 = 0
    integer arg3 = 0
    integer savedLine = 0
    integer savedPos = 0
    integer savedType = 0
    integer savedTokLine = 0
    integer savedTokPos = 0
    integer savedCall = 0
    integer bodyLine = 0
    integer bodyPos = 0
    integer paramCount = 0
    integer callId = 0
    if lpError
        return (FALSE)
    endif
    lpEvalSteps = lpEvalSteps + 1
    if lpEvalSteps > 2000
        LPFail("Evaluation step limit exceeded (possible recursion)")
        return (FALSE)
    endif
    if lpType == LP_NUMBER
        if not LPIntegerLiteral(lpValue)
            LPFail("Evaluation currently supports integers only")
            return (FALSE)
        endif
        lpResult = lpValue
        LPNextToken()
        return (not lpError)
    endif
    if lpType == LP_SYMBOL
        sym = lpValue
        if not LPFindBinding(sym)
            LPFail("Unbound symbol: " + sym)
            return (FALSE)
        endif
        lpResult = lpLookupValue
        LPNextToken()
        return (not lpError)
    endif
    if lpType <> LP_LPAREN
        LPFail("Evaluation expects a number, symbol, or list")
        return (FALSE)
    endif
    LPNextToken()
    if lpType <> LP_SYMBOL
        LPFail("Expected operator or function after '('")
        return (FALSE)
    endif
    op = lpValue
    LPNextToken()
    if op == "define"
        if lpActiveCall <> 0
            LPFail("define is supported at top level only")
            return (FALSE)
        endif
        if lpType <> LP_SYMBOL
            LPFail("Expected function name after define")
            return (FALSE)
        endif
        sym = lpValue
        LPNextToken()
        if lpType <> LP_LPAREN
            LPFail("Expected (lambda ...) after function name")
            return (FALSE)
        endif
        LPNextToken()
        if lpType <> LP_SYMBOL or lpValue <> "lambda"
            LPFail("Expected lambda in function definition")
            return (FALSE)
        endif
        LPNextToken()
        if lpType <> LP_LPAREN
            LPFail("Expected '(' before lambda parameters")
            return (FALSE)
        endif
        LPNextToken()
        while lpType <> LP_RPAREN and lpType <> LP_EOF and not lpError
            if lpType <> LP_SYMBOL
                LPFail("Expected parameter name")
                return (FALSE)
            endif
            paramCount = paramCount + 1
            if paramCount == 1
                p1 = lpValue
            elseif paramCount == 2
                p2 = lpValue
            elseif paramCount == 3
                p3 = lpValue
            else
                LPFail("Maximum three parameters in this version")
                return (FALSE)
            endif
            LPNextToken()
        endwhile
        if lpType <> LP_RPAREN
            LPFail("Expected ')' after lambda parameters")
            return (FALSE)
        endif
        LPNextToken()
        bodyLine = lpTokenLine
        bodyPos = lpTokenPos
        if not LPParseExpression()
            return (FALSE)
        endif
        if lpType <> LP_RPAREN
            LPFail("Expected ')' after lambda body")
            return (FALSE)
        endif
        LPNextToken()
        if lpType <> LP_RPAREN
            LPFail("Expected ')' after define")
            return (FALSE)
        endif
        LPNextToken()
        LPRecord("F|" + sym + "|" + Str(bodyLine) + "|" + Str(bodyPos) + "|" + Str(paramCount) + "|" + p1 + "|" + p2 + "|" + p3)
        lpResult = "defined " + sym
        return (not lpError)
    endif
    if op == "+" or op == "-" or op == "*" or op == "/"
        if op == "*"
            acc = 1
        endif
        while lpType <> LP_RPAREN and lpType <> LP_EOF and not lpError
            if not LPEvalExpression()
                return (FALSE)
            endif
            value = Val(lpResult)
            if first and (op == "-" or op == "/")
                acc = value
            elseif op == "+"
                acc = acc + value
            elseif op == "-"
                acc = acc - value
            elseif op == "*"
                acc = acc * value
            elseif op == "/"
                if value == 0
                    LPFail("Division by zero")
                    return (FALSE)
                endif
                acc = acc / value
            endif
            first = FALSE
        endwhile
        if lpType <> LP_RPAREN
            LPFail("Expected ')' after arithmetic expression")
            return (FALSE)
        endif
        if first and (op == "-" or op == "/")
            LPFail("Expected at least one arithmetic operand")
            return (FALSE)
        endif
        LPNextToken()
        lpResult = Str(acc)
        return (not lpError)
    endif
    // User-defined function call: evaluate actual arguments before entering body.
    if not LPFindFunction(op)
        LPFail("Unknown function: " + op)
        return (FALSE)
    endif
    bodyLine = lpFuncLine
    bodyPos = lpFuncPos
    paramCount = lpFuncArgc
    p1 = lpFuncParam1
    p2 = lpFuncParam2
    p3 = lpFuncParam3
    while lpType <> LP_RPAREN and lpType <> LP_EOF and not lpError
        if not LPEvalExpression()
            return (FALSE)
        endif
        argc = argc + 1
        if argc == 1
            arg1 = Val(lpResult)
        elseif argc == 2
            arg2 = Val(lpResult)
        elseif argc == 3
            arg3 = Val(lpResult)
        else
            LPFail("Maximum three function arguments in this version")
            return (FALSE)
        endif
    endwhile
    if lpType <> LP_RPAREN
        LPFail("Expected ')' after function arguments")
        return (FALSE)
    endif
    if argc <> paramCount
        LPFail("Wrong number of arguments for " + op)
        return (FALSE)
    endif
    LPNextToken()
    // Resume this caller's token stream after function-body evaluation.
    savedLine = lpLine
    savedPos = lpPos
    savedType = lpType
    savedTokLine = lpTokenLine
    savedTokPos = lpTokenPos
    savedValue = lpValue
    savedCall = lpActiveCall
    lpNextCall = lpNextCall + 1
    callId = lpNextCall
    lpActiveCall = callId
    if paramCount > 0
        LPRecord("B|" + Str(callId) + "|" + p1 + "|" + Str(arg1))
    endif
    if paramCount > 1
        LPRecord("B|" + Str(callId) + "|" + p2 + "|" + Str(arg2))
    endif
    if paramCount > 2
        LPRecord("B|" + Str(callId) + "|" + p3 + "|" + Str(arg3))
    endif
    lpLine = bodyLine
    lpPos = bodyPos
    LPNextToken()
    if not LPEvalExpression()
        lpActiveCall = savedCall
        return (FALSE)
    endif
    lpActiveCall = savedCall
    lpLine = savedLine
    lpPos = savedPos
    lpType = savedType
    lpTokenLine = savedTokLine
    lpTokenPos = savedTokPos
    lpValue = savedValue
    return (not lpError)
end

proc LPGoError()
    if lpErrorLine <= NumLines() and lpErrorLine > 0
        GotoLine(lpErrorLine)
        GotoPos(lpErrorPos)
    endif
    Warn("LISP syntax error at " + Str(lpErrorLine) + ":" + Str(lpErrorPos) + ": " + lpErrorText)
end

proc Main()
    string mode[8] = "P"
    string ini[255]
    string setting[20]
    integer parsed
    if NumFiles() == 0
        Warn("Open a LISP source file in TSE first")
        return ()
    endif
    ini = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + "lispparser.ini"
    mode = GetProfileStr("Parser", "Mode", "P", ini)
    setting = GetProfileStr("Parser", "MaxDepth", "128", ini)
    lpMaxDepth = Val(setting)
    if lpMaxDepth < 1
        lpMaxDepth = 128
    endif
    if not Ask("LISP: P=parse L=lex K=tokens T=tree E=eval:", mode, 91)
        return ()
    endif
    mode = Upper(mode)
    if mode <> "P" and mode <> "L" and mode <> "K" and mode <> "T" and mode <> "E"
        Warn("Enter P, L, K, T or E")
        return ()
    endif
    lpViewMode = mode
    lpOutputBuffer = 0
    lpSourceBuffer = GetBufferId()
    lpTreeLevel = 0
    if mode == "K"
        if not LPOpenView("Tokens")
            Warn("Could not create token-listing buffer")
            return ()
        endif
        LPOutput("LINE:COL  TYPE  VALUE")
    elseif mode == "E"
        if not LPOpenView("Evaluation")
            Warn("Could not create evaluation buffer")
            return ()
        endif
        LPOutput("Integer Lisp evaluator (define/lambda, + - * /)")
        lpEnvBuffer = CreateBuffer("[LISP Runtime]")
        if lpEnvBuffer == 0
            Warn("Could not create runtime buffer")
            GotoBufferId(lpSourceBuffer)
            return ()
        endif
        GotoBufferId(lpSourceBuffer)
        lpActiveCall = 0
        lpNextCall = 0
        lpEvalSteps = 0
    elseif mode == "T"
        if not LPOpenView("Syntax Tree")
            Warn("Could not create tree buffer")
            return ()
        endif
        LPOutput("Hierarchical parse tree (syntax only; no evaluation)")
    endif
    lpLine = 1
    lpPos = 1
    lpLines = NumLines()
    lpTokens = 0
    lpForms = 0
    lpDepth = 0
    lpError = FALSE
    lpErrorText = ""
    PushPosition()
    LPNextToken()
    if mode == "L" or mode == "K"
        while lpType <> LP_EOF and not lpError
            if mode == "K"
                LPTokenRow()
            endif
            LPNextToken()
        endwhile
        parsed = not lpError
    else
        parsed = TRUE
        while lpType <> LP_EOF and not lpError and parsed
            if mode == "E"
                parsed = LPEvalExpression()
            else
                parsed = LPParseExpression()
            endif
            if parsed
                lpForms = lpForms + 1
                if mode == "E"
                    LPOutput("Result " + Str(lpForms) + ": " + lpResult)
                endif
            endif
        endwhile
    endif
    PopPosition()
    if lpOutputBuffer <> 0
        if lpError
            LPOutput("ERROR " + Str(lpErrorLine) + ":" + Str(lpErrorPos) + " " + lpErrorText)
        else
            if mode == "K"
                LPOutput("OK: " + Str(lpTokens) + " tokens")
            else
                LPOutput("OK: " + Str(lpTokens) + " tokens, " + Str(lpForms) + " top-level forms")
            endif
        endif
        GotoBufferId(lpOutputBuffer)
        BegFile()
    endif
    if lpError
        GotoBufferId(lpSourceBuffer)
        LPGoError()
    elseif not parsed
        Warn("LISP parser stopped without a completed expression")
    elseif mode == "L"
        Warn("LISP lexer OK: " + Str(lpTokens) + " tokens")
    elseif mode == "K"
        Warn("LISP token listing: " + Str(lpTokens) + " tokens")
    elseif mode == "T"
        Warn("LISP syntax tree: " + Str(lpForms) + " expressions")
    elseif mode == "E"
        Warn("LISP evaluation: " + Str(lpForms) + " forms completed")
    else
        Warn("LISP syntax OK: " + Str(lpForms) + " expressions, " + Str(lpTokens) + " tokens")
    endif
end
