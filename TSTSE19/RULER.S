/* Put a ruler to the screen for SemWare's TSE editor V2.5. To make
   this SAL macro operational, invoke the main menu (F10), choose
   "Macro", choose "Compile" and press Enter at "Execute Macro".

....................................................................
Prof. Timo Salmi   Co-moderator of news:comp.archives.msdos.announce
Moderating at ftp:// & http://garbo.uwasa.fi archives  193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi  <URL:http://uwasa.fi/~ts>  ; FIN-65101,  Finland
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "RULER.S HELP"           // The help's caption
  x = 10                           // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's ruler"
  ""
  " Displays a relative, absolute or a centered "
  " ruler on the screen. "
  ""
  " You can use <F11> to invoke the command "
  " menu after first exiting this help. "
  ""
  " Last updated Tue 23-January-1996 21:42:30 "
end  /* tHelpData */

proc tRulerAbs()
  string s[255]
  Set(Attr, Color(BRIGHT Red ON Black))
  s = 'ббббеббб10ббббеббб20ббббеббб30ббббеббб40ббббеббб50ббббеббб60ббббеббб70ббббеббб80ббббеббб90ббббебб100'
    + 'ббббебб110ббббебб120ббббебб130ббббебб140ббббебб150ббббебб160ббббебб170ббббебб180ббббебб190ббббебб200'
    + 'ббббебб210ббббебб220ббббебб230ббббебб240ббббебб250ббббе'
  GotoXY(1,CurrRow()+1)
  Writeline(SubStr(s,CurrXoffset()+1,255))
end  tRulerAbs

proc tRulerRel()
  string s[255]
  Set(Attr, Color(BRIGHT Magenta ON Black))
  s = 'ббббеббб10ббббеббб20ббббеббб30ббббеббб40ббббеббб50ббббеббб60ббббеббб70ббббеббб80ббббеббб90ббббебб100'
    + 'ббббебб110ббббебб120ббббебб130ббббебб140ббббебб150ббббебб160ббббебб170ббббебб180ббббебб190ббббебб200'
    + 'ббббебб210ббббебб220ббббебб230ббббебб240ббббебб250ббббе'
  GotoXY(1,CurrRow()+1)
  Writeline(s)
end  tRulerRel

proc tRulerCent()
  string s[255]
  Set(Attr, Color(BRIGHT yellow ON Black))
  s = 'ббббеббб90ббббеббб80ббббеббб70ббббеббб60ббббеббб50ббббеббб40ббббеббб30ббббеббб20ббббеббб10ббббебббб0'
    + 'ббббеббб10ббббеббб20ббббеббб30ббббеббб40ббббеббб50ббббеббб60ббббеббб70ббббеббб80ббббеббб90ббббебб100'
  GotoXY(1,CurrRow()+1)
  Writeline(SubStr(s,101-CurrCol()+CurrXoffset(),255))
end  tRulerCent

// New keys and menus **************************************************
forward Menu tRulerMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 4>      tRulerAbs()
  <CtrlAlt 5>      tRulerRel()
  <CtrlAlt 6>      tRulerCent()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tRulerMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The ruler menu *****************************************************
Menu tRulerMenu()
  Title = "Timo's ruler menu"
  Width = 19
  x = 40
  y = 3
  history
  "&Absolute ruler    <CtrlAlt 4>"   , tRulerAbs()
  "&Relative ruler    <CtrlAlt 5>"   , tRulerRel()
  "&Centered ruler    <CtrlAlt 6>"   , tRulerCent()
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <F11>"
end tRulerMenu

proc Main()
  Enable (new_keys)
  tRulerMenu()
end
