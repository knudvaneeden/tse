/****************************************************************************\

    DlgVideo.S

    Video mode dialog used in UI.

    Version         v2.20/09.04.02
    Copyright       (c) 1995-2002 by DiK

    Overview:

    This dialog is used to change TSE's video mode.

    Keys:       (none)

    Usage Notes:

    This macro is called from the burned in user interface.

    History

    v2.20/09.04.02  adaption to TSE32 v4.0
                    + fixed version checking
    v2.10/30.11.00  adaption to TSE32 v3.0
                    + added new video modes
                    + fixed initialization quirks
                    + fixed size of drop down lists
    v2.02/07.01.99  first version

\****************************************************************************/

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dlgvideo.si"
#include "dialog.si"
#include "msgbox.si"

/****************************************************************************\
    compatibility
\****************************************************************************/

#if EDITOR_VERSION >= 0x3000
constant _30x90 = 13
constant _30x94 = 14
constant _34x90 = 15
constant _34x94 = 16
constant _40x90 = 17
constant _40x94 = 18
#endif

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "dlgvideo.dlg"

/****************************************************************************\
    shared code
\****************************************************************************/

#include "scver.si"
#include "scrun.si"

/****************************************************************************\
    global variables
\****************************************************************************/

constant DATA_SIZE = 12                 // size of video data

string DATA_FILE[] = "video.dat"        // name of data file

integer resource                        // dialog resource buffer
integer user_buff                       // buffer id of user file
integer init_data                       // startup data
integer init_buff                       // combo box buffer
integer curr_buff                       // ditto

integer init_x1                         // startup window pos
integer init_y1
integer init_rows
integer init_cols
integer init_mode
integer init_doit

integer curr_x1                          // current window pos
integer curr_y1
integer curr_rows
integer curr_cols

/****************************************************************************\
    datadefs: video modes
\****************************************************************************/

#if EDITOR_VERSION >= 0x3000

datadef VideoModes
    "25 lines"
    "28 lines"
    "30 lines"
    "30 lines, 90 cols"
    "30 lines, 94 cols"
    "33 lines"
    "34 lines, 90 cols"
    "34 lines, 94 cols"
    "36 lines"
    "40 lines"
    "40 lines, 90 cols"
    "40 lines, 94 cols"
    "43 lines"
    "44 lines"
    "50 lines"
    "Max lines"
    "Max cols"
    "Max lines/cols"
    "Custom lines/cols"
end

#else
#if EDITOR_VERSION >= 0x2800

datadef VideoModes
    "25 lines"
    "28 lines"
    "30 lines"
    "33 lines"
    "36 lines"
    "40 lines"
    "43 lines"
    "50 lines"
    "Max lines"
    "Max cols"
    "Max lines/cols"
    "Custom lines/cols"
end

#else

datadef VideoModes
    "25 lines"
    "28 lines"
    "30 lines"
    "33 lines"
    "36 lines"
    "40 lines"
    "44 lines"
    "50 lines"
end

#endif
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

integer proc GetWindowPosition(var integer x, var integer y)
    integer rc, hwnd, pntr
    string buffer[44] = ""

    hwnd = GetWinHandle()
    pntr = Addr(buffer) + 2
    PokeLong(pntr,44)
    rc = GetWindowPlacement(hwnd,pntr)
    if rc
        x = PeekLong(pntr+28)
        y = PeekLong(pntr+32)
    endif
    return(rc)
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
    helper routines
\****************************************************************************/

#if EDITOR_VERSION >= 0x3000

