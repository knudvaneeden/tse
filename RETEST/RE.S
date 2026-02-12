/**************************************************************************
     rePos() : Returns the start position of 'needle' within  'haystack,'
               using regular expression search and any additional specified
               searchs and replace options.

               Examples:
                    n = rePos(last_name, full_name, 'i')

                    if rePos('M[r]?s.', full_name, '^i')
                         sex = 'F'
                    endif
               where last_name and full_name are two strings in your proc.

               Returns 0 (FALSE) if not found.
 **************************************************************************/
integer proc rePos(STRING needle, STRING haystack, STRING options)
     integer bid = CreateTempBuffer(),
             location = 0
     AddLine(haystack)
     if lfind(needle, options + 'x')
          location = CurrPos()
     endif
     AbandonFile(bid)
     Return(location)
end

/********************************************************************
 reSubStr() : Returns the string matching regular expression 'needle'
              from within string 'haystack', using any additional
              search/replace options specified (if any).

              Example:
                    title =  rePos('[DM][r]?[s]?\.', full_name, '^')
              Returns
                    Dr.  Mr.  Mrs.  Ms.
                    Title is equal to any of these if they are at the
                    beginning of full_name.

               Returns '' (empty string) if not found.
**********************************************************************/
string  proc reSubStr(STRING needle, STRING haystack, STRING options)
     integer
          bid = CreateTempBuffer()
     string
          s[255] = ''
     PushBlock()
     UnMarkBlock()
     AddLine(haystack)
     if lfind(needle, options + 'x')
          MarkChar()
          BegLine()
          if lfind(needle + '\c', options + 'x')
               MarkChar()
               s = GetMarkedText()
          else
               s = ''
          endif
     endif
     AbandonFile(bid)
     PopBlock()
     Return(s)
end

/********************************************************************
rePlaceChars()

NOTE: 12 lines--80 bytes compiled--possibly the most useful and
      versatile single proc I've ever written.

Returns a string calculated by taking string 'haystack' and replacing
string 'needle' with string 'thread' using regular expression search
and any specified options. Returns haystack (unchanged) if no find
occurs. Example:

     full_name = rePlaceChars( first_name,    // find this
                               full_name,     // in this
                               initial,       // replace with this
                               'wi')          // using these opts

Use of ^ and $ in options allows this to be used to delete a string
[of spaces or text] from the start or end. To trim all spaces from
the end of a string, for instance:

     old_str = rePlaceChars( ' #',      // 1 or more spaces
                             old_str,
                             '',        // replaced with ;;
                             '^' )      // beginning

To trim them from the end of the string replace '^' with '$', above.
To trim them from both the beginning and the end:

     old_str = rePlaceChars( '{^ #}|{ #$}',  // see your manual
                             old_str,
                             '',
                             '2' )           // must allow 2 replaces

You can use rePlaceChars to insert a string into the middle of another
at aspecified position. For instance:

     old_str = rePlaceChars(
                              Format( '' : 5 :'.' ),  // 5 = insert pos
                              old_str,                // string input
                              '\0' + ins_str,
                              ''                      // no special opts
                            )

To place it 5 chars before the END of old_str, change '' to '$'.

Finally, you can use a number as part of option string to have that
nunber of occurrences of needle replaced by thread (if it occurs > 1
time).  Use 0 to mean 'replace all occurrences'.

     old_str = rePlaceChars(
                              ' ',               // space
                              old_str,           // string input
                              ''                 // no replace
                              '12'               // number of times
                            )
This deletes the first 12 spaces anywhere in the string.
 *********************************************************************/
string  proc rePlaceChars(STRING needle, STRING haystack,
                          STRING thread, STRING options)
     integer
          bid = CreateTempBuffer()
     string
          s[255] = ''
     AddLine(haystack)
     lreplace(needle, thread, options + 'xn1')
     s = GetText(1,CurrLineLen())
     AbandonFile(bid)
     Return(s)
end

/**********************************************************************
     R E Test Kit
 **********************************************************************/

