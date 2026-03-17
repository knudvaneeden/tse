// euler091.s
// Project Euler - Problem 91
// Right Triangles with Integer Coordinates
//
// Count all right triangles OPQ where:
//   O = (0,0), P = (x1,y1), Q = (x2,y2)
//   0 <= x1,y1,x2,y2 <= 50
//   Triangle is non-degenerate (P != O, Q != O, P != Q, not collinear)
//   Triangle has a right angle at O, P, or Q
//
// Strategy: iterate all ordered pairs (P,Q), count valid right triangles,
// divide by 2 at the end (each unordered pair counted twice).
//
// Right angle at O: OP . OQ = x1*x2 + y1*y2 == 0
// Right angle at P: PO . PQ = (-x1)*(x2-x1) + (-y1)*(y2-y1) == 0
// Right angle at Q: QO . QP = (-x2)*(x1-x2) + (-y2)*(y1-y2) == 0
//
// 32-bit overflow check:
//   dot_O max = 50*50 + 50*50 = 5000             OK
//   dot_P/Q max magnitude = 50*100 + 50*100 = 10000  OK
//   count max ~ 28468 (before /2)                OK
//   All well within INT_MAX = 2,147,483,647
//
// Note: TSE SAL has no 'iterate'/'continue' keyword.
//       Loop-skip logic is handled with nested if/endif blocks.
//
// Version: 1.1
// Date   : 2026-03-17

integer gx1, gy1, gx2, gy2    // loop counters
integer gdot_o                  // dot product at origin O
integer gdot_p                  // dot product at vertex P
integer gdot_q                  // dot product at vertex Q
integer gcross                  // cross product (collinearity test)
integer gcnt                    // running count (ordered pairs)
string  gans[20]                // final answer string

proc Main()
    gx1    = 0
    gy1    = 0
    gx2    = 0
    gy2    = 0
    gdot_o = 0
    gdot_p = 0
    gdot_q = 0
    gcross = 0
    gcnt   = 0
    gans   = ""

    for gx1 = 0 to 50
        for gy1 = 0 to 50
            for gx2 = 0 to 50
                for gy2 = 0 to 50

                    // Only process if P != O  AND  Q != O  AND  P != Q
                    if not (gx1 == 0 and gy1 == 0)
                        if not (gx2 == 0 and gy2 == 0)
                            if not (gx1 == gx2 and gy1 == gy2)

                                // Cross product: skip collinear
                                gcross = gx1 * gy2 - gy1 * gx2
                                if gcross <> 0

                                    // Dot product at O: OP . OQ
                                    gdot_o = gx1 * gx2 + gy1 * gy2

                                    // Dot product at P: PO . PQ
                                    gdot_p = (-gx1) * (gx2 - gx1) + (-gy1) * (gy2 - gy1)

                                    // Dot product at Q: QO . QP
                                    gdot_q = (-gx2) * (gx1 - gx2) + (-gy2) * (gy1 - gy2)

                                    // Count if any vertex has a right angle
                                    if gdot_o == 0 or gdot_p == 0 or gdot_q == 0
                                        gcnt = gcnt + 1
                                    endif

                                endif
                            endif
                        endif
                    endif

                endfor
            endfor
        endfor
    endfor

    // Each unordered pair {P,Q} was counted twice
    gcnt = gcnt / 2

    gans = Str(gcnt)

    // Show final answer in Warn() box
    Warn("Project Euler #91 answer: " + gans)

    // Copy only the bare answer to the Windows clipboard
    CopyToWinClip(gans)

end
