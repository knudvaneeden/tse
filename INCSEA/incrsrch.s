/*
 *  Function:	mIncrementalSearch  (Improved)
 *  Author:	Tony L. Burnett
 *		(based on original mIncrementalSearch macro)
 *
 *  Version	    Modifications
 *    1.0	    Initial release
 *    1.1	    Added prev/next file options (22-Dec-1994 @ 10:54 am)
 *    1.11	    Corrected problem with Ctrl-6 and Ctrl-4 definitions
 *		    begin backward and removed the 'G' option from the
 *		    default string if it exists because it generates bogus
 *		    results. (26-Jan-1995 @ 03:51 pm)
 *
 *
 * Description:
 *  The macro code which follows this comment block can be used as a direct
 *  replacement for the old mIncrementalSearch routine.  However, this version
 *  adds several new functions and makes minor modifications to the existing
 *  routine in the following ways:
 *
 *  Added functions:
 *	*   It is now possible to toggle (on/off) case-sensitivity,
 *	    regular expression, whole-word, begin-line and end-line matching.
 *
 *	*   It is possible to start a search from the bottom of a buffer.
 *
 *	*   There is now a quick help display (<F1>)
 *
 *	*   You can jump to the next, or previous, file in TSE's filering
 *	    while searching.
 *
 *  Modified Functions:
 *	*   Several of the command keys have been modified (but you can
 *	    change them to anything you want by modifying the code.)
 *
 *	*   <Escape> returns the cursor to its original (before starting the
 *	    search) position.
 *
 *	*   When a match is not found the key strokes are still added to the
 *	    search string.  This way you can start a search from the beginning
 *	    or end of a file without having to retype characters.
 *
 *	*   I removed the <F5> command key since I never used it, but you can
 *	    re-add it if you want.
 *
 *  If you have any comments or suggestions I can be reached in the
 *  Semware Forum on CompuServe, or at any of the following addresses.
 *
 *  CompuServe: 70004,1406
 *  Internet:	70004.1406@compuserve.com
 *
 * Installation:
 *	Remove the existing mIncrementalSearch macro from your .UI file
 *	(usaully tse.ui) and replace it with this entire file.	Re-burn
 *	TSE and your done.  You might want to change some of the key commands,
 *	but that is up to you.
 *
 *	or
 *
 *	Change the name of my macro from mIncrementalSearch to something else
 *	(maybe mImprovedISearch) and #include it (or insert this file) into you
 *	default .UI file. You will then have to assign a key to this new macro.
 *	Re-burn TSE.
 */


/*
 * a couple of constants used by mToggleOpts and/or mIncrementalSearch
 */
constant    S_MAX = 40,
	    OPT_MAX = 11

constant    DISP_HELP_KEY = <F1>,
	    CANCEL_KEY = <Escape>,
	    STOP_KEY = <Enter>,
	    BEG_FILE_KEY = <Ctrl B>,
	    END_FILE_KEY = <Ctrl E>,
	    NEXT_MATCH_KEY = <Ctrl L>,
	    PREV_MATCH_KEY = <Ctrl K>,
	    NEXT_FILE_KEY = <Ctrl N>,
	    PREV_FILE_KEY = <Ctrl P>,
	    TOGGLE_CASE_KEY = <Ctrl I>,
	    TOGGLE_REGEXP_KEY = <Ctrl X>,
	    TOGGLE_WORD_KEY = <Ctrl W>,
	    TOGGLE_BEGIN_KEYA = <Ctrl 6>,	// it should be Ctrl ^, but
	    TOGGLE_BEGIN_KEYB = <CtrlShift 6>,	// that is not possible
	    TOGGLE_END_KEYA = <Ctrl 4>, 	// it should be Ctrl $, but
	    TOGGLE_END_KEYB = <CtrlShift 4>	// that is not possible

