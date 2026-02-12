/*************************************************************************
  WhtSpc      Displays whitespace, bookmarks, and more.

  Author:     Chris Antos

  Date:       06/17/97

  Overview:

  WHTSPC adds a few handy visual elements, such as whitespace, bookmarks,
  a cursorline indicator, and a right margin indicator.  Each of these can
  be toggled on/off from a handy menu.


  Keys:       (none)


  Usage notes:

  Execute this macro to show a configuration menu where you can change the
  settings.

  NOTE:  THIS MACRO ONLY WORKS ON TSE 2.6 AND HIGHER!!


  Copyright (none) - FreeWare.

*************************************************************************/

// WHTSPC.S -----------------------------------------------------------------
// by Chris Antos
//
// Various enhancements to the TSE display, including displaying whitespaces
// on the cursorline.
//
// Execute the macro to display the options menu.



string c_stSection[] = "WHTSPC"
string c_stBookmarks[] = "Bookmarks"
string c_stBookmarkChr[] = "BookmarkChr"
string c_stBookmarkAttr[] = "BookmarkAttr"
string c_stBookmarkAttrTransparent[] = "BookmarkAttrTransparent"
string c_stSidechar[] = "CursorLine"
string c_stSidecharChr[] = "CursorLineChr"
string c_stSidecharAttr[] = "CursorLineAttr"
string c_stSidecharAttrTransparent[] = "CursorLineAttrTransparent"
string c_stMargin[] = "Margin"
string c_stWhitespace[] = "Whitespace"
string c_stSpaceChr[] = "WhitespaceSpaceChr"
string c_stTabChr[] = "WhitespaceTabChr"

integer g_fBookmarks
integer g_chBookmark
integer g_attrBookmark
integer g_fBookmarkTransparent
integer g_fSidechar
integer g_chSidechar
integer g_attrSidechar
integer g_fSidecharTransparent
integer g_fMargin
integer g_fWhitespace
integer g_chSpace
integer g_chTab

integer g_fChanged


#define COLOR_WIDTH 2
integer proc PickColor(var integer attr)
	string s[16*COLOR_WIDTH]
	string a[16*COLOR_WIDTH]
	integer i, j
	integer n = attr
	integer ch
	integer fRet = FALSE

	i = WhereXAbs()
	j = WhereYAbs()+1
	if i+(16*COLOR_WIDTH+2-1) > Query(ScreenCols)
		i = Query(ScreenCols)-(16*COLOR_WIDTH+2-1)
	endif
	if j+(18-1) > Query(ScreenRows)
		j = Query(ScreenRows)-(18-1)
	endif

	PopWinOpen(i, j, i+(16*COLOR_WIDTH+2-1), j+(18-1), 1, "Select Color",
			Query(CurrWinBorderAttr))

	for i = 0 to 255 by 16
		s = ""
		a = ""
		for j = 0 to 15
			s = s + Format(i+j:COLOR_WIDTH:"0":16)
			a = a + Format("":COLOR_WIDTH:Chr(i+j))
		endfor
		PutStrAttrXY(1, i/16+1, s, a)
	endfor

	i = (n mod 16)
	j = n/16

	loop
		// position cursor
		GotoXY((i+1)*COLOR_WIDTH, j+1)

		// process keys
		ch = GetKey()
		case ch
			when <Enter>
				// ok
				attr = j*16 + i
				fRet = TRUE
				break
			when <Escape>
				// cancel
				break
			when <CursorUp>, <GreyCursorUp>
				if j > 0
					j = j - 1
				else
					j = 15
				endif
			when <CursorDown>, <GreyCursorDown>
				if j < 15
					j = j + 1
				else
					j = 0
				endif
			when <CursorLeft>, <GreyCursorLeft>
				if i > 0
					i = i - 1
				else
					i = 15
				endif
			when <CursorRight>, <GreyCursorRight>
				if i < 15
					i = i + 1
				else
					i = 0
				endif
			when <Home>, <GreyHome>
				i = 0
				j = 0
			when <End>, <GreyEnd>
				i = 15
				j = 15
			when <Ctrl Home>, <Ctrl GreyHome>
			when <Ctrl End>, <Ctrl GreyEnd>
			when <PgUp>, <GreyPgUp>
			when <PgDn>, <GreyPgDn>
			when <Ctrl PgUp>, <Ctrl GreyPgUp>
			when <Ctrl PgDn>, <Ctrl GreyPgDn>
		endcase
	endloop

	PopWinClose()
	return (fRet)
end


