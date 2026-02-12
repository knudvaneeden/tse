/*
   Macro          CursColr
   Author         Carlo.Hogeveen@xs4all.nl
   Date           16 March 2009
   Compatibility  TSE Pro 4.0 upwards

   This macro changes the color of the cursor position:
   - if the background color equals the one configured for TSE's cursorline,
   - and:
     -  either only when the cursor is not on a visible character
     -  or always.

   The occasion for this macro was a user who uses a TSE color "intense ...
   ... on black" (which means a dark grey background): for this background
   color TSE doesn't show the cursor if the cursor position is a whitespace.


   Installation:
      Copy this sourcefile to TSE's "mac" directory,
      optionally change the two configurable variable values at the top,
      compile the macro,
      put it in TSE's Macro AutoLoad List,
      and restart TSE.
*/



// You may change these two configuration variables before compiling:
integer new_cursor_position_color = Color(bright white ON black)
integer change_allways = FALSE



integer cursor_x     = 0
integer cursor_y     = 0
string  cursor_s [1] = ""



proc restore_cursor_position_color()
   string s [1] = ""
   string a [1] = ""
   GetStrAttrXY(Query(WindowX1) + CurrCol() - CurrXoffset() - 1,
                Query(WindowY1) + CurrRow() - 1,
                s,
                a,
                1)

   if cursor_x > 0
      if s == cursor_s
         PutStrAttrXY(cursor_x, cursor_y, cursor_s, "", Query(CursorAttr))
      endif
      cursor_x = 0
      cursor_y = 0
      cursor_s = ""
   endif
end



proc change_cursor_position_color()
   string s [1] = ""
   string a [1] = ""
   GetStrAttrXY(Query(WindowX1) + CurrCol() - CurrXoffset() - 1,
                Query(WindowY1) + CurrRow() - 1,
                s,
                a,
                1)
   s = iif(s == "", " ", s)
   restore_cursor_position_color()
   if change_allways
   or (GetText(CurrPos(), 1) in " ", "")
      // Is the current background color equal to that of the cursorline?
      if Asc(a) / 16 == Query(CursorAttr) / 16
         cursor_x = Query(WindowX1) + CurrCol() - CurrXoffset() - 1
         cursor_y = Query(WindowY1) + CurrRow() - 1
         cursor_s = s
         PutStrAttrXY(cursor_x, cursor_y, cursor_s, "", new_cursor_position_color)
      endif
   endif
end



proc WhenLoaded()
   Hook(_BEFORE_COMMAND_, restore_cursor_position_color)
   Hook(_AFTER_COMMAND_ ,  change_cursor_position_color)
end

