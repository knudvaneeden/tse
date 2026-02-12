// DRAGDROP.S ù Mouse selection and drag-drop macro.
// 10/03/94 ù Christopher Antos, chrisant@microsoft.com
//
// This macro implements mouse selection and drag-drop support similar
// to Word for Windows.	 Feel free to modify, customize, distribute,
// etc this macro file.
//
//	ù For drag-scrolling, we try to match the delay against the
//		value of MouseRepeatDelay.  See mDelay().
//
//	ù Will not scroll properly in some directions for borderless windows,
//		depending on which edges of the window actually have borders.
//		This was a design decision to improve performance (too many
//		conditions were slowing it down).


#define FLOATING_FEEDBACK 1

// Constants --------------------------------------------------------------

			// this should be set to whatever key invokes your MainMenu().
constant MAINMENU_KEY = <Escape>

			// this should be set to some key to invoke the dragdrop
			// help screen, or 0 to disable this key.
constant HELP_SCREEN_KEY = 0

			// number of ticks to wait before drag-scrolling,
			// to allow slop time for dragging to another window.
constant SLOP_TICKS = 3

			// double-click timer
constant DBLCLK_SLOP = 7

			// colors for the drag feedback.
			// set to 0 to use MenuTextLtrAttr and MenuTextAttr.
			// i like using a color that is different, though, to alert
			// me that i'm in dragdrop mode!
integer COLOR_HILITE = 0	//Color(bright yellow on blue)
integer COLOR_TEXT = 0		//Color(bright white on blue)
integer COLOR_FEEDBACK = Color(blink blue on white)

			// keyboard flag constants
constant _ALT=080h, _CTRL=040h, _SHIFT=020h, _ACS=0e0h



// Variables --------------------------------------------------------------

integer mouseNumClicks = 0



// Help -------------------------------------------------------------------

helpdef Mouse
	title = "Mouse Reference"
	x = 10

"        ÄþÄ Mouse Controls ÄþÄ"
""
"LeftBtn             Move cursor or switch windows"
"LeftBtn + hold      Mark word or switch windows"
"LeftBtn x2          Mark line"
"LeftBtn + drag      Mark stream or drag block"
"LeftBtn x2 + drag   Mark lines"
"Ctrl LeftBtn        Mark column block"
"Alt LeftBtn         Mark lines"
""
"Shift LeftBtn       Switch windows and move cursor"
""
""
"        ÄþÄ While dragging ÄþÄ"
""
"Escape              Abort operation"
"Ctrl                Copy block (instead of move)"
"Alt                 Overwrite block on copy or move "
""
"Alt ,               Previous file"
"Alt .               Next file"
end



// Helper Functions -------------------------------------------------------

proc EatKeys()
	while KeyPressed()
		GetKey()
	endwhile
end


proc mTrackMouseCursor()
	if GotoMouseCursor()
		TrackMouseCursor()
		EatKeys()
	endif
end


proc mDelay(integer i)
	i = i / 2 + i * 10
	while i
		i = i - 1
	endwhile
end



// Core Functions ---------------------------------------------------------

proc mPutHelpLine(string s)
	integer sattr

	if not Query(ShowHelpLine)
		return ()
	endif

	sattr = Set(Attr, Query(MenuTextAttr))
	VGotoXYAbs(1, iif(Query(StatusLineAtTop), Query(ScreenRows), 1))
	PutHelpLine(s)
	ClrEol()
	Set(Attr, sattr)
end


proc PutDragFeedback(integer key)
	if not Query(ShowHelpLine)
		return()
	endif

	VGotoXYAbs(Query(ScreenCols)-13,
			iif(Query(StatusLineAtTop), Query(ScreenRows), 1))
	PutHelpLine(iif(key&_CTRL, " {[}COPY{]}", " {[}MOVE{]}"))
	PutHelpLine(iif(key&_ALT, " {[}OVER{]} ", "        "))
end


