FORWARD INTEGER PROC FNFileSaveCurrentToDirectoryLocalGitVersionControlB( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5, STRING s6 )
FORWARD INTEGER PROC FNFileSetUploadGithubFileVersionControlB( STRING s1, STRING s2, STRING s3, STRING s4, STRING s5, STRING s6 )
FORWARD INTEGER PROC FNMacroCheckExecB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckLoadB( STRING s1 )
FORWARD INTEGER PROC FNMathCheckLogicNotB( INTEGER i1 )
FORWARD INTEGER PROC FNMathGetNumberInputYesNoCancelPositionDefaultI( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
FORWARD PROC Main()
FORWARD PROC PROCMacroExec( STRING s1 )
FORWARD PROC PROCMacroRunKeep( STRING s1 )
FORWARD PROC PROCWarn( STRING s1 )
FORWARD PROC PROCWarnCons3( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetAsciiToCharacterS( INTEGER i1 )
FORWARD STRING PROC FNStringGetCarS( STRING s1 )
FORWARD STRING PROC FNStringGetCharacterSymbolCentralS( INTEGER i1 )
FORWARD STRING PROC FNStringGetCharacterSymbolSpaceS()
FORWARD STRING PROC FNStringGetConcatSeparatorS( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetCons3S( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetConsS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetEmptyS()


// --- MAIN --- //

PROC Main()
 //
 STRING s1[255] = "C:\TEMP\TSE\" // optionally change this (this is the directory where your (e.g. TSE) files are saved)
 //
 // STRING s2[255] = "https://github.com/knudvaneeden/python-neuralnetwork-tensorflow-01.git"
 // STRING s2[255] = "https://github.com/knudvaneeden/python-neuralnetwork-tensorflow-00.git" // change this (this is the remote github repository)
 STRING s2[255] = "https://github.com/knudvaneeden/tse" // change this (this is the remote github repository)
 //
 STRING s3[255] = "g:\cygwin\bin\git.exe" // change this (this is the full path to your git executable)
 //
 STRING s4[255] = "g:\utils\jpsoft\tcmd\tcc.exe" // change this to your JPSoft tcc.exe
 //
 // STRING s5[255] = FNStringGetProgramRunUsernameFileVersionControlGithubKnudS()
 STRING s5[255] = "yourGithubUserName" // you *must* change this to your own GitHub username and recompile this TSE macro
 //
 // STRING s6[255] = FNStringGetProgramRunPasswordFileVersionControlGithubKnudS()
 STRING s6[255] = "yourGithubPassword" // you *must* change this to your own GitHub password and recompile this TSE macro
 //
 IF ( NOT ( Ask( "file: set: upload: github: version: control: yourLocalDirectoryS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 IF ( NOT ( Ask( "file: set: upload: github: version: control: githubRemoteDirectoryUrlS = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 Message( FNFileSaveCurrentToDirectoryLocalGitVersionControlB( s1, s2, s3, s4, s5, s6 ) ) // gives e.g. TRUE if successful
END

<F12> Main()

// --- LIBRARY --- //

// library: file: save: to: directory: local: git: version: control <description></description> <version control></version control> <version>1.0.0.0.15</version> <version control></version control> (filenamemacro=savefivc.s) [<Program>] [<Research>] [kn, ri, su, 18-02-2018 05:40:49]
INTEGER PROC FNFileSaveCurrentToDirectoryLocalGitVersionControlB( STRING yourLocalDirectoryS, STRING githubRemoteDirectoryUrlS, STRING fileNameExecutableGitS, STRING fileNameExecutableTccS, STRING githubUserNameS, STRING githubPasswordS )
 // e.g. PROC Main()
 // e.g.  //
 // e.g.  STRING s1[255] = "C:\TEMP\TSE\" // optionally change this (this is the directory where your (e.g. TSE) files are saved)
 // e.g.  //
 // e.g.  // STRING s2[255] = "https://github.com/knudvaneeden/python-neuralnetwork-tensorflow-01.git"
 // e.g.  // STRING s2[255] = "https://github.com/knudvaneeden/python-neuralnetwork-tensorflow-00.git" // change this (this is the remote github repository)
 // e.g.  STRING s2[255] = "https://github.com/knudvaneeden/tse" // change this (this is the remote github repository)
 // e.g.  //
 // e.g.  STRING s3[255] = "g:\cygwin\bin\git.exe" // change this (this is the full path to your git executable)
 // e.g.  //
 // e.g.  STRING s4[255] = "g:\utils\jpsoft\tcmd\tcc.exe" // change this to your JPSoft tcc.exe
 // e.g.  //
 // e.g.  // STRING s5[255] = FNStringGetProgramRunUsernameFileVersionControlGithubKnudS()
 // e.g.  STRING s5[255] = "yourGithubUserName" // you *must* change this to your own GitHub username and recompile this TSE macro
 // e.g.  //
 // e.g.  // STRING s6[255] = FNStringGetProgramRunPasswordFileVersionControlGithubKnudS()
 // e.g.  STRING s6[255] = "yourGithubPassword" // you *must* change this to your own GitHub password and recompile this TSE macro
 // e.g.  //
 // e.g.  IF ( NOT ( Ask( "file: set: upload: github: version: control: yourLocalDirectoryS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "file: set: upload: github: version: control: githubRemoteDirectoryUrlS = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Message( FNFileSaveCurrentToDirectoryLocalGitVersionControlB( s1, s2, s3, s4, s5, s6 ) ) // gives e.g. TRUE if successful
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER B = FALSE
 //
 // STRING fileNameBatchS[255] = "c:\temp\ddd.bat"
 //
 STRING fileNameCurrentS[255] = CurrFilename()
 //
 STRING fileNameS[255] = Format( yourLocalDirectoryS, SplitPath( fileNameCurrentS, _NAME_ | _EXT_ ) )
 //
 IF FileExists( fileNameS )
  //
  Warn( "This file", ":", " ", fileNameS, " ", "exists already in your local GitHub directory", ":", " ", yourLocalDirectoryS )
  //
  IF ( FNMathGetNumberInputYesNoCancelPositionDefaultI( "Do you first want to upload this local GitHub directory to the remote GitHub directory" ) == 1 )
   //
   B = FNFileSetUploadGithubFileVersionControlB( yourLocalDirectoryS, githubRemoteDirectoryUrlS, fileNameExecutableGitS, fileNameExecutableTccS, githubUserNameS, githubPasswordS )
   IF ( NOT ( B ) )
    Warn( "could not upload the local GitHub directory", ":", " ", yourLocalDirectoryS, " ", ". Please check." )
    B = FALSE
    RETURN( B )
   ENDIF
   //
   EditFile( fileNameCurrentS )
   B = SaveAs( fileNameS, _OVERWRITE_ )
   IF ( NOT ( B ) )
    Warn( "could not overwrite the file", ":", " ", fileNameS, " ", "in the local GitHub directory. Please check." )
    B = FALSE
    RETURN( B )
   ENDIF
   //
   // PushPosition()
   // IF ( EditFile( fileNameBatchS ) )
   //  AbandonFile()
   //  EraseDiskFile( fileNameBatchS )
   // ENDIF
   // PopPosition()
   // //
   // B = FNFileSetUploadGithubFileVersionControlB( yourLocalDirectoryS, githubRemoteDirectoryUrlS, fileNameExecutableGitS, fileNameExecutableTccS, githubUserNameS, githubPasswordS )
   // IF ( NOT ( B ) )
   //  Warn( "could not upload the local GitHub directory", ":", " ", yourLocalDirectoryS, " ", ". Please check." )
   //  B = FALSE
   //  RETURN( B )
   // ENDIF
   // //
  ELSEIF ( FNMathGetNumberInputYesNoCancelPositionDefaultI( Format( "Do you want to overwrite the existing file", ":", " ", fileNameS ) ) == 1 )
   //
   EditFile( fileNameCurrentS )
   B = SaveAs( fileNameS, _OVERWRITE_ )
   IF ( NOT ( B ) )
    Warn( "could not overwrite the file", ":", " ", fileNameS, " ", "in the local GitHub directory. Please check." )
    B = FALSE
    RETURN( B )
   ENDIF
   //
  ENDIF
  //
 ELSE // file does not exist in that directory yet
  //
  EditFile( fileNameCurrentS )
  B = SaveAs( fileNameS )
  IF ( NOT ( B ) )
   Warn( "could not save the current file as", ":", " ", fileNameS, " ", "in the local GitHub directory. Please check." )
   B = FALSE
   RETURN( B )
  ENDIF
  //
 ENDIF
 //
 RETURN( B )
 //
END

// library: math: get: number: input: yes: no: cancel: position: default <description></description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getmapde.s) [<Program>] [<Research>] [kn, am, mo, 04-07-2011 14:23:57]
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

// library: file: set: upload: github: file: version: control <description></description> <version control></version control> <version>1.0.0.0.27</version> <version control></version control> (filenamemacro=setfivco.s) [<Program>] [<Research>] [kn, ri, fr, 09-02-2018 01:56:32]
INTEGER PROC FNFileSetUploadGithubFileVersionControlB( STRING yourLocalDirectoryS, STRING githubRemoteDirectoryUrlS, STRING fileNameExecutableGitS, STRING fileNameExecutableTccS, STRING githubUserNameS, STRING githubPasswordS )
 // e.g. PROC Main()
 // e.g.  //
 // e.g.  // STRING s1[255] = "C:\TEMP\DDDPYTHON01\"
 // e.g.  STRING s1[255] = "C:\TEMP\DDDPYTHON00\" // change this (this is the directory where your files are saved)
 // e.g.  //
 // e.g.  // STRING s2[255] = "https://github.com/knudvaneeden/python-neuralnetwork-tensorflow-01.git"
 // e.g.  STRING s2[255] = "https://github.com/knudvaneeden/python-neuralnetwork-tensorflow-00.git" // change this (this is the remote github repository)
 // e.g.  //
 // e.g.  STRING s3[255] = "g:\cygwin\bin\git.exe" // change this (this is the full path to your git executable)
 // e.g.  //
 // e.g.  STRING s4[255] = "g:\utils\jpsoft\tcmd\tcc.exe" // change this to your JPSoft tcc.exe
 // e.g.  //
 // e.g.  STRING s5[255] = FNStringGetProgramRunUsernameFileVersionControlGithubKnudS()
 // e.g.  // STRING s5[255] = "yourGithubUserName" // you *must* change this to your own GitHub username and recompile this TSE macro
 // e.g.  //
 // e.g.  STRING s6[255] = FNStringGetProgramRunPasswordFileVersionControlGithubKnudS()
 // e.g.  // STRING s6[255] = "yourGithubPassword" // you *must* change this to your own GitHub password and recompile this TSE macro
 // e.g.  //
 // e.g.  IF ( NOT ( Ask( "file: set: upload: github: version: control: yourLocalDirectoryS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "file: set: upload: github: version: control: githubRemoteDirectoryUrlS = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Message( FNFileSetUploadGithubFileVersionControlB( s1, s2, s3, s4, s5, s6 ) ) // gives e.g. TRUE if successful
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER B = FALSE
 //
 STRING fileNameS[255] = "c:\temp\ddd.bat"
 //
 STRING commitInformationS[255] = Format( '"', "Next commit", ":", " ", GetDateStr(), " ", GetTimeStr(), '"' )
 //
 IF EditFile( fileNameS )
  AbandonFile()
  EraseDiskFile( fileNameS )
 ENDIF
 //
 EditFile( fileNameS )
 //
 AddLine( Format( "cdd", " ", yourLocalDirectoryS ) )
 AddLine( Format( fileNameExecutableGitS, " ", "add", " ", "." ) )
 AddLine( Format( fileNameExecutableGitS, " ", "commit", " ", "-m", " ", commitInformationS ) )
 AddLine( Format( fileNameExecutableGitS, " ", "remote", " ", "add", " ", "origin", " ", githubRemoteDirectoryUrlS ) )
 AddLine( Format( fileNameExecutableGitS, " ", "remote", " ", "-v" ) )
 //
 // AddLine( Format( fileNameExecutableGitS, " ", "push", " ", "origin", " ", "master" ) ) // use this if no keystack, but you will then repeatedly have to supply your GitHub username + password
 AddLine( Format( "keystack", " ", '"', githubUserNameS, '"', " ", "enter", " ", '"', githubPasswordS, '"', " ", "enter", " ", "&", " ", fileNameExecutableGitS, " ", "push", " ", "origin", " ", "master" ) )
 //
 AddLine( Format( "pause" ) )
 //
 SaveAs( fileNameS, _OVERWRITE_ )
 //
 // PROCFileRun4NtAliasCommandListUser( fileNameS ) // run this batch file using tcc.exe
 LDos( fileNameExecutableTccS, fileNameS )
 //
 // PROCProgramRunInternetBrowserUrl( githubRemoteDirectoryUrlS )
 StartPgm( githubRemoteDirectoryUrlS )
 //
 B = TRUE
 //
 RETURN( B )
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

// library: macro: check: load <description>macro: load: (Loads a Macro File From Disk Into Memory) R    LoadMacro(STRING macro_filename)*</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checmacl.s) [<Program>] [<Research>] [[kn, zoe, we, 16-06-1999 01:07:06]
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

// library: string: check: empty <description>string: empty: is given string empty?</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checstcz.s) [<Program>] [<Research>] [[kn, ri, sa, 20-05-2000 20:11:08]
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
