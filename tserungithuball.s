FORWARD INTEGER PROC FNProgramRunTseGithubAllB()
FORWARD PROC Main()


// --- MAIN --- //

#DEFINE ELIST_INCLUDED FALSE
#include [ "eList.s" ]
//
PROC Main()
 Message( FNProgramRunTseGithubAllB() ) // gives e.g. TRUE
END

<F12> Main()

// --- LIBRARY --- //

// library: program: run: tse: github: all <description></description> <version control></version control> <version>1.0.0.0.22</version> <version control></version control> (filenamemacro=tserungithuball.s) [<Program>] [<Research>] [kn, ri, mo, 12-12-2022 21:00:22]
INTEGER PROC FNProgramRunTseGithubAllB()
 // e.g. #DEFINE ELIST_INCLUDED FALSE
 // e.g. #include [ "eList.s" ]
 // e.g. //
 // e.g. PROC Main()
 // e.g.  Message( FNProgramRunTseGithubAllB() ) // gives e.g. TRUE
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
 // e.g. // QuickHelp( HELPDEFFNProgramRunTseGithubAllB )
 // e.g. HELPDEF HELPDEFFNProgramRunTseGithubAllB
 // e.g.  title = "FNProgramRunTseGithubAllB() help" // The help's caption
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
 STRING s1[255] = ""
 //
 INTEGER bufferI = 0
 //
 STRING fileNameS[255] = "c:\temp\dddloggithub.log" // change this
 //
 REPEAT
  //
  PushPosition()
  bufferI = CreateTempBuffer()
  PopPosition()
  //
  PushPosition()
  PushBlock()
  //
  IF GotoBufferId( bufferI )
   PushBlock()
   PushPosition()
   // ExecMacro( "tserungithuballline" )
   // #INCLUDE [ "tserungithuballline.inc" ]
   //
   // The .inc file is a comma separated value (=CSV) file (separator is here the semi-colon)
   //
   // this path means that the include file is in the same directory as the loaded TSE macro
   //
   InsertFile( Format( AddTrailingSlash( SplitPath( CurrMacroFilename(), _DRIVE_ | _PATH_ ) ), "tserungithuballline.inc" ) )
   EndFile()
   AddLine( "quit" )
   // PurgeMacro( "tserungithuballline" )
   PopBlock()
   PopPosition()
  ENDIF
  //
  GotoLine( 1 )
  IF eList( "Choose an option" )
   s1 = Trim( GetText( 1, 255 ) )
  ELSE
   AbandonFile( bufferI )
   PopBlock()
   PopPosition()
   RETURN( FALSE )
  ENDIF
  AbandonFile( bufferI )
  PopBlock()
  PopPosition()
  //
  // do something with s1
  //
  PushPosition()
  PushBlock()
  EditFile( fileNameS )
  EndFile()
  Set( TimeFormat, 3 ) // 24 hour format and zero in front in time format
  AddLine( Format( "[", GetDateStr(), " ", GetTimeStr(), "]", ",", " ", s1 ) )
  EndLine()
  SaveAs( fileNameS, _OVERWRITE_ )
  PopBlock()
  PopPosition()
  //
  // s1 = FNStringGetCarS( s1 )
  s1 = GetToken( s1, ";", 1 )
  //
  PushBlock()
  PushPosition()
  ExecMacro( s1 )
  UpDateDisplay() // IF WaitForKeyPressed( 0 ) ENDIF // Activate if using a loop
  Warn( "<Press any key>" )
  PopBlock()
  PopPosition()
  //
 UNTIL EquiStr( s1, "quit" )
 //
 B = TRUE
 //
 RETURN( B )
 //
END
