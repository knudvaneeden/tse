/*
  Macro           CursorLine
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE Pro GUI v4.2 upwards
  Version         v1.0.4   14 Sep 2022

  This extension brightens or dims all the cursor line's foreground or
  background colors by a configurable percentage.

  It is an alternative to TSE's configuration option to give the cursor line
  different colors.


  INSTALLATION

  Copy this file to TSE's "mac" folder and compile it there, for example by
  opening it there in TSE and applying the Macro, Compile menu.

  Configure it to make it do something.


  CONFIGURATION

  Execute the extension as a macro, for example by selecting the
  menu Macro, Execute, and entering "CursorLine".

  Default the brightness percentage is 0%, meaning colors stay the same.
  The brightest percentage value is  100%, which makes all colors white.
  The dimmest   percentage value is -100%, which makes all colors black.


  Optionally optional:

  If TSE has cursor line colors configured to be different from normal text
  colors, then now it makes sense to make those colors the same.

  Go to the TSE menu
    Options,
    Full Configuration,
    Display/Color Options,
    Set Colors,
    Select Editing Colors,
  look up what the colors for
    Text - Normal
    Text - Blocked
  are, and then respectively set
    Text - Cursor Line
    Text - Cursor Line in Block
  to the same colors.


  TIP

  Context: TSE can be configured to have dark text on a bright background or
  bright text on a dark background.

  This extension's configuration allows you to brighten and dim the cursor
  line's foreground and background colors independently, making it usable
  for both kinds of text.

  The cursor line's foreground colors need a large percentage to be visible.

  The cursor line's background colors only need a tiny percentage.



  TODO
    MUST
    SHOULD
    COULD
    WONT
      The below ideas are technically possible, but might perform less well and
      would be very time-consuming to implement. Also, while they would look
      amazing, I would probably not use them in practice. So my cost/benefit
      analysis says not to do them:
      - Add a few proportionally less brightened lines around the cursor line.
      - Make a round spotlight.
      - Make the spread of the brightening configurable.


  HISTORY

  v1        13 Oct 2021
    Initial release.

  v1.0.1    13 Oct 2021
    Fixed it not actually being backwards compatible
    with Windows TSE Pro GUI v4.2.

  v1.0.2    30 Nov 2021
    Fixed the lag in brightening and dimming the cursor line.
    Improved the documentation.

  v1.0.3   17 Sep 2022
    Fixed incompatibility with TSE's '-i' command line option
    and the TSELOADDIR environment variable.

  v1.0.4   14 Oct 2022
    Fixed a future problem: CursurLine now disables itself during _DISPLAY_HELP_
    display mode, so it no longer overwrites OEM characters with ANSI characters
    there. Currently nobody edits files in _DISPLAY_HELP_ display mode, but in
    the future some of us will.

*/



/*
  T E C H I C A L   B A C K G R O U N D   I N F O


  TERMINOLOGY

  For colors almost all TSE functions refer to a TSE-specific 8-bit
  foreground/background color attribute.
  Its upper/lower 4 bits each refer to an index of 16 background/foreground
  colors.
  There is a TSE default for what actual 24-bit RGB color is used for each
  indexed color.
  This default can be queried and overwritten by the GetColorTableValue()
  and SetColorTableValue() functions.


  TRICK

  Oversimplified:

  The editor itself regularly updates the screen.

  If a macro assigns a new RGB color to an indexed color and updates the screen
  with PutStrAttrXY(), then this additional RGB color is shown as long as the
  editor itself does not update the screen.

  In theory all 16,777,216 RGB colors can simultenously be shown this way.
  In practice that number is limited to the number of characters on the screen.

  In reality the above method is anything but simple, because it is fraught
  with obstacles. Below these obstacles are described.


  THE PUTSTRATTRXY() BUG

  The bug is, that if PutStrAttrXY() is directed to write to the screen with
  color attribute 0 (BLACK on BLACK), then it uses color attribute Query(Attr)
  instead.
  This can relatively simply be worked around by pre-setting Attr to the
  required color attribute before using PutStrAttrXY().


  WORKING AROUND SCREEN CACHING

  This is a huge problem.

  The following kept mentally tripping me up:
  The TSE documentation refers to a character attribute's "color".
  There are even predefined constants that give names to "colors".
  But actually a character attribute refers to an index, that in turn refers
  to two (!) actual colors.
  The 8-bit index can have 256 values, the high and low 4 bits of each
  respectively referring to a fixed combination of 16 background and 16
  foreground colors.
  Up to TSE v4.2 that difference did not matter, because there was only one
  fixed set of actual colors.
  So it did made sense to simplify the documentation this way.
  However, with the introduction of the GetColorTableValue() and
  SetColorTableValue() functions in TSE v4.2 that no longer makes sense.
  The documentation was never updated, except those two functions.
  So firstly we have to mentally adjust for the outdated documentation.
  Secondly, a color index refers to two (!) actual colors.
  I kept being tripped up by thinking, that to temporarily change a character's
  color I could temporarily change its attribute value, forgetting that that
  refers to two (!) actual colors and that two different attribute values can
  refer to a same background or foreground color value.
  For example, the latter means that we cannot simply update a whole line's
  colors with one PutStrAttrXY() command if the line needs to contain more
  than 16 actual background or foreground colors.
  I hope this explanation helps you and future me fare better.

  About TSE's color ATTRIBUTE caching:
  The PutStrAttrXY() function does not recolor the screen when it writes the
  same color attribute that is already there.
  Normally this is a good thing, because it optimizes TSE's screen updates.
  Here however, it prohibites us from using PutStrAttrXY() with the same color
  attribute after having used SetColorTableValue() to temporarily set a new RGB
  color for the existing color attribute part.
  So to write a new RGB color to the screen we need to use a new color
  attribute.
  But a color attribute consists of a 4-bit reference to a background color and
  a 4-bit reference to a foreground color.
  So using a new color attribute would reference two actual colors!

  A general solution is possible, but is complex to very complex.
  Firstly, it requires updating the screen twice; once to an unused dummy
  attribute to force a dummy screen update and once to the intended new or old
  attribute to force the needed screen update.
  Secondly, if the application needs more than 16 background/foreground colors
  on the same line, then it requires updating the screen character by character,
  which at best is visibly slow.

  This extension has simpler requirements that can use a simpler solution.
  Because it updates the old set of colors in a line one-on-one to a new set of
  colors, it can overwrite the line as a whole, twice.
  It first overwrites the line with Color(Black on Black) to undo TSE's screen
  caching, and then immediately overwrites the line with the old set of color
  attributes, which temporarily have been set to brightend or dimmed RGB colors.

*/





