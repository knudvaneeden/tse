FORWARD INTEGER PROC FNBufferGetBufferIdFileCurrentI()
FORWARD INTEGER PROC FNBufferGetBufferIdGivenBufferNameI( STRING s1 )
FORWARD INTEGER PROC FNErrorCheckEscapeB( STRING s1 )
FORWARD INTEGER PROC FNErrorCheckSB( STRING s1 )
FORWARD INTEGER PROC FNFileCheckEditCentralMessageB( STRING s1, INTEGER i1 )
FORWARD INTEGER PROC FNFileCheckEditMessageB( STRING s1 )
FORWARD INTEGER PROC FNFileCheckGotoEndB()
FORWARD INTEGER PROC FNFileCheckInsertLineAfterLineGotoBeginTextInsertB( STRING s1, INTEGER i1 )
FORWARD INTEGER PROC FNFileSaveCurrentToDirectoryRemoteGitVersionControlB( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5, STRING s6, INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNFileSetUploadGithubFileVersionControlB( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5, STRING s6, INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNKeyCheckPressEscapeB( STRING s1 )
FORWARD INTEGER PROC FNLineCheckGotoBeginB()
FORWARD INTEGER PROC FNLineCheckInsertAfterLineGotoBeginTextInsertB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckExecB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckLoadB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckPurgeB( STRING s1 )
FORWARD INTEGER PROC FNMathCheckGetLogicFalseB()
FORWARD INTEGER PROC FNMathCheckGetLogicTrueB()
FORWARD INTEGER PROC FNMathCheckLogicNotB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheckLogicOrB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathGetProgramLineNumberAbsoluteCurrentI()
FORWARD INTEGER PROC FNProgramGetOperatingSystemLinuxNonWslB()
FORWARD INTEGER PROC FNProgramGetOperatingSystemLinuxWslB()
FORWARD INTEGER PROC FNProgramGetOperatingSystemMicrosoftWindowsB()
FORWARD INTEGER PROC FNStringCheckEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEnvironmentFoundNotB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNStringCheckEqualCharacterLastNB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNStringCheckEqualErrorOrEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringGetLengthI( STRING s1 )
FORWARD INTEGER PROC FNTextCheckInsertB( STRING s1 )
FORWARD INTEGER PROC FNTextCheckInsertCentralB( STRING s1, INTEGER i1 )
FORWARD PROC Main()
FORWARD PROC PROCBrowserRunDefaultParameter( STRING s1 )
FORWARD PROC PROCError( STRING s1 )
FORWARD PROC PROCErrorFileNotFound( STRING s1 )
FORWARD PROC PROCFileGotoEnd()
FORWARD PROC PROCFileInsertEndPrepare()
FORWARD PROC PROCFileInsertTextEnd( STRING s1, STRING s2, INTEGER i1 )
FORWARD PROC PROCFileRun4NtAliasCommandListUser( STRING s1 )
FORWARD PROC PROCFileUpdateVersionControlGitSaveCreateCurrent( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5, STRING s6, INTEGER i1, INTEGER i2 )
FORWARD PROC PROCLineInsertAfter()
FORWARD PROC PROCLineInsertAfterLineGotoBeginTextInsert( STRING s1 )
FORWARD PROC PROCMacroExec( STRING s1 )
FORWARD PROC PROCMacroPurge( STRING s1 )
FORWARD PROC PROCMacroRunKeep( STRING s1 )
FORWARD PROC PROCMacroRunKeepParameter( STRING s1, STRING s2 )
FORWARD PROC PROCMacroRunPurge( STRING s1 )
FORWARD PROC PROCMacroRunPurgeParameter( STRING s1, STRING s2 )
FORWARD PROC PROCProgramRunInternetBrowserUrl( STRING s1 )
FORWARD PROC PROCTextGotoLineBegin()
FORWARD PROC PROCTextInsert( STRING s1 )
FORWARD PROC PROCTextRemovePositionStackPop()
FORWARD PROC PROCTextSavePositionStackPush()
FORWARD PROC PROCWarn( STRING s1 )
FORWARD PROC PROCWarnCons3( STRING s1, STRING s2, STRING s3 )
FORWARD PROC PROCWarnCons4( STRING s1, STRING s2, STRING s3, STRING s4 )
FORWARD PROC PROCWarnCons5( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5 )
FORWARD STRING PROC FNBlockGetRecordCurrentTseMacroVersionS()
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
FORWARD STRING PROC FNStringGetFileGetFilenamePathDefaultCrossPlatformS( STRING s1 )
FORWARD STRING PROC FNStringGetFileIniDefaultCrossPlatformS( STRING s1 )
FORWARD STRING PROC FNStringGetFileIniDefaultS( STRING s1 )
FORWARD STRING PROC FNStringGetFileUpdateVersionControlGitSaveCreateCurrentBrowserS()
FORWARD STRING PROC FNStringGetFilenameCurrentS()
FORWARD STRING PROC FNStringGetFilenameEndBackSlashNotEqualInsertEndS( STRING s1 )
FORWARD STRING PROC FNStringGetFilenameGlobalErrorS()
FORWARD STRING PROC FNStringGetFilenameIniDefaultCrossPlatformS()
FORWARD STRING PROC FNStringGetGlobalS( STRING s1 )
FORWARD STRING PROC FNStringGetInitializationGlobalS( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetInitializeNewStringS()
FORWARD STRING PROC FNStringGetLineNumberCurrentS()
FORWARD STRING PROC FNStringGetMachineNameS()
FORWARD STRING PROC FNStringGetMathIntegerToStringS( INTEGER i1 )
FORWARD STRING PROC FNStringGetMicrosoftWindowsToCrossPlatformS( STRING s1 )
FORWARD STRING PROC FNStringGetMicrosoftWindowsToLinuxNonWslFileNameS( STRING s1 )
FORWARD STRING PROC FNStringGetMicrosoftWindowsToLinuxWslFileNameS( STRING s1 )
FORWARD STRING PROC FNStringGetMidStringS( STRING s1, INTEGER i1, INTEGER i2 )
FORWARD STRING PROC FNStringGetOperatingSystemS()
FORWARD STRING PROC FNStringGetPathFileAliasUnicode4Dos4NtFilenameS()
FORWARD STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashNotS()
FORWARD STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashS()
FORWARD STRING PROC FNStringGetPortS()
FORWARD STRING PROC FNStringGetProgram4ntFilenameS()
FORWARD STRING PROC FNStringGetProgramRunPasswordFileVersionControlGithubKnudS()
FORWARD STRING PROC FNStringGetProgramRunUsernameFileVersionControlGithubKnudS()
FORWARD STRING PROC FNStringGetRightStringLengthEqualS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetRightStringS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetSectionSeparatorS()
FORWARD STRING PROC FNStringGetUserNameFirstS()
FORWARD STRING PROC FNStringGetUserNameLastS()
FORWARD STRING PROC FNStringGetUserNameLinuxNonWslS()
FORWARD STRING PROC FNStringGet_FilenameIniDefaultS()


// --- MAIN --- //

PROC Main()
 //
 STRING choiceS[255] = ""
 //
 STRING s[255] = ""
 //
 STRING s0[255] = SplitPath( CurrFileName(), _NAME_ | _EXT_ )
 //
 STRING s1[255] = "G:\VERSIONCONTROL\GIT\DDD01\" // optionally change this (this is the (GIT) directory where your (e.g. TSE) files are saved)
 //
 STRING s2[255] = "https://github.com/knudvaneeden/tse" // change this (this is the remote github repository)
 //
 STRING s3[255] = "g:\cygwin\bin\git.exe" // change this (this is the full path to your git executable)
 //
 // STRING s4[255] = "yourGithubUserName" // you *must* change this to your own GitHub username and recompile this TSE macro
 STRING s4[255] = FNStringGetProgramRunUsernameFileVersionControlGithubKnudS()
 //
 // STRING s5[255] = "yourGithubPassword" // you *must* change this to your own GitHub password and recompile this TSE macro
 STRING s5[255] = FNStringGetProgramRunPasswordFileVersionControlGithubKnudS()
 //
 STRING s6[255] = "recompile"
 //
 STRING s7[255] = "1" // // change this // If this is a "1" then B1 = true and upload to remote repository / if this is "0" then B1 = false and upload only to local repository
 //
 STRING s8[255] = "150" // change this
 //
 // STRING s9[255] = "0" // change this is true then run the browser with the remote repository. If false then do not run the browser with the remote repository.
 STRING s9[255] = FNStringGetFileUpdateVersionControlGitSaveCreateCurrentBrowserS() // change this is true then run the browser with the remote repository. If false then do not run the browser with the remote repository.
 //
 INTEGER bufferI = 0
 //
 PushPosition()
 PushBlock()
 s = " "
 IF LFind( Format( "(filenamemacro=", s0, ")" ), "gi" )
  PROCMacroRunPurge( "markpamd" ) // operation: select: mark: 1: paragraph: current: fix [kn, ri, we, 04-01-2023 15:41:30]
  s = FNBlockGetRecordCurrentTseMacroVersionS()
  IF NOT EquiStr( Trim( s ), "" )
   s = Format( " ", "(", s, ")", " " )
  ENDIF
 ENDIF
 // s6 = Format( "[", s0, "]", s, "recompile|draft|backup|works|created|add setm|replace menu hotkey|save|major|minor|compile|refactor|original" ) // old [kn, zoe, mo, 20-11-2000 14:31:57]
 // s6 = Format( "recompile|added|changed|error|warn|backup|created|works|replace menu hotkey|save|major|minor|compile|refactor|original|add setm" ) // old [kn, ri, su, 10-11-2024 15:49:05]
 // s6 = Format( "corrected:changed:added:recompile:backup:created:works:error:warn:replace menu hotkey:save:major:minor:compile:refactor:original:add setm" ) // new [kn, ri, su, 10-11-2024 15:53:57]
 // s6 = FNStringGetInitializationGitS() // new [kn, ri, th, 12-02-2026 19:27:06]
 s6 = "recompile"
 //
 PopBlock()
 PopPosition()
 //
 PushPosition()
 bufferI = CreateTempBuffer()
 PopPosition()
 //
 PushPosition()
 PushBlock()
 GotoBufferId( bufferI )
 //
 AddLine( s1 )
 AddLine( s2 )
 //
 PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
 GotoLine( 1 )
 IF List( "Choose an option", 80 )
  choiceS = Trim( GetText( 1, MAXSTRINGLEN ) )
 ELSE
  AbandonFile( bufferI )
  PopBlock()
  PopPosition()
  RETURN()
 ENDIF
 AbandonFile( bufferI )
 PopBlock()
 PopPosition()
 //
 IF ( EquiStr( choiceS, s2 ) ) AND ( EquiStr( "BIBTSE", SplitPath( CurrFilename(), _NAME_ ) ) )
  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
  Warn( "Do not upload your file", ":", " " , CurrFilename(), " ", "to the online repository", ":", " ", s1 )
  RETURN()
 ENDIF
 //
 IF ( EquiStr( choiceS, s2 ) )
  //
  s7 = "1"
  //
  ELSE
  //
  s7 = "0"
  //
 ENDIF
 //
// e.g   PushKey( <Home> )
 PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
 // IF ( NOT ( Ask( "file: save: version: control: git: revisionChangeInformationS = ", s6, _EDIT_HISTORY_ ) ) AND ( Length( s3 ) > 0 ) ) RETURN() ENDIF // old [kn, ri, fr, 17-05-2024 16:11:35]
 IF ( NOT ( Ask( Format( "[", s0, "]", s, "file: save: version: control: git: revisionChangeInformationS = " ), s6, _EDIT_HISTORY_ ) ) AND ( Length( s6 ) > 0 ) ) RETURN() ENDIF // new [kn, ri, fr, 17-05-2024 16:11:40]
 s6 = Format( "[", s0, "]", s, s6 ) // new [kn, ri, fr, 17-05-2024 16:11:15]
 s6 = StrReplace( '"', s6, "'", "" ) // make sure no double quotes are present as this overrules the outer double quote and will cause an 'svn out of date' error.
 //
 IF ( Length( s6 ) > Val( s8 ) )
  Warn( "Please choose the description string shorter." )
  RETURN()
 ENDIF
 //
 PROCFileUpdateVersionControlGitSaveCreateCurrent( s1, s2, s3, s4, s5, s6, Val( s7 ), Val( s9 ) ) // gives e.g. TRUE if successful
 //
 // Warn( "File", " ", CurrFilename(), " ", "is now saved in your local working directory", " ", s1, " ", "and committed as a next revision to your repository", " ", s2 )
 //
 // Message( Format( CurrFilename(), " ", "saved in time", " ", s + "-" + GetTimeStr() ) )
 //
END

<F12> Main()

// --- LIBRARY --- //

// library: string: get: program: run: username: file: version: control: github: knud <description></description> <version control></version control> <version>1.0.0.0.5</version> <version control></version control> (filenamemacro=getstgkp.s) [<Program>] [<Research>] [kn, ri, mo, 12-02-2018 17:42:32]
STRING PROC FNStringGetProgramRunUsernameFileVersionControlGithubKnudS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetProgramRunUsernameFileVersionControlGithubKnudS() ) // gives e.g. "<your GitHub user name>"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetProgramRunUsernameFileVersionControlGithubS" ) )
 //
END

// library: string: get: program: run: password: file: version: control: github: knud <description></description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getstgkq.s) [<Program>] [<Research>] [kn, ri, mo, 12-02-2018 17:43:12]
STRING PROC FNStringGetProgramRunPasswordFileVersionControlGithubKnudS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetProgramRunPasswordFileVersionControlGithubKnudS() ) // gives e.g. "<your GitHub password>"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetProgramRunPasswordFileVersionControlGithubS" ) )
 //
END

// library: string: get: file: update: version: control: git: save: create: current: browser <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstcbr.s) [<Program>] [<Research>] [kn, ri, fr, 20-03-2026 15:44:40]
STRING PROC FNStringGetFileUpdateVersionControlGitSaveCreateCurrentBrowserS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetFileUpdateVersionControlGitSaveCreateCurrentBrowserS() ) // gives e.g. "0" // does not run browser with remote online repository
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
 // e.g. // QuickHelp( HELPDEFFNStringGetFileUpdateVersionControlGitSaveCreateCurrentBrowserS( )
 // e.g. HELPDEF HELPDEFFNStringGetFileUpdateVersionControlGitSaveCreateCurrentBrowserS(
 // e.g.  title = "FNStringGetFileUpdateVersionControlGitSaveCreateCurrentBrowserS( help" // The help's caption
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
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetFileUpdateVersionControlGitSaveCreateCurrentBrowserS" ) )
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

