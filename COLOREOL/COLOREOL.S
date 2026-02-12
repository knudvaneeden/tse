
/*
coloreol.s

        October 31, 1996        bar

        B. Alex Robinson
        Tranzoa, Co.
        P.O. Box 911
        Maple Valley, WA  98038
        http://ourworld.compuserve.com/homepages/ARobinson/tranzoa.htm
        71535.1673@compuserve.com

        Change the color of the far-right character of each line of text that
          extends beyond the right edge of the on-screen window.

        This is a long comment line to check our operation and interaction with the COLORS macro.

*/

integer ccolor

proc do_color_eol()

  /***      The next two lines have words out to the right for testing.    ***/
  integer   x, y, vx, vy, r, west, east,                                     width
  integer                                                                     cc
  integer   ln, pl

  /***  Save the state                                                     ***/
  x = CurrCol()
  y = CurrRow()
  vx = WhereX()
  vy = WhereY()

  width = Query(WindowCols)
  west = CurrXOffset()
  east = west + width
  r = 1
  pl = 0
  while (r <= Query(WindowRows))
    GotoRow(r)
    GotoColumn(east + 2)
    cc = CurrChar()
    ln = CurrLine()
    GotoColumn(x)
    GotoXoffset(west)
    if (ln <= pl)
      break
      endif
    pl = ln
    if (cc <> _BEYOND_EOL_)
      VGotoXY(Query(WindowX1) + width - 1, r + Query(WindowY1) - 1)
      PutAttr(ccolor, 1)            /* this is what does the trick           */
      endif
    r = r + 1
    endwhile

  /***  Restore the state                                                  ***/
  VGotoXY(vx, vy)
  GotoRow(y)
  GotoColumn(x)

end  do_color_eol



/*

    If we are hooked on _AFTER_UPDATE_DISPLAY_, then the COLORS.S macro
      overrides our logic.

*/
proc WhenLoaded()
  ccolor = Query(EOFMarkerAttr)     /* pick your favorite color here!        */

  Hook(_IDLE_, do_color_eol)
  do_color_eol()
end  WhenLoaded


proc WhenPurged()
  UnHook(do_color_eol)
end  WhenPurged



/* eof                                                              			*/
