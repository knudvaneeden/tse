/* Quoting text for SemWare's TSE editor V2.5. To make this SAL
   macro operational, invoke the main menu (F10), choose "Macro",
   choose "Compile" and press Enter at "Execute Macro".

....................................................................
Prof. Timo Salmi   Co-moderator of news:comp.archives.msdos.announce
Moderating at ftp:// & http://garbo.uwasa.fi archives  193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi  <URL:http://uwasa.fi/~ts>  ; FIN-65101,  Finland
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "QUOTE.S HELP"          // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's quote messages Internet style"
  ''
  ' The purpose of these commands is to quote messages by'
  ' preceding each line with the quote characters. You can'
  ' alternatively quote from the current position down, up'
  ' or only the current line. You can also alter the default '
  ' quote character which is ">".'
  ''
  ' You can use <F11> to invoke the command menu after '
  ' first exiting this help. '
  ''
  ' Last updated Tue 23-January-1996 21:40:11 '
end  /* tHelpData */

// Quote messages in various ways ************************************

string quoteChar[22] = ">"
integer quote_hist

// To alter the quote character
proc timoAskQuoteChar()
  Ask("Your quote character: ", quoteChar, quote_hist)
  AddHistoryStr (quoteChar, quote_hist)
end  timoAskQuoteChar

proc timoQuoteDown()
  BegLine()
  InsertText(quoteChar, _INSERT_)
  while Down()
    Begline()
    InsertText(quoteChar, _INSERT_)
    BegLine()
  endwhile
end

proc timoQuoteCurrent()
  BegLine()
  InsertText(QuoteChar, _INSERT_)
  Begline()
  Down()
end

proc timoQuoteUp()
  BegLine()
  InsertText(QuoteChar, _INSERT_)
  while Up()
    BegLine()
    InsertText(QuoteChar, _INSERT_)
    BegLine()
  endwhile
end

// New keys and menus **************************************************
forward Menu tQuoteMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 4>      timoQuoteDown()
  <CtrlAlt 5>      timoQuoteCurrent()
  <CtrlAlt 6>      timoQuoteUp()
  <CtrlAlt 7>      timoAskQuoteChar()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tQuoteMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1
    Disable(new_keys)
    DelHistory(quote_hist)
  endif
end

// The Quote menu *****************************************************
Menu tQuoteMenu()
  Title = "Timo's Quote menu"
  Width = 19
  x = 40
  y = 3
  history
  "Quote &down          <CtrlAlt 4>"   , timoQuoteDown()
  "Quote &current       <CtrlAlt 5>"   , timoQuoteCurrent()
  "Quote &up            <CtrlAlt 6>"   , timoQuoteUp()
  "",,Divide
  "&Alter quote char... <CtrlAlt 7>"   , timoAskQuoteChar()
  "",,Divide
  "Disable &new keys    <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help                <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <F11>"
end  /* tQuoteMenu */

proc Main()
  quote_hist = GetFreeHistory("QUOTE:timoAskQuoteChar")
  Enable (new_keys)
  tQuoteMenu()
end
