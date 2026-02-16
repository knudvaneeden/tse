FORWARD INTEGER PROC FNBlockCheckCurrentIsMarkedB()
FORWARD INTEGER PROC FNBlockCheckIsMarkedNotCurrentDefaultMessageB()
FORWARD INTEGER PROC FNBlockCheckIsMarkedNotCurrentMessageB( STRING s1 )
FORWARD INTEGER PROC FNBlockGetCurrentMarkedTypeI()
FORWARD INTEGER PROC FNBookmarkCheckIsSetB( STRING s1 )
FORWARD INTEGER PROC FNBufferGetBufferIdFileCurrentI()
FORWARD INTEGER PROC FNBufferGetBufferIdGivenBufferNameI( STRING s1 )
FORWARD INTEGER PROC FNCursorCheckDownNotB()
FORWARD INTEGER PROC FNCursorCheckGotoDownB()
FORWARD INTEGER PROC FNCursorCheckGotoUpB()
FORWARD INTEGER PROC FNErrorCheckEscapeB( STRING s1 )
FORWARD INTEGER PROC FNErrorCheckSB( STRING s1 )
FORWARD INTEGER PROC FNFileCheckEditCentralMessageB( STRING s1, INTEGER i1 )
FORWARD INTEGER PROC FNFileCheckEditMessageB( STRING s1 )
FORWARD INTEGER PROC FNFileCheckGotoEndB()
FORWARD INTEGER PROC FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( STRING s1, INTEGER i1 )
FORWARD INTEGER PROC FNFileCheckLineFirstB()
FORWARD INTEGER PROC FNFileCheckSearchExpressionB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNFileGetLineFirstI()
FORWARD INTEGER PROC FNInstrCheckFoundB( INTEGER i1 )
FORWARD INTEGER PROC FNInstrCheckFoundNotB( INTEGER i1 )
FORWARD INTEGER PROC FNKeyCheckPressEscapeB( STRING s1 )
FORWARD INTEGER PROC FNLineCheckGotoBeginB()
FORWARD INTEGER PROC FNLineCheckInsertAfterLineGotoBeginTextInsertB( STRING s1 )
FORWARD INTEGER PROC FNLineCheckSelectMarkB()
FORWARD INTEGER PROC FNLineCheckSelectMarkLineBeginEndB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNLineCheck_SearchExpressionFoundB( STRING s1, STRING s2 )
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
FORWARD INTEGER PROC FNMathCheckNumberInRangeB( INTEGER i1, INTEGER i2, INTEGER i3 )
FORWARD INTEGER PROC FNMathCheckNumberInRangeNotB( INTEGER i1, INTEGER i2, INTEGER i3 )
FORWARD INTEGER PROC FNMathCheckNumberIntegerEqualB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathCheckNumberSmallerOrEqualZeroB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheckNumber_Difference_SmallerOrEqualB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathGetInitializeNewI()
FORWARD INTEGER PROC FNMathGetIntegerZeroI()
FORWARD INTEGER PROC FNMathGetNumberInputYesNoCancelPositionDefaultI( STRING s1 )
FORWARD INTEGER PROC FNMathGetProgramLineNumberAbsoluteCurrentI()
FORWARD INTEGER PROC FNMathGetStringSearchInstrI( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNProgramGetOperatingSystemLinuxNonWslB()
FORWARD INTEGER PROC FNProgramGetOperatingSystemLinuxWslB()
FORWARD INTEGER PROC FNProgramGetOperatingSystemMicrosoftWindowsB()
FORWARD INTEGER PROC FNRecordCheckGotoBeginSeparatorLineAfterBeginB()
FORWARD INTEGER PROC FNRecordCheckRecordSelectMarkSeparatorB( STRING s1 )
FORWARD INTEGER PROC FNRecordCheckRecordSelectMarkSeparatorDefaultB()
FORWARD INTEGER PROC FNRecordCheckSearchMenuCapitalizeCentralB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNRecordCheckSeparatorLineB()
FORWARD INTEGER PROC FNRecordCheck_SearchMenuCapitalizeDefaultB( STRING s1 )
FORWARD INTEGER PROC FNRecordCheck_SearchMenuCapitalizeSecondFirstB( STRING s1 )
FORWARD INTEGER PROC FNRecordCheck_SearchMenuCapitalize_SecondFirstThirdB( STRING s1 )
FORWARD INTEGER PROC FNScreenGetWindowColumnTotalI()
FORWARD INTEGER PROC FNStringCheckEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEnvironmentFoundNotB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNStringCheckEqualCharacterLastNB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNStringCheckEqualErrorOrEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckSearchFoundNotB( STRING s1 )
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
FORWARD PROC PROCBookmarkSet( STRING s1 )
FORWARD PROC PROCCursorGotoDown()
FORWARD PROC PROCError( STRING s1 )
FORWARD PROC PROCErrorCaseNotFound( STRING s1, STRING s2, STRING s3 )
FORWARD PROC PROCErrorFileNotFound( STRING s1 )
FORWARD PROC PROCFileGotoEnd()
FORWARD PROC PROCFileInsertEndPrepare()
FORWARD PROC PROCFileInsertTextEnd( STRING s1, STRING s2, INTEGER i1 )
FORWARD PROC PROCLineInsertAfter()
FORWARD PROC PROCLineInsertAfterLineGotoBeginTextInsert( STRING s1 )
FORWARD PROC PROCLineSelectMarkCurrent()
FORWARD PROC PROCMacroExec( STRING s1 )
FORWARD PROC PROCMacroPurge( STRING s1 )
FORWARD PROC PROCMacroRunKeep( STRING s1 )
FORWARD PROC PROCMacroRunPurge( STRING s1 )
FORWARD PROC PROCMacroRunPurgeParameter( STRING s1, STRING s2 )
FORWARD PROC PROCRecordCreateMenuNew( STRING s1 )
FORWARD PROC PROCRecordCreateMenuSecondFirstThird()
FORWARD PROC PROCRecordGotoBeginSeparator()
FORWARD PROC PROCRecordGotoBeginSeparatorCursorGotoDown()
FORWARD PROC PROCRecordGotoBeginSeparatorLineAfterGotoBegin()
FORWARD PROC PROCRecordGotoBeginSeparator_CursorGotoDownLineGotoBegin()
FORWARD PROC PROCRecordGotoBegin_Separator_LineGotoSecondLineGotoBegin()
FORWARD PROC PROCRecordSelectMarkSeparator()
FORWARD PROC PROCScreenGotoScrollLeft_HorizontalN( INTEGER i1 )
FORWARD PROC PROCSituationRestoreOld()
FORWARD PROC PROCSituationStoreOld()
FORWARD PROC PROCTextGetAbbreviationTemplateDataExtractDefault( STRING s1 )
FORWARD PROC PROCTextGetAbbreviation_TemplateDataExtract( STRING s1, STRING s2 )
FORWARD PROC PROCTextGotoLineBegin()
FORWARD PROC PROCTextInsert( STRING s1 )
FORWARD PROC PROCTextRemovePositionStackPop()
FORWARD PROC PROCTextSavePositionStackPush()
FORWARD PROC PROCTextSearchFindScrollLeft()
FORWARD PROC PROCTextSelectMarkFound()
FORWARD PROC PROCTextSelectMarkFoundTag( INTEGER i1 )
FORWARD PROC PROCTextSelectMarkHiLiteFound()
FORWARD PROC PROCWarn( STRING s1 )
FORWARD PROC PROCWarnCons( STRING s1, STRING s2 )
FORWARD PROC PROCWarnCons3( STRING s1, STRING s2, STRING s3 )
FORWARD PROC PROCWarnCons4( STRING s1, STRING s2, STRING s3, STRING s4 )
FORWARD PROC PROCWarnCons5( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5 )
FORWARD STRING PROC FNFileGetExtensionCurrentPointS()
FORWARD STRING PROC FNLineGetFilenameMacroFilenameOnlyS()
FORWARD STRING PROC FNLineSearchFilenameMacroGet_CurrentS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNRecordGetDefProcFnNameRestoreNotS()
FORWARD STRING PROC FNRecordGetDefProcFnNameRestoreS()
FORWARD STRING PROC FNRecordGetMenuCapitalizeDefaultS( STRING s1 )
FORWARD STRING PROC FNRecordGetMenuCapitalize_FirstDefaultS()
FORWARD STRING PROC FNRecordGetMenuCapitalize_FirstS( STRING s1 )
FORWARD STRING PROC FNSearchCharacterAnyZeroOrMoreMinimumRegularExpressionS( STRING s1 )
FORWARD STRING PROC FNSearchRegularExpressionTagEndS()
FORWARD STRING PROC FNSearchRepeatZeroOrMoreMinimumRegularExpressionS( STRING s1 )
FORWARD STRING PROC FNStringGetAlphabetDigitS()
FORWARD STRING PROC FNStringGetAlphabetLowerDigitUnderscoreS()
FORWARD STRING PROC FNStringGetAlphabetLowerS()
FORWARD STRING PROC FNStringGetAlphabetS()
FORWARD STRING PROC FNStringGetAlphabetUnderscoreS()
FORWARD STRING PROC FNStringGetAlphabetVariableRestS()
FORWARD STRING PROC FNStringGetAsciiToCharacterS( INTEGER i1 )
FORWARD STRING PROC FNStringGetBlockMenuAmpersandAllS()
FORWARD STRING PROC FNStringGetBlockMenuAmpersand_AvailableNextS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetBlockSearchFilenameMacroFirstWarnNotS( STRING s1 )
FORWARD STRING PROC FNStringGetBlock_SearchFilenameMacroFirstWarnS( STRING s1 )
FORWARD STRING PROC FNStringGetBlock_Search_FilenameMacroFirstS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetCarCapitalizeFirstS( STRING s1 )
FORWARD STRING PROC FNStringGetCarCapitalizeNS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetCarCapitalizeS( STRING s1 )
FORWARD STRING PROC FNStringGetCarCapitalizeSecondS( STRING s1 )
FORWARD STRING PROC FNStringGetCarCapitalizeThirdS( STRING s1 )
FORWARD STRING PROC FNStringGetCarFirstWhileFindS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetCarS( STRING s1 )
FORWARD STRING PROC FNStringGetCaseLowerS( STRING s1 )
FORWARD STRING PROC FNStringGetCaseUpperS( STRING s1 )
FORWARD STRING PROC FNStringGetCdrCapitalizedS( STRING s1 )
FORWARD STRING PROC FNStringGetCdr_FirstS( STRING s1 )
FORWARD STRING PROC FNStringGetCharacterEndBackSlashNotEqualInsertEndS( STRING s1 )
FORWARD STRING PROC FNStringGetCharacterFirstS( STRING s1 )
FORWARD STRING PROC FNStringGetCharacterFrontS( STRING s1 )
FORWARD STRING PROC FNStringGetCharacterInsertEndIfEqualNotS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetCharacterS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetCharacterString1InString2AllS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetCharacterSymbolCentralS( INTEGER i1 )
FORWARD STRING PROC FNStringGetCharacterSymbolCurlyCloseParenthesisS()
FORWARD STRING PROC FNStringGetCharacterSymbolCurlyOpenParenthesisS()
FORWARD STRING PROC FNStringGetCharacterSymbolRoundCloseParenthesisS()
FORWARD STRING PROC FNStringGetCharacterSymbolSlashBackwardS()
FORWARD STRING PROC FNStringGetCharacterSymbolSpaceS()
FORWARD STRING PROC FNStringGetCharacterSymbolUnderScoreS()
FORWARD STRING PROC FNStringGetCharacterWithoutFirstS( STRING s1 )
FORWARD STRING PROC FNStringGetConcat3S( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetConcat4S( STRING s1, STRING s2, STRING s3, STRING s4 )
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
FORWARD STRING PROC FNStringGetExpressionRegularGotoEndS( STRING s1 )
FORWARD STRING PROC FNStringGetExpressionRegularGotoS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetFileExtensionToTypeNameCurrentS()
FORWARD STRING PROC FNStringGetFileExtensionToTypeNameS( STRING s1 )
FORWARD STRING PROC FNStringGetFileGetFilenamePathDefaultCrossPlatformS( STRING s1 )
FORWARD STRING PROC FNStringGetFileInfoToFileNameS( STRING s1 )
FORWARD STRING PROC FNStringGetFileIniDefaultCrossPlatformS( STRING s1 )
FORWARD STRING PROC FNStringGetFileIniDefaultS( STRING s1 )
FORWARD STRING PROC FNStringGetFilenameCurrentS()
FORWARD STRING PROC FNStringGetFilenameEndBackSlashNotEqualInsertEndS( STRING s1 )
FORWARD STRING PROC FNStringGetFilenameGlobalErrorS()
FORWARD STRING PROC FNStringGetFilenameIniDefaultCrossPlatformS()
FORWARD STRING PROC FNStringGetFilenameSplitInPartsS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetFunction_NameCapitalizeToWordsSeparatorRemoveS( STRING s1 )
FORWARD STRING PROC FNStringGetGlobalS( STRING s1 )
FORWARD STRING PROC FNStringGetInitializationGlobalS( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetInitializeNewStringS()
FORWARD STRING PROC FNStringGetLineFilenameMacro_GetCaseS( STRING s1 )
FORWARD STRING PROC FNStringGetLineGetCurrentS()
FORWARD STRING PROC FNStringGetLineNumberCurrentS()
FORWARD STRING PROC FNStringGetLineSearchFilenameMacroGetCurrentDefaultS()
FORWARD STRING PROC FNStringGetLineSearch_FilenameMacroGet_CurrentWarnS()
FORWARD STRING PROC FNStringGetMachineNameS()
FORWARD STRING PROC FNStringGetMathIntegerToStringS( INTEGER i1 )
FORWARD STRING PROC FNStringGetMenuAmpersandAvailableNextDefaultS( STRING s1 )
FORWARD STRING PROC FNStringGetMenuHotkeyAmpersandUniqueAllS()
FORWARD STRING PROC FNStringGetMidStringS( STRING s1, INTEGER i1, INTEGER i2 )
FORWARD STRING PROC FNStringGetOperatingSystemS()
FORWARD STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashNotS()
FORWARD STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashS()
FORWARD STRING PROC FNStringGetPortS()
FORWARD STRING PROC FNStringGetRecordGetMenuCapitalizeCentralS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetRecordGetMenu_CapitalizeSecondS( STRING s1 )
FORWARD STRING PROC FNStringGetRecordGetQAHeader_FilenameMacroFilenameOnlyS()
FORWARD STRING PROC FNStringGetRecordGet_MenuCapitalizeFirstSecondS( STRING s1 )
FORWARD STRING PROC FNStringGetRecordMenuAmpersandAllS()
FORWARD STRING PROC FNStringGetRecordMenuAmpersandNextS()
FORWARD STRING PROC FNStringGetRecordSearchSeparatorDefaultExpressionRegularS()
FORWARD STRING PROC FNStringGetRecordSeparatorBeginDefaultS()
FORWARD STRING PROC FNStringGetRecordSeparatorDefaultS()
FORWARD STRING PROC FNStringGetRecordSeparatorEndDefaultS()
FORWARD STRING PROC FNStringGetRecord_GetMenuCapitalizeSecondFirstS( STRING s1 )
FORWARD STRING PROC FNStringGetRecord_GetMenuCapitalizeSecondFirstThirdS( STRING s1 )
FORWARD STRING PROC FNStringGetRecord_GetMenuCapitalize_SecondFirstThirdSDefault()
FORWARD STRING PROC FNStringGetRecord_GetMenu_CapitalizeSecondFirstDefaultS()
FORWARD STRING PROC FNStringGetRemoveAllS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetRemoveCharactersFrontS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetReplaceAllS( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetRightStringLengthEqualS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetRightStringS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetSearchBetweenRegularExpressionTagS( STRING s1 )
FORWARD STRING PROC FNStringGetSearchCharacterAnyRegularExpressionS( STRING s1 )
FORWARD STRING PROC FNStringGetSearchCharacterDefaultAnyZeroOrMoreMinimumRegularExpressionS()
FORWARD STRING PROC FNStringGetSearchEscapeS( STRING s1 )
FORWARD STRING PROC FNStringGetSearchFilenameMacroExpressionRegularS()
FORWARD STRING PROC FNStringGetSearchFoundNotS()
FORWARD STRING PROC FNStringGetSearchOptionBlockMark_GlobalExpressionRegularS()
FORWARD STRING PROC FNStringGetSearchOptionExpressionRegularS()
FORWARD STRING PROC FNStringGetSearchOptionGlobalBlockMarkS()
FORWARD STRING PROC FNStringGetSearchOptionGlobalS()
FORWARD STRING PROC FNStringGetSearchOption_Block_MarkS()
FORWARD STRING PROC FNStringGetSearchProcedureDefinitionExpressionFirstS( STRING s1 )
FORWARD STRING PROC FNStringGetSearchProcedureNameExpressionS( STRING s1 )
FORWARD STRING PROC FNStringGetSearchRegularExpressionTagBeginS()
FORWARD STRING PROC FNStringGetSearchSymbolEscapeS()
FORWARD STRING PROC FNStringGetSearch_OptionExpressionRegularGotoS()
FORWARD STRING PROC FNStringGetSearch_ProcedureDefinitionExpressionS( STRING s1 )
FORWARD STRING PROC FNStringGetSectionSeparatorS()
FORWARD STRING PROC FNStringGetSpaceRemoveBeginEndS( STRING s1 )
FORWARD STRING PROC FNStringGetSpaceRemoveBeginS( STRING s1 )
FORWARD STRING PROC FNStringGetSpaceRemoveEndS( STRING s1 )
FORWARD STRING PROC FNStringGetTextFoundMarkS()
FORWARD STRING PROC FNStringGetTextFoundS()
FORWARD STRING PROC FNStringGetTextFoundTagCentralS( INTEGER i1 )
FORWARD STRING PROC FNStringGetTextFoundTagGetFirstS()
FORWARD STRING PROC FNStringGetTextFoundTagS( INTEGER i1 )
FORWARD STRING PROC FNStringGetTextMarkS()
FORWARD STRING PROC FNStringGetTokenCapitalizeDefaultMenuS()
FORWARD STRING PROC FNStringGetTokenCapitalizeMenuPrefixS()
FORWARD STRING PROC FNStringGetTokenCaseUpperCentralS( STRING s1 )
FORWARD STRING PROC FNStringGetTokenFunctionNameCaseUpperS()
FORWARD STRING PROC FNStringGetTokenLanguageAspS()
FORWARD STRING PROC FNStringGetTokenLanguageAssemblerS()
FORWARD STRING PROC FNStringGetTokenLanguageBasicS()
FORWARD STRING PROC FNStringGetTokenLanguageBatS()
FORWARD STRING PROC FNStringGetTokenLanguageCS()
FORWARD STRING PROC FNStringGetTokenLanguageCSharpS()
FORWARD STRING PROC FNStringGetTokenLanguageColdFusionS()
FORWARD STRING PROC FNStringGetTokenLanguageCppS()
FORWARD STRING PROC FNStringGetTokenLanguageDelphiS()
FORWARD STRING PROC FNStringGetTokenLanguageDokS()
FORWARD STRING PROC FNStringGetTokenLanguageDtdS()
FORWARD STRING PROC FNStringGetTokenLanguageFortranS()
FORWARD STRING PROC FNStringGetTokenLanguageHtmlS()
FORWARD STRING PROC FNStringGetTokenLanguageJavaS()
FORWARD STRING PROC FNStringGetTokenLanguageJavaScriptS()
FORWARD STRING PROC FNStringGetTokenLanguageJspS()
FORWARD STRING PROC FNStringGetTokenLanguageLispS()
FORWARD STRING PROC FNStringGetTokenLanguageLogoS()
FORWARD STRING PROC FNStringGetTokenLanguageLotusScriptS()
FORWARD STRING PROC FNStringGetTokenLanguageMapleS()
FORWARD STRING PROC FNStringGetTokenLanguagePascalS()
FORWARD STRING PROC FNStringGetTokenLanguagePerlS()
FORWARD STRING PROC FNStringGetTokenLanguagePhpS()
FORWARD STRING PROC FNStringGetTokenLanguagePostScriptS()
FORWARD STRING PROC FNStringGetTokenLanguagePrologS()
FORWARD STRING PROC FNStringGetTokenLanguagePythonS()
FORWARD STRING PROC FNStringGetTokenLanguageSqlS()
FORWARD STRING PROC FNStringGetTokenLanguageTexS()
FORWARD STRING PROC FNStringGetTokenLanguageTseCaseUpperS()
FORWARD STRING PROC FNStringGetTokenLanguageTseS()
FORWARD STRING PROC FNStringGetTokenLanguageUmlS()
FORWARD STRING PROC FNStringGetTokenLanguageVBScriptS()
FORWARD STRING PROC FNStringGetTokenLanguageVisualBasicS()
FORWARD STRING PROC FNStringGetTokenLanguageXmlS()
FORWARD STRING PROC FNStringGetTokenLanguageXsdS()
FORWARD STRING PROC FNStringGetTokenLanguageXslS()
FORWARD STRING PROC FNStringGetTokenNameClipboardTseS()
FORWARD STRING PROC FNStringGetTokenProgramFunctionNameS()
FORWARD STRING PROC FNStringGetTokenProgramProcedureNameS()
FORWARD STRING PROC FNStringGetTokenProgram_ProcedureNameCaseUpperS()
FORWARD STRING PROC FNStringGetUserNameFirstS()
FORWARD STRING PROC FNStringGetUserNameLastS()
FORWARD STRING PROC FNStringGetWordRestS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGet_FilenameGlobalFilenameMacroS()
FORWARD STRING PROC FNStringGet_FilenameIniDefaultS()


// --- MAIN --- //

PROC Main()
 PROCRecordCreateMenuSecondFirstThird()
END

<F12> Main()

// --- LIBRARY --- //

// library: record: create: menu: second: first: third <description></description> <version control></version control> <version>1.0.0.0.45</version> <version control></version control> (filenamemacro=creareft.s) [<Program>] [<Research>] [kn, ri, tu, 27-11-2012 02:33:12]
PROC PROCRecordCreateMenuSecondFirstThird()
 // e.g. PROC Main()
 // e.g.  PROCRecordCreateMenuSecondFirstThird()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER B1 = FALSE
 INTEGER B2 = FALSE
 // INTEGER B3 = FALSE
 INTEGER B4 = FALSE
 //
 STRING s[255] = ""
 STRING s1[255] = ""
 //
 STRING s2[255] = ""
 //
 PushPosition()
 //
 s = FNStringGetRecordGetQAHeader_FilenameMacroFilenameOnlyS()
 //
 IF LFind( Format( 'MacroRunPurge.*"', s, '"' ), "gix" ) // menu line exists already, then exit
  //
  PopPosition()
  //
  Message( "menu line containing macro", " ", s, " ", "already exists" )
  //
  RETURN()
  //
 ENDIF
 //
 // PROCBookmarkSet( "Z" )
 PROCBookmarkSet( "P" )
 //
 PROCMacroRunPurge( "crearetd" ) // operation: create: record: menu: line: library: to: menu: current: clipboard: tse: copy: message [kn, ri, tu, 27-11-2012 00:31:27]
 //
 PROCMacroRunPurge( "crearemi" ) // operation: create: record: menu: line: library: to: menu: current: clipboard: windows: copy: message: header // [kn, ri, tu, 27-11-2012 00:31:32]
 //
 B4 = FNRecordCheck_SearchMenuCapitalizeDefaultB( "gi" )
 //
 B1 = FNRecordCheck_SearchMenuCapitalize_SecondFirstThirdB( "gi" )
 //
 B2 = FNRecordCheck_SearchMenuCapitalizeSecondFirstB( "gi" )
 //
 //  B3 = FNStringGetRecordSearchMenu_CapitalizeSecondB( "gi" )
 //
 // Warn( B1, B2, B3, B4 )
 //
 PopPosition()
 //
 IF ( B4 )
  //
  B4 = FNRecordCheck_SearchMenuCapitalizeDefaultB( "gi" )
  //
  ScrollToTop()
  //
  s2 = FNStringGetRecordMenuAmpersandNextS()
  Warn( "next ampersand character available", " ", "=", " ", s2 )
  //
 ELSEIF ( B1 )
  //
  B1 = FNRecordCheck_SearchMenuCapitalize_SecondFirstThirdB( "gi" )
  //
  ScrollToTop()
  //
  s2 = FNStringGetRecordMenuAmpersandNextS()
  Warn( "next ampersand character available", " ", "=", " ", s2 )
  //
 ELSEIF ( B2 )
  //
  B2 = FNRecordCheck_SearchMenuCapitalizeSecondFirstB( "gi" )
  //
  ScrollToTop()
  //
  s2 = FNStringGetRecordMenuAmpersandNextS()
  Warn( "next ampersand character available", " ", "=", " ", s2 )
  //
 // ELSEIF ( B3 )
  //
  // B3 = FNStringGetRecordSearchMenu_CapitalizeSecondB( "gi" )
  //
 ELSE
  //
  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
  IF ( FNMathGetNumberInputYesNoCancelPositionDefaultI( "Do you want a new menu to be created?" ) == 1 )
   //
   Warn( "create a new MENU record (to be further worked out)" )
   //
   // create menu 213
   //
   s1 = FNStringGetRecord_GetMenuCapitalize_SecondFirstThirdSDefault()
   //
   BegFile()
   PROCMacroRunPurge( "recogont" ) // operation: goto: record: direction: next: windows: goto: top [kn, ri, tu, 27-11-2012 09:34:31]
   PROCRecordCreateMenuNew( s1 )
   //
   PROCMacroRunPurge( "replreiu" ) // operation:replace:record:library:function/procedure:name:capitalize:date:new // [kn, ri, tu, 27-11-2012 10:15:45]
   //
   PROCMacroRunPurge( "inselidd" ) // operation: create: example: proc: main: all" // new [kn, ri, su, 08-07-2012 22:40:27]
   //
   // create menu 21
   //
   s2 = FNStringGetRecord_GetMenu_CapitalizeSecondFirstDefaultS()
   //
   BegFile()
   PROCMacroRunPurge( "recogont" ) // operation: goto: record: direction: next: windows: goto: top [kn, ri, tu, 27-11-2012 09:34:31]
   PROCRecordCreateMenuNew( s2 )
   //
   PROCMacroRunPurge( "replreiu" ) // operation:replace:record:library:function/procedure:name:capitalize:date:new // [kn, ri, tu, 27-11-2012 10:15:45]
   //
   PROCMacroRunPurge( "inselidd" ) // operation: create: example: proc: main: all" // new [kn, ri, su, 08-07-2012 22:40:27]
   //
   Warn( "1", ".", " ", "add menu", " ", s1, " ", "to", " ", "menu", s2 )
   //
   Warn( "2", ".", " ", "add menu", " ", s2, " ", "to", " ", "menu", FNRecordGetMenuCapitalize_FirstDefaultS() )
   //
  ENDIF
  //
 ENDIF
 //
END

// library: string: get: record: get: q: a: header: filename: macro: filename: only <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstfon.s) [<Program>] [<Research>] [kn, ri, su, 30-10-2005 01:43:25]
STRING PROC FNStringGetRecordGetQAHeader_FilenameMacroFilenameOnlyS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecordGetQAHeader_FilenameMacroFilenameOnlyS() ) // gives e.g. ...""
 // e.g.  Warn( FNStringGetRecordGetQAHeader_FilenameMacroFilenameOnlyS() ) // gives e.g. "getstfon"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 PROCSituationStoreOld()
 //
 PROCRecordGotoBeginSeparator()
 //
 s = FNLineGetFilenameMacroFilenameOnlyS()
 //
 PROCSituationRestoreOld()
 //
 RETURN( s )
 //
END

// library: bookmark: set <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=setbobse.s) [<Program>] [<Research>] [kn, ri, su, 15-10-2000 22:51:07]
PROC PROCBookmarkSet( STRING bookmarkS )
 // e.g. PROC Main()
 // e.g.  // PROCBookmarkSet( "N" )
 // e.g.  PROCBookmarkSet( "O" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNBookmarkCheckIsSetB( bookmarkS ) )
  //
  PROCWarnCons3( "bookmark", bookmarkS, ": could not be placed. Stopped" )
  //
 ENDIF
 //
END

// library: macro: run: purge <description>macro: run a macro, then purge it (this text goes into the main macro file)</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=runmarpu.s) [<Program>] [<Research>] [[kn, zoe, tu, 27-10-1998 18:54:17]
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

// library: record: check: search: menu: capitalize: default <description></description> <version control></version control> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checreck.s) [<Program>] [<Research>] [kn, vo, fr, 09-05-2014 13:31:40]
INTEGER PROC FNRecordCheck_SearchMenuCapitalizeDefaultB( STRING searchOptionS )
 // e.g. PROC Main()
 // e.g.  Message( FNRecordCheck_SearchMenuCapitalizeDefaultB( FNStringGetEmptyS() ) ) // gives e.g. TRUE, when found in current file
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNRecordCheckSearchMenuCapitalizeCentralB( "default", searchOptionS ) )
 //
END

// library: record: check: search: menu: capitalize: second: first: third <description></description> <version control></version control> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=checrefz.s) [<Program>] [<Research>] [kn, ri, tu, 27-11-2012 02:06:51]
INTEGER PROC FNRecordCheck_SearchMenuCapitalize_SecondFirstThirdB( STRING searchOptionS )
 // e.g. PROC Main()
 // e.g.  Message( FNRecordCheck_SearchMenuCapitalize_SecondFirstThirdB( FNStringGetEmptyS() ) ) // gives e.g. TRUE, when found in current file
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNRecordCheckSearchMenuCapitalizeCentralB( "secondfirstthird", searchOptionS ) )
 //
END

// library: record: search: menu: capitalize: second: first <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=searresf.s) [<Program>] [<Research>] [kn, ri, sa, 20-04-2002 20:21:49]
INTEGER PROC FNRecordCheck_SearchMenuCapitalizeSecondFirstB( STRING searchOptionS )
 // e.g. PROC Main()
 // e.g.  Message( FNRecordCheck_SearchMenuCapitalizeSecondFirstB( "igv" ) ) // gives e.g. TRUE, when found in current file
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNRecordCheckSearchMenuCapitalizeCentralB( "secondfirst", searchOptionS ) )
 //
