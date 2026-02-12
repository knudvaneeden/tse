//	BULLET.S
//	Bulleted list support for wordwrap macros.  Also for Outlining.
//
//	BULLET is designed as a wrapper for you current wordwrap macro.
//	If you use WrapPara(), instead use ExecMacro("bullet -p").
//	If you use WrapLine(), instead use ExecMacro("bullet -l").
//	If you use ExecMacro("foo -x"), instead use ExecMacro("bullet foo -x").
//
//	Keys:
//	BULLET binds <Ctrl B> to bring up a Bullet Menu.  Select the bullet you
//	want to use and bingo!
//
//	Happy bulleting!
//	Chris Antos, chrisant@microsoft.com

/*
	//$ todo:
    ש Configurable indent styles: first indent I., second A., third 1), etc.
    ש Use DLG100 for styles dialog, and for options dialog:

    	I II ...    x.      ()
    	A B ...     x)      []
    	1 2 ...     (x)     <>
    	a b ...     (x.)    {}
    	i ii ...

    	[Indent]

*/


#include ["ini.si"]


#define DEBUG 1


#define BULLET_MENU 1		// BULLET_MENU: 1 = bind <Ctrl B> to bullet menu, 0 = don't
#define BULLET_CRETURN 1	// BULLET_CRETURN: 1 = bind <Enter> to auto-bullet procedure, 0 = don't
#define BULLET_INDENT 1		// BULLET_INDENT: 1 = bind <Tab>/<Shift Tab> to indent procedure, 0 = don't


forward integer proc GetMode()
forward proc DoBullet(string bullet)
forward proc DoOutline(integer mode)


constant modeNone = 0					// not bullet/outline
constant modeDontKnow = 1				// don't know
constant modeBullet = 2					// bulleting
constant modeDigits = 3					// digits (1, 2, 3, etc)
constant modeRoman = 4					// Roman numerals (i, ii, iii, etc)
constant modeUpRoman = 5				// Roman numerals (I, II, III, etc)
constant modeAlpha = 6					// letters (a, b, c, etc)
constant modeUpAlpha = 7				// letters (A, B, C, etc)

string FirstDigits[] = "1"
string FirstAlpha[] = "a"
string FirstRoman[] = "i"


integer fBullet = FALSE					// Bullet characters found.

string cmdline[255]

// NOTE:  the "-" ***MUST*** come at the end (or lFind will get confused)
string bullets[] = "‏תשנû+*o-"		// bullet characters

// regular expression to search for outlining
string outline[] = "[([{<]?{[0-9]#}|{[IVX]#}|{[ivx]#}|{[A-Za-z]}[.]|[.)\]}>]"

string prefix[3] = ""
string suffix[3] = "."
integer ai, pes
integer _cline							// current line -- avoid calculating hanging indent while on that line.

constant _Tab = 0
string section[] = "Bullet"				// ini file section name
integer g_nBullet1stIndent = 1			// 0=tab, <0=relative column position, >0=spaces
integer g_nOutline1stIndent = 1			// 0=tab, <0=relative column position, >0=spaces



#ifdef DEBUG
proc Assert(integer f, string s)
	if not f
		Message(s)
		UpdateDisplay()
		GetKey()
	endif
end
#endif

integer proc RomanVal(string s)
	case Upper(s[1])
		when "I"	return(1)
		when "V"	return(5)
		when "X"	return(10)
	endcase
	return(0)
end


integer proc RomanToInt(string s)
	integer n = 0, tmp = 0, i, j

	for i = 1 to Length(s)
		tmp = tmp + RomanVal(s[i])
		if i < Length(s)
			j = RomanVal(s[i]) - RomanVal(s[i+1])
			if j < 0
				tmp = 0 - tmp
			elseif j > 0
				n = n + tmp
				tmp = 0
			endif
		endif
	endfor
	return (n+tmp)
end


string proc IntToRoman(integer n)
	integer i = 1
	string s[20] = "", ch[1]

	while n <> 0
		if Abs(n) > 7
			ch = "x"
			n = iif(n>0, n-10, n+10)
		elseif Abs(n) > 3
			ch = "v"
			n = iif(n>0, n-5, n+5)
		else
			ch = "i"
			n = iif(n>0, n-1, n+1)
		endif

		s = InsStr(ch, s, i)
		if n > 0
			i = i + 1
		endif
	endwhile
	return (s)
end


