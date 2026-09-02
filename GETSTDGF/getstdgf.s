FORWARD PROC Main()
FORWARD STRING PROC FNStringGetTimeDifferenceGettimestrS( STRING s1, STRING s2 )


// --- MAIN --- //

PROC Main()
 STRING s1[255] = GetTimeStr()
 STRING s2[255] = GetTimeStr()
 IF ( NOT ( Ask( "Old GetTimeStr() value = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 IF ( NOT ( Ask( "New GetTimeStr() value = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 Warn( FNStringGetTimeDifferenceGettimestrS( s1, s2 ), " ", "seconds difference" ) // gives e.g. "315 seconds difference"
END


// --- LIBRARY --- //

// library: string: get: time: difference: gettimestr <description>LLM=OpenAI Codex</description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=getstdgf.s) [<Program>] [<Research>] [kn, ri, we, 02-09-2026 23:11:14]
STRING PROC FNStringGetTimeDifferenceGettimestrS( STRING getTimeStr1, STRING getTimeStr2 )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = GetTimeStr()
 // e.g.  STRING s2[255] = GetTimeStr()
 // e.g.  IF ( NOT ( Ask( "Old GetTimeStr() value = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "New GetTimeStr() value = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  Warn( FNStringGetTimeDifferenceGettimestrS( s1, s2 ), " ", "seconds difference" ) // gives e.g. "315 seconds difference"
 // e.g. END
 // e.g.
 //
 INTEGER I1 = 0
 INTEGER I2 = 0
 //
 // Convert HH:MM:SS to seconds.
 //
 I1 =   ( Val( SubStr( getTimeStr1, 1, 2 ) ) * 3600 )
      + ( Val( SubStr( getTimeStr1, 4, 2 ) ) * 60 )
      +   Val( SubStr( getTimeStr1, 7, 2 ) )
 //
 I2 =   ( Val( SubStr( getTimeStr2, 1, 2 ) ) * 3600 )
      + ( Val( SubStr( getTimeStr2, 4, 2 ) ) * 60 )
      +   Val( SubStr( getTimeStr2, 7, 2 ) )
 //
 // Assume midnight was crossed when the second time is earlier.
 //
 IF ( I2 < I1 )
  //
  I2 = I2 + ( 24 * 60 * 60 )
  //
 ENDIF
 //
 RETURN( Str( I2 - I1 ) )
 //
END
