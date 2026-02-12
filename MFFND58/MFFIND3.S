/****************************************************************************
 *  FILENAME :  mffind3.s                                                   *
 *  VERSION  :  5.8 (for TSE Pro 2.50a)                                     *
 *  AUTHOR   :  Ray Asbury (rasbury@msmailpc01.saic.com)                    *
 *  COPYRIGHT:  1995 E. Ray Asbury, Jr.  All Rights Reserved Worldwide.     *
 *  DATE     :  Mon 11-20-1995 09:38:34                                     *
 *  FILES    :  mffind.inc      mffind2.inc     mffind.ini                  *
 *              mffind.s        mffind2.s       mffind3.s                   *
 *              mffind4.s       mffind5.s       mffind6.s                   *
 *                                                                          *
 *  PURPOSE  :  Configuration support functions                             *
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

/****************************************************************************
 *  SECTION --> GLOBAL      Integer Variables                               *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Include Files                                   *
 ****************************************************************************/

#include ["mffind.inc"]

/****************************************************************************
 *  SECTION --> GLOBAL      Forward Declarations                            *
 ****************************************************************************/

FORWARD         MENU mnConfig()
FORWARD         MENU mnFileSettings()
FORWARD         MENU mnFillCharacters()
FORWARD         MENU mnHistType()
FORWARD         MENU mnProgMsgs()
FORWARD         MENU mnYesNoAsk()
FORWARD         PROC pnGetSettings(INTEGER lpiFromMenu)
FORWARD         PROC pnGetTrueFalseAsk(STRING lpsSection, STRING lpsItem,
                                        STRING lpsGlobVar,
                                        STRING lpsGlobVarDefAsk)
FORWARD         PROC pnSetProStr(STRING lpsSection, STRING lpsKeyword,
                                    STRING lpsValue)
FORWARD         PROC pnSetSettings()
FORWARD         PROC pnSetTrueFalseAsk(STRING lpsSection, STRING lpsItem,
                                        STRING lpsGlobVar,
                                        STRING lpsGlobVarDefAsk)
FORWARD STRING  PROC psGetProStr(STRING lpsSection, STRING lpsKeyword)

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

PROC WhenPurged()
    fsIniFile = fsIniFile       // PREVENT COMPILER NOTES ABOUT UN-REF'D VARS
    fsTseVer = fsTseVer         // PREVENT COMPILER NOTES ABOUT UN-REF'D VARS
    fsVer    = fsVer            // PREVENT COMPILER NOTES ABOUT UN-REF'D VARS
END WhenPurged

/****************************************************************************
 *  SECTION --> SYSPROC     Main                                            *
 ****************************************************************************/

PROC Main()

    INTEGER liMFFindUseOwnHist = GetGlobalInt("giMFFndHistType")

    IF (koDEBUG)
        Set(Break, ON)
    ENDIF
    CASE (GetGlobalInt("giMFFndCmd"))
        WHEN koOPT_CONFIG_MFFIND
            mnConfig()
            IF (liMFFindUseOwnHist <> GetGlobalInt("giMFFndHistType"))
                SetGlobalInt("giMFFndCmd", koOPT_SET_HISTORIES)
                ExecMacro("MFFIND4")
            ENDIF
        WHEN koOPT_INI_READ
            pnGetSettings(FALSE)
        OTHERWISE
            Warn(fsMsgPrefix, "MFFIND3 should not be executed directly - ",
                    "use MFFIND")
    ENDCASE
END Main

/****************************************************************************
 *  SECTION --> SYSPROC     Hooked Procedures                               *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> PROCS       Support Procedures                              *
 ****************************************************************************/

