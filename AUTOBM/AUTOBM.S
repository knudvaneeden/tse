/*****************************************************************************
                                AutoBookMark

           Macros to automatically add bookmarks at section heads
       or other searchable point when changing files. (Very effective
              with a bookmark system that includes picklists.)

              Change the file extension(s), search strings and
          search options within the CASE statement inside of
                    proc automarks(), at about line 64,
                             to suit yourself.

                         To use, compile and load.

                            version 2, 02-24-94

Version 2 is faster. It does not reset bookmarks if you go from a
file to the same file, as may happend during the execution of many
macros that use work buffers, lists, etc.

 ****************************************************************************/
INTEGER
    exitcalled = FALSE,
    messages = FALSE
STRING
    last_file_name[78]=''



proc automarks()
    string
        str1[64]= '',           // place bookmarks where this str is found
        opt1[8] = '',           // using these search options
        str2[64]= '',           // or this one, if no str1 found,
        opt2[8] = '',           // using these search options.
                                //
        excl[64]= '',           // If this string is in the same line with
        eopt[8]= '' ,           // the found text, no bm is placed.
                                //
        marks[26] = 'abcdefghijklmnopqrstuvwxyz'

    integer
        counter = 0,
        tb,                     // temp buffer
        start_count =  7        // start assigning with this letter
                                // of alphabet.

    /*
        Don't set bookmarks when switching to a system buffer.
        Or when exiting TSE.
    */
    if BufferType() == _SYSTEM_
       or exitcalled == TRUE
       or last_file_name == ExpandPath(CurrFileName())
        return()
    endif

    /*
        Set search string(s) according to file name.
        Also set search options.
        NOTE: Keep regular expressions simple, if used, or you'll
              take a speed hit.
    */
    case Trim(SplitPath(CurrFileName(), _EXT_))
        when '.s', '.inc'
            str1 = '{proc }|{menu }'
            opt1 = 'ix+'
            excl = 'forward'
            eopt = 'i'
        when '.asc', '.txt', '.mvp'
            str1 = GetGlobalStr('vp_major_heading_tag')
            opt1 = '^i'
            str2 = GetGlobalStr('vp_medium_heading_tag')
            opt2 = '^i'
        otherwise
            return()
    endcase

    PushPosition()

    // Now add bookmarks for str1:
    if messages == TRUE message('Adding bookmarks...') endif
    counter = start_count
    BegFile()
    while lfind( str1, opt1) and (counter <= 26)
        if not Length(excl) or
           not lFind(excl, eopt + 'cg')
            PlaceMark(marks[counter])
            counter = counter + 1
        endif
        down()
    endwhile

    // If str1 not found and str2 is defined
    // add bookmarks for str2:
    if counter == start_count and Length(str2)
        while lfind(str2, opt2) and (counter <= 26)
        if not Length(excl) or not lFind(excl, eopt + 'cg')
             PlaceMark(marks[counter])
             counter = counter + 1
        endif
             down()
         endwhile
    endif

    // Delete extra existing bookmarks in the to be used:
    if counter <= 26
        if messages == TRUE message('Deleting unused bookmarks...') endif
        Pushposition()
        tb = CreateBuffer('+++killbms+++', _SYSTEM_)
        while counter <= 26
            PlaceMark(marks[counter])
            counter = counter + 1
        endwhile
        AbandonFile(tb)
        Popposition()
    endif

    PopPosition()
    if Messages == TRUE UpdateDisplay(_STATUSLINE_REFRESH_) endif
    last_file_name = ExpandPath(CurrFileName())
end

proc                        no_more_automarks()
    exitcalled = TRUE
end

proc                        whenloaded()
    Hook(_ON_CHANGING_FILES_, automarks)
    Hook(_ON_EXIT_CALLED_, no_more_automarks)
end
