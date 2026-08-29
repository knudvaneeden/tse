FORWARD PROC Main()
FORWARD PROC PROCFileReplaceLoadFromDiskRefreshRingAllDefault()


// --- MAIN --- //

PROC Main()
 PROCFileReplaceLoadFromDiskRefreshRingAllDefault()
END

<Ctrl F12> Main()

// --- LIBRARY --- //

// library: file: replace: load: from: disk: refresh: ring: all: default <description></description> <version control></version control> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=filereplaceloadfromdiskrefreshringalldefault\replfira.s) [<Program>] [<Research>] [kn, ri, sa, 29-08-2026 02:56:36]
PROC PROCFileReplaceLoadFromDiskRefreshRingAllDefault()
 // e.g. PROC Main()
 // e.g.  PROCFileReplaceLoadFromDiskRefreshRingAllDefault()
 // e.g. END
 // e.g.
 // e.g. <Ctrl F12> Main()
 //
 // ===
 //
 // Use case = For all currently loaded files in the TSE ring:
 //            Get the latest file version from disk: You refresh from disk all already loaded files in the TSE ring.
 //
 //            It is basically the refresh action on 1 file, as happens when you chohose in TSE
 //
 //             <menu TSE> > 'Util' > 'Potpourri' > 'ReplaceF' to replace the current file,
 //
 //             but now you perform this action for all files in the ring automatically.
 //
 //             E.g.
 //
 //              You ask Artificial Intelligence (=AI) to generate files (e.g. foobar.s) for you.
 //              You download the filename to a fixed download directory location.
 //              Keep the filename and its path the same, e.g. c:\downloads\foobar.s
 //              You only load the filename once in TSE, then next updates running this program
 //              are replaced by the latest file version in the download
 //
 //             E.g.
 //
 //              You had files loaded in the TSE ring in TSE for Linux.
 //              You develop those files further on TSE for Microsoft Windows.
 //              Then when finished in TSE for Microsoft Windows there you want to have all the files also loaded
 //              to their TSE for Linux.
 //              So then you run this TSE macro.
 //
 //             E.g.
 //
 //              You had all the unzipped files in this .zip file loaded in TSE.
 //
 //               FppPack_1_04_portable.zip
 //
 //              Then you make all kind of changes in 1 or more of those files,
 //              e.g. editing in another direetory and then copying those
 //              files into the unzipped directory.
 //              You want then all these changed files loaded inside your TSE
 //              so that you have the latest version of these files loaded from disk.
 //              Then you run this TSE macro.
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
 // e.g. // QuickHelp( HELPDEFPROCFileLoadFromDiskRefreshReplaceRingAllDefault )
 // e.g. HELPDEF HELPDEFPROCFileReplaceLoadFromDiskRefreshRingAllDefault
 // e.g.  title = "PROCFileReplaceLoadFromDiskRefreshRingAllDefault() help" // The help's caption
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
 INTEGER fileCountI = NumFiles()
 //
 INTEGER I = 0
 //
 WHILE ( I < fileCountI )
  //
  UpDateDisplay() // IF WaitForKeyPressed( 0 ) ENDIF // Activate if using a loop
  //
  ExecMacro( "replacef" )
  //
  NextFile()
  //
  I = I + 1
  //
 ENDWHILE
 //
END
