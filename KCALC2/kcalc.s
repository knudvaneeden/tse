/*************************************************************************

KCalc       Calculates the numeric expression in a marked block.

Author:     Ken Green

Date:       Version 1.00 (watch yourself!) - April 2, 1997
            v1.01  4/08/97 - Added error check for numbers too long, changed
                        division to quit adding decimal places if the number
                        is too long
            v1.10  5/19/97 - Improved the math analysis, added better error
                        handling and support for large numbers (within our
                        Int limits)
            v1.11  2/15/98 - Corrected error in converting negative exponent
                        numbers into strings.  Thanks to David Treibs for
                        the bug notice and careful documentation of same.

Overview:   This macro calculates decimal, hexadecimal and/or binary numbers
            within a marked block (can be a column block).  The result is
            placed in the the text, at the current cursor position, based on
            the current insert/overwrite status.

Numbers:    Number types are determined based on format as follows:
                Decimal - NNNN or NNNNd or N,NNN or N,NNN.NN
                Hexadecimal - 0xNNNN or NNNNh or NNNN$
                Binary      - NNNNNb
                All others are assumed to be decimal.  Note that there can be
                no spaces between the "x", "h", "$", or "b" type indicators
                and the numbers.

            The result is put into the text based on the type of the first
            number:
                    2345  (decimal)
                    1000h (hexadecimal)
                    -----
                    6441  (decimal)

            Decimals will not have a "d" trailer; but, hexadecimal and binary
            numbers WILL have an "h" or "b" trailer respectively:
                    1000h (hexadecimal)
                    2345  (decimal)
                    -----
                  0+1929h (hexadecimal)

            Fractions are supported except for bitwise operations.  Commas
            within a number are ignored.

Operators:  The following math operators are available:
                >      SHR      (bitwise shift right)
                <      SHL      (bitwise shift left)
                %      MOD      (modulo division)
                &      AND      (bitwise AND)
                |      OR       (bitwise OR)
                ^      XOR      (bitwise eXclusive-OR)
                +      Addition
                -      Subtraction
                *      Multiplication
                /      Division

            Operator precedence is NOT as in SAL, but is simply left to right
            -- if in doubt, use parentheses.

Keys/Usage: This macro does not have any key assignments.  To use,
            simply use the Macro, Execute menu selection and type Calc.
            However, if you use it a fair amount, you may want to assign
            this macro to a keydef for Ctrl=, e.g.
                <Ctrl =>        ExecMacro("calc")

Authorship Notes:

  This has been completely written by Ken Green -- all bugs are his (of
  course, your calls will not be taken <g>).

  However, it was developed by reviewing code and copying some of same and
  ideas from SemWare's SUM.S written by Steve Watkins (4/11/94 version) and
  SemWare's EXPR.S - probably written by the master, Sammy Mitchel (3/23/94
  version). Therefore, SemWare's copywrite notice (for their code) is:

  Copyright 1992-1995 SemWare Corporation.  All Rights Reserved Worldwide.

  Use, modification, and distribution of this SAL macro is encouraged by
  SemWare provided that this statement, including the above copyright
  notice, is not removed; and provided that no fee or other remuneration
  is received for distribution.  You may add your own copyright notice
  to cover new matter you add to the macro, but SemWare Corporation will
  neither support nor assume legal responsibility for any material added
  or any changes made to the macro.

Final Note:

  Replacement of commas in decimal strings is left as an exercise for the
  reader.

Function List:
    integer proc CharInString(STRING TheChr, STRING TestString)
    integer proc GetNextChar(INTEGER bNumbOnly)
    integer proc Str2Numb(INTEGER nNumTyp)
    proc GetNextToken()
    integer proc CheckLength(INTEGER nNumb, INTEGER nMaxDigits)
    integer proc TweakNumb(var INTEGER nNumb, var INTEGER nExp, INTEGER nExpChg)
    proc AddSubtr(INTEGER bDoAdd, INTEGER nNumb1, INTEGER nExpr1,
        INTEGER nNumb2, INTEGER nExpr2)
    proc Multiply(INTEGER nNumb1, INTEGER nExpr1, INTEGER nNumb2, INTEGER nExpr2)
    proc Divide(INTEGER nNumb1, INTEGER nExpr1, INTEGER nNumb2, INTEGER nExpr2)
    proc Calculate(INTEGER nNum1, INTEGER nExp1, STRING Oper, INTEGER nNum2,
        INTEGER nExp2)
    proc ParseExpr(INTEGER bEndAtRParen)
    proc Numb2String(INTEGER nType)
    proc Main()

*************************************************************************/

// Constants:
constant is_Oper        = 1,    // Token is an operator
         is_Number      = 2,    // Token is a number
         is_LParen      = 3,    // Token is a left parenthesis
         is_RParen      = 4     // Token is a right parenthesis

