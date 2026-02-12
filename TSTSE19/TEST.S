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
  title = "TEST.S HELP"           // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's testbench"
  ""
  " To try out the current tTest() procedure "
  " exit this help and press <CtrlAlt 5>"
  ""
  " You can use <F11> to invoke the command "
  " menu after first exiting this help. "
  ""
  " Last updated Tue 23-January-1996 21:44:42 "
end  /* tHelpData */

/* =======================================================================
            Beginning of the procedure(s) to be tested
   ======================================================================= */

proc tTest()
    integer mon, day, year, dow,
            hour, minu, sec, sec100
    string  month_name[3] = ''
    string  weekday[3] = ''
    string  timeStr[8] = ''
    GetDate(mon, day, year, dow)    // get current date
    GetTime(hour, minu, sec, sec100)
    case mon
        when  1 month_name = 'Jan'
        when  2 month_name = 'Feb'
        when  3 month_name = 'Mar'
        when  4 month_name = 'Apr'
        when  5 month_name = 'May'
        when  6 month_name = 'Jun'
        when  7 month_name = 'Jul'
        when  8 month_name = 'Aug'
        when  9 month_name = 'Sep'
        when 10 month_name = 'Oct'
        when 11 month_name = 'Nov'
        when 12 month_name = 'Dec'
    endcase
    case dow
      when 1 weekday = 'Sun'
      when 2 weekday = 'Mon'
      when 3 weekday = 'Tue'
      when 4 weekday = 'Wed'
      when 5 weekday = 'Thu'
      when 6 weekday = 'Fri'
      when 7 weekday = 'Sat'
    endcase
    timeStr = Str(hour / 10) + Str(hour mod 10) + ':' + Str(minu/10) + Str(minu mod 10) + ':' + Str(sec/10) + Str(sec mod 10)
    Message(Format(weekday, ' ', month_name, ' ', day, ' ', timeStr, ' ', year))
end  /* tTest */

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
