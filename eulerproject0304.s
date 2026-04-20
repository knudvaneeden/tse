// Euler Project 304
// Pure TSE SAL
// <version>3</version>
// History:
// 1 - ChatGPT - initial pure TSE SAL solver for Project Euler problem 304
// 2 - ChatGPT - redesigned pure TSE SAL solver using segmented sieves and incremental Fibonacci
// 3 - ChatGPT - faster version using packed root primes and direct segment crossing recomputation
//
#DEFINE TARGET_COUNT        100000
#DEFINE SMALL_LIMIT         10000000
#DEFINE SMALL_ROOT          3163
#DEFINE BIG_BATCH_ODDS      2500000
#DEFINE BIG_BATCH_STEP      5000000
#DEFINE FLAG_CHUNK          250
#DEFINE PACKED_LINE_LIMIT   250
#DEFINE MOD_1               3
#DEFINE MOD_2               7
#DEFINE MOD_3               13
#DEFINE MOD_4               67
#DEFINE MOD_5               107
#DEFINE MOD_6               630803
//
INTEGER gRootPrimeBufferGI = 0
INTEGER gFibFirstGI = 0
INTEGER gFibSecondGI = 0
STRING gPendingRootPrimesGS[255] = ""
//
FORWARD PROC PROCReplaceCurrentLine( STRING lineS )
FORWARD STRING PROC FNRepeatCharS( STRING charS, INTEGER countI )
FORWARD INTEGER PROC FNFindCharFromI( STRING textS, STRING findS, INTEGER startI )
FORWARD STRING PROC FNReverseS( STRING textS )
FORWARD STRING PROC FNTrimLeadingZerosS( STRING numberS )
FORWARD STRING PROC FNStringAddS( STRING leftS, STRING rightS )
FORWARD STRING PROC FNStringMultiplySmallS( STRING numberS, INTEGER factorI )
FORWARD INTEGER PROC FNStringModSmallI( STRING numberS, INTEGER divisorI )
FORWARD STRING PROC FNDecimalToBitsS( STRING decimalS )
FORWARD INTEGER PROC FNMulModI( INTEGER leftI, INTEGER rightI, INTEGER modI )
FORWARD INTEGER PROC FNModInverseI( INTEGER valueI, INTEGER modI )
FORWARD PROC PROCComputeFibPairMod( STRING bitsS, INTEGER modI )
FORWARD PROC PROCInitFlagBuffer( INTEGER bufferI, INTEGER itemCountI )
FORWARD INTEGER PROC FNFlagIsZeroB( INTEGER bufferI, INTEGER indexI )
FORWARD PROC PROCMarkComposite( INTEGER firstI, INTEGER stepI, INTEGER itemCountI )
FORWARD PROC PROCAppendRootPrime( INTEGER primeI )
FORWARD PROC PROCFlushRootPrimes()
FORWARD PROC PROCBuildRootPrimes()
FORWARD PROC PROCMarkPrimeLine( STRING lineS, STRING startOddS, INTEGER itemCountI )
FORWARD STRING PROC FNCRTAnswerS( INTEGER residue1I, INTEGER residue2I, INTEGER residue3I, INTEGER residue4I, INTEGER residue5I, INTEGER residue6I )
//
PROC PROCReplaceCurrentLine( STRING lineS )
  BegLine()
  KillToEol()
  InsertText( lineS )
END
//
STRING PROC FNRepeatCharS( STRING charS, INTEGER countI )
  STRING resultS[255] = ""
  INTEGER indexI = 0
  FOR indexI = 1 TO countI
    resultS = resultS + charS
  ENDFOR
  RETURN( resultS )
END
//
INTEGER PROC FNFindCharFromI( STRING textS, STRING findS, INTEGER startI )
  INTEGER indexI = 0
  indexI = startI
  WHILE indexI <= Length( textS )
    IF SubStr( textS, indexI, 1 ) == findS
      RETURN( indexI )
    ENDIF
    indexI = indexI + 1
  ENDWHILE
  RETURN( 0 )
