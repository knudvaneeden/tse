#include ["r2qlist.dat"]

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

//    AbandonFile(work_id)
//    AbandonFile(tag_id)
//    AbandonFile(msg_id)
//    AbandonFile(header_id)
//    AbandonFile(skipdone_id)
//    AbandonFile(words_id)
end

/**************************************************************************
 stuff for skipped/done list function
 **************************************************************************/
keydef ListSkipDoneKeys
    <alt e>     EndProcess(_EDIT)       // = 2
end ListSkipDoneKeys

proc ListSkipDoneHook()
    string SkipDone_message[47] = " {Enter}-View   {Escape}-Cancel   {Alt E}-Edit "
    if Enable(ListSkipDoneKeys)
        WindowFooter(SkipDone_message)
    else
        Warn("Couldn't load ListSkipDoneKeys")
    endif
end ListSkipDoneHook

proc ListRecipeHook()
    string SkipDone_message[17] = " {Escape}-Cancel "
    WindowFooter(SkipDone_message)
end ListRecipeHook

//proc EditRecipeHook()
//    string edit_message[11] = " {F1}-Help "
//    WindowFooter(edit_message)
//end EditRecipeHook

/***************************************************************************
                        proc main()
 ***************************************************************************/
proc main()

    ListSkipDone()

end

/************************************************************************
                proc ListSkipDone()
  Get recipe titles (if 'Done' list)
  or message 'Subject:' lines, (if 'skipped' list)
  Get work buffer, Build list buffer, View results, process accordingly
 ************************************************************************/
integer proc ListSkipDone()
    integer success = _SUCCESS, width, maxlen, gotovnum, list_type,
            gotolnum = 0, view_result, listindex = 1
//            list_result = 0,
//            count, startlnum, listline = 0, id

    list_type = GetGlobalInt("list_type")
    curr_id = GetGlobalInt("curr_id")
    work_id = GetGlobalInt("work_id")
    msg_id = GetGlobalInt("msg_id")
    HFirstLine = GetGlobalStr("HFirstLine")
    nextitem = 0
    SetGlobalInt("nextitem", nextitem)
    list_result = 0

    BUILD:
    GotoBufferId(curr_id)
//    success = BuildList(listindex, maxlen, width, gotovnum, list_type)
    success = BuildList(listindex, maxlen, width, list_type)
                //returns with skipdone_id current = buffer
        repeat
            nextitem = GetGlobalInt("nextitem")
            if (nextitem)
                Down()                  //to next item in list
                listindex = CurrLine()
                if (list_result == _EDIT)
                    goto EDIT
                endif
            endif
            Hook(_LIST_STARTUP_, ListSkipDoneHook)
            list_result = lList(iif(list_type == _SKIP, "Skipped Messages", "Done Recipes"),
                                maxlen + width, Query(ScreenRows),
                                _ENABLE_SEARCH_ | _ENABLE_HSCROLL_)
            UnHook(ListSkipDoneHook)    //^^^"title", width, height, flag=
            listindex = CurrLine()

            EDIT:
            if list_result == _EDIT     //edit recipe or message
                nextitem = 0
                gotovnum = (val(GetText(1, width)) - 2)   //-Beg line, if _DONE
                GotoBufferId(curr_id)
                success = GetRecFileLinenum(list_type, gotovnum)
                //returns after setting StartMsg, EndMsg, StartRec, EndRec
                success = EditRec(list_type)
                GotoBufferId(curr_id)
                GotoLine(StartMsg)
                ScrollToRow(1)
                UpdateDisplay()
//                GotoBufferId(skipdone_id)
                goto BUILD
            elseif list_result          //exited via <Enter>
                nextitem = 0
                gotovnum = (val(GetText(1, width)) - 2)
                GotoBufferId(curr_id)
                success = GetRecFileLinenum(list_type, gotovnum)
                //returns after setting StartMsg, EndMsg, StartRec, EndRec
                if ((success == _FAIL) or (success == _ABORT))
                    PopPosition()
