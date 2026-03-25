// eulerproject0196ChatGPT.s
// <version>1.0.0.0.7</version>
// History:
// 1.0.0.0.1  2026-03-25  Initial full pure TSE SAL version for Project Euler 196
//                        Created by GPT-5.4 Thinking
// 1.0.0.0.2  2026-03-25  Removed redefinitions of TRUE/FALSE and removed
//                        string #define constants causing type mismatch
//                        Created by GPT-5.4 Thinking
// 1.0.0.0.3  2026-03-25  Benchmark test version
//                        Created by GPT-5.4 Thinking
// 1.0.0.0.4  2026-03-25  Additional segmented sieve attempt
//                        Created by GPT-5.4 Thinking
// 1.0.0.0.5  2026-03-25  Replaced triplet detection with direct 3x3-center method
//                        Created by GPT-5.4 Thinking
// 1.0.0.0.6  2026-03-25  Diagnostic version for rows 7, 8, 9
//                        Created by GPT-5.4 Thinking
// 1.0.0.0.7  2026-03-25  Fixed real bug in BuildSegmentCompositeMap:
//                        restore/read prime buffer correctly in every loop iteration
//                        Created by GPT-5.4 Thinking

#define CHUNK_SIZE         250
#define PRIME_SIEVE_LIMIT  5100000

INTEGER gChunkCacheBufferI = 0
INTEGER gChunkCacheLineI   = 0
INTEGER gChunkCacheDirtyB  = FALSE
STRING  gChunkCacheTextS[255] = ""

FORWARD STRING  PROC StringTrimLeadingZeros( STRING numberS )
FORWARD INTEGER PROC StringCompareNumbers( STRING leftS, STRING rightS )
FORWARD STRING  PROC StringAddNumbers( STRING leftS, STRING rightS )
FORWARD STRING  PROC StringAddSmall( STRING leftS, INTEGER addI )
FORWARD STRING  PROC StringSubtractNumbers( STRING leftS, STRING rightS )
FORWARD STRING  PROC StringMultiplySmall( STRING leftS, INTEGER mulI )
FORWARD STRING  PROC StringDivideSmall( STRING leftS, INTEGER divI )
FORWARD INTEGER PROC StringModSmall( STRING leftS, INTEGER divI )
FORWARD INTEGER PROC StringIsEven( STRING leftS )
FORWARD INTEGER PROC StringToIntegerSafe( STRING textS )
FORWARD STRING  PROC IntegerToStringSafe( INTEGER numberI )
FORWARD STRING  PROC StringRepeat( STRING charS, INTEGER countI )

FORWARD PROC    ChunkCacheFlush()
FORWARD PROC    ChunkCacheLoadLine( INTEGER bufferI, INTEGER lineI )
FORWARD STRING  PROC ChunkGetChar( INTEGER bufferI, INTEGER indexI )
FORWARD PROC    ChunkSetChar( INTEGER bufferI, INTEGER indexI, STRING charS )
FORWARD INTEGER PROC CreateChunkBuffer( INTEGER itemCountI, STRING fillCharS )

FORWARD INTEGER PROC CreatePrimeListBuffer()

FORWARD STRING  PROC RowStartString( INTEGER rowI )
FORWARD INTEGER PROC RowOffsetInside5Rows( INTEGER baseRowI, INTEGER rowI )
FORWARD INTEGER PROC SegmentLengthForTargetRow( INTEGER targetRowI )

FORWARD INTEGER PROC SegmentOddFirstOffset( STRING segmentStartS )
FORWARD INTEGER PROC SegmentOddIndex( INTEGER offsetI, INTEGER firstOddOffsetI )
FORWARD INTEGER PROC SegmentOddCount( INTEGER segmentLengthI, INTEGER firstOddOffsetI )

FORWARD PROC    BuildSegmentCompositeMap(
                    INTEGER primeListBufferI,
                    STRING  segmentStartS,
                    INTEGER segmentLengthI,
                    INTEGER compositeBufferI,
                    INTEGER firstOddOffsetI )

