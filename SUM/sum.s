// SUM 1.0.0.0.1 - 2026-10-05 13:49:46 +02:00
// Overflow protection and documentation: GPT-6 (OpenAI)
/*************************************************************************
  Sum         Sums a column of numbers marked as a COLUMN block

  Author:     SemWare

  Date:       Jun 12, 1992 - Initial version (Steve Watkins)
              Apr 11, 1994 - Bug fixes and rework (Steve Watkins)
              Feb  9, 2002 - Handle non OEM fonts. (Ross Boyd)
              Nov 11, 2011 - Handle accounting style negatives (100)
                             Ignore leading $ (SEM)
  Overview:

  This macro sums up a column of numbers that have been marked in the
  text as a column block.  The result is optionally inserted in the
  text.  Sum handles decimal and hexadecimal numbers.  For decimal
  numbers, it accepts positive and negative (identified with a
  preceding "-" sign) numbers. Fractions are rejected. It
  also supports accounting style negative numbers: (75).
  Version 1.0.0.0.1 accepts signed 32-bit integers only.

  Keys:       (none)

  Usage notes:

  This macro does not have any key assignments.  To use, simply select
  it from the Potpourri menu.

  Sums either base 10 (decimal), base 16 (hexadecimal), or mixed.

  Fractions are disallowed for all bases in version 1.0.0.0.1.

  For base 16, a preceding '0x' is ignored, as is a trailing 'h'.

  For mixed base, a preceding '0x' or a valid hexadecimal letter a-f
  or a trailing 'h' forces base 16 for that entry. Otherwise, base 10
  is assumed.

  Inputs and each running total must fit signed 32-bit integers.

  Commas within a number are ignored.

  Only the final result is placed in the necessary form for display.

  To find a number, the cursor scans left to right until a numeric
  sign or valid number is encountered.  Only whitespace is skipped.
  Also, only one sign is allowed.  In other words, --1 is not allowed.

  Copyright 1992-1995 SemWare Corporation.  All Rights Reserved Worldwide.

  Use, modification, and distribution of this SAL macro is encouraged by
  SemWare provided that this statement, including the above copyright
  notice, is not removed; and provided that no fee or other remuneration
  is received for distribution.  You may add your own copyright notice
  to cover new matter you add to the macro, but SemWare Corporation will
  neither support nor assume legal responsibility for any material added
  or any changes made to the macro.

*************************************************************************/

constant BASE_10    = 1,
         BASE_16    = 2,
         BASE_MIXED = 3

constant ins_DECIMAL        =   0x01,   // insert the sum in decimal
         ins_HEX            =   0x02,   // insert the sum in hex
         ins_END_OF_BLOCK   =   0x04,   // insert sum at end of block
         ins_CURSOR         =   0x08    // insert sum at cursor

constant NONE               =   0x00,
         LEADING_0X         =   0x01,
         TRAILING_H         =   0x02

string  dec_sum[20]         // formatted decimal 'sum' string
string  hex_sum[20]         // formatted hex 'sum' string
integer sum_type            // type of sum specified
integer hex_format          // format for hex ('h' or '0x')


constant SUM_MAX = 2147483647,
         SUM_MIN = -2147483647 - 1
integer GBSilent = FALSE
integer GBOverflow = FALSE
string GSWarning[255] = ""

proc PROCWarn(string messageS)
    GSWarning = messageS
end

integer proc FNCanAdd(integer leftI, integer rightI)
    if rightI > 0
        if leftI > SUM_MAX - rightI
            GBOverflow = TRUE
            return(FALSE)
        endif
    elseif rightI < 0
        if leftI < SUM_MIN - rightI
            GBOverflow = TRUE
            return(FALSE)
        endif
    endif
    return(TRUE)
end

// Accumulate negatively so -2147483648 is accepted without negation.
integer proc FNParseInteger(string numberS, integer radixI, integer negativeI)
    integer indexI, digitI, resultI = 0, limitI = -2147483647
    if negativeI
        limitI = SUM_MIN
    endif
    for indexI = 1 to Length(numberS) by 1
        digitI = Pos(Lower(SubStr(numberS,indexI,1)),"0123456789abcdef") - 1
        if digitI < 0 or digitI >= radixI
            return(0)
        endif
        if resultI < limitI / radixI
            GBOverflow = TRUE
            return(0)
        endif
        resultI = resultI * radixI
        if resultI < limitI + digitI
            GBOverflow = TRUE
            return(0)
        endif
        resultI = resultI - digitI
    endfor
    if negativeI
        return(resultI)
    endif
    return(-resultI)
