//// HSK Read-Only Win32 helper routines
//// Version: 1.0.0.0.1
//// LLM: OpenAI Codex (GPT-5)

// Win32 replacement for the unsupported DOS WP.BIN file services.
// Returns a Windows file-attribute bit mask, or -1 on failure.
dll "hskro100.dll"
    integer proc PASCAL HSKGetFileAttributes(string fileNameS : cstrval) : "HSKGETFILEATTRIBUTES"
    integer proc PASCAL HSKIsReadOnly(string fileNameS : cstrval) : "HSKISREADONLY"
end

integer proc ListIt(string title, integer width)
    width = width + 4
    if width > Query(ScreenCols)
        width = Query(ScreenCols)
    endif
    return(List(title, width))
end

string proc OnOffStr(integer i)
    return(iif(i, "On", "Off"))
end

integer proc ListAndGoto(integer start_id, integer list_id, integer maxl,
                         string title, integer start_line,
                         integer fn_start_col)
    string fn[255]

    if GotoBufferId(list_id)
        BegFile()
        if maxl == 0
            repeat
                if CurrLineLen() > maxl
                    maxl = CurrLineLen()
                endif
            until NOT Down()
        endif
        if maxl < Length(title)
            maxl = Length(title) + 2
        endif
        GotoLine(start_line)

        if ListIt(title, maxl)
            fn = GetText(fn_start_col, CurrLineLen() - fn_start_col + 1)
            if ExpandPath(fn) == fn
                EditFile(fn)
            else
                GotoBufferId(GetBufferId(fn))
                ExecHook(_ON_CHANGING_FILES_)
            endif
            return(TRUE)
        endif
        GotoBufferId(start_id)
    endif
    return(FALSE)
end
