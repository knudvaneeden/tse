// ============================================================
// Project Euler Problem 146
// "Investigating a Prime Pattern"
//
// Find all n < 150,000,000 where n^2+1, n^2+3, n^2+7,
// n^2+9, n^2+13, n^2+27 are consecutive primes. Sum them.
//
// Answer: 676333270
//
// <version>1.0.0.0.2</version>
// <created_by>Claude Sonnet 4.6 (Anthropic)</created_by>
// <date>2026-03-20</date>
//
// ---- ALGORITHM ----
// n^2+k can reach ~2.25e16 (55-bit numbers) -- beyond SAL's 32-bit signed
// limit (~2.1e9). Two phases are used for primality:
//
// PHASE 1 - Trial division pre-filter (fast, pure 32-bit):
//   Build a precomputed buffer at startup: for each prime p in [11..9999]
//   (1225 primes), store the set of "bad residues" r where r^2+k ð 0 (mod p)
//   for some REQUIRED k in {1,3,7,9,13,27} AND r^2+k != p.
//   (The r^2+k == p exclusion prevents falsely rejecting n when n^2+k IS p itself.)
//   At runtime: compute r = n mod p (pure 32-bit). If r is in the bad set,
//   n^2+k is composite for some required k => skip n immediately.
//   This rejects ~99.97% of candidates using only 32-bit arithmetic.
//   Average ~4 primes checked per candidate before rejection.
//   Primes 2,3,5,7 are unused: the mod-210 filter already guarantees none of
//   those produce bad required residues for our candidates.
//
// PHASE 2 - Miller-Rabin (only for the ~0.03% surviving Phase 1):
//   Represents large integers as (hi, lo) pairs in BASE = 2^30 = 1,073,741,824.
//   value = hi * 2^30 + lo. All intermediate values fit in SAL 32-bit signed.
//   mulmod uses binary (Russian-peasant) method; powmod uses square-and-multiply.
//   9 witnesses {2,3,5,7,11,13,17,19,23} are DETERMINISTIC for n < 3.825e18.
//   Our max n^2+27 < 2.25e16 < 3.825e18.
//
// ---- CANDIDATE FILTER (mod 210) ----
//   Valid residues mod 210 = LCM(10,3,7): {10, 80, 130, 200} -- ~52x speedup.
//
// ---- CONSECUTIVE PRIME CHECK ----
//   Required prime offsets:            1, 3, 7, 9, 13, 27
//   Forbidden odd offsets (composite): 5, 11, 15, 17, 19, 21, 23, 25
//   Even offsets: n^2 is even (n div 10) => n^2+even is even > 2 => composite.
//
// ---- BAD RESIDUE BUFFER LAYOUT ----
//   gBadBufI has NUM_PRIMES * ENTRY_SIZE lines (ENTRY_SIZE = 14).
//   For prime index i (1-based), entry starts at line (i-1)*ENTRY_SIZE + 1:
//     Line +0:  prime p
//     Line +1:  count of bad residues c (0..12)
//     Lines +2..+13: bad residues (padded with -1 for unused slots)
//   A residue r is "bad" if r^2+k ð 0 (mod p) for some required k
//   AND r^2+k != p (to avoid false rejection when p IS n^2+k).
//
// ---- PERFORMANCE ----
//   Phase 1 startup (precompute bad residues): ~3-5 minutes.
//   Phase 1 main loop (~2.86M candidates, avg 4 prime checks each): ~12 min.
//   Phase 2 Miller-Rabin (~1400 survivors, avg ~6 MR calls): ~45-90 min.
//   Total estimated runtime: 1 to 1.5 hours.
//   The program terminates -- no infinite loops.
// ============================================================

constant BASE30     = 1073741824    // 2^30
constant BASE30MSK  = 1073741823    // 2^30 - 1  (bitmask)
constant LIMIT      = 150000000     // search n in [1, LIMIT)
constant ENTRY_SIZE = 14            // lines per prime entry: 1(p)+1(cnt)+12(residues)
constant NUM_PRIMES = 1225          // count of primes in [11..9999]

integer gBadBufI   = 0   // buffer storing precomputed bad residue data
integer gSumI      = 0   // running sum of qualifying n
integer gCountI    = 0   // count of qualifying n

