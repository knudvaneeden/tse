FORWARD INTEGER PROC FNBlockGetWordFrequencyVectorI( INTEGER i1, INTEGER i2, INTEGER i3, STRING s1, STRING s2, STRING s3 )
FORWARD INTEGER PROC FNMathGetErrorI()
FORWARD INTEGER PROC FNMathGetIntegerMaximumAbsoluteI()
FORWARD INTEGER PROC FNMathGetIntegerMinimumAbsoluteI()
FORWARD PROC Main()
FORWARD STRING PROC FNStringGetExpressionRegularCharacterMetaEscapeS( STRING s1 )


// --- MAIN --- //

PROC Main()
 INTEGER buffer1I = 0
 INTEGER buffer2I = 0
 INTEGER buffer3I = 0
 INTEGER bufferI = 0
 //
 STRING fileNameS[255] = CurrFilename()
 //
 STRING s2[255] = "c:\temp\ddd1.csv" // change this
 STRING s3[255] = "c:\temp\ddd2.csv" // change this
 STRING s4[255] = "5"
 //
 STRING s5[255] = "g:\dddfrequencylistignore.txt" // change this to e.g. an empty file otherwise a file with a list of words to ignore
 // STRING s5[255] = "" // in general no ignore list file
 //
 STRING s[255] = ""
 //
 PushPosition()
 bufferI = CreateTempBuffer()
 PopPosition()
 //
 PushPosition()
 buffer1I = CreateTempBuffer()
 PopPosition()
 //
 PushPosition()
 buffer2I = CreateTempBuffer()
 PopPosition()
 //
 PushPosition()
 PushBlock()
 buffer3I = CreateTempBuffer()
 GotoBufferId( buffer3I )
 InsertFile( s5 ) // load the file with words to ignore // e.g. spelling errors, foreign words, person names, verbs, non-nouns, ...)
 PopBlock()
 PopPosition()
 //
 Message( FNBlockGetWordFrequencyVectorI( buffer1I, buffer2I, buffer3I, s4, s2, s3 ) ) // gives e.g. 100 if 100 words in the block
 //
 PushPosition()
 IF EditFile( s2 )
  AbandonFile()
  EraseDiskFile( s2 )
 ENDIF
 PopPosition()
 //
 PushPosition()
 IF EditFile( s3 )
  AbandonFile()
  EraseDiskFile( s3 )
 ENDIF
 PopPosition()
 //
 PushPosition()
 GotoBufferId( buffer2I )
 BegFile()
 DO ( NumLines() - 1 ) TIMES
  s = GetText( 1, 255 )
  s = Trim( s )
  PushPosition()
  GotoBufferId( bufferI )
  EndLine()
  InsertText( s, _INSERT_ )
  InsertText( ",", _INSERT_ )
  InsertText( " ", _INSERT_ )
  PopPosition()
  Down()
 ENDDO
  PushPosition()
  GotoBufferId( bufferI )
  EndLine()
  InsertText( s, _INSERT_ )
  MarkLine()
  Copy()
  PopPosition()
 PopPosition()
 //
 EditFile( s2 )
 EndFile()
 BegLine()
 Paste()
 //
 EditFile( s3 )
  IF ( NOT ( EquiStr( Trim( GetText( 1, 255 ) ), "" ) ) )
  InsertText( ",", _INSERT_ )
  InsertText( " ", _INSERT_ )
 ENDIF
 EndLine()
 InsertText( s4, _INSERT_ )
 //
 OneWindow()
 VWindow()
 VWindow()
 GotoWindow( 1 )
 HWindow()
 GotoWindow( 3 )
 HWindow()
 //
 GotoWindow( 1 )
 GotoBufferId( buffer1I )
 BegFile()
 //
 GotoWindow( 2 )
 GotoBufferId( buffer2I )
 BegFile()
 //
 GotoWindow( 3 )
 EditFile( s2 )
 BegFile()
 //
 GotoWindow( 4 )
 EditFile( fileNameS )
 GotoBlockBegin()
 //
 GotoWindow( 5 )
 EditFile( s3 )
 BegFile()
 //
END

<F12> Main()

// --- LIBRARY --- //

