/*
   Macro          WinWrap
   Author         Carlo.Hogeveen@xs4all.nl
   Compatibility  TSE Pro 4.0 upwards
   Version        1.1
   Date           29 March 2009

   DISCLAIMER:
      This macro was not rigourously tested. In fact, it was deemed so
      potentially hazardous, that it was only tested using a dummy.
      No real people were harmed during the making of this macro.
      Don't be the first: avoid risk to yourself, your files,
      and your other loved ones: simply do not use this macro.

   Purpose:
      When lines don't fit the window, apparently edit them window-wrapped,
      while actually still editing the not-wrapped lines.

   Installation:
      Copy this source to TSE's "mac" directory, compile it,
      and execute it at least once to configure it.

   Configuration options:
   -  Autoload:
         This configures whether the macro should be activated for future TSE
         sessions.
   -  Delay:
         After how many 18ths of a second WinWrap (de)activates wrapping if
         the current file has(n't) lines longer than the window is broad.
         There is this delay, because:
         -  Initially you might want to see the original file too,
         -  You especially don't want automatic wrapping when one line gets
            temporarily too long while typing.
         -  It avoids clashes with other macros.
         Set delay to all nines to automatically wrap after 2 years :-)
   -  Confirmation request after delay:
      -  Yes, you do want to confirm before wrapping automatically.
      -  No , you don't.
   -  Key to toggle wrapping mode:
         You can configure your own key here to set WinWrap explicitly on/off
         while editing each file. This then overrules automatic (un)wrapping
         after the delay.
   -  Wrap at:
      -  Border    : line wrapping occurs at the right window border.
      -  Whitespace: line wrapping occurs at the whitespace just before that.
   -  Indentation:
      -  None: the wrapped part of a line is not indented with extra spaces.
      -  Same: wrapped part of line is indented the same as the first part.
      -  Wiki: indenting as Same, and also somewhat wiki-aware, for example
         a leading * is treated as a bullet, which is treated as a whitespace
         when indenting.

   What doesn't work (yet?):
   -  Tilde indicator before the wrapped parts of a line.
   -  The correct column number on a wrapped line.
   -  Screen flickering is low, but might be further reduceable, maybe.
   -  Vertical scrolling in wrapped file scrolls too soon.

   What may never work:
   -  When wrapping automatically without confirmation,
      the wrapping doesn't appear until the next keystroke.
   -  Block marking/copying/pasting.
   -  Find marking.
   -  Jumping between split windows with a wrapped file hangs TSE.

   What will never work:
   -  Undo/redo is disabled for a wrapped file.

   History:
   v0.1 - v0.5    20 May 2005 - 5 September 2005
      These versions, initially named LongLine and ScrnWrap, were not
      satisfactory, because their completely different approach (leave the
      buffer intact and only redraw the screen) resulted in problems wich
      were unsolvable, such as massive screen flickering, a ghost cursor,
      and disabled syntax hiliting.
   v0.6           17 March 2009
      Eureka! A completely new approach seems to be very promising:
      in wrapping-mode (WinWrap -> ON) keep a copy of the real file in a
      shadow buffer, before each command restore the real file to the real
      buffer, after each command save the real file to the shadow buffer
      and wrap the "real" buffer.
   v0.6.1         18 March 2009
      Solved: TSE freezing at the end-of-file.
   v0.6.2         22 March 2009
      Solved: the FileChanged indicator was always "changed" after wrapping.
   v0.6.3         24 March 2009
      Added cool wrapping options, configurable by executing the macro.
   v0.6.4         25 March 2009
      Improved menus.
      Improved cleanup when purging macro.
      Added optional confirmation request when automatically setting
      a file in wrapped mode.
      Added a menu-configurable key to explicitly toggle a file's wrapmode.
   v1.0.0         25 March 2009
      Disabled the progress-messages from internal buffer-copying commands.
      Added AutoLoad option to the configuration menu.
      The macro is sufficiently finished that it might be usable for reckless
      people, so its beta status is lifted, and its existence is published.
   v1.0.1         26 March 2009
      Solved: The macro didn't compile for TSE Pro 4.0: the isAutoloaded()
              function doesn't exist yet in that version of TSE.
   v1.0.2         26 March 2009
      Solved: Auto-wrapping wasn't delayed when the macro was autoloaded
              and TSE was started with a file.
   v1.1           29 March 2009
      A "~" tilde indicator in the statusline shows if the file is in WinWrap
      mode. That only means that the file contains wrapped lines somewhere,
      not necessarily in the visible window.
*/


// You may set this global variable to TRUE to generate debug messages
// in a temp buffer.
integer debugging = FALSE


