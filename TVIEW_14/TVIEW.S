/****************************************************************************
 *  FILENAME :  tview.s                                                     *
 *  VERSION  :  1.4 (for TSE 2.00)                                           *
 *  AUTHOR   :  Ray Asbury (rasbury@msmailpc01.saic.com)                    *
 *  DATE     :  Fri 09-16-1994 10:55:28                                     *
 *  PURPOSE  :  Toggles between a read-only mode (similar to LIST.COM) and  *
 *              the normal edit mode.  When you execute TView, you are put  *
 *              into a view-only mode.  Pressing <F1> will pop up a help    *
 *              window, showing the key assignments.  From there things     *
 *              should be pretty straightforward.                           *
 *                                                                          *
 *              If you have any questions, comments, or bug reports, please *
 *              contact on Semware's BBS.                                   *
 *                                                                          *
 *  REVISIONS:  WHO DATE        DESCRIPTION                                 *
 *              --- --------    ------------------------------------------  *
 *              ERA 08-05-94    Currently forced to use standard Find and   *
 *                                  RepeatFind() due to lack of directional *
 *                                  argument (_FORWARD_ & _BACKWARD_)       *
 *                                  support                                 *
 *              ERA 08-10-94    Replaced PutStr with PutHelpLine() and      *
 *                                  added screen mode detection to the help *
 *                              Bumped version to "1.2"                     *
 *              ERA 09-04-94    Fix pnToggleWindows() to stay in the        *
 *                                  current file when creating the second   *
 *                                  window and not to prompt for "window    *
 *                                  edge to resize"                         *
 *                              Force one window on startup and shutdown    *
 *                              Bumped version to "1.3"                     *
 *              ERA 09-16-94    Re-compiled for TSE 2.00                    *
 *                              Bumped version to "1.4"                     *
 ****************************************************************************/

CONSTANT        koUSE_OWN_HISTORIES     = TRUE,
                koBOTTOM                = 1,
                koTOP                   = 2,
                koFORWARD               = 1,
                koBACKWARD              = 2,
                koNUM_HELP_SCREENS      = 2

INTEGER         fiBookMarkLastVisited   = 0,
                fiCenterFinds,
                fiCursorAttr,
                fiFindExecuted          = FALSE,
                fiMarking,
                fiPBLN_HISTORY_         = 0,
                fiFIND_HISTORY_         = 0

STRING          fsVersion[]             = "1.4"

FORWARD PROC    pnTextNotFound()
FORWARD PROC    piToggleToEditMode(INTEGER lpiStayAtCurrentLocation)
FORWARD PROC    pnWinFooterHelp()
FORWARD PROC    pnWinFooterList()

DATADEF ddReadKeys
""
"    FUNCTION KEYS            ALT- KEYS               ALT- KEYS"
""
"F1  Display Help        a-A  find text Again"
"F3  Find next text      a-B  mark Bottom line   a-T  Tabs on/off"
"F9  Find prev text      a-D  copy to file       a-U  Unmark lines"
"F10 Exit to TSE         a-E  toggle EGA 25/43   a-V  file select menu"
"/  Scan for exact text  a-F  get new Filespec   a-W  toggle windows"
"\  Find any case text   a-G  Goto DOS           a-X  exit, restore screen"
"                        a-H  toggle Hex mode    a-Y  recall bookmark"
"                        a-I  insert new file"
"                        a-M  Mark top line"
"Q  quit to next file    a-P  print marked       +/-/#   skip to line #"
"X  Exit to DOS, cls     a-P  print marked        1   display first file"
""
""
""
""
""
""
""
""
""
"             CONTROL KEYS               CURSOR KEYS"
""
"        c-A  scroll full left           Home   Top of file"
"        c-C  scroll down one page       End    Bottom of file"
"        c-D  scroll right 10            PgUp   scroll up one page"
"        c-E  scroll up one line         PgDn   scroll down one page"
"        c-F  printer form feed          Left   scroll left 10"
"                                        Right  scroll right 10"
"        c-I  define TAB interval        Down   scroll down one line"
"        c-L  show page separator        Up     scroll up one line"
"        c-M  scroll down one page"
"        c-N  display next file"
"        c-P  print entire file          c-Home   position by line number"
"        c-R  scroll up one page         c-PgUp   display previous file"
"        c-S  scroll left 10             c-PgDn   display next file"
"                                        c-Left   scroll full left"
"        c-U  display previous file      c-Right  scroll full right"
"        c-V  switch windows             c-W  scroll up one line"
"        c-X  scroll down one line"
"        c-Y  set bookmark"
"        c-Z  display previous file"
""
END ddReadKeys