// library: block: get: word: frequency: vector <description></description> <version control></version control> <version>1.0.0.0.27</version> <version control></version control> (filenamemacro=getblfve.s) [<Program>] [<Research>] [kn, ri, we, 21-02-2018 00:11:33]
INTEGER PROC FNBlockGetWordFrequencyVectorI( INTEGER buffer1I, INTEGER buffer2I, INTEGER buffer3I, STRING outputS, STRING fileNameCsvInputS, STRING fileNameCsvOutputS )
 // e.g. PROC Main()
 // e.g.  INTEGER buffer1I = 0
 // e.g.  INTEGER buffer2I = 0
 // e.g.  INTEGER buffer3I = 0
 // e.g.  INTEGER bufferI = 0
 // e.g.  //
 // e.g.  STRING fileNameS[255] = CurrFilename()
 // e.g.  //
 // e.g.  STRING s2[255] = "c:\temp\ddd1.csv" // change this
 // e.g.  STRING s3[255] = "c:\temp\ddd2.csv" // change this
 // e.g.  STRING s4[255] = "5"
 // e.g.  //
 // e.g.  STRING s5[255] = "g:\dddfrequencylistignore.txt" // change this to e.g. an empty file otherwise a file with a list of words to ignore
 // e.g.  // STRING s5[255] = "" // in general no ignore list file
 // e.g.  //
 // e.g.  STRING s[255] = ""
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  bufferI = CreateTempBuffer()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  buffer1I = CreateTempBuffer()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  buffer2I = CreateTempBuffer()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  PushBlock()
 // e.g.  buffer3I = CreateTempBuffer()
 // e.g.  GotoBufferId( buffer3I )
 // e.g.  InsertFile( s5 ) // load the file with words to ignore // e.g. spelling errors, foreign words, person names, verbs, non-nouns, ...)
 // e.g.  PopBlock()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  Message( FNBlockGetWordFrequencyVectorI( buffer1I, buffer2I, buffer3I, s4, s2, s3 ) ) // gives e.g. 100 if 100 words in the block
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  IF EditFile( s2 )
 // e.g.   AbandonFile()
 // e.g.   EraseDiskFile( s2 )
 // e.g.  ENDIF
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  IF EditFile( s3 )
 // e.g.   AbandonFile()
 // e.g.   EraseDiskFile( s3 )
 // e.g.  ENDIF
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  GotoBufferId( buffer2I )
 // e.g.  BegFile()
 // e.g.  DO ( NumLines() - 1 ) TIMES
 // e.g.   s = GetText( 1, 255 )
 // e.g.   s = Trim( s )
 // e.g.   PushPosition()
 // e.g.   GotoBufferId( bufferI )
 // e.g.   EndLine()
 // e.g.   InsertText( s, _INSERT_ )
 // e.g.   InsertText( ",", _INSERT_ )
 // e.g.   InsertText( " ", _INSERT_ )
 // e.g.   PopPosition()
 // e.g.   Down()
 // e.g.  ENDDO
 // e.g.   PushPosition()
 // e.g.   GotoBufferId( bufferI )
 // e.g.   EndLine()
 // e.g.   InsertText( s, _INSERT_ )
 // e.g.   MarkLine()
 // e.g.   Copy()
 // e.g.   PopPosition()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  EditFile( s2 )
 // e.g.  EndFile()
 // e.g.  BegLine()
 // e.g.  Paste()
 // e.g.  //
 // e.g.  EditFile( s3 )
 // e.g.   IF ( NOT ( EquiStr( Trim( GetText( 1, 255 ) ), "" ) ) )
 // e.g.   InsertText( ",", _INSERT_ )
 // e.g.   InsertText( " ", _INSERT_ )
 // e.g.  ENDIF
 // e.g.  EndLine()
 // e.g.  InsertText( s4, _INSERT_ )
 // e.g.  //
 // e.g.  OneWindow()
 // e.g.  VWindow()
 // e.g.  VWindow()
 // e.g.  GotoWindow( 1 )
 // e.g.  HWindow()
 // e.g.  GotoWindow( 3 )
 // e.g.  HWindow()
 // e.g.  //
 // e.g.  GotoWindow( 1 )
 // e.g.  GotoBufferId( buffer1I )
 // e.g.  BegFile()
 // e.g.  //
 // e.g.  GotoWindow( 2 )
 // e.g.  GotoBufferId( buffer2I )
 // e.g.  BegFile()
 // e.g.  //
 // e.g.  GotoWindow( 3 )
 // e.g.  EditFile( s2 )
 // e.g.  BegFile()
 // e.g.  //
 // e.g.  GotoWindow( 4 )
 // e.g.  EditFile( fileNameS )
 // e.g.  GotoBlockBegin()
 // e.g.  //
 // e.g.  GotoWindow( 5 )
 // e.g.  EditFile( s3 )
 // e.g.  BegFile()
 // e.g.  //
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER I = 0
 //
 INTEGER minI = 1
 //
 INTEGER lastLineI = 0
 //
 STRING s[255] = ""
 //
 STRING s1[255] = ""
 //
 INTEGER lineCurrentI = 0
 //
 INTEGER bufferI = 0
 //
 IF ( NOT ( IsBlockInCurrFile() ) ) Warn( "Please mark a block" ) I = FNMathGetErrorI() RETURN( I ) ENDIF // return from the current procedure if no block is marked
 //
 PushPosition()
 PushBlock()
 //
 PushPosition()
 bufferI = CreateTempBuffer()
 PopPosition()
 //
 GotoBlockBegin()
 //
 lastLineI = Query( BlockEndLine )
 //
 I = minI - 1
 //
 WHILE ( ( WordRight() ) AND ( CurrLine() <= lastLineI ) )
  //
  IF ( isWord() ) AND ( isCursorInBlock() )
   //
   I = I + 1
   //
   s = GetWord()
   s = Trim( s )
   //
   PushPosition()
   //
   GotoBufferId( buffer3I ) // check if the word is in the ignore file
   IF ( NOT ( LFind( Format( "^", FNStringGetExpressionRegularCharacterMetaEscapeS( s ), "$" ), "gix" ) ) )
    //
    GotoBufferId( buffer1I )
    IF ( LFind( Format( "^", FNStringGetExpressionRegularCharacterMetaEscapeS( s ), "$" ), "gix" ) )
     lineCurrentI = CurrLine()
     GotoBufferId( buffer2I )
     GotoLine( lineCurrentI )
     s1 = GetText( 1, 255 )
     s1 = Trim( s1 )
     s1 = Str( Val( s1 ) + 1 )
     BegLine()
     DelToEol()
     InsertText( s1 )
    ELSE
     //
     EndFile()
     AddLine( s )
     //
     PushPosition()
     GotoBufferId( buffer2I )
     EndFile()
     AddLine( "1" ) // first time it occurs, thus 1 times
     PopPosition()
     //
    ENDIF
    //
   ENDIF
   //
  PopPosition()
  //
  ENDIF
  //
 ENDWHILE
 //
 PopBlock()
 PopPosition()
 //
 RETURN( I )
 //
