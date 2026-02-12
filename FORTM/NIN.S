//Macro to put all "in-line" comments, on a seperate line.
// "in-line" comments are started after code on the same line, they
// start with "@" character.
proc main()
// check if a marked block
      string REP[1], abrep[1],comment_string[72],cc[1]
      integer all_flag = 0, abovel,xx,strt,leng,done_count = 0
     PushPosition()
    if isBlockInCurrFile() == _LINE_
    else
      message ('no marked line block')
      goto ender
    endif
repeatq:
      ABREP = "A"
    ask ("Place comments above or below line? <A/B>",ABREP)
    if ABREP == "A" or ABREP == "a"
      abovel = 1
    elseif ABREP == "B" or ABREP == "b"
      abovel = 0
    else
      goto repeatq
    endif
    gotoblockbegin()
    if Find('@','lg')
// check position is < 72
new_find:
      if Currpos() >= 72
         goto try_again
      endif
// check if already a comment
      cc = GetText(1,1)
      if cc == 'C' or cc == 'c' or cc == '*'
         goto try_again
      endif
      if all_flag == 1
         goto convert
      endif
ask_again:
      REP = "Y"
      ASK ("Convert this comment? <Yes/No/All/Quit> ",REP)
      if REP == 'Y' or REP == 'y'
convert:
         xx = Currpos()
         strt = xx + 1
         leng = 72 - strt + 1
         comment_string = GetText(strt,leng)
//   remove old comment.
         DelToEol()
         if abovel == 1
            InsertLine('C')
         else
            AddLine('C')
         endif
         InsertText(comment_string)
         done_count = done_count + 1
try_again:
// look for next in-line
      if RepeatFind()
         goto  new_find
      else
         message('Finished ',done_count,' in_line comments converted')
         goto ender
      endif
      elseif REP == 'N' or REP == 'n'
          goto try_again
      elseif REP == 'A' or REP == 'a'
          all_flag = 1
          goto convert
      elseif REP == 'Q' or REP == 'q'
        goto ender
      else
        goto ask_again
      endif
    else
      message ('no in-line comment found')
      goto ender
    endif
ender:
      popPosition()
end
