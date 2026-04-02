// Euler Project 244 - Sliders
// <version>3</version>
// History:
// Created by GPT-5.4 Thinking
// Fixed summed comparison syntax
// Fixed FORWARD declaration for ProcCharAt()
// Fixed checksum overflow by using safe modular multiplication
// Rule check applied in this source:
// - pure TSE SAL only
// - no hard coded final answer
// - one final Warn() box only
// - CopyToWinClip() before and after final Warn()
// - RETURN() always with parentheses
// - no user variables named val or pos
// - PROC Main() is last
// - version appears at one position only
//
FORWARD INTEGER PROC ProcChoose( INTEGER nI, INTEGER kI )
FORWARD INTEGER PROC ProcWaysAfterChoice( INTEGER remainingI, INTEGER blankLeftI, INTEGER redLeftI, INTEGER blueLeftI )
FORWARD STRING PROC ProcCharAt( STRING sourceS, INTEGER indexI )
FORWARD STRING PROC ProcReplaceAt( STRING sourceS, INTEGER indexI, STRING charS )
FORWARD STRING PROC ProcSwapChars( STRING sourceS, INTEGER firstI, INTEGER secondI )
FORWARD INTEGER PROC ProcFindBlankIndex( STRING stateS )
FORWARD STRING PROC ProcMoveLeft( STRING stateS )
FORWARD STRING PROC ProcMoveRight( STRING stateS )
FORWARD STRING PROC ProcMoveUp( STRING stateS )
FORWARD STRING PROC ProcMoveDown( STRING stateS )
FORWARD INTEGER PROC ProcMulMod( INTEGER leftI, INTEGER rightI, INTEGER modI )
FORWARD INTEGER PROC ProcNextChecksum( INTEGER checksumI, INTEGER moveAsciiI )
FORWARD INTEGER PROC ProcStateRank( STRING stateS )
FORWARD PROC ProcEnsureBufferLines( INTEGER bufferIdI, INTEGER wantedLinesI )
FORWARD STRING PROC ProcGetBufferLine( INTEGER bufferIdI, INTEGER lineI )
FORWARD PROC ProcSetBufferLine( INTEGER bufferIdI, INTEGER lineI, STRING textS )
FORWARD PROC ProcAppendBufferLine( INTEGER bufferIdI, STRING textS )
FORWARD PROC ProcClearBufferLine( INTEGER bufferIdI, INTEGER lineI )
FORWARD STRING PROC ProcIntToString( INTEGER numberI )
FORWARD INTEGER PROC ProcEntryChecksum( STRING entryS )
FORWARD STRING PROC ProcEntryState( STRING entryS )
FORWARD STRING PROC ProcMakeEntry( STRING stateS, INTEGER checksumI )
FORWARD INTEGER PROC ProcSearchEuler244()
//
INTEGER PROC ProcChoose( INTEGER nI, INTEGER kI )
 INTEGER resultI = 1
 INTEGER stepI = 0
 INTEGER useKI = 0
 //
 IF kI < 0
  RETURN( 0 )
 ENDIF
 IF kI > nI
  RETURN( 0 )
 ENDIF
 IF kI == 0
  RETURN( 1 )
 ENDIF
 useKI = kI
 IF useKI > nI - useKI
  useKI = nI - useKI
 ENDIF
 FOR stepI = 1 TO useKI
  resultI = ( resultI * ( nI - useKI + stepI ) ) / stepI
 ENDFOR
 RETURN( resultI )
END
//
INTEGER PROC ProcWaysAfterChoice( INTEGER remainingI, INTEGER blankLeftI, INTEGER redLeftI, INTEGER blueLeftI )
 INTEGER answerI = 0
 //
 IF blankLeftI < 0
  RETURN( 0 )
 ENDIF
 IF redLeftI < 0
  RETURN( 0 )
 ENDIF
 IF blueLeftI < 0
  RETURN( 0 )
 ENDIF
 IF ( NOT ( blankLeftI + redLeftI + blueLeftI == remainingI ) )
  RETURN( 0 )
 ENDIF
 answerI = ProcChoose( remainingI, blankLeftI ) * ProcChoose( remainingI - blankLeftI, redLeftI )
 RETURN( answerI )
