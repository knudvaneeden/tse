FORWARD PROC Main()
FORWARD PROC PROCProgramRunRecursionLimit( INTEGER i1 )


// --- MAIN --- //

PROC Main()
 PROCProgramRunRecursionLimit( 1 )
END

<F12> Main()

// --- LIBRARY --- //

// library: program: run: recursion: limit <description>will stop at 3616</description> <version>1.0.0.0.6</version> <version control></version control> (filenamemacro=runprrli.s) [<Program>] [<Research>] [kn, ri, su, 25-12-2011 23:12:02]
PROC PROCProgramRunRecursionLimit( INTEGER I )
 // e.g. PROC Main()
 // e.g.  PROCProgramRunRecursionLimit( 1 )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // http://rosettacode.org/wiki/Find_limit_of_recursion#TSE_SAL
 //
 // ===
 //
 Message( I )
 //
 PROCProgramRunRecursionLimit( I + 1 )
 //
END
