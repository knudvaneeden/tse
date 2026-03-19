// Project Euler - Problem 123: Prime Square Remainders
// =====================================================
// Let p_n be the nth prime: 2, 3, 5, 7, 11, ...
// Let r be the remainder when (p_n - 1)^n + (p_n + 1)^n is divided by p_n^2.
// Find the least value of n for which r first exceeds 10^10.
//
// Mathematical key insight:
//   When n is even:  r = 2  (binomial theorem, cross terms cancel)
//   When n is odd:   r = 2 * n * p_n  (mod p_n^2)
//                    (leading term of the binomial expansion mod p_n^2)
//
// So we only check odd n, and test whether 2 * n * p_n > 10^10,
// i.e. n * p_n > 5,000,000,000.
//
// OVERFLOW AVOIDANCE:
//   5,000,000,000 exceeds SAL's signed 32-bit max (2,147,483,647).
//   We rearrange:  n * p_n > 5e9  <=>  n > floor(5e9 / p_n)
//   The right-hand side (~21035) fits easily in 32 bits for large primes.
//   We compute floor(5e9 / p_n) safely as:
//     write 5e9 = 5,000,000 * 1000
//     floor(5e9/p) = floor(5000000/p)*1000 + floor((5000000 mod p)*1000/p)
//   All intermediates stay within signed 32-bit range for p >= 3:
//     5,000,000 mod p  <  p < 300,000
//     (5,000,000 mod p)*1000  < 300,000,000  (well under 2^31)
//   Exception: p=2 gives hiI*1000 = 2,500,000,000 which overflows 32-bit.
//   Guard: if threshI <= 0 (overflow detected), skip -- n cannot exceed
//   floor(5e9/2)=2.5e9 when n is only 1 or 3, so skipping is correct.
//
// Sieve of Eratosthenes up to 300,000 (sufficient for n up to ~25000).
//
// Created by: Claude (Anthropic)
// <version>1.0.0.0.4</version>
//
// History:
//   1.0.0.0.1  2026  Initial version. Created by Claude (Anthropic claude-sonnet-4-6).
//   1.0.0.0.2  2026  Fixed: ELSIF -> ELSEIF (SAL keyword is ELSEIF, not ELSIF).
//   1.0.0.0.3  2026  Fixed: removed broken MulHi/MulLo (SAL shr is arithmetic/signed,
//                    corrupting the high-half). Replaced with safe division-based
//                    comparison: n > floor(5e9/p_n), computed via two 32-bit steps.
//   1.0.0.0.4  2026  Fixed: p=2 (n=1) caused hiI*1000 = 2,500,000,000 to overflow
//                    signed 32-bit, producing a negative threshI and a false trigger
//                    at n=1. Added guard: only compare when threshI > 0.

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
constant SIEVE_MAX = 300000

// ---------------------------------------------------------------------------
// Globals
// ---------------------------------------------------------------------------
integer gSieveBufI = 0    // buffer id for sieve
integer gPrimeBufI = 0    // buffer id for prime list (one prime per line)

// ---------------------------------------------------------------------------
// Forward declarations
// ---------------------------------------------------------------------------
forward proc BuildSieve()
forward proc BuildPrimeList()
forward integer proc FloorDiv5e9( integer pI )

// ---------------------------------------------------------------------------
// BuildSieve
//   Fills gSieveBufI with SIEVE_MAX+1 lines.
//   Line n+1 = "1" means n is prime; "0" means composite.
//   0 and 1 are marked "0"; 2 upward start as "1".
// ---------------------------------------------------------------------------
proc BuildSieve()
    integer nI = 0
    integer mI = 0
    //
    GotoBufferId( gSieveBufI )
    EmptyBuffer()
    // Fill all lines with "1"
    nI = 0
    while nI <= SIEVE_MAX
        AddLine( "1" )
        nI = nI + 1
    endwhile
    // Mark 0 and 1 as not prime
    GotoLine( 1 )
    BegLine()
    KillToEol()
    InsertText( "0" )
    GotoLine( 2 )
    BegLine()
    KillToEol()
    InsertText( "0" )
    // Sieve: cross out multiples
    nI = 2
    while nI * nI <= SIEVE_MAX
        GotoLine( nI + 1 )
        if GetText( 1, 1 ) == "1"
            mI = nI * 2
            while mI <= SIEVE_MAX
                GotoLine( mI + 1 )
                BegLine()
                KillToEol()
                InsertText( "0" )
                mI = mI + nI
            endwhile
        endif
        nI = nI + 1
    endwhile