constant is_DECIMAL     = 1,    // Decimal number
         is_HEX         = 2,    // Hexadecimal number
         is_BINARY      = 3     // Binary number


// Global variables:
string NumberString[21] = "1234567890.,ABCDEFHX$"   // Allowable number chars
string OperString[13] = "()><%&|^+-*/"              // Allowable operators

integer bGotError = 0               // TRUE if we have an error
string  sErrorMsg[80]               // Error Message
integer bAtEof = FALSE              // TRUE if we're at the End of the File/Block

integer nRetType = 0                // Return Number Type: Dec, Hex, Binary
string  sRetRes[80]                 // Returned Result string

integer nResNumb = 0                // Result Mantissa
integer nResExp = 0                 // Result Exponent (* -1)

string  sToken[15]                  // Currently parsed number/operator
integer nTokenType                  // Token type (see is_x constants)
integer nTokenNumber                // Token as a number
integer nTokenExponent              // Token exponent
string  Char[1]                     // Next Char from Buffer (Block)

// Note whether a character is within a string
integer proc CharInString(STRING TheChr, STRING TestString)
    integer nPosn   = 1
    integer nStrLen = Length(TestString)
    string  cWkg[1] = ""

    // Test only the first character of TheChr
    if Length(TheChr) > 0
        cWkg = TheChr[1]
    endif

    // If we have a null character to test, return FALSE
    if Length(cWkg) == 0
        return (FALSE)
    endif

    // Otherwise look for the character in the string
    while nPosn <= nStrLen
        if cWkg == TestString[nPosn]
            return (TRUE)
        endif
        nPosn = nPosn + 1
    endwhile

    // Didn't get it
    return (FALSE)
end

// Return the next valid character from the buffer
integer proc GetNextChar(INTEGER bNumbOnly)
    string  Ch[1]

    // Our objective is to retrieve the next valid character from the file and
    //  return it.  Valid characters are non-whitespace characters in
    //  NumberString or OperString.

    // Assume we won't get anything
    Char = ""

    // If we're at EOF, just return a null string.
    if bAtEof
        return(0)
    endif

    // But, we are operating under two modes or states
    if bNumbOnly

        // Here, we're to return only numbers - not other Operators.  That
        //  means if the character isn't a number, we're not to move within
        //  the file so we can retrieve the character during the next call.

        // Whitespace isn't a number
        if isWhite()
            return(0)
        endif

        // Get the next character (put don't change the file pointer just yet)
        Ch = Upper( GetText(CurrPos(), 1))

        // If this really is a number, save it and move the file position
        if CharInString(Ch,NumberString)
            Char = Ch

            // Skip to the next character
            bAtEof = (not NextChar())
            return(is_Number)
        endif

        // Nope, not a number, so don't move the pointer
        return(0)
    endif

    // If bNumbOnly is FALSE, we're to return any ol' valid character.
    while Char == "" and (not bAtEof)

        // Skip any leading whitespace
        while isWhite() and (not bAtEof)
            bAtEof = (not NextChar())
        endwhile
        if bAtEof
            break
        endif

        // Get the next character and move the cursor
        Ch = Upper( GetText( CurrPos(), 1))
        bAtEof = (not NextChar())

        // This is a valid character if it is a digit or on operator, but
        //  number type letters aren't allowed here
        if CharInString(Ch, Substr(NumberString,1,10) )
            Char = Ch
            return(is_Number)
        endif
        if CharInString(Ch, OperString)
            Char = Ch
            case Char
            when "("      return(is_LParen)
            when ")"      return(is_RParen)
            otherwise     return(is_Oper)
            endcase
        endif
    endwhile
    return(0)
end