END
//
STRING PROC FNReverseS( STRING textS )
  STRING resultS[255] = ""
  INTEGER indexI = 0
  FOR indexI = Length( textS ) DOWNTO 1
    resultS = resultS + SubStr( textS, indexI, 1 )
  ENDFOR
  RETURN( resultS )
END
//
STRING PROC FNTrimLeadingZerosS( STRING numberS )
  INTEGER indexI = 1
  WHILE ( indexI < Length( numberS ) ) AND ( SubStr( numberS, indexI, 1 ) == "0" )
    indexI = indexI + 1
  ENDWHILE
  RETURN( SubStr( numberS, indexI, Length( numberS ) - indexI + 1 ) )
END
//
STRING PROC FNStringAddS( STRING leftS, STRING rightS )
  STRING resultRevS[255] = ""
  INTEGER indexLeftI = 0
  INTEGER indexRightI = 0
  INTEGER carryI = 0
  INTEGER digitLeftI = 0
  INTEGER digitRightI = 0
  INTEGER sumI = 0
  indexLeftI = Length( leftS )
  indexRightI = Length( rightS )
  carryI = 0
  WHILE ( indexLeftI > 0 ) OR ( indexRightI > 0 ) OR ( carryI > 0 )
    digitLeftI = 0
    digitRightI = 0
    IF indexLeftI > 0
      digitLeftI = Val( SubStr( leftS, indexLeftI, 1 ) )
      indexLeftI = indexLeftI - 1
    ENDIF
    IF indexRightI > 0
      digitRightI = Val( SubStr( rightS, indexRightI, 1 ) )
      indexRightI = indexRightI - 1
    ENDIF
    sumI = digitLeftI + digitRightI + carryI
    resultRevS = resultRevS + Format( sumI mod 10 )
    carryI = sumI / 10
  ENDWHILE
  RETURN( FNTrimLeadingZerosS( FNReverseS( resultRevS ) ) )
END
//
STRING PROC FNStringMultiplySmallS( STRING numberS, INTEGER factorI )
  STRING resultRevS[255] = ""
  INTEGER indexI = 0
  INTEGER digitI = 0
  INTEGER carryI = 0
  INTEGER valueI = 0
  IF factorI == 0
    RETURN( "0" )
  ENDIF
  IF factorI == 1
    RETURN( FNTrimLeadingZerosS( numberS ) )
  ENDIF
  carryI = 0
  FOR indexI = Length( numberS ) DOWNTO 1
    digitI = Val( SubStr( numberS, indexI, 1 ) )
    valueI = digitI * factorI + carryI
    resultRevS = resultRevS + Format( valueI mod 10 )
    carryI = valueI / 10
  ENDFOR
  WHILE carryI > 0
    resultRevS = resultRevS + Format( carryI mod 10 )
    carryI = carryI / 10
  ENDWHILE
  RETURN( FNTrimLeadingZerosS( FNReverseS( resultRevS ) ) )
END
//
INTEGER PROC FNStringModSmallI( STRING numberS, INTEGER divisorI )
  INTEGER indexI = 0
  INTEGER digitI = 0
  INTEGER remainderI = 0
  remainderI = 0
  FOR indexI = 1 TO Length( numberS )
    digitI = Val( SubStr( numberS, indexI, 1 ) )
    remainderI = ( remainderI * 10 + digitI ) mod divisorI
  ENDFOR
  RETURN( remainderI )
END
//
STRING PROC FNDecimalToBitsS( STRING decimalS )
  STRING workS[255] = ""
  STRING quotientS[255] = ""
  STRING bitsRevS[255] = ""
  INTEGER indexI = 0
  INTEGER digitI = 0
  INTEGER valueI = 0
  INTEGER quotientDigitI = 0
  INTEGER carryI = 0
  workS = FNTrimLeadingZerosS( decimalS )
  WHILE ( workS == "0" ) == FALSE
    quotientS = ""
    carryI = 0
    FOR indexI = 1 TO Length( workS )
      digitI = Val( SubStr( workS, indexI, 1 ) )
      valueI = carryI * 10 + digitI
      quotientDigitI = valueI / 2
      carryI = valueI mod 2
      IF ( ( quotientS == "" ) AND ( quotientDigitI == 0 ) ) == FALSE
        quotientS = quotientS + Format( quotientDigitI )
      ENDIF
    ENDFOR
    IF quotientS == ""
      quotientS = "0"
    ENDIF
    bitsRevS = bitsRevS + Format( carryI )
    workS = quotientS
  ENDWHILE
  RETURN( FNReverseS( bitsRevS ) )
