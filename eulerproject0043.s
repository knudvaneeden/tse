// Project Euler - Problem 43: Sub-string Divisibility
// Find the sum of all 0-to-9 pandigital numbers with the sub-string
// divisibility property:
//   d2d3d4  divisible by  2
//   d3d4d5  divisible by  3
//   d4d5d6  divisible by  5
//   d5d6d7  divisible by  7
//   d6d7d8  divisible by 11
//   d7d8d9  divisible by 13
//   d8d9d10 divisible by 17
//
// Strategy:
//   - Represent the digit permutation as a 10-character string "0123456789"
//   - Iterate through all 10! permutations in lexicographic order using
//     the "next permutation" algorithm
//   - For each permutation check the 7 divisibility conditions
//   - Accumulate qualifying numbers
//
// SAL has 32-bit signed integers (max ~2.1e9), but the answer (~1.67e10)
// exceeds this. We therefore keep a string-based accumulator and implement
// 64-bit addition using two 32-bit halves (hi * 1e9 + lo).
//
// Version: 1.0

// ── helpers ──────────────────────────────────────────────────────────────────

// Return the digit character at position p (1-based) in string s
integer proc DigitAt(string s, integer p)
    return( Asc(s[p]) - 48 )  // '0' == 48
end

// Return the 3-digit value formed by positions p, p+1, p+2 (1-based)
integer proc Sub3(string s, integer p)
    return( DigitAt(s, p) * 100 + DigitAt(s, p+1) * 10 + DigitAt(s, p+2) )
end

// Swap two characters in a string at 1-based positions i and j
string proc SwapChars(string s, integer i, integer j)
    string p[10]    // local working copy
    string tmp[1]
    p   = s
    tmp = p[i]
    p[i] = p[j]
    p[j] = tmp
    return( p )
end

// Reverse the substring from position lo to hi (1-based) in s
string proc RevSub(string s, integer lo, integer hi)
    string  p[10]   // local working copy
    string  tmp[1]
    integer a, b
    p = s
    a = lo
    b = hi
    while a < b
        tmp  = p[a]
        p[a] = p[b]
        p[b] = tmp
        a = a + 1
        b = b - 1
    endwhile
    return( p )
end

// Advance s to the next lexicographic permutation.
// Returns "" when s is already the last permutation.
string proc NextPerm(string s)
    string  p[10]   // local working copy (SAL forbids reassigning string params)
    integer i, j

    p = s   // work on local copy

    // Step 1: find largest i such that p[i] < p[i+1]
    i = 9   // 1-based: positions 1..10, so start at 9
    while i >= 1 and Asc(p[i]) >= Asc(p[i+1])
        i = i - 1
    endwhile
    if i < 1
        return( "" )   // last permutation
    endif

    // Step 2: find largest j such that p[j] > p[i]
    j = 10
    while Asc(p[j]) <= Asc(p[i])
        j = j - 1
    endwhile

    // Step 3: swap p[i] and p[j]
    p = SwapChars(p, i, j)

    // Step 4: reverse suffix after position i
    p = RevSub(p, i+1, 10)

    return( p )
end

// Check the 7 sub-string divisibility conditions for a 10-char digit string
integer proc HasProperty(string s)
    // Checks are fully unrolled (SAL has no arrays)
    if Sub3(s,  2) mod  2 <> 0  return( FALSE )  endif
    if Sub3(s,  3) mod  3 <> 0  return( FALSE )  endif
    if Sub3(s,  4) mod  5 <> 0  return( FALSE )  endif
    if Sub3(s,  5) mod  7 <> 0  return( FALSE )  endif
    if Sub3(s,  6) mod 11 <> 0  return( FALSE )  endif
    if Sub3(s,  7) mod 13 <> 0  return( FALSE )  endif
    if Sub3(s,  8) mod 17 <> 0  return( FALSE )  endif
    return( TRUE )
end

