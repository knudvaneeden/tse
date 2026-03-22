// Project Euler - Problem 159: Digital Root Sums of Factorisations
// Find sum of mdrs(n) for 1 < n < 1,000,000
// where mdrs(n) = maximum Digital Root Sum over all factorisations of n
//
// Algorithm:
//   dr(n)   = digital root of n = 1 + (n-1) mod 9  (for n >= 1)
//             special case: dr(0) = 0
//   mdrs(n) is initialised to dr(n) for all n (the "n itself" factorisation)
//   Sieve: for each n from 2..N-1, for each multiple m = 2n, 3n, ... < N:
//     candidate = dr(n) + mdrs[m/n]
//     if candidate > mdrs[m] then update mdrs[m]
//   Then sum all mdrs(n) for 2 <= n < 1000000
//
// Buffer layout: line (k+1) holds mdrs[k]
//   so line 1 = mdrs[0], line 2 = mdrs[1], ..., line (n+1) = mdrs[n]
//
// Overflow check: answer ~1.25e8 < 2^31 = 2.1e9, fits in one integer.
//
// Fix v2: GotoBufferId(bufMdrsI) added at start of outer sieve loop,
//         and dr(n) computed inline (no proc call) to avoid buffer switch.
//
// <version>1.0.0.0.2</version>
// <history>
//   1.0.0.0.1 - 2026-03-22 - Created by Claude (Anthropic claude-sonnet-4-6)
//   1.0.0.0.2 - 2026-03-22 - Fixed: GotoBufferId missing in sieve loop;
//                             dr(n) now computed inline to avoid buffer switch
// </history>

// ============================================================
// Main
// ============================================================
proc Main()
    integer bufMdrsI     // buffer id: line (n+1) = mdrs[n]
    integer nI           // outer sieve index
    integer mI           // inner: current multiple of nI
    integer limitI       // upper bound (exclusive) = 1000000
    integer drNI         // digital root of nI  (computed inline)
    integer curMdrsI     // current mdrs[m] value
    integer candI        // candidate new mdrs[m] = dr(n) + mdrs[m/n]
    integer mdrsQuotI    // mdrs[m/n]
    integer totalI       // accumulator for the final sum
    string  resultS[40]  // final answer as string
    // //
    limitI = 1000000
    // //
    // --- Phase 1: initialise buffer with dr(n) for n = 0 .. limitI-1 ---
    // CreateTempBuffer() opens a buffer with one empty line.
    // Write dr(0) into that existing line 1,
    // then AddLine() for n = 1 .. limitI-1.
    // Result: line 1 = dr(0)=0, line 2 = dr(1)=1, ..., line (nI+1) = dr(nI)
    // dr(n) inline: if n==0 -> 0, else 1 + (n-1) mod 9
    // //
    Message( "Phase 1: initialising mdrs buffer..." )
    bufMdrsI = CreateTempBuffer()
    GotoBufferId( bufMdrsI )
    BegFile()
    InsertText( "0" )          // line 1 = dr(0) = 0
    nI = 1
    while nI < limitI
        // compute dr(nI) inline
        drNI = 1 + ( ( nI - 1 ) mod 9 )
        AddLine( Str( drNI ) ) // line (nI+1) = dr(nI)
        nI = nI + 1
    endwhile
    // //
    // --- Phase 2: sieve to propagate max DRS ---
    // For each n from 2 upward, for every multiple m = k*n (k>=2, m<limit):
    //   mdrs[m] = max( mdrs[m], dr(n) + mdrs[m/n] )
    // Processing n in increasing order: when we process n, mdrs[m/n] is
    // already final (m/n < m, and m/n was the outer loop value earlier).
    // CRITICAL: GotoBufferId(bufMdrsI) at top of outer loop to stay on buffer.
    // dr(n) computed inline (no external proc call) to avoid buffer switching.
    // //
    Message( "Phase 2: running sieve..." )
    nI = 2
    while nI < limitI
        // ensure we are on the mdrs buffer
        GotoBufferId( bufMdrsI )
        // compute dr(nI) inline - no proc call, no buffer switch
        drNI = 1 + ( ( nI - 1 ) mod 9 )
        // read mdrs[nI] (already in buffer), but we only need dr(nI) for the
        // candidate, not mdrs[nI] - dr(nI) is correct here because when nI
        // is first used as the divisor factor, we want its raw digital root.
        // //
        mI = nI + nI    // first multiple: 2*nI
        while mI < limitI
            // get mdrs[m/n] from line (m/n)+1
            GotoLine( ( mI / nI ) + 1 )
            mdrsQuotI = Val( GetText( 1, CurrLineLen() ) )
            candI = drNI + mdrsQuotI
            // get current mdrs[m] from line m+1
            GotoLine( mI + 1 )
            curMdrsI = Val( GetText( 1, CurrLineLen() ) )
            // update mdrs[m] if candidate is better
            if candI > curMdrsI
                BegLine()
                KillToEol()
                InsertText( Str( candI ) )
            endif
            mI = mI + nI
        endwhile
        nI = nI + 1
    endwhile
    // //
    // --- Phase 3: sum mdrs[n] for n = 2 .. limitI-1 ---
    // //
    Message( "Phase 3: summing results..." )
    GotoBufferId( bufMdrsI )
    totalI = 0
    nI = 2
    while nI < limitI
        GotoLine( nI + 1 )
        totalI = totalI + Val( GetText( 1, CurrLineLen() ) )
        nI = nI + 1
    endwhile
    // //
    resultS = Str( totalI )
    // //
    AbandonFile()
    // //
    CopyToWinClip( resultS )
    Warn( "Project Euler 159 - Digital Root Sums of Factorisations", Chr(13),
          "Sum of mdrs(n) for 1 < n < 1000000", Chr(13),
          "Answer: ", resultS )
    CopyToWinClip( resultS )
end
