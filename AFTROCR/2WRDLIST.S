/*
   Macro.         2wrdlist.
   Author.        Carlo Hogeveen (hyphen@xs4all.nl).
   Date written.  24 juli 1998.
   Version.       27 juli 1998.

   This macro is based on Skip's macro 2wrdsrch.
   It adds: Reading the swap words from a wordfile.
            Swapping words case-sensitive.
            Swapping words automatically with option A.

   This macro is specificly targeted at existing words, so that a user
   is necessary to decide which word is the correct one: non-existing
   words can always be replaced and that is done a lot faster with
   another macro, the Ocr_bl macro.

   Execute this macro, the 2wrdlist macro, to put it to work on the
   currently loaded textfile.

   The macro repeatedly reads a pair of words from the wordfile
   "c:\tse\mac\2wrdlist.wrd", and then tries to find each occurrence
   of both these two words in the textfile.

   The theory is, that OCR software can mistake two words for each other
   both ways, so we have made it so, that you need to add a word pair to
   the OCR.LST file only once and in either order (except when using the
   "A" option, see later on).

   If a word from the OCR.LST file is found in the text file, then the grey
   minus key can be used to swap the found word with the other word of the
   pair, and the grey plus key can be used to find the next occurrence of
   one of the words from the OCR.LST file in the text file.

   The grey enter key can be used to skip occurences of the current word pair
   in the text file and to proceed with the rest of the words in the OCR.LST
   file.

   The grey forward slash key displays a message stating the current word
   pair from the OCR.LST file.

   When swapping words, the case of the word is preserved.

   The wordfile consists of lines in the following format:

      word1 word2 options

   Options can be: w, a, aw, wa or none.

      A  "W" option means to search for whole words: if a word from the
                    OCR.LST file will not be found where it is only a part
                    of a word in the text file.
      An "A" option means to allways replace word1 by word2 automatically,
                    and never the other way around.

   If words were replaced automatically, we sound the trumpet.

   Words that should be swapped automatically, can be replaced a lot faster
   by the ocr_bl macro than by this macro, so it makes sense not to use
   the A option of this macro.


   27 juli 1998.
      Added an updatedisplay() command to solve what is probably a bug
      in TSE2.5(e).
      Added a branch in swap_case_sensitive() to allow for swapping numbers
      with words.
*/

string wordfile_name[255] = "c:\tse\mac\2wrdlist.wrd"

string word1[255] = ""
string word2[255] = ""

integer wordfile_id = 0
integer textfile_id = 0

string search_a [1] = "a"

proc swap_case_sensitive(string foundword, string replaceword)
   string insertword [255] = ""
   if foundword == lower(foundword)
      if foundword == upper(foundword)
         insertword = replaceword // E.g. when foundword is a number.
      else
         insertword = lower(replaceword)
      endif
   else
      if foundword == upper(foundword)
         insertword = upper(replaceword)
      else
         if foundword == (upper(foundword[1]) + lower(substr(foundword, 2, 255)))
            insertword = upper(replaceword[1]) + lower(substr(replaceword, 2, 255))
         else
            insertword = replaceword
         endif
      endif
   endif
   DelBlock()
   InsertText(insertword, _INSERT_)
end

proc SwapWord()
   string FoundWord[255] = ""
   MarkFoundText()
   FoundWord = GetMarkedText()
   if Lower(FoundWord) == Lower(word1)
      swap_case_sensitive(foundword, word2)
   elseif Lower(FoundWord) == Lower(word2)
      swap_case_sensitive(foundword, word1)
   endif
end

proc trumpet()
   sound(1200, 18) delay(1) nosound() delay(1)
   sound(1300, 18) delay(1) nosound() delay(1)
   sound(1400, 18) delay(1) nosound() delay(1)
   sound(1700, 18) delay(4) nosound() delay(1)
   sound(1400, 18) delay(1) nosound() delay(1)
   sound(1700, 18) delay(9) nosound() delay(1)
end

proc find_next_word()
   /* We disable beep, because we don't want a beep for each single word
      from the wordlist that is not found: instead there is a tone when
      none of the remaining words in the list is found.
   */
   integer old_beep = set(beep, off)
   integer stop = false
   integer automatically = 0
   string search_for [255] = ""
   string options [25] = ""
   string option_a [1] = ""
   string option_w [1] = ""
   repeat
      gotobufferid(wordfile_id)
      begline()
      word1 = getword()
      wordright()
      word2 = getword()
      wordright()
      options = lower(getword())
      if pos("a", options)
         option_a = "a"
         search_for = word1
      else
         option_a = ""
         search_for = "{" + word1 + "}|{" + word2 + "}"
      endif
      if pos("w", options)
         option_w = "w"
      else
         option_w = ""
      endif
      gotobufferid(textfile_id)
      updatedisplay() // Necessary for TSE 2.5: otherwise markfoundtext error.
      if  search_a == option_a
      and Find(search_for, option_w + "ix+")
         right()              // "Why?" asks Carlo.
         if option_a == "a"
            SwapWord() // Always replace word1 by word2.
            automatically = automatically + 1
         else
            stop = true // Stop for the user to decide.
            if automatically > 0
               message("Number of words replaced automatically: ",
                       automatically)
               trumpet()
               automatically = 0
            endif
         endif
      else
         gotobufferid(wordfile_id)
         if down()
            gotobufferid(textfile_id)
            begfile()
         else
            if search_a == "a"
               search_a = ""  // Go through the wordfile again, this time
               begfile()      // handling the wordpairs without option a.
            else
               stop = true
               Message("No more words found")
               Sound(500, 18) Delay(1) NoSound()
            endif
         endif
         gotobufferid(textfile_id)
      endif
   until stop
   set(beep, old_beep)
end

proc Main()
   search_a = "a"
   textfile_id = getbufferid()
   // We make an invisible copy of the wordfile to work from.
   if getbufferid(wordfile_name)
      gotobufferid(getbufferid(wordfile_name))
      markline(1,numlines())
      copy()
      gotobufferid(textfile_id)
   else
      editfile(wordfile_name)
      markline(1,numlines())
      copy()
      abandonfile()
      gotobufferid(textfile_id)
   endif
   wordfile_id = createtempbuffer()
   paste()
   unmarkblock()
   begfile()
   gotobufferid(textfile_id)
   begfile()
   find_next_word()
end

<Grey+> find_next_word()
<Grey-> SwapWord()
// <Grey*> Left() DelChar()
<GreyEnter> EndFile() Alarm() find_next_word()
<Grey/> Message(word1+" with "+word2)

