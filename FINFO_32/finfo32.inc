/*
    finfo32.inc
    Version : 1.0.0.0.1
    Date    : 2026-09-09
    LLM     : OpenAI GPT-5 Codex

    Shared declarations for the Windows-compatible FINFO_32 macros.
*/

#DEFINE FINFO_NORMAL   128
#DEFINE FINFO_READONLY 1
#DEFINE FINFO_HIDDEN   2
#DEFINE FINFO_SYSTEM   4
#DEFINE FINFO_ARCHIVE  32

DLL "finfo32.dll"
    INTEGER PROC PASCAL FInfoGetAttributes(STRING fileNameS : cstrval) : "FINFOGETATTRIBUTES"
    INTEGER PROC PASCAL FInfoSetAttributes(STRING fileNameS : cstrval,
                                           INTEGER attributesI) : "FINFOSETATTRIBUTES"
    INTEGER PROC PASCAL FInfoGetSize(STRING fileNameS : cstrval) : "FINFOGETSIZE"
    INTEGER PROC PASCAL FInfoGetDate(STRING fileNameS : cstrval) : "FINFOGETDATE"
    INTEGER PROC PASCAL FInfoGetTime(STRING fileNameS : cstrval) : "FINFOGETTIME"
END

STRING PROC FNAttributeStateS(INTEGER attributesI, INTEGER maskI)
    IF (attributesI & maskI)
        return("Yes")
    ENDIF
    return("No")
END

STRING PROC FNAttributesS(INTEGER attributesI)
    STRING resultS[80] = ""

    IF ((attributesI & (FINFO_READONLY | FINFO_HIDDEN | FINFO_SYSTEM | FINFO_ARCHIVE)) == 0)
        return("Normal (none)")
    ENDIF
    IF (attributesI & FINFO_READONLY)
        resultS = resultS + "Read-only "
    ENDIF
    IF (attributesI & FINFO_HIDDEN)
        resultS = resultS + "Hidden "
    ENDIF
    IF (attributesI & FINFO_SYSTEM)
        resultS = resultS + "System "
    ENDIF
    IF (attributesI & FINFO_ARCHIVE)
        resultS = resultS + "Archive "
    ENDIF
    return(resultS)
END

STRING PROC FNDosDateS(INTEGER dateI)
    INTEGER dayI   = dateI & 31
    INTEGER monthI = (dateI Shr 5) & 15
    INTEGER yearI  = ((dateI Shr 9) & 127) + 1980

    return(Format(yearI:4:"0", "-", monthI:2:"0", "-", dayI:2:"0"))
END

STRING PROC FNDosTimeS(INTEGER timeI)
    INTEGER secondI = (timeI & 31) * 2
    INTEGER minuteI = (timeI Shr 5) & 63
    INTEGER hourI   = (timeI Shr 11) & 31

    return(Format(hourI:2:"0", ":", minuteI:2:"0", ":", secondI:2:"0"))
END
