/*
  Project Euler problem 300
  Protein Folding
  Pure TSE SAL solution

  <version>1</version>

  History:
  2026-04-20 ChatGPT GPT-5.4 Thinking created this pure TSE SAL program.
*/

#DEFINE LENGTH_N            15
#DEFINE MAX_CONTACTS        8
#DEFINE TOTAL_PROTEINS      32768

INTEGER gGraph1BufferGI = 0
INTEGER gGraph2BufferGI = 0
INTEGER gGraph3BufferGI = 0
INTEGER gGraph4BufferGI = 0
INTEGER gGraph5BufferGI = 0
INTEGER gGraph6BufferGI = 0
INTEGER gGraph7BufferGI = 0
INTEGER gGraph8BufferGI = 0
INTEGER gMax1BufferGI   = 0
INTEGER gMax2BufferGI   = 0
INTEGER gMax3BufferGI   = 0
INTEGER gMax4BufferGI   = 0
INTEGER gMax5BufferGI   = 0
INTEGER gMax6BufferGI   = 0
INTEGER gMax7BufferGI   = 0
INTEGER gMax8BufferGI   = 0
INTEGER gPos01XGI       = 0
INTEGER gPos02XGI       = 0
INTEGER gPos03XGI       = 0
INTEGER gPos04XGI       = 0
INTEGER gPos05XGI       = 0
INTEGER gPos06XGI       = 0
INTEGER gPos07XGI       = 0
INTEGER gPos08XGI       = 0
INTEGER gPos09XGI       = 0
INTEGER gPos10XGI       = 0
INTEGER gPos11XGI       = 0
INTEGER gPos12XGI       = 0
INTEGER gPos13XGI       = 0
INTEGER gPos14XGI       = 0
INTEGER gPos15XGI       = 0
INTEGER gPos01YGI       = 0
INTEGER gPos02YGI       = 0
INTEGER gPos03YGI       = 0
INTEGER gPos04YGI       = 0
INTEGER gPos05YGI       = 0
INTEGER gPos06YGI       = 0
INTEGER gPos07YGI       = 0
INTEGER gPos08YGI       = 0
INTEGER gPos09YGI       = 0
INTEGER gPos10YGI       = 0
INTEGER gPos11YGI       = 0
INTEGER gPos12YGI       = 0
INTEGER gPos13YGI       = 0
INTEGER gPos14YGI       = 0
INTEGER gPos15YGI       = 0

INTEGER PROC FNGraphBufferI( INTEGER countI )
  CASE countI
    WHEN 1
      return( gGraph1BufferGI )
    WHEN 2
      return( gGraph2BufferGI )
    WHEN 3
      return( gGraph3BufferGI )
    WHEN 4
      return( gGraph4BufferGI )
    WHEN 5
      return( gGraph5BufferGI )
    WHEN 6
      return( gGraph6BufferGI )
    WHEN 7
      return( gGraph7BufferGI )
    WHEN 8
      return( gGraph8BufferGI )
    OTHERWISE
      return( 0 )
  ENDCASE
END

INTEGER PROC FNMaxBufferI( INTEGER countI )
  CASE countI
    WHEN 1
      return( gMax1BufferGI )
    WHEN 2
      return( gMax2BufferGI )
    WHEN 3
      return( gMax3BufferGI )
    WHEN 4
      return( gMax4BufferGI )
    WHEN 5
      return( gMax5BufferGI )
    WHEN 6
      return( gMax6BufferGI )
    WHEN 7
      return( gMax7BufferGI )
    WHEN 8
      return( gMax8BufferGI )
    OTHERWISE
      return( 0 )
  ENDCASE
END

STRING PROC FNBufferLineS( INTEGER bufferI, INTEGER lineI )
  STRING lineS[255] = ""
  PushLocation()
  GotoBufferId( bufferI )
  GotoLine( lineI )
  lineS = GetText( 1, 255 )
  PopLocation()
  return( lineS )
END

INTEGER PROC FNBufferLineCountI( INTEGER bufferI )
  INTEGER lineCountI = 0
  PushLocation()
  GotoBufferId( bufferI )
  lineCountI = NumLines()
  PopLocation()
  return( lineCountI )
END

