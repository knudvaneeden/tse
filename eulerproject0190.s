// Project Euler Problem 190 - Maximising a Weighted Product
// Find sum of floor(Pm) for m = 2 to 15
// where Pm = x1 * x2^2 * ... * xm^m is maximised subject to
// x1 + x2 + ... + xm = m  (all xi positive reals)
//
// By Lagrange multipliers: optimal xk = 2k / (m+1)
// Therefore: Pm = prod(k=1..m) ( 2k/(m+1) )^k
//
// As exact integer fraction:
//   Numerator   = prod(k=1..m) (2k)^k  = 2^Tm * prod(k=1..m) k^k
//   Denominator = (m+1)^Tm
//   where Tm = 1+2+...+m = m*(m+1)/2
//
// Computed entirely in big-integer string arithmetic.
// Answer = sum of floor(Pm) for m = 2 to 15  (= 371048281)
//
// <version>1.0.0.0.1</version>
// Created by: Claude (Anthropic) - claude-sonnet-4-6
// History:
//   1.0.0.0.1  2025-03-24  Initial version by Claude Sonnet 4.6 (Anthropic)
//              Math confirmed: m=10 gives floor(P10)=4112 as per problem statement

// ============================================================
// BigAdd: add two non-negative big-integer strings
// Returns their sum as a string
// ============================================================
string proc BigAdd( string aS, string bS )
    string resultS[255] = ""
    string digitS[4]    = ""
    integer carryI      = 0
    integer aLenI       = 0
    integer bLenI       = 0
    integer maxLenI     = 0
    integer iI          = 0
    integer aDigI       = 0
    integer bDigI       = 0
    integer sumI        = 0
    //
    aLenI   = Length( aS )
    bLenI   = Length( bS )
    maxLenI = iif( aLenI > bLenI, aLenI, bLenI )
    carryI  = 0
    resultS = ""
    //
    for iI = 1 to maxLenI
        if iI <= aLenI
            aDigI = Asc( SubStr( aS, aLenI - iI + 1, 1 ) ) - 48
        else
            aDigI = 0
        endif
        if iI <= bLenI
            bDigI = Asc( SubStr( bS, bLenI - iI + 1, 1 ) ) - 48
        else
            bDigI = 0
        endif
        sumI    = aDigI + bDigI + carryI
        carryI  = sumI / 10
        sumI    = sumI mod 10
        digitS  = Chr( sumI + 48 )
        resultS = digitS + resultS
    endfor
    if carryI > 0
        resultS = Chr( carryI + 48 ) + resultS
    endif
    return( resultS )
end

// ============================================================
// BigMulInt: multiply big-integer string by a small integer
// Returns the product as a string
// ============================================================
string proc BigMulInt( string aS, integer bI )
    string resultS[255] = ""
    string digitS[4]    = ""
    integer carryI      = 0
    integer aLenI       = 0
    integer iI          = 0
    integer aDigI       = 0
    integer prodI       = 0
    //
    if bI == 0
        return( "0" )
    endif
    if bI == 1
        return( aS )
    endif
    aLenI   = Length( aS )
    carryI  = 0
    resultS = ""
    //
    for iI = 1 to aLenI
        aDigI   = Asc( SubStr( aS, aLenI - iI + 1, 1 ) ) - 48
        prodI   = aDigI * bI + carryI
        carryI  = prodI / 10
        prodI   = prodI mod 10
        digitS  = Chr( prodI + 48 )
        resultS = digitS + resultS
    endfor
    while carryI > 0
        digitS  = Chr( ( carryI mod 10 ) + 48 )
        resultS = digitS + resultS
        carryI  = carryI / 10
    endwhile
    return( resultS )
end