END

// library: math: get: error <description>indicate, via the returned number, that an error occurred</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getmager.s) [<Program>] [<Research>] [kn, ri, th, 29-04-1999 21:19:56]
INTEGER PROC FNMathGetErrorI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetErrorI() ) // gives e.g. -( 2^31 - 1 ) = -2147483647
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathGetIntegerMinimumAbsoluteI() )
 //
END

// library: string: get: expression: regular: character: meta: escape <description></description> <version>1.0.0.0.4</version> <version control></version control> (filenamemacro=getstmes.s) [<Program>] [<Research>] [kn, ri, mo, 20-12-2010 01:06:56]
STRING PROC FNStringGetExpressionRegularCharacterMetaEscapeS( STRING inS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetExpressionRegularCharacterMetaEscapeS( "{" ) ) // gives e.g. "\{"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = inS
 //
 s = StrReplace( "\", s, "\\", "gn" )
 s = StrReplace( "{", s, "\{", "gn" )
 s = StrReplace( "[", s, "\[", "gn" )
 s = StrReplace( "}", s, "\}", "gn" )
 s = StrReplace( "]", s, "\]", "gn" )
 s = StrReplace( "*", s, "\*", "gn" )
 s = StrReplace( "+", s, "\+", "gn" )
 s = StrReplace( "@", s, "\@", "gn" )
 s = StrReplace( ".", s, "\.", "gn" )
 s = StrReplace( "^", s, "\^", "gn" )
 s = StrReplace( "$", s, "\$", "gn" )
 s = StrReplace( "|", s, "\|", "gn" )
 s = StrReplace( "?", s, "\?", "gn" )
 s = StrReplace( "#", s, "\#", "gn" )
 s = StrReplace( "/", s, "\/", "gn" ) // [kn, ri, tu, 03-01-2012 00:20:06]
 //
 RETURN( s )
 //
END

// library: math: get: integer: minimum: absolute <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getmamab.s) [<Program>] [<Research>] [kn, noot, mo, 09-07-2001 11:51:54]
INTEGER PROC FNMathGetIntegerMinimumAbsoluteI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetIntegerMinimumAbsoluteI() ) // gives always a negative integer. E.g. -4
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( - FNMathGetIntegerMaximumAbsoluteI() )
 //
END

// library: math: get: integer: maximum: absolute <description></description> <version control></version control> <version>1.0.0.0.4</version> (filenamemacro=getmamac.s) [<Program>] [<Research>] [kn, noot, mo, 09-07-2001 11:51:54]
INTEGER PROC FNMathGetIntegerMaximumAbsoluteI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetIntegerMaximumAbsoluteI() ) // gives the maximum value of an integer possible in TSE. This is currently 2147483647 (= 2^31 - 1. Note this is not 2^32 - 1 even if 32 bits, because 1 bit is reserved for the sign (thus '+' or '-'), as it are signed integers by design in TSE).
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( MAXINT )
 //
END
