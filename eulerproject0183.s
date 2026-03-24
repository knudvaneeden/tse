// Project Euler Problem 183 - Maximum Product of Parts
// Find sum of D(N) for N=5..10000, where:
//   M(N) = max over integer k of (N/k)^k
//   D(N) = -N if M(N) is terminating decimal, +N otherwise
// Expected answer: 48861552  (check: sum N=5..100 = 2438)
//
// <version>1.0.0.0.1</version>
// <history>
//   1.0.0.0.1  2026-03-24  Claude (claude-sonnet-4-6) - Initial version
// </history>
//
// Algorithm:
//   Precise ln table via prime factorisation + 13-smooth Machin corrections
//   at scale S = 20,000,000.  Optimal k via reformulated comparison:
//     P(k+1) > P(k)  iff  lnN > ln(k+1) + k * 2*atanh(1/(2k+1))
//   where k*2*atanh(1/(2k+1)) = S10 - S10/(2k+1) + small corrections
//   (S10 = S*10 = 200,000,000 -- fits in 32-bit signed).
//   Terminating check: k/gcd(N,k) has only prime factors 2 and 5.
//
// All intermediate values fit in 32-bit signed integers (verified).
// S = 20,000,000  |  S10 = 200,000,000  |  S100 = 2,000,000,000

// ---- Globals: scale constants ----
integer S    = 20000000
integer S10  = 200000000
// S100 = 2000000000  -- used inline where needed

// ---- Hardcoded ln constants at scale S = 20,000,000 ----
integer LN2  = 13862944
integer LN3  = 21972246
integer LN5  = 32188758
integer LN7  = 38918203
integer LN11 = 47957905
integer LN13 = 51298987

// ---- Buffer IDs (global) ----
integer g_bufLnI     = 0   // ln table:      line (n+1) = Str(ln[n])
integer g_bufSpfI    = 0   // SPF sieve:     line (n+1) = Str(spf[n])
integer g_bufLnPrimI = 0   // ln[prime]:     line (p+1) = Str(ln[p])
integer g_bufSmoothI = 0   // 13-smooth list (sorted, one per line)

// ---- GCD ----
integer proc FnGcdI( integer aI, integer bI )
    integer tI = 0
    while bI <> 0
        tI = aI mod bI
        aI = bI
        bI = tI
    endwhile
    return( aI )
end

// ---- Does n have only factors 2 and 5? ----
integer proc FnOnlyTwoFiveI( integer nI )
    while nI mod 2 == 0
        nI = nI / 2
    endwhile
    while nI mod 5 == 0
        nI = nI / 5
    endwhile
    return( nI == 1 )
end

// ---- Read integer from buffer at line lineI ----
integer proc FnBufGetI( integer bufI, integer lineI )
    integer nVal = 0
    GotoBufferId( bufI )
    GotoLine( lineI )
    nVal = Val( GetText( 1, CurrLineLen() ) )
    return( nVal )
end

// ---- Write integer to buffer at line lineI ----
proc PBufPutI( integer bufI, integer lineI, integer nVal )
    GotoBufferId( bufI )
    GotoLine( lineI )
    BegLine()
    KillToEol()
    InsertText( Str( nVal ) )
end

// ---- Safe: floor(S * num / den) without S*num overflow ----
// Uses: (S//den)*num + ((S mod den)*num)//den  -- exact integer identity
integer proc FnSafeScaleDivI( integer numI, integer denI )
    integer hiI = 0
    integer loI = 0
    hiI = ( S / denI ) * numI
    loI = ( ( S mod denI ) * numI ) / denI
    return( hiI + loI )
end

