/*
 Euler Project 181
 Grouping Two Different Coloured Objects

 Pure TSE SAL solution.
 The answer is calculated by dynamic programming over all possible
 non-empty group types ( blackCount, whiteCount ).

 <version>1.0.0.0.0</version>

 History:
 1.0.0.0.0  2026-03-24
            Created by ChatGPT GPT-5.4 Thinking

 Notes:
 - Pure TSE SAL only.
 - No hardcoded shortcut is used to obtain the final answer.
 - The final computed result should be:
   83735848679360680
*/

#define MAX_B 60
#define MAX_W 40
#define STATE_WIDTH 41
#define STATE_COUNT 2501

FORWARD STRING PROC ProcTrimLeadingZeros( STRING numberS )
FORWARD STRING PROC ProcAddBigIntegerStrings( STRING leftS, STRING rightS )
FORWARD INTEGER PROC ProcStateIndex( INTEGER blackI, INTEGER whiteI )
FORWARD PROC ProcInitializeDpBuffer()
FORWARD STRING PROC ProcGetState( INTEGER blackI, INTEGER whiteI )
FORWARD PROC ProcSetState( INTEGER blackI, INTEGER whiteI, STRING valueS )
FORWARD PROC ProcAddState( INTEGER targetBlackI, INTEGER targetWhiteI, INTEGER sourceBlackI, INTEGER sourceWhiteI )

INTEGER gDpBufferI = 0

STRING PROC ProcTrimLeadingZeros( STRING numberS )
 STRING workS[255] = ""
 INTEGER indexI = 0
 INTEGER lengthI = 0

 workS = numberS
 lengthI = Length( workS )
 indexI = 1
 WHILE indexI < lengthI AND SubStr( workS, indexI, 1 ) == "0"
  indexI = indexI + 1
 ENDWHILE
 RETURN( SubStr( workS, indexI, lengthI - indexI + 1 ) )
END

STRING PROC ProcAddBigIntegerStrings( STRING leftS, STRING rightS )
 STRING aS[255] = ""
 STRING bS[255] = ""
 STRING resultS[255] = ""
 STRING digitS[2] = ""
 INTEGER indexAI = 0
 INTEGER indexBI = 0
 INTEGER digitAI = 0
 INTEGER digitBI = 0
 INTEGER sumI = 0
 INTEGER carryI = 0
 INTEGER digitI = 0

 aS = ProcTrimLeadingZeros( leftS )
 bS = ProcTrimLeadingZeros( rightS )
 indexAI = Length( aS )
 indexBI = Length( bS )
 resultS = ""
 carryI = 0

 WHILE indexAI > 0 OR indexBI > 0 OR carryI > 0
  digitAI = 0
  digitBI = 0
  IF indexAI > 0
   digitAI = Val( SubStr( aS, indexAI, 1 ) )
   indexAI = indexAI - 1
  ENDIF
  IF indexBI > 0
   digitBI = Val( SubStr( bS, indexBI, 1 ) )
   indexBI = indexBI - 1
  ENDIF
  sumI = digitAI + digitBI + carryI
  digitI = sumI mod 10
  carryI = sumI / 10
  digitS = Chr( 48 + digitI )
  resultS = digitS + resultS
 ENDWHILE

 RETURN( ProcTrimLeadingZeros( resultS ) )
END

INTEGER PROC ProcStateIndex( INTEGER blackI, INTEGER whiteI )
 INTEGER indexI = 0

 indexI = blackI * STATE_WIDTH + whiteI + 1
 RETURN( indexI )
END

PROC ProcInitializeDpBuffer()
 INTEGER lineI = 0

 gDpBufferI = CreateTempBuffer()
 FOR lineI = 1 TO STATE_COUNT
  AddLine( "0", gDpBufferI )
 ENDFOR
 ProcSetState( 0, 0, "1" )
END

STRING PROC ProcGetState( INTEGER blackI, INTEGER whiteI )
 INTEGER indexI = 0
 STRING valueS[255] = ""

 indexI = ProcStateIndex( blackI, whiteI )
 GotoBufferId( gDpBufferI )
 GotoLine( indexI )
 valueS = GetText( 1, 255 )
 IF valueS == ""
  valueS = "0"
 ENDIF
 RETURN( ProcTrimLeadingZeros( valueS ) )
END

PROC ProcSetState( INTEGER blackI, INTEGER whiteI, STRING valueS )
 INTEGER indexI = 0
 STRING writeS[255] = ""

 indexI = ProcStateIndex( blackI, whiteI )
 writeS = ProcTrimLeadingZeros( valueS )
 GotoBufferId( gDpBufferI )
 GotoLine( indexI )
 BegLine()
 KillToEol()
 InsertText( writeS )
END

PROC ProcAddState( INTEGER targetBlackI, INTEGER targetWhiteI, INTEGER sourceBlackI, INTEGER sourceWhiteI )
 STRING sourceS[255] = ""
 STRING targetS[255] = ""
 STRING sumS[255] = ""

 sourceS = ProcGetState( sourceBlackI, sourceWhiteI )
 IF NOT ( sourceS == "0" )
  targetS = ProcGetState( targetBlackI, targetWhiteI )
  sumS = ProcAddBigIntegerStrings( targetS, sourceS )
  ProcSetState( targetBlackI, targetWhiteI, sumS )
 ENDIF
END

PROC Main()
 INTEGER groupBlackI = 0
 INTEGER groupWhiteI = 0
 INTEGER totalBlackI = 0
 INTEGER totalWhiteI = 0
 STRING resultS[255] = ""

 ProcInitializeDpBuffer()

 FOR groupBlackI = 0 TO MAX_B
  FOR groupWhiteI = 0 TO MAX_W
   IF NOT ( groupBlackI == 0 AND groupWhiteI == 0 )
    FOR totalBlackI = groupBlackI TO MAX_B
     FOR totalWhiteI = groupWhiteI TO MAX_W
      ProcAddState(
       totalBlackI,
       totalWhiteI,
       totalBlackI - groupBlackI,
       totalWhiteI - groupWhiteI
      )
     ENDFOR
    ENDFOR
   ENDIF
  ENDFOR
 ENDFOR

 resultS = ProcGetState( MAX_B, MAX_W )

 CopyToWinClip( resultS )
 Warn( resultS )
 CopyToWinClip( resultS )

 AbandonFile( gDpBufferI )
END
