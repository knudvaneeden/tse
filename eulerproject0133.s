// p133.s
// Project Euler Problem 133 - Repunit Nonfactors
//
// A repunit R(k) consists of k ones.  We examine R(10^n) for all n >= 1.
// Find the sum of all primes p < 100000 that will NEVER be a factor of
// R(10^n) for any n >= 1.
//
// Mathematical background:
//   R(k) = (10^k - 1) / 9
//   p | R(k)  iff  p | (10^k-1)/9
//   When gcd(p,9) = 1 (i.e. p /= 3): this simplifies to ord_p(10) | k.
//   So p | R(10^n) for some n  iff  ord_p(10) divides 10^n = 2^n*5^n,
//   which happens iff ord_p(10) is of the form 2^a * 5^b.
//
//   Special nonfactors handled directly:
//     p = 2 : repunits are all odd (digit sum is k, last digit 1). 2 never divides R(k).
//     p = 3 : R(k) mod 3 = k mod 3 (digit sum).  R(10^n) mod 3 = 10^n mod 3 = 1.
//             So 3 never divides R(10^n).  (The ord_p formula breaks for p=3 since
//             gcd(3,9)=3 /= 1; handled as explicit special case.)
//     p = 5 : last digit of R(k) is always 1, never 0 or 5.  5 never divides R(k).
//
//   For all primes p not in {2, 3, 5}:  gcd(p,9)=1, so use the order criterion:
//     Compute ord_p(10) via divisor-based reduction on p-1 (Fermat's little theorem).
//     If ord_p(10) is NOT purely 2^a*5^b -> p is a nonfactor -> add to sum.
//
// Verification against the problem statement:
//   Primes < 100 that CAN be a factor of R(10^n): 11, 17, 41, 73 (exactly as stated).
//
// Order computation algorithm:
//   ord = p - 1
//   For each distinct prime factor q of (p-1):
//     while (ord mod q == 0) and PowerMod(10, ord/q, p) == 1:
//       ord = ord / q
//
// Overflow safety:
//   p < 100000 -> intermediate PowerMod products up to ~10^10 > 2^31.
//   We use MulMod (binary doubling / Russian-peasant) to avoid overflow.
//
// Expected answer: 453647705
//
// Created by: Claude (Anthropic claude-sonnet-4-6)
// <version>1.0.0.0.1</version>
//
// Output: Warn() box with the answer.
//         CopyToWinClip() copies ONLY the numeric answer.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Forward declarations
// ---------------------------------------------------------------------------
forward integer proc IsPrime( integer nI )
forward integer proc MulMod( integer aI, integer bI, integer mI )
forward integer proc PowerMod( integer baseI, integer expI, integer modI )
forward integer proc OrderOf10( integer pI )
forward integer proc IsPurelyTwoFive( integer nI )

// ---------------------------------------------------------------------------
// Global: sieve buffer id
// ---------------------------------------------------------------------------
integer gSieveBufI = 0

// ---------------------------------------------------------------------------
// BuildSieve
//   Creates temp buffer gSieveBufI.
//   Line (k+1) holds "1" if k is prime, "0" otherwise.
//   Covers numbers 0 .. limitI inclusive.
// ---------------------------------------------------------------------------
proc BuildSieve( integer limitI )
    //
    integer iI = 0
    integer jI = 0
    //
    gSieveBufI = CreateTempBuffer()
    GotoBufferId( gSieveBufI )
    //
    AddLine( "0" )   // line 1 -> number 0 (not prime)
    AddLine( "0" )   // line 2 -> number 1 (not prime)
    iI = 2
    while iI <= limitI
        AddLine( "1" )
        iI = iI + 1
    endwhile
    //
    iI = 2
    while iI * iI <= limitI
        GotoLine( iI + 1 )
        if GetText( 1, 1 ) == "1"
            jI = iI * iI
            while jI <= limitI
                GotoLine( jI + 1 )
                BegLine()
                KillToEol()
                InsertText( "0" )
                jI = jI + iI
            endwhile
        endif
        iI = iI + 1
    endwhile
end

// ---------------------------------------------------------------------------
// IsPrime
//   Returns 1 if nI is prime (sieve lookup), else 0.
// ---------------------------------------------------------------------------
integer proc IsPrime( integer nI )
    //
    integer savedI  = 0
    integer retI    = 0
    string  chS[2]  = ""
    //
    if nI < 2
        return( 0 )
    endif
    savedI = GetBufferId()
    GotoBufferId( gSieveBufI )
    GotoLine( nI + 1 )
    chS = GetText( 1, 1 )
    if chS == "1"
        retI = 1
    else
        retI = 0
    endif
    GotoBufferId( savedI )
    return( retI )
end

// ---------------------------------------------------------------------------
// MulMod
//   Computes (aI * bI) mod mI safely via binary doubling (Russian-peasant).
//   Prevents 32-bit overflow when aI, bI can reach ~100000.
// ---------------------------------------------------------------------------
integer proc MulMod( integer aI, integer bI, integer mI )
    //
    integer resultI = 0
    integer xI      = 0
    integer yI      = 0
    //
    xI      = aI mod mI
    yI      = bI
    resultI = 0
    while yI > 0
        if ( yI & 1 ) == 1
            resultI = ( resultI + xI ) mod mI
        endif
        xI = ( xI + xI ) mod mI
        yI = yI shr 1
    endwhile
    return( resultI )
end

