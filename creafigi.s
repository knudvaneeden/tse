FORWARD INTEGER PROC FNFileCreateNeuralNetworkGraphvizImageB( STRING s1, INTEGER i1, INTEGER i2, INTEGER i3, INTEGER i4, INTEGER i5, INTEGER i6, INTEGER i7, INTEGER i8, STRING s2, INTEGER i9 )
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 STRING s1[255] = "3"
 STRING s2[255] = "5"
 STRING s3[255] = "5"
 STRING s4[255] = "6"
 STRING s5[255] = "4"
 STRING s6[255] = "0"
 STRING s7[255] = "0"
 //
 STRING s8[255] = "5" // total amount of layers, including the input layer and including the output layer. Count starts from 1.
 //
 STRING s9[255] = "c:\temp\ddd.dot" // change this to an existing path on your system (=Graphviz .dot filename to save the result in).
 //
 STRING s10[255] = "g:\utils\diagram\graphviz\graphviz 2.28\bin\dot.exe" // Change this (=the full path to your GraphViz dot.exe file)
 //
 INTEGER bufferI = 0
 //
 PushPosition()
 bufferI = CreateTempBuffer() // buffer to store the temporary result
 PopPosition()
 //
 IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: layerMaxI = ", s8, _EDIT_HISTORY_ ) ) AND ( Length( s8 ) > 0 ) ) RETURN() ENDIF
 //
 IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max0I = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max1I = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max2I = ", s3, _EDIT_HISTORY_ ) ) AND ( Length( s3 ) > 0 ) ) RETURN() ENDIF
 IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max3I = ", s4, _EDIT_HISTORY_ ) ) AND ( Length( s4 ) > 0 ) ) RETURN() ENDIF
 IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max4I = ", s5, _EDIT_HISTORY_ ) ) AND ( Length( s5 ) > 0 ) ) RETURN() ENDIF
 IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max5I = ", s6, _EDIT_HISTORY_ ) ) AND ( Length( s6 ) > 0 ) ) RETURN() ENDIF
 IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max6I = ", s7, _EDIT_HISTORY_ ) ) AND ( Length( s7 ) > 0 ) ) RETURN() ENDIF
 //
 Message( FNFileCreateNeuralNetworkGraphvizImageB( s9, Val( s8 ), Val( s1 ), Val( s2 ), Val( s3 ), Val( s4 ), Val( s5 ), Val( s6 ), Val( s7 ), s10, bufferI ) ) // gives e.g. TRUE if successful
 //
 GotoBufferId( bufferI )
 MarkLine( 1, NumLines() )
 CopyToWinClip()
 Message( "The resulting GraphViz .dot program has been copied to the Microsoft Windows clipboard. Paste it e.g. in the webpage to see the graph result." )
 //
END

<F12> Main()

// --- LIBRARY --- //

