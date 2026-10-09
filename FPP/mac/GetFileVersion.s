///*****************************************************************************
///
/// GetFileVersion.s
///
/// Author:        Eckhard Hillmann
///
/// First created: 14. February 2024
///
/// ****************************************************************************
/// This software is provided "as is" without express or implied warranty.
/// ****************************************************************************
///
/// History:
///
/// Jan 2025: Version 1.0.0.1
///           First public release
///
///
/// Description:
///
/// GetFileVersion is a macro that uses a system-call to read the version
/// information of an exe/dll and compares it to the given requirement.
/// The result is stored in the global string "FileVersionString".
///
/// If this macro is called without any parameter it does nothing, there will be
/// no message. It is designed to interact with other macros only.
///
/// Calling the macro can be done as follows:
///
/// string proc Test(string cProgramToCheck)
///  ExecMacro("GetFileVersion + cProgramToCheck)
///  return (GetGlobalStr("FileVersionString"))
/// end
///
/// proc main()
///   Message("Result: " + Test("1|4.5.0.0|d:\tsepro\g32.exe"))
/// end
///
///*****************************************************************************

#define TESTMODE  FALSE

// Used DLLs, used functions and constants to include here
#define GET_VERSION_INFO        TRUE

#include ["BO_Helper.inc"]

string gcMacVersion[] = " [1.0.0.1]"

// declaration of used procs etc.
forward proc WhenLoaded()
forward integer proc GetFileVersion(integer vnCompareMode, string vcProgname, string vcNeededVersion, var string rcFoundVersion)

///*****************************************************************************
///
/// Main
///
/// Entry to version-check.
///
/// Parameter are passed using the macro command line.
/// Three parameters have to be passed:
///
/// Parameter 1:
///   CompareMode -> Found version must be <=, ==, >= compared to passed version
///                  VERSION_LT_EQ  -1 (<=)
///                  VERSION_EQUAL   0 (==)
///                  VERSION_GT_EQ   1 (>=)
///                  Constan definitions can be found in BO_Helper.inc
/// Parameter 2:
///   NeededVersion -> Version that should to be present
/// Parameter 3:
///   Progname      -> Name of exe/dll to check
///
/// Parameter must be separated by "|"
/// Example: "1|4.5.0.0|d:\tsepro\g32.exe"
///
/// The result is placed in the system global string "FileVersionString".
/// It contains the current found version of the exe/dll, for example "4.5.0.0".
/// In case of an error the macro displays a warning and "FileVersionString"
/// will contain an empty string.
///
///*****************************************************************************
proc main()

#if TESTMODE
  string cProgram[MAXSTRINGLEN]     = "D:\TSEPro\FppCon_x64.exe"
  string cNeedVersion[64]           = "1.9.0.19"
  string cFoundVersion[64]          = ""

  // found <= need
  GetVersion(VERSION_LT_EQ, cProgram, cNeedVersion, cFoundVersion)

  // found == need
  GetVersion(VERSION_EQUAL, cProgram, cNeedVersion, cFoundVersion)

  // found >= need
  GetVersion(VERSION_GT_EQ, cProgram, cNeedVersion, cFoundVersion)

#else       // Normal runtime
  integer nMode = 0

  string cCommandline[MAXSTRINGLEN] = Query(MacroCmdLine)
  string cProgram[MAXSTRINGLEN]     = ""
  string cNeedVersion[64]           = ""
  string cFoundVersion[64]          = ""

  if cCommandline <> ""
    nMode        = Val (GetToken(cCommandline, "|", 1))
    cNeedVersion = Trim(GetToken(cCommandline, "|", 2))
    cProgram     = Trim(GetToken(cCommandline, "|", 3))

    if GetFileVersion(nMode, cProgram, cNeedVersion, cFoundVersion)
      SetGlobalStr("FileVersionString", "")      // Version passt nicht oder Fehler
    else
      SetGlobalStr("FileVersionString", cFoundVersion)
    endif
  endif
#endif

end

///*****************************************************************************
///
/// WhenLoaded
///
/// Initialize global string
///
///*****************************************************************************
proc WhenLoaded()

  SetGlobalStr("FileVersionString", "")

end

