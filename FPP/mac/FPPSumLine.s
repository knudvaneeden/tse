/*******************************************************************************

  Filename     : FppSumLine.s

  Author       : Eckhard Hillmann

  Creation Date: 14. March 2022

  ****************************************************************************
  This software is provided "as is" without express or implied warranty.
  ****************************************************************************

  Description:
  ============
  FppSumLine provides management functions for the line parser FppCon_xxx.exe
  where all the calculations are done. It provides the necessary files for the
  exe and does the result presentation using the returned data file.

  When started a marked column block to work with is expected.

  This macro calls FppCon_xxx.exe with the needed number of arguments and
  inserts the sum block with a minimum distance of one space (default) right
  next the marked block.

  The total sum, if selected, is appended to the sum block.

  For more details see FppHelp.txt (section FppSumLine).

  History:
  ========
  Jan 2025: Version 1.0.0.54
            First public release

  Feb 2025: Version 1.0.0.57
            - Added TOC (T)able (O)f (C)ontents and unified help handling to
              all Fpp* macros.
            Thanks to Joachim Merkel who inspired me to add this.

  Mar 2025: Version 1.0.0.62
            - Unified TOC-Handling.
            - Added TOC-Marker sign to menu to let the user select/set his own
              marker when he added/changed them in FppHelp.txt. The setting is
              individual for each macro.
            Special thanks to Joachim Merkel for his feedback, suggestions
            and testing.

  Apr 2025: Version 1.0.0.65
            - Internal cleaneup
            - Fixed flashing cursor in menu when leaving help
            - More error checking

  Dec 2025: Version 1.0.0.75
            - Cosmetic changes, minor fixes and improvements

  Mar 2026: Version 1.0.0.82
            - Improved handling of very very rare cases
            - Minor fixes and improvements

  Aug 2026: Version 1.0.0.83
            - Portable support-file lookup relative to the macro directory
            - Execute GetFileVersion.mac by its full macro-relative path

  Examples:
  =========
  Mark the area within the single lines with a column block to get the sum of
  each line and the total sum.
  +--------------------------------+=========+
  |a=1.25:b=5: a * 1,167.2 + 47.112|1,506.112| -+
  |1,120.20 + b                    |1,125.200|  |
  |30.30 / b                       |    6.060|  |
  |$ff - 10 / 4                    |  252.500|  |
  |              d=47              |         |  |
  |3.1415e2                        |  314.150|  +-> sum of each line
  |40.40                           |   40.400|  |
  |              i=23              |         |  |
  |- 50.50                         |  -50.500|  |
  |         pro(100|19)            |   19.000|  |
  |2 * 17.5 : 3 * 20               |   95.000| -+
  +--------------------------------+3,307.922| total sum, only if selected
                                   +=========+
                                    +---+---+
                                        V
                                    Generated and inserted sum block
                                    including total sum.

  y = SinDeg(x)   for x = 0 to 90 step 10
  +-------------------------------------+==================================+
  |step = 10                            |                                  |
  |x = 0: SinDeg(x)          //   0  y =| 0                                |
  |x = x + step: SinDeg(x)   //  10  y =| 0.1736481776669303488517166267693|
  |x = x + step: SinDeg(x)   //  20  y =| 0.3420201433256687330440996146823|
  |x = x + step: SinDeg(x)   //  30  y =| 0.5                              |
  |x = x + step: SinDeg(x)   //  40  y =| 0.6427876096865393263226434099073|
  |x = x + step: SinDeg(x)   //  50  y =| 0.7660444431189780352023926505554|
  |x = x + step: SinDeg(x)   //  60  y =| 0.8660254037844386467637231707529|
  |x = x + step: SinDeg(x)   //  70  y =| 0.9396926207859083840541092773247|
  |x = x + step: SinDeg(x)   //  80  y =| 0.9848077530122080593667430245895|
  |x = x + step: SinDeg(x)   //  90  y =| 1                                |
  +-------------------------------------+==================================+
                                         +---------------+----------------+
                                                         V
                                          Generated and inserted sum block,
                                        without total sum, no right alignment.

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !!                                                                 !!
  !! The following was done to show what may happen if you don't pay !!
  !! attention to the used localization and select the wrong format. !!
  !!                                                                 !!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   Non-US is correctly used here.            US-Standard is wrongly used here.

   Item        ea.                   EURO    Item        ea.                   EURO
  +---------------------------------+=====+ +---------------------------------+=====+
  |Salad     = 0,99 : Salad     * 2 | 1,98| |Salad     = 0,99 : Salad     * 2 |  198|
  |Bread     = 0,39 : Bread     * 9 | 3,51| |Bread     = 0,39 : Bread     * 9 |  351|
  |Cheese    = 0,59 : Cheese    * 6 | 3,54| |Cheese    = 0,59 : Cheese    * 6 |  354|
  |Chocolate = 2,79 : Chocolate * 3 | 8,37| |Chocolate = 2,79 : Chocolate * 3 |  837|
  |Peanuts   = 2,29 : Peanuts   * 2 | 4,58| |Peanuts   = 2,29 : Peanuts   * 2 |  458|
  +---------------------------------+21,98| +---------------------------------+2,198|
                                    +=====+                                   +=====+

 *******************************************************************************/
// = TRUE shows statusbar in FppBuildResultBlock() and FppAlignResults()
#define USE_STATUSBAR  TRUE

// Used DLLs, used functions and constants to include here
#define GET_OS_VERSION_STRING   TRUE
#define GET_IS_WOW64            TRUE
#define GET_SYSTEM_CLOCK_TICKS  TRUE
#define RUN_APPLICATION         TRUE
#define QUERY_LOCALE_INFO       TRUE

#include ["BO_Helper.inc"]

// Used includes
#include ["FPPError.h"]

// Constants used for output and dimensions
constant LINES_DISPLAY_SIZE = 15
constant TIME_TAKEN_LENGHT  = 32

// Statusbar
#if USE_STATUSBAR
  constant BAR_SIZE = 50
#endif

// Window sizes
constant WIN_HEIGHT = 11
constant WIN_WIDTH  = 53

// About window size
constant WIN_ABOUT_HEIGHT = 11
constant WIN_ABOUT_WIDTH  = 42

// Textlength and positions
constant STAT_TXT_LEN      = 50

constant X_TEXT            = 2

constant Y_COPY_BLOCK      = 1
constant Y_NORM_BLOCK      = 2
constant Y_DET_FRAC        = 3
constant Y_WRITE_BLOCK     = 4
constant Y_CALCULATE       = 5
constant Y_LOAD_RES        = 6
constant Y_BUILD_RES_BLOCK = 7
constant Y_BUILD_BAR       = 7
constant Y_ALIGN_RES       = 8
constant Y_ALIGN_BAR       = 8
constant Y_INSERT_RES      = 9

// Fraktional digits in result, Range 0-99
constant FLOAT_DECIMALS     = 30
constant FLOAT_MAX_DECIMALS = 99

// Color help marker
constant DEFAULT_COL_HELP_MARKER = 0x8A

// Size of TOC-Marker
constant TOC_MARKER_SIZE   = 5

// Size of version strings
constant OS_VERSION_LENGTH = 30

// Return-codes for EndProcess
constant EP_ABORT          =  0
constant EP_FPP_HELP_TOC   = -15

// Codes for Statusdisplay
constant STAT_COPY_BLOCK = 0,
         STAT_NORM_BLOCK,
         STAT_DET_FRAC,
         STAT_WRITE_BLOCK,
         STAT_CALCULATE,
         STAT_LOAD_RESULT,
         STAT_BUILD_RES_BLOCK,
         STAT_ALIGN_RES,
         STAT_INSERT_RES

// Possible result localizations
constant LOCALE_US = 1,         // -us
         LOCALE_NU,             // -nu
         LOCALE_SY              // -sy
// The sequence in this string must match the above constants
string gcLocaleSelector[] = "-us -nu -sy"

// Filenames used for data exchange with FppCon_xxx.exe
string gcFileResult[]     = "FppSumLineRes.txt"
string gcFileExpression[] = "FppSumLineExp.txt"

// Filename FppShell help
string gcFileHelp[]       = "FppHelp.txt"

// Filename used for redirection when in console mode only
string gcFileRedirect[]   = "FppRedir.txt"

// Used paths for EXE, DLL, MAC and TXT
string gcLoadDir[_MAXPATH_] = ""
string gcMacDir[_MAXPATH_]  = ""

// Identifier for exe-version/-name x86 and x64 and macro
string gcExe_x64[]    = "FppCon_x64.exe" // 64-Bit OS
string gcExe_x86[]    = "FppCon_x86.exe" // 32-Bit OS

string gcExeName[16]  = ""               // min length is longest exe-name
string gcNeedExeVer[] = "2.4.3.26"       // min needed exe version

string gcDllName[]    = "BO_Helper.dll"  // name of helper dll
string gcNeedDllVer[] = "1.9.1.28"       // min needed dll version

string gcMacVersion[] = "1.0.0.83"

// Versiondata of exe and dll
string gcExeVersion[23] = ""
string gcDllVersion[23] = ""
string gcOsVersion[OS_VERSION_LENGTH] = ""

// Identifier used for TSE.INI
string gcTSE_INI_KEY[]     = "FppSumLine"
string gcBUILD_SUM_INI[]   = "BuildSum"
string gcNUM_SPACES_INI[]  = "NumSpaces"
string gcALIGN_RES_INI[]   = "AlignResult"
string gcDIGITS_INI[]      = "Digits"
string gcTocMarkerString[] = "TocMarkerString"

