/* ********************************************************
   BibleRes.s  Bible Research using the Semware Editor
 ******************************************************* */

// Declarations

#define space 32
#define horizontal_tab 9

integer first_findws_id = 0
integer first_findws_line = 0
integer first_findws_column = 0
integer SrchHit = 0

string Target[80] = ""
// string Source[80] = "C:\Bible\Kjv.txt"
string Source[80] = ".\Kjv.txt"
string SrchLine[10] = ""
string SrchCol[10] = ""
string SrchNum[10] = ""
string SrchOpt[10] = "LIX+"
string FirstBook[3] = ""
string LastBook[3] = ""
string FirstRef[32] = ""
string LastRef[32] = ""
string LookUp[32] = ""
string Bracketed[80] = ""

helpdef BookNamesHlp
  title = " 3-Character Abbreviations for Bible Book names "
  x = 6
  y = 3
  "             Use the 3-character abbreviations shown              "
  "             here when prompted to enter a book name              "
  "                                                                  "
  "  GEN  Genesis           ISA  Isaiah         ROM  Romans          "
  "  EXO  Exodus            JER  Jeremiah       1CO  1 Corinthians   "
  "  LEV  Leviticus         LAM  Lamentations   2CO  2 Corinthians   "
  "  NUM  Numbers           EZE  Ezekiel        GAL  Galatians       "
  "  DEU  Deuteronomy       DAN  Daniel         EPH  Ephesians       "
  "  JOS  Joshua            HOS  Hosea          PHI  Philippians     "
  "  JDG  Judges            JOE  Joel           COL  Colossians      "
  "  RUT  Ruth              AMO  Amos           1TH  1 Thessalonians "
  "  1SA  1 Samuel          OBA  Obadiah        2TH  2 Thessalonians "
  "  2SA  2 Samuel          JON  Jonah          1TI  1 Timothy       "
  "  1KI  1 Kings           MIC  Micah          2TI  2 Timothy       "
  "  2KI  2 Kings           NAH  Nahum          TIT  Titus           "
  "  1CH  1 Chronicles      HAB  Habakkuk       PHM  Philemon        "
  "  2CH  2 Chronicles      ZEP  Zephaniah      HEB  Hebrews         "
  "  EZR  Ezra              HAG  Haggai         JAM  James           "
  "  NEH  Nehemiah          ZEC  Zechariah      1PE  1 Peter         "
  "  EST  Esther            MAL  Malachi        2PE  2 Peter         "
  "  JOB  Job               MAT  Matthew        1JO  1 John          "
  "  PSA  Psalms            MAR  Mark           2JO  2 John          "
  "  PRO  Proverbs          LUK  Luke           3JO  3 John          "
  "  ECC  Ecclesiastes      JOH  John           JUD  Jude            "
  "  SON  Song of Solomon   ACT  Acts           REV  Revelation      "
  "                                                                  "
end

helpdef BibleResHlp
  title = "Bible Research via the Semware Editor"
  x = 8
  y = 4
"                                                                      "
"             All operations are available from the Main Menu          "
"                   or you may use these shortcut keys:                "
"                                                                      "
"             These keys are active                                    "
"                while this program is running:                        "
"                                                                      "
"                                                                      "
"               <Alt 1>  Search For Words, Phrases                     "
"               <Alt 2>  View a Specified Bible Verse                  "
"               <Alt 3>  Extract Bible Verses to a File                "
"               <Alt 4>  Display Bible Book Name Abbreviations         "
"                                                                      "
"             These keys are active                                    "
"                when viewing the 'Hits.txt' file:                     "
"                                                                      "
"               <Alt 5>  Move To Any Target                            "
"               <Alt 6>  Go to the Original Text File                  "
"               <Alt 7>  Return to the 'Hits.txt File                  "
"               <Alt 8>  Go to the next Hit                            "

