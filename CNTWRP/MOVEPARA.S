/************************************************************************
  A group of macros to go to the next and previous paragraphs,
  and to the beginning or end of the current paragraph.
  Assumes paragraphs are separated by blank lines.
 ************************************************************************/

// Go to the start of the next Paragraph or to EOF.
proc NextPara()
    if not Down()                       // exit if at EOF
        goto common_exit
    endif

    // if in a paragraph, scan till the end of it
    while PosFirstNonWhite()
        if not Down()                   // exit if at EOF
            goto common_exit
        endif
    endwhile

    // skip any blank lines
    while PosFirstNonWhite() == 0
        if not Down()                   // exit if at EOF
            goto common_exit
        endif
    endwhile

    common_exit:
    GotoPos(PosFirstNonWhite())
end NextPara

// If in a para (and not on the first line) go to the beginning of the para.
// Otherwise, go to the beginning of the previous para.
proc PrevPara()
    if not Up()                         // exit if at BOF
        goto common_exit
    endif

    // skip any blank lines
    while PosFirstNonWhite() == 0
        if not Up()                     // exit if at BOF
            goto common_exit
        endif
    endwhile

    // must be in a paragraph, scan till the start of it or until BOF
    while PosFirstNonWhite()
        if not Up()                     // exit if at BOF
            goto common_exit
        endif
    endwhile

    Down()                              // not at BOF, move to 1st line of para

    common_exit:
    GotoPos(PosFirstNonWhite())
end PrevPara

// If in a para, go to the end of the para or to EOF.
// Otherwise, go to the end of the next para or to EOF.
proc EndPara()
    // skip any blank lines
    while PosFirstNonWhite() == 0
        if not Down()                   // exit if at EOF
            goto common_exit
        endif
    endwhile

    // must be in a paragraph, scan till the end of it or until EOF
    while PosFirstNonWhite()
        if not Down()                   // exit if at EOF
            break
        endif
    endwhile

    common_exit:
    GotoPos(PosFirstNonWhite())
end EndPara

// If in a para, go to the beginning of the para or to BOF.
// Otherwise, go to the beginning of the previous para or to BOF.
proc BeginPara()
    // skip any blank lines
    while PosFirstNonWhite() == 0
        if not Up()                     // exit if at BOF
            goto common_exit
        endif
    endwhile

    // must be in a paragraph, scan till the start of it or until BOF
    while PosFirstNonWhite()
        if not Up()
            goto common_exit
        endif
    endwhile

    Down()                              // not at BOF, move to 1st line of para

    common_exit:
    GotoPos(PosFirstNonWhite())
end BeginPara

