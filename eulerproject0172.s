// Project Euler - Problem 172: Few Repeated Digits
// How many 18-digit numbers n (without leading zeros) are there
// such that no digit occurs more than three times?
//
// Approach:
//   Enumerate all (c0..c9) with each ci in {0,1,2,3} and sum=18.
//   For each combination count valid 18-digit arrangements:
//     total = 18! / (c0! * c1! * ... * c9!)
//     minus leading-zero fix (when c0 > 0):
//       lz = 17! / ((c0-1)! * c1! * ... * c9!)
//     contribution = total - lz
//   Uses string-based big-integer arithmetic (18! > 32-bit range).
//
// <version>1.0.0.0.1</version>
// <created_by>Claude Sonnet 4.6 (Anthropic)</created_by>
// <history>
//   1.0.0.0.1 - 2026-03-22 - Initial version by Claude Sonnet 4.6
// </history>

// ============================================================
// BigAdd: add two non-negative big-integer strings
// ============================================================
string proc BigAdd( string aS, string bS )
    string  resultS[255]
    string  digitS[4]
    integer aI, bI, sumI, carryI, posI, aLenI, bLenI
    //
    resultS = ""
    carryI  = 0
    aLenI   = Length( aS )
    bLenI   = Length( bS )
    posI    = 0
    //
    while ( posI < aLenI ) or ( posI < bLenI ) or ( carryI > 0 )
        aI = 0
        bI = 0
        if posI < aLenI
            aI = Asc( SubStr( aS, aLenI - posI, 1 ) ) - 48
        endif
        if posI < bLenI
            bI = Asc( SubStr( bS, bLenI - posI, 1 ) ) - 48
        endif
        sumI    = aI + bI + carryI
        carryI  = sumI / 10
        sumI    = sumI mod 10
        digitS  = Chr( sumI + 48 )
        resultS = digitS + resultS
        posI    = posI + 1
    endwhile
    //
    if Length( resultS ) == 0
        resultS = "0"
    endif
    return( resultS )
end

// ============================================================
// BigMulSmall: multiply big-integer string by small integer
// ============================================================
string proc BigMulSmall( string aS, integer bI )
    string  resultS[255]
    string  digitS[4]
    integer carryI, posI, aLenI, prodI, digitI
    //
    if bI == 0
        return( "0" )
    endif
    //
    resultS = ""
    carryI  = 0
    aLenI   = Length( aS )
    posI    = 0
    //
    while ( posI < aLenI ) or ( carryI > 0 )
        digitI = 0
        if posI < aLenI
            digitI = Asc( SubStr( aS, aLenI - posI, 1 ) ) - 48
        endif
        prodI  = digitI * bI + carryI
        carryI = prodI / 10
        prodI  = prodI mod 10
        digitS  = Chr( prodI + 48 )
        resultS = digitS + resultS
        posI    = posI + 1
    endwhile
    //
    if Length( resultS ) == 0
        resultS = "0"
    endif
    return( resultS )
end

// ============================================================
// BigDivSmall: divide big-integer string by small positive integer
//              returns quotient (exact integer division assumed)
// ============================================================
string proc BigDivSmall( string aS, integer bI )
    string  resultS[255]
    string  digitS[4]
    integer remI, posI, aLenI, digitI, quotI
    //
    if bI <= 1
        return( aS )
    endif
    //
    resultS = ""
    remI    = 0
    aLenI   = Length( aS )
    posI    = 1
    //
    while posI <= aLenI
        digitI = Asc( SubStr( aS, posI, 1 ) ) - 48
        quotI  = ( remI * 10 + digitI ) / bI
        remI   = ( remI * 10 + digitI ) mod bI
        if ( Length( resultS ) > 0 ) or ( quotI > 0 )
            digitS  = Chr( quotI + 48 )
            resultS = resultS + digitS
        endif
        posI = posI + 1
    endwhile
    //
    if Length( resultS ) == 0
        resultS = "0"
    endif
    return( resultS )
end

// ============================================================
// BigSubtract: subtract bS from aS (assumes aS >= bS >= "0")
// ============================================================
string proc BigSubtract( string aS, string bS )
    string  resultS[255]
    string  digitS[4]
    integer aLenI, bLenI, posI, aDigI, bDigI, diffI, borrowI
    //
    if bS == "0"
        return( aS )
    endif
    //
    resultS = ""
    borrowI = 0
    aLenI   = Length( aS )
    bLenI   = Length( bS )
    posI    = 0
    //
    while posI < aLenI
        aDigI = Asc( SubStr( aS, aLenI - posI, 1 ) ) - 48
        bDigI = 0
        if posI < bLenI
            bDigI = Asc( SubStr( bS, bLenI - posI, 1 ) ) - 48
        endif
        diffI   = aDigI - bDigI - borrowI
        borrowI = 0
        if diffI < 0
            diffI   = diffI + 10
            borrowI = 1
        endif
        digitS  = Chr( diffI + 48 )
        resultS = digitS + resultS
        posI    = posI + 1
    endwhile
    //
    // Strip leading zeros
    while ( Length( resultS ) > 1 ) and ( SubStr( resultS, 1, 1 ) == "0" )
        resultS = SubStr( resultS, 2, Length( resultS ) - 1 )
    endwhile
    //
    if Length( resultS ) == 0
        resultS = "0"
    endif
    return( resultS )