PROC PROCSortUniqueBuffer( INTEGER bufferI )
  INTEGER lineCountI = 0
  PushLocation()
  GotoBufferId( bufferI )
  lineCountI = NumLines()
  IF lineCountI > 0
    MarkAll()
    ExecMacro( "sort -k" )
  ENDIF
  PopLocation()
END

PROC PROCSetPoint( INTEGER indexI, INTEGER xI, INTEGER yI )
  CASE indexI
    WHEN 1
      gPos01XGI = xI
      gPos01YGI = yI
    WHEN 2
      gPos02XGI = xI
      gPos02YGI = yI
    WHEN 3
      gPos03XGI = xI
      gPos03YGI = yI
    WHEN 4
      gPos04XGI = xI
      gPos04YGI = yI
    WHEN 5
      gPos05XGI = xI
      gPos05YGI = yI
    WHEN 6
      gPos06XGI = xI
      gPos06YGI = yI
    WHEN 7
      gPos07XGI = xI
      gPos07YGI = yI
    WHEN 8
      gPos08XGI = xI
      gPos08YGI = yI
    WHEN 9
      gPos09XGI = xI
      gPos09YGI = yI
    WHEN 10
      gPos10XGI = xI
      gPos10YGI = yI
    WHEN 11
      gPos11XGI = xI
      gPos11YGI = yI
    WHEN 12
      gPos12XGI = xI
      gPos12YGI = yI
    WHEN 13
      gPos13XGI = xI
      gPos13YGI = yI
    WHEN 14
      gPos14XGI = xI
      gPos14YGI = yI
    WHEN 15
      gPos15XGI = xI
      gPos15YGI = yI
  ENDCASE
END

INTEGER PROC FNPointXI( INTEGER indexI )
  CASE indexI
    WHEN 1
      return( gPos01XGI )
    WHEN 2
      return( gPos02XGI )
    WHEN 3
      return( gPos03XGI )
    WHEN 4
      return( gPos04XGI )
    WHEN 5
      return( gPos05XGI )
    WHEN 6
      return( gPos06XGI )
    WHEN 7
      return( gPos07XGI )
    WHEN 8
      return( gPos08XGI )
    WHEN 9
      return( gPos09XGI )
    WHEN 10
      return( gPos10XGI )
    WHEN 11
      return( gPos11XGI )
    WHEN 12
      return( gPos12XGI )
    WHEN 13
      return( gPos13XGI )
    WHEN 14
      return( gPos14XGI )
    WHEN 15
      return( gPos15XGI )
    OTHERWISE
      return( 0 )
  ENDCASE
END

INTEGER PROC FNPointYI( INTEGER indexI )
  CASE indexI
    WHEN 1
      return( gPos01YGI )
    WHEN 2
      return( gPos02YGI )
    WHEN 3
      return( gPos03YGI )
    WHEN 4
      return( gPos04YGI )
    WHEN 5
      return( gPos05YGI )
    WHEN 6
      return( gPos06YGI )
    WHEN 7
      return( gPos07YGI )
    WHEN 8
      return( gPos08YGI )
    WHEN 9
      return( gPos09YGI )
    WHEN 10
      return( gPos10YGI )
    WHEN 11
      return( gPos11YGI )
    WHEN 12
      return( gPos12YGI )
    WHEN 13
      return( gPos13YGI )
    WHEN 14
      return( gPos14YGI )
    WHEN 15
      return( gPos15YGI )
    OTHERWISE
      return( 0 )
  ENDCASE
END

INTEGER PROC FNAbsI( INTEGER valueI )
  IF valueI < 0
    return( -valueI )
  ENDIF
  return( valueI )
END

INTEGER PROC FNManhattanI( INTEGER x1I, INTEGER y1I, INTEGER x2I, INTEGER y2I )
  return( FNAbsI( x1I - x2I ) + FNAbsI( y1I - y2I ) )
END

INTEGER PROC FNOccupiedB( INTEGER lastIndexI, INTEGER xI, INTEGER yI )
  INTEGER I = 0
  FOR I = 1 TO lastIndexI
    IF FNPointXI( I ) == xI
      IF FNPointYI( I ) == yI
        return( TRUE )
      ENDIF
    ENDIF
  ENDFOR
  return( FALSE )
