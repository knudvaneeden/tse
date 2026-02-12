/*
TSE-Cal v2.0

A floating point math package and calculator for TSE.

Curtis Repen

Portions by David Marcus and Mel Hulse

Fri  01-15-1993  12:38:49 cmr - started eval stuff
Tue  01-19-1993  13:31:59 cmr - first release
Thu  01-21-1993  11:02:33 cmr - fixed solo '-' bug
Tue  01-26-1993  11:36:34 cmr - if only one number found, use existing
                                result as first operand
Tue  01-26-1993  11:41:01 cmr - fixed bug with 0 operand, and with
                                displaying negative results with
                                exponent >= 0
Thu  02-04-1993  16:16:44 cmr - merged Mel's notrailingzeros and %
                                function, fixed a (bad) bug in division
                                with result < 0
Fri  02-05-1993  16:01:10 cmr - separated "add" from tabulate, rolled
                                number-gathering into calculate(),
                                removed *fn()
Tue  04-13-1994  11:45:00 mwh - removed stub for tape buffer not
                                done. Added comments.  Removed
                                debug code. Now finds over commas
                                in input and formats them into
                                output.  Provided warning for
                                possible error with large
                                numbers.  Requires column block
                                for multiline input.
sat  04-15-94    17:30:00 mwh - Designated "version 2.0" Added
                                averaging.  Problem discovered
                                dividing and averaging negative
                                numbers.  Attempted to trap these
                                cases and prohibit them.
Operation:

    TSE-Cal is a floating point calculator.  It works on single
    line block or column block marked text.  It uses assigned
    keys or a menu to select the action desired.  Results are
    available for pasting into the text or as an input to a
    following math action.

    Senses negative numbers. Ignores non-numeric characters (EG.
    $) preceding and following numbers. Ignores commas within
    numbers.  If used in the input, "$" and/or "," are shown in
    output.

    Two math modes are available.

        The calculate mode.

        If one number is blocked, it will act on the results of
        the previous math action.  If there has not been an
        action, zero is assumed is the previous result.

        If two numbers are blocked, the second number will act on
        the first.

        If three numbers are blocked, only the first two will be
        used.

        Tabulate mode. Two versions here:

            Sums a list of blocked numbers, vertical or
            horizontal. This is similiar to the supplied SUM
            macro, except that it will handle floating point
            numbers.

            Averages a list of blocked numbers.

    Insert the result.  The last computed result will be inserted
    at the cursor using the current insert toggle status.

    WARNING.

    TSE implements integer arithmetic. TSE-CAL is limited by the
    maximum and minimum integer size of numbers TSE can handle.
    Generally, input numbers should be limited to 8 digits or
    less.  The final digits of answers are usually correct to 9
    significant digits.  Order of magnitudes should be correct. A
    warning is issued for possibly suspect numbers.

    An error results in some cases when multiplying, dividing and
    averaging negative numbers.  Some of these cases are trapped,
    but there appear to be others.

    I am still not sure if I have fixed all cases where an
    infinite loop can occur.  For this reaso, I have left <break>
    ON.

    Appreciate any suggestions on improving the division algorythm.

           > .\\êú «≥uúse, Silicon Valley - Team TSE <
              Internet: Mel.Hulse@LIMS.Lockheed.com
****************************************************************/

constant ADD        = 0
constant SUBTRACT   = 1
constant MULTIPLY   = 2
constant DIVIDE     = 3
constant PERCENT    = 4
constant AVERAGE    = 5

STRING resultstr[70]

// Check for block and for blocks longer than one line, column block.

proc blockcheck()

    integer beg,
            ending

    If (isBlockMarked() == FALSE)           // Be sure there is a block
        warn("No block is marked... ")
        popposition()
        Halt
    EndIf

    pushposition()
    gotoblockbegin()
    beg = currline()
    gotoblockend()
    ending = currline()
    popposition()

    if beg <> ending AND isblockincurrfile() <> _COLUMN_
        warn("Multiline input requires a column block... ")
        Halt
    endif
end

proc neg_warning()
    warn("Negative number not supported in this case... ")
    halt
end

//  Check if a character is numeric.

