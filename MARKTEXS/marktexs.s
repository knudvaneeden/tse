FORWARD INTEGER PROC FNBlockCheckSelectMarkStreamB()
FORWARD INTEGER PROC FNBlockCheckSelectMarkStreamStartB()
FORWARD INTEGER PROC FNCursorCheckGotoLeftB()
FORWARD INTEGER PROC FNCursorCheckGotoRightB()
FORWARD INTEGER PROC FNLineCheckCharacterFirstB()
FORWARD INTEGER PROC FNLineCheckGotoEndB()
FORWARD INTEGER PROC FNLineGetColumnPositionCurrentI()
FORWARD INTEGER PROC FNMathCheckGetLogicFalseB()
FORWARD INTEGER PROC FNMathCheckGetLogicTrueB()
FORWARD INTEGER PROC FNMathCheckInitializeNewBooleanFalseB()
FORWARD INTEGER PROC FNMathCheckLogicAndB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathCheckLogicNotB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheckNumberEqualB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathCheckNumberIntegerEqualB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
FORWARD INTEGER PROC FNTextCheckCharacter_CurrentEqualB( STRING s1 )
FORWARD INTEGER PROC FNTextCheckLineCharacterEndPastB()
FORWARD INTEGER PROC FNTextCheckLineCharacter_BeyondLastB()
FORWARD INTEGER PROC FNTextCheckLineCharacter_LastNextB()
FORWARD INTEGER PROC FNTextCheckLineGotoCharacterBeyondLastB()
FORWARD INTEGER PROC FNTextGetCharacterCurrentI()
FORWARD INTEGER PROC FNTextGetCharacterEndOfLineI()
FORWARD INTEGER PROC FNTextGetCharacterLineEndBeyondI()
FORWARD INTEGER PROC FNTextGetPositionWindowColumnCurrentI()
FORWARD PROC Main()
FORWARD PROC PROCBlockSelectClearMark()
FORWARD PROC PROCBlockSelectMarkFix()
FORWARD PROC PROCBlockSelectMarkStream()
FORWARD PROC PROCCursorGotoLeft()
FORWARD PROC PROCCursorGotoRight()
FORWARD PROC PROCLineGotoCharacterLast()
FORWARD PROC PROCTextGotoLineCharacterBeyondLast()
FORWARD PROC PROCTextGotoLineEnd()
FORWARD PROC PROCTextRemovePositionStackPop()
FORWARD PROC PROCTextSavePositionStackPush()
FORWARD PROC PROCTextSelectMarkSpaceBetween()
FORWARD PROC PROCWarn( STRING s1 )
FORWARD STRING PROC FNStringGetAsciiToCharacterS( INTEGER i1 )
FORWARD STRING PROC FNStringGetCharacterSymbolCentralS( INTEGER i1 )
FORWARD STRING PROC FNStringGetCharacterSymbolSpaceS()
FORWARD STRING PROC FNStringGetTextMidStringS( INTEGER i1, INTEGER i2 )
FORWARD STRING PROC FNTextGetCharacterCurrentS()


// --- MAIN --- //

PROC Main()
 PROCTextSelectMarkSpaceBetween()
END

<F12> Main()

// --- LIBRARY --- //

