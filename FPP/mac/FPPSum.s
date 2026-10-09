/*******************************************************************************

  Filename     : FppSum.s

  Author       : Eckhard Hillmann

  Creation Date: 08. May 2004

  ****************************************************************************
  This software is provided "as is" without express or implied warranty.
  ****************************************************************************

  Description:
  ============
  FppSum provides management functions for the line parser FppCon_xxx.exe
  where all the calculations are done. It provides the necessary files for the
  exe and does the result presentation using the returned data file.

  The sum can be inserted in various formats into the text or the clipboard.

  When started a marked column block to work with is expected.

  For more details see FppHelp.txt (section FppSum).

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
            - Insert result without prefix "Sum:" in text and clipboard.
            Special thanks to Joachim Merkel for his feedback, suggestions
            and testing.

  Apr 2025: Version 1.0.0.65
            - Internal cleaneup
            - Fixed flashing cursor in menu when leaving help
            - More error checking

  Dec 2025: Version 1.0.0.78
            - Cosmetic changes, minor fixes and improvements

  Mar 2026: Version 1.0.0.84
            - Improved handling of very very rare cases
            - Minor fixes and improvements

  Aug 2026: Version 1.0.0.85
            - Portable support-file lookup relative to the macro directory
            - Execute GetFileVersion.mac by its full macro-relative path

  Examples:
  =========
  Mark the area within the single lines with a column block to get the sum.

  +--------------------------------+
  |a=1.25:b=5: a * 1,167.2 + 47.112|
  |1,120.20 + b                    |
  |30.30 / b                       |
  |$ff - 10 / 4                    |
  |              d=47              |
  |3.1415e2                        |
  |40.40                           |
  |              i=23              |
  |- 50.50                         |
  |         pro(100|19)            |
  |2 * 17.5 : 3 * 20               |
  +--------------------------------+
  In this example the total sum is 3,307.922

                     +-------------+
  22.11.2022  00:38  |1,450,470,994| Episode_01.mkv
  22.11.2022  00:50  |1,445,452,901| Episode_02.mkv
  22.11.2022  00:55  |1,450,863,171| Episode_03.mkv
  22.11.2022  00:59  |1,450,780,408| Episode_04.mkv
  22.11.2022  01:02  |1,444,349,981| Episode_05.mkv
  22.11.2022  01:05  |1,450,646,560| Episode_06.mkv
  22.11.2022  01:08  |1,449,969,375| Episode_07.mkv
  22.11.2022  01:10  |1,449,861,282| Episode_08.mkv
  22.11.2022  01:12  |1,449,846,633| Episode_09.mkv
  22.11.2022  01:15  |1,448,968,743| Episode_10.mkv
  22.11.2022  01:17  |1,449,294,539| Episode_11.mkv
  22.11.2022  01:19  |1,448,445,401| Episode_12.mkv
                     +-------------+
  In this example the total sum is 17,388,949,988

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !!                                                                 !!
  !! The following was done to show what may happen if you don't pay !!
  !! attention to the used localization and select the wrong format. !!
  !!                                                                 !!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   Non-US is correctly used here.       US-Standard is wrongly used here.

   Item        ea.                       Item        ea.
  +---------------------------------+   +---------------------------------+
  |Salad     = 0,99 : Salad     * 2 |   |Salad     = 0,99 : Salad     * 2 |
  |Bread     = 0,39 : Bread     * 9 |   |Bread     = 0,39 : Bread     * 9 |
  |Cheese    = 0,59 : Cheese    * 6 |   |Cheese    = 0,59 : Cheese    * 6 |
  |Chocolate = 2,79 : Chocolate * 3 |   |Chocolate = 2,79 : Chocolate * 3 |
  |Peanuts   = 2,29 : Peanuts   * 2 |   |Peanuts   = 2,29 : Peanuts   * 2 |
  +---------------------------------+   +---------------------------------+
                Sum :     21,98 EURO                  Sum :     2,198 EURO

 *******************************************************************************/

// Used DLLs, used functions and constants to include here
#define GET_OS_VERSION_STRING   TRUE
#define GET_IS_WOW64            TRUE
#define GET_SYSTEM_CLOCK_TICKS  TRUE
#define RUN_APPLICATION         TRUE
#define CONVERT_BASE10_TO_BASEX TRUE
#define QUERY_LOCALE_INFO       TRUE

#include ["BO_Helper.inc"]

// Used includes
#include ["FPPError.h"]

// Selector where to insert data used with FppInsertResult() und FppCopyToClipboard()
constant INSERT_AT_BLOCKEND = TRUE
constant INSERT_AT_CURSOR   = FALSE

constant DECIMAL_RESULT     = TRUE
constant BASE_RESULT        = FALSE