integer proc isNumeric(integer char)

    if ( ( char >= Asc('0')) AND  ( char <= Asc('9')) )
        return(TRUE)
    endif

    return(FALSE)
end isNumeric

integer mantissa    //  working mantissa
integer exponent    //  working exponent

Integer dollar_sign = FALSE
Integer comma       = FALSE

integer accu_m
integer accu_e

integer blkendline
integer warning     = FALSE

//  Parse user's string into mantissa and exponent and determine if
//  number is negative.

integer proc getnum()

    integer endofblock = FALSE
    integer isnegative = FALSE
    integer gotdecimal = FALSE
    integer done = FALSE
    string numstr[12] = ""

    mantissa = 0
    exponent = 0

    while((done       <> TRUE) AND
          (endofblock <> TRUE))

        if ((isNumeric(currchar()) == FALSE) AND
              (currchar() <> Asc('$')) AND
              (currchar() <> Asc('-')) AND
              (currchar() <> Asc('.')))
            right()
        else

            if (currchar() == Asc('$'))
                dollar_sign = TRUE
                right()
            endif

            if (currchar() == Asc('-'))
                isNegative = TRUE
                right()
            endif

            if (currchar() == Asc('.'))
                gotdecimal = TRUE
                right()
            endif

            while((isnumeric(currchar())
                 OR (currchar() == Asc('.'))
                 OR (currchar() == Asc(',')))
                 AND (isCursorInBlock() <> FALSE))

                if (currchar() == Asc('.')) // Check for second decimal.
                    if (gotdecimal == FALSE)
                        gotdecimal = TRUE
                    else
                        Warn("Number has 2 decimals. . . Aborted")
                        popposition()
                        Halt
                    endif
                elseif currchar() == Asc(',')
                    comma = TRUE
                else
                    done = TRUE
                    if ( ((MAXINT / 10) ) >= val(numstr) )
                        numstr = numstr + chr(currchar())   // Concat. mantissa
                        if (gotdecimal == TRUE)     // Determine exponent.
                            exponent = exponent - 1
                        endif
                    else
                        if (gotdecimal == FALSE)
                            exponent = exponent + 1
                        endif
                    endif
                endif
                right()
            endwhile

// Get rid of trailing zeros.
            if (done == TRUE)
                mantissa = val(numstr)
                while (((( mantissa / 10) * 10) == mantissa)
                      AND (mantissa <> 0))
                    mantissa = mantissa / 10
                    exponent = exponent + 1
                endwhile
                if (isNegative == TRUE)
                    mantissa = -mantissa
                endif
            endif
        endif

//  Handle vertical list.
        if(isCursorInBlock() == FALSE)
            if (down() == FALSE)
                endofblock = TRUE
            else
                begline()
                if (currline() > blkendline)
                    endofblock = TRUE
                else
                    while(isCursorInBlock() == FALSE)
                        right()
                    endwhile
                endif
            endif
        endif
    endwhile
    return(done)
end getnum


//  Convert the computed mantissa and exponent to a string.

proc integer_notation_to_string(integer mantissa,
                                integer exponent,
                                integer operation)
    INTEGER
        negative_flag = iif(mantissa < 0, TRUE, FALSE),
        i = 0

        /************************
        * truncate trailing zeroes
        * after decimal point
        *************************/

    while (((( mantissa / 10) * 10) == mantissa)
           AND (exponent < 0))
        mantissa = mantissa / 10
        exponent = exponent + 1
    endwhile

    resultstr = Str(abs(mantissa))

    while(exponent > 0)
        resultstr = resultstr + "0"
        exponent = exponent - 1
    endwhile

    If length(resultstr) > 9
        warning = TRUE
    endif

    if (exponent < 0)

        /* Add leading Zeroes; might be needed after decimal point */

        while (Length(resultstr) <= Abs(exponent) - 1)
            resultstr = '0' + resultstr
        endwhile

        /* Insert the '.' */
        resultstr =
            SubStr(resultstr, 1, Length(resultstr) - Abs(exponent)) + '.' +
            SubStr(resultstr, Length(resultstr) - Abs(exponent) + 1,
                   Abs(exponent) )
    endif


    if comma == TRUE
        i = POS(".", resultstr)
        if i == 0
            i = length(resultstr) + 1
        endif
        while i > 4
            resultstr = substr(resultstr, 1, i - 4) + "," +
                        substr(resultstr, i - 3, length(resultstr))
            i = i - 3
        endwhile
    endif

    if (negative_flag == TRUE)
        resultstr = "-"+resultstr
    endif

    if dollar_sign == TRUE AND operation <> PERCENT
        resultstr = "$"+resultstr
    endif
