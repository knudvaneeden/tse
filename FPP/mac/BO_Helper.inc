///******************************************************************************
///
/// BO_Helper.inc
///
/// Author:        Eckhard Hillmann
///
/// First created: 18. January 2022
///
/// ****************************************************************************
/// This software is provided "as is" without express or implied warranty.
/// ****************************************************************************
///
/// History:
///
/// Jan 2025: Version 1.0.0.5
///           First public release
///
/// Aug 2025: Version 1.0.0.7
///           Return-values now match the latest version of BO_Helper.dll
///
/// Mar 2026  Version 1.0.0.8
///           + GetOsVersionString()
///
/// Aug 2026: Version 1.0.0.9
///           + Added SetDllDirectory() for portable macro packages
///
/// Description:
///
/// Contains all currently available calls of the BO_Helper.dll to implement in
/// TSE macros.
///
/// The parameter passing is specially designed to work with TSE only!
///
///******************************************************************************

/// Include into SAL macros starts below this line -----------------------------
// Uncomment the #define lines of the calls to use in your destination macro
// #define GET_VERSION_INFO        TRUE
// #define GET_OS_VERSION_STRING   TRUE
// #define GET_IS_WOW64            TRUE
// #define GET_IS_ELEVATED         TRUE
// #define GET_SYSTEM_CLOCK_TICKS  TRUE
// #define GET_MODULE_NAME         TRUE
// #define GET_FILE_STAT           TRUE
// #define RUN_APPLICATION         TRUE
// #define RUN_SHELL_APPLICATION   TRUE
// #define CONVERT_DATE_TO_UTC     TRUE
// #define CONVERT_UTC_TO_DATE     TRUE
// #define UTC_ADD_DATE            TRUE
// #define UTC_SUB_DATE            TRUE
// #define CONVERT_BASE10_TO_BASEX TRUE
// #define CONVERT_BASEX_TO_BASE10 TRUE
// #define QUERY_LOCALE_INFO       TRUE

//#include ["BO_Helper.inc"]  // uncomment this line to use in destination macro
/// Include stops above this line ----------------------------------------------

//**********************************************
// Constants used by GetVersion() vn_CompareMode
//**********************************************
constant VERSION_LT_EQ = -1   // (<=)
constant VERSION_EQUAL =  0   // (==)
constant VERSION_GT_EQ =  1   // (>=)

// Allow each macro to select the directory containing BO_Helper.dll before
// its first BO_Helper call. This makes the package independent of LoadDir().
dll "<Kernel32.dll>"
  integer proc SetDllDirectory(string pcPathName:cstrval): "SetDllDirectoryA"
end

//******************************************************************************
//
// GetVersionInfo
//
// Returns the version info of a file for further evaluation.
//
// Input:
// pc_FilePath -> Pointer of a 0 terminated string containing the filename
// p_TseString -> Pointer of a TSE-String, will be filled with data (0.0.0.0)
// n_TseMaxLen -> The string length of p_TseString (currently max 255)
//
// Output:
// p_TseString -> If successful contains version data
//
// Return:
// n_RetVal -> > 0 ok, number of copied bytes
//             < 0 Error, number is error code
//
//******************************************************************************
#ifdef GET_VERSION_INFO
dll "BO_Helper.dll"
  integer proc GetVersionInfo(string     pc_FilePath:cstrval,
                              var string p_TseString
                              // automatic by TSE, long n_TseMaxLen)
                             )

// Example call from SAL:
// nRetVal = GetVersionInfo(cFilename, cDllVersion)
end
#endif

//******************************************************************************
//
// GetOsVersionString
//
// Queries the current OS-Version and return a version string.
//
// p_TseString -> Pointer to a string for data placement
// n_TseMaxLen -> The string length of p_TseString (currently max 255)
//
// Output:
// p_TseString -> Formatted OS-Version string.
//                Example: [Win 64-Bit, 10.0.26200.6899]
//
// Return:
// n_RetVal    -> Number of copied bytes
//
//******************************************************************************
#ifdef GET_OS_VERSION_STRING
dll "BO_Helper.dll"
  integer proc GetOsVersionString(var string p_TseString
                                  // automatic by TSE, long n_TseMaxLen)
                                 )

// Example call from SAL:
// nRetVal = GetOsVersionString(cString)
end
#endif

//******************************************************************************
//
// GetIsWow64
//
// Check if we are running on a 64 bit OS.
//
// Input:
// void
//
// Output:
// void
//
// Return:
// 0= 32 bit system, <> 0= 64 bit system
//******************************************************************************
#ifdef GET_IS_WOW64
dll "BO_Helper.dll"
  integer proc GetIsWow64()

