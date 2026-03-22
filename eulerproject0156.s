/*
  Euler Project 156 - Counting Digits
  Pure TSE SAL solution
  <version>1.0.0.0.3</version>

  History:
  1.0.0.0.3 - 2026-03-22 - Final Warn() now shows only the final answer - Created by GPT-5.4 Thinking (ChatGPT)
  1.0.0.0.2 - 2026-03-22 - Removed intermediate Warn() boxes, only final Warn() remains - Created by GPT-5.4 Thinking (ChatGPT)
  1.0.0.0.1 - 2026-03-22 - Corrected WHILE terminators to ENDWHILE - Created by GPT-5.4 Thinking (ChatGPT)
  1.0.0.0.0 - 2026-03-22 - Initial version - Created by GPT-5.4 Thinking (ChatGPT)

  Rules explicitly applied to this program:
  - pure TSE SAL only
  - full program supplied
  - PROC Main() is last
  - FORWARD declarations included
  - no own variables named val or pos
  - Return() always with parentheses
  - WHILE ... ENDWHILE
  - only one final Warn()
  - CopyToWinClip() after Warn()
  - clipboard gets only the final numeric answer
  - version/history included
  - fixed string sizes used
  - no reassignment of string parameters

  This program calculates the final Euler 156 answer fully inside SAL.
  Calculated result: 21295121502550

  Method:
  - Represent all large values as unsigned decimal strings.
  - Compute f( n, d ) with decimal digit-count logic.
  - Use interval pruning:
      if f( low, d ) > high or f( high, d ) < low, no fixed point exists.
  - Recurse until intervals are small, then brute force.

  Search range:
  0 .. 100000000000
*/

