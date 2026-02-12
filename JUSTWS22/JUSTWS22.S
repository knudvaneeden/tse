/****   JustiWS Version 2.2     WordStar-like full justification macro
        09.09.1995              Deutsche Beschreibung siehe unten!


Macro written  31.7.1993 by: Paul Lenz                proppi@sampo.han.de
                             Friesenstrasse 22
                             D-30161 Hannover
                             Germany


Look at these switches:
=======================
        GERMAN     // Select your language!
       ENGLISH     // Select your language!
     TWO_SPACE     // if you like 2 SPACEs behind .!?:;
     DELHYPHEN     // if you want to delete old hyphens
     NOJUSTIFY     // Wrap function without justification


JustiWS justifies (almost) like WordStar's Ctrl-B:
--------------------------------------------------
1. - deletes multiple SPACEs and probable old hyphens
2. - joins lines until the line is too long
3. - tries to split the line
   - if the rightmost word is too long, the macro offers the possibility
     to hyphenate this word
4. - justifies too short lines by including spaces:
     at first: behind periods, exclamation marks, question marks, commas, etc.
     after this: behind every word
     equally alternate from left and right margins

This macro does NOT use ParaEndStyle,  because this works only if the macro
is started at the first line of a paragraph,  and I don't want to force the
user to do so. So this macro needs blank lines between paragraphs!



06/08/94:  ERROR after 'case upc' [approx. line 280] was ' When " '
v1.3       it should have been:
           When "Ñ","î","Å","é","ô","ö"      // German vowels.

06/08/94:  No revision indicated by Paul Lenz but changes have been made
v1.4       to the file and the ERROR above was introduced.

01/06/95:  Fixed bugs:
v1.5       The vowel() function didn't consider that Y is a vowel.
           Existing hyphens could jut out of the right margin.
           Single letter words at the end of a line could be connected
                to the first word of the next line.
           Enhancements:
           TwoSpace() inserts always two SPACEs behind periods and others

03/21/95:  Improved programming structure, more comments - so I hope
v2.0            that curious people understand it better
           Only one version for English and German language
           Improved recognizing of old hyphens
           Features and language can be switched ON or OFF

07/09/95:  It was wrong to split lines at the BegWord() position,
v2.1            because there can be e.g. a bracket before the word.
           I added the macro TrueBegWord().

09/09/95:  TrueBegWord() started working even if it had to start
v2.2            on a SPACE character.
           Improved language switches.
           New switch for those who want word wrap without justification


############################################################################
############################################################################

Bitte folgende Schalter beachten:
=================================
        GERMAN     // Sprache auswÑhlen
       ENGLISH     // Sprache auswÑhlen
     TWO_SPACE     // macht zwei Leerzeichen hinter .!?:;
     DELHYPHEN     // lîscht vermutliche alte Trennungszeichen
     NOJUSTIFY     // nur Zeilenumbruch ohne Blocksatz


JustiWS justiert AbsÑtze (fast) wie Ctrl-B von WordStar:
--------------------------------------------------------
1. - beseitigt mehrfache Leerzeichen
2. - verbindet Zeilen, bis sie zu lang sind
3. - versucht, die Zeile zu teilen
   - falls das rechte Wort zu lang ist, bietet das Macro die
     Mîglichkeit, das Wort zu trennen
4. - justiert die Zeile durch EinfÅgen von Leerzeichen:
     zuerst hinter Punkten, Ausrufezeichen, Fragezeichen, Kommata etc.,
     danach hinter jedem Wort, und zwar
     gleichmÑ·ig abwechselnd vom rechten und vom linken Rand aus

Dieses  Macro  benutzt NICHT die TSE-Variable ParaEndStyle,  weil dies  nur
dann funktioniert, wenn das Macro auf der ersten Zeile eines Satzes gestar-
tet wird,  und ich will den Benutzer dazu nicht zwingen.  Folglich  braucht
dieses Macro Leerzeilen zwischen den AbsÑtzen!


08.06.94:  Fehler in englischer Version beseitigt
v4

01.06.95:  weitere Fehler beseitigt:
v5         Vowel() berÅcksichtigte nicht, da· "Y" ein Vokal ist
           Bereits existierende Trennungszeichen konnten den
            rechten Rand Åberschreiten
           Wîrter, die nur aus 1 Buchstaben bestehen und am Ende einer
            Zeile stehen, konnten mit dem ersten Wort der nÑchsten
            Zeile verbunden werden
           Anpassung an TSE 2.0
           Erweiterungen:
           TwoSpace() fÅgt immer mindestens zwei Leerzeichen hinter .!?:;

21.03.95:  Verbesserte Programmstruktur, mehr Kommentare - damit
v2.0            neugierige Leute es besser verstehen
           Nur eine Version fÅr Englisch und Deutsch
           Verbesserte Erkennung alter Trennzeichen
           Features und Sprache kînnen ein- oder ausgeschaltet werden

09.07.95:  Wegen der Benutzung von BegWord() konnten Zeilen an der
v2.1       falschen Stelle gesplittet werden; z.B. konnte eine Klammer
                vor einem Wort von diesem abgetrennt werden.
           Zu diesem Zweck das Macro TrueBegWord() eingesetzt.

09.09.95:  TrueBegWord() begann seine Arbeit auch an einem Leerzeichen,
v2.2            anstatt dort sofort aufzuhîren.
           Verbesserte Schalter fÅr Sprachen.
           Neuer Schalter fÅr diejenigen, die nur den Zeilenumbruch
                ohne Blocksatz bevorzugen


*****************************************************************************
*****************************************************************************
*****************************************************************************/

