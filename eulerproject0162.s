/*
  Euler Project 162
  Hexadecimal numbers
  Pure TSE SAL solution
  <version>1.0.0.0.0</version>

  History:
    1.0.0.0.0
      - Initial pure TSE SAL version
      - Uses inclusion-exclusion
      - Uses decimal string big integer arithmetic
      - Converts final decimal result to hexadecimal
      - LLM: GPT-5.4 Thinking
*/

FORWARD STRING PROC ProcTrimLeadingZeros( STRING numberS )
FORWARD INTEGER PROC ProcCompareDecimalStrings( STRING firstS, STRING secondS )
FORWARD STRING PROC ProcAddDecimalStrings( STRING firstS, STRING secondS )
FORWARD STRING PROC ProcSubtractDecimalStrings( STRING firstS, STRING secondS )
FORWARD STRING PROC ProcMultiplyDecimalStringByInteger( STRING numberS, INTEGER multiplierI )
FORWARD STRING PROC ProcDivideDecimalStringByInteger( STRING numberS, INTEGER divisorI )
FORWARD STRING PROC ProcHexDigitFromInteger( INTEGER digitI )
FORWARD STRING PROC ProcDecimalStringToHexString( STRING numberS )

INTEGER gDivisionRemainderI = 0

STRING PROC ProcTrimLeadingZeros( STRING numberS )
 STRING workS[255] = ""
 workS = numberS
 WHILE Length( workS ) > 1
  IF SubStr( workS, 1, 1 ) == "0"
   workS = SubStr( workS, 2, Length( workS ) - 1 )
  ELSE
   Return( workS )
  ENDIF
 ENDWHILE
 Return( workS )
END

INTEGER PROC ProcCompareDecimalStrings( STRING firstS, STRING secondS )
 STRING leftS[255] = ""
 STRING rightS[255] = ""
 INTEGER indexI = 0
 INTEGER leftDigitI = 0
 INTEGER rightDigitI = 0
 leftS = ProcTrimLeadingZeros( firstS )
 rightS = ProcTrimLeadingZeros( secondS )
 IF Length( leftS ) < Length( rightS )
  Return( -1 )
 ENDIF
 IF Length( leftS ) > Length( rightS )
  Return( 1 )
 ENDIF
 FOR indexI = 1 TO Length( leftS )
  leftDigitI = Val( SubStr( leftS, indexI, 1 ) )
  rightDigitI = Val( SubStr( rightS, indexI, 1 ) )
  IF leftDigitI < rightDigitI
   Return( -1 )
  ENDIF
  IF leftDigitI > rightDigitI
   Return( 1 )
  ENDIF
 ENDFOR
 Return( 0 )
END

