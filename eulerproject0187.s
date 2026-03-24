// ===========================================================================
// Project Euler - Problem 187: Semiprimes
// ===========================================================================
// How many composite integers n < 10^8 have precisely two prime factors
// (not necessarily distinct)?
// ===========================================================================
// Example: below 30 the 10 semiprimes are: 4,6,9,10,14,15,21,22,25,26.
//
// Method:
//   A semiprime n = p*q with p <= q, both prime.  p^2 <= n < LIMIT => p<=9999.
//   Answer = sum over primes p <= 9999 of CountPrimesInRange(p, (LIMIT-1)/p)
//          = sum of [pi((LIMIT-1)/p) - (primeIndex(p) - 1)]
//
//   PACKED SIEVE (gSieveBufI):
//     CHUNK=240 numbers per line. Line k (1-based) covers numbers
//     [(k-1)*240 .. k*240-1]. Each line = 240-char string, '0'=prime, '1'=comp.
//     Built via Eratosthenes: for each small prime p (trial-div found),
//     mark all multiples >= 2p as '1'.  For each block, done in ONE string
//     build then ONE AddLine -- so only 208334 AddLine calls total.
//
//   COUNTING:
//     Small primes p <= 9999 found by trial division (1229 primes).
//     For each p (index idxI, 1-based), count primes in [p..(LIMIT-1)/p]
//     by scanning the packed sieve line by line.
// ===========================================================================
// <version>1.0.0.0.1</version>
// <history>
//   1.0.0.0.1  2025-03-24  Created by Claude (Anthropic claude-sonnet-4-6)
// </history>
// ===========================================================================

constant LIMIT     = 100000000    // 10^8 (exclusive)
constant SIEVE_MAX = 49999999     // sieve [0 .. SIEVE_MAX]; q<=SIEVE_MAX for p=2
constant CHUNK     = 240          // numbers per sieve line
constant SQRT_SM   = 7072         // floor(sqrt(SIEVE_MAX)) for Eratosthenes
constant SMALL_LIM = 9999         // p^2 < LIMIT => p <= 9999

integer gSieveBufI = 0    // packed sieve buffer
integer gSmPrBufI  = 0    // small primes p <= SMALL_LIM, one per line

// ---------------------------------------------------------------------------
// IsPrimeTrialDiv: trial division for small n (n <= SMALL_LIM)
// ---------------------------------------------------------------------------
integer proc IsPrimeTrialDiv( integer nI )
    integer dI
    //
    if nI < 2         return( FALSE )  endif
    if nI == 2        return( TRUE )   endif
    if nI mod 2 == 0  return( FALSE )  endif
    dI = 3
    while dI * dI <= nI
        if nI mod dI == 0
            return( FALSE )
        endif
        dI = dI + 2
    endwhile
    return( TRUE )
end

// ---------------------------------------------------------------------------
// CollectSmallPrimes: store primes 2..SMALL_LIM in gSmPrBufI (one per line)
// ---------------------------------------------------------------------------
proc CollectSmallPrimes()
    integer nI
    //
    GotoBufferId( gSmPrBufI )
    EmptyBuffer()
    nI = 2
    while nI <= SMALL_LIM
        if IsPrimeTrialDiv( nI )
            AddLine( Str( nI ) )
        endif
        nI = nI + 1
    endwhile
end

// ---------------------------------------------------------------------------
// BuildPackedSieve:
//   For each block (group of CHUNK numbers), build a CHUNK-char string with
//   composites pre-marked, then AddLine once.  => O(blocks) line writes.
//   Inner marking loop: for each small prime p <= SQRT_SM, mark all multiples
//   >= 2p within the current block by modifying the block string.
// ---------------------------------------------------------------------------
proc BuildPackedSieve()
    integer numBlocksI    // total number of blocks (lines in sieve buffer)
    integer numSpSieveI   // count of small primes needed for sieve (p <= SQRT_SM)
    integer blockI        // block index (0-based)
    integer loI           // first number in block
    integer hiI           // last number in block
    integer blockSzI      // actual block size (may be less than CHUNK for last block)
    integer spIdxI        // index into gSmPrBufI
    integer pI            // current small prime
    integer firstMultI    // first multiple of pI in [loI..hiI] that we mark
    integer mI            // current multiple
    integer kI            // 1-based position within block string
    string  blockS[240]   // block string being constructed
    string  zS[240]       // 240 zeros (template)
    //
    // 240-zero template (5 * 48 = 240)
    zS = "000000000000000000000000000000000000000000000000" +
         "000000000000000000000000000000000000000000000000" +
         "000000000000000000000000000000000000000000000000" +
         "000000000000000000000000000000000000000000000000" +
         "000000000000000000000000000000000000000000000000"
    //
    // Count small primes for sieve (p <= SQRT_SM)
    GotoBufferId( gSmPrBufI )
    numSpSieveI = 0
    numBlocksI  = SIEVE_MAX / CHUNK + 1
    //
    // Find how many primes <= SQRT_SM
    GotoBufferId( gSmPrBufI )
    numSpSieveI = NumLines()    // start with all, will stop early in loop
    //
    GotoBufferId( gSieveBufI )
    EmptyBuffer()
    //
    // Process each block
    blockI = 0
    while blockI < numBlocksI
        loI      = blockI * CHUNK
        hiI      = loI + CHUNK - 1
        if hiI > SIEVE_MAX
            hiI = SIEVE_MAX
        endif
        blockSzI = hiI - loI + 1
        //
        // Start block as all prime candidates ('0')
        blockS = SubStr( zS, 1, blockSzI )
        //
        // Mark 0 and 1 as composite (only in block 0)
        if blockI == 0
            // position 1 = number 0  => composite
            blockS = "1" + SubStr( blockS, 2, blockSzI - 1 )
            // position 2 = number 1  => composite
            blockS = SubStr( blockS, 1, 1 ) + "1" + SubStr( blockS, 3, blockSzI - 2 )
        endif
        //
        // Mark composites using each small prime p <= SQRT_SM
        spIdxI = 1
        while spIdxI <= numSpSieveI
            GotoBufferId( gSmPrBufI )
            GotoLine( spIdxI )
            pI = Val( GetText( 1, CurrLineLen() ) )
            //
            // Only use primes up to SQRT_SM for sieving
            if pI > SQRT_SM
                break
            endif
            //
            // First multiple of pI to mark: at least 2*pI, and at least loI
            firstMultI = ( ( loI + pI - 1 ) / pI ) * pI
            if firstMultI < pI * 2
                firstMultI = pI * 2
            endif
            //
            mI = firstMultI
            while mI <= hiI
                kI     = mI - loI + 1    // 1-based position in blockS
                blockS = SubStr( blockS, 1, kI - 1 ) + "1" +
                         SubStr( blockS, kI + 1, blockSzI - kI )
                mI = mI + pI
            endwhile
            //
            spIdxI = spIdxI + 1
        endwhile
        //
        // Write completed block to sieve buffer
        GotoBufferId( gSieveBufI )
        AddLine( blockS )
        //
        blockI = blockI + 1
    endwhile
