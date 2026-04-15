// Euler Project problem 280
// Ant and Seeds
// Pure TSE SAL
// Version: 1
// LLM: ChatGPT

#define GRID_SIZE 5
#define CELL_COUNT 25
#define MASK_COUNT 32
#define BASE 100000000

INTEGER gE0WholeBufferGI = 0
INTEGER gE0Frac1BufferGI = 0
INTEGER gE0Frac2BufferGI = 0
INTEGER gE1WholeBufferGI = 0
INTEGER gE1Frac1BufferGI = 0
INTEGER gE1Frac2BufferGI = 0
INTEGER gWorkBufferGI    = 0

INTEGER PROC ProcPopCount5( INTEGER maskI )
  INTEGER countI = 0
  INTEGER bitI   = 0
  FOR bitI = 0 TO 4
    IF ( ( maskI shr bitI ) & 1 ) == 1
      countI = countI + 1
    ENDIF
  ENDFOR
  RETURN( countI )
END

INTEGER PROC ProcStorageIndex( INTEGER topMaskI, INTEGER bottomMaskI, INTEGER positionI )
  INTEGER indexI = 0
  indexI = ( topMaskI * MASK_COUNT + bottomMaskI ) * CELL_COUNT + positionI
  RETURN( indexI )
END

STRING PROC ProcWorkVarName( STRING prefixS, INTEGER positionI )
  STRING nameS[255] = ""
  nameS = prefixS + Format( positionI )
  RETURN( nameS )
END

STRING PROC ProcStoreVarName( INTEGER topMaskI, INTEGER bottomMaskI, INTEGER positionI )
  STRING nameS[255] = ""
  INTEGER indexI    = 0
  indexI = ProcStorageIndex( topMaskI, bottomMaskI, positionI )
  nameS = "V" + Format( indexI )
  RETURN( nameS )
END

INTEGER PROC ProcGetWorkInt( STRING prefixS, INTEGER positionI )
  STRING nameS[255] = ""
  INTEGER valueI    = 0
  nameS = ProcWorkVarName( prefixS, positionI )
  valueI = GetBufferInt( nameS, gWorkBufferGI )
  RETURN( valueI )
END

PROC ProcSetWorkInt( STRING prefixS, INTEGER positionI, INTEGER valueI )
  STRING nameS[255] = ""
  nameS = ProcWorkVarName( prefixS, positionI )
  SetBufferInt( nameS, valueI, gWorkBufferGI )
END

INTEGER PROC ProcGetStoredInt( INTEGER bufferI, INTEGER topMaskI, INTEGER bottomMaskI, INTEGER positionI )
  STRING nameS[255] = ""
  INTEGER valueI    = 0
  nameS = ProcStoreVarName( topMaskI, bottomMaskI, positionI )
  valueI = GetBufferInt( nameS, bufferI )
  RETURN( valueI )
END

PROC ProcSetStoredInt( INTEGER bufferI, INTEGER topMaskI, INTEGER bottomMaskI, INTEGER positionI, INTEGER valueI )
  STRING nameS[255] = ""
  nameS = ProcStoreVarName( topMaskI, bottomMaskI, positionI )
  SetBufferInt( nameS, valueI, bufferI )
END

INTEGER PROC ProcTripleGreaterThan(
  INTEGER leftWholeI,  INTEGER leftFrac1I,  INTEGER leftFrac2I,
  INTEGER rightWholeI, INTEGER rightFrac1I, INTEGER rightFrac2I
)
  IF leftWholeI > rightWholeI
    RETURN( TRUE )
  ENDIF
  IF leftWholeI < rightWholeI
    RETURN( FALSE )
  ENDIF
  IF leftFrac1I > rightFrac1I
    RETURN( TRUE )
  ENDIF
  IF leftFrac1I < rightFrac1I
    RETURN( FALSE )
  ENDIF
  IF leftFrac2I > rightFrac2I
    RETURN( TRUE )
  ENDIF
  RETURN( FALSE )
END

PROC ProcClearWorkStage()
  INTEGER positionI = 0
  FOR positionI = 0 TO CELL_COUNT - 1
    ProcSetWorkInt( "W", positionI, 0 )
    ProcSetWorkInt( "A", positionI, 0 )
    ProcSetWorkInt( "B", positionI, 0 )
    ProcSetWorkInt( "D", positionI, 0 )
  ENDFOR
