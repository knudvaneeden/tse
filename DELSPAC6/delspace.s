/*
   Macro:   DelSpace.
   Author:  Carlo.Hogeveen@xs4all.nl.
   Date:    27 July 1999.
   Version: 6.

   Purpose: Eliminates spaces inside a word.
   Uses the SpellCheck macro to determine legal words.

   Usage:   Make the file to correct the current file,
   and then execute the Fragment macro.

   After some messages you end up in a generated report,
   in which the changes are mentioned, that the fragment macro
   is going to make when you press the Enter key.

   You can use the arrow keys, the page keys, and the home and end keys
   to move around in the report, and you can use the spacebar to delete
   those lines, that you do not want the DelSpace macro to execute.

   When you are done, you can press the Enter key to execute the remaining
   changes, or you press the Escape key to abort the Fragment macro and to
   return to the original text without any changes having been made.

   History:
   -  Version 2, 31 Jul 1999:
      -  The macro was renamed to "fragment" and music was added. Really.
   -  Version 3,  7 Nov 2001:
      -  The macro was renamed to DelSpace again, the music removed,
         and the spellchecking optimized by directly addressing the binary
         or dll spellchecking programs instead of the Spellchk macro.
   -  Version 4,  8 Nov 2001:
      -  The macro immediately starts showing a percentage it has done,
         and percentages are shown 10 times more frequently.
      -  An erroneous message, that the user had to press ANY key, was removed.
   -  Version 5,  9 Nov 2001:
      -  DelSpace can now also knit one good word followed by at least one
         bad word to one good word, for instance "opera te" to "operate".
         The fragmented word doesn't have to start with a bad word anymore.
   -  Version 6, 11 Nov 2001:
      -  Punctuation was mistakenly seen as part of a word, which
         made DelSpace miss fragmented puntuated words.
      -  Deleting a line moved the cursor up, which was counter-intuitive.
      -  Fixing the first two points, as an added bonus the performance seems
         better too.
*/

#ifdef WIN32
constant
    PATHLEN = 255
dll "spell.dll"
    integer proc OpenSpell(string fn) : "_OpenSpell"
    integer proc CloseSpell() : "_CloseSpell"
    integer proc SpellCheckWord(string st) : "_SpellCheckWord"
    integer proc SuggestWord(string st) : "_SuggestWord"
            proc GetSuggestion(var string st, integer n) : "_GetSuggestion"
            proc RemoveQuotes(var string st) : "_RemoveQuotes"
end
#else
constant
    PATHLEN = 70
binary ['spellbin.bin']
    integer proc OpenSpell(string fn) : 0
    integer proc CloseSpell() : 3
    integer proc SpellCheckWord(string word) : 6
    integer proc SuggestWord(string word) : 9
            proc GetSuggestion(var string word, integer n) : 12
            proc RemoveQuotes(var string word) : 15
end
#endif

integer text_id = 0
integer report_id = 0
integer number_of_changes = 0
string report_header [255] = "DelSpace will make "

proc wait(integer seconds)
   integer counter = seconds * 18
   if counter < 0
      counter = 0
   endif
   while counter
   and   not KeyPressed()
      Delay(1)
      counter = counter - 1
   endwhile
end

proc after_command()
   if CurrLineLen() > 0
      Find("^.*$", "cgix")
   endif
end

forward proc NoCleanUp()

proc CleanUp()
   string line [255] = ""
   string old_word [255] = ""
   string new_word [255] = ""
   integer curr_line = 0
   integer curr_col = 0
   GotoBufferId(report_id)
   if lFind("^" + report_header, "gix")
      KillLine()
   endif
   EndFile()
   repeat
      if  lFind("^At", "cgix")
      and Find("^At line [0-9]+ column [0-9]+ change ", "cgix")
         line = GetText(1, CurrLineLen())
         curr_line = Val(GetToken(line, " ", 3))
         curr_col = Val(GetToken(line, " ", 5))
         new_word = GetToken(line, " ", NumTokens(line, " "))
         MarkFoundText()
         KillBlock()
         lFind(" ", "bcg")
         lFind(" ", "bc")
         KillToEol()
         old_word = GetText(1, CurrLineLen())
         GotoBufferId(text_id)
         GotoLine(curr_line)
         GotoColumn(curr_col)
         DelChar(Length(old_word))
         InsertText(new_word, _INSERT_)
      endif
      GotoBufferId(report_id)
   until not Up()
   NoCleanUp()
end

Keydef cleanup_keys
   <spacebar>        DelLine() Up() Down()
   <enter>           CleanUp()
   <Escape>          NoCleanUp()
   <cursorup>        Up()
   <greycursorup>    Up()
   <cursordown>      Down()
   <greycursordown>  Down()
   <pgdn>            PageDown()
   <greypgdn>        PageDown()
   <pgup>            PageUp()
   <greypgup>        PageUp()
   <home>            BegFile()
   <greyhome>        BegFile()
   <end>             EndFile()
   <greyend>         EndFile()
end

proc NoCleanUp()
   AbandonFile(report_id)
   GotoBufferId(text_id)
   UnHook(after_command)
   Disable(cleanup_keys)
   PopPosition()
   UpdateDisplay(_ALL_WINDOWS_REFRESH_)
   if Query(Key) == <Escape>
      Message("End of DelSpace macro: no changes were applied")
   else
      Message("End of DelSpace macro: the changes have been applied")
   endif
   Delay(36)
   PurgeMacro("DelSpace")
