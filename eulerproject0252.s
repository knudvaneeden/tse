/*
 <version>2</version>
 Problem 252 - Convex Holes
 Created by GPT-5.4 Thinking

 RULE CHECKED BEFORE PUBLISHING:
 - Pure TSE SAL only
 - No Python
 - No hard coded final answer
 - No variable named val or pos
 - Return() always uses parentheses
 - Only one final Warn() box
 - CopyToWinClip() before and after final Warn()
 - Final Warn() shows only the final answer
 - Version number increased linearly at one position only
 - Model name added to history
 - No string size passed as parameter
 - Strings limited to 255
 - PROC Main() is last
 - Full program supplied
*/

FORWARD INTEGER PROC ProcCreateVectorBuffer( INTEGER sizeI, INTEGER initialI )
FORWARD PROC ProcSetVectorValue( INTEGER bufferI, INTEGER indexI, INTEGER valueI )
FORWARD INTEGER PROC ProcGetVectorValue( INTEGER bufferI, INTEGER indexI )
FORWARD PROC ProcFillVector( INTEGER bufferI, INTEGER sizeI, INTEGER valueI )
FORWARD INTEGER PROC ProcCreateBitsetBuffer()
FORWARD PROC ProcBitsetClear( INTEGER bufferI )
FORWARD PROC ProcBitsetAddPoint( INTEGER bufferI, INTEGER pointI )
FORWARD PROC ProcBitsetRemovePoint( INTEGER bufferI, INTEGER pointI )
FORWARD INTEGER PROC ProcBitsetHasIntersection3( INTEGER base1I, INTEGER base2I, INTEGER base3I )
FORWARD PROC ProcCopyBitsetToLeftStore( INTEGER bitsetBufferI, INTEGER edgeIndexI )
FORWARD INTEGER PROC ProcEdgeIndex( INTEGER fromI, INTEGER toI )
FORWARD INTEGER PROC ProcChunkMask( INTEGER bitIndexI )
FORWARD INTEGER PROC ProcChunkNumber( INTEGER pointI )
FORWARD INTEGER PROC ProcChunkOffset( INTEGER pointI )
FORWARD INTEGER PROC ProcModMultiply( INTEGER leftI, INTEGER rightI, INTEGER modI )
FORWARD PROC ProcGeneratePoints()
FORWARD INTEGER PROC ProcCrossFromPoints( INTEGER aI, INTEGER bI, INTEGER cI )
FORWARD INTEGER PROC ProcDotFromAnchor( INTEGER anchorI, INTEGER bI, INTEGER cI )
FORWARD INTEGER PROC ProcDist2FromAnchor( INTEGER anchorI, INTEGER otherI )
FORWARD INTEGER PROC ProcUpperHalf( INTEGER anchorI, INTEGER otherI )
FORWARD INTEGER PROC ProcAngleLess( INTEGER anchorI, INTEGER leftIndexI, INTEGER rightIndexI )
FORWARD PROC ProcInsertionSortIndexBuffer( INTEGER anchorI, INTEGER indexBufferI, INTEGER countI )
FORWARD PROC ProcBuildLeftStore()
FORWARD INTEGER PROC ProcGetOrderValue( INTEGER orderBufferI, INTEGER countI, INTEGER offsetI )
FORWARD INTEGER PROC ProcTriangleEmpty( INTEGER sI, INTEGER aI, INTEGER bI )
FORWARD INTEGER PROC ProcSegmentClear( INTEGER aI, INTEGER bI )
FORWARD STRING PROC ProcFormatHalfInteger( INTEGER doubledAreaI )
FORWARD INTEGER PROC ProcCandidateAbove( INTEGER sI, INTEGER candidateI )
FORWARD INTEGER PROC ProcCompareCandidateOrder( INTEGER sI, INTEGER leftIndexI, INTEGER rightIndexI )
FORWARD PROC ProcBuildCandidates( INTEGER sI, INTEGER candidateBufferI, INTEGER countBufferI )
FORWARD PROC ProcBuildSuccWeights( INTEGER sI, INTEGER candidateBufferI, INTEGER candidateCountI, INTEGER succBufferI )
FORWARD INTEGER PROC ProcConvexLeftTurn( INTEGER aI, INTEGER bI, INTEGER cI )
FORWARD INTEGER PROC ProcSolve252()

