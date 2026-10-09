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
  preceding "-" sign) numbers, as well as decimal-point fractions. It
  also supports accounting style negative numbers: (75).

  Keys:       (none)

  Usage notes:

  This macro does not have any key assignments.  To use, simply select
  it from the Potpourri menu.

  Sums either base 10 (decimal), base 16 (hexadecimal), or mixed.

  For base 10, a fractional part is allowed and may be up to 8 decimal
  places.  Fractions are disallowed for hexadecimal numbers.

  For base 16, a preceding '0x' is ignored, as is a trailing 'h'.

  For mixed base, a preceding '0x' or a valid hexadecimal letter a-f
  or a trailing 'h' forces base 16 for that entry. Otherwise, base 10
  is assumed.

  The fractional part is maintained within (-1,1) to avoid overflow.

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

// define it according to your country : One million Dollars  (USA), fifty three cents : 1,000,000.53
//                                       One million Reais (Brazil), fifty three cents : 1.000.000,53

#define THOUSANDS_SEPARATOR Asc('.')
#define DECIMAL_SEPARATOR   Asc(',')

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

proc InsertSum(integer flags)
    if (flags & ins_END_OF_BLOCK)
        GotoBlockEnd()
        GotoColumn(Query(BlockBegCol))
        if not Down()
            AddLine()
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

menu InsertSumMenu()
    HISTORY = InsertSumHistory()
    TITLE = "Decimal Sum"

    ""  [dec_sum: SizeOf(dec_sum)]  ,                       ,   SKIP
    "Insert at &Cursor"          ,   InsertSum(ins_DECIMAL)
    "Insert at &End of Block"    ,   InsertSum(ins_DECIMAL | ins_END_OF_BLOCK)
    "Copy to TSE Clip&Board"     ,   CopyToClipboard( dec_sum )
    "Copy to &Windows Clipboard"    ,   CopyToWinClip( dec_sum )
    "Hex Sum"                      ,                        ,   DIVIDE
    ""  [hex_sum: SizeOf(hex_sum)]  ,                       ,   SKIP
    "In&sert at Cursor"          ,   InsertSum(ins_HEX)
    "Inse&rt at End of Block"    ,   InsertSum(ins_HEX | ins_END_OF_BLOCK)
    "Copy t&o TSE Clipboard"     ,   CopyToClipboard( hex_sum )
    "Copy to W&indows Clipboard" ,   CopyToWinClip( hex_sum )
end

// Helper routines to display status as numbers are being summed

integer bar_total, bar_complete, bar_resolution, bar_size, bar_open

proc SetupBar(string TITLE, integer size)
    bar_total = 0
    bar_complete = 0
    bar_size = size
    bar_resolution = bar_size / 40
    bar_open = PopWinOpen(20,10,61,12,1,TITLE,Color(Red))
    if bar_open
        ClrScr()
    endif
end

