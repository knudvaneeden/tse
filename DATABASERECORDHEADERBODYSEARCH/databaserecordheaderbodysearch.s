FORWARD INTEGER PROC FNBlockCheckSelectMarkStreamB()
FORWARD INTEGER PROC FNBufferGetBufferIdFileCurrentI()
FORWARD INTEGER PROC FNBufferGetBufferIdGivenBufferNameI( STRING s1 )
FORWARD INTEGER PROC FNCursorCheckDownNotB()
FORWARD INTEGER PROC FNCursorCheckGotoDownB()
FORWARD INTEGER PROC FNCursorCheckGotoLeftB()
FORWARD INTEGER PROC FNCursorCheckGotoUpB()
FORWARD INTEGER PROC FNErrorCheckEscapeB( STRING s1 )
FORWARD INTEGER PROC FNErrorCheckSB( STRING s1 )
FORWARD INTEGER PROC FNFileCheckEditCentralMessageB( STRING s1, INTEGER i1 )
FORWARD INTEGER PROC FNFileCheckEditMessageB( STRING s1 )
FORWARD INTEGER PROC FNFileCheckGotoEndB()
FORWARD INTEGER PROC FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( STRING s1, INTEGER i1 )
FORWARD INTEGER PROC FNFileCheckLineFirstB()
FORWARD INTEGER PROC FNFileGetLineFirstI()
FORWARD INTEGER PROC FNHistoryCheckAskCentralB( STRING s1, VAR STRING s2, INTEGER i1 )
FORWARD INTEGER PROC FNKeyCheckPressEscapeB( STRING s1 )
FORWARD INTEGER PROC FNLineCheckGotoBeginB()
FORWARD INTEGER PROC FNLineCheckGotoEndB()
FORWARD INTEGER PROC FNLineCheckInsertAfterLineGotoBeginTextInsertB( STRING s1 )
FORWARD INTEGER PROC FNLineCheckSelectMarkB()
FORWARD INTEGER PROC FNLineCheckSelectMarkLineBeginEndB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMacroCheckExecB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckLoadB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckPurgeB( STRING s1 )
FORWARD INTEGER PROC FNMathCheckGetLogicFalseB()
FORWARD INTEGER PROC FNMathCheckGetLogicTrueB()
FORWARD INTEGER PROC FNMathCheckInitializeNewBooleanFalseB()
FORWARD INTEGER PROC FNMathCheckLogicNotB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheckLogicOrB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathCheckNumberEqualB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathCheckNumberEqualZeroB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheckNumberEqualZeroNotB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheckNumberIntegerEqualB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathGetProgramLineNumberAbsoluteCurrentI()
FORWARD INTEGER PROC FNRecordCheckGotoBeginSeparatorLineAfterBeginB()
FORWARD INTEGER PROC FNRecordCheckGotoLineEndSeparatorB()
FORWARD INTEGER PROC FNRecordCheckGotoNextSeparatorB()
FORWARD INTEGER PROC FNRecordCheckSeparatorLineB()
FORWARD INTEGER PROC FNScreenGetWindowColumnTotalI()
FORWARD INTEGER PROC FNStringCheckEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEmptyNotB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEnvironmentFoundNotB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNStringCheckEqualCharacterLastNB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNStringCheckEqualErrorOrEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringGetLengthI( STRING s1 )
FORWARD INTEGER PROC FNTextCheckInsertB( STRING s1 )
FORWARD INTEGER PROC FNTextCheckInsertCentralB( STRING s1, INTEGER i1 )
FORWARD INTEGER PROC FNTextCheckSearchExpressionB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNTextCheckSearchExpressionFoundB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNTextCheckSeparatorLineB( STRING s1 )
FORWARD INTEGER PROC FNTextGetPositionWindowColumnCurrentI()
FORWARD INTEGER PROC FNWindowCheckScrollHorizontalB()
FORWARD INTEGER PROC FNWindowGetScrollHorizontalI()
FORWARD PROC Main()
FORWARD PROC PROCBlockRemoveStackPop()
FORWARD PROC PROCBlockSaveStackPush()
FORWARD PROC PROCBlockSelectClearMark()
FORWARD PROC PROCBlockSelectMarkStream()
FORWARD PROC PROCCursorGotoDown()
FORWARD PROC PROCCursorGotoLeft()
FORWARD PROC PROCCursorGotoUp()
FORWARD PROC PROCError( STRING s1 )
FORWARD PROC PROCErrorFileNotFound( STRING s1 )
FORWARD PROC PROCFileGotoEnd()
FORWARD PROC PROCFileInsertEndPrepare()
FORWARD PROC PROCFileInsertTextEnd( STRING s1, STRING s2, INTEGER i1 )
FORWARD PROC PROCLineInsertAfter()
FORWARD PROC PROCLineInsertAfterLineGotoBeginTextInsert( STRING s1 )
FORWARD PROC PROCLineSelectMarkCurrent()
FORWARD PROC PROCMacroExec( STRING s1 )
FORWARD PROC PROCMacroPurge( STRING s1 )
FORWARD PROC PROCMacroRunPurge( STRING s1 )
FORWARD PROC PROCMacroRunPurgeParameter( STRING s1, STRING s2 )
FORWARD PROC PROCRecordGotoBeginSeparator()
FORWARD PROC PROCRecordGotoBeginSeparatorLineAfterGotoBegin()
FORWARD PROC PROCRecordGotoEndSeparator()
FORWARD PROC PROCRecordGotoEndSeparatorLineBefore()
FORWARD PROC PROCRecordGotoNextSeparator()
FORWARD PROC PROCRecordGotoSearchHeaderBodyFileView( STRING s1, STRING s2, STRING s3, STRING s4 )
FORWARD PROC PROCRecordSelectMark_CurrentSeparator()
FORWARD PROC PROCScreenGotoScrollLeft_HorizontalN( INTEGER i1 )
FORWARD PROC PROCSituationRestoreOld()
FORWARD PROC PROCSituationStoreOld()
FORWARD PROC PROCTextGotoLineBegin()
FORWARD PROC PROCTextGotoLineEnd()
FORWARD PROC PROCTextInsert( STRING s1 )
FORWARD PROC PROCTextRemovePositionStackPop()
FORWARD PROC PROCTextSavePositionStackPush()
FORWARD PROC PROCTextSearchFindScrollLeft()
FORWARD PROC PROCTextSelectMarkHiLiteFound()
FORWARD PROC PROCWarn( STRING s1 )
FORWARD PROC PROCWarnCons3( STRING s1, STRING s2, STRING s3 )
FORWARD PROC PROCWarnCons4( STRING s1, STRING s2, STRING s3, STRING s4 )
FORWARD PROC PROCWarnCons5( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5 )
FORWARD STRING PROC FNStringGetAsciiToCharacterS( INTEGER i1 )
FORWARD STRING PROC FNStringGetCarS( STRING s1 )
FORWARD STRING PROC FNStringGetCharacterEndBackSlashNotEqualInsertEndS( STRING s1 )
FORWARD STRING PROC FNStringGetCharacterInsertEndIfEqualNotS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetCharacterSymbolCentralS( INTEGER i1 )
FORWARD STRING PROC FNStringGetCharacterSymbolSlashBackwardS()
FORWARD STRING PROC FNStringGetCharacterSymbolSpaceS()
FORWARD STRING PROC FNStringGetConcatS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetConcatSeparatorS( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetConcatTailS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetCons3S( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetCons4S( STRING s1, STRING s2, STRING s3, STRING s4 )
FORWARD STRING PROC FNStringGetCons5S( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5 )
FORWARD STRING PROC FNStringGetConsS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetEmptyS()
FORWARD STRING PROC FNStringGetEnvironmentS( STRING s1 )
FORWARD STRING PROC FNStringGetErrorS()
FORWARD STRING PROC FNStringGetEscapeS()
FORWARD STRING PROC FNStringGetFileGetFilenamePathDefaultS( STRING s1 )
FORWARD STRING PROC FNStringGetFileIniDefaultS( STRING s1 )
FORWARD STRING PROC FNStringGetFilenameCurrentS()
FORWARD STRING PROC FNStringGetFilenameEndBackSlashNotEqualInsertEndS( STRING s1 )
FORWARD STRING PROC FNStringGetFilenameGlobalErrorS()
FORWARD STRING PROC FNStringGetFilenameIniDefaultS()
FORWARD STRING PROC FNStringGetGlobalS( STRING s1 )
FORWARD STRING PROC FNStringGetHistoryInputS( STRING s1, STRING s2, INTEGER i1 )
FORWARD STRING PROC FNStringGetInitializationGlobalS( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetInitializeNewStringS()
FORWARD STRING PROC FNStringGetLineGetCurrentS()
FORWARD STRING PROC FNStringGetLineNumberCurrentS()
FORWARD STRING PROC FNStringGetMachineNameS()
FORWARD STRING PROC FNStringGetMathIntegerToStringS( INTEGER i1 )
FORWARD STRING PROC FNStringGetMidStringS( STRING s1, INTEGER i1, INTEGER i2 )
FORWARD STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashNotS()
FORWARD STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashS()
FORWARD STRING PROC FNStringGetPortS()
FORWARD STRING PROC FNStringGetRecordSearchSeparatorDefaultExpressionRegularS()
FORWARD STRING PROC FNStringGetRecordSeparatorBeginDefaultS()
FORWARD STRING PROC FNStringGetRecordSeparatorDefaultS()
FORWARD STRING PROC FNStringGetRecordSeparatorEndDefaultS()
FORWARD STRING PROC FNStringGetRightStringLengthEqualS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetRightStringS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetSearchHistoryFindInputS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetSectionSeparatorS()
FORWARD STRING PROC FNStringGetTextFoundS()
FORWARD STRING PROC FNStringGetTextMarkS()
FORWARD STRING PROC FNStringGetUserNameFirstS()
FORWARD STRING PROC FNStringGetUserNameLastS()
FORWARD STRING PROC FNStringGet_FilenameIniDefaultS()


FORWARD STRING PROC FNDBBaseNameS( STRING pathS )
FORWARD STRING PROC FNDBMacroDirectoryS()
FORWARD INTEGER PROC FNDBAbsolutePathB( STRING pathS )
FORWARD STRING PROC FNDBResolvePathS( STRING pathS )
FORWARD STRING PROC FNDBIniValueS( STRING keyS, STRING fallbackS )
FORWARD PROC PROCDBShowResults()
FORWARD PROC PROCDBRightBtn()
FORWARD PROC PROCDBInitializeOutput( STRING pathS )
FORWARD PROC PROCDBScanFile( STRING headerS, STRING bodyS, STRING headerOptionsS, STRING bodyOptionsS )
FORWARD STRING PROC FNDBFindOptionsS( STRING optionsS )
FORWARD INTEGER PROC FNDBOptionsValidB( STRING headerOptionsS, STRING bodyOptionsS )
FORWARD PROC PROCDBDrawLine( INTEGER isCursorLineB )
FORWARD PROC PROCDBInitHistories()
FORWARD STRING PROC FNDBAskHistoryS( STRING promptS, STRING defaultS, INTEGER historyI )
// --- MAIN --- //
// databaserecordheaderbodysearch 1.0.0.0.24
// Keep this compiled macro loaded for the <CtrlAlt G> results shortcut.

STRING dbHeaderPatternGS[255] = ""
STRING dbBodyPatternGS[255] = ""
INTEGER dbBodyAfterMaxGI = 255
INTEGER dbShowProgressGB = TRUE
INTEGER dbProgressIntervalGI = 1
INTEGER dbHeaderColorGI = 0
INTEGER dbBodyColorGI = 0
STRING dbSourceGS[255] = ""
STRING dbResultsGS[255] = ""
INTEGER dbResultsReadyGB = FALSE
INTEGER dbHeaderHistoryGI = 0
INTEGER dbBodyHistoryGI = 0
INTEGER dbHeaderOptionsHistoryGI = 0
INTEGER dbBodyOptionsHistoryGI = 0
INTEGER dbOutputHistoryGI = 0
STRING dbMapGS[255] = ""
STRING dbHeaderSearchOptionsGS[255] = ""
STRING dbBodySearchOptionsGS[255] = ""
INTEGER dbAllFilesGB = FALSE
INTEGER dbViewHitGB = FALSE
INTEGER dbMatchCountGI = 0

// Show only the filename in the results view. Keep full path in the map.
STRING PROC FNDBBaseNameS( STRING pathS )
 INTEGER indexI = Length( pathS )
 WHILE indexI > 0
  IF SubStr( pathS, indexI, 1 ) == "\" OR SubStr( pathS, indexI, 1 ) == "/"
   RETURN( SubStr( pathS, indexI + 1, 255 ) )
  ENDIF
  indexI = indexI - 1
 ENDWHILE
 RETURN( pathS )
END

// Draw colored portions of each list line without changing its underlying text.
// The BODY: field contains the actual body match from GetFoundText().
PROC PROCDBDrawLine( INTEGER isCursorLineB )
 STRING lineS[255] = GetText( 1, 255 )
 STRING visibleS[255] = ""
 INTEGER headerPosI = 0
 INTEGER headerStartI = 0
 INTEGER headerRelativeI = 0
 INTEGER bodyPosI = 0
 INTEGER offsetI = CurrXoffset()
 INTEGER lengthI = 0
 INTEGER indexI = 0
 INTEGER attributeI = Query( TextAttr )
 INTEGER baseAttrI = Query( TextAttr )
 INTEGER charI = 0
 INTEGER visibleColsI = Query( WindowCols )
 IF isCursorLineB
  baseAttrI = Query( CursorAttr )
 ENDIF
 bodyPosI = StrFind( "BODY:", lineS, "i" )
 // Search for the header highlight only after the filename prefix.
 headerStartI = StrFind( "] Q.", lineS, "i" )
 IF dbHeaderPatternGS <> "" AND headerStartI > 0
  headerRelativeI = StrFind( dbHeaderPatternGS, SubStr( lineS, headerStartI + 2, 255 ), "ix" )
  IF headerRelativeI > 0
   headerPosI = headerStartI + 1 + headerRelativeI
  ENDIF
 ENDIF
 IF bodyPosI > 0 AND headerPosI >= bodyPosI
  headerPosI = 0
 ENDIF
 visibleS = GetText( offsetI + 1, 255 )
 lengthI = Length( visibleS )
 FOR indexI = 1 TO visibleColsI
  charI = indexI + offsetI
  IF indexI > lengthI BREAK ENDIF
  attributeI = baseAttrI
  IF headerPosI > 0
   IF charI >= headerPosI AND charI < headerPosI + Length( dbHeaderPatternGS )
    attributeI = dbHeaderColorGI
   ENDIF
  ENDIF
  IF bodyPosI > 0
   IF charI >= bodyPosI + Length( "BODY: " ) - 1 AND charI < bodyPosI + Length( "BODY: " ) - 1 + Length( dbBodyPatternGS )
    attributeI = dbBodyColorGI
   ENDIF
  ENDIF
  Set( Attr, attributeI )
  PutChar( SubStr( visibleS, indexI, 1 ) )
 ENDFOR
 Set( Attr, baseAttrI )
 ClrEol()
END

// TSE reuses each named history list instead of the shared Find history.
PROC PROCDBInitHistories()
 IF dbHeaderHistoryGI == 0
  dbHeaderHistoryGI = GetFreeHistory( "DATABASERECORDHEADERBODYSEARCH:header" )
 ENDIF
 IF dbBodyHistoryGI == 0
  dbBodyHistoryGI = GetFreeHistory( "DATABASERECORDHEADERBODYSEARCH:body" )
 ENDIF
 IF dbHeaderOptionsHistoryGI == 0
  dbHeaderOptionsHistoryGI = GetFreeHistory( "DATABASERECORDHEADERBODYSEARCH:headeroptions" )
 ENDIF
 IF dbBodyOptionsHistoryGI == 0
  dbBodyOptionsHistoryGI = GetFreeHistory( "DATABASERECORDHEADERBODYSEARCH:bodyoptions" )
 ENDIF
 IF dbOutputHistoryGI == 0
  dbOutputHistoryGI = GetFreeHistory( "DATABASERECORDHEADERBODYSEARCH:outputfile" )
 ENDIF
END

STRING PROC FNDBAskHistoryS( STRING promptS, STRING defaultS, INTEGER historyI )
 // Preserve the existing helper's <Escape> marker and input handling.
 // Gracefully fall back to an unassigned history if none is available.
 RETURN( FNStringGetHistoryInputS( promptS, defaultS, historyI ) )
END

STRING PROC FNDBMacroDirectoryS()
 STRING fullS[255] = CurrMacroFilename()
 INTEGER indexI = Length( fullS )
 WHILE indexI > 0
  IF SubStr( fullS, indexI, 1 ) == "\" OR SubStr( fullS, indexI, 1 ) == "/"
   RETURN( SubStr( fullS, 1, indexI ) )
  ENDIF
  indexI = indexI - 1
 ENDWHILE
 RETURN( "" )
END

INTEGER PROC FNDBAbsolutePathB( STRING pathS )
 IF Length( pathS ) >= 2
  IF SubStr( pathS, 2, 1 ) == ":" RETURN( TRUE ) ENDIF
 ENDIF
 IF Length( pathS ) >= 2
  IF SubStr( pathS, 1, 2 ) == "\\" RETURN( TRUE ) ENDIF
 ENDIF
 RETURN( FALSE )
END

STRING PROC FNDBResolvePathS( STRING pathS )
 IF FNDBAbsolutePathB( pathS ) RETURN( pathS ) ENDIF
 RETURN( FNDBMacroDirectoryS() + pathS )
END

STRING PROC FNDBIniValueS( STRING keyS, STRING fallbackS )
 STRING iniS[255] = FNDBMacroDirectoryS() + "databaserecordheaderbodysearch.ini"
 RETURN( GetProfileStr( "default", keyS, fallbackS, iniS ) )
END

PROC PROCDBShowResults()
 INTEGER choiceI = 0
 INTEGER resultRowI = 0
 INTEGER sourceLineI = 0
 STRING currentS[255] = ""
 STRING mapLineS[255] = ""
 STRING targetFileS[255] = ""
 IF NOT dbResultsReadyGB
  Warn( "No results yet. Run <F12> from a database file first." )
  RETURN()
 ENDIF
 dbViewHitGB = FALSE
 currentS = CurrFilename()
 IF NOT EditFile( dbResultsGS )
  Warn( "Results file could not be opened: " + dbResultsGS )
  RETURN()
 ENDIF
 BegFile()
 HookDisplay( PROCDBDrawLine, , , )
 choiceI = List( "Select matching record | CtrlAlt G / RightBtn: overview", 150 )
 UnhookDisplay()
 IF choiceI == 0
  IF currentS <> "" EditFile( currentS ) ENDIF
  RETURN()
 ENDIF
 // The visible result row and the map row always have identical indices.
 resultRowI = CurrLine()
 IF NOT EditFile( dbMapGS )
  Warn( "Result mapping file unavailable: " + dbMapGS )
  RETURN()
 ENDIF
 GotoLine( resultRowI )
 mapLineS = GetText( 1, 255 )
 sourceLineI = Val( GetToken( mapLineS, "|", 1 ) )
 targetFileS = GetToken( mapLineS, "|", 2 )
 IF sourceLineI <= 0 OR targetFileS == ""
  Warn( "Invalid result mapping." )
  RETURN()
 ENDIF
 IF NOT EditFile( targetFileS )
  Warn( "Database source cannot be opened: " + targetFileS )
  RETURN()
 ENDIF
 GotoLine( sourceLineI )
 BegLine()
 ScrollToTop()
 dbSourceGS = targetFileS
 dbViewHitGB = TRUE
END

PROC PROCDBRightBtn()
 IF dbViewHitGB
  PROCDBShowResults()
 ENDIF
END

PROC Main()
 STRING headerS[255] = ""
 STRING bodyS[255] = ""
 STRING headerOptionsS[255] = ""
 STRING bodyOptionsS[255] = ""
 STRING outputS[255] = ""
 STRING fallbackS[255] = ""
 PROCDBInitHistories()
 IF CurrFilename() == dbResultsGS AND dbSourceGS <> ""
  EditFile( dbSourceGS )
 ENDIF
 headerS = FNDBAskHistoryS( "Header regular expression = ", FNDBIniValueS( "headersearch", "TSE" ), dbHeaderHistoryGI )
 IF FNKeyCheckPressEscapeB( headerS ) RETURN() ENDIF
 bodyS = FNDBAskHistoryS( "Body regular expression = ", FNDBIniValueS( "bodysearch", "the" ), dbBodyHistoryGI )
 IF FNKeyCheckPressEscapeB( bodyS ) RETURN() ENDIF
 headerOptionsS = FNDBAskHistoryS( "HEADER options (a/l, i, w, x) = ", FNDBIniValueS( "headersearchoptions", "iwx" ), dbHeaderOptionsHistoryGI )
 IF FNKeyCheckPressEscapeB( headerOptionsS ) RETURN() ENDIF
 bodyOptionsS = FNDBAskHistoryS( "BODY options (i, w, x) = ", FNDBIniValueS( "bodysearchoptions", "ix" ), dbBodyOptionsHistoryGI )
 IF FNKeyCheckPressEscapeB( bodyOptionsS ) RETURN() ENDIF
 IF NOT FNDBOptionsValidB( headerOptionsS, bodyOptionsS ) RETURN() ENDIF
 fallbackS = FNDBIniValueS( "outputfile", "databaserecordheaderbodysearch_results.txt" )
 outputS = FNDBAskHistoryS( "Results filename = ", fallbackS, dbOutputHistoryGI )
 IF FNKeyCheckPressEscapeB( outputS ) RETURN() ENDIF
 outputS = FNDBResolvePathS( outputS )
 IF CurrFilename() == "" OR CurrFilename() == outputS
  Warn( "Open the database source file first; it must differ from results." )
  RETURN()
 ENDIF
 dbHeaderPatternGS = headerS
 dbBodyPatternGS = bodyS
 dbBodyAfterMaxGI = Val( FNDBIniValueS( "bodyaftermax", "255" ) )
 IF dbBodyAfterMaxGI < 0 dbBodyAfterMaxGI = 0 ENDIF
 IF dbBodyAfterMaxGI > 255 dbBodyAfterMaxGI = 255 ENDIF
 dbHeaderColorGI = Val( FNDBIniValueS( "headercolor", "249" ) )
 dbBodyColorGI = Val( FNDBIniValueS( "bodycolor", "244" ) )
 dbShowProgressGB = Val( FNDBIniValueS( "showsearchprogress", "1" ) ) <> 0
 dbProgressIntervalGI = Val( FNDBIniValueS( "progressinterval", "1" ) )
 IF dbProgressIntervalGI < 1 dbProgressIntervalGI = 1 ENDIF
 dbResultsReadyGB = FALSE
 dbHeaderSearchOptionsGS = headerOptionsS
 dbBodySearchOptionsGS = bodyOptionsS
 dbAllFilesGB = StrFind( "a", headerOptionsS, "i" ) > 0
 PROCRecordGotoSearchHeaderBodyFileView( headerS, bodyS, headerOptionsS, outputS )
END

<F12> Main()
<CtrlAlt G> PROCDBShowResults()
<RightBtn> PROCDBRightBtn()

// TSE SAL: escape result from the persistent Ask() wrapper.
// Restored from the original gotorefv.s library implementation.
INTEGER PROC FNKeyCheckPressEscapeB( STRING answerS )
 RETURN( FNStringCheckEqualB( answerS, FNStringGetEscapeS() ) )
END

// --- LIBRARY --- //

// Scope options a/l are handled by the ring iteration, not LFind().
// Header matching requires x because the expression has the ^Q. prefix.
// BODY matching uses only the options explicitly requested by the user,
// plus the mandatory local-block restriction added in PROCDBScanFile().
STRING PROC FNDBFindOptionsS( STRING optionsS )
 STRING resultS[255] = ""
 IF StrFind( "i", optionsS, "i" ) > 0 resultS = resultS + "i" ENDIF
 IF StrFind( "w", optionsS, "i" ) > 0 resultS = resultS + "w" ENDIF
 IF StrFind( "x", optionsS, "i" ) > 0 resultS = resultS + "x" ENDIF
 RETURN( resultS )
END

INTEGER PROC FNDBOptionsValidB( STRING headerOptionsS, STRING bodyOptionsS )
 IF StrFind( "a", headerOptionsS, "i" ) > 0 AND StrFind( "l", headerOptionsS, "i" ) > 0
  Warn( "HEADER options: 'a' and 'l' are mutually exclusive." )
  RETURN( FALSE )
 ENDIF
 IF StrFind( "a", bodyOptionsS, "i" ) > 0 OR StrFind( "l", bodyOptionsS, "i" ) > 0
  Warn( "BODY options must not include 'a' or 'l'; body is always local to the current record." )
  RETURN( FALSE )
 ENDIF
 RETURN( TRUE )
END

// Reset a results file without modifying the caller's source file.
PROC PROCDBInitializeOutput( STRING pathS )
 EraseDiskFile( pathS )
 EditFile( pathS )
 AbandonFile()
END

// Search one database file, from Q. until its record separator.
// At most one body result is added for each matching Q. record.
PROC PROCDBScanFile( STRING headerS, STRING bodyS, STRING headerOptionsS, STRING bodyOptionsS )
 INTEGER bodyOffsetI = 0
 INTEGER bodyValidB = FALSE
 INTEGER sourceLineI = 0
 INTEGER bodyColumnI = 0
 INTEGER headerLineI = 0
 INTEGER nextRecordLineI = 0
 STRING sourceS[255] = CurrFilename()
 STRING headerLineS[255] = ""
 STRING headerMatchedS[255] = ""
 INTEGER headerMatchColI = 0
 STRING bodyMatchS[255] = ""
 STRING bodyAfterS[255] = ""
 STRING resultLineS[255] = ""
 STRING previewS[255] = ""
 STRING displayNameS[255] = ""
 INTEGER bodyRoomI = 0
 STRING headerFindS[255] = ""
 STRING bodyFindS[255] = ""
 IF sourceS == dbResultsGS OR sourceS == dbMapGS OR sourceS == "" RETURN() ENDIF
 headerFindS = "^Q\. .*" + headerS
 bodyFindS = FNDBFindOptionsS( bodyOptionsS ) + "l+"
 PushPosition()
 PushBlock()
 BegFile()
 WHILE LFind( headerFindS, FNDBFindOptionsS( headerOptionsS ) + "x+" )
  headerLineI = CurrLine()
  headerLineS = GetText( 1, 255 )
  // The header expression may be a regular expression. Use its first matching
  // position for highlighting, without changing the header-search algorithm.
  headerMatchColI = StrFind( headerS, headerLineS, FNDBFindOptionsS( headerOptionsS ) )
  headerMatchedS = headerS
  PROCRecordSelectMark_CurrentSeparator()
  GotoBlockBegin()
  // A.+1 date, +2 metadata, +3 ---, +4 repeated title,
  // +5 starts the answer BODY below the repeated title.
  IF LFind( "^A\.", "lx+" )
   bodyValidB = TRUE
   FOR bodyOffsetI = 1 TO 5
    IF NOT Down()
     bodyValidB = FALSE
     BREAK
    ENDIF
   ENDFOR
   IF bodyValidB
    BegLine()
    IF LFind( bodyS, bodyFindS )
     sourceLineI = CurrLine()
     bodyColumnI = CurrCol()
     bodyMatchS = GetFoundText()
     bodyAfterS = ""
     IF dbBodyAfterMaxGI > 0
      bodyAfterS = GetText( bodyColumnI + Length( bodyMatchS ), dbBodyAfterMaxGI )
     ENDIF
     // Visible filename follows the line number. The map keeps the full path.
     displayNameS = FNDBBaseNameS( sourceS )
     IF Length( displayNameS ) > 60
      displayNameS = SubStr( displayNameS, 1, 57 ) + "..."
     ENDIF
     resultLineS = Str( sourceLineI ) + ":  [" + displayNameS + "] " + SubStr( headerLineS, 1, 78 ) + " | BODY: "
     // SAL strings hold up to 255 characters; reserve room for BODY match.
     bodyRoomI = 255 - Length( resultLineS ) - Length( bodyMatchS )
     IF bodyRoomI < 0
      // Preserve BODY match and marker, shortening the HEADER preview.
      resultLineS = Str( sourceLineI ) + ":  [" + displayNameS + "] " + SubStr( headerLineS, 1, 30 ) + " | BODY: "
      bodyRoomI = 255 - Length( resultLineS ) - Length( bodyMatchS )
     ENDIF
     IF bodyRoomI < 0 bodyRoomI = 0 ENDIF
     IF Length( bodyAfterS ) > bodyRoomI
      bodyAfterS = SubStr( bodyAfterS, 1, bodyRoomI )
     ENDIF
     PushPosition()
     EditFile( dbResultsGS )
     EndFile()
     AddLine( resultLineS )
     EndLine()
     InsertText( bodyMatchS, 0 )
     InsertText( bodyAfterS, 0 )
     PopPosition()
     PushPosition()
     EditFile( dbMapGS )
     EndFile()
     AddLine( Str( headerLineI ) + "|" + sourceS )
     PopPosition()
     dbMatchCountGI = dbMatchCountGI + 1
     // Refresh ONLY for records matching both HEADER and BODY.
     // Keep the Q. HEADER at the TOP, while selecting the matching BODY
     // line by its absolute line number. MarkLine(row,row) does not
     // require moving the cursor to the BODY line first.
     // A BODY line below the visible window remains marked, but cannot
     // be visible at the same time as a far-away Q. header.
     // Native selection preserves the editor's line-number margin.
     IF dbShowProgressGB AND ( ( dbMatchCountGI MOD dbProgressIntervalGI ) == 0 )
      PushPosition()
      PushBlock()
      UnMarkBlock()
      GotoLine( headerLineI )
      BegLine()
      ScrollToTop()
      MarkLine( sourceLineI, sourceLineI )
      UpdateDisplay()
      IF WaitForKeyPressed( 0 ) ENDIF
      PopBlock()
      PopPosition()
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  GotoBlockEnd()
  UnMarkBlock()
  // Advance to another Q. without revisiting this record.
  IF CurrLine() <= headerLineI
   GotoLine( headerLineI )
   IF NOT Down() BREAK ENDIF
  ENDIF
 ENDWHILE
 PopBlock()
 PopPosition()
END

PROC PROCRecordGotoSearchHeaderBodyFileView( STRING searchRecordHeaderS, STRING searchRecordBodyS, STRING searchOptionS, STRING fileNameOutputS )
 INTEGER ringTotalI = 0
 INTEGER ringI = 0
 INTEGER currentIdI = 0
 INTEGER sourceIdI = GetBufferId()
 STRING sourceS[255] = CurrFilename()
 IF sourceS == fileNameOutputS
  Warn( "Output file must differ from source database." )
  RETURN()
 ENDIF
 dbSourceGS = sourceS
 dbResultsGS = fileNameOutputS
 dbMapGS = fileNameOutputS + ".map"
 dbResultsReadyGB = FALSE
 dbViewHitGB = FALSE
 dbMatchCountGI = 0
 PROCDBInitializeOutput( dbResultsGS )
 PROCDBInitializeOutput( dbMapGS )
 // Keep both output buffers open before NumFiles()/NextFile() traversal.
 // Otherwise the first hit opens them and changes the ring mid-scan.
 EditFile( dbResultsGS )
 EditFile( dbMapGS )
 GotoBufferId( sourceIdI )
 IF dbAllFilesGB
  // Take the ring size AFTER the output buffers have been created.
  // Include them in traversal, but never search either output buffer.
  // This prevents new buffers from silently shortening the ring scan.
  ringTotalI = NumFiles()
 ELSE
  ringTotalI = 1
 ENDIF
 FOR ringI = 1 TO ringTotalI
  currentIdI = GetBufferId()
  IF CurrFilename() <> dbResultsGS AND CurrFilename() <> dbMapGS AND CurrFilename() <> ""
   PROCDBScanFile( searchRecordHeaderS, searchRecordBodyS, searchOptionS, dbBodySearchOptionsGS )
  ENDIF
  // The scan switches to results and mapping buffers to append hits.
  // Restore the ring buffer BEFORE going to the next file.
  GotoBufferId( currentIdI )
  IF dbAllFilesGB NextFile() ENDIF
 ENDFOR
 GotoBufferId( sourceIdI )
 EditFile( dbResultsGS )
 SaveFile()
 EditFile( dbMapGS )
 SaveFile()
 GotoBufferId( sourceIdI )
 dbResultsReadyGB = TRUE
 PROCDBShowResults()
END

// library: string: get: search: history: find: input <description>input a string: history: find</description> <version>1.0.0.0.3</version> (filenamemacro=getstfir.s) [<Program>] [<Research>] [kn, ri, sa, 25-08-2001 21:00:25]
STRING PROC FNStringGetSearchHistoryFindInputS( STRING askS, STRING answerDefaultS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchHistoryFindInputS( "Please input something", "test" ) ) // gives e.g. "test"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetHistoryInputS( askS, answerDefaultS, _FIND_HISTORY_ ) )
 //
END

// library: string: check: equal <description>string: equal: are two given strings equal? (stored in 'checstcf.s')</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checstcy.s) [<Program>] [<Research>] [[kn, zoe, we, 04-10-2000 18:23:27]
INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: check: equal: first string = ", "a" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "string: check: equal: second string = ", "a" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNStringCheckEqualB( s1, s2 ) ) // gives e.g. TRUE when string1 is equal to string2
 // e.g.  GetKey()
 // e.g.  Message( FNStringCheckEqualB( "knud", "knud" ) ) // gives TRUE
 // e.g.  GetKey()
 // e.g.  Message( FNStringCheckEqualB( "knud", "van" ) ) // gives FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( s1 == s2 )
 //
END

// library: string: get: escape <description>general output string to recognize an escape (e.g. in another routine). Central routine, only one occurrence of this constant string</description> <version>1.0.0.0.3</version> (filenamemacro=getstges.s) [<Program>] [<Research>] [kn, ri, sa, 05-12-1998 18:52:24]
STRING PROC FNStringGetEscapeS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetEscapeS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "<ESCAPE>" )
 //
END

// library: text: check: search: expression: found <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checteei.s) [<Program>] [<Research>] [kn, ri, sa, 25-08-2001 21:58:50]
INTEGER PROC FNTextCheckSearchExpressionFoundB( STRING searchS, STRING searchoptionS )
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckSearchExpressionFoundB( "test", "i" ) ) // gives e.g. TRUE when that text is found
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckNumberEqualZeroNotB( FNTextCheckSearchExpressionB( searchS, searchoptionS ) ) )
 //
