/************************************************************************
  Author:  SemWare (Sammy Mitchell)

  Date:    August, 1993

        The original idea for this macro came from the Sprint Potpourri
        menu (hence the name).

        Tom Wheeler wrote a similar macro, proving that it could be done,
        thus giving impetus to this version.

        Modified:

        10/14/93 Steve Watkins
                Allows for interactive add/del of items

        05-19-94 Kevin A. Carr
                Added support for user-configurable help.

        07-18-94 Kevin A. Carr
                Now searches for "Keys:" in the description and
                displays popup box with list of key assignemts
                when a macro is selected.

        08-04-94 George De Bruin
                Added PushBlock()/PopBlock() to preserve blocks
                users may have marked before calling Potpourri.

        April 19, 2006 Sam Mitchell
                On Linux, filenames are case-sensitive.  For now,
                assume all macro names are lower-case.  In the call to
                ExecMacro(), lowercase the filename.

        May 9, 2019 Carlo Hogeveen
                Backwards compatibly extended possible macro names
                from 8 to 12 characters.


  Description:

    This macro provides a simple mechanism for allowing easy access to
    numerous macros, without having to place them on menus or giving them
    key assignments.  Just execute the potpourr macro, and up pops a list
    (with a single line description) of your own choosing.

  Assumptions:

    The file "potpourr.dat" (and the macros that it references) exist
    somewhere along the TSEPath, in the current directory, or in the editor
    load directory.

  Usage notes:

    Create a file called potpourr.dat, and place it somewhere as mentioned
    above.  A potpourr.dat file is supplied with the editor, and placed in the
    SE directory.

    How to get Potpourri to display key assignments for macros when selected:

    Highlight the desired macro and press the <Alt E> key to edit the
    description. The first line of the description is the brief description
    displayed in the main list.  Somewhere after this line, begin a new line
    with the keyword "Keys:" (without the quotes).  Then list the key
    assignments on the following lines.  Terminate  the key assignments with a
    blank line.  There MUST be a blank line between the last key assignment
    line and any text that follows. The only exception is if the key
    assignments are the last lines entered. Also, there cannot be any blank
    lines within the key assignments.

    Two common formats for key assignments are as follows:

    1)      Keys:
                    <F1>        Help
                    <Ctrl Y>    Delete the current line
                    <Escape>    Exit and Save


    2)      Keys:
                    Help                        <F1>
                    Delete the current line     <Ctrl Y>
                    Exit and Save               <Escape>

    See the descriptions of the supplied macros for more examples.

    By default, this macro is on the TSE Util menu, item Potpourri.

 ************************************************************************/

constant    KILL    = FALSE,
            ADD     = TRUE

string  potpourri_fn[70] = "potpourr.dat",
        item_expr[] = "^[~ ]",
        help_fn[12]

integer last_pot, datID, workID, quick_help, no_help,
        TextAttr, CursorAttr, CurrWinBorderAttr,
        MenuBorderAttr, MenuTextAttr, MenuTextLtrAttr,
        MenuSelectAttr, MenuSelectLtrAttr,
        mba, mta, mtla, msa, msla

constant FNLEN = 12

proc SetMenuColors()
    mba = Set(MenuBorderAttr, MenuBorderAttr)
    mta = Set(MenuTextAttr, MenuTextAttr)
    mtla = Set(MenuTextLtrAttr, MenuTextLtrAttr)
    msa = Set(MenuSelectAttr, MenuSelectAttr)
    msla = Set(MenuSelectLtrAttr, MenuSelectLtrAttr)
end

proc RestoreColors()
    Set(MenuBorderAttr, mba)
    Set(MenuTextAttr, mta)
    Set(MenuTextLtrAttr, mtla)
    Set(MenuSelectAttr, msa)
    Set(MenuSelectLtrAttr, msla)
end

integer proc mYesNo(string title)
    integer rc

    Set(X1, WhereXAbs())
    Set(Y1, WhereYAbs())
    SetMenuColors()
    rc = YesNo(title)
    RestoreColors()

    return (rc)
end

string proc FindMacro(string macro_fn)
    return (SearchPath(macro_fn, Query(TSEPath), "mac"))
