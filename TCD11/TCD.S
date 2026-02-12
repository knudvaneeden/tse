// TCD.S  05/21/1993  06/05/1993
// by Richard Hendricks

// Version 1.0 - 05/21/1993  Used DOS( CD,..) to change directory
// Version 1.1 - 06/05/1993  Uses Richard Blackburn's change directory BIN

binary ['dirchng.bin']        // Written by Richard BlackBurn / SemWare Corporation
    integer proc cd(string dir):0
end

proc MAIN()
  integer dirID, cmdID
  string cmdFname[128] = GetEnvStr( "MACPATH" )+"tcd.tmp"
  string gotoDIR[128] = "",
         userDIR[128] = ""

  ClrScr()
  Message( "The Semware Editor Directory Changer þ TCD þ Version 1.1" )
  dirID = GetBufferID()

  cmdID = EditFile( cmdFname )
  userDIR = GetText( 1, sizeof( userDIR ) ) // Unchanged/Original Request
  BegFile()
  LReplace( "*", ".@", "n" )  // DOS *'s to TSE Regular Expression: .@ 0 or more any character
  BegFile()
  LReplace( "?", ".", "n" )   // DOS ?'s to TSE Regular Expression: any character
  BegFile()
  LReplace( "\", "\\", "n" )  // DOS \ to TSE Regular Expression: \\
  BegFile()
  gotoDIR = GetText( 1, sizeof( gotoDIR ) )

  GotoBufferID( dirID )
  gotoDIR = iif( gotoDIR[1] <> "\" and not pos( ":", gotoDIR ), "\\", "" ) + gotoDIR
  if LFind( gotoDIR, "IX" )
    gotoDIR = GetText( 1, sizeof( gotoDIR ) )
    cd( gotoDIR + Chr(0) )                  // Calls DIRCHNG.BIN
    LogDrive( SplitPath( gotoDIR, _DRIVE_ ) )
  else
    warn( "'"+userDIR+"' wasn't found" )
  endif
  AbandonEditor()
end MAIN
// end-of-file TCD.S
