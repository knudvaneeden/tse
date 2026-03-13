FORWARD INTEGER PROC FNMathGetMultiple3Or5Below1000I( INTEGER i1, INTEGER i2 )
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 STRING s1[255] = "1"
 STRING s2[255] = "10"
 Warn( FNMathGetMultiple3Or5Below1000I( 1, 1000 ) ) // gives e.g. "233168"
 REPEAT
  IF ( NOT ( Ask( "math: get: multiple3: or5: below1000: minI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
  IF ( NOT ( Ask( "math: get: multiple3: or5: below1000: maxI = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
  Warn( FNMathGetMultiple3Or5Below1000I( Val( s1 ), Val( s2 ) ) ) // gives e.g. "23"
 UNTIL FALSE
END

<F12> Main()

// --- LIBRARY --- //

// library: math: get: multiple3: or5: below1000 <description></description> <version control></version control> <version>1.0.0.0.9</version> <version control></version control> (filenamemacro=getmaobe.s) [<Program>] [<Research>] [kn, ri, su, 27-01-2013 00:10:47]
INTEGER PROC FNMathGetMultiple3Or5Below1000I( INTEGER minI, INTEGER maxI )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "1"
 // e.g.  STRING s2[255] = "10"
 // e.g.  Warn( FNMathGetMultiple3Or5Below1000I( 1, 1000 ) ) // gives e.g. "233168"
 // e.g.  REPEAT
 // e.g.   IF ( NOT ( Ask( "math: get: multiple3: or5: below1000: minI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.   IF ( NOT ( Ask( "math: get: multiple3: or5: below1000: maxI = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.   Warn( FNMathGetMultiple3Or5Below1000I( Val( s1 ), Val( s2 ) ) ) // gives e.g. "23"
 // e.g.  UNTIL FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER sumI = 0
 //
 INTEGER I = 0
 //
 FOR I = minI TO maxI - 1 // make sure you stay below that number, so subtract 1
  //
  IF ( ( I MOD 3 ) == 0 ) OR ( ( I MOD 5 ) == 0 ) // current integer divisible by 3 or divisible by 5? (so leaving a rest of 0)
   //
   sumI = sumI + I // if yes, add that integer to the sum
   //
  ENDIF
  //
 ENDFOR
 //
 RETURN( sumI )
 //
END
