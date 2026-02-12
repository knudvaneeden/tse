/******************************************************************
These two procs are the result of a discussion that went on on
the BBS about a year ago. The original request was for a version
of MarkWord that would mark successive words as long as the same
(assigned) keystroke was repeated, and exit and pass the
keystroke on when any different key was pressed. If the cursor is
before the first word when mMarkWord is invoked, it will mark
from BOL to the end of the first nonWhite group. Note that the
first call will mark a "Word", while repeated keystrokes will
mark successive nonWhite groups. This allows the inclusion of
brackets in source code, and commas, periods, etc. in text.

I wrote the second proc more recently, because I found myself
frequently writing a line (or part of a line) that I knew I would
want to repeat four or five times in the following text, so
wanted to be able to mark backwards wordwise without having to
reset the cursor. This one marks by word instead of nonwhite
group; since all the stuff you want to include with a word
generally follows the word, it gets included automatically
anyway.

These are intended to be included into your .UI file and assigned
to keystrokes.

                                -Arnold M.J. Hennig
******************************************************************/



proc mMarkWord()
    integer key = Query(Key),
            nextkey = 0

    PushPosition()
    while not IsWord()
      if not Left()
           UnmarkBlock()
           MarkChar()
           GoToPos(PosFirstNonWhite())
           while CurrChar() >= 0 and not isWhite()
                Right()
           endwhile
           MarkChar()
           goto siga
      endif
    endwhile
    MarkWord()

    siga:
    PopPosition()
    UpdateDisplay()
    nextkey = GetKey()
    while nextkey == key
        PushPosition()
        GotoBlockEnd()
        if WordRight()
           while CurrChar() >= 0 and not isWhite()
                Right()
           endwhile
            MarkChar()
        endif
        PopPosition()
        UpdateDisplay()
        nextkey = GetKey()
    endwhile
    PushKey(nextkey)
end


proc mLMarkWord()
    integer key = Query(Key),
            nextkey = 0

    PushPosition()
    if not MarkWord()
        Left()
        while CurrChar() < 0 or IsWhite()     // Start a with nonwhite char
            if not Left()                   //  on the same line
                PopPosition()    // None exists
                return()
            endif
        endwhile
        UnmarkBlock()  // New Block, do not extend an existing one
        MarkStream()
        while not BegWord() and Left() endwhile   // BegWord or BOL
        MarkChar()
    endif

    PopPosition()          // Conditional End of proc
    UpdateDisplay()
    nextkey = GetKey()

    while nextkey == key      // Extend block if same keystroke
        PushPosition()
        GotoBlockBegin()
        if not PrevChar()    // test for BOF
            PopPosition()
            return()
        endif
        while not BegWord() and Left() endwhile  // Extend Block to next word or BOL
        MarkChar()
        PopPosition()   // Conditional End of proc
        UpdateDisplay()
        nextkey = GetKey()
    endwhile
    PushKey(nextkey)    // Pass on the keystroke
end