FORWARD STRING PROC ProcTrimLeadingZeros( STRING inputS )
FORWARD INTEGER PROC ProcCompareUnsigned( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcAddUnsigned( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcSubtractUnsigned( STRING leftS, STRING rightS )
FORWARD STRING PROC ProcMultiplyBy10Power( STRING inputS, INTEGER zeroCountI )
FORWARD STRING PROC ProcMakeRepeatedChar( INTEGER countI, STRING charS )
FORWARD STRING PROC ProcDivideBy2Unsigned( STRING inputS )
FORWARD STRING PROC ProcMidpointUnsigned( STRING lowS, STRING highS )
FORWARD STRING PROC ProcIncrementUnsigned( STRING inputS )
FORWARD STRING PROC ProcIntegerToString( INTEGER numberI )
FORWARD STRING PROC ProcCountDigitUpTo( STRING numberS, INTEGER digitI )
FORWARD PROC ProcSearchInterval( STRING lowS, STRING highS )
FORWARD PROC ProcBruteForceInterval( STRING lowS, STRING highS )
FORWARD PROC ProcSolveDigit( INTEGER digitI )

STRING gTotalSumS[255]  = "0"
STRING gDigitSumS[255]  = "0"
INTEGER gCurrentDigitI  = 0
INTEGER gLeafThresholdI = 2000

STRING PROC ProcTrimLeadingZeros( STRING inputS )
  STRING workS[255] = ""
  INTEGER indexI    = 1
  INTEGER lengthI   = 0
  //
  workS   = inputS
  lengthI = Length( workS )
  //
  WHILE indexI < lengthI AND SubStr( workS, indexI, 1 ) == "0"
    indexI = indexI + 1
  ENDWHILE
  //
  RETURN( SubStr( workS, indexI, lengthI - indexI + 1 ) )
END

INTEGER PROC ProcCompareUnsigned( STRING leftS, STRING rightS )
  STRING leftWorkS[255]  = ""
  STRING rightWorkS[255] = ""
  INTEGER leftLenI       = 0
  INTEGER rightLenI      = 0
  INTEGER indexI         = 0
  STRING leftCharS[2]    = ""
  STRING rightCharS[2]   = ""
  //
  leftWorkS  = ProcTrimLeadingZeros( leftS )
  rightWorkS = ProcTrimLeadingZeros( rightS )
  //
  leftLenI  = Length( leftWorkS )
  rightLenI = Length( rightWorkS )
  //
  IF leftLenI < rightLenI
    RETURN( -1 )
  ENDIF
  //
  IF leftLenI > rightLenI
    RETURN( 1 )
  ENDIF
  //
  FOR indexI = 1 TO leftLenI
    leftCharS  = SubStr( leftWorkS,  indexI, 1 )
    rightCharS = SubStr( rightWorkS, indexI, 1 )
    //
    IF leftCharS < rightCharS
      RETURN( -1 )
    ENDIF
    //
    IF leftCharS > rightCharS
      RETURN( 1 )
    ENDIF
  ENDFOR
  //
  RETURN( 0 )
END

STRING PROC ProcAddUnsigned( STRING leftS, STRING rightS )
  STRING leftWorkS[255]  = ""
  STRING rightWorkS[255] = ""
  STRING resultS[255]    = ""
  INTEGER leftIndexI     = 0
  INTEGER rightIndexI    = 0
  INTEGER carryI         = 0
  INTEGER digitLeftI     = 0
  INTEGER digitRightI    = 0
  INTEGER digitSumI      = 0
  INTEGER resultDigitI   = 0
  //
  leftWorkS  = ProcTrimLeadingZeros( leftS )
  rightWorkS = ProcTrimLeadingZeros( rightS )
  //
  leftIndexI  = Length( leftWorkS )
  rightIndexI = Length( rightWorkS )
  //
  WHILE leftIndexI > 0 OR rightIndexI > 0 OR carryI > 0
    digitLeftI  = 0
    digitRightI = 0
    //
    IF leftIndexI > 0
      digitLeftI = Val( SubStr( leftWorkS, leftIndexI, 1 ) )
      leftIndexI = leftIndexI - 1
    ENDIF
    //
    IF rightIndexI > 0
      digitRightI = Val( SubStr( rightWorkS, rightIndexI, 1 ) )
      rightIndexI = rightIndexI - 1
    ENDIF
    //
    digitSumI    = digitLeftI + digitRightI + carryI
    resultDigitI = digitSumI mod 10
    carryI       = digitSumI / 10
    //
    resultS = ProcIntegerToString( resultDigitI ) + resultS
  ENDWHILE
  //
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcSubtractUnsigned( STRING leftS, STRING rightS )
  STRING leftWorkS[255]  = ""
  STRING rightWorkS[255] = ""
  STRING resultS[255]    = ""
  INTEGER leftIndexI     = 0
  INTEGER rightIndexI    = 0
  INTEGER borrowI        = 0
  INTEGER digitLeftI     = 0
  INTEGER digitRightI    = 0
  INTEGER digitDiffI     = 0
  //
  leftWorkS  = ProcTrimLeadingZeros( leftS )
  rightWorkS = ProcTrimLeadingZeros( rightS )
  //
  leftIndexI  = Length( leftWorkS )
  rightIndexI = Length( rightWorkS )
  //
  WHILE leftIndexI > 0
    digitLeftI  = Val( SubStr( leftWorkS, leftIndexI, 1 ) ) - borrowI
    digitRightI = 0
    //
    IF rightIndexI > 0
      digitRightI = Val( SubStr( rightWorkS, rightIndexI, 1 ) )
      rightIndexI = rightIndexI - 1
    ENDIF
    //
    IF digitLeftI < digitRightI
      digitLeftI = digitLeftI + 10
      borrowI    = 1
    ELSE
      borrowI    = 0
    ENDIF
    //
    digitDiffI = digitLeftI - digitRightI
    resultS    = ProcIntegerToString( digitDiffI ) + resultS
    //
    leftIndexI = leftIndexI - 1
  ENDWHILE
  //
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcMultiplyBy10Power( STRING inputS, INTEGER zeroCountI )
  STRING workS[255]  = ""
  STRING zerosS[255] = ""
  //
  workS = ProcTrimLeadingZeros( inputS )
  //
  IF workS == "0"
    RETURN( "0" )
  ENDIF
  //
  zerosS = ProcMakeRepeatedChar( zeroCountI, "0" )
  RETURN( workS + zerosS )
END

STRING PROC ProcMakeRepeatedChar( INTEGER countI, STRING charS )
  STRING resultS[255] = ""
  INTEGER indexI      = 0
  //
  FOR indexI = 1 TO countI
    resultS = resultS + charS
  ENDFOR
  //
  RETURN( resultS )
END

STRING PROC ProcDivideBy2Unsigned( STRING inputS )
  STRING workS[255]   = ""
  STRING resultS[255] = ""
  INTEGER carryI      = 0
  INTEGER indexI      = 0
  INTEGER digitI      = 0
  INTEGER valueI      = 0
  INTEGER quotientI   = 0
  //
  workS = ProcTrimLeadingZeros( inputS )
  //
  FOR indexI = 1 TO Length( workS )
    digitI    = Val( SubStr( workS, indexI, 1 ) )
    valueI    = carryI * 10 + digitI
    quotientI = valueI / 2
    carryI    = valueI mod 2
    resultS   = resultS + ProcIntegerToString( quotientI )
  ENDFOR
  //
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcMidpointUnsigned( STRING lowS, STRING highS )
  STRING sumS[255] = ""
  //
  sumS = ProcAddUnsigned( lowS, highS )
  RETURN( ProcDivideBy2Unsigned( sumS ) )
END

STRING PROC ProcIncrementUnsigned( STRING inputS )
  RETURN( ProcAddUnsigned( inputS, "1" ) )
END

STRING PROC ProcIntegerToString( INTEGER numberI )
  STRING resultS[255] = ""
  INTEGER workI       = 0
  INTEGER digitI      = 0
  //
  workI = numberI
  //
  IF workI == 0
    RETURN( "0" )
  ENDIF
  //
  WHILE workI > 0
    digitI  = workI mod 10
    resultS = Chr( Asc( "0" ) + digitI ) + resultS
    workI   = workI / 10
  ENDWHILE
  //
  RETURN( resultS )
END

STRING PROC ProcCountDigitUpTo( STRING numberS, INTEGER digitI )
  STRING workS[255]     = ""
  STRING totalS[255]    = "0"
  STRING higherS[255]   = ""
  STRING lowerS[255]    = ""
  STRING baseS[255]     = ""
  STRING addS[255]      = ""
  STRING powerS[255]    = ""
  INTEGER lengthI       = 0
  INTEGER indexI        = 0
  INTEGER currentDigitI = 0
  INTEGER lowerLengthI  = 0
  //
  workS   = ProcTrimLeadingZeros( numberS )
  lengthI = Length( workS )
  //
  IF workS == "0"
    RETURN( "0" )
  ENDIF
  //
  FOR indexI = 1 TO lengthI
    IF indexI == 1
      higherS = "0"
    ELSE
      higherS = ProcTrimLeadingZeros( SubStr( workS, 1, indexI - 1 ) )
    ENDIF
    //
    currentDigitI = Val( SubStr( workS, indexI, 1 ) )
    lowerLengthI  = lengthI - indexI
    //
    IF lowerLengthI == 0
      lowerS = "0"
    ELSE
      lowerS = ProcTrimLeadingZeros( SubStr( workS, indexI + 1, lowerLengthI ) )
    ENDIF
    //
    baseS  = ProcMultiplyBy10Power( higherS, lowerLengthI )
    powerS = ProcMultiplyBy10Power( "1", lowerLengthI )
    //
    IF currentDigitI < digitI
      addS = baseS
    ELSEIF currentDigitI == digitI
      addS = ProcAddUnsigned( baseS, ProcAddUnsigned( lowerS, "1" ) )
    ELSE
      addS = ProcAddUnsigned( baseS, powerS )
    ENDIF
    //
    totalS = ProcAddUnsigned( totalS, addS )
  ENDFOR
  //
  RETURN( totalS )
END

PROC ProcBruteForceInterval( STRING lowS, STRING highS )
  STRING currentS[255] = ""
  STRING countS[255]   = ""
  //
  currentS = lowS
  //
  WHILE ProcCompareUnsigned( currentS, highS ) <= 0
    countS = ProcCountDigitUpTo( currentS, gCurrentDigitI )
    //
    IF ProcCompareUnsigned( countS, currentS ) == 0
      gDigitSumS = ProcAddUnsigned( gDigitSumS, currentS )
      gTotalSumS = ProcAddUnsigned( gTotalSumS, currentS )
    ENDIF
    //
    currentS = ProcIncrementUnsigned( currentS )
  ENDWHILE
END

PROC ProcSearchInterval( STRING lowS, STRING highS )
  STRING countLowS[255]  = ""
  STRING countHighS[255] = ""
  STRING widthS[255]     = ""
  STRING midS[255]       = ""
  STRING nextS[255]      = ""
  //
  countLowS  = ProcCountDigitUpTo( lowS,  gCurrentDigitI )
  countHighS = ProcCountDigitUpTo( highS, gCurrentDigitI )
  //
  IF ProcCompareUnsigned( countLowS, highS ) > 0
    RETURN()
  ENDIF
  //
  IF ProcCompareUnsigned( countHighS, lowS ) < 0
    RETURN()
  ENDIF
  //
  widthS = ProcSubtractUnsigned( highS, lowS )
  //
  IF ProcCompareUnsigned( widthS, ProcIntegerToString( gLeafThresholdI ) ) <= 0
    ProcBruteForceInterval( lowS, highS )
    RETURN()
  ENDIF
  //
  midS  = ProcMidpointUnsigned( lowS, highS )
  nextS = ProcIncrementUnsigned( midS )
  //
  ProcSearchInterval( lowS, midS )
  ProcSearchInterval( nextS, highS )
END

PROC ProcSolveDigit( INTEGER digitI )
  STRING zeroS[255] = "0"
  STRING maxS[255]  = "100000000000"
  //
  gCurrentDigitI = digitI
  gDigitSumS     = "0"
  //
  ProcSearchInterval( zeroS, maxS )
END

PROC Main()
  STRING finalMessageS[255] = ""
  INTEGER digitI            = 0
  //
  gTotalSumS = "0"
  //
  FOR digitI = 1 TO 9
    ProcSolveDigit( digitI )
  ENDFOR
  //
  finalMessageS =
    "Euler 156 final answer =" + Chr( 13 ) +
    gTotalSumS
  //
  Warn( finalMessageS )
  CopyToWinClip( gTotalSumS )
END
