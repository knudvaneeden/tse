dll "ascii_ebcdic.dll"
    proc ASCIItoEBCDICBuf(string s:strval) : "_ASCIItoEBCDICBuf@8"
    proc EBCDICtoASCIIBuf(string s:strval) : "_EBCDICtoASCIIBuf@8"
end

proc toASCII()
    string s[255]

    PushPosition()
    BegFile()

    repeat
        BegLine()
        s = GetText(1, 255)
        EBCDICtoASCIIBuf(s)
        InsertText(s, _OVERWRITE_)
    until not Down()
    PopPosition()
end

proc toEBCDIC()
    string s[255]

    PushPosition()
    BegFile()

    repeat
        BegLine()
        s = GetText(1, 255)
        ASCIItoEBCDICBuf(s)
        InsertText(s, _OVERWRITE_)
    until not Down()
    PopPosition()
end

string EBCDIC[] = "EBCDIC"
string EXTENSION[] = "extension"
string LRECL_ITEM[] = "lrecl"
string EBCDIC_ext[32]
integer EBCDIC_lrecl
string EBCDIC_FILE[] = "EBCDIC_FILE"

string proc getEBCDICext()
    string ext[32]
    ext = GetProfileStr(EBCDIC, EXTENSION, "")

    if ext == ""
        repeat until Ask("Enter EBCDIC file extension (.ebc):", ext) and Trim(ext) <> ""
        if ext[1] <> '.'
            ext = '.' + ext
        endif
        WriteProfileStr(EBCDIC, EXTENSION, ext)
    endif
    return (ext)
end

integer proc getEBCDIClrecl()
    integer lrecl
    string lrecl_str[32] = ""

    lrecl = GetProfileInt(EBCDIC, LRECL_ITEM, 0)

    if lrecl == 0
        repeat until AskNumeric("Enter EBCDIC record length:", lrecl_str) and Val(lrecl_str) <> 0
            lrecl = Val(lrecl_str)
        WriteProfileInt(EBCDIC, LRECL_ITEM, lrecl)
    endif
    return (lrecl)
end

integer proc isAutoLoaded()
    integer id, found
    PushPosition()
    id = EditBuffer(LoadDir() + "tseload.dat", _HIDDEN_, -1)
    if id
        found = lFind(CurrMacroFilename(), "i^$")
    endif
    PopPosition()
    if id
        AbandonFile(id)
    endif
    return (found)
end

proc onFileSave()
    if GetBufferInt(EBCDIC_FILE)
        case MsgBoxEx("", "Save As", "[&EBCDIC];[&ASCII];[&CANCEL]")
            when 0
                TerminateEvent()
            when 1
                toEBCDIC()
            when 2
                BinaryMode(0)
        endcase
    endif
end

proc onFirstEdit()
    integer undo_mode = UndoMode(off)
    if GetBufferInt(EBCDIC_FILE)
        toASCII()
        FileChanged(FALSE)
        ClearUndoRedoList()
    endif
    UndoMode(undo_mode)
end

proc onFileLoad()
    if EquiStr(CurrExt(), EBCDIC_ext)
        BinaryMode(EBCDIC_lrecl)
        SetBufferInt(EBCDIC_FILE, 1)
    endif
end

proc WhenLoaded()
    if not isAutoLoaded()
        AddAutoLoadMacro(CurrMacroFilename())
    endif
    EBCDIC_ext = getEBCDICext()
    EBCDIC_lrecl = getEBCDIClrecl()
    Hook(_ON_FILE_LOAD_, onFileLoad)
    Hook(_ON_FIRST_EDIT_, onFirstEdit)
    Hook(_ON_FILE_SAVE_, onFileSave)
end
