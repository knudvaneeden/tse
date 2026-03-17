/****************************************************************************
 *
 *  euler073.s  -  The SemWare Editor (TSE) SAL Macro
 *
 *  Project Euler - Problem 73: Counting Fractions in a Range
 *  https://projecteuler.net/problem=73
 *
 *  Problem:
 *    How many reduced proper fractions n/d (with HCF(n,d)=1, n<d)
 *    lie strictly between 1/3 and 1/2 for d <= 12000?
 *
 *  Method: Farey Sequence neighbour algorithm
 *  -----------------------------------------------
 *  The Farey sequence F(N) lists all reduced fractions in [0,1] with
 *  denominator <= N, in ascending order.  Given two consecutive Farey
 *  fractions a/b and c/d, the NEXT fraction p/q in F(N) satisfies:
 *
 *      k = floor((b + N) / d)
 *      p = k * c - a
 *      q = k * d - b
 *
 *  Starting just after 1/3 and stepping until we reach 1/2, we count
 *  every intermediate fraction.  No GCD computation needed.
 *
 *  Bootstrap:
 *    The pair (0/1, 1/3) generates the first fraction after 1/3 via
 *    one application of the recurrence.  We then walk forward to 1/2.
 *
 *  Expected answer: 7295372
 *
 *  Usage:  Load this file in TSE, then press <F9> (or ExecMacro).
 *
 *  Author:  SAL implementation for Project Euler
 *  Date:    2026
 *
 ****************************************************************************/

// ---------------------------------------------------------------------------
// Euler073  -  main entry point
// ---------------------------------------------------------------------------
proc Main()

    // --- variable declarations (all at top of proc) ---
    integer N      = 12000     // Farey order (max denominator)
    integer prev_n = 0         // numerator   of left Farey neighbour
    integer prev_d = 1         // denominator of left Farey neighbour
    integer cur_n  = 1         // numerator   of current fraction (start: 1/3)
    integer cur_d  = 3         // denominator of current fraction (start: 1/3)
    integer k
    integer next_n
    integer next_d
    integer count  = 0

    // ------------------------------------------------------------
    // Step 1: Bootstrap - find the first Farey fraction after 1/3
    //
    //   Start with the consecutive Farey pair (0/1, 1/3).
    //   Apply one Farey step to get the fraction immediately right
    //   of 1/3 in F(N).
    //
    //   k    = floor((1 + N) / 3)  = floor(12001/3) = 4000
    //   p    = k * 1 - 0           = 4000
    //   q    = k * 3 - 1           = 11999
    //
    //   First fraction after 1/3 in F(12000) = 4000/11999
    // ------------------------------------------------------------
    k      = (prev_d + N) / cur_d   // integer division = floor for positives
    next_n = k * cur_n - prev_n
    next_d = k * cur_d - prev_d

    // Advance: previous = 1/3,  current = first fraction after 1/3
    prev_n = cur_n
    prev_d = cur_d
    cur_n  = next_n
    cur_d  = next_d

    // ------------------------------------------------------------
    // Step 2: Walk the Farey sequence forward, counting each
    //         fraction, until we reach 1/2.
    //
    //   Stop condition: cur_n/cur_d == 1/2
    //   i.e. 2 * cur_n == cur_d
    // ------------------------------------------------------------
    while (2 * cur_n) <> cur_d

        count = count + 1

        // Next Farey fraction after cur, given previous prev
        k      = (prev_d + N) / cur_d
        next_n = k * cur_n - prev_n
        next_d = k * cur_d - prev_d

        // Shift window
        prev_n = cur_n
        prev_d = cur_d
        cur_n  = next_n
        cur_d  = next_d

    endwhile

    // ------------------------------------------------------------
    // Step 3: Display result using Warn()
    // ------------------------------------------------------------
    CopyToWinClip( Str( count ) )
    Warn("Project Euler - Problem 73" + Chr(13) + "===============================" + Chr(13) + "Reduced fractions n/d" + Chr(13) + "with 1/3 < n/d < 1/2, d <= 12000" + Chr(13) + "" + Chr(13) + "Answer = " + Str(count) + Chr(13) + "" + Chr(13) + "Expected: 7295372")

end

// ---------------------------------------------------------------------------
// Bind to a key if desired, e.g.:
//   <Ctrl F1>  Main()
// ---------------------------------------------------------------------------
