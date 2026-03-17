// euler087.s
// Version: 1.0
//
// Project Euler - Problem 87: Prime Power Triples
//
// The smallest number expressible as the sum of a prime square, prime cube,
// and prime fourth power is 28.
//   28 = 2^2 + 2^3 + 2^4
//   33 = 3^2 + 2^3 + 2^4
//   49 = 5^2 + 2^3 + 2^4
//   47 = 2^2 + 3^3 + 2^4
//
// How many numbers below fifty million can be expressed as the sum of a
// prime square, prime cube, and prime fourth power?
//
// Answer: 1097343
//
// ---------------------------------------------------------------------------
// TSE SAL rules applied (explicitly confirmed):
//
//  1. NO INTEGER ARRAYS
//     -> sieve_buf : CreateTempBuffer(), 7072 lines, "1"/"0" per line
//     -> found_buf : CreateTempBuffer(), 250000 lines, 200-char "0...0" per line
//        Each line represents 200 consecutive candidate numbers (BLOCK=200).
//        Line  = (candidate / 200) + 1   [1-based]
//        Char  = (candidate mod 200) + 1 [1-based inside the 200-char string]
//
//  2. RESERVED / FORBIDDEN VARIABLE NAMES: val, pos, str, MAXINT, MININT
//     -> NOT used as variable names anywhere in this file.
//        All variable names checked: ndx, prime_r, prime_q, prime_p, r4, q3,
//        p2, part_sum, full_sum, count_found, sieve_len, found_lines,
//        line_idx, chr_idx, row_str, ans_str, prev_buf, result_v, sv,
//        line_nr, char_nr, cand, row_txt, head_part, tail_part, ch.
//        None of these match reserved/forbidden names.
//
//  3. STRING DECLARATIONS USE SQUARE BRACKETS: STRING foo[n]
//     -> All string vars declared as STRING foo[n].  No colon syntax used.
//
//  4. Return() ALWAYS HAS PARENTHESES
//     -> Every Return statement written as Return() or Return(expr).
//
//  5. Warn() BOX TO SHOW FINAL ANSWER
//     -> Warn("Project Euler #87 answer: " + ans_str)
//
//  6. CopyToWinClip() COPIES ONLY THE BARE NUMERIC ANSWER
//     -> CopyToWinClip(ans_str)  -- ans_str holds only the number string
//
//  7. NO PASTE OF RESULT INTO .s BUFFER
//     -> No AddLine / InsertText of ans_str / count_found into any editor buffer.
//
//  8. 32-BIT SIGNED INTEGER OVERFLOW ANALYSIS
//     -> max r^4 : 83^4  = 47,458,321        < 2,147,483,647  OK
//     -> max q^3 : 367^3 = 49,430,863        < 2,147,483,647  OK
//     -> max p^2 : 7069^2= 49,970,761        < 2,147,483,647  OK
//     -> part_sum (r4+q3) checked < LIMIT before computing p2, so < 50M  OK
//     -> full_sum checked < LIMIT before storage, so < 50M               OK
//     -> Intermediate r4 steps: prime_r <= 83, r*r <= 6889, r*r*r <= 571787,
//        r*r*r*r <= 47,458,321 -- all well within 32-bit range.
//
//  9. VERSION NUMBER IN FILE
//     -> "// Version: 1.0"  at top of file.
//
// ---------------------------------------------------------------------------
// Buffer structure:
//   sieve_buf : 7072 lines, line (ndx+1) = "1" if ndx is prime, "0" otherwise
//               ndx range 0..7071
//   found_buf : 250000 lines, each a 200-char string of '0'/'1'
//               Tracks which candidate numbers < 50,000,000 have been found.
//               BLOCK = 200; line = (n/200)+1; char position = (n mod 200)+1
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Global variables (no integer arrays)
// ---------------------------------------------------------------------------
INTEGER LIMIT        // = 50000000
INTEGER BLOCK        // = 200
INTEGER SIEVE_MAX    // = 7072

INTEGER sieve_buf    // buffer ID for sieve
INTEGER found_buf    // buffer ID for found-set

// ---------------------------------------------------------------------------
// GetSieve: return 1 if sieve index ndx is prime, else 0
// ---------------------------------------------------------------------------
INTEGER PROC GetSieve(INTEGER ndx)
    INTEGER prev_buf
    INTEGER result_v
    prev_buf = GetBufferId()
    GotoBufferId(sieve_buf)
    GotoLine(ndx + 1)
    result_v = Val(GetText(1, 1))
    GotoBufferId(prev_buf)
    Return(result_v)
