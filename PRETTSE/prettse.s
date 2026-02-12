FORWARD INTEGER PROC FNBlockCheckCurrentIsMarkedB()
FORWARD INTEGER PROC FNBlockCheckCursorInBlockB()
FORWARD INTEGER PROC FNBlockCheckGotoBeginB()
FORWARD INTEGER PROC FNBlockCheckGotoBeginNotB()
FORWARD INTEGER PROC FNBlockCheckIsMarkedNotCurrentDefaultMessageB()
FORWARD INTEGER PROC FNBlockCheckIsMarkedNotCurrentMessageB( STRING s1 )
FORWARD INTEGER PROC FNBlockGetCurrentMarkedTypeI()
FORWARD INTEGER PROC FNBlockGetPrintPrettySubTseI( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNBufferGetBufferIdFileCurrentI()
FORWARD INTEGER PROC FNBufferGetBufferIdGivenBufferNameI( STRING s1 )
FORWARD INTEGER PROC FNCursorCheckGotoDownB()
FORWARD INTEGER PROC FNCursorCheckGotoRightB()
FORWARD INTEGER PROC FNErrorCheckEscapeB( STRING s1 )
FORWARD INTEGER PROC FNErrorCheckSB( STRING s1 )
FORWARD INTEGER PROC FNFileCheckEditCentralMessageB( STRING s1, INTEGER i1 )
FORWARD INTEGER PROC FNFileCheckEditMessageB( STRING s1 )
FORWARD INTEGER PROC FNFileCheckGotoEndB()
FORWARD INTEGER PROC FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( STRING s1, INTEGER i1 )
FORWARD INTEGER PROC FNKeyCheckPressEscapeB( STRING s1 )
FORWARD INTEGER PROC FNLineCheckGotoBeginB()
FORWARD INTEGER PROC FNLineCheckInsertAfterLineGotoBeginTextInsertB( STRING s1 )
FORWARD INTEGER PROC FNLineCheckSelectMarkB()
FORWARD INTEGER PROC FNLineCheckSelectMarkLineBeginEndB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMacroCheckExecB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckLoadB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckPurgeB( STRING s1 )
FORWARD INTEGER PROC FNMathCheckGetLogicFalseB()
FORWARD INTEGER PROC FNMathCheckGetLogicTrueB()
FORWARD INTEGER PROC FNMathCheckInitializeNewBooleanTrueB()
FORWARD INTEGER PROC FNMathCheckLogicNotB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheckLogicOrB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathCheckNumberEqualB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathCheckNumberEqualZeroB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheckNumberEqualZeroNotB( INTEGER i1 )
FORWARD INTEGER PROC FNMathGetErrorI()
FORWARD INTEGER PROC FNMathGetInitializeNewI()
FORWARD INTEGER PROC FNMathGetIntegerMaximumAbsoluteI()
FORWARD INTEGER PROC FNMathGetIntegerMinimumAbsoluteI()
FORWARD INTEGER PROC FNMathGetIntegerZeroI()
FORWARD INTEGER PROC FNMathGetProgramLineNumberAbsoluteCurrentI()
FORWARD INTEGER PROC FNScreenGetWindowColumnTotalI()
FORWARD INTEGER PROC FNStringCheckEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEnvironmentFoundNotB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNStringCheckEqualCharacterLastNB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNStringCheckEqualErrorOrEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringGetLengthI( STRING s1 )
FORWARD INTEGER PROC FNTextCheckDeleteWordRightB()
FORWARD INTEGER PROC FNTextCheckInsertB( STRING s1 )
FORWARD INTEGER PROC FNTextCheckInsertCentralB( STRING s1, INTEGER i1 )
FORWARD INTEGER PROC FNTextCheckReplaceB( STRING s1, STRING s2, STRING s3 )
FORWARD INTEGER PROC FNTextCheckSearchExpressionB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNTextCheckSearchExpressionFoundB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNTextGetPositionWindowColumnCurrentI()
FORWARD INTEGER PROC FNWindowCheckScrollHorizontalB()
FORWARD INTEGER PROC FNWindowGetScrollHorizontalI()
FORWARD PROC Main()
FORWARD PROC PROCBlockChangeConvertPrintPrettyTse( INTEGER i1, INTEGER i2 )
FORWARD PROC PROCBlockChangePrintPrettyBracket( STRING s1, STRING s2 )
FORWARD PROC PROCBlockChangePrintPrettyCaseDefault()
FORWARD PROC PROCBlockChangePrintPrettyCaseDefaultSub( STRING s1 )
FORWARD PROC PROCBlockChangePrintPrettyCaseUpper()
FORWARD PROC PROCBlockChangePrintPretty_BracketOpen( STRING s1 )
FORWARD PROC PROCBlockChangePrint_PrettyBracketClosed( STRING s1 )
FORWARD PROC PROCBlockGotoBegin()
FORWARD PROC PROCBlockInsertPrintPretty( STRING s1, INTEGER i1 )
FORWARD PROC PROCBlockRemoveSpaceLineBegin()
FORWARD PROC PROCBlockRemoveStackPop()
FORWARD PROC PROCBlockReplaceWordCaseUpper( STRING s1 )
FORWARD PROC PROCBlockSaveStackPush()
FORWARD PROC PROCBlockSelectClearMark()
FORWARD PROC PROCCursorGotoRight()
FORWARD PROC PROCError( STRING s1 )
FORWARD PROC PROCErrorCaseNotFound( STRING s1, STRING s2, STRING s3 )
FORWARD PROC PROCErrorFileNotFound( STRING s1 )
FORWARD PROC PROCFileGotoEnd()
FORWARD PROC PROCFileInsertEndPrepare()
FORWARD PROC PROCFileInsertTextEnd( STRING s1, STRING s2, INTEGER i1 )
FORWARD PROC PROCLineGotoBeginTextInsert( STRING s1 )
FORWARD PROC PROCLineInsertAfter()
FORWARD PROC PROCLineInsertAfterLineGotoBeginTextInsert( STRING s1 )
FORWARD PROC PROCLineRemoveWordFront()
FORWARD PROC PROCLineSelectMarkCurrent()
FORWARD PROC PROCMacroExec( STRING s1 )
FORWARD PROC PROCMacroPurge( STRING s1 )
FORWARD PROC PROCMacroRunKeep( STRING s1 )
FORWARD PROC PROCMacroRunPurge( STRING s1 )
FORWARD PROC PROCMacroRunPurgeParameter( STRING s1, STRING s2 )
FORWARD PROC PROCScreenGotoScrollLeft_HorizontalN( INTEGER i1 )
FORWARD PROC PROCSituationRestoreOld()
FORWARD PROC PROCSituationStoreOld()
FORWARD PROC PROCTextGotoLineBegin()
FORWARD PROC PROCTextInsert( STRING s1 )
FORWARD PROC PROCTextInsertLineTextFront( STRING s1 )
FORWARD PROC PROCTextRemovePositionStackPop()
FORWARD PROC PROCTextRemoveWordRight()
FORWARD PROC PROCTextReplace( STRING s1, STRING s2, STRING s3 )
FORWARD PROC PROCTextSavePositionStackPush()
FORWARD PROC PROCTextSearchFindScrollLeft()
FORWARD PROC PROCTextSelectMarkHiLiteFound()
FORWARD PROC PROCWarn( STRING s1 )
FORWARD PROC PROCWarnCons3( STRING s1, STRING s2, STRING s3 )
FORWARD PROC PROCWarnCons4( STRING s1, STRING s2, STRING s3, STRING s4 )
FORWARD PROC PROCWarnCons5( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5 )
FORWARD STRING PROC FNStringGetAsciiToCharacterS( INTEGER i1 )
FORWARD STRING PROC FNStringGetCarCentralS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetCarFirstS( STRING s1 )
FORWARD STRING PROC FNStringGetCarNS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetCarS( STRING s1 )
FORWARD STRING PROC FNStringGetCarSecondS( STRING s1 )
FORWARD STRING PROC FNStringGetCarThirdS( STRING s1 )
FORWARD STRING PROC FNStringGetCaseUpperS( STRING s1 )
FORWARD STRING PROC FNStringGetCharacterEndBackSlashNotEqualInsertEndS( STRING s1 )
FORWARD STRING PROC FNStringGetCharacterInsertEndIfEqualNotS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetCharacterSymbolCentralS( INTEGER i1 )
FORWARD STRING PROC FNStringGetCharacterSymbolSlashBackwardS()
FORWARD STRING PROC FNStringGetCharacterSymbolSpaceS()
FORWARD STRING PROC FNStringGetConcat3S( STRING s1, STRING s2, STRING s3 )
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
FORWARD STRING PROC FNStringGetInStringS( INTEGER i1, STRING s1 )
FORWARD STRING PROC FNStringGetInitializationGlobalS( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetInitializeNewStringS()
FORWARD STRING PROC FNStringGetLeftStringS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetLineGetCurrentS()
FORWARD STRING PROC FNStringGetLineNumberCurrentS()
FORWARD STRING PROC FNStringGetMachineNameS()
FORWARD STRING PROC FNStringGetMathIntegerToStringS( INTEGER i1 )
FORWARD STRING PROC FNStringGetMidStringS( STRING s1, INTEGER i1, INTEGER i2 )
FORWARD STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashNotS()
FORWARD STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashS()
FORWARD STRING PROC FNStringGetPortS()
FORWARD STRING PROC FNStringGetRightStringLengthEqualS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetRightStringS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetSearchOptionAskNotS()
FORWARD STRING PROC FNStringGetSearchOptionBlockMarkGlobalAskNotS()
FORWARD STRING PROC FNStringGetSearchOptionBlockMarkGlobalExpressionRegularAskNotS()
FORWARD STRING PROC FNStringGetSearchOptionExpressionRegularS()
FORWARD STRING PROC FNStringGetSearchOptionGlobalBlockMarkS()
FORWARD STRING PROC FNStringGetSearchOptionGlobalS()
FORWARD STRING PROC FNStringGetSearchOption_Block_MarkS()
FORWARD STRING PROC FNStringGetSectionSeparatorS()
FORWARD STRING PROC FNStringGetTextFoundS()
FORWARD STRING PROC FNStringGetTextMarkS()
FORWARD STRING PROC FNStringGetTokenCaseUpperCentralS( STRING s1 )
FORWARD STRING PROC FNStringGetTokenFunctionNameCaseUpperS()
FORWARD STRING PROC FNStringGetTokenProgramFunctionNameS()
FORWARD STRING PROC FNStringGetTokenProgramProcedureNameS()
FORWARD STRING PROC FNStringGetTokenProgram_ProcedureNameCaseUpperS()
FORWARD STRING PROC FNStringGetUserNameFirstS()
FORWARD STRING PROC FNStringGetUserNameLastS()
FORWARD STRING PROC FNStringGet_FilenameIniDefaultS()


// --- MAIN --- //

PROC Main()
 STRING s1[255] = "0" // 1 = add indent spaces around '(' or ')' parentheses // 0 = do not // change this
 STRING s2[255] = "0" // 1 = add indent PROC | FN | B( | S( // 0 = do not // change this
 PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default
 IF ( NOT ( Ask( "change: convert: block: print: pretty print: bracketSpaceInsertB = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 //
 PROCBlockChangeConvertPrintPrettyTse( Val( s1 ), Val( s2 ) )
 //
END

<F12> Main()

// --- LIBRARY --- //

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

// library: change: convert: block: print: pretty print <description></description> <version control></version control> <version>1.0.0.0.25</version> (filenamemacro=prettse.s) [<Program>] [<Research>] [kn, zoe, we, 13-10-1999 19:06:35]
PROC PROCBlockChangeConvertPrintPrettyTse( INTEGER bracketSpaceInsertB, INTEGER functionProcedureTypeB )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "0" // 1 = add indent spaces around '(' or ')' parentheses // 0 = do not // change this
 // e.g.  STRING s2[255] = "0" // 1 = add indent PROC | FN | B( | S( // 0 = do not // change this
 // e.g.  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default
 // e.g.  IF ( NOT ( Ask( "change: convert: block: print: pretty print: bracketSpaceInsertB = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  //
 // e.g.  PROCBlockChangeConvertPrintPrettyTse( Val( s1 ), Val( s2 ) )
 // e.g.  //
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // Use case = Pretty print for TSE SAL. It is a special case of refactoring, because you change the source code, but not the functionality of that source code.
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 // Idea
 //
 // The basic idea for pretty print would be that:
 //  1. If you find a begin word you move it to the right
 //  2. If you find a corresponding end word you move it to the left
 //  3. else you do nothing
 //
 // In practice you have a space counting variable that you
 // systematically decrease or increase depending on the words found
 //
 //  ---
 //
 //  How to use?
 //
 //  Steps:
 //
 //  1. Load this file in your TSE editor
 //  2. Compile this file (e.g. via <CTRL><F9>)
 //  3. Goto the other file you want to pretty print
 //  4. In this other file highlight a block of TSE code you want to pretty print
 //
 // ===
 //
 // Example:
 //
 // Input:
 //
 /*
--- cut here: begin --------------------------------------------------
FOR T = 1 TO 4
WHILE
This is a test
ENDWHILE
ENDFOR
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
FOR T = 1 TO 4
 WHILE
  This is a test
 ENDWHILE
ENDFOR
--- cut here: end ----------------------------------------------------
 */
 //
 // Todo:
 //
 //  [kn, ri, sa, 20-08-2022 11:59:57]
 //  -Add a boolean yes/no to add 'PROC' or 'FN' in front of function or procedure name definitions. [kn, ri, fr, 19-08-2022 16:15:43]
 //  -Thus check if this can be isolated in the source code. [kn, ri, fr, 19-08-2022 16:15:45]
 //
 // ===
 //
 // e.g. // QuickHelp( HELPDEFPROCBlockChangeConvertPrintPrettyTse )
 // e.g. HELPDEF HELPDEFPROCBlockChangeConvertPrintPrettyTse
 // e.g.  title = "PROCBlockChangeConvertPrintPrettyTse() help" // The help's caption
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
 INTEGER indentI = FNMathGetInitializeNewI()
 //
 INTEGER downB = FNMathCheckInitializeNewBooleanTrueB()
 //
 IF ( FNBlockCheckIsMarkedNotCurrentDefaultMessageB() ) RETURN() ENDIF // return from the current procedure if no block is marked
 //
 // replace tab (\t or ASCII 09) by spaces
 //
 PushKey( <D> ) // added [kn, ri, sa, 20-08-2022 14:12:51]
 PROCMacroRunPurge( "tabutil" ) // added [kn, ri, sa, 20-08-2022 14:12:51]
 //
 PROCBlockChangePrintPrettyCaseUpper()
 //
 PROCTextSavePositionStackPush()
 //
 PROCBlockRemoveSpaceLineBegin()
 //
 // [line ] +
 //
 PROCBlockGotoBegin()
 //
 WHILE FNBlockCheckCursorInBlockB() AND downB
  //
  indentI = FNBlockGetPrintPrettySubTseI( indentI, functionProcedureTypeB )
  //
  downB = FNCursorCheckGotoDownB()
  //
 ENDWHILE
 //
 PROCBlockChangePrintPrettyCaseDefault() // added [kn, ri, sa, 20-08-2022 13:18:33]
 //
 IF ( bracketSpaceInsertB )
  //
  PROCBlockChangePrintPrettyBracket( "(", ")" )
  //
  PROCBlockChangePrintPrettyBracket( "[", "]" )
  //
  PROCBlockChangePrintPrettyBracket( "{", "}" )
  //
 ENDIF
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

// library: initialize: check: new: boolean: true <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checinbt.s) [<Program>] [<Research>] [kn, ri, su, 22-07-2001 15:58:01]
INTEGER PROC FNMathCheckInitializeNewBooleanTrueB()
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckInitializeNewBooleanTrueB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckGetLogicTrueB() )
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

// library: block: change: pretty print: keywords in upper case <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=prinblcu.s) [<Program>] [<Research>] [kn, ri, tu, 20-02-2001 10:07:24]
PROC PROCBlockChangePrintPrettyCaseUpper()
 // e.g. PROC Main()
 // e.g.  PROCBlockChangePrintPrettyCaseUpper()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCBlockReplaceWordCaseUpper( "abs" )
 //
 PROCBlockReplaceWordCaseUpper( "and" )
 //
 PROCBlockReplaceWordCaseUpper( "asc" )
 //
 PROCBlockReplaceWordCaseUpper( "binary" )
 //
 PROCBlockReplaceWordCaseUpper( "break" )
 //
 PROCBlockReplaceWordCaseUpper( "by" )
 //
 PROCBlockReplaceWordCaseUpper( "case" )
 //
 PROCBlockReplaceWordCaseUpper( "chr" )
 //
 PROCBlockReplaceWordCaseUpper( "chrset" )
 //
 PROCBlockReplaceWordCaseUpper( "color" )
 //
 PROCBlockReplaceWordCaseUpper( "config" )
 //
 PROCBlockReplaceWordCaseUpper( "constant" )
 //
 PROCBlockReplaceWordCaseUpper( "datadef" )
 //
 PROCBlockReplaceWordCaseUpper( "do" )
 //
 PROCBlockReplaceWordCaseUpper( "downto" )
 //
 PROCBlockReplaceWordCaseUpper( "else" )
 //
 PROCBlockReplaceWordCaseUpper( "elseif" )
 //
 PROCBlockReplaceWordCaseUpper( "end" )
 //
 PROCBlockReplaceWordCaseUpper( "endcase" )
 //
 PROCBlockReplaceWordCaseUpper( "endconfig" )
 //
 PROCBlockReplaceWordCaseUpper( "enddo" )
 //
 PROCBlockReplaceWordCaseUpper( "endfor" )
 //
 PROCBlockReplaceWordCaseUpper( "endif" )
 //
 PROCBlockReplaceWordCaseUpper( "endloop" )
 //
 PROCBlockReplaceWordCaseUpper( "endwhile" )
 //
 PROCBlockReplaceWordCaseUpper( "false" )
 //
 PROCBlockReplaceWordCaseUpper( "for" )
 //
 PROCBlockReplaceWordCaseUpper( "forward" )
 //
 PROCBlockReplaceWordCaseUpper( "goto" )
 //
 PROCBlockReplaceWordCaseUpper( "halt" )
 //
 PROCBlockReplaceWordCaseUpper( "helpdef" )
 //
 PROCBlockReplaceWordCaseUpper( "if" )
 //
 PROCBlockReplaceWordCaseUpper( "iif" )
 //
 PROCBlockReplaceWordCaseUpper( "in" )
 //
 PROCBlockReplaceWordCaseUpper( "include" )
 //
 PROCBlockReplaceWordCaseUpper( "integer" )
 //
 PROCBlockReplaceWordCaseUpper( "keydef" )
 //
 PROCBlockReplaceWordCaseUpper( "length" )
 //
 PROCBlockReplaceWordCaseUpper( "loop" )
 //
 PROCBlockReplaceWordCaseUpper( "maxint" )
 //
 PROCBlockReplaceWordCaseUpper( "maxlinelen" )
 //
 PROCBlockReplaceWordCaseUpper( "menu" )
 //
 PROCBlockReplaceWordCaseUpper( "menubar" )
 //
 PROCBlockReplaceWordCaseUpper( "minint" )
 //
 PROCBlockReplaceWordCaseUpper( "mod" )
 //
 PROCBlockReplaceWordCaseUpper( "not" )
 //
 PROCBlockReplaceWordCaseUpper( "off" )
 //
 PROCBlockReplaceWordCaseUpper( "on" )
 //
 PROCBlockReplaceWordCaseUpper( "or" )
 //
 PROCBlockReplaceWordCaseUpper( "otherwise" )
 //
 PROCBlockReplaceWordCaseUpper( "proc" )
 //
 PROCBlockReplaceWordCaseUpper( "public" )
 //
 PROCBlockReplaceWordCaseUpper( "register" )
 //
 PROCBlockReplaceWordCaseUpper( "repeat" )
 //
 PROCBlockReplaceWordCaseUpper( "return" )
 //
 PROCBlockReplaceWordCaseUpper( "shl" )
 //
 PROCBlockReplaceWordCaseUpper( "shr" )
 //
 PROCBlockReplaceWordCaseUpper( "sizeof" )
 //
 PROCBlockReplaceWordCaseUpper( "string" )
 //
 PROCBlockReplaceWordCaseUpper( "tabset" )
 //
 PROCBlockReplaceWordCaseUpper( "times" )
 //
 PROCBlockReplaceWordCaseUpper( "to" )
 //
 PROCBlockReplaceWordCaseUpper( "true" )
 //
 PROCBlockReplaceWordCaseUpper( "until" )
 //
 PROCBlockReplaceWordCaseUpper( "var" )
 //
 PROCBlockReplaceWordCaseUpper( "when" )
 //
 PROCBlockReplaceWordCaseUpper( "while" )
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

// library: block: text: space: delete: remove any space in begin of line (e.g. when OCR text from Cuneiform containing a lot of spurious spaces between the words) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=remobllb.s) [<Program>] [<Research>] [kn, ri, th, 29-04-1999 02:35:54]
PROC PROCBlockRemoveSpaceLineBegin()
 // e.g. PROC Main()
 // e.g.  PROCBlockRemoveSpaceLineBegin()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 WHILE FNTextCheckReplaceB( "^ ", FNStringGetEmptyS(), FNStringGetSearchOptionBlockMarkGlobalExpressionRegularAskNotS() )
 //
 ENDWHILE
 //
END

// library: block: goto: movement: goto the beginning of the block (and also to the beginning of that line) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=gotoblgc.s) [<Program>] [<Research>] [kn, zoe, mo, 29-03-1999 20:46:25]
PROC PROCBlockGotoBegin()
 // e.g. PROC Main()
 // e.g.  PROCBlockGotoBegin()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNBlockCheckGotoBeginNotB()
  //
  // PROCWarn( "Block: Goto: Begin: Already in begin or NO block marked in the current file" )
  //
 ENDIF
 //
END

// library: block: check: cursor: is cursor in block? (Determines Whether Cursor is Inside a Marked Block) N    * <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checblic.s) [<Program>] [<Research>] [kn, ri, mo, 29-03-1999 20:24:05]
INTEGER PROC FNBlockCheckCursorInBlockB()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockCheckCursorInBlockB() ) // gives TRUE or FALSE depending on if the cursor is in the highlighted blcok, or not
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( IsCursorInBlock() )
 //
END

// library: block: get: print: pretty: sub: tse <description>block: movement: go through all lines in a marked block: do something</description> <version control></version control> <version>1.0.0.0.17</version> <version control></version control> (filenamemacro=getblsts.s) [<Program>] [<Research>] [kn, zoe, we, 13-10-1999 19:06:35]
INTEGER PROC FNBlockGetPrintPrettySubTseI( INTEGER indentI, INTEGER functionProcedureTypeB )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "0" // 1 = add indent PROC | FN | B( | S( // 0 = do not // change this
 // e.g.  Message( FNBlockGetPrintPrettySubTseI( 3, Val( s1 ) ) ) // gives e.g. 3
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING lineS[255] = FNStringGetLineGetCurrentS()
 //
 STRING firstS[255] = FNStringGetCaseUpperS( FNStringGetCarFirstS( lineS ) )
 //
 STRING secondS[255] = FNStringGetCaseUpperS( FNStringGetCarSecondS( lineS ) )
 //
 CASE firstS
  //
  WHEN
   //
   "INTEGER",
   //
   "STRING"
     //
     IF FNStringCheckEqualB( secondS, FNStringGetTokenProgram_ProcedureNameCaseUpperS() )
      //
      PROCLineRemoveWordFront() // remove word INTEGER or STRING
      //
      PROCLineRemoveWordFront() // remove word PROC
      //
      IF FNMathCheckLogicNotB( FNStringCheckEqualB( FNStringGetLeftStringS( FNStringGetCaseUpperS( FNStringGetCarThirdS( lineS ) ), 2 ), FNStringGetTokenFunctionNameCaseUpperS() ) ) // IF NOT found function 'FN'
       //
       PROCTextSavePositionStackPush()
       //
       IF FNTextCheckSearchExpressionFoundB( "(", "c" ) // search first occurrence of '('
        //
        CASE firstS
         //
         WHEN "STRING" // when it was 'STRING'
          //
          IF ( functionProcedureTypeB )
           //
           PROCTextInsert( "S" )
          ENDIF
          //
         WHEN "INTEGER" // when it was 'INTEGER'
          //
          IF ( functionProcedureTypeB )
           //
           PROCTextInsert( "B" )
           //
          ENDIF
          //
         OTHERWISE
          //
          PROCErrorCaseNotFound( FNStringGetEmptyS(), "FNBlockGetPrintPrettySubTseI(", firstS )
          //
          RETURN( FNMathGetErrorI() )
          //
        ENDCASE
        //
       ENDIF
       //
       PROCTextRemovePositionStackPop()
       //
       firstS = FNStringGetCaseUpperS( FNStringGetConsS( firstS, secondS ) )
       //
       PROCLineGotoBeginTextInsert( FNStringGetConsS( FNStringGetTokenProgram_ProcedureNameCaseUpperS(), FNStringGetTokenFunctionNameCaseUpperS() ) )
       //
      ENDIF
      //
     ENDIF
     //
  WHEN
   //
   "PROC"
    //
    IF FNMathCheckLogicNotB( FNStringCheckEqualB( FNStringGetLeftStringS( FNStringGetCaseUpperS( FNStringGetCarSecondS( lineS ) ), 4 ), FNStringGetTokenProgram_ProcedureNameCaseUpperS() ) )
     //
     PROCLineRemoveWordFront()
     //
     PROCLineGotoBeginTextInsert( FNStringGetConsS( FNStringGetTokenProgram_ProcedureNameCaseUpperS(), FNStringGetTokenProgram_ProcedureNameCaseUpperS() ) )
     //
    ENDIF
    //
  WHEN
   //
   "IF" // one liner END-IF
     //
     IF FNTextCheckSearchExpressionFoundB( "ENDIF", "ic" )
      //
      firstS = "IF-ENDIF"
      //
     ENDIF
     //
 ENDCASE
 //
 CASE firstS
  //
  WHEN
   //
   "#DEFINE", // added [kn, ri, mo, 15-08-2022 10:27:34]
   //
   "PROC",
   //
   "PUBLIC",
   //
   "MENU",
   //
   "KEYDEF",
   //
   "DATADEF",
   //
   "HELPDEF",
   //
   "STRING PROC",
   //
   "INTEGER PROC"
     //
     firstS = FNStringGetCaseUpperS( firstS )
     //
     PROCBlockInsertPrintPretty( firstS, indentI )
     //
     indentI = 1
     //
  WHEN
   //
   "WHILE",
   //
   "DO",
   //
   "FOR",
   //
   "CASE",
   //
   "REPEAT",
   //
   "IFF", // added [kn, ri, fr, 19-08-2022 14:42:37]
   //
   "IF"       // one line 'IF' has to be tested by 'ENDIF' on end of line: not implemented yet (do this via 'IF FNTextCheckSearchExpressionFoundB( "ENDIF", "ic" )') [kn, zoe, th, 04-11-1999 01:30:28]
     //
     firstS = FNStringGetCaseUpperS( firstS )
     //
     PROCBlockInsertPrintPretty( firstS, indentI )
     //
     indentI = indentI + 1
     //
  WHEN
   //
   "ENDWHILE",
   //
   "ENDDO",
   //
   "ENDFOR",
   //
   "ENDCASE",
   //
   "UNTIL",
   //
   "ENDIF",
   //
   "END",
   //
   "ELSE" // added [kn, ri, sa, 20-08-2022 15:16:38]
     //
     firstS = FNStringGetCaseUpperS( firstS )
     //
     indentI = indentI - 1
     //
     PROCBlockInsertPrintPretty( firstS, indentI )
     //
     IF ( firstS == "ELSE" ) // added [kn, ri, sa, 20-08-2022 15:11:24]
      indentI = indentI + 1 // added [kn, ri, sa, 20-08-2022 15:16:28]
     ENDIF // added [kn, ri, sa, 20-08-2022 15:16:30]
     //
  WHEN
   //
   "IF-ENDIF"
     //
     PROCBlockInsertPrintPretty( "IF", indentI )
     //
  OTHERWISE
   //
   PROCTextInsertLineTextFront( FNStringGetInStringS( indentI, " " ) )
   //
 ENDCASE
 //
 RETURN( indentI )
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

// library: block: change: print: pretty: case: default <description></description> <version control></version control> <version>1.0.0.0.4</version> <version control></version control> (filenamemacro=chanblce.s) [<Program>] [<Research>] [kn, ri, sa, 20-08-2022 13:06:30]
PROC PROCBlockChangePrintPrettyCaseDefault()
 // e.g. PROC Main()
 // e.g.  PROCBlockChangePrintPrettyCaseDefault()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // Use case = Replace any case insensitive occurrence with the desired case sensitive version
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
 // e.g. // QuickHelp( HELPDEFPROCBlockChangePrintPrettyCaseDefault )
 // e.g. HELPDEF HELPDEFPROCBlockChangePrintPrettyCaseDefault
 // e.g.  title = "PROCBlockChangePrintPrettyCaseDefault() help" // The help's caption
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
 PROCBlockChangePrintPrettyCaseDefaultSub( "IIF(" )
 //
 PROCBlockChangePrintPrettyCaseDefaultSub( "BegLine(" )
 PROCBlockChangePrintPrettyCaseDefaultSub( "GotoBlockBegin(" )
 PROCBlockChangePrintPrettyCaseDefaultSub( "IsCursorInBlock(" )
 PROCBlockChangePrintPrettyCaseDefaultSub( "LReplace(" )
 PROCBlockChangePrintPrettyCaseDefaultSub( "Message(" )
 PROCBlockChangePrintPrettyCaseDefaultSub( "PopPosition(" )
 PROCBlockChangePrintPrettyCaseDefaultSub( "PushPosition(" )
 PROCBlockChangePrintPrettyCaseDefaultSub( "Set(" )
 PROCBlockChangePrintPrettyCaseDefaultSub( "Warn(" )
 PROCBlockChangePrintPrettyCaseDefaultSub( "WrapPara(" )
 //
END

// library: block: change: print: pretty print: bracket<description>one space after every opening bracket and one space before every closing bracket</description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=prinblpb.s) [<Program>] [<Research>] [kn, zoe, we, 17-11-1999 02:28:59]
PROC PROCBlockChangePrintPrettyBracket( STRING bracketopenS, STRING bracketclosedS )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "block: print: pretty: bracketopenS = ", "(" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "block: print: pretty: bracketclosedS = ", ")" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  PROCBlockChangePrintPrettyBracket( s1, s2 )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCBlockChangePrintPretty_BracketOpen( bracketopenS )
 //
 PROCBlockChangePrint_PrettyBracketClosed( bracketclosedS )
 //
 PROCTextReplace( "( )", "()", "igln" )
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

// library: math: get: integer: zero <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getmaize.s) [<Program>] [<Research>] [kn, ri, we, 06-02-2002 21:12:47]
INTEGER PROC FNMathGetIntegerZeroI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetIntegerZeroI() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( 0 )
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

// library: block: replace: case: upper: word: convert in marked block given word to upper case <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=replcauw.s) [<Program>] [<Research>] [kn, ri, su, 07-04-2002 19:47:19]
PROC PROCBlockReplaceWordCaseUpper( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCBlockReplaceWordCaseUpper( "ddd" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF ( FNBlockCheckIsMarkedNotCurrentDefaultMessageB() ) RETURN() ENDIF // return from the current procedure if no block is marked
 //
 PROCTextReplace( s, FNStringGetCaseUpperS( s ), "inlgw" )
 //
END

// library: text: check: replace <description>string: replace: replace text old for new (Performs Low-Level Replace() Command)</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=chectecx.s) [<Program>] [<Research>] [[kn, ri, mo, 24-08-1998 02:45:27]
INTEGER PROC FNTextCheckReplaceB( STRING replaceoldS, STRING replacenewS, STRING searchOptionS )
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckReplaceB( "knud", "best", "" ) ) // gives "best"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( LReplace( replaceoldS, replacenewS, searchOptionS ) )
 //
END

// library: string: get: empty (return an empty string) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgem.s) [<Program>] [<Research>] [kn, ri, sa, 20-05-2000 20:11:03]
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

// library: string: get: search: option: block: mark: global: expression: regular: ask: not <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstano.s) [<Program>] [<Research>] [kn, amv, tu, 05-04-2005 12:43:09]
STRING PROC FNStringGetSearchOptionBlockMarkGlobalExpressionRegularAskNotS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchOptionBlockMarkGlobalExpressionRegularAskNotS() ) // gives e.g. alphabetically "glnx" and further "gxnl" / "gxln" / "gnxl" / "gnlx" / "glxn" / "lgnx" / "lxgn" / "lngx" / "lnxg" / "lgxn" / "lgnx" / "nlxg" / "nlgx" / "ngxl" / "nglx" / "nxgl" / "nxlg" / "xnlg" / "xngl" / "xlgn" / "xlng" / "xgnl" / "xgln"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatS( FNStringGetSearchOptionBlockMarkGlobalAskNotS(), FNStringGetSearchOptionExpressionRegularS() ) )
 //
END

// library: block: check: goto: begin: not <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checblbo.s) [<Program>] [<Research>] [kn, ri, su, 27-05-2007 22:13:38]
INTEGER PROC FNBlockCheckGotoBeginNotB()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockCheckGotoBeginNotB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckLogicNotB( FNBlockCheckGotoBeginB() ) )
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

// library: string: get: word: token: get: first token <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcfn.s) [<Program>] [<Research>] [kn, ri, mo, 26-11-2001 17:20:03]
STRING PROC FNStringGetCarFirstS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: word: token: get: first: string = ", "this is a test line containing a lot of words" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCarFirstS( s1 ) ) // gives e.g. "this"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCarCentralS( s, 1 ) )
 //
END

// library: string: get: word: token: get: second token <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcsf.s) [<Program>] [<Research>] [kn, ri, mo, 26-11-2001 17:20:03]
STRING PROC FNStringGetCarSecondS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: word: token: get: second: string = ", "this is a test line containing a lot of words" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCarSecondS( s1 ) ) // gives e.g. "is"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCarCentralS( s, 2 ) )
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

// library: line: remove: word: front <description>line: remove: word: front</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=remoliwf.s) [<Program>] [<Research>] [[kn, ri, tu, 20-02-2001 08:49:54]
PROC PROCLineRemoveWordFront()
 // e.g. PROC Main()
 // e.g.  PROCLineRemoveWordFront()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextGotoLineBegin()
 //
 PROCTextRemoveWordRight()
 //
END

// library: string: get: word: token: first: return a given integer amount of characters from the left of a given string (=LEFT$ in BASIC) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=strilels.s) [<Program>] [<Research>] [kn, ri, tu, 13-10-1998 20:05:49]
STRING PROC FNStringGetLeftStringS( STRING s, INTEGER totalI )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING charactertotalS[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "string: word: token: get: left: string = ", "knud" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  charactertotalS = FNStringGetInputS( "string: word: token: get: left: character total = ", "2" )
 // e.g.  IF FNKeyCheckPressEscapeB( charactertotalS ) RETURN() ENDIF
 // e.g.  Message( FNStringGetLeftStringS( s, FNStringGetToIntegerI( charactertotalS ) ) ) //  gives e.g. "kn"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetMidStringS( s, 1, totalI ) )
 //
END

// library: string: get: word: token: get: third token <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcti.s) [<Program>] [<Research>] [kn, ri, mo, 26-11-2001 17:20:03]
STRING PROC FNStringGetCarThirdS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: word: token: get: third: string = ", "this is a test line containing a lot of words" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCarThirdS( s1 ) ) // gives e.g. "a"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCarCentralS( s, 3 ) )
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

// library: math: get: error <description>indicate, via the returned number, that an error occurred</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getmager.s) [<Program>] [<Research>] [kn, ri, th, 29-04-1999 21:19:56]
INTEGER PROC FNMathGetErrorI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetErrorI() ) // gives e.g. -( 2^31 - 1 ) = -2147483647
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathGetIntegerMinimumAbsoluteI() )
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

// library: text: insert: goto begin of line and insert <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotoliti.s) [<Program>] [<Research>] [kn, zoe, th, 12-10-2000 14:04:38]
PROC PROCLineGotoBeginTextInsert( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCLineGotoBeginTextInsert( "test" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextGotoLineBegin()
 //
 PROCTextInsert( s )
 //
END

// library: block: insert: pretty print: do something with the current line <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=inseblpp.s) [<Program>] [<Research>] [kn, zoe, we, 17-11-1999 02:17:58]
PROC PROCBlockInsertPrintPretty( STRING firstS, INTEGER indentI )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "block: insert: pretty: firstS = ", "FOR" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "block: insert: pretty: indentI = ", "3" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  PROCBlockInsertPrintPretty( s1, FNStringGetToIntegerI( s2 ) )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextGotoLineBegin()
 //
 WHILE IsWhite()
  //
  PROCCursorGotoRight()
  //
 ENDWHILE
 //
 PROCTextRemoveWordRight()
 //
 PROCTextInsertLineTextFront( FNStringGetConcat3S( FNStringGetInStringS( indentI, FNStringGetCharacterSymbolSpaceS() ), firstS, FNStringGetCharacterSymbolSpaceS() ) )
 //
END

// library: line: text: insert a given string in front of 1 line <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=textliif.s) [<Program>] [<Research>] [kn, zoe, th, 04-11-1999 00:21:11]
PROC PROCTextInsertLineTextFront( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCTextInsertLineTextFront( "test" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCTextGotoLineBegin()
 //
 PROCTextInsert( s )
 //
END

// library: string: get: in: string <description>create concatenated duplicates of a certain string (STRING$ in BBCBASIC)</description> <version>1.0.0.0.7</version> <version control></version control> (filenamemacro=getstist.s) [<Program>] [<Research>] [kn, zoe, th, 20-05-1999 11:25:55]
STRING PROC FNStringGetInStringS( INTEGER maxI, STRING inS )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "3" // change this
 // e.g.  STRING s2[255] = "a" // change this
 // e.g.  IF ( NOT ( Ask( "string: get: copy: create concatenated duplicates of a certain string: totalT = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "string: get: copy: create concatenated duplicates of a certain string: string = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Warn( FNStringGetInStringS( Val( s1 ), s2 ) ) // gives "aaa"
 // e.g.  Warn( FNStringGetInStringS( 15, "0" ) ) // gives "000000000000000"
 // e.g.  Warn( FNStringGetInStringS( 3, " " ) ) // gives "   "
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER minI = 1
 //
 INTEGER I = 0
 //
 STRING s[255] = ""
 //
 IF ( maxI <= 0 )
  //
  RETURN( "" )
  //
 ENDIF // minimum 1 character width block or more to insert
 //
 FOR I = minI TO maxI
  //
  s = Format( s, inS )
  //
 ENDFOR
 //
 RETURN( s )
 //
END

// library: block: change: print: pretty: case: default <description></description> <version control></version control> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=chanblce.s) [<Program>] [<Research>] [kn, ri, sa, 20-08-2022 13:06:30]
PROC PROCBlockChangePrintPrettyCaseDefaultSub( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCBlockChangePrintPrettyCaseDefaultSub( "BegLine(" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // Use case = Replace any case insensitive occurrence with the desired case sensitive version
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 //
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
 // e.g. // QuickHelp( HELPDEFPROCBlockChangePrintPrettyCaseDefaultSub )
 // e.g. HELPDEF HELPDEFPROCBlockChangePrintPrettyCaseDefaultSub
 // e.g.  title = "PROCBlockChangePrintPrettyCaseDefaultSub( s1 ) help" // The help's caption
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
 LReplace( s, s, "gilnw" )
 //
END

// library: block: change: print: pretty print: bracket <description>one space after every opening bracket</description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=prinblbo.s) [<Program>] [<Research>] [kn, zoe, we, 17-11-1999 02:26:18]
PROC PROCBlockChangePrintPretty_BracketOpen( STRING bracketopenS )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "block: print: pretty: bracketopenS = ", "(" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  PROCBlockChangePrintPretty_BracketOpen( s1 )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 WHILE FNTextCheckReplaceB( FNStringGetConcatS( bracketopenS, " " ), bracketopenS, FNStringGetSearchOptionBlockMarkGlobalAskNotS() )
 //
 ENDWHILE
 //
 PROCTextReplace( bracketopenS, FNStringGetConcatS( bracketopenS, " " ), FNStringGetSearchOptionBlockMarkGlobalAskNotS() )
 //
END

// library: block: change: pretty print: bracket <description>one space before every closing bracket</description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=prinblbc.s) [<Program>] [<Research>] [kn, zoe, we, 17-11-1999 02:26:34]
PROC PROCBlockChangePrint_PrettyBracketClosed( STRING bracketclosedS )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "block: pretty: bracketclosedS = ", ")" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  PROCBlockChangePrint_PrettyBracketClosed( s1 )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 WHILE FNTextCheckReplaceB( FNStringGetConcatS( FNStringGetCharacterSymbolSpaceS(), bracketclosedS ), bracketclosedS, FNStringGetSearchOptionBlockMarkGlobalAskNotS() )
 //
 ENDWHILE
 //
 PROCTextReplace( bracketclosedS, FNStringGetConcatS( FNStringGetCharacterSymbolSpaceS(), bracketclosedS ), FNStringGetSearchOptionBlockMarkGlobalAskNotS() )
 //
END

// library: text: replace <description>string: replace: replace text old for new</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=repltets.s) [<Program>] [<Research>] [[kn, ri, mo, 24-08-1998 02:45:27]
PROC PROCTextReplace( STRING replaceoldS, STRING replacenewS, STRING searchOptionS )
 // e.g. PROC Main()
 // e.g.  PROCTextReplace( replaceoldS, replacenewS, searchOptionS )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNTextCheckReplaceB( replaceoldS, replacenewS, searchOptionS ) )
 //
 // PROCWarn( "Text replace: " + replaceoldS + " was not found (anymore)" )
 //
 ENDIF
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

// library: string: get: search: option: block: mark: global: ask: not <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstanr.s) [<Program>] [<Research>] [kn, amv, tu, 05-04-2005 13:34:46]
STRING PROC FNStringGetSearchOptionBlockMarkGlobalAskNotS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchOptionBlockMarkGlobalAskNotS() ) // gives e.g. alphabetically "gln" and further "lgn" / "lng" / "gnl" / "nlg" / "ngl"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatS( FNStringGetSearchOptionGlobalBlockMarkS(), FNStringGetSearchOptionAskNotS() ) )
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

// library: block: goto: movement: goto the beginning of the block <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checblgb.s) [<Program>] [<Research>] [kn, zoe, mo, 29-03-1999 20:46:25]
INTEGER PROC FNBlockCheckGotoBeginB()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockCheckGotoBeginB() ) // gives 0 if failure, else non zero value
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( GotoBlockBegin() )
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

// library: line: mark: mark all the characters in the current line (e.g. 2040 characters) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=marklinc.s) [<Program>] [<Research>] [kn, zoe, mo, 14-06-1999 22:07:35]
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

// library: string: get: car: central <description>string: get: word: token: get: Nth token: central routine</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstccz.s) [<Program>] [<Research>] [[kn, ri, mo, 26-11-2001 17:20:03]
STRING PROC FNStringGetCarCentralS( STRING s, INTEGER I )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCarCentralS( s, I ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCarNS( s, I ) )
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

// library: text: remove: word: right <description>text: word: delete: right: deletes the word to the right of the cursor</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=remotewr.s) [<Program>] [<Research>] [[kn, zoe, we, 16-06-1999 01:06:52]
PROC PROCTextRemoveWordRight()
 // e.g. PROC Main()
 // e.g.  PROCTextRemoveWordRight()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNTextCheckDeleteWordRightB() )
  //
  // PROCWarn( "word: delete: right of cursor: not successful" )
  //
 ENDIF
 //
END

// library: string: get: mid: string <description></description> <version control>string: get: word: token: middle: return a given integer amount of characters from the a given startposition</version control> <version>1.0.0.0.7</version> (=MID$ in BASIC) <version>1.0.0.0.7</version> (filenamemacro=getstmid.s) [<Program>] [<Research>] [kn, ri, tu, 13-10-1998 20:29:00]
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

// library: math: get: integer: minimum: absolute <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getmamab.s) [<Program>] [<Research>] [kn, noot, mo, 09-07-2001 11:51:54]
INTEGER PROC FNMathGetIntegerMinimumAbsoluteI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetIntegerMinimumAbsoluteI() ) // gives always a negative integer. E.g. -4
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( - FNMathGetIntegerMaximumAbsoluteI() )
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

// library: cursor: goto: right <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotocugr.s) [<Program>] [<Research>] [kn, zoe, tu, 15-06-1999 23:46:50]
PROC PROCCursorGotoRight()
 // e.g. PROC Main()
 // e.g.  PROCCursorGotoRight()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNCursorCheckGotoRightB() )
  //
  // PROCWarn( "Could not go right"  )
  //
 ENDIF
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

// library: string: get: search: option: ask: not <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstanp.s) [<Program>] [<Research>] [kn, ri, tu, 05-04-2005 12:59:23]
STRING PROC FNStringGetSearchOptionAskNotS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchOptionAskNotS() ) // gives e.g. "n"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "n" )
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

// library: string: get: word: token: get: first: FNCarN(): Get the Nth word of a string (words delimited by a space " " (=space delimited list)). E.g. Message( FNCarN( "Knud is the best", 2 ) ) gives "is" // <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstco.s) [<Program>] [<Research>] [kn, ni, su, 02-08-1998 15:54:17]
STRING PROC FNStringGetCarNS( STRING s, INTEGER N )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: word: token: get: first: string = ", "this is a test line" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "string: get: word: token: get: first: position = ", "4" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCarNS( s1, FNStringGetToIntegerI( s2 ) ) ) // gives e.g. "test"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // variation: RETURN( FNStringGetTokenFirstNS( s, " ", N ) )
 //
 RETURN( GetToken( s, " ", N ) ) // faster, but not central
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

// library: text: check: delete: word: right <description>text: word: delete: rigtht: deletes the word to the right of the cursor</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=chectewr.s) [<Program>] [<Research>] [[kn, zoe, we, 16-06-1999 01:06:52]
INTEGER PROC FNTextCheckDeleteWordRightB()
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckDeleteWordRightB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( DelRightWord() )
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

// library: math: get: integer: maximum: absolute <description></description> <version control></version control> <version>1.0.0.0.4</version> (filenamemacro=getmamac.s) [<Program>] [<Research>] [kn, noot, mo, 09-07-2001 11:51:54]
INTEGER PROC FNMathGetIntegerMaximumAbsoluteI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetIntegerMaximumAbsoluteI() ) // gives the maximum value of an integer possible in TSE. This is currently 2147483647 (= 2^31 - 1. Note this is not 2^32 - 1 even if 32 bits, because 1 bit is reserved for the sign (thus '+' or '-'), as it are signed integers by design in TSE).
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( MAXINT )
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

// library: movement: line: left: go to the next character <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checcugr.s) [<Program>] [<Research>] [kn, zoe, we, 12-05-1999 15:48:01]
INTEGER PROC FNCursorCheckGotoRightB()
 // e.g. PROC Main()
 // e.g.  Message( FNCursorCheckGotoRightB() ) // gives e.g. TRUE when cursor successfully moved to the right
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Right() )
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

// library: file: check: edit: central: message <description></description> <version control></version control> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checfiex.s) [<Program>] [<Research>] [kn, ho, mo, 17-04-2006 17:41:21]
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
 PROCMacroRunPurgeParameter( "runprmcn", Format( FNStringGetMachineNameS(), ";", FNStringGetUserNameFirstS(), ";", FNStringGetUserNameLastS(), ";", FNStringGetPortS(), ";", "TSE@3A+File@3A+Load@3A+" + s + "&submit01=Create" ) )
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

// library: file: get: ini: default: central <description></description> <version control></version control> <version>1.0.0.0.6</version> (filenamemacro=getfiidf.s) [<Program>] [<Research>] [kn, ri, we, 31-12-2003 02:17:48]
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
 STRING s[255] = ""
 //
 s =FNStringGetFileGetFilenamePathDefaultS( searchS )
 //
 IF EquiStr( Trim( s ), "" )
  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
  Warn( searchS, ":", " ", "Mot found (or found but the value is the empty string). Please check dddpath.ini and adapt file bibdelph.del" )
 ENDIF
 //
 RETURN( FNStringGetFileGetFilenamePathDefaultS( searchS ) )
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

// library: file: get: filename: path: default <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getfipde.s) [<Program>] [<Research>] [kn, ri, we, 31-12-2003 02:14:28]
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

// library: filename: get: filename: ini: default <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getfiide.s) [<Program>] [<Research>] [kn, ri, we, 31-12-2003 02:15:47]
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

// library: STRING: get: right: string: length: equal <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstler.s) [<Program>] [<Research>] [kn, ni, su, 30-11-2003 23:32:40]
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
