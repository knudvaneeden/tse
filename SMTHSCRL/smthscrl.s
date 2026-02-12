// SmthScrl - Smooth scrolling scrollbar macro.

/*
 * History:
 *
 * v1.2 -- July 24, 2004 -- Public release.
 *
 */

//$ todo: optionally use a real scrollbar somehow; overlay it on the console
// window or GUI window.

#ifndef WIN32
error:  This macro only works on TSE 2.6 and higher for Windows.
#endif

dll "<user32.dll>"
	proc GetClientRect(integer hwnd, integer pRect)
	proc ScreenToClient(integer hwnd, integer pPoint)
	proc GetCursorPos(integer pPoint)
end

#include ["guiinc.inc"]

/*
 * GetCellHeight - calculate pixel height of character cells.
 */

integer proc GetCellHeight()
	string rc[16] = ""

	GetClientRect(GetWinHandle(), AdjPtr(Addr(rc), 2))

	return(PeekLong(AdjPtr(Addr(rc), 2+12)) / Query(ScreenRows))
end

/*
 * GetThumbRow - get the height of the scrollbar in characters.
 */

integer proc GetThumbRow()
	// The height of the scrollbar is the window height minus two, for the up
	// and down arrow buttons.

	integer cyBar = Query(WindowRows) - 2
	integer cLines = NumLines() - Query(WindowRows)
	integer row = 0

	if cLines > 0
		row = (CurrLine() - CurrRow())
		row = (row * cyBar) / cLines
	endif

	return(min(row + 1, cyBar))
end

/*
 * DrawScrollbar - draw the custom scrollbar appearance.
 */

#if EDITOR_VERSION >= 0x3000
integer g_chHash = Asc("±")
#else
integer g_chHash = Asc("°")
#endif

proc DrawScrollbar(integer fDragging)
	integer x, y
	integer i

	BufferVideo()

	Set(Attr, Query(CurrWinBorderAttr))
	x = Query(WindowX1) + Query(WindowCols)
	y = GetThumbRow()

	// Draw upper portion of bar.

	for i = 1 to y - 1
		mPutOemChrXY(x, Query(WindowY1) + i, g_chHash, Query(Attr), FALSE)
	endfor

	// Draw thumb button.

	mPutOemChrXY(x, Query(WindowY1) + y, iif(fDragging, Asc(""), Asc("Û")), Query(Attr), FALSE)

	// Draw lower portion of bar.

	for i = y + 1 to Query(WindowRows) - 2
		mPutOemChrXY(x, Query(WindowY1) + i, g_chHash, Query(Attr), FALSE)
	endfor

	UnBufferVideo()
end

/*
 * GetMouseY - get the mouse position in client coordinates.
 */

integer proc GetMouseY()
	string pt[8] = ""

	// Offset to adjust the mouse client coordinates by.  Probably it's needed
	// due to the 3D recessed border inside the window's client area, in both
	// the console and GUI versions.

	constant c_dyFudge = 2

	// Get the mouse position in client coordinates.

	GetCursorPos(AdjPtr(Addr(pt), 2))
	ScreenToClient(GetWinHandle(), AdjPtr(Addr(pt), 2))

	// Return the position, adjusted by the fudge factor above.

	return(PeekLong(AdjPtr(Addr(pt), 2 + 4)) - c_dyFudge)
end

/*
 * CalcTopLine - calculate what the top line should be.
 */

integer proc CalcTopLine(integer yTop, integer cyCell, integer dy, integer cLines)
	integer y
	integer ln = 0

	y = GetMouseY() - yTop

	ln = ((y / cyCell) * cLines / (Query(WindowRows) - 2)) + ((y mod cyCell) * cLines / (Query(WindowRows) - 2) / cyCell)
	ln = ln + 1 - dy

	if ln < 1
		ln = 1
	elseif ln > cLines
		ln = cLines
	endif

	return(ln)
end

/*
 * SetTopLine - scroll the window so the specified line is at the top, while
 * trying to keep the cursor line on the same row.
 */

proc SetTopLine(integer lnTop)
	integer row = CurrRow()

	BufferVideo()

	BegWindow()
	GotoLine(lnTop)
	GotoRow(row)

	UpdateDisplay()
	DrawScrollbar(TRUE)

	UnBufferVideo()
end

/*
 * mLeftBtn - handle the vertical scrollbar events to enable smooth scrolling.
 */

proc mLeftBtn()
	integer cyCell
	integer yTop
	integer lnNumLines
	integer dy = 0
	integer lnTop = 0
	integer lnPrev = 0
	integer fPop = FALSE

	case MouseHotSpot()
		when _MOUSE_PAGEUP_, _MOUSE_VELEVATOR_, _MOUSE_PAGEDOWN_
			GotoWindow(MouseWindowId())

			if Query(MouseY) < GetThumbRow()+Query(WindowY1)
				PageUp()
				return()
			elseif Query(MouseY) > GetThumbRow()+Query(WindowY1)
				PageDown()
				return()
			endif

			PushPosition()

			// Get the scrollbar top in client coordinates, and the extent in
			// character cells.

			cyCell = GetCellHeight()
			yTop = Query(WindowY1) * cyCell
			//lnNumLines = NumLines() - (Query(WindowRows) - 1)
			lnNumLines = (NumLines() - Query(WindowRows)) + 1

			// Calculate the current top line.

			lnTop = CurrLine() - CurrRow() + 1

			// Calculate the 'dy' offset to adjust the calculated top line by,
			// so that the top line changes proportional to how much (if at
			// all) the mouse is moved.  This avoids jittery behavior on the
			// initial click, or exaggerated response when the mouse is first
			// moved.

			dy = CalcTopLine(yTop, cyCell, 0, lnNumLines) - lnTop

			// Set the top line.  Do this unconditionally simply because it's
			// an easy way to make sure the scrollbar gets redraw to show the
			// drag feedback.

			lnPrev = lnTop
			SetTopLine(lnTop)

			// Loop until the mouse is released.  Unfortunately TSE does not
			// detect the mouse button being released outside the window;
			// probably TSE doesn't use the SetCapture() and ReleaseCapture()
			// APIs.

			while MouseStatus()
				// Calculate the new top line.

				lnTop = CalcTopLine(yTop, cyCell, dy, lnNumLines)

				// Update the top line if it needs to change.

				if lnTop <> lnPrev
					lnPrev = lnTop
					SetTopLine(lnTop)
				endif

				// If the <Escape> key is pressed then cancel the scrolling.

				if KeyPressed()
					if GetKey() == <Escape>
						fPop = TRUE
						break
					endif
				endif
			endwhile

			// If the scrolling was canceled then pop back to the original
			// position.

			if fPop
				PopPosition()
				BufferVideo()
				UpdateDisplay()
				DrawScrollbar(FALSE)
				UnBufferVideo()
			else
				KillPosition()
			endif

		otherwise
			ChainCmd()
	endcase
end

/*
 * OnIdle - idle proc to draw the custom scrollbar appearance.
 */

proc Draw()
	if Query(DisplayBoxed)
		DrawScrollbar(FALSE)
	endif
end

/*
 * WhenLoaded - hook the idle proc to draw the custom scrollbar appearance.
 */

proc WhenLoaded()
	Hook(_IDLE_, Draw)
end

/*
 * Key binding for the left mouse button, to handle the scrollbar events.
 */

<LeftBtn>				mLeftBtn()
