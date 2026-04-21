// Problem 305 - Reflexive Position
// <version>10</version>
// History:
// 1 - Created by ChatGPT for TSE SAL Euler problem 305
// 2 - Fixed warning 1014 by rewriting FNBigModSmallI without an unused local
// 3 - Fixed CASE setter OTHERWISE branches
// 4 - Reworked again from uploaded Python algorithm structure
// 5 - Replaced comment-only OTHERWISE branches in setter procedures by return()
// 6 - Replaced mutating PROC setter CASE blocks with IF chains
// 7 - Removed all early return() statements from mutating PROC setters
// 8 - Added debugging trace buffer for setup/sample/binary-search diagnostics
// 9 - Fixed unstable temporary string argument passing by first copying into
//     local string variables before calling long-running string-parameter code
// 10 - Removed debugging trace code after verified correct result
//      Creator: ChatGPT
//
// Final output:
// - One final Warn() box with only the numeric answer
// - CopyToWinClip() before and after Warn()

#DEFINE MAX_DIGITS         20
#DEFINE ARRAY_CT           1
#DEFINE ARRAY_MT           2
#DEFINE ARRAY_CL           3
#DEFINE ARRAY_ML           4
#DEFINE ARRAY_NEW_CT       5
#DEFINE ARRAY_NEW_MT       6
#DEFINE ARRAY_NEW_CL       7
#DEFINE ARRAY_NEW_ML       8

FORWARD STRING PROC FNTrimLeadingZerosS( STRING numberS )
FORWARD INTEGER PROC FNBigCmpI( STRING leftS, STRING rightS )
FORWARD STRING PROC FNBigAddS( STRING leftS, STRING rightS )
FORWARD STRING PROC FNBigSubS( STRING leftS, STRING rightS )
FORWARD STRING PROC FNBigMulSmallS( STRING numberS, INTEGER factorI )
FORWARD STRING PROC FNBigDivSmallS( STRING numberS, INTEGER divisorI )
FORWARD INTEGER PROC FNBigModSmallI( STRING numberS, INTEGER divisorI )
FORWARD STRING PROC FNBigAddSmallS( STRING numberS, INTEGER addI )
FORWARD STRING PROC FNBigSubSmallS( STRING numberS, INTEGER subI )
FORWARD STRING PROC FNPower10S( INTEGER exponentI )
FORWARD INTEGER PROC FNPower10I( INTEGER exponentI )
FORWARD STRING PROC FNRepeatCharS( STRING charS, INTEGER countI )
FORWARD STRING PROC FNIntTimesPower10S( INTEGER valueI, INTEGER zerosI )
FORWARD STRING PROC FNBigMinS( STRING leftS, STRING rightS )
FORWARD STRING PROC FNBigMaxS( STRING leftS, STRING rightS )

FORWARD PROC ProcClearPi()
FORWARD INTEGER PROC FNGetPiI( INTEGER indexI )
FORWARD PROC ProcSetPi( INTEGER indexI, INTEGER valueI )

FORWARD INTEGER PROC FNPatternDigitI( INTEGER indexI )
FORWARD PROC ProcSetTransitionLine( INTEGER slotI, STRING nextLineS, STRING incLineS )
FORWARD INTEGER PROC FNTransitionNextI( INTEGER stateI, INTEGER digitI )
FORWARD INTEGER PROC FNTransitionIncI( INTEGER stateI, INTEGER digitI )

FORWARD STRING PROC FNGetArrayValueS( INTEGER arrayIdI, INTEGER indexI )
FORWARD PROC ProcSetArrayValue( INTEGER arrayIdI, INTEGER indexI, STRING valueS )
FORWARD PROC ProcClearArray( INTEGER arrayIdI, INTEGER countI )
FORWARD PROC ProcCopyArray( INTEGER fromArrayI, INTEGER toArrayI, INTEGER countI )
FORWARD PROC ProcAddArrayValue( INTEGER arrayIdI, INTEGER indexI, STRING addS )
FORWARD STRING PROC FNArraySumS( INTEGER arrayIdI, INTEGER countI )

FORWARD STRING PROC FNGetInternalLenS( INTEGER indexI )
FORWARD PROC ProcSetInternalLen( INTEGER indexI, STRING valueS )

FORWARD PROC ProcBuildPrefixAndTransitions()
FORWARD PROC ProcBuildBruteCounts( INTEGER uptoI )
FORWARD STRING PROC FNBruteCountS( INTEGER numberI )
FORWARD PROC ProcPrecomputeInternalLens()

FORWARD STRING PROC FNInternalUptoS( STRING numberS )
FORWARD STRING PROC FNCountArithProgressionS( STRING lowS, STRING highS, INTEGER modI, INTEGER remainderI )
FORWARD STRING PROC FNBoundaryUptoS( STRING numberS )
FORWARD STRING PROC FNCountFullConcatS( STRING numberS )
FORWARD STRING PROC FNTailDigitsS( STRING numberS, INTEGER needI )
FORWARD STRING PROC FNPrefixToNS( STRING prefixS )
FORWARD STRING PROC FNCountMatchesInPrefixS( STRING prefixS )
FORWARD STRING PROC FNCountStartsLeqS( STRING startS )
FORWARD STRING PROC FNFindNthOccurrenceS( STRING targetS )

FORWARD PROC ProcSetupPattern( STRING patternS )
FORWARD STRING PROC FNComputeFS( INTEGER numberI )
FORWARD STRING PROC FNSolveS()

INTEGER gBruteBufferGI = 0
INTEGER gPatternLengthGI = 0
INTEGER gBruteLimitGI = 0
INTEGER gDivRemainderGI = 0
INTEGER gPrefixRemainderGI = 0

STRING gPatternGS[255] = ""
STRING gBruteAGS[255] = "0"
STRING gInternalAGS[255] = "0"
STRING gBoundaryAGS[255] = "0"

INTEGER gPi1GI = 0
INTEGER gPi2GI = 0
INTEGER gPi3GI = 0
INTEGER gPi4GI = 0
INTEGER gPi5GI = 0
INTEGER gPi6GI = 0
INTEGER gPi7GI = 0

STRING gNextLine1GS[255] = ""
STRING gNextLine2GS[255] = ""
STRING gNextLine3GS[255] = ""
STRING gNextLine4GS[255] = ""
STRING gNextLine5GS[255] = ""
STRING gNextLine6GS[255] = ""
STRING gNextLine7GS[255] = ""

STRING gIncLine1GS[255] = ""
STRING gIncLine2GS[255] = ""
STRING gIncLine3GS[255] = ""
STRING gIncLine4GS[255] = ""
STRING gIncLine5GS[255] = ""
STRING gIncLine6GS[255] = ""
STRING gIncLine7GS[255] = ""

