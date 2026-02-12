/****************************************************************************\

    compx.s

    Compares two text files interactively.

    Overview:

    DlgCompX loads two files and starts comparing them. If a pair of
    non matching lines is found, it stops and highlights these lines.
    The user now can make a detailed comparison of the lines, adjust
    the file position in either or both files or just continue comparing.

    Keys:       (none)

    Command Line Format:

    Cannot be called directly, must use DlgComp.
    The filenames are retrieved from the history lists.

    Usage notes:

    The key assignment when Compare stops at a mismatch is displayed
    at the help line. Press the Ctrl or Alt keys to see more commands.
    DlgCompX can be interrupted anytime by pressing Escape. The files
    which should be compared must exist and must be specified at the
    DlgCompX macro command line, otherwise the macro will be aborted.

    Version         v3.30/09.05.05
    Copyright       (c) 1994-2005 by DiK

    History

    v3.30/09.05.05  adaption to WinDlgs (Win32 only)
    v3.20/30.11.00  removed non-Ascii marking characters
    v3.10/30.11.00  changed calling convention
    v3.01/08.07.97  adaption to TSE32 (switch off syntax hilighting)
    v3.00/24.10.96  adaption to TSE32 (simplified exiting logic)
    v2.10/03.08.95  adaption to v2.5 of TSE
    v2.00/28.04.95  interface to TseFile, Menu & Help
    v1.11/25.11.94  bug-fix
    v1.10/26.10.94  adaption to v2.0 of TSE
    v1.00/26.01.94  first release

    Note:

    DlgCompX is TseComp minus the user interface.

    Warning:

    DlgCompX doesn't update the display when exiting.
    This has to be done by the calling macro.

\****************************************************************************/

/****************************************************************************\
    screen colors
\****************************************************************************/

integer clr_comp_text   = Color(Blink Black on White)
integer clr_comp_block  = Color(Bright White on Black)
integer clr_comp_cursor = Color(Blink Black on Cyan)
integer clr_comp_curr   = Color(Blink Bright Blue on White)
integer clr_comp_menu   = Color(Black on White)
integer clr_comp_hotkey = Color(Red on White)
integer clr_comp_select = Color(Black on Green)
integer clr_comp_selkey = Color(Red on Green)

/****************************************************************************\
    constant strings
\****************************************************************************/

string  banner1[] = "TSE File Comparison 3.30"
string  banner2[] = "Copyright (c) 1994-2005 by DiK"

/****************************************************************************\
    global variables
\****************************************************************************/

integer vert                            // vertical split screen
integer roll                            // lines for page roll
integer code                            // return code of exit menu
integer temp                            // working buffer
integer buff1, load1                    // left buffer
integer buff2, load2                    // right buffer
string  filter[64]                      // ignored characters
string  name1[255]                      // filename
string  name2[255]                      // ditto

/****************************************************************************\
    Editor environment changes
\****************************************************************************/

integer fcEquateEnhancedKbd,
        fcInsertLineBlocksAbove,
        fcExpandTabs,
        fcTabWidth,
        fcTabType,
        fcShowEOFMarker,
        fcTextAttr,
        fcBlockAttr,
        fcCursorAttr,
        fcCurrWinBorderAttr,
        fcOtherWinBorderAttr,
        fcMsgAttr,
        fcHelpTextAttr,
        fcMenuTextAttr,
        fcMenuTextLtrAttr,
        fcMenuSelectAttr,
        fcMenuSelectLtrAttr,
        fcMenuBorderAttr,
        fcShowSyntaxHilite

/****************************************************************************\
    helper macros
\****************************************************************************/

proc SyncLines( integer rn )
    GotoWindow(2)
    if rn
        GotoLine(rn)
    endif
    ScrollToCenter()
    GotoWindow(1)
    ScrollToCenter()
end

proc SplitScreen()
    vert = not vert
    OneWindow()
    if vert
        VWindow()
    else
        HWindow()
    endif
    GotoBufferId(buff2)
    GotoWindow(1)
    GotoBufferId(buff1)
    SyncLines(0)
