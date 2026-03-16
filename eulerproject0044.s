// Project Euler - Problem 44: Pentagon Numbers
//
// Pentagonal numbers: P(n) = n*(3*n - 1) / 2
// Find Pj, Pk where both (Pk+Pj) and (Pk-Pj) are pentagonal,
// and D = Pk - Pj is minimised.  Answer: 5482660
//
// Speed strategy:
//   Store all pentagonal numbers as fixed-width 12-char decimal
//   strings (right-justified, space-padded) in a single long
//   line in a temp buffer.  IsPentagonal(v) then does ONE lFind
//   call -- TSE's native search is fast C code, no SAL loop.
//
//   N_MAX = 5000 gives P(5000) = 37,492,500.
//   Largest value to test is sum of winning pair ~8.5M < 37.5M.
//
// Main loop uses FOR (bounded), never an unbounded WHILE,
// so there is no risk of hanging.

constant N_MAX      = 5000
constant FIELD_W    = 12    // fixed width per number in the string

integer g_pentBufId

// --------------- format integer as fixed-width 12-char string --------
string proc FmtFixed(integer v)
    string s[12]
    s = Str(v)
    // right-justify in FIELD_W chars by prepending spaces
    while Length(s) < FIELD_W
        s = " " + s
    endwhile
    return( s )
end

// --------------- build lookup buffer ---------------------------------
// One buffer, one line: all N_MAX pentagons as 12-char fields.
proc BuildTable()
    integer i, savedId
    string  line[255]
    savedId     = GetBufferId()
    g_pentBufId = CreateTempBuffer()
    GotoBufferId(g_pentBufId)
    EmptyBuffer()
    // Build in chunks of 20 to stay under the 255-char SAL string limit
    line = ""
    i = 1
    while i <= N_MAX
        line = line + FmtFixed(i * (3 * i - 1) / 2)
        if (i mod 20) == 0
            InsertText(line)
            line = ""
        endif
        i = i + 1
    endwhile
    if Length(line) > 0
        InsertText(line)
    endif
    GotoBufferId(savedId)
end

// --------------- test if v is pentagonal via lFind -------------------
integer proc IsPentagonal(integer v)
    integer savedId, found
    string  target[12]
    target  = FmtFixed(v)
    savedId = GetBufferId()
    GotoBufferId(g_pentBufId)
    BegFile()
    found = lFind(target, "g")
    GotoBufferId(savedId)
    return( found )
end

// --------------- pentagonal number -----------------------------------
integer proc Pent(integer n)
    return( n * (3 * n - 1) / 2 )
end

// --------------- main ------------------------------------------------
proc main()
    integer k, j, pk, pj, diffPair, sumPair, bestD
    string  resultStr[40]

    BuildTable()

    bestD = 0

    // Outer loop: k from 2 to N_MAX
    k = 2
    while k <= N_MAX
        pk = Pent(k)

        // Outer early-exit: consecutive gap exceeds bestD
        if bestD > 0
            if (pk - Pent(k - 1)) > bestD
                k = N_MAX + 1   // force outer loop exit
            endif
        endif

        if k <= N_MAX
            // Inner loop: j from k-1 down to 1
            j = k - 1
            while j >= 1
                pj       = Pent(j)
                diffPair = pk - pj

                // diffPair grows as j decreases; prune once > bestD
                if bestD > 0 and diffPair >= bestD
                    j = 0   // will become -1 after j=j-1, exits loop
                else
                    sumPair = pk + pj
                    if IsPentagonal(diffPair) and IsPentagonal(sumPair)
                        bestD = diffPair
                        j = 0
                    endif
                endif

                j = j - 1
            endwhile
        endif

        k = k + 1
    endwhile

    // Clean up
    AbandonFile(g_pentBufId)

    resultStr = Str(bestD)
    Warn("Project Euler Problem 44 -- Pentagon Numbers" +
         Chr(13) + Chr(10) +
         "D (minimum difference) = " + resultStr)
    CopyToWinClip(resultStr)
end
