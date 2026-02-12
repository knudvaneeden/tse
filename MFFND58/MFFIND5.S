/****************************************************************************
 *  FILENAME :  mffind5.s                                                   *
 *  VERSION  :  5.8 (for TSE Pro 2.50a)                                     *
 *  AUTHOR   :  Ray Asbury (rasbury@msmailpc01.saic.com)                    *
 *  COPYRIGHT:  1995 E. Ray Asbury, Jr.  All Rights Reserved Worldwide.     *
 *  DATE     :  Mon 11-20-1995 09:38:34                                     *
 *  FILES    :  mffind.inc      mffind2.inc     mffind.ini                  *
 *              mffind.s        mffind2.s       mffind3.s                   *
 *              mffind4.s       mffind5.s       mffind6.s                   *
 *                                                                          *
 *  PURPOSE  :  'Hit-file', and Line find/delete functions                  *
 *                                                                          *
 *  REVISIONS:  WHO DATE        DESCRIPTION                                 *
 *              --- --------    ------------------------------------------  *
 *              [SEE REVISIONS LIST IN MFFIND.S]                            *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Constants                                       *
 ****************************************************************************/

// SEE MFFIND.INC FOR ADDITIONAL CONSTANTS

/****************************************************************************
 *  SECTION --> GLOBAL      String Variables                                *
 ****************************************************************************/

// SEE MFFIND.INC FOR ADDITIONAL CONSTANTS

STRING      fsMFEditName[]                  = "MFFIND.LST",
            fsOptsFnd[12]                   = "",
            fsRemovedMsg[]                  = "This file has been removed " +
                                                "from the ring",
            fsTargetFnd[127]                = ""

/****************************************************************************
 *  SECTION --> GLOBAL      Integer Variables                               *
 ****************************************************************************/

INTEGER     fiHighLightFirstHit             = TRUE

/****************************************************************************
 *  SECTION --> GLOBAL      Include Files                                   *
 ****************************************************************************/

#include ["mffind2.inc"]

/****************************************************************************
 *  SECTION --> GLOBAL      Forward Declarations                            *
 ****************************************************************************/

FORWARD         PROC pnAddListPageDown()
FORWARD         PROC pnAgain()
FORWARD         PROC pnDoBlankLines(INTEGER lpiDeleteThem)
FORWARD         PROC pnDoDuplicateLines(INTEGER lpiDeleteThem)
FORWARD         PROC pnDoLines(INTEGER lpiDoCompliment, INTEGER lpiDeleteThem)
FORWARD         PROC pnNext(INTEGER lpiGoForward)
FORWARD         PROC pnPickFileNextFile()
FORWARD         PROC pnPickFilePrevFile()
FORWARD         PROC pnPromptCleanUp()
FORWARD         PROC pnPromptStartUp()
FORWARD INTEGER PROC piPickFile()

/****************************************************************************
 *  SECTION --> GLOBAL      Data Definitions                                *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Help Definitions                                *
 ****************************************************************************/

HELPDEF hdHitFile
"<Enter>                Goto the current 'hit'"
"<Alt GreyCursorUp>     Previous file"
"<Alt GreyCursorDown>   Next file"
"<PgDn>                 Page down one screen"
"<PgUp>                 Page up one screen"
"<CursorUp>             Goto previous line"
"<CursorDown>           Goto next line"
"<Ctrl CursorUp>        Roll screen up one line"
"<Ctrl CursorDown>      Roll screen down one line"
"<Ctrl PgUp>            Beginning of 'hit-file'"
"<Ctrl PgDn>            End of 'hit-file'"
""
"Additionally, 'Speed Search' is available"
END hdHitFile

/****************************************************************************
 *  SECTION --> GLOBAL      Key Definitions                                 *
 ****************************************************************************/

KEYDEF kdAddListKeys
  <F1>                      QuickHelp(hdHitFile)
  <Alt GreyCursorUp>        pnPickFilePrevFile()
  <Alt GreyCursorDown>      pnPickFileNextFile()
  <Ctrl PgDn>               pnAddListPageDown()
END kdAddListKeys

/****************************************************************************
 *  SECTION --> SYSPROC     WhenLoaded                                      *
 ****************************************************************************/

PROC WhenLoaded()
    SetGlobalInt("giMFFndPid", FALSE)
END WhenLoaded

/****************************************************************************
 *  SECTION --> SYSPROC     WhenPurged                                      *
 ****************************************************************************/

