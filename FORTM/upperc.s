// Macro to set all code lines to upper-case characters (except text
// strings)
proc main()
       string sss[1] = ' '
       string ff[1]
       string gg[1]
       integer strl
       integer endl
       integer curl
       integer ij
       integer flag
// is there a line block?
       strl = 1
       endl = NumLines()
       if IsBlockInCurrFile() == _LINE_
           strl = Query(BlockBegLine)
           endl = Query(BlockEndLine)
       else
          ask("no line block-use whole file? Y/N",sss)
          if sss == 'Y' or sss == 'y'
          else
            return()
          endif
       endif
       pushposition()
       flag = 0
       for curl = strl  to endl
          GotoLine(curl)
          ff = gettext(1,1)
          if ff == 'C' OR FF == '*' or ff == 'c'
              if ff == 'c'
                gotoColumn(1)
                InsertText('C',_OVERWRITE_)
              endif
              goto next_one
          else
            for ij = 1 to CurrLineLen()
              ff = gettext(ij,1)
              if ff == "'"
                 if flag == 0
                    flag = 1
                 else
                    flag = 0
                 endif
              else
                 if flag == 0
                   gg = upper(ff)
                   if gg <> ff
                     GotoColumn(ij)
                     InsertText(gg,_OVERWRITE_)
                   endif
                 endif
              endif
            endfor
          endif
next_one:
      endfor
      popposition()
      message("Finished")
end


