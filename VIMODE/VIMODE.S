/*
Charlie Harris posted his origional version of viTSE at an 
opportune time for me, since I have had reason to start working 
with a UNIX environment, but had found it difficult to learn the 
editors without spending more time than I had available with 
which to get nothing done, and most of my real work is with text.
His TSE vi emulation has allowed me to gradually familiarize 
myself with the basic vi command set without having to come to a 
comlete stop to do it.

I have also been gradually improving and adding commands as I go 
along, and have recently undertaken the task of overhauling the 
results of my efforts in order to put them into postable shape. 

Because of differences in our primary goals, Charlie Harris and I 
have taken different paths in the updating of viTSE, and anyone 
interested in working with this command set may want to look at 
both versions. I have expanded on the origional structure of 
viTSE using a Process() with an exclusive keydef as the basic 
Command mode, while he has changed to the use of a case statement
to define his key commands within a proc. His new implementation
makes possible the implementation of the dot command, while mine
makes possible the proper use of numeric input to movement
commands.

I made the statement recently that I thought that the dot command
could be implemented without too much difficulty, but this was
based on an erroneous understanding of the dot command. It is
really a variant of the famous "undo" and just as intractable,
which is why Charlie Harris found himself obliged to change his
approach in order to implement it.

I find the vi mode to be just as clumsy as its reputation for 
general text entry and manipulation, but it has a good set of 
movement and text change commands for the editing of existing 
text. With movement by paragraph, sentence, word, or to a 
specified letter in the middle of an extra long word, and with 
the option to specify how many words, lines, or whatever to move, 
it is easy to get to anyplace within the text.

And the commands to leave command mode and insert text allow 
specifying insert, overwrite, or a combination of the two (eg. 
write over two words and insert the rest of the new text before 
the third word, etc).

NOTES: 

1. My implementation isn't exact, either, although with a few 
   stated exceptions (as noted in the source code), I have tried 
   to make it as much so as possible.

2. I have had some difficulty with the sentence movement macros.
   They sometimes leave you in the wrong place, although general-
   ly not far from where you should be. This happens when the 
   sentence crosses a line, but it doesn't always happen. In any
   case, with this in mind, they are useable in their present 
   form, and perhaps someone else can show me what I'm missing. 
   In any case I'll eventually change them, but I have to let 
   them go for a while. Working on a problem too long tends to 
   create mental blocks.

3. Most of the movement commands take numeric input. You type the 
   number first, and it does not appear anywhere on the screen. 
   When you type the command, it will do it that many times. On 
   the help screen (Alt-F1), I have indicated an ü for those 
   commands which behave differently if no number is supplied. 
   The c (change) and d (delete) commands require a second, 
   cursor movent command, and can take the numeric input either 
   first, or in between (eg. 3cw == c3w).

4. The proper implementation of the y (yank to buffer) and p 
   (paste) commands would be built similiarly to the c and d 
   commands, but a little more complex because they also take a 
   letter buffername. I have not bothered to implement these, 
   although I have thought about it, because I use viTSE mostly 
   for editing existing text, and can always use the similiar TSE 
   functions instead. I have deleted the rudimentary versions 
   from this file so as not to create confusion as to their 
   behaviour.


-----------cut here -----------cut here -----------cut here-----------*/

/****************************** viTSE() ********************************/


helpdef vihelp
     Title = "vi commands"
     x = 5
     y = 2

