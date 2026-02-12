/* Running programs on the date in the editor window for SemWare's
   TSE editor V4.0. To make this SAL macro operational, invoke the
   main menu (F10), choose "Macro", choose "Compile" and press Enter
   at "Execute Macro".

....................................................................
Prof. Timo Salmi ftp & http://garbo.uwasa.fi/ archives 193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi <http://www.uwasa.fi/~ts/>  ; FIN-65101,  Finland
Timo's  FAQ  materials  at   http://www.uwasa.fi/~ts/http/tsfaq.html
Dense spam-kill procmail filtering with a public email key in effect
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "WPROGS.S HELP"         // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's calling various executable programs. "
  ""
  " This macro runs external programs using the data of "
  " the current (saved) file as its input. Before you can "
  " run an item from this macro, you need the corresponding "
  " program. You have to acquire separately each program "
  " which you wish to use. "
  ""
  " The programs that can be called rigth now include e.g. "
  " linear programming, trivial encryption/decryption, and "
  " Turbo Pascal."
  ""
  " You can use <F11> to invoke the command menu after first"
  " exiting this help. "
  ""
  " Last updated Sun 9-January-2005 12:17:21 "
end  /* tHelpData */

// Solve a linear programming program with Timo's linsolve *************
proc timoLinsolve()
  string cfilename[80] = CurrFileName()
  string progname[80] = "c:\_f\matem\linsolve.exe"
  if FileExists(progname)
    Dos (progname + " /i" + cfilename, _DONTPROMPT_)
  else
    PopWinOpen(2,3,79,8, 1, "Warning", Color(BRIGHT Red ON Black))
    Set(Attr, Color(BRIGHT Magenta ON Black))
    ClrScr()
    Writeline('File ', progname, ' was not found!')
    Set(Attr, Color(BRIGHT Yellow ON Black))
    Writeline('You need it from ftp://garbo.uwasa.fi/pc/ts/tslin35c.zip or whatever')
    Writeline('the current version number is. If you have it, adjust your path to it.')
    Set(Attr, Color(BRIGHT Green ON Black))
    Write ('Press esc ... ')
    GetKey()
    PopWinClose()
  endif
end timoLinsolve

