/*
 <title>Euler Project 184</title>
 <version>1.0.0.0.4</version>
 <date>2026-03-24</date>
 <author>OpenAI ChatGPT GPT-5.4 Thinking</author>
 <history>
 1.0.0.0.1  2026-03-24  Created by OpenAI ChatGPT GPT-5.4 Thinking
 1.0.0.0.2  2026-03-24  Fixed 32-bit overflow in weighted triple accumulation
 1.0.0.0.3  2026-03-24  Replaced prefix-window subtraction with sliding-window semicircle counting
 1.0.0.0.4  2026-03-24  Replaced duplicated-buffer wrap logic by explicit cyclic indexing
 </history>
 <result>1725323624056</result>
*/

#define RADIUS 105
#define RADIUS_SQUARED 11025
#define MAX_INSIDE_SQUARED 11024

integer gFirstXBufferI = 0
integer gFirstYBufferI = 0
integer gFirstWBufferI = 0
integer gFullXBufferI  = 0
integer gFullYBufferI  = 0
integer gFullWBufferI  = 0
integer gFirstCountI   = 0
integer gFullCountI    = 0

FORWARD string proc ProcTrimLeadingZeros( string numberS )
FORWARD string proc ProcIntegerToString( integer numberI )
FORWARD integer proc ProcGetDigitFromRight( string numberS, integer indexFromRightI )
FORWARD string proc ProcAddDecimalStrings( string leftS, string rightS )
FORWARD string proc ProcSubtractDecimalStrings( string leftS, string rightS )
FORWARD string proc ProcMultiplyStringBySmall( string numberS, integer factorI )
FORWARD integer proc ProcStringToInteger( string numberS )
FORWARD integer proc ProcComputeWeight( integer xI, integer yI )
FORWARD proc ProcAppendFirstDirection( integer xI, integer yI, integer weightI )
FORWARD proc ProcGenerateFirstQuadrant( integer leftYI, integer leftXI, integer rightYI, integer rightXI )
FORWARD proc ProcBuildFirstQuadrant()
FORWARD proc ProcRotateVector( integer xI, integer yI, integer rotationI, var integer outXI, var integer outYI )
FORWARD proc ProcAppendFullDirection( integer xI, integer yI, integer weightI )
FORWARD proc ProcBuildFullDirections()
FORWARD string proc ProcGetBufferLine( integer bufferIdI, integer lineNumberI )
FORWARD integer proc ProcGetBufferInteger( integer bufferIdI, integer lineNumberI )
FORWARD integer proc ProcWrapIndex( integer indexI )
FORWARD integer proc ProcGetWrappedX( integer indexI )
FORWARD integer proc ProcGetWrappedY( integer indexI )
FORWARD integer proc ProcGetWrappedW( integer indexI )
FORWARD string proc ProcComputeAnswer()
FORWARD proc Main()

string proc ProcTrimLeadingZeros( string numberS )
 string workS[255] = ""
 integer indexI = 1
 //
 workS = numberS
 WHILE indexI < Length( workS ) AND workS[ indexI ] == "0"
  indexI = indexI + 1
 ENDWHILE
 RETURN( workS[ indexI : Length( workS ) - indexI + 1 ] )
END

string proc ProcIntegerToString( integer numberI )
 string numberS[255] = ""
 //
 numberS = Format( numberI )
 RETURN( ProcTrimLeadingZeros( numberS ) )
END

integer proc ProcGetDigitFromRight( string numberS, integer indexFromRightI )
 integer textLengthI = 0
 integer charCodeI = 0
 //
 textLengthI = Length( numberS )
 IF indexFromRightI > textLengthI
  RETURN( 0 )
 ENDIF
 charCodeI = Asc( numberS[ textLengthI - indexFromRightI + 1 ] )
 RETURN( charCodeI - Asc( "0" ) )
END

