/*
  Alternate SaveBlock() command.  This version has Overlay first on the
  menu, as did TSE 1.0

  To use, include this in your .ui file, and assign mSaveBlock() to a key
  and/or menu, replacing SaveBlock().

 */

menu SaveBlockMenu()
    history

    "&Overlay"
    "&Append"
    "&Cancel"
end

integer proc GetFilename(string msg, var string reply, integer history)
    string fn[80] = reply

    while Ask(msg, fn, HISTORY)
        fn = ExpandPath(fn)
        if Pos('?', fn) or Pos('*', fn)
            fn = PickFile(fn)
        endif
        if Length(fn)
            reply = fn
            return (TRUE)
        endif
    endwhile
    return (FALSE)
end

proc mSaveBlock()
    integer choice
    string fn[80] = '',
        msg[80] = iif(isBlockInCurrFile(), "Save block to:", "Save as:")

    while GetFilename(msg, fn, _EDIT_HISTORY_)
        choice = 0
        if FileExists(fn)
            choice = SaveBlockMenu("File exists")
            if choice == 0 or choice == 3
                goto continue
            endif
        endif
        if SaveBlock(fn, iif(choice == 1, _OVERWRITE_, _APPEND_))
            return ()
        endif

        continue:
    endwhile
end

