/*
    bh.s

    Launches the portable BH Windows Help search from TSE Pro.

    Version : 1.0.0.0.12
    Date    : 2026-09-09
    Time    : 22:56 CEST
    LLM     : OpenAI Codex
*/

STRING PROC FNCleanHlpFilenameS(STRING filenameS)
    STRING resultS[255] = filenameS

    IF (Length(resultS) > 0)
        IF (SubStr(resultS, 1, 1) == Chr(34))
            resultS = SubStr(resultS, 2, 255)
        ENDIF
    ENDIF

    IF (Length(resultS) > 0)
        IF (SubStr(resultS, Length(resultS), 1) == Chr(34))
            resultS = SubStr(resultS, 1, Length(resultS) - 1)
        ENDIF
    ENDIF

    RETURN(resultS)
END

PROC Main()
    STRING wordS[80] = GetWord(1)
    STRING hlpFilenameS[255] = ""
    STRING bhDirectoryS[255] = SplitPath(CurrMacroFilename(),
                                         _DRIVE_ | _PATH_)
    STRING bhFilenameS[255] = bhDirectoryS + "bh.exe"
    STRING commandS[255] = ""

    IF (Length(wordS) == 0)
        Ask("Windows Help search", wordS, _EDIT_HISTORY_)
    ENDIF

    IF (Length(wordS) > 0)
        IF (Ask("Windows HLP filename", hlpFilenameS, _EDIT_HISTORY_))
            hlpFilenameS = FNCleanHlpFilenameS(hlpFilenameS)
            IF (Length(hlpFilenameS) > 0)
                commandS = Chr(34) + bhFilenameS + Chr(34) + " " +
                           Chr(34) + hlpFilenameS + Chr(34) + " " +
                           Chr(34) + wordS + Chr(34)
                Dos(commandS, _DONT_PROMPT_)
            ENDIF
        ENDIF
    ENDIF
END
