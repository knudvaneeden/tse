FORWARD INTEGER PROC FNBlockCheckCurrentIsMarkedB()
FORWARD INTEGER PROC FNBlockCheckIsMarkedNotCurrentDefaultMessageB()
FORWARD INTEGER PROC FNBlockCheckIsMarkedNotCurrentMessageB( STRING s1 )
FORWARD INTEGER PROC FNBlockGetCurrentMarkedTypeI()
FORWARD INTEGER PROC FNBlockInsertColumnCharacterEqualLeftVerticalAllB( INTEGER i1, INTEGER i2, INTEGER i3, INTEGER i4 )
FORWARD INTEGER PROC FNBlockInsertColumnCharacterEqualRightVerticalAllB( INTEGER i1, INTEGER i2, INTEGER i3, INTEGER i4 )
FORWARD INTEGER PROC FNMathCheckLogicNotB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheckNumberEqualB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathCheckNumberEqualZeroB( INTEGER i1 )
FORWARD PROC Main()
FORWARD PROC PROCBlockInsertColumnCharacterEqualVerticalAll()
FORWARD PROC PROCWarn( STRING s1 )


// --- MAIN --- //

PROC Main()
 PROCBlockInsertColumnCharacterEqualVerticalAll()
END

<F12> Main()

// --- LIBRARY --- //

// library: block: insert: column: character: equal: vertical: all <description></description> <version>1.0.0.0.242</version> (filenamemacro=inseblea.s) [kn, ri, sa, 25-09-2010 22:46:46]
PROC PROCBlockInsertColumnCharacterEqualVerticalAll()
 // e.g. PROC Main()
 // e.g.  PROCBlockInsertColumnCharacterEqualVerticalAll()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // Description:
 //
 // When you click with your mouse on the right of the block, it will add simultaneously the same character  over the length of the whole vertical right column.
 // Similar, if you click with your mouse on the left of the block, it will add simultaneously the same character over the length of the whole vertical left column.
 //
 // ===
 //
 // To quit, press <Escape>
 //
 // ===
 //
 // The current version is an alpha version, but should do *most of the time* the desired actions.
 // Use e.g. Undo() (e.g. <Ctrl><Z>) or <BackSpace> to undo any of your changes, when applicable.
 //
 // ===
 //
 // Method:
 //
 // -I have split it in two actions, left or right.
 //
 //   Because right and left actions are not (e.g. mirror) symmetrical in this case, as far as I can tell currently.
 //   Otherwise I would maybe have mixed them together.
 //   For example if you insert right, then the block has to be repainted one position to the right.
 //   While if you insert left, the block should stay in the same position.
 //
 //   Trying to make the program much shorter, I played also a bit with e.g. MoveBlock()
 //   (idea: move the block, then insert a vertical 1 character block at begin column or end column)
 //   but that did not exactly what was wanted here (MoveBlock() pushes columns aside, what is not wanted here),
 //   so I abandoned that and went back to my original approach below.
 //
 //  1. filling the text on the left of the column
 //
 //     -Create a vertical block of 1 character wide, and use FillBlock() to fill it with the currently typed character
 //     -Goto first line and first column of block
 //     -Paste insert it in the text
 //     -Increase the horizontal position counter
 //     -Move boundaries of the block one position to the right (using that counter)
 //     -Repaint the block at the new position)
 //
 //  2. filling the text on the right of the column
 //
 //     -Create a vertical block of 1 character wide, and use FillBlock() to fill it with the currently typed character
 //     -Goto first line and last column of block
 //     -Paste insert it in the text
 //     -Increase the horizontal position counter and insert next character column there
 //
 INTEGER quitB = FALSE
 //
 INTEGER blockLineBeginI = 0
 INTEGER blockLineEndI = 0
 INTEGER blockColumnBeginI = 0
 INTEGER blockColumnEndI = 0
 //
 IF FNBlockCheckIsMarkedNotCurrentDefaultMessageB() RETURN() ENDIF // return from the current procedure if no block is marked
 //
 Message( "Equal characters inserted around block (press <ESC> at any time to cancel)" )
 //
 REPEAT
  //
  blockLineBeginI = Query( BlockBegLine )
  blockLineEndI = Query( BlockEndLine )
  blockColumnBeginI = Query( BlockBegCol )
  blockColumnEndI = Query( BlockEndCol )
  //
  IF ( Query( MouseX ) >= ( blockColumnEndI + blockColumnBeginI ) / 2 )
   //
   GotoBlockBegin()
   //
   GotoColumn( blockColumnEndI )
   //
   quitB = FNBlockInsertColumnCharacterEqualRightVerticalAllB( blockLineBeginI, blockLineEndI, blockColumnBeginI, blockColumnEndI )
   //
  ELSE
   //
   GotoBlockBegin()
   //
   GotoColumn( blockColumnBeginI )
   //
   quitB = FNBlockInsertColumnCharacterEqualLeftVerticalAllB( blockLineBeginI, blockLineEndI, blockColumnBeginI, blockColumnEndI )
   //
  ENDIF
  //
  UpdateDisplay()
  //
 UNTIL ( quitB )
 //
