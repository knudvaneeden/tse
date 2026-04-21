// Project Euler 310 - Nim Square
// Pure TSE SAL solution.
// The answer is computed; it is not hard coded.
// Counting idea:
// 1) Compute Grundy values g(0..100000) for the square-removal subtraction game.
// 2) Let A be the number of ordered triples (x,y,z) with g(x)^g(y)^g(z)==0.
// 3) The required number of nondecreasing triples is
//      ( A + count0 * ( 3 * LIMIT_N_K + 5 ) ) / 6
//    where count0 is the number of heap sizes with Grundy value 0.

#DEFINE LIMIT_N_K          100000
#DEFINE SEGMENT_BITS_K     31
#DEFINE GRUNDY_OFFSET_K    33
#DEFINE ASCII_ZERO_K       48
#DEFINE VERSION_K          1
#DEFINE HISTORY_ID_K       1

STRING PROC FNTrimLeadingZerosS( STRING numberS )
 STRING workS[255] = ""
 INTEGER indexI = 1
 workS = numberS
 WHILE ( indexI < Length( workS ) ) AND ( SubStr( workS, indexI, 1 ) == "0" )
  indexI = indexI + 1
 ENDWHILE
 return( SubStr( workS, indexI, SizeOf( workS ) ) )
END

STRING PROC FNBigAddS( STRING firstNumberS, STRING secondNumberS )
 STRING workFirstS[255] = ""
 STRING workSecondS[255] = ""
 STRING resultS[255] = ""
 INTEGER indexFirstI = 0
 INTEGER indexSecondI = 0
 INTEGER digitFirstI = 0
 INTEGER digitSecondI = 0
 INTEGER digitSumI = 0
 INTEGER carryI = 0
 workFirstS = firstNumberS
 workSecondS = secondNumberS
 resultS = ""
 indexFirstI = Length( workFirstS )
 indexSecondI = Length( workSecondS )
 WHILE ( indexFirstI > 0 ) OR ( indexSecondI > 0 ) OR ( carryI > 0 )
  digitFirstI = 0
  digitSecondI = 0
  IF indexFirstI > 0
   digitFirstI = Asc( SubStr( workFirstS, indexFirstI, 1 ) ) - ASCII_ZERO_K
   indexFirstI = indexFirstI - 1
  ENDIF
  IF indexSecondI > 0
   digitSecondI = Asc( SubStr( workSecondS, indexSecondI, 1 ) ) - ASCII_ZERO_K
   indexSecondI = indexSecondI - 1
  ENDIF
  digitSumI = digitFirstI + digitSecondI + carryI
  resultS = Chr( ASCII_ZERO_K + ( digitSumI mod 10 ) ) + resultS
  carryI = digitSumI / 10
 ENDWHILE
 return( FNTrimLeadingZerosS( resultS ) )
END

STRING PROC FNBigMulSmallS( STRING numberS, INTEGER factorI )
 STRING workS[255] = ""
 STRING resultS[255] = ""
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER productI = 0
 INTEGER carryI = 0
 workS = numberS
 IF factorI == 0
  return( "0" )
 ENDIF
 IF factorI == 1
  return( FNTrimLeadingZerosS( workS ) )
 ENDIF
 resultS = ""
 carryI = 0
 indexI = Length( workS )
 WHILE indexI > 0
  digitI = Asc( SubStr( workS, indexI, 1 ) ) - ASCII_ZERO_K
  productI = digitI * factorI + carryI
  resultS = Chr( ASCII_ZERO_K + ( productI mod 10 ) ) + resultS
  carryI = productI / 10
  indexI = indexI - 1
 ENDWHILE
 WHILE carryI > 0
  resultS = Chr( ASCII_ZERO_K + ( carryI mod 10 ) ) + resultS
  carryI = carryI / 10
 ENDWHILE
 return( FNTrimLeadingZerosS( resultS ) )
END

STRING PROC FNBigDivSmallS( STRING numberS, INTEGER divisorI )
 STRING workS[255] = ""
 STRING resultS[255] = ""
 INTEGER indexI = 0
 INTEGER digitI = 0
 INTEGER valueI = 0
 INTEGER quotientDigitI = 0
 INTEGER remainderI = 0
 workS = numberS
 resultS = ""
 remainderI = 0
 FOR indexI = 1 TO Length( workS )
  digitI = Asc( SubStr( workS, indexI, 1 ) ) - ASCII_ZERO_K
  valueI = remainderI * 10 + digitI
  quotientDigitI = valueI / divisorI
  remainderI = valueI mod divisorI
  resultS = resultS + Chr( ASCII_ZERO_K + quotientDigitI )
 ENDFOR
 return( FNTrimLeadingZerosS( resultS ) )
END

STRING PROC FNCountNameS( INTEGER grundyI )
 STRING countNameS[32] = ""
 countNameS = Format( "count_", grundyI )
 return( countNameS )
END

INTEGER PROC FNGetCountI( INTEGER bufferI, INTEGER grundyI )
 STRING countNameS[32] = ""
 countNameS = FNCountNameS( grundyI )
 return( GetBufferInt( countNameS, bufferI ) )
END

PROC PROCIncrementCount( INTEGER bufferI, INTEGER grundyI )
 STRING countNameS[32] = ""
 INTEGER countI = 0
 countNameS = FNCountNameS( grundyI )
 countI = GetBufferInt( countNameS, bufferI )
 SetBufferInt( countNameS, countI + 1, bufferI )
