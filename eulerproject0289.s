// Euler Project 289
// Pure TSE SAL
// <version>1</version>
// History:
// 1 - ChatGPT - initial pure TSE SAL frontier-DP version for problem 289.
//
// The program computes L(6,10) mod 10^10.
// It uses a transfer-matrix / frontier dynamic programming approach.
// The state is stored as a 10-character hexadecimal-like string because
// after symmetry we only need m <= 6, thus state width = m + 4 <= 10.
//
// Output rule:
// - Only one final Warn() box
// - CopyToWinClip() before and after Warn()
// - Final Warn() contains only the final answer
//
#DEFINE STATE_WIDTH       10
#DEFINE COUNT_BASE        100000
#DEFINE CONNECTION_COUNT  14
#DEFINE FINAL_M           6
#DEFINE FINAL_N           10
FORWARD STRING  PROC FNZeroStateS()
FORWARD STRING  PROC FNHexCharS( INTEGER valueI )
FORWARD INTEGER PROC FNHexValueI( STRING charS )
FORWARD STRING  PROC FNCharAtS( STRING sourceS, INTEGER positionI )
FORWARD STRING  PROC FNSliceS( STRING sourceS, INTEGER firstI, INTEGER countI )
FORWARD STRING  PROC FNFirstCharsS( STRING sourceS, INTEGER countI )
FORWARD STRING  PROC FNDropFirstCharS( STRING sourceS )
FORWARD INTEGER PROC FNStateLabelI( STRING stateS, INTEGER indexI )
FORWARD STRING  PROC FNSetStateLabelS( STRING stateS, INTEGER indexI, INTEGER labelI )
FORWARD STRING  PROC FNMergeLabelS( STRING stateS, INTEGER sourceI, INTEGER destinationI, INTEGER limitI )
FORWARD INTEGER PROC FNCountLabelI( STRING stateS, INTEGER labelI, INTEGER activeLenI )
FORWARD STRING  PROC FNCanonicalStateS( STRING stateS, INTEGER activeLenI )
FORWARD STRING  PROC FNConnectionPatternS( INTEGER connectionI )
FORWARD INTEGER PROC FNChoose4ValueI( INTEGER whichI, INTEGER firstI, INTEGER secondI, INTEGER thirdI, INTEGER fourthI )
FORWARD STRING  PROC FNEncodedLineS( STRING stateS, INTEGER highI, INTEGER lowI )
FORWARD STRING  PROC FNLineStateS( STRING lineS )
FORWARD INTEGER PROC FNLineHighI( STRING lineS )
FORWARD INTEGER PROC FNLineLowI( STRING lineS )
FORWARD STRING  PROC FNCountToResultS( INTEGER highI, INTEGER lowI )
FORWARD PROC    PROCSortBuffer( INTEGER bufferI )
FORWARD PROC    PROCDestroyBuffer( INTEGER bufferI )
FORWARD PROC    PROCGenerateTransitions( STRING stateS, INTEGER activeLenI, INTEGER xI, INTEGER yI, INTEGER nI, INTEGER mI, INTEGER finalB, INTEGER waysHighI, INTEGER waysLowI, INTEGER workBufferI )
FORWARD PROC    PROCAggregateBuffer( INTEGER workBufferI, INTEGER nextBufferI )
FORWARD STRING  PROC FNComputeLModS( INTEGER inputMI, INTEGER inputNI )
STRING PROC FNZeroStateS()
  RETURN( "0000000000" )
END
STRING PROC FNHexCharS( INTEGER valueI )
  CASE valueI
    WHEN 0
      RETURN( "0" )
    WHEN 1
      RETURN( "1" )
    WHEN 2
      RETURN( "2" )
    WHEN 3
      RETURN( "3" )
    WHEN 4
      RETURN( "4" )
    WHEN 5
      RETURN( "5" )
    WHEN 6
      RETURN( "6" )
    WHEN 7
      RETURN( "7" )
    WHEN 8
      RETURN( "8" )
    WHEN 9
      RETURN( "9" )
    WHEN 10
      RETURN( "A" )
    WHEN 11
      RETURN( "B" )
    WHEN 12
      RETURN( "C" )
    WHEN 13
      RETURN( "D" )
    WHEN 14
      RETURN( "E" )
    WHEN 15
      RETURN( "F" )
    OTHERWISE
      RETURN( "0" )
  ENDCASE
