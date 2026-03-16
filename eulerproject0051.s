// Project Euler - Problem 51: Prime Digit Replacements
//
// By replacing part of a number (not necessarily adjacent digits) with
// the same digit, find the smallest prime which is part of an
// eight prime value family.
//
// Answer: 121313
//
// Strategy:
//   1. Sieve of Eratosthenes up to 1,000,000 stored in a TSE buffer
//      (line N+1 holds '1' if N is prime, '0' otherwise).
//   2. For each 6-digit prime p, build its digit string.
//   3. For each digit value d (0..9) that appears in p, try every
//      non-empty subset of the positions where d occurs.
//   4. For each such (digit, subset) pair, replace those positions
//      with 0..9 in turn and count how many results are prime.
//   5. If the count reaches 8, record p as a candidate answer.
//   6. Report the smallest such prime found.

// ---------------------------------------------------------------------------
// Sieve buffer id (global)
// ---------------------------------------------------------------------------
integer g_sieve_buf = 0

// ---------------------------------------------------------------------------
// IsPrime: returns 1 if n is prime, 0 otherwise
//   Uses the sieve buffer: line (n+1) holds '1' or '0'.
// ---------------------------------------------------------------------------
integer proc IsPrime(integer n)
    integer cur_buf
    string  ch[4]
    if n < 2
        return( 0 )
    endif
    cur_buf = GotoBufferId(g_sieve_buf)
    GotoLine(n + 1)
    ch = GetText(1, 1)
    GotoBufferId(cur_buf)
    if ch == "1"
        return( 1 )
    endif
    return( 0 )
end

// ---------------------------------------------------------------------------
// SetComposite: mark n as composite in sieve buffer
// ---------------------------------------------------------------------------
proc SetComposite(integer n)
    integer cur_buf
    cur_buf = GotoBufferId(g_sieve_buf)
    GotoLine(n + 1)
    BegLine()
    DelChar()
    InsertText("0", _INSERT_)
    GotoBufferId(cur_buf)
end

// ---------------------------------------------------------------------------
// BuildSieve: Sieve of Eratosthenes up to LIMIT.
//   Each line in the sieve buffer = one number (line 1 = number 0).
//   Initial value '1' (prime candidate); composite entries set to '0'.
// ---------------------------------------------------------------------------
proc BuildSieve(integer lim)
    integer nIdx, mIdx, cur_buf

    cur_buf = GetBufferId()
    g_sieve_buf = CreateTempBuffer()
    GotoBufferId(g_sieve_buf)
    EmptyBuffer()

    // Fill buffer: lim+1 lines each containing '1'
    // Line 1 = number 0, line 2 = number 1, ...
    nIdx = 0
    while nIdx <= lim
        AddLine("1")
        nIdx = nIdx + 1
    endwhile

    // Mark 0 and 1 as not prime
    GotoLine(1)  BegLine()  DelChar()  InsertText("0", _INSERT_)
    GotoLine(2)  BegLine()  DelChar()  InsertText("0", _INSERT_)

    // Sieve
    nIdx = 2
    while nIdx * nIdx <= lim
        if IsPrime(nIdx)
            mIdx = nIdx * nIdx
            while mIdx <= lim
                SetComposite(mIdx)
                mIdx = mIdx + nIdx
            endwhile
        endif
        nIdx = nIdx + 1
    endwhile

    GotoBufferId(cur_buf)
end