PROC pnAdjustHelpScreens()

    INTEGER liCnt,
            liLinesToAdd        = Query(ScreenRows) - 25,
            liNumHelpScreens    = koNUM_HELP_SCREENS

    WHILE (liNumHelpScreens)
        Down(22)
        liCnt = 0
        WHILE (liCnt < liLinesToAdd)
            AddLine("")
            liCnt = liCnt + 1
        ENDWHILE
        liNumHelpScreens = liNumHelpScreens - 1
    ENDWHILE
    BegFile()
END pnAdjustHelpScreens

PROC pnAssignHistories()

    INTEGER liAssignmentFailed = TRUE

    IF (koUSE_OWN_HISTORIES)
        fiPBLN_HISTORY_ = GetFreeHistory()
        IF (fiPBLN_HISTORY_)
            fiFIND_HISTORY_ = GetFreeHistory()
            IF (fiFIND_HISTORY_)
                liAssignmentFailed = FALSE
            ELSE
                DelHistory(fiPBLN_HISTORY_)
            ENDIF
        ENDIF
    ENDIF
    IF ( (NOT koUSE_OWN_HISTORIES) OR (liAssignmentFailed) )
        Warn("Unable to assign histories - reverting to standard histories")
        fiPBLN_HISTORY_ = _GOTOLINE_HISTORY_
        fiFIND_HISTORY_ = _FIND_HISTORY_
    ENDIF
END pnAssignHistories

PROC pnDefineTABInterval()

    STRING lsNbr[10] = ""

    INTEGER liNbr = Query(TabWidth)

    Set(Cursor, ON)
    IF (Ask("Tab Interval ", lsNbr)) AND (Length(lsNbr))
        liNbr = Val(lsNbr)
        Set(TabWidth, liNbr)
    ENDIF
    Set(Cursor, OFF)
END pnDefineTABInterval

PROC pnDisplayFirstFile()

    INTEGER liCid = GetBufferID(),
            liFirstId = MAXINT

    REPEAT
        IF (GetBufferID() < liFirstId)
            liFirstId = GetBufferID()
        ENDIF
        NextFile()
    UNTIL (liCid == GetBufferID())
    GotoBufferID(liFirstId)
END pnDisplayFirstFile

PROC pnEditFile()
    Set(Cursor, ON)
    EditFile()
    Set(Cursor, OFF)
END pnEditFile

PROC pnFileSelectMenu()
    Set(Cursor, ON)
    EditFile(PickFile("*.*"))
    Set(Cursor, OFF)
END pnFileSelectMenu

PROC pnFind(INTEGER lpiCaseSensitive)

    STRING  lsOpts[2]   = "",
            lsPrompt[5] = "",
            lsStr[80]   = ""

    IF (lpiCaseSensitive)
        lsPrompt = "Scan"
    ELSE
        lsPrompt = "Find"
        lsOpts = "i"
    ENDIF
    Set(Cursor, ON)
    IF (Ask(lsPrompt, lsStr, fiFIND_HISTORY_) AND Length(lsStr))
        IF (Find(lsStr, lsOpts))
            HiLiteFoundText()
            fiFindExecuted = TRUE
        ELSE
            pnTextNotFound()
        ENDIF
    ENDIF
    Set(Cursor, OFF)
END pnFind

PROC pnFindAnyCaseText()
    pnFind(FALSE)
END pnFindAnyCaseText