STRING
     gneedle[60], ghaystack[60], greplace_with[60] = '*', goptions[10],
     found_pos[3], found_len[3], found_str[60], new_str[120]

INTEGER
     n_hist, o_hist, h_hist, r_hist

proc reTestMenuAction()
     case MenuOption()
          when 1 Ask('Search string:',  gneedle, n_hist)
          when 2 Ask('Search within:', ghaystack, h_hist)
          when 3 Ask('Search options [x assumed]:', goptions, o_hist)
          when 9 Ask('Replace with:', greplace_with, r_hist)
     endcase
     found_pos = str(rePos( gneedle, ghaystack,  goptions) )
     found_str = reSubStr(  gneedle, ghaystack,  goptions)
     found_len = str(length(found_str))
     new_str   = rePlaceChars( gneedle, ghaystack, greplace_with, goptions)
end

forward helpdef re_help

menu reTestMenu()
     History   x=1 y=1   command = reTestMenuAction()
     Title = 'Regular Expression Tester'
     '&Search String'  [gneedle   : 60]    , , closeafter
     '&Target'         [ghaystack : 60]    , , closeafter
     '&Options'        [goptions  : 60]    , , closeafter
     '',, divide
     'Found:'          [found_str : 60]    , , skip
     'At:'             [found_pos : 60]    , , skip
     'Length:'         [found_len : 60]    , , skip
     '',, divide
     '&Replace with'   [greplace_with : 60], , closeafter
     'Results in:  '   [new_str : 60]      , , skip
     '',, divide
     '&Help', QuickHelp(re_help), dontclose
end

proc main()
     set(BREAK,ON)
     if not n_hist
          n_hist = GetFreeHistory()
          o_hist = GetFreeHistory()
          h_hist = GetFreeHistory()
          r_hist = GetFreeHistory()
     endif
     repeat until not retestmenu()
end

Helpdef re_help
     title = ''
     width = 78
     height = 20
     x = 1 y = 5
' Symbol   Regular Expression Search Behavior'
' 컴컴컴   컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴'
'  .      Matches any single character [except end-of-line].'
'  ^      Beginning of line/block'
'  $      End of line/block'
'  \n     In a REPLACE pattern:  references a Tagged component pattern from the'
'         search pattern, where "n" is a single-digit number from 0 through 9.'
'  |      "Or" operator:  matches the preceding or the following pattern.'
'  ?      Optionally matches the preceding pattern.'
' [ ]     Class of characters against which to match a single character. [abc]'
'[ - ]    Indicates a range of characters within a class. [a-z] = lowercase letter'
' [~ ]    Complement of class. [~a-z] = not a lowercase letter'
''
'  *      0 or more occurrences of the preceding pattern; minimum closure.'
'  +      1 or more occurrences of the preceding pattern; minimum closure.'
'  @      0 or more occurrences of the preceding pattern; maximum closure.'
'  #      1 or more occurrences of the preceding pattern; maximum closure.'
''
' { }     Identifies a pattern group or component pattern. {proc}|{menu}'
'         See \1 ... \9, below.'
'  \      Escape operator. Makes the following character a literal character.'
'         unless used as follows:'
'         \c     Designates the placement of the cursor within Find string'
'         \0     In replace string, stands for entire found pattern'
'         \1 ... \9 In replace string, stands for a tagged pattern (see {}).'
''
'         \a     Alert (beep) character (^G or ASCII 7).'
'         \b     Backspace character (^H or ASCII 8).'
'         \f     Formfeed character (^L or ASCII 12).'
'         \n     Newline (line feed) character (^J or ASCII 10).'
'         \r     Return character (^M or ASCII 13).'
'         \t     Tab character (^I or ASCII 9).'
'         \v     Vvertical tab character (^K or ASCII 11).'
'         \xnn   Character equivalent to hex nn'
'         \dnnn  Character equivalent to dec nnn'
'         \onnn  Character equivalent to xctal nnn'
end