end

//  Adds two numbers represented as mantissas and exponents.

proc math_add(integer m1, integer e1,integer m2,integer e2)
    integer m3
    integer e3
    integer maxintok = FALSE

    if (e2 > e1)
        e3 = e2
        m3 = m2

        e2 = e1
        m2 = m1

        e1 = e3
        m1 = m3
    endif

    while (e1 <> e2)
        if ((MAXINT / 10) > m1)
            e1 = e1 - 1
            m1 = m1 * 10
        else
            e2 = e2 + 1
            m2 = m2 / 10
        endif
    endwhile

    if ( (m1 > 0) AND ( m2 > 0) AND ((MAXINT - m2) > m1) )
        maxintok = TRUE
    endif

    if ( (m1 < 0) AND ( m2 < 0) AND ((-MAXINT - m2) < m1) )
        maxintok = TRUE
    endif

    if ( (m1 < 0) AND ( m2 > 0))
        maxintok = TRUE
    endif

    if ( (m1 > 0) AND ( m2 < 0))
        maxintok = TRUE
    endif

    if ( (m1 == 0) OR ( m2 == 0))
        maxintok = TRUE
    endif


    if (maxintok == FALSE)
        e1 = e1 + 1
        e2 = e2 + 1
        m1 = m1 / 10
        m2 = m2 / 10
    endif

    m2 = m2 + m1

    accu_e = e2
    accu_m = m2

end math_add

//  Subtracts the second number from the first as represented by
//  their mantissas and exponents.

proc math_sub(integer m1, integer e1,integer m2,integer e2)
    integer m3
    integer e3
    integer maxintok = FALSE
    integer swapped = FALSE

    if (e1 < e2)
        swapped = TRUE
        e3 = e2
        m3 = m2

        e2 = e1
        m2 = m1

        e1 = e3
        m1 = m3
    endif

    while (e1 <> e2)
        if ((MAXINT / 10) > m1)
            e1 = e1 - 1
            m1 = m1 * 10
        else
            e2 = e2 + 1
            m2 = m2 / 10
        endif
    endwhile

    if (swapped == TRUE)
        e3 = e2
        m3 = m2
        e2 = e1
        m2 = m1
        e1 = e3
        m1 = m3
    endif

    if ( (m1 > 0) AND ( m2 < 0) AND ((MAXINT + m2) > m1) )
        maxintok = TRUE
    endif

    if ( (m1 < 0) AND ( m2 > 0) AND ((-MAXINT + m2) < m1) )
        maxintok = TRUE
    endif

    if ( (m1 > 0) AND ( m2 > 0))
        maxintok = TRUE
    endif

    if ( (m1 < 0) AND ( m2 < 0))
        maxintok = TRUE
    endif

    if ( (m1 == 0) OR ( m2 == 0))
        maxintok = TRUE
    endif

    if (maxintok == FALSE)
        e1 = e1 + 1
        e2 = e2 + 1
        m1 = m1 / 10
        m2 = m2 / 10
    endif

    m2 = m1 - m2
    accu_e = e2
    accu_m = m2

end math_sub

//  Multiplies two numbers as represented by their mantissas and exponents.

proc math_mult(integer m1, integer e1,integer m2,integer e2)
    integer m3
    integer e3

    if m1 < 0
        neg_warning()
    endif

    if ((m1 == 0) OR (m2 == 0))
        m2 = 0
        e2 = 0
        return()
    endif

    if (e1 < e2)
        e3 = e2
        m3 = m2

        e2 = e1
        m2 = m1

        e1 = e3
        m1 = m3
    endif

    while ( ( MAXINT / m1) < abs(m2) )
        if (m1 >= m2)
            m1 = m1 / 10
            e1 = e1 + 1
        else
            m1 = m1 / 10
            e1 = e1 + 1
        endif
    endwhile

    m2 = m1 * m2
    e2 = e1 + e2
    accu_e = e2
    accu_m = m2

