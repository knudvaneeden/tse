/* SemWare's TSE editor V2.5 macros to insert escape codes into
   ascii text for a Diconix InkJet Printer Model 150. Alternatively,
   set printer directly instead of inserting. To make this SAL macro
   operational, invoke the main menu (F10), choose "Macro", choose
   "Compile" and press Enter at "Execute Macro".

....................................................................
Prof. Timo Salmi   Co-moderator of news:comp.archives.msdos.announce
Moderating at ftp:// & http://garbo.uwasa.fi archives  193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi  <URL:http://uwasa.fi/~ts>  ; FIN-65101,  Finland
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "DICONIX.S HELP"        // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's Diconix Printer Escape Codes "
  ""
  " Sends or Inserts escape codes into ascii text "
  " for a Diconix InkJet Printer Model 150 "
  ""
  " You can use <F11> and <Alt F11> to invoke the "
  " command menus after first exiting this help. "
  ""
  " Last updated Thu 26-December-1996 09:10:43 "
end tHelpData

// Send the given escape sequence to the Diconix printer
proc SendEscSequence (string s)
  integer i
  for i = 1 to Length(s)
    if not PrintChar(s[i])
      break
    endif
  endfor
end SendEscSequence

// Send the reset sequence to the Diconix printer
proc tSendReset()
  SendEscSequence ("@")
end

// Insert the reset sequence for the Diconix printer into the text
proc tReset()
  InsertText ("@",_INSERT_)
end

proc tSendUnderlineOn()
  SendEscSequence ("-1")
end

proc tUnderlineOn()
  InsertText ("-1",_INSERT_)
end

proc tSendUnderlineOff()
  SendEscSequence ("-0")
end

proc tUnderlineOff()
  InsertText ("-0",_INSERT_)
end

proc tSendOverscoreOn()
  SendEscSequence ("_1")
end

proc tOverscoreOn()
  InsertText ("_1",_INSERT_)
end

proc tSendOverscoreOff()
  SendEscSequence ("_0")
end

proc tOverscoreOff()
  InsertText ("_0",_INSERT_)
end

proc tSendSuperScriptOn()
  SendEscSequence ("S0")
end

proc tSuperScriptOn()
  InsertText ("S0",_INSERT_)
end

proc tSendSubScriptOn()
  SendEscSequence ("S1")
end

proc tSubScriptOn()
  InsertText ("S1",_INSERT_)
end

proc tSendSuperScriptOff()
  SendEscSequence ("T")
end

proc tSuperScriptOff()
  InsertText ("T",_INSERT_)
end

proc tSendDoubleStrikeOn()
  SendEscSequence ("G")
end

proc tDoubleStrikeOn()
  InsertText ("G",_INSERT_)
end

proc tSendDoubleStrikeOff()
  SendEscSequence ("H")
end

proc tDoubleStrikeOff()
  InsertText ("H",_INSERT_)
end

proc tSendEmphasizedOn()
  SendEscSequence ("E")
end

proc tEmphasizedOn()
  InsertText ("E",_INSERT_)
end

proc tSendEmphasizedOff()
  SendEscSequence ("F")
end

proc tEmphasizedOff()
  InsertText ("F",_INSERT_)
end

proc tSendEliteNormal()
  SendEscSequence ("!")
end

proc tEliteNormal()
  InsertText ("!",_INSERT_)
end

proc tSendEliteCondensed()
  SendEscSequence ("!")
end

proc tEliteCondensed()
  InsertText ("!",_INSERT_)
end

proc tSendEliteCondensedEmphasized()
  if CurrPos() <> 1
    Warn("Can only be at the beginning of the line")
  else
    SendEscSequence ("!")
  endif
end

proc tEliteCondensedEmphasized()
  if CurrPos() <> 1
    Warn("Can only be at the beginning of the line")
  else
    InsertText ("!",_INSERT_)
  endif
end

proc tSendWide()
  SendEscSequence ("!$")
end

proc tWide()
  InsertText ("!$",_INSERT_)
end

proc tSendWideEmphasized()
  SendEscSequence ("!,")
end

proc tWideEmphasized()
  InsertText ("!,",_INSERT_)
end

proc tSendEnlargedOn()
  SendEscSequence ("W1")
end

proc tEnlargedOn()
  InsertText ("W1",_INSERT_)
end

proc tSendEnlargedOff()
  SendEscSequence ("W0")
end

proc tEnlargedOff()
  InsertText ("W0",_INSERT_)
end

// Cancel escape sequences all through the file
proc tCancelAll()
  lReplace("@","","gn")
  lReplace("-1","","gn")
  lReplace("-0","","gn")
  lReplace("_1","","gn")
  lReplace("_0","","gn")
  lReplace("E","","gn")
  lReplace("F","","gn")
  lReplace("S0","","gn")
  lReplace("S1","","gn")
  lReplace("T","","gn")
  lReplace("G","","gn")
  lReplace("H","","gn")
  lReplace("!","","gn")
  lReplace("!","","gn")
  lReplace("!","","gn")
  lReplace("!$","","gn")
  lReplace("!,","","gn")
  lReplace("W1","","gn")
  lReplace("W0","","gn")
end tCancelAll

// Cancel escape sequences on the current line
proc tCancelLine()
  PushPosition()
  BegLine()
  lReplace("@","","cn")
  lReplace("-1","","cn")
  lReplace("-0","","cn")
  lReplace("_1","","cn")
  lReplace("_0","","cn")
  lReplace("E","","cn")
  lReplace("F","","cn")
  lReplace("S0","","cn")
  lReplace("S1","","cn")
  lReplace("T","","cn")
  lReplace("G","","cn")
  lReplace("H","","cn")
  lReplace("!","","cn")
  lReplace("!","","cn")
  lReplace("!","","cn")
  lReplace("!$","","cn")
  lReplace("!,","","cn")
  lReplace("W1","","cn")
  lReplace("W0","","cn")
  PopPosition()
  Down()
end tCancelLine

// New keys and menus **************************************************
forward proc tDisableNewKeys()
forward menu tSendMenu()
forward menu tInsertMenu()
forward menu tCancelMenu()
forward menu tFontMenu()

// Add the new key definitions
keydef new_keys
  <CtrlAlt C>      tCancelMenu()
  <CtrlAlt F>      tFontMenu()
  <CtrlAlt L>      tCancelLine()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tSendMenu()
  <Alt F11>        tInsertMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

//  ***********************************************
Menu tSendFontMenu()
  Title = "Fonts"
  Width = 19
  x = 38
  y = 14
  history
  "Elite &Normal"                  , tSendEliteNormal()
  "Elite &Condensed"               , tSendEliteCondensed()
  "Elite Condensed &Emphasized"    , tSendEliteCondensedEmphasized()
  "&Wide"                          , tSendWide()
  "W&ide Emphasized"               , tSendWideEmphasized()
  "Enlarged &On"                   , tSendEnlargedOn()
  "Enlarged O&ff"                  , tSendEnlargedOff()
end tSendFontMenu

//  ***********************************************
Menu tFontMenu()
  Title = "Fonts"
  Width = 19
  x = 40
  y = 14
  history
  "Elite &Normal"                  , tEliteNormal()
  "Elite &Condensed"               , tEliteCondensed()
  "Elite Condensed &Emphasized"    , tEliteCondensedEmphasized()
  "&Wide"                          , tWide()
  "W&ide Emphasized"               , tWideEmphasized()
  "Enlarged &On"                   , tEnlargedOn()
  "Enlarged O&ff"                  , tEnlargedOff()
end tFontMenu

//  ***********************************************
Menu tCancelMenu()
  Title = "Cancel sequences"
  Width = 19
  x = 40
  y = 17
  history
  "&Cancel all through the file"        , tCancelAll()
  "Cancel on current &line <CtrlAlt L>" , tCancelLine()
end tCancelMenu

//  ***********************************************
Menu tSendMenu()
  Title = "Send Escape Sequences"
  Width = 19
  x = 3
  y = 2
  history
  "Reset"                            , tSendReset()
  "Underline on"                     , tSendUnderlineOn()
  "Underline off"                    , tSendUnderlineOff()
  "Overscore on"                     , tSendOverscoreOn()
  "Overscore off"                    , tSendOverscoreOff()
  "Double-Strike Mode on"            , tSendDoubleStrikeOn()
  "Double-Strike Mode off"           , tSendDoubleStrikeOff()
  "Emphasized Mode on"               , tSendEmphasizedOn()
  "Emphasized Mode off"              , tSendEmphasizedOff()
  "Superscript Mode On"              , tSendSuperScriptOn()
  "Subscript Mode On"                , tSendSubScriptOn()
  "Super/Subscript Mode Off"         , tSendSuperScriptOff()
  "&Fonts <CtrlAltF> "              , tSendFontMenu(),    DontClose
  "",,Divide
  "&Insert Escape Sequences "       , tInsertMenu(),      DontClose
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <F11>"          , tSendMenu()
end tSendMenu

//  ***********************************************
Menu tInsertMenu()
  Title = "Insert Escape Sequences"
  Width = 19
  x = 5
  y = 3
  history
  "Reset"                            , tReset()
  "Underline on"                     , tUnderlineOn()
  "Underline off"                    , tUnderlineOff()
  "Overscore on"                     , tOverscoreOn()
  "Overscore off"                    , tOverscoreOff()
  "Double-Strike Mode on"            , tDoubleStrikeOn()
  "Double-Strike Mode off"           , tDoubleStrikeOff()
  "Emphasized Mode on"               , tEmphasizedOn()
  "Emphasized Mode off"              , tEmphasizedOff()
  "Superscript Mode On"              , tSuperScriptOn()
  "Subscript Mode On"                , tSubScriptOn()
  "Super/Subscript Mode Off"         , tSuperScriptOff()
  "&Fonts <CtrlAltF> "              , tFontMenu(),        DontClose
  "",,Divide
  "&Cancel esc seq <CtrlAltC> "     , tCancelMenu(),      DontClose
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <Alt F11>"      , tInsertMenu()
end tInsertMenu

proc Main()
  Enable (new_keys)
  tSendMenu()
end