END

// library: record: mark: current: fix: mark a record <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=selermcs.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 13:40:22]
PROC PROCRecordSelectMark_CurrentSeparator()
 // e.g. PROC Main()
 // e.g.  PROCRecordSelectMark_CurrentSeparator()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextSavePositionStackPush() // added later [kn, zoe, sa, 26-06-1999 00:32:53]
 //
 PROCBlockSelectClearMark() // added later [kn, ri, tu, 08-06-1999 21:53:42]
 //
 PROCRecordGotoBeginSeparator()
 //
 PROCBlockSelectMarkStream()
 //
 PROCRecordGotoEndSeparator()
 //
 PROCCursorGotoLeft() // avoid the extra line when pasting
 //
 PROCBlockSelectMarkStream()
 //
 PROCTextRemovePositionStackPop()
 //
END

// library: record: movement: goto the begin next record with separator <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=gotorens.s) [<Program>] [<Research>] [kn, ri, fr, 09-02-2001 00:14:01]
PROC PROCRecordGotoNextSeparator()
 // e.g. PROC Main()
 // e.g.  PROCRecordGotoNextSeparator()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNRecordCheckGotoNextSeparatorB() )
  //
  // PROCWarn( "" )
  //
 ENDIF
 //
END

// library: string: get: history: input <description>input a string and store it in that specific history list</description> <version>1.0.0.0.3</version> (filenamemacro=getsthin.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 13:04:18]
STRING PROC FNStringGetHistoryInputS( STRING infoS, STRING answerDefaultS, INTEGER historyI )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetHistoryInputS( "Please input something", "test", _FIND_HISTORY_ ) ) // gives e.g. "test"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = answerDefaultS
 //
 INTEGER escapeB = FNMathCheckInitializeNewBooleanFalseB()
 //
 escapeB = FNMathCheckLogicNotB( FNHistoryCheckAskCentralB( infoS, s, historyI ) )
 //
 IF ( escapeB )
  //
  RETURN( FNStringGetEscapeS() )
  //
 ENDIF // <Escape> was pressed, in response
 //
 IF FNStringCheckEmptyB( s ) AND FNStringCheckEmptyNotB( answerDefaultS )
  //
  RETURN( FNStringGetEmptyS() ) // input of an empty string, user has removed the string to indicate that an empty string was wanted
  //
 ENDIF
 //
 IF FNStringCheckEmptyB( s )
  //
  RETURN( answerDefaultS )
  //
 ENDIF // <Enter> was pressed, in response (variation: IF FNMathCheckLogicNotB( FNStringGetLengthI( s ) ) ...) // removed FN because it gave problems compiling [kn, ri, sa, 16-02-2008 21:53:49]
 //
 RETURN( s ) // response was entered
 //
