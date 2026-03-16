// Project Euler - Problem 32: Pandigital Products
//
// Find the sum of all products whose multiplicand/multiplier/product
// identity can be written as a 1-through-9 pandigital.
// (Each digit 1-9 used exactly once across a, b, and a*b)
//
// Strategy: only two digit-length combos work: (1,4,4) and (2,3,4).
// Pandigital check: concatenate Str(a)+Str(b)+Str(c), sort the 9 chars,
// compare to "123456789".
// Collect unique products in a temp buffer, then sum them.
//
// Answer: 45228

// Sort a 9-character string of digits (insertion sort)
string proc SortStr9(string s)
    string t[10]
    string tmp[2]
    integer i, j
    t = s
    i = 2
    while i <= 9
        j = i
        while j > 1 AND SubStr(t, j, 1) < SubStr(t, j-1, 1)
            t = SubStr(t, 1, j-2) + SubStr(t, j, 1) + SubStr(t, j-1, 1) + SubStr(t, j+1, 9)
            j = j - 1
        endwhile
        i = i + 1
    endwhile
    return(t)
end

// Returns TRUE if digits of a, b, c together are exactly 1-9 each once
integer proc IsPandigital9(integer a, integer b, integer c)
    string s[10]
    s = Str(a) + Str(b) + Str(c)
    if Length(s) <> 9
        return(FALSE)
    endif
    return(SortStr9(s) == "123456789")
end

// Add prod to buffer if not already present (one integer string per line)
proc AddUniqueProduct(integer prod_buf_id, integer prod)
    integer found
    integer save_id
    string line[20]
    string target[20]

    save_id = GetBufferId()
    target = Str(prod)
    found = FALSE
    GotoBufferId(prod_buf_id)
    BegFile()
    repeat
        line = GetText(1, CurrLineLen())
        if line == target
            found = TRUE
        endif
    until found OR NOT Down()

    if NOT found
        EndFile()
        AddLine(target)
    endif
    GotoBufferId(save_id)
end

proc Main()
    integer prod_buf_id
    integer a, b, c
    integer total
    string line[20]
    string result[60]

    prod_buf_id = CreateTempBuffer()

    // Case 1: a has 1 digit (1-9), b has 4 digits (1234-9876)
    a = 1
    while a <= 9
        b = 1234
        while b <= 9876
            c = a * b
            if IsPandigital9(a, b, c)
                AddUniqueProduct(prod_buf_id, c)
            endif
            b = b + 1
        endwhile
        a = a + 1
    endwhile

    // Case 2: a has 2 digits (12-98), b has 3 digits (123-987)
    a = 12
    while a <= 98
        b = 123
        while b <= 987
            c = a * b
            if IsPandigital9(a, b, c)
                AddUniqueProduct(prod_buf_id, c)
            endif
            b = b + 1
        endwhile
        a = a + 1
    endwhile

    // Sum all unique products
    total = 0
    GotoBufferId(prod_buf_id)
    BegFile()
    repeat
        line = GetText(1, CurrLineLen())
        if Length(line) > 0
            total = total + Val(line)
        endif
    until NOT Down()

    result = "Euler 32 - Pandigital Products sum = " + Str(total)
    Warn(result)
    CopyToWinClip(result)

    AbandonFile(prod_buf_id)
end
