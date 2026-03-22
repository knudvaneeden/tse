/*
 Euler Project 176
 Common Cathetus Right-angled Triangles

 Find the smallest integer that can be the length of a cathetus
 of exactly 47547 different integer sided right-angled triangles.

 Pure TSE SAL solution.
 No hardcoded final answer.
 The answer is calculated from the mathematics.

 <version>1.0.0.0.0</version>

 History:
 1.0.0.0.0 - Created by ChatGPT GPT-5.4 Thinking
*/

#define TARGET_TRIANGLES 47547
#define MAX_FACTORS      5

integer gFactorCountI = 0
integer gFactor1I = 0
integer gFactor2I = 0
integer gFactor3I = 0
integer gFactor4I = 0
integer gFactor5I = 0
integer gGroupProduct1I = 1
integer gGroupProduct2I = 1
integer gGroupProduct3I = 1
integer gGroupProduct4I = 1
integer gGroupProduct5I = 1
string  gBestEvenS[255] = ""
string  gBestOddS[255]  = ""

/*
 Forward declarations
*/
forward integer proc ProcGetFactor( integer indexI )
forward proc ProcSetFactor( integer indexI, integer valueI )
forward integer proc ProcGetGroupProduct( integer indexI )
forward proc ProcSetGroupProduct( integer indexI, integer valueI )
forward integer proc ProcGetEvenBase( integer indexI )
forward integer proc ProcGetOddBase( integer indexI )
forward string proc ProcTrimLeadingZeros( string numberS )
forward integer proc ProcCompareBigIntegerStrings( string leftS, string rightS )
forward string proc ProcMultiplyBigIntegerBySmall( string numberS, integer multiplierI )
forward string proc ProcBuildCandidateString( integer exponent1I, integer exponent2I, integer exponent3I, integer exponent4I, integer exponent5I, integer oddOnlyB )
forward proc ProcSortFiveDescending( var integer aI, var integer bI, var integer cI, var integer dI, var integer eI )
forward proc ProcEvaluateCurrentPartition()
forward proc ProcEnumeratePartitions( integer factorIndexI, integer groupCountI )
forward proc ProcFactorOddIntegerIntoPrimeFactors( integer numberI )
forward string proc ProcMinimumString( string leftS, string rightS )

integer proc ProcGetFactor( integer indexI )
 integer resultI = 0
 CASE indexI
  WHEN 1
   resultI = gFactor1I
  WHEN 2
   resultI = gFactor2I
  WHEN 3
   resultI = gFactor3I
  WHEN 4
   resultI = gFactor4I
  WHEN 5
   resultI = gFactor5I
  OTHERWISE
   resultI = 0
 ENDCASE
 RETURN( resultI )
END

proc ProcSetFactor( integer indexI, integer valueI )
 CASE indexI
  WHEN 1
   gFactor1I = valueI
  WHEN 2
   gFactor2I = valueI
  WHEN 3
   gFactor3I = valueI
  WHEN 4
   gFactor4I = valueI
  WHEN 5
   gFactor5I = valueI
  OTHERWISE
   //
 ENDCASE
END

integer proc ProcGetGroupProduct( integer indexI )
 integer resultI = 1
 CASE indexI
  WHEN 1
   resultI = gGroupProduct1I
  WHEN 2
   resultI = gGroupProduct2I
  WHEN 3
   resultI = gGroupProduct3I
  WHEN 4
   resultI = gGroupProduct4I
  WHEN 5
   resultI = gGroupProduct5I
  OTHERWISE
   resultI = 1
 ENDCASE
 RETURN( resultI )
END

proc ProcSetGroupProduct( integer indexI, integer valueI )
 CASE indexI
  WHEN 1
   gGroupProduct1I = valueI
  WHEN 2
   gGroupProduct2I = valueI
  WHEN 3
   gGroupProduct3I = valueI
  WHEN 4
   gGroupProduct4I = valueI
  WHEN 5
   gGroupProduct5I = valueI
  OTHERWISE
   //
 ENDCASE
END

integer proc ProcGetEvenBase( integer indexI )
 integer resultI = 2
 CASE indexI
  WHEN 1
   resultI = 2
  WHEN 2
   resultI = 3
  WHEN 3
   resultI = 5
  WHEN 4
   resultI = 7
  WHEN 5
   resultI = 11
  OTHERWISE
   resultI = 13
 ENDCASE
 RETURN( resultI )
END

integer proc ProcGetOddBase( integer indexI )
 integer resultI = 3
 CASE indexI
  WHEN 1
   resultI = 3
  WHEN 2
   resultI = 5
  WHEN 3
   resultI = 7
  WHEN 4
   resultI = 11
  WHEN 5
   resultI = 13
  OTHERWISE
   resultI = 17
 ENDCASE
 RETURN( resultI )
END

