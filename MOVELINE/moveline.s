/****************************************************************************
  Moveline procedure
 ***************************************************************************/

/* Package version 1.0.0.0.0 - updated 2026-09-22 */

string GSProgramName[20] = "MOVELINE"
string GSVersion[20]     = "1.0.0.0.0"

string proc FNIniFilename()
    return(SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_) + "moveline.ini")
end

integer proc FNIsSilent()
    string valueS[20] = GetProfileStr("moveline", "silent", "false", FNIniFilename())
    return(EquiStr(valueS, "true"))
end

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

proc Main()
    if not FNIsSilent()
        Warn(GSProgramName, " ", GSVersion, " is loaded.  Use Ctrl+CursorUp/Down to move the current line, or Ctrl+Shift+CursorUp/Down to move a marked line block.  Set silent=true in moveline.ini to hide this message.")
    endif
end
