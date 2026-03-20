/*
  Euler Project 144
  Pure TSE SAL
  <version>1.0.0.0.2</version>

  Expected answer: 354

  LLM: ChatGPT GPT-5.4 Thinking
*/

#define MAX_BIGLEN 255

STRING gDivisionRemainderS[ MAX_BIGLEN ] = "0"
STRING gLlmNameS[ 40 ] = "ChatGPT GPT-5.4 Thinking"

FORWARD STRING PROC ProcTrimLeadingZeros( STRING numberS )
FORWARD STRING PROC ProcNormalizeInteger( STRING numberS )
FORWARD STRING PROC ProcAbsInteger( STRING numberS )
FORWARD INTEGER PROC ProcIsNegative( STRING numberS )
FORWARD INTEGER PROC ProcIsZero( STRING numberS )
FORWARD INTEGER PROC ProcCompareAbs( STRING leftS, STRING rightS )
FORWARD INTEGER PROC ProcCompareIntegers( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcAddPositive( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcSubtractPositive( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcAddIntegers( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcNegateInteger( STRING numberS )
FORWARD STRING PROC ProcMultiplyPositiveByDigit( STRING leftS, INTEGER digitI )
FORWARD STRING PROC ProcMultiplyPositiveByTen( STRING leftS )
FORWARD STRING PROC ProcMultiplyPositive( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcMultiplyIntegers( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcAppendDigit( STRING leftS, STRING digitS )
FORWARD INTEGER PROC ProcFindQuotientDigit( STRING remainderS, STRING denominatorS )
FORWARD STRING PROC ProcDividePositive( STRING numeratorS, STRING denominatorS )
FORWARD STRING PROC ProcDivideSignedByPositiveRounded( STRING numeratorS, STRING denominatorS )
FORWARD STRING PROC ProcMulBySmallInteger( STRING numberS, INTEGER factorI )
FORWARD INTEGER PROC ProcAbsLessOrEqual( STRING leftS, STRING rightS )
FORWARD INTEGER PROC ProcIsPositive( STRING numberS )
FORWARD STRING PROC ProcFixedMultiply( STRING leftS, STRING rightS, STRING scaleS )
FORWARD STRING PROC ProcFixedDivideSignedByPositive( STRING numeratorS, STRING denominatorS, STRING scaleS )
FORWARD STRING PROC ProcReflectComponent(
  STRING vComponentS,
  STRING factorS,
  STRING nComponentS,
  STRING scaleS
)

STRING PROC ProcTrimLeadingZeros( STRING numberS )
  STRING workS[ MAX_BIGLEN ] = ""
  INTEGER indexI = 1
  workS = numberS
  IF Length( workS ) == 0
    Return( "0" )
  ENDIF
  WHILE indexI < Length( workS ) AND SubStr( workS, indexI, 1 ) == "0"
    indexI = indexI + 1
  ENDWHILE
  Return( SubStr( workS, indexI, Length( workS ) - indexI + 1 ) )
END

STRING PROC ProcNormalizeInteger( STRING numberS )
  STRING workS[ MAX_BIGLEN ] = ""
  STRING signS[ 2 ] = ""
  workS = numberS
  IF Length( workS ) == 0
    Return( "0" )
  ENDIF
  IF SubStr( workS, 1, 1 ) == "+"
    workS = SubStr( workS, 2, Length( workS ) - 1 )
  ENDIF
  IF Length( workS ) > 0 AND SubStr( workS, 1, 1 ) == "-"
    signS = "-"
    workS = SubStr( workS, 2, Length( workS ) - 1 )
  ENDIF
  IF Length( workS ) == 0
    Return( "0" )
  ENDIF
  workS = ProcTrimLeadingZeros( workS )
  IF workS == "0"
    Return( "0" )
  ENDIF
  Return( signS + workS )
END

STRING PROC ProcAbsInteger( STRING numberS )
  STRING workS[ MAX_BIGLEN ] = ""
  workS = ProcNormalizeInteger( numberS )
  IF SubStr( workS, 1, 1 ) == "-"
    Return( SubStr( workS, 2, Length( workS ) - 1 ) )
  ENDIF
  Return( workS )
END

INTEGER PROC ProcIsNegative( STRING numberS )
  STRING workS[ MAX_BIGLEN ] = ""
  workS = ProcNormalizeInteger( numberS )
  IF workS == "0"
    Return( FALSE )
  ENDIF
  Return( SubStr( workS, 1, 1 ) == "-" )
END

INTEGER PROC ProcIsZero( STRING numberS )
  Return( ProcNormalizeInteger( numberS ) == "0" )
END

INTEGER PROC ProcCompareAbs( STRING leftS, STRING rightS )
  STRING aS[ MAX_BIGLEN ] = ""
  STRING bS[ MAX_BIGLEN ] = ""
  INTEGER indexI = 0
  aS = ProcAbsInteger( leftS )
  bS = ProcAbsInteger( rightS )
  IF Length( aS ) < Length( bS )
    Return( -1 )
  ENDIF
  IF Length( aS ) > Length( bS )
    Return( 1 )
  ENDIF
  FOR indexI = 1 TO Length( aS )
    IF SubStr( aS, indexI, 1 ) < SubStr( bS, indexI, 1 )
      Return( -1 )
    ENDIF
    IF SubStr( aS, indexI, 1 ) > SubStr( bS, indexI, 1 )
      Return( 1 )
    ENDIF
  ENDFOR
  Return( 0 )
END

INTEGER PROC ProcCompareIntegers( STRING leftS, STRING rightS )
  STRING aS[ MAX_BIGLEN ] = ""
  STRING bS[ MAX_BIGLEN ] = ""
  aS = ProcNormalizeInteger( leftS )
  bS = ProcNormalizeInteger( rightS )
  IF ProcIsNegative( aS ) AND NOT ProcIsNegative( bS )
    Return( -1 )
  ENDIF
  IF NOT ProcIsNegative( aS ) AND ProcIsNegative( bS )
    Return( 1 )
  ENDIF
  IF ProcIsNegative( aS )
    Return( -ProcCompareAbs( aS, bS ) )
  ENDIF
  Return( ProcCompareAbs( aS, bS ) )
END

STRING PROC ProcAddPositive( STRING leftS, STRING rightS )
  STRING aS[ MAX_BIGLEN ] = ""
  STRING bS[ MAX_BIGLEN ] = ""
  STRING resultS[ MAX_BIGLEN ] = ""
  INTEGER leftIndexI = 0
  INTEGER rightIndexI = 0
  INTEGER carryI = 0
  INTEGER digitLeftI = 0
  INTEGER digitRightI = 0
  INTEGER sumI = 0
  aS = ProcTrimLeadingZeros( leftS )
  bS = ProcTrimLeadingZeros( rightS )
  leftIndexI = Length( aS )
  rightIndexI = Length( bS )
  WHILE leftIndexI > 0 OR rightIndexI > 0 OR carryI > 0
    digitLeftI = 0
    digitRightI = 0
    IF leftIndexI > 0
      digitLeftI = Val( SubStr( aS, leftIndexI, 1 ) )
    ENDIF
    IF rightIndexI > 0
      digitRightI = Val( SubStr( bS, rightIndexI, 1 ) )
    ENDIF
    sumI = digitLeftI + digitRightI + carryI
    resultS = Chr( 48 + ( sumI mod 10 ) ) + resultS
    carryI = sumI / 10
    leftIndexI = leftIndexI - 1
    rightIndexI = rightIndexI - 1
  ENDWHILE
  Return( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcSubtractPositive( STRING leftS, STRING rightS )
  STRING aS[ MAX_BIGLEN ] = ""
  STRING bS[ MAX_BIGLEN ] = ""
  STRING resultS[ MAX_BIGLEN ] = ""
  INTEGER leftIndexI = 0
  INTEGER rightIndexI = 0
  INTEGER borrowI = 0
  INTEGER digitLeftI = 0
  INTEGER digitRightI = 0
  INTEGER diffI = 0
  aS = ProcTrimLeadingZeros( leftS )
  bS = ProcTrimLeadingZeros( rightS )
  leftIndexI = Length( aS )
  rightIndexI = Length( bS )
  WHILE leftIndexI > 0
    digitLeftI = Val( SubStr( aS, leftIndexI, 1 ) ) - borrowI
    digitRightI = 0
    IF rightIndexI > 0
      digitRightI = Val( SubStr( bS, rightIndexI, 1 ) )
    ENDIF
    IF digitLeftI < digitRightI
      digitLeftI = digitLeftI + 10
      borrowI = 1
    ELSE
      borrowI = 0
    ENDIF
    diffI = digitLeftI - digitRightI
    resultS = Chr( 48 + diffI ) + resultS
    leftIndexI = leftIndexI - 1
    rightIndexI = rightIndexI - 1
  ENDWHILE
  Return( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcAddIntegers( STRING leftS, STRING rightS )
  STRING aS[ MAX_BIGLEN ] = ""
  STRING bS[ MAX_BIGLEN ] = ""
  STRING absAS[ MAX_BIGLEN ] = ""
  STRING absBS[ MAX_BIGLEN ] = ""
  aS = ProcNormalizeInteger( leftS )
  bS = ProcNormalizeInteger( rightS )
  absAS = ProcAbsInteger( aS )
  absBS = ProcAbsInteger( bS )
  IF ProcIsNegative( aS ) == ProcIsNegative( bS )
    IF ProcIsNegative( aS )
      Return( ProcNormalizeInteger( "-" + ProcAddPositive( absAS, absBS ) ) )
    ENDIF
    Return( ProcNormalizeInteger( ProcAddPositive( absAS, absBS ) ) )
  ENDIF
  IF ProcCompareAbs( absAS, absBS ) >= 0
    IF ProcIsNegative( aS )
      Return( ProcNormalizeInteger( "-" + ProcSubtractPositive( absAS, absBS ) ) )
    ENDIF
    Return( ProcNormalizeInteger( ProcSubtractPositive( absAS, absBS ) ) )
  ENDIF
  IF ProcIsNegative( bS )
    Return( ProcNormalizeInteger( "-" + ProcSubtractPositive( absBS, absAS ) ) )
  ENDIF
  Return( ProcNormalizeInteger( ProcSubtractPositive( absBS, absAS ) ) )
END

STRING PROC ProcNegateInteger( STRING numberS )
  STRING workS[ MAX_BIGLEN ] = ""
  workS = ProcNormalizeInteger( numberS )
  IF workS == "0"
    Return( "0" )
  ENDIF
  IF SubStr( workS, 1, 1 ) == "-"
    Return( SubStr( workS, 2, Length( workS ) - 1 ) )
  ENDIF
  Return( "-" + workS )
END

STRING PROC ProcMultiplyPositiveByDigit( STRING leftS, INTEGER digitI )
  STRING aS[ MAX_BIGLEN ] = ""
  STRING resultS[ MAX_BIGLEN ] = ""
  INTEGER indexI = 0
  INTEGER carryI = 0
  INTEGER productI = 0
  IF digitI == 0
    Return( "0" )
  ENDIF
  IF digitI == 1
    Return( ProcTrimLeadingZeros( leftS ) )
  ENDIF
  aS = ProcTrimLeadingZeros( leftS )
  FOR indexI = Length( aS ) DOWNTO 1
    productI = Val( SubStr( aS, indexI, 1 ) ) * digitI + carryI
    resultS = Chr( 48 + ( productI mod 10 ) ) + resultS
    carryI = productI / 10
  ENDFOR
  WHILE carryI > 0
    resultS = Chr( 48 + ( carryI mod 10 ) ) + resultS
    carryI = carryI / 10
  ENDWHILE
  Return( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcMultiplyPositiveByTen( STRING leftS )
  STRING aS[ MAX_BIGLEN ] = ""
  aS = ProcTrimLeadingZeros( leftS )
  IF aS == "0"
    Return( "0" )
  ENDIF
  Return( aS + "0" )
END

STRING PROC ProcMultiplyPositive( STRING leftS, STRING rightS )
  STRING aS[ MAX_BIGLEN ] = ""
  STRING bS[ MAX_BIGLEN ] = ""
  STRING resultS[ MAX_BIGLEN ] = "0"
  STRING partialS[ MAX_BIGLEN ] = ""
  INTEGER indexI = 0
  INTEGER digitI = 0
  INTEGER shiftCountI = 0
  INTEGER shiftI = 0
  aS = ProcTrimLeadingZeros( leftS )
  bS = ProcTrimLeadingZeros( rightS )
  IF aS == "0" OR bS == "0"
    Return( "0" )
  ENDIF
  FOR indexI = Length( bS ) DOWNTO 1
    digitI = Val( SubStr( bS, indexI, 1 ) )
    partialS = ProcMultiplyPositiveByDigit( aS, digitI )
    shiftCountI = Length( bS ) - indexI
    FOR shiftI = 1 TO shiftCountI
      partialS = ProcMultiplyPositiveByTen( partialS )
    ENDFOR
    resultS = ProcAddPositive( resultS, partialS )
  ENDFOR
  Return( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcMultiplyIntegers( STRING leftS, STRING rightS )
  STRING aS[ MAX_BIGLEN ] = ""
  STRING bS[ MAX_BIGLEN ] = ""
  STRING resultS[ MAX_BIGLEN ] = ""
  INTEGER negativeB = FALSE
  aS = ProcNormalizeInteger( leftS )
  bS = ProcNormalizeInteger( rightS )
  negativeB = NOT( ProcIsNegative( aS ) == ProcIsNegative( bS ) )
  resultS = ProcMultiplyPositive( ProcAbsInteger( aS ), ProcAbsInteger( bS ) )
  IF resultS == "0"
    Return( "0" )
  ENDIF
  IF negativeB
    Return( "-" + resultS )
  ENDIF
  Return( resultS )
END

STRING PROC ProcAppendDigit( STRING leftS, STRING digitS )
  STRING aS[ MAX_BIGLEN ] = ""
  aS = ProcTrimLeadingZeros( leftS )
  IF aS == "0"
    Return( ProcTrimLeadingZeros( digitS ) )
  ENDIF
  Return( aS + digitS )
END

INTEGER PROC ProcFindQuotientDigit( STRING remainderS, STRING denominatorS )
  INTEGER qDigitI = 0
  INTEGER bestI = 0
  STRING trialS[ MAX_BIGLEN ] = ""
  FOR qDigitI = 0 TO 9
    trialS = ProcMultiplyPositiveByDigit( denominatorS, qDigitI )
    IF ProcCompareAbs( trialS, remainderS ) <= 0
      bestI = qDigitI
    ELSE
      Return( bestI )
    ENDIF
  ENDFOR
  Return( bestI )
END

STRING PROC ProcDividePositive( STRING numeratorS, STRING denominatorS )
  STRING numS[ MAX_BIGLEN ] = ""
  STRING denS[ MAX_BIGLEN ] = ""
  STRING remainderS[ MAX_BIGLEN ] = "0"
  STRING quotientS[ MAX_BIGLEN ] = ""
  STRING digitS[ 2 ] = ""
  INTEGER indexI = 0
  INTEGER qDigitI = 0
  numS = ProcTrimLeadingZeros( numeratorS )
  denS = ProcTrimLeadingZeros( denominatorS )
  IF denS == "0"
    gDivisionRemainderS = "0"
    Return( "0" )
  ENDIF
  IF ProcCompareAbs( numS, denS ) < 0
    gDivisionRemainderS = numS
    Return( "0" )
  ENDIF
  FOR indexI = 1 TO Length( numS )
    digitS = SubStr( numS, indexI, 1 )
    remainderS = ProcAppendDigit( remainderS, digitS )
    qDigitI = ProcFindQuotientDigit( remainderS, denS )
    quotientS = quotientS + Chr( 48 + qDigitI )
    IF qDigitI > 0
      remainderS = ProcSubtractPositive(
        remainderS,
        ProcMultiplyPositiveByDigit( denS, qDigitI )
      )
    ENDIF
  ENDFOR
  gDivisionRemainderS = ProcTrimLeadingZeros( remainderS )
  Return( ProcTrimLeadingZeros( quotientS ) )
END

STRING PROC ProcDivideSignedByPositiveRounded( STRING numeratorS, STRING denominatorS )
  STRING absNumS[ MAX_BIGLEN ] = ""
  STRING quotientS[ MAX_BIGLEN ] = ""
  STRING twiceRemainderS[ MAX_BIGLEN ] = ""
  INTEGER negativeB = FALSE
  negativeB = ProcIsNegative( numeratorS )
  absNumS = ProcAbsInteger( numeratorS )
  quotientS = ProcDividePositive( absNumS, denominatorS )
  twiceRemainderS = ProcMultiplyPositiveByDigit( gDivisionRemainderS, 2 )
  IF ProcCompareAbs( twiceRemainderS, denominatorS ) >= 0
    quotientS = ProcAddPositive( quotientS, "1" )
  ENDIF
  IF quotientS == "0"
    Return( "0" )
  ENDIF
  IF negativeB
    Return( "-" + quotientS )
  ENDIF
  Return( quotientS )
END

STRING PROC ProcMulBySmallInteger( STRING numberS, INTEGER factorI )
  STRING resultS[ MAX_BIGLEN ] = "0"
  INTEGER indexI = 0
  FOR indexI = 1 TO factorI
    resultS = ProcAddIntegers( resultS, numberS )
  ENDFOR
  Return( resultS )
END

INTEGER PROC ProcAbsLessOrEqual( STRING leftS, STRING rightS )
  Return( ProcCompareAbs( leftS, rightS ) <= 0 )
END

INTEGER PROC ProcIsPositive( STRING numberS )
  STRING workS[ MAX_BIGLEN ] = ""
  workS = ProcNormalizeInteger( numberS )
  Return( NOT ProcIsNegative( workS ) AND NOT ProcIsZero( workS ) )
END

STRING PROC ProcFixedMultiply( STRING leftS, STRING rightS, STRING scaleS )
  STRING productS[ MAX_BIGLEN ] = ""
  productS = ProcMultiplyIntegers( leftS, rightS )
  Return( ProcDivideSignedByPositiveRounded( productS, scaleS ) )
END

STRING PROC ProcFixedDivideSignedByPositive( STRING numeratorS, STRING denominatorS, STRING scaleS )
  STRING scaledNumeratorS[ MAX_BIGLEN ] = ""
  scaledNumeratorS = ProcMultiplyIntegers( numeratorS, scaleS )
  Return( ProcDivideSignedByPositiveRounded( scaledNumeratorS, denominatorS ) )
END

STRING PROC ProcReflectComponent(
  STRING vComponentS,
  STRING factorS,
  STRING nComponentS,
  STRING scaleS
)
  STRING correctionS[ MAX_BIGLEN ] = ""
  correctionS = ProcFixedMultiply( factorS, nComponentS, scaleS )
  Return( ProcAddIntegers( vComponentS, ProcNegateInteger( correctionS ) ) )
END

PROC Main()
  STRING scaleS[ 16 ] = "100000000"
  STRING holeS[ 16 ] = "1000000"
  STRING xS[ MAX_BIGLEN ] = "140000000"
  STRING yS[ MAX_BIGLEN ] = "-960000000"
  STRING vxS[ MAX_BIGLEN ] = "140000000"
  STRING vyS[ MAX_BIGLEN ] = "-1970000000"
  STRING nxS[ MAX_BIGLEN ] = ""
  STRING nyS[ MAX_BIGLEN ] = ""
  STRING dotS[ MAX_BIGLEN ] = ""
  STRING nnS[ MAX_BIGLEN ] = ""
  STRING factorS[ MAX_BIGLEN ] = ""
  STRING newVxS[ MAX_BIGLEN ] = ""
  STRING newVyS[ MAX_BIGLEN ] = ""
  STRING stepNumS[ MAX_BIGLEN ] = ""
  STRING stepDenS[ MAX_BIGLEN ] = ""
  STRING tS[ MAX_BIGLEN ] = ""
  STRING deltaXS[ MAX_BIGLEN ] = ""
  STRING deltaYS[ MAX_BIGLEN ] = ""
  STRING resultS[ 16 ] = ""
  INTEGER hitCountI = 0
  INTEGER exitFoundB = FALSE
  INTEGER guardI = 0
  //
  // If your TSE build supports it, you can uncomment the next line.
  // AddHistoryStr( gLlmNameS, _EDIT_HISTORY_ )
  //
  WHILE NOT exitFoundB
    hitCountI = hitCountI + 1
    nxS = ProcMulBySmallInteger( xS, 4 )
    nyS = yS
    dotS = ProcAddIntegers(
      ProcFixedMultiply( vxS, nxS, scaleS ),
      ProcFixedMultiply( vyS, nyS, scaleS )
    )
    nnS = ProcAddIntegers(
      ProcFixedMultiply( nxS, nxS, scaleS ),
      ProcFixedMultiply( nyS, nyS, scaleS )
    )
    factorS = ProcFixedDivideSignedByPositive(
      ProcMulBySmallInteger( dotS, 2 ),
      nnS,
      scaleS
    )
    newVxS = ProcReflectComponent( vxS, factorS, nxS, scaleS )
    newVyS = ProcReflectComponent( vyS, factorS, nyS, scaleS )
    stepNumS = ProcNegateInteger(
      ProcMulBySmallInteger(
        ProcAddIntegers(
          ProcFixedMultiply( ProcMulBySmallInteger( xS, 4 ), newVxS, scaleS ),
          ProcFixedMultiply( yS, newVyS, scaleS )
        ),
        2
      )
    )
    stepDenS = ProcAddIntegers(
      ProcFixedMultiply( ProcMulBySmallInteger( newVxS, 4 ), newVxS, scaleS ),
      ProcFixedMultiply( newVyS, newVyS, scaleS )
    )
    tS = ProcFixedDivideSignedByPositive( stepNumS, stepDenS, scaleS )
    deltaXS = ProcFixedMultiply( tS, newVxS, scaleS )
    deltaYS = ProcFixedMultiply( tS, newVyS, scaleS )
    xS = ProcAddIntegers( xS, deltaXS )
    yS = ProcAddIntegers( yS, deltaYS )
    vxS = newVxS
    vyS = newVyS
    IF ProcIsPositive( yS ) AND ProcAbsLessOrEqual( xS, holeS )
      exitFoundB = TRUE
    ENDIF
    guardI = guardI + 1
    IF guardI > 2000
      Warn( "Guard triggered" )
      Return()
    ENDIF
  ENDWHILE
  resultS = Format( hitCountI )
  CopyToWinClip( resultS )
  Warn( resultS )
END
