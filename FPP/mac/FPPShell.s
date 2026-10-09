/*******************************************************************************

  Filename     : FppShell.s

  Author       : Eckhard Hillmann

  Creation Date: 06. May 2004

  It all started as a quick and dirty hack to make my programmers life a bit
  easier. Over the years it got a bit bigger, but hopefully, less dirty ;-)

  ****************************************************************************
  This software is provided "as is" without express or implied warranty.
  ****************************************************************************

  Description:
  ============
  FppShell provides management and edit functions for the line parser
  FppCon*.exe where all the calculations are done.
  It provides the necessary files for the exe and does the result presentation
  using the returned data files.

  History:
  ========
  Jan 2025: Version 1.1.32.44
            First public release

  Feb 2025: Version 1.1.32.50
            - Added mouse support to edit-line.
            Special thanks to Joachim Merkel for his feedback, suggestions
            and testing.

  Feb 2025: Version 1.1.32.53
            - Added TOC (T)able (O)f (C)ontents and unified help handling to
            - all Fpp* macros.
            Thanks to Joachim Merkel who inspired me to add this.

  Mar 2025: Version 1.1.32.59
            - Moved color settings to own menu.
            - Added TOC-Marker sign to option menu to let the user select/set
              his own marker when he added/changed them in FppHelp.txt. The
              setting is individual for each macro.
            Special thanks to Joachim Merkel for his feedback, suggestions
            and testing.

  Apr 2025: Version 1.1.32.65
            - Internal cleaneup
            - More error checking
            - Enhanced word detection when F1 or @F is pressed

  Dec 2025: Version 1.1.32.93
            - Cosmetic changes, minor fixes and improvements
            - Improved range check for mouse-actions
            - Changed behavior of XButton1 and XButton2
              <XButton1>
                Short click:
                  Move cursor left to the beginning of next word.
                Long click:
                  Deletes word left.
              <XButton2>
                Short click:
                  Move cursor right to the beginning of next word.
                Long click:
                  Deletes word right.
            - Long-Left-Click outside input-line didn't always work as expected

  Mar 2026: Version 1.1.32.99
            - Improved handling of very very rare cases
            - Minor fixes and improvements

  Aug 2026: Version 1.1.32.100
            - Portable support-file lookup relative to the macro directory
            - Execute GetFileVersion.mac by its full macro-relative path


 *******************************************************************************/

// Comfort function for FppPickColor() and moving the cursor in the input-line
#if (EDITOR_VERSION >= 0x00004000)
  #define WHEEL_IS_PRESENT     TRUE
#endif

#if (EDITOR_VERSION > 0x00004400)
  #define XBUTTON_IS_PRESENT   TRUE
#endif

// Default public color values, related to TSE standard default settings
#define PUBLIC_DEFAULT_COLORS   TRUE

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

// Fieldsizes for data
constant BASE_FIELD_SIZE        = 64
constant RESULT_F32_SIZE        = 8
constant RESULT_F64_SIZE        = 16
constant RESULT_F32_BIN_SIZE    = 32
constant RESULT_F64_BIN_SIZE    = 64
constant RESULT_F32D_SIZE       = 16
constant RESULT_F64D_SIZE       = 24
constant RESULT_U64_HEX_SIZE    = 16
constant RESULT_64_SIZE         = 29
constant RESULT_32_SIZE         = 14
constant RESULT_16_SIZE         = 8
constant RESULT_8_SIZE          = 5
constant RESULT_FLOAT_SIZE      = 64
constant RESULT_TIME_TAKEN_SIZE = 14

// Fraktional digits in result, Range 0-99
constant FLOAT_DECIMALS     = 50
constant FLOAT_MAX_DECIMALS = 99

// Output window size
constant WIN_HEIGHT = 23
constant WIN_WIDTH  = 76

// About window size
constant WIN_ABOUT_HEIGHT = 11
constant WIN_ABOUT_WIDTH  = 42

// Line in outputwindow
constant WIN_BASE1_3_X      = 2
constant WIN_BASE1          = 1
constant WIN_BASE2          = 2
constant WIN_BASE3          = 3
constant WIN_LINE_1         = 4
constant WIN_UN_SI_HEAD     = 5
constant WIN_UNSIGNED       = 6
constant WIN_SIGNED         = 7
constant WIN_U64_HEX        = 8
constant WIN_LINE_2         = 9
constant WIN_IEEE_HEAD      = 10
constant WIN_IEEE_SINGLE    = 11
constant WIN_IEEE_S_BIN     = 12
constant WIN_IEEE_DOUBLE    = 13
constant WIN_IEEE_D_BIN     = 14
constant WIN_LINE_3         = 15
constant WIN_DECIMAL        = 16
constant WIN_FORMAT_FLOAT_X = 9
constant WIN_LINE_4         = 17
constant WIN_TEXT           = 18
constant WIN_EXPRESSION     = 19
constant WIN_ERROR          = 20
constant WIN_MATHERROR      = 21

// Codes for FppBase()
constant BASE_UP   = TRUE
constant BASE_DOWN = FALSE
constant BASE_1    = 1
constant BASE_2    = 2
constant BASE_3    = 3

// Codes for which mouse-button is pressed
constant MBUT_LEFT = 1,
         MBUT_RIGHT,
         MBUT_XBUT_1,
         MBUT_XBUT_2

// Menucodes for what to insert in FppInsertResult()
constant RESULT_BASE_1 = 0,
         RESULT_BASE_2,
         RESULT_BASE_3,
         RESULT_F32,
         RESULT_F64,
         RESULT_F32_BIN,
         RESULT_F64_BIN,
         RESULT_F32D,
         RESULT_F64D,
         RESULT_U64,
         RESULT_S64,
         RESULT_U32,
         RESULT_S32,
         RESULT_U16,
         RESULT_S16,
         RESULT_U8,
         RESULT_S8,
         RESULT_U64F,
         RESULT_S64F,
         RESULT_U32F,
         RESULT_S32F,
         RESULT_U16F,
         RESULT_S16F,
         RESULT_U8F,
         RESULT_S8F,
         RESULT_FLOAT,
         RESULT_EXPRESSION,
         RESULT_FLOAT_N,
         RESULT_FLOAT_S,
         RESULT_FLOAT_G,
         RESULT_F32N,
         RESULT_F32S,
         RESULT_F32G,
         RESULT_F64N,
         RESULT_F64S,
         RESULT_F64G

// Return-codes for EndProcess
constant EP_ACCEPTED       =  1
constant EP_ABORT          =  0
constant EP_ABORT_EDIT     = -1
constant EP_FUNCTION_LIST  = -2
constant EP_VARLIST        = -3
constant EP_CODELIST       = -4
constant EP_DEL_VAR        = -5
constant EP_DEL_ALL_VARS   = -6
constant EP_BASE_3_DOWN    = -7
constant EP_BASE_3_UP      = -8
constant EP_BASE_2_DOWN    = -9
constant EP_BASE_2_UP      = -10
constant EP_BASE_1_DOWN    = -11
constant EP_BASE_1_UP      = -12
constant EP_INSERT_MENU    = -13
constant EP_FPP_HELP       = -14
constant EP_FPP_HELP_TOC   = -15
constant EP_CONST_LIST     = -16
constant EP_FLOAT_FORMAT   = -17
constant EP_OPTION_MENU    = -18
constant EP_INTEGER_FORMAT = -19
constant EP_NO_ACTION      = -20

// Range of number bases
constant MIN_BASE =  2
constant MAX_BASE = 36

// Word-selector for FppGetWordFromInput
constant GET_WORD_FUNC  = 1,
         GET_WORD_VAR,
         GET_WORD_CONST,
         GET_WORD_HELP

// For FppPickColor()
constant COLOR_WIDTH = 2

constant PICK_COL_8_BIT = 0,
         PICK_COL_16_BIT,
         PICK_COL_32_BIT,
         PICK_COL_64_BIT,
         PICK_COL_NORM,
         PICK_COL_IEEE_SINGLE,
         PICK_COL_IEEE_DOUBLE,
         PICK_COL_FLOAT,
         PICK_COL_SIGN,
         PICK_COL_EXPONENT,
         PICK_COL_MANTISSA,
         PICK_COL_HELP_MARKER,
         PICK_COL_INPUT_LINE,
         PICK_COL_DEFAULT

#if PUBLIC_DEFAULT_COLORS
  // Default public color values, related to TSE standard default settings.
  // Caution:
  // Only the foreground part is used, the background is set automatically
  //               Example: Background-++-Foreground
  //                                   ||
  //                                 0x0B
  constant DEFAULT_COL_8BIT        = 0x04   // set foreground only!
  constant DEFAULT_COL_16BIT       = 0x0E   // set foreground only!
  constant DEFAULT_COL_32BIT       = 0x09   // set foreground only!
  constant DEFAULT_COL_64BIT       = 0x04   // set foreground only!
  constant DEFAULT_COL_NORMBASE    = 0x04   // set foreground only!
  constant DEFAULT_COL_IEEESINGLE  = 0x04   // set foreground only!
  constant DEFAULT_COL_IEEEDOUBLE  = 0x04   // set foreground only!
  constant DEFAULT_COL_FLOAT       = 0x0F   // set foreground only!
  constant DEFAULT_COL_SIGN        = 0x0B   // set foreground only!
  constant DEFAULT_COL_EXPONENT    = 0x09   // set foreground only!
  constant DEFAULT_COL_MANTISSA    = 0x0C   // set foreground only!

  constant DEFAULT_COL_HELP_MARKER = 0xB9   // set foreground *and* background
#else
  // Default private color values for use with a custom color palette!
  // Caution:
  // Values need to be adjusted according to the custom color palette.
  // Only the foreground part is used, the background is set automatically
  //               Example: Background-++-Foreground
  //                                   ||
  //                                 0x0B
  constant DEFAULT_COL_8BIT        = 0x0A   // set foreground only!
  constant DEFAULT_COL_16BIT       = 0x0E   // set foreground only!
  constant DEFAULT_COL_32BIT       = 0x0B   // set foreground only!
  constant DEFAULT_COL_64BIT       = 0x0C   // set foreground only!
  constant DEFAULT_COL_NORMBASE    = 0x0C   // set foreground only!
  constant DEFAULT_COL_IEEESINGLE  = 0x0A   // set foreground only!
  constant DEFAULT_COL_IEEEDOUBLE  = 0x0A   // set foreground only!
  constant DEFAULT_COL_FLOAT       = 0x0F   // set foreground only!
  constant DEFAULT_COL_SIGN        = 0x0B   // set foreground only!
  constant DEFAULT_COL_EXPONENT    = 0x07   // set foreground only!
  constant DEFAULT_COL_MANTISSA    = 0x0C   // set foreground only!

  constant DEFAULT_COL_HELP_MARKER = 0x8A   // set foreground *and* background
#endif

constant DEFAULT_COL_INPUT_LINE    = 0x1F   // set foreground *and* background

// X-Position for coloring in menu
constant XPOS_MENU_COLOR = 36

// Size of TOC-Marker
constant TOC_MARKER_SIZE = 5

// Size of version string
constant OS_VERSION_LENGTH = 30

// Selector how float-values are displayed
constant FLOAT_DISP_MIN = 0,
         FLOAT_NORMAL,
         FLOAT_SCIENTIFIC,
         FLOAT_GROUPED,
         FLOAT_DISP_MAX

// Selector where to insert data
constant INS_RES_CURSOR = 0,
         INS_RES_WCLIP,
         INS_RES_TSECLIP

// Possible result localizations
constant LOCALE_US = 1,         // -us
         LOCALE_NU,             // -nu
         LOCALE_SY              // -sy
// The sequence in this string must match the above constants
string gcLocaleSelector[] = "-us -nu -sy"

// Identifier for exe-version/-name x86 and x64 and macro
string gcExe_x64[]    = "FppCon_x64.exe" // 64-Bit OS
string gcExe_x86[]    = "FppCon_x86.exe" // 32-Bit OS

string gcExeName[16]  = ""               // min length is longest exe-name
string gcNeedExeVer[] = "2.4.3.26"       // min needed exe version

string gcDllName[]    = "BO_Helper.dll"  // name of helper dll
string gcNeedDllVer[] = "1.9.1.29"       // min needed dll version

string gcMacVersion[] = "1.1.32.100"

// Versiondata of exe and dll
string gcExeVersion[23] = ""
string gcDllVersion[23] = ""
string gcOsVersion[OS_VERSION_LENGTH] = ""

// Identifier to map, otherwise they would be removed
string gcQuote[]        = '"'
string gcQuoteReplace[] = Chr(255)

// Identifier used for TSE.INI
string gcTSE_INI_KEY[]      = "FppShell"
string gcLastExpression[]   = "LastExpression"
string gcBASE1_INI[]        = "B1"
string gcBASE2_INI[]        = "B2"
string gcBASE3_INI[]        = "B3"
string gcFLOAT_DISP[]       = "FDisp"
string gcOneColorXXX[]      = "ModeXXX"
string gcIntegerGrouped[]   = "IntGroup"
string gcCol8Bit[]          = "Col8Bit"
string gcCol16Bit[]         = "Col16Bit"
string gcCol32Bit[]         = "Col32Bit"
string gcCol64Bit[]         = "Col64Bit"
string gcColNormBase[]      = "ColNormBase"
string gcColIeeeSingle[]    = "ColIeeeSingle"
string gcColIeeeDouble[]    = "ColIeeeDouble"
string gcColFloat[]         = "ColFloat"
string gcColSign[]          = "ColSign"
string gcColExponent[]      = "ColExponent"
string gcColMantissa[]      = "ColMantissa"
string gcColInputLine[]     = "ColInputLine"
string gcInputLnSingleCol[] = "InputLnSingleCol"
string gcDigits[]           = "Digits"
string gcResLocalization[]  = "ResLocale"
string gcStartupCurPos[]    = "StartupCurPos"
string gcXOffset[]          = "XOffset"
string gcCursorPos[]        = "CursorPos"
string gcInsertResAt[]      = "InsertResAt"
string gcWsearchFuncList[]  = "WsFuncList"
string gcWsearchVarList[]   = "WsVarList"
string gcWsearchConList[]   = "WsConList"
string gcWsearchHelp[]      = "WsHelp"
string gcTocMarkerString[]  = "TocMarkerString"
string gcRESULT_FLOAT[]     = "QFN"
string gcRESULT_SFLOAT[]    = "QFS"
string gcRESULT_LFLOAT[]    = "QFL"
string gcRESULT_BASE1[]     = "R1"
string gcRESULT_BASE2[]     = "R2"
string gcRESULT_BASE3[]     = "R3"
string gcRESULT_F32[]       = "F32"
string gcRESULT_F64[]       = "F64"
string gcResult_F32Bin[]    = "F32BIN"
string gcResult_F64Bin[]    = "F64BIN"
string gcRESULT_F32D[]      = "F32D"
string gcRESULT_F64D[]      = "F64D"
string gcRESULT_F32S[]      = "F32S"
string gcRESULT_F64S[]      = "F64S"
string gcRESULT_F32L[]      = "F32L"
string gcRESULT_F64L[]      = "F64L"
string gcRESULT_U8_BIT[]    = "U8"
string gcRESULT_S8_BIT[]    = "S8"
string gcRESULT_U16_BIT[]   = "U16"
string gcRESULT_S16_BIT[]   = "S16"
string gcRESULT_U32BIT[]    = "U32"
string gcRESULT_S32BIT[]    = "S32"
string gcRESULT_U64BIT[]    = "U64"
string gcRESULT_S64BIT[]    = "S64"
string gcRESULT_U8_BITL[]   = "U8L"
string gcRESULT_S8_BITL[]   = "S8L"
string gcRESULT_U16_BITL[]  = "U16L"
string gcRESULT_S16_BITL[]  = "S16L"
string gcRESULT_U32BITL[]   = "U32L"
string gcRESULT_S32BITL[]   = "S32L"
string gcRESULT_U64BITL[]   = "U64L"
string gcRESULT_S64BITL[]   = "S64L"
string gcRESULT_U64HEX[]    = "U64HEX"
string gcRESULT_ERRORPOS[]  = "EPos"
string gcRESULT_ERRORTEXT[] = "EText"
string gcRESULT_MATHERROR[] = "MError"
string gcSTRIPLINE_3D[]     = "Stripline3D"
string gcTIME_TAKEN[]       = "TimeTaken"

string gcTSE_HELP_KEY[]     = "FppHelp"
string gcColHelpMarker[]    = "ColHelpMarker"

// Filenames used for data exchange with FppCon*.exe
string gcFileVarList[]    = "FppVar.txt"
string gcFileCodeList[]   = "FppCode.txt"
string gcFileFuncList[]   = "FppFunc.txt"
string gcFileResult[]     = "FppRes.txt"
string gcFileExpression[] = "FppExp.txt"
string gcFileConstList[]  = "FppConst.txt"

// Filename FppShell help
string gcFileHelp[]       = "FppHelp.txt"

// Filename used for redirection when in console mode only
string gcFileRedirect[]   = "FppRedir.txt"

// Used paths for EXE, DLL, MAC and TXT
string gcLoadDir[_MAXPATH_] = ""
string gcMacDir[_MAXPATH_]  = ""

// Constant Errormessages
string gcErrorOpenFile[]  = "Error open file: "
string gcErrorCloseFile[] = "Error close file: "
string gcErrorReadFile[]  = "Error read file: "
string gcErrorWriteFile[] = "Error write file: "

// Resultstrings, expressionstrings and errorstrings
string gcExpression[MAXSTRINGLEN]            = ""
string gcFloat[MAXSTRINGLEN]                 = ""
string gcSFloat[MAXSTRINGLEN]                = ""
string gcLFloat[MAXSTRINGLEN]                = ""
string gcResultBase1[BASE_FIELD_SIZE]        = ""
string gcResultBase2[BASE_FIELD_SIZE]        = ""
string gcResultBase3[BASE_FIELD_SIZE]        = ""
string gcF32[RESULT_F32_SIZE]                = ""
string gcF64[RESULT_F64_SIZE]                = ""
string gcF32Bin[RESULT_F32_BIN_SIZE]         = ""
string gcF64Bin[RESULT_F64_BIN_SIZE]         = ""
string gcF32D[RESULT_F32D_SIZE]              = ""
string gcF64D[RESULT_F64D_SIZE]              = ""
string gcF32S[RESULT_F32D_SIZE]              = ""
string gcF64S[RESULT_F64D_SIZE]              = ""
string gcF32L[RESULT_F32D_SIZE]              = ""
string gcF64L[RESULT_F64D_SIZE]              = ""
string gcU8[RESULT_8_SIZE]                   = ""
string gcS8[RESULT_8_SIZE]                   = ""
string gcU16[RESULT_16_SIZE]                 = ""
string gcS16[RESULT_16_SIZE]                 = ""
string gcU32[RESULT_32_SIZE]                 = ""
string gcS32[RESULT_32_SIZE]                 = ""
string gcU64[RESULT_64_SIZE]                 = ""
string gcS64[RESULT_64_SIZE]                 = ""
string gcU8L[RESULT_8_SIZE]                  = ""
string gcS8L[RESULT_8_SIZE]                  = ""
string gcU16L[RESULT_16_SIZE]                = ""
string gcS16L[RESULT_16_SIZE]                = ""
string gcU32L[RESULT_32_SIZE]                = ""
string gcS32L[RESULT_32_SIZE]                = ""
string gcU64L[RESULT_64_SIZE]                = ""
string gcS64L[RESULT_64_SIZE]                = ""
string gcU64Hex[RESULT_U64_HEX_SIZE]         = ""
string gcErrorText[MAXSTRINGLEN]             = ""
string gcMathError[MAXSTRINGLEN]             = ""
string gcDisplayFormat[]                     = "NSG"
string gcTimeTaken[WIN_WIDTH]                = ""
string gcTimeCompRun[RESULT_TIME_TAKEN_SIZE] = ""

// Insert and videostrings
string gcValToInsert[MAXSTRINGLEN]  = ""
string gcWord[MAXSTRINGLEN] = ""

// Position for marking
string gcTocLine[20] = ""

// Used marker for TOC
string gcTocMarker[TOC_MARKER_SIZE] = "#"

// Number of digits dependent from base
string gcBaseLen[] = "0 64 41 32 28 25 23 22 21 20 19 18 18 17 17 16 16 16 16 15 15 15 15 14 14 14 14 14 14 14 13 13 13 13 13 13 "
//  Base                2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36

// Defaults of global variables
integer gfExitMenu             = FALSE
integer gnFppHistory           = 0
integer gnInsertResAt          = INS_RES_CURSOR
integer gfOneColorXXX          = FALSE
integer gfIntegerGrouped       = TRUE
integer gfTerminated           = FALSE
integer gfWsFuncList           = TRUE
integer gfWsVarList            = TRUE
integer gfWsConList            = TRUE
integer gfWsHelp               = TRUE
integer gfInputLnSingleCol     = FALSE
integer gnFloatFormat          = FLOAT_GROUPED
integer gnDigits               = FLOAT_DECIMALS
integer gnResLocale            = LOCALE_US
integer gnBase1                = 2
integer gnBase2                = 8
integer gnBase3                = 16
integer gnCursorPos            = 1
integer gnXOffset              = 0
integer gnExitCode             = EP_NO_ACTION
integer gnErrorPos             = 0
integer gnCol8Bit              = 0
integer gnCol16Bit             = 0
integer gnCol32Bit             = 0
integer gnCol64Bit             = 0
integer gnColNormBase          = 0
integer gnColIeeeSingle        = 0
integer gnColIeeeDouble        = 0
integer gnColFloat             = 0
integer gnColSign              = 0
integer gnColExponent          = 0
integer gnColMantissa          = 0
integer gnColInputLine         = 0
integer gnColHelpMarker        = 0
integer gnFieldFlags           = 0
integer gfStartupCurPos        = FALSE
integer gnStriplineIn3D        = 0
integer gnCR_X                 = 0
integer gnAlt_F_X              = 0
integer gnAlt_V_X              = 0
integer gnAlt_T_X              = 0
integer gnAlt_L_X              = 0
integer gnAlt_P_X              = 0
integer gnAlt_S_X              = 0
integer gnAlt_O_X              = 0
integer gnAlt_I_X              = 0
integer gnF1_X                 = 0
integer gnPutColorToMenuValues = FALSE
integer gfRestoreCursor        = FALSE