// ---------------------------------------------------------------------------
// PowerMod
//   Computes (baseI ^ expI) mod modI via binary exponentiation.
//   Uses MulMod for overflow-safe multiplications.
// ---------------------------------------------------------------------------
integer proc PowerMod( integer baseI, integer expI, integer modI )
    //
    integer resultI = 1
    integer bI      = 0
    integer eI      = 0
    //
    if modI == 1
        return( 0 )
    endif
    bI = baseI mod modI
    eI = expI
    while eI > 0
        if ( eI & 1 ) == 1
            resultI = MulMod( resultI, bI, modI )
        endif
        bI = MulMod( bI, bI, modI )
        eI = eI shr 1
    endwhile
    return( resultI )
end

// ---------------------------------------------------------------------------
// OrderOf10
//   Multiplicative order of 10 modulo pI (the smallest k>0 with 10^k=1 mod pI).
//   Pre-condition: pI is prime, pI not in {2, 3, 5} so gcd(10,pI)=1.
//
//   Algorithm:
//     Start with ord = p-1 (valid by Fermat's little theorem).
//     Collect distinct prime factors of (p-1) into a temp buffer.
//     For each such factor q:
//       while ord divisible by q AND 10^(ord/q) = 1 mod p:
//         ord = ord / q
//     Return ord.
// ---------------------------------------------------------------------------
integer proc OrderOf10( integer pI )
    //
    integer ordI      = 0
    integer rI        = 0
    integer dI        = 0
    integer qI        = 0
    integer nFactI    = 0
    integer kI        = 0
    integer doneB     = 0
    integer factBufI  = 0
    integer savedI    = 0
    string  lineS[20] = ""
    //
    savedI   = GetBufferId()
    ordI     = pI - 1
    factBufI = CreateTempBuffer()
    GotoBufferId( factBufI )
    //
    // --- collect distinct prime factors of (pI - 1) ---
    rI = pI - 1
    if ( rI mod 2 ) == 0
        AddLine( "2" )
        while ( rI mod 2 ) == 0
            rI = rI / 2
        endwhile
    endif
    dI = 3
    while dI * dI <= rI
        if ( rI mod dI ) == 0
            AddLine( Str( dI ) )
            while ( rI mod dI ) == 0
                rI = rI / dI
            endwhile
        endif
        dI = dI + 2
    endwhile
    if rI > 1
        AddLine( Str( rI ) )
    endif
    nFactI = NumLines()
    //
    // --- reduce ord by each prime factor ---
    kI = 1
    while kI <= nFactI
        GotoLine( kI )
        lineS = GetText( 1, CurrLineLen() )
        qI    = Val( lineS )
        //
        doneB = FALSE
        while doneB == FALSE
            if ( ordI mod qI ) == 0
                if PowerMod( 10, ordI / qI, pI ) == 1
                    ordI = ordI / qI
                else
                    doneB = TRUE
                endif
            else
                doneB = TRUE
            endif
        endwhile
        //
        kI = kI + 1
    endwhile
    //
    GotoBufferId( savedI )
    AbandonFile( factBufI )
    return( ordI )
end

// ---------------------------------------------------------------------------
// IsPurelyTwoFive
//   Returns 1 if nI == 2^a * 5^b for some a,b >= 0, else 0.
// ---------------------------------------------------------------------------
integer proc IsPurelyTwoFive( integer nI )
    //
    integer rI = nI
    //
    while ( rI mod 2 ) == 0
        rI = rI / 2
    endwhile
    while ( rI mod 5 ) == 0
        rI = rI / 5
    endwhile
    if rI == 1
        return( 1 )
    endif
    return( 0 )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    //
    integer LIMIT    = 100000
    integer pI       = 0
    integer ordI     = 0
    integer sumLoI   = 0
    integer sumHiI   = 0
    integer ansBufI  = 0
    integer savedI   = 0
    string  ansS[30] = ""
    //
    // Build sieve for primality tests
    BuildSieve( LIMIT - 1 )
    //
    // p=2, p=3, p=5 are unconditional nonfactors (see header for proofs).
    // The ord formula requires gcd(p,9)=1 which excludes p=3.
    sumLoI = 2 + 3 + 5   // = 10
    //
    // Check all odd primes p in [7, LIMIT) -- skip 3 (already counted)
    pI = 7
    while pI < LIMIT
        if IsPrime( pI )
            ordI = OrderOf10( pI )
            // If order is NOT purely 2^a*5^b, p can never divide R(10^n)
            if IsPurelyTwoFive( ordI ) == 0
                sumLoI = sumLoI + pI
                if sumLoI >= 1000000000
                    sumLoI = sumLoI - 1000000000
                    sumHiI = sumHiI + 1
                endif
            endif
        endif
        pI = pI + 2
    endwhile
    //
    // Build answer string (handle sums exceeding 10^9)
    if sumHiI > 0
        ansS = Str( sumHiI ) + Format( sumLoI:9:"0" )
    else
        ansS = Str( sumLoI )
    endif
    //
    // Display result
    Warn( "Project Euler #133 - Repunit Nonfactors" + Chr(13) +
          "Sum of primes < 100000 never dividing R(10^n):" + Chr(13) +
          ansS )
    //
    // Copy ONLY the numeric answer to clipboard
    savedI  = GetBufferId()
    ansBufI = CreateTempBuffer()
    GotoBufferId( ansBufI )
    InsertText( ansS )
    MarkLine( 1, 1 )
    CopyToWinClip()
    AbandonFile()
    GotoBufferId( savedI )
end
