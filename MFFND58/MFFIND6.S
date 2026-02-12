/****************************************************************************
 *  FILENAME :  mffind6.s                                                   *
 *  VERSION  :  5.8 (for TSE Pro 2.50a)                                     *
 *  AUTHOR   :  Ray Asbury (rasbury@msmailpc01.saic.com)                    *
 *  COPYRIGHT:  1995 E. Ray Asbury, Jr.  All Rights Reserved Worldwide.     *
 *  DATE     :  Mon 11-20-1995 09:38:34                                     *
 *  FILES    :  mffind.inc      mffind2.inc     mffind.ini                  *
 *              mffind.s        mffind2.s       mffind3.s                   *
 *              mffind4.s       mffind5.s       mffind6.s                   *
 *                                                                          *
 *  PURPOSE  :  String search/replace functions                             *
 *                                                                          *
 *  REVISIONS:  WHO DATE        DESCRIPTION                                 *
 *              --- --------    ------------------------------------------  *
 *              [SEE REVISIONS LIST IN MFFIND.S]                            *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Constants                                       *
 ****************************************************************************/

// SEE MFFIND.INC FOR ADDITIONAL CONSTANTS

CONSTANT    koRSAE_FOUND                    = 2,
            koRSAE_NOT_FOUND                = 3,
            koRSAE_STOP                     = 1

/****************************************************************************
 *  SECTION --> GLOBAL      String Variables                                *
 ****************************************************************************/

// SEE MFFIND.INC FOR ADDITIONAL CONSTANTS

STRING      fsOptsRep[12]                   = "",
            fsReplace[127]                  = "",
            fsTargetRep[127]                = ""

/****************************************************************************
 *  SECTION --> GLOBAL      Integer Variables                               *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Include Files                                   *
 ****************************************************************************/

#include ["mffind2.inc"]

/****************************************************************************
 *  SECTION --> GLOBAL      Forward Declarations                            *
 ****************************************************************************/

FORWARD         PROC pnFind(INTEGER lpiWhichSearchType)
FORWARD         PROC pnPromptCleanUp()
FORWARD         PROC pnPromptStartUp()
FORWARD         PROC pnReplace()
FORWARD         PROC pnUpdateScreenIfNotMinimal()
FORWARD INTEGER PROC pnPromptForAsks()
FORWARD INTEGER PROC piReplaceStringAlreadyExists()
FORWARD STRING  PROC psReplaceSubStr(STRING lpsNeedle, STRING lpsHaystack,
                                        STRING lpsNewNeedle)

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

PROC WhenLoaded()
    SetGlobalInt("giMFFndPid", FALSE)
END WhenLoaded

/****************************************************************************
 *  SECTION --> SYSPROC     WhenPurged                                      *
 ****************************************************************************/

PROC WhenPurged()
    fsIniFile = fsIniFile       // PREVENT COMPILER NOTES ABOUT UN-REF'D VARS
    fsTseVer = fsTseVer         // PREVENT COMPILER NOTES ABOUT UN-REF'D VARS
    fsVer = fsVer               // PREVENT COMPILER NOTES ABOUT UN-REF'D VARS
    fiLastSearchType = fiLastSearchType // SAME AS ABOVE
    IF (fiPid)
        AbandonFile(fiPid)
        SetGlobalInt("giMFFndPid", FALSE)
    ENDIF
    ExecHook(_ON_CHANGING_FILES_)
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
    fiLastSearchType = GetGlobalInt("giMFFndLstSrchType")   // STOPS SC NOTE
    fiThisSearchType = GetGlobalInt("giMFFndCmd")
    CASE (fiThisSearchType)
        WHEN koOPT_FIND_CMNTS_BOTH, koOPT_FIND_CMNTS_C, koOPT_FIND_CMNTS_CPP,
             koOPT_FIND_CUR_WORD, koOPT_FIND_FCNS, koOPT_FIND_STR
            IF ( (fiThisSearchType == koOPT_FIND_CUR_WORD) AND
                 (NOT IsWord()) )
                Message(fsMsgPrefix,
                        "Cursor must be on a word for word search")
            ELSE
                pnInitForNewOption()
                pnFind(GetGlobalInt("giMFFndCmd"))
            ENDIF
        WHEN KoOPT_REPLACE_STR
            pnInitForNewOption()
            pnReplace()
        OTHERWISE
            Warn(fsMsgPrefix, "MFFIND6 should not be executed directly - ",
                    "use MFFIND")
    ENDCASE
    Set(Cursor, ON)
    UnHook(pnPromptStartUp)
    UnHook(pnPromptCleanUp)
    Set(StatusLineUpdating, ON)
    ExecHook(_ON_CHANGING_FILES_)