// Example call from SAL:
// nRetVal = GetIsWow64()
end
#endif

//******************************************************************************
//
// GetIsElevated
//
// Check if we are running in elevated rights mode.
//
// Input:
// void
//
// Output:
// void
//
// Return:
// 0 = not elevated, <> 0 = Elevated mode aktiv
//******************************************************************************
#ifdef GET_IS_ELEVATED
dll "BO_Helper.dll"
  integer proc GetIsElevated()

// Example call from SAL:
// nRetVal = GetIsElevated()
end
#endif


//******************************************************************************
//
// GetSystemClockTicks
//
// Gets the current system clock count in msec.
//
// Can be replaced by the following call:
//   dll "<ucrtbase.dll>"
//     // Return: ClockTicks in msec
//     integer proc clock()
//   end
//
// Input:
// void
//
// Output:
// void
//
// Return:
// ClockTicks in msec
//******************************************************************************
#ifdef GET_SYSTEM_CLOCK_TICKS
dll "BO_Helper.dll"
  integer proc GetSystemClockTicks()

// Example call from SAL:
// nClockTicks = GetSystemClockTicks()
end
#endif


//******************************************************************************
//
// GetModuleName
//
// Returns the path and name of the calling programm.
//
// Input:
// p_TseString -> Pointer to a string for data placement
// n_TseMaxLen -> Length of the p_TseString
//
// Output:
// p_TseString -> Path and Name of the calling programm
//
// Return:
// n_RetVal    -> Number of copied bytes
//******************************************************************************
#ifdef GET_MODULE_NAME
dll "BO_Helper.dll"
  integer proc GetModuleName(var string p_TseString
                             // automatic by TSE, long n_TseMaxLen)
                            )

// Example call from SAL:
// nRetVal = GetModuleName(pTseString)
end
#endif


//******************************************************************************
//
// GetFileStat
//
// Gets additional information for a file, like date/time, size and attributes.
//
// Input:
// p_TseInput  -> Pointer of a 0 terminated string containing the filename
// p_TseString -> Pointer to a string for data placement
// n_TseMaxLen -> Length of the p_TseString
//
// Output:
// p_TseString -> Data as string with keywords
//                Example:
//                        [FSZ]1.234|
//                        [FFCD]2014-08-21 20:32:45.235|
//                        [FFAD]2014-09-23 23:17:10.156|
//                        [FFMD]2014-09-23 23:17:10.632|
//                        [FAT]---A|
//                        Every keyword is surrounded by [] and dedicated data
//                        is terminated with a |
//
// Return:
// FILE_STAT_NO_ERROR            = 0
// FILE_STAT_FILE_NOT_FOUND      = 1
// FILE_STAT_LOCALIZE_SIZE_ERROR = 2
// FILE_STAT_RETURN_BUFFER_SIZE  = 3
// FILE_STAT_CREATE_HANDLE       = 4
// FILE_STAT_GET_FILETIME        = 5
//******************************************************************************
#ifdef GET_FILE_STAT
//**********************************
// GetFileStat possible return codes
//**********************************
constant FILE_STAT_NO_ERROR = 0,
         FILE_STAT_FILE_NOT_FOUND,
         FILE_STAT_LOCALIZE_SIZE_ERROR,
         FILE_STAT_RETURN_BUFFER_SIZE,
         FILE_STAT_CREATE_HANDLE,
         FILE_STAT_GET_FILETIME

dll "BO_Helper.dll"
  integer proc GetFileStat(string p_TseInput:cstrval,
                           var string p_TseString
                           // automatic by TSE, long n_TseMaxLen)
                          )

// Example call from SAL:
// nRetVal = GetFileStat(cFilename, cBuffer)
end
#endif