// ============================================================
// hi/lo COMPARISON
// Returns 1 if a > b, -1 if a < b, 0 if equal.
// ============================================================
integer proc FNCmpI( integer aHI, integer aLI,
                      integer bHI, integer bLI )
    // //
    if aHI > bHI   return(  1 )  endif
    if aHI < bHI   return( -1 )  endif
    if aLI > bLI   return(  1 )  endif
    if aLI < bLI   return( -1 )  endif
    return( 0 )
end

// ============================================================
// ProcMulMod
// Computes (aHI:aLI * bHI:bLI) mod (mHI:mLI), result in (rHI, rLI).
// Binary (Russian-peasant) method on BASE=2^30 hi/lo pairs.
// Reduction inlined (no sub-proc call) for speed.
// ============================================================
proc ProcMulMod( integer aHI,    integer aLI,
                  integer bHI,    integer bLI,
                  integer mHI,    integer mLI,
                  var integer rHI, var integer rLI )
    integer resHI  = 0
    integer resLI  = 0
    integer curAHI = 0
    integer curALI = 0
    integer curBHI = 0
    integer curBLI = 0
    integer sHI    = 0
    integer sLI    = 0
    integer carI   = 0
    integer dLI    = 0
    integer borI   = 0
    // //
    resHI  = 0
    resLI  = 0
    curAHI = aHI
    curALI = aLI
    curBHI = bHI
    curBLI = bLI
    while ( curBHI > 0 ) or ( curBLI > 0 )
        if ( curBLI & 1 ) == 1
            // res = (res + curA) mod m  -- inline reduce
            sLI  = resLI + curALI
            carI = sLI shr 30
            sLI  = sLI & BASE30MSK
            sHI  = resHI + curAHI + carI
            if sHI > mHI
                borI  = 0
                dLI   = sLI - mLI
                if dLI < 0   dLI = dLI + BASE30   borI = 1   endif
                resLI = dLI
                resHI = sHI - mHI - borI
            elseif sHI == mHI
                if sLI >= mLI
                    resLI = sLI - mLI
                    resHI = 0
                else
                    resHI = sHI
                    resLI = sLI
                endif
            else
                resHI = sHI
                resLI = sLI
            endif
        endif
        // curA = (2 * curA) mod m  -- inline reduce
        sLI  = curALI shl 1
        carI = sLI shr 30
        sLI  = sLI & BASE30MSK
        sHI  = ( curAHI shl 1 ) + carI
        if sHI > mHI
            borI   = 0
            dLI    = sLI - mLI
            if dLI < 0   dLI = dLI + BASE30   borI = 1   endif
            curALI = dLI
            curAHI = sHI - mHI - borI
        elseif sHI == mHI
            if sLI >= mLI
                curALI = sLI - mLI
                curAHI = 0
            else
                curAHI = sHI
                curALI = sLI
            endif
        else
            curAHI = sHI
            curALI = sLI
        endif
        // b >>= 1 in BASE=2^30
        curBLI = ( curBLI shr 1 ) | ( ( curBHI & 1 ) shl 29 )
        curBHI = curBHI shr 1
    endwhile
    rHI = resHI
    rLI = resLI
end

// ============================================================
// ProcPowMod
// Computes (baseHI:baseLI ^ expHI:expLI) mod (mHI:mLI).
// Square-and-multiply. Result in (rHI, rLI).
// ============================================================
proc ProcPowMod( integer baseHI,   integer baseLI,
                  integer expHI,    integer expLI,
                  integer mHI,      integer mLI,
                  var integer rHI,   var integer rLI )
    integer resHI  = 0
    integer resLI  = 1
    integer curBHI = 0
    integer curBLI = 0
    integer curEHI = 0
    integer curELI = 0
    integer tHI    = 0
    integer tLI    = 0
    integer borI   = 0
    integer dLI    = 0
    // //
    resHI  = 0
    resLI  = 1
    curBHI = baseHI
    curBLI = baseLI
    curEHI = expHI
    curELI = expLI
    // Reduce base mod m (inline one-step reduction: base assumed < 2*m)
    if FNCmpI( curBHI, curBLI, mHI, mLI ) >= 0
        borI   = 0
        dLI    = curBLI - mLI
        if dLI < 0   dLI = dLI + BASE30   borI = 1   endif
        curBLI = dLI
        curBHI = curBHI - mHI - borI
    endif
    while ( curEHI > 0 ) or ( curELI > 0 )
        if ( curELI & 1 ) == 1
            ProcMulMod( resHI, resLI, curBHI, curBLI, mHI, mLI, tHI, tLI )
            resHI = tHI
            resLI = tLI
        endif
        ProcMulMod( curBHI, curBLI, curBHI, curBLI, mHI, mLI, tHI, tLI )
        curBHI = tHI
        curBLI = tLI
        curELI = ( curELI shr 1 ) | ( ( curEHI & 1 ) shl 29 )
        curEHI = curEHI shr 1
    endwhile
    rHI = resHI
    rLI = resLI
