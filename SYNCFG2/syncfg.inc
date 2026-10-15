// SYNCFG2 package version 1.0.0.0.8
// Dependency supplied with TSE 4.50.32; original contents retained below.
// constant strings
string
    directive_str[] = "Directive",
    keyword_str[] = "KeyWords",
    multiline_delimited_str[] = "MultiLineDelimited",
    option_strs[] = "HiliteIncompleteQuotes IgnoreCaseOfKeyWords HiliteIf0StyleComments Transparent CursorLineFlag NumberFlag WordSet",
    quote_escape_str[] = "QuoteEscape",
    quote_str[] = "Quote",
    singleline_delimited_str[] = "SingleLineDelimited",
    till_end_of_line_str[] = "TillEOL",
    till_end_of_line_start_col_str[] = "TillEOLStartCol",
    wordset_str[] = "WordSet",

    cursorline_overrides[] = "CursorLineOverrides",
    syntaxhilite_overrides[] = "SyntaxHiliteOverrides",
    transparent_cursorline[] = "TransparentCursorLine",

    // assume these are in strict order of the numeric flags, and 1 2 4 8 16 32 64 128 256 512 1024
    numeric_flag_str[]   = "Integer C-Hex ASM-Hex Pascal-Hex Binary Real Sci-Notation Comma C-UL BASIC-Hex Sci-DP-Notation Euphoria-Hex  SAL-Binary Underline",
    numeric_flag_nnn[]   = "0000000 11111 2222222 3333333333 444444 5555 666666666666 77777 8888 999999999 aaaaaaaaaaaaaaa bbbbbbbbbbbb  cccccccccc ddddddddd",

    numeric_flag_str_old[] = " Whole",
    numeric_flag_nnn_old[] = " 00000"

integer proc Pow(integer base, integer exponent)
    integer i, result

    if exponent == 0
        return (1)
    endif

    result = base
    for i = 2 to exponent
        result = result * base
    endfor

    return (result)
end

integer proc EncodeNumericFlag(string s)
    integer i, flag, n, p
    string token[80],
        num_flag_str[255] = numeric_flag_str + numeric_flag_str_old,
        num_flag_nnn[255] = numeric_flag_nnn + numeric_flag_nnn_old

    if Trim(s) == ""
        return (0)
    elseif isDigit(s)
        return (Val(s))
    endif

    flag = 0
    n = NumTokens(s, '|')
    for i = 1 to n
        token = GetToken(s, '|', i)
        p = Pos(Lower(token), Lower(num_flag_str))
        if p
            flag = flag | Pow(2, Val(num_flag_nnn[p], 16))
        else
            Warn("Unrecognized numeric flag value:", token)
        endif
    endfor
    return (flag)
end

integer proc EncodeCursorLineFlag(string s)
    case Lower(s)
        when '0', Lower(cursorline_overrides)    return (0)
        when '1', Lower(syntaxhilite_overrides)  return (1)
        when '2', Lower(transparent_cursorline)  return (2)
        otherwise
            Warn("Unrecognized value for CursorLineFlag:", s)
    endcase
    return (0)
end

// handle CURSOR_LINE_FLAG
string proc DecodeCursorLineFlag(integer flag)
    case flag
        when 0 return(cursorline_overrides)
        when 1 return(syntaxhilite_overrides)
        when 2 return(transparent_cursorline)
    endcase

    return (Str(flag) + " is an unknown value!")
end

string proc DecodeNumericFlag(integer flag)
    string s[255]
    integer bit, i

    s = ""
    bit = 1
    for i = 1 to TOTAL_NUMERIC_FLAGS
        if flag & bit
            s = s + GetToken(numeric_flag_str, ' ', i) + "|"
        endif
        bit = bit * 2
    endfor
    s = Trim(s)
    return (iif(s == "", "0", s[1:Length(s) - 1]))
end