PROC pnGetFileSettings(INTEGER lpiWhichOne)

    STRING  lsBuf1[80]  = "",
            lsBuf2[80]  = ""

    lsBuf1 = psGetProStr("Custom File Definitions",
                            Format("FileExtension", lpiWhichOne))
    lsBuf2 = psGetProStr("Custom File Definitions",
                            Format("SearchString", lpiWhichOne))
    IF ( (Length(lsBuf1)) AND (Length(lsBuf2)) )
        SetGlobalStr(Format("gsMFFndFExt", lpiWhichOne:2:"0"), lsBuf1)
        SetGlobalStr(Format("gsMFFndSStr", lpiWhichOne:2:"0"), lsBuf2)
    ELSE
        SetGlobalStr(Format("gsMFFndFExt", lpiWhichOne:2:"0"), "")
        SetGlobalStr(Format("gsMFFndSStr", lpiWhichOne:2:"0"), "")
    ENDIF
END pnGetFileSettings

PROC pnGetProgMsgsThreshold()

    STRING lsNum[8] = Str(GetGlobalInt("giMFFndProgMsgsTHold"))

    IF (AskNumeric("New threshold?", lsNum))
        SetGlobalInt("giMFFndProgMsgsTHold", Val(lsNum))
    ENDIF
END pnGetProgMsgsThreshold

STRING PROC psGetProStr(STRING lpsSection, STRING lpsKeyword)

    STRING  lsSrchTx[80] = '',
            lsValue[63]

    IF (LFind("[" + lpsSection + "]", "i"))
        EndLine()
        UnMarkBlock()
        MarkLine()
        lsSrchTx = "^\["
        IF NOT LFind(lsSrchTx, "ix")    // Goto next section
            EndFile()                  // or End of File
        ENDIF
        MarkLine()
        lsSrchTx = "^" + lpsKeyword + "="
        IF (LFind(lsSrchTx, "lgix"))    // Search in this section only
            BegLine()
            IF (LFind("=",""))
                lsValue = GetText(CurrCol()+1, CurrLineLen() - CurrCol())
            ENDIF
        ENDIF
    ENDIF
    UnMarkBlock()
    BegFile()
    Return(lsValue)
END psGetProStr

PROC pnGetSettings(INTEGER lpiFromMenu)

    INTEGER liBlkMarked = IsBlockMarked(),
            liBid,
            liCid       = GetBufferId(),
            liMsgLevel  = Set(MsgLevel, _WARNINGS_ONLY_)

    STRING  lsBuf1[80]  = ""

    IF (liBlkMarked)
        PushBlock()
    ENDIF
    liBid = CreateTempBuffer()
    InsertFile(GetGlobalStr("gsMFFndIniFile"))
    Set(MsgLevel, liMsgLevel)

    /* HISTORY USAGE ********************************************************/

    SetGlobalInt("giMFFndHistType",
                    IIF((Upper(psGetProStr("History Usage",
                                            "UseOwnHistories")) == "TRUE"),
                            koHIST_OWN, koHIST_STD))

    /* FILL CHARACTERS ******************************************************/

    lsBuf1 = psGetProStr("Fill Characters", "SelectLineCharacter")
    IF (Length(lsBuf1) <> 1)
        lsBuf1 = "þ"
    ENDIF
    SetGlobalStr("gsMFFndSelLineChar", lsBuf1)

    lsBuf1 = psGetProStr("Fill Characters", "BufferLineCharacter")
    IF (Length(lsBuf1) <> 1)
        lsBuf1 = "ù"
    ENDIF
    SetGlobalStr("gsMFFndBufLineChar", lsBuf1)

    /* SECONDARY LINE HIT HANDLING ******************************************/

    pnGetTrueFalseAsk("Group Hits", "DistinguishGroupHits",
                        "giMFFndDistGrpHits", "giMFFndDistGrpHitsAskDef")

    /* MINIMAL SCREEN UPDATING **********************************************/

    pnGetTrueFalseAsk("Screen Updating", "Minimal",
                        "giMFFndMinScrnUpds", "giMFFndMinScrnUpdsAskDef")

    /* ACTION ON ERRORS *****************************************************/

    pnGetTrueFalseAsk("Function Search", "PauseOnErrors",
                        "giMFFndPauseOnErr", "giMFFndPauseOnErrAskDef")

    /* DISPLAY OF PROGRESS MESSAGES *****************************************/

    pnGetTrueFalseAsk("Progress", "Messages",
                        "giMFFndProgMsgs", "giMFFndprogMsgsAskDef")

    /* PROGRESS MESSAGES THRESHOLD ******************************************/

    SetGlobalInt("giMFFndProgMsgsTHold",
                    Val(psGetProStr("Progress", "Threshold")))

    /* VERIFICATION BEFORE REPLACE ******************************************/

    pnGetTrueFalseAsk("Replace", "Verify",
                        "giMFFndVerBefRep", "giMFFndVerBefRepAskDef")

    /* WORD SEARCH CASE SENSITIVITY *****************************************/

    pnGetTrueFalseAsk("Word Search", "CaseSensitive",
                        "giMFFndWrdSrchCsSens", "giMFFndWrdSrchCsSensAskDef")

    /* CUSTOM FILE SETTINGS *************************************************/

    pnGetFileSettings(1)
    pnGetFileSettings(2)
    pnGetFileSettings(3)
    pnGetFileSettings(4)
    pnGetFileSettings(5)
    pnGetFileSettings(6)
    pnGetFileSettings(7)
    pnGetFileSettings(8)
    pnGetFileSettings(9)
    pnGetFileSettings(10)

    /* FINISH UP ************************************************************/

    GotoBufferId(liCid)
    AbandonFile(liBid)
    IF (liBlkMarked)
        PopBlock()
    ENDIF
    IF (lpiFromMenu)
        mnConfig()
    ENDIF
