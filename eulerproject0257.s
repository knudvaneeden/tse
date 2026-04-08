// Project Euler 257
// Angular Bisectors
// Pure TSE SAL
// Version: 7
//
// History:
// 1 - Created by ChatGPT GPT-5.4 Thinking.
// 2 - Updated by ChatGPT GPT-5.4 Thinking for TSE Pro 4.50.22 Format() display behavior.
// 3 - Updated by ChatGPT GPT-5.4 Thinking with exact k = 2 / k = 3 family counting.
// 4 - Updated by ChatGPT GPT-5.4 Thinking to avoid 32-bit overflow in k = 3 side/perimeter calculations.
// 5 - Updated by ChatGPT GPT-5.4 Thinking to use exact coprime ( a, b ) enumeration.
// 6 - Updated by ChatGPT GPT-5.4 Thinking to use the correct truncated lower bound
//     a = floor( ( sqrt( k ) - 1 ) * b ).
// 7 - Updated by ChatGPT GPT-5.4 Thinking to use safe full b-ranges for N = 100000000
//     instead of prematurely stopping by a derived perimeter test.
//
// Rules applied:
// - Pure TSE SAL only
// - PROC Main() is last
// - Return() always uses parentheses
// - No variables named val or pos
// - Only one final Warn() box
// - Two CopyToWinClip() calls around final Warn()
// - Final answer converted with Format( answerI )

FORWARD INTEGER PROC ProcGcd( INTEGER leftI, INTEGER rightI )
FORWARD INTEGER PROC ProcStartAForK( INTEGER kI, INTEGER bI )
FORWARD INTEGER PROC ProcCountForK( INTEGER limitI, INTEGER kI )
FORWARD INTEGER PROC ProcSolve( INTEGER limitI )

INTEGER PROC ProcGcd( INTEGER leftI, INTEGER rightI )
    INTEGER tempI = 0
    //
    IF leftI < 0
        leftI = -leftI
    ENDIF
    IF rightI < 0
        rightI = -rightI
    ENDIF
    WHILE ( rightI > 0 )
        tempI  = leftI mod rightI
        leftI  = rightI
        rightI = tempI
    ENDWHILE
    RETURN( leftI )
END

INTEGER PROC ProcStartAForK( INTEGER kI, INTEGER bI )
    INTEGER lowI = 0
    INTEGER highI = 0
    INTEGER midI = 0
    INTEGER leftExprI = 0
    INTEGER rightExprI = 0
    //
    IF kI == 2
        highI = bI / 2
        WHILE ( lowI < highI )
            midI = ( lowI + highI + 1 ) / 2
            leftExprI  = midI * midI + 2 * midI * bI
            rightExprI = bI * bI
            IF leftExprI <= rightExprI
                lowI = midI
            ELSE
                highI = midI - 1
            ENDIF
        ENDWHILE
        RETURN( lowI )
    ELSE
        highI = bI
        WHILE ( lowI < highI )
            midI = ( lowI + highI + 1 ) / 2
            leftExprI  = midI * midI + 2 * midI * bI
            rightExprI = 2 * bI * bI
            IF leftExprI <= rightExprI
                lowI = midI
            ELSE
                highI = midI - 1
            ENDIF
        ENDWHILE
        RETURN( lowI )
    ENDIF
END

INTEGER PROC ProcCountForK( INTEGER limitI, INTEGER kI )
    INTEGER countI = 0
    INTEGER upperBI = 0
    INTEGER bI = 0
    INTEGER startAI = 0
    INTEGER endAI = 0
    INTEGER aI = 0
    INTEGER tI = 0
    INTEGER sideAI = 0
    INTEGER sideBI = 0
    INTEGER sideCI = 0
    INTEGER reduceI = 0
    INTEGER perimeterI = 0
    //
    IF kI == 2
        upperBI = 41603
    ELSE
        upperBI = 32139
    ENDIF
    FOR bI = 1 TO upperBI
        startAI = ProcStartAForK( kI, bI )
        IF kI == 2
            endAI = bI / 2
        ELSE
            endAI = bI
        ENDIF
        FOR aI = startAI TO endAI
            IF aI > 0
                IF ProcGcd( aI, bI ) == 1
                    tI = ( kI - 1 ) * bI - aI
                    sideAI = aI * tI
                    sideBI = bI * tI
                    sideCI = aI * ( aI + bI )
                    reduceI = ProcGcd( tI, sideCI )
                    IF reduceI > 1
                        sideAI = sideAI / reduceI
                        sideBI = sideBI / reduceI
                        sideCI = sideCI / reduceI
                    ENDIF
                    perimeterI = sideAI + sideBI + sideCI
                    IF sideAI + sideBI > sideCI
                        IF sideAI <= sideBI
                            IF sideBI <= sideCI
                                IF perimeterI <= limitI
                                    countI = countI + ( limitI / perimeterI )
                                ENDIF
                            ENDIF
                        ENDIF
                    ENDIF
                ENDIF
            ENDIF
        ENDFOR
    ENDFOR
    RETURN( countI )
END

INTEGER PROC ProcSolve( INTEGER limitI )
    INTEGER answerI = 0
    //
    answerI = limitI / 3
    answerI = answerI + ProcCountForK( limitI, 2 )
    answerI = answerI + ProcCountForK( limitI, 3 )
    RETURN( answerI )
END

PROC Main()
    INTEGER limitI = 100000000
    INTEGER answerI = 0
    STRING answerS[255] = ""
    //
    answerI = ProcSolve( limitI )
    answerS = Format( answerI )
    CopyToWinClip( answerS )
    Warn( answerS )
    CopyToWinClip( answerS )
END
