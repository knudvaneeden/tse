// eulerproject0185ChatGPT.s
// <version>1.0.0.0.4</version>
// Created by ChatGPT GPT-5.4 Thinking
// Project Euler 185 - Number Mind
// Pure TSE SAL solver using constraint propagation +
// iterative backtracking with clue-combination branching

STRING gDomain01S[255] = ""
STRING gDomain02S[255] = ""
STRING gDomain03S[255] = ""
STRING gDomain04S[255] = ""
STRING gDomain05S[255] = ""
STRING gDomain06S[255] = ""
STRING gDomain07S[255] = ""
STRING gDomain08S[255] = ""
STRING gDomain09S[255] = ""
STRING gDomain10S[255] = ""
STRING gDomain11S[255] = ""
STRING gDomain12S[255] = ""
STRING gDomain13S[255] = ""
STRING gDomain14S[255] = ""
STRING gDomain15S[255] = ""
STRING gDomain16S[255] = ""

STRING gDigitsS[255] = "0123456789"
STRING gResultS[255] = ""

STRING gState01S[255] = ""
STRING gState02S[255] = ""
STRING gState03S[255] = ""
STRING gState04S[255] = ""
STRING gState05S[255] = ""
STRING gState06S[255] = ""
STRING gState07S[255] = ""
STRING gState08S[255] = ""
STRING gState09S[255] = ""
STRING gState10S[255] = ""
STRING gState11S[255] = ""
STRING gState12S[255] = ""
STRING gState13S[255] = ""
STRING gState14S[255] = ""
STRING gState15S[255] = ""
STRING gState16S[255] = ""
STRING gState17S[255] = ""
STRING gState18S[255] = ""
STRING gState19S[255] = ""
STRING gState20S[255] = ""

INTEGER gMode01I = 0
INTEGER gMode02I = 0
INTEGER gMode03I = 0
INTEGER gMode04I = 0
INTEGER gMode05I = 0
INTEGER gMode06I = 0
INTEGER gMode07I = 0
INTEGER gMode08I = 0
INTEGER gMode09I = 0
INTEGER gMode10I = 0
INTEGER gMode11I = 0
INTEGER gMode12I = 0
INTEGER gMode13I = 0
INTEGER gMode14I = 0
INTEGER gMode15I = 0
INTEGER gMode16I = 0
INTEGER gMode17I = 0
INTEGER gMode18I = 0
INTEGER gMode19I = 0
INTEGER gMode20I = 0

INTEGER gItem01I = 0
INTEGER gItem02I = 0
INTEGER gItem03I = 0
INTEGER gItem04I = 0
INTEGER gItem05I = 0
INTEGER gItem06I = 0
INTEGER gItem07I = 0
INTEGER gItem08I = 0
INTEGER gItem09I = 0
INTEGER gItem10I = 0
INTEGER gItem11I = 0
INTEGER gItem12I = 0
INTEGER gItem13I = 0
INTEGER gItem14I = 0
INTEGER gItem15I = 0
INTEGER gItem16I = 0
INTEGER gItem17I = 0
INTEGER gItem18I = 0
INTEGER gItem19I = 0
INTEGER gItem20I = 0

INTEGER gNext01I = 0
INTEGER gNext02I = 0
INTEGER gNext03I = 0
INTEGER gNext04I = 0
INTEGER gNext05I = 0
INTEGER gNext06I = 0
INTEGER gNext07I = 0
INTEGER gNext08I = 0
INTEGER gNext09I = 0
INTEGER gNext10I = 0
INTEGER gNext11I = 0
INTEGER gNext12I = 0
INTEGER gNext13I = 0
INTEGER gNext14I = 0
INTEGER gNext15I = 0
INTEGER gNext16I = 0
INTEGER gNext17I = 0
INTEGER gNext18I = 0
INTEGER gNext19I = 0
INTEGER gNext20I = 0

INTEGER gWorkMatchedI = 0
INTEGER gWorkPossibleI = 0
INTEGER gWorkRemainingI = 0
STRING  gWorkPosListS[255] = ""

// -----------------------------------------------------------------------------

STRING PROC ProcCharAt( STRING sourceS, INTEGER indexI )
 STRING resultS[255] = ""
 resultS = SubStr( sourceS, indexI, 1 )
 RETURN( resultS )
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcStringContainsChar( STRING sourceS, STRING searchS )
 INTEGER indexI = 0
 FOR indexI = 1 TO Length( sourceS )
  IF ProcCharAt( sourceS, indexI ) == searchS
   RETURN( TRUE )
  ENDIF
 ENDFOR
 RETURN( FALSE )
END

// -----------------------------------------------------------------------------