// Convert the sToken string into a number in nTokenNumber, set nTokenExponent
integer proc Str2Numb(INTEGER nNumTyp)
    integer StrLen, bCarry

    // Before we risk doing number type conversions, we have to know if the
    //  number will overflow.  We are going to deal with all numbers as
    //  decimal, but our decimal limit is +/- 2,147,483,647d.  So, we can't
    //  convert Hex or Binary numbers if they're over this limit.
    StrLen = Length(sToken)

    // Convert sToken into a number, checking the length first
    case nNumTyp

    // Hexadecimal
    when is_HEX

        // Our number limit is +/- 7FFFFFFFh - 8 character length
        if StrLen > 8 or (StrLen == 8 and sToken[1] > '7')
            sErrorMsg = "Error - Hex number limit is: +/- 7FFFFFFF; you "
            sErrorMsg = sErrorMsg + 'have: ' + sToken
            return(FALSE)
        endif
        nTokenNumber = Val(sToken, 16)

    // Binary
    when is_BINARY

        // Here, our number limit is a long muther:
        //  +/- 10000000000000000000000000000000b - 32 character length.
        // We'll check for 31 characters.
        if StrLen > 31
            sErrorMsg = "Error - Binary number is too long: " + sToken
            return(FALSE)
        endif
        nTokenNumber = Val(sToken, 2)

    // Decimals
    otherwise

        // Here, length is loosy goosy - our limit of +/- 2,147,483,647
        //  implies that we can't handle a number like 123,456,000,000,000
        //  or 0.000,000,000,000,123,456.  But, with exponents, it's easy:
        // 1. If we have leading 0's:
        //      0.000,000,000,000,123,456 --> sToken: 0000000000000123456 E-18
        //          Change to: 123456 E-18
        //      000,000,000,000,123,456   --> sToken: 0000000000000123456 E0
        //          Change to: 123456 E0
        //    For each leading 0 we just strip it - no effect on exponents.
        while (StrLen > 0 and sToken[1] == '0')
            sToken = SubStr(sToken, 2, StrLen-1)
            StrLen = StrLen - 1
        endwhile

        // 2. If we have trailing 0's, it's a bit messier:
        //      a. 123,456,000,000,000 --> sToken: 123456000000000 E0
        //          Change to: 123456 E9
        //      b. 123,456,000.000,000 --> sToken: 123456000000000 E-6
        //          Change to: 123456 E3
        //  For each trailing 0 we strip, we add 1 to the exponent
        while (StrLen > 0 and sToken[StrLen] == '0')
            sToken = SubStr(sToken, 1, StrLen-1)
            StrLen = StrLen - 1
            nTokenExponent = nTokenExponent + 1
        endwhile

        // Now, we still could be too long (limit: +/- 2,147,483,647):
        //      2,345,147,483,647 --> 2345147483647 E0
        // So, we'll strip trailing digits, and increment exponents until
        //  we have a string <= 9 chars.  We'll note the rounding carry.
        bCarry = FALSE
        while (StrLen > 9)
            if sToken[StrLen] > '4'
                bCarry = TRUE
            else
                bCarry = FALSE
            endif
            sToken = SubStr(sToken, 1, StrLen-1)
            StrLen = StrLen - 1
            nTokenExponent = nTokenExponent + 1
        endwhile

        // Whew, now we can convert to a number
        nTokenNumber = Val(sToken, 10)
        if bCarry
            nTokenNumber = nTokenNumber + 1
        endif
    endcase
    return(TRUE)
end

// GetNextToken - Get the next number or operator from the buffer
proc GetNextToken()
    integer NumbType = 0        // Type of number
    integer DecPosn = 0         // Decimal position

    // Get the next character in the buffer
    nTokenType = GetNextChar(FALSE)

    // Put it in Token
    sToken = Char

    // If it's not a number return the token type
    if nTokenType <> is_Number
        return()
    endif

    // It is a number.  Assume that it's decimal (all first digits of numbers
    //  must be decimal).
    NumbType = is_DECIMAL

    // Get all of the rest of the digits in the number
    while GetNextChar(TRUE) == is_Number

        // Set our number type if appropriate
        case Char
        when "D"
            NumbType = is_DECIMAL
        when "H"
            NumbType = is_HEX
        when "X"
            NumbType = is_HEX
        when "$"
            NumbType = is_HEX
        when "B"
            NumbType = is_BINARY
        when "."
            if NumbType == is_DECIMAL
                DecPosn = Length(sToken)
            else
                bGotError = TRUE
                sErrorMsg = "Error - can't handle decimal points in hex or binary nos."
                break
            endif
        when ","
            // Ignore
        otherwise
            sToken = sToken + Char
        endcase
    endwhile
    if bGotError
        return()
    endif

    // The number (as a string) is in sToken.  NumbType defines the type of
    //  number and DecPosn has the decimal position (if any).

    // If we have a Decimal position calculate the exponent
    nTokenExponent = 0
    if DecPosn > 0 and DecPosn < Length(sToken)

        // The number of decimal digits defines the exponent, e.g.
        //  1234.234 has 3 decimal digits, so the exponent is -3.
        // The token length (without the decimal point) is 7, the decimal
        //  position is 4 (the length of the token when the decimal is found),
        //  so: the Exponent is 4 - 7 = -3
        // If instead, we have 0.000456, the token length is 7 and the decimal
        //  position is 1, so the Exponent is 1 - 7 = -6
        nTokenExponent = DecPosn - Length(sToken)
    endif

    // Go convert the string into a number
    if not Str2Numb(NumbType)
        bGotError = TRUE
        return()
    endif

    // One last thing, if this is the first number retrieved, we need to
    //  know the number type for our return calculation.
    if nRetType == 0
        nRetType = NumbType
    endif
    return()
end

// Check a number's length and return TRUE if it's longer than desired
integer proc CheckLength(INTEGER nNumb, INTEGER nMaxDigits)
    string  sTemp[15]
    integer nLen
    sTemp = Str(nNumb, 10)
    nLen = Length(sTemp)
    if nLen < nMaxDigits
        RETURN(FALSE)
    endif
    return(TRUE)
