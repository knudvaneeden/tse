// Project Euler - Problem 149: Maximum-sum Subsequence
// Find the greatest sum of adjacent entries in any direction
// in a 2000x2000 grid filled by a Lagged Fibonacci Generator.
//
// LFG definition:
//   For 1 <= k <= 55:   s[k] = (100003 - 200003*k + 300007*k^3) mod 1000000 - 500000
//   For 56 <= k <= 4M:  s[k] = (s[k-24] + s[k-55] + 1000000) mod 1000000 - 500000
//
// Two arithmetic pitfalls fixed for k=1..55:
//
// PITFALL 1 - Overflow in 300007*k^3:
//   After computing t = k^3 mod 1000000, the naive (t * 300007) overflows
//   32-bit signed because 999999 * 300007 = ~300 billion >> 2^31.
//   Fix: decompose 300007 = 300 * 1000 + 7 and apply mod at each step:
//     t = (k * k) mod 1000000           <- k^2 mod M  [max 55*55=3025, safe]
//     t = (t * k) mod 1000000           <- k^3 mod M  [max 999999*55=54.9M, safe]
//     a = (t * 300) mod 1000000         <- [max 999999*300=299.9M < 2^31, safe]
//     a = (a * 1000) mod 1000000        <- [max 999999*1000=999.9M < 2^31, safe]
//     b = (t * 7) mod 1000000           <- [max 999999*7=6.99M, safe]
//     t = (a + b) mod 1000000           <- 300007*k^3 mod M, no overflow
//
// PITFALL 2 - Negative dividend for SAL mod:
//   SAL uses C-style truncation-toward-zero mod (like C/Java), NOT Python
//   floor mod. For negative x: SAL gives (x mod M) < 0, Python gives >= 0.
//   The raw value (100003 - 200003*k + t) is as low as -10,397,911 (at k=54).
//   We need an offset that is a multiple of 1,000,000 and >= 10,397,911.
//   Offset = 11,000,000 guarantees the dividend is always positive:
//   minimum raw + offset = 100003 - 11000165 + 0 + 11000000 = 99838 > 0.
//   So (raw + 11000000) mod 1000000 gives the same result in SAL as Python.
//   Final: s[k] = (100003 - 200003*k + t + 11000000) mod 1000000 - 500000
//
// Strategy:
//   Store all 4,000,000 s-values in a TSE temp buffer, one per line.
//   Grid cell (r,c) (both 1-based) lives at line (r-1)*2000 + c.
//   For each row, column, main-diagonal, anti-diagonal sequence:
//     Fill a scratch buffer with those elements, run Kadane's algorithm.
//   Track the global maximum across all sequences.
//
// Diagonal indexing (stride = 2001, r and c both increase by 1):
//   Set A: anchor col=1, row=1..2000. startLine=(r-1)*2000+1. len=2001-r.
//   Set B: anchor row=1, col=2..2000. startLine=c.            len=2001-c.
//
// Anti-diagonal indexing (stride = 1999, r+1 and c-1):
//   Set A: anchor row=1, col=1..2000. startLine=c.              len=c.
//   Set B: anchor col=2000, row=2..2000. startLine=(r-1)*2000+2000. len=2001-r.
//
// Created by: Claude Sonnet 4.5 (Anthropic)
// <version>1.0.0.0.4</version>

integer gSBufI  = 0    // buffer holding all 4,000,000 s-values (one per line)
integer gBestI  = 0    // running global maximum sum found so far

// ---------------------------------------------------------------------------
// FNKadaneI: Kadane's maximum-subarray on the first nLenI lines of scrBufI.
// Returns the maximum contiguous subarray sum.
// Handles all-negative input correctly (returns the least-negative value).
// ---------------------------------------------------------------------------
integer proc FNKadaneI( integer scrBufI, integer nLenI )
    integer curSumI  = 0
    integer bestSumI = 0
    integer nValI    = 0
    integer iI       = 0
    integer firstB   = TRUE
    //
    GotoBufferId( scrBufI )
    BegFile()
    //
    for iI = 1 to nLenI
        nValI = Val( GetText( 1, CurrLineLen() ) )
        //
        if firstB
            curSumI  = nValI
            bestSumI = nValI
            firstB   = FALSE
        else
            if curSumI + nValI > nValI
                curSumI = curSumI + nValI
            else
                curSumI = nValI
            endif
            if curSumI > bestSumI
                bestSumI = curSumI
            endif
        endif
        //
        if iI < nLenI
            Down()
        endif
    endfor
    //
    return( bestSumI )
