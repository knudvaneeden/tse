/*
  Project Euler 254
  Pure TSE SAL
  LLM creator: ChatGPT
  Version: 6

  Applied rule check:
  - pure TSE SAL only
  - no hardcoded final answer
  - no variable names val / pos
  - Return() always with parentheses
  - one final Warn() only
  - CopyToWinClip() before and after final Warn()
  - version number present once
  - LLM creator noted in source header
*/

#define SMALL_LIMIT 63
#define SMALL_Y_MAX 9999999
#define FACT9 362880

FORWARD STRING PROC ProcTrimLeadingZeros( STRING numberS )
FORWARD INTEGER PROC ProcDigitCharToInteger( STRING oneCharS )
FORWARD STRING PROC ProcIntegerToDigit( INTEGER digitI )
FORWARD STRING PROC ProcAddDecimalStrings( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcAddSmallToDecimalString( STRING leftS, INTEGER addI )
FORWARD STRING PROC ProcMultiplyDecimalStringBySmall( STRING leftS, INTEGER mulI )
FORWARD INTEGER PROC ProcGetLineInteger( INTEGER bufferIdI, INTEGER lineI )
FORWARD PROC ProcSetLineInteger( INTEGER bufferIdI, INTEGER lineI, INTEGER numberI )
FORWARD PROC ProcEnsureLineCount( INTEGER bufferIdI, INTEGER neededLineCountI )
FORWARD PROC ProcInitIntegerBuffer( INTEGER bufferIdI, INTEGER lineCountI, INTEGER initialI )
FORWARD PROC ProcInitBestBuffers()
FORWARD PROC ProcFactoradicSetToOne()
FORWARD PROC ProcFactoradicIncrement()
FORWARD INTEGER PROC ProcCountTrailingNines( INTEGER numberI )
FORWARD INTEGER PROC ProcCurrentLength()
FORWARD INTEGER PROC ProcCandidateBeatsStored( INTEGER sumI )
FORWARD PROC ProcStoreCurrentCandidate( INTEGER sumI )
FORWARD PROC ProcBuildSmallExactAnswers()
FORWARD STRING PROC ProcBuildSmallSgString( INTEGER sumI )
FORWARD STRING PROC ProcBuildLargeYString( INTEGER targetI )
FORWARD PROC ProcDivideDecimalStringByFact9( STRING numberS )
FORWARD PROC ProcDecodeRemainderCounts( INTEGER remainderI )
FORWARD STRING PROC ProcBuildLargeSgString( INTEGER targetI )
FORWARD STRING PROC ProcRepeatDigit( INTEGER digitI, INTEGER countI )

INTEGER gBestFoundBufferI = 0
INTEGER gBestLenBufferI = 0
INTEGER gBest1BufferI = 0
INTEGER gBest2BufferI = 0
INTEGER gBest3BufferI = 0
INTEGER gBest4BufferI = 0
INTEGER gBest5BufferI = 0
INTEGER gBest6BufferI = 0
INTEGER gBest7BufferI = 0
INTEGER gBest8BufferI = 0
INTEGER gBest9BufferI = 0

INTEGER gCur1I = 0
INTEGER gCur2I = 0
INTEGER gCur3I = 0
INTEGER gCur4I = 0
INTEGER gCur5I = 0
INTEGER gCur6I = 0
INTEGER gCur7I = 0
INTEGER gCur8I = 0
INTEGER gCur9I = 0

STRING gDivisionQuotientS[255] = ""
INTEGER gDivisionRemainderI = 0
INTEGER gLarge1I = 0
INTEGER gLarge2I = 0
INTEGER gLarge3I = 0
INTEGER gLarge4I = 0
INTEGER gLarge5I = 0
INTEGER gLarge6I = 0
INTEGER gLarge7I = 0
INTEGER gLarge8I = 0

STRING PROC ProcTrimLeadingZeros( STRING numberS )
  STRING workS[255] = ""
  INTEGER indexI = 0
  workS = numberS
  IF workS == ""
    RETURN( "0" )
  ENDIF
  indexI = 1
  WHILE indexI < Length( workS ) AND SubStr( workS, indexI, 1 ) == "0"
    indexI = indexI + 1
  ENDWHILE
  RETURN( SubStr( workS, indexI, Length( workS ) - indexI + 1 ) )
END

INTEGER PROC ProcDigitCharToInteger( STRING oneCharS )
  CASE oneCharS
    WHEN "0"
      RETURN( 0 )
    WHEN "1"
      RETURN( 1 )
    WHEN "2"
      RETURN( 2 )
    WHEN "3"
      RETURN( 3 )
    WHEN "4"
      RETURN( 4 )
    WHEN "5"
      RETURN( 5 )
    WHEN "6"
      RETURN( 6 )
    WHEN "7"
      RETURN( 7 )
    WHEN "8"
      RETURN( 8 )
    WHEN "9"
      RETURN( 9 )
    OTHERWISE
      RETURN( 0 )
  ENDCASE
END

STRING PROC ProcIntegerToDigit( INTEGER digitI )
  STRING outS[2] = ""
  CASE digitI
    WHEN 0
      outS = "0"
    WHEN 1
      outS = "1"
    WHEN 2
      outS = "2"
    WHEN 3
      outS = "3"
    WHEN 4
      outS = "4"
    WHEN 5
      outS = "5"
    WHEN 6
      outS = "6"
    WHEN 7
      outS = "7"
    WHEN 8
      outS = "8"
    WHEN 9
      outS = "9"
    OTHERWISE
      outS = "0"
  ENDCASE
  RETURN( outS )
END

STRING PROC ProcAddDecimalStrings( STRING leftS, STRING rightS )
  STRING aS[255] = ""
  STRING bS[255] = ""
  STRING resultS[255] = ""
  INTEGER carryI = 0
  INTEGER leftIndexI = 0
  INTEGER rightIndexI = 0
  INTEGER digitLeftI = 0
  INTEGER digitRightI = 0
  INTEGER digitSumI = 0
  aS = ProcTrimLeadingZeros( leftS )
  bS = ProcTrimLeadingZeros( rightS )
  resultS = ""
  leftIndexI = Length( aS )
  rightIndexI = Length( bS )
  WHILE leftIndexI > 0 OR rightIndexI > 0 OR carryI > 0
    digitLeftI = 0
    digitRightI = 0
    IF leftIndexI > 0
      digitLeftI = ProcDigitCharToInteger( SubStr( aS, leftIndexI, 1 ) )
      leftIndexI = leftIndexI - 1
    ENDIF
    IF rightIndexI > 0
      digitRightI = ProcDigitCharToInteger( SubStr( bS, rightIndexI, 1 ) )
      rightIndexI = rightIndexI - 1
    ENDIF
    digitSumI = digitLeftI + digitRightI + carryI
    resultS = ProcIntegerToDigit( digitSumI mod 10 ) + resultS
    carryI = digitSumI / 10
  ENDWHILE
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcAddSmallToDecimalString( STRING leftS, INTEGER addI )
  STRING addS[32] = ""
  addS = Str( addI )
  RETURN( ProcAddDecimalStrings( leftS, addS ) )
END

STRING PROC ProcMultiplyDecimalStringBySmall( STRING leftS, INTEGER mulI )
  STRING workS[255] = ""
  STRING resultS[255] = ""
  INTEGER indexI = 0
  INTEGER digitI = 0
  INTEGER productI = 0
  INTEGER carryI = 0
  workS = ProcTrimLeadingZeros( leftS )
  IF workS == "0"
    RETURN( "0" )
  ENDIF
  IF mulI == 0
    RETURN( "0" )
  ENDIF
  resultS = ""
  carryI = 0
  FOR indexI = Length( workS ) DOWNTO 1
    digitI = ProcDigitCharToInteger( SubStr( workS, indexI, 1 ) )
    productI = digitI * mulI + carryI
    resultS = ProcIntegerToDigit( productI mod 10 ) + resultS
    carryI = productI / 10
  ENDFOR
  WHILE carryI > 0
    resultS = ProcIntegerToDigit( carryI mod 10 ) + resultS
    carryI = carryI / 10
  ENDWHILE
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

INTEGER PROC ProcGetLineInteger( INTEGER bufferIdI, INTEGER lineI )
  STRING textS[255] = ""
  INTEGER numberI = 0
  PushLocation()
  GotoBufferId( bufferIdI )
  GotoLine( lineI )
  textS = GetText( 1, 255 )
  numberI = Val( textS )
  PopLocation()
  RETURN( numberI )
END

PROC ProcSetLineInteger( INTEGER bufferIdI, INTEGER lineI, INTEGER numberI )
  STRING textS[255] = ""
  PushLocation()
  GotoBufferId( bufferIdI )
  ProcEnsureLineCount( bufferIdI, lineI )
  GotoLine( lineI )
  BegLine()
  KillToEol()
  textS = Str( numberI )
  InsertText( textS )
  PopLocation()
END

PROC ProcEnsureLineCount( INTEGER bufferIdI, INTEGER neededLineCountI )
  INTEGER currentCountI = 0
  PushLocation()
  GotoBufferId( bufferIdI )
  currentCountI = NumLines()
  WHILE currentCountI < neededLineCountI
    AddLine( "0", bufferIdI )
    currentCountI = currentCountI + 1
  ENDWHILE
  PopLocation()
END

PROC ProcInitIntegerBuffer( INTEGER bufferIdI, INTEGER lineCountI, INTEGER initialI )
  INTEGER indexI = 0
  STRING textS[255] = ""
  textS = Str( initialI )
  PushLocation()
  GotoBufferId( bufferIdI )
  EmptyBuffer()
  FOR indexI = 1 TO lineCountI
    AddLine( textS, bufferIdI )
  ENDFOR
  PopLocation()
END

PROC ProcInitBestBuffers()
  gBestFoundBufferI = CreateTempBuffer()
  gBestLenBufferI = CreateTempBuffer()
  gBest1BufferI = CreateTempBuffer()
  gBest2BufferI = CreateTempBuffer()
  gBest3BufferI = CreateTempBuffer()
  gBest4BufferI = CreateTempBuffer()
  gBest5BufferI = CreateTempBuffer()
  gBest6BufferI = CreateTempBuffer()
  gBest7BufferI = CreateTempBuffer()
  gBest8BufferI = CreateTempBuffer()
  gBest9BufferI = CreateTempBuffer()

  ProcInitIntegerBuffer( gBestFoundBufferI, SMALL_LIMIT, 0 )
  ProcInitIntegerBuffer( gBestLenBufferI, SMALL_LIMIT, 2147483647 )
  ProcInitIntegerBuffer( gBest1BufferI, SMALL_LIMIT, 0 )
  ProcInitIntegerBuffer( gBest2BufferI, SMALL_LIMIT, 0 )
  ProcInitIntegerBuffer( gBest3BufferI, SMALL_LIMIT, 0 )
  ProcInitIntegerBuffer( gBest4BufferI, SMALL_LIMIT, 0 )
  ProcInitIntegerBuffer( gBest5BufferI, SMALL_LIMIT, 0 )
  ProcInitIntegerBuffer( gBest6BufferI, SMALL_LIMIT, 0 )
  ProcInitIntegerBuffer( gBest7BufferI, SMALL_LIMIT, 0 )
  ProcInitIntegerBuffer( gBest8BufferI, SMALL_LIMIT, 0 )
  ProcInitIntegerBuffer( gBest9BufferI, SMALL_LIMIT, 0 )
END

PROC ProcFactoradicSetToOne()
  gCur1I = 1
  gCur2I = 0
  gCur3I = 0
  gCur4I = 0
  gCur5I = 0
  gCur6I = 0
  gCur7I = 0
  gCur8I = 0
  gCur9I = 0
END

PROC ProcFactoradicIncrement()
  gCur1I = gCur1I + 1
  IF gCur1I == 2
    gCur1I = 0
    gCur2I = gCur2I + 1
    IF gCur2I == 3
      gCur2I = 0
      gCur3I = gCur3I + 1
      IF gCur3I == 4
        gCur3I = 0
        gCur4I = gCur4I + 1
        IF gCur4I == 5
          gCur4I = 0
          gCur5I = gCur5I + 1
          IF gCur5I == 6
            gCur5I = 0
            gCur6I = gCur6I + 1
            IF gCur6I == 7
              gCur6I = 0
              gCur7I = gCur7I + 1
              IF gCur7I == 8
                gCur7I = 0
                gCur8I = gCur8I + 1
                IF gCur8I == 9
                  gCur8I = 0
                  gCur9I = gCur9I + 1
                ENDIF
              ENDIF
            ENDIF
          ENDIF
        ENDIF
      ENDIF
    ENDIF
  ENDIF
END

INTEGER PROC ProcCountTrailingNines( INTEGER numberI )
  INTEGER countI = 0
  INTEGER workI = 0
  workI = numberI
  WHILE ( workI mod 10 ) == 9
    countI = countI + 1
    workI = workI / 10
  ENDWHILE
  RETURN( countI )
END

INTEGER PROC ProcCurrentLength()
  RETURN(
    gCur1I + gCur2I + gCur3I + gCur4I +
    gCur5I + gCur6I + gCur7I + gCur8I + gCur9I
  )
END

INTEGER PROC ProcCandidateBeatsStored( INTEGER sumI )
  INTEGER foundI = 0
  INTEGER bestLenI = 0
  INTEGER best1I = 0
  INTEGER best2I = 0
  INTEGER best3I = 0
  INTEGER best4I = 0
  INTEGER best5I = 0
  INTEGER best6I = 0
  INTEGER best7I = 0
  INTEGER best8I = 0
  INTEGER best9I = 0
  INTEGER candLenI = 0

  foundI = ProcGetLineInteger( gBestFoundBufferI, sumI )
  IF NOT foundI
    RETURN( TRUE )
  ENDIF

  candLenI = ProcCurrentLength()
  bestLenI = ProcGetLineInteger( gBestLenBufferI, sumI )

  IF candLenI < bestLenI
    RETURN( TRUE )
  ENDIF
  IF candLenI > bestLenI
    RETURN( FALSE )
  ENDIF

  best1I = ProcGetLineInteger( gBest1BufferI, sumI )
  IF gCur1I > best1I
    RETURN( TRUE )
  ENDIF
  IF gCur1I < best1I
    RETURN( FALSE )
  ENDIF

  best2I = ProcGetLineInteger( gBest2BufferI, sumI )
  IF gCur2I > best2I
    RETURN( TRUE )
  ENDIF
  IF gCur2I < best2I
    RETURN( FALSE )
  ENDIF

  best3I = ProcGetLineInteger( gBest3BufferI, sumI )
  IF gCur3I > best3I
    RETURN( TRUE )
  ENDIF
  IF gCur3I < best3I
    RETURN( FALSE )
  ENDIF

  best4I = ProcGetLineInteger( gBest4BufferI, sumI )
  IF gCur4I > best4I
    RETURN( TRUE )
  ENDIF
  IF gCur4I < best4I
    RETURN( FALSE )
  ENDIF

  best5I = ProcGetLineInteger( gBest5BufferI, sumI )
  IF gCur5I > best5I
    RETURN( TRUE )
  ENDIF
  IF gCur5I < best5I
    RETURN( FALSE )
  ENDIF

  best6I = ProcGetLineInteger( gBest6BufferI, sumI )
  IF gCur6I > best6I
    RETURN( TRUE )
  ENDIF
  IF gCur6I < best6I
    RETURN( FALSE )
  ENDIF

  best7I = ProcGetLineInteger( gBest7BufferI, sumI )
  IF gCur7I > best7I
    RETURN( TRUE )
  ENDIF
  IF gCur7I < best7I
    RETURN( FALSE )
  ENDIF

  best8I = ProcGetLineInteger( gBest8BufferI, sumI )
  IF gCur8I > best8I
    RETURN( TRUE )
  ENDIF
  IF gCur8I < best8I
    RETURN( FALSE )
  ENDIF

  best9I = ProcGetLineInteger( gBest9BufferI, sumI )
  IF gCur9I > best9I
    RETURN( TRUE )
  ENDIF

  RETURN( FALSE )
END

PROC ProcStoreCurrentCandidate( INTEGER sumI )
  ProcSetLineInteger( gBestFoundBufferI, sumI, 1 )
  ProcSetLineInteger( gBestLenBufferI, sumI, ProcCurrentLength() )
  ProcSetLineInteger( gBest1BufferI, sumI, gCur1I )
  ProcSetLineInteger( gBest2BufferI, sumI, gCur2I )
  ProcSetLineInteger( gBest3BufferI, sumI, gCur3I )
  ProcSetLineInteger( gBest4BufferI, sumI, gCur4I )
  ProcSetLineInteger( gBest5BufferI, sumI, gCur5I )
  ProcSetLineInteger( gBest6BufferI, sumI, gCur6I )
  ProcSetLineInteger( gBest7BufferI, sumI, gCur7I )
  ProcSetLineInteger( gBest8BufferI, sumI, gCur8I )
  ProcSetLineInteger( gBest9BufferI, sumI, gCur9I )
END

PROC ProcBuildSmallExactAnswers()
  INTEGER yI = 0
  INTEGER sumYI = 0
  INTEGER trailing9I = 0

  ProcInitBestBuffers()
  yI = 1
  sumYI = 1
  ProcFactoradicSetToOne()

  WHILE yI <= SMALL_Y_MAX
    IF ProcCandidateBeatsStored( sumYI )
      ProcStoreCurrentCandidate( sumYI )
    ENDIF

    IF yI < SMALL_Y_MAX
      trailing9I = ProcCountTrailingNines( yI )
      sumYI = sumYI + 1 - 9 * trailing9I
      yI = yI + 1
      ProcFactoradicIncrement()
    ELSE
      yI = yI + 1
    ENDIF
  ENDWHILE
END

STRING PROC ProcBuildSmallSgString( INTEGER sumI )
  INTEGER best1I = 0
  INTEGER best2I = 0
  INTEGER best3I = 0
  INTEGER best4I = 0
  INTEGER best5I = 0
  INTEGER best6I = 0
  INTEGER best7I = 0
  INTEGER best8I = 0
  INTEGER best9I = 0
  INTEGER sgI = 0
  STRING resultS[255] = ""

  best1I = ProcGetLineInteger( gBest1BufferI, sumI )
  best2I = ProcGetLineInteger( gBest2BufferI, sumI )
  best3I = ProcGetLineInteger( gBest3BufferI, sumI )
  best4I = ProcGetLineInteger( gBest4BufferI, sumI )
  best5I = ProcGetLineInteger( gBest5BufferI, sumI )
  best6I = ProcGetLineInteger( gBest6BufferI, sumI )
  best7I = ProcGetLineInteger( gBest7BufferI, sumI )
  best8I = ProcGetLineInteger( gBest8BufferI, sumI )
  best9I = ProcGetLineInteger( gBest9BufferI, sumI )

  sgI =
    1 * best1I +
    2 * best2I +
    3 * best3I +
    4 * best4I +
    5 * best5I +
    6 * best6I +
    7 * best7I +
    8 * best8I +
    9 * best9I

  resultS = Str( sgI )
  RETURN( resultS )
END

STRING PROC ProcRepeatDigit( INTEGER digitI, INTEGER countI )
  STRING resultS[255] = ""
  INTEGER indexI = 0
  resultS = ""
  FOR indexI = 1 TO countI
    resultS = resultS + ProcIntegerToDigit( digitI )
  ENDFOR
  RETURN( resultS )
END

STRING PROC ProcBuildLargeYString( INTEGER targetI )
  INTEGER firstDigitI = 0
  INTEGER nineCountI = 0
  STRING yS[255] = ""
  firstDigitI = ( ( targetI - 1 ) mod 9 ) + 1
  nineCountI = ( targetI - firstDigitI ) / 9
  yS = ProcIntegerToDigit( firstDigitI ) + ProcRepeatDigit( 9, nineCountI )
  RETURN( yS )
END

PROC ProcDivideDecimalStringByFact9( STRING numberS )
  INTEGER indexI = 0
  INTEGER currentI = 0
  INTEGER qDigitI = 0
  INTEGER startedB = FALSE
  STRING oneCharS[2] = ""
  gDivisionQuotientS = ""
  gDivisionRemainderI = 0

  FOR indexI = 1 TO Length( numberS )
    oneCharS = SubStr( numberS, indexI, 1 )
    currentI = gDivisionRemainderI * 10 + ProcDigitCharToInteger( oneCharS )
    qDigitI = currentI / FACT9
    gDivisionRemainderI = currentI mod FACT9
    IF qDigitI > 0 OR startedB
      gDivisionQuotientS = gDivisionQuotientS + ProcIntegerToDigit( qDigitI )
      startedB = TRUE
    ENDIF
  ENDFOR

  IF NOT startedB
    gDivisionQuotientS = "0"
  ENDIF

  gDivisionQuotientS = ProcTrimLeadingZeros( gDivisionQuotientS )
END

PROC ProcDecodeRemainderCounts( INTEGER remainderI )
  INTEGER facI = 0
  gLarge1I = 0
  gLarge2I = 0
  gLarge3I = 0
  gLarge4I = 0
  gLarge5I = 0
  gLarge6I = 0
  gLarge7I = 0
  gLarge8I = 0

  facI = FACT9

  facI = facI / 9
  gLarge8I = remainderI / facI
  remainderI = remainderI mod facI

  facI = facI / 8
  gLarge7I = remainderI / facI
  remainderI = remainderI mod facI

  facI = facI / 7
  gLarge6I = remainderI / facI
  remainderI = remainderI mod facI

  facI = facI / 6
  gLarge5I = remainderI / facI
  remainderI = remainderI mod facI

  facI = facI / 5
  gLarge4I = remainderI / facI
  remainderI = remainderI mod facI

  facI = facI / 4
  gLarge3I = remainderI / facI
  remainderI = remainderI mod facI

  facI = facI / 3
  gLarge2I = remainderI / facI
  remainderI = remainderI mod facI

  facI = facI / 2
  gLarge1I = remainderI / facI
END

STRING PROC ProcBuildLargeSgString( INTEGER targetI )
  STRING yS[255] = ""
  STRING resultS[255] = ""
  INTEGER smallI = 0

  yS = ProcBuildLargeYString( targetI )
  ProcDivideDecimalStringByFact9( yS )
  ProcDecodeRemainderCounts( gDivisionRemainderI )

  resultS = ProcMultiplyDecimalStringBySmall( gDivisionQuotientS, 9 )

  smallI =
    1 * gLarge1I +
    2 * gLarge2I +
    3 * gLarge3I +
    4 * gLarge4I +
    5 * gLarge5I +
    6 * gLarge6I +
    7 * gLarge7I +
    8 * gLarge8I

  resultS = ProcAddSmallToDecimalString( resultS, smallI )
  RETURN( resultS )
END

PROC Main()
  INTEGER indexI = 0
  STRING totalS[255] = ""
  STRING addS[255] = ""

  ProcBuildSmallExactAnswers()

  totalS = "0"

  FOR indexI = 1 TO SMALL_LIMIT
    addS = ProcBuildSmallSgString( indexI )
    totalS = ProcAddDecimalStrings( totalS, addS )
  ENDFOR

  FOR indexI = 64 TO 150
    addS = ProcBuildLargeSgString( indexI )
    totalS = ProcAddDecimalStrings( totalS, addS )
  ENDFOR

  CopyToWinClip( totalS )
  Warn( totalS )
  CopyToWinClip( totalS )
END