END pnGetSettings

STRING PROC psGetSettingStr(STRING lpsWhichSetting, STRING lpsDefAsk)
    CASE (GetGlobalInt(lpsWhichSetting))
        WHEN TRUE
            Return("Yes")
        WHEN FALSE
            Return("No")
    ENDCASE
    Return(Format("Ask/", IIF((GetGlobalInt(lpsDefAsk)), "yes", "no")))
END psGetSettingStr

PROC pnGetTrueFalseAsk(STRING lpsSection, STRING lpsItem,
                                STRING lpsGlobVar, STRING lpsGlobVarDefAsk)

    INTEGER liSetting

    CASE (Upper(psGetProStr(lpsSection, lpsItem)))
        WHEN "TRUE"
            liSetting = TRUE
        WHEN "FALSE"
            liSetting = FALSE
        OTHERWISE
            liSetting = koASK
    ENDCASE
    SetGlobalInt(lpsGlobVar, liSetting)
    IF (Upper(psGetProStr(lpsSection, "DefaultOnAsk")) == "YES")
        liSetting = TRUE
    ELSE
        liSetting = FALSE
    ENDIF
    SetGlobalInt(lpsGlobVarDefAsk, liSetting)
END pnGetTrueFalseAsk

PROC pnHistType()
    IF (GetGlobalInt("giMFFndHistType") == koHIST_OWN)
        PushKey(<CursorDown>)
    ENDIF
    mnHistType()
END pnHistType

PROC pnPickChar(STRING lpsSetting)

    INTEGER liChr       = 0,
            liOk        = FALSE,
            liCurrChar  = Asc(GetGlobalStr(lpsSetting)),
            liBid

    PushPosition()
    liBid = CreateTempBuffer()
    WHILE ( (AddLine(format(Chr(liChr):4))) AND (liChr <> 255) )
        liChr = liChr + 1
    ENDWHILE
    BegFile()
    IF (liCurrChar > 0)
        GotoLine(liCurrChar + 1)
    ENDIF
    liOk = List("Char", 8)
    liChr = CurrLine() - 1
    PopPosition()
    IF (liOk)
        SetGlobalStr(lpsSetting, chr(liChr))
    ENDIF
    AbandonFile(liBid)
END pnPickChar

