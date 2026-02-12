/****************************************************************************\

    SetVideo.S

    Set startup video mode.

    Version         v2.20/30.11.00
    Copyright       (c) 1999-2002 by DiK

    Overview:

    This macro is used to set TSE's video mode at startup.

    Keys:       (none)

    Usage Notes:

    This macro will be added to TSE's autostart list by DlgVideo.

    History
    v2.20/30.11.00  adaption to TSE32 v4.0
                    þ fixed updating display
    v2.10/30.11.00  adaption to TSE32 v3.0
                    þ fixed freeing data buffer
                    þ fixed initialization quirks
    v2.02/07.01.99  first version

\****************************************************************************/

/****************************************************************************\
    global variables
\****************************************************************************/

constant DATA_SIZE = 12                 // size of video data

string DATA_FILE[] = "video.dat"        // name of data file

integer init_mode                       // startup video mode

#ifdef win32
integer init_x1                         // window position
integer init_y1
integer init_rows                       // window size
integer init_cols
#endif

/****************************************************************************\
    compatibility
\****************************************************************************/

#ifndef WIN32

integer proc LoadBuffer(string fn, integer reclen)
    integer ok

    EmptyBuffer()
    BinaryMode(reclen)
    PushBlock()
    ok = InsertFile(fn, _DONT_PROMPT_)
    PopBlock()
    return (ok)
end

#endif

/****************************************************************************\
    windows api routines
\****************************************************************************/

#ifdef win32

dll "<user32.dll>"
    integer proc GetWindowPlacement(integer hwnd, integer lpwndpl)
    integer proc SetWindowPlacement(integer hwnd, integer lpwndpl)
end

integer proc SetWindowPosition(integer x, integer y)
    integer rc, hwnd, pntr
    integer x2, y2, dx, dy
    string buffer[44] = ""

    hwnd = GetWinHandle()
    pntr = Addr(buffer) + 2
    PokeLong(pntr,44)
    rc = GetWindowPlacement(hwnd,pntr)
    if rc
        dx = x - PeekLong(pntr+28)
        dy = y - PeekLong(pntr+32)
        x2 = PeekLong(pntr+36) + dx
        y2 = PeekLong(pntr+40) + dy
        PokeLong(pntr+28,x)
        PokeLong(pntr+32,y)
        PokeLong(pntr+36,x2)
        PokeLong(pntr+40,y2)
        rc = SetWindowPlacement(hwnd,pntr)
    endif
    return(rc)
end

#endif

/****************************************************************************\
    video routine
\****************************************************************************/

#ifdef win32

proc SetVideoMode()
    integer max_rows, max_cols

    GetMaxRowsCols(max_rows,max_cols)
    case init_mode
        when _MAX_LINES_
            init_y1 = 0
            init_rows = max_rows
            init_cols = 80
        when _MAX_COLS_
            init_x1 = 0
            init_rows = 25
            init_cols = max_cols
        when _MAX_LINES_COLS_
            init_x1 = 0
            init_y1 = 0
            init_rows = max_rows
            init_cols = max_cols
    endcase
    UpdateDisplay()
    SetWindowPosition(init_x1,init_y1)
    SetVideoRowsCols(init_rows,init_cols)
end

#else

proc SetVideoMode()
    Set(CurrVideoMode,init_mode)
end

#endif


/****************************************************************************\
    main program
\****************************************************************************/

proc WhenLoaded()
    string buffer[DATA_SIZE]
    integer pntr = Addr(buffer)
    integer data, user
    integer ok, set_mode

    user = GetBufferId()
    data = CreateTempBuffer()

    ok = data and LoadBuffer(LoadDir(FALSE)+DATA_FILE,-1)
            and NumLines() == 1 and CurrLineLen() == DATA_SIZE

    if ok
        buffer = GetText(1,DATA_SIZE)
        set_mode  = PeekWord(pntr+2)
        init_mode = PeekWord(pntr+4)

#ifdef win32
        init_x1   = PeekWord(pntr+6)
        init_y1   = PeekWord(pntr+8)
        init_rows = PeekWord(pntr+10)
        init_cols = PeekWord(pntr+12)
#endif
    endif

    GotoBufferId(user)
    AbandonFile(data)

    if ok and set_mode
        SetVideoMode()
    endif

    PurgeMacro(CurrMacroFilename())
end
