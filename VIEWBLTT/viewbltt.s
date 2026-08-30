FORWARD INTEGER PROC FNBlockCheckCurrentIsMarkedB()
FORWARD INTEGER PROC FNBlockCheckIsMarkedNotCurrentDefaultMessageB()
FORWARD INTEGER PROC FNBlockCheckIsMarkedNotCurrentMessageB( STRING s1 )
FORWARD INTEGER PROC FNBlockGetCurrentMarkedTypeI()
FORWARD INTEGER PROC FNBlockViewLineMenuAmpersandTotalTseI()
FORWARD INTEGER PROC FNMacroCheckExecB( STRING s1 )
FORWARD INTEGER PROC FNMacroCheckLoadB( STRING s1 )
FORWARD INTEGER PROC FNMathCheckLogicNotB( INTEGER i1 )
FORWARD INTEGER PROC FNMathCheckNumberEqualB( INTEGER i1, INTEGER i2 )
FORWARD INTEGER PROC FNMathCheckNumberEqualZeroB( INTEGER i1 )
FORWARD INTEGER PROC FNStringCheckEmptyB( STRING s1 )
FORWARD INTEGER PROC FNStringCheckEqualB( STRING s1, STRING s2 )
FORWARD PROC Main()
FORWARD PROC PROCMacroExec( STRING s1 )
FORWARD PROC PROCMacroRunKeep( STRING s1 )
FORWARD PROC PROCWarn( STRING s1 )
FORWARD PROC PROCWarnCons3( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetAsciiToCharacterS( INTEGER i1 )
FORWARD STRING PROC FNStringGetCarS( STRING s1 )
FORWARD STRING PROC FNStringGetCharacterSymbolCentralS( INTEGER i1 )
FORWARD STRING PROC FNStringGetCharacterSymbolSpaceS()
FORWARD STRING PROC FNStringGetConcatSeparatorS( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetCons3S( STRING s1, STRING s2, STRING s3 )
FORWARD STRING PROC FNStringGetConsS( STRING s1, STRING s2 )
FORWARD STRING PROC FNStringGetEmptyS()


// --- MAIN --- //

PROC Main()
 Warn( "Total ampersand lines (&) in this block", " ", "=", " ", FNBlockViewLineMenuAmpersandTotalTseI() ) // gives e.g. 10 ampersand lines found in the current record
END

<Ctrl F12> Main()

// --- LIBRARY --- //

// library: block: view: line: menu: ampersand: total: tse <description></description> <version control></version control> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=viewbltt.s) [<Program>] [<Research>] [kn, ri, su, 30-08-2026 14:37:03]
INTEGER PROC FNBlockViewLineMenuAmpersandTotalTseI()
 // e.g. PROC Main()
 // e.g.  Warn( "Total ampersand lines (&) in this block", " ", "=", " ", FNBlockViewLineMenuAmpersandTotalTseI() ) // gives e.g. 10 ampersand lines found in the current record
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
 // e.g. // QuickHelp( HELPDEFFNBlockViewLineMenuAmpersandTotalTseI )
 // e.g. HELPDEF HELPDEFFNBlockViewLineMenuAmpersandTotalTseI
 // e.g.  title = "FNBlockViewLineMenuAmpersandTotalTseI() help" // The help's caption
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
 INTEGER I = 0
 //
 INTEGER downB = TRUE
 //
 PushPosition()
 //
 PushBlock()
 //
 IF FNBlockCheckIsMarkedNotCurrentDefaultMessageB() RETURN( 0 ) ENDIF // return from the current procedure if no block is marked
 //
 GotoBlockBegin()
 //
 I = 1 - 1
 //
 WHILE ( ( IsCursorInBlock() ) AND ( downB ) )
  //
  // IF LFind( '^[ ]*"\&.', "cgx" )
  IF LFind( '^[ ]*"{[~"]}*\&{[~"]}+\"\c', "cgx" )
   //
   I = I + 1
   //
  ENDIF
  //
  downB = Down()
  //
 ENDWHILE
 //
 PopBlock()
 //
 PopPosition()
 //
 RETURN( I )
 //
END

// library: block: mark: if NO block in CURRENT file marked, give a default message <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checbldm.s) [<Program>] [<Research>] [kn, ri, su, 17-10-1999 08:21:38]
INTEGER PROC FNBlockCheckIsMarkedNotCurrentDefaultMessageB()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockCheckIsMarkedNotCurrentDefaultMessageB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNBlockCheckIsMarkedNotCurrentMessageB( "No block is marked in current file. First mark a block" ) )
 //
END

// library: block: mark: if NO block in CURRENT file marked, give a message <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checblcn.s) [<Program>] [<Research>] [kn, ri, su, 17-10-1999 08:21:38]
INTEGER PROC FNBlockCheckIsMarkedNotCurrentMessageB( STRING s )
 // e.g. PROC Main()
 // e.g.  IF FNBlockCheckIsMarkedNotCurrentMessageB( "No block is marked in current file" ) RETURN() ENDIF // return from the current procedure if no block is marked
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER blockcurrentismarkedB = FNBlockCheckCurrentIsMarkedB()
 //
 IF FNMathCheckLogicNotB( blockcurrentismarkedb ) // block is not marked
  //
  PROCWarn( s )
  //
 ENDIF
 //
 RETURN( FNMathCheckLogicNotB( blockcurrentismarkedB ) )
 //
END

// library: block: mark: is a block marked in CURRENT file? <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=checblim.s) [<Program>] [<Research>] [kn, zoe, th, 20-05-1999 12:41:49]
INTEGER PROC FNBlockCheckCurrentIsMarkedB()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockCheckCurrentIsMarkedB() ) // gives TRUE if a block is marked in the current file
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckLogicNotB( FNMathCheckNumberEqualZeroB( FNBlockGetCurrentMarkedTypeI() ) ) )
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

