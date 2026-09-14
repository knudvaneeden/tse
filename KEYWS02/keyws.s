#include ["keyws.dat"]
//hot key for this macro
<Ctrl F3>   FixKeywords()

/***************************************************************************
                                proc main()
 ***************************************************************************/
proc main()
    FixKeywords()
end main

/***************************************************************************
                    public integer proc FixKeywords()
 ***************************************************************************/
public integer proc FixKeywords()
    integer id, success = _SUCCESS

//    PushPosition()
    id = GetBufferId()
    success = GetBuffers()
    if (not success)
        goto FAIL
    endif

    loop
        success = KeywordMenu()
        if (success == _EXIT)
            break
        elseif
            (success == _ABORT)
            break
        endif
    endloop

    FAIL:
//    PopPosition()
    AbandonFile(keyw_id)
    AbandonFile(newkeyw_id)
    AbandonFile(work_id)
    AbandonFile(autoscan_id)
    AbandonFile(autoscan1_id)
    AbandonFile(maincat_id)
    AbandonFile(country_id)
    return(success)

end FixKeywords

/***************************************************************************
                    integer proc GetBuffers()
 ***************************************************************************/
integer proc GetBuffers()
    integer success = _SUCCESS

    curr_id = GetBufferId()

    work_id = CreateBuffer("Work", _HIDDEN_)
    if (not work_id)
        Warn("Can't create work buffer")
        return(_FAIL)
    endif

    newkeyw_id = CreateBuffer("NewKeys", _HIDDEN_)
    if (not newkeyw_id)
        Warn("Can't create new keyword buffer")
        return(_FAIL)
    endif

    keyw_id = CreateBuffer("Keywords", _HIDDEN_)
    if (not keyw_id)
        Warn("Can't create 'Keywords' buffer")
        return(_FAIL)
    endif

    maincat_id = CreateBuffer("MainCat", _HIDDEN_)
    if (not maincat_id)
        Warn("Can't create 'Main Category' buffer")
        return(_FAIL)
    else
        if not LoadKeyFile(maincat_id, 0, "maincat", 0)
            AbandonFile(maincat_id)
        endif
    endif

    country_id = CreateBuffer("Country", _HIDDEN_)
    if (not country_id)
        Warn("Can't create 'Country' buffer")
        return(_FAIL)
    else
        if not LoadKeyFile(country_id, 0, "country", 0)
            AbandonFile(country_id)
        endif
    endif

    if not LoadKeywordFile()    //load file of search keywords to keyw_id
        return(_FAIL)
    endif

    GotoBufferId(curr_id)
    return(success)

end GetBuffers

/***************************************************************************
                    integer proc GetRec()
 ***************************************************************************/
integer proc GetRec()   //get recipe to work buffer
    integer id

    id = GetBufferId()
    oldlines = 0

    GotoBufferId(curr_id)
    BegLine()
    if (lFind(BEG_REC, "^ic"))
        StartRec = CurrLine()
    elseif (lFind(BEG_REC, "^ib"))
        StartRec = CurrLine()
    elseif (lFind(BEG_REC, "^i"))
        StartRec = CurrLine()
    else
        Warn("Recipe not found")
        GotoBufferId(id)
        return(_FAIL)
    endif
    if (lFind(END_REC, "^i"))
        EndRec = CurrLine()
    else
        Warn("Recipe not found")
        GotoBufferId(id)
        return(_FAIL)
    endif
    MarkLine(StartRec, EndRec)
    GotoBufferId(work_id)
    EmptyBuffer()
    CopyBlock()
    UnmarkBlock()
    oldlines = NumLines()

    GotoBufferId(id)
    return(_SUCCESS)

end GetRec

/***************************************************************************
                    integer proc AutoScan()
 create buffer (autoscan), load keywords to add to all recipes in file;
 create buffer (autoscan1), load keywords to search for in recipes- add as
 keyword only if match found.
 ***************************************************************************/
integer proc AutoScan()
    integer id, n = 0, wholeword = 0, oldwholeword, p, oldline
    string findkey[MAX_KEYWLEN] = ""
    string tempstr[MAX_KEYWLEN] = ""
    string sparam[3] = "gi"
    string oldsparam[3] = "gi"

    id = GetBufferId()
    oldline = CurrLine()
    lastrec = 0

    case (YesNo("Match whole word only?"))
        when 0, 3
            goto DONE
        when 1
            wholeword = 1
            sparam = "giw"
        when 2
            wholeword = 0
            sparam = "gi"
    endcase
    oldsparam = sparam
    oldwholeword = wholeword

    autoscan_id = CreateBuffer("AutoScan", _HIDDEN_)
    if (not autoscan_id)
        Warn("Can't create autoscan buffer")
        return(_ABORT)
    endif
    autoscan1_id = CreateBuffer("AutoScan1", _HIDDEN_)
    if (not autoscan1_id)
        Warn("Can't create autoscan buffer")
        return(_ABORT)
    endif
    LoadKeyFile(autoscan1_id, 0, "autoscan", 0)
    LoadKeyFile(autoscan_id, 0, "allrec", 0)
    LoadKeyFile(autoscan_id, 1, "alldir", 1)
    GotoBufferId(curr_id)
    LoadKeyFile(autoscan_id, 1, (SplitPath(CurrFilename(), _NAME_)), 1)