PROC pnPromptUserForSetting(STRING lpsWhichSetting, STRING lpsDefAsk)

    INTEGER liGotNewSetting = TRUE,
            liNewSetting,
            liAgain         = FALSE

    PFUS_Again:
    IF (liAgain)
        PushKey(<CursorDown>)
        PushKey(<CursorDown>)
    ELSE
        CASE (GetGlobalInt(lpsWhichSetting))
            WHEN TRUE
                PushKey(<CursorDown>)
            WHEN FALSE
                PushKey(<CursorDown>)
                PushKey(<CursorDown>)
        ENDCASE
    ENDIF
    mnYesNoAsk()
    CASE MenuOption()
        WHEN 1  // Yes
            liNewSetting = TRUE
        WHEN 2  // No
            liNewSetting = FALSE
        WHEN 3  // Ask
            liNewSetting = koASK
            IF (GetGlobalInt(lpsWhichSetting))
                PushKey(<CursorDown>)
            ENDIF
            CASE (YesNo("Default when prompting?"))
                WHEN 1
                    SetGlobalInt(lpsDefAsk, TRUE)
                WHEN 2
                    SetGlobalInt(lpsDefAsk, FALSE)
                OTHERWISE
                    liAgain = TRUE
                    GOTO PFUS_Again
            ENDCASE
        OTHERWISE
            liGotNewSetting = FALSE
    ENDCASE
    IF (liGotNewSetting)
        SetGlobalInt(lpsWhichSetting, liNewSetting)
    ENDIF
END pnPromptUserForSetting

PROC pnSetFileOption(INTEGER lpsIsExt, STRING lpsOpt, STRING lpsDescription)

    STRING  lsCompSetting[80]   = "",
            lsOldExt[4]         = "",
            lsNewExt[4]         = "",
            lsOldValue[80]      = "",
            lsNewValue[80]      = ""

    IF (lpsIsExt)
        lsOldExt = GetGlobalStr(lpsOpt)
        lsNewExt = GetGlobalStr(lpsOpt)
        IF ( (Ask(("New Value for " + lpsDescription), lsNewExt)) AND
             (lsNewExt <> lsOldExt) )
            lsNewExt = Trim(lsNewExt)
            IF (Length(lsNewExt))
                IF ( (NOT Pos(".", lsNewExt)) AND (Length(lsNewExt) < 4) )
                    lsNewExt = "." + lsNewExt
                ENDIF
            ELSE
                lsCompSetting = Format("gsMFFndSStr",
                                        SubStr(lpsOpt, 13, 2))
                SetGlobalStr(lsCompSetting, "")
            ENDIF
            SetGlobalStr(lpsOpt, lsNewExt)
        ENDIF
    ELSE
        lsOldValue = GetGlobalStr(lpsOpt)
        lsNewValue = GetGlobalStr(lpsOpt)
        IF ( (Ask(("New Value for " + lpsDescription), lsNewValue)) AND
             (lsNewValue <> lsOldValue) )
            lsNewValue = Trim(lsNewValue)
            IF (NOT Length(lsNewValue))
                lsCompSetting = Format("gsMFFndFExt",
                                        SubStr(lpsOpt, 13, 2))
                SetGlobalStr(lsCompSetting, "")
            ENDIF
            SetGlobalStr(lpsOpt, lsNewValue)
        ENDIF
    ENDIF
    Pushkey(<Enter>)
    Pushkey(<Escape>)
END pnSetFileOption

PROC pnSetFileSettings(INTEGER lpiWhichOne)
    pnSetProStr("Custom File Definitions", Format("FileExtension",
                                                    lpiWhichOne),
        GetGlobalStr(Format("gsMFFndFExt", lpiWhichOne:2:"0")))
    pnSetProStr("Custom File Definitions", Format("SearchString",
                                                    lpiWhichOne),
        GetGlobalStr(Format("gsMFFndSStr", lpiWhichOne:2:"0")))