string gcTSE_HELP_KEY[]    = "FppHelp"
string gcColHelpMarker[]   = "ColHelpMarker"

// Constant Errormessages
string gcErrorOpenFile[]  = "Error open file: "
string gcErrorCloseFile[] = "Error close file: "
string gcErrorReadFile[]  = "Error read file: "
string gcErrorWriteFile[] = "Error write file: "

// Error strings
string gcErrorText[MAXSTRINGLEN]  = ""
string gcMathError[MAXSTRINGLEN]  = ""
string gcExpression[MAXSTRINGLEN] = ""

// Result string
string gcTimeTaken[TIME_TAKEN_LENGHT]       = ""
string gcTimeCompRun[TIME_TAKEN_LENGHT]     = ""
string gcLinesProcessed[LINES_DISPLAY_SIZE] = ""

// Position for marking
string gcTocLine[20] = ""

// Used marker for TOC
string gcTocMarker[TOC_MARKER_SIZE] = "#"

// Lacalization data
string gcSystemDecimalSep[5]  = ""
string gcSystemThousandSep[5] = ""
string gcSystemGrouping[10]   = ""

// Defaults of global variables
integer gnLineCount     = 0
integer gnErrorPos      = 0
integer gnBuildSum      = -1
integer gnAlignRes      = -1
integer gnNumSpaces     = 1            // min 1 space distance
integer gnResLocale     = LOCALE_US
integer gnDigits        = FLOAT_DECIMALS
integer gnColHelpMarker = 0

// Handles used for redirection when in console mode only
integer gnHandStdOut = 0
integer gnHandErrOut = 0

// Declaration of used procs etc.
forward proc Main()
forward proc WhenLoaded()
forward proc WhenPurged()
forward proc FppOnAbandonEditor()
forward integer proc FppGetLocaleInfo(integer vnLocalType, integer vnInfoType, var string rcInformation)
forward KeyDef FppHelpKeysSl
forward KeyDef FppHelpTocKeysSl
forward proc FppEnableHelpKeys()
forward proc FppDisableHelpKeys()
forward proc FppEnableTocKeys()
forward proc FppDisableTocKeys()
forward proc FppEnableErrorFooter()
forward proc FppHelp(string vcHelpSearch)
forward proc FppHiliteText()
forward proc FppDrawHelpLine(integer vfIsCursor)
forward proc FppHelpTOC()
forward proc FppDrawTocLine(integer vfIsCursor)
forward proc FppShowErrors(integer vnErrors)
forward string proc FppYesNoStr(integer vnSelect)
forward string proc FppToggleInsTotal()
forward string proc FppToggleAlign()
forward proc FppNumSpaces()
forward menu FppBlockLokalizedMenu()
forward proc FppEnterDigits()
forward proc FppEditTocMarker()
forward string proc FppLocalizeResult(string vcDecimalSep, string vcThousandSep, string vcGrouping, string vcResultToFormat)
forward integer proc FppBuildResultBlock(integer vnInResultBuffer, integer vnLines, integer vnAddSum, integer vnFraction,
                                         integer vnIsFracInBlock, integer vnAlignRight, string vcDecimalSep)
forward integer proc FppAlignResults(integer vnResultBuffer, integer vnLines, integer vnAlignRight)
forward integer proc FppOpenProgress(integer vnYPos)
forward proc FppSetStatus(integer vnStatus)
forward proc FppStartRedirect(string vcFile, var integer rnStdOut, var integer rnStdErr)
forward proc FppEndRedirect(string vcFile, integer vnStdOut, integer vnStdErr)
forward proc FppAbout()