END

// library: math: check: number: equal: zero: not <description>math: number not equal to ZERO?</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=checmazn.s) [<Program>] [<Research>] [kn, ri, we, 04-07-2001 13:26:56]
INTEGER PROC FNMathCheckNumberEqualZeroNotB( INTEGER x )
 // e.g. PROC Main()
 // e.g.  Warn( FNMathCheckNumberEqualZeroNotB( 0 ) ) // gives e.g. FALSE
 // e.g.  Warn( FNMathCheckNumberEqualZeroNotB( 1 ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckLogicNotB( FNMathCheckNumberEqualZeroB( x ) ) )
 //
END

// library: text: search: return true if found <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=searteex.s) [<Program>] [<Research>] [kn, ni, fr, 07-08-1998 19:36:39]
INTEGER PROC FNTextCheckSearchExpressionB( STRING searchS, STRING searchoptionS )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING searchoptionS[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "text: search: string = ", "test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  searchoptionS = FNStringGetInputS( "text: search: string = ", "test" )
 // e.g.  IF FNKeyCheckPressEscapeB( searchoptionS ) RETURN() ENDIF
 // e.g.  Message( FNTextCheckSearchExpressionB( s, searchoptionS ) ) // gives e.g. TRUE when the string is found in the text
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER foundB = LFind( searchS, searchoptionS )
 //
 IF foundB
  //
  PROCTextSearchFindScrollLeft()
  //
 ENDIF
 //
 RETURN( foundB )
 //
END

// library: text: save: position: stack: push <description>text: save: position: stack: push: store</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=savetesp.s) [<Program>] [<Research>] [[kn, zoe, fr, 04-06-1999 23:01:00]
PROC PROCTextSavePositionStackPush()
 // e.g. PROC Main()
 // e.g.  PROCTextSavePositionStackPush()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PushPosition() // returns nothing
 //
 // pushpopGT = pushpopGT + 1 // for checking purposes on the end of your routines. This must give 0 (as there as as many +1 as -1 in the OK case)
 //
END

// library: block: mark: unmark: PROCBlockUnMark(): (Unmarks Marked Block) N * <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=cleablcm.s) [<Program>] [<Research>] [kn, zoe, we, 16-06-1999 01:07:12]
PROC PROCBlockSelectClearMark()
 // e.g. PROC Main()
 // e.g.  PROCBlockSelectClearMark()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 UnMarkBlock()
 //
END

// library: record: goto: begin: separator <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=gotorebu.s) [<Program>] [<Research>] [kn, ri, su, 27-05-2007 22:36:50]
PROC PROCRecordGotoBeginSeparator()
 // e.g. PROC Main()
 // e.g.  PROCRecordGotoBeginSeparator()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCRecordGotoBeginSeparatorLineAfterGotoBegin()
 //
END

// library: block: mark: mark a stream block (marks character block that includes cursor position) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=markblms.s) [<Program>] [<Research>] [kn, ri, we, 12-05-1999 07:40:27]
PROC PROCBlockSelectMarkStream()
 // e.g. PROC Main()
 // e.g.  PROCBlockSelectMarkStream()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNBlockCheckSelectMarkStreamB() )
  //
  PROCWarn( "mark stream was not possible" )
  //
 ENDIF
 //
END

// library: record: goto: end: separator <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=gotoreeu.s) [<Program>] [<Research>] [kn, ri, su, 27-05-2007 22:57:06]
PROC PROCRecordGotoEndSeparator()
 // e.g. PROC Main()
 // e.g.  PROCRecordGotoEndSeparator()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCRecordGotoEndSeparatorLineBefore()
 //
END

// library: cursor: goto: left <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=gotocugl.s) [<Program>] [<Research>] [kn, zoe, tu, 15-06-1999 23:46:50]
PROC PROCCursorGotoLeft()
 // e.g. PROC Main()
 // e.g.  PROCCursorGotoLeft()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNCursorCheckGotoLeftB() )
  //
  // PROCWarn( "Could not go left"  )
  //
 ENDIF
 //
END

// library: text: remove: position: stack: pop <description>text: remove: position: stack: pop: restore</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=remotesp.s) [<Program>] [<Research>] [[kn, zoe, fr, 04-06-1999 23:01:00]
PROC PROCTextRemovePositionStackPop()
 // e.g. PROC Main()
 // e.g.  PROCTextRemovePositionStackPop()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PopPosition() // returns nothing
 //
 // pushpopGT = pushpopGT - 1 // for checking purposes on the end of your routines. This must give 0 (as there as as many +1 as -1 in the OK case)
 //
END

// library: math: check: logic: not <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checmaln.s) [<Program>] [<Research>] [kn, ri, tu, 15-05-2001 16:54:21]
INTEGER PROC FNMathCheckLogicNotB( INTEGER B )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "math: check: logic: not: number = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( FNMathCheckLogicNotB( FNStringGetToIntegerI( s ) ) )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( NOT B )
 //
END

// library: record: check: goto: next: separator <description></description> <version control></version control> <version>1.0.0.0.12</version> (filenamemacro=checrens.s) [<Program>] [<Research>] [kn, ri, su, 01-11-2009 21:56:04]
INTEGER PROC FNRecordCheckGotoNextSeparatorB()
 // e.g. PROC Main()
 // e.g.  Message( FNRecordCheckGotoNextSeparatorB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF ( CurrLine() == NumLines() )
  //
  RETURN( FALSE )
  //
 ENDIF
 //
 // IF NOT LFind( Format( "^", FNStringGetRecordSeparatorDefaultS(), "$" ), "x" )
 //
 IF ( NOT ( LFind( FNStringGetRecordSearchSeparatorDefaultExpressionRegularS(), "x" ) ) )
  //
  Warn( "no separator found" )
  //
  RETURN( FALSE )
  //
 ENDIF
 //
 PROCCursorGotoDown()
 //
 PROCMacroRunPurge( "gotowist" ) // operation: goto: windows: scroll: top
 //
 RETURN( TRUE )
 //
END

// library: initialize: check: new: boolean: false <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checinbf.s) [<Program>] [<Research>] [kn, ri, su, 22-07-2001 15:58:06]
INTEGER PROC FNMathCheckInitializeNewBooleanFalseB()
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckInitializeNewBooleanFalseB() ) // gives e.g. FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckGetLogicFalseB() )
 //