END

// library: block: mark: if NO block in CURRENT file marked, give a default message <description></description> <version>1.0.0.0.0</version> (filenamemacro=checbldm.s) [kn, ri, zo, 17-10-1999 08:21:38]
INTEGER PROC FNBlockCheckIsMarkedNotCurrentDefaultMessageB()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockCheckIsMarkedNotCurrentDefaultMessageB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 RETURN( FNBlockCheckIsMarkedNotCurrentMessageB( "No block is marked in current file. First mark a block" ) )
END

// library: block: insert: column: character: equal: right: vertical: all <description></description> <version>1.0.0.0.138</version> (filenamemacro=inseblra.s) [kn, ri, su, 26-09-2010 17:20:10]
INTEGER PROC FNBlockInsertColumnCharacterEqualRightVerticalAllB( INTEGER blockLineBeginI, INTEGER blockLineEndI, INTEGER blockColumnBeginI, INTEGER blockColumnEndI )
 // e.g. PROC Main()
 // e.g.  Message( FNBlockInsertColumnCharacterEqualRightVerticalAllB( 10, 20, 30, 40 ) )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER k = 0
 INTEGER quitB = FALSE
 INTEGER mouseButtonLeftB = FALSE
 //
 INTEGER minI = 0
 INTEGER I = 0
 //
 INTEGER columnI = 0
 //
 INTEGER B = FALSE
 //
 IF FNBlockCheckIsMarkedNotCurrentDefaultMessageB() RETURN( TRUE ) ENDIF // return from the current procedure if no block is marked
 //
 PushPosition()
 //
 Message( "Right: Equal characters inserted around block (press <ESC> at any time to cancel)" )
 //
 I = minI - 1
 //
 REPEAT
  //
  k = GetKey()
  //
  CASE k
   //
   WHEN <Escape>
    //
    quitB = TRUE
    //
   WHEN <LeftBtn>
    //
    mouseButtonLeftB = TRUE
    quitB = TRUE
    //
   WHEN <BackSpace>, <Ctrl z>
    //
    IF ( I >= minI )
     //
     I = I - 1
     //
     Undo()
     //
    ENDIF
    //
   OTHERWISE
    //
    IF ( ( Asc( " " ) <= k ) AND ( k <= 127 ) )
     //
     PushPosition()
     //
     I = I + 1
     //
     MarkColumn( blockLineBeginI, 1, blockLineEndI, 1 )
     //
     GotoBlockBegin()
     //
     Copy()
     //
     columnI = blockColumnEndI
     //
     GotoColumn( columnI + I + 1 )
     //
     Paste()
     //
     FillBlock( Chr( k ) )
     //
     MarkColumn( blockLineBeginI, BlockColumnBeginI, blockLineEndI, BlockColumnEndI )
     //
     PopPosition()
     //
     GotoColumn( columnI + I + 1 + 1 )
     //
    ELSE
     //
     PressKey( k )
     //
    ENDIF
    //
  ENDCASE
  //
  UpdateDisplay()
  //
 UNTIL ( quitB )
 //
 PopPosition()
 //
 IF mouseButtonLeftB
  //
  B = FALSE
  //
 ELSE
  //
  B = TRUE
  //
 ENDIF
 //
 RETURN( B )
 //
END

