// Revision: 14970
//
// ===
//
// Macro     Svn.s
// Author    Carlo.Hogeveen@xs4all.nl
// Date      25 May 2012
// Version   1.6 (Extracts to temp disk for BeyondCompare, updated BComp path)
//
// ===
//
// Purpose:
//   The fastest possible Subversion browser.
//
// Why:
//   Tortoisesvn is beyond too slow for directories with many files.
//
// Trade-off:
//   A selected file's Subversion-properties are initially not shown.
//
// Installation:
//   The "svn" macro is "just" a shell around the "svn" commandline tool,
//   which is [a part of] the actual Subversion tool.
//   Therefore the commandline-tool "svn" must be installed and in the PATH
//   environment variable, either in general or from where TSE is started.
//
//   Either download the latest version of TortoiseSVN (1.7.7 as I write,
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
//   Browsing the HEAD of a Subversion repository's directories and files,
//   view their info, properties, and history, and read or edit [the historic
//   version of] a file (without saving to the repository).
//
// NOT a feature (yet):
//   Subversion security: the repository must either be publicly accessible,
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
 'This is fast Subversion browser, specifically intended for browsing'
 'those really large large directories, for which TortoiseSVN would take'
 'minutes instead of seconds.'
 ''
 'The top of the screen shows which object is currently selected.'
 'A @ followed by a revisionnumber indicates you look'
 'at that historic version (revision) of the object.'
 'Is there no @, then you look at the latest version.'
 ''
 'The bottom of the screen continuously shows possible actions.'
 'A file is opened for read first, and for editing separately.'
 'Editing leaves the browser, and does not mean you can Save the file'
 '(directly) but "only" that you get all the editing options of TSE.'
 '"Props" stands for "Properties": an object' + "'s Subversion-properties."
 ''
 'In a list and when reading a file you can type a string of'
 'characters to quickly go to their first occurrence.'
 'For instance, type "props" now.'
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
STRING prev_list[ MAXSTRINGLEN ] = 'browse'
INTEGER org_id = 0
STRING selected_file[ MAXSTRINGLEN ] = ''
STRING selected_property[ MAXSTRINGLEN ] = ''
//
STRING fileNameCurrentGS[ MAXSTRINGLEN ] = '' 
//
STRING versionControlExecutableGS[ MAXSTRINGLEN ] = "g:\cygwin\bin\svn.exe" 
STRING workingDirectoryGS[ MAXSTRINGLEN ] = '/cygdrive/G/VERSIONCONTROL/SUBVERSION/W1' 
//
// Globals for Diff logic
STRING compareExecutableGS[ MAXSTRINGLEN ] = "G:\UTILS\COMPARE\BEYONDCOMPARE\Beyond Compare 5\BComp.exe"
STRING firstDiffFileGS[ MAXSTRINGLEN ] = ""
//
KEYDEF extra_list_keys
 <f1> next_list = 'help' PushKey(<Enter>)
 <f5> next_list = 'log'  PushKey(<Enter>)
 <f8> next_list = 'info' PushKey(<Enter>)
 <f9> next_list = 'proplist' PushKey(<Enter>)
 <f10> next_list = 'diff' PushKey(<Enter>) 
END
//
INTEGER PROC FNget_dosI( STRING cmdS )
 INTEGER resultI = FALSE
 EraseDiskFile( log_file )
 IF Dos( cmdS + ' > ' + QuotePath( log_file ) + ' 2>&1', _START_HIDDEN_ )
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
   resultI = TRUE
  ENDIF
 ENDIF
 RETURN( resultI )
END FNget_dosI
//
PROC PROCshow_dos_error( STRING textS )
 STRING warningS[ MAXSTRINGLEN ] = textS
 BegFile()
 REPEAT
  warningS = warningS + Chr( 13 ) + RTrim( GetText( 1, MAXSTRINGLEN ) )
 UNTIL NOT Down()
 Warn( warningS )
END PROCshow_dos_error
//
INTEGER PROC set_log_file()
 INTEGER orgIdI = GetBufferId()
 INTEGER resultI = STATE_ERROR
 STRING tmpDirS[ MAXSTRINGLEN ] = ''
 IF GetEnvStr( 'tmp' ) <> ''
  tmpDirS = GetEnvStr( 'tmp' )
  ELSEIF GetEnvStr( 'temp' ) <> ''
  tmpDirS = GetEnvStr( 'temp' )
  ELSE
  tmpDirS = 'c:'
 ENDIF
 IF tmpDirS[Length( tmpDirS )] <> '\'
  tmpDirS = tmpDirS + '\'
 ENDIF
 IF ( FileExists( tmpDirS ) & _DIRECTORY_ )
  log_file = tmpDirS + 'TseSvn.log'
  log_id   = EditFile( log_file, _DONT_PROMPT_ )
  IF log_id
   EmptyBuffer()
   InsertText( 'Hello world!' )
   IF SaveAs( CurrFilename(), _DONT_PROMPT_|_OVERWRITE_ )
    resultI = STATE_OK
    ELSE
    AbandonFile( log_id )
   ENDIF
   GotoBufferId( orgIdI )
  ENDIF
 ENDIF
 IF resultI <> STATE_OK
  Warn( 'Error: cannot create a temporary file: ', log_file )
 ENDIF
 RETURN( resultI )
