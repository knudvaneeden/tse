// Macro to left justify labels in a marked block
proc main()
   integer found = 0,i,j
   string    first5[5] = ' ',ch[1]
   pushposition()
   if   IsBlockInCurrFile() <> _LINE_
        message ('no line marked block')
        goto ender2
   endif
    gotoblockbegin()
   if LFind('^[~Cc*]','xgl') == 0
      goto ender
   endif
   goto check_label
//    check for a label
try_again:
   if LRepeatFind() == 0
      goto ender
   endif
check_label:
      if GetText(1,5) == '     '
         goto try_again
      endif
//    check if a number
      j = 1
      first5 = '     '
      for i = 1 to 5
         ch = GetText(i,1)
         if ch == ' '
            goto end_loop
         endif
         if ch >= '0' or ch <= '9'
         else
            Message('None valid Label')
            KillPosition()
            GotoLine(CurrLine())
            return()
         endif
         first5[j:1] = ch
         j = j + 1
end_loop:
      endfor
      InsertText(first5,_OVERWRITE_)
      found = found + 1
      goto try_again
ender:
    Message('Number of label processed = ',found)
ender2:
    popposition()
    return()
end