end

// Change the passed number and its exponent as desired
integer proc TweakNumb(var INTEGER nNumb, var INTEGER nExp, INTEGER nExpChg)
    string  sTemp[15]
    integer nLen, bCarry

    /*
    We want to alter the stored state of nNumb E(nExp) by adjusting the
    exponent as defined by nExpChg.  But, we don't want to change the actual
    number (unless we have to drop trailing digits).  For example:
        Number: 12345 E-2 (123.45)  Change: -2      Result: 1234500 E-4
        Number: 12345 E-2 (123.45)  Change: +3      Result: 12 E+1
    If we're to increase the exponent (e.g. from -2 to 0), we'll have to
    multiply the number times 10^nExpChg.  If we're to decrease the exponent
    (e.g. from -2 to -4), we'll have to divide the number by 10^nExpChg
    rounding off as we do this.   */

    // Handle decreases in exponent
    if nExpChg < 0

        // Go do the conversion
        while nExpChg < 0

            // We can't do this if the resulting number would be > 9 digits.
            if CheckLength(nNumb, 8)
                return(FALSE)
            endif

            // Add a trailing digit and reduce the exponent
            nNumb = nNumb * 10
            nExp = nExp - 1
            nExpChg = nExpChg + 1
        endwhile

    // Handle increases in exponent
    else

        // This could result in numbers becoming 0.  Oh well, at lease we'll
        //  try to round it off
        while nExpChg > 0

            // Should we round?
            sTemp = Str(nNumb, 10)
            nLen = Length(sTemp)
            bCarry = FALSE
            if sTemp[nLen] > '4'
                bCarry = TRUE
            endif

            // Divide by 10
            nNumb = nNumb / 10
            if bCarry
                nNumb = nNumb + 1
            endif
            nExp = nExp + 1
            nExpChg = nExpChg - 1

            // We may be done before we thought
            if nNumb == 0
                nExp = nExpChg * (-1)
                return(TRUE)
            endif
        endwhile
    endif
    return(TRUE)
end

// Handle decimal addition or subtraction
proc AddSubtr(INTEGER bDoAdd, INTEGER nNumb1, INTEGER nExpr1, INTEGER nNumb2,
              INTEGER nExpr2)

    /*
    It wouldn't do to try to add or subtract numbers until the exponents are
    the same:
            123.456 --> 123456 E-3
         +55345.    -->  55345 E0 --> HUH?
    For either adding or subtracting, we have to convert the number with the
    larger exponent to match the smaller exponent:
            123.456 --> 123456 E-3  -->   123456 E-3
         +55345.    -->  55345 E0   --> 55345000 E-3         Now, we can add
    But, we could have an overflow with this scheme:
            123.456 -->    123456 E-3  -->       123456 E-3
     +553450000.    --> 553450000 E0   --> 553450000000 E-3  Oops, 12 digits
    */

    // So, our rules for exponent conversion are:
    if nExpr1 <> nExpr2

        // First, if either number is 0, we can just make the exponents match
        if nNumb1 == 0
            nExpr1 = nExpr2
        endif
        if nNumb2 == 0
            nExpr2 = nExpr1
        endif

        // 1. Convert the number with the larger exponent until it matches the
        //    smaller exponent.
        if nExpr1 > nExpr2

            // nExpr1 > nExpr2: diff = nExpr1 - nExpr2, change = diff * (-1)
            //  or, change = (nExpr1 - nExpr2) * (-1)
            //             = -nExpr1 + nExpr2
            //             =  nExpr2 - nExpr1
            //  123 E0 and 234 E-3  diff = 0 - (-3) = 3  change = -3
            //  123 E5 and 234 E3   diff = 5 - 3 = 2     change = -2
            TweakNumb(nNumb1, nExpr1, nExpr2 - nExpr1)
        elseif nExpr2 > nExpr1

            // nExpr2 > nExpr1: diff = nExpr2 - nExpr1, change = diff * (-1)
            //  or, change = (nExpr2 - nExpr1) * (-1)
            //             = -nExpr2 + nExpr1
            //             =  nExpr1 - nExpr2
            //  123 E-3 and 234 E0  diff = 0 - (-3) = 3  change = -3
            //  123 E3 and 234 E5   diff = 5 - 3 = 2     change = -2
            TweakNumb(nNumb2, nExpr2, nExpr1 - nExpr2)
        endif

        // 2. If the converted exponent still doesn't match the other, it's
        //    because it would be longer than 9 digits.  So, shorten (truncate
        //    with rounding) the other number until we get a match.
        if nExpr1 > nExpr2

            // Here, we change nExpr2
            // nExpr1 > nExpr2: diff = nExpr1 - nExpr2, change = diff
            //  123 E0 and 234 E-3  diff = 0 - (-3) = 3 = change2
            //  123 E5 and 234 E3   diff = 5 - 3 = 2    = change2
            TweakNumb(nNumb2, nExpr2, nExpr1 - nExpr2)
        elseif nExpr2 > nExpr1

            // Again, here we change nExpr1
            // nExpr2 > nExpr1: diff = nExpr2 - nExpr1, change = diff
            //  123 E-3 and 234 E0  diff = 0 - (-3) = 3 = change2
            //  123 E3 and 234 E5   diff = 5 - 3 = 2    = change2
            TweakNumb(nNumb1, nExpr1, nExpr2 - nExpr1)
        endif
    endif

    // Here, the exponents are the same, so just add or subtract the numbers
    if bDoAdd
        nResNumb = nNumb1 + nNumb2
    else    // subtract
        nResNumb = nNumb1 - nNumb2
    endif
    nResExp = nExpr1
    return()
