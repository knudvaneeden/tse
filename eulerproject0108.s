// p108.s
// Project Euler - Problem 108: Diophantine Reciprocals I
//
// Problem:
//   1/x + 1/y = 1/n, where x, y, n are positive integers.
//   Find the least value of n for which the number of
//   distinct solutions exceeds 1000.
//
// Math key:
//   Rearranging: (x-n)(y-n) = n^2
//   Distinct solutions with x<=y = (d(n^2) + 1) / 2
//   where d(n^2) is the number of divisors of n^2.
//   If n = p1^e1 * p2^e2 * ... then d(n^2) = (2e1+1)(2e2+1)...
//   We need (d(n^2)+1)/2 > 1000  =>  d(n^2) >= 1999
//
// Strategy:
//   For each n, trial-divide by small primes to get exponents,
//   compute d(n^2) from those exponents.
//   No need to compute n^2 (avoids 32-bit overflow for n~180180).
//
// Answer: 180180
//
// <version>1.0.0.0.1</version>

// --- Globals ---
integer gPrimeBufIdG    = 0     // buffer id for small primes sieve
integer gAnswerG        = 0     // final answer

// ---------------------------------------------------------------------------
// BuildPrimeSieve
// Sieve of Eratosthenes up to SIEVE_LIMIT.
// Line k+1 holds "1" if k is prime, "0" otherwise  (1-indexed: line 1 = number 0).
// We only need primes up to sqrt(180180) ~ 425, so 500 is ample.
// ---------------------------------------------------------------------------
proc BuildPrimeSieve()
    integer SIEVE_LIMIT
    integer i
    integer j
    integer NVal

    SIEVE_LIMIT = 500

    gPrimeBufIdG = CreateTempBuffer()
    GotoBufferId( gPrimeBufIdG )
    EmptyBuffer()

    // Fill lines: index 1 = number 0, index 2 = number 1, etc.
    // Initialise all to "1"
    i = 0
    while i <= SIEVE_LIMIT
        AddLine( "1" )
        i = i + 1
    endwhile

    // 0 and 1 are not prime
    GotoLine( 1 )   // number 0
    BegLine()
    KillToEol()
    InsertText( "0" )

    GotoLine( 2 )   // number 1
    BegLine()
    KillToEol()
    InsertText( "0" )

    // Sieve
    i = 2
    while i <= SIEVE_LIMIT
        GotoLine( i + 1 )
        if GetText( 1, 1 ) == "1"
            j = i * i
            while j <= SIEVE_LIMIT
                GotoLine( j + 1 )
                BegLine()
                KillToEol()
                InsertText( "0" )
                j = j + i
            endwhile
        endif
        i = i + 1
    endwhile
end

// ---------------------------------------------------------------------------
// IsPrime(n)  - checks the sieve (for n <= 500) or does trial division
// ---------------------------------------------------------------------------
integer proc IsPrime( integer n )
    integer d

    if n < 2
        return( 0 )
    endif

    if n <= 500
        GotoBufferId( gPrimeBufIdG )
        GotoLine( n + 1 )
        if GetText( 1, 1 ) == "1"
            return( 1 )
        else
            return( 0 )
        endif
    endif

    // Trial division for n > 500 (shouldn't be needed here)
    if ( n & 1 ) == 0
        return( 0 )
    endif
    d = 3
    while d * d <= n
        if n mod d == 0
            return( 0 )
        endif
        d = d + 2
    endwhile
    return( 1 )
end

// ---------------------------------------------------------------------------
// CountDivisorsNSquared(n)
// Returns d(n^2) = product of (2*ei + 1) for each prime power p^ei | n.
// Uses trial division; primes only up to sqrt(n) ~ 425 for n<=180180.
// ---------------------------------------------------------------------------
integer proc CountDivisorsNSquared( integer nIn )
    integer rem
    integer dCount
    integer p
    integer e
    integer primeBufSave

    primeBufSave = GetBufferId()   // save current buffer context
    rem    = nIn
    dCount = 1
    p      = 2

    // Trial divide by 2 first
    if rem mod 2 == 0
        e = 0
        while rem mod 2 == 0
            e   = e + 1
            rem = rem / 2
        endwhile
        dCount = dCount * ( 2 * e + 1 )
    endif

    // Trial divide by odd numbers starting at 3
    p = 3
    while p * p <= rem
        if rem mod p == 0
            e = 0
            while rem mod p == 0
                e   = e + 1
                rem = rem / p
            endwhile
            dCount = dCount * ( 2 * e + 1 )
        endif
        p = p + 2
    endwhile

    // If a prime factor > sqrt(n) remains
    if rem > 1
        dCount = dCount * ( 2 * 1 + 1 )
    endif

    GotoBufferId( primeBufSave )
    return( dCount )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer n
    integer dSq
    integer numSolutions
    string  sAnswer[20]

    BuildPrimeSieve()

    n = 1
    numSolutions = 0

    while numSolutions <= 1000
        n = n + 1
        dSq          = CountDivisorsNSquared( n )
        numSolutions = ( dSq + 1 ) / 2
    endwhile

    gAnswerG = n
    sAnswer  = Str( gAnswerG )

    CopyToWinClip( sAnswer )
    Warn( "Project Euler Problem 108" + Chr(13) +
          "Diophantine Reciprocals I"  + Chr(13) +
          "Least n with > 1000 distinct solutions:" + Chr(13) +
          sAnswer )
end
