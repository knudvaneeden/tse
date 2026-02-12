FORWARD INTEGER PROC FNProgramRunVersionControlGithubB()
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 Message( FNProgramRunVersionControlGithubB() ) // gives e.g. TRUE if successful
END

<F12> Main()

// --- LIBRARY --- //

// library: program: run: version: control: github <description></description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=runprcgi.s) [<Program>] [<Research>] [kn, ri, su, 18-02-2018 07:18:27]
INTEGER PROC FNProgramRunVersionControlGithubB()
 // e.g. PROC Main()
 // e.g.  Message( FNProgramRunVersionControlGithubB() ) // gives e.g. TRUE if successful
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER B = FALSE
 //
 STRING urlS[255] = "http://www.github.com"
 //
 B = StartPgm( urlS )
 // PROCProgramRunInternetBrowserUrl( urlS ) B = TRUE
 //
 RETURN( B )
 //
END