END
//
INTEGER PROC FNMulModI( INTEGER leftI, INTEGER rightI, INTEGER modI )
  INTEGER resultI = 0
  INTEGER addI = 0
  INTEGER valueI = 0
  addI = leftI mod modI
  valueI = rightI mod modI
  resultI = 0
  WHILE valueI > 0
    IF valueI mod 2 == 1
      resultI = resultI + addI
      IF resultI >= modI
        resultI = resultI - modI
      ENDIF
    ENDIF
    valueI = valueI / 2
    addI = addI + addI
    IF addI >= modI
      addI = addI - modI
    ENDIF
  ENDWHILE
  RETURN( resultI )
END
//
INTEGER PROC FNModInverseI( INTEGER valueI, INTEGER modI )
  INTEGER candidateI = 0
  candidateI = 1
  WHILE candidateI < modI
    IF FNMulModI( valueI, candidateI, modI ) == 1
      RETURN( candidateI )
    ENDIF
    candidateI = candidateI + 1
  ENDWHILE
  RETURN( 0 )
END
//
PROC PROCComputeFibPairMod( STRING bitsS, INTEGER modI )
  INTEGER fibAI = 0
  INTEGER fibBI = 1
  INTEGER bitIndexI = 0
  INTEGER twoBMinusAI = 0
  INTEGER cI = 0
  INTEGER dI = 0
  INTEGER tmpI = 0
  fibAI = 0
  fibBI = 1
  FOR bitIndexI = 1 TO Length( bitsS )
    tmpI = fibBI + fibBI
    IF tmpI >= modI
      tmpI = tmpI - modI
    ENDIF
    IF tmpI >= fibAI
      twoBMinusAI = tmpI - fibAI
    ELSE
      twoBMinusAI = tmpI + modI - fibAI
    ENDIF
    cI = FNMulModI( fibAI, twoBMinusAI, modI )
    dI = FNMulModI( fibAI, fibAI, modI )
    dI = dI + FNMulModI( fibBI, fibBI, modI )
    IF dI >= modI
      dI = dI - modI
    ENDIF
    IF SubStr( bitsS, bitIndexI, 1 ) == "0"
      fibAI = cI
      fibBI = dI
    ELSE
      fibAI = dI
      fibBI = cI + dI
      IF fibBI >= modI
        fibBI = fibBI - modI
      ENDIF
    ENDIF
  ENDFOR
  gFibFirstGI = fibAI
  gFibSecondGI = fibBI
END
//
PROC PROCInitFlagBuffer( INTEGER bufferI, INTEGER itemCountI )
  STRING zeroChunkS[255] = ""
  INTEGER fullLinesI = 0
  INTEGER remainI = 0
  INTEGER lineNoI = 0
  zeroChunkS = FNRepeatCharS( "0", FLAG_CHUNK )
  fullLinesI = itemCountI / FLAG_CHUNK
  remainI = itemCountI mod FLAG_CHUNK
  FOR lineNoI = 1 TO fullLinesI
    AddLine( zeroChunkS, bufferI )
  ENDFOR
  IF remainI > 0
    AddLine( FNRepeatCharS( "0", remainI ), bufferI )
  ENDIF
