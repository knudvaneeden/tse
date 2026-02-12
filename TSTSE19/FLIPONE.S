/* Generalized flip for one character for SemWare's TSE editor V2.5.
   Covers also foreign 8-bit IBM characters. To make this SAL macro
   operational, invoke the main menu (F10), choose "Macro", choose
   "Compile" and press Enter at "Execute Macro".

....................................................................
Prof. Timo Salmi   Co-moderator of news:comp.archives.msdos.announce
Moderating at ftp:// & http://garbo.uwasa.fi archives  193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi  <URL:http://uwasa.fi/~ts>  ; FIN-65101,  Finland
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "FLIPONE.S HELP"           // The help's caption
  x = 10                             // Location
  y = 3
  // The actual help text
  " Timo's flip. Changes the case of one character "
  " at a time. Converts also the 8-bit foreign"
  " characters. To use, take the cursor where you"
  " wish to start and then keep <CtrlAlt 5> down"
  " as long as you wish to flip. The cursor is"
  " automatically advanced, also from line to line. "
  ""
  " You can use <F11> to invoke the command menu "
  " after first exiting this help. "
  ""
  " Last updated Wed 19-June-1996 21:26:23 "
end  /* tHelpData */

// Flip a character, covers also foreign characters
string proc timoReturnFlip (string char)
  string lowercase[40] = 'abcdefghijklmnopqrstuvwxyz†„”‚‡‘¤'
  string uppercase[40] = 'ABCDEFGHIJKLMNOPQRSTUVWXYZŽ™š€’¥'
  string flipped[1]
  integer p1, p2
  p1 = Pos (char, lowercase)
  p2 = Pos (char, uppercase)
  if p1 > 0
    flipped = uppercase[p1]
  elseif p2 > 0
    flipped = lowercase[p2]
  else
    flipped = char
  endif
  return (flipped)
end timoReturnFlip

// Flip (chance the case of) a single character
proc timoFlip()
  string char[1] = ''
  PushBlock()
  UnMarkBlock()
  if MarkStream()
     char = GetMarkedText()
     char = timoReturnFlip(char)
     PushPosition()
     InsertText(char, _OVERWRITE_)
     PopPosition()
     WordRight()
     if CurrPos() > CurrLineLen()
       WordRight()
     endif
  endif
  PopBlock()
end timoFlip

// New keys and menus **************************************************
forward Menu tFlipMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 5>      timoFlip()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tFlipMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The flip menu ******************************************************
Menu tFlipMenu()
  Title = "Timo's flip menu"
  Width = 19
  x = 40
  y = 3
  history
  "&Flip one character <CtrlAlt 5>" , timoFlip()
  "Administer",,Divide
  "Disable &new keys   <CtrlAlt 0>" , tDisableNewKeys()
  "&Help               <CtrlAlt H>" , QuickHelp(tHelpData)
  "This Menu          <F11>"
end  /* tFlipMenu */

proc Main()
  Enable (new_keys)
  tFlipMenu()
end