// library: text: select: mark: space: between: version: 1 <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=marktexs.s) [<Program>] [<Research>] [kn, zoe, fr, 27-08-1999 21:45:15]
PROC PROCTextSelectMarkSpaceBetween()
 // e.g. PROC Main()
 // e.g.  PROCTextSelectMarkSpaceBetween()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER markedB = FNMathCheckInitializeNewBooleanFalseB()
 //
 PROCTextSavePositionStackPush()
 //
 PROCTextGotoLineCharacterBeyondLast()
 //
 WHILE ( FNMathCheckLogicAndB( FNMathCheckLogicNotB( FNLineCheckCharacterFirstB() ), FNMathCheckLogicNotB( FNTextCheckCharacter_CurrentEqualB( FNStringGetCharacterSymbolSpaceS() ) ) ) ) // first goto the left most position of the text you want to get
  //
  markedB = FNMathCheckGetLogicTrueB()
  //
  PROCCursorGotoLeft()
  //
 ENDWHILE
 //
 IF FNLineCheckCharacterFirstB()
  //
  markedB = FNMathCheckGetLogicTrueB()
  //
 ENDIF
 //
 IF markedB // if you marked already
  //
  IF FNTextCheckCharacter_CurrentEqualB( FNStringGetCharacterSymbolSpaceS() ) // if you moved to the front space, go one step to the right
   //
   PROCCursorGotoRight()
   //
  ENDIF
  //
  PROCBlockSelectClearMark()
  //
  PROCBlockSelectMarkStream() // start marking from the left most position
  //
  WHILE ( FNMathCheckLogicAndB( FNMathCheckLogicNotB( FNTextCheckLineCharacter_LastNextB() ), FNMathCheckLogicNotB( FNTextCheckCharacter_CurrentEqualB( FNStringGetCharacterSymbolSpaceS() ) ) ) ) // then goto the right most position of the text you want to get
   //
   PROCCursorGotoRight()
   //
  ENDWHILE
  //
  IF FNTextCheckCharacter_CurrentEqualB( FNStringGetCharacterSymbolSpaceS() ) // if you moved onto the end space, go one step to the left
   //
   PROCCursorGotoLeft()
   //
  ENDIF
  //
  PROCTextGotoLineCharacterBeyondLast()
  //
  PROCBlockSelectMarkFix() // fix the block
  //
 ENDIF
 //
 PROCTextRemovePositionStackPop()
 //
END

// library: initialize: check: new: boolean: false <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checinbf.s) [<Program>] [<Research>] [kn, ri, su, 22-07-2001 15:58:06]
INTEGER PROC FNMathCheckInitializeNewBooleanFalseB()
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckInitializeNewBooleanFalseB() ) // gives e.g. FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckGetLogicFalseB() )
 //
END

// library: text: save: position: stack: push <description>text: save: position: stack: push: store</description> <version>1.0.0.0.0</version> <version control></version control> (filenamemacro=savetesp.s) [<Program>] [<Research>] [[kn, zoe, fr, 04-06-1999 23:01:00]
PROC PROCTextSavePositionStackPush()
 // e.g. PROC Main()
 // e.g.  PROCTextSavePositionStackPush()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PushPosition() // returns nothing
 //
 // pushpopGT = pushpopGT + 1 // for checking purposes on the end of your routines. This must give 0 (as there as as many +1 as -1 in the OK case)
 //
END

// library: text: goto: line: character: beyond: last <description>if past the last character of the line, move onto the last character</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=gototebl.s) [<Program>] [<Research>] [kn, zoe, sa, 02-10-1999 14:27:12]
PROC PROCTextGotoLineCharacterBeyondLast()
 // e.g. PROC Main()
 // e.g.  PROCTextGotoLineCharacterBeyondLast()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 FNTextCheckLineGotoCharacterBeyondLastB()
 //
END