end

// Handle decimal multiplication
proc Multiply(INTEGER nNumb1, INTEGER nExpr1, INTEGER nNumb2, INTEGER nExpr2)
    integer nNumDigits1
    integer nNumDigits2

    /*
    Multiplying is simple - just multiply the numbers and add the exponents:
        3.5 * 2.3 = 8.05
        35 E-1 --> 3.5
        23 E-1 --> 2.3
        35 * 23 = 805 E-2
    But, if we multiply 2 numbers, the maximum result length (of the number)
    is the sum of the two number's digits.  If this is more than 9 digits,
    we're in trouble.  Example:
        123456789 E2 (9 digits) * 23456 E3     (5 digits)
        Result: 2895802442784 E5 (13 digits)
    So, we'll check the overall length of each number before multiplying, then
    reduce the numbers' length (compensating with their exponents) until their
    total digits <= 9. or the exponents are 0 - that's the best we can do.
    */
    nNumDigits1 = Length( Str(nNumb1, 10) )
    nNumDigits2 = Length( Str(nNumb2, 10) )

    // If we have to chop 'em, our chopping rules are:
    if nNumDigits1 + nNumDigits2 > 9

        // 1. First, chop numbers with trailing 0s.
        while nNumDigits1 + nNumDigits2 > 9 and
          (nNumb1 mod 10 == 0 or nNumb2 mod 10 == 0)
            if nNumb1 mod 10 == 0
                TweakNumb(nNumb1, nExpr1, 1)
            endif
            if nNumb2 mod 10 == 0
                TweakNumb(nNumb2, nExpr2, 1)
            endif
        endwhile
        nNumDigits1 = Length( Str(nNumb1, 10) )
        nNumDigits2 = Length( Str(nNumb2, 10) )
    endif

    // If we still have to chop:
    if nNumDigits1 + nNumDigits2 > 9

        // 2. Don't chop a number that has 4 or less digits (the chopping can
        //     come from the other number as it's larger).
        // 3. Roundoff while chopping
        while nNumDigits1 + nNumDigits2 > 9
            if Length( Str(nNumb1, 10) ) > 4
                TweakNumb(nNumb1, nExpr1, 1)
                nNumDigits1 = Length( Str(nNumb1, 10) )
            endif
            if Length( Str(nNumb2, 10) ) > 4
                TweakNumb(nNumb2, nExpr2, 1)
                nNumDigits2 = Length( Str(nNumb2, 10) )
            endif
        endwhile
    endif

    // Now, go ahead and multiply
    nResNumb = nNumb1 * nNumb2
    nResExp = nExpr1 + nExpr2
    return()
end