// Handles used for redirection when in console mode only
integer gnHandStdOut = 0
integer gnHandErrOut = 0

// declaration of used procs etc.
forward proc Main()
forward proc WhenLoaded()
forward proc WhenPurged()
forward proc FppOnAbandonEditor()
forward proc FppStartColorMenuValues()
forward proc FppStopColorMenuValues()
forward proc FppBeforeGetkey()
forward menu FppOptionsMenu()
forward menu FppColorMenu()
forward menu FppInsertMenu()
forward menu FppInsertDestMenu()
forward menu FppFloatMenu()
forward menu FppIntMenu()
forward menu FppIntGroupedMenu()
forward menu FppIeeeMenu()
forward menu FppLocaleMenu()
forward KeyDef FppHelpKeys
forward KeyDef FppHelpTocKeys
forward KeyDef FppErrorKeys
forward KeyDef FppConstKeys
forward KeyDef FppFuncKeys
forward KeyDef FppVarKeys
forward KeyDef FppCodeListKeys
forward KeyDef FppKeys
forward proc FppDelToLeft()
forward proc FppHelp(string vcHelpSearch)
forward proc FppHiliteText()
forward proc FppDrawHelpLine(integer vfIsCursor)
forward proc FppHelpToc()
forward proc FppDrawTocLine(integer vfIsCursor)
forward proc FppInsertResult(integer nResultToInsert)
forward proc FppFuncList()
forward proc FppVarList()
forward proc FppCodeList()
forward proc FppConstList()
forward proc FppGetWordFromInput(integer vnSelector)
forward proc FppGetWord(string vcWordset)
forward proc FppTypeWord(integer vnTypeWord)
forward proc FppShowErrors(integer vnErrors)
forward proc FppKillResults()
forward proc FppImportResults()
forward proc FppBase(integer vnUp, integer vnBaseNum)
forward proc FppEnableConstKeys()
forward proc FppDisableConstKeys()
forward proc FppEnableErrorKeys()
forward proc FppDisableErrorKeys()
forward proc FppEnableHelpKeys()
forward proc FppDisableHelpKeys()
forward proc FppEnableTocKeys()
forward proc FppDisableTocKeys()
forward proc FppEnableFuncKeys()
forward proc FppDisableFuncKeys()
forward proc FppEnableVarKeys()
forward proc FppDisableVarKeys()
forward proc FppEnableCodeListKeys()
forward proc FppDisableCodeListKeys()
forward proc FppEnableKeys()
forward proc FppDisableKeys()
forward proc FppEditTocMarker()
forward proc FppSelectColorMenu()
forward string proc FppShowInsertDest()
forward proc FppChangeInsertDest(integer vnDestination)
forward proc FppToggleStripLineDrawMode()
forward proc FppToggleInputSingleCol()
forward proc FppToggleModeXXX()
forward proc FppToggleIntGroup()
forward proc FppToggleOldCurPos()
forward proc FppToggleWsFuncList()
forward proc FppToggleWsVarList()
forward proc FppToggleWsConList()
forward proc FppToggleWsHelp()
forward proc FppEnterDigits()
forward proc FppSwitchFloatFormat()
forward proc FppSelectLocalization()
forward string proc FppGetResLocalization()
forward proc FppSetLocale(integer vnLocale)
forward string proc FppLocalizeResult(integer vnLocaleCode, string vcResultToFormat)
forward integer proc FppGetLocaleData(integer vnLocaleCode, var string rcDecSep, var string rcThoSep, var string rcGrouping)
forward integer proc FppGetLocaleInfo(integer vnLocalType, integer vnInfoType, var string rcInformation)
forward proc FppPickColor(integer vnColorToChange, string vcHeadText)
forward proc FppColorBaseVal(integer vnX, integer vnY, integer vnBase)
forward proc FppColorBaseXXX()
forward proc FppColorValues()
forward integer proc FppOpenWindow(integer vnXl, integer vnYt, integer vnXr, integer vnYb)
forward proc FppDisplayInteger()
forward proc FppDisplayFloat()
forward proc FppDrawStripLines()
forward integer proc FppCheckAndSetMouseAction(integer vnButton, integer vnX, integer vnY)
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

  integer nCode       = 0
  integer nTempBuffer = 0
  integer nProcess    = 0
  integer nTickStart  = 0
  integer nTickStop   = 0
  integer nErrorWin   = FALSE
  integer nRetVal     = ERROR_NO_ERROR
  integer nxWin       = WhereXAbs()
  integer nyWin       = WhereYAbs()
  integer nTextAttr   = Query(MenuTextAttr)
  integer nLtrAttr    = Query(MenuTextLtrAttr)
  integer nGrayAttr   = Query(MenuGrayAttr)
  integer nBlockAttr  = Query(BlockAttr)
  integer nMsgAttr    = Query(MsgAttr)
  integer nOldBuffer  = GetBufferId()

  string  cVersionQuery[MAXSTRINGLEN] = ""

  // Resolve support files relative to this macro, not to g32.exe/e32.exe.
  gcMacDir  = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_)
  gcLoadDir = gcMacDir
  SetDllDirectory(gcLoadDir)

  // Determine if OS is 32 or 64 bit and select suitable exe
  if GetIsWow64()
    gcExeName = gcExe_x64     // 64-Bit OS
  else
    gcExeName = gcExe_x86     // 32-Bit OS
  endif

  // Always query EXE- and DLL-version, because they could have been changed
  gfTerminated = FALSE

  Message(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion)

  cVersionQuery = Str(VERSION_GT_EQ) + "|" + gcNeedExeVer + "|" + gcLoadDir + gcExeName
  ExecMacro('"' + gcMacDir + 'GetFileVersion.mac" ' + cVersionQuery)
  gcExeVersion = GetGlobalStr("FileVersionString")

  cVersionQuery = Str(VERSION_GT_EQ) + "|" + gcNeedDllVer + "|" + gcLoadDir + gcDllName
  ExecMacro('"' + gcMacDir + 'GetFileVersion.mac" ' + cVersionQuery)
  gcDllVersion = GetGlobalStr("FileVersionString")

  if gcExeVersion == "" or gcDllVersion == ""
    // Terminate because of previous message
    gfTerminated = TRUE
    PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
    UpdateDisplay(_STATUSLINE_REFRESH_)   // Restore statusline
    return()
  endif

  UpdateDisplay(_STATUSLINE_REFRESH_)     // Restore statusline

  // For info only
  if GetOsVersionString(gcOsVersion)
    // Remove brackets
    gcOsVersion = StrReplace("[\[\]]", gcOsVersion, "", "x")
  // Version couldn't be build ?!
  else
    gcOsVersion = "???"
  endif

  gnFppHistory = GetFreeHistory("FppShell:FppHistory")

  // Determine X-Position for PopUp
  if nxWin > WIN_WIDTH
    nxWin = nxWin - WIN_WIDTH
  else
    nxWin = nxWin + 1
  endif

  if nxWin + WIN_WIDTH > Query(ScreenCols)
    nxWin = Query(WindowCols) - WIN_WIDTH
  endif

  // Determine Y-Position for PopUp
  if nyWin > WIN_HEIGHT
    nyWin = nyWin - WIN_HEIGHT
  else
    nyWin = nyWin + 1
  endif

  if nyWin + WIN_HEIGHT > Query(ScreenRows)
    nyWin = Query(WindowRows) - WIN_HEIGHT
  endif

  // Don't overlap Menu- and/or Status-Line
  nyWin = max(iif(Query(StatusLineAtTop), 3, 2), nyWin)

  // Open window if possible
  if FppOpenWindow(nxWin, nyWin, nxWin + WIN_WIDTH, nyWin + WIN_HEIGHT - 1) == FALSE
    return()
  endif

  PushPosition()                  // Save cursor position
  PushBlock()                     // Save block marking

  // Restore old cursor position in input line at first startup if selected
  gfRestoreCursor = gfStartupCurPos

  // Mainloop
  loop
LBL_MAIN_LOOP_START:
    BufferVideo()

    // Integer values of the 3 number bases
    PutStrXY(WIN_BASE1_3_X + 2, WIN_BASE1,
             Format(gnbase1:3, ": ",
                    RightStr(gcResultBase1,
                    Val(GetToken(gcBaseLen, " ", gnBase1))):-BASE_FIELD_SIZE),
             nTextAttr
            )

    FppColorBaseVal(WIN_BASE1_3_X + 7, WIN_BASE1, gnBase1)

    PutStrXY(WIN_BASE1_3_X + 2, WIN_BASE2,
             Format(gnbase2:3, ": ",
                    RightStr(gcResultBase2,
                    Val(GetToken(gcBaseLen, " ", gnBase2))):-BASE_FIELD_SIZE),
             nTextAttr
            )

    FppColorBaseVal(WIN_BASE1_3_X + 7, WIN_BASE2, gnBase2)

    PutStrXY(WIN_BASE1_3_X + 2, WIN_BASE3,
             Format(gnbase3:3, ": ",
                    RightStr(gcResultBase3,
                             Val(GetToken(gcBaseLen, " ",
                                 gnBase3))):-BASE_FIELD_SIZE),
             nTextAttr
            )

    FppColorBaseVal(WIN_BASE1_3_X + 7, WIN_BASE3, gnBase3)

    // Display integer values
    FppDisplayInteger()

    // Display float values
    FppDisplayFloat()

    // Output displayformat float values
    PutStrXY(WIN_FORMAT_FLOAT_X, WIN_DECIMAL, gcDisplayFormat[gnFloatFormat], nLtrAttr)

    // Errormessage
    PutStrXY(1, WIN_ERROR,
             Format(gcErrorText:-WIN_WIDTH),
             iif(Length(gcErrorText), Color(Bright White on Red), nTextAttr)
            )

    // Matherror
    if Length(gcMathError)
      PutStrXY(1, WIN_MATHERROR,
               Format(gcMathError:-WIN_WIDTH),
               iif(Length(gcMathError), Color(Bright White on Red), nTextAttr)
              )

    // If no error, display last overall data
    else
      PutStrXY(1, WIN_MATHERROR,
               Format(iif(Length(gcErrorText) or Length(gcFloat) < 1, "",
               "Overall " + gcTimeTaken):-WIN_WIDTH),
               nGrayAttr
              )
    endif

    // Put color to the values
    FppColorValues()

    UnBufferVideo()

    // Enable special keys
    if (not Hook(_PROMPT_STARTUP_, FppEnableKeys)) or (not Hook(_PROMPT_CLEANUP_, FppDisableKeys))
      Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
           Chr(13) + Chr(13) +
           "Hook FppEnableKeys/FppDisableKeys could not be established!" + Chr(13) +
           "Keymappings will not work as expected."
          )
    endif

    // Set color for input line if selected
    if gfInputLnSingleCol
      Set(BlockAttr, gnColInputLine)
      Set(MsgAttr,   gnColInputLine)
    endif

    // Enter the expression
    GotoXY(1, WIN_EXPRESSION)
    nCode = Read(gcExpression, gnFppHistory)

    // Restore cursor position
    gfRestoreCursor = TRUE

    // Restore old input colors if selected
    if gfInputLnSingleCol
      Set(BlockAttr, nBlockAttr)
      Set(MsgAttr,   nMsgAttr)
    endif

    // Evaluate exit-code
    case nCode
    // Evaluate expression
    when EP_ACCEPTED
      nTickStart = GetSystemClockTicks()   // Starttime

      // Write expression to file, prepare transfer to FppCon*.exe
      nTempBuffer = CreateTempBuffer()
      SetUndoOff()
      AddLine(gcExpression)
      if SaveAs(gcMacDir + gcFileExpression, _OVERWRITE_) == 0
        MsgBox(SplitPath(CurrMacroFilename(), _NAME_) + " [" + gcMacVersion + "]",
               "Error writing file:" + Chr(13) +
               gcMacDir + gcFileExpression + Chr(13),
               _OK_
              )
        AbandonFile(nTempBuffer)
        GotoBufferId(nOldBuffer)
        goto LBL_MAIN_LOOP_START
      endif

      AbandonFile(nTempBuffer)
      GotoBufferId(nOldBuffer)

      // Only necessary when running in console-mode
      if not isGui()
        FppStartRedirect('"' + gcMacDir + gcFileRedirect + '"', gnHandStdOut, gnHandErrOut)
      endif

      // Delete Codelist
      EraseDiskFile(gcMacDir + gcFileCodeList)

      // Evaluate expression
      // Replacement for ldos()
      // ldos() doesn't return the needed 32 bit return value and can't handle the window
      // nProcess -> >0 = Process was started
      //              0 = Process couldn't get started
      //             <0 = OS-Errormessage
      nProcess = RunApplication('"' + gcLoadDir + gcExeName + '"',
                                "PA" +
                                ' "-e' + gcMacDir + gcFileExpression + '"' +
                                ' "-v' + gcMacDir + gcFileVarList    + '"' +
                                ' "-l' + gcMacDir + gcFileCodeList   + '"' +
                                ' "-r' + gcMacDir + gcFileResult     + '"' +
                                " -x" + Str(gnBase1)  +
                                " -y" + Str(gnBase2)  +
                                " -z" + Str(gnBase3)  +
                                " -d" + Str(gnDigits) +
                                " " + GetToken(gcLocaleSelector, " ", gnResLocale),
                                START_APP_GET_RETURN,
                                SW_HIDE, // SW_SHOWMINNOACTIVE
                                nRetVal
                               )
      // Only necessary when running in console-mode
      if not isGui()
        FppEndRedirect(gcMacDir + gcFileRedirect, gnHandStdOut, gnHandErrOut)
      endif

      // Everything was ok
      if nProcess > 0
        // Get results from file
        FppImportResults()

        // Detemine and store used time for later display
        nTickStop   = GetSystemClockTicks()
        gcTimeTaken = Str(nTickStop - nTickStart) +
        " msec. Parsing total "   +
        gcTimeTaken + " Calculation only " + gcTimeCompRun

        // Check only the highest possible error-code first
        if nRetVal == ERROR_IN_EXPRESSION
          gnCursorPos = gnErrorPos
          gnXOffset   = 0
          PushKey(<TAB>)

        // There might be more than one error to display
        elseif nRetVal <> ERROR_NO_ERROR
          FppShowErrors(nRetVal)

          if nRetVal & ERROR_IN_EXPRESSION
            gnCursorPos = gnErrorPos
            gnXOffset   = 0
            PushKey(<TAB>)
          endif
        endif

      // Display OS-Errorcode
      elseif nProcess < 0
        nProcess = -nProcess
        Warn("OS-Errorcode: " + Str(nProcess) + Chr(13)
             + "trying to run " + gcExeName + " command PARSE failed"
            )
        FppKillResults()

      // Program not found???
      else
        Warn(gcExeName + " command PARSE could not be executed")
        FppKillResults()
      endif

    // Select function from list to insert in expression
    when EP_FUNCTION_LIST
      FppFuncList()

    // Select variable from list to insert in expression or delete variables
    when EP_VARLIST
      FppVarList()

    // Display code-list of the last evaluated expression
    when EP_CODELIST
      FppCodeList()

    // Select constant from list to insert in expression
    when EP_CONST_LIST
      FppConstList()

    // Appropiate base up/down
    when EP_BASE_1_UP
      FppBase(BASE_UP, BASE_1)

    when EP_BASE_1_DOWN
      FppBase(BASE_DOWN, BASE_1)

    when EP_BASE_2_UP
      FppBase(BASE_UP, BASE_2)

    when EP_BASE_2_DOWN
      FppBase(BASE_DOWN, BASE_2)

    when EP_BASE_3_UP
      FppBase(BASE_UP, BASE_3)

    when EP_BASE_3_DOWN
      FppBase(BASE_DOWN, BASE_3)

    // Insert result into text, only if there is no error
    when EP_INSERT_MENU
      if BrowseMode() and gnInsertResAt == INS_RES_CURSOR
        if MsgBox(SplitPath(CurrMacroFilename(), _NAME_) + " [" + gcMacVersion + "]",
                  "Browse-Mode is activ!" + Chr(13) + Chr(13) +
                  "Data can be inserted into Clipboard only." + Chr(13) + Chr(13) +
                  "Do you want to continue?",
                  _YES_NO_
                 ) == 1                 // 1 = OK (Yes)
          goto CONTINUE_INSERT
        endif

      // The regular case
      else