proc Save()
	// save settings
	SaveIniSettings()
end


string Valid[32] = ChrSet("0-9A-Za-z")
integer ext_n = 0, ext_nEnd = 0
string proc Extract(string s)
	integer n, nEnd = 0

	// set n == index to "number"
	for n = 1 to Length(s)
		if GetBit(Valid, Asc(s[n]))
			nEnd = n
			while GetBit(Valid, Asc(s[nEnd])) and nEnd <= Length(s)
				nEnd = nEnd + 1
			endwhile
			break
		endif
	endfor

	ext_n = n
	ext_nEnd = nEnd
	// return "number" part of string
	return(s[n:nEnd-n])
end


// Increment
// increments s using given mode, returns new string.
string proc Increment(string s, integer mode)
	string new[20]

	#ifdef DEBUG
	if mode <= modeDontKnow
		Assert(FALSE, 'Oops.  "'+s+'"')
		return(s)
	endif
	#endif

	if mode == modeBullet
		// no incrementing for bullets
		return(s)
	endif

	// get "number" part
	new = Extract(s)

	#ifdef DEBUG
	if Length(new) == 0
		Assert(FALSE, "Increment:  Oops, no number part.")
		return("")
	endif
	#endif

	// get "next" string
	case mode
		when modeDigits
			new = Str(Val(new)+1)
		when modeUpAlpha, modeAlpha
			if Upper(new[1]) < "Z"
				new = Chr(Asc(new[1])+1)
			endif
		when modeUpRoman, modeRoman
			new = IntToRoman(RomanToInt(new)+1)
	endcase
	if mode in modeUpRoman, modeUpAlpha
		new = Upper(new)
	endif

	// replace old "number" with new
	new = InsStr(new, DelStr(s, ext_n, ext_nEnd-ext_n), ext_n)

	// not perfect tabbing, but good enough?
	if Length(new) > Length(s) and new[Length(new)] == " " and
			new[Length(new)-1] == " "
		// if excess spaces will screw up alignment, remove one space
		new = new[1:Length(new)-1]
	elseif Length(new) < Length(s)
		new = Format(new:-Length(s):" ")
	endif

	return (new)
end


integer proc isBulletLine(integer fEndOk)
	integer modeRet = modeNone
	string s[3] = iif(fEndOk, "|$}", "}")

	PushPosition()
	//fRet = lFind("^[\t ]@\c{"+outline+"}|{["+bullets+"][\t ]|$}", "cgx")
	if lFind("^[\t ]@{"+outline+"[\t ]"+s, "cgx")
		modeRet = modeDontKnow
	elseif lFind("^[\t ]@{["+bullets+"][\t ]"+s, "cgx")
    	modeRet = modeBullet
    endif
	PopPosition()
	return (modeRet)
	/*
	return (PosFirstNonWhite() and
			Pos(Chr(CurrChar(PosFirstNonWhite())), bullets) and
			(CurrChar(PosFirstNonWhite()+1) == _AT_EOL_ or
			Pos(Chr(CurrChar(PosFirstNonWhite()+1)), " "+Chr(9))))
	*/
end


integer proc isTabAtBulletBeg()
	integer fRet = FALSE
	integer nPos = CurrPos()

	PushPosition()
	//fRet = lFind("^[\t ]@\c{"+outline+"}|{["+bullets+"][\t ]|$}", "cgx")
	if (lFind("^[\t ]@{"+outline+"}\c", "cgx") or
			lFind("^[\t ]@{["+bullets+"]}\c", "cgx")) and
			nPos == CurrPos()
		fRet = TRUE
    endif
	PopPosition()
	return (fRet)
end


integer proc ColFirstNonWhite()
	integer nCol

	PushPosition()
	GotoPos(PosFirstNonWhite())
	nCol = CurrCol()
	PopPosition()
	return (nCol)
end


// FirstIndent
// performs first-line indent action.
// 0 aligns to next tab stop.
// >0 inserts specific number of spaces.
// <0 relative column to bullet.
proc FirstIndent(integer n)
	if n == 0
		// align to next tab stop, using current TabType
		TabRight()
	elseif n > 0
		// insert specific number of spaces
		InsertText(Format("":n:" "), _INSERT_)
	else
		// column position relative to bullet character
		InsertText(Format("":ColFirstNonWhite() + (-n) - CurrCol():" "),
				_INSERT_)
	endif
end


