// p026.s
//
// Project Euler - Problem 26: Reciprocal Cycles
//
// A unit fraction contains 1 in the numerator.
// The decimal representations of 1/d for d = 2 to 10 are given,
// where some have recurring cycles, e.g. 1/7 = 0.(142857) with cycle 6.
//
// Find the value of d < 1000 for which 1/d contains the longest
// recurring cycle in its decimal fraction part.
//
// Algorithm: long division remainder tracking.
// For 1/d, simulate long division by tracking remainders.
// Store remainder -> position in a buffer used as a lookup table.
// When a remainder repeats, the cycle length = current_pos - stored_pos.
// If remainder becomes 0, there is no recurring cycle (terminates).
//
// Answer: 983
//
// Version: 1.0

// ---------------------------------------------------------------------------
// cycleLen(d)
//   Returns the length of the recurring cycle of 1/d,
//   or 0 if 1/d has a terminating decimal expansion.
// ---------------------------------------------------------------------------
integer proc cycleLen(integer d)
    integer remainder
    integer curPos
    integer seen
    integer remainderBuf
    integer i

    // Use a temp buffer as a remainder -> position lookup table.
    // We store position+1 at index=remainder (0 means "not seen").
    remainderBuf = CreateTempBuffer()

    // Pre-fill buffer with d+1 lines of "0"
    BegFile()
    i = 0
    while i <= d
        AddLine("0")
        i = i + 1
    endwhile

    remainder = 1
    curPos = 0

    while remainder <> 0
        // Look up whether this remainder was seen before
        GotoLine(remainder + 1)
        seen = Val(GetText(1, CurrLineLen()))
        if seen > 0
            // Cycle detected: length = curPos - (seen - 1)
            AbandonFile(remainderBuf)
            return(curPos - (seen - 1))
        endif

        // Mark remainder as seen at curPos (store curPos+1 so 0 = unseen)
        BegLine()
        InsertText(Str(curPos + 1), _OVERWRITE_)

        remainder = (remainder * 10) mod d
        curPos = curPos + 1
    endwhile

    AbandonFile(remainderBuf)
    return(0)
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer d
    integer bestD
    integer bestLen
    integer curLen
    string  resultStr[80]

    bestD   = 0
    bestLen = 0

    d = 1
    while d < 1000
        curLen = cycleLen(d)
        if curLen > bestLen
            bestLen = curLen
            bestD   = d
        endif
        d = d + 1
    endwhile

    resultStr = "P026: d=" + Str(bestD) + "  cycle length=" + Str(bestLen)
    Warn(resultStr)
    CopyToWinClip(resultStr)
end
