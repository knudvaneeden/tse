forward integer proc ListKeywords()

// user-definable settings
//hot key for this macro
<Alt Tab>   ListKeywords()

//constants for QBook format
constant MAX_KEYWLEN = 32           //maximum keyword length
string END_REC[]     = "-End Recipe Export-"    //end marker
string KEY_LINE[]    = "Keywords:"  //Header of keyword line
string KEY_SEP[]     = ", "         //keyword separator
constant MAX_KEYLINE = 78           //maximum length of keyword line

// end user-definable settings

constant LIST_WIDTH = MAX_KEYWLEN + 9   //width of keyword list box
integer keyw_id                         //list buffer id
string Marked_Keyw[MAX_KEYWLEN] = ""    //contains keyword to add to recipe
string  keyw_fn[128]                //keywords filename
integer File_id = 0

datadef KeywordList
    "Appetizers"
    "Desserts"
    "Main dish"
    "Side dish"
    "One dish"
    "Poultry"
    "Meats"
    "Fish"
    "Seafood"
    "Beverages"
    "Soups"
    "Stews"
    "Salads"
    "BBQ"
end

proc main()
    ListKeywords()
end

integer proc SaveKeywordFile()
    integer n, eof_type, level

    eof_type = Set(EOFType, _NONE_)
    level = Set(MsgLevel, _NONE_)
    n = SaveAs(keyw_fn, _OVERWRITE_)
    Set(MsgLevel, level)
    Set(EOFType, eof_type)
    return (n)
end

integer proc _InsertFile(string fn)
    integer level, success
    level = Set(MsgLevel, _NONE_)
    success = InsertFile(fn)
    UnmarkBlock()
    Set(MsgLevel, level)
    return (success)
end

integer proc LoadKeywordFile()
    string just_fn[12]
    integer success = FALSE, eof_type

    keyw_id     = CreateTempBuffer()

    if keyw_id
        just_fn = SplitPath(CurrMacroFileName(), _NAME_) + ".dat"
        keyw_fn = SearchPath(just_fn, Query(TSEPath) ,"mac")

        if keyw_fn == ''
            if YesNo("Create keyword file '"+just_fn+"'") == 1
                BegFile()
                keyw_fn = just_fn
                InsertData(KeyWordList)
                MarkColumn(1,1,NumLines(), MAX_KEYWLEN)
                Sort(_IGNORE_CASE_)         //sort for disk file
                UnmarkBlock()
                success = SaveKeywordFile()
            endif
        else
            eof_type = Set(EOFType, _NONE_)
            success = _InsertFile(keyw_fn)
            Set(EOFType, eof_type)
            if not success
                Warn("Error loading '",keyw_fn,"'")
            else
                BegFile()
            endif
        endif
    else
        Warn("Out of memory")
    endif

    return (success)
end

proc WhenLoaded()
    File_id = GetBufferId()

//    set(Break, ON)

    if not LoadKeywordFile()
        PurgeMacro(CurrMacroFileName())
    endif

    GotoBufferId(File_id)
end

proc WhenPurged()
    AbandonFile(keyw_id)
end

integer proc FindKeyword(string word)
    integer id, line

    line = 0
    id = 0

    id = GotoBufferId(keyw_id)
    if id
        line = lFind(word, "^giw")     //0 = not found
        //options: ^ = BOL, g = BOF, i = insensitive, w = whole words
        GotoBufferId(id)
    endif
    return (line)
end

integer proc AddKeyword()      //add a keyword
    integer id, line, n
    string word[MAX_KEYWLEN]

    word = ''

    n = Ask("Enter keyword:",word)        //return 0 = escape pressed
    if n
        line = FindKeyword(word)
        if line
            Warn("That keyword already exists!")
            Return(FALSE)
        Endif
        word = Trim(word)
        id = GotoBufferId(keyw_id)
        BegFile()
        BegLine()
        InsertLine(word)
        MarkColumn(1,1,NumLines(), MAX_KEYWLEN)
        Sort(_IGNORE_CASE_)         //sort for display purposes
        UnmarkBlock()
        SaveKeywordFile()
        GotoBufferId(id)
        return (TRUE)
    endif
    return (FALSE)
end

integer proc lDelKeyword(integer line)
    integer id

    id = GotoBufferId(keyw_id)

    GotoLine(line)
    KillLine()
    SaveKeywordFile()

    GotoBufferId(id)

    return (TRUE)
end

