/*
  Macro           ControlChars
  Author          Carlo.Hogeveen@xs4all.nl
  Version         v1.0.1  -  31 Oct 2019
  Compatibility   TSE Pro v4.0 upwards



  FUNCTIONALITY

  With this TSE extension you can [better] see control characters, like null,
  bell, backspace, tab, line feed, form feed or carriage return.

  [Better]:
  The GUI version of TSE with an ANSI compatible font hides control characters
  by showing them as spaces.
  The Console version of TSE and e.g. the Terminal font show most control
  characters as regular characters, which is better but does not make them
  stand out from regular text.
  This TSE extensions shows all control characters and always makes them stand
  out.

  Note, that in normal/non-binary mode TSE has stripped carriage returns and
  line feeds from lines, so what is not there will not be shown.

  In the TSE menu "ASCII Chart" you see control characters 0, 1, 2, 3 ... 31
  also as the column "^@", "^A", "^B", "^C", ..., "^Z", ..., "^_".
  This TSE extension consistently shows a control character as the second
  character from that last column but in the inverted text colour.


  INSTALLATION

  Copy this source file to TSE's "mac" folder, open the file in TSE, and
  compile the file with the Macro Compile menu.

  Then add this macro's name "ControlChars" to the TOP (!!!)
  of the Macro AutoLoad List menu, and restart TSE.


  KNOWN ERROR

  There is a known error, that for some configurations control characters in
  column 1 of a text are not shown.
  For now the solution is to put "ControlChars" at the top of
  the Macro AutoLoad List menu and restart TSE.


  HISTORY

  v1.0    -  29 Oct 2019
    Initial release.
  v1.0.1  -  31 Oct 2019
    Improved the documentation.
*/

proc update_edit_window()
  string  attrs [MAXSTRINGLEN] = ''
  string  chars [MAXSTRINGLEN] = ''
  integer col                  = 0
  integer col_from             = Query(WindowX1)
  string  new_attr         [1] = '' // Chr(Color(white ON black))
  string  new_char         [1] = ''
  integer num_cols             = Query(WindowCols)
  integer read_length          = 0
  integer row                  = 0
  integer row_from             = Query(WindowY1)
  integer row_to               = Query(WindowY1) + Query(WindowRows) - 1
  for row = row_from to row_to
    read_length = GetStrAttrXY(col_from, row, chars, attrs, num_cols)
    for col = 1 to read_length
      if (Asc(chars[col]) in 0 .. 31)
        new_char = Chr(Asc(chars[col]) +  64)
        new_attr = Chr(Asc(attrs[col]) ^ 255)
        PutStrAttrXY(col_from + col - 1, row, new_char, new_attr)
      endif
    endfor
  endfor
end update_edit_window

proc WhenLoaded()
  Hook(_AFTER_UPDATE_DISPLAY_, update_edit_window)
end

proc Main()
  // Configuration needed?
end Main