STRING PROC ProcRemoveChar( STRING sourceS, STRING removeS )
 STRING resultS[255] = ""
 STRING currentS[255] = ""
 INTEGER indexI = 0

 FOR indexI = 1 TO Length( sourceS )
  currentS = ProcCharAt( sourceS, indexI )
  IF currentS == removeS
   //
  ELSE
   resultS = resultS + currentS
  ENDIF
 ENDFOR

 RETURN( resultS )
END

// -----------------------------------------------------------------------------

STRING PROC ProcTwoDigitString( INTEGER numberI )
 STRING numberS[255] = ""
 IF numberI < 10
  numberS = "0" + Str( numberI )
 ELSE
  numberS = Str( numberI )
 ENDIF
 RETURN( numberS )
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcGetListItemCount( STRING listS )
 RETURN( Length( listS ) / 2 )
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcGetListItemByIndex( STRING listS, INTEGER itemIndexI )
 STRING itemS[255] = ""
 itemS = SubStr( listS, ( itemIndexI - 1 ) * 2 + 1, 2 )
 RETURN( Val( itemS ) )
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcBitCount( INTEGER maskI )
 INTEGER countI = 0
 INTEGER workI = 0

 workI = maskI
 WHILE workI > 0
  IF ( workI & 1 ) == 1
   countI = countI + 1
  ENDIF
  workI = workI shr 1
 ENDWHILE

 RETURN( countI )
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcCombinationCount( INTEGER totalI, INTEGER chooseI )
 INTEGER resultI = 1
 INTEGER stepI = 0
 INTEGER smallChooseI = 0

 IF chooseI < 0
  RETURN( 0 )
 ENDIF

 IF chooseI > totalI
  RETURN( 0 )
 ENDIF

 IF chooseI == 0
  RETURN( 1 )
 ENDIF

 IF chooseI == totalI
  RETURN( 1 )
 ENDIF

 smallChooseI = chooseI
 IF chooseI > totalI - chooseI
  smallChooseI = totalI - chooseI
 ENDIF

 resultI = 1
 FOR stepI = 1 TO smallChooseI
  resultI = ( resultI * ( totalI - smallChooseI + stepI ) ) / stepI
 ENDFOR

 RETURN( resultI )
END

// -----------------------------------------------------------------------------

STRING PROC ProcGetGuessByIndex( INTEGER guessIndexI )
 STRING guessS[255] = ""

 CASE guessIndexI
  WHEN 1
   guessS = "5616185650518293"
  WHEN 2
   guessS = "3847439647293047"
  WHEN 3
   guessS = "5855462940810587"
  WHEN 4
   guessS = "9742855507068353"
  WHEN 5
   guessS = "4296849643607543"
  WHEN 6
   guessS = "3174248439465858"
  WHEN 7
   guessS = "4513559094146117"
  WHEN 8
   guessS = "7890971548908067"
  WHEN 9
   guessS = "8157356344118483"
  WHEN 10
   guessS = "2615250744386899"
  WHEN 11
   guessS = "8690095851526254"
  WHEN 12
   guessS = "6375711915077050"
  WHEN 13
   guessS = "6913859173121360"
  WHEN 14
   guessS = "6442889055042768"
  WHEN 15
   guessS = "2321386104303845"
  WHEN 16
   guessS = "2326509471271448"
  WHEN 17
   guessS = "5251583379644322"
  WHEN 18
   guessS = "1748270476758276"
  WHEN 19
   guessS = "4895722652190306"
  WHEN 20
   guessS = "3041631117224635"
  WHEN 21
   guessS = "1841236454324589"
  WHEN 22
   guessS = "2659862637316867"
  OTHERWISE
   guessS = ""
 ENDCASE

 RETURN( guessS )
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcGetRequiredByIndex( INTEGER guessIndexI )
 INTEGER requiredI = 0

 CASE guessIndexI
  WHEN 1
   requiredI = 2
  WHEN 2
   requiredI = 1
  WHEN 3
   requiredI = 3
  WHEN 4
   requiredI = 3
  WHEN 5
   requiredI = 3
  WHEN 6
   requiredI = 1
  WHEN 7
   requiredI = 2
  WHEN 8
   requiredI = 3
  WHEN 9
   requiredI = 1
  WHEN 10
   requiredI = 2
  WHEN 11
   requiredI = 3
  WHEN 12
   requiredI = 1
  WHEN 13
   requiredI = 1
  WHEN 14
   requiredI = 2
  WHEN 15
   requiredI = 0
  WHEN 16
   requiredI = 2
  WHEN 17
   requiredI = 2
  WHEN 18
   requiredI = 3
  WHEN 19
   requiredI = 1
  WHEN 20
   requiredI = 3
  WHEN 21
   requiredI = 3
  WHEN 22
   requiredI = 2
  OTHERWISE
   requiredI = 0
 ENDCASE

 RETURN( requiredI )
