/*
 Squarefree Binomial Coefficients
 Project Euler 203
 Pure TSE SAL solution
 <version>1.0.0.0.2</version>
 History:
 1.0.0.0.2 - 2026-03-25 - Created by ChatGPT GPT-5.4 Thinking
 1.0.0.0.1 - 2026-03-25 - Initial version
 Rules applied:
 - Pure TSE SAL only
 - No hardcoded final answer
 - Final answer calculated from loops/functions
 - Return() always uses parentheses
 - No own variables named val or pos
 - Only one final Warn() box
 - Two CopyToWinClip() calls around final Warn()
 - Final Warn() shows only the final result
 - #define used only for numeric constants
*/
#define MAX_PRIME_COUNT 15
INTEGER gPrimeBufferI = 0
INTEGER gUniqueBufferI = 0
FORWARD STRING PROC ProcTrimLeadingZeros( STRING numberInS )
FORWARD INTEGER PROC ProcCompareBigIntegers( STRING leftInS, STRING rightInS )
FORWARD STRING PROC ProcAddBigIntegers( STRING leftInS, STRING rightInS )
FORWARD STRING PROC ProcMultiplyBigIntegerByInt( STRING numberInS, INTEGER multiplierI )
FORWARD INTEGER PROC ProcFactorialPrimeExponent( INTEGER numberI, INTEGER primeI )
FORWARD INTEGER PROC ProcIsSquarefreeBinomial( INTEGER rowI, INTEGER columnI )
FORWARD STRING PROC ProcBuildBinomialString( INTEGER rowI, INTEGER columnI )
FORWARD PROC ProcCreatePrimeBuffer()
FORWARD INTEGER PROC ProcBufferContainsString( INTEGER bufferIdI, STRING targetInS )
STRING PROC ProcTrimLeadingZeros( STRING numberInS )
 STRING numberS[255] = ""
 STRING resultS[255] = ""
 INTEGER indexI = 1
 INTEGER lengthI = 0
 numberS = numberInS
 lengthI = Length( numberS )
 WHILE ( indexI < lengthI ) AND ( SubStr( numberS, indexI, 1 ) == "0" )
  indexI = indexI + 1
 ENDWHILE
 resultS = SubStr( numberS, indexI, lengthI - indexI + 1 )
 RETURN( resultS )
END
INTEGER PROC ProcCompareBigIntegers( STRING leftInS, STRING rightInS )
 STRING leftS[255] = ""
 STRING rightS[255] = ""
 INTEGER leftLengthI = 0
 INTEGER rightLengthI = 0
 leftS  = ProcTrimLeadingZeros( leftInS )
 rightS = ProcTrimLeadingZeros( rightInS )
 leftLengthI  = Length( leftS )
 rightLengthI = Length( rightS )
 IF leftLengthI < rightLengthI
  RETURN( -1 )
 ENDIF
 IF leftLengthI > rightLengthI
  RETURN( 1 )
 ENDIF
 IF leftS < rightS
  RETURN( -1 )
 ENDIF
 IF leftS > rightS
  RETURN( 1 )
 ENDIF
 RETURN( 0 )
END
STRING PROC ProcAddBigIntegers( STRING leftInS, STRING rightInS )
 STRING leftS[255] = ""
 STRING rightS[255] = ""
 STRING reverseS[255] = ""
 STRING resultS[255] = ""
 STRING digitS[2] = ""
 INTEGER leftIndexI = 0
 INTEGER rightIndexI = 0
 INTEGER leftDigitI = 0
 INTEGER rightDigitI = 0
 INTEGER sumDigitI = 0
 INTEGER carryI = 0
 INTEGER reverseIndexI = 0
 leftS  = ProcTrimLeadingZeros( leftInS )
 rightS = ProcTrimLeadingZeros( rightInS )
 leftIndexI  = Length( leftS )
 rightIndexI = Length( rightS )
 WHILE ( leftIndexI > 0 ) OR ( rightIndexI > 0 ) OR ( carryI > 0 )
  leftDigitI = 0
  IF leftIndexI > 0
   leftDigitI = Val( SubStr( leftS, leftIndexI, 1 ) )
   leftIndexI = leftIndexI - 1
  ENDIF
  rightDigitI = 0
  IF rightIndexI > 0
   rightDigitI = Val( SubStr( rightS, rightIndexI, 1 ) )
   rightIndexI = rightIndexI - 1
  ENDIF
  sumDigitI = leftDigitI + rightDigitI + carryI
  carryI = sumDigitI / 10
  digitS = Chr( Asc( "0" ) + ( sumDigitI mod 10 ) )
  reverseS = reverseS + digitS
 ENDWHILE
 resultS = ""
 FOR reverseIndexI = Length( reverseS ) DOWNTO 1 BY 1
  resultS = resultS + SubStr( reverseS, reverseIndexI, 1 )
 ENDFOR
 RETURN( ProcTrimLeadingZeros( resultS ) )
