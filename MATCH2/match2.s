//  MATCH2                   version 1.0.0.0.12
//  Package date             2026-09-21 23:48:49 UTC
//  Updated with             OpenAI Codex
//
//  mLanguageMatch()         original version 2.00
//
//  Peter Birch
//  06/14/93
//
//      This macro will find the matching language control statements such
//      as 'if' and 'endif' in your source code.  It works well with
//      the standard matching behavior originally supplied as MATCH.S.
//
//  This needs  GetWord()           built into current TSE versions
//
//
//  Suggested usage for this macro is as follows:
//
//     Bind mLanguageMatch() to the key you are presently using for
//     the standard matching macro.  Have SC burn the macros into E.EXE.
//     Then in your
//     language source file put your cursor on a language control statement
//     such as 'if', 'endif', 'while', 'end', etc.  Then hit the key that
//     matching macro was bound to.  This macro will take you to the opposite
//     (or
//     compliment) statement and if the cursor is on a [{()}] etc. that
//     standard matching worked with, it will still work.
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
string proc FNGetFirstWord()
    string firstWord[MAX_WORD_SIZE + 2]

    PushPosition()
    GotoPos(PosFirstNonWhite())
    firstWord = Format(' ', Lower(GetWord()), ' ')
    PopPosition()

    return(firstWord)
end

// **************************************************************************
// currently these are xBase (Clipper) words
// with no options for determining the type of file being edited.
//
integer proc mCheckWord (string word2check, integer pnDirection)
    integer retval

    if (pnDirection == LOOK_UP)
        retval = pos(word2check, " if begin while do for loop repeat ")

        if (word2check == " do ") // the next word should be 'case' or 'while'
            pushPosition()
            gotopos(posFirstNonWhite())
            wordRight()
            retval = pos(format(' ', lower(GetWord()), ' '), " case while ")
            popPosition()
        endif

    elseif (pnDirection == LOOK_DOWN)
        retval = pos(word2check, " end endif enddo endwhile endfor endloop until endcase next ")

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

        if (mCheckWord (FNGetFirstWord(), LOOK_AROUND))
            if (numFound == 0)
                lFound = TRUE
                gotoPos(posFirstNonWhite())
                break
            endif

        elseif (mCheckWord (FNGetFirstWord(), not gDirection))
            numFound = numFound + 1

        elseif (mCheckWord (FNGetFirstWord(), gDirection))
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
integer proc FNFindControlMatch(integer directionI, string openWordS, string closeWordS)
    integer foundI = FALSE
    integer levelI = 1
    string firstWordS[MAX_WORD_SIZE + 2]

    PushPosition()
    while iif(directionI == LOOK_UP, Up(), Down())
        firstWordS = FNGetFirstWord()

        if directionI == LOOK_DOWN
            if firstWordS == openWordS
                levelI = levelI + 1
            elseif firstWordS == closeWordS
                levelI = levelI - 1
            endif
        else
            if firstWordS == closeWordS
                levelI = levelI + 1
            elseif firstWordS == openWordS
                levelI = levelI - 1
            endif
        endif

        if levelI == 0
            foundI = TRUE
            KillPosition()
            GotoPos(PosFirstNonWhite())
            break
        endif
    endwhile

    if not foundI
        PopPosition()
    endif

    return(foundI)
end

// **************************************************************************
integer proc FNFindNextCaseKeyword()
    integer foundI = FALSE
    integer levelI = 0
    string firstWordS[MAX_WORD_SIZE + 2]

    PushPosition()
    while Down()
        firstWordS = FNGetFirstWord()

        if levelI == 0 and (firstWordS == " when " or firstWordS == " otherwise ")
            foundI = TRUE
            KillPosition()
            GotoPos(PosFirstNonWhite())
            break
        elseif firstWordS == " case "
            levelI = levelI + 1
        elseif firstWordS == " endcase "
            if levelI == 0
                foundI = TRUE
                KillPosition()
                GotoPos(PosFirstNonWhite())
                break
            else
                levelI = levelI - 1
            endif
        endif
    endwhile

    if not foundI
        PopPosition()
    endif

    return(foundI)
end

