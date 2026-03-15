// Project Euler - Problem 25
// 1000-digit Fibonacci Number
//
// The Fibonacci sequence is defined by the recurrence relation:
//   F(n) = F(n-1) + F(n-2), where F(1) = 1 and F(2) = 1.
// The 12th term, F(12) = 144, is the first term to contain 3 digits.
// What is the index of the first term in the Fibonacci sequence
// to contain 1000 digits?
//
// Strategy: implement big-integer addition using string buffers.
//   Digits are stored as one character per line, least-significant first.
//   We keep three TSE buffers: prev, curr, and temp for the swap.
//
// Version: 1.0.0.0

// ---------------------------------------------------------------------------
// BigInt helper: add two big integers stored in temp buffers.
// Each buffer holds one decimal digit per line, least-significant digit first.
// Result is placed in the 'result' buffer (which may be the same as a or b).
// ---------------------------------------------------------------------------
proc BigAdd(integer idA, integer idB, integer idResult)
    integer lenA, lenB, lenMax
    integer carry, digitA, digitB, digitSum
    integer i
    integer idTemp

    // Work out lengths
    GotoBufferId(idA)
    lenA = NumLines()
    GotoBufferId(idB)
    lenB = NumLines()

    if lenA > lenB
        lenMax = lenA
    else
        lenMax = lenB
    endif

    // Build result in a fresh temp buffer, then copy to idResult
    idTemp = CreateTempBuffer()

    carry = 0
    i = 1
    while i <= lenMax or carry
        digitA = 0
        digitB = 0

        if i <= lenA
            GotoBufferId(idA)
            GotoLine(i)
            digitA = Val(GetText(1, CurrLineLen()))
        endif

        if i <= lenB
            GotoBufferId(idB)
            GotoLine(i)
            digitB = Val(GetText(1, CurrLineLen()))
        endif

        digitSum = digitA + digitB + carry
        carry    = digitSum / 10
        digitSum = digitSum mod 10

        GotoBufferId(idTemp)
        EndFile()
        AddLine(Str(digitSum))

        i = i + 1
    endwhile

    // Copy temp -> idResult
    GotoBufferId(idResult)
    EmptyBuffer()
    GotoBufferId(idTemp)
    BegFile()
    MarkLine()
    EndFile()
    MarkLine()
    GotoBufferId(idResult)
    BegFile()
    CopyBlock()

    AbandonFile(idTemp)
end

// ---------------------------------------------------------------------------
// Return the number of digits stored in a big-int buffer
// ---------------------------------------------------------------------------
integer proc BigLen(integer idBuf)
    GotoBufferId(idBuf)
    return( NumLines() )
end

// ---------------------------------------------------------------------------
// Put a small integer value into a big-int buffer (single digit assumed here,
// but works for any non-negative integer).
// ---------------------------------------------------------------------------
proc BigSet(integer idBuf, integer value)
    integer v, digit
    GotoBufferId(idBuf)
    EmptyBuffer()
    if value == 0
        AddLine("0")
        return()
    endif
    v = value
    while v > 0
        digit = v mod 10
        v     = v / 10
        EndFile()
        AddLine(Str(digit))
    endwhile
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer idPrev, idCurr, idNext, idSwap
    integer index
    string  resultStr[255]

    // Create three big-int buffers: F(n-1)=1, F(n)=1
    idPrev = CreateTempBuffer()
    idCurr = CreateTempBuffer()
    idNext = CreateTempBuffer()

    BigSet(idPrev, 1)   // F(1) = 1
    BigSet(idCurr, 1)   // F(2) = 1

    index = 2

    // Iterate until F(index) has >= 1000 digits
    while BigLen(idCurr) < 1000
        // F(next) = F(curr) + F(prev)
        BigAdd(idCurr, idPrev, idNext)

        // Rotate: prev <- curr, curr <- next
        // Swap idPrev and idCurr pointers, then put idNext into idCurr
        idSwap = idPrev
        idPrev = idCurr
        idCurr = idNext
        idNext = idSwap   // reuse the old prev buffer as scratch

        index = index + 1
    endwhile

    resultStr = "Project Euler #25: First Fibonacci index with 1000 digits = " + Str(index)

    AbandonFile(idPrev)
    AbandonFile(idCurr)
    AbandonFile(idNext)

    Warn(resultStr)
    CopyToWinClip(Str(index))
end
