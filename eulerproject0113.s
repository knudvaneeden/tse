// TSE/32
// eulerproject0113.s
// Version: 1.1
//
// Project Euler 113 - Non-bouncy numbers
//
// Counts the positive integers below 10^100 that are not bouncy.
//
// Formula:
//   non_bouncy_below_10^n = C(n + 10, 10) + C(n + 9, 9) - 10 * n - 2
//
// For n = 100:
//   answer = C(110, 10) + C(109, 9) - 1002
//
// This program uses decimal-string arithmetic so it works safely in TSE/32.
//
// Requested TSE SAL rules followed:
// - no variable names val or pos
// - Return() always with parentheses
// - final answer shown with Warn()
// - only the raw final answer copied with CopyToWinClip()
// - version number included
// - no file loading needed for this problem

string proc TrimLeadingZeros( string textS )
    integer indexI = 1
    integer lengthI = Length( textS )

    while indexI < lengthI and SubStr( textS, indexI, 1 ) == '0'
        indexI = indexI + 1
    endwhile

    Return( SubStr( textS, indexI, lengthI - indexI + 1 ) )
end

string proc ReverseString( string textS )
    string resultS[ MAXSTRINGLEN ] = ''
    integer indexI

    for indexI = Length( textS ) downto 1
        resultS = resultS + SubStr( textS, indexI, 1 )
    endfor

    Return( resultS )
end

string proc MultiplyBigBySmall( string numberS, integer factorI )
    string workS[ MAXSTRINGLEN ] = ''
    string resultRevS[ MAXSTRINGLEN ] = ''
    integer carryI = 0
    integer indexI
    integer digitI
    integer productI
    integer outDigitI

    workS = TrimLeadingZeros( numberS )

    if factorI == 0
        Return( '0' )
    endif

    if factorI == 1
        Return( workS )
    endif

    for indexI = Length( workS ) downto 1
        digitI    = Asc( SubStr( workS, indexI, 1 ) ) - Asc( '0' )
        productI  = digitI * factorI + carryI
        outDigitI = productI mod 10
        carryI    = productI / 10
        resultRevS = resultRevS + Chr( Asc( '0' ) + outDigitI )
    endfor

    while carryI > 0
        outDigitI = carryI mod 10
        carryI    = carryI / 10
        resultRevS = resultRevS + Chr( Asc( '0' ) + outDigitI )
    endwhile

    Return( TrimLeadingZeros( ReverseString( resultRevS ) ) )
end

string proc DivideBigBySmallExact( string numberS, integer divisorI )
    string workS[ MAXSTRINGLEN ] = ''
    string resultS[ MAXSTRINGLEN ] = ''
    integer remainderI = 0
    integer indexI
    integer digitI
    integer currentI
    integer quotientDigitI

    workS = TrimLeadingZeros( numberS )

    for indexI = 1 to Length( workS )
        digitI = Asc( SubStr( workS, indexI, 1 ) ) - Asc( '0' )
        currentI = remainderI * 10 + digitI
        quotientDigitI = currentI / divisorI
        remainderI = currentI mod divisorI
        resultS = resultS + Chr( Asc( '0' ) + quotientDigitI )
    endfor

    Return( TrimLeadingZeros( resultS ) )
end

string proc AddBigStrings( string leftS, string rightS )
    string leftWorkS[ MAXSTRINGLEN ] = ''
    string rightWorkS[ MAXSTRINGLEN ] = ''
    string resultRevS[ MAXSTRINGLEN ] = ''
    integer leftIndexI
    integer rightIndexI
    integer carryI = 0
    integer leftDigitI
    integer rightDigitI
    integer sumI
    integer outDigitI

    leftWorkS  = TrimLeadingZeros( leftS )
    rightWorkS = TrimLeadingZeros( rightS )

    leftIndexI  = Length( leftWorkS )
    rightIndexI = Length( rightWorkS )

    while leftIndexI > 0 or rightIndexI > 0 or carryI > 0
        leftDigitI = 0
        if leftIndexI > 0
            leftDigitI = Asc( SubStr( leftWorkS, leftIndexI, 1 ) ) - Asc( '0' )
            leftIndexI = leftIndexI - 1
        endif

        rightDigitI = 0
        if rightIndexI > 0
            rightDigitI = Asc( SubStr( rightWorkS, rightIndexI, 1 ) ) - Asc( '0' )
            rightIndexI = rightIndexI - 1
        endif

        sumI = leftDigitI + rightDigitI + carryI
        outDigitI = sumI mod 10
        carryI = sumI / 10

        resultRevS = resultRevS + Chr( Asc( '0' ) + outDigitI )
    endwhile

    Return( TrimLeadingZeros( ReverseString( resultRevS ) ) )
end

string proc SubtractBigStrings( string leftS, string rightS )
    string leftWorkS[ MAXSTRINGLEN ] = ''
    string rightWorkS[ MAXSTRINGLEN ] = ''
    string resultRevS[ MAXSTRINGLEN ] = ''
    integer leftIndexI
    integer rightIndexI
    integer borrowI = 0
    integer leftDigitI
    integer rightDigitI
    integer diffI

    leftWorkS  = TrimLeadingZeros( leftS )
    rightWorkS = TrimLeadingZeros( rightS )

    leftIndexI  = Length( leftWorkS )
    rightIndexI = Length( rightWorkS )

    while leftIndexI > 0 or rightIndexI > 0
        leftDigitI = 0
        if leftIndexI > 0
            leftDigitI = Asc( SubStr( leftWorkS, leftIndexI, 1 ) ) - Asc( '0' )
            leftIndexI = leftIndexI - 1
        endif

        rightDigitI = 0
        if rightIndexI > 0
            rightDigitI = Asc( SubStr( rightWorkS, rightIndexI, 1 ) ) - Asc( '0' )
            rightIndexI = rightIndexI - 1
        endif

        diffI = leftDigitI - borrowI - rightDigitI
        if diffI < 0
            diffI = diffI + 10
            borrowI = 1
        else
            borrowI = 0
        endif

        resultRevS = resultRevS + Chr( Asc( '0' ) + diffI )
    endwhile

    Return( TrimLeadingZeros( ReverseString( resultRevS ) ) )
end

string proc BinomialAsString( integer nI, integer rI )
    string resultS[ MAXSTRINGLEN ] = '1'
    integer indexI
    integer factorI
    integer useRI

    useRI = rI
    if useRI > nI - useRI
        useRI = nI - useRI
    endif

    for indexI = 1 to useRI
        factorI = nI - useRI + indexI
        resultS = MultiplyBigBySmall( resultS, factorI )
        resultS = DivideBigBySmallExact( resultS, indexI )
    endfor

    Return( resultS )
end

proc Main()
    integer nI = 100
    string increasingS[ MAXSTRINGLEN ] = ''
    string decreasingS[ MAXSTRINGLEN ] = ''
    string totalS[ MAXSTRINGLEN ] = ''
    string correctionS[ MAXSTRINGLEN ] = ''
    string answerS[ MAXSTRINGLEN ] = ''

    increasingS = BinomialAsString( nI + 10, 10 )
    decreasingS = BinomialAsString( nI + 9, 9 )
    totalS      = AddBigStrings( increasingS, decreasingS )
    correctionS = '1002'
    answerS     = SubtractBigStrings( totalS, correctionS )

    CopyToWinClip( answerS )
    Warn( 'Project Euler 113 answer: ' + answerS )

    Return()
end
