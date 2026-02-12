//
// Copyright 1992-1993 SemWare Corporation.  All Rights Reserved Worldwide.
//
// 03-20-93: RB - Rewritten, commented, and tested.
//
// 05/21/93: JHH - Heavy-duty modifications to make it able to re-justify a
//		   previously justified paragraph, and to make	its  return
//		   behavior  similar  to  that	of  WrapPara() so it can be
//		   substituted for it.	It also	 can  be  controlled  by  a
//		   variable "Justify" if desired, which can turn it OFF and
//		   ON.
//
// Macro that does Full Justification of the current paragraph. It works
// like the WrapPara() command, in that it starts at the current line and
// goes to the end of the paragraph.  It tests for ParaEndStyle to know when
// to stop justifying.
//
// PARAMETERS:	none
//
// RETURNS:	TRUE/FALSE under the same rules as WrapPara() (TRUE unless
//			   last line is at EOF)
//
// GLOBAL VARS: none
//
// LOCAL VARS:	Described in code where defined.
//

/*******************************************************************************

				  WHA' HOPPENS

   First we have to locate the beginning of the paragraph in  imitation	 of
   WrapPara().

   Next, we remove the results of previous justification, which consists of
   removing excess blanks from the lines.   At	the  same  time,  tabs	are
   converted  to blanks and exactly two spaces are placed after each period
   that is followed by one or more spaces.

   The paragraph is then wrapped using WrapPara, and  the  return  code	 is
   saved to return to the caller.  The number of lines in the paragraph (as
   determined by WrapPara()  )	is  saved  for	the  possible  full-justify
   operation.

   The	variable  "Justify"  is	 checked  to see if a full justification is
   desired.  If not, the caller is returned to.

   Otherwise the paragraph is full-justified.

   Procedure to justify a paragraph:

   The method used to justify the paragraph is:

	Save our position.
	If the lm == 0 set it to the position of first non white char
	    on the next line.
	Repeat
	    Calculate the number of spaces needed to justify the line.
		Check to see if the line number is even or odd.
		If even start at the end of the line, else at beginning.
		Work through the line putting a space between words.
	Until
	    All lines of the paragraph have been processed.

*******************************************************************************/

public integer proc mJustifyPara()
    string  wrdset[32] = Query( WordSet )
    integer rm = Query(RightMargin),	// Position of right margin
	    linelen = 0,		// length of line being justified.
	    spaces = 0,			// Number of spaces to add to this line.
	    wwstate = Query( WordWrap ),// Sate of WordWrap at entry.
	    Dwn = TRUE,			// Results of last REAL WrapPara().
	    Again,			// Iteration control for removing blanks
	    sp,				// Starting point on first line.
	    i,				// Line # of last line of paragraph.
	    j				// Blank removal iteration count.
//
// First we locate the actual starting point
//
    sp = CurrPos()
    BegLine()
    while (CurrLineLen() == 0)		// Locate a non-blank line.
       or (PosFirstNonWhite() < 1)	// Just try to position us just at
	if NOT Down()			// the start of a paragraph.
	    return( FALSE )
	endif
	sp = 1				// If we were on first line of paragraph
    endwhile				// when we begin, go to original
    if sp < PosFirstNonWhite()		// position on line, or to first non-
	sp = PosFirstNonWhite()		// white if it's greater, before
    endif				// starting.
    GotoPos(sp)

