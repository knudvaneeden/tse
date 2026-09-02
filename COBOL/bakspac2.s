/*
      Smarter backspace.
*/


#define picture_position 42


#define TAB    9
#define SPACE 32


integer proc is_white()
   integer result
   if CurrChar() in TAB, SPACE, _AT_EOL_, _BEYOND_EOL_
      result = TRUE
   else
      result = FALSE
   endif
   return(result)
end


proc smartbackspace()
   integer
      tab_column,
      white_column

   if CurrCol() == 1
      if CurrLine() <> 1
         PrevChar()
         JoinLine()
      endif
   else
      Left()
      if is_white()
         if  CurrCol() > picture_position - 4
         and CurrCol() < picture_position
         and Lower(SubStr(SplitPath(CurrFilename(), _NAME_), 1, 3)) == "cpy"
            DelChar()
         else
            PushPosition()
            while  Left()
               and is_white()
            endwhile
            white_column = CurrCol()
            if not is_white()
               white_column = white_column + 1
            endif
            PopPosition()
            Right()
            ExecMacro("settabs2 set")
            tab_column = CurrCol() - DistanceToTab(FALSE)
            if tab_column > white_column
               while CurrCol() > tab_column
                  BackSpace()
               endwhile
            else
               BackSpace()
            endif
            ExecMacro("settabs2 reset")
         endif
      else
         DelChar()
      endif
   endif
end


proc Main()
   smartbackspace()
end

<BackSpace> Main()