// Switches:

#ifndef GERMAN
    #define         GERMAN TRUE    // Sprache auswÑhlen!
#endif
#ifndef ENGLISH
    #define        ENGLISH FALSE   // Select your language!
#endif
#define          TWO_SPACE FALSE   // TRUE if you like 2 SPACEs behind .!?:;
#define          DELHYPHEN TRUE    // TRUE if you want to delete old hyphens
#define          NOJUSTIFY FALSE   // TRUE if you don't want justification

//***************************************************************************

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
// TrueBegWord() goes to the first non-white character of a word,
// independent on WordSet

proc TrueBegWord()

    repeat
    until CurrChar() <= space        // Seach for SAPCE or TAB
        OR NOT Left()                //   backwards

    if CurrPos() > 1 AND CurrPos() > Query(LeftMargin)
        Right()
    endif
end

// ##########################################################################
//
// TwoSpace makes 2 SPACEs behind .!?:;

#if TWO_SPACE

   proc TwoSpace()
       MarkLine()
       lReplace("{[.!?:;] }","\1 ","xnlg")
       UnMarkBlock()
   end

#endif

// ##########################################################################
//
// FindSpace finds a given number of SPACEs
//
//      returns 1 if a matching gap is found, otherwise 0
//
// For example: we want to justify a line where the gaps between the words
// are two and three SPACEs long. Of course, we don't want to widen the
// three SPACE gaps, therefore we use this macro to find a two SPACE gap.


integer proc FindSpace(integer anzleer)     // anzleer: wanted number
    integer fs                              // fs: found number

    if direc == 1                                   // Depends on direction:
        while Right()
            if CurrChar() == space
                fs = 1                                  // Reset counter
                while Right() AND CurrChar() == space
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
// CountPunct counts the .!?:,); in a line.
// Returns the hex coded sums. Because of this method we get
// the sums and a priority of them.
// (Yes, we can count only til 16, but that should be enough!)


integer proc CountPunct()
    integer code = 0,
            diff

    GotoPos(PosFirstNonWhite())     // Beginning of text
    repeat
        Right()
        case CurrChar()
            when asc(".")
                diff = 01000000h    // Code for .
            when asc("!")
                diff =  0100000h    // Code for !
            when asc("?")
                diff =   010000h    // Code for ?
            when asc(":")
                diff =    01000h    // Code for :
            when asc(",")
                diff =     0100h    // Code for ,
            when asc(")")
                diff =      010h    // Code for )
            when asc(";")
                diff =       01h    // Code for ;
            otherwise
                diff =        0h    // Nothing special foud
        endcase
        code = code + diff          // Add code to code number

// Don't insert SPACEs between '...' oder '),' - so don't count those things!

        Right()                     // Following character
        if CurrChar() <> space      //   is no SPACE:
            code = code - diff      //   so subtract it again
        endif
        left()

    until CurrCol() == CurrLineLen() - 1
    return(code)

