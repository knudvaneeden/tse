FORWARD INTEGER PROC FNMathGetDamerauLevenshteinDistanceI( STRING s1, STRING s2 )
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
STRING s1[255] = "arcain"
STRING s2[255] = "arcane"
//
s1 = "arcain"
s2 = "arcane"
Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 2
//
s1 = "algorithm"
s2 = "altruistic"
Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 6
//
s1 = "1638452297"
s2 = "444488444"
Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 9
//
s1 = ""
s2 = ""
Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 0
//
s1 = "aaapppp"
s2 = ""
Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 7
//
s1 = "frog"
s2 = "fog"
Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 1
//
s1 = "fly"
s2 = "ant"
Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 3
//
s1 = "elephant"
s2 = "hippo"
Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 7
//
s1 = "hippo"
s2 = "elephant"
Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 7
//
s1 = "hippo"
s2 = "zzzzzzzz"
Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 8
//
s1 = "hello"
s2 = "hallo"
Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 1
//
s1 = "abc"
s2 = "abcde"
REPEAT
 IF ( NOT ( Ask( "math: get: damerau: levenshtein = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 IF ( NOT ( Ask( "math: get: damerau: levenshtein = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 2
UNTIL FALSE
END

<F12> Main()

// --- LIBRARY --- //

// library: math: get: damerau: levenshtein <description></description> <version>1.0.0.0.26</version> <version control></version control> (filenamemacro=getmadle.s) [<Program>] [<Research>] [kn, ri, th, 08-09-2011 23:04:55]
INTEGER PROC FNMathGetDamerauLevenshteinDistanceI( STRING s1, STRING s2 )
 // e.g. PROC Main()
 // e.g. STRING s1[255] = "arcain"
 // e.g. STRING s2[255] = "arcane"
 // e.g. //
 // e.g. s1 = "arcain"
 // e.g. s2 = "arcane"
 // e.g. Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 2
 // e.g. //
 // e.g. s1 = "algorithm"
 // e.g. s2 = "altruistic"
 // e.g. Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 6
 // e.g. //
 // e.g. s1 = "1638452297"
 // e.g. s2 = "444488444"
 // e.g. Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 9
 // e.g. //
 // e.g. s1 = ""
 // e.g. s2 = ""
 // e.g. Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 0
 // e.g. //
 // e.g. s1 = "aaapppp"
 // e.g. s2 = ""
 // e.g. Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 7
 // e.g. //
 // e.g. s1 = "frog"
 // e.g. s2 = "fog"
 // e.g. Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 1
 // e.g. //
 // e.g. s1 = "fly"
 // e.g. s2 = "ant"
 // e.g. Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 3
 // e.g. //
 // e.g. s1 = "elephant"
 // e.g. s2 = "hippo"
 // e.g. Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 7
 // e.g. //
 // e.g. s1 = "hippo"
 // e.g. s2 = "elephant"
 // e.g. Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 7
 // e.g. //
 // e.g. s1 = "hippo"
 // e.g. s2 = "zzzzzzzz"
 // e.g. Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 8
 // e.g. //
 // e.g. s1 = "hello"
 // e.g. s2 = "hallo"
 // e.g. Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 1
 // e.g. //
 // e.g. s1 = "abc"
 // e.g. s2 = "abcde"
 // e.g. REPEAT
 // e.g.  IF ( NOT ( Ask( "math: get: damerau: levenshtein = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "math: get: damerau: levenshtein = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Warn( "Minimum amount of steps to convert ", s1, " to ", s2, " = ", FNMathGetDamerauLevenshteinDistanceI( s1, s2 ) ) // gives e.g. 2
 // e.g. UNTIL FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // http://rosettacode.org/wiki/Levenshtein_distance#TSE_SAL
 //
 // ===
 //
 INTEGER L1 = Length( s1 )
 //
 INTEGER L2 = Length( s2 )
 //
 INTEGER substitutionCostI = 0
 //
 STRING h1[255] = ""
 STRING h2[255] = ""
 //
 IF ( ( L1 == 0 ) OR ( L2 == 0 ) )
  //
  // Trivial case: one string is 0-length
  //
  RETURN( Max( L1, L2 ) )
  //
 ELSE
  //
  // The cost of substituting the last character
  //
  IF   ( ( s1[ L1 ] ) == ( s2[ L2 ] ) )
   //
   substitutionCostI = 0
   //
  ELSE
   //
   substitutionCostI = 1
   //
  ENDIF
  //
  // h1 and h2 are s1 and s2 with the last character chopped off
  //
  h1 = SubStr( s1, 1,  L1 - 1 )
  //
  h2 = SubStr( s2, 1,  L2 - 1 )
  //
  IF ( ( L1 > 1 ) AND  ( L2 > 1 ) AND  ( s1[ L1 - 0 ] == s2[ L2 - 1 ] ) AND ( s1[ L1 - 1 ] == s2[ L2 - 0 ] ) )
   //
   RETURN( Min( Min( FNMathGetDamerauLevenshteinDistanceI( h1, s2 ) + 1, FNMathGetDamerauLevenshteinDistanceI( s1, h2 ) + 1 ), Min( FNMathGetDamerauLevenshteinDistanceI( h1 , h2 ) + substitutionCostI, FNMathGetDamerauLevenshteinDistanceI( SubStr( s1, 1,  L1 - 2 ), SubStr( s2, 1, L2 - 2 ) ) + 1 ) ) )
   //
  ENDIF
  //
  RETURN( Min( Min( FNMathGetDamerauLevenshteinDistanceI( h1, s2 ) + 1, FNMathGetDamerauLevenshteinDistanceI( s1, h2 ) + 1 ), FNMathGetDamerauLevenshteinDistanceI( h1 ,  h2 ) + substitutionCostI ) )
  //
 ENDIF
 //
END
