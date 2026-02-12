/*
  Macro           ColorPicker
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE Pro GUI v4.2 upwards
  Version         v1.0.1

  This tool lets you or your macro pick a color by clicking in a palette of
  colors.

  Because of how TSE works, the tool needs to create the palette on a virtual
  screen that has a lower resolution than your physical screen.

  The tool communicates through the title bar.

  This tool is very slow to start up. If that is not an acceptable price for
  its awesomeness, then you might want to use an online color picker instead.


  INSTALLATION

  Copy this file to TSE's "mac" folder and compile it there, for example by
  opening it there in TSE and applying the Macro, Compile menu.


  USE

  If you just want to see it in action then execute "ColorPicker" as a macro.
  When you click on a color you get a message which RGB color you picked.

  If you are a macro programmer and want to use ColorPicker from your own
  macro, then execute "ColorPicker get".
  This skips giving a message to the user and returns the picked color or an
  empty string in Query(MacroCmdLine).

  During execution ColorPicker communicates with the user through the window
  title bar.

  During start-up ColorPicker shows the virtual screen resolution it was able
  to attain.

  After start-up ColorPicker shows the mouse position in the virtual screen
  and the color that will be picked if the user clicks a mouse butten.


  HISTORY

  v1      25 Sep 2021
    Initial release.

  v1.0.1  20 Sep 2021
    Only tweaked the documentation.
*/





/*
  T E C H I C A L   B A C K G R O U N D   I N F O


  MESSY CODE

  Because of other priorities I did not clean up the code.
  Especially but not limited to: variables may have misleading names.



  THE VIRTUAL SCREEN

  TSE implements colors as RGB values.
  This means a theoretical limitation of 256 * 256 * 256 = 16,777,216 colors.
  As distributed the editor itself uses only 16 of these colors as the text's
  background and foreground colors, but its programming language allows us to
  access the other colors and in specific circumstances show many of them
  concurrently.
  TSE can only show and color text foreground and background.
  So to show as many colors as possible, as many characters as possible need to
  be shown:
    The TSE window is maximized to fit more characters.
    The font size is decreased as much as possible to fit more characters.
  The characters become illegibly small, and effectively become pixels.
  The end result is a virtual screen with a resolution of N * M pixels.
  The virtual screen's resolution depends on each individual computer's and
  monitor's capabilities and settings.
  At start-up the color picker will show the virtual screen's resolution in the
  title bar.
  On my cheap monitor my virtual screen shows 768 * 267 pixels.


  THE CUBE MODEL

  The tool ideally needs to show an evenly distributed subset of colors.
  TSE uses RGB color values: a color is a combination of a red value, a green
  value and a blue value, where each value can be 0 to 255.
  A practical way to think of an evenly distributed set of possible RGB values
  is as a cube with a red, green and blue axis, where each coordinate in the
  cube is colored according to the corresponding color values on the three
  axes.
  The full set of 256 * 256 * 256 colors cannot simultaneously be shown
  together, so a subset needs to be shown.
  The cube model:
    We can display an evenly distributed cube of colors by displaying the third
    dimension of the cube as square slices, where the number of slices equals
    the length of a cube side.
  Such a cube implies that it needs sides with a whole number as length, say L,
  of which the square root must also be a whole number, say N, because we need
  to show L slices, and two-dimensionally that can screen-real-estate-wise
  most efficiently be done as N by N slices.
  Refrased, such a cube of evenly distributed colors can be shown as N by N
  squares of L by L colors.
  For example,
    2 by 2 squares of each 4 by 4 colors =
    4 squares of 4 * 4 colors =
    4 * 4 * 4 colors =
    64 colors.
  For example,
    3 by 3 squares of each 9 by 9 colors =
    9 squares of 9 * 9 colors =
    9 * 9 * 9 colors =
    729 colors.
  For example
    4 by 4 squares of each 16 by 16 colors =
    16 squares of 16 * 16 colors =
    16 * 16 * 16 colors =
    4096 colors.
  For example
    5 by 5 squares of each 25 by 25 colors =
    25 squares of 25 * 25 colors =
    25 * 25 * 25 colors =
    15625 colors.

  We are limited by the resolution of the virtual screen:
  Only cubes can be shown for which the square root of the side length is a
  whole number, say N, and N * N * N is smaller than each screen axis.
  For example,
    For N = 4 all screen axes need to be able to show 4 * 4 * 4 =  64 pixels.
    for N = 5 all screen axes need to be able to show 5 * 5 * 5 = 625 pixels.
  For example,
    On my virtual screen with a resolution of 768 * 267 pixels, N cannot be
    larger than 4, which still allows a model cube to display 4096 colors.


  THE RELAXED CUBE MODEL

  The great property of the cube model is, that it gives us an as evenly
  distributed set of colors as possible.

  But having reached that goal, it is quite possible that inside each square
  more than one pixel is available for a specific color. It makes sense to
  inside each square redistribute pixel colors to one color per pixel.

  For example, when a cube with side length 16 is displayed on a virtual screen
  of 261 pixels high, squares are 65 or 66 pixels high. It makes sense to
  vertically display 65 or 66 different colors instead of just 16.

  And when a screen is wider than it is high, it makes sense to extend our cube
  to an imagined bar of visible rectangle slices to get even more pixels and
  likewise display even more different colors.

  For example, when a cube with side length 16 is displayed on a virtual screen
  of 768 pixels wide, squares are 192 pixels wide. It makes sense to
  horizontally display 192 different colors instead of just 16.

  Note that the imagined third dimension, which in the example is represented
  by 16 slices, is still only contributing 16 different colors for that
  dimension.

  In the example we end up with 16 rectangles of 65 * 192 different colors
  which is 199,680 colors, so why start from a cube model?
  My best answer is, that we need a three dimensional representation that at
  all levels can only use whole numbers, and that if our goal is an as even as
  possible distribution of each dimension's color values, then the cube
  representation gives us a grip on what the least bad solution might be.

  Note that in the relaxed cube model there are now theoretically 6 choices
  for which of the colors red, green and blue to use the most and the least
  shades. In practice I just picked one.

  And now I will contradict myself with opposing views.
  Having created this relaxed cube model I find it has drawbacks.
  For one, to pick pure white (RGB color FFFFFF) you have to click one specific
  pixel at the bottom right of the virtual screen, which is hard.
  Likewise, it is hard to get an impression of a color to pick when it is
  surrounded by shades of itself: perhaps the non-relaxed cube model or another
  model entirely might be better after all.
  So while I am pleased having created a technically well founded model, I am
  no longer sure it is the model for the best user experience.


  SOME GENERAL TEST RESULTS

  ColorTableValue can be used to draw 16,777,216 background colors at once
  by not refreshing the screen.

  In a spot where you drew a color, PutStrAttrXY() cannot redraw a new color
  by using the same color attribute. It just sees the same color attribute and
  decides it has nothing to do.

  My cheap monitor shows a surface of one color as stripy, until I redraw
  another attribute at position (2, 1). Position (1, 1) does not work for this.
  Maybe there are other situations where a redraw elsewhere on column 1 is
  necessary too.
  In this tool the stripiness did not occur, so the trick was left out.

*/









