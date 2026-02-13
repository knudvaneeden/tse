// Revision: 14974
//
// ===
//
// Macro     Git.s
// Author    Carlo.Hogeveen@xs4all.nl
// Date      25 May 2012
// Version   See the history and the help_text.
//
// ===
//
// Purpose:
//   The fastest possible Git browser.
//
// Why:
//   Tortoisesvn is beyond too slow for directories with many files.
//
// Trade-off:
//   A selected file's Git-properties are initially not shown.
//
// Installation:
//   The "git" macro is "just" a shell around the "svn" commandline tool,
//   which is [a part of] the actual Git tool.
//   Therefore the commandline-tool "git" must be installed and in the PATH
//   environment variable, either in general or from where TSE is started.
//
//   Either download the latest version of Git GUI tools (1.7.7 as I write,
//   which also includes and installs "SVN") from
//   http://tortoisesvn.net/downloads.html ,
//
//   or download one of the binary packages for "svn" for Windows at the
//   bottom of the page of
//   http://subversion.apache.org/packages.html .
//
//   As for the macro, just put it in TSE's "mac" directory,
//   and compile and execute it.
//
// Features:
//   Browsing the HEAD of a Git repository's directories and files,
//   view their info, properties, and history, and read or edit [the historic
//   version of] a file (without saving to the repository).
//
// NOT a feature (yet):
//   Git security: the repository must either be publicly accessible,
//   or the username and password must already be locally stored
//   by (Tortoise)SVN itself.
//
// Wishlist:
// MUST
// - Being asked for a username and password when required by the repository.
// SHOULD
// - Closing a selected historic object should return to the history-list.
// - Being able to browse historic repository directories.
// - In the history-list you should not be able to select the separation lines.
// - Putting the @<revision> before the file-extension to enable
//   syntax-hiliting.
// COULD
// - Being able to compare two versions.
// WOULD
// - Make the macro also compileable to a .exe.
//
// History:
// 0.9   25 May 2012
//   - Initial version.
// 0.9.1  3 Jun 2012
//   - If started from the command-line with "-eSvn" and no file was opened
//     for editing, then TSE is closed with the macro.
// 0.9.2  25 Feb 2013
//     - Changed the helptext and a warning to English.
//
#DEFINE LANGUAGE _DEFAULT_
//
DATADEF help_text
 'This is a fast Git browser, intended for browsing large working-tree'
 'directories where GUI tools can feel slow.'
 ''
 'The top of the screen shows which object is currently selected.'
 'An @ followed by a commit hash indicates you look at that historic'
 'version of the file.'
 'Is there no @, then you look at the current working-tree version.'
 ''
 'The bottom of the screen continuously shows possible actions.'
 'A file is opened for read first, and for editing separately.'
 'Editing leaves the browser, and does not mean you can Save the file'
 '(directly) but "only" that you get all the editing options of TSE.'
 '"Props" shows Git-related information (status / last commit / etc.).'
 ''
 'In a list and when reading a file you can type a string of'
 'characters to quickly go to their first occurrence.'
 ''
 'Browse keys: Arrow(Up/Down), PageUp, PageDown, Home, End.'
END help_text
//
#DEFINE STATE_ERROR     0
#DEFINE STATE_OK        1
#DEFINE STATE_STOPPED   3
//
STRING curr_list[ MAXSTRINGLEN ] = ''
STRING file_revision[ MAXSTRINGLEN ] = ''
STRING list_header[ MAXSTRINGLEN ] = ''
STRING log_file[ MAXSTRINGLEN ] = ''
INTEGER log_id = 0
STRING list_footer[ MAXSTRINGLEN ] = ''
STRING macro_name[ MAXSTRINGLEN ] = ''
STRING next_list[ MAXSTRINGLEN ] = 'browse'
INTEGER org_id = 0
STRING selected_file[ MAXSTRINGLEN ] = ''
STRING selected_property[ MAXSTRINGLEN ] = ''
//
STRING fileNameCurrentGS[ MAXSTRINGLEN ] = '' // [kn, ri, fr, 30-01-2026 12:22:54]
//
// STRING versionControlExecutableGS[ MAXSTRINGLEN ] = "c:\program files\cygwin\bin\bash.exe" // change this // [kn, ri, fr, 19-08-2022 12:22:17]
STRING versionControlExecutableGS[ MAXSTRINGLEN ] = "g:\cygwin\bin\bash.exe" // change this // [kn, ri, fr, 19-08-2022 12:22:17]
STRING gitExecutableGS[ MAXSTRINGLEN ] = "git" // git executable inside Cygwin bash PATH
// STRING workingDirectoryGS[ MAXSTRINGLEN ] = "/cygdrive/c/TEMP/W1" // old [kn, ri, sa, 13-08-2022 16:00:23] // new [kn, ri, mo, 14-10-2024 00:33:40]

