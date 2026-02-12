/* Miscellaneous additional commands for SemWare's TSE editor V2.5.
   To make this SAL macro operational, invoke the main menu (F10),
   choose "Macro", choose "Compile" and press Enter at "Execute
   Macro".

....................................................................
Prof. Timo Salmi   Co-moderator of news:comp.archives.msdos.announce
Moderating at ftp:// & http://garbo.uwasa.fi archives  193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi  <URL:http://uwasa.fi/~ts>  ; FIN-65101,  Finland
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "MISC.S HELP"           // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's miscellania"
  ""
  " You can use <F11> to invoke the command "
  " menu after first exiting this help. "
  ""
  " Last updated Sun 25-February-1996 17:45:16 "
end  /* tHelpData */

// File name options ***************************************************
proc timoInsertFileName()
  string fn[80]
  fn = Upper(SplitPath(CurrFilename(),_NAME_))
  fn = fn + Upper(SplitPath(CurrFilename(),_EXT_))
  InsertText(fn)
end timoInsertFileName

proc timoInsertFullFilename()
  InsertText(Upper(CurrFilename()), _DEFAULT_)
end timoInsertFullFileName

// For timoGoDown and timoGoUp **************************************
string linesToGoUpDown[22] = "50"
integer goupdown_hist

// Advance the cursor for manual paging
proc timoGoDown()
  integer n = 0
  integer i = 0
  integer ok = FALSE
  ok = Ask("Number of lines down: ", linesToGoUpDown, goupdown_hist)
  if ok and Length(linesToGoUpDown) > 0
    n = Val(linesToGoUpDown)
    while i < n
      i = i + 1
      Down()
    endwhile
  endif
end

proc timoGoUp()
  integer n = 0
  integer i = 0
  integer ok = FALSE
  ok = Ask("Number of lines up: ", linesToGoUpDown, goupdown_hist)
  if ok and Length(linesToGoUpDown) > 0
    n = Val(linesToGoUpDown)
    while i < n
      i = i + 1
      Up()
    endwhile
  endif
end

// Find the longest line ***********************************************
proc timoMaxLength()
  integer m, r
  BegFile()
  m = CurrLineLen()
  r = CurrLine()
  while Down()
    if CurrLineLen() > m
      m = CurrLineLen()
      r = CurrLine()
    endif
  endwhile
  GotoLine(r)
  BegLine()
  ScrollToRow(Query(WindowRows) / 2)
  Message ('Longest line ', Str(r), ', length ', Str(m))
end timoMaxLength

// Send the current line to the printer ********************************
proc timoPrintLine()
  PushBlock()
  UnmarkBlock()
  MarkLine()
  PrintBlock()
  UnmarkBlock()
  Down()
  PopBlock()
end timoPrintLine

// Reload the current file
// My thanks for the earlier help on this from Richard Blackburn
proc timoReloadFile()
  string fn[80] = CurrFilename()    // save the file name
  if FileChanged()
    AbandonFile()                   // quit the file
    EditFile(fn)                    // edit the file again
  endif
end timoReloadFile

menu timoReloadFileMenu()
  Title = "Reload the current file"
  x = 5
  y = 4
  history
  "&Yes, abandoning unsaved changes", timoReloadFile()
  "&No, cancel the operation"
end timoReloadFileMenu

// New keys and menus **************************************************
forward Menu tMiscMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 1>      timoInsertFilename()
  <CtrlAlt 2>      timoInsertFullFilename()
  <CtrlAlt 3>      timoGoDown()
  <CtrlAlt 4>      timoGoUp()
  <CtrlAlt 5>      timoMaxLength()
  <CtrlAlt 6>      timoPrintLine()
  <CtrlAlt 7>      timoReloadFileMenu()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tMiscMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1
    Disable(new_keys)
    DelHistory(goupdown_hist)
  endif
end

// The miscellaneous routines menu ************************************
Menu tMiscMenu()
  Title = "Type file name"
  x = 40
  y = 3
  history
  "&Insert filename      <CtrlAlt 1>"   , timoInsertFilename()
  "Insert &full filename <CtrlAlt 2>"   , timoInsertFullFilename()
  "Manual paging",,Divide
  "Lines &Down...        <CtrlAlt 3>"   , timoGoDown()
  "Lines &Up...          <CtrlAlt 4>"   , timoGoUp()
  "Find",,Divide
  "&Goto longest line    <CtrlAlt 5>"   , timoMaxLength()
  "Print",,Divide
  "&Print current line   <CtrlAlt 6>"   , timoPrintLine()
  "File",,Divide
  "&Reload current file  <CtrlAlt 7>"   , timoReloadFileMenu()
  "Administer",,Divide
  "Disable new &keys     <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help                 <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu            <F11>"
end  /* tMiscMenu */

proc Main()
  goupdown_hist = GetFreeHistory("MISC:timogo")
  Enable (new_keys)
  tMiscMenu()
end
