
// ===========================================================================
// Filename   : euler171.s
// Version    : 1.1
// Description: Project Euler - Problem 171
//              "Finding numbers for which the sum of the squares of
//               the digits is a perfect square"
//
//              For a positive integer n, let f(n) be the sum of the squares
//              of the digits (in base 10) of n:
//                f(3)   = 3^2 = 9
//                f(25)  = 2^2 + 5^2 = 29
//                f(442) = 4^2 + 4^2 + 2^2 = 36
//
//              Find the last nine digits of the sum of all n,
//              0 < n < 10^20, such that f(n) is a perfect square.
//
//              Answer: 142989277
//
// URL        : https://projecteuler.net/problem=171
// Author     : Perplexity Computer (LLM: Claude Sonnet 4.6)
// Date       : 2026-03-22
//
// History    :
//   1.0  2026-03-22  Created by Perplexity Computer (LLM: Claude Sonnet 4.6)
//   1.1  2026-03-22  Fixed: TSE SAL has no 'Integer Function'; all subprograms
//                    are 'Proc'. Return values passed via global variables.
//
// ---------------------------------------------------------------------------
// Algorithm:
//   All 20-digit numbers (with leading zeros) having the same multiset of
//   digits share the same f(n).  We enumerate all multisets of 20 digits
//   in non-decreasing order and, for each multiset where f(n) is a perfect
//   square, compute (mod 10^9) the sum of all 20-digit permutations.
//
//   Sum formula -- avoids any division:
//     Let cnt[d] = count of digit d (d = 0..9), total = 20.
//     For each d with cnt[d] > 0:
//       Temporarily set cnt[d] -= 1 (now 19 items remain)
//       Compute inner_mn19 = product of C[remaining][cnt[k]] for k = 0..9
//                          = multinomial(19; cnt[0]..cnt[d]-1..cnt[9])  mod MODULO
//       Contribution of digit d = d * inner_mn19 * 111111111  (mod MODULO)
//       Restore cnt[d] += 1
//     Sum all digit contributions into the running answer, mod MODULO.
//
//   32-bit safety (MODULO = 10^9 < 2^30):
//     MulMod(a,b): Russian peasant. a,b < MODULO < 2^30.
//       a+a < 2*MODULO < 2^31-1.  res+a < 2*MODULO < 2^31-1.  Safe.
//     C[n][k] <= C(20,10) = 184756 -- fits in 32-bit.
//     sq_sum max = 20*81 = 1620 -- fits in 32-bit.
//     ones9 = 111111111 -- fits in 32-bit.
//     Accumulation: each addition < 2*MODULO < 2^31-1.  Safe.
// ===========================================================================

// ---------------------------------------------------------------------------
// Global variables
// ---------------------------------------------------------------------------

// Digit counts for the current multiset being built
Integer gCnt0
Integer gCnt1
Integer gCnt2
Integer gCnt3
Integer gCnt4
Integer gCnt5
Integer gCnt6
Integer gCnt7
Integer gCnt8
Integer gCnt9

// Buffer IDs
Integer gCBuf       // Pascal's triangle: line (n*21+k+1) holds C(n,k)
Integer gSqBuf      // isSquare table:    line (sq+1) holds "1" or "0"
Integer gLvlDBuf    // DFS stack: digit chosen at level L  (line L)
Integer gLvlMBuf    // DFS stack: minimum digit at level L (line L)

// MODULO = 1,000,000,000
Integer gMODULO

// Running answer (mod MODULO)
Integer gAnswer

// Return value globals (TSE SAL has no Integer Function, only Proc)
Integer gCResult        // return value of GetC()
Integer gBufIntResult   // return value of GetBufInt()
Integer gMulModResult   // return value of MulMod()
Integer gGetCntResult   // return value of GetCntD()
Integer gIsSqResult     // return value of IsSqIndex()

// ---------------------------------------------------------------------------
// Proc: GetBufInt(bufId, lineNr)
// Result returned in gBufIntResult
// ---------------------------------------------------------------------------
Proc GetBufInt(Integer bufId, Integer lineNr)
    Integer prevBuf
    String  ls[32]

    prevBuf = GetBufferId()
    GotoBufferId(bufId)
    GotoLine(lineNr)
    BegLine()
    ls = GetText(1, CurrLineLen())
    gBufIntResult = Val(ls)
    GotoBufferId(prevBuf)
