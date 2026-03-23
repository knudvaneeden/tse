// Project Euler - Problem 180 - Golden Triplets
// <version>1.0.0.0.2</version>
// Created by: Claude (Anthropic) claude-sonnet-4-6
//
// History:
//   1.0.0.0.1  2025-03-24  Claude (Anthropic) claude-sonnet-4-6  Initial version
//   1.0.0.0.2  2025-03-24  Claude (Anthropic) claude-sonnet-4-6  Fix: SAL string params
//                           are read-only constants; copy to local vars in FNBigGcdS
//
// Problem summary:
//   fn(x,y,z) = (x^n + y^n - z^n)(x+y+z)  [after algebraic simplification]
//   fn = 0 iff x^n + y^n = z^n  (since x,y,z > 0)
//   Valid integer n: 1, -1, 2, -2  (FLT rules out |n|>=3 for rationals)
//   Find sum t=u/v of all distinct s(x,y,z)=x+y+z for golden triples of order 35.
//   Answer = u + v.
//
// Big-integer representation: plain decimal strings, no leading zeros.
// All fractions kept in reduced form.

// ============================================================
// FORWARD declarations
// ============================================================
forward integer proc FNGcdI( integer aI, integer bI )
forward string  proc FNBigMulSmallS( string bigS, integer smallI )
forward string  proc FNBigAddS( string aS, string bS )
forward string  proc FNBigSubS( string aS, string bS )
forward integer proc FNBigCmpI( string aS, string bS )
forward string  proc FNBigModBigS( string aS, string bS )
forward string  proc FNBigDivSmallS( string bigS, integer nI )
forward string  proc FNBigGcdS( string aS, string bS )
forward integer proc FNISqrtI( integer nI )

// ============================================================
// GCD of two 32-bit integers (Euclidean)
// ============================================================
integer proc FNGcdI( integer aI, integer bI )
    integer rI
    //
    while bI <> 0
        rI = aI mod bI
        aI = bI
        bI = rI
    endwhile
    return( aI )
end

// ============================================================
// Integer square root (returns floor(sqrt(n)))
// ============================================================
integer proc FNISqrtI( integer nI )
    integer xI
    integer x1I
    //
    if nI <= 0
        return( 0 )
    endif
    xI = nI
    x1I = ( xI + 1 ) / 2
    while x1I < xI
        xI = x1I
        x1I = ( xI + nI / xI ) / 2
    endwhile
    return( xI )
end

// ============================================================
// BigMulSmall: multiply big-integer string by small 32-bit int
// Returns result string (no leading zeros)
// ============================================================
string proc FNBigMulSmallS( string bigS, integer smallI )
    integer lenI
    integer iI
    integer carryI
    integer dI
    integer prodI
    string  resultS[255]
    string  charS[4]
    //
    if smallI == 0
        return( "0" )
    endif
    lenI   = Length( bigS )
    carryI = 0
    resultS = ""
    iI = lenI
    while iI >= 1
        dI      = Val( SubStr( bigS, iI, 1 ) )
        prodI   = dI * smallI + carryI
        carryI  = prodI / 10
        charS   = Str( prodI mod 10 )
        resultS = charS + resultS
        iI = iI - 1
    endwhile
    while carryI > 0
        charS   = Str( carryI mod 10 )
        resultS = charS + resultS
        carryI  = carryI / 10
    endwhile
    // Strip leading zeros
    while Length( resultS ) > 1 and SubStr( resultS, 1, 1 ) == "0"
        resultS = SubStr( resultS, 2, Length( resultS ) - 1 )
    endwhile
    return( resultS )
end