END

// library: string: get: record: menu: ampersand: next <description></description> <version control></version control> <version>1.0.0.0.14</version> <version control></version control> (filenamemacro=getstanh.s) [<Program>] [<Research>] [kn, ri, fr, 30-11-2012 22:41:37]
STRING PROC FNStringGetRecordMenuAmpersandNextS()
 // e.g. PROC Main()
 // e.g.  Warn( FNStringGetRecordMenuAmpersandNextS(), " ", "=", " ", "next available menu ampersand character" ) // gives e.g. "I" (if given that the characters "ABCDEFGH" are already used as '&' characters
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetRecordMenuAmpersandAllS()
 //
 s = FNStringGetMenuAmpersandAvailableNextDefaultS( s )
 //
 RETURN( s )
 //
END

// library: macro: run: keep <description>macro: run a macro, then keep it</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=runmarke.s) [<Program>] [<Research>] [[kn, zoe, fr, 27-10-2000 15:59:33]
PROC PROCMacroRunKeep( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  PROCMacroRunKeep( "mysubma1.mac myparameter11 myparameter12" )
 // e.g.  PROCMacroRunKeep( "mysubma2.mac myparameter21" )
 // e.g.  PROCMacroRunKeep( "mysubma3.mac myparameter31 myparameter32" )
 // e.g. END
 //
 IF FNMacroCheckLoadB( FNStringGetCarS( macronameS ) ) // necessary if you pass parameters in a string
  //
  PROCMacroExec( macronameS )
  //
 ENDIF
 //
END

// library: math: get: number: input: yes: no: cancel: position: default <description></description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getmapde.s) [<Program>] [<Research>] [kn, am, mo, 04-07-2011 14:23:57]
INTEGER PROC FNMathGetNumberInputYesNoCancelPositionDefaultI( STRING infoS )
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetNumberInputYesNoCancelPositionDefaultI( "Please press Yes/No/Cancel" ) ) // gives e.g. 1 if Yes has been choosen
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default
 //
 RETURN( YesNo( infoS ) )
 //
END

// library: string: get: record: get: menu: capitalize: second: first: third: s: default <description></description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getstsdd.s) [<Program>] [<Research>] [kn, ri, tu, 27-11-2012 02:40:16]
STRING PROC FNStringGetRecord_GetMenuCapitalize_SecondFirstThirdSDefault()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecord_GetMenuCapitalize_SecondFirstThirdSDefault() ) // gives e.g. "MENUQGetStringRecord"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetRecord_GetMenuCapitalizeSecondFirstThirdS( FNStringGetTokenCapitalizeMenuPrefixS() ) )
 //
END

// library: record: create: menu: new <description></description> <version control></version control> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=crearemn.s) [<Program>] [<Research>] [kn, ri, tu, 27-11-2012 10:26:04]
PROC PROCRecordCreateMenuNew( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCRecordCreateMenuNew( "test" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PushBlock()
 PROCRecordSelectMarkSeparator()
 GotoBlockBegin()
 Up() // goto the separator line
 DupLine() // duplicate the separator line
 Up() // add an empty line in between
 AddLine()
 BegLine()
 PROCTextGetAbbreviationTemplateDataExtractDefault( "l" )
 AddLine( Format( "MENU", " ", s, "()" ) )
 AddLine( Format ( " ", "history" ) )
 AddLine( Format( " ", "x = 30" ) )
 AddLine( Format( " ", "y = 29" ) )
 AddLine( Format( " " ,"title", " ", "=", " ", '"', "OPERATION", ":", " ", s, '"' ) )
 AddLine()
 BegLine()
 PasteFromWinClip()
 BegLine()
 InsertText( " ", _INSERT_ )
 AddLine()
 BegLine()
 Paste()
 BegLine()
 InsertText( " ", _INSERT_ )
 AddLine( "END" )
 PopBlock()
 //
END

// library: string: get: record: get: menu: capitalize: second: first: default <description></description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getstfdg.s) [<Program>] [<Research>] [kn, ri, tu, 27-11-2012 09:27:03]
STRING PROC FNStringGetRecord_GetMenu_CapitalizeSecondFirstDefaultS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecord_GetMenu_CapitalizeSecondFirstDefaultS() ) // gives e.g. "MENU qgetrecord"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetRecord_GetMenuCapitalizeSecondFirstS( FNStringGetTokenCapitalizeMenuPrefixS() ) )
 //
END

// library: record: get: menu: capitalize: first: default <description></description> <version control></version control> <version>1.0.0.0.7</version> <version control></version control> (filenamemacro=getrefdf.s) [<Program>] [<Research>] [kn, ri, su, 02-12-2012 00:33:51]
STRING PROC FNRecordGetMenuCapitalize_FirstDefaultS()
 // e.g. PROC Main()
 // e.g.  Message( FNRecordGetMenuCapitalize_FirstDefaultS() ) // gives e.g. "MENU qrecord"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNRecordGetMenuCapitalize_FirstS( FNStringGetTokenCapitalizeMenuPrefixS() ) )
 //
END

// library: string: get: initialize: new: string <description>string: initialize</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstnsa.s) [<Program>] [<Research>] [[kn, ri, mo, 09-07-2001 12:00:07]
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

// library: line: get: filename: macro: filename: only <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getlifon.s) [<Program>] [<Research>] [kn, ni, sa, 02-11-2002 04:39:09]
STRING PROC FNLineGetFilenameMacroFilenameOnlyS()
 // e.g. PROC Main()
 // e.g.  Message( FNLineGetFilenameMacroFilenameOnlyS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetLineFilenameMacro_GetCaseS( "filename only" ) )
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

// library: bookmark: put <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=setbobsf.s) [<Program>] [<Research>] [kn, ri, su, 15-10-2000 22:51:40]
INTEGER PROC FNBookmarkCheckIsSetB( STRING bookmarkS )
 // e.g. PROC Main()
 // e.g.  Message( FNBookmarkCheckIsSetB( "A" ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( PlaceMark( bookmarkS ) )
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

// library: string: check: empty <description>string: empty: is given string empty?</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checstcz.s) [<Program>] [<Research>] [[kn, ri, sa, 20-05-2000 20:11:08]
INTEGER PROC FNStringCheckEmptyB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckEmptyB( s ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( s, FNStringGetEmptyS() ) )
 //
END

// library: error <description>error: central routine</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=ererror.s) [<Program>] [<Research>] [[kn, ni, mo, 03-08-1998 13:08:12]
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

// library: macro: check: load <description>macro: load: (Loads a Macro File From Disk Into Memory) R    LoadMacro(STRING macro_filename)*</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checmacl.s) [<Program>] [<Research>] [[kn, zoe, we, 16-06-1999 01:07:06]
INTEGER PROC FNMacroCheckLoadB( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  Message( FNMacroCheckLoadB( macronameS ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( LoadMacro( macronameS ) )
 //
END

// library: string: get: word: token: get: first: FNStringGetCarS(): Get the first word of a string (words delimited by a space " " (=space delimited list)). <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgca.s) [<Program>] [<Research>] [kn, ni, su, 02-08-1998 15:54:17]
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

// library: macro: exec <description>macro: (Executes the Requested Macro) O    ExecMacro([<Program>] [<Research>] [STRING macroname])*</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=execmame.s) [[kn, zoe, we, 16-06-1999 01:06:54]
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

// library: macro: purge <description>macro: (Purges a Macro File From Memory) R    PurgeMacro(STRING s)*</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=purgmamp.s) [<Program>] [<Research>] [[kn, zoe, fr, 13-10-2000 19:09:32]
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

// library: record: check: search: menu: capitalize: central <description>record: search: menu: capitalize</description> <version>1.0.0.0.8</version> <version control></version control> (filenamemacro=checreci.s) [<Program>] [<Research>] [[kn, ri, sa, 20-04-2002 20:21:57]
INTEGER PROC FNRecordCheckSearchMenuCapitalizeCentralB( STRING caseS, STRING searchOptionS )
 // e.g. PROC Main()
 // e.g.  Message( FNRecordCheckSearchMenuCapitalizeCentralB( "secondfirstthird", "igv" ) ) // gives e.g. TRUE when found
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 STRING prefixS[255] = FNStringGetTokenCapitalizeMenuPrefixS()
 //
 CASE caseS
  //
  WHEN "default"
   //
   s = FNRecordGetMenuCapitalizeDefaultS( prefixS )
   //
  WHEN "first"
   //
   s = FNRecordGetMenuCapitalize_FirstS( prefixS )
   //
  WHEN "second"
   //
   s = FNStringGetRecordGetMenu_CapitalizeSecondS( prefixS )
   //
  WHEN "firstsecond"
   //
   s = FNStringGetRecordGet_MenuCapitalizeFirstSecondS( prefixS )
   //
  WHEN "secondfirst"
   //
   s = FNStringGetRecord_GetMenuCapitalizeSecondFirstS( prefixS )
   //
  WHEN "secondfirstthird"
   //
   s = FNStringGetRecord_GetMenuCapitalizeSecondFirstThirdS( prefixS )
   //
  OTHERWISE
   //
   PROCErrorCaseNotFound( FNStringGetEmptyS(), "FNRecordCheckSearchMenuCapitalizeCentralB(", caseS )
   //
   s = FNStringGetErrorS()
   //
 ENDCASE
 //
 IF FNErrorCheckSB( s )
  //
  RETURN( FNMathCheckGetLogicFalseB() )
  //
 ENDIF
 //
 IF FNStringCheckSearchFoundNotB( s )
  //
  RETURN( FNMathCheckGetLogicFalseB() )
  //
 ENDIF
 //
 s = Format( "MENU", " ", s ) // added [kn, ri, tu, 27-11-2012 02:15:33]
 //
 // RETURN( FNFileCheckSearchExpressionB( s, FNStringGetConcatS( searchOptionS, "igv" ) ) ) // old [kn, ri, tu, 27-11-2012 02:18:01]
 RETURN( FNFileCheckSearchExpressionB( s, searchOptionS ) ) // new [kn, ri, tu, 27-11-2012 02:18:08]
 //
END

// library: string: get: record: menu: ampersand: all <description></description> <version control></version control> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=getstaaq.s) [<Program>] [<Research>] [kn, ri, fr, 30-11-2012 15:49:35]
STRING PROC FNStringGetRecordMenuAmpersandAllS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecordMenuAmpersandAllS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = ""
 //
 PushPosition()
 //
 PushBlock()
 //
 PROCRecordSelectMarkSeparator()
 //
 s = FNStringGetBlockMenuAmpersandAllS()
 //
 PopBlock()
 //
 PopPosition()
 //
 RETURN( s )
 //
END

// library: string: get: menu: ampersand: available: next <description></description> <version control></version control> <version>1.0.0.0.8</version> <version control></version control> (filenamemacro=getstang.s) [<Program>] [<Research>] [kn, ri, fr, 30-11-2012 22:21:13]
STRING PROC FNStringGetMenuAmpersandAvailableNextDefaultS( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetMenuAmpersandAvailableNextDefaultS( "ABCDEFGH" ) ) // gives e.g. "I"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetBlockMenuAmpersand_AvailableNextS( s, FNStringGetMenuHotkeyAmpersandUniqueAllS() ) )
 //
END

// library: string: get: record: get: menu: capitalize: second: first: third <description></description> <version control></version control> <version>1.0.0.0.4</version> <version control></version control> (filenamemacro=getstfth.s) [<Program>] [<Research>] [kn, ri, tu, 27-11-2012 02:02:33]
STRING PROC FNStringGetRecord_GetMenuCapitalizeSecondFirstThirdS( STRING inS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecord_GetMenuCapitalizeSecondFirstThirdS( FNStringGetTokenCapitalizeMenuPrefixS() ) ) // gives e.g. "MENUQGetStringRecord"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetRecordGetMenuCapitalizeCentralS( inS, "secondfirstthird" ) )
 //
END

// library: string: get: capitalize: menu: prefix <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=getstmpr.s) [<Program>] [<Research>] [kn, ri, sa, 20-04-2002 21:06:44]
STRING PROC FNStringGetTokenCapitalizeMenuPrefixS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenCapitalizeMenuPrefixS() ) // gives e.g. "MENU q"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( "MENUQ" ) // old [kn, ri, su, 15-02-2026 23:08:41]
 // RETURN( "MENUQT" ) // new [kn, ri, su, 15-02-2026 23:08:55]
 RETURN( "MENUQTroubleshoot" ) // new [kn, ri, su, 15-02-2026 23:08:55]
 //
END

// library: record: select: mark: separator <description></description> <version>1.0.0.0.15</version> <version control></version control> (filenamemacro=selerems.s) [<Program>] [<Research>] [kn, ri, su, 06-11-2011 13:59:40]
PROC PROCRecordSelectMarkSeparator()
 // e.g. PROC Main()
 // e.g.  PROCRecordSelectMarkSeparator()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF ( NOT ( FNRecordCheckRecordSelectMarkSeparatorDefaultB() ) )
  //
  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
  Warn( "Could not find a record at current position (e.g. begin record separator and or record end separator missing). Please check." )
  //
 ENDIF
 //
END

// library: text: get: abbreviation: template: data: extract: default <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getteede.s) [<Program>] [<Research>] [kn, ri, su, 23-09-2007 21:35:09]
PROC PROCTextGetAbbreviationTemplateDataExtractDefault( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCTextGetAbbreviationTemplateDataExtractDefault( "su" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextGetAbbreviation_TemplateDataExtract( s, "template.mac" )
 //
END

// library: string: get: record: get: menu: capitalize: second: first <description></description> <version control></version control> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=getstsfq.s) [<Program>] [<Research>] [kn, ri, sa, 04-01-2020 14:37:50]
STRING PROC FNStringGetRecord_GetMenuCapitalizeSecondFirstS( STRING inS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecord_GetMenuCapitalizeSecondFirstS( FNStringGetTokenCapitalizeMenuPrefixS() ) ) // gives e.g. "MENU qgetrecord"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetRecordGetMenuCapitalizeCentralS( inS, "secondfirst" ) )
 //
END

// library: record: get: menu: capitalize: first <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getrecf.s) [<Program>] [<Research>] [kn, ri, sa, 20-04-2002 20:21:44]
STRING PROC FNRecordGetMenuCapitalize_FirstS( STRING inS )
 // e.g. PROC Main()
 // e.g.  Message( FNRecordGetMenuCapitalize_FirstS( FNStringGetTokenCapitalizeMenuPrefixS() ) ) // gives e.g. "MENU qrecord"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetRecordGetMenuCapitalizeCentralS( inS, "first" ) )
 //
END

// library: string: get: empty (return an empty string) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstgem.s) [<Program>] [<Research>] [kn, ri, sa, 20-05-2000 20:11:03]
STRING PROC FNStringGetEmptyS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetEmptyS() ) // gives e.g. the empty string: ""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "" )
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

// library: text: save: position: stack: push <description>text: save: position: stack: push: store</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=savetesp.s) [<Program>] [<Research>] [[kn, zoe, fr, 04-06-1999 23:01:00]
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

// library: string: get: line: filename: macro: get: case <description>line: get: filename: macro: case</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstgdd.s) [<Program>] [<Research>] [[kn, ri, sa, 08-12-2001 20:09:54]
STRING PROC FNStringGetLineFilenameMacro_GetCaseS( STRING caseS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetLineFilenameMacro_GetCaseS( caseS ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetLineSearchFilenameMacroGetCurrentDefaultS()
 //
 IF FNErrorCheckSB( s )
  //
  RETURN( FNStringGetErrorS() )
  //
 ENDIF
 //
 CASE caseS
  //
  WHEN "filename+extension"
   //
   // default, do nothing
   //
  WHEN "filename only"
   //
   s = FNStringGetFileInfoToFileNameS( s )
   //
  OTHERWISE
   //
   PROCErrorCaseNotFound( FNStringGetEmptyS(), "FNStringGetLineFilenameMacro_GetCaseS(", caseS )
   //
   s = FNStringGetErrorS()
   //
 ENDCASE
 //
 RETURN( s )
 //
END

// library: text: remove: position: stack: pop <description>text: remove: position: stack: pop: restore</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=remotesp.s) [<Program>] [<Research>] [[kn, zoe, fr, 04-06-1999 23:01:00]
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

// library: warn <description>error: warning: give a warning message</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=wawarn.s)  [<Program>] [<Research>] [kn, zoe, we, 09-06-1999 22:11:07]
PROC PROCWarn( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCWarn( "you have forgotten to input a value" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new [kn, ri, fr, 22-05-2020 20:12:39]
 Warn( s )
 //
END

// library: string: get: cons3: string: concatenation: 3 strings <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgcy.s) [<Program>] [<Research>] [kn, zoe, fr, 17-11-2000 13:52:07]
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

// library: string: check: equal <description>string: equal: are two given strings equal? (stored in 'checstcf.s')</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checstcy.s) [<Program>] [<Research>] [[kn, zoe, we, 04-10-2000 18:23:27]
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

// library: string: get: line: number: current (return the current linenumber) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstncm.s) [<Program>] [<Research>] [kn, ni, mo, 02-08-1999 00:46:42]
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

// library: file: insert: text: end <description>file: line: text: insert: end: goto the end of the given file, insert some text (when newlineB is TRUE, start every inserted line on a new line)</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=insefite.s) [<Program>] [<Research>] [[kn, ni, mo, 03-08-1998 13:08:29]
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
 // ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿|
 // ³                                                  ³|
 // ³                                                  ³|
 // ³                                                  ³|
 // ³                                                  ³|
 // ³                                                  ³V
 // ³cursor is here on this line                       ³--- <-- CurrLine()
 // ³                                                  ³
 // ³                                                  ³
 // ³[end of file]-------------------------------------³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ³                                                  ³
 // ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 //
 RETURN( CurrLine() )
 //
END

// library: string: get: filename: global: error <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstget.s) [<Program>] [<Research>] [kn, zoe, fr, 20-10-2000 23:34:48]
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

// library: math: check: get: logic: true: wrapper <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmalt.s) [<Program>] [<Research>] [kn, ri, su, 22-07-2001 15:43:12]
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

// library: macro: check: exec <description>macro: (Executes the Requested Macro) O    ExecMacro([<Program>] [<Research>] [STRING macroname])*</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checmace.s) [[kn, zoe, we, 16-06-1999 01:06:54]
INTEGER PROC FNMacroCheckExecB( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  Message( FNMacroCheckExecB( macronameS ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( ExecMacro( macronameS ) )
 //
END

// library: macro: check: purge <description>macro: purge</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checmacp.s) [<Program>] [<Research>] [[kn, zoe, fr, 13-10-2000 19:03:50]
INTEGER PROC FNMacroCheckPurgeB( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  Message( FNMacroCheckPurgeB( macronameS ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( PurgeMacro( macronameS ) )
 //
END

// library: record: get: menu: capitalize: default <description></description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getrecdg.s) [<Program>] [<Research>] [kn, vo, fr, 09-05-2014 13:26:42]
STRING PROC FNRecordGetMenuCapitalizeDefaultS( STRING inS )
 // e.g. PROC Main()
 // e.g.  Message( FNRecordGetMenuCapitalizeDefaultS( FNStringGetTokenCapitalizeMenuPrefixS() ) ) // gives e.g. "MENU qgetjobdefault"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetRecordGetMenuCapitalizeCentralS( inS, "default" ) )
 //
END

// library: record: get: menu: capitalize: second <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getrecs.s) [<Program>] [<Research>] [kn, ri, sa, 20-04-2002 20:21:44]
STRING PROC FNStringGetRecordGetMenu_CapitalizeSecondS( STRING inS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecordGetMenu_CapitalizeSecondS( FNStringGetTokenCapitalizeMenuPrefixS() ) ) // gives e.g. "MENU qget"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetRecordGetMenuCapitalizeCentralS( inS, "second" ) )
 //
END

// library: record: get: menu: capitalize: first: second <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getrefs.s) [<Program>] [<Research>] [kn, ri, sa, 20-04-2002 20:21:44]
STRING PROC FNStringGetRecordGet_MenuCapitalizeFirstSecondS( STRING inS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecordGet_MenuCapitalizeFirstSecondS( FNStringGetTokenCapitalizeMenuPrefixS() ) ) // gives e.g. "MENU qrecordget"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetRecordGetMenuCapitalizeCentralS( inS, "firstsecond" ) )
 //
END

// library: error: case: not: found <description>error: case: not: found</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=caseernf.s) [<Program>] [<Research>] [[kn, ri, we, 28-02-2001 23:08:10]
PROC PROCErrorCaseNotFound( STRING infoS, STRING procfnnameS, STRING caseS )
 // e.g. PROC Main()
 // e.g.  PROCErrorCaseNotFound( infoS, procfnnameS, caseS )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCError( FNStringGetCons5S( procfnnameS, infoS, ": case: ", caseS, " not found / unknown option" ) )
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

// library: error: check <description>error: test if an error occurred, via testing the output // version with testing local variable. Better.</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=checercs.s) [<Program>] [<Research>] [[kn, ni, we, 05-08-1998 20:27:34]
INTEGER PROC FNErrorCheckSB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNErrorCheckSB( "this is an error" ) ) // version with testing local variable. Better. ) // gives TRUE or FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( s, FNStringGetErrorS() ) )
 //
END

// library: math: check: get: logic: false: wrapper <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmalf.s) [<Program>] [<Research>] [kn, ri, su, 22-07-2001 15:43:08]
INTEGER PROC FNMathCheckGetLogicFalseB()
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckGetLogicFalseB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FALSE )
 //
END

// library: string: check: search: found: not (search: not found?) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checstfq.s) [<Program>] [<Research>] [kn, ri, tu, 13-11-2001 05:54:19]
INTEGER PROC FNStringCheckSearchFoundNotB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckSearchFoundNotB( FNStringGetEmptyS() ) ) // gives e.g. FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( s, FNStringGetSearchFoundNotS() ) )
 //
END

// library: file: search all occurrences in the current file, starting from the begin of the file <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=searfise.s) [<Program>] [<Research>] [kn, ri, fr, 13-07-2001 12:31:01]
INTEGER PROC FNFileCheckSearchExpressionB( STRING searchS, STRING searchOptionS )
 // e.g. PROC Main()
 // e.g.  Message( FNFileCheckSearchExpressionB( "test", FNStringGetEmptyS() ) ) // gives TRUE when "test" is found in current file
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNTextCheckSearchExpressionFoundB( searchS, FNStringGetConcatS( searchOptionS, "g" ) ) )
 //
END

// library: string: get: block: menu: ampersand: all <description></description> <version control></version control> <version>1.0.0.0.16</version> <version control></version control> (filenamemacro=getlstaa.s) [<Program>] [<Research>] [kn, ri, fr, 30-11-2012 15:24:18]
STRING PROC FNStringGetBlockMenuAmpersandAllS()
 // e.g. PROC Main()
 // e.g.  STRING s[255] = ""
 // e.g.  s = FNStringGetBlockMenuAmpersandAllS() // gives e.g. "ABCDE"
 // e.g.  CopyToWinClip( s )
 // e.g.  Message( "Copied to Microsoft Windows clipboard", ":", " ", s ) // gives e.g. "Copied to Microsoft Windows clipboard: ABCDE"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s1[255] = ""
 //
 STRING s2[255] = ""
 //
 IF FNBlockCheckIsMarkedNotCurrentDefaultMessageB() RETURN( FNStringGetEmptyS() ) ENDIF // return from the current procedure if no block is marked
 //
 PushPosition()
 //
 GotoBlockBegin()
 //
 WHILE ( ( LFind( '^[ ]*"&{.}:\c', "lx" ) ) AND ( IsCursorInBlock() ) ) // assumes ampersand is in the beginning of the line '^', after a double quote '"' and followed by a colon ':'. This is my special menu notation. For a more general one change the regular expression
  //
  s1 = GetFoundText( 1 )
  //
  s2 = Format( s2, s1 )
  //
 ENDWHILE
 //
 GotoBlockBegin()
 //
 WHILE ( ( LFind( "^[ ]*'&{.}:\c", "lx" ) ) AND ( IsCursorInBlock() ) ) // assumes ampersand is in the beginning of the line '^', after a single quote '"' and followed by a colon ':'. This is my special menu notation. For a more general one change the regular expression
  //
  s1 = GetFoundText( 1 )
  //
  s2 = Format( s2, s1 )
  //
 ENDWHILE
 //
 PopPosition()
 //
 RETURN(  s2 )
 //
END

// library: string: get: block: menu: ampersand: available: next <description></description> <version control></version control> <version>1.0.0.0.10</version> <version control></version control> (filenamemacro=getstani.s) [<Program>] [<Research>] [kn, ri, fr, 30-11-2012 22:21:13][kn, ri, fr, 19-08-2022 01:48:30]
STRING PROC FNStringGetBlockMenuAmpersand_AvailableNextS( STRING hotKeyUniqueS, STRING hotKeyUniqueAllS )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "ABCDEFGH"
 // e.g.  STRING s2[255] = FNStringGetMenuHotkeyAmpersandUniqueAllS()
 // e.g.  IF ( NOT ( Ask( "string: get: block: menu: ampersand: available: next: hotKeyUniqueS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "string: get: block: menu: ampersand: available: next: hotKeyUniqueAllS = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Warn( FNStringGetBlockMenuAmpersand_AvailableNextS( s1, s2 ) ) // gives e.g. "I"
 // e.g.  Warn( FNStringGetBlockMenuAmpersand_AvailableNextS( "!#$%&'()*+-./0123456789::;=@ACDEFGHIJKLMNOPQRSTUVWXYZ[\]^_{|}~B" + '"', s2 ) ) // gives e.g. "I"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // Method:
 //
 // 1. -So you basically go through all characters of the given string with found menu characters. E.g. "ABCD".
 //
 // 2. -If that character is found in the all string then you remove that character. So if the all string is "ABCDEFGHIJK" then you remove "A", "B", "C" and "D" from the all string.
 //
 // 3. -Then you are left over with all the not found characters. So here you are left with "EFGHIJK".
 //
 // 4. -From that result you take the first character. So here you return the first character in the not found string which is "E".
 //
 STRING s[255] = FNStringGetCharacterString1InString2AllS( Upper( hotKeyUniqueS ), Upper( hotKeyUniqueAllS ) )
 //
 s = SubStr( s, 1, 1 ) // take off the first character of the result
 //
 RETURN( s )
 //
END

// library: string: get: menu: hotkey: ampersand: unique: all <description></description> <version control></version control> <version>1.0.0.0.15</version> (filenamemacro=getstauo.s) [<Program>] [<Research>] [kn, ri, sa, 26-09-2009 17:39:28]
STRING PROC FNStringGetMenuHotkeyAmpersandUniqueAllS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetMenuHotkeyAmpersandUniqueAllS() ) // gives e.g. "ABCDEFGHIJKLMNOPQRSTUVWXYZ"~!@#$%^*()_+{}|:?>< "
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( FNStringGetAlphabetS() + "0123456789" + "~!@#$%^*()" + "-=" + "_+" + "[]\" + "{}|" + ";'" + ":" + '"' + ",./" + "<>?" + "`" )
 RETURN( FNStringGetAlphabetS() + "0123456789" + "~!@#$%^*()" + "-=" + "_+" + "[]\" + "{}|" + ";'" + ":" + '"' + ",./" + "<>?" + "`" + " " )
 //
END

// library: string: get: record: get: menu: capitalize: central <description>record: get: menu: capitalize</description> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=getstccy.s) [<Program>] [<Research>] [[kn, ri, sa, 20-04-2002 20:21:57]
STRING PROC FNStringGetRecordGetMenuCapitalizeCentralS( STRING inS, STRING caseS )
 // e.g. PROC Main()
 // e.g.  Warn( FNStringGetRecordGetMenuCapitalizeCentralS( FNStringGetTokenCapitalizeMenuPrefixS(), "secondfirstthird" ) ) // gives e.g. "MENU qgetrecord"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNRecordGetDefProcFnNameRestoreS()
 //
 STRING firstS[255] = FNStringGetInitializeNewStringS()
 //
 STRING secondS[255] = FNStringGetInitializeNewStringS()
 //
 STRING thirdS[255] = FNStringGetInitializeNewStringS()
 //
 IF FNErrorCheckSB( s )
  //
  RETURN( s )
  //
 ENDIF
 //
 IF FNStringCheckSearchFoundNotB( s )
  //
  PROCError( s )
  //
  RETURN( s )
  //
 ENDIF
 //
 s = FNStringGetFunction_NameCapitalizeToWordsSeparatorRemoveS( s )
 //
 firstS = FNStringGetCarCapitalizeFirstS( s )
 //
 secondS = FNStringGetCarCapitalizeSecondS( s )
 //
 thirdS = FNStringGetCarCapitalizeThirdS( s )
 //
 CASE caseS
  //
  WHEN "default"
  //
  s = FNStringGetConcat3S( inS, secondS, FNStringGetTokenCapitalizeDefaultMenuS() ) // gives e.g. MENUQGetJobDefault
  //
  WHEN "first"
   //
   s = FNStringGetConcatS( inS, firstS )
   //
  WHEN "second"
   //
   s = FNStringGetConcatS( inS, secondS )
   //
  WHEN "secondfirst"
   //
   s = FNStringGetConcat3S( inS, secondS, firstS )
   //
  WHEN "firstsecond"
   //
   s = FNStringGetConcat3S( inS, firstS, secondS )
   //
  WHEN "secondfirstthird"
   //
   s = FNStringGetConcat4S( inS, secondS, firstS, thirdS )
   //
  OTHERWISE
   //
   PROCErrorCaseNotFound( FNStringGetEmptyS(), "FNStringGetRecordGetMenuCapitalizeCentralS(", caseS )
   //
   s = FNStringGetErrorS()
   //
 ENDCASE
 //
 RETURN( s )
 //
END

// library: record: check: record: select: mark: separator: default <description></description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=checrese.s) [<Program>] [<Research>] [kn, ri, su, 06-11-2011 15:01:01]
INTEGER PROC FNRecordCheckRecordSelectMarkSeparatorDefaultB()
 // e.g. PROC Main()
 // e.g.  Message( FNRecordCheckRecordSelectMarkSeparatorDefaultB() ) // gives e.g. TRUE if record separators could be found
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNRecordCheckRecordSelectMarkSeparatorB( FNStringGetRecordSearchSeparatorDefaultExpressionRegularS() ) )
 //
END

// library: text: get: abbreviation: template: data: extract <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gettedex.s) [<Program>] [<Research>] [kn, ri, mo, 28-05-2007 02:41:59]
PROC PROCTextGetAbbreviation_TemplateDataExtract( STRING s, STRING macroNameS )
 // e.g. PROC Main()
 // e.g.  PROCTextGetAbbreviation_TemplateDataExtract( "su", "template.mac" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextInsert( s )
 //
 PROCMacroRunKeep( macroNameS )
 //
END

// library: record: movement: goto the start of a record: separator <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotorebt.s) [<Program>] [<Research>] [kn, zoe, mo, 11-12-2000 16:38:16]
INTEGER PROC FNRecordCheckGotoBeginSeparatorLineAfterBeginB()
 // e.g. PROC Main()
 // e.g.  Message( FNRecordCheckGotoBeginSeparatorLineAfterBeginB() ) // gives e.g. TRUE
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

// library: string: get: line: search: filename: macro: get: current: default <description>file: search: "filenamemacro=": first occurrence: line: current</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstcdv.s) [<Program>] [<Research>] [[kn, ri, sa, 08-12-2001 19:57:34]
STRING PROC FNStringGetLineSearchFilenameMacroGetCurrentDefaultS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetLineSearchFilenameMacroGetCurrentDefaultS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetLineSearch_FilenameMacroGet_CurrentWarnS() )
 //
END

// library: string: get: file: info: to: file: name <description>given a filename (and possible drive, path, extension), extract the filename (and not the path)</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getstfna.s) [<Program>] [<Research>] [kn, ri, su, 28-03-1999 05:01:23]
STRING PROC FNStringGetFileInfoToFileNameS( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFileInfoToFileNameS( "c:\kee\bbc\taal\ddd.dok" ) ) // gives 'ddd'
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFilenameSplitInPartsS( s, _NAME_ ) )
 //
END

// library: string: get: cons: string: concatenation: concatenation 2 words to 1 word (separated by a space) <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=getstgcx.s) [<Program>] [<Research>] [kn, ri, we, 25-11-1998 20:15:03]
STRING PROC FNStringGetConsS( STRING s1, STRING s2 )
 // e.g. //
 // e.g. // version with test if string empty
 // e.g. //
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConsS( "john", "doe" ) ) // gives "john doe"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatSeparatorS( s1, s2, FNStringGetCharacterSymbolSpaceS() ) )
 //
END

// library: string: get: cons4: string: concatenation: 4 strings <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgcz.s) [<Program>] [<Research>] [kn, zoe, fr, 17-11-2000 13:54:56]
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

// library: file: edit: edit a file, with test of problems <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checficf.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 13:08:39]
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

// library: file: movement: end: goto end of file: moves to the end of the last line of current file <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotofien.s) [<Program>] [<Research>] [kn, ri, su, 28-03-1999 01:08:06]
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

// library: file: insert: end: prepare <description>file: insert: prepare for the insertion (e.g. of text, of a new file, ...)</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=insefiep.s) [<Program>] [<Research>] [[kn, zoe, th, 25-01-2001 18:03:46]
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

// library: text: insert: insert text <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=insetein.s) [<Program>] [<Research>] [kn, ni, mo, 10-08-1998 06:26:51]
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

// library: string: get: global <description>string: global: get: get a global string</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstggl.s) [<Program>] [<Research>] [[kn, zoe, mo, 14-06-1999 20:54:18]
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

// library: string: get: cons5: string: concatenation: 5 strings <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgcb.s) [<Program>] [<Research>] [kn, zoe, fr, 17-11-2000 13:55:03]
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

// library: string: get: search: found: not <description>indicate that the search was not successful</description> <version>1.0.0.0.2</version> (filenamemacro=getstfnp.s) [<Program>] [<Research>] [kn, ri, su, 26-12-1999 23:40:07]
STRING PROC FNStringGetSearchFoundNotS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchFoundNotS() ) // gives e.g. "not found"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "not found" )
 //
END

// library: text: check: search: expression: found <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checteei.s) [<Program>] [<Research>] [kn, ri, sa, 25-08-2001 21:58:50]
INTEGER PROC FNTextCheckSearchExpressionFoundB( STRING searchS, STRING searchOptionS )
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckSearchExpressionFoundB( "test", "i" ) ) // gives e.g. TRUE when that text is found
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckNumberEqualZeroNotB( FNTextCheckSearchExpressionB( searchS, searchOptionS ) ) )
 //
END

// library: string: get: concat <description>concatenation 2 words tot 1 word</description> <version>1.0.0.0.3</version> (filenamemacro=getstgch.s) [<Program>] [<Research>] [kn, zoe, th, 01-02-2001 19:32:49]
STRING PROC FNStringGetConcatS( STRING s1, STRING s2 )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConcatS( "test1", "test2" ) ) // version with test if string empty ) // gives e.g. "test1test2"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatSeparatorS( s1, s2, FNStringGetEmptyS() ) )
 //
END

// library: block: mark: if NO block in CURRENT file marked, give a default message <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checbldm.s) [<Program>] [<Research>] [kn, ri, su, 17-10-1999 08:21:38]
INTEGER PROC FNBlockCheckIsMarkedNotCurrentDefaultMessageB()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockCheckIsMarkedNotCurrentDefaultMessageB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNBlockCheckIsMarkedNotCurrentMessageB( "No block is marked in current file. First mark a block" ) )
 //
END

// library: string: get: character: string1: in: string2: all <description>the two strings do not have to be sorted, as the characters from string1 are one by one taken out, searched for in the whole of string2, and removed when found</description> <version control></version control> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstisu.s) [<Program>] [<Research>] [kn, ri, fr, 30-11-2012 22:22:48]
STRING PROC FNStringGetCharacterString1InString2AllS( STRING s1, STRING s2 )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterString1InString2AllS( "DEF", "ABCDEFGHIJK" ) ) // gives e.g. "ABCGHIJK"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER minI = 1
 INTEGER maxI = Length( s1 )
 INTEGER I = 0
 //
 STRING s[255] = s2
 //
 STRING characterS[1] = ""
 //
 FOR I = minI TO maxI
  //
  characterS = SubStr( s1, I, 1 )
  //
  s = StrReplace( characterS, s, FNStringGetEmptyS(), "gn" )
  //
 ENDFOR
 //
 RETURN( s )
 //