end

// ============================================================
// DivByFactorial: divide bigS by kI! by dividing by 2,3,...,kI
//                 (for kI=0 or kI=1, no division needed since 0!=1!=1)
// ============================================================
string proc DivByFactorial( string bigS, integer kI )
    string  resS[255]
    integer iI
    //
    resS = bigS
    iI   = 2
    while iI <= kI
        resS = BigDivSmall( resS, iI )
        iI   = iI + 1
    endwhile
    return( resS )
end

// ============================================================
// Main
// ============================================================
proc Main()
    integer factBufI
    integer fI
    string  factS[255]
    string  f18S[255]
    string  f17S[255]
    string  answerS[255]
    string  termS[255]
    string  lzS[255]
    integer c0I, c1I, c2I, c3I, c4I
    integer c5I, c6I, c7I, c8I, c9I
    integer sumI
    integer c0mI
    //
    // Build factorial table: line (k+1) = k! for k=0..18
    factBufI = CreateTempBuffer()
    GotoBufferId( factBufI )
    EmptyBuffer()
    factS = "1"
    AddLine( factS )                    // line 1 = 0! = 1
    fI = 1
    while fI <= 18
        factS = BigMulSmall( factS, fI )
        AddLine( factS )                // line fI+1 = fI!
        fI = fI + 1
    endwhile
    //
    // Retrieve 17! and 18! from buffer
    GotoBufferId( factBufI )
    GotoLine( 19 )                      // line 19 = 18!
    f18S = GetText( 1, CurrLineLen() )
    GotoLine( 18 )                      // line 18 = 17!
    f17S = GetText( 1, CurrLineLen() )
    //
    answerS = "0"
    //
    // 10 nested loops: c0..c9 each in {0,1,2,3}, require sum=18
    c0I = 0
    while c0I <= 3
        c1I = 0
        while c1I <= 3
            c2I = 0
            while c2I <= 3
                c3I = 0
                while c3I <= 3
                    c4I = 0
                    while c4I <= 3
                        c5I = 0
                        while c5I <= 3
                            c6I = 0
                            while c6I <= 3
                                c7I = 0
                                while c7I <= 3
                                    c8I = 0
                                    while c8I <= 3
                                        c9I = 0
                                        while c9I <= 3
                                            sumI = c0I + c1I + c2I + c3I + c4I
                                                 + c5I + c6I + c7I + c8I + c9I
                                            if sumI == 18
                                                // Compute 18! / (c0! * ... * c9!)
                                                termS = f18S
                                                termS = DivByFactorial( termS, c0I )
                                                termS = DivByFactorial( termS, c1I )
                                                termS = DivByFactorial( termS, c2I )
                                                termS = DivByFactorial( termS, c3I )
                                                termS = DivByFactorial( termS, c4I )
                                                termS = DivByFactorial( termS, c5I )
                                                termS = DivByFactorial( termS, c6I )
                                                termS = DivByFactorial( termS, c7I )
                                                termS = DivByFactorial( termS, c8I )
                                                termS = DivByFactorial( termS, c9I )
                                                //
                                                // Leading-zero correction (c0 > 0):
                                                // subtract 17!/((c0-1)!*c1!*...*c9!)
                                                if c0I > 0
                                                    lzS  = f17S
                                                    c0mI = c0I - 1
                                                    lzS  = DivByFactorial( lzS, c0mI )
                                                    lzS  = DivByFactorial( lzS, c1I )
                                                    lzS  = DivByFactorial( lzS, c2I )
                                                    lzS  = DivByFactorial( lzS, c3I )
                                                    lzS  = DivByFactorial( lzS, c4I )
                                                    lzS  = DivByFactorial( lzS, c5I )
                                                    lzS  = DivByFactorial( lzS, c6I )
                                                    lzS  = DivByFactorial( lzS, c7I )
                                                    lzS  = DivByFactorial( lzS, c8I )
                                                    lzS  = DivByFactorial( lzS, c9I )
                                                    termS = BigSubtract( termS, lzS )
                                                endif
                                                //
                                                answerS = BigAdd( answerS, termS )
                                            endif
                                            c9I = c9I + 1
                                        endwhile
                                        c8I = c8I + 1
                                    endwhile
                                    c7I = c7I + 1
                                endwhile
                                c6I = c6I + 1
                            endwhile
                            c5I = c5I + 1
                        endwhile
                        c4I = c4I + 1
                    endwhile
                    c3I = c3I + 1
                endwhile
                c2I = c2I + 1
            endwhile
            c1I = c1I + 1
        endwhile
        c0I = c0I + 1
    endwhile
    //
    AbandonFile( factBufI )
    //
    CopyToWinClip( answerS )
    Warn( "P172 Answer: " + answerS )
    CopyToWinClip( answerS )
end