// Start of compatibility restrictions and mitigations



/*
  When compiled for Linux or with a TSE version below TSE v4.2 the compiler
  reports a syntax error and hilights the first applicable line below.
*/

#ifdef LINUX
  Linux is not supported.
#endif

#ifdef WIN32
#else
   16-bit versions of TSE are not supported. You need at least TSE Pro v4.2.
#endif

#ifdef EDITOR_VERSION
#else
   Editor Version is older than TSE Pro v3.0. You need at least TSE Pro v4.2.
#endif

#if EDITOR_VERSION < 4200h
   Editor Version is older than TSE Pro v4.2. You need at least TSE Pro v4.2.
#endif





#if EDITOR_VERSION < 4400h
  /*
    isAutoLoaded() 1.0

    This procedure implements TSE 4.4's isAutoLoaded() function for older TSE
    versions. This procedure differs in that here no parameter is allowed,
    so it can only examine the currently running macro's autoload status.
  */
  integer isAutoLoaded_id                    = 0
  string  isAutoLoaded_file_name_chrset [44] = "- !#$%&'()+,.0-9;=@A-Z[]^_`a-z{}~\d127-\d255"
  integer proc isAutoLoaded()
    string  autoload_name [255] = ''
    string  old_wordset    [32] = Set(WordSet, ChrSet(isAutoLoaded_file_name_chrset))
    integer org_id              = GetBufferId()
    integer result              = FALSE
    if isAutoLoaded_id
      GotoBufferId(isAutoLoaded_id)
    else
      autoload_name = SplitPath(CurrMacroFilename(), _NAME_) + ':isAutoLoaded'
      isAutoLoaded_id   = GetBufferId(autoload_name)
      if isAutoLoaded_id
        GotoBufferId(isAutoLoaded_id)
      else
        isAutoLoaded_id = CreateTempBuffer()
        ChangeCurrFilename(autoload_name, _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
      endif
    endif
    LoadBuffer(LoadDir() + 'tseload.dat')
    result = lFind(SplitPath(CurrMacroFilename(), _NAME_), "giw")
    Set(WordSet, old_wordset)
    GotoBufferId(org_id)
    return(result)
  end isAutoLoaded
#endif



// End of compatibility restrictions and mitigations.





// Global constants
#define CCF_OPTIONS     _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
#define BLACK_ON_BLACK  Color(black ON black)

// Global semi-constants  (initialized at start-up)
// string  TSE_COLOR_ATTRS      [32] = ChrSet('')
integer HASHES_ID                 = 0
string  MACRO_NAME [MAXSTRINGLEN] = ''
// string  OWN_COLOR_ATTRS      [32] = ChrSet('')

// Global variables
integer brighten_bg_percentage          = 0
integer brighten_fg_percentage          = 0
integer brightened_buffer_id            = 0
integer brightened_file_line_nr         = 0
integer brightened_screen_row_nr        = 0
integer brightened_window_row_nr        = 0
string  saved_rgb_colors [MAXSTRINGLEN] = ''
integer update_cursor_line              = -1



integer proc write_profile_str(string section_name,
                               string item_name,
                               string item_value)
  integer result = 0
  result = WriteProfileStr(section_name,
                           item_name,
                           item_value)
  if not result
    Alarm()
    Warn('ERROR writing'; MACRO_NAME, "'s configuration to TSE's .ini file.")
  endif
  return(result)
end write_profile_str

proc show_help()
  string  full_macro_source_name [MAXSTRINGLEN] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + '.s'
  string  help_file_name         [MAXSTRINGLEN] = '*** ' + MACRO_NAME + ' Help ***'
  integer hlp_id                                = GetBufferId(help_file_name)
  integer org_id                                = GetBufferId()
  integer tmp_id                                = 0
  if hlp_id
    GotoBufferId(hlp_id)
    UpdateDisplay()
  else
    tmp_id = CreateTempBuffer()
    if LoadBuffer(full_macro_source_name)
      // Separate characters, otherwise my SynCase macro gets confused.
      if lFind('/' + '*', 'g')
        PushBlock()
        UnMarkBlock()
        Right(2)
        MarkChar()
        if not lFind('*' + '/', '')
          EndFile()
        endif
        MarkChar()
        Copy()
        CreateTempBuffer()
        Paste()
        UnMarkBlock()
        PopBlock()
        BegFile()
        ChangeCurrFilename(help_file_name, CCF_OPTIONS)
        BufferType(_NORMAL_)
        FileChanged(FALSE)
        BrowseMode(TRUE)
        UpdateDisplay()
      else
        GotoBufferId(org_id)
        Warn('File "', full_macro_source_name, '" has no multi-line comment block.')
      endif
    else
      GotoBufferId(org_id)
      Warn('File "', full_macro_source_name, '" not found.')
    endif
    AbandonFile(tmp_id)
  endif
end show_help

proc save_then_brighten_rgb_colors()
  integer brighten_percentage = 0
  integer b_color             = 0
  integer color_index         = 0
  integer ground              = 0
  integer g_color             = 0
  integer rgb_color           = 0
  integer r_color             = 0
  saved_rgb_colors = ''
  for ground = _FOREGROUND_ to _BACKGROUND_
    brighten_percentage = iif(ground == _FOREGROUND_,
                              brighten_fg_percentage, brighten_bg_percentage)
    for color_index = 0 to 15
      rgb_color        = GetColorTableValue(ground, color_index)
      saved_rgb_colors = Trim(saved_rgb_colors + ' ' + Str(rgb_color, 16))
      r_color = rgb_color / 65536
      g_color = (rgb_color mod 65536) / 256
      b_color = rgb_color mod 256
      if     brighten_percentage > 0
        r_color = (255 - r_color) * brighten_percentage / 100 + r_color
        g_color = (255 - g_color) * brighten_percentage / 100 + g_color
        b_color = (255 - b_color) * brighten_percentage / 100 + b_color
      elseif brighten_percentage < 0
        r_color = r_color - r_color * Abs(brighten_percentage) / 100
        g_color = g_color - g_color * Abs(brighten_percentage) / 100
        b_color = b_color - b_color * Abs(brighten_percentage) / 100
      endif
      rgb_color = (r_color * 65536) + (g_color * 256) + b_color
      SetColorTableValue(ground, color_index, rgb_color)
    endfor
  endfor
end save_then_brighten_rgb_colors

proc restore_rgb_colors()
  integer color_index   = 0
  integer ground        = 0
  string  rgb_color [6] = ''
  integer token_nr      = 0
  for ground = _FOREGROUND_ to _BACKGROUND_
    for color_index = 0 to 15
      token_nr  = token_nr + 1
      rgb_color = GetToken(saved_rgb_colors, ' ', token_nr)
      SetColorTableValue(ground, color_index, Val(rgb_color, 16))
    endfor
  endfor
end restore_rgb_colors

proc brighten_cursor_line()
  integer old_cursor               = 0
  string  row_attrs [MAXSTRINGLEN] = ''
  string  row_chars [MAXSTRINGLEN] = ''
  integer screen_row_nr            = 0

  old_cursor    = Set(Cursor, OFF)
  screen_row_nr = Query(WindowY1) - 1 + CurrRow()

  // Brighten the current line
  GetStrAttrXY(Query(WindowX1), screen_row_nr, row_chars, row_attrs,
               Query(WindowCols))
  save_then_brighten_rgb_colors()
  Set(Attr, BLACK_ON_BLACK) // Works around the PutStrAttrXY() bug.
  PutStrAttrXY(Query(WindowX1), screen_row_nr, row_chars, '', BLACK_ON_BLACK)
  PutStrAttrXY(Query(WindowX1), screen_row_nr, row_chars, row_attrs)
  restore_rgb_colors()

  if  brightened_window_row_nr <> CurrRow()
  and brightened_file_line_nr  <> CurrLine()
  and brightened_buffer_id     == GetBufferId()
    // Restore the previously brightened line to not-brightened colors.
    GetStrAttrXY(Query(WindowX1), brightened_screen_row_nr, row_chars,
                 row_attrs, Query(WindowCols))
    Set(Attr, BLACK_ON_BLACK) // Works around the PutStrAttrXY() bug.
    PutStrAttrXY(Query(WindowX1), brightened_screen_row_nr, row_chars, '',
                 BLACK_ON_BLACK)
    PutStrAttrXY(Query(WindowX1), brightened_screen_row_nr, row_chars,
                 row_attrs)
  endif

  brightened_screen_row_nr = screen_row_nr
  brightened_window_row_nr = CurrRow()
  brightened_file_line_nr  = CurrLine()
  brightened_buffer_id     = GetBufferId()

  Set(Cursor, old_cursor)

end brighten_cursor_line

proc idle()
  if  update_cursor_line == -1
  and DisplayMode()      == _DISPLAY_HELP_
    update_cursor_line = FALSE
  elseif update_cursor_line
    brighten_cursor_line()
    update_cursor_line = FALSE
  endif
end idle

proc after_command()
  if DisplayMode() <> _DISPLAY_HELP_
    brighten_cursor_line()
    update_cursor_line = TRUE
  endif
end after_command

proc get_and_set_percentage(integer ground)
  string  new_value          [4] = ''
  string  old_value          [4] = ''
  old_value = iif(ground == _FOREGROUND_, Str(brighten_fg_percentage),
                                          Str(brighten_bg_percentage))
  new_value = old_value
  if lReadNumeric(new_value, 4)
    if (Val(new_value) in -100 .. 100)
      if Val(new_value) <> Val(old_value)
        if ground == _FOREGROUND_
          brighten_fg_percentage = Val(new_value)
          Write_Profile_Str(MACRO_NAME + ':Config',
                            'ForegroundPercentage',
                            new_value)
        else
          brighten_bg_percentage = Val(new_value)
          Write_Profile_Str(MACRO_NAME + ':Config',
                            'BackgroundPercentage',
                            new_value)
        endif
      endif
    else
      Alarm()
    endif
  endif
end get_and_set_percentage

menu main_menu()
  title = "Brighten or dim cursor line colors"
  history

  "&Help",
    show_help(),,
    "Open the user documentation"

  "&Foreground percentage   (-100 to 100)  "
    [Str(brighten_fg_percentage):4],
    get_and_set_percentage(_FOREGROUND_),
    _MF_DONT_CLOSE_,
    "Brighten/dim the cursor line's foreground colors by a positive/negative %-tage"

  "&Background percentage   (-100 to 100)  "
    [Str(brighten_bg_percentage):4],
    get_and_set_percentage(_BACKGROUND_),
    _MF_DONT_CLOSE_,
    "Brighten/dim the cursor line's background colors by a positive/negative %-tage"
end main_menu

proc configuration()
  main_menu()
  if  brighten_fg_percentage == 0
  and brighten_bg_percentage == 0
    if isAutoLoaded()
      DelAutoLoadMacro(MACRO_NAME)
    endif
    PurgeMacro(MACRO_NAME)
  else
    if not isAutoLoaded()
      AddAutoLoadMacro(MACRO_NAME)
    endif
  endif
end configuration

proc Main()
  if isGUI()
    configuration()
  endif
end Main

proc WhenPurged()
  if HASHES_ID
    AbandonFile(HASHES_ID)
  endif
end WhenPurged

proc WhenLoaded()
  integer org_id = GetBufferId()
  MACRO_NAME = SplitPath(CurrMacroFilename(), _NAME_)
  if isGUI()
    HASHES_ID = CreateTempBuffer()
    ChangeCurrFilename(MACRO_NAME + ':Hashes', CCF_OPTIONS)
    GotoBufferId(org_id)
    brighten_bg_percentage = GetProfileInt(MACRO_NAME + ':Config',
                                           'BackgroundPercentage',
                                           0)
    brighten_fg_percentage = GetProfileInt(MACRO_NAME + ':Config',
                                           'ForegroundPercentage',
                                           0)
    Hook(_AFTER_COMMAND_, after_command)
    Hook(_IDLE_         , idle)
  else
    Warn(MACRO_NAME, ': This extension only works with the GUI version of TSE.')
    PurgeMacro(MACRO_NAME)
  endif
end WhenLoaded

