// 11/04/93 - John Wright
// This is a simple function to count the rows & columns in a block.
// It has proved very helpful for me when programming.

proc BlockCount()
   integer i, x
   i = IsBlockInCurrFile()
   if i == 0
      Warn("A block must be marked in current file!")
   else
      x = ( Query( BlockEndLine ) - Query( BlockBegLine ) ) + 1
      if i == _COLUMN_
         i = ( Query( BlockEndCol ) - Query( BlockBegCol ) ) + 1
         Message( " " + Str(i) + " columns and " + Str(x) + " lines in block" )
      else
         Message( " " + Str(x) + " lines in block" )
      endif
   endif
end BlockCount