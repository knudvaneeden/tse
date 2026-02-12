//for edit function
forward         menu    EFileMenu()
forward         menu    ERecipeMenu()
forward         menu    EMessageMenu()
forward         menu    EOtherMenu()
forward         keydef  REditKeys
//forward         keydef  REditSkipKeys
forward         keydef  NotesLineKeys
forward         helpdef REditHelp
forward integer proc    R2QEDIT()
forward integer proc    QBTemplate()
forward integer proc    TMoveIngred()
forward integer proc    TMoveDirect()
forward integer proc    NotesLine()
forward integer proc    RAddIngred()
forward integer proc    RAddDirect()
forward integer proc    SourceFmt()
forward integer proc    NotWorking()
forward integer proc    ExitEdit()      //normal exit function
forward integer proc    ExitEditNext()  //<Alt N> exit function
forward         proc    HelpOnREditKeys()

constant _ABORT = -1
constant _FAIL = 0
constant _SUCCESS = 1
constant _SKIP = 6
constant _DONE = 7
constant _NOT_WORKING = 5  //function not implemented yet
constant _EXIT = 99
constant _NEXT = 2
constant _CAPSEXCLUDE = 1
constant _KEYLIST = 2

integer StartMsg, EndMsg, StartRec, EndRec, msg_id, work_id, curr_id, etype,
        oldlines, nextitem, OldInsLineBlocks
//integer changed, words_id, WordsLoaded

/***************************************************************************
                                WhenLoaded()
 ***************************************************************************/
proc WhenLoaded()
    Set(Break, ON)
end

/***************************************************************************
                                WhenPurged()
 ***************************************************************************/
proc WhenPurged()

end

/***************************************************************************
                        proc main()
 ***************************************************************************/
proc main()

    r2qedit()

end

/***************************************************************************
                    public integer proc R2QEDIT()
 enter with valid StartMsg and EndMsg set, StartRec & EndRec (if working on
 'Done' recipes); etype _SKIP=Skipped, _DONE=Done
 ***************************************************************************/
integer proc R2QEDIT()  //Edit recipe or message
    integer success = _SUCCESS, id, OldMarking, OldRightMargin

    StartMsg = GetGlobalInt("StartMsg")
    EndMsg = GetGlobalInt("EndMsg")
    StartRec = GetGlobalInt("StartRec")
    EndRec = GetGlobalInt("EndRec")
    work_id = GetGlobalInt("work_id")
    msg_id = GetGlobalInt("msg_id")
    curr_id = GetGlobalInt("curr_id")
    etype = GetGlobalInt("etype")
    nextitem = GetGlobalInt("nextitem")

    id = GetBufferId()
    OldMarking = Set(Marking, OFF)
    OldInsLineBlocks = Set(InsertLineBlocksAbove, OFF)
    OldRightMargin = Set(RightMargin, 74)
    PushPosition()
    PushBlock()

    GotoBufferId(work_id)
    oldlines = NumLines()       //number of lines in orig. msg/recipe
    FileChanged(FALSE)

    if Enable(REditKeys, _EXCLUSIVE_ | _TYPEABLES_)
        success = Process()
        Disable(REditKeys)
    else
        Warn("Can't load keydef's- aborting!")
    endif

    case success
        when _EXIT              //exited edit process normally
        when _FAIL              //aborted edit- no changes saved
        when _ABORT             //error abort process- no changes saved
        when _NEXT              //edit next item
    endcase

//    SetGlobalInt("nextitem", nextitem)
    GotoBufferId(id)
    Set(Marking, OldMarking)
    Set(InsertLineBlocksAbove, OldInsLineBlocks)
    Set(RightMargin, OldRightMargin)
    PopPosition()
    PopBlock()

    return(success)
end

/***************************************************************************
                        integer proc SaveChanges()
 ***************************************************************************/
integer proc SaveChanges()  //to message or recipe
    integer success = _SUCCESS, newlines = 0, id

    id = GotoBufferId(work_id)
    BegFile()
    UpdateDisplay()
    ScrollToRow(1)
    if (FileChanged())
        GotoBufferId(curr_id)
        if (etype == _SKIP)
            MarkLine(StartMsg, EndMsg)
            GotoBlockBegin()    //CurLine=line after deleted
            KillBlock()
            Up()
            BegLine()
            GotoBufferId(work_id)
            BegFile()
            newlines = NumLines()
            MarkLine(CurrLine(), newlines)
            GotoBufferId(curr_id)
            CopyBlock()
            UnmarkBlock()
            Down()
            StartMsg = CurrLine()
            EndMsg = (StartMsg + newlines - 1)
        elseif (etype == _DONE)
            MarkLine(StartRec, EndRec)
            GotoBlockBegin()    //CurLine=line after deleted
            KillBlock()
            Up()
            BegLine()
            GotoBufferId(work_id)
            BegFile()
            newlines = NumLines()
            MarkLine(CurrLine(), newlines)
            GotoBufferId(curr_id)
            CopyBlock()
            UnmarkBlock()
            Down()
            StartRec = CurrLine()
            EndRec = (StartRec + newlines - 1)
            EndMsg = (EndMsg - oldlines + newlines)
        endif
        GotoBufferId(work_id)
        FileChanged(FALSE)
    endif
    GotoBufferId(id)
    SetGlobalInt("EndRec", EndRec)
    SetGlobalInt("EndMsg", EndMsg)

    return(success)
