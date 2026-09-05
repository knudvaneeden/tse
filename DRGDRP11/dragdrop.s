// DRAGDROP.S ù Mouse selection and drag-drop macro.
// 04/03/97 ù Christopher Antos, chrisant@microsoft.com
//
// v1.1, works on TSE 2.5 or TSE 2.6
//
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
#ifdef WIN32
constant _ALT_KEY = 0x03, _CTRL_KEY = 0x0c, _SHIFT_KEY = 0x10
constant _ALT=0x0400, _CTRL=0x0200, _SHIFT=0x0100, _ACS=0x0700
#else
constant _ALT_KEY = _ALT_KEY_, _CTRL_KEY = _CTRL_KEY_, _SHIFT_KEY = _LEFT_SHIFT_KEY_|_RIGHT_SHIFT_KEY_
constant _ALT=0x80, _CTRL=0x40, _SHIFT=0x20, _ACS=0xe0
#endif
constant _ACS_KEY = _ALT_KEY|_CTRL_KEY|_SHIFT_KEY



// Variables --------------------------------------------------------------

integer mouseNumClicks = 0



// Help -------------------------------------------------------------------

helpdef Mouse
	title = "Mouse Reference"
	x = 10

"            DRAGDROP  v1.1"
""
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
"Alt <               Previous file"
"Alt >               Next file"
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
	PutHelpLine(iif(key&_CTRL_KEY, " {[}COPY{]}", " {[}MOVE{]}"))
	PutHelpLine(iif(key&_ALT_KEY, " {[}OVER{]}", "       "))
end


integer proc mTrackMouseCursor2()
	integer mousekeypressed = Query(MouseKey)
	//integer lastmousekey = Query(MouseKey)
	integer keyflags = GetKeyFlags()
	integer lastkeyflags = GetKeyFlags()
	integer fDelay = FALSE
	integer fUpdate
	integer fFeedback = TRUE
	integer ticks = GetClockTicks()
	integer fRet = FALSE
	integer xofs
	integer fPop = FALSE
	integer _ofs

	loop
		fUpdate = FALSE
		if fFeedback
			fFeedback = FALSE
			PutDragFeedback(keyflags)
		endif
		MouseStatus()
		keyflags = GetKeyFlags()
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
		#ifdef WIN32
		if (Query(MouseKey)&~_ACS) == <LeftRightBtn>
		#else
		if (Query(MouseKey)&~_ACS) == <59395>
		#endif
			// both mouse buttons unmarks block
			UnMarkBlock()
			goto byebye
		endif
		if (keyflags&_ACS_KEY) <> (lastkeyflags&_ACS_KEY)
			fFeedback = TRUE
			fUpdate = TRUE
		endif
		if (Query(MouseKey)&~_ACS) <> (mousekeypressed&~_ACS)
			// if another mouse key is pressed/released, bail
			break
		endif
		lastkeyflags = keyflags
		//lastmousekey = Query(MouseKey)
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
			//PutNCharAttr(iif(keyflags&_CTRL_KEY, "[+]", "[ ]"), 3)
			_ofs = iif(Query(InsertLineBlocksAbove), 0, 1)
			if Query(MouseX) < Query(ScreenCols)-8
				PopWinOpen(Query(MouseX)+_ofs, Query(MouseY),
						Query(MouseX)+7+_ofs, Query(MouseY),
						1, iif(keyflags&_CTRL_KEY, " copy", " move"),
						COLOR_FEEDBACK)
			else
				PopWinOpen(Query(MouseX)-8-_ofs, Query(MouseY),
						Query(MouseX)-_ofs-1, Query(MouseY),
						1, iif(keyflags&_CTRL_KEY, "copy ", "move "),
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
	integer keyflags

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
						keyflags = GetKeyFlags()
						ctrl = keyflags & _CTRL_KEY
						alt = keyflags & _ALT_KEY
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
proc mLeftBtn(integer markingstyle, integer fExtend)
	integer event

	if markingstyle == 0
		markingstyle = iif(isBlockMarked(), isBlockMarked(), _NON_INCLUSIVE_)
	endif

	case MouseHotSpot()
		when _MOUSE_MARKING_
			if fExtend
				if not isBlockMarked() or not isBlockInCurrFile()
					Mark(markingstyle)
				endif
				Set(Marking, ON)
				mTrackMouseCursor()
				Mark(markingstyle)
			endif

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
			else//if not fExtend
				mMouseDrag(markingstyle)
			endif
		otherwise
			mouseNumClicks = 0
			ChainCmd()
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
//<59586>	<CtrlAlt RightBtn>
//<59490>	<CtrlShift RightBtn>
//<59618>	<CtrlShiftAlt RightBtn>
//<59554>	<ShiftAlt RightBtn>

<LeftBtn>				mLeftBtn(_NONINCLUSIVE_, FALSE)
<Ctrl LeftBtn>			mLeftBtn(_COLUMN_, FALSE)
<Alt LeftBtn>			mLeftBtn(_LINE_, FALSE)
<Shift LeftBtn>			mLeftBtn(0, TRUE)				// extend selection
#ifdef WIN32
<CtrlAlt LeftBtn>		mLeftBtn(_NONINCLUSIVE_, FALSE)	//Ctrl+Alt
<CtrlShift LeftBtn>		mLeftBtn(_NONINCLUSIVE_, FALSE)	//Ctrl+Shift
<CtrlAltShift LeftBtn>	mLeftBtn(_NONINCLUSIVE_, FALSE)	//Ctrl+Shift+Alt
<AltShift LeftBtn>		mLeftBtn(_NONINCLUSIVE_, FALSE)	//Shift+Alt
#else
<59585>					mLeftBtn(_NONINCLUSIVE_, FALSE)	//Ctrl+Alt
<59489>					mLeftBtn(_NONINCLUSIVE_, FALSE)	//Ctrl+Shift
<59617>					mLeftBtn(_NONINCLUSIVE_, FALSE)	//Ctrl+Shift+Alt
<59553>					mLeftBtn(_NONINCLUSIVE_, FALSE)	//Shift+Alt
#endif

#if HELP_SCREEN_KEY
<HELP_SCREEN_KEY>		QuickHelp(Mouse)
#endif