END
INTEGER PROC FNHexValueI( STRING charS )
  CASE charS
    WHEN "0"
      RETURN( 0 )
    WHEN "1"
      RETURN( 1 )
    WHEN "2"
      RETURN( 2 )
    WHEN "3"
      RETURN( 3 )
    WHEN "4"
      RETURN( 4 )
    WHEN "5"
      RETURN( 5 )
    WHEN "6"
      RETURN( 6 )
    WHEN "7"
      RETURN( 7 )
    WHEN "8"
      RETURN( 8 )
    WHEN "9"
      RETURN( 9 )
    WHEN "A"
      RETURN( 10 )
    WHEN "B"
      RETURN( 11 )
    WHEN "C"
      RETURN( 12 )
    WHEN "D"
      RETURN( 13 )
    WHEN "E"
      RETURN( 14 )
    WHEN "F"
      RETURN( 15 )
    OTHERWISE
      RETURN( 0 )
  ENDCASE
END
STRING PROC FNCharAtS( STRING sourceS, INTEGER positionI )
  IF positionI < 1
    RETURN( "0" )
  ENDIF
  IF positionI > Length( sourceS )
    RETURN( "0" )
  ENDIF
  RETURN( SubStr( sourceS, positionI, 1 ) )
END
STRING PROC FNSliceS( STRING sourceS, INTEGER firstI, INTEGER countI )
  STRING resultS[255] = ""
  INTEGER indexI = 0
  IF countI <= 0
    RETURN( "" )
  ENDIF
  FOR indexI = 0 TO countI - 1
    resultS = resultS + FNCharAtS( sourceS, firstI + indexI )
  ENDFOR
  RETURN( resultS )
END
STRING PROC FNFirstCharsS( STRING sourceS, INTEGER countI )
  RETURN( FNSliceS( sourceS, 1, countI ) )
END
STRING PROC FNDropFirstCharS( STRING sourceS )
  RETURN( FNSliceS( sourceS, 2, Length( sourceS ) - 1 ) )
END
INTEGER PROC FNStateLabelI( STRING stateS, INTEGER indexI )
  RETURN( FNHexValueI( FNCharAtS( stateS, indexI + 1 ) ) )
END
STRING PROC FNSetStateLabelS( STRING stateS, INTEGER indexI, INTEGER labelI )
  STRING resultS[255] = ""
  INTEGER positionI = 0
  FOR positionI = 1 TO Length( stateS )
    IF positionI == indexI + 1
      resultS = resultS + FNHexCharS( labelI )
    ELSE
      resultS = resultS + FNCharAtS( stateS, positionI )
    ENDIF
  ENDFOR
  RETURN( resultS )
END
STRING PROC FNMergeLabelS( STRING stateS, INTEGER sourceI, INTEGER destinationI, INTEGER limitI )
  STRING resultS[255] = ""
  INTEGER positionI = 0
  INTEGER labelI = 0
  FOR positionI = 1 TO Length( stateS )
    IF positionI <= limitI
      labelI = FNHexValueI( FNCharAtS( stateS, positionI ) )
      IF labelI == sourceI
        resultS = resultS + FNHexCharS( destinationI )
      ELSE
        resultS = resultS + FNCharAtS( stateS, positionI )
      ENDIF
    ELSE
      resultS = resultS + FNCharAtS( stateS, positionI )
    ENDIF
  ENDFOR
  RETURN( resultS )
END
INTEGER PROC FNCountLabelI( STRING stateS, INTEGER labelI, INTEGER activeLenI )
  INTEGER countI = 0
  INTEGER indexI = 0
  FOR indexI = 0 TO activeLenI - 1
    IF FNStateLabelI( stateS, indexI ) == labelI
      countI = countI + 1
    ENDIF
  ENDFOR
  RETURN( countI )