end

/***************************************************************************
                integer proc ExitEdit()
 exittype = _EXIT, normal exit. If _NEXT (alt-n), edit next item.
 ***************************************************************************/
integer proc ExitEdit()  //file menu exit function

    GotoBufferId(work_id)
    BegFile()
    UpdateDisplay()
    ScrollToRow(1)
    if (FileChanged())
        case (YesNo("Save Changes?"))
            when 0, 3           //escape or cancel
            when 2              //no
            when 1              //yes
                SaveChanges()
        endcase
    endif

    nextitem = 0
    SetGlobalInt("nextitem", nextitem)

    EndProcess(_EXIT)
    return(_EXIT)
end

/***************************************************************************
                integer proc ExitEditNext()
 exittype = _NEXT (alt-n), edit next item.
 ***************************************************************************/
integer proc ExitEditNext()  //<Alt N> exit function

    GotoBufferId(work_id)
    BegFile()
    UpdateDisplay()
    ScrollToRow(1)
    if (FileChanged())
        case (YesNo("Save Changes?"))
            when 0, 3           //escape or cancel
            when 2              //no
            when 1              //yes
                SaveChanges()
        endcase
    endif

    nextitem = 1
    SetGlobalInt("nextitem", nextitem)
    EndProcess(_NEXT)
    return(_NEXT)
end

/***************************************************************************
 Edit Recipe functions (to assign to keys)
 All functions assume work_id contains recipe to work on;
 msg_id contains original message.
 ***************************************************************************/

/***************************************************************************
        integer proc NotesLine()    //add line(s) from orig msg to recipe
 ***************************************************************************/
integer proc NotesLine()    //add line(s) from orig msg to recipe
integer success = _FAIL, id, movelines = 0, notelines = 0,
        begblock, endblock, begnotes, endnotes, firstmoveline = 0,
        OldParaEndStyle, OldWordWrap, OldAutoIndent, OldLeftMargin,
        OldRightMargin
