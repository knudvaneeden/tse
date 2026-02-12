/* Date and time insertion alternatives for for SemWare's TSE editor
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
  title = "DATETIME.S HELP"       // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's date/time alternatives"
  ""
  " Insert date and/or time in various formats: "
  "  Sun Feb 25 09:22:00 1996"
  "  Sun 25-Feb-96"
  "  Sun 25-February-1996"
  "  09:22:06"
  ""
  " You can use <F11> to invoke the command "
  " menu after first exiting this help. "
  ""
  " Last updated Sun 25-February-1996 09:23:38 "
end  /* tHelpData */

// Give both date and time, date verbally
proc timoDateTime()
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
    InsertText(Format(weekday, ' ', month_name, ' ', day, ' ', timeStr, ' ', year), _INSERT_)
end  /* timoDateTime */

// Date, long format; Use the Scandinavian date convention
proc timoDate()
    integer mon, day, year, dow
    string  month_name[9] = ''
    string  weekday[3] = ''
    GetDate(mon, day, year, dow)    // get current date
    case mon
        when  1 month_name = 'January'
        when  2 month_name = 'February'
        when  3 month_name = 'March'
        when  4 month_name = 'April'
        when  5 month_name = 'May'
        when  6 month_name = 'June'
        when  7 month_name = 'July'
        when  8 month_name = 'August'
        when  9 month_name = 'September'
        when 10 month_name = 'October'
        when 11 month_name = 'November'
        when 12 month_name = 'December'
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
    InsertText(Format(weekday, ' ', day, '-', month_name, '-', year, ' '), _INSERT_)
end  /* timoDate */

// Date, brief format; Use the Scandinavian date convention
proc timoDateBrief()
    integer mon, day, year, dow
    string  month_name[3] = ''
    string  weekday[3] = ''
    string  yearStr[4] = ''
    GetDate(mon, day, year, dow)    // get current date
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
    yearStr = Str(year)
    InsertText(Format(weekday, ' ', day, '-', month_name, '-', yearStr[3], yearStr[4], ' '), _INSERT_)
end  /* timoDateBrief() */

// Time
proc timoTimeStamp()
  InsertText(GetTimeStr() + " ", _INSERT_)
end

// New keys and menus **************************************************
forward Menu tDateMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 1>      timoDateTime()
  <CtrlAlt 2>      timoDateBrief()
  <CtrlAlt 3>      timoDate()
  <CtrlAlt 4>      timoTimeStamp()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tDateMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The DateTimeMenu menu **********************************************
Menu tDateMenu()
  Title = "Timo's DateTime menu"
  x = 40
  y = 3
  history
  "Time&AndDate Stamp <CtrlAlt 1>"   , timoDateTime()
  "&Brief Date Stamp  <CtrlAlt 2>"   , timoDateBrief()
  "&Date Stamp        <CtrlAlt 3>"   , timoDate()
  "&Time Stamp        <CtrlAlt 4>"   , timoTimeStamp()
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <F11>"
end  /* tDateMenu */

proc Main()
  Enable (new_keys)
  tDateMenu()
end
