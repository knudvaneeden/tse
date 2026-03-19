// euler119.s
// Project Euler - Problem 119: Digit Power Sum
//
// Find a_30: the 30th number (>= 10) equal to (digit_sum)^k for integer k >= 2.
//
// Algorithm:
//   For base b = 2..MAX_BASE, compute b^k for k = 2..MAX_EXP (big-integer strings).
//   If digit_sum(b^k) == b AND b^k >= 10, record b^k as a candidate.
//   After collecting, sort candidates numerically (pad to equal width, sort, strip).
//   Return the 30th distinct value.
//
// Big-integer arithmetic: stored as decimal strings (max 255 chars, enough here).
// Candidates stored in a TSE temp buffer, one per line.
//
// Created by: Claude (Anthropic)
// <version>1.0.0.0.1</version>
//
// History:
//   1.0.0.0.1  Initial version. Created by Claude (claude.ai, Anthropic).

constant MAX_BASE    = 150
constant MAX_EXP     = 50
constant TARGET_TERM = 30
constant PAD_WIDTH   = 120  // digit padding width for sort (max ~109 digits seen)

// ---------------------------------------------------------------------------
// BigMul: multiply big-integer string s by integer n, return result string
// ---------------------------------------------------------------------------
string proc BigMul(string s, integer n)
    string  result[255]
    integer carry
    integer digit
    integer prod
    integer i
    integer sLen

    result = ""
    carry  = 0
    sLen   = Length(s)

    // Multiply from least significant digit (right) to most significant
    i = sLen
    while i >= 1
        digit  = Asc(s[i]) - Asc("0")
        prod   = digit * n + carry
        carry  = prod / 10
        result = Chr((prod mod 10) + Asc("0")) + result
        i = i - 1
    endwhile

    // Propagate remaining carry
    while carry > 0
        result = Chr((carry mod 10) + Asc("0")) + result
        carry  = carry / 10
    endwhile

    if Length(result) == 0
        result = "0"
    endif

    return(result)
end

// ---------------------------------------------------------------------------
// DigitSum: compute sum of decimal digits of big-integer string s
// ---------------------------------------------------------------------------
integer proc DigitSum(string s)
    integer total
    integer i
    integer sLen

    total = 0
    sLen  = Length(s)
    i     = 1
    while i <= sLen
        total = total + Asc(s[i]) - Asc("0")
        i = i + 1
    endwhile
    return(total)
end

// ---------------------------------------------------------------------------
// PadLeft: left-pad string s with '0' to width w (for numeric sort)
// ---------------------------------------------------------------------------
string proc PadLeft(string s, integer w)
    string padded[255]
    padded = s
    while Length(padded) < w
        padded = "0" + padded
    endwhile
    return(padded)
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer candidateBufId
    integer sortBufId
    integer resultBufId
    integer b
    integer k
    integer dSum
    integer nLines
    integer i
    integer lineLen
    string  power[255]
    string  bStr[20]
    string  answer[255]
    string  padded[255]
    string  raw[255]

    // Create buffer to collect candidate numbers (as decimal strings)
    candidateBufId = CreateTempBuffer()
    if candidateBufId == 0
        Warn("ERROR: Could not create candidate buffer.")
        return()
    endif

    // -------------------------------------------------------------------
    // Search: for each base b, compute b^k and check digit sum
    // -------------------------------------------------------------------
    b = 2
    while b <= MAX_BASE
        // Compute b^2, b^3, ... up to MAX_EXP
        // Start with power = b^1, then multiply repeatedly
        bStr  = Str(b)
        power = bStr   // b^1

        k = 2
        while k <= MAX_EXP
            power = BigMul(power, b)   // now power = b^k

            // Candidate only if number has at least 2 digits
            if Length(power) >= 2
                dSum = DigitSum(power)
                if dSum == b
                    // Valid candidate: add to buffer
                    GotoBufferId(candidateBufId)
                    EndFile()
                    AddLine(power)
                endif
            endif

            // Early exit: if power already > 255 chars we can stop
            // (string limit reached; in practice MAX_EXP keeps us safe)
            if Length(power) >= 250
                k = MAX_EXP + 1   // break
            else
                k = k + 1
            endif
        endwhile

        b = b + 1
    endwhile

    // -------------------------------------------------------------------
    // Remove duplicates and sort numerically
    // Pad each line to PAD_WIDTH digits, sort lexicographically, strip pad
    // -------------------------------------------------------------------

    // Build a sort buffer with zero-padded lines
    sortBufId = CreateTempBuffer()
    if sortBufId == 0
        Warn("ERROR: Could not create sort buffer.")
        return()
    endif

    GotoBufferId(candidateBufId)
    nLines = NumLines()

    i = 1
    while i <= nLines
        GotoBufferId(candidateBufId)
        GotoLine(i)
        BegLine()
        raw     = GetText(1, CurrLineLen())
        padded  = PadLeft(raw, PAD_WIDTH)
        GotoBufferId(sortBufId)
        EndFile()
        AddLine(padded)
        i = i + 1
    endwhile

    // Sort lexicographically (= numeric order after zero-padding)
    GotoBufferId(sortBufId)
    if NumLines() > 1
        BegFile()
        MarkLine()
        EndFile()
        Sort(_IGNORE_CASE_)
        UnMarkBlock()
    endif

    // Remove duplicate lines from sortBufId
    // Strategy: walk lines, keep track of previous line
    resultBufId = CreateTempBuffer()
    if resultBufId == 0
        Warn("ERROR: Could not create result buffer.")
        return()
    endif

    GotoBufferId(sortBufId)
    nLines = NumLines()
    answer = ""   // reuse as "previous line" tracker

    i = 1
    while i <= nLines
        GotoBufferId(sortBufId)
        GotoLine(i)
        BegLine()
        padded = GetText(1, CurrLineLen())
        if padded <> answer
            answer = padded
            // Strip leading zeros to recover raw number
            raw = padded
            while (Length(raw) > 1) and (raw[1] == "0")
                raw = SubStr(raw, 2, Length(raw) - 1)
            endwhile
            GotoBufferId(resultBufId)
            EndFile()
            AddLine(raw)
        endif
        i = i + 1
    endwhile

    // -------------------------------------------------------------------
    // Read the 30th term
    // -------------------------------------------------------------------
    GotoBufferId(resultBufId)
    nLines = NumLines()

    if nLines < TARGET_TERM
        Warn("Only found " + Str(nLines) + " terms (need 30). Increase MAX_BASE/MAX_EXP.")
        AbandonFile(candidateBufId)
        AbandonFile(sortBufId)
        AbandonFile(resultBufId)
        return()
    endif

    GotoLine(TARGET_TERM)
    BegLine()
    lineLen = CurrLineLen()
    answer  = GetText(1, lineLen)

    // Clean up temp buffers
    AbandonFile(candidateBufId)
    AbandonFile(sortBufId)
    AbandonFile(resultBufId)

    // -------------------------------------------------------------------
    // Output
    // -------------------------------------------------------------------
    CopyToWinClip(answer)
    Warn("Project Euler #119 - Digit Power Sum" + Chr(13) +
         "a_30 = " + answer + Chr(13) +
         Chr(13) +
         "Result copied to clipboard.")
end
