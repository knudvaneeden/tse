#include ["r2qb.dat"]

//key assignment
<Ctrl F2> R2QB()

/**************************************************************************
                        proc WhenLoaded()
 ***************************************************************************/
proc WhenLoaded()
    set(Break, ON)

end

/**************************************************************************
                        proc WhenPurged()
 **************************************************************************/
proc WhenPurged()

    AbandonFile(work_id)
    AbandonFile(tag_id)
    AbandonFile(msg_id)
    AbandonFile(header_id)
    AbandonFile(skipdone_id)
    AbandonFile(words_id)
end

/***************************************************************************
 This macro formats recipes (in message files) for QBook. Planned
 enhancements include conversion of any recognized format to any other
 format. Also planned is ability to format any text file, not just message
 files.
                        integer proc Rec2QB()
 ***************************************************************************/
integer proc R2QB()

integer success = _FAIL,
        OldIndent, OldInsert, OldLMarg, OldPara, OldRemWh, OldRet, OldRMarg,
        OldWrap, OldInsLB, OldEqEnhKbd, OldMarking
string  saved_wordset[32] = ""

    OldIndent =     Set(AutoIndent, ON)
    OldInsert =     Set(Insert, ON)
    OldLMarg =      Set(LeftMargin, 0)
    OldPara =       Set(ParaEndStyle, 1)
    OldRemWh =      Set(RemoveTrailingWhite, ON)
    OldRet =        Set(ReturnEqNextLine, OFF)
    OldRMarg =      Set(RightMargin, 78)
    OldWrap =       Set(WordWrap, ON)
    OldInsLB =      Set(InsertLineBlocksAbove, OFF)
    OldEqEnhKbd =   Set(EquateEnhancedKbd, OFF)
    OldMarking =    Set(Marking, OFF)
    saved_wordset = Set(WordSet, ChrSet("0-9_A-Za-z"))

    PushBlock()
    PushPosition()
    curr_id = GetBufferId()

    case (GetDataFile())        //to buffer 'header_id'
        when _ABORT
            Warn("Error loading HDRCFG.DAT - aborting")
            success = _ABORT
            goto DONE
        when _FAIL
            Warn("HDRCFG must be run to configure message areas- aborting")
            success = _ABORT
            goto DONE
        when _MEMERR
            success = _ABORT
            goto DONE
    endcase

    case (GetExclWordList())            //get list for FixTitle()
        when _SUCCESS
            GotoBufferId(curr_id)
        otherwise
            Warn("Can't load exclude words list- continuing without")
    endcase

    work_id = CreateBuffer("Work", _HIDDEN_)
    if work_id
        GotoBufferId(curr_id)
    else
        MemError()
        success = _ABORT
        goto DONE
    endif

    msg_id = CreateBuffer("Message", _HIDDEN_)
    if msg_id
        GotoBufferId(curr_id)
    else
        MemError()
        success = _ABORT
        goto DONE
    endif

    PROCESS_MENU:
    GotoBufferId(curr_id)
    BegFile()
    ScrollToRow(1)
    UpdateDisplay()
    case ProcessRecipeMenu()
        when _NOT_WORKING, _CONTINUE, _CANCEL, _SUCCESS, _NO_HEADERS_FOUND
            goto PROCESS_MENU
        when _ABORT
            success = _ABORT
            goto DONE
        when _FAIL      //as of now, just redisplay menu
            goto PROCESS_MENU
        when _EXIT
            goto DONE
        otherwise goto PROCESS_MENU   //plan to do something else here
    endcase

    ExitFixRec()

    DONE:
    GotoBufferId(curr_id)
    PopBlock()
    PopPosition()
    Set(AutoIndent, OldIndent)
    Set(Insert, OldInsert)
    Set(LeftMargin, OldLMarg)
    Set(ParaEndStyle, OldPara)
    Set(RemoveTrailingWhite, OldRemWh)
    Set(ReturnEqNextLine, OldRet)
    Set(RightMargin, OldRMarg)
    Set(WordWrap, OldWrap)
    Set(InsertLineBlocksAbove, OldInsLB)
    Set(EquateEnhancedKbd, OldEqEnhKbd)
    Set(Marking, OldMarking)
    Set(WordSet, saved_wordset)
    if success == _ABORT
        PurgeMacro(CurrMacroFilename())
    endif
    return(success)
end

/***************************************************************************
                        integer proc ProcMsgs()
 ***************************************************************************/
integer proc ProcMsgs()
    integer success = _SUCCESS
//    integer id = 0

//    id = GetBufferId()
//    GotoBufferId(curr_id)
    BegFile()
    BegLine()

//    while ((success <> _ABORT) and (success <> _FAIL) and (not LastMsg)
//            and (success <> _NO_HEADERS_FOUND) and (success <> _CANCEL))
    while ((success == _SUCCESS) and (not LastMsg))
        success = ProcRecs()
        //only returns _FAIL if header or footer or title line not found.
        //return to main menu
    endwhile

//    GotoBufferId(id)
//    GotoBufferId(curr_id)
    return(success)
end ProcMsgs

/***************************************************************************
                        integer proc ProcRecs()
 find recipe to process- call CheckFMT
 ***************************************************************************/
integer proc ProcRecs()
    integer success = _SUCCESS
//    integer id = 0

    StartMsg = 0
    EndMsg = 0
    LastMsg = 0
//    id = GetBufferId()

//    GotoBufferId(curr_id)

    FIND_NEXT_MSG:
    GotoBufferId(curr_id)
    success = FindNextMsg() //find next message, set LastMsg if it's last one
                            //sets StartMsg to first line of header
    if (success == _SUCCESS)
        if not CheckSkipDone()  //returns 0 if marked skipped or done
            if LastMsg
//                GotoBufferId(id)
                return(success)
            endif
            goto FIND_NEXT_MSG
        else
            GetHeaderStrings()
            GotoLine(StartMsg + HLastOffset)
            AddLine(FromStr)
            AddLine(ToStr)
            AddLine()
            AddLine(SubjStr)
            AddLine()
            AddLine()
            EndMsg = (EndMsg + 6)

//Check for proper format routine (must have header, footer, and title
//lines or returns false).
            case (CheckFMT(RecFMT))
                when _DELETED
                    goto FIND_NEXT_MSG
                when _CANCEL
                    return(_CANCEL)
                when _ABORT
                    return(_ABORT)
                when _FAIL
                    ScrollToRow(1)
                    UpdateDisplay()

                    SKIP_MENU:
                    case (SkipRecipeMenu())
                        when _NOT_WORKING   //not implemented yet
                            goto SKIP_MENU
                        when _FAIL          //abort formatting (go to main menu)
//                            GotoBufferId(id)
                            return(_FAIL)
                        when _CONTINUE      //do next message, do not mark skipped
                            success = _SUCCESS
                        when _SKIP          //marked as skipped- do next message
                            success = _SUCCESS
                        when _EDIT          //not implemented yet
                            goto SKIP_MENU
                    endcase
                    goto FIND_NEXT_MSG
            endcase