END Main

/****************************************************************************
 *  SECTION --> SYSPROC     Hooked Procedures                               *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> PROCS       Support Procedures                              *
 ****************************************************************************/

STRING PROC piIsExtUserDefined(VAR STRING lpspCurrExt)
    IF (lpspCurrExt == GetGlobalStr("gsMFFndFExt01"))
        Return(GetGlobalStr("gsMFFndSStr01"))
    ELSEIF (lpspCurrExt == GetGlobalStr("gsMFFndFExt02"))
        Return(GetGlobalStr("gsMFFndSStr02"))
    ELSEIF (lpspCurrExt == GetGlobalStr("gsMFFndFExt03"))
        Return(GetGlobalStr("gsMFFndSStr03"))
    ELSEIF (lpspCurrExt == GetGlobalStr("gsMFFndFExt04"))
        Return(GetGlobalStr("gsMFFndSStr04"))
    ELSEIF (lpspCurrExt == GetGlobalStr("gsMFFndFExt05"))
        Return(GetGlobalStr("gsMFFndSStr05"))
    ELSEIF (lpspCurrExt == GetGlobalStr("gsMFFndFExt06"))
        Return(GetGlobalStr("gsMFFndSStr06"))
    ELSEIF (lpspCurrExt == GetGlobalStr("gsMFFndFExt07"))
        Return(GetGlobalStr("gsMFFndSStr07"))
    ELSEIF (lpspCurrExt == GetGlobalStr("gsMFFndFExt08"))
        Return(GetGlobalStr("gsMFFndSStr08"))
    ELSEIF (lpspCurrExt == GetGlobalStr("gsMFFndFExt09"))
        Return(GetGlobalStr("gsMFFndSStr09"))
    ELSEIF (lpspCurrExt == GetGlobalStr("gsMFFndFExt10"))
        Return(GetGlobalStr("gsMFFndSStr10"))
    ENDIF
    Return("")
END piIsExtUserDefined

/* MARK - MAJOR SEARCHING FUNCTION */

