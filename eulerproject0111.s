// Euler Problem 111 - Primes with Runs
// For each digit d in 0..9:
//   Find the maximum k such that there exists a 10-digit prime
//   containing exactly k copies of digit d.
//   Sum all such primes -> S(10,d).
// Answer = sum of S(10,d) for d=0..9.
//
// Approach:
//   Trial division primality test using primes up to 100000
//   (= sqrt(10^10)), so the test is exact.
//   10-digit numbers exceed 32-bit range; we represent them as
//   10-character digit strings. Modular reduction is done
//   digit-by-digit (rem = rem*10 + digit) mod p, which stays
//   within 32-bit throughout since p < 100000 and rem < p.
//   Sums are accumulated with string big-integer arithmetic.
//
//   For each (d, k) we enumerate all placements:
//     - Choose k positions (0-based 0..9) for digit d via
//       standard next-combination algorithm stored in gCombBufG.
//     - Fill the remaining 10-k positions with a base-9 odometer
//       stored in gOtherBufG (values 0..8, mapped to actual digits
//       by skipping d).
//
// Buffers:
//   gPrimeBufG  : one prime per line (2, 3, 5, ..., up to 100000)
//   gResultBufG : lines 1-10 = S(10,d) for d=0..9 as decimal strings
//   gCombBufG   : k lines = indices (0-based) of d-positions
//   gOtherBufG  : (10-k) lines = odometer digits 0..8
//
// <version>1.0.0.0.1</version>

integer gPrimeBufG  = 0
integer gResultBufG = 0
integer gCombBufG   = 0
integer gOtherBufG  = 0

constant SIEVE_MAX = 100000
constant NDIGITS   = 10

// ===========================================================================
// BuildSieve
// Populates gPrimeBufG with all primes from 2 to SIEVE_MAX, one per line.
// Uses an internal temp sieve buffer (line k+1 = "1" if k is prime).
// ===========================================================================
proc BuildSieve()
    integer nTmpBuf
    integer nSave
    integer k
    integer j
    string  sMark[2]

    nSave   = GetBufferId()
    nTmpBuf = CreateTempBuffer()

    // Fill sieve: line k+1 represents number k; "1" = possibly prime
    GotoBufferId( nTmpBuf )
    k = 0
    while k <= SIEVE_MAX
        AddLine( "1" )
        k = k + 1
    endwhile
    // 0 and 1 are not prime
    GotoLine( 1 ) BegLine() KillToEol() InsertText( "0" )
    GotoLine( 2 ) BegLine() KillToEol() InsertText( "0" )

    // Sieve
    k = 2
    while k * k <= SIEVE_MAX
        GotoLine( k + 1 )
        sMark = GetText( 1, 1 )
        if sMark == "1"
            j = k * k
            while j <= SIEVE_MAX
                GotoLine( j + 1 )
                BegLine() KillToEol() InsertText( "0" )
                j = j + k
            endwhile
        endif
        k = k + 1
    endwhile

    // Harvest primes into gPrimeBufG
    GotoBufferId( gPrimeBufG )
    EmptyBuffer()
    k = 2
    while k <= SIEVE_MAX
        GotoBufferId( nTmpBuf )
        GotoLine( k + 1 )
        sMark = GetText( 1, 1 )
        if sMark == "1"
            GotoBufferId( gPrimeBufG )
            AddLine( Str( k ) )
        endif
        k = k + 1
    endwhile

    AbandonFile( nTmpBuf )
    GotoBufferId( nSave )
end

