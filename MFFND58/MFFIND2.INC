/****************************************************************************
 *  FILENAME :  mffind2.inc                                                 *
 *  VERSION  :  5.8 (for TSE Pro 2.50a)                                     *
 *  AUTHOR   :  Ray Asbury (rasbury@msmailpc01.saic.com)                    *
 *  COPYRIGHT:  1995 E. Ray Asbury, Jr.  All Rights Reserved Worldwide.     *
 *  DATE     :  Mon 11-20-1995 09:38:34                                     *
 *  FILES    :  mffind.inc      mffind2.inc     mffind.ini                  *
 *              mffind.s        mffind2.s       mffind3.s                   *
 *              mffind4.s       mffind5.s       mffind6.s                   *
 *                                                                          *
 *  PURPOSE  :  Shared functions for mffind5.s & mffind6.s                  *
 *                                                                          *
 *  REVISIONS:  WHO DATE        DESCRIPTION                                 *
 *              --- --------    ------------------------------------------  *
 *              [SEE REVISIONS LIST IN MFFIND.S]                            *
 *                                                                          *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Constants                                       *
 ****************************************************************************/

CONSTANT    koFILLWIDTH                     = 26,
            koFILLWIDTHADD                  = 14,
            koHDRLINES_DF_LINES_BD          = 4,
            koHDRLINES_DF_LINES_EI          = 6,
            koHDRLINES_FIND_STR             = 6,
            koHDRLINES_FIND_CUR_WORD        = 5,
            koHDRLINES_FIND_CF              = 4,
            koHDRLINES_REPLACE_STR          = 7,
            koLEFT_MARGIN_WIDTH             = 2,
            koLF_ADJACENT_BLANK_LINES       = 1,
            koLF_DUPLICATE_LINES            = 2,
            koLF_SECONDARY_HITS             = 3,
            koMAXLINE                       = 91,
            koSEPARATOR                     = 179,
            koSTD_WIDTH                     = 5,
            koTEXT_WIDTH                    = 79

/****************************************************************************
 *  SECTION --> GLOBAL      String Variables                                *
 ****************************************************************************/

STRING      fsBadOpts[12],
            fsBuffer[127],
            fsBufferLineFillChar[1],
            fsBufferLineFillCharStart[1],
            fsMFLineOne[]                   = " SELECT THIS LINE TO EDIT ",
            fsMFBuffName[]                  = "$~MFSR~$",
            fsSelLineFillChar[1]

/****************************************************************************
 *  SECTION --> GLOBAL      Integer Variables                               *
 ****************************************************************************/

INTEGER     fiCid,
            fiCntr,
            fiFileIdFirst,
            fiFileIdLast,
            fiLastSearchType,
            fiMaxLnNbrLen,
            fiMFFndDistGrpHits,
            fiMFFndMinScrnUpds,
            fiMFFndProgMsgs,
            fiNumFiles,
            fiPid                           = 0,
            fiProcessingFirstFile,
            fiThisSearchType,
            fiTotalNumLines,
            fiWid

/****************************************************************************
 *  SECTION --> GLOBAL      Include Files                                   *
 ****************************************************************************/

#include ["mffind.inc"]

/****************************************************************************
 *  SECTION --> GLOBAL      Forward Declarations                            *
 ****************************************************************************/

FORWARD         PROC pnGetRingEndsAndMaxLines()
FORWARD         PROC pnInitForNewOption()
FORWARD         PROC piProcessHits()
FORWARD         PROC pnPutLine(INTEGER lpiInsert, INTEGER lpiCurrLine,
                                INTEGER lpiCurrPos)
FORWARD         PROC pnUpdateScreenIfNotMinimal()
FORWARD STRING  PROC psRemoveBadOpts(STRING lpsHaystack, INTEGER lpiOptsType,
                                        INTEGER lpiWarn)
FORWARD STRING  PROC piShortenFileName(INTEGER lpiRestOfMsg)

/****************************************************************************
 *  SECTION --> GLOBAL      Data Definitions                                *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Help Definitions                                *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Key Definitions                                 *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> SYSPROC     WhenLoaded                                      *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> SYSPROC     WhenPurged                                      *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> SYSPROC     Main                                            *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> SYSPROC     Hooked Procedures                               *
 ****************************************************************************/