"Cursor Movements:             h   Left"
"  w   Word forward            j   Down"
"  b   Word backward           k   Up"
"  W/B (by nonwhite group)     l   Right"
"  e   to end of word          H   to Top of Screen"
"  f(chr) forwd to char        L   to Bottom of Screen"
"  t(chr) to char before       M   to Middle of Screen"
"  F(chr) backwd to char       0   to BegLine"
"  )   Sentence forward        $   to EOL"
"  (   Sentence backward       |   to üCol"
"  }   Paragraph forward       G   to üLine (EOF)"
"  {   Paragraph back          %   to ü% of File"
"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
" Edit Commands                C  Change to EOL"
"   i  Insert at Cursor        c(mvmt)  Change text"
"   I  Insert at BegLine       d(mvmt)  Del text"
"   a  Append at cursor        D  Del to EOL"
"   A  Append to EOL           o  Open new line"
"   r  Replace Char            O  Open line above"
"   R  Overwrite Mode          <  Shift text left"
"   s  Subst., then insert     >  Shift text right"
"   S  Substitute from BOL     ~  Flip Case"
"   x  Del Char                =  Wrap Paragraph"
"   X  DelChars Left           u  Undelete"
"   J  JoinLines               U  Undo Cursor Line"
"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
"Colon Mode Commands           :wq   Write & Quit"
"   :q   QuitFile              :edit EditFile"
"   :w   Write                 :n    Nextfile"
"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
"Screen Movements:            Search"
"  ^F  Page Forward             /  Find"
"  ^B  Page Backward            ?  BackwdFind"
"  ^U  Up ülines (« Page)       n  Repeat Find"
"  ^D  Down ülines (« Page)     N  Backwrd RptFind"
"  ^E  ScrollDown"
"  ^Y  ScrollUp               Special Functions"
"  z(+,.,-) make (top,middle,    %  Matching Brace"
"          bottom) of screen     m  BookMark"
"  ^G  Show File Info            '  GotoMark"
"  ^L  Update Screen             ZZ Save & Exit"
end vihelp



integer rptnum = 0

proc NumCmd(STRING n)   // This proc produces the repeat variable
    integer ky          // on recieving numeric input from the keyboard.
    integer keyval
    string key[1]
    string rnum[5] = ""

    rnum = n
    loop                    // create a string for multiple keystroke handling.
        ky = Getkey()
        keyval = Val(Chr(ky))
        if (ky == <0>)
            rnum = Format(rnum + "0")
        elseif keyval
            key = Chr(ky)
            rnum = Format(rnum + key)
        else
            Pushkey(ky)   // make non-numeric keystroke available to the next user
            break
        endif
    endloop
    rptnum = Val(rnum)   // convert sting to integer for use by commands
end

/****************************************************************************
  The match command.  Use this macro to match (){}{}<> chars.
  From TSE.UI. Comment out or delete this proc if you burn viTSE
  into your .UI.
 ***************************************************************************/
string match_chars[] = "(){}[]<>"   // pairs of chars to match
integer proc mMatch()
    integer p, level, mc, ch, start_line = CurrLine(), start_row = CurrRow()

    p = Pos(chr(CurrChar()), match_chars)
    // If we're not already on a match char, go forward to find one
    if p == 0 and lFind("[(){}[\]<>]", "x")
        ScrollToRow(CurrLine() - start_line + start_row)
        return (FALSE)
    endif

    PushPosition()
    if p
        ch = asc(match_chars[p])             // Get the character we're matching
        mc = asc(match_chars[iif(p & 1, p + 1, p - 1)])  // And its reverse
        level = 1                       // Start out at level 1

        while lFind("[\" + chr(ch) + "\" + chr(mc) + "]", iif(p & 1, "x+", "xb"))
            case CurrChar()             // And check out the current character
                when ch
                    level = level + 1
                when mc
                    level = level - 1
                    if level == 0
                        KillPosition()          // Found a match, remove position
                        GotoXoffset(0)          // Fix up possible horizontal scrolling
                        ScrollToRow(CurrLine() - start_line + start_row)
                        return (TRUE)           // And return success
                    endif
            endcase
        endwhile
    endif
    PopPosition()                       // Restore position
    return (warn("Match not found"))    // Warn() returns False
end mMatch

/********** end of mMatch ********************/

proc WrdEnd(INTEGER n)  // n is rptnum passed by the keydef
    if n
        WordRight(n - 1)
    else
        Right(2)
    endif
    EndWord()
    Left()
end

proc WLeft(INTEGER n)
    if n
        WordLeft(n)
    else
        WordLeft()
    endif
end

