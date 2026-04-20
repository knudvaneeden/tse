// <version>1</version>
// History: created by ChatGPT
// Rules applied and confirmed:
// - Pure TSE SAL only
// - No hardcoded final answer
// - No user variables named val or pos
// - All RETURN() calls use parentheses
// - One final Warn() only
// - Two CopyToWinClip() calls around the final Warn()
// - Final result is computed exactly from aggregated state counts
#DEFINE MEMORY_SIZE 5
#DEFINE SYMBOL_COUNT 10
#DEFINE TURN_COUNT 50
#DEFINE DECIMALS 8
#DEFINE DELTA_SHIFT 100
#DEFINE ROUND_CUT ( TURN_COUNT - DECIMALS )
FORWARD PROC ProcAbandonBuffer( INTEGER bufferI )
FORWARD PROC ProcSortBuffer( INTEGER bufferI )
FORWARD INTEGER PROC FNFindCharI( STRING sourceS, STRING targetS )
FORWARD STRING PROC FNRepeatCharS( STRING charS, INTEGER countI )
FORWARD STRING PROC FNBigTrimS( STRING numberS )
FORWARD STRING PROC FNBigAddS( STRING leftS, STRING rightS )
FORWARD STRING PROC FNBigMulSmallS( STRING numberS, INTEGER factorI )
FORWARD INTEGER PROC FNFindDelimiterFromI( STRING sourceS, STRING delimiterS, INTEGER startI )
FORWARD STRING PROC FNStateLarryS( STRING stateS )
FORWARD STRING PROC FNStateRobinS( STRING stateS )
FORWARD STRING PROC FNDeleteFirstCharS( STRING sourceS, STRING targetS )
FORWARD STRING PROC FNLarryNextS( STRING larryS, STRING callS )
FORWARD STRING PROC FNRobinNextS( STRING robinS, STRING callS )
FORWARD STRING PROC FNCanonicalStateS( STRING stateS )
FORWARD STRING PROC FNNextStateS( STRING stateS, STRING callS )
FORWARD INTEGER PROC FNDeltaChangeI( STRING stateS, STRING callS )
FORWARD INTEGER PROC FNDistinctCountI( STRING stateS )
FORWARD STRING PROC FNField1S( STRING lineS )
FORWARD STRING PROC FNField2S( STRING lineS )
FORWARD STRING PROC FNField3S( STRING lineS )
FORWARD STRING PROC FNKeyPrefixS( STRING lineS )
FORWARD STRING PROC FNMakeDpLineS( STRING stateS, INTEGER deltaI, STRING countS )
FORWARD INTEGER PROC FNGenerateNextLayerI( INTEGER sourceBufferI )
FORWARD INTEGER PROC FNCollapseLayerI( INTEGER sourceBufferI )
FORWARD STRING PROC FNInsertDecimalS( STRING scaledS, INTEGER decimalsI )
FORWARD STRING PROC FNFormatAnswerS( STRING numeratorS )
FORWARD STRING PROC FNComputeAnswerS( INTEGER sourceBufferI )
STRING gSymbolsGS[10] = "123456789A"
PROC ProcAbandonBuffer( INTEGER bufferI )
  PushLocation()
  GotoBufferId( bufferI )
  AbandonFile()
  PopLocation()
END
PROC ProcSortBuffer( INTEGER bufferI )
  PushLocation()
  GotoBufferId( bufferI )
  MarkAll()
  ExecMacro( "sort" )
  PopLocation()
END
INTEGER PROC FNFindCharI( STRING sourceS, STRING targetS )
  INTEGER indexI = 0
  FOR indexI = 1 TO Length( sourceS )
    IF SubStr( sourceS, indexI, 1 ) == targetS
      RETURN( indexI )
    ENDIF
  ENDFOR
  RETURN( 0 )
END
STRING PROC FNRepeatCharS( STRING charS, INTEGER countI )
  INTEGER indexI = 0
  STRING resultS[255] = ""
  IF countI <= 0
    RETURN( "" )
  ENDIF
  FOR indexI = 1 TO countI
    resultS = resultS + charS
  ENDFOR
  RETURN( resultS )