///*****************************************************************************
///
/// Main
///
/// Opening the main window and flow control
///
///*****************************************************************************
proc Main()

  integer nLineLength        = 0
  integer nTempBuffer        = 0
  integer nResultBlockBuffer = 0
  integer nProcess           = 0
  integer nRetVal            = 0
  integer nFraction          = 0
  integer nIsFracInBlock     = FALSE
  integer nDefaultFracDigits = 2
  integer nSystemFracDigits  = 2
  integer nTickStart         = 0
  integer nTickStop          = 0
  integer nCurrLine          = CurrLine()
  integer nCurrRow           = CurrRow()
  integer nCurrPos           = CurrPos()
  integer nCurrXOffset       = CurrXOffset()
  integer nyPos              = WhereYAbs()
  integer nOldBuffer         = GetBufferId()

  string cDecimalSep[5]        = ""
  string cThousandSep[5]       = ""
  string cGrouping[10]         = ""
  string cBuffer[MAXSTRINGLEN] = ""

  // Determine if OS is 32 or 64 bit and select suitable exe
  if GetIsWow64()
    gcExeName = gcExe_x64     // 64-Bit OS
  else
    gcExeName = gcExe_x86     // 32-Bit OS
  endif

  // Resolve support files relative to this macro, not to g32.exe/e32.exe.
  gcMacDir  = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
  gcLoadDir = gcMacDir
  SetDllDirectory(gcLoadDir)

  // Always query EXE- and DLL-version, because they could have been changed
  cBuffer = Str(VERSION_GT_EQ) + "|" + gcNeedExeVer + "|" + gcLoadDir + gcExeName
  ExecMacro('"' + gcMacDir + 'GetFileVersion.mac" ' + cBuffer)
  gcExeVersion = GetGlobalStr("FileVersionString")

  cBuffer = Str(VERSION_GT_EQ) + "|" + gcNeedDllVer + "|" + gcLoadDir + gcDllName
  ExecMacro('"' + gcMacDir + 'GetFileVersion.mac" ' + cBuffer)
  gcDllVersion = GetGlobalStr("FileVersionString")

  cBuffer = ""

  if gcExeVersion == "" or gcDllVersion == ""
    // Terminate because of previous message
    PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
    return()
  endif

  // Column block has to be marked
  if isBlockInCurrFile() <> _COLUMN_
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_),
           "Column-block must be marked!",
           _OK_
          )
    return()
  endif

  // No insert in browse mode
  if BrowseMode()
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_),
           "Browse-Mode is activ!" + Chr(13) + Chr(13) +
           "Results can't be inserted into file.",
           _OK_
          )
    return()
  endif

  // For info only
  if GetOsVersionString(gcOsVersion)
    // Remove brackets
    gcOsVersion = StrReplace("[\[\]]", gcOsVersion, "", "x")
  // Version couldn't be build ?!
  else
    gcOsVersion = "???"
  endif

  // Loaded from a different section
  gnColHelpMarker = GetProfileInt(gcTSE_HELP_KEY, gcColHelpMarker, DEFAULT_COL_HELP_MARKER)

  // System Decimalseparator
  if FppGetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDECIMAL, gcSystemDecimalSep)
    gcSystemDecimalSep = "."
  endif

  // System Thousandseparator
  if FppGetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_STHOUSAND, gcSystemThousandSep)
    gcSystemThousandSep = ","
  endif

  // System Grouping
  if FppGetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SGROUPING, gcSystemGrouping)
    gcSystemGrouping = "3;0"
  endif

  // System Fractional digits
  if FppGetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_IDIGITS, cBuffer)
    cBuffer = "2"
  endif

  nSystemFracDigits = Val(cBuffer)

  // Ask for number format to use
  case FppBlockLokalizedMenu()
  // US format is used
  when 1
    gnResLocale        = LOCALE_US
    cDecimalSep        = "."
    cThousandSep       = ","
    cGrouping          = "3;0"
    nDefaultFracDigits = 2

  // Non-US format
  when 2
    gnResLocale        = LOCALE_NU
    cDecimalSep        = ","
    cThousandSep       = "."
    cGrouping          = "3;0"
    nDefaultFracDigits = 2

  // System-Default format
  when 3
    gnResLocale        = LOCALE_SY
    cDecimalSep        = gcSystemDecimalSep
    cThousandSep       = gcSystemThousandSep
    cGrouping          = gcSystemGrouping
    nDefaultFracDigits = nSystemFracDigits

  // Quit
  otherwise
    UpdateDisplay(_STATUSLINE_REFRESH_)
    return()
  endcase

  // Open status/progress
  if FppOpenProgress(nyPos) == FALSE
    return()
  endif

  // Prepare block for calculation
  nTickStart = GetSystemClockTicks()
  PushBlock()
  nTempBuffer = CreateTempBuffer()
  SetUndoOff()                              // saves memory and time

  FppSetStatus(STAT_COPY_BLOCK)
  if CopyBlock() == 0
    PopWinClose()                           // close status/progress
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_),
           "Block couldn't be copied!",
           _OK_
          )
    AbandonFile(nTempBuffer)
    GotoBufferId(nOldBuffer)
    PopBlock()
    return()
  endif

  FppSetStatus(STAT_NORM_BLOCK)
  lReplace(Trim(cThousandSep), "", "ign")   // remove thousandseparator
  lReplace(Trim(cDecimalSep), ".", "ign")   // replace local decimalseparator

  // Convert tab to space to get the right errorposition for display if necessary
  BegFile()
  while lFind(Chr(9), "i")
    ExpandTabsToSpaces()
  endwhile

  lReplace(" #", "", "$gnx")                // remove all trailing spaces

  // Determine number of fractional digits, *only* when align right is selected
  FppSetStatus(STAT_DET_FRAC)
  if gnAlignRes
    if lFind("\.[ 0-9Ee]#", "gx")
      repeat
        MarkFoundText()
        // check if behind a remark -> no action necessary
        if lFind("//", "bc")
          EndLine()
        else
          cBuffer = GetMarkedText()
          // Exponential values are *not* taken into account
          if StrFind("E", cBuffer, "i") == 0
            nFraction = Max(nFraction, Length(StrReplace(" ", cBuffer, "")))
          endif
          GotoBlockEndCol()
        endif
      until lFind("\.[ 0-9Ee]#", "x") == 0

      nFraction = nFraction - 1             // because of decimal separator

      if nFraction > 0
        nIsFracInBlock = TRUE
      endif
    endif

    nFraction = Min(Max(nDefaultFracDigits, nFraction), FLOAT_MAX_DECIMALS)
  endif

  // Store file for evaluation
  FppSetStatus(STAT_WRITE_BLOCK)
  if SaveAs(gcMacDir + gcFileExpression, _OVERWRITE_) == 0
    PopWinClose()                           // Close status
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_),
           "Error writing file:" + Chr(13) +
           gcMacDir + gcFileExpression + Chr(13),
           _OK_
          )
    AbandonFile(nTempBuffer)
    GotoBufferId(nOldBuffer)
    PopBlock()
    return()
  endif

  AbandonFile(nTempBuffer)
  GotoBufferId(nOldBuffer)
  PopBlock()

  FppSetStatus(STAT_CALCULATE)

  // Only necessary when running in console-mode
  if not isGui()
    FppStartRedirect('"' + gcMacDir + gcFileRedirect + '"', gnHandStdOut, gnHandErrOut)
  endif

  // SumLine file
  // Repacement for ldos()
  // ldos() doesn't deliver the needed return value and can't handle the window
  // nProcess -> >0 = Process was started
  //              0 = Process couldn't get started
  //             <0 = OS-Errormessage
  nProcess = RunApplication('"' + gcLoadDir + gcExeName + '"',
                            "Sl " +
                            '"-e' + gcMacDir + gcFileExpression + '" ' +
                            '"-r' + gcMacDir + gcFileResult     + '"'  +
                            " -d" + str(gnDigits) +
                            " " + GetToken(gcLocaleSelector, " ", gnResLocale),
                            START_APP_GET_RETURN,
                            SW_HIDE, // SW_SHOWMINNOACTIVE,
                            nRetVal
                           )

  // Only necessary when running in console-mode
  if not isGui()
    FppEndRedirect(gcMacDir + gcFileRedirect, gnHandStdOut, gnHandErrOut)
  endif

  // Everything went well
  if nProcess > 0
    // Load resultfile
    if FindThisFile(gcMacDir + gcFileResult) == FALSE
      PopWinClose()                         // Close status
      Warn("Error loading " + gcMacDir + gcFileResult +", File not found")
      return()
    endif

    // Get results from file
    PushBlock()
    nResultBlockBuffer = CreateTempBuffer()
    SetUndoOff()                            // Saves memory and time
    FppSetStatus(STAT_LOAD_RESULT)

    if InsertFile(gcMacDir + gcFileResult, _DONT_PROMPT_) == 0
      AbandonFile(nTempBuffer)
      PopWinClose()                         // Close status
      MsgBox(SplitPath(CurrMacroFilename(), _NAME_),
             "Resultfile couldn't be loaded!" + Chr(13) +
             gcMacDir + gcFileResult + Chr(13),
             _OK_
            )
      GotoBufferId(nOldBuffer)
      PopBlock()
      return()
    endif

    gcErrorText  = ""
    gcMathError  = ""
    gcExpression = ""
    gnLineCount  = 0
    gnErrorPos   = 0

    if lReplace("[ET]", "", "g^1")
      gcErrorText = GetText(1, MAXSTRINGLEN)
    endif

    if lReplace("[ME]", "", "g^1")
      gcMathError = GetText(1, MAXSTRINGLEN)
    endif

    if lReplace("[EXPR]", "", "g^1")
      gcExpression = GetText(1, MAXSTRINGLEN)
    endif

    if lReplace("[LC]", "", "g^1")
      gnLineCount   = Val(GetText(1, 10))
    endif

    if lReplace("[COMP_RUN_COUNT]", "", "g^1")
      gcLinesProcessed = GetText(1, 10)
    endif

    if lReplace("[EP]", "", "g^1")
      gnErrorPos = Val(GetText(1, 10))
    endif

    if lReplace("[TIME_OVERALL]", "", "g^1")
      gcTimeTaken = LTrim(GetText(1, TIME_TAKEN_LENGHT))
    endif

    if lReplace("[TIME_COMP_RUN]", "", "g^1")
      gcTimeCompRun = LTrim(GetText(1, TIME_TAKEN_LENGHT))
    endif

    // In case of error free memory by closing the resultfile, it's not needed anymore
    if nRetVal <> ERROR_NO_ERROR
      PopWinClose()                         // Close status
      AbandonFile(nResultBlockBuffer)
      GotoBufferId(nOldBuffer)
      PopBlock()
    endif

    // No error, get result to the corresponding line
    if nRetVal == ERROR_NO_ERROR

      // Position cursor just behind the top right border of the marked block
      GotoBufferId(nOldBuffer)
      PopBlock()
      GotoBlockBegin()
      GotoBlockEndCol()
      Right()
      PushBlock()

      // Create result buffer and format the results
      FppSetStatus(STAT_BUILD_RES_BLOCK)
      gnLineCount = FppBuildResultBlock(nResultBlockBuffer, gnLineCount, gnBuildSum, nFraction, nIsFracInBlock, gnAlignRes, cDecimalSep)

      // Results are present
      if gnLineCount
        // Align the results
        FppSetStatus(STAT_ALIGN_RES)
        nLineLength = FppAlignResults(nResultBlockBuffer, gnLineCount, gnAlignRes)

        // Mark column block in result buffer
        GotoBufferId(nResultBlockBuffer)
        MarkColumn(1, 1, gnLineCount, nLineLength)

        // Move formatted results into source text
        FppSetStatus(STAT_INSERT_RES)
        GotoBufferId(nOldBuffer)

        if MoveBlock(_DEFAULT_) == 0
          PopWinClose()                     // Close status
          MsgBox(SplitPath(CurrMacroFilename(), _NAME_),
                 "Resultblock couldn't be inserted!",
                 _OK_
                )
          AbandonFile(nResultBlockBuffer)
          GotoBufferId(nOldBuffer)
          PopBlock()
          return()
        endif

        // Free memory by releasing the result buffer and restore old block marking
        AbandonFile(nResultBlockBuffer)
        PopBlock()
        nTickStop = GetSystemClockTicks()
        PopWinClose()                       // Close status
        Message("Overall time " +
                FppLocalizeResult(cDecimalSep, cThousandSep, cGrouping, Str(nTickStop - nTickStart))
                + " msec. [" +  gcExeName + " " + gcExeVersion + " processed " + gcLinesProcessed
                + " / " + FppLocalizeResult(cDecimalSep, cThousandSep, cGrouping, Str(gnLineCount - iif(gnBuildSum, 1, 0)))
                + " lines. Parsing total " + gcTimeTaken + " Calc. only " + gcTimeCompRun + "]"
               )

      // No result-area was found, it was an empty block or everything was commented out...???
      else
        AbandonFile(nResultBlockBuffer)
        GotoBufferId(nOldBuffer)
        PopBlock()
        PopWinClose()                       // Close status
        Warn("No results found!")
        UpdateDisplay(_STATUSLINE_REFRESH_) // restore statusline
      endif

      // Restore old cursorposion and view-area
      GotoLine(nCurrLine)
      ScrollToRow(nCurrRow)
      GotoPos(nCurrPos)
      GotoXoffset(nCurrXOffset)

    // Check only the highest possible error-code first
    elseif nRetVal == ERROR_IN_EXPRESSION
      MsgBox("Error while building line result",
                gcMathError + Chr(13) + Chr(13)
                + gcErrorText + Chr(13) + Chr(13)
                + gcExpression + Chr(13)
                + Format("?":gnErrorPos:" ") + Chr(13) + Chr(13)
                + "Cursor will be positioned at the corresponding line",
                _OK_
               )

      // Position cursor to the corresponding block-line
      GotoLine(Query(BlockBegLine)  + gnLineCount - 1)
      GotoColumn(Query(BlockBegCol) + gnErrorPos - 1)
      ScrollToRow(Query(WindowRows) shr 1)

      Message(gcErrorText + " " + gcMathError)

    // There may be more than one error to display
    else
      FppShowErrors(nRetVal)

      // Position cursor to the corresponding block-line
      if nRetVal & ERROR_IN_EXPRESSION
        GotoLine(Query(BlockBegLine)  + gnLineCount - 1)
        GotoColumn(Query(BlockBegCol) + gnErrorPos - 1)
        ScrollToRow(Query(WindowRows) shr 1)

        Message(gcErrorText + " " + gcMathError)
      endif
    endif

  // Display OS-Errorcode
  elseif nProcess < 0
    PopWinClose()                           // Status Popup schliessen
    nProcess = -nProcess
    Warn("OS-Errorcode: " + Str(nProcess) + Chr(13)
         + "trying to run " + gcExeName + " command SumLine failed"
        )
    UpdateDisplay(_STATUSLINE_REFRESH_)       // restore statusline

  // Program not found???
  else
    PopWinClose()                           // Status Popup schliessen
    Warn(gcExeName + " command SumLine could not be executed")
    UpdateDisplay(_STATUSLINE_REFRESH_)       // restore statusline
  endif

end

