// Version: 3
// Created by: Google Gemini
// Project Euler Problem 268: Counting numbers with at least four distinct prime factors less than 100

string TotalPos[255] = "0"
string TotalNeg[255] = "0"

// --- Helper Functions for Type Conversion ---

string proc IntToStr(integer num)
    string res[255] = ""
    integer n = num
    if n == 0
        Return("0")
    endif
    while n > 0
        res = Chr((n MOD 10) + 48) + res
        n = n / 10
    endwhile
    Return(res)
end

integer proc StrToInt(string s)
    integer res = 0
    integer i = 1
    while i <= Length(s)
        res = res * 10 + (Asc(SubStr(s, i, 1)) - 48)
        i = i + 1
    endwhile
    Return(res)
end

// --- Custom Big Integer Math Implementation ---

string proc BigAdd(string a, string b)
    integer carry = 0
    integer i = Length(a)
    integer j = Length(b)
    integer sum = 0
    string res[255] = ""

    while i > 0 or j > 0 or carry > 0
        sum = carry
        if i > 0
            sum = sum + Asc(SubStr(a, i, 1)) - 48
            i = i - 1
        endif
        if j > 0
            sum = sum + Asc(SubStr(b, j, 1)) - 48
            j = j - 1
        endif
        res = Chr((sum MOD 10) + 48) + res
        carry = sum / 10
    endwhile
    if res == ""
        res = "0"
    endif
    Return(res)
end

string proc BigSub(string a, string b)
    integer borrow = 0
    string loc_a[255] = a
    string loc_b[255] = b
    integer i = Length(loc_a)
    integer j = Length(loc_b)
    integer diff = 0
    string res[255] = ""

    // Pad loc_b to the left with zeros
    while Length(loc_b) < Length(loc_a)
        loc_b = "0" + loc_b
    endwhile
    // Pad loc_a to the left with zeros
    while Length(loc_a) < Length(loc_b)
        loc_a = "0" + loc_a
    endwhile
    i = Length(loc_a)
    j = Length(loc_b)

    while i > 0
        diff = Asc(SubStr(loc_a, i, 1)) - 48 - borrow
        if j > 0
            diff = diff - (Asc(SubStr(loc_b, j, 1)) - 48)
            j = j - 1
        endif
        if diff < 0
            diff = diff + 10
            borrow = 1
        else
            borrow = 0
        endif
        res = Chr(diff + 48) + res
        i = i - 1
    endwhile

    // Remove leading zeros
    while Length(res) > 1 and SubStr(res, 1, 1) == "0"
        res = SubStr(res, 2, Length(res) - 1)
    endwhile
    Return(res)
end

string proc BigMultSmall(string a, integer b)
    integer carry = 0
    integer i = Length(a)
    integer prod = 0
    string res[255] = ""

    if a == "0" or b == 0
        Return("0")
    endif

    while i > 0 or carry > 0
        prod = carry
        if i > 0
            prod = prod + (Asc(SubStr(a, i, 1)) - 48) * b
            i = i - 1
        endif
        res = Chr((prod MOD 10) + 48) + res
        carry = prod / 10
    endwhile
    Return(res)
end

string proc BigDivSmall(string a, integer b)
    integer i = 1
    integer len = Length(a)
    integer rem = 0
    integer digit = 0
    string res[255] = ""

    if b == 0 
        Return("Error") 
    endif

    while i <= len
        rem = rem * 10 + (Asc(SubStr(a, i, 1)) - 48)
        digit = rem / b
        res = res + Chr(digit + 48)
        rem = rem MOD b
        i = i + 1
    endwhile

    while Length(res) > 1 and SubStr(res, 1, 1) == "0"
        res = SubStr(res, 2, Length(res) - 1)
    endwhile
    Return(res)
end

// --- Problem Specific Math ---

integer proc GetCoef(integer count)
    integer c = 0
    if count >= 4
        // Combinations: C(count - 1, 3)
        c = (count - 1) * (count - 2) * (count - 3) / 6
    endif
    Return(c)
end

integer proc GetPrime(integer idx)
    if idx == 1 Return(2) endif
    if idx == 2 Return(3) endif
    if idx == 3 Return(5) endif
    if idx == 4 Return(7) endif
    if idx == 5 Return(11) endif
    if idx == 6 Return(13) endif
    if idx == 7 Return(17) endif
    if idx == 8 Return(19) endif
    if idx == 9 Return(23) endif
    if idx == 10 Return(29) endif
    if idx == 11 Return(31) endif
    if idx == 12 Return(37) endif
    if idx == 13 Return(41) endif
    if idx == 14 Return(43) endif
    if idx == 15 Return(47) endif
    if idx == 16 Return(53) endif
    if idx == 17 Return(59) endif
    if idx == 18 Return(61) endif
    if idx == 19 Return(67) endif
    if idx == 20 Return(71) endif
    if idx == 21 Return(73) endif
    if idx == 22 Return(79) endif
    if idx == 23 Return(83) endif
    if idx == 24 Return(89) endif
    if idx == 25 Return(97) endif
    Return(0)
end

// --- Optimized Integer DFS Search ---

proc DFS_Int(integer idx, integer current_N, integer count)
    integer i = idx
    integer p = 0
    integer next_N = 0
    integer coef = 0
    string term[255] = ""

    if count >= 4
        coef = GetCoef(count)
        term = BigMultSmall(IntToStr(current_N), coef)
        if ((count - 4) MOD 2) == 0
            TotalPos = BigAdd(TotalPos, term)
        else
            TotalNeg = BigAdd(TotalNeg, term)
        endif
    endif

    while i <= 25
        p = GetPrime(i)
        next_N = current_N / p
        if next_N == 0
            i = 26 
        else
            DFS_Int(i + 1, next_N, count + 1)
        endif
        i = i + 1
    endwhile
end

// --- Primary String BigInt DFS Search ---

proc DFS(integer idx, string current_N, integer count)
    integer i = idx
    integer p = 0
    string next_N[255] = ""
    integer coef = 0
    string term[255] = ""

    // Optimization: Fallback to fast 32-bit native ints when safe (length < 9 limits to 99,999,999 max)
    if Length(current_N) < 9
        DFS_Int(idx, StrToInt(current_N), count)
        Return()
    endif

    if count >= 4
        coef = GetCoef(count)
        term = BigMultSmall(current_N, coef)
        if ((count - 4) MOD 2) == 0
            TotalPos = BigAdd(TotalPos, term)
        else
            TotalNeg = BigAdd(TotalNeg, term)
        endif
    endif

    while i <= 25
        p = GetPrime(i)
        next_N = BigDivSmall(current_N, p)
        if next_N == "0"
            i = 26 
        else
            DFS(i + 1, next_N, count + 1)
        endif
        i = i + 1
    endwhile
end

proc Main()
    string final_answer[255] = ""

    TotalPos = "0"
    TotalNeg = "0"

    // Limit N is < 10^16, meaning N = 9999999999999999
    DFS(1, "9999999999999999", 0)

    final_answer = BigSub(TotalPos, TotalNeg)

    CopyToWinClip(final_answer)
    Warn("Project Euler 268 Result: ", final_answer)
    CopyToWinClip(final_answer)
end
