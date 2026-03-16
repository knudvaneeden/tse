FORWARD INTEGER PROC FNMathGetGreatestCommonDivisorI( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathGetLeastCommonMultipleI( INTEGER i1, INTEGER i2 )
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 // STRING s1[255] = "2"
 // STRING s2[255] = "13"
 //
 // STRING s1[255] = "1231232"
 // STRING s2[255] = "1234"
 //
 STRING s1[255] = "10"
 STRING s2[255] = "20"
 REPEAT
  IF ( NOT ( Ask( "math: get: least: common: multiple: x1I = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
  IF ( NOT ( Ask( "math: get: least: common: multiple: x2I = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
  Warn( FNMathGetLeastCommonMultipleI( Val( s1 ), Val( s2 ) ) ) // gives e.g. 10
 UNTIL FALSE
END

<F12> Main()

// --- LIBRARY --- //

// library: math: get: least: common: multiple <description></description> <version control></version control> <version>1.0.0.0.4</version> <version control></version control> (filenamemacro=getmacmu.s) [<Program>] [<Research>] [kn, ri, su, 20-01-2013 14:36:11]
INTEGER PROC FNMathGetLeastCommonMultipleI( INTEGER x1I, INTEGER x2I )
 // e.g. PROC Main()
 // e.g.  // STRING s1[255] = "2"
 // e.g.  // STRING s2[255] = "13"
 // e.g.  //
 // e.g.  // STRING s1[255] = "1231232"
 // e.g.  // STRING s2[255] = "1234"
 // e.g.  //
 // e.g.  STRING s1[255] = "10"
 // e.g.  STRING s2[255] = "20"
 // e.g.  REPEAT
 // e.g.   IF ( NOT ( Ask( "math: get: least: common: multiple: x1I = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.   IF ( NOT ( Ask( "math: get: least: common: multiple: x2I = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.   Warn( FNMathGetLeastCommonMultipleI( Val( s1 ), Val( s2 ) ) ) // gives e.g. 10
 // e.g.  UNTIL FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // http://rosettacode.org/wiki/Least_common_multiple#TSE_SAL
 //
 // ===
 //
 RETURN( x1I * x2I / FNMathGetGreatestCommonDivisorI( x1I, x2I ) )
 //
END

// library: math: get: greatest: common: divisor <description>greatest common divisor whole numbers. Euclid's algorithm. Recursive version</description> <version control></version control> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=getmacdi.s) [<Program>] [<Research>] [kn, ri, su, 20-01-2013 14:22:41]
INTEGER PROC FNMathGetGreatestCommonDivisorI( INTEGER x1I, INTEGER x2I )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "353"
 // e.g.  STRING s2[255] = "46"
 // e.g.  REPEAT
 // e.g.   IF ( NOT ( Ask( "math: get: greatest: common: divisor: x1I = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.   IF ( NOT ( Ask( "math: get: greatest: common: divisor: x2I = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.   Warn( FNMathGetGreatestCommonDivisorI( Val( s1 ), Val( s2 ) ) ) // gives e.g. 1
 // e.g.  UNTIL FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // http://rosettacode.org/wiki/Greatest_common_divisor#TSE_SAL
 //
 // ===
 //
 IF ( x2I == 0 )
  //
  RETURN( x1I )
  //
 ENDIF
 //
 RETURN( FNMathGetGreatestCommonDivisorI( x2I, x1I MOD x2I ) )
 //
END