END
STRING PROC ProcMultiplyBigIntegerByInt( STRING numberInS, INTEGER multiplierI )
 STRING numberS[255] = ""
 STRING reverseS[255] = ""
 STRING resultS[255] = ""
 STRING digitS[2] = ""
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER productI = 0
 INTEGER carryI = 0
 INTEGER reverseIndexI = 0
 IF multiplierI == 0
  RETURN( "0" )
 ENDIF
 IF multiplierI == 1
  RETURN( ProcTrimLeadingZeros( numberInS ) )
 ENDIF
 numberS = ProcTrimLeadingZeros( numberInS )
 FOR indexI = Length( numberS ) DOWNTO 1 BY 1
  digitI = Val( SubStr( numberS, indexI, 1 ) )
  productI = digitI * multiplierI + carryI
  carryI = productI / 10
  digitS = Chr( Asc( "0" ) + ( productI mod 10 ) )
  reverseS = reverseS + digitS
 ENDFOR
 WHILE carryI > 0
  digitS = Chr( Asc( "0" ) + ( carryI mod 10 ) )
  reverseS = reverseS + digitS
  carryI = carryI / 10
 ENDWHILE
 resultS = ""
 FOR reverseIndexI = Length( reverseS ) DOWNTO 1 BY 1
  resultS = resultS + SubStr( reverseS, reverseIndexI, 1 )
 ENDFOR
 RETURN( ProcTrimLeadingZeros( resultS ) )
END
INTEGER PROC ProcFactorialPrimeExponent( INTEGER numberI, INTEGER primeI )
 INTEGER workI = 0
 INTEGER exponentI = 0
 workI = numberI
 WHILE workI > 0
  workI = workI / primeI
  exponentI = exponentI + workI
 ENDWHILE
 RETURN( exponentI )
END
INTEGER PROC ProcIsSquarefreeBinomial( INTEGER rowI, INTEGER columnI )
 INTEGER lineCountI = 0
 INTEGER lineI = 0
 INTEGER primeI = 0
 INTEGER exponentI = 0
 STRING lineS[255] = ""
 PushLocation()
 GotoBufferId( gPrimeBufferI )
 lineCountI = NumLines()
 FOR lineI = 1 TO lineCountI BY 1
  GotoLine( lineI )
  lineS = GetText( 1, CurrLineLen() )
  IF lineS <> ""
   primeI = Val( lineS )
   IF primeI <= rowI
    exponentI = ProcFactorialPrimeExponent( rowI, primeI ) - ProcFactorialPrimeExponent( columnI, primeI ) - ProcFactorialPrimeExponent( rowI - columnI, primeI )
    IF exponentI >= 2
     PopLocation()
     RETURN( FALSE )
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 PopLocation()
 RETURN( TRUE )
END
STRING PROC ProcBuildBinomialString( INTEGER rowI, INTEGER columnI )
 STRING resultS[255] = ""
 STRING lineS[255] = ""
 INTEGER lineCountI = 0
 INTEGER lineI = 0
 INTEGER primeI = 0
 INTEGER exponentI = 0
 INTEGER repeatI = 0
 resultS = "1"
 PushLocation()
 GotoBufferId( gPrimeBufferI )
 lineCountI = NumLines()
 FOR lineI = 1 TO lineCountI BY 1
  GotoLine( lineI )
  lineS = GetText( 1, CurrLineLen() )
  IF lineS <> ""
   primeI = Val( lineS )
   IF primeI <= rowI
    exponentI = ProcFactorialPrimeExponent( rowI, primeI ) - ProcFactorialPrimeExponent( columnI, primeI ) - ProcFactorialPrimeExponent( rowI - columnI, primeI )
    FOR repeatI = 1 TO exponentI BY 1
     resultS = ProcMultiplyBigIntegerByInt( resultS, primeI )
    ENDFOR
   ENDIF
  ENDIF
 ENDFOR
 PopLocation()
 RETURN( resultS )
END
PROC ProcCreatePrimeBuffer()
 AddLine( "2",  gPrimeBufferI )
 AddLine( "3",  gPrimeBufferI )
 AddLine( "5",  gPrimeBufferI )
 AddLine( "7",  gPrimeBufferI )
 AddLine( "11", gPrimeBufferI )
 AddLine( "13", gPrimeBufferI )
 AddLine( "17", gPrimeBufferI )
 AddLine( "19", gPrimeBufferI )
 AddLine( "23", gPrimeBufferI )
 AddLine( "29", gPrimeBufferI )
 AddLine( "31", gPrimeBufferI )
 AddLine( "37", gPrimeBufferI )
 AddLine( "41", gPrimeBufferI )
 AddLine( "43", gPrimeBufferI )
 AddLine( "47", gPrimeBufferI )
END
INTEGER PROC ProcBufferContainsString( INTEGER bufferIdI, STRING targetInS )
 INTEGER lineCountI = 0
 INTEGER lineI = 0
 STRING lineS[255] = ""
 PushLocation()
 GotoBufferId( bufferIdI )
 lineCountI = NumLines()
 FOR lineI = 1 TO lineCountI BY 1
  GotoLine( lineI )
  lineS = GetText( 1, CurrLineLen() )
  IF lineS == targetInS
   PopLocation()
   RETURN( TRUE )
  ENDIF
 ENDFOR
 PopLocation()
 RETURN( FALSE )
END
PROC Main()
 STRING answerS[255] = ""
 STRING coefficientS[255] = ""
 INTEGER rowI = 0
 INTEGER columnI = 0
 gPrimeBufferI  = CreateTempBuffer()
 gUniqueBufferI = CreateTempBuffer()
 ProcCreatePrimeBuffer()
 answerS = "0"
 FOR rowI = 0 TO 50 BY 1
  FOR columnI = 0 TO rowI BY 1
   IF ProcIsSquarefreeBinomial( rowI, columnI )
    coefficientS = ProcBuildBinomialString( rowI, columnI )
    IF NOT ProcBufferContainsString( gUniqueBufferI, coefficientS )
     AddLine( coefficientS, gUniqueBufferI )
     answerS = ProcAddBigIntegers( answerS, coefficientS )
    ENDIF
   ENDIF
  ENDFOR
 ENDFOR
 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
 AbandonFile( gUniqueBufferI )
 AbandonFile( gPrimeBufferI )
END