// GotoPosFirstNonBullet
// goto position of first non-bullet (and non-white) character on the line.
proc GotoPosFirstNonBullet()
    string ws[32]

	ws = Set(WordSet, ChrSet("~ \t"))
	GotoPos(PosFirstNonWhite())
	WordRight()
	if CurrChar() == _AT_EOL_ and not (CurrChar(CurrPos()-1) in 9, 32)
		FirstIndent(iif(isBulletLine(TRUE) == modeBullet,
				g_nBullet1stIndent, g_nOutline1stIndent))
	endif
	Set(WordSet, ws)
end


// PosFirstNonBullet
// return position of first non-bullet (and non-white) character on the
// line, or the end of the line.
integer proc PosFirstNonBullet()
    integer p

    PushPosition()
    GotoPosFirstNonBullet()
	p = CurrPos()
	PopPosition()
	return(p)
end


// PosLastBullet
// return position of last bullet (non-white) character on the line, or the
// end of the line.
integer proc PosLastBullet()
    string ws[32]
    integer p

    PushPosition()
	GotoPos(PosFirstNonWhite())
	ws = Set(WordSet, ChrSet("~ \t"))
	EndWord()
	Left()
	p = CurrPos()
	Set(WordSet, ws)
	PopPosition()
	return(p)
end


// _BegBullet
// places cursor on first line of bullet point.  column is undefined.
// returns TRUE if beginning of bullet point was found, FALSE otherwise.
integer proc _BegBullet()
	integer fRet = FALSE, nLeft = 0, rtw

	rtw = Set(RemoveTrailingWhite, OFF)
	PushPosition()
	while PosFirstNonWhite() and not isBulletLine(TRUE)
		nLeft = PosFirstNonWhite()
		if not Up()
			break
		endif
	endwhile
	if isBulletLine(TRUE) and (not nLeft or nLeft > PosFirstNonWhite())
		KillPosition()
		PushPosition()
		fRet = TRUE
	endif
	PopPosition()
	Set(RemoveTrailingWhite, rtw)
	return(fRet)
end


// public BegBullet
// places cursor on first line of bullet point.  column is undefined.
// returns success code in MacroCmdLine.  (TRUE = found, FALSE = not found).
public proc BegBullet()
	Set(MacroCmdLine, Str(_BegBullet()))
end


// public EndBullet
// places cursor on last line of bullet point.  column is undefined.
public proc EndBullet()
	integer fBullet = isBulletLine(TRUE), nColBullet = ColFirstNonWhite()
	integer rtw, fDown

	rtw = Set(RemoveTrailingWhite, OFF)
	if Down()
		Up()	// undo the Down()

		// find end of bullet point
		repeat
			fDown = Down()
		until not fDown or not PosFirstNonWhite() or isBulletLine(TRUE) or
				(fBullet and ColFirstNonWhite() <= nColBullet)
		if fDown
			Up()
		endif
	endif
	Set(RemoveTrailingWhite, rtw)
end


// PrevBullet
// find beginning of previous bullet, skipping subpoints (ie, points
// with a greater indent than the point we started from).
// returns TRUE if successful.
integer proc PrevBullet(integer mode)
	integer fRet = FALSE, rtw
	integer nLeft = PosFirstNonWhite()

	#ifdef DEBUG
	if not isBulletLine(TRUE)
		Assert(FALSE, "PrevBullet:  Only call me from first line of a bullet point!")
		return(FALSE)
	endif
	#endif

	rtw = Set(RemoveTrailingWhite, OFF)
	PushPosition()
	while Up() and (PosFirstNonWhite() == 0 or PosFirstNonWhite() >= nLeft)
		if PosFirstNonWhite() == nLeft
			if isBulletLine(TRUE) and
					(mode <= modeDontKnow or GetMode() == mode)
				fRet = TRUE
				KillPosition()
				PushPosition()
			endif
			break
		endif
	endwhile
	PopPosition()
	Set(RemoveTrailingWhite, rtw)
	return(fRet)
end


