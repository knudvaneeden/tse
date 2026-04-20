/*
  Euler Project 297 - Zeckendorf Representation
  Pure TSE SAL solution
  <version>1</version>

  History:
  1 - 2026-04-20 - ChatGPT - Initial pure TSE SAL version for problem 297.
*/

FORWARD STRING  PROC FNTrimLeadingZerosS( STRING valueS )
FORWARD INTEGER PROC FNCompareBigI( STRING leftS, STRING rightS )
FORWARD STRING  PROC FNAddBigS( STRING leftS, STRING rightS )
FORWARD STRING  PROC FNSubBigS( STRING leftS, STRING rightS )
FORWARD PROC    PROCAppendBufferLine( INTEGER bufferI, STRING valueS )
FORWARD STRING  PROC FNGetBufferLineS( INTEGER bufferI, INTEGER lineI )
FORWARD INTEGER PROC FNFindLargestFibIndexI( STRING valueS )
FORWARD PROC    PROCBuildTables( STRING maxValueS )
FORWARD STRING  PROC FNSumZeckendorfToS( STRING valueS )

INTEGER gFibBufferGI = 0
INTEGER gSumBufferGI = 0
INTEGER gFibCountGI  = 0

STRING PROC FNTrimLeadingZerosS( STRING valueS )
  STRING workS[255] = ""
  STRING resultS[255] = ""
  INTEGER indexI = 1
  workS = valueS
  IF Length( workS ) == 0
    RETURN( "0" )
  ENDIF
  WHILE indexI < Length( workS ) AND workS[ indexI ] == "0"
    indexI = indexI + 1
  ENDWHILE
  resultS = SubStr( workS, indexI, Length( workS ) - indexI + 1 )
  IF Length( resultS ) == 0
    resultS = "0"
  ENDIF
  RETURN( resultS )
END