// ============================================================
// BigAdd: add two non-negative big-integer strings
// ============================================================
string proc FNBigAddS( string aS, string bS )
    integer laI
    integer lbI
    integer iI
    integer jaI
    integer jbI
    integer carryI
    integer sumI
    string  resultS[255]
    string  charS[4]
    //
    laI = Length( aS )
    lbI = Length( bS )
    carryI  = 0
    resultS = ""
    iI = 1
    while iI <= laI or iI <= lbI or carryI > 0
        jaI = 0
        jbI = 0
        if iI <= laI
            jaI = Val( SubStr( aS, laI - iI + 1, 1 ) )
        endif
        if iI <= lbI
            jbI = Val( SubStr( bS, lbI - iI + 1, 1 ) )
        endif
        sumI    = jaI + jbI + carryI
        carryI  = sumI / 10
        charS   = Str( sumI mod 10 )
        resultS = charS + resultS
        iI = iI + 1
    endwhile
    if Length( resultS ) == 0
        resultS = "0"
    endif
    return( resultS )
end

// ============================================================
// BigSub: subtract b from a  (a >= b assumed, both non-negative)
// ============================================================
string proc FNBigSubS( string aS, string bS )
    integer laI
    integer lbI
    integer iI
    integer daI
    integer dbI
    integer borrowI
    integer diffI
    string  resultS[255]
    string  charS[4]
    //
    laI = Length( aS )
    lbI = Length( bS )
    borrowI = 0
    resultS = ""
    iI = 1
    while iI <= laI
        daI = Val( SubStr( aS, laI - iI + 1, 1 ) )
        dbI = 0
        if iI <= lbI
            dbI = Val( SubStr( bS, lbI - iI + 1, 1 ) )
        endif
        diffI = daI - dbI - borrowI
        if diffI < 0
            diffI   = diffI + 10
            borrowI = 1
        else
            borrowI = 0
        endif
        charS   = Str( diffI )
        resultS = charS + resultS
        iI = iI + 1
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

// ============================================================
// BigCmp: compare two non-negative big-integer strings
// Returns: 1 if a>b, -1 if a<b, 0 if a==b
// ============================================================
integer proc FNBigCmpI( string aS, string bS )
    integer laI
    integer lbI
    integer iI
    integer daI
    integer dbI
    //
    laI = Length( aS )
    lbI = Length( bS )
    if laI > lbI
        return( 1 )
    endif
    if laI < lbI
        return( -1 )
    endif
    // Same length: compare digit by digit from left
    iI = 1
    while iI <= laI
        daI = Val( SubStr( aS, iI, 1 ) )
        dbI = Val( SubStr( bS, iI, 1 ) )
        if daI > dbI
            return( 1 )
        endif
        if daI < dbI
            return( -1 )
        endif
        iI = iI + 1
    endwhile
    return( 0 )
end

// ============================================================
// BigModBig: compute a mod b  (a,b non-negative, b>0)
// Uses quotient estimation: q = a // b, then remainder = a - q*b
// The quotient is always <= 3948 in our problem, fitting in 32-bit.
// ============================================================
string proc FNBigModBigS( string aS, string bS )
    integer laI
    integer lbI
    integer diffI
    integer a9I
    integer b9I
    integer pow10I
    integer kI
    integer qI
    string  prodS[255]
    string  prodPlusBufS[255]
    //
    // If a < b, remainder is a
    if FNBigCmpI( aS, bS ) < 0
        return( aS )
    endif
    if aS == bS
        return( "0" )
    endif
    laI = Length( aS )
    lbI = Length( bS )
    diffI = laI - lbI
    // Extract up to 9 leading digits of a
    if laI >= 9
        a9I = Val( LeftStr( aS, 9 ) )
    else
        a9I = Val( aS )
    endif
    // Extract up to 9 leading digits of b
    if lbI >= 9
        b9I = Val( LeftStr( bS, 9 ) )
    else
        b9I = Val( bS )
    endif
    // Compute 10^diffI (diffI <= 4 in our problem, safe)
    pow10I = 1
    kI = 0
    while kI < diffI
        pow10I = pow10I * 10
        kI = kI + 1
    endwhile
    // Estimate quotient
    qI = ( a9I * pow10I ) / b9I
    if qI < 0
        qI = 0
    endif
    // Compute q * b
    prodS = FNBigMulSmallS( bS, qI )
    // Adjust down if prod > a
    while FNBigCmpI( prodS, aS ) > 0
        qI    = qI - 1
        prodS = FNBigMulSmallS( bS, qI )
    endwhile
    // Adjust up if (q+1)*b <= a
    prodPlusBufS = FNBigAddS( prodS, bS )
    while FNBigCmpI( prodPlusBufS, aS ) <= 0
        qI           = qI + 1
        prodS        = prodPlusBufS
        prodPlusBufS = FNBigAddS( prodS, bS )
    endwhile
    // Remainder
    return( FNBigSubS( aS, prodS ) )