// ── 64-bit accumulator ────────────────────────────────────────────────────────
// We store the running total as  hi * 1_000_000_000 + lo
// where 0 <= lo < 1_000_000_000  (fits in 32-bit signed fine)
// and hi is small (answer ~16.7 => hi = 16, lo = 695_334_890)

integer g_hi   // high part
integer g_lo   // low part

proc AddNum(string s)
    // Convert 10-char digit string to two halves:
    //   top  = first  digit  (d1)          — up to 9
    //   mid  = digits 2-5                  — up to 9999
    //   bot  = digits 6-10                 — up to 99999
    // Value = top*1e9 + mid*1e5 + bot
    // But 1e9 still fits in 32-bit (max 2.1e9), so we can compute hi/lo split.
    integer d1, d2, d3, d4, d5, d6, d7, d8, d9, d10
    integer lo_val, hi_val
    integer carry

    d1  = DigitAt(s,  1)
    d2  = DigitAt(s,  2)
    d3  = DigitAt(s,  3)
    d4  = DigitAt(s,  4)
    d5  = DigitAt(s,  5)
    d6  = DigitAt(s,  6)
    d7  = DigitAt(s,  7)
    d8  = DigitAt(s,  8)
    d9  = DigitAt(s,  9)
    d10 = DigitAt(s, 10)

    // lo_val = last 9 digits  (d2..d10 when d1=0, else d2..d10)
    // Actually we split at: lo = d2*1e8 + d3*1e7 + ... + d10
    //                       hi = d1
    // That way hi*1e9 + lo = the full 10-digit number.
    // Max lo = 9*111111111 < 1e9 — fits in 32-bit signed? 9*111111111 = 999999999 — yes!

    lo_val = d2  * 100000000  // 1e8
           + d3  * 10000000
           + d4  * 1000000
           + d5  * 100000
           + d6  * 10000
           + d7  * 1000
           + d8  * 100
           + d9  * 10
           + d10

    hi_val = d1   // single digit 1-9 (never 0 for a qualifying number, but fine)

    // Accumulate into g_hi:g_lo
    g_lo = g_lo + lo_val
    carry = g_lo / 1000000000
    g_lo  = g_lo mod 1000000000
    g_hi  = g_hi + hi_val + carry
end

// Format the 64-bit result as a decimal string
string proc FormatResult()
    string hi_s[20]
    string lo_s[20]
    string lo_pad[9]
    integer pad_len, i

    if g_hi == 0
        return( Str(g_lo) )
    endif

    hi_s  = Str(g_hi)
    lo_s  = Str(g_lo)

    // Zero-pad lo to exactly 9 digits
    lo_pad = lo_s
    pad_len = 9 - Length(lo_s)
    i = 1
    while i <= pad_len
        lo_pad = "0" + lo_pad
        i = i + 1
    endwhile

    return( hi_s + lo_pad )
end

// ── main ──────────────────────────────────────────────────────────────────────

proc Main()
    string  perm[10]
    string  result_str[30]
    integer count
    integer tmp_id

    g_hi  = 0
    g_lo  = 0
    count = 0

    perm = "0123456789"   // start from the first lexicographic permutation

    Message("Project Euler #43: scanning all 10! permutations...")

    repeat
        // Skip permutations starting with 0 (not 10-digit numbers)
        if Asc(perm[1]) <> 48   // '0'
            if HasProperty(perm)
                AddNum(perm)
                count = count + 1
            endif
        endif
        perm = NextPerm(perm)
    until Length(perm) == 0   // NextPerm returns "" when done

    result_str = FormatResult()

    // Copy result to clipboard via a temporary buffer
    tmp_id = CreateTempBuffer()
    if tmp_id
        GotoBufferId(tmp_id)
        BegFile()
        InsertText(result_str)
        BegLine()
        MarkLine()
        CopyToWinClip()
        AbandonFile(tmp_id)
    endif

    Warn("Project Euler #43 - Sub-string Divisibility",
         "",
         "Qualifying pandigital numbers found: " + Str(count),
         "",
         "Sum = " + result_str,
         "",
         "(Result copied to clipboard)")
end