END

// -----------------------------------------------------------------------------

STRING PROC ProcGetDomainByIndex( INTEGER indexI )
 STRING domainS[255] = ""

 CASE indexI
  WHEN 1
   domainS = gDomain01S
  WHEN 2
   domainS = gDomain02S
  WHEN 3
   domainS = gDomain03S
  WHEN 4
   domainS = gDomain04S
  WHEN 5
   domainS = gDomain05S
  WHEN 6
   domainS = gDomain06S
  WHEN 7
   domainS = gDomain07S
  WHEN 8
   domainS = gDomain08S
  WHEN 9
   domainS = gDomain09S
  WHEN 10
   domainS = gDomain10S
  WHEN 11
   domainS = gDomain11S
  WHEN 12
   domainS = gDomain12S
  WHEN 13
   domainS = gDomain13S
  WHEN 14
   domainS = gDomain14S
  WHEN 15
   domainS = gDomain15S
  WHEN 16
   domainS = gDomain16S
  OTHERWISE
   domainS = ""
 ENDCASE

 RETURN( domainS )
END

// -----------------------------------------------------------------------------

PROC ProcSetDomainByIndex( INTEGER indexI, STRING domainS )
 CASE indexI
  WHEN 1
   gDomain01S = domainS
  WHEN 2
   gDomain02S = domainS
  WHEN 3
   gDomain03S = domainS
  WHEN 4
   gDomain04S = domainS
  WHEN 5
   gDomain05S = domainS
  WHEN 6
   gDomain06S = domainS
  WHEN 7
   gDomain07S = domainS
  WHEN 8
   gDomain08S = domainS
  WHEN 9
   gDomain09S = domainS
  WHEN 10
   gDomain10S = domainS
  WHEN 11
   gDomain11S = domainS
  WHEN 12
   gDomain12S = domainS
  WHEN 13
   gDomain13S = domainS
  WHEN 14
   gDomain14S = domainS
  WHEN 15
   gDomain15S = domainS
  WHEN 16
   gDomain16S = domainS
  OTHERWISE
   //
 ENDCASE
END

// -----------------------------------------------------------------------------

PROC ProcInitializeDomains()
 gDomain01S = gDigitsS
 gDomain02S = gDigitsS
 gDomain03S = gDigitsS
 gDomain04S = gDigitsS
 gDomain05S = gDigitsS
 gDomain06S = gDigitsS
 gDomain07S = gDigitsS
 gDomain08S = gDigitsS
 gDomain09S = gDigitsS
 gDomain10S = gDigitsS
 gDomain11S = gDigitsS
 gDomain12S = gDigitsS
 gDomain13S = gDigitsS
 gDomain14S = gDigitsS
 gDomain15S = gDigitsS
 gDomain16S = gDigitsS
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcAllSingletons()
 INTEGER indexI = 0

 FOR indexI = 1 TO 16
  IF Length( ProcGetDomainByIndex( indexI ) ) == 1
   //
  ELSE
   RETURN( FALSE )
  ENDIF
 ENDFOR

 RETURN( TRUE )
END

// -----------------------------------------------------------------------------

STRING PROC ProcBuildResult()
 STRING resultS[255] = ""
 INTEGER indexI = 0

 FOR indexI = 1 TO 16
  resultS = resultS + ProcCharAt( ProcGetDomainByIndex( indexI ), 1 )
 ENDFOR

 RETURN( resultS )
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcChooseBestIndex()
 INTEGER bestIndexI = 0
 INTEGER bestLengthI = 999
 INTEGER currentLengthI = 0
 INTEGER indexI = 0

 FOR indexI = 1 TO 16
  currentLengthI = Length( ProcGetDomainByIndex( indexI ) )
  IF currentLengthI > 1
   IF currentLengthI < bestLengthI
    bestLengthI = currentLengthI
    bestIndexI = indexI
   ENDIF
  ENDIF
 ENDFOR

 RETURN( bestIndexI )
END

// -----------------------------------------------------------------------------

STRING PROC ProcBuildSnapshot()
 STRING snapshotS[255] = ""

 snapshotS = gDomain01S + "|" + gDomain02S + "|" + gDomain03S + "|" + gDomain04S
 snapshotS = snapshotS + "|" + gDomain05S + "|" + gDomain06S + "|" + gDomain07S + "|" + gDomain08S
 snapshotS = snapshotS + "|" + gDomain09S + "|" + gDomain10S + "|" + gDomain11S + "|" + gDomain12S
 snapshotS = snapshotS + "|" + gDomain13S + "|" + gDomain14S + "|" + gDomain15S + "|" + gDomain16S

 RETURN( snapshotS )
