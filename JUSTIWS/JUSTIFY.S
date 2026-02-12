/*****************************************************************************

JustiWS justifies (almost) like WordStar's Ctrl-B:
--------------------------------------------------
1. - deletes multiple SPACEs
2. - joins lines until the line is too long
3. - tries to split the line
   - if the rightmost word is too long, the macro offers the possibility
     to hyphenate this word
4. - justifies too short lines by including spaces:
     at first: behind periods, exclamation marks, question marks, commas, etc.
     after this: behind every word
     equally alternate from left and right margin
 
This macro does NOT use ParaEndStyle, because this works only if the
macro is started at the first line of a paragraph. So this macro needs
blank lines between paragraphs!
 
 
  Macro written  31.7.1993 by: Paul Lenz
                               Friesenstrasse 22
                               D-30161 Hannover
                               Germany
 
*****************************************************************************/
 
// Global variables:
 
integer direc       // working direction
                    // 1 = from left to right
                    // 0 = from right to left
 
// Constants:
 
constant    minhyph = 3,        // min. lenght between word beginning and
                                //  hyphen
            space = asc(" ")
 
 
// ##########################################################################
//
// FindSpace finds a given number of SPACEs
//
//      returns 1 if a matching gap is found, otherwise 0
//
// For example: we want to justify a line where the gaps between the words
// are two and three SPACEs long. Of course we don't want to widen the
// three SPACEs gaps. So we use this macro to find a two SPACEs gap.
 
 
integer proc FindSpace(integer anzleer)     // anzleer: wanted number
    integer fs                              // fs: found number
 
 
    if direc == 1                                   // Depends on direction:
        while right()
            if CurrChar() == space
                fs = 1                                  // Reset counter
                while right() AND CurrChar() == space
                    fs = fs + 1                         // Count SPACEs
                endwhile
                if fs == anzleer                        // Wanted number
                    return(1)                           // found!
                endif
            endif
        endwhile
    else
        while left()
            if CurrChar() == space
                fs = 1                                  // Reset counter
                while left() AND CurrChar() == space
                    fs = fs + 1                         // Count SPACEs
                endwhile
                if fs == anzleer                        // Wanted number
                    return(1)                           // found!
                endif
            endif
        endwhile
    endif
    return(0)                                           // NOT FOUND!
end
 
 
// ##########################################################################
//
// Justify fills a line with SPACEs until it fits the margins.
// Gaps after .!?:,); are filled first
 
proc Justify()
    integer lira,           // Position of left margin or indent
            code,           // Code number for number of .!?:,);
            rcode,          // Memory for code number
            diff,           // For byte.wise calculation of code number
            anzleer         // Number of SPACES to search for
    string ss[1],cs[1]      // Memory for .!?:,);
 
 
    GotoPos(CurrLineLen())
    while CurrChar() == space       // Delete rightmost SPACEs
        DelChar()
        left()
    endwhile
 
    if CurrLineLen() < Query(RightMargin)   // Don't justify too long lines
                                            // because they don't have gaps!
 
        lira = PosFirstNonWhite()           // Beginning of text
        GotoPos(lira)
        MarkStream()
        GotoPos(CurrLineLen())
        MarkStream()                        // Mark this line without indent
        if NOT lFind(" ","lg")              // Search for SPACEs
            UnMarkBlock()
            return()                // No SPACEs: do not try to justify!
        endif
 
        anzleer = 1                     // Begin the justify work with
                                        // one SPACE gaps!
        code = 0                        // Reset code number
        GotoPos(lira)                   // Beginning of text
        repeat
            right()
            case CurrChar()
                when asc(".")
                    diff = 01000000h    // Code for .
                when asc("!")
                    diff = 0100000h     // Code for !
                when asc("?")
                    diff = 010000h      // Code for ?
                when asc(":")
                    diff = 01000h       // Code for :
                when asc(",")
                    diff = 0100h        // Code for ,
                when asc(")")
                    diff = 010h         // Code for )
                when asc(";")
                    diff = 01h          // Code for ;
                otherwise
                    diff = 0            // Nothin special foud
            endcase
            code = code + diff          // Add code to code number
 