STRING PROC psFindFile(string lpsPcFName)

    STRING  lsNewFName[76],
            lsFPath[76],
            lsIncPath[128]

    INTEGER liPos

    PushPosition()

    IF (NOT FileExists(lpsPcFName) AND LFind("#lsIncPath", "CIG"))
        lsIncPath = GetEnvStr("lsIncPath")
        liPos     = Pos(';', lsIncPath)
        lsNewFName = "\" + lpsPcFName
        IF (liPos)
            WHILE (liPos > 0)
                lsFPath = SubStr(lsIncPath, 1, liPos - 1) + lsNewFName
                IF (FileExists(lsFPath))
                    BREAK
                ENDIF

                lsIncPath = SubStr(lsIncPath, liPos + 1,
                                    Length(lsIncPath) - liPos)
                liPos        = Pos(';', lsIncPath)
            ENDWHILE
            lsNewFName = lsFPath
        ELSE
            // there is no ';' in the lsIncPath environment variable
            lsNewFName = lsIncPath + lpsPcFName
        ENDIF
    ELSE
        lsNewFName = lpsPcFName
    ENDIF
    PopPosition()
    Return(lsNewFName)
END psFindFile

PROC pnFindNextText()
    IF (NOT fiFindExecuted)
        pnFind(FALSE)
    ELSEIF (RepeatFind(_FORWARD_))
        HiLiteFoundText()
    ELSE
        pnTextNotFound()
    ENDIF
END pnFindNextText

PROC pnFindPrevText()
    IF (NOT fiFindExecuted)
        pnFind(FALSE)
    ELSEIF (RepeatFind(_BACKWARD_))
        HiLiteFoundText()
    ELSE
        pnTextNotFound()
    ENDIF
END pnFindPrevText

PROC pnFindTextAgain()
    IF (NOT fiFindExecuted)
        pnFind(FALSE)
    ELSEIF (RepeatFind(_FORWARD_))
        HiLiteFoundText()
    ELSE
        BegFile()
        IF (RepeatFind(_FORWARD_))
            HiLiteFoundText()
        ELSE
            pnTextNotFound()
        ENDIF
    ENDIF
END pnFindTextAgain

STRING PROC psGetWordAtCursor()

    STRING  lsWord[80] = ''

    PushPosition()
    PushBlock()                     // Save current block status
    IF MarkWord() OR (Left() AND MarkWord())   // Mark the lsWord
        lsWord = GetMarkedText()      // Get it
    ENDIF
    PopBlock()                      // Restore block status
    PopPosition()
    Return (lsWord)                   // Thats all, folks!
END psGetWordAtCursor

proc pnInsertNewFile()

    STRING  fileName[76],
            savit[ 32]

    // set wordset to valid filename characters
    savit = set(wordset, chrset("a-zA-Z0-9_!\#\$%&`\-\./\\{}~:"))

    // psGetWordAtCursor() is supplied in tse.s
    fileName = psGetWordAtCursor()
    set(wordset, savit)                 // Restore old
    UnMarkBlock()
    editFile(psFindFile(fileName))
end pnInsertNewFile

PROC pnMarkLine(INTEGER lpiWhich)

    IF (lpiWhich == koTOP)
        BegWindow()
    ELSE
        EndWindow()
    ENDIF
    MarkLine()
    Set(Marking, OFF)
END pnMarkLine

PROC pnMarkLineBottom()
    pnMarkLine(koBOTTOM)
END pnMarkLineBottom

PROC pnMarkLineTop()
    pnMarkLine(koTOP)
END pnMarkLineTop

PROC pnOnChangingFiles()
    BreakHookChain()
END pnOnChangingFiles

PROC pnPositionByLineNumber()

    STRING lsNbr[10] = ""

    INTEGER liNbr

    Set(Cursor, ON)
    IF (Ask("Line #", lsNbr, fiPBLN_HISTORY_)) AND (Length(lsNbr))
        liNbr = Val(lsNbr)
        IF (NOT liNbr OR (liNbr > NumLines()))
            Message(Format("Please specify a line number between 1 and ",
                            Str(NumLines())))
        ELSE
            BegFile()
            GotoLine(liNbr)
        ENDIF
    ENDIF
    Set(Cursor, OFF)
