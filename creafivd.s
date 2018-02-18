FORWARD INTEGER PROC FNFileCreateRepositoryNewRemoteGithubFileVersionControlB()
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 //
 Message( FNFileCreateRepositoryNewRemoteGithubFileVersionControlB() )
END

<F12> Main()

// --- LIBRARY --- //

// library: file: create: repository: new: remote: github: file: version: control <description></description> <version control></version control> <version>1.0.0.0.11</version> <version control></version control> (filenamemacro=creafivd.s) [<Program>] [<Research>] [kn, ri, fr, 16-02-2018 17:55:44]
INTEGER PROC FNFileCreateRepositoryNewRemoteGithubFileVersionControlB()
 // e.g. PROC Main()
 // e.g.  //
 // e.g.  Message( FNFileCreateRepositoryNewRemoteGithubFileVersionControlB() )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER B = FALSE
 //
 STRING urlS[255] = "https://github.com/new/"
 //
 StartPgm( urlS )
 //
 B = TRUE
 //
 RETURN( B )
 //
END