// library: block: insert: column: character: equal: left: vertical: all <description></description> <version>1.0.0.0.141</version> (filenamemacro=inseblla.s) [kn, ri, su, 26-09-2010 17:06:25]
INTEGER PROC FNBlockInsertColumnCharacterEqualLeftVerticalAllB( INTEGER blockLineBeginI, INTEGER blockLineEndI, INTEGER blockColumnBeginI, INTEGER blockColumnEndI )
 // e.g. PROC Main()
 // e.g.  Message( FNBlockInsertColumnCharacterEqualLeftVerticalAllB( 10, 20, 30, 40 ) )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER k = 0
 INTEGER quitB = FALSE
 INTEGER mouseButtonLeftB = FALSE
 //
 INTEGER minI = 0
 INTEGER I = 0
 //
 INTEGER columnI = 0
 //
 INTEGER B = FALSE
 //
 IF FNBlockCheckIsMarkedNotCurrentDefaultMessageB() RETURN( TRUE ) ENDIF // return from the current procedure if no block is marked
 //
 PushPosition()
 //
 Message( "Left: Equal characters inserted around block (press <ESC> at any time to cancel)" )
 //
 I = minI - 1
 //
 REPEAT
  //
  k = GetKey()
  //
  CASE k
   //
   WHEN <Escape>
    //
    quitB = TRUE
    //
   WHEN <LeftBtn>
    //
    mouseButtonLeftB = TRUE
    quitB = TRUE
    //
   WHEN <BackSpace>, <Ctrl z>
    //
    IF ( I >= minI )
     //
     I = I - 1
     //
     Undo()
     //
     MarkColumn( blockLineBeginI, BlockColumnBeginI + I + 1, blockLineEndI, BlockColumnEndI + I + 1 )
     //
    ENDIF
    //
   OTHERWISE
    //
    IF ( ( Asc( " " ) <= k ) AND ( k <= 127 ) )
     //
     PushPosition()
     //
     I = I + 1
     //
     MarkColumn( blockLineBeginI, 1, blockLineEndI, 1 )
     //
     GotoBlockBegin()
     //
     Copy()
     //
     columnI = blockColumnBeginI
     //
     GotoColumn( columnI + I )
     //
     Paste()
     //
     FillBlock( Chr( k ) )
     //
     MarkColumn( blockLineBeginI, BlockColumnBeginI + I + 1, blockLineEndI, BlockColumnEndI + I + 1 )
     //
     PopPosition()
     //
     GotoColumn( columnI + I + 1 )
     //
    ELSE
     //
     PressKey( k )
     //
    ENDIF
    //
  ENDCASE
  //
  UpdateDisplay()
  //
 UNTIL ( quitB )
 //
 PopPosition()
 //
 IF mouseButtonLeftB
  //
  B = FALSE
  //
 ELSE
  //
  B = TRUE
  //
 ENDIF
 //
 RETURN( B )
 //
END

// library: block: mark: if NO block in CURRENT file marked, give a message <description></description> <version>1.0.0.0.0</version> (filenamemacro=checblcn.s) [kn, ri, zo, 17-10-1999 08:21:38]
INTEGER PROC FNBlockCheckIsMarkedNotCurrentMessageB( STRING s )
 // e.g. PROC Main()
 // e.g.  IF FNBlockCheckIsMarkedNotCurrentMessageB( "No block is marked in current file" ) RETURN() ENDIF // return from the current procedure if no block is marked
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 INTEGER blockcurrentismarkedB = FNBlockCheckCurrentIsMarkedB()
 IF FNMathCheckLogicNotB( blockcurrentismarkedb ) // block is not marked
  PROCWarn( s )
 ENDIF
 RETURN( FNMathCheckLogicNotB( blockcurrentismarkedB ) )
END

// library: block: mark: is a block marked in CURRENT file? <description></description> <version>1.0.0.0.0</version> (filenamemacro=checblim.s) [kn, zoe, do, 20-05-1999 12:41:49]
INTEGER PROC FNBlockCheckCurrentIsMarkedB()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockCheckCurrentIsMarkedB() ) // gives TRUE if a block is marked in the current file
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 RETURN( FNMathCheckLogicNotB( FNMathCheckNumberEqualZeroB( FNBlockGetCurrentMarkedTypeI() ) ) )
END

// library: math: check: logic: not <description></description> <version>1.0.0.0.0</version> (filenamemacro=checmaln.s) [kn, ri, tu, 15-05-2001 16:54:21]
INTEGER PROC FNMathCheckLogicNotB( INTEGER B )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "math: check: logic: not: number = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( FNMathCheckLogicNotB( FNStringGetToIntegerI( s ) ) )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 RETURN( NOT B )
END

// library: error: warning: give a warning message [kn, zoe, wo, 09-06-1999 22:11:07]
PROC PROCWarn( STRING s )
 // e.g. <F12> PROCWarn( "you have forgotten to input a value" )
 Warn( s )
END

// library: math: number equal to ZERO? [kn, ri, th, 03-05-2001 14:19:57]
INTEGER PROC FNMathCheckNumberEqualZeroB( INTEGER x )
 RETURN( FNMathCheckNumberEqualB( x, 0 ) )
END

// library: block: mark: type: return the type of the block marked in the current file (Determines Whether a Block is Marked in Current File, 0 if no block, else _INCLUSIVE_, _NON_INCLUSIVE_, _LINE_, _COLUMN_) N <description></description> <version>1.0.0.0.0</version> (filenamemacro=getblmty.s) [kn, ri, zo, 17-10-1999 07:17:38]
INTEGER PROC FNBlockGetCurrentMarkedTypeI()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockGetCurrentMarkedTypeI() ) // gives e.g. 1
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 RETURN( IsBlockInCurrFile() )
END

// library: math: number: compare: equal: number1 EQUAL TO number2? <description></description> <version>1.0.0.0.0</version> (filenamemacro=checmane.s) [kn, ri, th, 03-05-2001 12:51:27]
INTEGER PROC FNMathCheckNumberEqualB( INTEGER x1, INTEGER x2 )
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckNumberEqualB( 3, 3 ) ) // gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 RETURN( x1 == x2 )
END
