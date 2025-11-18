// Revision: 1
//
// ===
//
// Macro     Git.s
// Author    Adapted from Carlo.Hogeveen@xs4all.nl by ChatGPT
// Date      16 Nov 2025
// Version   0.9-git
//
// ===
//
// Purpose:
//   A fast Git browser for large working trees.
//
// Why:
//   GUI tools can be very slow on directories with many files.
//
// Installation:
//   The "git" macro is "just" a shell around the "git" commandline tool.
//   Therefore the commandline-tool "git" must be installed and in the PATH
//   environment variable, either in general or from where TSE is started.
//
//   As for the macro, just put it in TSE's "mac" directory,
//   and compile and execute it.
//
// Features:
//   - Browsing a Git working directory's directories and files.
//   - Viewing their history, info and attributes via Git.
//   - Reading or editing the current or a historic version of a file
//     (editing is local in TSE; the macro does not commit).
//
// Wishlist / TODO (parity with SVN version):
//   - Ask for username/password for remote operations if needed (currently
//     relies on Git's own credential handling).
//   - More detailed diff integration and branch selection.
//
// ===

#DEFINE LANGUAGE _DEFAULT_
//
// Help text shown with F1.
DATADEF help_text
 'This is a fast Git browser, specifically intended for browsing'
 'those really large directories, for which GUI Git tools can be slow.'
 ''
 'The top of the screen shows which object is currently selected.'
 'If you opened a historic version from the log, the commit hash'
 'is shown after an @.'
 ''
 'The bottom of the screen continuously shows possible actions.'
 'A file is opened for read first, and for editing separately.'
 'Editing leaves the browser, and does not mean you can commit the file'
 'to Git, but "only" that you get all the editing options of TSE.'
 '"Props" stands for "Properties": a file" + "s Git attributes.'
 ''
 'Browse keys: Arrow(Up/Down), PageUp, PageDown, Home, End.'
 'Use . for current directory and .. for parent directory.'
 ''
 'Function keys while browsing:'
 '  F1  - Help'
 '  F5  - History (git log --oneline)'
 '  F8  - Info   (last commit for file)'
 '  F9  - Props  (git check-attr -a)'
 '  F10 - Diff   (git diff HEAD -- file)'
 '  Enter - View file or directory'
 '  Esc   - Quit macro'
END help_text

#DEFINE STATE_ERROR     0
#DEFINE STATE_OK        1
#DEFINE STATE_STOPPED   3

STRING curr_list[ MAXSTRINGLEN ] = ''
STRING file_revision[ MAXSTRINGLEN ] = ''   // commit hash for Git
STRING git_relpath[ MAXSTRINGLEN ] = ''     // path relative to Git root
STRING list_header[ MAXSTRINGLEN ] = ''
STRING log_file[ MAXSTRINGLEN ] = ''
INTEGER log_id = 0
STRING list_footer[ MAXSTRINGLEN ] = ''
STRING macro_name[ MAXSTRINGLEN ] = ''
STRING next_list[ MAXSTRINGLEN ] = 'browse'
INTEGER org_id = 0
STRING selected_file[ MAXSTRINGLEN ] = ''
STRING selected_property[ MAXSTRINGLEN ] = ''

// Path to your Git executable - ADAPT THIS:
STRING versionControlExecutableGS[ MAXSTRINGLEN ] = "g:\cygwin\bin\git.exe"

// Default working directory to start browsing in:
STRING workingDirectoryGS[ MAXSTRINGLEN ] = "c:\temp\ddd01"

KEYDEF extra_list_keys
 <f1>  next_list = 'help'     PushKey(<Enter>)
 <f5>  next_list = 'log'      PushKey(<Enter>)
 <f8>  next_list = 'info'     PushKey(<Enter>)
 <f9>  next_list = 'proplist' PushKey(<Enter>)
 <f10> next_list = 'diff'     PushKey(<Enter>)
END

