/*
  Program        Xmas
  Author         Carlo.Hogeveen@xs4all.nl
  Compatibility  TSE Pro v4.0 upwards.
  Version        1.0.2   -   27 May 2020

  An experiment in programmed fine-textured drawing with TSE.

  The macro does nothing but write an animated picture to the screen.

  If present it will use the "Courier New" font, which in the GUI version
  of TSE can be resized to really tiny pixels (pointsize 2), which gives a
  surprisingly fine-textured picture. I hope it works for you too.

  Based on a user's input I have extended its claimed compatibility to also
  include the Console version of TSE, but be aware that unless you yourself
  pre-set a large screen size and a small font size, the generated picture
  will have a low resolution in the Console version of TSE.

  Any key will stop it and restore the original screen and settings.

  Installation:
    Just copy the macro to TSE's "mac" directory,
    compile it, and execute it any way you like.


  Historie:
    v1.0     -   25 Dec 2007
      Initial version
    v1.0.1   -   28 dec 2007
    -  Solved a "devide by zero" error when the Xmas macro stopped.
      It only occurred on a certain pc and only when
      running TSE beta 4.40.35 instead of TSE 4.0.
    -  Also reduced the statements for downsizing the font.
    -  Added a question before stopping.

    v1.0.2   -   27 May 2020
      No new features:
      Just made Xmas compatible with TSE Pro v4.41.38 upwards.
*/

proc sort_points_vertically(var integer point1_x, var integer point1_y,
                            var integer point2_x, var integer point2_y)
  integer point3_x = 0
  integer point3_y = 0
  if point1_y > point2_y
    point3_x = point1_x
    point3_y = point1_y
    point1_x = point2_x
    point1_y = point2_y
    point2_x = point3_x
    point2_y = point3_y
  endif
end sort_points_vertically

integer proc horizontal_intersect(integer point1_x, integer point1_y,
                                  integer point2_x, integer point2_y,
                                  integer horizontal_y)
  // Pre:  point1_y <= horizontal_y <= point2_y.
  // Post: horizontal_x contains the x-coordinate of the point where the
  //       horizontal line with y-coordinate "horizontal_y" crosses the
  //       line defined by "point1" and "point2".
  integer horizontal_x = 0
  if point1_x == point2_x
  or point1_y == point2_y
    horizontal_x = (point1_x + point2_x) / 2     // :-)
  else
    if     point1_x < point2_x
      horizontal_x = point1_x
                   + (point2_x - point1_x)
                   * (horizontal_y - point1_y) / (point2_y - point1_y)
    else
      horizontal_x = point2_x
                   + (point1_x - point2_x)
                   * (point2_y - horizontal_y) / (point2_y - point1_y)
    endif
  endif
  return(horizontal_x)
end horizontal_intersect

proc draw_triangle(integer point1_x_in, integer point1_y_in,
                   integer point2_x_in, integer point2_y_in,
                   integer point3_x_in, integer point3_y_in,
                   integer color_in)
  integer point1_x        = point1_x_in
  integer point1_y        = point1_y_in
  integer point2_x        = point2_x_in
  integer point2_y        = point2_y_in
  integer point3_x        = point3_x_in
  integer point3_y        = point3_y_in
  integer horizontal_y    = 0
  integer horizontal_x    = 0
  integer horizontal_x1   = 0
  integer horizontal_x2   = 0
  sort_points_vertically(point1_x, point1_y, point2_x, point2_y)
  sort_points_vertically(point2_x, point2_y, point3_x, point3_y)
  sort_points_vertically(point1_x, point1_y, point2_x, point2_y)
  for horizontal_y = point1_y to point2_y
    horizontal_x1 = horizontal_intersect(point1_x, point1_y,
                                         point2_x, point2_y, horizontal_y)
    horizontal_x2 = horizontal_intersect(point1_x, point1_y,
                                         point3_x, point3_y, horizontal_y)
    for horizontal_x = Min(horizontal_x1, horizontal_x2)
                    to Max(horizontal_x1, horizontal_x2)
      PutStrXY(horizontal_x, horizontal_y, "*", color_in)
    endfor
  endfor
  for horizontal_y = point2_y to point3_y
    horizontal_x1 = horizontal_intersect(point1_x, point1_y,
                                         point3_x, point3_y, horizontal_y)
    horizontal_x2 = horizontal_intersect(point2_x, point2_y,
                                         point3_x, point3_y, horizontal_y)
    for horizontal_x = Min(horizontal_x1, horizontal_x2)
                    to Max(horizontal_x1, horizontal_x2)
      PutStrXY(horizontal_x, horizontal_y, "*", color_in)
    endfor
  endfor