//routine to do the actual formatting
            success = FormatRec()   //returns _SUCCESS, _CANCEL, _ABORT

            case (success)
                when _CANCEL, _ABORT
                    //_CANCEL) = shift escape pressed to abort formatting
                return(success)
            endcase

//this is the section that checks end of message for another recipe
            repeat
                ScrollToRow(1)
                UpdateDisplay()
                success = Check4More()  //only returns _SUCCESS, _CONTINUE
                                        //_CANCEL or _ABORT
                if ((success == _CANCEL) or (success == _ABORT))
                    return(success)
                endif
            until (success == _CONTINUE)

            goto FIND_NEXT_MSG
        endif

        goto FIND_NEXT_MSG

    elseif (success == _NO_HEADERS_FOUND)
        return(success)
    endif

//    GotoBufferId(id)
    return(success)
end

/***************************************************************************
                        integer proc FindNextMsg()
 ***************************************************************************/
integer proc FindNextMsg()
integer success = _SUCCESS
//integer id

//    id = GotoBufferId(curr_id)

    If lFind(HFirstLine, "w^")
        StartMsg = CurrLine()

        If lFind(HFirstLine, "w+^")
            EndMsg = (CurrLine() - 1)
        else
            EndFile()
            EndMsg = CurrLine()
            LastMsg = 1
        endif
    else
        success = _NO_HEADERS_FOUND
        Warn("No messages found: Function completed, or wrong format loaded")
    endif

//    GotoBufferId(id)
    return(success)
end FindNextMsg

/***************************************************************************
                        proc GetHeaderStrings()
 ***************************************************************************/
//proc GetFromString()
proc GetHeaderStrings()
    string TempStr[80] = ""

    GotoLine(StartMsg + HFromOffset)                    //to 'from' line
    FromStr = trim(GetText(HFromSPos, (HFromEPos - HFromSPos + 1)))
                                                        //get full name
    GotoLine(StartMsg + HDateOffset)                    //get date/time
    TempStr = trim(GetText(HDateSPos, (HDateEPos - HDateSPos + 1)))
    GotoLine(StartMsg + HAreaOffset)                    //get area
    TempStr = TempStr + ", Area: " +
                    (trim(GetText(HAreaSPos, (HAreaEPos - HAreaSPos + 1))))
    FromStr = "From : " + FromStr + ", " + TempStr

//proc GetSubjStr()
    GotoLine(StartMsg + HSubjOffset)                    //to 'subject' line
    SubjStr = trim(GetText(HSubjSPos, (HSubjEPos - HSubjSPos + 1)))
                                                        //get subject
    SubjStr = "Subject: " + SubjStr

//proc GetToStr()
    GotoLine(StartMsg + HToOffset)                    //to 'To:' line
    ToStr = trim(GetText(HToSPos, (HToEPos - HToSPos + 1)))
                                                        //get subject
    ToStr = "To: " + ToStr

end

/***************************************************************************
                    integer proc CheckSkipDone()
 ***************************************************************************/
integer proc CheckSkipDone()
    integer success = _FAIL
    string  SkipLine[24] = "*****RECIPE SKIPPED*****",
            EndSkipLine[28] = "*****END RECIPE SKIPPED*****",
            DoneLine[21] = "*****RECIPE DONE*****",
            EndDoneLine[25] = "*****END RECIPE DONE*****"

    MarkLine(StartMsg, EndMsg)
    GotoBlockBegin()
    BegLine()
    //skip this message if it's marked skip or done

    if (lFind(SkipLine, "lg") or lFind(DoneLine, "lg") or
        lFind(EndSkipLine, "lg") or lFind(EndDoneLine, "lg"))
        if LastMsg              //quit if it's the last message
            Warn("No more messages to process")
        endif
        GotoBlockEnd()
        success = _FAIL
    else
        GotoLine(StartMsg)
        success = _SUCCESS
    endif
    UnmarkBlock()

    return(success)
end

/***************************************************************************
                integer proc CheckFMT(var string fmt)
 checks recipe format; sets variables for various key lines.
 need to enter with StartMsg and EndMsg set
 sets StartRec, EndRec, TitleLine... failure exit if they're not set
 ***************************************************************************/
integer proc CheckFMT(var string fmt)
    string  QB_HEADER[21] = "-Begin Recipe Export-", RecHeader[21] = QB_HEADER,
            QB_FOOTER[19] = "-End Recipe Export-", RecFooter[19] = QB_FOOTER,
            CC_HEADER[14] = "    **********",
            CC_FOOTER[38] = "    *** Recipe Via Compu-Chef (tm)",
            MC_HEADER[54] = "                    *  Exported from  MasterCook II  *",
            MC_FOOTER[54] = "                   - - - - - - - - - - - - - - - - - -",
            KA_HEADER[75] = "________________________________________________________Kitchen Assistant/2",
            KA_FOOTER[12] = "____________",
//            saved_wordset[32] = "",
            TempStr[80] = ""
//set fmt (RecFMT) to "MMFmt", "CCFmt", "QBFmt", "MCFmt", "KAFmt", "or TXFmt"

    StartRec = 0
    EndRec = 0
    TitleLine = 0
    KeyLine = 0

    ServLine = 0
//    saved_wordset = Set(WordSet, ChrSet("-0-9_A-Za-z"))

    MarkLine(StartMsg, EndMsg)
    IndexLine = StartMsg
    EmptyBuffer(work_id)
    GoToBufferId(work_id)

    if not CopyBlock()              //copy whole message to work buffer
        UnmarkBlock()
//        GoToBufferId(curr_id)
        MemError()
        return(_ABORT)
    endif

    UnmarkBlock()
    GoToBufferId(curr_id)
    GoToLine(StartMsg)
    BegLine()
    MarkLine(StartMsg, EndMsg)

//check for format- gets StartRec and EndRec lines
    if lFind("Meal-Master", "ilg")
        BegLine()
        if (lFind("MMMMM", "ic^") or lFind("-----", "ic^"))
            StartRec = CurrLine()
            EndLine()
