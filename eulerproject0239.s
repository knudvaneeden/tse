// eulerproject0239.s
// Project Euler Problem 239 - Twenty-two Foolish Primes
// Version 1
// Created by: Claude
//
// History:
// v1 - Claude - Initial version
//
// Problem: 100 discs, 25 primes <= 100.
// Probability exactly 22 primes are NOT in their natural position.
// Non-primes may be anywhere.
//
// Formula:
//   P = C(25,3) * IE / 100!
//   IE = sum_{k=0}^{22} (-1)^k * C(22,k) * (97-k)!
//   (fix 3 primes in place; inclusion-exclusion ensures 22 primes are deranged
//    among 97 remaining positions; non-primes fill remaining spots freely)
//
// All big-integer arithmetic in pure TSE SAL.
// Final result by long division to 12 decimal places.

// ============================================================
// BigAdd: add two unsigned big-int strings
// ============================================================
string proc BigAdd( string aS, string bS )
    integer lenA, lenB, lenMax
    integer carry, da, db, sm, i
    string resS[255]
    lenA = Length( aS )
    lenB = Length( bS )
    if lenA > lenB
        lenMax = lenA
    else
        lenMax = lenB
    endif
    carry = 0
    resS = ""
    for i = 0 to lenMax - 1
        if i < lenA
            da = Asc( SubStr( aS, lenA - i, 1 ) ) - 48
        else
            da = 0
        endif
        if i < lenB
            db = Asc( SubStr( bS, lenB - i, 1 ) ) - 48
        else
            db = 0
        endif
        sm = da + db + carry
        carry = sm / 10
        sm = sm mod 10
        resS = Chr( sm + 48 ) + resS
    endfor
    if carry > 0
        resS = Chr( carry + 48 ) + resS
    endif
    if Length( resS ) == 0
        resS = "0"
    endif
    return( resS )
end

// ============================================================
// BigSub: aS - bS, assumes aS >= bS (unsigned)
// ============================================================
string proc BigSub( string aS, string bS )
    integer lenA, lenB
    integer borrow, da, db, diff, i
    string resS[255]
    lenA = Length( aS )
    lenB = Length( bS )
    borrow = 0
    resS = ""
    for i = 0 to lenA - 1
        da = Asc( SubStr( aS, lenA - i, 1 ) ) - 48
        if i < lenB
            db = Asc( SubStr( bS, lenB - i, 1 ) ) - 48
        else
            db = 0
        endif
        diff = da - db - borrow
        if diff < 0
            diff = diff + 10
            borrow = 1
        else
            borrow = 0
        endif
        resS = Chr( diff + 48 ) + resS
    endfor
    while Length( resS ) > 1 and SubStr( resS, 1, 1 ) == "0"
        resS = SubStr( resS, 2, Length( resS ) - 1 )
    endwhile
    if Length( resS ) == 0
        resS = "0"
    endif
    return( resS )
end

// ============================================================
// BigCmp: compare two unsigned big-int strings
// returns -1, 0, or 1
// ============================================================
integer proc BigCmp( string aS, string bS )
    integer lenA, lenB, i
    string ca[1], cb[1]
    lenA = Length( aS )
    lenB = Length( bS )
    if lenA < lenB
        return( -1 )
    endif
    if lenA > lenB
        return( 1 )
    endif
    for i = 1 to lenA
        ca = SubStr( aS, i, 1 )
        cb = SubStr( bS, i, 1 )
        if ca < cb
            return( -1 )
        elseif ca > cb
            return( 1 )
        endif
    endfor
    return( 0 )
end

