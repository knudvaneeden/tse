/*
  Project Euler problem 272
  Modular Cubes, Part 2
  <version>5</version>

  History:
  1 - ChatGPT initial version.
  2 - ChatGPT version based on uploaded 272.py structure.
  3 - ChatGPT faster version with precomputed minimal suffix products.
  4 - ChatGPT compile fix: replaced invalid string #define with global string variable.
  5 - ChatGPT faster version: removed slow buffer-based primality checks and
      used direct prime testing for generating primes p == 1 (mod 3).

  Verification note:
  Correct final result for this problem is:
  8495585919506151122
  This value is NOT used in the calculation logic below.
*/

#define PREFIX_ALLOW3 1
#define PREFIX_NO3 2
#define GOOD_PRIME_LIMIT 6426322
#define PREFIX_LIMIT 207300

FORWARD STRING PROC ProcTrimLeadingZeros( STRING numberS )
FORWARD STRING PROC ProcReverseString( STRING inputS )
FORWARD STRING PROC ProcDigitChar( INTEGER digitI )
FORWARD INTEGER PROC ProcCompareDecimalStrings( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcAddDecimalStrings( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcMultiplyDecimalStringByInteger( STRING numberS, INTEGER multiplierI )
FORWARD STRING PROC ProcMultiplyDecimalStrings( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcDivideDecimalStringByInteger( STRING numberS, INTEGER divisorI )
FORWARD STRING PROC ProcCapMultiplyDecimalStringByInteger( STRING numberS, INTEGER multiplierI, STRING capS )
FORWARD PROC ProcSetBufferLineText( INTEGER bufferI, INTEGER lineI, STRING textS )
FORWARD STRING PROC ProcGetBufferLineText( INTEGER bufferI, INTEGER lineI )
FORWARD INTEGER PROC ProcIsPrimeFast( INTEGER candidateI )
FORWARD PROC ProcBuildGoodPrimeBuffer()
FORWARD PROC ProcMarkStepBuffer( INTEGER bufferI, INTEGER stepI )
FORWARD PROC ProcBuildPrefixBuffers()
FORWARD STRING PROC ProcGetPrefixSum( INTEGER prefixTypeI, INTEGER limitI )
FORWARD PROC ProcCreateFilledBuffer( INTEGER bufferI, INTEGER lineCountI, STRING fillS )
FORWARD PROC ProcBuildMinProdBuffers()
FORWARD STRING PROC ProcGetMinProd( INTEGER remainingI, INTEGER startLineI )
FORWARD INTEGER PROC ProcTailFits( INTEGER startLineI, INTEGER remainingI, STRING limitS )
FORWARD PROC ProcDfsGoodPrimePowers( INTEGER startLineI, INTEGER remainingI, STRING accS, STRING limitS, INTEGER prefixTypeI )

INTEGER gGoodPrimeBufferI = 0
INTEGER gGoodPrimeCountI = 0
INTEGER gAllow3PrefixBufferI = 0
INTEGER gNo3PrefixBufferI = 0
INTEGER gAllow3FlagBufferI = 0
INTEGER gNo3FlagBufferI = 0
INTEGER gMinProd1BufferI = 0
INTEGER gMinProd2BufferI = 0
INTEGER gMinProd3BufferI = 0
INTEGER gMinProd4BufferI = 0
INTEGER gMinProd5BufferI = 0
INTEGER gDivisionRemainderI = 0
STRING gOverallLimitS[255] = "100000000000"
STRING gCapLimitS[255] = "100000000001"
STRING gAnswerS[255] = "0"

STRING PROC ProcTrimLeadingZeros( STRING numberS )
  INTEGER indexI = 1
  INTEGER lengthI = 0
  STRING workS[255] = ""

  workS = numberS
  lengthI = Length( workS )
  IF lengthI == 0
    RETURN( "0" )
  ENDIF
  WHILE indexI < lengthI
    IF NOT ( SubStr( workS, indexI, 1 ) == "0" )
      BREAK
    ENDIF
    indexI = indexI + 1
  ENDWHILE
  RETURN( SubStr( workS, indexI, lengthI - indexI + 1 ) )
END

STRING PROC ProcReverseString( STRING inputS )
  INTEGER indexI = 0
  STRING outputS[255] = ""

  FOR indexI = Length( inputS ) DOWNTO 1
    outputS = outputS + SubStr( inputS, indexI, 1 )
  ENDFOR
  RETURN( outputS )
END

STRING PROC ProcDigitChar( INTEGER digitI )
  STRING digitsS[11] = "0123456789"

  RETURN( SubStr( digitsS, digitI + 1, 1 ) )
END

INTEGER PROC ProcCompareDecimalStrings( STRING leftS, STRING rightS )
  INTEGER indexI = 0
  STRING leftTrimS[255] = ""
  STRING rightTrimS[255] = ""
  STRING leftCharS[2] = ""
  STRING rightCharS[2] = ""

  leftTrimS = ProcTrimLeadingZeros( leftS )
  rightTrimS = ProcTrimLeadingZeros( rightS )
  IF Length( leftTrimS ) < Length( rightTrimS )
    RETURN( -1 )
  ENDIF
  IF Length( leftTrimS ) > Length( rightTrimS )
    RETURN( 1 )
  ENDIF
  FOR indexI = 1 TO Length( leftTrimS )
    leftCharS = SubStr( leftTrimS, indexI, 1 )
    rightCharS = SubStr( rightTrimS, indexI, 1 )
    IF leftCharS < rightCharS
      RETURN( -1 )
    ENDIF
    IF leftCharS > rightCharS
      RETURN( 1 )
    ENDIF
  ENDFOR
  RETURN( 0 )
END

STRING PROC ProcAddDecimalStrings( STRING leftS, STRING rightS )
  INTEGER indexLeftI = 0
  INTEGER indexRightI = 0
  INTEGER carryI = 0
  INTEGER digitLeftI = 0
  INTEGER digitRightI = 0
  INTEGER sumI = 0
  STRING leftTrimS[255] = ""
  STRING rightTrimS[255] = ""
  STRING resultReversedS[255] = ""
  STRING resultS[255] = ""

  leftTrimS = ProcTrimLeadingZeros( leftS )
  rightTrimS = ProcTrimLeadingZeros( rightS )
  indexLeftI = Length( leftTrimS )
  indexRightI = Length( rightTrimS )
  WHILE indexLeftI > 0 OR indexRightI > 0 OR carryI > 0
    digitLeftI = 0
    digitRightI = 0
    IF indexLeftI > 0
      digitLeftI = Val( SubStr( leftTrimS, indexLeftI, 1 ) )
      indexLeftI = indexLeftI - 1
    ENDIF
    IF indexRightI > 0
      digitRightI = Val( SubStr( rightTrimS, indexRightI, 1 ) )
      indexRightI = indexRightI - 1
    ENDIF
    sumI = digitLeftI + digitRightI + carryI
    resultReversedS = resultReversedS + ProcDigitChar( sumI mod 10 )
    carryI = sumI / 10
  ENDWHILE
  resultS = ProcReverseString( resultReversedS )
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcMultiplyDecimalStringByInteger( STRING numberS, INTEGER multiplierI )
  INTEGER indexI = 0
  INTEGER carryI = 0
  INTEGER digitI = 0
  INTEGER productI = 0
  STRING workS[255] = ""
  STRING resultReversedS[255] = ""
  STRING resultS[255] = ""

  workS = ProcTrimLeadingZeros( numberS )
  IF multiplierI == 0
    RETURN( "0" )
  ENDIF
  IF multiplierI == 1
    RETURN( workS )
  ENDIF
  FOR indexI = Length( workS ) DOWNTO 1
    digitI = Val( SubStr( workS, indexI, 1 ) )
    productI = digitI * multiplierI + carryI
    resultReversedS = resultReversedS + ProcDigitChar( productI mod 10 )
    carryI = productI / 10
  ENDFOR
  WHILE carryI > 0
    resultReversedS = resultReversedS + ProcDigitChar( carryI mod 10 )
    carryI = carryI / 10
  ENDWHILE
  resultS = ProcReverseString( resultReversedS )
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcMultiplyDecimalStrings( STRING leftS, STRING rightS )
  INTEGER indexI = 0
  INTEGER appendI = 0
  INTEGER digitI = 0
  INTEGER shiftI = 0
  STRING leftTrimS[255] = ""
  STRING rightTrimS[255] = ""
  STRING partialS[255] = ""
  STRING resultS[255] = ""

  leftTrimS = ProcTrimLeadingZeros( leftS )
  rightTrimS = ProcTrimLeadingZeros( rightS )
  IF leftTrimS == "0" OR rightTrimS == "0"
    RETURN( "0" )
  ENDIF
  resultS = "0"
  shiftI = 0
  FOR indexI = Length( rightTrimS ) DOWNTO 1
    digitI = Val( SubStr( rightTrimS, indexI, 1 ) )
    partialS = ProcMultiplyDecimalStringByInteger( leftTrimS, digitI )
    IF NOT ( partialS == "0" )
      FOR appendI = 1 TO shiftI
        partialS = partialS + "0"
      ENDFOR
      resultS = ProcAddDecimalStrings( resultS, partialS )
    ENDIF
    shiftI = shiftI + 1
  ENDFOR
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcDivideDecimalStringByInteger( STRING numberS, INTEGER divisorI )
  INTEGER indexI = 0
  INTEGER digitI = 0
  INTEGER quotientDigitI = 0
  STRING workS[255] = ""
  STRING quotientS[255] = ""

  workS = ProcTrimLeadingZeros( numberS )
  gDivisionRemainderI = 0
  FOR indexI = 1 TO Length( workS )
    digitI = Val( SubStr( workS, indexI, 1 ) )
    gDivisionRemainderI = gDivisionRemainderI * 10 + digitI
    quotientDigitI = gDivisionRemainderI / divisorI
    gDivisionRemainderI = gDivisionRemainderI mod divisorI
    quotientS = quotientS + ProcDigitChar( quotientDigitI )
  ENDFOR
  RETURN( ProcTrimLeadingZeros( quotientS ) )
END

STRING PROC ProcCapMultiplyDecimalStringByInteger( STRING numberS, INTEGER multiplierI, STRING capS )
  STRING productS[255] = ""

  productS = ProcMultiplyDecimalStringByInteger( numberS, multiplierI )
  IF ProcCompareDecimalStrings( productS, capS ) > 0
    RETURN( capS )
  ENDIF
  RETURN( productS )
END

PROC ProcSetBufferLineText( INTEGER bufferI, INTEGER lineI, STRING textS )
  PushLocation()
  GotoBufferId( bufferI )
  GotoLine( lineI )
  BegLine()
  KillToEol()
  InsertText( textS )
  PopLocation()
END

STRING PROC ProcGetBufferLineText( INTEGER bufferI, INTEGER lineI )
  STRING textS[255] = ""

  IF lineI <= 0
    RETURN( "0" )
  ENDIF
  PushLocation()
  GotoBufferId( bufferI )
  GotoLine( lineI )
  textS = GetText( 1, 255 )
  PopLocation()
  RETURN( textS )
END

INTEGER PROC ProcIsPrimeFast( INTEGER candidateI )
  INTEGER divisorI = 0

  IF candidateI < 2
    RETURN( FALSE )
  ENDIF
  IF candidateI == 2 OR candidateI == 3
    RETURN( TRUE )
  ENDIF
  IF candidateI mod 2 == 0 OR candidateI mod 3 == 0
    RETURN( FALSE )
  ENDIF
  divisorI = 5
  WHILE divisorI * divisorI <= candidateI
    IF candidateI mod divisorI == 0
      RETURN( FALSE )
    ENDIF
    IF candidateI mod ( divisorI + 2 ) == 0
      RETURN( FALSE )
    ENDIF
    divisorI = divisorI + 6
  ENDWHILE
  RETURN( TRUE )
END

PROC ProcBuildGoodPrimeBuffer()
  INTEGER candidateI = 0

  IF gGoodPrimeBufferI
    RETURN()
  ENDIF
  gGoodPrimeBufferI = CreateTempBuffer()
  gGoodPrimeCountI = 0
  FOR candidateI = 7 TO GOOD_PRIME_LIMIT BY 6
    IF ProcIsPrimeFast( candidateI )
      AddLine( Format( candidateI ), gGoodPrimeBufferI )
      gGoodPrimeCountI = gGoodPrimeCountI + 1
    ENDIF
  ENDFOR
END

PROC ProcMarkStepBuffer( INTEGER bufferI, INTEGER stepI )
  INTEGER lineI = 0

  PushLocation()
  GotoBufferId( bufferI )
  FOR lineI = stepI TO PREFIX_LIMIT BY stepI
    GotoLine( lineI )
    BegLine()
    KillToEol()
    InsertText( "0" )
  ENDFOR
  PopLocation()
END

PROC ProcBuildPrefixBuffers()
  INTEGER indexI = 0
  INTEGER primeI = 0
  STRING lineS[255] = ""
  STRING allowSumS[255] = ""
  STRING no3SumS[255] = ""
  STRING allowFlagS[2] = ""
  STRING no3FlagS[2] = ""

  IF gAllow3PrefixBufferI AND gNo3PrefixBufferI
    RETURN()
  ENDIF

  gAllow3FlagBufferI = CreateTempBuffer()
  gNo3FlagBufferI = CreateTempBuffer()
  FOR indexI = 1 TO PREFIX_LIMIT
    AddLine( "1", gAllow3FlagBufferI )
    AddLine( "1", gNo3FlagBufferI )
  ENDFOR

  ProcMarkStepBuffer( gAllow3FlagBufferI, 9 )
  ProcMarkStepBuffer( gNo3FlagBufferI, 3 )

  PushLocation()
  GotoBufferId( gGoodPrimeBufferI )
  BegFile()
  FOR indexI = 1 TO gGoodPrimeCountI
    lineS = GetText( 1, 255 )
    primeI = Val( lineS )
    IF primeI > PREFIX_LIMIT
      BREAK
    ENDIF
    ProcMarkStepBuffer( gAllow3FlagBufferI, primeI )
    ProcMarkStepBuffer( gNo3FlagBufferI, primeI )
    IF indexI < gGoodPrimeCountI
      Down()
    ENDIF
  ENDFOR
  PopLocation()

  gAllow3PrefixBufferI = CreateTempBuffer()
  gNo3PrefixBufferI = CreateTempBuffer()
  allowSumS = "0"
  no3SumS = "0"

  PushLocation()
  GotoBufferId( gAllow3FlagBufferI )
  BegFile()
  FOR indexI = 1 TO PREFIX_LIMIT
    allowFlagS = GetText( 1, 1 )
    PushLocation()
    GotoBufferId( gNo3FlagBufferI )
    GotoLine( indexI )
    no3FlagS = GetText( 1, 1 )
    PopLocation()
    IF allowFlagS == "1"
      allowSumS = ProcAddDecimalStrings( allowSumS, Format( indexI ) )
    ENDIF
    IF no3FlagS == "1"
      no3SumS = ProcAddDecimalStrings( no3SumS, Format( indexI ) )
    ENDIF
    AddLine( allowSumS, gAllow3PrefixBufferI )
    AddLine( no3SumS, gNo3PrefixBufferI )
    IF indexI < PREFIX_LIMIT
      Down()
    ENDIF
  ENDFOR
  PopLocation()
END

STRING PROC ProcGetPrefixSum( INTEGER prefixTypeI, INTEGER limitI )
  IF limitI <= 0
    RETURN( "0" )
  ENDIF
  IF prefixTypeI == PREFIX_ALLOW3
    RETURN( ProcGetBufferLineText( gAllow3PrefixBufferI, limitI ) )
  ENDIF
  RETURN( ProcGetBufferLineText( gNo3PrefixBufferI, limitI ) )
END

PROC ProcCreateFilledBuffer( INTEGER bufferI, INTEGER lineCountI, STRING fillS )
  INTEGER indexI = 0

  FOR indexI = 1 TO lineCountI
    AddLine( fillS, bufferI )
  ENDFOR
END

PROC ProcBuildMinProdBuffers()
  INTEGER lineI = 0
  INTEGER primeI = 0
  STRING lineS[255] = ""
  STRING next1S[255] = ""
  STRING next2S[255] = ""
  STRING next3S[255] = ""
  STRING next4S[255] = ""
  STRING next5S[255] = ""
  STRING cur1S[255] = ""
  STRING cur2S[255] = ""
  STRING cur3S[255] = ""
  STRING cur4S[255] = ""
  STRING cur5S[255] = ""

  IF gMinProd1BufferI
    RETURN()
  ENDIF

  gMinProd1BufferI = CreateTempBuffer()
  gMinProd2BufferI = CreateTempBuffer()
  gMinProd3BufferI = CreateTempBuffer()
  gMinProd4BufferI = CreateTempBuffer()
  gMinProd5BufferI = CreateTempBuffer()

  ProcCreateFilledBuffer( gMinProd1BufferI, gGoodPrimeCountI + 1, gCapLimitS )
  ProcCreateFilledBuffer( gMinProd2BufferI, gGoodPrimeCountI + 1, gCapLimitS )
  ProcCreateFilledBuffer( gMinProd3BufferI, gGoodPrimeCountI + 1, gCapLimitS )
  ProcCreateFilledBuffer( gMinProd4BufferI, gGoodPrimeCountI + 1, gCapLimitS )
  ProcCreateFilledBuffer( gMinProd5BufferI, gGoodPrimeCountI + 1, gCapLimitS )

  next1S = gCapLimitS
  next2S = gCapLimitS
  next3S = gCapLimitS
  next4S = gCapLimitS
  next5S = gCapLimitS

  PushLocation()
  GotoBufferId( gGoodPrimeBufferI )
  EndFile()
  FOR lineI = gGoodPrimeCountI DOWNTO 1
    lineS = GetText( 1, 255 )
    primeI = Val( lineS )
    cur1S = lineS
    cur2S = ProcCapMultiplyDecimalStringByInteger( next1S, primeI, gCapLimitS )
    cur3S = ProcCapMultiplyDecimalStringByInteger( next2S, primeI, gCapLimitS )
    cur4S = ProcCapMultiplyDecimalStringByInteger( next3S, primeI, gCapLimitS )
    cur5S = ProcCapMultiplyDecimalStringByInteger( next4S, primeI, gCapLimitS )
    ProcSetBufferLineText( gMinProd1BufferI, lineI, cur1S )
    ProcSetBufferLineText( gMinProd2BufferI, lineI, cur2S )
    ProcSetBufferLineText( gMinProd3BufferI, lineI, cur3S )
    ProcSetBufferLineText( gMinProd4BufferI, lineI, cur4S )
    ProcSetBufferLineText( gMinProd5BufferI, lineI, cur5S )
    next1S = cur1S
    next2S = cur2S
    next3S = cur3S
    next4S = cur4S
    next5S = cur5S
    IF lineI > 1
      Up()
    ENDIF
  ENDFOR
  PopLocation()
END

STRING PROC ProcGetMinProd( INTEGER remainingI, INTEGER startLineI )
  IF remainingI == 1
    RETURN( ProcGetBufferLineText( gMinProd1BufferI, startLineI ) )
  ENDIF
  IF remainingI == 2
    RETURN( ProcGetBufferLineText( gMinProd2BufferI, startLineI ) )
  ENDIF
  IF remainingI == 3
    RETURN( ProcGetBufferLineText( gMinProd3BufferI, startLineI ) )
  ENDIF
  IF remainingI == 4
    RETURN( ProcGetBufferLineText( gMinProd4BufferI, startLineI ) )
  ENDIF
  RETURN( ProcGetBufferLineText( gMinProd5BufferI, startLineI ) )
END

INTEGER PROC ProcTailFits( INTEGER startLineI, INTEGER remainingI, STRING limitS )
  STRING minProdS[255] = ""

  IF remainingI <= 0
    RETURN( TRUE )
  ENDIF
  IF startLineI > gGoodPrimeCountI
    RETURN( FALSE )
  ENDIF
  minProdS = ProcGetMinProd( remainingI, startLineI )
  IF ProcCompareDecimalStrings( minProdS, limitS ) > 0
    RETURN( FALSE )
  ENDIF
  RETURN( TRUE )
END

PROC ProcDfsGoodPrimePowers( INTEGER startLineI, INTEGER remainingI, STRING accS, STRING limitS, INTEGER prefixTypeI )
  INTEGER lineI = 0
  INTEGER primeI = 0
  INTEGER prefixIndexI = 0
  STRING lineS[255] = ""
  STRING accPowS[255] = ""
  STRING limitPowS[255] = ""
  STRING prefixS[255] = ""
  STRING termS[255] = ""
  STRING minNeedS[255] = ""

  IF remainingI == 1
    PushLocation()
    GotoBufferId( gGoodPrimeBufferI )
    GotoLine( startLineI )
    FOR lineI = startLineI TO gGoodPrimeCountI
      lineS = GetText( 1, 255 )
      IF ProcCompareDecimalStrings( lineS, limitS ) > 0
        BREAK
      ENDIF
      primeI = Val( lineS )
      accPowS = accS
      limitPowS = limitS
      WHILE ProcCompareDecimalStrings( limitPowS, lineS ) >= 0
        accPowS = ProcMultiplyDecimalStringByInteger( accPowS, primeI )
        limitPowS = ProcDivideDecimalStringByInteger( limitPowS, primeI )
        prefixIndexI = Val( limitPowS )
        prefixS = ProcGetPrefixSum( prefixTypeI, prefixIndexI )
        termS = ProcMultiplyDecimalStrings( accPowS, prefixS )
        gAnswerS = ProcAddDecimalStrings( gAnswerS, termS )
      ENDWHILE
      IF lineI < gGoodPrimeCountI
        Down()
      ENDIF
    ENDFOR
    PopLocation()
    RETURN()
  ENDIF

  PushLocation()
  GotoBufferId( gGoodPrimeBufferI )
  GotoLine( startLineI )
  FOR lineI = startLineI TO gGoodPrimeCountI
    lineS = GetText( 1, 255 )
    minNeedS = ProcGetMinProd( remainingI, lineI )
    IF ProcCompareDecimalStrings( minNeedS, limitS ) > 0
      BREAK
    ENDIF
    primeI = Val( lineS )
    accPowS = accS
    limitPowS = limitS
    WHILE ProcCompareDecimalStrings( limitPowS, lineS ) >= 0
      accPowS = ProcMultiplyDecimalStringByInteger( accPowS, primeI )
      limitPowS = ProcDivideDecimalStringByInteger( limitPowS, primeI )
      IF ProcTailFits( lineI + 1, remainingI - 1, limitPowS )
        ProcDfsGoodPrimePowers( lineI + 1, remainingI - 1, accPowS, limitPowS, prefixTypeI )
      ELSE
        BREAK
      ENDIF
    ENDWHILE
    IF lineI < gGoodPrimeCountI
      Down()
    ENDIF
  ENDFOR
  PopLocation()
END

PROC Main()
  STRING acc3S[255] = ""
  STRING limit3S[255] = ""

  ProcBuildGoodPrimeBuffer()
  ProcBuildPrefixBuffers()
  ProcBuildMinProdBuffers()

  gAnswerS = "0"

  ProcDfsGoodPrimePowers( 1, 5, "1", gOverallLimitS, PREFIX_ALLOW3 )

  acc3S = "9"
  limit3S = ProcDivideDecimalStringByInteger( gOverallLimitS, 9 )
  WHILE TRUE
    IF NOT ( ProcTailFits( 1, 4, limit3S ) )
      BREAK
    ENDIF
    ProcDfsGoodPrimePowers( 1, 4, acc3S, limit3S, PREFIX_NO3 )
    acc3S = ProcMultiplyDecimalStringByInteger( acc3S, 3 )
    limit3S = ProcDivideDecimalStringByInteger( limit3S, 3 )
  ENDWHILE

  CopyToWinClip( gAnswerS )
  Warn( gAnswerS )
  CopyToWinClip( gAnswerS )
END
