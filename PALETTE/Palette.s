/*
  Macro           Palette
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE Pro GUI v4.2 upwards
  Version         v1.1.2   17 Sep 2022

  TSE's color configuration menus refer to 1 fixed palette of 16 fixed
  foreground colors and 16 fixed background colors.

  This extension allows you to make any number of named palettes of 16
  foreground and 16 background colors, which each can be any of 16,777,216
  RGB colors.

  A selected palette is persistent across TSE sessions.


  EXAMPLES

  You can make a palette where the color that is named "red" is a different red
  or another color entirely.
  You can make your own daytime and nighttime palettes, though you would have
  to manually switch between them.
  You can match your TSE border and menu colors with your Windows theme colors.
  You can make your own TSE nature or party color theme.
  You can create an old-style green, amber or black-and-white monitor theme.
  Me, I wanted an off-white background for generating HTML and email with
  the Text2html tool.


  INSTALLATION

  Copy this file to TSE's "mac" folder and compile it there, for example by
  opening it there in TSE and applying the Macro, Compile menu.

  Optional:
  If you install the ColorPicker macro, then this macro will use it when you
  select the internal color picker from the prompt where you change a selected
  color.


  CONFIGURATION

  Execute the extension as a macro,
    either by applying the Macro -> Execute menu and entering "Palette",
    or by adding it to the Potpourri menu and starting it from there,
    or by attaching it to a key combination.

  The color table has 2 positions for each color combination: A left one to
  select the background color and a right one to select the foreground color.

  You can select a specific color with the cursor keys, or you can select the
  background color of a color combination by clicking anywhere in the window,
  which works great with the example text pane on the right.

  After <Enter> you can modify the selected color by entering a new color value
  in any of these case-insensitive example formats:
    Hexadecimal:
      2468AC
      #2468AC
    Decimal:
      36 104 172
      rgb(36 104 172)
  The <Tab> key toggles between hexadecimal en decimal.
  The <Ctrl I> key combination starts the internal color picker, if installed.
  The <Ctrl E> Key combination starts an external online color picker:
    Pick a color and copy/paste its RGB value in any of the above formats.
  A changed, unsaved palette gets a "*" before its name.

  Without further action the colors you changed only remain for the duration
  of the current TSE session.

  Any of the following actions implicitly changes colors across TSE sessions:
    <Ctrl S> saves the current set of colors as a named palette.
    <Ctrl O> opens or deletes a previously saved palette.
    <Ctrl R> resets colors to TSE's default palette.

  You can make TSE unusable, for example by setting all colors to a same value.
  When you can still start TSE and the extension then <Ctrl R> will rescue you.
  Otherwise renaming Palette.ini in TSE's root folder resets the palette too.


  TIPS

  - Color schemes, as defined in TSE's Color Schemes menu, and palettes are
    configured separately.
    If you want to use a certain palette with a certain color scheme, then
    give the palette the same or a similar name.
    For example, besides a color scheme "White by Carlo" I can optionally
    configure a palette "White by Carlo: Off-White".

  - The latest beta version of TSE comes with a menu of predefined palettes,
    which are not persistent across TSE sessions.
    You can "import" those into the Palette extension as follows:
    - Use TSE's menus to select a palette.
    - Start the Palette extension, and save the current colors as a palette.
    The Palette extension does make palettes persistent across TSE sessions.



  TODO
    MUST
    SHOULD
    COULD
    WONT
    - Create my own table cursor, which would be visible for all colors.
      However, I can live with a cursor that is only invisible in a very few
      spots, so I do not see a significant need.
    - Attach a palette to a color scheme, so that if you change a color scheme
      then the palette would change too.
      This is a valid idea, but too much work for too little need and for too
      little estimated usage.


  HISTORY

  v1      18 Sep 2021
    Initial release.

  v1.0.1  19 Sep 2021
    Mitigated:
      A non-block cursor is not visible with a range of colors.
      Changed it to a full block, which is visible with the most colors.

  v1.0.2  20 Sep 2021
    Tweaked the documentation.

  v1.0.3  21 Sep 2021
    Documented and added a run-time warning, that it only works for the GUI
    version of TSE. Added a compile-time warning, that it does not work for
    the Linux version of TSE.

  v1.1    2 Oct 2021
    Added the capability to use the internal ColorPicker macro, if installed.
    The <Ctrl P> key was replaced by a <Ctrl I> and <Ctrl E> key to
    differentiate between using the internal or external color picker.

  v1.1.1   29 Dec 2021
    The "Ctrl" key did not stand out in a submenu helpline.

  v1.1.2   17 Sep 2022
    Fixed incompatibility with TSE's '-i' command line option
    and the TSELOADDIR environment variable.

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
   16-bit versions of TSE are not supported. You need at least TSE v4.2.
#endif

#ifdef EDITOR_VERSION
#else
   Editor Version is older than TSE v3.0. You need at least TSE v4.2.
#endif

#if EDITOR_VERSION < 4200h
   Editor Version is older than TSE v4.2. You need at least TSE v4.2.
#endif



#if EDITOR_VERSION < 4400h
  /*
    isAutoLoaded() 1.0

    This procedure implements TSE 4.4's isAutoLoaded() function for older TSE
    versions. This procedure differs in that here no parameter is allowed,
    so it can only examine the currently running macro's autoload status.
  */
  integer      isAutoLoaded_id                    = 0
  string       isAutoLoaded_file_name_chrset [44] = "- !#$%&'()+,.0-9;=@A-Z[]^_`a-z{}~\d127-\d255"

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



