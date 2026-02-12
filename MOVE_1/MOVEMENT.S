/****************************************************************************
 *   FILENAME:  C:\TSE\WRK\MAIL\MOVEMENT.S                                  *
 *   AUTHOR  :  "Buddy" E. Ray Asbury, Jr.                                  *
 *   DATE    :  Wed 06-30-1993 10:28:37                                     *
 *   PURPOSE :  To provide improvements over several of TSE's cursor        *
 *              movement commands through the use of SAL macro              *
 *              programming.  Each macro is preceeded by a short            *
 *              description explaining the improvement made, and how it can *
 *              be used.                                                    *
 *                                                                          *
 *              I hereby release these SAL macros to the public domain.  If *
 *              you make improvements on them, please share them freely.    *
 *                                                                          *
 *              I can be contacted either on SemWare's BBS or through any   *
 *              of the SemWare echos as "RAY ASBURY".                       *
 *                                                                          *
 *  MODIFICATIONS:                                                          *
 *                                                                          *
 *      06-30-93    ERA     Changed argument types for mGotoLocation to     *
 *                              strings. The characters "-" & "+", when     *
 *                              immediately preceding or following a value  *
 *                              causes the mGotoLocation() macro to use the *
 *                              specified values as offsets from the        *
 *                              current position.                           *
 ****************************************************************************/

/****************************************************************************
 *  The following constants are used to indentify the desired action to     *
 *  take when mGotoWord() is called                                         *
 ****************************************************************************/

CONSTANT kPREVIOUS_WORD = 1,
         kNEXT_WORD = 0

/****************************************************************************
 *  The following constants are used internally and should not be modified  *
 ****************************************************************************/

CONSTANT kROW = 1,
         kCOL = 2,
         kMINUS = 2,
         kPLUS = 3

/****************************************************************************
 *  The following variable is used to provide a history for when            *
 *  mGotoLocation() prompts for user specification of the desired location  *
 ****************************************************************************/

INTEGER gGotoLocHist = 0

/****************************************************************************
 *  The following two macros, mGotoWord1() and mGotoWord2() are dsigned to  *
 *  be used by mGotoWord().  They should not be modified, not called        *
 *  directly by the user.                                                   *
 ****************************************************************************/

INTEGER PROC mGotoWord1(INTEGER whichOne)
    IF (whichOne ==kNEXT_WORD)
        Return(WordRight())
    ENDIF
    Return(WordLeft())
END mGoToWord1

INTEGER PROC mGotoWord2(INTEGER whichOne)
    WHILE ( (mGotoWord1(whichOne)) AND (NOT IsWord()) )
        whichOne = whichOne
    ENDWHILE
    IF (IsWord())
        Return(TRUE)
    ENDIF
    Return(FALSE)
END mGotoWord2

/****************************************************************************
 *  mGotoLocation() provides the ability to either                          *
 *                                                                          *
 *      þ Go to a specific line,                                            *
 *      þ Go to a specific column                                           *
 *      þ Go to a specific line and column                                  *
 *                                                                          *
 *  by using either absolute references, or as offsets from the current     *
 *  cursor location.                                                        *
 *                                                                          *
 *  The functionality is very similar the "-n" command line option.  While  *
 *  the TSE commands, GotoColumn() & GotoLine() can accomplish the same as  *
 *  this macro, mGotoLocation() handles both lines & columns with one macro *
 *  and can be used with a SAL macro, or to prompt the user.                *
 *                                                                          *
 *  To use it with a SAL macro without prompting the user, simply call      *
 *  "mGotoLocation("<line>", "<column>")", where <line> is the line number, *
 *  or row to go to, and <column> is the column to go to.  If you wish to   *
 *  use offset values (such as to go to the line 10 lines from the current  *
 *  one), put a +/- sign immediately before or after the number.  Here are  *
 *  some valid calls:                                                       *
 *                                                                          *
 *      mGotoLocation("10", "46")       mGotoLocation("+10", "46")          *
 *      mGotoLocation("10+", "46")      mGotoLocation("10", "+46")          *
 *      mGotoLocation("10", "46+")      mGotoLocation("-10", "+46")         *
 *      mGotoLocation("10+", "46-")                                         *
 *                                                                          *
 *  If you only want to go to a particular line, use "FALSE" for <column>.  *
 *  Likewise, use "FALSE" for <line> when you want to only go to a          *
 *  particular column.                                                      *
 *                                                                          *
 *  To use it interactively, allowing the user to specify where to go to,   *
 *  simply use the call mGotoLocation(FALSE, FALSE).  For example           *
 *                                                                          *
 *      "12"        - goes to line 12, staying in the current column        *
 *      ",13"       - goes to column 13, staying on the current line        *
 *      "12, 13"    - goes to column 13 of line 12                          *
 *      "+12"       - goes to 12th line after the current line, staying in  *
 *                    the current column                                    *
 *      ",-13"      - goes to the column 13 places to the left of the       *
 *                    current cursor location, staying on the current line  *
 *      "12+, 13-"  - goes to the column 13 places to the left of the       *
 *                    current cursor position and to the line 12 lines      *
 *                    after the current line                                *
 ****************************************************************************/