//******************************************************************************
//
// RunApplication
//
// Starts an application in a window or invisible in the background. Optionally
// returns the return code of the started application.
// If the return code is not needed the application will be started detached
// without waiting for it to finish.
// If only the app-name is handed over without a path then it will be searched
// and if found the app will be started. While searching the path the environment
// PATH will also be used.
//
// Input:
// pc_AppName     -> Pointer of a 0 terminated string containing the filename
// pc_CommandLine -> Pointer of a 0 terminated string containing commandline data
// n_GetExitCode  -> START_APP_DETACHED don't wait for end of app, no returncode
//                   START_APP_GET_RETURN wait for end of app and store
//                   returncode pn_ReturnCode.
// n_WindowType   -> Code 0...11  (SW_HIDE...SW_FORCEMINIMIZE)
// pn_ReturnCode  -> Return code when app ends, see Output
//
// Output:
// pn_ReturnCode  -> if n_GetExitCode <>0: Returncode, else always 0
//
// Return:
// n_RetVal ->  >0 = Process was started
//               0 = Process couldn't get started
//              <0 = OS-Errormessage
//******************************************************************************
#ifdef RUN_APPLICATION
//*******************************************
// RunApplication codes used for n_WindowType
//*******************************************
constant SW_HIDE = 0,
         SW_SHOWNORMAL,
         SW_SHOWMINIMIZED,
         SW_SHOWMAXIMIZED,
         SW_SHOWNOACTIVATE,
         SW_SHOW,
         SW_MINIMIZE,
         SW_SHOWMINNOACTIVE,
         SW_SHOWNA,
         SW_RESTORE,
         SW_SHOWDEFAULT,
         SW_FORCEMINIMIZE

//*********************************************
//* RunApplication codes used for n_GetExitCode
//*********************************************
constant START_APP_GET_RETURN = TRUE
constant START_APP_DETACHED   = FALSE

dll "BO_Helper.dll"
  integer proc RunApplication(string      pc_AppName:cstrval,
                              string      pc_CommandLine:cstrval,
                              integer     n_GetExitCode,
                              integer     n_WindowType,
                              var integer pn_ReturnCode
                             )

// Example call from SAL:
// nRetVal = RunApplication(cExeName,
//                          cCommandLine,
//                          START_APP_DETACHED,
//                          SW_SHOWNORMAL,
//                          nRetVal
//                         )
end
#endif


//******************************************************************************
//
// RunShellApplication
//
// Starts an app dedicated to the file in its own window.
//
// Input:
// pc_FilePath -> Pointer of a 0 terminated string containing the complete path
//                and filename
//
// Output:
// ---
//
// Return:
// >= 32 -> ok, app found and started
//  < 32 -> Error, code why app could not be started
//******************************************************************************
#ifdef RUN_SHELL_APPLICATION
dll "BO_Helper.dll"
  integer proc RunShellApplication(string pc_FilePath:cstrval)

// Example call from SAL:
// nRetVal = RunShellApplication(cFilename)
end
#endif


//******************************************************************************
//
// ConvertDateToUtc
//
// Converts a date into a 64-bit UTC-value.
// Calculation range from year 1970 to 3000.
// Week calculation is done according to DIN 1355.
//
// Input:
// n_Year    -> years since 1900 (if >= 1900 then 1900 will be subtracted)
// n_Month   -> months since January - [0,11] (if > 0 then 1 will be sutracted)
// n_Day     -> day of the month - [1,31]
// n_Hour    -> hours since midnight - [0,23]
// n_Min     -> minutes after the hour - [0,59]
// n_Sec     -> seconds after the minute - [0,59]
// p_TseString -> Pointer to a string for data placement
// n_TseMaxLen -> Length of the p_TseString
//
// Output:
// p_TseString -> Converted date with keywords, Every keyword is surronded by []
//                Example:
//                      [DEC]1321009871
//                      [HEX]0x000000004EBD02CF
//                      [YYYY]2011
//                      [MONTH]11
//                      [DAY]11
//                      [HOUR]11
//                      [MIN]11
//                      [SEC]11
//                      [WDAY]Friday
//                      [DOW]5
//                      [DOYEAR]315
//                      [NOMONTH]November
//                      [WOYDIN1355]45-2011
//
// Return:
// TRUE in case of error, else FALSE if ok
//******************************************************************************
#ifdef CONVERT_DATE_TO_UTC
dll "BO_Helper.dll"
  integer proc ConvertDateToUtc(integer    n_Year,
                                integer    n_Month,
                                integer    n_Day,
                                integer    n_Hour,
                                integer    n_Min,
                                integer    n_Sec,
                                var string p_TseString
                                // automatic by TSE, long n_TseMaxLen)
                               )

// Example call from SAL:
// nRetVal = ConvertDateToUtc(nYear, nMonth, nDay, nHour, nMin, nSec, cBuffer)
end
#endif


