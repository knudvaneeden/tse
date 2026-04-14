// Euler Project problem 277
// Version: 1
// LLM history: ChatGPT

STRING PROC ProcTrimLeadingZeros( STRING numberS )
  STRING workS[255] = ''
  workS = numberS
  WHILE Length( workS ) > 1 AND SubStr( workS, 1, 1 ) == '0'
    workS = SubStr( workS, 2, Length( workS ) - 1 )
  ENDWHILE
  RETURN( workS )
END

INTEGER PROC ProcBigCompare( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ''
  STRING rightWorkS[255] = ''
  INTEGER indexI = 0
  leftWorkS  = ProcTrimLeadingZeros( leftS )
  rightWorkS = ProcTrimLeadingZeros( rightS )
  IF Length( leftWorkS ) < Length( rightWorkS )
    RETURN( -1 )
  ENDIF
  IF Length( leftWorkS ) > Length( rightWorkS )
    RETURN( 1 )
  ENDIF
  FOR indexI = 1 TO Length( leftWorkS ) BY 1
    IF SubStr( leftWorkS, indexI, 1 ) < SubStr( rightWorkS, indexI, 1 )
      RETURN( -1 )
    ENDIF
    IF SubStr( leftWorkS, indexI, 1 ) > SubStr( rightWorkS, indexI, 1 )
      RETURN( 1 )
    ENDIF
  ENDFOR
  RETURN( 0 )
END

STRING PROC ProcBigAdd( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ''
  STRING rightWorkS[255] = ''
  STRING resultS[255] = ''
  INTEGER leftIndexI = 0
  INTEGER rightIndexI = 0
  INTEGER carryI = 0
  INTEGER leftDigitI = 0
  INTEGER rightDigitI = 0
  INTEGER sumI = 0
  leftWorkS  = ProcTrimLeadingZeros( leftS )
  rightWorkS = ProcTrimLeadingZeros( rightS )
  leftIndexI  = Length( leftWorkS )
  rightIndexI = Length( rightWorkS )
  WHILE leftIndexI > 0 OR rightIndexI > 0 OR carryI > 0
    leftDigitI = 0
    rightDigitI = 0
    IF leftIndexI > 0
      leftDigitI = Val( SubStr( leftWorkS, leftIndexI, 1 ) )
      leftIndexI = leftIndexI - 1
    ENDIF
    IF rightIndexI > 0
      rightDigitI = Val( SubStr( rightWorkS, rightIndexI, 1 ) )
      rightIndexI = rightIndexI - 1
    ENDIF
    sumI = leftDigitI + rightDigitI + carryI
    resultS = Format( sumI mod 10 ) + resultS
    carryI = sumI / 10
  ENDWHILE
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcBigSubtract( STRING leftS, STRING rightS )
  STRING leftWorkS[255] = ''
  STRING rightWorkS[255] = ''
  STRING resultS[255] = ''
  INTEGER leftIndexI = 0
  INTEGER rightIndexI = 0
  INTEGER borrowI = 0
  INTEGER leftDigitI = 0
  INTEGER rightDigitI = 0
  INTEGER diffI = 0
  leftWorkS  = ProcTrimLeadingZeros( leftS )
  rightWorkS = ProcTrimLeadingZeros( rightS )
  leftIndexI  = Length( leftWorkS )
  rightIndexI = Length( rightWorkS )
  WHILE leftIndexI > 0 OR rightIndexI > 0
    leftDigitI = 0
    rightDigitI = 0
    IF leftIndexI > 0
      leftDigitI = Val( SubStr( leftWorkS, leftIndexI, 1 ) )
      leftIndexI = leftIndexI - 1
    ENDIF
    IF rightIndexI > 0
      rightDigitI = Val( SubStr( rightWorkS, rightIndexI, 1 ) )
      rightIndexI = rightIndexI - 1
    ENDIF
    diffI = leftDigitI - borrowI - rightDigitI
    IF diffI < 0
      diffI = diffI + 10
      borrowI = 1
    ELSE
      borrowI = 0
    ENDIF
    resultS = Format( diffI ) + resultS
  ENDWHILE
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcBigMultiplySmall( STRING numberS, INTEGER factorI )
  STRING workS[255] = ''
  STRING resultS[255] = ''
  INTEGER indexI = 0
  INTEGER carryI = 0
  INTEGER digitI = 0
  INTEGER productI = 0
  workS = ProcTrimLeadingZeros( numberS )
  IF factorI == 0
    RETURN( '0' )
  ENDIF
  IF factorI == 1
    RETURN( workS )
  ENDIF
  indexI = Length( workS )
  WHILE indexI > 0
    digitI = Val( SubStr( workS, indexI, 1 ) )
    productI = digitI * factorI + carryI
    resultS = Format( productI mod 10 ) + resultS
    carryI = productI / 10
    indexI = indexI - 1
  ENDWHILE
  WHILE carryI > 0
    resultS = Format( carryI mod 10 ) + resultS
    carryI = carryI / 10
  ENDWHILE
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcBigDivideSmall( STRING numberS, INTEGER divisorI )
  STRING workS[255] = ''
  STRING quotientS[255] = ''
  INTEGER indexI = 0
  INTEGER remainderI = 0
  INTEGER currentI = 0
  INTEGER quotientDigitI = 0
  workS = ProcTrimLeadingZeros( numberS )
  FOR indexI = 1 TO Length( workS ) BY 1
    currentI = remainderI * 10 + Val( SubStr( workS, indexI, 1 ) )
    quotientDigitI = currentI / divisorI
    remainderI = currentI mod divisorI
    IF Length( quotientS ) > 0 OR quotientDigitI > 0 OR indexI == Length( workS )
      quotientS = quotientS + Format( quotientDigitI )
    ENDIF
  ENDFOR
  IF quotientS == ''
    quotientS = '0'
  ENDIF
  RETURN( ProcTrimLeadingZeros( quotientS ) )
END

INTEGER PROC ProcBigModuloSmall( STRING numberS, INTEGER divisorI )
  STRING workS[255] = ''
  INTEGER indexI = 0
  INTEGER remainderI = 0
  workS = ProcTrimLeadingZeros( numberS )
  FOR indexI = 1 TO Length( workS ) BY 1
    remainderI = ( remainderI * 10 + Val( SubStr( workS, indexI, 1 ) ) ) mod divisorI
  ENDFOR
  RETURN( remainderI )
END

STRING PROC ProcDetermineStep( STRING currentS )
  INTEGER remainderI = 0
  remainderI = ProcBigModuloSmall( currentS, 3 )
  IF remainderI == 0
    RETURN( 'D' )
  ENDIF
  IF remainderI == 1
    RETURN( 'U' )
  ENDIF
  RETURN( 'd' )
END

STRING PROC ProcApplyStep( STRING currentS, STRING stepS )
  STRING workS[255] = ''
  IF stepS == 'D'
    RETURN( ProcBigDivideSmall( currentS, 3 ) )
  ENDIF
  IF stepS == 'U'
    workS = ProcBigMultiplySmall( currentS, 4 )
    workS = ProcBigAdd( workS, '2' )
    RETURN( ProcBigDivideSmall( workS, 3 ) )
  ENDIF
  workS = ProcBigMultiplySmall( currentS, 2 )
  workS = ProcBigSubtract( workS, '1' )
  RETURN( ProcBigDivideSmall( workS, 3 ) )
END

INTEGER PROC ProcMatchesPrefix( STRING startS, STRING sequenceS, INTEGER prefixLengthI )
  STRING currentS[255] = ''
  STRING actualStepS[2] = ''
  INTEGER indexI = 0
  currentS = ProcTrimLeadingZeros( startS )
  FOR indexI = 1 TO prefixLengthI BY 1
    actualStepS = ProcDetermineStep( currentS )
    IF NOT( actualStepS == SubStr( sequenceS, indexI, 1 ) )
      RETURN( FALSE )
    ENDIF
    currentS = ProcApplyStep( currentS, actualStepS )
  ENDFOR
  RETURN( TRUE )
END

PROC Main()
  STRING sequenceS[255] = 'UDDDUdddDDUDDddDdDddDDUDDdUUDd'
  STRING residueS[255] = '0'
  STRING modulusS[255] = '1'
  STRING candidateS[255] = ''
  STRING answerS[255] = ''
  STRING thresholdS[255] = '1000000000000000'
  INTEGER prefixLengthI = 0
  INTEGER liftI = 0
  INTEGER foundB = FALSE
  FOR prefixLengthI = 1 TO Length( sequenceS ) BY 1
    foundB = FALSE
    FOR liftI = 0 TO 2 BY 1
      IF foundB == FALSE
        candidateS = ProcBigAdd( residueS, ProcBigMultiplySmall( modulusS, liftI ) )
        IF ProcMatchesPrefix( candidateS, sequenceS, prefixLengthI )
          residueS = candidateS
          foundB = TRUE
        ENDIF
      ENDIF
    ENDFOR
    modulusS = ProcBigMultiplySmall( modulusS, 3 )
  ENDFOR
  answerS = residueS
  WHILE ProcBigCompare( answerS, thresholdS ) <= 0
    answerS = ProcBigAdd( answerS, modulusS )
  ENDWHILE
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
