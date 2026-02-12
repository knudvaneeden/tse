/****************************************************************************\

    SBTN.S

    Add a window sizing button to TSE which can be used with the mouse.

    Overview:

    This macro displays an S in the lower right corner of TSE's window.
    If you click it, hold the mouse button and drag the mouse, a status
    box indicating the current position of the mouse is displayed. When
    the mouse button is released TSE's window will be resized such that
    the lower right corner of the window moves to the mouse cursor. This
    works exactly like resizing a GUI application by dragging it at the
    lower right corner. To cancel resizing press the escape key while
    still holding the mouse button.

    Right clicking the S button or pressing <Alt -> will pop up a menu
    which allows you to shrink TSE to thumb nail size or maximize the
    window to screen size. Right clicking the button or pressing <Alt ->
    again while TSE is minimized or maximized will restore the window to
    its previous position and size.

    Keys:   (none)

    Usage notes:

    You must add SBTN to TSE's autoload list.
    This macro works only for TSE 3.0.

    Version         v1.10/28.08.01
    Copyright       (c) 2001 by DiK

    History
    v1.00/28.08.01  first version

\****************************************************************************/

/****************************************************************************\
    user configurable constants
\****************************************************************************/

constant
    MENU_KEY = <Alt ->

constant
    ButtonColor = Color( bright yellow on red )

/****************************************************************************\
    constants and variables
\****************************************************************************/

constant
    BOX_ROWS = 5,               // do NOT change these!
    BOX_COLS = 16

integer hwnd                    // TSE's windows handle
integer toolbar_height          // the height of the console's toolbar
integer col_width               // dimension of TSE's character cell (width)
integer row_height              // ditto (height)

integer prev_x                  // window position before min/max
integer prev_y
integer prev_cols               // window size before min/max
integer prev_rows

/****************************************************************************\
    windows API functions
\****************************************************************************/

constant
    GW_HWNDNEXT = 2,
    GW_CHILD = 5

dll "<user32.dll>"
    integer proc GetCursorPos(integer pPoint)
    integer proc ScreenToClient(integer hWnd, integer pPoint)
    integer proc IsWindowVisible(integer hWnd)
    integer proc GetClientRect(integer hWnd, integer pRect)
    integer proc GetWindowRect(integer hWnd, integer pRect)
    integer proc GetWindowPlacement(integer hWnd, integer lpwndpl)
    integer proc SetWindowPlacement(integer hWnd, integer lpwndpl)
    integer proc GetWindow(integer hWnd, integer ucmd)
    integer proc GetClassNameA(integer hWnd, string ClassName: strptr, integer nMaxCount)
end

/****************************************************************************\
    wrapper functions for WindowPlacement
\****************************************************************************/

integer proc GetWindowPosition(var integer x, var integer y)
    integer rc
    string wndpl[44] = ""                           // WNDPL struct
    integer pWndpl = AdjPtr(Addr(wndpl), 2)

    PokeLong(pWndpl, 44)
    rc = GetWindowPlacement(hwnd, pWndpl)
    if rc
        x = PeekLong(pWndpl + 28)                   // wndpl.rcNormalPosition.Left
        y = PeekLong(pWndpl + 32)                   // wndpl.rcNormalPosition.Top
    endif
    return(rc)
end

integer proc SetWindowPosition(integer x, integer y)
    integer rc
    integer dx, dy, x2, y2
    string wndpl[44] = ""                           // WNDPL struct
    integer pWndpl = AdjPtr(Addr(wndpl), 2)

    PokeLong(pWndpl, 44)
    rc = GetWindowPlacement(hwnd, pWndpl)
    if rc
        dx = x - PeekLong(pWndpl + 28)              // compute offset
        dy = y - PeekLong(pWndpl + 32)
        x2 = PeekLong(pWndpl + 36) + dx             // add offset to lower-right corner
        y2 = PeekLong(pWndpl + 40) + dy
        PokeLong(pWndpl + 28, x)                    // wndpl.rcNormalPosition.Left
        PokeLong(pWndpl + 32, y)                    // wndpl.rcNormalPosition.Top
        PokeLong(pWndpl + 36, x2)                   // wndpl.rcNormalPosition.Right
        PokeLong(pWndpl + 40, y2)                   // wndpl.rcNormalPosition.Bottom
        rc = SetWindowPlacement(hwnd, pWndpl)
    endif
    return(rc)
end

/****************************************************************************\
    mouse interface to windows
\****************************************************************************/

// determine the height of the console's toolbar