end

proc ErrorMsg(string msg)
    MsgBox("Error",msg,_OK_)
end

/****************************************************************************\
    left side movement
\****************************************************************************/

proc LeftRollUp( integer lines )
    if not RollUp(lines)
        Up()
    endif
end

proc LeftRollDown( integer lines )
    if not RollDown(lines)
        Down()
    endif
end

/****************************************************************************\
    right side movement
\****************************************************************************/

proc RightRollUp( integer lines )
    GotoWindow(2)
    if not RollUp(lines)
        Up()
    endif
    GotoWindow(1)
end

proc RightRollDown( integer lines )
    GotoWindow(2)
    if not RollDown(lines)
        Down()
    endif
    GotoWindow(1)
end

proc RightBegFile()
    GotoWindow(2)
    BegFile()
    GotoWindow(1)
end

proc RightEndFile()
    GotoWindow(2)
    EndFile()
    GotoWindow(1)
end

/****************************************************************************\
    beginning/end of block
\****************************************************************************/

proc BegBlock()
    if isBlockMarked()
        if isBlockInCurrFile()
            GotoBlockBegin()
        else
            GotoWindow(2)
            GotoBlockBegin()
            GotoWindow(1)
        endif
        SyncLines(0)
    else
        Alarm()
    endif
end

proc EndBlock()
    if isBlockMarked()
        if isBlockInCurrFile()
            GotoBlockEnd()
            Down()
        else
            GotoWindow(2)
            GotoBlockEnd()
            Down()
            GotoWindow(1)
        endif
        SyncLines(0)
    else
        Alarm()
    endif
end

/****************************************************************************\
    basic searching
\****************************************************************************/

menu SearchTextMenu()
    "&Left Window",,,
        "Search for text (left window)"
    "&Right Window",,,
        "Search for text (right window)"
end

proc SearchText()
    SearchTextMenu()
    case MenuOption()
        when 0
            return()
        when 2
            GotoWindow(2)
    endcase
    Find()
    SyncLines(0)
end

/****************************************************************************\
    line commands
\****************************************************************************/

menu DelLineMenu()
    "&Left Line",,,
        "Delete the current line (left window)"
    "&Right Line",,,
        "Delete the current line (right window)"
end

proc UpdateLine( integer leftwin )
    string ll[255]

    if leftwin
        GotoWindow(2)
    endif
    ll = GetText(1,255)
    NextWindow()
    DelToEol()
    InsertText(ll)
    BegLine()
    SyncLines(0)
end

proc DeleteLine()
    DelLineMenu()
    case MenuOption()
        when 0
            return()
        when 2
            GotoWindow(2)
    endcase
    DelLine()
    SyncLines(0)
end

/****************************************************************************\
    block commands
\****************************************************************************/

proc CopyMissingBlock()
    if isBlockMarked()
        if isBlockInCurrFile()
            GotoWindow(2)
        endif
        CopyBlock()
        GotoBlockEnd()
        Down()
        SyncLines(0)
    else
        Alarm()
    endif
end

proc DeleteBlock()
    if isBlockMarked()
        if not isBlockInCurrFile()
            GotoWindow(2)
        endif
        DelBlock()
        SyncLines(0)
    else
        Alarm()
    endif
end

proc UndoSearch()
    if isBlockMarked()
        if not isBlockInCurrFile()
            GotoWindow(2)
        endif
        GotoBlockBegin()
        UnmarkBlock()
        SyncLines(0)
    else
        Alarm()
    endif
end

/****************************************************************************\
    compare filtered lines
\****************************************************************************/

proc FilterLine ( var string nl, string ol )
    AddLine(ol)
    lReplace("["+filter+"]","","gnx")
    nl = GetText(1,255)
    EmptyBuffer()
end