END
STRING PROC FNBigTrimS( STRING numberS )
  INTEGER indexI = 1
  STRING workS[255] = numberS
  IF workS == ""
    RETURN( "0" )
  ENDIF
  WHILE indexI < Length( workS ) AND SubStr( workS, indexI, 1 ) == "0"
    indexI = indexI + 1
  ENDWHILE
  RETURN( SubStr( workS, indexI, Length( workS ) - indexI + 1 ) )
END
STRING PROC FNBigAddS( STRING leftS, STRING rightS )
  INTEGER leftIndexI = 0
  INTEGER rightIndexI = 0
  INTEGER carryI = 0
  INTEGER digitLeftI = 0
  INTEGER digitRightI = 0
  INTEGER sumI = 0
  STRING resultS[255] = ""
  STRING workLeftS[255] = FNBigTrimS( leftS )
  STRING workRightS[255] = FNBigTrimS( rightS )
  leftIndexI = Length( workLeftS )
  rightIndexI = Length( workRightS )
  WHILE leftIndexI > 0 OR rightIndexI > 0 OR carryI > 0
    digitLeftI = 0
    digitRightI = 0
    IF leftIndexI > 0
      digitLeftI = Val( SubStr( workLeftS, leftIndexI, 1 ) )
      leftIndexI = leftIndexI - 1
    ENDIF
    IF rightIndexI > 0
      digitRightI = Val( SubStr( workRightS, rightIndexI, 1 ) )
      rightIndexI = rightIndexI - 1
    ENDIF
    sumI = digitLeftI + digitRightI + carryI
    resultS = Format( sumI mod 10 ) + resultS
    carryI = sumI / 10
  ENDWHILE
  RETURN( FNBigTrimS( resultS ) )
END
STRING PROC FNBigMulSmallS( STRING numberS, INTEGER factorI )
  INTEGER indexI = 0
  INTEGER carryI = 0
  INTEGER digitI = 0
  INTEGER valueI = 0
  STRING workS[255] = FNBigTrimS( numberS )
  STRING resultS[255] = ""
  IF factorI <= 0
    RETURN( "0" )
  ENDIF
  IF factorI == 1
    RETURN( workS )
  ENDIF
  FOR indexI = Length( workS ) DOWNTO 1
    digitI = Val( SubStr( workS, indexI, 1 ) )
    valueI = digitI * factorI + carryI
    resultS = Format( valueI mod 10 ) + resultS
    carryI = valueI / 10
  ENDFOR
  WHILE carryI > 0
    resultS = Format( carryI mod 10 ) + resultS
    carryI = carryI / 10
  ENDWHILE
  RETURN( FNBigTrimS( resultS ) )
END
INTEGER PROC FNFindDelimiterFromI( STRING sourceS, STRING delimiterS, INTEGER startI )
  INTEGER indexI = 0
  FOR indexI = startI TO Length( sourceS )
    IF SubStr( sourceS, indexI, 1 ) == delimiterS
      RETURN( indexI )
    ENDIF
  ENDFOR
  RETURN( 0 )
END
STRING PROC FNStateLarryS( STRING stateS )
  INTEGER slashI = 0
  slashI = FNFindCharI( stateS, "/" )
  IF slashI <= 1
    RETURN( "" )
  ENDIF
  RETURN( SubStr( stateS, 1, slashI - 1 ) )
END
STRING PROC FNStateRobinS( STRING stateS )
  INTEGER slashI = 0
  slashI = FNFindCharI( stateS, "/" )
  IF slashI == 0
    RETURN( "" )
  ENDIF
  IF slashI == Length( stateS )
    RETURN( "" )
  ENDIF
  RETURN( SubStr( stateS, slashI + 1, Length( stateS ) - slashI ) )
END
STRING PROC FNDeleteFirstCharS( STRING sourceS, STRING targetS )
  INTEGER foundI = 0
  STRING leftPartS[255] = ""
  STRING rightPartS[255] = ""
  foundI = FNFindCharI( sourceS, targetS )
  IF foundI == 0
    RETURN( sourceS )
  ENDIF
  IF foundI > 1
    leftPartS = SubStr( sourceS, 1, foundI - 1 )
  ENDIF
  IF foundI < Length( sourceS )
    rightPartS = SubStr( sourceS, foundI + 1, Length( sourceS ) - foundI )
  ENDIF
  RETURN( leftPartS + rightPartS )
