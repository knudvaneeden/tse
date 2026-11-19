FORWARD INTEGER PROC FNMathCheckLogicNotB( INTEGER i1 )
FORWARD INTEGER PROC FNWindowCheckGotoScrollGotoTopB()
FORWARD PROC Main()
FORWARD PROC PROCWindowGotoScrollTop()


// --- MAIN --- //

PROC Main()
 PROCWindowGotoScrollTop()
END

<F12> Main()

// --- LIBRARY --- //

// library: window: goto: scroll: to: top <description></description> <version control></version control> <version>1.0.0.0.1</version> (filenamemacro=gotowist.s) [<Program>] [<Research>] [kn, ri, su, 09-12-2001 16:13:39]
PROC PROCWindowGotoScrollTop()
 // e.g. PROC Main()
 // e.g.  PROCWindowGotoScrollTop()
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF FNMathCheckLogicNotB( FNWindowCheckGotoScrollGotoTopB() )
  //
  // PROCWarn( "window: could not scroll to top" )
  //
 ENDIF
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

// library: window: goto: scroll: goto: top <description></description> <version control></version control> <version>1.0.0.0.0</version> (filenamemacro=gotowigt.s) [<Program>] [<Research>] [kn, ri, su, 09-12-2001 16:12:20]
INTEGER PROC FNWindowCheckGotoScrollGotoTopB()
 // e.g. PROC Main()
 // e.g.  Message( FNWindowCheckGotoScrollGotoTopB() ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 RETURN( ScrollToTop() )
 //
END