INTEGER PROC mGotoLocation(STRING numRowStr, STRING numColStr)
    INTEGER cnt,                        numRow,
            numCol,                     replyLen,
            whichOne = kROW,            rowSign = FALSE,
            colSign = FALSE
    STRING reply[18] = ""

    IF (Length(numRowStr))
        CASE (numRowStr[1])
            WHEN '-'
                rowSign = kMINUS
                numRow = Val(SubStr(numRowStr, 2, (Length(numRowStr) - 1)))
            WHEN '+'
                rowSign = kPLUS
                numRow = Val(SubStr(numRowStr, 2, (Length(numRowStr) - 1)))
            OTHERWISE
                CASE (numRowStr[Length(numRowStr) - 1])
                    WHEN '-'
                        rowSign = kMINUS
                        numRow = Val(SubStr(numRowStr, 1,
                            (Length(numRowStr) - 1)))
                    WHEN '+'
                        rowSign = kPLUS
                        numRow = Val(SubStr(numRowStr, 1,
                            (Length(numRowStr) - 1)))
                    OTHERWISE
                        numRow = Val(numRowStr)
                ENDCASE
        ENDCASE
    ELSE
        numRow = FALSE
    ENDIF
    IF (Length(numColStr))
        CASE (numColStr[1])
            WHEN '-'
                colSign = kMINUS
                numCol = Val(SubStr(numColStr, 2, (Length(numColStr) - 1)))
            WHEN '+'
                colSign = kPLUS
                numCol = Val(SubStr(numColStr, 2, (Length(numColStr) - 1)))
            OTHERWISE
                CASE (numColStr[Length(numColStr) - 1])
                    WHEN '-'
                        colSign = kMINUS
                        numCol = Val(SubStr(numColStr, 1,
                            (Length(numColStr) - 1)))
                    WHEN '+'
                        colSign = kPLUS
                        numCol = Val(SubStr(numColStr, 1,
                            (Length(numColStr) - 1)))
                    OTHERWISE
                        numCol = Val(numColStr)
                ENDCASE
        ENDCASE
    ELSE
        numCol = FALSE
    ENDIF
    IF ((numRow + numCol) == FALSE)
        again:
        IF (NOT gGotoLocHist)
            gGotoLocHist = GetFreeHistory()
        ENDIF
        IF (Ask("Location (l[,c]): ", reply, gGotoLocHist))
            numRow = 0
            numCol = 0
            cnt = 1
            whichOne = kROW
            replyLen = Length(reply)
            WHILE (cnt <= replyLen)
                CASE ((reply[cnt]))
                    WHEN "0".."9"
                        IF (whichOne == kROW)
                            numRow = (numRow*10) + Val(SubStr(reply, cnt, 1))
                        ELSE
                            numCol = (numCol*10) + Val(SubStr(reply, cnt, 1))
                        ENDIF
                    WHEN '-'
                        IF (whichOne == kROW)
                            rowSign = kMINUS
                        ELSE
                            colSign = kMINUS
                        ENDIF
                    WHEN '+'
                        IF (whichOne == kROW)
                            rowSign = kPLUS
                        ELSE
                            colSign = kPLUS
                        ENDIF
                    WHEN ","
                        whichOne = kCOL
                    WHEN " "
                        whichOne = whichOne
                ENDCASE
                cnt = cnt + 1
            ENDWHILE
            IF (replyLen AND NOT numRow AND NOT numCol)
                Warn("Invalid Input")
                GOTO again
            ENDIF
        ELSE
            numRow = 0
            numCol = 0
        ENDIF
    ENDIF
    IF (numRow)
        CASE (rowSign)
            WHEN kMINUS
                IF ( (CurrLine() - numRow) > 0 )
                    GotoLine(CurrLine() - numRow)
                ELSE
                    Warn("Attempted to go past the first line")
                    Return(FALSE)
                ENDIF
            WHEN kPLUS
                IF ( (CurrLine() + numRow) <= NumLines() )
                    GotoLine(CurrLine() + numRow)
                ELSE
                    Warn("Attempted to go past the last line")
                    Return(FALSE)
                ENDIF
            OTHERWISE
                IF (NumLines() >= numRow)
                    IF (numRow > 0)
                        GotoLine(numRow)
                    ELSE
                        Warn("Attempted to go past the first line")
                    ENDIF
                ELSE
                    Warn("Attempt to go past the last line")
                ENDIF
        ENDCASE
        ScrollToRow(Query(WindowRows) / 2)
    ENDIF
    IF (numCol)
        CASE (colSign)
            WHEN kMINUS
                IF ( (CurrPos() - numCol) > 0 )
                    GotoPos(CurrPos() - numCol)
                ELSE
                    Warn("Attempted to go past column 1")
                    Return(FALSE)
                ENDIF
            WHEN kPLUS
                IF ( (CurrPos() + numCol) <= 1020 )
                    GotoPos(CurrPos() + numCol)
                ELSE
                    Warn("Attempted to go past column 1004")
                    Return(FALSE)
                ENDIF
            OTHERWISE
                IF (numCol <= 1004)
                    IF (numCol > 0)
                        GotoPos(numCol)
                    ELSE
                        Warn("Attempted to go past the first column")
                    ENDIF
                ELSE
                    Warn("Attempt to go past the column 1004")
                ENDIF
        ENDCASE
    ENDIF
    IF ((numRow + numCol) == FALSE)
        Return(FALSE)
    ENDIF
    Return(TRUE)
