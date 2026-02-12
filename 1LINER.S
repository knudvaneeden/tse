/*******************************************************************************

				     1LINER

 This  goes through a file converting each paragraph into a single line with an
 EOL (whatever is set in TSE) at the end.  It will  also  make	sure  that  all
 periods, question marks and exclamation points that are followed by spaces are
 followed by at least TWO spaces.

 Written: 01/20/94
 By:	  Jack Hazlehurst
 Modified 08/22/94 by Jack Hazlehurst
 Modified 10/17/94 by Jack Hazlehurst

===

 [kn, ri, th, 12-02-2026 00:11:54]

  Modified by Knud van Eeden

  -works in TSE for Microsoft Windows version 4.50 RC24

  -works in TSE for Linux version 4.50.14 in Linux WSL (Ubuntu)

  -works in TSE for Linux version 4.50.19 in Linux non-WSL (Ubuntu)

  -version 1.0.0.0

*******************************************************************************

[File: Source: FILE_ID.DIZ]

---

1LINER is a TSE v2.00 macro that converts
paragraphs into long single lines for input
to word processors.  Do your writing with
TSE, then run 1LINER on them and transfer
them to your word processor for formatting
and printing.

*******************************************************************************

[File: Source: 1LINER.HLP]

1Liner      Converts multi-line paragraphs to single line paragraphs.

            Overview:

            This macro prepares ASCII text files for importing into word
            processors such as Word or Word Perfect by converting multi-line
            paragraphs into single line paragraphs.

            If a block is marked in the current file, only the paragraphs
            within the block are processed;  otherwise the entire current
            file is processed.  _COLUMN_ blocks may NOT be used.

            The length of the resulting line is limited to the 32000-character
            limit imposed by TSE.

            Keys:         (none)

            Usage notes:

            Just run from the Potpourri menu.

*******************************************************************************

[File: Source: 1LINER.DOC]

---

1LINER

I wrote 1LINER to cover one of those nuisance jobs I run into. You know
the one I mean -- you do a writeup with TSE, then decide you need to
move it to a word processor. In my case, I wrote a short article for
the Chicago Computer Society rag, and they like to import these things
into Word Perfect. Mumble, mumble mumble.

A number of word processors like each paragraph to be a single line,
with some kind of thing at the end. TSE already provides a choice of
things at the end of the line. The problem is to go through and make
each paragraph a single line.

No, this is not a general-purpose macro. It assumes, for example, that
none of your paragraphs are more than "MaxLineLen" characters long,
TSE's current line length limit (3032 in v 2.00). A paragraph that big
will fill your entire screen (well, at 25 X 80 it will), and that is a
pretty big paragraph. For writeups like this, and short articles, you
should not be writing paragraphs that long.

1LINER has features that automate some of the execrable little garbage
that I had to do during a manual pass at converting. Normally I like to
put two spaces between sentences. If a line ends with a sentence end,
WrapPara() would not take care of this for me. So I automated that
process. There are other places where you have an end-of-sentence that
needs two spaces, but I have not figured out a simple way to determine
these places, so I fall back on the old WordStar method: ask the user.
If you look at the source code, you will see that I have used this as
an excuse to try out the new "c" parameter for Find, and I have also
used it to practice using regular expressions. Did you ever notice how
a regular expression resembles swearing as politely written down?

Anyway, I have set this up to be added to POTPOURRI. "Main" just calls
the routine itself. If you use it a lot and want it in your User
Interface, just remove the "main" proc and copy the rest of it into
your UI file.

For those of you who WILL add 1LINER to your POTPOURRI menu, just copy
the 1LINER.MAC file into your macro subdirectory. It was compiled for
TSE 2.00. I have also included a ".HLP" file, which is actually a block
of text which you should insert as is into your POTPOURR.DAT file. If
you do this, you would not have to add it to POTPOURRI in the usual
way; it will be ready to run. TSE is the perfect choice for this little
task. |-)

1LINER processes either your entire file or a marked block. If the
cursor is in a marked block when you call it, it will process just that
block; otherwise it scrambles the entire file. (Want to have some
"fun"? Run it on a file of source code, by accident. Be sure you save
the file before you have the accident.) If only part of a paragraph is
marked, processing begins at the beginning of the line when the marking
starts, and ends at the end of the paragraph, even if it extends beyond
the marked area.

1LINER does not like column blocks, and will not process them. It will
tell you this when it encounters this problem.

1LINER uses some of the more interesting effects of regular expressions
in TSE's Find/Replace command to make the spacing adjustments. You can
change them as you wish to suit your own tastes.

1LINER is not bulletproof or sophisticated. I just needed something
simple, that covers my needs, and is reasonably fast on my Old Beater
XT clone. It is not quite as fast as I would like, but it is okay. To
keep it from looking like it has frozen my machine, I put in a little
counter and a display to assure me that it is still working and has not
gone away to somewhere.

The counter does NOT count paragraphs, unless you want to consider the
lines between paragraphs and title lines "paragraphs".

*******************************************************************************/
//
PROC PROCOneLiner()
 //
 INTEGER ib = 0
 INTEGER rm = 0
 INTEGER ct = 0
 INTEGER xt = 0
 //
 IF ( IsCursorInBlock() == _COLUMN_ )
  Warn( "The Machine does NOT process column blocks." )
 ELSE
  PushPosition()                  // Save our current location.
  xt = Set( ExpandTabs, OFF )     // We do not want this messing.
  rm = Set( RightMargin, MAXLINELEN ) // A paragraph had better not
  ct = 0                            // be longer than this!
  IF IsCursorInBlock()            // Block processing?
   GotoBlockBegin()            // Yes.
   ib = TRUE
  ELSE
   BegFile()                   // No.
   ib = FALSE
  ENDIF
  //
  REPEAT
   ct = ct + 1                 // Show we are busy.
   Message( "Working... ", ct )
   BegLine()                   // Be sure we are at start of line.
   PushPosition()              // Wrap the paragraph TO a single line,
   WrapPara()                  // then go back to start of line.
   PopPosition()
   LReplace( "\t", " ", "cn" ) // Remove tabs and extra spaces from
   BegLine()                   // the line, then do the extra space
   LReplace( "{[~ ]}  #", "\1 ", "cxn" ) // padding as needed.
   LReplace( '{[.?!]["' + "')\]}]@ }{[~ ]}", "\1 \2", "cxn" )
  UNTIL NOT Down()                // Process to end of file or until
  OR ( ib AND NOT IsCursorInBlock() ) // outside of block.
  //
  PopPosition()                   // Return to starting position.
  Set( RightMargin, rm )          // Restore right margin setting.
  Set( ExpandTabs, xt )           // Restore tab expansion setting.
  Message( "Done." )
 ENDIF
 //
END
//
// The required "main"
//
PROC Main()
 PROCOneLiner()
END