"               <Alt 9>  Menu of Bullet Operations                     "
"               <Alt 0>  Re-Start the macro                            "
"                                                                      "
"               <Alt M>  Display the BibleRes Menu                     "
"               <Alt H>  Help for BibleRes macro                       "
"               <Alt Q>  Quit the BibleRes macro                       "
"                                                                      "
"                                                                      "
"                                + + +                                 "
"                                                                      "
"                           Author: Ed Marsh                           "
"                                                                      "
"                         This is Version 2.1                         "
"                                                                      "
"                        Last updated: 2011-1220                       "
"                                                                      "
"                                + + +                                 "
"                                                                      "
"                             Introduction                             "
"                                                                      "
" This macro performs three primary functions to enhance your study of "
" the Holy Scriptures:                                                 "
"                                                                      "
" First, it will search through the ascii text of the King James Bible "
" using a powerful search engine that has no restrictions as to        "
" so-called insignificant words.  It will search for single words, or  "
" multiple word phrases (that do not have to be on the same line in    "
" the text).  Also, regular expression searches are available.  Each   "
" verse in which the target word or phrase was found is then copied to "
" a file named 'Hits.txt' which can be saved, edited, or discarded     "
" without ever being written to your drive.  While viewing this report "
" file, provision is available to jump to the same verse in the Bible  "
" file, where you can scroll as much as you wish in order to examine   "
" the context.  When you are ready, another key takes you back to the  "
" Hits.txt file, with the cursor positioned past the target you just   "
" viewed.  One more key will place the cursor at the beginning of the  "
" next hit.                                                            "
"                                                                      "
" The Hits.txt file provides additional information, that may be of    "
" real value to the serious Bible student.  All occurrences of the     "
" target are marked with an ascii 035 # bullet at the beginning of     "
" the word or phrase; the total number of finds is reported at the top "
" of the file, and each verse containing one or more finds is          "
" numbered; and the exact line and column number in the Bible text     "
" file is indicated (for the first hit within any one verse).  If the  "
" file is saved to another name for future reference, it will provide  "
" an accurate record of all the work you did, and the results          "
" obtained.                                                            "
"                                                                      "
" Second, for those times when you simply want to 'turn to' a specific "
" verse to find out what it says, or perhaps to refresh your memory,   "
" there is an option that quickly performs that task.  Simply enter    "
" the reference and you will be instantly looking at the verse, in     "
" context.                                                             "
"                                                                      "
" Third, it is often beneficial, or perhaps necessary, to gather       "
" together in one place, a number of Scripture passages.  Just select  "
" the extract verses option on the menu.  You will be prompted for the "
" starting verse and then the ending verse.  Because the ending verse  "
" frequently will be not far from the starting reference, the prompt   "
" for the final verse will display the starting verse as the default.  "
" Should you wish to copy only the one verse, just press <Enter> and   "
" the deed is done.  The verses will be copied to a file named         "
" verses.txt, which also can be edited, saved, discarded--whatever you "
" decide.                                                              "
"                                                                      "
" A stand-alone macro called 'Bullets' (which has been a constant help "
" to the author for several years) has been included in this package,  "
" and made available from the Main Menu by pressing <Alt 9>.  There is "
" extensive information given in the header of that macro, so it won't "
" be repeated here.  Use of these bullets in conjunction with the      "
" editor's CompressView function (or 'Find' with the 'V' option) is a  "
" great way to move around in any file that uses these bullets.        "
"                                                                      "
" A word about fonts: The original version was developed and shipped   "
" using the Letter Gothic Line font, and used upper-ascii characters   "
" extensively for bullets.  While the bullets are necessary for the    "
" macro to operate, this version was written in Courier New and uses   "
" only lower-ascii bullets (*~#).  You may change these if you wish,   "
" by using the Editor's Replace function, as long as you run the       "
" Replace on ALL THREE of these files: BibleRes.s and KJV.txt and      "
" Bullets.s!                                                           "
"                                                                      "
" See the 'Install.txt' file for further information.                  "
"                                                                      "
"                          Acknowledgments:                            "
"                                                                      "
" This version is dedicated to the memory of Skip Gore, long-time user "
" of the Editor, and a valuable helper to the author.  Skip, who was   "
" totally blind, was working on a separate version for vision-impared  "
" users when he died.                                                  "
"                                                                      "
" Carlo Hogeveen, for developing the excellent search engine FindWs,   "
" which provides the search capabilities for this macro.               "
"                                                                      "
" Sammy Mitchell, for providing us all with The World's Greatest Text  "
" Editor: The Semware Editor, or TSE, but affectionately known as      "
" 'Tessie' by all who love her!                                        "
"                                                                      "
" For questions, comments, suggestions, or help with this version:     "
"                                                                      "
"                         libby1018@comcast.com                        "
"                                                                      "
"                                + + +                                 "
"                                                                      "
"                             Suggestion:                              "
" You might find it helpful to print a cheat-sheet of the Book Name    "
" Abbreviations to use until you become familiar with them.            "
"                                                                      "
"                      Press <Escape> to continue                      "
end

