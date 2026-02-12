/* A special net postscript print for SemWare's TSE editor V2.5.
   This macro is an expert's tool, and will require much more than
   usual to configure it to make it work. To make this SAL macro
   operational, first customize the file name and the path
   constants, then invoke the main menu (F10), choose "Macro",
   choose "Compile" and press Enter at "Execute Macro".

....................................................................
Prof. Timo Salmi   Co-moderator of news:comp.archives.msdos.announce
Moderating at ftp:// & http://garbo.uwasa.fi archives  193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi  <URL:http://uwasa.fi/~ts>  ; FIN-65101,  Finland
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "POSTSCRI.S HELP"       // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's use net postscript printers. "
  ""
  " This macro is an expert's tool and may require "
  " careful customizing and acquisitions before you "
  " can utilize it. "
  ""
  " You can use <F11> to invoke the command menu after "
  " first exiting this help. "
  ""
  " Last updated Tue 23-January-1996 21:33:53 "
end  /* tHelpData */

// Initializations
//
integer font_size = 25
string font_type[20] = "NCSB"
string printer_choice[20] = "lt"           // Customize as appropriate
//
integer left_margin_hist
integer line_spacing_hist
integer font_size_hist
//
string ramDiskPath[80] = "r:\"             // Customize as appropriate
string ramFilePath[80] = "ts$$.prn"        // Customize as appropriate
//
string pcpsProg[80] = "c:\box\boxtools\pcps.exe" // Customize as appropriate
//
string lprDrive[1]  // Customize as appropriate in proc Main()
string lprPath[80]  = "\progs\telecsv"   // Customize as appropriate

// Check that you have the right PC, customize as appropriate
// You'll need a "set pcid_=YourId" in you autoexec.bat
integer proc CheckPC()
  case GetEnvStr("PCID_")
    when "karvi","osku" Return (TRUE)  // Customize as appropriate
  endcase
  Warn("The macro is not for this PC, see CheckPC()" )
  Return(FALSE)
end CheckPC

// Check that the ramdisk is available
integer proc CheckRamDisk()
  if FileExists(ramDiskPath) Return(TRUE) endif
  PopWinOpen(2,3,74,8, 1, "Warning", Color(BRIGHT Red ON Black))
  Set(Attr, Color(BRIGHT Magenta ON Black))
  ClrScr()
  Writeline('Ramdisk directory ', ramDiskPath, ' was not found!')
  Set(Attr, Color(BRIGHT Yellow ON Black))
  Writeline('You either need to edit and recompile the macro to point to an existing')
  Writeline('drive, or create an appropriate ramdisk.')
  Set(Attr, Color(BRIGHT Green ON Black))
  Write ('Press esc ... ')
  GetKey()
  PopWinClose()
  Return(FALSE)
end CheckRamDisk

// Check that the postscript program is available
integer proc CheckPCPSprog()
  if FileExists(pcpsProg) Return(TRUE) endif
  PopWinOpen(2,3,79,8, 1, "Warning", Color(BRIGHT Red ON Black))
  Set(Attr, Color(Cyan ON Black))
  ClrScr()
  Writeline('File ', pcpsProg, ' was not found!')
  Set(Attr, Color(BRIGHT Yellow ON Black))
  Writeline('You need it from garbo.uwasa.fi:/pc/postscript/pcps792.zip for running')
  Writeline('this macro. If you already have it, adjust your path to it.')
  Set(Attr, Color(BRIGHT Green ON Black))
  Write ('Press esc ... ')
  GetKey()
  PopWinClose()
  Return(FALSE)
end CheckPCPSprog

// Check that program to send a job to a remote printer is available
integer proc CheckLPRprog()
  if FileExists(lprDrive + ":" + lprPath + "\lpr.exe")
    Return(TRUE)
  endif
  PopWinOpen(2,3,79,8, 1, "Warning", Color(BRIGHT Red ON Black))
  Set(Attr, Color(Cyan ON Black))
  ClrScr()
  Writeline("File ", lprDrive + ":" + lprPath, "\lpr.exe was not found!")
  Set(Attr, Color(BRIGHT Yellow ON Black))
  Writeline('You need it from garbo.uwasa.fi:/pc/connect/tel2308b.zip for running')
  Writeline('this macro. If you already have it, adjust your path to it.')
  Set(Attr, Color(BRIGHT Green ON Black))
  Write ('Press esc ... ')
  GetKey()
  PopWinClose()
  Return(FALSE)
end CheckLPRprog

/*
Returns the current directory, minus the trailing slash (unless
root) without the drive name. Based on a procedure by Ian Campbell.
*/
string proc tCurrDir()
  string s[80]
  s = SplitPath(ExpandPath(""), _PATH_)
  if Length(s) > 1
    s = SubStr(s, 1, Length(s) - 1)
  endif
  return(s)
end tCurrDir

