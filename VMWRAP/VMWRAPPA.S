/**********************************************************************
procedure==>  vmWrapPara ()  <== ver. 1.1 by Volker Multhopp  08/15/93
              with subprocedure and tips.


Abstract:   vmWrapPara() is designed as a straight up replacement for the TSE 
            editor function WrapPara(), EXCEPT that it will NOT delete 
            trailing white space.  

Returns:  Number of lines traversed in the re-formatting process (but not all 
          of those lines will necessarily be altered).


           IF YOU (WILL) ALWAYS HAVE SET(RemoveTrailingWhite, ON), 
               THEN THIS PROCEDURE WILL HAVE NO VALUE FOR YOU. 
        
        (Unless you want to play with alternate paragraph end styles,)
                (or otherwise alter paragraph re-formatting.)




                            CONTENTS OF THIS FILE:

                      Reformatting paragraphs with TSE
                      How to Implement vmWrapPara()
                      COMMENTS
                      Paragraph endstyles (defined)
                      Paragraph endstyles (comments to)
                      Glossary; Definitions
                      procedure vmWrap_Borrow() -- source code
                      procedure vmWrapPara ()   -- source code



                      Reformatting paragraphs with TSE:

    When the native TSE function WrapPara() wraps (reformats) a paragraph, 
each line is shortened or lengthened to the current right margin, until the 
procedure has determined that the end of the paragraph has been reached.  
Additionally, the line may be shifted left or right to match the effective 
left margin.  Any line which is altered will lose all the trailing white 
space, regardless of the RemoveTrailingWhite setting.

    Your paragraph reformat key ( <alt b>? ) probably is, and should be bound 
to the enhanced user interface procedure mWrapPara().  mWrapPara() will wrap 
all paragraphs within a marked blocked, permitting a faster reformat of a 
large text section.  Better yet, if there is a marked column block, it will 
reformat only text with that column.

    Unfortunately, for the those of us who want to keep trailing white, or who 
want to keep two spaces after sentence-periods, the TSE WrapPara()s are 
frustrating.  That's why I wrote this macro.  Additionally the user can fiddle 
with the source code to change ways the effective left margin and paragraph 
ends are determined.  There is a specific provision for an alternate paragraph 
end style (search for "style 3").  There is a discussion on different 
paragraph end styles further below.



                        How to Implement vmWrapPara()

    vmWrapPara() can be used as external macro.  But it is better to burn it 
in with the editor, so it is always there working, saving trailing whites when 
set(RemoveTrailingWhite, off), and so that it can be called by the enhanced 
mWrapPara() procedure.

    External:

    1.  Edit this file (vmwrappa.s).  At the end of the file add a line 
    binding a key to the procedure.  Eg.  <alt b> vmWrapPara()

    2.  Compile the file.  This can be done either from the editor 
    ( <ctrl f9> ? ), or from DOS ( "SC VMWRAPPA").

    3.  Move the resulting *.MAC file to your MAC directory.

    4.  When you want to use it in an edit session, first load the macro 
    ( <ctrl f10> ?, then "vmwrappa"), then you can repeatedly execute the 
    procedure with the bound key.

    
    Internal (burning in) [TSE 1.0] :

    1.  Make sure this file is in your user interface directory (UI).

    2.  Edit your main user interface file (TSE.S ?).  In the beginning add 
    the line ' #INCLUDE ["VMWRAPPA.S"] '.  

        At this point you will also want to modify the procedure mWrapPara() 
    so it will call vmWrapPara() not WrapPara().  To do that REPLACE all
    "ÿWrapPara" with "ÿvmWrapPara", EXCEPT* in the line in mWrapPara where the 
    column block is handled.  That line should be "until not WrapPara()"-- 
    leave it alone.  The leading white spaces are important!  Do not replace 
    "WrapPara" with "vmWrapPara" (because otherwise you'll change mWrapPara to 
    mvmWrapPara).

        Also make the replacements in your other "#INCLUDE" files, probably 
    TSE.KEY.

    3.  Quit the editor (well, your configuration file is up-to-date, isn't 
    it?).  Burn in the editor with "sc -bE TSE", or whatever the name of your 
    editor *.EXE and your main user interface files are.


    *(note) vmWrapPara() does not work within the mWrapPara() column mode 
    code, because mWrapPara() essentially creates false trailing white space.



                                   COMMENTS

    1. Trailing white space is information.  Information lost is not always 
easily regained.  If you always lose trailing white, and you separate 
sentences with double spaces, and a sentence ends at a line end, you will lose
one of the spaces.  You could search for short sentence separations after you 
are finished editing, and repair the damage.  But that's extra work, you might 
miss some, and you might make some false repairs.  There are other 
possibilities for where more than one consecutive space might appear in text 
(eg. tables), reformatting could be costly.

    On the other hand, trailing white space can cause problems sometimes, 
particularly when printing.  If the invisible white space causes the line to be 
longer than the print width (say 80 characters), then the printer will likely 
print an extra line to accommodate the (invisible) overflow.  A whole
file can be trimmed easily enough, though, before sending to a printer with 
lReplace('[\t ]#$','','gxn').


    2.  Actually I don't like the cursor wandering when I am reformatting.  
You might want to try an extended wrap function: 
        
        proc x_Wrap() 
            pushposition()
            mWrapPara() 
            popPosition() 
        end 
        <alt b> x_Wrap()


    3.  vmWrapPara() doesn't care whether RemoveTrailingWhite is ON or OFF; it 
doesn't even check for the condition.


                        Paragraph endstyles (defined):

    Here some different ways for determining where a paragraph within an ASCII 
text ends, starting from an arbitrary cursor position.  There are many other 
possibilities.  The numbers given are arbitrary:

    0.  A blank line or EOF.  TSE WrapPara() Style 0.  Everyone must agree 
    this always ends a paragraph.  All other styles incorporate this as an 
    alternate stopper.

    1.  TSE WrapPara() style 1.  If the first and second lines have DIFFERENT 
    indents, then the paragraph ends when a new line has the first indent.  
    This is not how the 1.0 manual describes the operation.

    2.  TSE 1.0 manual (pg 204) description of 1 style.  Paragraph ends when a 
    line has the first indent.

    3.  Like 1, but if first and second lines have the SAME indent, then the 
    paragraph ends with any line having ANY different indent.

    4.  Stop on any line after the second which is not indented equal to the 
    second.

    5.  Like 1, but if first and second lines have the SAME indent, then 
    search backwards (up) until a line is encountered with a different indent.  
    Then go down.  The paragraph ends when another line has that same indent.


                      Paragraph endstyles (comments to):

    0.  This is idiotproof.  But some people just don't like this system, they 
    like paragraphs touching each other, providing some kind of aesthetic 
    connection between paragraphs.  Because of these people (I'm one of them, 
    sometimes) all problems arise.

    1.  This is a pretty good system.  But it really just gives up on touching
    paragraphs and runs wild to the first blank line, if the reformat begins 
    on any line that is followed by a line with the same indent.  Another 
    problem is that even if the first two lines have different indents, the 
    reformatting might run through subsequent paragraphs, if they have 
    slightly different (not exactly equal) indents.

    2.  This is pretty useless-- reformatting completely stops after the first 
    line, if that line is followed by one with the same indent.

    3.  (style 3)  This is my system.  It will not "run amok" if reformatting 
    begins on the first of two equally indented lines.  The main problem, as I 
    see it, is that it cannot deal well with the ragged left problem, unless 
    reformatting begins on the first of two differently indented lines.  For 
    some people this is a serious consideration.  But it's my experience that 
    reformatting is usually done to correct the right side of the paragraph, 
    not the left.  This system does also suffer from the second problem 
    mentioned in 1. above, but basically this is a conservative system that 
    will reformat too little as opposed to too much.

    4.  This one never copes with ragged left.  On the other hand, it is never
    troubled by changing paragraph indents.  Maybe I like this better than my 
    own system.  Very conservative.

    5.  This is the first of what could be an arbitrarily expanded slew of 
    increasingly "smart" systems.  Like 1. it deals with the ragged left 
    problem.  It always does come to a proper stop if the next paragraph is 
    properly indented.  It also suffers from the "slightly wrong" indent 
    problem.


                            Glossary; Definitions:

    Effective Left Margin-- The place where all lines of the paragraph, except 
        the first, should begin.  This is not necessarily the editor variable 
        LeftMargin.  If AutoIndent is ON or STICKY, use the indent of the 
        second line.

    First Line-- The cursor line when the paragraph wrap is called.  This is 
        certainly not what you or I would always call the first of line of the 
        paragraph.
 
    Indent-- I use this word in two different senses that should be clear from 
        the context.  The indent of a line is the column of the first 
        non-white character.  The indent of a paragraph is the indent of the 
        paragraph's FIRST line.  The paragraph indent is often greater than 
        the effective left margin.  Sometimes, the indent may be less than the 
        effective left margin, this is called a hanging indent or an outdent 
        and is particularly useful if the first word is a keyword for the 
        whole paragraph.  Or the paragraph may be "unindented" (undented?), in 
        which case it needs to separated from others by a blank line.

    Non-white-- See White Space.

    Paragraph-- One or more adjacent sentences bound by a common idea or the 
        author's insistence, and physically separated from others in the text.  
        All lines after the first one should have the same indent.

    Raw Line-- I consider a line to be "raw" if it does not have any trailing 
        white space.  If a word is added to this line, a space will have to be
        added first.

    Right Margin-- the point beyond which there should be no non-white 
        characters.  Use the editor variable RightMargin.

    White Space-- Space occupied by the space character (chr(32)) and/or the 
        hard tab (chr(9)) only-- not chr(0) or chr(255) or anything else.

**********************************************************************/