CONTINUE_INSERT:
        gcValToInsert = ""
        gfExitMenu    = FALSE           // To stay in loop
        BufferVideo()

        // Loop because you can change the destination
        repeat
          gnFieldFlags  = iif((gnErrorPos or BrowseMode()) and gnInsertResAt == INS_RES_CURSOR, _MF_GRAYED_, _MF_ENABLED_)
        until FppInsertMenu() == 0 or gfExitMenu == TRUE

        UnBufferVideo()

        // Selection has been made
        if gcValToInsert <> ""

          // Insert data at Cursorposition
          if gnInsertResAt == INS_RES_CURSOR
            // To insert text all popups have to be closed before,
            // it will cause some flickering.
            PopWinClose()
            GotoBufferId(nOldBuffer)
            PushPosition()              // Save cursor position
            PushBlock()                 // Save block marking
            InsertText(gcValToInsert, _INSERT_)
            PopBlock()                  // Restore block marking
            PopPosition()               // Restore cursor position
            UpdateDisplay(_CLINE_REFRESH_)

            // Reopen window if possible
            if FppOpenWindow(nxWin, nyWin, nxWin + WIN_WIDTH, nyWin + WIN_HEIGHT - 1) == FALSE
              nErrorWin = TRUE
              break
            endif

          // Insert data into Windows clipboard
          elseif gnInsertResAt == INS_RES_WCLIP
            CopyToWinClip(gcValToInsert)

          // Insert data into TSE clipboard
          elseif gnInsertResAt == INS_RES_TSECLIP
            CopyToClipboard(gcValToInsert)
          endif
        endif
      endif

    // Switch display of float values
    when EP_FLOAT_FORMAT
      FppSwitchFloatFormat()

    // Switch display of integer values
    when EP_INTEGER_FORMAT
      FppToggleIntGroup()

    // Select colors and more
    when EP_OPTION_MENU
      BufferVideo()

      while FppOptionsMenu()
        FppDisplayInteger()
        FppDisplayFloat()
        FppColorValues()
        // Output displayformat float values
        PutStrXY(WIN_FORMAT_FLOAT_X, WIN_DECIMAL, gcDisplayFormat[gnFloatFormat], nLtrAttr)
        FppDrawStripLines()
      endwhile

      UnBufferVideo()

    // Display help
    when EP_FPP_HELP
      FppHelp(iif(gfWsHelp and gcWord <> "", "", "FppShell Help"))

    // Quit
    when EP_ABORT_EDIT
      break
    endcase
  endloop

  // Restore old settings
  PopBlock()                // Restore block marking
  PopPosition()             // Restore cursor position

  // Only if there was no error close the window
  if nErrorWin == FALSE
    PopWinClose()
  endif

  UpdateDisplay(_STATUS_LINE_REFRESH_)

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
  integer nTextAttr = Query(MenuTextAttr)

  string  cBuffer[MAXSTRINGLEN] = ""

  // Initialize hooks
  Hook(_ON_ABANDON_EDITOR_, FppOnAbandonEditor)

  // Numeric data
  gnBase1            = GetProfileInt(gcTSE_INI_KEY, gcBASE1_INI,        2)
  gnBase2            = GetProfileInt(gcTSE_INI_KEY, gcBASE2_INI,        8)
  gnBase3            = GetProfileInt(gcTSE_INI_KEY, gcBASE3_INI,        16)
  gnErrorPos         = GetProfileInt(gcTSE_INI_KEY, gcRESULT_ERRORPOS,  0)

  nTextAttr          = nTextAttr & 0xF0
  gnCol8Bit          = GetProfileInt(gcTSE_INI_KEY, gcCol8Bit,          nTextAttr | DEFAULT_COL_8BIT)
  gnCol16Bit         = GetProfileInt(gcTSE_INI_KEY, gcCol16Bit,         nTextAttr | DEFAULT_COL_16BIT)
  gnCol32Bit         = GetProfileInt(gcTSE_INI_KEY, gcCol32Bit,         nTextAttr | DEFAULT_COL_32BIT)
  gnCol64Bit         = GetProfileInt(gcTSE_INI_KEY, gcCol64Bit,         nTextAttr | DEFAULT_COL_64BIT)
  gnColNormBase      = GetProfileInt(gcTSE_INI_KEY, gcColNormBase,      nTextAttr | DEFAULT_COL_NORMBASE)
  gnColIeeeSingle    = GetProfileInt(gcTSE_INI_KEY, gcColIeeeSingle,    nTextAttr | DEFAULT_COL_IEEESINGLE)
  gnColIeeeDouble    = GetProfileInt(gcTSE_INI_KEY, gcColIeeeDouble,    nTextAttr | DEFAULT_COL_IEEEDOUBLE)
  gnColFloat         = GetProfileInt(gcTSE_INI_KEY, gcColFloat,         nTextAttr | DEFAULT_COL_FLOAT)
  gnColSign          = GetProfileInt(gcTSE_INI_KEY, gcColSign,          nTextAttr | DEFAULT_COL_SIGN)
  gnColExponent      = GetProfileInt(gcTSE_INI_KEY, gcColExponent,      nTextAttr | DEFAULT_COL_EXPONENT)
  gnColMantissa      = GetProfileInt(gcTSE_INI_KEY, gcColMantissa,      nTextAttr | DEFAULT_COL_MANTISSA)
  gnColInputLine     = GetProfileInt(gcTSE_INI_KEY, gcColInputLine,     DEFAULT_COL_INPUT_LINE)
  gnFloatFormat      = GetProfileInt(gcTSE_INI_KEY, gcFLOAT_DISP,       FLOAT_GROUPED)
  gnDigits           = GetProfileInt(gcTSE_INI_KEY, gcDigits,           FLOAT_DECIMALS)
  gnResLocale        = GetProfileInt(gcTSE_INI_KEY, gcResLocalization,  LOCALE_US)
  gnXOffset          = GetProfileInt(gcTSE_INI_KEY, gcXOffset,          0)
  gnCursorPos        = GetProfileInt(gcTSE_INI_KEY, gcCursorPos,        1)
  gnInsertResAt      = GetProfileInt(gcTSE_INI_KEY, gcInsertResAt,      INS_RES_CURSOR)
  gfOneColorXXX      = GetProfileInt(gcTSE_INI_KEY, gcOneColorXXX,      FALSE)
  gfIntegerGrouped   = GetProfileInt(gcTSE_INI_KEY, gcIntegerGrouped,   TRUE)
  gfStartupCurPos    = GetProfileInt(gcTSE_INI_KEY, gcStartupCurPos,    FALSE)
  gfWsFuncList       = GetProfileInt(gcTSE_INI_KEY, gcWsearchFuncList,  TRUE)
  gfWsVarList        = GetProfileInt(gcTSE_INI_KEY, gcWsearchVarList,   TRUE)
  gfWsConList        = GetProfileInt(gcTSE_INI_KEY, gcWsearchConList,   TRUE)
  gfWsHelp           = GetProfileInt(gcTSE_INI_KEY, gcWsearchHelp,      TRUE)
  gfInputLnSingleCol = GetProfileInt(gcTSE_INI_KEY, gcInputLnSingleCol, FALSE)
  gnStriplineIn3D    = GetProfileInt(gcTSE_INI_KEY, gcSTRIPLINE_3D,     0)

  // String data
  cBuffer            = GetProfileStr(gcTSE_INI_KEY, gcTocMarkerString, "23") // Hex of #
  gcTocMarker        = ""

  // Convert Hex-values to string
  for nCount = 1 to TOC_MARKER_SIZE
    nChar = Val(GetToken(cBuffer, ";", nCount), 16)
    if (nChar in 1 .. 255)
      gcTocMarker = gcTocMarker + Chr(nChar)
    endif
  endfor

  // Special handling of expression string. When loading eventually present ""
  // will be removed what would lead to a false display of the expression.
  // To prevent this the " are replaced with Chr(255) when stored. This will be
  // reverted here.
  cBuffer            = GetProfileStr(gcTSE_INI_KEY, gcLastExpression,   "")
  gcExpression       = StrReplace(gcQuoteReplace, cBuffer, gcQuote)

  gcResultBase1      = GetProfileStr(gcTSE_INI_KEY, gcRESULT_BASE1,     "")
  gcResultBase2      = GetProfileStr(gcTSE_INI_KEY, gcRESULT_BASE2,     "")
  gcResultBase3      = GetProfileStr(gcTSE_INI_KEY, gcRESULT_BASE3,     "")
  gcFloat            = GetProfileStr(gcTSE_INI_KEY, gcRESULT_FLOAT,     "")
  gcSFloat           = GetProfileStr(gcTSE_INI_KEY, gcRESULT_SFLOAT,    "")
  gcLFloat           = GetProfileStr(gcTSE_INI_KEY, gcRESULT_LFLOAT,    "")
  gcF32              = GetProfileStr(gcTSE_INI_KEY, gcRESULT_F32,       "")
  gcF64              = GetProfileStr(gcTSE_INI_KEY, gcRESULT_F64,       "")
  gcF32Bin           = GetProfileStr(gcTSE_INI_KEY, gcRESULT_F32Bin,    "")
  gcF64Bin           = GetProfileStr(gcTSE_INI_KEY, gcRESULT_F64Bin,    "")
  gcF32D             = GetProfileStr(gcTSE_INI_KEY, gcRESULT_F32D,      "")
  gcF64D             = GetProfileStr(gcTSE_INI_KEY, gcRESULT_F64D,      "")
  gcF32S             = GetProfileStr(gcTSE_INI_KEY, gcRESULT_F32S,      "")
  gcF64S             = GetProfileStr(gcTSE_INI_KEY, gcRESULT_F64S,      "")
  gcF32L             = GetProfileStr(gcTSE_INI_KEY, gcRESULT_F32L,      "")
  gcF64L             = GetProfileStr(gcTSE_INI_KEY, gcRESULT_F64L,      "")
  gcU8               = GetProfileStr(gcTSE_INI_KEY, gcRESULT_U8_BIT,    "")
  gcS8               = GetProfileStr(gcTSE_INI_KEY, gcRESULT_S8_BIT,    "")
  gcU16              = GetProfileStr(gcTSE_INI_KEY, gcRESULT_U16_BIT,   "")
  gcS16              = GetProfileStr(gcTSE_INI_KEY, gcRESULT_S16_BIT,   "")
  gcU32              = GetProfileStr(gcTSE_INI_KEY, gcRESULT_U32BIT,    "")
  gcS32              = GetProfileStr(gcTSE_INI_KEY, gcRESULT_S32BIT,    "")
  gcU64              = GetProfileStr(gcTSE_INI_KEY, gcRESULT_U64BIT,    "")
  gcS64              = GetProfileStr(gcTSE_INI_KEY, gcRESULT_S64BIT,    "")
  gcU8L              = GetProfileStr(gcTSE_INI_KEY, gcRESULT_U8_BITL,   "")
  gcS8L              = GetProfileStr(gcTSE_INI_KEY, gcRESULT_S8_BITL,   "")
  gcU16L             = GetProfileStr(gcTSE_INI_KEY, gcRESULT_U16_BITL,  "")
  gcS16L             = GetProfileStr(gcTSE_INI_KEY, gcRESULT_S16_BITL,  "")
  gcU32L             = GetProfileStr(gcTSE_INI_KEY, gcRESULT_U32BITL,   "")
  gcS32L             = GetProfileStr(gcTSE_INI_KEY, gcRESULT_S32BITL,   "")
  gcU64L             = GetProfileStr(gcTSE_INI_KEY, gcRESULT_U64BITL,   "")
  gcS64L             = GetProfileStr(gcTSE_INI_KEY, gcRESULT_S64BITL,   "")
  gcU64Hex           = GetProfileStr(gcTSE_INI_KEY, gcRESULT_U64HEX,    "")
  gcErrorText        = GetProfileStr(gcTSE_INI_KEY, gcRESULT_ERRORTEXT, "")
  gcMathError        = GetProfileStr(gcTSE_INI_KEY, gcRESULT_MATHERROR, "")
  gcTimeTaken        = GetProfileStr(gcTSE_INI_KEY, gcTIME_TAKEN,       "")

  // For safety reasons only
  if gnFloatFormat <= FLOAT_DISP_MIN or gnFloatFormat >= FLOAT_DISP_MAX
    gnFloatFormat = FLOAT_GROUPED
  endif

  // Loaded from a different section
  gnColHelpMarker = GetProfileInt(gcTSE_HELP_KEY, gcColHelpMarker, DEFAULT_COL_HELP_MARKER)

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

  string  cBuffer[MAXSTRINGLEN] = ""

  UnHook(FppOnAbandonEditor)

  // Normal Terrmination, no forced termination due to wrong version check at startup
  if gfTerminated == FALSE
    // There seems to be a problem when writing div. strings to TSE.ini, it will
    // uncontrolled arbitrarily grow. To prevent this the entire section is
    // erased before writing the settings. This way it works as expected.
    RemoveProfileSection(gcTSE_INI_KEY)

    // Numerical data
    WriteProfileInt(gcTSE_INI_KEY, gcBASE1_INI,        gnBase1)
    WriteProfileInt(gcTSE_INI_KEY, gcBASE2_INI,        gnBase2)
    WriteProfileInt(gcTSE_INI_KEY, gcBASE3_INI,        gnBase3)
    WriteProfileInt(gcTSE_INI_KEY, gcRESULT_ERRORPOS,  gnErrorPos)
    WriteProfileInt(gcTSE_INI_KEY, gcCol8Bit,          gnCol8Bit)
    WriteProfileInt(gcTSE_INI_KEY, gcCol16Bit,         gnCol16Bit)
    WriteProfileInt(gcTSE_INI_KEY, gcCol32Bit,         gnCol32Bit)
    WriteProfileInt(gcTSE_INI_KEY, gcCol64Bit,         gnCol64Bit)
    WriteProfileInt(gcTSE_INI_KEY, gcColNormBase,      gnColNormBase)
    WriteProfileInt(gcTSE_INI_KEY, gcColIeeeSingle,    gnColIeeeSingle)
    WriteProfileInt(gcTSE_INI_KEY, gcColIeeeDouble,    gnColIeeeDouble)
    WriteProfileInt(gcTSE_INI_KEY, gcColFloat,         gnColFloat)
    WriteProfileInt(gcTSE_INI_KEY, gcColSign,          gnColSign)
    WriteProfileInt(gcTSE_INI_KEY, gcColExponent,      gnColExponent)
    WriteProfileInt(gcTSE_INI_KEY, gcColMantissa,      gnColMantissa)
    WriteProfileInt(gcTSE_INI_KEY, gcColInputLine,     gnColInputLine)
    WriteProfileInt(gcTSE_INI_KEY, gcXOffset,          gnXOffset)
    WriteProfileInt(gcTSE_INI_KEY, gcCursorPos,        gnCursorPos)
    WriteProfileInt(gcTSE_INI_KEY, gcInsertResAt,      gnInsertResAt)
    WriteProfileInt(gcTSE_INI_KEY, gcStartupCurPos,    gfStartupCurPos)
    WriteProfileInt(gcTSE_INI_KEY, gcWsearchFuncList,  gfWsFuncList)
    WriteProfileInt(gcTSE_INI_KEY, gcWsearchVarList,   gfWsVarList)
    WriteProfileInt(gcTSE_INI_KEY, gcWsearchConList,   gfWsConList)
    WriteProfileInt(gcTSE_INI_KEY, gcWsearchHelp,      gfWsHelp)
    WriteProfileInt(gcTSE_INI_KEY, gcFLOAT_DISP,       gnFloatFormat)
    WriteProfileInt(gcTSE_INI_KEY, gcDigits,           gnDigits)
    WriteProfileInt(gcTSE_INI_KEY, gcResLocalization,  gnResLocale)
    WriteProfileInt(gcTSE_INI_KEY, gcOneColorXXX,      gfOneColorXXX)
    WriteProfileInt(gcTSE_INI_KEY, gcIntegerGrouped,   gfIntegerGrouped)
    WriteProfileInt(gcTSE_INI_KEY, gcInputLnSingleCol, gfInputLnSingleCol)
    WriteProfileInt(gcTSE_INI_KEY, gcSTRIPLINE_3D,     gnStriplineIn3D)

    // String data
    // Convert char to Hex-value string
    cBuffer = ""
    for nCount = 1 to Length(gcTocMarker)
      cBuffer = cBuffer + Upper(Format(Asc(gcTocMarker[nCount]):2:"0":16, ";"))
    endfor
    WriteProfileStr(gcTSE_INI_KEY, gcTocMarkerString, cBuffer)

    // Special handling of expression string. When loading eventually present ""
    // will be removed what would lead to a false display of the expression.
    // To prevent this the " are replaced with Chr(255) when stored.
    cBuffer = StrReplace(gcQuote, gcExpression, gcQuoteReplace)
    WriteProfileStr(gcTSE_INI_KEY, gcLastExpression,   cBuffer)

    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_BASE1,     gcResultBase1)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_BASE2,     gcResultBase2)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_BASE3,     gcResultBase3)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_FLOAT,     gcFloat)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_SFLOAT,    gcSFloat)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_LFLOAT,    gcLFloat)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_F32,       gcF32)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_F64,       gcF64)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_F32Bin,    gcF32Bin)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_F64Bin,    gcF64Bin)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_F32D,      gcF32D)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_F64D,      gcF64D)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_F32S,      gcF32S)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_F64S,      gcF64S)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_F32L,      gcF32L)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_F64L,      gcF64L)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_U8_BIT,    gcU8)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_S8_BIT,    gcS8)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_U16_BIT,   gcU16)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_S16_BIT,   gcS16)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_U32BIT,    gcU32)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_S32BIT,    gcS32)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_U64BIT,    gcU64)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_S64BIT,    gcS64)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_U8_BITL,   gcU8L)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_S8_BITL,   gcS8L)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_U16_BITL,  gcU16L)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_S16_BITL,  gcS16L)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_U32BITL,   gcU32L)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_S32BITL,   gcS32L)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_U64BITL,   gcU64L)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_S64BITL,   gcS64L)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_U64HEX,    gcU64Hex)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_ERRORTEXT, gcErrorText)
    WriteProfileStr(gcTSE_INI_KEY, gcRESULT_MATHERROR, gcMathError)
    WriteProfileStr(gcTSE_INI_KEY, gcTIME_TAKEN,       gcTimeTaken)

    // Saved to a different section
    RemoveProfileSection(gcTSE_HELP_KEY)
    WriteProfileInt(gcTSE_HELP_KEY, gcColHelpMarker, gnColHelpMarker)
  endif

end

///*****************************************************************************
///
/// FppStartColorMenuValues
///
/// Helper to activate coloring in menu
///
///*****************************************************************************
proc FppStartColorMenuValues()

  gnPutColorToMenuValues = TRUE

end

///*****************************************************************************
///
/// FppStopColorMenuValues
///
/// Helper to deactivate coloring in menu
///
///*****************************************************************************
proc FppStopColorMenuValues()

  gnPutColorToMenuValues = FALSE

end

///*****************************************************************************
///
/// FppBeforeGetkey
///
/// Helper to dispay colors in menu
///
///*****************************************************************************
proc FppBeforeGetkey()

  if gnPutColorToMenuValues
    BufferVideo()
    PutAttrXY(XPOS_MENU_COLOR,  1, gnCol8Bit, 2)        // A - 8 Bit Color
    PutAttrXY(XPOS_MENU_COLOR,  2, gnCol16Bit, 2)       // B - 16 Bit Color
    PutAttrXY(XPOS_MENU_COLOR,  3, gnCol32Bit, 2)       // C - 32 Bit Color
    PutAttrXY(XPOS_MENU_COLOR,  4, gnCol64Bit, 2)       // D - 64 Bit Color
    PutAttrXY(XPOS_MENU_COLOR,  5, gnColNormBase, 2)    // E - Normal Base Color
    PutAttrXY(XPOS_MENU_COLOR,  6, gnColIeeeSingle, 2)  // F - IEEE Single Color
    PutAttrXY(XPOS_MENU_COLOR,  7, gnColIeeeDouble, 2)  // G - IEEE Double Color
    PutAttrXY(XPOS_MENU_COLOR,  8, gnColFloat, 2)       // H - Float Result Color
    PutAttrXY(XPOS_MENU_COLOR,  9, gnColSign, 2)        // I - Sign Bit Color
    PutAttrXY(XPOS_MENU_COLOR, 10, gnColExponent, 2)    // J - Exponent Bits Color
    PutAttrXY(XPOS_MENU_COLOR, 11, gnColMantissa, 2)    // K - Mantissa Bits Color
    PutAttrXY(XPOS_MENU_COLOR, 12, gnColHelpMarker, 2)  // L - Help Marker Color

    if gfInputLnSingleCol
      PutAttrXY(XPOS_MENU_COLOR, 13, gnColInputLine, 2) // M - Input-Line Color
    endif
    UnBufferVideo()
  endif

end

///*****************************************************************************
///
/// FppOptionsMenu
///
/// Called when pressing <Alt O>
///
///*****************************************************************************
menu FppOptionsMenu()

  title = "Options"
  history

  "&A - Set Colors...",
  FppSelectColorMenu(),
  _MF_CLOSE_BEFORE_,
  "Lets you select the colors"

  "Number Display",, _MF_DIVIDE_

  "&B - Float Format"[gcDisplayFormat[gnFloatFormat]:1],
  FppSwitchFloatFormat(),
  _MF_CLOSE_AFTER_,
  "(N)ormal = 12345.67 (S)cientific = 1.234567E+4 (G)rouped = 12,345.67"

  "&C - Integer Grouped" [iif(gfIntegerGrouped, "Yes", " No"):3],
  FppToggleIntGroup(),
  _MF_CLOSE_AFTER_,
  "Display integers grouped (12,345,678) or not (12345678)"

  "&D - Digits for Result Display"[gnDigits:2],
  FppEnterDigits(),
  _MF_DONT_CLOSE_,
  "Applies to Results only. Range 0-99, default=50, active with next evaluation"

  "&E - Result Localization..."[FppGetResLocalization():12],
  FppSelectLocalization(),
  _MF_CLOSE_AFTER_,
  "Result-display only, no localized input! Uses locale decimal & thousands separators and grouping"

  "Speedsearch Word at Cursor in",, _MF_DIVIDE_

  "&F - Functions List" [iif(gfWsFuncList, "Yes", " No"):3],
  FppToggleWsFuncList(),
  _MF_DONT_CLOSE_,
  "Enable automatic Speedsearch when opening Functions-List from Main-Dialog"

  "&G - Variables List" [iif(gfWsVarList, "Yes", " No"):3],
  FppToggleWsVarList(),
  _MF_DONT_CLOSE_,
  "Enable automatic Speedsearch when opening Variables-List from Main-Dialog"

  "&H - Constants List" [iif(gfWsConList, "Yes", " No"):3],
  FppToggleWsConList(),
  _MF_DONT_CLOSE_,
  "Enable automatic Speedsearch when opening Constants-List from Main-Dialog"

  "&I - Help-File" [iif(gfWsHelp, "Yes", " No"):3],
  FppToggleWsHelp(),
  _MF_DONT_CLOSE_,
  "Enable automatic Speedsearch when opening Help-File from Main-Dialog"

  "Cursor repositioning",, _MF_DIVIDE_

  "&J - Old Cursor Pos. on Startup" [iif(gfStartupCurPos, "Yes", " No"):3],
  FppToggleOldCurPos(),
  _MF_DONT_CLOSE_,
  "Sets old cursor pos. in expression when makro is activated (no auto clear line)"

  "",, _MF_DIVIDE_

  "&K - 3D Striplines" [iif(gnStriplineIn3D, "Yes", "No"):3],
  FppToggleStripLineDrawMode(),
  iif(isGui(), _MF_CLOSE_AFTER_ | _MF_ENABLED_, _MF_GRAYED_),
  "How striplines are displayed, No = Normal, Yes = 3D, works with TSE-GUI only"

  "",, _MF_DIVIDE_

  "&L - TOC-Marker Sign"[gcTocMarker:TOC_MARKER_SIZE],
  FppEditTocMarker(),
  _MF_DONT_CLOSE_,
  "Lets you change the current used TOC-Marker sign. Default: #"

  "",, _MF_DIVIDE_

  "&M - About",
  FppAbout(),
  _MF_DONT_CLOSE_,
  "Shows version info about the macro, used Exe, Dll and OS"

end

///*****************************************************************************
///
/// FppColorMenu
///
/// Called from FppOptionsMenu
///
///*****************************************************************************
menu FppColorMenu()

  title = "Set Colors"
  history

  "&A - 8 Bit Color..." [Format(gnCol8Bit:2:"0":16):2],
  FppPickColor(PICK_COL_8_BIT, "8 Bit Color"),
  _MF_CLOSE_AFTER_,
  "Valid for base=2 or base=16 at top 3 lines"

  "&B - 16 Bit Color..." [Format(gnCol16Bit:2:"0":16):2],
  FppPickColor(PICK_COL_16_BIT, "16 Bit Color"),
  _MF_CLOSE_AFTER_,
  "Valid for base=2 or base=16 at top 3 lines"

  "&C - 32 Bit Color..." [Format(gnCol32Bit:2:"0":16):2],
  FppPickColor(PICK_COL_32_BIT, "32 Bit Color"),
  _MF_CLOSE_AFTER_,
  "Valid for base=2 or base=16 at top 3 lines"

  "&D - 64 Bit Color..." [Format(gnCol64Bit:2:"0":16):2],
  FppPickColor(PICK_COL_64_BIT, "64 Bit Color"),
  _MF_CLOSE_AFTER_,
  "Valid for base=2 or base=16 at top 3 lines"

  "&E - Normal Base Color..." [Format(gnColNormBase:2:"0":16):2],
  FppPickColor(PICK_COL_NORM, "Normal Base Color"),
  _MF_CLOSE_AFTER_,
  "Valid for bases only that are not 2 and not 16 at top 3 lines"

  "&F - IEEE Single Color..." [Format(gnColIeeeSingle:2:"0":16):2],
  FppPickColor(PICK_COL_IEEE_SINGLE, "IEEE Single Color"),
  _MF_CLOSE_AFTER_,
  "Applies to hex and decimal"

  "&G - IEEE Double Color..." [Format(gnColIeeeDouble:2:"0":16):2],
  FppPickColor(PICK_COL_IEEE_DOUBLE, "IEEE Double Color"),
  _MF_CLOSE_AFTER_,
  "Applies to hex and decimal"

  "&H - Float Result Color..." [Format(gnColFloat:2:"0":16):2],
  FppPickColor(PICK_COL_FLOAT, "Float Result Color"),
  _MF_CLOSE_AFTER_,
  "Applies to result only"

  "&I - Sign Bit Color..." [Format(gnColSign:2:"0":16):2],
  FppPickColor(PICK_COL_SIGN, "Sign Bit Color"),
  _MF_CLOSE_AFTER_,
  "Applies to IEEE bin sign bit only"

  "&J - Exponent Bits Color..." [Format(gnColExponent:2:"0":16):2],
  FppPickColor(PICK_COL_EXPONENT, "Exponent Bits Color"),
  _MF_CLOSE_AFTER_,
  "Applies to IEEE bin exponent bits only"

  "&K - Mantissa Bits Color..." [Format(gnColMantissa:2:"0":16):2],
  FppPickColor(PICK_COL_MANTISSA, "Mantissa Bits Color"),
  _MF_CLOSE_AFTER_,
  "Applies to IEEE bin mantissa bits only"

  "&L - TOC-Marker Color..." [Format(gnColHelpMarker:2:"0":16):2],
  FppPickColor(PICK_COL_HELP_MARKER, "TOC Marker Line Color"),
  _MF_CLOSE_AFTER_,
  "Applies to Help, TOC Marker Line only"

  "&M - Input-Line Color..." [Format(gnColInputLine:2:"0":16):2],
  FppPickColor(PICK_COL_INPUT_LINE, "Input-Line Color"),
  iif(gfInputLnSingleCol, _MF_CLOSE_AFTER_ | _MF_ENABLED_, _MF_GRAYED_),
  "Applies to input-line only. Active only when Input-Line Single Color=Yes"

  "",, _MF_DIVIDE_

  "&N - Use Input-Line Single Color" [iif(gfInputLnSingleCol, "Yes", "No"):3],
  FppToggleInputSingleCol(),
  _MF_CLOSE_AFTER_,
  "Only selected color will be used, not changing when pressing keys"

  "&O - Use one Color for Bitx...x" [iif(gfOneColorXXX, "Yes", " No"):3],
  FppToggleModeXXX(),
  _MF_CLOSE_AFTER_,
  "No = Segmented coloring, Yes = Single coloring of x...x in 'Values:' and 'Hex:' line"

  "",, _MF_DIVIDE_

  "&P - Reset to FPPShell Default Colors",
  FppPickColor(PICK_COL_DEFAULT, ""),
  _MF_CLOSE_BEFORE_,
  "Resets all FPPShell colors to default values"

