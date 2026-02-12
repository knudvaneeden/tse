/*
  Macro           OpenCursor
  Author          Carlo.Hogeveen@xs4all.nl
  Website         https://ecarlo.nl/tse
  Compatibility   TSE Pro v4.0 upwards
  Version         0.1 - 7 May 2020

  This tool opens the file or URL the cursor is on.

  Only existing files are recognized and opened. In case of duplicate
  possibilities the one with the longest path and name is opened, and in
  Windows not-plain-text files are opened with their default application.

  To be recognized a URL either has to start with "http(s)://" or "www." or
  have an address-part that ends with a macro-configured top level domain (TLD)
  like ".com", ".org", and a few country codes. You can add a few additional
  TLDs. URLs are opened with the default webbrowser.


  INSTALLATION

  Copy this .s file to TSE's "mac" folder, and compile it there, for example
  by opening it there in TSE and using the Macro Compile menu.

  Use any or all of the following methods to open the file or URL that the
  cursor is on:
  - Add "OpenCursor" to TSE's Potpourri menu, and use the "Open" action in the
    configuration menu.
  - In the TSE user interface file (one of the ui\*.ui files) assign the macro
    with the argument "open" to a key or mouse combination, for example:
      <your key combination>  ExecMacro('OpenCursor open')
  - Use the Keys.ui file of my Keys macro to assign the macro with the argument
    "open" one or more key or mouse combinations, for example to double left
    clicking the mouse:
      <LeftBtn><LeftBtn>        ExecMacro('OpenCursor open')
  - Use TSE's Macro Execute menu and type:
      OpenCursor open

  Not implemented yet: Execute the macro without arguments to configure it.


  TODO
    MUST
    - Currently the macro must be in the autoload list after the keys and
      cuamark macros, and I do not understand why because I compensated for
      them. Do keyboard logging to find out what is happening.
    SHOULD
    COULD
    WONT

*/


// Global constants
#define IDLE_PERIOD 18


// Global variables
integer idle_timer                   = IDLE_PERIOD
integer mouse_x                      = 0
integer mouse_y                      = 0
string  my_macro_name [MAXSTRINGLEN] = ''


proc open_cursor()
  integer cursor_pos         = CurrPos()
  integer found              = FALSE
  string  search_options [4] = 'cgix'

  // If the last key was a mouse key, then the cursor position might not have
  // been updated and will possibly not be updated to the click position.
  // Here we account for that.
  // In such a case we do update the cursor position to give a visual
  // confirmation of which cursor position we used.
  if mouse_x
  or mouse_y
    GotoColumn(mouse_x - Query(WindowX1) + 1)
    GotoRow   (mouse_y - Query(WindowY1) + 1)
  endif

  PushLocation()

  // Try to find a URL starting with "http".
  while not found
  and   lFind('https?://[~ \d009]#', search_options)
    found = (cursor_pos in CurrPos() .. (CurrPos() + Length(GetFoundText()) - 1))
    search_options = 'cix+'
  endwhile
  if found
    StartPgm(GetFoundText())
  endif
  PopLocation()
end open_cursor

proc hilite_openable_strings()
  // Not implemented yet.
end hilite_openable_strings

proc idle()
  if idle_timer
    idle_timer = idle_timer - 1
  else
    hilite_openable_strings()
    idle_timer = IDLE_PERIOD
  endif
end idle

proc after_getkey()
  integer last_key = Query(Key)

  // When this macro is executed by the Keys macro, then at that point it will
  // only see key -1 or one of its synonyms.
  // This hook is executed earlier, and can recognize the real last key, and if
  // it was a mouse key it can remember the last mouse position for us.
  if not (last_key in 65535, 32767, 2047, -1)
    if RightStr(KeyName(last_key), 3) == 'Btn'
      mouse_x = Query(MouseX)
      mouse_y = Query(MouseY)
    else
      mouse_x = 0
      mouse_y = 0
    endif
  endif
end after_getkey

proc WhenLoaded()
  my_macro_name = SplitPath(CurrMacroFilename(), _NAME_)
  Hook(_AFTER_GETKEY_, after_getkey)
  Hook(_IDLE_        , idle)
end WhenLoaded

proc configure()
  Warn(my_macro_name, ': Configuration not implemented yet.')
end configure

proc Main()
  case Lower(Query(MacroCmdLine))
    when 'open'
      open_cursor()
    when ''
      configure()
    otherwise
      Warn(my_macro_name; 'was called with this illegal argument:';
           Query(MacroCmdLine))
  endcase
end Main