END

// library: history: check: ask: central <description>input: ask: find history</description> <version>1.0.0.0.2</version> (filenamemacro=chechiac.s) [<Program>] [<Research>] [kn, ri, sa, 25-08-2001 20:34:13]
INTEGER PROC FNHistoryCheckAskCentralB( STRING askS, VAR STRING answerDefaultS, INTEGER historyI )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = "test"
 // e.g.  Message( FNHistoryCheckAskCentralB( "Please input something", s, _FIND_HISTORY_ ) ) // gives e.g. "test"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Ask( askS, answerDefaultS, historyI ) )
 //
END

// library: string: check: empty <description>string: empty: is given string empty?</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checstcz.s) [<Program>] [<Research>] [[kn, ri, sa, 20-05-2000 20:11:08]
INTEGER PROC FNStringCheckEmptyB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckEmptyB( s ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( s, FNStringGetEmptyS() ) )
 //
END

// library: string: check: empty: not <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checstep.s) [<Program>] [<Research>] [kn, ri, su, 21-05-2006 22:32:11]
INTEGER PROC FNStringCheckEmptyNotB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckEmptyNotB( FNStringGetEmptyS() ) ) // gives e.g. FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckLogicNotB( FNStringCheckEmptyB( s ) ) )
 //
END

// library: string: get: empty (return an empty string) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstgem.s) [<Program>] [<Research>] [kn, ri, sa, 20-05-2000 20:11:03]
STRING PROC FNStringGetEmptyS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetEmptyS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "" )
 //
END

// library: string: line: length: what is the length <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstgle.s) [<Program>] [<Research>] [kn, ri, we, 25-11-1998 20:20:58]
INTEGER PROC FNStringGetLengthI( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: line: length: string = ", "this is a test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetLengthI( s1 ) ) // gives e.g. 14
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetLengthI( "knud" ) ) // gives 4
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetLengthI( "the" ) ) // gives 3
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Length( s ) )
 //
END

// library: math: check: number: equal: zero <description>math: number equal to ZERO?</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checmaeb.s) [<Program>] [<Research>] [kn, ri, th, 03-05-2001 14:19:57]
INTEGER PROC FNMathCheckNumberEqualZeroB( INTEGER x )
 // e.g. PROC Main()
 // e.g.  Warn( FNMathCheckNumberEqualZeroB( 0 ) ) // gives e.g. TRUE
 // e.g.  Warn( FNMathCheckNumberEqualZeroB( 1 ) ) // gives e.g. FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckNumberEqualB( x, 0 ) )
 //
END

// library: text: search: find: scroll: left <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=seartesl.s) [<Program>] [<Research>] [kn, ri, sa, 21-05-2005 16:07:12]
PROC PROCTextSearchFindScrollLeft()
 // e.g. PROC Main()
 // e.g.  PROCTextSearchFindScrollLeft()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // if the screen has scrolled horizontally, and the current horizontal line length (counting from the beginning of the window until the end of the found string) fits completely in the current window, then move the window back to its begin position
 //
 IF FNWindowCheckScrollHorizontalB() AND ( FNTextGetPositionWindowColumnCurrentI() + FNStringGetLengthI( FNStringGetTextFoundS() ) - 1 ) <= FNScreenGetWindowColumnTotalI()
  //
  PROCScreenGotoScrollLeft_HorizontalN( FNWindowGetScrollHorizontalI() )
  //
  PROCTextSelectMarkHiLiteFound()
  //
 ENDIF
 //
END

// library: record: movement: goto the start of a record: separator <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=gotorebs.s) [<Program>] [<Research>] [kn, zoe, mo, 11-12-2000 16:38:16]
PROC PROCRecordGotoBeginSeparatorLineAfterGotoBegin()
 // e.g. PROC Main()
 // e.g.  PROCRecordGotoBeginSeparatorLineAfterGotoBegin()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNRecordCheckGotoBeginSeparatorLineAfterBeginB() )
  //
  PROCWarn( "Record begin separator not found" )
  //
 ENDIF
 //
END

// library: block: mark: stream <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=markblmt.s) [<Program>] [<Research>] [kn, zoe, fr, 24-11-2000 19:08:32]
INTEGER PROC FNBlockCheckSelectMarkStreamB()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockCheckSelectMarkStreamB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( MarkStream() )
 //
END

// library: warn <description>error: warning: give a warning message</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=wawarn.s)  [<Program>] [<Research>] [kn, zoe, we, 09-06-1999 22:11:07]
PROC PROCWarn( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCWarn( "you have forgotten to input a value" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 Warn( s )
 //
END

// library: record: movement: goto the end of a record: separator <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=gotoreet.s) [<Program>] [<Research>] [kn, zoe, mo, 11-12-2000 16:38:16]
PROC PROCRecordGotoEndSeparatorLineBefore()
 // e.g. PROC Main()
 // e.g.  PROCRecordGotoEndSeparatorLineBefore()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNRecordCheckGotoLineEndSeparatorB() )
  //
  PROCWarn( "Record end separator not found" )
  //
 ENDIF
 //
END

// library: movement: line: left: go to the previous character <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checcugl.s) [<Program>] [<Research>] [kn, zoe, we, 12-05-1999 15:48:43]
INTEGER PROC FNCursorCheckGotoLeftB()
 // e.g. PROC Main()
 // e.g.  Message( FNCursorCheckGotoLeftB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Left() )
 //
END

// library: string: get: record: search: separator: default: expression: regular <description></description> <version>1.0.0.0.12</version> <version control></version control> (filenamemacro=getstern.s) [<Program>] [<Research>] [kn, ri, su, 06-11-2011 13:49:26]
STRING PROC FNStringGetRecordSearchSeparatorDefaultExpressionRegularS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecordSearchSeparatorDefaultExpressionRegularS() ) // gives e.g. "^ÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃ$"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( Format( "^", FNStringGetRecordSeparatorDefaultS(), "$" ) )
 //
 RETURN( Format( FNStringGetRecordSeparatorBeginDefaultS(), FNStringGetRecordSeparatorDefaultS(), FNStringGetRecordSeparatorEndDefaultS() ) )
 //
END

// library: cursor: goto: down <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=gotocugd.s) [<Program>] [<Research>] [kn, zoe, tu, 15-06-1999 23:46:50]
PROC PROCCursorGotoDown()
 // e.g. PROC Main()
 // e.g.  PROCCursorGotoDown()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNCursorCheckDownNotB()
  //
  // PROCWarn( "Could not go down"  )
  //
 ENDIF
 //
END

// library: macro: run: purge <description>macro: run a macro, then purge it (this text goes into the main macro file)</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=runmarpu.s) [<Program>] [<Research>] [[kn, zoe, tu, 27-10-1998 18:54:17]
PROC PROCMacroRunPurge( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  PROCMacroRunPurge( "mysubma1.mac myparameter11 myparameter12" )
 // e.g.  PROCMacroRunPurge( "mysubma2.mac myparameter21" )
 // e.g.  PROCMacroRunPurge( "mysubma3.mac myparameter31 myparameter32" )
 // e.g. END
 //
 IF FNStringCheckEmptyB( macronameS )
  //
  PROCError( "macro should not be empty" )
  //
  RETURN()
  //
 ENDIF
 //
 IF FNMacroCheckLoadB( FNStringGetCarS( macronameS ) ) // necessary if you pass parameters in a string
  //
  PROCMacroExec( macronameS )
  //
  PROCMacroPurge( FNStringGetCarS( macronameS ) )
  //
 ENDIF
 //
 // PROCFileInsertStringEndFilenameDefault( macronameS ) // if you want to count the frequency a certain macro has been called
 //
END

// library: math: check: get: logic: false: wrapper <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checmalf.s) [<Program>] [<Research>] [kn, ri, su, 22-07-2001 15:43:08]
INTEGER PROC FNMathCheckGetLogicFalseB()
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckGetLogicFalseB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FALSE )
 //
END

// library: math: number: compare: equal: number1 EQUAL TO number2? <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checmane.s) [<Program>] [<Research>] [kn, ri, th, 03-05-2001 12:51:27]
INTEGER PROC FNMathCheckNumberEqualB( INTEGER x1, INTEGER x2 )
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckNumberEqualB( 3, 3 ) ) // gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( x1 == x2 )
 //
END

// library: window: check: scroll: horizontal <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checwisi.s) [<Program>] [<Research>] [kn, ri, sa, 21-05-2005 15:36:00]
INTEGER PROC FNWindowCheckScrollHorizontalB()
 // e.g. PROC Main()
 // e.g.  Message( FNWindowCheckScrollHorizontalB() ) // gives TRUE (that is, a non zero value) if the screen has scolled horizontally
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNWindowGetScrollHorizontalI() <> 0 )
 //
END

// library: text: get: position: window: column: current <description>position: line: column: get: (Get the Number of Current Column Position) N    *</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getteccw.s) [<Program>] [<Research>] [kn, zoe, we, 07-07-1999 19:21:23]
INTEGER PROC FNTextGetPositionWindowColumnCurrentI()
 // e.g. PROC Main()
 // e.g.  Message( FNTextGetPositionWindowColumnCurrentI() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( CurrCol() )
 //
END

// library: text: found: get: get found text <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getsttfo.s) [<Program>] [<Research>] [kn, zoe, tu, 19-10-1999 23:59:01]
STRING PROC FNStringGetTextFoundS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTextFoundS() ) // gives the currently found text
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 //  Returns the results of the immediately preceding find.
 //
 //  Syntax:     STRING GetFoundText([INTEGER tag_number])
 //
 //              Ã¹ tag_number is the optional tagged pattern number to return
 //
 //                from a regular expression search string.  If not passed, the
 //
 //                entire found string is returned.
 //
 //  Returns:    The found text.
 //
 //  Notes:      For this command to work properly, it should immediately follow a
 //
 //              Find() or lFind() command, before any other commands that might
 //
 //              change the current position are invoked.
 //
 //              The optional tag_number parameter only applies if a regular
 //
 //              expression find was performed.
 //
 //              For more information on regular expressions, see the chapter on
 //
 //              "Search Features:  Finding and Replacing Text" in the User's
 //
 //              Guide.
 //
 //  Examples:
 //
 //              string s[80]
 //
 //              if lFind("^a.*z$", "x")
 //
 //                  s = GetFoundText() // get the found text in s
 //
 //              endif
 //
 //  See Also:   lFind(), Find(), GetMarkedText(), MarkFoundText()
 //
 RETURN( GetFoundText() )
 //
END

// library: screen: get: window: column: total <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getsccto.s) [<Program>] [<Research>] [kn, ri, sa, 21-05-2005 15:29:22]
INTEGER PROC FNScreenGetWindowColumnTotalI()
 // e.g. PROC Main()
 // e.g.  Message( FNScreenGetWindowColumnTotalI() ) // gives e.g. 158 if there are 158 columns total in the current open TSE screen
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Query( windowCols ) )
 //
END

// library: screen: movement: scroll: left: N <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=scroscln.s) [<Program>] [<Research>] [kn, ni, sa, 02-11-2002 22:04:19]
PROC PROCScreenGotoScrollLeft_HorizontalN( INTEGER maxI )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "screen: movement: scroll: left: N: total = ", "5" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  PROCScreenGotoScrollLeft_HorizontalN( FNStringGetToIntegerI( s1 ) )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 ScrollLeft( maxI )
 //
END

// library: window: goto: scroll: horizontal: get the number of columns current window has scrolled horizontally <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getwisho.s) [<Program>] [<Research>] [kn, zoe, we, 16-06-1999 01:06:52]
INTEGER PROC FNWindowGetScrollHorizontalI()
 // e.g. PROC Main()
 // e.g.  Message( FNWindowGetScrollHorizontalI() ) // gives '0', if the screen has not scrolled horizontally. Gives e.g. 18 if the current screen has scroller 18 positions horizontally to the right
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( CurrXoffset() )
 //
END