proc DrawBookmarks(integer attrBorder)
	integer i, id, ln, lpos, xofs, row
	integer nTop, nBottom
	integer cid = GetBufferId()
	//integer attr

	if g_fBookmarks
		nTop = CurrLine() - CurrRow() + 1
		nBottom = nTop + Query(WindowRows)
		if g_fBookmarkTransparent
			Set(Attr, (g_attrBookmark & 0x0f) | (attrBorder & 0xf0))
		else
			Set(Attr, g_attrBookmark)
		endif

		if Query(DisplayBoxed) == 2 or
				(Query(DisplayBoxed) == 1 and Query(MouseEnabled))
			// draw bookmark indicators
			for i = Asc('A') to Asc('Z')
				if isBookMarkSet(Chr(i)) and
						GetBookMarkInfo(Chr(i), id, ln, lpos, xofs, row) and
						id == cid and ln >= nTop and
						ln < nBottom
					VGotoXYAbs(Query(WindowX1)-1, Query(WindowY1)+ln-nTop)
					PutChar(Chr(g_chBookmark))
				endif
			endfor
		endif

		//Set(Attr, attr)
	endif
end


proc DrawSidechar(integer x, integer y, integer attrBorder)
	if g_fSidechar
		VGotoXYAbs(x, y)
		if g_fSidecharTransparent
			PutStr(Chr(g_chSidechar), (g_attrSidechar & 0x0f) | (attrBorder & 0xf0))
		else
			PutStr(Chr(g_chSidechar), g_attrSidechar)
		endif
	endif
end


proc DrawLeftBorder()
	string s[1]	= ""
	string a[1]	= ""
	integer x = Query(WindowX1)-1
	integer y = Query(WindowY1)
	integer rows = Query(WindowRows)
	integer fFound = FALSE
	integer i

	if Query(DisplayBoxed) == 2 or
			(Query(DisplayBoxed) == 1 and Query(MouseEnabled))
		// look for border type and attr
		Window(1, 1, Query(ScreenCols), Query(ScreenRows))
		for i = 0 to rows-1
			VGotoXYAbs(x, y+i)
			GetStrAttr(s, a, 1)
			if Asc(s) in 179/*³*/, 186/*º*/, 219/*Û*/, 222/*Þ*/
				fFound = TRUE
				break
			endif
		endfor

		// if found border type and attr, draw stuff on the border
		if fFound
			// redraw the left edge, to erase old sidechar/bookmarks
			Set(Attr, Asc(a))
			VGotoXYAbs(x, y)
			PutCharV(s, rows)

			// draw sidechar
			DrawSidechar(x, y + CurrRow() - 1, Asc(a))

			// draw bookmarks
			DrawBookmarks(Asc(a))
		endif
		FullWindow()
	endif
end


// DrawWhitespace()
// this is more complex than it would seem.
integer g_idWindows = 0
proc DrawWhitespace(integer fDraw)
	string s[255] = ""
	string a[255] = ""
	integer xofs = CurrXoffset()
	integer topln, row, cid
	integer i
	string st[32]

	if not g_fWhitespace or
			CurrLine() > NumLines() or
			DisplayMode() <> _DISPLAY_TEXT_
		return()
	endif

	// get string from screen
	GetStrAttrXY(Query(WindowX1), Query(WindowY1)+CurrRow()-1, s, a, Query(WindowCols))
	PushPosition()

	// fix trailing whitespace
	EndLine()
	if CurrCol()-xofs <= Query(WindowCols)
		s = SubStr(s, 1, CurrCol()-xofs-1)
		s = Format(s:-Query(WindowCols):" ")
	endif

	// draw whitespace characters
	GotoColumn(xofs+1)
	repeat
		i = CurrCol()-xofs
		case CurrChar()
			when 32
				s[i] = iif(fDraw, Chr(g_chSpace), " ")
			when 9
				i = i + DistanceToTab(TRUE) - 1
				if i <= Query(WindowCols)
					s[i] = iif(fDraw, Chr(g_chTab), " ")
				endif
		endcase
		Right()
	until CurrChar() < 0 or i >= Query(WindowCols)

	// put string to screen
	PopPosition()
	PutStrAttrXY(Query(WindowX1), Query(WindowY1)+CurrRow()-1, s, a)

	// update previous line if CursorAttr == TextAttr
	if fDraw and Query(CursorAttr) == Query(TextAttr)
		// get current info
		row = CurrRow()
		topln = CurrLine() - CurrRow() + 1
		cid = GetBufferId()

		// goto/create window info buffer
		if g_idWindows
			GotoBufferId(g_idWindows)
		else
			g_idWindows = CreateTempBuffer()
			do 32 times			// actual max is 9, allow for growth
				AddLine()
			enddo
		endif

		// check if need to force redraw
		GotoLine(WindowId())
		st = GetText(1, CurrLineLen())
		if row <> Val(GetToken(st, " ", 1)) and
				topln == Val(GetToken(st, " ", 2)) and
				xofs == Val(GetToken(st, " ", 3)) and
				cid == Val(GetToken(st, " ", 4))
			GotoBufferId(cid)
			PushPosition()
			GotoRow(Val(GetToken(st, " ", 1)))
			DrawWhitespace(FALSE)
			PopPosition()
		endif

		// record current window info
		GotoBufferId(g_idWindows)
		BegLine()
		KillToEol()
		InsertText(Format(row; topln; xofs; cid))
		GotoBufferId(cid)
	endif