string TempStr[80]

    if (etype == _SKIP)
        Warn("Add Notes only works for recipes marked 'Done'")
        goto ABORT
    endif
    OldParaEndStyle = Set(ParaEndStyle, 1)
    OldAutoIndent = Set(AutoIndent, OFF)
    OldLeftMargin = Set(LeftMargin, 0)
    OldRightMargin = Set(RightMargin, 74)
    OldWordWrap = Set(WordWrap, OFF)

    id = GotoBufferId(msg_id)
    if (Enable(NotesLineKeys, _EXCLUSIVE_))
        Message("<Alt L> = Mark line(s) to move- <Escape> = abort, <Enter> = done")
        success = Process()
        Disable(NotesLineKeys)
    endif

    if (not success)
        GotoBufferId(msg_id)
        UnmarkBlock()
        GotoBufferId(id)
        goto DONE
    endif

    if isBlockMarked()          //user marked block of lines to move
        GotoBlockEnd()
        endblock = CurrLine()
        GotoBlockBegin()
        begblock = CurrLine()
    else                        //or just move current line
        begblock = CurrLine()
        endblock = begblock
        movelines = 1
    endif

    movelines = ((endblock - begblock) + 1) //number of lines to move
    notelines = movelines                   //number of notes lines to add
    UnmarkBlock()

    GotoBufferId(work_id)
    BegFile()
    MarkLine()
    EndFile()
    MarkLine()
    if not lFind("Contributor's NOTES:", "^lgb")
        UnmarkBlock()
        BegLine()
        InsertLine()        //add 2 blank lines and NOTES: line
        InsertLine()        //so we'll have a blank line before and after
        AddLine("Contributor's NOTES:")
        begnotes = CurrLine()
    else
        begnotes = CurrLine()
        while PosFirstNonWhite()        //while not a blank line
            Down()
            if (CurrLine() == NumLines())   //if not there, add blank line to
                InsertLine()            //end of notes line(s)
                break
            endif
        endwhile
        Up()
        endnotes = CurrLine()
    endif

    GotoBufferId(msg_id)
    GotoLine(begblock)
    firstmoveline = 1

    while movelines
        MarkLine(CurrLine(), CurrLine())
        GotoBufferId(work_id)
        MoveBlock()
        UnmarkBlock()
        Down()
        if (firstmoveline)
            BegLine()
            TempStr = Trim(GetText(1, CurrLineLen()))
            TempStr = "    " + TempStr  //indent the first line of moved block
            KillLine()
            InsertLine(TempStr)
            firstmoveline = 0
        elseif (PosFirstNonWhite())     //if it's not a blank line
            BegLine()                   //put at column 1
            TempStr = Trim(GetText(1, CurrLineLen()))
            KillLine()
            InsertLine(TempStr)
        endif
        endnotes = CurrLine()
        GotoBufferId(msg_id)
        movelines = (movelines - 1)
    endwhile

    GotoLine(begnotes)
    while (CurrLine() <= endnotes)  //remove all blank lines from notes
        while (PosFirstNonWhite())  //while not a blank line
            Down()                  //goto next line
        endwhile
        while (not PosFirstNonWhite())  //while 'blank line found'
            KillLine()                  //kill it
            endnotes = (endnotes - 1)
            if (CurrLine() == EndRec)
                InsertLine()            //killed one too many
                Down()                  //back to EndRec line
                endnotes = (endnotes + 1)
                break
            endif
            if ((CurrLine() <> NumLines()) and PosFirstNonWhite())
                //if not at end of recipe and not on a blank line
                TempStr = Trim(GetText(1, CurrLineLen()))
                TempStr = "    " + TempStr  //indent the first line of paragraph
                KillLine()
                InsertLine(TempStr)
                Down()
            endif
        endwhile
    endwhile
    GotoLine(begnotes)
    Down()
    Set(WordWrap, ON)
    while (CurrLine() <> NumLines())
        WrapPara()
    endwhile
    success = _SUCCESS

    DONE:
    GotoBufferId(id)
    UpdateDisplay()
    Set(ParaEndStyle, OldParaEndStyle)
    Set(AutoIndent, OldAutoIndent)
    Set(LeftMargin, OldLeftMargin)
    Set(RightMargin, OldRightMargin)
    Set(WordWrap, OldWordWrap)
    return(success)
    ABORT:
    success = _FAIL
    return(success)
end

/***************************************************************************
                        integer proc SourceFmt()
 format 'source:' line(s); enter with lines marked. If not marked, will
 just assume current line.
 ***************************************************************************/
integer proc SourceFmt()    //format 'source:' line(s)
    integer success = _SUCCESS

    if (etype == _SKIP)
        Warn("Source Format only works for recipes marked 'Done'")
        goto ABORT
    endif

//    id = GetBufferId()
//    GotoBufferId(work_id)
//    if (isBlockMarked() and isBlockInCurrFile())
//        GotoBlockBegin()
//    endif

//    changed = 1
//    GotoBufferId(id)
    return(success)
    ABORT:
    return(_FAIL)
end

/***************************************************************************
                        integer proc YieldFmt()
 format 'yield:' line(s); enter with lines marked. If not marked, will
 just assume current line.
 ***************************************************************************/
integer proc YieldFmt() //format yield/servings line
    string  QB_YIELD[9] = "Servings:",
            MM_YIELD[6] = "Yield:",
            KA_YIELD[6] = "Makes:",