END

PROC ProcLoadCarryBoundary( INTEGER topMaskI, INTEGER bottomMaskI )
  INTEGER emptyMaskI = 0
  INTEGER columnI    = 0
  INTEGER positionI  = 0
  INTEGER wholeI     = 0
  INTEGER frac1I     = 0
  INTEGER frac2I     = 0
  emptyMaskI = 31 ^ topMaskI
  FOR columnI = 0 TO 4
    IF ( ( emptyMaskI shr columnI ) & 1 ) == 1
      positionI = columnI
      wholeI = ProcGetStoredInt( gE0WholeBufferGI, topMaskI | ( 1 shl columnI ), bottomMaskI, positionI )
      frac1I = ProcGetStoredInt( gE0Frac1BufferGI, topMaskI | ( 1 shl columnI ), bottomMaskI, positionI )
      frac2I = ProcGetStoredInt( gE0Frac2BufferGI, topMaskI | ( 1 shl columnI ), bottomMaskI, positionI )
      ProcSetWorkInt( "W", positionI, wholeI )
      ProcSetWorkInt( "A", positionI, frac1I )
      ProcSetWorkInt( "B", positionI, frac2I )
      ProcSetWorkInt( "D", positionI, 1 )
    ENDIF
  ENDFOR
END

PROC ProcLoadNotCarryBoundary( INTEGER topMaskI, INTEGER bottomMaskI )
  INTEGER columnI   = 0
  INTEGER positionI = 0
  INTEGER wholeI    = 0
  INTEGER frac1I    = 0
  INTEGER frac2I    = 0
  FOR columnI = 0 TO 4
    IF ( ( bottomMaskI shr columnI ) & 1 ) == 1
      positionI = 20 + columnI
      wholeI = ProcGetStoredInt( gE1WholeBufferGI, topMaskI, bottomMaskI ^ ( 1 shl columnI ), positionI )
      frac1I = ProcGetStoredInt( gE1Frac1BufferGI, topMaskI, bottomMaskI ^ ( 1 shl columnI ), positionI )
      frac2I = ProcGetStoredInt( gE1Frac2BufferGI, topMaskI, bottomMaskI ^ ( 1 shl columnI ), positionI )
      ProcSetWorkInt( "W", positionI, wholeI )
      ProcSetWorkInt( "A", positionI, frac1I )
      ProcSetWorkInt( "B", positionI, frac2I )
      ProcSetWorkInt( "D", positionI, 1 )
    ENDIF
  ENDFOR
END

