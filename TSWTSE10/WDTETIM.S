/* Date and time insertion alternatives for for SemWare's TSE editor
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
  title = "WDTETIM.S HELP"        // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's date/time alternatives"
  ""
  " Insert date and/or time in various formats: "
  "  Sun Dec 12 05:39:39 2004"
  "  Sun 12-Dec-04"
  "  Sun 12-Dec-2004"
  "  Sun 12-December-2004"
  "   5:39:52"
  "  Su 12-joulu-04"
  "  Sunnuntaina, 12. joulukuuta, 2004"
  "  Sun, 12 Dec 2004 05:40:18 +0200 (EET)"
  ""
  " You can use <F11> to invoke the command "
  " menu after first exiting this help. "
  ""
  " Last updated Thu 6-January-2005 20:42:41 "
end  /* tHelpData */

// Give both date and time, date verbally
// Thu Jan  6 20:40:53 2005
// Uses constant field lengths
proc timoDateTime()
    integer mon, day, year, dow,
            hour, minu, sec, sec100
    string  month_name[3] = ''
    string  weekday[3] = ''
    string  timeStr[8] = ''
    string  dayStr[2] = ''
    GetDate(mon, day, year, dow)    // get current date
    GetTime(hour, minu, sec, sec100)
    if day < 10
      dayStr = ' ' + Str(day)
    else
      dayStr = Str(day)
    endif
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
    InsertText(Format(weekday, ' ', month_name, ' ', dayStr, ' ', timeStr, ' ', year), _INSERT_)
end timoDateTime

// Give both date and time, date verbally, Usenet + email Style
// Sun, 2 Jan 2000 22:28:16 +0200 (EET)
proc timoEmailDateTime()
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
    InsertText(Format(weekday, ', ', day, ' ', month_name, ' ', year, ' ', timeStr, ' +0200 (EET)'), _INSERT_)
end timoEmailDateTime

// Date, long format; Use the Scandinavian date convention
// Sun 2-January-2000
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
// Sun 2-Jan-00
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

// Date, brief format, 4-digit year; Use the Scandinavian date convention
// Sun 2-Jan-2000
proc timoDateBrief4()
    integer mon, day, year, dow
    string  month_name[3] = ''
    string  weekday[3] = ''
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
    InsertText(Format(weekday, ' ', day, '-', month_name, '-', year, ' '), _INSERT_)
end  /* timoDateBrief4() */

// Time
// 22:17:56
proc timoTimeStamp()
  InsertText(GetTimeStr() + " ", _INSERT_)
end

// Date, brief format; Use the Scandinavian date convention
// Su 2-tammi-00
proc timoFinnishDateBrief()
    integer mon, day, year, dow
    string  month_name[6] = ''
    string  weekday[2] = ''
    string  yearStr[4] = ''
    GetDate(mon, day, year, dow)    // get current date
    case mon
        when  1 month_name = 'tammi'
        when  2 month_name = 'helmi'
        when  3 month_name = 'maalis'
        when  4 month_name = 'huhti'
        when  5 month_name = 'touko'
        when  6 month_name = 'kes„'
        when  7 month_name = 'hein„'
        when  8 month_name = 'elo'
        when  9 month_name = 'syys'
        when 10 month_name = 'loka'
        when 11 month_name = 'marras'
        when 12 month_name = 'joulu'
    endcase
    case dow
      when 1 weekday = 'Su'
      when 2 weekday = 'Ma'
      when 3 weekday = 'Ti'
      when 4 weekday = 'Ke'
      when 5 weekday = 'To'
      when 6 weekday = 'Pe'
      when 7 weekday = 'La'
    endcase
    yearStr = Str(year)
    InsertText(Format(weekday, ' ', day, '-', month_name, '-', yearStr[3], yearStr[4], ' '), _INSERT_)
end  timoFinnishDateBrief

// Date, long format in Finnish; Use the Scandinavian date convention
// Sunnuntaina, 2. tammikuuta, 2000
proc timoFinnishDate()
    integer mon, day, year, dow
    string  month_name[11] = ''
    string  weekday[13] = ''
    GetDate(mon, day, year, dow)    // get current date
    case mon
        when  1 month_name = 'tammikuuta'
        when  2 month_name = 'helmikuuta'
        when  3 month_name = 'maaliskuuta'
        when  4 month_name = 'huhtikuuta'
        when  5 month_name = 'toukokuuta'
        when  6 month_name = 'kes„kuuta'
        when  7 month_name = 'hein„kuuta'
        when  8 month_name = 'elokuuta'
        when  9 month_name = 'syyskuuta'
        when 10 month_name = 'lokakuuta'
        when 11 month_name = 'marraskuuta'
        when 12 month_name = 'joulukuuta'
    endcase
    case dow
      when 1 weekday = 'Sunnuntaina'
      when 2 weekday = 'Maanantaina'
      when 3 weekday = 'Tiistaina'
      when 4 weekday = 'Keskiviikkona'
      when 5 weekday = 'Torstaina'
      when 6 weekday = 'Perjantaina'
      when 7 weekday = 'Lauantaina'
    endcase
    InsertText(Format(weekday, ', ', day, '. ', month_name, ', ', year, ' '), _INSERT_)
end timoFinnishDate

// New keys and menus **************************************************
forward Menu tDateMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 1>      timoDateTime()
  <CtrlAlt 2>      timoDateBrief()
  <CtrlAlt 3>      timoDateBrief4()
  <CtrlAlt 4>      timoDate()
  <CtrlAlt 5>      timoTimeStamp()
  <CtrlAlt 6>      timoFinnishDateBrief()
  <CtrlAlt 7>      timoFinnishDate()
  <CtrlAlt 8>      timoEmailDateTime()
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
  "Time&AndDate Stamp        <CtrlAlt 1>"   , timoDateTime()
  "&Brief Date Stamp         <CtrlAlt 2>"   , timoDateBrief()
  "Brief Date &4-year        <CtrlAlt 3>"   , timoDateBrief4()
  "&Date Stamp               <CtrlAlt 4>"   , timoDate()
  "&Time Stamp               <CtrlAlt 5>"   , timoTimeStamp()
  "&Finnish Brief Date Stamp <CtrlAlt 6>"   , timoFinnishDateBrief()
  "F&innish Date Stamp       <CtrlAlt 7>"   , timoFinnishDate()
  "&Usenet+email Date Stamp  <CtrlAlt 8>"   , timoEmailDateTime()
  "",,Divide
  "Disable &new keys         <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help                     <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu                <F11>"
end  /* tDateMenu */

proc Main()
  Enable (new_keys)
  tDateMenu()
end
