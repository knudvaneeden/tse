/****************************************************************************\

    TSEComp.S

    Compares two text files interactively.

    Overview:

    Compare prompts the user for two filenames, loads the two files,
    if necessary, and starts comparing them. If a pair of non matching
    lines is found, it stops and highlights these lines. The user now
    can make a detailed comparison of the lines, adjust the file
    position in either or both files or just continue comparing.

    Keys:       (none)

    Usage notes:

    The key assignment when Compare stops at a mismatch is displayed
    at the help line. Depress the Ctrl or Alt keys to see more
    commands. Compare can be interrupted anytime by pressing Escape.

    Version         v2.00/28.04.95
    Copyright       (c) 1994,95 by DiK

    History
    v2.00/28.04.95  interface to TSEFile, Menu & Help
    v1.11/25.11.94  bug-fix
    v1.10/26.10.94  adaption to v2.0 of TSE
    v1.00/26.01.94  primary release

\****************************************************************************/

#include ["fnprompt.src"]

/****************************************************************************\
  ú constants
\****************************************************************************/

constant    CC_TEXT     = Color( bright cyan on blue ),     // listing
            CC_CURR     = Color( bright white on blue ),
            CC_CURSOR   = Color( black on green ),
            CC_BLOCK    = Color( white on blue ),           // editing
            CC_MENU     = Color( black on white ),          // main menu
            CC_HOTKEY   = Color( red on white ),
            CC_SELECT   = Color( black on green ),
            CC_SELKEY   = Color( red on green ),
            CC_INFO     = Color( black on white )           // boxes

/****************************************************************************\
  ú constant strings
\****************************************************************************/

string  banner[] = "TSE File Compare 2.0 (c) 1994,95 by DiK"

/****************************************************************************\
  ú session global variables
\****************************************************************************/

string  switch[] = "TSEF3-switch"
string  target[] = "TSEF3-target"

/****************************************************************************\
  ú global variables
\****************************************************************************/

integer TSEF                            // called by TSEFile
integer vert                            // vertical split screen
integer roll                            // lines for page roll
integer both                            // edit both files
integer file, temp                      // buffer id's
integer lbuff, rbuff                    // dito
integer lkeep, rkeep                    // dito
string  filter[64]                      // ignored characters
string  lname[128]                      // filename
string  rname[128]                      // dito

/****************************************************************************\
  ú Editor environment changes
\****************************************************************************/

integer fcInsertLineBlocksAbove,
        fcExpandTabs,
        fcTabWidth,
        fcTabType,
        fcShowEOFMarker,
        fcTextAttr,
        fcCursorAttr,
        fcCurrWinBorderAttr,
        fcOtherWinBorderAttr,
        fcMenuTextAttr,
        fcMenuTextLtrAttr,
        fcMenuSelectAttr,
        fcMenuSelectLtrAttr,
        fcMenuBorderAttr

/****************************************************************************\
  ú helper macros
\****************************************************************************/

proc SyncLines( integer rn )
    GotoWindow(2)
    if rn
        GotoLine(rn)
    endif
    ScrollToRow(Query(WindowRows)/2)
    GotoWindow(1)
    ScrollToRow(Query(WindowRows)/2)
end

proc SplitScreen()
    vert = not vert
    OneWindow()
    if vert
        VWindow()
    else
        HWindow()
    endif
    GotoBufferId(rbuff)
    GotoWindow(1)
    GotoBufferId(lbuff)
    SyncLines(0)
end

/****************************************************************************\
  ú left side movement
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
  ú right side movement
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
  ú beginning/end of block
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
  ú basic searching
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
  ú line commands
\****************************************************************************/

menu DelLineMenu()
    "&Left Line",,,
        "Delete the current line (left window)"
    "&Right Line",,,
        "Delete the current line (right window)"
end

proc UpdateLine( integer leftwin )
    string ll[254]

    if leftwin
        GotoWindow(2)
    endif
    ll = GetText(1,254)
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
  ú block commands
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
  ú compare filtered lines
\****************************************************************************/