PROC WhenPurged()
    fsIniFile = fsIniFile       // PREVENT COMPILER NOTES ABOUT UN-REF'D VARS
    IF (fiPid)
        AbandonFile(fiPid)
        SetGlobalInt("giMFFndPid", FALSE)
    ENDIF
END WhenPurged

/****************************************************************************
 *  SECTION --> SYSPROC     Main                                            *
 ****************************************************************************/

PROC Main()
    IF (koDEBUG)
        Set(Break, ON)
    ENDIF
    Set(Cursor, OFF)
    Hook(_PROMPT_STARTUP_, pnPromptStartUp)
    Hook(_PROMPT_CLEANUP_, pnPromptCleanUp)
    fiPid = GetGlobalInt("giMFFndPid")
    fiLastSearchType = GetGlobalInt("giMFFndLstSrchType")
    fiThisSearchType = GetGlobalInt("giMFFndCmd")
    fsBufferLineFillChar = GetGlobalStr("gsMFFndBufLineChar")
    CASE (fsBufferLineFillChar)
        WHEN "Ý", "Þ"
            fsBufferLineFillCharStart = "Û"
        OTHERWISE
            fsBufferLineFillCharStart = fsBufferLineFillChar
    ENDCASE
    CASE (fiThisSearchType)
        WHEN koOPT_DEL_LINES_BLNKS
            pnInitForNewOption()
            IF (NOT pnPromptForAsks())
                GOTO Main_End
            ENDIF
            pnDoBlankLines(TRUE)
        WHEN koOPT_FIND_LINE_BLNKS
            pnInitForNewOption()
            IF (NOT pnPromptForAsks())
                GOTO Main_End
            ENDIF
            pnDoBlankLines(FALSE)
        WHEN koOPT_DEL_LINES_DUPS
            pnInitForNewOption()
            IF (NOT pnPromptForAsks())
                GOTO Main_End
            ENDIF
            pnDoDuplicateLines(TRUE)
        WHEN koOPT_FIND_LINE_DUPS
            pnInitForNewOption()
            IF (NOT pnPromptForAsks())
                GOTO Main_End
            ENDIF
            pnDoDuplicateLines(FALSE)
        WHEN koOPT_DEL_LINES_EXCLX
            pnInitForNewOption()
            pnDoLines(TRUE, TRUE)
        WHEN koOPT_FIND_LINE_EXCLX
            pnInitForNewOption()
            pnDoLines(TRUE, FALSE)
        WHEN koOPT_DEL_LINES_INCLX
            pnInitForNewOption()
            pnDoLines(FALSE, TRUE)
        WHEN koOPT_FIND_LINE_INCLX
            pnInitForNewOption()
            pnDoLines(FALSE, FALSE)
        WHEN koOPT_PICK_AGAIN
            pnAgain()
        WHEN koOPT_PICK_FILE
            PushPosition()
            IF (NOT piPickFile())
                PopPosition()
            ELSE
                KillPosition()
            ENDIF
        WHEN koOPT_HIT_NEXT
            pnNext(TRUE)
        WHEN koOPT_HIT_PREVIOUS
            pnNext(FALSE)
        OTHERWISE
            Warn(fsMsgPrefix, "MFFIND5 should not be executed directly - ",
                    "use MFFIND")
    ENDCASE
    Main_End:
    Set(Cursor, ON)
    UnHook(pnPromptStartUp)
    UnHook(pnPromptCleanUp)
    Set(StatusLineUpdating, ON)
    ExecHook(_ON_CHANGING_FILES_)
END Main

/****************************************************************************
 *  SECTION --> SYSPROC     Hooked Procedures                               *
 ****************************************************************************/

PROC pnAddListKeysLoad()
    Enable(kdAddListKeys)
    WindowFooter(" {<Enter>}-Go To Current Line  {<F1>}-Help  " +
                    "{<Escape>}-Exit ")
    UnHook(pnAddListKeysLoad)
END pnAddListKeysLoad

//PROC pnStopHook()
//    BreakHookChain()
//END pnStopHook

/****************************************************************************
 *  SECTION --> PROCS       Support Procedures                              *
 ****************************************************************************/

PROC pnAddListPageDown()
    EndFile()
    BegLine()
END pnAddListPageDown

PROC pnAgain()
    PushPosition()
    fiHighLightFirstHit = FALSE
    IF (NOT piPickFile())
        PopPosition()
    ELSE
        KillPosition()
    ENDIF
    fiHighLightFirstHit = TRUE
END pnAgain

/* MARK - MAJOR SEARCHING FUNCTION */