END

// -----------------------------------------------------------------------------

STRING PROC ProcGetFieldFromSnapshot( STRING snapshotS, INTEGER wantedFieldI )
 STRING resultS[255] = ""
 STRING currentS[255] = ""
 INTEGER fieldI = 1
 INTEGER indexI = 0

 FOR indexI = 1 TO Length( snapshotS )
  currentS = ProcCharAt( snapshotS, indexI )
  IF currentS == "|"
   fieldI = fieldI + 1
  ELSE
   IF fieldI == wantedFieldI
    resultS = resultS + currentS
   ENDIF
  ENDIF
 ENDFOR

 RETURN( resultS )
END

// -----------------------------------------------------------------------------

PROC ProcSetStateByLevel( INTEGER levelI, STRING snapshotS )
 CASE levelI
  WHEN 1
   gState01S = snapshotS
  WHEN 2
   gState02S = snapshotS
  WHEN 3
   gState03S = snapshotS
  WHEN 4
   gState04S = snapshotS
  WHEN 5
   gState05S = snapshotS
  WHEN 6
   gState06S = snapshotS
  WHEN 7
   gState07S = snapshotS
  WHEN 8
   gState08S = snapshotS
  WHEN 9
   gState09S = snapshotS
  WHEN 10
   gState10S = snapshotS
  WHEN 11
   gState11S = snapshotS
  WHEN 12
   gState12S = snapshotS
  WHEN 13
   gState13S = snapshotS
  WHEN 14
   gState14S = snapshotS
  WHEN 15
   gState15S = snapshotS
  WHEN 16
   gState16S = snapshotS
  WHEN 17
   gState17S = snapshotS
  WHEN 18
   gState18S = snapshotS
  WHEN 19
   gState19S = snapshotS
  WHEN 20
   gState20S = snapshotS
  OTHERWISE
   //
 ENDCASE
END

// -----------------------------------------------------------------------------

STRING PROC ProcGetStateByLevel( INTEGER levelI )
 STRING snapshotS[255] = ""

 CASE levelI
  WHEN 1
   snapshotS = gState01S
  WHEN 2
   snapshotS = gState02S
  WHEN 3
   snapshotS = gState03S
  WHEN 4
   snapshotS = gState04S
  WHEN 5
   snapshotS = gState05S
  WHEN 6
   snapshotS = gState06S
  WHEN 7
   snapshotS = gState07S
  WHEN 8
   snapshotS = gState08S
  WHEN 9
   snapshotS = gState09S
  WHEN 10
   snapshotS = gState10S
  WHEN 11
   snapshotS = gState11S
  WHEN 12
   snapshotS = gState12S
  WHEN 13
   snapshotS = gState13S
  WHEN 14
   snapshotS = gState14S
  WHEN 15
   snapshotS = gState15S
  WHEN 16
   snapshotS = gState16S
  WHEN 17
   snapshotS = gState17S
  WHEN 18
   snapshotS = gState18S
  WHEN 19
   snapshotS = gState19S
  WHEN 20
   snapshotS = gState20S
  OTHERWISE
   snapshotS = ""
 ENDCASE

 RETURN( snapshotS )
END

// -----------------------------------------------------------------------------

PROC ProcSaveDomainsForLevel( INTEGER levelI )
 ProcSetStateByLevel( levelI, ProcBuildSnapshot() )
END

// -----------------------------------------------------------------------------

PROC ProcRestoreDomainsForLevel( INTEGER levelI )
 STRING snapshotS[255] = ""

 snapshotS = ProcGetStateByLevel( levelI )

 gDomain01S = ProcGetFieldFromSnapshot( snapshotS, 1 )
 gDomain02S = ProcGetFieldFromSnapshot( snapshotS, 2 )
 gDomain03S = ProcGetFieldFromSnapshot( snapshotS, 3 )
 gDomain04S = ProcGetFieldFromSnapshot( snapshotS, 4 )
 gDomain05S = ProcGetFieldFromSnapshot( snapshotS, 5 )
 gDomain06S = ProcGetFieldFromSnapshot( snapshotS, 6 )
 gDomain07S = ProcGetFieldFromSnapshot( snapshotS, 7 )
 gDomain08S = ProcGetFieldFromSnapshot( snapshotS, 8 )
 gDomain09S = ProcGetFieldFromSnapshot( snapshotS, 9 )
 gDomain10S = ProcGetFieldFromSnapshot( snapshotS, 10 )
 gDomain11S = ProcGetFieldFromSnapshot( snapshotS, 11 )
 gDomain12S = ProcGetFieldFromSnapshot( snapshotS, 12 )
 gDomain13S = ProcGetFieldFromSnapshot( snapshotS, 13 )
 gDomain14S = ProcGetFieldFromSnapshot( snapshotS, 14 )
 gDomain15S = ProcGetFieldFromSnapshot( snapshotS, 15 )
 gDomain16S = ProcGetFieldFromSnapshot( snapshotS, 16 )