STRING gInternalLen01GS[255] = "0"
STRING gInternalLen02GS[255] = "0"
STRING gInternalLen03GS[255] = "0"
STRING gInternalLen04GS[255] = "0"
STRING gInternalLen05GS[255] = "0"
STRING gInternalLen06GS[255] = "0"
STRING gInternalLen07GS[255] = "0"
STRING gInternalLen08GS[255] = "0"
STRING gInternalLen09GS[255] = "0"
STRING gInternalLen10GS[255] = "0"
STRING gInternalLen11GS[255] = "0"
STRING gInternalLen12GS[255] = "0"
STRING gInternalLen13GS[255] = "0"
STRING gInternalLen14GS[255] = "0"
STRING gInternalLen15GS[255] = "0"
STRING gInternalLen16GS[255] = "0"
STRING gInternalLen17GS[255] = "0"
STRING gInternalLen18GS[255] = "0"
STRING gInternalLen19GS[255] = "0"
STRING gInternalLen20GS[255] = "0"

STRING gCt1GS[255] = "0"
STRING gCt2GS[255] = "0"
STRING gCt3GS[255] = "0"
STRING gCt4GS[255] = "0"
STRING gCt5GS[255] = "0"
STRING gCt6GS[255] = "0"
STRING gCt7GS[255] = "0"

STRING gMt1GS[255] = "0"
STRING gMt2GS[255] = "0"
STRING gMt3GS[255] = "0"
STRING gMt4GS[255] = "0"
STRING gMt5GS[255] = "0"
STRING gMt6GS[255] = "0"
STRING gMt7GS[255] = "0"

STRING gCl1GS[255] = "0"
STRING gCl2GS[255] = "0"
STRING gCl3GS[255] = "0"
STRING gCl4GS[255] = "0"
STRING gCl5GS[255] = "0"
STRING gCl6GS[255] = "0"
STRING gCl7GS[255] = "0"

STRING gMl1GS[255] = "0"
STRING gMl2GS[255] = "0"
STRING gMl3GS[255] = "0"
STRING gMl4GS[255] = "0"
STRING gMl5GS[255] = "0"
STRING gMl6GS[255] = "0"
STRING gMl7GS[255] = "0"

STRING gNewCt1GS[255] = "0"
STRING gNewCt2GS[255] = "0"
STRING gNewCt3GS[255] = "0"
STRING gNewCt4GS[255] = "0"
STRING gNewCt5GS[255] = "0"
STRING gNewCt6GS[255] = "0"
STRING gNewCt7GS[255] = "0"

STRING gNewMt1GS[255] = "0"
STRING gNewMt2GS[255] = "0"
STRING gNewMt3GS[255] = "0"
STRING gNewMt4GS[255] = "0"
STRING gNewMt5GS[255] = "0"
STRING gNewMt6GS[255] = "0"
STRING gNewMt7GS[255] = "0"

STRING gNewCl1GS[255] = "0"
STRING gNewCl2GS[255] = "0"
STRING gNewCl3GS[255] = "0"
STRING gNewCl4GS[255] = "0"
STRING gNewCl5GS[255] = "0"
STRING gNewCl6GS[255] = "0"
STRING gNewCl7GS[255] = "0"

STRING gNewMl1GS[255] = "0"
STRING gNewMl2GS[255] = "0"
STRING gNewMl3GS[255] = "0"
STRING gNewMl4GS[255] = "0"
STRING gNewMl5GS[255] = "0"
STRING gNewMl6GS[255] = "0"
STRING gNewMl7GS[255] = "0"

STRING PROC FNTrimLeadingZerosS( STRING numberS )
 STRING workS[255] = ""
 INTEGER indexI = 1
 //
 workS = numberS
 WHILE ( indexI < Length( workS ) ) AND ( SubStr( workS, indexI, 1 ) == "0" )
  indexI = indexI + 1
 ENDWHILE
 return( SubStr( workS, indexI, Length( workS ) - indexI + 1 ) )
END

INTEGER PROC FNBigCmpI( STRING leftS, STRING rightS )
 STRING leftWorkS[255] = ""
 STRING rightWorkS[255] = ""
 INTEGER indexI = 0
 //
 leftWorkS  = FNTrimLeadingZerosS( leftS )
 rightWorkS = FNTrimLeadingZerosS( rightS )
 IF Length( leftWorkS ) < Length( rightWorkS )
  return( -1 )
 ENDIF
 IF Length( leftWorkS ) > Length( rightWorkS )
  return( 1 )
 ENDIF
 FOR indexI = 1 TO Length( leftWorkS )
  IF SubStr( leftWorkS, indexI, 1 ) < SubStr( rightWorkS, indexI, 1 )
   return( -1 )
  ENDIF
  IF SubStr( leftWorkS, indexI, 1 ) > SubStr( rightWorkS, indexI, 1 )
   return( 1 )
  ENDIF
 ENDFOR
 return( 0 )
END

STRING PROC FNBigAddS( STRING leftS, STRING rightS )
 STRING leftWorkS[255] = ""
 STRING rightWorkS[255] = ""
 STRING resultS[255] = ""
 INTEGER leftIndexI = 0
 INTEGER rightIndexI = 0
 INTEGER carryI = 0
 INTEGER digitI = 0
 INTEGER sumI = 0
 //
 leftWorkS  = FNTrimLeadingZerosS( leftS )
 rightWorkS = FNTrimLeadingZerosS( rightS )
 leftIndexI  = Length( leftWorkS )
 rightIndexI = Length( rightWorkS )
 WHILE ( leftIndexI > 0 ) OR ( rightIndexI > 0 ) OR ( carryI > 0 )
  sumI = carryI
  IF leftIndexI > 0
   sumI = sumI + Val( SubStr( leftWorkS, leftIndexI, 1 ) )
   leftIndexI = leftIndexI - 1
  ENDIF
  IF rightIndexI > 0
   sumI = sumI + Val( SubStr( rightWorkS, rightIndexI, 1 ) )
   rightIndexI = rightIndexI - 1
  ENDIF
  digitI = sumI mod 10
  carryI = sumI / 10
  resultS = Chr( digitI + 48 ) + resultS
 ENDWHILE
 return( FNTrimLeadingZerosS( resultS ) )
END

STRING PROC FNBigSubS( STRING leftS, STRING rightS )
 STRING leftWorkS[255] = ""
 STRING rightWorkS[255] = ""
 STRING resultS[255] = ""
 INTEGER leftIndexI = 0
 INTEGER rightIndexI = 0
 INTEGER borrowI = 0
 INTEGER leftDigitI = 0
 INTEGER rightDigitI = 0
 INTEGER digitI = 0
 //
 leftWorkS  = FNTrimLeadingZerosS( leftS )
 rightWorkS = FNTrimLeadingZerosS( rightS )
 leftIndexI  = Length( leftWorkS )
 rightIndexI = Length( rightWorkS )
 WHILE leftIndexI > 0
  leftDigitI = Val( SubStr( leftWorkS, leftIndexI, 1 ) ) - borrowI
  rightDigitI = 0
  IF rightIndexI > 0
   rightDigitI = Val( SubStr( rightWorkS, rightIndexI, 1 ) )
   rightIndexI = rightIndexI - 1
  ENDIF
  IF leftDigitI < rightDigitI
   leftDigitI = leftDigitI + 10
   borrowI = 1
  ELSE
   borrowI = 0
  ENDIF
  digitI = leftDigitI - rightDigitI
  resultS = Chr( digitI + 48 ) + resultS
  leftIndexI = leftIndexI - 1
 ENDWHILE
 return( FNTrimLeadingZerosS( resultS ) )
