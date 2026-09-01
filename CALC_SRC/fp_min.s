/*
    FP.S        --  Suite of convenient high-level functions for doing
                    floating point calculations.
    Author:  Tim Farley
      Date:  25-Feb-1993
    Revised: 26-Feb-1993

    Explanation:  The UCR Floating Point library, adapted to The SemWare
    Editor in UCRFP.S, provides a number of convenient floating point
    functions.  These are defined in this file, along with a series
    of more convenient higher-level functions to access the library.

    This file is intended to be #include'd in your macros which need
    to access floating point numbers.

  Release:  This source code and the associated SAL macros are released to
            the public domain.  Please honor any restrictions which are
            included in present or future versions of UCRLIB, but beyond
            that I do not restrict use.  I would appreciate it if you
            mention my name in the docs of any derivative macros you
            distribute.

              ***** Wednesday, 9 June 1993 [L.A.V.] *****
          ***** Removed unused code and renamed fp_min.s *****
*/

/*
    LOW LEVEL INTERFACE is defined in FPLOW.DLL.
    FPLOW.DLL replacement version: 1.0.0.0.7
    TSE SAL uses the Pascal calling convention.
*/
dll "fplow.dll"
            proc PASCAL lsfpa(string Single) : "LSFPA"
    integer proc PASCAL ssfpa(var string Single) : "SSFPA"
            proc PASCAL ldfpa(string Double) : "LDFPA"
    integer proc PASCAL sdfpa(var string Double) : "SDFPA"
            proc PASCAL lefpa(string Extended) : "LEFPA"
    integer proc PASCAL sefpa(var string Extended) : "SEFPA"

            proc PASCAL lsfpo(string Single) : "LSFPO"
            proc PASCAL ldfpo(string Double) : "LDFPO"
            proc PASCAL lefpo(string Extended) : "LEFPO"

            proc PASCAL ltof(integer SignedLong) : "LTOF"
    integer proc PASCAL ftol(var integer SignedLong) : "FTOL"

            proc PASCAL fpadd() : "FPADD"
            proc PASCAL fpsub() : "FPSUB"
    integer proc PASCAL fpcmp() : "FPCMP"
            proc PASCAL fpmul() : "FPMUL"
            proc PASCAL fpdiv() : "FPDIV"

    integer proc PASCAL ftoa(var string Target, integer Wide, integer DecP) : "FTOA"
    integer proc PASCAL etoa(var string Target, integer Wide) : "ETOA"
            proc PASCAL atof(string Source) : "SAL_ATOF"

    integer proc PASCAL fpTextParse(var string Target, string Source) : "FPTEXTPARSE"
    integer proc PASCAL fpTextOperation(var string Target, string LeftText,
                                        string RightText, integer Operation) : "FPTEXTOPERATION"
    integer proc PASCAL fpTextFormat(var string Target, string ValueText,
                                     integer Wide, integer Decimals) : "FPTEXTFORMAT"
end


/*
    SIZES OF STRINGS NEEDED
*/
constant
    IEEE_SINGLE   = 4,
    IEEE_DOUBLE   = 8,
    IEEE_EXTENDED = 10,
    IEEE          = 64      // Text representation used by the modern DLL

/*
    COMMONLY USED CONSTANTS
*/
string
    // The number ZERO in all three formats
    ZeroSingle[ IEEE_SINGLE ] = CHR(0)+CHR(0)+CHR(0)+CHR(0),
    ZeroDouble[ IEEE_DOUBLE ] = CHR(0)+CHR(0)+CHR(0)+CHR(0)
                               +CHR(0)+CHR(0)+CHR(0)+CHR(0),
    // Keep the historical name; the modern DLL uses decimal text internally.
    ZeroExtended[ IEEE ] = '0'

integer
    FMathError = FALSE      // Set to TRUE if overflow or error occurs

