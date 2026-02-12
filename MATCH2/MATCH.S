//  mLanguageMatch()         v2.00
//
//  Peter Birch
//  06/14/93
//
//      This macro will find the matching language control statements such
//      as 'if' and 'endif' in your source code.  It works well with
//      mMatch() supplied with TSE.
//
//  This needs  GetFirstWord()      from TSE.S
//              GetWordAtCursor()   from TSE.S
//              mMatch()            from TSE.S
//
//
//  Suggested usage for this macro is as follows:
//
//     Bind mLanguageMatch() to the key you are presently using for
//     mMatch().  Have SC burn the macros into E.EXE.  Then in your
//     language source file put your cursor on a language control statement
//     such as 'if', 'endif', 'while', 'end', etc.  Then hit the key that
//     mMatch() was bound to.  This macro will take you to the opposite (or
//     compliment) statement and if the cursor is on a [{()}] etc. that
//     mMatch worked with, it will still work.
//
//
//
//  main function in this source file is mLanguageMatch()
//

constant    LOOK_UP         =    0
constant    LOOK_DOWN       =    1
constant    LOOK_AROUND     =   -1
constant    MAX_WORD_SIZE   =   20

integer     gDirection      = LOOK_DOWN

// **************************************************************************
// currently these are xBase (Clipper) words
// with no options for determining the type of file being edited.
//
integer proc mCheckWord (string word2check, integer pnDirection)
    integer retval

    if (pnDirection == LOOK_UP)
        retval = pos(word2check, " if begin while do for ")

        if (word2check == " do ") // the next word should be 'case' or 'while'
            pushPosition()
            gotopos(posFirstNonWhite())
            wordRight()
            retval = pos(format(' ', lower(getWordAtCursor()), ' '), " case while ")
            popPosition()
        endif

    elseif (pnDirection == LOOK_DOWN)
        retval = pos(word2check, " end endif enddo endcase next ")

    else
        retval = pos(word2check, " else elseif case otherwise ")

    endif

    return (retval)
end

// **************************************************************************
integer proc findOther ()
    integer lFound      = FALSE
    integer numFound    = 0

    while (iif (gDirection == LOOK_UP, up(), down()))

        if (mCheckWord (GetFirstWord(), LOOK_AROUND))
            if (numFound == 0)
                lFound = TRUE
                gotoPos(posFirstNonWhite())
                break
            endif

        elseif (mCheckWord (GetFirstWord(), not gDirection))
            numFound = numFound + 1

        elseif (mCheckWord (GetFirstWord(), gDirection))
            if (numFound == 0)
                lFound = TRUE
                gotoPos(posFirstNonWhite())
                break
            else
                numFound = numFound - 1
            endif
        endif
    endwhile

    return (lFound)
end

// **************************************************************************
integer proc findMatch()

    integer retval                   = FALSE
    string  currWord[ MAX_WORD_SIZE] = format(' ', getWordAtCursor(), ' ')

    if (length(currWord))

        if (mCheckWord (currWord, LOOK_UP))
            gDirection = LOOK_DOWN
            retval = findOther()

        elseif (mCheckWord (currWord, LOOK_DOWN))
            gDirection = LOOK_UP
            retval = findOther()

        elseif (mCheckWord (currWord, LOOK_AROUND))
            retval = findOther()

        endif
    endif
    return (retval)
end

// **************************************************************************
proc mLanguageMatch ()
    if (not (language and not cmode and findMatch()))
        mMatch()
    endif
end