integer proc mTrackMouseCursor2()
	integer mousekeypressed = Query(MouseKey)
	integer lastmousekey = Query(MouseKey)
	integer fDelay = FALSE
	integer fUpdate
	integer ticks = GetClockTicks()
	integer fRet = FALSE
	integer xofs
	integer fPop = FALSE

	PutDragFeedback(mousekeypressed)
	loop
		fUpdate = FALSE
		MouseStatus()
		if KeyPressed()
			case GetKey()
				when <Escape>
					goto byebye
				when <Alt ,>
					PrevFile()
				when <Alt .>
					NextFile()
			endcase
			fUpdate = TRUE
		endif
		if (Query(MouseKey)&~_ACS) == <59395>
			UnMarkBlock()
			goto byebye
		endif
		if (Query(MouseKey)&_ACS) <> (lastmousekey&_ACS)
			PutDragFeedback(Query(MouseKey))
			fUpdate = TRUE
		endif
		if (Query(MouseKey)&~_ACS) <> (mousekeypressed&~_ACS)
			break
		endif
		lastmousekey = Query(MouseKey)
		//if WindowId() <> MouseWindowId()
		//	GotoWindow(MouseWindowId())
		//endif

		if MouseHotSpot() == _MOUSE_MARKING_
			GotoMouseCursor()
			ticks = GetClockTicks()
		else
			if GetClockTicks() < ticks or
					GetClockTicks()-ticks > SLOP_TICKS

				if Query(MouseY) < Query(WindowY1)
					// fool GotoMouseCursor
					Set(MouseY, Query(WindowY1))
					GotoMouseCursor()
					if Up()
						fUpdate = TRUE
						mDelay(Query(MouseRepeatDelay))
						fDelay = TRUE
					endif
				elseif Query(MouseY) >= Query(WindowY1)+Query(WindowRows)
					// fool GotoMouseCursor
					Set(MouseY, Query(WindowY1)+Query(WindowRows))
					GotoMouseCursor()
					if Down()
						fUpdate = TRUE
						mDelay(Query(MouseRepeatDelay))
						fDelay = TRUE
					endif
				endif
				if Query(MouseX) < Query(WindowX1)
					xofs = CurrXoffset()
					GotoMouseCursor()
					if not fDelay
						mDelay(Query(MouseRepeatDelay))
					endif
					if xofs <> CurrXoffset()
						fUpdate = TRUE
					endif
				elseif Query(MouseX) >= Query(WindowX1)+Query(WindowCols)
					xofs = CurrXoffset()
					GotoMouseCursor()
					if not fDelay
						mDelay(Query(MouseRepeatDelay))
					endif
					if xofs <> CurrXoffset()
						fUpdate = TRUE
					endif
				endif
				fDelay = FALSE
			endif
		endif

		if not fUpdate and (Query(MouseY) <> Query(LastMouseY) or
				Query(MouseX) <> Query(LastMouseX))
			fUpdate = TRUE
		endif

		if fUpdate
			#ifdef FLOATING_FEEDBACK
			if fPop
				PopWinClose()
			endif
			#endif

			UpdateDisplay()

			#ifdef FLOATING_FEEDBACK
			fPop = TRUE
			//VGotoXYAbs(Query(MouseX), Query(MouseY))
			//PutNCharAttr(iif(Query(MouseKey)&_CTRL, "[+]", "[ ]"), 3)
			if Query(MouseX) < Query(ScreenCols)-8
				PopWinOpen(Query(MouseX)+1, Query(MouseY),
						Query(MouseX)+8, Query(MouseY),
						1, iif(Query(MouseKey)&_CTRL, " copy", " move"),
						COLOR_FEEDBACK)
			else
				PopWinOpen(Query(MouseX)-8, Query(MouseY),
						Query(MouseX)-1, Query(MouseY),
						1, iif(Query(MouseKey)&_CTRL, "copy ", "move "),
						COLOR_FEEDBACK)
			endif
			#endif
		endif
	endloop

	fRet = TRUE
byebye:
	#ifdef FLOATING_FEEDBACK
	if fPop
		PopWinClose()
	endif
	#endif
	return (fRet)
end