END

STRING PROC FNBigMulSmallS( STRING numberS, INTEGER factorI )
 STRING workS[255] = ""
 STRING resultS[255] = ""
 INTEGER indexI = 0
 INTEGER carryI = 0
 INTEGER valueI = 0
 INTEGER digitI = 0
 //
 IF factorI == 0
  return( "0" )
 ENDIF
 IF factorI == 1
  return( FNTrimLeadingZerosS( numberS ) )
 ENDIF
 workS = FNTrimLeadingZerosS( numberS )
 indexI = Length( workS )
 WHILE indexI > 0
  valueI = Val( SubStr( workS, indexI, 1 ) ) * factorI + carryI
  digitI = valueI mod 10
  carryI = valueI / 10
  resultS = Chr( digitI + 48 ) + resultS
  indexI = indexI - 1
 ENDWHILE
 WHILE carryI > 0
  digitI = carryI mod 10
  carryI = carryI / 10
  resultS = Chr( digitI + 48 ) + resultS
 ENDWHILE
 return( FNTrimLeadingZerosS( resultS ) )
END

STRING PROC FNBigDivSmallS( STRING numberS, INTEGER divisorI )
 STRING workS[255] = ""
 STRING resultS[255] = ""
 INTEGER indexI = 0
 INTEGER currentI = 0
 INTEGER quotientDigitI = 0
 INTEGER startedB = FALSE
 //
 workS = FNTrimLeadingZerosS( numberS )
 gDivRemainderGI = 0
 FOR indexI = 1 TO Length( workS )
  currentI = gDivRemainderGI * 10 + Val( SubStr( workS, indexI, 1 ) )
  quotientDigitI = currentI / divisorI
  gDivRemainderGI = currentI mod divisorI
  IF ( quotientDigitI > 0 ) OR startedB
   resultS = resultS + Chr( quotientDigitI + 48 )
   startedB = TRUE
  ENDIF
 ENDFOR
 IF resultS == ""
  resultS = "0"
 ENDIF
 return( resultS )
END

INTEGER PROC FNBigModSmallI( STRING numberS, INTEGER divisorI )
 STRING workS[255] = ""
 INTEGER indexI = 0
 INTEGER remainderI = 0
 //
 workS = FNTrimLeadingZerosS( numberS )
 FOR indexI = 1 TO Length( workS )
  remainderI = ( remainderI * 10 + Val( SubStr( workS, indexI, 1 ) ) ) mod divisorI
 ENDFOR
 return( remainderI )
END

STRING PROC FNBigAddSmallS( STRING numberS, INTEGER addI )
 return( FNBigAddS( numberS, Format( addI ) ) )
END

STRING PROC FNBigSubSmallS( STRING numberS, INTEGER subI )
 return( FNBigSubS( numberS, Format( subI ) ) )
END

STRING PROC FNPower10S( INTEGER exponentI )
 STRING resultS[255] = "1"
 INTEGER indexI = 0
 //
 FOR indexI = 1 TO exponentI
  resultS = resultS + "0"
 ENDFOR
 return( resultS )
END

INTEGER PROC FNPower10I( INTEGER exponentI )
 INTEGER resultI = 1
 INTEGER indexI = 0
 //
 FOR indexI = 1 TO exponentI
  resultI = resultI * 10
 ENDFOR
 return( resultI )
END

STRING PROC FNRepeatCharS( STRING charS, INTEGER countI )
 STRING resultS[255] = ""
 INTEGER indexI = 0
 //
 FOR indexI = 1 TO countI
  resultS = resultS + charS
 ENDFOR
 return( resultS )
END

STRING PROC FNIntTimesPower10S( INTEGER valueI, INTEGER zerosI )
 IF valueI == 0
  return( "0" )
 ENDIF
 return( Format( valueI ) + FNRepeatCharS( "0", zerosI ) )
END

STRING PROC FNBigMinS( STRING leftS, STRING rightS )
 IF FNBigCmpI( leftS, rightS ) <= 0
  return( leftS )
 ENDIF
 return( rightS )
END

STRING PROC FNBigMaxS( STRING leftS, STRING rightS )
 IF FNBigCmpI( leftS, rightS ) >= 0
  return( leftS )
 ENDIF
 return( rightS )
END

PROC ProcClearPi()
 gPi1GI = 0
 gPi2GI = 0
 gPi3GI = 0
 gPi4GI = 0
 gPi5GI = 0
 gPi6GI = 0
 gPi7GI = 0
END

INTEGER PROC FNGetPiI( INTEGER indexI )
 CASE indexI
  WHEN 1
   return( gPi1GI )
  WHEN 2
   return( gPi2GI )
  WHEN 3
   return( gPi3GI )
  WHEN 4
   return( gPi4GI )
  WHEN 5
   return( gPi5GI )
  WHEN 6
   return( gPi6GI )
  WHEN 7
   return( gPi7GI )
  OTHERWISE
   return( 0 )
 ENDCASE
END

PROC ProcSetPi( INTEGER indexI, INTEGER valueI )
 IF indexI == 1
  gPi1GI = valueI
 ENDIF
 IF indexI == 2
  gPi2GI = valueI
 ENDIF
 IF indexI == 3
  gPi3GI = valueI
 ENDIF
 IF indexI == 4
  gPi4GI = valueI
 ENDIF
 IF indexI == 5
  gPi5GI = valueI
 ENDIF
 IF indexI == 6
  gPi6GI = valueI
 ENDIF
 IF indexI == 7
  gPi7GI = valueI
 ENDIF
END

INTEGER PROC FNPatternDigitI( INTEGER indexI )
 return( Val( SubStr( gPatternGS, indexI, 1 ) ) )
END

PROC ProcSetTransitionLine( INTEGER slotI, STRING nextLineS, STRING incLineS )
 IF slotI == 1
  gNextLine1GS = nextLineS
  gIncLine1GS  = incLineS
 ENDIF
 IF slotI == 2
  gNextLine2GS = nextLineS
  gIncLine2GS  = incLineS
 ENDIF
 IF slotI == 3
  gNextLine3GS = nextLineS
  gIncLine3GS  = incLineS
 ENDIF
 IF slotI == 4
  gNextLine4GS = nextLineS
  gIncLine4GS  = incLineS
 ENDIF
 IF slotI == 5
  gNextLine5GS = nextLineS
  gIncLine5GS  = incLineS
 ENDIF
 IF slotI == 6
  gNextLine6GS = nextLineS
  gIncLine6GS  = incLineS
 ENDIF
 IF slotI == 7
  gNextLine7GS = nextLineS
  gIncLine7GS  = incLineS
 ENDIF
