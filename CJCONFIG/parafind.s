/*******************************************************************************

		 FIND BEGIN/END OF NEXT/PREVIOUS PARAGRAPH

Written by: Jack Hazlehurst
Date:	    06/03/93
Released to the Public Domain

    These are routines to find the beginning or end of the previous or	next
    paragraph.	 Regardless  of	 the setting of ParaEndStyle, these routines
    treat the style as 1, which covers all possibilities.

    The parameter "EOPSwitch" indicates which end of the paragraph  to	stop
    on.	  TRUE	means  "stop  at  end-of-paragraph";  FALSE  means  "stop at
    beginning-of-paragraph.  The intended use would  have  the	value  of  a
    togglable global parameter supplied, or a constant, depending on how the
    keys are assigned, or the menu arranged.

    I have used a relaxed definition of a paragraph in these  routines.	  In
    general,  a	 paragraph  ends  where	 there	is a change in the amount of
    indent.  If we begin at a break point, I look for a	 greater  indent  to
    identify  the start of a paragraph, but otherwise ANY change does it.  I
    have to do this since I never know when I start what the relationship of
    the	 cursor is to the start or end of a paragraph.	I suppose I could do
    more analysis, but the routines are messy enough as they are!

    I am annoyed when moving to a place on the screen puts the cursor on the
    top	 or bottom line so that you can't see what's comming next, and these
    routines can leave you there.  So I've written a couple of functions  to
    detect  this  situation  and  scroll  the  screen  a  bit.	You may find
    RepoTop() and RepoBot() useful in your other macros.

*******************************************************************************/

//
// First we have a couple of helper routines for repositioning the screen
// when the cursor gets too close to the top or bottom edge.   Adjust the
// distances to suit your own tastes.
//
proc RepoTop()
    if CurrRow() < 4
	ScrollToRow( 5 )
    endif
end

proc RepoBot()
    if CurrRow() > ( Query(WindowRows) - 3 )
	ScrollToRow( Query(WindowRows) - 4 )
    endif
end

//------------------------------------------------------------------------------
//
// Go to the NEXT start or end of paragraph encountered
//
integer proc mNextPara( integer EOPSwitch )
    integer ind = PosFirstNonWhite(),
	    cp	= CurrPos()
				// At first we don't know where we are.
    if CurrLine() >= NumLines()		// In case we're at EOF.
	if  EOPSwitch
	and (cp <= CurrLineLen())
	    goto GoodEnd
	else
BadEnd:
	    BegLine()
	    RepoBot()
	    EndLine()
	    return( FALSE )
	endif
    endif

    if ind				// Maybe we're just at a paragraph
	Down()				// break.  We check the line below.
	if NOT PosFirstNonWhite()	// If it has more indent, it's a break.
	or (ind < PosFirstNonWhite())
	    if EOPSwitch		// If we're looking for EOP, check
		Up()			// previous line to see if we're left
		if cp <= CurrLineLen()	// of EOL.
		    goto GoodEnd	// If so, we're there.
		endif
		Down()			// Otherwise search must continue.
		if PosFirstNonWhite()
		    Down()
		endif
	    else			// See if we're at BOP.
		if PosFirstNonWhite()
		    goto GoodBeg
		endif
	    endif
	endif
	ind = PosFirstNonWhite()
    endif


    if NOT PosFirstNonWhite()		// Are we in a paragraph?
	ind = 0
	repeat				// if not, try to find one.
	    if NOT Down()
		goto BadEnd		// No paragraph if EOF.
	    endif
	until PosFirstNonWhite()
	if NOT EOPSwitch		// If looking for start of paragraph,
	    goto GoodBeg		// we are there.
	else
	    Down()
	endif
    endif			// We either started in paragraph and are
				// looking for next, or are looking for EOP.
    if NOT ind
	ind = PosFirstNonWhite()	// Get our running indent amount.
	if NOT ind
	    ind = 1
	endif
    endif
    while ind == PosFirstNonWhite()	// Run down the file watching for a
	if NOT Down()			// change.
	    if EOPSwitch		// At end-of-file, results depend on
		goto GoodEnd		// whether we want EOP or not.
	    endif
	    goto BadEnd
	endif
    endwhile			// So now we are one line past end of the
				// previous paragraph.
    if EOPSwitch			// If we're looking for EOP, we just
	Up()				// back up a line and go to EOL.
GoodEnd:
	BegLine()
	EndLine()
	RepoBot()
	return( TRUE )
    endif

    while NOT PosFirstNonWhite()	// We're looking for start of
	if NOT Down()			// paragraph.
	    goto BadEnd			// If we find EOF instead,
	endif				// we've failed.
    endwhile


GoodBeg:
    BegLine()				// We found it!	 Go to first character
    GotoPos( PosFirstNonWhite() )	// of line and report success.
    RepoBot()
    return( TRUE )

end

//------------------------------------------------------------------------------
//
// Go to the PREVIOUS start or end of paragraph encountered
//
integer proc mPrevPara( integer EOPSwitch )
    integer ind = PosFirstNonWhite(),
	    cp	= CurrPos()
				// At first we don't know where we are.
    if CurrLine() <= 1			//First treat possible top-of-file.
	if  NOT EOPSwitch
	and (cp > ind)
	    goto ToBeg
	else
	    BegLine()
	    return( FALSE )
	endif
    endif

    if ind				// Maybe we're just at paragraph
	Up()				// break.  We check the line above.
	if ind > PosFirstNonWhite()	// If it has less indent, we're at EOP.
	    if NOT EOPSwitch		// If we're looking for BOP, and this
		if cp > ind		// To BOP on previous line?
		    Down()		// Yup.
		    goto ToBeg
		else
		    ind = 0		// Otherwise for continued search up.
		endif
	    endif
	endif
    endif
				// We're somewhere else!
    if NOT PosFirstNonWhite()		// Are we in a paragraph?
	ind = 0
	repeat				// If not, we must search upward
	    if not Up()			// looking for non-blank line.
		BegLine()
		return( FALSE )		// No paragraph if BOF.
	    endif
	until PosFirstNonWhite()
	if EOPSwitch			// If looking for end of paragraph,
	    goto ToEnd			// we are there.
	endif
    endif			// We are in a paragraph, either looking for
				// BOP or EOP in previous paragraph.
    if NOT ind
	ind = PosFirstNonWhite()	// Get our running indent amount.
    endif
    if ind				// Run up the file watching for a
	while ind == PosFirstNonWhite() // change.
	    if NOT Up()			// At BOF, results depend on
		if NOT EOPSwitch	// whether we want EOP or not.
		    goto ToBeg
		endif
		BegLine()
		return( FALSE )
	    endif
	endwhile
    endif			// So now we may be one line above the top of
				// the previous paragraph.
    if NOT EOPSwitch			// If we're looking for BOP,
	if NOT PosFirstNonWhite()	// if one line above BOP,
	    Down()			// back up a line,
	endif				// and go to start of line.
ToBeg:
	BegLine()
	GotoPos( PosFirstNonWhite() )
	RepoTop()
	return( TRUE )
    endif

    repeat				// We're looking for end of previous
	if NOT Up()			// paragraph.  If we find BOF
	    EndLine()			// instead, we've failed.
	    return( FALSE )
	endif
    until PosFirstNonWhite()

ToEnd:
    BegLine()				// We found it!	 Go to end of line
    EndLine()				// and report success.
    RepoTop()
    return( TRUE )

end
//------------------------------------------------------------------------------

public proc test()
    Message("mNextPara returned ", iif( mNextPara(0),"TRUE","FALSE" ) )
end

proc main()
end
