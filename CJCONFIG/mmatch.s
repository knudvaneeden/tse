/*************************************************************************
  The match command.  Use this macro to match (){}{}<> chars (and others).

  NOTE: This is a modification of the mMatch() macro that comes  with  The
  Semware  Editor  and  can be found in TSE.S and the other user interface
  files.  The modification adds directionality to the searches and  allows
  the  search  control  strings  to  be  edited by the user during an edit
  session. (Modifications 07/01/93 by Jack Hazlehurst.)
  *************************************************************************/

string AllBrackets[20]	 = '(){}[]<>""',	// Pairs of chars to match
       LeftBrackets[12]	 = "[({[]",		// Left brackets to lFind
       RightBrackets[12] = "[)}\]]"		// Right brackets to lFind

proc GetLRBrackets( string Msg, var string Holder )
    string s[16] = SubStr( Holder, 2, Length(Holder)-2 )
    integer i					// This routine supports
    loop					// editing of the
	if NOT Ask( Msg, s )			// RightBrackets and
	    return()				// LeftBrackets variables.
	else
	    i = Pos( "]", s )			// If the string contains
	    if (i == 0)				// a right square bracket
	    or ( (i > 1) and (s[i-1] == "\") )	// it MUST be preceeded by
		Holder = "[" + s + "]"		// a backslash.	 Note that
		return()			// we present the user with
	    endif				// a string stripped of the
	endif					// enclosing square brackets
    endloop					// and put them back later.
end

proc GetAllBrackets()				// This routine does the same
    string s[16] = AllBrackets			// thing for the AllBrackets
						// variable which has somewhat
    loop					// different requirements.
	if NOT Ask( "Change bracket pairs:", s )
	    return()
	elseif (Length(s) > 1)			// We MUST have something, and
	and    ((Length(s) & 1) == 0)		// everthing must come in pairs.
	    AllBrackets = s			// That's why the length must
	    return()				// be even.
	endif
    endloop
end

proc MFixScroll()			// Fixup routine used to undo
    integer p = CurrPos()		// scrolling effects.
    KillPosition()
    BegLine()
    GotoPos(p)
end

integer proc mMatch(integer dir)	// The match routine itself.
    integer px, p, level
    integer mc, ch

    p = Pos(chr(CurrChar()), AllBrackets)	// Maybe we're on a bracket?
    px = p
    // Check for wrong-way match character
    PushPosition()
    if	(px <> 0)				// We got a hit!
	if AllBrackets[px+1] == AllBrackets[px] // If like " or ' or ,
	    if dir < 0				// adjust pointer so remainder
		p = p + 1			// of code will work!
	    endif				// If current bracket direction
	elseif (px & 1) and (dir < 0)		// wrong for direction requested
	    px = 0				// we pretend we didn't get a
	elseif not ((p & 1) or (dir < 0))	// hit;	 instead we set up
	    NextChar()				// search for appropriate
	    px = 0				// starting point.
	endif
    endif
    // If we're not already on a match char, go forward or backward to find one
    if px == 0 and lFind( iif( dir < 0, LeftBrackets, RightBrackets ),
						      iif( dir < 0, "bx", "x") )
	mFixScroll()
	return (FALSE)
    endif
    PopPosition()

    PushPosition()
    if p
	ch = asc(AllBrackets[p])	// Get the character we're matching
	mc = asc(AllBrackets[iif(p & 1, p + 1, p - 1)])	 // And its reverse
	level = 1			// Start out at level 1

	while lFind("[\" + chr(ch) + "\" + chr(mc) + "]", iif(p & 1, "x+", "xb"))
	    if ch == mc			// Maybe not TRUE barckets --
		mFixScroll()
		return( TRUE )
	    endif
	    case CurrChar()		// And check out the current character
		when ch
		    level = level + 1
		when mc
		    level = level - 1
		    if level == 0
			mFixScroll()	// Fix any hor scroll & kill pos.
			return (TRUE)	// And return success
		    endif
	    endcase
	endwhile
    endif
    PopPosition()			// Restore position
    return (warn("Match not found"))	// Warn() returns False
end mMatch