// NextBullet
// find beginning of next bullet, skipping subpoints (ie, points with a
// greater indent than the point we started from).
// returns TRUE if successful.
integer proc NextBullet(integer mode)
	integer nLeft, fRet = FALSE, fDown, rtw

	rtw = Set(RemoveTrailingWhite, OFF)
	PushPosition()
	if _BegBullet()
		nLeft = PosFirstNonWhite()

		skipsubs:
		EndBullet()
		repeat
			fDown = Down()
		until not fDown or PosFirstNonWhite()
		if fDown and isBulletLine(TRUE) and PosFirstNonWhite() >= nLeft
			if PosFirstNonWhite() > nLeft
				goto skipsubs
			endif
			if PosFirstNonWhite() == nLeft and
					(mode <= modeDontKnow or GetMode() == mode)
				fRet = TRUE
				KillPosition()
				PushPosition()
			endif
		endif
	endif
	PopPosition()
	Set(RemoveTrailingWhite, rtw)
	return(fRet)
end


// GetOutline
// returns string used as bullet for current bullet paragraph
string proc GetOutline()
	string s[20] = ""
	integer rtw

	rtw = Set(RemoveTrailingWhite, OFF)
	PushPosition()
	if _BegBullet()
		PushBlock()
		GotoPos(PosFirstNonWhite())
		MarkChar()
		GotoPosFirstNonBullet()
		MarkChar()
		s = GetMarkedText()
		PopBlock()
	endif
	PopPosition()
	Set(RemoveTrailingWhite, rtw)
	return (s)
end


// GetMode
// returns mode of current bullet paragraph
// MUST BE CALLED FROM FIRST LINE IN BULLET PARAGRAPH
integer proc GetMode()
	integer mode
	integer i, rtw
	string prev[20] = "", curr[20]

	mode = isBulletLine(TRUE)
	#ifdef DEBUG
	if mode == modeNone
		Assert(FALSE, "GetMode:  Oops, not on a bulletline.  Use _BegBullet() first!")
		return (mode)
	endif
	#endif

	if mode == modeDontKnow
		curr = Extract(GetOutline())

		#ifdef DEBUG
		if Length(curr) == 0
			Assert(FALSE, "GetMode:  Hey, no number part!")
			return (modeNone)
		endif
		#endif

		// figure out the mode
		if curr[1] >= "0" and curr[1] <= "9"
			// Digits
			mode = modeDigits
		else
			rtw = Set(RemoveTrailingWhite, OFF)
			PushPosition()
			// figure out Alpha or Roman
			if PrevBullet(modeDontKnow)
				prev = Extract(GetOutline())
			endif
			if Length(prev)
				if Upper(curr) == Upper(FirstAlpha) or
						Trim(Increment(prev, modeUpAlpha)) == Upper(curr)
					mode = modeAlpha
				elseif Upper(curr) == Upper(FirstRoman) or
						Trim(Increment(prev, modeUpRoman)) == Upper(curr)
					mode = modeRoman
				else
					goto guess
				endif
			else
				guess:
				// no prev, take best guess
				if Length(curr) == 1
					if not Pos(Upper(curr[1]), "IVX")
						mode = modeAlpha
					else
						// well, it's a toss up.  either way, every so often
						// it'll be wrong.
						mode = modeRoman
					endif
				else
					mode = modeRoman
				endif
			endif

			// figure out case
			if mode in modeAlpha, modeRoman
				for i = 1 to Length(curr)
					if curr[i] >= "A" and curr[i] <= "Z"
						// make it the upper case version
						mode = mode + 1
						break
					endif
				endfor
			endif

			PopPosition()
			Set(RemoveTrailingWhite, rtw)
		endif
	endif

	return (mode)
end


// GetCurrMode
// returns mode of current outline paragraph, or modeNone.
integer proc GetCurrMode()
	integer rtw, mode = modeNone

	rtw = Set(RemoveTrailingWhite, OFF)
	PushPosition()
	if _BegBullet()
		mode = GetMode()
	endif
	PopPosition()
	Set(RemoveTrailingWhite, rtw)
	return(mode)
end


// FindBullets
// find extents of bullet point and insert blank lines as
// paragraph delimiters.
proc FindBullets()
	//integer nCol = 0
	//string text[128]

	fBullet = FALSE
	DelBookMark("1")
	DelBookMark("2")
	// try to delimit bullet point blank lines
	PushPosition()
	if _BegBullet()
		fBullet = TRUE
		ai = Set(AutoIndent, _STICKY_)
		pes = Set(ParaEndStyle, 0)

		// insert blank line above this bullet point
		InsertLine()
		PlaceMark("1")
		Down()
	endif

	// find bottom of bullet point/paragraph and insert blank line
	EndBullet()
	AddLine()
	PlaceMark("2")
	PopPosition()
	_cline = CurrLine()