// These global variables may only be set by the macro.
integer winwrap_delay      = 0
string  wrap_at       [10] = ""
string  indentation    [4] = ""
string  confirmation   [3] = ""
string  macro_name   [255] = ""
integer winwrap_timer      = 0
integer debug_id           = 0
integer command_recursions = 0
integer menu_history       = 0
integer toggle_key         = 0
integer idle_id            = 0

proc debug_message(string text)
   integer clockticks = 0
   integer hours      = 0
   integer minutes    = 0
   integer seconds    = 0
   integer hundreths  = 0
   if debugging
      clockticks = GetClockTicks()
      hours      = clockticks                       / (18 * 60 * 60)
      minutes    = (clockticks mod (18  * 60 * 60)) / (18 * 60)
      seconds    = (clockticks mod (18  * 60     )) /  18
      hundreths  = (clockticks mod  18            ) * 100 / 18
      AddLine(Format(hours,":",minutes,":",seconds,".",hundreths," ",text),
              debug_id)
   endif
end

integer proc is_AutoLoaded()
   integer org_id = GetBufferId()
   integer result = FALSE
   integer autoload_id = 0
   #ifdef WIN32
      autoload_id = EditBuffer(LoadDir() + "tseload.dat", _SYSTEM_)
   #else
      autoload_id = CreateTempBuffer()
      if autoload_id
         InsertFile(LoadDir() + "tseload.dat", _DONT_PROMPT_)
      endif
   #endif
   if autoload_id
      result = lFind(macro_name, "giw")
      GotoBufferId(org_id)
      AbandonFile(autoload_id)
   endif
   return(result)
end

proc pop_message(string text)
   integer old_cursor = Set(Cursor, OFF)
   if PopWinOpen(10, 10, 10 + Length(text) + 1, 10 + 2, 1, "", Query(MenuBorderAttr))
      GotoXY(2,2)
      ClrScr()
      PutStr(text, Query(MenuTextAttr))
      Delay(36)
      PopWinClose()
   else
      debug_message("PopWinOpen failed")
   endif
   Set(Cursor, old_cursor)
end

proc copy_org_to_shadow()
   integer org_msglevel = Set(MsgLevel, _WARNINGS_ONLY_)
   integer org_id       = GetBufferId()
   integer org_line     = CurrLine()
   integer org_column   = CurrCol()
   integer org_row      = CurrRow()
   integer shadow_id    = GetBufferInt(macro_name + ":shadow_id")
   debug_message("   copy_org_to_shadow")
   SetBufferInt(macro_name + ":filechanged", FileChanged())
   MarkLine(1,NumLines())
   Copy()
   GotoBufferId(shadow_id)
   EmptyBuffer()
   Paste()
   UnMarkBlock()
   BegFile()
   GotoLine(org_line)
   BegLine()
   while CurrRow() <> org_row
      if CurrRow() < org_row
         ScrollUp()
      else
         ScrollDown()
      endif
   endwhile
   GotoColumn(org_column)
   GotoBufferId(org_id)
   Set(MsgLevel, org_msglevel)
end

proc copy_shadow_to_org()
   integer org_msglevel    = Set(MsgLevel, _WARNINGS_ONLY_)
   integer org_id          = GetBufferId()
   integer org_filechanged = GetBufferInt(macro_name + ":filechanged")
   integer shadow_id       = GetBufferInt(macro_name + ":shadow_id")
   integer shadow_line     = 0
   integer shadow_column   = 0
   integer shadow_row      = 0
   debug_message("   copy_shadow_to_org")
   GotoBufferId(shadow_id)
   shadow_line   = CurrLine()
   shadow_column = CurrCol()
   shadow_row    = CurrRow()
   MarkLine(1, NumLines())
   Copy()
   GotoBufferId(org_id)
   EmptyBuffer()
   Paste()
   UnMarkBlock()
   BegFile()
   GotoLine(shadow_line)
   BegLine()
   while CurrRow() <> shadow_row
      if CurrRow() < shadow_row
         ScrollUp()
      else
         ScrollDown()
      endif
   endwhile
   GotoColumn(shadow_column)
   FileChanged(org_filechanged)
   Set(MsgLevel, org_msglevel)
end

proc do_wrap_at()
   integer old_column = CurrCol()
   if wrap_at == "Whitespace"
      if  Left()
      and lFind("[ \d009]", "bcx")
      and CurrPos() > PosFirstNonWhite()
         Right()
      else
         GotoColumn(old_column)
      endif
   endif
end

