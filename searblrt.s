FORWARD INTEGER PROC FNBlockCheckCurrentIsMarkedB()
FORWARD INTEGER PROC FNBlockCheckIsMarkedNotCurrentDefaultMessageB()
FORWARD INTEGER PROC FNBlockCheckIsMarkedNotCurrentMessageB( STRING s1 )
FORWARD INTEGER PROC FNBlockGetCurrentMarkedTypeI()
FORWARD INTEGER PROC FNHistoryCheckAskCentralB( STRING s1, VAR STRING s2, INTEGER i1 )
FORWARD INTEGER PROC FNKeyCheckPressEscapeB( STRING s1 )
FORWARD INTEGER PROC FNMathCheckGetLogicFalseB()
FORWARD INTEGER PROC FNMathCheckInitializeNewBooleanFalseB()
FORWARD INTEGER PROC FNMathCheckLogicNotB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheckNumberEqualB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathCheckNumberEqualZeroB( INTEGER i1 )
FORWARD INTEGER PROC FNStringCheckEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEmptyNotB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
FORWARD PROC Main()
FORWARD PROC PROCBlockSearchAllOnceRecursiveTail( STRING s1, STRING s2, STRING s3, INTEGER i1, INTEGER i2 )
FORWARD PROC PROCWarn( STRING s1 )
FORWARD STRING PROC FNStringGetEmptyS()
FORWARD STRING PROC FNStringGetEscapeS()
FORWARD STRING PROC FNStringGetHistoryInputS( STRING s1, STRING s2, INTEGER i1 )
FORWARD STRING PROC FNStringGetInitializeNewStringS()
FORWARD STRING PROC FNStringGetInputS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetSearchHistoryFindInputS( STRING s1, STRING s2 )


// --- MAIN --- //

PROC Main()
 // Now changing something [kn, ri, sa, 25-09-2010 20:58:31]
 STRING s1[255] = FNStringGetInitializeNewStringS()
 STRING s2[255] = FNStringGetInitializeNewStringS()
 STRING s3[255] = FNStringGetInitializeNewStringS()
 STRING s4[255] = FNStringGetInitializeNewStringS()
 STRING s5[255] = FNStringGetInitializeNewStringS()
 s1 = FNStringGetInputS( "block: search: all: recursive: tail: s = ", "PROCA" )
 IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 s2 = FNStringGetInputS( "block: search: all: recursive: tail: procedureBeginS = ", "[ ]+" )
 IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 s3 = FNStringGetInputS( "block: search: all: recursive: tail: procedureEndS = ", "(" )
 IF FNKeyCheckPressEscapeB( s3 ) RETURN() ENDIF
 s4 = FNStringGetInputS( "block: search: all: recursive: tail: lineI = ", "1" )
 IF FNKeyCheckPressEscapeB( s4 ) RETURN() ENDIF
 s5 = FNStringGetInputS( "block: search: all: recursive: tail: posI = ", "1" )
 IF FNKeyCheckPressEscapeB( s5 ) RETURN() ENDIF
 PROCBlockSearchAllOnceRecursiveTail( s1, s2, s3, Val( s4 ), Val( s5 ) )
END

<F12> Main()

// --- LIBRARY --- //

// library: string: initialize [kn, ri, mo, 09-07-2001 12:00:07]
STRING PROC FNStringGetInitializeNewStringS()
 RETURN( FNStringGetEmptyS() )
END

// library: string: get: input <description>input a string</description> <version>1.0.0.0.1</version> (filenamemacro=getstgiq.s) [kn, ni, ma, 03-08-1998 13:04:18]
STRING PROC FNStringGetInputS( STRING askS, STRING answerDefaultS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConcat3S( "'", FNStringGetInputS( "Choose option (Y/n)", "Y" ), "'" ) ) // gives e.g. "Y"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetSearchHistoryFindInputS( askS, answerDefaultS ) )
 //
END

// library: key: check: press: escape <description>input: escape: test if escape was pressed</description> <version>1.0.0.0.2</version> (filenamemacro=checkepe.s) [kn, ni, wo, 05-08-1998 20:29:00]
INTEGER PROC FNKeyCheckPressEscapeB( STRING s ) // version with testing local variable
 // e.g. PROC Main()
 // e.g.  Message( FNKeyCheckPressEscapeB( "" ) ) // version with testing local variable ) // gives e.g. FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( s, FNStringGetEscapeS() ) )
 //