//MC_YIELD format = "Serving Size  :  0   Preparation Time :0:00"
            MC_YIELD[15] = "Serving Size  :",
            CC_YIELD[19] = "Number of Servings:",
            TempStr[80] = ""
    integer success = _SUCCESS, id, servline = 0, yieldpos = 0

    if (etype == _SKIP)
        Warn("Yield Format only works for recipes marked 'Done'")
        goto ABORT
    endif

    id = GoToBufferId(work_id)
    BegFile()
    BegLine()

    if (lFind(CC_YIELD, "ig"))                  //"Number of Servings:"
        yieldpos = CurrPos()
        TempStr = GetText(yieldpos, (CurrLineLen() - yieldpos + 1))
        KillToEol()
        BegLine()
        AddLine(TempStr)
        BegLine()
        DelRightWord()
        DelRightWord()
        servline = CurrLine()
    elseif (lFind(QB_YIELD, "ig"))                  //"Servings:"
        servline = CurrLine()
        TempStr = trim(GetText(1, CurrLineLen()))
        BegLine()
        DelToEol()
        InsertText(TempStr, _OVERWRITE_)
    elseif (lFind(MM_YIELD, "ig"))                  //"Yield:"
        servline = CurrLine()
        TempStr = trim(GetText(1, CurrLineLen()))
        BegLine()
        DelToEol()
        InsertText(TempStr, _OVERWRITE_)
        BegLine()
        DelRightWord()
        DelChar()
        InsertText(QB_YIELD, _INSERT_)
    elseif (lFind(MC_YIELD, "ig"))                  //"Serving Size  :"
        servline = CurrLine()
        TempStr = trim(GetText(1, CurrLineLen()))
        BegLine()
        DelToEol()
        InsertText(TempStr, _OVERWRITE_)
        BegLine()
        DelRightWord()
        DelRightWord()
        DelChar()
        InsertText(QB_YIELD, _INSERT_)
    elseif (lFind(KA_YIELD, "ig"))                  //"Makes:"
        servline = CurrLine()
        TempStr = trim(GetText(1, CurrLineLen()))
        BegLine()
        DelToEol()
        InsertText(TempStr, _OVERWRITE_)
        BegLine()
        DelRightWord()
        DelChar()
        InsertText(QB_YIELD, _INSERT_)
    else
        if (Enable(NotesLineKeys, _EXCLUSIVE_))
            Message("Place cursor on Yield/Servings line- <Escape> = abort, <Enter> = done")
            success = Process()
            Disable(NotesLineKeys)
        else
            Warn("Couldn't load keydef's- aborting")
            goto ABORT
        endif
        if (success)
            if isBlockMarked()          //user marked line
                GotoBlockBegin()
            endif
            UnmarkBlock()
            servline = CurrLine()
            TempStr = trim(GetText(1, CurrLineLen()))
            BegLine()
            DelToEol()
            InsertText(TempStr, _OVERWRITE_)
            BegLine()
            InsertText(QB_YIELD, _INSERT_)
        endif
        UnmarkBlock()               //in case user marked block, then esc
    endif

    if (not servline)
        //code to add blank "Servings:" line
        if (lFind("Keywords:", "^gb"))
            AddLine("Servings:")
        elseif (lFind("Title:", "^g"))
            AddLine()
            AddLine("Servings:")
        endif
    else
        MarkLine(servline, servline)
        TempStr = GetMarkedText()
        if (lFind("Keywords:", "^gb"))
            AddLine(TempStr)
            KillBlock()
        elseif (lFind("Title:", "^g"))
            AddLine()
            AddLine(TempStr)
            KillBlock()
        else
            UnmarkBlock()
        endif
    endif

    GotoBufferId(id)
    return(success)
    ABORT:
    return(_FAIL)
end

/***************************************************************************
                        integer proc QBTemplate()
 insert a recipe template at start of msg
 ***************************************************************************/
integer proc QBTemplate()  //insert a recipe template at start of msg
    integer success = _SUCCESS

    if (etype == _DONE)
        Warn("Add Template only works for recipes marked 'Skipped'")
        goto ABORT
    endif

    return(success)
    ABORT:
    return(_FAIL)
end

/***************************************************************************
                    integer proc    RAddIngred()
 ***************************************************************************/
integer proc RAddIngred()   //add 'Ingredients:' line
integer success = _SUCCESS, id

    id = GotoBufferId(work_id)
    if (Enable(NotesLineKeys, _EXCLUSIVE_))
        Message("Place cursor on first line of Ingredients- <Escape> = abort, <Enter> = done")
        success = Process()
        Disable(NotesLineKeys)
    endif

    if (not success)
        UnmarkBlock()
        GotoBufferId(id)
        goto DONE
    endif

    if isBlockMarked()          //user marked line
        GotoBlockBegin()
    endif
    UnmarkBlock()

    BegLine()
    InsertLine("INGREDIENTS:")

    DONE:
    GotoBufferId(id)
    UpdateDisplay()
    return(success)
end

/***************************************************************************
                    integer proc    RAddDirect()
 ***************************************************************************/
integer proc RAddDirect()   //add 'Directions:' line
integer success = _SUCCESS, id

    id = GotoBufferId(work_id)
    if (Enable(NotesLineKeys, _EXCLUSIVE_))
        Message("Place cursor on first line of Directions- <Escape> = abort, <Enter> = done")
        success = Process()
        Disable(NotesLineKeys)
    endif

    if (not success)
        UnmarkBlock()
        GotoBufferId(id)
        goto DONE
    endif

    if isBlockMarked()          //user marked line
        GotoBlockBegin()
    endif
    UnmarkBlock()

    BegLine()
    InsertLine("DIRECTIONS:")

    DONE:
    GotoBufferId(id)
    UpdateDisplay()
    return(success)
end

/***************************************************************************
                        integer proc TMoveIngred()
 move line/marked block to 'template Ingredients'
 ***************************************************************************/