integer proc ModeToLine(integer curr_mode)
    integer line, cols

    cols = Query(ScreenCols)

    case curr_mode
        when _25_LINES_         line = iif( cols == 80,  1, 19)
        when _28_LINES_         line = iif( cols == 80,  2, 19)
        when _30_LINES_         line = iif( cols == 80,  3, 19)
        when _30x90             line = iif( cols == 90,  4, 19)
        when _30x94             line = iif( cols == 94,  5, 19)
        when _33_LINES_         line = iif( cols == 80,  6, 19)
        when _34x90             line = iif( cols == 90,  7, 19)
        when _34x94             line = iif( cols == 94,  8, 19)
        when _36_LINES_         line = iif( cols == 80,  9, 19)
        when _40_LINES_         line = iif( cols == 80, 10, 19)
        when _40x90             line = iif( cols == 90, 11, 19)
        when _40x94             line = iif( cols == 94, 12, 19)
        when _43_LINES_         line = iif( cols == 80, 13, 19)
        when _44_LINES_         line = iif( cols == 80, 14, 19)
        when _50_LINES_         line = iif( cols == 80, 15, 19)
        when _MAX_LINES_        line = 16
        when _MAX_COLS_         line = 17
        when _MAX_LINES_COLS_   line = 18
        otherwise               line = 19
    endcase
    return (line)
end

integer proc LineToMode(integer line)
    integer mode

    case line
        when  1   mode = _25_LINES_
        when  2   mode = _28_LINES_
        when  3   mode = _30_LINES_
        when  4   mode = _30x90
        when  5   mode = _30x94
        when  6   mode = _33_LINES_
        when  7   mode = _34x90
        when  8   mode = _34x94
        when  9   mode = _36_LINES_
        when  10  mode = _40_LINES_
        when  11  mode = _40x90
        when  12  mode = _40x94
        when  13  mode = _43_LINES_
        when  14  mode = _44_LINES_
        when  15  mode = _50_LINES_
        when  16  mode = _MAX_LINES_
        when  17  mode = _MAX_COLS_
        when  18  mode = _MAX_LINES_COLS_
        otherwise mode = 255
    endcase
    return (mode)
end

proc LineToRowsCols(integer line, var integer rows, var integer cols)
    integer max_rows, max_cols

    GetMaxRowsCols(max_rows,max_cols)
    rows = Query(ScreenRows)
    cols = Query(ScreenCols)

    case line
        when  1   rows = 25         cols = 80
        when  2   rows = 28         cols = 80
        when  3   rows = 30         cols = 80
        when  4   rows = 30         cols = 90
        when  5   rows = 30         cols = 94
        when  6   rows = 33         cols = 80
        when  7   rows = 34         cols = 90
        when  8   rows = 34         cols = 94
        when  9   rows = 36         cols = 80
        when 10   rows = 40         cols = 80
        when 11   rows = 40         cols = 90
        when 12   rows = 40         cols = 94
        when 13   rows = 43         cols = 80
        when 14   rows = 44         cols = 80
        when 15   rows = 50         cols = 80
        when 16   rows = max_rows
        when 17                     cols = max_cols
        when 18   rows = max_rows   cols = max_cols
    endcase
end

#else
#if EDITOR_VERSION >= 0x2800

integer proc ModeToLine(integer curr_mode)
    integer line, cols

    cols = Query(ScreenCols)

    case curr_mode
        when _25_LINES_         line = iif( cols == 80, 1, 19)
        when _28_LINES_         line = iif( cols == 80, 2, 19)
        when _30_LINES_         line = iif( cols == 80, 3, 19)
        when _33_LINES_         line = iif( cols == 80, 4, 19)
        when _36_LINES_         line = iif( cols == 80, 5, 19)
        when _40_LINES_         line = iif( cols == 80, 6, 19)
        when _43_LINES_         line = iif( cols == 80, 7, 19)
        when _50_LINES_         line = iif( cols == 80, 8, 19)
        when _MAX_LINES_        line =  9
        when _MAX_COLS_         line = 10
        when _MAX_LINES_COLS_   line = 11
        otherwise               line = 12
    endcase
    return (line)
end

integer proc LineToMode(integer line)
    integer mode

    case line
        when  1   mode = _25_LINES_
        when  2   mode = _28_LINES_
        when  3   mode = _30_LINES_
        when  4   mode = _33_LINES_
        when  5   mode = _36_LINES_
        when  6   mode = _40_LINES_
        when  7   mode = _43_LINES_
        when  8   mode = _50_LINES_
        when  9   mode = _MAX_LINES_
        when  10  mode = _MAX_COLS_
        when  11  mode = _MAX_LINES_COLS_
        when  11  mode = _MAX_LINES_COLS_
        otherwise mode = 255
    endcase
    return (mode)