END

PROC Main()
 INTEGER grundyBufferI = 0
 INTEGER nI = 0
 INTEGER squareI = 0
 INTEGER deltaI = 0
 INTEGER lookUpLineI = 0
 INTEGER moveGrundyI = 0
 INTEGER mexI = 0
 INTEGER maxGrundyI = 0
 INTEGER seen0I = 0
 INTEGER seen1I = 0
 INTEGER seen2I = 0
 INTEGER seen3I = 0
 INTEGER bitI = 0
 INTEGER zeroCountI = 0
 INTEGER firstGrundyI = 0
 INTEGER secondGrundyI = 0
 INTEGER thirdGrundyI = 0
 INTEGER firstCountI = 0
 INTEGER secondCountI = 0
 INTEGER thirdCountI = 0
 INTEGER pairCountI = 0
 INTEGER adjustmentI = 0
 STRING oneCharS[1] = ""
 STRING orderedTotalS[255] = ""
 STRING termS[255] = ""
 STRING resultS[255] = ""
 PushLocation()
 grundyBufferI = CreateTempBuffer()
 BegFile()
 KillToEol()
 InsertText( Chr( GRUNDY_OFFSET_K ) )
 PROCIncrementCount( grundyBufferI, 0 )
 FOR nI = 1 TO LIMIT_N_K
  seen0I = 0
  seen1I = 0
  seen2I = 0
  seen3I = 0
  squareI = 1
  deltaI = 3
  WHILE squareI <= nI
   lookUpLineI = nI - squareI + 1
   GotoLine( lookUpLineI )
   oneCharS = GetText( 1, 1 )
   moveGrundyI = Asc( oneCharS ) - GRUNDY_OFFSET_K
   IF moveGrundyI < SEGMENT_BITS_K
    bitI = 1 shl moveGrundyI
    seen0I = seen0I | bitI
   ELSEIF moveGrundyI < ( 2 * SEGMENT_BITS_K )
    bitI = 1 shl ( moveGrundyI - SEGMENT_BITS_K )
    seen1I = seen1I | bitI
   ELSEIF moveGrundyI < ( 3 * SEGMENT_BITS_K )
    bitI = 1 shl ( moveGrundyI - 2 * SEGMENT_BITS_K )
    seen2I = seen2I | bitI
   ELSE
    bitI = 1 shl ( moveGrundyI - 3 * SEGMENT_BITS_K )
    seen3I = seen3I | bitI
   ENDIF
   squareI = squareI + deltaI
   deltaI = deltaI + 2
  ENDWHILE
  mexI = 0
  WHILE TRUE
   IF mexI < SEGMENT_BITS_K
    bitI = 1 shl mexI
    IF ( seen0I & bitI ) == 0
     BREAK
    ENDIF
   ELSEIF mexI < ( 2 * SEGMENT_BITS_K )
    bitI = 1 shl ( mexI - SEGMENT_BITS_K )
    IF ( seen1I & bitI ) == 0
     BREAK
    ENDIF
   ELSEIF mexI < ( 3 * SEGMENT_BITS_K )
    bitI = 1 shl ( mexI - 2 * SEGMENT_BITS_K )
    IF ( seen2I & bitI ) == 0
     BREAK
    ENDIF
   ELSE
    bitI = 1 shl ( mexI - 3 * SEGMENT_BITS_K )
    IF ( seen3I & bitI ) == 0
     BREAK
    ENDIF
   ENDIF
   mexI = mexI + 1
  ENDWHILE
  IF mexI > maxGrundyI
   maxGrundyI = mexI
  ENDIF
  EndFile()
  AddLine( Chr( GRUNDY_OFFSET_K + mexI ) )
  PROCIncrementCount( grundyBufferI, mexI )
 ENDFOR
 orderedTotalS = "0"
 FOR firstGrundyI = 0 TO maxGrundyI
  firstCountI = FNGetCountI( grundyBufferI, firstGrundyI )
  IF firstCountI > 0
   FOR secondGrundyI = 0 TO maxGrundyI
    secondCountI = FNGetCountI( grundyBufferI, secondGrundyI )
    IF secondCountI > 0
     thirdGrundyI = firstGrundyI ^ secondGrundyI
     IF thirdGrundyI <= maxGrundyI
      thirdCountI = FNGetCountI( grundyBufferI, thirdGrundyI )
      IF thirdCountI > 0
       pairCountI = firstCountI * secondCountI
       termS = FNBigMulSmallS( Format( pairCountI ), thirdCountI )
       orderedTotalS = FNBigAddS( orderedTotalS, termS )
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 zeroCountI = FNGetCountI( grundyBufferI, 0 )
 adjustmentI = zeroCountI * ( 3 * LIMIT_N_K + 5 )
 resultS = FNBigAddS( orderedTotalS, Format( adjustmentI ) )
 resultS = FNBigDivSmallS( resultS, 6 )
 AddHistoryStr( Format( "Project Euler 310 | LLM=ChatGPT GPT-5.4 Thinking | version=", VERSION_K ), HISTORY_ID_K )
 PopLocation()
 CopyToWinClip( resultS )
 Warn( resultS )
 CopyToWinClip( resultS )
 AbandonFile( grundyBufferI )
END
