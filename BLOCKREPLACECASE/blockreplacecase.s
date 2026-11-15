// blockreplacecase.s - 1.0.0.0.3
// TSE SAL 4.50 - replace text ONLY inside a marked block.
// Search is literal and case-insensitive; L means LOCAL (marked block).
// B means BACKWARDS in TSE, NOT block.

integer proc FNLetter(string c)
    integer a
    a = Asc(c)
    return((a >= 65 and a <= 90) or (a >= 97 and a <= 122))
end

integer proc FNUpperLetter(string c)
    integer a
    a = Asc(c)
    return(a >= 65 and a <= 90)
end

integer proc FNVowel(string c)
    string lowerC[1]
    lowerC = Lower(c)
    return(lowerC == "a" or lowerC == "e" or lowerC == "i" or lowerC == "o" or lowerC == "u")
end

// Derive the case of the replacement from the typed SEARCH string.
// If search text uses mixed case and both strings have the same length,
// apply its uppercase/lowercase pattern letter by letter.
string proc FNMatchCase(string searchText, string replacement)
    integer i, n, allUpper, allLower, firstUpper, laterLower
    string c[1], out[255], adjusted[255]
    n = Length(searchText)
    allUpper = TRUE
    allLower = TRUE
    firstUpper = FALSE
    laterLower = TRUE
    for i = 1 to n
        c = SubStr(searchText, i, 1)
        if FNLetter(c)
            if not FNUpperLetter(c)
                allUpper = FALSE
            else
                allLower = FALSE
                if i == 1
                    firstUpper = TRUE
                else
                    laterLower = FALSE
                endif
            endif
        endif
    endfor
    if allUpper
        return(Upper(replacement))
    endif
    if allLower
        return(Lower(replacement))
    endif
    if firstUpper and laterLower
        adjusted = Lower(replacement)
        if Length(adjusted) > 0
            adjusted = Upper(SubStr(adjusted, 1, 1)) + SubStr(adjusted, 2, Length(adjusted))
        endif
        return(adjusted)
    endif
    if Length(searchText) == Length(replacement)
        out = ""
        for i = 1 to Length(replacement)
            c = SubStr(replacement, i, 1)
            if FNUpperLetter(SubStr(searchText, i, 1))
                out = out + Upper(c)
            else
                out = out + Lower(c)
            endif
        endfor
        return(out)
    endif
    return(replacement) // Ambiguous pattern: preserve the supplied replacement.
end

// Styles 2-17. Work on the REPLACEMENT string, not on the editor buffer.
// Non-letter/digit separators are normalized in identifier styles.
string proc FNStyle(string s, integer mode)
    integer i, a, wordStart, wordNo, letterNo, makeUpper, prevWasLower
    string c[1], result[255], sep[1], prev[1]
    if mode == 2
        return(Lower(s))
    endif
    if mode == 3
        return(Upper(s))
    endif
    if mode == 5
        result = ""
        for i = 1 to Length(s)
            c = SubStr(s, i, 1)
            if FNUpperLetter(c)
                result = result + Lower(c)
            else
                result = result + Upper(c)
            endif
        endfor
        return(result)
    endif
    if mode >= 6 and mode <= 9
        result = ""
        letterNo = 0
        for i = 1 to Length(s)
            c = SubStr(s, i, 1)
            if FNLetter(c)
                letterNo = letterNo + 1
                makeUpper = FALSE
                if mode == 6 and (letterNo mod 2) == 0
                    makeUpper = TRUE
                elseif mode == 7 and (letterNo mod 2) == 1
                    makeUpper = TRUE
                elseif mode == 8 and FNVowel(c)
                    makeUpper = TRUE
                elseif mode == 9 and not FNVowel(c)
                    makeUpper = TRUE
                endif
                if makeUpper
                    c = Upper(c)
                else
                    c = Lower(c)
                endif
            endif
            result = result + c
        endfor
        return(result)
    endif

    result = ""
    wordStart = TRUE
    wordNo = 0
    prevWasLower = FALSE
    sep = ""
    if mode == 10 or mode == 11 or mode == 12
        sep = "_"
    elseif mode == 15 or mode == 16 or mode == 17
        sep = "-"
    elseif mode == 4
        sep = " "
    endif
    prev = ""
    for i = 1 to Length(s)
        c = SubStr(s, i, 1)
        a = Asc(c)
        if FNLetter(c) or (a >= 48 and a <= 57)
            // A lower-to-upper transition begins another word: fooBar.
            if prevWasLower and FNUpperLetter(c)
                wordStart = TRUE
            endif
            if wordStart
                if wordNo > 0
                    result = result + sep
                endif
                wordNo = wordNo + 1
            endif
            makeUpper = FALSE
            if mode == 4 or mode == 13 or mode == 16
                makeUpper = wordStart
            elseif mode == 14
                makeUpper = wordStart and wordNo > 1
            elseif mode == 11 or mode == 17
                makeUpper = TRUE
            elseif mode == 12
                makeUpper = wordStart
            endif
            if makeUpper
                result = result + Upper(c)
            else
                result = result + Lower(c)
            endif
            prevWasLower = FNLetter(c) and not FNUpperLetter(c)
            wordStart = FALSE
        else
            wordStart = TRUE
            prevWasLower = FALSE
        endif
        prev = c
    endfor
    return(result)