// library: text: mark: hi: lite: found: Highlights Text Found by Most Recent Find Command <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=marktelf.s) [<Program>] [<Research>] [kn, zoe, we, 16-06-1999 01:06:56]
PROC PROCTextSelectMarkHiLiteFound()
 // e.g. PROC Main()
 // e.g.  PROCTextSelectMarkHiLiteFound()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 HiLiteFoundText()
 //
END

// library: record: movement: goto the start of a record: separator <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=gotorebt.s) [<Program>] [<Research>] [kn, zoe, mo, 11-12-2000 16:38:16]
INTEGER PROC FNRecordCheckGotoBeginSeparatorLineAfterBeginB()
 // e.g. PROC Main()
 // e.g.  Message( FNRecordCheckGotoBeginSeparatorLineAfterBeginB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER upB = FNMathCheckGetLogicTrueB()
 //
 INTEGER separatorB = FNMathCheckGetLogicFalseB()
 //
 WHILE ( FNMathCheckLogicNotB( separatorB ) ) AND upB
  //
  upB = FNCursorCheckGotoUpB()
  //
  separatorB = FNRecordCheckSeparatorLineB()
  //
 ENDWHILE
 //
 PROCTextGotoLineBegin()
 //
 IF upB PROCCursorGotoDown() ENDIF
 //
 IF separatorB RETURN( FNMathCheckGetLogicTrueB() ) ENDIF // if separator found, begin of record found
 //
 RETURN( FNFileCheckLineFirstB() ) // if no separator found, then the only possibility is the record separator is the first record of the file
 //
END

// library: record: movement: goto the end of a record: separator <description></description> <version control></version control> <version>1.0.0.0.4</version> (filenamemacro=gotorees.s) [<Program>] [<Research>] [kn, zoe, mo, 11-12-2000 16:38:16]
INTEGER PROC FNRecordCheckGotoLineEndSeparatorB()
 // e.g. PROC Main()
 // e.g.  Message( FNRecordCheckGotoLineEndSeparatorB() ) // gives e.g. TRUE, if cursor currently on a separator
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCMacroRunPurge( "recogont" ) // operation: goto: record: direction: next: windows: goto: top // new [kn, vo, we, 06-03-2013 13:46:31]
 //
 IF ( FNRecordCheckSeparatorLineB() )
  //
  PROCCursorGotoUp()
  //
 ELSE
  //
  PROCCursorGotoUp()
  PROCCursorGotoUp()
  //
 ENDIF
 //
 PROCTextGotoLineEnd()
 //
 RETURN( TRUE )
 //
END

// library: string: get: record: separator: begin: default <description></description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstbdh.s) [<Program>] [<Research>] [kn, ri, su, 06-11-2011 14:49:39]
STRING PROC FNStringGetRecordSeparatorBeginDefaultS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecordSeparatorBeginDefaultS() ) // gives e.g. "^"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetRecordSeparatorBeginDefaultS" ) )
 //
END

// library: string: get: record: separator: default <description></description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getstsds.s) [<Program>] [<Research>] [kn, zoe, fr, 17-11-2000 15:50:54]
STRING PROC FNStringGetRecordSeparatorDefaultS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecordSeparatorDefaultS() ) // gives e.g. "ÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃ"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( FNStringGetInStringS( 78, FNStringGetCharacterSymbolRecordSeparatorS() ) )
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetRecordSeparatorDefaultS" ) )
 //
END

// library: string: get: record: separator: end: default <description></description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstedi.s) [<Program>] [<Research>] [kn, ri, su, 06-11-2011 14:51:44]
STRING PROC FNStringGetRecordSeparatorEndDefaultS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecordSeparatorEndDefaultS() ) // gives e.g. "$"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetRecordSeparatorEndDefaultS" ) )
 //
END

// library: cursor: check: down: not <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checcudn.s) [<Program>] [<Research>] [kn, ni, mo, 05-05-2003 19:49:32]
INTEGER PROC FNCursorCheckDownNotB()
 // e.g. PROC Main()
 // e.g.  Message( FNCursorCheckDownNotB() ) // gives e.g. TRUE if the cursor could not be moved one line down
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckLogicNotB( FNCursorCheckGotoDownB() ) )
 //
END

// library: error <description>error: central routine</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=ererror.s) [<Program>] [<Research>] [[kn, ni, mo, 03-08-1998 13:08:12]
PROC PROCError( STRING s )
 // e.g. INTEGER ErrorGB = FNMathCheckGetLogicFalseB()
 // e.g. PROC Main()
 // e.g.  PROCError( "this is an error" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextSavePositionStackPush()
 //
 // Alarm()
 //
 // PROCWarn( s )
 //
 // Message( s )
 //
 // Message( "Linenr ", FNMathGetProgramLineNumberAbsoluteCurrentI(), ": ", s )
 //
 PROCWarnCons4( "Error: Linenr", FNStringGetLineNumberCurrentS(), ":", s )
 //
 // only when seriously: PROCFileInsertTextEnd( "line " + STR( FNMathGetProgramLineNumberAbsoluteCurrentI() ) + ": " + s, FNStringGetFilenameGlobalErrorS(), FNMathCheckGetLogicTrueB() )
 //
 PROCFileInsertTextEnd( "line " + STR( FNMathGetProgramLineNumberAbsoluteCurrentI() ) + ": " + s, FNStringGetFilenameGlobalErrorS(), FNMathCheckGetLogicTrueB() )
 //
 // errorGB = FNMathCheckGetLogicTrueB()
 //
 PROCTextRemovePositionStackPop()
 //
END

// library: macro: check: load <description>macro: load: (Loads a Macro File From Disk Into Memory) R    LoadMacro(STRING macro_filename)*</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checmacl.s) [<Program>] [<Research>] [[kn, zoe, we, 16-06-1999 01:07:06]
INTEGER PROC FNMacroCheckLoadB( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  Message( FNMacroCheckLoadB( macronameS ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( LoadMacro( macronameS ) )
 //
END

// library: string: get: word: token: get: first: FNStringGetCarS(): Get the first word of a string (words delimited by a space " " (=space delimited list)). <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstgca.s) [<Program>] [<Research>] [kn, ni, su, 02-08-1998 15:54:17]
STRING PROC FNStringGetCarS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: word: token: get: first: s = ", "this is a test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCarS( s1 ) ) // gives e.g. "this"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // variation: RETURN( FNStringGetTokenFirstS( s, " " ) )
 //
 RETURN( GetToken( s, " ", 1 ) ) // faster, but not central
 //
END

// library: macro: exec <description>macro: (Executes the Requested Macro) O    ExecMacro([<Program>] [<Research>] [STRING macroname])*</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=execmame.s) [[kn, zoe, we, 16-06-1999 01:06:54]
PROC PROCMacroExec( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  PROCMacroExec( "video" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNMacroCheckExecB( macronameS ) )
  //
  PROCWarnCons3( "macro", macronameS, ": could not be executed" )
  //
 ENDIF
 //
END

// library: macro: purge <description>macro: (Purges a Macro File From Memory) R    PurgeMacro(STRING s)*</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=purgmamp.s) [<Program>] [<Research>] [[kn, zoe, fr, 13-10-2000 19:09:32]
PROC PROCMacroPurge( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  PROCMacroPurge( macronameS )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNMacroCheckPurgeB( macronameS ) )
  //
  PROCWarnCons3( "macro", macronameS, ": could not be found" )
  //
 ENDIF
 //
END

// library: math: check: get: logic: true: wrapper <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checmalt.s) [<Program>] [<Research>] [kn, ri, su, 22-07-2001 15:43:12]
INTEGER PROC FNMathCheckGetLogicTrueB()
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckGetLogicTrueB() ) // gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( TRUE )
 //
END

// library: movement: line: up: go to the previous line <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checcucu.s) [<Program>] [<Research>] [kn, zoe, mo, 29-03-1999 20:34:26]
INTEGER PROC FNCursorCheckGotoUpB()
 // e.g. PROC Main()
 // e.g.  Message( FNCursorCheckGotoUpB() ) // gives e.g. TRUE when cursor successfully moved one line up
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Up() )
 //
END

// library: record: separator: line: is this a record separator line? <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checresl.s) [<Program>] [<Research>] [kn, zoe, fr, 01-12-2000 19:59:19]
INTEGER PROC FNRecordCheckSeparatorLineB()
 // e.g. PROC Main()
 // e.g.  Message( FNRecordCheckSeparatorLineB() ) // gives e.g. TRUE when the cursor is on a record separator line
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNTextCheckSeparatorLineB( FNStringGetRecordSeparatorDefaultS() ) )
 //
END

// library: text: goto: line: begin // goto begin of line (=column 1 of the current line). If the cursor is already at the beginning of the current line, zero is returned. See also: EndLine() <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=gotolibe.s) [<Program>] [<Research>] [kn, zoe, th, 17-06-1999 00:12:52]
PROC PROCTextGotoLineBegin()
 // e.g. PROC Main()
 // e.g.  PROCTextGotoLineBegin()
 // e.g. END
 //
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNLineCheckGotoBeginB() )
  //
  // PROCWarn( "Could not go to the beginning of the current line" )
  //
 ENDIF
 //
END

// library: file: check: line: first <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checfilp.s) [<Program>] [<Research>] [kn, zoe, mo, 11-12-2000 17:09:53]
INTEGER PROC FNFileCheckLineFirstB()
 // e.g. PROC Main()
 // e.g.  Message( FNFileCheckLineFirstB() ) // gives TRUE if cursor on first line of file
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckNumberIntegerEqualB( FNMathGetProgramLineNumberAbsoluteCurrentI(), FNFileGetLineFirstI() ) )
 //
END

// library: cursor: goto: up <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=gotocugu.s) [<Program>] [<Research>] [kn, zoe, tu, 15-06-1999 23:46:50]
PROC PROCCursorGotoUp()
 // e.g. PROC Main()
 // e.g.  PROCCursorGotoUp()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNCursorCheckGotoUpB() )
  //
  // PROCWarn( "Could not go up"  )
  //
 ENDIF
 //
END

// library: movement: line: goto the end of the line (one character past the last character <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=gotolien.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 13:36:32]
PROC PROCTextGotoLineEnd()
 // e.g. PROC Main()
 // e.g.  PROCTextGotoLineEnd()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNLineCheckGotoEndB() )
  //
  // PROCWarn( "could not go to the end of the line" )
  //
 ENDIF
 //
END

// library: file: get: ini: default: central <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getfiidf.s) [<Program>] [<Research>] [kn, ri, we, 31-12-2003 02:17:48]
STRING PROC FNStringGetFileIniDefaultS( STRING searchS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFileIniDefaultS( "path4dos" ) ) // gives e.g. "c:\4dos"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 // e.g.
 //
 // USAGE
 //
 // 1. -Choose a filename for your global variables initialization file
 //
 //    1. -E.g. default name is here
 //
 //         dddpath.ini
 //
 //    2. -You can set this name in a function in this library, if you
 //
 //        want to change the default name
 //
 // 3. -Save this file in the directory
 //
 //     (path chosen to be given by Microsoft Windows environment variable APPDATA)
 //
 //      C:\Documents and Settings\<your Microsoft Windows login name>\Application Data\
 //
 // 4. -The full path to your initialization file is thus e.g.
 //
 //      C:\Documents and Settings\Administrator\Application Data\dddpath.ini
 //
 // 5. -To keep things as simple as possible, you need to put once
 //
 //     in top of your file the word (which must start at the beginning
 //
 //     of the line). Further no more '[' characters starting at the begin of any line.
 //
 //      [default]
 //
 // 6. -This file contains 0 or more lines of the general format
 //
 //      <variable name> = <variable value>
 //
 //     1. -E.g.
 //
 //         [default]
 //
 //          path4dos = c:\4dos
 //
 //          tsevariable1 = test1
 //
 //          tsevariable2 = test2
 //
 //          tsevariable3 = test3
 //
 //          ...
 //
 //     2. -Note: you should/could put spaces before and after the '=' sign
 //
 //         (e.g. for backwards compatibility purposes)
 //
 // 7. -Using this library, you can then e.g. get the value of your global variable from this file
 //
 RETURN( FNStringGetFileGetFilenamePathDefaultS( searchS ) )
 //
END

// library: movement: line: down: go to the next line <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checcucd.s) [<Program>] [<Research>] [kn, zoe, we, 12-05-1999 15:49:40]
INTEGER PROC FNCursorCheckGotoDownB()
 // e.g. PROC Main()
 // e.g.  Message( FNCursorCheckGotoDownB() ) // gives e.g. TRUE when cursor successfully moved one line down
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Down() )
 //
END

// library: warn: cons4 <description>error: warning: give a warning message via 4 strings</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=conswawe.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 18:28:22]
PROC PROCWarnCons4( STRING s1, STRING s2, STRING s3, STRING s4 )
 // e.g. PROC Main()
 // e.g.  PROCWarnCons4( "error", "1", "2", "3" ) // gives e.g. "error 1 2 3"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCWarn( FNStringGetCons4S( s1, s2, s3, s4 ) )
 //
END

// library: string: get: line: number: current (return the current linenumber) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstncm.s) [<Program>] [<Research>] [kn, ni, mo, 02-08-1999 00:46:42]
STRING PROC FNStringGetLineNumberCurrentS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetLineNumberCurrentS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetMathIntegerToStringS( FNMathGetProgramLineNumberAbsoluteCurrentI() ) )
 //
END

// library: file: insert: text: end <description>file: line: text: insert: end: goto the end of the given file, insert some text (when newlineB is TRUE, start every inserted line on a new line)</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=insefite.s) [<Program>] [<Research>] [[kn, ni, mo, 03-08-1998 13:08:29]
PROC PROCFileInsertTextEnd( STRING s, STRING filenameS, INTEGER newlineB )
 // e.g. PROC Main()
 // e.g.  PROCFileInsertTextEnd( "this is put on the end of the file", "myoutputfile", FNMathCheckGetLogicTrueB() )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextSavePositionStackPush()
 //
 IF FNMathCheckLogicNotB( FNFileCheckEditMessageB( filenameS ) )
  //
  PROCTextRemovePositionStackPop()
  //
  RETURN()
  //
 ENDIF
 //
 PROCFileGotoEnd()
 //
 IF ( newlineB )
  //
  PROCFileInsertEndPrepare()
  //
 ENDIF
 //
 PROCTextInsert( s )
 //
 PROCTextRemovePositionStackPop()
 //