// library: block: get: record: current: tse: macro: version <description></description> <version control></version control> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getblmve.s) [<Program>] [<Research>] [kn, ri, we, 04-01-2023 15:42:36]
STRING PROC FNBlockGetRecordCurrentTseMacroVersionS()
 // e.g. PROC Main()
 // e.g.  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
 // e.g.  Warn( FNBlockGetRecordCurrentTseMacroVersionS() ) // gives e.g. "1.0.0.3"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
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
 // e.g. // QuickHelp( HELPDEFFNStringGetRecordCurrentTseMacroVersionS )
 // e.g. HELPDEF HELPDEFFNStringGetRecordCurrentTseMacroVersionS
 // e.g.  title = "FNStringGetRecordCurrentTseMacroVersionS() help" // The help's caption
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
 STRING s[255] = ""
 //
 IF ( NOT ( IsBlockInCurrFile() ) ) Warn( "Please mark a block" ) RETURN( FNStringGetEmptyS()  ) ENDIF // return from the current procedure if no block is marked
 //
 PushPosition()
 PushBlock()
 //
 GotoBlockBegin()
 //
 IF LFind( "<version>{.*}</version>", "gilx" )
  //
  s = GetFoundText( 1 )
  //
 ENDIF
 //
 PopBlock()
 PopPosition()
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