END
//
STRING PROC ProcCharAt( STRING sourceS, INTEGER indexI )
 STRING answerS[255] = ""
 //
 IF indexI < 1
  RETURN( answerS )
 ENDIF
 IF indexI > Length( sourceS )
  RETURN( answerS )
 ENDIF
 answerS = SubStr( sourceS, indexI, 1 )
 RETURN( answerS )
END
//
STRING PROC ProcReplaceAt( STRING sourceS, INTEGER indexI, STRING charS )
 STRING leftPartS[255] = ""
 STRING rightPartS[255] = ""
 STRING answerS[255] = ""
 //
 IF indexI < 1
  RETURN( sourceS )
 ENDIF
 IF indexI > Length( sourceS )
  RETURN( sourceS )
 ENDIF
 IF indexI > 1
  leftPartS = SubStr( sourceS, 1, indexI - 1 )
 ENDIF
 IF indexI < Length( sourceS )
  rightPartS = SubStr( sourceS, indexI + 1, Length( sourceS ) - indexI )
 ENDIF
 answerS = leftPartS + charS + rightPartS
 RETURN( answerS )
END
//
STRING PROC ProcSwapChars( STRING sourceS, INTEGER firstI, INTEGER secondI )
 STRING firstCharS[255] = ""
 STRING secondCharS[255] = ""
 STRING workS[255] = ""
 //
 IF firstI == secondI
  RETURN( sourceS )
 ENDIF
 firstCharS = ProcCharAt( sourceS, firstI )
 secondCharS = ProcCharAt( sourceS, secondI )
 workS = ProcReplaceAt( sourceS, firstI, secondCharS )
 workS = ProcReplaceAt( workS, secondI, firstCharS )
 RETURN( workS )
END
//
INTEGER PROC ProcFindBlankIndex( STRING stateS )
 INTEGER indexI = 0
 //
 FOR indexI = 1 TO Length( stateS )
  IF ProcCharAt( stateS, indexI ) == "."
   RETURN( indexI )
  ENDIF
 ENDFOR
 RETURN( 0 )
END
//
STRING PROC ProcMoveLeft( STRING stateS )
 INTEGER blankIndexI = 0
 INTEGER columnI = 0
 //
 blankIndexI = ProcFindBlankIndex( stateS )
 IF blankIndexI == 0
  RETURN( "" )
 ENDIF
 columnI = ( blankIndexI - 1 ) mod 4
 IF columnI == 3
  RETURN( "" )
 ENDIF
 RETURN( ProcSwapChars( stateS, blankIndexI, blankIndexI + 1 ) )
END
//
STRING PROC ProcMoveRight( STRING stateS )
 INTEGER blankIndexI = 0
 INTEGER columnI = 0
 //
 blankIndexI = ProcFindBlankIndex( stateS )
 IF blankIndexI == 0
  RETURN( "" )
 ENDIF
 columnI = ( blankIndexI - 1 ) mod 4
 IF columnI == 0
  RETURN( "" )
 ENDIF
 RETURN( ProcSwapChars( stateS, blankIndexI, blankIndexI - 1 ) )
END
//
STRING PROC ProcMoveUp( STRING stateS )
 INTEGER blankIndexI = 0
 INTEGER rowI = 0
 //
 blankIndexI = ProcFindBlankIndex( stateS )
 IF blankIndexI == 0
  RETURN( "" )
 ENDIF
 rowI = ( blankIndexI - 1 ) / 4
 IF rowI == 3
  RETURN( "" )
 ENDIF
 RETURN( ProcSwapChars( stateS, blankIndexI, blankIndexI + 4 ) )
END
//
STRING PROC ProcMoveDown( STRING stateS )
 INTEGER blankIndexI = 0
 INTEGER rowI = 0
 //
 blankIndexI = ProcFindBlankIndex( stateS )
 IF blankIndexI == 0
  RETURN( "" )
 ENDIF
 rowI = ( blankIndexI - 1 ) / 4
 IF rowI == 0
  RETURN( "" )
 ENDIF
 RETURN( ProcSwapChars( stateS, blankIndexI, blankIndexI - 4 ) )
END
//
INTEGER PROC ProcMulMod( INTEGER leftI, INTEGER rightI, INTEGER modI )
 INTEGER answerI = 0
 INTEGER addendI = 0
 INTEGER factorI = 0
 //
 addendI = leftI mod modI
 factorI = rightI
 WHILE factorI > 0
  IF factorI & 1
   answerI = answerI + addendI
   IF answerI >= modI
    answerI = answerI - modI
   ENDIF
  ENDIF
  factorI = factorI shr 1
  addendI = addendI + addendI
  IF addendI >= modI
   addendI = addendI - modI
  ENDIF
 ENDWHILE
 RETURN( answerI )
