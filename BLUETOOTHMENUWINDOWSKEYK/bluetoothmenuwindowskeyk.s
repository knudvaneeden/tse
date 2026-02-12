FORWARD INTEGER PROC FNProgramRunBluetoothMenuViewWindowsKeyKAutohotkeyB()
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 Message( FNProgramRunBluetoothMenuViewWindowsKeyKAutohotkeyB() ) // gives e.g. TRUE
END

<F12> Main()

// --- LIBRARY --- //

// library: program: run: bluetooth: menu: view: windows: key: k: autohotkey <description></description> <version control></version control> <version>1.0.0.0.5</version> <version control></version control> (filenamemacro=bluetoothmenuwindowskeyk.s) [<Program>] [<Research>] [kn, ri, we, 14-12-2022 12:11:33]
INTEGER PROC FNProgramRunBluetoothMenuViewWindowsKeyKAutohotkeyB()
 // e.g. PROC Main()
 // e.g.  Message( FNProgramRunBluetoothMenuViewWindowsKeyKAutohotkeyB() ) // gives e.g. TRUE
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
 // e.g. // QuickHelp( HELPDEFFNProgramRunBluetoothMenuViewWindowsKeyKAutohotkeyB )
 // e.g. HELPDEF HELPDEFFNProgramRunBluetoothMenuViewWindowsKeyKAutohotkeyB
 // e.g.  title = "FNProgramRunBluetoothMenuViewWindowsKeyKAutohotkeyB() help" // The help's caption
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
 STRING outputFileNameS[255] = "c:\temp\ddd.ahk" // change this
 //
 PushPosition()
 PushBlock()
 //
 PushPosition()
 PushBlock()
 EraseDiskFile( outputFileNameS )
 IF EditFile( outputFileNameS )
  AbandonFile()
 ENDIF
 PopBlock()
 PopPosition()
 //
 EditFile( outputFileNameS )
 AddLine( "Send, {LWin down}k{LWin up}" )
 SaveAs( outputFileNameS, _OVERWRITE_ )
 //
 // PROCFileRun4NtAliasCommandListUser( Format( "autohotkey", " ", QuotePath( outputFileNameS ) ) )
 Dos( Format( "g:\macrorecorder\autohotkey\autohotkey.exe", " ", QuotePath( outputFileNameS ) ), _START_HIDDEN_ ) // you will have to supply the full path to the autohotkey executable
 //
 B = TRUE
 //
 IF EditFile( outputFileNameS )
  AbandonFile()
 ENDIF
 //
 PopBlock()
 PopPosition()
 //
 RETURN( B )
 //
END