// library: math: check: logic: and <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmala.s) [<Program>] [<Research>] [kn, ri, tu, 15-05-2001 16:54:21]
INTEGER PROC FNMathCheckLogicAndB( INTEGER B1, INTEGER B2 )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "math: check: logic: and: number1 = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "math: check: logic: and: number2 = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNMathCheckLogicAndB( FNStringGetToIntegerI( s1 ), FNStringGetToIntegerI( s2 ) ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF NOT ( B1 )
  //
  RETURN( FNMathCheckGetLogicFalseB() )
  //
 ENDIF
 //
 IF NOT ( B2 )
  //
  RETURN( FNMathCheckGetLogicFalseB() )
  //
 ENDIF
 //
 RETURN( FNMathCheckGetLogicTrueB() )
 //
END

// library: math: check: logic: not <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checmaln.s) [<Program>] [<Research>] [kn, ri, tu, 15-05-2001 16:54:21]
INTEGER PROC FNMathCheckLogicNotB( INTEGER B )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = FNStringGetInitializeNewStringS()
 // e.g.  s = FNStringGetInputS( "math: check: logic: not: number = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s ) RETURN() ENDIF
 // e.g.  Message( FNMathCheckLogicNotB( FNStringGetToIntegerI( s ) ) )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( NOT B )
 //
END

// library: line: check: character: first <description>position: line: begin: Is the current column position at the beginning of the current line? [<Program>] [<Research>] [1st character of the line]</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checlich.s) [kn, zoe, mo, 29-03-1999 21:03:44]
INTEGER PROC FNLineCheckCharacterFirstB()
 // e.g. PROC Main()
 // e.g.  Message( FNLineCheckCharacterFirstB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // variation: RETURN( CurrCol() == 1 )
 //
 RETURN( FNTextGetPositionWindowColumnCurrentI() == 1 )
 //
END

// library: text: check: character: current: equal <description>character: equal: current: is this character equal to current character / text: string: character: token: get: current: string: test if the current character is equal to the given character</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=chectech.s) [<Program>] [<Research>] [[kn, ri, su, 16-05-1999 19:19:55]
INTEGER PROC FNTextCheckCharacter_CurrentEqualB( STRING kS )
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckCharacter_CurrentEqualB( " " ) ) // gives TRUE, when the current character is a space
 // e.g.  GetKey()
 // e.g.  Message( FNTextCheckCharacter_CurrentEqualB( "k" ) ) // gives TRUE, when the current character is a "k"
 // e.g.  GetKey()
 // e.g.  Message( FNTextCheckCharacter_CurrentEqualB( "k" ) ) // gives FALSE, when the current character is any character other than "k", e.g. "b"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( kS, FNTextGetCharacterCurrentS() ) )
 //
END

// library: string: get: character: symbol: " " <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstssp.s) [<Program>] [<Research>] [kn, zoe, we, 25-10-2000 01:33:39]
STRING PROC FNStringGetCharacterSymbolSpaceS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterSymbolSpaceS() ) // gives " "
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetCharacterSymbolCentralS( 32 ) )
 //
END

// library: math: check: get: logic: true: wrapper <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmalt.s) [<Program>] [<Research>] [kn, ri, su, 22-07-2001 15:43:12]
INTEGER PROC FNMathCheckGetLogicTrueB()
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckGetLogicTrueB() ) // gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( TRUE )
 //
END

// library: cursor: goto: left <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotocugl.s) [<Program>] [<Research>] [kn, zoe, tu, 15-06-1999 23:46:50]
PROC PROCCursorGotoLeft()
 // e.g. PROC Main()
 // e.g.  PROCCursorGotoLeft()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNCursorCheckGotoLeftB() )
  //
  // PROCWarn( "Could not go left"  )
  //
 ENDIF
 //
END

// library: cursor: goto: right <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotocugr.s) [<Program>] [<Research>] [kn, zoe, tu, 15-06-1999 23:46:50]
PROC PROCCursorGotoRight()
 // e.g. PROC Main()
 // e.g.  PROCCursorGotoRight()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNCursorCheckGotoRightB() )
  //
  // PROCWarn( "Could not go right"  )
  //
 ENDIF
 //
END

// library: block: mark: unmark: PROCBlockUnMark(): (Unmarks Marked Block) N * <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=cleablcm.s) [<Program>] [<Research>] [kn, zoe, we, 16-06-1999 01:07:12]
PROC PROCBlockSelectClearMark()
 // e.g. PROC Main()
 // e.g.  PROCBlockSelectClearMark()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 UnMarkBlock()
 //
END

// library: block: mark: mark a stream block (marks character block that includes cursor position) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=markblms.s) [<Program>] [<Research>] [kn, ri, we, 12-05-1999 07:40:27]
PROC PROCBlockSelectMarkStream()
 // e.g. PROC Main()
 // e.g.  PROCBlockSelectMarkStream()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNBlockCheckSelectMarkStreamB() )
  //
  PROCWarn( "mark stream was not possible" )
  //
 ENDIF
 //
END

