/*****************************************************************************
   LOPENFIX.S
   Version 1.0.0.0.6
   2026-09-19 19:41 CEST

   The following macros and variables:
      - Cause a "beep" to sound whenever NextFile or PrevFile move you
        to the first file that was loaded
      - Change ListFiles so that the first file loaded is always at the
        top of the list
      - The procedure MakeFirst allows you to assign any file as the
        "first" file for the above
      - Read supported runtime options from lopenfix.ini

   NOTE: This code was originally intended for integration into the
         User-Interface macro source.  It can also be compiled separately
         for testing, but OnFirstEdit(), MakeFirst(), and mListOpenFiles()
         must still be called/hooked from the surrounding UI as required.
 *****************************************************************************/

integer firstID = 0

string proc FNIniFilename()
    return (SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + "lopenfix.ini")
end FNIniFilename

integer proc FNIniBool(string itemS, integer defaultB)
    string valueS[20]

    if defaultB
        valueS = GetProfileStr("LOPENFIX", itemS, "true", FNIniFilename())
    else
        valueS = GetProfileStr("LOPENFIX", itemS, "false", FNIniFilename())
    endif

    if EquiStr(valueS, "true") or EquiStr(valueS, "yes") or EquiStr(valueS, "on") or valueS == "1"
        return (TRUE)
    endif

    if EquiStr(valueS, "false") or EquiStr(valueS, "no") or EquiStr(valueS, "off") or valueS == "0"
        return (FALSE)
    endif

    return (defaultB)
end FNIniBool

proc OnFirstEdit()
    if firstID == 0
        firstID = GetBufferId()
    endif
end OnFirstEdit

proc mNextfile()
    integer frequencyI, delayI

    frequencyI = GetProfileInt("LOPENFIX", "soundfrequency", 300, FNIniFilename())
    delayI = GetProfileInt("LOPENFIX", "sounddelay", 1, FNIniFilename())

    NextFile()
    if GetBufferId() == firstID
        if frequencyI > 0
            Sound(frequencyI, 1)
            if delayI > 0
                Delay(delayI)
            endif
            NoSound()
        endif
    endif
end mNextfile

proc mPrevfile()
    integer frequencyI, delayI

    frequencyI = GetProfileInt("LOPENFIX", "soundfrequency", 300, FNIniFilename())
    delayI = GetProfileInt("LOPENFIX", "sounddelay", 1, FNIniFilename())

    PrevFile()
    if GetBufferId() == firstID
        if frequencyI > 0
            Sound(frequencyI, 1)
            if delayI > 0
                Delay(delayI)
            endif
            NoSound()
        endif
    endif
end mPrevfile

proc MakeFirst()
    if FNIniBool("usemakefirst", TRUE)
        firstID = GetBufferId()
        Message("Current File Now Marked as the First")
    else
        Message("MakeFirst disabled in lopenfix.ini")
    endif
end MakeFirst

proc mListOpenFiles()
    integer start_file, filelist, id, rc, maxl, n, listWidth
    string fn[65]

    n = NumFiles() + (BufferType() <> _NORMAL_)
    if n == 0
        return ()
    endif

    maxl = 0
    start_file = GetBufferId()
    filelist = CreateTempBuffer()
    if filelist == 0
        Warn("Can't create filelist")
        return ()
    endif

    if FNIniBool("usemodifiedfilelist", TRUE) and firstID <> 0
        GotoBufferId(firstID)
    else
        GotoBufferId(start_file)
    endif

    id = GetBufferId()
    while n
        fn = CurrFilename()
        if Length(fn)
            if Length(fn) > maxl
                maxl = Length(fn)
            endif
            rc = FileChanged()
            GotoBufferId(filelist)
            AddLine(iif(rc, '*', ' ') + fn)
            GotoBufferId(id)
        endif
        NextFile(_DONT_LOAD_)
        id = GetBufferId()
        n = n - 1
    endwhile

    GotoBufferId(filelist)
    BegFile()
    listWidth = maxl + 4
    if listWidth > Query(ScreenCols)
        listWidth = Query(ScreenCols)
    endif

    if List("Buffer List", listWidth)
        EditFile(GetText(2, sizeof(fn)))
    else
        GotoBufferId(start_file)
    endif
    AbandonFile(filelist)
end mListOpenFiles

// Key definitions are compile-time SAL syntax and cannot be changed at
// runtime from lopenfix.ini.  The INI nextfilekey/prevfilekey entries are
// therefore documentation/reference values only.
<Alt n> mNextfile()
<Alt p> mPrevfile()