END
STRING PROC FNCanonicalStateS( STRING stateS, INTEGER activeLenI )
  STRING resultS[255] = ""
  INTEGER lastNonZeroI = -1
  INTEGER indexI = 0
  INTEGER nextLabelI = 0
  INTEGER labelI = 0
  INTEGER newLabelI = 0
  INTEGER map0I = -1
  INTEGER map1I = -1
  INTEGER map2I = -1
  INTEGER map3I = -1
  INTEGER map4I = -1
  INTEGER map5I = -1
  INTEGER map6I = -1
  INTEGER map7I = -1
  INTEGER map8I = -1
  INTEGER map9I = -1
  INTEGER map10I = -1
  INTEGER map11I = -1
  INTEGER map12I = -1
  INTEGER map13I = -1
  INTEGER map14I = -1
  INTEGER map15I = -1
  FOR indexI = activeLenI - 1 DOWNTO 0
    IF FNStateLabelI( stateS, indexI ) > 0
      lastNonZeroI = indexI
      indexI = -1
    ENDIF
  ENDFOR
  IF lastNonZeroI < 0
    RETURN( FNZeroStateS() )
  ENDIF
  FOR indexI = 0 TO lastNonZeroI
    labelI = FNStateLabelI( stateS, indexI )
    CASE labelI
      WHEN 0
        IF map0I < 0
          map0I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map0I
      WHEN 1
        IF map1I < 0
          map1I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map1I
      WHEN 2
        IF map2I < 0
          map2I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map2I
      WHEN 3
        IF map3I < 0
          map3I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map3I
      WHEN 4
        IF map4I < 0
          map4I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map4I
      WHEN 5
        IF map5I < 0
          map5I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map5I
      WHEN 6
        IF map6I < 0
          map6I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map6I
      WHEN 7
        IF map7I < 0
          map7I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map7I
      WHEN 8
        IF map8I < 0
          map8I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map8I
      WHEN 9
        IF map9I < 0
          map9I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map9I
      WHEN 10
        IF map10I < 0
          map10I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map10I
      WHEN 11
        IF map11I < 0
          map11I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map11I
      WHEN 12
        IF map12I < 0
          map12I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map12I
      WHEN 13
        IF map13I < 0
          map13I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map13I
      WHEN 14
        IF map14I < 0
          map14I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map14I
      WHEN 15
        IF map15I < 0
          map15I = nextLabelI
          nextLabelI = nextLabelI + 1
        ENDIF
        newLabelI = map15I
      OTHERWISE
        newLabelI = 0
    ENDCASE
    resultS = resultS + FNHexCharS( newLabelI )
  ENDFOR
  FOR indexI = lastNonZeroI + 1 TO STATE_WIDTH - 1
    resultS = resultS + "0"
  ENDFOR
  RETURN( resultS )
END
STRING PROC FNConnectionPatternS( INTEGER connectionI )
  CASE connectionI
    WHEN 1
      RETURN( "0000" )
    WHEN 2
      RETURN( "0003" )
    WHEN 3
      RETURN( "0022" )
    WHEN 4
      RETURN( "0023" )
    WHEN 5
      RETURN( "0020" )
    WHEN 6
      RETURN( "0100" )
    WHEN 7
      RETURN( "0103" )
    WHEN 8
      RETURN( "0110" )
    WHEN 9
      RETURN( "0111" )
    WHEN 10
      RETURN( "0113" )
    WHEN 11
      RETURN( "0120" )
    WHEN 12
      RETURN( "0121" )
    WHEN 13
      RETURN( "0122" )
    WHEN 14
      RETURN( "0123" )
    OTHERWISE
      RETURN( "0000" )
  ENDCASE
END
INTEGER PROC FNChoose4ValueI( INTEGER whichI, INTEGER firstI, INTEGER secondI, INTEGER thirdI, INTEGER fourthI )
  CASE whichI
    WHEN 0
      RETURN( firstI )
    WHEN 1
      RETURN( secondI )
    WHEN 2
      RETURN( thirdI )
    WHEN 3
      RETURN( fourthI )
    OTHERWISE
      RETURN( 0 )
  ENDCASE
END
STRING PROC FNEncodedLineS( STRING stateS, INTEGER highI, INTEGER lowI )
  RETURN( stateS + Format( highI : 5 : "0" ) + Format( lowI : 5 : "0" ) )
END
STRING PROC FNLineStateS( STRING lineS )
  RETURN( FNSliceS( lineS, 1, STATE_WIDTH ) )
END
INTEGER PROC FNLineHighI( STRING lineS )
  RETURN( Val( FNSliceS( lineS, STATE_WIDTH + 1, 5 ) ) )
END
INTEGER PROC FNLineLowI( STRING lineS )
  RETURN( Val( FNSliceS( lineS, STATE_WIDTH + 6, 5 ) ) )
END
STRING PROC FNCountToResultS( INTEGER highI, INTEGER lowI )
  IF highI == 0
    RETURN( Format( lowI ) )
  ENDIF
  RETURN( Format( highI ) + Format( lowI : 5 : "0" ) )
END
PROC PROCSortBuffer( INTEGER bufferI )
  INTEGER lineCountI = 0
  PushLocation()
  GotoBufferId( bufferI )
  lineCountI = NumLines()
  IF lineCountI > 1
    MarkAll()
    ExecMacro( "sort" )
  ENDIF
  PopLocation()
END
PROC PROCDestroyBuffer( INTEGER bufferI )
  IF bufferI == 0
    RETURN()
  ENDIF
  PushLocation()
  GotoBufferId( bufferI )
  AbandonFile()
  PopLocation()