END

INTEGER PROC FNTransitionNextI( INTEGER stateI, INTEGER digitI )
 STRING lineS[255] = ""
 //
 CASE stateI + 1
  WHEN 1
   lineS = gNextLine1GS
  WHEN 2
   lineS = gNextLine2GS
  WHEN 3
   lineS = gNextLine3GS
  WHEN 4
   lineS = gNextLine4GS
  WHEN 5
   lineS = gNextLine5GS
  WHEN 6
   lineS = gNextLine6GS
  WHEN 7
   lineS = gNextLine7GS
  OTHERWISE
   lineS = "0000000000"
 ENDCASE
 return( Val( SubStr( lineS, digitI + 1, 1 ) ) )
END

INTEGER PROC FNTransitionIncI( INTEGER stateI, INTEGER digitI )
 STRING lineS[255] = ""
 //
 CASE stateI + 1
  WHEN 1
   lineS = gIncLine1GS
  WHEN 2
   lineS = gIncLine2GS
  WHEN 3
   lineS = gIncLine3GS
  WHEN 4
   lineS = gIncLine4GS
  WHEN 5
   lineS = gIncLine5GS
  WHEN 6
   lineS = gIncLine6GS
  WHEN 7
   lineS = gIncLine7GS
  OTHERWISE
   lineS = "0000000000"
 ENDCASE
 return( Val( SubStr( lineS, digitI + 1, 1 ) ) )
END

STRING PROC FNGetArrayValueS( INTEGER arrayIdI, INTEGER indexI )
 INTEGER keyI = 0
 //
 keyI = arrayIdI * 10 + indexI
 CASE keyI
  WHEN 11
   return( gCt1GS )
  WHEN 12
   return( gCt2GS )
  WHEN 13
   return( gCt3GS )
  WHEN 14
   return( gCt4GS )
  WHEN 15
   return( gCt5GS )
  WHEN 16
   return( gCt6GS )
  WHEN 17
   return( gCt7GS )
  WHEN 21
   return( gMt1GS )
  WHEN 22
   return( gMt2GS )
  WHEN 23
   return( gMt3GS )
  WHEN 24
   return( gMt4GS )
  WHEN 25
   return( gMt5GS )
  WHEN 26
   return( gMt6GS )
  WHEN 27
   return( gMt7GS )
  WHEN 31
   return( gCl1GS )
  WHEN 32
   return( gCl2GS )
  WHEN 33
   return( gCl3GS )
  WHEN 34
   return( gCl4GS )
  WHEN 35
   return( gCl5GS )
  WHEN 36
   return( gCl6GS )
  WHEN 37
   return( gCl7GS )
  WHEN 41
   return( gMl1GS )
  WHEN 42
   return( gMl2GS )
  WHEN 43
   return( gMl3GS )
  WHEN 44
   return( gMl4GS )
  WHEN 45
   return( gMl5GS )
  WHEN 46
   return( gMl6GS )
  WHEN 47
   return( gMl7GS )
  WHEN 51
   return( gNewCt1GS )
  WHEN 52
   return( gNewCt2GS )
  WHEN 53
   return( gNewCt3GS )
  WHEN 54
   return( gNewCt4GS )
  WHEN 55
   return( gNewCt5GS )
  WHEN 56
   return( gNewCt6GS )
  WHEN 57
   return( gNewCt7GS )
  WHEN 61
   return( gNewMt1GS )
  WHEN 62
   return( gNewMt2GS )
  WHEN 63
   return( gNewMt3GS )
  WHEN 64
   return( gNewMt4GS )
  WHEN 65
   return( gNewMt5GS )
  WHEN 66
   return( gNewMt6GS )
  WHEN 67
   return( gNewMt7GS )
  WHEN 71
   return( gNewCl1GS )
  WHEN 72
   return( gNewCl2GS )
  WHEN 73
   return( gNewCl3GS )
  WHEN 74
   return( gNewCl4GS )
  WHEN 75
   return( gNewCl5GS )
  WHEN 76
   return( gNewCl6GS )
  WHEN 77
   return( gNewCl7GS )
  WHEN 81
   return( gNewMl1GS )
  WHEN 82
   return( gNewMl2GS )
  WHEN 83
   return( gNewMl3GS )
  WHEN 84
   return( gNewMl4GS )
  WHEN 85
   return( gNewMl5GS )
  WHEN 86
   return( gNewMl6GS )
  WHEN 87
   return( gNewMl7GS )
  OTHERWISE
   return( "0" )
 ENDCASE
END

PROC ProcSetArrayValue( INTEGER arrayIdI, INTEGER indexI, STRING valueS )
 INTEGER keyI = 0
 //
 keyI = arrayIdI * 10 + indexI
 IF keyI == 11
  gCt1GS = valueS
 ENDIF
 IF keyI == 12
  gCt2GS = valueS
 ENDIF
 IF keyI == 13
  gCt3GS = valueS
 ENDIF
 IF keyI == 14
  gCt4GS = valueS
 ENDIF
 IF keyI == 15
  gCt5GS = valueS
 ENDIF
 IF keyI == 16
  gCt6GS = valueS
 ENDIF
 IF keyI == 17
  gCt7GS = valueS
 ENDIF
 IF keyI == 21
  gMt1GS = valueS
 ENDIF
 IF keyI == 22
  gMt2GS = valueS
 ENDIF
 IF keyI == 23
  gMt3GS = valueS
 ENDIF
 IF keyI == 24
  gMt4GS = valueS
 ENDIF
 IF keyI == 25
  gMt5GS = valueS
 ENDIF
 IF keyI == 26
  gMt6GS = valueS
 ENDIF
 IF keyI == 27
  gMt7GS = valueS
 ENDIF
 IF keyI == 31
  gCl1GS = valueS
 ENDIF
 IF keyI == 32
  gCl2GS = valueS
 ENDIF
 IF keyI == 33
  gCl3GS = valueS
 ENDIF
 IF keyI == 34
  gCl4GS = valueS
 ENDIF
 IF keyI == 35
  gCl5GS = valueS
 ENDIF
 IF keyI == 36
  gCl6GS = valueS
 ENDIF
 IF keyI == 37
  gCl7GS = valueS
 ENDIF
 IF keyI == 41
  gMl1GS = valueS
 ENDIF
 IF keyI == 42
  gMl2GS = valueS
 ENDIF
 IF keyI == 43
  gMl3GS = valueS
 ENDIF
 IF keyI == 44
  gMl4GS = valueS
 ENDIF
 IF keyI == 45
  gMl5GS = valueS
 ENDIF
 IF keyI == 46
  gMl6GS = valueS
 ENDIF
 IF keyI == 47
  gMl7GS = valueS
 ENDIF
 IF keyI == 51
  gNewCt1GS = valueS
 ENDIF
 IF keyI == 52
  gNewCt2GS = valueS
 ENDIF
 IF keyI == 53
  gNewCt3GS = valueS
 ENDIF
 IF keyI == 54
  gNewCt4GS = valueS
 ENDIF
 IF keyI == 55
  gNewCt5GS = valueS
 ENDIF
 IF keyI == 56
  gNewCt6GS = valueS
 ENDIF
 IF keyI == 57
  gNewCt7GS = valueS
 ENDIF
 IF keyI == 61
  gNewMt1GS = valueS
 ENDIF
 IF keyI == 62
  gNewMt2GS = valueS
 ENDIF
 IF keyI == 63
  gNewMt3GS = valueS
 ENDIF
 IF keyI == 64
  gNewMt4GS = valueS
 ENDIF
 IF keyI == 65
  gNewMt5GS = valueS
 ENDIF
 IF keyI == 66
  gNewMt6GS = valueS
 ENDIF
 IF keyI == 67
  gNewMt7GS = valueS
 ENDIF
 IF keyI == 71
  gNewCl1GS = valueS
 ENDIF
 IF keyI == 72
  gNewCl2GS = valueS
 ENDIF
 IF keyI == 73
  gNewCl3GS = valueS
 ENDIF
 IF keyI == 74
  gNewCl4GS = valueS
 ENDIF
 IF keyI == 75
  gNewCl5GS = valueS
 ENDIF
 IF keyI == 76
  gNewCl6GS = valueS
 ENDIF
 IF keyI == 77
  gNewCl7GS = valueS
 ENDIF
 IF keyI == 81
  gNewMl1GS = valueS
 ENDIF
 IF keyI == 82
  gNewMl2GS = valueS
 ENDIF
 IF keyI == 83
  gNewMl3GS = valueS
 ENDIF
 IF keyI == 84
  gNewMl4GS = valueS
 ENDIF
 IF keyI == 85
  gNewMl5GS = valueS
 ENDIF
 IF keyI == 86
  gNewMl6GS = valueS
 ENDIF
 IF keyI == 87
  gNewMl7GS = valueS
 ENDIF
