/*
   Macro.         Ocr_bl.
   Author.        Carlo Hogeveen (hyphen@xs4all.nl).
   Date-written.  14 august 1998.



   This is the balanced-line version of the OCR macro.
   It runs seven and a half times faster than the simple version of
   the OCR macro, with a 1 meg text file and a 12.000 word OCR.LST file.

   It replaces supposedly badly scanned non-existing words in the current
   text file by their corresponding correct words.

   This macro is specificly targeted at non-existing words, which can be
   ruthlessly replaced by existing words without any user consultation.

   When replacing existing words, use the 2wrdlist macro instead:
   it lets the user decide, if the replacement makes sense for each
   occurrence of one of a pair of words in the text.

   This macro, the ocr_bl macro, replaces words without question,
   based on the file C:\TSE\MAC\OCR.LST, which contains two words on each
   line separated by the pipe character "|".

   The first word is ideally a nonexisting word and the second word is
   the corresponding word to replace the first word.

   The words in the OCR.LST file may only contain charaters from TSE's
   word character-set: no spaces or other non-word characters are allowed.

   The scanning of words happens case-insensitive.

   Whenever possible when replacing words in the original text file,
   the case of the new word is made equal to the case of the old word.

   The macro finishes in a newly created report file, which states
   which words were how many times replaced by which: use <alt n> and
   <alt p> to switch between the report file and the text file.

   There might be words in the OCR.LST file, which at one time seemed safe
   to always replace, but which might not be so in another context, so always
   check the macro's resulting report wether the changes are plausible.



   The following explanation is for interested macro programmers.

   Internally the Ocr_bl macro works in 7 steps:

   Step 1.  Sort the OCR.LST file on the search words.

   Step 2.  Convert the text file by splitting up the lines
            by putting each word on it's own line and preceding
            each word with it's old line number and column position
            and by reserving one character before the word to indicate
            whether and how the word is changed later on.
            Make a low sound for every one per cent of this step done.

   Step 3.  Sort the new text file on it's words.

   Step 4.  We now have two files sorted on words: the OCR.LST file
            with word pairs and the new text file.
            We walk through both files side by side comparing the words
            and updating the words in the text file as necessary.
            This side by side walking through files sorted on the same key
            is called balanced-line processing.
            If a word is changed but the size of the word does not change,
            then the change indicator in the text file is filled with a "-".
            If a word is changed and the size of the word changes too,
            then the change indicator in the text file is filled with a "+",
            and after the word in the text file a space and a number are
            added, indicating how much the word became smaller or larger.
            Make a low sound for every one per cent of this step done.

   Step 5.  Sort the text file back on the line and column positions
            of the words.

   Step 6.  Join the words back to lines.
            Here it is importent to know which words changed in size.
            Make a low sound for every one per cent of this step done.

   Step 7.  Report to the user that the macro is finished.
            Repeatedly sound 3 tones until the user presses a key,
            the three tones going down if there were no changes,
            and the three tones going up if there were changes.
            The macro finishes in a newly created report file, which states
            which words were how many times replaced by which.
*/

string ocr_filename     [255] = "c:\tse\mac\ocr.lst"
string changes_filename [255] = "c:\tse\mac\ocr.mut"

#define space 32

integer org_numlines             = 0
integer line_size                = 0
integer column_size              = 0
integer column_column            = 0
integer change_indicator_column  = 0
integer word_begin_column        = 0
integer word_end_column          = 0
integer words_changed            = 0
integer txt_id                   = 0
integer ocr_id                   = 0
integer changes_id               = 0

#ifdef WIN32
#else
   integer proc longestlineinbuffer()
      integer result = 0
      pushposition()
      begfile()
      repeat
         if result < currlinelen()
            result = currlinelen()
         endif
      until not down()
      popposition()
      return(result)
   end
#endif

proc equalize_case(string example_word, var string equalize_word)
   if example_word == lower(example_word)
      equalize_word = lower(equalize_word)
   else
      if example_word == upper(example_word)
         equalize_word = upper(equalize_word)
      else
         if example_word == (upper(example_word[1])
                            + lower(substr(example_word, 2, 255)))
            equalize_word = upper(equalize_word[1])
                            + lower(substr(equalize_word, 2, 255))
         endif
      endif
   endif
end

proc sort_file()
   /*
      TSE/32 handled the _ignore_case_ flag the wrong way around.
   */
