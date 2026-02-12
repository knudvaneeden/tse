/*
  Macro           BlockHilite
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   TSE 4.0 upwards
  Version         v1   20 Jul 2022

  This TSE extension syntax-hilites characters in a marked block with the same
  syntax-hilited foreground colors they would get without a marked block.

  Obviously this will not work for all normal, syntax hilited and blocked color
  combinations.

  My tip is to make your normal text and blocked text background colors both
  light or both dark, and similarly make your normal text and blocked text
  foreground colors are of contrasting colors of both of the background colors.
  And to make your syntax hiliting colors match the normal text's background
  colors.



  INSTALLATION

  Copy this file to TSE's "mac" folder and compile it there, for example by
  opening it there in TSE and applying the Macro -> Compile menu.

  Add the macro's name "BlockHilite" to TSE's Macro -> AutoLoad List menu,
  and restart TSE.
*/


// Global constants and semi-constants
string  MACRO_NAME [MAXSTRINGLEN] = ''
integer HILITE_ATTRS_ID           = 0


// Global variables
integer display_updated = FALSE


proc syntax_hilite_block()
  integer block_bg_attr                        = Query(BlockAttr) / 16
  integer column                               = 0
  integer column_bg_attr                       = 0
  integer cursor_in_block_bg_attr              = Query(CursorInBlockAttr) / 16
  integer row                                  = 0
  string  row_with_block_attrs  [MAXSTRINGLEN] = ''
  string  row_with_both_attrs   [MAXSTRINGLEN] = ''
  string  row_with_hilite_attrs [MAXSTRINGLEN] = ''
  string  row_text              [MAXSTRINGLEN] = ''
  integer window_beg_row                       = Query(WindowY1)
  integer window_cols                          = Query(WindowCols)
  integer window_end_row                       = window_beg_row + Query(WindowRows) - 1
  integer window_x1                            = Query(WindowX1)

  BufferVideo()
  PushBlock()
  UnMarkBlock()
  UpdateDisplay(_WINDOW_REFRESH_)
  for row = window_beg_row to window_end_row
    GetStrAttrXY(window_x1, row, row_text, row_with_hilite_attrs, window_cols)
    SetBufferStr(Str(row), row_with_hilite_attrs, HILITE_ATTRS_ID)
  endfor
  PopBlock()
  UpdateDisplay(_WINDOW_REFRESH_)
  UnBufferVideo()

  for row = window_beg_row to window_end_row
    GetStrAttrXY(window_x1, row, row_text, row_with_block_attrs, window_cols)
    row_with_hilite_attrs = GetBufferStr(Str(row), HILITE_ATTRS_ID)
    row_with_both_attrs   = row_with_block_attrs
    for column = 1 to Length(row_with_both_attrs)
      column_bg_attr = Asc(row_with_block_attrs [column]) / 16
      if (column_bg_attr in block_bg_attr, cursor_in_block_bg_attr)
        row_with_both_attrs [column] =
          Chr(Asc(row_with_hilite_attrs [column]) mod 16 + column_bg_attr * 16)
      endif
    endfor
    if row_with_both_attrs <> row_with_block_attrs
      PutStrAttrXY(window_x1, row, row_text, row_with_both_attrs)
    endif
    DelBufferVar(Str(row), HILITE_ATTRS_ID)
  endfor
end syntax_hilite_block


proc check_for_block_in_curr_window()
  integer first_displayed_buffer_line = CurrLine() - CurrRow() + 1
  integer last_displayed_buffer_line  = 0

  last_displayed_buffer_line = first_displayed_buffer_line + Query(WindowRows) - 1

  if  Query(BlockBegLine) < last_displayed_buffer_line
  and Query(BlockEndLine) > first_displayed_buffer_line
    syntax_hilite_block()
  endif
end check_for_block_in_curr_window


proc check_for_block_in_curr_file()
  if isBlockInCurrFile()
    check_for_block_in_curr_window()
  endif
end check_for_block_in_curr_file


proc check_for_display_update()
  if display_updated
    check_for_block_in_curr_file()
    display_updated = FALSE
  endif
end check_for_display_update


proc set_display_is_updated()
  display_updated = TRUE
end set_display_is_updated


proc WhenLoaded()
  MACRO_NAME = SplitPath(CurrMacroFilename(), _NAME_)

  PushLocation()
  HILITE_ATTRS_ID = CreateTempBuffer()
  ChangeCurrFilename(MACRO_NAME + ':HiliteAttrs',
                     _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  PopLocation()

  Hook(_AFTER_UPDATE_DISPLAY_, set_display_is_updated)
  Hook(_IDLE_                , check_for_display_update)
end WhenLoaded