proc FilterLine ( var string nl, string ol )
    AddLine(ol)
    lReplace("["+filter+"]","","gnx")
    nl = GetText(1,254)
    EmptyBuffer()
end

integer proc DiffLines( string l1, string l2 )
    string nl1[254] = ""
    string nl2[254] = ""

    if Length(filter)
        GotoBufferId(temp)
        FilterLine(nl1,l1)
        FilterLine(nl2,l2)
        GotoBufferId(rbuff)
        return ( nl1 <> nl2 )
    endif
    return (TRUE)
end

/****************************************************************************\
  ú search routine
\****************************************************************************/

proc SearchLine( integer leftwin )
    string ll[254]

    // get line and switch windows

    if leftwin
        GotoWindow(2)
    endif
    ll = GetText(1,254)
    NextWindow()

    // search the line

    MarkLine()
    while Down()
        if ll == GetText(1,254) or not DiffLines(ll,GetText(1,254))
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
  ú compare routine
\****************************************************************************/

proc Compare( integer start )
    integer dn
    integer ln, rn
    string ll[254]

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
            GotoBufferId(rbuff)
            rn = CurrLine()
            dn = Down()
            GotoBufferId(lbuff)
            if not dn
                Up()
            endif
        endif
        if not dn
            Alarm()
            Warn("Cannot scan beyond this point")
            return ()
        endif
    endif

    // compare files one line at a time

    loop
        ln = ln + 1
        rn = rn + 1

        // compare lines

        ll = GetText(1,254)
        GotoBufferId(rbuff)
        if ll <> GetText(1,254) and DiffLines(ll,GetText(1,254))
            GotoBufferId(lbuff)
            Message("Differences in lines ",ln," and ",rn)
            SyncLines(rn)
            return()
        endif

        // advance to next lines

        dn = Down()
        GotoBufferId(lbuff)
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
  ú display differences in current lines
\****************************************************************************/

string ruler1[54] = "    ....þ...10....þ...20....þ...30....þ...40....þ...50"
string ruler2[54] = "    ....þ...60....þ...70....þ...80....þ...90....þ..100"
string ruler3[54] = "    ....þ..110....þ..120....þ..130....þ..140....þ..150"
string ruler4[54] = "    ....þ..160....þ..170....þ..180....þ..190....þ..200"
string ruler5[54] = "    ....þ..210....þ..220....þ..230....þ..240....þ..250"

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
    WindowFooter(" {Enter}-Continue {Escape}-Return ")
end

proc CompLines()
    constant WIDTH = 50
    integer c, r
    integer ln, rn
    string lt[250]
    string rt[250]
    string disp[WIDTH]

    // get current lines and switch to work buffer

    UnmarkBlock()
    ln = CurrLine()
    lt = GetText(1,250)
    GotoWindow(2)
    rn = CurrLine()
    rt = GetText(1,250)
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
        disp = SubStr(lt,1,WIDTH)
        AddLine(Format(" l  ",disp:-WIDTH:"°"))
        disp = SubStr(rt,1,WIDTH)
        AddLine(Format(" r  ",disp:-WIDTH:"°"))

        // add markers showing differences

        AddLine()
        GotoColumn(5)
        c = 0
        while c < WIDTH and ( c < Length(lt) or c < Length(rt) )
            c = c + 1
            if c > Length(lt) or c > Length(rt) or lt[c] <> rt[c]
                InsertText("")
            else
                Right()
            endif
        endwhile

        // remove already shown parts from strings

        lt = SubStr(lt,WIDTH+1,250)
        rt = SubStr(rt,WIDTH+1,250)
    endwhile

    // show fomratted lines in scrolling list

    AddLine()
    lFind("","g")
    Hook(_LIST_STARTUP_,ListHook)
    if List("Differences in lines "+Str(ln)+" and "+Str(rn),WIDTH+6)
        PushKey(<Enter>)
    endif
    Unhook(ListHook)

    // flush work buffer and return

    EmptyBuffer()
    GotoBufferId(lbuff)
end

/****************************************************************************\
  ú exit routines
\****************************************************************************/

proc EditLeftFile()
    file = lbuff
    lkeep = lbuff
    BegFile()