END

// library: string: get: alphabet: upper <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgal.s) [<Program>] [<Research>] [kn, ri, th, 11-04-2002 23:03:10]
STRING PROC FNStringGetAlphabetS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetAlphabetS() ) // gives e.g. "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "ABCDEFGHIJKLMNOPQRSTUVWXYZ" )
 //
END

// library: record: get: def: proc: fn: name <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getprfnn.s) [<Program>] [<Research>] [kn, ri, mo, 01-04-2002 15:49:54]
STRING PROC FNRecordGetDefProcFnNameRestoreS()
 // e.g. PROC Main()
 // e.g.  Message( FNRecordGetDefProcFnNameRestoreS() ) // gives e.g. "FNRecordGetDefProcFnNameS()"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 PROCSituationStoreOld()
 //
 s = FNRecordGetDefProcFnNameRestoreNotS()
 //
 PROCSituationRestoreOld()
 //
 RETURN( s )
 //
END

// library: string: get: function: name: capitalize: to: words: separator: remove <description>function/procedure: name: capitalize: to: words: separator</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstsre.s) [<Program>] [<Research>] [[kn, ri, su, 02-09-2001 02:47:27]
STRING PROC FNStringGetFunction_NameCapitalizeToWordsSeparatorRemoveS( STRING inS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFunction_NameCapitalizeToWordsSeparatorRemoveS( inS ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = inS
 //
 IF FNStringCheckEmptyB( s )
  //
  PROCWarn( "do not enter an empty string" )
  //
  RETURN( FNStringGetErrorS() )
  //
 ENDIF
 //
 s = FNStringGetRemoveAllS( s, FNStringGetCharacterSymbolUnderScoreS() )
 //
 s = FNStringGetRemoveAllS( s, "B()" )
 //
 s = FNStringGetRemoveAllS( s, "B(" )
 //
 s = FNStringGetRemoveAllS( s, "D()" )
 //
 s = FNStringGetRemoveAllS( s, "D(" )
 //
 s = FNStringGetRemoveAllS( s, "F()" )
 //
 s = FNStringGetRemoveAllS( s, "F(" )
 //
 s = FNStringGetRemoveAllS( s, "I()" )
 //
 s = FNStringGetRemoveAllS( s, "I(" )
 //
 s = FNStringGetRemoveAllS( s, "P()" )
 //
 s = FNStringGetRemoveAllS( s, "P(" )
 //
 s = FNStringGetRemoveAllS( s, "S()" )
 //
 s = FNStringGetRemoveAllS( s, "S(" )
 //
 s = FNStringGetRemoveAllS( s, "()" )
 //
 s = FNStringGetRemoveAllS( s, "(" )
 //
 s = FNStringGetRemoveAllS( s, FNStringGetTokenFunctionNameCaseUpperS() )
 //
 s = FNStringGetRemoveAllS( s, FNStringGetTokenProgram_ProcedureNameCaseUpperS() )
 //
 s = FNStringGetRemoveAllS( s, "MENU" )
 //
 s = FNStringGetRemoveAllS( s, "KEYDEF" )
 //
 s = FNStringGetRemoveAllS( s, "DATADEF" )
 //
 s = FNStringGetRemoveAllS( s, "HELPDEF" )
 //
 RETURN( s )
 //
END

// library: string: get: capitalize: front: first: while you find in front, get that front part: iterative version <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcc1.s) [<Program>] [<Research>] [kn, ri, su, 07-04-2002 23:48:18]
STRING PROC FNStringGetCarCapitalizeFirstS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: get: capitalize: car: first: string = ", "ThisIsACapitalizedString" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCarCapitalizeFirstS( s ) ) // gives e.g. "This"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCarCapitalizeNS( s, 1 ) )
 //
END

// library: string: get: capitalize: front: second: while you find in front, get that front part: iterative version <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcc2.s) [<Program>] [<Research>] [kn, ri, su, 07-04-2002 23:48:18]
STRING PROC FNStringGetCarCapitalizeSecondS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: get: capitalize: car: second: string = ", "ThisIsACapitalizedString" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCarCapitalizeSecondS( s ) ) // gives e.g. "This"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCarCapitalizeNS( s, 2 ) )
 //
END

// library: string: get: capitalize: front: third: while you find in front, get that front part: iterative version <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcc3.s) [<Program>] [<Research>] [kn, ri, su, 07-04-2002 23:48:18]
STRING PROC FNStringGetCarCapitalizeThirdS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: get: capitalize: car: third: string = ", "ThisIsACapitalizedString" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCarCapitalizeThirdS( s ) ) // gives e.g. "This"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCarCapitalizeNS( s, 3 ) )
 //
END

// library: string: get: concat3 <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgcp.s) [<Program>] [<Research>] [kn, zoe, th, 01-02-2001 19:32:49]
STRING PROC FNStringGetConcat3S( STRING s1, STRING s2, STRING s3 )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConcat3S( "PROC", "Test", "(" ) ) // gives "PROCTest("
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatS( FNStringGetConcatS( s1, s2 ), s3 ) )
 //
END

// library: string: get: token: capitalize: default: menu <description></description> <version control></version control> <version>1.0.0.0.4</version> <version control></version control> (filenamemacro=getstdme.s) [<Program>] [<Research>] [kn, vo, fr, 09-05-2014 13:12:16]
STRING PROC FNStringGetTokenCapitalizeDefaultMenuS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenCapitalizeDefaultMenuS() ) // gives e.g. "JobMain"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( "JobDefault" ) // "default" old [kn, ri, sa, 04-01-2020 14:10:30]
 // RETURN( "JobMain" ) // "default" new [kn, ri, sa, 04-01-2020 14:10:30]
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetTokenCapitalizeDefaultMenuS" ) )
 //
END

// library: string: get: concat4: string: concatenation: 4 strings <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgcq.s) [<Program>] [<Research>] [kn, zoe, th, 01-02-2001 19:32:59]
STRING PROC FNStringGetConcat4S( STRING s1, STRING s2, STRING s3, STRING s4 )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConcat4S( "a", "b", "c", "d" ) ) // gives "abcd"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatS( FNStringGetConcat3S( s1, s2, s3 ), s4 ) )
 //
END

// library: record: check: record: select: mark: separator <description></description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=checremu.s) [<Program>] [<Research>] [kn, ri, su, 06-11-2011 14:35:56]
INTEGER PROC FNRecordCheckRecordSelectMarkSeparatorB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNRecordCheckRecordSelectMarkSeparatorB( FNStringGetRecordSearchSeparatorDefaultExpressionRegularS() ) ) // gives e.g. TRUE if record separators could be found
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER lineBeginI = 0
 //
 INTEGER lineEndI = 0
 //
 PushPosition()
 //
 PushBlock()
 //
 IF ( LFind( s, "x" ) )
  //
  Up()
  //
  lineEndI = CurrLine()
  //
 ELSE
  //
  PopBlock()
  //
  PopPosition()
  //
  RETURN( FALSE )
  //
 ENDIF
 //
 IF ( LFind( s, "bx" ) )
  //
  Down()
  //
  lineBeginI = CurrLine()
  //
 ELSE
  //
  PopBlock()
  //
  PopPosition()
  //
  RETURN( FALSE )
  //
 ENDIF
 //
 PopBlock()
 //
 MarkLine( lineBeginI, lineEndI )
 //
 PopPosition()
 //
 RETURN( TRUE )
 //
END

// library: string: get: record: search: separator: default: expression: regular <description></description> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=getstern.s) [<Program>] [<Research>] [kn, ri, su, 06-11-2011 13:49:26]
STRING PROC FNStringGetRecordSearchSeparatorDefaultExpressionRegularS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecordSearchSeparatorDefaultExpressionRegularS() ) // gives e.g. "^ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ$"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( Format( "^", FNStringGetRecordSeparatorDefaultS(), "$" ) )
 //
 RETURN( Format( FNStringGetRecordSeparatorBeginDefaultS(), FNStringGetRecordSeparatorDefaultS(), FNStringGetRecordSeparatorEndDefaultS() ) )
 //
END

// library: movement: line: up: go to the previous line <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checcucu.s) [<Program>] [<Research>] [kn, zoe, mo, 29-03-1999 20:34:26]
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

// library: text: goto: line: begin // goto begin of line (=column 1 of the current line). If the cursor is already at the beginning of the current line, zero is returned. See also: EndLine() <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotolibe.s) [<Program>] [<Research>] [kn, zoe, th, 17-06-1999 00:12:52]
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

// library: cursor: goto: down <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotocugd.s) [<Program>] [<Research>] [kn, zoe, tu, 15-06-1999 23:46:50]
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

// library: file: check: line: first <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checfilp.s) [<Program>] [<Research>] [kn, zoe, mo, 11-12-2000 17:09:53]
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

// library: string: get: line: search: filename: macro: get: current: warn <description>file: search: "filenamemacro=": first occurrence: line: current: warning when not found</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstcwa.s) [<Program>] [<Research>] [[kn, ri, sa, 08-12-2001 19:57:34]
STRING PROC FNStringGetLineSearch_FilenameMacroGet_CurrentWarnS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetLineSearch_FilenameMacroGet_CurrentWarnS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNLineSearchFilenameMacroGet_CurrentS( FNStringGetSearchFilenameMacroExpressionRegularS(), FNMathCheckGetLogicTrueB() ) )
 //
END

// library: string: get: filename: split: in: parts <description>split the given filename in its parts (e.g. split in drive, path, filename, extension or combinations)</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstipa.s) [<Program>] [<Research>] [kn, zoe, mo, 05-07-1999 18:56:12]
STRING PROC FNStringGetFilenameSplitInPartsS( STRING s, INTEGER optionV )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFilenameSplitInPartsS( "d:\kee\temp\ddd.bbc", _PATH_ ) ) // gives '\kee\temp\'
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( SplitPath( s, optionV ) )
 //
END

// library: string: get: concat: separator: string: concatenation: concatenate 2 words to 1 word, separated by separator <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcsg.s) [<Program>] [<Research>] [kn, zoe, th, 01-07-1999 01:33:18]
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

// library: string: get: character: symbol: " " <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstssp.s) [<Program>] [<Research>] [kn, zoe, we, 25-10-2000 01:33:39]
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

// library: file: check: edit: central: message <description></description> <version control></version control> <version>1.0.0.0.7</version> <version control></version control> (filenamemacro=checfiex.s) [<Program>] [<Research>] [kn, ho, mo, 17-04-2006 17:41:21]
INTEGER PROC FNFileCheckEditCentralMessageB( STRING filenameS, INTEGER messageB )
 // e.g. PROC Main()
 // e.g.  Message( FNFileCheckEditCentralMessageB( "test.dok", FNMathCheckGetLogicFalseB() ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER editfileB = FNMathCheckGetLogicFalseB()
 //
 STRING s[255] = ""
 //
 // here the file is loaded in TSE menu "&Load..." [kn, ri, fr, 10-02-2023 01:59:37]
 //
 if FNStringCheckEmptyB( filenameS )
  //
  PushKey( <ALT Del> ) // delete to end of line // added [kn, ri, fr, 10-02-2023 02:07:49]
  PushKey( <Home> ) // goto beginning of the box // added [kn, ri, fr, 10-02-2023 02:07:49]
  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
  editfileB = EditFile()
  //
 ELSE
  //
  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
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
 IF ( ( WhichOS() == _WINDOWS_ ) OR ( WhichOS() == _WINDOWS_NT_ ) )
  //
  PROCMacroRunPurgeParameter( "runprmcn", Format( FNStringGetMachineNameS(), ";", FNStringGetUserNameFirstS(), ";", FNStringGetUserNameLastS(), ";", FNStringGetPortS(), ";", "TSE%3A+File%3A+Load%3A+" + s + "&submit01=Create" ) )
  //
 ENDIF
 //
 RETURN( editfileB )
 //