/*
    FAccumulator  puts a real number into the UCR FP library's FPA, and
        returns it's size.  Returns 0 if doesn't appear to be a correct
        real number (based only on the size!)
*/
integer proc FAccumulator( string RealNumber )
    integer RealSize

    FMathError = FALSE
    RealSize = Length( RealNumber )
    case  ( RealSize )
        when IEEE_SINGLE        lsfpa( RealNumber )
        when IEEE_DOUBLE        ldfpa( RealNumber )
        when IEEE_EXTENDED      lefpa( RealNumber )
        otherwise               FMathError = TRUE  return ( 0 )
    endcase

    return ( RealSize )
end FAccumulator


/*
    FOperand  puts a real number into the UCR FP library's FPO, and
        returns it's size.  Returns 0 if doesn't appear to be a correct
        real number (based only on the size!)
*/
integer proc FOperand( string RealNumber )
    integer RealSize

    FMathError = FALSE
    RealSize = Length( RealNumber )
    case  ( RealSize )
        when IEEE_SINGLE        lsfpo( RealNumber )
        when IEEE_DOUBLE        ldfpo( RealNumber )
        when IEEE_EXTENDED      lefpo( RealNumber )
        otherwise               FMathError = TRUE  return ( 0 )
    endcase

    return ( RealSize )
end FOperand


/*
    FResult  retrieves a result in the specified size from the FPA
*/
string proc FResult( integer IEEESize )
    string Answer[ IEEE ] = ""

    FMathError = FALSE
    case  ( IEEESize )
        when IEEE_SINGLE
            FMathError = NOT ssfpa( Answer )
            if  FMathError
                return ( ZeroSingle )
            endif
        when IEEE_DOUBLE
            FMathError = NOT sdfpa( Answer )
            if  FMathError
                return ( ZeroDouble )
            endif
        when IEEE_EXTENDED
            FMathError = NOT sefpa( Answer )
            if  FMathError
                return ( ZeroExtended )
            endif
    endcase

    return ( Answer )
end FResult


/*
    Perform a binary math operation
*/
constant
    OP_ADD = 1,
    OP_SUB = 2,
    OP_MUL = 3,
    OP_DIV = 4

string proc FOperation( integer Operator, string LeftOp, string RightOp )
    string Answer[ IEEE ] = ""
    FMathError = NOT fpTextOperation(Answer, LeftOp, RightOp, Operator)
    if FMathError
        return(ZeroExtended)
    endif
    return(Answer)
end FOperation


/*
    Add two numbers
*/
string proc FAdd( string LeftOp, string RightOp )
    return ( FOperation( OP_ADD, LeftOp, RightOp ) )
end FAdd

/*
    Subtract two numbers
*/
string proc FSub( string LeftOp, string RightOp )
    return ( FOperation( OP_SUB, LeftOp, RightOp ) )
end FSub

/*
    Multiply two numbers
*/
string proc FMul( string LeftOp, string RightOp )
    return ( FOperation( OP_MUL, LeftOp, RightOp ) )
end FMul

/*
    Divide two numbers
*/
string proc FDiv( string LeftOp, string RightOp )
    return ( FOperation( OP_DIV, LeftOp, RightOp ) )
end FDiv



/*
    FVal does for real numbers what Val() does for INTEGERS.
    That is, it converts a STRING representation of a number into a real
    number.

    NOTE:  Does not support bases other than 10.
*/
string proc FVal( string Ascii )
    string Answer[IEEE] = ""
    FMathError = NOT fpTextParse(Answer, Ascii)
    if FMathError
        return(ZeroExtended)
    endif
    return(Answer)
end FVal


/*
    FStr does for real numbers what Str() does for INTEGERS
    That is, it converts a real number to its STRING representation.

    NOTE:  Does not support bases other than 10.
*/
constant
    MAX_WIDTH = 254

string proc FStr( string RealNumber, integer Width, integer Decimals )
    // NOTE: this string must have room for a NUL terminator at end of string
    string Answer[ MAX_WIDTH + 1 ] = ""

    FMathError = (Width > MAX_WIDTH) OR
                 (NOT fpTextFormat(Answer, RealNumber, Width, Decimals))
    if FMathError
        return("Error!")
    endif
    return(Answer)
end FStr

/* eof: fp.s */