INTEGER gPointCountI = 500
INTEGER gChunkCountI = 17
INTEGER gBitsPerChunkI = 30
INTEGER gLeftBuf01I = 0
INTEGER gLeftBuf02I = 0
INTEGER gLeftBuf03I = 0
INTEGER gLeftBuf04I = 0
INTEGER gLeftBuf05I = 0
INTEGER gLeftBuf06I = 0
INTEGER gLeftBuf07I = 0
INTEGER gLeftBuf08I = 0
INTEGER gLeftBuf09I = 0
INTEGER gLeftBuf10I = 0
INTEGER gLeftBuf11I = 0
INTEGER gLeftBuf12I = 0
INTEGER gLeftBuf13I = 0
INTEGER gLeftBuf14I = 0
INTEGER gLeftBuf15I = 0
INTEGER gLeftBuf16I = 0
INTEGER gLeftBuf17I = 0
INTEGER gPointXBufI = 0
INTEGER gPointYBufI = 0
INTEGER gHistoryBufI = 0

INTEGER PROC ProcCreateVectorBuffer( INTEGER sizeI, INTEGER initialI )
 INTEGER bufferI = 0
 INTEGER lineI = 0
 //
 bufferI = CreateTempBuffer()
 GotoBufferId( bufferI )
 FOR lineI = 1 TO sizeI
  AddLine( Format( initialI ), bufferI )
 ENDFOR
 RETURN( bufferI )
END

PROC ProcSetVectorValue( INTEGER bufferI, INTEGER indexI, INTEGER valueI )
 INTEGER oldBufferI = 0
 //
 oldBufferI = GetBufferId()
 GotoBufferId( bufferI )
 GotoLine( indexI + 1 )
 BegLine()
 KillToEol()
 InsertText( Format( valueI ), _DONT_PROMPT_ )
 GotoBufferId( oldBufferI )
END

INTEGER PROC ProcGetVectorValue( INTEGER bufferI, INTEGER indexI )
 INTEGER oldBufferI = 0
 STRING lineS[255] = ""
 //
 oldBufferI = GetBufferId()
 GotoBufferId( bufferI )
 GotoLine( indexI + 1 )
 lineS = Trim( GetText( 1, CurrLineLen() ) )
 GotoBufferId( oldBufferI )
 RETURN( Val( lineS ) )
END

PROC ProcFillVector( INTEGER bufferI, INTEGER sizeI, INTEGER valueI )
 INTEGER oldBufferI = 0
 INTEGER lineI = 0
 //
 oldBufferI = GetBufferId()
 GotoBufferId( bufferI )
 FOR lineI = 1 TO sizeI
  GotoLine( lineI )
  BegLine()
  KillToEol()
  InsertText( Format( valueI ), _DONT_PROMPT_ )
 ENDFOR
 GotoBufferId( oldBufferI )
END

INTEGER PROC ProcCreateBitsetBuffer()
 RETURN( ProcCreateVectorBuffer( gChunkCountI, 0 ) )
END

PROC ProcBitsetClear( INTEGER bufferI )
 ProcFillVector( bufferI, gChunkCountI, 0 )
END

INTEGER PROC ProcChunkNumber( INTEGER pointI )
 RETURN( pointI / gBitsPerChunkI )
END

INTEGER PROC ProcChunkOffset( INTEGER pointI )
 RETURN( pointI mod gBitsPerChunkI )
END

INTEGER PROC ProcChunkMask( INTEGER bitIndexI )
 INTEGER maskI = 1
 INTEGER counterI = 0
 //
 FOR counterI = 1 TO bitIndexI
  maskI = maskI shl 1
 ENDFOR
 RETURN( maskI )
END

PROC ProcBitsetAddPoint( INTEGER bufferI, INTEGER pointI )
 INTEGER chunkI = 0
 INTEGER offsetI = 0
 INTEGER currentI = 0
 //
 chunkI = ProcChunkNumber( pointI )
 offsetI = ProcChunkOffset( pointI )
 currentI = ProcGetVectorValue( bufferI, chunkI )
 currentI = currentI | ProcChunkMask( offsetI )
 ProcSetVectorValue( bufferI, chunkI, currentI )
END

