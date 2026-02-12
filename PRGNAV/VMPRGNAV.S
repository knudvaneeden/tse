/**********************************************************************
procedure==>  vmProgNav ('u'|'d')  <==by Volker Multhopp  05/12/93

    A procedure for navigating upwards or downwards in programs,
outlines, and other formally structured texts.  Assign this
procedure to two keys-- one up, the other down.

    The operation of this procedure is much more difficult to
    describe than use.  Once you get used to it (won't take long),
    you'll wonder how did without it.

    returns: 1 if cursor moved, else 0.

    notes:  vmProgNav is a general navigation routine for use in
    programs and outlines.  It traverses the text upwards or
    downwards depending on whether the calling argument is 'u' or
    'd'.

    The DESCRIPTION OF OPERATION below applies to 'u'p; 'd'own is
    identical, except for direction:

    1.  The CURSOR column is unimportant, critical is the column
    (indent) of the firstnonwhite.

    2.  If the current line is empty, go up until non-empty.  End.

    3.  Otherwise always IGNORE empty lines.

    4.  If the current line is unindented (indent=1), go up until
    there's an indented line.  End.

    5.  If the line above has the SAME indent as the current line,
    go up until there's a line with less indent. Ie., go up to the
    next higher level of organization.  End.

    6.  If the line above has a DIFFERENT indent than the current
    line, go up until there's line with the same or less indent as
    the lesser of the current line or new line.   Ie., go to an
    equal or higher level.  Eg., if on 'endif' find 'else' or 'if'.
    End.

    7.  Done.


    This procedure is biased to going toward less indented (higher
    level or more fundamental) lines.

    This procedure will only move logically if the text is logically
    indented.

    I like to assign this procedure to the <alt greycursor > keys,
    see end.

    Except in trivial cases this procedure will traverse at least
    two lines.

**********************************************************************/
integer proc vmProgNav (string dir)
    integer GoUp=false,   // direction of navigation
    org_indent=PosFirstNonWhite(),  // later this is a column position.
    alt_indent,
    i

    // ascertain called direction.
    if lower(dir[1])=='u'
        GoUp=true
    else
        if not(lower(dir[1])=='d')
            warn('Error calling vmProgNav ')
            return(0)
        endif
    endif

    // deal with silly BOF, EOF cases.
    pushposition()
    if not( iif( GoUP, up(), down()))
        popposition()
        return(0)
    endif
    popposition()

    // we're gonna travel.

    // on empty line?
    if not org_indent
        while iif( GoUP, up(), down())
            if PosFirstNonWhite()
                break   // end while looping
            endif
        endwhile
        return(1)    // done.
    endif

    gotoPos(org_indent)
    org_indent=currcol()

    // unindented?
    if org_indent == 1
        while iif( GoUP, up(), down())
            if PosFirstNonWhite() > 1
                break   // done
            endif
        endwhile
        return(1)
    endif

    // find first non white line.
    while iif( GoUP, up(), down())
        if PosFirstNonWhite()
            break
        endif
    endwhile

    // determine mode of operation
    gotoPos(PosFirstNonWhite())
    alt_indent=currcol()
    if alt_indent<>org_indent
        alt_indent = iif( alt_indent < org_indent, alt_indent, org_indent) + 1
        // +1 is a kludge, since we're going to do a strictly less than search.
    endif

    // Mainloop
    while iif( GoUP, up(), down())
        i = PosFirstNonWhite()
        if i
            GotoPos(i)
            if CurrCol() < Alt_indent
                break   // we're outta here.
            endif
        endif
    endwhile
    return(1)

end  // of vmProgNav ().

// These assignments are for test purposes:
<alt greycursorup>     vmProgNav ('u')
<alt greycursordown>   vmProgNav ('d')
