// Project Euler - Problem 115: Counting Block Combinations II
//
// A row of n units has red blocks of minimum length m placed on it,
// separated by at least one black square. F(m,n) counts the ways.
//
// Recurrence (standard):
//   F(m, n) = 1                           for n < m  (all-black only)
//   F(m, n) = F(m, n-1)                   [leading black square]
//           + Sum_{k=m}^{n} F(m, n-k-1)  [red block of length k at right end,
//                                          with a mandatory gap before it]
// where F(m, j) = 1 for j < 0 (empty row = 1 way).
//
// For m = 50, find the least n with F(50, n) > 1,000,000.
//
// Values remain well within 32-bit integers at the answer (~168),
// so no big-integer arithmetic is needed.
//
// Buffer layout: line (j+2) stores F(m, j).
//   j = -1  ->  line 1  (= 1, base case)
//   j =  0  ->  line 2  (= 1, empty row)
//   j =  1  ->  line 3
//   ...
//
// <version>1.0.0.0.1</version>

integer gAnswerN
integer gAnswerF

// -------------------------------------------------------------------
// getF(buf, j): return F(m, j) from buffer buf.
//   For j < -1, return 1 (base case).
//   Line index = j + 2.
// -------------------------------------------------------------------
integer proc getF(integer buf, integer j)
    integer nLine
    integer nRet
    if j < -1
        return( 1 )
    endif
    nLine = j + 2
    GotoBufferId(buf)
    if nLine > NumLines()
        return( 1 )   // safety: treat out-of-range as base case
    endif
    GotoLine(nLine)
    nRet = Val(GetText(1, CurrLineLen()))
    return( nRet )
end

// -------------------------------------------------------------------
// setF(buf, j, nNewVal): store nNewVal as F(m, j) in buffer buf.
// -------------------------------------------------------------------
proc setF(integer buf, integer j, integer nNewVal)
    integer nLine
    nLine = j + 2
    GotoBufferId(buf)
    GotoLine(nLine)
    BegLine()
    KillToEol()
    InsertText(Str(nNewVal))
end

// -------------------------------------------------------------------
// Main
// -------------------------------------------------------------------
proc Main()
    integer dpBuf       // DP value buffer
    integer clipBuf     // temp buffer for clipboard copy
    integer m           // minimum red block length (= 50)
    integer n           // current row length
    integer fVal        // F(m, n) for current n
    integer nSum        // sum over red-block placements
    integer k           // red block length (m..n)
    integer nDone       // loop exit flag
    string  sAns[20]    // answer as string

    m     = 50
    nDone = 0

    // Initialise DP buffer.
    // Pre-populate lines 1 and 2: F(m,-1)=1 and F(m,0)=1.
    dpBuf = CreateTempBuffer()
    GotoBufferId(dpBuf)
    EmptyBuffer()
    InsertText("1")   // line 1: F(m, -1) = 1
    AddLine("1")      // line 2: F(m,  0) = 1

    n = 1
    while not nDone

        // Append a placeholder line for F(m, n)
        GotoBufferId(dpBuf)
        EndFile()
        AddLine("0")

        // F(m, n) starts with F(m, n-1) [put black at rightmost cell]
        fVal = getF(dpBuf, n - 1)

        // Add Sum_{k=m}^{n} F(m, n-k-1)
        // When k=n: F(m, -1) = 1  (red block fills entire row)
        // n-k-1 ranges from n-m-1 down to -1 as k goes m..n
        nSum = 0
        k = m
        while k <= n
            nSum = nSum + getF(dpBuf, n - k - 1)
            k = k + 1
        endwhile

        fVal = fVal + nSum
        setF(dpBuf, n, fVal)

        if fVal > 1000000
            nDone    = 1
            gAnswerN = n
            gAnswerF = fVal
        endif

        n = n + 1
    endwhile

    AbandonFile(dpBuf)

    // Display result
    sAns = Str(gAnswerN)
    Warn("Project Euler #115 - Counting Block Combinations II" + Chr(13) +
         "m = 50: least n with F(50,n) > 1,000,000" + Chr(13) +
         Chr(13) +
         "Answer: n = " + sAns + Chr(13) +
         "F(50, " + sAns + ") = " + Str(gAnswerF))

    // Copy only the numeric answer to clipboard
    clipBuf = CreateTempBuffer()
    GotoBufferId(clipBuf)
    InsertText(sAns)
    BegLine()
    MarkLine()
    CopyToWinClip()
    AbandonFile(clipBuf)
end