end

// ---------------------------------------------------------------------------
// ProcCheckSeqP: run Kadane on scrBufI and update gBestI if result is larger.
// ---------------------------------------------------------------------------
proc ProcCheckSeqP( integer scrBufI, integer nLenI )
    integer resI = 0
    //
    resI = FNKadaneI( scrBufI, nLenI )
    if resI > gBestI
        gBestI = resI
    endif
end

// ---------------------------------------------------------------------------
// ProcFillScratchP: populate scrBufI with nLenI values from gSBufI.
//   First element at absolute line startLineI; subsequent elements
//   spaced strideI lines apart.
// ---------------------------------------------------------------------------
proc ProcFillScratchP( integer scrBufI,
                        integer startLineI,
                        integer strideI,
                        integer nLenI )
    integer iI    = 0
    integer lineI = 0
    string  sS[30] = ""
    //
    GotoBufferId( scrBufI )
    EmptyBuffer()
    //
    for iI = 0 to nLenI - 1
        lineI = startLineI + iI * strideI
        GotoBufferId( gSBufI )
        GotoLine( lineI )
        sS = GetText( 1, CurrLineLen() )
        GotoBufferId( scrBufI )
        if iI == 0
            BegFile()
            BegLine()
            KillToEol()
            InsertText( sS )
        else
            AddLine( sS )
        endif
    endfor
    //
    GotoBufferId( scrBufI )
    BegFile()
end