/* ********************************************************
   Borrowed from tse.ui as a helper in other procs
 ******************************************************* */
integer proc FindNextBlankLine()
    repeat
       if not Down()
           return (FALSE)
       endif
    until PosFirstNonWhite() == 0
    return (TRUE)
end

/* ********************************************************
   One Blank - cleans up the Hits List file
 ******************************************************* */

proc OneBlank()
   BegFile()
   PushKey(<o>)
   ExecMacro("DelBlank")
end

Forward Menu BibleResMenu()

/* ********************************************************
   Back To Bible - provides quick and easy way to re-focus
   the Editor on the Bible text file, ready to begin again
 ******************************************************* */

proc BackToBible()
   EditFile(Source)
   BegFile()
   Message("Press <Alt M> for menu")
end

proc Start()
   Source = "C:\Bible\Kjv.txt"
   BackToBible()
end

proc MoveToAnyTarget()
   Find("Verse Number 1 ", "v")
end

/* ********************************************************
   Jump To Text - to be called from the Hits List file
   places cursor on the found word in the Bible text file
 ******************************************************* */

proc JumpToText()                      // Alt 6
   lFind("-=<>=-", "b")
   lFind("#", "")
   PlaceMark("j")
   lFind("On Line:\c", "bx")
   WordRight()
   SrchLine = GetWord()
   EndLine()
   WordLeft()
   SrchCol = GetWord()

   EditFile(Source)
   GotoLine(Val(SrchLine))
   GotoColumn(Val(SrchCol))
   ScrollToCenter()
end

/* ********************************************************
   Ret To Hits - to be called from the Bible text file
   after Jump To Text has been used.
   Places cursor after the found word in the Hits List
   file that was used to activate Jump To Text.
 ******************************************************* */

proc RetToHits()                       // Alt 7
   BegFile()
   GotoMark("j")
   repeat
      Right()
   until isWhite() | CurrChar() == _AT_EOL_
   ScrollToCenter()
end

/* ********************************************************
   Next Hit - to be called from the Hits List file
   places the cursor at beginning of next occurrence
   of target
 ******************************************************* */

proc NextHit()                         // Alt 8
   if not lFind("#", "+")
      Message("No more hits!")
      Return()
   endif
end

proc QuitBibleRes()
   PurgeMacro("BibleRes")
   Exit()
end

/* ********************************************************
   Go To Verse - asks for a reference to view in the Bible
   text file - requires 3-char abbreviation - pops up list
   on failure
 ******************************************************* */

proc GotoVerse()
   EditFile(Source)
   if Ask("GotoVerse: ", Lookup, GetFreeHistory("BibleRes:LookUp"))
      and Length(Lookup)
   else
      Warn("Please specify a verse to go to!")
      GotoVerse()
      Return()
   endif

   Editfile(Source)
   BegFile()
   if not lFind(Lookup, "^i")
      Warn(Lookup + " not found!  Please check your entry.")
      QuickHelp("BookNamesHlp")
      GotoVerse()
      Return()
   endif
   ScrollToCenter()
end