END
//
INTEGER PROC FNFlagIsZeroB( INTEGER bufferI, INTEGER indexI )
  INTEGER lineNoI = 0
  INTEGER columnI = 0
  STRING lineS[255] = ""
  PushLocation()
  GotoBufferId( bufferI )
  lineNoI = indexI / FLAG_CHUNK + 1
  columnI = indexI mod FLAG_CHUNK + 1
  GotoLine( lineNoI )
  lineS = GetText( 1, 255 )
  PopLocation()
  IF SubStr( lineS, columnI, 1 ) == "0"
    RETURN( TRUE )
  ENDIF
  RETURN( FALSE )
END
//
PROC PROCMarkComposite( INTEGER firstI, INTEGER stepI, INTEGER itemCountI )
  INTEGER indexI = 0
  INTEGER lineNoI = 0
  INTEGER columnI = 0
  INTEGER currentLineNoI = 0
  STRING lineS[255] = ""
  STRING beforeS[255] = ""
  STRING afterS[255] = ""
  indexI = firstI
  currentLineNoI = 0
  lineS = ""
  WHILE indexI < itemCountI
    lineNoI = indexI / FLAG_CHUNK + 1
    columnI = indexI mod FLAG_CHUNK + 1
    IF lineNoI == currentLineNoI
    ELSE
      IF currentLineNoI > 0
        GotoLine( currentLineNoI )
        PROCReplaceCurrentLine( lineS )
      ENDIF
      GotoLine( lineNoI )
      lineS = GetText( 1, 255 )
      currentLineNoI = lineNoI
    ENDIF
    IF SubStr( lineS, columnI, 1 ) == "0"
      beforeS = ""
      afterS = ""
      IF columnI > 1
        beforeS = SubStr( lineS, 1, columnI - 1 )
      ENDIF
      IF columnI < Length( lineS )
        afterS = SubStr( lineS, columnI + 1, Length( lineS ) - columnI )
      ENDIF
      lineS = beforeS + "1" + afterS
    ENDIF
    indexI = indexI + stepI
  ENDWHILE
  IF currentLineNoI > 0
    GotoLine( currentLineNoI )
    PROCReplaceCurrentLine( lineS )
  ENDIF
END
//
PROC PROCAppendRootPrime( INTEGER primeI )
  STRING tokenS[255] = ""
  tokenS = Format( primeI )
  IF gPendingRootPrimesGS == ""
    gPendingRootPrimesGS = tokenS
  ELSE
    IF Length( gPendingRootPrimesGS ) + 1 + Length( tokenS ) <= PACKED_LINE_LIMIT
      gPendingRootPrimesGS = gPendingRootPrimesGS + " " + tokenS
    ELSE
      AddLine( gPendingRootPrimesGS, gRootPrimeBufferGI )
      gPendingRootPrimesGS = tokenS
    ENDIF
  ENDIF
END
//
PROC PROCFlushRootPrimes()
  IF ( gPendingRootPrimesGS == "" ) == FALSE
    AddLine( gPendingRootPrimesGS, gRootPrimeBufferGI )
    gPendingRootPrimesGS = ""
  ENDIF
END
//
PROC PROCBuildRootPrimes()
  INTEGER flagBufferI = 0
  INTEGER totalOddsI = 0
  INTEGER maxIndexI = 0
  INTEGER oddIndexI = 0
  INTEGER primeI = 0
  INTEGER firstIndexI = 0
  INTEGER lineCountI = 0
  INTEGER lineNoI = 0
  INTEGER charPosI = 0
  INTEGER globalIndexI = 0
  STRING lineS[255] = ""
  totalOddsI = ( SMALL_LIMIT - 3 ) / 2 + 1
  flagBufferI = CreateTempBuffer()
  PROCInitFlagBuffer( flagBufferI, totalOddsI )
  maxIndexI = ( SMALL_ROOT - 3 ) / 2
  FOR oddIndexI = 0 TO maxIndexI
    IF FNFlagIsZeroB( flagBufferI, oddIndexI )
      primeI = 3 + 2 * oddIndexI
      firstIndexI = ( primeI * primeI - 3 ) / 2
      PushLocation()
      GotoBufferId( flagBufferI )
      PROCMarkComposite( firstIndexI, primeI, totalOddsI )
      PopLocation()
    ENDIF
  ENDFOR
  gPendingRootPrimesGS = ""
  PushLocation()
  GotoBufferId( flagBufferI )
  lineCountI = NumLines()
  globalIndexI = 0
  FOR lineNoI = 1 TO lineCountI
    GotoLine( lineNoI )
    lineS = GetText( 1, 255 )
    FOR charPosI = 1 TO Length( lineS )
      IF SubStr( lineS, charPosI, 1 ) == "0"
        primeI = 3 + 2 * globalIndexI
        PROCAppendRootPrime( primeI )
      ENDIF
      globalIndexI = globalIndexI + 1
    ENDFOR
  ENDFOR
  PopLocation()
  PROCFlushRootPrimes()
  PushLocation()
  GotoBufferId( flagBufferI )
  AbandonFile()
  PopLocation()
