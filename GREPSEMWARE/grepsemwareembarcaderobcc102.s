FORWARD INTEGER PROC FNProgramRunSearchGrepTseEmbarcaderobcc102B()
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 Message( FNProgramRunSearchGrepTseEmbarcaderobcc102B() ) // gives e.g. TRUE
END

<F12> Main()

// --- LIBRARY --- //

// library: program: run: search: grep: tse: embarcaderobcc102 <description></description> <version control></version control> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=grepsemwareembarcaderobcc102.s) [<Program>] [<Research>] [kn, ri, su, 04-12-2022 22:34:42]
INTEGER PROC FNProgramRunSearchGrepTseEmbarcaderobcc102B()
 // e.g. PROC Main()
 // e.g.  Message( FNProgramRunSearchGrepTseEmbarcaderobcc102B() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // Use case = Convert Embarcaderobcc102 grep output to TSE grep output.
 //
 //            You want to convert a block of lines with the
 //            filename in front of each line to a block
 //            with the filename occurring once on top.
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
c:\temp\foobar1.txt:1       a
c:\temp\foobar1.txt:2       a
c:\temp\foobar1.txt:3       a
c:\temp\foobar1.txt:4       a
c:\temp\foobar2.txt:1       a
c:\temp\foobar2.txt:2       a
c:\temp\foobar2.txt:3       a
c:\temp\foobar2.txt:4       a
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
c:\temp\foobar1.txt
1: a
2: a
3: a
4: a
c:\temp\foobar2.txt
1: a
2: a
3: a
4: a
--- cut here: end ----------------------------------------------------
 */
 //
 // ===
 //
 // e.g. // QuickHelp( HELPDEFFNProgramRunSearchGrepTseEmbarcaderobcc102B )
 // e.g. HELPDEF HELPDEFFNProgramRunSearchGrepTseEmbarcaderobcc102B
 // e.g.  title = "FNProgramRunSearchGrepTseEmbarcaderobcc102B() help" // The help's caption
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
 INTEGER downB = TRUE
 //
 STRING s1[255] = ""
 STRING s2[255] = ""
 //
 INTEGER I1 = 0
 INTEGER I2 = 0
 //
 INTEGER B = FALSE
 //
 IF ( NOT ( IsBlockInCurrFile() ) ) Warn( "Please mark a block" ) B = FALSE RETURN( B ) ENDIF // return from the current procedure if no block is marked
 //
 Set( BREAK, ON )
 //
 PushPosition()
 PushBlock()
 //
 GotoBlockEnd()
 AddLine( "Q" )
 //
 GotoBlockBegin()
 //
 WHILE ( ( IsCursorInBlock() ) AND ( downB ) )
  //
  // skip empty lines
  //
  IF NOT LFind( "^$", "cgx" )
   //
   GotoColumn( 3 ) // go past the first ':' after the drive letter
   IF LFind( "[ :]", "cx" ) // search for the end of the first filename
    I1 = CurrCol()
    //
    // extract the first filename
    //
    s1 = GetText( 1, I1 - 1 )
   ENDIF
   //
   PushPosition()
   PushBlock()
   //
   Down()
   GotoColumn( 3 ) // go past the first ':' after the drive letter
   IF LFind( "[ :]", "cx" ) // search for the filename below the current line
    I2 = CurrCol()
    //
    // extract the filename below the current line
    //
    s2 = GetText( 1, I2 - 1 )
   ENDIF
   Up()
   //
   IF ( B == FALSE )
    B = TRUE
    InsertLine( Format( "File:", " ", s1 ) )
    Down()
   ENDIF
   //
   IF ( NOT EquiStr( s1, s2 ) ) AND ( B == TRUE )
    B = FALSE
   ENDIF
   //
   PushBlock()
   PushPosition()
   GotoColumn( 1 )
   MarkStream()
   GotoColumn( I1 )
   MarkStream()
   Cut()
   PopBlock()
   PopPosition()
   //
   PopBlock()
   PopPosition()
   //
  ENDIF
  //
  downB = Down()
  //
 ENDWHILE
 //
 IF LFind( "^Q$", "gx" )
  DelLine()
 ENDIF
 //
 WHILE LFind( ": Is a Directory$", "gix" )
  DelLine()
 ENDWHILE
 //
 PopPosition()
 PopBlock()
 //
 B = TRUE
 //
 RETURN( B )
 //
END
