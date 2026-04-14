// Project Euler problem 276
// Primitive Triangles
// Pure TSE SAL solution
// <version>1</version>
// History: 1 - ChatGPT

#define PERIMETER_LIMIT 10000000

INTEGER gResultBufferI = 0

STRING PROC ProcTrimLeadingZeros( STRING numberS )
  STRING workS[255] = ''
  INTEGER indexI = 1
  INTEGER lengthI = 0
  workS = numberS
  IF workS == ''
    RETURN( '0' )
  ENDIF
  lengthI = Length( workS )
  WHILE indexI < lengthI AND SubStr( workS, indexI, 1 ) == '0'
    indexI = indexI + 1
  ENDWHILE
  RETURN( SubStr( workS, indexI, lengthI - indexI + 1 ) )
END

INTEGER PROC ProcGetChunkFromRight( STRING numberS, INTEGER endPosI )
  INTEGER startI = 0
  INTEGER lengthI = 0
  STRING chunkS[16] = ''
  IF endPosI <= 0
    RETURN( 0 )
  ENDIF
  startI = endPosI - 3
  IF startI < 1
    startI = 1
  ENDIF
  lengthI = endPosI - startI + 1
  chunkS = SubStr( numberS, startI, lengthI )
  RETURN( Val( chunkS ) )
END

STRING PROC ProcAddBig( STRING leftS, STRING rightS )
  INTEGER leftEndI = 0
  INTEGER rightEndI = 0
  INTEGER leftChunkI = 0
  INTEGER rightChunkI = 0
  INTEGER carryI = 0
  INTEGER partI = 0
  STRING resultS[255] = ''
  leftEndI = Length( leftS )
  rightEndI = Length( rightS )
  WHILE leftEndI > 0 OR rightEndI > 0
    leftChunkI = ProcGetChunkFromRight( leftS, leftEndI )
    rightChunkI = ProcGetChunkFromRight( rightS, rightEndI )
    partI = leftChunkI + rightChunkI + carryI
    carryI = partI / 10000
    partI = partI mod 10000
    resultS = Format( partI : 4 : '0' ) + resultS
    leftEndI = leftEndI - 4
    rightEndI = rightEndI - 4
  ENDWHILE
  IF carryI > 0
    resultS = Format( carryI ) + resultS
  ENDIF
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcSubtractBig( STRING leftS, STRING rightS )
  INTEGER leftEndI = 0
  INTEGER rightEndI = 0
  INTEGER leftChunkI = 0
  INTEGER rightChunkI = 0
  INTEGER borrowI = 0
  INTEGER partI = 0
  STRING resultS[255] = ''
  leftEndI = Length( leftS )
  rightEndI = Length( rightS )
  WHILE leftEndI > 0 OR rightEndI > 0
    leftChunkI = ProcGetChunkFromRight( leftS, leftEndI )
    rightChunkI = ProcGetChunkFromRight( rightS, rightEndI )
    partI = leftChunkI - rightChunkI - borrowI
    IF partI < 0
      partI = partI + 10000
      borrowI = 1
    ELSE
      borrowI = 0
    ENDIF
    resultS = Format( partI : 4 : '0' ) + resultS
    leftEndI = leftEndI - 4
    rightEndI = rightEndI - 4
  ENDWHILE
  RETURN( ProcTrimLeadingZeros( resultS ) )
END

STRING PROC ProcMultiplyBigByInt( STRING numberS, INTEGER multiplierI )
  STRING resultS[255] = '0'
  STRING addendS[255] = ''
  INTEGER workMultiplierI = 0
  addendS = ProcTrimLeadingZeros( numberS )
  workMultiplierI = multiplierI
  IF workMultiplierI == 0 OR addendS == '0'
    RETURN( '0' )
  ENDIF
  WHILE workMultiplierI > 0
    IF ( workMultiplierI & 1 ) == 1
      resultS = ProcAddBig( resultS, addendS )
    ENDIF
    workMultiplierI = workMultiplierI shr 1
    IF workMultiplierI > 0
      addendS = ProcAddBig( addendS, addendS )
    ENDIF
  ENDWHILE
  RETURN( resultS )
END

INTEGER PROC ProcGetC1( INTEGER remainderI )
  CASE remainderI
    WHEN 0
      RETURN( 0 )
    WHEN 1
      RETURN( 2 )
    WHEN 2
      RETURN( 3 )
    WHEN 3
      RETURN( 6 )
    WHEN 4
      RETURN( 8 )
    WHEN 5
      RETURN( 12 )
    WHEN 6
      RETURN( 15 )
    WHEN 7
      RETURN( 20 )
    WHEN 8
      RETURN( 24 )
    WHEN 9
      RETURN( 30 )
    WHEN 10
      RETURN( 35 )
    OTHERWISE
      RETURN( 42 )
  ENDCASE
END

INTEGER PROC ProcGetC0( INTEGER remainderI )
  CASE remainderI
    WHEN 0
      RETURN( 0 )
    WHEN 1
      RETURN( 0 )
    WHEN 2
      RETURN( 0 )
    WHEN 3
      RETURN( 1 )
    WHEN 4
      RETURN( 1 )
    WHEN 5
      RETURN( 2 )
    WHEN 6
      RETURN( 3 )
    WHEN 7
      RETURN( 5 )
    WHEN 8
      RETURN( 6 )
    WHEN 9
      RETURN( 9 )
    WHEN 10
      RETURN( 11 )
    OTHERWISE
      RETURN( 15 )
  ENDCASE