proc do_indentation()
   integer indentation_chars = 0
   if indentation == "Same"
      GotoPos(PosFirstNonWhite())
   elseif indentation == "Wiki"
      lFind("[~ \d009*]", "cgx")
   else
      BegLine()
   endif
   indentation_chars = CurrCol() - 1
   Down()
   if  indentation == "Wiki"
   and CurrChar(PosFirstNonWhite()) == Asc(":")
      indentation_chars = indentation_chars + 2
   endif
   if indentation_chars > 0
      BegLine()
      InsertText(Format("":indentation_chars))
   endif
   Up()
end

proc wrap_org()
   integer org_col         = CurrCol()
   integer org_row         = CurrRow()
   integer org_filechanged = GetBufferInt(macro_name + ":filechanged")
   debug_message("   wrap_org")
   BegWindow()
   repeat
      if CurrLineLen() > Query(WindowCols)
         GotoColumn(Query(WindowCols) + 1)
         do_wrap_at()
         SplitLine()
         do_indentation()
         if     CurrRow() <  org_row
            ScrollDown()
         elseif CurrRow() == org_row
            if org_col > Query(WindowCols)
               ScrollDown()
               org_col = org_col - Query(WindowCols)
            endif
         endif
      endif
   until not Down()
      or CurrRow() >= Query(WindowRows)
   GotoRow(org_row)
   BegLine()
   GotoColumn(org_col)
   FileChanged(org_filechanged)
end

proc set_wrapping_indicator()
   integer indicator_line   = 0
   integer indicator_column = 33
   if GetBufferInt(macro_name + ":shadow_id")
      if Query(StatusLineAtTop)
         if Query(ShowMainMenu)
            indicator_line = 2
         else
            indicator_line = 1
         endif
      else
         indicator_line = Query(ScreenRows)
      endif
      PutStrAttrXY(indicator_column,
                   indicator_line,
                   "~",
                   "",
                   Query(StatusLineAttr))
   endif
end

proc deactivate_winwrap_for_this_file()
   copy_shadow_to_org()
   AbandonFile(GetBufferInt(macro_name + ":shadow_id"))
   if GetBufferInt(macro_name + ":undo_mode")
      SetUndoOn()
   endif
   DelBufferVar(macro_name + ":undo_mode")
   DelBufferVar(macro_name + ":shadow_id")
   DelBufferVar(macro_name + ":wrapping_disabled")
   pop_message("WinWrap -> OFF")
end

proc activate_winwrap_for_this_file()
   integer org_id    = GetBufferId()
   integer shadow_id = CreateTempBuffer()
   SetUndoOff()
   GotoBufferId(org_id)
   SetBufferInt(macro_name + ":shadow_id", shadow_id)
   if UndoMode()
      SetBufferInt(macro_name + ":undo_mode", TRUE)
   endif
   SetUndoOff()
   copy_org_to_shadow()
   DelBufferVar(macro_name + ":wrapping_disabled")
   pop_message("WinWrap -> ON")
   idle_id = 0
end

proc idle()
   integer org_id    = GetBufferId()
   integer shadow_id = GetBufferInt(macro_name + ":shadow_id")
   integer wrapping_allowed
   if winwrap_timer <= 0
      winwrap_timer = winwrap_delay
      if shadow_id
         GotoBufferId(shadow_id)
         if LongestLineInBuffer() <= Query(WindowCols)
            GotoBufferId(org_id)
            deactivate_winwrap_for_this_file()
         else
            GotoBufferId(org_id)
         endif
      else
         if      LongestLineInBuffer() > Query(WindowCols)
         and not GetBufferInt(macro_name + ":wrapping_disabled")
            if  confirmation <> "No"
            and YesNo("Confirm wrapping this file?") <> 1
               SetBufferInt(macro_name + ":wrapping_disabled", TRUE)
               wrapping_allowed = FALSE
               pop_message("WinWrap -> OFF")
            else
               wrapping_allowed = TRUE
            endif
            if wrapping_allowed
               activate_winwrap_for_this_file()
            endif
         endif
      endif
   else
      winwrap_timer = winwrap_timer - 1
   endif
   // When changing files (e.g. with Next File), the status line is updated
   // after the_AFTER_COMMAND_ hook, so the wrapping indicator isn't updated.
   // Doing UpdateDisplay(_STATUS_LINE_REFRESH_) before our own statusline-
   // update would work, but that might disturb other macro's updating the
   // statusline, depending on the macro-autoload-order.
   // This solution solves all that:
   if GetBufferId() <> idle_id
      set_wrapping_indicator()
      idle_id = GetBufferId()
   endif
end