END

// -----------------------------------------------------------------------------

PROC ProcSetModeByLevel( INTEGER levelI, INTEGER modeI )
 CASE levelI
  WHEN 1
   gMode01I = modeI
  WHEN 2
   gMode02I = modeI
  WHEN 3
   gMode03I = modeI
  WHEN 4
   gMode04I = modeI
  WHEN 5
   gMode05I = modeI
  WHEN 6
   gMode06I = modeI
  WHEN 7
   gMode07I = modeI
  WHEN 8
   gMode08I = modeI
  WHEN 9
   gMode09I = modeI
  WHEN 10
   gMode10I = modeI
  WHEN 11
   gMode11I = modeI
  WHEN 12
   gMode12I = modeI
  WHEN 13
   gMode13I = modeI
  WHEN 14
   gMode14I = modeI
  WHEN 15
   gMode15I = modeI
  WHEN 16
   gMode16I = modeI
  WHEN 17
   gMode17I = modeI
  WHEN 18
   gMode18I = modeI
  WHEN 19
   gMode19I = modeI
  WHEN 20
   gMode20I = modeI
  OTHERWISE
   //
 ENDCASE
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcGetModeByLevel( INTEGER levelI )
 INTEGER modeI = 0

 CASE levelI
  WHEN 1
   modeI = gMode01I
  WHEN 2
   modeI = gMode02I
  WHEN 3
   modeI = gMode03I
  WHEN 4
   modeI = gMode04I
  WHEN 5
   modeI = gMode05I
  WHEN 6
   modeI = gMode06I
  WHEN 7
   modeI = gMode07I
  WHEN 8
   modeI = gMode08I
  WHEN 9
   modeI = gMode09I
  WHEN 10
   modeI = gMode10I
  WHEN 11
   modeI = gMode11I
  WHEN 12
   modeI = gMode12I
  WHEN 13
   modeI = gMode13I
  WHEN 14
   modeI = gMode14I
  WHEN 15
   modeI = gMode15I
  WHEN 16
   modeI = gMode16I
  WHEN 17
   modeI = gMode17I
  WHEN 18
   modeI = gMode18I
  WHEN 19
   modeI = gMode19I
  WHEN 20
   modeI = gMode20I
  OTHERWISE
   modeI = 0
 ENDCASE

 RETURN( modeI )
END

// -----------------------------------------------------------------------------

PROC ProcSetItemByLevel( INTEGER levelI, INTEGER itemI )
 CASE levelI
  WHEN 1
   gItem01I = itemI
  WHEN 2
   gItem02I = itemI
  WHEN 3
   gItem03I = itemI
  WHEN 4
   gItem04I = itemI
  WHEN 5
   gItem05I = itemI
  WHEN 6
   gItem06I = itemI
  WHEN 7
   gItem07I = itemI
  WHEN 8
   gItem08I = itemI
  WHEN 9
   gItem09I = itemI
  WHEN 10
   gItem10I = itemI
  WHEN 11
   gItem11I = itemI
  WHEN 12
   gItem12I = itemI
  WHEN 13
   gItem13I = itemI
  WHEN 14
   gItem14I = itemI
  WHEN 15
   gItem15I = itemI
  WHEN 16
   gItem16I = itemI
  WHEN 17
   gItem17I = itemI
  WHEN 18
   gItem18I = itemI
  WHEN 19
   gItem19I = itemI
  WHEN 20
   gItem20I = itemI
  OTHERWISE
   //
 ENDCASE
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcGetItemByLevel( INTEGER levelI )
 INTEGER itemI = 0

 CASE levelI
  WHEN 1
   itemI = gItem01I
  WHEN 2
   itemI = gItem02I
  WHEN 3
   itemI = gItem03I
  WHEN 4
   itemI = gItem04I
  WHEN 5
   itemI = gItem05I
  WHEN 6
   itemI = gItem06I
  WHEN 7
   itemI = gItem07I
  WHEN 8
   itemI = gItem08I
  WHEN 9
   itemI = gItem09I
  WHEN 10
   itemI = gItem10I
  WHEN 11
   itemI = gItem11I
  WHEN 12
   itemI = gItem12I
  WHEN 13
   itemI = gItem13I
  WHEN 14
   itemI = gItem14I
  WHEN 15
   itemI = gItem15I
  WHEN 16
   itemI = gItem16I
  WHEN 17
   itemI = gItem17I
  WHEN 18
   itemI = gItem18I
  WHEN 19
   itemI = gItem19I
  WHEN 20
   itemI = gItem20I
  OTHERWISE
   itemI = 0
 ENDCASE

 RETURN( itemI )