END
STRING PROC FNLarryNextS( STRING larryS, STRING callS )
  STRING workS[255] = larryS
  INTEGER foundI = 0
  foundI = FNFindCharI( workS, callS )
  IF foundI > 0
    workS = FNDeleteFirstCharS( workS, callS )
    workS = workS + callS
    RETURN( workS )
  ENDIF
  IF Length( workS ) == MEMORY_SIZE
    workS = SubStr( workS, 2, MEMORY_SIZE - 1 )
  ENDIF
  workS = workS + callS
  RETURN( workS )
END
STRING PROC FNRobinNextS( STRING robinS, STRING callS )
  STRING workS[255] = robinS
  INTEGER foundI = 0
  foundI = FNFindCharI( workS, callS )
  IF foundI > 0
    RETURN( workS )
  ENDIF
  IF Length( workS ) == MEMORY_SIZE
    workS = SubStr( workS, 2, MEMORY_SIZE - 1 )
  ENDIF
  workS = workS + callS
  RETURN( workS )
END
STRING PROC FNCanonicalStateS( STRING stateS )
  STRING larryS[255] = ""
  STRING robinS[255] = ""
  STRING seenS[255] = ""
  STRING mapS[255] = ""
  STRING newLarryS[255] = ""
  STRING newRobinS[255] = ""
  STRING charS[1] = ""
  INTEGER indexI = 0
  INTEGER foundI = 0
  larryS = FNStateLarryS( stateS )
  robinS = FNStateRobinS( stateS )
  FOR indexI = 1 TO Length( larryS )
    charS = SubStr( larryS, indexI, 1 )
    foundI = FNFindCharI( seenS, charS )
    IF foundI == 0
      seenS = seenS + charS
      mapS = mapS + SubStr( gSymbolsGS, Length( seenS ), 1 )
      foundI = Length( seenS )
    ENDIF
    newLarryS = newLarryS + SubStr( mapS, foundI, 1 )
  ENDFOR
  FOR indexI = 1 TO Length( robinS )
    charS = SubStr( robinS, indexI, 1 )
    foundI = FNFindCharI( seenS, charS )
    IF foundI == 0
      seenS = seenS + charS
      mapS = mapS + SubStr( gSymbolsGS, Length( seenS ), 1 )
      foundI = Length( seenS )
    ENDIF
    newRobinS = newRobinS + SubStr( mapS, foundI, 1 )
  ENDFOR
  RETURN( newLarryS + "/" + newRobinS )
END
STRING PROC FNNextStateS( STRING stateS, STRING callS )
  STRING larryS[255] = ""
  STRING robinS[255] = ""
  larryS = FNLarryNextS( FNStateLarryS( stateS ), callS )
  robinS = FNRobinNextS( FNStateRobinS( stateS ), callS )
  RETURN( FNCanonicalStateS( larryS + "/" + robinS ) )
END
INTEGER PROC FNDeltaChangeI( STRING stateS, STRING callS )
  STRING larryS[255] = ""
  STRING robinS[255] = ""
  INTEGER changeI = 0
  larryS = FNStateLarryS( stateS )
  robinS = FNStateRobinS( stateS )
  IF FNFindCharI( larryS, callS ) > 0
    changeI = changeI + 1
  ENDIF
  IF FNFindCharI( robinS, callS ) > 0
    changeI = changeI - 1
  ENDIF
  RETURN( changeI )
END
INTEGER PROC FNDistinctCountI( STRING stateS )
  STRING larryS[255] = ""
  STRING robinS[255] = ""
  STRING seenS[255] = ""
  STRING charS[1] = ""
  INTEGER indexI = 0
  larryS = FNStateLarryS( stateS )
  robinS = FNStateRobinS( stateS )
  FOR indexI = 1 TO Length( larryS )
    charS = SubStr( larryS, indexI, 1 )
    IF FNFindCharI( seenS, charS ) == 0
      seenS = seenS + charS
    ENDIF
  ENDFOR
  FOR indexI = 1 TO Length( robinS )
    charS = SubStr( robinS, indexI, 1 )
    IF FNFindCharI( seenS, charS ) == 0
      seenS = seenS + charS
    ENDIF
  ENDFOR
  RETURN( Length( seenS ) )
