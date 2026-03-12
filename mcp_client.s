// mcp_client.s
// TSE MCP Client - filesystem server over stdio
// Place in: c:\temp\mcp_client.s
// <version>1.0.0.0.8</version>

string REQ_FILE[64]     = "c:\temp\mcp_req.json"
string RESP_FILE[64]    = "c:\temp\mcp_resp.json"
string CONTENT_FILE[64] = "c:\temp\mcp_content.tmp"
string SC32[128]        = "f:\wordproc\tse32_v45024\sc32.exe"
string ERRFILE[255]     = "c:\temp\sc32_output.txt"
// string BRIDGE[128]   = "python c:\temp\mcp_client.py"
string BRIDGE[128]      = "g:\language\computer\python\python\python.exe c:\temp\mcp_client.py"

// ---------------------------------------------------------------------------
// WriteFile - write a string to a file, replacing its contents
// ---------------------------------------------------------------------------
proc WriteFile(string path, string content)
    integer fh
    fh = fCreate(path)
    if fh >= 0
        fWrite(fh, content)
        fClose(fh)
    else
        Warn("WriteFile: could not create " + path)
    endif
end

// ---------------------------------------------------------------------------
// RunBridge - invoke the Python MCP client and open the response
// ---------------------------------------------------------------------------
proc RunBridge()
    // Dos(BRIDGE) // debug: keep window open
    Dos(BRIDGE, _DONT_PROMPT_)
    EditFile(RESP_FILE)
end

// ---------------------------------------------------------------------------
// McpListTools - discover what tools the filesystem server exposes
// ---------------------------------------------------------------------------
proc McpListTools()
    WriteFile(REQ_FILE, '{"method":"tools/list"}')
    RunBridge()
end

// ---------------------------------------------------------------------------
// McpListDir - list a directory (path must be under c:\temp)
// ---------------------------------------------------------------------------
proc McpListDir(string dirpath)
    string json1[128]
    string json2[128]
    json1 = '{"method":"tools/call","tool":"list_directory",'
    json2 = '"arguments":{"path":"' + dirpath + '"}}'
    WriteFile(REQ_FILE, json1 + json2)
    RunBridge()
end

// ---------------------------------------------------------------------------
// McpReadFile - read a file (must be under c:\temp)
// ---------------------------------------------------------------------------
proc McpReadFile(string filepath)
    string json1[128]
    string json2[128]
    json1 = '{"method":"tools/call","tool":"read_text_file",'
    json2 = '"arguments":{"path":"' + filepath + '"}}'
    WriteFile(REQ_FILE, json1 + json2)
    RunBridge()
end

// ---------------------------------------------------------------------------
// McpWriteFile - write a file with short content (max ~180 chars of content)
// For larger content use McpWriteFileLarge instead
// ---------------------------------------------------------------------------
proc McpWriteFile(string filepath, string content)
    string json1[128]
    string json2[255]
    json1 = '{"method":"tools/call","tool":"write_file",'
    json2 = '"arguments":{"path":"' + filepath + '","content":"' + content + '"}}'
    WriteFile(REQ_FILE, json1 + json2)
    RunBridge()
end

// ---------------------------------------------------------------------------
// McpWriteFileLarge - write a file with large content via temp file
// bypasses the 255-char SAL string limit
// caller must write content to CONTENT_FILE before calling this proc
// ---------------------------------------------------------------------------
proc McpWriteFileLarge(string filepath)
    string json1[128]
    string json2[128]
    json1 = '{"method":"tools/call","tool":"write_file",'
    json2 = '"arguments":{"path":"' + filepath + '","content_file":"c:\\temp\\mcp_content.tmp"}}'
    WriteFile(REQ_FILE, json1 + json2)
    RunBridge()
end

// ---------------------------------------------------------------------------
// CompileViaMcp - write a SAL source file via MCP then compile with sc32.exe
// source content must already be written to CONTENT_FILE by the caller
// filepath : target .s filename under c:\temp e.g. "hello.s"
// ---------------------------------------------------------------------------
proc CompileViaMcp(string filepath)
    string cmd[255]
    // step 1 - write source file via MCP
    McpWriteFileLarge(filepath)
    // step 2 - compile with sc32.exe, capture output
    cmd = SC32 + " c:\temp\" + filepath + " > " + ERRFILE + " 2>&1"
    Dos(cmd, _DONT_PROMPT_)
    // step 3 - open compiler output in TSE
    EditFile(ERRFILE)
