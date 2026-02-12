// Here are some procs/macs from my tse.ui file and from loadable macro files.
// I hope someone may find these useful, or perhaps discover a way of solving
// a particular problem by using the principles. I have benefitted greatly by
// learning from code written by others, and want to continue the tradition.
//   Ed Marsh   Papa's Chariot   New Cumberland, WV   fido 1:157/534.12


/***************************************************************************
   These two macs make reading through paragraphed text much simpler
   Can also be applied to moving source code into position
***************************************************************************/

proc mNxtBlnkC()                       /** <Alt F5> **/
  if lFind("^$","x")
    ScrollToRow(Query(WindowRows) / 2)
    Down()
  else Alarm()
  endif
end  //  move next blank line to center of window

proc mNxtBlnkT()                       /** <Ctrl F5> **/
  if lFind("^$","x")
    ScrollToRow(1)
    Down()
  else Alarm()
  endif
end  //  move next blank line to top of window


/***************************************************************************
   The next two macros work great together, but can be useful for other
   purposes individually. When making a chart or cheat-sheet, there may
   be a lot of space between the end of the left column and the beginning
   of the right column, because entries vary in length. Place the cursor
   anywhere between the two columns, and you will get a dot leader between
   the two, with a space separating the dots from the other data.
***************************************************************************/

proc mEndWrd()                         /** <Ctrl e> **/
  START:
      Right()
        Case CurrChar()
          when _AT_EOL_,_BEYOND_EOL_   // at or Beyond End Of Line
            Alarm()                    // warning sound
            Goto DONE
          when 0x20                    // space char
            Goto DONE                  // found what we were looking for!
          otherwise                    // if none of the above,
            Goto START                 // try again, next char right
        EndCase
  DONE:
end  //  cursor to first whitespace after current word

proc mDotLeader()                      /** <Alt .> **/
    Set(Insert, OFF)
    WordLeft()                         // move to beginning of word to left
    mEndWrd()                          // move to end of word to left
    Right()                            // leave 1 blank space
      if CurrChar() < 0                // are we at or beyond end-of-line?
          Alarm()                      // if so, it's quittin' time
          goto DONE
      endif
    while isWhite()                    // keep replacing space with dot .
        InsertText(".", _OVERWRITE_)
    endwhile                           // until no more spaces,
    Left()                             // then back up one,
        InsertText(" ", _OVERWRITE_)   // change last dot to a space
    DONE:
end  // insert dots '.' from word to left, to word to right, space each end


/***************************************************************************
   Some variations on copying char above, moving to right or down
***************************************************************************/

proc mCopyCharAboveToEol()             /** <Shift F2> **/
  while mCopyCharAbove()               // keep copying until EOL
  endwhile                             // on the line above
end

proc mCopyCharAboveDown()              /** <Alt F2> **/
    mCopyCharAbove()                   // copy from above, cursor to
    Down() Left()                      // same column, next line
end

proc mCopyCharAboveDownToEoF()         /** <Ctrl F2> **/
  repeat                               // keep on copying char above
    mCopyCharAbove()                   // down the current column
    Left()                             // until reaches bottom of file
  until NOT Down()                     // make sure InsertMode is correct
end                                    // to do what you want to do!


/***************************************************************************
   Join line below to curline, with 1 space between
***************************************************************************/

proc mjoinnext()                       /** <Alt J> **/
    EndLine()                          // goto end curline
    Right()                            // add 2 spaces
    Right()
    JoinLine()                         // bring up the line below
    Left()                             // backup to first space
    DelRightWord()                     // delete all other spaces
end  // join line below to curline, 1 space between


/***************************************************************************
   Some simple keystroke savers for beginning/ending comments in C or Pascal
   Yes, I know the extra '*' isn't needed, I just like it that way!
   The key assignments are based on seeing the 'upper' character, as () <>
***************************************************************************/

proc mBegCcmnt()                       /** <CtrlShift 9> **/
    InsertText("/** ")
end  // begin C comment

proc mEndCcmnt()                       /** <CtrlShift 0> **/
    InsertText(" **/")
end  // end C comment

proc mBegPcmnt()                       /** <AltShift ,> **/
    InsertText("(** ")
end  // begin pascal comment

proc mEndPcmnt()                       /** <AltShift .> **/
    InsertText(" **)")
end  // end pascal comment

proc mPascalAssignOper()               /** <Alt ;> **/
    InsertText(" := ")
end  // insert pascal assignment operator, and 1 space before & after


/***************************************************************************
   A handy 'rest of line' marker...column block enables easier paste over
***************************************************************************/

proc mMarkToEoL()                      /** <Alt Grey+> **/
    MarkColumn() EndLine() Left() MarkColumn() GoToBlockBegin()
end  // Mark from current position to end of line


/***************************************************************************
   Makes the current char the first on the line (column 1)
   BTW I have <Alt GreyEnd> assigned DelToEoL; they seem to go together!
***************************************************************************/

