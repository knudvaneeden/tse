FORWARD PROC Main()
FORWARD PROC PROCProgramSaveStateEditorTextFilenameTse( STRING s1 )


// --- MAIN --- //

PROC Main()
 STRING s1[255] = "*.dat"
 IF ( NOT ( AskFilename( "program: save: state: editor: text: filename: tse: fileNameS = ", s1, _DEFAULT_, _EDIT_HISTORY_ ) ) ) RETURN() ENDIF
 PROCProgramSaveStateEditorTextFilenameTse( s1 )
END

<F12> Main()

// --- LIBRARY --- //

// library: program: save: state: editor: text: filename: tse <description></description> <version>1.0.0.0.7</version> <version control></version control> (filenamemacro=saveprft.s) [<Program>] [<Research>] [kn, ri, sa, 08-01-2011 19:43:05]
PROC PROCProgramSaveStateEditorTextFilenameTse( STRING fileNameS )
 // e.g. PROC Main()
 // e.g.  STRING s1[255] = "*.dat"
 // e.g.  IF ( NOT ( AskFilename( "program: save: state: editor: text: filename: tse: fileNameS = ", s1, _DEFAULT_, _EDIT_HISTORY_ ) ) ) RETURN() ENDIF
 // e.g.  PROCProgramSaveStateEditorTextFilenameTse( s1 )
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // Note: by default the state macro will create 2 files, a .kbd file and a .dat file.
 //
 //
 ExecMacro( Format( "state", " ", "-s", " ", "-f", fileNameS ) )
 //
END