integer proc TMoveIngred()  //move ingredients line(s) to template
    integer success = _SUCCESS

    if (etype == _DONE)
        Warn("Move Ingredients only works for recipes marked 'Skipped'")
        goto ABORT
    endif

    return(success)
    ABORT:
    return(_FAIL)
end

/***************************************************************************
                        integer proc TMoveDirect()
 ***************************************************************************/
integer proc TMoveDirect()  //move directions line(s) to template
    integer success = _SUCCESS

    if (etype == _DONE)
        Warn("Move Directions only works for messages marked 'Skipped'")
        goto ABORT
    endif

    return(success)
    ABORT:
    return(_FAIL)
end

/**************************************************************************
                    integer proc NotWorking()
 **************************************************************************/
integer proc NotWorking()
    Warn("This menu item is not installed yet")
return(_NOT_WORKING)
end

/**************************************************************************
                        proc HelpOnEditKeys()
 **************************************************************************/
proc HelpOnREditKeys()
    BreakHookChain()
    QuickHelp(REditHelp)
end

helpdef REditHelp
    title       = "  Recipe/Message Edit Help- PgUp/PgDn to view  "
 "This is a preliminary help listing, still under construction!     "
 ""
 "Following is a list of functions available from within the Recipe "
 "Edit function. Some of them are not installed yet. Selecting an   "
 "uninstalled function won't hurt anything... it just won't work!   "
 "Only the keys specific to the Recipe Edit function are listed     "
 "here. Most of the other keys defined in the default TSE.UI file   "
 "are also available for use while editing. The 'keydef' is in the  "
 "R2TSE   source file, if you want to change some keys and          "
 "recompile. Please be careful not to add any 'file save' or exit   "
 "functions to the keydef. The Recipe Edit save and exit functions  "
 "are written to properly save the edited message or recipe. Any    "
 "attempt to use a 'normal' save file or exit function will not     "
 "work, and will cause any changes made to be lost. Also, do not add"
 "any keys which will switch to another file or buffer. The macro   "
 "assumes the correct buffer location and will not work if you      "
 "change to another file or buffer!                                 "
 ""
 "<Escape>    RecEditMenu()  - Main Edit menu                       "
 "<Alt F>     EFileMenu()    - File menu                            "
 "<Alt R>     ERecipeMenu()  - Recipe functions menu                "
 "<Alt E>     EMessageMenu() - Message functions menu               "
 "<Alt O>     EOtherMenu()   - Functions for recipes and            "
 "                             messages menu                        "
 "<Alt S>     SaveChanges()  - Save changes to recipe/message but   "
 "                             don't exit.                          "
 "<Alt X>     ExitEdit()     - Exit Edit (with prompt to save       "
 "                             changes) and return to the list.     "
 "<Alt N>     ExitEditNext() - Exit Edit (with prompt to save       "
 "                             changes) and edit the next           "
 "                             recipe or message in the list.       "
 "<Alt Tab>   ListKeywords() - This is for the popup keyword list   "
 "                             macro, which is in a separate file   "
 "                             (KEYWORD.MAC). It must be in the same"
 "                             directory with these macros (or in   "
 "                             your TSEPath) to be used here.       "
 "<Ctrl K><N> NotesLine()    - Add notes from the original message  "
 "or <Ctrl F2>                 to the end of the QBook format       "
 "                             recipe. Use <Alt L> to mark lines,   "
 "                             or place cursor on desired line if   "
 "                             you only want to move one line. Press"
 "                             <ENTER> when done.                   "
 "                             HINT: this can be used to view the   "
 "                             original message while editing the   "
 "                             recipe. Pressing <escape> will return"
 "                             to the recipe window without making  "
 "                             any changes.                         "
 "<Ctrl K><Y> YieldFmt()     - Format 'Yield:' or 'Servings:' line  "
 "or <Ctrl F4>                 and move to line under 'Keywords:'   "
 "                             line(s). Place cursor on line you    "
 "                             want to format.                      "
 "<Ctrl K><I> RAddIngred()   - Add an 'INGREDIENTS:' line to the    "
 "or <Ctrl F5>                 start of the ingredients list. This  "
 "                             may be used in future macros I write."
 "<Ctrl K><D> RAddDirect()   - Add a 'DIRECTIONS:' line to the start"
 "or <Ctrl F6>                 of the recipe directions. This may be"
 "                             used in future macros I write.       "
 "<Ctrl K><S> SourceFmt()    - Not installed. Will format 'Source:' "
 "or <Ctrl F3>                 line(s).                             "
 "<Ctrl F7>   QBTemplate()   - Not installed. Will add a 'template' "
 "                             in QBook format to the start of a    "
 "                             message.                             "
 "<Ctrl K><G> TMoveIngred()  - Not installed. Will move ingredients "
 "                             line(s) to the template.             "
 "<Ctrl K><R> TMoveDirect()  - Not installed. Will move directions  "
 "                             line(s) to the template.             "
 ""