// #ifdef WIN32
//    execmacro("sort")     No longer necessary because of the new sort macro.
// #else
      execmacro("sort " + str(_ignore_case_))
// #endif
end

proc sort_ocrfile_on_words()
   message("Sorting ocrfile on words ... ")
   delay(18)
   gotobufferid(ocr_id)
   markcolumn(1, 1, numlines(), longestlineinbuffer())
   sort_file()
   unmarkblock()
end

proc convert_textfile_to_wordfile()
   string  left_word  [255] = ""
   string  right_word [255] = ""
   string  word       [255] = ""
   integer line             = 0
   integer per_cent         = 0
   message("Converting the textfile to a wordfile ... ")
   delay(18)
   gotobufferid(txt_id)
   begfile()
   insertline()
   endfile()
   addline()
   up()
   repeat
      line = currline()
      if per_cent <> 100 - line * 100 / org_numlines
         per_cent = 100 - line * 100 / org_numlines
         message("Converting textfile to wordfile ", per_cent, " %")
         sound(111, 18)
         delay(1)
         nosound()
      endif
      endline()
      if currpos() == 1
         killline()
         up()
         addline(format(line:line_size))
      else
         repeat
            left()
         until currpos()  == 1
            or currchar() <> space
         right_word = getword()
         endline()
         wordleft()
         if currline() == line
            left_word = getword()
            if left_word <> right_word
               right(length(left_word))
            endif
         else
            gotoline(line)
            begline()
         endif
         while currchar() == space
            right()
         endwhile
         word = gettext(currpos(), currlinelen() - currpos() + 1)
         if currpos() == 1
            killline()
            up()
         else
            killtoeol()
         endif
         if word <> format(" ":length(word))
            addline(format(line:line_size, currpos():column_size, " ", word))
         endif
      endif
      up()
   until currline() == 1
   killline()
   endfile()
   killline()
end

proc sort_wordfile_on_words()
   message("Sorting wordfile on words")
   delay(18)
   gotobufferid(txt_id)
   markcolumn(1, word_begin_column, numlines(), word_end_column)
   sort_file()
   unmarkblock()
end

proc balance_the_lines()
   string  ocr_word     [255] = ""
   string  txt_word     [255] = ""
   string  replace_word [255] = ""
   integer startpos           = word_begin_column - 1
   integer length_difference  = 0
   integer stop               = false
   integer per_cent           = 0
   message("Balancing the wordfile against the ocrfile ...")
   delay(18)
   gotobufferid(ocr_id)
   begfile()
   ocr_word = gettoken(gettext(1,currlinelen()), "|", 1)
   gotobufferid(txt_id)
   begfile()
   txt_word = gettext(word_begin_column, currlinelen() - startpos)
   repeat
      if lower(txt_word) == lower(ocr_word)
         gotobufferid(ocr_id)
         replace_word = gettoken(gettext(1,currlinelen()), "|", 2)
         equalize_case(txt_word, replace_word)
         gotobufferid(txt_id)
         if txt_word <> replace_word
            gotobufferid(changes_id)
            addline(txt_word + " was 1 times replaced by " + replace_word)
            gotobufferid(txt_id)
            words_changed = words_changed + 1
            length_difference = length(replace_word) - length(txt_word)
            gotopos(change_indicator_column)
            killtoeol()
            if length_difference == 0
               inserttext("-" + replace_word)
            else
               inserttext("+" + replace_word + " " + str(length_difference))
            endif
         endif
         if down()
            txt_word = gettext(word_begin_column, currlinelen() - startpos)
         else
            stop = true
         endif
      else
         if lower(txt_word) > lower(ocr_word)
            gotobufferid(ocr_id)
            if down()
               ocr_word = gettoken(gettext(1,currlinelen()), "|", 1)
            else
               stop = true
            endif
         else
            gotobufferid(txt_id)
            if down()
               txt_word = gettext(word_begin_column, currlinelen() - startpos)
            else
               stop = true
            endif
            if per_cent <> currline() * 100 / numlines()
               per_cent = currline() * 100 / numlines()
               message("Balancing wordfile against ocrfile ", per_cent, " %")
               sound(111, 18)
               delay(1)
               nosound()
            endif
         endif
      endif
   until stop
   gotobufferid(ocr_id)
   abandonfile()
   gotobufferid(txt_id)
end

proc sort_wordfile_back_on_positions()
   integer position_size = line_size + column_size
   message("Sorting the wordfile back on positions ...")
   delay(18)
   gotobufferid(txt_id)
   markcolumn(1, 1, numlines(), position_size)
   sort_file()
   unmarkblock()