// library: file: update: version: control: git: save: create: current <description></description> <version control></version control> <version>1.0.0.0.24</version> <version control></version control> (filenamemacro=updaficd.s) [<Program>] [<Research>] [kn, ri, th, 12-02-2026 18:53:49]
PROC PROCFileUpdateVersionControlGitSaveCreateCurrent( STRING yourLocalDirectoryS, STRING githubRemoteDirectoryUrlS, STRING fileNameExecutableGitS, STRING githubUserNameS, STRING githubPasswordS, STRING revisionChangeInformationS, INTEGER B1, INTEGER B2 )
 // e.g. PROC Main()
 // e.g.  //
 // e.g.  STRING choiceS[255] = ""
 // e.g.  //
 // e.g.  STRING s[255] = ""
 // e.g.  //
 // e.g.  STRING s0[255] = SplitPath( CurrFileName(), _NAME_ | _EXT_ )
 // e.g.  //
 // e.g.  STRING s1[255] = "G:\VERSIONCONTROL\GIT\DDD01\" // optionally change this (this is the (GIT) directory where your (e.g. TSE) files are saved)
 // e.g.  //
 // e.g.  STRING s2[255] = "https://github.com/knudvaneeden/tse" // change this (this is the remote github repository)
 // e.g.  //
 // e.g.  STRING s3[255] = "g:\cygwin\bin\git.exe" // change this (this is the full path to your git executable)
 // e.g.  //
 // e.g.  // STRING s4[255] = "yourGithubUserName" // you *must* change this to your own GitHub username and recompile this TSE macro
 // e.g.  STRING s4[255] = FNStringGetProgramRunUsernameFileVersionControlGithubKnudS()
 // e.g.  //
 // e.g.  // STRING s5[255] = "yourGithubPassword" // you *must* change this to your own GitHub password and recompile this TSE macro
 // e.g.  STRING s5[255] = FNStringGetProgramRunPasswordFileVersionControlGithubKnudS()
 // e.g.  //
 // e.g.  STRING s6[255] = "recompile"
 // e.g.  //
 // e.g.  STRING s7[255] = "1" // // change this // If this is a "1" then B1 = true and upload to remote repository / if this is "0" then B1 = false and upload only to local repository
 // e.g.  //
 // e.g.  STRING s8[255] = "150" // change this
 // e.g.  //
 // e.g.  // STRING s9[255] = "0" // change this is true then run the browser with the remote repository. If false then do not run the browser with the remote repository.
 // e.g.  STRING s9[255] = FNStringGetFileUpdateVersionControlGitSaveCreateCurrentBrowserS() // change this is true then run the browser with the remote repository. If false then do not run the browser with the remote repository.
 // e.g.  //
 // e.g.  INTEGER bufferI = 0
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  PushBlock()
 // e.g.  s = " "
 // e.g.  IF LFind( Format( "(filenamemacro=", s0, ")" ), "gi" )
 // e.g.   PROCMacroRunPurge( "markpamd" ) // operation: select: mark: 1: paragraph: current: fix [kn, ri, we, 04-01-2023 15:41:30]
 // e.g.   s = FNBlockGetRecordCurrentTseMacroVersionS()
 // e.g.   IF NOT EquiStr( Trim( s ), "" )
 // e.g.    s = Format( " ", "(", s, ")", " " )
 // e.g.   ENDIF
 // e.g.  ENDIF
 // e.g.  // s6 = Format( "[", s0, "]", s, "recompile|draft|backup|works|created|add setm|replace menu hotkey|save|major|minor|compile|refactor|original" ) // old [kn, zoe, mo, 20-11-2000 14:31:57]
 // e.g.  // s6 = Format( "recompile|added|changed|error|warn|backup|created|works|replace menu hotkey|save|major|minor|compile|refactor|original|add setm" ) // old [kn, ri, su, 10-11-2024 15:49:05]
 // e.g.  // s6 = Format( "corrected:changed:added:recompile:backup:created:works:error:warn:replace menu hotkey:save:major:minor:compile:refactor:original:add setm" ) // new [kn, ri, su, 10-11-2024 15:53:57]
 // e.g.  // s6 = FNStringGetInitializationGitS() // new [kn, ri, th, 12-02-2026 19:27:06]
 // e.g.  s6 = "recompile"
 // e.g.  //
 // e.g.  PopBlock()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  bufferI = CreateTempBuffer()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  PushBlock()
 // e.g.  GotoBufferId( bufferI )
 // e.g.  //
 // e.g.  AddLine( s1 )
 // e.g.  AddLine( s2 )
 // e.g.  //
 // e.g.  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
 // e.g.  GotoLine( 1 )
 // e.g.  IF List( "Choose an option", 80 )
 // e.g.   choiceS = Trim( GetText( 1, MAXSTRINGLEN ) )
 // e.g.  ELSE
 // e.g.   AbandonFile( bufferI )
 // e.g.   PopBlock()
 // e.g.   PopPosition()
 // e.g.   RETURN()
 // e.g.  ENDIF
 // e.g.  AbandonFile( bufferI )
 // e.g.  PopBlock()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  IF ( EquiStr( choiceS, s2 ) ) AND ( EquiStr( "BIBTSE", SplitPath( CurrFilename(), _NAME_ ) ) )
 // e.g.   PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
 // e.g.   Warn( "Do not upload your file", ":", " " , CurrFilename(), " ", "to the online repository", ":", " ", s1 )
 // e.g.   RETURN()
 // e.g.  ENDIF
 // e.g.  //
 // e.g.  IF ( EquiStr( choiceS, s2 ) )
 // e.g.   //
 // e.g.   s7 = "1"
 // e.g.   //
 // e.g.   ELSE
 // e.g.   //
 // e.g.   s7 = "0"
 // e.g.   //
 // e.g.  ENDIF
 // e.g.  //
 // e.g   PushKey( <Home> )
 // e.g.  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
 // e.g.  // IF ( NOT ( Ask( "file: save: version: control: git: revisionChangeInformationS = ", s6, _EDIT_HISTORY_ ) ) AND ( Length( s3 ) > 0 ) ) RETURN() ENDIF // old [kn, ri, fr, 17-05-2024 16:11:35]
 // e.g.  IF ( NOT ( Ask( Format( "[", s0, "]", s, "file: save: version: control: git: revisionChangeInformationS = " ), s6, _EDIT_HISTORY_ ) ) AND ( Length( s6 ) > 0 ) ) RETURN() ENDIF // new [kn, ri, fr, 17-05-2024 16:11:40]
 // e.g.  s6 = Format( "[", s0, "]", s, s6 ) // new [kn, ri, fr, 17-05-2024 16:11:15]
 // e.g.  s6 = StrReplace( '"', s6, "'", "" ) // make sure no double quotes are present as this overrules the outer double quote and will cause an 'svn out of date' error.
 // e.g.  //
 // e.g.  IF ( Length( s6 ) > Val( s8 ) )
 // e.g.   Warn( "Please choose the description string shorter." )
 // e.g.   RETURN()
 // e.g.  ENDIF
 // e.g.  //
 // e.g.  PROCFileUpdateVersionControlGitSaveCreateCurrent( s1, s2, s3, s4, s5, s6, Val( s7 ), Val( s9 ) ) // gives e.g. TRUE if successful
 // e.g.  //
 // e.g.  // Warn( "File", " ", CurrFilename(), " ", "is now saved in your local working directory", " ", s1, " ", "and committed as a next revision to your repository", " ", s2 )
 // e.g.  //
 // e.g.  // Message( Format( CurrFilename(), " ", "saved in time", " ", s + "-" + GetTimeStr() ) )
 // e.g.  //
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 FNFileSaveCurrentToDirectoryRemoteGitVersionControlB( yourLocalDirectoryS, githubRemoteDirectoryUrlS, fileNameExecutableGitS, githubUserNameS, githubPasswordS, revisionChangeInformationS, B1, B2 )
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

