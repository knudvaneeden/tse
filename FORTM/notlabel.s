// Macro to find which labels are not used in a Block.
proc main()
   integer xx,ll,lnum,cx
   string label[5]
   pushposition()
   gotoblockbegin()
   if IsBlockMarked() == 0
        message ('no marked block')
        goto ender
   endif
    gotoblockbegin()
   XX = LFind('^[0-9]#','wxlg')
   if xx == 0
      message('no label found')
      goto ender
   endif
new_label:
   ll = currLine()
   label = gettext(1,5)
   lnum = val(label)
   if lnum == 0
      message ("Invalid label ",label)
      killposition()
      gotoline(ll)
      gotocolumn(1)
      return()
   endif
//  Try and find label in whole block
    xx = Lfind(str(lnum),'lgw')
chk:
    if  xx == 0
        message ("Label not used ",label)
        killposition()
        gotoline(ll)
        gotocolumn(1)
        return()
    endif
//  Check co-ordinates
    cx = Currcol()
    if cx < 7  or cx > 72
//     try again
       xx = lrepeatfind(_FORWARD_)
       goto chk
    else
//    Label found- look for next label
      ll = ll + 1
      if ll >  query(blockendline)
          goto ender
      endif
      gotoline(ll)
      gotocolumn(1)
      XX = LFind('^[0-9]#','wxl')
      if xx == 0
         goto ender
      endif
      goto new_label
    endif
ender:
    Message ("All labels in use")
    popposition()
end