PROC pnPromptCleanUp()
    Set(Cursor, OFF)
END pnPromptCleanUp

PROC pnPromptStartUp()
    Set(Cursor, ON)
END pnPromptStartUp

/****************************************************************************
 *  SECTION --> PROCS       Support Procedures                              *
 ****************************************************************************/

STRING PROC psDelSubStr(STRING lpsNeedle, STRING lpsHaystack)

    STRING  lsHay[255]    = Upper(lpsHaystack)

    INTEGER liNeedlePos   = Pos(lpsNeedle, lsHay)

    WHILE liNeedlePos
        lsHay = substr(lsHay, 1, (liNeedlePos - 1)) +
                substr(lsHay, (liNeedlePos + Length(lpsNeedle)),
                        (Length(lsHay) - (liNeedlePos + Length(lpsNeedle))) +
                        1)
        liNeedlePos = Pos(lpsNeedle,lsHay)
    ENDWHILE
    Return(lsHay)
END psDelSubStr

PROC pnGetRingEndsAndMaxLines()

    // ALTHOUGH IT IS SAFE TO ASSUME THAT THE FIRST NORMAL BUFFER IN THE
    // RING IS THE ONE WITH THE LOWEST ID, IT CANNOT BE ASSUMED THAT THE
    // ONE WITH THE HIGHEST ID IS NECESSARILY THE LAST IN THE RING.

    INTEGER liCid           = GetBufferID(),
            liMaxNumLines   = 0

    Set(MsgLevel,_WARNINGS_ONLY_)
    Message(fsMsgPrefix, "Please wait while initializing...")
    fiFileIdFirst = MAXINT
    fiFileIdLast = 0
    fiNumFiles = 0
    fiMaxLnNbrLen = 0
    fiTotalNumLines = 0
    REPEAT

        fiFileIdFirst = Min(GetBufferId(), fiFileIdFirst)

        fiTotalNumLines = fiTotalNumLines + NumLines()

        liMaxNumLines = Max(liMaxNumLines, NumLines())
        //NextFile(_DONT_LOAD_)
        NextFile()
        fiNumFiles = fiNumFiles + 1
    UNTIL (liCid == GetBufferID())
    Message("")
    GotoBufferId(fiFileIdFirst)
    //PrevFile(_DONT_LOAD_)
    PrevFile()
    fiFileIdLast = GetBufferId()
    GotoBufferId(liCid)
    fiMaxLnNbrLen = Length(Str(liMaxNumLines))
    SetGlobalInt("giMFFndNumFiles", fiNumFiles)
    SetGlobalInt("giMFFndFileIdFirst", fiFileIdFirst)
    SetGlobalInt("giMFFndFileIdLast", fiFileIdLast)
    UpdateDisplay(_STATUSLINE_REFRESH_)
    IF (koDEBUG)
        Warn("fiFileIdFirst: ", fiFileIdFirst)
        Warn("fiFileIdLast: ", fiFileIdLast)
        Warn("fiTotalNumLines: ", fiTotalNumLines)
        Warn("liMaxNumLines: ", liMaxNumLines)
        Warn("fiMaxLnNbrLen: ", fiMaxLnNbrLen)
    ENDIF
END pnGetRingEndsAndMaxLines

PROC pnInitForNewOption()
    pnGetRingEndsAndMaxLines()
    fsSelLineFillChar           = GetGlobalStr("gsMFFndSelLineChar")
    IF (fsSelLineFillChar == "")
        fsSelLineFillChar = "þ"
    ENDIF
    fsBufferLineFillChar        = GetGlobalStr("gsMFFndBufLineChar")
    IF (fsBufferLineFillChar == "")
        fsBufferLineFillChar = "ù"
    ENDIF
    CASE (fsBufferLineFillChar)
        WHEN "Ý", "Þ"
            fsBufferLineFillCharStart = "Û"
        OTHERWISE
            fsBufferLineFillCharStart = fsBufferLineFillChar
    ENDCASE
END pnInitForNewOption