//I know this code looks a bit strange, but I had problems getting it to
//work any other way;) it's a fix for odd ingredients separator lines
//which look like: (note the space after MMMMM)
// MMMMM -----------------some_text_here==================
            NOT_END_LINE:
            if (lFind("MMMMM", "ilw^") or lFind("-----", "lw^"))
                if (CurrLineLen() <> 5)
                    EndLine()
                    goto NOT_END_LINE
                endif
                EndRec = CurrLine()
                fmt = "MMFmt"
            endif
        endif

    elseif lFind(QB_HEADER, "ilg")
        StartRec = CurrLine()
        if lFind(QB_FOOTER, "ilg")
            BegLine()
            EndRec = CurrLine()
            fmt = "QBFmt"
        endif

    elseif lFind(CC_FOOTER, "^lg")
        EndRec = CurrLine()
        GotoBlockBegin()
        BegLine()
        if lFind(CC_HEADER, "^lg")
            fmt = "CCFmt"
            StartRec = CurrLine()
        endif

    elseif lFind(MC_HEADER, "^lg")
        StartRec = CurrLine()
        BegLine()
        if lFind(MC_FOOTER, "^lg")
            EndRec = CurrLine()
            fmt = "MCFmt"
        endif

    elseif lFind(KA_HEADER, "^lg")
        StartRec = CurrLine()
        BegLine()
        if lFind(KA_FOOTER, "^lgw")
            EndRec = CurrLine()
            fmt = "KAFmt"
        endif

    else fmt = "TXFmt"
        StartRec = 0
        EndRec = 0
    endif

    UnmarkBlock()

    if not StartRec                 //must have recipe header line to continue
        lList_str = "RECIPE HEADER"
        DeleteOK = 1
        StartRec = PromptUser()     //current=work_id, returns in curr_id
        if (shift_escape == 1)
            return(_CANCEL)
        elseif (StartRec == _DELETED)
            return(_DELETED)
        elseif not StartRec
            return(_FAIL)
        endif
    endif

    if not EndRec                   //must have recipe footer line to continue
        lList_str = "RECIPE FOOTER"
        EndRec = PromptUser()
        if (shift_escape == 1)
            return(_CANCEL)
        endif
        if not EndRec
            return(_FAIL)
        endif
    endif

    GotoLine(StartRec)
    BegLine()
    MarkLine(StartRec, EndRec)

    if lFind("Title:", "ilg")       //must have title line to continue
        TitleLine = CurrLine()
    elseif fmt == "CCFmt"
        TitleLine = (StartRec + 1)
    elseif fmt == "MCFmt"
        TitleLine = (StartRec + 2)
    endif

    UnmarkBlock()

    if not TitleLine
        lList_str = "RECIPE TITLE"
        TitleLine = PromptUser()
        if (shift_escape == 1)
            return(_CANCEL)
        endif
        if not TitleLine
            return(_FAIL)
        endif
    endif

//do header and footer formatting here.......
    GotoLine(StartRec)
    BegLine()
    DelToEol()
    InsertText(RecHeader, _OVERWRITE_)

    GotoLine(EndRec)
    BegLine()
    DelToEol()
    InsertText(RecFooter, _OVERWRITE_)

    GoToLine(TitleLine)
    BegLine()
    if fmt == "CCFmt"        //get rid of all the #^&*^%@  *'s ;)
        lReplace("*", "", "cn")
        Down()
        lReplace("*", "", "cn")
        Up()
    endif

    TempStr = trim(GetText(1, CurrLineLen()))
    BegLine()
    if (lFind("subject:", "^ciw"))
        TempStr = trim(SubStr(TempStr, 9, (CurrLineLen() - 8)))
    endif
    if not lFind("Title:", "ciw")
        TempStr = "Title: " + TempStr
    else
        TempStr = Trim(SubStr(TempStr, 7, (CurrLineLen() - 6)))
        TempStr = ("Title: " + TempStr)
    endif

    BegLine()
    DelToEol()
    InsertText(TempStr, _OVERWRITE_)

    MarkLine(TitleLine, TitleLine)
    GotoLine(StartRec)
    MoveBlock()
    UnMarkBlock()
    Down()
    if (TitleLine < StartRec)
        StartRec = (StartRec - 1)
        EndRec = (EndRec + 1)
        EndMsg = (EndMsg + 1)
    endif
    TitleLine = CurrLine()

    GotoLine(StartRec)
    Down()
    if (PosFirstNonWhite())
        InsertLine()
        EndRec = (EndRec + 1)
        EndMsg = (EndMsg + 1)
        TitleLine = (TitleLine + 1)
    endif

    Return(_SUCCESS)
end


/***************************************************************************
                        integer proc FormatRec()
 check for format, try to format the recipe
 right now, this only formats to QB!!!!
 must enter with StartRec, EndRec, and TitleLine set
 ***************************************************************************/
integer proc FormatRec()
    string  QB_KEYS[9] = "Keywords:", QB_YIELD[9] = "Servings:",
            MM_KEYS[11] = "Categories:", MM_YIELD[6] = "Yield:",
            CC_KEYS[16] = "    Categories: ",
//            MC_KEYS[16] = "Categories    : ",
            KA_KEYS[9] = "Group(s):", KA_YIELD[7] = "Makes: ",
            DoneLine[21] = "*****RECIPE DONE*****",
            EndDoneLine[25] = "*****END RECIPE DONE*****",
            TempStr[80] = ""
    integer success = _SUCCESS, numnewkeys = 0, numkeys = 0, firstkey = 0,
            savepos = 0, lastkey = 0

    MarkLine(StartRec, EndRec)
    IndexLine = StartRec
    EmptyBuffer(work_id)
    GoToBufferId(work_id)
    if not CopyBlock()
        UnmarkBlock()
        MemError()
        return(_ABORT)
    endif

    UnmarkBlock()
    GoToBufferId(curr_id)
    MarkLine(StartRec, EndRec)
    GotoLine(StartRec)

    while (lFind(MM_KEYS, "il") or lFind(QB_KEYS, "il") or
        lFind(CC_KEYS, "il") or lFind(KA_KEYS, "il"))
//        or lFind(MC_KEYS, "il")
//give up on MC keywords for now
        PushBlock()
        UnmarkBlock()
//        KeyLine = CurrLine()
        if (not numkeys)        //if first time through loop
            KeyLine = TitleLine
            firstkey = KeyLine + 1
        endif
        numkeys = numkeys + 1       //number of keywords lines
        EndLine()
        Left()
        if (Chr(CurrChar())) == ","
            DelChar()
        endif
        TempStr = trim(GetText(1, CurrLineLen()))
        BegLine()
        DelToEol()
        InsertText(TempStr, _OVERWRITE_)
        BegLine()

        if not lFind("Keywords:", "c")
            if lFind("Categories:", "^ic")
                TempStr = Trim(GetText(12, (CurrLineLen() - 11)))
                TempStr = ("Keywords: " + TempStr)
                BegLine()
                DelToEol()
                InsertText(TempStr, _OVERWRITE_)
            endif
            if lFind("Group(s):", "ci")
                TempStr = Trim(GetText(10, (CurrLineLen() - 9)))
                TempStr = ("Keywords: " + TempStr)
                BegLine()
                DelToEol()
                InsertText(TempStr, _OVERWRITE_)
            endif
        endif
        MarkLine()
        MarkLine()
        GotoLine(KeyLine)
        MoveBlock()
        Down()
        KeyLine = CurrLine()
        lastkey = KeyLine
        EndLine()
        PopBlock()
    endwhile
    UnmarkBlock()