END

STRING PROC ProcTotalTriangleCountUpTo( INTEGER limitI )
  INTEGER blockI = 0
  INTEGER remainderI = 0
  INTEGER c1I = 0
  INTEGER c0I = 0
  STRING blockS[255] = ''
  STRING squareS[255] = ''
  STRING cubeS[255] = ''
  STRING resultS[255] = '0'
  blockI = limitI / 12
  remainderI = limitI mod 12
  c1I = ProcGetC1( remainderI )
  c0I = ProcGetC0( remainderI )
  blockS = Format( blockI )
  squareS = ProcMultiplyBigByInt( blockS, blockI )
  cubeS = ProcMultiplyBigByInt( squareS, blockI )
  resultS = ProcAddBig( resultS, ProcMultiplyBigByInt( cubeS, 12 ) )
  resultS = ProcAddBig( resultS, ProcMultiplyBigByInt( squareS, 3 * remainderI + 6 ) )
  IF c1I > 0
    resultS = ProcAddBig( resultS, ProcMultiplyBigByInt( blockS, c1I ) )
  ENDIF
  IF c0I > 0
    resultS = ProcAddBig( resultS, Format( c0I ) )
  ENDIF
  RETURN( resultS )
END

INTEGER PROC ProcCalcSqrtLimit( INTEGER limitI )
  INTEGER rootI = 0
  WHILE ( rootI + 1 ) * ( rootI + 1 ) <= limitI
    rootI = rootI + 1
  ENDWHILE
  RETURN( rootI )
END

INTEGER PROC ProcCountDistinctFloorValues( INTEGER limitI )
  INTEGER countI = 0
  INTEGER startI = 1
  INTEGER quotientI = 0
  INTEGER endI = 0
  WHILE startI <= limitI
    quotientI = limitI / startI
    endI = limitI / quotientI
    countI = countI + 1
    startI = endI + 1
  ENDWHILE
  RETURN( countI )
END

INTEGER PROC ProcLineToValue( INTEGER lineI, INTEGER totalLinesI, INTEGER sqrtLimitI, INTEGER limitI )
  INTEGER divisorI = 0
  IF lineI <= sqrtLimitI
    RETURN( lineI )
  ENDIF
  divisorI = totalLinesI - lineI + 1
  RETURN( limitI / divisorI )
END

INTEGER PROC ProcValueToLine( INTEGER valueI, INTEGER totalLinesI, INTEGER sqrtLimitI, INTEGER limitI )
  IF valueI <= sqrtLimitI
    RETURN( valueI )
  ENDIF
  RETURN( totalLinesI - ( limitI / valueI ) + 1 )
END

STRING PROC ProcReadLineFromResultBuffer( INTEGER lineI )
  STRING lineS[255] = ''
  GotoLine( lineI )
  lineS = GetText( 1, 255 )
  IF lineS == ''
    lineS = '0'
  ENDIF
  RETURN( lineS )
END

PROC ProcWriteLineToResultBuffer( INTEGER lineI, STRING lineS )
  GotoLine( lineI )
  BegLine()
  KillToEol()
  InsertText( lineS )
END

PROC Main()
  INTEGER limitI = PERIMETER_LIMIT
  INTEGER sqrtLimitI = 0
  INTEGER totalLinesI = 0
  INTEGER lineI = 0
  INTEGER currentValueI = 0
  INTEGER divisorStartI = 0
  INTEGER quotientI = 0
  INTEGER divisorEndI = 0
  INTEGER countI = 0
  INTEGER prevLineI = 0
  STRING totalS[255] = ''
  STRING prevS[255] = ''
  STRING subtractS[255] = ''
  STRING answerS[255] = ''
  sqrtLimitI = ProcCalcSqrtLimit( limitI )
  totalLinesI = ProcCountDistinctFloorValues( limitI )
  gResultBufferI = CreateTempBuffer()
  PushLocation()
  GotoBufferId( gResultBufferI )
  ProcWriteLineToResultBuffer( 1, '0' )
  FOR lineI = 2 TO totalLinesI
    AddLine( '0', gResultBufferI )
  ENDFOR
  FOR lineI = 1 TO totalLinesI
    currentValueI = ProcLineToValue( lineI, totalLinesI, sqrtLimitI, limitI )
    totalS = ProcTotalTriangleCountUpTo( currentValueI )
    divisorStartI = 2
    WHILE divisorStartI <= currentValueI
      quotientI = currentValueI / divisorStartI
      divisorEndI = currentValueI / quotientI
      countI = divisorEndI - divisorStartI + 1
      prevLineI = ProcValueToLine( quotientI, totalLinesI, sqrtLimitI, limitI )
      prevS = ProcReadLineFromResultBuffer( prevLineI )
      IF countI == 1
        subtractS = prevS
      ELSE
        subtractS = ProcMultiplyBigByInt( prevS, countI )
      ENDIF
      totalS = ProcSubtractBig( totalS, subtractS )
      divisorStartI = divisorEndI + 1
    ENDWHILE
    ProcWriteLineToResultBuffer( lineI, totalS )
  ENDFOR
  answerS = ProcReadLineFromResultBuffer( totalLinesI )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
  PopLocation()
  IF gResultBufferI > 0
    PushLocation()
    GotoBufferId( gResultBufferI )
    AbandonFile()
    PopLocation()
  ENDIF
END
