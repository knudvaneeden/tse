/* -------------------------------------------------------------------------- */
/* File Name...: VDIFF.S																		*/
/* Program Name: Visual "diff" Utility for The SemWare Editor                 */
/* Version.....: 0.10																			*/
/* Author......: Jim Susoy																		*/
/* Notice......: (C) Copyright 1993 - All Rights Reserved							*/
/* Desc........: This TSE macro enables TSE to display the differences (on a  */
/* 				  line-by-line basis) of two files by "highlighting" the lines */
/* 				  in one file that are different from the lines in another 		*/
/* 				  file.  The user can then move the line (in either direction) */
/* 				  to resolve the difference. All the differences are           */
/* 				  highlighted simultaneously. 											*/
/*  																									*/
/* Revisions...: 0.10	-	02/01/93	First Coding   									*/
/* 				  0.20	-	02/05/93	Added functions to move lines between  	*/
/* 											to aid in resolving differences. 			*/
/* 				  0.21	-	04/01/93 Formatted Drive C: (Just seeing if you 	*/
/* 											are paying attention!) 							*/
/* 				  0.30	-	04/02/93	Rewrote mDisplayDiffs() so that highlights*/
/* 											were not redrawn by TSE between each 		*/
/* 											iteration of the while loop. 					*/
/* 											It seems that TSE redraw the entire window*/
/* 											whenever it is switched to or from.  So   */
/* 											now VDiff does all its proccessing in 		*/
/* 											file2's window (it just switches between	*/
/* 											buffers) 											*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
/* Global Variables 																				*/
/* -------------------------------------------------------------------------- */
integer	Window1							/* Window ID of first diff window 			*/
integer	Window2							/* Window ID of second diff window 			*/
integer	Buffer1							/* Buffer ID of first diff file 				*/
integer	Buffer2							/* Buffer ID of second diff file 			*/
integer	VDiffHiAttr						/* Attribute to use to highlight diffs 	*/
string	File1Line[255] = ""			/* Storage for line comparison 				*/
string	File2Line[255] = ""			/* Storage for line comparison            */

/*
// ^begin^
//
// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
// PROC mDisplayDiffs()
// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//
// Desc.     :	This is the macro that does the actual DIFF of the two files
//             and highlighting of the differences.  It is called every time
//					the cursor row changes in either file
//
// Parameters:                -  void
//
// Returns   : Directly       -  void
//
// Notes     :
//
// ^end^
//
// ***********************    Revision History    ******************************
//
// ^rbegin^
//
// mDisplayDiffs()
//
// 02/01/93 -  First Coding
//
// ^rend^
*/
PROC mDisplayDiffs()
   integer 	i = 1
   integer	rows
   integer	x								/* Value of WindowX1 TSe var when called	*/
   integer	c								/* Value of WindowCols  						*/

   GotoWindow(Window2)
	x = Query(WindowX1)
	c = Query(WindowCols)
   PushPosition()
   rows = Query(WindowRows)			/* Get number of rows in window 				*/

   while(i <= rows)
		GotoBufferId(Buffer1)			/* Goto specified buffer 						*/
		GotoRow(i)							/* Go to the specified row 					*/
		File1Line = GetText(1,255)		/* Get the line 									*/
		GotoBufferId(Buffer2)			/* Goto specified buffer 						*/
		GotoRow(i)							/* Go to the specified row 					*/
		File2Line = GetText(1,255)		/* Get the line 									*/

   	GotoWindow(Window2)
   	if(File1Line <> File2Line)
         VGotoXY(x, i+2)
         PutAttr(VDiffHiAttr, Query(WindowCols))
   	endif
   	i = i + 1
	endwhile
	PopPosition()
END


/* -------------------------------------------------------------------------- */
/* The following support macros are called to move around and copy lines		*/
/* between the two files 																		*/
/* -------------------------------------------------------------------------- */
PROC mDiffCursorDown()
	GotoWindow(Window1)
	if(Down() <> 0)
		GotoWindow(Window2)
      Down()
   endif
	GotoWindow(Window2)
	UpdateDisplay(_WINDOW_REFRESH_)
	mDisplayDiffs()
