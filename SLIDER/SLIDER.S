
// Slide a column block over existing text and paste it at a chosen location.

proc mSlider()
    integer old_after_paste, orig, size_hor, size_ver, text_top, text_sub,
            exit_flag=FALSE

    if isBlockMarked() <> 8
        Message('Slider requires a marked COLUMN block')
        return()
    endif
    old_after_paste = Query(UnmarkAfterPaste)
    Set(UnmarkAfterPaste, OFF)
    orig = GetBufferId()
    GotoBlockBegin()
    PlaceMark('q')
    size_ver = Query(BlockEndLine) - Query(BlockBegLine)
    size_hor = Query(BlockEndCol) - Query(BlockBegCol)
    text_top = CreateTempBuffer()
    text_sub = CreateTempBuffer()
    GotoBufferId(orig)
    Set(ClipBoardId,text_top)
    PushBlock()
    Copy()
    PopBlock()
    Set(ClipBoardId,text_sub)
    FillBlock(' ')
    Copy()
    repeat
        Message("MOVE: Cursor Keys, Tab, Shft-Tab, PgUp, PgDn, Home    DONE: Enter    CANCEL: Esc")

//  Restore underlying text in ORIG buffer
        Set(ClipBoardId,text_sub)
        Paste(_OVERWRITE_)
//  The moving block isn't there anymore, but the screen is not updated yet.

        case GetKey()
            when <CursorRight>
                Right(size_hor + 1)
                Left(size_hor)
            when <Tab>
                Right(size_hor + 12)
                Left(size_hor)
            when <Shift Tab>
                Left(12)
            when <CursorLeft>
                Left()
            when <CursorDown>
                Down(size_ver + 1)
                Up(size_ver)
            when <PgDn>
                Down(size_ver + 6)
                Up(size_ver)
            when <CursorUp>
                Up()
            when <PgUp>
                Up(6)
            when <Home>
                GotoMark('q')
            when <Escape>
                GotoMark('q')
                exit_flag = TRUE
            when  <Enter>, <GreyEnter>
                exit_flag = TRUE
        endcase

//  Update underlying block in TEXT_SUB
        UnmarkBlock()
        MarkColumn()
        PushPosition()
        Right(size_hor)
        Down(size_ver)
        Set(ClipBoardId,text_sub)
        Copy()

//  Restore moving block in ORIG
        PopPosition()
        Set(ClipBoardId,text_top)
        Paste(_OVERWRITE_)
        UpdateDisplay()         // while waiting for GetKey()

    until exit_flag
    UnmarkBlock()
    Set(UnmarkAfterPaste, old_after_paste)
end

proc Main()
    Message('F12 to activate SLIDER')
end

<F12>  mSlider()