FORWARD INTEGER PROC IsPrimeInSegment(
                    STRING  segmentStartS,
                    INTEGER segmentLengthI,
                    INTEGER compositeBufferI,
                    INTEGER firstOddOffsetI,
                    INTEGER offsetI )

FORWARD INTEGER PROC IsPrimeAtRowCol(
                    INTEGER baseRowI,
                    STRING  segmentStartS,
                    INTEGER segmentLengthI,
                    INTEGER compositeBufferI,
                    INTEGER firstOddOffsetI,
                    INTEGER rowI,
                    INTEGER colI )

FORWARD INTEGER PROC GetAbsoluteOffsetIn5Rows(
                    INTEGER baseRowI,
                    INTEGER rowI,
                    INTEGER colI )

FORWARD INTEGER PROC CountPrimesInNeighborhood(
                    INTEGER baseRowI,
                    STRING  segmentStartS,
                    INTEGER segmentLengthI,
                    INTEGER compositeBufferI,
                    INTEGER firstOddOffsetI,
                    INTEGER rowI,
                    INTEGER colI )

FORWARD STRING  PROC ComputeSOfRow( INTEGER targetRowI, INTEGER primeListBufferI )
FORWARD STRING  PROC ComputeFinalAnswer()

STRING PROC StringTrimLeadingZeros( STRING numberS )
 STRING workS[255] = numberS
 INTEGER indexI = 1
 //
 WHILE ( indexI < Length( workS ) ) AND ( SubStr( workS, indexI, 1 ) == "0" )
  indexI = indexI + 1
 ENDWHILE
 //
 Return( SubStr( workS, indexI, Length( workS ) - indexI + 1 ) )
END

INTEGER PROC StringCompareNumbers( STRING leftS, STRING rightS )
 STRING aS[255] = StringTrimLeadingZeros( leftS )
 STRING bS[255] = StringTrimLeadingZeros( rightS )
 INTEGER lenA_I = Length( aS )
 INTEGER lenB_I = Length( bS )
 //
 IF lenA_I < lenB_I
  Return( -1 )
 ENDIF
 //
 IF lenA_I > lenB_I
  Return( 1 )
 ENDIF
 //
 IF aS == bS
  Return( 0 )
 ENDIF
 //
 IF aS < bS
  Return( -1 )
 ENDIF
 //
 Return( 1 )
END

STRING PROC StringAddNumbers( STRING leftS, STRING rightS )
 STRING aS[255] = StringTrimLeadingZeros( leftS )
 STRING bS[255] = StringTrimLeadingZeros( rightS )
 STRING resultS[255] = ""
 INTEGER carryI = 0
 INTEGER indexA_I = Length( aS )
 INTEGER indexB_I = Length( bS )
 INTEGER digitA_I = 0
 INTEGER digitB_I = 0
 INTEGER sumI = 0
 //
 WHILE ( indexA_I > 0 ) OR ( indexB_I > 0 ) OR ( carryI > 0 )
  digitA_I = 0
  digitB_I = 0
  //
  IF indexA_I > 0
   digitA_I = Val( SubStr( aS, indexA_I, 1 ) )
   indexA_I = indexA_I - 1
  ENDIF
  //
  IF indexB_I > 0
   digitB_I = Val( SubStr( bS, indexB_I, 1 ) )
   indexB_I = indexB_I - 1
  ENDIF
  //
  sumI   = digitA_I + digitB_I + carryI
  carryI = sumI / 10
  resultS = Chr( 48 + ( sumI mod 10 ) ) + resultS
 ENDWHILE
 //
 Return( StringTrimLeadingZeros( resultS ) )
END

STRING PROC StringAddSmall( STRING leftS, INTEGER addI )
 STRING addS[255] = IntegerToStringSafe( addI )
 //
 Return( StringAddNumbers( leftS, addS ) )
END

