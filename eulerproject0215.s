/*
 Euler Project 215
 Crack-free Walls
 Pure TSE SAL
 <version>1.0.0.0.0</version>
 history:
 1.0.0.0.0 - GPT-5.4 Thinking - initial full pure SAL version
*/
#define WALL_WIDTH  32
#define WALL_HEIGHT 10
INTEGER gMaskBufferI          = 0
INTEGER gCompatibilityBufferI = 0
INTEGER PROC ProcMin( INTEGER leftI, INTEGER rightI )
 INTEGER answerI = 0
 IF leftI < rightI
  answerI = leftI
 ELSE
  answerI = rightI
 ENDIF
 RETURN( answerI )
END
STRING PROC ProcTrimLeadingZeros( STRING numberS )
 STRING workS[255] = ""
 INTEGER indexI = 1
 workS = numberS
 WHILE ( indexI < Length( workS ) ) AND ( SubStr( workS, indexI, 1 ) == "0" )
  indexI = indexI + 1
 ENDWHILE
 RETURN( SubStr( workS, indexI, Length( workS ) - indexI + 1 ) )
END
STRING PROC ProcIntToString( INTEGER numberI )
 STRING numberS[255] = ""
 numberS = Format( numberI : 0 )
 RETURN( numberS )
END
STRING PROC ProcGetBufferLine( INTEGER bufferI, INTEGER lineNumberI )
 STRING textS[255] = ""
 PushLocation()
 GotoBufferId( bufferI )
 IF ( lineNumberI >= 1 ) AND ( lineNumberI <= NumLines() )
  GotoLine( lineNumberI )
  textS = GetText( 1, 255 )
 ELSE
  textS = ""
 ENDIF
 PopLocation()
 RETURN( textS )
END
STRING PROC ProcAddBig( STRING leftNumberS, STRING rightNumberS )
 STRING leftWorkS[255]   = ""
 STRING rightWorkS[255]  = ""
 STRING answerS[255]     = ""
 STRING digitS[2]        = ""
 INTEGER leftIndexI      = 0
 INTEGER rightIndexI     = 0
 INTEGER leftDigitI      = 0
 INTEGER rightDigitI     = 0
 INTEGER sumDigitI       = 0
 INTEGER carryI          = 0
 leftWorkS  = ProcTrimLeadingZeros( leftNumberS )
 rightWorkS = ProcTrimLeadingZeros( rightNumberS )
 leftIndexI  = Length( leftWorkS )
 rightIndexI = Length( rightWorkS )
 WHILE ( leftIndexI > 0 ) OR ( rightIndexI > 0 ) OR ( carryI > 0 )
  leftDigitI = 0
  rightDigitI = 0
  IF leftIndexI > 0
   digitS = SubStr( leftWorkS, leftIndexI, 1 )
   leftDigitI = Val( digitS )
   leftIndexI = leftIndexI - 1
  ENDIF
  IF rightIndexI > 0
   digitS = SubStr( rightWorkS, rightIndexI, 1 )
   rightDigitI = Val( digitS )
   rightIndexI = rightIndexI - 1
  ENDIF
  sumDigitI = leftDigitI + rightDigitI + carryI
  answerS = Chr( ( sumDigitI mod 10 ) + 48 ) + answerS
  carryI = sumDigitI / 10
 ENDWHILE
 RETURN( ProcTrimLeadingZeros( answerS ) )
END
STRING PROC ProcAppendIndexList( STRING listS, INTEGER indexValueI )
 STRING answerS[255] = ""
 STRING indexS[255]  = ""
 indexS = ProcIntToString( indexValueI )
 IF listS == ""
  answerS = indexS
 ELSE
  answerS = listS + "," + indexS
 ENDIF
 RETURN( answerS )
END
STRING PROC ProcSumCompatibilityLine( STRING compatibilityS, INTEGER countBufferI )
 STRING workS[255]        = ""
 STRING tokenS[255]       = ""
 STRING countS[255]       = ""
 STRING answerS[255]      = ""
 STRING oneCharS[2]       = ""
 INTEGER indexI           = 0
 INTEGER referencedRowI   = 0
 workS = compatibilityS
 answerS = "0"
 tokenS = ""
 FOR indexI = 1 TO Length( workS )
  oneCharS = SubStr( workS, indexI, 1 )
  IF oneCharS == ","
   IF NOT( tokenS == "" )
    referencedRowI = Val( tokenS )
    countS = ProcGetBufferLine( countBufferI, referencedRowI )
    answerS = ProcAddBig( answerS, countS )
    tokenS = ""
   ENDIF
  ELSE
   tokenS = tokenS + oneCharS
  ENDIF
 ENDFOR
 IF NOT( tokenS == "" )
  referencedRowI = Val( tokenS )
  countS = ProcGetBufferLine( countBufferI, referencedRowI )
  answerS = ProcAddBig( answerS, countS )
 ENDIF
 RETURN( ProcTrimLeadingZeros( answerS ) )
