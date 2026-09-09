// Macro to remove blank comment lines (spaces from 2-72)
// Only works within a marked block.
proc main()
   integer count = 0
   pushposition()
   if   IsBlockInCurrFile() <> _LINE_
        message ('no line marked block')
        goto ender
   endif
   GotoBlockBegin()
// First remove completly blank lines
      if LFind("^$",'xgl')  == 0
         goto process_2
      endif
del_line:
      KillLine()
      count = count + 1
      GotoLine(CurrLine()-1)
      GotoColumn(1)
      if LRepeatFind() == 0
         goto process_2
      else
         goto del_line
      endif
process_2:
// Now delete all lines that are only the comment character in col 1.
      if LFind("^[Cc*]$","XGL") == 0
         goto process_3
      endif
del_line2:
      Delline()
      count = count + 1
      GotoLine(CurrLine()-1)
      GotoColumn(1)
      if LRepeatFind() == 0
         goto process_3
      else
         goto del_line2
      endif
Process_3:
// Now the tricky ones, with data in cols 73-80
       if LFind('^[Cc*]','xlg') == 0
          goto pre_ender
       endif
// Check for next non-space on the line
find_non_spaces:
       GotoColumn(2)
       if Lfind('[~ ]','cx') == 0
          goto try_again
       endif
       if CurrCol() >= 73
         Delline()
         count = count + 1
         GotoLine(CurrLine()-1)
         GotoColumn(1)
       endif
try_again:
       if LFind('^[Cc*]','xl') == 0
          goto pre_ender
       endif
       goto find_non_spaces
pre_ender:
       Message("Finished ", count," lines deleted")
ender:
    popposition()
end