/* ********************************************************
   Set Range - asks for first book of range to be searched
   then asks for last book of range to be searched
   NOTE: first book defaults to ""
          last book defaults to whatever entered for first
          book since many times we want to search just one
          book - this can be changed - was originally REV
 ******************************************************* */

proc SetRange()
   UnmarkBlock()
   EditFile(Source)
   FirstBook = "GEN"
   if Ask("First Book: ", FirstBook) and Length(FirstBook)
   endif

   LastBook = "REV"
   if Ask("Last Book: ", LastBook) and Length(LastBook)
   endif

   EditFile(Source)
   BegFile()
   if not lFind("* " + FirstBook, "i")
      Warn(FirstBook + " not recognized!  Check spelling.")
      QuickHelp("BookNamesHlp")
      SetRange()
      Return()
   else
      BegLine()
      MarkChar()
      Up()
   endif

   if not lFind("* " + LastBook, "i")
      Warn(LastBook + " not recognized!  Check spelling.")
      QuickHelp("BookNamesHlp")
      SetRange()
      Return()
   else
      NextChar()
      lFind("*", "^")  // d\042 bullet at beginning of next book
      MarkChar()
   endif
   GotoBlockBegin()
end

/* ********************************************************
   Extract Verses - asks for first verse to be copied
   then asks for last verse to be copied
   NOTE: last verse defaults to whatever entered for
         first verse since we often want just a few
         consecutive verses (just backspace and enter
         the new last verse)
 ******************************************************* */

proc ExtractVerses()
   EditFile(Source)
   BegFile()
   if Ask("First Reference: ", FirstRef) and Length(FirstRef)
   else
      Warn("Please enter the starting reference")
      QuickHelp("BookNamesHlp")
      ExtractVerses()
   endif
   LastRef = FirstRef

   EditFile(Source)
   if Ask("Last Reference: ", LastRef) and Length(LastRef)
   else
      Warn("Please enter the ending reference")
      QuickHelp("BookNamesHlp")
      ExtractVerses()
   endif

   EditFile(Source)
   if not lFind(FirstRef, "^ig")
      Warn(FirstRef + " not found!  Please check your entry.")
      QuickHelp("BookNamesHlp")
      ExtractVerses()
      Return()
   else
      MarkLine()
   endif

   if not lFind(LastRef, "i")
      Warn(LastRef + " not found!  Please check your entry.")
      QuickHelp("BookNamesHlp")
      ExtractVerses()
      Return()
   endif

   if not FindNextBlankLine()
      Warn("Can't find the end of the last verse!")
      Return()
   else
      Up()
      MarkLine()
      Copy()
      BegFile()

      EditFile("Verses.txt")
      EndFile()
      cReturn()
      InsertText("-=<>=-")
      cReturn()
      cReturn()
      Paste()
   endif
end

/* ********************************************************
   Find It - the search engine for finding words and
   phrases much of the code borrowed from "FindWS" by
   Carlo Hogeveen (Thanks, Carlo!) - it will locate
   multiple word phrases spread across lines
 ******************************************************* */