//                    GotoBufferId(id)
                    return(_ABORT)
                endif
                EmptyBuffer(work_id)
                MarkLine(StartRec, EndRec)
                GotoBufferId(work_id)
                CopyBlock()
                UnmarkBlock()
                Hook(_LIST_STARTUP_, ListRecipeHook)
                view_result = lList(iif(list_type == _SKIP, "Messages", "Recipe"),
                                    80, Query(ScreenRows),
                                    _ENABLE_SEARCH_ | _ENABLE_HSCROLL_)
                UnHook(ListRecipeHook)    //^^^"title", width, height, flag=
                GotoBufferId(curr_id)
            endif
            GotoBufferId(skipdone_id)
        until (not list_result)

//    GotoBufferId(id)
    if gotolnum == 0
        PopPosition()
    else
        KillPosition()
        GotoLine(gotolnum)
        BegLine()
        ScrollToRow(1)
    endif

    AbandonFile(skipdone_id)
//    GotoBufferId(id)
    return(_SUCCESS)
end ListSkipDone

/****************************************************************************
                integer proc BuildList(integer listindex)
 list_type _DONE = done recipes, _SKIP = skipped messages
 ****************************************************************************/
//integer proc BuildList(integer listindex, var integer maxlen, var integer width, var integer gotovnum, var integer list_type)
integer proc BuildList(integer listindex, var integer maxlen, var integer width, var integer list_type)
    string listtext[60],
    SkipDone_message[47] = " {Enter}-View   {Escape}-Cancel   {Alt E}-Edit ",
    SkipLine[24] = "*****RECIPE SKIPPED*****",
    DoneLine[21] = "*****RECIPE DONE*****"
    integer id, count, listline = 0, success = _SUCCESS
//    gotolnum = 0, startlnum,
//            view_result

    id = GetBufferId()

    skipdone_id = CreateBuffer("SkipDone")
    if skipdone_id == 0         //if it already exists
        skipdone_id = GetBufferId("SkipDone")
    endif
    if skipdone_id == id
        warn("Can't use this buffer")
        GotoBufferId(id)
        return(_FAIL)
    endif
    if ((skipdone_id == 0) or (not GotoBufferId(skipdone_id)))
        GotoBufferId(id)
        return(_FAIL)
    endif

    GotoBufferId(curr_id)
    EmptyBuffer(skipdone_id)
    maxlen = (Length(SkipDone_message) - 6)   //windowfooter message - 6
    width = Length(Str(NumLines()))
//    listtext = ''
    if list_type == _DONE
        listtext = DoneLine
    else
        listtext = SkipLine
    endif

//    startlnum = CurrLine()
    PushPosition()
    BegFile()

    if not lFind(listtext, '^g')    //start at beg file
        Warn(listtext, " not found.")
        PopPosition()
        GotoBufferId(id)
        return(_FAIL)
    else
    //if looking for SkipLine, it's at StartMsg + 1
    //if looking for DoneLine, it's at StartRec - 1
        count = 0
        repeat
            count = count + 1
            listline = GetListLinenum(list_type)    //ret title or subj line#
            if (listline == _FAIL)
                break
            endif
            if not AddLine(Format(CurrLine():width, ': ', GetText(1, 100)),
                           skipdone_id)
                break
            endif
            if CurrLineLen() > maxlen
                maxlen = CurrLineLen() + 2
            endif
//            if gotolnum == 0 and CurrLine() >= startlnum
//                gotolnum = count - (CurrLine() > startlnum)
//                gotolnum = count
//            endif
        until (not lFind(listtext, '^'))

        GotoBufferId(skipdone_id)
//        GotoLine(iif(gotolnum, gotolnum, count))
        GotoLine(listindex)
    endif
    return(success)
end BuildList

/****************************************************************************
                integer proc GetListLinenum(integer list_type)
 list_type _DONE = done recipes, _SKIP = skipped messages
 ****************************************************************************/
integer proc GetListLinenum(integer list_type)
    integer subjoffset, listline, titleoffset = 3

    PushPosition()
    BegLine()
    StartMsg = lFind(HFirstLine, "^b")  //search back (from 'skip'
    if (not StartMsg)                   //or 'done' line
