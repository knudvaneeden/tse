/*************************************************************************
  SpellChk    Spell checks a word, block, or file.

  Author:     SemWare (Sammy Mitchell)
  컴컴컴�

  Date:       Jun  4  1993 - Initial version
  컴컴�       May  27 1994 - Miscellaneous cleanup

  Overview:
  컴컴컴컴�

  This macro allows you to check the spelling of the word at the cursor,
  a marked block, from the cursor to the end of file, or the entire
  file.

  Keys:       <F12> - also available on the TSE Util menu.
  컴컴�

  Usage notes:
  컴컴컴컴컴컴

  Uses 3 word lists:

    semware.lex (supplied by SemWare)

    user.lex (user supplied)
      SpellCheck will add to and update (on disk) this file after
      every invocation of SpellCheck.

    personal.lex (user supplied)
      SpellCheck will load this file if found, but will never
      update it.

  Word lists are loaded by using SearchPath(name, TSEPath, "spell")

  Copyright 1992-1994 SemWare Corporation.  All Rights Reserved Worldwide.

  Use, modification, and distribution of this SAL macro is encouraged by
  SemWare provided that this statement, including the above copyright
  notice, is not removed; and provided that no fee or other remuneration
  is received for distribution.  You may add your own copyright notice
  to cover new matter you add to the macro, but SemWare Corporation will
  neither support nor assume legal responsibility for any material added
  or any changes made to the macro.

*************************************************************************/

binary ['spellbin.bin']
    integer proc OpenSpell(string fn) : 0
    integer proc CloseSpell() : 3
    integer proc SpellCheckWord(string word) : 6
    integer proc SuggestWord(string word) : 9
            proc GetSuggestion(var string word, integer n) : 12
end

constant
    MINIMUM_WORD_LENGTH = 2,
    IGNORE_NON_ALPHA_WORDS = TRUE

constant
    SKIPONCE = 12, IGNORE = 13, EDIT = 14, ADD = 15, TAG = 16, QUIT = 17,
//    spESCAPE = 0, spFILE = 1, spREST = 2, spBLOCK = 3, spWORD = 4,
    spESCAPE = 0, spWORD = 1, spBLOCK = 2, spFILE = 3, spREST = 4,
    MAXWORD = 32,
    PATHLEN = 60

integer count, curr_id, ignore_id, addl_id, added_to_addl,
    suggestion, number_suggestion, edit_word_history

string main_disk_fn[PATHLEN] = "semware.lex",
    addl_buffer_name[] = "+++addl@words+++", addl_disk_fn[PATHLEN] = "user.lex",
    ignore_buffer_name[] = "+++ignore@words+++", ignore_disk_fn[PATHLEN] = "personal.lex"

menu SpellMenu()
    Title = "Spell Check"
    History

//    "&File"
//    "&Rest of File"
//    "&Block"
//    "&Word"
    "&Word"
    "&Block"
    "&File"
    "&Rest of File"
end

string proc GetNextSuggestion()
    string word[MAXWORD] = ""

    if number_suggestion
        number_suggestion = number_suggestion - 1
        suggestion = suggestion + 1
        GetSuggestion(word, suggestion)
        if Length(word) < sizeof(word)
            word = Format(' ', word:-MAXWORD)
        endif
    endif
    return (word)
end

menu WhatToDoMenu()
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    "",,DIVIDE
    "&Skip Once"
    "&Ignore for Rest of Session"
    "&Edit"
    "&Add to Word List"
    "&Tag"
    "&Quit"
end

integer proc FindWordIn(string word, integer id)
    integer ok

    GotoBufferId(id)
    ok = lFind(word, "gw")
    GotoBufferId(curr_id)
    return (ok)
end

string proc GetWord()
    string word[MAXWORD]

    PushBlock()
    if CurrChar() == _AT_EOL_   Left()   //RBH:Jan95
    endif                                //RBH:Jan95
    MarkWord()
    word = GetMarkedText()
    PopBlock()
//    EndWord()                            //RBH:Jan95
    return (word)
end

integer last_ticks, reset_ticks

