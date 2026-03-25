// version 1.0.0.0.2
// LLM history: ChatGPT GPT-5.4 Thinking
//
// Stored TSE SAL rules applied in this source:
// // pure TSE SAL only
// // no hard coded final answer
// // answer fully calculated
// // no own variables named val or pos
// // Return() always with parentheses
// // only one final Warn() box
// // CopyToWinClip() before and after final Warn()
// // version number included
// // no intermediate Warn() boxes
// // final Warn() shows only the final answer
// // string parameters are not reassigned
// // string sizes are 255 or less
// // FORWARD declarations at top
// // declarations immediately after proc headers
// // BY / DOWNTO style preserved where relevant
// // no Python, no external helper
//
// Mathematical reduction used:
// Let n be the number of bounces.
// Let m = ( n + 3 ) / 2.
// Let limit = ( n + 1 ) / 4 = floor( ( m - 1 ) / 2 ).
// Count integers c with:
// // 1 <= c <= limit
// // c ð offset (mod 3), where offset = 3 - ( m mod 3 )
// // gcd( c, m ) = 1
// Final answer = 2 * count.
//
// For n = 12017639147 the correct answer is:
// 1209002624

INTEGER gPrimeCountI = 0
INTEGER gPrime1I = 0
INTEGER gPrime2I = 0
INTEGER gPrime3I = 0
INTEGER gPrime4I = 0
INTEGER gPrime5I = 0
INTEGER gPrime6I = 0
INTEGER gPrime7I = 0
INTEGER gPrime8I = 0
INTEGER gPrime9I = 0
INTEGER gPrime10I = 0
INTEGER gPrime11I = 0
INTEGER gPrime12I = 0
INTEGER gOffsetI = 0
STRING  gLimitS[255] = ""
STRING  gMS[255] = ""
//
//
FORWARD STRING  PROC ProcTrimLeadingZeros( STRING numberInS )
FORWARD INTEGER PROC ProcCompareBigIntegers( STRING leftInS, STRING rightInS )
FORWARD INTEGER PROC ProcCompareBigIntegerToSmall( STRING leftInS, INTEGER rightI )
FORWARD STRING  PROC ProcAddBigIntSmall( STRING numberInS, INTEGER addI )
FORWARD STRING  PROC ProcSubtractBigIntSmall( STRING numberInS, INTEGER subtractI )
FORWARD INTEGER PROC ProcBigModSmall( STRING numberInS, INTEGER divisorI )
FORWARD STRING  PROC ProcBigDivideBySmall( STRING numberInS, INTEGER divisorI )
FORWARD STRING  PROC ProcSquareIntAsString( INTEGER valueI )
FORWARD PROC    ProcStorePrime( INTEGER primeI )
FORWARD INTEGER PROC ProcGetPrime( INTEGER indexI )
FORWARD PROC    ProcFactorMS()
FORWARD INTEGER PROC ProcCountForDivisor( INTEGER divisorI )
FORWARD INTEGER PROC ProcInclusionExclusion( INTEGER startIndexI, INTEGER productI, INTEGER signI )
FORWARD STRING  PROC ProcComputeAnswer()
//
//
STRING PROC ProcTrimLeadingZeros( STRING numberInS )
 STRING workS[255] = ""
 INTEGER indexI = 0
 //
 workS = numberInS
 indexI = 1
 WHILE indexI < Length( workS ) AND SubStr( workS, indexI, 1 ) == "0"
  indexI = indexI + 1
 ENDWHILE
 RETURN( SubStr( workS, indexI, Length( workS ) - indexI + 1 ) )
END
//
//
INTEGER PROC ProcCompareBigIntegers( STRING leftInS, STRING rightInS )
 STRING leftS[255] = ""
 STRING rightS[255] = ""
 INTEGER leftLengthI = 0
 INTEGER rightLengthI = 0
 INTEGER indexI = 0
 //
 leftS = ProcTrimLeadingZeros( leftInS )
 rightS = ProcTrimLeadingZeros( rightInS )
 leftLengthI = Length( leftS )
 rightLengthI = Length( rightS )
 IF leftLengthI < rightLengthI
  RETURN( -1 )
 ENDIF
 IF leftLengthI > rightLengthI
  RETURN( 1 )
 ENDIF
 FOR indexI = 1 TO leftLengthI
  IF SubStr( leftS, indexI, 1 ) < SubStr( rightS, indexI, 1 )
   RETURN( -1 )
  ENDIF
  IF SubStr( leftS, indexI, 1 ) > SubStr( rightS, indexI, 1 )
   RETURN( 1 )
  ENDIF
 ENDFOR
 RETURN( 0 )
END
//
//
INTEGER PROC ProcCompareBigIntegerToSmall( STRING leftInS, INTEGER rightI )
 STRING rightS[255] = ""
 //
 rightS = Format( rightI )
 RETURN( ProcCompareBigIntegers( leftInS, rightS ) )
