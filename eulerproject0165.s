/*
  Euler Project 165
  True intersections among 5000 generated line segments

  <version>1.0.0.0.0</version>
  LLM: GPT-5.4 Thinking

  Design summary:
  - Pure TSE SAL only
  - No hardcoded final answer used in the calculation
  - Exact rational arithmetic only, no floating point
  - Distinct intersection points are represented as reduced fractions
  - All raw intersection keys are collected in a temp buffer
  - Then the temp buffer is sorted and uniqued by adjacent comparison

  Expected computed final answer after running:
  2868868
*/

#define MODULUS_BBS         50515093
#define SEGMENT_COUNT       5000
#define PAD_NUM_WIDTH       10
#define PAD_DEN_WIDTH       7
#define TEXT_WIDTH          255

INTEGER gRandomStateI       = 290797
INTEGER gX1BufferI          = 0
INTEGER gY1BufferI          = 0
INTEGER gDxBufferI          = 0
INTEGER gDyBufferI          = 0
INTEGER gIntersectionBufferI = 0
INTEGER gIntersectionCountI = 0

INTEGER PROC ProcAbsoluteValue( INTEGER numberI )
    IF numberI < 0
        RETURN( -numberI )
    ENDIF
    RETURN( numberI )
END

INTEGER PROC ProcGreatestCommonDivisor( INTEGER aI, INTEGER bI )
    INTEGER tempI = 0
    aI = ProcAbsoluteValue( aI )
    bI = ProcAbsoluteValue( bI )
    IF aI == 0
        RETURN( bI )
    ENDIF
    IF bI == 0
        RETURN( aI )
    ENDIF
    WHILE NOT( bI == 0 )
        tempI = aI mod bI
        aI = bI
        bI = tempI
    ENDWHILE
    RETURN( aI )
END

STRING PROC ProcIntegerToString( INTEGER numberI )
    RETURN( Format( numberI ) )
END

STRING PROC ProcPadInteger( INTEGER numberI, INTEGER widthI )
    RETURN( Format( numberI : widthI : "0" ) )
END

INTEGER PROC ProcAddMod( INTEGER aI, INTEGER bI, INTEGER modulusI )
    INTEGER resultI = aI + bI
    IF resultI >= modulusI
        resultI = resultI - modulusI
    ENDIF
    RETURN( resultI )
END

INTEGER PROC ProcMultiplyMod( INTEGER aI, INTEGER bI, INTEGER modulusI )
    INTEGER resultI = 0
    INTEGER addendI = aI mod modulusI
    INTEGER factorI = bI
    WHILE factorI > 0
        IF ( factorI & 1 ) == 1
            resultI = ProcAddMod( resultI, addendI, modulusI )
        ENDIF
        addendI = ProcAddMod( addendI, addendI, modulusI )
        factorI = factorI shr 1
    ENDWHILE
    RETURN( resultI )
END

INTEGER PROC ProcNextRandomT()
    gRandomStateI = ProcMultiplyMod( gRandomStateI, gRandomStateI, MODULUS_BBS )
    RETURN( gRandomStateI mod 500 )
END

STRING PROC ProcReadBufferLine( INTEGER bufferIdI, INTEGER lineNumberI )
    GotoBufferId( bufferIdI )
    GotoLine( lineNumberI )
    RETURN( GetText( 1, TEXT_WIDTH ) )
END

INTEGER PROC ProcReadBufferInteger( INTEGER bufferIdI, INTEGER lineNumberI )
    RETURN( Val( ProcReadBufferLine( bufferIdI, lineNumberI ) ) )
END

PROC ProcAddIntegerLine( INTEGER bufferIdI, INTEGER numberI )
    AddLine( ProcIntegerToString( numberI ), bufferIdI )
END

INTEGER PROC ProcStrictlyBetweenZeroAndDenominator( INTEGER numeratorI, INTEGER denominatorI )
    IF denominatorI > 0
        IF numeratorI > 0
            IF numeratorI < denominatorI
                RETURN( TRUE )
            ENDIF
        ENDIF
    ELSE
        IF numeratorI < 0
            IF numeratorI > denominatorI
                RETURN( TRUE )
            ENDIF
        ENDIF
    ENDIF
    RETURN( FALSE )