end

// ============================================================
// ProcSquareToHiLo
// Computes n^2 in BASE=2^30 hi/lo. n < 150,000,000 < 2^28.
// Split n = na*2^14 + nb to stay within 32-bit signed arithmetic:
//   n^2 = na^2 * 2^28 + 2*na*nb * 2^14 + nb^2
// All partials fit comfortably in SAL 32-bit.
// ============================================================
proc ProcSquareToHiLo( integer nI,
                         var integer hI, var integer lI )
    integer naI  = 0
    integer nbI  = 0
    integer aaI  = 0
    integer ab2I = 0
    integer bbI  = 0
    integer tHI  = 0
    integer tLI  = 0
    integer carI = 0
    // //
    naI  = nI shr 14
    nbI  = nI & 16383
    aaI  = naI * naI
    ab2I = 2 * naI * nbI
    bbI  = nbI * nbI
    tHI  = 0
    tLI  = bbI
    carI = ab2I shr 16
    tLI  = tLI + ( ( ab2I & 65535 ) shl 14 )
    tHI  = tHI + carI + ( tLI shr 30 )
    tLI  = tLI & BASE30MSK
    carI = aaI shr 2
    tLI  = tLI + ( ( aaI & 3 ) shl 28 )
    tHI  = tHI + carI + ( tLI shr 30 )
    tLI  = tLI & BASE30MSK
    hI   = tHI
    lI   = tLI
end

// ============================================================
// FNMRCompositeI
// One Miller-Rabin witness test. Returns TRUE (1) if n is
// DEFINITELY composite, FALSE (0) if possibly prime.
// n-1 = d * 2^rI. Witness is small integer aI (2..23).
// ============================================================
integer proc FNMRCompositeI( integer nHI,  integer nLI,
                               integer dHI,  integer dLI,
                               integer rI,
                               integer aI )
    integer xHI    = 0
    integer xLI    = 0
    integer nm1HI  = 0
    integer nm1LI  = 0
    integer tHI    = 0
    integer tLI    = 0
    integer iI     = 0
    integer borI   = 0
    // //
    ProcPowMod( 0, aI, dHI, dLI, nHI, nLI, xHI, xLI )
    nm1LI = nLI - 1
    borI  = 0
    if nm1LI < 0   nm1LI = nm1LI + BASE30   borI = 1   endif
    nm1HI = nHI - borI
    if ( xHI == 0 ) and ( xLI == 1 )
        return( 0 )
    endif
    if ( xHI == nm1HI ) and ( xLI == nm1LI )
        return( 0 )
    endif
    iI = 1
    while iI < rI
        ProcMulMod( xHI, xLI, xHI, xLI, nHI, nLI, tHI, tLI )
        xHI = tHI
        xLI = tLI
        if ( xHI == nm1HI ) and ( xLI == nm1LI )
            return( 0 )
        endif
        iI = iI + 1
    endwhile
    return( 1 )   // composite
end

