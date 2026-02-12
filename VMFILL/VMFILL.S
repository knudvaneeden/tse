/**********************************************************************
procedure==>  vmFill(s,s)  <==by Volker Multhopp  04/30/93

Superior to standard FillBlock() in as much as it will fill with an entire
string, not just a character.  Also it recognizes user's left margin.
There are 2 modes or styles:
    'w' where the filler string wraps around, and
    'c' where the chars are aligned in columns.

    returns: 1 if fill done.
    notes:  Normally to be assigned a key as
            <key> vmFill('','') ;
            but can be called by another macro with string args.

**********************************************************************/
/**********************************************************************
procedure==>  vmFillinlay(sii)  <==by Volker Multhopp  04/29/93
              a SUB-ROUTINE
              Lays in numchars.
              returns: The position of the next char of filler to be inlaid.
              notes:  Called by vmFill.  Editor is already on the
                      correct line, correct column.

**********************************************************************/
integer proc vmFillinlay(string filler, integer at, integer numchars)
    // 'at' is pos in filler.  numchars is num chars to inlay

    integer num=numchars, m,
        len = length (filler)

    if num < 1
        return (at)     // safety exit.
    endif

    // do first part part
    if at > 1   // not starting at 1
        m = len - at + 1 // length str from at to end
        if m >= num  // just do num and out
            inserttext(substr(filler,at,num))
            m = at + num - 1
            goto out
        endif
        inserttext(substr(filler,at,m))
        num = num - m  // reset m
    endif       // won't need at any more

    // do wholes part
    m = num / len       // num of whole strings.
    while m
        inserttext(filler)
        m = m - 1
    endwhile

    // do last part part
    m = num mod len     // remainder
    if m
        inserttext(substr(filler,1,m))
    endif

    out:
    // m was pos last char inserted, next will be one more.
    return(iif( m >= len, 1, m + 1 ) )

end  // of vmFillinlay().

/**********************************************************************
This is it.
**********************************************************************/
integer proc vmFill(string calledFiller, string calledstyle)

    integer
        x1, y1, x2, y2,  // block endpoints
        fir, las, len, numchars, nx=1,  // filler data
        stat,   // status, last down result
        blocktype = isBlockMarked(),
        savinsert = query (insert),
        savmarking = query (marking),
        lmar = query(leftmargin)

    string filler[40]='',
        style[1] = 'w'

    set ( insert , off )  // overwrite
    set ( marking, off )  // don't drag your end all over the place
    lmar = iif(lmar,lmar,1)

    // find the end points
    pushposition()
    gotoblockend()
    x2 = currpos()
    y2 = currline()
    if Blocktype == _Line_  // line blocks are funny
        x2 = PosLastNonWhite()
        x2 = iif ( x2, x2, 1 )
    endif
    gotoblockbegin()
    x1 = currpos()
    y1 = currline()
    if Blocktype == _Line_
        x1 = PosFirstNonWhite()
        x1 = iif ( x1, x1, 1 )
    endif
    popposition()

    // make sure there's a block, and for safety, it's in curr file
    if not ( blocktype and isBlockinCurrFile() ) goto bad endif

    // get the filler string
    if length (calledFiller) == 0
        stat = ask('Fill block with which string?',filler)
        if length ( filler ) == 0 or not stat goto bad endif  //exit
    else
        filler =  calledfiller
    endif
    len = length(filler)
    if len == 1 or
        ( not((x2 - x1 + 1) mod len ) and BlockType == _Column_ )
        style = 'w' // dosen't matter.
        goto start
    endif

    getstyle:
    if length (calledstyle) == 0
        if ask('style of fill:  Columnar or Wrapped [CW]?', style)
            lower(style)
            if not ( style == 'c' or style == 'w' )
                goto getstyle
            endif
        else
            goto bad    // user escaped
        endif
    else
        style = calledstyle
        lower (style)
        if not (style == 'c')
            style = 'w'    // if you don't call right, you get wrapped
        endif
    endif


    start:
    pushposition()
    gotoBlockBegin()
    gotopos(x1)
    if BlockType == _column_
        goto columnBlock
    endif

    //do the first line.
    numchars = (iif( y2==y1, x2, posLastNonWhite())) - x1 + 1
    // if one line, use blockend
    nx = vmFillinlay(filler,1,numchars)
    stat = down()
    if currline() > y2 or not stat
        goto done
    elseif currline() == y2
        goto lastline
    endif

    // do each line.
    while currline() < y2
        fir = posFirstnonWhite()
        fir = iif( lmar <= fir, lmar, fir ) // respect lmar if user does.
        las = posLastnonWhite()
        if fir  //  any chars?
            gotopos(fir)
            if style=='c'
                nx = ( fir -x1 + 1) mod len
                nx = iif ( nx < 1, nx + len, nx)
            endif
            nx = vmFillinlay(filler,nx,las - fir +1)
        endif
        down()
    endwhile

    lastline:
    //do the last line.
    fir = posFirstnonWhite()
    fir = iif( lmar <= fir, lmar, fir ) // respect lmar if user does.
    gotopos(fir)
    if style=='c'
        nx = ( fir - x1 + 1) mod len
        nx = iif ( nx < 1, nx + len, nx)
    endif
    vmFillinlay(filler,nx,x2 - fir +1)
    goto done

    ColumnBlock:
    // easy!
    nx = vmFillinlay(filler,1,x2 - x1 +1)
    stat = down()
    if not stat or currline() > y2
        goto done
    endif
    while currline() <= y2
        gotopos(x1)
        if style == 'c'
            nx = 1
        endif
        nx = vmFillinlay(filler,nx,x2 - x1 +1)
        stat = down()
        if not stat break endif // eof
    endwhile
    goto done

    bad:
    warn('Bad FILL call, or no block marked in file.')
    stat = 0
    goto restore

    done:
    popposition()
    stat = 1

    restore:
    // restore user settings and out
    set ( insert , savinsert )
    set ( marking, savmarking)
    return(stat)

end    // of vmFill().

// test with    <grey*> vmFill('','')