// Handle decimal division
proc Divide(INTEGER nNumb1, INTEGER nExpr1, INTEGER nNumb2, INTEGER nExpr2)
    integer Remainder
    integer nDecCnt

    /*
    Normally, dividing is just division of the numbers and then subtracting
    exponents:
        35.1 / 72 = 0.4875
        351 E-1 --> 35.1    E: -1
         72 E0  --> 72         -0
        351 / 72 = 4.875    E-1
    But, as we can only do integer operations, we'll have to do special
    game-playing to deal with remainders.
    */
    // First get the integer result of the division
    nResNumb = nNumb1 / nNumb2        // 351 / 72 = 4
    nResExp = nExpr1 - nExpr2         // E-1 - E0 = E-1
    Remainder = nNumb1 mod nNumb2     // Rem = 63

    // If we have a remainder, we'll do successive integer divides.  We'll add
    //  up to 6 decimal places but we'll quit if the resulting number becomes
    //  too long (> 9 digits).
    if Remainder <> 0
        nDecCnt = 1
        while (Remainder <> 0 and nDecCnt <= 6 and not CheckLength(nResNumb, 8))

            // Multiply the remainder * 10
            //  Pass 1: 63 * 10 = 630
            //  Pass 2: 54 * 10 = 540
            //  Pass 3: 36 * 10 = 360
            Remainder = Remainder * 10

            // Now, multiply the result * 10.
            //  Pass 1:   4 * 10 = 40
            //  Pass 2:  48 * 10 = 480
            //  Pass 3: 487 * 10 = 4870
            nResNumb = (nResNumb * 10)

            // Divide the new remainder by the divisor and add it to the result
            //  Pass 1: 630 / 72 = 8    Result =   40 + 8 =   48
            //  Pass 2: 540 / 72 = 7    Result =  480 + 7 =  487
            //  Pass 3: 360 / 72 = 5    Result = 4870 + 5 = 4875
            nResNumb = nResNumb + (Remainder / nNumb2)

            // Since we added a digit, decrement the exponent
            //  Pass 1: E-1 - 1 = E-2
            //  Pass 2: E-2 - 1 = E-3
            //  Pass 3: E-3 - 1 = E-4
            nResExp = nResExp - 1

            // Get the new Remainder
            //  Pass 1: Remainder = 630 mod 72 = 54
            //  Pass 2: Remainder = 540 mod 72 = 36
            //  Pass 3: Remainder = 630 mod 72 = 0
            Remainder = Remainder mod nNumb2

            // Kick up our decimal count and do it again
            nDecCnt = nDecCnt + 1

            // Note that we'll exit this loop if the Remainder = 0
        endwhile
    endif   // Remainder <> 0
    return()
end

// Do a simple calculation between 2 numbers and an operator and put the
//  result in nResNumb and nResExp
proc Calculate(INTEGER nNum1, INTEGER nExp1, STRING Oper, INTEGER nNum2,
  INTEGER nExp2)

    /* Hex or Binary operations:
        >  SHR      (bitwise shift right)
        <  SHL      (bitwise shift left)
        %  MOD      (modulo division)
        &  AND      (bitwise AND)
        |  OR       (bitwise OR)
        ^  XOR      (bitwise eXclusive-OR)      */
    if CharInString(Oper, "><%&|^")

        // If either number has an exponent, we have to try to reduce it to
        //  0 before we can go on.
        if nExp1 <> 0
            bGotError = (not TweakNumb( nNum1, nExp1, nExp1 * (-1) ) )
        endif
        if nExp2 <> 0
            bGotError = (bGotError or (not
              TweakNumb( nNum2, nExp2, nExp2 * (-1) ) ) )
        endif
        if bGotError
           sErrorMsg = "Error - can't handle decimals in hex or binary math"
           return()
        endif

        // Here, both exponents are 0, so we can go on
        nResExp = 0
        case Oper

        //  >  SHR      (bitwise shift right)
        when '>'
            nResNumb = nNum1 shr nNum2

        //  <  SHL      (bitwise shift left)
        when '<'
            nResNumb = nNum1 shl nNum2

        //  %  MOD      (modulo division)
        when '%'
            nResNumb = nNum1 mod nNum2

        //  &  AND      (bitwise AND)
        when '&'
            nResNumb = nNum1 & nNum2

        //  |  OR       (bitwise OR)
        when '|'
            nResNumb = nNum1 | nNum2

        //  ^  XOR      (bitwise eXclusive-OR)
        otherwise
            nResNumb = nNum1 ^ nNum2
        endcase
        return()
    endif

    /* Here we have to handle decimal operations where we have to use our own,
       oh so swift, floating point library <g>.  We have to pay attention to
       the exponents as well as the math (I should have paid more attention to
       math theory instead of ogling girls in class.)
        +  Addition
        -  Subtraction
        *  Multiplication
        /  Division             */

    // First, addition or subtraction
    if (Oper == '+' or Oper == '-')
        AddSubtr(Oper == '+', nNum1, nExp1, nNum2, nExp2)

    // Multiplication
    elseif (Oper == '*')
        Multiply(nNum1, nExp1, nNum2, nExp2)

    // Division is the only operator left
    else    // (Oper == '/')
        Divide(nNum1, nExp1, nNum2, nExp2)
    endif

    // To keep later operations simpler, get rid of any trailing 0's and
    //  increment the exponents if we can
    while nResNumb <> 0 and nResNumb mod 10 == 0
        nResNumb = nResNumb / 10
        nResExp = nResExp + 1
    endwhile
    return()
end

