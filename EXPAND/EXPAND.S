/**************************************************************************
  Word ... A macro to expand a just-typed abbreviation by offering
           choices of words (a) from an abbreviation list or (b) found in
           the current document, whose beginning matches the abbreviation.
 **************************************************************************

               Expand(), Version 1, 8-19-93, David Marcus.

Expand() begins by looking the word up in an abbreviation file. If it
finds a match, it displays the expansion of the abbreviation. The word
being offered appears highlighted on text line, replacing the
abbreviation you type. Then:

     * To reject it, press 'N' or press the Expand() key.

     * To accept it, press any other key. This should be the next
       keystroke you want in your file, because Expand() will pass it to
       TSE for processing.

       (If, right here in this file, you type "key<expand key>s", you'll
       have "keystrokes" as the result.)

     * To end without accepting, press <escape>

** NOTE ** Be sure to set the file name before using Expand(). Search
           for 'expand.lst' to locate the definition of it. (NOTE: If
           Expand() cannot find the file it simply ignores it.

If you don't accept any suggestion from the abbrevs file , Expand() begins
offering words starting from current word and working backwards. (No word
is offered more than 1 time.)

If no word is found and accepted between the abbreviation and the
beginning of the file, a forward search is performed from the
abbreviation to the end of the file.

                            Replacement Case

Expand() matches the case of your abbreviation.  For instance:

          Abbreviation        Expansion
          ------------        ---------
            repl              replace        // all lower case
            REPL              REPLACE        // all caps
            RePl              RePlace        // caps mapped abbr:expansion
            REPl              REPlace        //
            rEP               rEPlace        //

Add a '-' to the end of your abbreviation to bypass this case mapping.
For instnace, if 'Replace' is on line 1 of your file and you are on line 2:

          Abbreviation        Expansion
          ------------        ---------
            repl-             Replace        // all lower case
            REPL-             Replace        // all caps
            RePl-             Replace        // caps mapped abbr:expansion
            REPl-             Replace        //
            rEP-              Replace        //

                       Adding to the Abbrevs File

If you accept a word, it is automatically added to the abbrevs file _if_
the abbreviation you used is 3 or more characters. This lets you use
abbreviations between documents, transparently.

If you want to add a word to the abbrevs file, press the Expand() key at
the beginning of a line.

*** WARNING: ***
     If you use Expand(), edit the abbrevs file, and then use Expand() again
     in the same edit session, your edits will be lost.

                             The Expand() Key

This file uses a key assignment of <`>.

Please change this in the CONSTANT section of this file ... not the keydef.

 **************************************************************************/

forward integer          proc query_user()
forward                  proc done()
forward                  proc reject()
forward integer          proc Get_Ready()
forward                  proc set_position(INTEGER TYPE)
forward                  proc goto_position(INTEGER TYPE)