END

PROC ProcClearArray( INTEGER arrayIdI, INTEGER countI )
 INTEGER indexI = 0
 //
 FOR indexI = 1 TO countI
  ProcSetArrayValue( arrayIdI, indexI, "0" )
 ENDFOR
END

PROC ProcCopyArray( INTEGER fromArrayI, INTEGER toArrayI, INTEGER countI )
 INTEGER indexI = 0
 //
 FOR indexI = 1 TO countI
  ProcSetArrayValue( toArrayI, indexI, FNGetArrayValueS( fromArrayI, indexI ) )
 ENDFOR
END

PROC ProcAddArrayValue( INTEGER arrayIdI, INTEGER indexI, STRING addS )
 STRING currentS[255] = ""
 //
 currentS = FNGetArrayValueS( arrayIdI, indexI )
 ProcSetArrayValue( arrayIdI, indexI, FNBigAddS( currentS, addS ) )
END

STRING PROC FNArraySumS( INTEGER arrayIdI, INTEGER countI )
 STRING sumS[255] = "0"
 INTEGER indexI = 0
 //
 FOR indexI = 1 TO countI
  sumS = FNBigAddS( sumS, FNGetArrayValueS( arrayIdI, indexI ) )
 ENDFOR
 return( sumS )
END

STRING PROC FNGetInternalLenS( INTEGER indexI )
 CASE indexI
  WHEN 1
   return( gInternalLen01GS )
  WHEN 2
   return( gInternalLen02GS )
  WHEN 3
   return( gInternalLen03GS )
  WHEN 4
   return( gInternalLen04GS )
  WHEN 5
   return( gInternalLen05GS )
  WHEN 6
   return( gInternalLen06GS )
  WHEN 7
   return( gInternalLen07GS )
  WHEN 8
   return( gInternalLen08GS )
  WHEN 9
   return( gInternalLen09GS )
  WHEN 10
   return( gInternalLen10GS )
  WHEN 11
   return( gInternalLen11GS )
  WHEN 12
   return( gInternalLen12GS )
  WHEN 13
   return( gInternalLen13GS )
  WHEN 14
   return( gInternalLen14GS )
  WHEN 15
   return( gInternalLen15GS )
  WHEN 16
   return( gInternalLen16GS )
  WHEN 17
   return( gInternalLen17GS )
  WHEN 18
   return( gInternalLen18GS )
  WHEN 19
   return( gInternalLen19GS )
  WHEN 20
   return( gInternalLen20GS )
  OTHERWISE
   return( "0" )
 ENDCASE
END

PROC ProcSetInternalLen( INTEGER indexI, STRING valueS )
 IF indexI == 1
  gInternalLen01GS = valueS
 ENDIF
 IF indexI == 2
  gInternalLen02GS = valueS
 ENDIF
 IF indexI == 3
  gInternalLen03GS = valueS
 ENDIF
 IF indexI == 4
  gInternalLen04GS = valueS
 ENDIF
 IF indexI == 5
  gInternalLen05GS = valueS
 ENDIF
 IF indexI == 6
  gInternalLen06GS = valueS
 ENDIF
 IF indexI == 7
  gInternalLen07GS = valueS
 ENDIF
 IF indexI == 8
  gInternalLen08GS = valueS
 ENDIF
 IF indexI == 9
  gInternalLen09GS = valueS
 ENDIF
 IF indexI == 10
  gInternalLen10GS = valueS
 ENDIF
 IF indexI == 11
  gInternalLen11GS = valueS
 ENDIF
 IF indexI == 12
  gInternalLen12GS = valueS
 ENDIF
 IF indexI == 13
  gInternalLen13GS = valueS
 ENDIF
 IF indexI == 14
  gInternalLen14GS = valueS
 ENDIF
 IF indexI == 15
  gInternalLen15GS = valueS
 ENDIF
 IF indexI == 16
  gInternalLen16GS = valueS
 ENDIF
 IF indexI == 17
  gInternalLen17GS = valueS
 ENDIF
 IF indexI == 18
  gInternalLen18GS = valueS
 ENDIF
 IF indexI == 19
  gInternalLen19GS = valueS
 ENDIF
 IF indexI == 20
  gInternalLen20GS = valueS
 ENDIF
END