//******************************************************************************
//
// ConvertUtcToDate
//
// Converts an UTC-value to a date string.
// Calculation range from year 1970 to 3000.
// Week calculation is done according to DIN 1355.
//
// Input:
// p_TseInput  -> Pointer of a 0 terminated string containing the UTC-value
// p_TseString -> Pointer to a string for data placement
// n_TseMaxLen -> Length of the p_TseString
//
// Output:
// p_TseString -> Converted date with keywords, Every keyword is surronded by []
//                Example:
//                      [DEC]1321009871
//                      [HEX]0x000000004EBD02CF
//                      [YYYY]2011
//                      [MONTH]11
//                      [DAY]11
//                      [HOUR]11
//                      [MIN]11
//                      [SEC]11
//                      [WDAY]Friday
//                      [DOW]5
//                      [DOYEAR]315
//                      [NOMONTH]November
//                      [WOYDIN1355]45-2011
//
// Return:
// TRUE in case of error, else FALSE if ok
//******************************************************************************
#ifdef CONVERT_UTC_TO_DATE
dll "BO_Helper.dll"
  integer proc ConvertUtcToDate(string      p_TseInput:cstrval,
                                var string  p_TseString
                                // automatic by TSE, long n_TseMaxLen)
                               )

// Example call from SAL:
// nRetVal = ConvertUtcToDate(cDateTime, cBuffer)
end
#endif


//******************************************************************************
//
// UtcAddDate
//
// Adds input to a given UTC-value and returns the converted data.
// Calculation range from year 1970 to 3000.
// Week calculation is done according to DIN 1355.
//
// Input:
// p_TseInput  -> Pointer of a 0 terminated string containing the UTC-value
// n_Year      -> Years to add
// n_Month     -> Months to add
// n_Day       -> Days to add
// n_Hour      -> Hours to add
// n_Min       -> Minutes to add
// n_Sec       -> Seconds to add
// n_Weeks     -> Weeks to add
// p_TseString -> Pointer to a string for data placement
// n_TseMaxLen -> Length of the p_TseString
//
// Output:
// p_TseString -> Converted date with keywords, Every keyword is surronded by []
//                Example:
//                      [DEC]1321009871
//                      [HEX]0x000000004EBD02CF
//                      [YYYY]2011
//                      [MONTH]11
//                      [DAY]11
//                      [HOUR]11
//                      [MIN]11
//                      [SEC]11
//                      [WDAY]Freitag
//                      [DOYEAR]315
//                      [WOYDIN1355]45-2011
//
// Return:
// TRUE in case of error, else FALSE if ok
//******************************************************************************
#ifdef UTC_ADD_DATE
dll "BO_Helper.dll"
  integer proc UtcAddDate(string     p_TseInput:cstrval,
                          integer    n_Years,
                          integer    n_Months,
                          integer    n_Days,
                          integer    n_Hours,
                          integer    n_Mins,
                          integer    n_Secs,
                          integer    n_Weeks,
                          var string p_TseString
                          // automatic by TSE, long n_TseMaxLen)
                         )

// Example call from SAL:
// nRetVal = UtcAddDate(cUTC, nYear, nMonth, nDay,
//                      nHour, nMin, nSec, nWeek,
//                      cBuffer
//                     )
end
#endif


//******************************************************************************
//
// UtcSubDate
//
// Subtracts input to a given UTC-value and returns the converted data.
// Calculation range from year 1970 to 3000.
// Week calculation is done according to DIN 1355.
//
// Input:
// p_TseInput  -> Pointer of a 0 terminated string containing the UTC-value
// n_Year      -> Years to subtract
// n_Month     -> Months to subtract
// n_Day       -> Days to subtract
// n_Hour      -> Hours to subtract
// n_Min       -> Minutes to subtract
// n_Sec       -> Seconds to subtract
// n_Weeks     -> Weeks to subtract
// p_TseString -> Pointer to a string for data placement
// n_TseMaxLen -> Length of the p_TseString
//
// Output:
// p_TseString -> Converted date with keywords, Every keyword is surronded by []
//                Example:
//                      [DEC]1321009871
//                      [HEX]0x000000004EBD02CF
//                      [YYYY]2011
//                      [MONTH]11
//                      [DAY]11
//                      [HOUR]11
//                      [MIN]11
//                      [SEC]11
//                      [WDAY]Freitag
//                      [DOYEAR]315
//                      [WOYDIN1355]45-2011
//
// Return:
// TRUE in case of error, else FALSE if ok
//******************************************************************************
#ifdef UTC_SUB_DATE
dll "BO_Helper.dll"
  integer proc UtcSubDate(string     p_TseInput:cstrval,
                          integer    n_Years,
                          integer    n_Months,
                          integer    n_Days,
                          integer    n_Hours,
                          integer    n_Mins,
                          integer    n_Secs,
                          integer    n_Weeks,
                          var string p_TseString
                          // automatic by TSE, long n_TseMaxLen)
                         )

