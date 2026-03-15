FORWARD PROC Main()
FORWARD PROC PROCUrlGetSource( STRING s1, STRING s2 )


// --- MAIN --- //

DLL "<urlmon.dll>"
 INTEGER PROC FNUrlGetSourceApiI(
  INTEGER lpunknown,
  STRING urlS : CSTRVAL,
  STRING filenameS : CSTRVAL,
  INTEGER dword,
  INTEGER tlpbindstatuscallback
) : "URLDownloadToFileA"
END

PROC Main()
STRING s1[255] = "http://www.google.com/index.html"
STRING s2[255] = "c:\temp\ddd.txt"
IF ( NOT ( Ask( "url: get: source: urlS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
IF ( NOT ( AskFilename( "url: get: source: filenameS = ", s2, _DEFAULT_, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 PROCUrlGetSource( s1, s2 )
 EditFile( s2 )
END

<F12> Main()

// --- LIBRARY --- //

// library: url: get: source <description></description> <version control></version control> <version>1.0.0.0.6</version> (filenamemacro=geturgso.s) [<Program>] [<Research>] [kn, ri, su, 13-04-2008 05:12:53]
PROC PROCUrlGetSource( STRING urlS, STRING filenameS )
 // e.g. DLL "<urlmon.dll>"
 // e.g.  INTEGER PROC FNUrlGetSourceApiI(
 // e.g.   INTEGER lpunknown,
 // e.g.   STRING urlS : CSTRVAL,
 // e.g.   STRING filenameS : CSTRVAL,
 // e.g.   INTEGER dword,
 // e.g.   INTEGER tlpbindstatuscallback
 // e.g. ) : "URLDownloadToFileA"
 // e.g. END
 // e.g.
 // e.g. PROC Main()
 // e.g. STRING s1[255] = "http://www.google.com/index.html"
 // e.g. STRING s2[255] = "c:\temp\ddd.txt"
 // e.g. IF ( NOT ( Ask( "url: get: source: urlS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g. IF ( NOT ( AskFilename( "url: get: source: filenameS = ", s2, _DEFAULT_, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  PROCUrlGetSource( s1, s2 )
 // e.g.  EditFile( s2 )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // http://rosettacode.org/wiki/HTTP#TSE_SAL
 //
 // ===
 //
 FNUrlGetSourceApiI( 0, urlS, filenameS, 0, 0 )
 //
END
