// Project Euler 303 in pure TSE SAL
// <version>1</version>
// History:
// 2026-04-20 ChatGPT GPT-5.4 Thinking
// - Initial exact pure TSE SAL solution for Project Euler problem 303.
// - No hardcoded final answer.
// - Uses exact BFS on remainders and decimal string arithmetic.
#DEFINE MAX_N_K               10000
#DEFINE PACK_WIDTH_K          5
#DEFINE PACK_PER_LINE_K       50
#DEFINE PACK_LINE_LEN_K       250
#DEFINE TREE_BASE_LINE_K      1
#DEFINE QUEUE_BASE_LINE_K     201
#DEFINE UNVISITED_CODE_K      99999
#DEFINE ROOT_CODE_BASE_K      30000
FORWARD PROC PROCLineAssign( INTEGER targetLineI, STRING newTextS )
FORWARD PROC PROCEnsureLineCount( INTEGER requiredLinesI )
FORWARD PROC PROCResetPackedBlock( INTEGER firstLineI, INTEGER packedLineCountI, STRING fillPackedLineS )
FORWARD INTEGER PROC FNNeededPackedLinesI( INTEGER entryCountI )
FORWARD INTEGER PROC FNPackedItemI( INTEGER baseLineI, INTEGER indexI )
FORWARD PROC PROCPackedItemAssign( INTEGER baseLineI, INTEGER indexI, INTEGER valueI )
FORWARD STRING PROC FNRepeatedPackedLineS( STRING packedEntryS )
FORWARD STRING PROC FNAddBigDecimalsS( STRING addendOneS, STRING addendTwoS )
FORWARD STRING PROC FNExactQuotientS( STRING numberS, INTEGER divisorI )
FORWARD STRING PROC FNLeastSmallDigitMultipleS( INTEGER nI )
INTEGER workBufferGI = 0
STRING gUnvisitedPackedLineGS[255] = ""
STRING gZeroPackedLineGS[255] = ""
PROC PROCLineAssign( INTEGER targetLineI, STRING newTextS )
  GotoLine( targetLineI )
  BegLine()
  KillToEol()
  InsertText( newTextS )
END
PROC PROCEnsureLineCount( INTEGER requiredLinesI )
  WHILE NumLines() < requiredLinesI
    EndFile()
    AddLine( "" )
  ENDWHILE
END
PROC PROCResetPackedBlock( INTEGER firstLineI, INTEGER packedLineCountI, STRING fillPackedLineS )
  INTEGER lineI = 0
  FOR lineI = firstLineI TO firstLineI + packedLineCountI - 1
    PROCLineAssign( lineI, fillPackedLineS )
  ENDFOR
END
INTEGER PROC FNNeededPackedLinesI( INTEGER entryCountI )
  RETURN( ( entryCountI + PACK_PER_LINE_K - 1 ) / PACK_PER_LINE_K )
END
INTEGER PROC FNPackedItemI( INTEGER baseLineI, INTEGER indexI )
  INTEGER targetLineI = 0
  INTEGER offsetI = 0
  STRING packedLineS[255] = ""
  STRING packedValueS[5] = ""
  targetLineI = baseLineI + ( indexI / PACK_PER_LINE_K )
  offsetI     = ( ( indexI mod PACK_PER_LINE_K ) * PACK_WIDTH_K ) + 1
  GotoLine( targetLineI )
  packedLineS  = GetText( 1, PACK_LINE_LEN_K )
  packedValueS = SubStr( packedLineS, offsetI, PACK_WIDTH_K )
  RETURN( Val( packedValueS ) )
END
PROC PROCPackedItemAssign( INTEGER baseLineI, INTEGER indexI, INTEGER valueI )
  INTEGER targetLineI = 0
  INTEGER offsetI = 0
  STRING packedLineS[255] = ""
  STRING prefixS[255] = ""
  STRING suffixS[255] = ""
  STRING replacementS[5] = ""
  targetLineI   = baseLineI + ( indexI / PACK_PER_LINE_K )
  offsetI       = ( ( indexI mod PACK_PER_LINE_K ) * PACK_WIDTH_K ) + 1
  replacementS  = Format( valueI : PACK_WIDTH_K : "0" )
  GotoLine( targetLineI )
  packedLineS = GetText( 1, PACK_LINE_LEN_K )
  IF offsetI > 1
    prefixS = SubStr( packedLineS, 1, offsetI - 1 )
  ELSE
    prefixS = ""
  ENDIF
  IF ( offsetI + PACK_WIDTH_K ) <= PACK_LINE_LEN_K
    suffixS = SubStr( packedLineS, offsetI + PACK_WIDTH_K, PACK_LINE_LEN_K - offsetI - PACK_WIDTH_K + 1 )
  ELSE
    suffixS = ""
  ENDIF
  packedLineS = prefixS + replacementS + suffixS
  PROCLineAssign( targetLineI, packedLineS )
END
STRING PROC FNRepeatedPackedLineS( STRING packedEntryS )
  INTEGER I = 0
  STRING repeatedS[255] = ""
  FOR I = 1 TO PACK_PER_LINE_K
    repeatedS = repeatedS + packedEntryS
  ENDFOR
  RETURN( repeatedS )