INTEGER debugGitI = 0 // set to 1 for Warn() debugging

PROC DebugGit( STRING msg )
 IF debugGitI
  Warn( msg )
 ENDIF
END

// STRING workingDirectoryGS[ MAXSTRINGLEN ] = '/cygdrive/G/VERSIONCONTROL/SUBVERSION/W1' // [kn, ri, tu, 30-12-2025 21:32:56]
STRING workingDirectoryGS[ MAXSTRINGLEN ] = 'G:\VERSIONCONTROL\GIT\DDD01\' // [kn, ri, tu, 30-12-2025 21:32:56]
//
KEYDEF extra_list_keys
 <f1> next_list = 'help' PushKey(<Enter>)
 <f5> next_list = 'log'  PushKey(<Enter>)
 <f8> next_list = 'info' PushKey(<Enter>)
 <f9> next_list = 'proplist' PushKey(<Enter>)
 <f10> next_list = 'diff' PushKey(<Enter>) // [kn, ri, su, 16-11-2025 00:59:08]
END
//
INTEGER PROC get_dos( STRING cmd )
  DebugGit( 'DOS: ' + cmd )
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
//
STRING PROC BashQuote( STRING s )
 INTEGER i = 0
 STRING out[ MAXSTRINGLEN ] = ""
 STRING ch[ 2 ] = ""

 // Build a bash single-quoted string, escaping embedded single quotes as: '\''
 out = Chr(39)   // opening '

 FOR i = 1 TO Length( s )
  ch = SubStr( s, i, 1 )
  IF Asc( ch ) == 39
   // append: '\''
   out = out + Chr(39) + Chr(92) + Chr(39) + Chr(39)
  ELSE
   out = out + ch
  ENDIF
 ENDFOR

 out = out + Chr(39) // closing '
 RETURN( out )
END

STRING PROC GitCmd( STRING repo, STRING cmd )
 STRING fullRepo[ MAXSTRINGLEN ] = repo
 STRING bashCommand[ MAXSTRINGLEN ] = ''
 fullRepo = Trim( fullRepo )
 WHILE SubStr( fullRepo, Length( fullRepo ), 1 ) == '/'
  fullRepo = SubStr( fullRepo, 1, Length( fullRepo ) - 1 )
 ENDWHILE
 bashCommand = 'cd ' + BashQuote( fullRepo ) + ' && ' + gitExecutableGS + ' ' + cmd
 RETURN( QuotePath( versionControlExecutableGS ) + ' --login -c ' + QuotePath( bashCommand ) )
END
//
STRING PROC BashCmd( STRING dir, STRING cmd )
 STRING fullDir[ MAXSTRINGLEN ] = dir
 STRING bashCommand[ MAXSTRINGLEN ] = ''
 fullDir = Trim( fullDir )
 WHILE SubStr( fullDir, Length( fullDir ), 1 ) == '/'
  fullDir = SubStr( fullDir, 1, Length( fullDir ) - 1 )
 ENDWHILE
 bashCommand = 'cd ' + BashQuote( fullDir ) + ' && ' + cmd
 RETURN( QuotePath( versionControlExecutableGS ) + ' --login -c ' + QuotePath( bashCommand ) )