PROC pnDoBlankLines(INTEGER lpiDeleteThem)

    STRING  lsShortName[80],
            lsOpts[2]       = "xbn",
            lsTarget[3]     = "^$"

    INTEGER liCntr          = 0

    fiCid = GetBufferId()
    IF (fiPid <> 0)
        AbandonFile(fiPid)
    ENDIF
    fiPid = CreateBuffer(fsMFBuffName, _SYSTEM_)  // SHOULD BE _HIDDEN_
    SetGlobalInt("giMFFndPid", fiPid)
    IF (lpiDeleteThem)
        AddLine(   "Mode           : DELETE BLANK LINES", fiPid)
        AddLine(   "Lines Deleted  : ", fiPid)
    ELSE
        AddLine(   "Mode           : FIND BLANK LINES", fiPid)
        AddLine(   "Lines Found    : ", fiPid)
    ENDIF
    AddLine(Format("Number of Files: ", NumFiles()), fiPid)
    AddLine(Format(fsSelLineFillChar:koFILLWIDTH:fsSelLineFillChar,
                    fsMFLineOne,
                    fsSelLineFillChar:koFILLWIDTH:fsSelLineFillChar,
                    fsSelLineFillChar:koFILLWIDTHADD:fsSelLineFillChar),
                    fiPid)
    fiCntr = 0
    liCntr = 0
    GotoBufferId(fiFileIdFirst)
    IF (IsBlockMarked())
        UnMarkBlock()
    ENDIF
    fiWid = GetBufferId()
    GotoBufferId(fiPid)
    EndFile()
    CReturn()
    GotoBufferId(fiWid)
    REPEAT
        fiWid = GetBufferId()
        PushPosition()
        EndFile()
        pnUpdateScreenIfNotMinimal()
        IF (NOT fiMFFndProgMsgs)
            Message(fsMsgPrefix, "Searching ", piShortenFileName(18))
        ENDIF
        GotoBufferId(fiPid)
        EndFile()
        GotoBufferId(fiWid)
        InsertLine(Format(fsBufferLineFillCharStart, " ", CurrFileName(),
                            " [buffer ", fiWid, "]"), fiPid)
        IF (NOT NumLines())
            GOTO pnDoBlankLines_NextFile
        ENDIF
        GotoBufferId(fiPid)
        EndFile()
        GotoBufferId(fiWid)
        lsShortName = piShortenFileName(46)
        WHILE (NOT PosFirstNonWhite())  /* REMOVE BLANKS AT EOF */
            pnUpdateScreenIfNotMinimal()
            IF (fiMFFndProgMsgs)
                Message(fsMsgPrefix, IIF(lpiDeleteThem, "Deleting", "Found"),
                        " line ", CurrLine(), " of ", NumLines(), " in ",
                        lsShortName)
            ENDIF
            MarkLine()
            pnPutLine(TRUE, CurrLine(), 1)
            UnMarkBlock()
            fiCntr = fiCntr + 1
            liCntr = liCntr + 1
            IF (lpiDeleteThem)
                KillLine()
                GotoLine(NumLines())
            ELSE
                Up()
            ENDIF
        ENDWHILE
        EndLine()
        WHILE (LFind(lsTarget, lsOpts))
            pnUpdateScreenIfNotMinimal()
            IF (fiMFFndProgMsgs)
                Message(fsMsgPrefix, IIF(lpiDeleteThem, "Deleting", "Found"),
                        " line ", CurrLine(), " of ", NumLines(), " in ",
                        lsShortName)
            ENDIF
            MarkLine()
            pnPutLine(TRUE, CurrLine(), CurrPos())
            UnMarkBlock()
            fiCntr = fiCntr + 1
            liCntr = liCntr + 1
            IF (lpiDeleteThem)
                KillLine()
            ENDIF
            BegLine()
        ENDWHILE
        pnDoBlankLines_NextFile:
            PopPosition()
            NextFile()
            liCntr = 0
    UNTIL (GetBufferId() == fiFileIdFirst)
    GotoBufferID(fiPid)
    EndFile()
    IF (NOT PosFirstNonWhite())
        KillLine()
    ENDIF
    BegFile()
    IF (LFind("^ @Lines {Deleted}|{Found} @: \c", "x"))
        InsertText(Str(fiCntr))
    ENDIF
    BegFile()
    piProcessHits()
    GotoBufferID(fiCid)
    SetGlobalInt("giMFFndLstSrchType", fiThisSearchType)
    PushPosition()
    fiHighLightFirstHit = TRUE
    IF (NOT piPickFile())
        PopPosition()
    ELSE
        KillPosition()
    ENDIF
    fiHighLightFirstHit = FALSE