STRING PROC StringSubtractNumbers( STRING leftS, STRING rightS )
 STRING aS[255] = StringTrimLeadingZeros( leftS )
 STRING bS[255] = StringTrimLeadingZeros( rightS )
 STRING resultS[255] = ""
 INTEGER borrowI = 0
 INTEGER indexA_I = Length( aS )
 INTEGER indexB_I = Length( bS )
 INTEGER digitA_I = 0
 INTEGER digitB_I = 0
 INTEGER diffI = 0
 //
 IF StringCompareNumbers( aS, bS ) < 0
  Return( "0" )
 ENDIF
 //
 WHILE indexA_I > 0
  digitA_I = Val( SubStr( aS, indexA_I, 1 ) ) - borrowI
  digitB_I = 0
  //
  IF indexB_I > 0
   digitB_I = Val( SubStr( bS, indexB_I, 1 ) )
   indexB_I = indexB_I - 1
  ENDIF
  //
  IF digitA_I < digitB_I
   digitA_I = digitA_I + 10
   borrowI = 1
  ELSE
   borrowI = 0
  ENDIF
  //
  diffI = digitA_I - digitB_I
  resultS = Chr( 48 + diffI ) + resultS
  indexA_I = indexA_I - 1
 ENDWHILE
 //
 Return( StringTrimLeadingZeros( resultS ) )
END

STRING PROC StringMultiplySmall( STRING leftS, INTEGER mulI )
 STRING aS[255] = StringTrimLeadingZeros( leftS )
 STRING resultS[255] = ""
 INTEGER carryI = 0
 INTEGER indexI = Length( aS )
 INTEGER digitI = 0
 INTEGER prodI = 0
 //
 IF mulI == 0
  Return( "0" )
 ENDIF
 //
 IF mulI == 1
  Return( aS )
 ENDIF
 //
 WHILE ( indexI > 0 ) OR ( carryI > 0 )
  digitI = 0
  //
  IF indexI > 0
   digitI = Val( SubStr( aS, indexI, 1 ) )
   indexI = indexI - 1
  ENDIF
  //
  prodI   = digitI * mulI + carryI
  carryI  = prodI / 10
  resultS = Chr( 48 + ( prodI mod 10 ) ) + resultS
 ENDWHILE
 //
 Return( StringTrimLeadingZeros( resultS ) )
END

STRING PROC StringDivideSmall( STRING leftS, INTEGER divI )
 STRING aS[255] = StringTrimLeadingZeros( leftS )
 STRING resultS[255] = ""
 INTEGER carryI = 0
 INTEGER indexI = 1
 INTEGER curI = 0
 INTEGER qI = 0
 //
 WHILE indexI <= Length( aS )
  curI = carryI * 10 + Val( SubStr( aS, indexI, 1 ) )
  qI = curI / divI
  carryI = curI mod divI
  resultS = resultS + Chr( 48 + qI )
  indexI = indexI + 1
 ENDWHILE
 //
 Return( StringTrimLeadingZeros( resultS ) )
END

INTEGER PROC StringModSmall( STRING leftS, INTEGER divI )
 STRING aS[255] = StringTrimLeadingZeros( leftS )
 INTEGER carryI = 0
 INTEGER indexI = 1
 //
 WHILE indexI <= Length( aS )
  carryI = ( carryI * 10 + Val( SubStr( aS, indexI, 1 ) ) ) mod divI
  indexI = indexI + 1
 ENDWHILE
 //
 Return( carryI )
END

INTEGER PROC StringIsEven( STRING leftS )
 STRING aS[255] = StringTrimLeadingZeros( leftS )
 INTEGER lastDigitI = Val( SubStr( aS, Length( aS ), 1 ) )
 //
 Return( ( lastDigitI mod 2 ) == 0 )
END

INTEGER PROC StringToIntegerSafe( STRING textS )
 Return( Val( textS ) )
END

STRING PROC IntegerToStringSafe( INTEGER numberI )
 Return( Format( numberI ) )
END

STRING PROC StringRepeat( STRING charS, INTEGER countI )
 STRING resultS[255] = ""
 INTEGER indexI = 1
 //
 WHILE indexI <= countI
  resultS = resultS + charS
  indexI = indexI + 1
 ENDWHILE
 //
 Return( resultS )