end draw_triangle

integer proc square_root(integer square_number)
  integer result = 0
  if square_number > 0
    while result * result <= square_number
      result = result + 1
    endwhile
    result = result - 1
  endif
  return(result)
end square_root

proc draw_circle(integer center_x, integer center_y, integer radius_x,
                 integer color_in)
  // "Pixels" are denser on the x-axis than y-axis.
  // Compensating by guessing this is twice as dense usually works.
  integer radius_y = radius_x / 2
  integer x = 0
  integer y = 0
  integer distance = 0
  for x = center_x - radius_x to center_x + radius_x
    for y = center_y - radius_y to center_y + radius_y
      distance = square_root( (x - center_x) * (x - center_x)
                            + (y - center_y) * (y - center_y) * 4)
      if distance <= radius_x
        PutStrXY(x, y, "*", color_in)
      endif
    endfor
  endfor
end draw_circle

proc draw_rectangle(integer point1_x, integer point1_y,
                    integer point2_x, integer point2_y,
                    integer color_in)
  // Pre: Supply the coordinates of any OPPOSITE corners of the rectangle.
  integer x, y
  for x = Min(point1_x, point2_x) to Max(point1_x, point2_x)
    for y = Min(point1_y, point2_y) to Max(point1_y, point2_y)
      PutStrXY(x, y, "*", color_in)
    endfor
  endfor
end draw_rectangle

#if EDITOR_VERSION <= 4400h
  integer seed = 0

  integer proc random()
    integer lo, Hi, test
    Hi = seed  /  127773
    lo = seed mod 127773
    test = 16807 * lo - (2147483647 mod 16807) * Hi
    if test > 0
      seed = test
    else
      seed = test + 2147483647
    endif
    return(seed)
  end random
#endif

integer proc random_direction()
  return((random() mod 3) - 1)
end random_direction

integer proc random_star()
  return(random() mod 100 == 0)
end random_star

proc draw_nightsky()
  integer x, y
  Set(Attr, Color(bright white ON black))
  ClrScr()
  // Draw random stars.
  for x = 1 to Query(ScreenCols)
    for y = 1 to Query(ScreenRows)
      if random_star()
        PutStrXY(x, y, "*", Color(intense bright yellow ON yellow))
      endif
    endfor
  endfor
end draw_nightsky

proc draw_snowground()
  integer x, y
  for x = 1 to Query(ScreenCols)
    for y = Query(ScreenRows) downto (Query(ScreenRows) * 2 / 3)
          +   (x - Query(ScreenCols) / 3)
            * (x - Query(ScreenCols) / 3)
            / (Query(ScreenCols) * 9)
      PutStrXY(x, y, "*", Color(intense bright white ON white))
    endfor
    KeyPressed()
  endfor
end draw_snowground

proc draw_tree()
  integer tree_pos_x      = Query(ScreenCols) * 5/6
  integer tree_top        = Query(ScreenRows) * 1/3
  integer tree_bottom     = Query(ScreenRows) * 11/12
  integer trunk_width     = Query(ScreenCols) / 50
  integer branch_height   = (tree_bottom - tree_top) / 5
  integer branch_top      = tree_top
  integer branch_width    = Query(ScreenCols) / 50
  integer inc_branch_width = Query(ScreenCols) / 50
  // Draw trunk.
  draw_triangle(tree_pos_x,
                tree_top,
                tree_pos_x - trunk_width / 2,
                tree_bottom,
                tree_pos_x + trunk_width / 2,
                tree_bottom,
                Color(red ON red))
  // Draw leaves.

  for branch_top = tree_top to tree_bottom - branch_height - 1 by branch_height / 2
    branch_width = branch_width + inc_branch_width
    draw_triangle( tree_pos_x,
                   branch_top,
                   tree_pos_x - branch_width / 2,
                   branch_top + branch_height,
                   tree_pos_x + branch_width / 2,
                   branch_top + branch_height,
                   Color(green ON green))
  endfor