///*****************************************************************************
///
/// WhenLoaded
///
/// Read all stored data from TSE.ini
///
///*****************************************************************************
proc WhenLoaded()

  integer nCount    = 0
  integer nChar     = 0

  string  cBuffer[TOC_MARKER_SIZE * 3] = ""

  // Initialize hooks
  Hook(_ON_ABANDON_EDITOR_, FppOnAbandonEditor)

  // Numeric data
  gnBuildSum  = GetProfileInt(gcTSE_INI_KEY, gcBUILD_SUM_INI, -1)
  gnAlignRes  = GetProfileInt(gcTSE_INI_KEY, gcALIGN_RES_INI, -1)
  gnNumSpaces = GetProfileInt(gcTSE_INI_KEY, gcNUM_SPACES_INI, 1)
  gnDigits    = GetProfileInt(gcTSE_INI_KEY, gcDIGITS_INI, FLOAT_DECIMALS)

  // String data
  cBuffer     = GetProfileStr(gcTSE_INI_KEY, gcTocMarkerString, "23") // Hex of #
  gcTocMarker = ""

  // Convert Hex-values to string
  for nCount = 1 to TOC_MARKER_SIZE
    nChar = Val(GetToken(cBuffer, ";", nCount), 16)
    if (nChar in 1 .. 255)
      gcTocMarker = gcTocMarker + Chr(nChar)
    endif
  endfor

end

///*****************************************************************************
///
/// WhenPurged
///
/// Store Data to TSE.ini
///
///*****************************************************************************
proc WhenPurged()

  FppOnAbandonEditor()

end

///*****************************************************************************
///
/// FppOnAbandonEditor
///
/// Stores all data into TSE.ini.
///
///*****************************************************************************
proc FppOnAbandonEditor()

  integer nCount = 0

  string cBuffer[TOC_MARKER_SIZE * 3] = ""

  UnHook(FppOnAbandonEditor)

  RemoveProfileSection(gcTSE_INI_KEY)

  // Numeric data
  WriteProfileInt(gcTSE_INI_KEY, gcBUILD_SUM_INI,  gnBuildSum)
  WriteProfileInt(gcTSE_INI_KEY, gcALIGN_RES_INI,  gnAlignRes)
  WriteProfileInt(gcTSE_INI_KEY, gcNUM_SPACES_INI, gnNumSpaces)
  WriteProfileInt(gcTSE_INI_KEY, gcDIGITS_INI,     gnDigits)

  // String data
  // Convert char to Hex-value string
  for nCount = 1 to Length(gcTocMarker)
    cBuffer = cBuffer + Upper(Format(Asc(gcTocMarker[nCount]):2:"0":16, ";"))
  endfor
  WriteProfileStr(gcTSE_INI_KEY, gcTocMarkerString, cBuffer)

end

///*****************************************************************************
/// FppGetLocaleInfo
///
/// Query localization information from the OS and returns the result in
/// rcInformation.
///
/// Input:
/// vnLocalType   ->   0 = System default
///                   >0 = Userdata
/// vnInfoType    -> Information to query
/// rcInformation -> Buffer for storing query data
///
/// Output:
/// rcInformation -> Data from query, in case of error empty string ""
///
/// Return:
/// TRUE/FALSE -> TRUE = Error occured, FALSE = ok
///*****************************************************************************
integer proc FppGetLocaleInfo(integer vnLocalType, integer vnInfoType, var string rcInformation)

  integer nRetVal = 0

  string  cErrorText[60] = ""

  nRetVal = QueryLocaleInfo(vnLocalType, vnInfoType, rcInformation)

  // Errorcode
  if nRetVal < 0
    nRetVal = -nRetVal

    case nRetVal
    when ERROR_INVALID_PARAMETER
      cErrorText = "Please check the vnInfoType parameter."

    when ERROR_INSUFFICIENT_BUFFER
      cErrorText = "The size of rcInformation is too small for this call."

    when ERROR_INVALID_FLAGS
      cErrorText = "Please check the vnInfoType parameter flags."

    otherwise
      cErrorText = "See OS-Errorcodes for details."
    endcase

    Warn("FppGetLocaleInfo() returned ErrorCode " + Str(nRetVal) + Chr(13)
         + cErrorText + Chr(13)
         + "Macro: " + Upper(SplitPath(CurrMacroFilename(), _NAME_|_EXT_))
        )

    rcInformation = ""
    return(TRUE)
  endif

  return(FALSE)

end

///*****************************************************************************
///
/// FppHelpKeysSl
///
/// Activates when Help is selected in the main menu.
///
///*****************************************************************************
KeyDef FppHelpKeysSl

  <Escape>              EndProcess(EP_ABORT)

  <Ctrl Home>           Begfile()
  <Ctrl End>            Endfile()
  <Ctrl PgUp>           BegWindow()
  <Ctrl PgDn>           EndWindow()
  <Alt T>               FppHelpTOC() EndProcess(EP_FPP_HELP_TOC)

  <Ctrl CursorUp>       Begline()
                        if lFind(gcTocMarker, "^b")
                          ScrollToCenter()
                        endif

  <Ctrl CursorDown>     EndLine()
                        if lFind(gcTocMarker, "^+")
                        	ScrollToCenter()
                        endif

end

///*****************************************************************************
///
/// FppHelpTocKeysSl
///
/// Activates when <Alt T> is pressed in the help-list.
///
///*****************************************************************************
KeyDef FppHelpTocKeysSl

  <Ctrl Home>           Begfile()
  <Ctrl End>            Endfile()
  <Ctrl PgUp>           BegWindow()
  <Ctrl PgDn>           EndWindow()

end

///*****************************************************************************
///
/// FppEnableHelpKeys
///
/// Will be activated when the help is opened.
/// Activates the footer and the keys.
///
///*****************************************************************************
proc FppEnableHelpKeys()

  UnHook(FppEnableHelpKeys)
  ListFooter("{Esc}-Quit {Ctrl Cur-Up}-Previous Mark {Ctrl Cur-Down}-Next Mark {Alt T}-TOC")

  if not Enable(FppHelpKeysSl)
    Warn(SplitPath(CurrMacroFilename(), _NAME_) +
         Chr(13) + Chr(13) +
         "FppHelpKeysSl could not be activated!" + Chr(13) +
         "List keymappings might not work as expected."
        )
  endif

  BreakHookChain()

end

///*****************************************************************************
///
/// FppDisableHelpKeys
///
/// Will be called when the help is closed.
/// Deactivates the keys for help.
///
///*****************************************************************************
proc FppDisableHelpKeys()

  UnHook(FppDisableHelpKeys)
  Disable(FppHelpKeysSl)
  BreakHookChain()

end

///*****************************************************************************
///
/// FppEnableTocKeys
///
/// Will be activated when the TOC list is opened.
/// Activates the footer and the keys.
///
///*****************************************************************************
proc FppEnableTocKeys()

  UnHook(FppEnableTocKeys)
  ListFooter("{CR}-Goto Entry {Esc}-Quit")

  if not Enable(FppHelpTocKeysSl)
    Warn(SplitPath(CurrMacroFilename(), _NAME_) +
         Chr(13) + Chr(13) +
         "FppHelpTocKeysSl could not be activated!" + Chr(13) +
         "List keymappings might not work as expected."
        )
  endif

  BreakHookChain()

end

///*****************************************************************************
///
/// FppDisableTocKeys
///
/// Will be called when the TOC list is closed.
/// Deactivates the keys for TOC.
///
///*****************************************************************************
proc FppDisableTocKeys()

  UnHook(FppDisableTocKeys)
  Disable(FppHelpTocKeysSl)
  BreakHookChain()

end

///*****************************************************************************
///
/// FppEnableErrorFooter
///
/// Will be activated when the error list is opened.
/// Activates the footer.
///
///*****************************************************************************
proc FppEnableErrorFooter()

  UnHook(FppEnableErrorFooter)
  ListFooter("{Esc}-Quit")

end

///*****************************************************************************
///
/// FppHelp
///
/// Quick-Help-Menu, called from main-menu
///
/// Input:
/// vcHelpSearch -> optional searchtext to search for in the Help-File for
///                 display
///
///*****************************************************************************
proc FppHelp(string vcHelpSearch)

  integer nTempBuffer = 0
  integer nMaxWidth   = 0
  integer nOldBuffer  = GetBufferId()
  integer nOldCursor  = 0

  // Help-File must be present
  if FindThisFile(gcMacDir + gcFileHelp) == FALSE
    Warn("Error loading " + gcMacDir + gcFileHelp + ", File not found")
    return()
  endif

  // Prepare buffer
  PushBlock()
  nTempBuffer = CreateTempBuffer()
  SetUndoOff()
  if InsertFile(gcMacDir + gcFileHelp, _DONT_PROMPT_) == 0
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_),
           "Help-File couldn't be loaded!" + Chr(13) +
           gcMacDir + gcFileHelp + Chr(13),
           _OK_
          )
    GotoBufferId(nOldBuffer)
    PopBlock()
    return()
  endif

  nOldCursor = SetCursorOff()
  UnMarkBlock()
  BegFile()

  // Searchtext present?
  if vcHelpSearch <> ""
    if lFind(vcHelpSearch, "iwg")  // Ignore case, whole word, search from start
      ScrollToCenter()
    endif
  endif

  // Limit width to edit window
  nMaxWidth = Min(Query(ScreenCols), LongestLineInBuffer())

  // Display help
  BufferVideo()
  HookDisplay(FppDrawHelpLine,,, FppHiliteText)
  loop
    if (not Hook(_LIST_STARTUP_, FppEnableHelpKeys))  or (not Hook(_LIST_CLEANUP_, FppDisableHelpKeys))
      Warn(SplitPath(CurrMacroFilename(), _NAME_) +
           Chr(13) + Chr(13) +
           "Hook FppEnableHelpKeys/FppDisableHelpKeys could not be established!" + Chr(13) +
           "List keymappings might not work as expected."
          )
    endif

    if lList("FppSumLine Help: " + gcFileHelp, nMaxWidth, Query(ScreenRows), _ENABLE_SEARCH_ | _ENABLE_HSCROLL_) == EP_ABORT
      break
    endif
  endloop
  UnhookDisplay()
  UnBufferVideo()

  AbandonFile(nTempBuffer)
  GotoBufferId(nOldBuffer)
  PopBlock()
  Set(Cursor, nOldCursor)