///*****************************************************************************
///
/// GetFileVersion
///
/// Gets version information from an exe/dll an compares it aginst what is
/// needed. If the compare misses the specification or an error occurs a
/// message will be displayed.
///
/// Input:
/// vnCompareMode   -> Found version must be <=, ==, >=
///                     VERSION_LT_EQ (<=)
///                     VERSION_EQUAL (==)
///                     VERSION_GT_EQ (>=)
/// vcProgname      -> Name of exe/dll to check
/// vcNeededVersion -> Version that should to be present
/// rcFoundVersion  -> Current version of the exe/dll
///
/// Output:
/// rcFoundVersion -> Current version of the exe/dll when Return = FALSE (ok)
///
/// Return:
/// TRUE/FALSE -> TRUE = Error, FALSE = ok
///*****************************************************************************
integer proc GetFileVersion(integer vnCompareMode, string vcProgname, string vcNeededVersion, var string rcFoundVersion)

  integer nRetVal     = 0
  integer nCmpResult  = 0

  string cNeed_1[10]  = ""
  string cNeed_2[10]  = ""
  string cNeed_3[10]  = ""
  string cNeed_4[10]  = ""

  string cFound_1[10] = ""
  string cFound_2[10] = ""
  string cFound_3[10] = ""
  string cFound_4[10] = ""

  string cCmpSign[2]  = ""
  string cNeedV[64]   = ""
  string cFoundV[64]  = ""

  // Clear output
  rcFoundVersion = ""

  // Query exe/dll version
  nRetVal = GetVersionInfo(vcProgname, rcFoundVersion)

  // Data present
  if nRetVal > 0
    // Spilt version in single parts
    cNeed_1  = GetToken(vcNeededVersion, ".", 1)
    cNeed_2  = GetToken(vcNeededVersion, ".", 2)
    cNeed_3  = GetToken(vcNeededVersion, ".", 3)
    cNeed_4  = GetToken(vcNeededVersion, ".", 4)

    cFound_1 = GetToken(rcFoundVersion, ".", 1)
    cFound_2 = GetToken(rcFoundVersion, ".", 2)
    cFound_3 = GetToken(rcFoundVersion, ".", 3)
    cFound_4 = GetToken(rcFoundVersion, ".", 4)

    // Make every part of matching length
    if Length(cNeed_1) < Length(cFound_1)
      cNeed_1 = Format(cNeed_1: Length(cFound_1): "0")
    elseif Length(cNeed_1) > Length(cFound_1)
      cFound_1 = Format(cFound_1: Length(cNeed_1): "0")
    endif

    if Length(cNeed_2) < Length(cFound_2)
      cNeed_2 = Format(cNeed_2: Length(cFound_2): "0")
    elseif Length(cNeed_2) > Length(cFound_2)
      cFound_2 = Format(cFound_2: Length(cNeed_2): "0")
    endif

    if Length(cNeed_3) < Length(cFound_3)
      cNeed_3 = Format(cNeed_3: Length(cFound_3): "0")
    elseif Length(cNeed_3) > Length(cFound_3)
      cFound_3 = Format(cFound_3: Length(cNeed_3): "0")
    endif

    if Length(cNeed_4) < Length(cFound_4)
      cNeed_4 = Format(cNeed_4: Length(cFound_4): "0")
    elseif Length(cNeed_4) > Length(cFound_4)
      cFound_4 = Format(cFound_4: Length(cNeed_4): "0")
    endif

    // Assemble version strings for comparisson
    cNeedV  = cNeed_1  + cNeed_2  + cNeed_3  + cNeed_4
    cFoundV = cFound_1 + cFound_2 + cFound_3 + cFound_4

    // Compare versions
    nCmpResult = CmpiStr(cFoundV, cNeedV)

    // Compare with specification
    case vnCompareMode
    when VERSION_GT_EQ                        // Found >= needed
      if nCmpResult >= 0
#if TESTMODE
        Warn(">= ok? found >= need" + Chr(13)
             + "Need:  " + cNeedV + Chr(13)
             + "Found: " + cFoundV
            )
#endif
        return(FALSE)
      endif

      cCmpSign = ">="

    when VERSION_EQUAL                        // Found == needed
      if nCmpResult == 0
#if TESTMODE
        Warn("== ok? found == need" + Chr(13)
             + "Need:  " + cNeedV + Chr(13)
             + "Found: " + cFoundV
            )
#endif
        return(FALSE)
      endif

      cCmpSign = "=="

    when VERSION_LT_EQ                        // Found <= needed
      if nCmpResult <= 0
#if TESTMODE
        Warn("<= ok? found <= need" + Chr(13)
             + "Need:  " + cNeedV  + Chr(13)
             + "Found: " + cFoundV
            )
#endif
        return(FALSE)
      endif

      cCmpSign = "<="

    otherwise                                 // Error parameter
      Warn(SplitPath(CurrMacroFilename(), _NAME_ | _EXT_)
           + Chr(13) + Chr(13)
           + "Wrong Compare mode!"
          )
      return(TRUE)

    endcase

    // Found an needed don't match
    Warn(SplitPath(CurrMacroFilename(), _NAME_ | _EXT_) + gcMacVersion
         + Chr(13) + Chr(13)
         + "Wrong version of " + vcProgname + Chr(13)
         + "Found " + rcFoundVersion + Chr(13)
         + "Need version to be " + cCmpSign + " " + vcNeededVersion + Chr(13)
        )
      return(TRUE)

  // Errorcode
  elseif nRetVal < 0
    nRetVal = -nRetVal
    Warn(SplitPath(CurrMacroFilename(), _NAME_ | _EXT_) + gcMacVersion
         + Chr(13) + Chr(13)
         + "OS-Errorcode: " + Str(nRetVal) + Chr(13)
        )
    return(TRUE)

  // No data
  else
    Warn(SplitPath(CurrMacroFilename(), _NAME_ | _EXT_) + gcMacVersion
         + Chr(13) + Chr(13)
         + "No Version Data available for " + vcProgname + Chr(13)
        )
    return(TRUE)
  endif

  return(FALSE)

end