//    PopPosition()       //get old saved position
    GotoBufferId(curr_id)
    BegFile()
//    PushPosition()      //save new position
    while (not lastrec)
        if (not GetRec())                //get recipe to work buffer
            GotoBufferId(id)
            UpdateDisplay()
            return(_ABORT)
        endif
        wholeword = oldwholeword
        EmptyBuffer(newkeyw_id)
        GetRecKeys()        //get original keywords from recipe to newkeyw_id
        GetMatchKeys(autoscan1_id, newkeyw_id, wholeword)
        GotoBufferId(autoscan_id)
        BegFile()
        n = NumLines()
        while (n)
            //findkey is "-1" to cause a find on words like "blueberry"-
            //search will be for "blueberr" and will match either "blueberry"
            //or "blueberries"... this is only for keywords > 5 letters,
            //though, to avoid excessive mismatches
            sparam = oldsparam
            wholeword = oldwholeword
            findkey = GetText(1, CurrLineLen())
            p = Pos("~", findkey)
            if (p == Length(findkey))
                findkey = SubStr(findkey, 1, (Length(findkey) - 1))
                sparam = "giw"
                wholeword = 1
            endif
            tempstr = findkey       //save keyword before modifying
            p = Length(findkey)
            if ((p > 5) and (not wholeword))
                findkey = SubStr(findkey, 1, (p - 1))
            endif

//            if ((CurrLineLen() > 5) and (not wholeword))
//                findkey = GetText(1, CurrLineLen() - 1)
//            else
//                findkey = GetText(1, CurrLineLen())
//            endif
//            tempstr = GetText(1, CurrLineLen())

            GotoBufferId(newkeyw_id)        //see if it already is a key
            if (FindKeyword(findkey, wholeword))
                //returns 0 if not found, else return line# of found text
                KillLine()
            endif
            EndFile()
            AddLine(tempstr)
            GotoBufferId(autoscan_id)
            Down()
            n = (n - 1)
        endwhile
        SortKeys(newkeyw_id)
        SaveKeys()          //saves keywords in newkeyw_id to work_id recipe
        SaveRecipe(1)       //sets new EndRec
    endwhile

    DONE:
    lastrec = 0
//    PopPosition()
//    PushPosition()
    GotoBufferId(id)
    GotoLine(oldline)
    UpdateDisplay()
    return(_SUCCESS)

end AutoScan

/***************************************************************************
                    proc SortKeys()
 ***************************************************************************/
proc SortKeys(integer buffer_id)
    integer id

    id = GetBufferId()
    GotoBufferId(buffer_id)

    if (NumLines())
        MarkColumn(1,1,NumLines(), MAX_KEYWLEN)
        Sort(_IGNORE_CASE_)         //sort for display purposes
        UnmarkBlock()
        BegFile()
        while (not PosFirstNonWhite())
            KillLine()
        endwhile
    endif
    GotoBufferId(id)

end SortKeys

/***************************************************************************
                    integer proc GotoNextRec()
 ***************************************************************************/
integer proc GotoNextRec()
    integer id, oldid, oldln

    id = GetBufferId()
//    PopPosition()
    oldid = GetBufferId()
    oldln = CurrLine()
    GotoBufferId(curr_id)
    EndLine()
    if (lFind(BEG_REC, "^i"))
        if (not GetRec())
            GotoBufferId(oldid)
            GotoLine(oldln)
//            PushPosition()
            GotoBufferId(id)
            return(_ABORT)
        endif
        GotoLine(StartRec)
        ScrollToRow(1)
        UpdateDisplay()
    else
        Message("This is the last recipe")
        GotoBufferId(oldid)
        GotoLine(oldln)
//        PushPosition()
        GotoBufferId(id)
        return(_FAIL)
    endif
//    PushPosition()
    GotoBufferId(id)
    return(_SUCCESS)

end GotoNextRec

/***************************************************************************
                    integer proc GChgKey()
 ***************************************************************************/