proc BlockLeft()        // This traverses an entire block of text regardless of
    if not rptnum       // Wordset. Good for nested source code blocks.
        rptnum = 1
    endif
    while rptnum
        PrevChar()
        while isWhite()
            PrevChar()
        endwhile
        while not isWhite()
            if not Left()
                break
            endif
        endwhile
        rptnum = rptnum - 1
    endwhile
    Right()
end

proc WRight(INTEGER n)
    if n
        WordRight(n)
    else
        WordRight()
    endif
end

proc BlockRight()    // This traverses an entire block of text regardless of Wordset
    if not rptnum    // Good for nested source code blocks.
        rptnum = 1
    endif
    while rptnum
        NextChar()
        while isWhite()
            NextChar()
        endwhile
        while not isWhite()
            if not NextChar()
                break
            endif
        endwhile
        rptnum = rptnum - 1
    endwhile
end

proc viSentLeft()

    PushPosition()
    if not rptnum
        rptnum = 1
    endif
    if not WordLeft()   // set startpoint & test for unviable startpoint
              goto err_exit
    endif

    while rptnum            // Look for nth EOS (backward)
        loop       //look for nth instance of previous Sentence end.
            while not PosFirstNonWhite()
                if not WordLeft()
                    goto err_exit
                endif
            endwhile
            if not lFind(".[.?!]{ }|{$}","bcx")  // Line by line in order to defeat lFind's default screen shift.
                if not Up()
                    goto err_exit       // BOF
                else
                    if PosFirstNonWhite()
                        GoToPos(PosLastNonWhite())   // to end of line, ready for next lFind
                    else
                        break                           // (Blank line)
                    endif
                endif
            else         // found it!
                WordLeft()
                break
            endif
        endloop
        rptnum = rptnum - 1
    endwhile

    WordRight()
    KillPosition()
    rptnum = 0
    return()

    err_exit:
        PopPosition()
        Sound(1000) Delay(3) NoSound()
        rptnum = 0
end



proc viSentRight()  // This still occasionally goes to a location short of the proper
                    // place for some reason I have not been able to discover.
                    // Seems to have to do with the line break. Comments are welcome.

    PushPosition()
    if not rptnum
        rptnum = 1
    endif
    while rptnum                    // find nth end of sentence
        loop                           // Locate EOS loop, search line by line
            while CurrChar() < 0         // Blank line or last find was at EOL
                if not Left()            // (blank line)
                    if not Down()
                        goto err_out     // EOF
                    endif
                endif
            endwhile
            if not lFind(".[.?!]\c{ }|{$}","cx")  // Line by line in order to defeat lFind's default screen shift.
                if not Down()
                    goto err_out    // looking for a place beyond EOF
                endif
                if not GoToPos(PosFirstNonWhite())  // don't want to skip over an instance after a Down.
                    break    // consider a blank line to be a sentence boundary
                endif
            else
                break   // found it!
            endif
        endloop
        rptnum = rptnum - 1  // look for the next one.
    endwhile
    WordRight()
    KillPosition()
    return()

    err_out:
        PopPosition()
        Sound(1000) Delay(3) NoSound()
        rptnum = 0
end


proc viEndPara()  // The paragraph macros are modified versions of a set of macros
                  // previously posted on the SemWare BBS, I forget by whom.

    PushPosition()
    if not rptnum
        rptnum = 1
    endif

    while rptnum
        while PosFirstNonWhite() == 0    // skip any blank lines
            if not Down()
               goto err_out
            endif
        endwhile

        while PosFirstNonWhite()    // scan till the end of paragraph
            if not Down()
                if rptnum
                    goto err_out
                endif
                EndLine()
            endif
        endwhile
        rptnum = rptnum - 1
    endwhile
    KillPosition()
    return()

    err_out:
    PopPosition()
    Sound(1000) Delay(3) NoSound()
    rptnum = 0
end

