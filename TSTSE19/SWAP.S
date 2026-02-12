/* Switching text for SemWare's TSE editor V2.5. To make this SAL
   macro operational, invoke the main menu (F10), choose "Macro",
   choose "Compile" and press Enter at "Execute Macro".

....................................................................
Prof. Timo Salmi   Co-moderator of news:comp.archives.msdos.announce
Moderating at ftp:// & http://garbo.uwasa.fi archives  193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi  <URL:http://uwasa.fi/~ts>  ; FIN-65101,  Finland
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData                 // helpdef was Help in prelease
  title = "SWITCH.S HELP"         // The help's caption
  x = 10                          // Location
  y = 3
  "Timo's text-switch TSE commands "    // The actual help text
  ""
  " You can use <F11> to invoke the command "
  " menu after first exiting this help. "
  ""
  " Last updated Fri 26-January-1996 21:16:28 "
end  /* tHelpData */

// Swap two characters ************************************************
proc timoSwapChars()
  string s[1] = ''
  if CurrPos() < CurrLineLen()
    s = Chr(CurrChar())
    DelChar()
    Right()
    InsertText(s,_INSERT_)
    Left()
    Left()
  else
    Warn("Cursor at or beyond the end of line")
  endif
end timoSwapChars

// Swap two words ****************************************************
proc timoSwapWords()
  string s1[80] = '', s2[80] = '', s3[80] = ''
  integer col
  //
  // Store original status (don't use PushPosition here)
  col = CurrCol()
  PushBlock()
  //
  // Mark the first word and store it
  if not BegWord()
    Warn("Cursor not on a word")
    goto label_pop
  endif
  UnmarkBlock()
  MarkChar()
  EndWord()
  if CurrPos() >= CurrLineLen()
    Warn("Cursor on the last word of the line")
    goto label_pop
  endif
  MarkChar()
  s1 = GetMarkedText()
  DelBlock()
  //
  // Store the intervening blanks etc
  UnmarkBlock()
  MarkChar()
  WordRight()
  MarkChar()
  s2 = GetMarkedText()
  DelBlock()
  //
  // Get the latter word
  BegWord()
  UnmarkBlock()
  MarkChar()
  if not EndWord()
    InsertText (s1 + s2, _INSERT_)
    Warn("Special case: Un-swappable non-word on the right")
    goto label_pop
  endif
  MarkChar()
  s3 = GetMarkedText()
  DelBlock()
  //
  // Reverse
  InsertText (s3 + s2 + s1, _INSERT_)
  //
  // Restore original status
  label_pop:
  PopBlock()
  gotoColumn(col)
end timoSwapWords

// Reverse a person's name *********************************************
proc timoRevName()
  string s1[80] = '', s2[80] = ''
  integer comma = 0
  integer col
  //
  // Store original status (don't use PushPosition here)
  col = CurrCol()
  PushBlock()
  //
  // Mark the first part of the name and store it
  if not BegWord()
    Warn("Cursor not on a word")
    goto label_pop
  endif
  UnmarkBlock()
  MarkChar()
  EndWord()
  if CurrPos() >= CurrLineLen()
    Warn("Cursor on the last word of the line")
    goto label_pop
  endif
  MarkChar()
  s1 = GetMarkedText()
  DelBlock()
  //
  // Check for comma
  if CurrChar() == Asc(",")
    comma = 1
  else
    comma = 0
  endif
  //
  // Delete intervening blanks etc
  UnmarkBlock()
  MarkChar()
  WordRight()
  MarkChar()
  s2 = GetMarkedText()
  DelBlock()
  //
  // Reverse
  if not EndWord()
    InsertText (s1 + s2, _INSERT_)
    Warn("Special case: Un-swappable non-word on the right")
  else
    if comma
      InsertText (" " + s1, _INSERT_)
    else
      InsertText (", " + s1, _INSERT_)
    endif
  endif
  //
  // Restore original status
  label_pop:
  PopBlock()
  gotoColumn(col)
end timoRevName

// New keys and menus **************************************************
forward Menu tSwitchMenu()
forward proc timoDisableNewKeys()

// Add new key definitions
keydef new_keys
  <CtrlAlt 4>           timoSwapChars()
  <CtrlAlt 5>           timoSwapWords()
  <CtrlAlt 6>           timoRevName()
  // QuickHelp was ShowHelp in prerelease
  <CtrlAlt H>           QuickHelp(tHelpData)
  <F11>                 tSwitchMenu()
end

// Disable the new extra keys ****************************************
proc timoDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1
    Disable(new_keys)
  endif
end

Menu tSwitchMenu()
  Title = ""
  x = 31
  y = 2
  history
  "&Swap two characters     <CtrlAlt 4>"  , timoSwapChars()
  "Swap two &words          <CtrlAlt 5>"  , timoSwapWords()
  "&Reverse a person's name <CtrlAlt 6>"  , timoRevName()
  "Administer",,Divide
  "Disable new &keys        <CtrlAlt 0>" , timoDisableNewKeys()
  // QuickHelp was ShowHelp in prerelease
  "&Help                    <CtrlAlt H>" , QuickHelp(tHelpData)
  "This Menu               <F11>"
end  /* tSwitchMenu */

proc Main()
  Enable (new_keys)
  tSwitchMenu()
end
