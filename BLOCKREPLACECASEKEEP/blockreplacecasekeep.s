/*
   FNBlockReplaceCaseKeepB()
   TSE SAL - standalone library function (no Main, no helper macros).

   Based on the case-copying replacement algorithm in ccRepl.s
   by Carlo Hogeveen (30 June 1999).

   Replaces individual-line matches ONLY inside a marked block in
   the current file.  Preserves upper/lower case character-by-character.
   If the replacement is longer, the final matched character supplies
   the case for the additional characters.

   Return value: number of actual replacements.
   Requires an existing marked block (line, stream, or column).
   Supports ordinary lFind options, but NOT regex (x), ViewFinds (v),
   or multiline search strings. 'l' (local/marked block) is always forced; 'g' is removed.

   No Main() is supplied: call FNBlockReplaceCaseKeepB() from your library.
*/

integer proc FNBlockReplaceCaseKeepB()
    integer i = 0
    integer j = 0
    integer times = MAXINT
    integer skip_one = FALSE
    integer changes = 0
    integer quit_now = FALSE
    string character[1] = ""
    string old[255] = ""
    string new[255] = ""
    string opt[255] = "i"
    string searchopt[255] = ""
    string old2[255] = ""
    string new2[255] = ""

    if not IsBlockInCurrFile()
        Warn("FNBlockReplaceCaseKeepB: Please mark a block in the current file")
        return(0)
    endif

    if not Ask("Block: Search for:", old, 168)
        return(0)
    endif
    if not Ask("Block: Replace with:", new, 169)
        return(0)
    endif
    if not Ask("Block: Options [acinw^$#] (l forced, i default):", opt, 161)
        return(0)
    endif

    opt = Lower(opt)
    if Length(old) == 0
        Warn("Search string cannot be empty")
        return(0)
    endif
    if Pos("v", opt) or Pos("x", opt)
        Warn("Options v and x are not supported")
        return(0)
    endif

    // Extract an optional replacement count from the option string.
    // Match the original ccRepl convention (first run of digits).
    for i = 1 to Length(opt)
        if opt[i] in "0" .. "9"
            for j = Length(opt) downto i
                if opt[j] in "0" .. "9"
                    times = Val(SubStr(opt, i, j - i + 1))
                    j = i
                endif
            endfor
            i = Length(opt)
        endif
    endfor

    // Rebuild options, stripping any user-supplied global/wrap controls,
    // the local flag (added exactly once), and numeric count.
    searchopt = ""
    for i = 1 to Length(opt)
        if not (opt[i] in "0" .. "9")
        and opt[i] <> "g"
        and opt[i] <> "l"
        and opt[i] <> "+"
            searchopt = searchopt + opt[i]
        endif
    endfor
    searchopt = searchopt + "l"

    PushPosition()
    GotoBlockBegin()

    while times > 0
    and not quit_now
    and lFind(old, searchopt)
    and IsCursorInBlock()
        skip_one = FALSE

        if Pos("n", searchopt) == 0
            if Query(CenterFinds)
                ScrollToCenter()
            endif
            HiLiteFoundText()
            Message("L ", CurrLine(), "  Replace (Yes/No/Only/Rest/Quit):")
            repeat
                character = Lower(Chr(GetKey()))
                if Query(Key) == <Escape>
                    character = "q"
                endif
            until character in "y", "n", "o", "r", "q"

            case character
                when "n"
                    skip_one = TRUE
                when "o"
                    times = 1
                when "r"
                    searchopt = searchopt + "n"
                when "q"
                    skip_one = TRUE
                    quit_now = TRUE
            endcase
        endif

        if not skip_one
            old2 = GetText(CurrPos(), Length(old))
            new2 = new
            DelChar(Length(old))
            for i = 1 to Length(new2)
                j = Min(i, Length(old2))
                if old2[j] in "A" .. "Z"
                    new2[i] = Upper(new2[i])
                elseif old2[j] in "a" .. "z"
                    new2[i] = Lower(new2[i])
                endif
            endfor
            InsertText(new2, _INSERT_)
            Left(Length(new2))
            changes = changes + 1
        endif

        // Subsequent searches advance, including after a skipped match.
        if Pos("+", searchopt) == 0
            searchopt = searchopt + "+"
        endif
        times = times - 1
    endwhile

    PopPosition()
    Message(changes, " block replacement(s) made")
    return(changes)
end

PROC Main()
 FNBlockReplaceCaseKeepB()
END