proc UpdateBar()
    bar_complete = bar_complete + 1
    bar_total = bar_total + 1
    if bar_complete > bar_resolution and bar_open
        bar_complete = 0
        GotoXY(1,1) // physically move cursor to reduce flicker
        Set(Attr,Color(Green))
        // JHB: Handle non OEM fonts...
        // PutLine(Substr("ллллллллллллллллллллллллллллллллллллллллл",1,bar_total * 40 / bar_size),40)
        PutOemLine(SubStr("ллллллллллллллллллллллллллллллллллллллллл",1,bar_total * 40 / bar_size),40)
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
            frac_total,             // fractional part of sum
            decimal_places,         // number of decimal places
            max_decimal_places,     // max number of decimal places
            int_part,               // integral part of number
            frac_part,              // fractional part of number
            block_width,            // width of column block
            error,                  // TRUE if too many decimal places
            negative                // is this a negative number

    string s[32]                            // temp string for number
    string savewordset[32] = Query(WordSet) // wordset of valid numbers

    if isBlockInCurrFile() <> _COLUMN_
        Warn("Column block must be marked in current file")
        return ()
    endif

    SetupBar("Summing", Query(BlockEndLine) - Query(BlockBegLine) + 1)

    error = FALSE
    int_total = 0
    frac_total = 0
    max_decimal_places = 0
    hex_format = NONE
    sum_type = type

    block_width = Query(BlockEndCol) - Query(BlockBegCol) + 1
    if (block_width > SizeOf(s))
        // the user could increase the size of s if necessary
        Warn("Block too wide")
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
                when Asc('+'), Asc('$')
                    Right()
                when Asc('-')
                    negative = TRUE
                    Right()
                when Asc('(')
                    PushPosition()
                    loop
                        if not Right() or CurrChar() < 0
                            PopPosition()
                            break
                        endif
                        if CurrChar() == Asc(')')
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
                if CurrChar() == Asc('0')
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
                    s = s + Chr(CurrChar())
                elseif type == BASE_10 and CurrChar() == THOUSANDS_SEPARATOR
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
            int_part = Val(s, base)

            if (negative)
                int_part = -int_part
            endif

            int_total = int_total + int_part

            frac_part = 0

            if base == 10 and CurrChar() == DECIMAL_SEPARATOR

                Right()
                decimal_places = 0
                s = ''
                while isWord() and isCursorInBlock()
                    decimal_places = decimal_places + 1
                    if decimal_places > 8
                        Warn("Too many decimal places (8 maximum supported)")
                        error = TRUE
                    endif
                    s = s + Chr(CurrChar())

                    if not Right()
                        break
                    endif
                endwhile

                s = SubStr(s + '00000000',1,8)  // normalize to 8 places
                frac_part = Val(s)

                if (negative)
                    frac_part = -frac_part
                endif

                frac_total = frac_total + frac_part

                if (decimal_places > max_decimal_places)
                    max_decimal_places = decimal_places
                endif
            endif

            int_total = int_total + (frac_total / 100000000)
            frac_total = frac_total mod 100000000

        endif

        UpdateBar()         // update status

        GotoColumn(Query(BlockBegCol))

    until error or not Down() or not isCursorInBlock()

    // force result into form a + b or - a - b, where
    // a > 0 is integral part and b > 0 is fractional part

    if frac_total
        if frac_total > 0
            if int_total < 0
                int_total = int_total + 1
                frac_total = frac_total - 100000000
            endif
        else
            if int_total > 0
                int_total = int_total - 1
                frac_total = 100000000 + frac_total
            endif
        endif
    endif

    Set(WordSet, SaveWordSet)

    PopPosition()
    PopBlock()
    CloseBar()

    // Prompt on what to do with the sum if there were no errors

    if not error
        // convert sum to string so we can adjust the decimal places, etc
        dec_sum = Str(Abs(int_total))   // integral value as decimal string
        if (int_total < 0 or frac_total < 0)
            dec_sum = '-' + dec_sum
        endif

        hex_sum = Str(int_total, 16)    // integral value as hex string
        case hex_format
            when LEADING_0X
                hex_sum = '0x' + hex_sum
            when TRAILING_H
                hex_sum = hex_sum + 'h'
        endcase

        // format the decimal places (if any)
        if max_decimal_places <> 0
            dec_sum = dec_sum + Chr(DECIMAL_SEPARATOR) + SubStr(Format(Abs(frac_total):8:'0'),1,max_decimal_places)
        endif

        // try to format the sum into the same width of the block
        // if possible

        if (Length(dec_sum) < block_width)
            dec_sum = Format(dec_sum:block_width)
            hex_sum = Format(hex_sum:block_width)
        endif

        InsertSumMenu()

        UpdateDisplay(_STATUSLINE_REFRESH_)
    endif
end Sum

menu SumMenu()
    TITLE = "Sum"
    HISTORY

    "&Decimal",     Sum(BASE_10)
    "&Hexadecimal", Sum(BASE_16)
    "&Mixed",       Sum(BASE_MIXED)
end

proc Main()
    SumMenu()
end