End

// ---------------------------------------------------------------------------
// Proc: SetBufInt(bufId, lineNr, wval) -- write integer to a buffer line
// ---------------------------------------------------------------------------
Proc SetBufInt(Integer bufId, Integer lineNr, Integer wval)
    Integer prevBuf

    prevBuf = GetBufferId()
    GotoBufferId(bufId)
    GotoLine(lineNr)
    BegLine()
    KillToEol()
    InsertText(Str(wval), _INSERT_)
    GotoBufferId(prevBuf)
End

// ---------------------------------------------------------------------------
// Proc: InitCombTable
// Build Pascal's triangle in gCBuf.
// Line index = n*21 + k + 1 (1-based) holds C(n,k) as a string.
// n and k range 0..20  =>  21*21 = 441 lines.
// ---------------------------------------------------------------------------
Proc InitCombTable()
    Integer nn
    Integer kk
    Integer prev1
    Integer prev2
    Integer cval
    String  ls[32]

    gCBuf = CreateTempBuffer()
    GotoBufferId(gCBuf)

    // Pre-fill 441 lines with "0"
    nn = 0
    While nn < 441
        AddLine("0")
        nn = nn + 1
    EndWhile

    // Fill row by row using Pascal's recurrence
    nn = 0
    While nn <= 20

        // C[nn][0] = 1
        GotoLine(nn * 21 + 0 + 1)
        BegLine()
        KillToEol()
        InsertText("1", _INSERT_)

        kk = 1
        While kk <= nn
            // C[nn][kk] = C[nn-1][kk-1] + C[nn-1][kk]
            GotoLine((nn - 1) * 21 + (kk - 1) + 1)
            BegLine()
            ls = GetText(1, CurrLineLen())
            prev1 = Val(ls)

            GotoLine((nn - 1) * 21 + kk + 1)
            BegLine()
            ls = GetText(1, CurrLineLen())
            prev2 = Val(ls)

            cval = prev1 + prev2

            GotoLine(nn * 21 + kk + 1)
            BegLine()
            KillToEol()
            InsertText(Str(cval), _INSERT_)

            kk = kk + 1
        EndWhile

        nn = nn + 1
    EndWhile
End

// ---------------------------------------------------------------------------
// Proc: GetC(nn, kk)
// Reads C(nn,kk) from gCBuf into gCResult
// ---------------------------------------------------------------------------
Proc GetC(Integer nn, Integer kk)
    Integer prevBuf
    String  ls[32]

    prevBuf = GetBufferId()
    GotoBufferId(gCBuf)
    GotoLine(nn * 21 + kk + 1)
    BegLine()
    ls = GetText(1, CurrLineLen())
    gCResult = Val(ls)
    GotoBufferId(prevBuf)
End

// ---------------------------------------------------------------------------
// Proc: InitSquareTable
// Build gSqBuf: line (sq+1) = "1" if sq is a perfect square, else "0".
// Covers sq in 0..1620  (max f(n) = 20 * 9^2 = 1620).
// ---------------------------------------------------------------------------
Proc InitSquareTable()
    Integer ii
    Integer sq

    gSqBuf = CreateTempBuffer()
    GotoBufferId(gSqBuf)

    // Pre-fill 1621 lines with "0"
    ii = 0
    While ii <= 1620
        AddLine("0")
        ii = ii + 1
    EndWhile

    // i^2 for i=1..40  (40^2=1600 <= 1620, 41^2=1681 > 1620)
    ii = 1
    While ii <= 40
        sq = ii * ii
        GotoLine(sq + 1)
        BegLine()
        KillToEol()
        InsertText("1", _INSERT_)
        ii = ii + 1
    EndWhile
End