end

// ---------------------------------------------------------------------------
// HasCompileErrors - return TRUE if sc32_output.txt contains "Error"
// ---------------------------------------------------------------------------
integer proc HasCompileErrors()
    integer found, orig_id
    orig_id = GetBufferId()
    found = FALSE
    if EditFile(ERRFILE)
        if lFind("Error", "g")
            found = TRUE
        endif
        AbandonFile()
    endif
    GotoBufferId(orig_id)
    return(found)
end

// ---------------------------------------------------------------------------
// McpAutoFix - ask Claude API to fix SAL source errors
// filepath : the .s filename under c:\temp
// attempt  : current attempt number (1-3)
// Python reads source + errors, calls Claude, writes fixed source to
// CONTENT_FILE ready for the next CompileViaMcp call
// ---------------------------------------------------------------------------
proc McpAutoFix(string filepath, integer attempt)
    string json1[128]
    string json2[128]
    string json3[128]
    string json4[128]
    string attstr[4]
    attstr = Str(attempt)
    json1 = '{"method":"autofix",'
    json2 = '"source_file":"c:\\temp\\' + filepath + '",'
    json3 = '"error_file":"c:\\temp\\sc32_output.txt",'
    json4 = '"content_file":"c:\\temp\\mcp_content.tmp","attempt":' + attstr + '}'
    WriteFile(REQ_FILE, json1 + json2 + json3 + json4)
    Dos(BRIDGE, _DONT_PROMPT_)
    EditFile(RESP_FILE)
end

// ---------------------------------------------------------------------------
// CompileWithAutoFix - compile a SAL file, auto-fixing errors up to 3 times
// CONTENT_FILE must be written by caller before calling this proc
// filepath : target .s filename under c:\temp e.g. "bufferlister.s"
// ---------------------------------------------------------------------------
proc CompileWithAutoFix(string filepath)
    integer attempt
    string  cmd[255]
    attempt = 1
    while attempt <= 3
        // step 1 - write source via MCP and compile
        McpWriteFileLarge(filepath)
        cmd = SC32 + " c:\temp\" + filepath + " > " + ERRFILE + " 2>&1"
        Dos(cmd, _DONT_PROMPT_)
        // step 2 - check for errors
        if not HasCompileErrors()
            Message("Compiled OK on attempt " + Str(attempt))
            EditFile(ERRFILE)
            return()
        endif
        // step 3 - errors found - ask Claude to fix
        if attempt < 3
            Message("Attempt " + Str(attempt) + " failed - asking Claude to fix...")
            McpAutoFix(filepath, attempt)
            // Python has written fixed source to CONTENT_FILE - loop again
        endif
        attempt = attempt + 1
    endwhile
    // all 3 attempts failed
    Warn("Could not fix " + filepath + " after 3 attempts - see " + ERRFILE)
    EditFile(ERRFILE)
end