END

// ---------------------------------------------------------------------------
// SetSieve: write 1 or 0 at sieve index ndx
// ---------------------------------------------------------------------------
PROC SetSieve(INTEGER ndx, INTEGER sv)
    INTEGER prev_buf
    prev_buf = GetBufferId()
    GotoBufferId(sieve_buf)
    GotoLine(ndx + 1)
    BegLine()
    DelChar()
    IF sv == 1
        InsertText("1", _INSERT_)
    ELSE
        InsertText("0", _INSERT_)
    ENDIF
    GotoBufferId(prev_buf)
END

// ---------------------------------------------------------------------------
// IsFound: return 1 if candidate cand is already in the found-set, else 0
// ---------------------------------------------------------------------------
INTEGER PROC IsFound(INTEGER cand)
    INTEGER prev_buf
    INTEGER line_nr
    INTEGER char_nr
    STRING  ch[1]
    prev_buf = GetBufferId()
    GotoBufferId(found_buf)
    line_nr = cand / BLOCK + 1
    char_nr = cand mod BLOCK + 1
    GotoLine(line_nr)
    ch = GetText(char_nr, 1)
    GotoBufferId(prev_buf)
    IF ch == "1"
        Return(1)
    ENDIF
    Return(0)
END

// ---------------------------------------------------------------------------
// SetFound: mark candidate cand as found
// Uses SubStr to replace char at position char_nr without array indexing
// ---------------------------------------------------------------------------
PROC SetFound(INTEGER cand)
    INTEGER prev_buf
    INTEGER line_nr
    INTEGER char_nr
    INTEGER tail_start
    STRING  row_txt[200]
    STRING  head_part[200]
    STRING  tail_part[200]
    prev_buf = GetBufferId()
    GotoBufferId(found_buf)
    line_nr = cand / BLOCK + 1
    char_nr = cand mod BLOCK + 1
    GotoLine(line_nr)
    row_txt   = GetText(1, BLOCK)
    // Replace character at char_nr with "1":
    //   head_part = left (char_nr - 1) characters
    //   tail_part = characters from (char_nr + 1) to end
    head_part = SubStr(row_txt, 1, char_nr - 1)
    tail_start = char_nr + 1
    tail_part = SubStr(row_txt, tail_start, BLOCK - char_nr)
    row_txt = head_part + "1" + tail_part
    BegLine()
    KillToEol()
    InsertText(row_txt, _INSERT_)
    GotoBufferId(prev_buf)
