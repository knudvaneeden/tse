// ============================================================
// euler100.s
// Version: 1.2
//
// Project Euler - Problem 100: Arranged Probability
// https://projecteuler.net/problem=100
//
// A box has blue and red discs.  Two discs are drawn at random
// without replacement.  We want P(both blue) = exactly 1/2.
// Condition:  b/t * (b-1)/(t-1) = 1/2
//         =>  2*b*(b-1) = t*(t-1)
//
// The recurrence (derived from Pell-equation analysis) is:
//   b_new = 3*b + 2*t - 2
//   t_new = 4*b + 3*t - 3
// Starting from the example: b=15, t=21
// Iterate until t > 10^12, then report the blue count b.
//
// 64-BIT EMULATION
// SAL integers are 32-bit signed (max ~2,147,483,647).
// Values here grow to ~10^12, so each number is stored as
// two 32-bit halves:   value = hi * BASE + lo
// BASE = 1,000,000 (10^6).
// All intermediate products were verified to stay < 2^31.
//
// CONFIRMED TSE SAL RULES APPLIED:
//   [1] No integer arrays -- only scalar variables
//   [2] No reserved/built-in names used as variables
//       (val, pos, str, s, mark, find, insert, delete,
//        length, copy, old, loop, var, etc. all avoided)
//   [3] String lengths <= 255 characters
//   [4] 32-bit arithmetic only -- 64-bit via (hi,lo) pairs
//   [5] Warn() used to show the final answer
//   [6] CopyToWinClip() clips ONLY the bare answer string (no Str() wrap needed)
//   [7] No result pasted into the .s buffer
//   [8] Version number included (see top of file)
//   [9] Return() always written with parentheses
//  [10] No 'while 1' loops -- flag variable used instead
//  [11] Loop exits only via 'break'
//  [12] Each statement on its own line (no ; separator)
//  [13] Procedure/function endings: 'end' only (never 'end proc')
//  [14] Variable declarations placed at the top of each proc
//  [15] No use of 'val' or 'pos' as variable names
// ============================================================

// BASE = 1,000,000
integer BASE

proc SetBase()
    BASE = 1000000
end

// -------------------------------------------------------
// Concatenate a (hi * BASE + lo) pair into a decimal string.
// hi  : the high part  (0 .. ~2,000,000)
// lo  : the low part   (0 .. 999,999)
// dest: caller-supplied string variable to receive result
// -------------------------------------------------------
proc Pair2Str(integer hi, integer lo, var string dest)
    string lo_str[12]
    integer pad_needed
    integer pad_idx

    if hi == 0
        dest = Str(lo)
    else
        lo_str = Str(lo)
        // Zero-pad lo_str to exactly 6 digits
        pad_needed = 6 - Length(lo_str)
        pad_idx = 1
        while pad_idx <= pad_needed
            lo_str = "0" + lo_str
            pad_idx = pad_idx + 1
        endwhile
        dest = Str(hi) + lo_str
    endif
end

// -------------------------------------------------------
// Main entry point
// -------------------------------------------------------
proc Main()
    // 64-bit representation of blue count: b = bhi*BASE + blo
    integer bhi
    integer blo
    // 64-bit representation of total count: t = thi*BASE + tlo
    integer thi
    integer tlo
    // Temporaries for the recurrence step
    integer nb_lo_raw
    integer carry_b
    integer nb_hi
    integer nb_lo
    integer nt_lo_raw
    integer carry_t
    integer nt_hi
    integer nt_lo
    // Loop control flag (1 = keep iterating, 0 = stop)
    integer keep_going
    // String holding the final answer (blue disc count)
    string answer[20]

    answer = ""

    SetBase()

    // Initial values from the problem statement: b=15, t=21
    bhi = 0
    blo = 15
    thi = 0
    tlo = 21

    // Limit: t must exceed 10^12
    // 10^12 in (hi,lo) form with BASE=10^6 is (1000000, 0)
    // i.e. limit_hi = 1,000,000  and  limit_lo = 0

    keep_going = 1
    while keep_going == 1

        // Apply recurrence:
        //   b_new = 3*b + 2*t - 2
        //   t_new = 4*b + 3*t - 3

        // --- compute new b ---
        nb_lo_raw = 3 * blo + 2 * tlo - 2
        carry_b   = nb_lo_raw / BASE
        nb_lo     = nb_lo_raw mod BASE
        nb_hi     = 3 * bhi + 2 * thi + carry_b

        // --- compute new t ---
        nt_lo_raw = 4 * blo + 3 * tlo - 3
        carry_t   = nt_lo_raw / BASE
        nt_lo     = nt_lo_raw mod BASE
        nt_hi     = 4 * bhi + 3 * thi + carry_t

        bhi = nb_hi
        blo = nb_lo
        thi = nt_hi
        tlo = nt_lo

        // Check if t > 10^12, i.e. thi > 1000000,
        // OR thi == 1000000 AND tlo > 0
        if thi > 1000000
            keep_going = 0
        else
            if thi == 1000000
                if tlo > 0
                    keep_going = 0
                endif
            endif
        endif

        if keep_going == 0
            break
        endif

    endwhile

    // Build the answer string from (bhi, blo)
    Pair2Str(bhi, blo, answer)

    // Show the answer in a Warn() box
    Warn("Project Euler #100 answer (blue discs): " + answer)

    // Copy ONLY the bare answer to the Windows clipboard
    CopyToWinClip(answer)

end