PROC pnFind(INTEGER lpiWhichSearchType)

    STRING  lsCurrExt[4]    = "",
            lsShortName[80],
            lsOpts[12]      = "",
            lsTarget[127]   = ""

    INTEGER liFirstHitFlag = TRUE,
            fiMFFindWrdSrchCsSens

    CASE (lpiWhichSearchType)
        WHEN koOPT_FIND_CMNTS_BOTH
            lsTarget = "^[ \x09]@{/\x2A.@\x2A/}|{//.@}$"
            lsOpts = "x"
        WHEN koOPT_FIND_CMNTS_C
            lsTarget = "^[ \x09]@/\x2A.@\x2A/$"
            lsOpts = "x"
        WHEN koOPT_FIND_CMNTS_CPP
            lsTarget = "^[ \x09]@//.@$"
            lsOpts = "x"
        WHEN koOPT_FIND_CUR_WORD
            PushBlock()
            IF (MarkWord())
                lsTarget = GetMarkedText()
                fiMFFindWrdSrchCsSens = GetGlobalInt("giMFFndWrdSrchCsSens")
                CASE (fiMFFindWrdSrchCsSens)
                    WHEN TRUE
                        lsOpts = "w"
                    WHEN FALSE
                        lsOpts = "iw"
                    OTHERWISE
                        IF (NOT GetGlobalInt("giMFFndWrdSrchCsSensAskDef"))
                            PushKey(<CursorDown>)
                        ENDIF
                        CASE (YesNo("Case Sensitive?"))
                            WHEN 1
                                lsOpts = "w"
                                fiMFFindWrdSrchCsSens = TRUE
                            WHEN 2
                                lsOpts = "iw"
                                fiMFFindWrdSrchCsSens = FALSE
                            OTHERWISE
                                PopBlock()
                                Return()
                        ENDCASE
                ENDCASE
            ELSE
                PopBlock()
                Message(fsMsgPrefix, "Cursor must be located on a word")
                Return()
            ENDIF
            PopBlock()
        WHEN koOPT_FIND_FCNS
            lsOpts = "ix"
        WHEN koOPT_FIND_STR
            lsOpts = psRemoveBadOpts(lsOpts, koFIND, FALSE)
            IF ( (Ask("Search String", lsTarget,
                    GetGlobalInt("giMFFndHistFnd")) AND
                 (Length(lsTarget)) AND
                 Ask("Options [IWX] (Ignore-case Words reg-eXp)", lsOpts,
                        GetGlobalInt("giMFFndHistFndOpts"))) )
                lsOpts = psRemoveBadOpts(lsOpts, koFIND, TRUE)
                Set(Break, OFF)
            ELSE
                Return()
            ENDIF
    ENDCASE
    IF (NOT pnPromptForAsks())
        Return()
    ENDIF
    fiCid = GetBufferID()
    IF (fiPid <> 0)
        AbandonFile(fiPid)
    ENDIF
    fiPid = CreateBuffer(fsMFBuffName, _SYSTEM_)  // SHOULD BE _HIDDEN_
    SetGlobalInt("giMFFndPid", fiPid)
    CASE (lpiWhichSearchType)
        WHEN koOPT_FIND_CMNTS_BOTH
            AddLine(       "Mode           : FIND 1-LINE C/C++ STYLE " +
                    "COMMENTS", fiPid)
        WHEN koOPT_FIND_CMNTS_C
            AddLine(       "Mode           : FIND 1-LINE C STYLE " +
                    "COMMENTS", fiPid)
        WHEN koOPT_FIND_CMNTS_CPP
            AddLine(       "Mode           : FIND 1-LINE C++ STYLE " +
                    "COMMENTS", fiPid)
        WHEN koOPT_FIND_CUR_WORD
            AddLine(Format("Mode           : FIND CURRENT WORD (Case ",
                            IIF((fiMFFindWrdSrchCsSens == TRUE),
                                    "Sensitive", "Insensitive"), ")"), fiPid)
        WHEN koOPT_FIND_FCNS
            AddLine(       "Mode           : FIND FUNCTIONS", fiPid)
        WHEN koOPT_FIND_STR
            AddLine(       "Mode           : FIND STRING", fiPid)
    ENDCASE
    IF (lpiWhichSearchType IN koOPT_FIND_CUR_WORD, koOPT_FIND_STR)
            AddLine(Format(    "String         : '", lsTarget, "'"), fiPid)
    ENDIF
    IF (lpiWhichSearchType == koOPT_FIND_STR)
        AddLine(Format(    "Options        : '", lsOpts, "'",
                        IIF(Length(fsBadOpts),
                                Format("('", fsBadOpts, "' ignored)"),
                                "")), fiPid)
    ENDIF
    AddLine(               "'Hits'         : ", fiPid)
    AddLine(Format(        "Number of Files: ", NumFiles()), fiPid)
    AddLine(Format(fsSelLineFillChar:koFILLWIDTH:fsSelLineFillChar,
                    fsMFLineOne,
                    fsSelLineFillChar:koFILLWIDTH:fsSelLineFillChar,
                    fsSelLineFillChar:koFILLWIDTHADD:fsSelLineFillChar),
                    fiPid)
    fiCntr = 0
    GotoBufferID(fiFileIdFirst)
    IF (IsBlockMarked())
        UnMarkBlock()
    ENDIF
    REPEAT  // FOR EACH FILE
        fiWid = GetBufferID()
        PushPosition()
        BegFile()
        UpdateDisplay(_STATUSLINEREFRESH_|_ALLWINDOWSREFRESH_)
        IF (NOT fiMFFndProgMsgs)
            Message(fsMsgPrefix, "Searching ", piShortenFileName(18))
        ENDIF
        AddLine(Format(fsBufferLineFillCharStart + " ", CurrFileName(),
                        " [buffer ", fiWid, "]"), fiPid)
        IF (NOT NumLines())
            GOTO pnFind_NextFile
        ENDIF
        IF (lpiWhichSearchType == koOPT_FIND_FCNS)
            //lsCurrExt = SplitPath(CurrFileName(), _EXT_)
            lsCurrExt = CurrExt()
            CASE (lsCurrExt)
                WHEN ".c", ".h", ".pc"
                    lsTarget = piIsExtUserDefined(lsCurrExt)
                    IF (NOT Length(lsTarget))
                        lsTarget = "^_@[a-zA-Z][a-zA-Z0-9_* \t]@([~;]*$"
                        //lsTarget = "^{[a-zA-Z_].*}{) *\x7b " +
                        //            "*{{/\x2a.*\x2a/}|{//.*}}*}$"
                    ENDIF
                WHEN ".cpp"
                    lsTarget = piIsExtUserDefined(lsCurrExt)
                    IF (NOT Length(lsTarget))
                        lsTarget = "^_|~@[a-zA-Z:~][a-zA-Z0-9_* \t:~]" +
                                    "@([~;]*$"
                        //lsTarget = "^{[a-zA-Z_].*}{) *\x7b " +
                        //            "*{{/\x2a.*\x2a/}|{//.*}}*}$"
                    ENDIF
                WHEN ".s", ".ui", ".inc"
                    lsTarget = piIsExtUserDefined(lsCurrExt)
                    IF (NOT Length(lsTarget))
                        lsTarget = "^{{PUBLIC #}?{{INTEGER}|{STRING} #}?" +
                                    "PROC}|{MENUBAR}|{MENU}|{[DH][AE][LT]" +
                                    "[AP]DEF}|{KEYDEF} +[a-zA-Z_]\c"
                    ENDIF
                WHEN ".prg",".spr",".mpr",".qpr",".fmt",".frg",".lbg",".ch"
                    lsTarget = piIsExtUserDefined(lsCurrExt)
                    IF (NOT Length(lsTarget))
                        lsTarget = "^{procedure}|{function} +[a-zA-Z_]"
                    ENDIF
                OTHERWISE
                    lsTarget = piIsExtUserDefined(lsCurrExt)
                    IF (NOT Length(lsTarget))
                        IF (GetGlobalInt("giMFFndPauseOnErr"))
                            Warn(fsMsgPrefix, "Function search not ",
                                    "supported for '",
                                    Upper(SplitPath(CurrFileName(),
                                    _NAME_|_EXT_)),
                                    "' - skipping file")
                        ENDIF
                        GOTO pnFind_NextFile
                    ENDIF
            ENDCASE
            lsOpts = "ix"
        ENDIF
        liFirstHitFlag = TRUE
        lsOpts = psDelSubStr("+", lsOpts)
        lsShortName = piShortenFileName(42)
        WHILE (LFind(lsTarget, lsOpts))
            pnUpdateScreenIfNotMinimal()
            IF (fiMFFndProgMsgs)
                Message(fsMsgPrefix, "Hit found at line ", CurrLine(),
                        " of ", NumLines(), " in ", lsShortName)
            ENDIF
            MarkLine()
            pnPutLine(FALSE, CurrLine(), CurrPos())
            fiCntr = fiCntr + 1
            UnMarkBlock()
            IF (liFirstHitFlag)
                lsOpts = lsOpts + "+"
                liFirstHitFlag = FALSE
            ENDIF
        ENDWHILE
        lsOpts = psDelSubStr("+", lsOpts)
        pnFind_NextFile:
            PopPosition()
            NextFile()
    UNTIL (GetBufferId() == fiFileIdFirst)
    GotoBufferID(fiPid)
    BegFile()
    IF (LFind("^ @'Hits' @: \c", "x"))
        InsertText(Str(fiCntr))
    ENDIF
    BegFile()
    piProcessHits()
    GotoBufferID(fiCid)
    IF (lpiWhichSearchType == koOPT_FIND_STR)
        SetGlobalStr("gsMFFndTargetFnd", lsTarget)
        SetGlobalStr("gsMFFndOptsFnd", lsOpts)
    ENDIF
    SetGlobalInt("giMFFndLstSrchType", fiThisSearchType)
    SetGlobalInt("giMFFndCmd", koOPT_PICK_FILE)
    ExecMacro("MFFIND5")