// Handle expression parsing and calculating
proc ParseExpr(INTEGER bEndAtRParen)

    /* As we may possibly have decimals, but we can only perform integer
       calculations, we'll define numbers as a mantissa (always decimal) and
       a base 10 exponent (always decimal).

       GetNextToken() will convert all numbers into decimal (and will set the
       returned number type, nRetType, for the first number.

       As we have no unary operators, all expressions are in the form of
            numb1 oper1 numb2
       However, parentheses can alter this:
            numb1 oper1 (numb2 oper2 numb3)
       So, we'll have to evaluate (numb2 oper2 numb3) and make the result =
       numb2 before we can evaluate numb1 oper1 numb2. Therefore, a
       parenthesis will trigger a new number retreival, and calculation event.

       Further, there may be some implied numbers or operators in the block:
        A. Column block numbers have an implied + before the number (unless
            something else is entered).
        B. Expressions like (4+2)(3+5) have an implied * between the
            parentheses.
        C. An expression like (-123)*45 simply indicates that we're to
            multiply 45 times a negative number, e.g. the expression really is
            (0-123)*45.
        D. An expression like 23(145+2) has an implied operator "*" before the
            (145+2).

       Starting out, the possibilities are that the first entry on the line
       can be:
               a number: 23(145+2)
            parentheses: (4+2)(3+5)
            an operator: -2+45

       Further, my examples show relatively simple expressions, but we could
       have a whole series of stuff: -2+45-3+210...

       So, we'll seed the pot with "0+" as our first number and operator.
       Thereafter, we expect a number; if we get it we have a simple
       expression to calculate (numb1 oper1 numb2).  If we get parentheses or
       an operator, we'll have to call ourselves to deal with it.
    */
    integer     Numb1 = 0           // Mantissa #1
    integer     Exp1 = 0            // Exponent #1 - 10^0 = 1
    string      Oper[1] = '+'       // Operator
    integer     Numb2               // Mantissa #2
    integer     Exp2                // Exponent #2

    // Stay in a loop until we've got everything
    repeat

        // Get the next token
        GetNextToken()
        if bGotError
            return()
        endif

        // Act on the Token Type - first a number
        if nTokenType == is_Number

            // If we have no operator, there is an implied + between numbers.
            if Oper == " "
                Oper = "+"
            endif

            // Put this number in Numb2 and Exp2
            Numb2 = nTokenNumber
            Exp2  = nTokenExponent

            // Go perform the calculation.
            Calculate(Numb1, Exp1, Oper, Numb2, Exp2)

            // Put the result in Numb1 and Exp1.
            Numb1 = nResNumb
            Exp1  = nResExp

            // Clear the operator - we don't know what's coming next.
            Oper = " "

        // Token is an operator
        elseif nTokenType == is_Oper

            // Change our assumed operator and that's it
            Oper = sToken

        // Token is a left parenthesis
        elseif nTokenType == is_LParen

            // If we don't have an operator yet, assume a "*"
            if Oper == " "
                Oper = "*"
            endif

            // Call ourself noting that we want a return on a right parenthesis
            ParseExpr(TRUE)
            if bGotError
                return()
            endif

            // The result is in nResNumb and nResExp.  Put that in Numb2 and Exp2.
            Numb2 = nResNumb
            Exp2  = nResExp

            // Calculate the result of Numb1 Oper Numb2
            Calculate(Numb1, Exp1, Oper, Numb2, Exp2)

            // Put the result in Numb1 and Exp1.
            Numb1 = nResNumb
            Exp1  = nResExp

            // Clear the operator - we don't know what's coming next.
            Oper = " "

        // Token is a right parenthesis
        elseif nTokenType == is_RParen

            // If we're supposed to return on a right parenthesis, put Numb1
            //  and Exp1 into nResNumb, nResExp
            if bEndAtRParen
                nResNumb = Numb1
                nResExp  = Exp1
                return()
            else

                // Oops, too many right parenthesis
                bGotError = TRUE
                sErrorMsg = "Syntax error - unbalanced parentheses"
                return()
            endif

        // Or, the other possibility is that nTokenType = 0, this means that
        //  we're at the end of the Block/File.  bAtEof will then be set to
        //  TRUE, so we should exit. But, that Ken is a lazy sot and may not
        //  have entered trailing parentheses - so we have to cover for him.
        elseif (bAtEof and bEndAtRParen)

            // Act like we're supposed to for a right parenthesis
            nResNumb = Numb1
            nResExp  = Exp1
            return()
        endif

        // Go get the next token and keep on keeping on until we're done
    until (bGotError or bAtEof)

    // That's all folks.
end