PROC piProcessHits()

    STRING  lsLastLine[82]  = "",
            lsThisLine[82]

    INTEGER liCnt,
            liFirstOne      = TRUE,
            liLastLineNbr   = 0,
            liSelectLine,
            liLookFor,
            liThisLineNbr

    fiProcessingFirstFile = TRUE
    CASE (fiThisSearchType)
        WHEN koOPT_DEL_LINES_BLNKS, koOPT_DEL_LINES_DUPS
            liSelectLine = koHDRLINES_DF_LINES_BD
            liLookFor = FALSE
        WHEN koOPT_FIND_LINE_BLNKS
            liSelectLine = koHDRLINES_DF_LINES_BD
            liLookFor = koLF_ADJACENT_BLANK_LINES
        WHEN koOPT_FIND_LINE_DUPS
            liSelectLine = koHDRLINES_DF_LINES_BD
            liLookFor = koLF_DUPLICATE_LINES
        WHEN koOPT_DEL_LINES_EXCLX, koOPT_DEL_LINES_INCLX,
             koOPT_FIND_LINE_EXCLX, koOPT_FIND_LINE_INCLX
            liSelectLine = koHDRLINES_DF_LINES_EI
            liLookFor = FALSE
        WHEN koOPT_FIND_STR
            liSelectLine = koHDRLINES_FIND_STR
            liLookFor = koLF_SECONDARY_HITS
        WHEN koOPT_FIND_CUR_WORD
            liSelectLine = koHDRLINES_FIND_CUR_WORD
            liLookFor = koLF_SECONDARY_HITS
        WHEN koOPT_FIND_CMNTS_BOTH, koOPT_FIND_CMNTS_C,
             koOPT_FIND_CMNTS_CPP, koOPT_FIND_FCNS
            liSelectLine = koHDRLINES_FIND_CF
            liLookFor = FALSE
        WHEN KoOPT_REPLACE_STR
            liSelectLine = koHDRLINES_REPLACE_STR
            liLookFor = koLF_SECONDARY_HITS
    ENDCASE
    WHILE (liSelectLine)
        RollDown()
        liSelectLine = liSelectLine - 1
    ENDWHILE
    UpdateDisplay(_ALL_WINDOWS_REFRESH_|_HELPLINE_REFRESH_)
    IF (NOT fiMFFndProgMsgs)
        Message(fsMsgPrefix, "processing hits")
    ENDIF
    BegFile()
    WHILE (LFind("^\c" + fsBufferLineFillCharStart + " ", "x"))
        pnUpdateScreenIfNotMinimal()
        PushPosition()
        liCnt = 0
        IF (fiMFFndDistGrpHits)
            lsLastLine = ""
            lsThisLine = ""
        ENDIF
        WHILE ( (Down()) AND
                (GetText(1, 2) <> (fsBufferLineFillCharStart + " ")) )
            IF (fiMFFndProgMsgs)
                Message(fsMsgPrefix, "processing 'hits' (line ",
                        CurrLine(), " of ", NumLines(), ")")
            ENDIF
            IF ( (liLookFor <> FALSE) AND (fiMFFndDistGrpHits) )
                lsThisLine = GetText((fiMaxLnNbrLen + 4), (koTEXT_WIDTH + 3))
                BegLine()
                WordRight()
                MarkWord()
                liThisLineNbr = Val(GetMarkedText())
                UnMarkBlock()
                CASE (liLookFor)
                    WHEN koLF_DUPLICATE_LINES
                        IF ( (liThisLineNbr == liLastLineNbr + 1) AND
                             (lsThisLine == lsLastLine) )
                            GotoPos(fiMaxLnNbrLen + 4)
                            InsertText(Format("[duplicate hit]":
                                                (fiMaxLnNbrLen -
                                                    koTEXT_WIDTH):" "),
                                                _OVERWRITE_)
                        ELSE
                            lsLastLine = lsThisLine
                        ENDIF
                        liLastLineNbr = liThisLineNbr
                    WHEN koLF_ADJACENT_BLANK_LINES
                        IF (liThisLineNbr == liLastLineNbr + 1)
                            GotoPos(fiMaxLnNbrLen + 4)
                            InsertText(Format("[adjacent hit]":
                                                (fiMaxLnNbrLen -
                                                    koTEXT_WIDTH):" "),
                                                _OVERWRITE_)
                            IF ( (liFirstOne) AND
                                 (liLookFor == koLF_ADJACENT_BLANK_LINES) )
                                Up()
                                GotoPos(fiMaxLnNbrLen + 4)
                                InsertText(Format("[adjacent hit]":
                                                    (fiMaxLnNbrLen -
                                                        koTEXT_WIDTH):" "),
                                                    _OVERWRITE_)
                                Down()
                            ENDIF
                            liFirstOne = FALSE
                        ELSE
                            liFirstOne = TRUE
                        ENDIF
                        liLastLineNbr = liThisLineNbr
                    WHEN koLF_SECONDARY_HITS
                        IF ( (liThisLineNbr == liLastLineNbr) AND
                             (lsThisLine == lsLastLine) )
                            GotoPos(3)
                            InsertText(Format(" ":fiMaxLnNbrLen:" ",
                                                Chr(koSEPARATOR),
                                                "[secondary hit]":
                                                (fiMaxLnNbrLen -
                                                    koTEXT_WIDTH):" "),
                                                _OVERWRITE_)
                        ELSE
                            lsLastLine = lsThisLine
                            liLastLineNbr = liThisLineNbr
                        ENDIF
                ENDCASE
            ENDIF
            liCnt = liCnt + 1
        ENDWHILE
        PopPosition()
        IF (LFind(" .#\[buffer [0-9]#\c\]$", "x"))
            InsertText(", hits " + Str(liCnt))
            IF (PosLastNonWhite() < koMAXLINE)
                EndLine()
                Right()
                InsertText(Format(fsBufferLineFillCharStart:
                                    (koMAXLINE - PosLastNonWhite()):
                                    fsBufferLineFillChar))
            ENDIF
        ENDIF
        IF (CurrLine() == NumLines())
            Break
        ENDIF
        fiProcessingFirstFile = FALSE
    ENDWHILE
    BegFile()
