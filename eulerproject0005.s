FORWARD INTEGER PROC FNMathGetSmallestMultipleI( INTEGER i1, INTEGER i2 )
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 STRING s1[255] = "1"
 STRING s2[255] = "10"
 // Warn( "Please be patient, this will take a few minutes" )
 // Warn( FNMathGetSmallestMultipleI( 1, 20 ) ) // gives e.g. "232792560"
 REPEAT
  IF ( NOT ( Ask( "math: get: smallest: multiple: minI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
  IF ( NOT ( Ask( "math: get: smallest: multiple: maxI = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
  Warn( FNMathGetSmallestMultipleI( Val( s1 ), Val( s2 ) ) ) // gives e.g. "2520"
 UNTIL FALSE
END

<F12> Main()

// --- LIBRARY --- //

// library: math: get: smallest: multiple <description></description> <version control></version control> <version>1.0.0.0.5</version> <version control></version control> (filenamemacro=getmasmu.s) [<Program>] [<Research>] [kn, ri, su, 27-01-2013 01:50:28]
INTEGER PROC FNMathGetSmallestMultipleI( INTEGER minI, INTEGER maxI )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "1"
 // e.g.  STRING s2[255] = "10"
 // e.g.  // Warn( "Please be patient, this will take a few minutes" )
 // e.g.  // Warn( FNMathGetSmallestMultipleI( 1, 20 ) ) // gives e.g. "232792560"
 // e.g.  REPEAT
 // e.g.   IF ( NOT ( Ask( "math: get: smallest: multiple: minI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.   IF ( NOT ( Ask( "math: get: smallest: multiple: maxI = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.   Warn( FNMathGetSmallestMultipleI( Val( s1 ), Val( s2 ) ) ) // gives e.g. "2520"
 // e.g.  UNTIL FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER I = 1 - 1
 //
 INTEGER J = 0
 //
 INTEGER B = FALSE
 //
 REPEAT
  //
  I = I + 1
  //
  B = FALSE
  //
  J = minI - 1
  //
  REPEAT
   //
   J = J + 1
   //
   B = ( ( I MOD J ) == 0 ) // is current value of I divisible by the current value of J? (thus rest equal to 0)
   //
  UNTIL ( ( J >= maxI ) OR ( NOT ( B ) ) ) // stop if max reached or number can not be divided with zero rest
  //
 UNTIL ( B ) // stop if number can be divided by all numbers between min and max with zero rest
 //
 RETURN( I )
 //
END
