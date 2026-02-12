/* Switching text for SemWare's TSE editor V4.0. To make this SAL
   macro operational, invoke the main menu (F10), choose "Macro",
   choose "Compile" and press Enter at "Execute Macro".

....................................................................
Prof. Timo Salmi ftp & http://garbo.uwasa.fi/ archives 193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi <http://www.uwasa.fi/~ts/>  ; FIN-65101,  Finland
Timo's  FAQ  materials  at   http://www.uwasa.fi/~ts/http/tsfaq.html
Dense spam-kill procmail filtering with a public email key in effect
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "WSWAP.S HELP"          // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Timo's special text-switch TSE commands "
  ""
  " You can use <F11> to invoke the command "
  " menu after first exiting this help. "
  ""
  " Last updated Sun 9-January-2005 15:45:20 "
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
