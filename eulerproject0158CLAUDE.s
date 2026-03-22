// Project Euler Problem 158 - Lexicographical Neighbours
// <version>1.0.0.0.1</version>
// Created by: Claude (Anthropic) - claude-sonnet-4-20250514
//
// History:
//   1.0.0.0.1 - 2026-03-22 - Initial version by Claude (Anthropic)
//
// Problem:
//   Taking strings of length n using n DIFFERENT letters from the 26-letter
//   alphabet, p(n) = count of strings where exactly ONE character comes
//   lexicographically after its neighbour to the left.
//   Find the maximum value of p(n) for n <= 26.
//
// Mathematics:
//   p(n) = C(26, n) * A(n, 1)
//   where A(n, 1) is the Eulerian number = 2^n - n - 1
//   (number of permutations of n elements with exactly 1 ascent)
//
//   Derivation:
//     1. Choose which n letters to use: C(26, n) ways.
//     2. Arrange them so exactly 1 adjacent pair is ascending (an "ascent").
//     3. This count is the Eulerian number A(n, 1) = 2^n - n - 1.
//
//   Products can exceed 32-bit integers (max ~409 billion),
//   so big-integer string arithmetic is used for C(26,n) and p(n).
//   The Eulerian values max at 67,108,837 which fits in a 32-bit SAL integer.

// ============================================================
// BigAdd: add two non-negative big integers (as decimal strings)
// Returns result string
// ============================================================
string proc BigAdd( string aS, string bS )
    string  resS[255]
    string  digitS[4]
    integer aLenI
    integer bLenI
    integer aIdxI
    integer bIdxI
    integer carryI
    integer sumI
    integer aDigI
    integer bDigI
    //
    resS   = ""
    aLenI  = Length( aS )
    bLenI  = Length( bS )
    aIdxI  = aLenI
    bIdxI  = bLenI
    carryI = 0
    //
    while aIdxI >= 1 OR bIdxI >= 1 OR carryI > 0
        aDigI = 0
        bDigI = 0
        if aIdxI >= 1
            aDigI = Asc( SubStr( aS, aIdxI, 1 ) ) - Asc( "0" )
            aIdxI = aIdxI - 1
        endif
        if bIdxI >= 1
            bDigI = Asc( SubStr( bS, bIdxI, 1 ) ) - Asc( "0" )
            bIdxI = bIdxI - 1
        endif
        sumI   = aDigI + bDigI + carryI
        carryI = sumI / 10
        sumI   = sumI mod 10
        digitS = Chr( sumI + Asc( "0" ) )
        resS   = digitS + resS
    endwhile
    //
    if Length( resS ) == 0
        resS = "0"
    endif
    //
    return( resS )
end

// ============================================================
// BigMulInt: multiply big integer string by a small integer
// Returns result string
// Carry is safe: max carry = (9 * 67108837 + 67108837) / 10 = 67108837 < 2^31
// ============================================================
string proc BigMulInt( string aS, integer nI )
    string  resS[255]
    string  digitS[4]
    integer aLenI
    integer aIdxI
    integer carryI
    integer prodI
    integer aDigI
    //
    resS   = ""
    aLenI  = Length( aS )
    aIdxI  = aLenI
    carryI = 0
    //
    while aIdxI >= 1 OR carryI > 0
        aDigI = 0
        if aIdxI >= 1
            aDigI = Asc( SubStr( aS, aIdxI, 1 ) ) - Asc( "0" )
            aIdxI = aIdxI - 1
        endif
        prodI  = aDigI * nI + carryI
        carryI = prodI / 10
        prodI  = prodI mod 10
        digitS = Chr( prodI + Asc( "0" ) )
        resS   = digitS + resS
    endwhile
    //
    if Length( resS ) == 0
        resS = "0"
    endif
    //
    return( resS )
end

// ============================================================
// BigDivInt: divide big integer string by a small integer
// Returns quotient string (integer division)
// ============================================================
string proc BigDivInt( string aS, integer nI )
    string  resS[255]
    integer aLenI
    integer aIdxI
    integer remI
    integer digitI
    integer quotDigI
    //
    resS  = ""
    aLenI = Length( aS )
    remI  = 0
    //
    aIdxI = 1
    while aIdxI <= aLenI
        digitI   = Asc( SubStr( aS, aIdxI, 1 ) ) - Asc( "0" )
        remI     = remI * 10 + digitI
        quotDigI = remI / nI
        remI     = remI mod nI
        if Length( resS ) > 0 OR quotDigI > 0
            resS = resS + Chr( quotDigI + Asc( "0" ) )
        endif
        aIdxI = aIdxI + 1
    endwhile
    //
    if Length( resS ) == 0
        resS = "0"
    endif
    //
    return( resS )