// Print all to lt/mt printer
proc tPrintAllToLT()
  string s[80] = ""
  string pushDrive[1]
  string pushDir1[80]
  string pushDir2[80]
  //
  s = pcpsProg + " -nb -mal60 -mar1 -fo" + font_type + Str(font_size) + " " + CurrFileName() + " > r:\ts$$.ps"
  //
  pushDir1 = tCurrDir()
  pushDrive = GetDrive()
  LogDrive(lprDrive)
  pushDir2 = tCurrDir()
  ChDir(lprPath)
  //
  Dos (s)
  Dos ("lpr -P" + printer_choice + " -Schyde r:\ts$$.ps", _DONTPROMPT_)
  Dos ("del r:\ts$$.ps", _DONTPROMPT_)
  Message (CurrFileName() + " processed and sent to " + printer_choice + " printer")
  //
  ChDir(pushDir2)
  LogDrive(pushDrive)
  ChDir(pushDir1)
end tPrintAllToLT

// Print block to lt/mt printer
proc tPrintBlockToLT()
  string s[80] = ""
  string pushDrive[1]
  string pushDir1[80]
  string pushDir2[80]
  //
  if isBlockInCurrFile()
    PushPosition()
    PushBlock()
    SaveBlock(ramDiskPath + ramFilePath)
    //
    s = pcpsProg + " -nb -mal60 -mar1 -fo" + font_type + Str(font_size) + " " + ramDiskPath + ramFilePath + " > r:\ts$$.ps"
    //
    pushDir1 = tCurrDir()
    pushDrive = GetDrive()
    LogDrive(lprDrive)
    pushDir2 = tCurrDir()
    ChDir(lprPath)
    //
    Dos (s)
    Dos ("lpr -P" + printer_choice + " -Schyde r:\ts$$.ps", _DONTPROMPT_)
    Dos ("del r:\ts$$.ps", _DONTPROMPT_)
    Message ("Block processed and sent to " + printer_choice + " printer")
    //
    ChDir(pushDir2)
    LogDrive(pushDrive)
    ChDir(pushDir1)
    //
    EraseDiskFile(ramDiskPath + ramFilePath)
    PopBlock()
    PopPosition()
  else
    Warn("No Block")
  endif
end tPrintBlockToLT

proc tSetLTFonSize()
  string vast[11] = Str(font_size)
  Ask("Font size: ", vast, font_size_hist)
  AddHistoryStr (vast, font_size_hist)
  font_size = Val(vast)
end tSetLTFonSize

// New keys and menus **************************************************
forward Menu tPrintToLanMenu()
forward proc timoDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 0>      timoDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tPrintToLanMenu()
end

// Disable the new extra keys ****************************************
proc timoDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1
    Disable(new_keys)
    DelHistory(font_size_hist)
    DelHistory(line_spacing_hist)
    DelHistory(left_margin_hist)
  endif
end

proc tSetFont(integer choice)
  case choice
    when 1 font_type = "NCSB"
    when 2 font_type = "CB"
  endcase
end tSetFont

proc tChoosePrinter(integer choice)
  case choice
    when 1 printer_choice = "lt"
    when 2 printer_choice = "mt"
  endcase
end tChoosePrinter

// Select the font type for lt/mt printer
Menu tSetLTFonTypeMenu()
  Title = "Font type"
  x = 62
  y = 16
  history
  "&NCSB" , tSetFont(1)
  "&CB"   , tSetFont(2)
end /* tSetLTFonTypeMenu */

// The printer choice for lt/mt printer
Menu tChoosePrinterMenu()
  Title = "Choose lt/mt"
  x = 62
  y = 17
  history
  "&lt" , tChoosePrinter(1)
  "&mt" , tChoosePrinter(2)
end /* tChoosePrinterMenu */

// The tPrintToLan menu ***********************************************
Menu tPrintToLanMenu()
  Title = "Timo's net print menu"
  Width = 19
  x = 40
  y = 3
  history
  "Print all to l&t/mt-printer"        , tPrintAllToLT()
  "P&rint block to lt/mt-printer"      , tPrintBlockToLT()
  "",,Divide
  "Set lt/mt &font size ..."           , tSetLTFonSize()     , DontClose
  "Set lt/mt font t&ype "             , tSetLTFonTypeMenu() , DontClose
  "Choose lt&/mt printer "            , tChoosePrinterMenu(), DontClose
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"     , timoDisableNewKeys()
  "&Help              <CtrlAlt H>"     , QuickHelp(tHelpData)
  "This Menu         <F11>"
end  /* tPrintToLanMenu */

proc Main()
  //
  if GetEnvStr("PCID_") == "karvi"
    lprDrive = "f"
  elseif GetEnvStr("PCID_") == "osku"
    lprDrive = "d"
  else
    lprDrive = "c"    // Customize as appropriate
  endif
  //
  if not CheckPC()       goto _endproc endif
  if not CheckPCPSprog() goto _endproc endif
  if not CheckLPRprog()  goto _endproc endif
  if not CheckRamDisk()  goto _endproc endif
  left_margin_hist  = GetFreeHistory("POSTSCRI:postscri1")
  line_spacing_hist = GetFreeHistory("POSTSCRI:postscri2")
  font_size_hist    = GetFreeHistory("POSTSCRI:postscri3")
  Enable (new_keys)
  tprintToLanMenu()
_endproc:
end