end

integer proc FindAnyItem()
    return (lFind(item_expr, "gx"))
end

integer proc FindNextItem()
    return (lFind(item_expr, "+x"))
end

integer proc BuildItemList()
    EmptyBuffer(workID)
    GotoBufferId(datID)
    if (FindAnyItem())
        repeat
            if not AddLine(GetText(1, 78), workID)
                return (FALSE)
            endif
        until (not lRepeatFind())
    endif
    GotoBufferId(workID)
    return (TRUE)
end

proc RemoveTrailingBlankLines()
    EndFile()
    while (PosFirstNonWhite() == 0)
        KillLine()
        if (not Up())
            break
        endif
    endwhile
end

integer proc GotoItem(string item)
    GotoBufferId(datID)
    return (lFind(item, "^gi"))
end

integer proc FindItem(string item)
    integer rc, id = GetBufferId()

    rc = GotoItem(item)
    GotoBufferId(id)
    return (rc)
end

proc loMarkItem()
    UnMarkBlock()
    MarkLine()
    if (FindNextItem())
        Up()
    else
        EndFile()
    endif
    MarkLine()
end

integer proc MarkItem(string item)
    integer id = GetBufferId(), rc = FALSE

    if (GotoItem(item))
        loMarkItem()
        rc = TRUE
    endif

    GotoBufferId(id)
    return (rc)
end

proc KillCurrItem()
    //
    // expects to be sitting on first line of item
    // leaves cursor on first line of next item or <EOL marker>
    //
    PushBlock()
    loMarkItem()
    KillBlock()
    PopBlock()
end

proc loAddItem(string item)
    //
    // expects item to add marked as a line block in workID
    //
    integer InsertLineBlocksAbove = Set(InsertLineBlocksAbove, TRUE)
    string  temp[FNLEN]

    if (GotoItem(item))     // leaves us in datID
        KillCurrItem()
        CopyBlock()
    else
        if (FindAnyItem())
            loop
                temp = Lower(Trim(GetText(1, FNLEN)))
                if (temp > Lower(item))
                    CopyBlock()
                    break
                endif
                if (not lRepeatFind())
                    EndFile()
                    Set(InsertLineBlocksAbove, FALSE)
                    CopyBlock()
                    break
                endif
            endloop
        else
            EndFile()
            CopyBlock()
        endif
    endif

    Set(InsertLineBlocksAbove, InsertLineBlocksAbove)
end


integer proc DoSpellCheck()
    PushKey(<F>)
    if (not ExecMacro("SPELLCHK"))
        Warn("Error executing SpellChk!")
    endif
    return (1)
end

menu ExitMenu()
    title = "Save Changes?"
    "&Yes (run SpellCheck)",    DoSpellCheck()
    "Y&es"
    "&No"
    "&Cancel"
end

integer proc DoExitMenu()
    integer rc

    Set(X1, WhereXAbs())
    Set(Y1, WhereYAbs())
    SetMenuColors()
    rc = ExitMenu()
    RestoreColors()
    return (rc)
end

proc ExitHelpEdit()
    //
    // expects to be in workID
    //
    if (not FileChanged())
        EndProcess(TRUE)
    else
        case (DoExitMenu())
            when 1, 2
                RemoveTrailingBlankLines()
                MarkLine(1, NumLines())
                lReplace("^", "            ", "glxn")
                BegFile()
                InsertText(help_fn, _OVERWRITE_)
                loAddItem(help_fn)
                SaveAs(potpourri_fn, _OVERWRITE_)
                EndProcess(TRUE)
            when 3
                EndProcess(FALSE)
        endcase
    endif
end

proc mDelCh()
    if (CurrChar() >= 0)
        DelChar()
    else
        JoinLine()
    endif
end

proc mBackSpace()
    if (not BackSpace() and PrevChar())
        JoinLine()
    endif
end

