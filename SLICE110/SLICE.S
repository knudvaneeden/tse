/****************************************************************************\

    Slice.S

    Split a large file into smaller pieces.

    Version         v1.10/28.06.00
    Copyright       (c) 1998-2000 by DiK

    History
    v1.10/28.06.00  fixed error checking and user interface
    v1.01/30.10.98  minor fixes
    v1.00/23.10.98  first version

\****************************************************************************/

/****************************************************************************\
    global variables
\****************************************************************************/

integer slice_size
string caption[] = "Slice"

/****************************************************************************\
    helper routine
\****************************************************************************/

proc SliceMessage(string msg)
    integer msg_line

    if Query(StatusLineAtTop)
        msg_line = Query(ScreenRows)
    else
        msg_line = 1
    endif

    PutLineXY(1, msg_line, msg, Query(ScreenCols), Query(MenuTextAttr))
end

/****************************************************************************\
    main menu
\****************************************************************************/

proc AskSize(integer KB)
    integer remainder
    string size[8] = "0"

reiterate:
    if AskNumeric("Size of slices:", size)
        slice_size = Val(size)
        if KB
            slice_size = slice_size * 1024
        else
            remainder = slice_size mod 64
            if remainder <> 0
                MsgBox(caption, "Size of slizes must be a multiple of 64")
                size = Str(slice_size - remainder)
                goto reiterate
            endif
        endif
    else
        slice_size = 0
    endif
end

proc SetSize(integer size)
    slice_size = size
end

menu SizeMenu()
    title = "Size of Slices"
    X = 1
    Y = 1

    '3«" high density (1440kB)', SetSize(1457664)
    '3«" low  density ( 720kB)', SetSize( 730112)
    '',, _MF_DIVIDE_
    '5¬" high density (1200kB)', SetSize(1213952)
    '5¬" low  density ( 360kB)', SetSize( 362496)
    '',, _MF_DIVIDE_
    'User Specified Size (kB)...', AskSize(TRUE), _MF_CLOSE_AFTER_
    'User Specified Size (Bytes)...', AskSize(FALSE), _MF_CLOSE_AFTER_
end

/****************************************************************************\
    main program
\****************************************************************************/

proc main()
    integer from_cmdline
    integer curr_slice, num_slices
    string status[16]
    string file_name[255] = ""

    // get filename

    file_name = GetEnvStr("slice_argument")
    from_cmdline = Length(file_name) <> 0

    if from_cmdline
        if file_name[1] == '"' and file_name[Length(file_name)] == '"'
            file_name = file_name[2..Length(file_name)-1]
        endif
    else
        if not AskFilename("Name of file to slice:", file_name, _MUST_EXIST_)
            goto common_exit
        endif
    endif

    // get and verify size of slices

    SizeMenu()
    if slice_size == 0
        goto common_exit
    endif

    FindThisFile(ExpandPath(file_name))
    num_slices = FFSize() / slice_size + 1
    if num_slices == 1
        MsgBox(caption,
            "Nothing to do!" + Chr(13) +
            "Size of file is smaller than size of slices!")
        goto common_exit
    endif
    if num_slices > 999
        MsgBox(caption, "Huh!? More than 999 slices!")
        goto common_exit
    endif
    status = " of " + Str(num_slices)

    // load the file

    SliceMessage("Loading file...")
    if not EditFile("-b64 " + file_name)
        MsgBox(caption, "Cannot load file")
        goto common_exit
    endif

    // slice the file

    curr_slice = 1
    slice_size = slice_size / 64

    BegFile()
    repeat

        // mark current slice

        MarkLine()
        if not GotoLine(curr_slice * slice_size)
            GotoLine(NumLines())
        endif

        // save the block aka slice

        SliceMessage("Saving slice #" + Str(curr_slice) + status)
        SaveBlock(file_name + "." + Format(curr_slice:3:"0"))
        UnMarkBlock()

        // check for user interrupt

        if KeyPressed() and GetKey() == <Escape>
            if MsgBox(caption, "User interrupt! Quit now?", _YES_NO_CANCEL_) == 1
                break
            endif
        endif

        curr_slice = curr_slice + 1

    until not Down()

    // clean up

    SliceMessage("Terminating...")
    QuitFile()

common_exit:
    if from_cmdline
        Exit()
    endif
end