proc mMouseDrag(integer markingstyle)
	integer ctrl, alt
	integer smtla = Query(MenuTextLtrAttr), smta = Query(MenuTextAttr)

	Set(Marking, OFF)
	GotoMouseCursor()
	UpdateDisplay()
	case mouseNumClicks
		when 1
			if isCursorInBlock()
				if WaitForMouseEvent(_MOUSE_MOVE_|_MOUSE_RELEASE_) == _MOUSE_MOVE_
					trackmouse:
					if COLOR_HILITE <> 0
						Set(MenuTextLtrAttr, COLOR_HILITE)
					endif
					if COLOR_TEXT <> 0
						Set(MenuTextAttr, COLOR_TEXT)
					endif
					//PushPosition()
					mPutHelpLine("{DRAGDROP: Ctrl}-Copy {Shift}-Move {Alt}-Over {ESC}-Cancel")
					if not mTrackMouseCursor2()
						//PopPosition()
					else
						//KillPosition()
						ctrl = GetKeyFlags() & _CTRL_KEY_
						alt = GetKeyFlags() & _ALT_KEY_
						if ctrl
							CopyBlock(iif(alt, _OVERWRITE_, _DEFAULT_))
						else
							MoveBlock(iif(alt, _OVERWRITE_, _DEFAULT_))
						endif
					endif
					Set(MenuTextLtrAttr, smtla)
					Set(MenuTextAttr, smta)
					UpdateDisplay(_HELPLINE_REFRESH_|_REFRESH_THIS_ONLY_)
				else
					// not even sure this will ever get called!
					if KeyPressed()
						case GetKey()
							when <Alt ,>, <Alt .>
								PushKey(Query(Key))
								// jump - the keys will get processed by
								// mTrackMouseCursor2, which we call above.
								goto trackmouse
							otherwise
								EatKeys()
						endcase
					endif
				endif
			else
				case WaitForMouseEvent(_MOUSE_HOLD_TIME_|_MOUSE_MOVE_|_MOUSE_RELEASE_)
					when _MOUSE_HOLD_TIME_
						MarkWord()
						mouseNumClicks = 0
					when _MOUSE_MOVE_
						MouseMarking(markingstyle)
						mouseNumClicks = 0
				endcase
			endif
		when 2
		/*
			if WaitForMouseEvent(_MOUSE_MOVE_|_MOUSE_RELEASE_) == _MOUSE_MOVE_
				UnMarkBlock()
				MarkChar()
				TrackMouseCursor()
				MarkChar()
				//MouseMarking(_NONINCLUSIVE_)
				mouseNumClicks = 0
				EatKeys()
			else
				MarkWord()
			endif
		when 3
		*/
			UnMarkBlock()
			MarkLine()
			TrackMouseCursor()
			MarkLine()
			//MouseMarking(_LINE_)
			mouseNumClicks = 0
			EatKeys()
	endcase
end


integer last_click_tick = 0
proc mLeftBtn(integer markingstyle, integer fMark)
	integer event

	case MouseHotSpot()
		when _MOUSE_MARKING_
			MouseStatus()
			if (Query(MouseX) == Query(LastMouseX) and
					Query(MouseY) == Query(LastMouseY)) and
					GetClockTicks() - last_click_tick <= DBLCLK_SLOP
				if mouseNumClicks < 4
					mouseNumClicks = mouseNumClicks + 1
				endif
			else
				mouseNumClicks = 1
			endif
			last_click_tick = GetClockTicks()
			if MouseWindowId() <> WindowId()
				GotoWindow(MouseWindowId())
				UpdateDisplay()
				event = WaitForMouseEvent(_MOUSE_HOLD_TIME_|_MOUSE_RELEASE_|_MOUSE_MOVE_)
				if event == _MOUSE_HOLD_TIME_
					GotoMouseCursor()
					UpdateDisplay()
					event = WaitForMouseEvent(_MOUSE_RELEASE_|_MOUSE_MOVE_)
					// set event so we can fall through to next if statement
				endif
				if event == _MOUSE_MOVE_
					mTrackMouseCursor()
				endif
				mouseNumClicks = 0
			elseif fMark
				mMouseDrag(markingstyle)
			elseif not fMark
				mTrackMouseCursor()
			endif
		otherwise
			mouseNumClicks = 0
			if not ProcessHotSpot()
				//MainMenu()
				PushKey(<MAINMENU_KEY>)
			endif
	endcase
end



// Main -------------------------------------------------------------------

proc Main()
	QuickHelp(Mouse)
end



// Keydefs ----------------------------------------------------------------

// undocumented keys
//<14837>	<Ctrl Spacebar>
//<14841>	<Alt Spacebar>
//<508>		<CtrlShift Esc>
//<59585>	<CtrlAlt LeftBtn>
//<59489>	<CtrlShift LeftBtn>
//<59617>	<CtrlShiftAlt LeftBtn>
//<59553>	<ShiftAlt LeftBtn>
//<59586>	<CtrlAlt LeftBtn>
//<59490>	<CtrlShift LeftBtn>
//<59618>	<CtrlShiftAlt LeftBtn>
//<59554>	<ShiftAlt LeftBtn>

<LeftBtn>				mLeftBtn(_NONINCLUSIVE_, TRUE)
<Ctrl LeftBtn>			mLeftBtn(_COLUMN_, TRUE)
<Alt LeftBtn>			mLeftBtn(_LINE_, TRUE)
<Shift LeftBtn>			mLeftBtn(_LINE_, FALSE)		// just track cursor
<59585>					mLeftBtn(_NONINCLUSIVE_, TRUE)	//Ctrl+Alt
<59489>					mLeftBtn(_NONINCLUSIVE_, TRUE)	//Ctrl+Shift
<59617>					mLeftBtn(_NONINCLUSIVE_, TRUE)	//Ctrl+Shift+Alt
<59553>					mLeftBtn(_NONINCLUSIVE_, TRUE)	//Shift+Alt

<HELP_SCREEN_KEY>		QuickHelp(Mouse)