// ---------------------------------------------------------------------------
// WriteBufListerSource - write correct bufferlister.s source to CONTENT_FILE
// ---------------------------------------------------------------------------
proc WriteBufListerSource()
    integer fh
    fh = fCreate(CONTENT_FILE)
    if fh < 0
        Warn("Could not create " + CONTENT_FILE)
        return()
    endif
    fWrite(fh, "// bufferlister.s" + Chr(13) + Chr(10))
    fWrite(fh, "// List all open TSE buffers in a pick list" + Chr(13) + Chr(10))
    fWrite(fh, "// Written via MCP, compiled via sc32.exe" + Chr(13) + Chr(10))
    fWrite(fh, "// <version>1.0.0.0.5</version>" + Chr(13) + Chr(10))
    fWrite(fh, "" + Chr(13) + Chr(10))
    fWrite(fh, "proc Main()" + Chr(13) + Chr(10))
    fWrite(fh, "    integer pick_id, cur_id, orig_id, buf_id" + Chr(13) + Chr(10))
    fWrite(fh, "    string  bufname[255]" + Chr(13) + Chr(10))
    fWrite(fh, "" + Chr(13) + Chr(10))
    fWrite(fh, "    orig_id = GetBufferId()" + Chr(13) + Chr(10))
    fWrite(fh, "    pick_id = CreateTempBuffer()" + Chr(13) + Chr(10))
    fWrite(fh, "" + Chr(13) + Chr(10))
    fWrite(fh, "    // walk all buffers, collect filenames into pick_id" + Chr(13) + Chr(10))
    fWrite(fh, "    buf_id = orig_id" + Chr(13) + Chr(10))
    fWrite(fh, "    repeat" + Chr(13) + Chr(10))
    fWrite(fh, "        GotoBufferId(buf_id)" + Chr(13) + Chr(10))
    fWrite(fh, "        bufname = CurrFilename()" + Chr(13) + Chr(10))
    fWrite(fh, "        GotoBufferId(pick_id)" + Chr(13) + Chr(10))
    fWrite(fh, "        AddLine(bufname)" + Chr(13) + Chr(10))
    fWrite(fh, "        GotoBufferId(buf_id)" + Chr(13) + Chr(10))
    fWrite(fh, "        NextFile(_DONT_LOAD_)" + Chr(13) + Chr(10))
    fWrite(fh, "        buf_id = GetBufferId()" + Chr(13) + Chr(10))
    fWrite(fh, "    until buf_id == orig_id" + Chr(13) + Chr(10))
    fWrite(fh, "" + Chr(13) + Chr(10))
    fWrite(fh, "    // show pick list" + Chr(13) + Chr(10))
    fWrite(fh, "    GotoBufferId(pick_id)" + Chr(13) + Chr(10))
    fWrite(fh, "    BegFile()" + Chr(13) + Chr(10))
    fWrite(fh, "    if lList('Open Buffers', LongestLineInBuffer() + 4, 12, _ENABLE_HSCROLL_)" + Chr(13) + Chr(10))
    fWrite(fh, "        bufname = GetText(1, 255)" + Chr(13) + Chr(10))
    fWrite(fh, "        cur_id  = GetBufferId(bufname)" + Chr(13) + Chr(10))
    fWrite(fh, "        if cur_id" + Chr(13) + Chr(10))
    fWrite(fh, "            GotoBufferId(cur_id)" + Chr(13) + Chr(10))
    fWrite(fh, "        endif" + Chr(13) + Chr(10))
    fWrite(fh, "    else" + Chr(13) + Chr(10))
    fWrite(fh, "        GotoBufferId(orig_id)" + Chr(13) + Chr(10))
    fWrite(fh, "    endif" + Chr(13) + Chr(10))
    fWrite(fh, "" + Chr(13) + Chr(10))
    fWrite(fh, "    AbandonFile(pick_id)" + Chr(13) + Chr(10))
    fWrite(fh, "end" + Chr(13) + Chr(10))
    fClose(fh)
end

