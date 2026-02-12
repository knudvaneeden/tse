// Macro to find if any subroutines or functions are unused
proc main()
//   save start position
      integer fpos
      string wcs[6], cc[1]
      PushPosition()
// start at the top
      GotoLine(1)
next_one:
      if lFind ("^[~Cc*]+SUBROUTINE",'x')
      else
//              none found - look for functions
         goto try_functions
      endif
      GotoColumn(1)
//       find "subroutine" again
      lFind("SUBROUTINE",'w')
//       find the s/r name
      WordRight()
      wcs = GetWord()
//       keep position
      fpos = CurrLine()
      PushPosition()
      GotoLine(1)
      if lFind(wcs,'w')
//        is it define line? or a comment ?
check_again:
         cc = GetText(1,1)
         if CurrLine() == fpos  or cc == 'C' or cc == 'c' or cc == '*'
            if lRepeatFind()
                goto check_again
            else
               goto not_found
            endif
         else
             goto found_it
         endif
      else
//        not found ?
not_found:
//        tell what happened
         PopPosition()
         Find ('.','x')
         Warn('Subroutine ',wcs, ' not called')
     endif
     goto found_it2
found_it:
      PopPosition()
found_it2:
//   look for next
      goto next_one
try_functions:
      gotoLine(1)
try_once_more:
      if lfind('FUNCTION','w')
//           check it isn't a comment
        cc = GetText(1,1)
        if cc == 'C' or cc == 'c' or cc == '*'
//            move curser on a character.
           gotoColumn(CurrCol() + 1)
           goto try_once_more
        endif
//            find the s/r name
        WordRight()
        wcs = GetWord()
//             keep position
        fpos = CurrLine()
        PushPosition()
        GotoLine(1)
        if lFind(wcs,'w')
//              is it define line? or a comment ?
check_again2:
            cc = GetText(1,1)
            if CurrLine() == fpos  or cc == 'C' or cc == 'c' or cc == '*'
                if lRepeatFind()
                   goto check_again2
                else
                   goto not_found2
                endif
            else
               goto found_it33
            endif
        endif
//                 not found ?
not_found2:
//             tell what happened
        PopPosition()
        Find ('.','x')
        Warn('Function ',wcs, ' not called')
        goto found_it23
found_it33:
        PopPosition()
found_it23:
//          look for next
        goto try_once_more
      endif
      PopPosition()
end