// library: warn <description>error: warning: give a warning message</description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=wawarn.s)  [<Program>] [<Research>] [kn, zoe, we, 09-06-1999 22:11:07]
PROC PROCWarn( STRING s )
 // e.g. PROC Main()
 // e.g.  PROCWarn( "you have forgotten to input a value" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCMacroRunKeep( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new [kn, ri, fr, 22-05-2020 20:12:39]
 Warn( s )
 //
END

// library: math: check: number: equal: zero <description>math: number equal to ZERO?</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=checmaeb.s) [<Program>] [<Research>] [kn, ri, th, 03-05-2001 14:19:57]
INTEGER PROC FNMathCheckNumberEqualZeroB( INTEGER x )
 // e.g. PROC Main()
 // e.g.  Warn( FNMathCheckNumberEqualZeroB( 0 ) ) // gives e.g. TRUE
 // e.g.  Warn( FNMathCheckNumberEqualZeroB( 1 ) ) // gives e.g. FALSE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNMathCheckNumberEqualB( x, 0 ) )
 //
END

// library: block: mark: type: return the type of the block marked in the current file (Determines Whether a Block is Marked in Current File, 0 if no block, else _INCLUSIVE_, _NON_INCLUSIVE_, _LINE_, _COLUMN_) N <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getblmty.s) [<Program>] [<Research>] [kn, ri, su, 17-10-1999 07:17:38]
INTEGER PROC FNBlockGetCurrentMarkedTypeI()
 // e.g. PROC Main()
 // e.g.  Message( FNBlockGetCurrentMarkedTypeI() ) // gives e.g. 1
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( IsBlockInCurrFile() )
 //
END