// Don't insert SPACEs between '...' oder '(,' - so don't count those things!
 
            right()                     // Following character
            if CurrChar() <> space      //   is no SPACE:
                code = code - diff      //   so subtract it again
            endif
            left()
 
        until CurrCol() == CurrLineLen() - 1
        rcode = code                    // Remember the code number
 
        while CurrLineLen() < Query(RightMargin)

            if code > 0                 // If there were  .!?:,);
 
                cs = "x"                // Define "impossible" character
                while code
 
                    if code >    00ffffffh  // Check for priority...
                        ss = "."            //      behind this character
                        diff =   01000000h  //      we will insert a SPACE
                    elseif code > 00fffffh
                        ss = "!"
                        diff =    0100000h
                    elseif code >  00ffffh
                        ss = "?"
                        diff =     010000h
                    elseif code >   00fffh
                        ss = ":"
                        diff =      01000h
                    elseif code >    00ffh
                        ss = ","
                        diff =       0100h
                    elseif code >     00fh
                        ss = ")"
                        diff =        010h
                    else
                        ss = ";"
                        diff =         01h
                    endif
 
 
// If we found a new character to insert a SPACE behind it
//      we restart the procedure on the left or right margin:
 
                    if ss <> cs
                        if direc == 1               // Depends on direction:
                            GotoPos(lira)           //  begin left
                        else
                            GotoPos(CurrLineLen())  //  or right
                        endif
                        cs = ss                     // Save new character
                    endif
 
// Now we search for this character:
 
                    if direc == 1                   // Depends on direction:
                        lFind(ss,"l")               //  Search to the right
                    else                            //  Or...
                        left(2)             // We inserted a SPACE, so we
// must go left, otherwise we would find the same character again
                        lFind(ss,"lb")      // and search to the left
                    endif
                    right()                         // Next character
                    if CurrChar() == space          // If there is a gap:
                        InsertText(" ")             //   Insert SPACE
                        code = code - diff      // And remove this character
                                                // from the code number
                    endif
 
// If the line is long enough, we can stop our work:
                    if CurrLineLen() == Query(RightMargin)
                        direc = 1 - direc       // Toggle direction
                        break
                    endif
 
                endwhile
 
            else
 
// code == 0, so we inserted SPACEs behind each .!?:,);
//            or we didn't find any of them...
//            anyway, now we must insert SPACEs in "plain" gaps:
 
                if direc == 1                    // Depends on direction:
                    GotoPos(lira)                //  begin left
                else
                    GotoPos(CurrLineLen())       //  or right
                endif
 
// We search for gaps with a given number of SPACEs:
 
                if FindSpace(anzleer)   // If we found such a gap:
                    if direc == 0       //   If we work to th left
                        right()         //   we must correct or position
                    endif
                    InsertText(" ")             // Insert SPACE
                    direc = 1 - direc           // Change direction
                        // because we work from both sides to the middle
 
                else
 
// We didn't found such a gap. So all gaps have the same size and
// we must search for bigger gaps:
 
                    anzleer = anzleer + 1       // Increment number
                    code = rcode    // Restore code number because we want
                                    // first to check for .!?:,); again
                endif
            endif
        endwhile
        UnMarkBlock()                           // Unmark this line
    endif
end
 
// ##########################################################################
 
integer proc Vocal()            // Checks if a character is a vocal
 
    string upc[1]=""            // Current character
    integer ret                 // Return value
 
    upc = Chr(CurrChar())       // Get current character
    Upper(upc)                  // Turn it to upper case
    ret = 1                     // Return 1 if the character is a vocal
 
    case upc
        when "A","E","I","O","U"        // Usual vocals
        when "  // German vocals
    otherwise
        ret = 0                 // Return 0 if the character is no vocal
    endcase
    return(ret)
