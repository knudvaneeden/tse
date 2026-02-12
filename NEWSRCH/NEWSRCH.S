/****************************************************************************
 *   FILENAME:  C:\TSE\MAC\MFSRCHRP.S                                       *
 *   AUTHOR  :  "Buddy" E. Ray Asbury, Jr.                                  *
 *   DATE    :  Wed 05-04-1994 20:51:29                                     *
 *   PURPOSE :  Multiple file search and replace utility                    *
 *                                                                          *
 *  Slight modifications by Stuart Warren                                   *
 *                                                                          *
 *  Changes:                                                                *
 *  I made the search function put the bufferid, line, column info on the   *
 *  end of each string to hide the info in the list box.                    *
 *                                                                          *
 *  I made processes use a system hidden buffer, rather than a file, which  *
 *  hides them from vew in the file ring.                                   *
 *                                                                          *
 *  I changed the default search string to "I" rather than risk having a    *
 *  (G)lobal command be in the options. The Global makes the lfind() or     *
 *  lreplace() functions continuously find the first match until you run    *
 *  out of disk space.                                                      *
 *                                                                          *
 *                                                                          *
 ****************************************************************************/

/* GLOBAL VARIABLES *********************************************************/

STRING  target[100],
        replacement[100],
        opts[10]

INTEGER     pid = 0,
            cid,
            wid,
            cnt

FORWARD INTEGER PROC mPicklist()

PROC mAgain()
    PushPosition()
    IF (NOT mPicklist())
        PopPosition()
    ELSE
        KillPosition()
    ENDIF
END mAgain

PROC mFind()
    target = ""
    opts = "I"
    Set(Break, ON)
    IF (Ask("Target String", target, _FINDHISTORY_) AND
        Ask("Options [IWX] (Ignore-case Words reg-eXp)", opts))
        cid = GetBufferID()
        wid = cid
        IF (pid <> 0)
            AbandonFile(pid)
        ENDIF
        pid = CreateBuffer("+ + + FIND ",_HIDDEN_)
        cnt = 0
        GotoBufferID(cid)
        IF (IsBlockMarked())
            UnMarkBlock()
        ENDIF
        target = Format("\c", target)
        opts = Format(opts, "x")
        REPEAT  // FOR EACH FILE
            UpdateDisplay(_STATUSLINEREFRESH_|_ALLWINDOWSREFRESH_)
            Message(Format("Searching ", CurrFileName()))
            PushPosition()
            BegFile()
            AddLine(Format("þ ",CurrFileName():-75,"  ",wid:4),pid)
            WHILE (LFind(target, opts))
                MarkLine()
                AddLine(Format("  ",Trim(GetMarkedText()):-75, wid:6, CurrLine():8, CurrPos():8), pid)
                cnt = cnt + 1
                EndLine()
                UnMarkBlock()
            ENDWHILE
            PopPosition()
            NextFile()
            wid = GetBufferID()
            IF (wid == pid)
                NextFile()
                wid = GetBufferID()
            ENDIF
        UNTIL (wid == cid)
        IF (cnt == 0)
            Message("Target string not found.")
            AbandonFile(pid)
            pid = 0
        ELSE
            GotoBufferID(pid)
            BegFile()
            IF (NOT mPicklist())
                GotoBufferID(cid)
            ENDIF
        ENDIF
    ENDIF
END mFind

PROC mNext(INTEGER goForward)
    INTEGER fid = 0, curCol, curRow
    STRING opts[4] = "X+"

    PushPosition()  // LOCATION AT CALL
    IF (pid == 0)
        Message("Picklist has not been created yet.")
        Return()
    ENDIF
    GotoBufferID(pid)
    PushPosition()  // LOCATION IN HIT LIST BUFFER AT CALL
    IF (NOT goForward)
        opts = "BX+"
    ENDIF
    BegLine()
    IF (LFind("^ ", opts))
        KillPosition()
        KillPosition()

        EndLine()
        WordLeft()
        MarkWord()
        curCol = Val(GetMarkedText())
        UnMarkBlock()

        WordLeft()
        MarkWord()
        curRow = Val(GetMarkedText())
        UnMarkBlock()

        WordLeft()
        MarkWord()
        fid = Val(GetMarkedText())
        UnMarkBlock()

        GotoBufferID(fid)
        GotoLine(curRow)
        GotoPos(curCol)
        ScrollToRow(Query(WindowRows) / 2)
    ELSE
        PopPosition()
        PopPosition()
        IF (goForward)
            Message("At last hit.")
        ELSE
            Message("At first hit.")
        ENDIF
    ENDIF