#if EDITOR_VERSION < 4400h
  /*
    StartPgm()  1.0

    Below the line is StartPgm's TSE v4.4 documentation.

    When you make your macro backwards compatible downto TSE v4.0,
    then all four parameters become mandatory for all calls to StartPgm().

    If you do not need the 2nd, 3rd and 4th parameter, then you must use
    their default values: '', '' and _DEFAULT_.

    Tip:
      A practical use for StartPgm is that it lets you "start" a data file too,
      *if* Windows knows what program to run for the file's file type.

      For instance, you can "start" a URL, and StartPgm will start your default
      web browser for that URL.

    ---------------------------------------------------------------------------

    StartPgm

    Runs a program using the Windows ShellExecute function.

    Syntax:     INTEGER StartPgm(STRING pgm_name [, STRING args
                        [, STRING start_dir [, INTEGER startup_flags]]])

                - pgm_name is the name of the program to run.

                - args are optional command line arguments that should be passed
                  to pgm_name.

                - start_dir is an optional starting directory.

                - startup_flags are optional flags that control how pgm_name is
                  started.  Values can be: _START_HIDDEN_, _START_MINIMIZED_,
                  _START_MAXIMIZED_.

    Returns:    Non-zero if successful; zero (FALSE) on failure.

    Notes:      This function is the preferred way to run Win32 GUI programs
                from the editor.

    Examples:

                //Cause the editor to run g32.exe, editing the file "some.file"
                StartPgm("g32.exe", "some.file")

    See Also:   lDos(), Dos(), Shell()
  */
  #define SW_HIDE             0
  #define SW_SHOWNORMAL       1
  #define SW_NORMAL           1
  #define SW_SHOWMINIMIZED    2
  #define SW_SHOWMAXIMIZED    3
  #define SW_MAXIMIZE         3
  #define SW_SHOWNOACTIVATE   4
  #define SW_SHOW             5
  #define SW_MINIMIZE         6
  #define SW_SHOWMINNOACTIVE  7
  #define SW_SHOWNA           8
  #define SW_RESTORE          9
  #define SW_SHOWDEFAULT      10
  #define SW_MAX              10

  dll "<shell32.dll>"
    integer proc ShellExecute(
      integer h,          // handle to parent window
      string op:cstrval,  // specifies operation to perform
      string file:cstrval,// filename string
      string parm:cstrval,// specifies executable-file parameters
      string dir:cstrval, // specifies default directory
      integer show)       // whether file is shown when opened
      :"ShellExecuteA"
  end

  integer proc StartPgm(string  pgm_name,
                        string  args,
                        string  start_dir,
                        integer startup_flags)
    integer result              = FALSE
    integer return_code         = 0
    integer shell_startup_flags = 0
    case startup_flags
      when _DEFAULT_
        shell_startup_flags = SW_SHOWNORMAL
      when _START_HIDDEN_
        shell_startup_flags = SW_HIDE
      when _START_MAXIMIZED_
        shell_startup_flags = SW_SHOWMAXIMIZED
      when _START_MINIMIZED_
        shell_startup_flags = SW_SHOWMINIMIZED
      otherwise
        shell_startup_flags = SW_SHOWNORMAL
    endcase
    return_code = ShellExecute(0, 'open', pgm_name, args, start_dir,
                               shell_startup_flags)
    result = (return_code > 32)
    return(result)
  end StartPgm
#endif



