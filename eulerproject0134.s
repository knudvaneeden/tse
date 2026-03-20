// Project Euler - Problem 134: Prime Pair Connection
// <version>1.0.0.0.1</version>
//
// For every consecutive prime pair (p1, p2) with 5 <= p1 <= 1,000,000:
// Find the smallest positive S such that:
//   - S ends in the decimal digits of p1
//   - S is divisible by p2
// Sum all such S values.
//
// Method (modular arithmetic):
//   Let k = smallest power of 10 strictly greater than p1
//   S = m*k + p1  for some non-negative integer m
//   Divisibility: m*k + p1 == 0 (mod p2)
//   => m == (-p1) * ModInverse(k, p2)  (mod p2)
//   Take smallest non-negative m, then S = m*k + p1.
//
// Overflow notes:
//   - p1 <= 999983 (6 digits), so k <= 10^6; m < p2 <= ~1M => m*k <= ~10^12 (overflows 32-bit)
//   - Total sum ~1.86 * 10^16      (overflows 32-bit)
//   => Individual S values: hi/lo split with BASE=1000 (both hi and lo fit in 32-bit)
//   => Running sum: big-integer as decimal string in gSumBigS
//
// Big-integer addition stores one digit per line in a scratch buffer,
// reversed (LSB at line 1). Reading back reverses again into gSumBigS.

// ============================================================
// Constants
// ============================================================
constant LIMIT    = 1000000   // p1 must be <= this
constant SIEVE_N  = 1100000   // large enough to always have a next prime after p1
constant BASE     = 1000      // hi/lo split base  (= 10^3)
                              // With BASE=1000: hi = m*(k/1000) <= ~10^9 (fits 32-bit)
                              // lo = m*(k mod 1000) + p1 <= ~111M (fits 32-bit)

// ============================================================
// Globals
// ============================================================
string  gSumBigS[255] = "0"   // big-integer accumulator (decimal string)

// ============================================================
// FORWARD declarations
// ============================================================
forward integer proc FNIsPrimeI( integer nI )
forward integer proc FNModInverseI( integer aI, integer mI )
forward integer proc FNPow10GtI( integer nI )
forward proc         BigAddHiLo( integer hiI, integer loI )

// ============================================================
// FNIsPrimeI  --  sieve lookup
// Sieve buffer "p134_sieve": line (n+1) contains "1" (prime) or "0".
// ============================================================
integer proc FNIsPrimeI( integer nI )
    integer prevBufI = 0
    integer retI     = 0
    //
    prevBufI = GetBufferId()
    GotoBufferId( GetBufferId( "p134_sieve" ) )
    GotoLine( nI + 1 )
    retI = Val( GetText( 1, 1 ) )
    GotoBufferId( prevBufI )
    return( retI )
end

// ============================================================
// FNModInverseI  --  extended Euclidean
// Returns x in [0, mI) such that aI * x == 1 (mod mI).
// Guaranteed to exist because p2 is prime and k is a power of 10,
// and p2 > 5 so gcd(p2, 10) = 1.
// All intermediate values stay within 32-bit range (mI <= ~1.1M).
// ============================================================
integer proc FNModInverseI( integer aI, integer mI )
    integer oldRI = 0
    integer rI    = 0
    integer oldSI = 0
    integer sI    = 0
    integer tempI = 0
    integer quotI = 0
    //
    oldRI = aI
    rI    = mI
    oldSI = 1
    sI    = 0
    while rI <> 0
        quotI = oldRI / rI
        tempI = rI
        rI    = oldRI - quotI * rI
        oldRI = tempI
        tempI = sI
        sI    = oldSI - quotI * sI
        oldSI = tempI
    endwhile
    // Normalise to [0, mI)
    oldSI = ((oldSI mod mI) + mI) mod mI
    return( oldSI )
end

// ============================================================
// FNPow10GtI  --  smallest power of 10 strictly greater than nI
// ============================================================
integer proc FNPow10GtI( integer nI )
    integer kI = 0
    //
    kI = 10
    while kI <= nI
        kI = kI * 10
    endwhile
    return( kI )
end