END
PROC ProcGenerateMasks( INTEGER usedWidthI, INTEGER crackMaskI )
 INTEGER nextWidthI = 0
 INTEGER nextMaskI  = 0
 IF usedWidthI == WALL_WIDTH
  AddLine( ProcIntToString( crackMaskI ), gMaskBufferI )
 ELSE
  nextWidthI = usedWidthI + 2
  IF nextWidthI <= WALL_WIDTH
   nextMaskI = crackMaskI
   IF nextWidthI < WALL_WIDTH
    nextMaskI = nextMaskI | ( 1 shl ( nextWidthI - 1 ) )
   ENDIF
   ProcGenerateMasks( nextWidthI, nextMaskI )
  ENDIF
  nextWidthI = usedWidthI + 3
  IF nextWidthI <= WALL_WIDTH
   nextMaskI = crackMaskI
   IF nextWidthI < WALL_WIDTH
    nextMaskI = nextMaskI | ( 1 shl ( nextWidthI - 1 ) )
   ENDIF
   ProcGenerateMasks( nextWidthI, nextMaskI )
  ENDIF
 ENDIF
END
PROC ProcBuildCompatibility()
 INTEGER rowCountI     = 0
 INTEGER sourceRowI    = 0
 INTEGER targetRowI    = 0
 INTEGER sourceMaskI   = 0
 INTEGER targetMaskI   = 0
 STRING listS[255]     = ""
 PushLocation()
 GotoBufferId( gMaskBufferI )
 rowCountI = NumLines()
 FOR sourceRowI = 1 TO rowCountI
  GotoLine( sourceRowI )
  sourceMaskI = Val( GetText( 1, 255 ) )
  listS = ""
  FOR targetRowI = 1 TO rowCountI
   GotoLine( targetRowI )
   targetMaskI = Val( GetText( 1, 255 ) )
   IF ( sourceMaskI & targetMaskI ) == 0
    listS = ProcAppendIndexList( listS, targetRowI )
   ENDIF
  ENDFOR
  AddLine( listS, gCompatibilityBufferI )
 ENDFOR
 PopLocation()
END
STRING PROC ProcSolveWall()
 INTEGER rowCountI            = 0
 INTEGER currentCountBufferI  = 0
 INTEGER nextCountBufferI     = 0
 INTEGER layerI               = 0
 INTEGER rowI                 = 0
 STRING compatibilityS[255]   = ""
 STRING rowCountS[255]        = ""
 STRING totalS[255]           = ""
 currentCountBufferI = CreateTempBuffer()
 PushLocation()
 GotoBufferId( gMaskBufferI )
 rowCountI = NumLines()
 PopLocation()
 FOR rowI = 1 TO rowCountI
  AddLine( "1", currentCountBufferI )
 ENDFOR
 FOR layerI = 2 TO WALL_HEIGHT
  nextCountBufferI = CreateTempBuffer()
  FOR rowI = 1 TO rowCountI
   compatibilityS = ProcGetBufferLine( gCompatibilityBufferI, rowI )
   rowCountS = ProcSumCompatibilityLine( compatibilityS, currentCountBufferI )
   AddLine( rowCountS, nextCountBufferI )
  ENDFOR
  AbandonFile( currentCountBufferI )
  currentCountBufferI = nextCountBufferI
 ENDFOR
 totalS = "0"
 FOR rowI = 1 TO rowCountI
  rowCountS = ProcGetBufferLine( currentCountBufferI, rowI )
  totalS = ProcAddBig( totalS, rowCountS )
 ENDFOR
 AbandonFile( currentCountBufferI )
 RETURN( ProcTrimLeadingZeros( totalS ) )
END
PROC Main()
 STRING versionS[40] = "1.0.0.0.0"
 STRING llmNameS[40] = "GPT-5.4 Thinking"
 STRING answerS[255] = ""
 gMaskBufferI = CreateTempBuffer()
 gCompatibilityBufferI = CreateTempBuffer()
 ProcGenerateMasks( 0, 0 )
 ProcBuildCompatibility()
 answerS = ProcSolveWall()
 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
 AbandonFile( gCompatibilityBufferI )
 AbandonFile( gMaskBufferI )
END