END pnSetFileSettings

PROC pnSetProStr(STRING lpsSection, STRING lpsKeyword, STRING lpsValue)

    STRING  lsSrchTx[80]    = ""

    IF (LFind("[" + lpsSection + "]", "i"))
        EndLine()
        UnMarkBlock()
        MarkLine()
        lsSrchTx = "^\["
        IF (NOT LFind(lsSrchTx, "ix"))
            EndFile()
        ENDIF
        MarkLine()
        lsSrchTx = "^" + lpsKeyword + "="
        IF (LFind(lsSrchTx, "gixl"))
            BegLine()
            IF (LFind("=", ""))
                Right()
                DelToEOL()
                InsertText(lpsValue)
            ENDIF
        ELSE
            GotoBlockBegin()
            AddLine(lpsKeyword + "=" + lpsValue)
        ENDIF
    ELSE                        // New section
        EndFile()
        AddLine()
        AddLine("[" + lpsSection + "]")
        AddLine(lpsKeyword + "=" + lpsValue)
    ENDIF
    BegFile()
    IF (CurrLineLen() < 1)  // Caused by AddLine in an empty file
        DelLine()
    ENDIF
    BegFile()
END pnSetProStr

PROC pnSetSettings()

    INTEGER liBlkMarked         = IsBlockMarked(),
            liBid,
            liCid               = GetBufferId(),
            liMonth,
            liDay,
            liYear,
            liDayOfWeek,
            liHr,
            liMin,
            liSec,
            liHun

    IF (liBlkMarked)
        PushBlock()
    ENDIF

    /* MARK - ERA Tue 02-21-1995 10:25:44 ***********************************
     *  ADD VERIFICATION THAT THE FILE WAS OPENED
     ************************************************************************/

    liBid = EditFile(GetGlobalStr("gsMFFndIniFile"))

    /* HISTORY USAGE ********************************************************/

    pnSetProStr("History Usage", "UseOwnHistories",
        IIF((GetGlobalInt("giMFFndHistType") == koHIST_OWN),
                "TRUE", "FALSE"))

    /* FILL CHARACTERS ******************************************************/

    pnSetProStr("Fill Characters", "SelectLineCharacter",
        GetGlobalStr("gsMFFndSelLineChar"))
    pnSetProStr("Fill Characters", "BufferLineCharacter",
        GetGlobalStr("gsMFFndBufLineChar"))

    /* SECONDARY LINE HIT HANDLING ******************************************/

    pnSetTrueFalseAsk("Group Hits", "DistinguishGroupHits",
                        "giMFFndDistGrpHits", "giMFFndDistGrpHitsAskDef")

    /* MINIMAL SCREEN UPDATING **********************************************/

    pnSetTrueFalseAsk("Screen Updating", "Minimal",
                        "giMFFndMinScrnUpds", "giMFFndMinScrnUpdsAskDef")

    /* ACTION ON ERRORS *****************************************************/

    pnSetTrueFalseAsk("Function Search", "PauseOnErrors",
                        "giMFFndPauseOnErr", "giMFFndPauseOnErrAskDef")

    /* DISPLAY OF PROGRESS MESSAGES *****************************************/

    pnSetTrueFalseAsk("Progress", "Messages",
                        "giMFFndProgMsgs", "giMFFndProgMsgsAskDef")

    /* PROGRESS MESSAGES THRESHOLD ******************************************/

    pnSetProStr("Progress", "Threshold",
                Str(GetGlobalInt("giMFFndProgMsgsTHold")))

    /* VERIFICATION BEFORE REPLACE ******************************************/

    pnSetTrueFalseAsk("Replace", "Verify",
                        "giMFFndVerBefRep", "giMFFndVerBefRepAskDef")

    /* WORD SEARCH CASE SENSITIVITY *****************************************/

    pnSetTrueFalseAsk("Word Search", "CaseSensitive",
                        "giMFFndWrdSrchCsSens", "giMFFndWrdSrchCsSensAskDef")

    /* CUSTOM FILE SETTINGS *************************************************/

    pnSetFileSettings(1)
    pnSetFileSettings(2)
    pnSetFileSettings(3)
    pnSetFileSettings(4)
    pnSetFileSettings(5)
    pnSetFileSettings(6)
    pnSetFileSettings(7)
    pnSetFileSettings(8)
    pnSetFileSettings(9)
    pnSetFileSettings(10)

    /* FINISH UP ************************************************************/

    BegFile()
    MarkLine()
    Down(5)
    MarkLine()
    IF (LFind("DATE @:", "XLG"))
        WordRight()
        IF (CurrChar() < 0) // AT OR BEYOND EOL
            TabRight()
        ENDIF
        GetDate(liMonth, liDay, liYear, liDayOfWeek)
        GetTime(liHr, liMin, liSec, liHun)
        InsertText(Format(SubStr("SunMonTueWedThuFriSat",
                                    ((liDayOfWeek - 1) * 3 + 1), 3),
                            " ", liMonth:2:"0", Chr(Query(DateSeparator)),
                            liDay:2:"0", Chr(Query(DateSeparator)),
                            liYear:4:"0", " ", liHr:2:"0", ":", liMin:2:"0",
                            ":", liSec:2:"0"), _OVERWRITE_)
    ENDIF
    SaveFile()
    GotoBufferId(liCid)
    AbandonFile(liBid)
    IF (liBlkMarked)
        PopBlock()
    ENDIF
