/*****************************************************************************
  ReadFile() ...
              a macro to insert a disk file as a line block,
              using default TSE file extensions.

                           v1.1
                        David Marcus
                          05-10-94

   Use as ReadFile('') to be prompted for file.
   Use as ReadFile(string) to specify filename.
   In both cases, it uses default TSE file extensions and inserts the file
   as a line block.

   Version 1.1 accomodates changes made in TSE v1.52b.

þ Copyright (c) 1993-1994 David Marcus

  Permission is granted to all persons for non-commercial distribution
  of this file and the macros and ideas contained herein provided (a)
  credit is given to the author and (b) all changes not made by the
  author are attributed.

  Permission is granted to SemWare for commercial distribution provided
  (a) and (b) above.

þ Contacting The Author

  You can contact David Marcus
    ù on the SemWare BBS
    ù via CompuServe EMail (76300,3204)

*****************************************************************************/

integer proc ReadFile(STRING arg)
    integer    tid = 0
    string  fn[64] = '',
          fn2[64] = '',
         exts[38] = Query(DefaultExt)
   reask:
    if NOT Length(arg)
        if NOT ask("File to insert:", fn, _EDIT_HISTORY_)
            return(FALSE)
        endif
    else
        fn = arg
    endif

    if Pos(' ', fn)                         // strip to 1 name only
        fn = SubStr(fn, 1, Pos('ÿ', fn) - 1 )
    endif

    if Pos('*', fn) OR Pos('?', fn)         // pickfile for wildcard
       OR NOT Length(fn)
        fn2 = PickFile(fn)
        if length(fn2)                     // if not <esc>
            fn = fn2
            goto doit
        else                               // if <esc>
            goto reask                    // prompt again
        endif
    endif

    if FileExists(fn)                       // if exists, process
        goto doit
    elseif NOT Pos('.', fn)                 // if no '.', try
        fn2 = fn                           //   default extensions
        SET(BREAK,ON)
        repeat
            fn = fn2 + '.' + SubStr(exts, 1, Pos(' ', exts))
            if FileExists(fn)             // if shoe fits ...
            warn(fn, ' exists')
                goto doit                //   wear it!
            endif
            exts = SubStr(exts, Pos(' ', exts) + 1, length(exts))
        until not Pos(' ', exts)
    endif
    warn(fn, 'not found')
    if NOT length(arg)
        goto reask
    else
        return(FALSE)
    endif

   doit:
    PushPosition()
    tid = CreateTempBuffer()       // here is where the marking occurs
    InsertFile(fn)
    MarkLine(1, NumLines())
    PopPosition()
    CopyBlock()                    // note that block is left marked.
    AbandonFile(tid)
    Return(TRUE)
end