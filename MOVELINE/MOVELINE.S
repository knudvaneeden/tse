/****************************************************************************
  Moveline procedure
 ***************************************************************************/

/************************************************************************
  Author:  Sjoerd W. Rienstra (Netherlands)  (email: sjoerdr@win.tue.nl)
  Date:    June 13, 1995

  Description:

  A handy macro to move:
  -  a line down (0) or up (1)
  -  a line-block down (2) or up (3).

  To be included in the standard user interface tse.ui .

  Keys:
        <Ctrl CursorDown>       mMoveLine(0)
        <Ctrl CursorUp>         mMoveLine(1)
        <CtrlShift CursorDown>  mMoveLine(2)
        <CtrlShift CursorUp>    mMoveLine(3)
 ************************************************************************/

proc mMoveLine(integer n)
    integer ba = Set(InsertLineBlocksAbove,n mod 2)

    if n==2
       if (isCursorInBlock()==_LINE_) and (Numlines()>Query(BlockEndLine))
        GotoBlockBegin()
        MoveBlock()
        Down()
        if (Query(BlockEndLine)>CurrLine()+Query(WindowRows)-CurrRow())
         ScrollDown()
        endif
       endif
    elseif n==3
       if isCursorInBlock()==_LINE_
        GotoBlockBegin()
        Up()
        MoveBlock()
       endif
    else
    PushBlock()
    UnmarkBlock()
    MarkLine()
    MarkLine()
    If n == 0
       MoveBlock()
       Down()
    Else
       Up()
       MoveBlock()
    Endif
    PopBlock()
    endif
    Set(InsertLineBlocksAbove,ba)
end

<Ctrl CursorDown>       mMoveLine(0)
<Ctrl CursorUp>         mMoveLine(1)
<CtrlShift CursorDown>  mMoveLine(2)
<CtrlShift CursorUp>    mMoveLine(3)