// ---------------------------------------------------------------------------
// MAIN
// ---------------------------------------------------------------------------
proc Main()
    integer kI       = 0
    integer vI       = 0
    integer tI       = 0
    integer aI       = 0
    integer bI       = 0
    integer scrBufI  = 0
    integer rI       = 0
    integer cI       = 0
    integer diagLenI = 0
    integer startLI  = 0
    string  resS[30] = ""
    //
    // -----------------------------------------------------------------------
    // Step 1: Generate s[1..4000000] into gSBufI, one value per line.
    //   Line k in gSBufI holds s[k].
    // -----------------------------------------------------------------------
    gSBufI = CreateTempBuffer()
    if gSBufI == 0
        Warn( "ERROR: Cannot create s-buffer" )
        return()
    endif
    //
    GotoBufferId( gSBufI )
    EmptyBuffer()
    //
    // s[1..55]: polynomial formula with two overflow/mod fixes (see header).
    for kI = 1 to 55
        tI = ( kI * kI ) mod 1000000       // k^2 mod M  [max 3025, safe]
        tI = ( tI * kI ) mod 1000000       // k^3 mod M  [max 54.9M, safe]
        // Overflow-safe: (tI * 300007) mod 1000000
        // Decompose 300007 = 300*1000 + 7
        aI = ( tI * 300 ) mod 1000000      // [max 299.9M < 2^31, safe]
        aI = ( aI * 1000 ) mod 1000000     // [max 999.9M < 2^31, safe]
        bI = ( tI * 7 ) mod 1000000        // [max 6.99M, safe]
        tI = ( aI + bI ) mod 1000000       // 300007*k^3 mod M
        // +11000000 ensures dividend > 0 for all k=1..55 (see header)
        vI = ( 100003 - ( 200003 * kI ) + tI + 11000000 ) mod 1000000 - 500000
        //
        if kI == 1
            BegFile()
            BegLine()
            KillToEol()
            InsertText( Str( vI ) )
        else
            AddLine( Str( vI ) )
        endif
    endfor
    //
    // s[56..4000000]: Lagged Fibonacci recurrence.
    //   Values always in [-500000, 499999].
    //   Sum + 1000000 always in [0, 1999998] -> dividend always positive.
    //   SAL mod = Python mod here. No special handling needed.
    for kI = 56 to 4000000
        GotoLine( kI - 24 )
        vI = Val( GetText( 1, CurrLineLen() ) )
        GotoLine( kI - 55 )
        vI = ( vI + Val( GetText( 1, CurrLineLen() ) ) + 1000000 ) mod 1000000 - 500000
        GotoLine( kI - 1 )
        AddLine( Str( vI ) )
    endfor
    //
    // -----------------------------------------------------------------------
    // Step 2: Create scratch buffer for building sequences.
    // -----------------------------------------------------------------------
    scrBufI = CreateTempBuffer()
    if scrBufI == 0
        Warn( "ERROR: Cannot create scratch buffer" )
        AbandonFile( gSBufI )
        return()
    endif
    //
    gBestI = -500000   // minimum possible single-cell value
    //
    // -----------------------------------------------------------------------
    // Step 3: Rows (stride = 1).
    //   Row r (1-based): lines (r-1)*2000+1 to r*2000.
    // -----------------------------------------------------------------------
    for rI = 1 to 2000
        startLI = ( rI - 1 ) * 2000 + 1
        ProcFillScratchP( scrBufI, startLI, 1, 2000 )
        ProcCheckSeqP( scrBufI, 2000 )
    endfor
    //
    // -----------------------------------------------------------------------
    // Step 4: Columns (stride = 2000).
    //   Col c (1-based): lines c, c+2000, c+4000, ..., c+1999*2000.
    // -----------------------------------------------------------------------
    for cI = 1 to 2000
        ProcFillScratchP( scrBufI, cI, 2000, 2000 )
        ProcCheckSeqP( scrBufI, 2000 )
    endfor
    //
    // -----------------------------------------------------------------------
    // Step 5: Main diagonals top-left to bottom-right (stride = 2001).
    //   Set A: anchor (r,1) for r=1..2000, length = 2001-r.
    //   Set B: anchor (1,c) for c=2..2000, length = 2001-c.
    // -----------------------------------------------------------------------
    for rI = 1 to 2000
        diagLenI = 2001 - rI
        startLI  = ( rI - 1 ) * 2000 + 1
        ProcFillScratchP( scrBufI, startLI, 2001, diagLenI )
        ProcCheckSeqP( scrBufI, diagLenI )
    endfor
    //
    for cI = 2 to 2000
        diagLenI = 2001 - cI
        startLI  = cI
        ProcFillScratchP( scrBufI, startLI, 2001, diagLenI )
        ProcCheckSeqP( scrBufI, diagLenI )
    endfor
    //
    // -----------------------------------------------------------------------
    // Step 6: Anti-diagonals top-right to bottom-left (stride = 1999).
    //   Set A: anchor (1,c) for c=1..2000, length = c.
    //   Set B: anchor (r,2000) for r=2..2000, length = 2001-r.
    // -----------------------------------------------------------------------
    for cI = 1 to 2000
        diagLenI = cI
        startLI  = cI
        ProcFillScratchP( scrBufI, startLI, 1999, diagLenI )
        ProcCheckSeqP( scrBufI, diagLenI )
    endfor
    //
    for rI = 2 to 2000
        diagLenI = 2001 - rI
        startLI  = ( rI - 1 ) * 2000 + 2000
        ProcFillScratchP( scrBufI, startLI, 1999, diagLenI )
        ProcCheckSeqP( scrBufI, diagLenI )
    endfor
    //
    // -----------------------------------------------------------------------
    // Step 7: Report result.
    // -----------------------------------------------------------------------
    AbandonFile( scrBufI )
    AbandonFile( gSBufI )
    //
    resS = Str( gBestI )
    CopyToWinClip( resS )
    Warn( "Project Euler Problem 149"    + Chr(13) +
          "Maximum-sum Subsequence"       + Chr(13) +
          Chr(13) +
          "Answer: " + resS               + Chr(13) +
          Chr(13) +
          "(Answer copied to clipboard)"  )
end