// ============================================================
// BigAddHiLo  --  gSumBigS  +=  (hiI * BASE + loI)
//
// hiI >= 0,  0 <= loI < BASE.
// If hiI == 0: addS = Str(loI)
// Else:        addS = Str(hiI) + Format(loI:3:"0")   (no 32-bit overflow)
//
// Algorithm:
//   1. Build addS string.
//   2. Add addS to gSumBigS digit-by-digit (LSB first), storing each
//      result digit as one line in scratch buffer "p134_add".
//   3. Walk buffer from last line to first to rebuild gSumBigS.
// ============================================================
proc BigAddHiLo( integer hiI, integer loI )
    integer scrBufI   = 0
    integer prevBufI  = 0
    integer addLenI   = 0
    integer sumLenI   = 0
    integer maxLenI   = 0
    integer posI      = 0
    integer carryI    = 0
    integer dAddI     = 0
    integer dSumI     = 0
    integer totI      = 0
    integer nLinesI   = 0
    integer lineI     = 0
    integer stopB     = 0
    string  addS[255] = ""
    string  sumS[255] = ""
    //
    // Step 1: build the string for the value to add
    if hiI == 0
        addS = Str( loI )
    else
        addS = Str( hiI ) + Format( loI:3:"0" )
    endif
    //
    addLenI = Length( addS )
    sumLenI = Length( gSumBigS )
    maxLenI = addLenI
    if sumLenI > maxLenI
        maxLenI = sumLenI
    endif
    //
    // Step 2: digit-by-digit addition into scratch buffer (LSB at line 1)
    prevBufI = GetBufferId()
    scrBufI  = GetBufferId( "p134_add" )
    GotoBufferId( scrBufI )
    EmptyBuffer()
    //
    carryI = 0
    posI   = 0
    while posI < maxLenI OR carryI > 0
        dAddI = 0
        dSumI = 0
        if posI < addLenI
            dAddI = Val( SubStr( addS,     addLenI - posI,     1 ) )
        endif
        if posI < sumLenI
            dSumI = Val( SubStr( gSumBigS, sumLenI - posI, 1 ) )
        endif
        totI   = dAddI + dSumI + carryI
        carryI = totI / 10
        totI   = totI mod 10
        AddLine( Str( totI ) )
        posI = posI + 1
    endwhile
    //
    // Step 3: read lines from last to first => MSB-first decimal string
    nLinesI = NumLines()
    sumS    = ""
    lineI   = nLinesI
    stopB   = FALSE
    while stopB == FALSE
        GotoLine( lineI )
        sumS  = sumS + GetText( 1, CurrLineLen() )
        lineI = lineI - 1
        if lineI < 1
            stopB = TRUE
        endif
    endwhile
    //
    // Strip leading zeros (always keep at least one digit)
    posI = 1
    while posI < Length( sumS ) AND SubStr( sumS, posI, 1 ) == "0"
        posI = posI + 1
    endwhile
    gSumBigS = SubStr( sumS, posI, Length( sumS ) - posI + 1 )
    //
    GotoBufferId( prevBufI )
end

// ============================================================
// Main
// ============================================================
proc Main()
    integer sieveBufI = 0
    integer scrBufI   = 0
    integer iI        = 0
    integer jI        = 0
    integer p1I       = 0
    integer p2I       = 0
    integer kI        = 0
    integer invKI     = 0
    integer mI        = 0
    integer negP1I    = 0
    integer hiI       = 0
    integer loI       = 0
    //
    // ---- Build Sieve of Eratosthenes ----
    sieveBufI = GetBufferId( "p134_sieve" )
    if sieveBufI == 0
        sieveBufI = CreateBuffer( "p134_sieve" )
    endif
    GotoBufferId( sieveBufI )
    EmptyBuffer()
    //
    // Initialise: one line per number 0..SIEVE_N, all "1"
    iI = 0
    while iI <= SIEVE_N
        AddLine( "1" )
        iI = iI + 1
    endwhile
    //
    // Mark 0 and 1 as composite
    GotoLine( 0 + 1 )   BegLine()   KillToEol()   InsertText( "0" )
    GotoLine( 1 + 1 )   BegLine()   KillToEol()   InsertText( "0" )
    //
    // Sieve of Eratosthenes
    iI = 2
    while iI * iI <= SIEVE_N
        GotoLine( iI + 1 )
        if Val( GetText( 1, 1 ) ) == 1
            jI = iI * iI
            while jI <= SIEVE_N
                GotoLine( jI + 1 )
                BegLine()   KillToEol()   InsertText( "0" )
                jI = jI + iI
            endwhile
        endif
        iI = iI + 1
    endwhile
    //
    // ---- Create scratch buffer for BigAddHiLo ----
    scrBufI = GetBufferId( "p134_add" )
    if scrBufI == 0
        scrBufI = CreateBuffer( "p134_add" )
    endif
    //
    gSumBigS = "0"
    //
    // ---- Main loop: consecutive prime pairs (p1, p2), 5 <= p1 <= LIMIT ----
    p1I = 5
    while p1I <= LIMIT
        // Find p2 = next prime after p1
        p2I = p1I + 1
        while FNIsPrimeI( p2I ) == 0
            p2I = p2I + 1
        endwhile
        //
        // k = smallest power of 10 strictly greater than p1
        kI = FNPow10GtI( p1I )
        //
        // Modular inverse of (k mod p2) w.r.t. p2
        invKI = FNModInverseI( kI mod p2I, p2I )
        //
        // m = (-p1 mod p2) * invK  (mod p2),  result in [0, p2)
        negP1I = (p2I - (p1I mod p2I)) mod p2I
        mI     = (negP1I * invKI) mod p2I
        //
        // S = m*k + p1  via hi/lo split to avoid 32-bit overflow
        //   m < p2 <= ~1M,  k <= 10^6  =>  m*k <= ~10^12
        //   With BASE=1000: hi = m*(k/1000) <= ~10^9 (fits), lo = m*(k%1000)+p1 <= ~111M (fits)
        //   Note: k is always a power of 10, so k%1000 is 0 for k>=1000 (lo=p1 only)
        loI = mI * (kI mod BASE) + p1I
        hiI = mI * (kI / BASE)
        hiI = hiI + loI / BASE
        loI = loI mod BASE
        //
        BigAddHiLo( hiI, loI )
        //
        // Advance p1 to p2 for next iteration
        p1I = p2I
    endwhile
    //
    Warn( "Problem 134 answer:" + Chr(13) + gSumBigS )
    CopyToWinClip( gSumBigS )
end
