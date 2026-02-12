/*
      Macro.         FuBookDu.      (predecessor: bookdupe).
      Author.        Carlo Hogeveen (hyphen@xs4all.nl).
      Date-written.  31 May 1998.
      Version.       3.

      This macro removes adjoining identical line-blocks of text
      throughout the current file.

      Example: After scanning in a book and converting it to one large
               ascii file, some pages might accidentally have been
               scanned twice.

               This macro should delete those duplicate pages.

      Note: Testing proves that the macro works excellent for manually
            created adjoining identical line-blocks of text,
            but perhaps optical scanning produces artificial differences?

            If known, this macro could be expanded take those differences
            into account.

      Note: If a file One is N times as big as a file Two,
            then file Two takes N to the power 3 times as long to check.

            In other words, short files take very little time to check,
            while large files take a lot longer.

            To give an indication: A very large 1 megabyte textfile
            took 27 minutes to check using the Dos version of TSE
            on a Pentium 90 machine. A text file that was a quarter
            in size took only 39 seconds.
*/


// Global variable to remember the value of getclockticks() at start time.
integer start_clockticks = 0


integer proc longestlinelen()
   // Return what the length of the longest line in the current file is.
   // TSE Pro/Win32 has a built-in command to do this.
   // TSE Pro/Dos needs a little piece of program.
   integer result = 0
   #ifdef WIN32
      result = longestlineinbuffer()
   #else
      pushposition()
      begfile()
      repeat
         if result < currlinelen()
            result = currlinelen()
         endif
      until not down()
      popposition()
   #endif
   return(result)
end


string proc in_time_text()
   // Getclockticks returns the current time in clockticks.
   // 18 clockticks are 1 second.
   // The variable start_clockticks has been filled with the time
   // in clockticks at the start of the macro.
   // We return the number of minutes and seconds since the start of
   // the program.
   string result[40] = ""
   integer seconds = (getclockticks() - start_clockticks) / 18
   if seconds < 60
      result = " in "
               + str(seconds)
               + " seconds"
   else
      result = " in "
               + str(seconds / 60)
               + " minutes and "
               + str(seconds mod 60)
               + " seconds"
   endif
   return(result)
end


proc main()
   // Supposing there are two adjoining blocks of identical text,
   // we call them block1 and block2.
   // This is data about the first line of block1.
   integer block1_line_nr           = 0
   integer block1_line_len          = 0
   string  block1_line_text[254]    = ""

   // This is data about the line that is "lines_down" lines down
   // from block1_line.
   integer block1_down_len          = 0
   string  block1_down_text[254]    = ""

   // This is all the data we need to remember for block2.
   integer block2_line_nr           = 0

   // A boolean to tell the rest of the macro we have deleted a block.
   integer block_deleted            = false

   // A boolean to tell we have found two equal adjoining blocks.
   integer blocks_are_equal         = false

   // Count the deleted blocks, so we can report later on.
   integer number_of_blocks_deleted = 0

   // This variable is used to repeatedly go the same number of lines down
   // from the begin of both block1 and block2, and to compare the resulting
   // lines.
   integer lines_down               = 0

set(Break, ON)
   // TSE's find command and therefore this macro only work for
   // lines of 254 characters or less.
   if longestlinelen() <= 254
      // Log the time we start.
      start_clockticks = getclockticks()
      // Save where we are in the current file.
      pushposition()
      // This macro might run a long time (more than a few seconds).
      // Therefore tell the user it is running.
      message("Now scanning for adjoining identical blocks of text ...")
      // Start from the begin of the current file.
      begfile()
      // Repeat downwards for each line in the current file.
      repeat
         // If a block was deleted in the previous loop, then the cursor is
         // now on the second line of what was the second block.
         // However, this block could have been triplicate or more, so we have
         // to check the same text again, so we go up one line just to make
         // sure we do not miss a triplicate.
         if block_deleted
            block_deleted = false
            up()
         endif
         // Let's investigate, if the current line is the first line
         // of the first block of two adjoining identical blocks of text.
         // Start by getting the current line.
         block1_line_nr   = currline()
         block1_line_len  = currlinelen()
         block1_line_text = gettext(1, block1_line_len)
         // Now check all following lines, whether one of them is the
         // first line of an adjoining identical block of text, until
         // we find and delete a block or until we find no more identical
         // first lines.
         // The endline ensures we will not find the current line again.
         endline()
         while not block_deleted
         and   lfind(block1_line_text, "")
         and   currlinelen() == block1_line_len
            // Get the first line of this potential adjoining block.
            block2_line_nr   = currline()
            // Now we check if the text in the lines from block1_line_nr
            // upto block2_line_nr - 1 matches with the text starting
            // at line block2_line_nr.
            blocks_are_equal = true
            lines_down = 1
            while blocks_are_equal
            and   block1_line_nr + lines_down < block2_line_nr
               // Go lines_down lines down from block1 and remember the line.
               gotoline(block1_line_nr + lines_down)
               block1_down_len  = currlinelen()
               block1_down_text = gettext(1, block1_down_len)
               // Also go lines_down lines down from block2.
               gotoline(block2_line_nr + lines_down)
               // And compare the current line to the remembered line
               // from block1.
               if  currlinelen()             == block1_down_len
               and gettext(1, currlinelen()) == block1_down_text
                  // The blocks are still equal so far,
                  // prepare to go one more line down.
                  lines_down = lines_down + 1
               else
                  // The lines and therefore the blocks are not equal,
                  // so we can stop comparing the rest of these two blocks.
                  blocks_are_equal = false
               endif
            endwhile
            if blocks_are_equal
               // Delete the first block.
               markline(block1_line_nr, block2_line_nr - 1)
               killblock()
Sound(500, 18) Delay(1) NoSound()
               // A block is deleted: count it.
               number_of_blocks_deleted = number_of_blocks_deleted + 1
               // Get out of the while loop and go up one line.
               block_deleted = true
            endif
            // The endline ensures we will not find the current line again.
            gotoline(block2_line_nr)
            endline()
         endwhile
         // We have been walking through two blocks,
         // now return to the line from where we started our block comparing.
         gotoline(block1_line_nr)
         // Repeat until end of file.
Sound(25, 18) Delay(1) NoSound()
      until not down()
      // Return to the original position in the current file.
      popposition()
      // Now report what we have found and done.
      if number_of_blocks_deleted == 0
         sound(400, 18) delay(2) nosound()
         message("No blocks were deleted",
                 in_time_text())
      else
         sound(400, 18) delay(2) nosound()
         message("There were ",
                 number_of_blocks_deleted,
                 " adjoining identical blocks deleted",
                 in_time_text())
      endif
   else
      sound(400, 18) delay(2) nosound()
      message("Bookdup cannot handle lines > 254")
   endif
end