// ---------------------------------------------------------------------------
// CountFamilyForMask
//
//   s        = digit string of the prime (e.g. "121313")
//   dchar    = the digit character being replaced (e.g. '1')
//   mask     = bitmask over the positions where dchar occurs in s.
//              bit 0 = first occurrence, bit 1 = second occurrence, etc.
//              A set bit means that position IS replaced.
//   nOccur   = total number of occurrences of dchar in s
//   pos0..pos5 = positions (1-based within s) of the occurrences
//
//   Returns: number of primes in the resulting family (0-9 replacements,
//            skipping those that produce a leading zero).
// ---------------------------------------------------------------------------
integer proc CountFamilyForMask(string s,
                                integer mask, integer nOccur,
                                integer nPos0, integer nPos1,
                                integer nPos2, integer nPos3,
                                integer nPos4, integer nPos5)
    integer cnt, repl, nNum, leading, startRepl
    string  tmp[12]

    cnt = 0
    startRepl = 0   // try replacements 0..9

    // If ANY replaced position is at column 1 (leading digit), skip repl=0
    leading = 0
    if (mask & 1) and (nOccur >= 1) and (nPos0 == 1)    leading = 1  endif
    if (mask & 2) and (nOccur >= 2) and (nPos1 == 1)    leading = 1  endif
    if (mask & 4) and (nOccur >= 3) and (nPos2 == 1)    leading = 1  endif
    if (mask & 8) and (nOccur >= 4) and (nPos3 == 1)    leading = 1  endif
    if (mask & 16) and (nOccur >= 5) and (nPos4 == 1)   leading = 1  endif
    if (mask & 32) and (nOccur >= 6) and (nPos5 == 1)   leading = 1  endif

    if leading
        startRepl = 1
    endif

    repl = startRepl
    while repl <= 9
        // Build modified number string
        tmp = s

        // For each occurrence bit that is set, replace that position
        if (mask & 1) and (nOccur >= 1)
            tmp = SubStr(tmp, 1, nPos0 - 1) + Chr(repl + 48) + SubStr(tmp, nPos0 + 1, Length(tmp))
        endif
        if (mask & 2) and (nOccur >= 2)
            tmp = SubStr(tmp, 1, nPos1 - 1) + Chr(repl + 48) + SubStr(tmp, nPos1 + 1, Length(tmp))
        endif
        if (mask & 4) and (nOccur >= 3)
            tmp = SubStr(tmp, 1, nPos2 - 1) + Chr(repl + 48) + SubStr(tmp, nPos2 + 1, Length(tmp))
        endif
        if (mask & 8) and (nOccur >= 4)
            tmp = SubStr(tmp, 1, nPos3 - 1) + Chr(repl + 48) + SubStr(tmp, nPos3 + 1, Length(tmp))
        endif
        if (mask & 16) and (nOccur >= 5)
            tmp = SubStr(tmp, 1, nPos4 - 1) + Chr(repl + 48) + SubStr(tmp, nPos4 + 1, Length(tmp))
        endif
        if (mask & 32) and (nOccur >= 6)
            tmp = SubStr(tmp, 1, nPos5 - 1) + Chr(repl + 48) + SubStr(tmp, nPos5 + 1, Length(tmp))
        endif

        nNum = Val(tmp)
        if IsPrime(nNum)
            cnt = cnt + 1
        endif

        repl = repl + 1
    endwhile

    return( cnt )
end

// ---------------------------------------------------------------------------
// CheckPrime51: Check if prime p is part of an 8-prime family.
//   Returns 1 if yes, 0 if no.
// ---------------------------------------------------------------------------
integer proc CheckPrime51(integer p)
    string  s[12]
    integer sLen
    integer dv          // digit value 0..9
    integer nOccur      // how many times dv appears in s
    integer mask        // subset bitmask
    integer maxMask
    integer nPos0, nPos1, nPos2, nPos3, nPos4, nPos5
    integer cIdx        // character index in s
    integer ch          // ASCII value of current char
    integer famCount

    s    = Str(p)
    sLen = Length(s)

    // Only consider primes with at least 2 digits (no single digit edge cases)
    if sLen < 2
        return( 0 )
    endif

    // Try each digit value 0..9 as the "wildcard" digit
    dv = 0
    while dv <= 9
        // Find positions of dv in s (1-based), up to 6 occurrences
        nOccur = 0
        nPos0 = 0  nPos1 = 0  nPos2 = 0
        nPos3 = 0  nPos4 = 0  nPos5 = 0

        cIdx = 1
        while cIdx <= sLen
            ch = Asc(SubStr(s, cIdx, 1))
            if ch == (dv + 48)
                nOccur = nOccur + 1
                if    nOccur == 1   nPos0 = cIdx
                elseif nOccur == 2  nPos1 = cIdx
                elseif nOccur == 3  nPos2 = cIdx
                elseif nOccur == 4  nPos3 = cIdx
                elseif nOccur == 5  nPos4 = cIdx
                elseif nOccur == 6  nPos5 = cIdx
                endif
            endif
            cIdx = cIdx + 1
        endwhile

        if nOccur >= 1
            // Try all non-empty subsets of the nOccur positions
            maxMask = (1 shl nOccur) - 1
            mask = 1
            while mask <= maxMask
                famCount = CountFamilyForMask(s, mask, nOccur,
                                              nPos0, nPos1, nPos2,
                                              nPos3, nPos4, nPos5)
                if famCount >= 8
                    return( 1 )
                endif
                mask = mask + 1
            endwhile
        endif

        dv = dv + 1
    endwhile

    return( 0 )
end

// ---------------------------------------------------------------------------
// Main entry point
// ---------------------------------------------------------------------------
proc Main()
    integer LIMIT
    integer nIdx
    integer answer
    string  resultStr[40]

    LIMIT = 1000000

    Message("Building sieve to ", LIMIT, " ...")
    BuildSieve(LIMIT)
    Message("Sieve built. Searching...")

    answer = 0

    // The answer is a 6-digit prime; start search from 100000 to be safe,
    // but we iterate all primes from 2 upward and take the first hit.
    nIdx = 2
    while nIdx <= LIMIT
        if IsPrime(nIdx)
            if CheckPrime51(nIdx)
                answer = nIdx
                nIdx = LIMIT + 1    // break
            endif
        endif
        nIdx = nIdx + 1
    endwhile

    if answer > 0
        resultStr = Str(answer)
        CopyToWinClip(resultStr)
        Warn("Project Euler #51 answer: ", answer, " (copied to clipboard)")
    else
        Warn("No answer found below ", LIMIT)
    endif

    // Clean up sieve buffer
    AbandonFile(g_sieve_buf)
    g_sieve_buf = 0
end
