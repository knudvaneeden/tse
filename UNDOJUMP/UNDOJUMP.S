/*
   Macro :  UndoJump
   Author:  carlo.hogeveen@xs4all.nl
   Date  :  22 May 2001

   This macro undoes and redoes a maximum of 10 jumps in or between files.

   For instance, if you open a second file and/or searched that/a file
   to look something up, this macro positions you back were you were.

   This macro thinks you have jumped, if the cursor has moved more
   than N lines, which is checked each second of no activity.

   Default N is set to be just larger than a PageUp and PageDown.
   Note: This still means that 2 or more PageDowns without a pause
   in between is considered to be a jump.

   You might change these defaults with the variables "macro_reaction_speed"
   and "lines_moved_criterium" at the top of this source.

   At the bottom of this file the default keys for UndoJump and RedoJump
   are defined: of course you may change these at will.

   Installation:
   -  Copy the file UndoJump.s to TSE's "Mac" directory.
   -  Load the file in TSE and from the menu do a Macro, Compile.
   -  In the menu Macro, AutoLoad List do an <Insert> of "UndoJump"
      and an <enter> to confirm.
   -  Restart TSE.
*/

// Check each N/18 seconds of no activity.
integer macro_reaction_speed  = 18

// Check if the cursor moved N lines.
// If N == 0, then N is set to be just larger than a PageDown/PageUp.
integer lines_moved_criterium = 0



// Here starts the program.
// Touch at your own risk, except for the key definitions at the bottom.

string  jump_stack   [255] = ""
integer old_bufferid       = 0
integer old_line           = 0
integer old_column         = 0
integer lines_moved        = 0
integer jump_stack_top     = 0

proc Goto_Line(integer line)
   if line > NumLines()
      EndFile()
   else
      GotoLine(line)
   endif
end

proc Goto_Column(integer column)
   if column > CurrLineLen()
      EndLine()
   else
      GotoColumn(column)
   endif
end

proc Push_Position()
   if old_bufferid == 0
      // This happens the very first time Push_Position is called.
   else
      if jump_stack_top == 10
         jump_stack = SubStr(jump_stack, 26, 250)
      else
         jump_stack_top = jump_stack_top + 1
      endif
      jump_stack = SubStr(jump_stack, 1, (jump_stack_top - 1) * 25)
                 + Format( old_bufferid:10:"0",
                           old_line    :10:"0",
                           old_column  : 5:"0")
                 + SubStr(jump_stack, (jump_stack_top - 1) * 25 + 1, 250)
   endif
end

proc Pop_Position()
   integer tmp_bufferid = GetBufferId()
   integer tmp_line     = CurrLine()
   integer tmp_column   = CurrCol()
   if jump_stack_top == 0
      Message("No (more) jumps to undo")
      Delay(36)
      UpdateDisplay()
   else
      if jump_stack_top == 10
      or Val(SubStr(jump_stack, jump_stack_top * 25 +  1, 10)) <> GetBufferId()
      or Val(SubStr(jump_stack, jump_stack_top * 25 + 11, 10)) <> CurrLine()
      or Val(SubStr(jump_stack, jump_stack_top * 25 + 21,  5)) <> CurrCol()
         Push_Position()
         jump_stack_top = jump_stack_top - 1
      endif
      old_bufferid = Val(SubStr(jump_stack, (jump_stack_top - 1) * 25 +  1, 10))
      old_line     = Val(SubStr(jump_stack, (jump_stack_top - 1) * 25 + 11, 10))
      old_column   = Val(SubStr(jump_stack, (jump_stack_top - 1) * 25 + 21,  5))
      jump_stack_top = jump_stack_top - 1
      if GotoBufferId(old_bufferid)
         Goto_Line(old_line)
         Goto_Column(old_column)
         PushPosition()
         GotoBufferId(tmp_bufferid)
         GotoLine(tmp_line)
         GotoColumn(tmp_column)
         PopPosition() // Triggers _FileChanged_ hooks.
         ScrollToCenter()
      endif
   endif
end

proc undo_jump()
   Pop_Position()
end

proc redo_jump()
   integer tmp_bufferid    = GetBufferId()
   integer tmp_line        = CurrLine()
   integer tmp_column      = CurrCol()
   integer redo_bufferid   = Val(SubStr(jump_stack, (jump_stack_top + 1) * 25 +  1, 10))
   integer redo_line       = Val(SubStr(jump_stack, (jump_stack_top + 1) * 25 + 11, 10))
   integer redo_column     = Val(SubStr(jump_stack, (jump_stack_top + 1) * 25 + 21,  5))
   // Warn(jump_stack_top, " ", jump_stack)
   if jump_stack_top >= 9
   or redo_bufferid  == 0
      Message("No (more) jumps to redo")
      Delay(36)
      UpdateDisplay()
   else
      jump_stack_top = jump_stack_top + 1
      if GotoBufferId(redo_bufferid)
         Goto_Line(redo_line)
         Goto_Column(redo_column)
         PushPosition()
         GotoBufferId(tmp_bufferid)
         GotoLine(tmp_line)
         GotoColumn(tmp_column)
         PopPosition() // Triggers _FileChanged_ hooks.
         ScrollToCenter()
      endif
   endif
end

proc idle()
   if GetClockTicks() mod macro_reaction_speed == 0
      lines_moved  = CurrLine() - old_line
      if lines_moved > lines_moved_criterium
      or lines_moved < lines_moved_criterium * -1
      or GetBufferId() <> old_bufferid
         Push_Position()
      endif
      old_bufferid = GetBufferId()
      old_line     = CurrLine()
      old_column   = CurrCol()
   endif
end

proc WhenLoaded()
   if lines_moved_criterium == 0
      lines_moved_criterium = Query(ScreenRows)
   endif
   Hook(_IDLE_, idle)
end

proc Main()
end

#ifdef WIN32
   <AltShift F>      undo_jump()
   <CtrlAltShift F>  redo_jump()
#else
   <AltShift F>      undo_jump()
   <CtrlAlt F>       redo_jump()
#endif

