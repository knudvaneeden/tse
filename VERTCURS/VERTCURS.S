/****************************************************************************
  Vertical Cursor procedure
 ***************************************************************************/

/************************************************************************
  Author:  Sjoerd W. Rienstra (Netherlands)  (email: sjoerdr@win.tue.nl)
  Date:    August 21, 1995

  Description:

  A small macro to create temporarily a vertical cursor for
  (for example) the lining-up of do,for,etc.-loops.

  To be included in the standard user interface tse.ui .
  The selected colors may be adapted by the user.

  The implementation as a macro is a bit clumsy.
  Better is of course via low-level commands,
  preferably as a part of the tse-core.
  Who is willing and able ...?

  Suggested keys:
        <CtrlAlt GreyCursorRight> VertCurs(1)
        <CtrlAlt GreyCursorUp>    VertCurs(2)
        <CtrlAlt GreyCursorLeft>  VertCurs(3)
        <CtrlAlt GreyCursorDown>  VertCurs(4)
 ************************************************************************/

proc VertCurs(integer n)
     integer BlkAttr = Set(BlockAttr, 62),
             CbkAttr = Set(CursorInBlockAttr, 15)
     Case n
        When 1
             Right()
        When 2
             Up()
        When 3
             Left()
        When 4
             Down()
     EndCase
     PushBlock()
     PushPosition()
     UnMarkBlock()
     GotoLine(1)
     MarkColumn()
     GotoLine(Numlines())
     MarkColumn()
     PopPosition()
     UpdateDisplay()
     repeat until KeyPressed()
     Set(BlockAttr, BlkAttr)
     Set(CursorInBlockAttr, CbkAttr)
     PopBlock()
end

<CtrlAlt GreyCursorRight> VertCurs(1)
<CtrlAlt GreyCursorUp>    VertCurs(2)
<CtrlAlt GreyCursorLeft>  VertCurs(3)
<CtrlAlt GreyCursorDown>  VertCurs(4)
