/* Convert box drawing characters to 7-bit ASCII for SemWare's TSE
   editor V4.0. To make this SAL macro operational, invoke the main
   menu (F10), choose "Macro", choose "Compile" and press Enter at
   "Execute Macro".

 ÚÄÄÄÄÄÄÄÄÄ¿    +---------+      ÉÍÍÍÍÍÍÍÍÍ»   +=========+
 ³         ³    :         :      º         º   #         #
 ³         ³    :         :      º         º   #         #
 ÀÄÄÄÄÄÄÄÄÄÙ    +---------+      ÈÍÍÍÍÍÍÍÍÍ¼   +=========+

 ÚÄÂÄÄÂÄÄÄÄ¿    +-,--,----+      ÉÍËÍÍËÍÍÍÍ»   +=,==,====+
 ³ ³  ³    ³    : :  :    :      º º  º    º   # #  #    #
 ÃÄÁÄÄÅÄÄÂÄ´    :-'--|--,-:      ÌÍÊÍÍÎÍÍËÍ¹   #='==#==,=#
 ³    ³  ³ ³    :    :  : :      º    º  º º   #    #  # #
 ÀÄÄÄÄÁÄÄÁÄÙ    +----'--'-+      ÈÍÍÍÍÊÍÍÊÍ¼   +===='=='=+

....................................................................
Prof. Timo Salmi ftp & http://garbo.uwasa.fi/ archives 193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi <http://www.uwasa.fi/~ts/>  ; FIN-65101,  Finland
Timo's  FAQ  materials  at   http://www.uwasa.fi/~ts/http/tsfaq.html
Dense spam-kill procmail filtering with a public email key in effect
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "WBOX2ASC.S HELP"        // The help's caption
  x = 10                           // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's box drawing conversion"
  ""
  " These procedures are for converting the 8-bit box "
  " drawing characters to 7-bit ASCII equivalents."
  ""
  " You can use <F11> to invoke the command menu after "
  " first exiting this help. "
  ""
  " Last updated Mon 3-Jan-2005 09:48:59 "
end  /* tHelpData */

// Convert 8-bit Scandinavian characters to their local 7-bit counterparts
proc timoBoxToAsc(string FiltOptString)
  lReplace("Ú","+",FiltOptString)
  lReplace("¿","+",FiltOptString)
  lReplace("À","+",FiltOptString)
  lReplace("Ù","+",FiltOptString)
  lReplace("Å","|",FiltOptString)
  lReplace("Î","#",FiltOptString)
  lReplace("Â",",",FiltOptString)
  lReplace("Ë",",",FiltOptString)
  lReplace("Á","'",FiltOptString)
  lReplace("Ê","'",FiltOptString)
  lReplace("Ã",":",FiltOptString)
  lReplace("Ì","#",FiltOptString)
  lReplace("´",":",FiltOptString)
  lReplace("¹","#",FiltOptString)
  lReplace("Ä","-",FiltOptString)
  lReplace("³",":",FiltOptString)
  lReplace("º","#",FiltOptString)
  lReplace("Í","=",FiltOptString)
  lReplace("É","+",FiltOptString)
  lReplace("»","+",FiltOptString)
  lReplace("¼","+",FiltOptString)
  lReplace("È","+",FiltOptString)
end timoBoxToAsc

// Convert 8-bit Scandinavian characters to their local 7-bit counterparts
// in block
proc timoBoxToAscInBlk()
  if not isBlockInCurrFile()
    Warn('No block in current window')
  elseif isCursorInBlock() and CurrLine() <= Query(BlockEndLine)
    PushPosition()
    GotoBlockBegin()
    timoBoxToAsc('nl')
    PopPosition()
  else
    Warn('Cursor not in block')
  endif
end timoBoxToAscInBlk

// Convert 8-bit Scandinavian characters to spaces in a block
proc timoBoxToSpace(string FiltOptString)
  lReplace("Ú"," ",FiltOptString)
  lReplace("¿"," ",FiltOptString)
  lReplace("À"," ",FiltOptString)
  lReplace("Ù"," ",FiltOptString)
  lReplace("Å"," ",FiltOptString)
  lReplace("Î"," ",FiltOptString)
  lReplace("Â"," ",FiltOptString)
  lReplace("Ë"," ",FiltOptString)
  lReplace("Á"," ",FiltOptString)
  lReplace("Ê"," ",FiltOptString)
  lReplace("Ã"," ",FiltOptString)
  lReplace("Ì"," ",FiltOptString)
  lReplace("´"," ",FiltOptString)
  lReplace("¹"," ",FiltOptString)
  lReplace("Ä"," ",FiltOptString)
  lReplace("³"," ",FiltOptString)
  lReplace("º"," ",FiltOptString)
  lReplace("Í"," ",FiltOptString)
  lReplace("É"," ",FiltOptString)
  lReplace("»"," ",FiltOptString)
  lReplace("¼"," ",FiltOptString)
  lReplace("È"," ",FiltOptString)
end timoBoxToSpace

// Convert 8-bit Scandinavian characters to spaces in a block
// in block
proc timoBoxToSpaceInBlk()
  if not isBlockInCurrFile()
    Warn('No block in current window')
  elseif isCursorInBlock() and CurrLine() <= Query(BlockEndLine)
    PushPosition()
    GotoBlockBegin()
    timoBoxToSpace('nl')
    PopPosition()
  else
    Warn('Cursor not in block')
  endif
end timoBoxToSpaceInBlk

// New keys and menus **************************************************
forward Menu tBoxToAscMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 4>      timoBoxToAsc('gn')
  <CtrlAlt 5>      timoBoxToAscInBlk()
  <CtrlAlt 6>      timoBoxToSpace('gn')
  <CtrlAlt 7>      timoBoxToSpaceInBlk()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tBoxToAscMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The IbmAsc menu ****************************************************
Menu tBoxToAscMenu()
  Title = "Timo's conversion menu"
  x = 40
  y = 3
  history
  "Box to 7-bit &ASCII     <CtrlAlt 4>"   , timoBoxToAsc('gn')
  "Box to ASCII in &block  <CtrlAlt 5>"   , timoBoxToAscInBlk()
  "",,Divide
  "Box to spaces in &file  <CtrlAlt 6>"   , timoBoxToSpace('gn')
  "Box to &spaces in block <CtrlAlt 7>"   , timoBoxToSpaceInBlk()
  "",,Divide
  "Disable &new keys      <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help                  <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu             <F11>"
end tBoxToAscMenu

proc Main()
  Enable (new_keys)
  tBoxToAscMenu()
end
