dll "CallActX.dll"
    proc CallActX(integer hwnd)
end

proc Main()
    integer msglevel

    CallActX(GetWinHandle())

    msglevel = Set(MsgLevel, _NONE_)
    CreateTempBuffer()
    PasteFromWinClip()
    Set(MsgLevel, msglevel)
    Set(Y1, 3)
    lList("[WinClip Viewer]"
         ,Query(ScreenCols)
         ,iif(NumLines() + 3  < Query(ScreenRows), NumLines(), Query(ScreenRows) - 5)
         ,_ENABLE_SEARCH_|_ENABLE_HSCROLL_
         )
    AbandonFile()
end

<F3> Main()