//give up on MC keywords for now
    if (not KeyLine)
        if (RecFMT <> "MCFmt")
            lList_str = "CATEGORY/KEYWORD"
            KeyLine = PromptUser()
            if (shift_escape == 1)
                return(_CANCEL)
            endif
        endif
        if (not KeyLine)
            GotoLine(TitleLine)
            AddLine("Keywords:")
            firstkey = TitleLine + 1
            EndRec = EndRec + 1
            EndMsg = EndMsg + 1
            numkeys = numkeys + 1
        else
            GotoLine(KeyLine)
            MarkLine()
            MarkLine()
            GotoLine(TitleLine)
            MoveBlock()
            UnmarkBlock()
            firstkey = TitleLine + 1
            numkeys = 1
            KeyLine = TitleLine
            Down()
            TempStr = Trim(GetText(1, CurrLineLen()))
            TempStr = ("Keywords: " + TempStr)
            BegLine()
            DelToEol()
            InsertText(TempStr, _OVERWRITE_)
        endif
        lastkey = TitleLine + 1
    endif
//    endif

//Categories: xxxxx, xxxxx, xxxxx
        if (RecFMT == "CCFmt")
            GotoLine(KeyLine)
            BegLine()
            savepos = CurrLine()
            WordRight()     //to first keyword
            while (CurrLine() == savepos)
                EndWord()   //0 if cursor char, and char to left not in WS
                InsertText(", ")    //cursor at end of string
                case (CurrChar())
                    when _AT_EOL_, _BEYOND_EOL_
                        break
                    otherwise
                        DelRightWord()
                endcase
            endwhile
            EndLine()
            BackSpace()

        endif

//    GotoLine(firstkey)
    GotoLine(lastkey)
    numnewkeys = FixKey()           //add 'E/Lastname' keyword
    numkeys = (numkeys + numnewkeys)
    GotoLine(EndRec)        //add the *****RECIPE DONE*****
    AddLine(EndDoneLine)    //and *****END RECIPE DONE***** lines
    GotoLine(StartRec)
    InsertLine(DoneLine)
    EndMsg = (EndMsg + 2)
    EndRec = (EndRec + 1)

    MarkLine(StartRec, EndRec)
    GotoLine(StartRec)
    BegLine()
    if
//        lFind("Number of Servings:", "ilg") or    //skip for now
        lFind(QB_YIELD, "ilg") or
        lFind(MM_YIELD, "ilg") or
//        lFind("Serving Size  :", "ilg") or        //skip for now
        lFind(KA_YIELD, "ilg")
        ServLine = CurrLine()
        BegLine()
        GotoPos(PosFirstNonWhite())
        MarkWord()
        TempStr = Upper(GetMarkedText())
        if ((TempStr <> "SERVINGS") and (TempStr <> "YIELD"))
            ServLine = 0
        endif
    endif
    UnmarkBlock()

    if ServLine
        if (RecFMT <> "CCFmt")      //skip CC for now
//            GoToLine(ServLine)
            TempStr = trim(GetText(1, CurrLineLen()))
            BegLine()
            DelToEol()
            InsertText(TempStr, _OVERWRITE_)
            BegLine()
            if not lFind(QB_YIELD, "ci^")
                if lFind(MM_YIELD, "ci^")
                    TempStr = Trim(GetText(7, (CurrLineLen() - 6)))
                    TempStr = ("Servings: " + TempStr)
                    BegLine()
                    DelToEol()
                    InsertText(TempStr, _OVERWRITE_)
                    BegLine()
                endif
                if lFind(KA_YIELD, "ci^")
                    TempStr = Trim(GetText(7, (CurrLineLen() - 6)))
                    TempStr = ("Servings: " + TempStr)
                    BegLine()
                    DelToEol()
                    InsertText(TempStr, _OVERWRITE_)
                    BegLine()
                endif
            endif
        endif
        MarkLine()
        MarkLine()
        GotoLine(EndRec)
        lFind("Keywords:", "^ib")
        MoveBlock()
        UnmarkBlock()
    endif

    GotoLine(StartRec)
    MarkLine(StartRec, EndRec)
    if (lFind("Servings:", "^lg"))          //add 'From:' line
        UnmarkBlock()
        AddLine(FromStr)
        FromLine = CurrLine()
        EndRec = (EndRec + 1)
        EndMsg = (EndMsg + 1)
    elseif (lFind("Keywords:", "^blg"))
        UnmarkBlock()
        AddLine(FromStr)
        FromLine = CurrLine()
        AddLine()
        EndRec = (EndRec + 2)
        EndMsg = (EndMsg + 2)
    elseif (lFind("Title:", "lg"))
        UnmarkBlock()
        AddLine(FromStr)
        FromLine = CurrLine()
        AddLine()
        EndRec = (EndRec + 2)
        EndMsg = (EndMsg + 2)
    else
        UnmarkBlock()
        GotoLine(EndRec)
        InsertLine(FromStr)
        FromLine = CurrLine()
        EndRec = (EndRec + 1)
        EndMsg = (EndMsg + 1)

    endif

    GotoLine(StartRec)
    MarkLine(StartRec, EndRec)
    if (lFind("Title:", "^lg"))
        UnmarkBlock()
        TitleLine = CurrLine()
        if (CurrLineLen() > 67)
            TempStr = Trim(GetText(7, (CurrLineLen() - 6)))
            GotoLine(StartRec)
            MarkLine(StartRec, EndRec)
            if (lFind("From:", "^lg"))
                UnmarkBlock()
                AddLine(TempStr)
            else
                GotoLine(TitleLine)
                AddLine(TempStr)
            endif
            EndRec = (EndRec + 1)
            EndMsg = (EndMsg + 1)
        endif
    else
        Warn("Can't locate title at (about) line: ",Str(CurrLine()))
        return(_ABORT)
    endif
    GotoLine(TitleLine)
    FixTitle() //fix caps on title line

    GotoLine(StartMsg)

    while CurrLine() < EndRec   //remove excess blank lines from recipe
        while PosFirstNonWhite()
            Down()
        endwhile
        Down()
        if CurrLine() >= EndRec
            break
        endif
        while (not PosFirstNonWhite())
            KillLine()
            EndRec = (EndRec - 1)
            EndMsg = (EndMsg - 1)
            if CurrLine() >= EndRec
                break
            endif
        endwhile
    endwhile
    GotoLine(EndRec)
    success = _SUCCESS
    Return(success)
end

/***************************************************************************
 Add keyword: E/contributor_lastname. Reformat keyword to correct length,
 if needed. Return the number of keyword lines added (or 0 if none). Need to
 add to numkeys.
                        integer proc FixKey()
****************************************************************************/
integer proc FixKey()
    constant MAX_KEYWLEN = 32               //maximum keyword length
    constant MAX_KEYLINE = 78               //maximum length of keyword line
    integer len = 0, xpos = 0, numnewkeys = 0
    string  NewKeyLine[MAX_KEYLINE] = "", TempStr[80] = "",
            KEY_SEP[2]    = ", ",           //keyword separator
            Newkey[MAX_KEYWLEN + Sizeof(KEY_SEP) + 1] = "",
            templine[200] = "", EKey[MAX_KEYWLEN] = "",
            KEY_LINE[9]   = "Keywords:"     //Header of keyword line