integer proc Findit(string Target, string SrchOpt)
   string word[255] = ""
   integer found = false
   integer found_line = 0
   integer found_column = 0
   integer word_line = 0
   integer word_column = 0
   integer token_counter = 0
   integer first_found_id = 0
   integer first_found_line = 0
   integer first_found_column = 0

   pushposition()
   Message("Searching . . .")
   repeat
      token_counter = 0
      repeat
           token_counter = token_counter + 1
           word = gettoken(Target, " ", token_counter)
           if word <> ""
              if token_counter == 1
                 if lfind(word, SrchOpt)
                    SrchLine = str(CurrLine())
                    SrchCol  = str(CurrCol())

                    found = true
                    found_line = currline()
                    found_column = currcol()
                    if first_found_id == 0
                       first_found_id     = getbufferid()
                       first_found_line   = currline()
                       first_found_column = currcol()
                    else
                       if  first_found_id     == getbufferid()
                       and first_found_line   == found_line
                       and first_found_column == found_column
                          found = false
                          word = ""
                       endif
                    endif
                 else
                    found = false
                    word  = ""
                 endif
              else
                 // Cursor is on previous found word: goto next whitespace.
                 while chr(currchar()) in "A" .. "Z", "a" .. "z", "0" .. "9"
                    nextchar()
                 endwhile
                 // Cursor is on first whitespace: goto next non-whitespace.
                 while not(chr(currchar()) in "A" .. "Z", "a" .. "z", "0" .. "9")
                 or    currchar() == _at_eol_
                    nextchar()
                 endwhile
                 // Check if the word under the cursor is the next search word.
                 word_line = currline()
                 word_column = currcol()
                 if  lfind(word, "cix")
                 and currline() == word_line
                 and currcol() == word_column
                    // Yes, the next search word was and is under the cursor.
                 else
                    found = false
                 endif
              endif
           endif
      until found == false
      or    word  == ""
   until word == ""

   if not found
   or (getbufferid() == first_findws_id
      and found_line    == first_findws_line
      and found_column  == first_findws_column)

      popposition()
      Message("Finished searching for '" + Target + "'")
      Return(FALSE)
   else
      killposition()
      gotoline(found_line)
      gotocolumn(found_column)
      if first_findws_id == 0
           first_findws_id     = getbufferid()
           first_findws_line   = found_line
           first_findws_column = found_column
      endif
   endif
   Return(TRUE)
end


/* ********************************************************
   Copy It - grabs one complete paragraph at a time
   pastes it to the Hits List file with detailed research
   info then adds a  -=<>=-  section separator
 ******************************************************* */

proc Copyit()
   PushBlock()
   BegLine()                 // find the beginning of the para
   repeat
      Up()
   until CurrChar() < 0 or CurrLine() == 1

   while isWhite() or CurrChar() == _AT_EOL_
      NextChar()
   endwhile
   MarkChar()
   repeat                    // find the end of the para
      Down()
   until CurrChar() < 0 or CurrLine() >= NumLines()
   MarkChar()

   Copy()                    // copy the para
   UnmarkBlock()
   EditFile("Hits.txt")
   EndFile()
   cReturn()
   cReturn()
   InsertText("-=<>=-")
   cReturn()
   cReturn()

   InsertText("Verse Number " + SrchNum + " Containing the target")
   cReturn()
   InsertText("one or more times in the File:")
   cReturn()
   InsertText(Source)
   cReturn()
   InsertText("On Line: " + SrchLine + " At Column " + SrchCol)
   cReturn()
   cReturn()
   Paste()                   // paste the para

   EditFile(Source)
   PopBlock()
end

FORWARD proc Identify()

/* ********************************************************
   Bible Res - this is the heart of the program - it asks
   for info then sets up and calls the search engine.

   NOTE: for the most part, the default search options
      should be left alone - sometimes it is OK to add
      'w' to limit finds to whole words - otherwise the
      default is needed.

   This proc also provides the headers at the top of the
   Hits List file that display the target(s) searched
   for and the number of hits.

   NOTE: this remains true even if multiple searches are
      done using the same Hits List file.  Of course, the
      Hits List file can be copied pr renamed and saved at
      any time, and a new one will be started when another
      search is done.
 ******************************************************* */