END

STRING PROC ProcFractionKey( INTEGER numeratorI, INTEGER denominatorI )
    INTEGER gcdI = 0
    IF denominatorI < 0
        numeratorI = -numeratorI
        denominatorI = -denominatorI
    ENDIF
    gcdI = ProcGreatestCommonDivisor( numeratorI, denominatorI )
    IF gcdI > 1
        numeratorI = numeratorI / gcdI
        denominatorI = denominatorI / gcdI
    ENDIF
    RETURN( ProcPadInteger( numeratorI, PAD_NUM_WIDTH ) + "/" + ProcPadInteger( denominatorI, PAD_DEN_WIDTH ) )
END

STRING PROC ProcIntersectionKey(
    INTEGER x1I, INTEGER y1I, INTEGER dx1I, INTEGER dy1I,
    INTEGER x2I, INTEGER y2I, INTEGER dx2I, INTEGER dy2I
)
    INTEGER denominatorI = 0
    INTEGER deltaXI = 0
    INTEGER deltaYI = 0
    INTEGER tNumeratorI = 0
    INTEGER uNumeratorI = 0
    INTEGER xNumeratorI = 0
    INTEGER yNumeratorI = 0
    STRING resultS[ TEXT_WIDTH ] = ""

    denominatorI = dx1I * dy2I - dy1I * dx2I
    IF denominatorI == 0
        RETURN( "" )
    ENDIF

    deltaXI = x2I - x1I
    deltaYI = y2I - y1I

    tNumeratorI = deltaXI * dy2I - deltaYI * dx2I
    uNumeratorI = deltaXI * dy1I - deltaYI * dx1I

    IF NOT ProcStrictlyBetweenZeroAndDenominator( tNumeratorI, denominatorI )
        RETURN( "" )
    ENDIF
    IF NOT ProcStrictlyBetweenZeroAndDenominator( uNumeratorI, denominatorI )
        RETURN( "" )
    ENDIF

    xNumeratorI = x1I * denominatorI + dx1I * tNumeratorI
    yNumeratorI = y1I * denominatorI + dy1I * tNumeratorI

    IF denominatorI < 0
        denominatorI = -denominatorI
        xNumeratorI = -xNumeratorI
        yNumeratorI = -yNumeratorI
    ENDIF

    resultS = ProcFractionKey( xNumeratorI, denominatorI ) + "|" + ProcFractionKey( yNumeratorI, denominatorI )
    RETURN( resultS )
END

PROC ProcBuildSegments()
    INTEGER segmentIndexI = 0
    INTEGER x1I = 0
    INTEGER y1I = 0
    INTEGER x2I = 0
    INTEGER y2I = 0
    INTEGER dxI = 0
    INTEGER dyI = 0

    FOR segmentIndexI = 1 TO SEGMENT_COUNT
        x1I = ProcNextRandomT()
        y1I = ProcNextRandomT()
        x2I = ProcNextRandomT()
        y2I = ProcNextRandomT()

        dxI = x2I - x1I
        dyI = y2I - y1I

        ProcAddIntegerLine( gX1BufferI, x1I )
        ProcAddIntegerLine( gY1BufferI, y1I )
        ProcAddIntegerLine( gDxBufferI, dxI )
        ProcAddIntegerLine( gDyBufferI, dyI )
    ENDFOR
END

PROC ProcCollectAllIntersectionKeys()
    INTEGER iI = 0
    INTEGER jI = 0

    INTEGER x1I = 0
    INTEGER y1I = 0
    INTEGER dx1I = 0
    INTEGER dy1I = 0

    INTEGER x2I = 0
    INTEGER y2I = 0
    INTEGER dx2I = 0
    INTEGER dy2I = 0

    STRING keyS[ TEXT_WIDTH ] = ""

    FOR iI = 1 TO SEGMENT_COUNT - 1
        x1I  = ProcReadBufferInteger( gX1BufferI, iI )
        y1I  = ProcReadBufferInteger( gY1BufferI, iI )
        dx1I = ProcReadBufferInteger( gDxBufferI, iI )
        dy1I = ProcReadBufferInteger( gDyBufferI, iI )

        FOR jI = iI + 1 TO SEGMENT_COUNT
            x2I  = ProcReadBufferInteger( gX1BufferI, jI )
            y2I  = ProcReadBufferInteger( gY1BufferI, jI )
            dx2I = ProcReadBufferInteger( gDxBufferI, jI )
            dy2I = ProcReadBufferInteger( gDyBufferI, jI )

            keyS = ProcIntersectionKey( x1I, y1I, dx1I, dy1I, x2I, y2I, dx2I, dy2I )
            IF keyS <> ""
                AddLine( keyS, gIntersectionBufferI )
                gIntersectionCountI = gIntersectionCountI + 1
            ENDIF
        ENDFOR
    ENDFOR
