/*************************************************************************
  Blockcnt    Counts of number of blocked lines or columns in
              current file and displays count on the editor's header.
              Works for both line and column blocking.  Displays line
              count for line blocking, column count for column blocking.
  Hotkey:     <Ctrl Alt C>
  Author:     Dan Farmer
  Date:       July 28, 1995
*************************************************************************/
proc mCountBlocked()
    integer linecount, colcount = 0
    integer beg_line, end_line, beg_col, end_col, blocktype
    beg_line = Query(BlockBegLine)
    end_line = Query(BlockEndLine)
    beg_col  = Query(BlockBegCol)
    end_col  = Query(BlockEndCol)
    blocktype=isBlockInCurrFile()

    if( blocktype <> _NONE_)
        case blocktype
            when _LINE_
                linecount = abs(end_line - beg_line) + 1
                Message(Str(linecount) + " blocked lines ")
            when _COLUMN_
                colcount = abs(end_col - beg_col) + 1
                Message(Str(colcount) + " blocked columns")
        endcase
    endif
end mCountBlocked

proc Main()
    mCountBlocked()
end Main

<CtrlAlt C> mCountBlocked()