END

PROC ChunkCacheFlush()
 //
 IF ( gChunkCacheBufferI > 0 ) AND ( gChunkCacheLineI > 0 ) AND gChunkCacheDirtyB
  GotoBufferId( gChunkCacheBufferI )
  GotoLine( gChunkCacheLineI )
  BegLine()
  KillToEol()
  InsertText( gChunkCacheTextS )
  gChunkCacheDirtyB = FALSE
 ENDIF
END

PROC ChunkCacheLoadLine( INTEGER bufferI, INTEGER lineI )
 STRING textS[255] = ""
 //
 IF ( gChunkCacheBufferI == bufferI ) AND ( gChunkCacheLineI == lineI )
  Return()
 ENDIF
 //
 ChunkCacheFlush()
 //
 GotoBufferId( bufferI )
 GotoLine( lineI )
 BegLine()
 textS = GetText( 1, CurrLineLen() )
 //
 gChunkCacheBufferI = bufferI
 gChunkCacheLineI   = lineI
 gChunkCacheTextS   = textS
 gChunkCacheDirtyB  = FALSE
END

STRING PROC ChunkGetChar( INTEGER bufferI, INTEGER indexI )
 INTEGER lineI = ( indexI / CHUNK_SIZE ) + 1
 INTEGER colI  = ( indexI mod CHUNK_SIZE ) + 1
 //
 ChunkCacheLoadLine( bufferI, lineI )
 Return( SubStr( gChunkCacheTextS, colI, 1 ) )
END

PROC ChunkSetChar( INTEGER bufferI, INTEGER indexI, STRING charS )
 INTEGER lineI = ( indexI / CHUNK_SIZE ) + 1
 INTEGER colI  = ( indexI mod CHUNK_SIZE ) + 1
 STRING leftS[255] = ""
 STRING rightS[255] = ""
 //
 ChunkCacheLoadLine( bufferI, lineI )
 //
 IF colI > 1
  leftS = SubStr( gChunkCacheTextS, 1, colI - 1 )
 ENDIF
 //
 IF colI < Length( gChunkCacheTextS )
  rightS = SubStr( gChunkCacheTextS, colI + 1, Length( gChunkCacheTextS ) - colI )
 ENDIF
 //
 gChunkCacheTextS = leftS + charS + rightS
 gChunkCacheDirtyB = TRUE
END

INTEGER PROC CreateChunkBuffer( INTEGER itemCountI, STRING fillCharS )
 INTEGER bufferI = 0
 INTEGER lineCountI = 0
 STRING lineS[255] = ""
 //
 bufferI = CreateTempBuffer()
 lineCountI = itemCountI / CHUNK_SIZE
 IF ( itemCountI mod CHUNK_SIZE ) > 0
  lineCountI = lineCountI + 1
 ENDIF
 //
 lineS = StringRepeat( fillCharS, CHUNK_SIZE )
 //
 GotoBufferId( bufferI )
 //
 WHILE NumLines() > 0
  BegFile()
  KillLine()
 ENDWHILE
 //
 WHILE lineCountI > 0
  AddLine( lineS, bufferI )
  lineCountI = lineCountI - 1
 ENDWHILE
 //
 Return( bufferI )
END