END pnSetSettings

PROC pnSetTrueFalseAsk(STRING lpsSection, STRING lpsItem,
                                STRING lpsGlobVar, STRING lpsGlobVarDefAsk)

    STRING lsSetting[5] = ""

    CASE (GetGlobalInt(lpsGlobVar))
        WHEN TRUE
            lsSetting = "TRUE"
        WHEN FALSE
            lsSetting = "FALSE"
        OTHERWISE
            lsSetting = "ASK"
    ENDCASE
    pnSetProStr(lpsSection, lpsItem, lsSetting)
    IF (GetGlobalInt(lpsGlobVarDefAsk) == TRUE)
        lsSetting = "YES"
    ELSE
        lsSetting = "NO"
    ENDIF
    pnSetProStr(lpsSection, "DefaultOnAsk", lsSetting)
END pnSetTrueFalseAsk

/****************************************************************************
 *  SECTION --> PROCS       User Procedures                                 *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> MENU        The Menus                                       *
 ****************************************************************************/

MENU mnConfig()
    Title = "MFFind v5.8 - Configuration"
    History
    Command = UpdateDisplay(_ALL_WINDOWS_REFRESH_|_HELPLINE_REFRESH_)

    // HOTKEY USE:  CDFHMPOVWRS

    "&Custom File Settings             ",
        mnFileSettings(),
        DontClose,
        "Define custom file settings for function searches"
    "&Distinguish Secondary Group Hits"
            [psGetSettingStr("giMFFndDistGrpHits",
                                "giMFFndDistGrpHitsAskDef"):7],
        pnPromptUserForSetting("giMFFndDistGrpHits",
                                "giMFFndDistGrpHitsAskDef"),
        DontClose,
        "Secondary 'hits' in the 'hit-file' are marked as such"
    "&Fill Characters                  ",
        mnFillCharacters(),
        DontClose,
        "Specify characters to use as fillers in the 'hit-file'"
    "&Histories" [IIF((GetGlobalInt("giMFFndHistType") == koHIST_OWN),
                        "OWN", "STD"):3],
        pnHistType(),
        DontClose,
        "Specify which histories to use"
    "&Minimal Screen Updating"
            [psGetSettingStr("giMFFndMinScrnUpds",
                                "giMFFndMinScrnUpdsAskDef"):7],
        pnPromptUserForSetting("giMFFndMinScrnUpds",
                                "giMFFndMinScrnUpdsAskDef"),
        DontClose,
        "Provides the fasted performance"
    "&Pause on 'Find Functions' Errors"
            [psGetSettingStr("giMFFndPauseOnErr",
                                "giMFFndPauseOnErrAskDef"):7],
        pnPromptUserForSetting("giMFFndPauseOnErr",
                                "giMFFndPauseOnErrAskDef"),
        DontClose,
        "Pauses on un-recognized files when searching for functions"
    "Pr&ogress Messages                ",
        mnProgMsgs(),
        DontClose,
        "Specify progress messages settings"
    "&Verify Before Replacing"
            [psGetSettingStr("giMFFndVerBefRep",
                                "giMFFndVerBefRepAskDef"):7],
        pnPromptUserForSetting("giMFFndVerBefRep",
                                "giMFFndVerBefRepAskDef"),
        DontClose,
        "Verify that the resulting string(s) doesn't already exist in a file"
    "&Word Search Case Sensitive"
            [psGetSettingStr("giMFFndWrdSrchCsSens",
                                "giMFFndWrdSrchCsSensAskDef"):7],
        pnPromptUserForSetting("giMFFndWrdSrchCsSens",
                                "giMFFndWrdSrchCsSensAskDef"),
        DontClose,
        "Specify whether word searches should be case sensitive or not"
    "",
        ,
        Divide
    "&Restore Settings from INI File",
        pnGetSettings(TRUE),
        CloseBefore,
        "Reads and activates all settings from MFFIND.INI"
    "&Save Current Settings as default",
        pnSetSettings(),
        DontClose,
        "Saves all settings to MFFIND.INI"