END


PROC mDiffCursorUp()
	GotoWindow(Window1)
	if(Up() <> 0)
		GotoWindow(Window2)
		Up()
		UpdateDisplay(_WINDOW_REFRESH_)
		mDisplayDiffs()
	endif
	GotoWindow(Window2)
END


PROC mDiffPageUp()
	GotoWindow(Window1)
	if(PageUp() <> 0)
		GotoWindow(Window2)
		PageUp()
		UpdateDisplay(_WINDOW_REFRESH_)
		mDisplayDiffs()
	endif
	GotoWindow(Window2)
END


PROC mDiffPageDown()
	GotoWindow(Window1)
	if(PageDown() <> 0)
		GotoWindow(Window2)
		PageDown()
		UpdateDisplay(_WINDOW_REFRESH_)
		mDisplayDiffs()
	endif
	GotoWindow(Window2)
END


PROC mDiffBegFile()
	GotoWindow(Window1)
	if(BegFile() <> 0)
		GotoWindow(Window2)
		BegFile()
		UpdateDisplay(_WINDOW_REFRESH_)
		mDisplayDiffs()
	endif
	GotoWindow(Window2)
END

PROC mDiffEndFile()
	GotoWindow(Window1)
	if(EndFile() <> 0)
		GotoWindow(Window2)
		EndFile()
		UpdateDisplay(_WINDOW_REFRESH_)
		mDisplayDiffs()
	endif
	GotoWindow(Window2)
END

PROC mDiffCursorRight()
	GotoWindow(Window1)
	if(Right() <> 0)
		GotoWindow(Window2)
		Right()
		UpdateDisplay(_WINDOW_REFRESH_)
		mDisplayDiffs()
	endif
	GotoWindow(Window2)
END

PROC mDiffCursorLeft()
	GotoWindow(Window1)
	if(Left() <> 0)
		GotoWindow(Window2)
		Left()
		UpdateDisplay(_WINDOW_REFRESH_)
		mDisplayDiffs()
	endif
	GotoWindow(Window2)
END

PROC mDiffTopOfWindow()
	GotoWindow(Window1)
	if(BegWindow() <> 0)
		GotoWindow(Window2)
		BegWindow()
		UpdateDisplay(_WINDOW_REFRESH_)
		mDisplayDiffs()
	endif
	GotoWindow(Window2)
END

PROC mDiffBottomOfWindow()
	GotoWindow(Window1)
	if(EndWindow() <> 0)
		GotoWindow(Window2)
		EndWindow()
		UpdateDisplay(_WINDOW_REFRESH_)
		mDisplayDiffs()
	endif
	GotoWindow(Window2)
END

PROC mCopyLineFromOneToTwo()
	string 	text[255] = ""
	integer 	col

	GotoWindow(Window1)
	text = GetText(1,255)
	GotoWindow(Window2)
	col = CurrCol()
	InsertText(text,_OVERWRITE_)
	DelToEol()
	GotoColumn(col)
	GotoWindow(Window2)
END


PROC mCopyLineFromTwoToOne()
	string 	text[255] = ""
	integer 	col

	GotoWindow(Window2)
	text = GetText(1,255)
	GotoWindow(Window1)
	col = CurrCol()
	InsertText(text,_OVERWRITE_)
	DelToEol()
	GotoColumn(col)
	GotoWindow(Window2)
END


PROC mRollRightDown()
	GotoWindow(Window2)
	RollUp()
	UpdateDisplay(_ALL_WINDOWS_REFRESH_)
	mDisplayDiffs()
	GotoWindow(Window2)
END


PROC mRollRightUp()
	GotoWindow(Window2)
	RollDown()
	UpdateDisplay(_ALL_WINDOWS_REFRESH_)
   mDisplayDiffs()
   GotoWindow(Window2)
END



PROC mRollWindowsUp()
	GotoWindow(Window1)
	if(RollUp() <> 0)
		GotoWindow(Window2)
		RollUp()
		UpdateDisplay(_WINDOW_REFRESH_)
		mDisplayDiffs()
	endif
	GotoWindow(Window2)
