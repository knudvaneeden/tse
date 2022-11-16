FORWARD INTEGER PROC FNFileSaveFileVersionControlGitSimplestCaseB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckExecB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckLoadB( STRING s1 )
FORWARD INTEGER PROC FNMathCheckLogicNotB( INTEGER i1 )
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
 STRING s1[255] = "" // change this
 //
 INTEGER bufferI = 0
 //
 INTEGER quitB = FALSE
 //
 REPEAT
  //
  PushPosition()
  bufferI = CreateTempBuffer()
  PopPosition()
  //
  PushPosition()
  PushBlock()
  GotoBufferId( bufferI )
  //
  AddLine( "Once initialize your repository directory (and set your name + your email)" )
  AddLine( "--------------------------------------------------------------------------" )
  AddLine( "Add + Commit your current loaded file in TSE (into your local repository)" )
  AddLine( "Add + Commit your current loaded file in TSE (into your remote repository)" )
  AddLine( "--------------------------------------------------------------------------" )
  AddLine( "Goto your Git server web page on the Internet (e.g. GitHub)" )
  AddLine( "Status" )
  AddLine( "Log" )
  AddLine( "Diff" )
  AddLine( "--------------------------------------------------------------------------" )
  AddLine( "Settings" )
  AddLine( "--------------------------------------------------------------------------" )
  AddLine( "Quit" )
  //
  GotoLine( 1 )
  PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
  IF List( "Choose an option", 80 )
   s1 = Trim( GetText( 1, 255 ) )
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
  quitB = EquiStr( Trim( Lower( s1 ) ), "quit" )
  //
  IF NOT quitB
   Message( FNFileSaveFileVersionControlGitSimplestCaseB( s1 ) ) // gives e.g. TRUE
  ENDIF
  //
 UNTIL ( quitB )
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