INTEGER PROC FNCompareBigI( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  INTEGER indexI = 0
  leftWorkS  = FNTrimLeadingZerosS( leftS )
  rightWorkS = FNTrimLeadingZerosS( rightS )
  IF Length( leftWorkS ) < Length( rightWorkS )
    RETURN( -1 )
  ENDIF
  IF Length( leftWorkS ) > Length( rightWorkS )
    RETURN( 1 )
  ENDIF
  FOR indexI = 1 TO Length( leftWorkS )
    IF leftWorkS[ indexI ] < rightWorkS[ indexI ]
      RETURN( -1 )
    ENDIF
    IF leftWorkS[ indexI ] > rightWorkS[ indexI ]
      RETURN( 1 )
    ENDIF
  ENDFOR
  RETURN( 0 )
END

STRING PROC FNAddBigS( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  STRING resultS[255] = ""
  STRING digitS[2] = ""
  INTEGER leftIndexI = 0
  INTEGER rightIndexI = 0
  INTEGER carryI = 0
  INTEGER sumI = 0
  INTEGER digitI = 0
  leftWorkS  = FNTrimLeadingZerosS( leftS )
  rightWorkS = FNTrimLeadingZerosS( rightS )
  leftIndexI  = Length( leftWorkS )
  rightIndexI = Length( rightWorkS )
  WHILE leftIndexI > 0 OR rightIndexI > 0 OR carryI > 0
    sumI = carryI
    IF leftIndexI > 0
      digitS = leftWorkS[ leftIndexI ]
      sumI = sumI + Val( digitS )
      leftIndexI = leftIndexI - 1
    ENDIF
    IF rightIndexI > 0
      digitS = rightWorkS[ rightIndexI ]
      sumI = sumI + Val( digitS )
      rightIndexI = rightIndexI - 1
    ENDIF
    digitI = sumI mod 10
    carryI = sumI / 10
    resultS = Chr( 48 + digitI ) + resultS
  ENDWHILE
  RETURN( FNTrimLeadingZerosS( resultS ) )
END

STRING PROC FNSubBigS( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  STRING resultS[255] = ""
  STRING digitS[2] = ""
  INTEGER leftIndexI = 0
  INTEGER rightIndexI = 0
  INTEGER borrowI = 0
  INTEGER digitI = 0
  leftWorkS  = FNTrimLeadingZerosS( leftS )
  rightWorkS = FNTrimLeadingZerosS( rightS )
  leftIndexI  = Length( leftWorkS )
  rightIndexI = Length( rightWorkS )
  WHILE leftIndexI > 0
    digitS = leftWorkS[ leftIndexI ]
    digitI = Val( digitS ) - borrowI
    IF rightIndexI > 0
      digitS = rightWorkS[ rightIndexI ]
      digitI = digitI - Val( digitS )
      rightIndexI = rightIndexI - 1
    ENDIF
    IF digitI < 0
      digitI = digitI + 10
      borrowI = 1
    ELSE
      borrowI = 0
    ENDIF
    resultS = Chr( 48 + digitI ) + resultS
    leftIndexI = leftIndexI - 1
  ENDWHILE
  RETURN( FNTrimLeadingZerosS( resultS ) )
END

PROC PROCAppendBufferLine( INTEGER bufferI, STRING valueS )
  PushLocation()
  GotoBufferId( bufferI )
  IF NumLines() == 0
    InsertLine( valueS )
  ELSE
    EndFile()
    AddLine( valueS )
  ENDIF
  PopLocation()
END

STRING PROC FNGetBufferLineS( INTEGER bufferI, INTEGER lineI )
  STRING lineS[255] = ""
  PushLocation()
  GotoBufferId( bufferI )
  GotoLine( lineI )
  IF CurrLineLen() > 0
    lineS = GetText( 1, CurrLineLen() )
  ELSE
    lineS = ""
  ENDIF
  PopLocation()
  RETURN( lineS )
END

INTEGER PROC FNFindLargestFibIndexI( STRING valueS )
  INTEGER indexI = 0
  STRING fibS[255] = ""
  FOR indexI = gFibCountGI DOWNTO 1
    fibS = FNGetBufferLineS( gFibBufferGI, indexI )
    IF FNCompareBigI( fibS, valueS ) <= 0
      RETURN( indexI )
    ENDIF
  ENDFOR
  RETURN( 1 )
END

PROC PROCBuildTables( STRING maxValueS )
  STRING fibCurrentS[255] = ""
  STRING fibPreviousS[255] = ""
  STRING nextFibS[255] = ""
  STRING sumCurrentS[255] = ""
  STRING sumPreviousS[255] = ""
  STRING nextSumS[255] = ""
  INTEGER doneB = FALSE
  gFibBufferGI = CreateTempBuffer()
  gSumBufferGI = CreateTempBuffer()
  EmptyBuffer( gFibBufferGI )
  EmptyBuffer( gSumBufferGI )
  gFibCountGI = 0
  PROCAppendBufferLine( gFibBufferGI, "1" )
  PROCAppendBufferLine( gSumBufferGI, "1" )
  gFibCountGI = 1
  PROCAppendBufferLine( gFibBufferGI, "2" )
  PROCAppendBufferLine( gSumBufferGI, "2" )
  gFibCountGI = 2
  WHILE doneB == FALSE
    fibCurrentS  = FNGetBufferLineS( gFibBufferGI, gFibCountGI )
    fibPreviousS = FNGetBufferLineS( gFibBufferGI, gFibCountGI - 1 )
    nextFibS = FNAddBigS( fibCurrentS, fibPreviousS )
    IF FNCompareBigI( nextFibS, maxValueS ) > 0
      doneB = TRUE
    ELSE
      sumCurrentS  = FNGetBufferLineS( gSumBufferGI, gFibCountGI )
      sumPreviousS = FNGetBufferLineS( gSumBufferGI, gFibCountGI - 1 )
      nextSumS = FNAddBigS( sumCurrentS, sumPreviousS )
      nextSumS = FNAddBigS( nextSumS, fibPreviousS )
      nextSumS = FNSubBigS( nextSumS, "1" )
      PROCAppendBufferLine( gFibBufferGI, nextFibS )
      PROCAppendBufferLine( gSumBufferGI, nextSumS )
      gFibCountGI = gFibCountGI + 1
    ENDIF
  ENDWHILE
END

STRING PROC FNSumZeckendorfToS( STRING valueS )
  STRING workS[255] = ""
  STRING fibS[255] = ""
  STRING reducedS[255] = ""
  STRING resultS[255] = ""
  INTEGER fibIndexI = 0
  workS = FNTrimLeadingZerosS( valueS )
  IF FNCompareBigI( workS, "0" ) == 0
    RETURN( "0" )
  ENDIF
  fibIndexI = FNFindLargestFibIndexI( workS )
  fibS = FNGetBufferLineS( gFibBufferGI, fibIndexI )
  reducedS = FNSubBigS( workS, fibS )
  resultS = FNGetBufferLineS( gSumBufferGI, fibIndexI )
  IF FNCompareBigI( reducedS, "0" ) == 0
    RETURN( resultS )
  ENDIF
  resultS = FNAddBigS( resultS, reducedS )
  resultS = FNAddBigS( resultS, FNSumZeckendorfToS( reducedS ) )
  RETURN( resultS )
END

PROC Main()
  STRING limitS[255] = "100000000000000000"
  STRING maxValueS[255] = ""
  STRING answerS[255] = ""
  maxValueS = FNSubBigS( limitS, "1" )
  PROCBuildTables( maxValueS )
  answerS = FNSumZeckendorfToS( maxValueS )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