END


PROC mRollWindowsDown()
	GotoWindow(Window1)
	if(RollDown() <> 0)
		GotoWindow(Window2)
		RollDown()
		UpdateDisplay(_WINDOW_REFRESH_)
		mDisplayDiffs()
	endif
	GotoWindow(Window2)
END


KEYDEF VDiffKeys
    <CursorUp>          mDiffCursorUp()   		/* Move cursor up in window 	*/
    <CursorDown>        mDiffCursorDown()			/* Move cursor down in window */
    <CursorRight>			mDiffCursorRight()		/* Move cursor right 			*/
    <CursorLeft>			mDiffCursorLeft()			/* Move cursor left 				*/
    <PgUp>					mDiffPageUp()				/* Page up 							*/
    <PgDn>              mDiffPageDown()			/* Page Down 						*/
    <CTRL PgUp>			mDiffBegFile()				/* Start Of File 					*/
    <CTRL PgDn>			mDiffEndFile()				/* End Of File 					*/

    <CTRL Home>			mDiffTopOfWindow()		/* Top Of Window 					*/
    <CTRL End>				mDiffBottomOfWindow()	/* Bottom Of Window 				*/
    <CTRL CursorRight>	mCopyLineFromOneToTwo()	/* Move line from left to right*/
    <CTRL CursorLeft>	mCopyLineFromTwoToOne() /* Move line from right to left*/
    <CTRL CursorUp>		mRollWindowsUp()
    <CTRL CursorDown>	mRollWindowsDown()

    <ALT CursorUp>		mRollRightUp() 			/* Roll right win up Cursor reamins in sync*/
    <ALT CursorDown>		mRollRightDown() 			/* Roll right win Down Cursor reamins in sync*/

    <Escape>            EndProcess()				/* Done 								*/
END

/*
// ^begin^
//
// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
// PROC mVisualDiff(integer attr)
// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//
// Desc.     :	This is the PUBLIC entry point of the macro.  It is responsible
//					for prompt the user for the name of the two files to DIFF,
//					as well as setting up the vertical windows and initializing
//					some global variables.
//
// Parameters: attr           -	The attribute to use to highlight the
//											differences in file2
//
// Returns   : Directly       -	void
//
// Notes     :
//
// ^end^
//
// ***********************    Revision History    ******************************
//
// ^rbegin^
//
// mVisualDiff()
//
// 02/01/93 -  First Coding
//
// ^rend^
*/
PROC mVisualDiff(integer attr)
	VDiffHiAttr		= attr							/* Store highlight attribute 		*/
	Message("Enter filename for file #1...")
	if(EditFile() <> 0)                 	/* Load File #1 							*/
   	Buffer1 = GetBufferId()					/* Store the buffer ID 					*/
   	BegFile()									/* Goto start if already in buffer 	*/
   	Window1 = WindowID()						/* Store window ID 						*/
   	Message("Enter filename for file #2...")
   	if(EditFile() <> 0)						/* Load File #2 							*/
      	Buffer2 = GetBufferId()				/* Store it's buffer ID 				*/
   		BegFile()								/* Goto start if already in buffer 	*/
      	VWindow()								/* Create Vertical windows 		  	*/
      	Window2 = WindowID()					/* Store the window ID 					*/
      	GotoWindow(Window1)					/* Goto window #1 						*/
      	GotoBufferID(Buffer1)				/* and put file #1 in it 				*/
      	GotoWindow(Window2)					/* Goto window #2 						*/
      	GotoBufferID(Buffer2)				/* and put file #2 in it 				*/
      	UpdateDisplay(_ALL_WINDOWS_REFRESH_)

      	mDisplayDiffs()						/* Do the Diffs 							*/
      	Enable(VDiffKeys)
      	Process()               			/* Process User Keystrokes 			*/
      	Disable(VDiffKeys)
      	PopWinClose()
   		UpdateDisplay(_All_Windows_Refresh_)
   	else
   		AbandonFile(Buffer1)					/* If they hit escape, Dump the file*/
   	endif
   endif
END


