/****************************************************************************
  Latex procedures   version 5.5.1
 ***************************************************************************/
string LatexVersion[] = '5.5'

#define WIN_VERSION 2 //  =2  for NT, 2000, XP; =9  for 95, 98. note: not well tested

#define BETA 0        //  =1 if editor is beta version, otherwise =0

/*
   psutils  21-11-2004
   changes from 5.3 to 5.4:
   improved gsviewh1 handles
   error stringlength > 255 in IniDocu()
   lowercase \mathcal{.}
   pickfile( ..., _INSERT_PATH_)
   \langle, \rangle
   if MY_EDITOR_VERSION >= 0x4100  in stead of ==
   testbloc.pfg
   find slide
   Lower(t)
   error in "\padd"
   nomenclature
   Set(ClipBoardId, cclp) before return(1) (2x)
   22-12-04: rename log-file to avoid confusion with Distiller log file
   corrected parameters in psnup
   script...  ipv scrip
   new document : article or slides (to be adapted to its own choice!)
*/

/************************************************************************
  Author:  Sjoerd W. Rienstra (Netherlands)  (email: s dot w dot rienstra at tue dot nl)
  Date:    February 5, 2006

  TSE version: 4 and newer

  Description:
  - A couple of macros to edit,TeX-compile, view, and print LaTeX files from within the editor.
  - Compiles also straight TeX files.
  - Contains all (well, a lot) LaTeX and AMS-LaTeX commands and symbols.
  - The present commands are prepared for a standard MiKTeX-package.
    MikTex can be obtained from "http://www.miktex.org"
    The respective lines and file paths may be modified for other implementations.
  - Dvi-files are viewed with Yap that comes with MikTex.
  - Path names may contain spaces.
  - PostScript-files are viewed with GsView, to be obtained from "http://www.cs.wisc.edu/~ghost".
  - page layout of ps-files can be changed into n pages per sheet with psnup, a postscript
    utility by Angus J. C. Duggan, that can be obtained from
    "http://www.knackered.org/angus/psutils/" or the author's website.
    Fancy menu to read n, the pages-per-sheet number.
  - ps-files can be packed by PKZip (widespread in PC world) or GZip (widespread in UNIX
    world, compatible with GsView). PKZip can be obtained from "http://www.pkware.com".
    GZip can be obtained from "http://www.gzip.org" or the author's website.
  - Seperate zipmenu allows to (un)gzip, (un)pkzip and (un)tar.
  - Files can be packed (not necessarily compressed) with Tar (widespread in UNIX world).
    A MSWindows-compatible tar.exe (note: needs win32gnu.dll) can be obtained from
    "http://www.buva.sowi.uni-bamberg.de/files/software/gnu4NT/" or the author's website.
  - ps-files can be converted to pdf-files by Adobe's Acrobat Distiller (commercial package).
  - Option to generate selected ps-pages.
  - Contains some useful utilities like:
    . compilation + viewing in one run, no attempt to view if compilation unsuccessful.
    . automatic LaTeX re-run if labels have changed.
    . line-block compilation for testing a small piece, with or without ps-output
    . testing and viewing of a single slide, with or without ps-output
    . generates complete \begin-\end environment. If the cursor is in a line-block,
      the environment embraces the block.
    . \begin-\end environment from the name given.
    . delete \begin-\end environment
    . make index by point-and-shoot.
    . a "match" for \begin and \end.
    . an extension of the "WrapPara"-macro to deal with LaTeX constructs (with the help
      of Dan Luecking). The "public" procedure may replace the regular WrapPara.
    . a personal help, to be maintained & filled by user.
    . cleaneps macro to remove non-ascii junk (thumbnail...) at beginning of eps-file.
    . automatic include-file recognition.
  - An attempt was made to utilize the MikTex "source-specials" in the dvi-file to allow
    for jumping to "current position in Yap-view", and to "inverse search" from Yap to
    corresponding line in editor. This failed because Yap seems to accept only dvi-stored
    tex-filenames without path. We removed this option.
  - Improved configuration procedure.
  - An option to update a variable "\status" in order to show the status of a document on
    header or footer by (for example):
                  \usepackage{fancyhdr}
                  \pagestyle{fancyplain}{\rfoot{version: \status}}
  - reference tables of regular symbols, AMSTex symbols, and ding-font symbols from ps-file

  Usage notes:
  - Check your Windows version ("9" or "2") on line 6 if your editor version is 4.0 or lower
  - Configuration via menu (data in tse.ini)
  - Selfexplanatory menus.
  - In the "commands" and "symbols" one can "incremental-search".
  - Generates dvi and/or PostScript file.
  - Prompt-toggle is for capturing error messages.
  - "Main file", to be TeX-compiled, may be different from edited "include file".
    This is useful for e.g. a book with chapters, organized in separate files.
    The default mainfile name is the current file name. Note that a non-default mainfile
    name is not remembered when navigating through the ring of files. The normal strategy
    is to indicate in an include file the mainfile name by the line:
    %_INCLUDE_FILE_OF_"<mainfilename>.tex"
    If the file is recognized as an include file, the message
    "Include file of <mainfile>" is displayed.
  - "Ps-file" allows the user to change the name of the output postscript file.
    Default is the Latex-name with extension ".ps". Note that one (1) changed ps-file name
    is remembered when navigating through the ring of files.
  - "Block" is for compilation of a line-blocked part. The block is copied to an
    auxiliary file called "testbloc.tex", together with the initial part of the (main)
    file, up to "\begin{document}". The "testbloc.*"-files are removed at exiting the
    editor if the current directory is not changed.
  - The pages-per-sheet number may be + (Right-orientation) or - (Left-orientation).
    Select by right-left cursor, R, L, +, or - keys, or toggle with spacebar.
    Note: R and L correspond to the psnup.exe-options -l and -r, respectively.

  Reserved file names:
  - testbloc.tex, .dvi, .ps, .log, .aux, .idx, .ind, .ilg, .toc, .bbl, .blg, .tmp, .pfg
  - <filename without extension>.ps.tmp, .ps.nup, .ps.zip

  Installation:
  - The user should configure the necessary paths via the menu.
  - Add Latex to the autoload list
  - If not present, adapt the tse.ui definition file:
    . Add to the global variables the string:
      string tex_fun[] = "^\\{chapter}|{{subsub}|{sub}|{}section}|{{sub}|{}paragraph}"
    . Add to the procedure GetFunctionStr (used by FunctionList=mCompressView(1))
      the lines:
          when '.tex'
               return (tex_fun)
    . Neater, but not necessary:
      Change the key definition  <Alt q>   WrapPara()  into:
       <Alt q>   ExecMacro("TeXWrapPara").
    . Don't forget to re-compile tse.ui .

  Keys:
        <F12>                LatexMenu()
        <Shift F12>          Commands()
        <Ctrl F12>           EditFile('*.tex')
        <CtrlShift F12>      ZipMenu()
        <Alt F12>            EditFile(CurrFile+'.*')
        <CtrlAlt I>          Indexs()
        <CtrlAlt B>          FindBE()
        <Alt B>              lFind('\begin{','i+')
        <Ctrl B>             lFind('\begin{','bi+')
        <Alt Q>              ExecMacro("TeXWrapPara").
        <Ctrl \>             EnvFinish()
 ************************************************************************/

/************************************************************************
   Dos-options do not work well for older versions of g32.exe .
   Therefore a version based on windows primitives
   from kernel32.dll and user32.dll is included.

    _DEFAULT_             =  0
    _DONT_PROMPT_         =  1
    _DONT_CLEAR_          =  2
    _RUN_DETACHED_        =  4
    _PRESERVE_SCREEN_     =  8
                          =  16
    _RETURN_CODE_         =  32
    _TEE_OUTPUT_          =  64
                          =  128
    _DONT_CHANGE_VIDEO_   =  256
    _CREATE_NEW_CONSOLE_  =  512
    _DONT_WAIT_           =  1024
    _START_HIDDEN_        =  2048
    _START_MAXIMIZED_     =  4096
    _START_MINIMIZED_     =  8192

    _RETURN_PROCESS_HANDLE_  Instead of a return code, the process handle is returned.
                             You can call GetExitCodeProcess() to see if the process is
                             still running.  Only valid if used in conjunction with
                            _RUN_DETACHED_|_DONT_WAIT_.

    _DONT_WAIT_              Don't wait for a process to end.  Valid with _RUN_DETACHED_.

    _DONT_CHANGE_TITLE_      Leave the window title/caption alone.

  Console only:

    _PRESERVE_SCREEN_        Do a PopWin over the editors screen before calling command
    _DONT_CHANGE_VIDEO_      Don't force a safe (25x80, 43x80, 50x80) screen size in Win95/98/ME
    _CREATE_NEW_CONSOLE_     Just what is says

  GUI only:

   _ALLOW_DETACHMENT_        Allows detaching the child from the parent

  dont know why, but CreateNewConsole is necessary for e.32: so use
       lDos(cmd,cmf,_CREATE_NEW_CONSOLE_)
************************************************************************/

STRING iniFileNameGS[255] = ".\latex55.ini"

#ifndef EDITOR_VERSION
    #define EDITOR_VERSION 0
#endif

#if BETA == 0
 #define MY_EDITOR_VERSION EDITOR_VERSION
#endif
#if BETA == 1
  #define MY_EDITOR_VERSION 0x4100   // only for beta versions
#endif

integer
       StartPage    = 1,
       NmrOfPage    = 0,
       pgps         = 1,
       GetPgPsLine  = 1,
       prmpt        = OFF,
       overwr       = OFF,
       menu_history = 2,     //Latex 2 psi
       ps_history   = 1,     //ps 2 pdf
       psu_history  = 1,     //ps 2 pdf
       pgpsborder   = OFF,
       zip_history  = 1,     //gzip, pkzip
       gsviewh      = 0,    // gsview handle for latex-psfile
       yaph         = 0,    // yap    handle for latex-dvifile
       gsviewhb     = 0,    // gsview handle for block-psfile
       yaphb        = 0,    // yap    handle for block-dvifile
       gsviewhs     = 0,    // gsview handle for symbols-psfile
       psfnid       = 0,    // psfilename id
       tb2ps                // testblock as postscript

string
       gsviewh1[MAXSTRINGLEN] = '',   // gsview handle array for (e)psfile, indep. of tex

       LxSctn[] = 'LaTeX',

       c_txpth[]= 'LaTeXBinPath',
       c_gsvw[] = 'GhostViewPath',
       c_psnup[]= 'PsnupPath',
       c_gzip[] = 'GzipPath',
       c_tar[]  = 'TarPath',
       c_pkzip[]= 'PkzipPath',
       c_acdst[]= 'AcrobatDistillerPath',
       c_myhlp[]= 'MyLaTeXHelpfilePath',
       c_tb2ps[]= 'TestBlock2PostScript',

       txpth[_MAXPATH_] ,       // = 'c:\miktex\texmf\miktex\bin\',
       gsview[_MAXPATH_],       // = 'c:\miktex\ghostgum\gsview\gsview32.exe',
       psnup[_MAXPATH_] ,       // = 'c:\utl\psnup.exe',
       gzip[_MAXPATH_]  ,       // = 'c:\utl\gzip.exe',
       tar[_MAXPATH_]   ,       // = 'c:\utl\tar.exe',
       pkzip[_MAXPATH_] ,       // = 'c:\utl\pkzip25.exe',
       acdist[_MAXPATH_],       // = 'c:\Program Files\Adobe\Acrobat 5.0\Distillr\AcroDist.exe',
       myhelp[_MAXPATH_],       // = 'c:\tse32\supp\latex.hlp',


       ltx[]    = 'latex.exe',
       tx[]     = 'tex.exe',
       view[]   = 'yap.exe',
       dv2ps[]  = 'dvips.exe',
       bibtx[]  = 'bibtex.exe',
       mkindx[] = 'makeindex.exe',
       tb[]     = 'testbloc',
       psfile[_MAXPATH_],
       psfn[_MAXPATH_],
       mainfile[_MAXPATH_],
       barename[_MAXPATH_],
       tbpath[_MAX_PATH_],
       stopat1[] = '{{^}|{[~\\].*}\\\[}|{\\]}|{\\begin}|{\\end}|{\\s[a-z]*ection}|{\\[{sub}]*paragraph}|{^[ ]*%}',
       stopat2[] = '{\$\$}|{\\chapter}|{\\bibitem}|{\\[bmsvh][a-z]*skip}',
       stopat3[] = '{^[ ]*\\{new}|{clear}|{}page{style}|{}}',
       stopfrom[] ='{\\item}',
       stopwith[] = '{\$\$}|{\\\\}|{\\\\\[.*\]}|{[~\\]*%}',
       env1[] = 'center'    , env2[] = 'list'        , env3[]  = 'enumerate' ,
       env4[] = 'flushleft' , env5[] = 'flushright'  , env6[]  = 'verbatim'  ,
       env7[] = 'minipage'  , env8[] = 'quote'       , env9[]  = 'small'     ,
       env10[]= 'example'   , env11[]= 'thebibliography', env12[] = 'document'

forward  integer proc TestOnLatex(integer w)
forward  integer proc isBlankLine()
forward  integer proc Latexcomp(integer latex_type)
forward  string proc OnOffStr(integer i)
forward  string proc RtAl(string woord, integer n)
forward  string proc UnQuote(string s)
forward  proc mDos(string cmd, integer n)
forward  proc WriteSettings()
forward  proc GetSettings()
forward  proc Configure()
forward  proc PolishConfig()
forward  proc ToggleNr(var integer n,integer m)
forward  proc mChDirCurrFile()
forward  proc GetNumber(var integer n, integer m)
forward  proc GetString(var string s)
forward  proc PgPsPaintStatus()
forward  proc PgPsPaintChart(integer n)
forward  integer proc PgPsLoop()
forward  proc PgPsInit()
forward  proc PgPsDone( integer CurY )
forward  proc GetPgPs()
forward  proc GetPsName()
forward  proc GetMFName()
forward  proc BibTex()
forward  proc MakeIndex()
forward  proc MakeNomenc()
forward  integer proc DviView()
forward  proc Dvi2PS()
forward  integer proc PSView()
forward  integer proc FindWindowTitle(string title)
forward  integer proc TSE2GSview(string fn)
forward  string  proc GetWindowText(integer hwnd)
forward  menu PSMenu()
forward  menu PSUtils()
forward  proc PS2PDF()
forward  proc DistCFG()
forward  proc PS2GZ()
forward  proc PS2PKZ()
forward  proc PS2PSNUP()
forward  menu ZipMenu()
forward  proc F2GZ()
forward  proc F2UGZ()
forward  proc F2PKZ()
forward  proc F2TAR()
forward  proc F2UTAR()
forward  proc F2UPKZ()
forward  integer proc TestBlock()
forward  integer proc PSViewBlock()
forward  proc Figure()
forward  proc Margin()
forward  proc Table()
forward  proc Array()
forward  proc IniDocu()
forward  proc IncMnfn()
forward  proc UpdStatus()
forward  proc CleanEps()
forward  proc Indexs()
forward  proc FindBE()
forward  proc Envirs()
forward  proc Environment(string tx1, string tx2, integer nr, integer bl, integer cl)
forward  proc LE_PaintStatus(integer CurCX, integer CurX)
forward  proc LE_PaintChart(integer CurX)
forward  integer proc LE_Loop(integer CurX)
forward  proc LE_Init(integer crcl, integer cl)
forward  proc LE_Done()
forward  proc LatComs()
forward  proc Symbols()
forward  proc AMSSymb()
forward  proc ShowSymbols()
forward  proc WhenExit()
forward  public proc TeXWrapPara()
forward  proc EnvFinish()
forward  proc EnvDel()
forward  proc StopOnChangingFilesHook()
forward  proc MainPsFileNames()
forward  menu Options()
forward  menu LMenu()
forward  proc LatexMenu()
forward  menu BoxMenu()
forward  menu FracMenu()
forward  proc CloseView()
forward  menu ClView()
forward  proc TerminateView(var integer h)
forward  proc TerminateView1(var string h)

//***************************************************************************************
//***************************************************************************************
//***************************************************************************************

/*******************************************************
   the commands "CopyFile" and "MkDir" are included in g32-versions newer than 4.0
********************************************************/
#if MY_EDITOR_VERSION  < 0x4100
 dll "<kernel32.dll>"
    integer proc CopyFile(string src:cstrval, string dst:cstrval, integer fail_if_exists) : "CopyFileA"
    integer proc CreateDirectory(string dir:cstrval, integer sa) :"CreateDirectoryA"
 end

 integer proc MkDir(string s)
    string path[_MAXPATH_] = RemoveTrailingSlash(s)
    return (CreateDirectory(path, 0))
 end
#endif

dll "<kernel32.dll>"
    integer proc TerminateProcess(integer h, integer rc)
end

#if MY_EDITOR_VERSION >= 0x4100
     proc mDos(string cmd, integer n)
                Dos(cmd,n)
     end
#endif

#if MY_EDITOR_VERSION < 0x4100                    // Not necessary for e32.exe where we
 #if WIN_VERSION == 2                             // could rely on the regular Dos()
     dll "<kernel32.dll>"                         // but this is just as easy
     integer proc AllocConsole()
     integer proc FreeConsole()
     integer proc SetConsoleTitle(string title:cstrval) : "SetConsoleTitleA"
     integer proc GetStdHandle(integer h)
     integer proc SetConsoleMode(integer h, integer mode)
     integer proc CloseHandle(integer h)
     integer proc WaitForSingleObject(integer h, integer m)
     integer proc ReadConsole(integer h, integer buf, integer n, var integer nrd, integer z):"ReadConsoleA"
     end

     dll "<user32.dll>"
     integer proc GetForegroundWindow()
     integer proc SetForegroundWindow(integer h)
     integer proc FindWindow(integer class, string t:cstrval) : "FindWindowA"
     integer proc SetActiveWindow(integer h)
     integer proc SetFocus(integer h)
     end

     constant STD_INPUT_HANDLE  =  (-10)
     constant INFINITE = 0xFFFFFFFF

     proc mDos(string cmd, integer n)
         string buf[255]=""
         integer kbd, hwnd, nrd

         if n == 0
                 AllocConsole()
                 kbd = GetStdHandle(STD_INPUT_HANDLE)
                 SetConsoleTitle(cmd)
                 hwnd = FindWindow(0, cmd)

                 Dos(cmd, _DONT_PROMPT_)

                 SetConsoleTitle("Press <enter> to Close the Console Window")

                 SetFocus(hwnd)
                 SetActiveWindow(hwnd)
                 SetForegroundWindow(hwnd)

                 ReadConsole(kbd, Addr(buf)+2, 10, nrd, 0)
                 CloseHandle(kbd)

                 FreeConsole()
         elseif n==1
                 Dos(cmd,1)
         else
                 ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
                 Warn("Invalid option in mDos for NT")
         endif
     end
 #endif
 #if WIN_VERSION == 9
    dll "<kernel32.dll>"
    integer proc AllocConsole()
    integer proc FreeConsole()
    integer proc SetConsoleTitle(string title:cstrval) : "SetConsoleTitleA"
    integer proc GetStdHandle(integer h)
    integer proc SetConsoleMode(integer h, integer mode)
    integer proc CloseHandle(integer h)
    integer proc WaitForSingleObject(integer h, integer m)
    end

    dll "<user32.dll>"
    integer proc GetForegroundWindow()
    integer proc SetForegroundWindow(integer h)
    end

    constant STD_INPUT_HANDLE  =  (-10)
    constant INFINITE = 0xFFFFFFFF

    proc mDos(string cmd, integer n)
        integer kbd, hwnd

        if n == 0
                AllocConsole()
                hwnd = GetForegroundWindow()
                SetConsoleTitle(cmd)
                Dos(cmd, _DONT_PROMPT_)
                SetForegroundWindow(hwnd)
                SetConsoleTitle("Press a key to Close the Console Window")
                kbd = GetStdHandle(STD_INPUT_HANDLE)
                SetConsoleMode(kbd, 0)
                WaitForSingleObject(kbd, INFINITE)
                CloseHandle(kbd)

                FreeConsole()
        elseif n==1
                Dos(cmd,0)
        else
                ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
                Warn("Invalid option in mDos for 9X")
            endif
        endif
    end
 #endif
