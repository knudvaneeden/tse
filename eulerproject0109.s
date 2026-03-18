// Project Euler - Problem 109: Darts
// How many distinct ways can a player checkout with a score less than 100?
//
// Rules:
//   - Final dart must be a double (D1-D20, D25 = 50)
//   - Non-final darts: singles S1-S20, S25; doubles D1-D20, D25; trebles T1-T20
//   - Misses (S0) are NOT counted
//   - Two non-final darts are UNORDERED (count pairs, not permutations)
//   - Final double distinguishes checkouts (D1 D2 != D2 D1 as finish differs)
//   - Count checkouts with total < 100
//
// <version>1.0.0.0.1</version>

integer gNonFinalCountI    // how many non-final dart values
integer gDoubleCountI      // how many doubles
integer gAnswerI           // final answer
integer gNonFinalBufI      // buffer id for non-final dart values
integer gDoubleBufI        // buffer id for final double values

// ------------------------------------------------------------
// BuildDartValues
//   Populates gNonFinalBufI with all valid non-final dart scores,
//   and gDoubleBufI with all valid final-dart (double) scores.
//   Singles: S1-S20 (=1..20), S25 (=25)
//   Doubles: D1-D20 (=2..40 step 2), D25 (=50)
//   Trebles: T1-T20 (=3..60 step 3)
// ------------------------------------------------------------
proc BuildDartValues()
    integer nI
    integer nScore

    gNonFinalBufI = CreateTempBuffer()
    gDoubleBufI   = CreateTempBuffer()

    // --- Singles S1..S20 ---
    GotoBufferId(gNonFinalBufI)
    nI = 1
    while nI <= 20
        AddLine(Str(nI))
        nI = nI + 1
    endwhile
    // S25 (outer bull)
    AddLine(Str(25))

    // --- Doubles D1..D20 (values 2,4,...40) ---
    nI = 1
    while nI <= 20
        nScore = nI * 2
        AddLine(Str(nScore))
        nI = nI + 1
    endwhile
    // D25 (inner bull = 50)
    AddLine(Str(50))

    // --- Trebles T1..T20 (values 3,6,...60) ---
    nI = 1
    while nI <= 20
        nScore = nI * 3
        AddLine(Str(nScore))
        nI = nI + 1
    endwhile

    gNonFinalCountI = NumLines()

    // --- Doubles for final dart: D1..D20 + D25 ---
    GotoBufferId(gDoubleBufI)
    nI = 1
    while nI <= 20
        nScore = nI * 2
        AddLine(Str(nScore))
        nI = nI + 1
    endwhile
    // D25 = 50
    AddLine(Str(50))

    gDoubleCountI = NumLines()
end

// ------------------------------------------------------------
// GetNonFinal(idx) - returns value at line idx (1-based)
// ------------------------------------------------------------
integer proc GetNonFinal(integer nIdx)
    GotoBufferId(gNonFinalBufI)
    GotoLine(nIdx)
    return( Val(GetText(1, CurrLineLen())) )
end

// ------------------------------------------------------------
// GetDouble(idx) - returns value at line idx (1-based)
// ------------------------------------------------------------
integer proc GetDouble(integer nIdx)
    GotoBufferId(gDoubleBufI)
    GotoLine(nIdx)
    return( Val(GetText(1, CurrLineLen())) )
end

// ------------------------------------------------------------
// Main
// ------------------------------------------------------------
proc Main()
    integer nCount
    integer nDblIdx
    integer nDblVal
    integer nA, nB
    integer nAVal, nBVal
    integer nTotal
    string  sResult[20]

    BuildDartValues()

    nCount = 0

    // === 1-dart checkouts: just a double < 100 ===
    nDblIdx = 1
    while nDblIdx <= gDoubleCountI
        nDblVal = GetDouble(nDblIdx)
        if nDblVal < 100
            nCount = nCount + 1
        endif
        nDblIdx = nDblIdx + 1
    endwhile

    // === 2-dart checkouts: one non-final dart + double, total < 100 ===
    nDblIdx = 1
    while nDblIdx <= gDoubleCountI
        nDblVal = GetDouble(nDblIdx)
        nA = 1
        while nA <= gNonFinalCountI
            nAVal = GetNonFinal(nA)
            nTotal = nAVal + nDblVal
            if nTotal < 100
                nCount = nCount + 1
            endif
            nA = nA + 1
        endwhile
        nDblIdx = nDblIdx + 1
    endwhile

    // === 3-dart checkouts: two non-final darts (unordered, both >= 1)
    //     + double, total < 100
    //     Use nA <= nB to avoid counting (A,B) and (B,A) as different
    nDblIdx = 1
    while nDblIdx <= gDoubleCountI
        nDblVal = GetDouble(nDblIdx)
        nA = 1
        while nA <= gNonFinalCountI
            nAVal = GetNonFinal(nA)
            // nB starts at nA (allow same value repeated, e.g. S1 S1)
            nB = nA
            while nB <= gNonFinalCountI
                nBVal = GetNonFinal(nB)
                nTotal = nAVal + nBVal + nDblVal
                if nTotal < 100
                    nCount = nCount + 1
                endif
                nB = nB + 1
            endwhile
            nA = nA + 1
        endwhile
        nDblIdx = nDblIdx + 1
    endwhile

    // Clean up temp buffers
    AbandonFile(gNonFinalBufI)
    AbandonFile(gDoubleBufI)

    sResult = Str(nCount)
    CopyToWinClip(sResult)
    Warn("Project Euler Problem 109 - Darts" + Chr(13) +
         "Distinct checkouts with score < 100:" + Chr(13) +
         sResult)
end