INTEGER PROC CreatePrimeListBuffer()
 INTEGER sieveBufferI = 0
 INTEGER primeBufferI = 0
 INTEGER oddCountI = 0
 INTEGER candidateIndexI = 0
 INTEGER candidateI = 0
 INTEGER markI = 0
 INTEGER limitRootI = 2258
 //
 oddCountI = ( PRIME_SIEVE_LIMIT - 3 ) / 2 + 1
 sieveBufferI = CreateChunkBuffer( oddCountI, "0" )
 primeBufferI = CreateTempBuffer()
 //
 AddLine( "2", primeBufferI )
 //
 candidateIndexI = 0
 WHILE candidateIndexI < oddCountI
  IF ChunkGetChar( sieveBufferI, candidateIndexI ) == "0"
   candidateI = 3 + candidateIndexI * 2
   AddLine( Format( candidateI ), primeBufferI )
   //
   IF candidateI <= limitRootI
    markI = ( candidateI * candidateI - 3 ) / 2
    WHILE markI < oddCountI
     ChunkSetChar( sieveBufferI, markI, "1" )
     markI = markI + candidateI
    ENDWHILE
   ENDIF
  ENDIF
  candidateIndexI = candidateIndexI + 1
 ENDWHILE
 //
 ChunkCacheFlush()
 AbandonFile( sieveBufferI )
 //
 Return( primeBufferI )
END

STRING PROC RowStartString( INTEGER rowI )
 STRING resultS[255] = "0"
 //
 resultS = IntegerToStringSafe( rowI )
 resultS = StringMultiplySmall( resultS, rowI - 1 )
 resultS = StringDivideSmall( resultS, 2 )
 resultS = StringAddSmall( resultS, 1 )
 //
 Return( resultS )
END

INTEGER PROC RowOffsetInside5Rows( INTEGER baseRowI, INTEGER rowI )
 INTEGER curRowI = baseRowI
 INTEGER offsetI = 0
 //
 WHILE curRowI < rowI
  offsetI = offsetI + curRowI
  curRowI = curRowI + 1
 ENDWHILE
 //
 Return( offsetI )
END

INTEGER PROC SegmentLengthForTargetRow( INTEGER targetRowI )
 Return( ( targetRowI - 2 ) + ( targetRowI - 1 ) + targetRowI + ( targetRowI + 1 ) + ( targetRowI + 2 ) )
END

INTEGER PROC SegmentOddFirstOffset( STRING segmentStartS )
 IF StringIsEven( segmentStartS )
  Return( 1 )
 ENDIF
 //
 Return( 0 )
END

INTEGER PROC SegmentOddIndex( INTEGER offsetI, INTEGER firstOddOffsetI )
 Return( ( offsetI - firstOddOffsetI ) / 2 )
END

INTEGER PROC SegmentOddCount( INTEGER segmentLengthI, INTEGER firstOddOffsetI )
 INTEGER usableI = segmentLengthI - firstOddOffsetI
 //
 IF usableI <= 0
  Return( 0 )
 ENDIF
 //
 Return( ( usableI + 1 ) / 2 )
END

PROC BuildSegmentCompositeMap(
        INTEGER primeListBufferI,
        STRING  segmentStartS,
        INTEGER segmentLengthI,
        INTEGER compositeBufferI,
        INTEGER firstOddOffsetI )
 INTEGER primeLineCountI = 0
 INTEGER lineI = 1
 INTEGER primeI = 0
 INTEGER startRemainderI = 0
 INTEGER firstOffsetI = 0
 INTEGER oddIndexI = 0
 INTEGER stepI = 0
 //
 GotoBufferId( primeListBufferI )
 primeLineCountI = NumLines()
 //
 WHILE lineI <= primeLineCountI
  GotoBufferId( primeListBufferI )
  GotoLine( lineI )
  primeI = Val( GetText( 1, CurrLineLen() ) )
  //
  IF primeI > 2
   startRemainderI = StringModSmall( segmentStartS, primeI )
   //
   IF startRemainderI == 0
    firstOffsetI = 0
   ELSE
    firstOffsetI = primeI - startRemainderI
   ENDIF
   //
   IF StringIsEven( StringAddSmall( segmentStartS, firstOffsetI ) )
    firstOffsetI = firstOffsetI + primeI
   ENDIF
   //
   stepI = primeI * 2
   //
   WHILE firstOffsetI < segmentLengthI
    oddIndexI = SegmentOddIndex( firstOffsetI, firstOddOffsetI )
    IF oddIndexI >= 0
     ChunkSetChar( compositeBufferI, oddIndexI, "1" )
    ENDIF
    firstOffsetI = firstOffsetI + stepI
   ENDWHILE
  ENDIF
  //
  lineI = lineI + 1
 ENDWHILE
 //
 ChunkCacheFlush()
 //
 IF StringCompareNumbers( segmentStartS, "1" ) <= 0
  IF firstOddOffsetI == 0
   ChunkSetChar( compositeBufferI, 0, "1" )
  ENDIF
  ChunkCacheFlush()
 ENDIF