// Constants used for output and dimensions
constant RESULT_DISPLAY_SIZE = 60
constant BASE_FIELD_SIZE     = 64
constant BASE_HEADER_SIZE    = 16
constant RESULT_64_SIZE      = 27
constant EXE_DISPLAY_SIZE    = 32
constant LINES_DISPLAY_SIZE  = 32
constant TIME_DISPLAY_SIZE   = 15
constant TIME_TAKEN_LENGHT   = 32

// Window sizes
constant WIN_WIDTH  = 53
constant WIN_HEIGHT = 7

// About window size
constant WIN_ABOUT_HEIGHT = 11
constant WIN_ABOUT_WIDTH  = 42

// Textlength and positions
constant STAT_TXT_LEN  = 50

constant X_TEXT        = 2

constant Y_COPY_BLOCK  = 1
constant Y_NORM_BLOCK  = 2
constant Y_DET_FRAC    = 3
constant Y_WRITE_BLOCK = 4
constant Y_CALCULATE   = 5

// Fraktional digits in result, Range 0-99
constant FLOAT_DECIMALS     = 30
constant FLOAT_MAX_DECIMALS = 99

// Color help marker
constant DEFAULT_COL_HELP_MARKER = 0x8A

// Size of TOC-Marker
constant TOC_MARKER_SIZE = 5

// Size of version strings
constant OS_VERSION_LENGTH = 30

// Return-codes for EndProcess
constant EP_ABORT          =  0
constant EP_FPP_HELP_TOC   = -15

// Range of number bases
constant MIN_BASE     =  2
constant MAX_BASE     = 36
constant DEFAULT_BASE = 16

// Codes for Statusdisplay
constant STAT_COPY_BLOCK = 0,
         STAT_NORM_BLOCK,
         STAT_DET_FRAC,
         STAT_WRITE_BLOCK,
         STAT_CALCULATE

// Possible result localizations
constant LOCALE_US = 1,         // -us
         LOCALE_NU,             // -nu
         LOCALE_SY              // -sy
// The sequence in this string must match the above constants
string gcLocaleSelector[] = "-us -nu -sy"

// Filenames used for data exchange with FppCon_xxx.exe
string gcFileResult[]   = "FppSumRes.txt"
string gcFileFormular[] = "FppSumExp.txt"

// Filename used for redirection when in console mode only
string gcFileRedirect[] = "FppRedir.txt"

// Filename FppSum help
string gcFileHelp[]     = "FppHelp.txt"

// Used paths for EXE, DLL, MAC and TXT
string gcLoadDir[_MAXPATH_] = ""
string gcMacDir[_MAXPATH_]  = ""

// Identifier for exe-version/-name x86 and x64 and macro
string gcExe_x64[]    = "FppCon_x64.exe" // 64-Bit OS
string gcExe_x86[]    = "FppCon_x86.exe" // 32-Bit OS

string gcExeName[16]  = ""               // min length is longest exe-name
string gcNeedExeVer[] = "2.4.3.26"       // min needed exe version

string gcDllName[]    = "BO_Helper.dll"  // name of helper dll
string gcNeedDllVer[] = "1.9.1.29"       // min needed dll version

string gcMacVersion[] = "1.0.0.85"

// Versiondata of exe and dll
string gcExeVersion[23] = ""
string gcDllVersion[23] = ""
string gcOsVersion[OS_VERSION_LENGTH] = ""

// Identifier used for TSE.INI
string gcTSE_INI_KEY[]     = "FppSum"
string gcBASE_INI[]        = "Base"
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

// Result strings
string gcResult[MAXSTRINGLEN]               = ""
string gcBaseResult[MAXSTRINGLEN]           = ""
string gcBase10[MAXSTRINGLEN]               = ""
string gcTimeTaken[TIME_TAKEN_LENGHT]       = ""
string gcTimeCompRun[TIME_TAKEN_LENGHT]     = ""
string gcTotalTimeTaken[TIME_TAKEN_LENGHT]  = ""
string gcLinesProcessed[LINES_DISPLAY_SIZE] = ""

// Position for marking
string gcTocLine[20] = ""

// Used marker for TOC
string gcTocMarker[TOC_MARKER_SIZE] = "#"

// Lacalization data
string gcSystemDecimalSep[5]  = ""
string gcSystemThousandSep[5] = ""
string gcSystemGrouping[10]   = ""

// Number of digits dependent from base
string gcBaseLen[] = "0 64 41 32 28 25 23 22 21 20 19 18 18 17 17 16 16 16 16 15 15 15 15 14 14 14 14 14 14 14 13 13 13 13 13 13 "
//  Base                2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36

string gcBaseHeader[BASE_HEADER_SIZE] = ""

