/*
   Macro:            WinAnim
   Author:           Carlo.Hogeveen@xs4all.nl
   Date:             6 feb 2005
   Compatibility:    TSE 4.0 upwards

   Just a fun macro, that animates TSE's window when it opens and closes.

   Installation:
      Copy this file to TSE's "mac" directory and compile it.

   Configuration:
      Just execute the macro to configure it.

   Caveat:
      The OPEN method of this macro might cause a slightly or badly drawn
      screen when you start another macro from the commandline.
*/

#define AW_HOR_POSITIVE 0x00000001
#define AW_HOR_NEGATIVE 0x00000002
#define AW_VER_POSITIVE 0x00000004
#define AW_VER_NEGATIVE 0x00000008
#define AW_CENTER       0x00000010
#define AW_HIDE         0x00010000
#define AW_ACTIVATE     0x00020000
#define AW_SLIDE        0x00040000
#define AW_BLEND        0x00080000

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
#define SW_SHOWDEFAULT     10
#define SW_FORCEMINIMIZE   11
#define SW_MAX             11

string  macroname [255] = ""
integer open_option     = 0
integer close_option    = 0
integer open_duration   = 0
integer close_duration  = 0

dll "<user32.dll>"
   integer proc AnimateWindow(
         integer hwnd,
         integer dwTime,
         integer dwFlags
      )

   integer proc MinimizeWindow(
         integer hWnd
      ) : "CloseWindow"

   integer proc ShowWindow(
         integer hWnd,
         integer nCmdShow
      )

   integer proc RestoreWindow(
         integer hWnd
      ) : "OpenIcon"
end

proc on_editor_startup()
   integer hours, minutes, seconds, hundredths, random
   GetTime(hours, minutes, seconds, hundredths)
   random = hours   * 60 * 60 * 100
          + minutes      * 60 * 100
          + seconds           * 100
          + hundredths
   if open_option
      ShowWindow(GetWinHandle(), sw_hide)
   endif
   case open_option
      when 0
         NoOp()
      when 1
         MinimizeWindow(GetWinHandle())
         RestoreWindow(GetWinHandle())
      when 2
         AnimateWindow(GetWinHandle(), open_duration, aw_activate|aw_center)
      when 3
         AnimateWindow(GetWinHandle(), open_duration, aw_activate|aw_blend)
      when 4
         case (random mod 4)
            when 0
               AnimateWindow(GetWinHandle(), open_duration, aw_activate|aw_slide|aw_hor_positive)
            when 1
               AnimateWindow(GetWinHandle(), open_duration, aw_activate|aw_slide|aw_hor_negative)
            when 2
               AnimateWindow(GetWinHandle(), open_duration, aw_activate|aw_slide|aw_ver_positive)
            when 3
               AnimateWindow(GetWinHandle(), open_duration, aw_activate|aw_slide|aw_ver_negative)
         endcase
      otherwise
         case (random mod 13)
            when 1, 4, 7, 10
               AnimateWindow(GetWinHandle(), open_duration, aw_activate|aw_center)
            when 2, 5, 8, 11
               AnimateWindow(GetWinHandle(), open_duration, aw_activate|aw_blend)
            when 0
               AnimateWindow(GetWinHandle(), open_duration, aw_activate|aw_slide|aw_hor_positive)
            when 3
               AnimateWindow(GetWinHandle(), open_duration, aw_activate|aw_slide|aw_hor_negative)
            when 6
               AnimateWindow(GetWinHandle(), open_duration, aw_activate|aw_slide|aw_ver_positive)
            when 9
               AnimateWindow(GetWinHandle(), open_duration, aw_activate|aw_slide|aw_ver_negative)
            when 12
               MinimizeWindow(GetWinHandle())
               RestoreWindow(GetWinHandle())
         endcase
   endcase
end

proc on_abandon_editor()
   case close_option
      when 0
         NoOp()
      when 1
         MinimizeWindow(GetWinHandle())
      when 2
         AnimateWindow(GetWinHandle(), close_duration, aw_hide|aw_center)
      when 3
         AnimateWindow(GetWinHandle(), close_duration, aw_hide|aw_blend)
      when 4
         case (GetClockTicks() mod 4)
            when 0
               AnimateWindow(GetWinHandle(), close_duration, aw_hide|aw_slide|aw_hor_positive)
            when 1
               AnimateWindow(GetWinHandle(), close_duration, aw_hide|aw_slide|aw_hor_negative)
            when 2
               AnimateWindow(GetWinHandle(), close_duration, aw_hide|aw_slide|aw_ver_positive)
            when 3
               AnimateWindow(GetWinHandle(), close_duration, aw_hide|aw_slide|aw_ver_negative)
         endcase
      otherwise
         case (GetClockTicks() mod 13)
            when 1, 4, 7, 10
               AnimateWindow(GetWinHandle(), close_duration, aw_hide|aw_center)
            when 2, 5, 8, 11
               AnimateWindow(GetWinHandle(), close_duration, aw_hide|aw_blend)
            when 0
               AnimateWindow(GetWinHandle(), close_duration, aw_hide|aw_slide|aw_hor_positive)
            when 3
               AnimateWindow(GetWinHandle(), close_duration, aw_hide|aw_slide|aw_hor_negative)
            when 6
               AnimateWindow(GetWinHandle(), close_duration, aw_hide|aw_slide|aw_ver_positive)
            when 9
               AnimateWindow(GetWinHandle(), close_duration, aw_hide|aw_slide|aw_ver_negative)
            when 12
               MinimizeWindow(GetWinHandle())
         endcase
   endcase