proc vmWrap_Borrow(integer pad)  // this is a subroutine only.
    //  this subroutine deletes the marked borrow text, appends it
    // to the line above.
    delblock()
    up()
    endline()
    if pad
        // the line ends 'raw'.
        insertText(' ', _insert_)
    endif
    undelete()  // hanging the deleted text onto the end of the line 
    return()

end  // of vmWrap_Borrow ().

/**************************************************************************
main routine
**************************************************************************/

integer proc vmWrapPara ()

integer
    arm ,   // Actual Right Margin
    pad,    // flag that indicates the short line needs a space.
    indent, // indentation of first line of paragraph.
    Ef_Left,    // effective left margin
    first_line,  // flag to indicate the first line of a paragraph
    Lines_todo,  //  counter
    Start_Line, // marks initial position
    Last_Dark,    // column of last nonwhite char.
    First_Dark,   // column of first nonwhite char.
    adjust,
    flag,
    i

    /**********************************************************************
    // start
    **********************************************************************/

    arm = query(RightMargin)
    arm = iif (arm, arm, 1) // not 0
    start_line = currline()
    pushblock()     // don't forget to restore.
    unmarkblock()   


    // If on a blank line, drop till non blank
    flag = 0
    while PosFirstNonWhite() == 0 
        if not down()
            flag = 1
            break
        endif
    endwhile
    if flag
        // we're done, at eof.
        goto done_paragraph
    endif

    // we're on a non-blank line, so let's get to work.
    /**********************************************************************
    This is the paragraph analysis section.
    When done, lines_todo must have correct count of no. lines in para.
    **********************************************************************/

    pushposition()  // we're coming back.

    // get indent
    gotopos(posFirstNonWhite())
    indent = currcol()

    // count how many lines in this paragraph.
    // this is where the end-of-paragraph strategy plays.
    lines_todo = 1
    first_line = true
    flag = false    // flag here will mean first two lines have same indent.

    while down() and posFirstNonWhite() // either failure will end parag.

        if query(paraEndStyle) == 1 // indent style.
            gotopos (posFirstNonWhite())
            if first_line  
                // actually we're on second line!
                first_line = false
                if currcol() == indent
                    flag = true  // ie. indent of 1 and 2 are equal.
                endif
            else
                // we're on the 3+th line.
                if flag
                    // do nothing -- style 1
                    //if currcol() <> indent break endif  
                 // ^^ uncomment the above line for style 3
                else
                    if currcol() == indent
                        break   // next para per style 1 and 3
                    endif
                endif
            endif
        endif

        lines_todo = lines_todo + 1
    endwhile
    popPosition()
    // done counting lines_todo

    // get Ef_Left (effective left margin), 
    Ef_Left = query(leftmargin)

    if query(autoindent)    // some kind of autoindent
        // preset
        Ef_Left = indent
        if lines_todo > 1
            // use the indent of the next line for Ef_Left
            down()
            gotoPos(posFirstNonWhite())
            Ef_Left = currcol()
            up()    // get back
        endif
    endif
    Ef_Left = iif (Ef_Left, Ef_Left, 1) // never 0.

    // ok, we're back to the first real line. 
    // we have Ef_Left and indent and lines_todo.  Reset first line flag.
    first_line = true

    // end of analysis section.

    /**********************************************************************
    // Start of physical reformat
    **********************************************************************/
    // Ok, this is the loop executed for each line, until the EOParagraph 
    // is reached.

    while lines_todo

        GotoPos(PosFirstNonWhite())
        First_Dark = currCol()

        if not first_line
            // If this is not the first line, this might be a ragged left,
            // so fix it.
            adjust = First_Dark - Ef_Left  // adjust > 0 if we're too far right.
            if adjust
                // Fix to Ef_Left.
                if adjust > 0
                    GotoColumn(Ef_Left)     // go to where we're s'posed to be.
                    // eat space
                    while isWhite()
                        delChar()   // eating spaces and hardtabs alike.
                    endwhile
                else
                    // insert spaces (we're still on first dark)
                    while adjust < 0
                        insertText(' ',_insert_)
                        adjust = adjust + 1
                    endwhile
                endif
            endif
            first_dark = ef_left  // cause we made it so.
        endif // completing the ragged left problem.

        /******************************************************************
        Here we start dealing with the end of line problems.
        find the last dark char
        ******************************************************************/
        gotoPos(PosLastNonWhite())
        Last_Dark = currcol()

        // This line is either short, too long, or just right.
        if Last_Dark == arm
            goto Line_OK
        endif

        if Last_Dark > arm
            /**************************************************************
            We're TOO LONG.
            let's hack off what we don't need,
            unless there is only one word.
            **************************************************************/
            gotoColumn(arm + 1)
            // this is the critical column

            if isWhite()
                DRIFT_RIGHT:
                // drift RIGHT until not white
                while isWhite() and right()
                    // must fail on a dark
                endwhile

                HACK:
                /**********************************************************
                Hack the too long line-- 
                delete from cursor pos.,
                add a new line, go to eff left margin, undelete, 
                reset lines_todo counter, and get back as if nothing happend.
                **********************************************************/
                delToEol()
                addLine()
                gotoColumn(Ef_Left)
                unDelete()
                Lines_todo = Lines_todo  + 1 // since we've added a line.
                up()
                goto Line_OK     // since we've solved the too long problem
                // for the current line.

            endif


            // We're on a non-white
            // drift LEFT till we're white
            while not isWhite() and left()  
            endwhile
            // step back onto a dark
            if isWhite()
                right()
            endif

            if currCol() > First_Dark
                goto hack
                // let the routine above handle things.
            else
                // Wemighthavejustonewordwhichistoolongtohack, but there might be more words on this line.
                while not isWhite() and right() and currchar() >= 0
                endwhile  // finding white or  eol
                if currcol() > Last_Dark
                    // One looong word, don't hack it, 
                    goto Line_OK
                else
                    goto drift_right    // let the routine above handle
                endif
            endif


        endif


        /******************************************************************
        Last dark is less than right margin.
        Here we deal with the TOO SHORT problem.
        ******************************************************************/
        TOOSHORT:
        endLine()
        left()  // get on last char of line

        adjust = arm - currcol()
        // adjust is the distance from last any char to right margin.
        // if adjust is neg, then white space has padded the line
        // beyond the right margin.  That's ok.

        pad = iif (isWhite(), 0, 1)
        // pad means this is a raw line,
        // we will have to add a space to this line, if we 
        // borrow from next.

        adjust = adjust - pad
        // Now Adjust is the amount of nonwhite material
        // that we can borrow from the next line.

        if adjust > 0 and lines_todo > 1
            /**************************************************************
            the line is shorter than right margin, and there is another
            line to the paragraph.
            So we'll see if can borrow from the next line, 
            otherwise we're done this line.
            **************************************************************/

            down()
            gotoPos(PosFirstNonWhite())     //unfailable
            First_Dark = currcol()
            unMarkBlock()
            MarkStream()
            right(adjust)    // taking our stream block to ONE space
                             // BEYOND our maximum carrying capacity.

            /**************************************************************
            There are three possibilities now:
             We've landed on a non white character,
             We've landed on a white character, or
             We've gone beyond the eol.
            **************************************************************/

            if currChar() >= 0 and not isWhite()
                /**********************************************************
                We're not white nor beyond eol,
                so we're on a non-white.
                We've bitten off more than we can chew.
                Let's move left until first white and borrow.
                **********************************************************/
                while left() and not IsWhite() 
                endwhile

                if currCol() > First_Dark
                    // we can borrow/lend now from here.
                    vmWrap_Borrow(pad)
                else 
                    // it's just one word which is too long,
                    // we can't do anything except return.
                    up()
                endif
                goto Line_OK
            endif

            if isWhite()    // good!
                /**********************************************************
                We can take this white and GrabExtraWhite: 
                we have to carry all trailing white with us.
                **********************************************************/
                while isWhite() 
                    right() 
                endwhile

                if currChar() >= 0  // ie not beyond eol
                    left()  // get back on last white.
                    vmWrap_Borrow(pad)
                    goto Line_OK
                // else let next block handle the matter.
                endif
            endif

            if currChar() < 0
                // we're beyond eol
                // borrow the whole line, less leading white space.
                endline()
                left()  // getting on last char. 
                vmWrap_Borrow(pad)
                down()  // returning us to the line we've borrowed from
                delLine()   // since we've taken everything of substance.
                lines_todo = lines_todo - 1 // !
                // return to the work line.
                up()
                goto tooShort   // We're not necessarily done the current line,
                // since there's no guarantee that it's long enough!
            endif

        // else nothing to do.
        endif


        Line_OK:
        first_line = false   // there's no more special treatment 
        // of the first line.

        // go to next line.
        // the line has been done, is the paragraph?
        lines_todo = lines_todo - 1
        down()

    endwhile

    // we're out of the while loop, and on 
    // first line AFTER the last line of the paragraph, or EOF.

    // restore 
    done_paragraph:
    popblock()

    gotoColumn(indent) // courtesy
    lines_todo =  currline() - start_line  // now means lines done.

    message(lines_todo,' lines formatted.') // entertainment

    return(lines_todo)


end  // of vmWrapPara ().

// test 
//<alt b>   vmWrapPara ()