end

///*****************************************************************************
///
/// FppInsertMenu
///
/// Called when pressing <Alt P>
///
///*****************************************************************************
menu FppInsertMenu()

  title = "Paste Data"
  history

  "&A - To:"[FppShowInsertDest():17],
  FppInsertDestMenu(),
  _MF_DONT_CLOSE_

  "Select Result",, _MF_DIVIDE_

  "&B - Result",
  FppInsertResult(RESULT_FLOAT),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&C - Base1 Value",
  FppInsertResult(RESULT_BASE_1),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&D - Base2 Value",
  FppInsertResult(RESULT_BASE_2),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&E - Base3 Value",
  FppInsertResult(RESULT_BASE_3),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "",, _MF_DIVIDE_

  "&F - Float Value...",
  FppFloatMenu(),
  _MF_DONT_CLOSE_ | gnFieldFlags

  "&G - Integer Value...",
  FppIntMenu(),
  _MF_DONT_CLOSE_ | gnFieldFlags

  "&H - Integer Grouped...",
  FppIntGroupedMenu(),
  _MF_DONT_CLOSE_ | gnFieldFlags

  "&I - IEEE Hex-Bin...",
  FppIeeeMenu(),
  _MF_DONT_CLOSE_ | gnFieldFlags

  "",, _MF_DIVIDE_

  "&J - Expression",
  FppInsertResult(RESULT_EXPRESSION),
  _MF_CLOSE_ALL_BEFORE_ | iif(BrowseMode() and gnInsertResAt == INS_RES_CURSOR, _MF_GRAYED_, _MF_ENABLED_)

end

///*****************************************************************************
///
/// FppInsertDestMenu
///
/// Called from FppInsertMenu, changes the insert destination.
///
///*****************************************************************************
menu FppInsertDestMenu()

  title = "Select Destination"
  history

  "&A - Text Cursor",
  FppChangeInsertDest(INS_RES_CURSOR),
  _MF_CLOSE_ALL_AFTER_ | iif(BrowseMode(), _MF_GRAYED_, _MF_ENABLED_)

  "&B - Windows Clipboard",
  FppChangeInsertDest(INS_RES_WCLIP),
  _MF_CLOSE_ALL_AFTER_

  "&C - TSE Clipboard",
  FppChangeInsertDest(INS_RES_TSECLIP),
  _MF_CLOSE_ALL_AFTER_

end

///*****************************************************************************
///
/// FppFloatMenu
///
/// Called from FppInsertMenu, selects the float value to insert,
///
///*****************************************************************************
menu FppFloatMenu()

  title = "Float Value"
  history

  "&A - Result [N]",
  FppInsertResult(RESULT_FLOAT_N),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&B - Result [S]",
  FppInsertResult(RESULT_FLOAT_S),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&C - Result [G]",
  FppInsertResult(RESULT_FLOAT_G),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "",, _MF_DIVIDE_

  "&D - Single [N]",
  FppInsertResult(RESULT_F32N),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&E - Single [S]",
  FppInsertResult(RESULT_F32S),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&F - Single [G]",
  FppInsertResult(RESULT_F32G),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "",, _MF_DIVIDE_

  "&G - Double [N]",
  FppInsertResult(RESULT_F64N),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&H - Double [S]",
  FppInsertResult(RESULT_F64S),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&I - Double [G]",
  FppInsertResult(RESULT_F64G),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

end

///*****************************************************************************
///
/// FppIntMenu
///
/// Called from FppInsertMenu, selects the integer value to insert.
///
///*****************************************************************************
menu FppIntMenu()

  title = "Integer Value"
  history

  "&A - U64-Bit",
  FppInsertResult(RESULT_U64),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&B - S64-Bit",
  FppInsertResult(RESULT_S64),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "",, _MF_DIVIDE_

  "&C - U32-Bit",
  FppInsertResult(RESULT_U32),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&D - S32-Bit",
  FppInsertResult(RESULT_S32),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "",, _MF_DIVIDE_

  "&E - U16-Bit",
  FppInsertResult(RESULT_U16),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&F - S16-Bit",
  FppInsertResult(RESULT_S16),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "",, _MF_DIVIDE_

  "&G - U8-Bit",
  FppInsertResult(RESULT_U8),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&H - S8-Bit",
  FppInsertResult(RESULT_S8),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

end

///*****************************************************************************
///
/// FppIntGroupedMenu
///
/// Called from FppInsertMenu, selects the formatted integer value to insert.
///
///*****************************************************************************
menu FppIntGroupedMenu()

  title = "Integer Grouped"
  history

  "&A - U64-Bit G",
  FppInsertResult(RESULT_U64F),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&B - S64-Bit G",
  FppInsertResult(RESULT_S64F),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "",, _MF_DIVIDE_

  "&C - U32-Bit G",
  FppInsertResult(RESULT_U32F),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&D - S32-Bit G",
  FppInsertResult(RESULT_S32F),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "",, _MF_DIVIDE_

  "&E - U16-Bit G",
  FppInsertResult(RESULT_U16F),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&F - S16-Bit G",
  FppInsertResult(RESULT_S16F),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "",, _MF_DIVIDE_

  "&G - U8-Bit G",
  FppInsertResult(RESULT_U8F),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&H - S8-Bit G",
  FppInsertResult(RESULT_S8F),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

end

///*****************************************************************************
///
/// FppIeeeMenu
///
/// Called from FppInsertMenu, selects the formatted IEEE-Hex-dump values to
/// insert.
///
///*****************************************************************************
menu FppIeeeMenu()

  title = "IEEE Hex-Bin Menu"
  history

  "&A - Single IEEE Hex",
  FppInsertResult(RESULT_F32),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&B - Single IEEE Bin",
  FppInsertResult(RESULT_F32_BIN),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&C - Double IEEE Hex",
  FppInsertResult(RESULT_F64),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

  "&D - Double IEEE Bin",
  FppInsertResult(RESULT_F64_BIN),
  _MF_CLOSE_ALL_BEFORE_ | gnFieldFlags

end

///*****************************************************************************
///
/// FppLocaleMenu
///
/// Called from FppSelectLocalization, selcts the result localization.
///
///*****************************************************************************
menu FppLocaleMenu()
  title = "Result Localization"
  history
  CheckBoxes

  "&A - US-Standard"[FppLocalizeResult(LOCALE_US, "123456789.00"):16],
  FppSetLocale(LOCALE_US),
  _MF_CLOSE_BEFORE_ | iif(gnResLocale == LOCALE_US, _MF_CHECKED_, _MF_UNCHECKED_),
  "Uses US-Standard decimal '.' and grouping ',' separators"

  "&B - Non-US"[FppLocalizeResult(LOCALE_NU, "123456789.00"):16],
  FppSetLocale(LOCALE_NU),
  _MF_CLOSE_BEFORE_ | iif(gnResLocale == LOCALE_NU, _MF_CHECKED_, _MF_UNCHECKED_),
  "Uses Non-US decimal ',' and grouping '.' separators"

  "&C - System"[FppLocalizeResult(LOCALE_SY, "123456789.00"):16],
  FppSetLocale(LOCALE_SY),
  _MF_CLOSE_BEFORE_ | iif(gnResLocale == LOCALE_SY, _MF_CHECKED_, _MF_UNCHECKED_),
  "Uses the current system settings for decimal and grouping separation"

end

///*****************************************************************************
///
/// FppHelpKeys
///
/// Activates when <F1> is pressed.
///
///*****************************************************************************
KeyDef FppHelpKeys

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
/// FppHelpTocKeys
///
/// Activates when <Alt T> is pressed in the help-list.
///
///*****************************************************************************
KeyDef FppHelpTocKeys

  <Ctrl Home>           Begfile()
  <Ctrl End>            Endfile()
  <Ctrl PgUp>           BegWindow()
  <Ctrl PgDn>           EndWindow()

end

///*****************************************************************************
///
/// FppErrorKeys
///
/// Activates when error-list is opened.
///
///*****************************************************************************
KeyDef FppErrorKeys

  <Ctrl Home>           Begfile()
  <Ctrl End>            Endfile()
  <Ctrl PgUp>           BegWindow()
  <Ctrl PgDn>           EndWindow()

end
///*****************************************************************************
///
/// FppConstKeys
///
/// Activates when <Alt T> is pressed.
///
///*****************************************************************************
KeyDef FppConstKeys

  <Ctrl Home>           Begfile()
  <Ctrl End>            Endfile()
  <Ctrl PgUp>           BegWindow()
  <Ctrl PgDn>           EndWindow()
  <Enter>               EndProcess(EP_ACCEPTED)
  <GreyEnter>           EndProcess(EP_ACCEPTED)

  <Escape>              EndProcess(EP_ABORT)

end

///*****************************************************************************
///
/// FppFuncKeys
///
/// Activates when <Alt F> is pressed.
///
///*****************************************************************************
KeyDef FppFuncKeys

  <Ctrl Home>           Begfile()
  <Ctrl End>            Endfile()
  <Ctrl PgUp>           BegWindow()
  <Ctrl PgDn>           EndWindow()
  <F1>                  EndProcess(EP_FPP_HELP)

  <Enter>               EndProcess(EP_ACCEPTED)
  <GreyEnter>           EndProcess(EP_ACCEPTED)

  <Escape>              EndProcess(EP_ABORT)

end

///*****************************************************************************
///
/// FppVarKeys
///
/// Activates when <Alt V> is pressed.
///
///*****************************************************************************
KeyDef FppVarKeys

  <Ctrl Home>           Begfile()
  <Ctrl End>            Endfile()
  <Ctrl PgUp>           BegWindow()
  <Ctrl PgDn>           EndWindow()
  <Del>                 EndProcess(EP_DEL_VAR)
  <Ctrl DEL>            EndProcess(EP_DEL_ALL_VARS)

  <Enter>               EndProcess(EP_ACCEPTED)
  <GreyEnter>           EndProcess(EP_ACCEPTED)

  <Escape>              EndProcess(EP_ABORT)

end

///*****************************************************************************
///
/// FppCodeListKeys
///
/// Activates when <Alt L> is pressed.
///
///*****************************************************************************
KeyDef FppCodeListKeys

  <Ctrl Home>           Begfile()
  <Ctrl End>            Endfile()
  <Ctrl PgUp>           BegWindow()
  <Ctrl PgDn>           EndWindow()
  <F1>                  EndProcess(EP_FPP_HELP)

  <Enter>               EndProcess(EP_ABORT)
  <GreyEnter>           EndProcess(EP_ABORT)

  <Escape>              EndProcess(EP_ABORT)

  <LeftBtn>             if not ProcessHotSpot()
                          EndProcess(EP_ABORT)
                        endif

end

///*****************************************************************************
///
/// FppKeys
///
/// Activates when the main window is opened.
///
///*****************************************************************************
KeyDef FppKeys

  <Ctrl 1>              EndProcess(EP_BASE_1_DOWN)
  <Alt  1>              EndProcess(EP_BASE_1_UP)

  <Ctrl 2>              EndProcess(EP_BASE_2_DOWN)
  <Alt  2>              EndProcess(EP_BASE_2_UP)

  <Ctrl 3>              EndProcess(EP_BASE_3_DOWN)
  <Alt  3>              EndProcess(EP_BASE_3_UP)

  <Enter>               EndProcess(EP_ACCEPTED)
  <GreyEnter>           EndProcess(EP_ACCEPTED)

  <Escape>              EndProcess(EP_ABORT_EDIT)

  <Alt I>               EndProcess(EP_INTEGER_FORMAT)
  <Alt L>               EndProcess(EP_CODELIST)

  <Alt F>               FppGetWordFromInput(GET_WORD_FUNC)  EndProcess(EP_FUNCTION_LIST)
  <Alt V>               FppGetWordFromInput(GET_WORD_VAR)   EndProcess(EP_VARLIST)
  <Alt T>               FppGetWordFromInput(GET_WORD_CONST) EndProcess(EP_CONST_LIST)

  <Alt S>               EndProcess(EP_FLOAT_FORMAT)
  <Alt O>               EndProcess(EP_OPTION_MENU)

  <F1>                  FppGetWordFromInput(GET_WORD_HELP)  EndProcess(EP_FPP_HELP)

  <Tab>                 if gnErrorPos
                          BegLine()
                          GotoPos(gnErrorPos)
                        endif

  <Alt P>               EndProcess(EP_INSERT_MENU)

  <LeftBtn>             gnExitCode = FppCheckAndSetMouseAction(MBUT_LEFT, Query(MouseX), Query(MouseY))
                        if gnExitCode <> EP_NO_ACTION
                          EndProcess(gnExitCode)
                        endif

  <RightBtn>            gnExitCode = FppCheckAndSetMouseAction(MBUT_RIGHT, Query(MouseX), Query(MouseY))
                        if gnExitCode <> EP_NO_ACTION
                          EndProcess(gnExitCode)
                        endif

#ifdef WHEEL_IS_PRESENT
  <WheelUp>             Left()
  <WheelDown>           Right()
#endif

#ifdef XBUTTON_IS_PRESENT
  // Currently works with GUI-TSE only
  <XButton1>            gnExitCode = FppCheckAndSetMouseAction(MBUT_XBUT_1, Query(MouseX), Query(MouseY))
                        if gnExitCode <> EP_NO_ACTION
                          EndProcess(gnExitCode)
                        endif

  <XButton2>            gnExitCode = FppCheckAndSetMouseAction(MBUT_XBUT_2, Query(MouseX), Query(MouseY))
                        if gnExitCode <> EP_NO_ACTION
                          EndProcess(gnExitCode)
                        endif
#endif

  <Ctrl  M>             FppDelToLeft()
  <Alt   M>             DelToEol()

  // Additional keys
  <Ctrl  A>             MarkAll()
  <Ctrl  V>             PasteFromWinClip()
  <Ctrl  C>             CopyToWinClip()
  <Ctrl  X>             CutToWinClip()
  <Shift Del>           CutToWinClip()
  <Ctrl  Ins>           CopyToWinClip()
  <Shift Ins>           PasteFromWinClip()
  <Ctrl  H>             UnMarkBlock()
  <Alt   C>             CopyBlock()
  <Alt   A>             MarkStream()
  <Alt   J>             MarkColumn()
  <Alt   W>             MarkWord()
  <Alt   6>             MarkToEOL()
  <Alt   Y>             DelBlock()
  <Alt   U>             Paste()

end

///*****************************************************************************
///
/// FppDelToLeft()
///
/// Called from div. keys
/// Deletes from cursor to the beginning of the line, except char under cursor.
///
///*****************************************************************************
proc FppDelToLeft()

  while CurrPos() > 1
    BackSpace()
  endwhile

end

///*****************************************************************************
///
/// FppHelp
///
/// Quick-Help-Menu, called when pressing F1.
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

  // Save old marking
  PushBlock()

  // Prepare buffer
  nTempBuffer = CreateTempBuffer()
  SetUndoOff()
  if InsertFile(gcMacDir + gcFileHelp, _DONT_PROMPT_) == 0
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_) + " [" + gcMacVersion + "]",
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

  // Automatic search for word
  else
    FppTypeWord(gfWsHelp)
  endif

  // Limit width to edit window
  nMaxWidth = Min(Query(ScreenCols), LongestLineInBuffer())

  // Display help
  BufferVideo()
  HookDisplay(FppDrawHelpLine,,, FppHiliteText)
  loop
    if (not Hook(_LIST_STARTUP_, FppEnableHelpKeys))  or (not Hook(_LIST_CLEANUP_, FppDisableHelpKeys))
      Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
           Chr(13) + Chr(13) +
           "Hook FppEnableHelpKeys/FppDisableHelpKeys could not be established!" + Chr(13) +
           "List keymappings might not work as expected."
          )
    endif

    if lList("FppShell Help: " + gcFileHelp, nMaxWidth, Query(ScreenRows), _ENABLE_SEARCH_ | _ENABLE_HSCROLL_) == EP_ABORT
      break
    endif
  endloop
  UnHookDisplay()
  UnBufferVideo()

  AbandonFile(nTempBuffer)
  GotoBufferId(nOldBuffer)
  // Restore old marking
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

  string cBuffer[MAXSTRINGLEN] = GetText(CurrXoffset() + 1, MAXSTRINGLEN)

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
      Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
           Chr(13) + Chr(13) +
           "Hook FppEnableTocKeys/FppDisableTocKeys could not be established!" + Chr(13) +
           "List keymappings might not work as expected."
          )
    endif

    // Display TOC-list
    BufferVideo()
    HookDisplay(FppDrawTocLine,,, FppHiliteText)
    if lList("FppShell Help: TOC-List", nMaxWidth, Query(ScreenRows), _ENABLE_SEARCH_ | _ENABLE_HSCROLL_)
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

  string cBuffer[MAXSTRINGLEN] = GetText(CurrXoffset() + 1, MAXSTRINGLEN)

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
/// FppInsertResult
///
/// Called from div. FppInsert-menus. Prepares the the data for insert,
///
/// Input:
/// nResultToInsert -> Dataselector
///
///*****************************************************************************
proc FppInsertResult(integer nResultToInsert)

  case nResultToInsert
  when RESULT_BASE_1
    gcValToInsert = "Base " + Str(gnBase1) + ": " + Trim(RightStr(gcResultBase1, Val(GetToken(gcBaseLen, " ", gnBase1))))

  when RESULT_BASE_2
    gcValToInsert = "Base " + Str(gnBase2) + ": " + Trim(RightStr(gcResultBase2, Val(GetToken(gcBaseLen, " ", gnBase2))))

  when RESULT_BASE_3
    gcValToInsert = "Base " + Str(gnBase3) + ": " + Trim(RightStr(gcResultBase3, Val(GetToken(gcBaseLen, " ", gnBase3))))

  when RESULT_F32
    gcValToInsert = "Single hex: " + gcF32

  when RESULT_F64
    gcValToInsert = "Double hex: " + gcF64

  when RESULT_F32_BIN
    gcValToInsert = "Single bin: " + gcF32Bin

  when RESULT_F64_BIN
    gcValToInsert = "Double bin: " + gcF64Bin

  when RESULT_F32D
    if gnFloatFormat == FLOAT_NORMAL
      gcValToInsert = gcF32D
    elseif gnFloatFormat == FLOAT_SCIENTIFIC
      gcValToInsert = gcF32S
    else
      gcValToInsert = gcF32L
    endif

  when RESULT_F32N
    gcValToInsert = gcF32D

  when RESULT_F32S
    gcValToInsert = gcF32S

  when RESULT_F32G
    gcValToInsert = gcF32L

  when RESULT_F64D
    if gnFloatFormat == FLOAT_NORMAL
      gcValToInsert = gcF64D
    elseif gnFloatFormat == FLOAT_SCIENTIFIC
      gcValToInsert = gcF64S
    else
      gcValToInsert = gcF64L
    endif

  when RESULT_F64N
    gcValToInsert = gcF64D

  when RESULT_F64S
    gcValToInsert = gcF64S

  when RESULT_F64G
    gcValToInsert = gcF64L

  when RESULT_U64
    gcValToInsert = "u64: " + gcU64

  when RESULT_S64
    gcValToInsert = "s64: " + gcS64

  when RESULT_U32
    gcValToInsert = "u32: " + gcU32

  when RESULT_S32
    gcValToInsert = "s32: " + gcS32

  when RESULT_U16
    gcValToInsert = "u16: " + gcU16

  when RESULT_S16
    gcValToInsert = "s16: " + gcS16

  when RESULT_U8
    gcValToInsert = "u8: " + gcU8

  when RESULT_S8
    gcValToInsert = "s8: " + gcS8

  when RESULT_U64F
    gcValToInsert = "u64: " + gcU64L

  when RESULT_S64F
    gcValToInsert = "s64: " + gcS64L

  when RESULT_U32F
    gcValToInsert = "u32: " + gcU32L

  when RESULT_S32F
    gcValToInsert = "s32: " + gcS32L

  when RESULT_U16F
    gcValToInsert = "u16:"  + gcU16L

  when RESULT_S16F
    gcValToInsert = "s16: " + gcS16L

  when RESULT_U8F
    gcValToInsert = "u8: " + gcU8L

  when RESULT_S8F
    gcValToInsert = "s8: " + gcS8L

  when RESULT_FLOAT
    if gnFloatFormat == FLOAT_NORMAL
      gcValToInsert = gcFloat
    elseif gnFloatFormat == FLOAT_SCIENTIFIC
      gcValToInsert = gcSFloat
    else
      gcValToInsert = gcLFloat
    endif

  when RESULT_FLOAT_N
    gcValToInsert = gcFloat

  when RESULT_FLOAT_S
    gcValToInsert = gcSFloat

  when RESULT_FLOAT_G
    gcValToInsert = gcLFloat

  when RESULT_EXPRESSION
    gcValToInsert = gcExpression
  endcase

  gcValToInsert = Trim(gcValToInsert)
  gfExitMenu    = TRUE                 // Leave menu when done

