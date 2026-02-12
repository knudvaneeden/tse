/* A testbench for additional commands for SemWare's TSE editor
   V2.5. To make this SAL macro operational, invoke the main menu
   (F10), choose "Macro", choose "Compile" and press Enter at
   "Execute Macro".

....................................................................
Prof. Timo Salmi   Co-moderator of news:comp.archives.msdos.announce
Moderating at ftp:// & http://garbo.uwasa.fi archives  193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi  <URL:http://uwasa.fi/~ts>  ; FIN-65101,  Finland
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "DUMP.S HELP"           // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's dump"
  ""
  " Dumps a column block in binary, octal, "
  " decimal or hexadecimal.  E.g. in decimal "
  ' a "Timo" would be dumped at the cursor as '
  " 84 105 109 111 "
  ""
  " You can use <F11> to invoke the command "
  " menu after first exiting this help. "
  ""
  " Last updated Tue 23-January-1996 22:49:58 "
end  /* tHelpData */

proc timoDump(integer base)
  string s[255] = ''
  integer i = 0
  integer p
  //
  if not (isBlockInCurrFile() == _COLUMN_)
    Warn('No column block in the current window')
  else
    PushPosition()
    //
    // Check that the height is only 1
    GotoBlockBegin()
    if Down()
      if isCursorInBlock()
        Warn('The maximum block height is 1 for this operation')
        PopPosition()
        return()
      endif
    endif
    //
    // Read the row, then write the decimal ascii codes
    PopPosition()
    PushPosition()
    s = GetMarkedText()
    p = Length(s)
    repeat
      i = i + 1
      InsertText(Str(Asc(s[i]),base) + ' ')
    until i >= p
    PopPosition()
  endif
end timoDump

// New keys and menus **************************************************
forward Menu timoDumpMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 3>      timoDump(2)
  <CtrlAlt 4>      timoDump(8)
  <CtrlAlt 5>      timoDump(10)
  <CtrlAlt 6>      timoDump(16)
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            timoDumpMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The dump menu ******************************************************
Menu timoDumpMenu()
  Title = "Timo's dump menu"
  Width = 19
  x = 40
  y = 3
  history
  "&Binary dump       <CtrlAlt 3>"   , timoDump(2)
  "&Octal dump        <CtrlAlt 4>"   , timoDump(8)
  "&Decimal dump      <CtrlAlt 5>"   , timoDump(10)
  "He&x dump          <CtrlAlt 6>"   , timoDump(16)
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <F11>"
end timoDumpMenu

proc Main()
  Enable (new_keys)
  timoDumpMenu()
end