END
//
PROC PROCMarkPrimeLine( STRING lineS, STRING startOddS, INTEGER itemCountI )
  STRING tokenS[255] = ""
  INTEGER startI = 1
  INTEGER endI = 0
  INTEGER primeI = 0
  INTEGER remainderI = 0
  INTEGER deltaI = 0
  INTEGER firstIndexI = 0
  WHILE startI <= Length( lineS )
    WHILE ( startI <= Length( lineS ) ) AND ( SubStr( lineS, startI, 1 ) == " " )
      startI = startI + 1
    ENDWHILE
    IF startI <= Length( lineS )
      endI = startI
      WHILE ( endI <= Length( lineS ) ) AND ( SubStr( lineS, endI, 1 ) == " " ) == FALSE
        endI = endI + 1
      ENDWHILE
      tokenS = SubStr( lineS, startI, endI - startI )
      primeI = Val( tokenS )
      remainderI = FNStringModSmallI( startOddS, primeI )
      IF remainderI == 0
        deltaI = 0
      ELSE
        deltaI = primeI - remainderI
      ENDIF
      IF deltaI mod 2 == 1
        deltaI = deltaI + primeI
      ENDIF
      firstIndexI = deltaI / 2
      IF firstIndexI < itemCountI
        PROCMarkComposite( firstIndexI, primeI, itemCountI )
      ENDIF
      startI = endI + 1
    ENDIF
  ENDWHILE
END
//
STRING PROC FNCRTAnswerS( INTEGER residue1I, INTEGER residue2I, INTEGER residue3I, INTEGER residue4I, INTEGER residue5I, INTEGER residue6I )
  STRING answerS[255] = ""
  STRING currentModS[255] = ""
  INTEGER deltaI = 0
  INTEGER tI = 0
  INTEGER invI = 0
  answerS = Format( residue1I )
  currentModS = Format( MOD_1 )
  deltaI = residue2I - FNStringModSmallI( answerS, MOD_2 )
  IF deltaI < 0
    deltaI = deltaI + MOD_2
  ENDIF
  invI = FNModInverseI( FNStringModSmallI( currentModS, MOD_2 ), MOD_2 )
  tI = FNMulModI( deltaI, invI, MOD_2 )
  answerS = FNStringAddS( answerS, FNStringMultiplySmallS( currentModS, tI ) )
  currentModS = FNStringMultiplySmallS( currentModS, MOD_2 )
  deltaI = residue3I - FNStringModSmallI( answerS, MOD_3 )
  IF deltaI < 0
    deltaI = deltaI + MOD_3
  ENDIF
  invI = FNModInverseI( FNStringModSmallI( currentModS, MOD_3 ), MOD_3 )
  tI = FNMulModI( deltaI, invI, MOD_3 )
  answerS = FNStringAddS( answerS, FNStringMultiplySmallS( currentModS, tI ) )
  currentModS = FNStringMultiplySmallS( currentModS, MOD_3 )
  deltaI = residue4I - FNStringModSmallI( answerS, MOD_4 )
  IF deltaI < 0
    deltaI = deltaI + MOD_4
  ENDIF
  invI = FNModInverseI( FNStringModSmallI( currentModS, MOD_4 ), MOD_4 )
  tI = FNMulModI( deltaI, invI, MOD_4 )
  answerS = FNStringAddS( answerS, FNStringMultiplySmallS( currentModS, tI ) )
  currentModS = FNStringMultiplySmallS( currentModS, MOD_4 )
  deltaI = residue5I - FNStringModSmallI( answerS, MOD_5 )
  IF deltaI < 0
    deltaI = deltaI + MOD_5
  ENDIF
  invI = FNModInverseI( FNStringModSmallI( currentModS, MOD_5 ), MOD_5 )
  tI = FNMulModI( deltaI, invI, MOD_5 )
  answerS = FNStringAddS( answerS, FNStringMultiplySmallS( currentModS, tI ) )
  currentModS = FNStringMultiplySmallS( currentModS, MOD_5 )
  deltaI = residue6I - FNStringModSmallI( answerS, MOD_6 )
  IF deltaI < 0
    deltaI = deltaI + MOD_6
  ENDIF
  invI = FNModInverseI( FNStringModSmallI( currentModS, MOD_6 ), MOD_6 )
  tI = FNMulModI( deltaI, invI, MOD_6 )
  answerS = FNStringAddS( answerS, FNStringMultiplySmallS( currentModS, tI ) )
  RETURN( FNTrimLeadingZerosS( answerS ) )