END
STRING PROC FNField1S( STRING lineS )
  INTEGER tabI = 0
  tabI = FNFindCharI( lineS, Chr( 9 ) )
  IF tabI == 0
    RETURN( lineS )
  ENDIF
  RETURN( SubStr( lineS, 1, tabI - 1 ) )
END
STRING PROC FNField2S( STRING lineS )
  INTEGER tab1I = 0
  INTEGER tab2I = 0
  tab1I = FNFindCharI( lineS, Chr( 9 ) )
  tab2I = FNFindDelimiterFromI( lineS, Chr( 9 ), tab1I + 1 )
  RETURN( SubStr( lineS, tab1I + 1, tab2I - tab1I - 1 ) )
END
STRING PROC FNField3S( STRING lineS )
  INTEGER tab1I = 0
  INTEGER tab2I = 0
  tab1I = FNFindCharI( lineS, Chr( 9 ) )
  tab2I = FNFindDelimiterFromI( lineS, Chr( 9 ), tab1I + 1 )
  RETURN( SubStr( lineS, tab2I + 1, Length( lineS ) - tab2I ) )
END
STRING PROC FNKeyPrefixS( STRING lineS )
  INTEGER tab1I = 0
  INTEGER tab2I = 0
  tab1I = FNFindCharI( lineS, Chr( 9 ) )
  tab2I = FNFindDelimiterFromI( lineS, Chr( 9 ), tab1I + 1 )
  RETURN( SubStr( lineS, 1, tab2I - 1 ) )
END
STRING PROC FNMakeDpLineS( STRING stateS, INTEGER deltaI, STRING countS )
  STRING lineS[255] = ""
  lineS = stateS + Chr( 9 ) + Format( deltaI + DELTA_SHIFT : 3 : "0" ) + Chr( 9 ) + FNBigTrimS( countS )
  RETURN( lineS )
END
INTEGER PROC FNGenerateNextLayerI( INTEGER sourceBufferI )
  INTEGER targetBufferI = 0
  INTEGER totalLinesI = 0
  INTEGER lineI = 0
  INTEGER symbolCountI = 0
  INTEGER symbolI = 0
  INTEGER deltaI = 0
  INTEGER nextDeltaI = 0
  INTEGER newWeightI = 0
  STRING lineS[255] = ""
  STRING stateS[255] = ""
  STRING countS[255] = ""
  STRING nextCountS[255] = ""
  STRING callS[1] = ""
  STRING nextStateS[255] = ""
  targetBufferI = CreateTempBuffer()
  PushLocation()
  GotoBufferId( sourceBufferI )
  totalLinesI = NumLines()
  FOR lineI = 1 TO totalLinesI
    GotoLine( lineI )
    lineS = GetText( 1, 255 )
    stateS = FNField1S( lineS )
    deltaI = Val( FNField2S( lineS ) ) - DELTA_SHIFT
    countS = FNField3S( lineS )
    symbolCountI = FNDistinctCountI( stateS )
    FOR symbolI = 1 TO symbolCountI
      callS = SubStr( gSymbolsGS, symbolI, 1 )
      nextStateS = FNNextStateS( stateS, callS )
      nextDeltaI = deltaI + FNDeltaChangeI( stateS, callS )
      AddLine( FNMakeDpLineS( nextStateS, nextDeltaI, countS ), targetBufferI )
    ENDFOR
    newWeightI = SYMBOL_COUNT - symbolCountI
    IF newWeightI > 0
      nextStateS = FNNextStateS( stateS, "Z" )
      nextDeltaI = deltaI + FNDeltaChangeI( stateS, "Z" )
      nextCountS = FNBigMulSmallS( countS, newWeightI )
      AddLine( FNMakeDpLineS( nextStateS, nextDeltaI, nextCountS ), targetBufferI )
    ENDIF
  ENDFOR
  PopLocation()
  RETURN( targetBufferI )
