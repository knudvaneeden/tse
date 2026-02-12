FORWARD INTEGER PROC FNProgramRunSearchGrepTseTseB()
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 Message( FNProgramRunSearchGrepTseTseB() ) // gives e.g. TRUE
END

<F12> Main()

// --- LIBRARY --- //

// library: program: run: search: grep: tse: tse <description></description> <version control></version control> <version>1.0.0.0.7</version> <version control></version control> (filenamemacro=grepsemwaretse.s) [<Program>] [<Research>] [kn, ri, su, 04-12-2022 20:49:03]
INTEGER PROC FNProgramRunSearchGrepTseTseB()
 // e.g. PROC Main()
 // e.g.  Message( FNProgramRunSearchGrepTseTseB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // Use case = Convert Tse grep output (e.g. with -f) to TSE grep compatible output.
 //
 //            Only applicable if the TSE grep search option contains -f
 //
 //            The meaning of '-f' is to display also the filename on each found line
 //
 //            You want to convert a block of lines with the
 //            filename in front of each line to a block
 //            with the filename occurring once on top.
 //
 // ===
 //
 // Method = Check the filenames in 2 consecutive lines, if equal do something, if not equal do something and use a flag B TRUE or FALSE
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
 STRING optionS[255] = ""
 //
 optionS = Trim( Query( MacroCmdLine ) )
 //
 // only run this macro if the -f option is found
 //
 IF NOT StrFind( "-f", optionS, "i" )
  B = FALSE
  RETURN( B )
 ENDIF
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
   IF LFind( ":", "c" ) // search for the end of the first filename
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
   IF LFind( ":", "c" ) // search for the filename below the current line
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
 PopPosition()
 PopBlock()
 //
 B = TRUE
 //
 RETURN( B )
 //
END
