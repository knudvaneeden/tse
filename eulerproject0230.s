/*
  Euler Project 230
  Pure TSE SAL solution
  <version>2</version>

  History:
  1 - Created by ChatGPT GPT-5.4 Thinking
  2 - Corrected target index to ( 127 + 19*n ) * 7^n
*/

FORWARD STRING PROC ProcTrimLeadingZeros( STRING numberS )
FORWARD INTEGER PROC ProcCompareNumberStrings( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcAddNumberStrings( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcSubtractNumberStrings( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcMultiplyNumberStringBySmall( STRING numberS, INTEGER factorI )
FORWARD STRING PROC ProcReverseString( STRING textS )
FORWARD INTEGER PROC ProcCreateLengthsBuffer()
FORWARD PROC ProcAppendLength( INTEGER bufferIdI, STRING numberS )
FORWARD STRING PROC ProcGetBufferLine( INTEGER bufferIdI, INTEGER lineNumberI )
FORWARD INTEGER PROC ProcGetBufferLineCount( INTEGER bufferIdI )
FORWARD INTEGER PROC ProcFindContainingTermLine( INTEGER bufferIdI, STRING targetS )
FORWARD STRING PROC ProcGetDigitAt( INTEGER bufferIdI, STRING targetS, STRING aS, STRING bS )

STRING PROC ProcTrimLeadingZeros( STRING numberS )
  STRING workS[255] = ""
  INTEGER indexI = 1
  workS = numberS
  WHILE indexI < Length( workS ) AND SubStr( workS, indexI, 1 ) == "0"
    indexI = indexI + 1
  ENDWHILE
  Return( SubStr( workS, indexI, Length( workS ) - indexI + 1 ) )
END

INTEGER PROC ProcCompareNumberStrings( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  INTEGER indexI = 0
  leftWorkS = ProcTrimLeadingZeros( leftS )
  rightWorkS = ProcTrimLeadingZeros( rightS )
  IF Length( leftWorkS ) < Length( rightWorkS )
    Return( -1 )
  ENDIF
  IF Length( leftWorkS ) > Length( rightWorkS )
    Return( 1 )
  ENDIF
  FOR indexI = 1 TO Length( leftWorkS )
    IF SubStr( leftWorkS, indexI, 1 ) < SubStr( rightWorkS, indexI, 1 )
      Return( -1 )
    ENDIF
    IF SubStr( leftWorkS, indexI, 1 ) > SubStr( rightWorkS, indexI, 1 )
      Return( 1 )
    ENDIF
  ENDFOR
  Return( 0 )
END

STRING PROC ProcAddNumberStrings( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  STRING resultReversedS[255] = ""
  STRING digitLeftS[2] = ""
  STRING digitRightS[2] = ""
  INTEGER leftIndexI = 0
  INTEGER rightIndexI = 0
  INTEGER carryI = 0
  INTEGER digitSumI = 0
  INTEGER digitI = 0
  leftWorkS = ProcTrimLeadingZeros( leftS )
  rightWorkS = ProcTrimLeadingZeros( rightS )
  leftIndexI = Length( leftWorkS )
  rightIndexI = Length( rightWorkS )
  WHILE leftIndexI > 0 OR rightIndexI > 0 OR carryI > 0
    digitSumI = carryI
    IF leftIndexI > 0
      digitLeftS = SubStr( leftWorkS, leftIndexI, 1 )
      digitSumI = digitSumI + Asc( digitLeftS ) - Asc( "0" )
      leftIndexI = leftIndexI - 1
    ENDIF
    IF rightIndexI > 0
      digitRightS = SubStr( rightWorkS, rightIndexI, 1 )
      digitSumI = digitSumI + Asc( digitRightS ) - Asc( "0" )
      rightIndexI = rightIndexI - 1
    ENDIF
    digitI = digitSumI mod 10
    carryI = digitSumI / 10
    resultReversedS = resultReversedS + Chr( Asc( "0" ) + digitI )
  ENDWHILE
  Return( ProcReverseString( resultReversedS ) )
END

STRING PROC ProcSubtractNumberStrings( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ""
  STRING rightWorkS[255] = ""
  STRING resultReversedS[255] = ""
  INTEGER leftIndexI = 0
  INTEGER rightIndexI = 0
  INTEGER borrowI = 0
  INTEGER digitDiffI = 0
  leftWorkS = ProcTrimLeadingZeros( leftS )
  rightWorkS = ProcTrimLeadingZeros( rightS )
  leftIndexI = Length( leftWorkS )
  rightIndexI = Length( rightWorkS )
  WHILE leftIndexI > 0
    digitDiffI = Asc( SubStr( leftWorkS, leftIndexI, 1 ) ) - Asc( "0" ) - borrowI
    IF rightIndexI > 0
      digitDiffI = digitDiffI - ( Asc( SubStr( rightWorkS, rightIndexI, 1 ) ) - Asc( "0" ) )
      rightIndexI = rightIndexI - 1
    ENDIF
    IF digitDiffI < 0
      digitDiffI = digitDiffI + 10
      borrowI = 1
    ELSE
      borrowI = 0
    ENDIF
    resultReversedS = resultReversedS + Chr( Asc( "0" ) + digitDiffI )
    leftIndexI = leftIndexI - 1
  ENDWHILE
  Return( ProcTrimLeadingZeros( ProcReverseString( resultReversedS ) ) )
END

STRING PROC ProcMultiplyNumberStringBySmall( STRING numberS, INTEGER factorI )
  STRING workS[255] = ""
  STRING resultReversedS[255] = ""
  INTEGER indexI = 0
  INTEGER carryI = 0
  INTEGER digitI = 0
  INTEGER productI = 0
  workS = ProcTrimLeadingZeros( numberS )
  IF factorI == 0
    Return( "0" )
  ENDIF
  indexI = Length( workS )
  WHILE indexI > 0 OR carryI > 0
    productI = carryI
    IF indexI > 0
      digitI = Asc( SubStr( workS, indexI, 1 ) ) - Asc( "0" )
      productI = productI + digitI * factorI
      indexI = indexI - 1
    ENDIF
    resultReversedS = resultReversedS + Chr( Asc( "0" ) + ( productI mod 10 ) )
    carryI = productI / 10
  ENDWHILE
  Return( ProcTrimLeadingZeros( ProcReverseString( resultReversedS ) ) )
END

STRING PROC ProcReverseString( STRING textS )
  STRING resultS[255] = ""
  INTEGER indexI = 0
  FOR indexI = Length( textS ) DOWNTO 1
    resultS = resultS + SubStr( textS, indexI, 1 )
  ENDFOR
  Return( resultS )
END

INTEGER PROC ProcCreateLengthsBuffer()
  INTEGER bufferIdI = 0
  bufferIdI = CreateTempBuffer()
  Return( bufferIdI )
END

PROC ProcAppendLength( INTEGER bufferIdI, STRING numberS )
  AddLine( ProcTrimLeadingZeros( numberS ), bufferIdI )
END

STRING PROC ProcGetBufferLine( INTEGER bufferIdI, INTEGER lineNumberI )
  STRING lineS[255] = ""
  PushLocation()
  GotoBufferId( bufferIdI )
  GotoLine( lineNumberI )
  lineS = GetText( 1, 255 )
  PopLocation()
  Return( ProcTrimLeadingZeros( lineS ) )
END

INTEGER PROC ProcGetBufferLineCount( INTEGER bufferIdI )
  INTEGER countI = 0
  PushLocation()
  PushBlock()
  GotoBufferId( bufferIdI )
  countI = NumLines()
  PopBlock()
  PopLocation()
  Return( countI )
END

INTEGER PROC ProcFindContainingTermLine( INTEGER bufferIdI, STRING targetS )
  INTEGER lineCountI = 0
  INTEGER indexI = 0
  STRING currentS[255] = ""
  lineCountI = ProcGetBufferLineCount( bufferIdI )
  FOR indexI = 1 TO lineCountI
    currentS = ProcGetBufferLine( bufferIdI, indexI )
    IF ProcCompareNumberStrings( currentS, targetS ) >= 0
      Return( indexI )
    ENDIF
  ENDFOR
  Return( 0 )
END

STRING PROC ProcGetDigitAt( INTEGER bufferIdI, STRING targetS, STRING aS, STRING bS )
  STRING targetWorkS[255] = ""
  STRING previous2S[255] = ""
  INTEGER termLineI = 0
  INTEGER indexInBaseI = 0
  targetWorkS = ProcTrimLeadingZeros( targetS )
  termLineI = ProcFindContainingTermLine( bufferIdI, targetWorkS )
  WHILE termLineI > 2
    previous2S = ProcGetBufferLine( bufferIdI, termLineI - 2 )
    IF ProcCompareNumberStrings( targetWorkS, previous2S ) <= 0
      termLineI = termLineI - 2
    ELSE
      targetWorkS = ProcSubtractNumberStrings( targetWorkS, previous2S )
      termLineI = termLineI - 1
    ENDIF
  ENDWHILE
  indexInBaseI = Val( targetWorkS )
  IF termLineI == 1
    Return( SubStr( aS, indexInBaseI, 1 ) )
  ELSE
    Return( SubStr( bS, indexInBaseI, 1 ) )
  ENDIF
END

PROC Main()
  STRING versionS[32] = "2"
  STRING creatorS[64] = "ChatGPT GPT-5.4 Thinking"
  STRING aS[255] = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
  STRING bS[255] = "8214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196"
  STRING power7S[255] = "1"
  STRING targetS[255] = ""
  STRING digitS[2] = ""
  STRING answerS[255] = ""
  STRING finalOutputS[255] = ""
  STRING nextLengthS[255] = ""
  INTEGER lengthsBufferIdI = 0
  INTEGER indexI = 0
  INTEGER multiplierI = 0

  lengthsBufferIdI = ProcCreateLengthsBuffer()
  ProcAppendLength( lengthsBufferIdI, "100" )
  ProcAppendLength( lengthsBufferIdI, "100" )

  WHILE ProcCompareNumberStrings( ProcGetBufferLine( lengthsBufferIdI, ProcGetBufferLineCount( lengthsBufferIdI ) ), "104683731294243150" ) < 0
    nextLengthS = ProcAddNumberStrings(
      ProcGetBufferLine( lengthsBufferIdI, ProcGetBufferLineCount( lengthsBufferIdI ) ),
      ProcGetBufferLine( lengthsBufferIdI, ProcGetBufferLineCount( lengthsBufferIdI ) - 1 )
    )
    ProcAppendLength( lengthsBufferIdI, nextLengthS )
  ENDWHILE

  FOR indexI = 0 TO 17
    multiplierI = 127 + 19 * indexI
    targetS = ProcMultiplyNumberStringBySmall( power7S, multiplierI )
    digitS = ProcGetDigitAt( lengthsBufferIdI, targetS, aS, bS )
    answerS = digitS + answerS
    power7S = ProcMultiplyNumberStringBySmall( power7S, 7 )
  ENDFOR

  finalOutputS = answerS

  CopyToWinClip( finalOutputS )
  Warn( finalOutputS )
  CopyToWinClip( finalOutputS )

  AbandonFile( lengthsBufferIdI )
END