END pnPositionByLineNumber

PROC pnPrinterFormFeed()
    IF (NOT PrintChar(Chr(12)))
        Message("Error sending formfeed")
    ENDIF
END pnPrinterFormFeed

PROC pnQuitToNextFile()

    INTEGER aid = GetBufferID()

    NextFile()
    AbandonFile(aid)
END pnQuitToNextFile

PROC pnSaveBlock()
    Set(Cursor, ON)
    SaveBlock()
    Set(Cursor, OFF)
END pnSaveBlock

PROC pnScanForExactText()
    pnFind(TRUE)
END pnScanForExactText

PROC pnShowHelp()
    INTEGER liCid               = GetBufferID(),
            liTid,
            liOldColor

    IF (IsBlockMarked() <> FALSE)
        PushBlock()
    ENDIF
    liTid = CreateTempBuffer()
    InsertData(ddReadKeys)
    pnAdjustHelpScreens()
    liOldColor = Set(MenuSelectAttr, Query(StatusLineAttr))//menuTextAttr))
    Hook(_LIST_STARTUP_, pnWinFooterHelp)
    LList("View Mode Keys", Query(ScreenCols), Query(ScreenRows),
            _ANCHOR_SEARCH_)
    UnHook(pnWinFooterHelp)
    Set(MenuSelectAttr, liOldColor)
    GotoBufferID(liCid)
    AbandonFile(liTid)
    PopBlock()
END pnShowHelp

PROC pnSkipToLine(INTEGER lpiWhichWay)

    STRING lsNbr[10] = ""

    INTEGER liNbr

    Set(Cursor, ON)
    IF (Ask("# lines", lsNbr)) AND (Length(lsNbr))
        liNbr = Val(lsNbr)
        IF (lpiWhichWay == koFORWARD)
            RollDown(liNbr)
        ELSE
            RollUp(liNbr)
        ENDIF
    ENDIF
    Set(Cursor, OFF)
END pnSkipToLine

PROC pnTabsOnOff()
    IF (Query(ExpandTabs) == ON)
        Set(ExpandTabs, OFF)
    ELSE
        Set(ExpandTabs, ON)
    ENDIF
END pnTabsOnOff

PROC pnTextNotFound()
    Message("Text not found")
END pnTextNotFound

PROC pnToggleEGA2543()
    CASE (Query(CurrVideoMode))
        WHEN _25_LINES_
            Set(CurrVideoMode, _43_LINES_)
        WHEN _43_LINES_
            Set(CurrVideoMode, _25_LINES_)
        OTHERWISE
            Set(CurrVideoMode, _25_LINES_)
    ENDCASE
END pnToggleEGA2543

PROC pnToggleHexMode()
    IF (DisplayMode() == _DISPLAY_TEXT_)
        DisplayMode(_DISPLAY_HEX_)
    ELSE
        DisplayMode(_DISPLAY_TEXT_)
    ENDIF
END pnToggleHexMode

PROC pnToggleWindows()

    INTEGER cid = GetBufferId()

    IF (NumWindows() == 1)
        PushKey(<CursorUp>)
        HWindow()
        GotoBufferId(cid)
        UpdateDisplay(_STATUSLINE_REFRESH_|_ALL_WINDOWS_REFRESH_)
        ResizeWindow()
    ELSE
        OneWindow()
    ENDIF
END pnToggleWindows

/****************************************************************************
 *  Author:  SemWare (Sammy Mitchell - original idea by by Jim Susoy AND    *
 *                    Howard Kapustein)                                     *
 *  Date:    October   1992   Initial coding                                *
 *           April 10, 1993   Cleanup for PUBLIC release                    *
 *           April 13, 1993   ERA added auto FORWARD AND back capabilities  *
 *           April 14, 1993   SEM re-wrote AND reduced code by 184 bytes    *
 ****************************************************************************/