end

// ---------------------------------------------------------------------------
// BuildPrimeList
//   Walks gSieveBufI and appends each prime to gPrimeBufI (one per line).
// ---------------------------------------------------------------------------
proc BuildPrimeList()
    integer nI    = 2
    string  sS[8] = ""
    //
    GotoBufferId( gPrimeBufI )
    EmptyBuffer()
    while nI <= SIEVE_MAX
        GotoBufferId( gSieveBufI )
        GotoLine( nI + 1 )
        if GetText( 1, 1 ) == "1"
            GotoBufferId( gPrimeBufI )
            sS = Str( nI )
            AddLine( sS )
        endif
        nI = nI + 1
    endwhile
end

// ---------------------------------------------------------------------------
// FloorDiv5e9( pI )
//   Returns floor( 5,000,000,000 / pI ) using only safe 32-bit arithmetic.
//
//   Method: 5,000,000,000 = 5,000,000 * 1,000
//     floor(5e9 / p) = floor(5000000 / p) * 1000
//                    + floor( (5000000 mod p) * 1000 / p )
//
//   Safe for p >= 3. For p=2: hiI*1000 = 2,500,000,000 overflows;
//   caller must guard against threshI <= 0.
// ---------------------------------------------------------------------------
integer proc FloorDiv5e9( integer pI )
    integer hiI  = 0    // floor( 5000000 / pI )
    integer remI = 0    // 5000000 mod pI
    integer loI  = 0    // floor( remI * 1000 / pI )
    //
    hiI  = 5000000 / pI
    remI = 5000000 mod pI
    loI  = ( remI * 1000 ) / pI
    return( hiI * 1000 + loI )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer rankI      = 0     // n (1-based prime index)
    integer primeI     = 0     // p_n
    integer numPrimesI = 0     // total primes in list
    integer threshI    = 0     // floor(5e9 / p_n); may overflow for p=2
    integer foundI     = 0     // answer: least n
    string  resultS[20] = ""
    //
    // Create working buffers
    gSieveBufI = CreateTempBuffer()
    gPrimeBufI = CreateTempBuffer()
    //
    // Build sieve and prime list
    BuildSieve()
    BuildPrimeList()
    //
    GotoBufferId( gPrimeBufI )
    numPrimesI = NumLines()
    //
    // Walk primes; only odd-indexed n have non-trivial remainder.
    // Condition: 2*n*p_n > 10^10  <=>  n*p_n > 5e9  <=>  n > floor(5e9/p_n)
    // Guard: threshI > 0 ensures no false trigger from p=2 overflow.
    rankI = 1
    while rankI <= numPrimesI  AND  foundI == 0
        if ( rankI mod 2 ) == 1    // odd n only
            GotoBufferId( gPrimeBufI )
            GotoLine( rankI )
            primeI = Val( GetText( 1, CurrLineLen() ) )
            //
            threshI = FloorDiv5e9( primeI )
            //
            if threshI > 0  AND  rankI > threshI
                foundI = rankI
            endif
        endif
        rankI = rankI + 1
    endwhile
    //
    // Clean up buffers
    AbandonFile( gSieveBufI )
    AbandonFile( gPrimeBufI )
    //
    // Output result
    resultS = Str( foundI )
    CopyToWinClip( resultS )
    Warn( "Project Euler Problem 123" + Chr(13) +
          "Prime Square Remainders"   + Chr(13) +
          Chr(13) +
          "Least n where remainder"   + Chr(13) +
          "first exceeds 10^10:"      + Chr(13) +
          Chr(13) +
          "n = " + resultS            + Chr(13) +
          Chr(13) +
          "(Answer copied to clipboard)" )
end