proc GetToolbarHeight()
    integer hchild                              // handle of child windows
    string name[255] = ""                       // class name of child
    integer name_len
    string rect[16] = ""                        // RECT struct
    integer pRect = AdjPtr(Addr(rect), 2)
    integer rectTop, rectBottom

    // iterate all visible child windows of the console

    hchild = GetWindow(hwnd, GW_CHILD)
    while hchild <> 0
        if IsWindowVisible(hchild)

            // check for the toolbar

            name_len = GetClassNameA(hchild, name, 255)
            PokeWord(Addr(name), name_len)
            if name == "ToolbarWindow"

                // get the height of the toolbar

                GetWindowRect(hchild, pRect)
                rectTop = PeekLong(AdjPtr(pRect, 4))
                rectBottom = PeekLong(AdjPtr(pRect, 12))
                toolbar_height = rectBottom - rectTop
                return()

            endif

        endif
        hchild = GetWindow(hchild, GW_HWNDNEXT)
    endwhile

    // no visible child window found

    toolbar_height = 0
end

// compute the size of TSE's character cell

proc InitMouseTracking()
    string rect[16] = ""                                // RECT struct
    integer pRect = AdjPtr(Addr(rect), 2)
    integer rectRight, rectBottom

    GetClientRect(hwnd, pRect)

    rectRight  = PeekLong(AdjPtr(pRect,8))
    rectBottom = PeekLong(AdjPtr(pRect,12)) - toolbar_height

    col_width  = rectRight / Query(ScreenCols)
    row_height = rectBottom / Query(ScreenRows)
end

// compute mouse coordinates in terms of rows and columns

proc GetMousePos(var integer row, var integer col)
    string pt[8] = ""                                   // POINT struct
    integer pPoint = AdjPtr(Addr(pt), 2)
    integer ptX, ptY

    // compute position of mouse

    GetCursorPos(pPoint)
    ScreenToClient(hwnd, pPoint)

    ptX = PeekLong(pPoint)
    ptY = PeekLong(AdjPtr(pPoint,4))

    col = ptX / col_width + 1
    row = (ptY - toolbar_height) / row_height + 1

    // window must not become smaller than the status box

    col = Max(BOX_COLS, col)
    row = Max(BOX_ROWS, row)

    // handle integer underflow (65535 => -1)

    if col > 1024
        col = BOX_COLS
    endif
    if row > 1024
        row = BOX_ROWS
    endif
end

/****************************************************************************\
    mouse tracking
\****************************************************************************/

proc TrackMouse()
    integer rc
    integer col, row
    integer clr = Query(MenuTextAttr)

    rc = PopWinOpen(1, 1, BOX_COLS, BOX_ROWS, 4, "resizing", clr)
    if rc
        Set(Attr, clr)
        ClrScr()

        GetToolbarHeight()
        InitMouseTracking()
        repeat
            GetMousePos(row, col)

            VGotoXY(4,2)
            PutStr(Format(col:-4, row:4))

            Delay(1)
            if KeyPressed()
                rc = GetKey() <> <Escape>
            endif
        until not (rc and MouseKeyHeld())

        PopWinClose()
    endif
    if rc
        prev_x = 0
        SetVideoRowsCols(row,col)
    endif
end

/****************************************************************************\
    minimize/maximize window
\****************************************************************************/

proc StorePosition()
    prev_cols = Query(ScreenCols)
    prev_rows = Query(ScreenRows)
    GetWindowPosition(prev_x, prev_y)
end

proc Maximize()
    integer rows, cols

    StorePosition()
    GetMaxRowsCols(rows,cols)
    SetVideoRowsCols(rows,cols)
end

proc Minimize()
    StorePosition()
    SetVideoRowsCols(BOX_ROWS, BOX_COLS)
    PushKey(<Escape>)
end

menu SizeMenu()
    history = 2

    "Mi&nimize",    Minimize()
    "Ma&ximize",    Maximize()
end

proc ShowSizeMenu()
    if prev_x
        SetVideoRowsCols(prev_rows, prev_cols)
        SetWindowPosition(prev_x, prev_y)
        prev_x = 0
    else
        Set(X1, Query(ScreenCols))
        Set(Y1, Query(ScreenRows))
        SizeMenu()
    endif
end

/****************************************************************************\
    mouse click handling
\****************************************************************************/

integer proc SizeBtnClicked()
    return( Query(MouseX) > Query(ScreenCols) - 3  and Query(MouseY) == Query(ScreenRows) )
end

proc LeftBtnDown()
    if SizeBtnClicked()
        TrackMouse()
    else
        ChainCmd()
    endif
end

proc RightBtnDown()
    if SizeBtnClicked()
        ShowSizeMenu()
    else
        ChainCmd()
    endif
end

/****************************************************************************\
    button painting
\****************************************************************************/

proc PaintSizeBtn()
    VGotoXY(Query(ScreenCols)-2, Query(ScreenRows))
    Set(Attr, ButtonColor)
    PutStr(" S ")
end

/****************************************************************************\
     init and shutdown
\****************************************************************************/

proc WhenLoaded()
    hwnd = GetWinHandle()
    Hook(_AFTER_UPDATE_STATUSLINE_, PaintSizeBtn)
end

proc WhenPurged()
    UnHook(PaintSizeBtn)
end

/****************************************************************************\
    key definitions
\****************************************************************************/

<LeftBtn>   LeftBtnDown()
<RightBtn>  RightBtnDown()

<MENU_KEY>  ShowSizeMenu()