end

// ---------------------------------------------------------------------------
// CountPrimesInRange: count primes in [loI .. hiI] using the packed sieve.
//   Reads one sieve line at a time, scanning each line's relevant portion.
// ---------------------------------------------------------------------------
integer proc CountPrimesInRange( integer loI, integer hiI )
    integer cntI
    integer curNumI
    integer lineI
    integer lineStartI
    integer lineEndNumI
    integer colStartI
    integer colI
    string  lineS[240]
    //
    if loI > hiI  return( 0 )  endif
    if hiI > SIEVE_MAX  hiI = SIEVE_MAX  endif
    //
    cntI    = 0
    curNumI = loI
    //
    while curNumI <= hiI
        lineI       = curNumI / CHUNK + 1          // 1-based sieve line
        lineStartI  = ( lineI - 1 ) * CHUNK        // first number on this line
        lineEndNumI = lineStartI + CHUNK - 1       // last number on this line
        if lineEndNumI > hiI
            lineEndNumI = hiI
        endif
        //
        GotoBufferId( gSieveBufI )
        GotoLine( lineI )
        lineS     = GetText( 1, CHUNK )
        colStartI = curNumI - lineStartI + 1       // 1-based start col within lineS
        //
        colI = colStartI
        while curNumI <= lineEndNumI
            if SubStr( lineS, colI, 1 ) == "0"
                cntI = cntI + 1
            endif
            colI    = colI + 1
            curNumI = curNumI + 1
        endwhile
    endwhile
    //
    return( cntI )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer countI
    integer idxI
    integer pI
    integer qMaxI
    integer rangeCountI
    integer numSpI
    string  resultS[40]
    //
    gSieveBufI = CreateTempBuffer()
    gSmPrBufI  = CreateTempBuffer()
    //
    // Step 1: collect primes up to SMALL_LIM=9999 via trial division
    CollectSmallPrimes()
    //
    // Step 2: build packed sieve [0..SIEVE_MAX] using small primes
    BuildPackedSieve()
    //
    // Step 3: count semiprimes p*q with p<=q, p prime, q prime, p*q < LIMIT
    //   For each prime p (at 1-based index idxI in gSmPrBufI),
    //   count primes q in [p .. (LIMIT-1)/p].
    //   This equals pi((LIMIT-1)/p) - (idxI-1)
    //   because gSmPrBufI lines 1..idxI-1 are exactly the primes < p.
    //   We check p <= (LIMIT-1)/p, i.e. p^2 <= LIMIT-1, i.e. p <= 9999.
    //
    GotoBufferId( gSmPrBufI )
    numSpI = NumLines()    // all primes <= SMALL_LIM=9999
    countI = 0
    idxI   = 1
    while idxI <= numSpI
        GotoBufferId( gSmPrBufI )
        GotoLine( idxI )
        pI = Val( GetText( 1, CurrLineLen() ) )
        //
        qMaxI = ( LIMIT - 1 ) / pI     // q <= qMaxI  (= floor((LIMIT-1)/p))
        //
        // Guard: p <= qMaxI  <=>  p^2 <= LIMIT-1  <=>  p <= 9999
        if pI <= qMaxI
            rangeCountI = CountPrimesInRange( pI, qMaxI )
            countI      = countI + rangeCountI
        endif
        //
        idxI = idxI + 1
    endwhile
    //
    resultS = Str( countI )
    //
    AbandonFile( gSieveBufI )
    AbandonFile( gSmPrBufI )
    //
    CopyToWinClip( resultS )
    Warn( "Project Euler Problem 187 - Semiprimes", Chr(13),
          "Composites < 10^8 with exactly two prime factors:", Chr(13),
          Chr(13),
          "Answer: ", resultS )
    CopyToWinClip( resultS )
end
