FORWARD INTEGER PROC FNFileGetDownloadGithubFileVersionControlB( STRING s1, STRING s2, STRING s3, STRING s4 )
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 STRING s1[255] = "c:\temp\dddtest\" // the directory where to download it
 STRING s2[255] = "https://github.com/knudvaneeden/python-neuralnetwork-tensorflow-00.git" // change this to the remote GitHub repository URL
 STRING s3[255] = "g:\cygwin\bin\git.exe" // change this to your GIT executable
 STRING s4[255] = "g:\utils\jpsoft\tcmd\tcc.exe" // change this to your JPSoft tcc.exe
 IF ( NOT ( Ask( "file: get: download: github: file: version: control: yourLocalDirectoryS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 IF ( NOT ( Ask( "file: get: download: github: file: version: control: githubRemoteDirectoryUrlS = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 Message( FNFileGetDownloadGithubFileVersionControlB( s1, s2, s3, s4 ) ) // gives e.g. TRUE if successful
END

<F12> Main()

// --- LIBRARY --- //

// library: file: get: download: github: file: version: control <description></description> <version control></version control> <version>1.0.0.0.11</version> <version control></version control> (filenamemacro=getfivco.s) [<Program>] [<Research>] [kn, ri, fr, 09-02-2018 02:29:16]
INTEGER PROC FNFileGetDownloadGithubFileVersionControlB( STRING someLocaldirectoryS, STRING githubDirectoryS, STRING fileNameExecutableGitS, STRING fileNameExecutableTccS )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "c:\temp\dddtest\" // the directory where to download it
 // e.g.  STRING s2[255] = "https://github.com/knudvaneeden/python-neuralnetwork-tensorflow-00.git" // change this to the remote GitHub repository URL
 // e.g.  STRING s3[255] = "g:\cygwin\bin\git.exe" // change this to your GIT executable
 // e.g.  STRING s4[255] = "g:\utils\jpsoft\tcmd\tcc.exe" // change this to your JPSoft tcc.exe
 // e.g.  IF ( NOT ( Ask( "file: get: download: github: file: version: control: yourLocalDirectoryS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "file: get: download: github: file: version: control: githubRemoteDirectoryUrlS = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Message( FNFileGetDownloadGithubFileVersionControlB( s1, s2, s3, s4 ) ) // gives e.g. TRUE if successful
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER B = FALSE
 //
 STRING fileNameS[255] = "c:\temp\ddd.bat" // optionally change this to an existing path your system
 //
 IF EditFile( fileNameS )
  AbandonFile()
  EraseDiskFile( fileNameS )
 ENDIF
 //
 EditFile( fileNameS )
 //
 AddLine( Format( "md", " ", someLocaldirectoryS ) ) // optionally create the directory
 AddLine( Format( "cdd", " ", someLocaldirectoryS ) )
 AddLine( Format( fileNameExecutableGitS, " ", "clone", " ", githubDirectoryS ) )
 AddLine( Format( "pause" ) )
 //
 SaveAs( fileNameS, _OVERWRITE_ )
 //
 // PROCFileRun4NtAliasCommandListUser( fileNameS ) // run this batch file using tcc.exe
 LDos( fileNameExecutableTccS, fileNameS )
 //
 B = TRUE
 //
 RETURN( B )
 //
END
