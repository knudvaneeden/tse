FORWARD INTEGER PROC FNWindowSetCenterPopupOnB()
FORWARD MENU MENUFileSaveFileVersionControlGitSimplest()
FORWARD PROC Main()
FORWARD PROC PROCProgramRunPopupWindowPositionTse()


// --- MAIN --- //

//
#INCLUDE [ "git_tse.inc" ]
//
PROC Main()
 //
 PROCProgramRunPopupWindowPositionTse()
 MENUFileSaveFileVersionControlGitSimplest()
 //
END

<F12> Main()

// --- LIBRARY --- //

// library: program: run: git: tse: window <description></description> <version control></version control> <version>1.0.0.0.9</version> <version control></version control> (filenamemacro=runprtwi.s) [<Program>] [<Research>] [kn, ri, mo, 21-11-2022 12:31:19]
PROC PROCProgramRunPopupWindowPositionTse()
 // e.g. //
 // e.g. #INCLUDE [ "git_tse.inc" ]
 // e.g. //
 // e.g. PROC Main()
 // e.g.  PROCProgramRunPopupWindowPositionTse()
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
 // e.g. // QuickHelp( HELPDEFPROCProgramRunGitTseWindow )
 // e.g. HELPDEF HELPDEFPROCProgramRunGitTseWindow
 // e.g.  title = "PROCProgramRunPopupWindowPositionTse() help" // The help's caption
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
 STRING caseS[255] = ""
 //
 STRING sectionS[255] = GetGlobalStr( "sectionS" )
 //
 IF EquiStr( Trim( sectionS ), "" )
  //
  Warn( 'Please first set your SetGlobalStr( "sectionS" ) in file git_tse.s' )
  //
 ELSE
  //
  caseS = sectionS
  //
  CASE caseS
   //
   WHEN "git_tse"
    //
    B = FNWindowSetCenterPopupOnB()
    //
   WHEN "git_tse_knud"
    //
    ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
    //
   OTHERWISE
    //
    Warn( "PROCProgramRunPopupWindowPositionTse(", " ", "case", " ", ":", " ", caseS, ": not known" )
    //
    RETURN()
    //
  ENDCASE
 //
 ENDIF
 //
END

// library: file: save: file: version: control: git: simplest <description></description> <version control></version control> <version>1.0.0.0.13</version> <version control></version control> (filenamemacro=savefigs.s) [<Program>] [<Research>] [kn, ri, th, 24-11-2022 02:04:54]
MENU MENUFileSaveFileVersionControlGitSimplest()
 // e.g. //
 // e.g. #INCLUDE [ "git_tse.inc" ]
 // e.g. //
 // e.g. PROC Main()
 // e.g.  //
 // e.g.  PROCProgramRunPopupWindowPositionTse()
 // e.g.  MENUFileSaveFileVersionControlGitSimplest()
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
 // e.g. // QuickHelp( HELPDEFMENUFileSaveFileVersionControlGitSimplest )
 // e.g. HELPDEF HELPDEFMENUFileSaveFileVersionControlGitSimplest
 // e.g.  title = "MENUFileSaveFileVersionControlGitSimplest() help" // The help's caption
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
 history
 title = "git: choose one of the following possibilities:"
 "&P: programming git", ExecMacro( "git_tse" ), , "p: programming git"
 "", , divide
 "&R: running git", ExecMacro( "savefisp" ), , "r: running git"
END

// library: window: set: center: popup: on <description></description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=setwipon.s) [<Program>] [<Research>] [kn, ri, su, 06-11-2022 03:41:11]
INTEGER PROC FNWindowSetCenterPopupOnB()
 // e.g. PROC Main()
 // e.g.  Message( "Center popups", ":", " ", FNWindowSetCenterPopupOnB() ) // gives e.g. TRUE
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
 // e.g. // QuickHelp( HELPDEFFNWindowSetCenterPopupOnB )
 // e.g. HELPDEF HELPDEFFNWindowSetCenterPopupOnB
 // e.g.  title = "FNWindowSetCenterPopupOnB() help" // The help's caption
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
 Set( SpecialEffects, 14 ) // center popups on
 //
 RETURN( Query( SpecialEffects ) )
 //
END