proc before_command()
   debug_message("Before command")
   command_recursions = command_recursions + 1
   if command_recursions == 1
      if GetBufferInt(macro_name + ":shadow_id")
         copy_shadow_to_org()
      endif
   endif
end

proc after_command()
   debug_message("After command")
   command_recursions = command_recursions - 1
   if command_recursions <= 0
      command_recursions = 0
      if GetBufferInt(macro_name + ":shadow_id")
         copy_org_to_shadow()
         wrap_org()
         set_wrapping_indicator()
      endif
   endif
   winwrap_timer = winwrap_delay
end

integer proc read_num(integer n)
   string s[10] = Str(n)
   return (iif(ReadNumeric(s), Val(s), n))
end

proc set_delay()
   winwrap_delay = read_num(winwrap_delay)
   WriteProfileInt(macro_name, "delay", winwrap_delay)
end

integer proc get_delay()
   return(winwrap_delay)
end

string proc get_wrap_at()
   return(wrap_at)
end

proc set_wrap_at(string new_wrap_at)
   wrap_at = new_wrap_at
   WriteProfileStr(macro_name, "wrap_at", wrap_at)
end

menu wrap_at_menu()
   title = "Wrap at"
   history = menu_history
   "Border",
      set_wrap_at("Border"),
      _MF_CLOSE_BEFORE_|_MF_ENABLED_,
      "Wrap long lines at the right window border"
   "Whitespace",
      set_wrap_at("Whitespace"),
      _MF_CLOSE_BEFORE_|_MF_ENABLED_,
      "Wrap long lines at the last whitespace before the right window border"
end

proc to_wrap_at_menu()
   if wrap_at == "Whitespace"
      menu_history = 2
   else
      menu_history = 1
   endif
   wrap_at_menu()
end

string proc get_indentation()
   return(indentation)
end

proc set_indentation(string new_indentation)
   indentation = new_indentation
   WriteProfileStr(macro_name, "indentation", indentation)
end

menu indentation_menu()
   title = "Indentation for wrapped part of line"
   history = menu_history
   "None",
      set_indentation("None"),
      _MF_CLOSE_BEFORE_|_MF_ENABLED_,
      "Do not indent the wrapped part of a line"
   "Same",
      set_indentation("Same"),
      _MF_CLOSE_BEFORE_|_MF_ENABLED_,
      "Indent the wrapped part of a line the same as the first part"
   "Wiki",
      set_indentation("Wiki"),
      _MF_CLOSE_BEFORE_|_MF_ENABLED_,
      "Same plus some wiki formatting: e.g. treat leading * as a bullet"
end

proc to_indentation_menu()
   case indentation
      when "Same"
         menu_history = 2
      when "Wiki"
         menu_history = 3
      otherwise
         menu_history = 1
   endcase
   indentation_menu()
end

proc toggle_confirmation()
   if confirmation == "Yes"
      confirmation = "No"
   else
      confirmation = "Yes"
   endif
   WriteProfileStr(macro_name, "confirmation", confirmation)
end

string proc key_value_to_name(integer p_key_value)
   string key_name [255] = ""
   if p_key_value == -1
      key_name = "Unassigned"
   else
      key_name = "<" + KeyName(p_key_value) + ">"
   endif
   return(key_name)
end

integer proc key_name_to_value(string p_key_name)
   integer key_value = -1
   if p_key_name <> "Unassigned"
      key_value = KeyCode(SubStr(p_key_name, 2, Length(p_key_name) - 2))
   endif
   return(key_value)
end

proc set_toggle_key(var integer toggle_key)
   integer saved_key = toggle_key
   integer new_key = -1
   integer redraw  = FALSE
   // Fiddle with the display so the user gets the idea...
   PutAttr(Query(BlockAttr),Query(PopWinCols))
   loop
      redraw  = FALSE
      new_key = GetKey()
      if new_key == <Escape>
         toggle_key = saved_key
         Break
      elseif new_key == <Enter>
         if toggle_key <> saved_key
            WriteProfileStr(macro_name, "toggle_key", key_value_to_name(toggle_key))
         endif
         Break
      elseif new_key in <Del>, <GreyDel>
         toggle_key = -1
         redraw = TRUE
      elseif      Length(key_value_to_name(new_key)) == 3
          or (    Length(key_value_to_name(new_key)) == 9
             and  Lower(SubStr(key_value_to_name(new_key),1,7)) == "<shift "
             and (Lower(SubStr(key_value_to_name(new_key),8,1)) in "a".."z"))
         if Query(Beep)
            Alarm()
         endif
         Message(key_value_to_name(new_key), " is not allowed as a toggle key")
      else
         toggle_key = new_key
         redraw = TRUE
      endif
      if redraw
         VHomeCursor()
         PutStrAttr(Format(key_value_to_name(toggle_key):Query(PopWinCols)),
                    "", Query(BlockAttr))
      endif
   endloop