// En/decrypt a file **************************************************
proc timoCrypter()
  string cfilename[80] = CurrFileName()
  string password[30] = "YourOwnPassword"  // put your password here
  string progname[80] = "c:\_f\tuki\crypter.exe"
  string destfold[20] = "c:\_m"
  if not FileExists(progname)
    PopWinOpen(2,3,79,8, 1, "Warning", Color(BRIGHT Red ON Black))
    Set(Attr, Color(BRIGHT Magenta ON Black))
    ClrScr()
    Writeline('File ', progname, ' was not found!')
    Set(Attr, Color(BRIGHT Yellow ON Black))
    Writeline('You need it from ftp://garbo.uwasa.fi/pc/ts/tsfcom24.zip or whatever')
    Writeline('the current version number is. If you have it, adjust your path to it.')
    Set(Attr, Color(BRIGHT Green ON Black))
    Write ('Press esc ... ')
    GetKey()
    PopWinClose()
  elseif not FileExists(destfold + '\')
    PopWinOpen(2,3,79,8, 1, "Warning", Color(BRIGHT Red ON Black))
    Set(Attr, Color(BRIGHT Magenta ON Black))
    ClrScr()
    Writeline('Destination folder ', destfold, ' was not found!')
    Set(Attr, Color(BRIGHT Yellow ON Black))
    Writeline('You either need to edit and recompile the macro to point to an existing')
    Writeline('folder, or create the destination folder ', destfold)
    Set(Attr, Color(BRIGHT Green ON Black))
    Write ('Press esc ... ')
    GetKey()
    PopWinClose()
  else
    Dos (progname + " /o " + cfilename + " " + destfold + "\$crypt.tmp " + password, _DONTPROMPT_)
    Dos ("copy " + destfold + "\$crypt.tmp " + destfold + "\$crypt.txt", _DONTPROMPT_)
    Dos ("del " + destfold + "\$crypt.tmp", _DONTPROMPT_)
    AbandonFile()
    EditFile(cfilename)
    EditFile(destfold + "\$crypt.txt")
  endif
end timoCrypter

// Compile a Turbo Pascal source ***************************************
proc timoTpc()
  string cfilename[80] = CurrFileName()
  string progfold[80] = "c:\_f\progs\turbo70"
  string progname[80] = progfold + "\tpc.exe"
  string destfold[20] = "c:\_m"
  if not FileExists(progname)
    PopWinOpen(2,3,79,9, 1, "Warning", Color(BRIGHT Red ON Black))
    Set(Attr, Color(BRIGHT Magenta ON Black))
    ClrScr()
    Writeline('File ', progname, ' was not found!')
    Set(Attr, Color(BRIGHT Yellow ON Black))
    Writeline('You need Turbo Pascal 7.0 to use this macro entry. If you already have')
    Writeline('Turbo Pascal, adjust your path to it in the macro.')
    WriteLine('A destination folder ' + destfold + ' or customizing the macro is needed, as well.')
    Set(Attr, Color(BRIGHT Green ON Black))
    Write ('Press esc ... ')
    GetKey()
    PopWinClose()
  elseif not FileExists(destfold + '\')
    PopWinOpen(2,3,79,8, 1, "Warning", Color(BRIGHT Red ON Black))
    Set(Attr, Color(BRIGHT Magenta ON Black))
    ClrScr()
    Writeline('Destination folder ', destfold, ' was not found!')
    Set(Attr, Color(BRIGHT Yellow ON Black))
    Writeline('You either need to edit and recompile the macro to point to an existing')
    Writeline('folder, or create the destination folder ' + destfold)
    Set(Attr, Color(BRIGHT Green ON Black))
    Write ('Press esc ... ')
    GetKey()
    PopWinClose()
  else
    Dos (progname + " /u" + destfold + "\;" + progfold +  " /e" + destfold + "\ " + cfilename + " & pause")
  endif
end timoTpc

// Analyze a Turbo Pascal source ***************************************
proc timoPsa()
  string cfilename[80] = CurrFileName()
  string progfold[80] = "c:\_f\turbpasc\anal"
  string progname[80] = progfold + "\psa.exe"
  string destfold[20] = "c:\_m"
  if not FileExists(progname)
    PopWinOpen(2,3,79,8, 1, "Warning", Color(BRIGHT Red ON Black))
    Set(Attr, Color(BRIGHT Magenta ON Black))
    ClrScr()
    Writeline('File ', progname, ' was not found!')
    Set(Attr, Color(BRIGHT Yellow ON Black))
    Writeline('You need TurboPower Software Structure Analyst to use this macro entry.')
    Writeline('If you already have it, adjust your path to it.')
    WriteLine('A destination folder ' + destfold + ' or customizing the macro is needed, as well.')
    Set(Attr, Color(BRIGHT Green ON Black))
    Write ('Press esc ... ')
    GetKey()
    PopWinClose()
  elseif not FileExists(destfold + '\')
    PopWinOpen(2,3,79,8, 1, "Warning", Color(BRIGHT Red ON Black))
    Set(Attr, Color(BRIGHT Magenta ON Black))
    ClrScr()
    Writeline('Destination folder ', destfold, ' was not found!')
    Set(Attr, Color(BRIGHT Yellow ON Black))
    Writeline('You either need to edit and recompile the macro to point to an existing')
    Writeline('folder, or create the destination folder ' + destfold)
    Set(Attr, Color(BRIGHT Green ON Black))
    Write ('Press esc ... ')
    GetKey()
    PopWinClose()
  else
    Dos (progname + " /o " + destfold + "\$analyze.rpt " + cfilename, _DONT_PROMPT_)
    EditFile(destfold + "\$analyze.rpt")
  endif
end timoPsa

// Run a Turbo Pascal source ***************************************
proc timoTurboRun()
  string cfilename[80] = CurrFileName()
  string progfold[80] = "c:\_f\progs\turbo70"
  string progname[80] = progfold + "\tpc.exe"
  string destfold[20] = "c:\_m"
  string basename[80]
  integer i
  //
  basename = SubStr(cfilename,1,Pos(".", cfilename)-1)
  repeat
    i = Pos("\",SubStr(basename,1,Length(basename)))
    if i > 0
      basename = SubStr(basename,i+1,Length(basename))
    endif
  until i == 0
  //
  if not FileExists(progname)
    PopWinOpen(2,3,79,9, 1, "Warning", Color(BRIGHT Red ON Black))
    Set(Attr, Color(BRIGHT Magenta ON Black))
    ClrScr()
    Writeline('File ', progname, ' was not found!')
    Set(Attr, Color(BRIGHT Yellow ON Black))
    Writeline('You need Turbo Pascal 7.0 to use this macro entry. If you already have')
    Writeline('Turbo Pascal, adjust your path to it in the macro.')
    WriteLine('A destination folder ' + destfold + ' or customizing the macro is needed, as well.')
    Set(Attr, Color(BRIGHT Green ON Black))
    Write ('Press esc ... ')
    GetKey()
    PopWinClose()
  elseif not FileExists(destfold + '\')
    PopWinOpen(2,3,79,8, 1, "Warning", Color(BRIGHT Red ON Black))
    Set(Attr, Color(BRIGHT Magenta ON Black))
    ClrScr()
    Writeline('Destination folder ', destfold, ' was not found!')
    Set(Attr, Color(BRIGHT Yellow ON Black))
    Writeline('You either need to edit and recompile the macro to point to an existing')
    Writeline('folder, or create the destination folder ' + destfold)
    Set(Attr, Color(BRIGHT Green ON Black))
    Write ('Press esc ... ')
    GetKey()
    PopWinClose()
  else
    Dos (destfold + "\" + basename + " & pause")
  endif
end timoTurboRun

// Invoke Timo's own spelling checking program. No misttoks will remain. :-)
proc timoSpeller()
  string cfilename[80] = CurrFileName()
  string progname[80]  = "c:\_f\sanat\spell.exe"
  string vocabname[80] = "c:\_f\sanat\spelled3.dny"
  string listprog[80]  = "c:\_f\tools\list.com"
  if not FileExists(progname)
    PopWinOpen(2,3,79,8, 1, "Warning", Color(BRIGHT Red ON Black))
    Set(Attr, Color(BRIGHT Magenta ON Black))
    ClrScr()
    Writeline('Program file ', progname, ' was not found!')
    Set(Attr, Color(BRIGHT Yellow ON Black))
    Writeline('You need it from ftp://garbo.uwasa.fi/pc/ts/tschek15.zip or whatever')
    Writeline('the current version number is. If you have it, adjust your path to it.')
    Set(Attr, Color(BRIGHT Green ON Black))
    Write ('Press esc ... ')
    GetKey()
    PopWinClose()
  elseif not FileExists(vocabname)
    PopWinOpen(2,3,79,8, 1, "Warning", Color(BRIGHT Red ON Black))
    Set(Attr, Color(BRIGHT Magenta ON Black))
    ClrScr()
    Writeline('Vocabulary file ', vocabname, ' was not found!')
    Set(Attr, Color(BRIGHT Yellow ON Black))
    Writeline('You need it from ftp://garbo.uwasa.fi/pc/ts/tschek15.zip or whatever')
    Writeline('the current version number is. If you have it, adjust your path to it.')
    Set(Attr, Color(BRIGHT Green ON Black))
    Write ('Press esc ... ')
    GetKey()
    PopWinClose()
  elseif not FileExists(listprog)
    PopWinOpen(2,3,79,8, 1, "Warning", Color(BRIGHT Red ON Black))
    Set(Attr, Color(BRIGHT Magenta ON Black))
    ClrScr()
    Writeline('List program file ', listprog, ' was not found!')
    Set(Attr, Color(BRIGHT Yellow ON Black))
    Writeline('You need it from ftp://garbo.uwasa.fi/pc/fileutil/listp96x.zip or whatever')
    Writeline('the current version number is. If you have it, adjust your path to it.')
    Set(Attr, Color(BRIGHT Green ON Black))
    Write ('Press esc ... ')
    GetKey()
    PopWinClose()
  else
    Dos (progname + " " + vocabname + " /f " + cfilename + " | " + listprog + " /s", _DONTPROMPT_)
  endif
end timoSpeller

// New keys and menus **************************************************
forward Menu tProgsMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 3>      timoLinsolve()
  <CtrlAlt 4>      timoCrypter()
  <CtrlAlt 7>      timoTpc()
  <CtrlAlt 8>      timoTurboRun()
  <CtrlAlt 9>      timoPsa()
  <CtrlAlt ->      timoSpeller()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            tProgsMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The programs menu ***************************************************
Menu tProgsMenu()
  Title = "Timo's program call menu"
  Width = 19
  x = 40
  y = 3
  history
  "&Linsolve             <CtrlAlt 3>"   , timoLinsolve()
  "En/decr&ypt           <CtrlAlt 4>"   , timoCrypter()
  "&Turbo Pascal compile <CtrlAlt 7>"   , timoTpc()
  "Turbo &run            <CtrlAlt 8>"   , timoTurboRun()
  "Turbo &analyst        <CtrlAlt 9>"   , timoPsa()
  "&Check spelling II    <CtrlAlt ->"   , timoSpeller()
  "",,Divide
  "Disable &new keys     <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help                 <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu            <F11>"
end  /* tProgsMenu */

proc Main()
  Enable (new_keys)
  tProgsMenu()
end
