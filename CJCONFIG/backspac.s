/*********************************************************************
  This is a modification of the "mBackSpace()" macro provided with The
  Semware  Editor.   It	 has  been enhanced for languages to track the
  indenting levels on the lines above the  current  line  rather  than
  just	using  the  tab  or nominal indent amounts to make its behavior
  more like that of the Borland editors.
  (Modifications 07/01/93 by Jack Hazlehurst.)
  /*********************************************************************
  Fancy backspace() command.

  Taken  from  original  TSE  macros,  then  modified for languages to
  "outdent" when there is only white space before the cursor, tracking
  the first non-white-character of lines above, sort of like Borland's
  environment.

  Also does special handling for overwrite mode.  In  overwrite  mode,
  does a "rubout" instead of a backspace.
 *********************************************************************/

proc mBackSpace()
    integer sc, c1, xt, rtw

    if CurrPos() == 1		  // at beg-of-line, just join to previous
	if PrevChar()
	    JoinLine()
	endif
	return ()
    endif

    // if from here to prev-tabstop is 'white', then TabLeft()
    // and/or other oddities of language processing

    if Query(AutoIndent) and language
	if CurrPos() < PosFirstNonWhite()
	    TabLeft()
	    return ()
	endif

	if (CurrPos() == PosFirstNonWhite())	// For languages, if we're on
	or (PosFirstNonWhite() == 0)		// blank line or first non-white
	    PushBlock()				// we search up the file for
	    xt = Set( ExpandTabs, ON )		// next line that's indented
	    rtw = Set( RemoveTrailingWhite, OFF )
	    PushPosition()			// less to line up with.  We
	    sc = CurrCol()			// force tab expand on so we
	    while Up()				// can determine indent amount.
		UnmarkBlock()			// Note that the DISPLAY
		c1 = PosFirstNonWhite()		// controls the movement,
		if c1 <> 0			// not the line position.
		    BegLine()
		    MarkChar()
		    GotoPos(c1)
		    MarkChar()
		    if sc > CurrCol()		// We look for the first line
			sc = CurrCol()		// whose first non-white is to
			break			// the left of our position in
		    endif			// the starting line.  We mark
		endif				// its leading white space as
	    endwhile				// a character block.
	    PopPosition()			// Back to the starting line.
	    if sc == CurrCol()			// Did we find anything?
		TabLeft()			// No.
	    else
		BegLine()			// Remove current leading white
		DelChar( PosFirstNonWhite() - 1 )
		if isBlockInCurrFile()		// and replace with marked
		    CopyBlock()			// leading white space.
		    GotoBlockEnd()
		endif
	    endif
	    Set( RemoveTrailingWhite, rtw )
	    Set( ExpandTabs, xt )		// Restore original conditions.
	    PopBlock()
	    return()				// Done.
	endif

	PushPosition()				// For languages, if we're past
	GotoColumn(CurrCol() - DistanceToTab()) // end of line, we tab left
	if CurrPos() > PosLastNonWhite()	// instead of imitating left
	    PopPosition()			// arrow.  This helps us line
	    TabLeft()				// up with comments quicker.
	    return ()
	endif
	PopPosition()
    endif

    // Finally, do either rubout or backspace based on InsertMode

    Left()
    if CurrChar() >= 0
	if Query(Insert)
	    DelChar()
	else
	    InsertText(" ", _OVERWRITE_)
	    Left()
	endif
    endif
end
