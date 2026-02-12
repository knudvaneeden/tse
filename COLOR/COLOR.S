proc main()
// 10/13/93  Display a color chart - by John Wright
   integer i, x, xx
   PushPosition()
   PopWinOpen( 7, 3, 73, 20, 2, "Color Attributes", 15 )
   vHomeCursor()
   ClrScr()
   x = 0
   while x < 16
      xx = 0
      while xx < 16
         VGotoXY( (xx*4)+1, x+1 )
         if x < 8
            i = (x*16)+xx
            Write( " "+format(i:3:'0') )
         else
            i = ((x-8)*16)+xx
            Write( "  "+format(str(i,16):2:'0') )
         endif
         VGotoXY( (xx*4)+1, x+1 )
         PutAttr( i, 5 )
         xx = xx + 1
      endwhile
      x = x + 1
   endwhile
   Toggle( Cursor )
   x = Getkey()
   Toggle( Cursor )
   PopWinClose()
   PopPosition()
end main