PROC ProcSolveCurrentStage()
  INTEGER changedB     = TRUE
  INTEGER maxWholeI    = 0
  INTEGER maxFrac1I    = 0
  INTEGER maxFrac2I    = 0
  INTEGER positionI    = 0
  INTEGER boundaryI    = 0
  INTEGER xI           = 0
  INTEGER yI           = 0
  INTEGER degreeI      = 0
  INTEGER neighborI    = 0
  INTEGER sumWholeI    = 0
  INTEGER sumFrac1I    = 0
  INTEGER sumFrac2I    = 0
  INTEGER oldWholeI    = 0
  INTEGER oldFrac1I    = 0
  INTEGER oldFrac2I    = 0
  INTEGER newWholeI    = 0
  INTEGER newFrac1I    = 0
  INTEGER newFrac2I    = 0
  INTEGER remI         = 0
  INTEGER tempI        = 0
  INTEGER diffWholeI   = 0
  INTEGER diffFrac1I   = 0
  INTEGER diffFrac2I   = 0
  REPEAT
    maxWholeI = 0
    maxFrac1I = 0
    maxFrac2I = 0
    FOR positionI = 0 TO CELL_COUNT - 1
      boundaryI = ProcGetWorkInt( "D", positionI )
      IF boundaryI == 0
        xI = positionI mod GRID_SIZE
        yI = positionI / GRID_SIZE
        degreeI   = 0
        sumWholeI = 0
        sumFrac1I = 0
        sumFrac2I = 0
        IF xI > 0
          neighborI = positionI - 1
          sumWholeI = sumWholeI + ProcGetWorkInt( "W", neighborI )
          sumFrac1I = sumFrac1I + ProcGetWorkInt( "A", neighborI )
          sumFrac2I = sumFrac2I + ProcGetWorkInt( "B", neighborI )
          degreeI = degreeI + 1
        ENDIF
        IF xI < 4
          neighborI = positionI + 1
          sumWholeI = sumWholeI + ProcGetWorkInt( "W", neighborI )
          sumFrac1I = sumFrac1I + ProcGetWorkInt( "A", neighborI )
          sumFrac2I = sumFrac2I + ProcGetWorkInt( "B", neighborI )
          degreeI = degreeI + 1
        ENDIF
        IF yI > 0
          neighborI = positionI - 5
          sumWholeI = sumWholeI + ProcGetWorkInt( "W", neighborI )
          sumFrac1I = sumFrac1I + ProcGetWorkInt( "A", neighborI )
          sumFrac2I = sumFrac2I + ProcGetWorkInt( "B", neighborI )
          degreeI = degreeI + 1
        ENDIF
        IF yI < 4
          neighborI = positionI + 5
          sumWholeI = sumWholeI + ProcGetWorkInt( "W", neighborI )
          sumFrac1I = sumFrac1I + ProcGetWorkInt( "A", neighborI )
          sumFrac2I = sumFrac2I + ProcGetWorkInt( "B", neighborI )
          degreeI = degreeI + 1
        ENDIF
        sumFrac1I = sumFrac1I + ( sumFrac2I / BASE )
        sumFrac2I = sumFrac2I mod BASE
        sumWholeI = sumWholeI + ( sumFrac1I / BASE )
        sumFrac1I = sumFrac1I mod BASE
        newWholeI = sumWholeI / degreeI
        remI      = sumWholeI mod degreeI
        tempI     = remI * BASE + sumFrac1I
        newFrac1I = tempI / degreeI
        remI      = tempI mod degreeI
        tempI     = remI * BASE + sumFrac2I
        newFrac2I = tempI / degreeI
        newWholeI = newWholeI + 1
        oldWholeI = ProcGetWorkInt( "W", positionI )
        oldFrac1I = ProcGetWorkInt( "A", positionI )
        oldFrac2I = ProcGetWorkInt( "B", positionI )
        IF ProcTripleGreaterThan( newWholeI, newFrac1I, newFrac2I, oldWholeI, oldFrac1I, oldFrac2I )
          diffWholeI = newWholeI - oldWholeI
          diffFrac1I = newFrac1I - oldFrac1I
          diffFrac2I = newFrac2I - oldFrac2I
        ELSE
          diffWholeI = oldWholeI - newWholeI
          diffFrac1I = oldFrac1I - newFrac1I
          diffFrac2I = oldFrac2I - newFrac2I
        ENDIF
        IF diffFrac2I < 0
          diffFrac2I = diffFrac2I + BASE
          diffFrac1I = diffFrac1I - 1
        ENDIF
        IF diffFrac1I < 0
          diffFrac1I = diffFrac1I + BASE
          diffWholeI = diffWholeI - 1
        ENDIF
        IF ProcTripleGreaterThan( diffWholeI, diffFrac1I, diffFrac2I, maxWholeI, maxFrac1I, maxFrac2I )
          maxWholeI = diffWholeI
          maxFrac1I = diffFrac1I
          maxFrac2I = diffFrac2I
        ENDIF
        ProcSetWorkInt( "W", positionI, newWholeI )
        ProcSetWorkInt( "A", positionI, newFrac1I )
        ProcSetWorkInt( "B", positionI, newFrac2I )
      ENDIF
    ENDFOR
    changedB = ProcTripleGreaterThan( maxWholeI, maxFrac1I, maxFrac2I, 0, 0, 0 )
  UNTIL changedB == FALSE
END

PROC ProcStoreWorkIntoE0( INTEGER topMaskI, INTEGER bottomMaskI )
  INTEGER positionI = 0
  FOR positionI = 0 TO CELL_COUNT - 1
    ProcSetStoredInt( gE0WholeBufferGI, topMaskI, bottomMaskI, positionI, ProcGetWorkInt( "W", positionI ) )
    ProcSetStoredInt( gE0Frac1BufferGI, topMaskI, bottomMaskI, positionI, ProcGetWorkInt( "A", positionI ) )
    ProcSetStoredInt( gE0Frac2BufferGI, topMaskI, bottomMaskI, positionI, ProcGetWorkInt( "B", positionI ) )
  ENDFOR
