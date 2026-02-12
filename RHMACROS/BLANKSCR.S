//Quick Screen Blanker.  Can assign to a key by using:
//       <Key> ExecMacro("ScrBlank")  to activate; then any key to restore

proc ScreenBlank()
  integer o_cursor, o_attr

  o_cursor = Set( Cursor, Off )
  HideMouse()
  o_attr = Set( Attr, Color( Black on Black ) )
  ClrScr()
  GetKey()
  Set( Cursor, o_cursor )
  ShowMouse()
  Set( Attr, o_attr )
  UpdateDisplay( _STATUSLINEREFRESH_ | _ALLWINDOWSREFRESH_ )
end ScreenBlank

proc main()
ScreenBlank()
end