//sample 'From' line:
//From: Sherree Johansson, Fri 23 Sep 94 10:50, Area: COOKING
    len = (Length(FromStr) - 5)
    TempStr = trim(SubStr(FromStr, 6, len))
    xpos = Pos(",", TempStr)
    TempStr = SubStr(TempStr, 1, (xpos - 1))    //have whole name now

    AGAIN:
    xpos = Pos(" ", TempStr)
    if xpos
        len = (length(TempStr) - xpos)
        TempStr = SubStr(TempStr, (xpos + 1), len)
        goto AGAIN                  //hopefully this will get lastname
    endif
    EKey = "E/" + TempStr

    templine = trim(GetText(1, CurrLineLen()))
    if ((Upper(templine)) == (Upper(KEY_LINE)))
        EndLine()
        Newkey = " " + EKey
        InsertText(Newkey)
    else
        EndLine()
        Newkey = KEY_SEP + EKey
        InsertText(Newkey)
    endif

    if (CurrLineLen() > MAX_KEYLINE)
        NewKeyLine = ""
        while (CurrLineLen() > MAX_KEYLINE)
            UnmarkBlock()
            EndLine()
            Find(",", "bic")
            WordRight()
            Mark(_INCLUSIVE_)
            EndLine()
            Mark(_NONINCLUSIVE_)
            if NewKeyLine == ""
                NewKeyLine = GetMarkedText()
            else
                NewKeyLine = NewKeyLine + ", " + GetMarkedText()
            endif
            KillBlock()
            EndLine()
            Left()
            DelChar()
            BegLine()
        endwhile
        NewKeyLine = KEY_LINE + " " + NewKeyLine
        AddLine(NewKeyLine)
        numnewkeys = (numnewkeys + 1)
        EndRec = (EndRec + 1)
        EndMsg = (EndMsg + 1)
    Endif

    BegLine()
    Return(numnewkeys)
End


/***************************************************************************
 Called to check for more than on recipe in a msg...
                    integer proc Check4More()
****************************************************************************/
integer proc Check4More()
    integer success = _FAIL, saved_startmsg = StartMsg
    string  RecFMT[6] = ""

    saved_startmsg = StartMsg
    StartMsg = (EndRec + 2)         //lie about start for CheckFMT

    if (StartMsg >= (EndMsg - 1))       //skip if none/one lines past endrec
        success = _CONTINUE
        StartMsg = saved_startmsg
        return(success)
    endif

    success = CheckFMT(RecFMT)

    if (steal_tags == 1)
        StealTagline()
        steal_tags = 0
        success = CheckFMT(RecFMT)
    endif

    case (success)
        when _ABORT, _CANCEL
            return(success)
        when _FAIL, _DELETED
            StartMsg = saved_startmsg
            return(_CONTINUE)
    endcase

//    if (success == _CANCEL)
//        return(success)
//    endif

//    if (success == _FAIL)           //_FAIL means user didn't find another
//        StartMsg = saved_startmsg   //recipe header after first one
//        return(_CONTINUE)
//    endif

//    case (FormatRec())          //only returns _SUCCESS, _CANCEL as of now
//        when _CANCEL            //shift escape pressed to abort formatting
//            return(_CANCEL)
//    endcase
    success = FormatRec()

    StartMsg = saved_startmsg
    return(_SUCCESS)

end

/***************************************************************************
            integer proc PromptUser()
 this is only to be called while in work buffer
 ***************************************************************************/
integer proc PromptUser()
    integer linenum = 0, num = 0

    shift_escape = 0
    Hook(_LIST_STARTUP_, ListStartup)
    GotoBufferId(work_id)
    BegFile()

    case lList("Select Line", 80, 24, _ENABLE_HSCROLL_)
        when listENTER
            linenum = (CurrLine() + IndexLine - 1)
        when listESCAPE
            linenum = 0
        when listSHIFTESCAPE
            linenum = 0
            shift_escape = 1
        when listDEL
            if (DeleteOK)
                num = NumLines()
                GotoBufferId(curr_id)
                GotoLine(IndexLine)
                while num
                    DelLine()
                    num = (num - 1)
                endwhile
                GotoBufferId(work_id)
//                linenum = 0
                linenum = _DELETED
            else
                linenum = 0
            endif
        when listTAB
            linenum = 0
            steal_tags = 1
    endcase
    DeleteOK = 0

    UnHook(ListStartup)
    GotoBufferId(curr_id)
    Return(linenum)
end

/***************************************************************************
                integer proc StealTagline()
 ***************************************************************************/
integer proc StealTagline()
    integer id
    string tagpath[128] = ""
    string Taglines_fn[12] = "Taglines.txt"

    id = GetBufferId()
    GotoBufferId(work_id)
    tagpath = SplitPath(ExpandPath(""), _DRIVE_ | _PATH_)

    if Substr(tagpath, Length(tagpath), 1) <> "\"
        tagpath = tagpath + "\"
    endif

    tagpath = tagpath + Taglines_fn
    MarkLine()
    SaveBlock(tagpath, _APPEND_)
    UnmarkBlock()
    steal_tags = 0
    GotoBufferId(id)
    return(_SUCCESS)
end

/***************************************************************************
                        integer proc ListStartup()
 ***************************************************************************/
integer proc ListStartup()
    string TempStr[80]

    if Enable(SelectKeys, _EXCLUSIVE_)
        TempStr = "The '" + lList_str + "'line not found.    F1 = Help"
        WindowFooter(TempStr)
        BreakHookChain()

    else
        Warn("Can't load KeyDef's- aborting")
        Return(_FAIL)
    endif

    Return(_SUCCESS)
end

/***************************************************************************
                        integer proc HListStartup()
 ***************************************************************************/
integer proc HListStartup()

    if Enable(HSelectKeys, _EXCLUSIVE_ | _TYPEABLES_)
        WindowFooter("<ENTER> = Select")
        BreakHookChain()
    else
        Warn("Can't load KeyDef's- aborting")
        Return(_ABORT)
    endif

    Return(_SUCCESS)
end

/***************************************************************************
                            proc HelpHook()
 ***************************************************************************/
proc HelpHook()
    BreakHookChain()
end

/***************************************************************************
                            proc HelpOnListKeys()
 ***************************************************************************/
proc HelpOnListKeys()
    if Hook(_LIST_STARTUP_, HelpHook)
        QuickHelp(SelectHelp)
        UnHook(HelpHook)
    endif
end

/***************************************************************************
                    integer proc AbortRec()
 ***************************************************************************/
integer proc AbortRec()

    case YesNo("Abort Formatting?")
        when 1
            return(_FAIL)
        when 0, 2, 3
            return(_CONTINUE)
    endcase

    return(0)
end AbortRec

/***************************************************************************
                integer proc SkipOrDoneRec()
 ***************************************************************************/
integer proc SkipOrDoneRec()
    string  sline[80] = "*****RECIPE SKIPPED*****",
            eline[80] = "*****END RECIPE SKIPPED*****"
//            SkipLine[24] = "*****RECIPE SKIPPED*****",
//            EndSkipLine[28] = "*****END RECIPE SKIPPED*****",
//            DoneLine[21] = "*****RECIPE DONE*****",
//            EndDoneLine[25] = "*****END RECIPE DONE*****"
    integer success = _SKIP