end

proc InsertSum(integer flags)
    if (flags & ins_END_OF_BLOCK)
        GotoBlockEnd()
        GotoColumn(Query(BlockBegCol))
        if not Down()
            Addline()
        elseif CurrLineLen() <> 0
            InsertLine()
        endif
    endif
    InsertText(iif(flags & ins_DECIMAL, dec_sum, hex_sum), _INSERT_)
end


integer proc InsertSumHistory()
    if hex_format or sum_type == BASE_16
        return (7)
    endif
    return (3)
end

Menu InsertSumMenu()
    history = InsertSumHistory()
    title = "Decimal sum"

    ""  [dec_sum: sizeof(dec_sum)]  ,                       ,   Skip
    "Insert at cursor"          ,   InsertSum(ins_DECIMAL)
    "Insert at end of block"    ,   InsertSum(ins_DECIMAL | ins_END_OF_BLOCK)
    "Hex sum"                      ,                        ,   Divide
    ""  [hex_sum: sizeof(hex_sum)]  ,                       ,   Skip
    "Insert at cursor"          ,   InsertSum(ins_HEX)
    "Insert at end of block"    ,   InsertSum(ins_HEX | ins_END_OF_BLOCK)
end

// Helper routines to display status as numbers are being summed

integer bar_total, bar_complete, bar_resolution, bar_size, bar_open

proc SetupBar(string title, integer size)
    bar_total = 0
    bar_complete = 0
    bar_size = size
    bar_resolution = bar_size / 40
    bar_open = PopWinOpen(20,10,61,12,1,title,Color(Red))
    if bar_open
        ClrScr()
    endif
end

proc UpdateBar()
    string barS[40] = ""
    integer indexI
    bar_complete = bar_complete + 1
    bar_total = bar_total + 1
    if bar_complete > bar_resolution and bar_open
        bar_complete = 0
        GotoXY(1,1) // physically move cursor to reduce flicker
        Set(Attr,Color(Green))
        // JHB: Handle non OEM fonts...
        for indexI = 1 to 40 by 1
            barS = barS + Chr(219)
        endfor
        PutOemLine(SubStr(barS, 1, bar_total / bar_size * 40
                   + (bar_total mod bar_size) * 40 / bar_size),40)
    endif
end

proc CloseBar()
    if bar_open
        PopWinClose()
    endif
end

// Skip white space within block
proc SkipWhite()
    while isWhite() and isCursorInBlock() and Right()
    endwhile
end

integer base

proc SetBase10()
    Set(WordSet, ChrSet('[0-9]'))
    base = 10
end

proc SetBase16(integer form)
    Set(WordSet, ChrSet('[0-9A-Fa-f]'))
    base = 16
    if (hex_format == 0)
        hex_format = form
    endif
end

/* SUM:

   This procedure sums the values within a column block.
   It is intended for the summation of numbers.  If invalid
   characters appear within the block, this will affect the result.
*/

