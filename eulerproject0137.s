// ===========================================================================
// Project Euler - Problem 137: Fibonacci Golden Nuggets
// ===========================================================================
//
// Problem:
//   Consider A_F(x) = x*F1 + x^2*F2 + x^3*F3 + ...
//   where F_k is the k-th Fibonacci number (1,1,2,3,5,8,...).
//   A golden nugget is a positive integer value of A_F(x) where x is rational.
//   Find the 15th golden nugget.
//
// Mathematical derivation:
//   The closed form is A_F(x) = x / (1 - x - x^2).
//   Setting A_F(x) = n gives: n*x^2 + (n+1)*x - n = 0.
//   The discriminant is 5n^2 + 2n + 1, which must be a perfect square
//   for x to be rational.
//
//   Golden nuggets satisfy the linear recurrence:
//     g(k) = 7*g(k-1) - g(k-2) + 1
//   with g(1) = 2, g(2) = 15.
//
//   Verified: g(3)=104, g(4)=714, g(5)=4895, ..., g(10)=74049690.
//
//   Since g(15) far exceeds 32-bit integer range, big-integer arithmetic
//   (string-based) is used for the recurrence.
//
// Answer: 1120149658760 (the 15th golden nugget)
//
// Version  : <version>1.0.0.0.1</version>
// Author   : Claude (Anthropic) - AI-generated TSE SAL solution
// LLM      : Claude Sonnet 4.6 (Anthropic) - created this TSE SAL program
// Created  : 2026-03-20
// Language : TSE SAL (SemWare Application Language) for TSE Pro v4.x
// ===========================================================================

// ---------------------------------------------------------------------------
// BigAdd: add two non-negative big integers represented as decimal strings.
// Returns the sum as a decimal string.
// ---------------------------------------------------------------------------
string proc BigAdd( string aS, string bS )
    string  resultS[255]    = ""
    string  digitS[4]       = ""
    integer aLenI           = 0
    integer bLenI           = 0
    integer idxI            = 0
    integer aDigI           = 0
    integer bDigI           = 0
    integer sumI            = 0
    integer carryI          = 0
    //
    aLenI  = Length( aS )
    bLenI  = Length( bS )
    carryI = 0
    resultS = ""
    idxI = 1
    while idxI <= aLenI or idxI <= bLenI or carryI > 0
        aDigI = 0
        bDigI = 0
        if idxI <= aLenI
            aDigI = Asc( SubStr( aS, aLenI - idxI + 1, 1 ) ) - 48
        endif
        if idxI <= bLenI
            bDigI = Asc( SubStr( bS, bLenI - idxI + 1, 1 ) ) - 48
        endif
        sumI   = aDigI + bDigI + carryI
        carryI = sumI / 10
        sumI   = sumI mod 10
        digitS = Chr( sumI + 48 )
        resultS = digitS + resultS
        idxI = idxI + 1
    endwhile
    if Length( resultS ) == 0
        resultS = "0"
    endif
    return( resultS )
end

// ---------------------------------------------------------------------------
// BigMulSmall: multiply a big-integer string by a small integer (fits in 32-bit).
// Returns the product as a decimal string.
// ---------------------------------------------------------------------------
string proc BigMulSmall( string aS, integer multI )
    string  resultS[255]    = ""
    string  digitS[4]       = ""
    integer aLenI           = 0
    integer idxI            = 0
    integer aDigI           = 0
    integer prodI           = 0
    integer carryI          = 0
    //
    if multI == 0
        return( "0" )
    endif
    aLenI   = Length( aS )
    carryI  = 0
    resultS = ""
    idxI = 1
    while idxI <= aLenI or carryI > 0
        aDigI = 0
        if idxI <= aLenI
            aDigI = Asc( SubStr( aS, aLenI - idxI + 1, 1 ) ) - 48
        endif
        prodI  = aDigI * multI + carryI
        carryI = prodI / 10
        prodI  = prodI mod 10
        digitS = Chr( prodI + 48 )
        resultS = digitS + resultS
        idxI = idxI + 1
    endwhile
    if Length( resultS ) == 0
        resultS = "0"
    endif
    return( resultS )
end

// ---------------------------------------------------------------------------
// BigSub: subtract big integer bS from aS (assumes a >= b, both non-negative).
// Returns the difference as a decimal string.
// ---------------------------------------------------------------------------
string proc BigSub( string aS, string bS )
    string  resultS[255]    = ""
    string  digitS[4]       = ""
    integer aLenI           = 0
    integer bLenI           = 0
    integer idxI            = 0
    integer aDigI           = 0
    integer bDigI           = 0
    integer diffI           = 0
    integer borrowI         = 0
    //
    aLenI   = Length( aS )
    bLenI   = Length( bS )
    borrowI = 0
    resultS = ""
    idxI = 1
    while idxI <= aLenI
        aDigI = Asc( SubStr( aS, aLenI - idxI + 1, 1 ) ) - 48
        bDigI = 0
        if idxI <= bLenI
            bDigI = Asc( SubStr( bS, bLenI - idxI + 1, 1 ) ) - 48
        endif
        diffI = aDigI - bDigI - borrowI
        if diffI < 0
            diffI   = diffI + 10
            borrowI = 1
        else
            borrowI = 0
        endif
        digitS  = Chr( diffI + 48 )
        resultS = digitS + resultS
        idxI = idxI + 1
    endwhile
    // Strip leading zeros
    while Length( resultS ) > 1 and SubStr( resultS, 1, 1 ) == "0"
        resultS = SubStr( resultS, 2, Length( resultS ) - 1 )
    endwhile
    if Length( resultS ) == 0
        resultS = "0"
    endif
    return( resultS )
end

// ---------------------------------------------------------------------------
// Main: compute the 15th golden nugget using the recurrence:
//   g(k) = 7*g(k-1) - g(k-2) + 1
//   g(1) = 2, g(2) = 15
// ---------------------------------------------------------------------------
proc Main()
    string  prevPrevS[255]  = ""    // g(k-2)
    string  prevS[255]      = ""    // g(k-1)
    string  currS[255]      = ""    // g(k)
    string  term7S[255]     = ""    // 7 * g(k-1)
    string  resultS[255]    = ""
    string  msgS[255]       = ""
    integer kI              = 0
    //
    // g(1) = 2, g(2) = 15
    prevPrevS = "2"
    prevS     = "15"
    //
    // Iterate from k=3 up to k=15
    kI = 3
    while kI <= 15
        // g(k) = 7*g(k-1) - g(k-2) + 1
        term7S = BigMulSmall( prevS, 7 )
        currS  = BigSub( term7S, prevPrevS )
        currS  = BigAdd( currS, "1" )
        //
        prevPrevS = prevS
        prevS     = currS
        //
        kI = kI + 1
    endwhile
    //
    // prevS now holds g(15) (since after loop kI=16, last assigned prevS = g(15))
    resultS = prevS
    //
    msgS = "Project Euler Problem 137" + Chr(13) +
           "Fibonacci Golden Nuggets" + Chr(13) +
           Chr(13) +
           "The 15th golden nugget is:" + Chr(13) +
           Chr(13) +
           resultS
    //
    CopyToWinClip( resultS )
    Warn( msgS )
end