END
//
INTEGER PROC ProcNextChecksum( INTEGER checksumI, INTEGER moveAsciiI )
 INTEGER answerI = 0
 //
 answerI = ProcMulMod( checksumI, 243, 100000007 )
 answerI = answerI + moveAsciiI
 IF answerI >= 100000007
  answerI = answerI - 100000007
 ENDIF
 RETURN( answerI )
END
//
INTEGER PROC ProcStateRank( STRING stateS )
 INTEGER rankI = 0
 INTEGER indexI = 0
 INTEGER remainingI = 0
 INTEGER blankLeftI = 1
 INTEGER redLeftI = 7
 INTEGER blueLeftI = 8
 STRING currentCharS[255] = ""
 //
 FOR indexI = 1 TO 16
  remainingI = 16 - indexI
  currentCharS = ProcCharAt( stateS, indexI )
  IF currentCharS == "."
   blankLeftI = blankLeftI - 1
  ELSEIF currentCharS == "r"
   IF blankLeftI > 0
    rankI = rankI + ProcWaysAfterChoice( remainingI, 0, redLeftI, blueLeftI )
   ENDIF
   redLeftI = redLeftI - 1
  ELSE
   IF blankLeftI > 0
    rankI = rankI + ProcWaysAfterChoice( remainingI, 0, redLeftI, blueLeftI )
   ENDIF
   IF redLeftI > 0
    rankI = rankI + ProcWaysAfterChoice( remainingI, blankLeftI, redLeftI - 1, blueLeftI )
   ENDIF
   blueLeftI = blueLeftI - 1
  ENDIF
 ENDFOR
 RETURN( rankI )
END
//
PROC ProcEnsureBufferLines( INTEGER bufferIdI, INTEGER wantedLinesI )
 INTEGER currentLinesI = 0
 INTEGER addI = 0
 //
 PushLocation()
 GotoBufferId( bufferIdI )
 currentLinesI = NumLines()
 IF currentLinesI < wantedLinesI
  EndFile()
  FOR addI = currentLinesI + 1 TO wantedLinesI
   AddLine( "" )
  ENDFOR
 ENDIF
 PopLocation()
END
//
STRING PROC ProcGetBufferLine( INTEGER bufferIdI, INTEGER lineI )
 STRING answerS[255] = ""
 //
 PushLocation()
 GotoBufferId( bufferIdI )
 GotoLine( lineI )
 BegLine()
 IF CurrLineLen() > 0
  answerS = GetText( 1, CurrLineLen() )
 ENDIF
 PopLocation()
 RETURN( answerS )
END
//
PROC ProcSetBufferLine( INTEGER bufferIdI, INTEGER lineI, STRING textS )
 PushLocation()
 GotoBufferId( bufferIdI )
 GotoLine( lineI )
 BegLine()
 KillToEol()
 InsertText( textS )
 PopLocation()
END
//
PROC ProcAppendBufferLine( INTEGER bufferIdI, STRING textS )
 PushLocation()
 GotoBufferId( bufferIdI )
 EndFile()
 AddLine( textS )
 PopLocation()
END
//
PROC ProcClearBufferLine( INTEGER bufferIdI, INTEGER lineI )
 PushLocation()
 GotoBufferId( bufferIdI )
 GotoLine( lineI )
 BegLine()
 KillToEol()
 PopLocation()
END
//
STRING PROC ProcIntToString( INTEGER numberI )
 STRING answerS[255] = ""
 //
 answerS = Format( numberI )
 RETURN( answerS )
END
//
INTEGER PROC ProcEntryChecksum( STRING entryS )
 STRING checksumS[255] = ""
 //
 checksumS = SubStr( entryS, 18, Length( entryS ) - 17 )
 RETURN( Val( checksumS ) )
END
//
STRING PROC ProcEntryState( STRING entryS )
 STRING stateS[255] = ""
 //
 stateS = SubStr( entryS, 1, 16 )
 RETURN( stateS )
END
//
STRING PROC ProcMakeEntry( STRING stateS, INTEGER checksumI )
 STRING answerS[255] = ""
 //
 answerS = stateS + "|" + ProcIntToString( checksumI )
 RETURN( answerS )