end

menu BlockCaseMenu()
    title = "Replace case in marked block"
    "&0 Use INI default case"
    "&1 Match search text case"
    "&2 lower case"
    "&3 UPPER CASE"
    "&4 Capitalized Case / Title Case"
    "&5 fLIP cASE"
    "&6 aLtErNaTiNg (lower first)"
    "&7 AlTeRnAtInG (upper first)"
    "&8 vOwEls UPPER"
    "&9 CoNsOnAnTs UPPER"
    "&A snake_case"
    "&B SCREAMING_SNAKE_CASE"
    "&C Upper_then_lowercase"
    "&D UpperCamelCase / PascalCase"
    "&E lowerCamelCase"
    "&F kebab-case"
    "&G Train-Case"
    "&H UPPER-KEBAB-CASE"
end

proc Main()
    integer selection, mode, findHistory, replaceHistory
    string findText[255], replaceText[255], converted[255]
    string iniFile[255], defaultCase[32]

    if not isBlockInCurrFile()
        Warn("Mark a block in the current file first.")
        return()
    endif

    // INI resides beside the compiled macro, not in the current directory.
    iniFile = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_) + "blockreplacecase.ini"
    findText = GetProfileStr("Defaults", "searchstring", "", iniFile)
    replaceText = GetProfileStr("Defaults", "replacestring", "", iniFile)
    defaultCase = GetProfileStr("Defaults", "defaultcase", "1", iniFile)

    // Named independent TSE history lists, visible using Up/Down in Ask().
    // TSE preserves these between sessions when PersistentHistory is enabled.
    findHistory = GetFreeHistory("BLOCKREPLACECASE:searchstring")
    replaceHistory = GetFreeHistory("BLOCKREPLACECASE:replacestring")

    if not Ask("Find (literal text, ignore case):", findText, findHistory)
        return()
    endif
    if findText == ""
        Warn("The search text cannot be empty.")
        return()
    endif
    if not Ask("Replace with:", replaceText, replaceHistory)
        return()
    endif

    BlockCaseMenu()
    selection = MenuOption()
    if selection < 1 or selection > 18
        return()
    endif
    if selection == 1
        mode = Val(defaultCase)
    else
        mode = selection - 1
    endif
    if mode < 1 or mode > 17
        Warn("Invalid defaultcase in blockreplacecase.ini (expected 1..17).")
        return()
    endif

    if mode == 1
        converted = FNMatchCase(findText, replaceText)
    else
        converted = FNStyle(replaceText, mode)
    endif
    // i=ignore case, l=LOCAL marked block, g=global, n=no prompting.
    // No x option: typed search is literal, NOT a regular expression.
    lReplace(findText, converted, "giln")
end