end

proc EditRightFile()
    file = rbuff
    rkeep = rbuff
    GotoWindow(2)
    BegFile()
end

proc EditBothFiles()
    both = TRUE
    file = lbuff
    lkeep = lbuff
    rkeep = rbuff
    GotoWindow(2)
    BegFile()
    GotoWindow(1)
    BegFile()
end

menu QueryEditFiles()
    "&Flush Both Files",,,
        "Quit both files"
    "",,    divide
    "Edit &Left File",
        EditLeftFile(),,
        "Edit file (left window)"
    "Edit &Right File",
        EditRightFile(),,
        "Edit file (right window)"
    "Edit &Both Files",
        EditBothFiles(),,
        "Edit both files"
end

integer proc QuerySaveFile()
    if FileChanged()
        Message("File ",
            SplitPath(CurrFilename(),_NAME_|_EXT_),
            " has been changed! Save now?")
        Alarm()
        case YesNo("Save File?")
            when 0,3
                return(TRUE)
            when 1
                SaveFile()
        endcase
    endif
    return(FALSE)
end

proc ExitProc()
    integer rc

    QueryEditFiles()
    rc = MenuOption()
    if rc == 0
        return()
    endif
    if TSEF
        if rc <> 1
            SetGlobalInt(switch,file)
        endif
    endif
    if rc <> 3 and rc <> 5
        if QuerySaveFile()
            return()
        endif
    endif
    if rc < 4
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
  ú help system
\****************************************************************************/

proc AboutBox()
    if PopWinOpen(16,8,65,16,1,"About File Compare",CC_INFO)
        Set(Cursor,OFF)
        Set(Attr,CC_INFO)
        ClrScr()
        VGotoXY(6,4)
        PutStr(banner)
        GetKey()
        PopWinClose()
    endif
    Set(Cursor,ON)
end

helpdef MainHelp
    title = "Help on File Compare"
    x = 5
    y = 3
    width = 70
    height = 19

    ""
    " General remarks"
    " ---------------"
    ""
    " Basic Movement"
    "   The highlight is moved using the cursor keys (ck)."
    "       <ck>        move left window"
    "       <ctrl ck>   move right window"
    "       <alt ck>    move both windows"
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
    "   Ctrl-Enter      F10 C R     restart from beginning of files"
    "   Enter           F10 C C     continue comparison"
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
  ú menu system
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
    "&Exit TSEComp   ",
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
  ú keyboard bindings
\****************************************************************************/

keydef CompKeys
    <HelpLine>        "Comparing: {}-LeftWin {Enter}-Continue {Space}-Details {Tab}-ToggleScreen {F10}-Menu"
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
    <Alt GreyCursorUp>          LeftRollUp(1)   RightRollUp(1)
    <Alt GreyCursorDown>        LeftRollDown(1) RightRollDown(1)

    <PgUp>                      LeftRollUp(roll)
    <PgDn>                      LeftRollDown(roll)
    <Ctrl PgUp>                 RightRollUp(roll)
    <Ctrl PgDn>                 RightRollDown(roll)
    <Alt GreyPgUp>              LeftRollUp(roll)   RightRollUp(roll)
    <Alt GreyPgDn>              LeftRollDown(roll) RightRollDown(roll)

    <Home>                      BegFile()
    <End>                       EndFile()
    <Ctrl Home>                 RightBegFile()
    <Ctrl End>                  RightEndFile()
    <Alt GreyHome>              BegFile() RightBegFile()
    <Alt GreyEnd>               EndFile() RightEndFile()
end

/****************************************************************************\
  ú external interface
\****************************************************************************/

public proc TC_SetFirstName()
    TSEF = TRUE
    SetGlobalInt(switch,0)
    lname = GetGlobalStr(target)
    lkeep = GetBufferId(ExpandPath(lname))
end

public proc TC_SetLeftName()
    lname = GetGlobalStr(target)
    lkeep = FALSE
end

public proc TC_SetRightName()
    rname = GetGlobalStr(target)
    rkeep = FALSE
end