CONSTANT
     startup_key =  <`>,
     ORIGINAL = 1,       // for TYPE in set/goto_position
     ABBREV_BEGIN = 3,
     LAST_FIND = 2       // for TYPE in set/goto_position

STRING
     abbrev[24]='',      // the abbreviation
     abbrev_case[24]='', // maps the case of abbrev with 1s and 0s
     re_abbrev[48]='',   // altered form of above, for reg_exp search use
     rest_of_line[255]='', // rest of line after abbrev

     possible[64]='',    // the found word
     lo_possible[64]='', // the found word, lowercased

     abbrev_file[24]= 'q:\expand.wrd',      // external list
     exp_msg[48]='',
     exp_options[3]=''  // used internally - do not change

INTEGER
     abbrev_buffer,      // holds abbrev_file
     exp_cid,           // current file id
     reject_buffer=0,    // list of words found -- used to avoid
                         // giving the user the same choice more
                         // than once
     RTW=0,              // remove trailing spaces initial state
     KM=0,               // killmax original state
     start_line=0,       // original position
     start_col=0,        //
     ab_line=0,          // beginning of abbrev
     ab_col=0,           //
     find_line=0,        // beginning of find
     find_col=0,
     XMarksTheSpot=0,
     YMarksTheSpotToo=0,
     exp_key=0,         // keystrokes to select/not select word
     case_flag = 1       // do case matching; set internally

/**********************************************************************
                         PROCS
 **********************************************************************/

/*************************************************
     Set_Position()
          Sets various values equal to various
          positions.
 *************************************************/
proc set_position(INTEGER type)
     case TYPE
          when ORIGINAL
               start_line = CurrLine()
               start_col  = CurrCol()
          when LAST_FIND
               find_line  = CurrLine()
               find_col   = CurrCol()
          when ABBREV_BEGIN
               GotoBufferID(exp_cid)
               ab_line    = CurrLine()
               ab_col     = CurrCol()
          otherwise
               warn('bad arg for set_position')
     endcase
end

/*************************************************
     Goto_Position()
          Goes to prenamed positions.
 *************************************************/
proc goto_position(INTEGER type)
     case TYPE
          when ORIGINAL
               GotoBufferID(exp_cid)
               GotoLine  (start_line)
               GotoColumn(start_col )
          when ABBREV_BEGIN
               GotoBufferID(exp_cid)
               GotoLine  (ab_line)
               GotoColumn(ab_col )
               updatedisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
               updatedisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
          when LAST_FIND
               GotoLine  (find_line)
               GotoColumn(find_col )
          otherwise
               warn('bad arg for goto_position')
     endcase
end

/*************************************************
     Get_Ready()
          Goes to prenamed positions.
 *************************************************/
integer                  proc Get_Ready()
     Set(Break,On)
     abbrev_file= 'q:\abbrevs.wrd,'          // external abbreviations list
     exp_cid=GetBufferID()
     case_flag = 1
     re_abbrev = ''
     abbrev = ''
     abbrev_case = ''
     possible = ''
     lo_possible = ''
     RTW = Set(RemoveTrailingWhite, OFF)
     KM  = Set(KillMax,0)
     PushBlock()

     if not abbrev_buffer and FileExists(abbrev_file)
          abbrev_buffer = CreateTempBuffer()
          PushBlock()
          InsertFile(abbrev_file)
          PopBlock()
     else
          GotoBufferID(abbrev_buffer)
          BegFile()
     endif

     GotoBufferID(exp_cid)

     if CurrCol()  == 1
          if ask("Abbreviation?", abbrev) and Length(abbrev)
             and ask(abbrev + " is an abbreviation for: [spaces ok]" + currfilename(), possible)
             and Length(possible)
             GotoBufferID(abbrev_buffer)
             BegFile()
             AddLine(abbrev + ' ' + possible)
             SaveAs(abbrev_file, _OVERWRITE_)
             GotoBufferID(exp_cid)
          endif
             return(FALSE)                   // FALSE means don't do Expand()
     endif


                                        // get to last letter of abbreviation
     while CurrChar() == 32 or CurrChar() < 0
          PrevChar()
     endwhile
     return(TRUE)
end

/*************************************************
     Get_Abbrev_Char
          Gets a character and prepends it to
          the abbreviation variables.
 *************************************************/
proc get_abbrev_char()
     string s[1]= GetText(CurrPos(), 1)
     abbrev = s + abbrev
     abbrev_case =
          iif( s >= 'A' AND s <= 'Z',
               '1',                                // 1 = uppercase
               '0'                                 // 0 = not
             )
          + abbrev_case
     re_abbrev  =
          iif(Pos(s, '.^$\|?[]*+@#{}' ), '\', '')
          + s
          + re_abbrev
end

/*************************************************
     Set_Possibles_Case()
          sets up lo_possible as the lower case
          version and possible as the 'appropriate
          case' version.
 *************************************************/
proc set_possibles_case()
     integer nn = 1
     if case_flag == 0
          lo_possible = possible
          return()
     endif

     Lower(possible)
     lo_possible = possible             // keep this, and recase possible
     if Pos('1', abbrev_case)           // at least some upper case
          if not Pos('0', abbrev_case)  //        all upper case
               Upper(possible)
          else                          //        mixed case
               possible = ''
               while nn <= Length(abbrev)
                    possible = possible
                               + iif(abbrev_case[nn]  == '1',
                                     UpCase(lo_possible[nn]),
                                     lo_possible[nn]
                                    )
                    nn = nn + 1
               endwhile
               possible = possible
                          + SubStr(lo_possible,
                                   nn,
                                   Length(lo_possible)
                                  )
          endif
     endif
end

/*************************************************
     Expand()
          Main routine.
 *************************************************/
proc expand()
     UnMarkBlock()
     MarkStream()
     rest_of_line = GetText(CurrPos()+1, SizeOf(rest_of_line))

     while CurrChar() <> 32
       AND CurrChar() <>  9
       AND CurrPos()  <> 1
          get_abbrev_char()
          PrevChar()
     endwhile

     if CurrPos() == 1 AND         // if at BOL and on a character
        CurrChar() <> 32 AND       // add the character to the strings
        CurrChar() <> 9  AND
        CurrChar()  > 0
          get_abbrev_char()
          MarkStream()
     else
          NextChar()
          MarkStream()
     endif

     if abbrev[Length(abbrev)] == '-'
          case_flag = 0
          abbrev    = SubStr(   abbrev, 1, Length(   abbrev) -1)
          re_abbrev = SubStr(re_abbrev, 1, Length(re_abbrev) -1)
     endif

     set_position(ABBREV_BEGIN)

     DelBlock()               // delete abbreviation

     /*******************************
          EXTERNAL FILE SEARCH
      *******************************/

     GotoBufferID(abbrev_buffer)
     exp_msg = 'external abbrev search'
     message(exp_msg)

     while lfind(re_abbrev+'\c', '^xi')
          prevchar()
          repeat
               NextChar()     //
          until CurrChar() == 32 or CurrChar() < 0
          repeat
               NextChar()
          until CurrChar() <> 32 or CurrChar() < 0

          possible = GetText(CurrPos(), SizeOf(Possible))
          set_possibles_case()
          case query_user()
               when <escape>                      // aborts
                    InsertText(abbrev, _INSERT_)  // reinsertabbreviation
                    return()
               when <N>,<n>, <startup_key>        // rejects; keeps searching
                    reject()
               otherwise                          // bingo! do it
                    PushKey(exp_key)             // add keystroke back to keyboard
                    InsertText(possible, _INSERT_)// insert word
                    return()
          endcase
          GotoBufferID(abbrev_buffer)
     endwhile

    /*******************************
           INTERNAL SEARCH
     *******************************/
     exp_options='bix'
     goto_position(ABBREV_BEGIN)

     exp_msg = 'backward abbrev search'

    begin_internal:
     message(exp_msg)
     while lfind('{^}|{ }\c'+re_abbrev, exp_options)
                                             // search for matches at BOL
                                             // or preceded by a space
          set_position(LAST_FIND)            // lfind location
          possible = ''                      // reset and get possible
          repeat
               possible = possible + Chr(CurrChar())
               NextChar()
          until CurrChar() == 32 or CurrChar() == 9 or CurrChar() < 0
          while Pos(possible[Length(possible)], '.?"!([]),=')
               and Length(possible)
               possible = SubStr(possible, 1, Length(possible) -1)
          endwhile

          set_possibles_case()

          if possible == abbrev
               begword() prevchar()
               goto skipquery
          endif

          if reject_buffer                   // check if this match was previously
               GotoBufferID(reject_buffer)   // offered
               if lfind(lo_possible, '^g')   // if yes, skip by going
                    GotoBufferID(exp_cid)   // to bottom of while
                    goto skipquery
               endif
               GotoBufferID(exp_cid)
          endif
          case query_user()
               when <escape>                      // aborts
                    InsertText(abbrev, _INSERT_)  // reinsertabbreviation
                    return()
               when <N>,<n>,  <startup_key>       // rejects; keeps searching
                    reject()
               otherwise                          // bingo! do it
                    if abbrev_buffer              // if file didn't exist, buffer not
                         and Length(abbrev) <= 3
                         GotoBufferID(abbrev_buffer)        // created
                         if not lfind(re_abbrev, '^gxi')
                              EndFile()
                              AddLine(abbrev + ' ' + lo_possible)
                              SaveAs(abbrev_file, _OVERWRITE_)
                         endif
                    endif
                    GotoBufferID(exp_cid)
                    InsertText(possible, _INSERT_) // insert word
                    PushKey(exp_key)              // add keystroke back to
                    return()                       //   keyboard buffer
          endcase
        skipquery:
          goto_position(LAST_FIND)
     endwhile

     goto_position(ABBREV_BEGIN)

     if Pos('b', exp_options)                    // if could not find backwards
          exp_options = '+xi'                    // try forwards
          exp_msg = ' forward abbrev search'
          goto begin_internal
     endif

     Sound(3000) DeLay(1) NoSound() Delay(2) // should only get here when no [more]
     Sound(1500) DeLay(1) NoSound()          // finds occur
     InsertText(abbrev, _INSERT_)            // reinsertabbreviation
     return()
end

/*************************************************
     Done()
          Cleanup
 *************************************************/
proc done()
     Set(RemoveTrailingWhite, RTW)
     Set(KillMax,KM)
     if reject_buffer                        // delete the list of rejects set   up
          abandonfile(reject_buffer)
          reject_buffer = 0
     endif
     PopBlock()
     UpDateDisplay(_CLINE_REFRESH_ | _STATUS_LINE_REFRESH_ )
     return()
end

/*************************************************
     Query_user()
          Paints screen and returns input.
 *************************************************/
integer proc query_user()

     goto_position(ABBREV_BEGIN)

     if right( Length(possible) )
        left(  Length(possible) )
     endif
     message(exp_msg)
     updatedisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_)
     updatedisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_)

     XMarksTheSpot = WhereX()
     YMarksTheSpotToo = WhereY()
     PutStr(possible + rest_of_line)    // paint the possible word
     Set(Attr,Query(BlockAttr))         // set attribute for output

     GotoXY(XMarksTheSpot,YMarksTheSpotToo)
     PutStr(possible)                   // paint the possible word

     Set(Attr,Query(TextAttr))          // return to normal attr
     GotoXY(WhereX() + Length(possible) , WhereY() )
                                        // moves cursor to end of word
     exp_key = GetKey()                // wait for keystroke

     goto_position(ABBREV_BEGIN)
     PutStr(Format(' ' : Length(possible) )) // erase the word
     return(exp_key)
end

/*************************************************
     Reject()
          Adds reject words to reject list
 *************************************************/
proc                          reject()
     PushPosition()
     if not reject_buffer
          reject_buffer = CreateTempBuffer()
     else
     GotoBufferID(reject_buffer)
     endif
     AddLine(lo_possible)                    // add rejected word to list
     Possible = ''
     PopPosition()
end

proc main()
     if Get_Ready()
          expand()
     endif
     done()
end

<startup_key> main()          // change startup_key in CONSTANTS not here

/*

Permission is granted to all persons for non-commercial distribution of
this file and the macros and ideas contained herein provided (a) credit
is given to the author and (b) all changes not made by the author are
attributed. Permission is granted to SemWare for commercial distribution
provided (a) and (b) above. Otherwise, all rights are reserved by the
author, whether his or not.

*/
