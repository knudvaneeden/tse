FORWARD INTEGER PROC FNMathGetDifferenceSquareSumSumSquareI( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathGetSumRecursiveI( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathGetSumSquareRecursiveI( INTEGER i1, INTEGER i2 )
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 STRING s1[255] = "1"
 STRING s2[255] = "10"
 Warn( FNMathGetDifferenceSquareSumSumSquareI( 1, 100 ) ) // gives e.g. 25164150
 REPEAT
  IF ( NOT ( Ask( "math: get: difference: sum: square: square: sum: aI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
  IF ( NOT ( Ask( "math: get: difference: sum: square: square: sum: bI = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
  Warn( FNMathGetDifferenceSquareSumSumSquareI( Val( s1 ), Val( s2 ) ) ) // gives e.g. ( 55 )^2 - ( 385 ) = 2640
 UNTIL FALSE
END

<F12> Main()

// --- LIBRARY --- //

// library: math: get: difference: square: sum: sum: square <description></description> <version control></version control> <version>1.0.0.0.5</version> <version control></version control> (filenamemacro=getmassq.s) [<Program>] [<Research>] [kn, ri, fr, 01-02-2013 22:37:04]
INTEGER PROC FNMathGetDifferenceSquareSumSumSquareI( INTEGER aI, INTEGER bI )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "1"
 // e.g.  STRING s2[255] = "10"
 // e.g.  Warn( FNMathGetDifferenceSquareSumSumSquareI( 1, 100 ) ) // gives e.g. 25164150
 // e.g.  REPEAT
 // e.g.   IF ( NOT ( Ask( "math: get: difference: sum: square: square: sum: aI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.   IF ( NOT ( Ask( "math: get: difference: sum: square: square: sum: bI = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.   Warn( FNMathGetDifferenceSquareSumSumSquareI( Val( s1 ), Val( s2 ) ) ) // gives e.g. ( 55 )^2 - ( 385 ) = 2640
 // e.g.  UNTIL FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER sumI = FNMathGetSumRecursiveI( aI, bI )
 //
 RETURN( ( sumI * sumI ) - FNMathGetSumSquareRecursiveI( aI, bI ) )
 //
END

// library: math: get: sum: recursive <description></description> <version>1.0.0.0.5</version> <version control></version control> (filenamemacro=getmasre.s) [<Program>] [<Research>] [kn, ri, we, 08-02-2012 00:53:19]
INTEGER PROC FNMathGetSumRecursiveI( INTEGER aI, INTEGER bI )
 // e.g. PROC Main()
 // e.g. STRING s1[255] = "1"
 // e.g. STRING s2[255] = "10"
 // e.g. REPEAT
 // e.g.  IF ( NOT ( Ask( "math: get: sum: recursive: aI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "math: get: sum: recursive: bI = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Warn( FNMathGetSumRecursiveI( Val( s1 ), Val( s2 ) ) ) // gives e.g. 55
 // e.g. UNTIL FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF ( aI > bI )
  //
  RETURN( 0 )
  //
 ENDIF
 //
 RETURN( aI + FNMathGetSumRecursiveI( aI + 1, bI ) )
 //
END

// library: math: get: sum: square: recursive <description></description> <version>1.0.0.0.4</version> <version control></version control> (filenamemacro=getmasrf.s) [<Program>] [<Research>] [kn, ri, we, 08-02-2012 01:02:43]
INTEGER PROC FNMathGetSumSquareRecursiveI( INTEGER aI, INTEGER bI )
 // e.g. PROC Main()
 // e.g. STRING s1[255] = "3"
 // e.g. STRING s2[255] = "4"
 // e.g. REPEAT
 // e.g.  IF ( NOT ( Ask( "math: get: sum: square: recursive: aI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "math: get: sum: square: recursive: bI = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Warn( FNMathGetSumSquareRecursiveI( Val( s1 ), Val( s2 ) ) ) // gives e.g. 25 (=3^2 + 4^2)
 // e.g. UNTIL FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF ( aI > bI )
  //
  RETURN( 0 )
  //
 ENDIF
 //
 RETURN( ( aI * aI ) + FNMathGetSumSquareRecursiveI( aI + 1, bI ) )
 //
END