INTEGER PROC get_dos( STRING cmd )
 INTEGER result = FALSE

 EraseDiskFile( log_file )
 IF Dos( cmd + ' > ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  GotoBufferId( log_id )
  EmptyBuffer()
  IF FileExists( log_file )
   InsertFile( log_file, _DONT_PROMPT_ )
   UnMarkBlock()
   EndFile()
   WHILE ( ( CurrLine() > 1 ) AND ( CurrLineLen() == 0 ) )
    KillLine()
    Up()
   ENDWHILE
   BegFile()
   EraseDiskFile( log_file )
   result = TRUE
  ENDIF
 ENDIF

 RETURN( result )
END get_dos

PROC show_dos_error( STRING text )
 STRING warning[ MAXSTRINGLEN ] = text

 BegFile()
 REPEAT
  warning = warning + Chr( 13 ) + RTrim( GetText( 1, MAXSTRINGLEN ) )
 UNTIL NOT Down()
 Warn( warning )
END show_dos_error

INTEGER PROC set_log_file()
 INTEGER org_id_local = GetBufferId()
 INTEGER result = STATE_ERROR
 STRING tmp_dir[ MAXSTRINGLEN ] = ''

 IF GetEnvStr( 'tmp' ) <> ''
  tmp_dir = GetEnvStr( 'tmp' )
 ELSEIF GetEnvStr( 'temp' ) <> ''
  tmp_dir = GetEnvStr( 'temp' )
 ELSE
  tmp_dir = 'c:'
 ENDIF

 IF tmp_dir[Length( tmp_dir )] <> '\'
  tmp_dir = tmp_dir + '\'
 ENDIF

 IF ( FileExists( tmp_dir ) & _DIRECTORY_ )
  log_file = tmp_dir + 'TseGit.log'
  log_id   = EditFile( log_file, _DONT_PROMPT_ )
  IF log_id
   EmptyBuffer()
   InsertText( 'Hello world!' )
   IF SaveAs( CurrFilename(), _DONT_PROMPT_|_OVERWRITE_ )
    result = STATE_OK
   ELSE
    AbandonFile( log_id )
   ENDIF
   GotoBufferId( org_id_local )
  ENDIF
 ENDIF

 IF result <> STATE_OK
  Warn( 'Error: cannot create a temporary file: ', log_file )
 ENDIF

 RETURN( result )
END set_log_file

// Resolve path of selected_file relative to the Git root.
// Returns TRUE if the file is tracked by Git.
INTEGER PROC resolve_git_relpath( STRING curr_path, STRING filename )
 INTEGER ok = FALSE

 git_relpath = ''

 IF get_dos( QuotePath( versionControlExecutableGS ) + ' -C ' +
             QuotePath( curr_path ) + ' ls-files --full-name ' +
             QuotePath( filename ) )
  BegFile()
  IF LFind( '^fatal: ', 'gx' )
   ok = FALSE
  ELSEIF CurrLineLen() > 0
   git_relpath = Trim( GetText( 1, MAXSTRINGLEN ) )
   ok = ( git_relpath <> '' )
  ENDIF
 ENDIF

 RETURN( ok )
END resolve_git_relpath

// Ask for working directory or file to start browsing.
INTEGER PROC ask_repository( VAR STRING repository, VAR STRING dir, VAR STRING selected )
 INTEGER state = STATE_OK
 STRING request[ MAXSTRINGLEN ] = workingDirectoryGS

 IF Ask( 'Git working directory OR selected file:', request,
         GetFreeHistory( macro_name + ':request' ) )
  request = Trim( request )

  // Remove trailing slashes
  WHILE ( Length( request ) > 0 ) AND
        ( ( request[Length( request )] == '\' ) OR
          ( request[Length( request )] == '/' ) )
   request = SubStr( request, 1, Length( request ) - 1 )
  ENDWHILE

  IF request == ''
   state = STATE_STOPPED
  ELSE
   // Decide whether request is dir or file
   IF ( FileExists( request ) & _DIRECTORY_ )
    repository = request
    dir        = ''
    selected   = ''
   ELSE
    // Treat as file
    repository = SplitPath( request, _PATH_ )
    dir        = ''
    selected   = SplitPath( request, _NAME_|_EXT_ )
   ENDIF
  ENDIF
 ELSE
  state = STATE_STOPPED
 ENDIF

 RETURN( state )
END ask_repository

PROC list_startup()
 UnHook( list_startup )

 CASE next_list
  WHEN 'browse'
   Enable( extra_list_keys )
 ENDCASE

 ListFooter( list_footer )
END list_startup

PROC list_cleanup()
 Disable( extra_list_keys )
END list_cleanup

INTEGER PROC browse_repository( STRING repository, VAR STRING dir )
 INTEGER old_msglevel = 0
 INTEGER state        = STATE_OK
 STRING curr_path[ MAXSTRINGLEN ] = ''
 STRING full_file[ MAXSTRINGLEN ] = ''
 STRING line[ MAXSTRINGLEN ] = ''

 // list_header = repository
 list_header = repository + IIF( dir == '', '', '/' + dir ) + IIF( selected_file == '', '', '/' + selected_file ) + IIF( file_revision == '', '', '@' + file_revision )
 list_footer = '{Enter}-Back {Escape}-Back'
 curr_list   = next_list

 CASE next_list

  // --- BROWSE DIRECTORY --------------------------------------------------
  WHEN 'browse'
   curr_path   = repository + IIF( dir == '', '', '/' + dir )
   list_header = curr_path
   list_footer = '{F1}-Help {F5}-Hist {F8}-Info {F9}-Props {F10}-Diff {Enter}-Read {Esc}-Quit'

   // List directory contents (filesystem, not Git)
   get_dos( 'dir ' + QuotePath( curr_path ) + ' /b' )

   // Sort if there is content
   IF NumLines() > 0
    MarkLine( 1, NumLines() )
    old_msglevel = Set( MsgLevel, _WARNINGS_ONLY_ )
    ExecMacro( 'sort -i' )
    Set( MsgLevel, old_msglevel )
    UnMarkBlock()
   ENDIF

   // Insert "." or ".." at top
   BegFile()
   IF dir == ''
    InsertLine( '.' )
   ELSE
    InsertLine( '..' )
   ENDIF

   // Try to position on previously selected file
   LFind( selected_file, 'g' )

  // --- SHOW FILE CONTENT (VIEW) -----------------------------------------
  WHEN 'cat'
   list_footer = '{Enter}-Edit {Escape}-Back'
   curr_path   = repository + IIF( dir == '', '', '/' + dir )

   // Build full filesystem path
   IF ( curr_path[Length( curr_path )] <> '\' ) AND
      ( curr_path[Length( curr_path )] <> '/' )
    full_file = curr_path + '/' + selected_file
   ELSE
    full_file = curr_path + selected_file
   ENDIF

   // Try to resolve relative Git path
   resolve_git_relpath( curr_path, selected_file )

   IF file_revision == ''
    // HEAD / working version
    IF git_relpath <> ''
     get_dos( QuotePath( versionControlExecutableGS ) + ' -C ' +
              QuotePath( curr_path ) + ' show HEAD:' +
              QuotePath( git_relpath ) )
    ELSE
     // Not tracked by Git, just show working file
     get_dos( 'type ' + QuotePath( full_file ) )
    ENDIF
   ELSE
    // Historic version
    IF git_relpath <> ''
     get_dos( QuotePath( versionControlExecutableGS ) + ' -C ' +
              QuotePath( curr_path ) + ' show ' + file_revision + ':' +
              QuotePath( git_relpath ) )
    ELSE
     Warn( 'File not under Git control; no historic versions available.' )
     state = STATE_ERROR
    ENDIF
   ENDIF

   IF LFind( '^fatal: ', 'gx' )
    state = STATE_ERROR
    show_dos_error( 'Error from Git:' )
   ENDIF

  // --- EDIT CURRENT / HISTORIC VERSION ----------------------------------
  WHEN 'edit'
   curr_path = repository + IIF( dir == '', '', '/' + dir )

   IF ( curr_path[Length( curr_path )] <> '\' ) AND
      ( curr_path[Length( curr_path )] <> '/' )
    full_file = curr_path + '/' + selected_file
   ELSE
    full_file = curr_path + selected_file
   ENDIF

   resolve_git_relpath( curr_path, selected_file )

   // Load into log buffer, like in 'cat'
   IF file_revision == ''
    IF git_relpath <> ''
     get_dos( QuotePath( versionControlExecutableGS ) + ' -C ' +
              QuotePath( curr_path ) + ' show HEAD:' +
              QuotePath( git_relpath ) )
    ELSE
     get_dos( 'type ' + QuotePath( full_file ) )
    ENDIF
   ELSE
    IF git_relpath <> ''
     get_dos( QuotePath( versionControlExecutableGS ) + ' -C ' +
              QuotePath( curr_path ) + ' show ' + file_revision + ':' +
              QuotePath( git_relpath ) )
    ELSE
     Warn( 'File not under Git control; no historic versions available.' )
     state = STATE_ERROR
    ENDIF
   ENDIF

   IF LFind( '^fatal: ', 'gx' )
    state = STATE_ERROR
    show_dos_error( 'Error from Git:' )
   ELSE
    // Move this version to a new edit buffer
    MarkLine( 1, NumLines() )
    Copy()
    org_id = NewFile()
    Paste()
    UnMarkBlock()
    IF FileExists( list_header )
     EditFile( list_header )
     AbandonFile()
    ENDIF
    ChangeCurrFilename( list_header, _DONT_EXPAND_ )
    // Optional diff using TSE's compblct macro (toggle via global int)
    // IF ( ( GetGlobalInt( "diffGI" ) MOD 2 ) == 0 )
     IF YesNo( "Run diff (compblct)?" ) == 1
      ExecMacro( "compblct" )
      PurgeMacro( "compblct" )
     ENDIF
     // SetGlobalInt( "diffGI", 0 )  // reset
    // ENDIF
    state = STATE_STOPPED
   ENDIF

  // --- HELP --------------------------------------------------------------
  WHEN 'help'
   EmptyBuffer()
   InsertData( help_text )
   BegFile()

  // --- INFO (last commit for file) --------------------------------------
  WHEN 'info'
   curr_path = repository + IIF( dir == '', '', '/' + dir )
   get_dos( QuotePath( versionControlExecutableGS ) + ' -C ' +
            QuotePath( curr_path ) + ' log -1 --stat -- ' +
            QuotePath( selected_file ) )
   IF LFind( '^fatal: ', 'gx' )
    state = STATE_ERROR
    show_dos_error( 'Error from Git:' )
   ENDIF

  // --- LOG (history) -----------------------------------------------------
  WHEN 'log'
   list_footer = '{Enter}-Read {Esc}-Back'
   curr_path   = repository + IIF( dir == '', '', '/' + dir )

   get_dos( QuotePath( versionControlExecutableGS ) + ' -C ' +
            QuotePath( curr_path ) +
            ' log --oneline --decorate -- ' +
            QuotePath( selected_file ) )

   IF LFind( '^fatal: ', 'gx' )
    state = STATE_ERROR
    show_dos_error( 'Error from Git:' )
   ENDIF

  // --- PROPLIST (Git attributes) ----------------------------------------
  WHEN 'proplist'
   curr_path = repository + IIF( dir == '', '', '/' + dir )
   get_dos( QuotePath( versionControlExecutableGS ) + ' -C ' +
            QuotePath( curr_path ) + ' check-attr -a -- ' +
            QuotePath( selected_file ) )
   IF LFind( '^fatal: ', 'gx' )
    state = STATE_ERROR
    show_dos_error( 'Error from Git:' )
   ELSE
    LFind( selected_property, 'g' )
   ENDIF

  // --- DIFF (Git diff) ---------------------------------------------------
  WHEN 'diff'
   list_footer = '{Esc}-Back'
   curr_path   = repository + IIF( dir == '', '', '/' + dir )

   IF file_revision == ''
    // diff vs HEAD
    get_dos( QuotePath( versionControlExecutableGS ) + ' -C ' +
             QuotePath( curr_path ) + ' diff HEAD -- ' +
             QuotePath( selected_file ) )
   ELSE
    // diff selected commit vs its parent
    get_dos( QuotePath( versionControlExecutableGS ) + ' -C ' +
             QuotePath( curr_path ) + ' diff ' +
             file_revision + '^ ' + file_revision + ' -- ' +
             QuotePath( selected_file ) )
   ENDIF

   IF LFind( '^fatal: ', 'gx' )
    state = STATE_ERROR
    show_dos_error( 'Error from Git:' )
   ENDIF

  OTHERWISE
   Warn( 'Error: unknown action (1).' )
   state = STATE_ERROR
 ENDCASE

 // --- Show list / react to choice ---------------------------------------
 IF state == STATE_OK
  Hook( _LIST_STARTUP_, list_startup )
  Hook( _LIST_CLEANUP_, list_cleanup )

  IF List( list_header,
           Max( Max( Length( list_header ),
                     Length( list_footer ) ),
                LongestLineInBuffer() ) )
   UnHook( list_cleanup )

   CASE curr_list

    WHEN 'browse'
     selected_file = GetText( 1, CurrLineLen() )

     IF next_list == 'browse'
      IF selected_file == '..'
       // Go up one directory
       selected_file = SplitPath( dir, _NAME_|_EXT_ )
       dir = SplitPath( dir, _PATH_ )
       WHILE ( Length( dir ) > 0 ) AND
             ( ( dir[Length( dir )] == '/' ) OR
               ( dir[Length( dir )] == '\' ) )
        dir = SubStr( dir, 1, Length( dir ) - 1 )
       ENDWHILE

      ELSEIF selected_file == '.'
       // Stay in current dir
       dir = dir

      ELSE
       // Decide whether selection is a directory on disk
       curr_path = repository + IIF( dir == '', '', '/' + dir )

       IF ( curr_path[Length( curr_path )] <> '\' ) AND
          ( curr_path[Length( curr_path )] <> '/' )
        full_file = curr_path + '/' + selected_file
       ELSE
        full_file = curr_path + selected_file
       ENDIF

       IF ( FileExists( full_file ) & _DIRECTORY_ )
        // Enter subdirectory
        IF dir == ''
         dir = selected_file
        ELSE
         dir = dir + '/' + selected_file
        ENDIF
       ELSE
        // It's a file: view it
        next_list     = 'cat'
        file_revision = ''
       ENDIF
      ENDIF

     ELSE
      // Entered via F-key (log/info/props/diff). If '..' then go back to browse.
      IF selected_file == '..'
       next_list = 'browse'
      ENDIF
     ENDIF

    WHEN 'cat'
     next_list = 'edit'

    WHEN 'help'
     next_list = 'browse'

    WHEN 'info'
     next_list = 'browse'

    WHEN 'log'
     // Selected a line in git log; take first token as commit hash
     line = Trim( GetText( 1, CurrLineLen() ) )
     IF line <> ''
      file_revision = GetToken( line, ' ', 1 )
      next_list     = 'cat'
     ELSE
      next_list     = 'log'
     ENDIF

    WHEN 'proplist'
     next_list = 'browse'

    WHEN 'diff'
     next_list = 'browse'

    OTHERWISE
     Warn( 'Error: unknown action (2).' )
     state = STATE_ERROR
   ENDCASE

  ELSE
   // User pressed ESC in list
   CASE curr_list
    WHEN 'browse'
     state = STATE_STOPPED

    WHEN 'cat'
     next_list = 'browse'

    WHEN 'help'
     next_list = 'browse'

    WHEN 'info'
     next_list = 'browse'

    WHEN 'log'
     next_list = 'browse'

    WHEN 'proplist'
     next_list = 'browse'

    WHEN 'diff'
     next_list = 'browse'

    OTHERWISE
     Warn( 'Error: unknown action (3).' )
     state = STATE_ERROR
   ENDCASE
  ENDIF
 ENDIF

 RETURN( state )
END browse_repository

PROC WhenLoaded()
 macro_name = SplitPath( CurrMacroFilename(), _NAME_ )
END WhenLoaded

PROC Main()
 STRING  dir[ MAXSTRINGLEN ] = ''
 STRING  repository[ MAXSTRINGLEN ] = ''
 INTEGER state = STATE_OK

 // Let user override git.exe path if desired
 IF ( NOT ( Ask( "path to your Git executable = ",
                 versionControlExecutableGS, _EDIT_HISTORY_ ) ) AND
      ( Length( versionControlExecutableGS ) > 0 ) )
  RETURN()
 ENDIF

 // SetGlobalInt( "diffGI", GetGlobalInt( "diffGI" ) + 1 )

 org_id = GetBufferId()
 state  = set_log_file()

 WHILE state == STATE_OK
  state = ask_repository( repository, dir, selected_file )
  WHILE state == STATE_OK
   state = browse_repository( repository, dir )
  ENDWHILE
 ENDWHILE

 GotoBufferId( org_id )
 AbandonFile( log_id )
 PurgeMacro( macro_name )

 // If TSE was started as: e -eGit and no file was opened, close editor
 IF ( ( Lower( Trim( Query( DosCmdLine ) ) ) IN '-egit', '-e git' ) AND
      ( NumFiles() == 1 ) AND
      ( Pos( 'unnamed', Lower( CurrFilename() ) ) > 0 ) )
  AbandonEditor()
  // SetGlobalInt( "diffGI", 0 )
 ENDIF
END Main

