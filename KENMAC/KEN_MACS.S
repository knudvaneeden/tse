/**************************************************************************
Filename = KEN_MACS.S

This file includes 4 macros which I have found useful in my work as a
programmer.

  They are mEndWordLeft()   - moves cursor to end of word at left
           mEndWordRight()  - moves cursor to end of word at right
           mAsciiChart()    - displays ASCII chart and inserts decimal value
           mColorChart()    - displays color chart for text mode

I either reworked someone else's code or added statements so they would
perform their intended functions.  I do not claim full credit for these.

They may be used and distributed without restrictions.

Ken Curtis
CompuServe 72460,614
AOL CKCurtis

PS: TSE is the greatest editor!  My compliments to SEMWARE personnel.

**************************************************************************/


/**************************************************************************
mEndWordLeft()

This moves cursor to the end of the word to the left.

Suggested key: <Alt ,>
  Note the comma key is also the '<' key so it looks somewhat like a
  left arrow.
**************************************************************************/
proc mEndWordLeft()
    if CurrCol() <> 1
        repeat
            Left()
        until isWhite() or CurrCol() == 1
        if CurrCol() <> 1
            repeat
                Left()
            until not isWhite() or Currcol() == 1
            if not isWhite()
                right()
            endif
        endif
    endif
    if CurrCol() == 1
        while CurrLine() <> 1
            Up()
            EndLine()
            if CurrCol() <> 1
                break
            endif
        endwhile
    endif
end mEndWordLeft


/**************************************************************************
mEndWordRight()

This moves cursor to end of word to the right.

Suggested key: <Alt .>
  Note the period key is also the '>' key so it looks somewhat like a
  right arrow.
**************************************************************************/
proc mEndWordRight()

    integer last_line = numlines(), // line number of last line
            lineno = CurrLine(), // line number
            have_nonwhite = FALSE // TRUE if non-white character found

    repeat
      while iswhite() and currchar() >= 0
        right()
      endwhile
      if currchar() >= 0
        have_nonwhite = TRUE
        break
      endif
      if lineno < last_line
        down()
        begline()
      endif
      lineno = lineno + 1
    until lineno > last_line

    if have_nonwhite == TRUE
      while currchar() >= 0 and not iswhite()
        right()
      endwhile
    endif

end mEndWordRight


/**************************************************************************
mAsciiChart()

This procedure displays an ASCII chart.

If the user hits RETURN, a string is inserted in the text giving the value
of the selected ASCII character.  If the user hits ESC, nothing is inserted.

Suggested key: No suggestion given.

**************************************************************************/
integer asciichartid, asciichartline
proc mAsciiChart()
    integer i, // index or temp variable
            sltd // ~0 indicates user selected the variable
    string ascii[4] // ascii characters

    // save current position
    PushPosition()

    // make chart if not already made
    if asciichartid == 0
        asciichartid = CreateTempBuffer()
        i = 0
        while i < 256 and AddLine(format(i:7, str(i, 16):4, chr(i):4))
            i = i + 1
        endwhile
        asciichartline = 1
    endif

    // display file and allow user to pick character
    GotoBufferId(asciichartid)
    Message("[Return] inserts decimal number                     [Esc] aborts")
    GoToLine (asciichartline)
    sltd = ListIt("  DEC HEX Char", 14)
    asciichartline = CurrLine()
    i = asciichartline - 1

    // return to current file position
    PopPosition()

    // if user selected, then insert the character number
    if sltd
        ascii = Str(i)
        InsertText(ascii)
    endif
    UpdateDisplay()

end mAsciiChart


/**************************************************************************
mColorChart()

This procedure displays a color chart for programmers desiring to
know the hex value for text mode colors.

Suggested key: No suggestion given.

**************************************************************************/
proc mColorChart()
    integer urow = 5, lcol = 5, // upper left corner of window
            lrow = urow + 9, rcol = lcol + 69 // lower left corner of window
    integer i, k // indexes
    integer a // attribute
    string fg[65] =
      " f0  f1  f2  f3  f4  f5  f6  f7  f8  f9  fA  fB  fC  fD  fE  fF "

    // save current position
    PushPosition()

    // display window
    PopWinOpen(lcol,urow,rcol,lrow,1," Colors ",48)
    i = 0
    while i < 8
      vgotoxy(1,i + 1)
      write(format("b",i:-3,fg))
      k = 0
      while k < 16
        a = (i shl 4) + k
        vgotoxy(5 + (k shl 2),i + 1)
        putattr(a,4)
        k = k + 1
      endwhile
      i = i + 1
    endwhile

    vgotoxy(4,i + 1)
    write(" Attribute = (b << 4) | f ")
    vgotoxy(4,i + 1)
    putattr(48,26)
    gotoxy(5,i + 1)


    // wait for user to press key
    getkey()

    // close window and return to current file position
    PopWinClose()
    PopPosition()

end mColorChart