END

// library: file: check: goto: end <description>file: movement: end: goto end of file: moves to the end of the last line of current file</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checfigs.s) [<Program>] [<Research>] [[kn, ri, su, 28-03-1999 01:08:06]
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

// library: line: insert: inserts 1 line after current line. The cursor is placed on the newly created line. The cursor column does not change <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=inseliaf.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 13:35:30]
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

// library: text: check: insert <description>text: insert: insert text</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checteci.s) [<Program>] [<Research>] [[kn, zoe, tu, 23-11-1999 20:30:45]
INTEGER PROC FNTextCheckInsertB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckInsertB( s ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNTextCheckInsertCentralB( s, _INSERT_ ) )
 //
END

// library: file: filename: get: current: return current filename (as a string containing the complete path) (Get Full Name of Current Buffer) (nofilenamemacro) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstfcv.s) [<Program>] [<Research>] [kn, ni, sa, 08-08-1998 00:02:37] [FNfilenamecurrent]
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

// library: text: search: return true if found <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=searteex.s) [<Program>] [<Research>] [kn, ni, fr, 07-08-1998 19:36:39]
INTEGER PROC FNTextCheckSearchExpressionB( STRING searchS, STRING searchOptionS )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING searchOptionS[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "text: search: string = ", "test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  searchOptionS = FNStringGetInputS( "text: search: string = ", "test" )
 // e.g.  IF FNKeyCheckPressEscapeB( searchOptionS ) RETURN() ENDIF
 // e.g.  Message( FNTextCheckSearchExpressionB( s, searchOptionS ) ) // gives e.g. TRUE when the string is found in the text
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER foundB = LFind( searchS, searchOptionS )
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

// library: block: mark: if NO block in CURRENT file marked, give a message <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checblcn.s) [<Program>] [<Research>] [kn, ri, su, 17-10-1999 08:21:38]
INTEGER PROC FNBlockCheckIsMarkedNotCurrentMessageB( STRING s )
 // e.g. PROC Main()
 // e.g.  IF FNBlockCheckIsMarkedNotCurrentMessageB( "No block is marked in current file" ) RETURN() ENDIF // return from the current procedure if no block is marked
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER blockcurrentismarkedB = FNBlockCheckCurrentIsMarkedB()
 //
 IF FNMathCheckLogicNotB( blockcurrentismarkedb ) // block is not marked
  //
  PROCWarn( s )
  //
 ENDIF
 //
 RETURN( FNMathCheckLogicNotB( blockcurrentismarkedB ) )
 //
END

// library: record: get: def: proc: fn: name <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getprfrn.s) [<Program>] [<Research>] [kn, ri, mo, 01-04-2002 15:49:54]
STRING PROC FNRecordGetDefProcFnNameRestoreNotS()
 // e.g. PROC Main()
 // e.g.  Message( FNRecordGetDefProcFnNameRestoreNotS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 STRING defprocfnS[255] = FNStringGetInitializeNewStringS()
 //
 STRING procfnS[255] = FNStringGetInitializeNewStringS()
 //
 STRING fileextensioncurrentS[255] = FNFileGetExtensionCurrentPointS()
 //
 PROCRecordGotoBegin_Separator_LineGotoSecondLineGotoBegin()
 //
 defprocfnS = FNStringGetSearch_ProcedureDefinitionExpressionS( fileextensioncurrentS )
 //
 s = FNStringGetSearchFoundNotS()
 //
 IF FNLineCheck_SearchExpressionFoundB( defprocfnS, FNStringGetSearchOptionExpressionRegularS() )
  //
  procfnS = FNStringGetSearchProcedureNameExpressionS( fileextensioncurrentS )
  //
  IF FNLineCheck_SearchExpressionFoundB( procfnS, FNStringGetSearchOptionExpressionRegularS() )
   //
   s = FNStringGetTextFoundMarkS()
   //
  ENDIF
  //
 ENDIF
 //
 RETURN( FNStringGetSpaceRemoveBeginEndS( s ) )
 //
END

// library: string: get: remove: all <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstral.s) [<Program>] [<Research>] [kn, ri, sa, 01-09-2001 23:22:32]
STRING PROC FNStringGetRemoveAllS( STRING givenS, STRING removeS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRemoveAllS( "This is a &test", "&" ) ) // gives "This is a test"
 // e.g.  // Message( FNStringGetRemoveAllS( "knud was here or is here", " here" ) ) // gives "knud was or is"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetReplaceAllS( removeS, FNStringGetEmptyS(), givenS ) )
 //
END

// library: string: get: character: symbol: "_" <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstusc.s) [<Program>] [<Research>] [kn, ri, su, 02-09-2001 02:38:02]
STRING PROC FNStringGetCharacterSymbolUnderScoreS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterSymbolUnderScoreS() ) // gives "_"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterSymbolCentralS( 95 ) )
 //
END

// library: string: get: function: name: symbol <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstnsy.s) [<Program>] [<Research>] [kn, ni, su, 15-06-2003 17:52:33]
STRING PROC FNStringGetTokenFunctionNameCaseUpperS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenFunctionNameCaseUpperS() ) // gives e.g. "FN"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetTokenCaseUpperCentralS( FNStringGetTokenProgramFunctionNameS() ) )
 //
END

// library: string: get: procedure: name: symbol: case: upper <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstnsz.s) [<Program>] [<Research>] [kn, ni, su, 15-06-2003 17:52:59]
STRING PROC FNStringGetTokenProgram_ProcedureNameCaseUpperS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenProgram_ProcedureNameCaseUpperS() ) // gives e.g. "PROC"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetTokenCaseUpperCentralS( FNStringGetTokenProgramProcedureNameS() ) )
 //
END

// library: string: get: capitalize: front: while you find in front, get that front part: iterative version <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstccn.s) [<Program>] [<Research>] [kn, ri, mo, 08-04-2002 00:07:55]
STRING PROC FNStringGetCarCapitalizeNS( STRING inS, INTEGER maxI )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING nrS[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: get: capitalize: carN: string = ", "ThisIsACapitalizedString" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  nrS = FNStringGetInputS( "string: get: capitalize: carN: nr = ", "2" )
 // e.g.  IF FNKeyCheckPressEscapeB( nrS ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCarCapitalizeNS( s, FNStringGetToIntegerI( nrS ) ) ) // gives e.g. "This"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = inS
 //
 STRING firstS[255] = FNStringGetInitializeNewStringS()
 //
 INTEGER I = FNMathGetInitializeNewI()
 //
 FOR I = 1 TO maxI
  //
  firstS = FNStringGetCarCapitalizeS( s )
  //
  s = FNStringGetCdrCapitalizedS( s )
  //
 ENDFOR
 //
 RETURN( firstS )
 //
END

// library: string: get: file: ini: default <description></description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getstids.s) [<Program>] [<Research>] [kn, ri, th, 16-10-2025 00:57:40]
STRING PROC FNStringGetFileIniDefaultS( STRING searchS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFileIniDefaultS( "path4dos" ) ) // gives e.g. "c:\4dos"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 // e.g.
 //
 RETURN( FNStringGetFileIniDefaultCrossPlatformS( searchS ) )
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

// library: string: get: record: separator: default <description></description> <version>1.0.0.0.4</version> <version control></version control> (filenamemacro=getstsds.s) [<Program>] [<Research>] [kn, zoe, fr, 17-11-2000 15:50:54]
STRING PROC FNStringGetRecordSeparatorDefaultS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRecordSeparatorDefaultS() ) // gives e.g. "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
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

// library: text: separator: line: is this a text separator line? <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=chectesl.s) [<Program>] [<Research>] [kn, ni, sa, 11-10-2003 17:23:45]
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
INTEGER PROC FNLineCheckGotoBeginB()
 // e.g. //
 // e.g. // version not central
 // e.g. //
 // e.g. PROC Main()
 // e.g.  Message( "Goto the beginning of the line = ", FNLineCheckGotoBeginB() )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( BegLine() )
 //
END

// library: cursor: check: down: not <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checcudn.s) [<Program>] [<Research>] [kn, ni, mo, 05-05-2003 19:49:32]
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

// library: math: number: compare: equal: are two given numbers equal? <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmaie.s) [<Program>] [<Research>] [kn, zoe, fr, 01-12-2000 19:01:34]
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

// library: file: get: line: first (the number of the first line in the file) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getfilfi.s) [<Program>] [<Research>] [kn, ri, su, 17-10-1999 05:52:52]
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

// library: line: search: filename: macro: get: current <description>line: search: filename: macro: get: "filenamemacro=": first occurrence: line: current</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=searligc.s) [<Program>] [<Research>] [[kn, ri, sa, 08-12-2001 19:57:34]
STRING PROC FNLineSearchFilenameMacroGet_CurrentS( STRING inS, INTEGER warnB )
 // e.g. PROC Main()
 // e.g.  Message( FNLineSearchFilenameMacroGet_CurrentS( inS, warnB ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = inS
 //
 PROCSituationStoreOld()
 //
 PROCLineSelectMarkCurrent()
 //
 IF warnB
  //
  s = FNStringGetBlock_SearchFilenameMacroFirstWarnS( s )
  //
 ELSE
  //
  s = FNStringGetBlockSearchFilenameMacroFirstWarnNotS( s )
  //
 ENDIF
 //
 PROCSituationRestoreOld()
 //
 RETURN( s )
 //
END

// library: string: get: search: text: filenamemacro: "filenamemacro=": first occurrence: line: current: get the regular expression to find the 'filenamemacro=' position in the text <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=searfint.s) [<Program>] [<Research>] [kn, ri, mo, 11-03-2002 22:45:37]
STRING PROC FNStringGetSearchFilenameMacroExpressionRegularS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchFilenameMacroExpressionRegularS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetExpressionRegularGotoEndS( FNStringGetConcatS( FNStringGet_FilenameGlobalFilenameMacroS(), FNStringGetEmptyS() ) ) )
 //
END

// library: string: get: character: symbol: central <description>string: get: character: symbol: central</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstscm.s) [<Program>] [<Research>] [[kn, ri, sa, 07-07-2001 22:35:39]
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

// library: error: file: not: found <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=fileernf.s) [<Program>] [<Research>] [kn, ri, we, 28-02-2001 23:02:12]
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

// library: macro: run: purge: parameter <description>macro: run a macro, then purge it, pass parameter string</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=runmappa.s) [<Program>] [<Research>] [[kn, ri, sa, 17-02-2001 02:22:27]
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

// library: string: get: machine: name <description></description> <version control></version control> <version>1.0.0.0.5</version> (filenamemacro=getstmnc.s) [<Program>] [<Research>] [kn, ri, we, 16-06-2010 22:41:10]
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

// library: string: get: user: name: first <description></description> <version control></version control> <version>1.0.0.0.5</version> (filenamemacro=getstnfi.s) [<Program>] [<Research>] [kn, ri, we, 16-06-2010 22:40:16]
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

// library: line: insert: after: line: goto: begin: text: insert <description>line insert after: insert text at first column (text: insert: after each other)</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=inselitj.s) [<Program>] [<Research>] [[kn, zoe, we, 28-02-2001 20:24:53]
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

// library: text: check: insert: central <description>text: insert: insert text: central</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checteic.s) [<Program>] [<Research>] [[kn, ri, fr, 16-02-2001 22:00:44]
INTEGER PROC FNTextCheckInsertCentralB( STRING s, INTEGER optionB )
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckInsertCentralB( s, optionB ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( InsertText( s, optionB ) )
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

// library: text: search: find: scroll: left <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=seartesl.s) [<Program>] [<Research>] [kn, ri, sa, 21-05-2005 16:07:12]
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

// library: block: mark: is a block marked in CURRENT file? <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checblim.s) [<Program>] [<Research>] [kn, zoe, th, 20-05-1999 12:41:49]
INTEGER PROC FNBlockCheckCurrentIsMarkedB()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockCheckCurrentIsMarkedB() ) // gives TRUE if a block is marked in the current file
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckLogicNotB( FNMathCheckNumberEqualZeroB( FNBlockGetCurrentMarkedTypeI() ) ) )
 //
END

// library: file: filename: get: extension: current: current extension (included the '.' in front). <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getficpo.s) [<Program>] [<Research>] [kn, ri, su, 28-03-1999 05:01:23]
STRING PROC FNFileGetExtensionCurrentPointS()
 // e.g. PROC Main()
 // e.g.  Message( FNFileGetExtensionCurrentPointS() ) // gives '.dok', if e.g. the filename is 'c:\kee\bbc\taal\ddd.dok'
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( CurrExt() )
 //
END

// library: record: goto: begin: separator: line: goto: down <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotorbsb.s) [<Program>] [<Research>] [kn, ri, mo, 01-04-2002 18:36:32]
PROC PROCRecordGotoBegin_Separator_LineGotoSecondLineGotoBegin()
 // e.g. PROC Main()
 // e.g.  PROCRecordGotoBegin_Separator_LineGotoSecondLineGotoBegin()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCRecordGotoBeginSeparator_CursorGotoDownLineGotoBegin()
 //
END

// library: search: procedure: regular expression: procedure/function: definition: return the regular expression to find the DEFINITION of the defined procedures or functions. Regular expressions from tse themselves (see qeditknu.ui) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstdex.s) [<Program>] [<Research>] [kn, ni, th, 06-08-1998 23:26:12]
STRING PROC FNStringGetSearch_ProcedureDefinitionExpressionS( STRING fileextensionS )
 // e.g. //
 // e.g. // see 'GetFunctionStr()' in qedit.ui from Semware
 // e.g. //
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "search: procedure: regular expression: procedure/function: definition: file: extension = ", FNFileGetExtensionCurrentPointS() )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( FNStringGetSearch_ProcedureDefinitionExpressionS( s ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ---
 //
 // expected result after you found such an expression:
 //
 //  you should highlight all characters from the start of the line
 //
 //  until (included) the first character of the procedure or function
 //
 //  name
 //
 //  e.g.
 //
 //  DEF PROCMyProcedure
 //
 //  ³       ³
 //
 //  ÀÄÄÄÄÄÄÄÙ
 //
 //  ^
 //
 //  |
 //
 //  cursor here, at first character, and that block highlighted
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 STRING definitionfirstexpressionS[255] = FNStringGetSearchProcedureDefinitionExpressionFirstS( fileextensionS )
 //
 CASE fileextensionS
  //
  WHEN ".b36" // which language? (see search.s, macdownload) [kn, ni, tu, 11-08-1998 03:20:10]
    //
    s = definitionfirstexpressionS + "[a-zA-Z_\$].*=.*$"
    //
  WHEN ".bas", ".bbc" // BBCBASIC
   //
   // regular expression: BBCBASIC: First 'begin of line'. Then 0 or more spaces (maximum closure). Then 0 or more characters of the type 0-9. Then 0 or more spaces. Then the word 'DEF'. Then 0 or more spaces. Then the word 'FN' or 'PROC'. Changed to take into account BBCBASIC .bas files [kn, ni, th, 06-08-1998 21:57:35]
    //
    s = definitionfirstexpressionS + "{PROC}|{FN}"
       //
       // LEAVE THIS: s = "{^ @def fn}|{^ @sub}" // regular expression: First 'begin of line'. Then 0 or more spaces. Then the word 'def fn' or 'sub'. // old, leave it (it is the old definition for the BASIC .bas files) [kn, ni, th, 06-08-1998 21:57:35]
       //
  WHEN ".bat", ".dok" // BATCH
    //
    s = definitionfirstexpressionS // test this further [kn, ni, fr, 06-08-1999 03:09:44]
    //
  WHEN ".bbc" // this is a binary file!  [kn, ni, th, 06-08-1998 21:55:33]
    //
    s = definitionfirstexpressionS + "{\d164|\d242}" // regular expression: first the decimal character 221 (this is DEF). Then 0 or more spaces. Then FN (that is decimal 164) OR PROC (that is decimal 242) [kn, ni, sa, 08-08-1998 18:44:56]
    //
  WHEN ".c", ".h", ".pc" // C
   //
   // starts with: 'char', 'char *', 'file *', 'int', 'int pascal', 'long', 'long int', 'long far pascal', 'unsigned', 'void'
   //
   // regular expression: C: First 'begin of line'. Then 0 or more occurrences of the '_' (maximum closure). Then 1 character of the type A-Z or a-z. Then 0 or more occurrences of A-Z, a-z, 0-9, _, *, SPACE character, or the TAB character. Then after that the '('. Then any character except the ';'. Followed by the 'end of line' character. [kn, ni, fr, 07-08-1998 15:32:41]
   //
   // s = "^_@[a-zA-Z][a-zA-Z0-9_* \t]@([~;]*$" // leave this, more general [kn, zoe, tu, 10-08-1999 23:33:47]
   //
   // s = definitionfirstexpressionS + "{PROC}|{FN}" // [kn, zoe, tu, 10-08-1999 23:33:47]
   //
   s = definitionfirstexpressionS + "[a-zA-Z_]" // [kn, zoe, fr, 17-12-1999 22:11:01]
   //
   // LEAVE this, this is very probably regular expression AFTER definition: s = "^{[a-zA-Z_].*}{) *\x7b *{{/\x2a.*\x2a/}|{//.*}}*}$"
   //
  // WHEN ".cob", ".cbl" // cobol [kn, ni, tu, 11-08-1998 03:49:00]
  //
  WHEN ".cpp", ".hpp" // C++
   //
   // regular expression: C++: First 'begin of line'. Then 0 or more occurrences of the '_' or the '~' (maximum closure). Then 1 character of the type A-Z, a-z, ':' or '~'. Then 0 or more occurrences of A-Z, a-z, 0-9, _, *, SPACE character, TAB character, ':' or '~'. Then after that the '('. Then any character except the ';'. Followed by the 'end of line' character. // Note that c++ allows a few extra characters in function names.
   //
   s = "^_|~@[a-zA-Z:~][a-zA-Z0-9_* \t:~]@([~;]*$" // test this further [kn, ni, fr, 06-08-1999 06:22:30]
   //
   // LEAVE this, this is very probably regular expression AFTER definition: s = "^{[a-zA-Z_].*}{) *\x7b *{{/\x2a.*\x2a/}|{//.*}}*}$"
   //
  // WHEN "html", "fortran", "cobol", "lisp", "rpg",... // added knud [kn, ni, fr, 07-08-1998 16:10:32]
  //
  WHEN ".cs" // C#
   //
   s = "^_|~@[a-zA-Z:~][a-zA-Z0-9_* \t:~]@([~;]*$" // test this further [kn, ni, fr, 06-08-1999 06:22:30]
   //
  WHEN ".ini" // ini files
   //
   // regular expression: .INI file: first the character '['. Then any character until the ']'. Then the ']' [kn, ni, fr, 07-08-1998 15:53:39]
   //
   s = definitionfirstexpressionS + "\[.*\]"
   //
  WHEN ".java", ".jav" // Java
   //
   s = "^_|~@[a-zA-Z:~][a-zA-Z0-9_* \t:~]@([~;]*$" // [kn, ri, we, 01-05-2002 00:18:55]
   //
   s = definitionfirstexpressionS + "[a-zA-Z_]" // [kn, zoe, fr, 17-12-1999 22:11:01]
   //
  WHEN ".js" // JavaScript
   //
   s = definitionfirstexpressionS + "[a-zA-Z_]" // [kn, zoe, fr, 17-12-1999 22:11:01]
   //
  WHEN ".lot" // LotusScript
   //
   s = "{^ @def fn}|{^ @sub}" // regular expression: First 'begin of line'. Then 0 or more spaces. Then the word 'def fn' or 'sub'. // old, leave it (it is the old definition for the BASIC .bas files) [kn, ni, th, 06-08-1998 21:57:35]
   //
  WHEN ".cl", ".lsp" // LISP
    //
    s = "defun +\c" // [kn, ri, mo, 26-01-2004 01:52:11]
    //
  WHEN ".map" // Maple
   //
   s = "^[a-zA-Z][a-zA-Z0-9]*" + definitionfirstexpressionS // test further [kn, zoe, mo, 18-12-2000 23:31:36]
   //
  WHEN ".del" // Delphi
   //
   s = definitionfirstexpressionS + "[a-zA-Z_]" // [kn, ri, su, 01-09-2002 23:32:56]
   //
  WHEN ".pas" // Pascal
   //
   s = definitionfirstexpressionS + "[a-zA-Z_]" // [kn, ri, mo, 02-09-2002 00:50:42]
   //
  WHEN ".pc" // PC
   //
   s = definitionfirstexpressionS + "[a-zA-Z_]" // [kn, zoe, fr, 17-12-1999 22:11:01]
   //
  WHEN ".php" // PHP
   //
   s = definitionfirstexpressionS + "[a-zA-Z_]" // same as JavaScript [kn, ri, mo, 22-10-2001 00:19:27]
   //
  WHEN ".pl" // PERL
   //
   s = definitionfirstexpressionS + "[a-zA-Z_]" // [kn, ri, we, 04-09-2002 22:24:48]
   //
  WHEN ".prg",".spr",".mpr",".qpr",".fmt",".frg",".lbg",".ch"
   //
   // regular expression: optionally the word static. Then the word 'procedure' or 'function'. Then 1 or more occurrences of the ' ' (maximum closure). Then 1 occurrence of the characters A-Z, a-z or _
    //
    s = definitionfirstexpressionS + "[a-zA-Z_]"
    //
  WHEN ".py" // Python
   //
   s = definitionfirstexpressionS + "[a-zA-Z_]" // [kn, ri, we, 04-09-2002 22:24:48]
   //
  WHEN ".s", ".ui", ".si" // TSE
   //
   // regular expression: SAL: First 'begin of line'. Then the word 'menu' or 'helpdef' or 'datadef' or ( optionally the word 'public' followed by or the word 'integer' or the word 'string'. Then space 1 or more times). Then the word 'proc'. Then 1 or more spaces. Then 1 character of the type A-Z, a-z or '-'. [kn, ni, fr, 07-08-1998 15:24:15]
    //
    s = definitionfirstexpressionS + "[a-zA-Z_]"
    //
  WHEN ".vb" // Visual Basic
   //
   s = definitionfirstexpressionS + "[a-zA-Z_]" // [kn, ri, mo, 22-12-2003 01:25:05]
   //
  WHEN ".vbs" // VBScript
   //
   s = definitionfirstexpressionS + "[a-zA-Z_]" // [kn, ri, tu, 29-01-2002 23:18:32]
   //
  WHEN ".xf4" // very probably Fortran (see search.s, macdownload) [kn, ni, tu, 11-08-1998 03:20:50]
   //
   s = definitionfirstexpressionS + "[a-zA-Z_\$].*\(.*\)$"
   //
   // s = "^[~Cc*]+SUBROUTINE" // very probably fortran [kn, ni, fr, 06-08-1999 03:07:07]
   //
  WHEN ".xsl" // XSL stylesheet
   //
   s = definitionfirstexpressionS + "[a-zA-Z_]" // [kn, ri, fr, 29-06-2001 16:55:09]
   //
  OTHERWISE
   //
   PROCErrorCaseNotFound( "extension not defined yet", "FNStringGetSearch_ProcedureDefinitionExpressionS(", fileextensionS )
   //
   s = FNStringGetErrorS()
   //
 ENDCASE
 //
 RETURN( s )
 //
END

// library: line: search: expression: found <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=searlifo.s) [<Program>] [<Research>] [kn, ri, mo, 01-04-2002 18:44:49]
INTEGER PROC FNLineCheck_SearchExpressionFoundB( STRING searchS, STRING searchOptionS )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING searchOptionS[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "line: search: expression: found: search string = ", "test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  searchOptionS = FNStringGetInputS( "line: search: expression: found: search option = ", FNStringGetEmptyS() )
 // e.g.  IF FNKeyCheckPressEscapeB( searchOptionS ) RETURN() ENDIF
 // e.g.  Message( FNLineCheck_SearchExpressionFoundB( s, searchOptionS ) ) // gives e.g. TRUE when the string is found in the current line
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNTextCheckSearchExpressionFoundB( searchS, FNStringGetConcatS( "c", searchOptionS ) ) )
 //
END

// library: string: get: search: option: expression: regular <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getsteri.s) [<Program>] [<Research>] [kn, ri, tu, 05-04-2005 13:00:25]
STRING PROC FNStringGetSearchOptionExpressionRegularS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchOptionExpressionRegularS() ) // gives e.g. "x"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "x" )
 //
END

// library: search: procedure: regular expression: procedure/function: name: return the regular expression to find every occurrence of the NAME (inclusive any spaces in front. The cursor goes to the first open parenthese of the parameters) of the defined procedures or functions. Regular expressions from tse themselves (see qeditknu.ui) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstnex.s) [<Program>] [<Research>] [kn, ni, fr, 07-08-1998 16:11:08]
STRING PROC FNStringGetSearchProcedureNameExpressionS( STRING fileextensionS )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "search: procedure: regular expression: procedure/function: name: file: extension = ", FNFileGetExtensionCurrentPointS() )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( FNStringGetSearchProcedureNameExpressionS( s ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ---
 //
 // expected result after you found such an expression:
 //
 //  you should highlight all spaces between the DEF PROC or DEF FN
 //
 //  (not included) and the complete name of the function, including
 //
 //  the first parenthesis of the parameter(s)
 //
 //  e.g.
 //
 //     PROCMyProcedure(
 //
 //  ³ ³               ^
 //  ÀÄÙ               ³
 //  spaces            ³
 //  ^ ^               ³
 //  ³ ³               ³
 //  ÀÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 //
 STRING s[255] = "[A-Za-z_]" // default
 //
 CASE fileextensionS
  //
  // WHEN extension of "html", "javascript", "java", "fortran", "cobol", "lisp", "rpg",... // added knud [kn, ni, fr, 07-08-1998 16:10:32]
  //
  WHEN ".ahk" // Autohotkey [kn, vo, mo, 22-12-2014 14:19:10]
   s = "^PROC[A-Za-z][A-Za-z_0-9]@"
  WHEN ".bas", ".bbc" // BBCBASIC
    //
    s = "{{^ @}|{ }}{{PROC}|{FN}}[A-Za-z_][A-Za-z_0-9]@\c(@"
    //
  // WHEN ".bbc" // this is a binary file!  [kn, ni, th, 06-08-1998 21:55:33]
  //
  WHEN ".bat" // batch file
    //
    s = "^\.batch\ [A-Za-z_][A-Za-z_0-9]@\c"
    //
  WHEN ".c", ".cpp", ".h", ".hpp" // C, C++
    //
    s = "{{^ @}|{ }}_@[a-zA-Z][a-zA-Z0-9_*\t]@\c([~;]*" // test this further [kn, ni, fr, 06-08-1999 06:17:59]
    //
  WHEN ".cs" // C#
    //
    s = "{{^ @}|{ }}_@[a-zA-Z][a-zA-Z0-9_*\t]@\c([~;]*" // test this further [kn, ri, fr, 15-02-2002 20:27:00]
    //
  WHEN ".del" // Delphi
    //
    s = " *{{PROC}|{FN}}[A-Za-z_][A-Za-z_0-9]@\c @\(@" // [kn, ri, we, 04-09-2002 15:40:08]
    //
    // s = " *{{PROC}|{FN}}[A-Za-z_][A-Za-z_0-9]@\c @{{(}|{;}}?" // [kn, ri, we, 04-09-2002 15:21:00]
    //
    // s = " *{{PROC}|{FN}}[A-Za-z_][A-Za-z_0-9]@\c @\(?" // [kn, ri, we, 04-09-2002 14:51:54]
    //
    // s = " *{{PROC}|{FN}}[A-Za-z_][A-Za-z_0-9]@\c{ @{{;}|{(}}}@" // [kn, ri, we, 04-09-2002 14:16:56]
    //
    // s = " *{{PROC}|{FN}}[A-Za-z_][A-Za-z_0-9]@\c{ @{{\;}|{(}}}?" // [kn, ri, we, 04-09-2002 02:10:07]
    //
    // s = " *[A-Za-z_][A-Za-z_0-9]@\c @{{\;}|{(}}?" // [kn, ri, we, 04-09-2002 00:20:53]
    //
    // a procedure can end in a ';', '(', but not in a ':' (that is only for
    //
    // the definition of a function)
    //
    // s = " *[A-Za-z_][A-Za-z_0-9]@\c @{{:}|{\;}|{(}}?" // [kn, ri, we, 04-09-2002 00:20:53]
    //
    // s = " *[A-Za-z_][A-Za-z_0-9]@\c @{{:}|{\;}|{\(}|{}}" // [kn, ri, we, 04-09-2002 00:29:38]
    //
    // s = " *[A-Za-z_][A-Za-z_0-9]@\c @{{\;}|{(}}" // [kn, ri, su, 01-09-2002 23:45:40]
    //
  WHEN ".dok" // dok file Knud
    //
    // s = "^\.gf\ [A-Za-z_][A-Za-z_0-9]@\c" // old [kn, ri, fr, 22-03-2002 09:29:24]
    //
    s = "^\.gf\ [A-Za-z_-][A-Za-z_0-9-]@\c" // new [kn, ri, fr, 22-03-2002 09:29:31]
    //
  // WHEN ".ini"
  //
  WHEN ".java", ".jav"  // Java
    //
    // s = "{{^ @}|{ }}_@[a-zA-Z][a-zA-Z0-9_*\t]@\c([~;]*" // test this further [kn, zoe, tu, 28-11-2000 16:57:02]
    //
    // s = "{{ #}|{ }}_@[a-zA-Z][a-zA-Z0-9_*\t]@Applet #\c" // [kn, ri, su, 20-05-2001 23:36:51]
    //
    // s = "{{^ @}|{ }}_@[a-zA-Z][a-zA-Z0-9_*\t]@\c([~;]*" // [kn, ri, su, 20-05-2001 23:41:35]
    //
    s = "_@[a-zA-Z][a-zA-Z0-9_*\t]@\c([~;]*" // new [kn, ri, fr, 10-05-2002 02:43:24]
    //
  WHEN ".js" // JavaScript
    //
    s = "{{^ @}|{ }}_@[a-zA-Z][a-zA-Z0-9_*\t]@\c([~;]*" // test this further [kn, ri, su, 20-05-2001 22:30:25], [kn, zoe, tu, 28-11-2000 16:57:26]
    //
  WHEN ".lot" // LotusScript
    //
    s = "{{^ @}|{ }}{{DEF FN}|{SUB}}[A-Za-z_][A-Za-z_0-9]@\c(@" // test this further [kn, zoe, tu, 28-11-2000 16:58:42]
    //
  WHEN ".cl", ".lsp"
    //
    s = "defun +[A-Za-z_][A-Za-z_0-9-]#\c"
    //
  WHEN ".map" // Maple
    //
    s = "{{^ @}|{ }}_@[a-zA-Z][a-zA-Z0-9_*\t]@\c([~;]*" // works OK [kn, zoe, mo, 18-12-2000 22:58:34]
    //
  // s = "[a-zA-Z] *proc *\= *\(.*$\c" // get the whole line // test further [kn, zoe, th, 07-12-2000 21:54:10]
  //
  WHEN ".pas" // Pascal
    //
    s = "{{^ @}|{ }}[A-Za-z_][A-Za-z_0-9]@ @\c("
    //
  // WHEN ".prg",".spr",".mpr",".qpr",".fmt",".frg",".lbg",".ch"
  //
  WHEN ".pl" // PERL
    //
    s = "{{^ @}|{ }}[A-Za-z_][A-Za-z_0-9]@ @\c(" // [kn, ri, we, 04-09-2002 22:28:18]
    //
  WHEN ".php" // PHP
    //
    s = "{{^ @}|{ }}_@[a-zA-Z][a-zA-Z0-9_*\t]@\c([~;]*" // test this further [kn, ri, mo, 22-10-2001 00:22:50]
    //
  WHEN ".py" // Python
    //
    s = "{{^ @}|{ }}[A-Za-z_][A-Za-z_0-9]@ @\c(" // [kn, ri, we, 04-09-2002 22:28:32]
    //
  WHEN ".s", ".ui", ".si" // TSE
   //
   // regular expression: SAL: First 1 character of the type A-Z, a-z or _. Then 0 or more occurrences of A-Z, a-z, -, 0-9. Then immediately the character '(' (and position your cursor on the character '(' by including the '\c' option. This to initialize the position to goto the next occurrence, and not to remain on or in the currently found string anymore) [kn, ni, fr, 07-08-1998 14:15:32]
    //
    // old (without DATADEF): s = "{{^ @}|{ }}[A-Za-z_][A-Za-z_0-9]@ @\c("
    //
    // old (without KEYDEF): s = "{{{^ @}|{ }}[A-Za-z_][A-Za-z_0-9]@ @\c(}|{{{DATADEF}|{HELPDEF}}[A-Za-z_][A-Za-z_0-9]@}"
    //
    s = "{{{^ @}|{ }}[A-Za-z_][A-Za-z_0-9]@ @\c(}|{{{DATADEF}|{HELPDEF}|{KEYDEF}}[A-Za-z_][A-Za-z_0-9]@}"
    //
  WHEN ".vb" // Visual Basic
    //
    s = "{{^ @}|{ }}_@[a-zA-Z][a-zA-Z0-9_*\t]@\c([~;]*" // test this further [kn, ri, mo, 22-12-2003 01:25:37]
    //
  WHEN ".vbs" // VBScript
    //
    s = "{{^ @}|{ }}_@[a-zA-Z][a-zA-Z0-9_*\t]@\c([~;]*" // test this further [kn, ri, tu, 29-01-2002 23:19:39]
    //
  WHEN ".xsl" // XSL stylesheet
    //
    // s = '^{ *\<xsl\:call\-template *{name} *\= *\"' // this puts you on first character [kn, ri, fr, 29-06-2001 16:55:01]
    //
    s = ' *{{name} *\= *}{\"[A-Za-z_][A-Za-z_0-9]@ *\c\"}' // this puts you on first character [kn, ri, fr, 29-06-2001 16:55:01]
    //
  OTHERWISE
   //
   PROCErrorCaseNotFound( "def proc/fn file extension not defined yet", "FNStringGetSearchProcedureNameExpressionS(", fileextensionS )
   //
   s = FNStringGetErrorS()
   //
 ENDCASE
 //
 RETURN( s )
 //
END

// library: text: found: mark: get: (Copies Marked Block into String) N    * <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstfma.s) [<Program>] [<Research>] [kn, zoe, we, 16-06-1999 01:06:55]
STRING PROC FNStringGetTextFoundMarkS()
 // e.g. PROC Main()
 // e.g.  Warn( FNStringGetTextFoundMarkS() ) // gives the currently found text
 // e.g.  Message( "Remember that this routine undo's an already marked block. Thus call this by PROCBlockSaveStackPush() s = FNStringGetTextFoundMarkS() PROCBlockRemoveStackPop()" ) GetKey()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextSelectMarkFound() // mark any text if found
 //
 RETURN( FNStringGetTextMarkS() )
 //
END

// library: string: space: remove: begin: end: trim <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=remostst.s) [<Program>] [<Research>] [kn, ri, mo, 01-04-2002 19:22:22]
STRING PROC FNStringGetSpaceRemoveBeginEndS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: space: remove: begin: end: trim: string = ", "   test    " )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( "'", FNStringGetSpaceRemoveBeginEndS( s ), "'" ) // gives e.g. "test"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // variation: RETURN( Trim( s ) )
 //
 RETURN( FNStringGetSpaceRemoveEndS( FNStringGetSpaceRemoveBeginS( s ) ) )
 //
END

// library: string: get: replace: all / PHP: str_replace <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstram.s) [<Program>] [<Research>] [kn, ri, su, 02-12-2007 22:41:49]
STRING PROC FNStringGetReplaceAllS( STRING oldS, STRING newS, STRING givenS )
 // e.g. //
 // e.g. // version Semware
 // e.g. //
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s3[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: replace: all: string given = ", "abc abc abc" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "string: replace: all: old string to replace = ", "abc" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  s3 = FNStringGetInputS( "string: replace: all: new string = ", "def" )
 // e.g.  IF FNKeyCheckPressEscapeB( s3 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetReplaceAllS( s2, s3, s1 ) ) // gives e.g. "def def def" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( StrReplace( oldS, givenS, newS ) )
 //
END

// library: string: get: token: case: upper: central <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstuce.s) [<Program>] [<Research>] [kn, ri, su, 06-11-2005 20:20:53]
STRING PROC FNStringGetTokenCaseUpperCentralS( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenCaseUpperCentralS( "test" ) ) // gives "TEST"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCaseUpperS( s ) )
 //
END

// library: string: get: token: program: function: name <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstfnb.s) [<Program>] [<Research>] [kn, ri, su, 06-11-2005 20:41:56]
STRING PROC FNStringGetTokenProgramFunctionNameS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenProgramFunctionNameS() ) // gives e.g. "fn"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "fn" )
 //
END

// library: string: get: token: program: procedure: name <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstpna.s) [<Program>] [<Research>] [kn, ri, su, 06-11-2005 20:39:34]
STRING PROC FNStringGetTokenProgramProcedureNameS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenProgramProcedureNameS() ) // gives e.g. "proc"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "proc" )
 //
END

// library: math: get: initialize: new <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getmaine.s) [<Program>] [<Research>] [kn, noot, mo, 09-07-2001 11:59:54]
INTEGER PROC FNMathGetInitializeNewI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetInitializeNewI() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathGetIntegerZeroI() )
 //