PROC ProcBuildPrefixAndTransitions()
 INTEGER indexI = 0
 INTEGER jI = 0
 INTEGER stateI = 0
 INTEGER digitI = 0
 INTEGER sI = 0
 INTEGER incI = 0
 STRING nextLineS[255] = ""
 STRING incLineS[255] = ""
 //
 ProcClearPi()
 jI = 0
 FOR indexI = 2 TO gPatternLengthGI
  WHILE ( jI > 0 ) AND ( NOT ( FNPatternDigitI( indexI ) == FNPatternDigitI( jI + 1 ) ) )
   jI = FNGetPiI( jI )
  ENDWHILE
  IF FNPatternDigitI( indexI ) == FNPatternDigitI( jI + 1 )
   jI = jI + 1
  ENDIF
  ProcSetPi( indexI, jI )
 ENDFOR
 FOR stateI = 0 TO gPatternLengthGI - 1
  nextLineS = ""
  incLineS = ""
  FOR digitI = 0 TO 9
   sI = stateI
   WHILE ( sI > 0 ) AND ( NOT ( FNPatternDigitI( sI + 1 ) == digitI ) )
    sI = FNGetPiI( sI )
   ENDWHILE
   IF FNPatternDigitI( sI + 1 ) == digitI
    sI = sI + 1
   ENDIF
   incI = 0
   IF sI == gPatternLengthGI
    incI = 1
    sI = FNGetPiI( gPatternLengthGI )
   ENDIF
   nextLineS = nextLineS + Chr( sI + 48 )
   incLineS  = incLineS  + Chr( incI + 48 )
  ENDFOR
  ProcSetTransitionLine( stateI + 1, nextLineS, incLineS )
 ENDFOR
END

PROC ProcBuildBruteCounts( INTEGER uptoI )
 INTEGER numberI = 0
 INTEGER stateI = 0
 INTEGER digitI = 0
 INTEGER nextStateI = 0
 INTEGER incI = 0
 INTEGER totalI = 0
 INTEGER charIndexI = 0
 STRING digitsS[255] = ""
 //
 IF gBruteBufferGI > 0
  AbandonFile( gBruteBufferGI )
 ENDIF
 gBruteBufferGI = CreateTempBuffer()
 AddLine( "0", gBruteBufferGI )
 stateI = 0
 totalI = 0
 FOR numberI = 1 TO uptoI
  digitsS = Format( numberI )
  FOR charIndexI = 1 TO Length( digitsS )
   digitI = Val( SubStr( digitsS, charIndexI, 1 ) )
   incI = FNTransitionIncI( stateI, digitI )
   nextStateI = FNTransitionNextI( stateI, digitI )
   stateI = nextStateI
   totalI = totalI + incI
  ENDFOR
  AddLine( Format( totalI ), gBruteBufferGI )
 ENDFOR
END

STRING PROC FNBruteCountS( INTEGER numberI )
 STRING resultS[255] = "0"
 //
 PushLocation()
 GotoBufferId( gBruteBufferGI )
 GotoLine( numberI + 1 )
 resultS = GetText( 1, 255 )
 PopLocation()
 return( resultS )
END

PROC ProcPrecomputeInternalLens()
 INTEGER digitCountI = 0
 INTEGER digitI = 0
 INTEGER stateI = 0
 INTEGER nextStateI = 0
 INTEGER incI = 0
 INTEGER positionI = 0
 STRING countS[255] = ""
 STRING matchS[255] = ""
 STRING addMatchS[255] = ""
 //
 FOR digitCountI = 1 TO MAX_DIGITS
  ProcClearArray( ARRAY_CT, gPatternLengthGI )
  ProcClearArray( ARRAY_MT, gPatternLengthGI )
  FOR digitI = 1 TO 9
   nextStateI = FNTransitionNextI( 0, digitI )
   incI = FNTransitionIncI( 0, digitI )
   ProcAddArrayValue( ARRAY_CT, nextStateI + 1, "1" )
   ProcAddArrayValue( ARRAY_MT, nextStateI + 1, Format( incI ) )
  ENDFOR
  FOR positionI = 2 TO digitCountI
   ProcClearArray( ARRAY_NEW_CT, gPatternLengthGI )
   ProcClearArray( ARRAY_NEW_MT, gPatternLengthGI )
   FOR stateI = 0 TO gPatternLengthGI - 1
    countS = FNGetArrayValueS( ARRAY_CT, stateI + 1 )
    matchS = FNGetArrayValueS( ARRAY_MT, stateI + 1 )
    IF NOT ( countS == "0" )
     FOR digitI = 0 TO 9
      nextStateI = FNTransitionNextI( stateI, digitI )
      incI = FNTransitionIncI( stateI, digitI )
      ProcAddArrayValue( ARRAY_NEW_CT, nextStateI + 1, countS )
      addMatchS = matchS
      IF incI == 1
       addMatchS = FNBigAddS( addMatchS, countS )
      ENDIF
      ProcAddArrayValue( ARRAY_NEW_MT, nextStateI + 1, addMatchS )
     ENDFOR
    ENDIF
   ENDFOR
   ProcCopyArray( ARRAY_NEW_CT, ARRAY_CT, gPatternLengthGI )
   ProcCopyArray( ARRAY_NEW_MT, ARRAY_MT, gPatternLengthGI )
  ENDFOR
  ProcSetInternalLen( digitCountI, FNArraySumS( ARRAY_MT, gPatternLengthGI ) )
 ENDFOR
END

