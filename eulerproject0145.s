/*
    Euler Project 145 - Reversible numbers
    Pure TSE SAL solution
    <version>1.0.0.0.1</version>

    History:
    1.0.0.0.1  2026-03-20
               - Initial pure TSE SAL version for Project Euler problem 145
               - Created by LLM: ChatGPT GPT-5.4 Thinking
               - Uses combinatorial counting, not brute force
               - Final answer should be: 608720

    Mathematical idea:
    - For even digit lengths n = 2,4,6,8:
      count = 20 * 30^( n/2 - 1 )
    - For odd digit lengths n = 3,7:
      count = 100 * 500^( (n - 3) / 4 )
    - For digit lengths n = 1,5,9:
      count = 0
    - Total below 10^9 = sum for lengths 1..9, equivalently 2..9 here
*/

INTEGER PROC ProcIntegerPower( INTEGER baseI, INTEGER exponentI )
    INTEGER resultI = 1
    INTEGER loopI   = 0
    //
    FOR loopI = 1 TO exponentI
        resultI = resultI * baseI
    ENDFOR
    //
    Return( resultI )
END

INTEGER PROC ProcCountReversibleForDigits( INTEGER digitCountI )
    INTEGER countI = 0
    //
    IF digitCountI == 1
        countI = 0
    ELSEIF digitCountI mod 2 == 0
        countI = 20 * ProcIntegerPower( 30, ( digitCountI / 2 ) - 1 )
    ELSEIF digitCountI mod 4 == 3
        countI = 100 * ProcIntegerPower( 500, ( digitCountI - 3 ) / 4 )
    ELSE
        countI = 0
    ENDIF
    //
    Return( countI )
END

STRING PROC ProcSolveEuler145()
    INTEGER digitCountI = 0
    INTEGER totalI      = 0
    STRING  answerS[32] = ""
    //
    FOR digitCountI = 2 TO 9
        totalI = totalI + ProcCountReversibleForDigits( digitCountI )
    ENDFOR
    //
    answerS = Format( totalI )
    Return( answerS )
END

PROC Main()
    STRING answerS[32] = ""
    //
    answerS = ProcSolveEuler145()
    //
    CopyToWinClip( answerS )
    Warn( answerS )
END