end

proc WhenLoaded()
   macroname = SplitPath(CurrMacroFilename(), _NAME_)
   open_option  = GetProfileInt(macroname, "OpenOption" , 0)
   open_duration   = GetProfileInt(macroname, "OpenDuration"  , 0)
   close_option = GetProfileInt(macroname, "CloseOption", 0)
   close_duration  = GetProfileInt(macroname, "CloseDuration" , 0)
   on_editor_startup()
   Hook(_ON_ABANDON_EDITOR_, on_abandon_editor)
end

menu open_option_menu()
   title = "Select an OPEN method for TSE:"
   width = 60
   x = 10
   y = 10
   history = 1
   "Reversed &Minimize"
   "&Center"
   "&Blend"
   "&Slide"
   "",,_MF_DIVIDE_
   "&Random"
   "",,_MF_DIVIDE_
   "&None"
end

menu close_option_menu()
   title = "Select a CLOSE method for TSE:"
   width = 60
   x = 10
   y = 10
   history = 1
   "&Minimize"
   "&Center"
   "&Blend"
   "&Slide"
   "",,_MF_DIVIDE_
   "&Random"
   "",,_MF_DIVIDE_
   "&None"
end

proc select_prev_menu_option(integer menu_option)
   integer offset = menu_option - 1
   integer i = 0
   if menu_option == 6
      offset = 4
   elseif menu_option in 0, 8
      offset = 5
   endif
   for i = 1 to offset
      PushKey(<GreyCursorDown>)
   endfor
end

proc Main()
   integer ok = TRUE
   string answer [4] = ""
   Delay(9)
   if ok
      select_prev_menu_option(open_option)
      open_option_menu()
      Delay(9)
      if MenuOption() == 0
         Message("You escaped!")
         ok = FALSE
      else
         if MenuOption() == 8
            open_option = 0
            RemoveProfileItem(macroname, "OpenOption")
            RemoveProfileItem(macroname, "OpenDuration")
         else
            open_option = MenuOption()
            WriteProfileInt(macroname, "OpenOption", MenuOption())
            if MenuOption() == 1
               Message('(There is no "Window OPEN Duration" for Reversed Minimize)')
               Delay(54)
               Message("")
               Delay(9)
            else
               answer = Str(open_duration)
               Set(X1,10)
               Set(Y1,10)
               if Ask("Window OPEN duration   (0 = fastest, 1000 = one slow second) :", answer)
                  Delay(9)
                  open_duration = Abs(Val(answer))
                  WriteProfileInt(macroname, "OpenDuration", open_duration)
               else
                  Delay(9)
                  Message("You escaped!")
                  ok = FALSE
               endif
            endif
         endif
      endif
   endif
   if ok
      select_prev_menu_option(close_option)
      close_option_menu()
      Delay(9)
      if MenuOption() == 0
         Message("You escaped!")
         ok = FALSE
      else
         if MenuOption() == 8
            close_option = 0
            RemoveProfileItem(macroname, "CloseOption")
            RemoveProfileItem(macroname, "CloseDuration")
         else
            close_option = MenuOption()
            WriteProfileInt(macroname, "CloseOption", MenuOption())
            if MenuOption() == 1
               Message('(There is no "Window CLOSE Duration" for Minimize)')
               Delay(54)
               Message("")
               Delay(9)
               Message("Options changed.")
            else
               answer = Str(close_duration)
               Set(X1,10)
               Set(Y1,10)
               if Ask("Window CLOSE duration   (0 = fastest, 1000 = one slow second) :", answer)
                  Delay(9)
                  close_duration = Abs(Val(answer))
                  WriteProfileInt(macroname, "CloseDuration", close_duration)
                  Message("Options changed.")
                  Delay(36)
                  Message("Options changed.")
               else
                  Delay(9)
                  Message("You escaped!")
                  ok = FALSE
               endif
            endif
         endif
      endif
   endif
   if  open_option  == 0
   and close_option == 0
      DelAutoLoadMacro(macroname)
      PurgeMacro(macroname)
   else
      AddAutoLoadMacro(macroname)
   endif
end