//    if dowhat == _SKIP
//        sline = SkipLine
//        eline = EndSkipLine
//    elseif dowhat == _DONE
//        sline = DoneLine
//        eline = EndDoneLine
//    else
//        success = _FAIL
//        return(success)                   //error
//    endif

    GotoBufferId(curr_id)           //be sure we're in the right buffer
    if StartMsg
        GotoLine(StartMsg)
        AddLine(sline + " " + Str(HSubjOffset))   //add line below start of
                                    //message- incl offset to subject line
                                    //NOTE: offset doesn't include skip line
        if EndMsg
            EndMsg = (EndMsg + 1)    //account for added line
            GotoLine(EndMsg)
            AddLine(eline)          //add line after end of recipe
        endif
    else
        Warn("Can't find message start or end line- aborting")
        success = _FAIL
    endif

    return(success)
end SkipOrDoneRec

/**************************************************************************
                    integer proc GetExclWordList()
 the following creates a buffer and loads a file of exclude words for
 the "FixTitle" proc
 **************************************************************************/
integer proc GetExclWordList() //get list for FixTitle()
    integer success = _SUCCESS, id
    string  wordspath[128] = "", words_fn[128] = ""

    id = GetBufferId()

    words_id = CreateBuffer("WordList")
    if words_id == 0         //if it already exists
        words_id = GetBufferId("WordList")
    endif
    if ((words_id == 0) or (not GotoBufferId(words_id)) or (words_id == id))
        warn("'words_id' buffer error")
        GotoBufferId(id)
        WordsLoaded = _FAIL
        return(_FAIL)
    endif

    EmptyBuffer()                   //words_id
    BegFile()
    BegLine()
    wordspath = SplitPath(CurrMacroFileName(), _DRIVE_ | _PATH_)
    words_fn = SearchPath("EXCLWORD.DAT", wordspath)
    if (words_fn == '')                         //can't find exclude word file
        Warn("Can't find 'EXCLWORD.DAT'- creating default file")
        InsertData(CapsExcludeWords)            //in words_id
        SaveAs(wordspath + "EXCLWORD.DAT", _OVERWRITE_)
    else
        InsertFile(wordspath + "EXCLWORD.DAT")
    endif
    FileChanged(FALSE)
    WordsLoaded = _CAPSEXCLUDE  //variable to show which wordlist loaded (not
                                //needed yet- for future use

//    DONE:
    SetGlobalInt("WordsLoaded", WordsLoaded)
    SetGlobalInt("words_id", words_id)
    return(success)
end

/***************************************************************************
                proc FixTitle() //fix caps on title line
 ***************************************************************************/
proc FixTitle() //fix caps on title line
    integer title = 0
    string  word[40] = ""

    title = CurrLine()
    MarkLine()
    Lower()
    UnmarkBlock()
    Upper()             //upper 'T' in Title
    WordRight()
    Upper()             //capitalize first word in title
    while (WordRight() and (CurrLine() == title))
        if (MarkWord())
            word = GetMarkedText()
            UnmarkBlock()
            if (not FindWordInList(word))   //return true if word found
                case (CurrChar())
                    when _AT_EOL_, _BEYOND_EOL_
                        break
                    otherwise
                        Upper()
                endcase
            endif
        endif
    endwhile

end

/***************************************************************************
                integer FindWordInList(string word)
 find word in list loaded from file into words_id buffer
 ***************************************************************************/
integer proc FindWordInList(string word)
    integer success, id

    id = GotoBufferId(words_id)
    if (not id)
        success = _FAIL
        return(success)
    endif
//    BegFile()
//    BegLine()
    if (not WordsLoaded)
        success = _FAIL
        GotoBufferId(id)
        return(success)
    endif
    if (lFind(word, "ig"))
        success = _SUCCESS
    else
        success = _FAIL
    endif
    GotoBufferId(id)
    return(success)
end

/**************************************************************************
                    integer proc GetDataFile()
 **************************************************************************/
integer proc GetDataFile()
    constant MAX_HTAG = 20      //maximum length of header tag (type) name
    integer success = _SUCCESS, id
    string  tag[MAX_HTAG] = "",
            HeaderPath[128] = "",
            header_fn[128] = "",
            HeaderData_fn[12] = "HDRCFG.DAT"

    id = GetBufferId()
    header_id = CreateBuffer("Headers", _HIDDEN_)

    if header_id
        HeaderPath = SplitPath(CurrMacroFileName(), _DRIVE_ | _PATH_)
        Header_fn = SearchPath(HeaderData_fn, HeaderPath)
        if header_fn == ''      //can't find hdrcfg.dat
            if YesNo("Create header config file '" + HeaderData_fn + "'") == 1
                GotoBufferId(id)
                success = ExecMacro("HDRCFG")
                PurgeMacro("HDRCFG")
                if (success == _FAIL)
                    GotoBufferId(id)
                    return(success)
                else
                    HeaderPath = SplitPath(CurrMacroFileName(),
                                           _DRIVE_ | _PATH_)
                    Header_fn = SearchPath(HeaderData_fn, HeaderPath)
                    if header_fn == ''      //can't find hdrcfg.dat
                        success = _ABORT
                        return(success)
                    endif
                    GotoBufferId(header_id)
                    success = uInsertFile(Header_fn)
                    if (success == _FAIL)
                        GotoBufferId(id)
                        success = _ABORT
                        return(success)
                    endif
                endif
            else
                GotoBufferId(id)
                return(_ABORT)
            endif
        else
            success = uInsertFile(Header_fn)
            if (success == _FAIL)
                GotoBufferId(id)
                success = _ABORT
                return(success)
            endif
        endif
        BegFile()
    else
        GotoBufferId(id)
        MemError()
        return(_MEMERR)
    endif

    GotoBufferId(header_id)
    BegFile()
    BegLine()
    CurrTag = GetText(1, CurrLineLen())

    if not lFind("~~~~~~~~~~", "^w")
        Warn("Config file '", HeaderData_fn, "' is bad. Delete it and try again!")
        return(_FAIL)
    endif

    BegFile()
    while lFind("~~~~~~~~~~", "^w")
        loop
            Down()
            if lFind(CurrTag, "^c")
                Up()
                success = GetHeaderVariables()
                goto GET_TAGS
            else
                break
            endif
        endloop
    endwhile

    GET_TAGS:
    tag_id = CreateBuffer("Tags", _HIDDEN_)
    if tag_id
        GotoBufferId(header_id)
        BegFile()
        BegLine()
        BegFile()
        BegLine()
        CurrTag = GetText(1, CurrLineLen())
        while lFind("~~~~~~~~~~", "^w")
            Down()
            Tag = GetText(1, CurrLineLen())
            GotoBufferId(tag_id)
            EndFile()
            AddLine(Tag)
            GotoBufferId(header_id)
        endwhile
        GotoBufferId(curr_id)
    else
        GotoBufferId(curr_id)
        MemError()
        return(_MEMERR)
    endif

    GotoBufferId(id)
    return(success)
end