END

INTEGER PROC IsPrimeInSegment(
        STRING  segmentStartS,
        INTEGER segmentLengthI,
        INTEGER compositeBufferI,
        INTEGER firstOddOffsetI,
        INTEGER offsetI )
 STRING numberS[255] = ""
 INTEGER oddIndexI = 0
 //
 IF ( offsetI < 0 ) OR ( offsetI >= segmentLengthI )
  Return( FALSE )
 ENDIF
 //
 numberS = StringAddSmall( segmentStartS, offsetI )
 //
 IF numberS == "2"
  Return( TRUE )
 ENDIF
 //
 IF StringCompareNumbers( numberS, "2" ) < 0
  Return( FALSE )
 ENDIF
 //
 IF StringIsEven( numberS )
  Return( FALSE )
 ENDIF
 //
 oddIndexI = SegmentOddIndex( offsetI, firstOddOffsetI )
 IF oddIndexI < 0
  Return( FALSE )
 ENDIF
 //
 Return( ChunkGetChar( compositeBufferI, oddIndexI ) == "0" )
END

INTEGER PROC IsPrimeAtRowCol(
        INTEGER baseRowI,
        STRING  segmentStartS,
        INTEGER segmentLengthI,
        INTEGER compositeBufferI,
        INTEGER firstOddOffsetI,
        INTEGER rowI,
        INTEGER colI )
 INTEGER offsetI = 0
 //
 IF rowI < baseRowI
  Return( FALSE )
 ENDIF
 //
 IF rowI > baseRowI + 4
  Return( FALSE )
 ENDIF
 //
 IF colI < 1
  Return( FALSE )
 ENDIF
 //
 IF colI > rowI
  Return( FALSE )
 ENDIF
 //
 offsetI = RowOffsetInside5Rows( baseRowI, rowI ) + ( colI - 1 )
 //
 Return(
  IsPrimeInSegment(
   segmentStartS,
   segmentLengthI,
   compositeBufferI,
   firstOddOffsetI,
   offsetI ) )
END

INTEGER PROC GetAbsoluteOffsetIn5Rows(
        INTEGER baseRowI,
        INTEGER rowI,
        INTEGER colI )
 Return( RowOffsetInside5Rows( baseRowI, rowI ) + ( colI - 1 ) )
END

INTEGER PROC CountPrimesInNeighborhood(
        INTEGER baseRowI,
        STRING  segmentStartS,
        INTEGER segmentLengthI,
        INTEGER compositeBufferI,
        INTEGER firstOddOffsetI,
        INTEGER rowI,
        INTEGER colI )
 INTEGER countI = 0
 INTEGER deltaRowI = 0
 INTEGER deltaColI = 0
 INTEGER testRowI = 0
 INTEGER testColI = 0
 //
 FOR deltaRowI = -1 TO 1 BY 1
  FOR deltaColI = -1 TO 1 BY 1
   testRowI = rowI + deltaRowI
   testColI = colI + deltaColI
   IF IsPrimeAtRowCol(
       baseRowI,
       segmentStartS,
       segmentLengthI,
       compositeBufferI,
       firstOddOffsetI,
       testRowI,
       testColI )
    countI = countI + 1
   ENDIF
  ENDFOR
 ENDFOR
 //
 Return( countI )
END