integer proc DiffLines( string l1, string l2 )
    string nl1[255] = ""
    string nl2[255] = ""

    if Length(filter)
        GotoBufferId(temp)
        FilterLine(nl1,l1)
        FilterLine(nl2,l2)
        GotoBufferId(buff2)
        return ( nl1 <> nl2 )
    endif
    return (TRUE)
end

/****************************************************************************\
    search routine
\****************************************************************************/

proc SearchLine( integer leftwin )
    string ll[255]

    // get line and switch windows

    if leftwin
        GotoWindow(2)
    endif
    ll = GetText(1,255)
    NextWindow()

    // search the line

    MarkLine()
    while Down()
        if ll == GetText(1,255) or not DiffLines(ll,GetText(1,255))
            break
        endif
    endwhile
    Up()
    MarkLine()
    Down()

    // synchronize display

    SyncLines(0)
end

/****************************************************************************\
    compare routine
\****************************************************************************/

proc Compare( integer start )
    integer dn
    integer ln, rn
    string ll[255]

    // get current line numbers and go down one line

    UnmarkBlock()
    if start
        BegFile()
        RightBegFile()
        UpdateDisplay()
        ln = 0
        rn = 0
    else
        ln = CurrLine()
        dn = Down()
        if dn
            GotoBufferId(buff2)
            rn = CurrLine()
            dn = Down()
            GotoBufferId(buff1)
            if not dn
                Up()
            endif
        endif
        if not dn
            Alarm()
            ErrorMsg("Cannot scan beyond this point")
            return ()
        endif
    endif

    // compare files one line at a time

    loop
        ln = ln + 1
        rn = rn + 1

        // compare lines

        ll = GetText(1,255)
        GotoBufferId(buff2)
        if ll <> GetText(1,255) and DiffLines(ll,GetText(1,255))
            GotoBufferId(buff1)
            Message("Differences in lines ",ln," and ",rn)
            SyncLines(rn)
            return()
        endif

        // advance to next lines

        dn = Down()
        GotoBufferId(buff1)
        if not ( dn and Down() )
            break
        endif

        // display status message and check for interrupt

        if (ln & 0x0F) == 0
            Message("Current line ",ln,", Hit <Esc> to Break")
            if KeyPressed() and GetKey() == <Escape>
                Message("User break in lines ",ln," and ",rn)
                SyncLines(rn+1)
                return()
            endif
        endif
    endloop

    // end of file has been reached

    SyncLines(rn)
    ln = NumLines() - CurrLine()
    GotoWindow(2)
    rn = NumLines() - CurrLine()
    GotoWindow(1)

    Alarm()
    if ln > 0
        Message("Left file is longer than right file by ",ln," lines")
    elseif rn > 0
        Message("Right file is longer than left file by ",rn," lines")
    else
        Message("No more differences")
    endif
end

/****************************************************************************\
    display differences in current lines
\****************************************************************************/

string ruler1[54] = "    ....|...10....|...20....|...30....|...40....|...50"
string ruler2[54] = "    ....|...60....|...70....|...80....|...90....|..100"
string ruler3[54] = "    ....|..110....|..120....|..130....|..140....|..150"
string ruler4[54] = "    ....|..160....|..170....|..180....|..190....|..200"
string ruler5[54] = "    ....|..210....|..220....|..230....|..240....|..250"

keydef ListKeys
    <CursorUp>      if not Up(6) Down(5) endif
    <CursorDown>    if not Down(6) Up() endif
    <Enter>         EndProcess(TRUE)
    <Escape>        EndProcess(FALSE)
    <LeftBtn>       EndProcess(TRUE)
    <RightBtn>      EndProcess(FALSE)
end

proc ListHook()
    Enable(ListKeys,_EXCLUSIVE_)
    ListFooter(" {Enter}-Continue {Escape}-Return ")
end