END mNext

INTEGER PROC mPicklist()
    INTEGER fid = 0, curCol, curRow,
            saveHist = Query(MaxHistorySize)

    IF (pid == 0)
        Message("Picklist has not been created yet.")
        Return(FALSE)
    ENDIF
    ZoomWindow()
    GotoBufferID(pid)
    UpdateDisplay(_STATUSLINEREFRESH_|_CLINEREFRESH_|_ALLWINDOWSREFRESH_)
    Set(MaxHistorySize, 0)                               /* Disable History */
    IF (LList("Multi-File Find/Replace Picklist", 75,
              Query(ScreenRows), _ENABLE_SEARCH_) <> 0)
        IF (CurrChar() == Asc('þ'))
        	EndLine()
            WordLeft()
            MarkWord()
            fid = Val(GetMarkedText())      // get buffer id
            GotoBufferID(fid)               // jump to it
            BegFile()                       // set top of file
        ELSE
            EndLine()                       // go to end of line
            WordLeft()                      // go to start of last word
            MarkWord()
            curCol = Val(GetMarkedText())   // get column number
            UnMarkBlock()

            WordLeft()
            MarkWord()
            curRow = Val(GetMarkedText())   // get line number
            UnMarkBlock()

            WordLeft()
            MarkWord()
            fid = Val(GetMarkedText())      // get buffer number
            UnMarkBlock()

            GotoBufferID(fid)               // jump to location in file
            GotoLine(curRow)
            GotoPos(curCol)
            ScrollToRow(Query(WindowRows) / 2)
        ENDIF
    ELSE
        Return(FALSE)
    ENDIF
    ZoomWindow()
    Set(MaxHistorySize, saveHist)
    Return(TRUE)
END mPicklist

PROC mReplace()
    target = ""
    replacement = ""
    opts = "I"
    Set(Break, ON)
    IF (Ask("Target String", target, _FINDHISTORY_) AND
        Ask("Replacement String", replacement, _REPLACEHISTORY_) AND
        Ask("Options [IWX] (Ignore-case Words reg-eXp)", opts))
        cid = GetBufferID()
        wid = cid
        pid = CreateBuffer("+ + + FIND ",_HIDDEN_)
        cnt = 0
        GotoBufferID(cid)
        IF (IsBlockMarked())
            UnMarkBlock()
        ENDIF
        //target = Format("\c", target)
        opts = Format(opts, "xn")
        REPEAT  // FOR EACH FILE
            UpdateDisplay(_STATUSLINEREFRESH_|_ALLWINDOWSREFRESH_)
            Message(Format("Searching ", CurrFileName()))
            PushPosition()
            BegFile()
            AddLine(Format("þ ",CurrFileName():-75,"  ",wid:4),pid)
            WHILE (LReplace(target, replacement, opts))
                MarkLine()
                AddLine(Format("  ",Trim(GetMarkedText()):-75, wid:6, CurrLine():8, CurrPos():8), pid)
                cnt = cnt + 1
                EndLine()
                UnMarkBlock()
                Down()
            ENDWHILE
            PopPosition()
            NextFile()
            wid = GetBufferID()
            IF (wid == pid)
                NextFile()
                wid = GetBufferID()
            ENDIF
        UNTIL (wid == cid)
        IF (cnt == 0)
            Message("Target string not found.")
            AbandonFile(pid)
            pid = 0
        ELSE
            BegFile()
            IF (NOT mPicklist())
                GotoBufferID(cid)
            ENDIF
        ENDIF
    ENDIF
END mReplace

MENU menuMFFind()
    Title = "Multi-File Find/Replace"
    History
    "&Find",                mFind(),            CloseAllBefore
    "&Replace",             mReplace(),         CloseAllBefore
    "&Picklist",            mAgain(),           CloseAllBefore
    "&Next",                mNext(TRUE),        CloseAllBefore
    "Pr&evious",            mNext(FALSE),       CloseAllBefore
END menuMFFind

<Alt V><a>                  mAgain()
<Alt V><f>                  mFind()
<Alt V><n>                  mNext(TRUE)
<Alt V><p>                  mNext(FALSE)
<Alt V><r>                  mReplace()
<Alt V><Shift a>            mAgain()
<Alt V><Shift f>            mFind()
<Alt V><Shift n>            mNext(TRUE)
<Alt V><Shift p>            mNext(FALSE)
<Alt V><Shift r>            mReplace()
<Alt V><Shift v>            menuMFFind()
<Alt V><v>                  menuMFFind()

