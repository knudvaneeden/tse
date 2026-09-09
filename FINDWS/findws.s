/*
   Macro    Findws
   Author   Carlo.Hogeveen@xs4all.nl
   Date     11 May 1998
   Version  6
   Date     29 May 2011

   This macro finds a sequence of words separated by whitespace.

   You enter the words separated by a single space, which the macro matches
   with whitespace.

   Whitespace is any combination of spaces, horizontal_tabs and end_of_lines.

   The words may not contain spaces and are searched using case-insensitive
   regular expressions starting right from the cursor position.

   Findws can be started from the menu with Macro Execute, or from another
   macro or using a key definition with ExecMacro().

   It can be started with or without parameters.

   By searching "_again_" the previous find is repeated.

   Examples:
      begfile()
      execmacro("findws")
      execmacro("findws great britain")
      execmacro("findws _again_")

   History.
      Version 2, May 1998.
         Added searching _again_ .
      Version 3, May 1998.
         Seems meant for solving a bug.
      Version 4 and 5, May 1998.
         Spin-offs that assumed that all non-letters were whitespaces.
      Version 6.
         Based on version 3, and adds marking found text.

*/
#define horizontal_tab 9
#define space 32
integer find_history = 0
string previous_findws[255] = ""
proc Main()
   string word[255] = ""
   string searching[255] = Query(MacroCmdLine)
   integer found = FALSE
   integer found_beg_line = 0
   integer found_beg_column = 0
   integer found_end_line = 0
   integer found_end_column = 0
   integer word_line = 0
   integer word_column = 0
   integer token_counter = 0
// set(break, on)
   if searching == ""
      Ask("Enter words separated by spaces", searching, find_history)
   else
      if Lower(searching) == "_again_"
         searching = previous_findws
      endif
   endif
   if searching <> ""
      previous_findws = searching
   endif
   PushPosition()
   repeat
      token_counter = 0
      repeat
         token_counter = token_counter + 1
         word = GetToken(searching, " ", token_counter)
         if word <> ""
            if token_counter == 1
               if lFind(word, "ix+")
                  found = TRUE
                  found_beg_line = CurrLine()
                  found_beg_column = CurrCol()
                  found_end_line = CurrLine()
                  found_end_column = CurrCol() + Length(word) - 1
               else
                  found = FALSE
                  word  = ""
               endif
            else
               // Cursor is on previous found word: goto next whitespace.
               while CurrChar() <> space
               and   CurrChar() <> horizontal_tab
               and   CurrChar() <> _AT_EOL_
                  NextChar()
               endwhile
               // Cursor is on first whitespace: goto next non-whitespace.
               while CurrChar() == space
               or    CurrChar() == horizontal_tab
               or    CurrChar() == _AT_EOL_
                  NextChar()
               endwhile
               // Check if the word under the cursor is the next search word.
               word_line = CurrLine()
               word_column = CurrCol()
               if  lFind(word, "cix")
               and CurrLine() == word_line
               and CurrCol() == word_column
                  // Yes, the next search word was and is under the cursor.
                  found_end_line = CurrLine()
                  found_end_column = CurrCol() + Length(word) - 1
               else
                  found = FALSE
               endif
            endif
         endif
      until found == FALSE
      or    word  == ""
   until word == ""
   if found
      KillPosition()
      UnMarkBlock()
      GotoLine(found_beg_line)
      GotoColumn(found_beg_column)
      MarkStream()
      GotoLine(found_end_line)
      GotoColumn(found_end_column)
      MarkStream()
      GotoLine(found_beg_line)
      GotoColumn(found_beg_column)
   else
      Alarm()
      PopPosition()
      Message(searching, " not found.")
   endif
end
proc WhenLoaded()
    find_history = GetFreeHistory("findws:find")
end