end


// DoWrap
// execute the wrap function.
proc DoWrap(string s, integer fInternal)
	case Lower(Trim(s))
		when "-p"
			WrapPara()
		when "-l"
			if fInternal
				WrapPara()
			else
				WrapLine()
			endif
		otherwise
			ExecMacro(s)
	endcase
end


// RestoreBullets
// remove blank link paragraph delimiters for bullet point, and
// autoindent second line (hanging indent -- handles hard or soft tabs)
proc RestoreBullets()
    integer nCol
    string text[128]

    if fBullet
		// hanging indent for bulleted lists
		PushPosition()
		// find top of bullet point
		GotoMark("1")
		Down()
		GotoPosFirstNonBullet()
		nCol = CurrCol()
		text = GetText(1, PosFirstNonWhite() - 1)
		Down()
		if _cline <> CurrLine() and PosFirstNonWhite() and
				not isBulletLine(TRUE)
			GotoPos(PosFirstNonWhite())
			if CurrCol() <> nCol
				if CurrCol() > 1
					BegLine()
					PushBlock()
					UnMarkBlock()
					MarkChar()
					GotoPos(PosFirstNonWhite())
					MarkChar()
					KillBlock()
					PopBlock()
				endif
				BegLine()
				InsertText(text, _INSERT_)
				GotoPos(PosFirstNonWhite())
				while nCol - CurrCol() > 0
					if Query(TabType) <> _HARD_ or
							Query(TabWidth) > nCol - CurrCol()
						InsertText(" ", _INSERT_)
					else
						InsertText(Chr(9), _INSERT_)
					endif
				endwhile
				GotoMark("1")
				Down()
				GotoPosFirstNonBullet()
				PushBlock()
				UnMarkBlock()
				PushPosition()
				MarkChar()
				EndBullet()
				EndLine()
				MarkChar()
				PopPosition()
				DoWrap(cmdline, TRUE)
				PopBlock()
			endif
		endif
		PopPosition()

		Set(AutoIndent, ai)
		Set(ParaEndStyle, pes)
		fBullet = FALSE
	endif

	// remove blank line delimiters
	PushPosition()
	if GotoMark("1")
		DelBookMark("1")
		KillLine()
	endif
	if GotoMark("2")
		DelBookMark("2")
		KillLine()
	endif
	PopPosition()
end


proc Wrap(string s)
	integer rtw

	cmdline = s		// in case RestoreBullets decides to wrap again!
	rtw = Set(RemoveTrailingWhite, OFF)
	FindBullets()
	DoWrap(s, FALSE)
	RestoreBullets()
	Set(RemoveTrailingWhite, rtw)
end


proc MaybeWrap()
	if Query(WordWrap) >= ON
		// wrap bullet/outline paragraph using TSE WrapPara() command.
		// if you use a specialized wordwrap macro, change the string
		// to call your macro.
		PushPosition()
		Wrap("-p")
		PopPosition()
	endif
end


proc DoBullet(string bullet)
	integer fReplace = FALSE, fFix = FALSE
	integer nPos = CurrPos(), odc, cline

	odc = SetHookState(OFF, _ON_DELCHAR_)
	PushPosition()
	cline = CurrLine()
	if _BegBullet()
		fReplace = TRUE
		GotoPosFirstNonBullet()
		if CurrLine() == cline and nPos >= PosFirstNonWhite()
			fFix = TRUE
			if nPos < CurrPos()
				nPos = PosFirstNonWhite()
			else
				nPos = nPos - (CurrPos()-PosFirstNonWhite())
			endif
		endif
		BackSpace(CurrPos()-PosFirstNonWhite())
	endif
	InsertText(bullet, _INSERT_)
	FirstIndent(g_nBullet1stIndent)
	if fFix
		nPos = nPos + (CurrPos()-PosFirstNonWhite())
	endif
	MaybeWrap()
	if fReplace
		PopPosition()
		GotoPos(nPos)
	else
		KillPosition()
	endif
	SetHookState(odc, _ON_DELCHAR_)
end