// Start of compatibility restrictions and mitigations



/*
  If compiled for Linux or with a TSE version below TSE v4.2, then the compiler
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



// End of compatibility restrictions and mitigations.





// Global variables
integer slices_per_axis = 4   // Base for the display algorithm

string proc draw_palette()
  integer brush_attr                  = 0
  integer brush_bg_index              = 0
  integer brush_bg_rgb_old            = 0
  integer col                         = 0
  integer color_x                     = 0
  integer color_y                     = 0
  integer color_z                     = 0
  integer cols_per_slice               = 0
  integer cols_per_slice_minus_1       = 0
  integer first_col                   = 0
  integer first_row                   = 0
  integer last_col                    = 0
  integer last_row                    = 0
  integer old_CurrVideoMode           = Query(CurrVideoMode)
  integer old_Cursor                  = Set(Cursor        , OFF)
  integer old_Flags                   = 0
  string  old_FontName [MAXSTRINGLEN] = ""
  integer old_PointSize               = 0
  integer old_ShowHelpLine            = Set(ShowHelpLine  , OFF)
  integer old_ShowMainMenu            = Set(ShowMainMenu  , OFF)
  integer old_ShowStatusLine          = Set(ShowStatusLine, OFF)
  integer old_WhtSpc                  = FALSE
  integer org_id                      = GetBufferId()
  integer pos_x                       = 0
  integer pos_y                       = 0
  string  result                  [6] = ''
  integer rgb                         = 0
  integer row                         = 0
  integer rows_per_slice              = 0
  integer rows_per_slice_minus_1      = 0
  integer screen_cols                 = 0
  integer screen_rows                 = 0
  integer slices_minus_1              = 0
  integer slice_minus_1               = 0
  integer slice_x                     = 0
  integer slice_y                     = 0
  integer tmp_id                      = CreateTempBuffer()

  // Save more old settings.
  if isMacroLoaded("WhtSpc")
    old_WhtSpc = TRUE
    PurgeMacro("WhtSpc")
  endif
  GetFont(old_FontName, old_PointSize, old_Flags)
  // Try setting the "Courier New" font to get tested results.
  // So far in testing though, the font does not seem to matter.
  SetFont("Courier New", 12, 0)

  // Set smallest fontsize.
  while ResizeFont(-1)
  endwhile
  screen_cols = Query(ScreenCols)
  screen_rows = Query(ScreenRows)
  SetWindowTitle(Format('Virtual screen resolution'; screen_cols; '*';
                        screen_rows, '':MAXSTRINGLEN:' '))

  Set(Attr, Color(white ON black))
  PopWinOpen(1, 1, Query(ScreenCols), Query(ScreenRows), 0, '',
             Color(white ON black))
  ClrScr()

  brush_attr       = Color(intense black ON white)
  brush_bg_index   = brush_attr / 16
  brush_bg_rgb_old = GetColorTableValue(_BACKGROUND_, brush_bg_index)

  first_row              = 1
  last_row               = screen_rows
  rows_per_slice         = (last_row - first_row + 1) / slices_per_axis
  rows_per_slice_minus_1 = rows_per_slice - 1

  first_col              = 1
  last_col               = screen_cols
  cols_per_slice         = (last_col - first_col + 1) / slices_per_axis
  cols_per_slice_minus_1 = cols_per_slice - 1

  slices_minus_1         = slices_per_axis * slices_per_axis - 1

  // Suppose we need to distribute color values 0 to 255 over 4 colors
  // then we need to increase the color value in steps of (4 - 1):
  //    Color nr  Color value
  //      1         0 * 255 / 3  =    0
  //      2         1 * 255 / 3  =   85
  //      3         2 * 255 / 3  =  170
  //      4         3 * 255 / 3  =  255

  for slice_y = 1 to slices_per_axis
    for slice_x = 1 to slices_per_axis
      slice_minus_1 = (slice_y - 1) * slices_per_axis + slice_x - 1
      color_z = slice_minus_1 * 255 / slices_minus_1
      for pos_y = 0 to rows_per_slice_minus_1
        color_y = pos_y * 255 / rows_per_slice_minus_1
        for pos_x = 0 to cols_per_slice_minus_1
          color_x = pos_x * 255 / cols_per_slice_minus_1
          rgb     = color_z * 65536 + color_x * 256 + color_y
          row     = (slice_y - 1) * rows_per_slice + pos_y + 1
          col     = (slice_x - 1) * cols_per_slice + pos_x + 1
          SetColorTableValue(_BACKGROUND_, brush_bg_index, rgb)
          PutStrAttrXY(col, row, ' ', '', brush_attr)
          AddLine(Format(col:4; row:4; rgb:6:'0':16))
        endfor
      endfor
    endfor
  endfor

  while not KeyPressed()
    MouseStatus()
    if lFind(Format('^', Query(MouseX):4; Query(MouseY):4, ' '), 'gx')
      SetWindowTitle(Format('Position ',
                            GetText(1, 9),
                            ',   RGB color ',
                            GetText(11, 6),
                            '':MAXSTRINGLEN:' '))
    endif
    Delay(2)
  endwhile

  GetKey()
  if (Query(Key) in <LeftBtn>, <RightBtn>)
    result = GetToken(GetText(1, MAXSTRINGLEN), ' ', 3)
  endif

  PopWinClose()
  SetColorTableValue(_BACKGROUND_, brush_bg_index, brush_bg_rgb_old)
  Set(CurrVideoMode , old_CurrVideoMode)
  Set(ShowMainMenu  , old_ShowMainMenu)
  Set(ShowHelpLine  , old_ShowHelpLine)
  Set(ShowStatusLine, old_ShowStatusLine)
  Set(Cursor        , old_Cursor)
  // The "SetFont(old_..." must come AFTER a "Set(CurrVideoMode , old_...",
  // because otherwise it generates a "Divide by zero" error on systems
  // with AND TSE Pro > 4.0 AND some unknown environment influence.
  SetFont(old_FontName, old_pointSize, old_Flags)

  // But that leaves the screen too small, so we need to repeat:
  Set(CurrVideoMode , old_CurrVideoMode)

  GotoBufferId(org_id)
  AbandonFile(tmp_id)
  UpdateDisplay()
  if old_WhtSpc
    LoadMacro("WhtSpc")
  endif
  return(result)
end draw_palette

proc Main()
  string result [6] = ''
  if isGUI()
    result = draw_palette()
    if EquiStr(Query(MacroCmdLine), 'get')
      Set(MacroCmdLine, result)
    else
      if result == ''
        Warn('You picked no color.')
      else
        Warn('You picked color'; result, '.')
      endif
    endif
  else
    Warn('This extension only works with the GUI version of TSE.')
  endif
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