END

// -----------------------------------------------------------------------------

PROC ProcSetNextByLevel( INTEGER levelI, INTEGER nextI )
 CASE levelI
  WHEN 1
   gNext01I = nextI
  WHEN 2
   gNext02I = nextI
  WHEN 3
   gNext03I = nextI
  WHEN 4
   gNext04I = nextI
  WHEN 5
   gNext05I = nextI
  WHEN 6
   gNext06I = nextI
  WHEN 7
   gNext07I = nextI
  WHEN 8
   gNext08I = nextI
  WHEN 9
   gNext09I = nextI
  WHEN 10
   gNext10I = nextI
  WHEN 11
   gNext11I = nextI
  WHEN 12
   gNext12I = nextI
  WHEN 13
   gNext13I = nextI
  WHEN 14
   gNext14I = nextI
  WHEN 15
   gNext15I = nextI
  WHEN 16
   gNext16I = nextI
  WHEN 17
   gNext17I = nextI
  WHEN 18
   gNext18I = nextI
  WHEN 19
   gNext19I = nextI
  WHEN 20
   gNext20I = nextI
  OTHERWISE
   //
 ENDCASE
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcGetNextByLevel( INTEGER levelI )
 INTEGER nextI = 0

 CASE levelI
  WHEN 1
   nextI = gNext01I
  WHEN 2
   nextI = gNext02I
  WHEN 3
   nextI = gNext03I
  WHEN 4
   nextI = gNext04I
  WHEN 5
   nextI = gNext05I
  WHEN 6
   nextI = gNext06I
  WHEN 7
   nextI = gNext07I
  WHEN 8
   nextI = gNext08I
  WHEN 9
   nextI = gNext09I
  WHEN 10
   nextI = gNext10I
  WHEN 11
   nextI = gNext11I
  WHEN 12
   nextI = gNext12I
  WHEN 13
   nextI = gNext13I
  WHEN 14
   nextI = gNext14I
  WHEN 15
   nextI = gNext15I
  WHEN 16
   nextI = gNext16I
  WHEN 17
   nextI = gNext17I
  WHEN 18
   nextI = gNext18I
  WHEN 19
   nextI = gNext19I
  WHEN 20
   nextI = gNext20I
  OTHERWISE
   nextI = 0
 ENDCASE

 RETURN( nextI )
END

// -----------------------------------------------------------------------------

