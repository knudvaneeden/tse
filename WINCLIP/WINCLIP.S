/****************************************************************************\

    WinClip.S

    Copies blocks into and out of the windows clipboard.

    Version         v1.00/18.01.95
    Copyright       (c) 1995 by DiK

    History
    v1.00/18.01.95  primary release

\****************************************************************************/

binary "winclip.bin"
    integer proc GetString( var integer ofs, var string txt )           : 0
    integer proc PutString( var integer ofs, string txt: strval )       : 3
            proc PutNullChar( var integer ofs )                         : 6
    integer proc CheckForWindows()                                      : 9
    integer proc OpenClipboard()                                        : 12
    integer proc CloseClipboard()                                       : 15
    integer proc EmptyClipboard()                                       : 18
    integer proc GetClipboardDataSize()                                 : 21
    integer proc GetClipboardData()                                     : 24
    integer proc SetClipboardData( integer size: word )                 : 27
end

/****************************************************************************\
    global variables
\****************************************************************************/

constant    maxdata = 0x3000

integer     clip

string      get_err[40] = "Cannot receive data from clipboard."
string      len_err[40] = "Too much data (more than 12287 bytes)."

/****************************************************************************\
    cut and copy
\****************************************************************************/

proc CopyCut( integer del )
    integer file
    integer size
    integer ok

    // copy or move block to tse buffer

    if isBlockInCurrFile() == 0
        MarkLine()
    endif
    file = GotoBufferId(clip)
    if del
        MoveBlock()
    else
        CopyBlock()
    endif
    UnmarkBlock()

    // copy block to external buffer

    size = 0
    repeat
        if CurrLineLen() > 254
            Alarm()
            Warn("Line too long (length > 254).")
            goto CleanUp
        endif
        if PutString(size,GetText(1,CurrLineLen()))
            Alarm()
            Warn(len_err)
            goto CleanUp
        endif
    until not Down()
    PutNullChar(size)

    // copy external buffer to windows clipboard

    ok = OpenClipboard()
    if ok
        ok = EmptyClipboard() and SetClipboardData(size)
        CloseClipboard()
    endif
    if not ok
        Alarm()
        Warn("Cannot send data to clipboard.")
    endif

    // cleanup and return to file

    CleanUp:
    EmptyBuffer()
    GotoBufferId(file)
end

/****************************************************************************\
    paste data
\****************************************************************************/

proc PasteData( integer block, integer action )
    integer file
    integer data
    integer size
    integer long
    integer code
    string  line[254] = ""

    // copy windows clipboard to external buffer

    code = OpenClipboard()
    if code
        data = GetClipboardDataSize()
        if data > maxdata
            Alarm()
            Warn(len_err)
            return()
        endif
        code = GetClipboardData()
        CloseClipboard()
    endif
    if not code
        Alarm()
        Warn(get_err)
        return()
    endif

    // copy external buffer to tse buffer

    file = GotoBufferId(clip)
    size = 0
    long = 0
    code = 0
    while code == 0 and size < data
        code = GetString(size,line)
        if code == 0 or code == 1 and Length(line) > 0
            if Length(line) > long
                long = Length(line)
            endif
            AddLine(line)
        endif
    endwhile
    if code == 2
        Alarm()
        Warn(get_err)
        goto CleanUp
    endif

    // copy data from tse buffer to file

    UnmarkBlock()
    case block
        when _NONINCLUSIVE_
            BegFile()
            MarkChar()
            EndFile()
        when _LINE_
            BegFile()
            MarkLine()
            EndFile()
        when _COLUMN_
            MarkColumn(1,1,NumLines(),long)
    endcase
    GotoBufferId(file)
    CopyBlock(action)

    // cleanup and return to file

    CleanUp:
    EmptyBuffer(clip)
    GotoBufferId(file)
end

/****************************************************************************\
    entry points
\****************************************************************************/

public proc WinCut()
    CopyCut(TRUE)
end

public proc WinCopy()
    CopyCut(FALSE)
end

public proc WinPasteChar()
    PasteData(_NONINCLUSIVE_,_DEFAULT_)
end

public proc WinPasteLine()
    PasteData(_LINE_,_DEFAULT_)
end

public proc WinPasteColumn()
    PasteData(_COLUMN_,_DEFAULT_)
end

public proc WinPasteOver()
    PasteData(_COLUMN_,_OVERWRITE_)
end

/****************************************************************************\
    menu
\****************************************************************************/

menu WinClipMenu()
    Title = 'WinClip'
    history

    "Cu&t",
        WinCut(),,
        "Delete the current block or line and move it into the windows clipboard"
    "&Copy",
        WinCopy(),,
        "Copy the current block or line into the windows clipboard"
    "",,    Divide
    "&Paste Char",
        WinPasteChar(),,
        "Copy the contents of the windows clipboard as character block"
    "Paste &Line",
        WinPasteLine(),,
        "Copy the contents of the windows clipboard as line block"
    "Paste &Kolumn",
        WinPasteColumn(),,
        "Copy the contents of the windows clipboard as column block"
    "",,    Divide
    "&Paste &Over",
        WinPasteOver(),,
        "Overwrite the text at the cursor with the contents of the windows clipboard"
end

/****************************************************************************\
    main
\****************************************************************************/

proc main()
    if CheckForWindows()
        clip = CreateTempBuffer()
        if clip
            PrevFile()
            WinClipMenu()
            AbandonFile(clip)
        else
            Alarm()
            Warn("Cannot allocate work space.")
        endif
    else
        Alarm()
        Warn("Windows either not loaded or not running in enhanced mode.")
    endif
    PurgeMacro(CurrMacroFilename())
end

