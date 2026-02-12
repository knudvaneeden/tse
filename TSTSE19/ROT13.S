/* ROT13 rotation for SemWare's TSE editor V2.5. To make this SAL
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
  title = "ROT13.S HELP"          // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's ROT13"
  ""
  " ROT13 rotates ascii text by 13 positions. This is "
  " often used as an elementary encryption technique "
  " for public but somehow sensitive texts."
  ""
  " You can use <F11> to invoke the command menu "
  " after first exiting this help. "
  ""
  " Last updated Tue 23-January-1996 21:42:11 "
end  /* tHelpData */

// Return one character in rot13
string proc timoGetRot13 (string char)
  string s1[80] = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
  string s2[80] = 'nopqrstuvwxyzabcdefghijklmNOPQRSTUVWXYZABCDEFGHIJKLM'
  string rot13[1]
  integer p1
  p1 = Pos (char, s1)
  if p1 > 0
    rot13 = s2[p1]
  else
    rot13 = char
  endif
  return (rot13)
end timoGetRot13

// Write a character overwriting, without advancing the cursor
proc tOverText(string s)
  InsertText(s,_OVERWRITE_)
  PrevChar()
end tOverText

// Rot13 the designated area
proc timoRot13(integer choice)
  string char[1]
  PushPosition()
  PushBlock()
  case choice
    // Entire file
    when 1
      BegFile()
      repeat
        if CurrChar() >= 0
          char = chr(CurrChar())
          tOverText(timoGetRot13(char))
        endif
      until not NextChar()
    // Block
    when 2
      if not isBlockInCurrFile()
        Warn('No block in current file')
      elseif isBlockInCurrFile() == _COLUMN_
        Warn('Column blocks not allowed for ROT13')
      else
        GotoBlockBegin()
        if isBlockInCurrFile() == _LINE_ BegLine() endif
        repeat
          if CurrChar() >= 0
            char = chr(CurrChar())
            tOverText(timoGetRot13(char))
          endif
          if not NextChar() break endif
          if not NextChar() break endif
          if not isCursorInBlock() break endif
          PrevChar()
        until FALSE
      endif
  endcase
  PopPosition()
  PopBlock()
end timoRot13

// New keys and menus **************************************************
forward Menu tRot13Menu()
forward Menu tRot13SubMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 5>      tRot13SubMenu()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tRot13Menu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

Menu tRot13SubMenu()
  Title = "rot13"
  x = 55
  y = 6
  history
  "&Entire file", timoRot13(1)
  "&Block"      , timoRot13(2)
end tRot13subMenu

Menu tRot13Menu()
  Title = "Timo's rot13 menu"
  x = 30
  y = 3
  history
  "&Rot13            <CtrlAlt 5>"   , tRot13SubMenu(), DontClose
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <F11>"
end  /* tRot13Menu */

proc Main()
  Enable (new_keys)
  tRot13Menu()
end