Helpdef EditHelpKeys
    title = "Editing Keys QuickHelp"
    x = 18
    y = 1
    "  The first line of the help description"
    "  is used as the summary line."
    ""
    "  Use the cursor keys to move around."
    ""
    "  Go to beginning of line          <Home>"
    "  Go to end of line                <End>"
    ""
    "  Go to previous page              <PgUp>"
    "  Go to next page                  <PgDn>"
    ""
    "  Delete current line              <Alt D>"
    "  Insert new line                  <Enter>"
    ""
    "  Toggle Insert Mode               <Insert>  "
    ""
    "  Exit with option to save         <Escape>"
    "       and SpellCheck"
    ""
end

proc mQuickHelp()
    SetMenuColors()
    quick_help = TRUE
    QuickHelp(EditHelpKeys)
    quick_help = FALSE
    RestoreColors()
end

proc ProcessLeftBtn()

    case MouseHotSpot()

        when _MOUSE_MARKING_, _MOUSE_VWINDOW_, _MOUSE_HWINDOW_, _MOUSE_VRESIZE_, _MOUSE_HRESIZE_
        /* do nothing */

        when _MOUSE_CLOSE_, _NONE_
            ExitHelpEdit()
        otherwise
            ProcessHotSpot()
    endcase
end

keydef HelpEditKeys
    <CursorUp>      Up()
    <CursorDown>    Down()
    <CursorLeft>    Left()
    <CursorRight>   Right()
    <Home>          BegLine()
    <PgUp>          PageUp()
    <End>           EndLine()
    <PgDn>          PageDown()
    <Enter>         CReturn()   // mCReturn()
    <Del>           mDelCh()
    <BackSpace>     mBackSpace()
    <Ins>           Toggle(Insert)
    <Tab>           TabRight()
    <Shift Tab>     TabLeft()
    <Alt D>         KillLine()  // mDelLine()
    <F1>            mQuickHelp()
    <Escape>        ExitHelpEdit()
    <LeftBtn>       ProcessLeftBtn()
    <RightBtn>      ExitHelpEdit()
end

proc EditHelpStartup()
    integer rc = FALSE

    if (not quick_help)
        Set(Cursor, ON)
        if (Enable(HelpEditKeys, _EXCLUSIVE_| _TYPEABLES_))
            Set(Attr, Query(MenuBorderAttr))
            VGotoXY(5, 0)
            PutStr(' '+help_fn+' ')
            VGotoXY(59, 0)
            PutStr(" F1=Help ")
            DisplayMode(_DISPLAY_TEXT_)
            rc = Process()
            DisplayMode(_DISPLAY_USER_)
        endif
        EndProcess(rc)
    endif
    BreakHookChain()
end

proc GetItem()
    GotoBufferId(workID)
    EmptyBuffer()
    PushBlock()
    if (MarkItem(help_fn))
        CopyBlock()
        MarkColumn(1, 1, NumLines(), 12)
        KillBlock()
        RemoveTrailingBlankLines()
    endif
    no_help = (NumLines() == 0)
    if (no_help)
        AddLine(" - No Help Available -")
    endif
    BegFile()
    PopBlock()
end

integer proc loEditItemHelp()
    //
    // expects to be in workID with item help already inserted
    //
    integer rc, Cursor = Query(Cursor),
            MenuTextAttr = Set(MenuTextAttr, TextAttr),
            MenuSelectAttr = Set(MenuSelectAttr, CursorAttr),
            MenuBorderAttr = Set(MenuBorderAttr, CurrWinBorderAttr)

    if (no_help)
        EmptyBuffer()
    endif

    EndFile()

    FileChanged(FALSE)
    BegFile()

    Set(Y1, 1)
    if (Hook(_LIST_STARTUP_, EditHelpStartup))
        rc = lList("Editing Help Description", 68, Query(ScreenRows) - 2, _ENABLE_HSCROLL_ | _FIXED_HEIGHT_)
        UnHook(EditHelpStartup)
    endif

    Set(MenuBorderAttr, MenuBorderAttr)
    Set(MenuSelectAttr, MenuSelectAttr)
    Set(MenuTextAttr, MenuTextAttr)
    Set(Cursor, Cursor)

    return (rc)
end

proc EditItemHelp()
    help_fn = Trim(GetText(1, FNLEN))
    GetItem()
    loEditItemHelp()
    BuildItemList()
    lFind(help_fn, "^gi")
