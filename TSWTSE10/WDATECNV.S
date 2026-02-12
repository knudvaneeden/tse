/* Convert 10-24-04 dates to Oct-24-2004 dates for SemWare's TSE
   editor V4.0. To make this SAL macro operational, invoke the main
   menu (F10), choose "Macro", choose "Compile" and press Enter at
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
  title = "WDATECNV.S HELP"        // The help's caption
  x = 3                            // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's date format conversion"
  ""
  " Converts 10-24-04 dates to Oct-24-2004 dates "
  ""
  " You can use <F11> to invoke the command menu after "
  " first exiting this help. "
  ""
  " Last modified Tue 4-January-2005 23:19:58 "
end tHelpData

proc timoConvertDate(string FiltOptString)
  if FiltOptString == 'gln'
    if not isBlockInCurrFile()
      Warn('No block in the current window')
    endif
  endif
  lReplace(" 01-"," Jan-",FiltOptString)
  lReplace(" 02-"," Feb-",FiltOptString)
  lReplace(" 03-"," Mar-",FiltOptString)
  lReplace(" 04-"," Apr-",FiltOptString)
  lReplace(" 05-"," May-",FiltOptString)
  lReplace(" 06-"," Jun-",FiltOptString)
  lReplace(" 07-"," Jul-",FiltOptString)
  lReplace(" 08-"," Aug-",FiltOptString)
  lReplace(" 09-"," Sep-",FiltOptString)
  lReplace(" 10-"," Oct-",FiltOptString)
  lReplace(" 11-"," Nov-",FiltOptString)
  lReplace(" 12-"," Dec-",FiltOptString)
//
  lReplace("-80 ","-1980 ",FiltOptString)
  lReplace("-81 ","-1981 ",FiltOptString)
  lReplace("-82 ","-1982 ",FiltOptString)
  lReplace("-83 ","-1983 ",FiltOptString)
  lReplace("-84 ","-1984 ",FiltOptString)
  lReplace("-85 ","-1985 ",FiltOptString)
  lReplace("-86 ","-1986 ",FiltOptString)
  lReplace("-87 ","-1987 ",FiltOptString)
  lReplace("-88 ","-1988 ",FiltOptString)
  lReplace("-89 ","-1989 ",FiltOptString)
  lReplace("-90 ","-1990 ",FiltOptString)
  lReplace("-91 ","-1991 ",FiltOptString)
  lReplace("-92 ","-1992 ",FiltOptString)
  lReplace("-93 ","-1993 ",FiltOptString)
  lReplace("-94 ","-1994 ",FiltOptString)
  lReplace("-95 ","-1995 ",FiltOptString)
  lReplace("-96 ","-1996 ",FiltOptString)
  lReplace("-97 ","-1997 ",FiltOptString)
  lReplace("-98 ","-1998 ",FiltOptString)
  lReplace("-99 ","-1999 ",FiltOptString)
  lReplace("-00 ","-2000 ",FiltOptString)
  lReplace("-01 ","-2001 ",FiltOptString)
  lReplace("-02 ","-2002 ",FiltOptString)
  lReplace("-03 ","-2003 ",FiltOptString)
  lReplace("-04 ","-2004 ",FiltOptString)
  lReplace("-05 ","-2005 ",FiltOptString)
  lReplace("-06 ","-2006 ",FiltOptString)
  lReplace("-07 ","-2007 ",FiltOptString)
  lReplace("-08 ","-2008 ",FiltOptString)
  lReplace("-09 ","-2009 ",FiltOptString)
  lReplace("-10 ","-2010 ",FiltOptString)
  lReplace("-11 ","-2011 ",FiltOptString)
  lReplace("-12 ","-2012 ",FiltOptString)
  lReplace("-13 ","-2013 ",FiltOptString)
  lReplace("-14 ","-2014 ",FiltOptString)
  lReplace("-15 ","-2015 ",FiltOptString)
  lReplace("-16 ","-2016 ",FiltOptString)
  lReplace("-17 ","-2017 ",FiltOptString)
  lReplace("-18 ","-2018 ",FiltOptString)
  lReplace("-19 ","-2019 ",FiltOptString)
  lReplace("-20 ","-2020 ",FiltOptString)
  lReplace("-21 ","-2021 ",FiltOptString)
  lReplace("-22 ","-2022 ",FiltOptString)
  lReplace("-23 ","-2023 ",FiltOptString)
  lReplace("-24 ","-2024 ",FiltOptString)
  lReplace("-25 ","-2025 ",FiltOptString)
  lReplace("-26 ","-2026 ",FiltOptString)
  lReplace("-27 ","-2027 ",FiltOptString)
  lReplace("-28 ","-2028 ",FiltOptString)
  lReplace("-29 ","-2029 ",FiltOptString)
end timoConvertDate

// New keys and menus **************************************************
forward Menu timoCovertDateMenu()
forward Menu timoConvertDateChoicesMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 5>      timoConvertDateChoicesMenu()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            timoCovertDateMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

menu timoConvertDateChoicesMenu()
  Title = 'Date Format Covert'
  history
  "&Block"      , timoConvertDate('gln')
  "&Entire file", timoConvertDate('gn')
  "&Cancel"
end timoConvertDateChoicesMenu

// The test menu ****************************************************
Menu timoCovertDateMenu()
  Title = "Timo's Date Conversion Menu"
  x = 40
  y = 3
  history
  "Convert Datestamps  <CtrlAlt 5>"    , timoConvertDateChoicesMenu()
  "",,Divide
  "Disable &new keys     <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help                 <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu            <F11>"          ,timoCovertDateMenu()
end timoCovertDateMenu

proc Main()
  Enable (new_keys)
  timoCovertDateMenu()
end