proc viPrevPara()

    PushPosition()
    if not rptnum
        rptnum = 1
    endif

    if not Up()
        goto err_out
    endif

    while rptnum
        while PosFirstNonWhite() == 0
            if not Up()
                goto err_out
            endif
        endwhile

        while PosFirstNonWhite()
            if not Up()
                if rptnum
                   goto err_out
                endif
                GotoPos(PosFirstNonWhite())
                return()
            endif
        endwhile
        rptnum = rptnum - 1
    endwhile

    Down()
    GotoPos(PosFirstNonWhite())
    KillPosition()
    return()

    err_out:
    PopPosition()
    Sound(1000) Delay(3) NoSound()
    rptnum = 0
end

proc viNextPara()

     PushPosition()
    if not rptnum
        rptnum = 1
    endif

    while rptnum
        while PosFirstNonWhite()    // if in a paragraph, scan till the end of it
            if not Down()
                goto err_out
            endif
        endwhile

        while PosFirstNonWhite() == 0    // skip any blank lines
            if not Down()
                goto err_out
            endif
        endwhile
        rptnum = rptnum - 1
    endwhile

    GotoPos(PosFirstNonWhite())
    KillPosition()
    return()

    err_out:
    PopPosition()
    Sound(1000) Delay(3) NoSound()
    rptnum = 0
end


proc GoToChar(STRING dir)   // for f and t commands
  /*******************************************************
  *  These are useful for jumping into the middle of a   *
  *  long word to make corrections.                      *
  *******************************************************/
    integer ky

    PushPosition()
    if not rptnum
        rptnum = 1
    endif

    ky = GetKey()
    while rptnum
    if not lFind(Chr(ky),dir)   // options variable is passed by the keydef
        goto err_out
    endif
    rptnum = rptnum - 1
    endwhile

    KillPosition()
    return()

    err_out:
        PopPosition()
        Sound(1000) Delay(3) NoSound()
        rptnum = 0
end

proc viLeft()
    PushPosition()
    if not rptnum
        rptnum = 1
    endif
    if not Left(rptnum)     // never use an unprotected Left(), Up(), or Down
        PopPosition()
        Sound(1000) Delay(3) NoSound()
        rptnum = 0
        return()
    endif
    KillPosition()
    rptnum = 0
end

proc viRight()
    if not rptnum
        rptnum = 1
    endif
    Right(rptnum)
    rptnum = 0
end

proc viUp()
    PushPosition()
    if not rptnum
        rptnum = 1
    endif
    if not Up(rptnum)
        PopPosition()
        Sound(1000) Delay(3) NoSound()
        rptnum = 0
        return()
    endif
    KillPosition()
    rptnum = 0
end

proc viDown()
    PushPosition()
    if not rptnum
        rptnum = 1
    endif
    if not Down(rptnum)
        PopPosition()
        Sound(1000) Delay(3) NoSound()
        rptnum = 0
        return()
    endif
    KillPosition()
    rptnum = 0
end

proc viFlip(INTEGER n)
    PushBlock()
    MarkChar()
    Right(n)
    MarkChar()
    Flip()
    UnMarkBlock()
    PopBlock()
end

proc viC()  // Change to EOL
    integer ky

    rptnum = ((PosLastNonWhite() + 1) - CurrPos())
    while rptnum                // loop allows continuous display updating and checking for <Esc>
        VGoToXY(PosLastNonWhite(),WhereY())  // mark last char to change
        PutChar("$")
        VGoToXY(PosLastNonWhite(),WhereY())
        PutAttr(Query(HiLiteAttr),1)
        ky = GetKey()
        if ky == <Escape>    // del instead of changing character by character
            DelToEol()
            UpdateDisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
            rptnum = 0
        else
            InsertText(Chr(ky),_OVERWRITE_)
            UpdateDisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
            rptnum = rptnum - 1
        endif
    endwhile
    Set(Insert,ON)
end