end

proc toggle_autoload()
   if is_AutoLoaded()
      DelAutoLoadMacro(macro_name)
   else
      AddAutoLoadMacro(macro_name)
   endif
end

menu configure_winwrap()
   title = "Configure window wrapping"
   history
   "Autoload this macro" [Format(iif(is_AutoLoaded(), "Yes", "No"):3):3],
      toggle_autoload(),
      _MF_DONT_CLOSE_|_MF_ENABLED_,
      "Activate this macro for future TSE sessions?"
   "Delay (1/18th seconds)" [Format(get_delay():10):10],
      set_delay(),
      _MF_DONT_CLOSE_|_MF_ENABLED_,
      "Delay (in 1/18th seconds) before wrapping automatically"
   "Confirm wrapping automatically" [Format(confirmation:3):3],
      toggle_confirmation(),
      _MF_DONT_CLOSE_|_MF_ENABLED_,
      "After the above delay, do you want to confirm before wrapping?"
   "Key to toggle wrapping" [Format(key_value_to_name(toggle_key):30):30],
      set_toggle_key(toggle_key),
      _MF_DONT_CLOSE_|_MF_ENABLED_,
      "Key to toggle wrapping a file: press <Enter>, then new key or <Del>"
   "Wrap at" [Format(get_wrap_at():10):10],
      to_wrap_at_menu(),
      _MF_DONT_CLOSE_|_MF_ENABLED_,
      "Wrap at window border or at the last whitespace before it"
   "Indentation" [Format(get_indentation():4):4],
      to_indentation_menu(),
      _MF_DONT_CLOSE_|_MF_ENABLED_,
      "Indentation for the wrapped parts of long lines"
end

proc after_getkey()
   if  Query(Key) == toggle_key
   and QueryEditState() == 0
      if GetBufferInt(macro_name + ":shadow_id")
         deactivate_winwrap_for_this_file()
         SetBufferInt(macro_name + ":wrapping_disabled", TRUE)
      else
         activate_winwrap_for_this_file()
      endif
      PushKey(-1)                    // Necessary to fixup the keystack...
      GetKey()                       // Necessary to fixup the keystack...
   endif
end

proc WhenPurged()
   integer org_id   = GetBufferId()
   integer first_id = 0
   debug_message("WhenPurged")
   NextFile(_DONT_LOAD_)
   repeat
      if GetBufferInt(macro_name + ":shadow_id") > 0
         AbandonFile(GetBufferInt(macro_name + ":shadow_id"))
      endif
      if GetBufferInt(macro_name + ":undo_mode")
         SetUndoOn()
      endif
      DelBufferVar(macro_name + ":shadow_id")
      DelBufferVar(macro_name + ":undo_mode")
      DelBufferVar(macro_name + ":wrapping_disabled")
      if first_id == 0
         first_id = GetBufferId()
      endif
   until not NextFile(_DONT_LOAD_)
      or GetBufferId() == first_id
   GotoBufferId(org_id)
   pop_message("WinWrap -> ALL OFF")
end

proc WhenLoaded()
   integer org_id = GetBufferId()
   string toggle_name [255] = ""
   if debugging
      debug_id = CreateTempBuffer()
      ChangeCurrFilename(macro_name + ":debug.log",
                         _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
      GotoBufferId(org_id)
   endif
   debug_message("WhenLoaded")
   macro_name    = SplitPath(CurrMacroFilename(), _NAME_)
   winwrap_delay = GetProfileInt(macro_name, "delay"       ,  90         )
   confirmation  = GetProfileStr(macro_name, "confirmation", "No"        )
   toggle_name   = GetProfileStr(macro_name, "toggle_key"  , "Unassigned")
   wrap_at       = GetProfileStr(macro_name, "wrap_at"     , "Whitespace")
   indentation   = GetProfileStr(macro_name, "indentation" , "Wiki"      )
   winwrap_timer = winwrap_delay
   toggle_key    = key_name_to_value(toggle_name)
   Hook(_IDLE_                   , idle)
   Hook(_BEFORE_COMMAND_         , before_command)
   Hook(_BEFORE_NONEDIT_COMMAND_ , before_command)
   Hook(_AFTER_COMMAND_          , after_command)
   Hook(_AFTER_NONEDIT_COMMAND_  , after_command)
   Hook(_AFTER_GETKEY_           , after_getkey)
end

proc Main()
   configure_winwrap()
end