end
 
// ##########################################################################
 
 
// This macro checks if this line is the last line of a paragraph:
 
integer proc LastLine()
 
    if CurrLineLen() > Query(RightMargin)
        return(0)               // No - because we must split this line

// Now we try to go down:
 
    elseif NOT Down()           // Yes - this is the last line in the file
        return(1)
 
    elseif CurrLineLen() == 0   // Yes - the following line is empty
        Up()                    //       We return to the last line
        return(1)
    endif
 
    Up()                        // We return to the last line
 
    return(0)                   // No - this line is not the last line
 
end
 
// ##########################################################################
 
// This macro deletes multiple SPACEs and hyphnes
 
proc DelSpace()

    GotoPos(PosFirstNonWhite())         // Mark this line, 
    MarkStream()                        //  but don't mark an indent!
    GotoPos(CurrLineLen())
    MarkStream()
 
    repeat
    until NOT lReplace("  "," ","nlg")  // Remove multiple SPACEs
 
    repeat
    until NOT lReplace("- ","","nlg")   // Remove hyphens
 
    UnMarkBlock()                       // Unmark this line
 
end
 
// ##########################################################################
 
proc JustiWS()          // This is the Main Macro!
 
    integer cpos,       // Presumed hyphenating position
            wbeg,       // Word beginning
            tflag,      // Hyphenating flag
            ky,         // Key input
            insmod,     // Insert mode
            cursiz      // Cursor size
 
    // This help text appears when the macro wants to hyphenate:
    string msg[78] = " HYPHEN:   " + chr(27) + " left    " + chr(26)
           msg = msg + " right    - hyphen    ESC break    other key: wrap "
 
    PushBlock()                             // Save extant block
    UnMarkBlock()                           // Revove extant block
    cursiz = Query(InsertCursorSize)        // Save cursor size
    insmod = Query(Insert)                  // Save old insert mode
    set(Insert,1)                           // Switch to insert mode
 
    direc = CurrLine() mod 2                // Direction of justification
 
    if CurrLineLen() == 0                   // Don't justify empty lines
        goto endmacro
    endif
 
    while NOT LastLine()                    // Stop working at last line

        repeat
 
            DelSpace()                      // remove multiple SPACEs
 
            if CurrLineLen() > Query(RightMargin)   // If Line is too long:
                break                               // Stop this loop
            endif
 
            if CurrPos() > 1                // If this line is not empty:
                GotoPos(CurrLineLen() + 2)  // Insert 1 SPACE
            endif
 
            JoinLine()                      // Connect short lines until
                                            //  they are too long
        until LastLine()            // or until end of file
 
        if LastLine()               // Stop working at last line
            break
        endif
 
        GotoPos(Query(RightMargin) + 2)
        repeat
        until NOT left()                            // Search backwards:
            OR CurrChar() == space                  //  for SAPCE or
            OR CurrChar() == asc("-")               //  for hyphen or
            OR Vocal()                              //  for vocal
        tflag = 1                                   // Set hyph flag
 
        if Vocal()                                  // Vocal found:
            repeat
                left()                              // Search backwards
            until NOT Vocal()                       //  for consonant
            cpos = CurrPos()                        // Remember this position
 
                // Usually this is the right location for the hyphen:
                //  the last consonant befor a vocal!
 
            repeat                                  // Search on backwards
                if CurrChar() == space              //  for word beginning
                        OR CurrChar() == asc("-")   //  or hyphen
                    right()                         // Go to word beginning
                    break
                endif
            until not left()
 
            wbeg = CurrPos()                        // Remember this location
 
    // We compare the distance between the word beginning (wbeg) and the
    // hyphen position (cpos) with the min. lenght (minhyph):
 
            if cpos - wbeg < minhyph                // Distance is too short:
                tflag = 0                           // Reset hyph flag
            endif
 
            if tflag == 1                           // Yes, we hyphenate!
                GotoPos(1)                          // Go to left margin
                UpdateDisplay()                     // Display text
 
            // Is the hyphenating position + 7 characters visible?
            // If not, we scroll the window!
 
                if cpos + 7 > Query(WindowCols)
                    ScrollRight(cpos - Query(WindowCols) + 7)
                endif
                GotoPos(cpos)               // Go to hypenating position
                InsertText("-")             // Insert hyphen
                left()                      // Move cursor to the hyphen
                set(InsertCursorSize,8)     // Display cursor
                Set(Cursor,ON)
                Message(msg)                // display help text
 
                repeat
                    UpdateDisplay()
                    ky = GetKey()           // Key input
                    DelChar()               // delete hyphen
                    Message(msg)            // redisplay help text
 
                    case ky                 // Which key was pressed?
 
                        when 19200          // Cursor left:
                            left()          // Move left...
                            left()          //  and test for word beginning
                            if CurrChar() == space  // Word beginning found!
                                right()             // --> sorry, too far!
                            endif
                            right()         // Cancel test step
                            InsertText("-") // Insert hyphen
                            left()          // Set cursor on this location
 
                        when 19712          // Cursor right:
                            right()         // Move right...
                            if CurrPos() > Query(RightMargin)
                                left()      // Cancel at right marging!
                            endif
                            InsertText("-") // Insert hyphen
                            left()          // Set cursor on this location
 
                        when 13613          // hyphen (white key)
                        when 18989          // hyphen (grey key)
                                            // Do nothing in this loop
 
                        when 283            // Escape
                            UpdateDisplay()
                            goto exithyph   // Break this macro!!!
 
                        otherwise           // Other key:
                            tflag = 0       //  don't hyphenate!
                            GotoPos(wbeg)   //  and go to word beginning
                    endcase

                // Repeat key input loop while cursor key are pressed:
 
                until ky == 283 OR ky == 13613 OR ky == 18989 OR tflag == 0
 
                Set(Cursor,OFF)
                UpdateDisplay()
 
            // At this position we want to split the line!
 
                if CurrCol() == 1    // In this line seems to be only 1 word!
                    repeat              // Go to end of that long word
                    until CurrChar() == space OR NOT right()
                    if NOT right()
                        GotoPos(CurrLineLen() + 1)
                    endif
                endif
 
                if tflag == 1           // Do we want to hyphenate?
                    InsertText("- ")    // Yes: insert hyphen
                else
                    InsertText("  ")    // No: insert SPACE
                endif
            else
                InsertText("  ")
            endif
            left()
        endif
 
    // We don't want to split a line which contains a single word
    //  which doesn't fit the margins. So we only split a line when
    //  the cursor position is on SPACE or hyphen:
 
        if CurrChar() == space OR CurrChar() == asc("-")
            right()
            SplitLine()
 
            if Query(LeftMargin) > 2        // If there is a left margin:
                PushPosition()
                Down()            // Go to the back part of the splitted line
                GotoPos(1)                  // Go to the beginning
                while CurrPos() < Query(LeftMargin)
                    InsertText(" ")         // Move beginning to left margin
                endwhile
                PopPosition()
            endif
 
        endif
 
        Justify()           // Justify the line
 
        Down()              // Continue at next line
    endwhile
 
    // Now we are at the last line of a paragraph
 
    DelSpace()              // Remove multiple SPACEs of the last line
    Down()                  // Go to the empty line behind the paragraph
 
endmacro:
    Down()                  // If there is one empty line, this step brings
    GotoPos(1)              //  us to the beginning of the next paragraph
exithyph:
    set(Insert,insmod)                      // Reset insert mode
    set(InsertCursorSize,cursiz)            // Reset cursor size
 
    PopBlock()                              // Reset block

end

