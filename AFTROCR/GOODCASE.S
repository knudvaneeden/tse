/*
      Macro.         Goodcase.
      Author.        Carlo Hogeveen (hyphen@xs4all.nl).
      Date-written.  12 August 1998.


      OCR software has a problem determining the case of some characters,
      which later might confuse speech software, if it finds a capital
      in the middle of an otherwise lower case word.

      Problems with case can also point to other scanning errors
      than just a simple case mistake, so you might choose to run this
      macro last.

      This macro goes thru the current text file and corrects allmost all
      case errors by using the following 4 rules:

      Rule 1: Totally upper case words are not changed.
      Rule 2: The first letters of words are not changed.
      Rule 3: Letters preceded by "mac" or "mc" in any case are not changed.
      Rule 4: Otherwise, upper case letters are changed to lower case.
*/



integer char = 0
string proc get_free_char()
   // This procedure finds a character that is not used in the text.
   repeat
      char = char + 1
   until char >= 255
      or not lfind(chr(char), "gi")
   return(chr(char))
end
proc main()
   integer ascii = 0
   string char1 [1] = ""
   string char2 [1] = ""
//   set(break, on)
   pushposition()
   pushblock()
   char1 = get_free_char()
   char2 = get_free_char()
   if char >= 255
      sound(500, 18) delay(9) sound(300, 18) delay(9) sound(100, 18) delay(9) nosound()
      message("No free characters")
   else
      // With char1 mark total upper case words of more than 1 letter.
      lreplace("{[A-Z][A-Z]#}", char1 + "\1", "ginwx")
      // Put char2 before the next part of words containg "mac" and "mc",
      // so that the letter after "mac" or "mc" will not be changed.
      lreplace("{ma?c}{[A-Z]}", "\1" + char2 + "\2", "ginx")
      for ascii = asc("A") to asc("Z")
         // Lower case letters have an ascii value that is 32 higher
         // than the ascii value of the corresponding upper case letter.
         // Search for upper case letters that are not the first letter
         // in a word, and change the letter to lower case.
         lreplace("{[a-zA-Z]}" + chr(ascii), "\1" + chr(ascii + 32), "ginx")
      endfor
      // Remove the char2 character after "mac" and "mc".
      lreplace(char2, "", "gin")
      // The words that were totally upper case have been partially lower
      // cased by the macro, now we use char 1 to find them and put them
      // back to upper case.
      begfile()
      while lfind(char1, "")
         delchar()
         markword()
         upper()
      endwhile
      sound(100, 18) delay(9) sound(300, 18) delay(9) sound(500, 18) delay(9) nosound()
   endif
   popblock()
   popposition()
end