proc viR()   // Single Char Replace
  /******************************************************************
  * Note: in the true implementation rptnum causes multiples of the *
  * same character to be inserted. I have kept this implementation  *
  * based on an erroneous initial impression because I find it use- *
  * ful to be able to overwrite a specified number of characters    *
  * and return automatically to the command mode.                   *
  ******************************************************************/
    integer ky

    if not rptnum
        rptnum = 1
    endif
    while rptnum
        VGoToXY((CurrPos() + (rptnum -1)),WhereY())
        PutChar("$")
        VGoToXY((CurrPos() + (rptnum -1)),WhereY())
        PutAttr(Query(HiLiteAttr),1)
        ky = GetKey()
        if ky == <Escape>
            DelChar(rptnum)
            UpdateDisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
            rptnum = 0
        else
            InsertText(Chr(ky),_OVERWRITE_)
            UpdateDisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
            rptnum = rptnum - 1
        endif
    endwhile
end


proc viFindBackwards()    // This one is from Charlie Harris' new version, verbatim.
        AddHistoryStr("b", _FINDOPTIONS_HISTORY_)
        Find()
        AddHistoryStr("+", _FINDOPTIONS_HISTORY_)
end

proc viFileInfo()
  string title[14] = Upper(SplitPath(CurrFilename(), _NAME_ | _EXT_))
  integer pct = (CurrLine()*100 + (numlines()/200))/NumLines()
  string text[60] = title + ",  Line " + Str(CurrLine()) +
                    " of " + Str(NumLines()) +
                    " [" + Str(pct)+"%] "
  VGoToXY(1,Query(ScreenRows))
  PutStr(text)
  VGoToXY(1,Query(ScreenRows))
  PutAttr(Color(Bright White ON Red), Length(text))
end


proc BkwdDel(INTEGER row, INTEGER col)  // used by c and d commands
    MarkChar()
    GoToLine(row)
    GoToPos(col)
    MarkChar()
    DelBlock()
end

proc FwdDel(INTEGER row, INTEGER col)   // used by c and d commands
    MarkStream()
    GoToLine(row)
    GoToPos(col)
    MarkStream()
    DelBlock()
end

proc BkwdChng(INTEGER row, INTEGER col)   // used by c command
    integer c_num
    integer ky

    if row <> CurrRow()
        BkwdDel(row,col)
    else
        c_num = (col - CurrPos())
        while c_num
            VGoToXY((CurrPos() + (c_num -1)),WhereY())
            PutChar("$")
            VGoToXY((CurrPos() + (c_num -1)),WhereY())
            PutAttr(Query(HiLiteAttr),1)
            ky = GetKey()
            if ky == <Escape>
                DelChar(c_num)
                UpdateDisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
                c_num = 0
            else
                InsertText(Chr(ky),_OVERWRITE_)
                UpdateDisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
                c_num = c_num - 1
            endif
        endwhile
    endif
end

proc FwdChng(INTEGER row, INTEGER col)    // used by c command
    integer c_num
    integer ky

    if row <> CurrRow()
        FwdDel(row,col)
    else
        c_num = ((CurrPos() - col) + 1)
        GoToPos(col)
        while c_num
            VGoToXY((CurrPos() + (c_num -1)),WhereY())
            PutChar("$")
            VGoToXY((CurrPos() + (c_num -1)),WhereY())
            PutAttr(Query(HiLiteAttr),1)
            ky = GetKey()
            if ky == <Escape>
                DelChar(c_num)
                UpdateDisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
                c_num = 0
            else
                InsertText(Chr(ky),_OVERWRITE_)
                UpdateDisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
                c_num = c_num - 1
            endif
        endwhile
        Left()
    endif
end