// ---- S * atanh(num/den) where num/den is a small fraction ----
// Uses term1 always; adds term3 only when den < 188 (larger contribution < 1 unit)
integer proc FnAtanhSafeI( integer numI, integer denI )
    integer resultI = 0
    integer den3I   = 0
    integer num3I   = 0
    resultI = FnSafeScaleDivI( numI, denI )
    if denI < 188
        den3I   = denI * denI * denI   // safe: den < 188, den^3 < 6.6M < 2^31
        num3I   = numI * numI * numI   // safe: max num=43, num^3=79507 < 2^31
        resultI = resultI + ( S / ( 3 * den3I ) ) * num3I
    endif
    return( resultI )
end

// ---- Compute ln(m) for 13-smooth m (factors only 2,3,5,7,11,13) ----
integer proc FnLn13SmoothI( integer mI )
    integer rI = 0
    while mI mod 2 == 0
        mI = mI / 2
        rI = rI + LN2
    endwhile
    while mI mod 3 == 0
        mI = mI / 3
        rI = rI + LN3
    endwhile
    while mI mod 5 == 0
        mI = mI / 5
        rI = rI + LN5
    endwhile
    while mI mod 7 == 0
        mI = mI / 7
        rI = rI + LN7
    endwhile
    while mI mod 11 == 0
        mI = mI / 11
        rI = rI + LN11
    endwhile
    while mI mod 13 == 0
        mI = mI / 13
        rI = rI + LN13
    endwhile
    return( rI )
end

// ---- Generate all 13-smooth numbers <= 20001 into g_bufSmoothI ----
proc PBuildSmoothBuf()
    integer v2I  = 0
    integer v3I  = 0
    integer v5I  = 0
    integer v7I  = 0
    integer v11I = 0
    integer v13I = 0
    GotoBufferId( g_bufSmoothI )
    EmptyBuffer()
    v2I = 1
    while v2I <= 20001
        v3I = v2I
        while v3I <= 20001
            v5I = v3I
            while v5I <= 20001
                v7I = v5I
                while v7I <= 20001
                    v11I = v7I
                    while v11I <= 20001
                        v13I = v11I
                        while v13I <= 20001
                            AddLine( Str( v13I ) )
                            v13I = v13I * 13
                        endwhile
                        v11I = v11I * 11
                    endwhile
                    v7I = v7I * 7
                endwhile
                v5I = v5I * 5
            endwhile
            v3I = v3I * 3
        endwhile
        v2I = v2I * 2
    endwhile
    // Sort and deduplicate
    BegFile()
    MarkLine()
    EndFile()
    ExecMacro( "sort -k" )
    UnMarkBlock()
end

// ---- Find nearest 13-smooth number to pI (full linear scan of g_bufSmoothI) ----
// Note: TSE sort is lexicographic, so we cannot use an early-exit on value size.
// We scan all ~985 entries; this is fast enough.
integer proc FnNearestSmoothI( integer pI )
    integer bestI     = 1
    integer bestDistI = 0
    integer curValI   = 0
    integer curDistI  = 0
    integer nLinesI   = 0
    integer iI        = 0
    bestDistI = pI - 1
    GotoBufferId( g_bufSmoothI )
    nLinesI = NumLines()
    iI = 1
    while iI <= nLinesI
        GotoLine( iI )
        curValI = Val( GetText( 1, CurrLineLen() ) )
        if curValI >= 1 AND curValI <= 2 * pI      // skip 0 (empty lines); skip overly large
            curDistI = curValI - pI
            if curDistI < 0
                curDistI = pI - curValI
            endif
            if curDistI < bestDistI
                bestDistI = curDistI
                bestI     = curValI
            endif
        endif
        iI = iI + 1
    endwhile
    return( bestI )
end

// ---- Build Smallest Prime Factor (SPF) sieve for 0..10000 in g_bufSpfI ----
// Line (n+1) = spf[n]
proc PBuildSpf()
    integer iI = 0
    integer jI = 0
    GotoBufferId( g_bufSpfI )
    EmptyBuffer()
    iI = 0
    while iI <= 10000
        AddLine( Str( iI ) )      // spf[i] = i initially
        iI = iI + 1
    endwhile
    iI = 2
    while iI <= 100
        if FnBufGetI( g_bufSpfI, iI + 1 ) == iI    // iI is prime
            jI = iI * iI
            while jI <= 10000
                if FnBufGetI( g_bufSpfI, jI + 1 ) == jI
                    PBufPutI( g_bufSpfI, jI + 1, iI )
                endif
                jI = jI + iI
            endwhile
        endif
        iI = iI + 1
    endwhile