end

proc convert_wordfile_back_to_textfile()
   string  word         [255] = ""
   integer length_difference  = 0
   integer total_difference   = 0
   integer word_line          = 0
   integer word_column        = 0
   integer previous_word_line = 0
   integer per_cent           = 0
   message("Converting the wordfile back to a textfile ...")
   delay(18)
   gotobufferid(txt_id)
   unmarkblock()
   endfile()
   addline()
   begfile()
   repeat
      word_line   = val(gettext(1, line_size))
      word_column = val(gettext(column_column, column_size))
      if gettext(change_indicator_column, 1) == "+"
         endline()
         repeat
            left()
         until currchar() == space
         right()
         markchar()
         endline()
         length_difference = val(getmarkedtext())
         killblock()
         endline()
      else
         length_difference = 0
      endif
      gotopos(word_begin_column)
      word = gettext(currpos(), currlinelen() - currpos() + 1)
      killline()
      if word_line == previous_word_line
         up()
      else
         insertline()
         total_difference = 0
         previous_word_line = word_line
      endif
      gotocolumn(word_column + total_difference)
      inserttext(word, _insert_)
      total_difference = total_difference + length_difference
      down()
      if per_cent <> currline() * 100 / org_numlines
         per_cent = currline() * 100 / org_numlines
         message("Converting wordfile back to textfile ", per_cent, " %")
         sound(111, 18)
         delay(1)
         nosound()
      endif
   until currline() == numlines()
   killline()
   up()
end

proc report_changes()
   integer prev_times      = 0
   string  prev_line [255] = ""
   updatedisplay(_all_windows_refresh_)
   message(words_changed, " words changed.   Press a key to continue ... ")
   while keypressed() // Flush the keyboard buffer.
      getkey()
   endwhile
   repeat
      if words_changed > 0
         Sound(250, 18)
         Delay(3)
         Sound(450, 18)
         Delay(3)
         Sound(550, 18)
         Delay(3)
      else
         Sound(550, 18)
         Delay(3)
         Sound(450, 18)
         Delay(3)
         Sound(250, 18)
         Delay(3)
      endif
      NoSound()
      delay(36)
   until keypressed()
   getkey()
   gotobufferid(changes_id)
   markcolumn(1,1,numlines(),longestlineinbuffer())
   sort_file()
   unmarkblock()
   endfile()
   addline()
   begfile()
   prev_times = 1
   prev_line  = lower(gettext(1,currlinelen()))
   while down()
      if lower(gettext(1,currlinelen())) == prev_line
         killline()
         up()
         prev_times = prev_times + 1
      else
         up()
         lfind(" was .# times replaced ", "cgix")
         wordright(2)
         delrightword()
         inserttext(str(prev_times) + " ", _insert_)
         down()
         prev_times = 1
         prev_line = lower(gettext(1,currlinelen()))
      endif
   endwhile
   killline()
   begfile()
   insertline("There are " + str(words_changed) + " changed words.")
   message(gettext(1,currlinelen()))
   // These last two lines cause certain speech software to speak the first
   // line, otherwise it does no harm.
   find(gettext(1,currlinelen()), "cg")
   pushkey(<cursorup>)
end

proc main()
   integer old_rtw  = set(removetrailingwhite, on)
   // Pushposition and popposition don't work here. Probably another TSE bug.
   integer org_line = currline()
   integer org_pos  = currpos()
   pushblock()
   words_changed           = 0
   org_numlines            = numlines()
   line_size               = length(str(numlines()))
   column_size             = length(str(longestlineinbuffer()))
   column_column           = line_size + 1
   change_indicator_column = line_size + column_size + 1
   word_begin_column       = change_indicator_column + 1
   word_end_column         = longestlineinbuffer() - word_begin_column + 1
   txt_id                  = getbufferid()
   ocr_id                  = editfile(ocr_filename)
   changes_id              = editfile(changes_filename, _dont_prompt_)
   emptybuffer()
   sort_ocrfile_on_words()
   convert_textfile_to_wordfile()
   sort_wordfile_on_words()
   balance_the_lines()
   sort_wordfile_back_on_positions()
   convert_wordfile_back_to_textfile()
   gotobufferid(txt_id)
   gotoline(org_line)
   gotopos(org_pos)
   report_changes()
   popblock()
   set(removetrailingwhite, old_rtw)
end
