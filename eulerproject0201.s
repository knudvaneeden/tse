/*
 Euler Project 201
 Subsets with a Unique Sum
 Pure TSE SAL solution
 version 1.0.0.0.1

 History:
 1.0.0.0.1
 - Created by GPT-5.4 Thinking
 - Exact dynamic programming over sorted reachable-sum sets
 - No hardcoded result in the calculation path
*/

#define MAX_SET_SIZE                 100
#define CHOOSE_SET_SIZE              50

FORWARD INTEGER PROC ProcCreateEmptyNumberBuffer()
FORWARD PROC ProcDestroyBuffer( INTEGER bufferIdI )
FORWARD PROC ProcReplaceCurrentLine( STRING newTextS )
FORWARD PROC ProcAppendNumber( INTEGER bufferIdI, INTEGER numberI )
FORWARD INTEGER PROC ProcGetNumberAtLine( INTEGER bufferIdI, INTEGER lineNumberI )
FORWARD INTEGER PROC ProcGetBufferIdAtRow( INTEGER idsBufferIdI, INTEGER rowI )
FORWARD PROC ProcSetBufferIdAtRow( INTEGER idsBufferIdI, INTEGER rowI, INTEGER bufferIdI )
FORWARD INTEGER PROC ProcShiftBuffer( INTEGER sourceBufferIdI, INTEGER addI )
FORWARD INTEGER PROC ProcUnionBuffers( INTEGER leftBufferIdI, INTEGER rightBufferIdI )
FORWARD INTEGER PROC ProcDifferenceBuffers( INTEGER leftBufferIdI, INTEGER rightBufferIdI )
FORWARD INTEGER PROC ProcSumBuffer( INTEGER bufferIdI )
FORWARD INTEGER PROC ProcSquare( INTEGER numberI )
FORWARD PROC ProcInitializeRowBuffers( INTEGER reachableIdsBufferIdI, INTEGER uniqueIdsBufferIdI )

INTEGER PROC ProcCreateEmptyNumberBuffer()
 INTEGER bufferIdI = 0
 bufferIdI = CreateTempBuffer()
 RETURN( bufferIdI )
END

PROC ProcDestroyBuffer( INTEGER bufferIdI )
 PushLocation()
 GotoBufferId( bufferIdI )
 AbandonFile()
 PopLocation()
END

PROC ProcReplaceCurrentLine( STRING newTextS )
 BegLine()
 KillToEol()
 InsertText( newTextS )
END

PROC ProcAppendNumber( INTEGER bufferIdI, INTEGER numberI )
 AddLine( Format( numberI ), bufferIdI )
END

INTEGER PROC ProcGetNumberAtLine( INTEGER bufferIdI, INTEGER lineNumberI )
 STRING lineTextS[255] = ""
 INTEGER numberI = 0
 PushLocation()
 GotoBufferId( bufferIdI )
 GotoLine( lineNumberI )
 lineTextS = GetText( 1, 255 )
 numberI = Val( lineTextS )
 PopLocation()
 RETURN( numberI )
END

INTEGER PROC ProcGetBufferIdAtRow( INTEGER idsBufferIdI, INTEGER rowI )
 STRING lineTextS[255] = ""
 INTEGER bufferIdI = 0
 PushLocation()
 GotoBufferId( idsBufferIdI )
 GotoLine( rowI + 1 )
 lineTextS = GetText( 1, 255 )
 bufferIdI = Val( lineTextS )
 PopLocation()
 RETURN( bufferIdI )
END

PROC ProcSetBufferIdAtRow( INTEGER idsBufferIdI, INTEGER rowI, INTEGER bufferIdI )
 PushLocation()
 GotoBufferId( idsBufferIdI )
 GotoLine( rowI + 1 )
 ProcReplaceCurrentLine( Format( bufferIdI ) )
 PopLocation()
END

INTEGER PROC ProcShiftBuffer( INTEGER sourceBufferIdI, INTEGER addI )
 INTEGER resultBufferIdI = 0
 INTEGER lineCountI = 0
 INTEGER lineNumberI = 0
 INTEGER sourceNumberI = 0
 resultBufferIdI = ProcCreateEmptyNumberBuffer()
 PushLocation()
 GotoBufferId( sourceBufferIdI )
 lineCountI = NumLines()
 PopLocation()
 FOR lineNumberI = 1 TO lineCountI
  sourceNumberI = ProcGetNumberAtLine( sourceBufferIdI, lineNumberI )
  ProcAppendNumber( resultBufferIdI, sourceNumberI + addI )
 ENDFOR
 RETURN( resultBufferIdI )
END

