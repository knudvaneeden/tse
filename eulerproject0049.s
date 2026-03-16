// p049_prime_permutations.s
// Project Euler Problem 49 - Prime Permutations
//
// The arithmetic sequence 1487, 4817, 8147 (each term increases by 3330)
// is unusual: each term is prime AND each is a permutation of the others' digits.
// There is one other such 4-digit increasing sequence.
// Find the 12-digit number formed by concatenating its three terms.
//
// Strategy:
//   1. Build Sieve of Eratosthenes up to 9999 in a buffer
//      (line n holds "1" if n is prime, "0" otherwise; lines 0..9999)
//   2. For each 4-digit prime a (1000..3339):
//      For each step d (1..(9999-a)/2):
//        b = a+d, c = a+2d  -- all must be < 10000 (4-digit)
//        Check b and c are prime
//        Check a,b,c are all digit-permutations of each other
//        Skip the known sequence {1487,4817,8147}
//        Report the concatenation of a,b,c
//
// Note: SAL has INTEGER and STRING only; no floats, no arrays.
// Sieve stored as buffer lines; line index = number.

integer g_sieve_id   = 0     // buffer id for sieve

// ---------------------------------------------------------------
// IsPrime(n) - look up sieve buffer, return 1 if prime, 0 if not
// ---------------------------------------------------------------
integer proc IsPrime(integer n)
    if n < 2
        return( 0 )
    endif
    GotoBufferId( g_sieve_id )
    GotoLine( n + 1 )   // line 1 = number 0, line n+1 = number n
    if GetText(1, 1) == "1"
        return( 1 )
    endif
    return( 0 )
end

// ---------------------------------------------------------------
// SortedDigits(n) - returns a 4-char string of n's digits sorted
// ascending. Used to test if two numbers are digit permutations.
// n must be a 4-digit number (1000..9999).
// ---------------------------------------------------------------
string proc SortedDigits(integer n)
    string s[4]
    string tmp[1]
    integer i, j
    // Build digit string
    s = Chr( (n / 1000)       + Asc("0") )
      + Chr( (n / 100  mod 10)+ Asc("0") )
      + Chr( (n / 10   mod 10)+ Asc("0") )
      + Chr( (n        mod 10)+ Asc("0") )
    // Bubble sort the 4 characters ascending
    for j = 1 to 3
        for i = 1 to 4 - j
            if SubStr(s, i, 1) > SubStr(s, i+1, 1)
                tmp     = SubStr(s, i,   1)
                s       = SubStr(s, 1,   i-1)
                      + SubStr(s, i+1, 1)
                      + tmp
                      + SubStr(s, i+2, 4-i-1)
            endif
        endfor
    endfor
    return( s )
end

// ---------------------------------------------------------------
// BuildSieve - fills g_sieve_id buffer with 10000 lines
// line 1  = "1" (number 0 -- not prime, but we won't query it)
// line 2  = "0" (number 1 -- not prime)
// line 3  = "1" (number 2 -- prime)
// etc.
// After marking composites we flip composite lines to "0".
// ---------------------------------------------------------------
proc BuildSieve()
    integer n, mult
    g_sieve_id = CreateTempBuffer()
    // Insert 10000 lines, all "1" initially
    GotoBufferId( g_sieve_id )
    BegFile()
    // Line 1 already exists (empty) in a new buffer; fill it, then add the rest
    InsertText("1", _INSERT_)
    n = 1
    while n < 10000
        AddLine("1")
        n = n + 1
    endwhile
    // Mark 0 and 1 as not prime
    GotoLine(1)   BegLine()  KillToEol()  InsertText("0", _INSERT_)
    GotoLine(2)   BegLine()  KillToEol()  InsertText("0", _INSERT_)
    // Sieve: for each n from 2, mark multiples composite
    n = 2
    while n * n <= 9999
        GotoLine( n + 1 )
        if GetText(1,1) == "1"
            mult = n * n
            while mult <= 9999
                GotoLine( mult + 1 )
                BegLine()
                KillToEol()
                InsertText("0", _INSERT_)
                mult = mult + n
            endwhile
        endif
        n = n + 1
    endwhile
end

// ---------------------------------------------------------------
// Main
// ---------------------------------------------------------------
proc Main()
    integer a, b, c, d
    integer found
    string sa[4], sb[4], sc[4]
    string result[12]

    Message("Building sieve...")
    BuildSieve()
    Message("Sieve built. Searching...")

    found = 0
    a = 1000
    while a <= 9997 and found == 0
        if IsPrime(a)
            d = 1
            while d <= (9999 - a) / 2 and found == 0
                b = a + d
                c = a + 2 * d
                if c <= 9999
                    if IsPrime(b) and IsPrime(c)
                        sa = SortedDigits(a)
                        sb = SortedDigits(b)
                        sc = SortedDigits(c)
                        if sa == sb and sb == sc
                            // Skip the known example sequence
                            if a == 1487 and b == 4817 and c == 8147
                                // skip
                            else
                                result = Str(a) + Str(b) + Str(c)
                                found = 1
                            endif
                        endif
                    endif
                endif
                d = d + 1
            endwhile
        endif
        a = a + 1
    endwhile

    AbandonFile( g_sieve_id )

    if found
        CopyToWinClip( result )
        Warn("Euler 49: " + result)
    else
        Warn("No second sequence found.")
    endif
end
