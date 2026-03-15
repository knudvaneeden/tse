FORWARD INTEGER PROC FNMathGetNumberPythagorasTripletProductI( INTEGER i1 )
FORWARD INTEGER PROC FNMathGetSquareRootI( INTEGER i1 )
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 Warn( FNMathGetNumberPythagorasTripletProductI( 12 ) ) // e.g. gives 60 (=3 * 4 * 5)
 Warn( FNMathGetNumberPythagorasTripletProductI( 1000 ) ) // e.g. gives 31875000 (=200 * 375 * 425)
END

<F12> Main()

// --- LIBRARY --- //

// library: math: get: number: pythagoras: triplet: product <description></description> <version control></version control> <version>1.0.0.0.4</version> <version control></version control> (filenamemacro=getmatpr.s) [<Program>] [<Research>] [kn, ri, fr, 01-02-2013 23:59:30]
INTEGER PROC FNMathGetNumberPythagorasTripletProductI( INTEGER sumI )
 // e.g. PROC Main()
 // e.g.  Warn( FNMathGetNumberPythagorasTripletProductI( 12 ) ) // e.g. gives 60 (=3 * 4 * 5)
 // e.g.  Warn( FNMathGetNumberPythagorasTripletProductI( 1000 ) ) // e.g. gives 31875000 (=200 * 375 * 425)
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // Method: Brute force: Just check all possible integer triples between a given range
 //
 INTEGER minI = 1
 INTEGER maxI = 0
 INTEGER I = 0
 //
 INTEGER minJ = 1
 INTEGER maxJ
 INTEGER J
 //
 INTEGER minK = 1
 INTEGER maxK = 0
 INTEGER K = 0
 //
 INTEGER foundB = FALSE
 //
 INTEGER productI = 0
 //
 // This is just guess, in order to reduce the total possibilities.
 // First starting with sumI. But that took a long time.
 // Then changing it to square root of sumI. But that was too little.
 // Then enlarging successively until found.
 //
 // An upper bound would be to give each counter the value of totalI.
 // Then for sure you should find it always
 // Because the value for each counter must be between 1 and sumI
 // (that is dictated by the 'triangle inequality' rule (a + b <= c)).
 //
 maxI = 20 * FNMathGetSquareRootI( sumI )
 maxJ = 20 * FNMathGetSquareRootI( sumI )
 maxK = 20 * FNMathGetSquareRootI( sumI )
 //
 I = minI - 1
 //
 REPEAT
  //
  I = I + 1
  //
  J = minJ - 1
  //
  REPEAT
   //
   J = J + 1
   //
   K = minK - 1
   //
   REPEAT
    //
    K = K + 1
    //
    foundB = ( I * I + J * J == K * K ) AND ( ( I + J + K ) == sumI )
    //
   UNTIL ( K >= maxK ) OR ( foundB )
   //
  UNTIL ( J >= maxJ ) OR ( foundB )
  //
 UNTIL ( I >= maxI ) OR ( foundB )
 //
 IF ( foundB )
  //
  Warn( I, " ", J, " ", K )
  //
  productI = I * J * K
  //
 ELSE
  //
  Warn( "not found" )
  //
  productI = 0
  //
 ENDIF
 //
 RETURN( productI )
 //
END

// library: math: get: square: root <author>original from Carlo Hogeveen</author> <description>This will return the integer square root of a given integer</description> <version control></version control> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=getmasro.s) [<Program>] [<Research>] [kn, ri, su, 30-12-2012 22:26:47]
INTEGER PROC FNMathGetSquareRootI( INTEGER xI )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "25"
 // e.g.  IF ( NOT ( Ask( "math: get: square: root: xI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Message( FNMathGetSquareRootI( Val( s1 ) ) ) // gives e.g. "5"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER squareRootI = 0
 //
 IF ( xI > 0 )
  //
  WHILE( ( squareRootI * squareRootI ) <= xI )
   //
   squareRootI = squareRootI + 1
   //
  ENDWHILE
  //
  squareRootI = squareRootI - 1
  //
 ENDIF
 //
 RETURN( squareRootI )
 //
END