END set_log_file
//
INTEGER PROC ask_repository( VAR STRING repository, VAR STRING dir, VAR STRING selected )
 INTEGER stateI = STATE_OK
 STRING requestS[ MAXSTRINGLEN ] = workingDirectoryGS
 IF ( TRUE ) 
  requestS = Trim( requestS )
  WHILE SubStr( requestS, Length( requestS ), 1 ) == '/'
   requestS = SubStr( requestS, 1, Length( requestS ) - 1 )
  ENDWHILE
  IF requestS == ''
   stateI = STATE_STOPPED
   ELSE
   IF FNget_dosI( QuotePath( versionControlExecutableGS ) + ' ' + 'info ' + QuotePath( requestS ) )
    IF LFind( '^Repository Root: ', 'gx' )
     repository = Trim( GetText( 18, MAXSTRINGLEN ) )
     IF LFind( '^URL: ', 'gx' )
      dir = Trim( GetText( 6 + Length( repository ), MAXSTRINGLEN ) )
      IF LFind( '^Node Kind: {directory}|{selected}', 'gx' )
       IF LFind( '^Node Kind: selected', 'cgx' )
        selected = GetToken( dir, '/\', NumTokens( dir, '/\' ) )
        dir  = SubStr( dir, 1, Length( dir ) - Length( selected ) - 1 )
        ELSE
        selected = ''
       ENDIF
       ELSE
       stateI = STATE_ERROR
       PROCshow_dos_error( 'Error: no line starting with "Node Kind: file|directory".' )
      ENDIF
     ENDIF
     ELSE
     stateI = STATE_ERROR
     PROCshow_dos_error( 'Error: no line starting with "Repository Root: ".' )
    ENDIF
    ELSE
    stateI = STATE_ERROR
   ENDIF
  ENDIF
  ELSE
  stateI = STATE_STOPPED
 ENDIF
 RETURN( stateI )
END ask_repository
//
PROC PROClist_startup()
 UnHook( PROClist_startup )
 CASE next_list
  WHEN 'browse', 'log'
  Enable( extra_list_keys )
 ENDCASE
 ListFooter( list_footer )
END PROClist_startup
//
PROC PROClist_cleanup()
 Disable( extra_list_keys )
END PROClist_cleanup
//
INTEGER PROC browse_repository( string repository, VAR STRING dir )
 INTEGER oldMsglevelI = 0
 INTEGER stateI = STATE_OK
 INTEGER skipListI = FALSE
 
 INTEGER localBufferI = 0
 STRING tempNameS[ MAXSTRINGLEN ] = ''

 // Track our previous view so we can safely return to it after a diff extracts
 IF next_list <> 'diff'
  prev_list = next_list
 ENDIF

 list_header = repository + IIF( dir == '', '', '/' + dir ) + IIF( selected_file == '', '', '/' + selected_file ) + IIF( file_revision == '', '', '@' + file_revision )
 list_footer = '{Enter}-Back {Escape}-Back'
 curr_list   = next_list
 CASE next_list
  WHEN 'browse'
  list_header = repository + IIF( dir == '', '', '/' + dir )
  list_footer = '{F5}-Hist {F8}-Info {F9}-Props {F10}-Diff {Enter}-Read {Esc}-Quit {F1}-Help'
  FNget_dosI( QuotePath( versionControlExecutableGS ) + ' ' + 'list' + ' ' + QuotePath( repository + '/' + dir ) )
  IF LFind( '^svn: ', 'gx' )
   stateI = STATE_ERROR
   PROCshow_dos_error( 'Error:' )
   ELSE
   MarkLine( 1, NumLines() )
   oldMsglevelI = Set( MsgLevel, _WARNINGS_ONLY_ )
   ExecMacro( 'sort -i' )
   Set( MsgLevel, oldMsglevelI )
   UnMarkBlock()
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
  FNget_dosI( QuotePath( versionControlExecutableGS ) + ' ' + 'cat ' + IIF( file_revision == '', '', '-r' + file_revision + ' ' ) + QuotePath( repository + '/' + dir + '/' + selected_file ) )
  IF LFind( '^svn: ', 'gx' )
   stateI = STATE_ERROR
   PROCshow_dos_error( 'Error:' )
  ENDIF
  WHEN 'edit'
  FNget_dosI( QuotePath( versionControlExecutableGS ) + ' ' + 'cat ' + IIF( file_revision == '', '', '-r' + file_revision + ' ' ) + QuotePath( repository + '/' + dir + '/' + selected_file ) )
  IF LFind( '^svn: ', 'gx' )
   stateI = STATE_ERROR
   PROCshow_dos_error( 'Error:' )
   ELSE
   MarkLine( 1, NumLines() )
   Copy()
   org_id = NewFile()
   Paste()
   UnMarkBlock()
   ChangeCurrFilename( list_header, _DONT_EXPAND_ )
   stateI = STATE_STOPPED
  ENDIF
  WHEN 'diff'
  skipListI = TRUE
  FNget_dosI( QuotePath( versionControlExecutableGS ) + ' ' + 'cat ' + IIF( file_revision == '', '', '-r' + file_revision + ' ' ) + QuotePath( repository + '/' + dir + '/' + selected_file ) )
  IF LFind( '^svn: ', 'gx' )
   stateI = STATE_ERROR
   PROCshow_dos_error( 'Error:' )
  ELSE
   tempNameS = GetEnvStr( 'temp' ) + '\' + IIF( file_revision == '', 'head', file_revision ) + '_' + selected_file
   MarkLine( 1, NumLines() )
   Copy()
   localBufferI = NewFile()
   Paste()
   UnMarkBlock()
   SaveAs( tempNameS, _DONT_PROMPT_ | _OVERWRITE_ )
   AbandonFile( localBufferI )
   GotoBufferId( log_id )
   IF firstDiffFileGS == ''
    firstDiffFileGS = tempNameS
    Warn( 'First diff file marked: ' + tempNameS )
   ELSE
    Dos( QuotePath( compareExecutableGS ) + ' ' + QuotePath( firstDiffFileGS ) + ' ' + QuotePath( tempNameS ), _DONT_WAIT_ )
    firstDiffFileGS = ''
   ENDIF
   next_list = prev_list // Silently return to the active list (browse or log)
  ENDIF
  WHEN 'help'
   EmptyBuffer()
   InsertData( help_text )
   BegFile()
  WHEN 'info'
  FNget_dosI( QuotePath( versionControlExecutableGS ) + ' ' + 'info ' + QuotePath( repository + '/' + dir + '/' + selected_file ) )
  IF LFind( '^svn: ', 'gx' )
   stateI = STATE_ERROR
   PROCshow_dos_error( 'Error:' )
  ENDIF
  WHEN 'log'
  list_footer = '{Enter}-Read {F10}-Diff {Esc}-Back'
  FNget_dosI( QuotePath( versionControlExecutableGS ) + ' ' + 'log' + ' ' + QuotePath( repository + '/' + dir + '/' + selected_file ) )
  IF LFind( '^svn: ', 'gx' )
   stateI = STATE_ERROR
   PROCshow_dos_error( 'Error:' )
   ELSE
   WHILE LFind( '^$', 'gx' )
    KillLine()
   ENDWHILE
  ENDIF
  WHEN 'proplist'
  FNget_dosI( QuotePath( versionControlExecutableGS ) + ' ' + 'proplist -v ' + QuotePath( repository + '/' + dir + '/' + selected_file ) )
  IF LFind( '^svn: ', 'gx' )
   stateI = STATE_ERROR
   PROCshow_dos_error( 'Error:' )
   ELSE
   LFind( selected_property, 'g' )
  ENDIF
  OTHERWISE
  Warn( 'Error: unknown action ( 1 ).' )
  stateI = STATE_ERROR
 ENDCASE
 
 // The UI List is safely skipped if a background job like 'diff' occurs
 IF stateI == STATE_OK AND NOT skipListI
  Hook( _LIST_STARTUP_, PROClist_startup )
  Hook( _LIST_CLEANUP_, PROClist_cleanup )
  PushKeyStr( fileNameCurrentGS ) 
  IF List( list_header, Max( Max( Length( list_header ), Length( list_footer ) ), LongestLineInBuffer() ) )
   UnHook( PROClist_cleanup )
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
     ELSEIF next_list == 'diff'
     file_revision = ''
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
    IF LFind( '^-#$', 'cgx' )
     next_list = 'log'
     ELSE
     IF NOT LFind( '^r[0-9]# \| ', 'cgx' )
      Up()
      IF NOT LFind( '^r[0-9]# \| ', 'cgx' )
       Down()
      ENDIF
     ENDIF
     IF LFind( '^r[0-9]# \| ', 'cgx' )
      LFind( '[0-9]#', 'cgx' )
      file_revision = GetFoundText()
      IF next_list == 'diff'
       // Keep action as 'diff' 
      ELSE
       next_list = 'cat'
      ENDIF
      ELSE
      next_list     = 'log'
     ENDIF
    ENDIF
    WHEN 'proplist'
    next_list = 'browse'
    OTHERWISE
    Warn( 'Error: unknown action ( 2 ).' )
    stateI = STATE_ERROR
   ENDCASE
   ELSE
   CASE curr_list
    WHEN 'browse'
    stateI = STATE_STOPPED
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
    OTHERWISE
    Warn( 'Error: unknown action ( 3 ).' )
    stateI = STATE_ERROR
   ENDCASE
  ENDIF
 ENDIF
 RETURN( stateI )
END browse_repository
//
PROC WhenLoaded()
 macro_name = SplitPath( CurrMacroFilename(), _NAME_ )
 fileNameCurrentGS = SplitPath( CurrFilename(), _NAME_ | _EXT_ )
END WhenLoaded
//
PROC Main()
 STRING  dir[ MAXSTRINGLEN ] = ''
 STRING  repository[ MAXSTRINGLEN ] = ''
 INTEGER state = STATE_OK
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