// ============================================================
// FNIsPrimeHiLoI
// Deterministic Miller-Rabin. 9 witnesses {2,3,5,7,11,13,17,19,23}
// cover all n < 3.825e18 > our max 2.25e16.
// Returns TRUE (1) if prime, FALSE (0) if composite.
// ============================================================
integer proc FNIsPrimeHiLoI( integer nHI, integer nLI )
    integer dHI   = 0
    integer dLI   = 0
    integer rI    = 0
    integer nm1HI = 0
    integer nm1LI = 0
    integer borI  = 0
    // //
    if nHI == 0
        if nLI < 2              return( 0 )  endif
        if nLI == 2             return( 1 )  endif
        if nLI == 3             return( 1 )  endif
        if ( nLI & 1 ) == 0    return( 0 )  endif
        if ( nLI mod 3 ) == 0  return( 0 )  endif
    endif
    nm1LI = nLI - 1
    borI  = 0
    if nm1LI < 0   nm1LI = nm1LI + BASE30   borI = 1   endif
    nm1HI = nHI - borI
    dHI   = nm1HI
    dLI   = nm1LI
    rI    = 0
    while ( dLI & 1 ) == 0
        dLI = ( dLI shr 1 ) | ( ( dHI & 1 ) shl 29 )
        dHI = dHI shr 1
        rI  = rI + 1
    endwhile
    if FNMRCompositeI( nHI, nLI, dHI, dLI, rI,  2 )  return( 0 )  endif
    if FNMRCompositeI( nHI, nLI, dHI, dLI, rI,  3 )  return( 0 )  endif
    if FNMRCompositeI( nHI, nLI, dHI, dLI, rI,  5 )  return( 0 )  endif
    if FNMRCompositeI( nHI, nLI, dHI, dLI, rI,  7 )  return( 0 )  endif
    if FNMRCompositeI( nHI, nLI, dHI, dLI, rI, 11 )  return( 0 )  endif
    if FNMRCompositeI( nHI, nLI, dHI, dLI, rI, 13 )  return( 0 )  endif
    if FNMRCompositeI( nHI, nLI, dHI, dLI, rI, 17 )  return( 0 )  endif
    if FNMRCompositeI( nHI, nLI, dHI, dLI, rI, 19 )  return( 0 )  endif
    if FNMRCompositeI( nHI, nLI, dHI, dLI, rI, 23 )  return( 0 )  endif
    return( 1 )
end

// ============================================================
// FNNSqPlusKPrimeI
// Returns TRUE if n^2 + kI is prime (uses hi/lo Miller-Rabin).
// ============================================================
integer proc FNNSqPlusKPrimeI( integer nI, integer kI )
    integer hI   = 0
    integer lI   = 0
    integer carI = 0
    // //
    ProcSquareToHiLo( nI, hI, lI )
    lI   = lI + kI
    carI = lI shr 30
    lI   = lI & BASE30MSK
    hI   = hI + carI
    return( FNIsPrimeHiLoI( hI, lI ) )
end

