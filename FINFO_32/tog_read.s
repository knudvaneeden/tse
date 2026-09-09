/*
    tog_read.s
    Version : 1.0.0.0.1
    Date    : 2026-09-09
    LLM     : OpenAI GPT-5 Codex
*/

#INCLUDE ["finfo32.inc"]

PROC Main()
    STRING fileNameS[255] = CurrFileName() + Chr(0)
    INTEGER attributesI = FInfoGetAttributes(fileNameS)
    INTEGER resultI

    IF (attributesI < 0)
        Warn("Unable to read the current file attributes.")
        return()
    ENDIF

    IF (attributesI & FINFO_READONLY)
        attributesI = attributesI & ~FINFO_READONLY
    ELSE
        attributesI = attributesI | FINFO_READONLY
    ENDIF

    resultI = FInfoSetAttributes(fileNameS, attributesI)
    IF (resultI < 0)
        Warn("Unable to change the current file's read-only attribute.")
    ELSE
        Warn("The current file's read-only attribute was toggled successfully.")
    ENDIF
END
