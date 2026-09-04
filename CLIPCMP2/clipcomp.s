integer nId
integer nOldId
integer nRow

// **************************************************************************
string proc GetWordAtCursor()
    string word[80] = ''

    PushBlock()               // Save current block status
    if MarkWord()             // Mark and get the word
        word = GetMarkedText()
    endif
    PopBlock()                // Restore block status
    return (word)             // That's all, folks!
end

// **************************************************************************
proc nextError ()
    string  badString[ 80]

    pushblock()

    gotowindow(nId)

    if (lfind("{Fatal}|{Error}|{Warning}", "X"))

        // get line number
        begline()
        markline()
        markline()
        if (lfind("\([0-9]*\)", "LX"))
            right()
            nRow = val(getwordatcursor())
            // get bad word
            endline()
            left()
            left()
            lfind("'", "BL")
            unmarkblock()
            right()
            markchar()
            endline()
            left()
            markchar()
            badString = getmarkedtext()
            unmarkblock()

            gotowindow(nOldId)
            gotoline(nRow)
            begline()
            markline()
            markline()
            lfind(badstring, "WLI")
            unmarkblock()
        else
            warn("Don't know how to handle:" + getmarkedtext())
        endif
    else
        gotowindow(nOldId)
        warn("No more Errors/Warnings!")
    endif

    popblock()
end

// **************************************************************************
proc errComp ()
    string  fileName[ 80] = ""

    nOldId = windowid()
    nRow   = currline()

    if (ask("File to compile: ", fileName) and length(fileName))
        dos("Clipper " + fileName + " > ERROR.LOG", _DONT_PROMPT_)
        if (hwindow())
            editFile("ERROR.LOG")
            nId = windowid()
            nextError()
        endif
    endif
end

// **************************************************************************
proc main ()
    errComp()
end

<alt n> nextError()