// Renumber
// renumbers current and following bullet points using new mode.
// renumbers points of old mode; starts with value of previous point of old
// mode, or with current point if no previous is found.
integer fRenumbering = FALSE
proc Renumber(integer modeNew, integer modeOld)
	integer rtw, fFix = FALSE

	fRenumbering = TRUE
	rtw = Set(RemoveTrailingWhite, OFF)
	if isBulletLine(TRUE) and CurrPos() >= PosFirstNonWhite() and
			CurrPos() <= PosFirstNonBullet()
		GotoPosFirstNonBullet()
		Right()
		fFix = TRUE
	endif
	PushPosition()
	if _BegBullet()
		if modeNew <= modeDontKnow
			// if no mode given, use mode of previous point,
			// or current point if no previous point is found
			PushPosition()
			PrevBullet(modeNew)
			modeNew = GetMode()
			PopPosition()
		endif
		if modeOld <= modeDontKnow
			// if no mode given, use mode of current point
			modeOld = GetMode()
		endif
		if modeNew > modeBullet
			// if a numbered outline mode, change numbers
			/*
			while NextBullet(modeOld)
				DoOutline(modeNew)
			endwhile
			*/
			repeat
				DoOutline(modeNew)
			until not NextBullet(modeOld)
		endif
	endif
	PopPosition()
	if fFix
		Left()
	endif
	Set(RemoveTrailingWhite, rtw)
	fRenumbering = FALSE
end


// DoOutline
// inserts outline number in specified mode.  replaces existing number
// with new mode if a number already exists.  may renumber points.
#ifdef DEBUG
integer depth = 0
#endif
proc DoOutline(integer mode)
	integer fReplace = FALSE, fFix = FALSE
	integer nPos = CurrPos(), odc, ins, cline, rtw
	string s[20] = ""
	integer modeCurr = modeNone, modeRenumber
	integer fRenumber = FALSE, fNoIndent = FALSE

	#ifdef DEBUG
	// protect against deep recursion
	depth = depth + 1
	Assert(depth <= 2,
			Format("DoOutline:  Dive, dive!  Depth is ", depth, " mile",
			iif(depth == 1, "", "s"), " captain."))
	#endif

	rtw = Set(RemoveTrailingWhite, OFF)

	modeCurr = iif(fRenumbering, mode, GetCurrMode())
	modeRenumber = modeCurr

	if modeCurr == mode
		PushPosition()
		//if PrevBullet(iif(fRenumbering, modeNone, mode))
		if PrevBullet(mode)
			// if same as mode for previous outline paragraph, use
			// Increment of previous point.
			s = Increment(GetOutline(), mode)
			fNoIndent = TRUE
		else
			// force numbering at one
			modeCurr = modeNone
		endif
		PopPosition()
	endif
	if modeCurr <> mode
		// if changing mode, start numbering at one
		case mode
			when modeDigits
				s = FirstDigits
			when modeUpAlpha, modeAlpha
				s = FirstAlpha
			when modeUpRoman, modeRoman
				s = FirstRoman
		endcase
		s = prefix + s + suffix

		// if starting at one, renumber following points of same indent
		// and mode
		if Length(s) > 0 and not fRenumbering
			fRenumber = TRUE
		endif
	endif
	if mode in modeUpAlpha, modeUpRoman
		s = Upper(s)
	endif

	// remove old bullet, insert new outline bullet
	odc = SetHookState(OFF, _ON_DELCHAR_)
	ins = Set(Insert, ON)
	PushPosition()
	cline = CurrLine()
	if _BegBullet()
		fReplace = TRUE
		GotoPosFirstNonBullet()
		if CurrLine() == cline and nPos >= PosFirstNonWhite()
			fFix = TRUE
			if nPos < CurrPos()
				nPos = PosFirstNonWhite()
			else
				nPos = nPos - (CurrPos()-PosFirstNonWhite())
			endif
		endif
		BackSpace(CurrPos()-PosFirstNonWhite())
	endif
	InsertText(s)
	if not fNoIndent
		FirstIndent(g_nOutline1stIndent)
	endif
	if fFix
		nPos = nPos + (CurrPos()-PosFirstNonWhite())
	endif
	MaybeWrap()
	if fReplace
		PopPosition()
		GotoPos(nPos)
	else
		KillPosition()
	endif
	Set(Insert, ins)
	SetHookState(odc, _ON_DELCHAR_)

	// renumber
	if fRenumber and not fRenumbering
		Renumber(mode, modeRenumber)
	endif
	Set(RemoveTrailingWhite, rtw)

	#ifdef DEBUG
	depth = depth - 1
	#endif
end


