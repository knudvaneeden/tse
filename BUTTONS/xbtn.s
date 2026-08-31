/****************************************************************************\

    XBTN.S

    Add an Exit button to TSE's status/menu line.

    Overview:

    This macro displays an X in the upper right corner of TSE's window
    and calls the QuickXit macro, whenever this "exit button" is clicked.

    Keys:   (none)

    Usage notes:

    You must add XBTN to TSE's autoload list.

    Version         v1.11/28.08.01
    Copyright       (c) 1996-2001 by DiK

    History
    v1.11/28.08.01  centered quickxit
    v1.10/30.11.00  fixed exit processing (TSE v3.0)
    v1.01/08.12.97  fixed attribute update
    v1.00/16.07.97  first version

\****************************************************************************/

/****************************************************************************\
    user configurable constants
\****************************************************************************/

constant
    XNormalColor    = Color( bright yellow on red ),
    XClickedColor   = Color( blink  red on yellow )

/****************************************************************************\
    constants and variables
\****************************************************************************/

integer
    XColor = XNormalColor

/****************************************************************************\
    exit processing
\****************************************************************************/

forward proc Terminate()

keydef ExitKey
    <Escape>    Terminate()
end

proc Terminate()
    Disable(ExitKey)
    Set(X1, (Query(ScreenCols)-37) / 2)
    Set(Y1, (Query(ScreenRows)-6) / 2)
    ExecMacro("quickxit")
end

proc InitTerminate()
    Enable(ExitKey, _EXCLUSIVE_)
    PushKey(<Escape>)
end

/****************************************************************************\
    XBtn handling (painting and executing)
\****************************************************************************/

proc PaintXBtn()
    VGotoXY(Query(ScreenCols)-2,1)
    Set(Attr,XColor)
    PutStr(" X ")
end

proc PushXBtn()
    XColor = XClickedColor
    PaintXBtn()
    repeat
        Delay(1)
    until not MouseKeyHeld()
    XColor = XNormalColor
    PaintXBtn()
end

integer proc XBtnClicked()
    return( Query(MouseX) > Query(ScreenCols) - 3  and Query(MouseY) == 1 )
end

/****************************************************************************\
    event functions
\****************************************************************************/

proc LeftBtnDown()
    if XBtnClicked()
        PushXBtn()
        if XBtnClicked()
            InitTerminate()
        endif
    else
        ChainCmd()
    endif
end

/****************************************************************************\
     init and shutdown
\****************************************************************************/

proc WhenLoaded()
    Hook(_AFTER_UPDATE_STATUSLINE_, PaintXBtn)
end

proc WhenPurged()
    UnHook(PaintXBtn)
end

/****************************************************************************\
    key definitions
\****************************************************************************/

<LeftBtn>   LeftBtnDown()