helpdef IncrSrchHelp
    title = "Quick Help for Improved Incremental Search"
    x = 5
    "<F1>           Display this help screen."
    "<Escape>       Cancel search, return to original position."
    "<Enter>        Stop search, leave cursor on current match."
    "<Ctrl L>       Display next match."
    "<Ctrl K>       Display previous match."
    "<Ctrl B>       Force search to start from beginning of buffer."
    "<Ctrl E>       Force search to scan for first match at end of buffer."
    "<Ctrl I>       Toggle case matching on/off."
    "<Ctrl X>       Toggle regular expression matching on/off."
    "<Ctrl W>       Toggle whole-word matching on/off."
    "<Ctrl N>       Goto Next file in TSE's filering.*"
    "<Ctrl P>       Goto Previous file in TSE's filering.*"
    "<Ctrl ^(6)>    Toggle begin line matches on/off.*"
    "<Ctrl $(4)>    Toggle end line matches on/off.*"
    ""
    "* It might be necessary to follow this command with a <Ctrl B>,"
    "   <Ctrl E>, <Ctrl L> or <Ctrl K> in order to accomplish the"
    "   desired effect."
end

proc mToggleOpts (var string opts, string ch)
    string tmp_str[OPT_MAX]
    integer ch_loc

    ch_loc = Pos (ch, opts)	    // look for the ch in the option string

    if ch_loc == 0		    // the option is off so...
	opts = opts + ch	    // add it to the string
    else			    // the option is enabled, so remove it
	tmp_str = substr (opts, 1, ch_loc - 1)
	tmp_str = tmp_str + substr (opts, ch_loc + 1, length (opts))
	opts = tmp_str
    endif
end

proc mIncrementalSearch()
    string  s[S_MAX] = ""
    string  tmp_str[OPT_MAX]
    string  opts[OPT_MAX] = Upper (Query (FindOptions))
    integer ch
    integer global_or_reverse = FALSE
    integer next = FALSE

    /*
     * Remove the 'G' option if it exists or else the ^L and ^K options will
     * not work properly.
     */

    ch = Pos ("G", opts)

    if ch <> 0
	tmp_str = substr (opts, 1, ch - 1)
	tmp_str = tmp_str + substr (opts, ch + 1, length (opts))
	opts = tmp_str
    endif

    PushPosition()
    loop
	if Length(s) and (global_or_reverse or next)
	    opts = substr(opts, 1, length(opts) - 1)
	    global_or_reverse = FALSE
	    next = FALSE
	endif

	message ("I-Search [" + opts + "]:", s)

	retry:
	ch = getkey()
	case ch
	    when <BackSpace>		    // go back to start
		s = iif(length(s) <= 1, "", substr(s, 1, length(s) - 1))

	    when NEXT_MATCH_KEY 	    // just search again
		opts = opts + '+'
		next = TRUE

	    when PREV_MATCH_KEY 	    // go to previous occurrence
		opts = opts + 'B'
		global_or_reverse = TRUE

	    when BEG_FILE_KEY		    // beginning of file
		opts = opts + 'G'
		global_or_reverse = TRUE

	    when END_FILE_KEY		    // search from the end of the file
		opts = opts + 'B'
		global_or_reverse = TRUE
		EndFile ()

	    when TOGGLE_CASE_KEY	    // toggle case sensitivity
		mToggleOpts (opts, "I")

	    when TOGGLE_REGEXP_KEY	    // toggle regular expression
		mToggleOpts (opts, "X")

	    when TOGGLE_WORD_KEY	    // toggle word
		mToggleOpts (opts, "W")

	    when TOGGLE_BEGIN_KEYA,	    // toggle begline match (^)
		 TOGGLE_BEGIN_KEYB
		mToggleOpts (opts, "^")

	    when TOGGLE_END_KEYA,
		 TOGGLE_END_KEYB	    // toggle Endline match ($)
		mtoggleOpts (opts, "$")

	    when DISP_HELP_KEY		    // show the help screen
		QuickHelp (IncrSrchHelp)

	    when NEXT_FILE_KEY		    // goto next file in filering
		NextFile (_DEFAULT_)

	    when PREV_FILE_KEY		    // goto previous file in filering
		PrevFile (_DEFAULT_)

	    when STOP_KEY
		if Length(s)
		    AddHistoryStr(s, _FINDHISTORY_)
		endif
		KillPosition()		    // stay where we are
		break

	    when CANCEL_KEY
		PopPosition ()		    // aborted, return to original pos
		break
	    otherwise
		if (ch & 0xff) == 0	    // Function key?
		    goto retry		    // Yes, try again.
		endif
		s = s + chr(ch & 0xff)	    // mask off the scan code
	endcase
	find (s, opts)
    endloop
    UpdateDisplay()			    // to restore the status line
end