integer proc SpellCheck()
    integer col, i, ticks
    string word[MAXWORD], raw_word[MAXWORD], tword[MAXWORD]
    tword = ""             //RBH:Jan95  to eliminate compile "initialization" warning
    ticks = GetClockTicks()
    if reset_ticks
        last_ticks = ticks
        reset_ticks = FALSE
    elseif ticks - last_ticks > 12 or ticks < last_ticks
        last_ticks = ticks
        UpdateDisplay(_CLINE_REFRESH_)
        if Query(MsgLevel) == _ALL_MESSAGES_
            Message(count)
        endif
    endif

    retry:

    raw_word = GetWord()

    if SpellCheckWord(raw_word)
        return (TRUE)
    endif

    // try to handle hyphenated words at the eol
    // unfortunately, we can't (yet) correct them
    word = ''

    PushPosition()
    GotoPos(CurrPos() + Length(raw_word))
    if CurrPos() == PosLastNonWhite() and CurrChar() == Asc('-')
        EndLine()
        if WordRight() and isWord()
            word = raw_word + GetWord()
        endif
    endif
    if Length(word) and SpellCheckWord(word)
        KillPosition()
        return (TRUE)
    endif
    PopPosition()
    // end of eol hyphenation code...

    if raw_word[1] == "'"
        raw_word = substr(raw_word, 2, sizeof(raw_word))
    endif

    if raw_word[Length(raw_word)] == "'"
        raw_word = substr(raw_word, 1, Length(raw_word) - 1)
    endif

    word = Lower(raw_word)
    if FindWordIn(word, addl_id) or FindWordIn(word, ignore_id)
        return (TRUE)
    endif

    if Length(word) < MINIMUM_WORD_LENGTH
        return (TRUE)
    endif

    if IGNORE_NON_ALPHA_WORDS
        i = Length(word)
        while i
            if (word[i] < 'a' or word[i] > 'z') and word[i] <> "'"
                return (TRUE)
            endif
            i = i - 1
        endwhile
    endif

    reset_ticks = TRUE
    if CurrChar() == 0x27
        Right()
    endif
    col = CurrCol()
    EndWord()       // force word on-screen
    GotoColumn(col)
    ScrollToRow(4 - (Query(DisplayBoxed) <> 0))

    UpdateDisplay(_CLINE_REFRESH_ | _STATUSLINE_REFRESH_)
    VGotoXY(wherex(), wherey())
    PutAttr(Query(HiLiteAttr), Length(word))

    Set(Y1, 14)
    Set(X1, 60)

    suggestion = 0
    number_suggestion = SuggestWord(raw_word)

    case WhatToDoMenu(chr(34) + raw_word + chr(34) + " not found")
        when 1 .. 10
            if MenuOption() <= suggestion
                GetSuggestion(tword, MenuOption())
                lreplace(raw_word, tword, "n1")

                goto retry
            endif

        when SKIPONCE
            return (TRUE)
        when IGNORE
            AddLine(word, ignore_id)
            return (TRUE)
        when EDIT
            tword = raw_word
            if ask("Change word:", tword, edit_word_history)
                lreplace(raw_word, tword, "n1")
            endif

            goto retry

        when ADD
            AddLine(word, addl_id)
            added_to_addl = added_to_addl + 1
            return (TRUE)

        when TAG
            lreplace(raw_word, chr(174) + raw_word + chr(175), "n1")
            Right()
            return (TRUE)

        when QUIT, 0
            return (FALSE)

    endcase
    return (TRUE)
end

integer proc LoadWordsFile(integer id, string buffer_name, string diskfile_name)
    if id == 0
        id = GetBufferId(buffer_name)
        if id == 0
            PushBlock()

            id = CreateBuffer(buffer_name, _HIDDEN_)
            if FileExists(diskfile_name)
                InsertFile(diskfile_name)
            endif

            PopBlock()
            GotoBufferId(curr_id)
        endif
    endif
    return (id)
end

proc SaveAddlWordList()
    if added_to_addl
        GotoBufferId(addl_id)
        SaveAs(addl_disk_fn, _OVERWRITE_)
        GotoBufferId(curr_id)
    endif
end

proc Main()
    integer n, b, finished = TRUE
    string old_wordset[32]

    curr_id = GetBufferId()
    b = isBlockInCurrFile()
    n = SpellMenu()
    if n == spESCAPE
        return ()
    endif
    if b == 0 and n == spBLOCK
        Warn("No block Marked")
        return ()
    endif

    if not OpenSpell(main_disk_fn)
        warn("Can't load word list: ", main_disk_fn)
        return ()
    endif

    // at this point, main lexicon is loaded

    old_wordset = Set(WordSet, ChrSet("A-Za-z'0-9\d128-\d165"))
    PushBlock()
    PushPosition()
    Set(Marking, off)
    case n
        when spFILE
            BegFile()
        when spBLOCK
            GotoBlockBegin()
            if b == _LINE_
                BegLine()
            endif
        otherwise
                if CurrChar() == _AT_EOL_  Left()   //RBH:Jan95
                endif                               //RBH:Jan95
            BegWord()
    endcase

    added_to_addl = 0
    count = 0

    goto find_word
    loop
        count = count + 1

        if not SpellCheck()
            finished = FALSE
            goto common_exit

        endif
        WordRight()

        find_word:

        while not isWord()
            if not WordRight()
                goto common_exit

            endif
        endwhile

        case n
            when spWORD
                if count
                    goto common_exit

                endif
            when spBLOCK
                loop
                    if isCursorInBlock() and isWord()
                        break
                    endif
                    if not WordRight() or CurrLine() > Query(BlockEndLine)
                        goto common_exit

                    endif
                endloop
        endcase

    endloop

common_exit:

    SaveAddlWordList()
    Set(WordSet, old_wordset)
    CloseSpell()
    if finished
        PopPosition()
        EndWord()                             //RBH:Jan95
        if Query(MsgLevel) == _ALL_MESSAGES_
            Message("Finished...")
        endif
    else
        KillPosition()
    endif
    PopBlock()
end

string proc FindFile(string fn)
    return (SearchPath(fn, Query(TSEPATH), "SPELL\"))
end

proc WhenLoaded()
    string fn[PATHLEN]

    curr_id = GetBufferId()

    fn = FindFile(main_disk_fn)
    if Length(fn)
        main_disk_fn = fn
    endif

    fn = FindFile(addl_disk_fn)
    if Length(fn) == 0
        addl_disk_fn = SplitPath(main_disk_fn, _DRIVE_|_PATH_) + addl_disk_fn
    else
        addl_disk_fn = fn
    endif

    ignore_disk_fn = FindFile(ignore_disk_fn)

    addl_id = LoadWordsFile(addl_id, addl_buffer_name, addl_disk_fn)
    ignore_id = LoadWordsFile(ignore_id, ignore_buffer_name, ignore_disk_fn)
    edit_word_history = GetFreeHistory()
end

