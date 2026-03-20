/*
 eulerproject0142.s
 <version>1.0.0.1</version>
 Project Euler 142 - Perfect Square Collection
 Pure TSE SAL solution

 History:
 1.0.0.1 - 2026-03-20 - Fixed parity bug; created by GPT-5.4 Thinking (ChatGPT)
 1.0.0.0 - 2026-03-20 - Initial version; created by GPT-5.4 Thinking (ChatGPT)
*/

FORWARD INTEGER PROC ProcIsPerfectSquare( INTEGER numberI )
FORWARD STRING  PROC ProcIntegerToString( INTEGER numberI )
FORWARD PROC    ProcShowFinalAnswer( INTEGER answerI )

INTEGER PROC ProcIsPerfectSquare( INTEGER numberI )
    INTEGER lowI    = 1
    INTEGER highI   = 46340
    INTEGER midI    = 0
    INTEGER squareI = 0
    //
    IF numberI < 0
        RETURN( FALSE )
    ENDIF
    //
    IF numberI == 0
        RETURN( TRUE )
    ENDIF
    //
    WHILE lowI <= highI
        midI    = ( lowI + highI ) / 2
        squareI = midI * midI
        //
        IF squareI == numberI
            RETURN( TRUE )
        ENDIF
        //
        IF squareI < numberI
            lowI = midI + 1
        ELSE
            highI = midI - 1
        ENDIF
    ENDWHILE
    //
    RETURN( FALSE )
END

STRING PROC ProcIntegerToString( INTEGER numberI )
    STRING resultS[40] = ""
    //
    resultS = Format( numberI )
    //
    RETURN( resultS )
END

PROC ProcShowFinalAnswer( INTEGER answerI )
    STRING answerS[40] = ""
    //
    answerS = ProcIntegerToString( answerI )
    CopyToWinClip( answerS )
    Warn( "Project Euler 142 answer:"; Chr( 13 ); answerS )
END

PROC Main()
    INTEGER maxRootI          = 2000
    INTEGER bestSumI          = 0
    INTEGER aRootI            = 0
    INTEGER cRootI            = 0
    INTEGER dRootI            = 0
    INTEGER squareAI          = 0
    INTEGER squareBI          = 0
    INTEGER squareCI          = 0
    INTEGER squareDI          = 0
    INTEGER squareEI          = 0
    INTEGER squareFI          = 0
    INTEGER numeratorXI       = 0
    INTEGER numeratorYI       = 0
    INTEGER numeratorZI       = 0
    INTEGER xI                = 0
    INTEGER yI                = 0
    INTEGER zI                = 0
    INTEGER sumI              = 0
    //
    FOR aRootI = 2 TO maxRootI
        squareAI = aRootI * aRootI
        //
        FOR cRootI = 1 TO aRootI - 1
            squareCI = cRootI * cRootI
            squareFI = squareAI - squareCI
            //
            IF ProcIsPerfectSquare( squareFI )
                FOR dRootI = 1 TO cRootI - 1
                    squareDI = dRootI * dRootI
                    squareEI = squareAI - squareDI
                    //
                    IF ProcIsPerfectSquare( squareEI )
                        squareBI = squareCI - squareEI
                        //
                        IF squareBI > 0
                            IF ProcIsPerfectSquare( squareBI )
                                numeratorXI = squareAI + squareBI
                                numeratorYI = squareEI + squareFI
                                numeratorZI = squareCI - squareDI
                                //
                                IF ( numeratorXI mod 2 ) == 0
                                    IF ( numeratorYI mod 2 ) == 0
                                        IF ( numeratorZI mod 2 ) == 0
                                            xI = numeratorXI / 2
                                            yI = numeratorYI / 2
                                            zI = numeratorZI / 2
                                            //
                                            IF xI > yI
                                                IF yI > zI
                                                    IF zI > 0
                                                        sumI = xI + yI + zI
                                                        //
                                                        IF bestSumI == 0
                                                            bestSumI = sumI
                                                        ELSE
                                                            IF sumI < bestSumI
                                                                bestSumI = sumI
                                                            ENDIF
                                                        ENDIF
                                                    ENDIF
                                                ENDIF
                                            ENDIF
                                        ENDIF
                                    ENDIF
                                ENDIF
                            ENDIF
                        ENDIF
                    ENDIF
                ENDFOR
            ENDIF
        ENDFOR
    ENDFOR
    //
    IF bestSumI > 0
        ProcShowFinalAnswer( bestSumI )
    ELSE
        Warn( "No solution found up to root limit "; maxRootI )
    ENDIF
END
