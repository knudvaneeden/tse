/***************************************************************
 Program: undoline.s
 Author : Bruce Riggins
 Date   : 02/14/94
 Purpose: Undo the last line.  For TSE v.1.51a.

          Good for use with macros which change the line # in the
          background, since TSE is not presently sensing this condition.

          To use, compile with SC UNDOLINE, then load the macro.  I keep
          mine in the TSEINIT macro for automatic loading until line
          undo in TSE can do this itself.

          Currently, this is attached to <Ctrl Q><L>, but you can
          change this to be whatever you wish.

****************************************************************/

string UndoLine[255]
integer UndoLineNo = 0,
        UndoLineBufID = 0,
        ValidLine = FALSE,
        FChanged = TRUE

proc AfterCommand()
  if (CurrLine() <> UndoLineNo) or (GetBufferID() <> UndoLineBufID)
    if CurrLineLen() < 256
      UndoLine = GetText(1,CurrLineLen())
      ValidLine = TRUE
    else
      UndoLine = ""
      ValidLine = FALSE
    endif
    FChanged = FileChanged()
    UndoLineNo = CurrLine()
    UndoLineBufID = GetBUfferID()
  endif
end

proc UndoCursorLine()
  integer CurCol = CurrCol()

  if (CurrLine() == UndoLineNo) and
      (GetBufferID() == UndoLineBufID) and
      ValidLine
    BegLine()
    DelToEOL()
    InsertText(UndoLine,_OVERWRITE_)
    GotoColumn(CurCol)
    FileChanged(FChanged)
  endif
end

proc WhenLoaded()
  Hook(_AFTER_COMMAND_,AfterCommand)
end

<Ctrl Q><L>   UndoCursorLine()