end

proc get_token(string line, integer pos_from,
               var integer pos_to, var string leading_whitespaces, var string token)
   // This proc returns "characters not in the wordset" as a separate token
   // for each such character, except leading whitespaces, which are returned
   // as one string in a seperate variable.
   integer token_found = FALSE
   string  char [1] = ""
   pos_to              = pos_from
   leading_whitespaces = ""
   token               = ""
   while pos_to <= Length(line)
   and   (line[pos_to] in " ", Chr(9))
      leading_whitespaces = leading_whitespaces + line[pos_to]
      pos_to = pos_to + 1
   endwhile
   while pos_to <= Length(line)
   and   not token_found
      char = line[pos_to]
      if token == ""
         token = char
         if isWord(char)
            if pos_to < Length(line)
               pos_to = pos_to + 1
            else
               token_found = TRUE
            endif
         else
            token_found = TRUE
         endif
      else
         if isWord(token)
            if isWord(char)
               token = token  + char
               if pos_to < Length(line)
                  pos_to = pos_to + 1
               else
                  token_found = TRUE
               endif
            else
               token_found = TRUE
               pos_to = pos_to - 1
            endif
         else
            Warn("Program error in macro TEST.")
         endif
      endif
   endwhile
   if not token_found
      pos_to              = 0
      leading_whitespaces = ""
      token               = ""
   endif
end

/*
integer proc get_num_tokens(string line)
   integer result   = 0
   integer token_no = 0
   integer pos_from = 1
   integer pos_to   = 1
   string leading_whitespaces [255] = ""
   string token [255] = ""
   repeat
      get_token(line, pos_from, pos_to, leading_whitespaces, token)
      if token <> ""
         token_no = token_no + 1
         pos_from = pos_to + 1
      endif
   until token == ""
   result = token_no
   return(result)
end
*/

integer proc knittable(string word)
   string  old_word [255] = ""
   string  new_word [255] = ""
   integer Curr_Line = 0
   integer Curr_Col  = 0
   integer result    = FALSE

   string  line                [255] = ""
   integer pos_from                  = 1
   integer pos_to                    = 0
   string  leading_whitespaces [255] = ""
   string  token               [255] = ""

   old_word = word
   new_word = word
   line     = GetText(CurrCol(), CurrLineLen() - CurrCol() + 1)
   pos_from = Length(word) + 1

   repeat
      Get_Token(line, pos_from, pos_to, leading_whitespaces, token)
      if pos_to
         new_word = new_word + token
         old_word = old_word + leading_whitespaces + token
         pos_from = pos_to   + 1
      endif
   until pos_to == 0
      or (   isWord(new_word)
         and SpellCheckWord(new_word))

   if  isWord(new_word)
   and SpellCheckWord(new_word)
      Curr_Line = CurrLine()
      Curr_Col  = CurrCol()
      GotoBufferId(report_id)
      AddLine(Format("At line ", Curr_Line, " column ", Curr_Col,
                     " change ", old_word, " to ", new_word))
      GotoBufferId(text_id)
      Right(Length(old_word))
      number_of_changes = number_of_changes + 1
      result = TRUE
   endif

   return(result)
end

proc Main()
   string old_WordSet [32] = Set(WordSet, ChrSet("0-9A-Za-z'"))
   string word [255] = ""
   integer Curr_Line = 0
   integer counter = 0
   number_of_changes = 0
   text_id = GetBufferId()
   report_id = EditFile(LoadDir() + "mac\delspace.txt", _DONT_PROMPT_)
   EmptyBuffer()
   Set(break, ON)
   GotoBufferId(text_id)
   if not OpenSpell(LoadDir() + "spell\semware.lex")
      Set(WordSet, old_WordSet)
      AbandonFile(report_id)
      Warn("Can't open semware.lex")
      PurgeMacro("DelSpace")
   else
      Message(CurrLine() * 100 / NumLines(), " %")
      PushPosition()
      BegFile()
      repeat
         if CurrLine() mod 100 == 0
            Message(CurrLine() * 100 / NumLines(), " %")
         endif
         word = GetWord()
         if      word <> ""
         and not SpellCheckWord(word)
            if not knittable(word)
               PushPosition()
               curr_line = CurrLine()
               WordLeft()
               if CurrLine() == curr_line
                  word = GetWord()
                  if word <> ""
                     if knittable(word)
                        KillPosition()
                     else
                        PopPosition()
                     endif
                  else
                     PopPosition()
                  endif
               else
                  PopPosition()
               endif
            endif
         endif
      until not WordRight()
      Alarm()
      Set(WordSet, old_WordSet)
      GotoBufferId(report_id)
      BegFile()
      InsertLine(Format(report_header, number_of_changes, " changes"))
      UpdateDisplay()
      repeat
         UpdateDisplay()
         case counter
            when 0
               Message("Step 1:   Use the arrow and page keys to move to lines")
            when 1
               Message("Step 2:   Use SpaceBar to delete lines you do NOT want executed")
            when 2
               Message("Step 3:   Use Enter to execute all lines, or Escape to stop DelSpace")
         endcase
         wait(3)
         counter = counter + 1
         counter = counter mod 3
      until KeyPressed()
      Enable(cleanup_keys, _EXCLUSIVE_)
      Hook(_AFTER_COMMAND_, after_command)
      CloseSpell()
   endif
end