STRING PROC FNInternalUptoS( STRING numberS )
 STRING workS[255] = ""
 STRING resultS[255] = "0"
 STRING digitsS[255] = ""
 STRING countS[255] = ""
 STRING matchS[255] = ""
 STRING addMatchS[255] = ""
 INTEGER digitCountI = 0
 INTEGER positionI = 0
 INTEGER limitI = 0
 INTEGER stateI = 0
 INTEGER digitI = 0
 INTEGER nextStateI = 0
 INTEGER incI = 0
 INTEGER minDigitI = 0
 //
 IF FNBigCmpI( numberS, "0" ) <= 0
  return( "0" )
 ENDIF
 workS = FNTrimLeadingZerosS( numberS )
 digitCountI = Length( workS )
 FOR positionI = 1 TO digitCountI - 1
  resultS = FNBigAddS( resultS, FNGetInternalLenS( positionI ) )
 ENDFOR
 ProcClearArray( ARRAY_CT, gPatternLengthGI )
 ProcClearArray( ARRAY_MT, gPatternLengthGI )
 ProcClearArray( ARRAY_CL, gPatternLengthGI )
 ProcClearArray( ARRAY_ML, gPatternLengthGI )
 ProcSetArrayValue( ARRAY_CT, 1, "1" )
 digitsS = workS
 FOR positionI = 1 TO Length( digitsS )
  limitI = Val( SubStr( digitsS, positionI, 1 ) )
  ProcClearArray( ARRAY_NEW_CT, gPatternLengthGI )
  ProcClearArray( ARRAY_NEW_MT, gPatternLengthGI )
  ProcClearArray( ARRAY_NEW_CL, gPatternLengthGI )
  ProcClearArray( ARRAY_NEW_ML, gPatternLengthGI )
  IF positionI == 1
   minDigitI = 1
  ELSE
   minDigitI = 0
  ENDIF
  FOR stateI = 0 TO gPatternLengthGI - 1
   countS = FNGetArrayValueS( ARRAY_CT, stateI + 1 )
   matchS = FNGetArrayValueS( ARRAY_MT, stateI + 1 )
   IF NOT ( countS == "0" )
    FOR digitI = minDigitI TO limitI
     nextStateI = FNTransitionNextI( stateI, digitI )
     incI = FNTransitionIncI( stateI, digitI )
     addMatchS = matchS
     IF incI == 1
      addMatchS = FNBigAddS( addMatchS, countS )
     ENDIF
     IF digitI == limitI
      ProcAddArrayValue( ARRAY_NEW_CT, nextStateI + 1, countS )
      ProcAddArrayValue( ARRAY_NEW_MT, nextStateI + 1, addMatchS )
     ELSE
      ProcAddArrayValue( ARRAY_NEW_CL, nextStateI + 1, countS )
      ProcAddArrayValue( ARRAY_NEW_ML, nextStateI + 1, addMatchS )
     ENDIF
    ENDFOR
   ENDIF
  ENDFOR
  FOR stateI = 0 TO gPatternLengthGI - 1
   countS = FNGetArrayValueS( ARRAY_CL, stateI + 1 )
   matchS = FNGetArrayValueS( ARRAY_ML, stateI + 1 )
   IF NOT ( countS == "0" )
    IF positionI == 1
     minDigitI = 1
    ELSE
     minDigitI = 0
    ENDIF
    FOR digitI = minDigitI TO 9
     nextStateI = FNTransitionNextI( stateI, digitI )
     incI = FNTransitionIncI( stateI, digitI )
     addMatchS = matchS
     IF incI == 1
      addMatchS = FNBigAddS( addMatchS, countS )
     ENDIF
     ProcAddArrayValue( ARRAY_NEW_CL, nextStateI + 1, countS )
     ProcAddArrayValue( ARRAY_NEW_ML, nextStateI + 1, addMatchS )
    ENDFOR
   ENDIF
  ENDFOR
  ProcCopyArray( ARRAY_NEW_CT, ARRAY_CT, gPatternLengthGI )
  ProcCopyArray( ARRAY_NEW_MT, ARRAY_MT, gPatternLengthGI )
  ProcCopyArray( ARRAY_NEW_CL, ARRAY_CL, gPatternLengthGI )
  ProcCopyArray( ARRAY_NEW_ML, ARRAY_ML, gPatternLengthGI )
 ENDFOR
 resultS = FNBigAddS( resultS, FNArraySumS( ARRAY_MT, gPatternLengthGI ) )
 resultS = FNBigAddS( resultS, FNArraySumS( ARRAY_ML, gPatternLengthGI ) )
 return( resultS )
END

STRING PROC FNCountArithProgressionS( STRING lowS, STRING highS, INTEGER modI, INTEGER remainderI )
 INTEGER lowModI = 0
 INTEGER deltaI = 0
 STRING firstS[255] = ""
 STRING diffS[255] = ""
 STRING resultS[255] = ""
 //
 IF FNBigCmpI( highS, lowS ) < 0
  return( "0" )
 ENDIF
 lowModI = FNBigModSmallI( lowS, modI )
 deltaI = ( remainderI - lowModI + modI ) mod modI
 firstS = FNBigAddSmallS( lowS, deltaI )
 IF FNBigCmpI( firstS, highS ) > 0
  return( "0" )
 ENDIF
 diffS = FNBigSubS( highS, firstS )
 resultS = FNBigDivSmallS( diffS, modI )
 resultS = FNBigAddSmallS( resultS, 1 )
 return( resultS )
END

STRING PROC FNBoundaryUptoS( STRING numberS )
 STRING totalS[255] = "0"
 STRING lowS[255] = ""
 STRING highS[255] = ""
 STRING xLowS[255] = ""
 STRING xHighS[255] = ""
 STRING yLowS[255] = ""
 STRING yHighS[255] = ""
 STRING p1S[255] = ""
 STRING p2S[255] = ""
 STRING needS[255] = ""
 STRING nMinusOneS[255] = ""
 INTEGER maxDigitsI = 0
 INTEGER splitI = 0
 INTEGER digitCountI = 0
 INTEGER leftLenI = 0
 INTEGER suffixI = 0
 INTEGER prefixI = 0
 INTEGER modI = 0
 INTEGER dMaxI = 0
 INTEGER dMinI = 0
 //
 IF ( gPatternLengthGI <= 1 ) OR ( FNBigCmpI( numberS, "1" ) <= 0 )
  return( "0" )
 ENDIF
 nMinusOneS = FNBigSubSmallS( numberS, 1 )
 maxDigitsI = Length( nMinusOneS )
 FOR splitI = 1 TO gPatternLengthGI - 1
  p1S = SubStr( gPatternGS, 1, splitI )
  p2S = SubStr( gPatternGS, splitI + 1, gPatternLengthGI - splitI )
  IF NOT ( SubStr( p2S, 1, 1 ) == "0" )
   suffixI = Val( p1S )
   leftLenI = gPatternLengthGI - splitI
   prefixI = Val( p2S )
   modI = FNPower10I( splitI )
   FOR digitCountI = 1 TO maxDigitsI
    xLowS = "1"
    IF digitCountI > 1
     xLowS = FNPower10S( digitCountI - 1 )
    ENDIF
    xHighS = FNBigMinS( nMinusOneS, FNBigSubSmallS( FNPower10S( digitCountI ), 2 ) )
    IF ( digitCountI >= leftLenI ) AND ( FNBigCmpI( xHighS, xLowS ) >= 0 )
     yLowS  = FNIntTimesPower10S( prefixI, digitCountI - leftLenI )
     yHighS = FNBigSubSmallS( FNIntTimesPower10S( prefixI + 1, digitCountI - leftLenI ), 1 )
     lowS   = FNBigMaxS( xLowS, FNBigSubSmallS( yLowS, 1 ) )
     highS  = FNBigMinS( xHighS, FNBigSubSmallS( yHighS, 1 ) )
     IF FNBigCmpI( highS, lowS ) >= 0
      totalS = FNBigAddS( totalS, FNCountArithProgressionS( lowS, highS, modI, suffixI ) )
     ENDIF
    ENDIF
   ENDFOR
   IF p1S == FNRepeatCharS( "9", splitI )
    needS = "1" + FNRepeatCharS( "0", leftLenI - 1 )
    IF p2S == needS
     dMaxI = Length( numberS ) - 1
     dMinI = leftLenI - 1
     IF dMinI < 1
      dMinI = 1
     ENDIF
     IF dMaxI >= dMinI
      totalS = FNBigAddSmallS( totalS, dMaxI - dMinI + 1 )
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 return( totalS )
END