END piProcessHits

INTEGER PROC pnPromptForAsks()
    IF (fiTotalNumLines > GetGlobalInt("giMFFndProgMsgsTHold"))
        fiMFFndProgMsgs = TRUE
    ELSE
        fiMFFndProgMsgs = GetGlobalInt("giMFFndProgMsgs")
        IF (fiMFFndProgMsgs == koASK)
            IF (NOT GetGlobalInt("giMFFndProgMsgsDefAsk"))
                PushKey(<CursorDown>)
            ENDIF
            CASE (YesNo("Display Progress Messages?"))
                WHEN 1
                    fiMFFndProgMsgs = TRUE
                WHEN 2
                    fiMFFndProgMsgs = FALSE
                OTHERWISE
                    Return(FALSE)
            ENDCASE
        ENDIF
    ENDIF
    fiMFFndMinScrnUpds = GetGlobalInt("giMFFndMinScrnUpds")
    IF (fiMFFndMinScrnUpds == koASK)
        IF (NOT GetGlobalInt("giMFFndMinScrnUpdsDefAsk"))
            PushKey(<CursorDown>)
        ENDIF
        CASE (YesNo("Use Minimal Screen Updating?"))
            WHEN 1
                fiMFFndMinScrnUpds = TRUE
            WHEN 2
                fiMFFndMinScrnUpds = FALSE
            OTHERWISE
                Return(FALSE)
        ENDCASE
    ENDIF
    fiMFFndDistGrpHits = GetGlobalInt("giMFFndDistGrpHits")
    IF (fiMFFndDistGrpHits == koASK)
        IF (NOT GetGlobalInt("giMFFndDistGrpHitsDefAsk"))
            PushKey(<CursorDown>)
        ENDIF
        CASE (YesNo("Distinguish Secondary Group Hits?"))
            WHEN 1
                fiMFFndDistGrpHits = TRUE
            WHEN 2
                fiMFFndDistGrpHits = FALSE
            OTHERWISE
                Return(FALSE)
        ENDCASE
    ENDIF
    IF (fiMFFndMinScrnUpds)
        Set(StatusLineUpdating, OFF)
    ENDIF
    Return(TRUE)
END pnPromptForAsks

