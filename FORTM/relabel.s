// Macro to re-number all labels in a BLOCK
proc main()
   integer xx,strt,incr,lcount,ss,lnum,cc,LL,qq,LLM
   string startV[5],Incrv[3],label[5]
   string Warning[1] = 'Y'
   string comc[1]
   integer cp,bb
   pushposition()
   startV = '1010'
   Incrv   = '5'
   gotoblockbegin()
   BB = CurrLine()
   if   IsBlockMarked() == 0
        message ('no marked block')
        goto ender
   endif
   XX = LFind('^[0-9]#','wxlg')
   if xx == 0
      message('no label found')
      goto ender
   endif
   LL = currLine()
   lcount = 1
// count number of labels
next_label:
//   Find if any more labels with same number
   label = gettext(1,5)
   lnum = val(label)
   LL = LL + 1
   if LL >  query(blockendline)
        goto allfound
   endif
   gotoline(LL)
   xx = Lfind('^'+ str(lnum), 'lxw')
   if xx == 0
   else
       message('Duplicate label ',label)
      LL = currLine()
      killposition()
      gotoline(LL)
      gotocolumn(1)
      return()
   endif
   gotoline(LL)
   XX = LFind('^[0-9]#','wxl')
    if xx == 0
       goto allfound
    else
      lcount = lcount + 1
      LL = currLine()
      goto next_label
    endif
allfound:
//  Ask for renumber sequence
    ASK ("Start Label Number? ",startV)
    strt = Val(startv)
    ASK ("Label Increment value will be? ",IncrV)
    incr = Val(incrv)
ask_again:
    Ask ('Warning Checks to be made (Y/N)?', Warning)
    if Warning == 'y' or Warning == 'Y'
      Warning = 'Y'
    elseif Warning == 'n' or Warning == 'N'
      Warning = 'N'
    else
      goto ask_again
    endif
//  Get all labels again to check if label conflict
   XX = LFind('^[0-9]#','wxlg')
chk_label:
   label = gettext(1,5)
   lnum = val(label)
   if lnum == 0
      message ("Invalid label ",label)
      LL = currLine()
      killposition()
      gotoline(LL)
      gotocolumn(1)
      return()
   endif
   ss = strt
   cc = 1
lpstrt:
   if  ss == lnum
       message("Renumbering conflict with existing label ",label)
      LL = currLine()
      killposition()
      gotoline(LL)
      gotocolumn(1)
      return()
   endif
   if cc == lcount
      goto lpend
   endif
   ss = ss + incr
   cc = cc + 1
   goto lpstrt
lpend:
//  Save current position and look at places where changes will be made
//  to see if value might be a value instead of a label (check for value
//  being Right-Hand side of an = sign.
      if Warning == 'Y'
         PushPosition()
         qq = LFind(str(lnum),'wlg')
         goto warn2
find_next_warn:
          qq = LFind(str(lnum),'wl+')
warn2:
         if qq == 0
            goto end_warn
         endif
//            Current column position - check if a label
         cp = currcol()
         if cp < 7
            goto find_next_warn
          endif
//            Check if a comment
          comc = GetText(1,1)
          if comc == 'C' or comc == 'c' or comc == '*'
            goto find_next_warn
          endif
          PushPosition()
          LL = CurrLine()
          LLM = LL
//          Check for '=' on current line, before label number
try_equal:
          qq = LFind('=','bc')
          if qq == 1
            PopPosition()
            KillPosition()
            KillPosition()
            Message('Warning- possibly not a label at line ',LL)
            Return()
          else
//            Test if a continuation line
             comc = GetText(6,1)
             if comc == '0' or comc == ' '
               PopPosition()
               goto find_next_warn
             else
Prev_line:
               LLM = LLM - 1
               if LLM < bb
                  PopPosition()
                  goto find_next_warn
               endif
               GotoLine(LLM)
//               Skip over Comment lines.
               comc = GetText(1,1)
               if comc == 'C' or comc == 'c' or comc == '*'
                  goto Prev_line
               endif
               GotoColumn(72)
               goto try_equal
             endif
          endif
end_warn:
         PopPosition()
      endif
//   Find next label
    XX = LFind('^[0-9]#','wxl+')
    if xx == 0
       goto no_conflicts
    else
       goto chk_label
    endif
//   Now replace Label values!
no_conflicts:
   ss = strt
   XX = LFind('^[0-9]#','wxlg')
new_label:
   LL = currLine()
   label = gettext(1,5)
   lnum = val(label)
//   Replace label in whole block
    Lreplace(str(lnum),str(ss), 'lgnw')
//    Get Next Label
      LL = LL + 1
      if LL >  query(blockendline)
          goto ender
      endif
      gotoline(LL)
      gotocolumn(1)
      XX = LFind('^[0-9]#','wxl')
      if xx == 0
         goto ender
      else
         ss = ss + incr
         goto new_label
      endif
ender:
    popposition()
end