// library: text: check: line: character: last: next <description>position: line: end: cursor one position after last character of the current line?</description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checlepa.s) [<Program>] [<Research>] [kn, zoe, mo, 29-03-1999 21:09:19]
INTEGER PROC FNTextCheckLineCharacter_LastNextB()
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckLineCharacter_LastNextB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckNumberIntegerEqualB( FNTextGetCharacterCurrentI(), FNTextGetCharacterEndOfLineI() ) )
 //
END

// library: block: mark: fix <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=markblmf.s) [<Program>] [<Research>] [kn, ni, tu, 27-07-1999 18:03:13]
PROC PROCBlockSelectMarkFix()
 // e.g. <F12> Main()
 // e.g. PROC Main()
 // e.g.  PROCBlockSelectMarkFix()
 // e.g. END
 // e.g.
 IF FNBlockCheckSelectMarkStreamStartB()
  //
  PROCBlockSelectMarkStream()
  //
 ENDIF
 //
END

// library: text: remove: position: stack: pop <description>text: remove: position: stack: pop: restore</description> <version>1.0.0.0.0</version> <version control></version control> (filenamemacro=remotesp.s) [<Program>] [<Research>] [[kn, zoe, fr, 04-06-1999 23:01:00]
PROC PROCTextRemovePositionStackPop()
 // e.g. PROC Main()
 // e.g.  PROCTextRemovePositionStackPop()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PopPosition() // returns nothing
 //
 // pushpopGT = pushpopGT - 1 // for checking purposes on the end of your routines. This must give 0 (as there as as many +1 as -1 in the OK case)
 //
END

// library: math: check: get: logic: false: wrapper <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmalf.s) [<Program>] [<Research>] [kn, ri, su, 22-07-2001 15:43:08]
INTEGER PROC FNMathCheckGetLogicFalseB()
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckGetLogicFalseB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FALSE )
 //
END

// library: text: check: line: goto: character: beyond: last <description>if past the last character of the line, move onto the last character</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=chectebl.s) [<Program>] [<Research>] [kn, zoe, su, 10-10-1999 16:06:50]
INTEGER PROC FNTextCheckLineGotoCharacterBeyondLastB()
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckLineGotoCharacterBeyondLastB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER lastbeyondB = FNTextCheckLineCharacterEndPastB() // if you moved onto 1 character after the end, go one step to the left
 //
 IF lastbeyondB
  //
  PROCLineGotoCharacterLast()
  //
 ENDIF
 //
 RETURN( lastbeyondB )
 //
END

// library: text: get: position: window: column: current <description>position: line: column: get: (Get the Number of Current Column Position) N    *</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=getteccw.s) [<Program>] [<Research>] [kn, zoe, we, 07-07-1999 19:21:23]
INTEGER PROC FNTextGetPositionWindowColumnCurrentI()
 // e.g. PROC Main()
 // e.g.  Message( FNTextGetPositionWindowColumnCurrentI() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( CurrCol() )
 //
END

// library: string: check: equal <description>string: equal: are two given strings equal? (stored in 'checstcf.s')</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checstcy.s) [<Program>] [<Research>] [[kn, zoe, we, 04-10-2000 18:23:27]
INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: check: equal: first string = ", "a" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "string: check: equal: second string = ", "a" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNStringCheckEqualB( s1, s2 ) ) // gives e.g. TRUE when string1 is equal to string2
 // e.g.  GetKey()
 // e.g.  Message( FNStringCheckEqualB( "knud", "knud" ) ) // gives TRUE
 // e.g.  GetKey()
 // e.g.  Message( FNStringCheckEqualB( "knud", "van" ) ) // gives FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( s1 == s2 )
 //
END

// library: string: character: token: get: current: string: return the current character as a string <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getteccv.s) [<Program>] [<Research>] [kn, ri, su, 16-05-1999 19:18:17]
STRING PROC FNTextGetCharacterCurrentS()
 // e.g. PROC Main()
 // e.g.  Message( FNTextGetCharacterCurrentS() ) // gives e.g. "A" if ASCII value current character is 65
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // RETURN( GetText( CurrPos(), 1 ) )
 //
 RETURN( FNStringGetTextMidStringS( FNLineGetColumnPositionCurrentI(), 1 ) )
 //
 // RETURN( FNStringGetTextGetCharacterCentralS( FNTextGetCharacterCurrentI() ) ) // do not use
 //