end

///*****************************************************************************
///
/// FppFuncList
///
/// Called when <Alt F> is pressed. Builds a list of functions and lets you
/// selects a function to be inserted into the expression line at the cursor
/// position.
///
///*****************************************************************************
proc FppFuncList()

  integer nRetVal     = 0
  integer nTempBuffer = 0
  integer nMaxWidth   = 0
  integer nProcess    = 0
  integer nOldBuffer  = GetBufferId()

  string  cFuncName[20] = ""

  // Only necessary when running in console-mode
  if not isGui()
    FppStartRedirect('"' + gcMacDir + gcFileRedirect + '"', gnHandStdOut, gnHandErrOut)
  endif

  // Generate function-list
  // Replacement for ldos()
  // ldos() doesn't return the needed 32 bit return value and can't handle the window
  // nProcess -> >0 = Process was started
  //              0 = Process couldn't get started
  //             <0 = OS-Errormessage
  nProcess = RunApplication('"' + gcLoadDir + gcExeName + '"',
                            'Fl "-f' + gcMacDir + gcFileFuncList + '"',
                            START_APP_GET_RETURN,
                            SW_HIDE, // SW_SHOWMINNOACTIVE,
                            nRetVal
                           )

  // Only necessary when running in console-mode
  if not isGui()
    FppEndRedirect(gcMacDir + gcFileRedirect, gnHandStdOut, gnHandErrOut)
  endif

  // Program not found???
  if nProcess == 0
    Warn(gcLoadDir + gcExeName + Chr(13)
         + "command FLIST could not be executed"
        )
    return()

  // Display OS-Errorcode
  elseif nProcess < 0
    nProcess = -nProcess
    Warn("OS-Errorcode: " + Str(nProcess) + Chr(13)
         + "trying to run" + Chr(13)
         + gcLoadDir + gcExeName + Chr(13)
         + "command FLIST failed"
        )
    return()
  endif

  // Evaluate return code
  if nRetVal
    FppShowErrors(nRetVal)
    return()
  endif

  // Save old marking
  PushBlock()

  // Prepare buffer
  nTempBuffer = CreateTempBuffer()
  SetUndoOff()
  if InsertFile(gcMacDir + gcFileFuncList, _DONT_PROMPT_) == 0
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_) + " [" + gcMacVersion + "]",
           "FunctionList-File couldn't be loaded!" + Chr(13) +
           gcMacDir + gcFileFuncList + Chr(13),
           _OK_
          )
    GotoBufferId(nOldBuffer)
    PopBlock()
    return()
  endif

  UnMarkBlock()

  // Limit width to edit window
  nMaxWidth = Min(Query(ScreenCols), 30)

  // If there is a word to search for
  FppTypeWord(gfWsFuncList)

  BufferVideo()
  loop
    // Activate special keys
    if (not Hook(_LIST_STARTUP_, FppEnableFuncKeys))  or (not Hook(_LIST_CLEANUP_, FppDisableFuncKeys))
      Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
           Chr(13) + Chr(13) +
           "Hook FppEnableFuncKeys/FppDisableFuncKeys could not be established!" + Chr(13) +
           "List keymappings might not work as expected."
          )
    endif

    // Display list, evaluate return code
    case lList("Functions: " + gcFileFuncList, nMaxWidth, Query(ScreenRows), _ENABLE_SEARCH_ | _ENABLE_HSCROLL_)
    // Insert function into expression
    when EP_ACCEPTED
      cFuncName    = GetText(1, 20)
      gcExpression = InsStr(cFuncName, gcExpression, gnXOffset + gnCursorPos)
      break

    // Help for function
    when EP_FPP_HELP
        FppHelp(GetText(1, 20))

    // Quit
    when EP_ABORT
      break
    endcase
  endloop
  UnBufferVideo()

  AbandonFile(nTempBuffer)
  GotoBufferId(nOldBuffer)
  // Restore old marking
  PopBlock()

end

///*****************************************************************************
///
/// FppVarList
///
/// Called when <Alt V> is pressed. Builds a list of currently available
/// variables and lets you selects a variable to be inserted into the expression
/// line at the cursor position. Also provides a delete option.
///
///*****************************************************************************
proc FppVarList()

  integer nTempBuffer = 0
  integer nDelVar     = FALSE
  integer nMaxWidth   = 0
  integer nOldBuffer  = GetBufferId()

  string  cIdName[40]   = ""
  string  cDecSep[5]    = ""
  string  cThoSep[5]    = ""
  string  cGrouping[10] = ""

  // Variables file must be present
  if FindThisFile(gcMacDir + gcFileVarList) == FALSE
    Warn("Error loading " + gcMacDir + gcFileVarList + chr(13) + "File not found")
    return()
  endif

  // Save old marking
  PushBlock()

  // Prepare buffer
  nTempBuffer = CreateTempBuffer()
  SetUndoOff()
  if InsertFile(gcMacDir + gcFileVarList, _DONT_PROMPT_) == 0
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_) + " [" + gcMacVersion + "]",
           "VariablesList-File couldn't be loaded!" + Chr(13) +
           gcMacDir + gcFileVarList + Chr(13),
           _OK_
          )
    GotoBufferId(nOldBuffer)
    PopBlock()
    return()
  endif

  UnMarkBlock()

  // Insert locale separators
  BegFile()
  while lFind("[0-9-+.eE]#", "x$")
    InsertText(FppLocalizeResult(gnResLocale, GetFoundText()), _OVERWRITE_)
    EndLine()
  endwhile
  BegFile()

  // Limit width to edit window
  nMaxWidth = Min(Query(ScreenCols), WIN_WIDTH)

  // If there is a word to search for
  FppTypeWord(gfWsVarList)

  BufferVideo()
  loop
    // activate special keys
    if (not Hook(_LIST_STARTUP_, FppEnableVarKeys)) or (not Hook(_LIST_CLEANUP_, FppDisableVarKeys))
      Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
           Chr(13) + Chr(13) +
           "Hook FppEnableVarKeys/FppDisableVarKeys could not be established!" + Chr(13) +
           "List keymappings might not work as expected."
          )
    endif

    // Display list, evaluate return code
    case lList("Variables: " + gcFileVarList, nMaxWidth, Query(ScreenRows), _ENABLE_SEARCH_ | _ENABLE_HSCROLL_)
    // Insert variable into expression
    when EP_ACCEPTED
      cIdName      = Trim(GetToken(GetText(1, 40), " =:", 1))
      gcExpression = InsStr(cIdName, gcExpression, gnXOffset + gnCursorPos)
      break

    // Delete variable
    when EP_DEL_VAR
        KillLine()
        nDelVar = TRUE

    // Delete all variables
    when EP_DEL_ALL_VARS
      if MsgBox("Confirm Delete", "OK to delete ALL Vars?", _YES_NO_) == 1
        MarkAll()
        KillBlock()
        nDelVar = TRUE
        break
      endif

    // Quit
    when EP_ABORT
      break
    endcase
  endloop
  UnBufferVideo()

  // If there was at least one variable deleted, write the buffer
  if nDelVar
    // Restore locale to US-Standard before saving
    FppGetLocaleData(gnResLocale, cDecSep, cThoSep, cGrouping)
    lReplace(cThoSep, "", "gn")
    lReplace(cDecSep, ".", "gn")

    if SaveAs(gcMacDir + gcFileVarList, _OVERWRITE_ | _DONT_PROMPT_) == 0
      MsgBox(SplitPath(CurrMacroFilename(), _NAME_) + " [" + gcMacVersion + "]",
             "Error writing file:" + Chr(13) +
             gcMacDir + gcFileVarList + Chr(13),
             _OK_
            )
    endif
  endif

  AbandonFile(nTempBuffer)
  GotoBufferId(nOldBuffer)
  // Restore old marking
  PopBlock()

end

///*****************************************************************************
///
/// FppCodeList
///
/// Called when pressing <Alt L>. Displays the generated code-list generated by
/// the FppCon*.exe.
///
///*****************************************************************************
proc FppCodeList()

  integer nTempBuffer = 0
  integer nMaxWidth   = 0
  integer nOldBuffer  = GetBufferId()

  // Code-List file must be present
  if FindThisFile(gcMacDir + gcFileCodeList) == FALSE
    Warn("Error loading " + gcMacDir + gcFileCodeList + chr(13) + "File not found")
    return()
  endif

  // Save old marking
  PushBlock()

  // Prepare buffer
  nTempBuffer = CreateTempBuffer()
  SetUndoOff()
  if InsertFile(gcMacDir + gcFileCodeList, _DONT_PROMPT_) == 0
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_) + " [" + gcMacVersion + "]",
           "CodeList-File couldn't be loaded!" + Chr(13) +
           gcMacDir + gcFileCodeList + Chr(13),
           _OK_
          )
    GotoBufferId(nOldBuffer)
    PopBlock()
    return()
  endif

  UnMarkBlock()

  // Limit width to edit window
  nMaxWidth = Min(Query(ScreenCols), LongestLineInBuffer())

  BufferVideo()
  loop
    // Activate special keys
    if (not Hook(_LIST_STARTUP_, FppEnableCodeListKeys))  or (not Hook(_LIST_CLEANUP_, FppDisableCodeListKeys))
      Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
           Chr(13) + Chr(13) +
           "Hook FppEnableCodeListKeys/FppDisableCodeListKeys could not be established!" + Chr(13) +
           "List keymappings might not work as expected."
          )
    endif

    // Display list, evaluate return code
    case lList("Generated code: " + gcFileCodeList, nMaxWidth, Query(ScreenRows), _ENABLE_SEARCH_ | _ENABLE_HSCROLL_)
    // Help for codelist
    when EP_FPP_HELP
        FppHelp("code list-file  ")

    // Quit
    when EP_ABORT
      break
    endcase
  endloop
  UnBufferVideo()

  AbandonFile(nTempBuffer)
  GotoBufferId(nOldBuffer)
  // Restore old marking
  PopBlock()

end

///*****************************************************************************
///
/// FppConstList
///
/// Called when <Alt T> is pressed. Builds and displays a list of all
/// currently availabe constants and lets you select a constant to insert into
/// the expression line at the cursor position.
///
///*****************************************************************************
proc FppConstList()

  integer nRetVal     = 0
  integer nTempBuffer = 0
  integer nProcess    = 0
  integer nMaxWidth   = 0
  integer nOldBuffer  = GetBufferId()

  string  cConstName[20] = ""

  // Only necessary when running in console-mode
  if not isGui()
    FppStartRedirect('"' + gcMacDir + gcFileRedirect + '"', gnHandStdOut, gnHandErrOut)
  endif

  // Generate constants-file
  // Replacement for ldos()
  // ldos() doesn't return the needed 32 bit return value and can't handle the window
  // nProcess -> >0 = Process was started
  //              0 = Process couldn't get started
  //             <0 = OS-Errormessage
  nProcess = RunApplication('"' + gcLoadDir + gcExeName + '"',
                            'Cl "-c' + gcMacDir + gcFileConstList + '"',
                            START_APP_GET_RETURN,
                            SW_HIDE, // SW_SHOWMINNOACTIVE,
                            nRetVal
                           )

  // Only necessary when running in console-mode
  if not isGui()
    FppEndRedirect(gcMacDir + gcFileRedirect, gnHandStdOut, gnHandErrOut)
  endif

  // Program not found???
  if nProcess == 0
    Warn(gcLoadDir + gcExeName + Chr(13)
         + "command CLIST could not be executed"
        )
    return()

  // Display OS-Errorcode
  elseif nProcess < 0
    nProcess = -nProcess
    Warn("OS-Errorcode: " + Str(nProcess) + Chr(13)
         + "trying to run" + Chr(13)
         + gcLoadDir + gcExeName + Chr(13)
         + "command CLIST failed"
        )
    return()
  endif

  // Evaluate return code
  if nRetVal
    FppShowErrors(nRetVal)
    return()
  endif

  // Save old marking
  PushBlock()

  // Prepare buffer
  nTempBuffer = CreateTempBuffer()
  SetUndoOff()
  if InsertFile(gcMacDir + gcFileConstList, _DONT_PROMPT_) == 0
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_) + " [" + gcMacVersion + "]",
           "ConstantList-File couldn't be loaded!" + Chr(13) +
           gcMacDir + gcFileConstList + Chr(13),
           _OK_
          )
    GotoBufferId(nOldBuffer)
    PopBlock()
    return()
  endif

  UnMarkBlock()

  // Insert locale separators
  BegFile()
  while lFind("[0-9-+.eE]#", "x$")
    InsertText(FppLocalizeResult(gnResLocale, GetFoundText()), _OVERWRITE_)
    EndLine()
  endwhile
  BegFile()

  // Limit width to edit window
  nMaxWidth = Min(Query(ScreenCols), WIN_WIDTH)

  // Activate special keys
  if (not Hook(_LIST_STARTUP_, FppEnableConstKeys)) or (not Hook(_LIST_CLEANUP_, FppDisableConstKeys))
    Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
         Chr(13) + Chr(13) +
         "Hook FppEnableConstKeys/FppDisableConstKeys could not be established!" + Chr(13) +
         "List keymappings might not work as expected."
        )
  endif

  // If there is a word to search for
  FppTypeWord(gfWsConList)

  BufferVideo()
  // Display list, evaluate return code and insert constant into expression
  if lList("Constants: " + gcFileConstList, nMaxWidth, Query(ScreenRows), _ENABLE_SEARCH_ | _ENABLE_HSCROLL_) == EP_ACCEPTED
    cConstName   = Trim(GetToken(GetText(1, 20), " =:", 1))
    gcExpression = InsStr(cConstName, gcExpression, gnXOffset + gnCursorPos)
  endif
  UnBufferVideo()

  AbandonFile(nTempBuffer)
  GotoBufferId(nOldBuffer)
  // Restore old marking
  PopBlock()

end

///*****************************************************************************
///
/// FppGetWordFromInput
///
/// Calls the actual getter by setting the wordset according to the vnSelector.
///
/// Input:
/// vnSelector -> GET_WORD_*
///
///*****************************************************************************
proc FppGetWordFromInput(integer vnSelector)

  case vnSelector
  when GET_WORD_FUNC
    FppGetWord("0-9a-zA-Z(")

  when GET_WORD_VAR
    FppGetWord("0-9a-z_A-Z")

  when GET_WORD_CONST
    FppGetWord("a-zA-Z")

  when GET_WORD_HELP
    FppGetWord("0-9a-zA-Z(")

  otherwise
    gcWord = ""
  endcase

end

///*****************************************************************************
///
/// FppGetWord
///
/// Determines the actual word at cursor position in the input string if
/// there is any.
///
/// Input:
/// vcWordset -> Wordset to use, for example "a-zA-z"
///
///*****************************************************************************
proc FppGetWord(string vcWordset)

  gcWord = GetWord(TRUE, ChrSet(vcWordset))

end

///*****************************************************************************
///
/// FppTypeWord
///
/// Inserts the previously found word into the keyboard stack. This activates an
/// automatic search in the list and adjusts the display to the found text if it
/// is present.
///
/// Input:
/// vnTypeWord -> TRUE when search is allowed, FALSE otherwise
///
///*****************************************************************************
proc FppTypeWord(integer vnTypeWord)

  if vnTypeWord and gcWord <> ""
    PushKeyStr(gcWord)
  endif

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

  integer nTempBuffer = 0
  integer nMaxWidth   = 0
  integer nOldBuffer  = GetBufferId()

  // Save old marking
  PushBlock()

  // Prepare buffer
  nTempBuffer = CreateTempBuffer()
  SetUndoOff()

  if vnErrors & ERROR_IN_EXPRESSION
    AddLine("Error in Expression")
    AddLine(gcExpression)
    AddLine(Format("?":gnErrorPos:" "))
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

  if vnErrors & ERROR_BASE_1_OUT_OF_RANGE
    AddLine("Result Base 1 out of range (2...36), please check settings")
    AddLine()
  endif

  if vnErrors & ERROR_BASE_2_OUT_OF_RANGE
    AddLine("Result Base 2 out of range (2...36), please check settings")
    AddLine()
  endif

  if vnErrors & ERROR_BASE_3_OUT_OF_RANGE
    AddLine("Result Base 3 out of range (2...36), please check settings")
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

  if vnErrors & ERROR_VAR_OPEN_FILE
    AddLine(gcErrorOpenFile + gcMacDir + gcFileVarList)
    AddLine()
  endif

  if vnErrors & ERROR_VAR_CLOSE_FILE
    AddLine(gcErrorCloseFile + gcMacDir + gcFileVarList)
    AddLine()
  endif

  if vnErrors & ERROR_VAR_READ_FILE
    AddLine(gcErrorReadFile + gcMacDir + gcFileVarList)
    AddLine()
  endif

  if vnErrors & ERROR_VAR_WRITE_FILE
    AddLine(gcErrorWriteFile + gcMacDir + gcFileVarList)
    AddLine()
  endif

  if vnErrors & ERROR_VAR_NO_FILENAME
    AddLine("Error no filename for ID-List")
    AddLine()
  endif

  if vnErrors & ERROR_CODE_OPEN_FILE
    AddLine(gcErrorOpenFile + gcMacDir + gcFileCodeList)
    AddLine()
  endif

  if vnErrors & ERROR_CODE_CLOSE_FILE
    AddLine(gcErrorCloseFile + gcMacDir + gcFileCodeList)
    AddLine()
  endif

  if vnErrors & ERROR_CODE_WRITE_FILE
    AddLine(gcErrorWriteFile + gcMacDir + gcFileCodeList)
    AddLine()
  endif

  if vnErrors & ERROR_CODE_NO_FILENAME
    AddLine("Error no filename for Code-List")
    AddLine()
  endif

  if vnErrors & ERROR_RESULT_OPEN_FILE
    FppKillResults()
    AddLine(gcErrorOpenFile + gcMacDir + gcFileResult)
    AddLine()
  endif

  if vnErrors & ERROR_RESULT_CLOSE_FILE
    FppKillResults()
    AddLine(gcErrorCloseFile + gcMacDir + gcFileResult)
    AddLine()
  endif

  if vnErrors & ERROR_RESULT_WRITE_FILE
    FppKillResults()
    AddLine(gcErrorWriteFile + gcMacDir + gcFileResult)
    AddLine()
  endif

  if vnErrors & ERROR_RESULT_NO_FILENAME
    FppKillResults()
    AddLine("Error no filename for Result")
    AddLine()
  endif

  if vnErrors & ERROR_EXPR_OPEN_FILE
    AddLine(gcErrorOpenFile + gcMacDir + gcFileExpression)
    AddLine()
  endif

  if vnErrors & ERROR_EXPR_CLOSE_FILE
    AddLine(gcErrorCloseFile + gcMacDir + gcFileExpression)
    AddLine()
  endif

  if vnErrors & ERROR_EXPR_READ_FILE
    AddLine(gcErrorReadFile + gcMacDir + gcFileExpression)
    AddLine()
  endif

  if vnErrors & ERROR_EXPR_NO_FILENAME
    AddLine("Error no filename for Expression")
    AddLine()
  endif

  if vnErrors & ERROR_FUNC_OPEN_FILE
    AddLine(gcErrorOpenFile + gcMacDir + gcFileFuncList)
    AddLine()
  endif

  if vnErrors & ERROR_FUNC_CLOSE_FILE
    AddLine(gcErrorCloseFile + gcMacDir + gcFileFuncList)
    AddLine()
  endif

  if vnErrors & ERROR_FUNC_WRITE_FILE
    AddLine(gcErrorWriteFile + gcMacDir + gcFileFuncList)
    AddLine()
  endif

  if vnErrors & ERROR_FUNC_NO_FILENAME
    AddLine("Error no filename for Functions-List")
    AddLine()
  endif

  if vnErrors & ERROR_CONST_OPEN_FILE
    AddLine(gcErrorOpenFile + gcMacDir + gcFileConstList)
    AddLine()
  endif

  if vnErrors & ERROR_CONST_CLOSE_FILE
    AddLine(gcErrorCloseFile + gcMacDir + gcFileConstList)
    AddLine()
  endif

  if vnErrors & ERROR_CONST_WRITE_FILE
    AddLine(gcErrorWriteFile + gcMacDir + gcFileConstList)
    AddLine()
  endif

  if vnErrors & ERROR_CONST_NO_FILENAME
    AddLine("Error no filename for Constants-List")
    AddLine()
  endif

  // Limit width to edit window
  nMaxWidth = Min(Query(ScreenCols), LongestLineInBuffer())

  // Display errorlist
  if (not Hook(_LIST_STARTUP_, FppEnableErrorKeys)) or (not Hook(_LIST_CLEANUP_, FppDisableErrorKeys))
    Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
         Chr(13) + Chr(13) +
         "Hook FppEnableErrorKeys/FppDisableErrorKeys could not be established!" + Chr(13) +
         "List keymappings might not work as expected."
        )
  endif

  BufferVideo()
  lList("FppCon Returned Error(s)", nMaxWidth, Query(ScreenRows), _ENABLE_SEARCH_ | _ENABLE_HSCROLL_)
  UnBufferVideo()

  AbandonFile(nTempBuffer)
  GotoBufferId(nOldBuffer)
  // Restore old marking
  PopBlock()

end

