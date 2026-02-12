/* WORDS.S

   A word counter macro for TSE (The Semware Editor), pre-release
   version 1.0

   Author: David Mayerovitch
   reachable in ILink TSE Jr. conference
   or by E-mail: david.mayerovitch@canrem.com

   macro version 1.0 1 Nov 93
   ________________

   If the current file contains a marked block, WORDS counts the
   words in the block and displays the status line message
   "Words in block:" followed by the total.

   If the file contains no marked block, WORDS counts the words
   in the file and displays "Words in file:" followed by the
   total.

   A running total of the words counted appears on the status
   line, at increments of 50.  If you have a fast machine, you
   might want to increase the value of the variable Increment to
   keep this display readable.  On my good old XT, 50 provides a
   good balance of readability and excitement.

   Hitting any key during the count will stop the macro, and the
   exact word count up to the moment of interruption will be
   displayed.

   Your original cursor position is always restored after the
   count, whether completed or interrupted.

   Note: when a block is marked, a word which overlaps the start
   of the block will not be included in the count.  A word which
   overlaps the end of the block will be included.  (Don't ask.)

   WORDS will count as a word any string that matches the
   regular expression in the variable WordSpec.  The value
   supplied here is

    "[0-9A-Za-z',\.€-š -¥]#"

   which includes digits, the letters a-z and A-Z plus the
   diacritically-marked versions of them used in various
   languages, and the apostrophe, comma, and period.

   It does not include the hyphen "-" or the underscore "_".

   Thus the following strings will count as two words:

      555-1234   fast-moving   initial_value

   The following strings will count as one word:

      12,345   $19.95   she's   O'Casey
      se¤or    Qu‚bec   FILENAME.EXT

   WORDS saves the current value of the editor variable WordSet,
   uses a new value derived from WordSpec during the count, and
   then restores WordSet to its original value.

   If you want to use your own value for WordSpec, remember also
   to change the ChrSet() string-constant parameter near NOTE
   <A>, below.  Note that the parameter passed to ChrSet() uses
   a somewhat different syntax from the regular-expression
   string used in WordSpec.

   By the way, I find the WordSet characters defined in the
   WordSpec value provided here a good set to use in configuring
   TSE.  If you set the value

       WordSet = ChrSet("0-9A-Za-z',.€-š -¥")

   in your TSE.CFG file, the WordRight(), WordLeft(),
   DelRightWord() and DelLeftWord() commands will treat strings
   as one word or two just as illustrated above.

   Programmers who would like such strings as "initial_value" to
   be treated as one word can use

       WordSet = ChrSet("0-9A-Za-z',.€-š -¥_")

*/

proc main()

    integer count = 0
    integer increment = 50

    string WordSpec[25] = "[0-9A-Za-z',\.€-š -¥]#"
    string wordopt[4] = "XGW"
    string scope[5] = "file"
    string CurrWordSet[32]

    CurrWordSet = Set (WordSet, ChrSet("0-9A-Za-z',.€-š -¥"))
//  NOTE <A> ChrSet must take a string-constant parameter.

    if isBlockInCurrFile()
      scope = "block"
      wordopt = wordopt + "L"
    endif
    PushPosition()
    if lFind(wordspec, wordopt)
        repeat
            if ( (count mod increment) == 0 )
              Message ("Counting <any key to stop> ... ", count)
            endif
            count = count + 1
            if KeyPressed()
              GetKey()
              Message("Stopped at ", count)
              PopPosition()
              Set(WordSet, CurrWordSet)
              return()
            endif
        until not lRepeatFind()
    endif
    PopPosition()
    Message("Words in ", scope, ": ", count)
    Set(WordSet, CurrWordSet)
end main