// ============================================================
// BigMul: multiply two big-integer strings
// Uses a temp buffer to accumulate column sums, then
// propagates carries and assembles the result string
// ============================================================
string proc BigMul( string aS, string bS )
    string resultS[255] = ""
    string digitS[4]    = ""
    integer aLenI       = 0
    integer bLenI       = 0
    integer nDigitsI    = 0
    integer iI          = 0
    integer jI          = 0
    integer aDigI       = 0
    integer bDigI       = 0
    integer colI        = 0
    integer colValI     = 0
    integer carryI      = 0
    integer bufIdI      = 0
    integer saveIdI     = 0
    //
    if aS == "0" or bS == "0"
        return( "0" )
    endif
    if aS == "1"
        return( bS )
    endif
    if bS == "1"
        return( aS )
    endif
    //
    aLenI    = Length( aS )
    bLenI    = Length( bS )
    nDigitsI = aLenI + bLenI + 1
    //
    saveIdI = GetBufferId()
    bufIdI  = CreateTempBuffer()
    GotoBufferId( bufIdI )
    EmptyBuffer()
    // Seed buffer: one line per output digit position, value "0"
    for iI = 1 to nDigitsI
        InsertText( "0", _INSERT_ )
        AddLine()
    endfor
    //
    // Accumulate partial products into column buffer
    for iI = 1 to aLenI
        aDigI = Asc( SubStr( aS, aLenI - iI + 1, 1 ) ) - 48
        for jI = 1 to bLenI
            bDigI   = Asc( SubStr( bS, bLenI - jI + 1, 1 ) ) - 48
            colI    = iI + jI - 1
            GotoLine( colI )
            colValI = Val( GetText( 1, CurrLineLen() ) )
            colValI = colValI + aDigI * bDigI
            BegLine()
            KillToEol()
            InsertText( Str( colValI ), _INSERT_ )
        endfor
    endfor
    //
    // Propagate carries from least-significant to most-significant column
    carryI = 0
    for iI = 1 to nDigitsI
        GotoLine( iI )
        colValI = Val( GetText( 1, CurrLineLen() ) ) + carryI
        carryI  = colValI / 10
        colValI = colValI mod 10
        BegLine()
        KillToEol()
        InsertText( Str( colValI ), _INSERT_ )
    endfor
    //
    // Assemble result: most-significant digit first, skip leading zeros
    resultS = ""
    for iI = nDigitsI downto 1
        GotoLine( iI )
        digitS = GetText( 1, CurrLineLen() )
        if Length( resultS ) > 0 or Val( digitS ) > 0
            resultS = resultS + digitS
        endif
    endfor
    if Length( resultS ) == 0
        resultS = "0"
    endif
    //
    AbandonFile( bufIdI )
    GotoBufferId( saveIdI )
    return( resultS )
end

// ============================================================
// BigPow: raise big-integer string to a non-negative integer power
// Returns the result as a string
// ============================================================
string proc BigPow( string baseS, integer expI )
    string resultS[255] = "1"
    integer iI          = 0
    //
    if expI == 0
        return( "1" )
    endif
    if expI == 1
        return( baseS )
    endif
    resultS = baseS
    for iI = 2 to expI
        resultS = BigMul( resultS, baseS )
    endfor
    return( resultS )
end

// ============================================================
// BigCmp: compare two non-negative big-integer strings
// Returns: -1 if a < b,   0 if a == b,   1 if a > b
// ============================================================
integer proc BigCmp( string aS, string bS )
    integer aLenI = 0
    integer bLenI = 0
    integer iI    = 0
    integer aDI   = 0
    integer bDI   = 0
    //
    aLenI = Length( aS )
    bLenI = Length( bS )
    if aLenI < bLenI
        return( -1 )
    endif
    if aLenI > bLenI
        return( 1 )
    endif
    for iI = 1 to aLenI
        aDI = Asc( SubStr( aS, iI, 1 ) ) - 48
        bDI = Asc( SubStr( bS, iI, 1 ) ) - 48
        if aDI < bDI
            return( -1 )
        endif
        if aDI > bDI
            return( 1 )
        endif
    endfor
    return( 0 )
end