proc CompLines()
    constant WIDTH = 50
    integer c, r
    integer ln, rn
    string lt[250]
    string rt[250]

    // get current lines and switch to work buffer

    UnmarkBlock()
    ln = CurrLine()
    lt = GetText(1,CurrLineLen())
    GotoWindow(2)
    rn = CurrLine()
    rt = GetText(1,CurrLineLen())
    GotoWindow(1)
    GotoBufferId(temp)

    // format lines and display work buffer

    r = 0
    while Length(lt) or Length(rt)

        // add ruler

        r = r + 1
        AddLine()
        case r
            when 1  AddLine(ruler1)
            when 2  AddLine(ruler2)
            when 3  AddLine(ruler3)
            when 4  AddLine(ruler4)
            when 5  AddLine(ruler5)
        endcase

        // add formatted lines

        AddLine()
        AddLine(Format(" l  ",lt[1:WIDTH]:-WIDTH:" "))
        AddLine(Format(" r  ",rt[1:WIDTH]:-WIDTH:" "))

        // add markers showing differences

        AddLine()
        GotoColumn(5)
        c = 0
        while c < WIDTH and ( c < Length(lt) or c < Length(rt) )
            c = c + 1
            if c > Length(lt) or c > Length(rt) or lt[c] <> rt[c]
                InsertText("^")
            else
                Right()
            endif
        endwhile

        // skip displayed parts of strings

        lt = lt[WIDTH+1:250]
        rt = rt[WIDTH+1:250]
    endwhile

    // show formatted lines in scrolling list

    AddLine()
    lFind("^","g")
    Hook(_LIST_STARTUP_,ListHook)
    if List("Differences in lines "+Str(ln)+" and "+Str(rn),WIDTH+6)
        PushKey(<Enter>)
    endif
    Unhook(ListHook)

    // flush work buffer and return

    EmptyBuffer()
    GotoBufferId(buff1)
end

/****************************************************************************\
    exit routines
\****************************************************************************/

menu QueryEditFiles()
    "&Flush Both Files",,,
        "Quit both files"
    "",,    divide
    "Edit &Left File",,,
        "Edit file (left window)"
    "Edit &Right File",,,
        "Edit file (right window)"
    "Edit &Both Files",,,
        "Edit both files"
end

integer proc QuerySaveFile()
    integer RC

    if FileChanged()
        Alarm()
        RC = MsgBox("Warning",
            SplitPath(CurrFilename(),_NAME_|_EXT_) + Chr(13) + "has been changed! Save now?",
            _YES_NO_CANCEL_)
        case RC
            when 1      SaveFile()
            when 2      //NO = NOP
            otherwise   return(TRUE)
        endcase
    endif
    return(FALSE)
end

proc ExitProc()
    integer rc

    QueryEditFiles()
    code = MenuOption()
    if code == 0                        // resume comparing (escape)
        return()
    endif
    if not (code in 3,5)                // neither EditLeft nor EditBoth
        if QuerySaveFile()
            return()
        endif
    endif
    if not (code in 4,5)                // neither EditRight nor EditBoth
        GotoWindow(2)
        rc = QuerySaveFile()
        GotoWindow(1)
        if rc
            return()
        endif
    endif
    EndProcess()
end

/****************************************************************************\
    help system
\****************************************************************************/

proc AboutBox()
    MsgBox("About DlgComp", banner1 + Chr(13) + banner2, _OK_)
end