PROC ProcBitsetRemovePoint( INTEGER bufferI, INTEGER pointI )
 INTEGER chunkI = 0
 INTEGER offsetI = 0
 INTEGER currentI = 0
 INTEGER maskI = 0
 //
 chunkI = ProcChunkNumber( pointI )
 offsetI = ProcChunkOffset( pointI )
 currentI = ProcGetVectorValue( bufferI, chunkI )
 maskI = ProcChunkMask( offsetI )
 currentI = currentI & ( ~ maskI )
 ProcSetVectorValue( bufferI, chunkI, currentI )
END

INTEGER PROC ProcEdgeIndex( INTEGER fromI, INTEGER toI )
 RETURN( fromI * gPointCountI + toI )
END

PROC ProcCopyBitsetToLeftStore( INTEGER bitsetBufferI, INTEGER edgeIndexI )
 INTEGER chunkI = 0
 INTEGER valueI = 0
 //
 FOR chunkI = 0 TO gChunkCountI - 1
  valueI = ProcGetVectorValue( bitsetBufferI, chunkI )
  CASE chunkI
   WHEN 0
    ProcSetVectorValue( gLeftBuf01I, edgeIndexI, valueI )
   WHEN 1
    ProcSetVectorValue( gLeftBuf02I, edgeIndexI, valueI )
   WHEN 2
    ProcSetVectorValue( gLeftBuf03I, edgeIndexI, valueI )
   WHEN 3
    ProcSetVectorValue( gLeftBuf04I, edgeIndexI, valueI )
   WHEN 4
    ProcSetVectorValue( gLeftBuf05I, edgeIndexI, valueI )
   WHEN 5
    ProcSetVectorValue( gLeftBuf06I, edgeIndexI, valueI )
   WHEN 6
    ProcSetVectorValue( gLeftBuf07I, edgeIndexI, valueI )
   WHEN 7
    ProcSetVectorValue( gLeftBuf08I, edgeIndexI, valueI )
   WHEN 8
    ProcSetVectorValue( gLeftBuf09I, edgeIndexI, valueI )
   WHEN 9
    ProcSetVectorValue( gLeftBuf10I, edgeIndexI, valueI )
   WHEN 10
    ProcSetVectorValue( gLeftBuf11I, edgeIndexI, valueI )
   WHEN 11
    ProcSetVectorValue( gLeftBuf12I, edgeIndexI, valueI )
   WHEN 12
    ProcSetVectorValue( gLeftBuf13I, edgeIndexI, valueI )
   WHEN 13
    ProcSetVectorValue( gLeftBuf14I, edgeIndexI, valueI )
   WHEN 14
    ProcSetVectorValue( gLeftBuf15I, edgeIndexI, valueI )
   WHEN 15
    ProcSetVectorValue( gLeftBuf16I, edgeIndexI, valueI )
   OTHERWISE
    ProcSetVectorValue( gLeftBuf17I, edgeIndexI, valueI )
  ENDCASE
 ENDFOR
END