end REditHelp


menubar RecEditMenu()
    history
    "&File"                     , EFileMenu()
    "   &Recipe functions"      , ERecipeMenu()
    "   Me&ssage functions"     , EMessageMenu()
    "   &Other functions"       , EOtherMenu()
end RecEditMenu

keydef REditKeys
//template        "**************************************************************************************************"
<HelpLine>        "{F1}-Help {F2}-AddLine {F4}-DupLn {F5}-TOS {F6}-DelEol {F7}-MStream {F8}-MWord {F9}-Save {F10}-Exit"
<Alt HelpLine>    "{Alt: F}-FileMenu {R}-RecipeMenu {E}-MessageMenu {O}-OtherMenu {T}-Template {X}-Exit {S}-Save"
<Ctrl HelpLine>   "{Ctrl: F2}-Add Notes {F3}-Source fmt {F4}-Yield fmt {F5}-Ingredient {F6}-Directions {F7}-Template"
<Shift HelpLine>  "{Shift: F1}- {F3}- {F4}- {F5}-ScrollCtr {F7}- {F8}- {F9}- {F10}-PotPourri"
 <Escape>              RecEditMenu()
 <F1>                  HelpOnREditKeys()
 <Shift F1>            Help("Key Assignments")
// <Alt F>               mPullDownMenu(<F>) //??? need to add this
 <Alt F>               EFileMenu()
 <Alt R>               ERecipeMenu()
 <Alt E>               EMessageMenu()
 <Alt O>               EOtherMenu()
 <Alt S>               SaveChanges()
 <Alt X>               ExitEdit()
 <Alt N>               ExitEditNext()
 <Alt T>
 <Alt Tab>             ExecMacro("KEYWORD")
 <Ctrl F2>             NotesLine()
 <Ctrl F3>             SourceFmt()
 <Ctrl F4>             YieldFmt()
 <Ctrl F5>             RAddIngred()
 <Ctrl F6>             RAddDirect()
 <Ctrl F7>             QBTemplate()
 <Ctrl F8>
 <Ctrl F9>
 <Ctrl F10>
 <Ctrl F11>
 <Ctrl F12>
 <Ctrl K><N>           NotesLine()
 <Ctrl K><S>           SourceFmt()
 <Ctrl K><Y>           YieldFmt()
 <Ctrl K><I>           RAddIngred()
 <Ctrl K><D>           RAddDirect()
 <Ctrl K><G>           TMoveIngred()
 <Ctrl K><R>           TMoveDirect()
// <Ctrl K><L>           FillBlock()
// <Ctrl K><T>           MarkWord()
// <Alt N>               NextFile()
// <Alt P>               PrevFile()

 <F2>                  AddLine()
 <F4>                  DupLine()
 <F5>                  ScrollToRow(1)
 <F6>                  DelToEol()
 <F7>                  MarkStream()
 <F8>                  MarkWord()
 <F9>                  SaveChanges()
 <F10>                 ExitEdit()
 <F11>
 <F12>                 ExecMacro("SpellChk")

// <Ctrl F1>             HelpOnWordAtCursor()
// <Ctrl F2>             mSwapLines()

// <Alt F1>              PrevHelp()
 <Alt F2>              InsertLine()
// <Alt F3>              mMatch()
// <Alt F4>              mLower()
 <Alt F5>              RollLeft()
 <Alt F6>              RollRight()
 <Alt F7>
 <Alt F8>
// <Alt F9>              Dos()
// <Alt F10>             ShowEntryScreen()
 <Alt F11>
 <Alt F12>

// <Shift F3>            Sort(sort_flags)
// <Shift F4>            mUpper()
 <Shift F5>            ScrollToRow(Query(WindowRows) / 2)
// <Shift F7>            mShiftBlock(SHIFTLEFT)
// <Shift F8>            mShiftBlock(SHIFTRIGHT)
 <Shift F9>
// <Shift F10>           ExecMacro("Potpourri")


// SPECIAL-PURPOSE KEY   EDITOR COMMAND/MACRO
// 컴컴컴컴컴컴컴컴컴�   컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴


 <BackSpace>           BackSpace()
 <Ctrl BackSpace>      DelLeftWord()

 <Enter>               Creturn()
 <Ctrl Enter>          ExecScrapMacro()

 <Tab>                 TabRight()
 <Shift Tab>           TabLeft()


