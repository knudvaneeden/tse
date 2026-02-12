/* The Slide Macros work in conjuction with the cursor, cursor line,
   column and line blocks to provide an easy and fast way of moving
   text short distances with a minimum of effort.

   In general, the macros work by "grabbing" a character, line, or
   block, and then causing that item to move WITH the cursor, thereby
   sliding through or around the surrounding text.  This is particularly
   useful for transposing lines ( an extention to the mSwapLine() macro ),
   characters within a word, etc.

   The slide macros are bound at the end of this source code to the
   Alt-GreyCursor arrow keys.  To invoke a slide feature, simply hold down
   the Alt key while moving the cursor.  The appropriate character, block,
   or line, will move with the cursor.

   If no block is selected, then Sliding Up or Down will exchange the
   cursor line with the line above or below it respectively.  Sliding Left
   or Right will exchange the character at the cursor, with the character
   to it's immediate left or right respectively.  ( behavior is a little
   bizzare if sliding thru tabs )

   If a block is selected, then the block itself slides in the selected
   direction.  Line blocks cannot slide left or right, only up or down.
   These macros do not currently support sliding character blocks.  There
   did not seem ( to me ) to be a useful purpose for this, although certainly
   the idea can be extended, I suppose to do such a thing.

   I hope these prove useful.  I personally have found editors not capable
   of this feature to be annoying.  I would appreciate any comments on
   this idea, and the implementation of it.

   Terry Cox
   Seattle, WA

*/



/*********************************\
***                             ***
***    Terry's Slide Macro's    ***
***                             ***
\*********************************/

proc mSlideLeft()
    integer ch, col, row

    case isCursorInBlock()
        when FALSE                          // Not in a Block
            ch = CurrChar()
            DelChar()
            Left()
            InsertText(chr(ch), _INSERT_)
            Left()
        when _COLUMN_
            col = CurrCol()  row = CurrRow()
            GotoBlockBegin()
            Left()
            MoveBlock()
            GotoColumn(col-1)  GotoRow(row)
    endcase
end



proc mSlideRight()
    integer ch, col, row

    case isCursorInBlock()
        when FALSE                          // Not in a Block
            ch = CurrChar()
            DelChar()
            Right()
            InsertText(chr(ch), _INSERT_)
            Left()
        when _COLUMN_
            col = CurrCol()  row = CurrRow()
            GotoBlockBegin()
            Right()
            MoveBlock()
            GotoColumn(col+1)  GotoRow(row)
    endcase
end



proc mSlideDown()
    integer ilba, km, col, row

    ilba = Set(InsertLineBlocksAbove, FALSE)

    case isCursorInBlock()
        when FALSE                          // Not in a Block
            if( CurrLine() < NumLines() )
                km = Set(KillMax, 1)
                Down()
                DelLine()
                Up()
                UnDelete()
                Down()
                Set(KillMax, km)
            endif
        when _COLUMN_
            col = CurrCol()  row = CurrRow()
            GotoBlockBegin()
            Down()
            MoveBlock()
	    GotoColumn(col)  GotoRow(row+1)
        when _LINE_
            col = CurrCol() row = CurrRow()
	    GotoBlockEnd()
	    Down()
	    MoveBlock()
	    GotoColumn(col)  GotoRow(row+1)
    endcase

    Set(InsertLineBlocksAbove, ilba)
end



proc mSlideUp()
    integer ilba, km, col, row

    ilba = Set(InsertLineBlocksAbove, TRUE)

    case isCursorInBlock()
        when FALSE                          // Not in a Block
            km = Set(KillMax, 1)
            DelLine()
            Up()
            UnDelete()
            Set(KillMax, km)
        when _COLUMN_
            col = CurrCol()  row = CurrRow()
            GotoBlockBegin()
            Up()
            MoveBlock()
	    GotoColumn(col)  GotoRow(row-1)
        when _LINE_
            col = CurrCol() row = CurrRow()
	    GotoBlockBegin()
	    Up()
	    MoveBlock()
	    GotoColumn(col)  GotoRow(row-1)
    endcase

    Set(InsertLineBlocksAbove, ilba)
end


<Alt GreyCursorRight> mSlideRight()
<Alt GreyCursorLeft>  mSlideLeft()
<Alt GreyCursorUp>    mSlideUp()
<Alt GreyCursorDown>  mSlideDown()
