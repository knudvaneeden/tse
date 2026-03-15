FORWARD INTEGER PROC FNFileSaveVersionControlAllB()
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 Message( FNFileSaveVersionControlAllB() ) // gives e.g. TRUE
END

<Ctrl F12> Main()

// --- LIBRARY --- //

// library: file: save: version: control: all <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=saveficj.s) [<Program>] [<Research>] [kn, ri, su, 15-03-2026 22:44:25]
INTEGER PROC FNFileSaveVersionControlAllB()
 // e.g. PROC Main()
 // e.g.  Message( FNFileSaveVersionControlAllB() ) // gives e.g. TRUE
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
 // e.g. // QuickHelp( HELPDEFFNFileSaveVersionControlAllB )
 // e.g. HELPDEF HELPDEFFNFileSaveVersionControlAllB
 // e.g.  title = "FNFileSaveVersionControlAllB() help" // The help's caption
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
 // Subversion
 //
 // local
 //
 PushKey( <Enter> )
 PushKey( <Enter> )
 ExecMacro( "updafisc" )
 //
 // online
 //
 PushKey( <Enter> )
 PushKey( <Enter> )
 PushKey( <CursorDown> )
 ExecMacro( "updafisc" )
 //
 Delay( 2 * 36 )
 //
 // Git
 //
 // local
 //
 PushKey( <Enter> )
 PushKey( <Enter> )
 ExecMacro( "updaficd" )
 //
 // online
 //
 PushKey( <Enter> )
 PushKey( <Enter> )
 PushKey( <CursorDown> )
 ExecMacro( "updaficd" )
 //
 // PurgeMacro( CurrMacroFilename() )
 //
 B = TRUE
 //
 RETURN( B )
 //
END