END mnConfig

MENU mnFileSettings()
    Title = "Custom File Settings"
    History

    // HOTKEY USE: <NONE>

    "File Extension #1 "
            [GetGlobalStr("gsMFFndFExt01"):4],
        pnSetFileOption(TRUE, "gsMFFndFExt01", "File Extension #1"),
        DontClose
    "Search String  #1 "
            [GetGlobalStr("gsMFFndSStr01"):30],
        pnSetFileOption(FALSE, "gsMFFndSStr01", "Search String #1"),
        DontClose
    "File Extension #2 "
            [GetGlobalStr("gsMFFndFExt02"):4],
        pnSetFileOption(TRUE, "gsMFFndFExt02", "File Extension #2"),
        DontClose
    "Search String  #2 "
            [GetGlobalStr("gsMFFndSStr02"):30],
        pnSetFileOption(FALSE, "gsMFFndSStr02", "Search String #2"),
        DontClose
    "File Extension #3 "
            [GetGlobalStr("gsMFFndFExt03"):4],
        pnSetFileOption(TRUE, "gsMFFndFExt03", "File Extension #3"),
        DontClose
    "Search String  #3 "
            [GetGlobalStr("gsMFFndSStr03"):30],
        pnSetFileOption(FALSE, "gsMFFndSStr03", "Search String #3"),
        DontClose
    "File Extension #4 "
            [GetGlobalStr("gsMFFndFExt04"):4],
        pnSetFileOption(TRUE, "gsMFFndFExt04", "File Extension #4"),
        DontClose
    "Search String  #4 "
            [GetGlobalStr("gsMFFndSStr04"):30],
        pnSetFileOption(FALSE, "gsMFFndSStr04", "Search String #4"),
        DontClose
    "File Extension #5 "
            [GetGlobalStr("gsMFFndFExt05"):4],
        pnSetFileOption(TRUE, "gsMFFndFExt05", "File Extension #5"),
        DontClose
    "Search String  #5 "
            [GetGlobalStr("gsMFFndSStr05"):30],
        pnSetFileOption(FALSE, "gsMFFndSStr05", "Search String #5"),
        DontClose
    "File Extension #6 "
            [GetGlobalStr("gsMFFndFExt06"):4],
        pnSetFileOption(TRUE, "gsMFFndFExt06", "File Extension #6"),
        DontClose
    "Search String  #6 "
            [GetGlobalStr("gsMFFndSStr06"):30],
        pnSetFileOption(FALSE, "gsMFFndSStr06", "Search String #6"),
        DontClose
    "File Extension #7 "
            [GetGlobalStr("gsMFFndFExt07"):4],
        pnSetFileOption(TRUE, "gsMFFndFExt07", "File Extension #7"),
        DontClose
    "Search String  #7 "
            [GetGlobalStr("gsMFFndSStr07"):30],
        pnSetFileOption(FALSE, "gsMFFndSStr07", "Search String #7"),
        DontClose
    "File Extension #8 "
            [GetGlobalStr("gsMFFndFExt08"):4],
        pnSetFileOption(TRUE, "gsMFFndFExt08", "File Extension #8"),
        DontClose
    "Search String  #8 "
            [GetGlobalStr("gsMFFndSStr08"):30],
        pnSetFileOption(FALSE, "gsMFFndSStr08", "Search String #8"),
        DontClose
    "File Extension #9 "
            [GetGlobalStr("gsMFFndFExt09"):4],
        pnSetFileOption(TRUE, "gsMFFndFExt09", "File Extension #9"),
        DontClose
    "Search String  #9 "
            [GetGlobalStr("gsMFFndSStr09"):30],
        pnSetFileOption(FALSE, "gsMFFndSStr09", "Search String #9"),
        DontClose
    "File Extension #10"
            [GetGlobalStr("gsMFFndFExt10"):4],
        pnSetFileOption(TRUE, "gsMFFndFExt10", "File Extension #10"),
        DontClose
    "Search String  #10"
            [GetGlobalStr("gsMFFndSStr10"):30],
        pnSetFileOption(FALSE, "gsMFFndSStr10", "Search String #10"),
        DontClose