// ============================================================
// BigMulInt: multiply big-int string by small integer n
// ============================================================
string proc BigMulInt( string aS, integer n )
    integer lenA, carry, da, prod, i
    string resS[255]
    if n == 0
        return( "0" )
    endif
    lenA = Length( aS )
    carry = 0
    resS = ""
    for i = lenA downto 1
        da = Asc( SubStr( aS, i, 1 ) ) - 48
        prod = da * n + carry
        carry = prod / 10
        prod = prod mod 10
        resS = Chr( prod + 48 ) + resS
    endfor
    while carry > 0
        resS = Chr( (carry mod 10) + 48 ) + resS
        carry = carry / 10
    endwhile
    if Length( resS ) == 0
        resS = "0"
    endif
    return( resS )
end

// ============================================================
// BigFact: compute n! as big-int string
// ============================================================
string proc BigFact( integer n )
    integer i
    string resS[255]
    resS = "1"
    for i = 2 to n
        resS = BigMulInt( resS, i )
    endfor
    return( resS )
end

// ============================================================
// BigMul10: multiply big-int string by 10
// ============================================================
string proc BigMul10( string aS )
    if aS == "0"
        return( "0" )
    endif
    return( aS + "0" )
end

// ============================================================
// BigLongDiv: compute num/den to nDigits decimal places
// Assumes num < den (result is 0.something)
// Returns "0.dddddddddddd"
// ============================================================
string proc BigLongDiv( string numS, string denS, integer nDigits )
    string resultS[255]
    string remS[255]
    string tmpS[255]
    integer digit, i, d
    remS = numS
    resultS = "0."
    for i = 1 to nDigits
        remS = BigMul10( remS )
        digit = 0
        for d = 9 downto 0
            tmpS = BigMulInt( denS, d )
            if BigCmp( tmpS, remS ) <= 0
                digit = d
                goto FoundD
            endif
        endfor
        FoundD:
        resultS = resultS + Chr( digit + 48 )
        tmpS = BigMulInt( denS, digit )
        remS = BigSub( remS, tmpS )
    endfor
    return( resultS )
end

// ============================================================
// BinomInt: compute C(n,k) as integer (n,k small)
// ============================================================
integer proc BinomInt( integer n, integer k )
    integer i, res
    if k > n - k
        k = n - k
    endif
    res = 1
    for i = 0 to k - 1
        res = res * (n - i) / (i + 1)
    endfor
    return( res )
end

// ============================================================
// Main
// ============================================================
proc Main()
    integer k
    string termS[255]
    string factS[255]
    string posS[255]
    string negS[255]
    string ieS[255]
    string numS[255]
    string denS[255]
    string ansS[255]
    string digit13S[1]
    integer d13, lastPos, lastDig

    // IE = sum_{k=0}^{22} (-1)^k * C(22,k) * (97-k)!
    // Positive terms: k even; Negative terms: k odd
    posS = "0"
    negS = "0"
    for k = 0 to 22
        factS = BigFact( 97 - k )
        termS = BigMulInt( factS, BinomInt( 22, k ) )
        if (k mod 2) == 0
            posS = BigAdd( posS, termS )
        else
            negS = BigAdd( negS, termS )
        endif
    endfor
    ieS = BigSub( posS, negS )

    // numerator = C(25,3) * IE = 2300 * IE
    numS = BigMulInt( ieS, 2300 )

    // denominator = 100!
    denS = BigFact( 100 )

    // long division to 14 places, then round to 12
    ansS = BigLongDiv( numS, denS, 14 )

    // Round to 12 decimal places
    // ansS = "0." + 14 digits, length = 16
    // keep positions 1..14 ("0." + 12 digits), check position 15 for rounding
    digit13S = SubStr( ansS, 15, 1 )
    d13 = Asc( digit13S ) - 48
    ansS = SubStr( ansS, 1, 14 )
    if d13 >= 5
        lastPos = Length( ansS )
        lastDig = Asc( SubStr( ansS, lastPos, 1 ) ) - 48
        lastDig = lastDig + 1
        ansS = SubStr( ansS, 1, lastPos - 1 ) + Chr( lastDig + 48 )
    endif

    CopyToWinClip( ansS )
    Warn( "Project Euler 239 answer:" + Chr(13) + ansS )
    CopyToWinClip( ansS )
end