END

STRING PROC FNMaskTextS( INTEGER maskI )
  return( Format( maskI : 5 : "0" ) )
END

PROC PROCStoreGraph()
  INTEGER firstI = 0
  INTEGER secondI = 0
  INTEGER x1I = 0
  INTEGER y1I = 0
  INTEGER x2I = 0
  INTEGER y2I = 0
  INTEGER countI = 0
  INTEGER maskI = 0
  INTEGER bufferI = 0
  STRING lineS[255] = ""
  FOR firstI = 1 TO LENGTH_N
    x1I = FNPointXI( firstI )
    y1I = FNPointYI( firstI )
    FOR secondI = firstI + 2 TO LENGTH_N
      x2I = FNPointXI( secondI )
      y2I = FNPointYI( secondI )
      IF FNManhattanI( x1I, y1I, x2I, y2I ) == 1
        maskI = ( 1 shl ( firstI - 1 ) ) | ( 1 shl ( secondI - 1 ) )
        lineS = lineS + FNMaskTextS( maskI )
        countI = countI + 1
      ENDIF
    ENDFOR
  ENDFOR
  IF countI > 0
    bufferI = FNGraphBufferI( countI )
    AddLine( lineS, bufferI )
  ENDIF
END

PROC PROCSearchLayouts( INTEGER currentIndexI, INTEGER xI, INTEGER yI )
  INTEGER nextXI = 0
  INTEGER nextYI = 0
  IF currentIndexI > LENGTH_N
    IF yI >= 0
      PROCStoreGraph()
    ENDIF
    return()
  ENDIF
  nextXI = xI - 1
  nextYI = yI
  IF FNOccupiedB( currentIndexI - 1, nextXI, nextYI ) == FALSE
    PROCSetPoint( currentIndexI, nextXI, nextYI )
    PROCSearchLayouts( currentIndexI + 1, nextXI, nextYI )
  ENDIF
  nextXI = xI + 1
  nextYI = yI
  IF FNOccupiedB( currentIndexI - 1, nextXI, nextYI ) == FALSE
    PROCSetPoint( currentIndexI, nextXI, nextYI )
    PROCSearchLayouts( currentIndexI + 1, nextXI, nextYI )
  ENDIF
  nextXI = xI
  nextYI = yI - 1
  IF FNOccupiedB( currentIndexI - 1, nextXI, nextYI ) == FALSE
    PROCSetPoint( currentIndexI, nextXI, nextYI )
    PROCSearchLayouts( currentIndexI + 1, nextXI, nextYI )
  ENDIF
  nextXI = xI
  nextYI = yI + 1
  IF FNOccupiedB( currentIndexI - 1, nextXI, nextYI ) == FALSE
    PROCSetPoint( currentIndexI, nextXI, nextYI )
    PROCSearchLayouts( currentIndexI + 1, nextXI, nextYI )
  ENDIF
END

INTEGER PROC FNIsSubsetB( STRING candidateS, INTEGER candidateCountI, STRING superS, INTEGER superCountI )
  INTEGER candidateOffsetI = 1
  INTEGER superOffsetI = 1
  INTEGER candidateMaskI = 0
  INTEGER superMaskI = 0
  WHILE candidateOffsetI <= candidateCountI * 5
    IF superOffsetI > superCountI * 5
      return( FALSE )
    ENDIF
    candidateMaskI = Val( SubStr( candidateS, candidateOffsetI, 5 ) )
    superMaskI     = Val( SubStr( superS,     superOffsetI,     5 ) )
    IF candidateMaskI == superMaskI
      candidateOffsetI = candidateOffsetI + 5
      superOffsetI     = superOffsetI + 5
    ELSE
      IF candidateMaskI > superMaskI
        superOffsetI = superOffsetI + 5
      ELSE
        return( FALSE )
      ENDIF
    ENDIF
  ENDWHILE
  return( TRUE )
END

