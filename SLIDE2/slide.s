/***************************************************************************
  Slide       Quick and easy way of moving lines and blocks of text

  Author:     Terry Cox - Seattle, WA

  Date:       Oct   5, 1993 - Initial Release

              June 20, 1996 - (Lanny F) Bug fix.  Single marked char would
                              get dropped on slide right.

              July 24, 2002 - (Lanny F) Bug fix for TSE GUI use.  Slide
                              left or right would generate an Ascii 254 or
                              255 if at or beyond End Of Line.

  Overview:

  The Slide Macros work in conjunction with the cursor, cursor line,
  column and line blocks to provide an easy and fast way of moving
  text short distances with a minimum of effort.

  In general, the macros work by "grabbing" a character, line, or
  block, and then causing that item to move WITH the cursor, thereby
  sliding through or around the surrounding text.  This is particularly
  useful for transposing lines ( an extension to the mSwapLine() macro ),
  characters within a word, etc.

  The slide macros are bound at the end of this source code to the
  Alt-Cursor arrow keys.  To invoke a slide feature, simply hold down
  the Alt key while moving the cursor.  The appropriate character, block,
  or line, will move with the cursor.

  If no block is selected, then Sliding Up or Down will exchange the
  cursor line with the line above or below it respectively.  Sliding Left
  or Right will exchange the character at the cursor, with the character
  to it's immediate left or right respectively.  ( behavior is a little
  bizarre if sliding thru tabs )

  If a block is selected, then the block itself slides in the selected
  direction.  Line blocks cannot slide left or right, only up or down.
  These macros do not currently support sliding character blocks.  There
  did not seem ( to me ) to be a useful purpose for this, although certainly
  the idea can be extended, I suppose to do such a thing.

  I hope these prove useful.  I personally have found editors not capable
  of this feature to be annoying.  I would appreciate any comments on
  this idea, and the implementation of it.


  Keys:
     Alt Cursor Right: Slide Column Block or Char Right
     Alt Cursor Left:  Slide Column Block or Char Left
     Alt Cursor Up:    Slide Column Block or Current Line Up
     Alt Cursor Down:  Slide Column Block or Current Line Down

  Usage Notes.
     To make this a permanent part of your TSE life, just add "Slide" to the
     AutoLoad list on the Macro menu.

***************************************************************************/

proc mSlideLeft()
    integer ch, col, row

    if currchar()<0   //Don't Slide if beyond EOL..in TSE GUI an extra char is picked up
        left()
    else
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
    endif
end



proc mSlideRight()
    integer ch, col, row

    if currchar()<0   //Don't Slide if beyond eol..in TSE GUI an extra char is picked up
        right()
    else
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
                if not isCursorInBlock()
                    Right()
                endif
                MoveBlock()
                GotoColumn(col+1)  GotoRow(row)
        endcase
    endif
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

<Alt CursorRight> mSlideRight()
<Alt CursorLeft>  mSlideLeft()
<Alt CursorUp>    mSlideUp()
<Alt CursorDown>  mSlideDown()

