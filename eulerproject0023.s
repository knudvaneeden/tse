// =============================================================================
// Project Euler - Problem 23: Non-Abundant Sums
// =============================================================================
// A perfect number n has sum of proper divisors == n.
// A number is abundant if the sum of its proper divisors exceeds n.
// It can be shown all integers > 28123 are the sum of two abundant numbers.
// Find the sum of all positive integers that CANNOT be written as the sum
// of two abundant numbers.
//
// Answer: 4179871
//
// Strategy (no SAL arrays available):
//   Buffer 1 (gAbundantBufId): one line per abundant number (text "12", "18", ...)
//   Buffer 2 (gMarkBufId)    : 28124 lines, each "0" or "1"
//     line n = "1" means n can be expressed as sum of two abundant numbers
//   We iterate all pairs of abundant numbers, mark their sums, then sum all
//   unmarked lines 1..28123.
// =============================================================================

// Version: 1.0.0.0.1

constant UPPER_LIMIT = 28123

integer gAbundantBufId  // buffer holding abundant numbers, one per line
integer gMarkBufId      // buffer with 28124 lines: "0" or "1"
integer gAbundantCount

// ---------------------------------------------------------------------------
// sumProperDivisors(n) - returns sum of proper divisors of n
// ---------------------------------------------------------------------------
integer proc sumProperDivisors(integer n)
    integer s
    integer i
    integer q
    s = 1       // 1 is always a proper divisor for n > 1
    if n <= 1
        return(0)
    endif
    i = 2
    while i * i <= n
        q = n / i
        if q * i == n
            s = s + i
            if i <> q
                s = s + q
            endif
        endif
        i = i + 1
    endwhile
    return(s)
end

// ---------------------------------------------------------------------------
// buildAbundantList - fills gAbundantBufId with abundant numbers 1..UPPER_LIMIT
// ---------------------------------------------------------------------------
proc buildAbundantList()
    integer n
    integer saved

    saved = GetBufferId()
    GotoBufferId(gAbundantBufId)
    EmptyBuffer()

    n = 1
    while n <= UPPER_LIMIT
        if sumProperDivisors(n) > n
            AddLine(Str(n))
            gAbundantCount = gAbundantCount + 1
        endif
        n = n + 1
    endwhile

    GotoBufferId(saved)
end

// ---------------------------------------------------------------------------
// buildMarkBuffer - pre-fill gMarkBufId with (UPPER_LIMIT+1) lines of "0"
// ---------------------------------------------------------------------------
proc buildMarkBuffer()
    integer i
    integer saved

    saved = GetBufferId()
    GotoBufferId(gMarkBufId)
    EmptyBuffer()

    // line 0 placeholder so line index == number
    AddLine("0")   // line 1 = number 0 (unused)
    i = 1
    while i <= UPPER_LIMIT
        AddLine("0")
        i = i + 1
    endwhile

    GotoBufferId(saved)
end

// ---------------------------------------------------------------------------
// markSums - for every pair (ai, aj) of abundant numbers, mark ai+aj
// ---------------------------------------------------------------------------
proc markSums()
    integer i
    integer j
    integer ai
    integer aj
    integer s
    integer saved

    saved = GetBufferId()

    i = 1
    while i <= gAbundantCount
        GotoBufferId(gAbundantBufId)
        GotoLine(i)
        ai = Val(GetText(1, CurrLineLen()))

        j = i   // pairs (i,j) with j >= i  (both orders covered since sum is same)
        while j <= gAbundantCount
            GotoBufferId(gAbundantBufId)
            GotoLine(j)
            aj = Val(GetText(1, CurrLineLen()))

            s = ai + aj
            if s > UPPER_LIMIT
                j = gAbundantCount + 1  // break inner loop
            else
                // mark line s+1 in mark buffer (line 1 = number 0, line 2 = number 1, ...)
                GotoBufferId(gMarkBufId)
                GotoLine(s + 1)
                BegLine()
                // replace the "0" with "1" if not already marked
                if GetText(1, 1) == "0"
                    InsertText("1", _OVERWRITE_)
                endif
                j = j + 1
            endif
        endwhile

        i = i + 1
    endwhile

    GotoBufferId(saved)
end

// ---------------------------------------------------------------------------
// computeAnswer - sum all n in 1..UPPER_LIMIT where mark[n] == "0"
// ---------------------------------------------------------------------------
integer proc computeAnswer()
    integer n
    integer total
    integer saved
    string  markVal[2]

    saved = GetBufferId()
    total = 0
    n = 1
    while n <= UPPER_LIMIT
        GotoBufferId(gMarkBufId)
        GotoLine(n + 1)
        markVal = GetText(1, 1)
        if markVal == "0"
            total = total + n
        endif
        n = n + 1
    endwhile

    GotoBufferId(saved)
    return(total)
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer answer
    string  resultStr[30]

    // Create working buffers
    gAbundantBufId = CreateTempBuffer()
    gMarkBufId     = CreateTempBuffer()
    gAbundantCount = 0

    Message("P023: Building mark buffer (28123 lines)...")
    buildMarkBuffer()

    Message("P023: Finding abundant numbers up to 28123...")
    buildAbundantList()

    Message("P023: Marking sums of abundant pairs (this may take a minute)...")
    markSums()

    Message("P023: Summing non-abundant numbers...")
    answer = computeAnswer()

    // Clean up temp buffers
    AbandonFile(gAbundantBufId)
    AbandonFile(gMarkBufId)

    resultStr = Str(answer)
    CopyToWinClip(resultStr)
    Warn("Project Euler #23 answer: ", resultStr, "  (copied to clipboard)")
end
