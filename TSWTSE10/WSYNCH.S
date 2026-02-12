/* Synchronize the scrolling of windows for SemWare's TSE editor
   V4.0. To make this SAL macro operational, invoke the main menu
   (F10), choose "Macro", choose "Compile" and press Enter at
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
  title = "WSYNCH.S HELP"         // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Timo's synchronized scrolling of windows. "
  ""
  " If you have split the screen into two or "
  " more windows, you can scroll the text in "
  " the windows in unison with these commands. "
  " The commands allow you to scroll either "
  " all the windows or the two most current. "
  ""
  " You can use <F11> to invoke the command "
  " menu after first exiting this help. "
  ""
  " Last updated Sun 9-January-2005 15:54:05 "
end  /* tHelpData */

// Roll all windows down in unison
proc timoSynchAllDown()
integer wn, wn1
  wn1 = WindowId()
  RollDown()
  while TRUE
    NextWindow()
    wn = WindowId()
    if wn == wn1
      break
    endif
    RollDown()
  endwhile
end timoSynchAllDown

// Roll all windows up in unison
proc timoSynchAllUp()
integer wn, wn1
  wn1 = WindowId()
  RollUp()
  while TRUE
    NextWindow()
    wn = WindowId()
    if wn == wn1
      break
    endif
    RollUp()
  endwhile
end timoSynchAllUp

// Roll only two windows down in unison
proc timoSynchDown()
  RollDown()
  if NextWindow()
    RollDown()
    PrevWindow()
  endif
end timoSynchDown

// Roll only two windows up in unison
proc timoSynchUp()
  RollUp()
  if NextWindow()
    RollUp()
    PrevWindow()
  endif
end timoSynchUp

// New keys and menus **************************************************
forward Menu tSynchMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <Alt CursorDown>    timoSynchAllDown()
  <Alt CursorUp>      timoSynchAllUp()
  <CtrlAlt 4>         timoSynchDown()
  <CtrlAlt 6>         timoSynchUp()
  <CtrlAlt 0>         tDisableNewKeys()
  <CtrlAlt H>         QuickHelp(tHelpData)
  <F11>               tSynchMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The Synch menu *****************************************************
Menu tSynchMenu()
  Title = "Timo's synchronize menu"
  x = 44
  y = 3
  history
  "Synch all &up      <Alt >"      , timoSynchAllUp()
  "Synch all &down    <Alt >"      , timoSynchAllDown()
  "",,Divide
  "Syn&ch two down    <CtrlAlt 4>"  , timoSynchDown()
  "S&ynch two up      <CtrlAlt 6>"  , timoSynchUp()
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"  , tDisableNewKeys()
  "&Help              <CtrlAlt H>"  , QuickHelp(tHelpData)
  "This Menu         <F11>"
end  /* tSynchMenu */

proc Main()
  Enable (new_keys)
  tSynchMenu()
end
