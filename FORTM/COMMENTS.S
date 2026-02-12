// ** Macro to change all comments in a block to lower case (except
//  1st.letter.
proc main()
   string jock[71] = 'TEST' , ff[1], JANICE[71]
   integer   endlinex,lll
   PushPosition()
   gotoblockbegin()
   if isBlockMarked()  == 0
      message ('no marked block')
      goto ender
   endif
    endlinex = query(blockendline)
    lll = currline()
loop1:
     gotoline(lll)
     FF = GETTEXT(1,1)
     if ff == 'C' OR FF == '*' or ff == 'c'
        jock = gettext(2,71)
        JANICE = lower(jock)
        gotocolumn(2)
        inserttext(JANICE,_OVERWRITE_)
     endif
     lll = lll + 1
     if lll > endlinex
        goto ender
     endif
     goto loop1
ender:
      Message("Finished")
     PopPosition()
end