END
PROC PROCGenerateTransitions( STRING stateS, INTEGER activeLenI, INTEGER xI, INTEGER yI, INTEGER nI, INTEGER mI, INTEGER finalB, INTEGER waysHighI, INTEGER waysLowI, INTEGER workBufferI )
  INTEGER newColorI = 0
  INTEGER colors0I = 0
  INTEGER colors1I = 0
  INTEGER colors2I = 0
  INTEGER colors3I = 0
  INTEGER connectionI = 0
  STRING patternS[255] = ""
  INTEGER idx0I = 0
  INTEGER idx1I = 0
  INTEGER idx2I = 0
  INTEGER idx3I = 0
  STRING kkS[255] = ""
  INTEGER okB = FALSE
  INTEGER iI = 0
  INTEGER jI = 0
  INTEGER colorI = 0
  INTEGER colorJI = 0
  INTEGER idxI = 0
  INTEGER idxJI = 0
  INTEGER srcI = 0
  INTEGER dstI = 0
  INTEGER curI = 0
  INTEGER oldI = 0
  STRING successorS[255] = ""
  IF ( xI == nI ) OR ( yI == mI )
    newColorI = 0
  ELSE
    newColorI = 15
  ENDIF
  colors0I = FNStateLabelI( stateS, yI )
  colors1I = FNStateLabelI( stateS, yI + 1 )
  colors2I = FNStateLabelI( stateS, yI + 2 )
  colors3I = newColorI
  FOR connectionI = 1 TO CONNECTION_COUNT
    patternS = FNConnectionPatternS( connectionI )
    idx0I = Val( FNCharAtS( patternS, 1 ) )
    idx1I = Val( FNCharAtS( patternS, 2 ) )
    idx2I = Val( FNCharAtS( patternS, 3 ) )
    idx3I = Val( FNCharAtS( patternS, 4 ) )
    kkS = FNHexCharS( newColorI ) + stateS
    okB = TRUE
    FOR iI = 0 TO 3
      IF okB == TRUE
        colorI = FNChoose4ValueI( iI, colors0I, colors1I, colors2I, colors3I )
        IF colorI == 0
          idxI = FNChoose4ValueI( iI, idx0I, idx1I, idx2I, idx3I )
          FOR jI = 0 TO 3
            IF okB == TRUE
              colorJI = FNChoose4ValueI( jI, colors0I, colors1I, colors2I, colors3I )
              idxJI = FNChoose4ValueI( jI, idx0I, idx1I, idx2I, idx3I )
              IF NOT( ( colorJI == 0 ) == ( idxI == idxJI ) )
                okB = FALSE
              ENDIF
            ENDIF
          ENDFOR
        ENDIF
      ENDIF
    ENDFOR
    IF okB == TRUE
      FOR iI = 0 TO 3
        IF okB == TRUE
          idxI = FNChoose4ValueI( iI, idx0I, idx1I, idx2I, idx3I )
          IF NOT( iI == idxI )
            IF iI == 3
              srcI = newColorI
            ELSE
              srcI = FNStateLabelI( kkS, yI + iI + 1 )
            ENDIF
            dstI = FNStateLabelI( kkS, yI + idxI + 1 )
            IF srcI == 0
              //
            ELSE
              IF ( dstI == 0 ) OR ( srcI == dstI )
                okB = FALSE
              ELSE
                kkS = FNMergeLabelS( kkS, srcI, dstI, activeLenI + 1 )
              ENDIF
            ENDIF
          ENDIF
        ENDIF
      ENDFOR
    ENDIF
    IF okB == TRUE
      curI = FNStateLabelI( kkS, 0 )
      kkS = FNDropFirstCharS( kkS )
      oldI = FNStateLabelI( kkS, yI + 1 )
      IF ( FNCountLabelI( kkS, oldI, activeLenI ) > 1 ) OR ( oldI == curI ) OR ( finalB == TRUE )
        kkS = FNSetStateLabelS( kkS, yI + 1, curI )
        IF yI == mI
          kkS = "0" + FNFirstCharsS( kkS, STATE_WIDTH - 1 )
        ENDIF
        successorS = FNCanonicalStateS( kkS, activeLenI )
        AddLine( FNEncodedLineS( successorS, waysHighI, waysLowI ), workBufferI )
      ENDIF
    ENDIF
  ENDFOR
