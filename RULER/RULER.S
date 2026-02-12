/******************************************************************************

	Ruler		Movable ruler for TSE 2.0

	Author:	Glenn Alcott (CIS 76044,747)

	Date:		October 1, 1994

	Overview:

	This macro provides a movable ruler on the screen which makes it easy to
  count spaces.  When the macro is executed, the ruler is displayed with its
  upper left corner at the current cursor position.  It may be moved one row
  or column at a time by using	the Cursor Up, Cursor Down, Cursor Left and
  Cursor Right keys.	The	Home key will move it to the first column.  Page Up
  and Page Down will move it to the top and bottom of the screen. Pressing
  any other key terminates the ruler display.

	Please send any comments or suggestions to the author by CIS E-mail.

*******************************************************************************/

integer RulerTop, RulerLeft

proc DisplayRuler()

/* The Window command is used instead of PopWinOpen so there will not be a
	 border around the ruler. */
	Window(RulerLeft,RulerTop,Query(ScreenCols),RulerTop+3)
 	WriteLine("ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³ù³")
 	WriteLine(" 2 4 6 8 ³ 2 4 6 8 ³ 2 4 6 8 ³ 2 4 6 8 ³ 2 4 6 8 ³ 2 4 6 8 ³ 2 4 6 8 ³ 2 4 6 8 ³")
	WriteLine("        10        20        30        40        50        60        70         ³")
end


proc MoveRuler()
 	FullWindow()
 	UpdateDisplay(_ALL_WINDOWS_REFRESH_)
 	DisplayRuler()
end


proc Main()
	integer CursorState

	CursorState = Query(Cursor)
	Set(Cursor,OFF)
	Set(Attr, Query(MsgAttr))
	RulerTop = WhereY()
	RulerLeft = WhereX()
	DisplayRuler()
	loop
		case GetKey()
		  when <CursorDown>
		  	RulerTop=iif(RulerTop>Query(ScreenRows)-3,RulerTop,RulerTop+1)
		  	MoveRuler()
		  when <CursorUp>
		  	RulerTop=iif(RulerTop==1,1,RulerTop-1)
		  	MoveRuler()
		  when <CursorLeft>
		  	RulerLeft=iif(RulerLeft==1,1,RulerLeft-1)
		  	MoveRuler()
		  when <CursorRight>
		  	RulerLeft=iif(RulerLeft==Query(ScreenCols)-1,RulerLeft,RulerLeft+1)
		  	MoveRuler()
		  when <Home>
		  	RulerLeft=1
		  	MoveRuler()
		  when <PgUp>
		  	RulerTop=1
		  	MoveRuler()
		  when <PgDn>
		  	RulerTop=Query(ScreenRows)-2
		  	MoveRuler()
			otherwise
				FullWindow()
		  	UpdateDisplay(_ALL_WINDOWS_REFRESH_)
		  	break
			endcase
	endloop
	Set(Cursor,CursorState)
end