end

// ---- Build ln[prime] for all primes 2..10000 into g_bufLnPrimI ----
// Line (p+1) = ln[p]
proc PBuildLnPrimes()
    integer pI    = 0
    integer mI    = 0
    integer numI  = 0
    integer denI  = 0
    integer lnMI  = 0
    integer corrI = 0
    integer lnPI  = 0
    integer iI    = 0
    // Initialise to zero
    GotoBufferId( g_bufLnPrimI )
    EmptyBuffer()
    iI = 0
    while iI <= 10000
        AddLine( "0" )
        iI = iI + 1
    endwhile
    // Hardcode base primes
    PBufPutI( g_bufLnPrimI,  2 + 1, LN2  )
    PBufPutI( g_bufLnPrimI,  3 + 1, LN3  )
    PBufPutI( g_bufLnPrimI,  5 + 1, LN5  )
    PBufPutI( g_bufLnPrimI,  7 + 1, LN7  )
    PBufPutI( g_bufLnPrimI, 11 + 1, LN11 )
    PBufPutI( g_bufLnPrimI, 13 + 1, LN13 )
    // For all primes p = 17..10000: use nearest 13-smooth + atanh correction
    pI = 17
    while pI <= 10000
        if FnBufGetI( g_bufSpfI, pI + 1 ) == pI    // pI is prime
            mI   = FnNearestSmoothI( pI )
            lnMI = FnLn13SmoothI( mI )
            if pI > mI
                numI = pI - mI
            else
                numI = mI - pI
            endif
            denI  = pI + mI
            corrI = 2 * FnAtanhSafeI( numI, denI )
            if pI > mI
                lnPI = lnMI + corrI
            else
                lnPI = lnMI - corrI
            endif
            PBufPutI( g_bufLnPrimI, pI + 1, lnPI )
        endif
        pI = pI + 1
    endwhile
end

// ---- Build full ln table (n=0..10000) in g_bufLnI ----
// Factorises each n using SPF and sums ln(prime factors)
proc PBuildLnTable()
    integer nI   = 0
    integer mI   = 0
    integer pI   = 0
    integer lnNI = 0
    GotoBufferId( g_bufLnI )
    EmptyBuffer()
    nI = 0
    while nI <= 10000
        AddLine( "0" )
        nI = nI + 1
    endwhile
    nI = 2
    while nI <= 10000
        mI   = nI
        lnNI = 0
        while mI > 1
            pI = FnBufGetI( g_bufSpfI, mI + 1 )
            while mI mod pI == 0
                mI   = mI / pI
                lnNI = lnNI + FnBufGetI( g_bufLnPrimI, pI + 1 )
            endwhile
        endwhile
        PBufPutI( g_bufLnI, nI + 1, lnNI )
        nI = nI + 1
    endwhile
end

