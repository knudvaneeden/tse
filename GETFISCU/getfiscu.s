FORWARD INTEGER PROC FNFileGetSizeDiskCurrentI()
FORWARD INTEGER PROC FNFileGetSizeDiskI( STRING s1 )
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 Warn( FNFileGetSizeDiskCurrentI() ) // gives e.g. 12345 bytes as filesize on disk
END


// --- LIBRARY --- //

// library: file: get: size: disk: current <description></description> <version control></version control> <version>1.0.0.0.5</version> <version control></version control> (filenamemacro=getfiscu\getfiscu.s) [<Program>] [<Research>] [kn, ri, sa, 05-09-2026 17:31:32]
INTEGER PROC FNFileGetSizeDiskCurrentI()
 // e.g. PROC Main()
 // e.g.  Warn( FNFileGetSizeDiskCurrentI() ) // gives e.g. 12345 bytes as filesize on disk
 // e.g. END
 // e.g.
 //
 RETURN( FNFileGetSizeDiskI( CurrFileName() ) )
 //
END

// library: file: get: size: disk <description></description> <version control></version control> <version>1.0.0.0.12</version> <version control></version control> (filenamemacro=getfidso\getfidso.s) [<Program>] [<Research>] [kn, ri, sa, 05-09-2026 17:22:57]
INTEGER PROC FNFileGetSizeDiskI( STRING filenameS )
 // e.g. PROC Main()
 // e.g.  // STRING s1[255] = "/mnt/c/temp/ddd.txt" // TSE for Linux WSL / change this
 // e.g.  // STRING s1[255] = "/home/knudvaneeden/c/temp/tse_linux/knud/ddd.txt" // TSE for Linux non-WSL / change this
 // e.g.  STRING s1[255] = "c:\temp\ddd.txt" // TSE for Microsoft Windows / change this
 // e.g.  IF ( NOT ( Ask( "file: get: size: disk: fileNameS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Warn( FNFileGetSizeDiskI( s1 ) ) // gives e.g. 12345 bytes as filesize on disk
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER filesizeI = 0
 //
 // FindThisFile() and FFSize() are available in both the Windows and
 // Linux editions of TSE, including native Linux and WSL, so no
 // WIN32-only conditional is required.
 //
 IF FindThisFile( filenameS, _HIDDEN_ | _SYSTEM_ | _READONLY_ )
  //
  filesizeI = FFSize()
  //
 ELSE
  //
  Warn( Format( filenameS, " ", "not found (thus filesize in bytes could not be determined)" ) )
  //
 ENDIF
 //
 RETURN( filesizeI )
 //
END
