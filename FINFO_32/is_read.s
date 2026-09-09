/*
    is_read.s
    Version : 1.0.0.0.1
    Date    : 2026-09-09
    LLM     : OpenAI GPT-5 Codex
*/

#INCLUDE ["finfo32.inc"]

PROC Main()
    STRING fileNameS[255] = CurrFileName() + Chr(0)
    INTEGER attributesI = FInfoGetAttributes(fileNameS)

    IF ((attributesI >= 0) AND (attributesI & FINFO_READONLY))
        SetGlobalInt("giCurrFileIsReadOnly", TRUE)
    ELSE
        SetGlobalInt("giCurrFileIsReadOnly", FALSE)
    ENDIF
    return()
END