PROC ProcAnalyzeClue( INTEGER clueIndexI )
 INTEGER requiredI = 0
 INTEGER fieldIndexI = 0
 STRING guessS[255] = ""
 STRING clueDigitS[255] = ""
 STRING domainS[255] = ""

 gWorkMatchedI = 0
 gWorkPossibleI = 0
 gWorkRemainingI = 0
 gWorkPosListS = ""

 guessS = ProcGetGuessByIndex( clueIndexI )
 requiredI = ProcGetRequiredByIndex( clueIndexI )

 FOR fieldIndexI = 1 TO 16
  clueDigitS = ProcCharAt( guessS, fieldIndexI )
  domainS = ProcGetDomainByIndex( fieldIndexI )

  IF Length( domainS ) == 1
   IF domainS == clueDigitS
    gWorkMatchedI = gWorkMatchedI + 1
   ENDIF
  ELSE
   IF ProcStringContainsChar( domainS, clueDigitS )
    gWorkPossibleI = gWorkPossibleI + 1
    gWorkPosListS = gWorkPosListS + ProcTwoDigitString( fieldIndexI )
   ENDIF
  ENDIF
 ENDFOR

 gWorkRemainingI = requiredI - gWorkMatchedI
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcChooseBestClueBranch()
 INTEGER bestClueI = 0
 INTEGER bestCombosI = 999999
 INTEGER clueIndexI = 0
 INTEGER combosI = 0

 FOR clueIndexI = 1 TO 22
  ProcAnalyzeClue( clueIndexI )

  IF gWorkRemainingI < 0
   //
  ELSE
   IF gWorkRemainingI == 0
    //
   ELSE
    IF gWorkPossibleI > gWorkRemainingI
     combosI = ProcCombinationCount( gWorkPossibleI, gWorkRemainingI )
     IF combosI > 1
      IF combosI < bestCombosI
       bestCombosI = combosI
       bestClueI = clueIndexI
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDFOR

 RETURN( bestClueI )
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcApplyClueMask( INTEGER clueIndexI, INTEGER maskI )
 INTEGER itemIndexI = 0
 INTEGER fieldIndexI = 0
 INTEGER bitI = 0
 INTEGER totalPossibleI = 0
 STRING guessS[255] = ""
 STRING clueDigitS[255] = ""
 STRING domainS[255] = ""
 STRING newDomainS[255] = ""

 ProcAnalyzeClue( clueIndexI )

 totalPossibleI = gWorkPossibleI
 IF ProcBitCount( maskI ) == gWorkRemainingI
  //
 ELSE
  RETURN( FALSE )
 ENDIF

 guessS = ProcGetGuessByIndex( clueIndexI )

 FOR itemIndexI = 1 TO totalPossibleI
  fieldIndexI = ProcGetListItemByIndex( gWorkPosListS, itemIndexI )
  clueDigitS = ProcCharAt( guessS, fieldIndexI )
  bitI = 1 shl ( itemIndexI - 1 )
  domainS = ProcGetDomainByIndex( fieldIndexI )

  IF ( maskI & bitI ) == bitI
   ProcSetDomainByIndex( fieldIndexI, clueDigitS )
  ELSE
   newDomainS = ProcRemoveChar( domainS, clueDigitS )
   IF newDomainS == ""
    RETURN( FALSE )
   ENDIF
   ProcSetDomainByIndex( fieldIndexI, newDomainS )
  ENDIF
 ENDFOR

 RETURN( TRUE )
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcPropagate()
 INTEGER changedB = FALSE
 INTEGER stableB = FALSE
 INTEGER clueIndexI = 0
 INTEGER requiredI = 0
 INTEGER matchedI = 0
 INTEGER possibleI = 0
 INTEGER fieldIndexI = 0
 STRING guessS[255] = ""
 STRING clueDigitS[255] = ""
 STRING domainS[255] = ""
 STRING newDomainS[255] = ""

 stableB = FALSE

 WHILE stableB == FALSE
  changedB = FALSE

  FOR clueIndexI = 1 TO 22
   guessS = ProcGetGuessByIndex( clueIndexI )
   requiredI = ProcGetRequiredByIndex( clueIndexI )
   matchedI = 0
   possibleI = 0

   FOR fieldIndexI = 1 TO 16
    clueDigitS = ProcCharAt( guessS, fieldIndexI )
    domainS = ProcGetDomainByIndex( fieldIndexI )

    IF Length( domainS ) == 1
     IF domainS == clueDigitS
      matchedI = matchedI + 1
     ENDIF
    ELSE
     IF ProcStringContainsChar( domainS, clueDigitS )
      possibleI = possibleI + 1
     ENDIF
    ENDIF
   ENDFOR

   IF matchedI > requiredI
    RETURN( FALSE )
   ENDIF

   IF matchedI + possibleI < requiredI
    RETURN( FALSE )
   ENDIF

   IF matchedI == requiredI
    FOR fieldIndexI = 1 TO 16
     clueDigitS = ProcCharAt( guessS, fieldIndexI )
     domainS = ProcGetDomainByIndex( fieldIndexI )

     IF Length( domainS ) > 1
      IF ProcStringContainsChar( domainS, clueDigitS )
       newDomainS = ProcRemoveChar( domainS, clueDigitS )
       IF newDomainS == ""
        RETURN( FALSE )
       ENDIF
       IF newDomainS == domainS
        //
       ELSE
        ProcSetDomainByIndex( fieldIndexI, newDomainS )
        changedB = TRUE
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
   ENDIF

   IF matchedI + possibleI == requiredI
    FOR fieldIndexI = 1 TO 16
     clueDigitS = ProcCharAt( guessS, fieldIndexI )
     domainS = ProcGetDomainByIndex( fieldIndexI )

     IF Length( domainS ) > 1
      IF ProcStringContainsChar( domainS, clueDigitS )
       IF domainS == clueDigitS
        //
       ELSE
        ProcSetDomainByIndex( fieldIndexI, clueDigitS )
        changedB = TRUE
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
  ENDFOR

  FOR fieldIndexI = 1 TO 16
   IF ProcGetDomainByIndex( fieldIndexI ) == ""
    RETURN( FALSE )
   ENDIF
  ENDFOR

  IF changedB
   //
  ELSE
   stableB = TRUE
  ENDIF
 ENDWHILE

 RETURN( TRUE )
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcTryNextBranchAtLevel( INTEGER levelI )
 INTEGER modeI = 0
 INTEGER itemI = 0
 INTEGER nextI = 0
 INTEGER maxMaskI = 0
 INTEGER maskI = 0
 INTEGER foundB = FALSE
 STRING choicesS[255] = ""
 STRING chosenDigitS[255] = ""

 modeI = ProcGetModeByLevel( levelI )
 itemI = ProcGetItemByLevel( levelI )
 nextI = ProcGetNextByLevel( levelI )

 IF modeI == 1
  ProcAnalyzeClue( itemI )
  maxMaskI = ( 1 shl gWorkPossibleI ) - 1
  foundB = FALSE

  FOR maskI = nextI TO maxMaskI
   IF foundB
    //
   ELSE
    IF ProcBitCount( maskI ) == gWorkRemainingI
     ProcSetNextByLevel( levelI, maskI + 1 )
     IF ProcApplyClueMask( itemI, maskI )
      foundB = TRUE
     ENDIF
    ENDIF
   ENDIF
  ENDFOR

  IF foundB
   RETURN( TRUE )
  ELSE
   RETURN( FALSE )
  ENDIF
 ENDIF

 IF modeI == 2
  choicesS = ProcGetDomainByIndex( itemI )
  foundB = FALSE

  FOR maskI = nextI TO Length( choicesS )
   IF foundB
    //
   ELSE
    chosenDigitS = ProcCharAt( choicesS, maskI )
    ProcSetNextByLevel( levelI, maskI + 1 )
    ProcSetDomainByIndex( itemI, chosenDigitS )
    foundB = TRUE
   ENDIF
  ENDFOR

  IF foundB
   RETURN( TRUE )
  ELSE
   RETURN( FALSE )
  ENDIF
 ENDIF

 RETURN( FALSE )
