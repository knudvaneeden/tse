
/******** vid.s ***********************************************************/
/* 									  */
/* 	Video Routines for the Semware Editor				  */
/* 	These may be included in TSE.S or your equivalent.		  */
/* 									  */
/* 	Source Code (c) UK Ashpool Systems by Rob Staveley 28-08-93	  */
/* 									  */
/**************************************************************************/

/******** vid.bin *********************************************************/
/*
 * External video routines.
 */
binary "\tse\asm\vid.bin"	/* Include path to the binary file. */

	integer proc SetMode(integer VidMode):0
	proc PageSel(integer PageNum):3

end

/******** mHiMode *********************************************************/
/*
 * If we are currently in the high resolution video mode, revert to the
 * old low mode. Otherwise go high.
 */

/* Globals */
integer
	LoMode = _25_LINES_		/* "Static" variable */

/* NB: these constants are set for the Tseng ET4000 132x43 text mode,
   you should replace the values here with those which are appropriate
   to your own video adaptor. Examples as follows:
   	Adaptor		HICOLS	HIMODE
   	------------------------------
   	ATI SVGA	132	33h
   	C&T SVGA	132	61h
   	Genoa		132	64h
   	Paradise	132	54h
   	Trident		132	5Ah
   	Tseng		132	22h
   	Video7		132	45h
*/
constant
	HICOLS = 132,			/* Number of columns in high mode */
	HIMODE = 22h			/* High video mode */

proc mHiMode()

	/* See if we are not currently in our high resolution
	   video mode, by checking the column count. */
	if Query(ScreenCols) <> HICOLS

		/* Save the current video mode. */
		LoMode = Query(CurrVideoMode)

		/* Use the external binary macro to select high mode. */
		if SetMode(HIMODE)
			/* Video mode is autodetected from BIOS,
			   this ensures screen refresh and update
			   of internal variables, ScreenCols &
			   ScreenRows. */
			Set(CurrVideoMode,_AUTO_DETECT_)
			return() /* Successful exit */
		endif
	endif

	/* Video node is reset to (original) low mode. */
	Set(CurrVideoMode,LoMode)

end mHiMode

/******** mPageFlip *******************************************************/
/*
 * Flip between video pages 0 and 1. This acts as a convenient screen
 * blanker, but who knows what gets typed into your file!
 */

/* Globals */
integer
	PageNo = 0

proc mPageFlip()

	if PageNo
		PageNo = 0
                PageSel(PageNo)
        else
        	PageNo = 1
                PageSel(PageNo)
        endif

end mPageFlip

