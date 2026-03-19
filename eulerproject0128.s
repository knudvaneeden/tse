// TSE/32
//
// euler128.s
//
// Project Euler problem 128
// Hexagonal tile differences
//
// Created by: ChatGPT
//
// <version>1.0.0.0.2</version>
//
// History:
// 1.0.0.0.2  2026-03-20
//            Fixed missing END statements after helper functions
//            Created by ChatGPT
// 1.0.0.0.1  2026-03-20
//            Initial version
//            Created by ChatGPT

string proc AddSmallIntegerToDecimalString( string numberS, integer addI )
    string workS[255] = ""
    string resultS[255] = ""
    integer indexI = 0
    integer carryI = 0
    integer digitNumberI = 0
    integer digitAddI = 0
    integer sumI = 0
    integer carryDigitI = 0
    string chS[1] = ""
    //
    workS = numberS
    indexI = Length( workS )
    carryI = addI
    carryDigitI = 0
    //
    WHILE ( indexI > 0 ) OR ( carryI > 0 ) OR ( carryDigitI > 0 )
        //
        if indexI > 0
            digitNumberI = Asc( SubStr( workS, indexI, 1 ) ) - 48
        else
            digitNumberI = 0
        endif
        //
        if carryI > 0
            digitAddI = carryI mod 10
            carryI = carryI / 10
        else
            digitAddI = 0
        endif
        //
        sumI = digitNumberI + digitAddI + carryDigitI
        chS = Chr( ( sumI mod 10 ) + 48 )
        resultS = chS + resultS
        carryDigitI = sumI / 10
        //
        if indexI > 0
            indexI = indexI - 1
        endif
    ENDWHILE
    //
    Return( resultS )
END

integer proc IsPrime( integer numberI )
    integer divisorI = 0
    //
    if numberI < 2
        Return( FALSE )
    endif
    //
    if numberI == 2
        Return( TRUE )
    endif
    //
    if ( numberI mod 2 ) == 0
        Return( FALSE )
    endif
    //
    divisorI = 3
    //
    WHILE ( divisorI * divisorI ) <= numberI
        //
        if ( numberI mod divisorI ) == 0
            Return( FALSE )
        endif
        //
        divisorI = divisorI + 2
    ENDWHILE
    //
    Return( TRUE )
END

proc Main()
    integer targetCountI = 2000
    integer foundCountI = 0
    integer ringI = 0
    integer incrementFromI = 0
    integer incrementToI = 0
    integer incrementTo2I = 0
    string firstTileS[255] = ""
    string answerS[255] = ""
    integer answerFoundB = FALSE
    //
    // PD(1) = 3 and PD(2) = 3 are the first two sequence members.
    //
    if targetCountI == 1
        answerS = "1"
        answerFoundB = TRUE
    elseif targetCountI == 2
        answerS = "2"
        answerFoundB = TRUE
    else
        foundCountI = 2
        ringI = 2
        firstTileS = "8"
        //
        // For ring r >= 2:
        // first tile of ring r = firstTileS
        // last  tile of ring r = firstTileS + ( 6 * ringI - 1 )
        //
        WHILE NOT answerFoundB
            //
            incrementFromI = ( ringI - 1 ) * 6
            incrementToI   = ringI * 6
            incrementTo2I  = ( ringI + 1 ) * 6 + incrementToI
            //
            // First candidate: first tile of ring ringI
            // Prime differences: 6r-1, 6r+1, 12r+5
            //
            if IsPrime( incrementToI - 1 )
                if IsPrime( incrementToI + 1 ) AND IsPrime( incrementTo2I - 1 )
                    foundCountI = foundCountI + 1
                    if foundCountI == targetCountI
                        answerS = firstTileS
                        answerFoundB = TRUE
                    endif
                endif
                //
                // Second candidate: last tile of ring ringI
                // Prime differences: 6r-1, 12r-7, 6r+5
                //
                if NOT answerFoundB
                    if IsPrime( incrementFromI + incrementToI - 1 ) AND IsPrime( incrementTo2I - incrementToI - 1 )
                        foundCountI = foundCountI + 1
                        if foundCountI == targetCountI
                            answerS = AddSmallIntegerToDecimalString( firstTileS, incrementToI - 1 )
                            answerFoundB = TRUE
                        endif
                    endif
                endif
            endif
            //
            if NOT answerFoundB
                firstTileS = AddSmallIntegerToDecimalString( firstTileS, incrementToI )
                ringI = ringI + 1
            endif
        ENDWHILE
    endif
    //
    Warn( answerS )
    CopyToWinClip( answerS )
END