end math_mult

//  Divides the first number by the second as represented by
//  their mantissas and exponents.

proc math_div(integer m1, integer e1,integer m2,integer e2)

    if m1 < 0
        neg_warning()
    endif

    if (m1 == 0)
        m2 = 0
        e2 = 0
        return()
    endif

    if (m2 == 0)
        warn("Division by Zero - Aborted")
        return()
    endif

    while ( ( MAXINT / 10) > m1 )
        m1 = m1 * 10
        e1 = e1 - 1
    endwhile

    m2 = m1 / m2
    e2 = e1 - e2

    accu_e = e2
    accu_m = m2

end math_div

//  Cycles through a marked block to add each succeding number to
//  the sum of previous numbers in the block.

proc tabulatefn(integer operation)
    integer i = 0

    set(break,on)

    dollar_sign = FALSE
    comma       = FALSE
    accu_m      = 0
    accu_e      = 0

    pushposition()

    blockcheck()

    gotoblockend()
    blkendline = currline()
    gotoblockbegin()

    while (getnum() == TRUE)
        math_add(accu_m, accu_e, mantissa, exponent)
        i = i + 1
    endwhile

    if operation == AVERAGE
        math_div(accu_m, accu_e, i, 0)
    endif

    integer_notation_to_string(accu_m, accu_e, ADD)
    Message("Answer = " + resultstr + "  ")
    popposition()
    set(break,off)
end tabulatefn

//  Manages all two number math functions and displays the result.

proc calculate(integer operation)
    integer tempmantissa
    integer tempexponent

    set(break,on)
    dollar_sign = FALSE
    comma       = FALSE

    pushposition()

    blockcheck()

    gotoblockend()
    blkendline = currline()
    gotoblockbegin()

    if (getnum() == TRUE)
        TempMantissa = Mantissa
        TempExponent = Exponent
        if (getnum() == TRUE)
            accu_m = TempMantissa
            accu_e = TempExponent
        else
            Mantissa = TempMantissa
            Exponent = TempExponent
        endif
        case operation
            when ADD
                math_add(accu_m, accu_e, mantissa, exponent)
            when SUBTRACT
                math_sub(accu_m, accu_e, mantissa, exponent)
            when MULTIPLY
                math_mult(accu_m, accu_e, mantissa, exponent)
            when DIVIDE
                math_div(accu_m, accu_e, mantissa, exponent)
            when PERCENT
                math_div(accu_m, accu_e, mantissa, exponent-2)
        endcase
    else
        Warn("No Numbers Found")
    endif

    integer_notation_to_string(accu_m, accu_e, operation)
    if (operation == PERCENT)
        resultstr = resultstr + "%"
    endif

    if warning
        resultstr = resultstr + " (Last digits may be truncated or zeroed)"
    endif

    Message("Answer = " + resultstr + "  ")

    popposition()
    set(break,off)
end calculate

//  Pastes the result of the last math action.

proc paste_result()
    Inserttext(resultstr)
end paste_result

//  Menu to select desired functions.

Menu Math()
    History
    Title = "Math Functions"
    "&Tabulate marked numbers" ,  TabulateFn(ADD)
    "A&Verage marked numbers"  ,  TabulateFn(AVERAGE)
    "&Add 2 numbers"           ,  Calculate(ADD)
    "&Subtract"                ,  Calculate(SUBTRACT)
    "&Multiply"                ,  Calculate(MULTIPLY)
    "&Divide"                  ,  Calculate(DIVIDE)
    "&Percent"                 ,  Calculate(PERCENT)
    "&Insert the result"       ,  Paste_Result()
End

//  Suggested keys if you can sacrifice the default use of <ctrl m>.

<ctrl m><t>         TabulateFn(ADD)
<ctrl m><v>         TabulateFn(AVERAGE)
<ctrl m><a>         Calculate(ADD)
<ctrl m><s>         Calculate(SUBTRACT)
<ctrl m><m>         Calculate(MULTIPLY)
<ctrl m><d>         Calculate(DIVIDE)
<ctrl m><p>         Calculate(PERCENT)
<ctrl m><i>         Paste_Result()
<ctrl m><u>         Math()