// ===========================================================================
// IsPrime10
// Returns 1 if the 10-char digit string sN represents a prime, 0 otherwise.
// Uses trial division against gPrimeBufG.
// Digit-by-digit mod: rem = (rem * 10 + digit) mod p  stays in 32-bit.
// ===========================================================================
integer proc IsPrime10( string sN )
    integer nSave
    integer nPrimes
    integer i
    integer p
    integer rem
    integer dPos
    integer lastD

    // Quick rejection on last digit (divisible by 2 or 5)
    lastD = Asc( sN[ 10 ] ) - 48
    if lastD == 0 or lastD == 2 or lastD == 4
        or lastD == 5 or lastD == 6 or lastD == 8
        return( 0 )
    endif

    // Quick rejection: divisibility by 3 (digit sum mod 3)
    rem  = 0
    dPos = 1
    while dPos <= 10
        rem  = rem + ( Asc( sN[ dPos ] ) - 48 )
        dPos = dPos + 1
    endwhile
    if rem mod 3 == 0
        return( 0 )
    endif

    nSave   = GetBufferId()
    GotoBufferId( gPrimeBufG )
    nPrimes = NumLines()

    // Start at i=3 (prime=5): primes 2 and 3 already rejected above
    i = 3
    while i <= nPrimes
        GotoLine( i )
        p = Val( GetText( 1, CurrLineLen() ) )

        rem  = 0
        dPos = 1
        while dPos <= 10
            rem  = ( rem * 10 + ( Asc( sN[ dPos ] ) - 48 ) ) mod p
            dPos = dPos + 1
        endwhile

        if rem == 0
            GotoBufferId( nSave )
            return( 0 )
        endif
        i = i + 1
    endwhile

    GotoBufferId( nSave )
    return( 1 )
end

// ===========================================================================
// BigAddToLine
// Adds the decimal string sNum into the string stored on line nLine of
// gResultBufG, replacing it with the sum.
// ===========================================================================
proc BigAddToLine( integer nLine, string sNum )
    integer nSave
    string  sA[255]
    string  sB[255]
    string  sRes[255]
    integer ia
    integer ib
    integer carry
    integer dA
    integer dB
    integer dSum

    nSave = GetBufferId()
    GotoBufferId( gResultBufG )
    GotoLine( nLine )
    sA = GetText( 1, CurrLineLen() )
    if Length( sA ) == 0
        sA = "0"
    endif
    sB    = sNum
    ia    = Length( sA )
    ib    = Length( sB )
    carry = 0
    sRes  = ""

    while ia > 0 or ib > 0 or carry > 0
        dA = 0
        dB = 0
        if ia > 0
            dA = Asc( sA[ ia ] ) - 48
            ia = ia - 1
        endif
        if ib > 0
            dB = Asc( sB[ ib ] ) - 48
            ib = ib - 1
        endif
        dSum  = dA + dB + carry
        carry = dSum / 10
        dSum  = dSum mod 10
        sRes  = Chr( dSum + 48 ) + sRes
    endwhile

    if Length( sRes ) == 0
        sRes = "0"
    endif
    BegLine()
    KillToEol()
    InsertText( sRes )
    GotoBufferId( nSave )
end

// ===========================================================================
// InitComb
// Sets gCombBufG to the first k-combination: lines 1..k hold 0,1,...,k-1.
// ===========================================================================
proc InitComb( integer k )
    integer nSave
    integer i

    nSave = GetBufferId()
    GotoBufferId( gCombBufG )
    EmptyBuffer()
    i = 0
    while i < k
        AddLine( Str( i ) )
        i = i + 1
    endwhile
    GotoBufferId( nSave )
end

// ===========================================================================
// NextComb
// Advances the k-from-NDIGITS combination stored in gCombBufG.
// Returns 1 if a next combination exists, 0 if already at the last one.
// ===========================================================================
integer proc NextComb( integer k )
    integer nSave
    integer i
    integer nIdx
    integer nBase
    integer j

    nSave = GetBufferId()
    GotoBufferId( gCombBufG )

    // Find rightmost index that can be incremented
    i = k
    while i >= 1
        GotoLine( i )
        nIdx = Val( GetText( 1, CurrLineLen() ) )
        // Maximum value for position i (1-based) is NDIGITS - k + i - 1
        if nIdx < NDIGITS - k + i - 1
            // Increment this position
            nBase = nIdx + 1
            BegLine() KillToEol() InsertText( Str( nBase ) )
            // Reset all subsequent positions consecutively
            j = i + 1
            while j <= k
                GotoLine( j )
                BegLine() KillToEol() InsertText( Str( nBase + j - i ) )
                j = j + 1
            endwhile
            GotoBufferId( nSave )
            return( 1 )
        endif
        i = i - 1
    endwhile

    GotoBufferId( nSave )
    return( 0 )