end

proc LineToRowsCols(integer line, var integer rows, var integer cols)
    integer max_rows, max_cols

    GetMaxRowsCols(max_rows,max_cols)
    rows = Query(ScreenRows)
    cols = Query(ScreenCols)

    case line
        when  1   rows = 25         cols = 80
        when  2   rows = 28         cols = 80
        when  3   rows = 30         cols = 80
        when  4   rows = 33         cols = 80
        when  5   rows = 36         cols = 80
        when  6   rows = 40         cols = 80
        when  7   rows = 43         cols = 80
        when  8   rows = 50         cols = 80
        when  9   rows = max_rows
        when 10                     cols = max_cols
        when 11   rows = max_rows   cols = max_cols
    endcase
end

#else

integer proc ModeToLine(integer curr_mode)
    integer line

    case curr_mode
        when _25_LINES_         line =  1
        when _28_LINES_         line =  2
        when _30_LINES_         line =  3
        when _33_LINES_         line =  4
        when _36_LINES_         line =  5
        when _40_LINES_         line =  6
        when _44_LINES_         line =  7
        when _50_LINES_         line =  8
    endcase
    return (line)
end

integer proc LineToMode(integer line)
    integer mode

    case line
        when  1   mode = _25_LINES_
        when  2   mode = _28_LINES_
        when  3   mode = _30_LINES_
        when  4   mode = _33_LINES_
        when  5   mode = _36_LINES_
        when  6   mode = _40_LINES_
        when  7   mode = _44_LINES_
        when  8   mode = _50_LINES_
    endcase
    return (mode)
end

proc LineToRowsCols(integer line, var integer rows, var integer cols)
    rows = Query(ScreenRows)
    cols = 80

    case line
        when  1   rows = 25
        when  2   rows = 28
        when  3   rows = 30
        when  4   rows = 33
        when  5   rows = 36
        when  6   rows = 40
        when  7   rows = 44
        when  8   rows = 50
    endcase
end

#endif
#endif

/****************************************************************************\
    video data access

    NB: these routines expect that init_data is the current buffer
\****************************************************************************/

integer proc CheckData()
    return( NumLines() == 1 and CurrLineLen() == DATA_SIZE )
end

proc ReadData()
    string buffer[DATA_SIZE]
    integer pntr = Addr(buffer)

    buffer = GetText(1,DATA_SIZE)
    init_doit = PeekWord(pntr+2)
    init_mode = PeekWord(pntr+4)
    init_x1   = PeekWord(pntr+6)
    init_y1   = PeekWord(pntr+8)
    init_rows = PeekWord(pntr+10)
    init_cols = PeekWord(pntr+12)
end

proc WriteData()
    string buffer[DATA_SIZE] = ""
    integer pntr = Addr(buffer)

    PokeWord(pntr,DATA_SIZE)
    PokeWord(pntr+2,init_doit)
    PokeWord(pntr+4,init_mode)
    PokeWord(pntr+6,init_x1)
    PokeWord(pntr+8,init_y1)
    PokeWord(pntr+10,init_rows)
    PokeWord(pntr+12,init_cols)
    EmptyBuffer()
    AddLine(buffer)
end

/****************************************************************************\
    set screen
\****************************************************************************/

proc GetCurrPos()
#ifdef win32
    GetWindowPosition(curr_x1,curr_y1)
#endif
    curr_rows = Query(ScreenRows)
    curr_cols = Query(ScreenCols)
end

proc SetCurrPos()
    ExecMacro(Format("DlgSetTitle ",EDT_CURR_X1," ",curr_x1))
    ExecMacro(Format("DlgSetTitle ",EDT_CURR_Y1," ",curr_y1))
    ExecMacro(Format("DlgSetTitle ",EDT_CURR_COLS," ",curr_cols))
    ExecMacro(Format("DlgSetTitle ",EDT_CURR_ROWS," ",curr_rows))
end

