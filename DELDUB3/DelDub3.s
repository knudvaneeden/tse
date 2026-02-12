/*

      Macro.         DelDub3.
      Author.        Carlo.Hogeveen@xs4all.nl.
      Date-written.  5 februari 1997.

      This macro takes the current column-position,
      and uses this for the rest of the file.

      If two consecutive lines have case-insensitive the same word
      overlapping the above column-position, then the second line
      is deleted, from the current line onwards.

      If there is no word on the column-position, then no line is deleted.
*/

proc del_double()
   integer column = 0
   string word [80] = ""
   PushPosition()
   column  = CurrCol()
   BegFile()
   GotoColumn(column)
   word = Lower(GetWord())
   while Down()
      if  Lower(GetWord(FALSE)) == word
      and Lower(GetWord(FALSE)) <> ""
         KillLine()
         Up()
      endif
      word = Lower(GetWord(FALSE))
   endwhile
   PopPosition()
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

proc Main()
   del_double()
end