end

// ===========================================================================
// InitOdometer
// Fills gOtherBufG with nOther lines all set to "0".
// ===========================================================================
proc InitOdometer( integer nOther )
    integer nSave
    integer i

    nSave = GetBufferId()
    GotoBufferId( gOtherBufG )
    EmptyBuffer()
    i = 1
    while i <= nOther
        AddLine( "0" )
        i = i + 1
    endwhile
    GotoBufferId( nSave )
end

// ===========================================================================
// AdvanceOdometer
// Increments the base-9 counter in gOtherBufG (nOther digits).
// Returns 1 if successfully advanced, 0 if it wrapped (was all 8s).
// ===========================================================================
integer proc AdvanceOdometer( integer nOther )
    integer nSave
    integer i
    integer nV
    integer carry

    nSave = GetBufferId()
    GotoBufferId( gOtherBufG )

    carry = 1
    i     = nOther
    while i >= 1 and carry == 1
        GotoLine( i )
        nV = Val( GetText( 1, CurrLineLen() ) )
        nV = nV + 1
        if nV >= 9
            nV    = 0
            carry = 1
        else
            carry = 0
        endif
        BegLine() KillToEol() InsertText( Str( nV ) )
        i = i - 1
    endwhile

    GotoBufferId( nSave )
    if carry == 1
        return( 0 )
    endif
    return( 1 )
end

// ===========================================================================
// BuildNumber
// Constructs the 10-character digit string for the current state of
// gCombBufG (k positions for digit d) and gOtherBufG (nOther odometer values).
// Returns "" if the number has a leading zero.
// ===========================================================================
string proc BuildNumber( integer d, integer k, integer nOther )
    integer nSave
    string  sResult[12]
    integer i
    integer combIdx
    integer combVal
    integer isD
    integer otherIdx
    integer odoVal
    integer mappedDigit

    nSave    = GetBufferId()
    sResult  = ""
    otherIdx = 1

    i = 0
    while i < NDIGITS
        // Determine whether position i is a d-position
        isD     = 0
        combIdx = 1
        while combIdx <= k
            GotoBufferId( gCombBufG )
            GotoLine( combIdx )
            combVal = Val( GetText( 1, CurrLineLen() ) )
            if combVal == i
                isD     = 1
                combIdx = k + 1   // exit inner loop
            else
                combIdx = combIdx + 1
            endif
        endwhile

        if isD
            sResult = sResult + Chr( d + 48 )
        else
            // Map odometer value 0..8 to a digit 0..9 skipping d
            GotoBufferId( gOtherBufG )
            GotoLine( otherIdx )
            odoVal      = Val( GetText( 1, CurrLineLen() ) )
            mappedDigit = odoVal
            if mappedDigit >= d
                mappedDigit = mappedDigit + 1
            endif
            sResult  = sResult + Chr( mappedDigit + 48 )
            otherIdx = otherIdx + 1
        endif
        i = i + 1
    endwhile

    GotoBufferId( nSave )

    // Reject leading zero
    if sResult[ 1 ] == "0"
        return( "" )
    endif
    return( sResult )
end