#endif

#if WIN_VERSION == 2
 // these procs & variables are used by TSE2GSview
 dll "<user32.dll>"
 integer proc GetDesktopWindow()
 integer proc GetWindow(integer hwnd, integer cmd)
 integer proc _GetWindowText(integer hwnd, var string s:strptr, integer count) : "GetWindowTextA"
 integer proc SetForegroundWindow(integer hwnd)
 end

 #define GW_HWNDFIRST 0
 #define GW_HWNDLAST 1
 #define GW_HWNDNEXT 2
 #define GW_HWNDPREV 3
 #define GW_OWNER 4
 #define GW_CHILD 5
 #define GW_MAX 5
#endif

//***************************************************************************************
//***************************************************************************************
//***************************************************************************************

proc WriteSettings()
        WriteProfileStr(LxSctn, c_txpth, txpth, iniFileNameGS )
        WriteProfileStr(LxSctn, c_gsvw , gsview, iniFileNameGS )
        WriteProfileStr(LxSctn, c_psnup, psnup, iniFileNameGS )
        WriteProfileStr(LxSctn, c_gzip , gzip, iniFileNameGS )
        WriteProfileStr(LxSctn, c_tar  , tar, iniFileNameGS )
        WriteProfileStr(LxSctn, c_pkzip, pkzip, iniFileNameGS )
        WriteProfileStr(LxSctn, c_acdst, acdist, iniFileNameGS )
        WriteProfileStr(LxSctn, c_myhlp, myhelp, iniFileNameGS )
        WriteProfileStr(LxSctn, c_tb2ps, Str(tb2ps), iniFileNameGS )
end