/**************************************************************************
                    integer proc GetHeaderVariables()
 enter with current line = separator line (~~~~~~~~~~) of message header
 needed for loading variables
 **************************************************************************/
integer proc GetHeaderVariables()
    integer success = _SUCCESS

    PushPosition()
    BegFile()
    BegLine()
    CurrTag =       GetText(1, CurrLineLen())
    PopPosition()
    Down()
    BegLine()
//    CurrTag =       GetText(1, CurrLineLen())
    Down()
    HFirstLine =    GetText(1, CurrLineLen())
    Down()
//    HLastLine =     GetText(1, CurrLineLen())
    Down()
    HLastOffset =   Val(GetText(1, CurrLineLen()))
    Down()
//    HAreaLine =     GetText(1, CurrLineLen())
    Down()
    HAreaOffset =   Val(GetText(1, CurrLineLen()))
    Down()
    HAreaSpos =     Val(GetText(1, CurrLineLen()))
    Down()
    HAreaEpos =     Val(GetText(1, CurrLineLen()))
    Down()
//    HFromLine =     GetText(1, CurrLineLen())
    Down()
    HFromOffset =   Val(GetText(1, CurrLineLen()))
    Down()
    HFromSpos =     Val(GetText(1, CurrLineLen()))
    Down()
    HFromEpos =     Val(GetText(1, CurrLineLen()))
    Down()
//    HToLine =       GetText(1, CurrLineLen())
    Down()
    HToOffset =     Val(GetText(1, CurrLineLen()))
    Down()
    HToSpos =       Val(GetText(1, CurrLineLen()))
    Down()
    HToEpos =       Val(GetText(1, CurrLineLen()))
    Down()
//    HSubjLine =     GetText(1, CurrLineLen())
    Down()
    HSubjOffset =   Val(GetText(1, CurrLineLen()))
    Down()
    HSubjSpos =     Val(GetText(1, CurrLineLen()))
    Down()
    HSubjEpos =     Val(GetText(1, CurrLineLen()))
    Down()
//    HDateLine =     GetText(1, CurrLineLen())
    Down()
    HDateOffset =   Val(GetText(1, CurrLineLen()))
    Down()
    HDateSpos =     Val(GetText(1, CurrLineLen()))
    Down()
    HDateEpos =     Val(GetText(1, CurrLineLen()))
//    GotoBufferId(id)
    return(success)
end


/**************************************************************************
                integer proc uSaveFile(Header_fn, how)
 **************************************************************************/
integer proc uSaveFile(string fn, integer how)
integer success = 0, eof_type, level

    eof_type = Set(EOFType, _NONE_)
    level = Set(MsgLevel, _NONE_)
    success = SaveAs(fn, how)
    Set(MsgLevel, level)
    Set(EOFType, eof_type)
    return (success)
end

/**************************************************************************
 memory error routine
                        proc MemError()
 **************************************************************************/
proc MemError()
    Warn("Insufficient Memory Error!")
    Disable(HSelectKeys)
    Disable(SelectKeys)
    return()
end

/**************************************************************************
                            proc ExitFixrec()
 **************************************************************************/
integer proc ExitFixrec()

    Disable(HSelectKeys)
    Disable(SelectKeys)
    AbandonFile(work_id)
    AbandonFile(header_id)
    AbandonFile(tag_id)
    AbandonFile(msg_id)
    AbandonFile(skipdone_id)
    AbandonFile(words_id)
    return(_EXIT)
end

/**************************************************************************
                integer proc uInsertFile(string fn)
 **************************************************************************/
integer proc uInsertFile(string fn)
integer level, success, eof_type

    eof_type = Set(EOFType, _NONE_)
    level = Set(MsgLevel, _NONE_)
    success = InsertFile(fn)
    UnmarkBlock()
    Set(MsgLevel, level)
    Set(EOFType, eof_type)
    return(success)
end

/**************************************************************************
                    integer proc NotWorking()
 **************************************************************************/
integer proc NotWorking()   //menu item not installed
    Warn("This menu item is not installed yet")
return(_NOT_WORKING)
end

/**************************************************************************
                    string proc GetTag()
 **************************************************************************/
string proc GetTag() //to update main menu 'current header type'
    return(CurrTag)
end GetTag

/**************************************************************************
                integer proc MoveRec()
 **************************************************************************/
