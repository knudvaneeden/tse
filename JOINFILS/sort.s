/****************************************************************************
 Sort a marked block, calling either the internal (slow) sort on small
 blocks, and the external (fast) sort on large blocks.

 8-17-98 SEM: Bug!  The ignore-case option was being set the opposite of
              what it should be.

 3-27-98 SEM: Quote the path of the sort executable, if needed.

 2-05-98 SEM: Add "kill duplicates" option, and accept two different
                command line formats.  New format is:

                sort -i[gnorecase] -d[escending] -k[illdups]

                    or

                sort integer_sort_flags
                    where flags can be _DESCENDING_ and/or _IGNORE_CASE_

                If no options passed, then sort will be ascending, respecting case.

 1-08-98 SEM: Tsort fails when the temp path is a long filename. Since tsort
                is a 16 program that does not handle long filenames, use
                GetShortPathName() to convert long names to short names
                before passing them to tsort.

 9-39-97 SEM: check to see if we are Windows NT or Windows 95.  If NT,
                call the sort via Dos(), if 95 call the sort via lDos().
                Note that the options for the Dos() command to keep the
                window from showing are very particular, it took quite a bit
                of testing to come up with the right combination.

 7-30-97 SEM: win32 CreateProcess() doesn't always work with 16-bit
                executables.  In lieu of that, go back to calling
                Dos.  However, using the proper options, the screen
                doesn't get resized anymore!

 1-09-96 SEM: Always erase the block from disk (even if sort fails)

12-13-96 SEM: Use lDos in lieu of Dos to keep screen from resizing

12-18-95 SEM: Reset blocktype even if an error occurs.

  Call internal (slow) sort if:

    -lines to sort is < sort_thresh
    -file is in binary mode
    -block contains tabs or cr/lf characters
    -external sort module can not be found

return codes:
    ff00    SaveBlock fails
    fe00    if the Dos/lDos command fails
    fc00    everything looks ok, but sorted file does not exist

    0036    out of disk space
 ****************************************************************************/

#ifdef WIN32
#define MAXPATH 255

dll "<kernel32.dll>"
    integer proc GetVersionEx(integer p) : "GetVersionExA"
    integer proc GetShortPathName(string inpath:cstrval, var string outpath:strptr, integer len) : "GetShortPathNameA"
    integer proc GetLastError() : "GetLastError"
end

/*typedef struct _OSVERSIONINFO{

    DWORD dwOSVersionInfoSize;
    DWORD dwMajorVersion;
    DWORD dwMinorVersion;
    DWORD dwBuildNumber;
    DWORD dwPlatformId;
    TCHAR szCSDVersion[ 128 ];
} OSVERSIONINFO;
*/

#define VER_PLATFORM_WIN32s             0
#define VER_PLATFORM_WIN32_WINDOWS      1
#define VER_PLATFORM_WIN32_NT           2

// the following MUST remain in the listed order
integer dwOSVersionInfoSize = 148
integer dwMajorVersion
integer dwMinorVersion
integer dwBuildNumber
integer dwPlatformId
string szCSDVersion[128]

integer proc isWindowsNT()
    // get rid of compiler warning messages
    if dwOSVersionInfoSize or dwMajorVersion or dwMinorVersion or dwBuildNumber or dwPlatformId or szCSDVersion[1] == ""
    endif
    GetVersionEx(Addr(dwOSVersionInfoSize))
    return (dwPlatformId == VER_PLATFORM_WIN32_NT)
end

/**************************************************************************
  GetShortPathName only works for existing path's..., so create inpath if
  it does not already exist.
 **************************************************************************/
string proc mGetShortPathname(string inpath)
    integer h, len
    string short_path[_MAXPATH_] = Format("":_MAXPATH_:Chr(0))

    h = iif(FileExists(inpath), -1, fCreate(inpath))
    len = GetShortPathName(inpath, short_path, _MAXPATH_)
    if h <> -1
        fClose(h)
        EraseDiskFile(inpath)
    endif
    return (iif(len > 0, short_path[1:Pos(Chr(0), short_path) - 1], inpath))
end

#else

#define MAXPATH 80

string proc QuotePath(string path)
    return (path)
end

#endif

/**************************************************************************
  Decode the passed options - can either be a binary integer, or a flag in
  the format -option

  Return TRUE if the -killdups option is present
 **************************************************************************/
integer proc GetOptions(string cmdline, var integer flags, var string options)
    integer i, n, z, kill_dups, descending, ignore_case
    string s[32]

    kill_dups = FALSE
    descending = FALSE
    ignore_case = FALSE
    n = NumTokens(cmdline, ' ')
    for i = 1 to n
        s = GetToken(cmdline, ' ', i)
        case Lower(s[1:2])
            when '-i'
                ignore_case = TRUE
            when '-d'
                descending = TRUE
            when '-k'
                kill_dups = TRUE
            otherwise
                z = Val(s)
                if z & _IGNORE_CASE_
                    ignore_case = TRUE
                endif
                if z & _DESCENDING_
                    descending = TRUE
                endif
        endcase
    endfor

    if ignore_case
        flags = flags | _IGNORE_CASE_
    else
        options = options + "/A "
    endif

    if descending
        options = options + "/R "
        flags = flags | _DESCENDING_
    endif

    if kill_dups
        options = options + "/D "
    endif

    return (kill_dups)
end

proc mGotoLineCol(integer line, integer col)
    GotoLine(line)
    GotoColumn(col)
end

proc mMarkColumn(integer y1, integer x1, integer y2, integer x2)
    UnmarkBlock()
    mGotoLineCol(y1, x1)
    MarkColumn()
    mGotoLineCol(y2, x2)
    MarkColumn()
