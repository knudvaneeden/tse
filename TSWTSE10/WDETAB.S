/* Detab for SemWare's TSE editor V4.0. To make this SAL macro
   operational, invoke the main menu (F10), choose "Macro", choose
   "Compile" and press Enter at "Execute Macro".

....................................................................
Prof. Timo Salmi ftp & http://garbo.uwasa.fi/ archives 193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi <http://www.uwasa.fi/~ts/>  ; FIN-65101,  Finland
Timo's  FAQ  materials  at   http://www.uwasa.fi/~ts/http/tsfaq.html
Dense spam-kill procmail filtering with a public email key in effect
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "WDETAB.S HELP"         // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's detab "
  ""
  " The macro detabs lines or the entire file. "
  " The advantages over Potpourri's detab are: "
  "  - Includes full source code. "
  "  - Works for smart tabs / expand tabs off. "
  "  - Reports the number of tabs expanded. "
  ""
  " You can use <Ctrl D M> to invoke the command "
  " menu after first exiting this help. Note "
  " that this differs from <F11> used for most "
  " of my other SAL macros. Thus, if you press "
  " <F11>, you might get another macro's help! "
  ""
  " Last updated Fri 3-December-2004 07:30:20 "
end  /* tHelpData */

// Detab one line ******************************************************
integer proc tDetabOneLine(var integer tabCount,
                               integer fixed)
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
  if fixed
    tabWd = 2
  else
    tabWd = Query(TabWidth)
  endif
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
end tDetabOneLine

// Detab a line and go to the next if successful **********************
proc tDetabLine (integer fixed)
  integer countTabs
  if CurrLineLen() > 255
    Warn('Line too long to be detabbed')
  else
    if tDetabOneLine(countTabs, fixed)
      Down()
      Message ('Expanded ' + Str(countTabs) + ' tabs')
    else
      Warn('Line cannot be detabbed, would extend to over 255 characters')
    endif
  endif
end tDetabLine

// Detab the entire file
proc tDetabFile (integer fixed)
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
     if not tDetabOneLine(t, fixed)
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
end tDetabFile

// New keys and menus **************************************************
forward Menu tDetabMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <Ctrl d><f>      tDetabFile(0)
  <Ctrl d><l>      tDetabLine(0)
  <Ctrl d><k>      tDisableNewKeys()
  <Ctrl d><h>      QuickHelp(tHelpData)
  <Ctrl d><m>      tDetabMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The test menu ******************************************************
Menu tDetabMenu()
  Title = "Timo's detab menu"
  Width = 19
  x = 40
  y = 3
  history
  "&Detab file        <Ctrl D F>"   , tDetabFile(0)
  "Detab &line        <Ctrl D L>"   , tDetabLine(0)
  "Detab file, fixed tabwidth"   , tDetabFile(1)
  "",,Divide
  "Disable &new keys  <Ctrl D K>"   , tDisableNewKeys()
  "&Help              <Ctrl D H>"   , QuickHelp(tHelpData)
  "This Menu         <Ctrl D M>"
end  /* tDetabMenu */

proc Main()
  Enable (new_keys)
  tDetabMenu()
end