END

// library: string: get: character: symbol: central <description>string: get: character: symbol: central</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=getstscm.s) [<Program>] [<Research>] [[kn, ri, sa, 07-07-2001 22:35:39]
STRING PROC FNStringGetCharacterSymbolCentralS( INTEGER I )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCharacterSymbolCentralS( I ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetAsciiToCharacterS( I ) )
 //
END

// library: movement: line: left: go to the previous character <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checcugl.s) [<Program>] [<Research>] [kn, zoe, we, 12-05-1999 15:48:43]
INTEGER PROC FNCursorCheckGotoLeftB()
 // e.g. PROC Main()
 // e.g.  Message( FNCursorCheckGotoLeftB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Left() )
 //
END

// library: movement: line: left: go to the next character <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checcugr.s) [<Program>] [<Research>] [kn, zoe, we, 12-05-1999 15:48:01]
INTEGER PROC FNCursorCheckGotoRightB()
 // e.g. PROC Main()
 // e.g.  Message( FNCursorCheckGotoRightB() ) // gives e.g. TRUE when cursor successfully moved to the right
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Right() )
 //
END

// library: block: mark: stream <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=markblmt.s) [<Program>] [<Research>] [kn, zoe, fr, 24-11-2000 19:08:32]
INTEGER PROC FNBlockCheckSelectMarkStreamB()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockCheckSelectMarkStreamB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( MarkStream() )
 //
END

// library: warn <description>error: warning: give a warning message</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=wawarn.s)  [<Program>] [<Research>] [kn, zoe, we, 09-06-1999 22:11:07]
PROC PROCWarn( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCWarn( "you have forgotten to input a value" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 Warn( s )
 //
END

// library: math: number: compare: equal: are two given numbers equal? <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmaie.s) [<Program>] [<Research>] [kn, zoe, fr, 01-12-2000 19:01:34]
INTEGER PROC FNMathCheckNumberIntegerEqualB( INTEGER x1, INTEGER x2 )
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckNumberIntegerEqualB( 3, 3 ) ) // gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckNumberEqualB( x1, x2 ) )
 //
END

// library: text: character: token: get: current: ascii: return the current character as an ASCII number (Get the Integer Value of Character at Cursor Position) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getteccu.s) [<Program>] [<Research>] [kn, ri, su, 16-05-1999 19:18:17] [Ascii]
INTEGER PROC FNTextGetCharacterCurrentI()
 // e.g. PROC Main()
 // e.g.  Message( FNTextGetCharacterCurrentI() ) // gives e.g. 65 when cursor currently on the character "A"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( CurrChar() )
 //
END

// library: text: get: character: end: of: line <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getteoli.s) [<Program>] [<Research>] [kn, ri, su, 09-06-2002 23:39:51]
INTEGER PROC FNTextGetCharacterEndOfLineI()
 // e.g. PROC Main()
 // e.g.  Message( FNTextGetCharacterEndOfLineI() ) // gives -1
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( _AT_EOL_ )
 //
END

// library: block: mark: stream: started already? <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=markblss.s) [<Program>] [<Research>] [kn, ri, tu, 30-10-2001 05:45:36]
INTEGER PROC FNBlockCheckSelectMarkStreamStartB()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockCheckSelectMarkStreamStartB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Query( Marking ) )
 //
END

// library: text: check: line: character: end: past <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checteep.s) [<Program>] [<Research>] [kn, ri, tu, 11-06-2002 00:07:08]
INTEGER PROC FNTextCheckLineCharacterEndPastB()
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckLineCharacterEndPastB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNTextCheckLineCharacter_LastNextB() OR FNTextCheckLineCharacter_BeyondLastB() )
 //
END

// library: cursor: goto last character of the current line <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotolicl.s) [<Program>] [<Research>] [kn, zoe, mo, 15-01-2001 16:26:03]
PROC PROCLineGotoCharacterLast()
 // e.g. PROC Main()
 // e.g.  PROCLineGotoCharacterLast()
 // e.g. END
 // e.g.
 // e.g. <F12> PROCLineGotoCharacterLast()
 //
 PROCTextGotoLineEnd()
 //
 PROCCursorGotoLeft()
 //