end


// ##########################################################################
//
// Inserts a SPACE behind each .!?:,);
// Returns 1 if justification is finished
// Returns 0 if the line is still too short


integer proc JustifyPunct(integer code)
    integer diff
    string ss[1],cs[1]      // Memory for .!?:,);

    cs = "x"                // Define dummy character
    while code > 0

         if code >    00ffffffh         // Check for priority...
             ss = "."                   //      behind this character
             diff =   01000000h         //      we will insert a SPACE
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

        if ss <> cs                     // yes, new character
            if direc == 1               // Depends on direction:
                GotoPos(PosFirstNonWhite())  //  begin left
            else
                GotoPos(CurrLineLen())  //  or right
            endif
            cs = ss                     // Save new character
        endif

// Now we search for this character:

        if direc == 1                   // Depends on direction:
            lFind(ss,"l")               //  Search to the right
        else                            //  Or...
            Left(2)     // We inserted a SPACE, so we must go left,
                        // otherwise we would find the same character again
            lFind(ss,"lb")      // and search to the left
        endif
        Right()                         // Next character
        if CurrChar() == space          // If there is a gap:
            InsertText(" ")             //   Insert SPACE
            code = code - diff      // And remove this character
                                    // from the code number
        endif

// If the line is long enough, we can stop our work:

        if CurrLineLen() == Query(RightMargin)
            direc = 1 - direc       // Toggle direction
            Return (1)              // Job competely done!
        endif

    endwhile
    Return(0)                       // there is still something to do...

end


// ##########################################################################
//
// Justify fills a line with SPACEs until it fits the margins.
// Gaps after .!?:,); are filled first

proc Justify()
    integer code,           // Code number for number of .!?:,);
            rcode,          // Memory for code number
            anzleer         // Number of SPACES to search for


    GotoPos(CurrLineLen())
    while CurrChar() == space       // Delete rightmost SPACEs
        DelChar()
        Left()
    endwhile

    GotoPos(PosFirstNonWhite())         // Beginning of text
    MarkStream()
    GotoPos(CurrLineLen())
    MarkStream()                        // Mark this line without indent

    if NOT lFind(" ","lg")              // Search for SPACEs
        UnMarkBlock()
        Return()                // No SPACEs: do not try to justify!
    endif

    anzleer = 1                     // We begin the justify work with
                                    // one SPACE gaps.
    code = CountPunct()             // Count punctuation marks
    rcode = code                    // Remember the code number

    while CurrLineLen() < Query(RightMargin)

        if code > 0                     // If there are  .!?:,);
            if JustifyPunct(code)       // Insert SPACEs after them
                UnMarkBlock()
                Return()                // Return if job is finished
            endif
            code = 0                    // don't repeat it too early
        endif

// code == 0, so we finished inserting SPACEs behind each .!?:,);
//            or we didn't find any of them...
//            anyway, now we must insert SPACEs in "plain" gaps:

        if direc == 1                    // Depends on direction:
            GotoPos(PosFirstNonWhite())  //  begin left
        else
            GotoPos(CurrLineLen())       //  or right
        endif

// We search for gaps with a given number of SPACEs:

        if FindSpace(anzleer)           // If we found such a gap:
            if direc == 0               //   If we work to the left
                Right()                 //   we must correct our position
            endif
            InsertText(" ")             // Insert SPACE
            direc = 1 - direc           // Change direction
                // because we work from both sides to the middle

        else

// We didn't found such a gap. So all gaps have the same size and
// we must search for bigger gaps:

            anzleer = anzleer + 1       // Increment gap size
            code = rcode    // Restore code number because we want
                            // first to check for .!?:,); again
        endif
    endwhile
    UnMarkBlock()                           // Unmark this line
end


// ##########################################################################
//
integer proc Vowel()            // Checks if the current character is a vowel

    string upc[1]=""            // Current character
    integer ret                 // Return value

    upc = Chr(CurrChar())       // Get current character
    upc = Upper(upc)            // Turn it to upper case
    ret = 1                     // Return 1 if the character is a vowel

    case upc
        when "A","E","I","O","U","Y"    // Usual vowels
        when "Ñ","î","Å","é","ô","ö"    // German vowels
    otherwise
        ret = 0                 // Return 0 if the character is no vowel
    endcase
    Return(ret)