end

keydef HelpListKeys
    <CursorUp>      RollUp()
    <CursorDown>    RollDown()
    <CursorLeft>    RollLeft()
    <CursorRight>   RollRight()
    <Home>          BegFile()
    <PgUp>          BegFile()
    <End>           EndFile()
    <PgDn>          EndFile()
    <Escape>        EndProcess(0)
    <Alt E>         EndProcess(1)
end

proc HelpListStartup()
    if (not Enable(HelpListKeys, _EXCLUSIVE_))
        EndProcess()
    else
        ListFooter(" {Escape}-Exit  {Alt E}-Edit ")
    endif
    BreakHookChain()
end

proc PotpourriHelp()
    //
    // expects to be in workID
    //
    integer line = CurrLine(), y = WhereYAbs(),
            MenuBorderAttr = Set(MenuBorderAttr, Query(HelpBoldAttr)),
            MenuTextAttr = Set(MenuTextAttr, Query(HelpTextAttr)),
            MenuSelectAttr = Set(MenuSelectAttr, Query(HelpTextAttr)),
            MenuTextLtrAttr = Set(MenuTextLtrAttr, Query(HelpLinkAttr))


    help_fn = Trim(GetText(1, FNLEN))

    if (Hook(_LIST_STARTUP_, HelpListStartup))
        DisplayMode(_DISPLAY_TEXT_)
        loop
            GetItem()
            if ((y + NumLines() + 2) > Query(ScreenRows))
                y = Query(ScreenRows) - NumLines() - 1
            endif
            Set(Y1, y)
            if (not List(help_fn, 68))
                break
            endif
            loEditItemHelp()
        endloop
        DisplayMode(_DISPLAY_USER_)
        UnHook(HelpListStartup)
    endif

    BuildItemList()
    GotoLine(line)
    Set(MenuTextLtrAttr, MenuTextLtrAttr)
    Set(MenuSelectAttr, MenuSelectAttr)
    Set(MenuTextAttr, MenuTextAttr)
    Set(MenuBorderAttr, MenuBorderAttr)
end

proc AddItem()
    integer rc, cursor, line = CurrLine()
    string fn[FNLEN] = ''

    cursor = Set(Cursor,ON)
    if Ask("Macro name:",fn)
        fn = SplitPath(fn, _NAME_)
        if Length(FindMacro(fn + ".mac")) == 0
            Warn("Macro [", fn, "] not found in TSEPath - not added.")
        elseif (FindItem(fn))
            Warn("Macro [", fn, "] already in Potpourri.")
        else
            EmptyBuffer()
            help_fn = fn
            rc = loEditItemHelp()
            BuildItemList()
            if (rc)
                lFind(help_fn, "^gi")
            else
                GotoLine(line)
            endif
            EndProcess(-1)
        endif
    endif
    Set(Cursor, cursor)
end

proc DelItem()
    string  fn[FNLEN] = Trim(GetText(1, sizeof(fn)))
    integer line = CurrLine()

    if (mYesNo("Delete "+ fn + "?") == 1 and GotoItem(fn))
        KillCurrItem()
        SaveAs(potpourri_fn, _OVERWRITE_)
        BuildItemList()
        if (not GotoLine(line))
            EndFile()
        endif
        EndProcess(-1)
    endif
end

KeyDef ListKeys
    <F1>        PotpourriHelp()
    <Alt E>     EditItemHelp()
    <Ins>       AddItem()
    <GreyIns>   AddItem()
    <Del>       DelItem()
    <GreyDel>   DelItem()
end

proc ListHook()
    if (not Enable(ListKeys))
        EndProcess()
    else
        ListFooter(" {F1}-Help  {Ins}-Add  {Del}-Delete  {Enter}-Execute  {Alt E}-Edit Help  {Escape}-Cancel ")
    endif
    BreakHookChain()
end

proc AbandonBuffers()
    AbandonFile(datID)
    AbandonFile(workID)
end