PROC pnMarkSetup()

    STRING  lsStr[80]

    INTEGER liCnt,
            liCtrl,
            liTid

    PushPosition()
    liTid = CreateTempBuffer()
    liCnt = 1
    liCtrl = 1
    WHILE (liCtrl <= 26)
        IF (GotoMark(Chr(Asc('a') + liCtrl - 1)))
            lsStr = Format(liCnt:2, ': ',
                    SplitPath(CurrFileName(), _NAME_ | _EXT_):-12, ' ',
                    CurrLine():6, ' ', GetText(1, 50))
            GotoBufferID(liTid)
            AddLine(lsStr)
            liCnt = liCnt + 1
        ENDIF
        liCtrl = liCtrl + 1
    ENDWHILE
    GotoBufferID(liTid)
    BegFile()
END pnMarkSetup

INTEGER PROC piListIt(STRING lpsTitle, INTEGER lpiWidth)
    lpiWidth = lpiWidth + 4
    IF (lpiWidth > Query(ScreenCols))
        lpiWidth = Query(ScreenCols)
    ENDIF
    Return(List(lpsTitle, lpiWidth))
END piListIt

PROC pnPlaceBookMark()

    INTEGER liNbr

    pnMarkSetup()
    liNbr = NumLines() + 1
    IF (NumLines() > 25)
        liNbr = IIF(piListIt("Place Bookmark", Query(ScreenCols)),
                        CurrLine(), 0)
    ENDIF
    AbandonFile()
    PopPosition()
    IF (liNbr)
        PlaceMark(Chr(Asc('a') + liNbr - 1))
        Message(Format("Bookmark '", Chr(Asc('A') + liNbr - 1), "' Placed"))
        fiBookMarkLastVisited = fiBookMarkLastVisited  + 1
    ENDIF
END pnPlaceBookMark

PROC pnGotoBookMark(INTEGER lpiDoAutoDir) /**********************************/

    INTEGER liMark

    pnMarkSetup()
    liMark = fiBookMarkLastVisited
    IF (NumLines() == 0)
        liMark = 0
        Warn("No bookmarks found")
    ELSEIF ( (liMark <> 0) AND (lpiDoAutoDir == koFORWARD) )
        liMark = IIF(liMark == NumLines(), 1, (liMark + 1))
    ELSEIF ( (liMark <> 0) AND (lpiDoAutoDir == koBACKWARD) )
        liMark = IIF(liMark == 1, NumLines(), (liMark - 1))
    ELSEIF (piListIt("Goto bookmark", Query(ScreenCols)))
        liMark = CurrLine()
    ELSE
        liMark = 0
    ENDIF
    AbandonFile()
    IF (liMark)
        KillPosition()
        GotoMark(Chr(Asc('a') + liMark - 1))
        fiBookMarkLastVisited = liMark
    ELSE
        PopPosition()
    ENDIF
END pnGotoBookMark

