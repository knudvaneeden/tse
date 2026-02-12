/*
  Macro           Zoom
  Author          Carlo.Hogeveen@xs4all.nl
  Compatibility   Windows GUI versions of TSE Pro 4.0 upwards
                  with a not maximized screen.
  Version         1.3 - 24 Jul 2020


  Purpose
    Temporarily zoom in and out with Ctrl MouseWheel up and down,
    and go back by clicking Ctrl MouseWheel.

    To make a screen zoom size permanent, use the menu "Options ->
    Save Current Settings".

    Zooming out is limited to where letters (have) become to small to read.

    Zooming in is limited to where a screensize of 80 x 25 characters would no
    longer fit, because that might stop TSE's menus from working.

    When zooming the TSE screen size is kept as much the same as possible
    to the screen size when you started zooming.


  Installation
    Copy this file to TSE's "mac" folder, and compile it by opening it in TSE
    and using the "Macro -> Compile" menu.

    Then add the macro's name to TSE's Macro AutoLoad List by using the menu
    "Macro -> AutoLoad List -> <Insert> key -> type "Zoom" without the quotes
    -> <Enter> key (twice!)".

    Restart TSE.


  Known issues
    Because zooming uses the initial screen size of its first use as a
    reference throughout the TSE session, you might want to restart TSE
    if/after you change the screen size yourself.

    During zooming the initial screen size is shown resulting in flickering.
    This is caused by temporarily resetting the initial screen during zooming
    because this immensely helps with keeping the screen size the same.
    The accepted drawback is a flickering screen during zooming.

    The screen size keeping is pretty good, but still not perfect.


  History
    1.0 - 6 Apr 2018
      Initial version
    1.1 - 15 Oct 2018
      When zooming keep TSE's screen size as much the same as possible.
    1.2 - 17 Oct 2018
      Better screen size keeping, no longer losing the Help line.
    1.3 - 24 Jul 2020
      Now allows disabling the warning if this macro is started in the Console
      version of TSE.

*/



// Compatibility restrictions and mitigations

#ifdef WIN32
#else
   16-bit versions of TSE are not supported. You need at least TSE 4.0.
#endif

#ifdef EDITOR_VERSION
#else
   Editor Version is older than TSE 3.0. You need at least TSE 4.0.
#endif

#if EDITOR_VERSION < 4000h
   Editor Version is older than TSE 4.0. You need at least TSE 4.0.
#endif



dll "<user32.dll>"
  integer proc GetWindowRect(integer hwnd, integer rect)
  integer proc SetWindowPos(integer hwnd, integer hwndafter,
                            integer x, integer y, integer cx, integer cy,
                            integer flags)
  integer proc SendMessage(integer hwnd, integer msg, integer wparam, integer lparam) : "SendMessageA"
  integer proc IsMaximized(integer hwnd) : "IsZoomed"
  integer proc IsMinimized(integer hwnd) : "IsIconic"
end



// Global variables
string  my_macro_name     [MAXSTRINGLEN] = ''
string  initial_font_name [MAXSTRINGLEN] = ''
integer initial_font_pointsize           = 0
integer initial_font_flags               = 0
integer initial_screen_rows              = 0
integer initial_screen_cols              = 0
integer profile_error                    = FALSE



proc write_profile_error()
  if not profile_error
    Alarm()
    Warn('ERROR writing Zoom configuration to file "tse.ini": Zoom will stop ASAP.')
    profile_error = TRUE
  endif
  PurgeMacro(my_macro_name)
end write_profile_error

integer proc write_profile_str(string section_name,
                               string item_name,
                               string item_value)
  integer result = WriteProfileStr(section_name,
                                   item_name,
                                   item_value)
  if not result
    write_profile_error()
  endif
  return(result)
end write_profile_str

