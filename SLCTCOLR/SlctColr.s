/*
   Macro          SlctColr
   Author         Carlo.Hogeveen@xs4all.nl
   Date           10 June 2004
   Compatibility  TSE Pro 2.5e upwards

   This macro lets the user select one of TSE's colors.

   Although it can be run by itself, it is intended as a supplemental macro,
   to be called from other macros, to select a color for something.
   This macro by itself sets or updates nothing.

   It can optionally be given two parameters on the macro command line.
   The first string should be a hexadecimal value representing a TSE color.
   The rest of the macro commandline is shown to the user while he selects
   a color.

   The macro returns the selected color as a hexadecimal string in TSE's
   MacroCmdLine variable. If no color was selected, then an empty string
   is returned.

   Example:
      proc Main()
         integer selected_color = 0
         ExecMacro("SlctColr 80 Another color for my soul")
         if Query(MacroCmdLine) == ""
            Message("No color was selected.")
         else
            selected_color = Val(Query(MacroCmdLine), 16)
            VGotoXY(20,20)
            Set(Attr, selected_color)
            PutStr("Selected color is " + Str(selected_color, 16))
         endif
         PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
      end

   Some info about TSE colors:
      TSE can show 16 colors at once. However it never handles these colors
      by themselves, but always as a "foreground on background" color.
      When you assign a color anywhere in TSE, it is always as a
      "foreground on background" color. So there are 16 * 16 TSE-colors.
      Such a color is represented in one byte.
      The four most  significant bits represent the background color.
      The four least significant bits represent the foreground color.
      So if we show a TSE-color in hexedecimal format, then the first
      character represents the background color, and the second character
      represents the foreground color.
*/

#ifdef EDITOR_VERSION
   #if EDITOR_VERSION - 3000h
      #define EDITOR_VERSION_4 TRUE   // TSE version >= 4.00
   #else
      #define EDITOR_VERSION_4 FALSE  // TSE version == 3.00
   #endif
#else
   #define EDITOR_VERSION_4 FALSE     // TSE version <  3.00
#endif

string colors [46] = "Black Blue Green Cyan Red Magenta Yellow White"

#ifdef WIN32
#else
   proc PutStrAttrXY(integer x, integer y, string s, string attributes,
                     integer attribute)
      // The dummy variable avoids the compiler warning, that the attributes
      // variable is not used in this program.
      string dummy [1] = attributes
      dummy = dummy
      VGotoXY(x, y)
      Set(Attr, attribute)
      PutStr(s)
   end

   proc BufferVideo()
      // The non-existence of this command in TSE Pro versions below 2.6
      // will make the screen flash a bit.
   end

   proc UnBufferVideo()
      // The non-existence of this command in TSE Pro versions below 2.6
      // will make the screen flash a bit.
   end
#endif

