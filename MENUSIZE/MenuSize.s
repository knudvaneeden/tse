/*
  Macro           MenuSize
  Author          Carlo.Hogeveen@xs4all.nl
  Date            29 may 2013
  Compatibility   GUI versions of TSE Pro 4.0 upwards
  Version         1.0.1 - 30 May 2013

  This is a fun DEMO macro to show off dynamically resizing menu's.

  Adapting to your current screen size, this macro will dynamically show
  a menu in the largest possible font size that will fit the menu.

  So small menu's are shown in a large fontsize, and large menu's are
  shown in a small fontsize.

  The macro does not change the current font, only its size,
  and only as far as the font permits.

  Side effect 1:
    The menu-sizing only works correctly when TSE's screen is maximized,
    so the whole TSE screen is maximized during the menu sizing.

  Side effect 2:
    The old fontsize is restored AFTER the menu exits.
    This means that functions that are directly called by the menu,
    are executed in the resized font.
    Often that is no problem at all.
    If it IS a problem, then a work-around is to call that
    function AFTER the menu, based on the value of MenuOption().

  Design:
    The macro is split in a "menu size handling" part,
    and in a "your program" part.

    The intent is, that you can copy the "menu size handling" part "as is"
    to your own macro('s), and that you only have to write your own
    "your program part".

  History:
    1.0.0 - 29 May 2013
      Initial version.
    1.0.1 - 30 May 2013
      Solved bug when screen was not maximized.
      Solved responding to the correct menu level in the main program.
*/





// HERE starts the "menu handling part".

// Smaller is faster for large menu's, but doesn't show small menu's as big:
integer menu_max_pointsize = 64

#define SWP_NOSIZE      0x0001
#define WM_SYSCOMMAND   0x0112
#define SC_MINIMIZE     0xF020
#define SC_MAXIMIZE     0xF030
#define SC_RESTORE      0xF120

dll "<user32.dll>"
    integer proc GetWindowRect(integer hwnd, integer rect)
    integer proc SetWindowPos(integer hwnd, integer hwndafter,
                        integer X, integer Y, integer cx, integer cy,
                        integer flags)
    integer proc SendMessage(integer hwnd, integer msg, integer wparam, integer lparam) : "SendMessageA"
    integer proc IsMaximized(integer hwnd) : "IsZoomed"
    integer proc IsMinimized(integer hwnd) : "IsIconic"
end

string  menu_font_name       [255] = ''
integer menu_font_before_pointsize = 0
integer menu_font_pointsize        = 0
integer menu_font_flags            = 0
integer menu_before_msglevel       = 0
integer menu_maximized_screen      = FALSE

proc init_menu_size()
  integer set_font = FALSE

  menu_maximized_screen = FALSE
  if isGUI()
    if not (IsMaximized(GetWinHandle()) or IsMinimized(GetWinHandle()))
      SendMessage(GetWinHandle(), WM_SYSCOMMAND, SC_MAXIMIZE, 0)
      menu_maximized_screen = TRUE
    endif
  endif

  GetFont(menu_font_name, menu_font_before_pointsize, menu_font_flags)
  menu_before_msglevel   = Set(MsgLevel, _NONE_)
  menu_font_pointsize = menu_max_pointsize

  menu_font_pointsize = menu_font_pointsize + 1
  while menu_font_pointsize > 5
  and not set_font
    menu_font_pointsize = menu_font_pointsize - 1
    set_font = SetFont(menu_font_name, menu_font_pointsize,
                       menu_font_flags)
  endwhile
end init_menu_size

integer proc menu_size_found()
  integer result   = FALSE
  integer set_font = FALSE
  if MenuOption() > 0
    // The menu worked, and the user made a choice.
    result = TRUE
  elseif KeyName(MenuKey()) == 'Escape'
    // The menu worked, and the user pressed <Escape>.
    result = TRUE
  else
    // The menu aborted, we assume because of its too large screen size.
    while menu_font_pointsize >= 5
    and not set_font
      menu_font_pointsize = menu_font_pointsize - 1
      set_font = SetFont(menu_font_name, menu_font_pointsize,
                         menu_font_flags)
    endwhile
    if menu_font_pointsize <= 4
    or not set_font
      // No menu size fits this menu.
      result = TRUE
      Warn('Menu also too large for smallest font size.')
    endif
  endif
  if result
    Set(MsgLevel, menu_before_msglevel)
    SetFont(menu_font_name, menu_font_before_pointsize, menu_font_flags)
    if menu_maximized_screen
      SendMessage(GetWinHandle(), WM_SYSCOMMAND, SC_RESTORE, 0)
    endif
  endif
  return(result)
end menu_size_found

// HERE ends the "menu handling part".





// HERE starts the "your program part".

menu my_large_menu()
  TITLE = 'My Large Menu'
  HISTORY
  X = 10
  Y = 5
  "Choice  1"
  "Choice  2"
  "Choice  3"
  "Choice  4"
  "Choice  5"
  "Choice  6"
  "Choice  7"
  "Choice  8"
  "Choice  9"
  "Choice 10"
  "Choice 11"
  "Choice 12"
  "Choice 13"
  "Choice 14"
  "Choice 15"
  "Choice 16"
  "Choice 17"
  "Choice 18"
  "Choice 19"
  "Choice 20"
  "Choice 21"
  "Choice 22"
  "Choice 23"
  "Choice 24"
  "Choice 25"
  "Choice 26"
  "Choice 27"
  "Choice 28"
  "Choice 29"
  "Choice 30"
  "Choice 31"
  "Choice 32"
end my_large_menu

menu my_medium_menu()
  TITLE = 'My Medium Menu'
  HISTORY
  X = 10
  Y = 5
  "Choice  1"
  "Choice  2"
  "Choice  3"
  "Choice  4"
  "Choice  5"
  "Choice  6"
  "Choice  7"
  "Choice  8"
  "Choice  9"
  "Choice 10"
  "Choice 11"
  "Choice 12"
  "Choice 13"
  "Choice 14"
  "Choice 15"
  "Choice 16"
end my_medium_menu

menu my_small_menu()
  TITLE = 'My Small Menu'
  HISTORY
  X = 10
  Y = 5
  "Choice  1"
  "Choice  2"
  "Choice  3"
  "Choice  4"
  "Choice  5"
  "Choice  6"
  "Choice  7"
  "Choice  8"
end my_small_menu

integer my_menu_level = 0

proc show_menu_sized(string menu_name)
  my_menu_level = 2
  init_menu_size()
  repeat
    case menu_name
      when 'my_small_menu'
        my_small_menu()
      when 'my_medium_menu'
        my_medium_menu()
      when 'my_large_menu'
        my_large_menu()
    endcase
  until menu_size_found()
end

menu my_main_menu()
  TITLE = 'My Main Menu'
  HISTORY
  X = 10
  Y = 5
  "My &Small  Menu", show_menu_sized('my_small_menu')
  "My &Medium Menu", show_menu_sized('my_medium_menu')
  "My &Large  Menu", show_menu_sized('my_large_menu')
end my_main_menu

proc Main()
  repeat
    my_menu_level = 1
    my_main_menu()
  until my_menu_level      == 1
    and KeyName(MenuKey()) == 'Escape'
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

// HERE ends the "your program part".
