FORWARD INTEGER PROC FNFileGetTseMacroLoadedToBufferAllB()
FORWARD PROC Main()


// --- MAIN --- //

//
INTEGER loaded_macros_id = 0 // global variable
//
PROC Main()
 loaded_macros_id = NewFile()
 Hook(_LIST_STARTUP_, FNFileGetTseMacroLoadedToBufferAllB )
 PushKey(<Escape>)
 PurgeMacro()
 UnHook( FNFileGetTseMacroLoadedToBufferAllB )
 PurgeMacro( CurrMacroFilename() )
 Message( FNFileGetTseMacroLoadedToBufferAllB() ) // gives e.g. TRUE
END

<F12> Main()

// --- LIBRARY --- //

// library: file: get: tse: macro: loaded: to: buffer: all <description>author: Carlo Hogeveen</description> <version control></version control> <version>1.0.0.0.5</version> <version control></version control> (filenamemacro=tsemacroloadedget.s) [<Program>] [<Research>] [kn, ri, th, 15-12-2022 15:24:06]
INTEGER PROC FNFileGetTseMacroLoadedToBufferAllB()
 // e.g. //
 // e.g. INTEGER loaded_macros_id = 0 // global variable
 // e.g. //
 // e.g. PROC Main()
 // e.g.  loaded_macros_id = NewFile()
 // e.g.  Hook(_LIST_STARTUP_, FNFileGetTseMacroLoadedToBufferAllB )
 // e.g.  PushKey(<Escape>)
 // e.g.  PurgeMacro()
 // e.g.  UnHook( FNFileGetTseMacroLoadedToBufferAllB )
 // e.g.  PurgeMacro( CurrMacroFilename() )
 // e.g.  Message( FNFileGetTseMacroLoadedToBufferAllB() ) // gives e.g. TRUE
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
 // e.g. // QuickHelp( HELPDEFFNFileGetTseMacroLoadedToBufferAllB( )
 // e.g. HELPDEF HELPDEFFNFileGetTseMacroLoadedToBufferAllB()
 // e.g.  title = "FNFileGetTseMacroLoadedToBufferAllB() help" // The help's caption
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
 PushLocation()
 PushBlock()
 MarkLine( 1, NumLines() )
 GotoBufferId( loaded_macros_id )
 CopyBlock()
 PopBlock()
 PopLocation()
 //
 B = TRUE
 //
 RETURN( B )
 //
END