proc Main()
   integer rows_per_color      = (Query(ScreenRows) - 3) / 16
   integer cols_per_color      = (Query(ScreenCols) - 2) / 16
   integer top_margin          = (Query(ScreenRows) - 3 - rows_per_color * 16) / 2 + 1
   integer left_margin         = (Query(ScreenCols) - 2 - cols_per_color * 16) / 2 + 1
   integer foreground          = 0
   integer background          = 0
   integer sub_row             = 0
   integer selected_foreground = 0
   integer selected_background = 0
   integer mouse_foreground    = 0
   integer mouse_background    = 0
   integer old_cursor          = Set(Cursor, OFF)
   integer prev_clockticks     = 0
   string  param_color     [2] = Trim(SubStr(Query(MacroCmdLine), 1,  2))
   string  param_prompt  [252] = Trim(SubStr(Query(MacroCmdLine), 3,252))
   string  color_name     [33] = "Intense Bright Magenta on Magenta"
   string  window_title  [255] = ""
   #if EDITOR_VERSION_4
      integer old_SpecialEffects = 0
   #endif
   BufferVideo()
   Set(Attr, Color(bright white ON black))
   ClrScr()
   if param_color <> ""
      selected_foreground = Val(param_color, 16) mod 16
      selected_background = Val(param_color, 16)  /  16
   endif
   repeat
      color_name = iif(selected_background > 7, "Intense ", "")
                 + iif(selected_foreground > 7, "Bright " , "")
                 + GetToken(colors, " ", (selected_foreground mod 8) + 1)
                 + " on "
                 + GetToken(colors, " ", (selected_background mod 8) + 1)
      if param_prompt == ""
         window_title = color_name
      else
         window_title = Format(param_prompt, color_name:34)
      endif
      PutStrAttrXY(1, 1, window_title, "", Color(bright white ON black))
      ClrEol()
      PopWinOpen(left_margin,
                 top_margin,
                 left_margin + (cols_per_color * 16) + 1,
                 top_margin  + (rows_per_color * 16) + 1,
                 1,
                 "",
                 Color(bright white ON black))
      for foreground = 0 to 15 // Rows.
         for background = 0 to 15 // Columns.
            for sub_row = 1 to rows_per_color
               if foreground <> 0 // Skip a bug in the PutStrAttrXY command
               or background <> 0 // up to and including TSE 4.2.
                  PutStrAttrXY(background * cols_per_color + 1,
                               foreground * rows_per_color + sub_row,
                               Format((background * 16 + foreground)
                                      :cols_per_color:"0":16),
                               "",
                               background * 16 + foreground)
               endif
            endfor
         endfor
      endfor
      #if EDITOR_VERSION_4
         old_SpecialEffects = Set(SpecialEffects,
                              Query(SpecialEffects) & ~ _DRAW_SHADOWS_)
      #endif
      PopWinOpen(left_margin + selected_background * cols_per_color,
                 top_margin  + selected_foreground * rows_per_color,
                 left_margin + selected_background * cols_per_color + cols_per_color + 1,
                 top_margin  + selected_foreground * rows_per_color + rows_per_color + 1,
                 1,
                 "",
                 Color(bright white ON black))
      #if EDITOR_VERSION_4
         Set(SpecialEffects, old_SpecialEffects)
      #endif
      UnBufferVideo()
      case GetKey()
         when <Home>, <GreyHome>
            selected_foreground = 0
            selected_background = 0
         when <end>, <GreyEnd>
            selected_foreground = 15
            selected_background = 15
         when <CursorDown>, <GreyCursorDown>
            if selected_foreground == 15
               selected_foreground = 0
            else
               selected_foreground = selected_foreground + 1
            endif
         when <CursorUp>, <GreyCursorUp>
            if selected_foreground == 0
               selected_foreground = 15
            else
               selected_foreground = selected_foreground - 1
            endif
         when <CursorRight>, <GreyCursorRight>
            if selected_background == 15
               selected_background = 0
            else
               selected_background = selected_background + 1
            endif
         when <CursorLeft>, <GreyCursorLeft>
            if selected_background == 0
               selected_background = 15
            else
               selected_background = selected_background - 1
            endif
         when <LeftBtn>
            /*
               The Delay(1) turned out to be necessary to give the system
               time to update the mouse status. An extra call to MouseStatus
               was useless, as could be expected, because TSE should already
               do that internally after a mousekey.
            */
            Delay(1)
            mouse_background = (Query(MouseX) - left_margin - 1) / cols_per_color
            mouse_foreground = (Query(MouseY) -  top_margin - 1) / rows_per_color
            if  (mouse_background in 0 .. 15)
            and (mouse_foreground in 0 .. 15)
               if  mouse_background == selected_background
               and mouse_foreground == selected_foreground
                  if GetClockTicks() - prev_clockticks < 18
                     PushKey(<Enter>)
                  endif
               else
                  selected_background = mouse_background
                  selected_foreground = mouse_foreground
               endif
               prev_clockticks = GetClockTicks()
            endif
      endcase
      BufferVideo()
      PopWinClose()
      PopWinClose()
   until Query(Key) in <Enter>, <GreyEnter>, <Escape>
   UpdateDisplay(_ALL_WINDOWS_REFRESH_)
   UnBufferVideo()
   Set(Cursor, old_cursor)
   if Query(Key) == <Escape>
      Set(MacroCmdLine, "")
   else
      Set(MacroCmdLine,
          Str(selected_background * 16 + selected_foreground, 16))
   endif
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