//
// Next	 we  remove  possible  excess  spaces  from lines and make sure the
// paragraph is	 wrapped.   We	also  ensure  that  all	 embedded  periods,
// exclamation points and question marks are followed by two spaces.
//
    Set(WordSet, ChrSet(Chr(0) + '-' + Chr(8) + Chr(10) + '-' +
					       Chr(31) + '"--/->@-' + Chr(255)))
    j = 0
    Set( WordWrap, OFF )

    repeat
	PushPosition()
	GotoPos( PosFirstNonWhite() )	// Find number of last line in
	Dwn = WrapPara()		// paragraph and see that it's
	i = CurrLine()			// wrapped.
	if Dwn
	    i = i - 1
	endif
	PopPosition()			// Back to start of paragraph.

	PushPosition()
	if Pos( chr(CurrChar()), ".!?" )// In case paragraph begins with
	    WordRight()			// an end-of-sentence punctuation.
	endif
	EndWord()

	Again = FALSE
	repeat

	    if CurrPos() > PosLastNonWhite()	// If at end of line, first
		if CurrPos() <= CurrLineLen()	// reduce trailing garbage to
		    if CurrChar() == 9		// no more than one space.
			Again = TRUE
		    endif
		    InsertText( " ", _OVERWRITE_ )
		    if CurrPos() <= CurrLineLen()   // Don't load up the
			DelChar( CurrLineLen() - CurrPos() + 1 )
		    endif			    // history buffer!
		endif
		EndLine()
		if NOT WordRight()		// -- go to next line
		    break			// if possible.
		endif
	    else
		if CurrChar() == 9		// Replace tabs with spaces.
		    InsertText( " ", _OVERWRITE_ )
		    Again = TRUE		// Need another iteration.
		elseif NOT IsWhite()		// Periods, question marks and
		    Right()			// exclamation marks MUST be
		    if CurrChar() == 9		// followed by two or no spaces.
			InsertText( " ", _OVERWRITE_ )
			Left()
			Again = TRUE
		    endif
		    if	(CurrPos() < CurrLineLen())
		    and (CurrChar() == asc(" "))
			Right()
			if (CurrChar() <> asc(" "))
			    InsertText( " ", _INSERT_ )
			    Again = TRUE
			else			// It is important that we
			    Right()		// leave the cursor correctly
			endif			// positioned for the deletion
		    endif			// of excess spaces.
		elseif CurrPos() < CurrLineLen()
		    Right()			// Otherwise keep single space.
		endif
		while IsWhite()			// Now get rid of any further
		    DelChar()			// tabs and spaces.
		    Again = TRUE
		endwhile
		if (CurrPos() >= CurrLineLen()) // Ensure that we are at the
		or IsWhite()			// beginning of a word for the
		    WordRight()			// next iteration.
		endif
	    endif
	until NOT (   EndWord()		// Continue to end of paragraph or until
		   or Pos( chr(CurrChar()), ".!?" ) )
	   or (CurrLine() > i)		// end of file.

	PopPosition()
	j = j + 1

    until NOT Again
       or (j > 4)			// We do all this no more than 5 times.

//
// Okay, the paragraph is ready to justify
//
    if Again
/*    or NOT Justify	*/		    // Uncomment if "Justify" defined.
	PushPosition()			// If necessary, one last time to make
	Dwn = WrapPara()		// sure the paragraph is wrapped.
	i = CurrLine()
	if Dwn
	    i = i - 1
	endif
/*	  if NOT Justify		  // If not justifying, we need go
	    KillPosition()		// no further.
	    if NOT Dwn
		EndLine()		// NOTE: Un-comment this bit of code
	    endif			// if controlling variable "Justify"
	    Set( WordSet, wrdset )     // is available.
	    Set( WordWrap, wwstate )
	    return( Dwn )
	endif				*/
	PopPosition()
    endif

//
// Add spaces to justify the paragraph
//
    Set(WordSet, ChrSet(Chr(0) + '-' + Chr(8) + Chr(10) +
					       '-' + Chr(31) + '!-' + Chr(255)))
    while i > CurrLine()

	linelen = PosLastNonWhite()
	spaces = rm - linelen

	if spaces > 0			// NOTE: "sp" holds the cursor position
	    if CurrLine() mod 2		// at entry the first time through;
		GotoPos( sp )		// thereafter it holds the position of
	    else			// the first nonwhile character on the
		EndLine()		// line.
	    endif

	    while spaces
		if CurrLine() mod 2
		    WordRight()
		    if CurrChar() == _AT_EOL_
			GotoPos( sp )
			WordRight()
		    endif
		else
		    WordLeft()
		    if CurrPos() <=  sp
			EndLine()
			WordLeft()
		    endif
		endif
		InsertText(' ', _INSERT_)
		spaces = spaces - 1
	    endwhile

	endif

	Down()				// Next line.
	sp = PosFirstNonWhite()		// Locate starting position.
    endwhile

//
// ---and that, folks, is all
//
    Down()				// Go to first line following
    if Dwn				// this paragraph.
	BegLine()			// If at end-of-file, leave
    else				// cursor at end-of-line
	EndLine()			// instead of the beginning.
    endif
    Set( WordSet, wrdset )		// Restore entry state.
    Set( WordWrap, wwstate )
    return(Dwn)				// Back to caller.

end mJustifyPara

/*******************************************************************************
				 Little Helpers
*******************************************************************************/
//
// Convenient test driver
//
public proc mTest()
   warn( "mJustifyPara() is ", iif( mJustifyPara(), "TRUE", "FALSE" ) )
end
//
// Gotta have this whether we want it or not!
//
proc main()
end
