// euler086.s
// Version: 1.0
// Project Euler - Problem 86: Cuboid Route
// https://projecteuler.net/problem=86
//
// A spider sits in one corner of a cuboid room (sides a >= b >= c, integers).
// The shortest surface path = sqrt(a^2 + (b+c)^2)  [unfold the box].
// Count cuboids (ignoring rotations) where this path length is an integer.
// Find the least M such that the total count first exceeds 1,000,000.
//
// Algorithm:
//   For each side length aa (the longest side, 1..M):
//     For each bc = b+c, from 1 to 2*aa:
//       Check if aa*aa + bc*bc is a perfect square (integer isqrt).
//       If yes, add combinations(aa, bc) to the running total.
//         If aa >= bc  => combos = bc / 2
//         If aa <  bc  => combos = aa - (bc - 1) / 2
//   Stop at the first aa where total > 1,000,000.
//
// TSE SAL rules observed:
//   - No integer arrays (temp buffer used for isqrt cache if needed)
//   - No reserved names used as variables (val, pos, str, MAXINT, MININT)
//   - String declarations use square brackets
//   - Return() always has parentheses
//   - 32-bit integers only (all values fit comfortably)
//   - Warn() to show the final answer
//   - CopyToWinClip() on the bare answer string only
//   - No insertion of result into any buffer/document
//   - Version number included at top

// ---------------------------------------------------------------------------
// IsqrtOf(nn)
//   Returns floor(sqrt(nn)) via Newton's method (integer arithmetic only).
//   nn must be >= 0.
// ---------------------------------------------------------------------------
INTEGER PROC IsqrtOf(INTEGER nn)
    INTEGER xcur, xnxt, tmp

    IF nn <= 0
        RETURN(0)
    ENDIF
    IF nn == 1
        RETURN(1)
    ENDIF

    // Start estimate: use nn itself (will converge quickly via Newton)
    xcur = nn
    LOOP
        xnxt = (xcur + nn / xcur) / 2
        IF xnxt >= xcur
            BREAK
        ENDIF
        xcur = xnxt
    ENDLOOP

    // xcur = floor(sqrt(nn)), verify and adjust down if needed
    tmp = xcur
    WHILE tmp * tmp > nn
        tmp = tmp - 1
    ENDWHILE
    RETURN(tmp)
END

// ---------------------------------------------------------------------------
// CombosFor(aa, bc)
//   Count valid (b, c) pairs with b >= c >= 1, b+c = bc, b <= aa.
//   Constraint: longest side is aa, so aa >= b >= c.
// ---------------------------------------------------------------------------
INTEGER PROC CombosFor(INTEGER aa, INTEGER bc)
    // If 2*aa < bc, then b or c would exceed aa -- zero combos
    IF 2 * aa < bc
        RETURN(0)
    ENDIF
    // If aa >= bc: any (b,c) with b+c=bc, b>=c works => floor(bc/2) combos
    IF aa >= bc
        RETURN(bc / 2)
    ENDIF
    // aa < bc: some pairs rejected because b > aa
    // Valid combos = aa - floor((bc-1)/2)
    RETURN(aa - (bc - 1) / 2)
END

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
PROC Main()
    INTEGER aa, bc, sq, root, combos, total
    INTEGER found_m
    STRING  ans[20]

    total   = 0
    found_m = 0

    aa = 1
    WHILE aa <= 2000000
        bc = 1
        WHILE bc <= 2 * aa
            sq   = aa * aa + bc * bc
            root = IsqrtOf(sq)
            IF root * root == sq
                combos = CombosFor(aa, bc)
                total  = total + combos
            ENDIF
            IF total > 1000000
                BREAK
            ENDIF
            bc = bc + 1
        ENDWHILE
        IF total > 1000000
            found_m = aa
            BREAK
        ENDIF
        aa = aa + 1
    ENDWHILE

    ans = Str(found_m)
    Warn("Project Euler #86 answer: " + ans)
    CopyToWinClip(ans)
END
