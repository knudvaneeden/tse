// NEXTERR2 1.0.0.0.2 - standalone error navigation companion.
// Based on the error navigation example in NEXTERR.DOC by Andreas Martini.
// Expects a source window and a window displaying $ERRORS$.TMP.

string GSRegSearch[80] = " #: #{Error}|{Warning} #C[0-9]#:"

integer proc FNParseError(var string filenameS, var integer lineI)
    string textS[255] = ""
    integer openI = 0
    integer closeI = 0
    integer commaI = 0
    textS = GetText(1, 255)
    openI = Pos("(", textS)
    closeI = Pos(")", textS)
    if openI <= 1 or closeI <= openI + 1
        return(FALSE)
    endif
    filenameS = SubStr(textS, 1, openI - 1)
    commaI = Pos(",", textS)
    if commaI > openI and commaI < closeI
        lineI = Val(SubStr(textS, openI + 1, commaI - openI - 1))
    else
        lineI = Val(SubStr(textS, openI + 1, closeI - openI - 1))
    endif
    return(lineI > 0)
end

integer proc FNFindError(var string filenameS, var integer lineI,
                         var integer columnI)
    if lFind(GSRegSearch, "IX")
        if not FNParseError(filenameS, lineI)
            return(FALSE)
        endif
        columnI = 1
        return(TRUE)
    endif
    return(FALSE)
end

proc PROCNextError(integer directionI)
    string filenameS[255] = ""
    integer lineI = 0
    integer columnI = 1

    if not GetBufferId(ExpandPath("$errors$.tmp"))
        Warn("NEXTERR2: Open $ERRORS$.TMP after compiling first.")
        return()
    endif

    NextWindow()
    if directionI
        Down()
        if not FNFindError(filenameS, lineI, columnI)
            PrevWindow()
            Warn("NEXTERR2: No next C compiler error found.")
            return()
        endif
    else
        Up()
        if not lFind(GSRegSearch, "IXB")
            PrevWindow()
            Warn("NEXTERR2: No previous C compiler error found.")
            return()
        endif
        if not FNParseError(filenameS, lineI)
            PrevWindow()
            Warn("NEXTERR2: Could not parse the compiler error location.")
            return()
        endif
    endif
    PrevWindow()
    if filenameS <> "" and lineI > 0
        EditFile(filenameS)
        GotoLine(lineI)
        GotoColumn(columnI)
        UpdateDisplay()
    else
        Warn("NEXTERR2: Could not parse the compiler error location.")
    endif
end

proc Main()
    string silentS[10] = ""
    silentS = Lower(GetProfileStr("nexterr2", "silent", "false",
                                  ExpandPath("nexterr2.ini")))
    if silentS <> "true"
        Warn("NEXTERR2 1.0.0.0.2: Find the next C compiler error ",
             "in $ERRORS$.TMP. Requires source and error windows.")
    endif
    PROCNextError(TRUE)
end

<CtrlAlt N> PROCNextError(TRUE)
<CtrlAlt P> PROCNextError(FALSE)