end

// ============================================================
// BigCmp: compare two non-negative big integer strings
// Returns: -1 if a < b,  0 if a == b,  1 if a > b
// ============================================================
integer proc BigCmp( string aS, string bS )
    integer aLenI
    integer bLenI
    integer idxI
    integer aChI
    integer bChI
    //
    aLenI = Length( aS )
    bLenI = Length( bS )
    //
    if aLenI < bLenI
        return( -1 )
    endif
    if aLenI > bLenI
        return( 1 )
    endif
    // same length: compare digit by digit left-to-right
    idxI = 1
    while idxI <= aLenI
        aChI = Asc( SubStr( aS, idxI, 1 ) )
        bChI = Asc( SubStr( bS, idxI, 1 ) )
        if aChI < bChI
            return( -1 )
        endif
        if aChI > bChI
            return( 1 )
        endif
        idxI = idxI + 1
    endwhile
    //
    return( 0 )
end

// ============================================================
// BigSubInt: subtract a small non-negative integer from a
// big integer string.  aS must be >= subtractI.
// Returns result string.
// ============================================================
string proc BigSubInt( string aS, integer subtractI )
    string  diffS[255]
    string  digitS[4]
    integer aLenI
    integer idxI
    integer aDigI
    integer diffI
    integer borrowI
    //
    aLenI   = Length( aS )
    diffS   = ""
    borrowI = subtractI
    //
    // Process digits right-to-left
    idxI = aLenI
    while idxI >= 1
        aDigI   = Asc( SubStr( aS, idxI, 1 ) ) - Asc( "0" )
        diffI   = aDigI - ( borrowI mod 10 )
        borrowI = borrowI / 10
        if diffI < 0
            diffI   = diffI + 10
            borrowI = borrowI + 1
        endif
        digitS = Chr( diffI + Asc( "0" ) )
        diffS  = digitS + diffS
        idxI   = idxI - 1
    endwhile
    //
    // Strip leading zeros
    while Length( diffS ) > 1 AND SubStr( diffS, 1, 1 ) == "0"
        diffS = SubStr( diffS, 2, Length( diffS ) - 1 )
    endwhile
    //
    return( diffS )
end

// ============================================================
// Main computation
// ============================================================
proc Main()
    // p(n) = C(26, n) * (2^n - n - 1)
    // Find maximum over n = 2..26
    //
    string  maxPnS[255]       // maximum p(n) found so far
    string  curPnS[255]       // current p(n) for this n
    string  combS[255]        // C(26, n), updated iteratively
    string  pow2S[255]        // 2^n, updated iteratively
    string  eulerS[255]       // Eulerian A(n,1) = 2^n - n - 1
    string  resultS[255]      // final answer string
    integer nI                // loop variable
    integer bestNI            // n giving maximum p(n)
    integer eulerIntI         // Eulerian value as SAL integer
    //
    maxPnS = "0"
    bestNI = 0
    //
    // C(26, n) iterated: C(26,0)=1, then C(26,n) = C(26,n-1)*(27-n)/n
    // 2^n iterated:      pow2 starts at 1 (=2^0), then doubled each step
    //
    combS = "1"   // C(26, 0)
    pow2S = "1"   // 2^0
    //
    nI = 1
    while nI <= 26
        // C(26, nI) = C(26, nI-1) * (27 - nI) / nI
        combS = BigMulInt( combS, 27 - nI )
        combS = BigDivInt( combS, nI )
        //
        // 2^nI = 2 * 2^(nI-1)
        pow2S = BigMulInt( pow2S, 2 )
        //
        // Eulerian A(nI, 1) = 2^nI - nI - 1
        // Only positive for nI >= 2  (A(1,1)=0, skip)
        //
        if nI >= 2
            eulerS    = BigSubInt( pow2S, nI + 1 )
            eulerIntI = Val( eulerS )         // safe: max 67108837 < 2^31
            curPnS    = BigMulInt( combS, eulerIntI )
            //
            if BigCmp( curPnS, maxPnS ) > 0
                maxPnS = curPnS
                bestNI = nI
            endif
        endif
        //
        nI = nI + 1
    endwhile
    //
    resultS = maxPnS
    //
    CopyToWinClip( resultS )
    //
    Warn( "Project Euler Problem 158 - Lexicographical Neighbours", Chr(13),
          "p(n) = C(26,n) * (2^n - n - 1),  max over n = 1..26", Chr(13),
          "---", Chr(13),
          "Best n   = ", Str( bestNI ), Chr(13),
          "p(", Str( bestNI ), ") = ", resultS )
    //
    CopyToWinClip( resultS )
    //
end