end draw_tree

proc draw_moon()
  draw_circle(Query(ScreenCols) / 2, Query(ScreenRows) / 6,
              Query(ScreenCols) / 20,
              Color(intense bright yellow ON yellow))
end draw_moon

proc draw_window( integer top_left_x,
            integer top_left_y,
            integer pixel_x,
            integer pixel_y)
  // Draw window.
  draw_rectangle(top_left_x,
                 top_left_y,
                 top_left_x + 6 * pixel_x,
                 top_left_y + 6 * pixel_y,
                 Color(red ON red))
  // Draw panes.
  draw_rectangle(top_left_x +     pixel_x,
                 top_left_y +     pixel_y,
                 top_left_x + 2 * pixel_x,
                 top_left_y + 2 * pixel_y,
                 Color(intense bright yellow ON yellow))
  draw_rectangle(top_left_x +     pixel_x,
                 top_left_y + 4 * pixel_y,
                 top_left_x + 2 * pixel_x,
                 top_left_y + 5 * pixel_y,
                 Color(intense bright yellow ON yellow))
  draw_rectangle(top_left_x + 4 * pixel_x,
                 top_left_y +     pixel_y,
                 top_left_x + 5 * pixel_x,
                 top_left_y + 2 * pixel_y,
                 Color(intense bright yellow ON yellow))
  draw_rectangle(top_left_x + 4 * pixel_x,
                 top_left_y + 4 * pixel_y,
                 top_left_x + 5 * pixel_x,
                 top_left_y + 5 * pixel_y,
                 Color(intense bright yellow ON yellow))
end draw_window

proc draw_house()
  integer wall_top_left_x = Query(ScreenCols) / 12
  integer wall_top_left_y = Query(ScreenRows) * 17 / 32
  integer wall_width = Query(ScreenCols) / 6
  integer wall_height = Query(ScreenRows) / 6
  integer pixel_x = wall_width  / 16
  integer pixel_y = wall_height / 16
  // Draw wall.
  draw_rectangle(wall_top_left_x,
                 wall_top_left_y,
                 wall_top_left_x + wall_width,
                 wall_top_left_y + wall_height,
                 Color(intense bright cyan ON cyan))
  // Draw door.
  draw_rectangle(wall_top_left_x + wall_width  - 5 * pixel_x,
                 wall_top_left_y + wall_height - 8 * pixel_y,
                 wall_top_left_x + wall_width  -     pixel_x,
                 wall_top_left_y + wall_height,
                 Color(red ON red))
  draw_window(wall_top_left_x + pixel_x,
              wall_top_left_y + wall_height - 8 * pixel_y,
              pixel_x, pixel_y)
  draw_window(wall_top_left_x + pixel_x,
              wall_top_left_y +  2 * pixel_y,
              pixel_x, pixel_y)
  draw_window(wall_top_left_x + 10 * pixel_x,
              wall_top_left_y +  2 * pixel_y,
              pixel_x, pixel_y)
  // Draw roof.
  draw_triangle(wall_top_left_x + wall_width  / 2,
                wall_top_left_y - wall_height / 2,
                wall_top_left_x - pixel_x,
                wall_top_left_y + pixel_y,
                wall_top_left_x + wall_width + pixel_x,
                wall_top_left_y + pixel_y,
                Color(red ON red))
  // Draw chimney.
  draw_rectangle(wall_top_left_x + 3 * pixel_x,
                 wall_top_left_y - wall_height / 2 + 2 * pixel_y,
                 wall_top_left_x + 5 * pixel_x,
                 wall_top_left_y + pixel_y,
                 Color(red ON red))