proc Sum(integer type)
    integer int_total,              // integral part of sum
            int_part,               // integral part of number
            block_width,            // width of column block
            error,                  // TRUE if input or range is invalid
            negative                // is this a negative number

    string s[32]                            // temp string for number
    string savewordset[32] = Query(WordSet) // wordset of valid numbers

    if IsBlockInCurrFile() <> _COLUMN_
        PROCWarn("Column block must be marked in current file")
        return ()
    endif

    SetupBar("Summing", Query(BlockEndLine) - Query(BlockBegLine) + 1)

    error = FALSE
    int_total = 0
    hex_format = NONE
    sum_type = type

    block_width = Query(BlockEndCol) - Query(BlockBegCol) + 1
    if (block_width > sizeof(s))
        // the user could increase the size of s if necessary
        PROCWarn("Block too wide")
        CloseBar()
        return()
    endif

    PushBlock()
    Set(Marking,OFF)

    PushPosition()
    GotoBlockBegin()

    repeat
        if type == BASE_16
            SetBase16(NONE)
        else
            SetBase10()
        endif

        // skip to first non-white character
        SkipWhite()

        s=''    // clear storage string for number
                // use temp string since we don't necessarily
                // know the base yet

        if isCursorInBlock()

            // determine sign of number
            negative = FALSE
            case CurrChar()
                when ASC('+'), ASC('$')
                    Right()
                when ASC('-')
                    negative = TRUE
                    Right()
                when ASC('(')
                    PushPosition()
                    loop
                        if not Right() or CurrChar() < 0
                            PopPosition()
                            break
                        endif
                        if CurrChar() == ASC(')')
                            negative = TRUE
                            PopPosition()
                            Right()
                            break
                        endif
                    endloop
            endcase

            SkipWhite()

            if type <> BASE_10
                // see if leading 0x
                if CurrChar() == ASC('0')
                    if Right() and isCursorInBlock() and Lower(Chr(CurrChar())) == 'x'
                        Right()
                        SetBase16(LEADING_0X)
                    endif
                endif
            endif

            // get integral part of number
            loop

                if not isCursorInBlock()
                    break
                endif

                if isWord()
                    s = s + chr(CurrChar())
                elseif type == BASE_10 and CurrChar() == ASC(',')
                    // do nothing
                elseif type == BASE_MIXED and Pos(Chr(CurrChar()),"ABCDEFabcdef")
                    SetBase16(TRAILING_H)
                else
                    break
                endif

                if not Right()
                    break
                endif

            endloop

            if type <> BASE_10 and isCursorInBlock() and Lower(Chr(CurrChar())) == 'h'
                SetBase16(TRAILING_H)
            endif

            // add the integral part of the number
            int_part = FNParseInteger(s, base, negative)
            if GBOverflow
                error = TRUE
                break
            endif
            if not FNCanAdd(int_total, int_part)
                error = TRUE
                break
            endif
            int_total = int_total + int_part


            if CurrChar() == ASC('.')
                PROCWarn("SUM accepts integers only; fractional input is not allowed. No result inserted.")
                error = TRUE
                break
            endif

        endif

        UpdateBar()         // update status

        GotoColumn(Query(BlockBegCol))

    until error or not down() or not IsCursorInBlock()

    Set(WordSet, SaveWordSet)

    PopPosition()
    PopBlock()
    CloseBar()

    // Prompt on what to do with the sum if there were no errors

    if not error
        // convert sum to string so we can adjust the decimal places, etc
        if int_total == SUM_MIN
            dec_sum = "2147483648"
        else
            dec_sum = str(abs(int_total))
        endif
        //   // integral value as decimal string
        if (int_total < 0)
            dec_sum = '-' + dec_sum
        endif

        hex_sum = str(int_total, 16)    // integral value as hex string
        case hex_format
            when LEADING_0X
                hex_sum = '0x' + hex_sum
            when TRAILING_H
                hex_sum = hex_sum + 'h'
        endcase

        // try to format the sum into the same width of the block
        // if possible

        if (length(dec_sum) < block_width)
            dec_sum = format(dec_sum:block_width)
            hex_sum = format(hex_sum:block_width)
        endif

        InsertSumMenu()

        UpdateDisplay(_STATUSLINE_REFRESH_)
    endif
end Sum

menu SumMenu()
    title = "Sum"
    history

    "&Decimal",     Sum(BASE_10)
    "&Hexadecimal", Sum(BASE_16)
    "&Mixed",       Sum(BASE_MIXED)
end

proc Main()
    string iniS[255] = "sum.ini"
    GSWarning = ""
    GBOverflow = FALSE
    if not FileExists(iniS)
        iniS = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + "sum.ini"
    endif
    GBSilent = Lower(GetProfileStr("sum", "silent", "false", iniS)) == "true"
    SumMenu()
    if GBOverflow
        GSWarning = "SUM: 32-bit limit exceeded (maximum 2147483647, minimum -2147483648). No result inserted. Run the TSE SAL macro BigIntSum instead."
    elseif GSWarning == ""
        GSWarning = "SUM 1.0.0.0.1: Mark a COLUMN block, run Sum, choose Decimal, Hexadecimal or Mixed, then choose where to insert the result."
    endif
    if not GBSilent
        Warn(GSWarning)
    endif
end
