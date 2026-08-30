/****************************************************************************
    Block procs.                            03-12-94
                                            D. Marcus v3.147c

    1. resize_block()
        (a) if block marking is in progress, ends block
        (b) if cursor is inside a marked block, shrinks nearest of
            beginning or end of block (or block corner) to cursor position.
        (c) if cursor is outside a marked block, expands block to cursor

    2. change_block_type()
        if called with argument "1" and block is marked,
            cycles block type this way
                char --> column --> line --> char
        if called with other argument and block is marked,
            cycles block type this way
                char --> line --> column --> char

    Note: See key assignments at end of file.
****************************************************************************/
INTEGER
    x1, y1, ycur, x2, y2, xcur, type,
    c1=0, c2=0, c3=0, c4=0 // distance to corners

FORWARD proc                  end_or_resize_block()
FORWARD proc                  change_block_type(INTEGER mode)

FORWARD proc                  gotoposxy(INTEGER x, INTEGER y)
FORWARD integer proc          max(INTEGER a, INTEGER b, INTEGER c, INTEGER d)
FORWARD proc                  message_block(STRING arg)
FORWARD proc                  make_it_a_char_block()
FORWARD proc                  make_it_a_col_block()

/****************************************************************************
    END_OR_RESIZE_BLOCK()
        Use (a) to end any block marking
            (b) to change the start or end location of an already-marked
                block.
 ****************************************************************************/
proc                          end_or_resize_block()
    PushPosition()
    type = isCursorInBlock()
    /*
        If cursor is in a marked Block, shrink the Block unless it is
        at the beginning or end (or side, for a column Block).  The
        'else' of this if structure has the expancBlock actions.
    */
    if type
        xcur = CurrPos()    ycur = CurrLine()
        y1 =   Query(BlockBegLine)
        x1 =   iif( type == _LINE_, 0, Query(BlockBegCol) )
        y2 =   Query(BlockEndLine)
        x2 =   iif( type == _LINE_, 0, Query(BlockEndCol) )
        if type == _NON_INCLUSIVE_
            x2 = x2+1
        endif

        /*
            Calculate distance to corners
        */
        c1 = Abs(xcur - x1) + Abs(ycur - y1)
        c2 = Abs(xcur - x2) + Abs(ycur - y2)
        c3 = Abs(xcur - x1) + Abs(ycur - y2)
        c4 = Abs(xcur - x2) + Abs(ycur - y1)

        /*
        if character block and at beginning/end or
           line Block & cursor is on the top OR bottom line OR
           column Block & cursor is on a corner
        then end marking AND halt.
        */
        if c1 == 0 OR c2 == 0
           OR ( type == _LINE_ AND ((ycur == y1) OR (ycur == y2)) )
           OR ( type == _COLUMN_
                AND ((ycur == y1) OR (ycur == y2))
                AND ((xcur == x1) OR (xcur == x2)) )
            Set(Marking,OFF)           // end the Block marking
            message_block('ended')
            return()                   // exit
        endif

        /*
            block was marked but we are
            not on end/corner/edge of block
        */
        UnMarkBlock()
        if type <> _COLUMN_
            if c1 > c2      GotoPosXY(x1,y1)
            else            GotoPosXY(x2,Y2)
            endif
        else
            if     c1 == max(c1, c2, c3, c4)    GotoPosXY(x1,y1)
            elseif c2 == max(c1, c2, c3, c4)    GotoPosXY(x2,y2)
            elseif c3 == max(c1, c2, c3, c4)    GotoPosXY(x1,y2)
            elseif c4 == max(c1, c2, c3, c4)    GotoPosXY(x2,y1)
            endif
        endif
        Mark(type)  GotoPosXY(xcur,ycur)  Mark(type)
        message_block('ended')
    else
        /*
             Cursor is NOT in a marked Block
             ... continue the current Block Type,
        */
        Mark(isBlockInCurrFile())
        Set(Marking,OFF)
        message_block('ended')
    endif
    PopPosition()
end

/****************************************************************************
    change block type
        Changes marked block  (if in current file)
            from char --> line --> column --> char
 ****************************************************************************/
proc change_block_type(INTEGER foo)
    y1 = Query(BlockBegLine)
    x1 = iif( type == _LINE_, 0, Query(BlockBegCol) )
    y2 = Query(BlockEndLine)
    x2 = iif( type == _LINE_, 0, Query(BlockEndCol) )
    if isBlockInCurrFile()
        PushPosition()      PushBlock()     // allows recovery by PopBlock() assigned to key
        case IsBlockMarked()
            when _INCLUSIVE_,
                 _NON_INCLUSIVE_  if foo == 1 make_it_a_col_block()
                                  else        MarkLine(y1, y2)
                                  endif
            when _COLUMN_         if foo == 1 MarkLine(y1, y2)
                                  else        make_it_a_char_block()
                                  endif
            when _LINE_           if foo == 1 make_it_a_char_block()
                                  else        make_it_a_col_block()
                                  endif
        endcase
        message_block('')
        PopPosition()
    endif
end

proc message_block(STRING arg)
    string type[16]='???'
    case IsBlockMarked()
        when _LINE_         type = "line"
        when _COLUMN_       type = "col"
        when _NONINCLUSIVE_ type = "non-incl char"
        when _INCLUSIVE_    type = "char"
    endcase
    Message(type, " block ", arg)
end

integer proc max(INTEGER a, INTEGER b, INTEGER c, INTEGER d)
    if a>=b and a>=c and a>=d   return(a)
    elseif b>=c and b>=d        return(b)
    elseif c>=d                 return(c)
    endif                       return(d)
end

proc gotoposxy(INTEGER x, INTEGER y)
    GotoPos(x) GotoLine(y)
end

proc make_it_a_char_block()
    UnMarkBlock()
    GotoLine(y1)    GotoPos(PosFirstNonWhite())     MarkChar()
    GotoLine(y2)    GotoPos(PosLastNonWhite()+1)    MarkChar()
end

proc make_it_a_col_block()
  integer left_side=MAXINT, right_side=0
  GotoLine(y1)
  repeat
      left_side = iif(left_side < PosFirstNonWhite(), left_side, PosFirstNonWhite())
      right_side = iif(right_side > PosLastNonWhite(), right_side, PosLastNonWhite())
  until NOT Down() or (CurrLine() > y2)
  MarkColumn(y1,left_side,y2,right_side)
end

/*
Key assignments:
    F3 keys start blocks:
        Each does a PushBlock() first to allow recovery of the current block.
        Each then does an UnMarkBlock() so to always _start_ a block.
    F4 ends block if marking already started; resizes if block already marked.
*/

<f3>           PushBlock() UnMarkBlock() MarkChar()
<shift f3>     PushBlock() UnMarkBlock() MarkLine()
<ctrl f3>      PushBlock() UnMarkBlock() MarkColumn()
<alt f3>       change_block_type(0)
// <alt f3>    change_block_type(1) // which of these is a matter of taste

<f4>           end_or_resize_block()
<shift f4>     UnMarkBlock()
<alt f4>       PopBlock()

<f5>           GotoBlockBegin()
<f6>           GotoBlockEnd()