END

// library: string: get: capitalize: front: while you find in front, get that front part: iterative version <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcca.s) [<Program>] [<Research>] [kn, ri, tu, 05-06-2001 12:30:11]
STRING PROC FNStringGetCarCapitalizeS( STRING inS )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: get: capitalize: cdr: string = ", "ThisIsACapitalizedString" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCarCapitalizeS( s ) ) // gives e.g. "This"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = inS
 //
 STRING upperS[255] = FNStringGetInitializeNewStringS()
 //
 STRING lowerdigitunserscoreS[255] = FNStringGetInitializeNewStringS()
 //
 upperS = FNStringGetCharacterFirstS( s )
 //
 s = FNStringGetCharacterWithoutFirstS( s )
 //
 lowerdigitunserscoreS = FNStringGetCarFirstWhileFindS( s, FNStringGetAlphabetVariableRestS() )
 //
 RETURN( FNStringGetConcatS( upperS, lowerdigitunserscoreS ) )
 //
END

// library: string: get: capitalize: while you find in front, get that front part: iterative version <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstccd.s) [<Program>] [<Research>] [kn, ri, tu, 05-06-2001 12:30:03]
STRING PROC FNStringGetCdrCapitalizedS( STRING inS )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: get: capitalize: string = ", "ThisIsACapitalizedString" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCdrCapitalizedS( s ) ) // gives e.g. "IsACapitalizedString"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetRemoveCharactersFrontS( inS, FNStringGetCarCapitalizeS( inS ) ) )
 //
END

// library: string: get: file: ini: default: cross: platform <description></description> <version control></version control> <version>1.0.0.0.9</version> <version control></version control> (filenamemacro=getstcpo.s) [<Program>] [<Research>] [kn, ri, we, 15-10-2025 23:44:08]
STRING PROC FNStringGetFileIniDefaultCrossPlatformS( STRING searchS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFileIniDefaultCrossPlatformS( "path4dos" ) ) // gives e.g. "c:\4dos"
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
 STRING s[255] = ""
 //
 s = FNStringGetFileGetFilenamePathDefaultCrossPlatformS( searchS )
 //
 IF EquiStr( Trim( s ), "" )
  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
  Warn( searchS, ":", " ", "Not found (or found but the value is the empty string). Please check dddpath.ini and adapt file bibdelphi.del" )
 ENDIF
 //
 // If a filename it should be checked and converted if applicable in the receiving function, not before that.
 // IF ( StrFind( "^[A-Za-z]:", s, "gx" ) > 0 ) // is it a filename?
 // s = FNStringGetMicrosoftWindowsToCrossPlatformS( s )
 // //
 // ENDIF
 //
 RETURN( s )
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

// library: movement: line: down: go to the next line <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checcucd.s) [<Program>] [<Research>] [kn, zoe, we, 12-05-1999 15:49:40]
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

// library: math: number: compare: equal: number1 EQUAL TO number2? <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmane.s) [<Program>] [<Research>] [kn, ri, th, 03-05-2001 12:51:27]
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

// library: block: get: filename: macro: search: "filenamemacro=": first occurrence <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getblfwa.s) [<Program>] [<Research>] [kn, ri, su, 29-07-2001 15:13:22]
STRING PROC FNStringGetBlock_SearchFilenameMacroFirstWarnS( STRING inS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetBlock_SearchFilenameMacroFirstWarnS( "test" ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetBlock_Search_FilenameMacroFirstS( inS, FNMathCheckGetLogicTrueB() ) )
 //
END

// library: block: get: filename: macro: search: "filenamemacro=": first occurrence <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getblwno.s) [<Program>] [<Research>] [kn, ri, su, 29-07-2001 15:13:22]
STRING PROC FNStringGetBlockSearchFilenameMacroFirstWarnNotS( STRING inS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetBlockSearchFilenameMacroFirstWarnNotS( "info" ) ) // gives e.g. filenamemacroname
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetBlock_Search_FilenameMacroFirstS( inS, FNMathCheckGetLogicFalseB() ) )
 //
END

// library: string: get: expression: regular: goto: end <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgeo.s) [<Program>] [<Research>] [kn, ri, su, 30-10-2005 00:40:11]
STRING PROC FNStringGetExpressionRegularGotoEndS( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetExpressionRegularGotoEndS( "{test}" ) ) // gives "{test}\c"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetExpressionRegularGotoS( s, FNStringGetEmptyS() ) )
 //
END

// library: string: get: filename: global: filename: macro <description>string: filename: macro: "filenamemacro=": global</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstfmd.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 15:30:33]
STRING PROC FNStringGet_FilenameGlobalFilenameMacroS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGet_FilenameGlobalFilenameMacroS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "{\(filename}{macro}?{=}" )
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

// library: line insert after: insert text at first column <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=inseliti.s) [<Program>] [<Research>] [kn, zoe, we, 28-02-2001 20:24:53]
INTEGER PROC FNLineCheckInsertAfterLineGotoBeginTextInsertB( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "line insert after: insert text at first column: s = ", "test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNLineCheckInsertAfterLineGotoBeginTextInsertB( s1 ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( AddLine( s ) )
 //
 RETURN( FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( s, FNBufferGetBufferIdFileCurrentI() ) )
 //
END

// library: window: check: scroll: horizontal <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checwisi.s) [<Program>] [<Research>] [kn, ri, sa, 21-05-2005 15:36:00]
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

// library: string: line: length: what is the length <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgle.s) [<Program>] [<Research>] [kn, ri, we, 25-11-1998 20:20:58]
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
 //              ù tag_number is the optional tagged pattern number to return
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

// library: screen: get: window: column: total <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getsccto.s) [<Program>] [<Research>] [kn, ri, sa, 21-05-2005 15:29:22]
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

// library: screen: movement: scroll: left: N <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=scroscln.s) [<Program>] [<Research>] [kn, ni, sa, 02-11-2002 22:04:19]
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

// library: window: goto: scroll: horizontal: get the number of columns current window has scrolled horizontally <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getwisho.s) [<Program>] [<Research>] [kn, zoe, we, 16-06-1999 01:06:52]
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

// library: block: mark: type: return the type of the block marked in the current file (Determines Whether a Block is Marked in Current File, 0 if no block, else _INCLUSIVE_, _NON_INCLUSIVE_, _LINE_, _COLUMN_) N <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getblmty.s) [<Program>] [<Research>] [kn, ri, su, 17-10-1999 07:17:38]
INTEGER PROC FNBlockGetCurrentMarkedTypeI()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockGetCurrentMarkedTypeI() ) // gives e.g. 1
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( IsBlockInCurrFile() )
 //
END

// library: record: goto: begin: separator: line: goto: down <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotordlb.s) [<Program>] [<Research>] [kn, ri, sa, 16-03-2002 01:25:49]
PROC PROCRecordGotoBeginSeparator_CursorGotoDownLineGotoBegin()
 // e.g. PROC Main()
 // e.g.  PROCRecordGotoBeginSeparator_CursorGotoDownLineGotoBegin()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCRecordGotoBeginSeparatorCursorGotoDown()
 //
 PROCTextGotoLineBegin()
 //
END