end

// ##########################################################################
//
// This macro checks if this line is the last line of a paragraph:

integer proc LastLine()

    if CurrLineLen() > Query(RightMargin)
        Return(0)               // No - because we still must split this line

// Now we try to go down:

    elseif NOT Down()           // Yes - this is the last line in the file
        Return(1)

    elseif NOT PosFirstNonWhite()    // If this line is empty:
        Up()                         // We return to the previous line
        Return(1)               // Yes - this is the last line
    endif

    Up()                        // We return to the previous line
    Return(0)                   // No - this line is not the last line

end

// ##########################################################################
//
// This macro deletes multiple SPACEs

proc DelSpace()

    GotoPos(PosFirstNonWhite())         // Mark this line,
    MarkStream()                        //  but don't mark an indent!
    GotoPos(CurrLineLen())
    MarkStream()

    repeat
    until NOT lReplace("  "," ","nlg")  // Remove multiple SPACEs

    UnMarkBlock()                       // Unmark this line

end


// ##########################################################################
//
// This macro moves the cursor to the position where we want to split
// the line which is too long.
// It gives to possibility to insert a hyphen and correct its position.
//
// results: 0 if the user hits the ESC key, otherwise 1

integer proc SetSplitPos()

    string msg[79]      // Hyphe help message
    integer tflag,      // Hyphenating flag
            cpos,       // Presumed hyphenating position
            wbeg        // Word beginning position

    // This help text appears when the macro wants to hyphenate:

    #if GERMAN
        msg = " TRENNSTRICH:  " + chr(27) + " links   " + chr(26)
        msg = msg + " rechts   - trennen   ESC Abbruch   sonstige: Umbruch"
    #else
        msg = " HYPHEN:       " + chr(27) + " left    " + chr(26)
        msg = msg + " right    - hyphen    ESC break     other key: wrap "
    #endif

    tflag = 1                                   // Set hyph flag TRUE

    GotoPos(Query(RightMargin) + 2)
    repeat
    until NOT Left()                            // Search backwards:
        OR (CurrChar() == space                 //  for SAPCE or
           AND CurrPos() <= Query(RightMargin) + 1)
        OR (CurrChar() == asc("-")              //  for hyphen or
           AND CurrPos() <= Query(RightMargin))
        OR Vowel()                              //  for vowel

    if Vowel()                                  // Vowel found:
        repeat
            Left()                              // Search backwards
        until NOT Vowel()                       //  for consonant
            AND CurrPos() <= Query(RightMargin)
        cpos = CurrPos()                        // Remember this position

            // Usually this is the right location for the hyphen:
            //  the last consonant befor a vowel!

        BegWord()
        wbeg = CurrPos()                        // Remember this location

// We compare the distance between the word beginning (wbeg) and the
// hyphen position (cpos) with the min. lenght (minhyph):

        if cpos - wbeg < minhyph                // Distance is too short:
            tflag = 0                           // Reset hyph flag
            TrueBegWord()                       // Goto word beginning
        endif

        if tflag == 1                           // Yes, we hyphenate!
            BegLine()
            UpdateDisplay()                     // Display text

        // Is the hyphenating position + 7 characters visible?
        // If not, we scroll the window!

            if cpos + 7 > Query(WindowCols)
                ScrollRight(cpos - Query(WindowCols) + 7)
            endif
            GotoPos(cpos)               // Go to hypenating position
            InsertText("-")             // Insert hyphen (just so show it)
            Left()                      // Move cursor to the hyphen
            set(InsertCursorSize,8)
            Set(Cursor,ON)              // Display cursor
            Message(msg)                // display help text

            repeat
                UpdateDisplay()
                GetKey()                // Key input
                DelChar()               // delete "show" hyphen
                Message(msg)            // redisplay help text

                case Query(key)         // Which key was pressed?

                    when <CursorLeft>
                        Left()          // Move left...
                        Left()          //  and test for word beginning
                        if CurrChar() == space  // Word beginning found!
                            Right()             // --> sorry, too far!
                        endif
                        Right()         // Cancel test step
                        InsertText("-") // Insert hyphen (just so show it)
                        Left()          // Move cursor to this location

                    when <CursorRight>
                        Right()         // Move right...
                        if CurrPos() > Query(RightMargin)
                            Left()      // Cancel at right marging!
                        endif
                        InsertText("-") // Insert hyphen (just so show it)
                        Left()          // Move cursor to this location

                    when 13613, 18989   // hyphen, grey hyphen
                        tflag = 2       // Set flag (hyphenate)

                    when <escape>
                        UpdateDisplay()
                        Return(0)       // Break JustiWS macro

                    otherwise           // Other key:
                        tflag = 0       // Reset flag (don't hyphenate)
                        TrueBegWord()   //  and go to word beginning
                endcase

            // Repeat key input loop while cursor keys are pressed:
            until tflag <> 1            // cursor keys don't change tflag

            UpdateDisplay(_STATUSLINE_REFRESH_)         // Remove message

            if CurrCol() == PosFirstNonWhite()  // In this line seems to be
                GotoPos(CurrLineLen() + 1)      // only 1 word, so split
            endif                               // this line behind it!
        endif

            // At this position we want to split the line!

        if tflag > 0            // Can we / do we want to hyphenate?
            InsertText("- ")    // Yes: insert hyphen
        else
            InsertText("  ")    // No: insert SPACE
        endif

       Left()
    endif
    Return(1)