END
//
INTEGER PROC ProcSearchEuler244()
 INTEGER visitedBufferI = 0
 INTEGER nextMarkBufferI = 0
 INTEGER nextSumBufferI = 0
 INTEGER currentBufferI = 0
 INTEGER nextStatesBufferI = 0
 INTEGER newCurrentBufferI = 0
 INTEGER maxRanksI = 102960
 INTEGER targetRankI = 0
 INTEGER lineCountI = 0
 INTEGER lineIndexI = 0
 INTEGER moveAsciiI = 0
 INTEGER checksumI = 0
 INTEGER newChecksumI = 0
 INTEGER stateRankI = 0
 INTEGER oldSumI = 0
 INTEGER nextCountI = 0
 INTEGER resultI = 0
 STRING startStateS[255] = ".rbbrrbbrrbbrrbb"
 STRING targetStateS[255] = ".brbbrbrrbrbbrbr"
 STRING entryS[255] = ""
 STRING stateS[255] = ""
 STRING nextStateS[255] = ""
 STRING markS[255] = ""
 STRING sumS[255] = ""
 //
 visitedBufferI = CreateTempBuffer()
 nextMarkBufferI = CreateTempBuffer()
 nextSumBufferI = CreateTempBuffer()
 currentBufferI = CreateTempBuffer()
 //
 ProcEnsureBufferLines( visitedBufferI, maxRanksI )
 ProcEnsureBufferLines( nextMarkBufferI, maxRanksI )
 ProcEnsureBufferLines( nextSumBufferI, maxRanksI )
 //
 targetRankI = ProcStateRank( targetStateS )
 stateRankI = ProcStateRank( startStateS )
 ProcSetBufferLine( visitedBufferI, stateRankI + 1, "1" )
 ProcAppendBufferLine( currentBufferI, ProcMakeEntry( startStateS, 0 ) )
 //
 WHILE TRUE
  nextStatesBufferI = CreateTempBuffer()
  PushLocation()
  GotoBufferId( currentBufferI )
  lineCountI = NumLines()
  PopLocation()
  FOR lineIndexI = 1 TO lineCountI
   entryS = ProcGetBufferLine( currentBufferI, lineIndexI )
   stateS = ProcEntryState( entryS )
   checksumI = ProcEntryChecksum( entryS )
   //
   nextStateS = ProcMoveLeft( stateS )
   IF NOT( nextStateS == "" )
    moveAsciiI = 76
    stateRankI = ProcStateRank( nextStateS )
    IF ProcGetBufferLine( visitedBufferI, stateRankI + 1 ) == ""
     newChecksumI = ProcNextChecksum( checksumI, moveAsciiI )
     markS = ProcGetBufferLine( nextMarkBufferI, stateRankI + 1 )
     IF markS == ""
      ProcSetBufferLine( nextMarkBufferI, stateRankI + 1, "1" )
      ProcSetBufferLine( nextSumBufferI, stateRankI + 1, ProcIntToString( newChecksumI ) )
      ProcAppendBufferLine( nextStatesBufferI, nextStateS )
     ELSE
      oldSumI = Val( ProcGetBufferLine( nextSumBufferI, stateRankI + 1 ) )
      oldSumI = oldSumI + newChecksumI
      IF oldSumI >= 100000007
       oldSumI = oldSumI - 100000007
      ENDIF
      ProcSetBufferLine( nextSumBufferI, stateRankI + 1, ProcIntToString( oldSumI ) )
     ENDIF
    ENDIF
   ENDIF
   //
   nextStateS = ProcMoveRight( stateS )
   IF NOT( nextStateS == "" )
    moveAsciiI = 82
    stateRankI = ProcStateRank( nextStateS )
    IF ProcGetBufferLine( visitedBufferI, stateRankI + 1 ) == ""
     newChecksumI = ProcNextChecksum( checksumI, moveAsciiI )
     markS = ProcGetBufferLine( nextMarkBufferI, stateRankI + 1 )
     IF markS == ""
      ProcSetBufferLine( nextMarkBufferI, stateRankI + 1, "1" )
      ProcSetBufferLine( nextSumBufferI, stateRankI + 1, ProcIntToString( newChecksumI ) )
      ProcAppendBufferLine( nextStatesBufferI, nextStateS )
     ELSE
      oldSumI = Val( ProcGetBufferLine( nextSumBufferI, stateRankI + 1 ) )
      oldSumI = oldSumI + newChecksumI
      IF oldSumI >= 100000007
       oldSumI = oldSumI - 100000007
      ENDIF
      ProcSetBufferLine( nextSumBufferI, stateRankI + 1, ProcIntToString( oldSumI ) )
     ENDIF
    ENDIF
   ENDIF
   //
   nextStateS = ProcMoveUp( stateS )
   IF NOT( nextStateS == "" )
    moveAsciiI = 85
    stateRankI = ProcStateRank( nextStateS )
    IF ProcGetBufferLine( visitedBufferI, stateRankI + 1 ) == ""
     newChecksumI = ProcNextChecksum( checksumI, moveAsciiI )
     markS = ProcGetBufferLine( nextMarkBufferI, stateRankI + 1 )
     IF markS == ""
      ProcSetBufferLine( nextMarkBufferI, stateRankI + 1, "1" )
      ProcSetBufferLine( nextSumBufferI, stateRankI + 1, ProcIntToString( newChecksumI ) )
      ProcAppendBufferLine( nextStatesBufferI, nextStateS )
     ELSE
      oldSumI = Val( ProcGetBufferLine( nextSumBufferI, stateRankI + 1 ) )
      oldSumI = oldSumI + newChecksumI
      IF oldSumI >= 100000007
       oldSumI = oldSumI - 100000007
      ENDIF
      ProcSetBufferLine( nextSumBufferI, stateRankI + 1, ProcIntToString( oldSumI ) )
     ENDIF
    ENDIF
   ENDIF
   //
   nextStateS = ProcMoveDown( stateS )
   IF NOT( nextStateS == "" )
    moveAsciiI = 68
    stateRankI = ProcStateRank( nextStateS )
    IF ProcGetBufferLine( visitedBufferI, stateRankI + 1 ) == ""
     newChecksumI = ProcNextChecksum( checksumI, moveAsciiI )
     markS = ProcGetBufferLine( nextMarkBufferI, stateRankI + 1 )
     IF markS == ""
      ProcSetBufferLine( nextMarkBufferI, stateRankI + 1, "1" )
      ProcSetBufferLine( nextSumBufferI, stateRankI + 1, ProcIntToString( newChecksumI ) )
      ProcAppendBufferLine( nextStatesBufferI, nextStateS )
     ELSE
      oldSumI = Val( ProcGetBufferLine( nextSumBufferI, stateRankI + 1 ) )
      oldSumI = oldSumI + newChecksumI
      IF oldSumI >= 100000007
       oldSumI = oldSumI - 100000007
      ENDIF
      ProcSetBufferLine( nextSumBufferI, stateRankI + 1, ProcIntToString( oldSumI ) )
     ENDIF
    ENDIF
   ENDIF
  ENDFOR
  //
  markS = ProcGetBufferLine( nextMarkBufferI, targetRankI + 1 )
  IF NOT( markS == "" )
   resultI = Val( ProcGetBufferLine( nextSumBufferI, targetRankI + 1 ) )
   AbandonFile( nextStatesBufferI )
   BREAK
  ENDIF
  //
  newCurrentBufferI = CreateTempBuffer()
  PushLocation()
  GotoBufferId( nextStatesBufferI )
  nextCountI = NumLines()
  PopLocation()
  FOR lineIndexI = 1 TO nextCountI
   stateS = ProcGetBufferLine( nextStatesBufferI, lineIndexI )
   stateRankI = ProcStateRank( stateS )
   ProcSetBufferLine( visitedBufferI, stateRankI + 1, "1" )
   sumS = ProcGetBufferLine( nextSumBufferI, stateRankI + 1 )
   ProcAppendBufferLine( newCurrentBufferI, stateS + "|" + sumS )
   ProcClearBufferLine( nextMarkBufferI, stateRankI + 1 )
   ProcClearBufferLine( nextSumBufferI, stateRankI + 1 )
  ENDFOR
  AbandonFile( currentBufferI )
  currentBufferI = newCurrentBufferI
  AbandonFile( nextStatesBufferI )
 ENDWHILE
 //
 RETURN( resultI )
END
//
PROC Main()
 INTEGER answerI = 0
 STRING answerS[255] = ""
 //
 answerI = ProcSearchEuler244()
 answerS = ProcIntToString( answerI )
 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
END