STRING PROC ComputeSOfRow( INTEGER targetRowI, INTEGER primeListBufferI )
 INTEGER baseRowI = targetRowI - 2
 INTEGER segmentLengthI = 0
 STRING segmentStartS[255] = ""
 INTEGER firstOddOffsetI = 0
 INTEGER oddCountI = 0
 INTEGER compositeBufferI = 0
 INTEGER threePlusBufferI = 0
 INTEGER rowI = 0
 INTEGER colI = 0
 INTEGER deltaRowI = 0
 INTEGER deltaColI = 0
 INTEGER testRowI = 0
 INTEGER testColI = 0
 INTEGER offsetI = 0
 INTEGER atLeastThreeB = FALSE
 STRING rowStartS[255] = ""
 STRING valueS[255] = ""
 STRING sumS[255] = "0"
 //
 segmentLengthI = SegmentLengthForTargetRow( targetRowI )
 segmentStartS  = RowStartString( baseRowI )
 firstOddOffsetI = SegmentOddFirstOffset( segmentStartS )
 oddCountI = SegmentOddCount( segmentLengthI, firstOddOffsetI )
 //
 compositeBufferI = CreateChunkBuffer( oddCountI, "0" )
 threePlusBufferI = CreateChunkBuffer( segmentLengthI, "0" )
 //
 BuildSegmentCompositeMap(
  primeListBufferI,
  segmentStartS,
  segmentLengthI,
  compositeBufferI,
  firstOddOffsetI )
 //
 FOR rowI = targetRowI - 1 TO targetRowI + 1 BY 1
  FOR colI = 1 TO rowI BY 1
   IF IsPrimeAtRowCol(
       baseRowI,
       segmentStartS,
       segmentLengthI,
       compositeBufferI,
       firstOddOffsetI,
       rowI,
       colI )
    IF CountPrimesInNeighborhood(
        baseRowI,
        segmentStartS,
        segmentLengthI,
        compositeBufferI,
        firstOddOffsetI,
        rowI,
        colI ) >= 3
     offsetI = GetAbsoluteOffsetIn5Rows( baseRowI, rowI, colI )
     ChunkSetChar( threePlusBufferI, offsetI, "1" )
    ENDIF
   ENDIF
  ENDFOR
 ENDFOR
 //
 ChunkCacheFlush()
 //
 rowStartS = RowStartString( targetRowI )
 //
 FOR colI = 1 TO targetRowI BY 1
  IF IsPrimeAtRowCol(
      baseRowI,
      segmentStartS,
      segmentLengthI,
      compositeBufferI,
      firstOddOffsetI,
      targetRowI,
      colI )
   atLeastThreeB = FALSE
   //
   FOR deltaRowI = -1 TO 1 BY 1
    FOR deltaColI = -1 TO 1 BY 1
     testRowI = targetRowI + deltaRowI
     testColI = colI + deltaColI
     IF testRowI >= baseRowI
      IF testRowI <= baseRowI + 4
       IF testColI >= 1
        IF testColI <= testRowI
         offsetI = GetAbsoluteOffsetIn5Rows( baseRowI, testRowI, testColI )
         IF ChunkGetChar( threePlusBufferI, offsetI ) == "1"
          atLeastThreeB = TRUE
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
   ENDFOR
   //
   IF atLeastThreeB
    valueS = StringAddSmall( rowStartS, colI - 1 )
    sumS = StringAddNumbers( sumS, valueS )
   ENDIF
  ENDIF
 ENDFOR
 //
 ChunkCacheFlush()
 AbandonFile( compositeBufferI )
 AbandonFile( threePlusBufferI )
 //
 Return( sumS )
END

STRING PROC ComputeFinalAnswer()
 INTEGER primeListBufferI = 0
 STRING s1S[255] = ""
 STRING s2S[255] = ""
 STRING answerS[255] = ""
 //
 primeListBufferI = CreatePrimeListBuffer()
 //
 s1S = ComputeSOfRow( 5678027, primeListBufferI )
 s2S = ComputeSOfRow( 7208785, primeListBufferI )
 answerS = StringAddNumbers( s1S, s2S )
 //
 AbandonFile( primeListBufferI )
 //
 Return( answerS )
END

PROC Main()
 STRING answerS[255] = ""
 //
 answerS = ComputeFinalAnswer()
 //
 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
END
