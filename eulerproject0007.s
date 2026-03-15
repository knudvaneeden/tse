FORWARD INTEGER PROC FNMathCheckIntegerIsPrimeB( INTEGER i1 )
FORWARD INTEGER PROC FNMathGetIntegerPrimeNI( INTEGER i1 )
FORWARD INTEGER PROC FNMathGetSquareRootI( INTEGER i1 )
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 STRING s1[255] = "10001" // gives e.g. 104743
 REPEAT
  IF ( NOT ( Ask( "math: get: integer: prime: n: maxI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
  Warn( FNMathGetIntegerPrimeNI( Val( s1 ) ) )
 UNTIL FALSE
END

<F12> Main()

// --- LIBRARY --- //

// library: math: get: integer: prime: n <description></description> <version control></version control> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=getmapo.s) [<Program>] [<Research>] [kn, ri, fr, 01-02-2013 22:56:12]
INTEGER PROC FNMathGetIntegerPrimeNI( INTEGER maxI )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "10001" // gives e.g. 104743
 // e.g.  REPEAT
 // e.g.   IF ( NOT ( Ask( "math: get: integer: prime: n: maxI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.   Warn( FNMathGetIntegerPrimeNI( Val( s1 ) ) )
 // e.g.  UNTIL FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER minI = 0
 //
 INTEGER I = 0
 //
 INTEGER J = 0
 //
 I = minI - 1
 //
 REPEAT
 //
 I = I + 1
  //
  IF ( FNMathCheckIntegerIsPrimeB( I ) )
   //
   J = J + 1
   //
  ENDIF
  //
 UNTIL ( J >= maxI )
 //
 RETURN( I )
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