// library: file: save: current: to: directory: remote: git: version: control <description></description> <version control></version control> <version>1.0.0.0.16</version> <version control></version control> (filenamemacro=savefivd.s) [<Program>] [<Research>] [kn, ri, th, 12-02-2026 02:34:14]
INTEGER PROC FNFileSaveCurrentToDirectoryRemoteGitVersionControlB( STRING yourLocalDirectoryS,STRING githubRemoteDirectoryUrlS,STRING fileNameExecutableGitS,STRING githubUserNameS,STRING githubPasswordS,STRING revisionChangeInformationS,INTEGER B1,INTEGER B2 )
 // e.g. PROC Main()
 // e.g.  //
 // e.g.  STRING s1[255] = "G:\VERSIONCONTROL\GIT\DDD01\" // optionally change this (this is the (GIT) directory where your (e.g. TSE) files are saved)
 // e.g.  //
 // e.g.  STRING s2[255] = "https://github.com/knudvaneeden/tse" // change this (this is the remote github repository)
 // e.g.  //
 // e.g.  STRING s3[255] = "g:\cygwin\bin\git.exe" // change this (this is the full path to your git executable)
 // e.g.  //
 // e.g.  // STRING s4[255] = "yourGithubUserName" // you *must* change this to your own GitHub username and recompile this TSE macro
 // e.g.  STRING s4[255] = FNStringGetProgramRunUsernameFileVersionControlGithubKnudS()
 // e.g.  //
 // e.g.  // STRING s5[255] = "yourGithubPassword" // you *must* change this to your own GitHub password and recompile this TSE macro
 // e.g.  STRING s5[255] = FNStringGetProgramRunPasswordFileVersionControlGithubKnudS()
 // e.g.  //
 // e.g.  STRING s6[255] = "recompile"
 // e.g.  //
 // e.g.  STRING s7[255] = "1" // If this is a "1" then B1 = true and upload to remote repository / if this is "0" then B1 = false and upload only to local repository
 // e.g.  //
 // e.g.  // STRING s8[255] = "0" // change this is true then run the browser with the remote repository. If false then do not run the browser with the remote repository.
 // e.g.  STRING s8[255] = FNStringGetFileUpdateVersionControlGitSaveCreateCurrentBrowserS() // change this is true then run the browser with the remote repository. If false then do not run the browser with the remote repository.
 // e.g.  //
 // e.g.  IF ( NOT ( Ask( "file: set: upload: github: version: control: yourLocalDirectoryS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  //
 // e.g.  IF ( NOT ( Ask( "file: set: upload: github: version: control: githubRemoteDirectoryUrlS = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  //
 // e.g.  IF ( NOT ( Ask( "file: save: version: control: git: revisionChangeInformationS = ", s6, _EDIT_HISTORY_ ) ) AND ( Length( s6 ) > 0 ) ) RETURN() ENDIF
 // e.g.
 // e.g.  IF ( NOT ( Ask( "file: save: version: control: git: B1 = ", s7, _EDIT_HISTORY_ ) ) AND ( Length( s7 ) > 0 ) ) RETURN() ENDIF
 // e.g.  //
 // e.g.  Message( FNFileSaveCurrentToDirectoryRemoteGitVersionControlB( s1, s2, s3, s4, s5, s6, Val( s7 ), Val( s8 ) ) ) // gives e.g. TRUE if successful
 // e.g.  //
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // Use case = Upload your current file in TSE to your remote GitHub repository
 //
 //  Tested only for and only working with Cygwin git.exe + Cygwin bash.exe
 //
 //  Tested only with JPSoft tcc.exe
 //
 // ===
 //
 // Method = Create a .bat file containing the necessary GIT commands, then running that .bat file
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
 // e.g. // QuickHelp( HELPDEFFNFileSaveCurrentToDirectoryLocalGitVersionControlB )
 // e.g. HELPDEF HELPDEFFNFileSaveCurrentToDirectoryLocalGitVersionControlB
 // e.g.  title = "FNFileSaveCurrentToDirectoryLocalGitVersionControlB( s1, s2, s3, s4, s5, s6 ) help" // The help's caption
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
 STRING fileNameCurrentS[255] = CurrFilename()
 //
 STRING fileNameS[255] = Format( AddTrailingSlash( yourLocalDirectoryS ), SplitPath( fileNameCurrentS, _NAME_ | _EXT_ ) )
 //
 PushPosition()
 PushBlock()
 //
 EditFile( fileNameCurrentS )
 //
 B = SaveAs( fileNameS, _OVERWRITE_ )
 IF ( NOT ( B ) )
  Warn( "Could not overwrite the file", ":", " ", fileNameS, " ", "in the local GitHub directory. Please check." )
  B = FALSE
  PopBlock()
  PopPosition()
  RETURN( B )
 ENDIF
 //
 B = FNFileSetUploadGithubFileVersionControlB( yourLocalDirectoryS, githubRemoteDirectoryUrlS, fileNameExecutableGitS, githubUserNameS, githubPasswordS, revisionChangeInformationS, B1, B2 )
 IF ( NOT ( B ) )
  Warn( "Could not upload the current file from your local directory", ":", " ", yourLocalDirectoryS, " ", ". Please check." )
  B = FALSE
  PopBlock()
  PopPosition()
  RETURN( B )
 ENDIF
 //
 B = TRUE
 //
 PopBlock()
 PopPosition()
 //
 RETURN( B )
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