proc GetSettings()
        txpth  = GetProfileStr(LxSctn, c_txpth, '\texmf\miktex\bin\', iniFileNameGS )
        gsview = GetProfileStr(LxSctn, c_gsvw , '\gsview\gsview32.exe', iniFileNameGS )
        psnup  = GetProfileStr(LxSctn, c_psnup, '\psnup.exe', iniFileNameGS )
        gzip   = GetProfileStr(LxSctn, c_gzip , '\gzip.exe', iniFileNameGS )
        tar    = GetProfileStr(LxSctn, c_tar  , '\tar.exe', iniFileNameGS )
        pkzip  = GetProfileStr(LxSctn, c_pkzip, '\pkzip25.exe', iniFileNameGS )
        acdist = GetProfileStr(LxSctn, c_acdst, '\AcroDist.exe', iniFileNameGS )
        myhelp = GetProfileStr(LxSctn, c_myhlp, '\latex.hlp', iniFileNameGS )
        tb2ps  = Val(GetProfileStr(LxSctn, c_tb2ps, Str(0), iniFileNameGS ) )
        if txpth == '\texmf\miktex\bin\'
            ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
            Configure()
        endif
end

string proc RtAl(string woord, integer n)
       return(iif(Length(woord)<n,woord,Chr(17)+woord[Length(woord)+2-n:Length(woord)]))
end

menu Options()
        Title = "LaTeX Macro Configuration"
        Width = 56
        History
        "Latex bin path  " [RtAl(txpth ,40):40], GetString(txpth ), _MF_Dont_Close_
        "GhostView       " [RtAl(gsview,40):40], GetString(gsview), _MF_Dont_Close_
        "Psnup           " [RtAl(psnup ,40):40], GetString(psnup ), _MF_Dont_Close_
        "GZip            " [RtAl(gzip  ,40):40], GetString(gzip  ), _MF_Dont_Close_
        "TAR             " [RtAl(tar   ,40):40], GetString(tar   ), _MF_Dont_Close_
        "PkZip           " [RtAl(pkzip ,40):40], GetString(pkzip ), _MF_Dont_Close_
        "Acrob. Distiller" [RtAl(acdist,40):40], GetString(acdist), _MF_Dont_Close_
        "My Helpfile     " [RtAl(myhelp,40):40], GetString(myhelp), _MF_Dont_Close_
        "TestBlock to PS " [OnOffStr(tb2ps):3] , Togglenr(tb2ps,0), _MF_Dont_Close_
end

proc PolishConfig()
     if RightStr(txpth,1) <> '\'
       txpth  = txpth  + '\'
     endif
     if lower(RightStr(gsview,4)) <> '.exe' gsview = gsview + '.exe' endif
     if lower(RightStr(psnup,4))  <> '.exe' psnup  = psnup  + '.exe' endif
     if lower(RightStr(gzip,4))   <> '.exe' gzip   = gzip   + '.exe' endif
     if lower(RightStr(tar,4))    <> '.exe' tar    = tar    + '.exe' endif
     if lower(RightStr(pkzip,4))  <> '.exe' pkzip  = pkzip  + '.exe' endif
     if lower(RightStr(acdist,4)) <> '.exe' acdist = acdist + '.exe' endif
end

proc Configure()
        // looping allows us to refresh after each change
        while Options()
              ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
              PolishConfig()
        endwhile
        // Alarm()
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        if MsgBox("","Save new settings ?",_OK_)
            WriteSettings()
        endif
        menu_history=20
end

menu LMenu()
    Title   = 'Latex Menu'
    history = menu_history
    'LaTe&X + DVI-view'                                , Latexcomp(3)        , _MF_Close_All_Before_     // X
    'L&aTeX  PS'                                      , Latexcomp(2)        , _MF_Close_All_Before_     // a
    'PS-vie&w'                                         , PSView()            , _MF_Close_All_Before_     // w
    '&LaTeX'                                           , Latexcomp(1)        , _MF_Close_All_Before_     // L
    'DVI-&view'                                        , DviView()           , _MF_Close_All_Before_     // v
    'Plain &TeX'                                       , Latexcomp(0)        , _MF_Close_All_Before_     // T
    '&Block or Slide'                                  , TestBlock()         , _MF_Close_All_Before_     // B
    'PSView Block/Sli&de'                              , PSViewBlock()       , iif(tb2ps,_MF_Close_All_Before_,_MF_GRAYED_|_MF_SKIP_)     // d
    ''                                                 ,                     , _MF_DIVIDE_
    'B&ibTeX'                                          , Bibtex()            , _MF_Close_All_Before_     // i
    'MakeI&ndex'                                       , MakeIndex()         , _MF_Close_All_Before_     // n
    'Make Nomenclat&ure'                               , MakeNomenc()        , _MF_Close_All_Before_     // u
    ''                                                 ,                     , _MF_Divide_
    'PS &Utilities '                                  , PSUtils()           , _MF_Dont_Close_           // g
    'DVI  &PS'                                        , Dvi2PS()            , _MF_Close_All_Before_     // P
    'PS   &zip,pdf,n pg/sht '                        , PSMenu()            , _MF_Dont_Close_           // z
    'P&S-file' [iif(Length(SplitPath(psfile,_EXT_))==3 , RtAl(psfile,19)+' ' , RtAl(psfile,20)):20]
                                                       , GetPsName()         , _MF_Dont_Close_           // S
    '&Mainfile'[RtAl(mainfile,20):20]                  , GetMFName()         , _MF_Dont_Close_           // M
    ''                                                 ,                     , _MF_Divide_
    '&Configuration'[latexversion:sizeof(latexversion)], Configure()         , _MF_Close_All_Before_     // C
    'TestBlock t&o PS'[OnOffStr(tb2ps):3]              , Togglenr(tb2ps, 21) , _MF_Close_After_          // o
    'P&rompt to read messages' [OnOffStr(prmpt):3]     , Togglenr(prmpt, 0)  , _MF_Dont_Close_           // r
    'C&lose viewers'[iif(gsviewh<>0 or yaph<>0 or gsviewhb<>0 or yaphb<>0 or gsviewh1[1]<>'',' X ',''):3]
                                                       , CloseView()         , _MF_Dont_Close_           // l
end  LMenu

proc LatexMenu()
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        while LMenu()
        endwhile
end

proc CloseView()
        while ClView()
        endwhile
end

menu ClView()
     Title = 'Close viewers'
     'PS  view &independent (e)ps files'  [OnOffStr(length(gsviewh1)):3], TerminateView1(gsviewh1)  , _MF_Dont_Close_
     '&PS  view postscript-file'          [OnOffStr(gsviewh):3]         , TerminateView(gsviewh)    , _MF_Dont_Close_
     '&DVI view LaTeX dvi-file'           [OnOffStr(yaph):3]            , TerminateView(yaph)       , _MF_Dont_Close_
     'P&S  view testblock/slide ps-file'  [OnOffStr(gsviewhb):3]        , TerminateView(gsviewhb)   , _MF_Dont_Close_
     'D&VI view testblock/slide dvi-file' [OnOffStr(yaphb):3]           , TerminateView(yaphb)      , _MF_Dont_Close_
end

proc TerminateView(var integer h)
        TerminateProcess(h,0)
        h = 0
end
proc TerminateView1(var string h)
     integer i
     for i = 1 to length(h)
       TerminateProcess(Asc(h[i]),0)
     endfor
     h = ''
end

proc IncMnfn()
     string s[_MAXPATH_]
     PushPosition()
     if Lower(CurrExt()) <> '.tex'
        MsgBox('',"No tex-extension ",_OK_)
     elseif lFind('^{ *}\\document','xig')
        MsgBox('','"\document" detected (no include file)',_OK_)
        PopPosition()
     elseif lFind('^{ *}\\begin\{document\}','xig')
        MsgBox('','"\begin{document}" detected (no include file)',_OK_)
        PopPosition()
     else
        if lFind('%_INCLUDE_FILE_OF_"\c','^xg')
          PushBlock()
          UnMarkBlock()
          MarkToEOL()
          if  MsgBox('','Overwrite old "%_INCLUDE_FILE_OF_'+GetMarkedText()+' ?',_OK_) <> 1
              Message('No change of "%_INCLUDE_FILE_OF_'+GetMarkedText())
              PopBlock()
              PopPosition()
              return()
          endif
          KillLine()
        endif
        s = UnQuote(PickFile("*.tex",_INSERT_PATH_))
        if Length(s)
           mainfile = QuotePath(s)
           BegFile()
           if mainfile[1] == '"'
              InsertLine('%_INCLUDE_FILE_OF_'+mainfile)
           else
              InsertLine('%_INCLUDE_FILE_OF_"'+mainfile+'"')
           endif
           KillPosition()
        endif
     endif
end

proc UpdStatus()
     Set(DateFormat,5)
     Set(DateSeparator,ASC("-"))
     if Lower(CurrExt()) <> '.tex'
        MsgBox('','No tex-extension ',_OK_)
     elseif lFind('^{ *}\\def\\status\{\c','xig')
            PushBlock()
            UnMarkBlock()
            MarkColumn(CurrLine(),CurrCol(),CurrLine(),CurrCol()+9)
            if  MsgBox('','Overwrite "\def\status{'+GetMarkedText()+'}" command?',_OK_) == 1
                InsertText(GetDateStr()+'}',_OVERWRITE_)
                ScrollToRow(CurrLine())
            else
                Message('No change of \def\status')
            endif
            PopBlock()
     else
            if  MsgBox('','Place "\def\status{'+GetDateStr()+'}" command?',_OK_) == 1
                if lFind('^{ *}\c\\document','xig')
                   Down()
                else
                   GotoLine(2)
                   BegLine()
                endif
                if PosFirstNonWhite()
                   Insertline()
                endif
                InsertText('\def\status{'+GetDateStr()+'}')
                ScrollToRow(CurrLine())
            else
                Message('No "\def\status{'+GetDateStr()+'}" command inserted')
            endif
     endif
end

proc MainPsFileNames()
     LogDrive(SplitPath(CurrFilename(),_DRIVE_))
     ChDir(SplitPath(CurrFilename(),_PATH_))
     PushPosition()
     case Lower(CurrExt())
       when '.tex','.dtx','.ins'
         if lFind('%_INCLUDE_FILE_OF_"\c','^xg')
            PushBlock()
            MarkChar()
            lFind('\c"','+x')
            mainfile = QuotePath(GetMarkedText())
            UnMarkBlock()
            Message('Include file of "'+mainfile+'"')
            PopBlock()
         else
            mainfile = QuotePath(CurrFilename())
         endif
         barename = QuotePath(SplitPath(mainfile,_DRIVE_|_NAME_))
         if psfnid <> GetBufferId()
            psfile   = QuotePath(barename + '.ps')
         else
            psfile   = psfn
         endif
//       menu_history = iif(Lower(CurrExt()) == '.tex', 2, 4) // reset to 2 = Latex+PS, 4 = Latex
       when '.eps','.ps'
         if psfnid <> GetBufferId()
            psfile   = QuotePath(SplitPath(CurrFilename(),_DRIVE_|_EXT_))
         else
            psfile   = psfn
         endif
         mainfile = ''
         menu_history = 3    //gs-view
       otherwise
         mainfile = ''
         psfile = ''
     endcase
     PopPosition()
end  MainPsFileNames

/********************************************************
  Prevent any _ON_CHANGING_FILES_ hooks from being run
  while we are busy.
 ********************************************************/
proc StopOnChangingFilesHook()
    BreakHookChain()
end

proc WhenLoaded()
     GetSettings()
     PolishConfig()
     Hook(_ON_CHANGING_FILES_, MainPsFileNames)
     Hook(_ON_EXIT_CALLED_, WhenExit)
     Hook(_ON_ABANDON_EDITOR_, WhenExit)
end  WhenLoaded

proc WhenExit()
     integer n = 1
     TerminateProcess(yaph, 0)
     TerminateProcess(gsviewh, 0)
     for n = 1 to length(gsviewh1)
          TerminateProcess(Asc(gsviewh1[n]), 0)
     endfor
     TerminateProcess(gsviewhs, 0)
     TerminateProcess(yaphb, 0)
     TerminateProcess(gsviewhb, 0)
     EraseDiskFile(tbpath+'.tex')
     EraseDiskFile(tbpath+'.dvi')
     EraseDiskFile(tbpath+'.ps')
     EraseDiskFile(tbpath+'.pdf')
     EraseDiskFile(tbpath+'.log')
     EraseDiskFile(tbpath+'.llg')
     EraseDiskFile(tbpath+'.aux')
     EraseDiskFile(tbpath+'.idx')
     EraseDiskFile(tbpath+'.ind')
     EraseDiskFile(tbpath+'.ilg')
     EraseDiskFile(tbpath+'.toc')
     EraseDiskFile(tbpath+'.bbl')
     EraseDiskFile(tbpath+'.blg')
     EraseDiskFile(tbpath+'.tmp')
     EraseDiskFile(tbpath+'.pfg')
end  WhenExit

integer proc TestOnLatex(integer w)
     integer result = 1
     if (lower(CurrExt()) in '.tex','.dtx')
        PushPosition()
        BegFile()
        if  lFind('\document','')
            if not (GetText(CurrPos()+9,5) in 'class', 'style')
               iif(w,MsgBox('','Has no style or class ...',_OK_),0)
               result = 0
            endif
        elseif lFind('%_INCLUDE_FILE_OF_"\c','^xg')
               iif(w,MsgBox('','apparently Latex ...',_OK_),0)
        else
            iif(w,MsgBox('','No \document ...',_OK_),0)
            result = 0
        endif
        PopPosition()
     else
          iif(w,MsgBox('','No .tex extension ...',_OK_),0)
          result = 0
     endif
     return (result)
end  TestOnLatex

proc GetNumber(var integer n, integer m)
     string s[5] = Str(n)
     if Read(s)
        n = Val(s)
     endif
     psu_history = m
     menu_history = 14
end  GetNumber

proc GetString(var string s)
     string ss[_MAXPATH_] = s
     if Read(ss)
        s = ss
     endif
end  GetString

/********************* GetPgPs-number Routines ***************************/
constant   ClrW = Color(Black on White)  // window

proc PgPsPaintStatus()
    PutAttr(ClrW,3)
    GotoXY(1,GetPgPsLine)
    PutAttr(Color(Bright Yellow on Red),3)
    GotoXY(1,GetPgPsLine)
end

proc PgPsPaintChart(integer n)
      GotoXY(2,0)    if n PutStr("R")   else PutStr("L")                endif
      GotoXY(1,1)    if n PutStr(" 1 ") else GotoXY(1,1)  PutStr(" 1 ") endif
      GotoXY(1,2)    if n PutStr(" 2 ") else GotoXY(1,2)  PutStr("-2 ") endif
      GotoXY(1,3)    if n PutStr(" 3 ") else GotoXY(1,3)  PutStr("-3 ") endif
      GotoXY(1,4)    if n PutStr(" 4 ") else GotoXY(1,4)  PutStr("-4 ") endif
      GotoXY(1,5)    if n PutStr(" 6 ") else GotoXY(1,5)  PutStr("-6 ") endif
      GotoXY(1,6)    if n PutStr(" 8 ") else GotoXY(1,6)  PutStr("-8 ") endif
      GotoXY(1,7)    if n PutStr(" 9 ") else GotoXY(1,7)  PutStr("-9 ") endif
      GotoXY(1,8)    if n PutStr(" 10") else GotoXY(1,8)  PutStr("-10") endif
      GotoXY(1,9)    if n PutStr(" 12") else GotoXY(1,9)  PutStr("-12") endif
      GotoXY(1,10)   if n PutStr(" 14") else GotoXY(1,10) PutStr("-14") endif
      GotoXY(1,11)   if n PutStr(" 15") else GotoXY(1,11) PutStr("-15") endif
      GotoXY(1,12)   if n PutStr(" 16") else GotoXY(1,12) PutStr("-16") endif
      GotoXY(1,13)   if n PutStr(" 18") else GotoXY(1,13) PutStr("-18") endif
      GotoXY(1,14)   if n PutStr(" 20") else GotoXY(1,14) PutStr("-20") endif
      GotoXY(1,15)   if n PutStr(" 21") else GotoXY(1,15) PutStr("-21") endif
      GotoXY(1,16)   if n PutStr(" 24") else GotoXY(1,16) PutStr("-24") endif
      GotoXY(1,17)   if n PutStr(" 25") else GotoXY(1,17) PutStr("-25") endif
      GotoXY(1,18)   if n PutStr(" 27") else GotoXY(1,18) PutStr("-27") endif
      GotoXY(1,19)   if n PutStr(" 28") else GotoXY(1,19) PutStr("-28") endif
    GotoXY(1,GetPgPsLine)
end

integer proc PgPsLoop()
    integer CurY, Sgn = (pgps > 0)
    loop
        PgPsPaintStatus()
        case GetKey()
            when <Enter>       case GetPgPsLine
                                    when 1  CurY = 1
                                    when 2  CurY = 2
                                    when 3  CurY = 3
                                    when 4  CurY = 4
                                    when 5  CurY = 6
                                    when 6  CurY = 8
                                    when 7  CurY = 9
                                    when 8  CurY = 10
                                    when 9  CurY = 12
                                    when 10 CurY = 14
                                    when 11 CurY = 15
                                    when 12 CurY = 16
                                    when 13 CurY = 18
                                    when 14 CurY = 20
                                    when 15 CurY = 21
                                    when 16 CurY = 24
                                    when 17 CurY = 25
                                    when 18 CurY = 27
                                    when 19 CurY = 28
                                 endcase
                               CurY = iif(CurY>1,iif(Sgn,CurY,-CurY),1)
                               break
            when <Escape>      CurY = 0
                               break
            when <CursorUp>    GetPgPsLine=iif(GetPgPsLine==1,19,GetPgPsLine-1)
            when <CursorDown>  GetPgPsLine=iif(GetPgPsLine==19,1,GetPgPsLine+1)
            when <PgDn>        GetPgPsLine = 19
            when <PgUp>        GetPgPsLine = 1
            when <CursorLeft>,<L>,<l>,<->,<Grey->
                               Sgn = 0   PgPsPaintChart(0)
            when <CursorRight>,<R>,<r>,<+>,<Grey+>
                               Sgn = 1   PgPsPaintChart(1)
            when <Spacebar>    Sgn=iif(Sgn,0,1) PgPsPaintChart(Sgn)
        endcase
    endloop
    return(CurY)
end

proc PgPsInit()
     integer     WinL, WinT

     case abs(pgps)
          when 1  GetPgPsLine = 1
          when 2  GetPgPsLine = 2
          when 3  GetPgPsLine = 3
          when 4  GetPgPsLine = 4
          when 6  GetPgPsLine = 5
          when 8  GetPgPsLine = 6
          when 9  GetPgPsLine = 7
          when 10 GetPgPsLine = 8
          when 12 GetPgPsLine = 9
          when 14 GetPgPsLine = 10
          when 15 GetPgPsLine = 11
          when 16 GetPgPsLine = 12
          when 18 GetPgPsLine = 13
          when 20 GetPgPsLine = 14
          when 21 GetPgPsLine = 15
          when 24 GetPgPsLine = 16
          when 25 GetPgPsLine = 17
          when 27 GetPgPsLine = 18
          when 28 GetPgPsLine = 19
     endcase

     WinL = min(38 + (CurrPos() - CurrXoffset())/2, Query(ScreenCols)-4)
     WinT = min( 5 + CurrRow()/2 , Query(ScreenRows)-22)
     ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
     if not PopWinOpen(WinL,WinT,WinL+4,WinT+20,4,"ñ",ClrW)
         ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
         Warn("Error opening popup window")
         Alarm()
         halt
     endif
     Set(Cursor,OFF)
     Set(Attr,ClrW)
     PgPsPaintChart(pgps > 0)
end

proc PgPsDone( integer CurY )
     PopWinClose()
     Set(Cursor,ON)
     if CurY <> 0
         pgps = CurY
     endif
end

proc GetPgPs()
     PgPsInit()
     PgPsDone(PgPsLoop())
     psu_history = 3
     menu_history = 14
end

/************************************************/

proc GetPsName()
     string s[_MAXPATH_] = psfile
     if not (Ask('PS-file name',s) and Length(s))
        s = UnQuote(PickFile('*.ps*',_INSERT_PATH_))
        if Length(s)==0
           if mainfile==''
               return()
           endif
           s = Format(SplitPath(mainfile,_DRIVE_|_NAME_),'.ps')
           if not Ask('PS-file name',s)
              return()
           endif
        endif
     endif
     psfile = QuotePath(s)
     if s == Format(SplitPath(mainfile,_DRIVE_|_NAME_),'.ps')
          psfnid = 0
          psfn   = ''
     else
          psfn   = psfile
          psfnid = GetBufferId()
     endif
end  GetPsName

proc GetMFName()
     string s[_MAXPATH_] = mainfile
     if not (Ask('Mainfile name',s) and Length(s))
        s = UnQuote(PickFile('*.tex',_INSERT_PATH_))
        if Length(s)==0
           if psfile==''
               return()
           endif
           s = SplitPath(psfile,_DRIVE_|_NAME_)+'.tex'
           if not Ask('Mainfile name',s)
              return()
           endif
        endif
     endif
     mainfile = QuotePath(s)
end  GetMFName

string proc OnOffStr(integer i)
     return (iif(i, 'On', 'Off'))
end  OnOffStr

proc ToggleNr(var integer n , integer m)
     n = not n
     if m
        menu_history = m
     endif
end  ToggleNr

proc ToggleNru(var integer n , integer m)
     n = not n
     if m
        psu_history = m
        menu_history = 14
     endif
end  ToggleNru

proc mChDirCurrFile()
     if (SplitPath(ExpandPath(''),_DRIVE_|_PATH_) <> SplitPath(CurrFileName(),_DRIVE_|_PATH_))
        LogDrive(SubStr(SplitPath(CurrFilename(), _DRIVE_),1,1))
        ChDir(SplitPath(CurrFilename(), _PATH_))
     endif
end  mChDirCurrFile

//string proc UnQuote(string ss)
//     string s[_MAXPATH_] = ss
//     s = QuotePath(s)
//     if s[1]=='"'
//        s = s[2:Length(s)-2]
//     endif
//     return(s)
//end

string proc UnQuote(string ss)
     return(SplitPath(ss,_DRIVE_|_EXT_))
end

integer proc Latexcomp(integer latex_type)
//   latex_type = 0 : Tex           history = 6
//                1 : Latex         history = 4
//                2 : Latex + PS    history = 2
//                3 : Latex + view  history = 1
//                4 : Testblock     history = 7
     string cmdl[_MAXPATH_], texfn[_MAXPATH_], logfn[_MAXPATH_]
     integer cid = GetBufferId(), tid
     Set(Marking,Off)
     case latex_type
        when 0 menu_history = 6     //Tex
        when 1 menu_history = 4     //Latex
        when 2 menu_history = 2     //Latex+Ps
        when 3 menu_history = 1     //Latex + dvi-view
     endcase
     mChDirCurrFile()
     if FileChanged()
        if (FileExists(CurrFileName()) and not overwr)
           if not MsgBox('','Overwrite ?',_OK_)
              return(1)
           endif
           overwr = ON
        endif
        if not SaveFile()
           return(1)
        endif
     endif
     if  mainfile == '' or not FileExists(mainfile)
         MsgBox('','No mainfile ...',_OK_)
         return(1)
     endif
     Hook(_ON_CHANGING_FILES_, StopOnChangingFilesHook)
     EditFile(mainfile)
     mChDirCurrFile()
     texfn = mainfile
     logfn = QuotePath(barename + '.log')
     AbandonFile(GetBufferId(logfn))
     if latex_type == 0
          cmdl = QuotePath(txpth + tx) + ' ' + QuotePath(texfn)
          mDos(cmdl, iif(prmpt,0,1))
          menu_history = 5     //DviView
          if FileExists(logfn)
             if FileExists(barename+'.tlg')
                EraseDiskFile(barename+'.tlg')
             endif
             RenameDiskFile(logfn, barename+'.tlg')
          endif
     else
       if TestOnLatex(1)
          cmdl = QuotePath(txpth + ltx) + ' ' + QuotePath(texfn)
          mDos(cmdl, iif(prmpt,0,1))
          tid = CreateTempBuffer()
          LoadBuffer(logfn)
          if lFind('LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right.','g')
             mDos(cmdl, iif(prmpt,0,1))
             GotoBufferId(tid)
             LoadBuffer(logfn)
             if lFind('LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right.','g')
                mDos(cmdl, iif(prmpt,0,1))
                GotoBufferId(tid)
                LoadBuffer(logfn)
                if lFind('LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right.','g')
                   mDos(cmdl, iif(prmpt,0,1))
                endif
             endif
          endif
          if FileExists(logfn)
             if FileExists(barename+'.llg')
                EraseDiskFile(barename+'.llg')
             endif
             RenameDiskFile(logfn, barename+'.llg')
          endif
          if lFind('LaTeX Warning: There were undefined references.','g')
                Message('LaTeX Warning: There were undefined references.')
          endif
          EndFile()
          if lFind('No pages of output.','cg') or lFind('? x','^b')
             Message('No pages of output.')
             AbandonFile(tid)
             GotoBufferId(cid)
             mChDirCurrFile()
             UnHook(StopOnChangingFilesHook)
             return(0)
          endif
          AbandonFile(tid)
          case latex_type
             when 1   menu_history = 5     //DviView
             when 2   Dvi2PS()
                      menu_history = iif(gsviewh,2,3)  // 2=Latex+Ps, 3=GsView
             when 3   DviView()
                      menu_history = 1     //Latex + dvi-view
          endcase
       endif
     endif
     if GotoBufferId(GetBufferId(barename+'.llg'))
        ReplaceFile(barename+'.llg',_OVERWRITE_)
     endif
     GotoBufferId(cid)
     mChDirCurrFile()
     UnHook(StopOnChangingFilesHook)
     case latex_type
          when 0,1
             return(iif(yaph==0,1,0))
          when 2
            return(iif(gsviewh==0,1,0))
          when 3
            return(0)
          when 4
            return(1)
     endcase
     return(0)        // to keep sc happy
end  Latexcomp

integer proc PSView()
     if FileExists(gsview)
        if     psfile == '' or Lower(SplitPath(psfile,_EXT_)) == ".eps"
               mChDirCurrFile()
               if FileChanged() & FileExists(CurrFileName())
                  if not overwr
                    if not MsgBox('','Overwrite ?',_OK_)
                       return(1)
                    endif
                    overwr = ON
                  endif
                  if not SaveFile()
                     return(1)
                  endif
               endif
               gsviewh1[length(gsviewh1)+1] = Chr(lDos(gsview,QuotePath(CurrFileName()),_DONT_WAIT_|_RUN_DETACHED_|_RETURN_PROCESS_HANDLE_))

               menu_history = 3    //gs-view
        elseif FileExists(psfile)
               if gsviewh <> 0
                  TerminateProcess(gsviewh, 0)
               endif
               gsviewh  = lDos(gsview,QuotePath(psfile),_DONT_WAIT_|_RUN_DETACHED_|_RETURN_PROCESS_HANDLE_)
               menu_history = iif(Lower(CurrExt()) == '.tex',2,3) // 2 = Latex+PS, 3 = gs-view
        elseif FileExists(psfile+'.gz')
               if not MsgBox('','View gzipped file "'+Splitpath(psfile,_NAME_|_EXT_)+'.gz" ?',_OK_)
                  return(1)
               endif
               if gsviewh <> 0
                  TerminateProcess(gsviewh, 0)
               endif
               gsviewh  = lDos(gsview,QuotePath(psfile+'.gz'),_DONT_WAIT_|_RUN_DETACHED_|_RETURN_PROCESS_HANDLE_)
               menu_history = 2    //Latex+Ps
        else   MsgBox('','No ps or eps-file ...',_OK_)
               menu_history = 3    //gs-view
               return(1)
        endif
     else
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        MsgBox('',gsview+ ' not found',_OK_)
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Configure()
        return(1)
     endif
     return(0)
end  PSView

integer proc PSViewBlock()
     string tbps[_MAXPATH_] = QuotePath(SplitPath(barename,_DRIVE_|_PATH_)+tb+'.ps')
     if FileExists(gsview)
        if FileExists(tbps)
               if gsviewhb <> 0
                  TerminateProcess(gsviewhb, 0)
               endif
               gsviewhb = lDos(gsview,tbps,_DONT_WAIT_|_RUN_DETACHED_|_RETURN_PROCESS_HANDLE_)
               menu_history = 7 // 7 = Block or Slide
        else
               MsgBox('','No '+tbps+'-file ...',_OK_)
               menu_history = 7 // 7 = Block or Slide
               return(1)
        endif
     else
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        MsgBox('',gsview+ ' not found',_OK_)
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Configure()
     endif
     return(0)
end  PSViewBlock

menu PSMenu()
    title = 'Process Postscript'
    history = ps_history
    command = PushKey(<Escape>)
    'PS   pd&f   (.pdf)   ', PS2PDF()   , _MF_Dont_Close_  // f
    'PS   &GZip  (.ps.gz) ', PS2GZ()    , _MF_Dont_Close_  // G
    'PS   PK&Zip (.ps.zip ', PS2PKZ()   , _MF_Dont_Close_  // Z
    'PS   PS&NUP (.ps.nup)', PS2PSNUP() , _MF_Dont_Close_  // N
    'Distiller &Config'     , DistCFG()  , _MF_Dont_Close_  // C
    'GZip,&Tar,PkZip menu'  , Zipmenu()  , _MF_Dont_Close_  // T
end  PSMenu

menu PSUtils()
    title = 'Postscript Utilities'
    history = psu_history
    command = PushKey(<Escape>)
    'Begin pa&ge (PS only)'[StartPage:5]               , GetNumber(StartPage,1) , _MF_Dont_Close_           // g
    '&Nr(+)/last(-) page'  [NmrOfPage:5]               , GetNumber(NmrOfPage,2) , _MF_Dont_Close_           // N
    'Pages per s&heet (-+)'     [pgps:5]               , GetPgPs()              , _MF_Dont_Close_           // h
    'Pages with border    ' [OnOffStr(pgpsborder):5]   , ToggleNRu(pgpsborder,4), _MF_Dont_Close_           // h
end  PSUtils

proc PS2PDF()
     if FileExists(acdist)
        if    FileExists(psfile)
              lDos(acdist,QuotePath(ExpandPath(psfile)),_RUN_DETACHED_|_DONT_WAIT_|_DONT_PROMPT_)
        else
              MsgBox('','No ps-file ...',_OK_)
        endif
        menu_history=2
     else
           ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
           MsgBox('',acdist+ ' not found',_OK_)
           ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
           Configure()
     endif
     ps_history = 1
end  PS2PDF

proc DistCFG()
     if FileExists(acdist)
        lDos(acdist,'',_DONT_PROMPT_|_DONT_WAIT_|_RUN_DETACHED_)
        ps_history = 1
     else
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        MsgBox('',acdist+ ' not found',_OK_)
        ps_history = 5
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Configure()
     endif
     menu_history=19
end  DistCFG

proc PS2GZ()
     if FileExists(gzip)
        mChDirCurrFile()
        if    FileExists(psfile)
              if CopyFile(UnQuote(psfile), Format(UnQuote(psfile),".tmp"), TRUE)
                lDos(gzip,"-f "+QuotePath(psfile),1)
                if not RenameDiskFile(Format(UnQuote(psfile),".tmp"),UnQuote(psfile))
                   ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
                   Warn("No rename tmp-file possible")
                endif
              else
                if MsgBox("","No copy ps-file possible. GZip "+psfile+" anyway?",_YES_NO_CANCEL_)==1
                   lDos(gzip,"-f "+QuotePath(psfile),1)
                endif
              endif
        else
              MsgBox('','No ps-file ...',_OK_)
        endif
        menu_history=2
     else
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        MsgBox('',gzip+ ' not found',_OK_)
        Configure()
     endif
     ps_history = 2
end  PS2GZ

proc PS2PKZ()
     if FileExists(pkzip)
        if    FileExists(psfile)
              lDos(pkzip,'-add '+QuotePath(UnQuote(psfile)+'.zip')+' '+QuotePath(psfile),1)
        else
              MsgBox('','No ps-file ...',_OK_)
        endif
        menu_history=2
     else
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        MsgBox('',pkzip+ ' not found',_OK_)
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Configure()
     endif
     ps_history = 3
end  PS2PKZ

proc PS2PSNUP()
     string cmpfn[255]
     if FileExists(psnup)
        if    FileExists(psfile)
            if pgpsborder
                cmpfn = iif(pgps<0,'-l ','   ')+'-m1cm -b1mm -d -'+Str(abs(pgps))+' '+QuotePath(psfile)+' '+QuotePath(UnQuote(psfile)+'.nup')
                lDos(psnup,cmpfn,1)
            else
              if pgps<>1
                  cmpfn = iif(pgps<0,'-l ','   ')+'-m1cm -'+Str(abs(pgps))+' '+QuotePath(psfile)+' '+QuotePath(UnQuote(psfile)+'.nup')
                  lDos(psnup,cmpfn,1)
              endif
            endif
            menu_history = 3    //gs-view
        else  MsgBox('','No ps-file ...',_OK_)
        endif
        menu_history=2
     else
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        MsgBox('',psnup+ ' not found',_OK_)
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Configure()
     endif
     ps_history = 4
end  PS2PSNUP

menu ZipMenu()
//    title = 'GZip and PkZip'
    history = zip_history
    command = PushKey(<Escape>)
    '&GZip     *.gz  ', F2GZ()    , _MF_Dont_Close_     // G
    '&Un-GZip  *     ', F2UGZ()   , _MF_Dont_Close_     // U
    '&PKZip    *.zip ', F2PKZ()   , _MF_Dont_Close_     // P
    'U&n-PKZip *     ', F2UPKZ()  , _MF_Dont_Close_     // N
    '&TAR      *.tar ', F2TAR()   , _MF_Dont_Close_     // P
    'U&n-TAR   *     ', F2UTAR()  , _MF_Dont_Close_     // N
end  ZipMenu

proc F2GZ()
     string fn[_MAXPATH_], fntmp[_MAXPATH_]
     if FileExists(gzip)
          fn = UnQuote(PickFile('*.*',_INSERT_PATH_))
          while Length(fn)
             fntmp = Format(fn,".tmp")
             if MsgBox("","GZip "+fn+" ?",_YES_NO_CANCEL_)==1
                if CopyFile(fn, fntmp, TRUE)
                   lDos(gzip,"-f "+QuotePath(fn),1)
                   RenameDiskFile(fntmp,fn)
                else
                  if MsgBox("","No copy file possible. GZip "+fn+" anyway?",_YES_NO_CANCEL_)==1
                     lDos(gzip,"-f "+QuotePath(fn),1)
                  endif
                endif
             endif
             fn = UnQuote(PickFile("*.*",_INSERT_PATH_))
          endwhile
          zip_history = 1
     else
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        MsgBox('',gzip+ ' not found',_OK_)
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Configure()
     endif
end  F2GZ

proc F2UGZ()
     string fn[_MAXPATH_], fntmp[_MAXPATH_]
     if FileExists(gzip)
          fn = UnQuote(PickFile('*.*',_INSERT_PATH_))
          while Length(fn)
             fntmp = Format(fn,".tmp")
             if MsgBox("","Un-GZip "+fn+" ?",_YES_NO_CANCEL_)==1
                if CopyFile(fn, fntmp, TRUE)
                   lDos(gzip,"-d "+QuotePath(fn),_RETURN_CODE_)
                   if DosIOResult()==0
                       RenameDiskFile(fntmp,fn)
                   else      // this is when gzip failed and tmp-file is (why?) blocked
                       EraseDiskFile(fntmp)
                   endif
                else
                  if MsgBox("","No copy file possible. Un-GZip "+fn+" anyway?",_YES_NO_CANCEL_)==1
                     lDos(gzip,"-df "+QuotePath(fn),1)
                  endif
                endif
             endif
             fn = UnQuote(PickFile("*.*",_INSERT_PATH_))
          endwhile
          zip_history = 2
     else
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        MsgBox('',gzip+ ' not found',_OK_)
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Configure()
     endif
end  F2UGZ

proc F2PKZ()
     string fn[_MAXPATH_], fnzip[_MAXPATH_]
     if FileExists(pkzip)
          fn = UnQuote(PickFile('*.*',_INSERT_PATH_))
          while Length(fn)
             fnzip = Format(fn,".zip")
             if MsgBox("","PkZip "+fn+" ?",_YES_NO_CANCEL_)==1
                lDos(pkzip,'-add '+QuotePath(fnzip)+' '+QuotePath(fn),1)
             endif
             fn = UnQuote(PickFile("*.*",_INSERT_PATH_))
          endwhile
          zip_history = 3
     else
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        MsgBox('',pkzip+ ' not found',_OK_)
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Configure()
     endif
end  F2PKZ

proc F2UPKZ()
     string fn[_MAXPATH_]
     if FileExists(pkzip)
          fn = PickFile('*.*',_INSERT_PATH_)
          while Length(fn)
             if MsgBox('','Un-PkZip '+fn+' ?',_YES_NO_CANCEL_)==1
                lDos(pkzip,'-extract '+QuotePath(fn),1)
             endif
             fn = PickFile('*.*',_INSERT_PATH_)
          endwhile
          zip_history = 4
     else
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        MsgBox('',pkzip+ ' not found',_OK_)
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Configure()
     endif
end  F2UPKZ

proc F2TAR()
     string fn[_MAXPATH_], tardr[1], tarfn[_MAXPATH_], tarpth[_MAXPATH_], tmpdir[_MAXPATH_], tmpfn[_MAXPATH_], lst[_MAXPATH_]
     integer p, msglevel
     if FileExists(tar)
          fn = UnQuote(PickFile('*.*',_INSERT_PATH_))
          while Length(fn)
             tardr  = SplitPath(fn,_DRIVE_)
             tarpth = SplitPath(fn,_PATH_)
             tarfn  = RemoveTrailingSlash(CurrDir())
             p = Pos("\",tarfn)
             while p
                   tarfn = tarfn[p+1:Length(tarfn)]
                   p     = Pos("\",tarfn)
             endwhile
             tarfn = QuotePath(Format(tarfn,".tar"))
             if MsgBox("",'TAR all files + subdirs from present directory into '+tarfn+' ?',_YES_NO_CANCEL_)==1
                if FileExists(tarfn)
                   MsgBox('',tarfn +' already exists',_OK_)
                else
                   tmpdir = GetEnvStr("TEMP")
                   if tmpdir == ""
                      tmpdir = GetEnvStr("TMP")
                      if tmpdir == ""
                         tmpdir = CurrDir()
                      endif
                   endif
                   tmpfn = QuotePath(MakeTempName(tmpdir))
                   Dos(Format('dir /B .* >', tmpfn), _DONT_PROMPT_|_TEE_OUTPUT_)
                   PushPosition()
                   if EditFile(tmpfn)
                      msglevel = Set(MsgLevel, _WARNINGS_ONLY_)
                      KillFile()
                      Set(MsgLevel, msglevel)
                      BegFile() EndLine() Right()
                      while JoinLine()
                            EndLine()
                            Right()
                      endwhile
                      BegLine()
                      MarkToEOL()
                      lst = GetMarkedText()
                      AbandonFile()
                   else
                      lst = ""
                      MsgBox('','auxiliary file not created',_OK_)
                   endif
                   PopPosition()
                   LogDrive(tardr)
                   Chdir(tarpth)
                   lDos(tar,' cvf '+ tarfn +' * '+lst,1)          // note: lst is list of files of the type ".*"
                endif
             endif
             fn = UnQuote(PickFile("*.*",_INSERT_PATH_))
          endwhile
          zip_history = 5
     else
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        MsgBox('','"'+tar+'" not found',_OK_)
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Configure()
     endif
end  F2TAR

proc F2UTAR()
     string fn[_MAXPATH_], s[_MAXPATH_]
     integer mkd
     if FileExists(tar)
          fn = PickFile('*.*',_INSERT_PATH_)
          while Length(fn)
           if lower(SplitPath(fn,_EXT_))==".tar"
             s = SplitPath(fn,_DRIVE_|_NAME_)
             if MsgBox('','UnTAR '+QuotePath(fn)+' into directory '+QuotePath(s)+' ?',_YES_NO_CANCEL_)==1
                if (FileExists(s) & _DIRECTORY_)
                   if MsgBox('',QuotePath(s) +' already exists: cancel UnTAR?',_YES_NO_)==2
                     ChDir(s)
                     lDos(tar,'-xf '+QuotePath(fn),1)
                   endif
                else
                   mkd = MkDir(s)
                   if not mkd
                       ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
                       Warn('','Failed to create directory '+ QuotePath(s))
                   else
                       ChDir(s)
                       lDos(tar,'-xf '+ QuotePath(fn),1)
                   endif
                endif
             endif
           else
             MsgBox('','no "tar"-extension',_OK_)
           endif
           fn = PickFile('*.*',_INSERT_PATH_)
          endwhile
          zip_history = 6
     else
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        MsgBox('',tar+ ' not found',_OK_)
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Configure()
     endif
end  F2UTAR

/*********************************************/


integer proc DviView()
     string dvifn[_MAXPATH_]
     mChDirCurrFile()
     dvifn = QuotePath(SplitPath(mainfile,_DRIVE_|_NAME_)+'.dvi')
     if FileExists(dvifn)
        if yaph <> 0
           TerminateProcess(yaph, 0)
        endif
        yaph = lDos(txpth+view,dvifn,_RUN_DETACHED_|_DONT_WAIT_|_RETURN_PROCESS_HANDLE_)
        menu_history = iif(TestOnLatex(0),4,6)  // 4 = Latex, 6=Tex
     else
       MsgBox('','No dvi-file ...',_OK_)
       menu_history = 5
       return(1)
     endif
     return(0)
end  DviView

proc Dvi2PS()
     string psfn[255], dvifn[_MAXPATH_]
     integer cid = GetBufferId()
     if FileExists(mainfile)
     EditFile(mainfile)
     mChDirCurrFile()
     dvifn = QuotePath(SplitPath(mainfile,_DRIVE_|_NAME_)+'.dvi')
     if FileExists(dvifn)
       if (StartPage==1 and NmrOfPage==0)
          psfn = QuotePath(txpth+dv2ps)+' -o '+QuotePath(psfile)+' '+ dvifn
       else
          psfn = QuotePath(txpth+dv2ps)+' -p ='+Format(StartPage:-3)+iif(NmrOfPage>0,' -n',' -l =')+Format(abs(NmrOfPage):-3)+' -o '+QuotePath(psfile)+' '+ dvifn
          // note that the full command may become too long if the path length is (typically) > 80
          // this may be relieved by using lDos and split txtpth+dv2ps from the rest
       endif
       if length(psfn)==255
          ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
          Warn("Note: "+psfn+ "may be incomplete")
       endif
       mDos(psfn,iif(prmpt,0,1))
       if pgps<>1 or pgpsborder
           PS2PSNUP()
           EraseDiskFile(psfile)
              RenameDiskFile(Format(UnQuote(psfile)+".nup"),UnQuote(psfile))
       endif
       menu_history = 3    //gs-view
     else
       MsgBox('','No dvi-file ...',_OK_)
          menu_history = 15    //dvi2ps
        endif
        GotoBufferId(cid)
        mChDirCurrFile()
     else
        MsgBox('','No mainfile ...',_OK_)
        menu_history = 15    //dvi2ps
     endif
     gsviewh = iif(TSE2GSview(Splitpath(psfile,_NAME_|_EXT_)),gsviewh,0)
end  Dvi2PS

/*
  The following routine (due to Sammy Mitchell) switches from tse to GSview, where it is
  assumed that GSview always has "GSview" somewhere in the title and that no other windows do.
*/

string proc GetWindowText(integer hwnd)
 string s[255] = Format("":sizeof(s):Chr(0))
 integer len = _GetWindowText(hwnd, s, sizeof(s))
 return (iif(len > 0, s[1:Pos(Chr(0), s) - 1], ""))
end

integer proc FindWindowTitle(string title)
 integer hwnd, top_hwnd = GetDesktopWindow()
 hwnd = GetWindow(top_hwnd, GW_CHILD)
 while hwnd
  if Pos(title, GetWindowText(hwnd))
   return (hwnd)
  endif
  hwnd = GetWindow(hwnd, GW_HWNDNEXT)
 endwhile
 return (0)
end

integer proc TSE2GSview(string fn)
 integer hw
 hw = FindWindowTitle(fn+" - GSview")
 if hw
  SetForegroundWindow(hw)
  return(1)
// else
//  ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
//  Warn("GSview not found")
//  return(0)
 endif
 return(0)  // to keep sc happy
end

/***************************************************/

proc BibTex()
     integer cid = GetBufferId()
     if FileExists(mainfile)
        EditFile(mainfile)
        mChDirCurrFile()
        AbandonFile(GetBufferId(QuotePath(barename+'.blg')))
        mDos(QuotePath(txpth + bibtx)+' '+QuotePath(barename), iif(prmpt,0,1))
     else
        MsgBox('','No tex-file ...',_OK_)
     endif
     menu_history = 10         //BibTex
     GotoBufferId(cid)
end  BibTex

proc MakeIndex()
     mChDirCurrFile()
     if FileExists(mainfile)
        AbandonFile(GetBufferId(QuotePath(barename+'.ilg')))
        mDos(QuotePath(txpth+mkindx)+' '+QuotePath(barename),iif(prmpt,0,1))
     else
        MsgBox('','No tex-file ...',_OK_)
     endif
     menu_history = 11         //MakeIndex
end  MakeIndex

proc MakeNomenc()
     mChDirCurrFile()
     if FileExists(mainfile)
        AbandonFile(GetBufferId(QuotePath(barename+'.ilg')))
        mDos(QuotePath(txpth+mkindx)+' '+QuotePath(barename+'.glo')+' -s nomencl.ist -o '+QuotePath(barename+'.gls'),iif(prmpt,0,1))
     else
        MsgBox('','No tex-file ...',_OK_)
     endif
     menu_history = 12         //MakeNomenclature
end  MakeNomenc

/***********
 Testblock: copies block or slide-environment to an auxiliary tex-file, adds leader and
            trailer, and compiles and views.
 ***********/
integer proc TestBlock()
     string tmpnm[_MAXPATH_], tmpbr[_MAXPATH_], cmdnm[255]
     integer cid  = GetBufferid(), mid, tid, cclp, tclp, texres, pg = StartPage, bi, bp, sl = OFF

     menu_history = 7

     if (SplitPath(CurrFilename(),_NAME_) <> tb)

       tbpath = SplitPath(mainfile,_DRIVE_|_PATH_)+tb

       Set(Marking,Off)
       PushBlock()
       PushPosition()
       EndLine()
       if lower(CurrExt())=='.tex' and lFind('^[~%]?\\begin\{slide','bix')     //check if we have a slide
          MarkLine()
          if lFind('^[~%]?\\end\{slide','ix+')
             MarkLine()
             Set(Marking,Off)   // we have a slide, slide is now marked
             sl = ON
          else
             UnMarkBlock()
             MsgBox('','\begin{slide  without  \end{slide ...',_OK_)   // begin-slide without slide-end
          endif
       endif
       if not SL
          PopPosition()
          PopBlock()    // if no slide, use original block
       endif
       if isBlockmarked()

         mChDirCurrFile()
         if FileChanged()
            if not overwr
              if not MsgBox('','Overwrite ?',_OK_)
                 return(1)
              endif
              overwr = ON
            endif
            if not SaveFile()
               return(1)
            endif
            FileChanged(FALSE)
         endif

         if not isCursorInBlock()
            GotoBlockBegin()
            ScrollToTop()
            UpdateDisplay()
            if not MsgBox('','Continue ?',_OK_)
                   PrevPosition()
                   return(1)
            endif
         endif
         if mainfile <> CurrFilename()
            if  FileExists(mainfile)
                EditFile(mainfile)
                mChDirCurrFile()
                mid = GetBufferId()
            else
                if mainfile ==''
                  MsgBox('','mainfile does not exist...',_OK_)
                else
                  MsgBox('',mainfile+' does not exist...',_OK_)
                endif
                return(0)
            endif
         else
            mid = cid
         endif
         tclp=CreateTempBuffer()
         GotoBufferId(cid)
         if (tclp)
           cclp = Set(ClipBoardId,tclp)      // set up own clipboard buffer
           PushPosition()
           PushBlock()
           Copy()
           tid = CreateBuffer(tb+'.tex',_HIDDEN_)
           if (tid)
             BegFile()
             EmptyBuffer()
             bi = Set(InsertLineBlocksAbove,True)
             Paste()
             InsertLine('\noindent')
             GotoBufferId(mid)
             BegFile()
             MarkLine()
             if lFind('\begin{document}','i')
                MarkLine()
                Copy()
                GotoBufferId(tid)
                bp = Set(UnMarkAfterPaste,False)
                Paste()
                GotoBlockEnd()
                UnMarkBlock()
                Set(UnMarkAfterPaste,bp)
                EndFile()
                AddLine('\end{document}')
                StartPage = 1
                KillFile()
                tmpnm     = mainfile
                tmpbr     = barename
                barename  = tb
                mainfile  = tb+'.tex'
                if FileExists(tb+'.dvi')
                   EraseDiskFile(tb+'.dvi')
                endif
                texres    = LatexComp(4)          // = 1 if successful
                mChDirCurrFile()                  // ??? curr.dir becomes another dir
                barename  = tmpbr
                mainfile  = tmpnm
                StartPage = pg
//                MainPsFileNames()
                AbandonFile(tid)
             else
                MsgBox('','No \begin{document} ...',_OK_)
                Set(ClipBoardId, cclp)
                return(1)
             endif
             Set(InsertLineBlocksAbove,bi)
           else
             MsgBox('','Could not create Testblock-buffer ...',_OK_)
             Set(ClipBoardId, cclp)
             return(1)
           endif
           Set(ClipBoardId, cclp)
           AbandonFile(tclp)
           PopBlock()
           PopPosition()
           if (texres and FileExists(tb+'.dvi'))
              if (tb2ps)
                 cmdnm = ' -o '+QuotePath(tb+'.ps')+' '+QuotePath(tb+'.dvi')
                 mDos(QuotePath(txpth+dv2ps)+cmdnm,iif(prmpt,0,1))
                 gsviewhb = iif(TSE2GSview(tb+'.ps'),gsviewhb,0)
              else
                 cmdnm = QuotePath(tb+'.dvi')
                 if yaphb <> 0
                    TerminateProcess(yaphb, 0)
                 endif
                 yaphb = lDos(QuotePath(txpth+view),cmdnm,_RUN_DETACHED_|_DONT_WAIT_|_RETURN_PROCESS_HANDLE_)
              endif
              GotoBufferId(cid)
           else
              MsgBox('','No dvi-file created')
              GotoBufferId(cid)
              if sl                 // if slide: switch off aux block, switch on orig. block
                 UnMarkBlock()
                 PopPosition()
                 PopBlock()
              endif
              return(0)
           endif
         else
           MsgBox('','Could not create temporary clipboard-buffer ...',_OK_)
           if sl                 // if slide: switch off aux block, switch on orig. block
              UnMarkBlock()
              PopPosition()
              PopBlock()
           endif
           return(0)
         endif
         if sl                 // if slide: switch off aux block, switch on orig. block
            UnMarkBlock()
            PopPosition()
            PopBlock()
         endif
       else                  // if not isBlockMarked and, therefore, is not a slide
         MsgBox('','No block set, no slide ...',_OK_)
         return(0)
       endif                 // isblockmarked
     else
       MsgBox('','Use other file name than: testbloc.tex .',_OK_)
       return(0)
     endif
     menu_history = 7 + iif(tb2ps,iif(gsviewhb==0,1,0),0) // block or slide
     return(iif(tb2ps,iif(gsviewhb==0,1,0),0))
end  TestBlock

proc Indexs()
//   Makes an \index{..} of the current or next word
     PushBlock()
     UnMarkBlock()
     if not IsWord()
        WordRight()
     endif
     MarkWord()
     GotoBlockEnd()
     InsertText('\index{',_INSERT_)
     CopyBlock()
     GotoBlockEnd()
     InsertText('}',_INSERT_)
     PopBlock()
end  Indexs

proc FindBE()
     integer a=Pos('\',GetText(1,CurrLineLen())),
             b=Pos('{',GetText(a,CurrLineLen())),
             c=CurrCol(),
             YOffset=CurrLine()-CurrRow(),
             XOffset=CurrXOffset()
     GotoPos(a)
     case GetText(a,b)
       when '\end{'
           lFind('\{.*\}','xi')
           lFind('\begin'+GetFoundText(),'bi')
       when '\begin{'
           lFind('\{.*\}','xi')
           lFind('\end'+GetFoundText(),'i')
       otherwise
           lFind('{\\begin\{}|{\\end\{}','xi')
     endcase
     GotoColumn(c)
     case CurrLine()
        when 1..(YOffset-1)
            ScrollToRow(1)
        when YOffset..(Query(WindowRows)+YOffset)
             ScrollToRow(CurrLine()-YOffset)
        otherwise
             ScrollToRow(Query(WindowRows))
     endcase
     case CurrCol()
        when 1..(XOffset-1)
            GotoXOffSet(CurrCol())
        when XOffset..(Query(WindowCols)+XOffset)
             GotoXOffSet(XOffset)
        otherwise
             GotoXOffSet(CurrCol()-Query(WindowCols))
     endcase
end  FindBE

//----------------------------paragraph wrap for LaTeX------------------------
//
integer proc isBlankLine()
    return(iif(PosFirstNonWhite(),FALSE,TRUE))
end isBlankLine

public proc TeXWrapPara()
     integer itm = OFF, blckon = OFF, indent=Query(AutoIndent), lm=Query(LeftMargin),
     clm = CurrCol(), clm1, itm1, itm2

     string s[80]
     integer YOffset=CurrLine()-CurrRow()
     if CurrRow()==Query(WindowRows)
        ScrollToRow(1)
     endif
     if isBlankLine()
        while isBlankLine() and Down()
        endwhile
        return()
     endif

     if CurrExt() in '.tex', '.ps', '.eps', '.m'    //   skip quoted lined
        if CurrChar(PosFirstNonWhite())== 37   // currchar(%)=37
            while CurrChar(PosFirstNonWhite())== 37 and Down()
            endwhile
            return()
        endif
     endif

     Set(Leftmargin,clm)  // alternative: Set(Leftmargin,PosFirstNonWhite())
     Set(AutoIndent,Off)
     if Lower(CurrExt()) == '.tex'
       if lFind("\\item\c","ixcg")
           itm1 = currcol()-5
           itm = ON
           if CurrChar() in 91,123      // 91 = [, 123 = {
                  lFind("]|\}\c","+xc")
           endif
           clm1 = CurrCol()+1
           itm2 = max(clm,clm1)
           if lFind("[~ ]","+xc")
                PushBlock()
                MarkToEOL()
                MarkColumn(Query(BlockBegLine),Query(BlockBegCol),Query(BlockEndLine),Query(BlockEndCol))
                DelBlock()
                GotoColumn(itm2)
                PasteUndelete()
                PopBlock()
                if itm2 > clm1
                   PushBlock()
                   MarkColumn(CurrLine(),clm1,CurrLine(),itm2-1)
                   GotoColumn(itm1)
                   MoveBlock()
                   PopBlock()
                   itm1 = itm1 + itm2 - clm1
                   GotoColumn(itm2)
                endif
                if PosFirstNonWhite()==itm1
                   if clm<itm2
                      BegLine()
                      DelChar(min(itm1-1,itm2-clm))
                   endif
                endif
           else
                if itm2 > clm1
                   PushBlock()
                   MarkColumn(CurrLine(),clm1,CurrLine(),itm2-1)
                   GotoColumn(itm1)
                   MoveBlock()
                   PopBlock()
                   itm1 = itm1 + itm2 - clm1
                   GotoColumn(itm2)
                endif
                if PosFirstNonWhite()==itm1
                   if clm<itm2
                      BegLine()
                      DelChar(min(itm1-1,itm2-clm))
                   endif
                endif
                Down()
                goto eind
           endif
       endif
       if isBlockMarked()
          if isCursorInBlock()
              case MsgBoxEx('',"    You're in a marked block","[&TexWrap]; [&BlockWrap]; [&Cancel]")
                when 2                   // BlockWrap
                       ExecMacro('wrappara')
                       goto eind
                when 0                   // Esc
                       goto eind
              endcase
          endif
          blckon = ON
          PushBlock()
          UnMarkBlock()
       endif
       if lFind('\begin{document}','+i')
          Down()
          goto eind
       endif
       if isBlankLine()
          while isBlankLine() and Down()
          endwhile
          goto eind
       endif
       if lFind('\\begin\c','xcg')
          lFind('\{.*\}','xc')
          s = Lower(GetFoundText())
          s = s[2..Length(s)-1]
          if not (s in env1,env2,env3,env4,env5,env6,env7,env8,env9,env10,env11,env12)
             lFind('\\begin','xcg')
             if (currcol()==PosFirstNonWhite())
                if (clm>currcol())
                      BegLine()
                      InsertText(Format(" ":clm-PosFirstNonWhite()),_INSERT_)
                      GotoColumn(clm)
                else
                      GotoColumn(clm)
                      DelChar(PosFirstNonWhite()-clm)
                endif
             endif
             if Pos('*',s)
                s = InsStr('\',s,Pos('*',s))
             endif
             if lFind('\c\\end\{'+s+'\}','+ix')
                if (currcol()==PosFirstNonWhite())
                   if (clm>currcol())
                         BegLine()
                         InsertText(Format(" ":clm-PosFirstNonWhite()),_INSERT_)
                         GotoColumn(clm)
                   else
                         GotoColumn(clm)
                         DelChar(PosFirstNonWhite()-clm)
                   endif
                endif
                ScrollToRow(iif(CurrLine()<=Query(WindowRows)+YOffset,
                                CurrLine()-YOffset,Query(WindowRows)))
                goto eind
             else
                Alarm()
                Message('No \end{',s,'}')
             endif
          endif
       endif
       if lFind('{^}|{[~\\].*}\\\[','xcg')     //  let op: deze constructie is zo bedoeld
          if (currcol()==PosFirstNonWhite())
             if (clm>currcol())
                   BegLine()
                   InsertText(Format(" ":clm-PosFirstNonWhite()),_INSERT_)
                   GotoColumn(clm)
             else
                   GotoColumn(clm)
                   DelChar(PosFirstNonWhite()-clm)
             endif
          endif
          lFind('\\\]','x+')
          if (currcol()==PosFirstNonWhite())
             if (clm>currcol())
                   BegLine()
                   InsertText(Format(" ":clm-PosFirstNonWhite()),_INSERT_)
                   GotoColumn(clm)
             else
                   GotoColumn(clm)
                   DelChar(PosFirstNonWhite()-clm)
             endif
          endif
          ScrollToRow(iif(CurrLine()<=Query(WindowRows)+YOffset,
                          CurrLine()-YOffset,Query(WindowRows)))
          Down()
          goto eind
       endif
       if lFind('$$','cg')
          lFind('$$','+')
          ScrollToRow(iif(CurrLine()<=Query(WindowRows)+YOffset,
                          CurrLine()-YOffset,Query(WindowRows)))
          Down()
          goto eind
       endif
       PushPosition()
       if lFind(stopat1,'xicg') or
          lFind(stopat2,'xicg') or
          lFind(stopat3,'xicg')
            Down()
            goto eind
       endif
       PopPosition()
       if not itm
          ShiftText(CurrPos() - PosFirstNonWhite())
       endif
       MarkLine()
       if lFind(stopwith,'xigc')
       else
          while Down()
              if isBlankLine() or
                 lFind(stopat1,'xigc') or
                 lFind(stopat2,'xigc') or
                 lFind(stopat3,'xigc') or
                 lFind(stopfrom,'xigc')
                   Up()
                   break
              endif
              if lFind(stopwith,'xigc')
                  break
              endif
          endwhile
       endif
       MarkLine()
       ExecMacro('wrappara')
       UnMarkBlock()
eind:  if blckon
          PopBlock()
       endif
     else
       blckon = (IsBlockMarked() and (IsBlockMarked() == _Column_))
       if blckon
             PushBlock()
             UnMarkBlock()
       endif
       ExpandTabsToSpaces()
       ShiftText(clm-PosFirstNonWhite())
       GotoColumn(clm)
       ExecMacro('wrappara')
       if blckon
          PopBlock()
       endif
     endif
     Set(AutoIndent,indent)
     Set(LeftMargin,lm)
     GotoColumn(clm)
     return()
end  TeXWrapPara

proc EnvFinish()
     string env[80]=""
     integer mg = PosFirstNonWhite(), env_history = 4
     if Ask("Environment name: ",env,env_history) and Length(env)
       GotoPos(mg)
       AddLine()
       InsertText("\begin{"+env+"}")
       GotoPos(mg)
       AddLine()
       InsertText("\end{"+env+"}")
       InsertLine()
       GotoPos(mg+5)
     endif
end  EnvFinish

proc EnvDel()
     string env[80]=""
     integer crs = Query(CursorAttr)
     Set(CursorAttr,Query(HiLiteAttr))
     PushPosition()
     PushBlock()
     if lFind("\\begin\{.*\}","cgx")
           env = GetFoundText()
           UpdateDisplay(_CLINE_REFRESH_)
           if MsgBox("","Delete "+env+" ?",_OK_)
                DelLine()
                BegLine()
                env = "\end"+env[7:80]
                if lFind(env,"")
                   UpdateDisplay(_CLINE_REFRESH_)
                   if MsgBox("","Delete "+env+" ?",_OK_)
                      DelLine()
                   endif
                endif
           endif
     endif
     Set(CursorAttr,crs)
     UpdateDisplay(_CLINE_REFRESH_)
     PopBlock()
     PopPosition()
end  EnvDel

menu Commands()
     Title = 'Commands'
     history
     '&Environment '                   ,Envirs()     , _MF_Close_Before_  // E
     '&Frac        '                   ,FracMenu()   , _MF_Dont_Close_    // F
     '&Box         '                   ,BoxMenu()    , _MF_Dont_Close_    // B
     '&Commands    '                   ,LatComs()    , _MF_Dont_Close_    // C
     'S&ymbols     '                   ,Symbols()    , _MF_Dont_Close_    // y
     '&AMS Symbols '                   ,AMSSymb()    , _MF_Dont_Close_    // A
     'S&how symbols'                    ,ShowSymbols(), _MF_Close_Before_  // D
     ''                                 ,             , _MF_Divide_        //
     'Ne&w document'                    ,IniDocu()                         // w
     'Ma&rgin'                          ,Margin()                          // r
     'Fi&gure'                          ,Figure()                          // g
     'Arra&y'                           ,Array()                           // y
     '&Table'                           ,Table()                           // T
     'Clean e&ps'                       ,CleanEps()                        // p
     ''                                 ,             , _MF_Divide_        //
     '&Insert <mainfile name>'          ,IncMnfn()    , _MF_Close_Before_  // I
     'Update <&status>'                 ,UpdStatus()  , _MF_Close_Before_  // s
     ''                                 ,             , _MF_Divide_        //
     'Inde&x'                           ,Indexs()                          // x
     '&Match Begin/end'                 ,FindBE()                          // M
     'Fi&nd Begin '                    ,lFind('\begin{','i+')             // n
     'Fin&d Begin '                    ,lFind('\begin{','bi+')            // d
     '&QuickEnvironment'                ,EnvFinish()                       // Q
     'De&lete Environment'              ,EnvDel()                          // l
     '&Help'                            ,EditFile(QuotePath(myhelp))       // H
end  Commands

datadef EnvirsData
       'equation' 'equation*' 'subequations' 'eqnarray' 'eqnarray*' 'align' 'align*'
       'aligned' 'alignat' 'alignat*' 'alignedat' 'flalign' 'flalign*' 'xalignat' 'xalignat*'
       'xxalignat' 'gather' 'gather*' 'gathered' 'multline' 'multline*' 'split' 'center'
       'flushleft' 'flushright' 'tiny' 'scriptsize' 'footnotesize' 'small' 'normal'
       'large' 'Large' 'LARGE' 'huge' 'Huge' 'verbatim' 'minipage' 'array' 'matrix'
       'cases' 'list' 'enumerate' 'itemize' 'quote' 'verse' 'description' 'picture'
       'figure' 'table' 'tabbing' 'tabular' 'tabular*' 'theorem' 'lemma' 'corollary'
       'thebibliography' 'name' 'titlepage' 'slide' 'slide*' 'document'
end  EnvirsData

integer Envirs_Line = 0

proc Envirs()
     string envy[20]
     integer CR, auxLine, auxList, Envirs_id, Current_id = GetBufferId(), Blk= IsCursorInBlock(), crcl = 9999
     PushPosition()
     if Blk
        GotoBlockBegin()
        cr=CurrRow()+Query(WindowY1)-1
        while IsCursorInblock()                         // align to min(whole block)
              if not isBlankLine()
                 crcl = min(crcl, PosFirstNonWhite())
              endif
              if not Down()
                break
              endif
        endwhile
        if crcl == 9999 crcl = 1 endif
     else
        cr=CurrRow()+Query(WindowY1)-1
        if isBlankLine()                           // align curr.line, or if empty: prev. line
           if Up()
             crcl = max(1,PosFirstnonWhite())
             Down()
           else
             crcl = 1
           endif
        else
           crcl = PosFirstnonWhite()
        endif
     endif
     auxLine = Envirs_Line
     Envirs_id = CreateBuffer('Envirs')
     PopPosition()
     while crcl<> 0
        LE_Init(crcl,CR)
        crcl = LE_Loop(crcl)
        if crcl <> 0
           PushPosition()
           PushBlock()
           UnMarkBlock()
           GotoBufferId(Envirs_id)
           InsertData(EnvirsData)
           GotoLine(auxLine)
           ScrollUp(12)
           Set(y1,2)
           auxList = lList('Environments', 15,30,_ENABLE_SEARCH_+_ANCHOR_SEARCH_+_ENABLE_HSCROLL_)
           auxLine = CurrLine()
           if auxList
              BegLine() MarkToEOL()
              envy = GetMarkedText()
              GotoBufferId(Current_id)
              PopBlock()
              KillPosition()
              case envy
                  when 'equation'        Environment('equation}'       ,''                                                   , 0,Blk,crcl)
                  when 'equation*'       Environment('equation*}'      ,''                                                   , 0,Blk,crcl)
                  when 'subequations'    Environment('subequations}'   ,'\label{}'                                           ,21,Blk,crcl)
                  when 'eqnarray'        Environment('eqnarray}'       ,''                                                   , 0,Blk,crcl)
                  when 'eqnarray*'       Environment('eqnarray*}'      ,''                                                   , 0,Blk,crcl)
                  when 'align'           Environment('align}'          ,''                                                   , 0,Blk,crcl)
                  when 'align*'          Environment('align*}'         ,''                                                   , 0,Blk,crcl)
                  when 'aligned'         Environment('aligned}'        ,'[cbt]'                                              ,17,Blk,crcl)
                  when 'alignat'         Environment('alignat}'        ,'{n}'                                                ,17,Blk,crcl)
                  when 'alignat*'        Environment('alignat*}'       ,'{n}'                                                ,18,Blk,crcl)
                  when 'alignedat'       Environment('alignedat}'      ,'{n}[cbt]'                                           ,19,Blk,crcl)
                  when 'flalign'         Environment('flalign}'        ,''                                                   , 0,Blk,crcl)
                  when 'flalign*'        Environment('flalign*}'       ,''                                                   , 0,Blk,crcl)
                  when 'xalignat'        Environment('xalignat}'       ,''                                                   , 0,Blk,crcl)
                  when 'xxalignat'       Environment('xxalignat}'      ,''                                                   , 0,Blk,crcl)
                  when 'gather'          Environment('gather}'         ,''                                                   , 0,Blk,crcl)
                  when 'gather*'         Environment('gather*}'        ,''                                                   , 0,Blk,crcl)
                  when 'gathered'        Environment('gathered}'       ,'[cbt]'                                              ,18,Blk,crcl)
                  when 'multline'        Environment('multline}'       ,''                                                   , 0,Blk,crcl)
                  when 'multline*'       Environment('multline*}'      ,''                                                   , 0,Blk,crcl)
                  when 'split'           Environment('split}'          ,''                                                   , 0,Blk,crcl)
                  when 'center'          Environment('center}'         ,''                                                   , 0,Blk,crcl)
                  when 'flushleft'       Environment('flushleft}'      ,''                                                   , 0,Blk,crcl)
                  when 'flushright'      Environment('flushright}'     ,''                                                   , 0,Blk,crcl)
                  when 'tiny'            Environment('tiny}'           ,''                                                   , 0,Blk,crcl)
                  when 'scriptsize'      Environment('scriptsize}'     ,''                                                   , 0,Blk,crcl)
                  when 'footnotesize'    Environment('footnotesize}'   ,''                                                   , 0,Blk,crcl)
                  when 'small'           Environment('small}'          ,''                                                   , 0,Blk,crcl)
                  when 'normal'          Environment('normal}'         ,''                                                   , 0,Blk,crcl)
                  when 'large'           Environment('large}'          ,''                                                   , 0,Blk,crcl)
                  when 'Large'           Environment('Large}'          ,''                                                   , 0,Blk,crcl)
                  when 'LARGE'           Environment('LARGE}'          ,''                                                   , 0,Blk,crcl)
                  when 'huge'            Environment('huge}'           ,''                                                   , 0,Blk,crcl)
                  when 'Huge'            Environment('Huge}'           ,''                                                   , 0,Blk,crcl)
                  when 'verbatim'        Environment('verbatim}'       ,''                                                   , 0,Blk,crcl)
                  when 'minipage'        Environment('minipage}'       ,'[pos]{width}'                                       ,18,Blk,crcl)
                  when 'array'           Environment('array}'          ,'[pos]{r@{\ }c@{\ }l}'                               ,15,Blk,crcl)
                  when 'matrix'          Environment('matrix}'         ,''                                                   , 0,Blk,crcl)
                  when 'cases'           Environment('cases}'          ,''                                                   , 0,Blk,crcl)
                  when 'list'            Environment('list}'           ,'{label}{\leftmargin\labelsep\topsep\itemsep\parsep}',14,Blk,crcl)
                  when 'enumerate'       Environment('enumerate}'      ,''                                                   , 0,Blk,crcl)
                  when 'itemize'         Environment('itemize}'        ,''                                                   , 0,Blk,crcl)
                  when 'quote'           Environment('quote}'          ,''                                                   , 0,Blk,crcl)
                  when 'verse'           Environment('verse}'          ,''                                                   , 0,Blk,crcl)
                  when 'description'     Environment('description}'    ,''                                                   , 0,Blk,crcl)
                  when 'picture'         Environment('picture}'        ,'(wdth,hght)(offset x,y)'                            ,17,Blk,crcl)
                  when 'figure'          Environment('figure}'         ,'[!htb/H]'                                           ,16,Blk,crcl)
                  when 'table'           Environment('table}'          ,'[!htb/H]'                                           ,15,Blk,crcl)
                  when 'tabbing'         Environment('tabbing}'        ,''                                                   , 0,Blk,crcl)
                  when 'tabular'         Environment('tabular}'        ,'[pos]{cols}'                                        ,17,Blk,crcl)
                  when 'tabular*'        Environment('tabular*}'       ,'{width}[pos]{cols}'                                 ,18,Blk,crcl)
                  when 'theorem'         Environment('theorem}'        ,''                                                   , 0,Blk,crcl)
                  when 'lemma'           Environment('lemma}'          ,''                                                   , 0,Blk,crcl)
                  when 'corollary'       Environment('corollary}'      ,''                                                   , 0,Blk,crcl)
                  when 'thebibliography' Environment('thebibliography}','{widest-label}'                                     ,25,Blk,crcl)
                  when 'name'            Environment('name}'           ,''                                                   , 0,Blk,crcl)
                  when 'titlepage'       Environment('titlepage}'      ,''                                                   , 0,Blk,crcl)
                  when 'slide'           Environment('slide}'          ,''                                                   , 0,Blk,crcl)
                  when 'slide*'          Environment('slide*}'         ,''                                                   , 0,Blk,crcl)
                  when 'document'        Environment('document}'       ,''                                                   , 0,Blk,crcl)
              endcase
              crcl = 0
              Envirs_Line = auxLine
//              PushKey(<escape>)           // in case we leave the menu open
           else
              GotoBufferId(Current_id)
              PopPosition()
              PopBlock()
           endif
        endif
     endwhile
     AbandonFile(Envirs_id)
     LE_Done()
end  Envirs

proc Environment(string tx1,string tx2, integer nr, integer bl, integer cl)
     if bl                                              // if cursor in block
        GotoBlockBegin()
        GotoColumn(cl)
        InsertLine()
        InsertText('\begin{'+tx1+tx2,_INSERT_)
        GotoBlockEnd()
        GotoColumn(cl)
        AddLine()
        InsertText('\end{'+tx1,_INSERT_)
        GotoBlockBegin()
        if nr ==0
           GotoColumn(cl)
        else
           Up()
           GotoColumn(cl+nr-1)
        endif
     else
        if not isBlankLine() Addline() endif
        GotoColumn(cl)
        InsertText('\begin{'+tx1+tx2,_INSERT_)
        AddLine()
        GotoColumn(cl)
        InsertText('\end{'+tx1,_INSERT_)
        Up()
        if nr ==0
           EndLine()
        else
           GotoColumn(cl+nr-1)
        endif
     endif
end  Environment

/********************* Left-margin Environment Routines ***************************/

proc LE_PaintStatus(integer CurCX, integer CurX)

    if VWhereX()<Query(WindowCols)+1 & VWhereX()>0
       PutAttr(ClrW,1)
    endif
    GotoXY(13-Query(WindowX1),-2-WhereYabs()) PutStr(Format(CurX:3),Query(MenuTextAttr))
    GotoXY(CurCX,1)
    PutAttr(Color(Bright Yellow on Red),1)
    GotoXY(CurCX,1)
end

proc LE_PaintChart(integer CurCX)
     integer i
     for i=1 to Query(WindowCols)
      GotoXY(i,1)
      //  PutStr(".")
      PutAttr(ClrW,1)
     endfor
     GotoXY(CurCX,1)
end

integer proc LE_Loop(integer CurX)
    integer mincol = 1+CurrXOffSet(), maxcol = Query(WindowCols)-1 + mincol
    loop
        LE_PaintStatus(min(max(0,CurX-mincol+1),Query(WindowCols)+1), CurX)
        case GetKey()
            when <Enter>            break
            when <Escape>           CurX = 0
                                    break
            when <CursorLeft>       CurX = iif(CurX<=mincol,CurX,CurX-1)
            when <Ctrl CursorLeft>  CurX = max(1,CurX-1)
            when <CursorRight>      CurX = iif(CurX>=maxcol,CurX,CurX+1)
            when <Ctrl CursorRight> CurX = CurX+1
            when <Home>             CurX = mincol
            when <End>              CurX = maxcol
        endcase
    endloop
    return(CurX)
end

proc LE_Init(integer crcl, integer cr)
     integer     WinL=Query(WindowX1), WinT=cr

     if not PopWinOpen(WinL,WinT,WinL+Query(WindowCols),WinT+2,0,"",ClrW)
         ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
         Warn("Error opening popup window")
         Alarm()
         crcl = 0
         halt
     endif
     Set(Cursor,OFF)
     Set(Attr,ClrW)
     LE_PaintChart(crcl)
end

proc LE_Done()
     PopWinClose()
     Set(Cursor,ON)
end

/************************************************/


/*********************************************
 A complete figure environment. May be adapted.
 ********************************************/
proc Figure()
     AddLine('\begin{figure}[!htb/H]                                  ')
     AddLine('     \setlength{\unitlength}{1mm}                       ')
     AddLine('     \begin{picture}(150,YY)(0,0)                       ')
     AddLine('      \put(0,0){\framebox(150,YY)}                      ')
     AddLine('     \end{picture}                                      ')
     AddLine(' or: \epsfxsize= \epsfysize= \epsfbox{.eps}             ')
     AddLine(' or: \psfig{file=,figure=,height=,width=,               ')
     AddLine('            bbllx=,bblly=,bburx=,bbury=,                ')
     AddLine('            rheight=,rwidth=,clip=,angle=,silent=}      ')
     AddLine('     \setbox0\hbox{Text for the figure}                 ')
     AddLine('     \caption{\protect\parbox[t]{\wd0}{\box0}\label{..}}')
     AddLine('\end{figure}')
end  Figure

/********************************************************************
 A complete table environment; 'tabular' may be exchanged with 'array'.
 may be adapted.
 *******************************************************************/
proc Table()
     string s[2] = '', t[1] = ''
     integer nrcols
     if Ask("Number of columns", s) and (s[1] in '0'..'9')
        Ask('Tabular or Array',t)
        nrcols = Val(s)
        AddLine('\begin{table}[!htb/H]')
        if Lower(t)=='t'
            AddLine('   \centerline{')
            AddLine('   \begin{tabular}{|')
        else
            AddLine('   \[')
            AddLine('   \begin{array}{|')
        endif
        EndLine()
        do nrcols times
           InsertText('c|')
        enddo
        InsertText('}  \hline')
        AddLine()
        GotoColumn(8)
        do nrcols-1 times
           InsertText(' & ')
        enddo
        InsertText(' \\   \hline')
        if t=='t'
            AddLine('   \end{tabular}}')
        else
            AddLine('   \end{array}')
            AddLine('   \]')
        endif
        AddLine('   \setbox0\hbox{Text for the table}')
        AddLine('   \caption{\protect\parbox[t]{\wd0}{\box0}\label{..}}')
        AddLine('\end{table}')
        GotoColumn(8)
        Up(4)
     endif
end  Table

/***********
 an array environment
 ***********/
proc Array()
     string s[2] = ''
     integer nrcols
     if Ask("Number of columns", s) and (s[1] in '0'..'9')
        nrcols = Val(s)
        AddLine('\begin{array}{')
        EndLine()
        do nrcols times
           InsertText('c')
        enddo
        InsertText('}')
        AddLine()
        GotoColumn(8)
        do nrcols-1 times
           InsertText(' & ')
        enddo
        InsertText(' \\ ')
        AddLine('\end{array}')
        GotoColumn(8)
        Up()
     endif
end  Array

/***********
 a margin environment.
 ***********/
proc Margin()
     string s[2] = ''
     if Ask("Margin (in mm)", s) and (s[1] in '0'..'9')
     AddLine('\begin{list}{}{\rightmargin0cm\listparindent0cm\labelsep0cm%')
     AddLine('        \topsep0cm\parsep0cm\itemsep0cm\leftmargin')
     EndLine()
     InsertText(s+'mm}\item[]%')
     AddLine('')
     AddLine('\end{list}')
     Up()
     BegLine()
     endif
end  Margin

/***************************************
 Initialisation of LaTeX article or slides.
 NOTE: Present choice is very personal and should be adapted !
 **************************************/
proc IniDocu()
     string s[_MAXPATH_] = ''
     ChDir(SplitPath(CurrFilename(),_DRIVE_|_PATH_))
     s = PickFile(SplitPath(CurrFilename(),_DRIVE_|_PATH_)+"*.*",_INSERT_PATH_)
     if not length(s)
        s = QuotePath(SplitPath(CurrFilename(),_DRIVE_|_PATH_))
        if not Ask('New LaTeX filename', s) or SplitPath(s,_NAME_)==''
           s = ''
        endif
     endif
     if length(s)
      s = QuotePath(SplitPath(s,_DRIVE_|_PATH_|_NAME_)+'.tex')
      if Ask('New LaTeX filename', s) and length(s)
       AddHistoryStr(s,_EDIT_HISTORY_)
       EditFile(s)
       if NumLines() <> 0
          case YesNo("File already exists. Erase contents?")
               when 0
                    AbandonFile()
                    return()
               when 1
                    EmptyBuffer()
               when 2
                    return()
           endcase
       endif
       BegFile()
       case MsgBoxEx("","Type of file","[&Article];[&Slides]")
       when 0
            AbandonFile()
       when 1
            AddLine('\documentclass[11pt,reqno]{article}')
            AddLine('\usepackage[T1]{fontenc}')
            AddLine('\usepackage[T1,mtbold,cmcal]{mathtime}')
            AddLine('\usepackage{amsmath}')
            AddLine('\usepackage{amssymb}')
            AddLine('\usepackage{gensymb,eurosym}')
            AddLine('\oddsidemargin  0.125 in')
            AddLine('\evensidemargin 0.125 in')
            AddLine('\marginparwidth 0.75  in')
            AddLine('\textwidth      6.125 in')
            AddLine('\textheight 46\baselineskip')
            AddLine()
            AddLine('\arraycolsep1.5pt % (bug in eqnarray)')
            AddLine()
            AddLine('\let\oldnabla=\nabla                    % define \oldnabla as regular \nabla')
            AddLine('\def\nabla{\boldsymbol{\oldnabla}}      % redefine \nabla as bold nabla     ')
            AddLine('\edef\pounds{\text{\pounds}}            % bug in \pounds                    ')
            AddLine()
            AddLine('%% convenient definitions')
            AddLine()
            AddLine('\def\today{\number\day\space \ifcase\month\or')
            AddLine('    Jan \or Feb \or Mar \or Apr \or May \or Jun \or')
            AddLine('    Jul \or Aug \or Sep \or Oct \or Nov \or Dec \fi')
            AddLine('    \number\year}')
            AddLine('\newcount\hours')
            AddLine('\newcount\minutes')
            AddLine('\def \SetTime{\hours=\time')
            AddLine('    \global\divide\hours by 60')
            AddLine('    \minutes=\hours')
            AddLine('    \multiply\minutes by 60')
            AddLine('    \advance\minutes by-\time')
            AddLine('    \global\multiply\minutes by-1 }')
            AddLine('\SetTime')
            AddLine('\def \now{\number\hours:\ifnum\minutes<10 0\fi\number\minutes}')
            AddLine('\def \at{\char64} % = @')
            AddLine()
            AddLine('\def\pad#1#2{\def\leeg{}\def\test{#1}\frac{\partial\ifx\test\leeg{\,}\else#1\fi}{\partial #2}}')
            AddLine('\def\tpad#1#2{\def\leeg{}\def\test{#1}\tfrac{\partial\ifx\test\leeg{\,}\else#1\fi}{\partial #2}}')
            AddLine('\def\Pad#1#2{\def\leeg{}\def\test{#1}\dfrac{\partial\ifx\test\leeg{\,}\else#1\fi}{\partial #2}}')
            AddLine('\def\padd#1#2{\def\leeg{}\def\test{#1}\frac{\partial^2\ifx\test\leeg{\,}\else#1\fi}{\partial #2^2}}')
            AddLine('\def\tpadd#1#2{\def\leeg{}\def\test{#1}\tfrac{\partial^2\ifx\test\leeg{\,}\else#1\fi}{\partial #2^2}}')
            AddLine('\def\Padd#1#2{\def\leeg{}\def\test{#1}\dfrac{\partial^2\ifx\test\leeg{\,}\else#1\fi}{\partial #2^2}}')
            AddLine('\def\paddd#1#2{\def\leeg{}\def\test{#1}\frac{\partial^3\ifx\test\leeg{\,}\else#1\fi}{\partial #2^3}}')
            AddLine('\def\tpaddd#1#2{\def\leeg{}\def\test{#1}\tfrac{\partial^3\ifx\test\leeg{\,}\else#1\fi}{\partial #2^3}}')
            AddLine('\def\Paddd#1#2{\def\leeg{}\def\test{#1}\dfrac{\partial^3\ifx\test\leeg{\,}\else#1\fi}{\partial #2^3}}')
            AddLine('\def\padddd#1#2{\def\leeg{}\def\test{#1}\frac{\partial^4\ifx\test\leeg{\,}\else#1\fi}{\partial #2^4}}')
            AddLine('\def\tpadddd#1#2{\def\leeg{}\def\test{#1}\tfrac{\partial^4\ifx\test\leeg{\,}\else#1\fi}{\partial #2^4}}')
            AddLine('\def\Padddd#1#2{\def\leeg{}\def\test{#1}\dfrac{\partial^4\ifx\test\leeg{\,}\else#1\fi}{\partial #2^4}}')
            AddLine('\def\padxy#1#2#3{\def\leeg{}\def\test{#1}\frac{\partial^2\ifx\test\leeg{\,}\else#1\fi}{\partial #2 \partial #3}}')
            AddLine('\def\tpadxy#1#2#3{\def\leeg{}\def\test{#1}\tfrac{\partial^2\ifx\test\leeg{\,}\else#1\fi}{\partial #2 \partial #3}}')
            AddLine('\def\Padxy#1#2#3{\def\leeg{}\def\test{#1}\dfrac{\partial^2\ifx\test\leeg{\,}\else#1\fi}{\partial #2 \partial #3}}')
            AddLine('\def\nd#1#2{\def\leeg{}\def\test{#1}\frac{\d\ifx\test\leeg{\,}\else#1\fi}{\d #2}}')
            AddLine('\def\Nd#1#2{\def\leeg{}\def\test{#1}\dfrac{\d\ifx\test\leeg{\,}\else#1\fi}{\d #2}}')
            AddLine('\def\tnd#1#2{\def\leeg{}\def\test{#1}\tfrac{\d\ifx\test\leeg{\,}\else#1\fi}{\d #2}}')
            AddLine('\def\ndd#1#2{\def\leeg{}\def\test{#1}\frac{\d^2\ifx\test\leeg{\,}\else#1\fi}{\d #2^2}}')
            AddLine('\def\Ndd#1#2{\def\leeg{}\def\test{#1}\dfrac{\d^2\ifx\test\leeg{\,}\else#1\fi}{\d #2^2}}')
            AddLine('\def\tndd#1#2{\def\leeg{}\def\test{#1}\tfrac{\d^2\ifx\test\leeg{\,}\else#1\fi}{\d #2^2}}')
            AddLine()
            AddLine('\def\inner{\mathchoice{\mkern1.5mu\hbox{\mbox{$\boldsymbol{\cdot}$}}\mkern1.5mu}%')
            AddLine('                      {\mkern1.5mu\hbox{\mbox{$\boldsymbol{\cdot}$}}\mkern1.5mu}%')
            AddLine('                      {\hbox{\mbox{\footnotesize$\boldsymbol{\cdot}$}}\mkern1.0mu}%')
            AddLine('                      {\mkern1.0mu\raise-0.5pt\hbox{\mbox{\scriptsize$\boldsymbol{\cdot}$}}\mkern1.0mu}}')
            AddLine('\def\innernabla{\mkern2.0mu\hbox{\mbox{$\boldsymbol{\cdot}$}}\mkern-0.5mu\nabla}')
            AddLine('\def\nablainner{\nabla\mkern-0.5mu\hbox{\mbox{$\boldsymbol{\cdot}$}}\mkern1.5mu}')
            AddLine('\def\cross{\mkern1.mu\hbox{\mbox{$\boldsymbol{\times}$}}\mkern1.mu}')
            AddLine('\def\nablacross{\nabla\mkern-0.5mu\hbox{\mbox{$\boldsymbol{\times}$}}\mkern0.5mu}')
            AddLine()
            AddLine('\def\d{\mathrm{d}}')
            AddLine('\def\pa{\partial}')
            AddLine('\def\1{\mathrm{i}\mathchoice{\mkern1.5mu}{\mkern1.5mu}{\mkern0.5mu}{\mkern0.1mu}}    % imaginary unit')
            AddLine('\def\Im{\mathop{\rm Im}\nolimits}')
            AddLine('\def\Re{\mathop{\rm Re}\nolimits}')
            AddLine('\def\ra{{\ifmmode\rightarrow\else$\rightarrow$\fi}}')
            AddLine()
            AddLine('\def\5{\mathchoice{\mkern2mu}{\mkern2mu}{\mkern1mu}{\mkern0.6667mu}}                 % typically in exponent')
            AddLine('\def\2{\mathchoice{\mkern1mu}{\mkern1mu}{\mkern0.5mu}{\mkern0.3333mu}}               % alternative for the too big \,')
            AddLine('\def\qqquad{\hskip3em\relax}')
            AddLine()
            AddLine('\def\Exp#1{\mathop{\rm e}\nolimits^{#1}}')
            AddLine('\def\il{\int\limits}')
            AddLine('\def\Int{{\displaystyle{\int}}}')
            AddLine()
            AddLine('%% alphabet')
            AddLine()
            AddLine('\def\rmA{\mathrm{A}} \def\rma{\mathrm{a}} \def\bfA{\mathbf{A}} \def\bfa{\mathbf{a}} \def\bA{\boldsymbol{A}} \def\ba{\boldsymbol{a}}  \def\cA{\mathcal{A}} \def\ca{\mathcal{a}} \def\cbA{\boldsymbol{\mathcal{A}}}')AddLine(' \def\sfbA{\textsf{\fontseries{bx}\fontshape{sl}\selectfont A}}')Up()Joinline()
            AddLine('\def\rmB{\mathrm{B}} \def\rmb{\mathrm{b}} \def\bfB{\mathbf{B}} \def\bfb{\mathbf{b}} \def\bB{\boldsymbol{B}} \def\bb{\boldsymbol{b}}  \def\cB{\mathcal{B}} \def\cb{\mathcal{b}} \def\cbB{\boldsymbol{\mathcal{B}}}')AddLine(' \def\sfbB{\textsf{\fontseries{bx}\fontshape{sl}\selectfont B}}')Up()Joinline()
            AddLine('\def\rmC{\mathrm{C}} \def\rmc{\mathrm{c}} \def\bfC{\mathbf{C}} \def\bfc{\mathbf{c}} \def\bC{\boldsymbol{C}} \def\bc{\boldsymbol{c}}  \def\cC{\mathcal{C}} \def\cc{\mathcal{c}} \def\cbC{\boldsymbol{\mathcal{C}}}')AddLine(' \def\sfbC{\textsf{\fontseries{bx}\fontshape{sl}\selectfont C}}')Up()Joinline()
            AddLine('\def\rmD{\mathrm{D}} \def\rmd{\mathrm{d}} \def\bfD{\mathbf{D}} \def\bfd{\mathbf{d}} \def\bD{\boldsymbol{D}} \def\bd{\boldsymbol{d}}  \def\cD{\mathcal{D}} \def\cd{\mathcal{d}} \def\cbD{\boldsymbol{\mathcal{D}}}')AddLine(' \def\sfbD{\textsf{\fontseries{bx}\fontshape{sl}\selectfont D}}')Up()Joinline()
            AddLine('\def\rmE{\mathrm{E}} \def\rme{\mathrm{e}} \def\bfE{\mathbf{E}} \def\bfe{\mathbf{e}} \def\bE{\boldsymbol{E}} \def\be{\boldsymbol{e}}  \def\cE{\mathcal{E}} \def\ce{\mathcal{e}} \def\cbE{\boldsymbol{\mathcal{E}}}')AddLine(' \def\sfbE{\textsf{\fontseries{bx}\fontshape{sl}\selectfont E}}')Up()Joinline()
            AddLine('\def\rmF{\mathrm{F}} \def\rmf{\mathrm{f}} \def\bfF{\mathbf{F}} \def\bff{\mathbf{f}} \def\bF{\boldsymbol{F}} \def\bef{\boldsymbol{f}} \def\cF{\mathcal{F}} \def\cf{\mathcal{f}} \def\cbF{\boldsymbol{\mathcal{F}}}')AddLine(' \def\sfbF{\textsf{\fontseries{bx}\fontshape{sl}\selectfont F}}')Up()Joinline()
            AddLine('\def\rmG{\mathrm{G}} \def\rmg{\mathrm{g}} \def\bfG{\mathbf{G}} \def\bfg{\mathbf{g}} \def\bG{\boldsymbol{G}} \def\bg{\boldsymbol{g}}  \def\cG{\mathcal{G}} \def\cg{\mathcal{g}} \def\cbG{\boldsymbol{\mathcal{G}}}')AddLine(' \def\sfbG{\textsf{\fontseries{bx}\fontshape{sl}\selectfont G}}')Up()Joinline()
            AddLine('\def\rmH{\mathrm{H}} \def\rmh{\mathrm{h}} \def\bfH{\mathbf{H}} \def\bfh{\mathbf{h}} \def\bH{\boldsymbol{H}} \def\bh{\boldsymbol{h}}  \def\cH{\mathcal{H}} \def\ch{\mathcal{h}} \def\cbH{\boldsymbol{\mathcal{H}}}')AddLine(' \def\sfbH{\textsf{\fontseries{bx}\fontshape{sl}\selectfont H}}')Up()Joinline()
            AddLine('\def\rmI{\mathrm{I}} \def\rmi{\mathrm{i}} \def\bfI{\mathbf{I}} \def\bfi{\mathbf{i}} \def\bI{\boldsymbol{I}} \def\bi{\boldsymbol{i}}  \def\cI{\mathcal{I}} \def\ci{\mathcal{i}} \def\cbI{\boldsymbol{\mathcal{I}}}')AddLine(' \def\sfbI{\textsf{\fontseries{bx}\fontshape{sl}\selectfont I}}')Up()Joinline()
            AddLine('\def\rmJ{\mathrm{J}} \def\rmj{\mathrm{j}} \def\bfJ{\mathbf{J}} \def\bfj{\mathbf{j}} \def\bJ{\boldsymbol{J}} \def\bj{\boldsymbol{j}}  \def\cJ{\mathcal{J}} \def\cj{\mathcal{j}} \def\cbJ{\boldsymbol{\mathcal{J}}}')AddLine(' \def\sfbJ{\textsf{\fontseries{bx}\fontshape{sl}\selectfont J}}')Up()Joinline()
            AddLine('\def\rmK{\mathrm{K}} \def\rmk{\mathrm{k}} \def\bfK{\mathbf{K}} \def\bfk{\mathbf{k}} \def\bK{\boldsymbol{K}} \def\bk{\boldsymbol{k}}  \def\cK{\mathcal{K}} \def\ck{\mathcal{k}} \def\cbK{\boldsymbol{\mathcal{K}}}')AddLine(' \def\sfbK{\textsf{\fontseries{bx}\fontshape{sl}\selectfont K}}')Up()Joinline()
            AddLine('\def\rmL{\mathrm{L}} \def\rml{\mathrm{l}} \def\bfL{\mathbf{L}} \def\bfl{\mathbf{l}} \def\bL{\boldsymbol{L}} \def\bl{\boldsymbol{l}}  \def\cL{\mathcal{L}} \def\cl{\mathcal{l}} \def\cbL{\boldsymbol{\mathcal{L}}}')AddLine(' \def\sfbL{\textsf{\fontseries{bx}\fontshape{sl}\selectfont L}}')Up()Joinline()
            AddLine('\def\rmM{\mathrm{M}} \def\rmm{\mathrm{m}} \def\bfM{\mathbf{M}} \def\bfm{\mathbf{m}} \def\bM{\boldsymbol{M}} \def\bm{\boldsymbol{m}}  \def\cM{\mathcal{M}} \def\cm{\mathcal{m}} \def\cbM{\boldsymbol{\mathcal{M}}}')AddLine(' \def\sfbM{\textsf{\fontseries{bx}\fontshape{sl}\selectfont M}}')Up()Joinline()
            AddLine('\def\rmN{\mathrm{N}} \def\rmn{\mathrm{n}} \def\bfN{\mathbf{N}} \def\bfn{\mathbf{n}} \def\bN{\boldsymbol{N}} \def\bn{\boldsymbol{n}}  \def\cN{\mathcal{N}} \def\cn{\mathcal{n}} \def\cbN{\boldsymbol{\mathcal{N}}}')AddLine(' \def\sfbN{\textsf{\fontseries{bx}\fontshape{sl}\selectfont N}}')Up()Joinline()
            AddLine('\def\rmO{\mathrm{O}} \def\rmo{\mathrm{o}} \def\bfO{\mathbf{O}} \def\bfo{\mathbf{o}} \def\bO{\boldsymbol{O}} \def\bo{\boldsymbol{o}}  \def\cO{\mathcal{O}} \def\co{\mathcal{o}} \def\cbO{\boldsymbol{\mathcal{O}}}')AddLine(' \def\sfbO{\textsf{\fontseries{bx}\fontshape{sl}\selectfont O}}')Up()Joinline()
            AddLine('\def\rmP{\mathrm{P}} \def\rmp{\mathrm{p}} \def\bfP{\mathbf{P}} \def\bfp{\mathbf{p}} \def\bP{\boldsymbol{P}} \def\bp{\boldsymbol{p}}  \def\cP{\mathcal{P}} \def\cp{\mathcal{p}} \def\cbP{\boldsymbol{\mathcal{P}}}')AddLine(' \def\sfbP{\textsf{\fontseries{bx}\fontshape{sl}\selectfont P}}')Up()Joinline()
            AddLine('\def\rmQ{\mathrm{Q}} \def\rmq{\mathrm{q}} \def\bfQ{\mathbf{Q}} \def\bfq{\mathbf{q}} \def\bQ{\boldsymbol{Q}} \def\bq{\boldsymbol{q}}  \def\cQ{\mathcal{Q}} \def\cq{\mathcal{q}} \def\cbQ{\boldsymbol{\mathcal{Q}}}')AddLine(' \def\sfbQ{\textsf{\fontseries{bx}\fontshape{sl}\selectfont Q}}')Up()Joinline()
            AddLine('\def\rmR{\mathrm{R}} \def\rmr{\mathrm{r}} \def\bfR{\mathbf{R}} \def\bfr{\mathbf{r}} \def\bR{\boldsymbol{R}} \def\br{\boldsymbol{r}}  \def\cR{\mathcal{R}} \def\car{\mathcal{r}}\def\cbR{\boldsymbol{\mathcal{R}}}')AddLine(' \def\sfbR{\textsf{\fontseries{bx}\fontshape{sl}\selectfont R}}')Up()Joinline()
            AddLine('\def\rmS{\mathrm{S}} \def\rms{\mathrm{s}} \def\bfS{\mathbf{S}} \def\bfs{\mathbf{s}} \def\bS{\boldsymbol{S}} \def\bs{\boldsymbol{s}}  \def\cS{\mathcal{S}} \def\cs{\mathcal{s}} \def\cbS{\boldsymbol{\mathcal{S}}}')AddLine(' \def\sfbS{\textsf{\fontseries{bx}\fontshape{sl}\selectfont S}}')Up()Joinline()
            AddLine('\def\rmT{\mathrm{T}} \def\rmt{\mathrm{t}} \def\bfT{\mathbf{T}} \def\bft{\mathbf{t}} \def\bT{\boldsymbol{T}} \def\bt{\boldsymbol{t}}  \def\cT{\mathcal{T}} \def\ct{\mathcal{t}} \def\cbT{\boldsymbol{\mathcal{T}}}')AddLine(' \def\sfbT{\textsf{\fontseries{bx}\fontshape{sl}\selectfont T}}')Up()Joinline()
            AddLine('\def\rmU{\mathrm{U}} \def\rmu{\mathrm{u}} \def\bfU{\mathbf{U}} \def\bfu{\mathbf{u}} \def\bU{\boldsymbol{U}} \def\bu{\boldsymbol{u}}  \def\cU{\mathcal{U}} \def\cu{\mathcal{u}} \def\cbU{\boldsymbol{\mathcal{U}}}')AddLine(' \def\sfbU{\textsf{\fontseries{bx}\fontshape{sl}\selectfont U}}')Up()Joinline()
            AddLine('\def\rmV{\mathrm{V}} \def\rmv{\mathrm{v}} \def\bfV{\mathbf{V}} \def\bfv{\mathbf{v}} \def\bV{\boldsymbol{V}} \def\bv{\boldsymbol{v}}  \def\cV{\mathcal{V}} \def\cv{\mathcal{v}} \def\cbV{\boldsymbol{\mathcal{V}}}')AddLine(' \def\sfbV{\textsf{\fontseries{bx}\fontshape{sl}\selectfont V}}')Up()Joinline()
            AddLine('\def\rmW{\mathrm{W}} \def\rmw{\mathrm{w}} \def\bfW{\mathbf{W}} \def\bfw{\mathbf{w}} \def\bW{\boldsymbol{W}} \def\bw{\boldsymbol{w}}  \def\cW{\mathcal{W}} \def\cw{\mathcal{w}} \def\cbW{\boldsymbol{\mathcal{W}}}')AddLine(' \def\sfbW{\textsf{\fontseries{bx}\fontshape{sl}\selectfont W}}')Up()Joinline()
            AddLine('\def\rmX{\mathrm{X}} \def\rmx{\mathrm{x}} \def\bfX{\mathbf{X}} \def\bfx{\mathbf{x}} \def\bX{\boldsymbol{X}} \def\bx{\boldsymbol{x}}  \def\cX{\mathcal{X}} \def\cx{\mathcal{x}} \def\cbX{\boldsymbol{\mathcal{X}}}')AddLine(' \def\sfbX{\textsf{\fontseries{bx}\fontshape{sl}\selectfont X}}')Up()Joinline()
            AddLine('\def\rmY{\mathrm{Y}} \def\rmy{\mathrm{y}} \def\bfY{\mathbf{Y}} \def\bfy{\mathbf{y}} \def\bY{\boldsymbol{Y}} \def\by{\boldsymbol{y}}  \def\cY{\mathcal{Y}} \def\cy{\mathcal{y}} \def\cbY{\boldsymbol{\mathcal{Y}}}')AddLine(' \def\sfbY{\textsf{\fontseries{bx}\fontshape{sl}\selectfont Y}}')Up()Joinline()
            AddLine('\def\rmZ{\mathrm{Z}} \def\rmz{\mathrm{z}} \def\bfZ{\mathbf{Z}} \def\bfz{\mathbf{z}} \def\bZ{\boldsymbol{Z}} \def\bz{\boldsymbol{z}}  \def\cZ{\mathcal{Z}} \def\cz{\mathcal{z}} \def\cbZ{\boldsymbol{\mathcal{Z}}}')AddLine(' \def\sfbZ{\textsf{\fontseries{bx}\fontshape{sl}\selectfont Z}}')Up()Joinline()
            AddLine()
            AddLine('%% Greek alphabet')
            AddLine()
            AddLine('\def\Om{\Omega}')
            AddLine('\def\om{\omega}')
            AddLine('\def\eps{\varepsilon}')
            AddLine('\def\vphi{\varphi}')
            AddLine('\def\vart{\vartheta}')
            AddLine('\def\lbd{\lambda}')
            AddLine()
            AddLine('\def\beps{\boldsymbol{\varepsilon}}')
            AddLine('\def\bell{\boldsymbol{\ell}}')
            AddLine('\def\balpha{\boldsymbol{\alpha}}')
            AddLine('\def\bbeta{\boldsymbol{\beta}}')
            AddLine('\def\bgamma{\boldsymbol{\gamma}}')
            AddLine('\def\bGamma{\boldsymbol{\Gamma}}')
            AddLine('\def\bdelta{\boldsymbol{\delta}}')
            AddLine('\def\bDelta{\boldsymbol{\Delta}}')
            AddLine('\def\bepsilon{\boldsymbol{\epsilon}}')
            AddLine('\def\bzeta{\boldsymbol{\zeta}}')
            AddLine('\def\bfeta{\boldsymbol{\eta}}')
            AddLine('\def\btheta{\boldsymbol{\theta}}')
            AddLine('\def\bvartheta{\boldsymbol{\vartheta}}')
            AddLine('\def\bTheta{\boldsymbol{\Theta}}')
            AddLine('\def\biota{\boldsymbol{\iota}}')
            AddLine('\def\bkappa{\boldsymbol{\kappa}}')
            AddLine('\def\blambda{\boldsymbol{\lambda}}')
            AddLine('\def\bLambda{\boldsymbol{\Lambda}}')
            AddLine('\def\bmu{\boldsymbol{\mu}}')
            AddLine('\def\bnu{\boldsymbol{\nu}}')
            AddLine('\def\bxi{\boldsymbol{\xi}}')
            AddLine('\def\bXi{\boldsymbol{\Xi}}')
            AddLine('\def\bpi{\boldsymbol{\pi}}')
            AddLine('\def\bvarpi{\boldsymbol{\varpi}}')
            AddLine('\def\bPi{\boldsymbol{\Pi}}')
            AddLine('\def\brho{\boldsymbol{\rho}}')
            AddLine('\def\bvarrho{\boldsymbol{\varrho}}')
            AddLine('\def\bsigma{\boldsymbol{\sigma}}')
            AddLine('\def\bvarsigma{\boldsymbol{\varsigma}}')
            AddLine('\def\bSigma{\boldsymbol{\Sigma}}')
            AddLine('\def\btau{\boldsymbol{\tau}}')
            AddLine('\def\bupsilon{\boldsymbol{\upsilon}}')
            AddLine('\def\bUpsilon{\boldsymbol{\Upsilon}}')
            AddLine('\def\bphi{\boldsymbol{\phi}}')
            AddLine('\def\bvarphi{\boldsymbol{\varphi}}')
            AddLine('\def\bPhi{\boldsymbol{\Phi}}')
            AddLine('\def\bchi{\boldsymbol{\chi}}')
            AddLine('\def\bpsi{\boldsymbol{\psi}}')
            AddLine('\def\bPsi{\boldsymbol{\Psi}}')
            AddLine('\def\bom{\boldsymbol{\omega}}')
            AddLine('\def\bOm{\boldsymbol{\Omega}}')
            AddLine('\def\bzero{\boldsymbol{0}}')
            AddLine()
            AddLine('\begin{document}')
            AddLine()
            AddLine('\end{document}')
            GotoLine(165)
            ScrollToCenter()
       when 2
            AddLine('\documentclass[11pt,portrait,semrot,semlayer]{seminar}')
            AddLine('\onlyslides{1-99}')
            AddLine('\renewcommand{\printlandscape}{\special{landscape}}')
            AddLine('\def\pdf{1}       % 0 for ps, 1 for pdf (to correct faulty topmargin)')
            AddLine('\usepackage[T1]{fontenc}')
            AddLine('\usepackage[T1,mtbold,mtpluscal]{mathtime}')
            AddLine('\usepackage{amsmath,amssymb}')
            AddLine('\usepackage{gensymb,eurosym}')
            AddLine('\usepackage{pstricks, epsfig, psfrag}')
            AddLine('\usepackage{pst-all}')
            AddLine('\usepackage{color}')
            AddLine('\usepackage{sem-a4}')
            AddLine('\usepackage{fancybox}')
            AddLine('\usepackage{graphics}')
            AddLine('\usepackage{subfigure}')
            AddLine('')
            AddLine('\renewcommand{\slideleftmargin}{15.0mm}')
            AddLine('\renewcommand{\slidetopmargin}{18mm}')
            AddLine('\slideheight152mm')
            AddLine('\ifodd\pdf')
            AddLine('    \renewcommand{\slideleftmargin}{-3mm}')
            AddLine('    \renewcommand{\slidetopmargin}{18mm}')
            AddLine('    \slideheight152mm')
            AddLine('\fi  % necessary for pdf for some unknown reason, not (!) for ps')
            AddLine('')
            AddLine('\newgray{zeerlightgray}{0.96}')
            AddLine('\newgray{verylightgray}{0.92}')
            AddLine('\newgray{Verylightgray}{0.87}')
            AddLine('\newgray{VErylightgray}{0.81}')
            AddLine('')
            AddLine('\def\b{\bullet}')
            AddLine('\font\bigmath=cmsy10 scaled \magstep2 % voor vergrote symbolen')
            AddLine('\font\Bigmath=cmsy10 scaled \magstep4 % voor vergrote symbolen')
            AddLine('\def\Sim{\mathop{\hbox{\bigmath\char24}}}')
            AddLine('\def\NSim{\mathop{\hbox{\Bigmath\char24}}}')
            AddLine('')
            AddLine('\newlength{\echtemarge}')
            AddLine('\arraycolsep1.5pt')
            AddLine('\fboxsep3mm')
            AddLine('\newlength\figbr')
            AddLine('\newlength{\fighoogte}')
            AddLine('\fighoogte = 0.9\textheight')
            AddLine('')
            AddLine('\title{\sc\LARGE Title\\[5mm]}')
            AddLine('')
            AddLine('\author{{\sc\large')
            AddLine('                   Author}\\[-2mm]')
            AddLine('        {\sc\small')
            AddLine('                   Institute}\\[5mm]}')
            AddLine('\date{\sc\footnotesize')
            AddLine('                       Conference,\\')
            AddLine('                       Place, Date }')
            AddLine('\newcommand{\heading}{\slideheading}')
            AddLine('')
            AddLine('\definecolor{tueblauw}{cmyk}{1,0.76,0,0.18}')
            AddLine('\definecolor{tuegroen}{cmyk}{0.56,0.11,0,0.43}')
            AddLine('\def\TUElogo{{\normalfont\fontfamily{zlo}\fontsize{3}{0.0pt}\selectfont')
            AddLine('                      {\color{tueblauw}1}{\color{tuegroen}2}}}')
            AddLine('\def\facnaam{{\normalfont\fontfamily{zlo}\fontsize{3}{0.0pt}\selectfont \bfseries {\color{tueblauw}/k}}}')
            AddLine('')
            AddLine('\newfont{\tcmsl}{cmsl8 at 4pt}')
            AddLine('\newpagestyle{TU}{\hspace*{1cm}\TUElogo\facnaam \hfil\thepage\ of\ \pageref{laatstepagina}\hspace*{1cm}}%')
            AddLine('{{\tcmsl\color{mylightblue} \hfil')
            AddLine('                                  S.W.R. 2006')
            AddLine('                  \hspace*{1cm}}}')
            AddLine('\pagestyle{TU}')
            AddLine('')
            AddLine('\definecolor{myyellow}{rgb}{1,1,0}')
            AddLine('\definecolor{myblue}{rgb}{0,0,.3922}')
            AddLine('\definecolor{mylightblue}{rgb}{0.4,0.0,1}')
            AddLine('\def\kopblw{\color{blue}}')
            AddLine('\def\txtblw{\color{mylightblue}}')
            AddLine('\def\txtgrn{\color{tuegroen}}')
            AddLine('\def\rd#1{\textcolor{red}{#1}}')
            AddLine('')
            AddLine('\slidesmag{3}')
            AddLine('\articlemag{1}')
            AddLine('\rotateheaderstrue')
            AddLine('\slideframe{none}')
            AddLine('')
            AddLine('\begin{document}')
            AddLine('%')
            AddLine('\begin{slide}')
            AddLine('  \maketitle')
            AddLine('\end{slide}')
            AddLine('%')
            AddLine('\begin{slide}')
            AddLine('  \mbox{}\vfil')
            AddLine('  \centerline{\sc \Large Text }')
            AddLine('  \vfil')
            AddLine('\end{slide}')
            AddLine('%')
            AddLine('\begin{slide}')
            AddLine('\mbox{}\vfil')
            AddLine('\center{{\kopblw\Large\bf Conclusions}} \\%[3mm]')
            AddLine('\begin{list}{}{\setlength{\rightmargin}{0cm}')
            AddLine('               \setlength{\listparindent}{0cm}')
            AddLine('               \setlength{\itemsep}{3mm}')
            AddLine('               \settowidth{\labelwidth}{\quad}')
            AddLine('               \setlength{\leftmargin}{1.1\labelwidth}')
            AddLine('               \setlength{\labelsep}{.1\labelwidth}}')
            AddLine('\item[$\b$~] yes')
            AddLine('\item[$\b$~] no')
            AddLine('\item[$\b$~] maybe')
            AddLine('\end{list}')
            AddLine('\mbox{}\vfil')
            AddLine('\center{$/\hspace{-11pt}\raisebox{-2.5pt}[0pt][0pt]{$\NSim$}$ }')
            AddLine('\label{laatstepagina}')
            AddLine('\end{slide}')
            AddLine('%')
            AddLine('\end{document}')
            GotoLine(43)
            ScrollToTop()
       endcase
      endif
     endif
end  IniDocu

proc CleanEps()
      if Lower(CurrExt()) == '.eps'
        PushPosition()
        PushBlock()
        UnMarkBlock()
        BegFile()
        MarkStream()
        if lFind('\c.%!PS-Adobe-.\.. EPSF-.\..','+x')
           DelBlock()
        else
           MsgBox('','no: %!PS-Adobe-x.x EPSF-x.x',_OK_)
        endif
        PopBlock()
        PopPosition()
      else
        MsgBox('','no eps-file',_OK_)
      endif
end  CleanEps

menu BoxMenu()
    title = 'Box'
    history
    command = PushKey(<Escape>)
    '&Makebox'  ,InsertText('\makebox[wdth][pos]{text}')
    '&Parbox'   ,InsertText('\parbox[t]{wdth}{text}')
    '&Rule'     ,InsertText('\rule[raise]{wdth}{hght}')
    'R&aisebox' ,InsertText('\raisebox{raise}[hght][dpth]{text}')
end  BoxMenu

menu FracMenu()
    title = 'Frac'
    history
    command = PushKey(<Escape>)
    '&Frac{}{}' ,InsertText('\frac{}{}')
    'Fr&ac ë'   ,InsertText('\frac{\partial}{\partial}')
    '&Display'  ,InsertText('\dfrac{}{}')
    '&Text'     ,InsertText('\tfrac{}{}')
    'F&rac pq'  ,InsertText('\frac')
end  FracMenu

datadef SymbolsData
   'alpha''beta''gamma''Gamma''delta''Delta''epsilon''varepsilon'
   'zeta''eta''theta''vartheta''Theta''iota''kappa''lambda''Lambda'
   'mu''nu''xi''Xi''pi''varpi''Pi''rho''varrho''sigma''varsigma'
   'Sigma''tau''upsilon''Upsilon''phi''varphi''Phi''chi''psi''Psi'
   'omega''Omega''copyright''pounds''pm''mp''times''div''ast'
   'star''circ''bigcirc''bullet''cdot''cap''bigcap''cup''bigcup'
   'uplus''biguplus''sqcap''sqcup''bigsqcup''vee''bigvee''wedge'
   'bigwedge''setminus''wr''diamond''lgroup''rgroup'
   'triangleleft''triangleright''bigtriangleup''bigtriangledown'
   'lhd''rhd''unlhd''unrhd''oplus''bigoplus''ominus''otimes'
   'bigotimes''oslash''odot''bigodot''dag''dagger''ddag''ddagger'
   'amalg''leq''prec''preceq''ll''subset''subseteq''sqsubset''sqsubseteq'
   'in''vdash''geq''succ''succeq''gg''supset''supseteq''sqsupset'
   'sqsupseteq''ni''dashv''equiv''sim''simeq''asymp''approx''cong''neq'
   'doteq''propto''models''perp''mid''parallel''bowtie''Join'
   'smile''frown''langle''rangle'
   'leftarrow''Leftarrow''rightarrow''Rightarrow'
   'leftrightarrow''Leftrightarrow''mapsto''hookleftarrow'
   'leftharpoonup''leftharpoondown''rightleftharpoons'
   'longleftarrow''Longleftarrow''longrightarrow''Longrightarrow'
   'longleftrightarrow''Longleftrightarrow''longmapsto''hookrightarrow'
   'rightharpoonup''rightharpoondown''leadsto''uparrow''Uparrow'
   'downarrow''Downarrow''updownarrow''Updownarrow''nearrow'
   'searrow''swarrow''nwarrow''overleftarrow''overrightarrow'
   'aleph''hbar''imath''jmath''ell''wp''Re''Im''mho''prime''emptyset'
   'nabla''surd''top''bot''|''angle''forall''exists''neg''flat'
   'natural''sharp''backslash''partial''infty''Box''Diamond'
   'triangle''clubsuit''diamondsuit''heartsuit''spadesuit''sum'
   'prod''coprod''int''oint''arcsin''arccos''arctan''sin''sinh'
   'cos''cosh''tan''tanh''cot''coth''sec''csc''exp''ln''log'
   'arg''deg''det''dim''gcd''hom''ker''lg''lim''sup''inf'
   'limsup''liminf''max''min''Pr''lfloor''rfloor''lceil''rceil'
   'langle''rangle''hat{ }''widehat{ }''check{ }''breve{ }'
   'acute{ }''grave{ }''tilde{ }''widetilde{ }''bar{ }''vec{ }'
   'dot{ }''ddot{ }'
end SymbolsData

integer Symbols_Line = 0

proc Symbols()
     integer Symbols_id, Current_id = GetBufferId()
     PushBlock()
     UnMarkBlock()
     Symbols_id = CreateBuffer('symbols')
     InsertData(SymbolsData)
     GotoLine(Symbols_Line)
     ScrollUp(12)
     Set(y1,2)
     if lList('Latex Symbols', 18,22,_ENABLE_SEARCH_+_ANCHOR_SEARCH_+_ENABLE_HSCROLL_)
            Symbols_line = CurrLine()
            BegLine()
            MarkColumn()
            EndLine()
            GotoBufferId(Current_id)
            InsertText('\',_INSERT_)
            CopyBlock()
            GotoBlockEnd()
            UnMarkBlock()
            PushKey(<Escape>)
     endif
     PopBlock()
     AbandonFile(Symbols_id)
end  Symbols

datadef AMSSymbData
   'Bbbk' 'Box' 'Bumpeq' 'Cap' 'Cup' 'Diamond' 'Finv' 'Game' 'Join' 'Lleftarrow' 'Lsh'
   'Rrightarrow' 'Rsh' 'Subset' 'Supset' 'Vdash' 'Vvdash' 'angle' 'approxeq' 'backepsilon'
   'backprime' 'backsim' 'backsimeq' 'barwedge' 'because' 'beth' 'between' 'bigstar'
   'binom{}{}' 'blacklozenge' 'blacksquare' 'blacktriangle' 'blacktriangledown'
   'blacktriangleleft' 'blacktriangleright' 'boxdot' 'boxminus' 'boxplus' 'boxtimes'
   'bumpeq' 'centerdot' 'checkmark'
   'circeq' 'circlearrowleft' 'circlearrowright' 'circledR' 'circledS'
   'circledast' 'circledcirc' 'circleddash' 'complement' 'curlyeqprec' 'curlyeqsucc'
   'curlyvee' 'curlywedge' 'curvearrowleft' 'curvearrowright' 'daleth' 'dbinom{}{}'
   'dfrac{}{}' 'diagdown' 'diagup' 'digamma' 'divideontimes' 'doteqdot' 'dotplus' 'dots'
   'dotsb' 'dotsc' 'dotsi' 'dotsm' 'doublebarwedge' 'downdownarrows' 'downharpoonleft'
   'downharpoonright' 'eqcirc' 'eqsim' 'eqslantgtr' 'eqslantless' 'eth' 'fallingdotseq'
   'geqq' 'geqslant' 'ggg' 'gimel' 'gnapprox' 'gneq' 'gneqq' 'gnsim' 'gtrapprox' 'gtrdot'
   'gtreqless' 'gtreqqless' 'gtrless' 'gtrsim' 'gvertneqq' 'hbar' 'hslash' 'intercal'
   'leadsto' 'leftarrowtail' 'leftleftarrows' 'leftrightarrows' 'leftrightharpoons'
   'leftrightsquigarrow' 'leftthreetimes' 'leqq' 'leqslant' 'lessapprox' 'lessdot'
   'lesseqgtr' 'lesseqqgtr' 'lessgtr' 'lesssim' 'lhd' 'lll' 'lnapprox' 'lneq' 'lneqq'
   'lnsim' 'looparrowleft' 'looparrowright' 'lozenge' 'ltimes' 'lvertneqq' 'maltese' 'measuredangle'
   'mho' 'multimap' 'nLeftarrow' 'nLeftrightarrow' 'nRightarrow' 'nVDash' 'nVdash' 'ncong'
   'nexists' 'ngeq' 'ngeqq' 'ngeqslant' 'ngtr' 'nleftarrow' 'nleftrightarrow' 'nleq'
   'nleqq' 'nleqslant' 'nless' 'nmid' 'nparallel' 'nprec' 'npreceq' 'nrightarrow'
   'nshortmid' 'nshortparallel' 'nsim' 'nsubseteq' 'nsubseteqq' 'nsucc' 'nsucceq'
   'nsupseteq' 'nsupseteqq' 'ntriangleleft' 'ntrianglelefteq' 'ntriangleright'
   'ntrianglerighteq' 'nvDash' 'nvdash' 'overset{}{}' 'pitchfork' 'precapprox'
   'preccurlyeq' 'precnapprox' 'precneqq' 'precnsim' 'precsim' 'rhd' 'rightarrowtail'
   'rightleftarrows' 'rightleftharpoons' 'rightrightarrows' 'rightsquigarrow'
   'rightthreetimes' 'risingdotseq' 'rtimes' 'shortmid' 'shortparallel' 'sideset{}{}{}'
   'smallfrown' 'smallsetminus' 'smallsmile' 'sphericalangle' 'sqsubset' 'sqsupset'
   'square' 'subseteqq' 'subsetneq' 'subsetneqq' 'succapprox' 'succcurlyeq' 'succnapprox'
   'succneqq' 'succnsim' 'succsim' 'supseteqq' 'supsetneq' 'supsetneqq' 'tbinom{}{}'
   'tfrac{}{}' 'therefore' 'thickapprox' 'thicksim' 'triangledown' 'trianglelefteq'
   'triangleq' 'trianglerighteq' 'twoheadleftarrow' 'twoheadrightarrow' 'underset{}{}'
   'unlhd' 'unrhd' 'upharpoonleft' 'upharpoonright' 'upuparrows' 'vDash' 'varkappa'
   'varnothing' 'varpropto' 'varsubsetneq' 'varsubsetneqq' 'varsupsetneq' 'varsupsetneqq'
   'vartriangle' 'vartriangleleft' 'vartriangleright' 'veebar'
end AMSSymbData

integer AMSSymb_Line = 0

proc AMSSymb()
     integer AMSSymb_id, Current_id = GetBufferId()
     PushBlock()
     UnMarkBlock()
     AMSSymb_id = CreateBuffer('amssymb')
     InsertData(AMSSymbData)
     GotoLine(AMSSymb_Line)
     ScrollUp(12)
     Set(y1,2)
     if lList('AMS Symbols', 18,22,_ENABLE_SEARCH_+_ANCHOR_SEARCH_+_ENABLE_HSCROLL_)
            AMSSymb_line = CurrLine()
            BegLine()
            MarkColumn()
            EndLine()
            GotoBufferId(Current_id)
            InsertText('\',_INSERT_)
            CopyBlock()
            GotoBlockEnd()
            UnMarkBlock()
            PushKey(<Escape>)
     endif
     PopBlock()
     AbandonFile(AMSSymb_id)
end  AMSSymb

proc ShowSymbols()
     if gsviewhs <> 0
        TerminateProcess(gsviewhs, 0)
     endif
     gsviewhs = lDos(gsview,SplitPath(myhelp,_DRIVE_|_PATH_)+'symbols.ps.gz',_DONT_WAIT_|_RUN_DETACHED_|_RETURN_PROCESS_HANDLE_)
end

datadef LatComsData
  'abovedisplayshortskip''abovedisplayskip'
  'addcontentsline{file}{sec_unit}{entry}''address{Return address}'
  'addtocontents''addtocounter{counter}{value}''addtolength{\gnat}{length}'
  'addvspace''advancepageno''alph{counter}''Alph{counter}''and'
  'appendix''arabic''arraycolsep''arrayrulewidth''arraystretch'
  'author{names}''baselineskip''baselinestretch''batchmode''section'
  'belowdisplayshortskip''belowdisplayskip''bibindent'
  'bibitem[label]{cite_key}''bibliography''bibliographystyle''bigskip'
  'bigskipamount''blackandwhite''boldmath''boldsymbol''bottomfraction''Box'
  'bye''caption{title}''cdot''cdots''centering''chapter''check''choose'
  'circle[*]{diameter}''cite[text]{key_list}''cleardoublepage''clearpage'
  'cleartabs''cline{i-j}''closing{text}''colors''colorslides''columnsep'
  'columnseprule''dashbox''dashv''date{text}''dblfloatpagefraction'
  'dblfloatsep''dbltextfloatsep''dbltopfraction''ddot''ddots''def''det'
  'displaystyle''documentstyle[options]{style}''dosupereject''dotfill'
  'emptyset''encl''endinsert''eqalignno''eqalign''evensidemargin'
  'extracolsep''fbox{text}''fboxrule''fboxsep''fill''fivebf''fivei''fiverm'
  'fivesy''flat''floatpagefraction''floatsep''flushbottom'
  'fnsymbol{counter}''folio''footheight''footline''footnote[number]{text}'
  'footnotemark''footnoterule''footnoresep''footnotesize''footnotetext'
  'footskip''footstrut''frac{num}{den}''frame'
  'framebox[width][position]{text}''frenchspacing''glossary{str}'
  'glossaryentry''gnat''headheight''headline''headsep'
  'heartsuit''hfill''hline''hookleftarrow''hookrightarrow''hrule'
  'hrulefill''hspace{length}''hspace*{length}''hspace{\value{foo}\parindent}'
  'hyphenation''include{file}''includeonly{file_list}''indent''input{file}'
  'index{str}''indexentry{str}{pg}''indexspace''input''intextsep''int'
  'int\limits''iint''iint\limits''iiint''iiint\limits''idotsint'
  'idotsint\limits''invisible''item[label]''itemindent''itemsep''ker''kill'
  'label{key}''labelitemi''labelsep''labelwidth''LaTeX''ldots''left'
  'lefteqn''leftmargin''leftmatgini''leqalignno'
  'line(x slope,y slope){length}''linebreak''linethickness{dimension}'
  'linewidth{dimension}''listoffigures''listoftables''listparindent'
  'load''location''magnification''makebox(width,height)[position]'
  'makebox[width][position]{text}''makefootline''makeglossary'
  'makeheadline''makeindex''makelabel''makelabels''maketitle'
  'marginpar''marginparpush''marginparsep''marginparwidth''mark'
  'markboth{left head}{right head}''markright{right head}''mathindent'
  'mbox''medskip''medskipamount''mid''midinsert''mit''mspace{n mu}'
  'multlinegap' 'multicolumn{cols}{pos}{text}'
  'multiput(x ,y)(dx,dy){#copies}{object}''newcommand{cmd}[args]{def}'
  'newcounter{foo}[counter]''newenvironment{nam}[args]{begdef}{enddef}'
  'newfont{cmd}{font_name}''newlength''newline''newpage''newsavebox'
  'newtheorem{env_name}[numbered_like]{caption}[within]'
  'nocite{key_list}''nofiles''noindent''nolinebreak''nonfrenchspacing'
  'nonumber''nopagebreak''nopagenumbers''normalbottom'
  'normalmarginpar''normalsize''numberline''numberwithin{equation}{section}'
  'oddsidemargin''oldstyle''onecolumn''onlynotes''onlyslides''opening{text}'
  'oval(width,height)[portion]''overbrace''overline''pagebody'
  'pagebreak''pagecontents''pageinsert''pageno''pagenumbering{num_style}'
  'pageref''pagestyle''par''paragraph''parbox[position]{width}{text}'
  'parindent''parsep''parskip''part''partopsep''phantom{}''vphantom{}'
  'hphantom{}''plainoutput''poptabs''protect''ps''pushtabs'
  'put(x coord,y coord){ ... }''qquad''quad''raggedbottom''raggedleft'
  'raggedright''raisebox{raise-hght}[ext-above][ext-below]{text}''ref{key}'
  'refstepcounter''renewcommand{cmd}[args]{def}'
  'renewenvironment{nam}[args]{begdef}{enddef}''reversemarginpar''right'
  'rightmargin''roman''Roman''rule[raise-hght]{width}{height}'
  'samepage''savebox{cmd}[width][pos]{text}''sbox{cmd}[text]''sc'
  'scriptfont''scriptscriptfont''scriptscriptstyle''scriptsize''scriptstyle'
  'section''setcounter{counter}{value}''setlength{\gnat}{length}'
  'setminus''settabs''settowidth{\gnat}{text}''sevenbf''seveni'
  'sevensy''shortstack[position]{... \\ ... \\ ...}''signature{Your name}'
  'sloppy''small''smallskip''smallskipamount''smash[t/b]{..}''space'
  'sqrt[root]{arg}''stackrel''stepcounter''stop''stretch''subitem'
  'subparagraph''subsection''subsubitem''subsubsection''symbol''tabalign'
  'tabbingsep''tabcolsep''tableofcontents''tabs''tabsdone''tabset'
  'tag{}''tag*{}''teni''TeX''text{}''textfloatsep''textfont''textfraction'
  'textheight''textstyle''textwidth''telephone{number}''thanks'
  'thicklines''thinlines''thispagestyle''title{text}''today''topfraction'
  'tops''topinsert''topmargin''topsep''topskip''twocolumn''typein[cmd]{msg}'
  'typeout{msg}''unboldmath''underbrace''underline''unitlength''usebox{cmd}'
  'usecounter' 'usepackage{}''value''vdash''vdots'
  'vector(x slope,y slope){length}''verb char literal_text char'
  'verb* char literal_text char''verse''vfill''vfootnote''vline'
  'vspace{length}''vspace*{length}''vspace{\bigskipamount}'
  'vspace{\medskipamount}''vspace{\smallskipamount}'
end LatComsData

integer LatComs_Line = 0

proc LatComs()
     integer LatComs_id, Current_id = GetBufferId()
     PushBlock()
     UnMarkBlock()
     LatComs_id = CreateBuffer('LatComs')
     InsertData(LatComsData)
     GotoLine(LatComs_Line)
     ScrollUp(12)
     Set(y1,2)
     if lList('Latex Commands', 25,22,_ENABLE_SEARCH_+_ANCHOR_SEARCH_+_ENABLE_HSCROLL_)
            LatComs_Line = CurrLine()
            BegLine()
            MarkColumn()
            EndLine()
            GotoBufferId(Current_id)
            InsertText('\',_INSERT_)
            CopyBlock()
            GotoBlockEnd()
            UnMarkBlock()
            PushKey(<Escape>)
     endif
     PopBlock()
     AbandonFile(LatComs_id)
end  LatComs

proc main()
     ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
     Configure()
end

//proc ShowHandles()                           // test proc for handles
//     CreateBuffer('')
//     Addline(Str(length(gsviewh1)))
//     Addline(gsviewh1)
//     Addline(Str(gsviewh))
//     Addline(Str(gsviewhb))
//     Addline(Str(gsviewhs))
//end

<F12>                MainPsFileNames() Latexmenu()
<Shift F12>          Commands()
<CtrlShift F12>      ZipMenu()
<Ctrl F12>           EditFile('*.tex')
<Alt F12>            EditFile(iif(mainfile[1]=='','*.*',QuotePath(SplitPath(Mainfile,_DRIVE_|_NAME_)+'.*')))
<CtrlAlt I>          Indexs()
<CtrlAlt B>          FindBE()
<Alt B>              lFind('\begin{','i+')
<Ctrl B>             lFind('\begin{','bi+')
<Alt Q>              TeXWrapPara()
<Ctrl \>             EnvFinish()
<CtrlShift \>        EnvDel()
