/* Delete blank lines for SemWare's TSE editor V4.0. To make this
   SAL macro operational, invoke the main menu (F10), choose
   "Macro", choose "Compile" and press Enter at "Execute Macro".

....................................................................
Prof. Timo Salmi ftp & http://garbo.uwasa.fi/ archives 193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi <http://www.uwasa.fi/~ts/>  ; FIN-65101,  Finland
Timo's  FAQ  materials  at   http://www.uwasa.fi/~ts/http/tsfaq.html
Dense spam-kill procmail filtering with a public email key in effect
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "WNOBLANK.S HELP"       // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's delete blank lines"
  ""
  " You can use <F11> to invoke the command "
  " menu after first exiting this help. "
  ""
  " Last updated Sun 9-January-2005 09:23:31 "
end  /* tHelpData */

// Delete blank lines once through the file
//
proc tOnePass()
  repeat
    if CurrLineLen() == 0
      KillLine()
      Up()
    endif
  until not Down()
end tOnePass

// Delete blank lines once through the block
//
proc tOnePassBlock()
  GoToblockBegin()
  repeat
    if not isCursorInBlock() break endif
    if CurrLineLen() == 0
      KillLine()
      if not isCursorInBlock() break endif
      Up()
    endif
    if not isCursorInBlock() break endif
  until not Down()
end tOnePassBlock

// Delete blank lines starting from the current cursor line.
// If the cursor is at the first line of the file, the file must
// be swept twice.
//
proc tNoblank()
  integer startLine
  PushPosition()
  startLine = CurrLine()
  tOnePass()
  if startLine == 1
    BegFile()
    tOnePass()
  endif
  PopPosition()
  KillPosition()
  Message("Blank lines have been deleted starting from the cursor line")
end tNoblank

// Delete blank lines starting from the beginning of the block.
// Because fof the first line quirk the procedure must be done twice.
//
proc tNoBlankBlock()
  if not isBlockInCurrFile()
    Warn('No block in current file')
  elseif isBlockInCurrFile() == _COLUMN_
    Warn('Column blocks not allowed')
  elseif isBlockInCurrFile() == _LINE_
    Warn('Line blocks not allowed')
  else
    PushPosition()
    tOnePassBlock()
    tOnePassBlock()
    PopPosition()
    KillPosition()
    Message("Blank lines have been deleted from the block")
  endif
end tNoBlankBlock

// New keys and menus **************************************************
forward Menu tNoblankMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 5>      tNoblank()
  <CtrlAlt 6>      tNoblankBlock()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tNoblankMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The noblank menu ******************************************************
Menu tNoblankMenu()
  Title = "Timo's delete blank lines menu"
  Width = 32
  x = 40
  y = 3
  history
  "&Start from cursor <CtrlAlt 5>"   , tNoblank()
  "&Block             <CtrlAlt 6>"   , tNoblankBlock()
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <F11>"
end  /* tNoblankMenu */

proc Main()
  Enable (new_keys)
  tNoblankMenu()
end
