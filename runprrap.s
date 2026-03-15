FORWARD PROC Main()
FORWARD STRING PROC FNProgramRunProjectRosettaAllS()
FORWARD STRING PROC FNStringGetErrorS()


// --- MAIN --- //

PROC Main()
 Message( FNProgramRunProjectRosettaAllS() ) // gives e.g. "rosettaproject0001"
END

<Ctrl F12> Main()

// --- LIBRARY --- //

// library: program: run: project: rosetta: all <description></description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=runprrap.s) [<Program>] [<Research>] [kn, ri, su, 15-03-2026 22:54:22]
STRING PROC FNProgramRunProjectRosettaAllS()
 // e.g. PROC Main()
 // e.g.  Message( FNProgramRunProjectRosettaAllS() ) // gives e.g. "rosettaproject0001"
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
 // e.g. // QuickHelp( HELPDEFFNProgramRunProjectRosettaAllS )
 // e.g. HELPDEF HELPDEFFNProgramRunProjectRosettaAllS
 // e.g.  title = "FNProgramRunProjectRosettaAllS() help" // The help's caption
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
 INTEGER bufferI = 0
 //
 INTEGER lineI = 0
 //
 PushPosition()
 bufferI = CreateTempBuffer()
 PopPosition()
 //
 PushPosition()
 PushBlock()
 //
 GotoBufferId( bufferI )
 //
 AddLine( "------------------------------------------------------------------" )
 AddLine( "+ROSETTA: CODE: PROJECT" )
 AddLine( "------------------------------------------------------------------" )
 EndFile()
 AddLine()
 BegLine()
 InsertFile( "rosettaorglist.txt" )
 EndFile()
 AddLine()
 AddLine( "------------------------------------------------------------------" )
 //
 GotoLine( 1 )
 IF List( "Choose an option", 80 )
  s = Trim( GetText( 1, MAXSTRINGLEN ) )
  lineI = CurrLine()
  lineI = lineI - 3 // change this
 ELSE
  AbandonFile( bufferI )
  PopBlock()
  PopPosition()
  RETURN( FNStringGetErrorS() )
 ENDIF
 AbandonFile( bufferI )
 PopBlock()
 PopPosition()
 //
 s = GetToken( s, ";", 2 )
 s = Trim( s )
 //
 StartPgm( Format( s ) )
 //
 s = Format( "rosettacodeproject", Format( lineI : 4 : "0" ) )
 ExecMacro( s )
 //
 RETURN( s )
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
