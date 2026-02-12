/*
   Smart (shift) tab key.
*/


proc cbltab(integer direction)          // Direction must be 1 of -1.

   integer
      blocktype = isCursorInBlock(),
      line_begin,
      line_end,
      column,
      tab_step

   ExecMacro("settabs2 set")

   if DisplayMode() == _DISPLAY_HEX_
      HexEdit(FALSE)
   endif

   if Query(Marking)
      Mark(blocktype)
   endif

   if blocktype == _LINE_
   or blocktype == _COLUMN_
      GotoBlockEnd()
      line_end = CurrLine()
      GotoBlockBegin()
      line_begin = CurrLine()
      if blocktype == _LINE_
         if CurrExt() in ".cbl", ".cob"
            PushBlock()
            UnMarkBlock()
            MarkColumn(line_begin, 8, line_end, 2000)
            GotoBlockBegin()
         else
            BegLine()
         endif
      endif
   endif

   while isWhite()
      Right()
   endwhile
   column = CurrCol()

   if blocktype == _LINE_
   or blocktype == _COLUMN_
      if  (CurrExt() in ".cbl", ".cob")
      and column          == 8
      and direction        < 1
         tab_step = 0
      else
         tab_step = DistanceToTab(direction + 1) * direction
         if Query(Insert)
            repeat
               ShiftText(tab_step)
            until not RollDown()
               or CurrLine() > line_end
         endif
      endif

      GotoLine(line_begin)
      GotoColumn(column + tab_step)

      if  (CurrExt() in ".cbl", ".cob")
      and blocktype       == _LINE_
         PopBlock()
      endif
   else
      if direction > 0
         TabRight()
      else
         if direction < 0
            TabLeft()
         endif
      endif
   endif

   ExecMacro("settabs2 reset")
end


proc Main()
   string parameter [6] = Lower(GetToken(Query(MacroCmdLine), " ", 1))

   case parameter
      when "left"    cbltab(-1)
      when "right"   cbltab(1)

      otherwise
         Warn("Macro TAB received unknown parameter: ", parameter)
   endcase
end

<tab>       ExecMacro("tab2 Right")
<Shift tab> ExecMacro("tab2 left")
<BackSpace> ExecMacro("Bakspac2")


