/* Convert text into upper case for SemWare's TSE editor V4.0.
   Handles also foreign characters. To make this SAL macro
   operational, invoke the main menu (F10), choose "Macro", choose
   "Compile" and press Enter at "Execute Macro".

....................................................................
Prof. Timo Salmi ftp & http://garbo.uwasa.fi/ archives 193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi <http://www.uwasa.fi/~ts/>  ; FIN-65101,  Finland
Timo's  FAQ  materials  at   http://www.uwasa.fi/~ts/http/tsfaq.html
Dense spam-kill procmail filtering with a public email key in effect
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "WUPCASE.S HELP"        // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's UPCASE"
  ""
  " Converts ascii text into upper or lower case. "
  " Handles also the foreign characters: ÜÑîÅÇáë§ "
  ""
  " You can use <F11> to invoke the command menu "
  " after first exiting this help. "
  ""
  " Last updated Sun 9-January-2005 09:42:29 "
end  /* tHelpData */

// Return one character in upper case
string proc timoUpChar (string char)
  string s1[40] = 'abcdefghijklmnopqrstuvwxyzÜÑîÅÇáë§'
  string s2[40] = 'ABCDEFGHIJKLMNOPQRSTUVWXYZèéôöêÄí•'
  string s[1]
  integer p1
  p1 = Pos (char, s1)
  if p1 > 0
    s = s2[p1]
  else
    s = char
  endif
  return (s)
end timoUpChar

// Return one character in lower case
string proc timoDnChar (string char)
  string s1[40] = 'ABCDEFGHIJKLMNOPQRSTUVWXYZèéôöêÄí•'
  string s2[40] = 'abcdefghijklmnopqrstuvwxyzÜÑîÅÇáë§'
  string s[1]
  integer p1
  p1 = Pos (char, s1)
  if p1 > 0
    s = s2[p1]
  else
    s = char
  endif
  return (s)
end timoDnChar

// Write a character overwriting, without advancing the cursor
proc tOverText(string s)
  InsertText(s,_OVERWRITE_)
  PrevChar()
end tOverText

// Convert the designated area into upper case
proc timoUpcase(integer choice)
  string char[1]
  string saved_wordset[32]
  PushPosition()
  PushBlock()
  case choice
    // Entire file
    when 1
      if YesNo("Upper case entire file?") <> 1
        goto _out
      endif
      BegFile()
      repeat
        if CurrChar() >= 0
          char = chr(CurrChar())
          tOverText(timoUpChar(char))
        endif
      until not NextChar()
    // Block
    when 2
      if not isBlockInCurrFile()
        Warn('No block in current file')
      elseif isBlockInCurrFile() == _COLUMN_
        Warn('Column blocks not allowed for UPCASE')
      else
        GotoBlockBegin()
        if isBlockInCurrFile() == _LINE_ BegLine() endif
        repeat
          if CurrChar() >= 0
            char = chr(CurrChar())
            tOverText(timoUpChar(char))
          endif
          if not NextChar() goto _out endif
          if not NextChar() goto _out endif
          if not isCursorInBlock() goto _out endif
          PrevChar()
        until FALSE
      endif
    // Current Line
    when 3
      PushPosition()
      PushBlock()
      UnmarkBlock()
      BegLine()
      MarkChar()
      if Down()
        MarkChar()
      else
        EndLine()
        MarkChar()
      endif
      timoUpcase(2)
      PopPosition()
      PopBlock()
    when 4
      PushPosition()
      PushBlock()
      UnmarkBlock()
      saved_wordset = Set(WordSet, ChrSet("a-zA-ZÜÑîÅÇáë§èéôöêÄí•"))
      MarkWord()
      Set(WordSet, saved_wordset)
      timoUpcase(2)
      PopPosition()
      PopBlock()
  endcase
_out:
  PopPosition()
  PopBlock()
end timoUpcase

// Convert the designated area into lower case
proc timoDnCase(integer choice)
  string char[1]
  string saved_wordset[32]
  PushPosition()
  PushBlock()
  case choice
    // Entire file
    when 1
      if YesNo("Lower case entire file?") <> 1
        goto _out
      endif
      BegFile()
      repeat
        if CurrChar() >= 0
          char = chr(CurrChar())
          tOverText(timoDnChar(char))
        endif
      until not NextChar()
    // Block
    when 2
      if not isBlockInCurrFile()
        Warn('No block in current file')
      elseif isBlockInCurrFile() == _COLUMN_
        Warn('Column blocks not allowed for lower case')
      else
        GotoBlockBegin()
        if isBlockInCurrFile() == _LINE_ BegLine() endif
        repeat
          if CurrChar() >= 0
            char = chr(CurrChar())
            tOverText(timoDnChar(char))
          endif
          if not NextChar() goto _out endif
          if not NextChar() goto _out endif
          if not isCursorInBlock() goto _out endif
          PrevChar()
        until FALSE
      endif
    // Current Line
    when 3
      PushPosition()
      PushBlock()
      UnmarkBlock()
      BegLine()
      MarkChar()
      if Down()
        MarkChar()
      else
        EndLine()
        MarkChar()
      endif
      timoDnCase(2)
      PopPosition()
      PopBlock()
    when 4
      PushPosition()
      PushBlock()
      UnmarkBlock()
      saved_wordset = Set(WordSet, ChrSet("a-zA-ZÜÑîÅÇáë§èéôöêÄí•"))
      MarkWord()
      Set(WordSet, saved_wordset)
      timoDncase(2)
      PopPosition()
      PopBlock()
  endcase
_out:
  PopPosition()
  PopBlock()
end timoDnCase

// New keys and menus **************************************************
forward Menu tUpcaseMenu()
forward Menu tUpcaseSubMenu()
forward Menu tDnCaseSubMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 6>      tUpcaseSubMenu()
  <CtrlAlt 5>      tDnCaseSubMenu()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tUpcaseMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

Menu tUpcaseSubMenu()
  Title = "Upcase"
  x = 55
  y = 6
  history
  "&Word at Cursor", timoUpcase(4)
  "Current &Line"  , timoUpcase(3)
  "&Block"         , timoUpcase(2)
  "&Entire file"   , timoUpcase(1)
end tUpcaseSubMenu

Menu tDnCaseSubMenu()
  Title = "Lower case"
  x = 55
  y = 6
  history
  "&Word at Cursor", timoDncase(4)
  "Current &Line"  , timoDncase(3)
  "&Block"         , timoDncase(2)
  "&Entire file"   , timoDncase(1)
end tDnCaseSubMenu

Menu tUpcaseMenu()
  Title = "Timo's upper/lower case menu"
  x = 30
  y = 3
  history
  "&UpCase           <CtrlAlt 6>"   , tUpcaseSubMenu(), DontClose
  "&DownCase         <CtrlAlt 5>"   , tDnCaseSubMenu(), DontClose
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <F11>"
end  /* tUpcaseMenu */

proc Main()
  Enable (new_keys)
  tUpcaseMenu()
end
