FORWARD INTEGER PROC FNMathCheckIntegerIsPrimeB( INTEGER i1 )
FORWARD INTEGER PROC FNMathGetSquareRootI( INTEGER i1 )
FORWARD PROC Main()
FORWARD STRING PROC FNStringGetMathAddIntegerTwoS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetMathIntegerPrimeFirstSumS( INTEGER i1 )


// --- MAIN --- //

PROC Main()
 STRING s1[255] = "1999999" // = 2000000 - 1 = below 2 million // gives e.g. 142913828922
 IF ( NOT ( Ask( "string: get: math: integer: prime: first: sum: maxI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 Warn( FNStringGetMathIntegerPrimeFirstSumS( Val( s1 ) ) ) // chosing 10 gives e.g. 17 (=2 + 3 + 5 + 7)
END

<F12> Main()

// --- LIBRARY --- //

// library: string: get: math: integer: prime: first: sum <description></description> <version control></version control> <version>1.0.0.0.8</version> <version control></version control> (filenamemacro=getstfsx.s) [<Program>] [<Research>] [kn, ri, sa, 02-02-2013 00:16:46]
STRING PROC FNStringGetMathIntegerPrimeFirstSumS( INTEGER maxI )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "1999999" // = 2000000 - 1 = below 2 million // gives e.g. 142913828922
 // e.g.  IF ( NOT ( Ask( "string: get: math: integer: prime: first: sum: maxI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Warn( FNStringGetMathIntegerPrimeFirstSumS( Val( s1 ) ) ) // chosing 10 gives e.g. 17 (=2 + 3 + 5 + 7)
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER minI = 1
 //
 INTEGER I = 0
 //
 STRING s[255] = "0"
 //
 FOR I = minI TO maxI
  //
  IF ( FNMathCheckIntegerIsPrimeB( I ) )
   //
   s = FNStringGetMathAddIntegerTwoS( Str( I ), s )
   //
  ENDIF
  //
 ENDFOR
 //
 RETURN( s )
 //
END

// library: math: check: integer: is: prime <description></description> <version control></version control> <version>1.0.0.0.12</version> <version control></version control> (filenamemacro=checmaiu.s) [<Program>] [<Research>] [kn, ri, mo, 31-12-2012 00:12:15]
INTEGER PROC FNMathCheckIntegerIsPrimeB( INTEGER nI )
 // e.g. PROC Main()
 // e.g. STRING s1[255] = "127"
 // e.g. IF ( NOT ( Ask( "math: check: integer: is: prime: nI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Message( FNMathCheckIntegerIsPrimeB( Val( s1 ) ) ) // gives e.g. TRUE when chosen number is a prime number
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER I = 0
 //
 INTEGER primeB = FALSE
 //
 INTEGER stopB = FALSE
 //
 INTEGER restI = 0
 //
 INTEGER limitI = 0
 //
 // Method: Brute force division: Sieve of Eratosthenes
 //
 // You check if the given number has any divisors other than itself
 // If it has, then by definition it is not a prime number, otherwise it is a prime number
 //
 // You divide by an ever increasing divisor, until you reach the square root of the given number
 // After that you can just stop, because you will only repeat yourself
 //
 // To work about twice at fast, you just have to use odd divisors (3, 5, 7, 9, 11, ...),
 // and you skip thus the even divisors (2, 4, 6, 8, ...)
 //
 // It should work for integer number smaller or equal to MAXINT (which is 2^31 - 1 = 2147483647)
 //
 primeB = FALSE
 //
 // nI must be a positive integer
 IF ( nI <= 0 )
  //
  RETURN( FALSE )
  //
 ENDIF
 //
 // 1 is per definition not a prime number
 IF ( nI == 1 )
  //
  RETURN( FALSE )
  //
 ENDIF
 //
 // 2 is a prime number
 IF ( nI == 2 )
  //
  RETURN( TRUE )
  //
 ENDIF
 //
 // 3 is a prime number
 IF ( nI == 3 )
  //
  RETURN( TRUE )
  //
 ENDIF
 //
 // any even number greater than 2 is not a prime number (because it is divisible, in this case by 2).
 // You check if it is an even number, by dividing by 2. That leaves a rest 0 in case of an even number.
 IF ( nI MOD 2 == 0 )
  //
  RETURN( FALSE )
  //
 ENDIF
 //
 // if the given number is not of the type 6 n - 1 or 6 n + 1 (thus the pairs 5,7 11,13 17,19, ...) it is not prime.
 // For the primes greater than 3, no exceptions to this rule have been found yet
 IF ( ( nI MOD 6 ) <> 1 ) AND ( ( nI MOD 6 ) <> 5 )
  //
  RETURN( FALSE )
  //
 ENDIF
 //
 // So from here on you are only dealing with odd numbers (greater than 1). Alltogether (3), 5, 7, ...
 //
 // determine to where the divisor should run, in this case that is the square root of the given number
 //
 limitI = FNMathGetSquareRootI( nI )
 //
 // start with a divisor equal to 3
 //
 I = 3
 //
 REPEAT
  //
  // get the rest of dividing the given number by the current divisor (3, 5, 7, 9, 11, 13, ...)
  restI = ( nI MOD I )
  //
  // if it is divisible (thus a rest of 0), then it is per definition no prime number. Thus return false
  IF ( restI == 0 )
   //
   primeB = FALSE
   //
   stopB = TRUE
   //
  ENDIF
  //
  // if you reach the square root of the given number, then you can stop, as the divisors will switch symmetrically, and there would just be repetition (e.g. 3 * 5 = 5 * 3 = 15). Then it is a prime.
  //
  // To calculate if you have reached the square root:
  // -you multiply the divisor with itself, and check if it is greater than the given number IF ( I * I > nI)
  // -or completely equivalent, check if the divisor is greater than the square root of the given number
  // If yes, you stop.
  //
  IF ( I > limitI )
   //
   primeB = TRUE
   //
   stopB = TRUE
   //
  ENDIF
  //
  // create the successive next odd numbers (3, 5, 7, 9, 11, 13, ...) to test the division with.
  // You only have to divide by an odd number.
  // This because any given divisible odd number can always be written as an odd number times an odd number (e.g. 9 = 3 . 3, 15 = 5 . 3, 21 = 3 . 7, Thus odd = odd . odd
  // So only testing always using the odd number as a divisor.
  // If divisible it should leave an integer odd number.
  // Thus the rest of such a division will be 0.
  // So you never have to test dividing with an even number, because then you know for sure the given odd number is not divisible by it, and will leave a fraction. As odd / even gives fraction. Only odd / odd gives no fraction.
  //
  I = I + 2
  //
 UNTIL ( stopB )
 //
 RETURN( primeB )
 //
END

// library: string: get: math: add: integer: two <description></description> <version control></version control> <version>1.0.0.0.5</version> (filenamemacro=getstitw.s) [<Program>] [<Research>] [kn, ri, th, 22-01-2004 03:06:41]
STRING PROC FNStringGetMathAddIntegerTwoS( STRING in1S, STRING in2S )
 // e.g. PROC Main()
 // e.g. STRING s1[255] = "90"
 // e.g. STRING s2[255] = "1"
 // e.g.  Warn( FNStringGetMathAddIntegerTwoS( "3135814134123999", "513123413134123412341412342" ) ) // gives "513123413137259226475536341"
 // e.g.  Warn( FNStringGetMathAddIntegerTwoS( "12341234123413413241", "99897123412341234123412341341234" ) ) // gives "99897123412353575357535754754475"
 // e.g.  REPEAT
 // e.g.   IF ( NOT ( Ask( "string: get: math: add: integer: two: in1S = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.   IF ( NOT ( Ask( "string: get: math: add: integer: two: in2S = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.   Warn( FNStringGetMathAddIntegerTwoS( s1, s2 ) ) // gives e.g. "91"
 // e.g.  UNTIL FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER restI = 0
 //
 INTEGER lengthminI = 0
 //
 INTEGER lengthmaxI = 0
 //
 INTEGER sumI = 0
 //
 INTEGER I = 0
 //
 INTEGER J = 0
 //
 STRING sumS[255] = ""
 //
 STRING minS[255] = ""
 //
 STRING maxS[255] = ""
 //
 STRING cminS[1] = ""
 //
 STRING cmaxS[1] = ""
 //
 IF Length( in1S ) < Length( in2S )
  //
  minS = in1S
  //
  maxS = in2S
  //
 ELSE
  //
  minS = in2S
  //
  maxS = in1S
  //
 ENDIF
 //
 lengthminI = Length( minS )
 //
 lengthmaxI = Length( maxS )
 //
 FOR I = 1 TO lengthmaxI
  //
  J = lengthminI - I + 1
  //
  IF J > 0
   //
   cminS = minS[ J ]
   //
  ELSE
   //
   cminS = "0"
   //
  ENDIF
  //
  cmaxS = maxS[ lengthmaxI - I + 1 ]
  //
  sumI = Val( cmaxS ) + Val( cminS ) + restI
  //
  IF sumI > 9 AND ( I <> lengthmaxI )
   //
   restI = sumI / ( 9 + 1 )
   //
   sumI = sumI MOD ( 9 + 1 )
   //
  ELSE
   //
   restI = 0
   //
  ENDIF
  //
  sumS = Str( sumI ) + sumS
  //
 ENDFOR
 //
 RETURN( sumS )
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
