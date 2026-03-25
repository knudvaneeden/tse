// File: Euler209.s
// Version: 1.4
// LLM: Google Gemini
// Problem: Project Euler 209
// Rule Check: Used 'shr'/'shl', String sizes [255] added, All declarations at top,
//            no assignments in declarations, MOD used, Return() with parens,
//            BigInt string math, no 'val'/'pos' vars, AbandonFile() used.

// --- Big Integer Library (String Based) ---

string proc ReverseString(string s)
    integer i
    string res[255]

    res = ""
    i = Length(s)
    while i > 0
        res = res + SubStr(s, i, 1)
        i = i - 1
    endwhile
    Return(res)
end

string proc BigAdd(string s1, string s2)
    integer i1
    integer i2
    integer carry
    integer digit1
    integer digit2
    integer sum
    string res[255]

    res = ""
    carry = 0
    i1 = Length(s1)
    i2 = Length(s2)

    while i1 > 0 | i2 > 0 | carry > 0
        digit1 = 0
        digit2 = 0
        if i1 > 0
            digit1 = Asc(SubStr(s1, i1, 1)) - 48
            i1 = i1 - 1
        endif
        if i2 > 0
            digit2 = Asc(SubStr(s2, i2, 1)) - 48
            i2 = i2 - 1
        endif
        sum = digit1 + digit2 + carry
        carry = sum / 10
        res = res + Chr((sum MOD 10) + 48)
    endwhile
    Return(ReverseString(res))
end

string proc BigMul(string s1, string s2)
    integer i
    integer j
    integer d1
    integer d2
    integer carry
    integer temp_sum
    integer res_idx
    integer res_digit
    string res[255]
    
    res = ""
    for i = 1 to Length(s1) + Length(s2)
        res = res + "0"
    endfor
    
    for i = Length(s1) downto 1
        d1 = Asc(SubStr(s1, i, 1)) - 48
        carry = 0
        for j = Length(s2) downto 1
            d2 = Asc(SubStr(s2, j, 1)) - 48
            res_idx = i + j
            res_digit = Asc(SubStr(res, res_idx, 1)) - 48
            temp_sum = res_digit + (d1 * d2) + carry
            res = SubStr(res, 1, res_idx - 1) + Chr((temp_sum MOD 10) + 48) + SubStr(res, res_idx + 1, Length(res) - res_idx)
            carry = temp_sum / 10
        endfor
        
        if carry > 0
            res_idx = i
            res_digit = Asc(SubStr(res, res_idx, 1)) - 48
            temp_sum = res_digit + carry
            res = SubStr(res, 1, res_idx - 1) + Chr((temp_sum MOD 10) + 48) + SubStr(res, res_idx + 1, Length(res) - res_idx)
        endif
    endfor
    
    while Length(res) > 1 and SubStr(res, 1, 1) == "0"
        res = SubStr(res, 2, Length(res) - 1)
    endwhile
    
    Return(res)
end

// --- Problem Logic ---

integer proc GetNextState(integer u)
    integer x1
    integer x2
    integer x3
    integer new_bit
    integer res
    
    // Using shr and shl as per TSE SAL documentation
    x1 = (u shr 5) & 1
    x2 = (u shr 4) & 1
    x3 = (u shr 3) & 1
    new_bit = x1 ^ (x2 & x3)
    res = ((u & 31) shl 1) | new_bit
    Return(res)
end

proc Main()
    string visited[70]
    string total_ways[255]
    string l_minus_1[255]
    string l_minus_2[255]
    string current_lucas[255]
    integer i
    integer current_node
    integer cycle_len
    integer lucas_buf
    
    visited = ""
    for i = 1 to 64
        visited = visited + "0"
    endfor

    lucas_buf = CreateBuffer("lucas_table")
    AddLine("1") // L1
    AddLine("3") // L2
    l_minus_2 = "1"
    l_minus_1 = "3"

    for i = 3 to 64
        current_lucas = BigAdd(l_minus_1, l_minus_2)
        AddLine(current_lucas)
        l_minus_2 = l_minus_1
        l_minus_1 = current_lucas
    endfor

    total_ways = "1"

    for i = 0 to 63
        if SubStr(visited, i + 1, 1) == "0"
            cycle_len = 0
            current_node = i
            while SubStr(visited, current_node + 1, 1) == "0"
                visited = SubStr(visited, 1, current_node) + "1" + SubStr(visited, current_node + 2, 64 - current_node - 1)
                cycle_len = cycle_len + 1
                current_node = GetNextState(current_node)
            endwhile

            GotoLine(cycle_len)
            total_ways = BigMul(total_ways, GetText(1, 255))
        endif
    endfor

    AbandonFile(lucas_buf)

    CopyToWinClip(total_ways)
    Warn(total_ways)
    CopyToWinClip(total_ways)
end
