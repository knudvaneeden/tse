/*
  Euler Project problem 199
  Iterative Circle Packing
  Pure TSE SAL
  <version>1.0.0.0.6</version>

  History:
  1.0.0.0.6  2026-03-25  Replaced incorrect recursion with proper Descartes quadruple tree traversal, created by GPT-5.4 Thinking
*/

#define SCALE_DIGITS 14

STRING gScaleS[255] = ""
STRING gSqrt3S[255] = ""
STRING gOuterAbsS[255] = ""
STRING gOuterSqS[255] = ""
STRING gAreaSumS[255] = ""

FORWARD STRING PROC ProcRepeatChar( STRING charS, INTEGER countI )
FORWARD STRING PROC ProcTrimLeadingZeros( STRING numberS )
FORWARD STRING PROC ProcAbsString( STRING numberS )
FORWARD INTEGER PROC ProcIsNegative( STRING numberS )
FORWARD STRING PROC ProcNegateString( STRING numberS )
FORWARD INTEGER PROC ProcComparePositive( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcAddPositive( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcSubtractPositive( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcAddSigned( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcSubtractSigned( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcMultiplyPositiveByDigit( STRING leftS, INTEGER digitI )
FORWARD STRING PROC ProcMultiplyPositive( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcDividePositive( STRING dividendS, STRING divisorS )
FORWARD STRING PROC ProcDividePositiveBy2( STRING dividendS )
FORWARD STRING PROC ProcShiftLeft10( STRING numberS, INTEGER countI )
FORWARD STRING PROC ProcFixedOne()
FORWARD STRING PROC ProcFixedFromInteger( INTEGER numberI )
FORWARD STRING PROC ProcFixedAdd( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcFixedSubtract( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcFixedMultiply( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcFixedDivide( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcFixedSquare( STRING numberS )
FORWARD STRING PROC ProcFixedSqrt( STRING numberS )
FORWARD STRING PROC ProcFormatFixed8( STRING numberS )
FORWARD STRING PROC ProcPairToFixed( INTEGER aI, INTEGER bI )
FORWARD PROC ProcAddCircleAreaRatio( INTEGER aI, INTEGER bI )
FORWARD PROC ProcGenerate( INTEGER a0I, INTEGER b0I, INTEGER a1I, INTEGER b1I, INTEGER a2I, INTEGER b2I, INTEGER a3I, INTEGER b3I, INTEGER skipIndexI, INTEGER depthI )
FORWARD STRING PROC ProcGetFinalAnswer()

STRING PROC ProcRepeatChar( STRING charS, INTEGER countI )
 STRING resultS[255] = ""
 INTEGER indexI = 0
 FOR indexI = 1 TO countI BY 1
  resultS = resultS + charS
 ENDFOR
 RETURN( resultS )
END

STRING PROC ProcTrimLeadingZeros( STRING numberS )
 STRING workS[255] = numberS
 STRING signS[2] = ""
 INTEGER indexI = 1
 INTEGER lengthI = 0
 IF workS == ""
  RETURN( "0" )
 ENDIF
 IF SubStr( workS, 1, 1 ) == "-"
  signS = "-"
  workS = SubStr( workS, 2, Length( workS ) - 1 )
 ENDIF
 lengthI = Length( workS )
 indexI = 1
 WHILE indexI < lengthI AND SubStr( workS, indexI, 1 ) == "0"
  indexI = indexI + 1
 ENDWHILE
 workS = SubStr( workS, indexI, lengthI - indexI + 1 )
 IF workS == ""
  RETURN( "0" )
 ENDIF
 IF workS == "0"
  RETURN( "0" )
 ENDIF
 RETURN( signS + workS )
END

STRING PROC ProcAbsString( STRING numberS )
 STRING workS[255] = ProcTrimLeadingZeros( numberS )
 IF SubStr( workS, 1, 1 ) == "-"
  RETURN( SubStr( workS, 2, Length( workS ) - 1 ) )
 ENDIF
 RETURN( workS )
END

INTEGER PROC ProcIsNegative( STRING numberS )
 STRING workS[255] = ProcTrimLeadingZeros( numberS )
 IF Length( workS ) > 0 AND SubStr( workS, 1, 1 ) == "-"
  RETURN( TRUE )
 ENDIF
 RETURN( FALSE )
END

STRING PROC ProcNegateString( STRING numberS )
 STRING workS[255] = ProcTrimLeadingZeros( numberS )
 IF workS == "0"
  RETURN( "0" )
 ENDIF
 IF ProcIsNegative( workS )
  RETURN( ProcAbsString( workS ) )
 ENDIF
 RETURN( "-" + workS )
END

INTEGER PROC ProcComparePositive( STRING leftS, STRING rightS )
 STRING leftWorkS[255] = ProcTrimLeadingZeros( leftS )
 STRING rightWorkS[255] = ProcTrimLeadingZeros( rightS )
 INTEGER leftLenI = Length( leftWorkS )
 INTEGER rightLenI = Length( rightWorkS )
 INTEGER indexI = 0
 IF leftLenI < rightLenI
  RETURN( -1 )
 ENDIF
 IF leftLenI > rightLenI
  RETURN( 1 )
 ENDIF
 FOR indexI = 1 TO leftLenI BY 1
  IF SubStr( leftWorkS, indexI, 1 ) < SubStr( rightWorkS, indexI, 1 )
   RETURN( -1 )
  ENDIF
  IF SubStr( leftWorkS, indexI, 1 ) > SubStr( rightWorkS, indexI, 1 )
   RETURN( 1 )
  ENDIF
 ENDFOR
 RETURN( 0 )
END

STRING PROC ProcAddPositive( STRING leftS, STRING rightS )
 STRING leftWorkS[255] = ProcAbsString( leftS )
 STRING rightWorkS[255] = ProcAbsString( rightS )
 STRING resultS[255] = ""
 INTEGER carryI = 0
 INTEGER leftIndexI = Length( leftWorkS )
 INTEGER rightIndexI = Length( rightWorkS )
 INTEGER digitLeftI = 0
 INTEGER digitRightI = 0
 INTEGER sumI = 0
 WHILE leftIndexI > 0 OR rightIndexI > 0 OR carryI > 0
  digitLeftI = 0
  digitRightI = 0
  IF leftIndexI > 0
   digitLeftI = Val( SubStr( leftWorkS, leftIndexI, 1 ) )
   leftIndexI = leftIndexI - 1
  ENDIF
  IF rightIndexI > 0
   digitRightI = Val( SubStr( rightWorkS, rightIndexI, 1 ) )
   rightIndexI = rightIndexI - 1
  ENDIF
  sumI = digitLeftI + digitRightI + carryI
  resultS = Chr( Asc( "0" ) + ( sumI mod 10 ) ) + resultS
  carryI = sumI / 10
 ENDWHILE
 RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcSubtractPositive( STRING leftS, STRING rightS )
 STRING leftWorkS[255] = ProcAbsString( leftS )
 STRING rightWorkS[255] = ProcAbsString( rightS )
 STRING resultS[255] = ""
 INTEGER borrowI = 0
 INTEGER leftIndexI = Length( leftWorkS )
 INTEGER rightIndexI = Length( rightWorkS )
 INTEGER digitLeftI = 0
 INTEGER digitRightI = 0
 INTEGER diffI = 0
 WHILE leftIndexI > 0
  digitLeftI = Val( SubStr( leftWorkS, leftIndexI, 1 ) ) - borrowI
  digitRightI = 0
  IF rightIndexI > 0
   digitRightI = Val( SubStr( rightWorkS, rightIndexI, 1 ) )
   rightIndexI = rightIndexI - 1
  ENDIF
  IF digitLeftI < digitRightI
   digitLeftI = digitLeftI + 10
   borrowI = 1
  ELSE
   borrowI = 0
  ENDIF
  diffI = digitLeftI - digitRightI
  resultS = Chr( Asc( "0" ) + diffI ) + resultS
  leftIndexI = leftIndexI - 1
 ENDWHILE
 RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcAddSigned( STRING leftS, STRING rightS )
 STRING leftWorkS[255] = ProcTrimLeadingZeros( leftS )
 STRING rightWorkS[255] = ProcTrimLeadingZeros( rightS )
 STRING leftAbsS[255] = ProcAbsString( leftWorkS )
 STRING rightAbsS[255] = ProcAbsString( rightWorkS )
 INTEGER leftNegB = ProcIsNegative( leftWorkS )
 INTEGER rightNegB = ProcIsNegative( rightWorkS )
 INTEGER compareI = 0
 IF leftNegB == rightNegB
  IF leftNegB
   RETURN( ProcNegateString( ProcAddPositive( leftAbsS, rightAbsS ) ) )
  ENDIF
  RETURN( ProcAddPositive( leftAbsS, rightAbsS ) )
 ENDIF
 compareI = ProcComparePositive( leftAbsS, rightAbsS )
 IF compareI == 0
  RETURN( "0" )
 ENDIF
 IF compareI > 0
  IF leftNegB
   RETURN( ProcNegateString( ProcSubtractPositive( leftAbsS, rightAbsS ) ) )
  ENDIF
  RETURN( ProcSubtractPositive( leftAbsS, rightAbsS ) )
 ENDIF
 IF rightNegB
  RETURN( ProcNegateString( ProcSubtractPositive( rightAbsS, leftAbsS ) ) )
 ENDIF
 RETURN( ProcSubtractPositive( rightAbsS, leftAbsS ) )
END

STRING PROC ProcSubtractSigned( STRING leftS, STRING rightS )
 STRING rightNegatedS[255] = ProcNegateString( rightS )
 RETURN( ProcAddSigned( leftS, rightNegatedS ) )
END

STRING PROC ProcMultiplyPositiveByDigit( STRING leftS, INTEGER digitI )
 STRING leftWorkS[255] = ProcAbsString( leftS )
 STRING resultS[255] = ""
 INTEGER carryI = 0
 INTEGER indexI = 0
 INTEGER productI = 0
 IF digitI == 0 OR leftWorkS == "0"
  RETURN( "0" )
 ENDIF
 IF digitI == 1
  RETURN( leftWorkS )
 ENDIF
 FOR indexI = Length( leftWorkS ) DOWNTO 1 BY 1
  productI = Val( SubStr( leftWorkS, indexI, 1 ) ) * digitI + carryI
  resultS = Chr( Asc( "0" ) + ( productI mod 10 ) ) + resultS
  carryI = productI / 10
 ENDFOR
 WHILE carryI > 0
  resultS = Chr( Asc( "0" ) + ( carryI mod 10 ) ) + resultS
  carryI = carryI / 10
 ENDWHILE
 RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcMultiplyPositive( STRING leftS, STRING rightS )
 STRING leftWorkS[255] = ProcAbsString( leftS )
 STRING rightWorkS[255] = ProcAbsString( rightS )
 STRING resultS[255] = "0"
 STRING rowS[255] = ""
 INTEGER rightIndexI = 0
 INTEGER digitI = 0
 INTEGER zeroCountI = 0
 IF leftWorkS == "0" OR rightWorkS == "0"
  RETURN( "0" )
 ENDIF
 zeroCountI = 0
 FOR rightIndexI = Length( rightWorkS ) DOWNTO 1 BY 1
  digitI = Val( SubStr( rightWorkS, rightIndexI, 1 ) )
  rowS = ProcMultiplyPositiveByDigit( leftWorkS, digitI )
  rowS = rowS + ProcRepeatChar( "0", zeroCountI )
  resultS = ProcAddPositive( resultS, rowS )
  zeroCountI = zeroCountI + 1
 ENDFOR
 RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcDividePositive( STRING dividendS, STRING divisorS )
 STRING dividendWorkS[255] = ProcAbsString( dividendS )
 STRING divisorWorkS[255] = ProcAbsString( divisorS )
 STRING quotientS[255] = ""
 STRING currentS[255] = "0"
 STRING trialS[255] = ""
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER bestDigitI = 0
 INTEGER foundB = FALSE
 IF divisorWorkS == "0"
  RETURN( "0" )
 ENDIF
 IF ProcComparePositive( dividendWorkS, divisorWorkS ) < 0
  RETURN( "0" )
 ENDIF
 currentS = "0"
 FOR indexI = 1 TO Length( dividendWorkS ) BY 1
  IF currentS == "0"
   currentS = SubStr( dividendWorkS, indexI, 1 )
  ELSE
   currentS = currentS + SubStr( dividendWorkS, indexI, 1 )
  ENDIF
  currentS = ProcTrimLeadingZeros( currentS )
  bestDigitI = 0
  foundB = FALSE
  FOR digitI = 9 DOWNTO 0 BY 1
   trialS = ProcMultiplyPositiveByDigit( divisorWorkS, digitI )
   IF ProcComparePositive( trialS, currentS ) <= 0 AND foundB == FALSE
    bestDigitI = digitI
    foundB = TRUE
   ENDIF
  ENDFOR
  quotientS = quotientS + Chr( Asc( "0" ) + bestDigitI )
  currentS = ProcSubtractPositive( currentS, ProcMultiplyPositiveByDigit( divisorWorkS, bestDigitI ) )
 ENDFOR
 RETURN( ProcTrimLeadingZeros( quotientS ) )
END

STRING PROC ProcDividePositiveBy2( STRING dividendS )
 STRING dividendWorkS[255] = ProcAbsString( dividendS )
 STRING resultS[255] = ""
 INTEGER indexI = 0
 INTEGER carryI = 0
 INTEGER valueI = 0
 FOR indexI = 1 TO Length( dividendWorkS ) BY 1
  valueI = carryI * 10 + Val( SubStr( dividendWorkS, indexI, 1 ) )
  resultS = resultS + Chr( Asc( "0" ) + ( valueI / 2 ) )
  carryI = valueI mod 2
 ENDFOR
 RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcShiftLeft10( STRING numberS, INTEGER countI )
 STRING workS[255] = ProcTrimLeadingZeros( numberS )
 IF workS == "0"
  RETURN( "0" )
 ENDIF
 RETURN( workS + ProcRepeatChar( "0", countI ) )
END

STRING PROC ProcFixedOne()
 RETURN( gScaleS )
END

STRING PROC ProcFixedFromInteger( INTEGER numberI )
 STRING signS[2] = ""
 STRING baseS[255] = ""
 IF numberI < 0
  signS = "-"
  numberI = -numberI
 ENDIF
 baseS = Format( numberI )
 RETURN( signS + baseS + ProcRepeatChar( "0", SCALE_DIGITS ) )
END

STRING PROC ProcFixedAdd( STRING leftS, STRING rightS )
 RETURN( ProcAddSigned( leftS, rightS ) )
END

STRING PROC ProcFixedSubtract( STRING leftS, STRING rightS )
 RETURN( ProcSubtractSigned( leftS, rightS ) )
END

STRING PROC ProcFixedMultiply( STRING leftS, STRING rightS )
 STRING leftAbsS[255] = ProcAbsString( leftS )
 STRING rightAbsS[255] = ProcAbsString( rightS )
 STRING rawS[255] = ProcMultiplyPositive( leftAbsS, rightAbsS )
 STRING scaledS[255] = ""
 INTEGER negativeB = FALSE
 IF Length( rawS ) <= SCALE_DIGITS
  scaledS = "0"
 ELSE
  scaledS = SubStr( rawS, 1, Length( rawS ) - SCALE_DIGITS )
 ENDIF
 IF scaledS == ""
  scaledS = "0"
 ENDIF
 IF not ( ProcIsNegative( leftS ) == ProcIsNegative( rightS ) )
  negativeB = TRUE
 ENDIF
 IF negativeB AND scaledS == "0"
  negativeB = FALSE
 ENDIF
 IF negativeB
  RETURN( "-" + scaledS )
 ENDIF
 RETURN( scaledS )
END

STRING PROC ProcFixedDivide( STRING leftS, STRING rightS )
 STRING leftAbsS[255] = ProcAbsString( leftS )
 STRING rightAbsS[255] = ProcAbsString( rightS )
 STRING numeratorS[255] = ProcShiftLeft10( leftAbsS, SCALE_DIGITS )
 STRING quotientS[255] = ProcDividePositive( numeratorS, rightAbsS )
 INTEGER negativeB = FALSE
 IF not ( ProcIsNegative( leftS ) == ProcIsNegative( rightS ) )
  negativeB = TRUE
 ENDIF
 IF negativeB AND quotientS == "0"
  negativeB = FALSE
 ENDIF
 IF negativeB
  RETURN( "-" + quotientS )
 ENDIF
 RETURN( quotientS )
END

STRING PROC ProcFixedSquare( STRING numberS )
 RETURN( ProcFixedMultiply( numberS, numberS ) )
END

STRING PROC ProcFixedSqrt( STRING numberS )
 STRING workS[255] = ProcTrimLeadingZeros( numberS )
 STRING nS[255] = ""
 STRING guessS[255] = ""
 STRING nextS[255] = ""
 STRING quotientS[255] = ""
 INTEGER iterationI = 0
 INTEGER halfLenI = 0
 IF ProcIsNegative( workS )
  RETURN( "0" )
 ENDIF
 IF workS == "0"
  RETURN( "0" )
 ENDIF
 nS = ProcShiftLeft10( workS, SCALE_DIGITS )
 guessS = ProcFixedOne()
 IF ProcComparePositive( nS, ProcShiftLeft10( guessS, SCALE_DIGITS ) ) > 0
  halfLenI = Length( nS ) / 2
  guessS = ProcShiftLeft10( "1", halfLenI )
 ENDIF
 IF guessS == "0"
  guessS = "1"
 ENDIF
 FOR iterationI = 1 TO 22 BY 1
  quotientS = ProcDividePositive( nS, guessS )
  nextS = ProcDividePositiveBy2( ProcAddPositive( guessS, quotientS ) )
  IF ProcComparePositive( nextS, guessS ) == 0
   guessS = nextS
   iterationI = 22
  ELSE
   guessS = nextS
  ENDIF
 ENDFOR
 RETURN( ProcTrimLeadingZeros( guessS ) )
END

STRING PROC ProcFormatFixed8( STRING numberS )
 STRING workS[255] = ProcTrimLeadingZeros( numberS )
 STRING signS[2] = ""
 STRING absS[255] = ""
 STRING integerS[255] = ""
 STRING fractionS[255] = ""
 STRING roundDigitS[2] = ""
 INTEGER needZerosI = 0
 INTEGER roundDigitI = 0
 IF ProcIsNegative( workS )
  signS = "-"
  absS = ProcAbsString( workS )
 ELSE
  absS = workS
 ENDIF
 IF Length( absS ) <= SCALE_DIGITS
  integerS = "0"
  needZerosI = SCALE_DIGITS - Length( absS )
  fractionS = ProcRepeatChar( "0", needZerosI ) + absS
 ELSE
  integerS = SubStr( absS, 1, Length( absS ) - SCALE_DIGITS )
  fractionS = SubStr( absS, Length( absS ) - SCALE_DIGITS + 1, SCALE_DIGITS )
 ENDIF
 IF Length( fractionS ) < 9
  fractionS = fractionS + ProcRepeatChar( "0", 9 - Length( fractionS ) )
 ENDIF
 roundDigitS = SubStr( fractionS, 9, 1 )
 roundDigitI = Val( roundDigitS )
 fractionS = SubStr( fractionS, 1, 8 )
 IF roundDigitI >= 5
  fractionS = ProcAddPositive( fractionS, "1" )
  IF Length( fractionS ) > 8
   fractionS = SubStr( fractionS, 2, 8 )
   integerS = ProcAddPositive( integerS, "1" )
  ENDIF
 ENDIF
 WHILE Length( fractionS ) < 8
  fractionS = "0" + fractionS
 ENDWHILE
 RETURN( signS + integerS + "." + fractionS )
END

STRING PROC ProcPairToFixed( INTEGER aI, INTEGER bI )
 STRING aS[255] = ""
 STRING bS[255] = ""
 STRING resultS[255] = ""
 aS = ProcFixedFromInteger( aI )
 bS = ProcFixedMultiply( ProcFixedFromInteger( bI ), gSqrt3S )
 resultS = ProcFixedAdd( aS, bS )
 RETURN( resultS )
END

PROC ProcAddCircleAreaRatio( INTEGER aI, INTEGER bI )
 STRING kS[255] = ""
 STRING kSqS[255] = ""
 STRING ratioS[255] = ""
 kS = ProcPairToFixed( aI, bI )
 kSqS = ProcFixedSquare( kS )
 ratioS = ProcFixedDivide( gOuterSqS, kSqS )
 gAreaSumS = ProcFixedAdd( gAreaSumS, ratioS )
END

PROC ProcGenerate( INTEGER a0I, INTEGER b0I, INTEGER a1I, INTEGER b1I, INTEGER a2I, INTEGER b2I, INTEGER a3I, INTEGER b3I, INTEGER skipIndexI, INTEGER depthI )
 INTEGER n0AI = 0
 INTEGER n0BI = 0
 INTEGER n1AI = 0
 INTEGER n1BI = 0
 INTEGER n2AI = 0
 INTEGER n2BI = 0
 INTEGER n3AI = 0
 INTEGER n3BI = 0

 IF depthI <= 0
  RETURN()
 ENDIF

 IF not ( skipIndexI == 0 )
  n0AI = 2 * ( a1I + a2I + a3I ) - a0I
  n0BI = 2 * ( b1I + b2I + b3I ) - b0I
  ProcAddCircleAreaRatio( n0AI, n0BI )
  ProcGenerate( n0AI, n0BI, a1I, b1I, a2I, b2I, a3I, b3I, 0, depthI - 1 )
 ENDIF

 IF not ( skipIndexI == 1 )
  n1AI = 2 * ( a0I + a2I + a3I ) - a1I
  n1BI = 2 * ( b0I + b2I + b3I ) - b1I
  ProcAddCircleAreaRatio( n1AI, n1BI )
  ProcGenerate( a0I, b0I, n1AI, n1BI, a2I, b2I, a3I, b3I, 1, depthI - 1 )
 ENDIF

 IF not ( skipIndexI == 2 )
  n2AI = 2 * ( a0I + a1I + a3I ) - a2I
  n2BI = 2 * ( b0I + b1I + b3I ) - b2I
  ProcAddCircleAreaRatio( n2AI, n2BI )
  ProcGenerate( a0I, b0I, a1I, b1I, n2AI, n2BI, a3I, b3I, 2, depthI - 1 )
 ENDIF

 IF not ( skipIndexI == 3 )
  n3AI = 2 * ( a0I + a1I + a2I ) - a3I
  n3BI = 2 * ( b0I + b1I + b2I ) - b3I
  ProcAddCircleAreaRatio( n3AI, n3BI )
  ProcGenerate( a0I, b0I, a1I, b1I, a2I, b2I, n3AI, n3BI, 3, depthI - 1 )
 ENDIF
END

STRING PROC ProcGetFinalAnswer()
 STRING twoS[255] = ""
 STRING threeS[255] = ""
 STRING resultS[255] = ""

 gScaleS = "1" + ProcRepeatChar( "0", SCALE_DIGITS )
 gAreaSumS = "0"

 twoS = ProcFixedFromInteger( 2 )
 threeS = ProcFixedFromInteger( 3 )
 gSqrt3S = ProcFixedSqrt( threeS )
 gOuterAbsS = ProcFixedSubtract( ProcFixedMultiply( twoS, gSqrt3S ), threeS )
 gOuterSqS = ProcFixedSquare( gOuterAbsS )

 ProcAddCircleAreaRatio( 1, 0 )
 ProcAddCircleAreaRatio( 1, 0 )
 ProcAddCircleAreaRatio( 1, 0 )

 ProcGenerate( 3, -2, 1, 0, 1, 0, 1, 0, -1, 10 )

 resultS = ProcFixedSubtract( ProcFixedOne(), gAreaSumS )
 RETURN( ProcFormatFixed8( resultS ) )
END

PROC Main()
 STRING answerS[255] = ""
 answerS = ProcGetFinalAnswer()
 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
END
