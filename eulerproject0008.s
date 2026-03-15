FORWARD INTEGER PROC FNMathGetNumberConsecutiveDigitMaximumI( INTEGER i1, INTEGER i2, INTEGER i3 )
FORWARD INTEGER PROC FNMathGetNumberMaximumI( INTEGER i1, INTEGER i2 )
FORWARD PROC Main()
FORWARD PROC PROCMathGetNumberConsecutiveDigitMaximumAddLine( INTEGER i1 )


// --- MAIN --- //

PROC Main()
 INTEGER bufferI = 0
 //
 PushPosition()
 bufferI = CreateTempBuffer()
 PopPosition()
 //
 PROCMathGetNumberConsecutiveDigitMaximumAddLine( bufferI )
 //
 Warn( FNMathGetNumberConsecutiveDigitMaximumI( 5, 1000, bufferI ) ) // gives e.g. 40824
END

<F12> Main()

// --- LIBRARY --- //

// library: math: get: number: consecutive: digit: maximum: add: line <description></description> <version control></version control> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getmaali.s) [<Program>] [<Research>] [kn, ri, fr, 01-02-2013 23:23:55]
PROC PROCMathGetNumberConsecutiveDigitMaximumAddLine( INTEGER bufferI )
 // e.g. PROC Main()
 // e.g.  INTEGER bufferI = 0
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  bufferI = CreateTempBuffer()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  PROCMathGetNumberConsecutiveDigitMaximumAddLine( bufferI )
 // e.g.  GotoBufferId( bufferI )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PushPosition()
 //
 GotoBufferId( bufferI )
 //
 InsertText( "73167176531330624919225119674426574742355349194934", _INSERT_ )
 InsertText( "96983520312774506326239578318016984801869478851843", _INSERT_ )
 InsertText( "85861560789112949495459501737958331952853208805511", _INSERT_ )
 InsertText( "12540698747158523863050715693290963295227443043557", _INSERT_ )
 InsertText( "66896648950445244523161731856403098711121722383113", _INSERT_ )
 InsertText( "62229893423380308135336276614282806444486645238749", _INSERT_ )
 InsertText( "30358907296290491560440772390713810515859307960866", _INSERT_ )
 InsertText( "70172427121883998797908792274921901699720888093776", _INSERT_ )
 InsertText( "65727333001053367881220235421809751254540594752243", _INSERT_ )
 InsertText( "52584907711670556013604839586446706324415722155397", _INSERT_ )
 InsertText( "53697817977846174064955149290862569321978468622482", _INSERT_ )
 InsertText( "83972241375657056057490261407972968652414535100474", _INSERT_ )
 InsertText( "82166370484403199890008895243450658541227588666881", _INSERT_ )
 InsertText( "16427171479924442928230863465674813919123162824586", _INSERT_ )
 InsertText( "17866458359124566529476545682848912883142607690042", _INSERT_ )
 InsertText( "24219022671055626321111109370544217506941658960408", _INSERT_ )
 InsertText( "07198403850962455444362981230987879927244284909188", _INSERT_ )
 InsertText( "84580156166097919133875499200524063689912560717606", _INSERT_ )
 InsertText( "05886116467109405077541002256983155200055935729725", _INSERT_ )
 InsertText( "71636269561882670428252483600823257530420752963450", _INSERT_ )
 //
 PopPosition()
 //
END

// library: math: get: number: consecutive: digit: maximum <description></description> <version control></version control> <version>1.0.0.0.7</version> <version control></version control> (filenamemacro=getmadma.s) [<Program>] [<Research>] [kn, ri, fr, 01-02-2013 23:38:22]
INTEGER PROC FNMathGetNumberConsecutiveDigitMaximumI( INTEGER digitConsecutiveMaxI, INTEGER digitMaxI, INTEGER bufferI )
 // e.g. PROC Main()
 // e.g.  INTEGER bufferI = 0
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  bufferI = CreateTempBuffer()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  PROCMathGetNumberConsecutiveDigitMaximumAddLine( bufferI )
 // e.g.  //
 // e.g.  Warn( FNMathGetNumberConsecutiveDigitMaximumI( 5, 1000, bufferI ) ) // gives e.g. 40824
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER productI = 0
 //
 INTEGER productMaxI = -MAXINT
 //
 INTEGER digitMinI = 1
 //
 INTEGER digitConsecutiveMinI = 1
 //
 INTEGER I = 0
 //
 INTEGER J = 0
 //
 INTEGER AI = 0
 //
 PushPosition()
 //
 GotoBufferId( bufferI )
 //
 FOR I = digitMinI TO digitMaxI - digitConsecutiveMaxI
  //
  productI = 1
  //
  FOR J = digitConsecutiveMinI TO digitConsecutiveMaxI
   //
   PushPosition()
   GotoColumn( I + J - 1 )
   AI = Val( Chr( CurrChar() ) )
   PopPosition()
   //
   productI = productI * AI
   //
  ENDFOR
  //
  productMaxI = FNMathGetNumberMaximumI( productI, productMaxI )
  //
 ENDFOR
 //
 PopPosition()
 //
 RETURN( productMaxI )
 //
END

// library: math: get: number: min <description>math: max: determine the maximum of 2 given integer numbers</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getmanmk.s) [<Program>] [<Research>] [kn, ri, sa, 15-09-2012 00:30:42]
INTEGER PROC FNMathGetNumberMaximumI( INTEGER x1, INTEGER x2 )
 // e.g. PROC Main()
 // e.g.  Message( FNMathGetNumberMaximumI( 1, 3 ) ) // gives 3, because 3 is greater than 1
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Max( x1, x2 ) )
 //
END