proc SetInitPos()
    ExecMacro(Format("DlgSetTitle ",EDT_INIT_X1," ",init_x1))
    ExecMacro(Format("DlgSetTitle ",EDT_INIT_Y1," ",init_y1))
    ExecMacro(Format("DlgSetTitle ",EDT_INIT_COLS," ",init_cols))
    ExecMacro(Format("DlgSetTitle ",EDT_INIT_ROWS," ",init_rows))
end

/****************************************************************************\
    disabling custom size controls
\****************************************************************************/

proc EnableInitDetails(integer Enabled)
    ExecMacro(Format("DlgSetEnable ",TXT_INIT_COLS,Enabled:2))
    ExecMacro(Format("DlgSetEnable ",TXT_INIT_ROWS,Enabled:2))
    ExecMacro(Format("DlgSetEnable ",EDT_INIT_COLS,Enabled:2))
    ExecMacro(Format("DlgSetEnable ",EDT_INIT_ROWS,Enabled:2))
end

/****************************************************************************\
    setup dialog data
\****************************************************************************/

public proc VideoDataInit()

    // check dialog version

    if CheckVersion("DlgOpts",2,3)
        ExecMacro("DlgTerminate")
        return ()
    endif

    // init data

    GetCurrPos()
    SetCurrPos()
    SetInitPos()

    ExecMacro(Format("DlgSetData ",id_use_mode," ",init_doit))

    GotoBufferId(init_buff)
    GotoLine(ModeToLine(init_mode))
    ExecMacro(Format("DlgSetData ",id_init_mode," ",init_buff))

    GotoBufferId(curr_buff)
    GotoLine(ModeToLine(Query(CurrVideoMode)))
    ExecMacro(Format("DlgSetData ",id_curr_mode," ",curr_buff))

#ifdef win32
    EnableInitDetails(init_mode == 255)
#else
    EnableInitDetails(False)
    ExecMacro(Format("DlgSetEnable ",TXT_CURR_COLS," 0"))
    ExecMacro(Format("DlgSetEnable ",TXT_CURR_ROWS," 0"))
    ExecMacro(Format("DlgSetEnable ",EDT_CURR_COLS," 0"))
    ExecMacro(Format("DlgSetEnable ",EDT_CURR_ROWS," 0"))
    ExecMacro(Format("DlgSetEnable ",TXT_CURR_X1," 0"))
    ExecMacro(Format("DlgSetEnable ",TXT_CURR_Y1," 0"))
    ExecMacro(Format("DlgSetEnable ",EDT_CURR_X1," 0"))
    ExecMacro(Format("DlgSetEnable ",EDT_CURR_Y1," 0"))
    ExecMacro(Format("DlgSetEnable ",TXT_INIT_X1," 0"))
    ExecMacro(Format("DlgSetEnable ",TXT_INIT_Y1," 0"))
    ExecMacro(Format("DlgSetEnable ",EDT_INIT_X1," 0"))
    ExecMacro(Format("DlgSetEnable ",EDT_INIT_Y1," 0"))
#endif

    GotoBufferId(resource)
end

/****************************************************************************\
    apply dialog data
\****************************************************************************/

integer proc GetBool(integer id)
    ExecMacro(Format("DlgGetData ",id))
    return(Val(Query(MacroCmdLine)))
end

integer proc GetInt(integer id)
    ExecMacro(Format("DlgGetTitle ",id))
    return(Val(Query(MacroCmdLine)))
end

proc SetVideoMode()

    // get data for startup mode

    init_x1 = GetInt(EDT_INIT_X1)
    init_y1 = GetInt(EDT_INIT_Y1)
    init_cols = GetInt(EDT_INIT_COLS)
    init_rows = GetInt(EDT_INIT_ROWS)

    init_doit = GetBool(id_use_mode)

    GotoBufferId(init_buff)
    init_mode = LineToMode(CurrLine())

    // make sure SetVideo gets executed

    AddAutoLoadMacro("setvideo")

    // write startup data to file

    GotoBufferId(init_data)
    WriteData()
    SaveAs(LoadDir(FALSE)+DATA_FILE,_OVERWRITE_)
    GotoBufferId(resource)

    // get data for current mode

    curr_x1 = GetInt(EDT_CURR_X1)
    curr_y1 = GetInt(EDT_CURR_Y1)
    curr_cols = GetInt(EDT_CURR_COLS)
    curr_rows = GetInt(EDT_CURR_ROWS)

    // apply current mode to editor window

    ExecMacro(Format("DlgShowWindow 0"))
    GotoBufferId(curr_buff)