INTEGER PROC FNIsDominatedB( STRING candidateS, INTEGER candidateCountI )
  INTEGER largerCountI = 0
  INTEGER bufferI = 0
  INTEGER lineCountI = 0
  INTEGER lineIndexI = 0
  STRING superS[255] = ""
  PushLocation()
  FOR largerCountI = candidateCountI + 1 TO MAX_CONTACTS
    bufferI = FNMaxBufferI( largerCountI )
    GotoBufferId( bufferI )
    lineCountI = NumLines()
    FOR lineIndexI = 1 TO lineCountI
      GotoLine( lineIndexI )
      superS = GetText( 1, 255 )
      IF FNIsSubsetB( candidateS, candidateCountI, superS, largerCountI )
        PopLocation()
        return( TRUE )
      ENDIF
    ENDFOR
  ENDFOR
  PopLocation()
  return( FALSE )
END

PROC PROCBuildMaximalBuffers()
  INTEGER countI = 0
  INTEGER bufferI = 0
  INTEGER maxBufferI = 0
  INTEGER lineCountI = 0
  INTEGER lineIndexI = 0
  STRING lineS[255] = ""
  FOR countI = 1 TO MAX_CONTACTS
    PROCSortUniqueBuffer( FNGraphBufferI( countI ) )
  ENDFOR
  FOR countI = MAX_CONTACTS DOWNTO 1
    bufferI    = FNGraphBufferI( countI )
    maxBufferI = FNMaxBufferI( countI )
    PushLocation()
    GotoBufferId( bufferI )
    lineCountI = NumLines()
    FOR lineIndexI = 1 TO lineCountI
      GotoLine( lineIndexI )
      lineS = GetText( 1, 255 )
      IF FNIsDominatedB( lineS, countI ) == FALSE
        AddLine( lineS, maxBufferI )
      ENDIF
    ENDFOR
    PopLocation()
  ENDFOR
END

INTEGER PROC FNReverseProteinI( INTEGER proteinI )
  INTEGER reverseI = 0
  INTEGER bitIndexI = 0
  FOR bitIndexI = 0 TO LENGTH_N - 1
    IF ( proteinI & ( 1 shl bitIndexI ) ) <> 0
      reverseI = reverseI | ( 1 shl ( LENGTH_N - 1 - bitIndexI ) )
    ENDIF
  ENDFOR
  return( reverseI )
END

INTEGER PROC FNDirectContactsI( INTEGER proteinI )
  INTEGER contactCountI = 0
  INTEGER bitIndexI = 0
  FOR bitIndexI = 0 TO LENGTH_N - 2
    IF ( proteinI & ( 3 shl bitIndexI ) ) == 0
      contactCountI = contactCountI + 1
    ENDIF
  ENDFOR
  return( contactCountI )
END

INTEGER PROC FNCountSatisfiedContactsI( INTEGER proteinI, STRING graphS, INTEGER graphCountI, INTEGER minimumExtraI )
  INTEGER foundI = 0
  INTEGER remainingI = graphCountI
  INTEGER offsetI = 1
  INTEGER maskI = 0
  WHILE offsetI <= graphCountI * 5
    maskI = Val( SubStr( graphS, offsetI, 5 ) )
    IF ( proteinI & maskI ) == 0
      foundI = foundI + 1
    ENDIF
    remainingI = remainingI - 1
    IF foundI + remainingI <= minimumExtraI
      return( foundI )
    ENDIF
    offsetI = offsetI + 5
  ENDWHILE
  return( foundI )
END

