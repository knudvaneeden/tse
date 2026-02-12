/* Filter Unix email characters to IBM format for SemWare's TSE
   editor V4.0. Somewhat specialized and may take a bit figuring
   out. To make this SAL macro operational, invoke the main menu
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
  title = "WMAI2IBM.S HELP"       // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's Unix email to IBM format "
  ""
  " The purpose of this macro is to filter Unix "
  " email messages into an IBM readable format. "
  " Latin1 and Mac characters are converted and "
  " the file is intelligently detabbed. "
  ""
  " You can use <F11> to invoke the command menu "
  " after first exiting this help. "
  ""
  " Last updated Sun 9-January-2005 15:01:54 "
end  /* tHelpData */

// Detab one line ******************************************************
integer proc tDetabOneMailLine(var integer tabCount)
  string s[255], tmpb[255], tmp1[255], tmp2[255]
  string tab[1] = chr(9)
  integer tabWd
  integer p, blanks
  //
  s = GetText(1,255)
  tabCount = 0
  p = Pos(tab,s)
  if p == 0
    goto out
  endif
  //
  tabWd = Query(TabWidth)
  while p > 0
    blanks = TabWd - ((p-1) mod TabWd)
    tmp1 = SubStr(s,1,p-1)
    tmpb = Format(" ":blanks)
    tmp2 = SubStr(s,p+1,255)
    if Length(tmp1) + Length(tmpb) + Length(tmp2) > 255
      return(0)      // Signal an error
    endif
    s = tmp1 + tmpb + tmp2
    tabCount = tabCount + 1
    p = Pos(tab,s)
  endwhile
  //
  BegLine()
  KillToEol()
  InsertText(s,_INSERT_)
  BegLine()
out:
  return(1)          // All ok
end tDetabOneMailLine

// Detab the entire file
proc tDetabMailFile()
 integer m = 0
 integer ok = 1               // ok signal from tDetabOneLine
 integer countTabs = 0
 integer t
 PushPosition()
 BegFile()
 Message('working...')
 repeat                       // Check for excessively long lines
   if CurrLineLen() > m
     m = CurrLineLen()
   endif
 until not Down()
 if m > 255
   Warn('File cannot be detabbed, line(s) exceed 255 characters')
 else                         // Detab
   BegFile()
   repeat
     if not tDetabOneMailLine(t)
       ok = 0                 // not ok
       Warn('This line cannot be detabbed, extends to over 255 characters')
       break
     endif
     countTabs = countTabs + t
   until not Down()
 endif
 if ok                        // Back to where we where if ok
   PopPosition()
   BegLine()
   Message ('Expanded ' + Str(countTabs) + ' tabs')
 else
   KillPosition()
 endif
end tDetabMailFile

// Convert 8-bit Latin1 Scandinavian characters to their 8-bit IBM
// PC counterparts
proc timoLat1MailToIbm(string FiltOptString)
  if FiltOptString == 'gln'
    if not isBlockInCurrFile()
      Warn('No block in the current window')
    endif
  endif
  lReplace("‡","Ö",FiltOptString)
  lReplace("·","†",FiltOptString)
  lReplace("‚","É",FiltOptString)
  lReplace("‰","Ñ",FiltOptString)
  lReplace("Â","Ü",FiltOptString)
  lReplace("Ê","ë",FiltOptString)
  lReplace("Á","á",FiltOptString)
  lReplace("Ë","ä",FiltOptString)
  lReplace("È","Ç",FiltOptString)
  lReplace("Í","à",FiltOptString)
  lReplace("Î","â",FiltOptString)
  lReplace("Ï","ç",FiltOptString)
  lReplace("Ì","°",FiltOptString)
  lReplace("Ó","å",FiltOptString)
  lReplace("Ô","ã",FiltOptString)
  lReplace("Ò","§",FiltOptString)
  lReplace("Ú","ï",FiltOptString)
  lReplace("Û","¢",FiltOptString)
  lReplace("Ù","ì",FiltOptString)
  lReplace("ˆ","î",FiltOptString)
  lReplace("˘","ó",FiltOptString)
  lReplace("˙","£",FiltOptString)
  lReplace("˚","ñ",FiltOptString)
  lReplace("¸","Å",FiltOptString)
  lReplace("ƒ","é",FiltOptString)
  lReplace("≈","è",FiltOptString)
  lReplace("∆","í",FiltOptString)
  lReplace("«","Ä",FiltOptString)
  lReplace("…","ê",FiltOptString)
  lReplace("—","•",FiltOptString)
  lReplace("÷","ô",FiltOptString)
  lReplace("‹","ö",FiltOptString)
  lReplace("ß","",FiltOptString)
  lReplace('≤','"',FiltOptString)