// library: search: procedure: regular expression: procedure/function: definition: return the regular expression to find everything (spaces included. The cursor remains at the beginning of the found text) BEFORE the identifier (=the name of that procedure or function) in the DEFINITION of the defined procedures or functions. (filenamemacro=getstefi.s) [kn, ni, ma, 10-08-1998 00:55:48]
STRING PROC FNStringGetSearchProcedureDefinitionExpressionFirstS( STRING fileextensionS )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "search: procedure: regular expression: procedure/function: definition: file: extension = ", FNFileGetExtensionCurrentPointS() )
 // e.g.  IF FNEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( FNStringGetSearchProcedureDefinitionExpressionFirstS( s ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // To test:
 // take the .bas expression,
 // load bibbbc.bbc
 // and do a search by hand
 // and draw conclusions about what you want to achieve
 // then repeat it for the other extension(s)
 //
 // ---
 //
 // expected result after you found such an expression:
 //
 //  you should highlight all characters from the start of the line
 //  until (not included) the first character of the procedure or function
 //  name
 //
 //  e.g.
 //  DEF PROCMyProcedure
 //  ³      ³
 //  ÀÄÄÄÄÄÄÙ
 //  ^
 //  |
 //  cursor here, at first character, and that block highlighted
 //
 // ---
 //
 // How to test?
 //
 // The easiest method to test it, is to copy one of this
 // regular expressions below (e.g. for TSE, javascript, bbcbasic, ...),
 // then to load the library file for that language (e.g. bibtse.tse,
 // bibjavascript.js, bibbbc.bbc, ...) and then to search with that
 // regular expression, and having a look at the results. Then you know what you should
 // have as a similar result in any of the new languages you want to
 // add.
 // [kn, ri, su, 01-09-2002 23:21:36]
 //
 // ---
 //
 STRING s[255] = ""
 CASE fileextensionS
  WHEN ".ahk" // Autohotkey [kn, vo, mo, 22-12-2014 14:19:10]
   s = "^"
  WHEN ".asm" // Assembler
   s = "[a-zA-Z0-9] +{proc}" // [kn, zoe, th, 16-11-2000 17:55:35]
   // s = "^{proc +\c[a-zA-Z_0-9]#}|{\c[a-zA-Z_0-9]# +proc}" // [kn, zoe, th, 16-11-2000 17:46:57]
  WHEN ".b36" // which language? (see search.s, macdownload) [kn, ni, di, 11-08-1998 03:20:10]
   s = "^[global\t ]*routine[\t ]*"
   //
   //  Ä>Ä(begin of line)Ä>ÄÄÂÄÄÄÄÄÄÄÄÄ>ÄÄÄÄÄÄÄÄÄ¿
   //                        ³                   ³            ÚÄÄÄÄÄÄ>ÄÄÄÄÄÄÄÄÄ¿
   //                        ³   ÚÄ>Ä(g)ÄÄÄ>Ä¿   ³            ³                ³
   //                        À>Â>ÅÄ>Ä(l)ÄÄÄ>ÄÅÄ>ÄÅÄ>Ä(routine)Á>ÂÂ>ÄÄ( )ÄÄÄ>Â>ÂÁÄ>Ä
   //                          ³ ÃÄ>Ä(o)ÄÄÄ>Ä´   ³              ³³          ³ ³
   //                          ³ ÃÄ>Ä(b)ÄÄÄ>Ä´   ³              ³À>Ä(tab)Ä>ÄÙ ³
   //                          ³ ÃÄ>Ä(a)ÄÄÄ>Ä´   ³              ÀÄÄÄÄÄÄÄ<ÄÄÄÄÄÙ
   //                          ³ ÃÄ>Ä(l)ÄÄÄ>Ä´   ³
   //                          ³ ÀÄ>Ä(tab)Ä>ÄÙ   ³
   //                          ³                 ³
   //                          ÀÄÄÄÄÄÄÄÄ<ÄÄÄÄÄÄÄÄÙ
   //
  WHEN ".bas", ".bbc" // BBCBASIC
   s = "^ @[0-9]@ @DEF @" // e.g. "1000 DEF ... (so this does not include FN or PROC)"
   //  So this takes everything starting from the begin of the line, until (so not included) the procedure name.
   //  e.g.
   //
   //  in '1000 DEF PROCTest'
   //
   //  it takes out '1000 DEF '
   //                ^       ^
   //                ÀÄÄÄÄÄÄÄÙ
   //
   //
   //                                       ÚÄÄÄÄÄ<ÄÄÄÄÄÄÄ¿
   //                       ÚÄÄÄÄÄ<ÄÄÄÄÄ¿   ³  ÚÄÄÄÄÄÄÄ¿  ³    ÚÄÄÄÄÄ<ÄÄÄÄÄ¿           ÚÄÄÄÄÄ<ÄÄÄÄÄ¿
   //  Ä>Ä(begin of line)Ä>ÄÅ>Ä(space)Ä>ÅÄ>ÄÅÄ>´ digit ÃÄ>ÅÄÄ>ÄÅ>Ä(space)Ä>ÅÄ>Ä(DEF)Ä>ÄÅ>Ä(space)Ä>ÅÄ>Ä
   //                       ÀÄÄÄÄÄ>ÄÄÄÄÄÙ   ³  ÀÄÄÄÄÄÄÄÙ  ³    ÀÄÄÄÄÄ>ÄÄÄÄÄÙ           ÀÄÄÄÄÄ>ÄÄÄÄÄÙ
   //                                       ÀÄÄÄÄÄ>ÄÄÄÄÄÄÄÙ
   //
  WHEN ".bas", ".pbi", ".pbs", ".bi", ".pb3", ".vb" // visual basic, quick basic, power basic // [kn, zoe, th, 16-11-2000 17:56:19]
   s = "^ *{sub}|{function} +" // [kn, ri, su, 11-01-2004  9:05:42]
   // s = "^ *{sub}|{function} +[a-zA-Z.]" // [kn, zoe, th, 16-11-2000 17:54:39]
   // s = "^{static }?{{procedure}|{function}} +[a-zA-Z_]" // xbase, from TSE v4.0 for Windows [kn, ri, we, 04-09-2002 22:21:17]
   // s = "^{{friend}|{private}|{public}[ \t]+}?{function}|{sub}|{property}[ \t]" // visual basic, from TSE v4.0 for Windows [kn, ri, we, 04-09-2002 22:21:45]
   //
   //
   //
   //                                       Ú>ÄÄ(sub)ÄÄÄÄÄ¿                    Ú>Ä´lowercase characterÃ>¿
   //                       ÚÄÄÄÄÄ<ÄÄÄÄÄ¿   ³             ³     ÚÄÄÄÄÄ<ÄÄÄÄÄ¿  ³  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ³
   //  Ä>Ä(begin of line)Ä>ÄÅ>Ä(space)Ä>ÅÄ>Ä´             ÃÄÄ>ÄÄÁ>Ä(space)Ä>ÁÄ>´                        ÃÄ>Ä
   //                       ÀÄÄÄÄÄ>ÄÄÄÄÄÙ   ³             ³                    ³  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ ³
   //                                       À>Ä(function)ÄÙ                    À>Ä´uppercase characterÃ>Ù
   //                                                                             ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  WHEN ".bat" // batch file
   s = "^\[\" // e.g. "[..."
   // s = "^[\t ]*:"
   //
   //  e.g.
   //
   //  in '['
   //
   //  it takes out '['
   //                ^
   //                ³
   //
   //
   //  Ä>Ä(begin of line)Ä>Ä([)Ä>Ä
   //
  WHEN ".bbc" // BBCBASIC (this is a binary file!)  [kn, ni, do, 06-08-1998 21:55:33]
   s = "\d221 @"
   //
   //  e.g.
   //
   //  in '221 Test'
   //
   //  it takes out '221 '
   //                ^  ^
   //                ÀÄÄÙ
   //
   //
   //    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   ÚÄÄÄÄÄ<ÄÄÄÄÄ¿
   //  Ä>´ decimal 221 ÃÄ>ÄÅ>Ä(space)Ä>ÅÄ>Ä
   //    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   ÀÄÄÄÄÄ>ÄÄÄÄÄÙ
   //
   WHEN ".c", ".h" // C
    s = "{^[~A-Za-z_]*.*}"        // [kn, zoe, wo, 15-12-1999 01:00:14]
   // s = "^_@[a-zA-Z][a-zA-Z0-9_* \t]@([~;]*$" // [kn, zoe, th, 16-11-2000 17:43:04]
   // s = "^_@[a-zA-Z][a-zA-Z0-9_* \t]@\c([~;]*$" // test this further [kn, ni, vr, 06-08-1999 04:33:56]
   //
   // s = "^_@[a-zA-Z][a-zA-Z0-9_* \t]@\c([~;]*" // test this further [kn, ni, vr, 06-08-1999 04:33:56]
   //
   // s = "{^.*{char}[ *]@}|{long}|{void}|{int}|{double}|{unsigned}|{float}|{{char} @\*?}[ ]@"
   //
   //                        ÚÄÄÄÄÄÄÄÄ<ÄÄÄÄÄÄÄÄÄÄÄ¿
   //                        ³  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   ³        ÚÄÄÄ<ÄÄÄÄ¿
   //  ÄÄ>Â>Ä(begin of line)ÄÁÄ>´any characterÃÄ>ÄÁÄ(char)ÄÅ>Ä( )ÄÂÄÁÄÄ>Ä¿
   //     ³                     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            ³      ^      ³
   //     ³                                                À>Ä(*)ÄÙ      ³
   //     ³                                                              ³
   //     ³   ÚÄ(long)ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄÄÄ¿          ³
   //     ³   ÃÄ(void)ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄÄÄ´          ³
   //     ³   ÃÄ(bool)ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄÄÄ´          ³
   //     ³   ÃÄ(int)ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄÄÄ´          ³
   //     ³   ÃÄ(double)ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄÄÄ´          ³
   //     ³   ÃÄ(unsigned)ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄÄÄ´          ³
   //     À>ÄÄÅÄ(float)ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄÄÄÅÄÄ>ÄÄÄÄÄÄÄÁÄ>---
   //         ÃÄ(char)ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄÄÄ´
   //         ÃÄ(short)ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄÄÄ´
   //         ÀÄ(struct <struct name> *<function name>)ÄÄ>ÄÄÄÄÙ
   //
   //
   //        ÚÄÄÄÄÄ<ÄÄÄÄÄ¿   ÚÄÄÄÄ>ÄÄÄÄ¿   ÚÄÄÄÄÄ<ÄÄÄÄÄ¿
   //  ---->ÄÅ>Ä(space)Ä>ÅÄ>ÄÁÄ>Ä(*)Ä>ÄÁÄ>ÄÅ>Ä(space)Ä>ÅÄ>ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   //        ÀÄÄÄÄÄ>ÄÄÄÄÄÙ                 ÀÄÄÄÄÄ>ÄÄÄÄÄÙ
   //
   // s = "{^.*{char}[ *]@}|^{bool}|{long}|{void}|{int}|{double}|{float}|{{char} @\*?}[ ]@.*("  // WHEN ".cpp", ".hpp"
  WHEN ".cpp", ".hpp" // C++
   // s = "^{extern[ \t]+\x22C\x22[ \t]+}?_|~@[a-zA-Z:][a-zA-Z0-9_+\-*/%^&|~!=<>,\[\] \t:~]@([~;]*$" // TSE v4.0 for Windows [kn, ri, we, 04-09-2002 22:14:11]
   // s = "{^STDMETHOD.*(.+)[ \t]+}|{^{[~ \t]*[ \t]*}?[a-zA-Z_~][a-zA-Z0-9_* \t~]@{::\c[a-zA-Z_~][a-zA-Z0-9_* \t~]@}?{[~=;/]*([~;:/]@}|{[~=;:/]@}{//.@}?$}"
   // s = "^{extern[ \t]+\x22C\x22[ \t]+}?_|~@[a-zA-Z:][a-zA-Z0-9_+\-*/%^&|~!=<>,\[\] \t:~]@([~;]*$" // from TSE v3.0 for Windows [kn, ri, mo, 03-09-2001 17:35:20]
   // s = "^{extern[ \t]+\x22C\x22[ \t]+}?_|~@" // [kn, ri, mo, 03-09-2001 17:35:39]
   // s = "{^[~A-Za-z_]*.*}" // [kn, zoe, wo, 15-12-1999 01:00:14]
   // s = "{^.*{char}[ *]@}|^{long}|{void}|{int}|{double}|{float}|{{char} @\*?}[ ]*"  // WHEN ".cpp", ".hpp"
   // s = "^ *{{bool}|{long}|{void}|{int}|{double}|{float}|{char}}* *[~A-Za-z_]" // old [kn, ri, tu, 30-04-2002 23:55:41]
   // s = "^ *{{bool}|{long}|{void}|{int}|{double}|{float}|{char}}# @" // [kn, ri, we, 01-05-2002 00:09:06]
   s = "^ *{{long}|{void}|{int}|{double}|{float}|{char}|{string}}* *[~A-Za-z_]" // new [kn, ri, we, 01-05-2002 00:09:10]
  WHEN ".cs" // C#
   s = "^ *{{long}|{void}|{int}|{double}|{float}|{char}|{string}}* *[~A-Za-z_]"
  WHEN ".del" // Delphi
   s = "^\ *{{procedure}|{function}}\ +{{TForm}[0-9]{[0-9]}?\.}" // [kn, ri, su, 01-09-2002 23:50:30]
   //
   //  e.g.
   //
   //  in           'procedure TForm1.PROCtest'
   //
   //  it takes out 'procedure TForm1.'
   //                ^               ^
   //                ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //
   //
   //      Ú>Ä(procedure)Ä¿   ÚÄÄÄÄ<ÄÄÄÄ¿
   //  Ä>ÄÄ´              ÃÄ>ÄÁÄ(space)ÄÁÄ>ÄÄ
   //      À>Ä(function)ÄÄÙ
   //
  WHEN ".dok" // dok Knud
   s = "^\[\" // e.g. "[..."
   //
   //  e.g.
   //
   //  in '['
   //
   //  it takes out '['
   //                ^
   //                ³
   //
   //
   //  Ä>Ä(begin of line)Ä>Ä([)Ä>Ä
   //
  // WHEN "cobol", "fortran", "html", "lisp", "logo", "postscript", "rpg", "sap", "tex", ... // added knud [kn, ni, vr, 07-08-1998 16:10:32]
  WHEN ".ini" // ini files
   s = "" // test this further [kn, ni, vr, 06-08-1999 03:10:20]
   // s = "\[.*\]" // [kn, zoe, th, 16-11-2000 17:53:48]
   // s = "^[ \t]*\[.*\][ \t]*$" // from TSE v4.0 for Windows [kn, ri, we, 04-09-2002 22:15:21]
  WHEN ".java", ".jav" // Java
   // extension ".java" (because of more than the standard 3 characters of the extension, you should use TSE32 for this) [kn, zoe, vr, 17-12-1999 21:05:46]
   // s = "{{private}|{protected}|{public}} #{void}\c[ \t]+_@[~;]*" // [kn, zoe, we, 20-12-2000 23:37:22]
   // s = "{{private}|{protected}|{public}} #{class}\c[ \t]+_@[~;]*" // [kn, zoe, we, 20-12-2000 23:37:27]
   // s = "{{ #}|{ }}_@[a-zA-Z][a-zA-Z0-9_]@Applet\c +"
   // s = " *[a-zA-Z][a-zA-Z0-9_]@Applet\c{{$}|{ +}}" // [kn, ri, su, 20-05-2001 23:11:07]
   // s = "^ @{{{public}|{private}} #}?{class} @" // [kn, ri, su, 20-05-2001 23:30:16]
   // s = "^.*{class} @" // [kn, ri, su, 20-05-2001 23:30:16]
   // s = "^ *.*{{boolean}|{long}|{void}|{int}|{double}|{float}|{char}}# @" // [kn, ri, fr, 10-05-2002 02:30:45]
   // s = "{private}|{protected}|{public}|{void}[ \t]+_@" // [kn, ri, mo, 03-09-2001 17:35:50]
   // s = "{private}|{protected}|{public}|{void}[ \t]+_@[a-zA-Z][\.a-zA-Z0-9_*@{\[\]}? \t]@([~;]*$" // from TSE v4 tsejr.ui file [kn, ri, tu, 14-05-2002 21:33:34]
   s = "^ *{{public}|{private}|{protected}}.#[A-Za-z_][A-Za-z_0-9][(]" // [kn, ri, fr, 10-05-2002 03:03:21]
   //
   //
   //   function = accesstype static variablename ( parameter )
   //
   //   accesstype = {{private}|{protected}|{public}}
   //
   //
   //                       byte
   //    private
   //                       int
   //                                              ÚÄÄÄÄÄ<ÄÄÄÄÄÄÄÄÄ¿
   //    protected  static  void      variablename ³ parameter   , ÃÄ>Ä
   //                                              ³           ³   ³
   //                       boolean                ÀÄÄÄÄÄ>ÄÄÄÄÄÁÄ>ÄÙ
   //    public
   //                       String
   //
   //                       long
   //
   //                       short
   //
   //                       double
   //
   //
   //    parameter =  byte     variablename
   //
   //                 int
   //
   //                 boolean
   //
   //                 String  variablenameÄ¿ [] ÚÄÄ
   //                                      ÀÄÄ>ÄÙ
   //                 long
   //
   //                 short
   //
   //                 double
   //
   //
   //   parameter = {parametertype variablename [,]?}*
   //
   //   parametertype = {{byte}|{int}|{boolean}|{String}|{long}|{short}|{double}}
   //
   //   variablename = [A-Za-z_]{[A-Za-z_0-9]}@
   //
  WHEN ".js" // JavaScript
   s = "^ *function +" // [kn, ri, su, 01-09-2002 23:27:28]
   // s = "^ *function *" // [kn, zoe, vr, 17-12-1999 21:03:13]
   //
   // ->-(begin of line)->-(zero or more spaces)->-(the word 'function')->-(zero or more spaces)-
   //
  WHEN ".lot" // LotusScript
   s = "^ *.*[~{proc}]" // [kn, zoe, th, 07-12-2000 23:28:56]
   //
   //
  WHEN ".map" // Maple
   s = "{ #\:\= #}{proc(}" // [kn, zoe, mo, 18-12-2000 22:38:32]
   // s = "{^ *.#\:\= *}{proc(}" // [kn, zoe, mo, 18-12-2000 22:38:32]
   // s = "^ *.*[~{proc}]" // [kn, zoe, th, 07-12-2000 23:29:04]
   //
  WHEN ".pas" // Pascal
   s = "^\ *{{procedure}|{function}}\ +" // [kn, ri, mo, 02-09-2002 02:02:10]
   s = "{procedure}|{function} +" // test this further [kn, ni, vr, 06-08-1999 06:17:24]
   // s = "{procedure}|{function} +\c[a-zA-Z_0-9]" // [kn, zoe, th, 16-11-2000 17:48:57]
   // s = "^ *{procedure}|{function} +[a-zA-Z_]" // from TSE v4.0 for Windows [kn, ri, we, 04-09-2002 22:16:51]
   //
   //  e.g.
   //
   //  in 'procedure test'
   //
   //  it takes out 'procedure '
   //                ^        ^
   //                ÀÄÄÄÄÄÄÄÄÙ
   //
   //
   //      Ú>Ä(procedure)Ä¿   ÚÄÄÄÄ<ÄÄÄÄ¿
   //  Ä>ÄÄ´              ÃÄ>ÄÁÄ(space)ÄÁÄ>ÄÄ
   //      À>Ä(function)ÄÄÙ
   //
  WHEN ".pl" // PERL
   s = "^ *sub @"
   //
   //
   //    sub PROCMyproc
   // ^     ^
   // ³     ³
   // ÀÄÄÄÄÄÙ
   //
   //
  WHEN ".php" // PHP
   s = "^ *function +" // same as JavaScript [kn, ri, mo, 22-10-2001 00:18:36]
   // s = "^ *function *" // same as JavaScript [kn, ri, mo, 22-10-2001 00:18:36]
   //
   // ->-(begin of line)->-(zero or more spaces)->-(the word 'function')->-(zero or more spaces)-
   //
  WHEN ".prg",".spr",".mpr",".qpr",".fmt",".frg",".lbg",".ch"
   s = "^{static #}?{{procedure}|{function}} +"
   // s = "^{static }?{{procedure}|{function}} +[a-zA-Z_0-9]"
   //
   //  e.g.
   //
   //  in 'static procedure test'
   //
   //  it takes out 'static procedure '
   //                ^               ^
   //                ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //
   //
   //     ÚÄÄÄÄÄÄÄ>ÄÄÄÄÄÄÄ¿
   //     ³         ÚÄÄ<Ä¿³ Ú>Ä(procedure)Ä¿   ÚÄÄÄÄ<ÄÄÄÄ¿
   //  Ä>ÄÁÄ(staticÄÁ( )ÄÁÁ>´              ÃÄ>ÄÁÄ(space)ÄÁÄ>ÄÄ
   //                       À>Ä(function)ÄÄÙ
   //
  WHEN ".py" // Python
   s = "^ *def @"
   // s = "^[ \t]*{class}|{def} " // from TSE v4.0 for Windows [kn, ri, we, 04-09-2002 22:17:45]
   //
   //
   //    def PROCMyproc
   // ^     ^
   // ³     ³
   // ÀÄÄÄÄÄÙ
   //
   //
  WHEN ".s", ".ui", ".si", ".inc" // TSE
   // old [kn, ni, do, 05-08-1999 22:37:34]: s = "^{{menu}|{datadef}|{helpdef}}|{{public #}?{{integer #}|{string #}}@proc} +"
   // s = "^{datadef}|{helpdef}|{keydef}|{menu}|{{public #}?{{integer #}|{string #}}@proc} +"  // menubar I could not include (then error 'too many groups'). Remove another item in the string, when you want to add it
   // s = "^{menu}|{{public #}?{{integer #}|{string #}}@proc} +\c[a-zA-Z_0-9]" // [kn, zoe, th, 16-11-2000 17:47:30]
   // s = "^{menu}|{{public #}?{{integer #}|{string #}}@proc} +[a-zA-Z_]" // from TSE v4.0 for Windows [kn, ri, we, 04-09-2002 22:18:40]
   s = "^{{PUBLIC #}?{{INTEGER}|{STRING} #}?PROC}|{MENUBAR}|{MENU}|{[DH][AE][TL][AP]DEF}|{KEYDEF} +"
   //
   //  e.g.
   //
   //  in 'PUBLIC STRING PROC FNTest()'
   //
   //  it takes out 'PUBLIC STRING PROC '
   //                ^                 ^
   //                ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //
   //
   //                       ÚÄÄÄÄÄÄ>ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //                       ³                     ³  ÚÄÄÄÄÄÄÄÄÄÄ>ÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //                       ³              ÚÄÄ<Ä¿ ³  ³ Ú>Ä(STRING)ÄÄ¿  ÚÄÄ<Ä¿ ³
   //  Ä>Ä(begin of line)Ä>ÄÅÄ>Ä(PUBLIC)Ä>ÄÁ( )ÄÁ>ÁÄ>ÁÄ´            Ã>ÄÁ( )ÄÁ>ÁÄ(PROC)Ä>ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄ¿
   //                       ³                          À>Ä(INTEGER)ÄÙ                                              ³
   //                       ³                                                                                      ³
   //                       ³                        ÚÄÄ>Ä(MENUBAR)ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄ´
   //                       ³                        ³                                                             ³   ÚÄÄ<Ä¿
   //                       ³                        ÃÄÄ>Ä(MENU)ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄÅÄÄ>Á( )ÄÁÄ>Ä
   //                       ³                        ³                                                             ³
   //                       ÀÄÄÄÄÄÄ>ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´    Ú>Ä(D)Ä>¿   Ú>Ä(A)Ä>¿   Ú>Ä(L)Ä>¿   Ú>Ä(A)Ä>¿            ³
   //                                                ÃÄÄ>Ä´       ÃÄ>Ä´       ÃÄ>Ä´       ÃÄ>Ä´       ÃÄ>(DEF)ÄÄ>ÄÄ´
   //                                                ³    À>Ä(H)Ä>Ù   À>Ä(E)Ä>Ù   À>Ä(T)Ä>Ù   À>Ä(P)Ä>Ù            ³
   //                                                ³                                                             ³
   //                                                ³      the above gives e.g. 'DATADEF' or also                 ³
   //                                                ³                           'HELPDEF'                         ³
   //                                                ³                                                             ³
   //                                                ÀÄÄ>Ä(KEYDEF)ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>ÄÄÙ
   //
  WHEN ".tex"
   s = "^\\{chapter}|{{subsub}|{sub}|{}section}|{{sub}|{}paragraph}" // from TSE v4.0 for Windows [kn, ri, we, 04-09-2002 22:20:12]
   //
   //
  WHEN ".vbs" // VBScript
   s = "^ *FUNCTION *" // [kn, ri, tu, 29-01-2002 23:13:36]
   //
   // ->-(begin of line)->-(zero or more spaces)->-(the word 'FUNCTION')->-(zero or more spaces)-
   //
  WHEN ".xf4" // very probably Fortran (see search.s, macdownload) [kn, ni, di, 11-08-1998 03:20:50]
    s = "^[\t ]*subroutine[\t ]*"
   //
   //
  WHEN ".xsl" // XSL stylesheet
    s = '^ *\<xsl\:template *{name} *\= *\"' // [kn, ri, fr, 29-06-2001 16:55:34]
   //
   //
  OTHERWISE
   Warn( "extension not defined yet", "FNStringGetSearchProcedureDefinitionExpressionFirstS(", fileextensionS )
   s = "<ERROR>"
 ENDCASE
 RETURN( s )
END

// library: text: mark: mark found text <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=fountefm.s) [<Program>] [<Research>] [kn, zoe, we, 30-06-1999 01:39:38]
PROC PROCTextSelectMarkFound()
 // e.g. PROC Main()
 // e.g.  PROCTextSelectMarkFound()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 // e.g. PROCTextSelectMarkFound()
 //
 PROCTextSelectMarkFoundTag( -1 )
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

// library: string: space: remove: end <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=remostse.s) [<Program>] [<Research>] [kn, ri, th, 15-02-2001 06:06:51]
STRING PROC FNStringGetSpaceRemoveEndS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: space: remove: end: string = ", "   test    " )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( "'", FNStringGetSpaceRemoveEndS( s ), "'" ) // gives e.g. "   test"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( RTrim( s ) )
 //
END

// library: string: space: remove: begin <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=remostsb.s) [<Program>] [<Research>] [kn, ri, th, 15-02-2001 06:06:51]
STRING PROC FNStringGetSpaceRemoveBeginS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: space: remove: begin: string = ", "   test    " )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( "'", FNStringGetSpaceRemoveBeginS( s ), "'" ) // gives e.g. "test    "
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( LTrim( s ) )
 //
END

// library: string: get: case: uppercase/lowercase: upper case: convert characters in string to upper case <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcuq.s) [<Program>] [<Research>] [kn, zoe, we, 30-06-1999 01:21:07]
STRING PROC FNStringGetCaseUpperS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: case: upper: string = ", "This is a test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCaseUpperS( s1 ) ) // gives e.g. "THIS IS A TEST"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Upper( s ) )
 //
END

// library: math: get: integer: zero <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getmaize.s) [<Program>] [<Research>] [kn, ri, we, 06-02-2002 21:12:47]
INTEGER PROC FNMathGetIntegerZeroI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetIntegerZeroI() ) // gives e.g. 9
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( 0 )
 //
END

// library: string: get: character: token: get: first: return the first single character in the given string <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcfi.s) [<Program>] [<Research>] [kn, ri, we, 24-03-1999 23:21:02]
STRING PROC FNStringGetCharacterFirstS( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterFirstS( "knud" ) ) // gives "k"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetCharacterFirstS( "the" ) ) // gives "t"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // variation: RETURN( FNStringGetLeftStringS( s, 1 ) )
 //
 // variation: RETURN( s[ 1 ] ) // TSE only
 //
 // variation: RETURN( FNStringGetMidStringS( s, 1, 1 ) )
 //
 RETURN( FNStringGetCharacterS( s, 1 ) )
 //
END

// library: string: remove: character: token: delete: first: without first character on beginning of string <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=delestwf.s) [<Program>] [<Research>] [kn, ri, we, 25-11-1998 20:27:32]
STRING PROC FNStringGetCharacterWithoutFirstS( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterWithoutFirstS( "knud" ) ) // gives 'nud'
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // variation: RETURN( FNStringGetRemoveCharactersFrontS( s, " " ) )
 //
 // variation: RETURN( FNStringGetRightStringS( s, FNStringGetLengthI( s ) - 1 ) )
 //
 RETURN( FNStringGetWordRestS( s, 1 ) ) // take out everything starting after the 1st character
 //
END

// library: string: get: first: while you find in front, get that front part: iterative version <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstwfk.s) [<Program>] [<Research>] [kn, zoe, su, 12-12-1999 01:03:10]
STRING PROC FNStringGetCarFirstWhileFindS( STRING inS, STRING whileS )
 // e.g. //
 // e.g. // iterative version
 // e.g. //
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: word: first: while: string = ", "9736abcd" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "string: get: word: first: while: whileS = ", "0123456789" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCarFirstWhileFindS( s1, s2 ) ) // gives e.g. "9736"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = inS
 //
 STRING rS[255] = FNStringGetInitializeNewStringS()
 //
 STRING firstS[255] = FNStringGetCharacterFrontS( s )
 //
 WHILE FNInstrCheckFoundB( FNMathGetStringSearchInstrI( whileS, firstS ) )
  //
  rS = FNStringGetConcatS( rS, firstS ) // put the found character from the given set at the end of the result string (e.g. rs = rs + '0')
  //
  s = FNStringGetCdr_FirstS( s ) // goto the next character, by removing the front character from the given string (e.g. before '00123' becomes '0123')
  //
  firstS = FNStringGetCharacterFrontS( s ) // take current first character of the given string
  //
 ENDWHILE
 //
 RETURN( rS )
 //
END

// library: string: get: alphabet: variable: rest <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstvre.s) [<Program>] [<Research>] [kn, ri, tu, 22-04-2003 20:55:49]
STRING PROC FNStringGetAlphabetVariableRestS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetAlphabetVariableRestS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetAlphabetLowerDigitUnderscoreS() )
 //
END

// library: string: token: delete: first: remove as much characters from the beginning of a given string, as total amount of characters of given another string <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcfs.s) [<Program>] [<Research>] [kn, zoe, we, 30-06-1999 01:07:41]
STRING PROC FNStringGetRemoveCharactersFrontS( STRING s, STRING frontS )
//
// STRING PROC FNStringGetRemoveCharacterFirstNS( STRING s, STRING frontS )
 //
 // e.g. PROC Main()
 //
 // e.g.  Warn( FNStringGetRemoveCharactersFrontS( "knud", "k" ) ) //  gives "nud"
 //
 // e.g.  Warn( FNStringGetRemoveCharactersFrontS( "best", "be" ) ) //  gives "st"
 //
 // e.g. END
 //
 RETURN( FNStringGetRightStringS( s, FNStringGetLengthI( s ) - FNStringGetLengthI( frontS ) ) )
 //
END

// library: string: get: file: get: filename: path: default: cross: platform <description></description> <version control></version control> <version>1.0.0.0.5</version> <version control></version control> (filenamemacro=getstcpn.s) [<Program>] [<Research>] [kn, ri, we, 15-10-2025 23:32:24]
STRING PROC FNStringGetFileGetFilenamePathDefaultCrossPlatformS( STRING searchS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFileGetFilenamePathDefaultCrossPlatformS( "path4dos" ) ) // gives e.g. "c:\4dos"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetInitializationGlobalS( searchS, FNStringGetSectionSeparatorS(), FNStringGetFilenameIniDefaultCrossPlatformS() ) )
 //
END

// library: block: mark: unmark: PROCBlockUnMark(): (Unmarks Marked Block) N * <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=cleablcm.s) [<Program>] [<Research>] [kn, zoe, we, 16-06-1999 01:07:12]
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

// library: line: mark: mark the current line <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checlicm.s) [<Program>] [<Research>] [kn, zoe, mo, 14-06-1999 22:07:35]
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