STRING PROC FNCountFullConcatS( STRING numberS )
 STRING internalS[255] = ""
 STRING boundaryS[255] = ""
 STRING limitS[255] = ""
 //
 IF FNBigCmpI( numberS, "0" ) <= 0
  return( "0" )
 ENDIF
 limitS = Format( gBruteLimitGI )
 IF FNBigCmpI( numberS, limitS ) <= 0
  return( FNBruteCountS( Val( numberS ) ) )
 ENDIF
 internalS = FNBigSubS( FNInternalUptoS( numberS ), gInternalAGS )
 boundaryS = FNBigSubS( FNBoundaryUptoS( numberS ), gBoundaryAGS )
 return( FNBigAddS( gBruteAGS, FNBigAddS( internalS, boundaryS ) ) )
END

STRING PROC FNTailDigitsS( STRING numberS, INTEGER needI )
 STRING workS[255] = ""
 STRING tailS[255] = ""
 //
 IF ( needI <= 0 ) OR ( FNBigCmpI( numberS, "0" ) <= 0 )
  return( "" )
 ENDIF
 workS = numberS
 WHILE ( Length( tailS ) < needI ) AND ( FNBigCmpI( workS, "0" ) > 0 )
  tailS = workS + tailS
  workS = FNBigSubSmallS( workS, 1 )
 ENDWHILE
 IF Length( tailS ) > needI
  tailS = SubStr( tailS, Length( tailS ) - needI + 1, needI )
 ENDIF
 return( tailS )
END

STRING PROC FNPrefixToNS( STRING prefixS )
 STRING cumulativeS[255] = "0"
 STRING blockLenS[255] = ""
 STRING restS[255] = ""
 STRING tFullS[255] = ""
 INTEGER digitCountI = 1
 INTEGER doneB = FALSE
 //
 IF FNBigCmpI( prefixS, "0" ) <= 0
  gPrefixRemainderGI = 0
  return( "0" )
 ENDIF
 WHILE doneB == FALSE
  blockLenS = FNBigMulSmallS( FNPower10S( digitCountI - 1 ), 9 * digitCountI )
  IF FNBigCmpI( FNBigAddS( cumulativeS, blockLenS ), prefixS ) < 0
   cumulativeS = FNBigAddS( cumulativeS, blockLenS )
   digitCountI = digitCountI + 1
  ELSE
   doneB = TRUE
  ENDIF
 ENDWHILE
 restS = FNBigSubS( prefixS, cumulativeS )
 tFullS = FNBigDivSmallS( restS, digitCountI )
 gPrefixRemainderGI = gDivRemainderGI
 IF FNBigCmpI( tFullS, "0" ) == 0
  return( FNBigSubSmallS( FNPower10S( digitCountI - 1 ), 1 ) )
 ENDIF
 return( FNBigSubSmallS( FNBigAddS( FNPower10S( digitCountI - 1 ), tFullS ), 1 ) )
END

STRING PROC FNCountMatchesInPrefixS( STRING prefixS )
 STRING nFullS[255] = ""
 STRING countS[255] = ""
 STRING tailS[255] = ""
 STRING extensionS[255] = ""
 STRING combinedS[255] = ""
 INTEGER stateI = 0
 INTEGER nextStateI = 0
 INTEGER incI = 0
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER tailLengthI = 0
 INTEGER addI = 0
 //
 IF FNBigCmpI( prefixS, "0" ) <= 0
  return( "0" )
 ENDIF
 nFullS = FNPrefixToNS( prefixS )
 countS = FNCountFullConcatS( nFullS )
 IF gPrefixRemainderGI == 0
  return( countS )
 ENDIF
 tailS = FNTailDigitsS( nFullS, gPatternLengthGI - 1 )
 tailLengthI = Length( tailS )
 extensionS = SubStr( FNBigAddSmallS( nFullS, 1 ), 1, gPrefixRemainderGI )
 combinedS = tailS + extensionS
 stateI = 0
 addI = 0
 FOR indexI = 1 TO Length( combinedS )
  digitI = Val( SubStr( combinedS, indexI, 1 ) )
  incI = FNTransitionIncI( stateI, digitI )
  nextStateI = FNTransitionNextI( stateI, digitI )
  stateI = nextStateI
  IF ( incI == 1 ) AND ( indexI > tailLengthI )
   addI = addI + 1
  ENDIF
 ENDFOR
 return( FNBigAddSmallS( countS, addI ) )
END

STRING PROC FNCountStartsLeqS( STRING startS )
 STRING endS[255] = ""
 //
 endS = FNBigAddSmallS( startS, gPatternLengthGI - 1 )
 return( FNCountMatchesInPrefixS( endS ) )
END

STRING PROC FNFindNthOccurrenceS( STRING targetS )
 STRING lowS[255] = "1"
 STRING highS[255] = "1"
 STRING midS[255] = ""
 //
 WHILE FNBigCmpI( FNCountStartsLeqS( highS ), targetS ) < 0
  highS = FNBigMulSmallS( highS, 2 )
 ENDWHILE
 WHILE FNBigCmpI( lowS, highS ) < 0
  midS = FNBigDivSmallS( FNBigAddS( lowS, highS ), 2 )
  IF FNBigCmpI( FNCountStartsLeqS( midS ), targetS ) >= 0
   highS = midS
  ELSE
   lowS = FNBigAddSmallS( midS, 1 )
  ENDIF
 ENDWHILE
 return( lowS )
END

PROC ProcSetupPattern( STRING patternS )
 STRING bruteLimitS[255] = ""
 //
 gPatternGS = patternS
 gPatternLengthGI = Length( gPatternGS )
 IF gPatternLengthGI < 2
  gBruteLimitGI = 1
 ELSE
  gBruteLimitGI = FNPower10I( gPatternLengthGI - 2 )
 ENDIF
 ProcBuildPrefixAndTransitions()
 ProcBuildBruteCounts( gBruteLimitGI )
 ProcPrecomputeInternalLens()
 bruteLimitS = Format( gBruteLimitGI )
 gBruteAGS    = FNBruteCountS( gBruteLimitGI )
 gInternalAGS = FNInternalUptoS( bruteLimitS )
 gBoundaryAGS = FNBoundaryUptoS( bruteLimitS )
END

STRING PROC FNComputeFS( INTEGER numberI )
 STRING answerS[255] = ""
 STRING numberS[255] = ""
 //
 numberS = Format( numberI )
 ProcSetupPattern( numberS )
 answerS = FNFindNthOccurrenceS( numberS )
 return( answerS )
END

STRING PROC FNSolveS()
 STRING totalS[255] = "0"
 INTEGER powerI = 1
 INTEGER indexI = 0
 STRING oneS[255] = ""
 //
 FOR indexI = 1 TO 13
  powerI = powerI * 3
  oneS = FNComputeFS( powerI )
  totalS = FNBigAddS( totalS, oneS )
 ENDFOR
 return( totalS )
END

PROC Main()
 STRING resultS[255] = ""
 //
 resultS = FNSolveS()
 CopyToWinClip( resultS )
 Warn( resultS )
 CopyToWinClip( resultS )
 IF gBruteBufferGI > 0
  AbandonFile( gBruteBufferGI )
 ENDIF
END