// library: file: set: upload: github: file: version: control <description></description> <version control></version control> <version>1.0.0.0.46</version> <version control></version control> (filenamemacro=setfivco.s) [<Program>] [<Research>] [kn, ri, fr, 09-02-2018 01:56:32]
INTEGER PROC FNFileSetUploadGithubFileVersionControlB( STRING yourLocalDirectoryS, STRING githubRemoteDirectoryUrlS, STRING fileNameExecutableGitS, STRING githubUserNameS, STRING githubPasswordS, STRING revisionChangeInformationS, INTEGER B1, INTEGER B2 )
 // e.g. PROC Main()
 // e.g.  //
 // e.g.  STRING s1[255] = "G:\VERSIONCONTROL\GIT\DDD01\" // change this (this is the (GIT) directory where your files are saved)
 // e.g.  //
 // e.g.  STRING s2[255] = "https://github.com/knudvaneeden/tse" // change this (this is the remote github repository)
 // e.g.  //
 // e.g.  STRING s3[255] = "g:\cygwin\bin\git.exe" // change this (this is the full path to your git executable)
 // e.g.  //
 // e.g.  STRING s4[255] = FNStringGetProgramRunUsernameFileVersionControlGithubKnudS()
 // e.g.  // STRING s4[255] = "yourGithubUserName" // you *must* change this to your own GitHub username and recompile this TSE macro
 // e.g.  //
 // e.g.  STRING s5[255] = FNStringGetProgramRunPasswordFileVersionControlGithubKnudS()
 // e.g.  // STRING s5[255] = "yourGithubPassword" // you *must* change this to your own GitHub password and recompile this TSE macro
 // e.g.  //
 // e.g.  // STRING revisionInformationS[255] = Format( '"', "Last commit", ":", " ", GetDateStr(), " ", GetTimeStr(), '"' )
 // e.g.  STRING s6[255] = "recompile"
 // e.g.  //
 // e.g.  STRING s7[255] = "1" // If this is a "1" then B1 = true and upload to remote repository / if this is "0" then B1 = false and upload only to local repository
 // e.g.  //
 // e.g.  // STRING s8[255] = "0" // change this is true then run the browser with the remote repository. If false then do not run the browser with the remote repository.
 // e.g.  STRING s8[255] = FNStringGetFileUpdateVersionControlGitSaveCreateCurrentBrowserS() // change this is true then run the browser with the remote repository. If false then do not run the browser with the remote repository.
 // e.g.  //
 // e.g.  //
 // e.g.  IF ( NOT ( Ask( "file: set: upload: github: version: control: yourLocalDirectoryS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  //
 // e.g.  IF ( NOT ( Ask( "file: set: upload: github: version: control: githubRemoteDirectoryUrlS = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  //
 // e.g.  IF ( NOT ( Ask( "file: save: version: control: git: revisionChangeInformationS = ", s6, _EDIT_HISTORY_ ) ) AND ( Length( s6 ) > 0 ) ) RETURN() ENDIF
 // e.g.  //
 // e.g.  IF ( NOT ( Ask( "file: save: version: control: git: B1 = ", s7, _EDIT_HISTORY_ ) ) AND ( Length( s7 ) > 0 ) ) RETURN() ENDIF
 // e.g.  //
 // e.g.  Message( FNFileSetUploadGithubFileVersionControlB( s1, s2, s3, s4, s5, s6, Val( s7 ), Val( s8 ) ) ) // gives e.g. TRUE if successful
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER B = FALSE
 //
 STRING fileNameS[255] = "c:\temp\ddd.bat" // change this // temporary batch file
 //
 IF EditFile( fileNameS )
  AbandonFile()
 ENDIF
 EraseDiskFile( fileNameS )
 //
 EditFile( fileNameS )
 //
 AddLine( "@echo off" )
 AddLine( "setlocal EnableExtensions" )
 AddLine( "" )
 AddLine( "REM --- Use Cygwin bash to run git (avoids Cygwin shared library errors under TCC) ---" )
 AddLine( Format( 'set "CYG_GIT=', fileNameExecutableGitS, '"' ) )
 AddLine( 'if not defined CYG_GIT ( set "CYG_GIT=g:\cygwin\bin\git.exe" )' )
 AddLine( 'set "BASH_CMD=%CYG_GIT:\bin\git.exe=\bin\bash.exe%"' )
 AddLine( 'if not exist "%BASH_CMD%" (' )
 AddLine( '  echo ERROR: Cygwin bash.exe not found: %BASH_CMD%' )
 AddLine( '  echo Check your Cygwin install path.' )
 AddLine( '  pause' )
 AddLine( '  exit /b 1' )
 AddLine( ')' )
 AddLine( "" )
 AddLine( "REM --- Commit message ---" )
 AddLine( Format( 'set "WIN_DIR=', yourLocalDirectoryS, '"' ) )
 AddLine( Format( 'set "COMMIT_MSG=', revisionChangeInformationS, '"' ) )
 AddLine( 'if "%COMMIT_MSG%"=="" set COMMIT_MSG=tse_autocommit_%DATE%_%TIME%' )
 AddLine( "" )
 //
 IF ( B1 )
  AddLine( "REM --- GitHub authentication (PAT) ---" )
  AddLine( Format( 'set "GITHUB_USER=', githubUserNameS, '"' ) )
  AddLine( Format( 'set "GITHUB_PAT=', githubPasswordS, '"' ) ) // githubPasswordS is expected to be a GitHub PAT (Personal Access Token)
  AddLine( Format( 'set "GITHUB_REMOTE=', githubRemoteDirectoryUrlS, '"' ) )
  AddLine( "" )
  AddLine( "if not defined GITHUB_PAT (" )
  AddLine( "  echo ERROR: GITHUB_PAT is empty. Set it in your TSE ini and try again." )
  AddLine( "  pause" )
  AddLine( "  exit /b 1" )
  AddLine( ")" )
  AddLine( "" )
  AddLine( "REM --- Run all git commands inside bash (Cygwin) ---" )
  AddLine( 'REM --- Run git via bash with cmd line-continuations (avoid AddLine length limit) ---' )
  AddLine( '"%BASH_CMD%" --login -c "cd $(cygpath -u $WIN_DIR) && ^' )
  AddLine( 'COMMIT_MSG=${COMMIT_MSG//\//-}; COMMIT_MSG=${COMMIT_MSG//:/}; COMMIT_MSG=${COMMIT_MSG// /_}; ^' )
  AddLine( "COMMIT_MSG=$(echo $COMMIT_MSG | tr -d '\\042'); ^" )
  AddLine( 'git rev-parse --git-dir >/dev/null 2>&1 || git init .; ^' )
  AddLine( 'git add .; ^' )
  AddLine( 'git commit -m $COMMIT_MSG >/dev/null 2>&1 || true; ^' )
  AddLine( 'git branch -M main; ^' )
  AddLine( 'git remote get-url origin >/dev/null 2>&1 || git remote add origin $GITHUB_REMOTE; ^' )
  AddLine( 'REMOTE_NOAUTH=${GITHUB_REMOTE#https://}; ^' )
  AddLine( 'case $REMOTE_NOAUTH in *.git) ;; *) REMOTE_NOAUTH=$REMOTE_NOAUTH.git ;; esac; ^' )
  AddLine( 'git remote set-url origin https://$GITHUB_USER:$GITHUB_PAT@$REMOTE_NOAUTH; ^' )
  AddLine( 'UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true); ^' )
  AddLine( 'if [ -n $UPSTREAM ]; then PUSH_REMOTE=$(echo $UPSTREAM | cut -d/ -f1); PUSH_BRANCH=$(echo $UPSTREAM | cut -d/ -f2-); else PUSH_REMOTE=origin; PUSH_BRANCH=main; fi; ^' )
  AddLine( 'git push -u $PUSH_REMOTE HEAD:$PUSH_BRANCH; ^' )
  AddLine( 'git remote set-url origin $GITHUB_REMOTE"' )
 ELSE
  AddLine( "REM --- Local-only: commit to local repository (no remote push) ---" )
  AddLine( 'REM --- Run git via bash with cmd line-continuations (avoid AddLine length limit) ---' )
  AddLine( '"%BASH_CMD%" --login -c "cd $(cygpath -u $WIN_DIR) && ^' )
  AddLine( 'COMMIT_MSG=${COMMIT_MSG//\//-}; COMMIT_MSG=${COMMIT_MSG//:/}; COMMIT_MSG=${COMMIT_MSG// /_}; ^' )
  AddLine( "COMMIT_MSG=$(echo $COMMIT_MSG | tr -d '\\042'); ^" )
  AddLine( 'git rev-parse --git-dir >/dev/null 2>&1 || git init .; ^' )
  AddLine( 'git add .; ^' )
  AddLine( 'git commit -m $COMMIT_MSG >/dev/null 2>&1 || true; ^' )
  AddLine( 'git branch -M main"' )
 ENDIF
 //
 AddLine( "" )
 // AddLine( "pause" )
 //
 SaveAs( fileNameS, _OVERWRITE_ )
 //
 // LDos( fileNameExecutableTccS, fileNameS )
 PROCFileRun4NtAliasCommandListUser( fileNameS ) // run this batch file using tcc.exe
 //
 // StartPgm( githubRemoteDirectoryUrlS )
 IF ( B1 )
  IF ( B2 )
   PROCProgramRunInternetBrowserUrl( githubRemoteDirectoryUrlS )
  ENDIF
 ENDIF
 //
 // clean up the .bat file
 //
 IF EditFile( fileNameS )
  //
  AbandonFile()
  //
 ENDIF
 //
 B = TRUE
 //
 RETURN( B )
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

