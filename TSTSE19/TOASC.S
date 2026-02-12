/* Scandinavian conversions for SemWare's TSE editor V2.5. To make
   this SAL macro operational, invoke the main menu (F10), choose
   "Macro", choose "Compile" and press Enter at "Execute Macro".

....................................................................
Prof. Timo Salmi   Co-moderator of news:comp.archives.msdos.announce
Moderating at ftp:// & http://garbo.uwasa.fi archives  193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi  <URL:http://uwasa.fi/~ts>  ; FIN-65101,  Finland
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "TOASC.S HELP"           // The help's caption
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
  " Last updated Sat 30-November-1996 08:01:07 "
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
  lReplace("‰","Ñ",FiltOptString)
  lReplace("Â","Ü",FiltOptString)
  lReplace("ˆ","î",FiltOptString)
  lReplace("ƒ","é",FiltOptString)
  lReplace("≈","è",FiltOptString)
  lReplace("÷","ô",FiltOptString)
  lReplace("¸","Å",FiltOptString)
  lReplace("‹","ö",FiltOptString)
  lReplace("ß","",FiltOptString)
  lReplace("Û","Ç",FiltOptString)
  lReplace("È","¢",FiltOptString)
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
  lReplace("Ñ","‰",FiltOptString)
  lReplace("Ü","Â",FiltOptString)
  lReplace("î","ˆ",FiltOptString)
  lReplace("é","ƒ",FiltOptString)
  lReplace("è","≈",FiltOptString)
  lReplace("ô","÷",FiltOptString)
  lReplace("Å","¸",FiltOptString)
  lReplace("ö","‹",FiltOptString)
  lReplace("","ß",FiltOptString)
  lReplace("Ç","Û",FiltOptString)
  lReplace("¢","È",FiltOptString)
end timoIbmToLat1

menu timoIbmToLat1FilterMenu()
  Title = 'IBM to Latin1'
  history
  "&Entire file", TimoIbmToLat1('gn')
  "&Block"      , TimoIbmToLat1('gln')
  "&Cancel"
end timoIbmToLat1FilterMenu

// Covert Low "Mac" Scandinavian characters to their 8-bit IBM PC equivalents
proc timoMacPc(string FiltOptString)
  if FiltOptString == 'gln'
    if not isBlockInCurrFile()
      Warn('No block in the current window')
    endif
  endif
  lReplace("=E5","Ü",FiltOptString)
  lReplace("=E4","Ñ",FiltOptString)
  lReplace("=F6","î",FiltOptString)
  lReplace("=C5","è",FiltOptString)
  lReplace("=C4","é",FiltOptString)
  lReplace("=D6","ô",FiltOptString)
  lReplace("=7F","",FiltOptString)
  lReplace("=09","	",FiltOptString)
  lReplace("=A7","",FiltOptString)
  lReplace("=3D","=",FiltOptString)
  lReplace('=B2','"',FiltOptString)
  lReplace('=B3','"',FiltOptString)
  lReplace("=3F","?",FiltOptString)
  lReplace("=20"," ",FiltOptString)
  lReplace("=?iso-8859-1?Q?","",FiltOptString)
  lReplace("?=","",FiltOptString)
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