end

///*****************************************************************************
///
/// FppHiliteText
///
/// Called from FppHelp and FppHelpToc, marks found text (Qicksearch)
///
///*****************************************************************************
proc FppHiliteText()

  HiliteFoundText()

end

///*****************************************************************************
///
/// FppDrawHelpLine
///
/// Called from FppHelp, inserts and colors line to display
///
/// Input:
/// vfIsCursor -> TRUE when current line is the cursor line
///
///*****************************************************************************
proc FppDrawHelpLine(integer vfIsCursor)

  string cBuffer[MAXSTRINGLEN] = GetText(CurrXOffset() + 1, MAXSTRINGLEN)

  // Cursor overrules mark
  if vfIsCursor
    PutStr(cBuffer)
  // Color marked line
  elseif gcTocMarker == GetText(1, Length(gcTocMarker))
    PutStr(Format(cBuffer:-MAXSTRINGLEN), gnColHelpMarker)
  // Normal
  else
    PutStr(cBuffer)
  endif

  ClrEol()

end

///*****************************************************************************
///
/// FppHelpToc
///
/// Called from FppHelp, builds a TOC on the fly and displays it.
///
///*****************************************************************************
proc FppHelpToc()

  integer nMaxWidth   = 0
  integer nMarkerLine = 0
  integer nGotoLine   = 0
  integer nLine       = CurrLine()
  integer nLineWidth  = Length(Str(NumLines())) + 1
  integer nOldBuffer  = GetBufferId()
  integer nTocBuffer  = CreateTempBuffer()

  SetUndoOff()
  GotoBufferId(nOldBuffer)

  // Save old marking
  PushBlock()
  PushPosition()

  // Build list on the fly, remove leading TOC-marker and spaces
  if lFind(gcTocMarker, "g^")
    AddLine(Format(CurrLine():nLineWidth) + ":  " + Trim(GetText(Length(gcTocMarker) + 1, MAXSTRINGLEN)), nTocBuffer)

    while lRepeatFind(_FORWARD_)
      AddLine(Format(CurrLine():nLineWidth) + ":  " + Trim(GetText(Length(gcTocMarker) + 1, MAXSTRINGLEN)), nTocBuffer)
    endwhile

    GotoBufferId(nTocBuffer)

    // Remove right limiter char "|" at end of line
    lReplace("|", " ", "g$n")

    // Find the line where we are within the marker buffer
    BegFile()
    repeat
      nMarkerLine = Val(GetText(1, nLineWidth))
      if nMarkerLine == nLine
        break
      elseif nMarkerLine > nLine
        Up()
        break
      endif
    until not Down()

    // Used for marking line
    gcTocLine = GetText(1, nLineWidth)

    // Limit width to edit window
    nMaxWidth = Min(Query(ScreenCols), LongestLineInBuffer())

    if (not Hook(_LIST_STARTUP_, FppEnableTocKeys))  or (not Hook(_LIST_CLEANUP_, FppDisableTocKeys))
      Warn(SplitPath(CurrMacroFilename(), _NAME_) +
           Chr(13) + Chr(13) +
           "Hook FppEnableTocKeys/FppDisableTocKeys could not be established!" + Chr(13) +
           "List keymappings might not work as expected."
          )
    endif

    // Display TOC-list
    BufferVideo()
    HookDisplay(FppDrawTocLine,,, FppHiliteText)
    if lList("FppSumLine Help: TOC-List", nMaxWidth, Query(ScreenRows), _ENABLE_SEARCH_ | _ENABLE_HSCROLL_)
      // Get line
      nGotoLine = Val(GetText(1, nLineWidth))
    endif

    UnHookDisplay()
    UnBufferVideo()

  // No marking found
  else
    Warn("No TOC-Markers could be found!" + chr(13) + "Set Marker: " + gcTocMarker)
  endif

  AbandonFile(nTocBuffer)
  GotoBufferId(nOldBuffer)
  // Restore old marking
  PopPosition()
  PopBlock()

  // Goto selected mark
  if nGotoLine
    GotoLine(nGotoLine)
    ScrollToCenter()
  endif

end

///*****************************************************************************
///
/// FppDrawTocLine
///
/// Called from FppHelpToc, inserts and colors line to display
///
/// Input:
/// vfIsCursor -> TRUE when current line is the cursor line
///
///*****************************************************************************
proc FppDrawTocLine(integer vfIsCursor)

  string cBuffer[MAXSTRINGLEN] = GetText(CurrXOffset() + 1, MAXSTRINGLEN)

  // Cursor overrules mark
  if vfIsCursor
    PutStr(cBuffer)
  // Color marked line
  elseif EquiStr(gcTocLine, GetText(1, Length(gcTocLine)))
    PutStr(Format(cBuffer:-MAXSTRINGLEN), gnColHelpMarker)
  // Normal
  else
    PutStr(cBuffer)
  endif

  ClrEol()

end

///*****************************************************************************
///
/// FppShowErrors
///
/// Shows a list of all errors coded in vnErrors.
///
/// Input:
/// vnErrors -> Errorcodes
///
///*****************************************************************************
proc FppShowErrors(integer vnErrors)

  integer nOldBuffer  = GetBufferId()
  integer nTempBuffer = 0
  integer nMaxWidth   = 0

  // Save old marking
  PushBlock()

  // Prepare buffer
  nTempBuffer = CreateTempBuffer()
  SetUndoOff()                              // Saves memory and time

  if vnErrors & ERROR_IN_EXPRESSION
    Addline("Error in Expression")
    AddLine(gcExpression)
    AddLine(Format("?":gnErrorPos:" "))
    AddLine("Cursor will be positioned at the corresponding line")
    AddLine()
  endif

  if Length(gcErrorText) > 0
    AddLine(gcErrorText)
    AddLine()
  endif

  if Length(gcMathError) > 0
    AddLine(gcMathError)
    AddLine()
  endif

  if vnErrors & ERROR_MALLOC
    Addline("Error allocating memory")
    AddLine()
  endif

  if vnErrors & ERROR_COMMANDLINE_PARAMETER
    Addline("Error commandline parameter")
    AddLine()
  endif

  if vnErrors & ERROR_RESULT_OPEN_FILE
    Addline(gcErrorOpenFile + gcMacDir + gcFileResult)
    AddLine()
  endif

  if vnErrors & ERROR_RESULT_CLOSE_FILE
    Addline(gcErrorCloseFile + gcMacDir + gcFileResult)
    AddLine()
  endif

  if vnErrors & ERROR_RESULT_WRITE_FILE
    Addline(gcErrorWriteFile + gcMacDir + gcFileResult)
    AddLine()
  endif

  if vnErrors & ERROR_RESULT_NO_FILENAME
    Addline("Error no filename for Result")
    AddLine()
  endif

  if vnErrors & ERROR_EXPR_OPEN_FILE
    Addline(gcErrorOpenFile + gcMacDir + gcFileExpression)
    AddLine()
  endif

  if vnErrors & ERROR_EXPR_CLOSE_FILE
    Addline(gcErrorCloseFile + gcMacDir + gcFileExpression)
    AddLine()
  endif

  if vnErrors & ERROR_EXPR_READ_FILE
    Addline(gcErrorReadFile + gcMacDir + gcFileExpression)
    AddLine()
  endif

  if vnErrors & ERROR_EXPR_NO_FILENAME
    Addline("Error no filename for Expression")
    AddLine()
  endif

  // Limit width to edit window
  nMaxWidth = Min(Query(ScreenCols), LongestLineInBuffer())

  // Display errorlist
  Hook(_LIST_STARTUP_, FppEnableErrorFooter)
  lList("FppSumLine Returned Errors",
        nMaxWidth,
        Query(ScreenRows),
        _ENABLE_SEARCH_ | _ENABLE_HSCROLL_
       )

  AbandonFile(nTempBuffer)
  GotoBufferId(nOldBuffer)
  // Restore old marking
  PopBlock()

end

///*****************************************************************************
///
/// FppYesNoStr
///
/// Return the string associated to vnSelect.
///
/// Input:
/// vnSelect  -> TRUE / FALSE
///
/// Return:
/// "Yes" / "No"
///*****************************************************************************
string proc FppYesNoStr(integer vnSelect)

  return (iif(vnSelect, "Yes", "No"))

end

///*****************************************************************************
///
/// FppToggleInsTotal
///
/// Switch the global flag and return the associated text.
///
/// Return:
/// "Yes" / "No"
///*****************************************************************************
string proc FppToggleInsTotal()

  gnBuildSum = ~gnBuildSum
  return (FppYesNoStr(gnBuildSum))

end

///*****************************************************************************
///
/// FppToggleAlign
///
/// Switch the global flag and return the associated text.
///
/// Return:
/// "Yes" / "No"
///*****************************************************************************
string proc FppToggleAlign()

  gnAlignRes = ~gnAlignRes
  return (FppYesNoStr(gnBuildSum))

end

