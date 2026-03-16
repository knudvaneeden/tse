// p057.s  Project Euler Problem 57 - Square Root Convergents
//
// sqrt(2) = 1 + 1/(2 + 1/(2 + 1/(2 + ...)))
// Recurrence for convergent n/d:
//   n_new = 2*d + n
//   d_new = d + n
// Starting values: n=3, d=2  (first expansion 3/2)
//
// Numbers grow to ~300 digits -- beyond SAL's 255-char string limit.
// Solution: store each big integer in a TSE buffer, one DECIMAL DIGIT per line,
// least-significant digit first (line 1 = units digit).
//
// After EmptyBuffer() a TSE buffer has exactly ONE blank line.
// We write the first digit onto that line with InsertText(),
// then use AddLine() for subsequent digits -- so no spurious blank line 1.
//
// Count expansions (out of first 1000) where len(numerator) > len(denominator).
// Output via Warn() and CopyToWinClip().

// ---------------------------------------------------------------------------
// BufSetSingleDigit: initialise a buffer to hold the single digit value n
// ---------------------------------------------------------------------------
proc BufSetSingleDigit(integer bufId, integer n)
    GotoBufferId(bufId)
    EmptyBuffer()
    BegFile()
    InsertText(Str(n), _INSERT_)
end

// ---------------------------------------------------------------------------
// BufAdd: add big integers in bufA and bufB, put result in bufDst.
// Each buffer holds one decimal digit per line, LSB first.
// bufDst is overwritten; bufA and bufB are read-only.
// ---------------------------------------------------------------------------
proc BufAdd(integer bufA, integer bufB, integer bufDst)
    integer carry, da, db, dsum, lenA, lenB, lenMax, idx
    integer firstLine
    carry = 0

    GotoBufferId(bufA)  lenA = NumLines()
    GotoBufferId(bufB)  lenB = NumLines()
    if lenA > lenB
        lenMax = lenA
    else
        lenMax = lenB
    endif

    // Clear destination -- leaves one blank line
    GotoBufferId(bufDst)
    EmptyBuffer()
    BegFile()
    firstLine = TRUE

    idx = 1
    while idx <= lenMax
        da = 0
        db = 0
        GotoBufferId(bufA)
        if idx <= lenA
            GotoLine(idx)
            da = Val(GetText(1, CurrLineLen()))
        endif
        GotoBufferId(bufB)
        if idx <= lenB
            GotoLine(idx)
            db = Val(GetText(1, CurrLineLen()))
        endif
        dsum  = da + db + carry
        carry = dsum / 10
        dsum  = dsum mod 10

        GotoBufferId(bufDst)
        if firstLine
            // Write onto the existing blank line
            InsertText(Str(dsum), _INSERT_)
            firstLine = FALSE
        else
            AddLine(Str(dsum))
        endif
        idx = idx + 1
    endwhile

    // Propagate remaining carry
    GotoBufferId(bufDst)
    while carry
        dsum  = carry mod 10
        carry = carry / 10
        if firstLine
            InsertText(Str(dsum), _INSERT_)
            firstLine = FALSE
        else
            AddLine(Str(dsum))
        endif
    endwhile
end

// ---------------------------------------------------------------------------
// BufCopy: copy contents of bufSrc into bufDst (overwrite)
// ---------------------------------------------------------------------------
proc BufCopy(integer bufSrc, integer bufDst)
    integer n, idx
    integer firstLine
    string  ch[4]
    GotoBufferId(bufSrc)  n = NumLines()
    GotoBufferId(bufDst)
    EmptyBuffer()
    BegFile()
    firstLine = TRUE
    idx = 1
    while idx <= n
        GotoBufferId(bufSrc)
        GotoLine(idx)
        ch = GetText(1, CurrLineLen())
        GotoBufferId(bufDst)
        if firstLine
            InsertText(ch, _INSERT_)
            firstLine = FALSE
        else
            AddLine(ch)
        endif
        idx = idx + 1
    endwhile
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer bufN, bufD, bufNewN, bufNewD, bufTmp
    integer cnt, step, lenN, lenD
    string answer[20]

    // Create working buffers
    bufN    = CreateTempBuffer()
    bufD    = CreateTempBuffer()
    bufNewN = CreateTempBuffer()
    bufNewD = CreateTempBuffer()
    bufTmp  = CreateTempBuffer()

    // Initialise: n=3, d=2  (LSB first, one digit per line)
    BufSetSingleDigit(bufN, 3)
    BufSetSingleDigit(bufD, 2)

    cnt = 0

    step = 1
    while step <= 1000
        // n_new = 2*d + n
        BufAdd(bufD, bufD, bufTmp)       // bufTmp  = 2*d
        BufAdd(bufTmp, bufN, bufNewN)    // bufNewN = 2*d + n

        // d_new = d + n
        BufAdd(bufD, bufN, bufNewD)      // bufNewD = d + n

        // Promote: n <- newN,  d <- newD
        BufCopy(bufNewN, bufN)
        BufCopy(bufNewD, bufD)

        // Compare digit counts (NumLines = number of digits, LSB-first)
        GotoBufferId(bufN)  lenN = NumLines()
        GotoBufferId(bufD)  lenD = NumLines()

        if lenN > lenD
            cnt = cnt + 1
        endif

        step = step + 1
    endwhile

    // Clean up temp buffers
    AbandonFile(bufN)
    AbandonFile(bufD)
    AbandonFile(bufNewN)
    AbandonFile(bufNewD)
    AbandonFile(bufTmp)

    answer = Str(cnt)
    CopyToWinClip(answer)
    Warn("Project Euler 57 - Square Root Convergents" + Chr(13) +
         "In the first 1000 expansions," + Chr(13) +
         "numerator has more digits than denominator in:" + Chr(13) +
         answer + " cases" + Chr(13) +
         "(Answer copied to clipboard)")
end