proc viChange()
 /****************************************************************
 *  This Command accepts both numeric and cursor control (goto)  *
 *  input. the Numeric input may be entered first or after "c"   *
 *  but before the goto command. Changes to be made on the same  *
 *  line only will be marked as in the "r" and "s" commands, If  *
 *  the cursor movement crosses lines, the text to be changed    *
 *  will simply be deleted. The Delete command is similiar ex-   *
 *  cept that it simply deletes the affected text and remains in *
 *  command mode.                                                *
 ****************************************************************/

    integer ky
    integer keyval
    string key[1]
    string rnum[5] = ""
    integer col = CurrCol()
    integer row = CurrLine()

    ky = GetKey()
    if Val(Chr(ky))              // Slightly modified version of NumCmd()
        rnum = Chr(ky)
        loop
            ky = Getkey()
            keyval = Val(Chr(ky))
            if (ky == <0>)
                rnum = Format(rnum + "0")
            elseif keyval
                key = Chr(ky)
                rnum = Format(rnum + key)
            else
                break       // non-numeric input, go on
            endif
        endloop
        rptnum = Val(rnum)
    endif
        if ky == <Shift 9>      // decide which command to execute
            viSentLeft()
            BkwdChng(row,col)
        elseif ky == <2601>
            viSentLeft()
            BkwdChng(row,col)
        elseif ky == <Shift 0>
            viSentRight()
            PrevChar()
            FwdChng(row,col)
        elseif ky == <2877>
            viSentRight()
            PrevChar()
            FwdChng(row,col)
        elseif ky == <Shift f>
            GoToChar("bc")
            BkwdChng(row,col)
        elseif ky == <b>
            WLeft(rptnum)
            BkwdChng(row,col)
        elseif ky == <f>
            GoToChar("+c")
            Left()
            FwdChng(row,col)
        elseif ky == <t>
            GoToChar("+c")
            Left()
            Left()
            FwdChng(row,col)
        elseif ky == <w>
            WrdEnd(rptnum)
            FwdChng(row,col)
        elseif ky == <Shift [>
            viPrevPara()
            BkwdChng(row,col)
        elseif ky ==  <249>
            viPrevPara()
            BkwdChng(row,col)
        elseif ky == <Shift ]>
            viEndPara()
            FwdChng(row,col)
        elseif ky == <94>
            viEndPara()
            FwdChng(row,col)
        elseif ky == <6954>
            viEndPara()
            FwdChng(row,col)
        else
            Sound(1000) Delay(3) NoSound()   // erroneous input
            rptnum = 0
    endif
end


proc viDelete()        // same structure as above with only minor differences
    integer ky
    integer keyval
    string key[1]
    string rnum[5] = ""
    integer col = CurrCol()
    integer row = CurrLine()

    ky = GetKey()
    if Val(Chr(ky))
        rnum = Chr(ky)
        loop
            ky = Getkey()
            keyval = Val(Chr(ky))
            if (ky == <0>)
                rnum = Format(rnum + "0")
            elseif keyval
                key = Chr(ky)
                rnum = Format(rnum + key)
            else
                break
            endif
        endloop
        rptnum = Val(rnum)
    endif
        if ky == <Shift 9>
            viSentLeft()
            BkwdDel(row,col)
        elseif ky == <2601>
            viSentLeft()
            BkwdDel(row,col)
        elseif ky == <Shift 0>
            viSentRight()
            PrevChar()
            FwdDel(row,col)
        elseif ky == <2877>
            viSentRight()
            PrevChar()
            FwdDel(row,col)
        elseif ky == <Shift f>
            GoToChar("bc")
            BkwdDel(row,col)
        elseif ky == <b>
            WLeft(rptnum)
            BkwdDel(row,col)
        elseif ky == <d>                // dd = delete line(s)
            iif(rptnum,DelLine(rptnum),DelLine()) rptnum = 0
        elseif ky == <f>
            GoToChar("+c")
            Left()
            FwdDel(row,col)
        elseif ky == <t>
            GoToChar("+c")
            Left()
            Left()
            FwdDel(row,col)
        elseif ky == <w>
            WrdEnd(rptnum)
            FwdDel(row,col)
        elseif ky == <Shift [>
            viPrevPara()
            BkwdDel(row,col)
        elseif ky == <249>
            viPrevPara()
            BkwdDel(row,col)
        elseif ky == <Shift ]>
            viEndPara()
            FwdDel(row,col)
        elseif ky == <94>
            viEndPara()
            FwdDel(row,col)
        elseif ky == <6954>
            viEndPara()
            FwdDel(row,col)
        else
            Sound(1000) Delay(3) NoSound()
            rptnum = 0
    endif
end

