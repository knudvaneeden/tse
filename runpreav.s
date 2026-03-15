FORWARD PROC Main()
FORWARD STRING PROC FNProgramRunProjectEulerAllS()
FORWARD STRING PROC FNStringGetErrorS()


// --- MAIN --- //

PROC Main()
 Message( FNProgramRunProjectEulerAllS() ) // gives e.g. ...""
END

<Ctrl F12> Main()

// --- LIBRARY --- //

// library: program: run: project: euler: all <description></description> <version control></version control> <version>1.0.0.0.8</version> <version control></version control> (filenamemacro=runpreav.s) [<Program>] [<Research>] [kn, ri, su, 15-03-2026 14:42:23]
STRING PROC FNProgramRunProjectEulerAllS()
 // e.g. PROC Main()
 // e.g.  Message( FNProgramRunProjectEulerAllS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <Ctrl F12> Main()
 //
 // ===
 //
 // Use case =
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 // ===
 //
 // ===
 //
 // Example:
 //
 // Input:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // ===
 //
 // e.g. // QuickHelp( HELPDEFFNProgramRunProjectEulerAllS )
 // e.g. HELPDEF HELPDEFFNProgramRunProjectEulerAllS
 // e.g.  title = "FNProgramRunProjectEulerAllS() help" // The help's caption
 // e.g.  x = 100 // Location
 // e.g.  y = 3 // Location
 // e.g.  //
 // e.g.  // The actual help text
 // e.g.  //
 // e.g.  "Usage:"
 // e.g.  "//"
 // e.g.  "1. Run this TSE macro"
 // e.g.  "2. Then press <CtrlAlt F1> to show this help."
 // e.g.  "3. Press <Shift Escape> to quit."
 // e.g.  "//"
 // e.g.  ""
 // e.g.  "Key: Definitions:"
 // e.g.  ""
 // e.g.  "<> = do something"
 // e.g. END
 //
 STRING s[255] = ""
 //
  INTEGER bufferI = 0
 //
 PushPosition()
 bufferI = CreateTempBuffer()
 PopPosition()
 //
 PushPosition()
 PushBlock()
 //
 GotoBufferId( bufferI )
 //
 AddLine( "------------------------------------------------------------------" )
 AddLine( "+EULER: PROJECT" )
 AddLine( "------------------------------------------------------------------" )
 AddLine( "1  Multiples of 3 or 5                        " )
 AddLine( "2  Even Fibonacci Numbers                     " )
 AddLine( "3  Largest Prime Factor                       " )
 AddLine( "4  Largest Palindrome Product                 " )
 AddLine( "5  Smallest Multiple                          " )
 AddLine( "6  Sum Square Difference                      " )
 AddLine( "7  10 001st Prime                             " )
 AddLine( "8  Largest Product in a Series                " )
 AddLine( "9  Special Pythagorean Triplet                " )
 AddLine( "10 Summation of Primes                        " )
 AddLine( "11 Largest Product in a Grid                  " )
 AddLine( "12 Highly Divisible Triangular Number         " )
 AddLine( "13 Large Sum                                  " )
 AddLine( "14 Longest Collatz Sequence                   " )
 AddLine( "15 Lattice Paths                              " )
 AddLine( "16 Power Digit Sum                            " )
 AddLine( "17 Number Letter Counts                       " )
 AddLine( "18 Maximum Path Sum I                         " )
 AddLine( "19 Counting Sundays                           " )
 AddLine( "20 Factorial Digit Sum                        " )
 AddLine( "21 Amicable Numbers                           " )
 AddLine( "22 Names Scores                               " )
 AddLine( "23 Non-Abundant Sums                          " )
 AddLine( "24 Lexicographic Permutations                 " )
 AddLine( "25 1000-digit Fibonacci Number                " )
 AddLine( "26 Reciprocal Cycles                          " )
 AddLine( "27 Quadratic Primes                           " )
 AddLine( "28 Number Spiral Diagonals                    " )
 AddLine( "29 Distinct Powers                            " )
 AddLine( "30 Digit Fifth Powers                         " )
 AddLine( "31 Coin Sums                                  " )
 AddLine( "32 Pandigital Products                        " )
 AddLine( "33 Digit Cancelling Fractions                 " )
 AddLine( "34 Digit Factorials                           " )
 AddLine( "35 Circular Primes                            " )
 AddLine( "36 Double-base Palindromes                    " )
 AddLine( "37 Truncatable Primes                         " )
 AddLine( "38 Pandigital Multiples                       " )
 AddLine( "39 Integer Right Triangles                    " )
 AddLine( "40 Champernowne's Constant                    " )
 AddLine( "41 Pandigital Prime                           " )
 AddLine( "42 Coded Triangle Numbers                     " )
 AddLine( "43 Sub-string Divisibility                    " )
 AddLine( "44 Pentagon Numbers                           " )
 AddLine( "45 Triangular, Pentagonal, and Hexagonal      " )
 AddLine( "46 Goldbach's Other Conjecture                " )
 AddLine( "47 Distinct Primes Factors                    " )
 AddLine( "48 Self Powers                                " )
 AddLine( "49 Prime Permutations                         " )
 AddLine( "50 Consecutive Prime Sum                      " )
 AddLine( "------------------------------------------------------------------" )
 //
 GotoLine( 1 )
 IF List( "Choose an option", 80 )
  s = Trim( GetText( 1, MAXSTRINGLEN ) )
 ELSE
  AbandonFile( bufferI )
  PopBlock()
  PopPosition()
  RETURN( FNStringGetErrorS() )
 ENDIF
 AbandonFile( bufferI )
 PopBlock()
 PopPosition()
 //
 s = GetToken( s, " ", 1 )
 s = Trim( s )
 //
 StartPgm( Format( "https://projecteuler.net/problem=", s ) )
 //
 s = Format( "eulerproject", Format( s : 4 : "0" ) )
 ExecMacro( s )
 //
 RETURN( s )
 //
END

// library: string: get: error <description>general output string to recognize an error (e.g. in another routine). Central routine, only one occurrence of this constant string</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getstger.s) [<Program>] [<Research>] [kn, ri, sa, 05-12-1998 20:58:17]
STRING PROC FNStringGetErrorS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetErrorS() ) // gives e.g. "<ERROR>"
 // e.g. END
 //
 RETURN( "<ERROR>" )
 //
END