proc SetPrefix(string pre, string post)
	integer rtw

	rtw = Set(RemoveTrailingWhite, OFF)
	PushPosition()
	prefix = pre
	suffix = post
	if _BegBullet()
		DoOutline(GetMode())
	endif
	PopPosition()
	Set(RemoveTrailingWhite, rtw)
end


menu PrefixMenu()
title = "Prefix"
history
	"<None>", SetPrefix("", suffix)
	"(", SetPrefix("(", suffix)
	"[", SetPrefix("[", suffix)
	"{", SetPrefix("{", suffix)
	"<", SetPrefix("<", suffix)
end


menu SuffixMenu()
title = "Suffix"
history
	".", SetPrefix(prefix, ".")
	"",, Divide
	")", SetPrefix(prefix, ")")
	"]", SetPrefix(prefix, "]")
	"}", SetPrefix(prefix, "}")
	">", SetPrefix(prefix, ">")
	"",, Divide
	".)", SetPrefix(prefix, ".)")
	".]", SetPrefix(prefix, ".]")
	".}", SetPrefix(prefix, ".}")
	".>", SetPrefix(prefix, ".>")
end


menu Options()
title = "Bullet Options"
history
	"Outline Options",, Divide
	"",, Divide
	"&Save Settings", Save(),, "Saves your settings.  Settings are automatically saved when you exit."
end


menu BulletMenu()
	title = "Bullets"
	history = 3
	command = DoBullet(MenuStr(BulletMenu, MenuOption()))

    "‏"
    "ת"
    "ש"
    ""
    ""
    "נ"
    "û"
    "-"
    "+"
    "*"
    "o"
    "Outline",, Divide
    "&I..IV",	DoOutline(modeUpRoman),, "Outlining using uppercase Roman Numerals."
    "&ABC",		DoOutline(modeUpAlpha),, "Outlining using uppercase letters."
    "&123",		DoOutline(modeDigits),, "Outlining using numbers."
    "a&bc",		DoOutline(modeAlpha),, "Outlining using lowercase letters."
    "i..i&v",	DoOutline(modeRoman),, "Outlining using lowercase Roman Numerals."
    "",, Divide
    "&Prefix  ",	PrefixMenu(),, "Select prefix for number."
    "&Suffix  ",	SuffixMenu(),, "Select suffix for number."
    "&Renumber",	Renumber(modeDontKnow, modeDontKnow),, "Renumber bullet points."
    "",, Divide
    "&Options  ",	Options(),, "Change settings."
end


proc CleanUp()
	Save()
end


proc WhenLoaded()
	cmdline = Query(MacroCmdLine)

	g_nBullet1stIndent = GetIniInt(section, "Bullet1stIndent", 1)
	g_nOutline1stIndent = GetIniInt(section, "Outline1stIndent", -6)

	//$ hack: make stupid compiler shut up
	SetIniInt(section, "Bullet1stIndent", 1)
	SetIniInt(section, "Outline1stIndent", -6)

	Hook(_ON_ABANDON_EDITOR_, CleanUp)
	Set(MacroCmdLine, cmdline)
end


proc WhenPurged()
	CleanUp()
end


proc Main()
	cmdline = Query(MacroCmdLine)
	case Lower(Trim(cmdline))
		when "-m"
			BulletMenu()
			return()
		when "-o"
			Options()
			return()
		when ""
			return()
	endcase

	Wrap(cmdline)
end


#if BULLET_MENU
<Ctrl B>		BulletMenu()
#endif


#if BULLET_CRETURN
menu BlankOrBullet()
	title = "Point is empty, do you want to:"
	history

	"&Clear the line"
	"Keep the &point"
end


