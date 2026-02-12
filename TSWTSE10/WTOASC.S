/* Scandinavian conversions for SemWare's TSE editor V4.0. To make
   this SAL macro operational, invoke the main menu (F10), choose
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
  title = "WTOASC.S HELP"          // The help's caption
  x = 3                            // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's Scandinavian conversions"
  ""
  " These procedures are for converting the Scandinavian "
  " characters between different conventions."
  ""
  " IBM <--> ASCII  ÜÑîèéô      IBM <--> Latin1 ÑÜîéèôÅöÇ¢"
  "                 }{|][\                      ‰Âˆƒ≈÷¸‹ßÛÈ"
  ""
  " MAC(2) --> IBM  åäöÅÄÖ‘’"
  "                 ÜÑîèéô''"
  ""
  ' MAC(4) --> IBM  =E5 =E4 =F6 =C5 =C4 =D6 =7F =09 =A7 =3D =B2 =B3 =3F =20 '
  '                   Ü   Ñ   î   è   é   ô   " tab      =   "   "   ?  nl '
  ""
  " You can use <F11> to invoke the command menu after "
  " first exiting this help. "
  ""
  " Last updated Sun 9-January-2005 09:41:47 "
end  /* tHelpData */

// Convert 8-bit Scandinavian characters to their local 7-bit counterparts
proc timoIbmToAsc(string FiltOptString)
  if FiltOptString == 'gln'
    if not isBlockInCurrFile()
      Warn('No block in the current window')
    endif
  endif
  lReplace("Ü","}",FiltOptString)
  lReplace("Ñ","{",FiltOptString)
  lReplace("î","|",FiltOptString)
  lReplace("è","]",FiltOptString)
  lReplace("é","[",FiltOptString)
  lReplace("ô","\",FiltOptString)
end timoIbmToAsc

menu timoIbmToAscFilterMenu()
  Title = '8-bit Scandinavian IBM to 7-bit ASCII'
  history
  "&Entire file", TimoIbmToAsc('gn')
  "&Block"      , TimoIbmToAsc('gln')
  "&Cancel"
end timoIbmToAscFilterMenu

// Convert local 7-bit Scandinavian characters to their 8-bit IBM
// PC counterparts
proc timoAscToIbm(string FiltOptString)
  if FiltOptString == 'gln'
    if not isBlockInCurrFile()
      Warn('No block in the current window')
    endif
  endif
  lReplace("}","Ü",FiltOptString)
  lReplace("{","Ñ",FiltOptString)
  lReplace("|","î",FiltOptString)
  lReplace("]","è",FiltOptString)
  lReplace("[","é",FiltOptString)
  lReplace("\","ô",FiltOptString)
end timoAscToIbm

menu timoAscToIbmFilterMenu()
  Title = '7-bit Scandinavian ASCII to 8-bit IBM'
  history
  "&Entire file", TimoAscToIbm('gn')
  "&Block"      , TimoAscToIbm('gln')
  "&Cancel"
end timoAscToIbmFilterMenu

// Convert 8-bit Latin1 Scandinavian characters to their 8-bit IBM
// PC counterparts
proc timoLat1ToIbm(string FiltOptString)
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
end timoLat1ToIbm

menu timoLat1ToIbmFilterMenu()
  Title = 'Latin1 to IBM'
  history
  "&Entire file", TimoLat1ToIbm('gn')
  "&Block"      , TimoLat1ToIbm('gln')
  "&Cancel"
end timoLat1ToIbmFilterMenu

// Convert 8-bit IBM PC Scandinavian characters to their 8-bit
// Latin1 counterparts
proc timoIbmToLat1(string FiltOptString)
  if FiltOptString == 'gln'
    if not isBlockInCurrFile()
      Warn('No block in the current window')
    endif
  endif
  lReplace("Ö","‡",FiltOptString)
  lReplace("†","·",FiltOptString)
  lReplace("É","‚",FiltOptString)
  lReplace("Ñ","‰",FiltOptString)
  lReplace("Ü","Â",FiltOptString)
  lReplace("ë","Ê",FiltOptString)
  lReplace("á","Á",FiltOptString)
  lReplace("ä","Ë",FiltOptString)
  lReplace("Ç","È",FiltOptString)
  lReplace("à","Í",FiltOptString)
  lReplace("â","Î",FiltOptString)
  lReplace("ç","Ï",FiltOptString)
  lReplace("°","Ì",FiltOptString)
  lReplace("å","Ó",FiltOptString)
  lReplace("ã","Ô",FiltOptString)
  lReplace("§","Ò",FiltOptString)
  lReplace("ï","Ú",FiltOptString)
  lReplace("¢","Û",FiltOptString)
  lReplace("ì","Ù",FiltOptString)
  lReplace("î","ˆ",FiltOptString)
  lReplace("ó","˘",FiltOptString)
  lReplace("£","˙",FiltOptString)
  lReplace("ñ","˚",FiltOptString)
  lReplace("Å","¸",FiltOptString)
  lReplace("é","ƒ",FiltOptString)
  lReplace("è","≈",FiltOptString)
  lReplace("í","∆",FiltOptString)
  lReplace("Ä","«",FiltOptString)
  lReplace("ê","…",FiltOptString)
  lReplace("•","—",FiltOptString)
  lReplace("ô","÷",FiltOptString)
  lReplace("ö","‹",FiltOptString)
  lReplace("","ß",FiltOptString)
end timoIbmToLat1

menu timoIbmToLat1FilterMenu()
  Title = 'IBM to Latin1'
  history
  "&Entire file", TimoIbmToLat1('gn')
  "&Block"      , TimoIbmToLat1('gln')
  "&Cancel"
end timoIbmToLat1FilterMenu

// Covert "Mac" Scandinavian characters to their 8-bit IBM PC equivalents
proc timoMacPc(string FiltOptString)
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
  lReplace("?=","",FiltOptString)
  lReplace("=3D","=",FiltOptString)
end timoMacPc

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

menu timoMacPcFilterMenu()
  Title = 'MAC "E4" to IBM'
  history
  "&Entire file"   , TimoMacPc('gn')
  "&Block"         , TimoMacPc('gln')
  "Del &Mac =Eoln ", TimoMacEolnDelOneLine()
  "&Cancel"
end timoMacPcFilterMenu

// Covert Mac Scandinavian characters to their 8-bit IBM PC equivalents
proc timoMac2Pc(string FiltOptString)
  if FiltOptString == 'gln'
    if not isBlockInCurrFile()
      Warn('No block in the current window')
    endif
  endif
  lReplace("å","Ü",FiltOptString)
  lReplace("ä","Ñ",FiltOptString)
  lReplace("ö","î",FiltOptString)
  lReplace("Å","è",FiltOptString)
  lReplace("Ä","é",FiltOptString)
  lReplace("Ö","ô",FiltOptString)
  lReplace("‘","'",FiltOptString)
  lReplace("’","'",FiltOptString)
  lReplace('“','"',FiltOptString)
  lReplace('”','"',FiltOptString)
end timoMac2Pc

menu timoMac2PcFilterMenu()
  Title = 'MAC to IBM'
  history
  "&Entire file", TimoMac2Pc('gn')
  "&Block"      , TimoMac2Pc('gln')
  "&Cancel"
end timoMac2PcFilterMenu

// Convert 8-bit Scandinavian characters to their html codes
proc timoIbmToHtml(string FiltOptString)
  if FiltOptString == 'gln'
    if not isBlockInCurrFile()
      Warn('No block in the current window')
    endif
  endif
  lReplace("Ü","&aring;",FiltOptString)
  lReplace("Ñ","&auml;", FiltOptString)
  lReplace("î","&ouml;", FiltOptString)
  lReplace("è","&Aring;",FiltOptString)
  lReplace("é","&Auml;", FiltOptString)
  lReplace("ô","&Ouml;", FiltOptString)
  lReplace("Ä","&Ccedil;", FiltOptString)
  lReplace("Å","&uuml;", FiltOptString)
  lReplace("Ç","&eacute;", FiltOptString)
  lReplace("É","&acirc;", FiltOptString)
  lReplace("Ö","&agrave;", FiltOptString)
  lReplace("á","&ccedil;", FiltOptString)
  lReplace("à","&ecirc;", FiltOptString)
  lReplace("â","&euml;", FiltOptString)
  lReplace("ã","&iuml;", FiltOptString)
  lReplace("å","&icirc;", FiltOptString)
  lReplace("ç","&igrave;", FiltOptString)
  lReplace("ê","&Eacute;", FiltOptString)
  lReplace("ë","&aelig;", FiltOptString)
  lReplace("í","&AElig;", FiltOptString)
  lReplace("ì","&ocirc;", FiltOptString)
  lReplace("ï","&ograve;", FiltOptString)
  lReplace("ñ","&ucirc;", FiltOptString)
  lReplace("ó","&ugrave;", FiltOptString)
  lReplace("ò","&yuml;", FiltOptString)
  lReplace("ö","&Uuml;", FiltOptString)
  lReplace("†","&aacute;", FiltOptString)
  lReplace("°","&iacute;", FiltOptString)
  lReplace("¢","&oacute;", FiltOptString)
  lReplace("£","&uacute;", FiltOptString)
  lReplace("§","&ntilde;", FiltOptString)
  lReplace("•","&Ntilde;", FiltOptString)
  lReplace("·","&szlig;", FiltOptString)
  lReplace("","&sect;", FiltOptString)
end timoIbmToHtml

menu timoIbmToHtmlFilterMenu()
  Title = 'IBM to HTML'
  history
  "&Entire file", timoIbmToHtml('gn')
  "&Block"      , timoIbmToHtml('gln')
  "&Cancel"
end timoIbmToHtmlFilterMenu

// Convert html codes to their 8-bit Scandinavian counterparts
proc timoHtmlToIbm(string FiltOptString)
  if FiltOptString == 'gln'
    if not isBlockInCurrFile()
      Warn('No block in the current window')
    endif
  endif
  lReplace("&aring;","Ü",FiltOptString)
  lReplace("&auml;" ,"Ñ",FiltOptString)
  lReplace("&ouml;" ,"î",FiltOptString)
  lReplace("&Aring;","è",FiltOptString)
  lReplace("&Auml;" ,"é",FiltOptString)
  lReplace("&Ouml;" ,"ô",FiltOptString)
  lReplace("&Ccedil;","Ä", FiltOptString)
  lReplace("&uuml;","Å", FiltOptString)
  lReplace("&eacute;","Ç", FiltOptString)
  lReplace("&acirc;","É", FiltOptString)
  lReplace("&agrave;","Ö", FiltOptString)
  lReplace("&ccedil;","á", FiltOptString)
  lReplace("&ecirc;","à", FiltOptString)
  lReplace("&euml;","â", FiltOptString)
  lReplace("&iuml;","ã", FiltOptString)
  lReplace("&icirc;","å", FiltOptString)
  lReplace("&igrave;","ç", FiltOptString)
  lReplace("&Eacute;","ê", FiltOptString)
  lReplace("&aelig;","ë", FiltOptString)
  lReplace("&AElig;","í", FiltOptString)
  lReplace("&ocirc;","ì", FiltOptString)
  lReplace("&ograve;","ï", FiltOptString)
  lReplace("&ucirc;","ñ", FiltOptString)
  lReplace("&ugrave;","ó", FiltOptString)
  lReplace("&yuml;","ò", FiltOptString)
  lReplace("&Uuml;","ö", FiltOptString)
  lReplace("&aacute;","†", FiltOptString)
  lReplace("&iacute;","°", FiltOptString)
  lReplace("&oacute;","¢", FiltOptString)
  lReplace("&uacute;","£", FiltOptString)
  lReplace("&ntilde;","§", FiltOptString)
  lReplace("&Ntilde;","•", FiltOptString)
  lReplace("&szlig;","·", FiltOptString)
  lReplace("&lt;","<", FiltOptString)
  lReplace("&gt;",">", FiltOptString)
  lReplace("&amp;","&", FiltOptString)
  lReplace('&quot;','"', FiltOptString)
  lReplace('&sect;',"", FiltOptString)
end timoHtmlToIbm

menu timoHtmlToIbmFilterMenu()
  Title = 'HTML to IBM'
  history
  "&Entire file", timoHtmlToIbm('gn')
  "&Block"      , timoHtmlToIbm('gln')
  "&Cancel"
end timoHtmlToIbmFilterMenu

// New keys and menus **************************************************
forward Menu tIbmAscMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 1>      timoIbmToAscFilterMenu()
  <CtrlAlt 2>      timoAscToIbmFilterMenu()
  <CtrlAlt 3>      timoLat1ToIbmFilterMenu()
  <CtrlAlt 4>      timoIbmToLat1FilterMenu()
  <CtrlAlt 5>      timoMacPcFilterMenu()
  <CtrlAlt 6>      timoMac2PcFilterMenu()
  <CtrlAlt 7>      timoIbmToHtmlFilterMenu()
  <CtrlAlt 8>      timoHtmlToIbmFilterMenu()
  <CtrlAlt 9>      timoMacEolnDelOneLine()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tIbmAscMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The IbmAsc menu ****************************************************
Menu tIbmAscMenu()
  Title = "Timo's conversion menu"
  x = 40
  y = 3
  history
  "Ibm&Asc  (7-bit)   <CtrlAlt 1>"   , timoIbmToAscFilterMenu()
  "Asc&Ibm  (8-bit)   <CtrlAlt 2>"   , timoAscToIbmFilterMenu()
  "&Lat1Ibm (8-bit)   <CtrlAlt 3>"   , timoLat1ToIbmFilterMenu()
  "IbmLat&1 (8-bit)   <CtrlAlt 4>"   , timoIbmToLat1FilterMenu()
  "MacE&4PC (7-bit)   <CtrlAlt 5>"   , timoMacPcFilterMenu()
  "Mac2P&C  (8-bit)   <CtrlAlt 6>"   , timoMac2PcFilterMenu()
  "IbmH&tml (7-bit)   <CtrlAlt 7>"   , timoIbmToHtmlFilterMenu()
  "Ht&mlIbm (8-bit)   <CtrlAlt 8>"   , timoHtmlToIbmFilterMenu()
  "&Del Mac =Eoln      <CtrlAlt 9>"   , timoMacEolnDelOneLine()
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <F11>"
end tIbmAscMenu

proc Main()
  Enable (new_keys)
  tIbmAscMenu()
end