END pnDoBlankLines

/* MARK - MAJOR SEARCHING FUNCTION */

PROC pnDoDuplicateLines(INTEGER lpiDeleteThem)

    STRING  lsStr1[255],
            lsStr2[255],
            lsShortName[80]

    INTEGER liCntr      = 0,
            liFirstDup  = TRUE,
            liNotDone

    fiCid = GetBufferId()
    IF (fiPid <> 0)
        AbandonFile(fiPid)
    ENDIF
    fiPid = CreateBuffer(fsMFBuffName, _SYSTEM_)  // SHOULD BE _HIDDEN_
    SetGlobalInt("giMFFndPid", fiPid)
    IF (lpiDeleteThem)
        AddLine(   "Mode           : DELETE DUPLICATE LINES", fiPid)
        AddLine(   "Lines Deleted  : ", fiPid)
    ELSE
        AddLine(   "Mode           : FIND DUPLICATE LINES", fiPid)
        AddLine(   "Lines Found    : ", fiPid)
    ENDIF
    AddLine(Format("Number of Files: ", NumFiles()), fiPid)
    AddLine(Format(fsSelLineFillChar:koFILLWIDTH:fsSelLineFillChar,
                    fsMFLineOne, fsSelLineFillChar:koFILLWIDTH:
                    fsSelLineFillChar, fsSelLineFillChar:koFILLWIDTHADD:
                    fsSelLineFillChar), fiPid)
    fiCntr = 0
    liCntr = 0
    GotoBufferId(fiFileIdFirst)
    IF (IsBlockMarked())
        UnMarkBlock()
    ENDIF
    fiWid = GetBufferId()
    GotoBufferId(fiPid)
    EndFile()
    CReturn()
    GotoBufferId(fiWid)
    REPEAT
        liCntr = 0
        fiWid = GetBufferId()
        PushPosition()
        EndFile()
        UpdateDisplay(_STATUSLINEREFRESH_|_ALLWINDOWSREFRESH_)
        IF (NOT fiMFFndProgMsgs)
            Message(fsMsgPrefix, "Searching ", piShortenFileName(18))
        ENDIF
        GotoBufferId(fiPid)
        EndFile()
        GotoBufferId(fiWid)
        InsertLine(Format(fsBufferLineFillCharStart, " ", CurrFileName(),
                            " [buffer ", fiWid, "]"), fiPid)
        IF (NOT NumLines())
            GOTO pnDoDuplicateLines_NextFile
        ENDIF
        GotoBufferId(fiPid)
        EndFile()
        GotoBufferId(fiWid)
        liNotDone = TRUE
        lsStr1 = GetText(1, CurrLineLen())
        lsShortName = piShortenFileName(46)
        liFirstDup = TRUE
        WHILE (liNotDone)
            IF (Up())
                lsStr2 = GetText(1, CurrLineLen())
                IF (lsStr1 == lsStr2)
                    MarkLine()
                    IF ( (fiMFFndDistGrpHits) AND
                         (NOT lpiDeleteThem) AND
                         (liFirstDup) )
                        pnPutLine(TRUE, (CurrLine() + 1), 1)
                        liFirstDup = FALSE
                    ENDIF
                    pnPutLine(TRUE, CurrLine(), 1)
                    UnMarkBlock()
                    fiCntr = fiCntr + 1
                    liCntr = liCntr + 1
                    pnUpdateScreenIfNotMinimal()
                    IF (fiMFFndProgMsgs)
                        Message(fsMsgPrefix,
                                IIF(lpiDeleteThem, "Deleting", "Found"),
                                " line ", CurrLine(), " of ", NumLines(),
                                " in ", lsShortName)
                    ENDIF
                    IF (lpiDeleteThem)
                        KillLine()
                    ENDIF
                ELSE
                    liFirstDup = TRUE
                    lsStr1 = lsStr2
                ENDIF
            ELSE
                liNotDone = FALSE
            ENDIF
        ENDWHILE
        pnDoDuplicateLines_NextFile:
            PopPosition()
            NextFile()
    UNTIL (GetBufferId() == fiFileIdFirst)
    GotoBufferID(fiPid)
    EndFile()
    IF (NOT PosFirstNonWhite())
        KillLine()
    ENDIF
    BegFile()
    IF (LFind("^ @Lines {Deleted}|{Found} @: \c", "x"))
        InsertText(Str(fiCntr))
    ENDIF
    BegFile()
    piProcessHits()
    GotoBufferID(fiCid)
    SetGlobalInt("giMFFndLstSrchType", fiThisSearchType)
    PushPosition()
    fiHighLightFirstHit = TRUE
    IF (NOT piPickFile())
        PopPosition()
    ELSE
        KillPosition()
    ENDIF
    fiHighLightFirstHit = FALSE