helpdef MainHelp
    title = "Help on Comparing Text Files"
    width = 70
    height = 19
    x = 2
    y = 3

    ""
    " General remarks"
    " ---------------"
    ""
    " Basic Movement"
    "   The highlight is moved using the cursor keys (ck)."
    "       <ck>        move left window"
    "       <alt ck>    move both windows"
    "       <ctrl ck>   move right window"
    ""
    " Synchronizing files"
    "   The searching commands can be used to skip over blocks of text,"
    "   which are only present in one of the files. A few basic editing"
    "   commands are included, which help to synchronize the files."
    ""
    ""
    " Key bindings and menu commands"
    " ------------------------------"
    ""
    " Help"
    "   F1              F10 H H     this help"
    "   -               F10 H I     info on file compare"
    ""
    " Movement"
    "   Up/Down         -           move up/down one line"
    "   PgUp/Down       -           move up/down one page"
    "   Home/End        -           go to beginning/end of list"
    "   Ctrl-B/Ctrl-E   -           go to beginning/end of marked block"
    ""
    " Comparing"
    "   Enter           F10 C C     continue comparison"
    "   Ctrl-Enter      F10 C R     restart from beginning of files"
    "   SpaceBar        F10 C D     show details of differences"
    "   -               F10 C F     enter characters to ignore"
    "   Tab             -           toggle horizontal/vertical split"
    ""
    " Searching"
    "   Alt-F           F10 S F     search for text"
    "   Alt-L           F10 S L     search for block (left window)"
    "   Alt-R           F10 S R     search for block (right window)"
    "   Alt-U           F10 S U     unmark block and go back"
    ""
    " Synchronizing"
    "   Alt-D           F10 E D     delete currently marked block"
    "   Ctrl-D          F10 E T     delete one of the current lines"
    "   Alt-C           F10 E C     copy marked block to other window"
    "   Ctrl-L          F10 E C     update left line"
    "   Ctrl-R          F10 E C     update right line"
    ""
    " Miscellaneous"
    "   F10             -           activate menu"
    "   Escape          F10 F E     exit file compare"
    ""
end

/****************************************************************************\
    menu system
\****************************************************************************/

menu CompMenu()
    "&Compare",
        Compare(FALSE),,
        "Continue comparing files"
    "&Restart",
        Compare(TRUE),,
        "Restart file comparison at beginning of files"
    "&Differences...",
        CompLines(),,
        "Display window detailing differences of current lines"
    "",,    divide
    "&Filter...",
        Ask("Enter characters to ignore:",filter),
        DontClose,
        "Enter characters to ignore while comparing files"
    "",,    divide
    "&Exit DlgComp   ",
        ExitProc(),
        DontClose,
        "Quit file compare"
end

menu EditMenu()
    "&Delete Block",
        DeleteBlock(),,
        "Delete currently marked block"
    "Dele&te Line     ",
        DeleteLine(),
        DontClose,
        "Delete one of the current lines"
    "",,    divide
    "&Copy Block",
        CopyMissingBlock(),,
        "Synchronize (copy marked block to other window)"
    "",,    divide
    "Update &Left Line",
        UpdateLine(TRUE),,
        "Synchronize (update left line with contents of right line)"
    "Update &Right Line",
        UpdateLine(FALSE),,
        "Synchronize (update right line with contents of left line)"
end

menu SearchMenu()
    "&Find Text       ",
        SearchText(),
        DontClose,
        "Search for text"
    "",,    divide
    "&Left Window",
        SearchLine(TRUE),,
        "Search for inserted block (left window)"
    "&Right Window",
        SearchLine(FALSE),,
        "Search for inserted block (right window)"
    "",,    divide
    "&Undo Block Search",
        UndoSearch(),,
        "Undo last search (unmarks block and goes back to previous line)"
end

menu HelpMenu()
    "&Help",
        QuickHelp(MainHelp),,
        "Display help on key bindings"
    "",,    divide
    "&About...",
        AboutBox(),,
        "Display copyright info"
end

menubar MainMenu()
    "&Compare", CompMenu()
    "&Edit",    EditMenu()
    "&Search",  SearchMenu()
    "&Help",    HelpMenu()
end

/****************************************************************************\
    keyboard bindings
\****************************************************************************/