integer proc BulletCReturn()
	integer fBullet = FALSE, fBlank = FALSE
	string bullet[128]
	integer nCol, mode = modeNone, rtw
	integer key = Query(Key)

	if Query(WordWrap) > 0
		// auto bullets
		rtw = Set(RemoveTrailingWhite, OFF)
		if isBulletLine(TRUE) and CurrPos() >= PosFirstNonWhite() and
				CurrPos() < PosFirstNonBullet()
			// don't allow use to insert return in middle of bullet!
			GotoPosFirstNonBullet()
		endif
		PushPosition()
		if _BegBullet()
			mode = GetMode()
			fBullet = TRUE
			GotoPos(PosFirstNonWhite())
			nCol = CurrCol()
			GotoPosFirstNonBullet()
			bullet = GetText(PosFirstNonWhite(), CurrPos()-PosFirstNonWhite())
			if CurrChar() == _AT_EOL_
				case BlankOrBullet()
					when 0
						PopPosition()
						Set(RemoveTrailingWhite, rtw)
						return(FALSE)
					when 1
						fBlank = TRUE
					when 2
						goto incbullet
				endcase
			else
				incbullet:
				bullet = Increment(bullet, mode)
			endif
			// otherwise ChainCmd() is unhappy
			Set(Key, key)
		endif
		PopPosition()
		Set(RemoveTrailingWhite, rtw)
	endif

	ChainCmd()

	if fBullet
		rtw = Set(RemoveTrailingWhite, OFF)
		if fBlank
			PushPosition()
			Up()
			BegLine()
			KillToEol()
			PopPosition()
		endif
		GotoPos(PosFirstNonWhite())
		SplitLine()
		KillLine()
		InsertLine()
		GotoColumn(nCol)
		JoinLine()
		if mode == modeBullet
			DoBullet(Trim(bullet))
		else
			// insert this, or else DoOutline will renumber incorrectly
			InsertText(Trim(bullet)+" ", _INSERT_)
			DoOutline(mode)
			Renumber(mode, mode)
		endif
		Set(RemoveTrailingWhite, rtw)
		//return (InsertText(bullet, _INSERT_))
	endif

	return (TRUE)
end


<Enter>			BulletCReturn()
#endif


#if BULLET_INDENT
integer proc mShiftTabBlock(integer direction)
	integer goal_line = CurrLine(),
			save_marking = Query(Marking),
			tt = Query(TabType),
			save_insert = Set(Insert, TRUE),
			i, hk

	if tt == _VARIABLE_ or tt == _SMART_
		Set(TabType, _SOFT_)
	endif

	// assume cursor in block
	PushPosition()
	hk = SetHookState(OFF, _ON_DELCHAR_)
	if direction > 0
		goal_line = Query(BlockEndLine)
		GotoBlockBegin()
		repeat
			BegLine()
			TabRight()
			Left()
		until not RollDown()
				or CurrLine() > goal_line
	else
		goal_line = Query(BlockBegLine)
		GotoBlockEnd()
		repeat
			BegLine()
			i = 0
			repeat
				Right()
				i = i+1
			until DistanceToTab(TRUE) == Query(TabWidth)
			BackSpace(i)
		until not RollUp()
				or CurrLine() < goal_line
	endif
	SetHookState(hk, _ON_DELCHAR_)
	MaybeWrap()

	Set(Insert, save_insert)
	Set(TabType, tt)
	PopPosition()
	Set(Marking, save_marking)
	return (TRUE)
end


proc mTab(integer direction)
	integer rtw, nLine, fPos
	//integer mode						// auto-renumber [not tested]

	if DisplayMode() == _DISPLAY_HEX_ or isCursorInBlock()
		ChainCmd()
		return()
	endif

	if PosFirstNonWhite() and ((isBulletLine(TRUE) and
			not isBulletLine(FALSE) and CurrPos() == PosLastBullet()+1) or
			isTabAtBulletBeg())
		ChainCmd()
        return()
    endif

	rtw = Set(RemoveTrailingWhite, OFF)
	PushPosition()
	nLine = CurrLine()
	fPos = CurrPos() > PosFirstNonWhite()
	if _BegBullet() and (nLine == CurrLine() or fPos)
		if direction > 0 or PosFirstNonWhite() > 1
			PushBlock()
			UnMarkBlock()
			MarkLine()
			EndBullet()
			// mark whole bullet point
			MarkLine()
			PopPosition()
			// indent bullet point
			Right()
			mShiftTabBlock(direction * Query(TabWidth))
			Left()
			PopBlock()
			PushPosition()
			/*
			// auto-renumber [not tested]
			if PrevBullet(modeDontKnow)
				// make this point have same outline style as point above it,
				// and renumber following points.
				mode = GetMode()
				PopPosition()
				PushPosition()
				DoOutline(mode)
			endif
			*/
		endif
		PopPosition()
		Set(RemoveTrailingWhite, rtw)
		return()
	endif
	PopPosition()
	Set(RemoveTrailingWhite, rtw)

	ChainCmd()
end


<Tab>			mTab(1)
<Shift Tab>		mTab(-1)
#endif