/****************************************************************************\
  ú command hook

    This one is necessary, to check out from the TSEFile command hook.
\****************************************************************************/

proc CommandHook()
    BreakHookChain()
end

/****************************************************************************\
  ú main function
\****************************************************************************/

proc main()

    // change environment

    Set(Cursor,OFF)
    Set(StatusLineUpdating,ON)
    fcInsertLineBlocksAbove = Set(InsertLineBlocksAbove,ON)
    fcExpandTabs = Set(ExpandTabs,ON)
    fcTabWidth = Set(TabWidth,8)
    fcTabType = Set(TabType,_HARD_)
    fcShowEOFMarker = Set(ShowEOFMarker,ON)
    fcTextAttr = Set(TextAttr,CC_TEXT)
    fcCursorAttr = Set(CursorAttr,CC_CURSOR)
    fcCurrWinBorderAttr = Set(CurrWinBorderAttr,CC_CURR)
    fcOtherWinBorderAttr = Set(OtherWinBorderAttr,CC_TEXT)
    fcMenuTextAttr = Set(MenuTextAttr,CC_MENU)
    fcMenuTextLtrAttr = Set(MenuTextLtrAttr,CC_HOTKEY)
    fcMenuSelectAttr = Set(MenuSelectAttr,CC_SELECT)
    fcMenuSelectLtrAttr = Set(MenuSelectLtrAttr,CC_SELKEY)
    fcMenuBorderAttr = Set(MenuBorderAttr,CC_MENU)

    // get filenames and load files

    PushPosition()
    BegLine()
    ScrollToRow(1)
    file = GetBufferId()
    roll = (Query(ScreenRows) - 5) / 2

    Message(banner)
    if Length(lname) == 0
        lname = CurrFilename()
        if not FilePrompt(lname,"Enter name of first file:","",ON)
            goto done
        endif
        lkeep = GetBufferId(ExpandPath(lname))
    endif
    lbuff = EditFile(lname)

    Message(banner)
    if Length(rname) == 0
        rname = CurrFilename()
        if not FilePrompt(rname,"Enter name of second file:","",ON)
            goto done
        endif
        rkeep = GetBufferId(ExpandPath(rname))
    endif
    rbuff = EditFile(rname)

    if ExpandPath(lname) == ExpandPath(rname)
        Alarm()
        Warn("Filenames are identical")
        goto done
    endif

    // compare files

    temp = CreateTempBuffer()
    UpdateDisplay()
    UpdateDisplay(_STATUSLINE_REFRESH_)
    SplitScreen()
    Compare(TRUE)
    if Enable(CompKeys,_EXCLUSIVE_)
        Hook(_AFTER_COMMAND_,CommandHook)
        Process()
        UnHook(CommandHook)
        Disable(CompKeys)
    endif
    AbandonFile(temp)

done:

    // restore environment

    Set(Cursor,ON)
    Set(InsertLineBlocksAbove,fcInsertLineBlocksAbove)
    Set(ExpandTabs,fcExpandTabs)
    Set(TabWidth,fcTabWidth)
    Set(TabType,fcTabType)
    Set(ShowEOFMarker,fcShowEOFMarker)
    Set(TextAttr,fcTextAttr)
    Set(CursorAttr,fcCursorAttr)
    Set(CurrWinBorderAttr,fcCurrWinBorderAttr)
    Set(OtherWinBorderAttr,fcOtherWinBorderAttr)
    Set(MenuTextAttr,fcMenuTextAttr)
    Set(MenuTextLtrAttr,fcMenuTextLtrAttr)
    Set(MenuSelectAttr,fcMenuSelectAttr)
    Set(MenuSelectLtrAttr,fcMenuSelectLtrAttr)
    Set(MenuBorderAttr,fcMenuBorderAttr)

    // cleanup

    if lbuff <> lkeep  AbandonFile(lbuff)  endif
    if rbuff <> rkeep  AbandonFile(rbuff)  endif
    if not both
        OneWindow()
        GotoBufferId(file)
    endif
    PopPosition()
    UpdateDisplay()
    PurgeMacro(CurrMacroFilename())

end