proc zoom(string direction)
  integer is_svfntchn_loaded           = FALSE
  integer new_font_flags               = 0
  string  new_font_name [MAXSTRINGLEN] = ''
  integer new_font_pointsize           = 0
  integer next_key                     = 0
  integer old_font_flags               = 0
  string  old_font_name [MAXSTRINGLEN] = ''
  integer old_font_pointsize           = 0
  integer residual_mousewheel_rolls    = FALSE
  integer size_increase                = 0
  integer sizing_step                  = iif(direction == 'out', -1, 1)

  /*  Variables for redundant part.
  integer screen_max_rows              = 0
  integer screen_max_cols              = 0
  integer screen_old_rows              = 0
  integer screen_old_cols              = 0
  integer screen_new_rows              = 0
  integer screen_new_cols              = 0
  */

  if IsMaximized(GetWinHandle())
    Message('Zooming does not work in a maximized screen.')
    return()
  endif

  if isMacroLoaded('SvFntChn')
    is_svfntchn_loaded = TRUE
    PurgeMacro('SvFntChn')
  endif
  GetFont(old_font_name, old_font_pointsize, old_font_flags)
  if initial_font_name == ''
    initial_font_name      = old_font_name
    initial_font_pointsize = old_font_pointsize
    initial_font_flags     = old_font_flags
    initial_screen_rows    = Query(ScreenRows)
    initial_screen_cols    = Query(ScreenCols)
  endif
  if direction == 'back'
    SetFont(initial_font_name, initial_font_pointsize, initial_font_flags)
    // A <Ctrl CenterBtn> click easily introduces residual mousewheel rolls.
    // Let's delete those.
    repeat
      Delay(9)
      if KeyPressed()
        next_key = GetKey()
        if next_key in <Ctrl WheelDown>, <Ctrl WheelUp>
          residual_mousewheel_rolls = TRUE
        else
          residual_mousewheel_rolls = FALSE
          PushKey(next_key)
        endif
      else
        residual_mousewheel_rolls = FALSE
      endif
    until not residual_mousewheel_rolls
  else
    new_font_pointsize = old_font_pointsize
    while (  (sizing_step == -1 and new_font_pointsize >  5)
          or (sizing_step ==  1 and new_font_pointsize < 72) )
    and   new_font_pointsize == old_font_pointsize
      // ResizeFont(sizing_step)
      size_increase = size_increase + sizing_step
      SetFont(initial_font_name, initial_font_pointsize, initial_font_flags)
      SetVideoRowsCols(initial_screen_rows, initial_screen_cols)
      SetFont(old_font_name, old_font_pointsize + size_increase, old_font_flags)
      GetFont(new_font_name, new_font_pointsize, new_font_flags)
      if sizing_step == 1
        if Query(ScreenCols) < 80
        or Query(ScreenRows) < 25
          SetFont(old_font_name, old_font_pointsize, old_font_flags)
        endif
      endif
    endwhile
  endif

  // Testing showed this part is redundant.
  /*
  GetMaxRowsCols(screen_max_rows, screen_max_cols)
  screen_old_rows = Query(ScreenRows)
  screen_old_cols = Query(ScreenCols)
  screen_new_rows = iif(screen_old_rows > screen_max_rows, screen_max_rows, screen_old_rows)
  screen_new_cols = iif(screen_old_cols > screen_max_cols, screen_max_cols, screen_old_cols)
  if screen_new_rows <> screen_old_rows
  or screen_new_cols <> screen_old_cols
    SetVideoRowsCols(screen_new_rows, screen_new_cols)
  endif
  */

  if is_svfntchn_loaded
    LoadMacro('SvFntChn')
  endif
end zoom

proc WhenLoaded()
  my_macro_name = SplitPath(CurrMacroFilename(), _NAME_)
  if WhichOS() <> _WINDOWS_NT_
    Alarm()
    Warn(Upper(my_macro_name), ' macro stopped:', Chr(13), Chr(13),
         'It does not support your operating system.')
    PurgeMacro(my_macro_name)
  elseif not isGUI()
    if GetProfileStr(my_macro_name + ':Config', 'GiveConsoleWarning', 'n') <> 'y'
      Alarm()
      PushKey(<CursorRight>)
      if MsgBox('Skip this warning the next time?',
               my_macro_name +
               ' macro stops: It does not support the Console version of TSE.',
               _YES_NO_) == 1
        write_profile_str(my_macro_name + ':Config', 'GiveConsoleWarning', 'y')
      endif
    endif
    PurgeMacro(my_macro_name)
  endif
end WhenLoaded

<Ctrl WheelDown>  zoom('out')
<Ctrl WheelUp>    zoom('in')
<Ctrl CenterBtn>  zoom('back')