END
//
//
PROC show_dos_error( STRING text )
 STRING warning[ MAXSTRINGLEN ] = text
 BegFile()
 REPEAT
  warning = warning + Chr( 13 ) + RTrim( GetText( 1, MAXSTRINGLEN ) )
 UNTIL NOT Down()
 Warn( warning )
END show_dos_error
//
INTEGER PROC set_log_file()
 INTEGER org_id = GetBufferId()
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
  log_file = tmp_dir + 'TseSvn.log'
  log_id   = EditFile( log_file, _DONT_PROMPT_ )
  IF log_id
   EmptyBuffer()
   InsertText( 'Hello world!' )
   IF SaveAs( CurrFilename(), _DONT_PROMPT_|_OVERWRITE_ )
    result = STATE_OK
    ELSE
    AbandonFile( log_id )
   ENDIF
   GotoBufferId( org_id )
  ENDIF
 ENDIF
 IF result <> STATE_OK
  Warn( 'Error: cannot create a temporary file: ', log_file )
 ENDIF
 RETURN( result )
END set_log_file
//
INTEGER PROC ask_repository( VAR STRING repository, VAR STRING dir, VAR STRING selected )
 INTEGER state = STATE_OK
 STRING request[ MAXSTRINGLEN ] = workingDirectoryGS
 STRING repoRoot[ MAXSTRINGLEN ] = ''
 STRING relPath[ MAXSTRINGLEN ] = ''
 request = Trim( request )
 WHILE SubStr( request, Length( request ), 1 ) == '/'
  request = SubStr( request, 1, Length( request ) - 1 )
 ENDWHILE
 IF request == ''
  state = STATE_STOPPED
  ELSE
  // Verify we are inside a Git working tree and get the toplevel directory.
  IF get_dos( BashCmd( request, gitExecutableGS + ' rev-parse --show-toplevel' ) )
   repoRoot = Trim( GetText( 1, MAXSTRINGLEN ) )
   IF repoRoot == ''
    state = STATE_ERROR
    show_dos_error( 'Error: not a Git working tree.' )
    ELSE
    repository = repoRoot
    dir = ''
    selected = fileNameCurrentGS
   ENDIF
   ELSE
   state = STATE_ERROR
   show_dos_error( 'Error: failed to run git rev-parse.' )
  ENDIF
 ENDIF
 RETURN( state )
END ask_repository
//
PROC list_startup()
 UnHook( list_startup )
 CASE next_list
  WHEN 'browse'
  Enable( extra_list_keys )
 ENDCASE
 ListFooter( list_footer )
END list_startup
//
PROC list_cleanup()
 Disable( extra_list_keys )
