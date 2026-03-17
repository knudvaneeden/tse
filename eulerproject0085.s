// euler085.s
// Version: 1.0
// Project Euler - Problem 85: Counting Rectangles
//
// By counting carefully it can be seen that a rectangular grid measuring
// 3 by 2 contains eighteen rectangles.
// Although there exists no rectangular grid that contains exactly two
// million rectangles, find the area of the grid with the nearest solution.
//
// Formula:
//   Number of rectangles in a w x h grid =
//       T(w) * T(h)  where T(n) = n*(n+1)/2  (triangular number)
//   = [w*(w+1)/2] * [h*(h+1)/2]
//
// Strategy:
//   Iterate w from 1 upward while T(w)*T(1) <= 2,000,000 (upper bound).
//   For each w, iterate h from 1 upward until count exceeds 2,000,000.
//   Track the (w, h) pair whose count is closest to 2,000,000.
//   Return the area w*h.
//
// TSE SAL rules observed:
//   - No integer arrays (none needed; only scalar variables used)
//   - Forbidden variable names avoided: no val, pos, str, MAXINT, MININT
//   - Return() always uses parentheses
//   - Warn() used to show the final answer
//   - CopyToWinClip() copies only the bare numeric answer
//   - Result is NOT pasted into any buffer
//   - Version number included at top
//   - 32-bit integer arithmetic: max intermediate = 2001*2002/2 = 2,003,001
//     which is well within 2,147,483,647
//
// Answer: area = 2772  (grid 36 x 77, rectangles = 1,999,998)

// ---------------------------------------------------------------------------
// Helper: compute triangular number T(n) = n*(n+1)/2
// ---------------------------------------------------------------------------
INTEGER PROC TriNum(INTEGER nv_arg)
    RETURN(nv_arg * (nv_arg + 1) / 2)
END

// ---------------------------------------------------------------------------
// Main procedure
// ---------------------------------------------------------------------------
PROC Main()
    INTEGER ww          // current width  dimension (outer loop)
    INTEGER hh          // current height dimension (inner loop)
    INTEGER tw          // triangular number for ww
    INTEGER th          // triangular number for hh
    INTEGER cnt         // rectangle count for current (ww, hh)
    INTEGER best_diff   // smallest |cnt - 2000000| found so far
    INTEGER best_area   // area of best grid found so far
    INTEGER cur_diff    // |cnt - 2000000| for current candidate
    STRING  ans_str[20] // will hold Str(best_area) for display
    INTEGER target      // the target rectangle count

    target    = 2000000
    best_diff = target      // initialise to worst possible difference
    best_area = 0

    // Outer loop: increase ww as long as T(ww)*T(1) = T(ww) <= target
    // T(1) = 1, so we stop when T(ww) > target, i.e. ww*(ww+1)/2 > 2000000
    // Largest ww satisfying T(ww) <= 2000000 is ww = 1999 (T(1999)=1999000)
    // ww = 2000 gives T(2000) = 2001000 > 2000000, so loop runs to ww=1999+1
    // We let ww run to 2000 to catch the crossover.
    ww = 1
    WHILE TriNum(ww) <= target
        tw = TriNum(ww)

        // Inner loop: increase hh until count exceeds target
        hh = 1
        WHILE TRUE
            th  = TriNum(hh)
            cnt = tw * th

            cur_diff = cnt - target
            IF cur_diff < 0
                cur_diff = -cur_diff
            ENDIF

            IF cur_diff < best_diff
                best_diff = cur_diff
                best_area = ww * hh
            ENDIF

            // Once count exceeds target, going higher only makes it worse
            IF cnt >= target
                BREAK
            ENDIF

            hh = hh + 1
        ENDWHILE

        ww = ww + 1
    ENDWHILE

    // Display and copy the answer
    ans_str = Str(best_area)
    Warn("Project Euler #85 answer: " + ans_str)
    CopyToWinClip(ans_str)
END
