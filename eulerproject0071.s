// ===========================================================================
// euler071.s  -  TSE SAL solution for Project Euler Problem 71
// ---------------------------------------------------------------------------
// Problem:
//   Consider all reduced proper fractions n/d with d <= 1,000,000 listed in
//   ascending order.  Find the numerator of the fraction immediately to the
//   left of 3/7.
//
// Algorithm:
//   For every denominator d (1 .. 1 000 000) the largest integer n such that
//   n/d < 3/7  is  n = floor( (3*d - 1) / 7 ).
//   We scan all d values and keep track of the best (largest) n/d seen.
//   Comparison:  new fraction  best_n/best_d  vs  n/d
//               cross-multiply to avoid floating point:
//               n/d > best_n/best_d  iff  n * best_d > best_n * d
//
//   The answer is best_n at the end of the loop.
//
// Usage:
//   Load this file in TSE Pro, then press <F9> (or use Macro -> Execute) to
//   run the macro.  The result is displayed in a message box and also written
//   to the current buffer.
// ===========================================================================

proc euler071()

    integer d           // current denominator
    integer n           // best numerator for current d
    integer best_n      // numerator   of best fraction found so far
    integer best_d      // denominator of best fraction found so far
    integer MAX_D       // upper limit for denominators

    string  result[40]  // string buffer for the answer

    MAX_D  = 1000000

    // Start with the trivially valid fraction 0/1 (= 0 < 3/7)
    best_n = 0
    best_d = 1

    // -----------------------------------------------------------------------
    // Main loop: walk every denominator from 1 to 1 000 000
    // -----------------------------------------------------------------------
    d = 1
    while d <= MAX_D

        // Largest n with n/d < 3/7  =>  n < 3d/7  =>  n = floor((3d-1)/7)
        n = (3 * d - 1) / 7     // SAL integer division truncates toward zero

        // Only consider n >= 1  (proper fraction, n > 0)
        if n >= 1

            // Compare n/d  vs  best_n/best_d  via cross-multiplication
            // n/d > best_n/best_d  iff  n * best_d > best_n * d
            if (n * best_d) > (best_n * d)
                best_n = n
                best_d = d
            endif

        endif

        d = d + 1
    endwhile
    // -----------------------------------------------------------------------

    // Format and display the result
    result = Str(best_n)

    Warn("Euler #71 answer  (numerator of fraction left of 3/7): " + result)
    CopyToWinClip( result )

    // Also append the answer to the current buffer so it is visible/saveable
    // EndFile()
    // AddLine("Euler Problem 71 - numerator of fraction immediately left of 3/7:")
    // AddLine("  best fraction found : " + Str(best_n) + " / " + Str(best_d))
    // AddLine("  answer (numerator)  : " + result)

end

// ---------------------------------------------------------------------------
// Entry point - executed when the macro is run
// ---------------------------------------------------------------------------
proc Main()
    euler071()
end