END pnDoDuplicateLines

/* MARK - MAJOR SEARCHING FUNCTION */

PROC pnDoLines(INTEGER lpiDoCompliment, INTEGER lpiDeleteThem)

    STRING  lsPrompt[33],
            lsShortName[80]

    INTEGER liCntr          = 0,
            liNotDone

    IF (lpiDoCompliment)
        lsPrompt = IIF(lpiDeleteThem,"Delete", "Find") +
                    " all lines not containing:"
    ELSE
        lsPrompt = IIF(lpiDeleteThem,"Delete", "Find") +
                    " all lines containing:"
    ENDIF
    fsTargetFnd = GetGlobalStr("gsMFFndTargetFnd")
    fsOptsFnd = GetGlobalStr("gsMFFndOptsFnd")
    IF ( (Ask(lsPrompt, fsTargetFnd, _FINDHISTORY_)) AND
         (Length(fsTargetFnd)) )
        fsOptsFnd = psRemoveBadOpts(fsOptsFnd, koDELETE, FALSE)
        IF (NOT Ask("Options [IWX] (Ignore-case Words reg-eXp):",
                    fsOptsFnd, _FINDOPTIONSHISTORY_))
            Return()
        ENDIF
        IF ( (Pos("x", Lower(fsOptsFnd))) AND (fsTargetFnd == "^$") )
            Warn(fsMsgPrefix, "Cannot use '^$' with this option")
            Return()
        ENDIF
        IF (NOT pnPromptForAsks())
            Return()
        ENDIF
        fsOptsFnd = psRemoveBadOpts(fsOptsFnd, koDELETE, TRUE)
        SetGlobalStr("gsMFFndTargetFnd", fsTargetFnd)
        SetGlobalStr("gsMFFndOptsFnd", fsOptsFnd)
        fiCid = GetBufferId()
        IF (fiPid <> 0)
            AbandonFile(fiPid)
        ENDIF
        fiPid = CreateBuffer(fsMFBuffName, _SYSTEM_)  // SHOULD BE _HIDDEN_
        SetGlobalInt("giMFFndPid", fiPid)
        IF (lpiDeleteThem)
            AddLine(Format("Mode           : DELETE LINES ",
                            IIF(lpiDoCompliment, "NOT ", ""),
                            "CONTAINING"), fiPid)
        ELSE
            AddLine(Format("Mode           : FIND LINES ",
                            IIF(lpiDoCompliment, "NOT ", ""),
                            "CONTAINING"), fiPid)
        ENDIF
        AddLine(Format(    "Search String  : '", fsTargetFnd, "'"), fiPid)
        AddLine(Format(    "Options        : '", fsOptsFnd, "'",
                        IIF(Length(fsBadOpts), Format("('", fsBadOpts,
                                                        "' ignored)"),
                                                        "")), fiPid)
        IF (lpiDeleteThem)
            AddLine(       "Lines Deleted  : ", fiPid)
        ELSE
            AddLine(       "Lines Found    : ", fiPid)
        ENDIF
        AddLine(Format(    "Number of Files: ", NumFiles()), fiPid)
        AddLine(Format(fsSelLineFillChar:koFILLWIDTH:fsSelLineFillChar,
                        fsMFLineOne, fsSelLineFillChar:koFILLWIDTH:
                        fsSelLineFillChar, fsSelLineFillChar:koFILLWIDTHADD:
                        fsSelLineFillChar), fiPid)
        fiCntr = 0
        liCntr = 0
        GotoBufferId(fiFileIdFirst)
        IF (IsBlockMarked())
            UnMarkBlock()
        ENDIF
        fiWid = GetBufferId()
        GotoBufferId(fiPid)
        EndFile()
        CReturn()
        GotoBufferId(fiWid)
        IF (lpiDoCompliment)
            fsOptsFnd = Format(fsOptsFnd, "c")
            REPEAT
                liNotDone = TRUE
                liCntr = 0
                fiWid = GetBufferId()
                PushPosition()
                EndFile()
                UpdateDisplay(_STATUSLINEREFRESH_|_ALLWINDOWSREFRESH_)
                IF (NOT fiMFFndProgMsgs)
                    Message(fsMsgPrefix, "Searching ", piShortenFileName(18))
                ENDIF
                GotoBufferId(fiPid)
                EndFile()
                GotoBufferId(fiWid)
                InsertLine(Format(fsBufferLineFillCharStart + " ",
                                    CurrFileName(), " [buffer ", fiWid, "]"),
                                    fiPid)
                IF (NOT NumLines())
                    GOTO pnDoLines_NextFile1
                ENDIF
                GotoBufferId(fiPid)
                EndFile()
                GotoBufferId(fiWid)
                lsShortName = piShortenFileName(46)
                WHILE (liNotDone)
                    BegLine()
                    IF (NOT LFind(fsTargetFnd, fsOptsFnd))
                        MarkLine()
                        pnPutLine(TRUE, CurrLine(), CurrPos())
                        fiCntr = fiCntr + 1
                        liCntr = liCntr + 1
                        UnMarkBlock()
                        pnUpdateScreenIfNotMinimal()
                        IF (fiMFFndProgMsgs)
                            Message(fsMsgPrefix,
                                    IIF(lpiDeleteThem, "Deleting",
                                    "Found"), " line ", CurrLine(), " of ",
                                    NumLines(), " in ", lsShortName)
                        ENDIF
                        IF (lpiDeleteThem)
                            KillLine()
                        ENDIF
                    ENDIF
                    IF (NOT Up())
                        liNotDone = FALSE
                    ENDIF
                ENDWHILE
                IF (NOT NumLines())
                    GOTO pnDoLines_NextFile1
                ENDIF
                pnDoLines_NextFile1:
                    PopPosition()
                    NextFile()
            UNTIL (GetBufferId() == fiFileIdFirst)
        ELSE
            fsOptsFnd = fsOptsFnd + "b"
            REPEAT
                fiWid = GetBufferId()
                PushPosition()
                EndFile()
                UpdateDisplay(_STATUSLINEREFRESH_|_ALLWINDOWSREFRESH_)
                IF (NOT fiMFFndProgMsgs)
                    Message(fsMsgPrefix, "Searching ", piShortenFileName(18))
                ENDIF
                GotoBufferId(fiPid)
                EndFile()
                GotoBufferId(fiWid)
                InsertLine(Format(fsBufferLineFillCharStart + " ",
                                    CurrFileName(), " [buffer ", fiWid, "]"),
                                    fiPid)
                IF (NOT NumLines())
                    GOTO pnDoLines_NextFile2
                ENDIF
                GotoBufferId(fiPid)
                EndFile()
                GotoBufferId(fiWid)
                lsShortName = piShortenFileName(46)
                WHILE (LFind(fsTargetFnd, fsOptsFnd))
                    MarkLine()
                    pnPutLine(TRUE, CurrLine(), CurrPos())
                    UnMarkBlock()
                    fiCntr = fiCntr + 1
                    liCntr = liCntr + 1
                    pnUpdateScreenIfNotMinimal()
                    IF (fiMFFndProgMsgs)
                        Message(fsMsgPrefix,
                                IIF(lpiDeleteThem, "Deleting", "Found"),
                                " line ", CurrLine(), " of ", NumLines(),
                                " in ", lsShortName)
                    ENDIF
                    IF (lpiDeleteThem)
                        KillLine()
                    ENDIF
                    BegLine()
                ENDWHILE
                pnDoLines_NextFile2:
                    PopPosition()
                    NextFile()
                    liCntr = 0
            UNTIL (GetBufferId() == fiFileIdFirst)
        ENDIF
        GotoBufferID(fiPid)
        EndFile()
        IF (NOT PosFirstNonWhite())
            KillLine()
        ENDIF
        BegFile()
        IF (LFind("^ @Lines {Deleted}|{Found} @: \c", "x"))
            InsertText(Str(fiCntr))
        ENDIF
        BegFile()
        piProcessHits()
        GotoBufferID(fiCid)
        SetGlobalInt("giMFFndLstSrchType", fiThisSearchType)
        PushPosition()
        fiHighLightFirstHit = TRUE
        IF (NOT piPickFile())
            PopPosition()
        ELSE
            KillPosition()
        ENDIF
        fiHighLightFirstHit = FALSE
    ENDIF
