/******************************************************************************
  Filename : scrollword.s
  Version  : 1.0.0.0.0
  Date     : 2026-09-21
  Purpose  : Horizontally scroll the current view so the cursor character,
             and therefore the word at the cursor, is centered.
  LLM      : OpenAI Codex (GPT-5)
******************************************************************************/

STRING GSVersion[20] = "1.0.0.0.0"

PROC PROCScrollWordToCenter()
    INTEGER targetPercentI = 50
    INTEGER windowColumnsI = 0
    INTEGER targetColumnI = 0
    INTEGER newOffsetI = 0
    STRING iniFilenameS[255] = ""

    iniFilenameS = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + "scrollword.ini"
    targetPercentI = GetProfileInt("scrollword", "target", 50, iniFilenameS)

    IF targetPercentI < 1
        targetPercentI = 1
    ELSEIF targetPercentI > 100
        targetPercentI = 100
    ENDIF

    windowColumnsI = Query(WindowCols)
    targetColumnI = (windowColumnsI * targetPercentI) / 100

    IF targetColumnI < 1
        targetColumnI = 1
    ENDIF

    newOffsetI = CurrCol() - targetColumnI

    IF newOffsetI < 0
        newOffsetI = 0
    ENDIF

    GotoXoffset(newOffsetI)
END

PROC Main()
    PROCScrollWordToCenter()
    Warn("SCROLLWORD ", GSVersion, ": the word at the cursor is now centered horizontally.")
END

<CtrlAltShift C> PROCScrollWordToCenter()