#ifdef win32
    SetWindowPosition(curr_x1,curr_y1)
    SetVideoRowsCols(curr_rows,curr_cols)
#else
    Set(CurrVideoMode,LineToMode(CurrLine()))
#endif
    GotoBufferId(user_buff)
    UpdateDisplay()
    GotoBufferId(resource)
    ExecMacro(Format("DlgShowWindow 1"))
end

/****************************************************************************\
    apply data and close dialog
\****************************************************************************/

proc BtnApply()

    // set the new video mode

    SetVideoMode()

    // reflect current mode in dialog; this is necessary,
    // since we can't tell what happens when _MAX_LINES_COLS_ is used

    GetCurrPos()
    SetCurrPos()

    GotoBufferId(curr_buff)
    GotoLine(ModeToLine(Query(CurrVideoMode)))
    GotoBufferId(resource)

    // activate current mode combo box

    ExecMacro(Format("DlgExecCntrl ",ID_CURR_MODE))
end

proc BtnOk()
    SetVideoMode()
    ExecMacro("DlgTerminate")
end

/****************************************************************************\
    message response functions
\****************************************************************************/

public proc VideoEditChanged()
    integer rc, c

    c  = Val(GetToken(Query(MacroCmdLine)," ",2))
    rc = c <= 0 or c in 48..57
    if not rc and Query(Beep)
        Alarm()
    endif
    Set(MacroCmdLine,Str(rc))
end

public proc VideoCloseUp()
    integer line

    case CurrChar(POS_ID)
        when ID_CURR_MODE
            GotoBufferId(curr_buff)
            line = CurrLine()
            LineToRowsCols(line,curr_rows,curr_cols)
            SetCurrPos()
            GotoBufferId(resource)
        when ID_INIT_MODE
            GotoBufferId(init_buff)
            line = CurrLine()
            LineToRowsCols(line,init_rows,init_cols)
            SetInitPos()
            GotoBufferId(resource)
#ifdef win32
            EnableInitDetails(LineToMode(line) == 255)
#endif
    endcase
end

public proc VideoBtnDown()
    case CurrChar(POS_ID)
        when ID_OK              BtnOk()
        when ID_APPLY           BtnApply()
        when ID_HELP            Help("OptionsMenu->Video Mode")
    endcase
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer rc

    // init buffers

    PushBlock()
    user_buff = GetBufferId()

    // get startup data

    init_data = CreateTempBuffer()
    rc = init_data
    if LoadBuffer(LoadDir(FALSE)+DATA_FILE,-1) and CheckData()
        ReadData()
    else
        init_mode = Query(StartupVideoMode)
        LineToRowsCols(ModeToLine(init_mode),init_rows,init_cols)
    endif

    // allocate dialog data and exec dialog

    init_buff = CreateTempBuffer()
    rc = rc and init_buff and InsertData(VideoModes)
    curr_buff = CreateTempBuffer()
    rc = rc and curr_buff and InsertData(VideoModes)
    resource  = CreateTempBuffer()
    rc = rc and resource and InsertData(dlgvideo)
    rc = rc and ExecDialog("dialog video")

    // restore buffers

    AbandonFile(resource)
    AbandonFile(init_data)
    AbandonFile(init_buff)
    AbandonFile(curr_buff)
    GotoBufferId(user_buff)
    PopBlock()
    UpdateDisplay(_HELPLINE_REFRESH_)

    // check return code and set return values

    if not rc
        Set(MacroCmdLine,"0")
        Warn("DlgOpts: Error executing Video dialog")
    endif

    // purge self

    PurgeMacro(CurrMacroFilename())
end