keydef CompKeys
    <HelpLine>        "Comparing: {}-LeftWin {Enter}-Continue {SpaceBar}-Details {Tab}-ToggleScreen {F10}-Menu"
    <Alt HelpLine>    "Comparing: {}-BothWins {F}-Find {LR}-FindBlock {U}-UndoFind {D}-DelBlock {C}-CopyBlock"
    <Ctrl HelpLine>   "Comparing: {}-RightWin {Enter}-Restart {BE}-Beg/EndBlock {LR}-UpdateLine {D}-DeleteLine"
    <Shift HelpLine>  "Comparing: "

    <Escape>                    ExitProc()

    <F1>                        QuickHelp(MainHelp)
    <F10>                       MainMenu()

    <Tab>                       SplitScreen()
    <SpaceBar>                  CompLines()
    <Enter>                     Compare(FALSE)
    <Ctrl Enter>                Compare(TRUE)

    <Alt F>                     SearchText()
    <Alt L>                     SearchLine(TRUE)
    <Alt R>                     SearchLine(FALSE)
    <Alt U>                     UndoSearch()
    <Alt C>                     CopyMissingBlock()
    <Alt D>                     DeleteBlock()

    <Ctrl L>                    UpdateLine(TRUE)
    <Ctrl R>                    UpdateLine(FALSE)
    <Ctrl D>                    DeleteLine()

    <Ctrl B>                    BegBlock()
    <Ctrl E>                    EndBlock()
    <CursorUp>                  LeftRollUp(1)
    <CursorDown>                LeftRollDown(1)
    <Ctrl CursorUp>             RightRollUp(1)
    <Ctrl CursorDown>           RightRollDown(1)
    <Alt CursorUp>              LeftRollUp(1)   RightRollUp(1)
    <Alt CursorDown>            LeftRollDown(1) RightRollDown(1)

    <PgUp>                      LeftRollUp(roll)
    <PgDn>                      LeftRollDown(roll)
    <Ctrl PgUp>                 RightRollUp(roll)
    <Ctrl PgDn>                 RightRollDown(roll)
    <Alt PgUp>                  LeftRollUp(roll)   RightRollUp(roll)
    <Alt PgDn>                  LeftRollDown(roll) RightRollDown(roll)

    <Home>                      BegFile()
    <End>                       EndFile()
    <Ctrl Home>                 RightBegFile()
    <Ctrl End>                  RightEndFile()
    <Alt Home>                  BegFile() RightBegFile()
    <Alt End>                   EndFile() RightEndFile()
end

/****************************************************************************\
    adapt editor environment
\****************************************************************************/

proc InitEnv()
    Set(Cursor,OFF)
    Set(StatusLineUpdating,ON)
    fcEquateEnhancedKbd = Set(EquateEnhancedKbd,ON)
    fcInsertLineBlocksAbove = Set(InsertLineBlocksAbove,ON)
    fcExpandTabs = Set(ExpandTabs,ON)
    fcTabWidth = Set(TabWidth,8)
    fcTabType = Set(TabType,_HARD_)
    fcShowEOFMarker = Set(ShowEOFMarker,ON)
    fcTextAttr = Set(TextAttr,clr_comp_text)
    fcBlockAttr = Set(BlockAttr,clr_comp_block)
    fcCursorAttr = Set(CursorAttr,clr_comp_cursor)
    fcCurrWinBorderAttr = Set(CurrWinBorderAttr,clr_comp_curr)
    fcOtherWinBorderAttr = Set(OtherWinBorderAttr,clr_comp_text)
    fcMsgAttr = Set(MsgAttr,clr_comp_menu)
    fcHelpTextAttr = Set(HelpTextAttr,clr_comp_menu)
    fcMenuTextAttr = Set(MenuTextAttr,clr_comp_menu)
    fcMenuTextLtrAttr = Set(MenuTextLtrAttr,clr_comp_hotkey)
    fcMenuSelectAttr = Set(MenuSelectAttr,clr_comp_select)
    fcMenuSelectLtrAttr = Set(MenuSelectLtrAttr,clr_comp_selkey)
    fcMenuBorderAttr = Set(MenuBorderAttr,clr_comp_menu)
    fcShowSyntaxHilite = Set(ShowSyntaxHilite,OFF)
end