///*****************************************************************************
///
/// FppNumSpaces
///
/// Edit and set the number of spaces to insert between the marked block and
/// the sum-block.
///
///*****************************************************************************
proc FppNumSpaces()

  string cInput[2] = Str(gnNumSpaces)

  if Read(cInput)
    if isDigit(cInput)
      gnNumSpaces = Val(cInput)
      if gnNumSpaces < 1
        gnNumSpaces = 1
      endif
    endif
  endif

end

///*****************************************************************************
///
/// FppBlockLokalizedMenu
///
/// Selection of the input/output localization and formatting options.
///
///*****************************************************************************
menu FppBlockLokalizedMenu()
  history
  title = "FPPSumLine - Number Input and Output Format"

  "&A - US-Standard"[FppLocalizeResult(".", ",", "3;0", "123456789.00"):16],,
  _MF_CLOSE_ALL_BEFORE_,
  "Start Building-Sum using US-Standard decimal '.' and grouping ',' separators"

  "&B - Non-US"[FppLocalizeResult(",", ".", "3;0", "123456789.00"):16],,
  _MF_CLOSE_ALL_BEFORE_,
  "Start Building-Sum using Non-US decimal ',' and grouping '.' separators"

  "&C - System-Settings"[FppLocalizeResult(gcSystemDecimalSep, gcSystemThousandSep, gcSystemGrouping, "123456789.00"):16],,
  _MF_CLOSE_ALL_BEFORE_,
  "Start Building-Sum using the current system settings for decimal and grouping separators"

  "",, _MF_DIVIDE_

  "&D - Also insert Total Sum"[FppYesNoStr(gnBuildSum):3], FppToggleInsTotal(),
  _MF_DONT_CLOSE_,
  "Appends the total sum at the end of the sum block"

  "&E - Right align Results"[FppYesNoStr(gnAlignRes):3], FppToggleAlign(),
  _MF_DONT_CLOSE_,
  "Yes = Results are right aligned, No = no alignment"

  "",, _MF_DIVIDE_

  "&F - Spaces between Blocks"[gnNumSpaces:2], FppNumSpaces(),
  _MF_DONT_CLOSE_,
  "Spaces to insert between marked and sum block, Range 1 to 99"

  "&G - Digits for Result Display"[gnDigits:2], FppEnterDigits(),
  _MF_DONT_CLOSE_,
  "Applies to Results only. Range 0-99, default=30, active with next evaluation"

  "",, _MF_DIVIDE_

  "&H - TOC-Marker Sign"[gcTocMarker:TOC_MARKER_SIZE],
  FppEditTocMarker(),
  _MF_DONT_CLOSE_,
  "Lets you change the current used TOC-Marker sign. Default: #"

  "Help",, _MF_DIVIDE_

  "&I - FppSumLine Help", FppHelp("FppSumLine Help"),
  _MF_DONT_CLOSE_,
  "Shows the help-file section"

  "",, _MF_DIVIDE_

  "&J - About",
  FppAbout(),
  _MF_DONT_CLOSE_,
  "Shows version info about the macro, used Exe, Dll and OS"

end

///******************************************************************************
///
/// FppEnterDigits
///
/// Sets the number of digits for formatting the results.
///
///******************************************************************************
proc FppEnterDigits()

  integer nTemp = 0

  string  cEditbuff[2] = Str(gnDigits)

  if ReadNumeric(cEditbuff)
    nTemp = Val(cEditbuff)

    if nTemp >= 0 and nTemp <= FLOAT_MAX_DECIMALS
      gnDigits = nTemp
    elseif nTemp > FLOAT_MAX_DECIMALS
      gnDigits = FLOAT_MAX_DECIMALS
    else
      gnDigits = FLOAT_DECIMALS
    endif
  endif

end

///*****************************************************************************
///
/// FppEditTocMarker
///
/// Called from FppBlockLokalizedMenu
///
///*****************************************************************************
proc FppEditTocMarker()

  integer nHistory = GetFreeHistory("FppShell:FppTocHistory")

  AddHistoryStr(gcTocMarker, nHistory)

  if lRead(gcTocMarker, TOC_MARKER_SIZE, nHistory)
    // Make sure the default is present
    if Trim(gcTocMarker) == ""
      gcTocMarker = "#"
    endif
  endif

end

///*****************************************************************************
///
/// FppLocalizeResult
///
/// Localizes a string from 12345678.9 to for example 12,345,678.9
///
/// Input:
/// vcDecimalSep     -> Decimal separator
/// vcThousandSep    -> Thousand separator
/// vcGrouping       -> Grouping
/// vcResultToFormat -> Result to localize
///
/// Return:
/// cResult -> Localized Result
///*****************************************************************************
string proc FppLocalizeResult(string vcDecimalSep, string vcThousandSep, string vcGrouping, string vcResultToFormat)

  integer nCurrGoupVal = 0
  integer nNumEnd      = 0
  integer nGroupCount  = 1
  integer nExponentPos = 0
  integer nTemp        = 0

  string cBuffer[MAXSTRINGLEN] = ""
  string cSign[1]              = ""

  // Check if grouping specified
  if StrFind("[1-9];[0]", vcGrouping, "x") == 0
    return("Grouping not specified")
  endif

  // Copy all chars, filter spaces, replace decimalseparator with lokal separator
  for nTemp = 1 to Length(vcResultToFormat)
    // replace decimalseparator if one is present
    if vcResultToFormat[nTemp] == "."
      cBuffer = cBuffer + vcDecimalSep

    // Take everything except spaces
    elseif vcResultToFormat[nTemp] <> " "
      cBuffer = cBuffer + vcResultToFormat[nTemp]

      // Store exponent position
      if EquiStr(vcResultToFormat[nTemp], "E")
        nExponentPos = nTemp
      endif
    endif
  endfor

  // If first char +/- mask it out and remenber for later
  if cBuffer[1] == "-" or cBuffer[1] == "+"
    cSign   = cBuffer[1]
    cBuffer = SubStr(cBuffer, 2, MAXSTRINGLEN)
    nExponentPos = nExponentPos - 1
  endif

  // Set end of number for formatting
  nNumEnd = Pos(vcDecimalSep, cBuffer)

  if nNumEnd == 0
    nNumEnd = Length(cBuffer) + 1
  endif

  if nExponentPos > 0
    if nExponentPos < nNumEnd
      nNumEnd = nExponentPos
    endif
  endif

  // Format result using grouping
  nCurrGoupVal = Val(GetToken(vcGrouping, ";", nGroupCount))
  nGroupCount  = nGroupCount + 1

  // Insert thousandseparator according to grouping
  // Variable grouping is supported
  while nNumEnd > nCurrGoupVal
    nNumEnd = nNumEnd - nCurrGoupVal

    // Min 2 chars have to be there
    if nNumEnd > 1
      cBuffer = InsStr(vcThousandSep, cBuffer, nNumEnd)

    // Reached the end
    else
      break
    endif

    // Determine next grouping value
    nTemp = Val(GetToken(vcGrouping, ";", nGroupCount))

    // 0 marks the end, continue with last used value
    if nTemp > 0
      nGroupCount  = nGroupCount + 1
      nCurrGoupVal = nTemp

    endif
  endwhile

  // Insert sign if necessary
  if Length(cSign)
    return (cSign + cBuffer)
  endif

  return (cBuffer)

end

///*****************************************************************************
/// FppBuildResultBlock
///
/// Generates a result block. All results will be formatted and assigned to their
/// corresponding line in the source block.
///
/// Input:
/// vnInResultBuffer -> Buffer with raw data
/// vnLines          -> Number of lines to work with
/// vnAddSum         -> <> 0: Add total sum to the end of the block
/// vnFraction       -> Determined fractional digits from source block
/// vnIsFracInBlock  -> Indicates if fractional digits were present in source block
/// vnAlignRight     -> Align to right
/// vcDecimalSep     -> Decimal separator
///
/// Return:
/// nLinesInBlock    -> Number of lines in resultblock
///*****************************************************************************
integer proc FppBuildResultBlock(integer vnInResultBuffer, integer vnLines, integer vnAddSum, integer vnFraction,
                                 integer vnIsFracInBlock, integer vnAlignRight, string vcDecimalSep)

  integer nLineCount     = 0
  integer nFract         = 0
  integer nBlockState    = 0
  integer nLen           = 0
  integer nTemp          = 0

  string  cFound[MAXSTRINGLEN] = ""
  string  cSearch[15]          = "\" + vcDecimalSep + "[0-9Ee]#"

#if USE_STATUSBAR
  integer nBarAttr       = Query(MenuSelectAttr)
  integer nBarDone       = 0
  integer nBarResolution = 0
  integer nNumOutChar    = 0

  nBarResolution = (vnLines + iif(vnAddSum, 1, 0)) / BAR_SIZE
  PutAttrXY(X_TEXT, Y_BUILD_BAR, Query(TextAttr), BAR_SIZE)
