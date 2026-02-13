FORWARD INTEGER PROC FNBlockRunTseB()
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 Message( FNBlockRunTseB() ) // gives e.g. TRUE
END

<Ctrl F12> Main()

// --- LIBRARY --- //

// library: block: run: tse <description></description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=runblrts.s) [<Program>] [<Research>] [kn, ri, fr, 13-02-2026 16:56:38]
INTEGER PROC FNBlockRunTseB()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockRunTseB() ) // gives e.g. TRUE
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
 // e.g. // QuickHelp( HELPDEFFNBlockRunTseB )
 // e.g. HELPDEF HELPDEFFNBlockRunTseB
 // e.g.  title = "FNBlockRunTseB() help" // The help's caption
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
 STRING fileNameS[255] = "c:\temp\ddd.s" // change this
 //
 IF ( NOT ( IsBlockInCurrFile() ) ) Warn( "Please mark a block" ) B = FALSE RETURN( B ) ENDIF // return from the current procedure if no block is marked
 //
 PushPosition()
 PushBlock()
 //
 Copy()
 //
 // erase / refresh / clean up the current file
 //
 PushPosition()
 PushBlock()
 IF EditFile( fileNameS )
  AbandonFile()
 ENDIF
 EraseDiskFile( fileNameS )
 PopPosition()
 PopBlock()
 //
 // get the block into the current file
 //
 EditFile( fileNameS )
 Paste()
 //
 // compile current filename
 //
 ExecMacro( "compile -m" )
 //
 // execute current filename macro
 //
 ExecMacro( Format( AddTrailingSlash( SplitPath( fileNameS, _DRIVE_ | _PATH_ | _NAME_ ) ), ".mac" ) )
 //
 PopBlock()
 PopPosition()
 //
 B = TRUE
 //
 RETURN( B )
 //
END
