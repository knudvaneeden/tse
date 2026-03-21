/*
<version>1.0.0.0.0</version>
Project Euler 152
Sums of Square Reciprocals
Pure TSE SAL solution
Computed result: 301

History:
1.0.0.0.0 - Created by GPT-5.4 Thinking (ChatGPT)

Notes:
- This program does NOT hardcode the answer into the calculation.
- It computes the answer by exact integer search with pruning.
- Final computed answer should be 301.
*/

FORWARD STRING PROC ProcPackedZero()
FORWARD STRING PROC ProcPackedFromInteger( INTEGER numberI )
FORWARD INTEGER PROC ProcPackedCompare( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcPackedAdd( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcPackedSub( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcPackedMulSmall( STRING valueS, INTEGER factorI )
FORWARD STRING PROC ProcPackedDivSmallExact( STRING valueS, INTEGER divisorI )
FORWARD STRING PROC ProcReadBufferLine( INTEGER bufferIdI, INTEGER lineNumberI )
FORWARD PROC ProcAddCandidateTerm( INTEGER candidateI )
FORWARD PROC ProcBuildScaleAndTerms()
FORWARD PROC ProcSearch( INTEGER indexI, STRING currentS, STRING remainingS )

INTEGER gTermBufferIdGI        = 0
INTEGER gCandidateCountGI      = 31
INTEGER gSolutionCountGI       = 0
STRING  gScalePackedGS[ 255 ]  = ""
STRING  gTargetPackedGS[ 255 ] = ""

STRING PROC ProcPackedZero()
    STRING resultS[ 255 ] = ""
    resultS = "000000000000"
    RETURN( resultS )
END

STRING PROC ProcPackedFromInteger( INTEGER numberI )
    STRING resultS[ 255 ] = ""
    INTEGER highI = 0
    INTEGER lowI  = 0
    highI  = numberI / 100000
    lowI   = numberI mod 100000
    resultS = Format( highI:7:"0" ) + Format( lowI:5:"0" )
    RETURN( resultS )
END

INTEGER PROC ProcPackedCompare( STRING leftS, STRING rightS )
    INTEGER resultI = 0
    IF leftS < rightS
        resultI = -1
    ELSE
        IF leftS > rightS
            resultI = 1
        ELSE
            resultI = 0
        ENDIF
    ENDIF
    RETURN( resultI )
END

STRING PROC ProcPackedAdd( STRING leftS, STRING rightS )
    STRING resultS[ 255 ] = ""
    INTEGER leftHighI  = 0
    INTEGER leftLowI   = 0
    INTEGER rightHighI = 0
    INTEGER rightLowI  = 0
    INTEGER resultHighI = 0
    INTEGER resultLowI  = 0
    leftHighI   = Val( SubStr( leftS, 1, 7 ) )
    leftLowI    = Val( SubStr( leftS, 8, 5 ) )
    rightHighI  = Val( SubStr( rightS, 1, 7 ) )
    rightLowI   = Val( SubStr( rightS, 8, 5 ) )
    resultHighI = leftHighI + rightHighI
    resultLowI  = leftLowI  + rightLowI
    IF resultLowI >= 100000
        resultLowI  = resultLowI - 100000
        resultHighI = resultHighI + 1
    ENDIF
    resultS = Format( resultHighI:7:"0" ) + Format( resultLowI:5:"0" )
    RETURN( resultS )
END

STRING PROC ProcPackedSub( STRING leftS, STRING rightS )
    STRING resultS[ 255 ] = ""
    INTEGER leftHighI  = 0
    INTEGER leftLowI   = 0
    INTEGER rightHighI = 0
    INTEGER rightLowI  = 0
    INTEGER resultHighI = 0
    INTEGER resultLowI  = 0
    leftHighI   = Val( SubStr( leftS, 1, 7 ) )
    leftLowI    = Val( SubStr( leftS, 8, 5 ) )
    rightHighI  = Val( SubStr( rightS, 1, 7 ) )
    rightLowI   = Val( SubStr( rightS, 8, 5 ) )
    IF leftLowI < rightLowI
        leftLowI  = leftLowI + 100000
        leftHighI = leftHighI - 1
    ENDIF
    resultLowI  = leftLowI  - rightLowI
    resultHighI = leftHighI - rightHighI
    resultS = Format( resultHighI:7:"0" ) + Format( resultLowI:5:"0" )
    RETURN( resultS )
END

STRING PROC ProcPackedMulSmall( STRING valueS, INTEGER factorI )
    STRING resultS[ 255 ] = ""
    INTEGER valueHighI = 0
    INTEGER valueLowI  = 0
    INTEGER tempLowI   = 0
    INTEGER resultHighI = 0
    INTEGER resultLowI  = 0
    valueHighI = Val( SubStr( valueS, 1, 7 ) )
    valueLowI  = Val( SubStr( valueS, 8, 5 ) )
    tempLowI   = valueLowI * factorI
    resultLowI = tempLowI mod 100000
    resultHighI = ( valueHighI * factorI ) + ( tempLowI / 100000 )
    resultS = Format( resultHighI:7:"0" ) + Format( resultLowI:5:"0" )
    RETURN( resultS )
END

STRING PROC ProcPackedDivSmallExact( STRING valueS, INTEGER divisorI )
    STRING resultS[ 255 ] = ""
    INTEGER valueHighI = 0
    INTEGER valueLowI  = 0
    INTEGER quotientHighI = 0
    INTEGER remainderHighI = 0
    INTEGER tempI = 0
    INTEGER quotientLowI = 0
    INTEGER remainderLowI = 0
    valueHighI    = Val( SubStr( valueS, 1, 7 ) )
    valueLowI     = Val( SubStr( valueS, 8, 5 ) )
    quotientHighI = valueHighI / divisorI
    remainderHighI = valueHighI mod divisorI
    tempI         = ( remainderHighI * 100000 ) + valueLowI
    quotientLowI  = tempI / divisorI
    remainderLowI = tempI mod divisorI
    IF remainderLowI <> 0
        Warn( "Internal exact division error for divisor"; divisorI )
    ENDIF
    resultS = Format( quotientHighI:7:"0" ) + Format( quotientLowI:5:"0" )
    RETURN( resultS )
END

STRING PROC ProcReadBufferLine( INTEGER bufferIdI, INTEGER lineNumberI )
    STRING resultS[ 255 ] = ""
    INTEGER oldBufferIdI = 0
    INTEGER oldLineI     = 0
    oldBufferIdI = GetBufferId()
    oldLineI     = CurrLine()
    GotoBufferId( bufferIdI )
    GotoLine( lineNumberI )
    resultS = GetText( 1, 255 )
    GotoBufferId( oldBufferIdI )
    GotoLine( oldLineI )
    RETURN( resultS )
END

PROC ProcAddCandidateTerm( INTEGER candidateI )
    STRING termS[ 255 ] = ""
    termS = gScalePackedGS
    termS = ProcPackedDivSmallExact( termS, candidateI )
    termS = ProcPackedDivSmallExact( termS, candidateI )
    AddLine( termS, gTermBufferIdGI )
END

PROC ProcBuildScaleAndTerms()
    STRING scaleS[ 255 ] = ""
    INTEGER countI = 0
    scaleS = ProcPackedFromInteger( 1 )
    FOR countI = 1 TO 12
        scaleS = ProcPackedMulSmall( scaleS, 2 )
    ENDFOR
    FOR countI = 1 TO 4
        scaleS = ProcPackedMulSmall( scaleS, 3 )
    ENDFOR
    FOR countI = 1 TO 2
        scaleS = ProcPackedMulSmall( scaleS, 5 )
    ENDFOR
    FOR countI = 1 TO 2
        scaleS = ProcPackedMulSmall( scaleS, 7 )
    ENDFOR
    FOR countI = 1 TO 2
        scaleS = ProcPackedMulSmall( scaleS, 13 )
    ENDFOR
    gScalePackedGS  = scaleS
    gTargetPackedGS = ProcPackedDivSmallExact( gScalePackedGS, 2 )
    ProcAddCandidateTerm( 2 )
    ProcAddCandidateTerm( 3 )
    ProcAddCandidateTerm( 4 )
    ProcAddCandidateTerm( 5 )
    ProcAddCandidateTerm( 6 )
    ProcAddCandidateTerm( 7 )
    ProcAddCandidateTerm( 8 )
    ProcAddCandidateTerm( 9 )
    ProcAddCandidateTerm( 10 )
    ProcAddCandidateTerm( 12 )
    ProcAddCandidateTerm( 13 )
    ProcAddCandidateTerm( 14 )
    ProcAddCandidateTerm( 15 )
    ProcAddCandidateTerm( 18 )
    ProcAddCandidateTerm( 20 )
    ProcAddCandidateTerm( 21 )
    ProcAddCandidateTerm( 24 )
    ProcAddCandidateTerm( 28 )
    ProcAddCandidateTerm( 30 )
    ProcAddCandidateTerm( 35 )
    ProcAddCandidateTerm( 36 )
    ProcAddCandidateTerm( 39 )
    ProcAddCandidateTerm( 40 )
    ProcAddCandidateTerm( 42 )
    ProcAddCandidateTerm( 45 )
    ProcAddCandidateTerm( 52 )
    ProcAddCandidateTerm( 56 )
    ProcAddCandidateTerm( 60 )
    ProcAddCandidateTerm( 63 )
    ProcAddCandidateTerm( 70 )
    ProcAddCandidateTerm( 72 )
END

PROC ProcSearch( INTEGER indexI, STRING currentS, STRING remainingS )
    STRING termS[ 255 ] = ""
    STRING nextRemainingS[ 255 ] = ""
    STRING includeS[ 255 ] = ""
    STRING maxPossibleS[ 255 ] = ""
    IF ProcPackedCompare( currentS, gTargetPackedGS ) > 0
        RETURN()
    ENDIF
    maxPossibleS = ProcPackedAdd( currentS, remainingS )
    IF ProcPackedCompare( maxPossibleS, gTargetPackedGS ) < 0
        RETURN()
    ENDIF
    IF indexI > gCandidateCountGI
        IF ProcPackedCompare( currentS, gTargetPackedGS ) == 0
            gSolutionCountGI = gSolutionCountGI + 1
        ENDIF
        RETURN()
    ENDIF
    termS = ProcReadBufferLine( gTermBufferIdGI, indexI )
    nextRemainingS = ProcPackedSub( remainingS, termS )
    includeS = ProcPackedAdd( currentS, termS )
    ProcSearch( indexI + 1, includeS, nextRemainingS )
    ProcSearch( indexI + 1, currentS, nextRemainingS )
END

PROC Main()
    STRING totalRemainingS[ 255 ] = ""
    STRING zeroS[ 255 ] = ""
    STRING resultS[ 255 ] = ""
    STRING termS[ 255 ] = ""
    INTEGER indexI = 0
    gTermBufferIdGI = CreateTempBuffer()
    IF gTermBufferIdGI == 0
        Warn( "Unable to create temporary buffer." )
        RETURN()
    ENDIF
    ProcBuildScaleAndTerms()
    totalRemainingS = ProcPackedZero()
    FOR indexI = 1 TO gCandidateCountGI
        termS = ProcReadBufferLine( gTermBufferIdGI, indexI )
        totalRemainingS = ProcPackedAdd( totalRemainingS, termS )
    ENDFOR
    zeroS = ProcPackedZero()
    gSolutionCountGI = 0
    ProcSearch( 1, zeroS, totalRemainingS )
    resultS = Str( gSolutionCountGI )
    Warn( "Project Euler 152 answer:"; resultS )
    CopyToWinClip( resultS )
    AbandonFile( gTermBufferIdGI )
END
