/****************************************************************************

Crosshair 1.0
Michael Durland
mdurland@yahoo.com
May 20, 2004

This macro provides a movable crosshair on the screen which makes it easy
to line up text vertically and horizontally.  For example, if the cursor
is near the bottom of the screen, it can be used to visually identify 
what is directly above the cursor near the top of the screen.  This is
also useful across multiple open windows for visually checking lineup.

The crosshair can be moved around the screen using the cursor keys.
The ENTER key will remove the crosshair and set the cursor to the 
crosshair location.  Any other key will remove the crosshair and restore
the cursor to its original position.

The macro is most useful when assigned to a hotkey of your choosing.

Feel free to use/modify/distribute/etc. however you want.
This macro was developed under version TSE Pro v4.0.
Portions of this macro are based on ruler.s by Glenn Alcott.

*****************************************************************************/

integer									start_column = 0
integer									start_line = 0
integer									start_x = 0
integer									start_y = 0
integer									cross_x = 0
integer									cross_y = 0
integer									edge_top = 1
integer									edge_bottom = 0
integer									edge_left = 1
integer									edge_right = 0

integer cross_color = Color(bright black on blue)
// Other interesting colors:
//integer cross_color = Color(bright red on blue)
//integer cross_color = Color(bright blue on blue)
//integer cross_color = Color(bright cyan on blue)
//integer cross_color = Color(bright yellow on blue)
//integer cross_color = Color(bright magenta on blue)
//integer cross_color = Color(white on blue)
//integer cross_color = Color(red on blue)

proc paint_crosshair()
	integer								i = 0
	string								s[1] = ""

	UpdateDisplay(_ALL_WINDOWS_REFRESH_)
	
	// Paint the horizontal line
	for i = edge_left to edge_right
		GetStrXY(i, cross_y, s, 1)
		// Only paint line in blank spaces, and skip the crosshair intersection
		if Asc(s) == 32 and i <> cross_x
			PutOEMStrXY(i, cross_y, Chr(196), cross_color)
		endif
	endfor
	
	// Paint the vertical line
	for i = edge_top to edge_bottom
		GetStrXY(cross_x, i, s, 1)
		// Only paint line in blank spaces
		if Asc(s) == 32
			if i == cross_y
				// Paint the intersection
				PutOEMStrXY(cross_x, i, Chr(197), cross_color)
			else
				PutOEMStrXY(cross_x, i, Chr(179), cross_color)
			endif
		endif
	endfor
	
	// Show the current crosshair position in the status bar
	Message("L ", start_line + cross_y - start_y : -8, "C ", start_column + cross_x - start_x)
end

proc Main()
	integer								cursor_state = Query(Cursor)
	integer								done = FALSE
	
	Set(Cursor, OFF)
	
	// Save current cursor position in buffer
	start_column = CurrCol()
	start_line = CurrLine()
	
	// Save absolute starting position
	start_x = WhereX()
	start_y = WhereY()
	
	// Initialize absolete crosshair position
	cross_x = WhereX()
	cross_y = WhereY()
	
	// Initialize crosshair width range
	if Query(DisplayBoxed)
		edge_left = 2
		edge_right = Query(ScreenCols) - 1
	else
		edge_left = 1
		edge_right = Query(ScreenCols)
	endif
	
	// Initialize crosshair height range
	// Note these may be slightly off depending on current customizations.
	edge_top = 3
	edge_bottom = Query(ScreenRows) - 2
	
	// Do it
	repeat
		paint_crosshair()
		case GetKey()
			when <CursorDown>
				// Move down one row
				cross_y = iif(cross_y >= edge_bottom, edge_bottom, cross_y + 1)
			
			when <CursorUp>
				// Move up one row
				cross_y = iif(cross_y <= edge_top, edge_top, cross_y - 1)
			
			when <CursorLeft>
				// Move left one column
				cross_x = iif(cross_x <= edge_left, edge_left, cross_x - 1)
			
			when <CursorRight>
				// Move right one column
				cross_x = iif(cross_x >= edge_right, edge_right, cross_x + 1)
			
			when <Home>
				// Move to the left edge of the screen
				cross_x = edge_left
			
			when <End>
				// Move to the right edge of the screen
				cross_x = edge_right
			
			when <PgUp>
				// Move to the top of the screen
				cross_y = edge_top
			
			when <PgDn>
				// Move to the bottom of the screen
				cross_y = edge_bottom
			
			when <Enter>
				// Exit the crosshair mode, setting the cursor to the 
				// current crosshair location.
				GotoRow(CurrRow() + (cross_y - start_y))
				GotoColumn(start_column + cross_x - start_x)
				done = TRUE
				
			otherwise
				// Exit the crosshair mode, restoring the original
				// cursor position.
				done = TRUE
		endcase
	until done
	UpdateDisplay(_ALL_WINDOWS_REFRESH_)
	Set(Cursor, cursor_state)
end