// **************************************************************************
integer proc findMatch()

    integer retval                   = FALSE
    string  currWord[ MAX_WORD_SIZE] = format(' ', Lower(GetWord()), ' ')

    if (length(currWord))

        if currWord == " while "
            gDirection = LOOK_DOWN
            retval = FNFindControlMatch(LOOK_DOWN, " while ", " endwhile ")

        elseif currWord == " endwhile "
            gDirection = LOOK_UP
            retval = FNFindControlMatch(LOOK_UP, " while ", " endwhile ")

        elseif currWord == " for "
            gDirection = LOOK_DOWN
            retval = FNFindControlMatch(LOOK_DOWN, " for ", " endfor ")

        elseif currWord == " endfor "
            gDirection = LOOK_UP
            retval = FNFindControlMatch(LOOK_UP, " for ", " endfor ")

        elseif currWord == " loop "
            gDirection = LOOK_DOWN
            retval = FNFindControlMatch(LOOK_DOWN, " loop ", " endloop ")

        elseif currWord == " endloop "
            gDirection = LOOK_UP
            retval = FNFindControlMatch(LOOK_UP, " loop ", " endloop ")

        elseif currWord == " do "
            gDirection = LOOK_DOWN
            retval = FNFindControlMatch(LOOK_DOWN, " do ", " enddo ")

        elseif currWord == " enddo "
            gDirection = LOOK_UP
            retval = FNFindControlMatch(LOOK_UP, " do ", " enddo ")

        elseif currWord == " repeat "
            gDirection = LOOK_DOWN
            retval = FNFindControlMatch(LOOK_DOWN, " repeat ", " until ")

        elseif currWord == " until "
            gDirection = LOOK_UP
            retval = FNFindControlMatch(LOOK_UP, " repeat ", " until ")

        elseif currWord == " case "
            gDirection = LOOK_DOWN
            retval = FNFindNextCaseKeyword()

        elseif currWord == " endcase "
            gDirection = LOOK_UP
            retval = FNFindControlMatch(LOOK_UP, " case ", " endcase ")

        elseif currWord == " when " or currWord == " otherwise "
            gDirection = LOOK_DOWN
            retval = FNFindNextCaseKeyword()

        elseif (mCheckWord (currWord, LOOK_UP))
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
// Self-contained fallback based on SemWare's standard MATCH.S behavior.
// It matches () {} [] <> pairs and reports the length of quoted strings.
string GSMatchChars[8] = "(){}[]<>"

proc PROCCountString()
    integer startPosI

    startPosI = CurrPos()
    PushPosition()
    if lFind(Chr(CurrChar()), "+c")
        Message("String is ", CurrPos() - startPosI - 1, " characters long.")
    else
        Message("End of string not found...")
    endif
    PopPosition()
end

proc PROCStandardMatch()
    integer matchPosI
    integer levelI
    integer matchCharI
    integer currentCharI
    integer startLineI = CurrLine()
    integer startRowI = CurrRow()

    matchPosI = Pos(Chr(CurrChar()), GSMatchChars)
    if matchPosI == 0
        if CurrChar() in Asc('"'), Asc("'")
            PROCCountString()
        elseif lFind("[(){}[\]<>]", "x")
            ScrollToRow(CurrLine() - startLineI + startRowI)
        endif
        return()
    endif

    PushPosition()
    currentCharI = Asc(GSMatchChars[matchPosI])
    matchCharI = Asc(GSMatchChars[iif(matchPosI & 1, matchPosI + 1, matchPosI - 1)])
    levelI = 1

    while lFind("[\" + Chr(currentCharI) + "\" + Chr(matchCharI) + "]", iif(matchPosI & 1, "x+", "xb"))
        case CurrChar()
            when currentCharI
                levelI = levelI + 1
            when matchCharI
                levelI = levelI - 1
                if levelI == 0
                    KillPosition()
                    GotoXoffset(0)
                    ScrollToRow(CurrLine() - startLineI + startRowI)
                    return()
                endif
        endcase
    endwhile

    PopPosition()
    Warn("Match not found")
end

// **************************************************************************
proc mLanguageMatch ()
    if (not findMatch())
        PROCStandardMatch()
    endif
end

// **************************************************************************
keydef Match2Keys
    <Alt F3> mLanguageMatch()
end

proc WhenLoaded()
    Enable(Match2Keys)
end

// **************************************************************************
proc Main()
    Warn("MATCH2 1.0.0.0.12 is loaded. Press <Alt F3> on a supported language control word or bracket to jump to its matching partner.")
end