end

// ============================================================
// BigDivSmall: divide big integer string by small integer,
// returns quotient string (integer division, no remainder)
// ============================================================
string proc FNBigDivSmallS( string bigS, integer nI )
    integer lenI
    integer iI
    integer carryI
    integer digitI
    integer quotDigI
    string  resultS[255]
    string  charS[4]
    //
    lenI    = Length( bigS )
    carryI  = 0
    resultS = ""
    iI = 1
    while iI <= lenI
        digitI   = carryI * 10 + Val( SubStr( bigS, iI, 1 ) )
        quotDigI = digitI / nI
        carryI   = digitI mod nI
        charS    = Str( quotDigI )
        resultS  = resultS + charS
        iI = iI + 1
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

// ============================================================
// BigGcd: GCD of two non-negative big-integer strings
// Uses Euclidean algorithm; once values fit in 32-bit, uses FNGcdI.
// ============================================================
string proc FNBigGcdS( string aS, string bS )
    integer aI
    integer bI
    integer gI
    string  tmpS[255]
    string  curAS[255]
    string  curBS[255]
    //
    // SAL string parameters are read-only: copy to local working vars
    curAS = aS
    curBS = bS
    //
    if curBS == "0"
        return( curAS )
    endif
    if curAS == "0"
        return( curBS )
    endif
    // Reduce using BigModBig until both fit in 9 digits (32-bit range)
    while Length( curAS ) > 9 or Length( curBS ) > 9
        if curBS == "0"
            return( curAS )
        endif
        tmpS  = FNBigModBigS( curAS, curBS )
        curAS = curBS
        curBS = tmpS
    endwhile
    // Both fit in 32-bit now; use integer GCD
    aI = Val( curAS )
    bI = Val( curBS )
    gI = FNGcdI( aI, bI )
    return( Str( gI ) )
end