// Example call from SAL:
// nRetVal = UtcSubDate(cUTC, nYear, nMonth, nDay,
//                      nHour, nMin, nSec, nWeek,
//                      cBuffer
//                     )
end
#endif


//******************************************************************************
//
// ConvertBase10ToBaseX
//
// Converts a 64-bit integer base 10 to a 64-bit integer base 2 to 36.
//
// Input:
// n_DestBase       -> Destination base (2 - 36)
// pc_NumToConvert  -> Pointer to a 0 terminated string containing the base 10
//                     value to convert
// p_stTargetString -> Pointer of a TSE-String, will be filled with data
// n_TseMaxLen      -> The string length of p_stTargetString (currently max 255)
//
// Output:
// p_stTargetString -> If successful the to n_DestBase converted value
//
// Return:
// nRetVal -> > 0                                   = ok, Number of copied bytes
//            < 0                                   = Error, value is error code
//            CONV_BASE10_BASE_OUT_OF_RANGE         = n_DestBase not in range
//                                                    from 2 to 36
//            CONV_BASE10_DEST_STRING_SIZE_TO_SMALL = n_TseMaxLen is to small for
//                                                    converted value
//            CONV_BASE10_TO_BIG_FOR_64_BIT         = Number > 64 bit
//            CONV_BASE10_MATHERROR                 = Matherror, p_stTargetString
//                                                    contains error text as fits
//******************************************************************************
#ifdef CONVERT_BASE10_TO_BASEX
//*******************************************
// ConvertBase10ToBaseX possible return codes
//*******************************************
constant CONV_BASE10_BASE_OUT_OF_RANGE         = (-1)
constant CONV_BASE10_DEST_STRING_SIZE_TO_SMALL = (-2)
constant CONV_BASE10_TO_BIG_FOR_64_BIT         = (-3)
constant CONV_BASE10_MATHERROR                 = (-4)

dll "BO_Helper.dll"
  integer proc ConvertBase10ToBaseX(integer    n_DestBase,
                                    string     pc_NumToConvert:cstrval,
                                    var string p_stTargetString
                                    // automatic by TSE, long n_TseMaxLen)
                                   )

// Example call from SAL:
// nRetVal = ConvertBase10ToBaseX(nNewBase, cNumBase10, cConverted)
end
#endif


//******************************************************************************
//
// ConvertBaseXToBase10
//
// Converts a basex (2 - 36) 64-bit integer value to a 64-bit integer of base 10.
//
// Input:
// n_SourceBase     -> Source base (2 - 36)
// pc_BaseXString   -> Pointer to a 0 terminated string containing the basex
//                     value to convert
// pc_NumBase10     -> Pointer of a TSE-String, will be filled with data
// n_TseMaxLen      -> The string length of pc_NumBase10 (currently max 255)
//
// Output:
// pc_NumBase10     -> If successful the to base 10 converted value
//
// Return:
// n_RetVal -> CONV_BASE_X_NO_ERROR                  = OK, no error
//             CONV_BASE_X_BASE_OUT_OF_RANGE         = n_SourceBase not in range
//                                                     from 2 to 36
//             CONV_BASE_X_ILLEGAL_CHAR_FOR_BASE     = Number is to big for given
//                                                     sourcer base
//             CONV_BASE_X_TO_BIG_FOR_64_BIT         = Number > 64 bit
//             CONV_BASE_X_DEST_STRING_SIZE_TO_SMALL = n_TseMaxLen is to small for
//                                                     converted value
//             CONV_BASE_X_MATHERROR                 = Matherror, p_stTargetString
//                                                     contains error text as fits
//             CONV_BASE_NO_NUMBER_FOUND             = no number to convert
//******************************************************************************
#ifdef CONVERT_BASEX_TO_BASE10
//*******************************************
// ConvertBaseXToBase10 possible return codes
//*******************************************
constant CONV_BASE_X_NO_ERROR = 0,
         CONV_BASE_X_BASE_OUT_OF_RANGE,
         CONV_BASE_X_ILLEGAL_CHAR_FOR_BASE,
         CONV_BASE_X_TO_BIG_FOR_64_BIT,
         CONV_BASE_X_DEST_STRING_SIZE_TO_SMALL,
         CONV_BASE_X_MATHERROR,
         CONV_BASE_NO_NUMBER_FOUND

