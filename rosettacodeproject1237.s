FORWARD PROC Main()
FORWARD PROC PROCProgramRunTowersofhanoiRecursive( INTEGER i1, STRING s1, STRING s2, STRING s3 )
FORWARD PROC PROCProgramRunTowersofhanoiRecursiveSub( INTEGER i1, STRING s1, STRING s2, STRING s3, INTEGER i2 )


// --- MAIN --- //

PROC Main()
STRING s1[255] = "4"
IF ( NOT ( Ask( "program: run: towersofhanoi: recursive: totalDiskI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 PROCProgramRunTowersofhanoiRecursive( Val( s1 ), "source", "target", "via" )
END

<F12> Main()

// --- LIBRARY --- //

// library: program: run: towersofhanoi: recursive <description></description> <version>1.0.0.0.10</version> <version control></version control> (filenamemacro=runprtre.s) [<Program>] [<Research>] [kn, ri, tu, 07-02-2012 19:40:45]
PROC PROCProgramRunTowersofhanoiRecursive( INTEGER totalDiskI, STRING fromS, STRING toS, STRING viaS )
 // e.g. PROC Main()
  // e.g. STRING s1[255] = "4"
  // e.g. IF ( NOT ( Ask( "program: run: towersofhanoi: recursive: totalDiskI = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  PROCProgramRunTowersofhanoiRecursive( Val( s1 ), "source", "target", "via" )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // http://rosettacode.org/wiki/Towers_of_Hanoi
 //
 // ===
 //
 INTEGER bufferI = 0
 //
 PushPosition()
 bufferI = CreateTempBuffer()
 PopPosition()
 //
 PROCProgramRunTowersofhanoiRecursiveSub( totalDiskI, fromS, toS, viaS, bufferI )
 //
 GotoBufferId( bufferI )
 //
END

// library: program: run: towersofhanoi: recursive: sub <description></description> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=runprrsu.s) [<Program>] [<Research>] [kn, ri, tu, 07-02-2012 19:54:23]
PROC PROCProgramRunTowersofhanoiRecursiveSub( INTEGER totalDiskI, STRING fromS, STRING toS, STRING viaS, INTEGER bufferI )
 // e.g. PROC Main()
 // e.g.  PROCProgramRunTowersofhanoiRecursiveSub( totalDiskI, fromS, toS, viaS, bufferI )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 IF ( totalDiskI == 0 )
  //
  RETURN()
  //
 ENDIF
 //
 PROCProgramRunTowersofhanoiRecursiveSub( totalDiskI - 1, fromS, viaS, toS, bufferI ) // first move a tower of N-1 disks from the 'source' peg to the 'via' peg (using the 'target' peg as an intermediate)
 //
 AddLine( Format( "Move disk", " ", totalDiskI, " ", "from peg", " ", "'", fromS, "'", " ", "to peg", " ", "'", toS, "'" ), bufferI )
 //
 PROCProgramRunTowersofhanoiRecursiveSub( totalDiskI - 1, viaS, toS, fromS, bufferI ) // then move the *same* tower of N-1 disks from the 'via' peg to the 'target' peg (using the 'source' peg as an intermediate)
 //
END