KEYDEF kdReadKeys
    <->                     pnSkipToLine(koBACKWARD)
    </>                     pnScanForExactText()
    <1>                     pnDisplayFirstFile()
    <Alt A>                 pnFindTextAgain()
    <Alt B>                 pnMarkLineBottom()
    <Alt D>                 pnSaveBlock()
    <Alt E>                 pnToggleEGA2543()
    <Alt F>                 pnEditFile()
    <Alt G>                 Shell()
    <Alt H>                 pnToggleHexMode()
    <Alt I>                 pnInsertNewFile()
    <Alt M>                 pnMarkLineTop()
    <Alt P>                 PrintBlock()
    <Alt T>                 pnTabsOnOff()
    <Alt U>                 UnMarkBlock()
    <Alt V>                 pnFileSelectMenu()
    <Alt W>                 pnToggleWindows()
    <Alt X>                 AbandonEditor()
    <Alt Y>                 pnGotoBookMark(koFORWARD)
    <Ctrl A>                BegLine()
    <Ctrl C>                PageDown()
    <Ctrl CursorLeft>       BegLine()
    <Ctrl CursorRight>      EndLine()
    <Ctrl D>                ScrollRight(10)
    <Ctrl E>                RollUp()
    <Ctrl F>                pnPrinterFormFeed()
    <Ctrl Home>             pnPositionByLineNumber()
    <Ctrl I>                pnDefineTABInterval()
    <Ctrl M>                PageDown()
    <Ctrl N>                NextFile()
    <Ctrl P>                PrintFile()
    <Ctrl PgDn>             NextFile()
    <Ctrl PgUp>             PrevFile()
    <Ctrl R>                PageUp()
    <Ctrl S>                ScrollLeft(10)
    <Ctrl U>                PrevFile()
    <Ctrl V>                NextWindow()
    <Ctrl W>                RollUp()
    <Ctrl X>                RollDown()
    <Ctrl Y>                pnPlaceBookMark()
    <Ctrl Z>                PrevFile()
    <CursorDown>            RollDown()
    <CursorLeft>            ScrollLeft(10)
    <CursorRight>           ScrollRight(10)
    <CursorUp>              RollUp()
    <End>                   EndFile()
    <Escape>                piToggleToEditMode(FALSE)
    <F10>                   piToggleToEditMode(TRUE)
    <F1>                    pnShowHelp()
    <F3>                    pnFindNextText()
    <F9>                    pnFindPrevText()
    <Grey+>                 pnSkipToLine(koFORWARD)
    <Grey->                 pnSkipToLine(koBACKWARD)
    <Home>                  BegFile()
    <PgDn>                  PageDown()
    <PgUp>                  PageUp()
    <Q>                     pnQuitToNextFile()
    <Shift =>               pnSkipToLine(koFORWARD)
    <X>                     AbandonEditor()
    <\>                     pnFindAnyCaseText()
END kdReadKeys

PROC piToggleToEditMode(INTEGER lpiStayAtCurrentLocation)
    EndProcess()
    Disable(kdReadKeys)
    DelHistory(fiPBLN_HISTORY_)
    DelHistory(fiFIND_HISTORY_)
    Set(Cursor, ON)
    Set(CursorAttr, fiCursorAttr)
    IF (lpiStayAtCurrentLocation)
        KillPosition()
    ELSE
        PopPosition()
    ENDIF
    PopBlock()
    Set(Marking, fiMarking)
    Set(CenterFinds, fiCenterFinds)
    UnHook(pnWinFooterList)
    UnHook(pnOnChangingFiles)
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    OneWindow()
    PurgeMacro(CurrMacroFileName())
END piToggleToEditMode

PROC pnToggleToReadMode()
    Hook(_IDLE_, pnWinFooterList)
    Hook(_ON_CHANGING_FILES_, pnOnChangingFiles)
    pnAssignHistories()
    Enable(kdReadKeys, _EXCLUSIVE_)
    Set(Cursor, OFF)
    fiCenterFinds = Set(CenterFinds, ON)
    fiCursorAttr = Set(CursorAttr, Query(TextAttr))
    fiMarking = Set(Marking, OFF)
    PushBlock()
    UnMarkBlock()
    PushPosition()
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    Process()
END pnToggleToReadMode

PROC pnWinFooterHelp()
    WindowFooter("{<PgDn>} for next screen, {<PgUp>} for previous screen, " +
                    "{<Escape>} to return")
END pnWinFooterHelp

PROC pnWinFooterList()
    INTEGER liRow = 1

    IF (Query(StatusLineAtTop))
        liRow = Query(ScreenRows)
    ENDIF
    VGotoXY(1, liRow)
    PutHelpLine(Format(" View Mode ", fsVersion, " - Press {<F1>} for Help",
                            " or {<Escape>} to Exit"))
END pnWinFooterList

PROC Main()
    IF (CurrFileName() == "++unnamed++")
        PushKey(<Enter>)
        PushKey(<Spacebar>)
        IF (NOT EditFile())
            AbandonEditor()
        ELSE
            AbandonFile(GetBufferID("++unnamed++"))
        ENDIF
    ENDIF
    OneWindow()
    pnToggleToReadMode()
END Main