proc mDelToBegLine()                   /** <Alt GreyHome> **/
    Splitline() DelLine() BegLine()
end  // delete from cursor to beginning of line


/***************************************************************************
   Quick and easy flip one char...also handy if you accidently turn on
   the CapsLock key and type one or more words before discovering it.
***************************************************************************/

proc mFlipit()                         /** <F3> **/
    flip()
    right()
end  //  flip the case of the current char, move right


/***************************************************************************
   Did I spell that word correctly? This calls the spell checker on the
   word immediately to the left, assumes cursor on space past the word.
***************************************************************************/

proc mSpellWrdLeft()                   /** <Alt s> **/
    PushPosition()
    PushBlock()
    WordLeft()
    PushKey(<w>)
    ExecMacro("Spellchk")
    PopBlock()
    PopPosition()
end  // check spelling of word to left


/***************************************************************************
   Ultra simple, but very handy...especially when half asleep!
***************************************************************************/

proc mUp()                             /** <UpArrow> **/
    if not Up()
        Alarm()                        // hey, I can't go any farther!
    endif
end  // Beeps when can't go up, is on line 1 of file

proc mDown()                           /** <DownArrow> **/
    if not Down()
        Alarm()                        // hey, I can't go any farther!
    endif
end  // Beeps when can't go down, is on last line of file


/***************************************************************************
   EXTRACT.mac  Adapted from 2window.mac, a great one created by
   Rob Howse, Saskatoon, SK (Canada) Dec 14, 1994 )
   This variation is fast and clean: copies lines only, and only
   to the *.XTR file it creates, no printer option.
***************************************************************************/

proc mExtract()                        /** <Ctrl CenterCursor> **/
        OneWindow()                    //in case more than one open
        Hwindow()                      //now open 2nd window
        pushkey(<enter>)
        pushkey(<cursordown>)          //and resize 2nd window smaller
        pushkey(<cursordown>)
        pushkey(<cursordown>)
        pushkey(<cursordown>)
        pushkey(<cursordown>)
        pushkey(<cursorup>)
        resizewindow()

        EditFile(SplitPath(CurrFileName(), _NAME_) + ".xtr")
        EndFile()                      // change the filename ext
        AddLine()
        BegLine()                      // identify source of data
        InsertText("Extracted from   ")
      GoToWindow(1)                    // back to top window
        InsertText(CurrFileName(),_INSERT_)  // get the filename
        MarkChar()                     // temporary, will be removed
        BegLine()
      GoToWindow(2)                    // back to bottom window
        MoveBlock()                    // move the 'temp' from above
        UnMarkBlock()
        EndLine() Right() Right() Right()    // include the
        InsertText(GetDateStr(), _INSERT_)   // current date
        Right() Right() Right()              // and the
        InsertText(GetTimeStr(), _INSERT_)   // current time
        UnMarkBlock()
        AddLine() AddLine() BegLine()  // position cursor for next write
      GoToWindow(1)                    // back to top window
        FileChanged(FALSE)
        UpDateDisplay()
end  // setup *.xtr file in lower window, ready to receive extracted lines

proc mXtract()                         /** <CenterCursor> **/
    MarkLine()                         // mark the line to be extracted
  GoToWindow(2)                        // jump to bottom window
    EndFile()
    ScrollToRow(4)
    BegLine()
    CopyBlock()                        // copy the extracted line
    UnMarkBlock()
    BegLine()
    Down()                             // get ready for the next line
  GoToWindow(1)
    RollDown()
end  // copy current line to *.xtr file in lower window


/***************************************************************************
   Removes whitespace at beginning of line, hold key down to repeat
***************************************************************************/

proc mJustLeft()                       /** <CtrlShift j> **/
    BegLine()
    ShiftText(1)
    DelRightWord()
    Down()
end  //  justify line of text to LeftMargin


/***************************************************************************
   This next macro moves the cursor to the first non-whitespace char after
   the first punctuation it finds. I wrote this for a very specific job,
   but since I've not seen anything like it elsewhere, I share it in the
   hope that someone can use it, or at least the principle of it.
***************************************************************************/

proc mNextPunc()                       /** <Alt GreyCursorRight> **/
  START:
    Right()                            // begin at char to right
    Right()                            // begin at char to right
      Case CurrChar()
        when 0x2e,0x2c,0x21,0x3a,0x3b,0x3f   // . , ! : ; ?
          Goto DONE
        when _AT_EOL_,_BEYOND_EOL_     // no more punc on this line
          Alarm()                      // wake up,
          Goto QUIT                    // it's quittin' time
        otherwise
          Goto START                   // no punc here, try again
      EndCase
  DONE:
    Right()                            // now we want to skip space(s)
    if CurrChar() == 0x20
        Right()
    endif
  QUIT:
end  //  cursor to first non-white char after punctuation

