/* Cancel the effects of right-justification for SemWare's TSE
   editor V4.0. To make this SAL macro operational, invoke the main
   menu (F10), choose "Macro", choose "Compile" and press Enter at
   "Execute Macro".

....................................................................
Prof. Timo Salmi ftp & http://garbo.uwasa.fi/ archives 193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi <http://www.uwasa.fi/~ts/>  ; FIN-65101,  Finland
Timo's  FAQ  materials  at   http://www.uwasa.fi/~ts/http/tsfaq.html
Dense spam-kill procmail filtering with a public email key in effect
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "WDEJUSTI.S HELP"       // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's dejustify a right margin "
  ""
  " The Justify procedure in the Potpourri collection "
  " justifies a paragraph based on the right margin. "
  " The dejustify procedure in this macro collection "
  " can be used to cancel the effect. "
  ""
  " You can use <F11> to invoke the command menu "
  " after first exiting this help. "
  ""
  " Last updated Fri 7-January-2005 22:06:01 "
end  /* tHelpData */

/* These procedures are used to weed out the superfluous spaces.
   That is to dejustify right adjusted text */

// Auxiliary
proc timoGotoParagraphBegin()
  BegLine()
  if PosFirstNonWhite() > 0        // If we are not on an "empty" line
    repeat
      Up()
    until PosFirstNonWhite() == 0  OR CurrLine() == 1
    if PosFirstNonWhite() == 0
      Down()
    endif
  endif
  if PosFirstNonWhite() > 0
    GotoColumn(PosFirstNonWhite())
  endif
end

// Auxiliary
proc timoGotoParagraphEnd(integer backtrack)
  BegLine()
  if PosFirstNonWhite() > 0
    repeat
      Down()
    until PosFirstNonWhite() == 0 OR CurrLine() >= NumLines()
    if CurrLine() == NumLines()
      EndLine()
    else
      if backtrack == 1
        PrevChar()
      endif
    endif
  endif
end

// Auxiliary
proc timoMakeBlock()
  PushPosition()
  UnmarkBlock()
  timoGotoParagraphBegin()
  MarkChar()
  timoGotoParagraphEnd(1)
  MarkChar()
  PopPosition()
end

proc timoCondense()
  integer i = 0
  PushPosition()
  ExecMacro("wrappara")
  PopPosition()
  //
  repeat
    i = i + 1
    timoMakeBlock()
    if isBlockMarked() AND isBlockInCurrFile()
      lReplace("  "," ","ln")
    endif
  until i == 10
  UnmarkBlock()
  timoGotoParagraphEnd(0)
  while PosFirstNonWhite() == 0 AND CurrLine() < NumLines()
    Down()
  endwhile
  ScrollToRow(3*Query(WindowRows)/4)
end timoCondense

// New keys and menus **************************************************
forward Menu timoCondenseMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 5>      timoCondense()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            timoCondenseMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The condense menu ******************************************************
Menu timoCondenseMenu()
  Title = "Timo's dejustify menu"
  Width = 19
  x = 40
  y = 3
  history
  "&Dejustify right margin <CtrlAlt 5>"   , timoCondense()
  "",,Divide
  "Disable &new keys       <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help                   <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This &Menu              <F11>"
end  /* timoCondenseMenu */

proc Main()
  Enable (new_keys)
  timoCondenseMenu()
end