//        Warn("Can't find message header- wrong format loaded?")
//        PopPosition()
//        return(_ABORT)
        return(_FAIL)
    endif
    PopPosition()

    if (list_type == _SKIP)                  //working on a skipped message
        GotoPos(PosLastNonWhite())
        MarkWord()
        subjoffset = (Val(GetMarkedText()))
        listline = CurrLine() + subjoffset
    else
        listline = CurrLine() + titleoffset

    endif

    GotoLine(listline)
    return(listline)

end GetListLinenum

/****************************************************************************
   integer proc GetRecFileLinenum(integer list_type, integer linenum)
 list_type 0 = done recipes, 1 = skipped messages
 ****************************************************************************/
integer proc GetRecFileLinenum(integer list_type, integer linenum)
    integer success = _SUCCESS, id
    string  EndDoneLine[25] = "*****END RECIPE DONE*****"
//            SkipLine[24] = "*****RECIPE SKIPPED*****",
//            EndSkipLine[28] = "*****END RECIPE SKIPPED*****",
//            DoneLine[21] = "*****RECIPE DONE*****",

    PushPosition()

    id = GotoBufferId(curr_id)
    GotoLine(linenum)               //passed var is linenum (= StartRec)
    BegLine()                       //if _DONE, (subj: line) if _SKIP
    case (lFind(HFirstLine, "^b"))
        when _FAIL
            Warn("Can't find message header- wrong format loaded?")
            GotoBufferId(id)
            PopPosition()
            return(_ABORT)
        when _SUCCESS
            StartMsg = CurrLine()
    endcase

    EndMsg = lFind(HFirstLine, "^+")
    if (EndMsg)
        EndMsg = (CurrLine() - 1)
    else
        EndMsg = NumLines()     //end of file
    endif
    if (list_type == _DONE)              //working on a 'done' recipe
        GotoLine(linenum)
        StartRec = CurrLine()
        MarkLine(StartMsg, EndMsg)
        EndRec = lFind(EndDoneLine, "^l")
        UnmarkBlock()
        if (not EndRec)
            Warn("'Done' recipe not found- aborting")
            GotoBufferId(id)
            PopPosition()
            return(_ABORT)
        endif
        EndRec = (CurrLine() - 1)
    else                                 //working on a 'skipped' message
        StartRec = StartMsg
        EndRec = EndMsg
    endif
    SetGlobalInt("StartMsg", StartMsg)
    SetGlobalInt("EndMsg", EndMsg)
    SetGlobalInt("StartRec", StartRec)
    SetGlobalInt("EndRec", EndRec)

    GotoBufferId(id)
    PopPosition()
    return(success)

end GetRecFileLinenum

/**************************************************************************
                integer proc EditRec(integer etype)
 Setup to call edit macro- need to have StartMsg, EndMsg, StartRec, EndRec
 set on entering.
 **************************************************************************/
integer proc EditRec(integer etype)
    integer id, success

    SetGlobalInt("StartMsg", StartMsg)
    SetGlobalInt("EndMsg", EndMsg)
    SetGlobalInt("StartRec", StartRec)
    SetGlobalInt("EndRec", EndRec)
    SetGlobalInt("work_id", work_id)
    SetGlobalInt("msg_id", msg_id)
    SetGlobalInt("curr_id", curr_id)
    SetGlobalInt("etype", etype)
    SetGlobalInt("nextitem", nextitem)
    id = GotoBufferId(curr_id)

    EmptyBuffer(msg_id)
    MarkLine(StartMsg, EndMsg)
    GotoBufferId(msg_id)
    CopyBlock()
    UnmarkBlock()
    GotoBufferId(curr_id)
    EmptyBuffer(work_id)
    MarkLine(StartRec, EndRec)
    GotoBufferId(work_id)
    CopyBlock()
    UnmarkBlock()
    FileChanged(FALSE)

    success = ExecMacro("R2QEDIT")
    PurgeMacro("R2QEDIT")
    if (success)
        //if didn't save data in edit, then save it here
    endif

    GotoBufferId(id)
    return(success)

end

