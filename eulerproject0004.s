FORWARD INTEGER PROC FNMathGetProduct3DigitNumberPalindromeMaxI()
FORWARD PROC Main()
FORWARD STRING PROC FNStringGetCharacterReverseRecursiveSimpleS( STRING s1 )
FORWARD STRING PROC FNStringGetCharacterReverse_RecursiveSimpleSubS( STRING s1, STRING s2 )


// --- MAIN --- //

PROC Main()
 Message( FNMathGetProduct3DigitNumberPalindromeMaxI() ) // gives e.g. "906609"
END

<F12> Main()

// --- LIBRARY --- //

// library: math: get: product3: digit: number: palindrome: max <description></description> <version control></version control> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=getmapma.s) [<Program>] [<Research>] [kn, ri, su, 27-01-2013 01:11:30]
INTEGER PROC FNMathGetProduct3DigitNumberPalindromeMaxI()
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetProduct3DigitNumberPalindromeMaxI() ) // gives e.g. "906609"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER I = 0
 //
 INTEGER J = 0
 //
 INTEGER productI = 0
 //
 STRING s1[255] = ""
 STRING s2[255] = ""
 //
 INTEGER maxI = -MAXINT
 //
 FOR I = 100 TO 999 // from smallest 3 digit number (which is 100) to largest 3 digit number (which is 999)
  //
  FOR J = 100 TO 999
   //
   productI = I * J
   //
   s1 = Str( productI )
   //
   s2 = FNStringGetCharacterReverseRecursiveSimpleS( s1 )
   //
   IF EquiStr( s1, s2 )
    //
    IF ( productI > maxI )
     //
     maxI = productI
     //
    ENDIF
    //
   ENDIF
   //
  ENDFOR
  //
  ENDFOR
 //
 RETURN( maxI )
 //
END

// library: string: get: character: reverse: recursive: simple <description></description> <version control></version control> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstrsj.s) [<Program>] [<Research>] [kn, ri, su, 27-01-2013 01:19:09]
STRING PROC FNStringGetCharacterReverseRecursiveSimpleS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "hello"
 // e.g.  REPEAT
 // e.g.   IF ( NOT ( Ask( " = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.   Warn( FNStringGetCharacterReverseRecursiveSimpleS( s1 ) ) // gives e.g. "olleh"
 // e.g.  UNTIL FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterReverse_RecursiveSimpleSubS( s, "" ) )
 //
END

// library: string: get: character: reverse: recursive: simple: sub <description></description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getstssb.s) [<Program>] [<Research>] [kn, ri, su, 27-01-2013 01:20:05]
STRING PROC FNStringGetCharacterReverse_RecursiveSimpleSubS( STRING s, STRING reverseS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterReverse_RecursiveSimpleSubS( "hello", "" ) ) // gives e.g. "olleh"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF ( s == "" )
  //
  RETURN( reverseS )
  //
 ENDIF
 //
 RETURN( FNStringGetCharacterReverse_RecursiveSimpleSubS( s[2:Length(s)], s[1] + reverseS ) )
 //
END