END list_cleanup
//
INTEGER PROC browse_repository( string repository, VAR STRING dir )
 INTEGER old_msglevel = 0
 INTEGER state = STATE_OK
 list_header = repository + IIF( dir == '', '', '/' + dir ) + IIF( selected_file == '', '', '/' + selected_file ) + IIF( file_revision == '', '', '@' + file_revision )
 list_footer = '{Enter}-Back {Escape}-Back'
 curr_list   = next_list
 CASE next_list
  WHEN 'browse'
  list_header = repository + IIF( dir == '', '', '/' + dir )
  // list_footer = '{F1}-Help {F5}-Hist {F8}-Info {F9}-Diff {F10}-Props {Enter}-Read {Esc}-Quit'
  list_footer = '{F5}-Hist {F8}-Info {F9}-Props {Enter}-Read {Esc}-Quit {F1}-Help'
  get_dos( BashCmd( repository + IIF( dir == '', '', '/' + dir ), 'ls -1p --color=never' ) )
   //
   //
   // c:\temp\w1 Sun 16-11-25 00:26:55>g:\cygwin\bin\svn.exe list /cygdrive/c/TEMP/W1/
       //
       // 02 TSE.mbox
       // 1LINER.S
       // 2WRDLIST.S
       // ABREV.S
       // ANAGRAM.S
       // ARCHIVE7.S
       // ASM2BIN.S
       // ATAGS.S
       // AbanName.s
       // Ansi2oem.s
       // BIB4DOS.BTM
       // BIB4VS.4VS
       // BIBABAP.ABAP
       // BIBABBRE.DOK
       // BIBABC.ABC
       // BIBACTIONSCRIPT.AS
       // BIBADA.ADA
       // ...
  IF LFind( '^fatal: ', 'gx' )
   state = STATE_ERROR
   show_dos_error( 'Error:' )
   ELSE
   MarkLine( 1, NumLines() )
   old_msglevel = Set( MsgLevel, _WARNINGS_ONLY_ )
   ExecMacro( 'sort -i' )
   Set( MsgLevel, old_msglevel )
   UnMarkBlock()
   // Temporarily add a line, because searching 'something$' with 'bgx'
   // fails ( erroneously! ) WHEN the file contains a single line.
   EndFile()
   AddLine( '' )
   WHILE LFind( '/$', 'bgx' )
    MarkColumn( CurrLine(), 1, CurrLine(), CurrCol() - 1 )
    Copy()
    KillLine()
    BegFile()
    InsertLine( '/' )
    EndLine()
    Paste()
    UnMarkBlock()
   ENDWHILE
   EndFile()
   KillLine()
   BegFile()
   IF dir == ''
    InsertLine( '/.' )
    ELSE
    InsertLine( '/..' )
   ENDIF
  ENDIF
  LFind( selected_file, 'g' )
  WHEN 'cat'
  list_footer = '{Enter}-Edit {Escape}-Back'
  get_dos( IIF( file_revision == '', BashCmd( repository, 'cat -- "' + IIF( dir == '', selected_file, dir + '/' + selected_file ) + '"' ), GitCmd( repository, 'show ' + file_revision + ':"' + IIF( dir == '', selected_file, dir + '/' + selected_file ) + '"' ) ) )
  // c:\temp\w1 Sun 16-11-25 00:14:37>g:\cygwin\bin\svn.exe cat /cygdrive/c/TEMP/W1/svn.s
   //
   // Revision: 14970
   //
   // ===
   //
   // Macro     Git.s
   // Author    Carlo.Hogeveen@xs4all.nl
   // Date      25 May 2012
   // Version   See the history and the help_text.
   //
   // ===
   //
   // Purpose:
   //   The fastest possible Git browser.
   //
   // Why:
   //   Tortoisesvn is beyond too slow for directories with many files.
   //
   // Trade-off:
   //   A selected file's Git-properties are initially not shown.
   //
   // Installation:
   //   The "git" macro is "just" a shell around the "svn" commandline tool,
  //
  IF LFind( '^fatal: ', 'gx' )
   state = STATE_ERROR
   show_dos_error( 'Error:' )
  ENDIF
  WHEN 'edit'
  get_dos( IIF( file_revision == '', BashCmd( repository, 'cat -- "' + IIF( dir == '', selected_file, dir + '/' + selected_file ) + '"' ), GitCmd( repository, 'show ' + file_revision + ':"' + IIF( dir == '', selected_file, dir + '/' + selected_file ) + '"' ) ) )
   //
   // c:\temp\w1 Sun 16-11-25 00:27:05>g:\cygwin\bin\svn.exe info /cygdrive/c/TEMP/W1/svn.s
   // Path: svn.s
   // Name: svn.s
   // Working Copy Root Path: /cygdrive/c/TEMP/W1
   // URL: file:///cygdrive/c/temp/R1/svn.s
   // Relative URL: ^/svn.s
   // Repository Root: file:///cygdrive/c/temp/R1
   // Repository UUID: 6d1fcff0-99ff-11ef-9e48-6ffa6ec1e8ea
   // Revision: 2212
   // Node Kind: file
   // Schedule: normal
   // Last Changed Author: knud_
   // Last Changed Rev: 2212
   // Last Changed Date: 2025-11-16 00:29:22 +0100 (Sun, 16 Nov 2025)
   // Text Last Updated: 2025-11-16 00:29:16 +0100 (Sun, 16 Nov 2025)
   // Checksum: c9f853b7a86048a4f28e27a12d3224d956a8c1a5
   //
  IF LFind( '^fatal: ', 'gx' )
   state = STATE_ERROR
   show_dos_error( 'Error:' )
   ELSE
   MarkLine( 1, NumLines() )
   Copy()
   org_id = NewFile()
   Paste()
   UnMarkBlock()
   ChangeCurrFilename( list_header, _DONT_EXPAND_ )
   // IF ( ( GetGlobalInt( "diffGI" ) MOD 2 ) == 0 )
    IF YesNo( "Run diff?" ) == 1
     ExecMacro( "compblct" ) // operation: compare: block: two: difference: all
     PurgeMacro( "compblct" ) // operation: compare: block: two: difference: all
    // ENDIF
   // SetGlobalInt( "diffGI", 0 ) // reset
   ENDIF
   state = STATE_STOPPED
  ENDIF
  WHEN 'help'
   EmptyBuffer()
   InsertData( help_text )
   BegFile()
  WHEN 'info'
  get_dos( GitCmd( repository, 'log -1 --date=iso --pretty=fuller -- "' + IIF( dir == '', selected_file, dir + '/' + selected_file ) + '"' ) )
  IF LFind( '^fatal: ', 'gx' )
   state = STATE_ERROR
   show_dos_error( 'Error:' )
  ENDIF
  WHEN 'log'
    DebugGit( 'LOG: Enter pressed' )
  list_footer = '{Enter}-Read {Esc}-Back'
  get_dos( GitCmd( repository, "log --follow --date=iso --pretty=format:'%%h# | %%an | %%ad | %%s' -- " + BashQuote( IIF( dir == '', selected_file, dir + '/' + selected_file ) ) ) )//
   // c:\temp\w1 Sun 16-11-25 00:34:06>g:\cygwin\bin\svn.exe log /cygdrive/c/TEMP/W1/svn.s
   // ------------------------------------------------------------------------
   // r2213 | knud_ | 2025-11-16 00:31:57 +0100 (Sun, 16 Nov 2025) | 1 line
   //
   // [svn.s] recompile
   // ------------------------------------------------------------------------
   // r2212 | knud_ | 2025-11-16 00:29:22 +0100 (Sun, 16 Nov 2025) | 1 line
   //
   // [svn.s] recompile
   // ------------------------------------------------------------------------
   // r2208 | knud_ | 2025-11-15 22:39:15 +0100 (Sat, 15 Nov 2025) | 1 line
   //
   // [svn.s] recompile
   // ------------------------------------------------------------------------
   // r1 | knud_ | 2024-11-03 18:10:46 +0100 (Sun, 03 Nov 2024) | 1 line
   //
   // original
   // ------------------------------------------------------------------------
   //
  IF LFind( '^fatal: ', 'gx' )
   state = STATE_ERROR
   show_dos_error( 'Error:' )
   ELSE
   WHILE LFind( '^$', 'gx' )
    KillLine()
   ENDWHILE
  ENDIF
  WHEN 'proplist'
  get_dos( GitCmd( repository, 'status --porcelain=v1 -- "' + IIF( dir == '', selected_file, dir + '/' + selected_file ) + '"' ) )
  IF LFind( '^fatal: ', 'gx' )
   state = STATE_ERROR
   show_dos_error( 'Error:' )
   ELSE
   LFind( selected_property, 'g' )
  ENDIF
  OTHERWISE
  Warn( 'Error: unknown action ( 1 ).' )
  state = STATE_ERROR
 ENDCASE
 IF state == STATE_OK
  Hook( _LIST_STARTUP_, list_startup )
  Hook( _LIST_CLEANUP_, list_cleanup )
  //
  PushKeyStr( fileNameCurrentGS ) // [kn, ri, fr, 30-01-2026 12:18:22]
  //
  IF List( list_header, Max( Max( Length( list_header ), Length( list_footer ) ), LongestLineInBuffer() ) )
   UnHook( list_cleanup )
   CASE curr_list
    WHEN 'browse'
    selected_file = GetText( 1, CurrLineLen() )
    IF next_list == 'browse'
     IF selected_file == '/..'
      selected_file = '/' + SplitPath( dir, _NAME_|_EXT_ )
      dir  = SplitPath( dir, _PATH_ )
      IF SubStr( dir, Length( dir ), 1 ) == '/'
       dir = SubStr( dir, 1, Length( dir ) - 1 )
      ENDIF
      ELSEIF selected_file == '/.'
      dir = dir
      ELSEIF SubStr( selected_file, 1, 1 ) == '/'
      IF dir == ''
       dir = SubStr( selected_file, 2, MAXSTRINGLEN )
       ELSE
       dir = dir + selected_file
      ENDIF
      ELSE
      next_list     = 'cat'
      file_revision = ''
     ENDIF
     ELSE
     IF selected_file == '/..'
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
    IF LFind( '^-#$', 'cg' )
     next_list = 'log'
     ELSE
     IF NOT LFind( '^[0-9a-fA-F][0-9a-fA-F]*# \| ', 'cg' )
      Up()
      IF NOT LFind( '^[0-9a-fA-F][0-9a-fA-F]*# \| ', 'cg' )
       Down()
      ENDIF
     ENDIF
     IF LFind( '^[0-9a-fA-F][0-9a-fA-F]*# \| ', 'cg' )
      LFind( '[0-9a-fA-F][0-9a-fA-F]*#', 'cg' )
      file_revision = SubStr( GetFoundText(), 1, Length( GetFoundText() ) - 1 )
       DebugGit( 'LOG: revision=' + file_revision )
      next_list     = 'cat'
      ELSE
      next_list     = 'log'
     ENDIF
    ENDIF
    WHEN 'proplist'
    next_list = 'browse'
    OTHERWISE
    Warn( 'Error: unknown action ( 2 ).' )
    state = STATE_ERROR
   ENDCASE
   ELSE
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
    // WHEN 'diff'
    // next_list = 'browse'
    OTHERWISE
    Warn( 'Error: unknown action ( 3 ).' )
    state = STATE_ERROR
   ENDCASE
  ENDIF
 ENDIF
 RETURN( state )