string proc ProcAddDecimalStrings( string leftS, string rightS )
 string workLeftS[255] = ""
 string workRightS[255] = ""
 string resultS[255] = ""
 integer leftLengthI = 0
 integer rightLengthI = 0
 integer maxLengthI = 0
 integer indexI = 0
 integer digitLeftI = 0
 integer digitRightI = 0
 integer sumI = 0
 integer carryI = 0
 //
 workLeftS = ProcTrimLeadingZeros( leftS )
 workRightS = ProcTrimLeadingZeros( rightS )
 leftLengthI = Length( workLeftS )
 rightLengthI = Length( workRightS )
 IF leftLengthI > rightLengthI
  maxLengthI = leftLengthI
 ELSE
  maxLengthI = rightLengthI
 ENDIF
 resultS = ""
 carryI = 0
 FOR indexI = 1 TO maxLengthI
  digitLeftI = ProcGetDigitFromRight( workLeftS, indexI )
  digitRightI = ProcGetDigitFromRight( workRightS, indexI )
  sumI = digitLeftI + digitRightI + carryI
  resultS = Chr( Asc( "0" ) + ( sumI mod 10 ) ) + resultS
  carryI = sumI / 10
 ENDFOR
 IF carryI > 0
  resultS = Chr( Asc( "0" ) + carryI ) + resultS
 ENDIF
 RETURN( ProcTrimLeadingZeros( resultS ) )
END

string proc ProcSubtractDecimalStrings( string leftS, string rightS )
 string workLeftS[255] = ""
 string workRightS[255] = ""
 string resultS[255] = ""
 integer leftLengthI = 0
 integer indexI = 0
 integer digitLeftI = 0
 integer digitRightI = 0
 integer differenceI = 0
 integer borrowI = 0
 //
 workLeftS = ProcTrimLeadingZeros( leftS )
 workRightS = ProcTrimLeadingZeros( rightS )
 leftLengthI = Length( workLeftS )
 resultS = ""
 borrowI = 0
 FOR indexI = 1 TO leftLengthI
  digitLeftI = ProcGetDigitFromRight( workLeftS, indexI ) - borrowI
  digitRightI = ProcGetDigitFromRight( workRightS, indexI )
  IF digitLeftI < digitRightI
   digitLeftI = digitLeftI + 10
   borrowI = 1
  ELSE
   borrowI = 0
  ENDIF
  differenceI = digitLeftI - digitRightI
  resultS = Chr( Asc( "0" ) + differenceI ) + resultS
 ENDFOR
 RETURN( ProcTrimLeadingZeros( resultS ) )
END

string proc ProcMultiplyStringBySmall( string numberS, integer factorI )
 string workS[255] = ""
 string resultS[255] = ""
 integer textLengthI = 0
 integer indexI = 0
 integer digitI = 0
 integer productI = 0
 integer carryI = 0
 //
 IF factorI == 0
  RETURN( "0" )
 ENDIF
 IF factorI == 1
  RETURN( ProcTrimLeadingZeros( numberS ) )
 ENDIF
 workS = ProcTrimLeadingZeros( numberS )
 textLengthI = Length( workS )
 resultS = ""
 carryI = 0
 FOR indexI = textLengthI DOWNTO 1
  digitI = Asc( workS[ indexI ] ) - Asc( "0" )
  productI = digitI * factorI + carryI
  resultS = Chr( Asc( "0" ) + ( productI mod 10 ) ) + resultS
  carryI = productI / 10
 ENDFOR
 WHILE carryI > 0
  resultS = Chr( Asc( "0" ) + ( carryI mod 10 ) ) + resultS
  carryI = carryI / 10
 ENDWHILE
 RETURN( ProcTrimLeadingZeros( resultS ) )
END

integer proc ProcStringToInteger( string numberS )
 string workS[255] = ""
 //
 workS = Trim( numberS )
 RETURN( Val( workS ) )
END

integer proc ProcComputeWeight( integer xI, integer yI )
 integer distanceSquaredI = 0
 integer weightI = 0
 //
 distanceSquaredI = xI * xI + yI * yI
 weightI = 0
 WHILE ( weightI + 1 ) * ( weightI + 1 ) * distanceSquaredI <= MAX_INSIDE_SQUARED
  weightI = weightI + 1
 ENDWHILE
 RETURN( weightI )
END

proc ProcAppendFirstDirection( integer xI, integer yI, integer weightI )
 AddLine( ProcIntegerToString( xI ), gFirstXBufferI )
 AddLine( ProcIntegerToString( yI ), gFirstYBufferI )
 AddLine( ProcIntegerToString( weightI ), gFirstWBufferI )
 gFirstCountI = gFirstCountI + 1
END