integer proc GChgKey()
    integer id, oldline
    string  oldkey[MAX_KEYWLEN] = ""
    string  newkey[MAX_KEYWLEN] = ""
    string  tempkey[MAX_KEYWLEN] = ""

    id = GetBufferId()
    oldline = CurrLine()
    if Ask("Keyword to change: ", oldkey) and Length(oldkey)
        if Ask("New keyword: ", newkey) and Length(newkey)
            oldkey = Trim(oldkey)
            newkey = Trim(newkey)
            GotoBufferId(curr_id)
            BegFile()
            lastrec = 0
            while (not lastrec)
                if (not GetRec())                //get recipe to work buffer
                    GotoBufferId(id)
                    return(_ABORT)
                endif
                EmptyBuffer(newkeyw_id)
                GetRecKeys()  //get original keywords from recipe to newkeyw_id
                GotoBufferId(newkeyw_id)
                BegFile()
                while (lFind(oldkey, "iw"))
                    tempkey = Upper(GetText(1, CurrLineLen()))
                    if (Upper(oldkey) == tempkey)
                        KillLine()
                        if (not lFind(newkey, "giw"))
                            AddLine(newkey)
                        endif
                        goto DONEKEY
                    else
                        Right()
                    endif
                endwhile
                DONEKEY:
                SortKeys(newkeyw_id)
                SaveKeys() //saves keywords in newkeyw_id to work_id recipe
                SaveRecipe(1)       //sets new EndRec
            endwhile
        endif
    endif
//    PopPosition()
    lastrec = 0
//    PushPosition()
    GotoBufferId(id)
    GotoLine(oldline)
    UpdateDisplay()
    return(_SUCCESS)

end GChgKey

/***************************************************************************
                    integer proc GDelKey()
 ***************************************************************************/
integer proc GDelKey()
    integer id, success, oldline
    string  oldkey[MAX_KEYWLEN] = ""
    string  tempkey[MAX_KEYWLEN] = ""

    id = GetBufferId()
    oldline = CurrLine()
    if Ask("Keyword to delete: ", oldkey) and Length(oldkey)
        oldkey = Trim(oldkey)
        success = GotoBufferId(curr_id)
//Warn("GDelKey- success: ", Str(success))
        BegFile()
        lastrec = 0
        while (not lastrec)
            if (not GetRec())                //get recipe to work buffer
                GotoBufferId(id)
                return(_ABORT)
            endif
            EmptyBuffer(newkeyw_id)
            GetRecKeys()  //get original keywords from recipe to newkeyw_id
            GotoBufferId(newkeyw_id)
            BegFile()
            while (lFind(oldkey, "iw"))
                tempkey = Upper(GetText(1, CurrLineLen()))
                if (Upper(oldkey) == tempkey)
                    KillLine()
                    goto DONEKEY
                else
                    Right()
                endif
            endwhile
            DONEKEY:
            SortKeys(newkeyw_id)
            SaveKeys()          //saves keywords in newkeyw_id to work_id recipe
            SaveRecipe(1)       //sets new EndRec
        endwhile
    endif
    lastrec = 0
//    PopPosition()
//    PushPosition()
    GotoBufferId(id)
    GotoLine(oldline)
    UpdateDisplay()
    return(_SUCCESS)

end GDelKey

/***************************************************************************
                    integer proc GFixKeyCase()
 ***************************************************************************/
//integer proc GFixKeyCase()
//    integer id, n
//    string  tempkey[MAX_KEYWLEN] = ""
//
//    id = GetBufferId()
//    GotoBufferId(curr_id)
//    BegFile()
//        while (not lastrec)
//            if (not GetRec())                //get recipe to work buffer
//                GotoBufferId(id)
//                return(_ABORT)
//            endif
//            EmptyBuffer(newkeyw_id)
//            GetRecKeys()  //get original keywords from recipe to newkeyw_id
//            GotoBufferId(newkeyw_id)
//            BegFile()
//            BegLine()
//            n =  NumLines()
//            while (n)
//                if (not BegWord())
//                    WordRight()
//                endif
////                tempkey = Lower(GetText(1, CurrLineLen()))
//                MarkWord()
//                tempkey = Lower(GetMarkedText())
//                InsertText(tempkey, _OVERWRITE_)
//                BegWord()
//                UnmarkBlock()
//                Upper()
////                tempkey = Lower(GetText(1, CurrLineLen()))
////                BegLine()
////                DelToEol()
////                InsertText(tempkey, _OVERWRITE_)
////                BegLine()
////                Upper()
////                Down()
////                n = (n - 1)
//                n =  WordRight()
//            endwhile
//            SortKeys(newkeyw_id)
//            SaveKeys() //saves keywords in newkeyw_id to work_id recipe
//            SaveRecipe(1)       //sets new EndRec
//        endwhile
//    PopPosition()
//    UpdateDisplay()
//    PushPosition()
//    GotoBufferId(id)
//    return(_SUCCESS)
//
//end GFixKeyCase

/***************************************************************************
                    string proc ViewKeywid()
 ***************************************************************************/
