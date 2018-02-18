FORWARD INTEGER PROC FNFileSaveCurrentToDirectoryLocalGitVersionControlB()
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 Message( FNFileSaveCurrentToDirectoryLocalGitVersionControlB() ) // gives e.g. TRUE if successful
END

<F12> Main()

// --- LIBRARY --- //

// library: file: save: to: directory: local: git: version: control <description></description> <version control></version control> <version>1.0.0.0.1</version> <version control></version control> (filenamemacro=savefivc.s) [<Program>] [<Research>] [kn, ri, su, 18-02-2018 05:40:49]
INTEGER PROC FNFileSaveCurrentToDirectoryLocalGitVersionControlB()
 // e.g. PROC Main()
 // e.g.  Message( FNFileSaveCurrentToDirectoryLocalGitVersionControlB() ) // gives e.g. TRUE if successful
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER B = FALSE
 //
 STRING directoryLocalGitHubS[255] = "C:\TEMP\TSE\" // optionally change this
 //
 B = SaveAs( Format( directoryLocalGitHubS, SplitPath( CurrFileName(), _NAME_ | _EXT_ ) ), _OVERWRITE_ )
 //
 RETURN( B )
 //
END