END
//
//
STRING PROC ProcAddBigIntSmall( STRING numberInS, INTEGER addI )
 STRING numberS[255] = ""
 STRING resultS[255] = ""
 STRING digitS[2] = ""
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER carryI = 0
 INTEGER sumI = 0
 //
 numberS = ProcTrimLeadingZeros( numberInS )
 carryI = addI
 FOR indexI = Length( numberS ) DOWNTO 1
  digitS = SubStr( numberS, indexI, 1 )
  digitI = Val( digitS )
  sumI = digitI + carryI
  resultS = Format( sumI mod 10 ) + resultS
  carryI = sumI / 10
 ENDFOR
 WHILE carryI > 0
  resultS = Format( carryI mod 10 ) + resultS
  carryI = carryI / 10
 ENDWHILE
 RETURN( ProcTrimLeadingZeros( resultS ) )
END
//
//
STRING PROC ProcSubtractBigIntSmall( STRING numberInS, INTEGER subtractI )
 STRING numberS[255] = ""
 STRING resultS[255] = ""
 STRING digitS[2] = ""
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER borrowI = 0
 INTEGER subDigitI = 0
 INTEGER valueI = 0
 INTEGER tempSubtractI = 0
 //
 numberS = ProcTrimLeadingZeros( numberInS )
 resultS = ""
 tempSubtractI = subtractI
 FOR indexI = Length( numberS ) DOWNTO 1
  digitS = SubStr( numberS, indexI, 1 )
  digitI = Val( digitS )
  subDigitI = tempSubtractI mod 10
  tempSubtractI = tempSubtractI / 10
  valueI = digitI - borrowI - subDigitI
  IF valueI < 0
   valueI = valueI + 10
   borrowI = 1
  ELSE
   borrowI = 0
  ENDIF
  resultS = Format( valueI ) + resultS
 ENDFOR
 RETURN( ProcTrimLeadingZeros( resultS ) )
END
//
//
INTEGER PROC ProcBigModSmall( STRING numberInS, INTEGER divisorI )
 STRING numberS[255] = ""
 STRING digitS[2] = ""
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER remainderI = 0
 //
 numberS = ProcTrimLeadingZeros( numberInS )
 remainderI = 0
 FOR indexI = 1 TO Length( numberS )
  digitS = SubStr( numberS, indexI, 1 )
  digitI = Val( digitS )
  remainderI = ( remainderI * 10 + digitI ) mod divisorI
 ENDFOR
 RETURN( remainderI )
END
//
//
STRING PROC ProcBigDivideBySmall( STRING numberInS, INTEGER divisorI )
 STRING numberS[255] = ""
 STRING resultS[255] = ""
 STRING digitS[2] = ""
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER currentI = 0
 INTEGER quotientDigitI = 0
 INTEGER remainderI = 0
 //
 numberS = ProcTrimLeadingZeros( numberInS )
 resultS = ""
 remainderI = 0
 FOR indexI = 1 TO Length( numberS )
  digitS = SubStr( numberS, indexI, 1 )
  digitI = Val( digitS )
  currentI = remainderI * 10 + digitI
  quotientDigitI = currentI / divisorI
  remainderI = currentI mod divisorI
  IF resultS <> "" OR quotientDigitI <> 0
   resultS = resultS + Format( quotientDigitI )
  ENDIF
 ENDFOR
 IF resultS == ""
  resultS = "0"
 ENDIF
 RETURN( ProcTrimLeadingZeros( resultS ) )
END
//
//
STRING PROC ProcSquareIntAsString( INTEGER valueI )
 STRING leftS[255] = ""
 STRING rightS[255] = ""
 STRING resultS[255] = ""
 INTEGER leftI = 0
 INTEGER carryI = 0
 INTEGER digitI = 0
 INTEGER productI = 0
 //
 leftS = Format( valueI )
 rightS = leftS
 resultS = ""
 carryI = 0
 FOR leftI = Length( rightS ) DOWNTO 1
  digitI = Val( SubStr( rightS, leftI, 1 ) )
  productI = digitI * valueI + carryI
  resultS = Format( productI mod 10 ) + resultS
  carryI = productI / 10
 ENDFOR
 WHILE carryI > 0
  resultS = Format( carryI mod 10 ) + resultS
  carryI = carryI / 10
 ENDWHILE
 RETURN( ProcTrimLeadingZeros( resultS ) )
END
//
//
PROC ProcStorePrime( INTEGER primeI )
 //
 gPrimeCountI = gPrimeCountI + 1
 CASE gPrimeCountI
  WHEN 1
   gPrime1I = primeI
  WHEN 2
   gPrime2I = primeI
  WHEN 3
   gPrime3I = primeI
  WHEN 4
   gPrime4I = primeI
  WHEN 5
   gPrime5I = primeI
  WHEN 6
   gPrime6I = primeI
  WHEN 7
   gPrime7I = primeI
  WHEN 8
   gPrime8I = primeI
  WHEN 9
   gPrime9I = primeI
  WHEN 10
   gPrime10I = primeI
  WHEN 11
   gPrime11I = primeI
  WHEN 12
   gPrime12I = primeI
 ENDCASE
