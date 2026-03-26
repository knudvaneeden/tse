// Project Euler - Problem 210: Obtuse Angled Triangles
// https://projecteuler.net/problem=210
//
// Consider S(r): integer points (x,y) with |x|+|y| <= r.
// O=(0,0), C=(r/4,r/4). Count points B in S(r) where triangle OBC
// has an obtuse angle (largest angle strictly between 90 and 180 degrees).
// Find N(1,000,000,000).
//
// MATHEMATICAL DERIVATION:
//   q = r/4 = 250,000,000   (integer since r divisible by 4)
//   Q = r/8 = 125,000,000   (integer since r divisible by 8)
//
//   Exclude degenerate cases: B=O, B=C, B on line y=x (collinear with O and C).
//
//   dot_O = q*(x+y):    obtuse at O iff x+y < 0
//   dot_C = -q*(x+y-2q): obtuse at C iff x+y > 2q (= r/2)
//   dot_B = x^2+y^2-q*(x+y): obtuse at B iff x^2+y^2 < q*(x+y)
//   These three regions are mutually exclusive and exhaustive for obtuse triangles.
//
//   C1 = #{x+y<0, in S(r), x<>y} = r^2
//   C2 = #{x+y>r/2, in S(r), x<>y} = r^2/2
//   C3 = L(2Q^2) - (2Q-1)
//     L(2Q^2) = #{(a,b) integers: a^2+b^2 < 2Q^2}  (Gauss circle count)
//     (2Q-1) subtracts the collinear x=y points inside the circle
//
//   N(r) = C1 + C2 + C3
//        = r^2 + r^2/2 + L(2Q^2) - (2Q-1)
//
// L COMPUTATION - 8-fold octant symmetry + walking pointer (O(Q) iterations):
//   Iterate b = 0 .. Q-1.  Maintain a = largest integer >= b with a^2+b^2 < 2Q^2.
//   As b increases, a decreases monotonically -> amortised O(1) per iteration.
//   b=0:  L += 1 + 4*a  (origin plus 4 axis-reflections of (a,0))
//   b>=1: if a>=b: L += 4 + 8*(a-b)  (4 diagonal + 8 off-diagonal reflections)
//
// 64-BIT ARITHMETIC: all values stored as (H, L) with value = H*BASE + L
//   BASE = 1,000,000,000.  L always in [0, BASE-1].  H may exceed BASE.
//   All deltas in the walking loop are < BASE (verified: max delta = 2*a < 2*Q*sqrt(2) < 4e8).
//
// ANSWER: N(1,000,000,000) = 1,598,174,770,174,689,458
//
// Verified with: N(8)=100 (problem statement), N(16)=402, all match brute force.
//
// <version>1.0.0.0.2</version>
// Created by: Claude (Anthropic) - claude-sonnet-4-6
// History:
//   1.0.0.0.1 - 2026-03-26 - Claude (Anthropic) - Initial version, P210 obtuse triangles
//   1.0.0.0.2 - 2026-03-26 - Claude (Anthropic) - Fix: globals moved before helper procs

// ÄÄ Globals ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Must appear before any proc that references them (SAL forward-reference rule).
integer gFHI   = 0    // high word of f = a^2 + b^2  (64-bit, BASE=1e9)
integer gFLI   = 0    // low  word of f
integer gAccHI = 0    // high word of circle count L
integer gAccLI = 0    // low  word of circle count L

// ÄÄ 64-bit delta helpers ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// These operate on globals gFHI / gFLI (the walking f = a^2 + b^2).
// Deltas are always positive and < BASE = 1,000,000,000.

// Add delta to (gFHI, gFLI)
proc Add64DeltaF( integer nDeltaI )
    //
    gFLI = gFLI + nDeltaI
    if gFLI >= 1000000000
        gFLI = gFLI - 1000000000
        gFHI = gFHI + 1
    endif
end

