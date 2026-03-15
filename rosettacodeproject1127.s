FORWARD PROC Main()
FORWARD PROC PROCMathCreateArraySpiralOutwards( INTEGER i1 )


// --- MAIN --- //

PROC Main()
STRING s1[255] = "3"
IF ( NOT ( Ask( "math: create: array: spiral: outwards: nI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 PROCMathCreateArraySpiralOutwards( Val( s1 ) )
END

<F12> Main()

// --- LIBRARY --- //

// library: math: create: array: spiral: outwards <description></description> <version control></version control> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=creamaso.s) [<Program>] [<Research>] [kn, ri, mo, 31-12-2012 01:59:50]
PROC PROCMathCreateArraySpiralOutwards( INTEGER nI )
 // e.g. PROC Main()
 // e.g. STRING s1[255] = "3"
 // e.g. IF ( NOT ( Ask( "math: create: array: spiral: outwards: nI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  PROCMathCreateArraySpiralOutwards( Val( s1 ) )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER columnEndI = 0
 //
 INTEGER columnBeginI = nI - 1
 //
 INTEGER rowEndI = 0
 //
 INTEGER rowBeginI = nI - 1
 //
 INTEGER columnI = 0
 //
 INTEGER rowI = 0
 //
 INTEGER minI = 0
 INTEGER maxI = nI * nI - 1
 INTEGER I = 0
 //
 INTEGER columnWidthI = Length( Str( nI * nI - 1 ) ) + 1
 //
 INTEGER directionRightI = 0
 INTEGER directionLeftI = 1
 INTEGER directionDownI = 2
 INTEGER directionUpI = 3
 //
 INTEGER directionI = directionRightI
 //
 FOR I = maxI DOWNTO minI
  //
  // SetGlobalInt( Format( "MatrixS", columnI, ",", rowI ), I )
  SetGlobalInt( Format( "MatrixS", columnI, ",", rowI ), I + 1 )
  //
  // PutStrXY( ( Query( ScreenCols ) / 8 ) + columnI * columnWidthI, ( Query( ScreenRows ) / 8 ) + rowI, Str( I ), Color( BRIGHT RED ON WHITE ) )
  PutStrXY( ( Query( ScreenCols ) / 8 ) + columnI * columnWidthI, ( Query( ScreenRows ) / 8 ) + rowI, Str( I + 1 ), Color( BRIGHT RED ON WHITE ) )
  //
  CASE directionI
   //
   WHEN directionRightI
    //
    IF ( columnI < columnBeginI )
     //
     columnI = columnI + 1
     //
    ELSE
     //
     directionI = directionDownI
     //
     rowI = rowI + 1
     //
     rowEndI = rowEndI + 1
     //
    ENDIF
    //
   WHEN directionDownI
    //
    IF ( rowI < rowBeginI )
     //
     rowI = rowI + 1
     //
    ELSE
     //
     directionI = directionLeftI
     //
     columnI = columnI - 1
     //
     columnBeginI = columnBeginI - 1
     //
    ENDIF
    //
   WHEN directionLeftI
    //
    IF ( columnI > columnEndI )
     //
     columnI = columnI - 1
     //
    ELSE
     //
     directionI = directionUpI
     //
     rowI = rowI - 1
     //
     rowBeginI = rowBeginI - 1
     //
    ENDIF
    //
   WHEN directionUpI
    //
    IF ( rowI > rowEndI )
     //
     rowI = rowI - 1
     //
    ELSE
     //
     directionI = directionRightI
     //
     columnI = columnI + 1
     //
     columnEndI = columnEndI + 1
     //
    ENDIF
    //
   OTHERWISE
    //
    Warn( Format( "PROCGraphCreatePrimeSpiralUlam(", " ", "case", " ", ":", " ", Str( directionI ), ": not known" ) )
    //
    RETURN()
    //
  ENDCASE
  //
 ENDFOR
 //
END

