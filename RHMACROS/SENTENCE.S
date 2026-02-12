/***************************************************************************
Procedure to mark a sentence.
AUTHOR:  ROB HOWSE,  SASKATOON, SK (CAN)  DEC 94

Comments and Assumptions:

How do YOU define a sentence???

Have you thought about it...???

Well, I thought about it because it seems to me any good editor ought to be
able to pick out a sentence with one keystroke and optionally delete or move
it with one more.  (And further, re-wrap the paragraph with one more; this,
of course, TSE can do.)  Anyway, to implement SENTENCE MARKING, I've taken
the following approach, which seems a little more complicated than I would
have first expected, but my first more simple approach wouldn't work in
indented paragraphs.  (I'll keep my eyes open for the first person that can
come up with the same functionality in 10 lines of code or less! <g>)

NOTE:  "Trailing white space" must be OFF for this macro to work properly.

FWIW: Here's my logic.  I hope you can follow it! ¿
                                                  ³
1. Search backwards for:                        <ÄÙ

a. ->   2 consecutive spaces      *or*
b. ->   one of [ .!?: ] (OPTIONALLY followed by a quotation mark or a closing
        paranthesis) and then immediately followed by a space or end of line
        marker, or a blank line.  *or*
c. ->   a blank line              *or*
d. ->   one of [ >} ] at the end of a line.  (helps to look after "<g>"
        comments and the like and certain programming statements.)

2. Once something is found, we do some tests in the following order:
    IF:
a. ->  at a blank line; go to beginning of line below
b. ->  at the end of a line ending with "d" or "b" above; go to beginning
       of line below
c. ->  past FNW (FirstnonWhite) and at end of "a" or "b" above; must be
       start of a new sentence right here!
d. ->  at or before FNW  (must be indented line); go to end of line ABOVE
       and check for: i.   a blank line; go to beginning of line below
                      ii.  one of [ .!?:"')>} ] ; go to FNW on line below
       otherwise loop back up to beginning "1." and continue searching.

3. If we begin on the first sentence, above procedures may be unsuccessful
   in finding its beginning (if none of the  four conditions in "1." above
   PRECEDE the sentence.  To take care of this, IF WE HAVE BEEN UNSUCCESSFUL
   SO FAR, we make one last check for a capital letter in Column 1.  If we
   find it (still looking backwards from opening cursor position), we assume
   this is the start of our sentence.

4. If we still haven't found anything to match the above criteria, we quit!

5. If successful in finding a beginning, we now look forward for the
   sentence end, which we define with the same criteria as in "1." before,
   except we omit step "3."

6. If we find something, we go to the end of the found string (that meets
   our criteria) and test for the following:
    -> If before FNW (must be indented line); go to one position before FNW
       and repeat our search forward
    -> otherwise assume we are at (or near!) the end of our sentence. To
       take care of situations where we have anywhere from one to three
       spaces between sentences (it happens!), we go right two spaces, then
       left till be hit the first space.  THIS IS THE END OF OUR SENTENCE!

7. Providing we have found both a beginning and an end, we mark our
   "sentence"!  (Note that our definition of a sentence may not exactly meet
   with the approval of a strict grammar teacher, but for our purposes, it
   works pretty well!

NOTE:  If you want to mark more than one sentence,  you will have to
extend the block with the cursor keys after marking the initial sentence.
ALSO:
If by chance, a marked block extends too far, or not far enough, you can use
the cursor keys to extend or retract the end of the block as desired.  (One
instance where this will happen is if there is only a single space between 2
sentences, and the second begins with a single letter word ("A" or "I"
typically). Also, if the cursor is not within recognizable sentence
structures (as in the middle of program source code), this may not work
exactly as desired. But then you always have the option of simply unmarking
the Block, and doing the job 'manually', don't you? <g>
***************************************************************************/

proc MarkSentence()

  integer startline = 0
  integer startcol  = 0
  integer end_line  = 0
  integer endcol    = 0

  lookbackwrd:       //remember: you will be positioned at the START of the find
   if lfind("{  }|{[.!?:][\d034'\)]@{ |$}}|{^$}|{[>}]$}", "IBX")
     if CurrChar() == _AT_EOL_               //hit a blank line looking back
         Down()  BegLine()  goto startmark   //that was easy!
     else  MarkFoundText()  GotoBlockEnd()
        if CurrChar() == _AT_EOL_        //sentence ends on line above
                Down()  BegLine()  goto startmark   //could go to FNW if desired
        endif
     endif
     if CurrPos() > PosFirstNonWhite()  goto startmark
     elseif (CurrPos() <= PosFirstNonWhite())   //now check for indented line
       Up() Endline() Left()              //then check end char on line above
       if CurrChar() == _AT_EOL_          //hit a blank line looking back
         Down()  BegLine()  goto startmark
       elseif CurrChar() == 33  Down()   goto fnw
       elseif CurrChar() == 46  Down()   goto fnw
       elseif CurrChar() == 58  Down()   goto fnw
       elseif CurrChar() == 63  Down()   goto fnw
       elseif CurrChar() == 34  Down()   goto fnw
       elseif CurrChar() == 39  Down()   goto fnw
       elseif CurrChar() == 41  Down()   goto fnw
       elseif CurrChar() == 62  Down()   goto fnw
       elseif CurrChar() == 125 Down()   goto fnw
       else  goto lookbackwrd
       endif
     endif
  elseif lfind("^[A-Z]", "IBX+")  goto startmark  //first sentence (which starts in Col 1 or 2)
  else goto quit      //couldn't find anything
  fnw:
    GotoPos(PosFirstNonWhite())
  startmark:
  UnMarkBlock()
     while CurrChar() == 32  Right()
     endwhile
  startline = CurrLine()
  startcol  = CurrCol()
  endif
  lookforend:
  if lfind("{  }|{[.!?:>}][\d034'\)]@{ |$}}|{^$}", "IX")    // ":>}" optional
    MarkFoundText() GotoBlockEnd()  Left()    //gotoblockend leaves you one 'past'
    if CurrPos() < PosFirstNonWhite()  // check for indented line
        GotoPos(PosFirstNonWhite())  Left()
        goto lookforend
    endif
         Right(2)
         while CurrChar() > (32)  Left()
         endwhile
  UnMarkBlock()
  end_line = CurrLine()
  endcol = CurrCol()
  GotoLine(startline)  GotoPos(startcol)  MarkStream()
  GotoLine(end_line)   GotoPos(endcol)
  endif

  quit:
end

proc WhenLoaded()
  if isBlockMarked()
  case YesNo("Any marked Blocks will be unmarked before sentence marking. Continue?")
     when 0, 2, 3               //ESC, Cancel or No selected
        PurgeMacro("Sentence")
     when 1                     //<y> or "Yes" selected
        UnMarkBlock()
     endcase
  endif
end

proc main()
        MarkSentence()
end
