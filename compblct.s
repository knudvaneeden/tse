FORWARD INTEGER PROC FNErrorCheckSB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckExecB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckLoadB( STRING s1 )
FORWARD INTEGER PROC FNMathCheckGetLogicFalseB()
FORWARD INTEGER PROC FNMathCheckGetLogicTrueB()
FORWARD INTEGER PROC FNMathCheckLogicNotB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheckLogicOrB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNProgramGetOperatingSystemLinuxNonWslB()
FORWARD INTEGER PROC FNProgramGetOperatingSystemLinuxWslB()
FORWARD INTEGER PROC FNProgramGetOperatingSystemMicrosoftWindowsB()
FORWARD INTEGER PROC FNStringCheckEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEnvironmentFoundNotB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNStringCheckEqualCharacterLastNB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNStringCheckEqualErrorOrEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringGetLengthI( STRING s1 )
FORWARD PROC Main()
FORWARD PROC PROCBlockCompareTwo()
FORWARD PROC PROCFileRun4NtAliasCommandListUser( STRING s1 )
FORWARD PROC PROCMacroExec( STRING s1 )
FORWARD PROC PROCMacroRunKeep( STRING s1 )
FORWARD PROC PROCWarn( STRING s1 )
FORWARD PROC PROCWarnCons3( STRING s1, STRING s2, STRING s3 )
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
FORWARD STRING PROC FNStringGetConsS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetEmptyS()
FORWARD STRING PROC FNStringGetEnvironmentS( STRING s1 )
FORWARD STRING PROC FNStringGetErrorS()
FORWARD STRING PROC FNStringGetFileGetFilenamePathDefaultCrossPlatformS( STRING s1 )
FORWARD STRING PROC FNStringGetFileIniDefaultCrossPlatformS( STRING s1 )
FORWARD STRING PROC FNStringGetFileIniDefaultS( STRING s1 )
FORWARD STRING PROC FNStringGetFilenameEndBackSlashNotEqualInsertEndS( STRING s1 )
FORWARD STRING PROC FNStringGetFilenameIniDefaultCrossPlatformS()
FORWARD STRING PROC FNStringGetInitializationGlobalS( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetMicrosoftWindowsToCrossPlatformS( STRING s1 )
FORWARD STRING PROC FNStringGetMicrosoftWindowsToLinuxNonWslFileNameS( STRING s1 )
FORWARD STRING PROC FNStringGetMicrosoftWindowsToLinuxWslFileNameS( STRING s1 )
FORWARD STRING PROC FNStringGetMidStringS( STRING s1, INTEGER i1, INTEGER i2 )
FORWARD STRING PROC FNStringGetOperatingSystemS()
FORWARD STRING PROC FNStringGetPathFileAliasUnicode4Dos4NtFilenameS()
FORWARD STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashNotS()
FORWARD STRING PROC FNStringGetPathUser_DataApplicationCurrentBackslashS()
FORWARD STRING PROC FNStringGetProgram4ntFilenameS()
FORWARD STRING PROC FNStringGetRightStringLengthEqualS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetRightStringS( STRING s1, INTEGER i1 )
FORWARD STRING PROC FNStringGetSectionSeparatorS()
FORWARD STRING PROC FNStringGetUserNameLinuxNonWslS()
FORWARD STRING PROC FNStringGet_FilenameIniDefaultS()


// --- MAIN --- //

PROC Main()
 PROCBlockCompareTwo()
END

<F12> Main()

// --- LIBRARY --- //

// library: block: compare: two <author>Larry Hayes Smith</author> </<description></description> <version control></version control> <version>1.0.0.0.95</version> (filenamemacro=compblct.s) [<Program>] [<Research>] [kn, ri, we, 08-09-2010 01:15:44]
PROC PROCBlockCompareTwo()
 // e.g. PROC Main()
 // e.g.  PROCBlockCompareTwo()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER k = 0
 INTEGER stateI = 0
 INTEGER quitB = FALSE
 //
 STRING fileName1S[255] = MakeTempName( "." )
 STRING fileName2S[255] = MakeTempName( "." )
 //
 PushPosition()
 //
 Message( "Mark block one, then press <CtrlShift 1> (or press <SHIFT><ESC> at any time to cancel)" )
 //
 REPEAT
  //
  k = GetKey()
  //
  CASE k
   //
   WHEN <CtrlShift 1>
    IF ( IsBlockInCurrFile() ) AND ( stateI == 0 )
     SaveBlock( fileName1S )
     Message( "Now mark block two, then press <CtrlShift 2>" )
     stateI = stateI + 1
    ENDIF
    //
   WHEN <CtrlShift 2>
    IF ( IsBlockInCurrFile() ) AND ( stateI == 1 )
     SaveBlock( fileName2S )
     Message( "Complete. Now run the compare program(s)" )
     stateI = stateI + 1
    ENDIF
    //
   WHEN <Shift ESCAPE>
    quitB = TRUE
    //
  OTHERWISE
   //
   PressKey( k )
   //
  ENDCASE
  //
  UpDateDisplay() IF WaitForKeyPressed( 0 ) ENDIF
  //
  PutAttrXy( 1, Query( STATUSLINEROW ), Color( INTENSE BRIGHT RED ON YELLOW ), 10 )
  //
 UNTIL ( quitB ) OR ( stateI == 2 )
 //
 IF ( quitB )
  //        )
  Warn( "Cancelled." )
  //
 ELSE
  //
  // StartPgm( fileNameExecutableS, Format( QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ) )
  //
  IF ( YesNo( "Run TSE macro CmpBuffers?" ) == 1 )
   ExecMacro( Format( "CmpBuffers", " ", QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ) )
   stateI = stateI + 1
  ENDIF
  //
  IF ( NOT ( YesNo( "Do you want to run more compare programs?" ) == 1 ) )
   //
   Warn( "press any key when comparison is finished (then the 2 temporary created files will be deleted)" )
   EraseDiskFile( fileName1S )
   EraseDiskFile( fileName2S )
   //
   UpdateDisplay( _ALL_WINDOWS_REFRESH_ )
   //
   RETURN()
   //
  ENDIF
  //
  IF ( YesNo( "Run TSE macro CmpFiles?" ) == 1 )
   EditFile( fileName1S )
   ExecMacro( Format( "CmpFiles", " ", QuotePath( fileName2S ) ) )
   stateI = stateI + 1
  ENDIF
  //
  IF ( YesNo( "Run BeyondCompare?" ) == 1 )
   PROCFileRun4NtAliasCommandListUser( Format( "beyondcompare", " ", Format( QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ), " ", "&&", " ", "exit" ) )
   stateI = stateI + 1
  ENDIF
  //
  IF ( YesNo( "Run Total Commander?" ) == 1 )
   PROCFileRun4NtAliasCommandListUser( Format( "totalcommander", " ", "/S=C", " ", Format( QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ), " ", "&&", " ", "exit" ) )
   stateI = stateI + 1
  ENDIF
  //
  IF ( YesNo( "Run CsDiff?" ) == 1 )
   PROCFileRun4NtAliasCommandListUser( Format( "csdiff", " ", Format( QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ), " ", "&&", " ", "exit" ) )
   stateI = stateI + 1
  ENDIF
  //
  IF ( YesNo( "Run DiffZilla?" ) == 1 )
   PROCFileRun4NtAliasCommandListUser( Format( "diffzilla", " ", Format( QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ), " ", "&&", " ", "exit" ) )
   stateI = stateI + 1
  ENDIF
  //
  IF ( YesNo( "Run ExamDiff?" ) == 1 )
   PROCFileRun4NtAliasCommandListUser( Format( "examdiff", " ", Format( QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ), " ", "&&", " ", "exit" ) )
   stateI = stateI + 1
  ENDIF
  //
  IF ( YesNo( "Run KDiff?" ) == 1 )
   PROCFileRun4NtAliasCommandListUser( Format( "kdiff", " ", Format( QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ), " ", "&&", " ", "exit" ) )
   stateI = stateI + 1
  ENDIF
  //
  IF ( YesNo( "Run TkDiff?" ) == 1 )
   PROCFileRun4NtAliasCommandListUser( Format( "tkdiff", " ", Format( QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ), " ", "&&", " ", "exit" ) )
   stateI = stateI + 1
  ENDIF
  //
  IF ( YesNo( "Run UltraCompare?" ) == 1 )
   PROCFileRun4NtAliasCommandListUser( Format( "ultracompare", " ", Format( QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ), " ", "&&", " ", "exit" ) )
   stateI = stateI + 1
  ENDIF
  //
  IF ( YesNo( "Run WinDiff?" ) == 1 )
   PROCFileRun4NtAliasCommandListUser( Format( "windiff", " ", Format( QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ), " ", "&&", " ", "exit" ) )
   stateI = stateI + 1
  ENDIF
  //
  IF ( YesNo( "Run WinMerge?" ) == 1 )
   PROCFileRun4NtAliasCommandListUser( Format( "winmerge", " ", Format( QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ), " ", "&&", " ", "exit" ) )
   stateI = stateI + 1
  ENDIF
  //
  IF ( YesNo( "Run P4merge?" ) == 1 )
   PROCFileRun4NtAliasCommandListUser( Format( "p4merge", " ", Format( QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ), " ", "&&", " ", "exit" ) )
   stateI = stateI + 1
  ENDIF
  //
  IF ( YesNo( "Run AraxisMerge?" ) == 1 )
   PROCFileRun4NtAliasCommandListUser( Format( "araxismerge", " ", Format( QuotePath( fileName1S ), " ", QuotePath( fileName2S ) ), " ", "&&", " ", "exit" ) )
   stateI = stateI + 1
  ENDIF
  //
  // If at least one comparison program run, ask to press key to continue
  //
  IF ( stateI >= 3 )
   Warn( "press any key when comparison is finished (then the 2 temporary created files will be deleted)" )
  ENDIF
  //
  EraseDiskFile( fileName1S )
  EraseDiskFile( fileName2S )
  //
  UpdateDisplay( _ALL_WINDOWS_REFRESH_ )
  //
 ENDIF
 //
 PopPosition()
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

// library: string: get: error <description>general output string to recognize an error (e.g. in another routine). Central routine, only one occurrence of this constant string</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstger.s) [<Program>] [<Research>] [kn, ri, sa, 05-12-1998 20:58:17]
STRING PROC FNStringGetErrorS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetErrorS() ) // gives e.g. "<ERROR>"
 // e.g. END
 //
 RETURN( "<ERROR>" )
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
