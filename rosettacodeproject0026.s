FORWARD INTEGER PROC FNMathGetAckermannRecursiveI( INTEGER i1, INTEGER i2 )
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
STRING s1[255] = "2"
STRING s2[255] = "3"
IF ( NOT ( Ask( "math: get: ackermann: recursive: m = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
IF ( NOT ( Ask( "math: get: ackermann: recursive: n = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 Message( FNMathGetAckermannRecursiveI( Val( s1 ), Val( s2 ) ) ) // gives e.g. 9
END

<F12> Main()

// --- LIBRARY --- //

// library: math: get: ackermann: recursive <description></description> <version>1.0.0.0.8</version> <version control></version control> (filenamemacro=getmaare.s) [<Program>] [<Research>] [kn, ri, tu, 27-12-2011 14:46:59]
INTEGER PROC FNMathGetAckermannRecursiveI( INTEGER mI, INTEGER nI )
 // e.g. PROC Main()
 // e.g. STRING s1[255] = "2"
 // e.g. STRING s2[255] = "3"
 // e.g. IF ( NOT ( Ask( "math: get: ackermann: recursive: m = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g. IF ( NOT ( Ask( "math: get: ackermann: recursive: n = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Message( FNMathGetAckermannRecursiveI( Val( s1 ), Val( s2 ) ) ) // gives e.g. 9
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // http://rosettacode.org/wiki/Ackermann_function#TSE_SAL
 //
 // ===
 //
 IF ( mI == 0 )
  //
  RETURN( nI + 1 )
  //
 ENDIF
 //
 IF ( nI == 0 )
  //
  RETURN( FNMathGetAckermannRecursiveI( mI - 1, 1 ) )
  //
 ENDIF
 //
 RETURN( FNMathGetAckermannRecursiveI( mI - 1, FNMathGetAckermannRecursiveI( mI, nI - 1 ) ) )
 //
END
