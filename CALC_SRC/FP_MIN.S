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
    LOW LEVEL INTERFACE is defined here.
*/
binary "FPLOW.BIN"
    /*
       Floating Point Accumulator (fpa) operations.
    */
            proc lsfpa( string Single )                                 : 0
    integer proc ssfpa( var string Single )                             : 3
            proc ldfpa( string Double )                                 : 6
    integer proc sdfpa( var string Double )                             : 9
            proc lefpa( string Extended )                               : 12
    integer proc sefpa( var string Extended )                           : 15
    /*
       Floating Point Operand (fpo) operations
    */
            proc lsfpo( string Single )                                 : 18
            proc ldfpo( string Double )                                 : 21
            proc lefpo( string Extended )                               : 24
    /*
       Integer operations

       Since SAL's integers are signed longints (32 bits), most of the other
       operations are not truly useful from SAL, hence not defined.
    */
            proc ltof( integer SignedLong )                             : 27
    integer proc ftol( var integer SignedLong )                         : 30
    /*
       Mathematical operations
    */
            proc fpadd()                                                : 33
            proc fpsub()                                                : 36
    integer proc fpcmp()                                                : 39
            proc fpmul()                                                : 42
            proc fpdiv()                                                : 45
    /*
       String conversions
    */
    integer proc ftoa( var string Target, integer Wide, integer DecP )  : 48
    integer proc etoa( var string Target, integer Wide )                : 51
            proc atof( string Source )                                  : 54
end


/*
    SIZES OF STRINGS NEEDED
*/
constant
    IEEE_SINGLE   = 4,
    IEEE_DOUBLE   = 8,
    IEEE_EXTENDED = 10,
    IEEE          = 10      // Convenient for declaring max-length strings

/*
    COMMONLY USED CONSTANTS
*/
string
    // The number ZERO in all three formats
    ZeroSingle[ IEEE_SINGLE ] = CHR(0)+CHR(0)+CHR(0)+CHR(0),
    ZeroDouble[ IEEE_DOUBLE ] = CHR(0)+CHR(0)+CHR(0)+CHR(0)
                               +CHR(0)+CHR(0)+CHR(0)+CHR(0),
    ZeroExtended[ IEEE_EXTENDED ] = CHR(0)+CHR(0)+CHR(0)+CHR(0)+CHR(0)
                                   +CHR(0)+CHR(0)+CHR(0)+CHR(0)+CHR(0)

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
    integer AnswerSize = 0
    integer OperandSize

    // Left operand into the Floating Point Accumulator (FPA)
    // Default answer to same size
    AnswerSize = FAccumulator( LeftOp )
    if  FMathError  return ( ZeroSingle ) endif

    // Right operand into the Floating Point Operand (FPO)
    OperandSize = FOperand( RightOp )
    if  FMathError  return ( ZeroSingle ) endif

    // Promote answer to largest size passed
    if  OperandSize > AnswerSize
        AnswerSize = OperandSize
    endif

    // Perform the appropriate math operation
    case ( Operator )
        when OP_ADD  fpadd()
        when OP_SUB  fpsub()
        when OP_MUL  fpmul()
        when OP_DIV  fpdiv()
        otherwise    FMathError = TRUE  return( ZeroSingle )
    endcase

    return ( FResult( AnswerSize ) )   // Return answer to the caller
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
    // Convert the string to a number in the FPA
    atof( Ascii )

    // Retrieve answer from FPA in full precision.
    // If overflow, return zero.  Else return actual answer.
    return ( FResult( IEEE_EXTENDED ) )
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

    // Operand into the Floating Point Accumulator (FPA)
    FAccumulator( RealNumber )

    // Make sure we're not trying to do something stupid
    if  Width > MAX_WIDTH
        FMathError = TRUE
    endif

    // Get out of dodge if something is wrong.  Note that FMathError could
    // have been set by either or both of the operations above.
    if  FMathError
        return ( "Error!" )
    endif

    // Convert accumulator to a string with specified width & decimal places
    // Use floating point form only if Decimals is positive
    if  Decimals >= 0
        ftoa( Answer, Width, Decimals )
    endif

    // If Decimals is negative, or ftoa() could not fit it in field,
    // convert it in "exponential" form
    if  ( Decimals < 0 ) OR ( Answer[ 1 ] == "#" )
        etoa( Answer, Width )
    endif

    return ( Answer )
end FStr

/* eof: fp.s */