END
STRING PROC FNAddBigDecimalsS( STRING addendOneS, STRING addendTwoS )
  INTEGER addendOnePosI = 0
  INTEGER addendTwoPosI = 0
  INTEGER carryI = 0
  INTEGER digitSumI = 0
  STRING answerS[255] = ""
  addendOnePosI = Length( addendOneS )
  addendTwoPosI = Length( addendTwoS )
  WHILE ( addendOnePosI > 0 ) OR ( addendTwoPosI > 0 ) OR ( carryI > 0 )
    digitSumI = carryI
    IF addendOnePosI > 0
      digitSumI = digitSumI + Val( SubStr( addendOneS, addendOnePosI, 1 ) )
      addendOnePosI = addendOnePosI - 1
    ENDIF
    IF addendTwoPosI > 0
      digitSumI = digitSumI + Val( SubStr( addendTwoS, addendTwoPosI, 1 ) )
      addendTwoPosI = addendTwoPosI - 1
    ENDIF
    answerS = Chr( 48 + ( digitSumI mod 10 ) ) + answerS
    carryI  = digitSumI / 10
  ENDWHILE
  RETURN( answerS )
END
STRING PROC FNExactQuotientS( STRING numberS, INTEGER divisorI )
  INTEGER indexI = 0
  INTEGER carryI = 0
  INTEGER quotientDigitI = 0
  INTEGER startedB = FALSE
  STRING quotientS[255] = ""
  FOR indexI = 1 TO Length( numberS )
    carryI         = ( carryI * 10 ) + Val( SubStr( numberS, indexI, 1 ) )
    quotientDigitI = carryI / divisorI
    carryI         = carryI mod divisorI
    IF ( quotientDigitI > 0 ) OR ( startedB == TRUE )
      quotientS = quotientS + Chr( 48 + quotientDigitI )
      startedB  = TRUE
    ENDIF
  ENDFOR
  IF quotientS == ""
    quotientS = "0"
  ENDIF
  RETURN( quotientS )
END
STRING PROC FNLeastSmallDigitMultipleS( INTEGER nI )
  INTEGER packedLineCountI = 0
  INTEGER headI = 0
  INTEGER tailI = 0
  INTEGER digitI = 0
  INTEGER remainderI = 0
  INTEGER newRemainderI = 0
  INTEGER codeI = 0
  INTEGER doneB = FALSE
  STRING numberS[255] = ""
  packedLineCountI = FNNeededPackedLinesI( nI )
  PROCResetPackedBlock( TREE_BASE_LINE_K,  packedLineCountI, gUnvisitedPackedLineGS )
  PROCResetPackedBlock( QUEUE_BASE_LINE_K, packedLineCountI, gZeroPackedLineGS )
  headI = 0
  tailI = 0
  FOR digitI = 1 TO 2
    remainderI = digitI mod nI
    IF FNPackedItemI( TREE_BASE_LINE_K, remainderI ) == UNVISITED_CODE_K
      PROCPackedItemAssign( TREE_BASE_LINE_K, remainderI, ROOT_CODE_BASE_K + digitI )
      PROCPackedItemAssign( QUEUE_BASE_LINE_K, tailI, remainderI )
      tailI = tailI + 1
    ENDIF
  ENDFOR
  WHILE ( headI < tailI ) AND ( FNPackedItemI( TREE_BASE_LINE_K, 0 ) == UNVISITED_CODE_K )
    remainderI = FNPackedItemI( QUEUE_BASE_LINE_K, headI )
    headI = headI + 1
    FOR digitI = 0 TO 2
      newRemainderI = ( ( remainderI * 10 ) + digitI ) mod nI
      IF FNPackedItemI( TREE_BASE_LINE_K, newRemainderI ) == UNVISITED_CODE_K
        PROCPackedItemAssign( TREE_BASE_LINE_K, newRemainderI, ( remainderI * 3 ) + digitI )
        PROCPackedItemAssign( QUEUE_BASE_LINE_K, tailI, newRemainderI )
        tailI = tailI + 1
      ENDIF
    ENDFOR
  ENDWHILE
  numberS    = ""
  remainderI = 0
  doneB      = FALSE
  WHILE doneB == FALSE
    codeI = FNPackedItemI( TREE_BASE_LINE_K, remainderI )
    IF codeI >= ROOT_CODE_BASE_K
      digitI    = codeI - ROOT_CODE_BASE_K
      numberS   = Chr( 48 + digitI ) + numberS
      doneB     = TRUE
    ELSE
      digitI    = codeI mod 3
      numberS   = Chr( 48 + digitI ) + numberS
      remainderI = codeI / 3
    ENDIF
  ENDWHILE
  RETURN( numberS )
END
PROC Main()
  INTEGER totalWorkLinesI = 0
  INTEGER nI = 0
  STRING minimumMultipleS[255] = ""
  STRING quotientS[255] = ""
  STRING answerS[255] = ""
  workBufferGI = CreateTempBuffer()
  gUnvisitedPackedLineGS = FNRepeatedPackedLineS( Format( UNVISITED_CODE_K : PACK_WIDTH_K : "0" ) )
  gZeroPackedLineGS      = FNRepeatedPackedLineS( Format( 0 : PACK_WIDTH_K : "0" ) )
  GotoBufferId( workBufferGI )
  totalWorkLinesI = QUEUE_BASE_LINE_K + FNNeededPackedLinesI( MAX_N_K ) - 1
  PROCEnsureLineCount( totalWorkLinesI )
  answerS = "0"
  FOR nI = 1 TO MAX_N_K
    minimumMultipleS = FNLeastSmallDigitMultipleS( nI )
    quotientS        = FNExactQuotientS( minimumMultipleS, nI )
    answerS          = FNAddBigDecimalsS( answerS, quotientS )
  ENDFOR
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
  AbandonFile( workBufferGI )
END