// ---------------------------------------------------------------------------
// Proc: IsSqIndex(sq)
// Result in gIsSqResult: 1 if sq is a perfect square, else 0
// ---------------------------------------------------------------------------
Proc IsSqIndex(Integer sq)
    Integer prevBuf
    String  ls[4]

    prevBuf = GetBufferId()
    GotoBufferId(gSqBuf)
    GotoLine(sq + 1)
    BegLine()
    ls = GetText(1, CurrLineLen())
    gIsSqResult = Val(ls)
    GotoBufferId(prevBuf)
End

// ---------------------------------------------------------------------------
// Proc: MulMod(aa, bb)
// Computes (aa * bb) mod gMODULO via Russian peasant multiplication.
// Result in gMulModResult.
// 32-bit safe: aa,bb < MODULO < 2^30 => a+a < 2*MODULO < 2^31-1.
// ---------------------------------------------------------------------------
Proc MulMod(Integer aa, Integer bb)
    Integer res
    Integer aVal
    Integer bVal

    res  = 0
    aVal = aa
    bVal = bb

    While bVal > 0
        If (bVal mod 2) == 1
            res = res + aVal
            If res >= gMODULO
                res = res - gMODULO
            EndIf
        EndIf
        aVal = aVal + aVal
        If aVal >= gMODULO
            aVal = aVal - gMODULO
        EndIf
        bVal = bVal / 2
    EndWhile

    gMulModResult = res
End

// ---------------------------------------------------------------------------
// Proc: GetCntD(dg)
// Returns count of digit dg in gGetCntResult
// ---------------------------------------------------------------------------
Proc GetCntD(Integer dg)
    gGetCntResult = 0
    If dg == 0
        gGetCntResult = gCnt0
    EndIf
    If dg == 1
        gGetCntResult = gCnt1
    EndIf
    If dg == 2
        gGetCntResult = gCnt2
    EndIf
    If dg == 3
        gGetCntResult = gCnt3
    EndIf
    If dg == 4
        gGetCntResult = gCnt4
    EndIf
    If dg == 5
        gGetCntResult = gCnt5
    EndIf
    If dg == 6
        gGetCntResult = gCnt6
    EndIf
    If dg == 7
        gGetCntResult = gCnt7
    EndIf
    If dg == 8
        gGetCntResult = gCnt8
    EndIf
    If dg == 9
        gGetCntResult = gCnt9
    EndIf
End

// ---------------------------------------------------------------------------
// Proc: IncrementCnt(dg)
// ---------------------------------------------------------------------------
Proc IncrementCnt(Integer dg)
    If dg == 0
        gCnt0 = gCnt0 + 1
    EndIf
    If dg == 1
        gCnt1 = gCnt1 + 1
    EndIf
    If dg == 2
        gCnt2 = gCnt2 + 1
    EndIf
    If dg == 3
        gCnt3 = gCnt3 + 1
    EndIf
    If dg == 4
        gCnt4 = gCnt4 + 1
    EndIf
    If dg == 5
        gCnt5 = gCnt5 + 1
    EndIf
    If dg == 6
        gCnt6 = gCnt6 + 1
    EndIf
    If dg == 7
        gCnt7 = gCnt7 + 1
    EndIf
    If dg == 8
        gCnt8 = gCnt8 + 1
    EndIf
    If dg == 9
        gCnt9 = gCnt9 + 1
    EndIf
End

// ---------------------------------------------------------------------------
// Proc: DecrementCnt(dg)
// ---------------------------------------------------------------------------
Proc DecrementCnt(Integer dg)
    If dg == 0
        gCnt0 = gCnt0 - 1
    EndIf
    If dg == 1
        gCnt1 = gCnt1 - 1
    EndIf
    If dg == 2
        gCnt2 = gCnt2 - 1
    EndIf
    If dg == 3
        gCnt3 = gCnt3 - 1
    EndIf
    If dg == 4
        gCnt4 = gCnt4 - 1
    EndIf
    If dg == 5
        gCnt5 = gCnt5 - 1
    EndIf
    If dg == 6
        gCnt6 = gCnt6 - 1
    EndIf
    If dg == 7
        gCnt7 = gCnt7 - 1
    EndIf
    If dg == 8
        gCnt8 = gCnt8 - 1
    EndIf
    If dg == 9
        gCnt9 = gCnt9 - 1
    EndIf