end



// ##########################################################################
// ##########################################################################
// ##########################################################################
//
proc JustiWS()          // This is the Main Macro!

    integer insmod,     // Insert mode
            cursiz      // Cursor size


    if PosFirstNonWhite() == 0              // Don't justify empty lines
        Down()
        GotoPos(1)
        Return()
    endif

    PushBlock()                             // Save extant block
    UnMarkBlock()                           // Revove extant block
    cursiz = Query(InsertCursorSize)        // Save cursor size
    insmod = Query(Insert)                  // Save old insert mode
    set(Insert,1)                           // Switch to insert mode

    direc = CurrLine() mod 2                // Direction of justification

    while NOT LastLine()                    // Stop working at last line

// This loop joins lines until the current line is too long:
        repeat
            DelSpace()                      // remove multiple SPACEs

            if CurrLineLen() > Query(RightMargin)   // If line is too long:
                break                               // Stop this loop
            endif

            if CurrLineLen() > 0            // If this line is not empty:
                GotoPos(CurrLineLen() + 2)  // Insert 1 SPACE
            endif

#if DELHYPHEN
//  This command removes probable old hyphens. I know, this command is
//  not too clever, it will also delete the important hyphen in "self-
//  confident". So - if you don't like it, set DELHYPHEN = FALSE.

            if lReplace("{[~ ]}- @$","\1","cxnb")
                GotoPos(PosLastNonWhite() + 1)
            endif
#endif

            JoinLine()                      // Connect short lines
        until LastLine()            // or until end of paragraph

#if TWO_SPACE
        TwoSpace()                  // if you want 2 SPACEs behind period
#endif

        if LastLine()               // Stop working at last line
              break
        endif

        if NOT SetSplitPos()        // move cursor to SplitLine() position
            goto exithyph           // ESC was pressed while hyphenating
        endif

    // We don't want to split a line which contains a single word
    //  which doesn't fit the margins. So we only split a line if
    //  the cursor position is on SPACE or hyphen:

        if CurrChar() == space OR CurrChar() == asc("-")
                repeat
                    Right()
                until CurrChar() <> space
                SplitLine()

            if Query(LeftMargin) > 1        // If there is a left margin:
                PushPosition()
                Down()            // Go to the back part of the splitted line
                BegLine()         // Go to the beginning
                while CurrPos() < Query(LeftMargin)
                    InsertText(" ")         // Move beginning to left margin
                endwhile
                PopPosition()
            endif
        endif

#if NOT NOJUSTIFY
        Justify()           // Justify the line
#endif

        Down()              // Continue at next line
    endwhile

    // Now we are at the last line of a paragraph

    DelSpace()              // Remove multiple SPACEs of the last line

#if TWO_SPACE
    TwoSpace()              // if you want 2 SPACEs behind period
#endif

    Down(2)                 // Go to the next paragraph
    GotoPos(1)
exithyph:
    set(Insert, insmod)                     // Reset insert mode
    set(InsertCursorSize, cursiz)           // Reset cursor size
    Set(Cursor,ON)
    PopBlock()                              // Reset block

end