string proc ViewKeywid()
    integer id, n, listwidth, OldX1, listret, newkeys = 0, success, p
    string  word[MAX_KEYWLEN] = ""

    id = GotoBufferId(keyw_id)
    if (not id)
        return(word)
    endif

    n = NumLines()
    listwidth = 15
    while (n)
        if ((CurrLineLen() + 15) > listwidth)
            listwidth = (CurrLineLen() + 15)
        endif
        Down()
        n = n - 1
    endwhile

    loop
        GotoBufferId(keyw_id)
        if NumLines()
            BegFile()
            OldX1 = Set(X1, (Query(ScreenCols) - listwidth))
            listret = lList("KEYWS.KEY", listwidth, NumLines(),
                      _ENABLE_SEARCH_ | _ANCHOR_SEARCH_)
            Set(X1, OldX1)
            case listret
                when listENTER
                    word = GetText(1, CurrLineLen())
                    p = Pos("~", word)
                    if (p == Length(word))
                        word = SubStr(word, 1, (Length(word) - 1))
                    endif
                    break
                when listESCAPE
                    word = ""
                    break
                when listDEL
                    word = ""
                    KillLine()
                    newkeys = 1
                when listINS
                    word = ""
                    success = AddKeyword(word, keyw_id)
                    if (success)
                        newkeys = 1
                    else
                        newkeys = 0
                    endif
            endcase
        else
            Warn("No keywords to list")
            break
        endif
    endloop
    if (newkeys)
        SaveKeywordFile()
    endif
    GotoBufferId(id)
    return(word)

end ViewKeywid

/***************************************************************************
                    string proc PickMainCat()
 select main category for recipe
 ***************************************************************************/
string proc PickMainCat()
    integer id, n, listwidth, OldX1, listret
    string  word[MAX_KEYWLEN] = ""

    id = GotoBufferId(maincat_id)
    if (not id)
        return(word)
    endif

    n = NumLines()
    listwidth = 15
    while (n)
        if (CurrLineLen() > listwidth)
            listwidth = CurrLineLen()
        endif
        Down()
        n = n - 1
    endwhile

    loop
        GotoBufferId(maincat_id)
        if NumLines()
            BegFile()
            OldX1 = Set(X1, (Query(ScreenCols) - listwidth))
            listret = lList("Main Category", listwidth, NumLines(),
                      _ENABLE_SEARCH_ | _ANCHOR_SEARCH_)
            Set(X1, OldX1)
            case listret
                when listENTER
                    word = GetText(1, CurrLineLen())
                    break
                when listESCAPE
                    word = ""
                    break
            endcase
        else
            Warn("No categories to list")
            break
        endif
    endloop
    GotoBufferId(id)
    return(word)

end

/***************************************************************************
                    string proc PickCountry()
 select country category for recipe
 ***************************************************************************/
string proc PickCountry()
    integer id, n, listwidth, OldX1, listret
    string  word[MAX_KEYWLEN] = ""

    id = GotoBufferId(country_id)
    if (not id)
        return(word)
    endif

    n = NumLines()
    listwidth = 10
    while (n)
        if (CurrLineLen() > listwidth)
            listwidth = CurrLineLen()
        endif
        Down()
        n = n - 1
    endwhile

    loop
        GotoBufferId(country_id)
        if NumLines()
            BegFile()
            OldX1 = Set(X1, (Query(ScreenCols) - listwidth))
            listret = lList("Countries", listwidth, NumLines(),
                      _ENABLE_SEARCH_ | _ANCHOR_SEARCH_)
            Set(X1, OldX1)
            case listret
                when listENTER
                    word = GetText(1, CurrLineLen())
                    break
                when listESCAPE
                    word = ""
                    break
            endcase
        else
            Warn("No countries to list")
            break
        endif
    endloop
    GotoBufferId(id)
    return(word)

end

/***************************************************************************
                    integer proc ManualKey()
 ***************************************************************************/
integer proc ManualKey()    //menu: add keys from list
    integer id, n = 0, OldX1 = 1, listret = 0, nextrec = 0, savepos = 1
    string  word[MAX_KEYWLEN] = ""

    id = GetBufferId()
    LISTIT:
    if (not GetRec())
        Warn("Can't find recipe")
        return(_ABORT)
    endif
    if (nextrec)
        GotoBufferId(curr_id)
        GotoLine(StartRec)
        ScrollToRow(1)
        UpdateDisplay()
    endif
    nextrec = 0

    EmptyBuffer(newkeyw_id)
    GetRecKeys()        //get keywords from recipe to newkeyw_id
    GetMatchKeys(keyw_id, newkeyw_id, 0)      //get keywords from keyw_id
    SortKeys(newkeyw_id)

    GotoBufferId(newkeyw_id)

    n = NumLines()
    listwidth = 10
    while (n)
        if (CurrLineLen() > listwidth)
            listwidth = CurrLineLen()
        endif
        Down()
        n = n - 1
    endwhile

    Hook(_LIST_STARTUP_, ListStartup)
    loop
        GotoBufferId(newkeyw_id)
        if NumLines()
            GotoLine(savepos)
//            BegFile()
            OldX1 = Set(X1, (Query(ScreenCols) - listwidth))
            listret = lList("Keywords", listwidth, NumLines(),
                      _ENABLE_SEARCH_ | _ANCHOR_SEARCH_)
            Set(X1, OldX1)
            savepos = CurrLine()
            case listret
                when listENTER
                    ModKeyword()
                when listCTRLENTER
                    FixKeyCase()
                when listDEL
