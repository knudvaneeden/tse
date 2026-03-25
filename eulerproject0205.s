/*
  Euler Project 205
  Pure TSE SAL
  version 1.0.0.0.7

  history:
  - 1.0.0.0.1  created by ChatGPT (GPT-5.4 Thinking)
  - 1.0.0.0.7  replaced fragile big-string arithmetic with exact split-integer accumulation

  Calculates:
  Probability that Peter (9d4) beats Colin (6d6),
  rounded to seven decimal places.
*/
FORWARD STRING PROC ProcIntegerToString( INTEGER numberI )
FORWARD STRING PROC ProcPadLeftZeros( STRING numberS, INTEGER widthI )
FORWARD STRING PROC ProcRound8DigitsToSevenDecimals( STRING digits8S )
FORWARD STRING PROC ProcFractionToSevenDecimals( INTEGER numeratorI, INTEGER denominatorI )
FORWARD INTEGER PROC ProcCombination( INTEGER nI, INTEGER kI )
FORWARD INTEGER PROC ProcDiceWays( INTEGER diceCountI, INTEGER sidesCountI, INTEGER sumI )

STRING PROC ProcIntegerToString( INTEGER numberI )
 STRING resultS[255] = ""
 INTEGER workI       = 0
 INTEGER digitI      = 0
 //
 IF numberI == 0
  RETURN( "0" )
 ENDIF
 workI   = numberI
 resultS = ""
 WHILE workI > 0
  digitI  = workI mod 10
  resultS = Chr( 48 + digitI ) + resultS
  workI   = workI / 10
 ENDWHILE
 RETURN( resultS )
END

STRING PROC ProcPadLeftZeros( STRING numberS, INTEGER widthI )
 STRING workS[255] = ""
 //
 workS = numberS
 WHILE Length( workS ) < widthI
  workS = "0" + workS
 ENDWHILE
 RETURN( workS )
END

STRING PROC ProcRound8DigitsToSevenDecimals( STRING digits8S )
 STRING workS[255]      = ""
 STRING first7S[255]    = ""
 STRING lastDigitS[255] = ""
 STRING finalS[255]     = ""
 INTEGER first7I        = 0
 INTEGER lastDigitI     = 0
 //
 workS      = ProcPadLeftZeros( digits8S, 8 )
 first7S    = workS[1:7]
 lastDigitS = workS[8:8]
 first7I    = Val( first7S )
 lastDigitI = Val( lastDigitS )
 IF lastDigitI >= 5
  first7I = first7I + 1
 ENDIF
 IF first7I >= 10000000
  RETURN( "1.0000000" )
 ENDIF
 finalS = "0." + ProcPadLeftZeros( ProcIntegerToString( first7I ), 7 )
 RETURN( finalS )
END

STRING PROC ProcFractionToSevenDecimals( INTEGER numeratorI, INTEGER denominatorI )
 STRING digits8S[255] = ""
 STRING finalS[255]   = ""
 INTEGER remainderI   = 0
 INTEGER digitI       = 0
 INTEGER indexI       = 0
 //
 remainderI = numeratorI
 digits8S   = ""
 FOR indexI = 1 TO 8
  remainderI = remainderI * 10
  digitI     = remainderI / denominatorI
  remainderI = remainderI mod denominatorI
  digits8S   = digits8S + Chr( 48 + digitI )
 ENDFOR
 finalS = ProcRound8DigitsToSevenDecimals( digits8S )
 RETURN( finalS )
END

INTEGER PROC ProcCombination( INTEGER nI, INTEGER kI )
 INTEGER useKI   = 0
 INTEGER stepI   = 0
 INTEGER resultI = 1
 //
 IF kI < 0
  RETURN( 0 )
 ENDIF
 IF kI > nI
  RETURN( 0 )
 ENDIF
 useKI = kI
 IF useKI > ( nI - useKI )
  useKI = nI - useKI
 ENDIF
 IF useKI == 0
  RETURN( 1 )
 ENDIF
 resultI = 1
 FOR stepI = 1 TO useKI
  resultI = ( resultI * ( nI - useKI + stepI ) ) / stepI
 ENDFOR
 RETURN( resultI )
END