// ===========================================================================
// ProcessDigitK
// Enumerates all 10-digit numbers with exactly k copies of digit d,
// tests each for primality, accumulates sums into gResultBufG line d+1.
// Returns the count of primes found.
// ===========================================================================
integer proc ProcessDigitK( integer d, integer k )
    integer nOther
    integer nCount
    integer nSave
    string  sNum[12]
    integer moreCombs
    integer moreOdo
    integer odoValid

    nOther    = NDIGITS - k
    nCount    = 0
    nSave     = GetBufferId()

    InitComb( k )
    moreCombs = 1

    while moreCombs
        if nOther == 0
            // All 10 positions are digit d; only one number possible
            sNum = BuildNumber( d, k, 0 )
            if Length( sNum ) == 10
                if IsPrime10( sNum )
                    BigAddToLine( d + 1, sNum )
                    nCount = nCount + 1
                endif
            endif
        else
            // Iterate all 9^(nOther) odometer settings
            InitOdometer( nOther )
            odoValid = 1
            while odoValid
                sNum = BuildNumber( d, k, nOther )
                if Length( sNum ) == 10
                    if IsPrime10( sNum )
                        BigAddToLine( d + 1, sNum )
                        nCount = nCount + 1
                    endif
                endif
                // Advance odometer; if it overflows we are done
                moreOdo  = AdvanceOdometer( nOther )
                odoValid = moreOdo
            endwhile
        endif
        moreCombs = NextComb( k )
    endwhile

    GotoBufferId( nSave )
    return( nCount )
end

// ===========================================================================
// Main
// ===========================================================================
proc Main()
    integer d
    integer k
    integer nFound
    integer nSave
    string  sGrandTotal[255]
    string  sS[255]
    string  sResult[255]
    integer ia
    integer ib
    integer carry
    integer dA
    integer dB
    integer dSum

    nSave = GetBufferId()

    // Allocate working buffers
    gPrimeBufG  = CreateTempBuffer()
    gResultBufG = CreateTempBuffer()
    gCombBufG   = CreateTempBuffer()
    gOtherBufG  = CreateTempBuffer()

    // Initialise result lines 1..10 (for d=0..9) to "0"
    GotoBufferId( gResultBufG )
    EmptyBuffer()
    d = 0
    while d <= 9
        AddLine( "0" )
        d = d + 1
    endwhile

    // Build prime sieve (primes 2..100000)
    Message( "Building prime sieve..." )
    BuildSieve()

    // For each digit d find M(10,d) and accumulate S(10,d)
    d = 0
    while d <= 9
        Message( "Digit " + Str( d ) + ": searching for maximum run length..." )
        k      = NDIGITS
        nFound = 0
        while k >= 1 and nFound == 0
            nFound = ProcessDigitK( d, k )
            if nFound == 0
                k = k - 1
            endif
        endwhile
        d = d + 1
    endwhile

    // Grand total = sum of S(10,d) for d=0..9
    sGrandTotal = "0"
    d = 0
    while d <= 9
        GotoBufferId( gResultBufG )
        GotoLine( d + 1 )
        sS = GetText( 1, CurrLineLen() )
        if Length( sS ) == 0
            sS = "0"
        endif

        // Add sS into sGrandTotal
        ia    = Length( sGrandTotal )
        ib    = Length( sS )
        carry = 0
        sResult = ""
        while ia > 0 or ib > 0 or carry > 0
            dA = 0
            dB = 0
            if ia > 0
                dA = Asc( sGrandTotal[ ia ] ) - 48
                ia = ia - 1
            endif
            if ib > 0
                dB = Asc( sS[ ib ] ) - 48
                ib = ib - 1
            endif
            dSum    = dA + dB + carry
            carry   = dSum / 10
            dSum    = dSum mod 10
            sResult = Chr( dSum + 48 ) + sResult
        endwhile
        if Length( sResult ) == 0
            sResult = "0"
        endif
        sGrandTotal = sResult
        d = d + 1
    endwhile

    GotoBufferId( nSave )

    CopyToWinClip( sGrandTotal )
    Warn( "Euler P111 - Sum of all S(10,d) =" + Chr(13) + sGrandTotal )
end