//                    DelKeyword()
                    KillLine()
                when listINS
                    word = ""
                    AddKeyword(word, newkeyw_id)
                when listESCAPE
                    EmptyBuffer(newkeyw_id)
                    break
                when listF2
                    word = ViewKeywid()
                    if (word <> "")
                        AddKeyword(word, newkeyw_id)
                    endif
                    word = ""
                when listF7
                    word = PickCountry()
                    AddKeyword(word, newkeyw_id)
                    word = ""
                when listF8
                    word = PickMainCat()
                    AddKeyword(word, newkeyw_id)
                    word = ""
                when listF9
                    nextrec = 0
                    break
                when listF10
                    nextrec = 1
                    break
            endcase
        else
            Warn("No keywords to list")
            break
        endif
    endloop

    UnHook(ListStartup)

    if listret
        SaveKeys()
        SaveRecipe(nextrec)    //sets new EndRec, lastrec
    endif
    if ((nextrec) and (not lastrec))
        goto LISTIT
    endif

    lastrec = 0
    GotoBufferId(id)
    GotoLine(StartRec)
    ScrollToRow(1)
    UpdateDisplay()
    return(_SUCCESS)

end ManualKey

/***************************************************************************
                    integer proc SaveKeys()
 ***************************************************************************/
proc SaveKeys()         //save keywords from list to recipe
    integer n = 0, id

    id = GetBufferId()

    GotoBufferId(work_id)
    while (lFind(KEY_LINE, "^ig"))
        KillLine()
    endwhile
    if (lFind(TITLE_LINE, "^ig"))
        AddLine(KEY_LINE)
    else
        BegFile()
        AddLine()
        AddLine(TITLE_LINE)
        AddLine(KEY_LINE)
    endif
    GotoBufferId(newkeyw_id)
    BegFile()
    n = NumLines()
    while (n)
        Marked_Keyw = GetText(1, CurrLineLen())
        RecAddKey()         //routine to add keywords
        Marked_Keyw = ""
        Down()
        n = (n - 1)
    endwhile

    GotoBufferId(id)

end SaveKeys

/***************************************************************************
                    integer proc SaveRecipe(integer nextrec)
 ***************************************************************************/
integer proc SaveRecipe(integer nextrec) //save rec to orig file
    integer success = _SUCCESS, id, OldInsertLB

    id = GetBufferId()
    OldInsertLB = Set(InsertLineBlocksAbove, ON)

//    PopPosition()
    GotoBufferId(curr_id)
    GotoLine(StartRec)
    MarkLine(StartRec, EndRec)
    KillBlock()
    GotoBufferId(work_id)
    newlines = NumLines()
    BegFile()
    MarkLine()
    EndFile()
    MarkLine()
    GotoBufferId(curr_id)
    MoveBlock()
    UnmarkBlock()
    Set(InsertLineBlocksAbove, OldInsertLB)
    GotoLine(StartRec)
    Down()
    EndRec = (EndRec - oldlines + newlines)

    if (nextrec)
        if (not lFind(BEG_REC, "^i"))
            Message("Last recipe")
            lastrec = 1
            GotoLine(StartRec)
            ScrollToRow(1)
        else
            ScrollToRow(1)
        endif
    endif

//    GotoLine(StartRec)
//    ScrollToRow(1)
//    Down()
//    PushPosition()
    GotoBufferId(id)
    return(success)

end SaveRecipe

/***************************************************************************
    proc GetMatchKeys(integer src_id, integer dest_id, integer wword)
 find words in recipe that match words in src_id
 ***************************************************************************/
proc GetMatchKeys(integer src_id, integer dest_id, integer wword)
    string  findkey[MAX_KEYWLEN] = "", sparam[5] = "",
            tempstr[MAX_KEYWLEN] = "",
            tempkey1[MAX_KEYWLEN] = "",
            tempkey2[MAX_KEYWLEN] = "",
            oldsparam[3] = ""
    integer n, id, p, oldwword

    if (wword)
        sparam = "giw"
    else
        sparam = "gi"
    endif
    oldsparam = sparam
    oldwword = wword
    id = GotoBufferId(src_id)
    BegFile()
    n = NumLines()
    while (n)
        //findkey is "-1" to cause a find on words like "blueberry"-
        //search will be for "blueberr" and will match either "blueberry"
        //or "blueberries"... this is only for keywords > 5 letters,
        //though, to avoid excessive mismatches. Added: check for a '~'
        //at end of word, it will be deleted (this way you can avoid
        //deleting the last letter of the word for the search).
        //New: if word has '~' as last letter, force whole word match
        sparam = oldsparam
        wword = oldwword
        findkey = GetText(1, CurrLineLen())
        p = Pos("~", findkey)
        if (p == Length(findkey))
            findkey = SubStr(findkey, 1, (Length(findkey) - 1))
            sparam = "giw"
            wword = 1
        endif
        tempstr = findkey       //save keyword before modifying
        p = Length(findkey)
        if ((p > 5) and (not wword))
            findkey = SubStr(findkey, 1, (p - 1))
        endif