END
PROC PROCAggregateBuffer( INTEGER workBufferI, INTEGER nextBufferI )
  INTEGER lineCountI = 0
  INTEGER lineIndexI = 0
  STRING lineS[255] = ""
  STRING currentStateS[255] = ""
  STRING newStateS[255] = ""
  INTEGER sumHighI = 0
  INTEGER sumLowI = 0
  INTEGER addHighI = 0
  INTEGER addLowI = 0
  INTEGER carryI = 0
  PushLocation()
  GotoBufferId( workBufferI )
  lineCountI = NumLines()
  IF lineCountI <= 0
    PopLocation()
    RETURN()
  ENDIF
  GotoLine( 1 )
  lineS = GetText( 1, 20 )
  currentStateS = FNLineStateS( lineS )
  sumHighI = FNLineHighI( lineS )
  sumLowI = FNLineLowI( lineS )
  FOR lineIndexI = 2 TO lineCountI
    GotoLine( lineIndexI )
    lineS = GetText( 1, 20 )
    newStateS = FNLineStateS( lineS )
    addHighI = FNLineHighI( lineS )
    addLowI = FNLineLowI( lineS )
    IF newStateS == currentStateS
      sumLowI = sumLowI + addLowI
      carryI = 0
      IF sumLowI >= COUNT_BASE
        sumLowI = sumLowI - COUNT_BASE
        carryI = 1
      ENDIF
      sumHighI = sumHighI + addHighI + carryI
      IF sumHighI >= COUNT_BASE
        sumHighI = sumHighI - COUNT_BASE
      ENDIF
    ELSE
      AddLine( FNEncodedLineS( currentStateS, sumHighI, sumLowI ), nextBufferI )
      currentStateS = newStateS
      sumHighI = addHighI
      sumLowI = addLowI
    ENDIF
  ENDFOR
  AddLine( FNEncodedLineS( currentStateS, sumHighI, sumLowI ), nextBufferI )
  PopLocation()
END
STRING PROC FNComputeLModS( INTEGER inputMI, INTEGER inputNI )
  INTEGER workMI = inputMI
  INTEGER workNI = inputNI
  INTEGER swapI = 0
  INTEGER activeLenI = 0
  INTEGER currentBufferI = 0
  INTEGER workBufferI = 0
  INTEGER nextBufferI = 0
  INTEGER xI = 0
  INTEGER yI = 0
  INTEGER lineCountI = 0
  INTEGER lineIndexI = 0
  INTEGER finalB = FALSE
  STRING lineS[255] = ""
  STRING stateS[255] = ""
  INTEGER waysHighI = 0
  INTEGER waysLowI = 0
  STRING resultS[255] = "0"
  IF workMI > workNI
    swapI = workMI
    workMI = workNI
    workNI = swapI
  ENDIF
  activeLenI = workMI + 4
  currentBufferI = CreateTempBuffer()
  AddLine( FNEncodedLineS( FNZeroStateS(), 0, 1 ), currentBufferI )
  FOR xI = 0 TO workNI
    FOR yI = 0 TO workMI
      IF ( xI == workNI ) AND ( yI == workMI )
        finalB = TRUE
      ELSE
        finalB = FALSE
      ENDIF
      workBufferI = CreateTempBuffer()
      nextBufferI = CreateTempBuffer()
      PushLocation()
      GotoBufferId( currentBufferI )
      lineCountI = NumLines()
      FOR lineIndexI = 1 TO lineCountI
        GotoLine( lineIndexI )
        lineS = GetText( 1, 20 )
        stateS = FNLineStateS( lineS )
        waysHighI = FNLineHighI( lineS )
        waysLowI = FNLineLowI( lineS )
        PROCGenerateTransitions( stateS, activeLenI, xI, yI, workNI, workMI, finalB, waysHighI, waysLowI, workBufferI )
      ENDFOR
      PopLocation()
      PROCSortBuffer( workBufferI )
      PROCAggregateBuffer( workBufferI, nextBufferI )
      PROCDestroyBuffer( currentBufferI )
      PROCDestroyBuffer( workBufferI )
      currentBufferI = nextBufferI
    ENDFOR
  ENDFOR
  PushLocation()
  GotoBufferId( currentBufferI )
  lineCountI = NumLines()
  FOR lineIndexI = 1 TO lineCountI
    GotoLine( lineIndexI )
    lineS = GetText( 1, 20 )
    IF FNLineStateS( lineS ) == FNZeroStateS()
      resultS = FNCountToResultS( FNLineHighI( lineS ), FNLineLowI( lineS ) )
    ENDIF
  ENDFOR
  PopLocation()
  PROCDestroyBuffer( currentBufferI )
  RETURN( resultS )
END
PROC Main()
  STRING answerS[255] = ""
  answerS = FNComputeLModS( FINAL_M, FINAL_N )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