#endif
  // Select input buffer
  GotoBufferId(vnInResultBuffer)

  // Refresh fractional digits, because they could have changed due to
  // mathematical operations.
  // The largest number of fractional digits will always be used.
  // Only check the total sum here at first.
  // Only needed when align right is selected!
  if vnAlignRight and lFind("[QRESULT]", "g^")
    if lFind("\.[0-9Ee]#", "xc")
      // Exponential values are *not* taken into account
      cFound = GetFoundText()
      if StrFind("E", cFound, "i") == 0
        nFract = Max(vnFraction, Length(cFound))

      // Result has exponent, possibly there were fractional digits in the source block
      elseif vnIsFracInBlock
        nFract = vnFraction
      endif

    // Result doesn't contain fractional digits but there were some at the source block
    elseif vnIsFracInBlock
      nFract = vnFraction
    endif
  endif

  // Delete last line containing [CONVERT_AND_WRITE] if present
  EndFile()
  if lFind("[CONVERT_AND_WRITE]", "bc")
    KillLine()
  endif

  // Change the last line to contain the total sum, regardless if needed later on
  if lFind("[QRESULT_LOC]", "g^")
    MarkLine(CurrLine(), CurrLine())
    Endfile()
    nBlockState = Set(InsertLineBlocksAbove, OFF)
    CopyBlock()
    Set(InsertLineBlocksAbove, nBlockState)
  endif

  // Search start of result-area
  if lFind("[LRES_COUNT ", "g^")
    // Delete all lines before this line
    MarkLine(1, CurrLine() - 1)
    KillBlock()
    // Change prefix to that used for total sum
    EndFile()
    lReplace("[QRESULT_LOC]", "[LRES_COUNT 1][LINE_" + Str(vnLines + 1) + "]", "bc^1")

  // No result-area was found, it was an empty block or everything was commented out...???
  else
    return (0)
  endif

  // Output total sum if selected
  if vnAddSum
    vnLines = vnLines + 1
  endif

  // Right alignment is seleted, formatting is needed here
  if vnAlignRight
    // Make sure to have the actual largest number of fractional digits over all results
    if lFind(cSearch, "gx")
      cFound = GetFoundText()
      // Exponential values are *not* taken into account
      if StrFind("E", cFound, "i") == 0
        nTemp = Length(cFound)
      endif

      while lRepeatFind(_FORWARD_)
        cFound = GetFoundText()
        // Exponential values are *not* taken into account
        if StrFind("E", cFound, "i") == 0
          nTemp = Max(nTemp, Length(cFound))
        endif
      endwhile

      nTemp = nTemp - 1               // because of decimal separator
    endif

    nFract = Max(nTemp, nFract)

    // Get the result for every corresponding line
    for nLineCount = 1 to vnLines
      GotoLine(nLineCount)
      GotoColumn(1)

      // Build search term
      if lReplace("\[LRES_COUNT [0-9]#\]\[LINE_" + Str(nLineCount) + "\]", "", "x^1")
        // Format result, look for decimal separator
        if lFind(cSearch, "xc")
          cFound = GetFoundText()
          // Exponential values will *not* be formatted
          if StrFind("E", cFound, "i")
            goto UPDATE_BAR_AND_NEXT
          endif

          nLen = Length(cFound) - 1     // because of decimal separator

          // Append zeros till min number of fractional digits is reached
          if vnFraction > nLen
            cFound = Format(cFound, "":vnFraction - nLen:"0")
            lReplace(cSearch, cFound, "xc1")
            nLen = length(cFound) - 1   // because of decimal separator
            GotoColumn(1)
          endif

          // Number of fractional digits too small -> append with space
          if nFract > nLen
            cFound = Format(cFound, " ":nFract - nLen)
            lReplace(cSearch, cFound, "xc1")
          endif

        // Result is without fractional digits, but there were some in the source block
        // append with min number of fractional digits the rest with spaces.
        elseif nFract > 0
          Endline()
          InsertText(Format(vcDecimalSep, "":vnFraction:"0", "":nFract - vnFraction:" "), _INSERT_)
        endif

      // No result found for this line, insert empty line
      else
        InsertLine()
      endif

UPDATE_BAR_AND_NEXT:
#if USE_STATUSBAR
      // Update statusbar
      nBarDone = nBarDone + 1

      if nBarDone > nBarResolution
        nBarDone    = 0
        nNumOutChar = nLineCount * BAR_SIZE / vnlines
        PutAttrXY(X_TEXT, Y_BUILD_BAR, nBarAttr, nNumOutChar)
      endif
#endif
    endfor

  // No alignment, no formatting needed here, simply build left aligned block
  else
    // Get the result for every corresponding line
    for nLineCount = 1 to vnLines
      GotoLine(nLineCount)
      GotoColumn(1)

      // Build search term
      if lReplace("\[LRES_COUNT [0-9]#\]\[LINE_" + Str(nLineCount) + "\]", "", "x^1") == 0
        // No result found for this line, insert empty line
        InsertLine()
      endif

#if USE_STATUSBAR
      // Update statusbar
      nBarDone = nBarDone + 1

      if nBarDone > nBarResolution
        nBarDone    = 0
        nNumOutChar = nLineCount * BAR_SIZE / vnlines
        PutAttrXY(X_TEXT, Y_BUILD_BAR, nBarAttr, nNumOutChar)
      endif
#endif
    endfor
  endif

  // Remove total sum if not selected
  if vnAddSum == 0
    EndFile()
    KillLine()
  endif

  return (vnLines)

end

///*****************************************************************************
/// FppAlignResults
///
/// Align the allready formatted and localized results.
///
/// Input:
/// vnResultBuffer -> Buffer with allready localized and formatted results
/// vnLines        -> Number of lines to align
/// vnAlignRight   -> Right alingnment selected
///
/// Return:
/// nLineLength    -> Length of each line in buffer
///*****************************************************************************
integer proc FppAlignResults(integer vnResultBuffer, integer vnLines, integer vnAlignRight)

  integer nLineCount      = 0
  integer nLineLength     = 0
  integer nCurrLineLenght = 0
  integer nTemp           = 0
  integer nExtraSpace     = 0

#if USE_STATUSBAR
  integer nBarAttr       = Query(MenuSelectAttr)
  integer nBarDone       = 0
  integer nBarResolution = vnLines / BAR_SIZE
  integer nNumOutChar    = 0
#endif
  // Select result buffer
  GotoBufferId(vnResultBuffer)

#if USE_STATUSBAR
  PutAttrXY(X_TEXT, Y_ALIGN_BAR, Query(TextAttr), BAR_SIZE)
  nBarDone = 0
#endif

  nLineLength = LongestLineInBuffer() + gnNumSpaces   // spaces before result

  // Right align results by inserting leading spaces
  if vnAlignRight
    for nLineCount = 1 to vnLines
      GotoLine(nLineCount)

      nCurrLineLenght = CurrLineLen()
      nTemp           = nLineLength - nCurrLineLenght

      if nCurrLineLenght > 0 and nTemp > 0
        GotoColumn(1)
        InsertText(Format(" ":nTemp), _INSERT_)
      endif

#if USE_STATUSBAR
      // Update statusbar
      nBarDone = nBarDone + 1

      if nBarDone > nBarResolution
        nBarDone    = 0
        nNumOutChar = nLineCount * BAR_SIZE / vnlines
        PutAttrXY(X_TEXT, Y_ALIGN_BAR, nBarAttr, nNumOutChar)
      endif
#endif
    endfor

  // No alignment, only insert leading spaces, and extra space if necessary
  else
    // Check for leading sign if to insert an extra space
    nExtraSpace = lFind("^{\-}|{\+}", "gx")
    // Update longest line with an extra space if needed
    nLineLength = nLineLength + iif(nExtraSpace, 1, 0)

    for nLineCount = 1 to vnLines
      GotoLine(nLineCount)

      if CurrLineLen() > 0 and gnNumSpaces > 0
        GotoColumn(1)

        if (Pos(GetText(1, 1), "-+")) or (nExtraSpace == 0)
          InsertText(Format(" ":gnNumSpaces), _INSERT_)
        // Extra space needed
        else
          InsertText(" " + Format(" ":gnNumSpaces), _INSERT_)
        endif
      endif

#if USE_STATUSBAR
      // Update statusbar
      nBarDone = nBarDone + 1

      if nBarDone > nBarResolution
        nBarDone    = 0
        nNumOutChar = nLineCount * BAR_SIZE / vnlines
        PutAttrXY(X_TEXT, Y_ALIGN_BAR, nBarAttr, nNumOutChar)
      endif
#endif
    endfor
  endif

  return (nLineLength)

end

///*****************************************************************************
///
/// FppOpenProgress
///
/// Opens the progress window with constant elements. All elements are displayed
/// as grayed out.
///
/// Input:
/// vnYPos  -> Current cursorline on screen
///
/// Return:
/// TRUE  -> Window could be opened
/// FALSE -> Error while opening the window
///*****************************************************************************
integer proc FppOpenProgress(integer vnYPos)

  integer nTextAttr = Query(MenuTextAttr)
  integer nGrayAttr = Query(MenuGrayAttr)
  integer nOldAttr  = 0
  integer nxWin     = 0

  nxWin = (Query(ScreenCols) - WIN_WIDTH) / 2

  // Determine Y-Position for PopUp
  if vnYPos > WIN_HEIGHT
    vnYPos = vnYPos - WIN_HEIGHT
  else
    vnYPos = vnYPos + 1
  endif

  if vnYPos + WIN_HEIGHT > Query(ScreenRows)
    vnYPos = Query(WindowRows) - WIN_HEIGHT
  endif

  // Open window
  if PopWinOpen(nxWin, vnYPos, nxWin + WIN_WIDTH, vnYPos + WIN_HEIGHT - 1,
                Query(CurrWinBorderType),
                SplitPath(CurrMacroFilename(), _NAME_)
                + " - Progress",
                Query(MenuBorderAttr)
               ) == FALSE

    MsgBox(SplitPath(CurrMacroFilename(), _NAME_) + " Error",
           "FppOpenProgress()" + Chr(13) + "Unable to open pop-up window."
           + Chr(13)  + "Editor main window may be to small?"
           + Chr(13)  + "Needed size for pop-up is "
           + Str(WIN_WIDTH) + " x " + Str(WIN_HEIGHT),
           _OK_
          )
    return(FALSE)
  endif

  BufferVideo()

  // Clear area
  nOldAttr = Set(Attr, nTextAttr)
  VGotoXY(1, 1)
  ClrScr()
  Set(Attr, nOldAttr)

  PutStrXY(X_TEXT, Y_COPY_BLOCK,      "Copy Block", nGrayAttr)
  PutStrXY(X_TEXT, Y_NORM_BLOCK,      "Normalize copy of marked block", nGrayAttr)
  PutStrXY(X_TEXT, Y_DET_FRAC,        "Determine fractional digits", nGrayAttr)
  PutStrXY(X_TEXT, Y_WRITE_BLOCK,     "Writing block to file", nGrayAttr)
  PutStrXY(X_TEXT, Y_CALCULATE,       "Calculating sum. Run " + gcExeName + " [" + gcExeVersion + "]", nGrayAttr)
  PutStrXY(X_TEXT, Y_LOAD_RES,        "Load result file", nGrayAttr)
  PutStrXY(X_TEXT, Y_BUILD_RES_BLOCK, "Build result block and format results", nGrayAttr)
  PutStrXY(X_TEXT, Y_ALIGN_RES,       "Align results in block", nGrayAttr)
  PutStrXY(X_TEXT, Y_INSERT_RES,      "Insert result block", nGrayAttr)

  UnBufferVideo()

  return(TRUE)