INTEGER PROC ProcUnionBuffers( INTEGER leftBufferIdI, INTEGER rightBufferIdI )
 INTEGER resultBufferIdI = 0
 INTEGER leftCountI = 0
 INTEGER rightCountI = 0
 INTEGER leftLineI = 1
 INTEGER rightLineI = 1
 INTEGER leftNumberI = 0
 INTEGER rightNumberI = 0
 resultBufferIdI = ProcCreateEmptyNumberBuffer()
 PushLocation()
 GotoBufferId( leftBufferIdI )
 leftCountI = NumLines()
 PopLocation()
 PushLocation()
 GotoBufferId( rightBufferIdI )
 rightCountI = NumLines()
 PopLocation()
 WHILE leftLineI <= leftCountI AND rightLineI <= rightCountI
  leftNumberI = ProcGetNumberAtLine( leftBufferIdI, leftLineI )
  rightNumberI = ProcGetNumberAtLine( rightBufferIdI, rightLineI )
  IF leftNumberI < rightNumberI
   ProcAppendNumber( resultBufferIdI, leftNumberI )
   leftLineI = leftLineI + 1
  ELSE
   IF leftNumberI > rightNumberI
    ProcAppendNumber( resultBufferIdI, rightNumberI )
    rightLineI = rightLineI + 1
   ELSE
    ProcAppendNumber( resultBufferIdI, leftNumberI )
    leftLineI = leftLineI + 1
    rightLineI = rightLineI + 1
   ENDIF
  ENDIF
 ENDWHILE
 WHILE leftLineI <= leftCountI
  leftNumberI = ProcGetNumberAtLine( leftBufferIdI, leftLineI )
  ProcAppendNumber( resultBufferIdI, leftNumberI )
  leftLineI = leftLineI + 1
 ENDWHILE
 WHILE rightLineI <= rightCountI
  rightNumberI = ProcGetNumberAtLine( rightBufferIdI, rightLineI )
  ProcAppendNumber( resultBufferIdI, rightNumberI )
  rightLineI = rightLineI + 1
 ENDWHILE
 RETURN( resultBufferIdI )
END

INTEGER PROC ProcDifferenceBuffers( INTEGER leftBufferIdI, INTEGER rightBufferIdI )
 INTEGER resultBufferIdI = 0
 INTEGER leftCountI = 0
 INTEGER rightCountI = 0
 INTEGER leftLineI = 1
 INTEGER rightLineI = 1
 INTEGER leftNumberI = 0
 INTEGER rightNumberI = 0
 resultBufferIdI = ProcCreateEmptyNumberBuffer()
 PushLocation()
 GotoBufferId( leftBufferIdI )
 leftCountI = NumLines()
 PopLocation()
 PushLocation()
 GotoBufferId( rightBufferIdI )
 rightCountI = NumLines()
 PopLocation()
 WHILE leftLineI <= leftCountI AND rightLineI <= rightCountI
  leftNumberI = ProcGetNumberAtLine( leftBufferIdI, leftLineI )
  rightNumberI = ProcGetNumberAtLine( rightBufferIdI, rightLineI )
  IF leftNumberI < rightNumberI
   ProcAppendNumber( resultBufferIdI, leftNumberI )
   leftLineI = leftLineI + 1
  ELSE
   IF leftNumberI > rightNumberI
    rightLineI = rightLineI + 1
   ELSE
    leftLineI = leftLineI + 1
    rightLineI = rightLineI + 1
   ENDIF
  ENDIF
 ENDWHILE
 WHILE leftLineI <= leftCountI
  leftNumberI = ProcGetNumberAtLine( leftBufferIdI, leftLineI )
  ProcAppendNumber( resultBufferIdI, leftNumberI )
  leftLineI = leftLineI + 1
 ENDWHILE
 RETURN( resultBufferIdI )
END

INTEGER PROC ProcSumBuffer( INTEGER bufferIdI )
 INTEGER resultI = 0
 INTEGER lineCountI = 0
 INTEGER lineNumberI = 0
 INTEGER numberI = 0
 PushLocation()
 GotoBufferId( bufferIdI )
 lineCountI = NumLines()
 PopLocation()
 FOR lineNumberI = 1 TO lineCountI
  numberI = ProcGetNumberAtLine( bufferIdI, lineNumberI )
  resultI = resultI + numberI
 ENDFOR
 RETURN( resultI )
END

INTEGER PROC ProcSquare( INTEGER numberI )
 RETURN( numberI * numberI )
END