end timoLat1MailToIbm

// Covert "Mac" Scandinavian characters to their 8-bit IBM PC equivalents
proc TimoMacMail2Pc(string FiltOptString)
  if FiltOptString == 'gln'
    if not isBlockInCurrFile()
      Warn('No block in the current window')
    endif
  endif
  lReplace("=01","",FiltOptString)
  lReplace("=09","	",FiltOptString)
  lReplace("=0C","",FiltOptString)
  lReplace("=20"," ",FiltOptString)
  lReplace("=21","!",FiltOptString)
  lReplace('=22','"',FiltOptString)
  lReplace("=23","#",FiltOptString)
  lReplace("=24","$",FiltOptString)
  lReplace("=25","%",FiltOptString)
  lReplace("=26","&",FiltOptString)
  lReplace("=27","'",FiltOptString)
  lReplace("=28","(",FiltOptString)
  lReplace("=29",")",FiltOptString)
  lReplace("=2A","*",FiltOptString)
  lReplace("=2B","+",FiltOptString)
  lReplace("=2C",",",FiltOptString)
  lReplace("=2D","-",FiltOptString)
  lReplace("=2E",".",FiltOptString)
  lReplace("=2F","/",FiltOptString)
  lReplace("=30","0",FiltOptString)
  lReplace("=31","1",FiltOptString)
  lReplace("=32","2",FiltOptString)
  lReplace("=33","3",FiltOptString)
  lReplace("=34","4",FiltOptString)
  lReplace("=35","5",FiltOptString)
  lReplace("=36","6",FiltOptString)
  lReplace("=37","7",FiltOptString)
  lReplace("=38","8",FiltOptString)
  lReplace("=39","9",FiltOptString)
  lReplace("=3A",":",FiltOptString)
  lReplace("=3B",";",FiltOptString)
  lReplace("=3C","<",FiltOptString)
  lReplace("=3E",">",FiltOptString)
  lReplace("=3F","?",FiltOptString)
  lReplace("=40","@",FiltOptString)
  lReplace("=41","A",FiltOptString)
  lReplace("=42","B",FiltOptString)
  lReplace("=43","C",FiltOptString)
  lReplace("=44","D",FiltOptString)
  lReplace("=45","E",FiltOptString)
  lReplace("=46","F",FiltOptString)
  lReplace("=47","G",FiltOptString)
  lReplace("=48","H",FiltOptString)
  lReplace("=49","I",FiltOptString)
  lReplace("=4A","J",FiltOptString)
  lReplace("=4B","K",FiltOptString)
  lReplace("=4C","L",FiltOptString)
  lReplace("=4D","M",FiltOptString)
  lReplace("=4E","N",FiltOptString)
  lReplace("=4F","O",FiltOptString)
  lReplace("=50","P",FiltOptString)
  lReplace("=51","Q",FiltOptString)
  lReplace("=52","R",FiltOptString)
  lReplace("=53","S",FiltOptString)
  lReplace("=54","T",FiltOptString)
  lReplace("=55","U",FiltOptString)
  lReplace("=56","V",FiltOptString)
  lReplace("=57","W",FiltOptString)
  lReplace("=58","X",FiltOptString)
  lReplace("=59","Y",FiltOptString)
  lReplace("=5A","Z",FiltOptString)
  lReplace("=5B","[",FiltOptString)
  lReplace("=5C","\",FiltOptString)
  lReplace("=5D","]",FiltOptString)
  lReplace("=5E","^",FiltOptString)
  lReplace("=5F","_",FiltOptString)
  lReplace("=60","`",FiltOptString)
  lReplace("=61","a",FiltOptString)
  lReplace("=62","b",FiltOptString)
  lReplace("=63","c",FiltOptString)
  lReplace("=64","d",FiltOptString)
  lReplace("=65","e",FiltOptString)
  lReplace("=66","f",FiltOptString)
  lReplace("=67","g",FiltOptString)
  lReplace("=68","h",FiltOptString)
  lReplace("=69","i",FiltOptString)
  lReplace("=6A","j",FiltOptString)
  lReplace("=6B","k",FiltOptString)
  lReplace("=6C","l",FiltOptString)
  lReplace("=6D","m",FiltOptString)
  lReplace("=6E","n",FiltOptString)
  lReplace("=6F","o",FiltOptString)
  lReplace("=70","p",FiltOptString)
  lReplace("=71","q",FiltOptString)
  lReplace("=72","r",FiltOptString)
  lReplace("=73","s",FiltOptString)
  lReplace("=74","t",FiltOptString)
  lReplace("=75","u",FiltOptString)
  lReplace("=76","v",FiltOptString)
  lReplace("=77","w",FiltOptString)
  lReplace("=78","x",FiltOptString)
  lReplace("=79","y",FiltOptString)
  lReplace("=7A","z",FiltOptString)
  lReplace("=7B","{",FiltOptString)
  lReplace("=7C","|",FiltOptString)
  lReplace("=7D","}",FiltOptString)
  lReplace("=7E","~",FiltOptString)
  lReplace("=7F","",FiltOptString)
  lReplace("=A0"," ",FiltOptString)
  lReplace("=A1","≠",FiltOptString)
  lReplace("=A2","õ",FiltOptString)
  lReplace("=A3","ú",FiltOptString)
  lReplace("=A4","o",FiltOptString)
  lReplace("=A5","Y",FiltOptString)
  lReplace("=A6","|",FiltOptString)
  lReplace("=A7","",FiltOptString)
  lReplace("=A8","˙˙",FiltOptString)
  lReplace("=A9","(c)",FiltOptString)
  lReplace("=AA","a",FiltOptString)
  lReplace("=AB","Æ",FiltOptString)
  lReplace("=AC","-",FiltOptString)
  lReplace("=AD","-",FiltOptString)
  lReplace("=AE","(R)",FiltOptString)
  lReplace("=AF","-",FiltOptString)
  lReplace("=B0","¯",FiltOptString)
  lReplace("=B1","Ò",FiltOptString)
  lReplace('=B2','"',FiltOptString)
  lReplace('=B3','"',FiltOptString)
  lReplace("=B4","'",FiltOptString)
  lReplace("=B5","Ê",FiltOptString)
  lReplace("=B6","„",FiltOptString)
  lReplace("=B7","˙",FiltOptString)
  lReplace("=B8",",",FiltOptString)
  lReplace("=B9","1",FiltOptString)
  lReplace("=BA","ß",FiltOptString)
  lReplace("=BB","Ø",FiltOptString)
  lReplace("=BC","¨",FiltOptString)
  lReplace("=BD","´",FiltOptString)
  lReplace("=BE","3/4",FiltOptString)
  lReplace("=BF","®",FiltOptString)
  lReplace("=C0","A",FiltOptString)
  lReplace("=C1","A",FiltOptString)
  lReplace("=C2","A",FiltOptString)
  lReplace("=C3","A",FiltOptString)
  lReplace("=C4","é",FiltOptString)
  lReplace("=C5","è",FiltOptString)
  lReplace("=C6","í",FiltOptString)
  lReplace("=C7","Ä",FiltOptString)
  lReplace("=C8","E",FiltOptString)
  lReplace("=C9","ê",FiltOptString)
  lReplace("=CA","E",FiltOptString)
  lReplace("=CB","E",FiltOptString)
  lReplace("=CC","I",FiltOptString)
  lReplace("=CD","I",FiltOptString)
  lReplace("=CE","I",FiltOptString)
  lReplace("=CF","I",FiltOptString)
  lReplace("=D0","D",FiltOptString)
  lReplace("=D1","•",FiltOptString)
  lReplace("=D2","O",FiltOptString)
  lReplace("=D3","O",FiltOptString)
  lReplace("=D4","O",FiltOptString)
  lReplace("=D5","O",FiltOptString)
  lReplace("=D6","ô",FiltOptString)
  lReplace("=D7","x",FiltOptString)
  lReplace("=D8","O",FiltOptString)
  lReplace("=D9","U",FiltOptString)
  lReplace("=DA","U",FiltOptString)
  lReplace("=DB","U",FiltOptString)
  lReplace("=DC","ö",FiltOptString)
  lReplace("=DD","Y",FiltOptString)
  lReplace("=DE","Ë",FiltOptString)
  lReplace("=DF","·",FiltOptString)
  lReplace("=E0","Ö",FiltOptString)
  lReplace("=E1","†",FiltOptString)
  lReplace("=E2","É",FiltOptString)
  lReplace("=E3","a",FiltOptString)
  lReplace("=E4","Ñ",FiltOptString)
  lReplace("=E5","Ü",FiltOptString)
  lReplace("=E6","ë",FiltOptString)
  lReplace("=E7","á",FiltOptString)
  lReplace("=E8","ä",FiltOptString)
  lReplace("=E9","Ç",FiltOptString)
  lReplace("=EA","à",FiltOptString)
  lReplace("=EB","â",FiltOptString)
  lReplace("=EC","ç",FiltOptString)
  lReplace("=ED","°",FiltOptString)
  lReplace("=EE","å",FiltOptString)
  lReplace("=EF","ã",FiltOptString)
  lReplace("=F0","=F0",FiltOptString)
  lReplace("=F1","§",FiltOptString)
  lReplace("=F2","ï",FiltOptString)
  lReplace("=F3","¢",FiltOptString)
  lReplace("=F4","ì",FiltOptString)
  lReplace("=F5","o",FiltOptString)
  lReplace("=F6","î",FiltOptString)
  lReplace("=F7","ˆ",FiltOptString)
  lReplace("=F8","o",FiltOptString)
  lReplace("=F9","ó",FiltOptString)
  lReplace("=FA","£",FiltOptString)
  lReplace("=FB","ñ",FiltOptString)
  lReplace("=FC","Å",FiltOptString)
  lReplace("=FD","y",FiltOptString)
  lReplace("=FE","Ë",FiltOptString)
  lReplace("=FF","ò",FiltOptString)
  lReplace("=?iso-8859-1?Q?","",FiltOptString+"i")
  lReplace("=?iso-8859-15?Q?","",FiltOptString+"i")
  lReplace("?=","",FiltOptString)
  lReplace("=3D","=",FiltOptString)
end TimoMacMail2Pc

proc timoMacEolnDelOneLine()
  ScrollToCenter()
  EndLine()
  Left()
  if Chr(CurrChar()) == "="
    JoinLine()
    DelChar()
  endif
  BegLine()
  Down()
end timoMacEolnDelOneLine

// Process the file
proc tFilterFile()
  timoLat1MailToIbm('gn')
  TimoMacMail2Pc('gn')
  tDetabMailFile()
end tFilterFile

// Elm-type headers **************************************************

string emailAddress[60] = "ts@uwasa.fi"
integer emailAddress_hist
string emailName[60] = "Timo Salmi"
integer emailName_hist
string subject[60] = "Viesti Timolta"
integer subject_hist

// Give both date and time, date verbally
string proc timoDateTimeFn(integer flag)
  integer mon, day, year, dow,
          hour, minu, sec, sec100
  string  month_name[3] = ''
  string  weekday[3] = ''
  string  timeStr[8] = ''
  string  dayStr[2] = ''
  string  yearStr[4] = ''
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
  if day < 10
    case flag
      when 1
        dayStr = ' ' + Str(day)
      when 2
        dayStr = Str(day)
    endcase
  else
    dayStr = Str(day)
  endif
  yearStr = Str(year)
  case flag
    when 1
      Return(Format(weekday + ' ' + month_name + ' ' + dayStr + ' ' +
                  timeStr + ' ' + yearStr))
    when 2
      Return(Format(weekday + ', ' + dayStr + ' ' + month_name +
                    ' ' + yearStr + ' ' + timeStr))
  endcase
  Return('')
end timoDateTimeFn

proc tInsertHeader()
  string dateTime1[80] = ''
  string dateTime2[80] = ''
  Ask("Your email address: ", emailAddress, emailAddress_hist)
  AddHistoryStr (emailAddress, emailAddress_hist)
  Ask("Your name: ", emailName, emailName_hist)
  AddHistoryStr (emailName, emailName_hist)
  Ask("Subject: ", subject, subject_hist)
  AddHistoryStr (subject, subject_hist)
  dateTime1 = timoDateTimeFn(1)
  dateTime2 = timoDateTimeFn(2)

  AddLine('From ' + emailAddress + ' ' + dateTime1)
  BegLine()
  AddLine('Date: ' + dateTime2)
  BegLine()
  Addline('From: ' + emailAddress + ' (' + emailName +')')
  BegLine()
  Addline('Subject: ' + subject)
  BegLine()
  Addline('To: ')
  BegLine()
  Addline('Status: RO')
  AddLine()
end tInsertHeader

// New keys and menus **************************************************
forward Menu tFilterMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 5>      tFilterFile()
  <CtrlAlt 6>      tInsertHeader()
  <CtrlAlt 7>      timoMacEolnDelOneLine()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tFilterMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The test menu ******************************************************
Menu tFilterMenu()
  Title = "Timo's Unix mail characters -> PC menu"
  Width = 40
  x = 40
  y = 3
  history
  "&Filter Unix mail file <CtrlAlt 5>"   , tFilterFile()
  "&Insert email header   <CtrlAlt 6>"   , tInsertHeader()
  "Del &Mac =Eoln         <CtrlAlt 7>"   , TimoMacEolnDelOneLine()
  "",,Divide
  "Disable &new keys      <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help                  <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu             <F11>"
end tFilterMenu

proc Main()
  emailAddress_hist = GetFreeHistory("WMAI2IBM:tInsertHeaderAddress")
  emailName_hist = GetFreeHistory("WMAI2IBM:tInsertHeaderName")
  subject_hist = GetFreeHistory("WMAI2IBM:tInsertHeaderSubject")
  Enable (new_keys)
  tFilterMenu()
end