END mnFileSettings

MENU mnFillCharacters()
    Title = "Fill Characters"
    History

    // HOTKEY USE:  BF

    "&Buffer Line Fill Character"
            [GetGlobalStr("gsMFFndBufLineChar"):1],
        pnPickChar("gsMFFndBufLineChar"),
        DontClose,
        "Character used to mark the beginning of a file's hits in the " +
            "'hit-file'"
    "&Select Line Fill Character"
            [GetGlobalStr("gsMFFndSelLineChar"):1],
        pnPickChar("gsMFFndSelLineChar"),
        DontClose,
        "Character used to mark the 'Select This Line To Edit' line in " +
            "the 'hit-file'"
END mnFillCharacters

MENU mnHistType()

    // HOTKEY USE:  OS

    "&Own",
        SetGlobalInt("giMFFndHistType", koHIST_OWN),
        CloseBefore,
        "Use separate histories"
    "&Standard",
        SetGlobalInt("giMFFndHistType", koHIST_STD),
        CloseBefore,
        "Use same histories as Find & Replace"
END mnHistType

MENU mnProgMsgs()
    Title = "Progress Messages"
    History

    // HOTKEY USE:  AD

    "&Display "
            [psGetSettingStr("giMFFndProgMsgs",
                                "giMFFndProgMsgsAskDef"):7],
        pnPromptUserForSetting("giMFFndProgMsgs",
                                "giMFFndProgMsgsAskDef"),
        DontClose,
        "Display detailed progress messages"
    "&Automatic Display Threshold"
            [GetGlobalInt("giMFFndProgMsgsTHold"):8],
        pnGetProgMsgsThreshold(),
        DontClose,
        "Set when to automatically display progress messages (total " +
            "number of lines)"
END mnProgMsgs

MENU mnYesNoAsk()
    "&Yes",
        ,
        CloseBefore
    "&No",
        ,
        CloseBefore
    "&Ask",
        ,
        CloseBefore
END mnYesNoAsk

/****************************************************************************
 *  SECTION --> KEYS        Key Bindings                                    *
 ****************************************************************************/

