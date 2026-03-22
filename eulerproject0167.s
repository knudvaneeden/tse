/*
  Euler Project 167
  Investigating Ulam Sequences
  Pure TSE SAL solution
  <version>1.0.0.0.3</version>

  Notes:
  - Final Warn() box shows only the final numeric answer
  - Two CopyToWinClip() calls are kept, before and after Warn()
  - Pure TSE SAL only
  - No semicolons at line ends
  - No own variable names val / pos
  - Return() always with parentheses
  - PROC Main() is last
  - String sizes are explicit and <= 255
  - No SAL arrays used

  Expected final result:
  3916160068885

  History:
  - 1.0.0.0.3  Final Warn() now shows only the answer
  - 1.0.0.0.2  Shortened final Warn() text so all lines fit better
  - 1.0.0.0.1  Corrected invalid FOR syntax
  - 1.0.0.0.0  Created by ChatGPT GPT-5.4 Thinking
*/

FORWARD STRING PROC ProcTrimLeadingZeros( STRING numberS )
FORWARD STRING PROC ProcDigitToString( INTEGER digitI )
FORWARD STRING PROC ProcIntegerToString( INTEGER numberI )
FORWARD STRING PROC ProcAddBigIntegers( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcSubtractBigIntegers( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcSubtractBigIntegerBySmall( STRING leftS, INTEGER rightI )
FORWARD STRING PROC ProcMultiplyBigIntegerBySmall( STRING numberS, INTEGER multiplierI )
FORWARD STRING PROC ProcDivideBigIntegerBySmall( STRING numberS, INTEGER divisorI )
FORWARD INTEGER PROC ProcBuildInitialState( INTEGER bI )
FORWARD INTEGER PROC ProcTransitionStateAndGetNextBit( INTEGER stateI, INTEGER widthI )
FORWARD PROC ProcCalculateCycleData( INTEGER bI )
FORWARD INTEGER PROC ProcFindBitIndexOfNthOneInCycle( INTEGER bI, INTEGER targetOneI )
FORWARD STRING PROC ProcCalculateUlamTermString( INTEGER bI, STRING kS )

INTEGER gDivideRemainderI = 0
INTEGER gBitPeriodI = 0
INTEGER gOnesPerPeriodI = 0
STRING gKValueGS[255] = "100000000000"
STRING gExpectedAnswerGS[255] = "3916160068885"

STRING PROC ProcTrimLeadingZeros( STRING numberS )
 STRING workS[255] = ""
 INTEGER indexI = 1
 INTEGER lengthI = 0
 //
 workS = numberS
 lengthI = Length( workS )
 WHILE indexI < lengthI AND SubStr( workS, indexI, 1 ) == "0"
  indexI = indexI + 1
 ENDWHILE
 Return( SubStr( workS, indexI, lengthI - indexI + 1 ) )
END

STRING PROC ProcDigitToString( INTEGER digitI )
 STRING resultS[2] = ""
 //
 resultS = Chr( 48 + digitI )
 Return( resultS )
END

STRING PROC ProcIntegerToString( INTEGER numberI )
 STRING resultS[255] = ""
 INTEGER workI = 0
 INTEGER digitI = 0
 //
 workI = numberI
 IF workI == 0
  Return( "0" )
 ENDIF
 WHILE workI > 0
  digitI = workI mod 10
  resultS = ProcDigitToString( digitI ) + resultS
  workI = workI / 10
 ENDWHILE
 Return( resultS )
END

STRING PROC ProcAddBigIntegers( STRING leftS, STRING rightS )
 STRING aS[255] = ""
 STRING bS[255] = ""
 STRING resultS[255] = ""
 INTEGER indexAI = 0
 INTEGER indexBI = 0
 INTEGER digitAI = 0
 INTEGER digitBI = 0
 INTEGER carryI = 0
 INTEGER sumI = 0
 INTEGER lengthAI = 0
 INTEGER lengthBI = 0
 //
 aS = ProcTrimLeadingZeros( leftS )
 bS = ProcTrimLeadingZeros( rightS )
 lengthAI = Length( aS )
 lengthBI = Length( bS )
 indexAI = lengthAI
 indexBI = lengthBI
 WHILE indexAI >= 1 OR indexBI >= 1 OR carryI > 0
  digitAI = 0
  digitBI = 0
  IF indexAI >= 1
   digitAI = Asc( SubStr( aS, indexAI, 1 ) ) - 48
   indexAI = indexAI - 1
  ENDIF
  IF indexBI >= 1
   digitBI = Asc( SubStr( bS, indexBI, 1 ) ) - 48
   indexBI = indexBI - 1
  ENDIF
  sumI = digitAI + digitBI + carryI
  resultS = ProcDigitToString( sumI mod 10 ) + resultS
  carryI = sumI / 10
 ENDWHILE
 Return( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcSubtractBigIntegers( STRING leftS, STRING rightS )
 STRING aS[255] = ""
 STRING bS[255] = ""
 STRING resultS[255] = ""
 INTEGER indexAI = 0
 INTEGER indexBI = 0
 INTEGER digitAI = 0
 INTEGER digitBI = 0
 INTEGER borrowI = 0
 INTEGER diffI = 0
 //
 aS = ProcTrimLeadingZeros( leftS )
 bS = ProcTrimLeadingZeros( rightS )
 indexAI = Length( aS )
 indexBI = Length( bS )
 WHILE indexAI >= 1
  digitAI = Asc( SubStr( aS, indexAI, 1 ) ) - 48
  digitBI = 0
  IF indexBI >= 1
   digitBI = Asc( SubStr( bS, indexBI, 1 ) ) - 48
   indexBI = indexBI - 1
  ENDIF
  diffI = digitAI - borrowI - digitBI
  IF diffI < 0
   diffI = diffI + 10
   borrowI = 1
  ELSE
   borrowI = 0
  ENDIF
  resultS = ProcDigitToString( diffI ) + resultS
  indexAI = indexAI - 1
 ENDWHILE
 Return( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcSubtractBigIntegerBySmall( STRING leftS, INTEGER rightI )
 STRING rightS[255] = ""
 //
 rightS = ProcIntegerToString( rightI )
 Return( ProcSubtractBigIntegers( leftS, rightS ) )
END

STRING PROC ProcMultiplyBigIntegerBySmall( STRING numberS, INTEGER multiplierI )
 STRING workS[255] = ""
 STRING resultS[255] = ""
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER carryI = 0
 INTEGER productI = 0
 //
 workS = ProcTrimLeadingZeros( numberS )
 IF workS == "0" OR multiplierI == 0
  Return( "0" )
 ENDIF
 indexI = Length( workS )
 WHILE indexI >= 1 OR carryI > 0
  digitI = 0
  IF indexI >= 1
   digitI = Asc( SubStr( workS, indexI, 1 ) ) - 48
   indexI = indexI - 1
  ENDIF
  productI = digitI * multiplierI + carryI
  resultS = ProcDigitToString( productI mod 10 ) + resultS
  carryI = productI / 10
 ENDWHILE
 Return( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcDivideBigIntegerBySmall( STRING numberS, INTEGER divisorI )
 STRING workS[255] = ""
 STRING quotientS[255] = ""
 INTEGER indexI = 0
 INTEGER currentI = 0
 INTEGER quotientDigitI = 0
 INTEGER startedB = FALSE
 INTEGER digitI = 0
 //
 workS = ProcTrimLeadingZeros( numberS )
 gDivideRemainderI = 0
 FOR indexI = 1 TO Length( workS )
  digitI = Asc( SubStr( workS, indexI, 1 ) ) - 48
  currentI = gDivideRemainderI * 10 + digitI
  quotientDigitI = currentI / divisorI
  gDivideRemainderI = currentI mod divisorI
  IF quotientDigitI > 0 OR startedB
   quotientS = quotientS + ProcDigitToString( quotientDigitI )
   startedB = TRUE
  ENDIF
 ENDFOR
 IF NOT startedB
  quotientS = "0"
 ENDIF
 Return( ProcTrimLeadingZeros( quotientS ) )
END

INTEGER PROC ProcBuildInitialState( INTEGER bI )
 INTEGER firstOneI = 0
 INTEGER bitI = 0
 INTEGER stateI = 0
 //
 firstOneI = ( bI - 1 ) / 2
 FOR bitI = firstOneI TO bI
  stateI = stateI | ( 1 shl bitI )
 ENDFOR
 Return( stateI )
END

INTEGER PROC ProcTransitionStateAndGetNextBit( INTEGER stateI, INTEGER widthI )
 INTEGER oldestBitI = 0
 INTEGER newestBitI = 0
 INTEGER nextBitI = 0
 //
 oldestBitI = stateI & 1
 newestBitI = ( stateI shr ( widthI - 1 ) ) & 1
 nextBitI = oldestBitI ^ newestBitI
 Return( nextBitI )
END

PROC ProcCalculateCycleData( INTEGER bI )
 INTEGER widthI = 0
 INTEGER initialStateI = 0
 INTEGER stateI = 0
 INTEGER nextBitI = 0
 //
 widthI = bI + 1
 initialStateI = ProcBuildInitialState( bI )
 stateI = initialStateI
 gBitPeriodI = 0
 gOnesPerPeriodI = 0
 REPEAT
  nextBitI = ProcTransitionStateAndGetNextBit( stateI, widthI )
  stateI = stateI shr 1
  IF nextBitI == 1
   stateI = stateI | ( 1 shl ( widthI - 1 ) )
   gOnesPerPeriodI = gOnesPerPeriodI + 1
  ENDIF
  gBitPeriodI = gBitPeriodI + 1
 UNTIL stateI == initialStateI
END

INTEGER PROC ProcFindBitIndexOfNthOneInCycle( INTEGER bI, INTEGER targetOneI )
 INTEGER widthI = 0
 INTEGER stateI = 0
 INTEGER nextBitI = 0
 INTEGER seenOnesI = 0
 INTEGER bitIndexI = -1
 //
 widthI = bI + 1
 stateI = ProcBuildInitialState( bI )
 WHILE TRUE
  nextBitI = ProcTransitionStateAndGetNextBit( stateI, widthI )
  stateI = stateI shr 1
  bitIndexI = bitIndexI + 1
  IF nextBitI == 1
   stateI = stateI | ( 1 shl ( widthI - 1 ) )
   seenOnesI = seenOnesI + 1
   IF seenOnesI == targetOneI
    Return( bitIndexI )
   ENDIF
  ENDIF
 ENDWHILE
 Return( -1 )
END

STRING PROC ProcCalculateUlamTermString( INTEGER bI, STRING kS )
 STRING distS[255] = ""
 STRING cycleCountS[255] = ""
 STRING termS[255] = ""
 INTEGER prefixCountI = 0
 INTEGER targetOneI = 0
 INTEGER bitIndexI = 0
 INTEGER localValueI = 0
 //
 ProcCalculateCycleData( bI )
 prefixCountI = ( bI + 7 ) / 2
 distS = ProcSubtractBigIntegerBySmall( kS, prefixCountI + 1 )
 cycleCountS = ProcDivideBigIntegerBySmall( distS, gOnesPerPeriodI )
 targetOneI = gDivideRemainderI + 1
 bitIndexI = ProcFindBitIndexOfNthOneInCycle( bI, targetOneI )
 localValueI = 2 * bI + 3 + 2 * bitIndexI
 termS = ProcMultiplyBigIntegerBySmall( cycleCountS, 2 * gBitPeriodI )
 termS = ProcAddBigIntegers( termS, ProcIntegerToString( localValueI ) )
 Return( ProcTrimLeadingZeros( termS ) )
END

PROC Main()
 STRING sumS[255] = "0"
 STRING termS[255] = ""
 INTEGER bI = 0
 //
 FOR bI = 5 TO 21
  IF bI mod 2 == 1
   termS = ProcCalculateUlamTermString( bI, gKValueGS )
   sumS = ProcAddBigIntegers( sumS, termS )
  ENDIF
 ENDFOR
 CopyToWinClip( sumS )
 Warn( sumS )
 CopyToWinClip( sumS )
END
