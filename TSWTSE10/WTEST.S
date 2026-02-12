/* A testbench for additional commands for SemWare's TSE editor
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
  title = "WTEST.S HELP"          // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's SAL macros testbench "
  ""
  " To try out the current tTest() procedure "
  " exit this help and press <CtrlAlt 5>"
  ""
  " You can use <F11> to invoke the command "
  " menu after first exiting this help. "
  ""
  " Last updated Sun 9-January-2005 15:56:59 "
end  /* tHelpData */

/* =======================================================================
            Beginning of the procedure(s) to be tested
   ======================================================================= */

proc tTest()
  // whatever
end tTest

/* =======================================================================
            End of the procedure(s) to be tested
   ======================================================================= */

// New keys and menus **************************************************
forward Menu tTestMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 5>      tTest()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tTestMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The test menu ******************************************************
Menu tTestMenu()
  Title = "Timo's testbench menu"
  Width = 19
  x = 40
  y = 3
  history
  "&Test              <CtrlAlt 5>"   , tTest()
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <F11>"
end  /* tTestMenu */

proc Main()
  Enable (new_keys)
  tTestMenu()
end