// Defaults of global variables
integer gnLineCount      = 0
integer gnErrorPos       = 0
integer gnBase           = 0
integer gnNoConvert      = 0
integer gfExitMenu       = FALSE
integer gnResLocale      = LOCALE_US
integer gnDigits         = FLOAT_DECIMALS
integer gnColHelpMarker  = 0

// Handles used for redirection when in console mode only
integer gnHandStdOut = 0
integer gnHandErrOut = 0

// Declaration of used procs etc.
forward proc Main()
forward proc WhenLoaded()
forward proc WhenPurged()
forward proc FppOnAbandonEditor()
forward integer proc FppGetLocaleInfo(integer vnLocalType, integer vnInfoType, var string rcInformation)
forward KeyDef FppHelpKeysS
forward KeyDef FppHelpTocKeysS
forward proc FppEnableHelpKeys()
forward proc FppDisableHelpKeys()
forward proc FppEnableTocKeys()
forward proc FppDisableTocKeys()
forward proc FppEnableErrorFooter()
forward proc FppHelp(string vcHelpSearch)
forward proc FppHiliteText()
forward proc FppDrawHelpLine(integer vfIsCursor)
forward proc FppHelpToc()
forward proc FppDrawTocLine(integer vfIsCursor)
forward proc FppShowErrors(integer vnErrors)
forward menu FppBlockLokalizedMenu()
forward menu FppInsertResultMenu()
forward proc FppIncrementBase()
forward proc FppDecrementBase()
forward proc FppConvertBase10ToBaseX()
forward proc FppInsertResult(integer vnInsertPos, integer vnResultType)
forward proc FppCopyToClipboard(integer vnResultType)
forward proc FppCopyToTseClip(integer vnResultType)
forward proc FppEnterDigits()
forward proc FppEditTocMarker()
forward string proc FppLocalizeResult(string vcDecimalSep, string vcThousandSep, string vcGrouping, string vcResultToFormat)
forward integer proc FppOpenProgress(integer vnXPos, integer vnYPos)
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

  integer nTempBuffer        = 0
  integer nProcess           = 0
  integer nRetVal            = 0
  integer nFraction          = 0
  integer nFrac              = 0
  integer nIsFracInBlock     = FALSE
  integer nDefaultFracDigits = 2
  integer nSystemFracDigits  = 2
  integer nTickStart         = 0
  integer nTickStop          = 0
  integer nLen               = 0
  integer nxPos              = WhereXAbs()
  integer nyPos              = WhereYAbs()
  integer nOldBuffer         = GetBufferId()

  string cSearch[15]           = ""
  string cDecimalSep[5]        = ""
  string cThousandSep[5]       = ""
  string cGrouping[10]         = ""
  string cSum[MAXSTRINGLEN]    = ""
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

  // No insert into text in browse mode
  if BrowseMode()
    if MsgBox(SplitPath(CurrMacroFilename(), _NAME_),
              "Browse-Mode is activ!" + Chr(13) + Chr(13) +
              "Result can be inserted into Clipboard only." + Chr(13) + Chr(13) +
              "Do you want to continue?",
              _YES_NO_
             ) <> 1                       // 1 = OK (Yes)
      return()
    endif
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
  if FppOpenProgress(nxPos, nyPos) == FALSE
    return()
  endif

  // Prepare block for calculation
  nTickStart = GetSystemClockTicks()
  PushBlock()

  nTempBuffer = CreateTempBuffer()
  SetUndoOff()                              // saves memory and time

  FppSetStatus(STAT_COPY_BLOCK)
  if CopyBlock() == 0
    AbandonFile(nTempBuffer)
    PopWinClose()                           // close status/progress
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_),
           "Block couldn't be copied!",
           _OK_
          )
    GotoBufferId(nOldBuffer)
    PopBlock()
    return()
  endif

  FppSetStatus(STAT_NORM_BLOCK)
  lReplace(trim(cThousandSep), "", "ign")   // remove thousandseparator
  lReplace(trim(cDecimalSep), ".", "ign")   // replace local decimalseparator

  // Convert tab to space to get the right errorposition for display if necessary
  BegFile()
  while lFind(Chr(9), "i")
    ExpandTabsToSpaces()
  endwhile

  lReplace(" #", "", "$gnx")                // remove all trailing spaces

  // Determine number of fractional digits
  FppSetStatus(STAT_DET_FRAC)

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

    nFraction = nFraction - 1               // because of decimal separator

    if nFraction > 0
      nIsFracInBlock = TRUE
    endif
  endif

  nFraction = Min(Max(nDefaultFracDigits, nFraction), FLOAT_MAX_DECIMALS)

  // Store file for evaluation
  FppSetStatus(STAT_WRITE_BLOCK)
  if SaveAs(gcMacDir + gcFileFormular, _OVERWRITE_) == 0
    PopWinClose()                           // Close status
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_),
           "Error writing file:" + Chr(13) +
           gcMacDir + gcFileFormular + Chr(13),
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

  // Sum file
  // Repacement for ldos()
  // ldos() doesn't deliver the needed return value and can't handle the window
  // nProcess -> >0 = Process was started
  //              0 = Process couldn't get started
  //             <0 = OS-Errormessage
  nProcess = RunApplication('"' + gcLoadDir + gcExeName + '"',
                            "Su " +
                            '"-e' + gcMacDir + gcFileFormular + '" ' +
                            '"-r' + gcMacDir + gcFileResult   + '"'  +
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

  PopWinClose()                             // Close status

  // Everything went well
  if nProcess > 0
    // Load resultfile
    if FindThisFile(gcMacDir + gcFileResult) == FALSE
      Warn("Error loading " + gcMacDir + gcFileResult +", File not found")
      return()
    endif

    // Get result from file
    PushBlock()
    nTempBuffer = CreateTempBuffer()
    SetUndoOff()                            // saves time and memory

    if InsertFile(gcMacDir + gcFileResult, _DONT_PROMPT_) == 0
      AbandonFile(nTempBuffer)
      MsgBox(SplitPath(CurrMacroFilename(), _NAME_),
             "Resultfile couldn't be loaded!" + Chr(13) +
             gcMacDir + gcFileResult + Chr(13),
             _OK_
            )
      GotoBufferId(nOldBuffer)
      PopBlock()
      return()
    endif

    cSum         = "???"
    gcErrorText  = ""
    gcMathError  = ""
    gcExpression = ""
    gcBaseResult = ""
    gcBase10     = ""
    gnLineCount  = 0
    gnErrorPos   = 0
    gnNoConvert  = 0

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
      gnLineCount = Val(GetText(1, 10))
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

    // Refresh fractional digits, because they could have changed due to
    // mathematical operations.
    // The largest number of fractional digits will always be used.
    if lReplace("[QRESULT]", "", "g^1")
      gcBase10 = Trim(GetText(1, MAXSTRINGLEN))
      if StrFind("\.[0-9Ee]#", gcBase10, "x", 1, nLen)
        // Exponential values are *not* taken into account
        if StrFind("E", gcBase10, "i", 1) == 0
          nFrac = Max(nFraction, nLen - 1)
        endif

      // Result doesn't contain fractional digits but there were some at the source block
      elseif nIsFracInBlock
        nFrac = nFraction
      endif
    endif

    // Result in range of 64 Bit
    if lReplace("[U64]", "", "g^1")
      cBuffer = Trim(GetText(1, RESULT_64_SIZE))
      // Not in range "--" or error "  "
      if Pos(LeftStr(cBuffer, 2), "--  ") or Length(cBuffer) == 0
        gnNoConvert = _MF_GRAYED_ | _MF_SKIP_
      endif
    endif

    // Get result for display
    if lReplace("[QRESULT_LOC]", "", "g^1")
      // Format result, look for decimal separator
      cSearch = "\" + cDecimalSep + "[0-9Ee]#"

      if lFind(cSearch, "xc")
        cSum = GetFoundText()
        // Exponential values will *not* be formatted
        if StrFind("E", cSum, "i")
          goto GET_RESULT_NO_FORMAT
        endif

        nLen = Length(cSum) - 1             // because of decimal separator

        // Append zeros till min number of fractional digits is reached
        if nFrac > nLen
          cSum = Format(cSum, "":nFrac - nLen:"0")
          lReplace(cSearch, cSum, "xc1")
        endif

        // Result is without fractional digits, but there were some in the source block
        // append with min number of fractional digits
      elseif nFrac > 0
        Endline()
        InsertText(Format(cDecimalSep, "":nFraction:"0"), _INSERT_)
      endif

GET_RESULT_NO_FORMAT:
      gcResult = Trim(GetText(1, MAXSTRINGLEN))

    // No localized result could be found
    else
      gcResult = cSum
    endif

    AbandonFile(nTempBuffer)
    GotoBufferId(nOldBuffer)
    PopBlock()

    // No error, prepare result for inserting into text
    if nRetVal == ERROR_NO_ERROR

      // Empty Result
      if gcResult == ""
        Warn("No result found!")
        UpdateDisplay(_STATUSLINE_REFRESH_) // restore statusline
        return ()
      endif

      // Convert result to basex
      FppConvertBase10ToBaseX()

      gfExitMenu       = FALSE              // to stay in loop
      nTickStop        = GetSystemClockTicks()
      gcTotalTimeTaken = FppLocalizeResult(cDecimalSep, cThousandSep, cGrouping, Str(nTickStop - nTickStart))
                         + " msec."
      gcLinesProcessed = gcLinesProcessed + " / " + FppLocalizeResult(cDecimalSep, cThousandSep, cGrouping, Str(gnLineCount))

      UpdateDisplay(_STATUSLINE_REFRESH_)   // restore statusline

      // Insert result into text
      // Loop because you can change the base
      BufferVideo()
      repeat
        gcBaseHeader = "Current base:" + Format(gnBase:3)
      until FppInsertResultMenu() == 0 or gfExitMenu == TRUE
      UnBufferVideo()

    // Check only the highest possible error-code first
    elseif nRetVal == ERROR_IN_EXPRESSION
      MsgBox("Error while building sum",
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
    nProcess = -nProcess
    Warn("OS-Errorcode: " + Str(nProcess) + Chr(13)
         + "trying to run " + gcExeName + " command Sum failed"
        )
    UpdateDisplay(_STATUSLINE_REFRESH_)     // restore statusline

  // Program not found???
  else
    Warn(gcExeName + " command Sum could not be executed")
    UpdateDisplay(_STATUSLINE_REFRESH_)     // restore statusline
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

  integer nCount = 0
  integer nChar  = 0

  string  cBuffer[TOC_MARKER_SIZE * 3] = ""

  // Initialize hooks
  Hook(_ON_ABANDON_EDITOR_, FppOnAbandonEditor)

  // Numeric data
  gnBase = GetProfileInt(gcTSE_INI_KEY, gcBASE_INI, DEFAULT_BASE)
  if (gnBase in MIN_BASE .. MAX_BASE) == FALSE
    gnBase = DEFAULT_BASE
  endif

  gnDigits = GetProfileInt(gcTSE_INI_KEY, gcDIGITS_INI, FLOAT_DECIMALS)
  if (gnDigits in 0 .. FLOAT_MAX_DECIMALS) == FALSE
    gnDigits = FLOAT_DECIMALS
  endif

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
  WriteProfileInt(gcTSE_INI_KEY, gcBASE_INI, gnBase)
  WriteProfileInt(gcTSE_INI_KEY, gcDIGITS_INI, gnDigits)

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
/// FppHelpKeysS
///
/// Activates when Help is selected in the main menu.
///
///*****************************************************************************
KeyDef FppHelpKeysS
  <Escape>              EndProcess(EP_ABORT)

  <Ctrl Home>           Begfile()
  <Ctrl End>            Endfile()
  <Ctrl PgUp>           BegWindow()
  <Ctrl PgDn>           EndWindow()
  <Alt T>               FppHelpToc() EndProcess(EP_FPP_HELP_TOC)

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
/// FppHelpTocKeysS
///
/// Activates when <Alt T> is pressed in the help-list.
///
///*****************************************************************************
KeyDef FppHelpTocKeysS

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

  if not Enable(FppHelpKeysS)
    Warn(SplitPath(CurrMacroFilename(), _NAME_) +
         Chr(13) + Chr(13) +
         "FppHelpKeysS could not be activated!" + Chr(13) +
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
  Disable(FppHelpKeysS)
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

  if not Enable(FppHelpTocKeysS)
    Warn(SplitPath(CurrMacroFilename(), _NAME_) +
         Chr(13) + Chr(13) +
         "FppHelpTocKeysS could not be activated!" + Chr(13) +
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
  Disable(FppHelpTocKeysS)
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

    if lList("FppSum Help: " + gcFileHelp, nMaxWidth, Query(ScreenRows), _ENABLE_SEARCH_ | _ENABLE_HSCROLL_) == EP_ABORT
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
    if lList("FppSum Help: TOC-List", nMaxWidth, Query(ScreenRows), _ENABLE_SEARCH_ | _ENABLE_HSCROLL_)
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
  SetUndoOff()                              // saves memory and time

  if vnErrors & ERROR_IN_EXPRESSION
    AddLine("Error in Expression")
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
    AddLine("Error allocating memory")
    AddLine()
  endif

  if vnErrors & ERROR_COMMANDLINE_PARAMETER
    AddLine("Error commandline parameter")
    AddLine()
  endif

  if vnErrors & ERROR_VAR_NO_FILENAME
    AddLine("Error no filename for ID-List")
    AddLine()
  endif

  if vnErrors & ERROR_CODE_NO_FILENAME
    AddLine("Error no filename for Code-List")
    AddLine()
  endif

  if vnErrors & ERROR_RESULT_OPEN_FILE
    AddLine(gcErrorOpenFile + gcMacDir + gcFileResult)
    AddLine()
  endif

  if vnErrors & ERROR_RESULT_CLOSE_FILE
    AddLine(gcErrorCloseFile + gcMacDir + gcFileResult)
    AddLine()
  endif

  if vnErrors & ERROR_RESULT_WRITE_FILE
    AddLine(gcErrorWriteFile + gcMacDir + gcFileResult)
    AddLine()
  endif

  if vnErrors & ERROR_RESULT_NO_FILENAME
    AddLine("Error no filename for Result")
    AddLine()
  endif

  if vnErrors & ERROR_EXPR_OPEN_FILE
    AddLine(gcErrorOpenFile + gcMacDir + gcFileFormular)
    AddLine()
  endif

  if vnErrors & ERROR_EXPR_CLOSE_FILE
    AddLine(gcErrorCloseFile + gcMacDir + gcFileFormular)
    AddLine()
  endif

  if vnErrors & ERROR_EXPR_READ_FILE
    AddLine(gcErrorReadFile + gcMacDir + gcFileFormular)
    AddLine()
  endif

  if vnErrors & ERROR_EXPR_NO_FILENAME
    AddLine("Error no filename for Expression")
    AddLine()
  endif

  // Limit width to edit window
  nMaxWidth = Min(Query(ScreenCols), LongestLineInBuffer())

  // Display errorlist
  Hook(_LIST_STARTUP_, FppEnableErrorFooter)
  lList("FppSum Returned Errors",
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
/// FppBlockLokalizedMenu
///
/// Selection of the input/output localization and options.
///
///*****************************************************************************
menu FppBlockLokalizedMenu()
  history
  title = "FppSum - Number Input and Output Format"

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

  "&D - Digits for Result Display"[gnDigits:2], FppEnterDigits(),
  _MF_DONT_CLOSE_,
  "Applies to Results only. Range 0-99, default=30, active with next evaluation"

  "",, _MF_DIVIDE_

  "&E - TOC-Marker Sign"[gcTocMarker:TOC_MARKER_SIZE],
  FppEditTocMarker(),
  _MF_DONT_CLOSE_,
  "Lets you change the current used TOC-Marker sign. Default: #"

  "Help",, _MF_DIVIDE_

  "&F - FppSum Help", FppHelp("FppSum Help"),
  _MF_DONT_CLOSE_,
  "Shows the help-file section"

  "",, _MF_DIVIDE_

  "&G - About",
  FppAbout(),
  _MF_DONT_CLOSE_,
  "Shows version info about the macro, used Exe, Dll and OS"

end

///*****************************************************************************
///
/// FppInsertResultMenu
///
/// Select result to insert into text or clipboard
///
///*****************************************************************************
menu FppInsertResultMenu()
  history
  title = "FppSum - Result Output"

  "Result"[gcResult:RESULT_DISPLAY_SIZE],, _MF_SKIP_

  "Insert result at",, _MF_DIVIDE_

  "&A - Cursor", FppInsertResult(INSERT_AT_CURSOR, DECIMAL_RESULT),
  _MF_CLOSE_ALL_BEFORE_ | iif(BrowseMode(), _MF_GRAYED_, _MF_ENABLED_)

  "&B - End of block", FppInsertResult(INSERT_AT_BLOCKEND, DECIMAL_RESULT),
  _MF_CLOSE_ALL_BEFORE_ | iif(BrowseMode(), _MF_GRAYED_, _MF_ENABLED_)

  "&C - Windows clipboard", FppCopyToClipboard(DECIMAL_RESULT),
  _MF_CLOSE_ALL_BEFORE_

  "&D - TSE clipboard", FppCopyToTseClip(DECIMAL_RESULT),
  _MF_CLOSE_ALL_BEFORE_

  "Result base X (max. 64 bit int)"[gcBaseHeader:BASE_HEADER_SIZE],, _MF_DIVIDE_

  ""[gcBaseResult:BASE_FIELD_SIZE],,
  _MF_SKIP_ | gnNoConvert

  "&E - Increment Base", FppIncrementBase(),
  _MF_CLOSE_AFTER_ | gnNoConvert

  "&F - Decrement Base", FppDecrementBase(),
  _MF_CLOSE_AFTER_ | gnNoConvert

  "Insert result base X at",, _MF_DIVIDE_

  "&G - Cursor", FppInsertResult(INSERT_AT_CURSOR, BASE_RESULT),
  _MF_CLOSE_ALL_BEFORE_ | gnNoConvert | iif(BrowseMode(), _MF_GRAYED_, _MF_ENABLED_)

  "&H - End of block", FppInsertResult(INSERT_AT_BLOCKEND, BASE_RESULT),
  _MF_CLOSE_ALL_BEFORE_ | gnNoConvert | iif(BrowseMode(), _MF_GRAYED_, _MF_ENABLED_)

  "&I - Windows clipboard", FppCopyToClipboard(BASE_RESULT),
  _MF_CLOSE_ALL_BEFORE_ | gnNoConvert

  "&J - TSE clipboard", FppCopyToTseClip(BASE_RESULT),
  _MF_CLOSE_ALL_BEFORE_ | gnNoConvert

  "Processing info",, _MF_DIVIDE_

  "Overall time"[gcTotalTimeTaken:TIME_DISPLAY_SIZE],,
  _MF_SKIP_ | _MF_GRAYED_

//  "",, _MF_DIVIDE_

  "Program used"[gcExeName + " " + gcExeVersion:EXE_DISPLAY_SIZE],,
  _MF_SKIP_ | _MF_GRAYED_

  "Lines processed"[gcLinesProcessed:LINES_DISPLAY_SIZE],,
  _MF_SKIP_ | _MF_GRAYED_

  "Parsing overall"[gcTimeTaken:TIME_DISPLAY_SIZE],,
  _MF_SKIP_ | _MF_GRAYED_

  "Calculation only"[gcTimeCompRun:TIME_DISPLAY_SIZE],,
  _MF_SKIP_ | _MF_GRAYED_

end

///*****************************************************************************
///
/// FppIncrementBase
///
/// Increment base and converting the result into it
///
///*****************************************************************************
proc FppIncrementBase()
  gnBase = gnBase + 1

  if gnBase > MAX_BASE
    gnBase = MIN_BASE
  endif

  FppConvertBase10ToBaseX()

end

///*****************************************************************************
///
/// FppDecrementBase
///
/// Decrement base and converting the result into it
///
///*****************************************************************************
proc FppDecrementBase()
  gnBase = gnBase - 1

  if gnBase < MIN_BASE
    gnBase = MAX_BASE
  endif

  FppConvertBase10ToBaseX()

end

///*****************************************************************************
///
/// FppConvertBase10ToBaseX
///
/// Converts decimal result into base x, integer only!
///
///*****************************************************************************
proc FppConvertBase10ToBaseX()

  integer nRetVal = 0

  // nRetVal -> > 0 ok, Number of copied bytes
  //             < 0 Error, value is error code
  // This call is intentially used, because the TSE-funktion only works
  // on 32 bit signed values. This special kind of display needs unsigned
  // 64 bit values.
  if gnNoConvert == 0
    nRetVal = ConvertBase10ToBaseX(gnBase, gcBase10, gcBaseResult)

    if nRetVal == CONV_BASE10_BASE_OUT_OF_RANGE
      Warn("Base not in Range, valid range is 2...36")
      return()

    elseif nRetVal == CONV_BASE10_DEST_STRING_SIZE_TO_SMALL
      Warn("Storage area (stringlength) is to small for converted number")
      return()

    elseif nRetVal == CONV_BASE10_TO_BIG_FOR_64_BIT
      Warn("Number exceeds integer 64 bit limit")
      return()

    elseif nRetVal == CONV_BASE10_MATHERROR
      Warn(gcBaseResult + " Input was:" + gcBase10)
      return()
    endif

    gcBaseResult = Format(gcBaseResult:BASE_FIELD_SIZE:"0")
    gcBaseResult = Format(RightStr(gcBaseResult, Val(GetToken(gcBaseLen, " ", gnBase))):BASE_FIELD_SIZE)
  endif

end

///*****************************************************************************
///
/// FppInsertResult
///
/// Called from FppInsertResultMenu to insert result into text.
///
/// Input:
/// vnInsertPos  -> INSERT_AT_BLOCKEND
///                 INSERT_AT_CURSOR
/// vnResultType -> DECIMAL_RESULT
///                 BASE_RESULT
///
///*****************************************************************************
proc FppInsertResult(integer vnInsertPos, integer vnResultType)

  if vnInsertPos == INSERT_AT_BLOCKEND
    // insert result always below the marked block
    GotoBlockEnd()
    GotoColumn(Query(BlockBegCol))
    if not Down()
      AddLine()
    elseif CurrLineLen() <> 0
      Insertline()
    endif
  endif

  InsertText(iif(vnResultType == DECIMAL_RESULT,
                 Trim(gcResult),
                 Format("Base", gnBase:3, ": ", Trim(gcBaseResult))), _INSERT_)

  gfExitMenu = TRUE

end

///*****************************************************************************
///
/// FppCopyToClipboard
///
/// Called from FppInsertResultMenu to insert result into Windows-clipboard
///
/// Input:
/// vnResultType -> DECIMAL_RESULT
///                 BASE_RESULT
///
///*****************************************************************************
proc FppCopyToClipboard(integer vnResultType)

  if vnResultType == DECIMAL_RESULT
    CopyToWinClip(Trim(gcResult))
  else
    CopyToWinClip(Format("Base", gnBase:3, ": ", Trim(gcBaseResult)))
  endif

  gfExitMenu = TRUE

end

///*****************************************************************************
///
/// FppCopyToTseClip
///
/// Called from FppInsertResultMenu to insert result into TSE-clipboard
///
/// Input:
/// vnResultType -> DECIMAL_RESULT
///                 BASE_RESULT
///
///*****************************************************************************
proc FppCopyToTseClip(integer vnResultType)

  if vnResultType == DECIMAL_RESULT
    CopyToClipboard(Trim(gcResult))
  else
    CopyToClipboard(Format("Base", gnBase:3, ": ", Trim(gcBaseResult)))
  endif

  gfExitMenu = TRUE

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
  string  cBuffer[MAXSTRINGLEN] = ""
  string  cSign[1]              = ""

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

////****************************************************************************
///
/// FppOpenProgress
///
/// Opens the progress window with constant elements. All elements are displayed
/// as grayed out.
///
/// Input:
/// vnXPos  -> Current horizontal cursorposition relativ to the full screen
/// vnYPos  -> Current vertical cursorposition relativ to the full screen
///
/// Return:
/// TRUE  -> Window could be opened
/// FALSE -> Error while opening the window
////****************************************************************************
integer proc FppOpenProgress(integer vnXPos, integer vnYPos)

  integer nTextAttr = Query(MenuTextAttr)
  integer nGrayAttr = Query(MenuGrayAttr)
  integer nOldAttr  = 0

  // Determine X-Position for PopUp
  if vnXPos > WIN_WIDTH
    vnXPos = vnXPos - WIN_WIDTH
  else
    vnXPos = vnXPos + 1
  endif

  if vnXPos + WIN_WIDTH > Query(ScreenCols)
    vnXPos = Query(WindowCols) - WIN_WIDTH
  endif

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
  if PopWinOpen(vnXPos, vnYPos, vnXPos + WIN_WIDTH, vnYPos + WIN_HEIGHT - 1,
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

  PutStrXY(X_TEXT, Y_COPY_BLOCK,  "Copy Block", nGrayAttr)
  PutStrXY(X_TEXT, Y_NORM_BLOCK,  "Normalize copy of marked block", nGrayAttr)
  PutStrXY(X_TEXT, Y_DET_FRAC,    "Determine fractional digits", nGrayAttr)
  PutStrXY(X_TEXT, Y_WRITE_BLOCK, "Writing block to file", nGrayAttr)
  PutStrXY(X_TEXT, Y_CALCULATE,   "Calculating sum. Run " + gcExeName + " [" + gcExeVersion + "]", nGrayAttr)

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
    PutAttrXY(X_TEXT, Y_COPY_BLOCK,  nActivAttr, STAT_TXT_LEN)

  when STAT_NORM_BLOCK
    PutAttrXY(X_TEXT, Y_COPY_BLOCK,  nGrayAttr,  STAT_TXT_LEN)
    PutAttrXY(X_TEXT, Y_NORM_BLOCK,  nActivAttr, STAT_TXT_LEN)

  when STAT_DET_FRAC
    PutAttrXY(X_TEXT, Y_NORM_BLOCK,  nGrayAttr,  STAT_TXT_LEN)
    PutAttrXY(X_TEXT, Y_DET_FRAC,    nActivAttr, STAT_TXT_LEN)

  when STAT_WRITE_BLOCK
    PutAttrXY(X_TEXT, Y_DET_FRAC,    nGrayAttr,  STAT_TXT_LEN)
    PutAttrXY(X_TEXT, Y_WRITE_BLOCK, nActivAttr, STAT_TXT_LEN)

  when STAT_CALCULATE
    PutAttrXY(X_TEXT, Y_WRITE_BLOCK, nGrayAttr,  STAT_TXT_LEN)
    PutAttrXY(X_TEXT, Y_CALCULATE,   nActivAttr, STAT_TXT_LEN)
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

  string  cTop[6]   = "------"
  string  cCen[6]   = "FppSum"
  string  cBot[6]   = "======"
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

  PutStrXY(19, 7, cTop, nTextAttr)
  PutStrXY(19, 8, cCen, nTextAttr)
  PutStrXY(19, 9, cBot, nTextAttr)

  while WaitForKeyPressed(100, FALSE) == 0
    nVPos = Random(1, 6)

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

    PutStrXY(19, 7, cTop, nTextAttr)
    PutStrXY(19, 8, cCen, nTextAttr)
    PutStrXY(19, 9, cBot, nTextAttr)
  endwhile

  Set(Attr, nOldAttr)
  PopWinClose()
  SetCursorOn()

  // Clear keyboard buffer to keep menu open
  while KeyPressed()
    GetKey()
  endwhile

end

