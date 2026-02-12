// DispTime macro for The Semware Editor
// Public Domain by Dave Navarro, Jr.
// Last Revision:  September 28, 1994

/**************************************************************************
                Display a running clock at right of status line
 *************************************************************************/
proc mDispTime()
    integer SaveColor
    SaveColor = Query(Attr)
    Set(Attr, Query(StatusLineAttr))
    if Query(StatusLineAtTop) == TRUE
        VGotoXY( Query(ScreenCols)-8, 1 )
    else
        VGotoXY( Query(ScreenCols)-8, Query(ScreenRows) )
    endif
    PutStr( GetTimeStr() )
    Set(Attr, SaveColor)
end

/****************************************************************************
     This macro is called the first time a file is loaded into the editor.
 ***************************************************************************/
proc OnFirstEdit()
    Hook(_IDLE_, mDispTime)
    Hook(_AFTER_UPDATE_STATUSLINE_, mDispTime)
    Hook(_AFTER_UPDATEDISPLAY_, mDispTime)
end