END mGotoLocation

/****************************************************************************
 *  mGotoBlockBegin() & mGotoBlockEnd() are improvements over the TSE       *
 *  commands GotoBlockBegin() & GotoBlockEnd().  When called, the internal  *
 *  commands, if a line block exists in the current buffer (file), do not   *
 *  go to the VERY beginning or end of the block, they simply go to either  *
 *  the first or last LINE in the block.  The cursor remains in the current *
 *  column.                                                                 *
 *                                                                          *
 *  If you are processing each character in a line block, and are using the *
 *  internal commands, you may not actually be processing the entire block. *
 *  These macros should be very handy for anyone who needs to process a     *
 *  marked block (INCLUDING line blocks) on a character-by-character, or    *
 *  word-by-word basis.                                                     *
 ****************************************************************************/

INTEGER PROC mGotoBlockBegin()
    IF (IsBlockInCurrFile())
        Return(mGotoLocation(Str(Query(BlockBegLine)),
            Str(Query(BlockBegCol))))
    ENDIF
    Return(FALSE)
END mGotoBlockBegin

INTEGER PROC mGotoBlockEnd()
    IF (IsBlockInCurrFile())
        Return(mGotoLocation(Str(Query(BlockEndLine)),
            Str(Query(BlockEndCol))))
    ENDIF
    Return(FALSE)
END mGotoBlockEnd

/****************************************************************************
 *  The internal TSE commands, WordRight() and WordLeft() work very well,   *
 *  most of the time.  However, they both see the beginning of the line (if *
 *  a word starts at a column other than 1) and the end of the line as word *
 *  seperators.  For example, if the cursor in on the first word of a line, *
 *  the that word doesn't begin in column 1, WordLeft() moves the cursor to *
 *  the first column, instead of automatically going to the previous line   *
 *  (where it also stops at the end of the line) and continuing to search   *
 *  for the previous word.  Similarly, WordRight() also stops at the same,  *
 *  NON-WORD positions.  mGotoWord() solves this problem by insuring that   *
 *  the cursor DOES ACTUALLY MOVE TO the first character of either the next *
 *  or previous word, as defined by the WordSet currently in use, or it     *
 *  does not move the cursor at all.  For example                           *
 *                                                                          *
 *      mGotoWord(kPREVIOUS_WORD) - goes to the first character of the      *
 *                                  previous word, unless it is already at  *
 *                                  the first word in the current buffer    *
 *                                  (file)                                  *
 *      mGotoWord(kNEXT_WORD)     - goes to the first character of the next *
 *                                  word, unless it is already at the last  *
 *                                  word in the current buffer (file)       *
 ****************************************************************************/

INTEGER PROC mGotoWord(INTEGER whichOne)
    PushPosition()
    IF (mGotoWord1(whichOne))
        IF (NOT IsWord())
            IF (NOT mGotoWord2(whichOne))
                PopPosition()
                Return(FALSE)
            ENDIF
        ENDIF
    ELSE
        PopPosition()
        Return(FALSE)
    ENDIF
    KillPosition()
    Return(TRUE)
END mGotoWord