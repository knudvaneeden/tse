/*
    fileinfo.s
    Version : 1.0.0.0.1
    Date    : 2026-09-09
    LLM     : OpenAI GPT-5 Codex

    Windows-compatible replacement for the original FILEINFO.S.
*/

#INCLUDE ["finfo32.inc"]

PROC PROCChangeAttribute(INTEGER maskI)
    STRING fileNameS[255] = CurrFileName() + Chr(0)
    INTEGER attributesI = FInfoGetAttributes(fileNameS)

    IF (attributesI < 0)
        return()
    ENDIF
    IF (attributesI & maskI)
        attributesI = attributesI & ~maskI
    ELSE
        attributesI = attributesI | maskI
    ENDIF
    FInfoSetAttributes(fileNameS, attributesI)
END

MENU FileAttributesMenu()
    History
    Title = "Change File Attributes"
    "&Read-only"
        [FNAttributeStateS(FInfoGetAttributes(CurrFileName() + Chr(0)), FINFO_READONLY):3],
        PROCChangeAttribute(FINFO_READONLY),
        DontClose
    "&Archive"
        [FNAttributeStateS(FInfoGetAttributes(CurrFileName() + Chr(0)), FINFO_ARCHIVE):3],
        PROCChangeAttribute(FINFO_ARCHIVE),
        DontClose
    "&System"
        [FNAttributeStateS(FInfoGetAttributes(CurrFileName() + Chr(0)), FINFO_SYSTEM):3],
        PROCChangeAttribute(FINFO_SYSTEM),
        DontClose
    "&Hidden"
        [FNAttributeStateS(FInfoGetAttributes(CurrFileName() + Chr(0)), FINFO_HIDDEN):3],
        PROCChangeAttribute(FINFO_HIDDEN),
        DontClose
END

PROC Main()
    STRING fileNameS[255] = CurrFileName() + Chr(0)
    STRING displayNameS[255] = CurrFileName()
    STRING sizeS[40] = ""
    INTEGER attributesI = FInfoGetAttributes(fileNameS)
    INTEGER sizeI = FInfoGetSize(fileNameS)
    INTEGER dateI = FInfoGetDate(fileNameS)
    INTEGER timeI = FInfoGetTime(fileNameS)
    INTEGER answerI

    IF (attributesI < 0)
        Warn("Unable to read the current file information. Save the buffer first and verify that finfo32.dll can be loaded.")
        return()
    ENDIF

    IF (sizeI < 0)
        sizeS = "Greater than 2147483647 bytes"
    ELSE
        sizeS = Str(sizeI) + " bytes"
    ENDIF

    answerI = YesNo(Format(
        "File: ", displayNameS,
        " | Size: ", sizeS,
        " | Date: ", FNDosDateS(dateI),
        " | Time: ", FNDosTimeS(timeI),
        " | Attributes: ", FNAttributesS(attributesI),
        " | Change attributes?"))

    IF (answerI == 1)
        FileAttributesMenu()
    ENDIF
    Warn("FINFO_32 finished. File attributes: ", FNAttributesS(FInfoGetAttributes(fileNameS)))
END