END
INTEGER PROC FNCollapseLayerI( INTEGER sourceBufferI )
  INTEGER targetBufferI = 0
  INTEGER totalLinesI = 0
  INTEGER lineI = 0
  STRING lineS[255] = ""
  STRING keyS[255] = ""
  STRING previousKeyS[255] = ""
  STRING countS[255] = ""
  STRING sumCountS[255] = "0"
  ProcSortBuffer( sourceBufferI )
  targetBufferI = CreateTempBuffer()
  PushLocation()
  GotoBufferId( sourceBufferI )
  totalLinesI = NumLines()
  IF totalLinesI > 0
    FOR lineI = 1 TO totalLinesI
      GotoLine( lineI )
      lineS = GetText( 1, 255 )
      keyS = FNKeyPrefixS( lineS )
      countS = FNField3S( lineS )
      IF lineI == 1
        previousKeyS = keyS
        sumCountS = countS
      ELSE
        IF keyS == previousKeyS
          sumCountS = FNBigAddS( sumCountS, countS )
        ELSE
          AddLine( previousKeyS + Chr( 9 ) + sumCountS, targetBufferI )
          previousKeyS = keyS
          sumCountS = countS
        ENDIF
      ENDIF
    ENDFOR
    AddLine( previousKeyS + Chr( 9 ) + sumCountS, targetBufferI )
  ENDIF
  PopLocation()
  RETURN( targetBufferI )
END
STRING PROC FNInsertDecimalS( STRING scaledS, INTEGER decimalsI )
  STRING workS[255] = FNBigTrimS( scaledS )
  STRING integerPartS[255] = ""
  STRING fractionPartS[255] = ""
  IF Length( workS ) <= decimalsI
    fractionPartS = FNRepeatCharS( "0", decimalsI - Length( workS ) ) + workS
    RETURN( "0." + fractionPartS )
  ENDIF
  integerPartS = SubStr( workS, 1, Length( workS ) - decimalsI )
  fractionPartS = SubStr( workS, Length( workS ) - decimalsI + 1, decimalsI )
  RETURN( integerPartS + "." + fractionPartS )
END
STRING PROC FNFormatAnswerS( STRING numeratorS )
  STRING roundedS[255] = ""
  STRING scaledS[255] = ""
  STRING roundAdderS[255] = ""
  roundAdderS = "5" + FNRepeatCharS( "0", ROUND_CUT - 1 )
  roundedS = FNBigAddS( numeratorS, roundAdderS )
  IF Length( roundedS ) <= ROUND_CUT
    scaledS = "0"
  ELSE
    scaledS = SubStr( roundedS, 1, Length( roundedS ) - ROUND_CUT )
  ENDIF
  RETURN( FNInsertDecimalS( scaledS, DECIMALS ) )
END
STRING PROC FNComputeAnswerS( INTEGER sourceBufferI )
  INTEGER totalLinesI = 0
  INTEGER lineI = 0
  INTEGER deltaI = 0
  INTEGER absDeltaI = 0
  STRING lineS[255] = ""
  STRING countS[255] = ""
  STRING termS[255] = ""
  STRING numeratorS[255] = "0"
  PushLocation()
  GotoBufferId( sourceBufferI )
  totalLinesI = NumLines()
  FOR lineI = 1 TO totalLinesI
    GotoLine( lineI )
    lineS = GetText( 1, 255 )
    deltaI = Val( FNField2S( lineS ) ) - DELTA_SHIFT
    absDeltaI = deltaI
    IF absDeltaI < 0
      absDeltaI = -absDeltaI
    ENDIF
    IF absDeltaI > 0
      countS = FNField3S( lineS )
      termS = FNBigMulSmallS( countS, absDeltaI )
      numeratorS = FNBigAddS( numeratorS, termS )
    ENDIF
  ENDFOR
  PopLocation()
  RETURN( FNFormatAnswerS( numeratorS ) )
END
PROC Main()
  INTEGER currentBufferI = 0
  INTEGER nextBufferI = 0
  INTEGER collapsedBufferI = 0
  INTEGER turnI = 0
  STRING answerS[255] = ""
  currentBufferI = CreateTempBuffer()
  AddLine( FNMakeDpLineS( "/", 0, "1" ), currentBufferI )
  FOR turnI = 1 TO TURN_COUNT
    nextBufferI = FNGenerateNextLayerI( currentBufferI )
    ProcAbandonBuffer( currentBufferI )
    collapsedBufferI = FNCollapseLayerI( nextBufferI )
    ProcAbandonBuffer( nextBufferI )
    currentBufferI = collapsedBufferI
  ENDFOR
  answerS = FNComputeAnswerS( currentBufferI )
  ProcAbandonBuffer( currentBufferI )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