proc DoneEnv()
    Set(Cursor,ON)
    Set(EquateEnhancedKbd,fcEquateEnhancedKbd)
    Set(InsertLineBlocksAbove,fcInsertLineBlocksAbove)
    Set(ExpandTabs,fcExpandTabs)
    Set(TabWidth,fcTabWidth)
    Set(TabType,fcTabType)
    Set(ShowEOFMarker,fcShowEOFMarker)
    Set(TextAttr,fcTextAttr)
    Set(BlockAttr,fcBlockAttr)
    Set(CursorAttr,fcCursorAttr)
    Set(CurrWinBorderAttr,fcCurrWinBorderAttr)
    Set(OtherWinBorderAttr,fcOtherWinBorderAttr)
    Set(MsgAttr,fcMsgAttr)
    Set(HelpTextAttr,fcHelpTextAttr)
    Set(MenuTextAttr,fcMenuTextAttr)
    Set(MenuTextLtrAttr,fcMenuTextLtrAttr)
    Set(MenuSelectAttr,fcMenuSelectAttr)
    Set(MenuSelectLtrAttr,fcMenuSelectLtrAttr)
    Set(MenuBorderAttr,fcMenuBorderAttr)
    Set(ShowSyntaxHilite,fcShowSyntaxHilite)
end

/****************************************************************************\
    initialization
\****************************************************************************/

integer proc GetCmdLine()
    integer cmp_hist1, cmp_hist2

    cmp_hist1 = GetFreeHistory("DlgComp:FileName1")
    cmp_hist2 = GetFreeHistory("DlgComp:FileName2")

    name1 = GetHistoryStr(cmp_hist1,1)
    name2 = GetHistoryStr(cmp_hist2,1)

    if name1 == "" or name2 == ""
        ErrorMsg("Invalid command line argument(s)")
        return (FALSE)
    endif
    if name1 == name2
        ErrorMsg("Filenames are identical")
        return (FALSE)
    endif
    if not (FileExists(name1) and FileExists(name2))
        ErrorMsg("File(s) do not exist")
        return (FALSE)
    endif
    return (TRUE)
end

integer proc InitBuffers()
    PushPosition()
    temp = CreateTempBuffer()
    if not temp
        ErrorMsg("Cannot allocate work space")
        return (FALSE)
    endif
    load1 = GetBufferId(name1)
    load2 = GetBufferId(name2)
    buff1 = EditFile(QuotePath(name1))
    buff2 = EditFile(QuotePath(name2))
    if not (buff1 and buff2)
        ErrorMsg("Cannot load file(s)")
        return (FALSE)
    endif
    return (TRUE)
end

/****************************************************************************\
    shutdown
\****************************************************************************/

proc DoneBuffers()
    case code
        when 1                                  // flush both
            OneWindow()
            PopPosition()
        when 3                                  // edit left
            OneWindow()
            KillPosition()
            load1 = buff1
            GotoBufferId(buff1)
        when 4                                  // edit right
            OneWindow()
            KillPosition()
            load2 = buff2
            GotoBufferId(buff2)
        when 5                                  // edit both
            KillPosition()
            load1 = buff1
            load2 = buff2
    endcase
    if buff1 <> load1
        AbandonFile(buff1)
    endif
    if buff2 <> load2
        AbandonFile(buff2)
    endif
    AbandonFile(temp)
end

/****************************************************************************\
    compare function
\****************************************************************************/

proc CompareFiles()
    UpdateDisplay(_STATUSLINE_REFRESH_)
    UpdateDisplay()
    roll = (Query(ScreenRows) - 5) / 2
    SplitScreen()
    Compare(TRUE)
    if Enable(CompKeys,_EXCLUSIVE_)
        Process()
        Disable(CompKeys)
    endif
end

/****************************************************************************\
    main function
\****************************************************************************/

proc main()
    Message(banner1 + " " + banner2)
    if GetCmdLine() and InitBuffers()
        InitEnv()
        CompareFiles()
        DoneEnv()
    endif
    DoneBuffers()
    UpdateDisplay()
    PurgeMacro(CurrMacroFilename())
end