integer proc DelKeyword()
    if YesNo("Delete "+trim(GetText(1,MAX_KEYWLEN))) == 1
        return (lDelKeyword(CurrLine()))
        //need to get line number to pass to lDelKeyword
    endif
    return (FALSE)
end

constant listESCAPE     =   0,
         listENTER      =   1,
         listDEL        =   2,
         listINS        =   3

HelpDef ListKeysHelp
    title = "Help on keys"
    x = 27
    y = 5

    "<Enter>      Add keyword to recipe    "
    ""
    "<Ins>        Add new keyword to list  "
    ""
    "<Del>        Delete keyword from list "
    ""
    "<Escape>     Close keyword list       "
    ""
    ""
    "NOTE: The recipe MUST have a valid    "
    "'end of recipe' line for this macro   "
    "to work properly!.                    "
    ""
    "For example, '-End Recipe Export-'    "
    "for a QBook format recipe.            "
end

proc HelpHook()
    BreakHookChain()
end

proc HelpOnListKeys()
    if Hook(_LIST_STARTUP_, HelpHook)
        QuickHelp(ListKeysHelp)
        UnHook(HelpHook)
    endif
end


keydef ListKeys
    <Escape>        EndProcess(listESCAPE)
    <Enter>         EndProcess(listENTER)
    <Del>           EndProcess(listDEL)
    <GreyDel>       EndProcess(listDEL)
    <Ins>           EndProcess(listINS)
    <GreyIns>       EndProcess(listINS)
    <F1>            HelpOnListKeys()
end

proc ListStartup()
    if Enable(ListKeys)
        WindowFooter(" {F1}-Help")
        BreakHookChain()
    endif
end

integer proc RecAddKey()

string NewKeyLine[MAX_KEYLINE] = ""
string Newkey[MAX_KEYWLEN + Sizeof(KEY_SEP) + 1] = ""
string templine[200] = ""

    if Marked_Keyw == ""    //nothing to add!
        Warn("ERROR! No keyword to add.")
        Return(FALSE)
    Endif
    GoToBufferId(File_id)
    if not Find(END_REC, "i")
        Warn("ERROR! Can't find recipe end marker.")
        Return(FALSE)
    Endif
    if not Find(KEY_LINE, "ib")
        Warn("ERROR! Can't find keywords line.")
        Return(FALSE)
    Endif
    MarkLine()
    templine = trim(GetMarkedText())
    if ((Upper(templine)) == (Upper(KEY_LINE)))
        UnmarkBlock()
        EndLine()
        Newkey = " " + Marked_Keyw
        InsertText(Newkey)
    Else
        UnmarkBlock()
        EndLine()
        Newkey = KEY_SEP + Marked_Keyw
        InsertText(Newkey)
    Endif
    if (CurrLineLen() > MAX_KEYLINE)
        while (CurrLineLen() > MAX_KEYLINE)
            UnmarkBlock()
            EndLine()
            Find(KEY_SEP, "bic")
            MarkFoundText()
            KillBlock()
            Mark(_INCLUSIVE_)
            EndLine()
            Mark(_NONINCLUSIVE_)
            NewKeyLine = NewKeyLine + GetMarkedText()
            KillBlock()
        endwhile
        NewKeyLine = KEY_LINE + " " + NewKeyLine
        AddLine(NewKeyLine)
    Endif
    BegLine()
    Return(TRUE)
End


public integer proc ListKeywords()
    integer id, line, n

    line = 0

    id = GotoBufferId(keyw_id)

    Hook(_LIST_STARTUP_, ListStartup)

    loop
        GotoBufferId(keyw_id)
        if NumLines()           //file = 'keyw_id'
            BegFile()
            n = lList("Keywords", LIST_WIDTH, NumLines(), _ENABLE_SEARCH_ | _ANCHOR_SEARCH_)

            case n
                when listENTER
                    line = CurrLine()
                    break
                when listDEL
                    DelKeyword()
                when listINS
                    AddKeyword()
                when listESCAPE
                    break
            endcase

        else
            Warn("No keywords to list")
            break

        endif
    endloop

    UnHook(ListStartup)

    GotoBufferId(id)

    if line
        GotoBufferId(keyw_id)
        MarkLine()
        Marked_Keyw = GetMarkedText()
        UnmarkBlock()
        GotoBufferId(id)
        RecAddKey()         //routine to add keyword
        Marked_Keyw = ""
    endif
    return (line)
end