// library: block: get: filename: macro: search: "filenamemacro=": first occurrence <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getblmfi.s) [<Program>] [<Research>] [kn, ri, su, 29-07-2001 15:13:22]
STRING PROC FNStringGetBlock_Search_FilenameMacroFirstS( STRING inS, INTEGER warnB )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetBlock_Search_FilenameMacroFirstS( "test", FNMathCheckGetLogicTrueB() ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = inS
 //
 INTEGER foundB = FNMathCheckInitializeNewBooleanFalseB()
 //
 IF FNBlockCheckIsMarkedNotCurrentDefaultMessageB() RETURN( FNStringGetErrorS() ) ENDIF // return from the current procedure if no block is marked
 //
 PROCBlockSaveStackPush()
 //
 IF FNTextCheckSearchExpressionFoundB( s, FNStringGetSearchOptionBlockMark_GlobalExpressionRegularS() )
  //
  foundB = FNTextCheckSearchExpressionFoundB( FNStringGetConcatS( FNStringGetSearchBetweenRegularExpressionTagS( FNStringGetSearchCharacterDefaultAnyZeroOrMoreMinimumRegularExpressionS() ), FNStringGetSearchEscapeS( FNStringGetCharacterSymbolRoundCloseParenthesisS() ) ), "cx" )
  //
  IF foundB
   //
   s = FNStringGetTextFoundTagGetFirstS()
   //
  ENDIF
  //
 ENDIF
 //
 IF FNMathCheckLogicNotB( foundB )
  //
  IF warnB
   //
   PROCWarnCons( s, "not found in highlighted block" )
   //
  ENDIF
  //
  s = FNStringGetErrorS()
  //
 ENDIF
 //
 PROCBlockRemoveStackPop()
 //
 RETURN( s )
 //
END

// library: string: get: expression: regular: goto <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstrgo.s) [<Program>] [<Research>] [kn, ri, su, 30-10-2005 00:34:30]
STRING PROC FNStringGetExpressionRegularGotoS( STRING beginS, STRING endS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetExpressionRegularGotoS( "{before}", "{after}" ) ) // gives "{before}\c{after}"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcat3S( beginS, FNStringGetSearch_OptionExpressionRegularGotoS(), endS ) )
 //
END

// library: key: check: press: escape <description>input: escape: test if escape was pressed</description> <version>1.0.0.0.4</version> (filenamemacro=checkepe.s) [<Program>] [<Research>] [kn, ni, we, 05-08-1998 20:29:00]
INTEGER PROC FNKeyCheckPressEscapeB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNKeyCheckPressEscapeB( "" ) ) // version with testing local variable ) // gives e.g. FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( s, FNStringGetEscapeS() ) )
 //
END

// library: file: check: insert: line: after: line: goto: begin: text: insert: line insert after: insert text at first column (Add Line After Current Line). Syntax: AddLine( <STRING text <, INTEGER bufferid > > ). If the optional bufferid is specified, the line is added after the current line in the specified buffer. _ON_CHANGING_FILES_ hooks are not invoked by this command <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checfiti.s) [<Program>] [<Research>] [kn, zoe, we, 28-02-2001 20:24:53]
INTEGER PROC FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( STRING s, INTEGER bufferid )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "line insert after: insert text at first column: s = ", "test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "line insert after: insert text at first column: bufferID = ", FNStringGetMathIntegerToStringS( FNBufferGetBufferIdFileCurrentI() ) )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( s1, FNStringGetToIntegerI( s2 ) ) ) // gives e.g. TRUE
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

// library: record: goto: begin: separator: line: goto: down <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotoredo.s) [<Program>] [<Research>] [kn, ri, sa, 16-03-2002 01:25:49]
PROC PROCRecordGotoBeginSeparatorCursorGotoDown()
 // e.g. PROC Main()
 // e.g.  PROCRecordGotoBeginSeparatorCursorGotoDown()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCRecordGotoBeginSeparator()
 //
 PROCCursorGotoDown()
 //
END

// library: text: mark: mark given tag in found text <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=fountetm.s) [<Program>] [<Research>] [kn, zoe, we, 20-10-1999 00:06:40]
PROC PROCTextSelectMarkFoundTag( INTEGER tagI )
 // e.g. PROC Main()
 // e.g.  PROCTextSelectMarkFoundTag( 2 )
 // e.g.  Message( FNStringGetTextMarkS() ) // gives tag nr. 2 from the found regular expression -- do not use FNStringGetTextFoundMarkS(), as this gets the WHOLE found expressio
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 //  Marks the results of the immediately preceding find.
 //
 //  Syntax:     MarkFoundText([INTEGER tag_number])
 //
 //              ù tag_number is the optional tagged pattern number to mark in a
 //                regular expression search string.  If not passed, the entire
 //                found string is marked.
 //
 //  Returns:    Nothing.
 //
 //  Notes:      For this command to work properly, it should immediately follow a
 //              find command, before any other commands that might change the
 //              current position are invoked.
 //              The optional tag_number parameter only applies if a regular
 //              expression find was performed.
 //              For more information on regular expressions, see the chapter on
 //              "Search Features:  Finding and Replacing Text" in the User's
 //              Guide.
 //
 //  Examples:
 //
 //              string s[80]
 //
 //              if lFind("^a.*z$", "x")
 //
 //                  MarkFoundText() // mark found text
 //
 //                  s = GetMarkedText() // get it in s
 //
 //              endif
 //
 //              // Second example, this time marking the 2nd tagged
 //
 //              // expression found.
 //
 //              string s[80]
 //
 //              if lFind("{^a}{.*}{z$}", "x")
 //
 //                  MarkFoundText(2) // mark tag #2
 //
 //                  s = GetMarkedText() // store it in s
 //
 //              endif
 //
 //  See Also:   lFind(), GetMarkedText(), GetFoundText(), HiLiteFoundText()
 //
 //              Variables:  CenterFinds
 //
 IF FNMathCheckNumberSmallerOrEqualZeroB( tagI )
  //
  MarkFoundText()
  //
 ELSE
  //
  MarkFoundText( tagI )
  //
 ENDIF
 //
END

// library: string: get: character <description>string: get: character: token: return the character in the given string on the given position</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstgdj.s) [<Program>] [<Research>] [[kn, ri, fr, 25-12-1998 23:35:43]
STRING PROC FNStringGetCharacterS( STRING s, INTEGER positionI )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterS( s, positionI ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // e.g. FNStringGetCharacterS( "knud", 3 ) gives "u"
 //
 // variation: RETURN( s[ positionI ] ) // TSE only
 //
 RETURN( FNStringGetMidStringS( s, positionI, 1 ) )
 //
END

// library: string: get: word: rest <description>rest of the string after the first N  characters (same as MID$( s$, N% ) in BASIC / FNStringGetMidStringS( s$, N% ) )</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstwrf.s) [<Program>] [<Research>] [kn, ri, tu, 17-08-1999 01:15:41]
STRING PROC FNStringGetWordRestS( STRING s, INTEGER I )
 // e.g. PROC Main() // version via the more universal FNMidString
 // e.g.  Message( FNStringGetWordRestS( "knud", 2 ) ) // gives "ud"
 // e.g.  Message( FNStringGetWordRestS( "language", 4 ) ) // gives "uage"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER lengthI = FNStringGetLengthI( s )
 //
 IF ( FNMathCheckNumberInRangeNotB( I, 0, lengthI ) )
  //
  RETURN( FNStringGetEmptyS() )
  //
 ENDIF
 //
 RETURN( FNStringGetRightStringS( s, FNStringGetLengthI( s ) - I ) )
 //
END

// library: string: get: word: first: get the first character <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcfr.s) [<Program>] [<Research>] [kn, ni, su, 08-08-1999 18:54:59]
STRING PROC FNStringGetCharacterFrontS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: word: first: get: string = ", "knud" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCharacterFrontS( s1 ) ) // gives e.g. "k"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetCharacterFrontS( "test" ) ) // gives "t"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterFirstS( s ) )
 //
END

// library: instr: check: found <description>string: search/find: found</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checincf.s) [<Program>] [<Research>] [[kn, ri, su, 19-12-1999 23:13:29]
INTEGER PROC FNInstrCheckFoundB( INTEGER I )
 // e.g. PROC Main()
 // e.g.  Message( FNInstrCheckFoundB( FNMathGetStringSearchInstrI( "knud", "n" ) ) ) // gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckLogicNotB( FNInstrCheckFoundNotB( I ) ) )
 //
END

// library: math: get: string: search: instr (Similar to INSTR() in BASIC. find the first position of a string you search, in a given string / Returns Starting Position of One String Within Another) R    Pos(STRING needle, STRING haystack)*) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getmasin.s) [<Program>] [<Research>] [kn, ri, sa, 12-12-1998 20:08:55]
INTEGER PROC FNMathGetStringSearchInstrI( STRING containS, STRING searchS )
 // e.g. PROC Main()
 // e.g.  Message( IIF( FNMathGetStringSearchInstrI( "This line contains a ','", "," ) <> 0, "Found", "Not Found" ) )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Pos( searchS, containS ) )
 //
END

// library: string: get: word: last: get everything but the first character <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=getstcfj.s) [<Program>] [<Research>] [kn, ni, su, 08-08-1999 18:36:41]
STRING PROC FNStringGetCdr_FirstS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: word: last: s = ", "Knud" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCdr_FirstS( s1 ) ) // gives e.g. "nud"
 // e.g.  GetKey()
 // e.g.  Message( FNStringGetCdr_FirstS( "best" ) ) // gives "est"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // variation: RETURN( FNStringGetMidStringS( s, 2, FNStringGetLengthI( s ) - 1 ) )
 RETURN( FNStringGetCharacterWithoutFirstS( s ) )
 //
END

// library: string: get: alphabet: lower: digit: underscore <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstdun.s) [<Program>] [<Research>] [kn, ri, tu, 22-04-2003 20:42:19]
STRING PROC FNStringGetAlphabetLowerDigitUnderscoreS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetAlphabetLowerDigitUnderscoreS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcat3S( FNStringGetAlphabetLowerS(), FNStringGetAlphabetDigitS(), FNStringGetAlphabetUnderscoreS() ) )
 //
END

// library: string: get: word: token: last: return a given integer amount of characters from the right of a given string (=RIGHT$ in BASIC) <description></description> <version control></version control> <version>1.0.0.0.5</version> (filenamemacro=stririrs.s) [<Program>] [<Research>] [kn, ri, tu, 13-10-1998 20:05:49]
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

// library: string: get: initialization: global <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstigl.s) [<Program>] [<Research>] [kn, ri, mo, 22-05-2006 23:44:33]
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

// library: string: get: section: separator <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstssh.s) [<Program>] [<Research>] [kn, ri, mo, 22-05-2006 23:43:21]
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

// library: string: get: filename: ini: default: cross: platform <description></description> <version control></version control> <version>1.0.0.0.11</version> <version control></version control> (filenamemacro=getstcpm.s) [<Program>] [<Research>] [kn, ri, we, 15-10-2025 23:15:56]
STRING PROC FNStringGetFilenameIniDefaultCrossPlatformS()
 // e.g. PROC Main()
 // e.g. STRING s[255] = ""
 // e.g.  s = FNStringGetFilenameIniDefaultCrossPlatformS() // gives e.g. "c:\documents and settings\administrator\application data\dddpath.ini"
 // e.g.  IF NOT EditFile( QuotePath( s ) )
 // e.g.   Warn( "could not open the file", ":", " ", s, ".", " ", "Please check." )
 // e.g.   RETURN()
 // e.g.  ENDIF
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( "c:\dddpath.ini" )
 //
 STRING fileNameS[255] = ""
 //
 IF FNProgramGetOperatingSystemLinuxNonWslB()
  //
  // You will have to hard code the username(s) (or put it in a global variable SetGlobalStr() as the first lines in the start programs. Otherwise it calls itself recursively while searching) [kn, ri, sa, 18-10-2025 20:11:39]
  // fileNameS = Format( "/home/", FNStringGetUserNameLinuxNonWslS(), "/c/users/", FNStringGetUserNameMicrosoftWindowsS(), "/appdata/roaming/", FNStringGet_FilenameIniDefaultS() )
  fileNameS = Format( "/home/knudvaneeden/c/users/knud_/appdata/roaming/", FNStringGet_FilenameIniDefaultS() )
  //
 ELSEIF FNProgramGetOperatingSystemLinuxWslB()
  //
  // You will have to hard code the username(s) (or put it in a global variable SetGlobalStr() as the first lines in the start programs. Otherwise it calls itself recursively while searching) [kn, ri, sa, 18-10-2025 20:11:39]
  // fileNameS = Format( "/mnt/c/users/", userNameMicrosoftWindowsGS, "/appdata/roaming/", FNStringGet_FilenameIniDefaultS() )
  fileNameS = Format( "/mnt/c/users/knud_/appdata/roaming/", FNStringGet_FilenameIniDefaultS() )
  //
 ELSEIF FNProgramGetOperatingSystemMicrosoftWindowsB()
  //
  fileNameS = FNStringGetConcatS( FNStringGetPathUser_DataApplicationCurrentBackslashS(), FNStringGet_FilenameIniDefaultS() )
  //
 ELSE
  //
  Warn( "Unknown operating system. Please check." )
  //
 ENDIF
 //
 RETURN( fileNameS )
 //
END

// library: line: check: select: mark: line: begin: end <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checlibf.s) [<Program>] [<Research>] [kn, ri, su, 13-11-2005 00:33:54]
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

// library: initialize: check: new: boolean: false <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checinbf.s) [<Program>] [<Research>] [kn, ri, su, 22-07-2001 15:58:06]
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

// library: string: get: search: option: block: mark: global: expression: regular <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getsterj.s) [<Program>] [<Research>] [kn, ri, su, 10-04-2005 15:11:40]
STRING PROC FNStringGetSearchOptionBlockMark_GlobalExpressionRegularS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchOptionBlockMark_GlobalExpressionRegularS() ) // gives e.g. alphabetically "glx" and further "gxl" / "lgx" / "lxg" / "xgl" / "xlg"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatS( FNStringGetSearchOptionGlobalBlockMarkS(), FNStringGetSearchOptionExpressionRegularS() ) )
 //
END

// library: string: get: search: between: regular: expression: tag <description>search: regular expression: tag: between</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstetb.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 16:10:58]
STRING PROC FNStringGetSearchBetweenRegularExpressionTagS( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchBetweenRegularExpressionTagS( s ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcat3S( FNStringGetSearchRegularExpressionTagBeginS(), s, FNSearchRegularExpressionTagEndS() ) )
 //
END

// library: string: get: search: character: default: any: zero: or: more: minimum: regular: expression <description>search: regular expression: sequence: character: zero or more repetions of any character: tse</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstred.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 15:52:59]
STRING PROC FNStringGetSearchCharacterDefaultAnyZeroOrMoreMinimumRegularExpressionS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchCharacterDefaultAnyZeroOrMoreMinimumRegularExpressionS() ) // gives ...
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNSearchCharacterAnyZeroOrMoreMinimumRegularExpressionS( FNStringGetCaseLowerS( FNStringGetFileExtensionToTypeNameCurrentS() ) ) )
 //
END

// library: string: get: search: escape <description>search: regular expression: escape symbol</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstset.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 15:42:58]
STRING PROC FNStringGetSearchEscapeS( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchEscapeS( s ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatS( FNStringGetSearchSymbolEscapeS(), s ) )
 //
END

// library: string: get: character: symbol: ")" <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcpa.s) [<Program>] [<Research>] [kn, ri, su, 29-07-2001 16:25:41]
STRING PROC FNStringGetCharacterSymbolRoundCloseParenthesisS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterSymbolRoundCloseParenthesisS() ) // gives ")"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterSymbolCentralS( 41 ) )
 //
END

// library: text: found: tag: get: first <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstgfi.s) [<Program>] [<Research>] [kn, ri, tu, 27-02-2001 06:01:20]
STRING PROC FNStringGetTextFoundTagGetFirstS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTextFoundTagGetFirstS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetTextFoundTagS( 1 ) )
 //
END

// library: warn: cons <description>error: warning: give a warning message via 2 strings</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=conswawc.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 18:24:52]
PROC PROCWarnCons( STRING s1, STRING s2 )
 // e.g. PROC Main()
 // e.g.  PROCWarnCons( "error", "1" ) // gives e.g. "error 1"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCWarn( FNStringGetConsS( s1, s2 ) )
 //
END

// library: string: get: search: option: expression: regular: goto: search: end <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstseo.s) [<Program>] [<Research>] [kn, ri, su, 30-10-2005 00:23:32]
STRING PROC FNStringGetSearch_OptionExpressionRegularGotoS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearch_OptionExpressionRegularGotoS() ) // gives "\c"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "\c" )
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

// library: math: number: compare: number1 SMALLER THAN or EQUAL THAN zero? <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checmaea.s) [<Program>] [<Research>] [kn, ri, mo, 09-07-2001 14:23:43]
INTEGER PROC FNMathCheckNumberSmallerOrEqualZeroB( INTEGER x )
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckNumberSmallerOrEqualZeroB( -3 ) ) // gives TRUE, because -3 is smaller or equal to zero
 // e.g.  Message( FNMathCheckNumberSmallerOrEqualZeroB( +3 ) ) // gives FALSE, because +3 is not smaller and also not equal to zero
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckNumber_Difference_SmallerOrEqualB( x, 0 ) )
 //
END

// library: string: get: mid: string <description></description> <version control>string: get: word: token: middle: return a given integer amount of characters from a given startposition</version control> <version>1.0.0.0.9</version> (=MID$ in BASIC) <version>1.0.0.0.9</version> (filenamemacro=getstmid.s) [<Program>] [<Research>] [kn, ri, tu, 13-10-1998 20:29:00]
STRING PROC FNStringGetMidStringS( STRING s, INTEGER beginI, INTEGER totalI  )
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

// library: math: check: number: in: range: not <description>input: math: number: integer: not within a numerical range?</description> <version>1.0.0.0.2</version> (filenamemacro=checmarn.s) [<Program>] [<Research>] [kn, ri, su, 22-07-2001 18:24:51]
INTEGER PROC FNMathCheckNumberInRangeNotB( INTEGER I, INTEGER minI, INTEGER maxI )
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckNumberInRangeNotB( 1, 0, 100 ) ) // gives e.g. FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckLogicNotB( FNMathCheckNumberInRangeB( I, minI, maxI ) ) )
 //
END

// library: instr: check: found: not <description>string: search/find: found: not</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checinfo.s) [<Program>] [<Research>] [[kn, ri, we, 12-06-2002 00:08:02]
INTEGER PROC FNInstrCheckFoundNotB( INTEGER I )
 // e.g. PROC Main()
 // e.g.  Message( FNInstrCheckFoundNotB( FNMathGetStringSearchInstrI( "knud", "n" ) ) ) // gives FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckNumberEqualB( I, 0 ) ) // can also be -1 e.g. in JavaScript, so keep this instead of using FNMathCheckNumberEqualZeroB()
 //
END

// library: string: get: alphabet: lower <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstalo.s) [<Program>] [<Research>] [kn, ni, tu, 22-04-2003 20:34:44]
STRING PROC FNStringGetAlphabetLowerS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetAlphabetLowerS() ) // gives e.g. "abcdefghijklmnopqrstuvwxyz"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCaseLowerS( FNStringGetAlphabetS() ) )
 //
END

// library: string: get: alphabet: digit <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstadi.s) [<Program>] [<Research>] [kn, ri, tu, 22-04-2003 20:39:06]
STRING PROC FNStringGetAlphabetDigitS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetAlphabetDigitS() ) // gives e.g. "0123456789"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "0123456789" )
 //
END

// library: string: get: alphabet: underscore <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstaun.s) [<Program>] [<Research>] [kn, ri, tu, 22-04-2003 20:40:40]
STRING PROC FNStringGetAlphabetUnderscoreS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetAlphabetUnderscoreS() ) // gives e.g. "_"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterSymbolUnderScoreS() )
 //
END

// library: program: get: operating: system: linux: non: wsl <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getprnws.s) [<Program>] [<Research>] [kn, ri, fr, 10-10-2025 18:38:29]
INTEGER PROC FNProgramGetOperatingSystemLinuxNonWslB()
 // e.g. PROC Main()
 // e.g.  Message( FNProgramGetOperatingSystemLinuxNonWslB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <Ctrl F12> Main()
 //
 // ===
 //
 // Use case =
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 // ===
 //
 // ===
 //
 // Example:
 //
 // Input:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // ===
 //
 // e.g. // QuickHelp( HELPDEFFNProgramGetOperatingSystemLinuxNonWslB )
 // e.g. HELPDEF HELPDEFFNProgramGetOperatingSystemLinuxNonWslB
 // e.g.  title = "FNProgramGetOperatingSystemLinuxNonWslB() help" // The help's caption
 // e.g.  x = 100 // Location
 // e.g.  y = 3 // Location
 // e.g.  //
 // e.g.  // The actual help text
 // e.g.  //
 // e.g.  "Usage:"
 // e.g.  "//"
 // e.g.  "1. Run this TSE macro"
 // e.g.  "2. Then press <CtrlAlt F1> to show this help."
 // e.g.  "3. Press <Shift Escape> to quit."
 // e.g.  "//"
 // e.g.  ""
 // e.g.  "Key: Definitions:"
 // e.g.  ""
 // e.g.  "<> = do something"
 // e.g. END
 //
 INTEGER B = FALSE
 //
 STRING s[255] = ""
 //
 s = FNStringGetOperatingSystemS()
 //
 B = EquiStr( s, "Linux non-WSL" )
 //
 RETURN( B )
 //
END

// library: string: get: filename: ini: default <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstide.s) [<Program>] [<Research>] [kn, ri, sa, 21-02-2004 22:54:12]
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

// library: program: get: operating: system: linux: wsl <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getprlws.s) [<Program>] [<Research>] [kn, ri, fr, 10-10-2025 18:38:43]
INTEGER PROC FNProgramGetOperatingSystemLinuxWslB()
 // e.g. PROC Main() //
 // e.g.  Message( FNProgramGetOperatingSystemLinuxWslB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <Ctrl F12> Main()
 //
 // ===
 //
 // Use case =
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 // ===
 //
 // ===
 //
 // Example:
 //
 // Input:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // ===
 //
 // e.g. // QuickHelp( HELPDEFFNProgramGetOperatingSystemLinuxWslB )
 // e.g. HELPDEF HELPDEFFNProgramGetOperatingSystemLinuxWslB
 // e.g.  title = "FNProgramGetOperatingSystemLinuxWslB() help" // The help's caption
 // e.g.  x = 100 // Location
 // e.g.  y = 3 // Location
 // e.g.  //
 // e.g.  // The actual help text
 // e.g.  //
 // e.g.  "Usage:"
 // e.g.  "//"
 // e.g.  "1. Run this TSE macro"
 // e.g.  "2. Then press <CtrlAlt F1> to show this help."
 // e.g.  "3. Press <Shift Escape> to quit."
 // e.g.  "//"
 // e.g.  ""
 // e.g.  "Key: Definitions:"
 // e.g.  ""
 // e.g.  "<> = do something"
 // e.g. END
 //
 INTEGER B = FALSE
 //
 STRING s[255] = ""
 //
 s = FNStringGetOperatingSystemS()
 //
 B = EquiStr( s, "Linux WSL" )
 //
 RETURN( B )
 //
END

// library: program: get: operating: system: microsoft: windows <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getprmwi.s) [<Program>] [<Research>] [kn, ri, fr, 10-10-2025 18:30:02]
INTEGER PROC FNProgramGetOperatingSystemMicrosoftWindowsB()
 // e.g. PROC Main()
 // e.g.  Message( FNProgramGetOperatingSystemMicrosoftWindowsB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <Ctrl F12> Main()
 //
 // ===
 //
 // Use case =
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 // ===
 //
 // ===
 //
 // Example:
 //
 // Input:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // ===
 //
 // e.g. // QuickHelp( HELPDEFFNProgramGetOperatingSystemMicrosoftWindowsB )
 // e.g. HELPDEF HELPDEFFNProgramGetOperatingSystemMicrosoftWindowsB
 // e.g.  title = "FNProgramGetOperatingSystemMicrosoftWindowsB() help" // The help's caption
 // e.g.  x = 100 // Location
 // e.g.  y = 3 // Location
 // e.g.  //
 // e.g.  // The actual help text
 // e.g.  //
 // e.g.  "Usage:"
 // e.g.  "//"
 // e.g.  "1. Run this TSE macro"
 // e.g.  "2. Then press <CtrlAlt F1> to show this help."
 // e.g.  "3. Press <Shift Escape> to quit."
 // e.g.  "//"
 // e.g.  ""
 // e.g.  "Key: Definitions:"
 // e.g.  ""
 // e.g.  "<> = do something"
 // e.g. END
 //
 INTEGER B = FALSE
 //
 STRING s[255] = ""
 //
 s = FNStringGetOperatingSystemS()
 //
 B = EquiStr( s, "Microsoft Windows NT" ) OR EquiStr( s, "Microsoft Windows non-NT" )
 //
 RETURN( B )
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

// library: string: get: search: expression: regular: block: mark: global <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstmgl.s) [<Program>] [<Research>] [kn, ri, tu, 05-04-2005 12:34:14]
STRING PROC FNStringGetSearchOptionGlobalBlockMarkS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchOptionGlobalBlockMarkS() ) // gives e.g. alphabetically "gl" and further "lg"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatS( FNStringGetSearchOption_Block_MarkS(), FNStringGetSearchOptionGlobalS() ) )
 //
END

// library: string: get: search: regular: expression: tag: begin <description>search: regular expression: tag: begin</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getsttbl.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 16:11:14]
STRING PROC FNStringGetSearchRegularExpressionTagBeginS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchRegularExpressionTagBeginS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterSymbolCurlyOpenParenthesisS() )
 //
END

// library: search: regular: expression: tag: end <description>search: regular expression: tag: end</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=regusete.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 16:11:14]
STRING PROC FNSearchRegularExpressionTagEndS()
 // e.g. PROC Main()
 // e.g.  Message( FNSearchRegularExpressionTagEndS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterSymbolCurlyCloseParenthesisS() )
 //
END

// library: search: character: any: zero: or: more: minimum: regular: expression <description>search: regular expression: sequence: character: zero or more repetions of any character</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=charsere.s) [<Program>] [<Research>] [[kn, ri, tu, 10-07-2001 23:21:51]
STRING PROC FNSearchCharacterAnyZeroOrMoreMinimumRegularExpressionS( STRING caseS )
 // e.g. PROC Main()
 // e.g.  Message( FNSearchCharacterAnyZeroOrMoreMinimumRegularExpressionS( caseS ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 STRING defaultS[255] = FNStringGetConcatS( FNStringGetSearchCharacterAnyRegularExpressionS( caseS ), FNSearchRepeatZeroOrMoreMinimumRegularExpressionS( caseS ) )
 //
 CASE FNStringGetCaseLowerS( caseS )
  //
  WHEN "javascript"
   //
   s = defaultS
   //
  WHEN "tse"
   //
   s = defaultS
   //
  WHEN "perl"
   //
   s = defaultS
   //
  OTHERWISE
   //
   s = defaultS
   //
   // PROCErrorCaseNotFound( FNStringGetEmptyS(), "FNSearchCharacterAnyZeroOrMoreMinimumRegularExpressionS(", caseS )
   //
   // s = FNStringGetErrorS()
   //
 ENDCASE
 //
 RETURN( s )
 //