end


proc DrawMargin()
	integer x = Query(RightMargin)-CurrXoffset()
	integer y
	string s[1] = ""
	string a[1] = ""

	if g_fMargin and Length(CurrExt()) and
			Pos(CurrExt()+".", ".c.h.cpp.hpp.cxx.hxx.rc.rc2.idl.odl.s.si.ui.inc.asm.bat.btm.txt.")
		if x >= 1 and x <= Query(WindowCols)
			for y = 1 to Query(WindowRows)
				VGotoXY(Query(WindowX1)+x, Query(WindowY1)+y-1)
				GetStrAttr(s, a, 1)
				if Asc(s) == 32
					PutStr("³", iif(Asc(a) & 0xf0, Asc(a) & 0xf0, 0x07))
				endif
			endfor
		endif
	endif
end


proc AfterUpdateDisplay()
	if BufferType() == _NORMAL_
		DrawLeftBorder()
		DrawWhitespace(TRUE)
		DrawMargin()
	endif
end


proc GetSettings()
	g_fBookmarks = GetProfileInt(c_stSection, c_stBookmarks, TRUE)
	g_chBookmark = GetProfileInt(c_stSection, c_stBookmarkChr, 254)
	g_attrBookmark = GetProfileInt(c_stSection, c_stBookmarkAttr, Color(blink blue on white))
	g_fBookmarkTransparent = GetProfileInt(c_stSection, c_stBookmarkAttrTransparent, FALSE)

	g_fMargin = GetProfileInt(c_stSection, c_stMargin, TRUE)

	g_fWhitespace = GetProfileInt(c_stSection, c_stWhitespace, TRUE)
	g_chSpace = GetProfileInt(c_stSection, c_stSpaceChr, 250)
	g_chTab = GetProfileInt(c_stSection, c_stTabChr, 170)

	g_fSidechar = GetProfileInt(c_stSection, c_stSidechar, TRUE)
	g_chSidechar = GetProfileInt(c_stSection, c_stSidecharChr, 16)
	g_attrSidechar = GetProfileInt(c_stSection, c_stSidecharAttr, Color(bright red on black))
	g_fSidecharTransparent = GetProfileInt(c_stSection, c_stSidecharAttrTransparent, TRUE)
end


proc WriteSettings()
	WriteProfileInt(c_stSection, c_stBookmarks, g_fBookmarks)
	WriteProfileInt(c_stSection, c_stBookmarkChr, g_chBookmark)
	WriteProfileInt(c_stSection, c_stBookmarkAttr, g_attrBookmark)
	WriteProfileInt(c_stSection, c_stBookmarkAttrTransparent, g_fBookmarkTransparent)

	WriteProfileInt(c_stSection, c_stMargin, g_fMargin)

	WriteProfileInt(c_stSection, c_stWhitespace, g_fWhitespace)
	WriteProfileInt(c_stSection, c_stSpaceChr, g_chSpace)
	WriteProfileInt(c_stSection, c_stTabChr, g_chTab)

	WriteProfileInt(c_stSection, c_stSidechar, g_fSidechar)
	WriteProfileInt(c_stSection, c_stSidecharChr, g_chSidechar)
	WriteProfileInt(c_stSection, c_stSidecharAttr, g_attrSidechar)
	WriteProfileInt(c_stSection, c_stSidecharAttrTransparent, g_fSidecharTransparent)
end


string proc OnOffStr(integer f)
	return(iif(f, "On", "Off"))
end


proc ToggleVar(var integer f)
	f = not f
	g_fChanged = TRUE
end


#if 0
proc ReadChr(var integer ch)
	string st[5] = Str(ch)

	if ReadNumeric(st) and Val(st) in 0..255
		ch = Val(st)
		g_fChanged = TRUE
	endif
end
#endif


proc GetColor(var integer n)
	if PickColor(n)
		g_fChanged = TRUE
	endif
end