//        if ((CurrLineLen() > 5) and (not wword))
//            findkey = GetText(1, CurrLineLen() - 1)
//        else
//            findkey = GetText(1, CurrLineLen())
//        endif
//        tempstr = GetText(1, CurrLineLen())
//        p = Pos("~", tempstr)
//        if (p == Length(tempstr))
//            tempstr = SubStr(tempstr, 1, (Length(tempstr) - 1))
//        endif
//        p = Pos("~", findkey)
//        if (p == Length(findkey))
//            findkey = SubStr(findkey, 1, (Length(findkey) - 1))
//            sparam = "giw"
//        endif

        GotoBufferId(work_id)
        if (lFind(findkey, sparam))
            MarkFoundText()
            tempkey1 = GetMarkedText()
            UnmarkBlock()
            BegWord()
            tempkey2 = GetText(CurrPos(), Length(findkey))
            if (Upper(tempkey1) == Upper(tempkey2))
                GotoBufferId(dest_id)   //see if keyword already exists
                //findkeyword returns 0 if not found, else linenum
                if (FindKeyword(findkey, wword))
                    KillLine()
                endif
                EndFile()
                AddLine(tempstr)
            endif
        endif
        GotoBufferId(src_id)
        Down()
        n = (n - 1)
    endwhile

    GotoBufferId(id)
    return()

end GetMatchKeys

/***************************************************************************
                        proc GetRecKeys()
 ***************************************************************************/
proc GetRecKeys()       //get original keywords from recipe
    string  TempStr[80] = "", key[MAX_KEYWLEN] = ""
    integer kpos = 0, id

//    PushPosition()
    id = GotoBufferId(work_id)
    BegFile()
    while (lFind(KEY_LINE, "^i"))
        PushPosition()
        TempStr = Trim(GetText(10, CurrLineLen()))
        if (TempStr <> "")
            kpos = Pos(KEY_SEP, TempStr)
            while (kpos)
                kpos = Pos(KEY_SEP, TempStr)
                key = SubStr(TempStr, 1, (kpos - 1))    //get a keyword
                TempStr = Trim(SubStr(TempStr, (kpos + 1), Length(TempStr)))
                GotoBufferId(newkeyw_id)
                EndFile()
                AddLine(key)
            endwhile
            key = Trim(SubStr(TempStr, 1, Length(TempStr))) //get last key
            GotoBufferId(newkeyw_id)
            EndFile()
            AddLine(key)
        endif
        PopPosition()
        EndLine()
    endwhile

//    PopPosition()
    GotoBufferId(id)
    return()

end GetRecKeys

/***************************************************************************
                        integer proc RecAddKey()
 ***************************************************************************/
integer proc RecAddKey()        //add single keyword to recipe
    string NewKeyLine[MAX_KEYLINE] = ""
    string Newkey[MAX_KEYWLEN + Sizeof(KEY_SEP) + 1] = ""
    string templine[200] = ""

    if Marked_Keyw == ""    //nothing to add!
        Warn("ERROR! No keyword to add")
        GotoBufferId(newkeyw_id)
        Return(FALSE)
    Endif
    GoToBufferId(work_id)
    EndFile()

    if not Find(KEY_LINE, "ib")
        Warn("ERROR! Can't find keywords line")
        GotoBufferId(newkeyw_id)
        Return(FALSE)
    Endif
    MarkLine()
    templine = trim(GetMarkedText())
    if ((Upper(templine)) == (Upper(KEY_LINE)))
        UnmarkBlock()
        EndLine()
        Newkey = " " + Marked_Keyw
        InsertText(Newkey)
    else
        UnmarkBlock()
        EndLine()
        Newkey = KEY_SEP + Marked_Keyw
        InsertText(Newkey)
    endif
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
    GotoBufferId(newkeyw_id)
    Return(TRUE)
End RecAddKey

///***************************************************************************
//                        integer proc RecAddKey()
// ***************************************************************************/
//integer proc RecAddKey()
//    string NewKeyLine[MAX_KEYLINE] = ""
//    string Newkey[MAX_KEYWLEN + Sizeof(KEY_SEP) + 1] = ""
//    string templine[200] = ""
//
//    if Marked_Keyw == ""    //nothing to add!
//        Warn("ERROR! No keyword to add.")
//        Return(FALSE)
//    Endif
//    GoToBufferId(curr_id)
//    if not Find(END_REC, "i")
//        Warn("ERROR! Can't find recipe end marker.")
//        Return(FALSE)
//    Endif
//    if not Find(KEY_LINE, "ib")
//        Warn("ERROR! Can't find keywords line.")
//        Return(FALSE)
//    Endif
//    MarkLine()
//    templine = trim(GetMarkedText())
//    if ((Upper(templine)) == (Upper(KEY_LINE)))
//        UnmarkBlock()
//        EndLine()
//        Newkey = " " + Marked_Keyw
//        InsertText(Newkey)
//    Else
//        UnmarkBlock()
//        EndLine()
//        Newkey = KEY_SEP + Marked_Keyw
//        InsertText(Newkey)
//    Endif
//    if (CurrLineLen() > MAX_KEYLINE)
//        while (CurrLineLen() > MAX_KEYLINE)
//            UnmarkBlock()
//            EndLine()
//            Find(KEY_SEP, "bic")
//            MarkFoundText()
//            KillBlock()
//            Mark(_INCLUSIVE_)
//            EndLine()
//            Mark(_NONINCLUSIVE_)
//            NewKeyLine = NewKeyLine + GetMarkedText()
//            KillBlock()
//        endwhile
//        NewKeyLine = KEY_LINE + " " + NewKeyLine
//        AddLine(NewKeyLine)
//    Endif
//    BegLine()
//    Return(TRUE)
//End RecAddKey