INTEGER PROC ProcDiceWays( INTEGER diceCountI, INTEGER sidesCountI, INTEGER sumI )
 INTEGER upperI       = 0
 INTEGER indexI       = 0
 INTEGER signI        = 0
 INTEGER chooseDiceI  = 0
 INTEGER chooseStarsI = 0
 INTEGER termI        = 0
 INTEGER waysI        = 0
 INTEGER reducedI     = 0
 //
 IF sumI < diceCountI
  RETURN( 0 )
 ENDIF
 IF sumI > ( diceCountI * sidesCountI )
  RETURN( 0 )
 ENDIF
 upperI = ( sumI - diceCountI ) / sidesCountI
 waysI  = 0
 FOR indexI = 0 TO upperI
  chooseDiceI  = ProcCombination( diceCountI, indexI )
  reducedI     = sumI - ( indexI * sidesCountI ) - 1
  chooseStarsI = ProcCombination( reducedI, diceCountI - 1 )
  termI        = chooseDiceI * chooseStarsI
  signI        = indexI mod 2
  IF signI == 0
   waysI = waysI + termI
  ELSE
   waysI = waysI - termI
  ENDIF
 ENDFOR
 RETURN( waysI )
END

PROC Main()
 INTEGER BASE_I                = 10000
 INTEGER REDUCE_I              = 144
 INTEGER peterSumI             = 0
 INTEGER colinSumI             = 0
 INTEGER peterWaysI            = 0
 INTEGER colinWaysI            = 0
 INTEGER colinLessI            = 0
 INTEGER totalPeterI           = 0
 INTEGER totalColinI           = 0
 INTEGER termI                 = 0
 INTEGER winningHighI          = 0
 INTEGER winningLowI           = 0
 INTEGER denominatorHighI      = 0
 INTEGER denominatorLowI       = 0
 INTEGER addCountI             = 0
 INTEGER qHighI                = 0
 INTEGER qLowI                 = 0
 INTEGER remainderHighI        = 0
 INTEGER combinedI             = 0
 INTEGER reducedNumeratorI     = 0
 INTEGER reducedDenominatorI   = 0
 STRING finalAnswerS[255]      = ""
 //
 totalPeterI = 0
 FOR peterSumI = 9 TO 36
  totalPeterI = totalPeterI + ProcDiceWays( 9, 4, peterSumI )
 ENDFOR
 //
 totalColinI = 0
 FOR colinSumI = 6 TO 36
  totalColinI = totalColinI + ProcDiceWays( 6, 6, colinSumI )
 ENDFOR
 //
 winningHighI = 0
 winningLowI  = 0
 FOR peterSumI = 9 TO 36
  peterWaysI = ProcDiceWays( 9, 4, peterSumI )
  colinLessI = 0
  FOR colinSumI = 6 TO ( peterSumI - 1 )
   colinWaysI = ProcDiceWays( 6, 6, colinSumI )
   colinLessI = colinLessI + colinWaysI
  ENDFOR
  termI        = peterWaysI * colinLessI
  winningLowI  = winningLowI + termI
  winningHighI = winningHighI + ( winningLowI / BASE_I )
  winningLowI  = winningLowI mod BASE_I
 ENDFOR
 //
 denominatorHighI = 0
 denominatorLowI  = 0
 FOR addCountI = 1 TO totalColinI
  denominatorLowI  = denominatorLowI + totalPeterI
  denominatorHighI = denominatorHighI + ( denominatorLowI / BASE_I )
  denominatorLowI  = denominatorLowI mod BASE_I
 ENDFOR
 //
 qHighI            = winningHighI / REDUCE_I
 remainderHighI    = winningHighI mod REDUCE_I
 combinedI         = ( remainderHighI * BASE_I ) + winningLowI
 qLowI             = combinedI / REDUCE_I
 reducedNumeratorI = ( qHighI * BASE_I ) + qLowI
 //
 qHighI              = denominatorHighI / REDUCE_I
 remainderHighI      = denominatorHighI mod REDUCE_I
 combinedI           = ( remainderHighI * BASE_I ) + denominatorLowI
 qLowI               = combinedI / REDUCE_I
 reducedDenominatorI = ( qHighI * BASE_I ) + qLowI
 //
 finalAnswerS = ProcFractionToSevenDecimals( reducedNumeratorI, reducedDenominatorI )
 //
 CopyToWinClip( finalAnswerS )
 Warn( finalAnswerS )
 CopyToWinClip( finalAnswerS )
END