END

// -----------------------------------------------------------------------------

INTEGER PROC ProcSolveIterative()
 INTEGER depthI = 1
 INTEGER foundBranchB = FALSE
 INTEGER clueBranchI = 0
 INTEGER domainBranchI = 0

 WHILE TRUE
  IF ProcPropagate()
   IF ProcAllSingletons()
    gResultS = ProcBuildResult()
    RETURN( TRUE )
   ENDIF

   IF depthI > 20
    RETURN( FALSE )
   ENDIF

   clueBranchI = ProcChooseBestClueBranch()

   IF clueBranchI > 0
    ProcSaveDomainsForLevel( depthI )
    ProcSetModeByLevel( depthI, 1 )
    ProcSetItemByLevel( depthI, clueBranchI )
    ProcSetNextByLevel( depthI, 0 )

    IF ProcTryNextBranchAtLevel( depthI )
     depthI = depthI + 1
    ELSE
     depthI = depthI - 1
     foundBranchB = FALSE

     WHILE foundBranchB == FALSE
      IF depthI < 1
       RETURN( FALSE )
      ENDIF

      ProcRestoreDomainsForLevel( depthI )
      IF ProcTryNextBranchAtLevel( depthI )
       foundBranchB = TRUE
       depthI = depthI + 1
      ELSE
       depthI = depthI - 1
      ENDIF
     ENDWHILE
    ENDIF
   ELSE
    domainBranchI = ProcChooseBestIndex()
    IF domainBranchI == 0
     RETURN( FALSE )
    ENDIF

    ProcSaveDomainsForLevel( depthI )
    ProcSetModeByLevel( depthI, 2 )
    ProcSetItemByLevel( depthI, domainBranchI )
    ProcSetNextByLevel( depthI, 1 )

    IF ProcTryNextBranchAtLevel( depthI )
     depthI = depthI + 1
    ELSE
     depthI = depthI - 1
     foundBranchB = FALSE

     WHILE foundBranchB == FALSE
      IF depthI < 1
       RETURN( FALSE )
      ENDIF

      ProcRestoreDomainsForLevel( depthI )
      IF ProcTryNextBranchAtLevel( depthI )
       foundBranchB = TRUE
       depthI = depthI + 1
      ELSE
       depthI = depthI - 1
      ENDIF
     ENDWHILE
    ENDIF
   ENDIF
  ELSE
   depthI = depthI - 1
   foundBranchB = FALSE

   WHILE foundBranchB == FALSE
    IF depthI < 1
     RETURN( FALSE )
    ENDIF

    ProcRestoreDomainsForLevel( depthI )
    IF ProcTryNextBranchAtLevel( depthI )
     foundBranchB = TRUE
     depthI = depthI + 1
    ELSE
     depthI = depthI - 1
    ENDIF
   ENDWHILE
  ENDIF
 ENDWHILE

 RETURN( FALSE )
END

// -----------------------------------------------------------------------------

PROC Main()
 STRING resultS[255] = ""

 ProcInitializeDomains()

 IF ProcSolveIterative()
  resultS = gResultS
 ELSE
  resultS = "NO SOLUTION"
 ENDIF

 CopyToWinClip( resultS )
 Warn( resultS )
 CopyToWinClip( resultS )
END