proc BibleRes()
   integer ParaCount = 0
   integer Counter = 0
   string ParaNumber[6] = ""
   string Counted[10] = ""
   string ThisFile[64] = ""
   string fn[80] = ""
   SrchHit = 0

   fn = CurrFileName()
   ThisFile = SplitPath(fn, _NAME_ | _EXT_)
   if ThisFile == "Hits.txt"
      Warn("Hey! That won't work here!            You need to be in C:\Bible\KJV.txt")
      Return()
   endif

   SetRange()
   if Ask("Search for: ", Target, GetFreeHistory("Findit:TARGET"))
      and Length(Target)
   else
      Warn("Need a target to search for!")
      SetRange()
   endif

   Bracketed = ("<" + Target + ">")

   if Ask("Search Options: ", SrchOpt, GetFreeHistory("Findit:SrchOpt"))
      and Length(SrchOpt)
   else
      Message("Are you sure you want these options?")
   endif

   while Findit(Target, SrchOpt)
      SrchHit = SrchHit + 1
      SrchNum = str(SrchHit)
      Copyit()
      ParaCount = ParaCount + 1
      ParaNumber = Str(ParaCount)
   endwhile

   BegFile()
   EditFile("Hits.txt")
   BegFile()
   lFind("-=<>=-", "")
   cReturn()
   cReturn()
   Up()
   Up()
   Up()
   InsertLine()
   cReturn()
   InsertText("Found the target " + Bracketed)
   cReturn()
   InsertText("a total of")
   cReturn()
   InsertText("in the file " + Source)
   cReturn()
   InsertText("within the range: " + FirstBook + " - " + LastBook)
   cReturn()
   // cReturn()
   // InsertText("-=<>=-")
   cReturn()
   MarkLine()
   EndFile()
   MarkLine()
   GotoBlockBegin()
   while Findit(Target, SrchOpt)
      InsertText("#")
      Counter = Counter + 1
   endwhile

   BegFile()
   Counted = str(Counter)
   if lFind("a total of", "$")
      EndLine()
      InsertText(" " + Counted + " times in " + ParaNumber + " Verses")
   endif
   UnmarkBlock()
   BegFile()
   lReplace("##", "#", "n")
   BegFile()
   lReplace("<#", "<", "n")
   Identify()
   OneBlank()
end

/* ********************************************************
   Identify goes back (after the counting of hits is done)
   and replaces the words 'the target' with the actual
   target word or phrase, enclosed in <angle brackets>.
   There is also a menu option that will offer a picklist
   of the first found occurrence of all current searches.
 ******************************************************* */

proc Identify()
   EditFile("Hits.txt")
   EndFile()
   lFind("Verse Number 1 ", "b")
   while lFind("the target", "")
      MarkFoundText()
      DelBlock()
      InsertText(Bracketed)
   endwhile
end

/* ********************************************************
   Bible Res Menu - provides menu access to all functions
      of the Bible Research program.
 ******************************************************* */

Menu BibleResMenu()
   Title = "Bible Research Menu"
   x = 24
   y = 4
   history
   nokeys
   " &Search for Words       <Alt 1>", BibleRes()
   " &View Bible Verse       <Alt 2>", GotoVerse()
   " &Xtract Verses          <Alt 3>", ExtractVerses()
   " Book &Abbreviations     <Alt 4>", QuickHelp("BookNamesHlp")
   "                                ",                       , Divide
   " &First Hit Any Target   <Alt 5>", MoveToAnyTarget()
   " &Jump To KJV text       <Alt 6>", JumpToText()
   " &Return to Hits List    <Alt 7>", RetToHits()
   " &Go to Next Hit         <Alt 8>", NextHit()
   "                                ",                       , Divide
   " &Bullet Operations      <Alt 9>", ExecMacro("Bullets")
   " Re-Start &Program       <Alt 0>", BackToBible()
   " BibleRes &Help          <Alt H>", QuickHelp(BibleResHlp)
   " &Quit Bible Research    <Alt Q>", QuitBibleRes()
end

/* ********************************************************
   Key Assignments
 ******************************************************* */

<Alt 1> BibleRes()
<Alt 2> GotoVerse()
<Alt 3> ExtractVerses()
<Alt 4> QuickHelp("BookNamesHlp")
<Alt 5> MoveToAnyTarget()
<Alt 6> JumpToText()
<Alt 7> RetToHits()
<Alt 8> NextHit()
<Alt 9> ExecMacro("Bullets")
<Alt 0> BackToBible()

<Alt H> QuickHelp(BibleResHlp)
<Alt M> BibleResMenu()
<Alt Q> QuitBibleRes()

/* ********************************************************
   The required starting point
 ******************************************************* */

proc Main()
   Start()
end