proc ProcGenerateFirstQuadrant( integer leftYI, integer leftXI, integer rightYI, integer rightXI )
 integer middleYI = 0
 integer middleXI = 0
 integer weightI = 0
 //
 middleYI = leftYI + rightYI
 middleXI = leftXI + rightXI
 IF middleXI * middleXI + middleYI * middleYI < RADIUS_SQUARED
  ProcGenerateFirstQuadrant( leftYI, leftXI, middleYI, middleXI )
  weightI = ProcComputeWeight( middleXI, middleYI )
  ProcAppendFirstDirection( middleXI, middleYI, weightI )
  ProcGenerateFirstQuadrant( middleYI, middleXI, rightYI, rightXI )
 ENDIF
END

proc ProcBuildFirstQuadrant()
 integer weightI = 0
 //
 gFirstCountI = 0
 weightI = ProcComputeWeight( 1, 0 )
 ProcAppendFirstDirection( 1, 0, weightI )
 ProcGenerateFirstQuadrant( 0, 1, 1, 0 )
 weightI = ProcComputeWeight( 0, 1 )
 ProcAppendFirstDirection( 0, 1, weightI )
END

proc ProcRotateVector( integer xI, integer yI, integer rotationI, var integer outXI, var integer outYI )
 IF rotationI == 0
  outXI = xI
  outYI = yI
 ELSEIF rotationI == 1
  outXI = -yI
  outYI = xI
 ELSEIF rotationI == 2
  outXI = -xI
  outYI = -yI
 ELSE
  outXI = yI
  outYI = -xI
 ENDIF
END

proc ProcAppendFullDirection( integer xI, integer yI, integer weightI )
 AddLine( ProcIntegerToString( xI ), gFullXBufferI )
 AddLine( ProcIntegerToString( yI ), gFullYBufferI )
 AddLine( ProcIntegerToString( weightI ), gFullWBufferI )
 gFullCountI = gFullCountI + 1
END

proc ProcBuildFullDirections()
 integer rotationI = 0
 integer lineI = 0
 integer limitI = 0
 integer xI = 0
 integer yI = 0
 integer weightI = 0
 integer rotatedXI = 0
 integer rotatedYI = 0
 //
 gFullCountI = 0
 limitI = gFirstCountI - 1
 FOR rotationI = 0 TO 3
  FOR lineI = 1 TO limitI
   xI = ProcGetBufferInteger( gFirstXBufferI, lineI )
   yI = ProcGetBufferInteger( gFirstYBufferI, lineI )
   weightI = ProcGetBufferInteger( gFirstWBufferI, lineI )
   ProcRotateVector( xI, yI, rotationI, rotatedXI, rotatedYI )
   ProcAppendFullDirection( rotatedXI, rotatedYI, weightI )
  ENDFOR
 ENDFOR
END

string proc ProcGetBufferLine( integer bufferIdI, integer lineNumberI )
 string lineS[255] = ""
 integer oldBufferIdI = 0
 integer oldLineI = 0
 //
 oldBufferIdI = GetBufferId()
 oldLineI = CurrLine()
 GotoBufferId( bufferIdI )
 GotoLine( lineNumberI )
 lineS = Trim( GetText( 1, 255 ) )
 GotoBufferId( oldBufferIdI )
 GotoLine( oldLineI )
 RETURN( lineS )
END

integer proc ProcGetBufferInteger( integer bufferIdI, integer lineNumberI )
 string lineS[255] = ""
 //
 lineS = ProcGetBufferLine( bufferIdI, lineNumberI )
 RETURN( ProcStringToInteger( lineS ) )
END

integer proc ProcWrapIndex( integer indexI )
 integer wrappedI = 0
 //
 wrappedI = indexI
 WHILE wrappedI > gFullCountI
  wrappedI = wrappedI - gFullCountI
 ENDWHILE
 WHILE wrappedI < 1
  wrappedI = wrappedI + gFullCountI
 ENDWHILE
 RETURN( wrappedI )
END

integer proc ProcGetWrappedX( integer indexI )
 integer wrappedI = 0
 //
 wrappedI = ProcWrapIndex( indexI )
 RETURN( ProcGetBufferInteger( gFullXBufferI, wrappedI ) )
END

integer proc ProcGetWrappedY( integer indexI )
 integer wrappedI = 0
 //
 wrappedI = ProcWrapIndex( indexI )
 RETURN( ProcGetBufferInteger( gFullYBufferI, wrappedI ) )