STRING PROC ProcAddDecimalStrings( STRING firstS, STRING secondS )
 STRING leftS[255] = ""
 STRING rightS[255] = ""
 STRING resultS[255] = ""
 INTEGER leftIndexI = 0
 INTEGER rightIndexI = 0
 INTEGER leftDigitI = 0
 INTEGER rightDigitI = 0
 INTEGER sumI = 0
 INTEGER carryI = 0
 INTEGER digitI = 0
 leftS = ProcTrimLeadingZeros( firstS )
 rightS = ProcTrimLeadingZeros( secondS )
 resultS = ""
 carryI = 0
 leftIndexI = Length( leftS )
 rightIndexI = Length( rightS )
 WHILE leftIndexI > 0 OR rightIndexI > 0 OR carryI > 0
  leftDigitI = 0
  rightDigitI = 0
  IF leftIndexI > 0
   leftDigitI = Val( SubStr( leftS, leftIndexI, 1 ) )
   leftIndexI = leftIndexI - 1
  ENDIF
  IF rightIndexI > 0
   rightDigitI = Val( SubStr( rightS, rightIndexI, 1 ) )
   rightIndexI = rightIndexI - 1
  ENDIF
  sumI = leftDigitI + rightDigitI + carryI
  digitI = sumI mod 10
  carryI = sumI / 10
  resultS = Chr( 48 + digitI ) + resultS
 ENDWHILE
 Return( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcSubtractDecimalStrings( STRING firstS, STRING secondS )
 STRING leftS[255] = ""
 STRING rightS[255] = ""
 STRING resultS[255] = ""
 INTEGER leftIndexI = 0
 INTEGER rightIndexI = 0
 INTEGER leftDigitI = 0
 INTEGER rightDigitI = 0
 INTEGER diffI = 0
 INTEGER borrowI = 0
 leftS = ProcTrimLeadingZeros( firstS )
 rightS = ProcTrimLeadingZeros( secondS )
 resultS = ""
 borrowI = 0
 leftIndexI = Length( leftS )
 rightIndexI = Length( rightS )
 WHILE leftIndexI > 0
  leftDigitI = Val( SubStr( leftS, leftIndexI, 1 ) ) - borrowI
  rightDigitI = 0
  IF rightIndexI > 0
   rightDigitI = Val( SubStr( rightS, rightIndexI, 1 ) )
   rightIndexI = rightIndexI - 1
  ENDIF
  IF leftDigitI < rightDigitI
   leftDigitI = leftDigitI + 10
   borrowI = 1
  ELSE
   borrowI = 0
  ENDIF
  diffI = leftDigitI - rightDigitI
  resultS = Chr( 48 + diffI ) + resultS
  leftIndexI = leftIndexI - 1
 ENDWHILE
 Return( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcMultiplyDecimalStringByInteger( STRING numberS, INTEGER multiplierI )
 STRING workS[255] = ""
 STRING resultS[255] = ""
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER productI = 0
 INTEGER carryI = 0
 workS = ProcTrimLeadingZeros( numberS )
 IF workS == "0" OR multiplierI == 0
  Return( "0" )
 ENDIF
 resultS = ""
 carryI = 0
 FOR indexI = Length( workS ) DOWNTO 1
  digitI = Val( SubStr( workS, indexI, 1 ) )
  productI = digitI * multiplierI + carryI
  resultS = Chr( 48 + ( productI mod 10 ) ) + resultS
  carryI = productI / 10
 ENDFOR
 WHILE carryI > 0
  resultS = Chr( 48 + ( carryI mod 10 ) ) + resultS
  carryI = carryI / 10
 ENDWHILE
 Return( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcDivideDecimalStringByInteger( STRING numberS, INTEGER divisorI )
 STRING workS[255] = ""
 STRING quotientS[255] = ""
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER currentI = 0
 INTEGER quotientDigitI = 0
 INTEGER startedB = FALSE
 workS = ProcTrimLeadingZeros( numberS )
 quotientS = ""
 gDivisionRemainderI = 0
 startedB = FALSE
 FOR indexI = 1 TO Length( workS )
  digitI = Val( SubStr( workS, indexI, 1 ) )
  currentI = gDivisionRemainderI * 10 + digitI
  quotientDigitI = currentI / divisorI
  gDivisionRemainderI = currentI mod divisorI
  IF quotientDigitI > 0 OR startedB
   quotientS = quotientS + Chr( 48 + quotientDigitI )
   startedB = TRUE
  ENDIF
 ENDFOR
 IF quotientS == ""
  quotientS = "0"
 ENDIF
 Return( ProcTrimLeadingZeros( quotientS ) )
END

STRING PROC ProcHexDigitFromInteger( INTEGER digitI )
 IF digitI < 10
  Return( Chr( 48 + digitI ) )
 ENDIF
 Return( Chr( 55 + digitI ) )
END

STRING PROC ProcDecimalStringToHexString( STRING numberS )
 STRING workS[255] = ""
 STRING hexS[255] = ""
 workS = ProcTrimLeadingZeros( numberS )
 IF workS == "0"
  Return( "0" )
 ENDIF
 hexS = ""
 WHILE NOT( workS == "0" )
  workS = ProcDivideDecimalStringByInteger( workS, 16 )
  hexS = ProcHexDigitFromInteger( gDivisionRemainderI ) + hexS
 ENDWHILE
 Return( hexS )
END

PROC Main()
 STRING totalS[255] = "0"
 STRING pow16Nm1S[255] = "1"
 STRING pow15Nm1S[255] = "1"
 STRING pow14Nm1S[255] = "1"
 STRING pow13Nm1S[255] = "1"
 STRING pow15NS[255] = ""
 STRING pow14NS[255] = ""
 STRING pow13NS[255] = ""
 STRING term1S[255] = ""
 STRING term2S[255] = ""
 STRING term3S[255] = ""
 STRING term4S[255] = ""
 STRING term5S[255] = ""
 STRING term6S[255] = ""
 STRING positiveS[255] = ""
 STRING negativeS[255] = ""
 STRING countS[255] = ""
 STRING resultHexS[255] = ""
 STRING messageS[255] = ""
 INTEGER nI = 0
 FOR nI = 1 TO 16
  pow15NS = ProcMultiplyDecimalStringByInteger( pow15Nm1S, 15 )
  pow14NS = ProcMultiplyDecimalStringByInteger( pow14Nm1S, 14 )
  pow13NS = ProcMultiplyDecimalStringByInteger( pow13Nm1S, 13 )
  term1S = ProcMultiplyDecimalStringByInteger( pow16Nm1S, 15 )
  term2S = pow15NS
  term3S = ProcMultiplyDecimalStringByInteger( pow15Nm1S, 28 )
  term4S = ProcMultiplyDecimalStringByInteger( pow14NS, 2 )
  term5S = ProcMultiplyDecimalStringByInteger( pow14Nm1S, 13 )
  term6S = pow13NS
  positiveS = ProcAddDecimalStrings( term1S, term4S )
  positiveS = ProcAddDecimalStrings( positiveS, term5S )
  negativeS = ProcAddDecimalStrings( term2S, term3S )
  negativeS = ProcAddDecimalStrings( negativeS, term6S )
  countS = ProcSubtractDecimalStrings( positiveS, negativeS )
  IF nI >= 3
   totalS = ProcAddDecimalStrings( totalS, countS )
  ENDIF
  pow16Nm1S = ProcMultiplyDecimalStringByInteger( pow16Nm1S, 16 )
  pow15Nm1S = pow15NS
  pow14Nm1S = pow14NS
  pow13Nm1S = pow13NS
 ENDFOR
 resultHexS = ProcDecimalStringToHexString( totalS )
 CopyToWinClip( resultHexS )
 messageS = "Euler Project 162" + Chr( 13 ) +
            "hexadecimal result = " + resultHexS
 Warn( messageS )
 CopyToWinClip( resultHexS )
END
