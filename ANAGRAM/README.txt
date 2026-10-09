===

1. -To install

     1. -Take the file anagram_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstallanagram.bat

     4. -That will create a new file anagram_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          anagram.mac

2. -The .ini file is the local file 'anagram.ini'
    (thus not using tse.ini)

===

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