// Convert nResNumb and nResExp into a string in sRetRes based on passed type
proc Numb2String(INTEGER nType)
    string  TempStr[15]

    // We want to convert the number to E0 if possible.  We'll ignore any
    // errors as the the result will only be changed as reasonable.  To do
    // this, we have two possibilities:
    //  1. Trim trailing 0s: 123000 E-2.  But, only for negative exponents
    while nResExp < 0 and nResNumb mod 10 == 0 and Length(Str(nResNumb,10)) < 9
        nResNumb = nResNumb / 10
        nResExp = nResExp + 1
    endwhile

    //  2. Add trailing 0s: 5 E2
    while nResExp > 0 and Length(Str(nResNumb,10)) < 9
        nResNumb = nResNumb * 10
        nResExp = nResExp - 1
    endwhile

    // Hexadecimal and Binary numbers require exponents of 0
    if (nType == is_HEX or nType == is_BINARY)
        if nResExp <> 0
            bGotError = TRUE
            sErrorMsg = "Number too large or has fractions - can't calculate"
            return()
        endif

        // Otherwise, do the conversion
        if nType == is_HEX
            sRetRes = UPPER( Str(nResNumb, 16) ) + 'h'
        else    // nType == is_BINARY
            sRetRes = Str(nResNumb, 2) + 'b'
        endif

    // Decimal
    else    // nType == is_DECIMAL

        // Base 10 string conversion
        sRetRes = Str(nResNumb, 10)

        // Adjust based on the exponent (if we have one).
        if nResExp > 0

            // Positive exponents require adding 0s (e.g. 5 E2 --> 500)
            while nResExp > 0
                sRetRes = sRetRes + '0'
                nResExp = nResExp - 1
            endwhile

        elseif nResExp < 0

            // Negative exponents require either inserting a decimal point or
            //  adding leading 0s.  This depends on whether the exponent is
            //  outside of the current string length
            nResExp = (nResExp * (-1))
            if nResExp < Length(sRetRes)

                // The exponent is within the string length.  So, insert a
                //  decimal point (e.g. 550 E-2 --> 5.50).
                //      Example: 12345 E-2 --> 123.45, Length = 5
                //      TempStr = SubStr(str, 5 - 2 + 1, 15) = "45"
                TempStr = SubStr(sRetRes, Length(sRetRes) - nResExp + 1, 15)

                //      sRetStr = SubStr(str, 1, 5-2) = "123" + ',' + '45'
                sRetRes = SubStr(sRetRes, 1, Length(sRetRes) - nResExp)
                  + "." + TempStr
            else

                // The exponent is outside of the string length.  Two examples:
                //      1.    550 E-4 --> 0.0550
                //      2. 545454 E-6 --> 0.545454
                // So, how many leading 0's do we need to add?
                nResExp = nResExp - Length(sRetRes)

                // Add as many leading 0s as we need
                //      1.    550 E-4 --> Length = 3, 4-3 = add 1
                //      2. 545454 E-6 --> Length = 6, 6-6 = add 0
                while nResExp > 0
                    sRetRes = '0' + sRetRes
                    nResExp = nResExp - 1
                endwhile

                // Now add the leading "0."
                sRetRes = '0.' + sRetRes
            endif   // nResExp > Length(sRetRes)
        endif   // elseif nResExp < 0
    endif   // nType == is_DECIMAL
    return()
end                                   

// Main control routine
proc Main()
    integer     CurrFileID
    integer     SysBuffID

    // Gotta have a block somewhere
    if not IsBlockMarked()
        Warn("No block is marked to calculate")
        return ()
    endif

    // Save the current block and cursor settings
    PushBlock()
    PushPosition()

    // Save the current Buffer ID and create a new, temporary _SYSTEM_ buffer
    CurrFileID = GetBufferID()          // Current file
    SysBuffID = CreateTempBuffer()
    if SysBuffID == 0
        Message("Not enough memory for calculation buffer")
    else

        // Initialize the global variables (they won't change after the
        //  first run).
        bGotError = 0
        bAtEof = FALSE
        nRetType = 0
        nResNumb = 0
        nResExp = 0

        // Copy the block into the temporary buffer
        GotoBufferId(SysBuffID)
        CopyBlock()
        BegFile()

        // Skip any leading whitespace
        while isWhite()
            bAtEof = (not NextChar())
        endwhile

        // If we're at EOF, something's goofy
        if bAtEof
            bGotError = TRUE
            sErrorMsg = "Nothing to do (unexpected End of Block)"

        // Else, go do the calculation
        else

            // Start by assuming we have a simple expression in the form of
            //  numb1 oper1 numb2, and our only job is to extract the 3 terms
            //  and calculate the result. Functions will be called recursively
            //  if we encounter parentheses.
            ParseExpr(FALSE)

            // The result is in nResNumb and nResExp.  Convert the result into
            // a string in sRetRes based on the number type in nRetType.
            Numb2String(nRetType)
        endif
    endif   // SysBuffID > 0

    // Go back to the current file and restore the settings
    GotoBufferId(CurrFileID)
    PopBlock()
    PopPosition()

    // If we have an error, display the error message
    if bGotError
        Warn(sErrorMsg)
    else

        // Otherwise, insert the result at the cursor position based on the
        // current insert/overwrite status.
        InsertText( sRetRes, _DEFAULT_ )
    endif

    // Kill our temporary buffer if we got it
    if SysBuffID > 0
        AbandonFile(SysBuffID)
    endif

    // Done
    return()
end