// ============================================================
// MAIN
// ============================================================
proc Main()
    // Working buffers
    integer fracBufI
    integer sBufI
    // Loop variables
    integer iI
    integer jI
    integer numFracsI
    // Fraction components for x, y, z
    integer xnI
    integer xdI
    integer ynI
    integer ydI
    integer znI
    integer zdI
    // Temporaries for z computation
    integer znRawI
    integer zdRawI
    integer gI
    integer caseI
    // c2 for n=2 and n=-2
    integer c2sqI
    integer c2I
    // s fraction components
    integer snI
    integer sdI
    // String for buffer entry
    string  entryS[32]
    // Big-integer accumulators for running sum
    string  sumNumS[255]
    string  sumDenS[255]
    // Temporaries for fraction addition
    string  newNumS[255]
    string  newDenS[255]
    string  gS[255]
    string  snStrS[32]
    string  sdStrS[32]
    // Final answer
    string  resultS[255]
    //
    // --------------------------------------------------------
    // Step 1: Generate all reduced fractions a/b, 0<a<b<=35
    // Store in fracBuf, one line per fraction: "a b"
    // --------------------------------------------------------
    fracBufI = CreateTempBuffer()
    GotoBufferId( fracBufI )
    //
    iI = 2
    while iI <= 35
        jI = 1
        while jI < iI
            gI = FNGcdI( jI, iI )
            if gI == 1
                AddLine( Format( jI ) + " " + Format( iI ) )
            endif
            jI = jI + 1
        endwhile
        iI = iI + 1
    endwhile
    numFracsI = NumLines()
    //
    // --------------------------------------------------------
    // Step 2: For each pair (i,j) with i<=j, try 4 n-cases
    // Collect distinct s = x+y+z values into sBuf
    // --------------------------------------------------------
    sBufI = CreateTempBuffer()
    //
    iI = 1
    while iI <= numFracsI
        GotoBufferId( fracBufI )
        GotoLine( iI )
        xnI = Val( GetToken( GetText( 1, CurrLineLen() ), " ", 1 ) )
        xdI = Val( GetToken( GetText( 1, CurrLineLen() ), " ", 2 ) )
        //
        jI = iI
        while jI <= numFracsI
            GotoBufferId( fracBufI )
            GotoLine( jI )
            ynI = Val( GetToken( GetText( 1, CurrLineLen() ), " ", 1 ) )
            ydI = Val( GetToken( GetText( 1, CurrLineLen() ), " ", 2 ) )
            //
            // -- Case 0: n=1, z = x+y  (z_n = xn*yd+yn*xd, z_d = xd*yd) --
            znRawI = xnI * ydI + ynI * xdI
            zdRawI = xdI * ydI
            gI = FNGcdI( znRawI, zdRawI )
            znI = znRawI / gI
            zdI = zdRawI / gI
            if zdI <= 35 and znI > 0 and znI < zdI
                // s = x+y+z = (xn*yd*zd + yn*xd*zd + zn*xd*yd) / (xd*yd*zd)
                snI = xnI * ydI * zdI + ynI * xdI * zdI + znI * xdI * ydI
                sdI = xdI * ydI * zdI
                gI  = FNGcdI( snI, sdI )
                snI = snI / gI
                sdI = sdI / gI
                GotoBufferId( sBufI )
                AddLine( Format( snI:6:"0" ) + "/" + Format( sdI:6:"0" ) )
            endif
            //
            // -- Case 1: n=-1, z = xy/(x+y)  (zn=xn*yn, zd=xn*yd+yn*xd) --
            znRawI = xnI * ynI
            zdRawI = xnI * ydI + ynI * xdI
            gI = FNGcdI( znRawI, zdRawI )
            znI = znRawI / gI
            zdI = zdRawI / gI
            if zdI <= 35 and znI > 0 and znI < zdI
                snI = xnI * ydI * zdI + ynI * xdI * zdI + znI * xdI * ydI
                sdI = xdI * ydI * zdI
                gI  = FNGcdI( snI, sdI )
                snI = snI / gI
                sdI = sdI / gI
                GotoBufferId( sBufI )
                AddLine( Format( snI:6:"0" ) + "/" + Format( sdI:6:"0" ) )
            endif
            //
            // -- Case 2: n=2, z=sqrt(x^2+y^2) --
            // z^2 = (xn*yd)^2 + (yn*xd)^2  over (xd*yd)^2
            c2sqI = ( xnI * ydI ) * ( xnI * ydI ) + ( ynI * xdI ) * ( ynI * xdI )
            c2I   = FNISqrtI( c2sqI )
            if c2I * c2I == c2sqI
                gI  = FNGcdI( c2I, xdI * ydI )
                znI = c2I / gI
                zdI = ( xdI * ydI ) / gI
                if zdI <= 35 and znI > 0 and znI < zdI
                    snI = xnI * ydI * zdI + ynI * xdI * zdI + znI * xdI * ydI
                    sdI = xdI * ydI * zdI
                    gI  = FNGcdI( snI, sdI )
                    snI = snI / gI
                    sdI = sdI / gI
                    GotoBufferId( sBufI )
                    AddLine( Format( snI:6:"0" ) + "/" + Format( sdI:6:"0" ) )
                endif
            endif
            //
            // -- Case 3: n=-2, z=xy/sqrt(x^2+y^2) --
            // z_n = xn*yn,  z_d = sqrt((xn*yd)^2+(yn*xd)^2)
            c2sqI = ( xnI * ydI ) * ( xnI * ydI ) + ( ynI * xdI ) * ( ynI * xdI )
            c2I   = FNISqrtI( c2sqI )
            if c2I * c2I == c2sqI and c2I > 0
                gI  = FNGcdI( xnI * ynI, c2I )
                znI = ( xnI * ynI ) / gI
                zdI = c2I / gI
                if zdI <= 35 and znI > 0 and znI < zdI
                    snI = xnI * ydI * zdI + ynI * xdI * zdI + znI * xdI * ydI
                    sdI = xdI * ydI * zdI
                    gI  = FNGcdI( snI, sdI )
                    snI = snI / gI
                    sdI = sdI / gI
                    GotoBufferId( sBufI )
                    AddLine( Format( snI:6:"0" ) + "/" + Format( sdI:6:"0" ) )
                endif
            endif
            //
            jI = jI + 1
        endwhile
        iI = iI + 1
    endwhile
    //
    // --------------------------------------------------------
    // Step 3: Sort and deduplicate sBuf
    // ExecMacro "sort -k" sorts the marked block and removes duplicates
    // --------------------------------------------------------
    GotoBufferId( sBufI )
    BegFile()
    MarkLine()
    GotoLine( NumLines() )
    MarkLine()
    ExecMacro( "sort -k" )
    UnMarkBlock()
    //
    // --------------------------------------------------------
    // Step 4: Sum all distinct s values using big-integer arithmetic
    // t = sum_num / sum_den  (kept reduced)
    // --------------------------------------------------------
    sumNumS = "0"
    sumDenS = "1"
    //
    GotoBufferId( sBufI )
    BegFile()
    iI = 1
    while iI <= NumLines()
        GotoLine( iI )
        entryS = GetText( 1, CurrLineLen() )
        // Parse "NNNNNN/DDDDDD"
        snI = Val( GetToken( entryS, "/", 1 ) )
        sdI = Val( GetToken( entryS, "/", 2 ) )
        snStrS = Str( snI )
        sdStrS = Str( sdI )
        //
        // new_num = sum_num * sd + sn * sum_den
        // new_den = sum_den * sd
        newNumS = FNBigAddS(
                      FNBigMulSmallS( sumNumS, sdI ),
                      FNBigMulSmallS( sumDenS, snI )
                  )
        newDenS = FNBigMulSmallS( sumDenS, sdI )
        // Reduce by GCD
        gS      = FNBigGcdS( newNumS, newDenS )
        if gS <> "1"
            if Length( gS ) <= 9
                gI      = Val( gS )
                sumNumS = FNBigDivSmallS( newNumS, gI )
                sumDenS = FNBigDivSmallS( newDenS, gI )
            else
                // GCD too big for 32-bit (shouldn't happen in this problem)
                sumNumS = FNBigDivSmallS( newNumS, Val( LeftStr( gS, 9 ) ) )
                sumDenS = FNBigDivSmallS( newDenS, Val( LeftStr( gS, 9 ) ) )
            endif
        else
            sumNumS = newNumS
            sumDenS = newDenS
        endif
        //
        iI = iI + 1
    endwhile
    //
    // --------------------------------------------------------
    // Step 5: Compute u + v = sumNum + sumDen  (big int addition)
    // --------------------------------------------------------
    resultS = FNBigAddS( sumNumS, sumDenS )
    //
    // --------------------------------------------------------
    // Clean up buffers
    // --------------------------------------------------------
    AbandonFile( fracBufI )
    AbandonFile( sBufI )
    //
    // --------------------------------------------------------
    // Step 6: Output result
    // --------------------------------------------------------
    CopyToWinClip( resultS )
    Warn( "Project Euler 180 - Golden Triplets" + Chr(13) +
          "t = " + sumNumS + " / " + sumDenS + Chr(13) +
          "Answer u+v = " + resultS )
    CopyToWinClip( resultS )
end