// KEYPAD KEY            EDITOR COMMAND/MACRO
// 컴컴컴컴컴컴컴컴컴�   컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

 <Ins>                 ToggleInsert()

 <CursorDown>          Down()
 <Ctrl CursorDown>     RollDown()

 <CursorLeft>          Left()
 <Ctrl CursorLeft>     WordLeft()

 <CursorRight>         Right()
 <Ctrl CursorRight>    WordRight()

 <CursorUp>            Up()
 <Ctrl CursorUp>       RollUp()

 <Del>                 DelChar()
 <Alt Del>             DelToEol()
 <Ctrl Del>            DelRightWord()

 <End>                 EndLine()
 <Ctrl End>            EndWindow()
 
 <Grey*>               Paste()
 <Ctrl Grey*>          Paste(_OVERWRITE_)

 <Grey+>               Copy()
 <Ctrl Grey+>          Copy(_APPEND_)

 <Grey->               Cut()
 <Ctrl Grey->          Cut(_APPEND_)
 
 <Home>                BegLine()
 <Ctrl Home>           BegWindow()

 <PgDn>                PageDown()
 <Ctrl PgDn>           EndFile()

 <PgUp>                PageUp()
 <Ctrl PgUp>           BegFile()

 <Ctrl PrtSc>          Paste(_OVERWRITE_)


// MOUSE BUTTON          EDITOR COMMAND/MACRO
// 컴컴컴컴컴컴컴컴컴�   컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

// <LeftBtn>             mLeftBtn()
// <Alt LeftBtn>         MouseMarking(_LINE_)
// <Ctrl LeftBtn>        MouseMarking(_COLUMN_)
// <Shift LeftBtn>       mTrackMouseCursor()

// <RightBtn>            ClipBoardMenu()


// CONTROL KEY           EDITOR COMMAND/MACRO
// 컴컴컴컴컴컴컴컴컴�   컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

// <Ctrl ->              mCopyCharAbove()
// <Ctrl 0>              mListRecentFiles()
 <Ctrl 2>              PlaceMark()
 <Ctrl 6>              GotoMark()
// <Ctrl =>              mFindWordAtCursor('b')
 <Ctrl [>              GotoBlockBegin()
// <Ctrl \>              mFindWordAtCursor('g')
 <Ctrl ]>              GotoBlockEnd()
// <Ctrl A>              mAsciiChart()
// <Ctrl B>              NamedClipBoardMenu("Named ClipBoards")
 <Ctrl C>              GotoColumn()
 <Ctrl D>              DelLine()
 <Ctrl F>              Find()
// <Ctrl G>              mCompressView(1)
// <Ctrl I>              mIncrementalSearch()
 <Ctrl J>              GotoLine()
 <Ctrl L>              RepeatFind()
 <Ctrl M>              RecordKeyMacro()
 <Ctrl N>              InsertLine()
 <Ctrl O><C>           CloseWindow()
 <Ctrl O><D>           DelWindow()
 <Ctrl O><G>           GotoWindow()
 <Ctrl O><H>           HWindow()
 <Ctrl O><N>           NextWindow()
 <Ctrl O><O>           OneWindow()
 <Ctrl O><P>           PrevWindow()
 <Ctrl O><R>           ResizeWindow()
// <Ctrl O><T>           mCenterLine()
 <Ctrl O><V>           VWindow()
 <Ctrl O><W>           Toggle(WordWrap)
 <Ctrl O><Z>           ZoomWindow()
 <Ctrl P>              Literal()
 <Ctrl Q><0>           GotoMark("q")
 <Ctrl Q><1>           GotoMark("r")
 <Ctrl Q><2>           GotoMark("s")
 <Ctrl Q><3>           GotoMark("t")
 <Ctrl Q><4>           GotoMark("u")
 <Ctrl Q><5>           GotoMark("v")
 <Ctrl Q><6>           GotoMark("w")
 <Ctrl Q><7>           GotoMark("x")
 <Ctrl Q><8>           GotoMark("y")
 <Ctrl Q><9>           GotoMark("z")
 <Ctrl Q><Ctrl Q>      RepeatCmd()
 <Ctrl Q><I>           Set(AutoIndent, iif(Query(AutoIndent), 0, 2))
 <Ctrl Q><L>           RestoreCursorLine()
 <Ctrl Q><P>           PrevPosition()
 <Ctrl R>              Replace()
 <Ctrl T>              DelRightWord()
 <Ctrl U>              GlobalUnDelete()
 <Ctrl V>              Toggle(LineDrawing)
 <Ctrl W>              ScrollUp()
 <Ctrl X>              ExecMacro()
 <Ctrl Y>              DelLine()
 <Ctrl Z>              ScrollDown()


// ALT KEY               EDITOR COMMAND/MACRO
// 컴컴컴컴컴컴컴컴컴�   컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