// ---------------------------------------------------------------------------
// WriteBufListerSourceWithError - correct logic but buf_id missing from
// integer declaration - simple compile error for autofix loop testing
// ---------------------------------------------------------------------------
proc WriteBufListerSourceWithError()
    integer fh
    fh = fCreate(CONTENT_FILE)
    if fh < 0
        Warn("Could not create " + CONTENT_FILE)
        return()
    endif
    fWrite(fh, "// bufferlister.s" + Chr(13) + Chr(10))
    fWrite(fh, "// List all open TSE buffers in a pick list" + Chr(13) + Chr(10))
    fWrite(fh, "// Written via MCP, compiled via sc32.exe" + Chr(13) + Chr(10))
    fWrite(fh, "// <version>1.0.0.0.5</version>" + Chr(13) + Chr(10))
    fWrite(fh, "" + Chr(13) + Chr(10))
    fWrite(fh, "proc Main()" + Chr(13) + Chr(10))
    fWrite(fh, "    integer pick_id, cur_id, orig_id" + Chr(13) + Chr(10))
    fWrite(fh, "    string  bufname[255]" + Chr(13) + Chr(10))
    fWrite(fh, "" + Chr(13) + Chr(10))
    fWrite(fh, "    orig_id = GetBufferId()" + Chr(13) + Chr(10))
    fWrite(fh, "    pick_id = CreateTempBuffer()" + Chr(13) + Chr(10))
    fWrite(fh, "" + Chr(13) + Chr(10))
    fWrite(fh, "    // walk all buffers, collect filenames into pick_id" + Chr(13) + Chr(10))
    fWrite(fh, "    buf_id = orig_id" + Chr(13) + Chr(10))
    fWrite(fh, "    repeat" + Chr(13) + Chr(10))
    fWrite(fh, "        GotoBufferId(buf_id)" + Chr(13) + Chr(10))
    fWrite(fh, "        bufname = CurrFilename()" + Chr(13) + Chr(10))
    fWrite(fh, "        GotoBufferId(pick_id)" + Chr(13) + Chr(10))
    fWrite(fh, "        AddLine(bufname)" + Chr(13) + Chr(10))
    fWrite(fh, "        GotoBufferId(buf_id)" + Chr(13) + Chr(10))
    fWrite(fh, "        NextFile(_DONT_LOAD_)" + Chr(13) + Chr(10))
    fWrite(fh, "        buf_id = GetBufferId()" + Chr(13) + Chr(10))
    fWrite(fh, "    until buf_id == orig_id" + Chr(13) + Chr(10))
    fWrite(fh, "" + Chr(13) + Chr(10))
    fWrite(fh, "    // show pick list" + Chr(13) + Chr(10))
    fWrite(fh, "    GotoBufferId(pick_id)" + Chr(13) + Chr(10))
    fWrite(fh, "    BegFile()" + Chr(13) + Chr(10))
    fWrite(fh, "    if lList('Open Buffers', LongestLineInBuffer() + 4, 12, _ENABLE_HSCROLL_)" + Chr(13) + Chr(10))
    fWrite(fh, "        bufname = GetText(1, 255)" + Chr(13) + Chr(10))
    fWrite(fh, "        cur_id  = GetBufferId(bufname)" + Chr(13) + Chr(10))
    fWrite(fh, "        if cur_id" + Chr(13) + Chr(10))
    fWrite(fh, "            GotoBufferId(cur_id)" + Chr(13) + Chr(10))
    fWrite(fh, "        endif" + Chr(13) + Chr(10))
    fWrite(fh, "    else" + Chr(13) + Chr(10))
    fWrite(fh, "        GotoBufferId(orig_id)" + Chr(13) + Chr(10))
    fWrite(fh, "    endif" + Chr(13) + Chr(10))
    fWrite(fh, "" + Chr(13) + Chr(10))
    fWrite(fh, "    AbandonFile(pick_id)" + Chr(13) + Chr(10))
    fWrite(fh, "end" + Chr(13) + Chr(10))
    fClose(fh)
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer fh
    fh = 0
    //
    // erase / refresh / clean up
    //
    PushPosition()
    PushBlock()
    if EditFile(RESP_FILE)
        AbandonFile()
    endif
    EraseDiskFile(RESP_FILE)
    PopPosition()
    PopBlock()
    //
    PushPosition()
    PushBlock()
    if EditFile(ERRFILE)
        AbandonFile()
    endif
    EraseDiskFile(ERRFILE)
    PopPosition()
    PopBlock()
    //
    // McpListTools()         // works [kn, ri, th, 12-03-2026 16:30:41]
    // McpListDir(".")        // works [kn, ri, th, 12-03-2026 16:30:45]
    // McpReadFile("mcp_client.py")           // works [kn, ri, th, 12-03-2026 16:45:30]
    // McpWriteFile("mcp_test.txt", "Hello from TSE via MCP!")  // works [kn, ri, th, 12-03-2026 16:55:00]
    // McpWriteFileLarge("mcp_test_large.txt")                  // works [kn, ri, th, 12-03-2026 17:00:00]
    // McpReadFile("mcp_client.py")           // works [kn, ri, th, 12-03-2026 17:10:00]
    // CompileViaMcp("hello.s")               // works [kn, ri, th, 12-03-2026 17:20:00]
    // CompileViaMcp("bufferlister.s")        // works [kn, ri, th, 12-03-2026 17:30:00]
    //
    // Test autofix loop: write source WITH deliberate error, let Claude fix it
    WriteBufListerSourceWithError()
    CompileWithAutoFix("bufferlister.s")
    //
end