integer proc MoveRec()
    integer success = _SUCCESS, sline = 0, eline = 0, scount = 0
    string  RecSave_fn[12] = "SAVED.QBF",
            fn[12] = "",
            RecSaveFile[128] = "",
            save_path[128] = "",
            DoneLine[21] = "*****RECIPE DONE*****",
            EndDoneLine[25] = "*****END RECIPE DONE*****"

    BegFile()
    BegLine()
    save_path = SplitPath(ExpandPath(""), _DRIVE_ | _PATH_)
    if SubStr(save_path, Length(save_path), 1) <> "\"
        save_path = (save_path + "\")
    endif

    RecSaveFile = save_path + RecSave_fn

    case YesNo("Save to default file: No = select new filename")
        when 0, 3           //escape or cancel
            return(_CANCEL)
        when 2              //no
            if (Ask("Enter Filename: ", fn) and Length(fn))
                RecSave_fn = fn
                RecSaveFile = save_path + RecSave_fn
            else
                RecSaveFile = PickFile((save_path + "*.*"))
            endif
    endcase

    if RecSaveFile == ""
        return(_CANCEL)
    endif

    MOVE:
    success = FindNextMsg()
    if (success == _NO_HEADERS_FOUND)
        goto DONE
    endif

    MarkLine(StartMsg, EndMsg)
    GotoBlockBegin()
    BegLine()

    while lFind(DoneLine, "lg")
        sline = CurrLine()
        if lFind(EndDoneLine, "lg")
            eline = CurrLine()
            UnmarkBlock()
            MarkLine((sline + 1), (eline - 1))
            if not SaveBlock(RecSaveFile, _APPEND_)
                UnmarkBlock()
                Warn("Error writing to save file- disk full?")
                return(_CANCEL)
            endif
            scount = (scount + 1)
            UnmarkBlock()
            MarkLine(sline, eline)
            KillBlock()
            EndMsg = (EndMsg - ((eline - sline) + 1))
        endif
        UnmarkBlock()
        GotoLine(StartMsg)
        MarkLine(StartMsg, EndMsg)
        BegLine()
    endwhile

    UnmarkBlock()
    GotoLine(StartMsg + 1)
    goto MOVE

    DONE:
    Warn("Done: ", Str(scount), " messages saved")
    BegFile()
    BegLine()

    success = _SUCCESS
    return(success)
end

/**************************************************************************
                    integer proc GetNewHeader()
 **************************************************************************/
integer proc GetNewHeader()
    integer success = _FAIL
//    integer id
    string  HeaderPath[128] = "",
            header_fn[128] = "",
            HeaderData_fn[12] = "HDRCFG.DAT"

//    id = GetBufferId()
    Hook(_LIST_STARTUP_, HListStartup)
    GotoBufferId(tag_id)
    BegFile()

    case lList("Select Header Type", 24, 20, _ENABLE_SEARCH_ | _ANCHOR_SEARCH_)
        when listENTER
            CurrTag = GetText(1, CurrLineLen())
            GotoBufferId(header_id)
            BegFile()
            BegLine()
            KillLine()
            InsertLine(CurrTag)

            HeaderPath = SplitPath(CurrMacroFileName(), _DRIVE_ | _PATH_)
            Header_fn = SearchPath(HeaderData_fn, HeaderPath)
            success = uSaveFile(Header_fn, _OVERWRITE_)     //save header data

            if not success
                Warn("Error writing to file '", HeaderData_fn, "'- aborting")
//                GotoBufferId(id)
                return(_ABORT)
            endif

            while lFind("~~~~~~~~~~", "^w")
                loop
                    Down()
                    if lFind(CurrTag, "^c")
                        Up()
                        success = GetHeaderVariables()
                        success = _SUCCESS
//                        GotoBufferId(id)
                        return(success)
                    else
                        break
                    endif
                endloop
            endwhile

//            GotoBufferId(id)
            return(_ABORT)
            //has to be fatal error- bad header data file- 'impossible' error
        when listESCAPE
            success = _FAIL
    endcase

    UnHook(HListStartup)
//    GotoBufferId(id)
    return(success)
end GetNewHeader

/**************************************************************************
                    integer proc AddHeader()
 **************************************************************************/
integer proc AddHeader()

    constant MAX_HTAG = 20      //maximum length of header tag (type) name
    integer success = _SUCCESS
    string  tag[MAX_HTAG] = "",
            HeaderPath[128] = "",
            header_fn[128] = "",
            HeaderData_fn[12] = "HDRCFG.DAT"

    success = ExecMacro("HDRCFG")
    PurgeMacro("HDRCFG")
    HeaderPath = SplitPath(CurrMacroFileName(), _DRIVE_ | _PATH_)
    Header_fn = SearchPath(HeaderData_fn, HeaderPath)

    if header_fn == ''      //can't find hdrcfg.dat
        Warn("Error loading '",HeaderData_fn,"'")
        return(_ABORT)
    endif

    GotoBufferId(header_id)
    EmptyBuffer()
    success = uInsertFile(Header_fn)

    if (success == _FAIL)
        Warn("Error loading '",HeaderData_fn,"'")
        return(_ABORT)
    endif

    BegFile()
    BegLine()

    if not lFind("~~~~~~~~~~", "^w")
        Warn("Config file '", HeaderData_fn, "' bad. Delete it and try again!")
        return(_ABORT)
    endif

    success = GetHeaderVariables()      //haven't added error checking to
                                        //GetHeaderVariables yet
    BegFile()
    BegLine()
    CurrTag = GetText(1, CurrLineLen())
    EmptyBuffer(tag_id)

    while lFind("~~~~~~~~~~", "^w")
        Down()
        Tag = GetText(1, CurrLineLen())
        GotoBufferId(tag_id)
        EndFile()
        AddLine(Tag)
        GotoBufferId(header_id)
    endwhile

    return(success)
end AddHeader

/**************************************************************************
                integer proc RList(integer list_type)
 Setup to call edit macro- need to have StartMsg, EndMsg, StartRec, EndRec
 set on entering.
 **************************************************************************/
integer proc RList(integer list_type)
    integer success

    SetGlobalInt("curr_id", curr_id)
    SetGlobalInt("work_id", work_id)
    SetGlobalInt("msg_id", msg_id)
    SetGlobalInt("list_type", list_type)
    SetGlobalStr("HFirstLine", HFirstLine)

//    SetGlobalInt("StartMsg", StartMsg)
//    SetGlobalInt("EndMsg", EndMsg)
//    SetGlobalInt("StartRec", StartRec)
//    SetGlobalInt("EndRec", EndRec)
//    SetGlobalInt("nextitem", nextitem)

    GotoBufferId(curr_id)
//    EmptyBuffer(msg_id)
//    MarkLine(StartMsg, EndMsg)
//    GotoBufferId(msg_id)
//    CopyBlock()
//    UnmarkBlock()
//    GotoBufferId(curr_id)
//    EmptyBuffer(work_id)
//    MarkLine(StartRec, EndRec)
//    GotoBufferId(work_id)
//    CopyBlock()
//    UnmarkBlock()
//    FileChanged(FALSE)

    success = ExecMacro("R2QLIST")
    PurgeMacro("R2QLIST")

    GotoBufferId(curr_id)
    return(success)

end

/**************************************************************************
                                Menus
 **************************************************************************/

menu SkipRecipeMenu()
    title = "Recipe Options"
    x = 55
    y = 2
    command = NotWorking()
    "Mark as &Skipped",     SkipOrDoneRec()     , ,  "Mark this message as skipped"
    "&Edit Recipe",                             , ,  "Make changes to message; retry formatting"
    "&Abort Formatting",    AbortRec()          , ,  "Abort recipe formatting"
end SkipRecipeMenu

//this menu not implemented yet
//menu SaveFileMenu()
//    title = "Save File"
//    command = NotWorking()
//    "Save to &Default File"
//    "&Prompt for Filename"
//    ""                  ,                , Divide
//    "&Abort File Save"
//end SaveFileMenu

//this menu not implemented yet
//menu SaveRecipeMenu()
//    title = "Recipe Save Options"
//    command = NotWorking()
//    "&Move to File     ",                       ,  , "Move this recipe to another file"
//    "Mark as &Completed",   SkipOrDoneRec(_DONE),  , "Mark this message as completed, keep in current file"
//    "Mark as &Skipped  ",   SkipOrDoneRec(_SKIP),  , "Mark this recipe as skipped- continue processing the next"
//    "&Edit Recipe      ",                       ,  , "Make further changes to recipe; return to this menu"
//    ""                  ,                       , Divide
//    "&Abort Formatting ",   AbortRec(),            , "Abort recipe formatting"
//end SaveRecipeMenu

menu ProcessRecipeMenu()
    title = "Main Menu"
    x = 2
    y = 1
    command = NotWorking()
    "&Convert recipes"                  , ProcMsgs()         , , "Convert recipes to QBook format"
    "&Move 'Done' recipes to file"      , MoveRec()          , , "Move recipes previously marked as 'Done' to another file"
//    "Process '&Skipped' messages"       , ListSkipDone(_SKIP), , "Re-process recipes previously marked as 'skipped'"
    "Process '&Skipped' messages"       ,                    , , "Re-process recipes previously marked as 'skipped'"
//    "Process '&Done' recipes"           , ListSkipDone(_DONE), , "Re-process recipes previously marked as 'done'"
    "Process '&Done' recipes"           , RList(_DONE)       , , "Re-process recipes previously marked as 'done'"
    "Select &Header type" [GetTag():15] , GetNewHeader()     , , "Select another message header type for processing"
    "&Add new header type"              , AddHeader()        , , "Configure a new message header type"
    ""                                  ,                    , Divide
    "&Exit"                             , ExitFixRec()       , , "Exit from this macro"
end ProcessRecipeMenu

