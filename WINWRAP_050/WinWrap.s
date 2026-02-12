/*
   Macro             WinWrap
   Author            Carlo.Hogeveen@xs4all.nl
   Date              20 May 2005
   Version           0.5
   Compatitibility   At least TSE 3.0.
                     Only tested with TSE 4.4 so far.


   This macro is a windowwrapper, as opposed to a filewrapper.

   It wraps lines that are longer than the current window is wide,
   but it only wraps them on the screen, not in the file behind it.

   It therefore doesn't change or interfere with the editing buffer at all,
   it just changes the way text is displayed.

   This implies that it doesn't interfere with almost all editor functions
   and user macros.

   However, this also implies that it does interfere with:
   -  Syntax hiliting.
   -  Block marking.
   -  The "[End of File]" indicator.
   -  The WhtSpc macro.

   The macro does work with split windows, but it only wraps the current
   window, not the other windows.

   Installation:
   -  Copy this source file to TSE's "mac" directory and compile it there.

   Usage notes:
   -  For now, load the macro to start wrapping lines, and purge it to
      stop wrapping lines.
   -  To go to the wrapped part of a line, do not use the Down() key, because
      that will move you down to the next line in the file, not to the next
      line in the window. Instead use the Right() or the WordRight() key
      repeatedly.
   -  When using the Up() and Down() key, you will sometimes notice the text
      scrolling even when you are not at the top or bottom of the window.
      It is a looking-glass effect: the wrapped text is longer than the
      window, and therefore the Up() and Down() keys scroll the text as you
      move the cursor up and down the unwrapped lines behind it, just like a
      looking-glass seems to scroll lines as you move it over a text.
      The benefit is a closer relation between wrapped and unwrapped lines:
      for instance as you turn windowwrapping on and off, the cursor line
      remains at the same place. The downside is some unasked-for scrolling.
      That the macro can automatically (de)activate windowwrapping makes a
      closer relation between wrapped and unwrapped lines and therefore the
      looking-glass behaviour the more desirable choice.

   Known bugs:
   -  If the macro is purged and reloaded, then often the window
      repeatedly doesn't get updated until the the next keystroke.
   -  If the cursor is past the window-width on the first line, then the
      beginning of the line is not shown.

   Todo list:
   -  (De)activate the WhtSpc macro when wrapping is (not) active.
   -  When scrolling left and right out of the (invisible) real window, some
      of the flickering might be reduced by by pre-scrolling the real window
      ahead.
   -  Wrap lines in logical places instead of simply after the last window-
      character.
   -  Auto-indent the wrapped part of a line, ideally also honoring bullets.
   -  Reinstate some syntax hiliting by letting the macro do it too. This
      won't be perfect (numbers and multi-line comments).
   -  Make the macro (de)activate itself when there is (no) find-result
      in the current window.
      Note: when CuaMark is configured to block-mark find-results, then this
      already works.
      Note: I didn't get this to work based on GetFoundText() in the _idle_
      hook, because other resident macros do Finds too.


   History:
   v0.1  20 May 2005
   -  Initial try, works really bad, but demonstrates the idea.
   v0.2  14 Jun 2005
   -  Second try, better, but is having cursor and edit problems on the
      wrapped part of a line.
   v0.3  19 Jul 2005
   -  Renamed the macro from LongLine to ScrnWrap.
   -  This version seems bug-free!
   -  That said, it contains just its bare core functionality, and is not a
      pleasure to work with.
   v0.4  30 Jul 2005
   -  Renamed the macro from ScrnWrap to WinWrap.
   -  Solved some of the flickering. The remainder seems the result of TSE
      not always honoring its BufferVideo() command, especially during
      the _idle_ state. I have tried lots of possible solutions, and believe
      the current one is the least worse one.
   -  Found out there is a "ghost cursor" when scrolling horizontally in the
      wrapped part of a line. This ghost cursor is actually the real
      unwrapped cursor, which for our purposes is the wrong one.
      It seems impossible to make the ghost cursor invisible without making
      the wrapped cursor invisible, so we probably have to live with it.
   -  Found out that block marking doesn't show, which is logical.
      Shudder: solving this would be hard, and for column blocks more so.
   -  Found out that find-hiliting doesn't show, which is also logical.
   -  Solved the macro continuously corrupting the TSE clipboard.
   -  Solved the cursor positioning problem when the cursor is AND at or past
      the end-of-line AND at a position past the window-width.
      The result looks like empty lines being added to the current line
      to reach the cursor position.
   -  Made the macro (de)activate itself when there are (no) lines to be
      wrapped in the current window.
   v0.5  5 Sep 2005
   -  Made the macro deactivate itself when there is blockmarking in the
      current window, and reactivate itself as soon as there isn't any more.
   -  If the WhtSpc macro is loaded, then it is deactivated during wrapping,
      and reactivated as soon as there is no more wrapping.
   -  Executing the macro now toggles it on and off.
      Alas, turning it on again is subject to a known bug.
*/