proc ColonCmd()
    string ddot[1] = ":"
    string cmd[5] = ""

    VGoToXY(1,Query(ScreenRows))
    PutStr(ddot)
    lRead(cmd,4)

    if cmd == "n"
        NextFile()
    elseif cmd == "q"
        if not FileChanged()
            AbandonFile()
        else
            VGoToXY(1,Query(ScreenRows))
            PutStr("Use w to save file, or to abandon changes, use q!")
            VGoToXY(1,Query(ScreenRows))
            PutAttr(Color(Bright White ON Red), 49)
        endif
    elseif cmd == "q!"
        AbandonFile()
    elseif cmd == "w"
        SaveFile()
    elseif cmd == "wq"
        if NumFiles() > 1
            SaveAndQuitFile()
        else
            SaveFile()
            AbandonEditor()
        endif
    elseif cmd == "edit"
        EditFile()
    else
        VGoToXY(1,Query(ScreenRows))
        PutStr("Unknown Command")
        VGoToXY(1,Query(ScreenRows))
        PutAttr(Color(Bright White ON Red), 49)
    endif
end


keydef viKeys             //   vi command mode
/* Special Functions */
  <Escape>  Sound(1000) Delay(3) NoSound() rptnum = 0
  <Ctrl k>  Sound(1000) Delay(3) NoSound() rptnum = 0  // because I keep trying to use the Wordstar File key combinations without checking which mode I'm in!
  <Ctrl o>  Sound(1000) Delay(3) NoSound() rptnum = 0  // because I keep trying to use the Wordstar File key combinations without checking which mode I'm in!
  <Alt F1>  QuickHelp(vihelp)     rptnum = 0
  <Ctrl g> viFileInfo()  rptnum = 0
  <Ctrl l> UpdateDisplay(_WINDOW_REFRESH_)  rptnum = 0
  <1> NumCmd("1")
  <2> NumCmd("2")
  <3> NumCmd("3")
  <4> NumCmd("4")
  <5> NumCmd("5")
  <6> NumCmd("6")
  <7> NumCmd("7")
  <8> NumCmd("8")
  <9> NumCmd("9")
/* Buffer & Bookmark */
  <m>  PlaceMark() rptnum = 0
  <'>  GotoMark() rptnum = 0
  <Shift /> Disable(viKeys) viFindBackwards() Enable(viKeys, _EXCLUSIVE_) rptnum = 0  // "?"
  </>    Disable(viKeys) Find() Enable(viKeys, _EXCLUSIVE_) rptnum = 0
/* Movement */
  <Shift 6>  GoToPos(PosFirstNonWhite()) rptnum = 0
  <f>  GoToChar("+c")
  <t>  GoToChar("+c")  Left()
  <Shift f>  GoToChar("bc")
  <b>    WLeft(rptnum) rptnum = 0
  <Shift b>    BlockLeft()
  <e>    WrdEnd(rptnum) rptnum = 0
  <w>    WRight(rptnum) rptnum = 0
  <Shift w>    BlockRight()
  <Shift 0>   viSentRight()   // ")"
  <Shift 9>   viSentLeft()    // "("
  <Shift [>  viPrevPara()  // "{"
  <Shift ]>  viNextPara()   // "}"
  <Shift e> viEndPara()
  <Shift g> iif(rptnum,GoToLine(rptnum),EndFile()) rptnum = 0
  <Shift \>  GotoColumn(rptnum) rptnum = 0 // "|"
  <Shift 5> iif(rptnum,GoToLine((rptnum * NumLines() / 100) + 1),mMatch()) rptnum = 0
  <Shift ,> iif(rptnum,ShiftText(-rptnum),ShiftText(-1)) rptnum = 0  // "<"
  <Shift .> iif(rptnum,ShiftText(rptnum),ShiftText(1)) rptnum = 0  // ">"
    //CursorSet
  <0>    BegLine() rptnum = 0
  <Shift 4> EndLine() rptnum = 0      // "$"
  <Shift h> BegWindow() rptnum = 0
  <h>  viLeft()
  <j>  viDown()
  <k>  viUp()
  <l>  viRight()
  <Shift l> EndWindow() rptnum = 0
  <Shift m> GoToRow(Query(WindowRows) / 2)
  <Ctrl b>  iif(rptnum,PageUp(rptnum),PageUp()) rptnum = 0
  <Ctrl f>  iif(rptnum,PageDown(rptnum),PageDown()) rptnum = 0
  <Ctrl d>  iif(rptnum,GotoLine(CurrLine() + rptnum),GotoLine(CurrLine() + (Query(WindowRows) / 2))) rptnum = 0
  <Ctrl e>  Scrolldown() rptnum = 0
  <Ctrl u>  iif(rptnum,GotoLine(CurrLine() - rptnum),GotoLine(CurrLine() - (Query(WindowRows) / 2))) rptnum = 0
  <Ctrl y>  Scrollup() rptnum = 0
  <z><.> ScrollToRow(Query(WindowRows) / 2) rptnum = 0
  <z><Shift => ScrollToRow(1) rptnum = 0
  <z><-> ScrollToRow(Query(WindowRows)) rptnum = 0
