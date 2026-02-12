FORWARD INTEGER PROC FNBlockChangeSettingConfigurationToSetB( INTEGER i1, STRING s1, STRING s2 )
FORWARD INTEGER PROC FNFileChangeSettingConfigurationToSetB( INTEGER i1, STRING s1, STRING s2, STRING s3 )
FORWARD PROC Main()
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 //
 INTEGER buffer1I = 0
 INTEGER buffer2I = 0
 STRING s1[255] = "c:\temp\ddd.s" // temporary file // change this
 STRING s2[255] = "f:\wordproc\tse32_v44200\sc32.exe" // change this
 STRING s3[255] = ""
 //
 PushPosition()
 buffer1I = CreateTempBuffer()
 PopPosition()
 //
 PushPosition()
 buffer2I = CreateTempBuffer()
 PopPosition()
 //
 PushPosition()
 PushBlock()
 GotoBufferId( buffer1I )
 //
 AddLine( "c:\temp\dddconfigurationfile1.cfg" ) // change this to a profile file on your computer
 AddLine( "c:\temp\dddconfigurationfile2.cfg" ) // change this to another profile file on your computer
 // ...
 // and so on for other or more configuration files (add that once only to this List() and recompile the TSE macro)...
 //
 GotoLine( 1 )
 IF List( "Choose an option", 80 )
  s3 = Trim( GetText( 1, 255 ) )
 ELSE
  AbandonFile( buffer1I )
  RETURN()
 ENDIF
 AbandonFile( buffer1I )
 PopBlock()
 PopPosition()
 //
 IF ( NOT ( Ask( "file: change: setting: configuration: to: set: fileNameTseMacroS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 IF ( NOT ( Ask( "file: change: setting: configuration: to: set: fileNameSc32ExecutableS = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 //
 Message( FNFileChangeSettingConfigurationToSetB( buffer2I, s1, s2, s3 ) ) // gives e.g. TRUE
 //
END

<F12> Main()

// --- LIBRARY --- //

// library: file: change: setting: configuration: to: set <description></description> <version control></version control> <version>1.0.0.0.10</version> <version control></version control> (filenamemacro=chanfivv.s) [<Program>] [<Research>] [kn, ri, mo, 19-09-2022 23:11:26]
INTEGER PROC FNFileChangeSettingConfigurationToSetB( INTEGER bufferI, STRING fileNameTseMacroS, STRING fileNameSc32ExecutableS, STRING fileNameConfigurationS )
 // e.g. PROC Main()
 // e.g.  //
 // e.g.  INTEGER buffer1I = 0
 // e.g.  INTEGER buffer2I = 0
 // e.g.  STRING s1[255] = "c:\temp\ddd.s" // temporary file // change this
 // e.g.  STRING s2[255] = "f:\wordproc\tse32_v44200\sc32.exe" // change this
 // e.g.  STRING s3[255] = ""
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  buffer1I = CreateTempBuffer()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  buffer2I = CreateTempBuffer()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  PushBlock()
 // e.g.  GotoBufferId( buffer1I )
 // e.g.  //
 // e.g.  AddLine( "c:\temp\dddconfigurationfile1.cfg" ) // change this to a profile file on your computer
 // e.g.  AddLine( "c:\temp\dddconfigurationfile2.cfg" ) // change this to another profile file on your computer
 // e.g.  // ...
 // e.g.  // and so on for other or more configuration files (add that once only to this List() and recompile the TSE macro)...
 // e.g.  //
 // e.g.  GotoLine( 1 )
 // e.g.  IF List( "Choose an option", 80 )
 // e.g.   s3 = Trim( GetText( 1, 255 ) )
 // e.g.  ELSE
 // e.g.   AbandonFile( buffer1I )
 // e.g.   RETURN()
 // e.g.  ENDIF
 // e.g.  AbandonFile( buffer1I )
 // e.g.  PopBlock()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  IF ( NOT ( Ask( "file: change: setting: configuration: to: set: fileNameTseMacroS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "file: change: setting: configuration: to: set: fileNameSc32ExecutableS = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  //
 // e.g.  Message( FNFileChangeSettingConfigurationToSetB( buffer2I, s1, s2, s3 ) ) // gives e.g. TRUE
 // e.g.  //
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // Use case = You want to make different TSE configuration files active on your demand while inside TSE
 //
 // ===
 //
 // Method =
 //
 // This is thus designed to be done completely
 // only from within TSE itself
 // (so no exit of TSE or restart of TSE or start of another TSE executable necessary)
 //
 // One simplest approach:
 //
 //  1. Keep your desired settings as usual in 1, 2, 3, ..., N different profile text files
 //
 //  2. Use a List() to load the desired current profile text file from those available profile text files
 //
 //  3. Then parse one after the other all lines in the currently loaded profile text file.
 //
 //  4. Each of those single lines contains a key = value pair, like
 //
 //      blablabla = 123
 //
 //      xyzxyz = ON
 //
 //       ...
 //
 //  5. Extract the key and the value
 //
 //  6. Then use Set() to enable or disable that key value pair in that line
 //
 //  7. You can not (by TSE design and syntax) use a string variable for the set name, so you will have to output it verbatim to a TSE macro and compile that
 //
 // ===
 //
 // Example:
 //
 // Input: snippet from a TSE configuration file
 //
 /*
--- cut here: begin --------------------------------------------------
StartUpFlags            = _STARTUP_MENU_
GUIStartUpFlags         = _USE_DEFAULT_WIN_POS_|_USE_LAST_SAVED_FONT_|_USE_LAST_SAVED_WIN_SIZE_
SingleInstance          = On
DefaultExt              = "ui s si c cpp h java pas inc bat prg txt doc html asm"
FileLocking             = _NONE_
LoadWildFromDos         = On
LoadWildFromInside      = On
PickFileChangesDir      = Off
PickFileFlags           = _ADD_DIRS_ | _ADD_SLASH_ | _DIRS_AT_TOP_
PickFileSortOrder       = "ne"
EOLType                 = 0         // 0=As Loaded, 1=^M (CR), 2=^J (LF), 3=^M^J (CR/LF)
EOFType                 = 2         // 0=nothing, 1=^Z, 2=EOLType, 3=EOLType+^Z
--- cut here: end ----------------------------------------------------
 */
 //
 // Output: a compilable TSE .s file with the configuration values set using Set()
 //
 /*
--- cut here: begin --------------------------------------------------
PROC Main()
 Set( StartUpFlags , _STARTUP_MENU_ )
 Set( GUIStartUpFlags , _USE_DEFAULT_WIN_POS_|_USE_LAST_SAVED_FONT_|_USE_LAST_SAVED_WIN_SIZE_ )
 Set( SingleInstance , On )
 Set( DefaultExt , "ui s si c cpp h java pas inc bat prg txt doc html asm" )
 Set( FileLocking , _NONE_ )
 Set( LoadWildFromDos , On )
 Set( LoadWildFromInside , On )
 Set( PickFileChangesDir , Off )
 Set( PickFileFlags , _ADD_DIRS_ | _ADD_SLASH_ | _DIRS_AT_TOP_ )
 Set( PickFileSortOrder , "ne" )
 Set( EOLType , 0 )
 Set( EOFType , 2 )
END
--- cut here: end ----------------------------------------------------
 */
 //
 INTEGER B = FALSE
 //
 PushPosition()
 PushBlock()
 //
 B = FileExists( fileNameConfigurationS )
 //
 IF ( B )
  //
  EditFile( fileNameConfigurationS )
  //
  MarkLine( 1, NumLines() )
  //
  B = FNBlockChangeSettingConfigurationToSetB( bufferI, fileNameTseMacroS, fileNameSc32ExecutableS )
  //
 ELSE
  //
  Warn( fileNameConfigurationS, ":", " ", "can not be found. Please check." )
  PopBlock()
  PopPosition()
  B = FALSE
  RETURN( B )
  //
 ENDIF
 //
 PopBlock()
 PopPosition()
 //
 RETURN( B )
 //
END

// library: block: change: setting: configuration: to: set <description></description> <version control></version control> <version>1.0.0.0.17</version> <version control></version control> (filenamemacro=chanblux.s) [<Program>] [<Research>] [kn, ri, mo, 19-09-2022 22:05:07]
INTEGER PROC FNBlockChangeSettingConfigurationToSetB( INTEGER bufferI, STRING fileNameTseMacroS, STRING fileNameSc32ExecutableS )
 // e.g. PROC Main()
 // e.g.  //
 // e.g.  INTEGER bufferI = 0
 // e.g.  STRING s1[255] = "c:\temp\ddd.s" // temporary file // change this
 // e.g.  STRING s2[255] = "f:\wordproc\tse32_v44200\sc32.exe" // change this
 // e.g.  IF ( NOT ( Ask( "block: change: setting: configuration: to: set: fileNameTseMacroS = ", s1, _EDIT_HISTORY_ ) ) AND ( Length( s1 ) > 0 ) ) RETURN() ENDIF
 // e.g.  IF ( NOT ( Ask( "block: change: setting: configuration: to: set: fileNameSc32ExecutableS = ", s2, _EDIT_HISTORY_ ) ) AND ( Length( s2 ) > 0 ) ) RETURN() ENDIF
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  bufferI = CreateTempBuffer()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  Message( FNBlockChangeSettingConfigurationToSetB( bufferI, s1, s2 ) ) // gives e.g. TRUE
 // e.g.  //
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER B = FALSE
 //
 STRING s1[255] = ""
 STRING s2[255] = ""
 //
 STRING fileNameTseMacroMacS[255] = ""
 //
 INTEGER downB = TRUE
 //
 IF ( NOT ( IsBlockInCurrFile() ) ) Warn( "Please mark a block" ) B = FALSE RETURN( B ) ENDIF // return from the current procedure if no block is marked
 //
 Set( BREAK, ON )
 //
 // erase / refresh / clean up
 //
 PushPosition()
 PushBlock()
 //
 PushPosition()
 PushBlock()
 IF EditFile( fileNameTseMacroS )
  AbandonFile()
 ENDIF
 EraseDiskFile( fileNameTseMacroS )
 PopPosition()
 PopBlock()
 //
 // erase / refresh / clean up
 //
 PushPosition()
 PushBlock()
 IF EditFile( fileNameTseMacroMacS )
  AbandonFile()
 ENDIF
 EraseDiskFile( fileNameTseMacroMacS )
 PopPosition()
 PopBlock()
 //
 AddLine( "PROC Main()", bufferI )
 //
 GotoBlockBegin()
 //
 WHILE ( ( IsCursorInBlock() ) AND ( downB ) )
  //
  // skip empty lines
  //
  IF NOT LFind( "^$", "cgx" )
   //
   IF LFind( "{.*}[ ]+=[ ]+{.*}{{//}|$}", "cgx" )
    s1 = GetFoundText( 1 )
    s1 = Trim( s1 )
    s2 = GetFoundText( 2 )
    s2 = Trim( s2 )
    AddLine( Format( "Set(", " ", s1, " ", ",", " ", s2, " ", ")" ), bufferI )
   ENDIF
   //
  ENDIF
  //
  downB = Down()
  //
 ENDWHILE
 //
 AddLine( "END", bufferI )
 //
 GotoBufferId( bufferI )
 SaveAs( fileNameTseMacroS, _OVERWRITE_ )
 Dos( Format( QuotePath( fileNameSc32ExecutableS ), " ", QuotePath( fileNameTseMacroS ) ), _DONT_PROMPT_ )
 fileNameTseMacroMacS = Format( SplitPath( fileNameTseMacroS, _DRIVE_ | _PATH_ | _NAME_ ), ".", "mac" )
 IF FileExists( fileNameTseMacroMacS )
  PurgeMacro( fileNameTseMacroMacS )
  ExecMacro( fileNameTseMacroMacS )
  B = TRUE
 ELSE
  Warn( "File", ":", " ", fileNameTseMacroS, ":", " ", "could not be compiled by", ":", " ", fileNameSc32ExecutableS, ".", " ", "Please check." )
  B = FALSE
 ENDIF
 //
 AbandonFile( bufferI )
 //
 PopPosition()
 PopBlock()
 //
 RETURN( B )
 //
END
