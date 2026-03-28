// euler222.s
// <version>1.0.0.0.0</version>
// <llm>ChatGPT GPT-5.4 Thinking</llm>

#define SCALE_6                         1000000
#define EXTRA_DIGITS                    7
#define PIPE_RADIUS_I                   50
#define MIN_BALL_RADIUS_I               30
#define MAX_BALL_RADIUS_I               50

integer proc ProcSqrtScaled6( integer numberI )
    integer stepI = 0
    integer remainderI = 0
    integer rootI = 0
    integer digitI = 0
    integer trialI = 0
    FOR stepI = 0 TO EXTRA_DIGITS
        IF stepI == 0
            remainderI = numberI
        ELSE
            remainderI = remainderI * 100
        ENDIF
        digitI = 9
        WHILE digitI >= 0
            trialI = ( 20 * rootI + digitI ) * digitI
            IF trialI <= remainderI
                remainderI = remainderI - trialI
                rootI = rootI * 10 + digitI
                digitI = -1
            ELSE
                digitI = digitI - 1
            ENDIF
        ENDWHILE
    ENDFOR
    RETURN( ( rootI + 5 ) / 10 )
END

integer proc ProcGapScaledMm( integer leftRadiusI, integer rightRadiusI )
    integer radicandI = 0
    integer sqrtScaledI = 0
    radicandI = 2 * ( leftRadiusI + rightRadiusI ) - 100
    sqrtScaledI = ProcSqrtScaled6( radicandI )
    RETURN( 10 * sqrtScaledI )
END

proc Main()
    integer previousRadiusI = 0
    integer currentRadiusI = 0
    integer totalScaledMmI = 0
    integer answerUmI = 0
    string answerS[255] = ""
    string historyS[255] = "Euler 222 | LLM=ChatGPT GPT-5.4 Thinking | version 1.0.0.0.0"
    AddHistoryStr( historyS, _EDIT_HISTORY_ )
    totalScaledMmI = ( MAX_BALL_RADIUS_I + ( MAX_BALL_RADIUS_I - 1 ) ) * SCALE_6
    previousRadiusI = MAX_BALL_RADIUS_I
    FOR currentRadiusI = 48 DOWNTO MIN_BALL_RADIUS_I BY 2
        totalScaledMmI = totalScaledMmI + ProcGapScaledMm( previousRadiusI, currentRadiusI )
        previousRadiusI = currentRadiusI
    ENDFOR
    FOR currentRadiusI = 31 TO ( MAX_BALL_RADIUS_I - 1 ) BY 2
        totalScaledMmI = totalScaledMmI + ProcGapScaledMm( previousRadiusI, currentRadiusI )
        previousRadiusI = currentRadiusI
    ENDFOR
    answerUmI = ( totalScaledMmI + 500 ) / 1000
    answerS = Format( answerUmI )
    CopyToWinClip( answerS )
    Warn( answerS )
    CopyToWinClip( answerS )
END
