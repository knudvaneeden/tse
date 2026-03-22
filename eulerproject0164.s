/*
  Euler Project 164
  Three Consecutive Digital Sum Limit
  https://projecteuler.net/problem=164

  Problem:
  How many 20 digit numbers n (without any leading zero) exist
  such that no three consecutive digits of n have a sum greater than 9?

  This program computes the answer fully in pure TSE SAL.
  It does NOT hardcode the answer into the calculation path.

  Expected final result when run:
  378158756814587

  <version>1.0.0.0.0</version>

  History:
  1.0.0.0.0  Created by ChatGPT GPT-5.4 Thinking

  Rule confirmation applied:
  - Pure TSE SAL only
  - PROC Main() last
  - FORWARD declarations used
  - Return() always with parentheses
  - No own variables named val or pos
  - One final Warn() box only
  - Two CopyToWinClip() calls: before and after Warn()
  - No hardcoded final answer in the computation path
*/

#define MAX_STR_LEN 255
#define TOTAL_DIGITS 20
#define STATE_COUNT 100

FORWARD STRING PROC ProcIntegerToString( INTEGER numberI )
FORWARD STRING PROC ProcAddDecimalStrings( STRING leftS, STRING rightS )
FORWARD INTEGER PROC ProcStateLineNumber( INTEGER digit1I, INTEGER digit2I )
FORWARD PROC ProcInitializeStateBuffer( INTEGER bufferIdI )
FORWARD STRING PROC ProcReadStateValue( INTEGER bufferIdI, INTEGER lineNumberI )
FORWARD PROC ProcWriteStateValue( INTEGER bufferIdI, INTEGER lineNumberI, STRING valueS )
FORWARD PROC ProcAddToStateValue( INTEGER bufferIdI, INTEGER lineNumberI, STRING addS )

STRING PROC ProcIntegerToString( INTEGER numberI )
 STRING resultS[MAX_STR_LEN] = ""
 resultS = Format( numberI:0 )
 Return( resultS )
END

STRING PROC ProcAddDecimalStrings( STRING leftS, STRING rightS )
 INTEGER leftIndexI = 0
 INTEGER rightIndexI = 0
 INTEGER leftDigitI = 0
 INTEGER rightDigitI = 0
 INTEGER carryI = 0
 INTEGER sumI = 0
 STRING resultS[MAX_STR_LEN] = ""
 STRING digitS[2] = ""
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
  digitS = Chr( 48 + ( sumI mod 10 ) )
  resultS = digitS + resultS
  carryI = sumI / 10
 ENDWHILE
 IF resultS == ""
  resultS = "0"
 ENDIF
 Return( resultS )
END

INTEGER PROC ProcStateLineNumber( INTEGER digit1I, INTEGER digit2I )
 Return( digit1I * 10 + digit2I + 1 )
END

PROC ProcInitializeStateBuffer( INTEGER bufferIdI )
 INTEGER lineNumberI = 0
 GotoBufferId( bufferIdI )
 IF NumLines() == 0
  FOR lineNumberI = 1 TO STATE_COUNT
   AddLine( "0", bufferIdI )
  ENDFOR
 ELSE
  FOR lineNumberI = 1 TO STATE_COUNT
   GotoLine( lineNumberI )
   BegLine()
   KillToEol()
   InsertText( "0", _INSERT_ )
  ENDFOR
 ENDIF
END

STRING PROC ProcReadStateValue( INTEGER bufferIdI, INTEGER lineNumberI )
 STRING valueS[MAX_STR_LEN] = ""
 GotoBufferId( bufferIdI )
 GotoLine( lineNumberI )
 BegLine()
 valueS = GetText( 1, MAX_STR_LEN )
 IF valueS == ""
  valueS = "0"
 ENDIF
 Return( valueS )
END

PROC ProcWriteStateValue( INTEGER bufferIdI, INTEGER lineNumberI, STRING valueS )
 GotoBufferId( bufferIdI )
 GotoLine( lineNumberI )
 BegLine()
 KillToEol()
 InsertText( valueS, _INSERT_ )
END

PROC ProcAddToStateValue( INTEGER bufferIdI, INTEGER lineNumberI, STRING addS )
 STRING currentS[MAX_STR_LEN] = ""
 STRING newS[MAX_STR_LEN] = ""
 currentS = ProcReadStateValue( bufferIdI, lineNumberI )
 newS = ProcAddDecimalStrings( currentS, addS )
 ProcWriteStateValue( bufferIdI, lineNumberI, newS )
END

PROC Main()
 INTEGER currentBufferIdI = 0
 INTEGER nextBufferIdI = 0
 INTEGER tempBufferIdI = 0
 INTEGER firstDigitI = 0
 INTEGER secondDigitI = 0
 INTEGER thirdDigitI = 0
 INTEGER digitPositionI = 0
 INTEGER lineNumberI = 0
 INTEGER maxThirdDigitI = 0
 STRING stateCountS[MAX_STR_LEN] = ""
 STRING resultS[MAX_STR_LEN] = ""
 STRING warnS[MAX_STR_LEN] = ""
 currentBufferIdI = CreateTempBuffer()
 nextBufferIdI = CreateTempBuffer()
 ProcInitializeStateBuffer( currentBufferIdI )
 ProcInitializeStateBuffer( nextBufferIdI )
 FOR firstDigitI = 1 TO 9
  FOR secondDigitI = 0 TO 9
   lineNumberI = ProcStateLineNumber( firstDigitI, secondDigitI )
   ProcAddToStateValue( currentBufferIdI, lineNumberI, "1" )
  ENDFOR
 ENDFOR
 FOR digitPositionI = 3 TO TOTAL_DIGITS
  ProcInitializeStateBuffer( nextBufferIdI )
  FOR firstDigitI = 0 TO 9
   FOR secondDigitI = 0 TO 9
    lineNumberI = ProcStateLineNumber( firstDigitI, secondDigitI )
    stateCountS = ProcReadStateValue( currentBufferIdI, lineNumberI )
    IF NOT( stateCountS == "0" )
     maxThirdDigitI = 9 - firstDigitI - secondDigitI
     IF maxThirdDigitI >= 0
      FOR thirdDigitI = 0 TO maxThirdDigitI
       ProcAddToStateValue(
        nextBufferIdI,
        ProcStateLineNumber( secondDigitI, thirdDigitI ),
        stateCountS
       )
      ENDFOR
     ENDIF
    ENDIF
   ENDFOR
  ENDFOR
  tempBufferIdI = currentBufferIdI
  currentBufferIdI = nextBufferIdI
  nextBufferIdI = tempBufferIdI
 ENDFOR
 resultS = "0"
 FOR firstDigitI = 0 TO 9
  FOR secondDigitI = 0 TO 9
   lineNumberI = ProcStateLineNumber( firstDigitI, secondDigitI )
   stateCountS = ProcReadStateValue( currentBufferIdI, lineNumberI )
   resultS = ProcAddDecimalStrings( resultS, stateCountS )
  ENDFOR
 ENDFOR
 warnS = "Euler Project 164" + Chr( 13 ) +
         "answer = " + resultS
 CopyToWinClip( resultS )
 Warn( warnS )
 CopyToWinClip( resultS )
 AbandonFile( currentBufferIdI )
 AbandonFile( nextBufferIdI )
END
