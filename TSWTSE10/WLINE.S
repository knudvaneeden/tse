/* Insert line numbers, for SemWare's TSE editor V4.0. To make this
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
  title = "WLINE.S HELP"          // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's line numbering macro "
  ""
  " Puts a line number at the beginning of "
  " the line where the cursor is located. "
  ""
  " With the possibility of counting the lines "
  " from the beginning of the file or from the "
  " current line. In the latter case the user "
  " is prompted for the initial value."
  ""
  " You can use <F11> to invoke the command "
  " menu after first exiting this help. "
  ""
  " Last updated Sun 9-January-2005 09:20:49 "
end  /* tHelpData */

/* =======================================================================
            Beginning of the line marking procedure(s)
   ======================================================================= */

// Initializations
//
integer start_line = 1
integer start_line_hist
integer line_counter = 1

// Insert line number, counting from the file top and starting with 1
proc tLineNumberT()
  string lineN[10]
  string s[10] = ''
  integer p
  integer i = 5
  //
  lineN = Str(CurrLine())
  p = Length(lineN)
  while i > p
    i = i - 1
    s = s + ' '
  endwhile
  BegLine()
  InsertText(lineN + ':' + s)
  BegLine()
  if not Down() AddLine() endif
end tLineNumberT

// Anchor the starting line
proc tAnchorLine()
  string vast[11] = Str(start_line)
  Ask("Starting number: ", vast, start_line_hist)
  AddHistoryStr (vast, start_line_hist)
  start_line = Val(vast)
  line_counter = start_line
end tAnchorLine

// Insert line number, counting from the current line
proc tLineNumberC()
  string lineN[10]
  string s[10] = ''
  integer p
  integer i = 5
  //
  lineN = Str(line_counter)
  p = Length(lineN)
  line_counter = line_counter + 1
  while i > p
    i = i - 1
    s = s + ' '
  endwhile
  BegLine()
  InsertText(lineN + ':' + s)
  BegLine()
  if not Down() AddLine() endif
end tLineNumberC

/* =======================================================================
            End of the line marking procedure(s)
   ======================================================================= */

// New keys and menus **************************************************
forward Menu tLineMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 5>      tLineNumberT()
  <CtrlAlt 6>      tAnchorLine()
  <CtrlAlt 7>      tLineNumberC()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tLineMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1
    Disable(new_keys)
    DelHistory(start_line_hist)
  endif
end

// The test menu ******************************************************
Menu tLineMenu()
  Title = "Timo's linenumber menu"
  Width = 29
  x = 30
  y = 3
  history
  "Line number, count from &top, top=1    <CtrlAlt 5>"   , tLineNumberT()
  "&Anchor to the current line, ask start <CtrlAlt 6>"   , tAnchorLine()
  "Line number, continue from &current    <CtrlAlt 7>"   , tLineNumberC()
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"                 , tDisableNewKeys()
  "&Help              <CtrlAlt H>"                 , QuickHelp(tHelpData)
  "This Menu         <F11>"
end  /* tTestMenu */

proc Main()
  start_line_hist = GetFreeHistory("WLINE:tAnchorLine")
  Enable (new_keys)
  tLineMenu()
end