proc InsertDatFile()
    integer attribute

    GotoBufferId(datID)
    EmptyBuffer()
    attribute = FileExists(potpourri_fn)
    if attribute and (attribute & _DIRECTORY_) == 0
        PushBlock()
        InsertFile(potpourri_fn)
        PopBlock()
    endif
end

proc CreateDatFile()
    PushBlock()
    GotoBufferId(datID)
    EmptyBuffer()
    AddLine(" ;")
    AddLine(" ;")
    AddLine(" ; SemWare Potpourri Macro data file.")
    AddLine(" ;")
    AddLine(" ; *WARNING*     DO NOT EDIT THIS FILE DIRECTLY!!!")
    AddLine(" ;")
    AddLine(" ; The Potpourri macro expects this file to be in a certain format.")
    AddLine(" ;")
    AddLine(" ;")
    AddLine()
    PopBlock()
end

proc WhenLoaded()
    string pfn[70]

    PushPosition()

    pfn = FindMacro(potpourri_fn)
    if (Length(pfn))
        potpourri_fn = pfn
    endif

    workID = CreateTempBuffer()
    datID = CreateTempBuffer()

    if workID and datID
        if Length(pfn)
            InsertDatFile()
        else
            CreateDatFile()
        endif
        BuildItemList()
    else
        PurgeMacro(CurrMacroFilename())
    endif

    PopPosition()
end

proc WhenPurged()
    AbandonBuffers()
end

proc DisplayLn(integer is_cursorline)
    PutStr(GetText(1,FNLEN), iif(is_cursorline, Query(MenuSelectLtrAttr), Query(MenuTextLtrAttr)))
    PutStr(GetText(FNLEN + 1,CurrLineLen()))
    ClrEol()
end

proc HiLiteLn()
    HiliteFoundText()
end

proc Main()
    string  fn[FNLEN]
    integer y2, exec_it, cursor

    TextAttr          = Query(TextAttr)
    CursorAttr        = Query(CursorAttr)
    CurrWinBorderAttr = Query(CurrWinBorderAttr)
    MenuBorderAttr    = Query(MenuBorderAttr)
    MenuTextAttr      = Query(MenuTextAttr)
    MenuTextLtrAttr   = Query(MenuTextLtrAttr)
    MenuSelectAttr    = Query(MenuSelectAttr)
    MenuSelectLtrAttr = Query(MenuSelectLtrAttr)

    exec_it = 0
    PushPosition()
    GotoBufferId(workID)
    if (Hook(_LIST_STARTUP_, ListHook))
        PushBlock()
        repeat
            GotoLine(last_pot)
            HookDisplay(DisplayLn,,,HiLiteLn)
            exec_it = lList("Potpourri", Query(ScreenCols), NumLines(), _ANCHOR_SEARCH_ | _ENABLE_SEARCH_)
            UnHookDisplay()
            fn = Trim(GetText(1, sizeof(fn)))
            last_pot = CurrLine()
        until exec_it >= 0
        UnHook(ListHook)
        PopBlock()
    endif
    if exec_it > 0
        help_fn = fn
        GetItem()
        if lFind("^[ \t]*Keys:[ \t]@\c", "gix") and not Pos("none", Lower(GetText(CurrPos(), 15)))
            while Up()
                KillLine()
            endwhile
            if lFind("^$", "gx")
                PushBlock()
                MarkLine(CurrLine(), NumLines())
                KillBlock()
                PopBlock()
            endif
            y2 = NumLines() + 4
            if PopWinOpen(10, 3, 70, y2, 2, "Key assignments for macro: "+fn, Query(MenuBorderAttr))
                Set(Attr, Query(MenuTextAttr))
                ClrScr()
                BegFile()
                repeat
                    VGotoXY(1, CurrLine())
                    PutStr(GetText(1, 59))
                until not Down()
                VGotoXYAbs(27, y2)
                Set(Attr, Query(MenuBorderAttr))
                PutStr(" Press any key to continue ")
                cursor = Set(Cursor, OFF)
                GetKey()
                Set(Cursor, cursor)
                PopWinClose()
            endif
        endif
        BuildItemList()
    endif
    PopPosition()
    UpdateDisplay()
    if exec_it > 0
        ExecMacro(Lower(fn))
    endif
end