END

// library: block: search: all: once: recursive: tail <description></description> <version>1.0.0.0.12</version> (filenamemacro=searblrt.s) [kn, am, th, 29-07-2010 21:25:24]
PROC PROCBlockSearchAllOnceRecursiveTail( STRING s, STRING procedureBeginS, STRING procedureEndS, INTEGER lineI, INTEGER posI )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s3[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s4[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s5[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "block: search: all: recursive: tail: s = ", "PROCA" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "block: search: all: recursive: tail: procedureBeginS = ", "[ ]+" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  s3 = FNStringGetInputS( "block: search: all: recursive: tail: procedureEndS = ", "(" )
 // e.g.  IF FNKeyCheckPressEscapeB( s3 ) RETURN() ENDIF
 // e.g.  s4 = FNStringGetInputS( "block: search: all: recursive: tail: lineI = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s4 ) RETURN() ENDIF
 // e.g.  s5 = FNStringGetInputS( "block: search: all: recursive: tail: posI = ", "1" )
 // e.g.  IF FNKeyCheckPressEscapeB( s5 ) RETURN() ENDIF
 // e.g.  PROCBlockSearchAllOnceRecursiveTail( s1, s2, s3, Val( s4 ), Val( s5 ) )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // --- cut here: begin --------------------------------------------------
 //
 // PROC PROCC()
 //  //
 //  PROCA()
 //  //
 // END
 // //
 // PROC PROCD()
 //  //
 //  I = PROCA()
 //  //
 //  PROCC()
 //  //
 //  PROCA()
 //  //
 // END
 // //
 // PROC PROCA()
 //  //
 //  PROCA() // recursion to itself in PROCA
 //  //
 //  PROCD() // mutual recursion with another procedure
 //  //
 // END
 //
 // --- cut here: end ----------------------------------------------------
 //
 IF FNBlockCheckIsMarkedNotCurrentDefaultMessageB() RETURN() ENDIF // return from the current procedure if no block is marked
 //
 GotoLine( lineI )
 GotoPos( posI )
 //
 IF NOT ( LFind( Format( procedureBeginS, s, procedureEndS ), "ilx" ) ) RETURN() ENDIF
 //
 Warn( "found", " ", s, " ", "at position", " ", CurrLine(), " ", CurrPos() )
 //
 PROCBlockSearchAllOnceRecursiveTail( s, procedureBeginS, procedureEndS, CurrLine(), CurrPos() + 1 ) // goto one character to the right and start searching again
 //
END

// library: string: get: empty (return an empty string) <description></description> <version>1.0.0.0.0</version> (filenamemacro=getstgem.s) [kn, ri, za, 20-05-2000 20:11:03]
STRING PROC FNStringGetEmptyS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetEmptyS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 RETURN( "" )
END

// library: string: get: search: history: find: input <description>input a string: history: find</description> <version>1.0.0.0.2</version> (filenamemacro=getstfir.s) [kn, ri, sa, 25-08-2001 21:00:25]
STRING PROC FNStringGetSearchHistoryFindInputS( STRING askS, STRING answerDefaultS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetSearchHistoryFindInputS( "Please input something", "test" ) ) // gives e.g. "test"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetHistoryInputS( askS, answerDefaultS, _FIND_HISTORY_ ) )
 //
END

// library: string: equal: are two given strings equal? (stored in 'checstcf.s') [kn, zoe, wo, 04-10-2000 18:23:27]
INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  STRING s2[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: check: equal: first string = ", "a" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  s2 = FNStringGetInputS( "string: check: equal: second string = ", "a" )
 // e.g.  IF FNKeyCheckPressEscapeB( s2 ) RETURN() ENDIF
 // e.g.  Message( FNStringCheckEqualB( s1, s2 ) ) // gives e.g. TRUE when string1 is equal to string2
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // // <F12> PROCMessage( FNStringCheckEqualB( "knud", "knud" ) ) // gives TRUE
 // // <F12> PROCMessage( FNStringCheckEqualB( "knud", "van" ) ) // gives FALSE
 RETURN( s1 == s2 )
END

// library: string: get: escape <description>general output string to recognize an escape (e.g. in another routine). Central routine, only one occurrence of this constant string</description> <version>1.0.0.0.2</version> (filenamemacro=getstges.s) [kn, ri, za, 05-12-1998 18:52:24]
STRING PROC FNStringGetEscapeS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetEscapeS() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "<ESCAPE>" )
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

// library: string: get: history: input <description>input a string and store it in that specific history list</description> <version>1.0.0.0.2</version> (filenamemacro=getsthin.s) [kn, ni, ma, 03-08-1998 13:04:18]
STRING PROC FNStringGetHistoryInputS( STRING infoS, STRING answerDefaultS, INTEGER historyI )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetHistoryInputS( "Please input something", "test", _FIND_HISTORY_ ) ) // gives e.g. "test"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 STRING s[255] = answerDefaultS
 //
 INTEGER escapeB = FNMathCheckInitializeNewBooleanFalseB()
 //
 escapeB = FNMathCheckLogicNotB( FNHistoryCheckAskCentralB( infoS, s, historyI ) )
 //
 IF ( escapeB )
  //
  RETURN( FNStringGetEscapeS() )
  //
 ENDIF // <Escape> was pressed, in response
 //
 IF FNStringCheckEmptyB( s ) AND FNStringCheckEmptyNotB( answerDefaultS )
  //
  RETURN( FNStringGetEmptyS() ) // input of an empty string, user has removed the string to indicate that an empty string was wanted
  //
 ENDIF
 //
 IF FNStringCheckEmptyB( s )
  //
  RETURN( answerDefaultS )
  //
 ENDIF // <Enter> was pressed, in response (variation: IF FNMathCheckLogicNotB( MathGetStringLengthI( s ) ) ...) // removed FN because it gave problems compiling [kn, ri, sa, 16-02-2008 21:53:49]
 //
 RETURN( s ) // response was entered
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

// library: initialize: check: new: boolean: false <description></description> <version>1.0.0.0.0</version> (filenamemacro=checinbf.s) [kn, ri, su, 22-07-2001 15:58:06]
INTEGER PROC FNMathCheckInitializeNewBooleanFalseB()
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckInitializeNewBooleanFalseB() ) // gives e.g. FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 RETURN( FNMathCheckGetLogicFalseB() )
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

// library: history: check: ask: central <description>input: ask: find history</description> <version>1.0.0.0.1</version> (filenamemacro=chechiac.s) [kn, ri, sa, 25-08-2001 20:34:13]
INTEGER PROC FNHistoryCheckAskCentralB( STRING askS, VAR STRING answerDefaultS, INTEGER historyI )
 // e.g. PROC Main()
 // e.g.  STRING s[255] = "test"
 // e.g.  Message( FNHistoryCheckAskCentralB( "Please input something", s, _FIND_HISTORY_ ) ) // gives e.g. "test"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( Ask( askS, answerDefaultS, historyI ) )
 //
END

// library: string: empty: is given string empty? [kn, ri, za, 20-05-2000 20:11:08]
INTEGER PROC FNStringCheckEmptyB( STRING s )
 RETURN( FNStringCheckEqualB( s, FNStringGetEmptyS() ) )
END

// library: string: check: empty: not <description></description> <version>1.0.0.0.0</version> (filenamemacro=checstep.s) [kn, ri, su, 21-05-2006 22:32:11]
INTEGER PROC FNStringCheckEmptyNotB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckEmptyNotB( FNStringGetEmptyS() ) ) // gives e.g. FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 RETURN( FNMathCheckLogicNotB( FNStringCheckEmptyB( s ) ) )
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

// library: error: warning: give a warning message [kn, zoe, wo, 09-06-1999 22:11:07]
PROC PROCWarn( STRING s )
 // e.g. <F12> PROCWarn( "you have forgotten to input a value" )
 Warn( s )
END

// library: math: check: get: logic: false: wrapper <description></description> <version>1.0.0.0.0</version> (filenamemacro=checmalf.s) [kn, ri, su, 22-07-2001 15:43:08]
INTEGER PROC FNMathCheckGetLogicFalseB()
 // e.g. PROC Main()
 // e.g.  Message( FNMathCheckGetLogicFalseB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 RETURN( FALSE )
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