// ---- Compute S * k * 2*atanh(1/(2k+1)) (overflow-safe) ----
// Reformulation: S*2k/(2k+1) = S10 - S10/(2k+1)
// S10 = 200,000,000 fits in 32-bit; S10/(2k+1) is small positive.
// Term3,5,7 only applied for small k where they contribute >= 1 unit.
integer proc FnKTimes2AtanhI( integer kI )
    integer xI      = 0
    integer resultI = 0
    integer x3I     = 0
    integer x5I     = 0
    integer x7I     = 0
    xI      = 2 * kI + 1
    resultI = S10 - S10 / xI                          // term1 (exact up to /10 rounding)
    if kI < 100                                        // term3 contributes >= 1 unit for k<100
        x3I     = xI * xI * xI                        // x^3 <= 201^3 = 8.1M < 2^31
        resultI = resultI + ( S10 / ( 3 * x3I ) ) * 2 * kI
    endif
    if kI < 8                                          // term5 for k < 8  (x <= 15)
        x5I     = xI * xI * xI * xI * xI
        resultI = resultI + ( S10 / ( 5 * x5I ) ) * 2 * kI
    endif
    if kI <= 3                                         // term7 for k <= 3 (x <= 7)
        x7I     = xI * xI * xI * xI * xI * xI * xI
        resultI = resultI + ( S10 / ( 7 * x7I ) ) * 2 * kI
    endif
    return( ( resultI + 5 ) / 10 )
end

// ---- Find the optimal k for N (maximises (N/k)^k) ----
// Scans window k_approx-3 .. k_approx+3 using reformulated comparison.
integer proc FnOptimalKI( integer nI )
    integer kApproxI = 0
    integer loI      = 0
    integer hiI      = 0
    integer bestKI   = 0
    integer lnNI     = 0
    integer rhsI     = 0
    integer kI       = 0
    kApproxI = ( nI * 1000 + 1359 ) / 2718   // integer approximation of floor(N/e)
    loI      = kApproxI - 3
    if loI < 1
        loI = 1
    endif
    hiI = kApproxI + 3
    if hiI > nI - 1
        hiI = nI - 1
    endif
    bestKI = loI
    lnNI   = FnBufGetI( g_bufLnI, nI + 1 )
    kI     = loI
    while kI <= hiI
        if kI + 1 > nI
            kI = hiI + 1             // break
        else
            // P(k+1) > P(k) iff lnN > ln(k+1) + k*2*atanh(1/(2k+1))
            rhsI = FnBufGetI( g_bufLnI, kI + 1 + 1 ) + FnKTimes2AtanhI( kI )
            if lnNI > rhsI
                bestKI = kI + 1
                kI     = kI + 1
            else
                kI = hiI + 1         // unimodal: break on first non-increase
            endif
        endif
    endwhile
    if bestKI < 1
        bestKI = 1
    endif
    return( bestKI )
end

// ---- Main entry point ----
proc Main()
    integer totalI  = 0
    integer nI      = 0
    integer kI      = 0
    integer gcdI    = 0
    integer dI      = 0
    string  answerS[30] = ""

    // Allocate working buffers
    g_bufLnI     = CreateTempBuffer()
    g_bufSpfI    = CreateTempBuffer()
    g_bufLnPrimI = CreateTempBuffer()
    g_bufSmoothI = CreateTempBuffer()

    // Build data structures
    PBuildSmoothBuf()    // 13-smooth list (sorted)
    PBuildSpf()          // SPF sieve
    PBuildLnPrimes()     // ln[prime] for all primes 2..10000
    PBuildLnTable()      // ln[n] for n=2..10000

    // Main computation: sum D(N) for N = 5..10000
    totalI = 0
    nI     = 5
    while nI <= 10000
        kI   = FnOptimalKI( nI )
        gcdI = FnGcdI( nI, kI )
        dI   = kI / gcdI
        // Terminating iff k/gcd has only factors 2 and 5
        if FnOnlyTwoFiveI( dI )
            totalI = totalI - nI    // D(N) = -N  (terminating)
        else
            totalI = totalI + nI    // D(N) = +N  (non-terminating)
        endif
        nI = nI + 1
    endwhile

    // Output result
    answerS = Str( totalI )
    CopyToWinClip( answerS )
    Warn( "P183 Sum D(N) for N=5..10000:" + Chr(13) + answerS )
    CopyToWinClip( answerS )

    // Clean up temp buffers
    AbandonFile( g_bufLnI     )
    AbandonFile( g_bufSpfI    )
    AbandonFile( g_bufLnPrimI )
    AbandonFile( g_bufSmoothI )
end
