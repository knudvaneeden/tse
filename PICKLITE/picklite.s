// PICKLITE.S - version 1.0.0.0.17 - 2026-09-26
// Win32 GUI and console TSE picklist directory highlighting.
// Original PICKLITE example by Christopher Antos (1995).
// Updated by OpenAI Codex.

integer GICalls = 0
integer GIRowsRead = 0
integer GIMatches = 0
integer GIDebug = 0
integer GIMainRuns = 0
integer GIFirstCount = 0
integer GIFirstLength = 0
integer GIFirstPos = 0
integer GIFirstAttrLen = 0
integer GIFirstCode1 = 0
integer GIFirstCode2 = 0
integer GIFirstCode3 = 0
integer GIFirstCode4 = 0
integer GIFirstCode5 = 0
integer GIFirstOldAttr = 0
integer GIFirstNewAttr = 0
string GSFirstRow[80] = ""
string GSIniPath[255] = ""

integer proc FNDirectoryAttr(integer oldAttrI)
    integer backgroundI = oldAttrI / 16
    if oldAttrI == 30 or oldAttrI == 48
        return(oldAttrI)
    endif
    if backgroundI == 1
        return(48)
    endif
    return(30)
end

proc HilightList()
    integer xI = Query(PopWinX1)
    integer yI = Query(PopWinY1)
    integer colsI = Query(PopWinCols)
    integer rowsI = Query(PopWinRows)
    integer rowI, colI, countI, lastColI, oldAttrI, newAttrI
    string lineS[255] = ""
    string attrsS[255] = ""

    GICalls = GICalls + 1
    if colsI > 255
        colsI = 255
    endif
    if colsI < 2
        return()
    endif
    for rowI = yI to yI + rowsI - 1 by 1
        lineS = ""
        attrsS = ""
        countI = GetStrAttrXY(xI, rowI, lineS, attrsS, colsI)
        if countI > 0
            GIRowsRead = GIRowsRead + 1
            if GSFirstRow == ""
                GSFirstRow = LeftStr(lineS, 60)
                GIFirstCount = countI
                GIFirstLength = Length(lineS)
                GIFirstPos = Pos("[dir]", lineS)
                GIFirstAttrLen = Length(attrsS)
                GIFirstCode1 = Asc(SubStr(lineS, 1, 1))
                GIFirstCode2 = Asc(SubStr(lineS, 2, 1))
                GIFirstCode3 = Asc(SubStr(lineS, 3, 1))
                GIFirstCode4 = Asc(SubStr(lineS, 4, 1))
                GIFirstCode5 = Asc(SubStr(lineS, 5, 1))
            endif
        endif
        if Length(lineS) >= 5 and (
            (Asc(SubStr(lineS, 1, 1)) == 91 and
             Asc(SubStr(lineS, 2, 1)) == 100 and
             Asc(SubStr(lineS, 3, 1)) == 105 and
             Asc(SubStr(lineS, 4, 1)) == 114 and
             Asc(SubStr(lineS, 5, 1)) == 93) or
            (Asc(SubStr(lineS, 1, 1)) == 32 and
             Asc(SubStr(lineS, 2, 1)) == 92))
            GIMatches = GIMatches + 1
            if Length(attrsS) >= Length(lineS)
                lastColI = Length(lineS)
                while lastColI > 0 and SubStr(lineS, lastColI, 1) == " "
                    lastColI = lastColI - 1
                endwhile
                for colI = 1 to lastColI by 1
                    oldAttrI = Asc(SubStr(attrsS, colI, 1))
                    newAttrI = FNDirectoryAttr(oldAttrI)
                    if GIFirstOldAttr == 0
                        GIFirstOldAttr = oldAttrI
                        GIFirstNewAttr = newAttrI
                    endif
                    if newAttrI <> oldAttrI
                        PutAttrXY(xI + colI - 1, rowI, newAttrI, 1)
                    endif
                endfor
            endif
        endif
    endfor
end

proc ListCleanup()
    UnHook(ListCleanup)
    UnHook(HilightList)
    if GIDebug
        Warn("PICKLITE 1.0.0.0.17: calls=", GICalls,
             " rows read=", GIRowsRead, " matches=", GIMatches,
             " count=", GIFirstCount, " len=", GIFirstLength,
             " pos=", GIFirstPos, " attrlen=", GIFirstAttrLen,
             " codes=", GIFirstCode1, ",", GIFirstCode2, ",",
             GIFirstCode3, ",", GIFirstCode4, ",", GIFirstCode5,
             " old/new=", GIFirstOldAttr, "/", GIFirstNewAttr,
             " first row=[", GSFirstRow, "]")
    endif
end

proc ListStartup()
    GICalls = 0
    GIRowsRead = 0
    GIMatches = 0
    GSFirstRow = ""
    GIFirstCount = 0
    GIFirstLength = 0
    GIFirstPos = 0
    GIFirstAttrLen = 0
    GIFirstCode1 = 0
    GIFirstCode2 = 0
    GIFirstCode3 = 0
    GIFirstCode4 = 0
    GIFirstCode5 = 0
    GIFirstOldAttr = 0
    GIFirstNewAttr = 0
    if Lower(GetProfileStr("Picklite", "debug", "false", GSIniPath)) == "true"
        GIDebug = 1
    else
        GIDebug = 0
    endif
    Hook(_PICKFILE_CLEANUP_, ListCleanup)
    Hook(_NONEDIT_IDLE_, HilightList)
    Hook(_AFTER_NONEDIT_COMMAND_, HilightList)
end

proc WhenLoaded()
    GSIniPath = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + "picklite.ini"
    Hook(_PICKFILE_STARTUP_, ListStartup)
end

proc Main()
    GIMainRuns = GIMainRuns + 1
    if GSIniPath == ""
        GSIniPath = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + "picklite.ini"
    endif
    if Lower(GetProfileStr("Picklite", "debug", "false", GSIniPath)) == "true" and GIMainRuns > 1
        Warn("PICKLITE 1.0.0.0.17 (OpenAI Codex): calls=", GICalls,
             " rows read=", GIRowsRead, " matches=", GIMatches,
             " count=", GIFirstCount, " len=", GIFirstLength,
             " pos=", GIFirstPos, " attrlen=", GIFirstAttrLen,
             " codes=", GIFirstCode1, ",", GIFirstCode2, ",",
             GIFirstCode3, ",", GIFirstCode4, ",", GIFirstCode5,
             " old/new=", GIFirstOldAttr, "/", GIFirstNewAttr,
             " first row=[", GSFirstRow, "]")
    elseif Lower(GetProfileStr("Picklite", "silent", "false", GSIniPath)) <> "true"
        Warn("PICKLITE 1.0.0.0.17 (OpenAI Codex): directory highlighting is active. Open a picklist, close it, then run PICKLITE again for debug counts.")
    endif
end