// Subtract delta from (gFHI, gFLI)
proc Sub64DeltaF( integer nDeltaI )
    //
    gFLI = gFLI - nDeltaI
    if gFLI < 0
        gFLI = gFLI + 1000000000
        gFHI = gFHI - 1
    endif
end

// Add 64-bit (nDHI, nDLI) to accumulator (gAccHI, gAccLI)
proc Add64Acc( integer nDHI, integer nDLI )
    //
    gAccLI = gAccLI + nDLI
    if gAccLI >= 1000000000
        gAccLI = gAccLI - 1000000000
        gAccHI = gAccHI + 1
    endif
    gAccHI = gAccHI + nDHI
end

// ÄÄ Main ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
proc Main()
    //
    // ÄÄ Variable declarations ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    integer nQI     = 125000000   // Q = r/8; r = 8*Q = 1,000,000,000
    integer nAI     = 0           // walking pointer: largest a >= b with a^2+b^2 < 2Q^2
    integer nBI     = 0           // b loop counter  (0 .. Q-1)
    integer nDeltaI = 0           // scratch: delta for 64-bit add/sub
    integer nPP     = 0           // nAI / 10000   for square computation
    integer nRR     = 0           // nAI mod 10000 for square computation
    integer nT1HI   = 0           // temp 64-bit pair for nPP^2 * 1e8
    integer nT1LI   = 0
    integer nT2HI   = 0           // temp 64-bit pair for 2*nPP*nRR * 1e4
    integer nT2LI   = 0
    integer nC3HI   = 0           // C3 = L - (2Q-1)
    integer nC3LI   = 0
    integer nNHI    = 0           // N = C1 + C2 + C3  (final answer)
    integer nNLI    = 0
    integer nDLI    = 0           // per-iteration accumulator increment low word
    integer nDHI    = 0           // per-iteration accumulator increment high word
    string  nResultS[30] = ""     // final answer as decimal string

    // ÄÄ Step 1: initialise a_init = floor( Q * sqrt(2) ) = 176,776,695 ÄÄ
    // 2*Q^2 = 31,250,000,000,000,000
    // sqrt(2*Q^2) = Q*sqrt(2) = 176,776,695.296...  so a_init = 176,776,695
    // Confirmed: 176776695^2 = 31,249,999,895,123,025 < 2*Q^2  û
    //            176776696^2 = 31,250,000,248,676,416 > 2*Q^2  û
    nAI = 176776695

    // ÄÄ Step 2: compute fH,fL = a_init^2 in 64-bit ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    // Split: nPP = 17677, nRR = 6695
    // a^2 = nPP^2 * 1e8  +  2*nPP*nRR * 1e4  +  nRR^2
    // All intermediate factors fit in signed 32-bit (verified):
    //   nPP^2        = 312,476,329   < 2^31  û
    //   2*nPP*nRR    = 236,695,030   < 2^31  û
    //   nRR^2        =  44,823,025   < 2^31  û
    nPP   = nAI / 10000             // 17677
    nRR   = nAI mod 10000           // 6695
    //
    // term1 = nPP^2 * 100,000,000  as (nT1HI, nT1LI):
    //   high = nPP^2 / 10
    //   low  = (nPP^2 mod 10) * 100,000,000
    nT1HI = nPP * nPP               // 312,476,329
    nT1LI = (nT1HI mod 10) * 100000000
    nT1HI = nT1HI / 10
    //
    // term2 = 2*nPP*nRR * 10,000  as (nT2HI, nT2LI):
    //   high = (2*nPP*nRR) / 100,000
    //   low  = ((2*nPP*nRR) mod 100,000) * 10,000
    nT2HI = 2 * nPP * nRR          // 236,695,030
    nT2LI = (nT2HI mod 100000) * 10000
    nT2HI = nT2HI / 100000
    //
    // term3 = nRR^2  (< 1e8 < BASE, high=0)
    // Assemble f = term1 + term2 + term3:
    gFLI  = nT1LI + nT2LI + nRR * nRR
    gFHI  = nT1HI + nT2HI
    if gFLI >= 1000000000
        gFLI = gFLI - 1000000000
        gFHI = gFHI + 1
    endif
    // Result: gFHI=31,249,999  gFLI=895,123,025  (verified in Python simulation)

    // ÄÄ Step 3: b = 0 contribution ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    // L = 1 (origin) + 4 * a_init  (axis reflections of (a,0))
    // 4 * 176,776,695 = 707,106,780  < BASE -> fits directly in gAccLI
    gAccHI = 0
    gAccLI = 1 + 4 * nAI           // 707,106,781

    // ÄÄ Step 4: walking pointer loop  b = 1 .. Q ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    // R2 = 2*Q^2 = (31,250,000, 0) in (H, L) BASE=1e9.
    // Invariant: gFHI * 1e9 + gFLI  =  a^2 + b^2  <  R2
    // Comparison f >= R2: gFHI > 31,250,000  OR  gFHI == 31,250,000
    //   (the second case: gFHI==31250000 means f >= 31250000*1e9+0 = R2 since gFLI>=0)
    nBI = 0
    while nBI < nQI
        nBI = nBI + 1
        //
        // f += 2*b - 1  (b is already the new value after increment)
        nDeltaI = 2 * nBI - 1
        Add64DeltaF( nDeltaI )
        //
        // Walk a down until f < R2
        while gFHI > 31250000 or gFHI == 31250000
            nDeltaI = 2 * nAI - 1
            Sub64DeltaF( nDeltaI )
            nAI = nAI - 1
        endwhile
        //
        // Count contribution for this b (if a >= b)
        if nAI >= nBI
            // For a' = b: 4 diagonal reflections
            // For a' = b+1 .. a: 8 reflections each
            // Total: 4 + 8*(a - b)
            nDLI = 4 + 8 * (nAI - nBI)
            nDHI = nDLI / 1000000000   // 0 or 1
            nDLI = nDLI mod 1000000000
            Add64Acc( nDHI, nDLI )
        else
            nBI = nQI               // a < b: no more valid b, force loop exit
        endif
    endwhile

    // ÄÄ Step 5: C3 = L - D  where D = 2Q - 1 = 249,999,999 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    // D counts the x=y points inside the circle (x in [1..q-1], translated to a=b)
    // D = 249,999,999 < BASE -> simple single subtraction from low word
    nC3LI = gAccLI - (2 * nQI - 1)
    nC3HI = gAccHI
    if nC3LI < 0
        nC3LI = nC3LI + 1000000000
        nC3HI = nC3HI - 1
    endif

    // ÄÄ Step 6: N = C1 + C2 + C3 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    // C1 = r^2 = 1e18   -> (H=1,000,000,000, L=0)   [H=BASE is valid as 32-bit int]
    // C2 = r^2/2 = 5e17 -> (H=500,000,000,   L=0)
    // C3 =               -> (nC3HI, nC3LI)
    nNLI = nC3LI                    // C1L + C2L = 0
    nNHI = 1000000000 + 500000000 + nC3HI
    if nNLI >= 1000000000
        nNLI = nNLI - 1000000000
        nNHI = nNHI + 1
    endif
    // nNHI = 1,598,174,770  < 2^31 = 2,147,483,648  û

    // ÄÄ Step 7: format 18-digit result ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    // nNHI * 1e9 + nNLI; zero-pad nNLI to 9 digits
    nResultS = Str( nNHI ) + Format( nNLI:9:"0" )

    // ÄÄ Output ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    CopyToWinClip( nResultS )
    Warn( "Project Euler #210 - Obtuse Angled Triangles" + Chr(13) +
          "N(1,000,000,000) = " + nResultS )
    CopyToWinClip( nResultS )
end