dll "BO_Helper.dll"
  integer proc ConvertBaseXToBase10(integer    n_SourceBase,
                                    string     pc_BaseXString:cstrval,
                                    var string pc_NumBase10
                                    // automatic by TSE, long n_TseMaxLen)
                                   )

// Example call from SAL:
// nRetVal = ConvertBaseXToBase10(nSourceBase, cBaseXString, cNumBase10)
end
#endif


//******************************************************************************
//
// QueryLocaleInfo
//
// Query locale settings from OS.
//
// Input:
// n_LocaleInfo      -> >0 = LOCALE_USER_DEFAULT, 0 = LOCALE_SYSTEM_DEFAULT
// n_InformationType -> Code what information to query
// p_TseString       -> Pointer of a TSE-String, will be filled with data
// n_TseMaxLen       -> The string length of p_TseString (currently max 255)
//
// Output:
// p_TseString       -> if successful the requested data
//
// Return:
// numeric  >0 = Number of bytes in string
//          <0 = Error, contains error number
//
// Can be replaced by the following call:
// dll "<Kernel32.dll>"
//
// integer proc GetLastError()
//
// //***************************************************************/
// // returns  0 when function fails                               */
// //         >0 Number of bytes in pc_Buffer including trailing 0 */
// //***************************************************************/
// integer proc GetLocaleInfo(integer n_LocaleIdentifier,  // locale identifier
//                            integer n_InformationType,   // information type
//                            var string  pc_Buffer:strval // information buffer
//                            // integer   n_BufferLength     size of buffer
//                           ) : "GetLocaleInfoA"
// end
//
// /************************************/
// /* Constants for n_LocaleIdentifier */
// /************************************/
// constant LOCALE_USER_DEFAULT   = 0x00000400
// constant LOCALE_SYSTEM_DEFAULT = 0x00000800
//
// /***************************************************************/
// /* the following two constants may be used in combination with */
// /* any other constant of n_InformationType                     */
// /***************************************************************/
// constant LOCALE_NOUSEROVERRIDE = 0x80000000  // do not use user overrides
// constant LOCALE_USE_CP_ACP     = 0x40000000  // use the system ACP
//
// /***********************************************************************/
// /* the following Constants are mutually exclusive in that they may NOT */
// /* be used in combination with each other. Used with n_InformationType */
// /***********************************************************************/
// constant LOCALE_SDECIMAL      = 0x0000000E   // decimal separator
// constant LOCALE_STHOUSAND     = 0x0000000F   // thousand separator
// constant LOCALE_SGROUPING     = 0x00000010   // digit grouping
// constant LOCALE_IDIGITS       = 0x00000011   // number of fractional digits
// constant LOCALE_FONTSIGNATURE = 0x00000058   // font signature
//
// /*********************************************************************/
// /* possible returncodes of GetLastError() when using GetLocaleInfo() */
// /*********************************************************************/
// constant ERROR_INVALID_PARAMETER   = 87
// constant ERROR_INSUFFICIENT_BUFFER = 122
// constant ERROR_INVALID_FLAGS       = 1004
//
// /*****************************************/
// /* Buffersize used by FppGetLocaleInfo() */
// /*****************************************/
// #define SIZE_DATA_BUFFER 30
//******************************************************************************
#ifdef QUERY_LOCALE_INFO
//******************************
// Codes used by QueryLocaleInfo
//******************************
constant LOCALE_SYSTEM_DEFAULT = 0
constant LOCALE_USER_DEFAULT   = 1

constant LOCALE_SDECIMAL  = 0x0000000E    // decimal separator
constant LOCALE_STHOUSAND = 0x0000000F    // thousand separator
constant LOCALE_SGROUPING = 0x00000010    // digit grouping
constant LOCALE_IDIGITS   = 0x00000011    // number of fractional digits

//**************************************
// QueryLocaleInfo important error codes
//**************************************
constant ERROR_INVALID_PARAMETER   = 87   // parameter is incorrect
constant ERROR_INSUFFICIENT_BUFFER = 122  // data area passed to a system call is
                                          // too small
constant ERROR_INVALID_FLAGS       = 1004 // invalid flags

dll "BO_Helper.dll"
  integer proc QueryLocaleInfo(integer n_LocaleInfo,
                               integer n_InformationType,
                               var string  p_TseString
                               // automatic by TSE, long n_TseMaxLen)
                              )

// Example call from SAL:
// nRetVal = QueryLocaleInfo(nLocalType, nInfoType, cInformation)
end
#endif