// mAsciiChart
// display ASCII chart and returns selected character; <Esc> to abort.
proc GetAscii(var integer ch)
	integer i
	integer cid
	integer chartid

	cid = GetBufferId()
	chartid = CreateTempBuffer()

	if chartid
		i = 0
		while AddLine(Format(i:5, Str(i, 16):4, Chr(i):4)) and i < 255
			i = i + 1
		endwhile
		GotoLine(ch + 1)
		ScrollToCenter()
		if List("DEC HEX Char", 20)
			ch = CurrLine() - 1
			g_fChanged = TRUE
		endif
	endif

	GotoBufferId(cid)
	AbandonFile(chartid)
end


menu Options()
	title = "WHTSPC Options"
	history

	#if 0
	"&Whitespace" [OnOffStr(g_fWhitespace):3], ToggleVar(g_fWhitespace), DontClose, "Show whitespace on cursor line."
	"  Space character" [Chr(g_chSpace):1], GetAscii(g_chSpace), DontClose
	"  Tab character" [Chr(g_chTab):1], GetAscii(g_chTab), DontClose
	"&Bookmarks" [OnOffStr(g_fBookmarks):3], ToggleVar(g_fBookmarks), DontClose, "Display a marker for bookmarked lines, on the left window border."
	"  Marker character" [Chr(g_chBookmark):1], GetAscii(g_chBookmark), DontClose
	//"  Marker attribute" [g_attrBookmark:3], GetColor(g_attrBookmark), DontClose
	"  Marker attribute...", GetColor(g_attrBookmark), DontClose
	"  Transparent attribute" [OnOffStr(g_fBookmarkTransparent):3], ToggleVar(g_fBookmarkTransparent), DontClose
	"&Cursor Line" [OnOffStr(g_fSidechar):3], ToggleVar(g_fSidechar), DontClose, "Display a marker for the current line, on the left window border."
	"  Marker character" [Chr(g_chSidechar):1], GetAscii(g_chSidechar), DontClose
	//"  Marker attribute" [g_attrSidechar:3], GetColor(g_attrSidechar), DontClose
	"  Marker attribute...", GetColor(g_attrSidechar), DontClose
	"  Transparent attribute" [OnOffStr(g_fSidecharTransparent):3], ToggleVar(g_fSidecharTransparent), DontClose
	"&Margin" [OnOffStr(g_fMargin):3], ToggleVar(g_fMargin), DontClose, "Display a vertical line at the right margin."
	#endif

	"&Whitespace" [OnOffStr(g_fWhitespace):3], ToggleVar(g_fWhitespace), CloseAllAfter, "Show whitespace on cursor line."
	"  Space character" [Chr(g_chSpace):1], GetAscii(g_chSpace), CloseAllAfter
	"  Tab character" [Chr(g_chTab):1], GetAscii(g_chTab), CloseAllAfter
	"&Bookmarks" [OnOffStr(g_fBookmarks):3], ToggleVar(g_fBookmarks), CloseAllAfter, "Display a marker for bookmarked lines, on the left window border."
	"  Marker character" [Chr(g_chBookmark):1], GetAscii(g_chBookmark), CloseAllAfter
	//"  Marker attribute" [g_attrBookmark:3], GetColor(g_attrBookmark), CloseAllAfter
	"  Marker attribute...", GetColor(g_attrBookmark), CloseAllAfter
	"  Transparent attribute" [OnOffStr(g_fBookmarkTransparent):3], ToggleVar(g_fBookmarkTransparent), CloseAllAfter
	"&Cursor Line" [OnOffStr(g_fSidechar):3], ToggleVar(g_fSidechar), CloseAllAfter, "Display a marker for the current line, on the left window border."
	"  Marker character" [Chr(g_chSidechar):1], GetAscii(g_chSidechar), CloseAllAfter
	//"  Marker attribute" [g_attrSidechar:3], GetColor(g_attrSidechar), CloseAllAfter
	"  Marker attribute...", GetColor(g_attrSidechar), CloseAllAfter
	"  Transparent attribute" [OnOffStr(g_fSidecharTransparent):3], ToggleVar(g_fSidecharTransparent), CloseAllAfter
	"&Margin" [OnOffStr(g_fMargin):3], ToggleVar(g_fMargin), CloseAllAfter, "Display a vertical line at the right margin."
end


proc DoOptions()
	g_fChanged = FALSE

	// looping allows us to refresh the display after each change
	while Options()
		UpdateDisplay(_ALL_WINDOWS_REFRESH_)
	endwhile

	// if anything changed, write the settings to the ini file
	if g_fChanged
		WriteSettings()
		UpdateDisplay(_ALL_WINDOWS_REFRESH_)
	endif
end


proc WhenLoaded()
	GetSettings()
	Hook(_AFTER_UPDATE_DISPLAY_, AfterUpdateDisplay)
end


proc WhenPurged()
	if g_idWindows
		AbandonFile(g_idWindows)
	endif
end


proc Main()
	DoOptions()
end


