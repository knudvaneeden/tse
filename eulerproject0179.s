/*
 Euler Project 179
 Consecutive Positive Divisors
 https://projecteuler.net/problem=179

 Problem:
 Find the number of integers 1 < n < 10^7, for which n and n + 1
 have the same number of positive divisors.

 Expected final result after full calculation: 986262

 Created by: ChatGPT GPT-5.4 Thinking
 <version>1.0.0.0.1</version>
*/

#define LIMIT_179 10000000
#define SEGMENT_SIZE_179 20000
#define PRIME_LIMIT_179 3162

integer gPrimeBufferI = 0
integer gResidualBufferI = 0
integer gDivisorBufferI = 0

FORWARD string proc ProcIntegerToString( integer numberI )
FORWARD integer proc ProcMinimum( integer leftI, integer rightI )
FORWARD integer proc ProcBufferReadInteger( integer bufferIdI, integer lineNumberI )
FORWARD proc ProcBufferWriteInteger( integer bufferIdI, integer lineNumberI, integer valueI )
FORWARD proc ProcGeneratePrimeBuffer()
FORWARD proc ProcCreateSegmentBuffers( integer lowI, integer highI )
FORWARD integer proc ProcCountConsecutiveEqualDivisors()

string proc ProcIntegerToString( integer numberI )
 string numberS[255] = ""
 //
 numberS = Format( numberI )
 RETURN( numberS )
END

integer proc ProcMinimum( integer leftI, integer rightI )
 integer resultI = 0
 //
 IF leftI < rightI
  resultI = leftI
 ELSE
  resultI = rightI
 ENDIF
 RETURN( resultI )
END

integer proc ProcBufferReadInteger( integer bufferIdI, integer lineNumberI )
 string valueS[255] = ""
 integer valueI = 0
 //
 GotoBufferId( bufferIdI )
 GotoLine( lineNumberI )
 valueS = GetText( 1, CurrLineLen() )
 valueI = Val( valueS )
 RETURN( valueI )
END

proc ProcBufferWriteInteger( integer bufferIdI, integer lineNumberI, integer valueI )
 string valueS[255] = ""
 //
 valueS = ProcIntegerToString( valueI )
 GotoBufferId( bufferIdI )
 GotoLine( lineNumberI )
 BegLine()
 KillToEol()
 InsertText( valueS )
END

proc ProcGeneratePrimeBuffer()
 integer candidateI = 0
 integer divisorI = 0
 integer isPrimeB = FALSE
 //
 gPrimeBufferI = CreateTempBuffer()
 FOR candidateI = 2 TO PRIME_LIMIT_179
  isPrimeB = TRUE
  divisorI = 2
  WHILE divisorI * divisorI <= candidateI AND isPrimeB
   IF candidateI mod divisorI == 0
    isPrimeB = FALSE
   ELSE
    divisorI = divisorI + 1
   ENDIF
  ENDWHILE
  IF isPrimeB
   AddLine( ProcIntegerToString( candidateI ), gPrimeBufferI )
  ENDIF
 ENDFOR
END

proc ProcCreateSegmentBuffers( integer lowI, integer highI )
 integer numberI = 0
 //
 gResidualBufferI = CreateTempBuffer()
 gDivisorBufferI = CreateTempBuffer()
 FOR numberI = lowI TO highI
  AddLine( ProcIntegerToString( numberI ), gResidualBufferI )
  AddLine( "1", gDivisorBufferI )
 ENDFOR
END

integer proc ProcCountConsecutiveEqualDivisors()
 integer answerI = 0
 integer lowI = 0
 integer highI = 0
 integer primeLineI = 0
 integer primeCountI = 0
 integer primeI = 0
 integer firstMultipleI = 0
 integer multipleI = 0
 integer indexLineI = 0
 integer residualI = 0
 integer exponentI = 0
 integer divisorCountI = 0
 integer currentNumberI = 0
 integer previousDivisorCountI = 0
 integer lineCountI = 0
 //
 answerI = 0
 previousDivisorCountI = 0
 lowI = 2
 WHILE lowI <= LIMIT_179
  highI = ProcMinimum( lowI + SEGMENT_SIZE_179 - 1, LIMIT_179 )
  ProcCreateSegmentBuffers( lowI, highI )
  GotoBufferId( gPrimeBufferI )
  primeCountI = NumLines()
  FOR primeLineI = 1 TO primeCountI
   primeI = ProcBufferReadInteger( gPrimeBufferI, primeLineI )
   IF primeI * primeI <= highI
    firstMultipleI = lowI / primeI
    IF lowI mod primeI > 0
     firstMultipleI = firstMultipleI + 1
    ENDIF
    firstMultipleI = firstMultipleI * primeI
    multipleI = firstMultipleI
    WHILE multipleI <= highI
     indexLineI = multipleI - lowI + 1
     residualI = ProcBufferReadInteger( gResidualBufferI, indexLineI )
     exponentI = 0
     WHILE residualI mod primeI == 0
      residualI = residualI / primeI
      exponentI = exponentI + 1
     ENDWHILE
     IF exponentI > 0
      divisorCountI = ProcBufferReadInteger( gDivisorBufferI, indexLineI )
      divisorCountI = divisorCountI * ( exponentI + 1 )
      ProcBufferWriteInteger( gDivisorBufferI, indexLineI, divisorCountI )
      ProcBufferWriteInteger( gResidualBufferI, indexLineI, residualI )
     ENDIF
     multipleI = multipleI + primeI
    ENDWHILE
   ENDIF
  ENDFOR
  GotoBufferId( gDivisorBufferI )
  lineCountI = NumLines()
  FOR indexLineI = 1 TO lineCountI
   currentNumberI = lowI + indexLineI - 1
   residualI = ProcBufferReadInteger( gResidualBufferI, indexLineI )
   divisorCountI = ProcBufferReadInteger( gDivisorBufferI, indexLineI )
   IF residualI > 1
    divisorCountI = divisorCountI * 2
   ENDIF
   IF currentNumberI >= 3
    IF divisorCountI == previousDivisorCountI
     answerI = answerI + 1
    ENDIF
   ENDIF
   previousDivisorCountI = divisorCountI
  ENDFOR
  GotoBufferId( gResidualBufferI )
  AbandonFile()
  GotoBufferId( gDivisorBufferI )
  AbandonFile()
  lowI = highI + 1
 ENDWHILE
 RETURN( answerI )
END

PROC Main()
 integer answerI = 0
 string answerS[255] = ""
 //
 ProcGeneratePrimeBuffer()
 answerI = ProcCountConsecutiveEqualDivisors()
 answerS = ProcIntegerToString( answerI )
 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
 GotoBufferId( gPrimeBufferI )
 AbandonFile()
END
