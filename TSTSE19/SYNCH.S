/* Synchronize the scrolling of windows for SemWare's TSE editor
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
  title = "SYNCH.S HELP"          // The help's caption
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
  " Last updated Tue 23-January-1996 21:44:16 "
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
  <Shift CursorDown>    timoSynchAllDown()
  <Shift CursorUp>      timoSynchAllUp()
  <CtrlAlt 4>           timoSynchDown()
  <CtrlAlt 6>           timoSynchUp()
  <CtrlAlt 0>           tDisableNewKeys()
  <CtrlAlt H>           QuickHelp(tHelpData)
  <F11>                 tSynchMenu()
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
  "Synch all &up      <Shift >"      , timoSynchAllUp()
  "Synch all &down    <Shift >"      , timoSynchAllDown()
  "",,Divide
  "Syn&ch two down    <CtrlAlt 4>"    , timoSynchDown()
  "S&ynch two up      <CtrlAlt 6>"    , timoSynchUp()
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"    , tDisableNewKeys()
  "&Help              <CtrlAlt H>"    , QuickHelp(tHelpData)
  "This Menu         <F11>"
end  /* tSynchMenu */

proc Main()
  Enable (new_keys)
  tSynchMenu()
end