END

// library: math: get: program: line: number: absolute: current <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=getfincu.s) [<Program>] [<Research>] [kn, ni, mo, 02-08-1999 00:46:42]
INTEGER PROC FNMathGetProgramLineNumberAbsoluteCurrentI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetProgramLineNumberAbsoluteCurrentI() ) // gives e.g. 332 if the cursor is on line 332 in the current file
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 //                                                     |
 //                                                     ...
 // ÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÂ¿|
 // Â³                                                  Â³|
 // Â³                                                  Â³|
 // Â³                                                  Â³|
 // Â³                                                  Â³|
 // Â³                                                  Â³V
 // Â³cursor is here on this line                       Â³--- <-- CurrLine()
 // Â³                                                  Â³
 // Â³                                                  Â³
 // Â³[end of file]-------------------------------------Â³
 // Â³                                                  Â³
 // Â³                                                  Â³
 // Â³                                                  Â³
 // Â³                                                  Â³
 // Â³                                                  Â³
 // Â³                                                  Â³
 // Â³                                                  Â³
 // Â³                                                  Â³
 // Â³                                                  Â³
 // Â³                                                  Â³
 // Â³                                                  Â³
 // ÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃ
 //
 RETURN( CurrLine() )
 //
END

// library: string: get: filename: global: error <description></description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstget.s) [<Program>] [<Research>] [kn, zoe, fr, 20-10-2000 23:34:48]
STRING PROC FNStringGetFilenameGlobalErrorS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFilenameGlobalErrorS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetGlobalS( "filenameerrorGS" ) )
 //
END

// library: macro: check: exec <description>macro: (Executes the Requested Macro) O    ExecMacro([<Program>] [<Research>] [STRING macroname])*</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checmace.s) [[kn, zoe, we, 16-06-1999 01:06:54]
INTEGER PROC FNMacroCheckExecB( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  Message( FNMacroCheckExecB( macronameS ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( ExecMacro( macronameS ) )
 //
END

// library: warn: cons3 <description>error: warning: give a warning message via 3 strings</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=conswawd.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 18:24:52]
PROC PROCWarnCons3( STRING s1, STRING s2, STRING s3 )
 // e.g. PROC Main()
 // e.g.  PROCWarnCons3( "error", "1", "2" ) // gives e.g. "error 1 2"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCWarn( FNStringGetCons3S( s1, s2, s3 ) )
 //
END

// library: macro: check: purge <description>macro: purge</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checmacp.s) [<Program>] [<Research>] [[kn, zoe, fr, 13-10-2000 19:03:50]
INTEGER PROC FNMacroCheckPurgeB( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  Message( FNMacroCheckPurgeB( macronameS ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( PurgeMacro( macronameS ) )
 //
END

// library: text: separator: line: is this a text separator line? <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=chectesl.s) [<Program>] [<Research>] [kn, ni, sa, 11-10-2003 17:23:45]
INTEGER PROC FNTextCheckSeparatorLineB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckSeparatorLineB( "--- cut here" ) ) // gives e.g. TRUE when the cursor is on a record separator line
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( FNStringCheckEqualB( FNStringGetLineGetCurrentS(), s ) )
 //
 // RETURN( FNStringCheckEqualCharacterAllFrontNB( s, FNStringGetLineGetCurrentS() ) )
 //
 RETURN( FNStringCheckEqualB( s, FNStringGetLineGetCurrentS() ) )
 //
END

// library: line: check: goto: begin <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checligb.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 13:36:31]
INTEGER PROC FNLineCheckGotoBeginB() // version not central
 // e.g. PROC Main()
 // e.g.  Message( "Goto the beginning of the line = ", FNLineCheckGotoBeginB() )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( BegLine() )
 //
END

// library: math: number: compare: equal: are two given numbers equal? <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checmaie.s) [<Program>] [<Research>] [kn, zoe, fr, 01-12-2000 19:01:34]
INTEGER PROC FNMathCheckNumberIntegerEqualB( INTEGER x1, INTEGER x2 )
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckNumberIntegerEqualB( 3, 3 ) ) // gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckNumberEqualB( x1, x2 ) )
 //
END

// library: file: get: line: first (the number of the first line in the file) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getfilfi.s) [<Program>] [<Research>] [kn, ri, su, 17-10-1999 05:52:52]
INTEGER PROC FNFileGetLineFirstI()
 // e.g. PROC Main()
 // e.g.  Message( FNFileGetLineFirstI() ) // gives e.g. 1
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( 1 )
 //
END

// library: line: check: goto: end <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checlige.s) [<Program>] [<Research>] [kn, ni, su, 09-08-1998 18:00:41]
INTEGER PROC FNLineCheckGotoEndB()
 // e.g. PROC Main()
 // e.g.  Message( "Goto the end of the line = ", FNLineCheckGotoEndB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( EndLine() )
 //
END

// library: file: get: filename: path: default <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getfipde.s) [<Program>] [<Research>] [kn, ri, we, 31-12-2003 02:14:28]
STRING PROC FNStringGetFileGetFilenamePathDefaultS( STRING searchS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFileGetFilenamePathDefaultS( "path4dos" ) ) // gives e.g. "c:\4dos"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( FNStringGetFileGetFilenamePathS( searchS, FNStringGetFilenameIniDefaultS() ) ) // [kn, ri, mo, 22-05-2006 23:59:52]
 //
 RETURN( FNStringGetInitializationGlobalS( searchS, FNStringGetSectionSeparatorS(), FNStringGetFilenameIniDefaultS() ) )
 //
END

// library: string: get: cons4: string: concatenation: 4 strings <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstgcz.s) [<Program>] [<Research>] [kn, zoe, fr, 17-11-2000 13:54:56]
STRING PROC FNStringGetCons4S( STRING s1, STRING s2, STRING s3, STRING s4 )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCons4S( "a", "b", "c", "d" ) ) // gives e.g. "a b c d"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConsS( FNStringGetCons3S( s1, s2, s3 ), s4 ) )
 //
END

// library: string: get: math: get: integer: to: convert an integer to a string <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getsttsu.s) [<Program>] [<Research>] [number to string] [kn, ni, mo, 03-08-1998 00:34:05]
STRING PROC FNStringGetMathIntegerToStringS( INTEGER I )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetMathIntegerToStringS( 3 ) ) // gives e.g. "3"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Str( I ) )
 //
END

// library: file: edit: edit a file, with test of problems <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checficf.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 13:08:39]
INTEGER PROC FNFileCheckEditMessageB( STRING filenameS )
 // e.g. PROC Main()
 // e.g.  Message( FNFileCheckEditMessageB( "" ) ) // gives e.g. TRUE when file loaded without problems
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNFileCheckEditCentralMessageB( filenameS, FNMathCheckGetLogicTrueB() ) )
 //
END

// library: file: movement: end: goto end of file: moves to the end of the last line of current file <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=gotofien.s) [<Program>] [<Research>] [kn, ri, su, 28-03-1999 01:08:06]
PROC PROCFileGotoEnd()
 // e.g. PROC Main()
 // e.g.  PROCFileGotoEnd()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNFileCheckGotoEndB() )
  //
  // PROCWarn( "cursor was already in end file else error: could no go to end of file" )
  //
 ENDIF
 //
END

// library: file: insert: end: prepare <description>file: insert: prepare for the insertion (e.g. of text, of a new file, ...)</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=insefiep.s) [<Program>] [<Research>] [[kn, zoe, th, 25-01-2001 18:03:46]
PROC PROCFileInsertEndPrepare()
 // e.g. PROC Main()
 // e.g.  PROCFileInsertEndPrepare()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCFileGotoEnd()
 //
 PROCLineInsertAfter()
 //
 PROCTextGotoLineBegin()
 //
END

// library: text: insert: insert text <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=insetein.s) [<Program>] [<Research>] [kn, ni, mo, 10-08-1998 06:26:51]
PROC PROCTextInsert( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "which text to insert at current position = ", FNStringGetEmptyS() )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  PROCTextInsert( s )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNStringCheckEmptyB( s )
  //
  // PROCerror( FNStringGetFilenameCurrentS() + ": Attempt made to insert an empty string" )
  //
  RETURN()
  //
 ENDIF
 //
 IF FNMathCheckLogicNotB( FNTextCheckInsertB( s ) )
  //
  PROCerror( FNStringGetCons4S( FNStringGetFilenameCurrentS(), ": Text '", s, "' could not be inserted" ) )
  //
 ENDIF
 //
END

// library: string: get: global <description>string: global: get: get a global string</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstggl.s) [<Program>] [<Research>] [[kn, zoe, mo, 14-06-1999 20:54:18]
STRING PROC FNStringGetGlobalS( STRING stringglobalnameS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetGlobalS( "dirGS" ) ) // e.g. gives "c:\"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetGlobalS( "dir1GS" ) ) // indicates first that this string does not exist, and returns the result '<VARIABLE NOT KNOWN>'.
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 IF FNMathCheckLogicNotB( ExistGlobalVar( stringglobalnameS ) )
  //
  PROCWarnCons5( "file", FNStringGetFilenameCurrentS(), ":", stringglobalnameS, ": this string is not known to this macro (suggestion: execute 'initglobal.mac' (or 'i.m') for this macro)" )
  //
  RETURN( FNStringGetErrorS() )
  //
 ENDIF
 //
 s = GetGlobalStr( stringglobalnameS )
 //
 RETURN( s )
 //
END

// library: string: get: cons3: string: concatenation: 3 strings <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstgcy.s) [<Program>] [<Research>] [kn, zoe, fr, 17-11-2000 13:52:07]
STRING PROC FNStringGetCons3S( STRING s1, STRING s2, STRING s3 )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCons3S( "a", "b", "c" ) ) // gives e.g. "a b c"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConsS( FNStringGetConsS( s1, s2 ), s3 ) )
 //
END

// library: string: get: line: get: current <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstgck.s) [<Program>] [<Research>] [kn, ri, sa, 05-12-1998 22:27:51]
STRING PROC FNStringGetLineGetCurrentS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetLineGetCurrentS() ) // get text of current line
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 PROCSituationStoreOld()
 //
 PROCBlockSelectClearMark()
 //
 // variation: PROCTextGotoLineBegin() PROCTextSelectMarkCharacter() PROCTextGotoLineEnd() PROCTextSelectMarkCharacter()
 //
 // variation: PROCTextGotoLineBegin() MarkColumn() PROCTextGotoLineEnd()
 //
 PROCLineSelectMarkCurrent()
 //
 s = FNStringGetTextMarkS()
 //
 PROCSituationRestoreOld()
 //
 RETURN( s )
 //
END

// library: string: get: initialization: global <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstigl.s) [<Program>] [<Research>] [kn, ri, mo, 22-05-2006 23:44:33]
STRING PROC FNStringGetInitializationGlobalS( STRING searchS, STRING sectionS, STRING fileNameS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetInitializationGlobalS( "path4dos", "default", FNStringGetFilenameIniDefaultS() ) ) // e.g. gives "c:\4dos"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( GetProfileStr( sectionS, searchS, FNStringGetEmptyS(), fileNameS ) )
 //
END

// library: string: get: section: separator <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstssh.s) [<Program>] [<Research>] [kn, ri, mo, 22-05-2006 23:43:21]
STRING PROC FNStringGetSectionSeparatorS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSectionSeparatorS() ) // gives e.g. "default"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "default" ) // you can not put this in the initialization file, because this actually determines the default section of that file itself. Possibly pass it as a command line parameter
 //
END

// library: filename: get: filename: ini: default <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getfiide.s) [<Program>] [<Research>] [kn, ri, we, 31-12-2003 02:15:47]
STRING PROC FNStringGetFilenameIniDefaultS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFilenameIniDefaultS() ) // gives e.g. "c:\documents and settings\administrator\application data\dddpath.ini"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( "c:\dddpath.ini" )
 //
 RETURN( FNStringGetConcatS( FNStringGetPathUser_DataApplicationCurrentBackslashS(), FNStringGet_FilenameIniDefaultS() ) )
 //
END

// library: string: get: cons: string: concatenation: concatenation 2 words to 1 word (separated by a space) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstgcx.s) [<Program>] [<Research>] [kn, ri, we, 25-11-1998 20:15:03]
STRING PROC FNStringGetConsS( STRING s1, STRING s2 ) // version with test if string empty
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConsS( "john", "doe" ) ) // gives "john doe"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatSeparatorS( s1, s2, FNStringGetCharacterSymbolSpaceS() ) )
 //
END

// library: file: check: edit: central: message <description></description> <version control></version control> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checfiex.s) [<Program>] [<Research>] [kn, ho, mo, 17-04-2006 17:41:21]
INTEGER PROC FNFileCheckEditCentralMessageB( STRING filenameS, INTEGER messageB )
 // e.g. PROC Main()
 // e.g.  Message( FNFileCheckEditCentralMessageB( "test.dok", FNMathCheckGetLogicFalseB() ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER editfileB = FNMathCheckGetLogicFalseB()
 //
 STRING s[255] = ""
 //
 if FNStringCheckEmptyB( filenameS )
  //
  editfileB = EditFile()
  //
 ELSE
  //
  editfileB = EditFile( filenameS )
  //
 ENDIF
 //
 IF FNMathCheckLogicNotB( editfileB )
  //
  IF messageB
   //
   PROCErrorFileNotFound( filenameS )
   //
  ENDIF
  //
 ENDIF
 //
 s = CurrFileName()
 //
 PROCMacroRunPurgeParameter( "runprmcn", Format( FNStringGetMachineNameS(), ";", FNStringGetUserNameFirstS(), ";", FNStringGetUserNameLastS(), ";", FNStringGetPortS(), ";", "TSE%3A+File%3A+Load%3A+" + s + "&submit01=Create" ) )
 //
 RETURN( editfileB )
 //