END browse_repository
//
PROC WhenLoaded()
 macro_name = SplitPath( CurrMacroFilename(), _NAME_ )
 fileNameCurrentGS = SplitPath( CurrFileName(), _NAME_ | _EXT_ ) // [kn, ri, fr, 30-01-2026 12:20:41]
END WhenLoaded
//
PROC Main()
 STRING  dir[ MAXSTRINGLEN ] = ''
 STRING  repository[ MAXSTRINGLEN ] = ''
 INTEGER state = STATE_OK
 // IF ( NOT ( Ask( "path to your Git executable = ", versionControlExecutableGS, _EDIT_HISTORY_ ) ) AND ( Length( versionControlExecutableGS ) > 0 ) ) RETURN() ENDIF // new [kn, ri, tu, 13-01-2026 00:19:06]
 SetGlobalInt( "diffGI", GetGlobalInt( "diffGI" ) + 1 )
 org_id = GetBufferId()
 state = set_log_file()
 WHILE state == STATE_OK
  state = ask_repository( repository, dir, selected_file )
  WHILE state == STATE_OK
   state = browse_repository( repository, dir )
  ENDWHILE
 ENDWHILE
 GotoBufferId( org_id )
 AbandonFile( log_id )
 PurgeMacro( macro_name )
 IF ( ( Lower( Trim( Query( DosCmdLine ) ) ) IN '-esvn', '-e svn' ) AND ( NumFiles() == 1 ) AND ( Pos( 'unnamed', Lower( CurrFilename() ) ) > 0 ) )
  AbandonEditor()
 SetGlobalInt( "diffGI", 0 )
 ENDIF
END Main