End

// ---------------------------------------------------------------------------
// Proc: CountLeaf
// Called when gCnt0..gCnt9 hold a complete 20-digit multiset.
// For each digit d with cnt[d] > 0, computes:
//   contribution = d * multinomial(19; cnt[0]..cnt[d]-1..cnt[9]) * 111111111
// and accumulates into gAnswer (mod MODULO).
// ---------------------------------------------------------------------------
Proc CountLeaf()
    Integer sqSum
    Integer dd
    Integer cntD
    Integer remaining
    Integer inner
    Integer contrib
    Integer ones9

    // Compute sum of squared digits (digit 0 contributes 0)
    sqSum = gCnt1 * 1
          + gCnt2 * 4
          + gCnt3 * 9
          + gCnt4 * 16
          + gCnt5 * 25
          + gCnt6 * 36
          + gCnt7 * 49
          + gCnt8 * 64
          + gCnt9 * 81

    // Skip if f(n) is not a perfect square
    IsSqIndex(sqSum)
    If not (gIsSqResult == 1)
        Return()
    EndIf

    // ones9 = 111,111,111  (repunit of 9 ones; total = 20 >= 9 always)
    ones9 = 111111111

    // For each digit dd = 0..9 where cnt[dd] > 0
    dd = 0
    While dd <= 9

        GetCntD(dd)
        cntD = gGetCntResult

        If cntD > 0
            // Temporarily decrement cnt[dd]
            DecrementCnt(dd)

            // Compute inner_mn19 = product of C[remaining][cnt[k]] for k=0..9
            inner     = 1
            remaining = 19

            GetC(remaining, gCnt0)
            MulMod(inner, gCResult)
            inner     = gMulModResult
            remaining = remaining - gCnt0

            GetC(remaining, gCnt1)
            MulMod(inner, gCResult)
            inner     = gMulModResult
            remaining = remaining - gCnt1

            GetC(remaining, gCnt2)
            MulMod(inner, gCResult)
            inner     = gMulModResult
            remaining = remaining - gCnt2

            GetC(remaining, gCnt3)
            MulMod(inner, gCResult)
            inner     = gMulModResult
            remaining = remaining - gCnt3

            GetC(remaining, gCnt4)
            MulMod(inner, gCResult)
            inner     = gMulModResult
            remaining = remaining - gCnt4

            GetC(remaining, gCnt5)
            MulMod(inner, gCResult)
            inner     = gMulModResult
            remaining = remaining - gCnt5

            GetC(remaining, gCnt6)
            MulMod(inner, gCResult)
            inner     = gMulModResult
            remaining = remaining - gCnt6

            GetC(remaining, gCnt7)
            MulMod(inner, gCResult)
            inner     = gMulModResult
            remaining = remaining - gCnt7

            GetC(remaining, gCnt8)
            MulMod(inner, gCResult)
            inner     = gMulModResult
            remaining = remaining - gCnt8

            GetC(remaining, gCnt9)
            MulMod(inner, gCResult)
            inner     = gMulModResult

            // Restore cnt[dd]
            IncrementCnt(dd)

            // contribution = dd * inner * ones9  (mod MODULO)
            MulMod(inner, ones9)
            contrib = gMulModResult
            MulMod(dd, contrib)
            contrib = gMulModResult

            // Accumulate into gAnswer
            // (contrib < MODULO, gAnswer < MODULO => sum < 2*MODULO < 2^31-1)
            gAnswer = gAnswer + contrib
            If gAnswer >= gMODULO
                gAnswer = gAnswer - gMODULO
            EndIf

        EndIf   // cntD > 0

        dd = dd + 1
    EndWhile
End