/***************************************************************************
                    integer proc SaveKeywordFile()
 ***************************************************************************/
integer proc SaveKeywordFile()
    integer n, eof_type, level

    eof_type = Set(EOFType, _NONE_)
    level = Set(MsgLevel, _NONE_)
    n = SaveAs(keyw_fn, _OVERWRITE_)
    Set(MsgLevel, level)
    Set(EOFType, eof_type)
    return (n)
end SaveKeywordFile

/***************************************************************************
                integer proc _InsertFile(string fn)
 ***************************************************************************/
integer proc _InsertFile(string fn)
    integer level, success

    level = Set(MsgLevel, _NONE_)
    success = InsertFile(fn)
    UnmarkBlock()
    Set(MsgLevel, level)
    return (success)

end _InsertFile

/***************************************************************************
                    integer proc LoadKeyFile()
 ***************************************************************************/
integer proc LoadKeyFile(integer l_id, integer insf, string fname, integer fsrc)
    string  fpath[128] = "", f_name[12] = ""
    integer id, eof_type, success

    id = GetBufferId()
    if (fsrc)
        GotoBufferId(curr_id)
        fpath = SplitPath(CurrFilename(), _DRIVE_|_PATH_)
    else
        fpath = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_)
    endif
    GotoBufferId(l_id)
    f_name = fname + ".key"
    fpath = SearchPath(f_name, fpath)
    if (fpath == "")
        GotoBufferId(id)
        return(_FAIL)
    endif
    if (not insf)
        EmptyBuffer(l_id)
    endif
    eof_type = Set(EOFType, _NONE_)
    success = _InsertFile(fpath)
    Set(EOFType, eof_type)
    if not success
        GotoBufferId(id)
        return(_FAIL)
    else
        BegFile()
    endif

    GotoBufferId(id)
    return(_SUCCESS)

end LoadKeyFile

/***************************************************************************
                    integer proc LoadKeywordFile()
 ***************************************************************************/
integer proc LoadKeywordFile()
    string just_fn[12]
    integer success = _FAIL, eof_type, id

    id = GotoBufferId(keyw_id)

    just_fn = SplitPath(CurrMacroFileName(), _NAME_) + ".key"
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

    GotoBufferId(id)
    return (success)
end LoadKeywordFile

/***************************************************************************
                integer proc FindKeyword(string word)
 search for match in current buffer
 ***************************************************************************/
integer proc FindKeyword(string word, integer wword) //in curr buffer
    integer line = 0

    if (wword)
        line = lFind(word, "^giw")     //0 = not found
    else
        line = lFind(word, "^gi")     //0 = not found
    endif

    return(line)
end FindKeyword

/***************************************************************************
                        proc FixKeyCase()
 must enter in newkeyw_id- fix caps on keyword
 ***************************************************************************/
proc FixKeyCase()      //fix caps on keyword
    string word[MAX_KEYWLEN]

    word = GetText(1, CurrLineLen())
    word = Lower(word)
    KillLine()
    AddLine(word)
    BegLine()
    Upper()
    MarkColumn(1,1,NumLines(), MAX_KEYWLEN)
    Sort(_IGNORE_CASE_)         //sort for display purposes
    UnmarkBlock()

end FixKeyCase

/***************************************************************************
                        integer proc ModKeyword()
 must enter in newkeyw_id- modify a keyword in the list
 ***************************************************************************/
integer proc ModKeyword()      //modify a keyword in list
    integer n
    string word[MAX_KEYWLEN]

    word = GetText(1, CurrLineLen())
    n = Ask("New keyword: ", word)        //return 0 = escape pressed
    if n
        KillLine()
        word = Trim(word)
        AddLine(word)
        if (CurrLineLen() > listwidth)
            listwidth = CurrLineLen()
        endif
        MarkColumn(1,1,NumLines(), MAX_KEYWLEN)
        Sort(_IGNORE_CASE_)         //sort for display purposes
        UnmarkBlock()
        return (TRUE)
    endif
    return (FALSE)
end ModKeyword

/***************************************************************************
                        integer proc AddKeyword(kword)
 ***************************************************************************/
