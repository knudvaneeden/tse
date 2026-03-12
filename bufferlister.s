// bufferlister.s
// List all open TSE buffers in a pick list
// Written via MCP, compiled via sc32.exe
// <version>1.0.0.0.5</version>

proc Main()
    integer pick_id, cur_id, orig_id, buf_id
    string  bufname[255]

    orig_id = GetBufferId()
    pick_id = CreateTempBuffer()

    // walk all buffers, collect filenames into pick_id
    buf_id = orig_id
    repeat
        GotoBufferId(buf_id)
        bufname = CurrFilename()
        GotoBufferId(pick_id)
        AddLine(bufname)
        GotoBufferId(buf_id)
        NextFile(_DONT_LOAD_)
        buf_id = GetBufferId()
    until buf_id == orig_id

    // show pick list
    GotoBufferId(pick_id)
    BegFile()
    if lList('Open Buffers', LongestLineInBuffer() + 4, 12, _ENABLE_HSCROLL_)
        bufname = GetText(1, 255)
        cur_id  = GetBufferId(bufname)
        if cur_id
            GotoBufferId(cur_id)
        endif
    else
        GotoBufferId(orig_id)
    endif

    AbandonFile(pick_id)
end