///*****************************************************************************
///
/// FppKillResults
///
/// Deletes all result strings.
///
///*****************************************************************************
proc FppKillResults()

  gcResultBase1 = ""
  gcResultBase2 = ""
  gcResultBase3 = ""
  gcFloat       = ""
  gcSFloat      = ""
  gcLFloat      = ""
  gcF32Bin      = ""
  gcF64Bin      = ""
  gcF32         = ""
  gcF64         = ""
  gcF32D        = ""
  gcF64D        = ""
  gcF32S        = ""
  gcF64S        = ""
  gcF32L        = ""
  gcF64L        = ""
  gcU8          = ""
  gcS8          = ""
  gcU16         = ""
  gcS16         = ""
  gcU32         = ""
  gcS32         = ""
  gcU64         = ""
  gcS64         = ""
  gcU64Hex      = ""

end

///*****************************************************************************
///
/// FppImportResults
///
/// Loads the result file generated by FppCon*.exe and extracts all used data
/// to internal buffers while formatting them.
///
///*****************************************************************************
proc FppImportResults()

  integer nTempBuffer = 0
  integer nOldBuffer  = GetBufferId()

  // Load result file
  if FindThisFile(gcMacDir + gcFileResult) == FALSE
    FppKillResults()
    Warn("Error loading " + gcMacDir + gcFileResult +", File not found")
    return()
  endif

  // Save old marking
  PushBlock()

  nTempBuffer = CreateTempBuffer()
  SetUndoOff()
  if InsertFile(gcMacDir + gcFileResult, _DONT_PROMPT_) == 0
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_) + " [" + gcMacVersion + "]",
           "Result-File couldn't be loaded!" + Chr(13) +
           gcMacDir + gcFileResult + Chr(13),
           _OK_
          )
    GotoBufferId(nOldBuffer)
    PopBlock()
    return()
  endif

  UnMarkBlock()
  FppKillResults()

  if lReplace("[R1]", "", "g^1")
    gcResultBase1 = Format(GetText(1, BASE_FIELD_SIZE):-BASE_FIELD_SIZE)
  endif

  if lReplace("[R2]", "", "g^1")
    gcResultBase2 = Format(GetText(1, BASE_FIELD_SIZE):-BASE_FIELD_SIZE)
  endif

  if lReplace("[R3]", "", "g^1")
    gcResultBase3 = Format(GetText(1, BASE_FIELD_SIZE):-BASE_FIELD_SIZE)
  endif

  if lReplace("[QRESULT]", "", "g^1")
    gcFloat = Trim(GetText(1, MAXSTRINGLEN))
  endif

  if lReplace("[QRESULT_SCI]", "", "g^1")
    gcSFloat = Trim(GetText(1, MAXSTRINGLEN))
  endif

  if lReplace("[QRESULT_LOC]", "", "g^1")
    gcLFloat = Trim(GetText(1, MAXSTRINGLEN))
  endif

  if lReplace("[HEX_SINGLE]", "", "g^1")
    gcF32 = Format(GetText(1, RESULT_F32_SIZE):RESULT_F32_SIZE)
  endif

  if lReplace("[HEX_DOUBLE]", "", "g^1")
    gcF64 = Format(GetText(1, RESULT_F64_SIZE):RESULT_F64_SIZE)
  endif

  if lReplace("[SINGLE]", "", "g^1")
    gcF32D = Trim(GetText(1, RESULT_F32D_SIZE))
  endif

  if lReplace("[DOUBLE]", "", "g^1")
    gcF64D = Trim(GetText(1, RESULT_F64D_SIZE))
  endif

  if lReplace("[SCI_SINGLE]", "", "g^1")
    gcF32S = Trim(GetText(1, RESULT_F32D_SIZE))
  endif

  if lReplace("[SCI_DOUBLE]", "",  "g^1")
    gcF64S = Trim(GetText(1, RESULT_F64D_SIZE))
  endif

  if lReplace("[LOC_SINGLE]", "", "g^1")
    gcF32L = Trim(GetText(1, RESULT_F32D_SIZE))
  endif

  if lReplace("[LOC_DOUBLE]", "", "g^1")
    gcF64L = Trim(GetText(1, RESULT_F64D_SIZE))
  endif

  if lReplace("[BIN_SINGLE]", "", "g^1")
    gcF32Bin = Trim(GetText(1, RESULT_F32_BIN_SIZE))
  endif

  if lReplace("[BIN_DOUBLE]", "", "g^1")
    gcF64Bin = Trim(GetText(1, RESULT_F64_BIN_SIZE))
  endif

  if lReplace("[U64]", "", "g^1")
    gcU64 = Trim(GetText(1, RESULT_64_SIZE))
  endif

  if lReplace("[S64]", "", "g^1")
    gcS64 = Trim(GetText(1, RESULT_64_SIZE))
  endif

  if lReplace("[U32]", "", "g^1")
    gcU32 = Trim(GetText(1, RESULT_32_SIZE))
  endif

  if lReplace("[S32]", "", "g^1")
    gcS32 = Trim(GetText(1, RESULT_32_SIZE))
  endif

  if lReplace("[U16]", "", "g^1")
    gcU16 = Trim(GetText(1, RESULT_16_SIZE))
  endif

  if lReplace("[S16]", "", "g^1")
    gcS16 = Trim(GetText(1, RESULT_16_SIZE))
  endif

  if lReplace("[U8]", "", "g^1")
    gcU8 = Trim(GetText(1, RESULT_8_SIZE))
  endif

  if lReplace("[S8]", "", "g^1")
    gcS8 = Trim(GetText(1, RESULT_8_SIZE))
  endif

  if lReplace("[U64L]", "", "g^1")
    gcU64L = Trim(GetText(1, RESULT_64_SIZE))
  endif

  if lReplace("[S64L]", "", "g^1")
    gcS64L = Trim(GetText(1, RESULT_64_SIZE))
  endif

  if lReplace("[U32L]", "", "g^1")
    gcU32L = Trim(GetText(1, RESULT_32_SIZE))
  endif

  if lReplace("[S32L]", "", "g^1")
    gcS32L = Trim(GetText(1, RESULT_32_SIZE))
  endif

  if lReplace("[U16L]", "", "g^1")
    gcU16L = Trim(GetText(1, RESULT_16_SIZE))
  endif

  if lReplace("[S16L]", "", "g^1")
    gcS16L = Trim(GetText(1, RESULT_16_SIZE))
  endif

  if lReplace("[U8L]", "", "g^1")
    gcU8L = Trim(GetText(1, RESULT_8_SIZE))
  endif

  if lReplace("[S8L]", "", "g^1")
    gcS8L = Trim(GetText(1, RESULT_8_SIZE))
  endif

  if lReplace("[U64_HEX]", "", "g^1")
    gcU64Hex = Trim(GetText(1, RESULT_U64_HEX_SIZE))
  endif

  if lReplace("[EP]", "", "g^1")
    gnErrorPos = Val(GetText(1, 10))
  else
    gnErrorPos = 0
  endif

  if lReplace("[ET]", "", "g^1")
    gcErrorText = Trim(GetText(1, MAXSTRINGLEN))
  else
    gcErrorText = ""
  endif

  if lReplace("[ME]", "", "g^1")
    gcMathError = Trim(GetText(1, MAXSTRINGLEN))
  else
    gcMathError = ""
  endif

  if lReplace("[TIME_OVERALL]", "", "g^1")
    gcTimeTaken = ltrim(GetText(1, RESULT_TIME_TAKEN_SIZE))
  else
    gcTimeTaken = ""
  endif

  if lReplace("[TIME_COMP_RUN]", "", "g^1")
    gcTimeCompRun = ltrim(GetText(1, RESULT_TIME_TAKEN_SIZE))
  else
    gcTimeCompRun = ""
  endif

  AbandonFile(nTempBuffer)
  GotoBufferId(nOldBuffer)
  // Restore old marking
  PopBlock()

end

///*****************************************************************************
///
/// FppBase
///
/// Called when <Ctrl 1/2/3> increment base, or <Alt 1/2/3> decrement base
/// is pressed or mouse-click on +/-.
///
/// Input:
/// vnUp      -> TRUE  increment base, otherwise FALSE
/// vnBaseNum -> Base to inc/dec
///
///*****************************************************************************
proc FppBase(integer vnUp, integer vnBaseNum)

  integer nNewBase = 0
  integer nRetVal  = 0

  string  cConverted[BASE_FIELD_SIZE] = ""

  // Restore base for working
  case vnBaseNum
  when BASE_1
    nNewBase = gnBase1

  when BASE_2
    nNewBase = gnBase2

  when BASE_3
    nNewBase = gnBase3
  endcase

  // Inc base
  if vnUp
    if nNewBase < MAX_BASE
      nNewBase = nNewBase + 1
    else
      nNewBase = MIN_BASE
    endif

  // Dec base
  else
    if nNewBase > MIN_BASE
      nNewBase = nNewBase - 1
    else
      nNewBase = MAX_BASE
    endif
  endif

  // Set new base
  case vnBaseNum
  when BASE_1
    gnBase1 = nNewBase

  when BASE_2
    gnBase2 = nNewBase

  when BASE_3
    gnBase3 = nNewBase
  endcase

  // Value not out of range of 64 bit integer "--" and no error = "  "
  if Pos(LeftStr(gcU64, 2), "--  ") == 0 and Length(gcU64)
    // Build new value for display
    // nRetVal -> > 0 ok, Number of copied bytes
    //             < 0 Error, value is error code
    // This call is intentially used, because the TSE-funktion only works
    // on 32 bit signed values. This special kind of display needs unsigned
    // 64 bit values.
    nRetVal = ConvertBase10ToBaseX(nNewBase, gcU64, cConverted)

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
      Warn(cConverted + " Input was:" + gcU64)
      return()
    endif

    // Set new base and new converted value for display
    cConverted = Format(cConverted:BASE_FIELD_SIZE:"0")

    case vnBaseNum
    when BASE_1
      gnBase1       = nNewBase
      gcResultBase1 = cConverted

    when BASE_2
      gnBase2       = nNewBase
      gcResultBase2 = cConverted

    when BASE_3
      gnBase3       = nNewBase
      gcResultBase3 = cConverted
    endcase
  endif

end

///*****************************************************************************
///
/// FppEnableConstKeys
///
/// Will be activated when the constant list is opened.
/// Activates the footer and the keys.
///
///*****************************************************************************
proc FppEnableConstKeys()

  UnHook(FppEnableConstKeys)
  ListFooter("{CR}-Select {Esc}-Quit")

  if not Enable(FppConstKeys)
    Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
         Chr(13) + Chr(13) +
         "FppConstKeys could not be activated!" + Chr(13) +
         "List keymappings might not work as expected."
        )
  endif

  BreakHookChain()

end

///*****************************************************************************
///
/// FppDisableConstKeys
///
/// Will be called when the constant list is closed.
/// Deactivates the keys for constant list.
///
///*****************************************************************************
proc FppDisableConstKeys()

  UnHook(FppDisableConstKeys)
  Disable(FppConstKeys)
  BreakHookChain()

end

///*****************************************************************************
///
/// FppEnableErrorKeys
///
/// Will be activated when the error list is opened.
/// Activates the footer and the keys
///
///*****************************************************************************
proc FppEnableErrorKeys()

  UnHook(FppEnableErrorKeys)
  ListFooter("{Esc}-Quit")

  if not Enable(FppErrorKeys)
    Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
         Chr(13) + Chr(13) +
         "FppErrorKeys could not be activated!" + Chr(13) +
         "List keymappings might not work as expected."
        )
  endif

  BreakHookChain()

end

///*****************************************************************************
///
/// FppDisableErrorKeys
///
/// Will be called when the error list is closed.
/// Deactivates the keys for error list.
///
///*****************************************************************************
proc FppDisableErrorKeys()

  UnHook(FppDisableErrorKeys)
  Disable(FppErrorKeys)
  BreakHookChain()

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

  if not Enable(FppHelpKeys)
    Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
         Chr(13) + Chr(13) +
         "FppHelpKeys could not be activated!" + Chr(13) +
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
  Disable(FppHelpKeys)
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

  if not Enable(FppHelpTocKeys)
    Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
         Chr(13) + Chr(13) +
         "FppHelpTocKeys could not be activated!" + Chr(13) +
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
  Disable(FppHelpTocKeys)
  BreakHookChain()

end

///*****************************************************************************
///
/// FppEnableFuncKeys
///
/// Will be activated when the function list is opened.
/// Activates the footer and the keys.
///
///*****************************************************************************
proc FppEnableFuncKeys()

  UnHook(FppEnableFuncKeys)
  ListFooter("{F1}-Help {CR}-Select {Esc}-Quit")

  if not Enable(FppFuncKeys)
    Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
         Chr(13) + Chr(13) +
         "FppFuncKeys could not be activated!" + Chr(13) +
         "List keymappings might not work as expected."
        )
  endif

  BreakHookChain()

end

///*****************************************************************************
///
/// FppDisableFuncKeys
///
/// Will be called when the function list is closed.
/// Deactivates the keys for function list.
///
///*****************************************************************************
proc FppDisableFuncKeys()

  UnHook(FppDisableFuncKeys)
  Disable(FppFuncKeys)
  BreakHookChain()

end

///*****************************************************************************
///
/// FppEnableVarKeys
///
/// Will be activated when the variables list is opened.
/// Activates the footer and the keys.
///
///*****************************************************************************
proc FppEnableVarKeys()

  UnHook(FppEnableVarKeys)
  ListFooter("{CR}-Select {Del}-Delete {Ctrl Del}-Del.All {Esc}-Quit")

  if not Enable(FppVarKeys)
    Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
         Chr(13) + Chr(13) +
         "FppVarKeys could not be activated!" + Chr(13) +
         "List keymappings might not work as expected."
        )
  endif

  BreakHookChain()

end

///*****************************************************************************
///
/// FppDisableVarKeys
///
/// Will be called when the variables list is closed.
/// Deactivates the keys for variables list.
///
///*****************************************************************************
proc FppDisableVarKeys()

  UnHook(FppDisableVarKeys)
  Disable(FppVarKeys)
  BreakHookChain()

end

///*****************************************************************************
///
/// FppEnableCodeListKeys
///
/// Will be activated when the code list is opened.
/// Activates the footer and the keys.
///
///*****************************************************************************
proc FppEnableCodeListKeys()

  UnHook(FppEnableCodeListKeys)
  ListFooter("{F1}-Help {Esc}-Quit")

  if not Enable(FppCodeListKeys)
    Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
         Chr(13) + Chr(13) +
         "FppCodeListKeys could not be activated!" + Chr(13) +
         "List keymappings might not work as expected."
        )
  endif

  BreakHookChain()

end

///*****************************************************************************
///
/// FppDisableCodeListKeys
///
/// Will be called when the code list is closed.
/// Deactivates the keys for code list.
///
///*****************************************************************************
proc FppDisableCodeListKeys()

  UnHook(FppDisableCodeListKeys)
  Disable(FppCodeListKeys)
  BreakHookChain()

end

///*****************************************************************************
///
/// FppEnableKeys
///
/// Will be activated when the input line is opened.
/// Activates the keys.
///
///*****************************************************************************
proc FppEnableKeys()

  UnHook(FppEnableKeys)

  if not Enable(FppKeys)
    Warn(SplitPath(CurrMacroFilename(), _NAME_) + " " + gcMacVersion +
         Chr(13) + Chr(13) +
         "FppKeys could not be activated!" + Chr(13) +
         "Macro keymappings will not work as expected."
        )
  endif

  // Position the corsor in the input-line to stored values
  if gfRestoreCursor or gnErrorPos
    PushKey(<CursorRight>)
    PushKey(<CursorLeft>)

  // Normal input at first start of the macro
  else
    gnCursorPos = Length(gcExpression) + 1
    gnXOffset   = 0
  endif

  GotoPos(gnCursorPos)
  GotoXoffset(gnXOffset)

  BreakHookChain()

end

///*****************************************************************************
///
/// FppDisableKeys
///
/// Will be called when the input line is closed.
/// Deactivates the keys for input line.
///
///*****************************************************************************
proc FppDisableKeys()

  // Save position within the input-line for restore
  gnCursorPos = CurrPos()
  gnXOffset   = CurrXoffset()

  UnHook(FppDisableKeys)
  Disable(FppKeys)
  BreakHookChain()

end

///*****************************************************************************
///
/// FppEditTocMarker
///
/// Called from FppOptionsMenu.
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
/// FppSelectColorMenu
///
/// Called from FppOptionsMenu.
///
///*****************************************************************************
proc FppSelectColorMenu()

  FppStopColorMenuValues()          // Deactivate menu coloring
  Hook(_BEFORE_GETKEY_, FppBeforeGetkey)
  FppStartColorMenuValues()         // Activate menu coloring
  BufferVideo()

  while FppColorMenu()
    FppColorBaseXXX()
    FppColorBaseVal(WIN_BASE1_3_X + 7, WIN_BASE1, gnBase1)
    FppColorBaseVal(WIN_BASE1_3_X + 7, WIN_BASE2, gnBase2)
    FppColorBaseVal(WIN_BASE1_3_X + 7, WIN_BASE3, gnBase3)
    FppColorValues()
  endwhile

  FppStopColorMenuValues()          // Deactivate menu coloring
  UnHook(FppBeforeGetkey)
  UnBufferVideo()

end

///*****************************************************************************
///
/// FppShowInsertDest
///
/// Called from FppInsertMenu.
/// Returs the name of the destination.
///
/// Return:
/// string -> Name of the destination
///*****************************************************************************
string proc FppShowInsertDest()

  if gnInsertResAt == INS_RES_CURSOR
    return("Text Cursor")

  elseif gnInsertResAt == INS_RES_WCLIP
    return("Windows Clipboard")

  elseif gnInsertResAt == INS_RES_TSECLIP
    return("TSE Clipboard")
  endif

  return("???")

end

///*****************************************************************************
///
/// FppChangeInsertDest
///
/// Called from FppInsertDestMenu, changes the destination code.
///
/// Input:
/// vnDestination -> Destnation code
///
///*****************************************************************************
proc FppChangeInsertDest(integer vnDestination)

  if vnDestination == INS_RES_CURSOR
    gnInsertResAt = INS_RES_CURSOR

  elseif vnDestination == INS_RES_WCLIP
    gnInsertResAt = INS_RES_WCLIP

  else
    gnInsertResAt = INS_RES_TSECLIP
  endif

end

///*****************************************************************************
///
/// FppToggleStripLineDrawMode
///
/// Called from FppOptionsMenu.
///
///*****************************************************************************
proc FppToggleStripLineDrawMode()

  gnStriplineIn3D = not gnStriplineIn3D

end

///*****************************************************************************
///
/// FppToggleInputSingleCol
///
/// Called from FppOptionsMenu,
///
///*****************************************************************************
proc FppToggleInputSingleCol()

  gfInputLnSingleCol = not gfInputLnSingleCol

end

///*****************************************************************************
///
/// FppToggleModeXXX
///
/// Switches coloring mode between segmented and non segmented. Only used
/// with line Values: the xxx... in this line.
///
///*****************************************************************************
proc FppToggleModeXXX()

  gfOneColorXXX = not gfOneColorXXX

end

///*****************************************************************************
///
/// FppToggleIntGroup
///
/// Switches display format of integers.
///
///*****************************************************************************
proc FppToggleIntGroup()

  gfIntegerGrouped = not gfIntegerGrouped

end

///*****************************************************************************
///
/// FppToggleOldCurPos
///
/// Switches the restoring of the old cursor position at macro start.
///
///*****************************************************************************
proc FppToggleOldCurPos()

  gfStartupCurPos = not gfStartupCurPos

end

///*****************************************************************************
///
/// FppToggleWsFuncList
///
/// Switches automatic word search in function list.
///
///*****************************************************************************
proc FppToggleWsFuncList()

  gfWsFuncList = not gfWsFuncList

end

///*****************************************************************************
///
/// FppToggleWsVarList
///
/// Switches automatic word search in variables list.
///
///*****************************************************************************
proc FppToggleWsVarList()

  gfWsVarList = not gfWsVarList

end

///*****************************************************************************
///
/// FppToggleWsConList
///
/// Switches automatic word search in constants list.
///
///*****************************************************************************
proc FppToggleWsConList()

  gfWsConList = not gfWsConList

end

///*****************************************************************************
///
/// FppToggleWsHelp
///
/// Switches automatic word search in help file.
///
///*****************************************************************************
proc FppToggleWsHelp()

  gfWsHelp = not gfWsHelp

end

///*****************************************************************************
///
/// FppEnterDigits
///
/// Sets the number of digits for formatting the results.
///
///*****************************************************************************
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
/// FppSwitchFloatFormat
///
/// Switschen display format for float values.
///
///*****************************************************************************
proc FppSwitchFloatFormat()

  gnFloatFormat = gnFloatFormat + 1

  if gnFloatFormat >= FLOAT_DISP_MAX
    gnFloatFormat = FLOAT_NORMAL
  endif

end

///*****************************************************************************
///
/// FppSelectLocalization
///
/// Selects the localzation for results.
///
///*****************************************************************************
proc FppSelectLocalization()

  FppLocaleMenu()

end

///*****************************************************************************
///
/// FppGetResLocalization
///
/// Return the currently set localization for results
///
/// Return:
/// Text of the current result localization used
///*****************************************************************************
string proc FppGetResLocalization()

  case gnResLocale
  when LOCALE_NU
    return("Non-US")
  when LOCALE_SY
    return("System")
  when LOCALE_US
    return("US-Standard")
  endcase

  return("???")

end