// library: macro: run: keep <description>macro: run a macro, then keep it</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=runmarke.s) [<Program>] [<Research>] [[kn, zoe, fr, 27-10-2000 15:59:33]
PROC PROCMacroRunKeep( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  PROCMacroRunKeep( "mysubma1.mac myparameter11 myparameter12" )
 // e.g.  PROCMacroRunKeep( "mysubma2.mac myparameter21" )
 // e.g.  PROCMacroRunKeep( "mysubma3.mac myparameter31 myparameter32" )
 // e.g. END
 //
 IF FNMacroCheckLoadB( FNStringGetCarS( macronameS ) ) // necessary if you pass parameters in a string
  //
  PROCMacroExec( macronameS )
  //
 ENDIF
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

// library: macro: check: load <description>macro: load: (Loads a Macro File From Disk Into Memory) R    LoadMacro(STRING macro_filename)*</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checmacl.s) [<Program>] [<Research>] [[kn, zoe, we, 16-06-1999 01:07:06]
INTEGER PROC FNMacroCheckLoadB( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  Message( FNMacroCheckLoadB( macronameS ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( LoadMacro( macronameS ) )
 //
END

// library: string: get: word: token: get: first: FNStringGetCarS(): Get the first word of a string (words delimited by a space " " (=space delimited list)). <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgca.s) [<Program>] [<Research>] [kn, ni, su, 02-08-1998 15:54:17]
STRING PROC FNStringGetCarS( STRING s )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = FNStringGetInitializeNewStringS()
 // e.g.  s1 = FNStringGetInputS( "string: get: word: token: get: first: s = ", "this is a test" )
 // e.g.  IF FNKeyCheckPressEscapeB( s1 ) RETURN() ENDIF
 // e.g.  Message( FNStringGetCarS( s1 ) ) // gives e.g. "this"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // variation: RETURN( FNStringGetTokenFirstS( s, " " ) )
 //
 RETURN( GetToken( s, " ", 1 ) ) // faster, but not central
 //
END

// library: macro: exec <description>macro: (Executes the Requested Macro) O    ExecMacro([<Program>] [<Research>] [STRING macroname])*</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=execmame.s) [[kn, zoe, we, 16-06-1999 01:06:54]
PROC PROCMacroExec( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  PROCMacroExec( "video" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNMacroCheckExecB( macronameS ) )
  //
  PROCWarnCons3( "macro", macronameS, ": could not be executed" )
  //
 ENDIF
 //
END

// library: macro: check: exec <description>macro: (Executes the Requested Macro) O    ExecMacro([<Program>] [<Research>] [STRING macroname])*</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checmace.s) [[kn, zoe, we, 16-06-1999 01:06:54]
INTEGER PROC FNMacroCheckExecB( STRING macronameS )
 // e.g. PROC Main()
 // e.g.  Message( FNMacroCheckExecB( macronameS ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( ExecMacro( macronameS ) )
 //
END

// library: warn: cons3 <description>error: warning: give a warning message via 3 strings</description> <version>1.0.0.0.2</version> <version control></version control> (filenamemacro=conswawd.s) [<Program>] [<Research>] [[kn, ri, su, 29-07-2001 18:24:52]
PROC PROCWarnCons3( STRING s1, STRING s2, STRING s3 )
 // e.g. PROC Main()
 // e.g.  PROCWarnCons3( "error", "1", "2" ) // gives e.g. "error 1 2"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 PROCWarn( FNStringGetCons3S( s1, s2, s3 ) )
 //
END

// library: string: get: cons3: string: concatenation: 3 strings <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstgcy.s) [<Program>] [<Research>] [kn, zoe, fr, 17-11-2000 13:52:07]
STRING PROC FNStringGetCons3S( STRING s1, STRING s2, STRING s3 )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetCons3S( "a", "b", "c" ) ) // gives e.g. "a b c"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConsS( FNStringGetConsS( s1, s2 ), s3 ) )
 //
END

// library: string: get: cons: string: concatenation: concatenation 2 words to 1 word (separated by a space) <description></description> <version control></version control> <version>1.0.0.0.3</version> (filenamemacro=getstgcx.s) [<Program>] [<Research>] [kn, ri, we, 25-11-1998 20:15:03]
STRING PROC FNStringGetConsS( STRING s1, STRING s2 )
 // e.g. //
 // e.g. // version with test if string empty
 // e.g. //
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConsS( "john", "doe" ) ) // gives "john doe"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringGetConcatSeparatorS( s1, s2, FNStringGetCharacterSymbolSpaceS() ) )
 //
END

// library: string: get: concat: separator: string: concatenation: concatenate 2 words to 1 word, separated by separator <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=getstcsg.s) [<Program>] [<Research>] [kn, zoe, th, 01-07-1999 01:33:18]
STRING PROC FNStringGetConcatSeparatorS( STRING s1, STRING s2, STRING separatorS )
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetConcatSeparatorS( "test1", "test2", " " ) ) // gives e.g. "tes1 test2"
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNStringCheckEmptyB( s1 ) RETURN( s2 ) ENDIF
 //
 IF FNStringCheckEmptyB( s2 ) RETURN( s1 ) ENDIF
 //
 RETURN( s1 + separatorS + s2 ) // leave this like this. Do not call a function, as this is a primitive function, you will get into a recursive loop, and get stack overflow
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

// library: string: check: empty <description>string: empty: is given string empty?</description> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=checstcz.s) [<Program>] [<Research>] [[kn, ri, sa, 20-05-2000 20:11:08]
INTEGER PROC FNStringCheckEmptyB( STRING s )
 // e.g. PROC Main()
 // e.g.  Message( FNStringCheckEmptyB( s ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( FNStringCheckEqualB( s, FNStringGetEmptyS() ) )
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

// library: string: get: empty (return an empty string) <description></description> <version control></version control> <version>1.0.0.0.2</version> (filenamemacro=getstgem.s) [<Program>] [<Research>] [kn, ri, sa, 20-05-2000 20:11:03]
STRING PROC FNStringGetEmptyS()
 // e.g. PROC Main()
 // e.g.  Message( FNStringGetEmptyS() ) // gives e.g. the empty string: ""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( "" )
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