END pnFind

STRING PROC psGetTag(INTEGER lpiWhich)

    STRING  lsLastChar[1]   = ""

    INTEGER liCnt           = 1,
            liStart         = 0,
            liStop          = 0,
            liOpenCntr      = 0,
            liNesting       = 0

    /************************************************************************
     *  SAMPLE STRING FOR TESTING:                                          *
     *                                                                      *
     *                       1         2                                    *
     *              1234567890123456789012345678                            *
     *  TARGET:     PRO{C{WDE{\{\\{.#}\]}[0-9]}}                            *
     *  REPLACE:    P\3\2\1\4                                               *
     *  TAG1:           C{WDE{\{\\{.#}\]}[0-9]}                             *
     *  TAG2:             WDE{\{\\{.#}\]}[0-9]                              *
     *  TAG3:                 \{\\{.#}\]                                    *
     *  TAG4:                      .#                                       *
     *                                                                      *
     *  liStart                                                             *
     *  liStop                                                              *
     *                                                                      *
     *  lsLastChar      liCnt           liOpenCntr      liNesting           *
     *  ------------    ------------    ------------    ------------        *
     *                    1                                                 *
     ************************************************************************/

    WHILE (liCnt <= Length(fsTargetRep))
        CASE (SubStr(fsTargetRep, liCnt, 1))
            WHEN "{"
                IF (lsLastChar <> "\")
                    liOpenCntr = liOpenCntr + 1
                    IF (liStart)
                        liNesting = liNesting + 1
                    ELSEIF (liOpenCntr == lpiWhich)
                        liStart = liCnt + 1
                    ENDIF
                ENDIF
            WHEN "}"
                IF (lsLastChar <> "\")
                    IF (liNesting)
                        liNesting = liNesting - 1
                    ELSEIF (liStart)
                        liStop = liCnt - 1
                        liCnt = Length(fsTargetRep)
                    ENDIF
                ENDIF
            WHEN "["
                liCnt = liCnt +
                        Pos("]", SubStr(fsTargetRep, liCnt,
                                        (Length(fsTargetRep) - liCnt + 1))) - 1
                IF (NOT liCnt)
                    liCnt = Length(fsTargetRep)
                    liStart = 0
                ENDIF
        ENDCASE
        IF ( (lsLastChar == "\") AND (SubStr(fsTargetRep, liCnt, 1) == "\") )
            lsLastChar = ""
        ELSE
            lsLastChar = SubStr(fsTargetRep, liCnt, 1)
        ENDIF
        liCnt = liCnt + 1
    ENDWHILE
    IF ( (NOT liStart) OR (NOT liStop) )
        Return("")
    ENDIF
    Return(SubStr(fsTargetRep, liStart, (liStop - liStart + 1)))
END psGetTag

STRING PROC psMakeVerifyString()

    STRING  lsReplace[255] = fsReplace,
            lsBuf[255]      = ""

    INTEGER liCnt = 1

    IF (Pos("\0", fsReplace))
        lsReplace = psReplaceSubStr("\0", lsReplace, fsTargetRep)
    ELSE
        WHILE (liCnt < 10)
            IF (Pos(Format("\", liCnt), lsReplace))
                lsBuf = psGetTag(liCnt)
                lsReplace = psReplaceSubStr(Format("\", liCnt), lsReplace,
                                            lsBuf)
            ENDIF
            liCnt = liCnt + 1
        ENDWHILE
    ENDIF
    Return(lsReplace)
END psMakeVerifyString

/* MARK - MAJOR SEARCHING FUNCTION */

PROC pnReplace()

    STRING  lsShortName[80]

    INTEGER liMsgLevel      = Set(MsgLevel, _ALL_MESSAGES_),
            liFirstHitFlag  = TRUE,
            liVerifyFirst   = FALSE

    Set(Break, ON)

    pnReplace_Again:
    IF ( (Ask("Target String", fsTargetRep,
            GetGlobalInt("giMFFndHistFnd"))) AND
          (Ask("Replacement String", fsReplace,
                GetGlobalInt("giMFFndHistRep"))) )
        fsOptsRep = psRemoveBadOpts(fsOptsRep, koREPLACE, FALSE)
        IF (NOT Ask("Options [IWNX] (Ignore-case Words No-promp reg-eXp)",
                    fsOptsRep, GetGlobalInt("giMFFndHistRepOpts")))
            Set(MsgLevel, liMsgLevel)
            Return()
        ENDIF
        fsOptsRep = psRemoveBadOpts(fsOptsRep, koREPLACE, TRUE)
        fsOptsRep = Lower(fsOptsRep)
        IF (Length(fsReplace))
            liVerifyFirst = GetGlobalInt("giMFFndVerBefRep")
            IF (liVerifyFirst == koASK)
                CASE (YesNo("Verify Before Replacing?"))
                    WHEN 1
                        liVerifyFirst = TRUE
                    WHEN 2
                        liVerifyFirst = FALSE
                    OTHERWISE
                        Return()
                ENDCASE
            ENDIF
            IF (liVerifyFirst)
                CASE (piReplaceStringAlreadyExists())
                    WHEN koRSAE_STOP
                        Return()
                    WHEN koRSAE_FOUND
                        CASE (YesNo(Format("'",
                                        GetGlobalStr("gsRSAE_FoundStr"),
                                        "' already exists - continue?")))
                            WHEN 0
                                GOTO pnReplace_Again
                            WHEN 2
                                IF (YesNo(Format("Go to location of '",
                                        GetGlobalStr("gsRSAE_FoundStr"),
                                        "'?")) == 1)
                                    GotoBufferId(GetGlobalInt(
                                                    "giRSAE_Bid"))
                                    GotoLine(GetGlobalInt("giRSAE_CurrLine"))
                                    GotoPos(GetGlobalInt("giRSAE_CurrPos"))
                                    IF (Query(CenterFinds))
                                        ScrollToRow(Query(ScreenRows) / 2)
                                    ENDIF
                                    Message(fsMsgPrefix, "Found '",
                                        GetGlobalStr("gsRSAE_FoundStr"),
                                        "'")
                                ENDIF
                                Return()
                        ENDCASE
                ENDCASE
            ENDIF
        ENDIF
        IF (NOT pnPromptForAsks())
            Return()
        ENDIF
        fiCid = GetBufferID()
        IF (fiPid <> 0)
            AbandonFile(fiPid)
        ENDIF
        fiPid = CreateBuffer(fsMFBuffName, _SYSTEM_)  // SHOULD BE _HIDDEN_
        SetGlobalInt("giMFFndPid", fiPid)
        AddLine(       "Mode           : REPLACE STRING", fiPid)
        AddLine(Format("Search String  : '", fsTargetRep, "'"), fiPid)
        AddLine(Format("Replace String : '", fsReplace, "'"), fiPid)
        AddLine(Format("Options        : '", fsOptsRep, "'",
                        IIF(Length(fsBadOpts),
                            Format("('", fsBadOpts, "' ignored)"), "")),
                            fiPid)
        AddLine(       "'Hits'         : ", fiPid)
        AddLine(Format("Number of Files: ", NumFiles()), fiPid)
        AddLine(Format(fsSelLineFillChar:koFILLWIDTH:fsSelLineFillChar,
                        fsMFLineOne,
                        fsSelLineFillChar:koFILLWIDTH:fsSelLineFillChar,
                        fsSelLineFillChar:koFILLWIDTHADD:fsSelLineFillChar),
                        fiPid)
        fiCntr = 0
        GotoBufferID(fiFileIdFirst)
        IF (IsBlockMarked())
            UnMarkBlock()
        ENDIF
        REPEAT
            fiWid = GetBufferID()
            UpdateDisplay(_STATUSLINEREFRESH_|_ALLWINDOWSREFRESH_)
            IF (NOT fiMFFndProgMsgs)
                Message(fsMsgPrefix, "Searching ", piShortenFileName(18))
            ENDIF
            PushPosition()
            BegFile()
            AddLine(Format(fsBufferLineFillCharStart + " ", CurrFileName(),
                            " [buffer ", fiWid, "]"), fiPid)
            IF (NOT NumLines())
                GOTO pnReplace_NextFile
            ENDIF
            liFirstHitFlag = TRUE
            fsOptsRep = psDelSubStr("+", fsOptsRep)
            lsShortName = piShortenFileName(42)
            WHILE (LFind(fsTargetRep, fsOptsRep))
                pnUpdateScreenIfNotMinimal()
                IF (fiMFFndProgMsgs)
                    Message(fsMsgPrefix, "Hit found at line ", CurrLine(),
                            " of ", NumLines(), " in ", lsShortName)
                ENDIF
                MarkLine()
                pnPutLine(FALSE, CurrLine(), CurrPos())
                fiCntr = fiCntr + 1
                UnMarkBlock()
                IF (liFirstHitFlag)
                    fsOptsRep = fsOptsRep + "+"
                    liFirstHitFlag = FALSE
                ENDIF
            ENDWHILE
            fsOptsRep = psDelSubStr("+", fsOptsRep)
            BegFile()
            pnUpdateScreenIfNotMinimal()
            IF (fiMFFndProgMsgs)
                Message(fsMsgPrefix, "Replacing text on line ",
                        CurrLine(), " of ", NumLines(), " in ",
                        piShortenFileName(37))
            ENDIF
            LReplace(fsTargetRep, fsReplace, fsOptsRep)
            pnReplace_NextFile:
                PopPosition()
                NextFile()
        UNTIL (GetBufferId() == fiFileIdFirst)
        GotoBufferID(fiPid)
        BegFile()
        IF (LFind("^ @'Hits' @: \c", "x"))
            InsertText(Str(fiCntr))
        ENDIF
        BegFile()
        piProcessHits()
        GotoBufferID(fiCid)
        SetGlobalInt("giMFFndLstSrchType", fiThisSearchType)
        SetGlobalInt("giMFFndCmd", koOPT_PICK_FILE)
        ExecMacro("MFFIND5")
    ENDIF
    Set(MsgLevel, liMsgLevel)
END pnReplace

INTEGER PROC piReplaceStringAlreadyExists()

    STRING  lsOpts[4]       = fsOptsRep,
            lsPrompt[254]   = "",
            lsReplace[254]  = ""

    INTEGER liUseRegEx  = IIF(Pos("x", lsOpts), TRUE, FALSE)

    IF (liUseRegEx)
        lsReplace = psMakeVerifyString()
        lsOpts = psDelSubStr("x", lsOpts)
    ELSE
        lsReplace = fsReplace
    ENDIF
    lsOpts = psRemoveBadOpts(lsOpts, koVERIFY, FALSE)
    Message(fsMsgPrefix, "Verify if '", lsReplace, "' already exists using")
    lsPrompt = Format("Options ", IIF((liUseRegEx), "'X' + ", ""),
                        "[IW] (Ignore-case Words):")
    lsPrompt = Format(lsPrompt:-(Length(lsReplace) + 40))
    IF (NOT Ask(lsPrompt, lsOpts))
        UpdateDisplay(_STATUSLINE_REFRESH_)
        Return(koRSAE_STOP)
    ENDIF
    lsOpts = psRemoveBadOpts(lsOpts, koVERIFY, TRUE)
    lsOpts = lsOpts + "gx"
    UpdateDisplay(_STATUSLINE_REFRESH_)
    fiCid = GetBufferID()
    GotoBufferID(fiFileIdFirst)
    IF (IsBlockMarked())
        UnMarkBlock()
    ENDIF
    REPEAT
        fiWid = GetBufferID()
        PushPosition()
        IF (LFind(lsReplace, lsOpts))
            SetGlobalStr("gsRSAE_FoundStr", lsReplace)
            SetGlobalInt("giRSAE_Bid", GetBufferId())
            SetGlobalInt("giRSAE_CurrLine", CurrLine())
            SetGlobalInt("giRSAE_CurrPos", CurrPos())
            PopPosition()
            GotoBufferId(fiCid)
            Return(koRSAE_FOUND)
        ENDIF
        PopPosition()
        NextFile()
    UNTIL (GetBufferId() == fiFileIdFirst)
    GotoBufferID(fiCid)
    Return(koRSAE_NOT_FOUND)
END piReplaceStringAlreadyExists

STRING PROC psReplaceSubStr(STRING lpsNeedle, STRING lpsHaystack,
                            STRING lpsNewNeedle)

    INTEGER liStart//,
            //liNeedleLength

    liStart = Pos(lpsNeedle, lpsHaystack)
    //liNeedleLength = Length(lpsNeedle)
    Return(SubStr(lpsHaystack, 1, (liStart - 1)) + lpsNewNeedle +
                SubStr(lpsHaystack, (liStart + 2),
                        (Length(lpsHaystack) - (liStart + 1))))
END psReplaceSubStr

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