// library: file: run: 4: nt: alias: command: list: user <description></description> <version control></version control> <version>1.0.0.0.209</version> (filenamemacro=run4fira.s) [<Program>] [<Research>] [kn, ri, su, 01-03-2009 15:29:03]
PROC PROCFileRun4NtAliasCommandListUser( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  INTEGER bufferI = 0
 // e.g.  INTEGER I = 0
 // e.g.  STRING fileNameS[255] = FNStringGetProgramAliasRunFilenameListS() // casealiasinputlist.txt
 // e.g.  PushPosition()
 // e.g.  bufferI = CreateTempBuffer()
 // e.g.  GotoBufferId( bufferI )
 // e.g.  InsertFile( fileNameS )
 // e.g.  // I = List( "alias command", 115 - 21 )
 // e.g.  I = List( "FILE: RUN: 4NT: ALIAS: COMMAND: LIST: USER", FNWindowGetScreenWidthI() )
 // e.g.  IF ( NOT ( I == 0 ) )
 // e.g.   s1 = SubStr( GetText( 1, MAXSTRINGLEN ), 1, 188 - 1 )
 // e.g.   s1 = Trim( s1 )
 // e.g.   // combobox (but switched off as this is quicker)
 // e.g.   // s1 = FNStringGetInputS( "file: run: 4nt: alias: s = ", s1 )
 // e.g.   IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.   PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
 // e.g.   s1 = FNStringGetTagAngularRemoveWhileS( s1, "Please replace it by information to apply" )
 // e.g.   // do not move the runprmcn line, as it seems to work better [kn, vo, mo, 13-04-2015 19:57:52]
 // e.g.   PROCMacroRunPurgeParameter( "runprmcn", Format( FNStringGetMachineNameS(), ";", FNStringGetUserNameFirstS(), ";", FNStringGetUserNameLastS(), ";", FNStringGetPortS(), ";", "Run%3A+Alias%3A+" + s1 + "&submit01=Create" ) )
 // e.g.   PROCFileRun4NtAliasCommandListUser( s1 )
 // e.g.  ENDIF
 // e.g.  PopPosition()
 // e.g.  PushPosition()
 // e.g.  GotoBufferId( bufferI )
 // e.g.  AbandonFile( bufferI )
 // e.g.  PopPosition()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 // e.g. <CTRL L> RepeatFind()
 //
 // PROCFileChangeEditProgramRunStringAdd( "run", "", Format( "(program: 4nt: alias: general:", " ", s, ")" ) )
 //
 // LDos( QuotePath( FNStringGetProgram4ntFilenameS() ), Format( "alias", " ", FNStringGetPathFileAlias4Dos4NtFilenameS(), " ", "&&", " ", s, " ", "&& exit && exit" ), _DONT_PROMPT_ )
 // LDos( FNStringGetProgram4ntFilenameS(), Format( "alias", " ", FNStringGetPathFileAlias4Dos4NtFilenameS(), " ", "&&", " ", s, " ", "&& exit && exit" ), _DONT_PROMPT_ )
 // LDos( FNStringGetProgram4ntFilenameS(), Format( "alias", " ", FNStringGetPathFileAlias4Dos4NtFilenameS(), " ", "&&", " ", s, " ", "&& exit" ), _DONT_PROMPT_ )
 // LDos( FNStringGetProgram4ntFilenameS(), Format( "alias", " ", "/L", " ", "&&", " ", "alias", " ", FNStringGetPathFileAlias4Dos4NtFilenameS(), " ", "&&", " ", s, " ", "&& exit" ), _DONT_PROMPT_ )
 // LDos( FNStringGetProgram4ntFilenameS(), Format( "alias", " ", FNStringGetPathFileAlias4Dos4NtFilenameS(), " ", "&&", " ", s, " ", "&& exit" ), _DONT_PROMPT_ ) // old [kn, ri, su, 25-12-2016 02:18:29]
 // LDos( FNStringGetProgram4ntFilenameS(), Format( "alias", " ", FNStringGetPathFileAliasUnicode4Dos4NtFilenameS(), " ", "&&", " ", s, " ", "&& exit" ), _DONT_PROMPT_ ) // new [kn, ri, su, 25-12-2016 02:18:43] // old
 //
 // This works: LDos( "/mnt/g/utils/jpsoft/tcmd/tcc.exe", Format( '"', "alias      /L & alias /R /Z f:\\4dos\\alias\\dell\\latitudee6530\\aliasUnicode.dok & ad & exit", '"' ), _DONT_PROMPT_ )
 //
 // old: LDos( FNStringGetProgram4ntFilenameS(), Format( "alias", " ", FNStringGetPathFileAliasUnicode4Dos4NtFilenameS(), " ", "&&", " ", s, " ", "&& exit" ), _DONT_PROMPT_ ) // new [kn, ri, su, 25-12-2016 02:18:43]
 //
 LDos( FNStringGetProgram4ntFilenameS(), Format( '"', "alias", " ", FNStringGetPathFileAliasUnicode4Dos4NtFilenameS(), " ", "&&", " ", s, " ", "&& exit", '"' ), _DONT_PROMPT_ ) // new [kn, ri, su, 25-12-2016 02:18:43] // new [kn, ri, tu, 06-01-2026 00:31:11]
 //
 // PROCListSaveHistoryUser( s ) // old [kn, ri, su, 10-06-2012 13:44:33]
 //
 Message( Format( s, " ", ": file: run: 4nt/4dos: alias: command: list: user" ) )
 //
 // do not enable this runprmcn line, as it is run in the run part of this macro [kn, vo, mo, 13-04-2015 19:57:46]
 // PROCMacroRunPurgeParameter( "runprmcn", Format( FNStringGetMachineNameS(), ";", FNStringGetUserNameFirstS(), ";", FNStringGetUserNameLastS(), ";", FNStringGetPortS(), ";", "Run%3A+Alias%3A+" + s + "&submit01=Create" ) )
 //
END

// library: program: run: internet: browser: email: knud <description></description> <version control></version control> <version>1.0.0.0.8</version> (filenamemacro=runprekn.s) [<Program>] [<Research>] [kn, am, we, 06-05-2009 15:12:57]
PROC PROCProgramRunInternetBrowserUrl( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCProgramRunInternetBrowserUrl( "http://mail.yahoo.com" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCBrowserRunDefaultParameter( s )
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

// library: string: get: program4nt <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=getstgps.s) [<Program>] [<Research>] [kn, am, we, 29-04-2009 18:53:22]
STRING PROC FNStringGetProgram4ntFilenameS()
 // e.g. PROC Main()
 // e.g.  Warn( FNStringGetProgram4ntFilenameS() ) // gives e.g. "f:\4dos\4nt.exe" (or "/mnt/f/4dos/4nt.exe" on TSE for Linux)
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = ""
 //
 s = FNStringGetFileIniDefaultS( "ProgramName4DosS" )
 //
 s = FNStringGetMicrosoftWindowsToCrossPlatformS( s )
 //
 RETURN( s )
 //
END

// library: string: get: path: file: alias: unicode4: dos4: nt: filename <description></description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getstnfj.s) [<Program>] [<Research>] [kn, ri, su, 25-12-2016 02:20:20]
STRING PROC FNStringGetPathFileAliasUnicode4Dos4NtFilenameS()
 // e.g. PROC Main()
 // e.g.  IF ( FNMathGetNumberInputYesNoCancelPositionDefaultI( Format( "Alias command (should be similar to computer name)", " ", "=", " ", FNStringGetPathFileAliasUnicode4Dos4NtFilenameS() ) ) == 1 ) // gives e.g. "c:\4dos\aliasUnicode.dok"
 // e.g.  ENDIF
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // do not add this, it becomes too slow [kn, ri, sa, 09-02-2013 01:49:15]
 // PROCMacroRunPurgeParameter( "runprmcn", Format( FNStringGetMachineNameS(), ";", FNStringGetUserNameFirstS(), ";", FNStringGetUserNameLastS(), ";", FNStringGetPortS(), ";", "TSE%3A+String%3A+Get%3A" + "FNStringGetPathFileAlias4Dos4NtS" + "&submit01=Create" ) )
 //
 STRING s[255] = ""
 //
 s = FNStringGetFileIniDefaultS( "FNStringGetPathFileAliasUnicode4Dos4NtS" )
 //
 // do not use this: s = FNStringGetMicrosoftWindowsToCrossPlatformS( s ) // [kn, ri, tu, 06-01-2026 00:09:54]
 //
 RETURN( s )
 //
END

// library: browser: run: default: parameter <description></description> <version control></version control> <version>1.0.0.0.10</version> (filenamemacro=runbrdpa.s) [<Program>] [<Research>] [kn, ri, tu, 20-03-2001 19:10:11]
PROC PROCBrowserRunDefaultParameter( STRING parameterS )
 // e.g. PROC Main()
 // e.g.  PROCBrowserRunDefaultParameter( "http://www.google.com/search?hl=en&q=test" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // PROCBrowserRunMicrosoftExplorer( parameterS ) // [kn, ri, mo, 01-06-2009 14:31:52]
 //
 // PROCMacroRunPurgeParameter( "runbrmpa", parameterS ) // run default browser macro with that parameter // old [kn, ri, sa, 08-12-2012 14:47:17]
 PROCMacroRunKeepParameter( "runbrmpa", parameterS ) // run default browser macro with that parameter // new [kn, ri, sa, 08-12-2012 14:47:21]
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

// library: string: get: microsoft: windows: to: cross: platform <description></description> <version control></version control> <version>1.0.0.0.11</version> <version control></version control> (filenamemacro=getstcpl.s) [<Program>] [<Research>] [kn, ri, we, 15-10-2025 20:04:19]
STRING PROC FNStringGetMicrosoftWindowsToCrossPlatformS( STRING fileNameInS )
 // e.g. PROC Main()
 // e.g.  // STRING s1[255] = GetHistoryStr( _EDIT_HISTORY_, 1 ) // change this
 // e.g.  STRING s1[255] = "c:\temp\ddd.s" // change this
 // e.g.  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
 // e.g.  IF ( NOT ( Ask( "fileNameInS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Warn( FNStringGetMicrosoftWindowsToCrossPlatformS( s1 ) ) // gives e.g. "/mnt/c/temp/ddd.s" // when run on Linux WSL
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
 // e.g. // QuickHelp( HELPDEFFNStringGetMicrosoftWindowsToCrossPlatformS )
 // e.g. HELPDEF HELPDEFFNStringGetMicrosoftWindowsToCrossPlatformS
 // e.g.  title = "FNStringGetMicrosoftWindowsToCrossPlatformS( s1 ) help" // The help's caption
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
 STRING fileNameS[255] = ""
 //
 IF FNProgramGetOperatingSystemLinuxNonWslB()
  //
  fileNameS = FNStringGetMicrosoftWindowsToLinuxNonWslFileNameS( fileNameInS )
  //
 ELSEIF FNProgramGetOperatingSystemLinuxWslB()
  //
  fileNameS = FNStringGetMicrosoftWindowsToLinuxWslFileNameS( fileNameInS )
  //
 ELSEIF FNProgramGetOperatingSystemMicrosoftWindowsB()
  //
  fileNameS = fileNameInS
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

// library: macro: run: keep: parameter <description>macro: run a macro, then keep it, pass parameter string</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=runmakpa.s) [<Program>] [<Research>] [[kn, ri, su, 17-02-2002 16:07:46]
PROC PROCMacroRunKeepParameter( STRING macronameS, STRING commandlineparameterS )
 // e.g. PROC Main()
 // e.g.  PROCMacroRunKeepParameter( macronameS, commandlineparameterS )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCMacroRunKeep( FNStringGetConsS( macronameS, commandlineparameterS ) )
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

// library: string: get: microsoft: windows: to: linux: non: wsl: file: name <description></description> <version control></version control> <version>1.0.0.0.5</version> <version control></version control> (filenamemacro=getstfnl.s) [<Program>] [<Research>] [kn, ri, we, 15-10-2025 19:50:32]
STRING PROC FNStringGetMicrosoftWindowsToLinuxNonWslFileNameS( STRING fileNameS )
 // e.g. PROC Main()
 // e.g.  // Define a string array with a default Microsoft Windows path, adjust as necessary.
 // e.g.  // STRING s1[255] = "f:\wordproc\tse_linux\" // change this // Parameter: fileNameS - The original Microsoft Windows file path as a string.
 // e.g.  STRING s1[255] = "c:\temp\tse_linux\tse\ddd.s"
 // e.g.  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
 // e.g.  // Prompt the user to input a file path, with edit history enabled.
 // e.g.  // Checks if user cancelled the prompt (input is empty) and returns if true.
 // e.g.  IF ( NOT ( Ask( "string: get: microsoft: windows: to: linux: non: wsl: file: name: fileNameS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  // Convert the Microsoft Windows path to a Linux WSL path.
 // e.g.  s1 = FNStringGetMicrosoftWindowsToLinuxNonWslFileNameS( s1 ) // gives e.g. "/home/knudvaneeden/c/temp/ddd.s"
 // e.g.  // Display a message that the path has been converted and copied to the clipboard.
 // e.g.  // Message( "cd", " ", s1, " ", "has been copied to the Microsoft Windows ClipBoard" )
 // e.g.  Warn( s1, " ", "has been copied to the Microsoft Windows ClipBoard" )
 // e.g.  // Copy the Linux path command to the Microsoft Windows clipboard.
 // e.g.  // CopyToWinClip( Format( "cd", " ", s1 ) )
 // e.g.  CopyToWinClip( Format( s1 ) )
 // e.g. END
 // e.g.
 // e.g. <Ctrl F12> Main()
 //
 // ===
 //
 // Use case = Converts a Microsoft Windows file path to a Linux non-WSL file path
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
 // e.g. // QuickHelp( HELPDEFFNStringGetMicrosoftWindowsToLinuxNonWslFileNameS )
 // e.g. HELPDEF HELPDEFFNStringGetMicrosoftWindowsToLinuxNonWslFileNameS
 // e.g.  title = "FNStringGetMicrosoftWindowsToLinuxNonWslFileNameS( s1 ) help" // The help's caption
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
 // Declare a local string array of size 255, initially empty.
 STRING s[255] = ""
 //
 // Assign the input file name to local variable s.
 s = fileNameS
 //
 // Assign the input file name to local variable s.
 s = StrReplace( "\", s, "/", "" )
 //
 // Prefix the path with '/mnt/' which is a typical mount point for WSL.
 s = Format( "/home/", FNStringGetUserNameLinuxNonWslS(), "/", s )
 //
 // Remove colon characters from the path, e.g. from the drive letter 'c:' as these are not used in Linux file paths.
 s = StrReplace( ":", s, "", "" )
 //
 // Return the converted path
 //
 RETURN( s )
 //
END

// library: string: get: microsoft: windows: to: linux: wsl: file: name <description></description> <version control></version control> <version>1.0.0.0.64</version> <version control></version control> (filenamemacro=getstfnk.s) [<Program>] [<Research>] [kn, ri, mo, 15-04-2024 20:14:25]
STRING PROC FNStringGetMicrosoftWindowsToLinuxWslFileNameS( STRING fileNameS )
 // e.g. PROC Main()
 // e.g.  // Define a string array with a default Microsoft Windows path, adjust as necessary.
 // e.g.  // STRING s1[255] = "f:\wordproc\tse_linux\" // change this // Parameter: fileNameS - The original Microsoft Windows file path as a string.
 // e.g.  STRING s1[255] = "c:\temp\tse_linux\tse\ddd.s"
 // e.g.  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
 // e.g.  // Prompt the user to input a file path, with edit history enabled.
 // e.g.  // Checks if user cancelled the prompt (input is empty) and returns if true.
 // e.g.  IF ( NOT ( Ask( "string: get: microsoft: windows: to: linux: wsl: file: name: fileNameS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  // Convert the Microsoft Windows path to a Linux WSL path.
 // e.g.  s1 = FNStringGetMicrosoftWindowsToLinuxWslFileNameS( s1 ) // gives e.g. "/mnt/c/temp/ddd.s"
 // e.g.  // Display a message that the path has been converted and copied to the clipboard.
 // e.g.  // Message( "cd", " ", s1, " ", "has been copied to the Microsoft Windows ClipBoard" )
 // e.g.  Warn( s1, " ", "has been copied to the Microsoft Windows ClipBoard" )
 // e.g.  // Copy the Linux path command to the Microsoft Windows clipboard.
 // e.g.  // CopyToWinClip( Format( "cd", " ", s1 ) )
 // e.g.  CopyToWinClip( Format( s1 ) )
 // e.g. END
 // e.g.
 // e.g. <Ctrl F12> Main()
 //
 // ===
 //
 // Use case = Converts a Microsoft Windows file path to a Linux WSL file path
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
 // e.g. // QuickHelp( HELPDEFFNStringGetMicrosoftWindowsToLinuxWslFileNameS )
 // e.g. HELPDEF HELPDEFFNStringGetMicrosoftWindowsToLinuxWslFileNameS
 // e.g.  title = "FNStringGetMicrosoftWindowsToLinuxWslFileNameS( s1 ) help" // The help's caption
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
 // Declare a local string array of size 255, initially empty.
 STRING s[255] = ""
 //
 // Assign the input file name to local variable s.
 s = fileNameS
 //
 // Assign the input file name to local variable s.
 s = StrReplace( "\", s, "/", "" )
 //
 // Prefix the path with '/mnt/' which is a typical mount point for WSL.
 s = Format( "/mnt/", s )
 //
 // Remove colon characters from the path, e.g. from the drive letter 'c:' as these are not used in Linux file paths.
 s = StrReplace( ":", s, "", "" )
 //
 // Return the converted path
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

// library: string: get: user: name: linux: non: wsl <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstnws.s) [<Program>] [<Research>] [kn, ri, fr, 17-10-2025 12:42:37]
STRING PROC FNStringGetUserNameLinuxNonWslS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetUserNameLinuxNonWslS() ) // gives e.g. "knudvaneeden"
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
 // e.g. // QuickHelp( HELPDEFFNStringGetUserNameLinuxNonWslS )
 // e.g. HELPDEF HELPDEFFNStringGetUserNameLinuxNonWslS
 // e.g.  title = "FNStringGetUserNameLinuxNonWslS() help" // The help's caption
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
 RETURN( FNStringGetFileIniDefaultS( "FNStringGetUserNameLinuxNonWslS" ) )
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

// library: string: get: mid: string <description></description> <version control>string: get: word: token: middle: return a given integer amount of characters from a given startposition</version control> <version>1.0.0.0.9</version> (=MID$ in BASIC) <version>1.0.0.0.9</version> (filenamemacro=getstmid.s) [<Program>] [<Research>] [kn, ri, tu, 13-10-1998 20:29:00]
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
