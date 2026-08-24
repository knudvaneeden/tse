/*
 Anagram      find all valid anagrams from the supplied letters

              for TSE32 v 2.8

  Author:     Peter Birch       plbirch@home.com                - home
  -------                       Peter_Birch@rec.raytheon.com    - work

  Revision:   Warren Porter     wbport@bellsouth.net

  Date:       01/21/2000 - v1    initial version
  -----       01/28/2000 - v1.1  added error checking, user feedback, and
                                 cleaned up unused junk
              01/29/2000 - v1.11 kept in loop until escape hit., made sure
                                 buffer was empty
              02/07/2000 - v1.12 changed user feedback to a percentage
                                 and added "hit any key to quit search"
              04/27/2000 - v2    Sort input word before using (list will
                                 be alphabetized) and eliminates
                                 duplicates.


      Spell Check stuff liberally taken from SemWare's SpellChk macro.

      Logic to create unique permutations transcribed from a program
      written by Warren Porter.

  Overview:
  ---------

  the permutation routine will find all unique arrangements of numbers
  from 1 to n.

  The recursive function visit() is called with an input string and the
  position it is responsible for.  For example when given the string
  "abcde" and position 3, the function will create output strings in
  which the third character and all following characters will occupy the
  third position, leaving other characters in order.  In this case,
  it would call itself with "abcde", "abdce", and "abecd" and
  position 4.  When called with a position more than the length of
  the word, the procedure writeperm() is called with the completed
  word to see if it is legal.

  To eliminate duplicates, this macro uses an implementation of Pascal
  language "sets".  For example, when given "banana" and position 2,
  visit() will call test_set() with each character in the word from the
  2nd position on, adding each new character to the set (here it is the
  array named "used").  After calling itself with "banana" and "bnaana"
  at position 3,  it finds other a's and n's are already in the set.

  Beware!
  Beware!
  Beware!

  The time this takes to run goes up quickly for each added letter, try
  to keep the words short... This generates N! permutations of the
  integers from 1 to N so

  a   3 letter word will have          6 permutations
  a   7 letter word will have      5,040 permutations
  an 11 letter word will have 39,916,800 permutations
  etc.

  When duplicate letters are found, the number of permutations can be
  reduced by dividing by the factorial of each duplicate.  For example,
  Mississippi (11 characters long) contains 4 i's, 4 s's, 1 m and 2 p's
  so there are

  11! / (4! * 4! * 1! * 2!) or 34,650 permutations

  if you get into a long search, hit any key to stop and show the
  results so far.

*/

/*

[File: Source: FILE_ID.DIZ]

(05-09-00) - Anagram v2.0 for TSE Pro/32 v2.8

anagram2.zip replaces anagram.zip of 02-02-00

Find all valid anagrams from the entered
letters. Includes source code. V2 includes
enhancement by Warren Porter to reduce the
time for longer words with duplicate letters
in them.

Author:     Peter Birch
            plbirch@home.com

*/

constant
    PATHLEN         = 255,
    MAX_WORD_LENGTH =  20

string main_disk_fn[ PATHLEN] = "semware.lex"    // SemWare dictionary file.

integer v       /* length of word entered by the user */
integer done    /* flag to signal that a key has been hit and to terminate the look up loop */


// ---------------------------------------------------------------------------
//
//  Spell check stuff...
//
dll "spell.dll"
    integer proc OpenSpell(string fn) : "_OpenSpell"
    integer proc CloseSpell() : "_CloseSpell"
    integer proc SpellCheckWord(string st) : "_SpellCheckWord"
    integer proc SuggestWord(string st) : "_SuggestWord"
            proc GetSuggestion(var string st, integer n) : "_GetSuggestion"
            proc RemoveQuotes(var string st) : "_RemoveQuotes"
end

// ---------------------------------------------------------------------------
// user feedback stuff

integer FactorialN
integer N

integer proc Factorial (integer N)

    integer i
    integer FactorialN

    FactorialN = 1

    for i = 2 to N
        FactorialN = FactorialN * i
    endfor

    return (FactorialN)

end

// mississippi =  ssssppmiiii = 11! / (4! * 2! * 1! * 4!) or 34,650 permutations
integer proc figure_Factorial (var string workword)

    string  currentchar[ 1]
    integer i
    integer iCount
    integer iDivisor

    currentchar = workword[ 1]
    iCount      = 1
    iDivisor    = 1

    // count duplicate letters
    for i = 2 to v

        if (currentchar == workword[ i])
            iCount = iCount + 1
        else
            iDivisor    = iDivisor * Factorial(iCount)
            iCount      = 1
            currentchar = workword[ i]
        endif

    endfor

    iDivisor = iDivisor * Factorial(iCount)

    return (Factorial(v) / iDivisor)
end