INTEGER PROC FNSumBestContactsI()
  INTEGER proteinI = 0
  INTEGER reverseI = 0
  INTEGER weightI = 0
  INTEGER directI = 0
  INTEGER bestI = 0
  INTEGER bestExtraI = 0
  INTEGER graphCountI = 0
  INTEGER bufferI = 0
  INTEGER lineCountI = 0
  INTEGER lineIndexI = 0
  INTEGER foundExtraI = 0
  INTEGER sumI = 0
  INTEGER stopB = FALSE
  STRING graphS[255] = ""
  FOR proteinI = 0 TO TOTAL_PROTEINS - 1
    reverseI = FNReverseProteinI( proteinI )
    IF proteinI <= reverseI
      weightI = 2
      IF proteinI == reverseI
        weightI = 1
      ENDIF
      directI = FNDirectContactsI( proteinI )
      bestI = directI
      bestExtraI = 0
      stopB = FALSE
      PushLocation()
      graphCountI = MAX_CONTACTS
      WHILE graphCountI >= 1
        IF stopB == TRUE
          graphCountI = 0
        ELSE
          IF directI + graphCountI <= bestI
            stopB = TRUE
          ELSE
            bufferI = FNMaxBufferI( graphCountI )
            GotoBufferId( bufferI )
            lineCountI = NumLines()
            lineIndexI = 1
            WHILE lineIndexI <= lineCountI
              GotoLine( lineIndexI )
              graphS = GetText( 1, 255 )
              foundExtraI = FNCountSatisfiedContactsI( proteinI, graphS, graphCountI, bestExtraI )
              IF directI + foundExtraI > bestI
                bestI = directI + foundExtraI
                bestExtraI = foundExtraI
              ENDIF
              IF bestExtraI == graphCountI
                lineIndexI = lineCountI + 1
              ELSE
                lineIndexI = lineIndexI + 1
              ENDIF
            ENDWHILE
            IF bestExtraI == graphCountI
              stopB = TRUE
            ENDIF
          ENDIF
          graphCountI = graphCountI - 1
        ENDIF
      ENDWHILE
      PopLocation()
      sumI = sumI + weightI * bestI
    ENDIF
  ENDFOR
  return( sumI )
END

STRING PROC FNExactAverageS( INTEGER numeratorI )
  INTEGER integerPartI = 0
  INTEGER remainderI = 0
  INTEGER digitI = 0
  STRING resultS[255] = ""
  integerPartI = numeratorI / TOTAL_PROTEINS
  remainderI   = numeratorI mod TOTAL_PROTEINS
  resultS = Format( integerPartI )
  IF remainderI > 0
    resultS = resultS + "."
    WHILE remainderI > 0
      remainderI = remainderI * 10
      digitI = remainderI / TOTAL_PROTEINS
      resultS = resultS + Format( digitI )
      remainderI = remainderI mod TOTAL_PROTEINS
    ENDWHILE
  ENDIF
  return( resultS )
END

PROC PROCMainWork()
  INTEGER sumI = 0
  STRING answerS[255] = ""
  gGraph1BufferGI = CreateTempBuffer()
  gGraph2BufferGI = CreateTempBuffer()
  gGraph3BufferGI = CreateTempBuffer()
  gGraph4BufferGI = CreateTempBuffer()
  gGraph5BufferGI = CreateTempBuffer()
  gGraph6BufferGI = CreateTempBuffer()
  gGraph7BufferGI = CreateTempBuffer()
  gGraph8BufferGI = CreateTempBuffer()
  gMax1BufferGI   = CreateTempBuffer()
  gMax2BufferGI   = CreateTempBuffer()
  gMax3BufferGI   = CreateTempBuffer()
  gMax4BufferGI   = CreateTempBuffer()
  gMax5BufferGI   = CreateTempBuffer()
  gMax6BufferGI   = CreateTempBuffer()
  gMax7BufferGI   = CreateTempBuffer()
  gMax8BufferGI   = CreateTempBuffer()
  PROCSetPoint( 1, 0, 0 )
  PROCSetPoint( 2, 1, 0 )
  PROCSearchLayouts( 3, 1, 0 )
  PROCBuildMaximalBuffers()
  sumI = FNSumBestContactsI()
  answerS = FNExactAverageS( sumI )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
  AbandonFile( gGraph1BufferGI )
  AbandonFile( gGraph2BufferGI )
  AbandonFile( gGraph3BufferGI )
  AbandonFile( gGraph4BufferGI )
  AbandonFile( gGraph5BufferGI )
  AbandonFile( gGraph6BufferGI )
  AbandonFile( gGraph7BufferGI )
  AbandonFile( gGraph8BufferGI )
  AbandonFile( gMax1BufferGI )
  AbandonFile( gMax2BufferGI )
  AbandonFile( gMax3BufferGI )
  AbandonFile( gMax4BufferGI )
  AbandonFile( gMax5BufferGI )
  AbandonFile( gMax6BufferGI )
  AbandonFile( gMax7BufferGI )
  AbandonFile( gMax8BufferGI )
END

PROC Main()
  PROCMainWork()
END