// <Alt ->               mCopyCharAboveToEol()
// <Alt 0>               mListOpenFiles()
 <Alt 1>               Upper()
 <Alt 2>               Lower()
 <Alt 3>               Flip()
 <Alt 4>
 <Alt 5>
 <Alt 6>
 <Alt 7>
 <Alt 8>
 <Alt 9>
// <Alt =>               mFindWordAtCursor('+')
 <Alt A>               MarkStream()
 <Alt B>               WrapPara()
 <Alt C>               CopyBlock()
 <Alt D>               DelLine()
// <Alt E>               EditFile()
 <Alt G>               DelBlock()
 <Alt I>               MarkChar()
 <Alt J>               JoinLine()
 <Alt K>               MarkColumn()
 <Alt L>               MarkLine()
 <Alt M>               MoveBlock()
 <Alt U>               UnMarkBlock()
// <Alt V>               mCompressView(0)
// <Alt W>               SaveBlock()
 <Alt Z>               CopyBlock(_OVERWRITE_)


// SHIFT KEY             EDITOR COMMAND/MACRO
// 컴컴컴컴컴컴컴컴컴�   컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

// <Shift ]>             mCloseBrace()

end REditKeys

//KEYS FOR NotesLineKeys
constant notesESCAPE     =   0,      //abort
         notesENTER      =   1       //select line(s)

keydef NotesLineKeys
<HelpLine>        "{Alt L}-MarkLine {Cursor Keys}-Normal Usage {Enter}-Done"
<Alt HelpLine>    "{Alt L}-MarkLine {Cursor Keys}-Normal Usage {Enter}-Done"
<Ctrl HelpLine>   "{Alt L}-MarkLine {Cursor Keys}-Normal Usage {Enter}-Done"
<Shift HelpLine>  "{Alt L}-MarkLine {Cursor Keys}-Normal Usage {Enter}-Done"
    <GreyEnter>         EndProcess(notesENTER)
    <Enter>             EndProcess(notesENTER)
    <Escape>            EndProcess(notesESCAPE)
    <CenterBtn>         EndProcess(notesENTER)
    <LeftBtn>           EndProcess(notesENTER)
    <RightBtn>          EndProcess(notesENTER)
    <Alt L>             MarkLine()
    <CursorUp>          Up()
    <GreyCursorUp>      Up()
    <CursorDown>        Down()
    <GreyCursorDown>    Down()
    <Home>              BegWindow()
    <GreyHome>          BegWindow()
    <End>               EndWindow()
    <GreyEnd>           EndWindow()
    <PgDn>              PageDown()
    <GreyPgDn>          PageDown()
    <PgUp>              PageUp()
    <GreyPgUp>          PageUp()
    <Ctrl PgDn>         EndFile()
    <Ctrl PgUp>         BegFile()
end NotesLineKeys

menu EFileMenu()
    x = 2
    y = 2
    history
    command = NotWorking()
    "&Save Changes"             , SaveChanges()     ,, "Save changes to message or recipe"
    "E&xit"                     , ExitEdit()        ,, "Exit the edit function"
end EFileMenu

menu ERecipeMenu()
    x = 11
    y = 2
    history
    command = NotWorking()
    "Add &Notes"                , NotesLine()       ,, "Add lines from original message to end of recipe"
//    "Format &Source"            , SourceFmt()       ,, "Format 'Source:' line(s)"
    "Format &Source"            ,                   ,, "Format 'Source:' line(s)"
    "Format &Yield"             , YieldFmt()        ,, "Format 'Yield(Servings):' line(s)"
end ERecipeMenu

menu EMessageMenu()
    x = 32
    y = 2
    history
    command = NotWorking()
//    "&Template"                 , QBTemplate()      ,, "Insert a recipe template at the start of the message"
    "&Template"                 ,                   ,, "Insert a recipe template at the start of the message"
//    "Move &Ingredients"         , TMoveIngred()     ,, "Move ingredients line(s) to template after 'Ingredients:' line"
    "Move &Ingredients"         ,                   ,, "Move ingredients line(s) to template after 'Ingredients:' line"
//    "Move &Directions"          , TMoveDirect()     ,, "Move directions line(s) to template after 'Directions:' line"
    "Move &Directions"          ,                   ,, "Move directions line(s) to template after 'Directions:' line"
end EMessageMenu

menu EOtherMenu()
    x = 54
    y = 2
    history
    command = NotWorking()
    "Add &Ingredients Line"     , RAddIngred()      ,, "Add an 'Ingredients:' line before the current line"
    "Add &Directions Line"      , RAddDirect()      ,, "Add a 'Directions:' line before the current line"
end EOtherMenu

