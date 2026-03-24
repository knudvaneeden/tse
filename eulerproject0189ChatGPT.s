// Euler Project 189
// Tri-colouring a triangular grid
// Pure TSE SAL
// <version>1.5.0.0.0</version>
// History:
// 1.5.0.0.0  2026-03-24  Non-recursive iterative DP rewrite by ChatGPT GPT-5.4 Thinking
// 1.4.0.0.0  2026-03-24  Canonical upward-row DP rewrite by ChatGPT GPT-5.4 Thinking
// 1.3.0.0.0  2026-03-24  Corrected row-cache rewrite by ChatGPT GPT-5.4 Thinking
// 1.2.0.0.0  2026-03-24  Memory-lean rewrite by ChatGPT GPT-5.4 Thinking
// 1.1.0.0.0  2026-03-24  Updated by ChatGPT GPT-5.4 Thinking
// 1.0.0.0.0  2026-03-24  Created by ChatGPT GPT-5.4 Thinking
//
FORWARD INTEGER PROC FNPow3( INTEGER exponentI )
FORWARD STRING PROC FNBufferRead( INTEGER bufferI, INTEGER lineI )
FORWARD PROC FNBufferWrite( INTEGER bufferI, INTEGER lineI, STRING textS )
FORWARD STRING PROC FNBigAdd( STRING leftS, STRING rightS )
FORWARD STRING PROC FNBigMulSmall( STRING numberS, INTEGER factorI )
FORWARD PROC FNBigAddToBuffer( INTEGER bufferI, INTEGER lineI, STRING addS )
FORWARD STRING PROC FNTernaryPattern( INTEGER stateI, INTEGER lengthI )
FORWARD INTEGER PROC FNTransitionFactor( STRING upperS, STRING lowerS )
FORWARD STRING PROC FNSumBuffer( INTEGER bufferI, INTEGER maxLinesI )
INTEGER gHeightI = 8
INTEGER PROC FNPow3( INTEGER exponentI )
 CASE exponentI
  WHEN 0
   RETURN( 1 )
  WHEN 1
   RETURN( 3 )
  WHEN 2
   RETURN( 9 )
  WHEN 3
   RETURN( 27 )
  WHEN 4
   RETURN( 81 )
  WHEN 5
   RETURN( 243 )
  WHEN 6
   RETURN( 729 )
  WHEN 7
   RETURN( 2187 )
  WHEN 8
   RETURN( 6561 )
 ENDCASE
 RETURN( 0 )
END
STRING PROC FNBufferRead( INTEGER bufferI, INTEGER lineI )
 STRING textS[255] = ""
 GotoBufferId( bufferI )
 IF NumLines() >= lineI
  GotoLine( lineI )
  IF CurrLineLen() > 0
   textS = GetText( 1, CurrLineLen() )
  ENDIF
 ENDIF
 RETURN( textS )
END
PROC FNBufferWrite( INTEGER bufferI, INTEGER lineI, STRING textS )
 GotoBufferId( bufferI )
 WHILE NumLines() < lineI
  AddLine( "" )
 ENDWHILE
 GotoLine( lineI )
 BegLine()
 KillToEol()
 InsertText( textS, _DONT_PROMPT_ )
END
STRING PROC FNBigAdd( STRING leftS, STRING rightS )
 INTEGER leftIndexI = 0
 INTEGER rightIndexI = 0
 INTEGER carryI = 0
 INTEGER sumI = 0
 STRING digitS[2] = ""
 STRING resultS[255] = ""
 leftIndexI = Length( leftS )
 rightIndexI = Length( rightS )
 WHILE ( leftIndexI > 0 ) OR ( rightIndexI > 0 ) OR ( carryI > 0 )
  sumI = carryI
  IF leftIndexI > 0
   sumI = sumI + Val( SubStr( leftS, leftIndexI, 1 ) )
   leftIndexI = leftIndexI - 1
  ENDIF
  IF rightIndexI > 0
   sumI = sumI + Val( SubStr( rightS, rightIndexI, 1 ) )
   rightIndexI = rightIndexI - 1
  ENDIF
  digitS = Chr( 48 + ( sumI mod 10 ) )
  resultS = digitS + resultS
  carryI = sumI / 10
 ENDWHILE
 RETURN( resultS )
END
STRING PROC FNBigMulSmall( STRING numberS, INTEGER factorI )
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER carryI = 0
 INTEGER productI = 0
 STRING digitS[2] = ""
 STRING resultS[255] = ""
 IF factorI == 0
  RETURN( "0" )
 ENDIF
 IF factorI == 1
  RETURN( numberS )
 ENDIF
 FOR indexI = Length( numberS ) DOWNTO 1
  digitI = Val( SubStr( numberS, indexI, 1 ) )
  productI = digitI * factorI + carryI
  digitS = Chr( 48 + ( productI mod 10 ) )
  resultS = digitS + resultS
  carryI = productI / 10
 ENDFOR
 WHILE carryI > 0
  digitS = Chr( 48 + ( carryI mod 10 ) )
  resultS = digitS + resultS
  carryI = carryI / 10
 ENDWHILE
 RETURN( resultS )