/* Edit */
  <=>  WrapPara() rptnum = 0
  <Shift `> iif(rptnum,viFlip(rptnum),Flip()) rptnum = 0 // "~"
  <a>    Right() Set(Insert,ON) rptnum = 0 EndProcess()
  <Shift a> EndLine() Set(Insert,ON) rptnum = 0 EndProcess()
  <c>    viChange() Set(Insert,ON) EndProcess()
  <Shift c> viC() EndProcess()
  <d>    viDelete()
  <Shift D>  DelToEOL() rptnum = 0
  <i>    Set(Insert,ON) rptnum = 0 EndProcess()
  <Shift i> BegLine()  Set(Insert,ON) rptnum = 0 EndProcess()
  <Shift j>  JoinLine() rptnum = 0
  <n>    RepeatFind() rptnum = 0
  <Shift n>  RepeatFind(_BACKWARD_) rptnum = 0
  <o>    AddLine() BegLine() Set(Insert,ON)  rptnum = 0 EndProcess()
  <Shift o>  InsertLine() BegLine() Set(Insert,ON)  rptnum = 0 EndProcess()
  <r>    viR() Left()  // single char replace
  <Shift r> Set(Insert,OFF)  EndProcess()
  <s>    viR()  Set(Insert,ON)  EndProcess()
  <Shift s> BegLine() viC() EndProcess()
  <u>    Undelete() rptnum = 0
  <Shift u> RestoreCursorLine() rptnum = 0
  <x>    iif(rptnum,DelChar(rptnum),DelChar()) rptnum = 0
  <Shift x> iif(rptnum,BackSpace(rptnum),BackSpace()) rptnum = 0
  <Shift z><z> SaveFile() QuitFile() rptnum = 0
  <Shift ;> ColonCmd() rptnum = 0   // ":"
end

proc ModeMsg()
    VGoToXYAbs(64,1)
    PutStr("vi COMMAND MODE.")
end

/********************** for this you will need the file
            CAPSNUMS.ZIP by Peter Granaldi. Use it to ensure that you
                         will not be surprised having forgotten that
                         you had the CapsLock key ON before entering
                         vi mode. *********************************/
Binary "CAPSNUMS.BIN"
   Proc CapsOff()  :  0h
   Proc CapsOn()   :  9h
   Proc NumsOff()  : 12h
   Proc NumsOn()   : 1Bh
End


proc viTSE()
  if Enable(viKeys, _EXCLUSIVE_)        //  go into  vi command mode
      Hook(_AFTER_UPDATE_STATUSLINE_,ModeMsg)
      CapsOff()
      Process()
      UnHook(ModeMsg)
      Disable(viKeys)          // go into vi text input mode (and TSE)
      UpDateDisplay(_STATUSLINE_REFRESH_)
  endif
end

<Escape>    viTSE()

/***********************************************************************
*                  From: CHARLIE HARRIS,  10-23-94                     *
*                Modified and extended by ARNOLD HENNIG                *
***********************************************************************/