// library: file: save: file: version: control: git: simplest: case <description></description> <version control></version control> <version>1.0.0.0.66</version> <version control></version control> (filenamemacro=git_knud.s) [<Program>] [<Research>] [kn, ri, su, 13-11-2022 23:45:27]
INTEGER PROC FNFileSaveFileVersionControlGitSimplestCaseB( STRING caseS )
 // e.g. PROC Main()
 // e.g.  //
 // e.g.  STRING s1[255] = "" // change this
 // e.g.  //
 // e.g.  INTEGER bufferI = 0
 // e.g.  //
 // e.g.  INTEGER quitB = FALSE
 // e.g.  //
 // e.g.  REPEAT
 // e.g.   //
 // e.g.   PushPosition()
 // e.g.   bufferI = CreateTempBuffer()
 // e.g.   PopPosition()
 // e.g.   //
 // e.g.   PushPosition()
 // e.g.   PushBlock()
 // e.g.   GotoBufferId( bufferI )
 // e.g.   //
 // e.g.   AddLine( "Once initialize your repository directory (and set your name + your email)" )
 // e.g.   AddLine( "--------------------------------------------------------------------------" )
 // e.g.   AddLine( "Add + Commit your current loaded file in TSE (into your local repository)" )
 // e.g.   AddLine( "Add + Commit your current loaded file in TSE (into your remote repository)" )
 // e.g.   AddLine( "--------------------------------------------------------------------------" )
 // e.g.   AddLine( "Goto your Git server web page on the Internet (e.g. GitHub)" )
 // e.g.   AddLine( "Status" )
 // e.g.   AddLine( "Log" )
 // e.g.   AddLine( "Diff" )
 // e.g.   AddLine( "--------------------------------------------------------------------------" )
 // e.g.   AddLine( "Settings" )
 // e.g.   AddLine( "--------------------------------------------------------------------------" )
 // e.g.   AddLine( "Quit" )
 // e.g.   //
 // e.g.   GotoLine( 1 )
 // e.g.   PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
 // e.g.   IF List( "Choose an option", 80 )
 // e.g.    s1 = Trim( GetText( 1, 255 ) )
 // e.g.   ELSE
 // e.g.    AbandonFile( bufferI )
 // e.g.    PopBlock()
 // e.g.    PopPosition()
 // e.g.    RETURN()
 // e.g.   ENDIF
 // e.g.   AbandonFile( bufferI )
 // e.g.   PopBlock()
 // e.g.   PopPosition()
 // e.g.   //
 // e.g.   quitB = EquiStr( Trim( Lower( s1 ) ), "quit" )
 // e.g.   //
 // e.g.   IF NOT quitB
 // e.g.    Message( FNFileSaveFileVersionControlGitSimplestCaseB( s1 ) ) // gives e.g. TRUE
 // e.g.   ENDIF
 // e.g.   //
 // e.g.  UNTIL ( quitB )
 // e.g.  //
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
 // e.g. // QuickHelp( HELPDEFFNFileSaveFileVersionControlGitSimplestCaseB )
 // e.g. HELPDEF HELPDEFFNFileSaveFileVersionControlGitSimplestCaseB
 // e.g.  title = "FNFileSaveFileVersionControlGitSimplestCaseB() help" // The help's caption
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
 // CHANGE: ONCE: BEGIN
 //
 STRING sectionS[255] = "git_knud" // change this optionally. This is the section name that should be used in tse.ini.
 //
 STRING directoryExecutableS[255] = "g:\versioncontrol\git\gitscm\cmd\" // change this
 //
 // STRING nameTrunkS[255] = "master" // change this (you will first have to pull and merge
 STRING nameTrunkS[255] = "TRUNK" // change this
 //
 STRING messageS[255] = "changes in this revision = draft|backup|works|created|add setm|replace menu hotkey|save|major|minor|recompile|compiles|refactor|original" // change this
 //
 STRING directoryRepositoryInS[255] = "C:\TEMP\RG01" // change this (this is your repository directory)
 //
 STRING userNameS[255] = GetProfileStr( sectionS, "userNameS", "yourusername"  ) // (this is your e.g. GitHug=b user name
 STRING userEmailS[255] = GetProfileStr( sectionS, "userEmailS", "youremail" ) // (this is your e.g. GitHug=b password.
 //
 // fill in your e.g. GitHub user name or password. I store it in my.ini file, you might store it in e.g. tse.ini, or optionally (not recommended) store it hardcoded in this file
 STRING githubUserNameS[255] = GetProfileStr( sectionS, "FNStringGetProgramRunUsernameFileVersionControlGithubKnudS", "yourusername"  ) // (this is your e.g. GitHug user name
 STRING githubPasswordS[255] = GetProfileStr( sectionS, "FNStringGetProgramRunPasswordFileVersionControlGithubKnudS", "yourpassword" ) // (this is your e.g. GitHub password.
 STRING githubRemoteDirectoryUrlS[255] = GetProfileStr( sectionS, "githubRemoteDirectoryUrlS", "yourremotegitserver" ) // (this is your e.g. GitHub remote directory
 //
 // CHANGE: ONCE: END
 //
 STRING fileNameCurrentS[255] = Quotepath( CurrFilename() )
 //
 STRING fileNameExtensionS[255] = SplitPath( fileNameCurrentS, _NAME_ | _EXT_ )
 //
 STRING directoryRepositoryS[255] = QuotePath( directoryRepositoryInS )
 //
 STRING driveLetterS[255] = SplitPath( directoryRepositoryS, _DRIVE_ )
 //
 STRING executableS[255] = Format( QuotePath( AddTrailingSlash( directoryExecutableS ) ), "git.exe" )
 //
 STRING s[255] = ""
 //
 PushPosition()
 PushBlock()
 //
 CASE Trim( caseS )
  //
  WHEN "Once initialize your repository directory (and set your name + your email)"
   //
   PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
   IF ( NOT ( Ask( "file: save: file: version: control: git: simplest: case: userNameS = ", userNameS, _EDIT_HISTORY_ ) ) AND ( Length( userNameS ) > 0 ) ) RETURN( FALSE ) ENDIF
   PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
   IF ( NOT ( Ask( "file: save: file: version: control: git: simplest: case: userEmailS = ", userEmailS, _EDIT_HISTORY_ ) ) AND ( Length( userEmailS ) > 0 ) ) RETURN( FALSE ) ENDIF
   PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
   IF ( NOT ( Ask( "file: save: file: version: control: git: simplest: case: directoryRepositoryS = ", directoryRepositoryS, _EDIT_HISTORY_ ) ) AND ( Length( directoryRepositoryS ) > 0 ) ) RETURN( FALSE ) ENDIF
   //
   // check if repository directory exists, if not existing then warn and create it
   //
   IF NOT FileExists( directoryRepositoryS )
    PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
    Warn( "This Git repository directory does not exist and will be created now", ":", " ", directoryRepositoryS )
    MkDir( directoryRepositoryS )
   ENDIF
   //
   // initialize that repository directory (it will create a hidden .git directory inside the root of that directory)
   //
   s = Format( driveLetterS, " ", "&", " ", "cd", " ", directoryRepositoryS, " ", "&", " ", executableS, " ", "init", " ", "-b", " ", nameTrunkS, " ", directoryRepositoryS )
   Dos( Format( s, " ", "2>&1" ), _START_HIDDEN_ )
   //
   s = Format( executableS, " ", "config", " ", "--global", " ", "user.name", " ", '"', userNameS, '"' )
   Dos( Format( s, " ", "2>&1" ), _START_HIDDEN_ )
   //
   s = Format( executableS, " ", "config", " ", "--global", " ", "user.email", " ", '"', userEmailS, '"' )
   Dos( Format( s, " ", "2>&1" ), _START_HIDDEN_ )
   //
  WHEN "Add + Commit your current loaded file in TSE (into your local repository)"
   //
   IF NOT FileExists( directoryRepositoryS )
    PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
    Warn( "Run the initialize step first to create a Git repository" )
    //
   ELSE
    //
    PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
    IF ( ( Ask( "messageS = ", messageS, _EDIT_HISTORY_ ) ) AND ( Length( messageS ) > 0 ) )
     //
     s = Format( driveLetterS, " ", "&", " ", "cd", " ", directoryRepositoryS )
     s = Format( s, " ", "&", " " )
     s = Format( s, "copy", " ", fileNameCurrentS )
     s = Format( s, " ", "&", " " )
     s = Format( s, executableS, " ", "add", " ", fileNameExtensionS )
     s = Format( s, " ", "&", " " )
     s = Format( s, executableS, " ", "commit", " ", "-m", " ", '"', messageS, '"', " ", fileNameExtensionS )
     // Dos( Format( s, " ", "2>&1" ), _START_HIDDEN_ )
     Dos( Format( s, " ", "2>&1" ), _DONT_PROMPT_ )
    ENDIF
   //
   ENDIF
   //
  WHEN "Add + Commit your current loaded file in TSE (into your remote repository)"
   //
   s = Format( driveLetterS, " ", "&", " ", "cd", " ", directoryRepositoryS )
   // s = Format( s, " ", "&", " " )
   // s = Format( s, "keystack", " ", '"', githubUserNameS, '"', " ", "enter", " ", '"', githubPasswordS, '"', " ", "enter" )
   s = Format( s, " ", "&", " " )
   s = Format( s, executableS, " ", "push", " ", "--set-upstream", " ", githubRemoteDirectoryUrlS, " ", nameTrunkS )
   s = Format( s, " ", "&", " " )
   s = Format( s, "pause" )
   Dos( s )
   //
  WHEN "Status"
   //
   IF NOT FileExists( directoryRepositoryS )
    PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
    Warn( "Run the initialize step first to create a Git repository" )
   ELSE
    //
    s = Format( driveLetterS, " ", "&", " ", "cd", " ", directoryRepositoryS )
    s = Format( s, " ", "&", " " )
    s = Format( s, executableS, " ", "status" )
    Dos( s )
    //
   ENDIF
   //
  WHEN "Log"
   //
   IF NOT FileExists( directoryRepositoryS )
    PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
    Warn( "Run the initialize step first to create a Git repository" )
   ELSE
    //
    s = Format( driveLetterS, " ", "&", " ", "cd", " ", directoryRepositoryS )
    s = Format( s, " ", "&", " " )
    s = Format( s, executableS, " ", "log", " ", "--oneline" )
    Dos( s )
    //
   ENDIF
   //
  WHEN "Diff"
   //
   IF NOT FileExists( directoryRepositoryS )
    PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
    Warn( "Run the initialize step first to create a Git repository" )
   ELSE
    //
    s = Format( driveLetterS, " ", "&", " ", "cd", " ", directoryRepositoryS )
    s = Format( s, " ", "&", " " )
    s = Format( s, executableS, " ", "diff", " ", fileNameExtensionS )
    s = Format( s, " ", "&", " " )
    s = Format( s, "pause" )
    Dos( s )
    //
   ENDIF
   //
  WHEN "Goto your Git server web page on the Internet (e.g. GitHub)"
   //
   StartPgm( githubRemoteDirectoryUrlS )
   //
  WHEN "Settings"
   //
   PushPosition()
   PushBlock()
   EditFile( Format( AddTrailingSlash( LoadDir() ), "tse.ini" ) )
   IF LFind( sectionS, "" )
    ScrollToTop()
   ELSE
    Warn( "no expected session", ":", " ", "[", sectionS, "]", " ", "found in tse.ini. Please add it + add the parameters" )
   ENDIF
   UpDateDisplay() // IF WaitForKeyPressed( 0 ) ENDIF // Activate if using a loop
   PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
   Warn( "<Press any key to continue>" )
   PopBlock()
   PopPosition()
   //
 OTHERWISE
  //
  Warn( "FNFileSaveFileVersionControlGitCaseB(", " ", "case", " ", ":", " ", caseS, ": not known" )
  //
  B = FALSE
  //
 ENDCASE
 //
 PopBlock()
 PopPosition()
 //
 RETURN( B )
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
 // e.g.  Message( FNStringCheckEmptyB( s ) ) // gives e.g. TRUE
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
