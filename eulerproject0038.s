// Project Euler - Problem 38: Pandigital Multiples
// Find the largest 1-to-9 pandigital 9-digit number that can be formed
// as the concatenated product of an integer with (1,2,...,n) where n > 1.
//
// Example: 192 x 1=192, x2=384, x3=576 -> concat "192384576" (pandigital)
//          9   x 1=9,   x2=18,  x3=27, x4=36, x5=45 -> "918273645" (pandigital)
// Answer: 932718654

// ── IsPandigital9 ─────────────────────────────────────────────────────────
// Return 1 if s is exactly 9 chars containing each of '1'..'9' exactly once.

integer proc IsPandigital9(string s)
    integer i
    integer c
    integer d
    integer bit
    integer mask

    if Length(s) <> 9
        return(0)
    endif

    // Track which digits seen via bitmask (bit k = digit k seen).
    // All of 1-9 set => mask == 1022 (2^1 + 2^2 + ... + 2^9).
    mask = 0
    i = 1
    while i <= 9
        c = Asc(SubStr(s, i, 1))
        d = c - 48          // ASCII '0' = 48
        if d < 1 or d > 9
            return(0)       // digit 0 or non-digit: not 1-9 pandigital
        endif
        bit = 1 shl d
        if mask & bit
            return(0)       // duplicate digit
        endif
        mask = mask | bit
        i = i + 1
    endwhile

    if mask == 1022
        return(1)
    endif
    return(0)
end

// ── Main ──────────────────────────────────────────────────────────────────

proc Main()
    integer x
    integer n
    integer j
    integer prod
    integer candidate
    integer best
    string  concat[20]
    string  part[12]
    string  result[30]

    best = 0

    // x at most 4 digits: for x>=10000, x*1 + x*2 already exceeds 9 digits.
    x = 1
    while x <= 9999
        n = 2
        while n <= 9
            // Build concatenated product of x and (1, 2, ..., n)
            concat = ""
            j = 1
            while j <= n
                prod = x * j
                part = Str(prod)
                concat = concat + part
                if Length(concat) > 9
                    j = n + 1   // too long - break inner while
                else
                    j = j + 1
                endif
            endwhile

            if Length(concat) == 9 and IsPandigital9(concat)
                candidate = Val(concat)
                if candidate > best
                    best = candidate
                endif
            endif

            n = n + 1
        endwhile
        x = x + 1
    endwhile

    result = Str(best)
    CopyToWinClip(result)
    Warn("P038 Pandigital Multiples: " + result)
end
