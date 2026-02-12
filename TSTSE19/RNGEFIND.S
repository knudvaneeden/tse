/* Find low ascii or high ascii characters in a file. A macro for
   SemWare's TSE editor V2.5. To make this SAL macro operational,
   invoke the main menu (F10), choose "Macro", choose "Compile" and
   press Enter at "Execute Macro".

....................................................................
Prof. Timo Salmi   Co-moderator of news:comp.archives.msdos.announce
Moderating at ftp:// & http://garbo.uwasa.fi archives  193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi  <URL:http://uwasa.fi/~ts>  ; FIN-65101,  Finland
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "RNGEFIND.S HELP"       // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's rangefind."
  ""
  " Find low ascii or high ascii characters in "
  " a file. Searches forward from the current "
  " position. Note that the macro is rather for "
  " generally detecting if you have special "
  " characters in the file than for finding "
  " them in sequence one by one. "
  ""
  " Low ascii is from 1 to 31 excluding formfeed. "
  " High ascii is ascii 126 and above. "
  ""
  " You can use <F11> to invoke the command "
  " menu after first exiting this help. "
  ""
  " Last updated Sun 25-February-1996 09:15:31 "
end  /* tHelpData */

// Find if the file includes any in a range of characters
proc tRangeFind(integer low, integer high)
  integer i, ok
  integer foundone = 0
  string answer[34] = "y"
  string srow[10], scol[10]
  i = low
  repeat
    if lFind(chr(i),"")
      foundone = 1
      srow = Str(CurrLine())
      scol = Str(CurrCol())
      Message ("Found " + Chr(i) + " (ascii " + Str(i) + ") on line " + srow
               + " (column " + scol + ")")
      NextChar()
      _ask:
      ok = Ask ("Continue forward range-search y/n?", answer)
      if not ok goto _end2 endif
      if (answer == "n")
        goto _end2
      elseif (answer == "y")
      else
        Alarm()
        goto _ask
      endif
    else
      i = i+1
    endif
  until (i == high)
  if foundone
    Message ("No more finds between ascii " + Str(low)+ " and " + Str(high))
  else
    Message ("No finds between ascii " + Str(low) + " and " + Str(high))
  endif
_end2:
end tRangeFind

// New keys and menus **************************************************
forward Menu tRangeFindMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 4>      tRangeFind(1,11)
  <CtrlAlt 5>      tRangeFind(13,31)
  <CtrlAlt 6>      tRangeFind(126,255)
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tRangeFindMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The range-find menu ************************************************
Menu tRangeFindMenu()
  Title = "Timo's range-find menu"
  Width = 19
  x = 40
  y = 3
  history
  "Find &1-11 low ascii     <CtlrAlt 4>"   , tRangeFind(1,11)
  "Find 13-31 &low ascii    <CtlrAlt 5>"   , tRangeFind(13,31)
  "&Find 126-255 high ascii <CtlrAlt 6>"   , tRangeFind(126,255)
  "",,Divide
  "Disable &new keys        <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help                    <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This &Menu               <F11>"
end  /* tRangeFindMenu */

proc Main()
  Enable (new_keys)
  tRangeFindMenu()
end