// library: file: create: neural: network: graphviz: image <description></description> <version control></version control> <version>1.0.0.0.27</version> <version control></version control> (filenamemacro=creafigi.s) [<Program>] [<Research>] [kn, ri, mo, 19-02-2018 20:08:51]
INTEGER PROC FNFileCreateNeuralNetworkGraphvizImageB( STRING fileNameS, INTEGER layerMaxI, INTEGER max1I, INTEGER max2I, INTEGER max3I, INTEGER max4I, INTEGER max5I, INTEGER max6I, INTEGER max7I, STRING filenameExecutableS, INTEGER bufferI )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "3"
 // e.g.  STRING s2[255] = "5"
 // e.g.  STRING s3[255] = "5"
 // e.g.  STRING s4[255] = "6"
 // e.g.  STRING s5[255] = "4"
 // e.g.  STRING s6[255] = "0"
 // e.g.  STRING s7[255] = "0"
 // e.g.  //
 // e.g.  STRING s8[255] = "5" // total amount of layers, including the input layer and including the output layer. Count starts from 1.
 // e.g.  //
 // e.g.  STRING s9[255] = "c:\temp\ddd.dot" // change this to an existing path on your system (=Graphviz .dot filename to save the result in).
 // e.g.  //
 // e.g.  STRING s10[255] = "g:\utils\diagram\graphviz\graphviz 2.28\bin\dot.exe" // Change this (=the full path to your GraphViz dot.exe file)
 // e.g.  //
 // e.g.  INTEGER bufferI = 0
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  bufferI = CreateTempBuffer() // buffer to store the temporary result
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: layerMaxI = ", s8, _EDIT_HISTORY_ ) ) AND ( Length( s8 ) > 0 ) ) RETURN() ENDIF
 // e.g.  //
 // e.g.  IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max0I = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max1I = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max2I = ", s3, _EDIT_HISTORY_ ) ) AND ( Length( s3 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max3I = ", s4, _EDIT_HISTORY_ ) ) AND ( Length( s4 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max4I = ", s5, _EDIT_HISTORY_ ) ) AND ( Length( s5 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max5I = ", s6, _EDIT_HISTORY_ ) ) AND ( Length( s6 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "file: create: neural: network: graphviz: image: max6I = ", s7, _EDIT_HISTORY_ ) ) AND ( Length( s7 ) > 0 ) ) RETURN() ENDIF
 // e.g.  //
 // e.g.  Message( FNFileCreateNeuralNetworkGraphvizImageB( s9, Val( s8 ), Val( s1 ), Val( s2 ), Val( s3 ), Val( s4 ), Val( s5 ), Val( s6 ), Val( s7 ), s10, bufferI ) ) // gives e.g. TRUE if successful
 // e.g.  //
 // e.g.  GotoBufferId( bufferI )
 // e.g.  MarkLine( 1, NumLines() )
 // e.g.  CopyToWinClip()
 // e.g.  Message( "The resulting GraphViz .dot program has been copied to the Microsoft Windows clipboard. Paste it e.g. in the webpage to see the graph result." )
 // e.g.  //
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER B = FALSE
 //
 INTEGER I1 = 0
 INTEGER I2 = 0
 INTEGER I3 = 0
 INTEGER I4 = 0
 INTEGER I5 = 0
 INTEGER I6 = 0
 INTEGER I7 = 0
 //
 STRING s[255] = "h"
 //
 STRING s1[255] = "h"
 //
 INTEGER layerI = 1 - 1
 //
 PushPosition()
 //
 GotoBufferId( bufferI )
 //
 IF ( max1I > 0 )
  layerI = layerI + 1
  IF ( layerI == layerMaxI - 1 )
   s1 = "y"
  ENDIF
  FOR I1 = 1 TO max1I
   FOR I2 = 1 TO max2I
    AddLine( Format( "x", I1, " ", "->", " ", s1, "2_", I2, ";" ) )
   ENDFOR
  ENDFOR
 ELSE
  Warn( "you should have more than 0 inputs. Please check." )
  PopPosition()
  B = FALSE
  RETURN( B )
 ENDIF
 //
 IF ( max2I > 0 )
  layerI = layerI + 1
  IF ( layerI == layerMaxI - 1 )
   s1 = "y"
  ENDIF
  FOR I2 = 1 TO max2I
   FOR I3 = 1 TO max3I
    AddLine( Format( s, "2_", I2, " ", "->", " ", s1, "3_", I3, ";" ) )
   ENDFOR
  ENDFOR
 ELSE
  Warn( "you should have more than 0 inputs in the 1st hidden layer. Please check." )
  PopPosition()
  B = FALSE
  RETURN( B )
 ENDIF
 //
 IF ( max3I > 0 )
  layerI = layerI + 1
  IF ( layerI == layerMaxI - 1 )
   s1 = "y"
  ENDIF
  FOR I3 = 1 TO max3I
   FOR I4 = 1 TO max4I
    AddLine( Format( s, "3_", I3, " ", "->", " ", s1, "4_", I4, ";" ) )
   ENDFOR
  ENDFOR
 ENDIF
 //
 IF ( max4I > 0 )
  layerI = layerI + 1
  IF ( layerI == layerMaxI - 1 )
   s1 = "y"
  ENDIF
  FOR I4 = 1 TO max4I
   FOR I5 = 1 TO max5I
    AddLine( Format( s, "4_", I4, " ", "->", " ", s1, "5_", I5, ";" ) )
   ENDFOR
  ENDFOR
 ENDIF
 //
 IF ( max5I > 0 )
  layerI = layerI + 1
  IF ( layerI == layerMaxI - 1 )
   s1 = "y"
  ENDIF
  FOR I5 = 1 TO max5I
   FOR I6 = 1 TO max6I
    AddLine( Format( s, "5_", I5, " ", "->", " ", s1, "6_", I6, ";" ) )
   ENDFOR
  ENDFOR
 ENDIF
 //
 IF ( max6I > 0 )
  layerI = layerI + 1
  IF ( layerI == layerMaxI - 1 )
   s1 = "y"
  ENDIF
  FOR I6 = 1 TO max6I
   FOR I7 = 1 TO max7I
    AddLine( Format( s, "6_", I6, " ", "->", " ", s1, "7_", I7, ";" ) )
   ENDFOR
  ENDFOR
 ENDIF
 //
 GotoBufferId( bufferI )
 //
 BegFile()
 InsertLine( "digraph G {" )
 AddLine( "//" )
 AddLine( 'size="7, 7!"; landscape=true' )
 AddLine( "//" )
 //
 EndFile()
 AddLine( "}" )
 //
 IF EditFile( fileNameS )
  AbandonFile()
 ENDIF
 //
 GotoBufferId( bufferI )
 SaveAs( fileNameS, _OVERWRITE_ )
 //
 StartPgm( "http://www.webgraphviz.com/" ) // copy/paste the .dot file result here to see the graphical representation
 // StartPgm( fileNameExecutableS, fileNameS ) // run this .dot file. You will have to handle the running of the .dot file further on your system.
 // Dos( Format( fileNameExecutableS, " ", QuotePath( fileNameS ) ) ) // run this .dot file
 // PROCFileRun4NtAliasCommandListUser( Format( "dot", " ", QuotePath( fileNameS ) ) ) // run this .dot file
 //
 B = TRUE
 //
 PopPosition()
 //
 RETURN( B )
 //
END