END

// library: file: check: goto: end <description>file: movement: end: goto end of file: moves to the end of the last line of current file</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checfigs.s) [<Program>] [<Research>] [[kn, ri, su, 28-03-1999 01:08:06]
INTEGER PROC FNFileCheckGotoEndB()
 // e.g. PROC Main()
 // e.g.  Message( FNFileCheckGotoEndB() )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( EndFile() )
 //
END

// library: line: insert: inserts 1 line after current line. The cursor is placed on the newly created line. The cursor column does not change <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=inseliaf.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 13:35:30]
PROC PROCLineInsertAfter()
 // e.g. PROC Main()
 // e.g.  PROCLineInsertAfter()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCLineInsertAfterLineGotoBeginTextInsert( FNStringGetEmptyS() )
 //
END

// library: text: check: insert <description>text: insert: insert text</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checteci.s) [<Program>] [<Research>] [[kn, zoe, tu, 23-11-1999 20:30:45]
INTEGER PROC FNTextCheckInsertB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckInsertB( s ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNTextCheckInsertCentralB( s, _INSERT_ ) )
 //
END

// library: file: filename: get: current: return current filename (as a string containing the complete path) (Get Full Name of Current Buffer) (nofilenamemacro) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstfcv.s) [<Program>] [<Research>] [kn, ni, sa, 08-08-1998 00:02:37] [FNfilenamecurrent]
STRING PROC FNStringGetFilenameCurrentS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFilenameCurrentS() ) // gives e.g. "c:\wordproc\tse\ddd.ddd"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( CurrFilename() )
 //
END

// library: string: get: initialize: new: string <description>string: initialize</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstnsa.s) [<Program>] [<Research>] [[kn, ri, mo, 09-07-2001 12:00:07]
STRING PROC FNStringGetInitializeNewStringS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetInitializeNewStringS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetEmptyS() )
 //
END

// library: warn: cons5 <description>error: warning: give a warning message via 5 strings</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=conswawf.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 18:57:23]
PROC PROCWarnCons5( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5 )
  // e.g. PROC Main()
 // e.g.  PROCWarnCons5( "error", "1", "2", "3", "4" ) // gives e.g. "error 1 2 3 4"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCWarn( FNStringGetCons5S( s1, s2, s3, s4, s5 ) )
 //
END

// library: string: get: error <description>general output string to recognize an error (e.g. in another routine). Central routine, only one occurrence of this constant string</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstger.s) [<Program>] [<Research>] [kn, ri, sa, 05-12-1998 20:58:17]
STRING PROC FNStringGetErrorS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetErrorS() ) // gives e.g. "<ERROR>"
 // e.g. END
 //
 RETURN( "<ERROR>" )
 //
END

// library: push/pop: situation: store (blockpush, positionpush) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=storsiso.s) [<Program>] [<Research>] [kn, zoe, tu, 18-07-2000 14:21:42]
PROC PROCSituationStoreOld()
 // e.g. PROC Main()
 // e.g.  PROCSituationStoreOld()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCBlockSaveStackPush()
 //
 PROCTextSavePositionStackPush()
 //
END

// library: line: mark: mark all the characters in the current line (e.g. 2040 characters) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=marklinc.s) [<Program>] [<Research>] [kn, zoe, mo, 14-06-1999 22:07:35]
PROC PROCLineSelectMarkCurrent()
 // e.g. PROC Main()
 // e.g.  PROCLineSelectMarkCurrent()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCBlockSelectClearMark() // unmark any existing block, as it is overruled by the current marking anyhow
 //
 IF FNMathCheckLogicNotB( FNLineCheckSelectMarkB() )
  //
  PROCWarn( "Marking the current line was not successful" )
  //
 ENDIF
 //
END

// library: text: mark: get: (Copies Marked Block into String) N    * <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getsttma.s) [<Program>] [<Research>] [kn, zoe, we, 16-06-1999 01:06:55]
STRING PROC FNStringGetTextMarkS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTextMarkS() ) // // gives the currently marked text
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( GetMarkedText() )
 //
END

// library: push/pop: situation: store (blockpush, positionpush) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=restsiro.s) [<Program>] [<Research>] [kn, zoe, tu, 18-07-2000 14:21:42]
PROC PROCSituationRestoreOld()
 // e.g. PROC Main()
 // e.g.  PROCSituationRestoreOld()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextRemovePositionStackPop()
 //
 PROCBlockRemoveStackPop()
 //
END

// library: string: get: concat <description>concatenation 2 words tot 1 word</description> <version>1.0.0.0.2</version> (filenamemacro=getstgch.s) [<Program>] [<Research>] [kn, zoe, th, 01-02-2001 19:32:49]
STRING PROC FNStringGetConcatS( STRING s1, STRING s2 ) // version with test if string empty
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConcatS( "test1", "test2" ) ) // version with test if string empty ) // gives e.g. "test1test2"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatSeparatorS( s1, s2, FNStringGetEmptyS() ) )
 //
END

// library: string: get: path: user: data: application: current: backslash <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstcbe.s) [<Program>] [<Research>] [kn, ri, sa, 21-02-2004 23:01:06]
STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetPathUser_DataApplicationCurrentBackslashS() ) // gives e.g. "c:\documents and settings\administrator\application data\" (this is a hidden directory)
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFilenameEndBackSlashNotEqualInsertEndS( FNStringGetPathUser_DataApplicationCurrentBackslashNotS() ) )
 //
END

// library: string: get: filename: ini: default <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstide.s) [<Program>] [<Research>] [kn, ri, sa, 21-02-2004 22:54:12]
STRING PROC FNStringGet_FilenameIniDefaultS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGet_FilenameIniDefaultS() ) // gives e.g. "dddpath.ini"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "dddpath.ini" ) // you can not put this in the global initialization file, because this actually determines the name of that file itself. You could overrule this by passing the filename as a parameter on the command line. (if ( parameter is empty ) then ( defaultfilename = dddpath.ini ), else ( defaultfilename = <that command line parameter> ) )
 //
END

// library: string: get: concat: separator: string: concatenation: concatenate 2 words to 1 word, separated by separator <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstcsg.s) [<Program>] [<Research>] [kn, zoe, th, 01-07-1999 01:33:18]
STRING PROC FNStringGetConcatSeparatorS( STRING s1, STRING s2, STRING separatorS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConcatSeparatorS( "test1", "test2", " " ) ) // gives e.g. "tes1 test2"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNStringCheckEmptyB( s1 ) RETURN( s2 ) ENDIF
 //
 IF FNStringCheckEmptyB( s2 ) RETURN( s1 ) ENDIF
 //
 RETURN( s1 + separatorS + s2 ) // leave this like this. Do not call a function, as this is a primitive function, you will get into a recursive loop, and get stack overflow
 //
END

// library: string: get: character: symbol: " " <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstssp.s) [<Program>] [<Research>] [kn, zoe, we, 25-10-2000 01:33:39]
STRING PROC FNStringGetCharacterSymbolSpaceS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterSymbolSpaceS() ) // gives " "
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterSymbolCentralS( 32 ) )
 //
END

// library: error: file: not: found <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=fileernf.s) [<Program>] [<Research>] [kn, ri, we, 28-02-2001 23:02:12]
PROC PROCErrorFileNotFound( STRING filenameS )
 // e.g. PROC Main()
 // e.g.  PROCErrorFileNotFound( "xsefadafadfasdf.sdfa" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 IF FNErrorCheckEscapeB( filenameS )
  //
  s = FNStringGetConsS( FNStringGetEscapeS(), "has been pressed" )
  //
 ELSE
  //
  s = FNStringGetCons3S( "file: ", filenameS, "not found / path does not exist" )
  //
 ENDIF
 //
 PROCError( s )
 //
END

// library: macro: run: purge: parameter <description>macro: run a macro, then purge it, pass parameter string</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=runmappa.s) [<Program>] [<Research>] [[kn, ri, sa, 17-02-2001 02:22:27]
PROC PROCMacroRunPurgeParameter( STRING macronameS, STRING commandlineparameterS )
 // e.g. PROC Main()
 // e.g.  PROCMacroRunPurgeParameter( macronameS, commandlineparameterS )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCMacroRunPurge( FNStringGetConsS( macronameS, commandlineparameterS ) )
 //
END

// library: string: get: machine: name <description></description> <version control></version control> <version>1.0.0.0.12</version> (filenamemacro=getstmnc.s) [<Program>] [<Research>] [kn, ri, we, 16-06-2010 22:41:10]
STRING PROC FNStringGetMachineNameS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetMachineNameS() ) // gives e.g. "mcnlken01" or "localhost"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetMachineNameS" ) )
 //
END

// library: string: get: user: name: first <description></description> <version control></version control> <version>1.0.0.0.12</version> (filenamemacro=getstnfi.s) [<Program>] [<Research>] [kn, ri, we, 16-06-2010 22:40:16]
STRING PROC FNStringGetUserNameFirstS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetUserNameFirstS() ) // gives e.g. "knud"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetUserNameFirstS" ) )
 //
END

// library: string: get: user: name: last <description></description> <version control></version control> <version>1.0.0.0.4</version> (filenamemacro=getstnla.s) [<Program>] [<Research>] [kn, ri, we, 16-06-2010 22:40:40]
STRING PROC FNStringGetUserNameLastS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetUserNameLastS() ) // gives e.g. "van eeden"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetUserNameLastS" ) )
 //
END

// library: string: get: port: name <description></description> <version control></version control> <version>1.0.0.0.4</version> (filenamemacro=getstpnc.s) [<Program>] [<Research>] [kn, ri, sa, 24-07-2010 21:52:33]
STRING PROC FNStringGetPortS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetPortS() ) // gives e.g. "80"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetPortS" ) )
 //
END

// library: line: insert: after: line: goto: begin: text: insert <description>line insert after: insert text at first column (text: insert: after each other)</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=inselitj.s) [<Program>] [<Research>] [[kn, zoe, we, 28-02-2001 20:24:53]
PROC PROCLineInsertAfterLineGotoBeginTextInsert( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCLineInsertAfterLineGotoBeginTextInsert( s )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // variation: PROCLineInsertAfter() PROCLineGotoBeginTextInsert( s )
 //
 IF FNMathCheckLogicNotB( FNLineCheckInsertAfterLineGotoBeginTextInsertB( s ) )
  //
  // PROCWarn( "line could not be inserted" )
  //
 ENDIF
 //
END

// library: text: check: insert: central <description>text: insert: insert text: central</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checteic.s) [<Program>] [<Research>] [[kn, ri, fr, 16-02-2001 22:00:44]
INTEGER PROC FNTextCheckInsertCentralB( STRING s, INTEGER optionB )
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckInsertCentralB( s, optionB ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( InsertText( s, optionB ) )
 //
END

// library: string: get: cons5: string: concatenation: 5 strings <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstgcb.s) [<Program>] [<Research>] [kn, zoe, fr, 17-11-2000 13:55:03]
STRING PROC FNStringGetCons5S( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5 )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCons5S( "a", "b", "c", "d", "e" ) ) // gives e.g. "a b c d e"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConsS( FNStringGetCons4S( s1, s2, s3, s4 ), s5 ) )
 //
END

// library: block: save: stack: push: use this when you want to restore your old block position: store old (Saves Current Block Status on Marked Block Stack) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=saveblsp.s) [<Program>] [<Research>] [kn, zoe, fr, 04-06-1999 22:22:42]
PROC PROCBlockSaveStackPush()
 // e.g. PROC Main()
 // e.g.  PROCBlockSaveStackPush()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PushBlock() // returns no result
 //
END

// library: line: mark: mark the current line <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checlicm.s) [<Program>] [<Research>] [kn, zoe, mo, 14-06-1999 22:07:35]
INTEGER PROC FNLineCheckSelectMarkB()
 // e.g. PROC Main()
 // e.g.  Message( FNLineCheckSelectMarkB() ) // gives e.g. TRUE, and marks
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNLineCheckSelectMarkLineBeginEndB( FNMathGetProgramLineNumberAbsoluteCurrentI(), FNMathGetProgramLineNumberAbsoluteCurrentI() ) )
 //
END

// library: block: remove: stack: pop: use this when you want to restore your old block position: get old (Unmarks Current Block and Marks Block From Stack) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=remoblsp.s) [<Program>] [<Research>] [kn, zoe, fr, 04-06-1999 22:22:42]
PROC PROCBlockRemoveStackPop()
 // e.g. PROC Main()
 // e.g.  PROCBlockRemoveStackPop()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PopBlock() // does not return a result
 //
END

// library: string: get: filename: end: back: slash: not: equal: insert: end <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstiep.s) [<Program>] [<Research>] [kn, ni, su, 17-08-2003 00:24:04]
STRING PROC FNStringGetFilenameEndBackSlashNotEqualInsertEndS( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFilenameEndBackSlashNotEqualInsertEndS( 'c:\temp\ddd' ) ) // gives e.g. a string 'c:\temp\ddd\' (so with always a string with a backslash '\' at the end)
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterEndBackSlashNotEqualInsertEndS( s ) )
 //
END

// library: string: get: path: user: data: application: current <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstacu.s) [<Program>] [<Research>] [kn, ri, sa, 21-02-2004 22:50:55]
STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashNotS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetPathUser_DataApplicationCurrentBackslashNotS() ) // gives e.g. "c:\documents and settings\administrator\application data" (this is a hidden directory)
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetEnvironmentS( "APPDATA" )
 //
 IF FNStringCheckEnvironmentFoundNotB( s )
  //
  PROCWarnCons3( "current user path to application data", s, ": not found" )
  //
  s = FNStringGetErrorS()
  //
 ENDIF
 //
 RETURN( s )
 //
