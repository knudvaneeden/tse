//
// Crazy Jack's Version of JUSTIFY (or Fun With Regular Expressions)
//
//
// This	 version  of  Justify is called "mJustifyPara()" and is designed to be
// used (where suitable) as a substitute for "WrapPara()".    It  returns  the
// same TRUE or FALSE value that WrapPara() would return if called instead.
//
// If  you've ever tried the JUSTIFY macro that comes with TSE,  you will have
// noted that you get into trouble if you make any changes,  then try  to  re-
// wrap  a paragraph.   The spaces from the initial justification remain,  and
// new ones are added as necessary to line up the margins.   If you do this  a
// few  times,  your lines get to looking kind of sparse,  what with all those
// spaces accumulating.
//
// mJustifyPara() first removes all excess spaces from a paragraph,  then adds
// an additional space following periods,    question  marks  and  exclamation
// points,   and right brackets immediately preceded by the same,  and rewraps
// the paragraph.  Then, if the global integer variable "Justify" is TRUE,  it
// full-justifies the paragraph.
//
// This file contains a self-running version of the macro, but you should move
// it into your User Interface file and remove the "Main()" routine.  Assign a
// key  to toggle "Justify",  and put "mJustifyPara()" in place of "WrapPara()
// in your keyboard definition,  your menus,  and in the  macro  "mWrapPara()"
// (but check the next paragraph on this!).   NOTE:  Where there exists a call
// to "mWrapPara()", just leave it as is, but remember to change "mWrapPara()"
// as described in the next paragraph.
//
// IMPORTANT:	This  macro  may hang if it's run in a _SYSTEM_ buffer,	 where
// "RemoveTrailingWhite" has no effect.	  The macro "mWrapPara()" creates such
// a  situation	 when you mark off a column block for full justification.   It
// uses "CreateTempBuffer()" to make a buffer to which	it  moves  the	marked
// block,  where it does the desired justification.  To avoid the problem with
// this,  you must locate the "CreateTempBuffer()" command and	change	it  to
// "CreateBuffer(  "",	_HIDDEN_ ).   This revised version of "mJustifyPara()"
// will save and restore your setting of "RemoveTrailingWhite" and  runs  with
// this variable ON, which prevents the problem.
//
// This	 version is made possible by the TSE version 2.00 features that let us
// restrict the range of a find/replace to a single line or a marked block.
//
// Coding  notes:  Moving strings (such as Find and Replace strings,  and even
// option strings) more than two bytes long,  which are used more  than  once,
// out as "constant" strings referenced by name results in a saving of space.
//
// As  an  example of the use of "mJustifyPara()" in conjunction with a marked
// column block via a call to mWrapPara(), the paragraphs in this heading were
// all  marked  off  in  a single column block,  then full justified with this
// routine installed in my user interface as described above.
//
//							   Another Hideous Kluge
//					       (c)Copyright 1994 Jack Hazlehurst
//							     All rights reserved
//
// The following global variables are required to compile mJustifyPara():
//

integer Justify = TRUE

string	mjss1[] = '{[.?!]["' + "')>\]}]@ }{[~ ]}",	// These strings are
	mjss2[] = '[.?!,;:]["' + "')>\]}]@ #",		// used more than once
	mjss3[] = "[~ ] #",				// by lFind() and
	mjss4[] = "\0 ",				// lReplace() commands
	mjss5[] = "bxc"					// in mJustifyPara().

integer proc mJustifyPara()
    integer rm = Query(RightMargin),	// Position of right margin.
	    rtw = Set( RemoveTrailingWhite, ON ), // Needed for full justify.
	    spaces = 0,			// Number of spaces to add to this line.
	    Dwn = TRUE,			// Results of last REAL WrapPara().
	    sp = CurrPos(),		// Starting point on first line.
	    i,				// Line # of last line of paragraph.
	    j, k, rw			// Cursor Position after word wrap.
//
// First we locate the actual starting point
//
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
    PushBlock()
    UnMarkBlock()
//
// Next	 we  remove  possible  excess  spaces  from lines and make sure the
// paragraph is	 wrapped.   We	also  ensure  that  all	 embedded  periods,
// exclamation points and question marks are followed by two spaces.
//
    PushPosition()
    MarkLine()
    if WrapPara()			// Find number of last line in
	Up()				// paragraph and see that it's
    endif				// wrapped.
    MarkLine()
    PopPosition()			// Back to start of paragraph.

    if lFind( "[~\t .!?;:=\*/-]", "lx" )// . . . . In case paragraph begins
	PushPosition()			// with end-of-sentence punctuation.
	PushPosition()			// First we convert all tabs to
	lReplace( "\t", " ", "ln" )	// single spaces.
	PopPosition()
	PushPosition()			// Then we remove all excess spaces.
	lReplace( "{[~ ]}  #", "\1 ", "lxn" )
	PopPosition()

	repeat				// Process the paragraph until
	    PushPosition()		// things stop changing.
	    lReplace ( mjss1, "\1 \2", "lxn" )
	    UnMarkBlock()		// Re-insert spaces as needed
	    PopPosition()		// following end-of-sentence
	    MarkLine()			// sequences.
	    PushPosition()
	    Dwn = WrapPara()		// Each time we do this we must
	    i = CurrLine()		// rewrap the paragraph
	    j = i			// and get its extents.
	    rw = CurrRow()		// We also save resulting cursor
	    if Dwn			// position for later use.
		k = CurrPos()
		i = i - 1
		Up()
	    else
		k = -1
	    endif
	    MarkLine()
	    PopPosition()		// We repeat this if the Wrap resulted
					// in the need for another space to be
	until NOT lFind( mjss1, "lx" )	// inserted.

	PopPosition()			// We're done with normalizing the
    endif				// paragraph.

//
// Okay, the paragraph is ready to justify
//
    if NOT Justify			// If not justifying, we need go
	GotoLine(j)			// no further;	position cursor to
	if k < 0			// end of paragraph.
	    EndLine()
	else
	    GotoPos(k)
	endif
	ScrollToRow(rw)
	goto ParaReady
    endif

//
// Add spaces to justify the paragraph
//
    sp = CurrPos()
    while i > CurrLine()		// NOTE: "sp" holds the cursor position
					// at entry the first time through;
	goto FluffStart			// thereafter it holds the position of
	while spaces > 0		// the first nonwhile character on the
	    if CurrLine() mod 2		// current line.
		GotoPos( sp )
		lReplace( mjss2, mjss4, "cx" + Str(spaces) )
		spaces = rm - PosLastNonWhite()
		if spaces		// First try adding spaces at
		    GotoPos( sp )	// punctuation, then between all words.
		    lReplace( mjss3, mjss4, "cx" + Str(spaces) )
		endif
	    else			// Same for even lines, but in other
		EndLine()		// direction from end of line.
		lReplace( mjss2, mjss4, mjss5 + Str(spaces) )
		spaces = rm - PosLastNonWhite()
		if spaces
		    EndLine()
		    lReplace( mjss3, mjss4, mjss5 + Str(spaces) )
		endif
	    endif			// Keep it up until the line is
FluffStart:				// justified.
	    spaces = rm - PosLastNonWhite()
	endwhile

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
ParaReady:
    PopBlock()				// Restore entry state.
    Set( RemoveTrailingWhite, rtw )
    return(Dwn)				// Back to caller.

end mJustifyPara

/******************************************************************************/
//
// Remove this Main() procedure when you install it in your User Interface
//
proc Main()
    string S[10] = ""

    Justify = Ask( "Enter to full justify, Esc to just wrap ragged right.", S )
    mJustifyPara()
end
