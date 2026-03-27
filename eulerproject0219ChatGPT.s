// Euler Project problem 219
// Skew-cost Coding
// <version>1.0.0.0.1</version>
// History:
// 1.0.0.0.1  ChatGPT GPT-5.4 Thinking  Initial pure TSE SAL version
//
// Rule check applied:
// - Pure TSE SAL only
// - No Python
// - No string #define
// - No own variables named val or pos
// - Return() always with parentheses
// - Only one final Warn()
// - Two CopyToWinClip() lines around final Warn()
// - Final Warn() shows only the final answer
// - Result is calculated, not hard coded
//
#define TARGET_SIZE          1000000000
#define BASE_VALUE           1000000
#define INITIAL_LEAF_COUNT   1
//
string proc ProcFormatResult( integer totalHighI, integer totalLowI )
    string resultS[255] = ""
//
    IF totalHighI == 0
        resultS = Format( totalLowI:0 )
    ELSE
        resultS = Format( totalHighI:0 ) + Format( totalLowI:6:"0" )
    ENDIF
    RETURN( resultS )
end
//
proc ProcAddProductToTotal( integer amountI, integer factorI, var integer totalHighI, var integer totalLowI )
    integer amountHighI = 0
    integer amountLowI  = 0
    integer addHighI    = 0
    integer addLowI     = 0
    integer carryI      = 0
//
    amountHighI = amountI / BASE_VALUE
    amountLowI  = amountI mod BASE_VALUE
    addHighI    = amountHighI * factorI
    addLowI     = amountLowI  * factorI
    totalLowI   = totalLowI + addLowI
    carryI      = totalLowI / BASE_VALUE
    totalLowI   = totalLowI mod BASE_VALUE
    totalHighI  = totalHighI + addHighI + carryI
end
//
proc ProcProcessBucket( integer bucketCountI, integer bucketCostI, var integer remainingSplitsI, var integer totalHighI, var integer totalLowI )
    integer takenI = 0
//
    IF remainingSplitsI <= 0
        RETURN()
    ENDIF
    IF bucketCountI <= remainingSplitsI
        takenI = bucketCountI
    ELSE
        takenI = remainingSplitsI
    ENDIF
    ProcAddProductToTotal( takenI, bucketCostI + 5, totalHighI, totalLowI )
    remainingSplitsI = remainingSplitsI - takenI
end
//
PROC Main()
    integer remainingSplitsI = 0
    integer totalHighI       = 0
    integer totalLowI        = 0
    integer costI            = 0
    integer countMinus4I     = 1
    integer countMinus3I     = 1
    integer countMinus2I     = 1
    integer countMinus1I     = 1
    integer currentCountI    = 0
    string  resultS[255]     = ""
//
    remainingSplitsI = TARGET_SIZE - INITIAL_LEAF_COUNT
//
    costI = 0
    WHILE ( costI < 4 ) AND ( remainingSplitsI > 0 )
        ProcProcessBucket( 1, costI, remainingSplitsI, totalHighI, totalLowI )
        costI = costI + 1
    ENDWHILE
//
    costI = 4
    WHILE remainingSplitsI > 0
        currentCountI = countMinus4I + countMinus1I
        ProcProcessBucket( currentCountI, costI, remainingSplitsI, totalHighI, totalLowI )
        countMinus4I = countMinus3I
        countMinus3I = countMinus2I
        countMinus2I = countMinus1I
        countMinus1I = currentCountI
        costI = costI + 1
    ENDWHILE
//
    resultS = ProcFormatResult( totalHighI, totalLowI )
    CopyToWinClip( resultS )
    Warn( resultS )
    CopyToWinClip( resultS )
END