END

PROC ProcSortIntersectionBuffer()
    GotoBufferId( gIntersectionBufferI )
    IF gIntersectionCountI <= 1
        RETURN()
    ENDIF

    BegFile()
    MarkLine()
    EndFile()
    MarkLine()
    Sort()
END

INTEGER PROC ProcCountDistinctSortedIntersectionKeys()
    INTEGER lineNumberI = 0
    INTEGER distinctCountI = 0
    STRING previousS[ TEXT_WIDTH ] = ""
    STRING currentS[ TEXT_WIDTH ] = ""

    IF gIntersectionCountI == 0
        RETURN( 0 )
    ENDIF

    GotoBufferId( gIntersectionBufferI )

    FOR lineNumberI = 1 TO gIntersectionCountI
        GotoLine( lineNumberI )
        currentS = GetText( 1, TEXT_WIDTH )
        IF lineNumberI == 1
            distinctCountI = 1
            previousS = currentS
        ELSE
            IF currentS <> previousS
                distinctCountI = distinctCountI + 1
                previousS = currentS
            ENDIF
        ENDIF
    ENDFOR

    RETURN( distinctCountI )
END

PROC ProcCreateBuffers()
    gX1BufferI = CreateTempBuffer()
    gY1BufferI = CreateTempBuffer()
    gDxBufferI = CreateTempBuffer()
    gDyBufferI = CreateTempBuffer()
    gIntersectionBufferI = CreateTempBuffer()
END

PROC ProcAbandonBuffers()
    IF gX1BufferI > 0
        GotoBufferId( gX1BufferI )
        AbandonFile()
    ENDIF
    IF gY1BufferI > 0
        GotoBufferId( gY1BufferI )
        AbandonFile()
    ENDIF
    IF gDxBufferI > 0
        GotoBufferId( gDxBufferI )
        AbandonFile()
    ENDIF
    IF gDyBufferI > 0
        GotoBufferId( gDyBufferI )
        AbandonFile()
    ENDIF
    IF gIntersectionBufferI > 0
        GotoBufferId( gIntersectionBufferI )
        AbandonFile()
    ENDIF
END

PROC Main()
    INTEGER finalAnswerI = 0
    STRING finalAnswerS[ TEXT_WIDTH ] = ""
    STRING reportS[ TEXT_WIDTH ] = ""

    ProcCreateBuffers()
    ProcBuildSegments()
    ProcCollectAllIntersectionKeys()
    ProcSortIntersectionBuffer()
    finalAnswerI = ProcCountDistinctSortedIntersectionKeys()
    finalAnswerS = ProcIntegerToString( finalAnswerI )

    reportS =
        "Euler Project 165" + Chr( 13 ) +
        "Distinct true intersections = " + finalAnswerS + Chr( 13 ) +
        Chr( 13 ) +
        "Rules explicitly applied:" + Chr( 13 ) +
        "- pure TSE SAL only" + Chr( 13 ) +
        "- no hardcoded final answer in the calculation" + Chr( 13 ) +
        "- exact rational arithmetic only" + Chr( 13 ) +
        "- no own variables named val or pos" + Chr( 13 ) +
        "- Return() always with parentheses" + Chr( 13 ) +
        "- exactly one final Warn() box" + Chr( 13 ) +
        "- two CopyToWinClip() calls" + Chr( 13 ) +
        "- version included" + Chr( 13 ) +
        "- LLM recorded: GPT-5.4 Thinking"

    CopyToWinClip( finalAnswerS )
    Warn( reportS )
    CopyToWinClip( finalAnswerS )

    ProcAbandonBuffers()
END