end

///*****************************************************************************
///
/// FppSetStatus
///
/// Coloring of active and/or grayed out and active status.
///
/// Input:
/// vnStatus -> Highlited current status
///
///*****************************************************************************
proc FppSetStatus(integer vnStatus)

  integer nActivAttr = Query(MenuSelectAttr)
  integer nGrayAttr  = Query(MenuGrayAttr)

  BufferVideo()

  case vnStatus
  when STAT_COPY_BLOCK
    PutAttrXY(X_TEXT, Y_COPY_BLOCK,      nActivAttr, STAT_TXT_LEN)

  when STAT_NORM_BLOCK
    PutAttrXY(X_TEXT, Y_COPY_BLOCK,      nGrayAttr,  STAT_TXT_LEN)
    PutAttrXY(X_TEXT, Y_NORM_BLOCK,      nActivAttr, STAT_TXT_LEN)

  when STAT_DET_FRAC
    PutAttrXY(X_TEXT, Y_NORM_BLOCK,      nGrayAttr,  STAT_TXT_LEN)
    PutAttrXY(X_TEXT, Y_DET_FRAC,        nActivAttr, STAT_TXT_LEN)

  when STAT_WRITE_BLOCK
    PutAttrXY(X_TEXT, Y_DET_FRAC,        nGrayAttr,  STAT_TXT_LEN)
    PutAttrXY(X_TEXT, Y_WRITE_BLOCK,     nActivAttr, STAT_TXT_LEN)

  when STAT_CALCULATE
    PutAttrXY(X_TEXT, Y_WRITE_BLOCK,     nGrayAttr,  STAT_TXT_LEN)
    PutAttrXY(X_TEXT, Y_CALCULATE,       nActivAttr, STAT_TXT_LEN)

  when STAT_LOAD_RESULT
    PutAttrXY(X_TEXT, Y_CALCULATE,       nGrayAttr,  STAT_TXT_LEN)
    PutAttrXY(X_TEXT, Y_LOAD_RES,        nActivAttr, STAT_TXT_LEN)

  when STAT_BUILD_RES_BLOCK
    PutAttrXY(X_TEXT, Y_LOAD_RES,        nGrayAttr,  STAT_TXT_LEN)
    PutAttrXY(X_TEXT, Y_BUILD_RES_BLOCK, nActivAttr, STAT_TXT_LEN)

  when STAT_ALIGN_RES
    PutAttrXY(X_TEXT, Y_BUILD_RES_BLOCK, nGrayAttr,  STAT_TXT_LEN)
    PutAttrXY(X_TEXT, Y_ALIGN_RES,       nActivAttr, STAT_TXT_LEN)

  when STAT_INSERT_RES
    PutAttrXY(X_TEXT, Y_ALIGN_RES,       nGrayAttr,  STAT_TXT_LEN)
    PutAttrXY(X_TEXT, Y_INSERT_RES,      nActivAttr, STAT_TXT_LEN)
  endcase

  UnBufferVideo()
  UpdateDisplay()

end

///*****************************************************************************
///
/// FppStartRedirect
///
/// Redirects the _STDOUT_ to _STDERR_.
/// Is used when running in console-mode to suppress messages from the app that
/// would otherwise be shown somewhere on the editor-screen.
///
/// Input:
/// vcFile   -> Filename to redirect to
/// rnStdOut -> Storage for Handle
/// rnStdErr -> Storage for Handle
///
/// Output:
/// rnStdOut -> Handle _STDOUT_
/// rnStdErr -> Handle _STDERR_
///
///*****************************************************************************
proc FppStartRedirect(string vcFile, var integer rnStdOut, var integer rnStdErr)
  integer nFd1   = 0
  integer nFd2   = 0
  integer nFdOut = 0
  integer nFdErr = 0

  nFdOut = fCreate(vcFile)
  nFd1   = fDup(_STDOUT_)
  fDup2(nFdOut, _STDOUT_)

  nFdErr = nFdOut
  nFd2   = fDup(_STDERR_)
  fDup2(nFdErr, _STDERR_)

  fClose(nFdOut)

  rnStdOut = nFd1
  rnStdErr = nFd2

end

///*****************************************************************************
///
/// FppEndRedirect
///
/// Restores the redirected _STDOUT_ and _STDERR_
///
/// Input:
/// vcFile   -> Redirected Filename to erase
/// vnStdOut -> Original handle _STDOUT_
/// vnStdErr -> Original handle _STDERR_
///
///*****************************************************************************
proc FppEndRedirect(string vcFile, integer vnStdOut, integer vnStdErr)

  fDup2(vnStdOut, _STDOUT_)
  fClose(vnStdOut)

  fDup2(vnStdErr, _STDERR_)
  fClose(vnStdErr)

  if EraseDiskFile('"' + vcFile + '"') == 0
    warn("Unable to erase File " + Chr(13) + vcFile)
  endif

end

///*****************************************************************************
///
/// FppAbout
///
/// Called from FppOptionsMenu
///
///*****************************************************************************
proc FppAbout()
  integer nOldAttr  = 0
  integer nTextAttr = Query(MenuTextAttr)
  integer nxWin     = Query(ScreenCols)
  integer nyWin     = Query(ScreenRows)
  integer nVPos     = 0

  string  cTop[10]  = "----------"
  string  cCen[10]  = "FppSumLine"
  string  cBot[10]  = "=========="
  string  cT[1]     = ""
  string  cC[1]     = ""
  string  cB[1]     = ""

  // Center window on screen
  nxWin = (nxWin shr 1) - (WIN_ABOUT_WIDTH  shr 1)
  nyWin = (nyWin shr 1) - (WIN_ABOUT_HEIGHT shr 1)

  SetCursorOff()
  PopWinOpen(nxWin, nyWin, nxWin + WIN_ABOUT_WIDTH, nyWin + WIN_ABOUT_HEIGHT - 1,
             Query(CurrWinBorderType), "About", Query(MenuBorderAttr))
  WindowFooter("{Press a key to exit}")

  // Clear area
  nOldAttr = Set(Attr, nTextAttr)
  VGotoXY(1, 1)
  ClrScr()

  PutStrXY(2, 2, cCen, nTextAttr)
  PutStrXY(WIN_ABOUT_WIDTH - Length(gcMacVersion) - 1, 2, gcMacVersion, nTextAttr)

  PutStrXY(2, 3, gcExeName, nTextAttr)
  PutStrXY(WIN_ABOUT_WIDTH - Length(gcExeVersion) - 1, 3, gcExeVersion, nTextAttr)

  PutStrXY(2, 4, gcDllName, nTextAttr)
  PutStrXY(WIN_ABOUT_WIDTH - Length(gcDllVersion) - 1, 4, gcDllVersion, nTextAttr)

  PutStrXY(2, 5, "OS-Info", nTextAttr)
  PutStrXY(WIN_ABOUT_WIDTH - Length(gcOsVersion) - 1,  5, gcOsVersion, nTextAttr)

  PutStrXY(17, 7, cTop, nTextAttr)
  PutStrXY(17, 8, cCen, nTextAttr)
  PutStrXY(17, 9, cBot, nTextAttr)

  while WaitForKeyPressed(100, FALSE) == 0
    nVPos = Random(1, 10)

    cT = cTop[nVPos]
    cC = cCen[nVPos]
    cB = cBot[nVPos]

    case Random(1, 9)
    when 1, 4, 7
      cTop[nVPos] = cB
      cCen[nVPos] = cT
      cBot[nVPos] = cC
    when 2, 5, 8
      cTop[nVPos] = cC
      cCen[nVPos] = cB
      cBot[nVPos] = cT

    when 3, 6, 9
      cTop[nVPos] = cT
      cCen[nVPos] = cC
      cBot[nVPos] = cB
    endcase

    PutStrXY(17, 7, cTop, nTextAttr)
    PutStrXY(17, 8, cCen, nTextAttr)
    PutStrXY(17, 9, cBot, nTextAttr)
  endwhile

  Set(Attr, nOldAttr)
  PopWinClose()
  SetCursorOn()

  // Clear keyboard buffer to keep menu open
  while KeyPressed()
    GetKey()
  endwhile

end

