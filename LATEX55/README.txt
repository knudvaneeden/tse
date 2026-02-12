1. -To install

     1. -Take the file latex55_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstalllatex55.bat

     4. -That will create a new file latex55_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          latex.mac

2. -The .ini file is the local file 'latex55.ini'
    (thus not using tse.ini)

===

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