END
//
PROC Main()
  STRING startOddS[255] = "100000000000001"
  STRING startBitsS[255] = ""
  STRING lineS[255] = ""
  STRING answerS[255] = ""
  INTEGER flagBufferI = 0
  INTEGER rootLineCountI = 0
  INTEGER flagLineCountI = 0
  INTEGER lineNoI = 0
  INTEGER charPosI = 0
  INTEGER globalIndexI = 0
  INTEGER foundCountI = 0
  INTEGER odd1I = 0
  INTEGER next1I = 0
  INTEGER odd2I = 0
  INTEGER next2I = 0
  INTEGER odd3I = 0
  INTEGER next3I = 0
  INTEGER odd4I = 0
  INTEGER next4I = 0
  INTEGER odd5I = 0
  INTEGER next5I = 0
  INTEGER odd6I = 0
  INTEGER next6I = 0
  INTEGER tempI = 0
  INTEGER sum1I = 0
  INTEGER sum2I = 0
  INTEGER sum3I = 0
  INTEGER sum4I = 0
  INTEGER sum5I = 0
  INTEGER sum6I = 0
  gRootPrimeBufferGI = CreateTempBuffer()
  PROCBuildRootPrimes()
  PushLocation()
  GotoBufferId( gRootPrimeBufferGI )
  rootLineCountI = NumLines()
  PopLocation()
  startBitsS = FNDecimalToBitsS( startOddS )
  PROCComputeFibPairMod( startBitsS, MOD_1 )
  odd1I = gFibFirstGI
  next1I = gFibSecondGI
  PROCComputeFibPairMod( startBitsS, MOD_2 )
  odd2I = gFibFirstGI
  next2I = gFibSecondGI
  PROCComputeFibPairMod( startBitsS, MOD_3 )
  odd3I = gFibFirstGI
  next3I = gFibSecondGI
  PROCComputeFibPairMod( startBitsS, MOD_4 )
  odd4I = gFibFirstGI
  next4I = gFibSecondGI
  PROCComputeFibPairMod( startBitsS, MOD_5 )
  odd5I = gFibFirstGI
  next5I = gFibSecondGI
  PROCComputeFibPairMod( startBitsS, MOD_6 )
  odd6I = gFibFirstGI
  next6I = gFibSecondGI
  foundCountI = 0
  WHILE foundCountI < TARGET_COUNT
    flagBufferI = CreateTempBuffer()
    PROCInitFlagBuffer( flagBufferI, BIG_BATCH_ODDS )
    PushLocation()
    GotoBufferId( gRootPrimeBufferGI )
    FOR lineNoI = 1 TO rootLineCountI
      GotoLine( lineNoI )
      lineS = GetText( 1, 255 )
      GotoBufferId( flagBufferI )
      PROCMarkPrimeLine( lineS, startOddS, BIG_BATCH_ODDS )
      GotoBufferId( gRootPrimeBufferGI )
    ENDFOR
    PopLocation()
    PushLocation()
    GotoBufferId( flagBufferI )
    flagLineCountI = NumLines()
    globalIndexI = 0
    FOR lineNoI = 1 TO flagLineCountI
      GotoLine( lineNoI )
      lineS = GetText( 1, 255 )
      FOR charPosI = 1 TO Length( lineS )
        IF ( globalIndexI < BIG_BATCH_ODDS ) AND ( foundCountI < TARGET_COUNT )
          IF SubStr( lineS, charPosI, 1 ) == "0"
            sum1I = sum1I + odd1I
            IF sum1I >= MOD_1
              sum1I = sum1I - MOD_1
            ENDIF
            sum2I = sum2I + odd2I
            IF sum2I >= MOD_2
              sum2I = sum2I - MOD_2
            ENDIF
            sum3I = sum3I + odd3I
            IF sum3I >= MOD_3
              sum3I = sum3I - MOD_3
            ENDIF
            sum4I = sum4I + odd4I
            IF sum4I >= MOD_4
              sum4I = sum4I - MOD_4
            ENDIF
            sum5I = sum5I + odd5I
            IF sum5I >= MOD_5
              sum5I = sum5I - MOD_5
            ENDIF
            sum6I = sum6I + odd6I
            IF sum6I >= MOD_6
              sum6I = sum6I - MOD_6
            ENDIF
            foundCountI = foundCountI + 1
          ENDIF
        ENDIF
        IF globalIndexI < BIG_BATCH_ODDS
          tempI = odd1I + next1I
          IF tempI >= MOD_1
            tempI = tempI - MOD_1
          ENDIF
          next1I = tempI + next1I
          IF next1I >= MOD_1
            next1I = next1I - MOD_1
          ENDIF
          odd1I = tempI
          tempI = odd2I + next2I
          IF tempI >= MOD_2
            tempI = tempI - MOD_2
          ENDIF
          next2I = tempI + next2I
          IF next2I >= MOD_2
            next2I = next2I - MOD_2
          ENDIF
          odd2I = tempI
          tempI = odd3I + next3I
          IF tempI >= MOD_3
            tempI = tempI - MOD_3
          ENDIF
          next3I = tempI + next3I
          IF next3I >= MOD_3
            next3I = next3I - MOD_3
          ENDIF
          odd3I = tempI
          tempI = odd4I + next4I
          IF tempI >= MOD_4
            tempI = tempI - MOD_4
          ENDIF
          next4I = tempI + next4I
          IF next4I >= MOD_4
            next4I = next4I - MOD_4
          ENDIF
          odd4I = tempI
          tempI = odd5I + next5I
          IF tempI >= MOD_5
            tempI = tempI - MOD_5
          ENDIF
          next5I = tempI + next5I
          IF next5I >= MOD_5
            next5I = next5I - MOD_5
          ENDIF
          odd5I = tempI
          tempI = odd6I + next6I
          IF tempI >= MOD_6
            tempI = tempI - MOD_6
          ENDIF
          next6I = tempI + next6I
          IF next6I >= MOD_6
            next6I = next6I - MOD_6
          ENDIF
          odd6I = tempI
          globalIndexI = globalIndexI + 1
        ENDIF
      ENDFOR
    ENDFOR
    PopLocation()
    PushLocation()
    GotoBufferId( flagBufferI )
    AbandonFile()
    PopLocation()
    IF foundCountI < TARGET_COUNT
      startOddS = FNStringAddS( startOddS, Format( BIG_BATCH_STEP ) )
    ENDIF
  ENDWHILE
  answerS = FNCRTAnswerS( sum1I, sum2I, sum3I, sum4I, sum5I, sum6I )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
  PushLocation()
  GotoBufferId( gRootPrimeBufferGI )
  AbandonFile()
  PopLocation()
END