// ============================================================
// ProcBuildBadBuf
// Precomputes bad residues for each prime p in [11..9999].
// Fills gBadBufI: ENTRY_SIZE lines per prime:
//   Line (i-1)*ENTRY_SIZE+1 : prime p
//   Line (i-1)*ENTRY_SIZE+2 : count of bad residues
//   Lines +2..+13            : bad residues (padded with -1)
//
// Residue r is "bad" if:
//   r^2+k ð 0 (mod p) for some required k in {1,3,7,9,13,27}
//   AND r^2+k != p  (exclude: p divides n^2+k only because p==n^2+k,
//                    which means n^2+k IS prime -- not composite!)
//
// All arithmetic is pure 32-bit (r < p < 10000, r^2 < 10^8 < 2^31-1).
// ============================================================
proc ProcBuildBadBuf()
    integer pI      = 0
    integer rI      = 0
    integer r2I     = 0
    integer kI      = 0
    integer cntI    = 0
    integer isBadI  = 0
    integer isPrimI = 0
    integer jI      = 0
    integer iiI     = 0
    integer savedI  = 0
    // //
    savedI = GetBufferId()
    GotoBufferId( gBadBufI )
    EmptyBuffer()

    pI = 11
    while pI < 10000
        // Check primality of pI by trial division
        isPrimI = 1
        iiI     = 2
        while ( iiI * iiI ) <= pI
            if ( pI mod iiI ) == 0
                isPrimI = 0
                iiI     = pI   // exit loop
            endif
            iiI = iiI + 1
        endwhile

        if isPrimI == 1
            // Count bad residues first (needed for count line)
            cntI = 0
            rI   = 0
            while rI < pI
                r2I    = ( rI * rI ) mod pI
                isBadI = 0
                // Check each required offset; exclude r^2+k == p
                if ( ( r2I + 1  ) mod pI ) == 0
                    if ( rI * rI + 1  ) <> pI   isBadI = 1   endif
                endif
                if ( ( r2I + 3  ) mod pI ) == 0
                    if ( rI * rI + 3  ) <> pI   isBadI = 1   endif
                endif
                if ( ( r2I + 7  ) mod pI ) == 0
                    if ( rI * rI + 7  ) <> pI   isBadI = 1   endif
                endif
                if ( ( r2I + 9  ) mod pI ) == 0
                    if ( rI * rI + 9  ) <> pI   isBadI = 1   endif
                endif
                if ( ( r2I + 13 ) mod pI ) == 0
                    if ( rI * rI + 13 ) <> pI   isBadI = 1   endif
                endif
                if ( ( r2I + 27 ) mod pI ) == 0
                    if ( rI * rI + 27 ) <> pI   isBadI = 1   endif
                endif
                if isBadI == 1
                    cntI = cntI + 1
                endif
                rI = rI + 1
            endwhile

            // Write ENTRY_SIZE lines for this prime
            AddLine( Str( pI   ) )   // line 1: prime
            AddLine( Str( cntI ) )   // line 2: count
            // Lines 3..14: up to 12 bad residues, padded with -1
            rI = 0
            jI = 0
            while rI < pI
                r2I    = ( rI * rI ) mod pI
                isBadI = 0
                if ( ( r2I + 1  ) mod pI ) == 0
                    if ( rI * rI + 1  ) <> pI   isBadI = 1   endif
                endif
                if ( ( r2I + 3  ) mod pI ) == 0
                    if ( rI * rI + 3  ) <> pI   isBadI = 1   endif
                endif
                if ( ( r2I + 7  ) mod pI ) == 0
                    if ( rI * rI + 7  ) <> pI   isBadI = 1   endif
                endif
                if ( ( r2I + 9  ) mod pI ) == 0
                    if ( rI * rI + 9  ) <> pI   isBadI = 1   endif
                endif
                if ( ( r2I + 13 ) mod pI ) == 0
                    if ( rI * rI + 13 ) <> pI   isBadI = 1   endif
                endif
                if ( ( r2I + 27 ) mod pI ) == 0
                    if ( rI * rI + 27 ) <> pI   isBadI = 1   endif
                endif
                if isBadI == 1
                    AddLine( Str( rI ) )
                    jI = jI + 1
                endif
                rI = rI + 1
            endwhile
            // Pad to exactly 12 residue slots
            while jI < 12
                AddLine( "-1" )
                jI = jI + 1
            endwhile
        endif
        pI = pI + 1
    endwhile

    GotoBufferId( savedI )
end

// ============================================================
// FNPassesTrialDivI
// Phase 1 pre-filter. Checks n against all precomputed bad residues.
// Returns TRUE (1) if n passes (no required offset provably composite).
// Returns FALSE (0) if n^2+k is divisible by some small prime p for
// some required k, proving it composite.
// ============================================================
integer proc FNPassesTrialDivI( integer nI )
    integer idxI   = 0
    integer entI   = 0
    integer pI     = 0
    integer cntI   = 0
    integer rI     = 0
    integer jI     = 0
    integer badRI  = 0
    integer savedI = 0
    // //
    savedI = GetBufferId()
    GotoBufferId( gBadBufI )
    idxI = 1
    while idxI <= NUM_PRIMES
        entI = ( idxI - 1 ) * ENTRY_SIZE + 1
        GotoLine( entI )
        pI   = Val( GetText( 1, CurrLineLen() ) )
        GotoLine( entI + 1 )
        cntI = Val( GetText( 1, CurrLineLen() ) )
        if cntI > 0
            rI = nI mod pI
            jI = 0
            while jI < cntI
                GotoLine( entI + 2 + jI )
                badRI = Val( GetText( 1, CurrLineLen() ) )
                if rI == badRI
                    GotoBufferId( savedI )
                    return( 0 )
                endif
                jI = jI + 1
            endwhile
        endif
        idxI = idxI + 1
    endwhile
    GotoBufferId( savedI )
    return( 1 )
