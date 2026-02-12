FORWARD INTEGER PROC FNBlockSearchConcordanceB( STRING s1, STRING s2, INTEGER i1, STRING s3 )
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 STRING s1[255] = "monstrous"
 STRING s2[255] = " "
 STRING s3[255] = "35" // by choosing a bigger number, e.g. up to about 8000 (15000) you can concatenate multiple lines before and after the search word and do a regular expression search in in that multiple lines concatenated to a single line thus.
 STRING s4[255] = "C:\TEMP\ddd.txt" // change this optionally to an existing file on your harddisk
 IF ( NOT ( Ask( "block: search: concordance: searchS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 IF ( NOT ( Ask( "block: search: concordance: searchOptionS = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 IF ( NOT ( Ask( "block: search: concordance: characterAroundMaxI = ", s3, _EDIT_HISTORY_ ) ) AND ( Length( s3 ) > 0 ) ) RETURN() ENDIF
 //
 IF ( FNBlockSearchConcordanceB( s1, s2, Val( s3 ), s4 ) )
  EditFile( s4 )
 ENDIF
 //
END

<F12> Main()

// --- LIBRARY --- //

// library: block: search: concordance <description></description> <version control></version control> <version>1.0.0.0.55</version> <version control></version control> (filenamemacro=searblsc.s) [<Program>] [<Research>] [kn, ri, sa, 17-02-2018 22:45:55]
INTEGER PROC FNBlockSearchConcordanceB( STRING searchS, STRING searchOptionS, INTEGER characterAroundMaxI, STRING fileNameS )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "monstrous"
 // e.g.  STRING s2[255] = " "
 // e.g.  STRING s3[255] = "35" // by choosing a bigger number, e.g. up to about 8000 (15000) you can concatenate multiple lines before and after the search word and do a regular expression search in in that multiple lines concatenated to a single line thus.
 // e.g.  STRING s4[255] = "C:\TEMP\ddd.txt" // change this optionally to an existing file on your harddisk
 // e.g.  IF ( NOT ( Ask( "block: search: concordance: searchS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "block: search: concordance: searchOptionS = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "block: search: concordance: characterAroundMaxI = ", s3, _EDIT_HISTORY_ ) ) AND ( Length( s3 ) > 0 ) ) RETURN() ENDIF
 // e.g.  //
 // e.g.  IF ( FNBlockSearchConcordanceB( s1, s2, Val( s3 ), s4 ) )
 // e.g.   EditFile( s4 )
 // e.g.  ENDIF
 // e.g.  //
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER B = FALSE
 //
 STRING s[255] = ""
 //
 INTEGER lineCurrentI = 0
 //
 INTEGER spaceFrontMaxI = 9
 //
 INTEGER bufferI = 0
 //
 STRING fileNameCurrentS[255] = CurrFileName()
 //
 Set( Break, ON )
 //
 IF ( NOT ( IsBlockInCurrFile() ) ) Warn( "Please mark a block" ) AbandonFile( bufferI ) B = FALSE RETURN( B ) ENDIF // return from the current procedure if no block is marked
 //
 PushPosition()
 bufferI = CreateTempBuffer()
 PopPosition()
 //
 PushPosition()
 PushBlock()
 //
 GotoBlockBegin()
 //
 // do use local seach only (not a "lg" search, or else you will continuously be checking in the same block, because at each start of the while loop, because of the 'g' you start again at the beginning of the block)
 //
 WHILE ( LFind( searchS, Format( searchOptionS, "l" ) ) AND IsCursorInBlock() )
  //
  lineCurrentI = CurrLine()
  //
  PushPosition()
  PushBlock()
  //
  BegWord()
  Left()
  //
  DO ( characterAroundMaxI ) TIMES
   PrevChar()
  ENDDO
  //
  DO ( characterAroundMaxI ) TIMES
   NextChar()
   s = GetText( CurrPos(), 1 ) // get the current character
   CASE CurrChar() // if the cursor is at the end of the line
    WHEN _AT_EOL_, _BEYOND_EOL_
    s = " "
   ENDCASE
   PushPosition()
   GotoBufferId( bufferI )
   EndFile()
   EndLine()
   InsertText( s, _INSERT_ )
   PopPosition()
  ENDDO
  //
  PushPosition()
  GotoBufferId( bufferI )
  EndFile()
  //
  BegLine()
  InsertText( Format( Format( Str( lineCurrentI ): spaceFrontMaxI ), ":", " " ), _INSERT_ )
  EndLine()
  //
  GotoColumn( characterAroundMaxI + spaceFrontMaxI + 3 )
  InsertText( searchS, _INSERT_ )
  PopPosition()
  //
  DO ( Length( searchS ) ) TIMES
   Right()
  ENDDO
  //
  DO ( characterAroundMaxI ) TIMES
   NextChar()
   s = GetText( CurrPos(), 1 ) // get the current character
   CASE CurrChar() // if the cursor is at the end of the line
    WHEN _AT_EOL_, _BEYOND_EOL_
    s = " "
   ENDCASE
   PushPosition()
   GotoBufferId( bufferI )
   EndFile()
   EndLine()
   InsertText( s, _INSERT_ )
   PopPosition()
  ENDDO
  //
  PushPosition()
  GotoBufferId( bufferI )
  EndFile()
  AddLine()
  BegLine()
  PopPosition()
  //
  PopBlock()
  PopPosition()
  //
  // you have to go to a position after the position of the last found, otherwise you stay on the same place and the same expression is found again and again
  //
  EndWord()
  //
 ENDWHILE
 //
 PushPosition()
 IF EditFile( fileNameS )
  AbandonFile()
 ENDIF
 GotoBufferId( bufferI )
 //
 BegFile()
 InsertLine()
 InsertText( Format( "In file", ":", " ", fileNameCurrentS, ":", " ", "found", " ", NumLines() - 2, " ", "occurrences of search string", ":", " ", searchS ) )
 AddLine()
 //
 SaveAs( fileNameS, _OVERWRITE_ )
 AbandonFile( bufferI )
 PopPosition()
 //
 PopPosition()
 PopBlock()
 //
 B = TRUE
 //
 RETURN( B )
 //
END