END pnDoLines

INTEGER PROC piGotoHit(INTEGER lpiDoWarning)

    INTEGER liCurRow = 0,
            liCurPos,
            liFid

    // GET LINE NUMBER

    PushPosition()
    WHILE (liCurRow == 0)
        BegLine()
        WordRight()
        MarkWord()
        liCurRow = Val(GetMarkedText())
        IF (liCurRow == 0)
            Up()
        ENDIF
    ENDWHILE
    PopPosition()

    // ADJUST FOR PREVIOUS DELETED LINES

    CASE (fiLastSearchType)
        WHEN koOPT_DEL_LINES_BLNKS, koOPT_DEL_LINES_DUPS,
             koOPT_DEL_LINES_EXCLX, koOPT_DEL_LINES_INCLX
            PushPosition()
            LFind(Format("^", fsBufferLineFillCharStart,
                            ".#\[buffer [0-9]#, hits [0-9]#\]"), "ibx")
            liCurRow = liCurRow + CurrLine() + 1
            PopPosition()
            liCurRow = liCurRow - CurrLine()
    ENDCASE

    // GET COLUMN NUMBER

    EndLine()
    WordLeft()
    MarkWord()
    CASE (fiLastSearchType)
        WHEN koOPT_DEL_LINES_BLNKS, koOPT_DEL_LINES_DUPS,
             koOPT_DEL_LINES_EXCLX, koOPT_DEL_LINES_INCLX
            liCurPos = 1
        OTHERWISE
            liCurPos = Val(GetMarkedText())
    ENDCASE

    // GET BUFFER ID

    WordLeft()
    MarkWord()
    liFid = Val(GetMarkedText())
    BegLine()
    UnMarkBlock()

    // GOTO IT IF FILE'S STILL LOADED

    IF (GotoBufferID(liFid))
        GotoLine(liCurRow)
        GotoPos(liCurPos)
        ScrollToRow(Query(WindowRows) / 2)
        Return(TRUE)
    ENDIF
    GotoBufferId(fiPid)
    IF (lpiDoWarning)
        Warn(fsMsgPrefix, fsRemovedMsg)
    ENDIF
    UnMarkBlock()
    Return(FALSE)