END
PROC FNBigAddToBuffer( INTEGER bufferI, INTEGER lineI, STRING addS )
 STRING oldS[255] = ""
 STRING newS[255] = ""
 oldS = FNBufferRead( bufferI, lineI )
 IF oldS == ""
  FNBufferWrite( bufferI, lineI, addS )
 ELSE
  newS = FNBigAdd( oldS, addS )
  FNBufferWrite( bufferI, lineI, newS )
 ENDIF
END
STRING PROC FNTernaryPattern( INTEGER stateI, INTEGER lengthI )
 INTEGER divisorI = 0
 INTEGER digitI = 0
 INTEGER workingStateI = 0
 INTEGER indexI = 0
 STRING resultS[255] = ""
 workingStateI = stateI
 IF lengthI == 0
  RETURN( "" )
 ENDIF
 divisorI = FNPow3( lengthI - 1 )
 FOR indexI = 1 TO lengthI
  digitI = workingStateI / divisorI
  resultS = resultS + Chr( 48 + digitI )
  workingStateI = workingStateI mod divisorI
  IF divisorI > 1
   divisorI = divisorI / 3
  ENDIF
 ENDFOR
 RETURN( resultS )
END
INTEGER PROC FNTransitionFactor( STRING upperS, STRING lowerS )
 INTEGER indexI = 0
 INTEGER upperColorI = 0
 INTEGER leftLowerColorI = 0
 INTEGER rightLowerColorI = 0
 INTEGER factorI = 1
 INTEGER distinctCountI = 0
 FOR indexI = 1 TO Length( upperS )
  upperColorI = Val( SubStr( upperS, indexI, 1 ) )
  leftLowerColorI = Val( SubStr( lowerS, indexI, 1 ) )
  rightLowerColorI = Val( SubStr( lowerS, indexI + 1, 1 ) )
  distinctCountI = 1
  IF leftLowerColorI <> upperColorI
   distinctCountI = distinctCountI + 1
  ENDIF
  IF rightLowerColorI <> upperColorI
   IF rightLowerColorI <> leftLowerColorI
    distinctCountI = distinctCountI + 1
   ENDIF
  ENDIF
  IF distinctCountI == 3
   RETURN( 0 )
  ENDIF
  IF distinctCountI == 1
   factorI = factorI * 2
  ENDIF
 ENDFOR
 RETURN( factorI )
END
STRING PROC FNSumBuffer( INTEGER bufferI, INTEGER maxLinesI )
 INTEGER lineI = 0
 STRING totalS[255] = "0"
 STRING valueS[255] = ""
 FOR lineI = 1 TO maxLinesI
  valueS = FNBufferRead( bufferI, lineI )
  IF valueS <> ""
   totalS = FNBigAdd( totalS, valueS )
  ENDIF
 ENDFOR
 RETURN( totalS )
END
PROC Main()
 INTEGER currentBufferI = 0
 INTEGER nextBufferI = 0
 INTEGER patternUpperBufferI = 0
 INTEGER patternLowerBufferI = 0
 INTEGER rowI = 0
 INTEGER upperStateI = 0
 INTEGER lowerStateI = 0
 INTEGER upperCountI = 0
 INTEGER lowerCountI = 0
 INTEGER factorI = 0
 STRING countS[255] = ""
 STRING addS[255] = ""
 STRING upperPatternS[255] = ""
 STRING lowerPatternS[255] = ""
 STRING resultS[255] = ""
 currentBufferI = CreateTempBuffer()
 patternUpperBufferI = CreateTempBuffer()
 patternLowerBufferI = CreateTempBuffer()
 FNBufferWrite( currentBufferI, 1, "1" )
 FOR rowI = 0 TO ( gHeightI - 1 )
  nextBufferI = CreateTempBuffer()
  upperCountI = FNPow3( rowI )
  lowerCountI = FNPow3( rowI + 1 )
  GotoBufferId( patternUpperBufferI )
  EmptyBuffer()
  FOR upperStateI = 0 TO ( upperCountI - 1 )
   AddLine( FNTernaryPattern( upperStateI, rowI ) )
  ENDFOR
  GotoBufferId( patternLowerBufferI )
  EmptyBuffer()
  FOR lowerStateI = 0 TO ( lowerCountI - 1 )
   AddLine( FNTernaryPattern( lowerStateI, rowI + 1 ) )
  ENDFOR
  FOR upperStateI = 0 TO ( upperCountI - 1 )
   countS = FNBufferRead( currentBufferI, upperStateI + 1 )
   IF countS <> ""
    upperPatternS = FNBufferRead( patternUpperBufferI, upperStateI + 1 )
    FOR lowerStateI = 0 TO ( lowerCountI - 1 )
     lowerPatternS = FNBufferRead( patternLowerBufferI, lowerStateI + 1 )
     factorI = FNTransitionFactor( upperPatternS, lowerPatternS )
     IF factorI > 0
      addS = FNBigMulSmall( countS, factorI )
      FNBigAddToBuffer( nextBufferI, lowerStateI + 1, addS )
     ENDIF
    ENDFOR
   ENDIF
  ENDFOR
  AbandonFile( currentBufferI )
  currentBufferI = nextBufferI
 ENDFOR
 resultS = FNSumBuffer( currentBufferI, FNPow3( gHeightI ) )
 CopyToWinClip( resultS )
 Warn( resultS )
 CopyToWinClip( resultS )
 AbandonFile( currentBufferI )
 AbandonFile( patternUpperBufferI )
 AbandonFile( patternLowerBufferI )
END