#if EDITOR_VERSION < 4400h
  /*
    StrFind() 1.0

    If you have TSE Pro 4.0 or 4.2, then this proc implements the core of the
    built-in StrFind() function of TSE Pro 4.4.
    The StrFind() function searches a string or pattern inside another string
    and returns the position of the found string or zero.
    It works for strings like the regular Find() function does for files,
    so read the Help for the regular Find() function for the usage of the
    options, but apply these differences while reading:
    - Where the Find() (related) documentation refers to "file" and "line",
      StrFind() refers to "string".
    - The search option "g" ("global", meaning "from the start of the string")
      is implicit and can therefore always be omitted.
    As with the regular Find() function all characters are allowed as options,
    but here only these are acted upon: b, i, w, x, ^, $.

    Notable differences between the procedure below with TSE 4.4's built-in
    function:
    - The third parameter "options" is mandatory.
    - No fourth parameter "start" (actually occurrence: which one to search).
    - No fifth  parameter "len" (returning the length of the found text).

    Technical implementation notes:
    - To be reuseable elsewhere the procedure's source code is written to work
      independently of the rest of the source code.
      That said, it is intentionally not implemented as an include file, both
      for ease of installation and because one day another macro might need its
      omitted parameters, which would be an include file nightmare.
    - A tiny downside of the independent part is, that StrFind's buffer is not
      purged with the macro. To partially compensate for that if the macro is
      restarted, StrFind's possibly pre-existing buffer is searched for.
    - The fourth and fifth parameter are not implemented.
      - The first reason was that I estimated the tiny but actual performance
        gain and the easier function call to be more beneficial than the
        slight chance of a future use of these extra parameters.
      - The main reason turned out to be that in TSE 4.4 the fourth parameter
        "start" is erroneously documented and implemented.
        While this might be corrected in newer versions of TSE, it neither
        makes sense to me to faithfully reproduce these errors here, nor to
        make a correct implementation that will be replaced by an incorrect
        one if you upgrade to TSE 4.4.
  */
  integer strfind_id = 0
  integer proc StrFind(string needle, string haystack, string options)
    integer i                           = 0
    string  option                  [1] = ''
    integer org_id                      = GetBufferId()
    integer result                      = FALSE  // Zero.
    string  strfind_name [MAXSTRINGLEN] = ''
    string  validated_options       [7] = 'g'
    for i = 1 to Length(options)
      option = Lower(SubStr(options, i, 1))
      if      (option in 'b', 'i', 'w', 'x', '^', '$')
      and not Pos(option, validated_options)
        validated_options = validated_options + option
      endif
    endfor
    if strfind_id
      GotoBufferId(strfind_id)
      EmptyBuffer()
    else
      strfind_name = SplitPath(CurrMacroFilename(), _NAME_) + ':StrFind'
      strfind_id   = GetBufferId(strfind_name)
      if strfind_id
        GotoBufferId(strfind_id)
        EmptyBuffer()
      else
        strfind_id = CreateTempBuffer()
        ChangeCurrFilename(strfind_name, _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
      endif
    endif
    InsertText(haystack, _INSERT_)
    if lFind(needle, validated_options)
      result = CurrPos()
    endif
    GotoBufferId(org_id)
    return(result)
  end StrFind
#endif



#if EDITOR_VERSION < 4400h
  /*
    StrReplace() 1.0

    If you have TSE Pro 4.0 or 4.2, then this proc almost completely implements
    the built-in StrReplace() function of TSE Pro 4.4.
    The StrReplace() function replaces a string (pattern) inside a string.
    It works for strings like the Replace() function does for files, so read
    the Help for the Replace() function for the usage of the options, but apply
    these differences while reading:
    - Where Replace() refers to "file" and "line", StrReplace() refers to
      "string".
    - The options "g" ("global", meaning "from the start of the string")
      and "n" ("no questions", meaning "do not ask for confirmation on
      replacements") are implicitly always active, and can therefore be omitted.
    Notable differences between the procedure below with TSE 4.4's built-in
    function are, that here the fourth parameter "options" is mandatory
    and that the fifth parameter "start position" does not exist.
  */
  integer strreplace_id = 0
  string proc StrReplace(string needle, string haystack, string replacer, string options)
    integer i                      = 0
    integer org_id                 = GetBufferId()
    string  result  [MAXSTRINGLEN] = haystack
    string  validated_options [20] = 'gn'
    for i = 1 to Length(options)
      if (Lower(SubStr(options, i, 1)) in '0'..'9', 'b', 'i','w', 'x', '^', '$')
        validated_options = validated_options + SubStr(options, i, 1)
      endif
    endfor
    if strreplace_id == 0
      strreplace_id = CreateTempBuffer()
    else
      GotoBufferId(strreplace_id)
      EmptyBuffer()
    endif
    InsertText(haystack, _INSERT_)
    lReplace(needle, replacer, validated_options)
    result = GetText(1, CurrLineLen())
    GotoBufferId(org_id)
    return(result)
  end StrReplace
#endif



// End of compatibility restrictions and mitigations.





// Global constants
#define CCF_OPTIONS                      _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
string  COLORS                    [46] = 'Black Blue Green Cyan Red Magenta Yellow White'
string  COLOR_PICKER_MACRO_NAME   [11] = 'ColorPicker'
string  COLOR_PICKER_URL          [50] = 'https://www.w3schools.com/colors/colors_picker.asp'
string  CONFIG_SECTION_NAME        [8] = '<Config>'
string  CURRENT_PALETTE_ITEM_NAME [15] = 'Current palette'
string  DEFAULT_COLOR_TABLE_VALUES[90] = '0 80 8000 8080 800000 800080 808000 C0C0C0 808080 FF FF00 FFFF FF0000 FF00FF FFFF00 FFFFFF'
string  DEFAULT_PALETTE_NAME      [32] = '<Default TSE Palette>'
#define GO_END                           9
#define GO_HOME                          0
string  MAIN_HELP_LINE            [81] = ' {F1} Help   {Enter} Change selected color   {Ctrl: O}pen/{S}ave/{R}eset palette '
string  OEM_BOTTOM_LEFT_CORNER     [1] = Chr(192)
string  OEM_BOTTOM_RIGHT_CORNER    [1] = Chr(217)
string  OEM_HORIZONTAL_LINE        [1] = Chr(196)
string  OEM_TOP_LEFT_CORNER        [1] = Chr(218)
string  OEM_TOP_RIGHT_CORNER       [1] = Chr(191)
string  OEM_VERTICAL_LINE          [1] = Chr(179)
#define TOOL_COLOR                       Color(bright white ON black)

// Global semi-constants   ("Constants" initialized at start-up.)
string  MY_MACRO_NAME [MAXSTRINGLEN] = ''
string  PROFILE_NAME  [MAXSTRINGLEN] = ''

// Global variables
string  current_palette    [32] = ''
integer palette_is_changed      = FALSE
integer pick_a_color            = FALSE
integer show_profile_error      = TRUE
integer table_x                 = 2
integer table_y                 = 2
integer toggle_hex_decimal      = FALSE
integer deleted_picked_profile  = FALSE



proc write_profile_error()
  // When WriteProfileStr() returns an error it is usually because of a lack of
  // write permission, causing all WriteProfileStr() to fail.
  // Because WriteProfileStr() is also called in a loop, show_profile_error is
  // used to show the looped error only once.
  // Note to self: This could use a prettier solution.
  if show_profile_error
    Alarm()
    Warn('Cannot write to profile "', PROFILE_NAME, '".')
    show_profile_error = FALSE
  endif
end write_profile_error

integer proc remove_profile_section(string section, string profile_name_from)
  integer result = FALSE
  result = RemoveProfileSection(section, profile_name_from)
  if not result
    write_profile_error()
  endif
  return(result)
end remove_profile_section

integer proc write_profile_str(string section_name,
                               string item_name,
                               string item_value,
                               string profile_name_to)
  integer result = FALSE
  result = WriteProfileStr(section_name,
                           item_name,
                           item_value,
                           profile_name_to)
  if not result
    write_profile_error()
  endif
  return(result)
end write_profile_str

proc show_help()
  string  full_macro_source_name [MAXSTRINGLEN] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + '.s'
  string  help_file_name         [MAXSTRINGLEN] = '*** ' + MY_MACRO_NAME + ' Help ***'
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
        // Extra command for this specific tool:
        PushKey(<Escape>)
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

string proc ground_to_name(integer ground)
  string ground_name [10] = ''
  ground_name = iif(ground == _FOREGROUND_, 'Foreground', 'Background')
  return(ground_name)
end ground_to_name

integer proc get_key()
  integer cursor_timer            = 0
  integer old_InsertCursorSize    = Query(InsertCursorSize   )
  integer old_OverwriteCursorSize = Query(OverwriteCursorSize)
  integer wait_period             = 2   // In 1/18ths of a second.

  // Some cursors are less visible with some colors. The full block cursor
  // turns out to be the best visible one with most colors.
  old_InsertCursorSize    = Set(InsertCursorSize   , 8)
  old_OverwriteCursorSize = Set(OverwriteCursorSize, 8)

  // The elaborate loop is a work-around to keep the cursor blinking,
  // which otherwise would stop after about 5 seconds.
  while not KeyPressed()
    cursor_timer = cursor_timer + wait_period
    if cursor_timer >= 90   // 5 seconds
      if Query(Cursor)
        Set(Cursor, OFF)    // This trick restarts cursor blinking
        Set(Cursor, ON)
      endif
      cursor_timer = 0
    endif
    Delay(wait_period)
  endwhile

  Set(InsertCursorSize   , old_InsertCursorSize   )
  Set(OverwriteCursorSize, old_OverwriteCursorSize)
  return(GetKey())
end get_key

proc get_selected_color_references(var integer ground,
                                   var string  ground_name,
                                   var integer background_index,
                                   var integer foreground_index,
                                   var integer selected_index)
  background_index = (table_x - 2)  /  2
  foreground_index =  table_y - 2
  ground           = iif((table_x - 1) mod 2, _BACKGROUND_, _FOREGROUND_)
  ground_name      = ground_to_name(ground)
  selected_index   = iif(ground == _BACKGROUND_,
                         background_index, foreground_index)
end get_selected_color_references

proc redraw_table_title()
  integer name_start_pos = 0
  PutOemStrXY(1, 1, Format(        OEM_TOP_LEFT_CORNER), TOOL_COLOR)
  PutOemStrXY(2, 1, Format('': 32: OEM_HORIZONTAL_LINE), TOOL_COLOR)
  name_start_pos = 2 + (32 - Length(current_palette)) / 2   // Center the name.
  if palette_is_changed
    PutStrAttrXY(name_start_pos - 1, 1, '*'            , '', TOOL_COLOR)
  endif
  if current_palette <> ''
    PutStrAttrXY(name_start_pos    , 1, current_palette, '', TOOL_COLOR)
  endif
end redraw_table_title

proc open_and_draw_window()
  integer color_background_index = 0
  integer border_row             = 0
  integer color_combined_index   = 0
  integer color_foreground_index = 0
  string  table_column       [2] = ''
  PopWinOpen(1, 1, Query(ScreenCols), Query(ScreenRows), 1, 'Palette',
             TOOL_COLOR)
  WindowFooter(MAIN_HELP_LINE)
  Set(Attr, TOOL_COLOR)
  ClrScr()
  PutOemStrXY(1, 1,
              Format(OEM_TOP_LEFT_CORNER,
                     '': 32: OEM_HORIZONTAL_LINE,
                     OEM_TOP_RIGHT_CORNER),
              TOOL_COLOR)
  for border_row = 2 to 17
    PutOemStrXY( 1, border_row, OEM_VERTICAL_LINE, TOOL_COLOR)
    PutOemStrXY(34, border_row, OEM_VERTICAL_LINE, TOOL_COLOR)
  endfor
  PutOemStrXY(1, 18,
              Format(OEM_BOTTOM_LEFT_CORNER,
                     '':32:OEM_HORIZONTAL_LINE,
                     OEM_BOTTOM_RIGHT_CORNER),
              TOOL_COLOR)
  redraw_table_title()
  // The Set(Attr, ...) compensates for the known PutStrAttrXY() bug,
  // that for Color(black on black) it displays the Query(Attr) color instead.
  Set(Attr, Color(black ON black))
  for color_background_index = 0 to 15
    for color_foreground_index = 0 to 15
      color_combined_index = color_background_index * 16 + color_foreground_index
      table_column         = Format(color_combined_index: 2: '0': 16)
      PutStrAttrXY(2 + color_background_index * 2,
                   2 + color_foreground_index,
                   table_column,
                   '',
                   color_combined_index)
    endfor
  endfor

  PutStrAttrXY(38,  2, 'Text'           , '', Query(TextAttr))
  PutStrAttrXY(43,  2, 'Block'          , '', Query(BlockAttr))
  PutStrAttrXY(49,  2, 'CursorInBlock'  , '', Query(CursorInBlockAttr))
  PutStrAttrXY(63,  2, 'Cursor'         , '', Query(CursorAttr))
  PutStrAttrXY(70,  2, 'HiLite'         , '', Query(HiliteAttr))
  PutStrAttrXY(38,  3, 'MenuText'       , '', Query(MenuTextAttr))
  PutStrAttrXY(47,  3, 'MenuTextLtr'    , '', Query(MenuTextLtrAttr))
  PutStrAttrXY(59,  3, 'MenuGray'       , '', Query(MenuGrayAttr))
  PutStrAttrXY(68,  3, 'MenuSelect'     , '', Query(MenuSelectAttr))
  PutStrAttrXY(38,  4, 'MenuSelectGray' , '', Query(MenuSelectGrayAttr))
  PutStrAttrXY(53,  4, 'MenuBorder'     , '', Query(MenuBorderAttr))
  PutStrAttrXY(64,  4, 'MenuSelectLtr'  , '', Query(MenuSelectLtrAttr))
  PutStrAttrXY(38,  5, 'CurrWinBorder'  , '', Query(CurrWinBorderAttr))
  PutStrAttrXY(52,  5, 'OtherWinBorder' , '', Query(OtherWinBorderAttr))
  PutStrAttrXY(67,  5, 'EOFMarker'      , '', Query(EofMarkerAttr))
  PutStrAttrXY(38,  6, 'StatusLine'     , '', Query(StatusLineAttr))
  PutStrAttrXY(49,  6, 'HelpText'       , '', Query(HelpTextAttr))
  PutStrAttrXY(58,  6, 'HelpBold'       , '', Query(HelpBoldAttr))
#if EDITOR_VERSION >= 4400h
  PutStrAttrXY(67,  6, 'LineNumbers'    , '', Query(LineNumbersAttr))
#endif
  PutStrAttrXY(38,  7, 'HelpItalics'    , '', Query(HelpItalicsAttr))
  PutStrAttrXY(50,  7, 'HelpInfo'       , '', Query(HelpInfoAttr))
  PutStrAttrXY(59,  7, 'HelpLink'       , '', Query(HelpLinkAttr))
  PutStrAttrXY(68,  7, 'HelpSelect'     , '', Query(HelpSelectAttr))
  PutStrAttrXY(38,  8, 'Directive1'     , '', Query(Directive1Attr))
  PutStrAttrXY(49,  8, 'Directive2'     , '', Query(Directive2Attr))
  PutStrAttrXY(60,  8, 'Directive3'     , '', Query(Directive3Attr))
  PutStrAttrXY(71,  8, 'Msg'            , '', Query(MsgAttr))
  PutStrAttrXY(38,  9, 'MultiLnDlmt1'   , '', Query(MultiLnDlmt1Attr))
  PutStrAttrXY(51,  9, 'MultiLnDlmt2'   , '', Query(MultiLnDlmt2Attr))
  PutStrAttrXY(64,  9, 'MultiLnDlmt3'   , '', Query(MultiLnDlmt3Attr))
  PutStrAttrXY(38, 10, 'SingleLnDlmt1'  , '', Query(SingleLnDlmt1Attr))
  PutStrAttrXY(52, 10, 'SingleLnDlmt2'  , '', Query(SingleLnDlmt2Attr))
  PutStrAttrXY(66, 10, 'SingleLnDlmt3'  , '', Query(SingleLnDlmt3Attr))
  PutStrAttrXY(38, 11, 'ToEOL1'         , '', Query(ToEol1Attr))
  PutStrAttrXY(45, 11, 'ToEOL2'         , '', Query(ToEol2Attr))
  PutStrAttrXY(52, 11, 'ToEOL3'         , '', Query(ToEol3Attr))
  PutStrAttrXY(59, 11, 'Quote1'         , '', Query(Quote1Attr))
  PutStrAttrXY(66, 11, 'Quote2'         , '', Query(Quote2Attr))
  PutStrAttrXY(73, 11, 'Quote3'         , '', Query(Quote3Attr))
  PutStrAttrXY(38, 12, 'Number'         , '', Query(NumberAttr))
  PutStrAttrXY(45, 12, 'IncompleteQuote', '', Query(IncompleteQuoteAttr))
  PutStrAttrXY(38, 13, 'KeyWords1'      , '', Query(Keywords1Attr))
  PutStrAttrXY(48, 13, 'KeyWords2'      , '', Query(Keywords2Attr))
  PutStrAttrXY(58, 13, 'KeyWords3'      , '', Query(Keywords3Attr))
  PutStrAttrXY(38, 14, 'KeyWords4'      , '', Query(Keywords4Attr))
  PutStrAttrXY(48, 14, 'KeyWords5'      , '', Query(Keywords5Attr))
  PutStrAttrXY(58, 14, 'KeyWords6'      , '', Query(Keywords6Attr))
  PutStrAttrXY(38, 15, 'KeyWords7'      , '', Query(Keywords7Attr))
  PutStrAttrXY(48, 15, 'KeyWords8'      , '', Query(Keywords8Attr))
  PutStrAttrXY(58, 15, 'KeyWords9'      , '', Query(Keywords9Attr))

  PutStrAttrXY(1,
               Query(PopWinRows),
               'You can click anywhere to select a color.',
               '',
               TOOL_COLOR)
  GotoXY(table_x, table_y)
end open_and_draw_window

proc draw_current_values()
  integer background_index      = 0
  string  color_name       [33] = 'Intense Bright Magenta on Magenta'
  string  color_spec       [80] = ''
  integer color_value           = 0
  integer foreground_index      = 0
  integer ground                = 0
  string  ground_name      [10] = ''
  integer selected_index        = 0

  get_selected_color_references(ground, ground_name, background_index,
                                foreground_index, selected_index)

  color_name = iif(background_index > 7, 'Intense ', '')
             + iif(foreground_index > 7, 'Bright ' , '')
             + GetToken(colors, ' ', (foreground_index mod 8) + 1)
             + ' on '
             + GetToken(colors, ' ', (background_index mod 8) + 1)
  PutStrAttrXY(1, 19, Format(color_name:-33), '', TOOL_COLOR)

  color_value = GetColorTableValue(ground, selected_index)

  color_spec = Format(ground_name,
                      ' color ',
                      selected_index: 1: ' ': 16,
                      ' (',
                      selected_index: 2,
                      ') has RGB value ',
                      color_value: 6: '0': 16,
                      ' (',
                        color_value / 65536         : 3,
                      ( color_value /   256) mod 256: 4,
                        color_value          mod 256: 4,
                      ') in hex (decimal).')
  PutStrAttrXY(1, 20, color_spec, '', TOOL_COLOR)
end draw_current_values

proc close_window()
  PopWinClose()
end close_window

proc move_in_table(integer direction)
  case direction
    when _RIGHT_
      table_x = iif(table_x == 33,  2, table_x + 1)
    when _LEFT_
      table_x = iif(table_x ==  2, 33, table_x - 1)
    when _DOWN_
      table_y = iif(table_y == 17,  2, table_y + 1)
    when _UP_
      table_y = iif(table_y ==  2, 17, table_y - 1)
    when GO_HOME
      table_x = 2
      table_y = 2
    when GO_END
      table_x = 33
      table_y = 17
  endcase
  GotoXY(table_x, table_y)
end move_in_table

Keydef prompt_keys
  <Tab>    toggle_hex_decimal = TRUE PushKey(<Enter>)
  <Ctrl I> pick_a_color       = TRUE PushKey(<Enter>)
  <Ctrl E> StartPgm(COLOR_PICKER_URL, '', '', _DEFAULT_)
end prompt_keys

proc prompt_cleanup()
  Disable(prompt_keys)
end prompt_cleanup

proc prompt_startup()
  Enable(prompt_keys)
  WindowFooter("{Tab} Toggle hex/decimal   {Ctrl}: Use {I}nternal/{E}ternal color picker")
  Hook(_PROMPT_CLEANUP_, prompt_cleanup)
end prompt_startup

// This work-around trick refreshes the screen where UpdateDisplay() will not.
proc update_display()
  #if EDITOR_VERSION >= 4400h
    // Use this trick for TSE v4.4 upwards. Works seamlessly.
    Set(Transparency, Query(Transparency))
  #else
    // Use this trick for TSE v4.2. Causes a tiny screen flicker.
    PopWinOpen(1, 1, Query(PopWinCols), Query(PopWinRows), 0, '', TOOL_COLOR)
    ClrScr()
    PopWinClose()
  #endif
end update_display

integer proc validate_rgb(string rgb_in, var integer rgb_out)
  integer i           = 1
  integer invalid_pos = TRUE
  integer num_numbers = TRUE
  integer ok          = TRUE
  string  rgb    [78] = Lower(RTrim(rgb_in))
  if     Pos('rgba', rgb)
    Alarm()
    Warn('TSE is incompatible with RGBA. Use RGB instead.')
    ok = FALSE
  elseif Pos('hsl' , rgb)
  or     Pos('%'   , rgb)
    Alarm()
    Warn('You cannot use HSL or percentages.')
    ok = FALSE
  else
    rgb = RTrim(StrReplace('rgb', rgb, '   ', ''))
    rgb = RTrim(StrReplace('('  , rgb, ' '  , ''))
    rgb = RTrim(StrReplace(')'  , rgb, ' '  , ''))
    rgb = RTrim(StrReplace('#'  , rgb, ' '  , ''))
    rgb = RTrim(StrReplace(','  , rgb, ' '  , ''))
    invalid_pos = StrFind('[~ 0-9a-f]', rgb, 'x')
    if invalid_pos
      Alarm()
      Warn('Illegal character "', rgb_in[invalid_pos], '" in "', rgb_in, '".')
      ok = FALSE
    else
      num_numbers = NumTokens(rgb, ' ')
      if     num_numbers == 1
        if Length(GetToken(rgb, ' ', 1)) > 6
          Alarm()
          Warn('Hex RGB number has more than 6 digits. (Note: TSE is incompatible with RGBA.)')
          ok = FALSE
        else
          rgb_out = Val(rgb, 16)
        endif
      elseif num_numbers == 3
        invalid_pos = StrFind('[~ 0-9]', rgb, 'x')
        if invalid_pos
          Alarm()
          Warn('Illegal charcter "', rgb_in[invalid_pos],
               '". if you supply 3 numbers, then they must be decimal.')
          ok = FALSE
        else
          while ok
          and i <= 3
            if Length(GetToken(rgb, ' ', i)) > 3
              Alarm()
              Warn('Decimal number "', GetToken(rgb, ' ', i),
                   '" has more than 3 digits.')
              ok = FALSE
            elseif Val(GetToken(rgb, ' ', i)) > 255
              Alarm()
              Warn('Decimal number "', GetToken(rgb, ' ', i),
                   '" is greater than 255.')
              ok = FALSE
            endif
            i = i + 1
          endwhile
          if ok
            rgb_out = Val(GetToken(rgb, ' ', 1)) * 65536
                    + Val(GetToken(rgb, ' ', 2)) * 256
                    + Val(GetToken(rgb, ' ', 3))
          endif
        endif
      else
        Alarm()
        Warn('There are'; num_numbers;
             'numbers instead of 1 hex number or 3 decimal numbers.')
        ok = FALSE
      endif
    endif
  endif
  return(ok)
end validate_rgb

string proc call_colorpicker()
  integer old_MsgLevel = Set(MsgLevel, _NONE_)
  string  result [MAXSTRINGLEN] = ''
  if LoadMacro(COLOR_PICKER_MACRO_NAME)
    Set(MsgLevel, old_MsgLevel)
    // The ColorPicker gave an error that it cannot not be called from a
    // non-edit state. I took that as "not from a TSE-opened window".
    // Let us see if this work-around works.
    close_window()
    ExecMacro(COLOR_PICKER_MACRO_NAME + ' get')
    result = Query(MacroCmdLine)
    open_and_draw_window()
    draw_current_values()
  else
    Set(MsgLevel, old_MsgLevel)
    Warn('You do not have the ColorPicker macro installed.')
  endif
  return(result)
end call_colorpicker

proc change_current_color_value()
  integer background_index    = 0
  integer foreground_index    = 0
  integer ground              = 0
  string  ground_name    [10] = ''
  string  picked_color    [6] = ''
  integer repeat_prompt       = FALSE
  string  request        [78] = ''
  string  response       [78] = ''
  integer rgb_out             = 0
  integer selected_index      = 0

  get_selected_color_references(ground, ground_name, background_index,
                                foreground_index, selected_index)
  request  = Format('Change';
                    Lower(ground_name),
                    ' color';
                    selected_index: 1: ' ': 16,
                    ' (',
                    selected_index,
                    ').      You can copy/paste common RGB notations. ')
  response = Format(GetColorTableValue(ground, selected_index): 6: '0': 16)
  Hook(_PROMPT_STARTUP_, prompt_startup)
  repeat
    toggle_hex_decimal = FALSE
    repeat_prompt      = FALSE
    if Ask(request, response)
      if pick_a_color
        picked_color = call_colorpicker()
        if picked_color <> ''
          response     = picked_color
          picked_color = ''
        endif
        pick_a_color = FALSE
      endif
      if validate_rgb(response, rgb_out)
        if toggle_hex_decimal
          if     NumTokens(response, ' ') == 1
            response = Format(   rgb_out / 65536;
                               ( rgb_out /   256) mod 256;
                                 rgb_out          mod 256)
          else
            response = Str(rgb_out, 16)
          endif
          repeat_prompt = TRUE
        else
          SetColorTableValue(ground, selected_index, rgb_out)
          if not palette_is_changed
            palette_is_changed = TRUE
            redraw_table_title()
          endif
          update_display()
        endif
      else
        repeat_prompt = TRUE
      endif
    endif
  until not repeat_prompt
  UnHook(prompt_startup)
end change_current_color_value

proc save_palette()
  integer color_table_value         = 0
  string  color_table_value_hex [6] = ''
  integer ground                    = 0
  string  ground_name          [10] = ''
  integer index                     = 0
  integer ok                        = TRUE
  string  response             [32] = ''
  if current_palette <> DEFAULT_PALETTE_NAME
    response = current_palette
  endif
  if  Ask('Save palette as:', response)
  and Trim(response) <> ''
    response = Trim(response)
    if EquiStr(response, CONFIG_SECTION_NAME)
    or EquiStr(response, DEFAULT_PALETTE_NAME)
      Alarm()
      Warn('You cannot save a palette with reserved name "', response, '".')
    else
      if  response <> current_palette
      and LoadProfileSection(response, PROFILE_NAME)
        ok = FALSE
        Alarm()
        if YesNo('Palette "' + response + '" already exists. Overwrite?') == 1
          ok = TRUE
        endif
      endif
      if ok
        current_palette    = response
        show_profile_error = TRUE
        write_profile_str(CONFIG_SECTION_NAME,
                          CURRENT_PALETTE_ITEM_NAME,
                          current_palette,
                          PROFILE_NAME)
        for ground = _FOREGROUND_ to _BACKGROUND_
          ground_name = ground_to_name(ground)
          for index = 0 to 15
            color_table_value     = GetColorTableValue(ground, index)
            color_table_value_hex = Format(color_table_value: 6: '0': 16)
            write_profile_str(current_palette,
                              ground_name + ' ' + Str(index, 16),
                              color_table_value_hex,
                              PROFILE_NAME)
          endfor
        endfor
        palette_is_changed = FALSE
        redraw_table_title()
        update_display()
      endif
    endif
  endif
end save_palette

proc delete_picked_palette()
  string palette_name [MAXSTRINGLEN] = GetText(1, MAXSTRINGLEN)
  if palette_name <> DEFAULT_PALETTE_NAME
    show_profile_error = TRUE
    remove_profile_section(GetText(1, MAXSTRINGLEN), PROFILE_NAME)
    if CurrLine() == NumLines()
      KillLine()
      BegFile()
      EndFile()
    else
      KillLine()
    endif
  endif
  deleted_picked_profile = TRUE
  PushKey(<Escape>)
end delete_picked_palette

Keydef list_keys
  <Del>     delete_picked_palette()
  <GreyDel> delete_picked_palette()
end list_keys

proc list_cleanup()
  Disable(list_keys)
end list_cleanup

proc list_startup()
  Enable(list_keys)
  ListFooter("{Del} Delete palette")
  Hook(_LIST_CLEANUP_, list_cleanup)
end list_startup

string proc pick_palette(string list_title, integer include_default_palette)
  integer list_id               = 0
  string  palette_name     [32] = ''
  string  selected_palette [32] = ''
  PushLocation()
  list_id = CreateTempBuffer()
  if include_default_palette
    AddLine(DEFAULT_PALETTE_NAME)
  endif
  if LoadProfileSectionNames(PROFILE_NAME)
    while GetNextProfileSectionName(palette_name)
      if palette_name <> CONFIG_SECTION_NAME
        AddLine(palette_name)
      endif
    endwhile
  endif
  BegFile()
  Hook(_LIST_STARTUP_, list_startup)
  repeat
    deleted_picked_profile = FALSE
    if List(list_title, LongestLineInBuffer())
      selected_palette = Trim(GetText(1, 32))
    endif
  until not deleted_picked_profile
  UnHook(list_startup)
  PopLocation()
  AbandonFile(list_id)
  return(selected_palette)
end pick_palette

proc set_default_palette()
  integer color_table_value         = 0
  string  color_table_value_hex [6] = ''
  integer ground                    = 0
  integer index                     = 0
  current_palette    = DEFAULT_PALETTE_NAME
  show_profile_error = TRUE
  write_profile_str(CONFIG_SECTION_NAME,
                    CURRENT_PALETTE_ITEM_NAME,
                    current_palette,
                    PROFILE_NAME)
  for ground = _FOREGROUND_ to _BACKGROUND_
    for index = 0 to 15
      color_table_value_hex = GetToken(DEFAULT_COLOR_TABLE_VALUES,
                                       ' ', index + 1)
      color_table_value     = Val(color_table_value_hex, 16)
      SetColorTableValue(ground, index, color_table_value)
    endfor
  endfor
  palette_is_changed = FALSE
end set_default_palette

proc reset_palette()
  set_default_palette()
  redraw_table_title()
  update_display()
end reset_palette

proc load_palette(string palette_name)
  string  color_table_value_hex [6] = ''
  integer color_table_value         = 0
  integer ground                    = 0
  string  ground_name          [10] = ''
  integer index                     = 0
  if LoadProfileSection(palette_name, PROFILE_NAME)
    for ground = _FOREGROUND_ to _BACKGROUND_
      ground_name = ground_to_name(ground)
      for index = 0 to 15
        color_table_value_hex = GetProfileStr(palette_name,
                                ground_name + ' ' + Str(index, 16),
                                '',
                                PROFILE_NAME)
        color_table_value     = Val(color_table_value_hex, 16)
        SetColorTableValue(ground, index, color_table_value)
      endfor
    endfor
    palette_is_changed = FALSE
  endif
end load_palette

proc open_palette()
  string new_palette [32] = ''
  new_palette = pick_palette('Select a palette', TRUE)
  if new_palette <> ''
    if EquiStr(new_palette, DEFAULT_PALETTE_NAME)
      set_default_palette()
    else
      current_palette    = new_palette
      show_profile_error = TRUE
      write_profile_str(CONFIG_SECTION_NAME,
                        CURRENT_PALETTE_ITEM_NAME,
                        current_palette,
                        PROFILE_NAME)
      load_palette(current_palette)
    endif
    redraw_table_title()
    update_display()
  endif
end open_palette

integer proc next_action()
  string  a          [1] = ''
  integer do_next_action = TRUE
  integer last_key       = 0
  string  s          [1] = ''
  integer selected_attr  = 0
  last_key = get_key()
  case last_key
    when <Escape>
      do_next_action = FALSE
    when <CursorRight>, <GreyCursorRight>
      move_in_table(_RIGHT_)
    when <CursorLeft>, <GreyCursorLeft>
      move_in_table(_LEFT_)
    when <CursorDown>, <GreyCursorDown>
      move_in_table(_DOWN_)
    when <CursorUp>, <GreyCursorUp>
      move_in_table(_UP_)
    when <Home>, <GreyHome>
      move_in_table(GO_HOME)
    when <end>, <GreyEnd>
      move_in_table(GO_END)
    when <F1>
      show_help()
    when <Enter>
      change_current_color_value()
    when <Ctrl O>
      open_palette()
    when <Ctrl S>
      save_palette()
    when <Ctrl R>
      reset_palette()
    when <LeftBtn>
      GetStrAttrXY(Query(MouseX) - 1, Query(MouseY) - 1, s, a, 1)
      selected_attr = Asc(a)
      table_x       = 2 + (selected_attr  /  16) * 2
      table_y       = 2 +  selected_attr mod 16
      GotoXY(table_x, table_y)
  endcase
  return(do_next_action)
end next_action

proc Main()
  if isGUI()
    open_and_draw_window()
    repeat
      draw_current_values()
    until not next_action()
    close_window()

    if (current_palette in '', DEFAULT_PALETTE_NAME)
      if isAutoLoaded()
        DelAutoLoadMacro(MY_MACRO_NAME)
      endif
      PurgeMacro(MY_MACRO_NAME)
    else
      if not isAutoLoaded()
        AddAutoLoadMacro(MY_MACRO_NAME)
      endif
    endif
  else
    Warn('This extension only works with the GUI version of TSE.')
  endif
end Main

proc WhenLoaded()
  MY_MACRO_NAME = SplitPath(CurrMacroFilename(), _NAME_)
  if isGUI()
    PROFILE_NAME    = LoadDir() + MY_MACRO_NAME + '.ini'
    current_palette = GetProfileStr(CONFIG_SECTION_NAME,
                                    CURRENT_PALETTE_ITEM_NAME,
                                    DEFAULT_PALETTE_NAME,
                                    PROFILE_NAME)
    if not (current_palette in '', DEFAULT_PALETTE_NAME)
      load_palette(current_palette)
    endif
  else
    PurgeMacro(MY_MACRO_NAME)
  endif
end WhenLoaded