END piGotoHit

PROC pnNext(INTEGER lpiGoForward)

    STRING  lsOpts[4] = ""

    IF (fiPid == 0)
        Message(fsMsgPrefix, "Picklist has not been created yet")
        Return()
    ENDIF
    PushPosition()  // LOCATION AT CALL
    GotoBufferID(fiPid)
    PushPosition()  // LOCATION IN HIT LIST BUFFER AT CALL
    IF (lpiGoForward)
        lsOpts = "x+"
    ELSE
        lsOpts = "bx+"
    ENDIF
    BegLine()
    pnNext_Again:
    IF (LFind("^ ", lsOpts))
        IF (NOT piGotoHit(FALSE))
            Goto pnNext_Again
        ENDIF
        KillPosition()
        KillPosition()
    ELSE
        PopPosition()
        PopPosition()
        IF (lpiGoForward)
            Message(fsMsgPrefix, "At last hit")
        ELSE
            Message(fsMsgPrefix, "At first hit")
        ENDIF
    ENDIF
END pnNext

INTEGER PROC piPickFile()

    INTEGER liFid               = 0,
            liBlkMarked         = IsBlockMarked(),
            liSelectLine,
            liMaxHistorySize    = Query(MaxHistorySize)

    IF (fiPid == 0)
        Message(fsMsgPrefix, "Picklist has not been created yet")
        Return(FALSE)
    ENDIF
    CASE (GetGlobalInt("giMFFndLstSrchType"))
        WHEN koOPT_DEL_LINES_BLNKS, koOPT_DEL_LINES_DUPS
            liSelectLine = koHDRLINES_DF_LINES_BD
        WHEN koOPT_FIND_LINE_BLNKS, koOPT_FIND_LINE_DUPS
            liSelectLine = koHDRLINES_DF_LINES_BD
        WHEN koOPT_DEL_LINES_EXCLX, koOPT_DEL_LINES_INCLX
            liSelectLine = koHDRLINES_DF_LINES_EI
        WHEN koOPT_FIND_LINE_EXCLX, koOPT_FIND_LINE_INCLX
            liSelectLine = koHDRLINES_DF_LINES_EI
        WHEN koOPT_FIND_STR
            liSelectLine = koHDRLINES_FIND_STR
        WHEN koOPT_FIND_CUR_WORD
            liSelectLine = koHDRLINES_FIND_CUR_WORD
        WHEN koOPT_FIND_CMNTS_BOTH, koOPT_FIND_CMNTS_C,
             koOPT_FIND_CMNTS_CPP, koOPT_FIND_FCNS
            liSelectLine = koHDRLINES_FIND_CF
        WHEN KoOPT_REPLACE_STR
            liSelectLine = koHDRLINES_REPLACE_STR
    ENDCASE
    ZoomWindow()
    GotoBufferID(fiPid)
    UpdateDisplay(_STATUSLINEREFRESH_|_CLINEREFRESH_|_ALLWINDOWSREFRESH_)
    Set(MaxHistorySize, 0)
    piPickFile_Again:
    IF (fiHighLightFirstHit)
        BegFile()
        //LFind("\[buffer [0-9]#\]", "xi")
        LFind(GetGlobalStr("gsMFFndSelLineChar"), "")
        IF (NOT LFind("^ @[0-9]#", "x"))
            Up()
        ENDIF
    ENDIF
    IIF((CurrLine() <= Query(WindowRows)),
            ScrollToRow(Query(WindowRows)),
            ScrollToRow(Query(WindowRows) / 2))
    Hook(_LIST_STARTUP_, pnAddListKeysLoad)
    PushPosition()
    IF (LList(Format("Multi-File Find/Replace Picklist ", fsVer,
                        " (for TSE Pro v", fsTseVer, ")"),
                        Query(ScreenCols), Query(ScreenRows),
                        _ENABLE_SEARCH_|_ENABLE_HSCROLL_) <> 0)
        KillPosition()
        BegLine()
        IF (CurrLine() > liSelectLine)     // GOTO A HIT
            IF (CurrChar() == Asc(fsBufferLineFillCharStart))
                LFind(" .#\[buffer \c[0-9]", "x")
                MarkWord()
                liFid = Val(GetMarkedText())
                IF (GotoBufferID(liFid))
                    BegFile()
                ELSE
                    GotoBufferId(fiPid)
                    UnMarkBlock()
                    Warn(fsMsgPrefix, fsRemovedMsg)
                    GOTO piPickFile_Again
                ENDIF
            ELSE
                IF (NOT piGotoHit(TRUE))
                    GOTO piPickFile_Again
                ENDIF
            ENDIF
        ELSEIF (CurrLine() < liSelectLine) // STAY IN PICKLIST
            fiHighLightFirstHit = TRUE
            GOTO piPickFile_Again
        ELSE                                // USER CHOSE TO EDIT PICKLIST
            Message("Please wait...")
            liFid = EditFile(fsMFEditName)
            EmptyBuffer(liFid)
            GotoBufferID(fiPid)
            PushPosition()
            BegFile()
            IF (liBlkMarked)
                PushBlock()
            ENDIF
            MarkLine()
            EndFile()
            GotoBufferID(liFid)
            CopyBlock()
            GotoBufferID(fiPid)
            IIF((liBlkMarked), PopBlock(), UnMarkBlock())
            PopPosition()
            EditFile(fsMFEditName)
            UpdateDisplay(_ALL_WINDOWS_REFRESH_|_HELPLINE_REFRESH_)
        ENDIF
    ELSE
        PopPosition()
        Disable(kdAddListKeys)
        Set(MaxHistorySize, liMaxHistorySize)
        Return(FALSE)
    ENDIF
    Disable(kdAddListKeys)
    UnMarkBlock()
    ZoomWindow()
    Set(MaxHistorySize, liMaxHistorySize)
    Return(TRUE)
END piPickFile

PROC pnPickFilePrevFile()
    PushPosition()
    BegLine()
    IF (NOT LFind(Format("hits [0-9]#\] ", fsBufferLineFillChar), "xb"))
        PopPosition()
        Message(fsMsgPrefix, "At first file")
    ELSE
        KillPosition()
        BegLine()
    ENDIF
    ScrollToRow(Query(WindowRows) / 2)
END pnPickFilePrevFile

PROC pnPickFileNextFile()
    PushPosition()
    EndLine()
    IF (NOT LFind(Format("hits [0-9]#\] ", fsBufferLineFillChar), "x"))
        PopPosition()
        Message(fsMsgPrefix, "At last file")
    ELSE
        KillPosition()
        BegLine()
    ENDIF
    ScrollToRow(Query(WindowRows) / 2)
END pnPickFileNextFile

/****************************************************************************
 *  SECTION --> PROCS       User Procedures                                 *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> MENU        The Menus                                       *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> KEYS        Key Bindings                                    *
 ****************************************************************************/