end draw_house

proc x_mas()
  integer org_id             = GetBufferId()
  integer tmp_id             = CreateTempBuffer()
  integer old_ShowMainMenu   = Set(ShowMainMenu  , OFF)
  integer old_ShowHelpLine   = Set(ShowHelpLine  , OFF)
  integer old_ShowStatusLine = Set(ShowStatusLine, OFF)
  integer old_Cursor         = Set(Cursor        , OFF)
  integer old_CurrVideoMode  = Query(CurrVideoMode)
  string  old_FontName [255] = ""
  integer old_PointSize      = 0
  integer old_Flags          = 0
  integer old_WhtSpc         = FALSE
  integer particle           = 0
  integer particle_x         = 0
  integer particle_y         = 0
  integer no_new_particle_created = FALSE
  // Save more old settings.
  if isMacroLoaded("WhtSpc")
    old_WhtSpc = TRUE
    PurgeMacro("WhtSpc")
  endif
  GetFont(old_FontName, old_PointSize, old_Flags)
  // Try setting the "Courier New" font for best results.
  SetFont("Courier New", 12, 0)
  // Set smallest fontsize.
  while ResizeFont(-1)
  endwhile
  // Set largest window.
  Set(CurrVideoMode, _MAX_LINES_COLS_)
  UpdateDisplay()
  SetWindowTitle("TSE wenst je prettige feestdagen en een pleziervol nieuw jaar !")    // AFTER UpdateDisplay().
  // Draw picture.
  draw_nightsky()
  draw_tree()
  draw_moon()
  draw_house()
  draw_snowground()
  draw_tree()
  draw_moon()
  draw_house()
  // Note: waiting without using GetKey() doesn't refresh the screen to text
  //       if the pointsize wasn't changed.
  repeat
    // Update smoke particles.
    no_new_particle_created = TRUE
    for particle = 1 to 255
      particle_x = GetBufferInt("particle_" + Str(particle) + "_x")
      if particle_x > 0
        particle_y = GetBufferInt("particle_" + Str(particle) + "_y")
        // Note: blacking out requires the space character.
        PutStrXY(particle_x , particle_y, " ", Color(black ON black))
        particle_x = particle_x + random_direction()
        particle_y = particle_y + random_direction() - 1
        if particle_x < 1
        or particle_x > Query(ScreenCols)
        or particle_y < 1
          DelBufferVar("particle_" + Str(particle) + "_x")
          DelBufferVar("particle_" + Str(particle) + "_y")
        else
          SetBufferInt("particle_" + Str(particle) + "_x", particle_x)
          SetBufferInt("particle_" + Str(particle) + "_y", particle_y)
          PutStrXY(particle_x, particle_y, "*", Color(intense bright white ON white))
        endif
      else
        if no_new_particle_created
          no_new_particle_created = FALSE
          particle_x = Query(ScreenCols) / 12 + 4 * Query(ScreenCols) / 6 / 16
          particle_y = Query(ScreenRows) / 2 - Query(ScreenRows) / 6 / 2 + 3 * Query(ScreenRows) / 6 / 16
          SetBufferInt("particle_" + Str(particle) + "_x", particle_x)
          SetBufferInt("particle_" + Str(particle) + "_y", particle_y)
        endif
      endif
    endfor
    Delay(1)
  until KeyPressed()
  GetKey()
  // Restore old settings.
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
end x_mas

proc WhenLoaded()
  #if EDITOR_VERSION <= 4400h
    seed = (GetWinHandle() +  GetClockTicks())
  #endif
end WhenLoaded

proc Main()
  repeat
    x_mas()
    Set(X1, Query(ScreenCols) / 2 - 10)
    Set(Y1, Query(ScreenRows) / 2 -  5)
    PushKey(<GreyCursorDown>)
  until YesNo("Stop Christmas animation?") == 1
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
  if  NumFiles() == 1
  and SubStr(CurrFilename(),1,1) == "<"
    AbandonEditor()
  endif
end Main