proc openwin (var string workword)

    integer iTop, iLeft, iBottom, iRight

    Message("Hit any key to stop search...")

    iLeft = (query(screenCols) / 2) - 7
    iTop  = (query(screenRows) / 2) - 3

    iRight  = iLeft + 10
    iBottom = iTop  + 4

    popwinopen(iLeft, iTop, iRight, iBottom, 1, "Working", color(Bright White on Red))

    done       = FALSE
    N          = 0
    FactorialN = figure_Factorial(workword)

    clrscr()
end

proc closewin ()
    popwinclose()
//     UpdateDisplay(_STATUSLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
end

proc working ()

    N = N + 1

    if (0 == (N mod 100))  // for speed, we don't need to do this every time.

        vgotoxy(4, 2)
        write('%' + Format((N * 100) / FactorialN)) // Show percentage done.

        if (KeyPressed())
            Done = TRUE
            GetKey()    // soak up the key
        endif

    endif

end

// ---------------------------------------------------------------------------
// see if this permutation of letters makes a valid word
//
proc writeperm (var string word)

    working()

    if (SpellCheckWord(word))
        AddLine(word)
    endif

end

// ---------------------------------------------------------------------------
// create all permutations of numbers from 1 to v
//
integer proc test_set (integer achar, var string used)

    // Implementation of the Pascal set.  Convert each character to a
    // subscript and a bit position

    integer quo
    integer target

    quo = (achar shr 3) + 1         // + 1 Since we can't use zero subscript

    target = 128 shr (achar & 7)    // (achar & 7) is the same as achar mod 8

    if (asc(used[ quo]) & target)
        return(FALSE)               // This character has been used before
    endif

    used[ quo] = chr(asc(used[ quo]) | target)

    return(TRUE)
end


proc visit (var string istring, integer l)

    integer i
    integer j
    integer l_one
    string  ostring[ MAX_WORD_LENGTH]
    string  used[ 16]                           /* room for 128 bits */

    if (not done)

        if (l == v + 1)
            writeperm(istring)
        else
            for i = 1 to Sizeof(used)           /* initialized used to all 0s */
                used[ i] = chr(0)
            endfor

            ostring = istring
            l_one = l + 1
            visit(ostring, l_one)               /* First recursive call as is */

            test_set(asc(istring[ l]), used)    /* this function has a side effect of changing used[] */

            for i = l_one to v

                if (test_set(asc(istring[ i]), used))

                    ostring = istring           /* Reinitialize */
                    ostring[ l] = istring[ i]

                    for j = l_one to v
                        if (j <= i)
                            ostring[ j] = istring[ j - 1]
                        else
                            ostring[ j] = istring[ j]
                        endif
                    endfor

                    visit(ostring, l_one)       /* recursive call */

                endif

            endfor

        endif
    endif
end

// ---------------------------------------------------------------------------
proc main ()

    integer i
    integer j
    integer currBuffer
    integer newBuffer
    string  word[ MAX_WORD_LENGTH]     = ""
    string  workword[ MAX_WORD_LENGTH]
    string  tempi[ 1]

    PushBlock()
    Set(Marking, off)
    currBuffer = GetBufferId()

    newBuffer = CreateTempBuffer()

    if (newBuffer)

        if (OpenSpell(main_disk_fn))

            while (ask("Enter letters in anagram (no spaces, <Esc> to quit): ", word))

                v = Length(word)

                if (v)

                    EmptyBuffer()

                    workword = word

                    // sort the letters in the word
                    i = 1
                    while (i < v)

                        for j = i + 1 to v
                            if (workword[ i] < workword[ j])

                                tempi        = workword[ j]
                                workword[ j] = workword[ i]
                                workword[ i] = tempi

                            endif
                        endfor

                        i = i + 1
                    endwhile

                    openwin(workword)

                    visit(workword, 1)                  // create list

                    closewin()

                    // display the list
                    if (not lFind("^.#$", "igxv"))      // regx to just skip the blank line
//                         sound(7000)                     // no matter what I do here, I just get
//                         delay(6)                        // a normal bell sound...
//                         nosound()
                        Alarm()
                        Warn("No words found for " + word + ".")
                    endif

                endif

            endwhile

            CloseSpell()

        else
            warn("Can't load word list: ", main_disk_fn)

        endif

        AbandonFile()

    else
        warn("Can't create work buffer")

    endif

    GotoBufferId(currBuffer)
    PopBlock()
    UpdateDisplay(_STATUSLINE_REFRESH_ | _REFRESH_THIS_ONLY_)

end

// ---------------------------------------------------------------------------
//  Spell check stuff..........
//
proc WhenLoaded ()

    string fn[ PATHLEN]

    fn = SearchPath(main_disk_fn, Query(TSEPATH), "SPELL\")
    if (Length(fn))
        main_disk_fn = fn
    endif

end
