/*
  euler0235.s
  <version>1</version>

  History:
  1 - ChatGPT GPT-5.4 Thinking - Pure TSE SAL solution for Project Euler 235.

  Notes:
  - Pure TSE SAL only.
  - Uses fixed-point decimal arithmetic with 15 decimal places.
  - Uses string-based big integer arithmetic.
  - Final answer only is shown in one Warn() box.
  - Final answer only is copied to clipboard before and after Warn().
*/

#define INTERNAL_SCALE_DIGITS 15
#define OUTPUT_SCALE_DIGITS   12

FORWARD STRING PROC ProcNormalizeUnsigned( STRING numberS )
FORWARD STRING PROC ProcAbsSigned( STRING numberS )
FORWARD STRING PROC ProcNormalizeSigned( STRING numberS )
FORWARD INTEGER PROC ProcCompareUnsigned( STRING leftS, STRING rightS )
FORWARD INTEGER PROC ProcCompareSigned( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcAddUnsigned( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcSubUnsigned( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcAddSigned( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcMultiplyUnsignedByInt( STRING numberS, INTEGER factorI )
FORWARD STRING PROC ProcMultiplyUnsigned( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcAppendZeros( STRING numberS, INTEGER zeroCountI )
FORWARD STRING PROC ProcChopRightDigits( STRING numberS, INTEGER digitCountI )
FORWARD STRING PROC ProcHalfUnsigned( STRING numberS )
FORWARD STRING PROC ProcIncrementUnsigned( STRING numberS )
FORWARD STRING PROC ProcDecrementUnsigned( STRING numberS )
FORWARD STRING PROC ProcMidUnsigned( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcEvaluateSum235( STRING rScaledS )
FORWARD STRING PROC ProcRoundScaled15ToOutput12( STRING rScaledS )
FORWARD STRING PROC ProcFormatScaled12( STRING scaled12S )

STRING PROC ProcNormalizeUnsigned( STRING numberS )
  STRING workS[255] = ""
  INTEGER indexI = 0
  INTEGER lengthI = 0
  workS = numberS
  IF workS == ""
    RETURN( "0" )
  ENDIF
  lengthI = Length( workS )
  indexI = 1
  WHILE indexI < lengthI
    IF SubStr( workS, indexI, 1 ) == "0"
      indexI = indexI + 1
    ELSE
      BREAK
    ENDIF
  ENDWHILE
  workS = SubStr( workS, indexI, 255 )
  IF workS == ""
    workS = "0"
  ENDIF
  RETURN( workS )
END

STRING PROC ProcAbsSigned( STRING numberS )
  STRING workS[255] = ""
  workS = numberS
  IF workS == ""
    RETURN( "0" )
  ENDIF
  IF SubStr( workS, 1, 1 ) == "-"
    workS = SubStr( workS, 2, 255 )
  ENDIF
  RETURN( ProcNormalizeUnsigned( workS ) )
END

STRING PROC ProcNormalizeSigned( STRING numberS )
  STRING workS[255] = ""
  STRING absS[255] = ""
  workS = numberS
  IF workS == ""
    RETURN( "0" )
  ENDIF
  absS = ProcAbsSigned( workS )
  IF absS == "0"
    RETURN( "0" )
  ENDIF
  IF SubStr( workS, 1, 1 ) == "-"
    RETURN( "-" + absS )
  ENDIF
  RETURN( absS )
END

INTEGER PROC ProcCompareUnsigned( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  INTEGER leftLengthI = 0
  INTEGER rightLengthI = 0
  INTEGER indexI = 0
  leftWorkS = ProcNormalizeUnsigned( leftS )
  rightWorkS = ProcNormalizeUnsigned( rightS )
  leftLengthI = Length( leftWorkS )
  rightLengthI = Length( rightWorkS )
  IF leftLengthI < rightLengthI
    RETURN( -1 )
  ENDIF
  IF leftLengthI > rightLengthI
    RETURN( 1 )
  ENDIF
  FOR indexI = 1 TO leftLengthI BY 1
    IF SubStr( leftWorkS, indexI, 1 ) < SubStr( rightWorkS, indexI, 1 )
      RETURN( -1 )
    ENDIF
    IF SubStr( leftWorkS, indexI, 1 ) > SubStr( rightWorkS, indexI, 1 )
      RETURN( 1 )
    ENDIF
  ENDFOR
  RETURN( 0 )
END

INTEGER PROC ProcCompareSigned( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  STRING leftAbsS[255] = ""
  STRING rightAbsS[255] = ""
  INTEGER leftNegativeB = FALSE
  INTEGER rightNegativeB = FALSE
  INTEGER compareI = 0
  leftWorkS = ProcNormalizeSigned( leftS )
  rightWorkS = ProcNormalizeSigned( rightS )
  leftNegativeB = SubStr( leftWorkS, 1, 1 ) == "-"
  rightNegativeB = SubStr( rightWorkS, 1, 1 ) == "-"
  IF leftNegativeB AND NOT( rightNegativeB )
    RETURN( -1 )
  ENDIF
  IF NOT( leftNegativeB ) AND rightNegativeB
    RETURN( 1 )
  ENDIF
  leftAbsS = ProcAbsSigned( leftWorkS )
  rightAbsS = ProcAbsSigned( rightWorkS )
  compareI = ProcCompareUnsigned( leftAbsS, rightAbsS )
  IF NOT( leftNegativeB )
    RETURN( compareI )
  ENDIF
  IF compareI == -1
    RETURN( 1 )
  ENDIF
  IF compareI == 1
    RETURN( -1 )
  ENDIF
  RETURN( 0 )
END

STRING PROC ProcAddUnsigned( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  STRING resultS[255] = ""
  INTEGER leftIndexI = 0
  INTEGER rightIndexI = 0
  INTEGER carryI = 0
  INTEGER digitLeftI = 0
  INTEGER digitRightI = 0
  INTEGER sumI = 0
  leftWorkS = ProcNormalizeUnsigned( leftS )
  rightWorkS = ProcNormalizeUnsigned( rightS )
  leftIndexI = Length( leftWorkS )
  rightIndexI = Length( rightWorkS )
  carryI = 0
  resultS = ""
  WHILE ( leftIndexI > 0 ) OR ( rightIndexI > 0 ) OR ( carryI > 0 )
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
    carryI = sumI / 10
    resultS = Chr( 48 + ( sumI mod 10 ) ) + resultS
  ENDWHILE
  RETURN( ProcNormalizeUnsigned( resultS ) )
END

STRING PROC ProcSubUnsigned( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  STRING resultS[255] = ""
  INTEGER leftIndexI = 0
  INTEGER rightIndexI = 0
  INTEGER borrowI = 0
  INTEGER digitLeftI = 0
  INTEGER digitRightI = 0
  INTEGER diffI = 0
  leftWorkS = ProcNormalizeUnsigned( leftS )
  rightWorkS = ProcNormalizeUnsigned( rightS )
  IF ProcCompareUnsigned( leftWorkS, rightWorkS ) == 0
    RETURN( "0" )
  ENDIF
  leftIndexI = Length( leftWorkS )
  rightIndexI = Length( rightWorkS )
  borrowI = 0
  resultS = ""
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
    resultS = Chr( 48 + diffI ) + resultS
    leftIndexI = leftIndexI - 1
  ENDWHILE
  RETURN( ProcNormalizeUnsigned( resultS ) )
END

STRING PROC ProcAddSigned( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  STRING leftAbsS[255] = ""
  STRING rightAbsS[255] = ""
  STRING resultS[255] = ""
  INTEGER leftNegativeB = FALSE
  INTEGER rightNegativeB = FALSE
  INTEGER compareI = 0
  leftWorkS = ProcNormalizeSigned( leftS )
  rightWorkS = ProcNormalizeSigned( rightS )
  leftNegativeB = SubStr( leftWorkS, 1, 1 ) == "-"
  rightNegativeB = SubStr( rightWorkS, 1, 1 ) == "-"
  leftAbsS = ProcAbsSigned( leftWorkS )
  rightAbsS = ProcAbsSigned( rightWorkS )
  IF leftNegativeB == rightNegativeB
    resultS = ProcAddUnsigned( leftAbsS, rightAbsS )
    IF leftNegativeB AND NOT( resultS == "0" )
      RETURN( "-" + resultS )
    ENDIF
    RETURN( resultS )
  ENDIF
  compareI = ProcCompareUnsigned( leftAbsS, rightAbsS )
  IF compareI == 0
    RETURN( "0" )
  ENDIF
  IF compareI > 0
    resultS = ProcSubUnsigned( leftAbsS, rightAbsS )
    IF leftNegativeB
      RETURN( "-" + resultS )
    ENDIF
    RETURN( resultS )
  ENDIF
  resultS = ProcSubUnsigned( rightAbsS, leftAbsS )
  IF rightNegativeB
    RETURN( "-" + resultS )
  ENDIF
  RETURN( resultS )
END

STRING PROC ProcMultiplyUnsignedByInt( STRING numberS, INTEGER factorI )
  STRING workS[255] = ""
  STRING resultS[255] = ""
  INTEGER indexI = 0
  INTEGER digitI = 0
  INTEGER productI = 0
  INTEGER carryI = 0
  workS = ProcNormalizeUnsigned( numberS )
  IF ( workS == "0" ) OR ( factorI == 0 )
    RETURN( "0" )
  ENDIF
  resultS = ""
  carryI = 0
  FOR indexI = Length( workS ) DOWNTO 1 BY 1
    digitI = Val( SubStr( workS, indexI, 1 ) )
    productI = digitI * factorI + carryI
    resultS = Chr( 48 + ( productI mod 10 ) ) + resultS
    carryI = productI / 10
  ENDFOR
  WHILE carryI > 0
    resultS = Chr( 48 + ( carryI mod 10 ) ) + resultS
    carryI = carryI / 10
  ENDWHILE
  RETURN( ProcNormalizeUnsigned( resultS ) )
END

STRING PROC ProcAppendZeros( STRING numberS, INTEGER zeroCountI )
  STRING workS[255] = ""
  INTEGER indexI = 0
  workS = ProcNormalizeUnsigned( numberS )
  IF workS == "0"
    RETURN( "0" )
  ENDIF
  FOR indexI = 1 TO zeroCountI BY 1
    workS = workS + "0"
  ENDFOR
  RETURN( workS )
END

STRING PROC ProcMultiplyUnsigned( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  STRING resultS[255] = ""
  STRING partialS[255] = ""
  INTEGER indexI = 0
  INTEGER digitI = 0
  INTEGER zeroCountI = 0
  leftWorkS = ProcNormalizeUnsigned( leftS )
  rightWorkS = ProcNormalizeUnsigned( rightS )
  IF ( leftWorkS == "0" ) OR ( rightWorkS == "0" )
    RETURN( "0" )
  ENDIF
  resultS = "0"
  zeroCountI = 0
  FOR indexI = Length( rightWorkS ) DOWNTO 1 BY 1
    digitI = Val( SubStr( rightWorkS, indexI, 1 ) )
    partialS = ProcMultiplyUnsignedByInt( leftWorkS, digitI )
    partialS = ProcAppendZeros( partialS, zeroCountI )
    resultS = ProcAddUnsigned( resultS, partialS )
    zeroCountI = zeroCountI + 1
  ENDFOR
  RETURN( ProcNormalizeUnsigned( resultS ) )
END

STRING PROC ProcChopRightDigits( STRING numberS, INTEGER digitCountI )
  STRING workS[255] = ""
  INTEGER lengthI = 0
  workS = ProcNormalizeUnsigned( numberS )
  lengthI = Length( workS )
  IF lengthI <= digitCountI
    RETURN( "0" )
  ENDIF
  RETURN( ProcNormalizeUnsigned( SubStr( workS, 1, lengthI - digitCountI ) ) )
END

STRING PROC ProcHalfUnsigned( STRING numberS )
  STRING workS[255] = ""
  STRING resultS[255] = ""
  INTEGER indexI = 0
  INTEGER carryI = 0
  INTEGER digitI = 0
  INTEGER valueI = 0
  workS = ProcNormalizeUnsigned( numberS )
  resultS = ""
  carryI = 0
  FOR indexI = 1 TO Length( workS ) BY 1
    digitI = Val( SubStr( workS, indexI, 1 ) )
    valueI = carryI * 10 + digitI
    resultS = resultS + Chr( 48 + ( valueI / 2 ) )
    carryI = valueI mod 2
  ENDFOR
  RETURN( ProcNormalizeUnsigned( resultS ) )
END

STRING PROC ProcIncrementUnsigned( STRING numberS )
  RETURN( ProcAddUnsigned( numberS, "1" ) )
END

STRING PROC ProcDecrementUnsigned( STRING numberS )
  STRING workS[255] = ""
  workS = ProcNormalizeUnsigned( numberS )
  IF workS == "0"
    RETURN( "0" )
  ENDIF
  RETURN( ProcSubUnsigned( workS, "1" ) )
END

STRING PROC ProcMidUnsigned( STRING leftS, STRING rightS )
  STRING sumS[255] = ""
  sumS = ProcAddUnsigned( leftS, rightS )
  RETURN( ProcHalfUnsigned( sumS ) )
END

STRING PROC ProcEvaluateSum235( STRING rScaledS )
  STRING powerS[255] = ""
  STRING sumS[255] = ""
  STRING termS[255] = ""
  STRING multipliedS[255] = ""
  INTEGER kI = 0
  INTEGER coefficientI = 0
  powerS = "1000000000000000"
  sumS = "0"
  FOR kI = 1 TO 5000 BY 1
    coefficientI = 900 - 3 * kI
    IF coefficientI >= 0
      termS = ProcMultiplyUnsignedByInt( powerS, coefficientI )
      sumS = ProcAddSigned( sumS, termS )
    ELSE
      termS = ProcMultiplyUnsignedByInt( powerS, -coefficientI )
      sumS = ProcAddSigned( sumS, "-" + termS )
    ENDIF
    multipliedS = ProcMultiplyUnsigned( powerS, rScaledS )
    powerS = ProcChopRightDigits( multipliedS, INTERNAL_SCALE_DIGITS )
  ENDFOR
  RETURN( ProcNormalizeSigned( sumS ) )
END

STRING PROC ProcRoundScaled15ToOutput12( STRING rScaledS )
  STRING roundedS[255] = ""
  STRING scaled12S[255] = ""
  roundedS = ProcAddUnsigned( rScaledS, "500" )
  scaled12S = ProcChopRightDigits( roundedS, 3 )
  RETURN( ProcNormalizeUnsigned( scaled12S ) )
END

STRING PROC ProcFormatScaled12( STRING scaled12S )
  STRING workS[255] = ""
  STRING integerPartS[255] = ""
  STRING fractionPartS[255] = ""
  INTEGER lengthI = 0
  workS = ProcNormalizeUnsigned( scaled12S )
  lengthI = Length( workS )
  WHILE lengthI <= OUTPUT_SCALE_DIGITS
    workS = "0" + workS
    lengthI = lengthI + 1
  ENDWHILE
  integerPartS = SubStr( workS, 1, Length( workS ) - OUTPUT_SCALE_DIGITS )
  fractionPartS = SubStr( workS, Length( workS ) - OUTPUT_SCALE_DIGITS + 1, OUTPUT_SCALE_DIGITS )
  integerPartS = ProcNormalizeUnsigned( integerPartS )
  RETURN( integerPartS + "." + fractionPartS )
END

PROC Main()
  STRING lowS[255] = ""
  STRING highS[255] = ""
  STRING middleS[255] = ""
  STRING sumS[255] = ""
  STRING targetS[255] = ""
  STRING scaled12S[255] = ""
  STRING answerS[255] = ""
  targetS = "-600000000000000000000000000"
  lowS = "1002000000000000"
  highS = "1003000000000000"
  WHILE ProcCompareUnsigned( lowS, highS ) < 0
    middleS = ProcMidUnsigned( lowS, highS )
    sumS = ProcEvaluateSum235( middleS )
    IF ProcCompareSigned( sumS, targetS ) > 0
      lowS = ProcIncrementUnsigned( middleS )
    ELSE
      highS = middleS
    ENDIF
  ENDWHILE
  scaled12S = ProcRoundScaled15ToOutput12( lowS )
  answerS = ProcFormatScaled12( scaled12S )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
