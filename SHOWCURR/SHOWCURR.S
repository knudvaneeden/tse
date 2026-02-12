/*
  ShowCurr    Show ascii and hex value of current character on the StatusLine

  Author:     SemWare (Richard Blackburn)

  Date:       1994

              Jan 31, 1997  Use load/purge to turn on/off

  Overview:

  This macro will display the ascii and hex values of the current
  character on the right edge of the status line.

  Keys:     (none)

  Usage notes:

  To invoke, simply load this macro.  To turn the feature off, purge
  this macro.


  Copyright 1992-1997 SemWare Corporation.  All Rights Reserved Worldwide.

  Use, modification, and distribution of this SAL macro is encouraged by
  SemWare provided that this statement, including the above copyright
  notice, is not removed; and provided that no fee or other remuneration
  is received for distribution.  You may add your own copyright notice
  to cover new matter you add to the macro, but SemWare Corporation will
  neither support nor assume legal responsibility for any material added
  or any changes made to the macro.

*/

/* Extended with total lines of file And file attributes
   By H. Pikaar
   26-11-2002
   Extended with total lines in block
   By H. Pikaar
   17-03-2003
*/

Proc mShowChar()
    integer n = CurrChar(),
            y = Query(StatusLineRow),
            nl = NumLines(),
            rows = 0,
            sw = 0,
            bl = 0,
            Attr = Set(Attr, Query(StatusLineAttr)),
            fileattribute

    string  attr_bit[4] = "",
            b_r[1]      = "",
            b_a[1]      = "",
            b_h[1]      = "",
            b_s[1]      = "",
            bl_txt[14]  = ""

    // Initialize
    attr_bit = ""
    fileattribute = FileExists(CurrFilename())

    // Check for read-only attribute
    If fileattribute & _ReadOnly_
        b_r = "R"
    Else
        b_r = "-"
    EndIf

    // Check for archive attribute
    If fileattribute & _Archive_
        b_a = "A"
    Else
        b_a = "-"
    EndIf

    // Check for hidden attribute
    If fileattribute & _Hidden_
        b_h = "H"
    Else
        b_h = "-"
    EndIf

    // Check for system attribute
    If fileattribute & _System_
        b_s = "S"
    Else
        b_s = "-"
    EndIf

    attr_bit = b_r + b_a + b_h + b_s
    If attr_bit == "----"
        attr_bit = "None"
    EndIf

    // Check for Block
    If IsBlockInCurrFile()
        PushPosition()
        GotoBlockBegin()
        bl = CurrLine()
        GotoBlockEnd()
        rows = (CurrLine() - bl) + 1
        If rows < 1
                rows = 1
        EndIf
        sw = 1
        PopPosition()
        bl_txt = "      B.Lines "
    Else
        bl_txt = "              "
    EndIf

    // Here we put the found data in the status line
    If Query(StatusLineUpdating)
        VGotoXY(Query(ScreenCols) - 6, y)
        PutStr(IIf(n < 0, "<EOL>" + IIf(n == _At_EOL_, "  ", "+ "), Format(n:2:"0":16, "h,", n:-3)))
        PutStrXY(Query(ScreenCols) - (Length(Str(nl)) + 44 + IIf(sw == 1, Length(Str(rows)), 0)), Query(StatusLineRow), bl_txt + IIf(sw == 1, Str(rows), "") + '  Flags ' + attr_bit + '  T.Lines ' + Str(nl), Query(StatusLineAttr))

    EndIf
    Set(Attr, Attr)

End


Proc WhenLoaded()
    Hook(_After_Update_StatusLine_, mShowChar)
End