END

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
PROC Main()
    INTEGER ndx
    INTEGER prime_r
    INTEGER prime_q
    INTEGER prime_p
    INTEGER r4
    INTEGER q3
    INTEGER p2
    INTEGER part_sum
    INTEGER full_sum
    INTEGER count_found
    INTEGER sieve_len
    INTEGER found_lines
    INTEGER line_idx
    INTEGER chr_idx
    STRING  row_str[200]
    STRING  ans_str[20]

    // --- Initialise constants ---
    LIMIT     = 50000000
    BLOCK     = 200
    SIEVE_MAX = 7072        // candidates 0..7071 cover all primes up to sqrt(50M)

    // -----------------------------------------------------------------------
    // 1. Build sieve buffer (Sieve of Eratosthenes up to 7071)
    // -----------------------------------------------------------------------
    sieve_buf = CreateTempBuffer()
    IF sieve_buf == -1
        Warn("euler087: cannot create sieve buffer")
        Return()
    ENDIF
    GotoBufferId(sieve_buf)

    // Fill with "1" (prime candidate) for indices 0..SIEVE_MAX-1
    sieve_len = 0
    WHILE sieve_len < SIEVE_MAX
        AddLine("1")
        sieve_len = sieve_len + 1
    ENDWHILE

    // 0 and 1 are not prime
    SetSieve(0, 0)
    SetSieve(1, 0)

    // Sieve: for each ndx where ndx*ndx < SIEVE_MAX, cross out multiples
    ndx = 2
    WHILE ndx * ndx < SIEVE_MAX
        IF GetSieve(ndx) == 1
            prime_p = ndx * ndx
            WHILE prime_p < SIEVE_MAX
                SetSieve(prime_p, 0)
                prime_p = prime_p + ndx
            ENDWHILE
        ENDIF
        ndx = ndx + 1
    ENDWHILE

    // -----------------------------------------------------------------------
    // 2. Build found buffer: 250000 lines of 200 '0' characters each
    //    LIMIT / BLOCK = 50000000 / 200 = 250000
    // -----------------------------------------------------------------------
    found_buf = CreateTempBuffer()
    IF found_buf == -1
        Warn("euler087: cannot create found buffer")
        AbandonFile(sieve_buf)
        Return()
    ENDIF
    GotoBufferId(found_buf)

    // Build a 200-char all-zeros string
    row_str = ""
    chr_idx = 0
    WHILE chr_idx < BLOCK
        row_str = row_str + "0"
        chr_idx = chr_idx + 1
    ENDWHILE

    // Insert 250000 lines
    found_lines = LIMIT / BLOCK    // 250000
    line_idx = 0
    WHILE line_idx < found_lines
        AddLine(row_str)
        line_idx = line_idx + 1
    ENDWHILE

    // -----------------------------------------------------------------------
    // 3. Triple nested loop: outer = r (4th power), middle = q (cube),
    //    inner = p (square).  Break early when partial sum >= LIMIT.
    // -----------------------------------------------------------------------
    prime_r = 2
    WHILE prime_r < SIEVE_MAX
        IF GetSieve(prime_r) == 1
            // Compute r^4 step by step to stay within 32-bit range
            r4 = prime_r * prime_r
            r4 = r4 * prime_r
            r4 = r4 * prime_r
            IF r4 >= LIMIT
                // All larger r values also give r^4 >= LIMIT, stop outer loop
                prime_r = SIEVE_MAX
            ELSE
                prime_q = 2
                WHILE prime_q < SIEVE_MAX
                    IF GetSieve(prime_q) == 1
                        q3 = prime_q * prime_q * prime_q
                        part_sum = r4 + q3
                        IF part_sum >= LIMIT
                            // All larger q values also fail, stop middle loop
                            prime_q = SIEVE_MAX
                        ELSE
                            prime_p = 2
                            WHILE prime_p < SIEVE_MAX
                                IF GetSieve(prime_p) == 1
                                    p2 = prime_p * prime_p
                                    full_sum = part_sum + p2
                                    IF full_sum >= LIMIT
                                        // All larger p values also fail, stop inner loop
                                        prime_p = SIEVE_MAX
                                    ELSE
                                        // Mark this sum as found (if not already)
                                        IF NOT IsFound(full_sum)
                                            SetFound(full_sum)
                                        ENDIF
                                        prime_p = prime_p + 1
                                    ENDIF
                                ELSE
                                    prime_p = prime_p + 1
                                ENDIF
                            ENDWHILE
                            prime_q = prime_q + 1
                        ENDIF
                    ELSE
                        prime_q = prime_q + 1
                    ENDIF
                ENDWHILE
                prime_r = prime_r + 1
            ENDIF
        ELSE
            prime_r = prime_r + 1
        ENDIF
    ENDWHILE

    // -----------------------------------------------------------------------
    // 4. Count all marked positions in found_buf
    // -----------------------------------------------------------------------
    count_found = 0
    line_idx = 0
    WHILE line_idx < found_lines
        GotoBufferId(found_buf)
        GotoLine(line_idx + 1)
        row_str = GetText(1, BLOCK)
        chr_idx = 1
        WHILE chr_idx <= BLOCK
            IF SubStr(row_str, chr_idx, 1) == "1"
                count_found = count_found + 1
            ENDIF
            chr_idx = chr_idx + 1
        ENDWHILE
        line_idx = line_idx + 1
    ENDWHILE

    // -----------------------------------------------------------------------
    // 5. Discard temp buffers
    // -----------------------------------------------------------------------
    AbandonFile(sieve_buf)
    AbandonFile(found_buf)

    // -----------------------------------------------------------------------
    // 6. Show result and copy to clipboard
    // -----------------------------------------------------------------------
    ans_str = Str(count_found)

    // Rule 5: Use Warn() to show the final answer
    Warn("Project Euler #87 answer: " + ans_str)

    // Rule 6: CopyToWinClip() copies ONLY the bare answer (not surrounding text)
    CopyToWinClip(ans_str)

    // Rule 7: No AddLine / InsertText of ans_str into any buffer

END
