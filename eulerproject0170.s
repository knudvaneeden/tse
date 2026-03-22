/*
 Euler Project 170
 Pandigital Concatenating Products

 Pure TSE SAL solution
 <version>1.0.0.0.2</version>

 History:
 2026-03-22  Created by GPT-5.4 Thinking
 2026-03-22  Fixed constant string parameter reassignment for numberS
 2026-03-22  Fixed constant string parameter reassignment for bestS
*/

FORWARD STRING PROC ProcIntegerToString( INTEGER numberI )
FORWARD INTEGER PROC ProcStringToInteger( STRING numberS )
FORWARD STRING PROC ProcCharAt( STRING textS, INTEGER indexI )
FORWARD STRING PROC ProcReplaceCharacterAt( STRING textS, INTEGER indexI, STRING charS )
FORWARD STRING PROC ProcSwapCharacters( STRING textS, INTEGER index1I, INTEGER index2I )
FORWARD STRING PROC ProcReverseSubstring( STRING textS, INTEGER startI, INTEGER endI )
FORWARD STRING PROC ProcNextLowerPermutation( STRING textS )
FORWARD STRING PROC ProcBuildRemainingDigits( STRING excludedS )
FORWARD INTEGER PROC ProcDigitCharToInteger( STRING digitS )
FORWARD INTEGER PROC ProcStringCompareNumeric( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcTrimLeadingZeros( STRING numberS )
FORWARD STRING PROC ProcMultiplyStringByInteger( STRING numberS, INTEGER factorI )
FORWARD INTEGER PROC ProcIsPandigital10( STRING numberS )
FORWARD INTEGER PROC ProcContainsChar( STRING textS, STRING charS )
FORWARD INTEGER PROC ProcIsValidNumberPiece( STRING pieceS )
FORWARD STRING PROC ProcBestOfTwo( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcEvaluateCaseOneDigitMultiplier( STRING bestS )
FORWARD STRING PROC ProcEvaluateCaseTwoDigitMultiplier( STRING bestS )

STRING PROC ProcIntegerToString( INTEGER numberI )
 STRING resultS[ 255 ] = ""
 //
 resultS = Format( numberI:0 )
 Return( resultS )
END

INTEGER PROC ProcStringToInteger( STRING numberS )
 INTEGER resultI = 0
 //
 resultI = Val( numberS )
 Return( resultI )
END

STRING PROC ProcCharAt( STRING textS, INTEGER indexI )
 STRING resultS[ 255 ] = ""
 //
 resultS = SubStr( textS, indexI, 1 )
 Return( resultS )
END

STRING PROC ProcReplaceCharacterAt( STRING textS, INTEGER indexI, STRING charS )
 STRING resultS[ 255 ] = ""
 //
 resultS = SubStr( textS, 1, indexI - 1 ) + charS + SubStr( textS, indexI + 1, Length( textS ) - indexI )
 Return( resultS )
END

STRING PROC ProcSwapCharacters( STRING textS, INTEGER index1I, INTEGER index2I )
 STRING resultS[ 255 ] = ""
 STRING char1S[ 255 ] = ""
 STRING char2S[ 255 ] = ""
 //
 char1S = ProcCharAt( textS, index1I )
 char2S = ProcCharAt( textS, index2I )
 resultS = ProcReplaceCharacterAt( textS, index1I, char2S )
 resultS = ProcReplaceCharacterAt( resultS, index2I, char1S )
 Return( resultS )
END

STRING PROC ProcReverseSubstring( STRING textS, INTEGER startI, INTEGER endI )
 STRING resultS[ 255 ] = ""
 INTEGER leftI = 0
 INTEGER rightI = 0
 //
 resultS = textS
 leftI = startI
 rightI = endI
 WHILE leftI < rightI
  resultS = ProcSwapCharacters( resultS, leftI, rightI )
  leftI = leftI + 1
  rightI = rightI - 1
 ENDWHILE
 Return( resultS )
END

STRING PROC ProcNextLowerPermutation( STRING textS )
 STRING resultS[ 255 ] = ""
 INTEGER lengthI = 0
 INTEGER pivotI = 0
 INTEGER swapI = 0
 INTEGER foundPivotB = FALSE
 INTEGER foundSwapB = FALSE
 //
 lengthI = Length( textS )
 pivotI = lengthI - 1
 WHILE pivotI >= 1 AND NOT( foundPivotB )
  IF ProcCharAt( textS, pivotI ) > ProcCharAt( textS, pivotI + 1 )
   foundPivotB = TRUE
  ELSE
   pivotI = pivotI - 1
  ENDIF
 ENDWHILE
 IF NOT( foundPivotB )
  Return( "" )
 ENDIF
 swapI = lengthI
 WHILE swapI > pivotI AND NOT( foundSwapB )
  IF ProcCharAt( textS, swapI ) < ProcCharAt( textS, pivotI )
   foundSwapB = TRUE
  ELSE
   swapI = swapI - 1
  ENDIF
 ENDWHILE
 resultS = ProcSwapCharacters( textS, pivotI, swapI )
 resultS = ProcReverseSubstring( resultS, pivotI + 1, lengthI )
 Return( resultS )
END

STRING PROC ProcBuildRemainingDigits( STRING excludedS )
 STRING allDigitsS[ 255 ] = "9876543210"
 STRING resultS[ 255 ] = ""
 STRING currentS[ 255 ] = ""
 INTEGER indexI = 0
 //
 resultS = ""
 FOR indexI = 1 TO Length( allDigitsS )
  currentS = ProcCharAt( allDigitsS, indexI )
  IF NOT( ProcContainsChar( excludedS, currentS ) )
   resultS = resultS + currentS
  ENDIF
 ENDFOR
 Return( resultS )
END

INTEGER PROC ProcDigitCharToInteger( STRING digitS )
 INTEGER resultI = 0
 //
 resultI = Asc( digitS ) - Asc( "0" )
 Return( resultI )
END

INTEGER PROC ProcStringCompareNumeric( STRING leftS, STRING rightS )
 STRING leftTrimmedS[ 255 ] = ""
 STRING rightTrimmedS[ 255 ] = ""
 //
 leftTrimmedS = ProcTrimLeadingZeros( leftS )
 rightTrimmedS = ProcTrimLeadingZeros( rightS )
 IF Length( leftTrimmedS ) < Length( rightTrimmedS )
  Return( -1 )
 ENDIF
 IF Length( leftTrimmedS ) > Length( rightTrimmedS )
  Return( 1 )
 ENDIF
 IF leftTrimmedS < rightTrimmedS
  Return( -1 )
 ENDIF
 IF leftTrimmedS > rightTrimmedS
  Return( 1 )
 ENDIF
 Return( 0 )
END

STRING PROC ProcTrimLeadingZeros( STRING numberS )
 STRING resultS[ 255 ] = ""
 INTEGER indexI = 0
 //
 resultS = numberS
 indexI = 1
 WHILE indexI < Length( resultS ) AND ProcCharAt( resultS, indexI ) == "0"
  indexI = indexI + 1
 ENDWHILE
 resultS = SubStr( resultS, indexI, Length( resultS ) - indexI + 1 )
 IF resultS == ""
  resultS = "0"
 ENDIF
 Return( resultS )
END

STRING PROC ProcMultiplyStringByInteger( STRING numberS, INTEGER factorI )
 STRING resultS[ 255 ] = ""
 STRING workingNumberS[ 255 ] = ""
 STRING digitS[ 255 ] = ""
 INTEGER carryI = 0
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER productI = 0
 INTEGER remainderI = 0
 //
 resultS = ""
 carryI = 0
 workingNumberS = ProcTrimLeadingZeros( numberS )
 IF factorI == 0
  Return( "0" )
 ENDIF
 FOR indexI = Length( workingNumberS ) DOWNTO 1
  digitI = ProcDigitCharToInteger( ProcCharAt( workingNumberS, indexI ) )
  productI = digitI * factorI + carryI
  remainderI = productI mod 10
  carryI = productI / 10
  digitS = ProcIntegerToString( remainderI )
  resultS = digitS + resultS
 ENDFOR
 WHILE carryI > 0
  remainderI = carryI mod 10
  carryI = carryI / 10
  digitS = ProcIntegerToString( remainderI )
  resultS = digitS + resultS
 ENDWHILE
 resultS = ProcTrimLeadingZeros( resultS )
 Return( resultS )
END

INTEGER PROC ProcIsPandigital10( STRING numberS )
 INTEGER usedMaskI = 0
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER bitI = 0
 //
 IF NOT( Length( numberS ) == 10 )
  Return( FALSE )
 ENDIF
 usedMaskI = 0
 FOR indexI = 1 TO 10
  digitI = ProcDigitCharToInteger( ProcCharAt( numberS, indexI ) )
  IF digitI < 0 OR digitI > 9
   Return( FALSE )
  ENDIF
  bitI = 1 shl digitI
  IF NOT( ( usedMaskI & bitI ) == 0 )
   Return( FALSE )
  ENDIF
  usedMaskI = usedMaskI | bitI
 ENDFOR
 IF usedMaskI == 1023
  Return( TRUE )
 ENDIF
 Return( FALSE )
END

INTEGER PROC ProcContainsChar( STRING textS, STRING charS )
 INTEGER indexI = 0
 //
 FOR indexI = 1 TO Length( textS )
  IF ProcCharAt( textS, indexI ) == charS
   Return( TRUE )
  ENDIF
 ENDFOR
 Return( FALSE )
END

INTEGER PROC ProcIsValidNumberPiece( STRING pieceS )
 IF pieceS == ""
  Return( FALSE )
 ENDIF
 IF Length( pieceS ) > 1 AND ProcCharAt( pieceS, 1 ) == "0"
  Return( FALSE )
 ENDIF
 Return( TRUE )
END

STRING PROC ProcBestOfTwo( STRING leftS, STRING rightS )
 IF leftS == ""
  Return( rightS )
 ENDIF
 IF rightS == ""
  Return( leftS )
 ENDIF
 IF ProcStringCompareNumeric( leftS, rightS ) >= 0
  Return( leftS )
 ENDIF
 Return( rightS )
END

STRING PROC ProcEvaluateCaseOneDigitMultiplier( STRING bestS )
 STRING workingBestS[ 255 ] = ""
 STRING multiplierS[ 255 ] = ""
 STRING remainingDigitsS[ 255 ] = ""
 STRING permutationS[ 255 ] = ""
 STRING multiplicand1S[ 255 ] = ""
 STRING multiplicand2S[ 255 ] = ""
 STRING product1S[ 255 ] = ""
 STRING product2S[ 255 ] = ""
 STRING candidateS[ 255 ] = ""
 INTEGER multiplierI = 0
 INTEGER splitI = 0
 INTEGER digitI = 0
 //
 workingBestS = bestS
 FOR digitI = 9 DOWNTO 1
  multiplierI = digitI
  multiplierS = ProcIntegerToString( multiplierI )
  remainingDigitsS = ProcBuildRemainingDigits( multiplierS )
  permutationS = remainingDigitsS
  WHILE NOT( permutationS == "" )
   FOR splitI = 1 TO 8
    multiplicand1S = SubStr( permutationS, 1, splitI )
    multiplicand2S = SubStr( permutationS, splitI + 1, Length( permutationS ) - splitI )
    IF ProcIsValidNumberPiece( multiplicand1S ) AND ProcIsValidNumberPiece( multiplicand2S )
     product1S = ProcMultiplyStringByInteger( multiplicand1S, multiplierI )
     product2S = ProcMultiplyStringByInteger( multiplicand2S, multiplierI )
     candidateS = product1S + product2S
     IF ProcIsPandigital10( candidateS )
      IF ProcIsPandigital10( multiplierS + multiplicand1S + multiplicand2S )
       workingBestS = ProcBestOfTwo( workingBestS, candidateS )
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   permutationS = ProcNextLowerPermutation( permutationS )
  ENDWHILE
 ENDFOR
 Return( workingBestS )
END

STRING PROC ProcEvaluateCaseTwoDigitMultiplier( STRING bestS )
 STRING workingBestS[ 255 ] = ""
 STRING tensS[ 255 ] = ""
 STRING onesS[ 255 ] = ""
 STRING multiplierS[ 255 ] = ""
 STRING remainingDigitsS[ 255 ] = ""
 STRING permutationS[ 255 ] = ""
 STRING multiplicand1S[ 255 ] = ""
 STRING multiplicand2S[ 255 ] = ""
 STRING product1S[ 255 ] = ""
 STRING product2S[ 255 ] = ""
 STRING candidateS[ 255 ] = ""
 INTEGER tensI = 0
 INTEGER onesI = 0
 INTEGER multiplierI = 0
 INTEGER splitI = 0
 //
 workingBestS = bestS
 FOR tensI = 9 DOWNTO 1
  FOR onesI = 9 DOWNTO 0
   IF NOT( tensI == onesI )
    tensS = ProcIntegerToString( tensI )
    onesS = ProcIntegerToString( onesI )
    multiplierS = tensS + onesS
    multiplierI = ProcStringToInteger( multiplierS )
    remainingDigitsS = ProcBuildRemainingDigits( multiplierS )
    permutationS = remainingDigitsS
    WHILE NOT( permutationS == "" )
     FOR splitI = 1 TO 7
      multiplicand1S = SubStr( permutationS, 1, splitI )
      multiplicand2S = SubStr( permutationS, splitI + 1, Length( permutationS ) - splitI )
      IF ProcIsValidNumberPiece( multiplicand1S ) AND ProcIsValidNumberPiece( multiplicand2S )
       product1S = ProcMultiplyStringByInteger( multiplicand1S, multiplierI )
       product2S = ProcMultiplyStringByInteger( multiplicand2S, multiplierI )
       candidateS = product1S + product2S
       IF ProcIsPandigital10( candidateS )
        IF ProcIsPandigital10( multiplierS + multiplicand1S + multiplicand2S )
         workingBestS = ProcBestOfTwo( workingBestS, candidateS )
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
     permutationS = ProcNextLowerPermutation( permutationS )
    ENDWHILE
   ENDIF
  ENDFOR
 ENDFOR
 Return( workingBestS )
END

PROC Main()
 STRING bestS[ 255 ] = ""
 STRING finalAnswerS[ 255 ] = ""
 //
 bestS = ""
 bestS = ProcEvaluateCaseOneDigitMultiplier( bestS )
 bestS = ProcEvaluateCaseTwoDigitMultiplier( bestS )
 finalAnswerS = bestS
 //
 CopyToWinClip( finalAnswerS )
 Warn( finalAnswerS )
 CopyToWinClip( finalAnswerS )
END