// ============================================================
// BigSub: subtract bS from aS  (requires a >= b >= 0)
// Returns the difference as a string
// ============================================================
string proc BigSub( string aS, string bS )
    string resultS[255] = ""
    string digitS[4]    = ""
    integer aLenI       = 0
    integer bLenI       = 0
    integer iI          = 0
    integer aDigI       = 0
    integer bDigI       = 0
    integer diffI       = 0
    integer borrowI     = 0
    //
    if aS == bS
        return( "0" )
    endif
    aLenI   = Length( aS )
    bLenI   = Length( bS )
    borrowI = 0
    resultS = ""
    //
    for iI = 1 to aLenI
        aDigI = Asc( SubStr( aS, aLenI - iI + 1, 1 ) ) - 48
        if iI <= bLenI
            bDigI = Asc( SubStr( bS, bLenI - iI + 1, 1 ) ) - 48
        else
            bDigI = 0
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
    endfor
    // Strip leading zeros
    while Length( resultS ) > 1 and SubStr( resultS, 1, 1 ) == "0"
        resultS = SubStr( resultS, 2, Length( resultS ) - 1 )
    endwhile
    return( resultS )
end

// ============================================================
// BigDiv: compute floor( numeratorS / denominatorS )
// Long-division algorithm; returns quotient as string
// ============================================================
string proc BigDiv( string numeratorS, string denominatorS )
    string quotientS[255]  = ""
    string remainderS[255] = "0"
    string digitS[4]       = ""
    string prodS[255]      = ""
    integer numLenI        = 0
    integer iI             = 0
    integer dI             = 0
    integer foundB         = FALSE
    //
    // Quick check: if numerator < denominator, quotient is 0
    if BigCmp( numeratorS, denominatorS ) < 0
        return( "0" )
    endif
    //
    numLenI    = Length( numeratorS )
    remainderS = "0"
    quotientS  = ""
    //
    for iI = 1 to numLenI
        // Bring down the next digit of the numerator
        digitS = SubStr( numeratorS, iI, 1 )
        if remainderS == "0"
            remainderS = digitS
        else
            remainderS = remainderS + digitS
        endif
        // Strip any leading zeros from the running remainder
        while Length( remainderS ) > 1 and SubStr( remainderS, 1, 1 ) == "0"
            remainderS = SubStr( remainderS, 2, Length( remainderS ) - 1 )
        endwhile
        // Find the largest dI in 0..9 such that dI * denominator <= remainder
        // Search from 9 down to 0; stop when product fits
        dI     = 9
        foundB = FALSE
        while foundB == FALSE
            prodS = BigMulInt( denominatorS, dI )
            if BigCmp( prodS, remainderS ) <= 0
                foundB = TRUE
            else
                dI = dI - 1
                if dI < 0
                    dI     = 0
                    foundB = TRUE
                endif
            endif
        endwhile
        // Record quotient digit and subtract from remainder
        quotientS  = quotientS + Chr( dI + 48 )
        prodS      = BigMulInt( denominatorS, dI )
        remainderS = BigSub( remainderS, prodS )
    endfor
    //
    // Strip leading zeros from quotient
    while Length( quotientS ) > 1 and SubStr( quotientS, 1, 1 ) == "0"
        quotientS = SubStr( quotientS, 2, Length( quotientS ) - 1 )
    endwhile
    if Length( quotientS ) == 0
        quotientS = "0"
    endif
    return( quotientS )
end

// ============================================================
// Main
// ============================================================
proc Main()
    string sumS[255]    = "0"
    string numS[255]    = ""
    string denS[255]    = ""
    string floorS[255]  = ""
    string kkS[255]     = ""
    string resultS[255] = ""
    integer mI          = 0
    integer kI          = 0
    integer tmI         = 0
    //
    sumS = "0"
    //
    // Sum floor(Pm) for m = 2 to 15
    for mI = 2 to 15
        tmI = mI * ( mI + 1 ) / 2
        //
        // Numerator = 2^Tm * prod(k=1..m) k^k
        numS = BigPow( "2", tmI )
        for kI = 1 to mI
            kkS  = BigPow( Str( kI ), kI )
            numS = BigMul( numS, kkS )
        endfor
        //
        // Denominator = (m+1)^Tm
        denS = BigPow( Str( mI + 1 ), tmI )
        //
        // floor(Pm) = integer division of num by den
        floorS = BigDiv( numS, denS )
        //
        sumS = BigAdd( sumS, floorS )
    endfor
    //
    resultS = sumS
    //
    CopyToWinClip( resultS )
    Warn( "Project Euler 190 answer: " + resultS )
    CopyToWinClip( resultS )
end