// ---------------------------------------------------------------------------
// Proc: DoSearch
// Iterative depth-first backtracking over all 20-digit multisets
// in non-decreasing order.  Uses two temp buffers as a 20-deep stack.
// Calls CountLeaf() each time all 20 digits have been placed.
//
// Per level L (1..20):
//   gLvlDBuf line L = digit currently being tried at level L
//   gLvlMBuf line L = minimum digit allowed at level L
// ---------------------------------------------------------------------------
Proc DoSearch()
    Integer curLevel
    Integer curD
    Integer fillIdx

    // Allocate DFS stack buffers (21 lines each; lines 1..20 are used)
    gLvlDBuf = CreateTempBuffer()
    GotoBufferId(gLvlDBuf)
    fillIdx = 0
    While fillIdx < 21
        AddLine("0")
        fillIdx = fillIdx + 1
    EndWhile

    gLvlMBuf = CreateTempBuffer()
    GotoBufferId(gLvlMBuf)
    fillIdx = 0
    While fillIdx < 21
        AddLine("0")
        fillIdx = fillIdx + 1
    EndWhile

    // Initialise digit counts to zero
    gCnt0 = 0
    gCnt1 = 0
    gCnt2 = 0
    gCnt3 = 0
    gCnt4 = 0
    gCnt5 = 0
    gCnt6 = 0
    gCnt7 = 0
    gCnt8 = 0
    gCnt9 = 0

    // Start DFS at level 1, minimum digit = 0
    curLevel = 1
    SetBufInt(gLvlMBuf, 1, 0)
    SetBufInt(gLvlDBuf, 1, 0)

    // Main iterative DFS loop
    While curLevel >= 1

        GetBufInt(gLvlDBuf, curLevel)
        curD = gBufIntResult

        If curD > 9
            // All digits exhausted at this level: backtrack
            curLevel = curLevel - 1
            If curLevel >= 1
                // Undo the digit last pushed at curLevel and advance
                GetBufInt(gLvlDBuf, curLevel)
                curD = gBufIntResult
                DecrementCnt(curD)
                SetBufInt(gLvlDBuf, curLevel, curD + 1)
            EndIf
        Else
            // Push digit curD onto the multiset
            IncrementCnt(curD)

            If curLevel == 20
                // All 20 digits placed: process the leaf
                CountLeaf()
                // Undo and advance to next digit (stay at level 20)
                DecrementCnt(curD)
                SetBufInt(gLvlDBuf, curLevel, curD + 1)
            Else
                // Descend: next level starts from the same digit (non-decreasing)
                curLevel = curLevel + 1
                SetBufInt(gLvlMBuf, curLevel, curD)
                SetBufInt(gLvlDBuf, curLevel, curD)
            EndIf

        EndIf

    EndWhile

    // Release stack buffers
    AbandonFile(gLvlDBuf)
    AbandonFile(gLvlMBuf)
End

// ---------------------------------------------------------------------------
// Proc Main  -- entry point
// ---------------------------------------------------------------------------
Proc Main()
    Integer prevBuf
    String  answerStr[64]

    // Save caller's buffer
    prevBuf = GetBufferId()

    // Initialise globals
    gMODULO = 1000000000
    gAnswer  = 0
    gCnt0    = 0
    gCnt1    = 0
    gCnt2    = 0
    gCnt3    = 0
    gCnt4    = 0
    gCnt5    = 0
    gCnt6    = 0
    gCnt7    = 0
    gCnt8    = 0
    gCnt9    = 0

    // Build lookup tables
    InitCombTable()
    InitSquareTable()

    // Run the exhaustive search
    DoSearch()

    // Clean up lookup-table buffers
    AbandonFile(gCBuf)
    AbandonFile(gSqBuf)

    // Restore original buffer
    GotoBufferId(prevBuf)

    // Format answer: zero-pad to 9 digits
    answerStr = Str(gAnswer)
    While Length(answerStr) < 9
        answerStr = "0" + answerStr
    EndWhile

    // First CopyToWinClip (before Warn): take screenshot, then press OK
    CopyToWinClip(answerStr)

    // Show the final answer
    Warn("Project Euler 171 - Last nine digits of sum where f(n) is a perfect square:",
         Chr(10), "Answer = ", answerStr)

    // Second CopyToWinClip (after Warn): answer ready on clipboard
    CopyToWinClip(answerStr)

    // Paste the answer into the editor
    GotoBufferId(prevBuf)
    InsertText(answerStr, _INSERT_)
End

