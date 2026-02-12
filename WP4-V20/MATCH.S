//  findMatch()         v1.02
//
//  Peter Birch
//  06/14/93
//  06/17/93            fixed problem with lower()
//
//
//
//      This macro will find the matching language control statements such
//      as 'if' and 'endif' in your source code.  It works much like
//      mMatch() supplied with TSE.
//
//
//
//  Suggested usage for this macro is as follows:
//
//      To use this macro, include it anywhere after mMatch() is defined,
//      have SC burn it into E.EXE with the other macros that are included.
//      Make the changes to mMatch() and compile/burn with SC. Then in your
//      language source file put your cursor on the top or bottom of a
//      language control statement such as 'if', 'endif', 'while', 'end',
//      etc.  Then hit the key that mMatch() is bound to.  This macro will
//      take you to the opposite (or compliment) statement.
//
//
// /*************************************************************************
//   The match command supplied with TSE -.
//
// integer proc mMatch()
//     integer p, level, mc, ch, start_line = CurrLine()
//
// ADDED THE NEXT LINE
//     if (not (language and not cmode and findMatch()))
//
//         p = Pos(chr(CurrChar()), match_chars)
//         // If we're not already on a match char, go forward to find one
//         if p == 0 and lFind("[(){}[\]<>]", "x")
//             .
//             .
//             .
//         endif
//         PopPosition()                       // Restore position
//         return (warn("Match not found"))    // Warn() returns False
// ADDED THE NEXT LINE
//     endif
//     return (TRUE)
// end mMatch
//


//note in TSE.S         this forward decleration may need to be removed!
forward string proc GetWordAtCursor()


constant    LOOK_UP         =   0
constant    LOOK_DOWN       =   1
constant    MAX_WORD_LENGTH =   20

// **************************************************************************
// mostly taken from COMMANDS.DOC
string proc mGetFirstWord()
    string word[ MAX_WORD_LENGTH] = ""

    PushPosition()              // Save current position

    GotoPos(PosFirstNonWhite()) // Start at first character on line
    word = Lower(getWordAtCursor()) // added Lower() WP4

    PopPosition()               // Restore original position
    return (' ' + word + ' ')   // and return the word
end

// **************************************************************************
integer proc mCheckWord (string word2check, integer pnDirection)
    integer retval

    if (pnDirection == LOOK_UP)
        retval = pos(word2check, " if begin while do for ")

// new code starts here
        if (word2check == " do ") // the next word should be 'case' or 'while'
            pushPosition()
            gotopos(posFirstNonWhite())
            wordRight()
            retval = pos(format(' ', lower(getWordAtCursor()), ' '), " case while ")
            popPosition()
        endif
// new code ends here

    elseif (pnDirection == LOOK_DOWN)
        retval = pos(word2check, " end endif enddo endcase next ")

    else
        retval = pos(word2check, " else elseif case otherwise ")

    endif

    return (retval)
end

// **************************************************************************
integer proc findOther (integer pnDirection)
    integer lFound      = FALSE
    integer numFound    = 0

    pushPosition()

    while (iif (pnDirection == LOOK_UP, up(), down()))

        if (mCheckWord (mGetFirstWord(), not pnDirection))
            numFound = numFound + 1

        elseif (mCheckWord (mGetFirstWord(), pnDirection))
            if (numFound == 0)
                lFound = TRUE
                gotoPos(posFirstNonWhite())
                break
            else
                numFound = numFound - 1
            endif
        endif
    endwhile

    if (lFound)
        killPosition()
    else
        popPosition()
        warn("Match not found")
    endif
    return (lFound)
end

// **************************************************************************
// main function
//
integer proc findMatch()
    string  currWord[ MAX_WORD_LENGTH] = ""
    integer retval = FALSE

    currWord = Lower(getWordAtCursor()) // added Lower WP4

    if (length(currWord))

        lower(currWord) // seems unnecessary now WP4

        if (mCheckWord (currWord, LOOK_UP))
            retval = findOther(LOOK_DOWN)

        elseif (mCheckWord (currWord, LOOK_DOWN))
            retval = findOther(LOOK_UP)

        endif
    endif
    return (retval)
end
