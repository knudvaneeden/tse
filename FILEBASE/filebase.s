// Memorize file position

// Feb 2000 Loewe Opta GmbH, Helmut.Geisser@loewe.de

// This macro is intended for the auto load list

// It memorizes the cursor position for any file edited in a data base
// and restores the previous position whenever loading the file again

constant MAXPATH = 80

#include ["symtab.s"]

string VERSION_ID[] = "TSE File Base 20000224"
string FILE_BASE[] = "tsebase.dat"

integer TSEFileBase = 0
integer EditedFiles = 0

string proc Normalize(var string filename)
    integer i

    for i = 1 to Length(filename)
        if filename[i] == "/"
            filename[i] = "\\"
        endif
    endfor

    return(filename)
end

proc MemorizeFilePos()
    string fn[MAXPATH] = CurrFilename()

    if Length(fn)
        Normalize(fn)
        SymSet(EditedFiles, "FILE" + SUBSEP + fn,
                            Str(CurrLine()) + SUBSEP
                            + Str(CurrRow()) + SUBSEP
                            + Str(CurrPos()) + SUBSEP
                            + Str(CurrXOffset()))
        SymSet(TSEFileBase, SymName(EditedFiles), SymThis(EditedFiles))
    endif
end

proc RestoreFilePos()
    string fn[MAXPATH] = CurrFilename()
    string s[40]

    if Length(fn)
        Normalize(fn)
        s = SymGet(TSEFileBase, "FILE" + SUBSEP + fn)
        if Length(s)
            GotoLine(Val(GetToken(s, SUBSEP, 1)))
            ScrollToRow(Val(GetToken(s, SUBSEP, 2)))
            GotoPos(Val(GetToken(s, SUBSEP, 3)))
            GotoXOffset(Val(GetToken(s, SUBSEP, 4)))
        endif
    endif
end

proc ReadFileBase(var integer filebase)
    SymTabRead(filebase, LoadDir() + FILE_BASE)
    if SymGet(filebase, "VERSION") <> VERSION_ID
        SymTabDelete(filebase)
        filebase = SymTabCreate()
        SymSet(filebase, "VERSION", VERSION_ID)
    endif
end

proc UpdateFileBase()
    string FIRST_LINE_PATTERN[9] = FS + "1" + SUBSEP + "1" + SUBSEP + "1" + SUBSEP + "0" + FS

    if TSEFileBase
        do NumFiles() + (BufferType() <> _NORMAL_) times
            MemorizeFilePos()
            PrevFile()
        enddo

        SymTabDelete(TSEFileBase)
        TSEFileBase = SymTabCreate()
        if TSEFileBase
            ReadFileBase(TSEFileBase)
            SymTabMerge(TSEFileBase, EditedFiles)
            SymRemove(TSEFileBase, FIRST_LINE_PATTERN, "")
            SymTabWrite(TSEFileBase, LoadDir() + FILE_BASE)
        endif
    endif
end

proc OnFileQuit()
    MemorizeFilePos()
end

//proc OnFileSave()
//end

proc OnFirstEdit()
    RestoreFilePos()
end

//proc OnChangingFiles()
//end

//proc OnExitCalled()
//end

proc OnAbandonEditor()
    integer state

    state = SetHookState(_OFF_, _ON_FILE_QUIT_)
    RemoveUnloadedFiles()
    SetHookState(state, _ON_FILE_QUIT_)
    UpdateFileBase()
    SymTabDelete(EditedFiles)
    SymTabDelete(TSEFileBase)
end

proc WhenLoaded()
    TSEFileBase = SymTabCreate()
    EditedFiles = SymTabCreate()
    if TSEFileBase and EditedFiles
        ReadFileBase(TSEFileBase)
        RestoreFilePos()
        //Hook(_ON_CHANGING_FILES_, OnChangingFiles)
        Hook(_ON_FIRST_EDIT_, OnFirstEdit)
        //Hook(_ON_FILE_SAVE_, OnFileSave)
        Hook(_ON_FILE_QUIT_, OnFileQuit)
        //Hook(_ON_EXIT_CALLED_, OnExitCalled)
        Hook(_ON_ABANDON_EDITOR_, OnAbandonEditor)
    endif
end

proc WhenPurged()
    if TSEFileBase
        //UnHook(OnChangingFiles)
        UnHook(OnFirstEdit)
        //UnHook(OnFileSave)
        UnHook(OnFileQuit)
        //UnHook(OnExitCalled)
        UnHook(OnAbandonEditor)
        SymTabDelete(EditedFiles)
        SymTabDelete(TSEFileBase)
    endif
end