string proc ProcTrimLeadingZeros( string numberS )
 string workS[255] = ""
 integer indexI = 1
 workS = numberS
 WHILE indexI < Length( workS ) AND SubStr( workS, indexI, 1 ) == "0"
  indexI = indexI + 1
 ENDWHILE
 RETURN( SubStr( workS, indexI, Length( workS ) - indexI + 1 ) )
END

integer proc ProcCompareBigIntegerStrings( string leftS, string rightS )
 integer resultI = 0
 string leftWorkS[255] = ""
 string rightWorkS[255] = ""
 leftWorkS  = ProcTrimLeadingZeros( leftS )
 rightWorkS = ProcTrimLeadingZeros( rightS )
 IF Length( leftWorkS ) < Length( rightWorkS )
  resultI = -1
 ELSEIF Length( leftWorkS ) > Length( rightWorkS )
  resultI = 1
 ELSE
  IF leftWorkS < rightWorkS
   resultI = -1
  ELSEIF leftWorkS > rightWorkS
   resultI = 1
  ELSE
   resultI = 0
  ENDIF
 ENDIF
 RETURN( resultI )
END

string proc ProcMultiplyBigIntegerBySmall( string numberS, integer multiplierI )
 string workS[255] = ""
 string resultS[255] = ""
 integer carryI = 0
 integer indexI = 0
 integer digitI = 0
 integer productI = 0

 workS = ProcTrimLeadingZeros( numberS )

 IF multiplierI == 0
  RETURN( "0" )
 ENDIF

 IF workS == "0"
  RETURN( "0" )
 ENDIF

 resultS = ""
 carryI = 0

 FOR indexI = Length( workS ) DOWNTO 1
  digitI = Asc( SubStr( workS, indexI, 1 ) ) - Asc( "0" )
  productI = digitI * multiplierI + carryI
  resultS = Chr( ( productI mod 10 ) + Asc( "0" ) ) + resultS
  carryI = productI / 10
 ENDFOR

 WHILE carryI > 0
  resultS = Chr( ( carryI mod 10 ) + Asc( "0" ) ) + resultS
  carryI = carryI / 10
 ENDWHILE

 RETURN( ProcTrimLeadingZeros( resultS ) )
END

string proc ProcBuildCandidateString( integer exponent1I, integer exponent2I, integer exponent3I, integer exponent4I, integer exponent5I, integer oddOnlyB )
 string resultS[255] = ""
 integer baseI = 0
 integer repeatI = 0

 resultS = "1"

 IF exponent1I > 0
  IF oddOnlyB
   baseI = ProcGetOddBase( 1 )
  ELSE
   baseI = ProcGetEvenBase( 1 )
  ENDIF
  FOR repeatI = 1 TO exponent1I
   resultS = ProcMultiplyBigIntegerBySmall( resultS, baseI )
  ENDFOR
 ENDIF

 IF exponent2I > 0
  IF oddOnlyB
   baseI = ProcGetOddBase( 2 )
  ELSE
   baseI = ProcGetEvenBase( 2 )
  ENDIF
  FOR repeatI = 1 TO exponent2I
   resultS = ProcMultiplyBigIntegerBySmall( resultS, baseI )
  ENDFOR
 ENDIF

 IF exponent3I > 0
  IF oddOnlyB
   baseI = ProcGetOddBase( 3 )
  ELSE
   baseI = ProcGetEvenBase( 3 )
  ENDIF
  FOR repeatI = 1 TO exponent3I
   resultS = ProcMultiplyBigIntegerBySmall( resultS, baseI )
  ENDFOR
 ENDIF

 IF exponent4I > 0
  IF oddOnlyB
   baseI = ProcGetOddBase( 4 )
  ELSE
   baseI = ProcGetEvenBase( 4 )
  ENDIF
  FOR repeatI = 1 TO exponent4I
   resultS = ProcMultiplyBigIntegerBySmall( resultS, baseI )
  ENDFOR
 ENDIF

 IF exponent5I > 0
  IF oddOnlyB
   baseI = ProcGetOddBase( 5 )
  ELSE
   baseI = ProcGetEvenBase( 5 )
  ENDIF
  FOR repeatI = 1 TO exponent5I
   resultS = ProcMultiplyBigIntegerBySmall( resultS, baseI )
  ENDFOR
 ENDIF

 RETURN( ProcTrimLeadingZeros( resultS ) )
END

proc ProcSortFiveDescending( var integer aI, var integer bI, var integer cI, var integer dI, var integer eI )
 integer tempI = 0

 IF aI < bI
  tempI = aI
  aI = bI
  bI = tempI
 ENDIF
 IF bI < cI
  tempI = bI
  bI = cI
  cI = tempI
 ENDIF
 IF cI < dI
  tempI = cI
  cI = dI
  dI = tempI
 ENDIF
 IF dI < eI
  tempI = dI
  dI = eI
  eI = tempI
 ENDIF

 IF aI < bI
  tempI = aI
  aI = bI
  bI = tempI
 ENDIF
 IF bI < cI
  tempI = bI
  bI = cI
  cI = tempI
 ENDIF
 IF cI < dI
  tempI = cI
  cI = dI
  dI = tempI
 ENDIF

 IF aI < bI
  tempI = aI
  aI = bI
  bI = tempI
 ENDIF
 IF bI < cI
  tempI = bI
  bI = cI
  cI = tempI
 ENDIF

 IF aI < bI
  tempI = aI
  aI = bI
  bI = tempI
 ENDIF