END

PROC ProcStoreWorkIntoE1( INTEGER topMaskI, INTEGER bottomMaskI )
  INTEGER positionI = 0
  FOR positionI = 0 TO CELL_COUNT - 1
    ProcSetStoredInt( gE1WholeBufferGI, topMaskI, bottomMaskI, positionI, ProcGetWorkInt( "W", positionI ) )
    ProcSetStoredInt( gE1Frac1BufferGI, topMaskI, bottomMaskI, positionI, ProcGetWorkInt( "A", positionI ) )
    ProcSetStoredInt( gE1Frac2BufferGI, topMaskI, bottomMaskI, positionI, ProcGetWorkInt( "B", positionI ) )
  ENDFOR
END

STRING PROC ProcMakeAnswerString( INTEGER wholeI, INTEGER frac1I )
  STRING answerS[255] = ""
  INTEGER wholeLocalI = 0
  INTEGER sixI        = 0
  INTEGER roundI      = 0
  wholeLocalI = wholeI
  sixI   = frac1I / 100
  roundI = ( frac1I / 10 ) mod 10
  IF roundI >= 5
    sixI = sixI + 1
    IF sixI == 1000000
      wholeLocalI = wholeLocalI + 1
      sixI = 0
    ENDIF
  ENDIF
  answerS = Format( wholeLocalI ) + "." + Format( sixI : 6 : "0" )
  RETURN( answerS )
END

PROC Main()
  INTEGER kI           = 0
  INTEGER topMaskI     = 0
  INTEGER bottomMaskI  = 0
  INTEGER centerPosI   = 12
  INTEGER answerWholeI = 0
  INTEGER answerFrac1I = 0
  STRING answerS[255]  = ""
  PushLocation()
  gE0WholeBufferGI = CreateTempBuffer()
  gE0Frac1BufferGI = CreateTempBuffer()
  gE0Frac2BufferGI = CreateTempBuffer()
  gE1WholeBufferGI = CreateTempBuffer()
  gE1Frac1BufferGI = CreateTempBuffer()
  gE1Frac2BufferGI = CreateTempBuffer()
  gWorkBufferGI    = CreateTempBuffer()
  AddHistoryStr( "ChatGPT", _EDIT_HISTORY_ )
  FOR kI = 4 DOWNTO 0
    FOR topMaskI = 0 TO 31
      IF ProcPopCount5( topMaskI ) == kI
        FOR bottomMaskI = 0 TO 31
          IF ProcPopCount5( bottomMaskI ) == ( 4 - kI )
            ProcClearWorkStage()
            ProcLoadCarryBoundary( topMaskI, bottomMaskI )
            ProcSolveCurrentStage()
            ProcStoreWorkIntoE1( topMaskI, bottomMaskI )
          ENDIF
        ENDFOR
      ENDIF
    ENDFOR
    FOR topMaskI = 0 TO 31
      IF ProcPopCount5( topMaskI ) == kI
        FOR bottomMaskI = 0 TO 31
          IF ProcPopCount5( bottomMaskI ) == ( 5 - kI )
            ProcClearWorkStage()
            ProcLoadNotCarryBoundary( topMaskI, bottomMaskI )
            ProcSolveCurrentStage()
            ProcStoreWorkIntoE0( topMaskI, bottomMaskI )
          ENDIF
        ENDFOR
      ENDIF
    ENDFOR
  ENDFOR
  answerWholeI = ProcGetStoredInt( gE0WholeBufferGI, 0, 31, centerPosI )
  answerFrac1I = ProcGetStoredInt( gE0Frac1BufferGI, 0, 31, centerPosI )
  answerS = ProcMakeAnswerString( answerWholeI, answerFrac1I )
  PopLocation()
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
  AbandonFile( gWorkBufferGI )
  AbandonFile( gE1Frac2BufferGI )
  AbandonFile( gE1Frac1BufferGI )
  AbandonFile( gE1WholeBufferGI )
  AbandonFile( gE0Frac2BufferGI )
  AbandonFile( gE0Frac1BufferGI )
  AbandonFile( gE0WholeBufferGI )
END