end

/**************************************************************************
  Call the external (slow) sort.

  Do not call it if the kill_dups option is set.
 **************************************************************************/
proc BuiltInSort(integer flags, integer kill_dups, string msg)
    integer result

    if kill_dups
#ifdef WIN32
        MsgBox("", msg + " -killdups option not supported")
#else
        Warn(msg, " -killdups option not supported")
#endif
        return ()
    endif

    if msg == ""
        result = 1
    else
#ifdef WIN32
        result = MsgBox("", msg + " Use slow sort?", _YES_NO_CANCEL_)
#else
        result = YesNo(msg + " Use slow sort?")
#endif
    endif

    if result == 1
        Sort(flags)
    else
        Message("Sort terminated")
    endif
end

integer sort_thresh = 2000
string sort_path[MAXPATH], sort_name[] = "tsort.com"

proc main()
    string fn[MAXPATH], efn[MAXPATH], options[20]
#ifdef WIN32
    integer tsort_flags
    string dir[MAXPATH]
#endif
    integer x1, y1, x2, y2, b, line, col, row, marking, rc, save_eoltype,
        flags, save_eoftype, ctl_char_found, kill_dups

    options = ""
    flags = 0
    kill_dups = GetOptions(Trim(Query(MacroCmdLine)), flags, options)
    b = isBlockInCurrFile()
    y1 = Query(BlockBegLine)
    y2 = Query(BlockEndLine)
    x1 = Query(BlockBegCol)
    x2 = Query(BlockEndCol)
    // no block, or just a small block
    if b == 0 or (not kill_dups and y2 - y1 + 1 < sort_thresh)
        BuiltInSort(flags, kill_dups, "")
        return ()
    endif

    // can't find the external sort!
    if Length(sort_path) == 0
        sort_path = QuotePath(SearchPath(sort_name, Query(TSEPath), "."))
        if Length(sort_path) == 0
            sort_thresh = MAXINT
            BuiltInSort(flags, kill_dups, sort_name + " not found.")
            return ()
        endif
    endif

    // external sort doesn't handle binary files
    if BinaryMode()
        BuiltInSort(flags, kill_dups, "File is binary.")
        return ()
    endif

    // external sort would have problems with embedded control chars
    Message("Checking for ctrl characters")
    PushPosition()
    ctl_char_found = lFind("[\n\r\t]", "glx")
    PopPosition()
    if ctl_char_found
        BuiltInSort(flags, kill_dups, "Ctrl characters found.")
        return ()
    endif

    // force eoltype to cr and lf, and force a cr and lf at eof
    save_eoltype = Set(EOLType, 3)
    save_eoftype = Set(EOFType, 2)

    marking = Query(Marking)
    line = CurrLine()
    col = CurrCol()
    row = CurrRow()

    if b <> _LINE_
        if b == _COLUMN_
            options = Format(options, "/+", x1, ":", x2 - x1 + 1)
        endif
        MarkLine(y1, y2)
    endif
    GotoBlockBegin()
    BegLine()

#ifdef WIN32
    dir = GetEnvStr("TEMP")
    if Length(dir) == 0
        dir = GetEnvStr("TMP")
        if Length(dir) == 0
            dir = CurrDir()
        endif
    endif

    fn = MakeTempName(dir)
    efn = MakeTempName(dir)

    fn = mGetShortPathname(fn)
    efn = mGetShortPathname(efn)
#else
    fn = MakeTempName(Query(SwapPath))
    efn = MakeTempName(Query(SwapPath))
#endif

    /**************************************************************************
      Save the block to be sorted in the temp directory
     **************************************************************************/
    rc = 0xff00
    if SaveBlock(fn, _OVERWRITE_)
        rc = 0xfe00
#ifdef WIN32
        tsort_flags = _DONT_CLEAR_|_RETURN_CODE_|_START_HIDDEN_
        if isWindowsNT()
            tsort_flags = tsort_flags |_PRESERVE_SCREEN_|_DONT_CHANGE_VIDEO_
            if Dos(Format(sort_path; "/Q"; "/E", efn; "/Z"; fn; fn; options), tsort_flags)
                rc = DosIOResult()
            endif
        else
            tsort_flags = tsort_flags |_RUN_DETACHED_
            if lDos(sort_path, Format("/Q"; "/E", efn; "/Z"; fn; fn; options/*; ">nul"*/), tsort_flags)
                rc = DosIOResult()
            endif
        endif
#else
        if lDos(sort_path, Format("/Q"; "/E", efn; "/Z"; fn; fn; options/*; ">nul"*/), _DONT_CLEAR_|_RETURN_CODE_)
            rc = LoByte(DosIOResult())
        endif
#endif
        if rc == 0
            if not FileExists(fn)
                rc = 0xfc00
            else
                KillBlock()
                InsertFile(fn)
            endif
        endif
        EraseDiskFile(efn)
        EraseDiskFile(fn)
    endif

    if b <> _COLUMN_
        MarkLine(y1, y2)
    elseif not marking
        MarkColumn(y1, x1, y2, x2)
    elseif line == y1 and col == x2
        mMarkColumn(y2, x1, y1, x2)
    elseif line == y2 and col == x1
        mMarkColumn(y1, x2, y2, x1)
    else
        MarkColumn(y1, x1, y2, x2)
    endif

    GotoLine(line)
    GotoColumn(col)
    ScrollToRow(row)
    Set(Marking, marking)

    if rc <> 0
        Warn("Error"; rc:4:'0':16; "running external sort program:", sort_path)
    endif
    Set(EOLType, save_eoltype)
    Set(EOFType, save_eoftype)
end