END

// library: string: get: character: symbol: central <description>string: get: character: symbol: central</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstscm.s) [<Program>] [<Research>] [[kn, ri, sa, 07-07-2001 22:35:39]
STRING PROC FNStringGetCharacterSymbolCentralS( INTEGER I )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterSymbolCentralS( I ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetAsciiToCharacterS( I ) )
 //
END

// library: error: check: escape <description>escape or error</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=checerce.s) [<Program>] [<Research>] [[kn, zoe, th, 09-11-2000 23:18:32]
INTEGER PROC FNErrorCheckEscapeB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNErrorCheckEscapeB( "<ESCAPE>" ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNErrorCheckSB( s ) RETURN( FNMathCheckGetLogicTrueB() ) ENDIF
 //
 IF FNKeyCheckPressEscapeB( s ) RETURN( FNMathCheckGetLogicTrueB() ) ENDIF
 //
 RETURN( FNMathCheckGetLogicFalseB() )
 //
END

// library: line insert after: insert text at first column <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=inseliti.s) [<Program>] [<Research>] [kn, zoe, we, 28-02-2001 20:24:53]
INTEGER PROC FNLineCheckInsertAfterLineGotoBeginTextInsertB( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "line insert after: insert text at first column: s = ", "test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNLineCheckInsertAfterLineGotoBeginTextInsertB( s1 ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( AddLine( s ) )
 //
 RETURN( FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( s, FNBufferGetBufferIdFileCurrentI() ) )
 //
END

// library: line: check: select: mark: line: begin: end <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checlibf.s) [<Program>] [<Research>] [kn, ri, su, 13-11-2005 00:33:54]
INTEGER PROC FNLineCheckSelectMarkLineBeginEndB( INTEGER rowBeginI, INTEGER rowEndI )
 // e.g. PROC Main()
 // e.g.  Message( FNLineCheckSelectMarkLineBeginEndB( CurrLine(), CurrLine() ) ) // marks current line, and gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( MarkLine( rowBeginI, rowEndI ) )
 //
END

// library: string: get: backslash: if last character is not equal to '\', then concatenate a backslash to the end of the given string <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstien.s) [<Program>] [<Research>] [kn, ri, sa, 24-02-2001 23:48:15]
STRING PROC FNStringGetCharacterEndBackSlashNotEqualInsertEndS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: backslash: if: not equal insert end: string = ", "this is a string without a backslash at end" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCharacterEndBackSlashNotEqualInsertEndS( s1 ) ) // gives e.g. "this is a string with a backslash at end\"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterInsertEndIfEqualNotS( s, FNStringGetCharacterSymbolSlashBackwardS() ) )
 //
END

// library: environment: string: get (Searches for and Returns a Specified Environment Str) R    GetEnvStr(STRING s)* <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=getstgen.s) [<Program>] [<Research>] [kn, ri, th, 25-10-2001 01:44:48]
STRING PROC FNStringGetEnvironmentS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInputS( "value: environment variable = ", "windir" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  PROCMessageCons3( s, "=", FNStringGetEnvironmentS( s ) ) // gives e.g. "windir=C:\WINNT", when working on a Windows2000 machine
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING valueS[255] = GetEnvStr( s )
 //
 IF FNStringCheckEmptyB( valueS )
  //
  // PROCMessageCons3( "environment variable", s, ": not found" ) // old [kn, vo, fr, 08-02-2013 10:14:48]
  //
  valueS = FNStringGetErrorS()
  //
 ENDIF
 //
 RETURN( valueS )
 //
END

// library: environment: check: found: not <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checenfn.s) [<Program>] [<Research>] [kn, ri, sa, 27-05-2006 20:20:03]
INTEGER PROC FNStringCheckEnvironmentFoundNotB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckEnvironmentFoundNotB( FNStringGetEmptyS() ) ) // gives TRUE (thus not found) because string empty (or string error string)
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualErrorOrEmptyB( s ) )
 //
END

// library: string: get: ascii: to: character (given the ASCII value, what is the corresponding character? (Get Single Character Equivalent of an Integer). Syntax: Chr(INTEGER i)*) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getsttch.s)  [<Program>] [<Research>] [kn, zoe, we, 16-06-1999 01:06:51]
STRING PROC FNStringGetAsciiToCharacterS( INTEGER asciiI )
 // e.g. PROC Main()
 // e.g.  Warn( FNStringGetAsciiToCharacterS( 65 ) ) // gives "A"
 // e.g.  Warn( FNStringGetAsciiToCharacterS( 66 ) ) // gives "B"
 // e.g.  Warn( FNStringGetAsciiToCharacterS( 100 ) ) // gives "d"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Chr( asciiI ) ) // leave this keyword, otherwise possibly recursive stack overflow
 //
END

// library: error: check <description>error: test if an error occurred, via testing the output // version with testing local variable. Better.</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checercs.s) [<Program>] [<Research>] [[kn, ni, we, 05-08-1998 20:27:34]
INTEGER PROC FNErrorCheckSB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNErrorCheckSB( "this is an error" ) // version with testing local variable. Better. ) // gives ...
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( s, FNStringGetErrorS() ) )
 //
END

// library: file: check: insert: line: after: line: goto: begin: text: insert: line insert after: insert text at first column (Add Line After Current Line). Syntax: AddLine( <STRING text <, INTEGER bufferid > > ). If the optional bufferid is specified, the line is added after the current line in the specified buffer. _ON_CHANGING_FILES_ hooks are not invoked by this command <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checfiti.s) [<Program>] [<Research>] [kn, zoe, we, 28-02-2001 20:24:53]
INTEGER PROC FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( STRING s, INTEGER bufferid )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "line insert after: insert text at first column: s = ", "test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "line insert after: insert text at first column: bufferID = ", FNStringGetMathIntegerToStringS( FNBufferGetBufferIdFileCurrentI() ) )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( s1, FNStringGetToIntegerI( s2 ) ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( AddLine( s, bufferid ) ) // s is the string that will be inserted at column 1 of the newly created line. BufferidI is the optional id of the file where the line is to be added. If not passed, the line is added to the current file.
 //
END

// library: buffer: get: id: current ((Returns the Unique Id of Requested or Current Buffer) O GetBufferId([<Program>] [<Research>] [STRING name])*) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getbuicu.s) [kn, zoe, th, 25-01-2001 11:12:56]
INTEGER PROC FNBufferGetBufferIdFileCurrentI()
 // e.g. PROC Main()
 // e.g.  Message( FNBufferGetBufferIdFileCurrentI() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNBufferGetBufferIdGivenBufferNameI( FNStringGetFilenameCurrentS() ) )
 //
END

// library: compare if string end is equal, if not so insert that string at the end <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstenp.s) [<Program>] [<Research>] [kn, ri, sa, 24-02-2001 23:06:33]
STRING PROC FNStringGetCharacterInsertEndIfEqualNotS( STRING inS, STRING tailS )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: insert: insert: string = ", "c:\kee" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "string: insert: insert: frontS = ", "\" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCharacterInsertEndIfEqualNotS( s1, s2 ) ) // gives e.g. "c:\kee\"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetCharacterInsertEndIfEqualNotS( "c", ":" ) ) // gives "c:"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetCharacterInsertEndIfEqualNotS( "c:", ":" ) ) // gives "c:"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetCharacterInsertEndIfEqualNotS( "c:\kee", FNStringGetCharacterSymbolSlashBackwardS() ) ) // gives "c:\kee\"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = inS
 //
 IF FNMathCheckLogicNotB( FNStringCheckEqualCharacterLastNB( s, tailS ) )
  //
  // s = FNStringGetConcatS( s, tailS )
  //
  s = FNStringGetConcatTailS( s, tailS )
  //
 ENDIF
 //
 RETURN( s )
 //
END

// library: string: get: character: symbol: "\" <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstsba.s) [<Program>] [<Research>] [kn, ri, su, 29-07-2001 15:41:11]
STRING PROC FNStringGetCharacterSymbolSlashBackwardS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterSymbolSlashBackwardS() ) // gives "\"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterSymbolCentralS( 92 ) )
 //
END

// library: environment: check: found: not <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checenfn.s) [<Program>] [<Research>] [kn, ri, sa, 27-05-2006 20:20:03]
INTEGER PROC FNStringCheckEqualErrorOrEmptyB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckEqualErrorOrEmptyB( FNStringGetEmptyS() ) ) // gives TRUE if string empty or string equals error string
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckLogicOrB( FNErrorCheckSB( s ), FNStringCheckEmptyB( s ) ) )
 //
END

// library: buffer: get: buffer: id: given: buffer: name (Returns the Unique Id of Requested or Current Buffer) O GetBufferId([<Program>] [<Research>] [STRING name])*  <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getbubna.s) [kn, zoe, th, 25-01-2001 11:12:23]
INTEGER PROC FNBufferGetBufferIdGivenBufferNameI( STRING bufferNameS )
 // e.g. PROC Main()
 // e.g.  Message( FNBufferGetBufferIdGivenBufferNameI( "test" ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( GetBufferId( bufferNameS ) )
 //
END

// library: string: word: equal: last: compare if a given string is equal at the end to another given string <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checstln.s) [<Program>] [<Research>] [kn, zoe, we, 29-11-2000 19:08:34]
INTEGER PROC FNStringCheckEqualCharacterLastNB( STRING s, STRING tailS ) // version: first parameter s then endS
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckEqualCharacterLastNB( "knud", "d" ) ) //  gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( FNStringGetRightStringLengthEqualS( s, tailS ), tailS ) )
 //
END

// library: string: get: concat: tail: suffix <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstctb.s) [<Program>] [<Research>] [kn, ri, su, 02-09-2001 03:08:08]
STRING PROC FNStringGetConcatTailS( STRING s, STRING tailS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConcatTailS( "Knu", "d" ) ) // gives e.g. "Knud"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatS( s, tailS ) )
 //
END

// library: math: check: logic: or: 2 arguments <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checmalo.s) [<Program>] [<Research>] [kn, ri, tu, 15-05-2001 16:54:17]
INTEGER PROC FNMathCheckLogicOrB( INTEGER B1, INTEGER B2 )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "math: check: logic: or: number1 = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "math: check: logic: or: number2 = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNMathCheckLogicOrB( FNStringGetToIntegerI( s1 ), FNStringGetToIntegerI( s2 ) ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF ( B1 )
  //
  RETURN( FNMathCheckGetLogicTrueB() )
  //
 ENDIF
 //
 IF ( B2 )
  //
  RETURN( FNMathCheckGetLogicTrueB() )
  //
 ENDIF
 //
 RETURN( FNMathCheckGetLogicFalseB() )
 //
END

// library: STRING: get: right: string: length: equal <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstler.s) [<Program>] [<Research>] [kn, ni, su, 30-11-2003 23:32:40]
STRING PROC FNStringGetRightStringLengthEqualS( STRING s, STRING tailS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRightStringLengthEqualS( "Knud van Eeden", "12345" ) ) // gives e.g. "Eeden"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetRightStringS( s, FNStringGetLengthI( tailS ) ) )
 //
END

// library: string: get: word: token: last: return a given integer amount of characters from the right of a given string (=RIGHT$ in BASIC) <description></description> <version control></version control> <version>1.0.0.0.12</version> (filenamemacro=stririrs.s) [<Program>] [<Research>] [kn, ri, tu, 13-10-1998 20:05:49]
STRING PROC FNStringGetRightStringS( STRING s, INTEGER totalI )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING charactertotalS[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: word: token: get: right: string = ", "knud" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  charactertotalS = FNStringGetInputS( "string: word: token: get: right: character total = ", "2" )
 // e.g.  IF FNKeyCheckPressEscapeB( charactertotalS ) RETURN() ENDIF
 // e.g.  Message( FNStringGetRightStringS( s, FNStringGetToIntegerI( charactertotalS ) ) ) //  gives e.g. "kn"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetRightStringS( "knud", 1 ) ) // gives "d"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetRightStringS( "knud", 2 ) ) // gives "ud"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetRightStringS( "best", 3 ) ) // gives "est"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER lengthI = FNStringGetLengthI( s )
 //
 IF FNMathCheckLogicNotB( ( ( 0 <= totalI ) AND ( totalI <= lengthI ) ) ) // if not between 0 and length( string ), return the whole given string
  //
  totalI = lengthI
  //
 ENDIF
 //
 RETURN( FNStringGetMidStringS( s, 1 + lengthI - totalI, lengthI ) )
 //
END

// library: string: get: mid: string <description></description> <version control>string: get: word: token: middle: return a given integer amount of characters from the a given startposition</version control> <version>1.0.0.0.12</version> (=MID$ in BASIC) <version>1.0.0.0.12</version> (filenamemacro=getstmid.s) [<Program>] [<Research>] [kn, ri, tu, 13-10-1998 20:29:00]
STRING PROC FNStringGetMidStringS( STRING s, INTEGER beginI, INTEGER totalI )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING positionBeginS[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING characterTotalS[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: get: MIDSTRING: string = ", "testing" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  positionBeginS = FNStringGetInputS( "string: get: MIDSTRING: beginposition = ", "2" )
 // e.g.  IF FNKeyCheckPressEscapeB( positionBeginS ) RETURN() ENDIF
 // e.g.  characterTotalS = FNStringGetInputS( "string: get: MIDSTRING: character total = ", "3" )
 // e.g.  IF FNKeyCheckPressEscapeB( characterTotalS ) RETURN() ENDIF
 // e.g.  Message( FNStringGetMidStringS( s, FNStringGetToIntegerI( positionBeginS ), FNStringGetToIntegerI( characterTotalS ) ) )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // Message( FNStringGetMidStringS( "knud", 2, 3 ) ) // gives "nud"
 //
 // Message( FNStringGetMidStringS( "knud", 3, 2 ) ) // gives "ud"
 //
 RETURN( SubStr( s, beginI, totalI ) )
 //
END