// Global work-variables.
integer wrap_id               = 0
integer clipboard_id          = 0
integer clipboard_type        = 0
integer video_buffered        = FALSE
integer wrapped_cursor_line   = 1
integer wrapped_cursor_column = 1
integer wrapping_active       = FALSE
string  macroname      [255]  = ""
integer whtspc_purged         = FALSE
integer whenloaded_clockticks = 0

// Wrapping happens immediately after each keystroke, and also after each
// wrap_period of no keystrokes.
// Since the latter only occurs in exceptional cases, it is set to be slow (1
// second) and to gradually become even slower as no more keystrokes follow.
// Wrap_period is in 1/18ths of a second, and is the minimum time between two
// non-keystroke wraps: it will likely be longer, and might easily be twice
// as long depending on how busy your pc is in general, and specifically on
// how active other macros are.
// Minimum_wrap_period should be 0 for practical use, but may be set to 18
// or higher for testing why and when flickering occurs.
integer minimum_wrap_period = 18
integer maximum_wrap_period = 18 * 60
integer wrap_period         = 0
integer wrap_timer          = 0


proc push_clipboard()
   integer org_id = GetBufferId()
   integer old_uap = Set(UnMarkAfterPaste, OFF)
   PushBlock()
   GotoBufferId(clipboard_id)
   UnMarkBlock()
   EmptyBuffer()
   Paste()
   clipboard_type = isBlockMarked()
   Set(UnMarkAfterPaste, old_uap)
   GotoBufferId(org_id)
   PopBlock()
end

proc pop_clipboard()
   integer org_id = GetBufferId()
   PushBlock()
   GotoBufferId(clipboard_id)
   if clipboard_type
      case clipboard_type
         when _LINE_
            MarkLine(1, NumLines())
         when _COLUMN_
            MarkColumn(1, 1, NumLines(), CurrLineLen())
         when _INCLUSIVE_, _NONINCLUSIVE_
            BegFile()
            MarkChar()
            EndFile()
      endcase
      Copy()
      EmptyBuffer()
   else
      if GotoBufferId(Query(ClipBoardId))
      or GetBufferId() == Query(ClipBoardId)
         EmptyBuffer()
      endif
   endif
   GotoBufferId(org_id)
   PopBlock()
end

integer proc is_block_in_window()
   integer result = FALSE
   if isBlockInCurrFile()
      result = TRUE
      PushPosition()
      BegWindow()
      if Query(BlockEndLine) < CurrLine()
         result = FALSE
      else
         EndWindow()
         if Query(BlockBegLine) > CurrLine()
            result = FALSE
         endif
      endif
      PopPosition()
   endif
   return(result)
end

proc wrap_lines(  var integer window_cursor_line,
                  var integer window_cursor_column,
                  integer window_columns,
                  var integer window_start_line)
   integer tmp_window_cursor_line = window_cursor_line
   // If necessary make the current line longer to show the cursor correctly.
   GotoLine(window_cursor_line)
   if  window_cursor_column > window_columns
   and window_cursor_column > CurrLineLen()
      if CurrLineLen() < window_cursor_column
         GotoColumn(CurrLineLen() + 1)
         InsertText(Format("":(window_cursor_column - CurrLineLen())),
                    _INSERT_)
      endif
   endif
   // Start wrapping.
   wrapping_active = FALSE
   BegFile()
   repeat
      if CurrLineLen() > window_columns
         wrapping_active = TRUE
         if CurrLine() < tmp_window_cursor_line
            tmp_window_cursor_line = tmp_window_cursor_line + 1
            window_start_line      = window_start_line      + 1
         else
            if CurrLine() == tmp_window_cursor_line
               if window_cursor_column > window_columns
                  window_cursor_column   = window_cursor_column   - window_columns
                  tmp_window_cursor_line = tmp_window_cursor_line + 1
                  window_start_line      = window_start_line      + 1
               endif
            endif
         endif
         GotoColumn(window_columns + 1)
         SplitLine()
      endif
   until not Down()
end