END

// library: text: get: mid: string: retrieves text from current line of current file) gettext(integer pos, integer len) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gettemst.s) [<Program>] [<Research>] [kn, zoe, we, 16-06-1999 01:06:55]
STRING PROC FNStringGetTextMidStringS( INTEGER positionstartI, INTEGER charactertotalI )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetTextMidStringS( 2, 5 ) ) // gives e.g. "abcde"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( GetText( positionstartI, charactertotalI ) )
 //
END

// library: line: position: character position: return the current character position (=column number) (get the current position on the current line) <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getlipcu.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 13:35:20]
INTEGER PROC FNLineGetColumnPositionCurrentI()
 // e.g. PROC Main()
 // e.g.  Message( FNLineGetColumnPositionCurrentI() ) // gives e.g. 15 when the current column position of the cursor is on the 15th character
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( CurrPos() )
 //
END

// library: string: get: ascii: to: character (given the ASCII value, what is the corresponding character? (Get Single Character Equivalent of an Integer). Syntax: Chr(INTEGER i)*) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getsttch.s)  [<Program>] [<Research>] [kn, zoe, we, 16-06-1999 01:06:51]
STRING PROC FNStringGetAsciiToCharacterS( INTEGER asciiI )
 // e.g. PROC Main()
 // e.g.  Warn( FNStringGetAsciiToCharacterS( 65 ) ) // gives "A"
 // e.g.  Warn( FNStringGetAsciiToCharacterS( 66 ) ) // gives "B"
 // e.g.  Warn( FNStringGetAsciiToCharacterS( 100 ) ) // gives "d"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Chr( asciiI ) ) // leave this keyword, otherwise possibly recursive stack overflow
 //
END

// library: math: number: compare: equal: number1 EQUAL TO number2? <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checmane.s) [<Program>] [<Research>] [kn, ri, th, 03-05-2001 12:51:27]
INTEGER PROC FNMathCheckNumberEqualB( INTEGER x1, INTEGER x2 )
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckNumberEqualB( 3, 3 ) ) // gives TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( x1 == x2 )
 //
END

// library: text: check: line: character: beyond: last <description>position: line: end: If you are on the last character, then at least two to the right: Is the current position past the end of the current line? [<Program>] [<Research>] [last character of the line]</description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=checlibe.s) [kn, zoe, fr, 01-10-1999 17:13:15]
INTEGER PROC FNTextCheckLineCharacter_BeyondLastB()
 // e.g. PROC Main()
 // e.g.  Message( FNTextCheckLineCharacter_BeyondLastB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckNumberIntegerEqualB( FNTextGetCharacterCurrentI(), FNTextGetCharacterLineEndBeyondI() ) )
 //
END

// library: movement: line: goto the end of the line (one character past the last character <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotolien.s) [<Program>] [<Research>] [kn, ni, mo, 03-08-1998 13:36:32]
PROC PROCTextGotoLineEnd()
 // e.g. PROC Main()
 // e.g.  PROCTextGotoLineEnd()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNLineCheckGotoEndB() )
  //
  // PROCWarn( "could not go to the end of the line" )
  //
 ENDIF
 //
END

// library: text: get: character: beyond: end: of: line <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getteolj.s) [<Program>] [<Research>] [kn, ri, su, 09-06-2002 23:40:45]
INTEGER PROC FNTextGetCharacterLineEndBeyondI()
 // e.g. PROC Main()
 // e.g.  Message( FNTextGetCharacterLineEndBeyondI() ) // gives -2
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( _BEYOND_EOL_ )
 //
END

// library: line: check: goto: end <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=checlige.s) [<Program>] [<Research>] [kn, ni, su, 09-08-1998 18:00:41]
INTEGER PROC FNLineCheckGotoEndB()
 // e.g. PROC Main()
 // e.g.  Message( "Goto the end of the line = ", FNLineCheckGotoEndB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( EndLine() )
 //
END
