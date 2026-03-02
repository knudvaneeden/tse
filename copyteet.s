FORWARD PROC Main()
FORWARD STRING PROC FNTextCopyToWClipboardCentralTemplateS( INTEGER i1 )
FORWARD STRING PROC FNTextCopyToWClipboardThanksWithFriendlyGreetingsKnudVanEedenTemplateS()


// --- MAIN --- //

PROC Main()
 Message( FNTextCopyToWClipboardThanksWithFriendlyGreetingsKnudVanEedenTemplateS() ) // gives e.g. TRUE
END

<F12> Main()

// --- LIBRARY --- //

// library: text: copy: to: w: clipboard: thanks: with: friendly: greetings: knud: van: eeden: template <description></description> <version control></version control> <version>1.0.0.0.3</version> <version control></version control> (filenamemacro=copyteet.s) [<Program>] [<Research>] [kn, ri, mo, 02-03-2026 23:21:59]
STRING PROC FNTextCopyToWClipboardThanksWithFriendlyGreetingsKnudVanEedenTemplateS()
 // e.g. PROC Main()
 // e.g.  Message( FNTextCopyToWClipboardThanksWithFriendlyGreetingsKnudVanEedenTemplateS() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER bufferI = 0
 //
 PushPosition()
 bufferI = CreateTempBuffer()
 PopPosition()
 //
 PushPosition()
 PushBlock()
 GotoBufferId( bufferI )
 //
 // InsertText( "Thanks" )
 AddLine( "with friendly greetings" )
 AddLine( "Knud van Eeden" )
 AddLine( "Artificial Intelligence" )
 AddLine( "IT specialist" )
 AddLine( "TSE specialist" )
 //
 PopBlock()
 PopPosition()
 //
 RETURN( FNTextCopyToWClipboardCentralTemplateS( bufferI ) )
 //
END

// library: text: copy: to: w: clipboard: central: job: softwareag <description></description> <version control></version control> <version>1.0.0.0.17</version> <version control></version control> (filenamemacro=copytejt.s) [<Program>] [<Research>] [kn, ri, tu, 09-11-2021 19:49:50]
STRING PROC FNTextCopyToWClipboardCentralTemplateS( INTEGER bufferI )
 // e.g. PROC Main()
 // e.g.  INTEGER bufferI = 0
 // e.g.  PushPosition()
 // e.g.  bufferI = CreateTempBuffer()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  PushPosition()
 // e.g.  PushBlock()
 // e.g.  GotoBufferId( bufferI )
 // e.g.  InsertText( "Status: Update: Waiting for Software AG Research and Development" )
 // e.g.  PopBlock()
 // e.g.  PopPosition()
 // e.g.  //
 // e.g.  Message( FNTextCopyToWClipboardCentralTemplateS( bufferI ) ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER B = FALSE
 //
 STRING s[255] = ""
 //
 PushPosition()
 PushBlock()
 //
 IF NOT GotoBufferId( bufferI )
  //
  s = "0"
  //
  RETURN( s )
  //
 ENDIF
 //
 UnMarkBlock()
 BegFile()
 MarkStream()
 EndFile()
 Left()
 MarkStream()
 //
 B = CopyToWinClip()
 //
 IF ( B )
  //
  BegFile()
  //
  s = Format( "Copied to Microsoft Windows clipboard", ":", " ", GetText( 1, MAXSTRINGLEN ) )
  //
 ELSE
  //
  s = "0"
  //
 ENDIF
 //
 AbandonFile( bufferI )
 //
 PopPosition()
 PopBlock()
 //
 RETURN( s )
 //
END