END

// library: string: uppercase/lowercase: lower case: convert characters in string to lower case <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstclp.s) [<Program>] [<Research>] [kn, zoe, we, 30-06-1999 01:21:07]
STRING PROC FNStringGetCaseLowerS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: case: lower: string = ", "This is a test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCaseLowerS( s1 ) ) // gives e.g. "this is a test"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Lower( s ) )
 //
END

// library: string: get: file: extension: to: type: name: current <description>file: convert: extension: extension to filetype given current extension</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstndn.s) [<Program>] [<Research>] [kn, zoe, tu, 24-10-2000 23:29:14]
STRING PROC FNStringGetFileExtensionToTypeNameCurrentS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFileExtensionToTypeNameCurrentS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileExtensionToTypeNameS( FNFileGetExtensionCurrentPointS() ) )
 //
END

// library: string: get: search: symbol: escape: regular expression <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstesy.s) [<Program>] [<Research>] [kn, ri, su, 29-07-2001 15:42:58]
STRING PROC FNStringGetSearchSymbolEscapeS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchSymbolEscapeS() ) // gives e.g. "\"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterSymbolSlashBackwardS() )
 //
END

// library: text: found: get: get given tag from found text <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstfta.s) [<Program>] [<Research>] [kn, zoe, we, 20-10-1999 00:04:31]
STRING PROC FNStringGetTextFoundTagS( INTEGER tagI )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTextFoundTagS( 2 ) ) // gives e.g. ...""
 // e.g.  // Second example, this time retrieving the 2nd tagged
 // e.g.  // expression found.
 // e.g.  // STRING s[80]
 // e.g.  // IF FNTextCheckSearchExpressionFoundB( "{^a}{.*}{z$}", "x" )
 // e.g.  //  s = GetFoundText(2) // get tag #2
 // e.g.  //  Message( s )
 // e.g.  // ENDIF
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetTextFoundTagCentralS( tagI ) )
 //
END

// library: math: number: compare: number1 SMALLER THAN or EQUAL TO number2? <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmaoh.s) [<Program>] [<Research>] [kn, ri, th, 03-05-2001 13:55:01]
INTEGER PROC FNMathCheckNumber_Difference_SmallerOrEqualB( INTEGER x1, INTEGER x2 )
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckNumber_Difference_SmallerOrEqualB( 3, 3 ) ) // gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( x1 <= x2 )
 //
END

// library: math: check: number: in: range <description>input: math: number: integer: within a numerical range? ( xmin <= x <= xmax ) gives TRUE</description> <version>1.0.0.0.2</version> (filenamemacro=checmair.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 17:32:54]
INTEGER PROC FNMathCheckNumberInRangeB( INTEGER I, INTEGER minI, INTEGER maxI )
 // e.g. PROC Main()
 // e.g.  Warn( FNMathCheckNumberInRangeB( 5, 0, 10 ) ) // gives TRUE
 // e.g.  Warn( FNMathCheckNumberInRangeB( 0, 0, 10 ) ) // gives TRUE
 // e.g.  Warn( FNMathCheckNumberInRangeB( 10, 0, 10 ) ) // gives TRUE
 // e.g.  Warn( FNMathCheckNumberInRangeB( 20, 0, 10 ) ) // gives FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // variation:
 //
 // IF FNMathCheckLogicNotB( I IN minI..maxI )
 //
 //  PROCError( FNStringGetMathIntegerToStringS( I ) + ": must be between min " + FNStringGetMathIntegerToStringS( minI ) + " and maximum " + FNStringGetMathIntegerToStringS( maxI ))
 //
 //  RETURN( FNMathCheckGetLogicFalseB() )
 //
 // ENDIF
 //
 // RETURN( FNMathCheckGetLogicTrueB() )
 //
 RETURN( I IN minI..maxI )
 //
END

// library: string: get: operating: system <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstosy.s) [<Program>] [<Research>] [kn, ri, fr, 10-10-2025 18:26:13]
STRING PROC FNStringGetOperatingSystemS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetOperatingSystemS() ) // gives e.g. "Microsoft Windows"
 // e.g. END
 // e.g.
 // e.g. <Ctrl F12> Main()
 //
 // ===
 //
 // Use case =
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 // ===
 //
 // ===
 //
 // Example:
 //
 // Input:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // ===
 //
 // e.g. // QuickHelp( HELPDEFFNStringGetOperatingSystemS )
 // e.g. HELPDEF HELPDEFFNStringGetOperatingSystemS
 // e.g.  title = "FNStringGetOperatingSystemS() help" // The help's caption
 // e.g.  x = 100 // Location
 // e.g.  y = 3 // Location
 // e.g.  //
 // e.g.  // The actual help text
 // e.g.  //
 // e.g.  "Usage:"
 // e.g.  "//"
 // e.g.  "1. Run this TSE macro"
 // e.g.  "2. Then press <CtrlAlt F1> to show this help."
 // e.g.  "3. Press <Shift Escape> to quit."
 // e.g.  "//"
 // e.g.  ""
 // e.g.  "Key: Definitions:"
 // e.g.  ""
 // e.g.  "<> = do something"
 // e.g. END
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetOperatingSystemS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <Ctrl F12> Main()
 //
 // ===
 //
 // Use case =
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 // ===
 //
 // ===
 //
 // Example:
 //
 // Input:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // ===
 //
 // e.g. // QuickHelp( HELPDEFFNStringGetOperatingSystemS )
 // e.g. HELPDEF HELPDEFFNStringGetOperatingSystemS
 // e.g.  title = "FNStringGetOperatingSystemS() help" // The help's caption
 // e.g.  x = 100 // Location
 // e.g.  y = 3 // Location
 // e.g.  //
 // e.g.  // The actual help text
 // e.g.  //
 // e.g.  "Usage:"
 // e.g.  "//"
 // e.g.  "1. Run this TSE macro"
 // e.g.  "2. Then press <CtrlAlt F1> to show this help."
 // e.g.  "3. Press <Shift Escape> to quit."
 // e.g.  "//"
 // e.g.  ""
 // e.g.  "Key: Definitions:"
 // e.g.  ""
 // e.g.  "<> = do something"
 // e.g. END
 //
 // create a temporary filename in the current directory
 STRING fileNameS[255] = QuotePath( MakeTempName( ".", ".TMP" ) )
 //
 INTEGER linuxWslB = FALSE
 //
 STRING s[255] = ""
 //
 PushPosition()
 PushBlock()
 //
 IF ( WhichOS() == _LINUX_ )
  //
  PushPosition()
  PushBlock()
  //
  Dos( Format( "cat /proc/version", " ", ">", " ", fileNameS ), _DONT_PROMPT_ )
  //
  EditFile( fileNameS )
  //
  linuxWslB = LFind( "microsoft", "gi" )
  //
  IF linuxWslB
   //
   s = "Linux WSL"
   //
  ELSE
   //
   s = "Linux non-WSL"
   //
  ENDIF
  //
 ELSEIF ( WhichOS() == _WINDOWS_ )
  //
  s = "Microsoft Windows non-NT"
  //
 ELSEIF ( WhichOS() == _WINDOWS_NT_ )
  //
  s = "Microsoft Windows NT"
  //
 ELSE
  //
  Warn( "Unknown operating system. Please check." )
  //
  s = FNStringGetErrorS()
  //
 ENDIF
 //
 IF EditFile( fileNameS )
  //
  AbandonFile()
  //
 ENDIF
 //
 EraseDiskFile( fileNameS )
 //
 PopBlock()
 PopPosition()
 //
 RETURN( s )
 //
END

// library: string: get: filename: end: back: slash: not: equal: insert: end <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstiep.s) [<Program>] [<Research>] [kn, ni, su, 17-08-2003 00:24:04]
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

// library: string: get: search: option: block: mark <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstbmb.s) [<Program>] [<Research>] [kn, ri, tu, 05-04-2005 12:56:06]
STRING PROC FNStringGetSearchOption_Block_MarkS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchOption_Block_MarkS() ) // gives e.g. "l"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "l" )
 //
END

// library: string: get: search: option <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstsop.s) [<Program>] [<Research>] [kn, ri, tu, 05-04-2005 12:56:30]
STRING PROC FNStringGetSearchOptionGlobalS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchOptionGlobalS() ) // gives e.g. "g"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "g" )
 //
END

// library: string: get: character: symbol: "{" <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstopc.s) [<Program>] [<Research>] [kn, ri, su, 29-07-2001 16:07:30]
STRING PROC FNStringGetCharacterSymbolCurlyOpenParenthesisS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterSymbolCurlyOpenParenthesisS() ) // gives "{"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterSymbolCentralS( 123 ) )
 //
END

// library: string: get: character: symbol: "}" <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcpc.s) [<Program>] [<Research>] [kn, ni, su, 29-07-2001 16:07:30]
STRING PROC FNStringGetCharacterSymbolCurlyCloseParenthesisS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterSymbolCurlyCloseParenthesisS() ) // gives "}"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterSymbolCentralS( 125 ) )
 //
END

// library: string: get: search: character: any: regular: expression <description>search: regular expression: character: any</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstree.s) [<Program>] [<Research>] [[kn, ri, tu, 10-07-2001 23:21:51]
STRING PROC FNStringGetSearchCharacterAnyRegularExpressionS( STRING caseS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchCharacterAnyRegularExpressionS( caseS ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 CASE caseS
  //
  WHEN "javascript"
   //
   s = "."
   //
  WHEN "tse"
   //
   s = "."
   //
  WHEN "perl"
   //
   s = "."
   //
  OTHERWISE
   //
   s = "."
   //
   // PROCErrorCaseNotFound( FNStringGetEmptyS(), "FNStringGetSearchCharacterAnyRegularExpressionS(", caseS )
   //
   // s = FNStringGetErrorS()
   //
 ENDCASE
 //
 RETURN( s )
 //
END

// library: search: repeat: zero: or: more: minimum: regular: expression <description>search: regular expression: zero or more repetitions</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=repesere.s) [<Program>] [<Research>] [[kn, ri, tu, 10-07-2001 23:21:51]
STRING PROC FNSearchRepeatZeroOrMoreMinimumRegularExpressionS( STRING caseS )
 // e.g. PROC Main()
 // e.g.  Message( FNSearchRepeatZeroOrMoreMinimumRegularExpressionS( caseS ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 CASE caseS
  //
  WHEN "javascript"
   //
   s = "*"
   //
  WHEN "tse"
   //
   s = "*"
   //
  WHEN "perl"
   //
   s = "*"
   //
  OTHERWISE
   //
   s = "*"
   //
   // PROCErrorCaseNotFound( FNStringGetEmptyS(), "FNSearchRepeatZeroOrMoreRegularExpressionS(", caseS )
   //
   // s = FNStringGetErrorS()
   //
 ENDCASE
 //
 RETURN( s )
 //
END

// library: string: get: file: extension: to: type: name <description>file: convert: extension: extension to filetype</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getsttnd.s) [<Program>] [<Research>] [kn, ni, th, 29-07-1999 18:15:02]
STRING PROC FNStringGetFileExtensionToTypeNameS( STRING fileextensionS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFileExtensionToTypeNameS( ".s" ) ) // gives "TSE"
 // e.g.  Message( FNStringGetFileExtensionToTypeNameS( ".bas" ) ) // gives "BBCBASIC"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = FNStringGetInitializeNewStringS()
 //
 CASE fileextensionS
  //
  WHEN ".asm"
   //
   s = FNStringGetTokenLanguageAssemblerS()
   //
  WHEN ".asp"
   //
   s = FNStringGetTokenLanguageAspS()
   //
  WHEN ".bas", ".bbc"
   //
   s = FNStringGetTokenLanguageBasicS()
   //
  WHEN ".bas"
   //
   s = FNStringGetTokenLanguageVisualBasicS()
   //
  WHEN ".bat"
   //
   s = FNStringGetTokenLanguageBatS()
   //
  WHEN ".c", ".h"
   //
   s = FNStringGetTokenLanguageCS()
   //
  WHEN ".cfm"
   //
   s = FNStringGetTokenLanguageColdFusionS()
   //
  WHEN ".cpp", ".hpp"
   //
   s = FNStringGetTokenLanguageCppS()
   //
  WHEN ".cs"
   //
   s = FNStringGetTokenLanguageCSharpS()
   //
  WHEN ".del"
   //
   s = FNStringGetTokenLanguageDelphiS()
   //
  WHEN ".dok"
   //
   s = FNStringGetTokenLanguageDokS()
   //
  WHEN ".dtd"
   //
   s = FNStringGetTokenLanguageDtdS()
   //
  WHEN ".for"
   //
   s = FNStringGetTokenLanguageFortranS()
   //
  WHEN ".htm"
   //
   s = FNStringGetTokenLanguageHtmlS()
   //
  WHEN ".java", ".jav"
   //
   s = FNStringGetTokenLanguageJavaS()
   //
  WHEN ".js"
   //
   s = FNStringGetTokenLanguageJavaScriptS()
   //
  WHEN ".jsp"
   //
   s = FNStringGetTokenLanguageJspS()
   //
  WHEN ".log"
   //
   s = FNStringGetTokenLanguageLogoS()
   //
  WHEN ".lsp", ".cl"
   //
   s = FNStringGetTokenLanguageLispS()
   //
  WHEN ".lot"
   //
   s = FNStringGetTokenLanguageLotusScriptS()
   //
  WHEN ".map"
   //
   s = FNStringGetTokenLanguageMapleS()
   //
  WHEN ".pas"
   //
   s = FNStringGetTokenLanguagePascalS()
   //
  WHEN ".pl"
   //
   s = FNStringGetTokenLanguagePerlS()
   //
  WHEN ".php"
   //
   s = FNStringGetTokenLanguagePhpS()
   //
  WHEN ".pro"
   //
   s = FNStringGetTokenLanguagePrologS()
   //
  WHEN ".tex"
   //
   s = FNStringGetTokenLanguageTexS()
   //
  WHEN ".ps"
   //
   s = FNStringGetTokenLanguagePostScriptS()
   //
  WHEN ".py"
   //
   s = FNStringGetTokenLanguagePythonS()
   //
  WHEN ".sql"
   //
   s = FNStringGetTokenLanguageSqlS()
   //
  WHEN ".s"
   //
   s = FNStringGetTokenLanguageTseCaseUpperS()
   //
  WHEN ".uml"
   //
   s = FNStringGetTokenLanguageUmlS()
   //
  WHEN ".vb"
   //
   s = FNStringGetTokenLanguageVisualBasicS()
   //
  WHEN ".vbs"
   //
   s = FNStringGetTokenLanguageVBScriptS()
   //
  WHEN ".xml"
   //
   s = FNStringGetTokenLanguageXmlS()
   //
  WHEN ".xsd"
   //
   s = FNStringGetTokenLanguageXsdS()
   //
  WHEN ".xsl"
   //
   s = FNStringGetTokenLanguageXslS()
   //
  OTHERWISE
   //
   PROCErrorCaseNotFound( FNStringGetEmptyS(), "FNStringGetFileExtensionToTypeNameS(", "File extension :" + fileextensionS + ": not defined yet. Please define it" )
   //
   s = FNStringGetErrorS()
   //
 ENDCASE
 //
 RETURN( s )
 //
END

// library: string: get: character: symbol: "\" <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstsba.s) [<Program>] [<Research>] [kn, ri, su, 29-07-2001 15:41:11]
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

// library: string: get: text: found: tag: central <description></description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getsttcg.s) [<Program>] [<Research>] [kn, ri, mo, 23-07-2001 00:14:06]
STRING PROC FNStringGetTextFoundTagCentralS( INTEGER tagI )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "1"
 // e.g.  IF ( NOT ( Ask( " = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Message( FNStringGetTextFoundTagCentralS( Val( s1 ) ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( GetFoundText( tagI ) )
 //
END

// library: string: get: backslash: if last character is not equal to '\', then concatenate a backslash to the end of the given string <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstien.s) [<Program>] [<Research>] [kn, ri, sa, 24-02-2001 23:48:15]
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

// library: environment: string: get (Searches for and Returns a Specified Environment Str) R    GetEnvStr(STRING s)* <description></description> <version control></version control> <version>1.0.0.0.4</version> (filenamemacro=getstgen.s) [<Program>] [<Research>] [kn, ri, th, 25-10-2001 01:44:48]
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

// library: environment: check: found: not <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checenfn.s) [<Program>] [<Research>] [kn, ri, sa, 27-05-2006 20:20:03]
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

// library: string: get: token: language: assembler <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlat.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:08:04]
STRING PROC FNStringGetTokenLanguageAssemblerS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageAssemblerS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "ASSEMBLER" )
 //
END

// library: string: get: token: language: asp <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlas.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:08:04]
STRING PROC FNStringGetTokenLanguageAspS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageAspS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "ASP" )
 //
END

// library: string: get: token: language: basic <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlba.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:12]
STRING PROC FNStringGetTokenLanguageBasicS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageBasicS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "BBCBASIC" )
 //
END

// library: string: get: token: language: visual: basic <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstvba.s) [<Program>] [<Research>] [kn, ri, sa, 23-03-2002 20:25:55]
STRING PROC FNStringGetTokenLanguageVisualBasicS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageVisualBasicS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "VISUALBASIC" )
 //
END

// library: string: get: token: language: bat <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlbb.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:11]
STRING PROC FNStringGetTokenLanguageBatS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageBatS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "BATCH" )
 //
END

// library: string: get: token: language: c <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlc.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:11]
STRING PROC FNStringGetTokenLanguageCS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageCS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "C" )
 //
END

// library: string: get: token: language: cold: fusion <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstcfx.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:10]
STRING PROC FNStringGetTokenLanguageColdFusionS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageColdFusionS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "COLDFUSION" )
 //
END

// library: string: get: token: language: cpp <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlcp.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:11]
STRING PROC FNStringGetTokenLanguageCppS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageCppS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "C++" )
 //
END

// library: string: get: token: language: c: sharp <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstcsl.s) [<Program>] [<Research>] [kn, ri, fr, 15-02-2002 20:23:19]
STRING PROC FNStringGetTokenLanguageCSharpS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageCSharpS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "C#" )
 //
END

// library: string: get: token: language: delphi <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstldh.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:10]
STRING PROC FNStringGetTokenLanguageDelphiS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageDelphiS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "DELPHI" )
 //
END

// library: string: get: token: language: dok <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstldo.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:10]
STRING PROC FNStringGetTokenLanguageDokS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageDokS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "DOK" )
 //
END

// library: string: get: token: language: dtd <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstldt.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:11]
STRING PROC FNStringGetTokenLanguageDtdS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageDtdS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "DTD" )
 //
END

// library: string: get: token: language: fortran <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlfo.s) [<Program>] [<Research>] [kn, ri, sa, 23-03-2002 20:25:55]
STRING PROC FNStringGetTokenLanguageFortranS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageFortranS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "FORTRAN" )
 //
END

// library: string: get: token: language: html <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlht.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:10]
STRING PROC FNStringGetTokenLanguageHtmlS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageHtmlS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "HTML" )
 //
END

// library: string: get: token: language: java <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlja.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:10]
STRING PROC FNStringGetTokenLanguageJavaS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageJavaS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "JAVA" )
 //
END

// library: string: get: token: language: java: script <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstjse.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:10]
STRING PROC FNStringGetTokenLanguageJavaScriptS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageJavaScriptS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "JAVASCRIPT" )
 //
END

// library: string: get: token: language: jsp <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstljs.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:09]
STRING PROC FNStringGetTokenLanguageJspS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageJspS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "JSP" )
 //
END

// library: string: get: token: language: logo <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstllq.s) [<Program>] [<Research>] [kn, ri, sa, 23-03-2002 20:26:25]
STRING PROC FNStringGetTokenLanguageLogoS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageLogoS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "LOGO" )
 //
END

// library: string: get: token: language: lisp <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstllp.s) [<Program>] [<Research>] [kn, ri, sa, 23-03-2002 20:25:55]
STRING PROC FNStringGetTokenLanguageLispS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageLispS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "LISP" )
 //
END

// library: string: get: token: language: lotus: script <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlsc.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:09]
STRING PROC FNStringGetTokenLanguageLotusScriptS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageLotusScriptS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "LOTUSSCRIPT" )
 //
END

// library: string: get: token: language: maple <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlmc.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:09]
STRING PROC FNStringGetTokenLanguageMapleS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageMapleS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "MAPLE" )
 //
END

// library: string: get: token: language: pascal <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlpc.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:08]
STRING PROC FNStringGetTokenLanguagePascalS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguagePascalS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "PASCAL" )
 //
END

// library: string: get: token: language: perl <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlpf.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:08]
STRING PROC FNStringGetTokenLanguagePerlS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguagePerlS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "PERL" )
 //
END

// library: string: get: token: language: php <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlph.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:08]
STRING PROC FNStringGetTokenLanguagePhpS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguagePhpS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "PHP" )
 //
END

// library: string: get: token: language: prolog <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlpr.s) [<Program>] [<Research>] [kn, ri, sa, 23-03-2002 20:27:23]
STRING PROC FNStringGetTokenLanguagePrologS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguagePrologS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "PROLOG" )
 //
END

// library: string: get: token: language: tex <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlte.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:07]
STRING PROC FNStringGetTokenLanguageTexS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageTexS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "TEX" )
 //
END

// library: string: get: token: language: post: script <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstpsc.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:07]
STRING PROC FNStringGetTokenLanguagePostScriptS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguagePostScriptS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "POSTSCRIPT" )
 //
END

// library: string: get: token: language: python <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlpz.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:07]
STRING PROC FNStringGetTokenLanguagePythonS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguagePythonS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "PYTHON" )
 //
END

// library: string: get: token: language: sql <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlsq.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:07]
STRING PROC FNStringGetTokenLanguageSqlS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageSqlS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "SQL" )
 //
END

// library: string: get: token: language: tse: case: upper <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstcuu.s) [<Program>] [<Research>] [kn, ri, su, 06-11-2005 20:54:36]
STRING PROC FNStringGetTokenLanguageTseCaseUpperS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageTseCaseUpperS() ) // gives e.g. "TSE"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetTokenCaseUpperCentralS( FNStringGetTokenNameClipboardTseS() ) )
 //
END

// library: string: get: token: language: uml <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlum.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:07]
STRING PROC FNStringGetTokenLanguageUmlS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageUmlS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "UML" )
 //
END

// library: string: get: token: language: v: b: script <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstbsc.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:07]
STRING PROC FNStringGetTokenLanguageVBScriptS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageVBScriptS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "VBSCRIPT" )
 //
END

// library: string: get: token: language: xml <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlxm.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:08:57]
STRING PROC FNStringGetTokenLanguageXmlS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageXmlS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "XML" )
 //
END

// library: string: get: token: language: xsd <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlxs.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:08:57]
STRING PROC FNStringGetTokenLanguageXsdS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageXsdS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "XSD" )
 //
END

// library: string: get: token: language: xsl <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstlxt.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:08:57]
STRING PROC FNStringGetTokenLanguageXslS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageXslS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "XSL" )
 //
END

// library: compare if string end is equal, if not so insert that string at the end <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstenp.s) [<Program>] [<Research>] [kn, ri, sa, 24-02-2001 23:06:33]
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

// library: environment: check: found: not <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checenfn.s) [<Program>] [<Research>] [kn, ri, sa, 27-05-2006 20:20:03]
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

// library: string: get: name: clipboard: tse <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstctt.s) [<Program>] [<Research>] [kn, ri, su, 17-04-2005 17:39:50]
STRING PROC FNStringGetTokenNameClipboardTseS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenNameClipboardTseS() ) // gives e.g. "tse"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetTokenLanguageTseS() )
 //
END

// library: string: word: equal: last: compare if a given string is equal at the end to another given string <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checstln.s) [<Program>] [<Research>] [kn, zoe, we, 29-11-2000 19:08:34]
INTEGER PROC FNStringCheckEqualCharacterLastNB( STRING s, STRING tailS )
 // e.g. //
 // e.g. // version: first parameter s then endS
 // e.g. //
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckEqualCharacterLastNB( "knud", "d" ) ) //  gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( FNStringGetRightStringLengthEqualS( s, tailS ), tailS ) )
 //
END

// library: string: get: concat: tail: suffix <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstctb.s) [<Program>] [<Research>] [kn, ri, su, 02-09-2001 03:08:08]
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

// library: math: check: logic: or: 2 arguments <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmalo.s) [<Program>] [<Research>] [kn, ri, tu, 15-05-2001 16:54:17]
INTEGER PROC FNMathCheckLogicOrB( INTEGER B1, INTEGER B2 )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "math: check: logic: or: number1 = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "math: check: logic: or: number2 = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNMathCheckLogicOrB( FNStringGetToIntegerI( s1 ), FNStringGetToIntegerI( s2 ) ) ) // gives e.g. TRUE
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

// library: string: get: token: language: tse <description></description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstltt.s) [<Program>] [<Research>] [kn, ri, we, 07-11-2001 06:09:07]
STRING PROC FNStringGetTokenLanguageTseS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTokenLanguageTseS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "tse" )
 //
END

// library: STRING: get: right: string: length: equal <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstler.s) [<Program>] [<Research>] [kn, ni, su, 30-11-2003 23:32:40]
STRING PROC FNStringGetRightStringLengthEqualS( STRING s, STRING tailS
)
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetRightStringLengthEqualS( "Knud van Eeden", "12345" ) ) // gives e.g. "Eeden"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetRightStringS( s, FNStringGetLengthI( tailS ) ) )
 //
END