END
//
//
INTEGER PROC ProcGetPrime( INTEGER indexI )
 //
 CASE indexI
  WHEN 1
   RETURN( gPrime1I )
  WHEN 2
   RETURN( gPrime2I )
  WHEN 3
   RETURN( gPrime3I )
  WHEN 4
   RETURN( gPrime4I )
  WHEN 5
   RETURN( gPrime5I )
  WHEN 6
   RETURN( gPrime6I )
  WHEN 7
   RETURN( gPrime7I )
  WHEN 8
   RETURN( gPrime8I )
  WHEN 9
   RETURN( gPrime9I )
  WHEN 10
   RETURN( gPrime10I )
  WHEN 11
   RETURN( gPrime11I )
  WHEN 12
   RETURN( gPrime12I )
 ENDCASE
 RETURN( 0 )
END
//
//
PROC ProcFactorMS()
 STRING remainingS[255] = ""
 STRING squareS[255] = ""
 INTEGER divisorI = 0
 INTEGER compareI = 0
 INTEGER remainderI = 0
 INTEGER finalPrimeI = 0
 //
 gPrimeCountI = 0
 remainingS = gMS
 divisorI = 2
 WHILE TRUE
  squareS = ProcSquareIntAsString( divisorI )
  compareI = ProcCompareBigIntegers( squareS, remainingS )
  IF compareI > 0
   BREAK
  ENDIF
  remainderI = ProcBigModSmall( remainingS, divisorI )
  IF remainderI == 0
   ProcStorePrime( divisorI )
   WHILE ProcBigModSmall( remainingS, divisorI ) == 0
    remainingS = ProcBigDivideBySmall( remainingS, divisorI )
   ENDWHILE
  ENDIF
  IF divisorI == 2
   divisorI = 3
  ELSE
   divisorI = divisorI + 2
  ENDIF
 ENDWHILE
 IF remainingS <> "1"
  finalPrimeI = Val( remainingS )
  ProcStorePrime( finalPrimeI )
 ENDIF
END
//
//
INTEGER PROC ProcCountForDivisor( INTEGER divisorI )
 STRING maxKS[255] = ""
 STRING tempS[255] = ""
 INTEGER divisorMod3I = 0
 INTEGER inverseI = 0
 INTEGER residueKI = 0
 INTEGER compareI = 0
 INTEGER countI = 0
 //
 maxKS = ProcBigDivideBySmall( gLimitS, divisorI )
 divisorMod3I = divisorI mod 3
 IF divisorMod3I == 1
  inverseI = 1
 ELSE
  inverseI = 2
 ENDIF
 residueKI = ( gOffsetI * inverseI ) mod 3
 IF residueKI == 0
  residueKI = 3
 ENDIF
 compareI = ProcCompareBigIntegerToSmall( maxKS, residueKI )
 IF compareI < 0
  RETURN( 0 )
 ENDIF
 tempS = ProcSubtractBigIntSmall( maxKS, residueKI )
 tempS = ProcBigDivideBySmall( tempS, 3 )
 countI = Val( tempS ) + 1
 RETURN( countI )
END
//
//
INTEGER PROC ProcInclusionExclusion( INTEGER startIndexI, INTEGER productI, INTEGER signI )
 INTEGER totalI = 0
 INTEGER indexI = 0
 INTEGER nextPrimeI = 0
 INTEGER nextProductI = 0
 INTEGER contributionI = 0
 //
 totalI = 0
 FOR indexI = startIndexI TO gPrimeCountI
  nextPrimeI = ProcGetPrime( indexI )
  nextProductI = productI * nextPrimeI
  contributionI = ProcCountForDivisor( nextProductI )
  IF signI < 0
   totalI = totalI - contributionI
  ELSE
   totalI = totalI + contributionI
  ENDIF
  totalI = totalI + ProcInclusionExclusion( indexI + 1, nextProductI, 0 - signI )
 ENDFOR
 RETURN( totalI )
END
//
//
STRING PROC ProcComputeAnswer()
 STRING surfacesS[255] = ""
 STRING answerS[255] = ""
 INTEGER baseCountI = 0
 INTEGER totalCountI = 0
 INTEGER finalAnswerI = 0
 //
 surfacesS = "12017639147"
 gMS = ProcBigDivideBySmall( ProcAddBigIntSmall( surfacesS, 3 ), 2 )
 gLimitS = ProcBigDivideBySmall( ProcAddBigIntSmall( surfacesS, 1 ), 4 )
 gOffsetI = 3 - ProcBigModSmall( gMS, 3 )
 ProcFactorMS()
 baseCountI = ProcCountForDivisor( 1 )
 totalCountI = baseCountI + ProcInclusionExclusion( 1, 1, -1 )
 finalAnswerI = totalCountI * 2
 answerS = Format( finalAnswerI )
 RETURN( answerS )
END
//
//
PROC Main()
 STRING answerS[255] = ""
 //
 answerS = ProcComputeAnswer()
 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
END
