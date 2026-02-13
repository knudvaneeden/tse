//
// Macro     Git.s
// Author    Knud van Eeden (adapted from the file 'svn.s' by author Carlo Hogeveen)
//
// ===
//
// Download the latest version here:
//
//  https://sourceforge.net/p/the-semware-editor-tse/code/HEAD/tree/TRUNK/git.s?format=raw
//
//   or here (click in the right top on the download button)
//
//  https://github.com/knudvaneeden/tse/blob/TRUNK/git.s
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
//
//  1. Needs git.exe (you have to install Cygwin git)
//
//  2. Change the working directory to your working directory\
//
//      STRING workingDirectoryGS[ MAXSTRINGLEN ] = 'G:\VERSIONCONTROL\GIT\DDD01\'
//
//  3. Run this program git.s that will show a list of TSE programs
//     under git control. It searches automatically for the current
//     filename.
//
//  4. Select the filename
//
//  5. Then press <F5> to see the file content of that revision
//
//  6. Press <F8> to view some more information about the file revision for that filename
//
//  6. Press <F9> to view some more other information about the file revision for that filename
//
// Features:
//
//   Browsing the HEAD of a Git repository's directories and files,
//   view their info, properties, and history, and read or edit [the historic
//   version of] a file (without saving to the repository).
//
// History:
//
// 1.0.0.0 12 February 2026
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
// STRING workingDirectoryGS[ MAXSTRINGLEN ] = '/cygdrive/G/VERSIONCONTROL/SUBVERSION/W1' // [kn, ri, tu, 30-12-2025 21:32:56]
STRING workingDirectoryGS[ MAXSTRINGLEN ] = 'G:\VERSIONCONTROL\GIT\DDD01\'
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
//
STRING PROC BashQuote( STRING s )
 INTEGER i = 0
 STRING out[ MAXSTRINGLEN ] = ''
 STRING ch[2] = ''
 out = Chr( 39 ) // opening single quote
 FOR i = 1 TO Length( s )
  ch = SubStr( s, i, 1 )
  IF Asc( ch ) == 39
   // append: '\''  (end quote, escaped quote, start quote)
   out = out + Chr( 39 ) + Chr( 92 ) + Chr( 39 ) + Chr( 39 )
  ELSE
   out = out + ch
  ENDIF
 ENDFOR
 out = out + Chr( 39 ) // closing single quote
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
 STRING urlLocal[ MAXSTRINGLEN ] = ''
 STRING topLocal[ MAXSTRINGLEN ] = ''
 STRING headLocal[ MAXSTRINGLEN ] = ''
 STRING rootLocal[ MAXSTRINGLEN ] = ''
 STRING lastAuthorLocal[ MAXSTRINGLEN ] = ''
 STRING lastRevLocal[ MAXSTRINGLEN ] = ''
 STRING lastDateLocal[ MAXSTRINGLEN ] = ''
 STRING request[ MAXSTRINGLEN ] = workingDirectoryGS
 STRING repoRoot[ MAXSTRINGLEN ] = ''
 // STRING relPath[ MAXSTRINGLEN ] = ''
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
 STRING relPathLocal[255] = ""
 STRING topLocal[255] = ""
 STRING headLocal[255] = ""
 STRING rootLocal[255] = ""
 STRING lastAuthorLocal[255] = ""
 STRING lastRevLocal[255] = ""
 STRING lastDateLocal[255] = ""
 STRING urlLocal[255] = ""
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
  get_dos( IIF( file_revision == '', BashCmd( repository, 'cat -- ' + BashQuote( IIF( dir == '', selected_file, dir + '/' + selected_file ) ) ), GitCmd( repository, 'show ' + BashQuote( file_revision + ':' + IIF( dir == '', selected_file, dir + '/' + selected_file ) ) ) ) )
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
  get_dos( IIF( file_revision == '', BashCmd( repository, 'cat -- ' + BashQuote( IIF( dir == '', selected_file, dir + '/' + selected_file ) ) ), GitCmd( repository, 'show ' + BashQuote( file_revision + ':' + IIF( dir == '', selected_file, dir + '/' + selected_file ) ) ) ) )
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
   // IF YesNo( "Run diff?" ) == 1
   //  ExecMacro( "compblct" ) // operation: compare: block: two: difference: all
   //  PurgeMacro( "compblct" ) // operation: compare: block: two: difference: all
   // // ENDIF
   // // SetGlobalInt( "diffGI", 0 ) // reset
   // ENDIF
   state = STATE_STOPPED
  ENDIF
  WHEN 'help'
   EmptyBuffer()
   InsertData( help_text )
   BegFile()
  WHEN 'info'
  // SVN-like info for Git (assembled from multiple short git commands)
  relPathLocal = IIF( dir == '', selected_file, dir + '/' + selected_file )

  // Collect values (each command kept short to avoid command-length limits)
  get_dos( GitCmd( repository, 'config --get remote.origin.url' ) )
  urlLocal = Trim( GetText( 1, MAXSTRINGLEN ) )

  get_dos( GitCmd( repository, 'rev-parse --show-toplevel' ) )
  topLocal = Trim( GetText( 1, MAXSTRINGLEN ) )

  get_dos( GitCmd( repository, 'rev-parse --short HEAD' ) )
  headLocal = Trim( GetText( 1, MAXSTRINGLEN ) )

  get_dos( GitCmd( repository, 'rev-list --max-parents=0 HEAD' ) )
  rootLocal = Trim( GetText( 1, MAXSTRINGLEN ) )

  get_dos( GitCmd( repository, 'log -1 --pretty=format:' + Chr(39) + '%%an' + Chr(39) + ' -- ' + BashQuote( relPathLocal ) ) )
  lastAuthorLocal = Trim( GetText( 1, MAXSTRINGLEN ) )

  get_dos( GitCmd( repository, 'log -1 --pretty=format:' + Chr(39) + '%%h' + Chr(39) + ' -- ' + BashQuote( relPathLocal ) ) )
  lastRevLocal = Trim( GetText( 1, MAXSTRINGLEN ) )

  get_dos( GitCmd( repository, 'log -1 --date=iso --pretty=format:' + Chr(39) + '%%ad' + Chr(39) + ' -- ' + BashQuote( relPathLocal ) ) )
  lastDateLocal = Trim( GetText( 1, MAXSTRINGLEN ) )

  // Build an svn-info-like output in the log buffer
  GotoBufferId( log_id )
  EmptyBuffer()
  AddLine( 'Path: ' + relPathLocal )
  AddLine( 'Name: ' + selected_file )
  AddLine( 'URL: ' + urlLocal )
  AddLine( 'Relative URL: ^/' + relPathLocal )
  AddLine( 'Repository Root: ' + urlLocal )
  AddLine( 'Repository UUID: ' + rootLocal )
  AddLine( 'Revision: ' + headLocal )
  AddLine( 'Node Kind: file' )
  AddLine( 'Schedule: normal' )
  AddLine( 'Working Copy Root Path: ' + topLocal )
  AddLine( 'Last Changed Author: ' + lastAuthorLocal )
  AddLine( 'Last Changed Rev: ' + lastRevLocal )
  AddLine( 'Last Changed Date: ' + lastDateLocal )
  BegFile()
  WHEN 'log'
  list_footer = '{Enter}-Read {Esc}-Back'
  get_dos( GitCmd( repository, 'log --follow --date=iso --pretty=format:' + Chr(39) + '%%h# | %%an | %%ad | %%s' + Chr(39) + ' -- ' + BashQuote( IIF( dir == '', selected_file, dir + '/' + selected_file ) ) ) )
   //
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
  // Git "properties" (closest SVN-style): status + index + head + size + last commit + attributes
  EraseDiskFile( log_file )

  relPathLocal = IIF( dir == '', selected_file, dir + '/' + selected_file )

  // Path / Name
  Dos( BashCmd( repository, 'echo Path: ' + BashQuote( relPathLocal ) ) + ' > '  + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( BashCmd( repository, 'echo Name: ' + BashQuote( selected_file ) ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( BashCmd( repository, 'echo' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )

  // Status
  Dos( BashCmd( repository, 'echo Status:' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( GitCmd( repository, 'status --porcelain=v1 -- ' + BashQuote( relPathLocal ) ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( BashCmd( repository, 'echo' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )

  // Index / staged entry
  Dos( BashCmd( repository, 'echo Index:' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( GitCmd( repository, 'ls-files --stage -- ' + BashQuote( relPathLocal ) ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( BashCmd( repository, 'echo' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )

  // HEAD blob entry
  Dos( BashCmd( repository, 'echo HEAD:' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( GitCmd( repository, 'ls-tree HEAD -- ' + BashQuote( relPathLocal ) ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( BashCmd( repository, 'echo' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )

  // File size (working-tree)
  Dos( BashCmd( repository, 'echo File Size:' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( BashCmd( repository, 'wc -c -- ' + BashQuote( relPathLocal ) ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( BashCmd( repository, 'echo' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )

  // Last commit affecting file
  Dos( BashCmd( repository, 'echo Last Commit:' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( GitCmd( repository, 'log -1 --date=iso --pretty=format:' + Chr(39) + '%%h | %%an | %%ad | %%s' + Chr(39) + ' -- ' + BashQuote( relPathLocal ) ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( BashCmd( repository, 'echo' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )

  // core.autocrlf
  Dos( BashCmd( repository, 'echo core.autocrlf:' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( GitCmd( repository, 'config --get core.autocrlf' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( BashCmd( repository, 'echo' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )

  // eol attribute
  Dos( BashCmd( repository, 'echo eol attribute:' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( GitCmd( repository, 'check-attr eol -- ' + BashQuote( relPathLocal ) ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( BashCmd( repository, 'echo' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )

  // Ignored? (prints the path when ignored, prints nothing otherwise)
  Dos( BashCmd( repository, 'echo Ignored:' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( GitCmd( repository, 'check-ignore -- ' + BashQuote( relPathLocal ) ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( BashCmd( repository, 'echo' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )

  // Flags (assume-unchanged / skip-worktree show up here)
  Dos( BashCmd( repository, 'echo Flags:' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( GitCmd( repository, 'ls-files -v -- ' + BashQuote( relPathLocal ) ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( BashCmd( repository, 'echo' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )

  // Attributes (.gitattributes)
  Dos( BashCmd( repository, 'echo Attributes:' ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
  Dos( GitCmd( repository, 'check-attr -a -- ' + BashQuote( relPathLocal ) ) + ' >> ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )

  // Load result into the log buffer
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
  ENDIF
  EraseDiskFile( log_file )

  IF LFind( '^fatal: ', 'gx' )
   state = STATE_ERROR
   show_dos_error( 'Error:' )
   ELSE
   // Position on previous selection if any
   IF Length( selected_property ) > 0
    LFind( selected_property, 'g' )
   ENDIF
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
    IF LFind( '^-\#$', 'cgx' )
     next_list = 'log'
     ELSE
     IF NOT LFind( '^[0-9a-fA-F]+\#\x20\|\x20', 'cgx' )
      Up()
      IF NOT LFind( '^[0-9a-fA-F]+\#\x20\|\x20', 'cgx' )
       Down()
      ENDIF
     ENDIF
     IF LFind( '^[0-9a-fA-F]+\#\x20\|\x20', 'cgx' )
      LFind( '[0-9a-fA-F]+\#', 'cgx' )
      file_revision = SubStr( GetFoundText(), 1, Length( GetFoundText() ) - 1 )
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
