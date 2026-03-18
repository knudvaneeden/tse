// euler106.s
// Version: 1.0
//
// Project Euler - Problem 106
// "Special Subset Sums: Meta-testing"
//
// Problem:
//   Given a set A of n = 12 strictly increasing elements (Rule 2 is already
//   satisfied: larger subset => larger sum), how many of the 261625 possible
//   unordered pairs of non-empty disjoint subsets still need to be tested
//   for Rule 1 (S(B) != S(C))?
//
// Key insight:
//   - Different-size pairs are already covered by Rule 2 (given satisfied).
//   - Only equal-size pairs {B, C} with |B| = |C| = k can possibly have S(B) = S(C).
//   - Among equal-size pairs, a pair does NOT need testing if, when both subsets
//     are sorted ascending, one set dominates the other componentwise
//     (i.e., sorted(B)[i] > sorted(C)[i] for all i, OR sorted(C)[i] > sorted(B)[i]
//     for all i). In that case the strictly-increasing property guarantees S(B) != S(C).
//   - A pair NEEDS testing iff neither dominates (the sequences "cross").
//
// Formula (verified against n=4 and n=7 examples from the problem):
//   For each k = 1 .. 6 (= n/2), contribution = C(12, 2k) * cross(k)
//   where cross(k) = number of "crossing" unordered splits per 2k-element pool:
//     k=1 -> cross=0    (one element each; larger always wins, no test needed)
//     k=2 -> cross=1
//     k=3 -> cross=5
//     k=4 -> cross=21
//     k=5 -> cross=84
//     k=6 -> cross=330
//
// Contributions:
//   k=1:  C(12,2)  *   0 =  66 *   0 =      0
//   k=2:  C(12,4)  *   1 = 495 *   1 =    495
//   k=3:  C(12,6)  *   5 = 924 *   5 =   4620
//   k=4:  C(12,8)  *  21 = 495 *  21 =  10395
//   k=5:  C(12,10) *  84 =  66 *  84 =   5544
//   k=6:  C(12,12) * 330 =   1 * 330 =    330
//   Total = 0 + 495 + 4620 + 10395 + 5544 + 330 = 21384
//
// Verified:  n=4 -> 1  (matches problem statement)
//            n=7 -> 70 (matches problem statement)
//            n=12 -> 21384
//
// TSE SAL rules applied:
//   [1] No integer arrays  - no arrays needed; all values computed arithmetically
//   [2] val and pos not used as own variable names
//   [3] Return() always has parentheses
//   [4] Warn() shows the final answer
//   [5] CopyToWinClip() copies only the bare numeric answer string
//   [6] No paste of the result into any buffer/editor
//   [7] Version number included in file header
//   [8] String variables declared with sufficient size
//   [9] Bitwise infix notation used where applicable
//   [10] 32-bit integers only (all values well within range)

// ---------------------------------------------------------------------------
// Helper: compute C(n, k) - binomial coefficient
// Returns the integer value of n-choose-k for small n, k.
// ---------------------------------------------------------------------------
integer proc BinomCoeff(integer nn, integer kk)
    integer result
    integer ii
    integer jj
    if kk < 0 or kk > nn
        Return(0)
    endif
    if kk == 0 or kk == nn
        Return(1)
    endif
    // Use the smaller of kk and nn-kk for efficiency
    if kk > nn - kk
        kk = nn - kk
    endif
    result = 1
    ii = 1
    while ii <= kk
        jj = nn - kk + ii
        result = result * jj / ii
        ii = ii + 1
    endwhile
    Return(result)
end

// ---------------------------------------------------------------------------
// Helper: count "crossing" unordered equal-size subset pairs per 2k-element pool
// A pair {B, C} with |B|=|C|=k "crosses" iff neither sorted(B) dominates sorted(C)
// nor sorted(C) dominates sorted(B) componentwise.
// These values are precomputed and hardcoded (k=1..6):
// ---------------------------------------------------------------------------
integer proc CrossCount(integer kk)
    integer cv
    cv = 0
    case kk
        when 1  cv = 0
        when 2  cv = 1
        when 3  cv = 5
        when 4  cv = 21
        when 5  cv = 84
        when 6  cv = 330
    endcase
    Return(cv)
end

// ---------------------------------------------------------------------------
// Main procedure
// ---------------------------------------------------------------------------
proc Main()
    integer nn
    integer kk
    integer total_count
    integer contrib
    integer binom_val
    integer cross_val
    string  ans[20]

    nn          = 12
    total_count = 0

    // Sum contributions for each equal-subset size k = 1 .. n/2
    kk = 1
    while kk <= nn / 2
        binom_val  = BinomCoeff(nn, 2 * kk)
        cross_val  = CrossCount(kk)
        contrib    = binom_val * cross_val
        total_count = total_count + contrib
        kk = kk + 1
    endwhile

    // Format the answer as a string
    ans = Str(total_count)

    // Show result in a Warn() box
    Warn("Project Euler #106 answer: " + ans)

    // Copy ONLY the bare numeric answer to the Windows clipboard
    CopyToWinClip(ans)
end
