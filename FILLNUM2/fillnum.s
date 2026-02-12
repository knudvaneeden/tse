/*************************************************************************
  FillNum     Fill a COLUMN block with a sequence of numbers

  Author:     SemWare

  Date:       Dec  8, 1992 - Initial version
              Oct 29, 1993 - Bug fixes, speed opts
              May 24, 2001 - bar - fill character
                                   numeric base

  Overview:

  This macro fills a column block with a series of numbers that can be
  incremented or decremented.  You specify the beginning and
  (optionally) ending number in the series, as well as the positive or
  negative amount by which to increment or decrement the series.

  Keys:       (none)

  Usage notes:

  This macro does not have any key assignments.  To use, simply select
  it from the Potpourri menu.

  Copyright 1992-1995 SemWare Corporation.  All Rights Reserved Worldwide.

  Use, modification, and distribution of this SAL macro is encouraged by
  SemWare provided that this statement, including the above copyright
  notice, is not removed; and provided that no fee or other remuneration
  is received for distribution.  You may add your own copyright notice
  to cover new matter you add to the macro, but SemWare Corporation will
  neither support nor assume legal responsibility for any material added
  or any changes made to the macro.

*************************************************************************/

integer start = 1,
        stop  = 0,
        step  = 1

string  fchr[1] = " "
integer base    = 10



proc GetString(var string s)
    Read(s)
end

proc GetNumber(var integer n)
    string s[5] = Str(n)

    if Read(s)
        n = val(s)
    endif
end

proc NumericFill()
    integer width, col, i


    if IsBlockInCurrFile() <> _COLUMN_
        Warn("Column block must be marked")
    else
        width = Query(BlockEndCol) - Query(BlockBegCol) + 1

        PushPosition()
        PushBlock()

        GotoBlockBegin()
        col = CurrCol()

        i = start
        while isCursorInBlock()
            InsertText(format(i:width:fchr:base), _OVERWRITE_)
            GotoColumn(col)
            i = i + step
            if stop                 // see if we're at the end
                if step > 0         // positive steps
                    if i > stop
                        break
                    endif
                else                // negative steps
                    if i < stop
                        break
                    endif
                endif
            endif
            if not Down()
                break       // we're at the end of the file
            endif
        endwhile

        PopBlock()
        PopPosition()

    endif
end

Menu NumericFillMenu()
    title   = "Numeric FillBlock"
    history = 5

    "&From"     [start : 5] ,   GetNumber(start)    ,   DontClose
    "&To"       [stop  : 5] ,   GetNumber(stop)     ,   DontClose
    "&Step"     [step  : 5] ,   GetNumber(step)     ,   DontClose
    ""                      ,                       ,   Divide
    "b&Ase"     [base  : 5] ,   GetNumber(base)     ,   DontClose

    "fi&Ll char"[fchr  : 1] ,   GetString(fchr)     ,   DontClose

    ""                      ,                       ,   Divide
    "Fill &Block"           ,   NumericFill()
end

proc main()
    NumericFillMenu()
end



/* eof */