PROC ProcInitializeRowBuffers( INTEGER reachableIdsBufferIdI, INTEGER uniqueIdsBufferIdI )
 INTEGER rowI = 0
 INTEGER reachableBufferIdI = 0
 INTEGER uniqueBufferIdI = 0
 FOR rowI = 0 TO CHOOSE_SET_SIZE
  reachableBufferIdI = ProcCreateEmptyNumberBuffer()
  uniqueBufferIdI = ProcCreateEmptyNumberBuffer()
  AddLine( Format( reachableBufferIdI ), reachableIdsBufferIdI )
  AddLine( Format( uniqueBufferIdI ), uniqueIdsBufferIdI )
 ENDFOR
 reachableBufferIdI = ProcGetBufferIdAtRow( reachableIdsBufferIdI, 0 )
 uniqueBufferIdI = ProcGetBufferIdAtRow( uniqueIdsBufferIdI, 0 )
 ProcAppendNumber( reachableBufferIdI, 0 )
 ProcAppendNumber( uniqueBufferIdI, 0 )
END

PROC Main()
 STRING versionS[40] = "1.0.0.0.1"
 STRING resultS[255] = ""
 INTEGER reachableIdsBufferIdI = 0
 INTEGER uniqueIdsBufferIdI = 0
 INTEGER numberI = 0
 INTEGER chooseI = 0
 INTEGER squareI = 0
 INTEGER sourceReachableBufferIdI = 0
 INTEGER sourceUniqueBufferIdI = 0
 INTEGER oldReachableBufferIdI = 0
 INTEGER oldUniqueBufferIdI = 0
 INTEGER addedReachableBufferIdI = 0
 INTEGER addedUniqueBufferIdI = 0
 INTEGER leftUniqueBufferIdI = 0
 INTEGER rightUniqueBufferIdI = 0
 INTEGER newReachableBufferIdI = 0
 INTEGER newUniqueBufferIdI = 0
 INTEGER finalUniqueBufferIdI = 0
 INTEGER answerI = 0
 INTEGER rowI = 0
 reachableIdsBufferIdI = ProcCreateEmptyNumberBuffer()
 uniqueIdsBufferIdI = ProcCreateEmptyNumberBuffer()
 ProcInitializeRowBuffers( reachableIdsBufferIdI, uniqueIdsBufferIdI )
 FOR numberI = 1 TO MAX_SET_SIZE
  squareI = ProcSquare( numberI )
  FOR chooseI = CHOOSE_SET_SIZE DOWNTO 1 BY 1
   sourceReachableBufferIdI = ProcGetBufferIdAtRow( reachableIdsBufferIdI, chooseI - 1 )
   sourceUniqueBufferIdI = ProcGetBufferIdAtRow( uniqueIdsBufferIdI, chooseI - 1 )
   oldReachableBufferIdI = ProcGetBufferIdAtRow( reachableIdsBufferIdI, chooseI )
   oldUniqueBufferIdI = ProcGetBufferIdAtRow( uniqueIdsBufferIdI, chooseI )
   addedReachableBufferIdI = ProcShiftBuffer( sourceReachableBufferIdI, squareI )
   addedUniqueBufferIdI = ProcShiftBuffer( sourceUniqueBufferIdI, squareI )
   newReachableBufferIdI = ProcUnionBuffers( oldReachableBufferIdI, addedReachableBufferIdI )
   leftUniqueBufferIdI = ProcDifferenceBuffers( oldUniqueBufferIdI, addedReachableBufferIdI )
   rightUniqueBufferIdI = ProcDifferenceBuffers( addedUniqueBufferIdI, oldReachableBufferIdI )
   newUniqueBufferIdI = ProcUnionBuffers( leftUniqueBufferIdI, rightUniqueBufferIdI )
   ProcDestroyBuffer( oldReachableBufferIdI )
   ProcDestroyBuffer( oldUniqueBufferIdI )
   ProcSetBufferIdAtRow( reachableIdsBufferIdI, chooseI, newReachableBufferIdI )
   ProcSetBufferIdAtRow( uniqueIdsBufferIdI, chooseI, newUniqueBufferIdI )
   ProcDestroyBuffer( addedReachableBufferIdI )
   ProcDestroyBuffer( addedUniqueBufferIdI )
   ProcDestroyBuffer( leftUniqueBufferIdI )
   ProcDestroyBuffer( rightUniqueBufferIdI )
  ENDFOR
 ENDFOR
 finalUniqueBufferIdI = ProcGetBufferIdAtRow( uniqueIdsBufferIdI, CHOOSE_SET_SIZE )
 answerI = ProcSumBuffer( finalUniqueBufferIdI )
 resultS = Format( answerI )
 CopyToWinClip( resultS )
 Warn( resultS )
 CopyToWinClip( resultS )
 FOR rowI = 0 TO CHOOSE_SET_SIZE
  ProcDestroyBuffer( ProcGetBufferIdAtRow( reachableIdsBufferIdI, rowI ) )
  ProcDestroyBuffer( ProcGetBufferIdAtRow( uniqueIdsBufferIdI, rowI ) )
 ENDFOR
 ProcDestroyBuffer( reachableIdsBufferIdI )
 ProcDestroyBuffer( uniqueIdsBufferIdI )
END