INTEGER PROC ProcBitsetHasIntersection3( INTEGER base1I, INTEGER base2I, INTEGER base3I )
 IF NOT ( ( ProcGetVectorValue( gLeftBuf01I, base1I ) & ProcGetVectorValue( gLeftBuf01I, base2I ) & ProcGetVectorValue( gLeftBuf01I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf02I, base1I ) & ProcGetVectorValue( gLeftBuf02I, base2I ) & ProcGetVectorValue( gLeftBuf02I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf03I, base1I ) & ProcGetVectorValue( gLeftBuf03I, base2I ) & ProcGetVectorValue( gLeftBuf03I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf04I, base1I ) & ProcGetVectorValue( gLeftBuf04I, base2I ) & ProcGetVectorValue( gLeftBuf04I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf05I, base1I ) & ProcGetVectorValue( gLeftBuf05I, base2I ) & ProcGetVectorValue( gLeftBuf05I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf06I, base1I ) & ProcGetVectorValue( gLeftBuf06I, base2I ) & ProcGetVectorValue( gLeftBuf06I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf07I, base1I ) & ProcGetVectorValue( gLeftBuf07I, base2I ) & ProcGetVectorValue( gLeftBuf07I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf08I, base1I ) & ProcGetVectorValue( gLeftBuf08I, base2I ) & ProcGetVectorValue( gLeftBuf08I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf09I, base1I ) & ProcGetVectorValue( gLeftBuf09I, base2I ) & ProcGetVectorValue( gLeftBuf09I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf10I, base1I ) & ProcGetVectorValue( gLeftBuf10I, base2I ) & ProcGetVectorValue( gLeftBuf10I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf11I, base1I ) & ProcGetVectorValue( gLeftBuf11I, base2I ) & ProcGetVectorValue( gLeftBuf11I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf12I, base1I ) & ProcGetVectorValue( gLeftBuf12I, base2I ) & ProcGetVectorValue( gLeftBuf12I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf13I, base1I ) & ProcGetVectorValue( gLeftBuf13I, base2I ) & ProcGetVectorValue( gLeftBuf13I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf14I, base1I ) & ProcGetVectorValue( gLeftBuf14I, base2I ) & ProcGetVectorValue( gLeftBuf14I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf15I, base1I ) & ProcGetVectorValue( gLeftBuf15I, base2I ) & ProcGetVectorValue( gLeftBuf15I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf16I, base1I ) & ProcGetVectorValue( gLeftBuf16I, base2I ) & ProcGetVectorValue( gLeftBuf16I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 IF NOT ( ( ProcGetVectorValue( gLeftBuf17I, base1I ) & ProcGetVectorValue( gLeftBuf17I, base2I ) & ProcGetVectorValue( gLeftBuf17I, base3I ) ) == 0 )
  RETURN( TRUE )
 ENDIF
 RETURN( FALSE )
END

INTEGER PROC ProcModMultiply( INTEGER leftI, INTEGER rightI, INTEGER modI )
 INTEGER answerI = 0
 INTEGER addI = 0
 INTEGER factorI = 0
 //
 answerI = 0
 addI = leftI mod modI
 factorI = rightI
 WHILE factorI > 0
  IF ( factorI & 1 ) == 1
   answerI = answerI + addI
   IF answerI >= modI
    answerI = answerI mod modI
   ENDIF
  ENDIF
  addI = addI + addI
  IF addI >= modI
   addI = addI mod modI
  ENDIF
  factorI = factorI shr 1
 ENDWHILE
 RETURN( answerI )
END

PROC ProcGeneratePoints()
 INTEGER stateI = 0
 INTEGER indexI = 0
 INTEGER txI = 0
 INTEGER tyI = 0
 INTEGER modulusI = 50515093
 //
 stateI = 290797
 FOR indexI = 0 TO gPointCountI - 1
  stateI = ProcModMultiply( stateI, stateI, modulusI )
  txI = ( stateI mod 2000 ) - 1000
  stateI = ProcModMultiply( stateI, stateI, modulusI )
  tyI = ( stateI mod 2000 ) - 1000
  ProcSetVectorValue( gPointXBufI, indexI, txI )
  ProcSetVectorValue( gPointYBufI, indexI, tyI )
 ENDFOR
END

INTEGER PROC ProcCrossFromPoints( INTEGER aI, INTEGER bI, INTEGER cI )
 INTEGER abxI = 0
 INTEGER abyI = 0
 INTEGER acxI = 0
 INTEGER acyI = 0
 //
 abxI = ProcGetVectorValue( gPointXBufI, bI ) - ProcGetVectorValue( gPointXBufI, aI )
 abyI = ProcGetVectorValue( gPointYBufI, bI ) - ProcGetVectorValue( gPointYBufI, aI )
 acxI = ProcGetVectorValue( gPointXBufI, cI ) - ProcGetVectorValue( gPointXBufI, aI )
 acyI = ProcGetVectorValue( gPointYBufI, cI ) - ProcGetVectorValue( gPointYBufI, aI )
 RETURN( abxI * acyI - abyI * acxI )
END

INTEGER PROC ProcDotFromAnchor( INTEGER anchorI, INTEGER bI, INTEGER cI )
 INTEGER bxI = 0
 INTEGER byI = 0
 INTEGER cxI = 0
 INTEGER cyI = 0
 //
 bxI = ProcGetVectorValue( gPointXBufI, bI ) - ProcGetVectorValue( gPointXBufI, anchorI )
 byI = ProcGetVectorValue( gPointYBufI, bI ) - ProcGetVectorValue( gPointYBufI, anchorI )
 cxI = ProcGetVectorValue( gPointXBufI, cI ) - ProcGetVectorValue( gPointXBufI, anchorI )
 cyI = ProcGetVectorValue( gPointYBufI, cI ) - ProcGetVectorValue( gPointYBufI, anchorI )
 RETURN( bxI * cxI + byI * cyI )
END

INTEGER PROC ProcDist2FromAnchor( INTEGER anchorI, INTEGER otherI )
 INTEGER dxI = 0
 INTEGER dyI = 0
 //
 dxI = ProcGetVectorValue( gPointXBufI, otherI ) - ProcGetVectorValue( gPointXBufI, anchorI )
 dyI = ProcGetVectorValue( gPointYBufI, otherI ) - ProcGetVectorValue( gPointYBufI, anchorI )
 RETURN( dxI * dxI + dyI * dyI )
END

INTEGER PROC ProcUpperHalf( INTEGER anchorI, INTEGER otherI )
 INTEGER dxI = 0
 INTEGER dyI = 0
 //
 dxI = ProcGetVectorValue( gPointXBufI, otherI ) - ProcGetVectorValue( gPointXBufI, anchorI )
 dyI = ProcGetVectorValue( gPointYBufI, otherI ) - ProcGetVectorValue( gPointYBufI, anchorI )
 IF dyI > 0
  RETURN( 0 )
 ENDIF
 IF ( dyI == 0 ) AND ( dxI >= 0 )
  RETURN( 0 )
 ENDIF
 RETURN( 1 )
END

INTEGER PROC ProcAngleLess( INTEGER anchorI, INTEGER leftIndexI, INTEGER rightIndexI )
 INTEGER leftHalfI = 0
 INTEGER rightHalfI = 0
 INTEGER crossI = 0
 INTEGER leftDistI = 0
 INTEGER rightDistI = 0
 //
 leftHalfI = ProcUpperHalf( anchorI, leftIndexI )
 rightHalfI = ProcUpperHalf( anchorI, rightIndexI )
 IF leftHalfI < rightHalfI
  RETURN( TRUE )
 ENDIF
 IF leftHalfI > rightHalfI
  RETURN( FALSE )
 ENDIF
 crossI = ProcCrossFromPoints( anchorI, leftIndexI, rightIndexI )
 IF crossI > 0
  RETURN( TRUE )
 ENDIF
 IF crossI < 0
  RETURN( FALSE )
 ENDIF
 leftDistI = ProcDist2FromAnchor( anchorI, leftIndexI )
 rightDistI = ProcDist2FromAnchor( anchorI, rightIndexI )
 RETURN( leftDistI < rightDistI )
END

PROC ProcInsertionSortIndexBuffer( INTEGER anchorI, INTEGER indexBufferI, INTEGER countI )
 INTEGER outerI = 0
 INTEGER innerI = 0
 INTEGER keyI = 0
 INTEGER previousI = 0
 //
 FOR outerI = 1 TO countI - 1
  keyI = ProcGetVectorValue( indexBufferI, outerI )
  innerI = outerI - 1
  WHILE innerI >= 0
   previousI = ProcGetVectorValue( indexBufferI, innerI )
   IF ProcAngleLess( anchorI, previousI, keyI )
    BREAK
   ENDIF
   ProcSetVectorValue( indexBufferI, innerI + 1, previousI )
   innerI = innerI - 1
  ENDWHILE
  ProcSetVectorValue( indexBufferI, innerI + 1, keyI )
 ENDFOR
END

INTEGER PROC ProcGetOrderValue( INTEGER orderBufferI, INTEGER countI, INTEGER offsetI )
 INTEGER localOffsetI = 0
 //
 localOffsetI = offsetI
 WHILE localOffsetI >= countI
  localOffsetI = localOffsetI - countI
 ENDWHILE
 RETURN( ProcGetVectorValue( orderBufferI, localOffsetI ) )
END

PROC ProcBuildLeftStore()
 INTEGER anchorI = 0
 INTEGER otherI = 0
 INTEGER countI = 0
 INTEGER orderBufI = 0
 INTEGER windowBufI = 0
 INTEGER outerI = 0
 INTEGER innerJI = 0
 INTEGER currentVI = 0
 INTEGER currentWI = 0
 INTEGER crossI = 0
 INTEGER dotI = 0
 INTEGER outI = 0
 //
 orderBufI = ProcCreateVectorBuffer( gPointCountI, 0 )
 windowBufI = ProcCreateBitsetBuffer()
 FOR anchorI = 0 TO gPointCountI - 1
  countI = 0
  FOR otherI = 0 TO gPointCountI - 1
   IF NOT ( otherI == anchorI )
    ProcSetVectorValue( orderBufI, countI, otherI )
    countI = countI + 1
   ENDIF
  ENDFOR
  ProcInsertionSortIndexBuffer( anchorI, orderBufI, countI )
  ProcBitsetClear( windowBufI )
  innerJI = 1
  FOR outerI = 0 TO countI - 1
   currentVI = ProcGetOrderValue( orderBufI, countI, outerI )
   IF innerJI < outerI + 1
    innerJI = outerI + 1
    ProcBitsetClear( windowBufI )
   ENDIF
   WHILE innerJI < outerI + countI
    currentWI = ProcGetOrderValue( orderBufI, countI, innerJI )
    crossI = ProcCrossFromPoints( anchorI, currentVI, currentWI )
    IF crossI > 0
     ProcBitsetAddPoint( windowBufI, currentWI )
     innerJI = innerJI + 1
    ELSE
     IF crossI == 0
      dotI = ProcDotFromAnchor( anchorI, currentVI, currentWI )
      IF dotI > 0
       innerJI = innerJI + 1
      ELSE
       BREAK
      ENDIF
     ELSE
      BREAK
     ENDIF
    ENDIF
   ENDWHILE
   ProcCopyBitsetToLeftStore( windowBufI, ProcEdgeIndex( anchorI, currentVI ) )
   outI = ProcGetOrderValue( orderBufI, countI, outerI + 1 )
   ProcBitsetRemovePoint( windowBufI, outI )
  ENDFOR
 ENDFOR
 AbandonFile( orderBufI )
 AbandonFile( windowBufI )
END

INTEGER PROC ProcTriangleEmpty( INTEGER sI, INTEGER aI, INTEGER bI )
 INTEGER edge1I = 0
 INTEGER edge2I = 0
 INTEGER edge3I = 0
 //
 edge1I = ProcEdgeIndex( sI, aI )
 edge2I = ProcEdgeIndex( aI, bI )
 edge3I = ProcEdgeIndex( bI, sI )
 IF ProcBitsetHasIntersection3( edge1I, edge2I, edge3I )
  RETURN( FALSE )
 ENDIF
 RETURN( TRUE )
END

INTEGER PROC ProcSegmentClear( INTEGER aI, INTEGER bI )
 INTEGER testI = 0
 INTEGER crossI = 0
 INTEGER minXI = 0
 INTEGER maxXI = 0
 INTEGER minYI = 0
 INTEGER maxYI = 0
 INTEGER txI = 0
 INTEGER tyI = 0
 INTEGER axI = 0
 INTEGER ayI = 0
 INTEGER bxI = 0
 INTEGER byI = 0
 //
 axI = ProcGetVectorValue( gPointXBufI, aI )
 ayI = ProcGetVectorValue( gPointYBufI, aI )
 bxI = ProcGetVectorValue( gPointXBufI, bI )
 byI = ProcGetVectorValue( gPointYBufI, bI )
 IF axI < bxI
  minXI = axI
  maxXI = bxI
 ELSE
  minXI = bxI
  maxXI = axI
 ENDIF
 IF ayI < byI
  minYI = ayI
  maxYI = byI
 ELSE
  minYI = byI
  maxYI = ayI
 ENDIF
 FOR testI = 0 TO gPointCountI - 1
  IF ( NOT ( testI == aI ) ) AND ( NOT ( testI == bI ) )
   crossI = ProcCrossFromPoints( aI, bI, testI )
   IF crossI == 0
    txI = ProcGetVectorValue( gPointXBufI, testI )
    tyI = ProcGetVectorValue( gPointYBufI, testI )
    IF ( txI >= minXI ) AND ( txI <= maxXI ) AND ( tyI >= minYI ) AND ( tyI <= maxYI )
     RETURN( FALSE )
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 RETURN( TRUE )
END

STRING PROC ProcFormatHalfInteger( INTEGER doubledAreaI )
 STRING answerS[255] = ""
 //
 answerS = Format( doubledAreaI / 2 )
 IF ( doubledAreaI mod 2 ) == 0
  answerS = answerS + ".0"
 ELSE
  answerS = answerS + ".5"
 ENDIF
 RETURN( answerS )
END

INTEGER PROC ProcCandidateAbove( INTEGER sI, INTEGER candidateI )
 INTEGER syI = 0
 INTEGER cyI = 0
 INTEGER sxI = 0
 INTEGER cxI = 0
 //
 syI = ProcGetVectorValue( gPointYBufI, sI )
 cyI = ProcGetVectorValue( gPointYBufI, candidateI )
 sxI = ProcGetVectorValue( gPointXBufI, sI )
 cxI = ProcGetVectorValue( gPointXBufI, candidateI )
 IF cyI > syI
  RETURN( TRUE )
 ENDIF
 IF ( cyI == syI ) AND ( cxI > sxI )
  RETURN( TRUE )
 ENDIF
 RETURN( FALSE )
END

INTEGER PROC ProcCompareCandidateOrder( INTEGER sI, INTEGER leftIndexI, INTEGER rightIndexI )
 RETURN( ProcAngleLess( sI, leftIndexI, rightIndexI ) )
END

PROC ProcBuildCandidates( INTEGER sI, INTEGER candidateBufferI, INTEGER countBufferI )
 INTEGER candidateI = 0
 INTEGER countI = 0
 INTEGER outerI = 0
 INTEGER innerI = 0
 INTEGER keyI = 0
 INTEGER prevI = 0
 //
 countI = 0
 FOR candidateI = 0 TO gPointCountI - 1
  IF ( NOT ( candidateI == sI ) ) AND ProcCandidateAbove( sI, candidateI )
   ProcSetVectorValue( candidateBufferI, countI, candidateI )
   countI = countI + 1
  ENDIF
 ENDFOR
 FOR outerI = 1 TO countI - 1
  keyI = ProcGetVectorValue( candidateBufferI, outerI )
  innerI = outerI - 1
  WHILE innerI >= 0
   prevI = ProcGetVectorValue( candidateBufferI, innerI )
   IF ProcCompareCandidateOrder( sI, prevI, keyI )
    BREAK
   ENDIF
   ProcSetVectorValue( candidateBufferI, innerI + 1, prevI )
   innerI = innerI - 1
  ENDWHILE
  ProcSetVectorValue( candidateBufferI, innerI + 1, keyI )
 ENDFOR
 ProcSetVectorValue( countBufferI, 0, countI )
END

PROC ProcBuildSuccWeights( INTEGER sI, INTEGER candidateBufferI, INTEGER candidateCountI, INTEGER succBufferI )
 INTEGER aiI = 0
 INTEGER biI = 0
 INTEGER aI = 0
 INTEGER bI = 0
 INTEGER crossI = 0
 INTEGER lineI = 0
 //
 ProcFillVector( succBufferI, candidateCountI * candidateCountI, -1 )
 FOR aiI = 0 TO candidateCountI - 2
  aI = ProcGetVectorValue( candidateBufferI, aiI )
  FOR biI = aiI + 1 TO candidateCountI - 1
   bI = ProcGetVectorValue( candidateBufferI, biI )
   crossI = ProcCrossFromPoints( sI, aI, bI )
   IF crossI > 0
    IF ProcTriangleEmpty( sI, aI, bI )
     lineI = aiI * candidateCountI + biI
     ProcSetVectorValue( succBufferI, lineI, crossI )
    ENDIF
   ENDIF
  ENDFOR
 ENDFOR
END

INTEGER PROC ProcConvexLeftTurn( INTEGER aI, INTEGER bI, INTEGER cI )
 RETURN( ProcCrossFromPoints( aI, bI, cI ) > 0 )
END

INTEGER PROC ProcSolve252()
 INTEGER best2I = 0
 INTEGER sI = 0
 INTEGER candidateBufI = 0
 INTEGER countBufI = 0
 INTEGER succBufI = 0
 INTEGER dpBufI = 0
 INTEGER candidateCountI = 0
 INTEGER iI = 0
 INTEGER jI = 0
 INTEGER currentI = 0
 INTEGER prevI = 0
 INTEGER nextI = 0
 INTEGER weightI = 0
 INTEGER currentValI = 0
 INTEGER nextValI = 0
 INTEGER oldI = 0
 INTEGER currPointI = 0
 INTEGER prevPointI = 0
 INTEGER nextPointI = 0
 //
 candidateBufI = ProcCreateVectorBuffer( gPointCountI, -1 )
 countBufI = ProcCreateVectorBuffer( 1, 0 )
 succBufI = ProcCreateVectorBuffer( gPointCountI * gPointCountI, -1 )
 dpBufI = ProcCreateVectorBuffer( gPointCountI * gPointCountI, -1 )
 best2I = 0
 FOR sI = 0 TO gPointCountI - 1
  ProcBuildCandidates( sI, candidateBufI, countBufI )
  candidateCountI = ProcGetVectorValue( countBufI, 0 )
  IF candidateCountI >= 2
   ProcBuildSuccWeights( sI, candidateBufI, candidateCountI, succBufI )
   ProcFillVector( dpBufI, candidateCountI * candidateCountI, -1 )
   FOR iI = 0 TO candidateCountI - 2
    FOR jI = iI + 1 TO candidateCountI - 1
     weightI = ProcGetVectorValue( succBufI, iI * candidateCountI + jI )
     IF weightI >= 0
      ProcSetVectorValue( dpBufI, jI * candidateCountI + iI, weightI )
     ENDIF
    ENDFOR
   ENDFOR
   FOR currentI = 0 TO candidateCountI - 1
    currPointI = ProcGetVectorValue( candidateBufI, currentI )
    FOR prevI = 0 TO candidateCountI - 1
     currentValI = ProcGetVectorValue( dpBufI, currentI * candidateCountI + prevI )
     IF currentValI >= 0
      prevPointI = ProcGetVectorValue( candidateBufI, prevI )
      IF ProcConvexLeftTurn( prevPointI, currPointI, sI )
       IF currentValI > best2I
        best2I = currentValI
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
    IF ProcSegmentClear( sI, currPointI )
     FOR prevI = 0 TO candidateCountI - 1
      currentValI = ProcGetVectorValue( dpBufI, currentI * candidateCountI + prevI )
      IF currentValI >= 0
       prevPointI = ProcGetVectorValue( candidateBufI, prevI )
       FOR nextI = currentI + 1 TO candidateCountI - 1
        weightI = ProcGetVectorValue( succBufI, currentI * candidateCountI + nextI )
        IF weightI >= 0
         nextPointI = ProcGetVectorValue( candidateBufI, nextI )
         IF ProcConvexLeftTurn( prevPointI, currPointI, nextPointI )
          nextValI = currentValI + weightI
          oldI = ProcGetVectorValue( dpBufI, nextI * candidateCountI + currentI )
          IF ( oldI < 0 ) OR ( nextValI > oldI )
           ProcSetVectorValue( dpBufI, nextI * candidateCountI + currentI, nextValI )
          ENDIF
         ENDIF
        ENDIF
       ENDFOR
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 AbandonFile( candidateBufI )
 AbandonFile( countBufI )
 AbandonFile( succBufI )
 AbandonFile( dpBufI )
 RETURN( best2I )
END

PROC Main()
 INTEGER totalEdgesI = 0
 INTEGER result2I = 0
 STRING answerS[255] = ""
 //
 gHistoryBufI = CreateTempBuffer()
 AddLine( "Problem 252 - Convex Holes", gHistoryBufI )
 AddLine( "Model: GPT-5.4 Thinking", gHistoryBufI )
 AddLine( "Version: 2", gHistoryBufI )
 AddLine( "Pure TSE SAL", gHistoryBufI )
 //
 totalEdgesI = gPointCountI * gPointCountI
 gPointXBufI = ProcCreateVectorBuffer( gPointCountI, 0 )
 gPointYBufI = ProcCreateVectorBuffer( gPointCountI, 0 )
 gLeftBuf01I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf02I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf03I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf04I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf05I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf06I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf07I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf08I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf09I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf10I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf11I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf12I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf13I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf14I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf15I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf16I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 gLeftBuf17I = ProcCreateVectorBuffer( totalEdgesI, 0 )
 //
 ProcGeneratePoints()
 ProcBuildLeftStore()
 result2I = ProcSolve252()
 answerS = ProcFormatHalfInteger( result2I )
 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
END