///*****************************************************************************
///
/// FppSetLocale
///
/// Sets the value for result localization and changes the localization for the
/// currently displayed values.
///
/// Input:
/// vnLocale -> LOCALE_US, LOCALE_NU, LOCALE_SY
///
///*****************************************************************************
proc FppSetLocale(integer vnLocale)
  string cCurDecSep[5] = ""
  string cCurThoSep[5] = ""
  string cGrouping[10] = ""

  // nothing to do?
  if vnLocale == gnResLocale
    return()
  endif

  // Get current old locale separators
  FppGetLocaleData(gnResLocale, cCurDecSep, cCurThoSep, cGrouping)

  // Change decimal- and thousandseparator to US standard then apply new locale
  gcLFloat = StrReplace(cCurThoSep, gcLFloat, "")
  gcLFloat = StrReplace(cCurDecSep, gcLFloat, ".")
  gcLFloat = FppLocalizeResult(vnLocale, gcLFloat)

  if Pos(LeftStr(gcF64L, 2), "--  ") == 0 and Length(gcF64L)
    gcF64L = StrReplace(cCurThoSep, gcF64L, "")
    gcF64L = StrReplace(cCurDecSep, gcF64L, ".")
    gcF64L = FppLocalizeResult(vnLocale, gcF64L)
  endif

  if Pos(LeftStr(gcF32L, 2), "--  ") == 0 and Length(gcF32L)
    gcF32L = StrReplace(cCurThoSep, gcF32L, "")
    gcF32L = StrReplace(cCurDecSep, gcF32L, ".")
    gcF32L = FppLocalizeResult(vnLocale, gcF32L)
  endif

  // Only thousandseparator needs to be changed
  if Pos(LeftStr(gcU64L, 2), "--  ") == 0 and Length(gcU64L)
    gcU64L = StrReplace(cCurThoSep, gcU64L, "")
    gcU64L = FppLocalizeResult(vnLocale, gcU64L)

    gcS64L = StrReplace(cCurThoSep, gcS64L, "")
    gcS64L = FppLocalizeResult(vnLocale, gcS64L)

    gcU32L = StrReplace(cCurThoSep, gcU32L, "")
    gcU32L = FppLocalizeResult(vnLocale, gcU32L)

    gcS32L = StrReplace(cCurThoSep, gcS32L, "")
    gcS32L = FppLocalizeResult(vnLocale, gcS32L)

    gcU16L = StrReplace(cCurThoSep, gcU16L, "")
    gcU16L = FppLocalizeResult(vnLocale, gcU16L)

    gcS16L = StrReplace(cCurThoSep, gcS16L, "")
    gcS16L = FppLocalizeResult(vnLocale, gcS16L)

    gcU8L  = StrReplace(cCurThoSep, gcU8L,  "")
    gcU8L  = FppLocalizeResult(vnLocale, gcU8L)

    gcS8L  = StrReplace(cCurThoSep, gcS8L,  "")
    gcS8L  = FppLocalizeResult(vnLocale, gcS8L)
  endif

  // Set new locale
  gnResLocale = vnLocale

end

///*****************************************************************************
///
/// FppLocalizeResult
///
/// Localizes a string from 12345678.9 to for example 12,345,678.9
///
/// Input:
/// vnLocaleCode     -> LOCALE_US, LOCALE_NU, LOCALE_SY
/// vcResultToFormat -> Result to localize in US standard format (123456789.00)
///
/// Return:
/// cResult -> Localized Result
///*****************************************************************************
string proc FppLocalizeResult(integer vnLocaleCode, string vcResultToFormat)

  integer nCurrGoupVal = 0
  integer nNumEnd      = 0
  integer nGroupCount  = 1
  integer nExponentPos = 0
  integer nTemp        = 0

  string cBuffer[MAXSTRINGLEN] = ""
  string cSign[1]              = ""
  string cDecimalSep[5]  = ""
  string cThousandSep[5] = ""
  string cGrouping[10]   = ""

  FppGetLocaleData(vnLocaleCode, cDecimalSep, cThousandSep, cGrouping)

  // Check if grouping specified
  if StrFind("[1-9];[0]", cGrouping, "x") == 0
    return("Grouping not specified")
  endif

  // Copy all chars, filter spaces, replace decimalseparator with lokal separator
  for nTemp = 1 to Length(vcResultToFormat)
    // replace decimalseparator if one is present
    if vcResultToFormat[nTemp] == "."
      cBuffer = cBuffer + cDecimalSep

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
  nNumEnd = Pos(cDecimalSep, cBuffer)

  if nNumEnd == 0
    nNumEnd = Length(cBuffer) + 1
  endif

  if nExponentPos > 0
    if nExponentPos < nNumEnd
      nNumEnd = nExponentPos
    endif
  endif

  // Format result using grouping
  nCurrGoupVal = Val(GetToken(cGrouping, ";", nGroupCount))
  nGroupCount  = nGroupCount + 1

  // Insert thousandseparator according to grouping
  // Variable grouping is supported
  while nNumEnd > nCurrGoupVal
    nNumEnd = nNumEnd - nCurrGoupVal

    // Min 2 chars have to be there
    if nNumEnd > 1
      cBuffer = InsStr(cThousandSep, cBuffer, nNumEnd)

    // Reached the end
    else
      break
    endif

    // Determine next grouping value
    nTemp = Val(GetToken(cGrouping, ";", nGroupCount))

    // 0 marks the end, continue with last used value
    if nTemp > 0
      nGroupCount  = nGroupCount + 1
      nCurrGoupVal = nTemp
    endif
  endwhile

  // Insert sign if necessary
  if Length(cSign)
    return(cSign + cBuffer)
  endif

  return(cBuffer)

end

///*****************************************************************************
/// FppGetLocaleData
///
/// Query localization information and returns the data used for
/// Decimalseparator, Thousandseparator and Grouping.
///
/// Input:
/// vnLocaleCode -> LOCALE_US, LOCALE_NU, LOCALE_SY
/// rcDecSep     -> Data storage Decimalseparator
/// rcThoSep     -> Data storage Thousandseparator
/// rcGrouping   -> Data storage Grouping
///
/// Output:
/// rcDecimalSep  -> Data from query, in case of error empty string ""
/// rcThousandSep -> Data from query, in case of error empty string ""
/// rcGrouping    -> Data from query, in case of error empty string ""
///
/// Return:
/// TRUE/FALSE -> TRUE = Error occured, FALSE = ok
///*****************************************************************************
integer proc FppGetLocaleData(integer vnLocaleCode, var string rcDecSep, var string rcThoSep, var string rcGrouping)

  integer nError = FALSE

  // Determine used numberformat
  case vnLocaleCode
  // Non-US format
  when LOCALE_NU
    rcDecSep   = ","
    rcThoSep   = "."
    rcGrouping = "3;0"

  // System-Default format
  when LOCALE_SY
    // System Decimalseparator
    if FppGetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDECIMAL, rcDecSep)
      nError   = TRUE
      rcDecSep = "."
    endif

    // System Thousandseparator
    if FppGetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_STHOUSAND, rcThoSep)
      nError   = TRUE
      rcThoSep = ","
    endif

    // System Grouping
    if FppGetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SGROUPING, rcGrouping)
      nError   = TRUE
      rcGrouping = "3;0"
    endif

  // US format is used
  otherwise
    rcDecSep   = "."
    rcThoSep   = ","
    rcGrouping = "3;0"
  endcase

  return(nError)

end

///*****************************************************************************
/// FppGetLocaleInfo
///
/// Query localization information from the OS and returns the result in
/// rcInformation.
///
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
/// FppPickColor
///
/// Shows a selection window and lets you navigate to select a color.
///
/// Input:
/// vnColorToChange -> Code what color should be changed
/// vcHeadText      -> Text to show in header
///
///*****************************************************************************
proc FppPickColor(integer vnColorToChange, string vcHeadText)

  integer ni        = 0
  integer nj        = 0
  integer nColor    = 0
  integer nKeyCode  = 0
  integer nMouseX   = 0
  integer nMouseY   = 0
  integer nX_Width  = 0
  integer nxWin     = WhereXAbs()
  integer nyWin     = WhereYAbs() + 1
  integer nTextCol  = Query(MenuTextAttr)

  string cText[16 * COLOR_WIDTH]   = ""
  string cAttrib[16 * COLOR_WIDTH] = ""

  FppStopColorMenuValues()      // Deactivate menu coloring

  // Initialize temporary storage
  case vnColorToChange
  when PICK_COL_8_BIT
    nColor = gnCol8Bit

  when PICK_COL_16_BIT
    nColor = gnCol16Bit

  when PICK_COL_32_BIT
    nColor = gnCol32Bit

  when PICK_COL_64_BIT
    nColor = gnCol64Bit

  when PICK_COL_NORM
    nColor = gnColNormBase

  when PICK_COL_IEEE_SINGLE
    nColor = gnColIeeeSingle

  when PICK_COL_IEEE_DOUBLE
    nColor = gnColIeeeDouble

  when PICK_COL_FLOAT
    nColor = gnColFloat

  when PICK_COL_SIGN
    nColor = gnColSign

  when PICK_COL_EXPONENT
    nColor = gnColExponent

  when PICK_COL_MANTISSA
    nColor = gnColMantissa

  when PICK_COL_HELP_MARKER
    nColor = gnColHelpMarker

  when PICK_COL_INPUT_LINE
    nColor = gnColInputLine

  when PICK_COL_DEFAULT
    gnColHelpMarker = DEFAULT_COL_HELP_MARKER
    nTextCol        = nTextCol & 0xF0
    gnCol8Bit       = nTextCol | DEFAULT_COL_8BIT
    gnCol16Bit      = nTextCol | DEFAULT_COL_16BIT
    gnCol32Bit      = nTextCol | DEFAULT_COL_32BIT
    gnCol64Bit      = nTextCol | DEFAULT_COL_64BIT
    gnColNormBase   = nTextCol | DEFAULT_COL_NORMBASE
    gnColIeeeSingle = nTextCol | DEFAULT_COL_IEEESINGLE
    gnColIeeeDouble = nTextCol | DEFAULT_COL_IEEEDOUBLE
    gnColFloat      = nTextCol | DEFAULT_COL_FLOAT
    gnColSign       = nTextCol | DEFAULT_COL_SIGN
    gnColExponent   = nTextCol | DEFAULT_COL_EXPONENT
    gnColMantissa   = nTextCol | DEFAULT_COL_MANTISSA
    gnColInputLine  = DEFAULT_COL_INPUT_LINE

    FppStartColorMenuValues()     // Activate menu coloring
    return()

  otherwise
    Warn("Unknown command in FppPickColor()")
    FppStartColorMenuValues()     // Activate menu coloring
    return()
  endcase

  // Calculate window position
  if nxWin + (16 * COLOR_WIDTH + 2 - 1) > Query(ScreenCols)
    nxWin = Query(ScreenCols) - (16 * COLOR_WIDTH + 2 - 1)
  endif

  nX_Width = 16 * COLOR_WIDTH + 2 - 1

  if nyWin + (22 - 1) > Query(ScreenRows)
    nyWin = Query(ScreenRows) - (22 - 1)
  endif

  // Open window
  if PopWinOpen(nxWin, nyWin, nxWin + nX_Width, nyWin + (22 - 1), 1, vcHeadText, Query(MenuBorderAttr)) == FALSE
    FppStartColorMenuValues()     // Activate menu coloring
    return()
  endif

  WindowFooter("{Cur-Keys}-Move {CR}-Select {Esc}-Exit")

  BufferVideo()

  // Show colors to select from
  for ni = 0 to 255 by 16
    cText = ""
    cAttrib = ""

    for nj = 0 to 15
      cText   = cText   + Format(ni + nj:COLOR_WIDTH:"0":16)
      cAttrib = cAttrib + Format("":COLOR_WIDTH:Chr(ni + nj))
    endfor

    PutStrAttrXY(1, ni / 16 + 1, cText, cAttrib)
  endfor

  ni = (nColor mod 16)
  nj = nColor / 16

  // Last lines show how it looks
  PutStrXY(1, 22 - 5, Format("64-32-16-8-Bit Normal-Base Float":-(nX_Width - 1)), nTextCol)
  PutStrXY(1, 22 - 4, Format("xxxxxxxx Single Double S Exp Man":-(nX_Width - 1)), nTextCol)
  PutStrXY(1, 22 - 3, Format("Input-Line 123456":-(nX_Width - 1)), nTextCol)
  PutStrXY(1, 22 - 2, Format("Help, TOC Marker Line":-(nX_Width - 1)),  nTextCol)

  UnBufferVideo()

  loop
    BufferVideo()

    // Put color to text lines
    PutAttrXY(1,  22 - 5, iif(vnColorToChange == PICK_COL_64_BIT, nColor, gnCol64Bit), 2)
    PutAttrXY(4,  22 - 5, iif(vnColorToChange == PICK_COL_32_BIT, nColor, gnCol32Bit), 2)
    PutAttrXY(7,  22 - 5, iif(vnColorToChange == PICK_COL_16_BIT, nColor, gnCol16Bit), 2)
    PutAttrXY(10, 22 - 5, iif(vnColorToChange == PICK_COL_8_BIT, nColor, gnCol8Bit), 1)
    PutAttrXY(16, 22 - 5, iif(vnColorToChange == PICK_COL_NORM, nColor, gnColNormBase), 11)
    PutAttrXY(28, 22 - 5, iif(vnColorToChange == PICK_COL_FLOAT, nColor, gnColFloat), 5)

    PutAttrXY(1,  22 - 4, iif(vnColorToChange == PICK_COL_64_BIT, nColor, gnCol64Bit), 4)
    PutAttrXY(5,  22 - 4, iif(vnColorToChange == PICK_COL_32_BIT, nColor, gnCol32Bit), 2)
    PutAttrXY(7,  22 - 4, iif(vnColorToChange == PICK_COL_16_BIT, nColor, gnCol16Bit), 1)
    PutAttrXY(8,  22 - 4, iif(vnColorToChange == PICK_COL_8_BIT, nColor, gnCol8Bit), 1)
    PutAttrXY(10, 22 - 4, iif(vnColorToChange == PICK_COL_IEEE_SINGLE, nColor, gnColIeeeSingle), 6)
    PutAttrXY(17, 22 - 4, iif(vnColorToChange == PICK_COL_IEEE_DOUBLE, nColor, gnColIeeeDouble), 6)
    PutAttrXY(24, 22 - 4, iif(vnColorToChange == PICK_COL_SIGN, nColor, gnColSign), 1)

    PutAttrXY(26, 22 - 4, iif(vnColorToChange == PICK_COL_EXPONENT, nColor, gnColExponent), 3)
    PutAttrXY(30, 22 - 4, iif(vnColorToChange == PICK_COL_MANTISSA, nColor, gnColMantissa), 3)
    PutAttrXY(1,  22 - 3, iif(vnColorToChange == PICK_COL_INPUT_LINE, nColor, gnColInputLine), nX_Width - 1)
    PutAttrXY(1,  22 - 2, iif(vnColorToChange == PICK_COL_HELP_MARKER, nColor, gnColHelpMarker), nX_Width - 1)

    // Position Cursor
    GotoXY((ni + 1) * COLOR_WIDTH, nj + 1)

    UnBufferVideo()

    // Wait for key
    nKeyCode = GetKey()

    // Evaluate key
    case nKeyCode

    // ok
    when <Enter>, <GreyEnter>
LBL_OK_SET_COLOR:
      // Set new color
      nColor = nj * 16 + ni

      case vnColorToChange
      when PICK_COL_8_BIT
        gnCol8Bit = nColor

      when PICK_COL_16_BIT
        gnCol16Bit = nColor

      when PICK_COL_32_BIT
        gnCol32Bit = nColor

      when PICK_COL_64_BIT
        gnCol64Bit = nColor

      when PICK_COL_NORM
        gnColNormBase = nColor

      when PICK_COL_IEEE_SINGLE
        gnColIeeeSingle = nColor

      when PICK_COL_IEEE_DOUBLE
        gnColIeeeDouble = nColor

      when PICK_COL_FLOAT
        gnColFloat = nColor

      when PICK_COL_SIGN
        gnColSign = nColor

      when PICK_COL_EXPONENT
        gnColExponent = nColor

      when PICK_COL_MANTISSA
        gnColMantissa = nColor

      when PICK_COL_HELP_MARKER
        gnColHelpMarker = nColor
        WriteProfileInt(gcTSE_HELP_KEY, gcColHelpMarker, gnColHelpMarker)

      when PICK_COL_INPUT_LINE
        gnColInputLine = nColor
      endcase

      break

    // Quit
    when <Escape>, <RightBtn>
      break

    // Line up
    when <CursorUp>, <GreyCursorUp>
      if nj > 0
        nj = nj - 1
      else
        nj = 15
      endif

    // Line down
    when <CursorDown>, <GreyCursorDown>
      if nj < 15
        nj = nj + 1
      else
        nj = 0
      endif

#ifdef WHEEL_IS_PRESENT
    // Line up with automatic switch to left when reached at top
    when <WheelUp>
      if nj > 0
        nj = nj - 1
      else
        nj = 15

        if ni > 0
          ni = ni - 1
        else
          ni = 15
        endif
      endif

    // Line down with automatic switch to right when reached at bottom
    when <WheelDown>
      if nj < 15
        nj = nj + 1
      else
        nj = 0

        if ni < 15
          ni = ni + 1
        else
          ni = 0
        endif
      endif
#endif

    // Column left
    when <CursorLeft>, <GreyCursorLeft>
      if ni > 0
        ni = ni - 1
      else
        ni = 15
      endif

    // Column right
    when <CursorRight>, <GreyCursorRight>
      if ni < 15
        ni = ni + 1
      else
        ni = 0
      endif

    // First position
    when <Home>, <GreyHome>
      ni = 0
      nj = 0

    // Last position
    when <End>, <GreyEnd>
      ni = 15
      nj = 15

    // Short click position on color, no selection
    // Long click selects
    when <LeftBtn>, <CenterBtn>
      nMouseX = Query(MouseX) - nxWin
      nMouseY = Query(MouseY) - nyWin
      // Only if pointer is in area
      if (    (nMouseX > 0 and nMouseX < (16 * COLOR_WIDTH + 2 - 1))
          and
              (nMouseY > 0 and nMouseY < (18 - 1))
         )
        // Position on color
        ni = ((nMouseX + COLOR_WIDTH - 1) / COLOR_WIDTH) - 1
        nj = nMouseY - 1

        // Long click selects
        if WaitForMouseEvent(_MOUSE_RELEASE_ | _MOUSE_HOLD_TIME_) == _MOUSE_HOLD_TIME_
          // ok
          goto LBL_OK_SET_COLOR
        endif
      endif
    endcase

    // Set changed color to show in text how it looks
    nColor = nj * 16 + ni
  endloop

  PopWinClose()

  FppStartColorMenuValues()     // Activate menu coloring

end

///*****************************************************************************
///
/// FppColorBaseVal
///
/// Coloring of displayed base values if the base is set to 2 or 16.
///
/// Input:
/// vnX    -> x-coordinate where area starts
/// vnY    -> y-coordinate where area starts
/// vnBase -> current set base for value
///
///*****************************************************************************
proc FppColorBaseVal(integer vnX, integer vnY, integer vnBase)

  // Coloring only takes place if no error is present
  if gnErrorPos
    return()
  endif

  BufferVideo()

  // Coloring only if base is 2 or 16
  case vnBase
  when 2
    PutAttrXY(vnX,      vnY, gnCol64Bit, 32)
    PutAttrXY(vnX + 32, vnY, gnCol32Bit, 16)
    PutAttrXY(vnX + 48, vnY, gnCol16Bit,  8)
    PutAttrXY(vnX + 56, vnY, gnCol8Bit,   8)

  when 16
    PutAttrXY(vnX,      vnY, gnCol64Bit, 8)
    PutAttrXY(vnX +  8, vnY, gnCol32Bit, 4)
    PutAttrXY(vnX + 12, vnY, gnCol16Bit, 2)
    PutAttrXY(vnX + 14, vnY, gnCol8Bit,  2)

  otherwise
    PutAttrXY(vnX, vnY, gnColNormBase, Val(GetToken(gcBaseLen, " ", vnBase)))
  endcase

  UnBufferVideo()

end

///*****************************************************************************
///
/// FppColorBaseXXX
///
/// Coloring of statically displayed text (64-Bit...) with associated colors.
///
///*****************************************************************************
proc FppColorBaseXXX()

  BufferVideo()

  // Color whole area with one color
  if gfOneColorXXX
    // 64 Bit
    PutAttrXY(4 + 14, WIN_UN_SI_HEAD, gnCol64Bit, 8)

    // 32 Bit
    PutAttrXY(4 + 45, WIN_UN_SI_HEAD, gnCol32Bit, 4)

    // 16 Bit
    PutAttrXY(4 + 61, WIN_UN_SI_HEAD, gnCol16Bit, 2)

  // Color each part of the area with different color
  else
    // 64 Bit
    PutAttrXY(4 + 14, WIN_UN_SI_HEAD, gnCol64Bit, 4)
    PutAttrXY(4 + 18, WIN_UN_SI_HEAD, gnCol32Bit, 2)
    PutAttrXY(4 + 20, WIN_UN_SI_HEAD, gnCol16Bit, 1)
    PutAttrXY(4 + 21, WIN_UN_SI_HEAD, gnCol8Bit,  1)

    // 32 Bit
    PutAttrXY(4 + 45, WIN_UN_SI_HEAD, gnCol32Bit, 2)
    PutAttrXY(4 + 47, WIN_UN_SI_HEAD, gnCol16Bit, 1)
    PutAttrXY(4 + 48, WIN_UN_SI_HEAD, gnCol8Bit,  1)

    // 16 Bit
    PutAttrXY(4 + 61, WIN_UN_SI_HEAD, gnCol16Bit, 1)
    PutAttrXY(4 + 62, WIN_UN_SI_HEAD, gnCol8Bit,  1)
  endif

  // 8 Bit
  PutAttrXY(4 + 70, WIN_UN_SI_HEAD, gnCol8Bit, 1)

  UnBufferVideo()

end

