/* Count lines, words and characters in a marked block for SemWare's
   TSE editor V4.0. To make this SAL macro operational, invoke the
   main menu (F10), choose "Macro", choose "Compile" and press Enter
   at "Execute Macro".

....................................................................
Prof. Timo Salmi ftp & http://garbo.uwasa.fi/ archives 193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi <http://www.uwasa.fi/~ts/>  ; FIN-65101,  Finland
Timo's  FAQ  materials  at   http://www.uwasa.fi/~ts/http/tsfaq.html
Dense spam-kill procmail filtering with a public email key in effect
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "WCOUNT.S HELP"          // The help's caption
  x = 10                           // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's Unix wc like count."
  ""
  " This macro calculates the number of lines, words "
  " and characters in a marked block."
  ""
  " Leading but not the trailing blanks are included "
  " in the character count. The counts are not "
  " always fully accurate. The results may depend on "
  " the relative location of the block in the file. "
  ""
  " You can use <F11> to invoke the command menu "
  " after first exiting this help. "
  ""
  " Last updated Thu 2-December-2004 22:09:02 "
end  /* tHelpData */

// Count the number of lines in a block
//
integer proc tCountLinesInBlock()
  integer lines = 0
  integer key
  PushPosition()
  GoToblockBegin()
  repeat
    if KeyPressed()
      key = GetKey()
      if key == <escape>
        return(-1)
      endif
    endif
    if not RollDown() break endif
    if not isCursorInBlock() break endif
    lines = lines + 1
    if lines mod 10 == 0
      Message ("Counting lines, <Esc> aborts: " + Str(lines))
    endif
  until FALSE
  PopPosition()
  if isBlockMarked() == _LINE_ return(lines+1) endif
  return(lines)
end tCountLinesInBlock

// Count the number of words in a block
//
integer proc tCountWordsInBlock()
  integer words = 0
  integer flag = FALSE
  integer key
  PushPosition()
  GoToblockBegin()
  repeat
    if not isCursorInBlock() break endif
    if not NextChar() break endif
  until CurrChar() <> 32 and CurrChar() <> 9 and CurrChar() <> 12
  flag = TRUE
  repeat
    if KeyPressed()
      key = GetKey()
      if key == <escape>
        return(-1)
      endif
    endif
    if CurrChar() == 32 or CurrChar() ==  9 or
       CurrChar() == 12 or CurrChar() < 0
      if flag words = words + 1 endif
      if words mod 100 == 0
        Message ("Counting words, <Esc> aborts: "+ Str(words))
      endif
      flag = FALSE
    else
      flag = TRUE
    endif
  until not isCursorInBlock() or not NextChar()
  PopPosition()
  return(words)
end tCountWordsInBlock

// Count the number of characters in a block
//
integer proc tCountCharsInBlock()
  integer chars = 0
  integer key
  PushPosition()
  GoToblockBegin()
  repeat
    if KeyPressed()
      key = GetKey()
      if key == <escape>
        return(-1)
      endif
    endif
    if CurrChar() == _BEYOND_EOL_
      chars = chars - 1
    endif
    if not isCursorInBlock() break endif
    if not NextChar() break endif
    if CurrChar() >= 0
      chars = chars + 1
    endif
    if chars mod 1000 == 0
      Message ("Counting characters, <Esc> aborts: " + Str(chars))
    endif
  until FALSE
  PopPosition()
  return(chars)
end tCountCharsInBlock

// Call only counting lines
//
proc tCallCountLines()
  integer lines
  string s[79] = ""
  if isBlockInCurrFile() == _COLUMN_
    Warn ("Column blocks not allowed for COUNT")
  elseif isBlockInCurrFile()
    lines  = tCountLinesInBlock()
    if lines == -1
      s = "Aborted"
    else
      s = Str(lines) + " lines "
    endif
    if lines <> -1 s = s + "in the marked block" endif
    Message(s)
  else
    Warn ("No marked block in the current window")
  endif
end tCallCountLines

// Call only counting words
//
proc tCallCountWords()
  integer words
  string s[79] = ""
  if isBlockInCurrFile() == _COLUMN_
    Warn ("Column blocks not allowed for COUNT")
  elseif isBlockInCurrFile()
    words  = tCountWordsInBlock()
    if words == -1
      s = "Aborted"
    else
      s = Str(words) + " words "
    endif
    if words <> -1 s = s + "in the marked block" endif
    Message(s)
  else
    Warn ("No marked block in the current window")
  endif
end tCallCountWords

// Call only counting characters
//
proc tCallCountChars()
  integer chars
  string s[79] = ""
  if isBlockInCurrFile() == _COLUMN_
    Warn ("Column blocks not allowed for COUNT")
  elseif isBlockInCurrFile()
    chars  = tCountCharsInBlock()
    if chars == -1
      s = "Aborted"
    else
      s = Str(chars) + " characters "
    endif
    if chars <> -1 s = s + "in the marked block" endif
    Message(s)
  else
    Warn ("No marked block in the current window")
  endif
end tCallCountChars

// Call counting lines, words and characters
//
proc tCallCountAll()
  integer lines, words, chars
  string s[79] = ""
  if isBlockInCurrFile() == _COLUMN_
    Warn ("Column blocks not allowed for COUNT")
  elseif isBlockInCurrFile()
    lines  = tCountLinesInBlock()
    if lines == -1
      s = "Aborted"
      goto _show
    else
      s = Str(lines) + " lines "
    endif
    //
    words = tCountWordsInBlock()
    if words == -1
      goto _show
    else
      s = s + Str(words) + " words "
    endif
    //
    chars = tCountCharsInBlock()
    if chars == -1
      goto _show
    else
      s = s + Str(chars) + " characters "
    endif
    _show:
    if lines <> -1 s = s + "in the marked block" endif
    Message(s)
  else
    Warn ("No marked block in the current window")
  endif
end tCallCountAll

// New keys and menus **************************************************
forward Menu tCountMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 2>      tCallCountLines()
  <CtrlAlt 3>      tCallCountWords()
  <CtrlAlt 4>      tCallCountChars()
  <CtrlAlt 5>      tCallCountAll()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tCountMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The count menu *****************************************************
Menu tCountMenu()
  Title = "Timo's count menu"
  Width = 19
  x = 40
  y = 3
  history
  "Count &lines       <CtrlAlt 2>"   , tCallCountLines()
  "Count &words       <CtrlAlt 3>"   , tCallCountWords()
  "Count &characters  <CtrlAlt 4>"   , tCallCountChars()
  "Count &all         <CtrlAlt 5>"   , tCallCountAll()
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <F11>"
end tCountMenu

proc Main()
  Enable (new_keys)
  tCountMenu()
end
