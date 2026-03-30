FORWARD INTEGER PROC FNTextSearchWordFileAllB()
FORWARD PROC Main()


// --- MAIN --- //

INTEGER sort_flags = _IGNORE_CASE_   // (internal) used for Sorting
//
PROC Main()
 Message( FNTextSearchWordFileAllB() ) // gives e.g. TRUE
END

<Ctrl F12> Main()

// --- LIBRARY --- //

// library: text: search: word: file: all <description></description> <version control></version control> <version>1.0.0.0.4</version> <version control></version control> (filenamemacro=mcvw.s) [<Program>] [<Research>] [kn, ri, mo, 30-03-2026 23:10:19]
INTEGER PROC FNTextSearchWordFileAllB()
 // e.g. INTEGER sort_flags = _IGNORE_CASE_   // (internal) used for Sorting
 // e.g. //
 // e.g. PROC Main()
 // e.g.  Message( FNTextSearchWordFileAllB() ) // gives e.g. TRUE
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
 // e.g. // QuickHelp( HELPDEFFNTextSearchWordFileAllB )
 // e.g. HELPDEF HELPDEFFNTextSearchWordFileAllB
 // e.g.  title = "FNTextSearchWordFileAllB() help" // The help's caption
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
 STRING word[255] = ""
 //
 STRING opstr[4] = ""
 //
 word = GetWord( 1 )
 //
 IF ( Length(word) == 0 ) OR ( word == "@" ) OR ( word == "$" )
  //
  B = FALSE
  //
  RETURN( B )
  //
 ENDIF
 //
 opstr='wv'
 //
 IF ( sort_flags & _IGNORE_CASE_ ) <> 0
  //
  opstr=opstr + 'i'
  //
 ENDIF
 //
 opstr = opstr + 'a'
 //
 IF lFind( word, opstr )
  //
  B = TRUE
  //
 ELSE
  //
  Message( word, " ", ":", " ", "search: file: all: not found." )
  //
  B = FALSE
  //
 ENDIF
 //
 RETURN( B )
 //
END