///*****************************************************************************
///
/// FppColorValues
///
/// Coloring of values with their associated colors.
///
///*****************************************************************************
proc FppColorValues()

  integer nTemp = 0

  // coloring only takes place if no error is present
  if gnErrorPos
    return()
  endif

  BufferVideo()

  // Integer grouping
  if gfIntegerGrouped
    // Integer unsigned
    PutAttrXY(2 + 10, WIN_UNSIGNED, gnCol64Bit, Length(gcU64L))
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2, WIN_UNSIGNED, gnCol32Bit, Length(gcU32L))
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_32_SIZE + 2, WIN_UNSIGNED, gnCol16Bit, Length(gcU16L))
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_32_SIZE + 2 + RESULT_16_SIZE + 2, WIN_UNSIGNED, gnCol8Bit, Length(gcU8L))

    // Integer signed
    PutAttrXY(2 + 10, WIN_SIGNED, gnCol64Bit, Length(gcS64L))
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2, WIN_SIGNED, gnCol32Bit, Length(gcS32L))
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_32_SIZE + 2, WIN_SIGNED, gnCol16Bit, Length(gcS16L))
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_32_SIZE + 2 + RESULT_16_SIZE + 2, WIN_SIGNED, gnCol8Bit, Length(gcS8L))

  // Integer without grouping
  else
    // Integer unsigned
    PutAttrXY(2 + 10, WIN_UNSIGNED, gnCol64Bit, Length(gcU64))
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2, WIN_UNSIGNED, gnCol32Bit, Length(gcU32))
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_32_SIZE + 2, WIN_UNSIGNED, gnCol16Bit, Length(gcU16))
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_32_SIZE + 2 + RESULT_16_SIZE + 2, WIN_UNSIGNED, gnCol8Bit, Length(gcU8))

    // Integer signed
    PutAttrXY(2 + 10, WIN_SIGNED, gnCol64Bit, Length(gcS64))
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2, WIN_SIGNED, gnCol32Bit, Length(gcS32))
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_32_SIZE + 2, WIN_SIGNED, gnCol16Bit, Length(gcS16))
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_32_SIZE + 2 + RESULT_16_SIZE + 2, WIN_SIGNED, gnCol8Bit, Length(gcS8))
  endif

  // Color whole area with one color
  if gfOneColorXXX
    // Hex 64
    PutAttrXY(2 + 10, WIN_U64_HEX, gnCol64Bit, RESULT_U64_HEX_SIZE)

    // Hex 32
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2, WIN_U64_HEX, gnCol32Bit, RESULT_U64_HEX_SIZE / 2)

    // Hex 16
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_32_SIZE + 2, WIN_U64_HEX, gnCol16Bit, RESULT_U64_HEX_SIZE / 4)

    // Hex 8
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_32_SIZE + 2 + RESULT_16_SIZE + 2, WIN_U64_HEX, gnCol8Bit, RESULT_U64_HEX_SIZE / 8)

  // Color each part of the area with different color
  else
    // Hex 64
    PutAttrXY(2 + 10, WIN_U64_HEX, gnCol64Bit, RESULT_U64_HEX_SIZE / 2)
    PutAttrXY(2 + 10 + RESULT_U64_HEX_SIZE / 2, WIN_U64_HEX, gnCol32Bit, RESULT_U64_HEX_SIZE / 4)
    PutAttrXY(2 + 10 + RESULT_U64_HEX_SIZE / 2 + RESULT_U64_HEX_SIZE / 4, WIN_U64_HEX, gnCol16Bit, RESULT_U64_HEX_SIZE / 8)
    PutAttrXY(2 + 10 + RESULT_U64_HEX_SIZE / 2 + RESULT_U64_HEX_SIZE / 4 + RESULT_U64_HEX_SIZE / 8, WIN_U64_HEX, gnCol8Bit, RESULT_U64_HEX_SIZE / 8)

    // Hex 32
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2, WIN_U64_HEX, gnCol32Bit, RESULT_U64_HEX_SIZE / 4)
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_U64_HEX_SIZE / 4, WIN_U64_HEX, gnCol16Bit, RESULT_U64_HEX_SIZE / 8)
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_U64_HEX_SIZE / 4 + RESULT_U64_HEX_SIZE / 8, WIN_U64_HEX, gnCol8Bit, RESULT_U64_HEX_SIZE / 8)

    // Hex 16
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_32_SIZE + 2, WIN_U64_HEX, gnCol16Bit, RESULT_U64_HEX_SIZE / 8)
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_32_SIZE + 2 + RESULT_U64_HEX_SIZE / 8, WIN_U64_HEX, gnCol8Bit, RESULT_U64_HEX_SIZE / 8)

    // Hex 8
    PutAttrXY(2 + 10 + RESULT_64_SIZE + 2 + RESULT_32_SIZE + 2 + RESULT_16_SIZE + 2, WIN_U64_HEX, gnCol8Bit, RESULT_U64_HEX_SIZE / 8)
  endif

  // IEEE single
  PutAttrXY(2 + 8, WIN_IEEE_SINGLE, gnColIeeeSingle, RESULT_F32_SIZE)
  PutAttrXY(2 + 7 + RESULT_F32_SIZE + 26, WIN_IEEE_SINGLE, gnColIeeeSingle,
            Length(iif(gnFloatFormat == FLOAT_NORMAL, gcF32D, iif(gnFloatFormat == FLOAT_SCIENTIFIC, gcF32S, gcF32L))))

  // IEEE double
  PutAttrXY(2 + 8, WIN_IEEE_DOUBLE, gnColIeeeDouble, RESULT_F64_SIZE)
  PutAttrXY(2 + 7 + RESULT_F64_SIZE + 18, WIN_IEEE_DOUBLE, gnColIeeeDouble,
            Length(iif(gnFloatFormat == FLOAT_NORMAL, gcF64D, iif(gnFloatFormat == FLOAT_SCIENTIFIC, gcF64S, gcF64L))))

  // IEEE Bin Single
  PutAttrXY(5 + 5, WIN_IEEE_S_BIN, gnColSign, 1)
  PutAttrXY(5 + 4 + 2, WIN_IEEE_S_BIN, gnColExponent, 8)
  PutAttrXY(5 + 4 + 1 + 9, WIN_IEEE_S_BIN, gnColMantissa, 23)

  // IEEE Bin Double
  PutAttrXY(5 + 5, WIN_IEEE_D_BIN, gnColSign, 1)
  PutAttrXY(5 + 4 + 2, WIN_IEEE_D_BIN, gnColExponent, 11)
  PutAttrXY(5 + 4 + 1 + 12, WIN_IEEE_D_BIN, gnColMantissa, 52)

  // Float
  nTemp = Length(iif(gnFloatFormat == FLOAT_NORMAL, gcFloat, iif(gnFloatFormat == FLOAT_SCIENTIFIC, gcSFloat, gcLFloat)))

  if nTemp > RESULT_FLOAT_SIZE
    PutAttrXY(2 + 10, WIN_DECIMAL, gnColFloat, RESULT_FLOAT_SIZE)
    nTemp = nTemp - RESULT_FLOAT_SIZE
    PutAttrXY(2 + 10, WIN_DECIMAL + 1, gnColFloat, Min(nTemp, RESULT_FLOAT_SIZE))
  else
    PutAttrXY(2 + 10, WIN_DECIMAL, gnColFloat, nTemp)
  endif

  UnBufferVideo()

end

///*****************************************************************************
///
/// FppOpenWindow
///
/// Opens the main window writes constant parts and determines coordinates.
///
/// Input:
/// vnXl -> X top left
/// vnYt -> Y top left
/// vnXr -> X bottom right
/// vnYb -> Y bottom right
///
/// Return:
/// TRUE  -> Window could be opened
/// FALSE -> Error while opening window
///*****************************************************************************
integer proc FppOpenWindow(integer vnXl, integer vnYt, integer vnXr, integer vnYb)

  string  cBuffer[WIN_WIDTH - 1] = ""

  integer nOldAttr  = 0
  integer nTextAttr = Query(MenuTextAttr)
  integer nLtrAttr  = Query(MenuTextLtrAttr)

  // Open window
  if PopWinOpen(vnXl, vnYt, vnXr, vnYb, Query(CurrWinBorderType),
                SplitPath(CurrMacroFilename(), _NAME_),
                Query(MenuBorderAttr)) == FALSE
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_) + " Error",
           "FppOpenWindow()" + Chr(13) + "Unable to open pop-up window."
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

  // Attention:
  // When changing key assignments the shortcuts below {@*}-*** must also be
  // changed accordingly!
  WindowFooter("{CR}-Parse {@F}-Func {@V}-Var {@T}-Con {@L}-Lst {@P}-Paste {@S}-Sf {@I}-Ig {@O}-Opt {F1}-Help")

  // Determine positions of keys in window and store it for later mouse handling
  // of the line.
  GetStrXY(1, WIN_HEIGHT - 1, cBuffer, WIN_WIDTH - 1)

  // Attention:
  // When changing shortcuts {@*}- the above footer line must be changed
  // accordingly!
  //
  // Determine positions for mouse handling
  gnCR_X    = Pos("CR-", cBuffer)
  gnAlt_F_X = Pos("@F-", cBuffer)
  gnAlt_V_X = Pos("@V-", cBuffer)
  gnAlt_L_X = Pos("@L-", cBuffer)
  gnAlt_T_X = Pos("@T-", cBuffer)
  gnAlt_P_X = Pos("@P-", cBuffer)
  gnAlt_S_X = Pos("@S-", cBuffer)
  gnAlt_O_X = Pos("@O-", cBuffer)
  gnAlt_I_X = Pos("@I-", cBuffer)
  gnF1_X    = Pos("F1-", cBuffer)

  // Write constant parts of the window only once
  PutStrXY(WIN_BASE1_3_X, WIN_BASE1, "-+", nLtrAttr)
  PutStrXY(WIN_BASE1_3_X, WIN_BASE2, "-+", nLtrAttr)
  PutStrXY(WIN_BASE1_3_X, WIN_BASE3, "-+", nLtrAttr)

  PutStrXY(4, WIN_UN_SI_HEAD,
           Format("Values: ", "64-Bitxxxxxxxx":-RESULT_64_SIZE, "  ", "32-Bitxxxx":-RESULT_32_SIZE, "  ", "16-Bitxx":-RESULT_16_SIZE, "  8-Bitx"),
           nTextAttr)

  PutStrXY(2, WIN_UNSIGNED, "Unsigned:", nTextAttr)
  PutStrXY(2, WIN_SIGNED,   "  Signed:", nTextAttr)
  PutStrXY(2, WIN_U64_HEX,  "     Hex:", nTextAttr)

  PutStrXY(2, WIN_IEEE_HEAD, "IEEE    Hex                              Decimal", nTextAttr)

  PutStrXY(2, WIN_IEEE_SINGLE, Format("Single: ", "":-RESULT_F32_SIZE), nTextAttr)
  PutStrXY(2, WIN_IEEE_DOUBLE, Format("Double: ", "":-RESULT_F64_SIZE), nTextAttr)
  PutStrXY(5, WIN_IEEE_S_BIN,  Format("Bin: ", "":-RESULT_F32_BIN_SIZE), nTextAttr)
  PutStrXY(5, WIN_IEEE_D_BIN,  Format("Bin: ", "":-RESULT_F64_BIN_SIZE), nTextAttr)
  PutStrXY(2, WIN_DECIMAL, "Result- :", nTextAttr)

  PutStrXY(2, WIN_TEXT, "Enter Expression:", nTextAttr)

  FppColorBaseXXX()
  FppDrawStripLines()
  UnBufferVideo()
  return(TRUE)

end

///*****************************************************************************
///
/// FppDisplayInteger
///
/// Writes the integer values in relation to gfIntegerGrouped.
///
///*****************************************************************************
proc FppDisplayInteger()

  integer nTextAttr = Query(MenuTextAttr)

  BufferVideo()

  // Integer Grouping
  if gfIntegerGrouped
    // Integer unsigned
    PutStrXY(2 + 10, WIN_UNSIGNED,
             Format(gcU64L:-RESULT_64_SIZE, "  ", gcU32L:-RESULT_32_SIZE, "  ", gcU16L:-RESULT_16_SIZE, "  ", gcU8L:-RESULT_8_SIZE),
             nTextAttr)

    // Integer signed
    PutStrXY(2 + 10, WIN_SIGNED,
             Format(gcS64L:-RESULT_64_SIZE, "  ", gcS32L:-RESULT_32_SIZE, "  ", gcS16L:-RESULT_16_SIZE, "  ", gcS8L:-RESULT_8_SIZE),
             nTextAttr)

  // Integer normal
  else
    // Integer unsigned
    PutStrXY(2 + 10, WIN_UNSIGNED,
             Format(gcU64:-RESULT_64_SIZE, "  ", gcU32:-RESULT_32_SIZE, "  ", gcU16:-RESULT_16_SIZE, "  ", gcU8:-RESULT_8_SIZE),
             nTextAttr)

    // Integer signed
    PutStrXY(2 + 10, WIN_SIGNED,
             Format(gcS64:-RESULT_64_SIZE, "  ", gcS32:-RESULT_32_SIZE, "  ", gcS16:-RESULT_16_SIZE, "  ", gcS8:-RESULT_8_SIZE),
             nTextAttr)
  endif

  // Hex
  PutStrXY(2 + 10, WIN_U64_HEX,
           Format(gcU64Hex:-RESULT_64_SIZE, "  ",
                  RightStr(gcU64Hex, 8):-RESULT_32_SIZE, "  ", RightStr(gcU64Hex, 4):-RESULT_16_SIZE, "  ", RightStr(gcU64Hex, 2):-RESULT_8_SIZE),
           nTextAttr)

  UnBufferVideo()

end

///*****************************************************************************
///
/// FppDisplayFloat
///
/// Writes the float values in relation to gnFloatFormat.
///
///*****************************************************************************
proc FppDisplayFloat()

  integer nTextAttr = Query(MenuTextAttr)
  string  cDisplay[MAXSTRINGLEN] = ""

  BufferVideo()

  // IEEE Single
  PutStrXY(2 + 8, WIN_IEEE_SINGLE, Format(gcF32:-RESULT_F32_SIZE), nTextAttr)
  PutStrXY(2 + 7 + RESULT_F32_SIZE + 26, WIN_IEEE_SINGLE,
           Format(iif(gnFloatFormat == FLOAT_NORMAL, gcF32D, iif(gnFloatFormat == FLOAT_SCIENTIFIC, gcF32S, gcF32L)):-RESULT_F32D_SIZE),
           nTextAttr)

  // IEEE Double
  PutStrXY(2 + 8, WIN_IEEE_DOUBLE, Format(gcF64:-RESULT_F64_SIZE), nTextAttr)
  PutStrXY(2 + 7 + RESULT_F64_SIZE + 18, WIN_IEEE_DOUBLE,
           Format(iif(gnFloatFormat == FLOAT_NORMAL, gcF64D, iif(gnFloatFormat == FLOAT_SCIENTIFIC, gcF64S, gcF64L)):-RESULT_F64D_SIZE),
           nTextAttr)

  // IEEE Bin Single
  PutStrXY(5 + 5, WIN_IEEE_S_BIN, Format(gcF32Bin:-RESULT_F32_BIN_SIZE), nTextAttr)

  // IEEE Bin Double
  PutStrXY(5 + 5, WIN_IEEE_D_BIN, Format(gcF64Bin:-RESULT_F64_BIN_SIZE), nTextAttr)

  // Result Float
  cDisplay = iif(gnFloatFormat == FLOAT_NORMAL, gcFloat, iif(gnFloatFormat == FLOAT_SCIENTIFIC, gcSFloat, gcLFloat))

  PutStrXY(2 + 10, WIN_DECIMAL, Format(SubStr(cDisplay, 1, RESULT_FLOAT_SIZE):-RESULT_FLOAT_SIZE), nTextAttr)
  PutStrXY(2 + 10, WIN_DECIMAL + 1,
           Format(SubStr(cDisplay, RESULT_FLOAT_SIZE + 1, MAXSTRINGLEN):-RESULT_FLOAT_SIZE), nTextAttr)

  UnBufferVideo()

end

///*****************************************************************************
///
/// FppDrawStripLines
///
/// Draws the striplines.
///
///*****************************************************************************
proc FppDrawStripLines()

  integer nTextAttr = Query(MenuTextAttr)
  integer nFlags    = iif(gnStriplineIn3D, _USE3D_, 0)

  BufferVideo()

  PutOemStrXY(1, WIN_LINE_1, Format("":WIN_WIDTH - 1:chr(196)), nTextAttr, nFlags)
  PutOemStrXY(1, WIN_LINE_2, Format("":WIN_WIDTH - 1:chr(196)), nTextAttr, nFlags)
  PutOemStrXY(1, WIN_LINE_3, Format("":WIN_WIDTH - 1:chr(196)), nTextAttr, nFlags)
  PutOemStrXY(1, WIN_LINE_4, Format("":10:chr(196)), nTextAttr, nFlags)

  UnBufferVideo()

end

///*****************************************************************************
///
/// FppCheckAndSetMouseAction
///
/// This procedure is called from inside of an active read!
///
/// Determines the mouse action according to the coordinates and does the
/// necessary arrangements before the action takes place.
///
/// Input:
/// vnButton -> Which button is pressed:
///             <MBUT_LEFT>, <MBUT_RIGHT>, <MBUT_XBUT_1>, <MBUT_XBUT_2>
/// vnX      -> X mouse position relative to input line
/// vnY      -> Y mouse position relative to input line
///
/// Return:
/// nMouseAction -> Exit code. For example: EP_ACCEPTED, EP_FUNCTION_LIST...
///*****************************************************************************
integer proc FppCheckAndSetMouseAction(integer vnButton, integer vnX, integer vnY)

  integer nMouseAction = EP_NO_ACTION

  case WaitForMouseEvent(_MOUSE_RELEASE_ | _MOUSE_HOLD_TIME_)
  // Short click
  when _MOUSE_RELEASE_
    // Actions are dependent of the pressed button
    case vnButton
    // Position the cursor in the input-line
    when MBUT_LEFT
      // Move the cursor in the input-line
      if vnY == 1 and (vnX in 1 .. (Query(PopWinCols)))
        GotoPos(CurrXoffset() + vnX)

      // Position of the footer line relative to input line
      elseif vnY == (WIN_HEIGHT - WIN_EXPRESSION)
        // If necessary switch exit code EP_NO_ACTION to an exit code related
        // to the coordinates.
        case vnX
        when gnCR_X, gnCR_X + 1           // Click on C or R
          nMouseAction = EP_ACCEPTED

        when gnAlt_F_X, gnAlt_F_X + 1     // Click on @ or F
          FppGetWordFromInput(GET_WORD_FUNC)
          nMouseAction = EP_FUNCTION_LIST

        when gnAlt_V_X, gnAlt_V_X + 1     // Click on @ or V
          FppGetWordFromInput(GET_WORD_VAR)
          nMouseAction = EP_VARLIST

        when gnAlt_L_X, gnAlt_L_X + 1     // Click on @ or L
          nMouseAction = EP_CODELIST

        when gnAlt_T_X, gnAlt_T_X + 1     // Click on @ or T
          FppGetWordFromInput(GET_WORD_CONST)
          nMouseAction = EP_CONST_LIST

        when gnAlt_P_X, gnAlt_P_X + 1     // Click on @ or P
          nMouseAction = EP_INSERT_MENU

        when gnAlt_S_X, gnAlt_S_X + 1     // Click on @ or S
          nMouseAction = EP_FLOAT_FORMAT

        when gnAlt_O_X, gnAlt_O_X + 1     // Click on @ or O
          nMouseAction = EP_OPTION_MENU

        when gnAlt_I_X, gnAlt_I_X + 1     // Click on @ or I
          nMouseAction = EP_INTEGER_FORMAT

        when gnF1_X, gnF1_X + 1           // Click on F or 1
          FppGetWordFromInput(GET_WORD_HELP)
          nMouseAction = EP_FPP_HELP
        endcase

      // Check if base or display-format is clicked
      elseif (vnY in 65519 .. 65521)
        // Base down click on "-"
        if vnX == WIN_BASE1_3_X
          case vnY
          when 65519
            nMouseAction = EP_BASE_1_DOWN

          when 65520
            nMouseAction = EP_BASE_2_DOWN

          when 65521
            nMouseAction = EP_BASE_3_DOWN
          endcase

        // Base up click on "+"
        elseif vnX == WIN_BASE1_3_X + 1
          case vnY
          when 65519
            nMouseAction = EP_BASE_1_UP

          when 65520
            nMouseAction = EP_BASE_2_UP

          when 65521
            nMouseAction = EP_BASE_3_UP
          endcase
        endif

        // Displayformat float, click on "N/G/S"
      elseif vnX == WIN_FORMAT_FLOAT_X and vnY == 65534
        nMouseAction = EP_FLOAT_FORMAT
      endif

    // Position the cursor in the input-line *and* delete to end of line,
    // including char under cursor
    when MBUT_RIGHT
      if vnY == 1 and (vnX in 1 .. (Query(PopWinCols)))
        GotoPos(CurrXoffset() + vnX)
        DelToEol()
      endif

    // Go word left
    when MBUT_XBUT_1
      WordLeft()

    // Go word right
    when MBUT_XBUT_2
      WordRight()
    endcase

  // Long click
  when _MOUSE_HOLD_TIME_
    // Actions are dependent of the pressed button
    case vnButton
    // Delete to beginning of line, except char under cursor
    when MBUT_LEFT
      FppDelToLeft()

    // Delete to end of line, including char under cursor
    when MBUT_RIGHT
      DelToEol()

    // Delete word left
    when MBUT_XBUT_1
      DelLeftWord()

    // Delete word right
    when MBUT_XBUT_2
      DelRightWord()
    endcase
  endcase

  return(nMouseAction)

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

  string  cTop[8]   = "--------"
  string  cCen[8]   = "FppShell"
  string  cBot[8]   = "========"
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

  PutStrXY(18, 7, cTop, nTextAttr)
  PutStrXY(18, 8, cCen, nTextAttr)
  PutStrXY(18, 9, cBot, nTextAttr)

  while WaitForKeyPressed(100, FALSE) == 0
    nVPos = Random(1, 8)

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

    PutStrXY(18, 7, cTop, nTextAttr)
    PutStrXY(18, 8, cCen, nTextAttr)
    PutStrXY(18, 9, cBot, nTextAttr)
  endwhile

  Set(Attr, nOldAttr)
  PopWinClose()
  SetCursorOn()

  // Clear keyboard buffer to keep menu open
  while KeyPressed()
    GetKey()
  endwhile

end