PROC pnPutLine(INTEGER lpiInsert, INTEGER lpiCurrLine, INTEGER lpiCurrPos)
    fsBuffer = Format(" ":koLEFT_MARGIN_WIDTH, lpiCurrLine:fiMaxLnNbrLen,
                        Chr(koSEPARATOR),
                        Trim(GetMarkedText()):-(koTEXT_WIDTH - fiMaxLnNbrLen),
                        fiWid:koSTD_WIDTH, lpiCurrPos:koSTD_WIDTH)
    IIF((lpiInsert), InsertLine(fsBuffer, fiPid), AddLine(fsBuffer, fiPid))
END pnPutLine

STRING PROC psRemoveBadOpts(STRING lpsHaystack, INTEGER lpiOptsType,
                            INTEGER lpiWarn)

    STRING  lsHay[12]       = "",
            lsBuf[12]       = "",
            lsCurChar[1]    = ""

    INTEGER liSrcCnt        = 1,
            liTarCnt        = 1

    fsBadOpts = ""
    WHILE (liSrcCnt <= Length(lpsHayStack))
        lsCurChar = Lower(SubStr(lpsHayStack, liSrcCnt, 1))
        CASE lsCurChar
            WHEN "i", "w", "x"      // Delete, Find, Replace, & Verify
                lsHay = lsHay + lsCurChar
                liTarCnt = liTarCnt + 1
            WHEN "n"                // Replace
                IF (lpiOptsType == koREPLACE)
                    lsHay = lsHay + lsCurChar
                    liTarCnt = liTarCnt + 1
                ELSE
                    fsBadOpts = fsBadOpts + lsCurChar
                ENDIF
            OTHERWISE
                fsBadOpts = fsBadOpts + lsCurChar
        ENDCASE
        liSrcCnt = liSrcCnt + 1
    ENDWHILE

    /* TELL USER IF GAVE BAD OPTIONS AND PREVENT AUTO REPLACE ***************/

    IF ( (liSrcCnt <> liTarCnt) AND (lpiWarn) )
        Warn(fsMsgPrefix, "Invalid search options, {", fsBadOpts,
                    "} will be ignored!")
        lsBuf = psDelSubStr("n", lsHay)
        IF (Length(lsBuf) <> Length(lsHay))
            fsBadOpts = fsBadOpts + "n"
            lsHay = lsBuf
            Warn(fsMsgPrefix, "No-Prompt option is also being ignored")
        ENDIF
    ENDIF
    Return(lsHay)
END psRemoveBadOpts

STRING PROC piShortenFileName(INTEGER lpiRestOfMsg)

    STRING  lsCFName[127]   = CurrFileName(),
            lsBuf[127]      = ""

    INTEGER liMaxLength,
            liStart

    liMaxLength = Query(ScreenCols) - lpiRestOfMsg
    IF (Length(lsCFName) <= liMaxLength)
        Return(lsCFName)
    ENDIF
    lsBuf = lsCFName
    lsCFName = Format(SubStr(lsCFName, 1, 3), "...\")
    lsBuf = SubStr(lsBuf, 4, (Length(lsBuf) - 3))
    WHILE (Length(lsBuf) > (liMaxLength - 7))
        liStart = Pos("\", lsBuf)
        lsBuf = SubStr(lsBuf, (liStart + 1), (Length(lsBuf) - liStart))
    ENDWHILE
    lsCFName = Format(lsCFName,
                        lsBuf:-(liMaxLength - 7):Chr(
                                Query(StatusLineFillChar)))
    lsCFName = Format(lsCFName:-(liMaxLength + 1):
                        Chr(Query(StatusLineFillChar)))
    Return(lsCFName)
END piShortenFileName

PROC pnUpdateScreenIfNotMinimal()
    IF (NOT fiMFFndMinScrnUpds)
        IF (NOT fiProcessingFirstFile)
            ScrollToCenter()
        ENDIF
        IF (fiMFFndProgMsgs)
            UpdateDisplay(_WINDOW_REFRESH_)
        ELSE
            UpdateDisplay(_ALL_WINDOWS_REFRESH_|_HELPLINE_REFRESH_)
        ENDIF
    ENDIF
END pnUpdateScreenIfNotMinimal

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