proc wrap_window()
   integer org_id                = GetBufferId()
   integer old_hook_state        = 0
   integer org_file_line_from    = 0
   integer org_file_line_to      = 0
   integer window_cursor_line    = CurrLine()
   integer window_cursor_column  = CurrCol()
   integer window_columns        = Query(WindowCols)
   integer window_start_line     = 1
   integer wrapped_line          = 0
   integer window_row_from       = Query(WindowY1)
   integer window_row_to         = window_row_from + Query(WindowRows) - 1
   integer window_column_from    = Query(WindowX1)
   integer y                     = 0
   integer old_wrapping_active   = wrapping_active
   integer old_currpos           = 0
   string  line            [255] = ""
   if is_block_in_window()
      wrapping_active = FALSE
   else
      old_hook_state = SetHookState(OFF)
      PushPosition()
      PushBlock()
      push_clipboard()
      BegWindow()
      org_file_line_from = CurrLine()
      EndWindow()
      org_file_line_to   = CurrLine()
      window_cursor_line = window_cursor_line - org_file_line_from + 1
      MarkLine(org_file_line_from, org_file_line_to)
      Copy()
      GotoBufferId(wrap_id)
      EmptyBuffer()
      Paste()
      wrap_lines(window_cursor_line, window_cursor_column, window_columns,
                 window_start_line)
      if wrapping_active
         wrapped_line = window_start_line
         for y = window_row_from to window_row_to
            GotoLine(wrapped_line)
            line = Format(GetText(1, CurrLineLen()) : window_columns * -1)
            PutStrXY(window_column_from, y, line, Query(TextAttr))
            wrapped_line = wrapped_line + 1
         endfor
         wrapped_cursor_line   = window_column_from + window_cursor_column - 1
         wrapped_cursor_column = window_row_from    + window_cursor_line   - 1
         GotoXY(wrapped_cursor_line, wrapped_cursor_column)
      endif
      GotoBufferId(org_id) // Avoids _on_changing_files_ hook by popposition().
      PopPosition()        // Necessary to reposition the real cursorline
                           // relative to the real window. Hmm.
      PopBlock()
      pop_clipboard()
      SetHookState(old_hook_state)
   endif
   if old_wrapping_active <> wrapping_active
      old_wrapping_active = wrapping_active
      // The next three lines ensure that the real window is no longer
      // shifted to the right when wrapping is deactivated.
      old_currpos = CurrPos()
      BegLine()
      GotoPos(old_currpos)
      if wrapping_active
         if isMacroLoaded("WhtSpc")
            PurgeMacro("WhtSpc")
            whtspc_purged = TRUE
         endif
      else
         if whtspc_purged
            LoadMacro("WhtSpc")
            whtspc_purged = FALSE
         endif
      endif
   endif
end

proc before_command()
   if wrapping_active
      if not video_buffered
         BufferVideo()
         video_buffered = TRUE
      endif
   endif
end

proc after_command()
   wrap_timer  = 0
   wrap_period = minimum_wrap_period
   if wrapping_active
      GotoXY(wrapped_cursor_line, wrapped_cursor_column)
      if video_buffered
         if not KeyPressed()
            wrap_window()
            UnBufferVideo()
            // Alas, some types of screen-changes can only be overridden here,
            // and some types can only be overidden in the _idle_ state.
            // So we immediately buffervideo again for the next _idle_ event.
            BufferVideo()
         endif
      endif
   else
      if video_buffered
         UnBufferVideo()
         video_buffered = FALSE
      endif
   endif
end

proc idle()
   if video_buffered
      if not KeyPressed()
         wrap_window()
         UnBufferVideo()
         video_buffered = FALSE
      endif
      wrap_timer = 0
      wrap_period = minimum_wrap_period
   else
      if wrap_timer >= wrap_period
         BufferVideo()
         wrap_window()
         UnBufferVideo()
         wrap_timer = 0
         if wrap_period < 1
            wrap_period = 1
         else
            wrap_period = wrap_period * 2
         endif
         if wrap_period >= maximum_wrap_period
            wrap_period  = maximum_wrap_period
         endif
      else
         wrap_timer = wrap_timer + 1
      endif
   endif
end

proc WhenLoaded()
   integer org_id = GetBufferId()
   video_buffered = FALSE
   macroname = SplitPath(CurrMacroFilename(), _NAME_)
   AbandonFile(GetBufferId(macroname + "_wrapfile.tmp"))
   wrap_id = CreateTempBuffer()
   ChangeCurrFilename(macroname + "_wrapfile.tmp",
                      _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
   AbandonFile(GetBufferId(macroname + "_clipboard.tmp"))
   clipboard_id = CreateTempBuffer()
   ChangeCurrFilename(macroname + "_clipboard.tmp",
                      _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
   GotoBufferId(org_id)
   Hook(_BEFORE_COMMAND_, before_command)
   Hook(_AFTER_COMMAND_ , after_command)
   Hook(_IDLE_          , idle)
   whenloaded_clockticks = GetClockTicks()
end

proc WhenPurged()
   UnHook(before_command)
   UnHook(after_command)
   UnHook(idle)
   AbandonFile(wrap_id)
   AbandonFile(clipboard_id)
   if whtspc_purged
      LoadMacro("WhtSpc")
   endif
   UpdateDisplay(_ALL_WINDOWS_REFRESH_)
end

proc Main()
//   string wrap_period_string [10] = Str(wrap_period)
   if GetClockTicks() - whenloaded_clockticks > 1
      PurgeMacro(macroname)
   endif
   Delay(9)
   /*
   Message("The recommended value is 90 (to keep lots of free processortime)")
   if Ask("Minimum non-keystroke wrap-period (1/18th seconds):",
          wrap_period_string)
      if Val(wrap_period_string) > 0
         wrap_period = Val(wrap_period_string)
         WriteProfileInt(macroname, "wrap_period", wrap_period)
      endif
   endif
   */
   UpdateDisplay(_STATUSLINE_REFRESH_|_REFRESH_THIS_ONLY_)
   Delay(9)
end

