/******************************************************************************
  Filename : scrollwordcarriagereturn.s
  Version  : 1.0.0.0.1
  Date     : 2026-09-25
  Purpose  : Return the horizontal view to a configurable left position
             when typing reaches a configurable right position.
  LLM      : OpenAI Codex (GPT-6)
******************************************************************************/

STRING GSVersion[20] = "1.0.0.0.1"
INTEGER GBEnabled = FALSE
INTEGER GIBeginPercent = 25
INTEGER GIEndPercent = 75

PROC PROCReadSettings()
    STRING iniFilenameS[255] = ""

    iniFilenameS = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + "scrollwordcarriagereturn.ini"
    GIBeginPercent = GetProfileInt("scrollwordcarriagereturn", "targetbegin", 25, iniFilenameS)
    GIEndPercent = GetProfileInt("scrollwordcarriagereturn", "targetend", 75, iniFilenameS)

    IF GIBeginPercent < 1
        GIBeginPercent = 1
    ELSEIF GIBeginPercent > 99
        GIBeginPercent = 99
    ENDIF
    IF GIEndPercent < 2
        GIEndPercent = 2
    ELSEIF GIEndPercent > 100
        GIEndPercent = 100
    ENDIF
    IF GIBeginPercent >= GIEndPercent
        GIBeginPercent = 25
        GIEndPercent = 75
    ENDIF
END

PROC PROCScrollWordCarriageReturn()
    INTEGER windowColumnsI = 0
    INTEGER beginColumnI = 0
    INTEGER newOffsetI = 0

    windowColumnsI = Query(WindowCols)
    IF windowColumnsI >= 2
        beginColumnI = (windowColumnsI * GIBeginPercent) / 100
        IF beginColumnI < 1
            beginColumnI = 1
        ENDIF
        newOffsetI = CurrCol() - beginColumnI
        IF newOffsetI < 0
            newOffsetI = 0
        ENDIF
        GotoXoffset(newOffsetI)
    ENDIF
END

PROC PROCOnSelfInsert()
    INTEGER windowColumnsI = 0
    INTEGER endColumnI = 0

    IF GBEnabled
        windowColumnsI = Query(WindowCols)
        IF windowColumnsI >= 2
            endColumnI = (windowColumnsI * GIEndPercent) / 100
            IF endColumnI < 2
                endColumnI = 2
            ENDIF
            IF CurrCol() - CurrXoffset() >= endColumnI
                PROCScrollWordCarriageReturn()
            ENDIF
        ENDIF
    ENDIF
END

PROC Main()
    STRING iniFilenameS[255] = ""
    STRING silentS[10] = ""

    iniFilenameS = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + "scrollwordcarriagereturn.ini"
    PROCReadSettings()

    IF GBEnabled
        UnHook(PROCOnSelfInsert)
        GBEnabled = FALSE
    ELSE
        IF Hook(_ON_SELFINSERT_, PROCOnSelfInsert)
            GBEnabled = TRUE
        ENDIF
    ENDIF

    silentS = GetProfileStr("scrollwordcarriagereturn", "silent", "false", iniFilenameS)
    IF EquiStr(silentS, "true") == FALSE
        IF GBEnabled
            Warn("SCROLLWORDCARRIAGERETURN ", GSVersion, ": automatic horizontal return enabled.")
        ELSE
            Warn("SCROLLWORDCARRIAGERETURN ", GSVersion, ": automatic horizontal return disabled.")
        ENDIF
    ENDIF
END

<CtrlAltShift C> PROCScrollWordCarriageReturn()