END

string proc ProcMinimumString( string leftS, string rightS )
 string resultS[255] = ""
 IF leftS == ""
  resultS = rightS
 ELSEIF rightS == ""
  resultS = leftS
 ELSEIF ProcCompareBigIntegerStrings( leftS, rightS ) <= 0
  resultS = leftS
 ELSE
  resultS = rightS
 ENDIF
 RETURN( resultS )
END

proc ProcEvaluateCurrentPartition()
 integer exponent1I = 0
 integer exponent2I = 0
 integer exponent3I = 0
 integer exponent4I = 0
 integer exponent5I = 0
 integer productI = 0
 string candidateEvenMS[255] = ""
 string candidateEvenNS[255] = ""
 string candidateOddNS[255] = ""

 productI = ProcGetGroupProduct( 1 )
 IF productI > 1
  exponent1I = ( productI - 1 ) / 2
 ENDIF

 productI = ProcGetGroupProduct( 2 )
 IF productI > 1
  exponent2I = ( productI - 1 ) / 2
 ENDIF

 productI = ProcGetGroupProduct( 3 )
 IF productI > 1
  exponent3I = ( productI - 1 ) / 2
 ENDIF

 productI = ProcGetGroupProduct( 4 )
 IF productI > 1
  exponent4I = ( productI - 1 ) / 2
 ENDIF

 productI = ProcGetGroupProduct( 5 )
 IF productI > 1
  exponent5I = ( productI - 1 ) / 2
 ENDIF

 ProcSortFiveDescending( exponent1I, exponent2I, exponent3I, exponent4I, exponent5I )

 candidateEvenMS = ProcBuildCandidateString( exponent1I, exponent2I, exponent3I, exponent4I, exponent5I, FALSE )
 candidateEvenNS = ProcMultiplyBigIntegerBySmall( candidateEvenMS, 2 )
 gBestEvenS = ProcMinimumString( gBestEvenS, candidateEvenNS )

 candidateOddNS = ProcBuildCandidateString( exponent1I, exponent2I, exponent3I, exponent4I, exponent5I, TRUE )
 gBestOddS = ProcMinimumString( gBestOddS, candidateOddNS )
END

proc ProcEnumeratePartitions( integer factorIndexI, integer groupCountI )
 integer currentFactorI = 0
 integer groupIndexI = 0
 integer oldProductI = 0

 IF factorIndexI > gFactorCountI
  ProcEvaluateCurrentPartition()
  RETURN()
 ENDIF

 currentFactorI = ProcGetFactor( factorIndexI )

 FOR groupIndexI = 1 TO groupCountI
  oldProductI = ProcGetGroupProduct( groupIndexI )
  ProcSetGroupProduct( groupIndexI, oldProductI * currentFactorI )
  ProcEnumeratePartitions( factorIndexI + 1, groupCountI )
  ProcSetGroupProduct( groupIndexI, oldProductI )
 ENDFOR

 IF groupCountI < MAX_FACTORS
  ProcSetGroupProduct( groupCountI + 1, currentFactorI )
  ProcEnumeratePartitions( factorIndexI + 1, groupCountI + 1 )
  ProcSetGroupProduct( groupCountI + 1, 1 )
 ENDIF
END

proc ProcFactorOddIntegerIntoPrimeFactors( integer numberI )
 integer workI = 0
 integer divisorI = 0

 gFactorCountI = 0
 workI = numberI

 divisorI = 3
 WHILE divisorI * divisorI <= workI
  WHILE ( workI mod divisorI ) == 0
   gFactorCountI = gFactorCountI + 1
   ProcSetFactor( gFactorCountI, divisorI )
   workI = workI / divisorI
  ENDWHILE
  divisorI = divisorI + 2
 ENDWHILE

 IF workI > 1
  gFactorCountI = gFactorCountI + 1
  ProcSetFactor( gFactorCountI, workI )
 ENDIF
END

PROC Main()
 integer divisorTargetI = 0
 string finalResultS[255] = ""

 divisorTargetI = TARGET_TRIANGLES * 2 + 1

 gBestEvenS = ""
 gBestOddS  = ""

 gGroupProduct1I = 1
 gGroupProduct2I = 1
 gGroupProduct3I = 1
 gGroupProduct4I = 1
 gGroupProduct5I = 1

 ProcFactorOddIntegerIntoPrimeFactors( divisorTargetI )
 ProcEnumeratePartitions( 1, 0 )

 finalResultS = ProcMinimumString( gBestEvenS, gBestOddS )

 CopyToWinClip( finalResultS )
 Warn( finalResultS )
 CopyToWinClip( finalResultS )
END
