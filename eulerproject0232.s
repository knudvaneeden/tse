/*
  Euler Project 232 - The Race
  Pure TSE SAL solution
  Version: 1
  History:
    1 - Created by ChatGPT GPT-5.4 Thinking on 2026-03-31

  Expected displayed result after calculation:
    0.83648556
*/

#define MAX_SCORE 100
#define TOTAL_STATES 10000
#define SCALE_DIGITS 24

FORWARD STRING PROC ProcDigitToString( INTEGER digitI )
FORWARD STRING PROC ProcTrimLeadingZeros( STRING inputS )
FORWARD STRING PROC ProcPadLeftZeros( STRING inputS, INTEGER targetLengthI )
FORWARD INTEGER PROC ProcCompareUnsigned( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcAddUnsigned( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcMultiplyUnsignedSmall( STRING numberS, INTEGER factorI )
FORWARD STRING PROC ProcDivideUnsignedSmall( STRING numberS, INTEGER divisorI )
FORWARD INTEGER PROC ProcStateIndex( INTEGER needOneI, INTEGER needTwoI )
FORWARD STRING PROC ProcGetState( INTEGER needOneI, INTEGER needTwoI )
FORWARD PROC ProcSetState( INTEGER needOneI, INTEGER needTwoI, STRING valueS )
FORWARD STRING PROC ProcComputeCurrent( STRING scoreA1NextS, STRING scoreANextS, STRING scoreA1SameS, INTEGER betI )
FORWARD STRING PROC ProcFormatScaledTo8( STRING scaledS )
FORWARD PROC ProcInitialize()
FORWARD PROC Main()

INTEGER gStateBufferIdI = 0
STRING gOneScaleS[255] = ""
STRING gZeroS[255] = "0"

STRING PROC ProcDigitToString( INTEGER digitI )
  STRING resultS[2] = ""
  resultS = Chr( 48 + digitI )
  RETURN( resultS )
END

STRING PROC ProcTrimLeadingZeros( STRING inputS )
  STRING workS[255] = ""
  INTEGER indexI = 1
  workS = inputS
  WHILE ( indexI < Length( workS ) ) AND ( SubStr( workS, indexI, 1 ) == "0" )
    indexI = indexI + 1
  ENDWHILE
  RETURN( SubStr( workS, indexI, Length( workS ) - indexI + 1 ) )
END

STRING PROC ProcPadLeftZeros( STRING inputS, INTEGER targetLengthI )
  STRING workS[255] = ""
  workS = inputS
  WHILE Length( workS ) < targetLengthI
    workS = "0" + workS
  ENDWHILE
  RETURN( workS )
END

INTEGER PROC ProcCompareUnsigned( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  INTEGER lengthLeftI = 0
  INTEGER lengthRightI = 0
  INTEGER indexI = 0

  leftWorkS  = ProcTrimLeadingZeros( leftS )
  rightWorkS = ProcTrimLeadingZeros( rightS )

  lengthLeftI  = Length( leftWorkS )
  lengthRightI = Length( rightWorkS )

  IF lengthLeftI < lengthRightI
    RETURN( -1 )
  ENDIF
  IF lengthLeftI > lengthRightI
    RETURN( 1 )
  ENDIF

  FOR indexI = 1 TO lengthLeftI
    IF SubStr( leftWorkS, indexI, 1 ) < SubStr( rightWorkS, indexI, 1 )
      RETURN( -1 )
    ENDIF
    IF SubStr( leftWorkS, indexI, 1 ) > SubStr( rightWorkS, indexI, 1 )
      RETURN( 1 )
    ENDIF
  ENDFOR

  RETURN( 0 )
END

STRING PROC ProcAddUnsigned( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  STRING resultS[255] = ""
  INTEGER indexLeftI = 0
  INTEGER indexRightI = 0
  INTEGER carryI = 0
  INTEGER digitLeftI = 0
  INTEGER digitRightI = 0
  INTEGER sumI = 0
  INTEGER digitI = 0

  leftWorkS  = ProcTrimLeadingZeros( leftS )
  rightWorkS = ProcTrimLeadingZeros( rightS )

  indexLeftI  = Length( leftWorkS )
  indexRightI = Length( rightWorkS )

  WHILE ( indexLeftI > 0 ) OR ( indexRightI > 0 ) OR ( carryI > 0 )
    digitLeftI  = 0
    digitRightI = 0

    IF indexLeftI > 0
      digitLeftI = Val( SubStr( leftWorkS, indexLeftI, 1 ) )
      indexLeftI = indexLeftI - 1
    ENDIF
    IF indexRightI > 0
      digitRightI = Val( SubStr( rightWorkS, indexRightI, 1 ) )
      indexRightI = indexRightI - 1
    ENDIF

    sumI   = digitLeftI + digitRightI + carryI
    digitI = sumI mod 10
    carryI = sumI / 10

    resultS = ProcDigitToString( digitI ) + resultS
  ENDWHILE

  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcMultiplyUnsignedSmall( STRING numberS, INTEGER factorI )
  STRING workS[255] = ""
  STRING resultS[255] = ""
  STRING carryPartS[255] = ""
  INTEGER indexI = 0
  INTEGER digitI = 0
  INTEGER productI = 0
  INTEGER carryI = 0
  INTEGER remainderI = 0

  workS = ProcTrimLeadingZeros( numberS )

  IF factorI == 0
    RETURN( "0" )
  ENDIF
  IF factorI == 1
    RETURN( workS )
  ENDIF
  IF workS == "0"
    RETURN( "0" )
  ENDIF

  indexI = Length( workS )
  WHILE indexI > 0
    digitI = Val( SubStr( workS, indexI, 1 ) )
    productI = digitI * factorI + carryI
    remainderI = productI mod 10
    carryI = productI / 10
    resultS = ProcDigitToString( remainderI ) + resultS
    indexI = indexI - 1
  ENDWHILE

  WHILE carryI > 0
    carryPartS = ProcDigitToString( carryI mod 10 ) + carryPartS
    carryI = carryI / 10
  ENDWHILE

  resultS = carryPartS + resultS
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcDivideUnsignedSmall( STRING numberS, INTEGER divisorI )
  STRING workS[255] = ""
  STRING resultS[255] = ""
  INTEGER indexI = 0
  INTEGER digitI = 0
  INTEGER currentI = 0
  INTEGER quotientDigitI = 0
  INTEGER remainderI = 0
  INTEGER startedB = FALSE

  workS = ProcTrimLeadingZeros( numberS )

  IF workS == "0"
    RETURN( "0" )
  ENDIF

  FOR indexI = 1 TO Length( workS )
    digitI = Val( SubStr( workS, indexI, 1 ) )
    currentI = remainderI * 10 + digitI
    quotientDigitI = currentI / divisorI
    remainderI = currentI mod divisorI

    IF ( quotientDigitI > 0 ) OR startedB
      resultS = resultS + ProcDigitToString( quotientDigitI )
      startedB = TRUE
    ENDIF
  ENDFOR

  IF NOT startedB
    resultS = "0"
  ENDIF

  RETURN( ProcTrimLeadingZeros( resultS ) )
END

INTEGER PROC ProcStateIndex( INTEGER needOneI, INTEGER needTwoI )
  RETURN( ( needOneI - 1 ) * MAX_SCORE + needTwoI )
END

STRING PROC ProcGetState( INTEGER needOneI, INTEGER needTwoI )
  STRING lineS[255] = ""
  INTEGER indexI = 0

  IF needTwoI <= 0
    RETURN( gOneScaleS )
  ENDIF
  IF needOneI <= 0
    RETURN( "0" )
  ENDIF

  indexI = ProcStateIndex( needOneI, needTwoI )

  PushLocation()
  GotoBufferId( gStateBufferIdI )
  GotoLine( indexI )
  IF CurrLineLen() > 0
    lineS = GetText( 1, CurrLineLen() )
  ELSE
    lineS = "0"
  ENDIF
  PopLocation()

  RETURN( lineS )
END

PROC ProcSetState( INTEGER needOneI, INTEGER needTwoI, STRING valueS )
  INTEGER indexI = 0
  STRING workS[255] = ""

  IF ( needOneI <= 0 ) OR ( needTwoI <= 0 )
    RETURN()
  ENDIF

  indexI = ProcStateIndex( needOneI, needTwoI )
  workS = ProcTrimLeadingZeros( valueS )

  PushLocation()
  GotoBufferId( gStateBufferIdI )
  GotoLine( indexI )
  BegLine()
  KillToEol()
  InsertText( workS, _DONT_PROMPT_ )
  PopLocation()
END

STRING PROC ProcComputeCurrent( STRING scoreA1NextS, STRING scoreANextS, STRING scoreA1SameS, INTEGER betI )
  STRING part1S[255] = ""
  STRING part2S[255] = ""
  STRING numeratorS[255] = ""
  STRING currentS[255] = ""
  INTEGER multiplierI = 0
  INTEGER divisorI = 0

  multiplierI = 2 * betI - 1
  divisorI    = 2 * betI + 1

  part1S = ProcAddUnsigned( scoreA1NextS, scoreANextS )
  part2S = ProcMultiplyUnsignedSmall( scoreA1SameS, multiplierI )
  numeratorS = ProcAddUnsigned( part1S, part2S )
  currentS = ProcDivideUnsignedSmall( numeratorS, divisorI )

  RETURN( currentS )
END

STRING PROC ProcFormatScaledTo8( STRING scaledS )
  STRING paddedS[255] = ""
  STRING firstEightS[16] = ""
  STRING ninthS[2] = ""
  STRING roundedS[16] = ""
  STRING workS[255] = ""
  INTEGER indexI = 0
  INTEGER carryI = 0
  INTEGER digitI = 0

  paddedS = ProcPadLeftZeros( ProcTrimLeadingZeros( scaledS ), SCALE_DIGITS )

  firstEightS = SubStr( paddedS, 1, 8 )
  ninthS      = SubStr( paddedS, 9, 1 )

  IF Val( ninthS ) >= 5
    carryI = 1
    FOR indexI = 8 DOWNTO 1
      digitI = Val( SubStr( firstEightS, indexI, 1 ) ) + carryI
      IF digitI >= 10
        digitI = digitI - 10
        carryI = 1
      ELSE
        carryI = 0
      ENDIF
      roundedS = ProcDigitToString( digitI ) + roundedS
    ENDFOR
    IF carryI > 0
      roundedS = "100000000"
      RETURN( "1.00000000" )
    ENDIF
  ELSE
    roundedS = firstEightS
  ENDIF

  workS = "0." + roundedS
  RETURN( workS )
END

PROC ProcInitialize()
  INTEGER indexI = 0
  STRING zeroLineS[2] = "0"

  gStateBufferIdI = CreateTempBuffer()
  gOneScaleS = "1"
  FOR indexI = 1 TO SCALE_DIGITS
    gOneScaleS = gOneScaleS + "0"
  ENDFOR

  PushLocation()
  GotoBufferId( gStateBufferIdI )
  FOR indexI = 1 TO TOTAL_STATES
    AddLine( zeroLineS, gStateBufferIdI )
  ENDFOR
  PopLocation()
END

PROC Main()
  INTEGER needOneI = 0
  INTEGER needTwoI = 0
  INTEGER betI = 0
  INTEGER nextNeedTwoI = 0
  STRING bestS[255] = ""
  STRING currentS[255] = ""
  STRING scoreA1NextS[255] = ""
  STRING scoreANextS[255] = ""
  STRING scoreA1SameS[255] = ""
  STRING sumInitialS[255] = ""
  STRING resultS[255] = ""

  ProcInitialize()

  FOR needOneI = 1 TO MAX_SCORE
    FOR needTwoI = 1 TO MAX_SCORE
      bestS = "0"
      betI = 1

      WHILE TRUE
        nextNeedTwoI = needTwoI - betI
        IF nextNeedTwoI < 0
          nextNeedTwoI = 0
        ENDIF

        scoreA1NextS = ProcGetState( needOneI - 1, nextNeedTwoI )
        scoreANextS  = ProcGetState( needOneI,     nextNeedTwoI )
        scoreA1SameS = ProcGetState( needOneI - 1, needTwoI )

        currentS = ProcComputeCurrent( scoreA1NextS, scoreANextS, scoreA1SameS, betI )

        IF ProcCompareUnsigned( currentS, bestS ) > 0
          bestS = currentS
        ENDIF

        IF nextNeedTwoI == 0
          BREAK
        ENDIF

        betI = betI * 2
      ENDWHILE

      ProcSetState( needOneI, needTwoI, bestS )
    ENDFOR
  ENDFOR

  sumInitialS = ProcAddUnsigned( ProcGetState( MAX_SCORE - 1, MAX_SCORE ), ProcGetState( MAX_SCORE, MAX_SCORE ) )
  resultS = ProcFormatScaledTo8( ProcDivideUnsignedSmall( sumInitialS, 2 ) )

  CopyToWinClip( resultS )
  Warn( resultS )
  CopyToWinClip( resultS )

  AbandonFile( gStateBufferIdI )
END
