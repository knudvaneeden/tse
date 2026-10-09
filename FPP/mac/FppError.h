///****************************************************************************
///
/// FPPError.h
///
/// Author:        Eckhard Hillmann
///
/// First created: 18. May 2005
///
/// ****************************************************************************
/// This software is provided "as is" without express or implied warranty.
/// ****************************************************************************
///
/// History:
///
/// Jan 2025: Version 1.0.0.0
///           First public release
///
/// Dec 2025  Version 1.0.0.1
///           Cosmetic, Changed #define to constant
///
/// Description:
///
/// Haeder to include with FPP*.s macros who make use of the FppCon_xxx.exe
///
///****************************************************************************

// Errorcodes returned by FppCon_xxx.exe
constant ERROR_NO_ERROR              = 0x00000000
constant ERROR_IN_EXPRESSION         = 0x00000001

constant ERROR_BASE_1_OUT_OF_RANGE   = 0x00000002
constant ERROR_BASE_2_OUT_OF_RANGE   = 0x00000004
constant ERROR_BASE_3_OUT_OF_RANGE   = 0x00000008

constant ERROR_CONST_OPEN_FILE       = 0x00000010
constant ERROR_CONST_CLOSE_FILE      = 0x00000020
constant ERROR_CONST_WRITE_FILE      = 0x00000040
constant ERROR_CONST_NO_FILENAME     = 0x00000080

constant ERROR_MALLOC                = 0x00000100
constant ERROR_COMMANDLINE_PARAMETER = 0x00000200

constant ERROR_VAR_OPEN_FILE         = 0x00000400
constant ERROR_VAR_CLOSE_FILE        = 0x00000800
constant ERROR_VAR_READ_FILE         = 0x00001000
constant ERROR_VAR_WRITE_FILE        = 0x00002000
constant ERROR_VAR_NO_FILENAME       = 0x00004000

constant ERROR_FUNC_OPEN_FILE        = 0x00008000
constant ERROR_FUNC_CLOSE_FILE       = 0x00010000
constant ERROR_FUNC_WRITE_FILE       = 0x00020000
constant ERROR_FUNC_NO_FILENAME      = 0x00040000

constant ERROR_CODE_OPEN_FILE        = 0x00080000
constant ERROR_CODE_CLOSE_FILE       = 0x00100000
constant ERROR_CODE_WRITE_FILE       = 0x00200000
constant ERROR_CODE_NO_FILENAME      = 0x00400000

constant ERROR_RESULT_OPEN_FILE      = 0x00800000
constant ERROR_RESULT_CLOSE_FILE     = 0x01000000
constant ERROR_RESULT_WRITE_FILE     = 0x02000000
constant ERROR_RESULT_NO_FILENAME    = 0x04000000

constant ERROR_EXPR_OPEN_FILE        = 0x08000000
constant ERROR_EXPR_CLOSE_FILE       = 0x10000000
constant ERROR_EXPR_READ_FILE        = 0x20000000
constant ERROR_EXPR_NO_FILENAME      = 0x40000000

constant ERROR_MATHERROR             = 0x80000000