end

// ============================================================
// FNQualifiesI
// Full check for n that passed Phase 1. Uses Miller-Rabin (hi/lo).
// Tests required offsets for primality and forbidden for compositeness.
// ============================================================
integer proc FNQualifiesI( integer nI )
    // //
    // Required offsets must all be prime
    if FNNSqPlusKPrimeI( nI,  1 ) == 0  return( 0 )  endif
    if FNNSqPlusKPrimeI( nI,  3 ) == 0  return( 0 )  endif
    if FNNSqPlusKPrimeI( nI,  7 ) == 0  return( 0 )  endif
    if FNNSqPlusKPrimeI( nI,  9 ) == 0  return( 0 )  endif
    if FNNSqPlusKPrimeI( nI, 13 ) == 0  return( 0 )  endif
    if FNNSqPlusKPrimeI( nI, 27 ) == 0  return( 0 )  endif
    // Forbidden odd offsets must NOT be prime
    // (Even offsets are automatically composite: n^2 even, n^2+even even > 2)
    if FNNSqPlusKPrimeI( nI,  5 ) == 1  return( 0 )  endif
    if FNNSqPlusKPrimeI( nI, 11 ) == 1  return( 0 )  endif
    if FNNSqPlusKPrimeI( nI, 15 ) == 1  return( 0 )  endif
    if FNNSqPlusKPrimeI( nI, 17 ) == 1  return( 0 )  endif
    if FNNSqPlusKPrimeI( nI, 19 ) == 1  return( 0 )  endif
    if FNNSqPlusKPrimeI( nI, 21 ) == 1  return( 0 )  endif
    if FNNSqPlusKPrimeI( nI, 23 ) == 1  return( 0 )  endif
    if FNNSqPlusKPrimeI( nI, 25 ) == 1  return( 0 )  endif
    return( 1 )
end

// ============================================================
// Main
// ============================================================
proc Main()
    integer nI       = 0
    integer baseI    = 0
    string  resS[30] = ""
    // //
    gSumI   = 0
    gCountI = 0

    // Create and populate the bad-residue buffer
    gBadBufI = CreateTempBuffer()
    if gBadBufI == 0
        Warn( "ERROR: could not create temp buffer for prime data." )
        return()
    endif
    ProcBuildBadBuf()

    // Main candidate loop.
    // Valid residues mod 210: {10, 80, 130, 200}
    baseI = 0
    while baseI < LIMIT
        nI = baseI + 10
        if ( nI > 0 ) and ( nI < LIMIT )
            if FNPassesTrialDivI( nI )
                if FNQualifiesI( nI )
                    gSumI   = gSumI + nI
                    gCountI = gCountI + 1
                endif
            endif
        endif
        nI = baseI + 80
        if ( nI > 0 ) and ( nI < LIMIT )
            if FNPassesTrialDivI( nI )
                if FNQualifiesI( nI )
                    gSumI   = gSumI + nI
                    gCountI = gCountI + 1
                endif
            endif
        endif
        nI = baseI + 130
        if ( nI > 0 ) and ( nI < LIMIT )
            if FNPassesTrialDivI( nI )
                if FNQualifiesI( nI )
                    gSumI   = gSumI + nI
                    gCountI = gCountI + 1
                endif
            endif
        endif
        nI = baseI + 200
        if ( nI > 0 ) and ( nI < LIMIT )
            if FNPassesTrialDivI( nI )
                if FNQualifiesI( nI )
                    gSumI   = gSumI + nI
                    gCountI = gCountI + 1
                endif
            endif
        endif
        baseI = baseI + 210
    endwhile

    AbandonFile( gBadBufI )

    resS = Str( gSumI )
    CopyToWinClip( resS )
    Warn( "Project Euler 146 - Consecutive Prime Pattern",       Chr(13),
          "Sum of qualifying n < 150,000,000:",                   Chr(13),
          "Answer = ", resS,                                       Chr(13),
          "(", Str( gCountI ), " qualifying values of n found)",  Chr(13),
          "[Result copied to clipboard]" )
end
