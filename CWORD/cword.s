/*
 Cword        (Short for "crossword") find all words from known letters
               and "wild cards" (asterisks) for TSE32 v 2.8

  Author:     Warren Porter     wbport@bellsouth.net
  ------

  Date:       05/29/2001 - v1    initial version


      Spell Check stuff liberally taken from SemWare's SpellChk macro
      and Peter Birch's "anagram.s" macro.  Credit also to Peter Birch
      for the Progress Window.

  Overview:
  ---------

  When given a lower case word containing one or more asterisks (*), each
  letter of the alphabet is substituted for the asterisks and run through
  the SpellChk macro.  For example, when given "c**", this macro will
  return a list of all three letter words starting with the letter "c".

  Beware!
  Beware!
  Beware!

  The time this takes to run goes up quickly for each added asterisk.  The
  number of words to be checked equals 26 to the number of asterisks
  power.  For four asterisks in the word, this is 456,976 words to be
  passed through SpellChk.

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

integer MaxCount
integer N

proc openwin ()

    integer iTop, iLeft, iBottom, iRight

    Message("Hit any key to stop search...")

    iLeft = (query(screenCols) / 2) - 7
    iTop  = (query(screenRows) / 2) - 3

    iRight  = iLeft + 10
    iBottom = iTop  + 4

    popwinopen(iLeft, iTop, iRight, iBottom, 1, "Working", color(Bright White on Red))

    done       = FALSE
    N          = 0

    clrscr()
end

proc closewin ()
    popwinclose()
end

proc working ()

    N = N + 1

    if (0 == (N mod 100))  // for speed, we don't need to do this every time.

// MaxCount was earlier divided by 100.  The following would crash if run
// with one asterisk (26/100 = zero in integer arithmetic), but the above
// 'mod' test prevents this.

        vgotoxy(4, 2)
        write('%' + Format(N / MaxCount)) // Show percentage done.

        if (KeyPressed())
            done = TRUE
            GetKey()    // soak up the key
        endif

    endif

end

// ---------------------------------------------------------------------------
// see if this combination of given and assigned letters makes a valid word
//
proc writeperm (var string word)

    working()

    if (SpellCheckWord(word))
        AddLine(word)
    endif

end
proc main ()

    integer i
    integer currBuffer
    integer newBuffer
    integer cntAster = 0
    string  asterLoc[ 5] ="\0\0\0\0\0" // Location of asterisks in reverse
    string  asterVal[ 5] = "aaaaa"     // Initial value of asterisks
    string  word[ MAX_WORD_LENGTH]     = ""
    string  workword[ MAX_WORD_LENGTH]

//  PushBlock()
//  Set(Marking, off)
    currBuffer = GetBufferId()

    newBuffer = CreateTempBuffer()

    if (newBuffer)

        if (OpenSpell(main_disk_fn))

            loop
              if (ask("Enter known letters and * for unknown (no spaces, <Esc> to quit): ", word))

                word = Lower(word)

                v = Length(word)

                if (v)   // Count asterisks only to determine if user error
                  cntAster = 0
                  for i = 1 to v
                    if word[i] == "*"
                      cntAster = cntAster + 1
                    endif
                  endfor
                endif

                if (cntAster == 0)
                  Warn("No asterisks, I don't have anything to do")
                  v = -1 // Gives user another chance
                endif

                if (cntAster > 5 )
                  Warn("I can't handle more than five asterisks")
                  v = -1 // Gives user another chance
                endif
               else  //User pressed ESC at the Ask() so exit
                  v = 0
               endif
                if ( v > 0)

                    EmptyBuffer()

                    for i = 1 to 5
                     asterLoc[i] = chr(0)
                    endfor

                    workword = word
                    MaxCount = 1  // since this value will be multiplied
                    N        = 0
                    cntAster = 0  // have to recount
                    // done in reverse so list will be alphabetized
                    for i = v downto 1
                      if workword[i] == "*"
                         cntAster = cntAster + 1
                         asterLoc[cntAster] = chr(i)
                         MaxCount = MaxCount * 26
                      endif
                    endfor

//                  Divided by 100 so will be ready to display percentage done
                    MaxCount = MaxCount / 100


                    for i = 1 to cntAster   //fill in all 'a's the first time
                      workword[asc(asterLoc[i])] = "a"
                    endfor
                    asterVal = "aaaaa"

                    openwin()

                loop

                  writeperm(workword)

                  if done
                    break
                  endif

                 // following increments like a 5-digit, base 26 "number"
                  asterVal[1] = chr(asc(asterVal[1]) + 1)

                  if asterVal[1] > 'z'  // if need to carry
                    if cntAster > 1     // if only one * we break
                      asterVal[1] = "a" // change this position to "a" (0)
                      asterVal[2] = chr(asc(asterVal[2]) + 1) //carry next pos
                      if asterVal[2] > "z"
                        if cntAster > 2
                          asterVal[2] = "a"
                          asterVal[3] = chr(asc(asterVal[3]) + 1)
                          if asterVal[3] > "z"
                            if cntAster > 3
                              asterVal[3] = "a"
                              asterVal[4] = chr(asc(asterVal[4]) + 1)
                              if asterVal[4] > "z"
                                if cntAster > 4
                                  asterVal[4] = "a"
                                  asterVal[5] = chr(asc(asterVal[5]) + 1)
                                  if asterVal[5] > "z"
                                    break
                                  endif
                                  workword[asc(AsterLoc[5])] = asterVal[5]
                                else
                                  break
                                endif
                              endif
                              workword[asc(AsterLoc[4])] = asterVal[4]
                            else
                              break
                            endif
                          endif
                          workword[asc(AsterLoc[3])] = asterVal[3]
                        else
                          break
                        endif
                      endif
                      workword[asc(AsterLoc[2])] = asterVal[2]
                    else    // Only had one position, reached 'z' so break out
                      break
                    endif
                  endif  // Loc 1 changed regardless of carry so after endif
                  workword[asc(AsterLoc[1])] = asterVal[1]
                endloop

                closewin()

                // display the list
                if (not lFind("^.#$", "igxv")) // regx to just skip the blank line
                    Alarm()
                    Warn("No words found for " + word + ".")
                endif

                else
                  if (v == 0)
                    break
                  endif
                endif
              endloop

            CloseSpell()

        else
            warn("Can't load word list: ", main_disk_fn)

        endif

        AbandonFile()

    else
        warn("Can't create work buffer")

    endif

    GotoBufferId(currBuffer)
//  PopBlock()
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