integer proc AddKeyword(string kword, integer keyid)  //add a keyword to list
    integer id, line, n
    string word[MAX_KEYWLEN]

    word = ''
    id = GetBufferId()
    if (kword <> "")
        n = 1
        word = kword
        goto ADDKEY
    endif

    n = Ask("Enter keyword:",word)        //return 0 = escape pressed
    ADDKEY:
    if n
        GotoBufferId(keyid)
        line = FindKeyword(word, 1)
        if line
            KillLine()
//            Warn("That keyword already exists!")
//            GotoBufferId(id)
//            Return(FALSE)
        endif
        word = Trim(word)
        InsertLine(word)
        if (CurrLineLen() > listwidth)
            listwidth = CurrLineLen()
        endif
        MarkColumn(1,1,NumLines(), MAX_KEYWLEN)
//        Sort(_IGNORE_CASE_)         //sort for display purposes
        SortKeys(keyid)
        UnmarkBlock()
        GotoBufferId(id)
        return(TRUE)
    endif
    return(FALSE)
end AddKeyword


/***************************************************************************
                integer proc lDelKeyword(integer line)
 ***************************************************************************/
//integer proc lDelKeyword(integer line)
//    integer id

//    id = GotoBufferId(newkeyw_id)

//    GotoLine(line)
//    KillLine()

//    GotoBufferId(id)

//    return (TRUE)
//end lDelKeyword

/***************************************************************************
                    integer proc DelKeyword()
 must enter with buffer to delete from = current buffer AND
 line to delete = current line
 ***************************************************************************/
//integer proc DelKeyword()
//
//    KillLine()
//
//end DelKeyword

///***************************************************************************
//                integer proc lDelKeyword(integer line)
// ***************************************************************************/
//integer proc lDelKeyword(integer line)
//    integer id
//
//    id = GotoBufferId(keyw_id)
//
//    GotoLine(line)
//    KillLine()
//    SaveKeywordFile()
//
//    GotoBufferId(id)
//
//    return (TRUE)
//end lDelKeyword
//
///***************************************************************************
//                    integer proc DelKeyword()
// ***************************************************************************/
//integer proc DelKeyword()
//
//    if YesNo("Delete "+trim(GetText(1,MAX_KEYWLEN))) == 1
//        return (lDelKeyword(CurrLine()))
//        //need to get line number to pass to lDelKeyword
//    endif
//    return (FALSE)
//end
//
//proc HelpHook()
//    BreakHookChain()
//end HelpHook

/***************************************************************************
                    integer proc ExitKeyws()
 ***************************************************************************/
integer proc ExitKeyws()
    return(_EXIT)

end

/***************************************************************************
                            proc HelpHook()
 ***************************************************************************/
proc HelpHook()
    BreakHookChain()
end HelpHook

/***************************************************************************
                            proc HelpOnListKeys()
 ***************************************************************************/
proc HelpOnListKeys()
    if Hook(_LIST_STARTUP_, HelpHook)
        QuickHelp(ListKeysHelp)
        UnHook(HelpHook)
    endif
end HelpOnListKeys

/***************************************************************************
                            proc ListStartup()
 ***************************************************************************/
proc ListStartup()
    if Enable(ListKeys)
        WindowFooter(" {F1}-Help")
        BreakHookChain()
    endif
end ListStartup

/***************************************************************************
                            proc WhenLoaded()
 ***************************************************************************/
proc WhenLoaded()
    set(Break, ON)
end WhenLoaded

/***************************************************************************
                            proc WhenPurged()
 ***************************************************************************/
proc WhenPurged()
    AbandonFile(keyw_id)
    AbandonFile(newkeyw_id)
    AbandonFile(work_id)
    AbandonFile(autoscan_id)
    AbandonFile(autoscan1_id)
    AbandonFile(maincat_id)
    AbandonFile(country_id)
end WhenPurged

menu KeywordMenu()
    title = "Keywords Menu"
    x = 2
    y = 2
//    command = NotWorking()
    "&1 Add keywords"                    , ManualKey()        , , "Add keywords from a popup picklist"
    "&2 Go to next recipe"               , GotoNextRec()      , , "Find next recipe in file"
    "&3 Autoscan"                        , AutoScan()         , , "Automatically add keywords to all recipes in file"
    "&4 Global delete keyword"           , GDelKey()          , , "Delete a keyword from all recipes in file"
    "&5 Global change keyword"           , GChgKey()          , , "Change a keyword in all recipes in file"
//    "&6 Fix caps- all keywords"          , GFixKeyCase()      , , "Fix keywords- all will have just first letter capitalized"
    ""                                  ,                    , Divide
    "&Help on menu items"                , QuickHelp(ListMenuHelp)
//    "&3 Add main keyword category"       , MainKey()          , , "Select main category for current recipe from list"
//    "&4 Add subcategory keywords"        , SubCatKeys()       , , "Add keywords based on main category"
//    "&5 Add source keyword"              , SourceKey()        , , "Select a source from a popup list"
//    "                                   ,                    , , ""
//    "                                   ,                    , , ""
    ""                                  ,                    , Divide
    "&Exit"                             , ExitKeyws()        , , "Exit from this macro"
end KeywordMenu