END

integer proc ProcGetWrappedW( integer indexI )
 integer wrappedI = 0
 //
 wrappedI = ProcWrapIndex( indexI )
 RETURN( ProcGetBufferInteger( gFullWBufferI, wrappedI ) )
END

string proc ProcComputeAnswer()
 integer indexI = 0
 integer pointerJI = 0
 integer xStartI = 0
 integer yStartI = 0
 integer xEndI = 0
 integer yEndI = 0
 integer crossI = 0
 integer dotI = 0
 integer weightI = 0
 integer e1I = 0
 integer windowWeightSumI = 0
 integer windowWeightSquareSumI = 0
 integer pairWeightI = 0
 integer removeWeightI = 0
 string e2S[255] = ""
 string totalTriplesS[255] = ""
 string addToE2S[255] = ""
 string termS[255] = ""
 string badTriplesS[255] = ""
 string answerS[255] = ""
 //
 e1I = 0
 e2S = "0"
 totalTriplesS = "0"
 FOR indexI = 1 TO gFullCountI
  weightI = ProcGetWrappedW( indexI )
  termS = ProcMultiplyStringBySmall( e2S, weightI )
  totalTriplesS = ProcAddDecimalStrings( totalTriplesS, termS )
  addToE2S = ProcMultiplyStringBySmall( ProcIntegerToString( e1I ), weightI )
  e2S = ProcAddDecimalStrings( e2S, addToE2S )
  e1I = e1I + weightI
 ENDFOR
 badTriplesS = "0"
 pointerJI = 2
 windowWeightSumI = 0
 windowWeightSquareSumI = 0
 FOR indexI = 1 TO gFullCountI
  IF pointerJI < indexI + 1
   pointerJI = indexI + 1
   windowWeightSumI = 0
   windowWeightSquareSumI = 0
  ENDIF
  xStartI = ProcGetWrappedX( indexI )
  yStartI = ProcGetWrappedY( indexI )
  WHILE pointerJI <= indexI + gFullCountI - 1
   xEndI = ProcGetWrappedX( pointerJI )
   yEndI = ProcGetWrappedY( pointerJI )
   crossI = xStartI * yEndI - yStartI * xEndI
   dotI = xStartI * xEndI + yStartI * yEndI
   IF crossI > 0 OR ( crossI == 0 AND dotI < 0 )
    weightI = ProcGetWrappedW( pointerJI )
    windowWeightSumI = windowWeightSumI + weightI
    windowWeightSquareSumI = windowWeightSquareSumI + weightI * weightI
    pointerJI = pointerJI + 1
   ELSE
    BREAK
   ENDIF
  ENDWHILE
  pairWeightI = ( windowWeightSumI * windowWeightSumI - windowWeightSquareSumI ) / 2
  weightI = ProcGetWrappedW( indexI )
  termS = ProcMultiplyStringBySmall( ProcIntegerToString( pairWeightI ), weightI )
  badTriplesS = ProcAddDecimalStrings( badTriplesS, termS )
  IF indexI + 1 < pointerJI
   removeWeightI = ProcGetWrappedW( indexI + 1 )
   windowWeightSumI = windowWeightSumI - removeWeightI
   windowWeightSquareSumI = windowWeightSquareSumI - removeWeightI * removeWeightI
  ENDIF
 ENDFOR
 answerS = ProcSubtractDecimalStrings( totalTriplesS, badTriplesS )
 RETURN( answerS )
END

proc Main()
 string answerS[255] = ""
 //
 gFirstXBufferI = CreateTempBuffer()
 gFirstYBufferI = CreateTempBuffer()
 gFirstWBufferI = CreateTempBuffer()
 gFullXBufferI  = CreateTempBuffer()
 gFullYBufferI  = CreateTempBuffer()
 gFullWBufferI  = CreateTempBuffer()
 ProcBuildFirstQuadrant()
 ProcBuildFullDirections()
 answerS = ProcComputeAnswer()
 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
 AbandonFile( gFullWBufferI )
 AbandonFile( gFullYBufferI )
 AbandonFile( gFullXBufferI )
 AbandonFile( gFirstWBufferI )
 AbandonFile( gFirstYBufferI )
 AbandonFile( gFirstXBufferI )
END
