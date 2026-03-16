// Project Euler - Problem 45
// Triangular, Pentagonal, and Hexagonal
//
// Triangle   T(n) = n*(n+1)/2     --> 1, 3, 6, 10, 15, ...
// Pentagonal P(n) = n*(3*n-1)/2   --> 1, 5, 12, 22, 35, ...
// Hexagonal  H(n) = n*(2*n-1)     --> 1, 6, 15, 28, 45, ...
//
// It can be verified that T(285) = P(165) = H(143) = 40755.
// Find the next triangle number that is also pentagonal and hexagonal.
//
// Key insight: Every H(n) = T(2n-1), so all hexagonal numbers are also
// triangular. We only need to find numbers that are BOTH pentagonal
// and hexagonal.
//
// Approach: Two-pointer merge on the two increasing sequences.
//   - Advance the pentagonal index if P(m) < H(n)
//   - Advance the hexagonal index if H(n) < P(m)
//   - When P(m) == H(n), we have a match
//
// Overflow avoidance:
//   H(n) = n*(2n-1) -- no overflow up to answer (n=27693, result=1533776805)
//
//   P(m) = m*(3m-1)/2 -- naive intermediate overflows 32-bit at m~26755.
//   Safe form: divide BEFORE multiplying, exploiting that one factor is even:
//     if m is even:  P(m) = (m/2) * (3m-1)
//     if m is odd:   P(m) = m * ((3m-1)/2)   [3m-1 is even when m is odd]
//   Max intermediate for m=31929 is 31929*47893 = 1529175597 < 2^31-1. OK.
//
// Answer: 1533776805
//
// SAL constraints observed:
//   - INTEGER only (no floats)
//   - No arrays
//   - return() requires parentheses
//   - Warn() for output, CopyToWinClip() for clipboard copy

// ---------------------------------------------------------------------------
// SafePent(m) -- compute P(m) = m*(3m-1)/2 without 32-bit overflow
// Divide before multiplying: one of m or (3m-1) is always even.
//   m even --> (m/2)*(3m-1)
//   m odd  --> m*((3m-1)/2)
// ---------------------------------------------------------------------------
integer proc SafePent(integer m)
    if m mod 2 == 0
        return( (m / 2) * (3 * m - 1) )
    endif
    return( m * ((3 * m - 1) / 2) )
end

proc Main()
    integer pm      // pentagonal index m
    integer hn      // hexagonal index n
    integer p       // current pentagonal number P(m)
    integer h       // current hexagonal number H(n)
    string  s[30]

    // Start just past the known solution T(285)=P(165)=H(143)=40755
    pm = 166
    hn = 144
    p = SafePent(pm)
    h = hn * (2 * hn - 1)

    while TRUE
        if p == h
            // Found: p is both pentagonal and hexagonal (hence triangular)
            s = Str(p)
            Warn("Euler 45: Next T=P=H number is " + s)
            CopyToWinClip(s)
            return()
        elseif p < h
            // Advance pentagonal
            pm = pm + 1
            p = SafePent(pm)
        else
            // Advance hexagonal
            hn = hn + 1
            h = hn * (2 * hn - 1)
        endif
    endwhile
end
