/* SemWare's TSE editor V2.5 macros to insert escape codes into
   ascii text for a Hewlett Packard DeskJet 500 Printer.
   Alternatively, set printer directly instead of inserting. To make
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
  title = "HP500.S HELP"          // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's HP500 Printer Escape Codes "
  ""
  " Sends or Inserts escape codes into ascii text "
  " for a Hewlett Packard DeskJet 500 Printer "
  ""
  " You can use <F11> and <Alt F11> to invoke the "
  " command menus after first exiting this help. "
  ""
  " Last updated Thu 26-December-1996 08:23:51 "
end tHelpData

// Globals and initializations
string nLeftMargin[22] = "7"
integer nLeftMargin_hist

// Send the given escape sequence to the HP 500 printer
proc SendEscSequence (string s)
  integer i
  for i = 1 to Length(s)
    if not PrintChar(s[i])
      break
    endif
  endfor
end SendEscSequence

// Send the reset sequence to the HP 500 printer
proc tSendReset()
  SendEscSequence ("E")
end

// Insert the reset sequence for the HP 500 printer into the text
proc tReset()
  InsertText ("E",_INSERT_)
end

proc tSendUnderlineOn()
  SendEscSequence ("&d1D")
end

proc tUnderlineOn()
  InsertText ("&d1D",_INSERT_)
end

proc tSendUnderline2On()
  SendEscSequence ("&d2D")
end

proc tUnderline2On()
  InsertText ("&d2D",_INSERT_)
end

proc tSendUnderlineOff()
  SendEscSequence ("&d@")
end

proc tUnderlineOff()
  InsertText ("&d@",_INSERT_)
end

proc tSendDraftQuality()
  SendEscSequence ("(s1Q")
end

proc tDraftQuality()
  InsertText ("(s1Q",_INSERT_)
end

proc tSendLetterQuality()
  SendEscSequence ("(s2Q")
end

proc tLetterQuality()
  InsertText ("(s2Q",_INSERT_)
end

proc tSendCourierNormalLight()
  SendEscSequence ("(s10h12v0s0b3T")
end

proc tCourierNormalLight()
  InsertText ("(s10h12v0s0b3T",_INSERT_)
end

proc tSendCourierNormalItalicLight()
  SendEscSequence ("(s10h12v1s0b3T")
end

proc tCourierNormalItalicLight()
  InsertText ("(s10h12v1s0b3T",_INSERT_)
end

proc tSendCourierNormalBold()
  SendEscSequence ("(s10h12v0s3b3T")
end

proc tCourierNormalBold()
  InsertText ("(s10h12v0s3b3T",_INSERT_)
end

proc tSendCourierNormalItalicBold()
  SendEscSequence ("(s10h12v1s3b3T")
end

proc tCourierNormalItalicBold()
  InsertText ("(s10h12v1s3b3T",_INSERT_)
end

proc tSendCourierLargeLight()
  SendEscSequence ("(s5h12v0s0b3T")
end

proc tCourierLargeLight()
  InsertText ("(s5h12v0s0b3T",_INSERT_)
end

proc tSendCourierLargeBold()
  SendEscSequence ("(s5h12v0s3b3T")
end

proc tCourierLargeBold()
  InsertText ("(s5h12v0s3b3T",_INSERT_)
end

proc tSendCourierSmall()
  SendEscSequence ("(s16.67h6v0s0b3T")
end

proc tCourierSmall()
  InsertText ("(s16.67h6v0s0b3T",_INSERT_)
end

proc tSendCourierTinyLight()
  SendEscSequence ("(s20h6v0s0b3T")
end

proc tCourierTinyLight()
  InsertText ("(s20h6v0s0b3T",_INSERT_)
end

proc tSendCourierTinyBold()
  SendEscSequence ("(s20h6v0s3b3T")
end

proc tCourierTinyBold()
  InsertText ("(s20h6v0s3b3T",_INSERT_)
end

proc tSendGothicNormalLight()
  SendEscSequence ("(s12h12v0s0b4101T")
end

proc tGothicNormalLight()
  InsertText ("(s12h12v0s0b4101T",_INSERT_)
end

proc tSendGothicNormalBold()
  SendEscSequence ("(s12h12v0s3b4101T")
end

proc tGothicNormalBold()
  InsertText ("(s12h12v0s3b4101T",_INSERT_)
end

proc tLeftMargin(integer send)
  integer n = 0
  integer maxn = 15
  integer ok = FALSE
  ok = Ask("Left margin: ", nLeftMargin, nLeftMargin_hist)
  if ok and Length(nLeftMargin) > 0
    n = Val(nLeftMargin)
    if n >= 0 and n <= maxn
      if send
        SendEscSequence ("&a"+nLeftMargin+"L")
      else
        InsertText ("&a"+nLeftMargin+"L",_INSERT_)
      endif
    else
      Warn ("Value out of range [0.."+Str(maxn)+"]")
    endif
  endif
end

// Cancel escape sequences all through the file
proc tCancelAll()
  integer i
  lReplace("E","","gn")
  lReplace("&d1D","","gn")
  lReplace("&d2D","","gn")
  lReplace("&d@","","gn")
  lReplace("(s1Q","","gn")
  lReplace("(s2Q","","gn")
  lReplace("(s10h12v0s0b3T","","gn")
  lReplace("(s10h12v1s0b3T","","gn")
  lReplace("(s10h12v0s3b3T","","gn")
  lReplace("(s10h12v1s3b3T","","gn")
  lReplace("(s5h12v0s0b3T","","gn")
  lReplace("(s5h12v0s3b3T","","gn")
  lReplace("(s16.67h6v0s0b3T","","gn")
  lReplace("(s20h6v0s0b3T","","gn")
  lReplace("(s20h6v0s3b3T","","gn")
  lReplace("(s12h12v0s0b4101T","","gn")
  lReplace("(s12h12v0s3b4101T","","gn")
  i = 1
  repeat
    lReplace("&a"+Str(i)+"L","","gn")
    i = i + 1
  until i > 15
end tCancelAll

// Cancel escape sequences on the current line
proc tCancelLine()
  integer i
  PushPosition()
  BegLine()
  lReplace("E","","cn")
  lReplace("&d1D","","cn")
  lReplace("&d2D","","cn")
  lReplace("&d@","","cn")
  lReplace("(s1Q","","cn")
  lReplace("(s2Q","","cn")
  lReplace("(s10h12v0s0b3T","","cn")
  lReplace("(s10h12v1s0b3T","","cn")
  lReplace("(s10h12v0s3b3T","","cn")
  lReplace("(s10h12v1s3b3T","","cn")
  lReplace("(s5h12v0s0b3T","","cn")
  lReplace("(s5h12v0s3b3T","","cn")
  lReplace("(s16.67h6v0s0b3T","","cn")
  lReplace("(s20h6v0s0b3T","","cn")
  lReplace("(s20h6v0s3b3T","","cn")
  lReplace("(s12h12v0s0b4101T","","cn")
  lReplace("(s12h12v0s3b4101T","","cn")
  i = 1
  repeat
    lReplace("&a"+Str(i)+"L","","cn")
    i = i + 1
  until i > 15
  PopPosition()
  Down()
end tCancelLine

// New keys and menus **************************************************
forward proc tDisableNewKeys()
forward menu tMainMenu()
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
  <F11>            tMainMenu()
  <Alt F11>        tInsertMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1
    Disable(new_keys)
    DelHistory(nLeftMargin_hist)
  endif
end

//  ***********************************************
Menu tFontMenu()
  Title = "Fonts"
  Width = 19
  x = 40
  y = 3
  history
  "&Courier Normal Light"             , tCourierNormalLight()
  "Courier &Normal Bold"              , tCourierNormalBold()
  "Courier Normal &Italic Light"      , tCourierNormalItalicLight()
  "Courier Normal It&alic Bold"       , tCourierNormalItalicBold()
  "Courier &Large Light"              , tCourierLargeLight()
  "Courier Large &Bold"               , tCourierLargeBold()
  "Courier &Small"                    , tCourierSmall()
  "Courier &Tiny Light"               , tCourierTinyLight()
  "Courier Tiny B&old"                , tCourierTinyBold()
  "",,Divide
  "Letter &Gothic Normal Light"       , tGothicNormalLight()
  "Letter Got&hic Normal Bold"        , tGothicNormalBold()
end tFontMenu

//  ***********************************************
Menu tSendFontMenu()
  Title = "Send font esc sequences"
  Width = 19
  x = 38
  y = 2
  history
  "&Courier Normal Light"             , tSendCourierNormalLight()
  "Courier &Normal Bold"              , tSendCourierNormalBold()
  "Courier Normal &Italic Light"      , tSendCourierNormalItalicLight()
  "Courier Normal It&alic Bold"       , tSendCourierNormalItalicBold()
  "Courier &Large Light"              , tSendCourierLargeLight()
  "Courier Large &Bold"               , tSendCourierLargeBold()
  "Courier &Small"                    , tSendCourierSmall()
  "Courier &Tiny Light"               , tSendCourierTinyLight()
  "Courier Tiny B&old"                , tSendCourierTinyBold()
  "",,Divide
  "Letter &Gothic Normal Light"       , tSendGothicNormalLight()
  "Letter Got&hic Normal Bold"        , tSendGothicNormalBold()
end tSendFontMenu

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
Menu tInsertMenu()
  Title = "Insert Escape Sequences"
  Width = 19
  x = 5
  y = 3
  history
  "Underline Single Fixed On"        , tUnderlineOn()
  "Underline Double Fixed On"        , tUnderline2On()
  "Underline off"                    , tUnderlineOff()
  "Draft Quality"                    , tDraftQuality()
  "Letter Quality"                   , tLetterQuality()
  "Reset"                            , tReset()
  "&Left Margin ..."                 , tLeftMargin(FALSE)
  "&Fonts <CtrlAltF> "              , tFontMenu(),        DontClose
  "",,Divide
  "&Cancel esc seq <CtrlAltC> "     , tCancelMenu(),      DontClose
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <Alt F11>"      , tInsertMenu()
end tInsertMenu

Menu tMainMenu()
  Title = "Send Escape Sequences"
  Width = 19
  x = 3
  y = 2
  history
  "Underline Single Fixed On"        , tSendUnderlineOn()
  "Underline Double Fixed On"        , tSendUnderline2On()
  "Underline off"                    , tSendUnderlineOff()
  "Draft Quality"                    , tSendDraftQuality()
  "Letter Quality"                   , tSendLetterQuality()
  "Reset"                            , tSendReset()
  "",,Divide
  "&Left Margin ..."                 , tLeftMargin(TRUE)
  "&Fonts <CtrlAltF> "              , tSendFontMenu(),      DontClose
  "",,Divide
  "&Insert Escape Sequences "       , tInsertMenu(),        DontClose
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <F11>"          , tMainMenu()
end tMainMenu

proc Main()
  nLeftMargin_hist = GetFreeHistory("S:hp500")
  Enable (new_keys)
  tMainMenu()
end
