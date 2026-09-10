// TSE/32
// GREP.S ù Grep Function
// Christopher Antos

// Portable adaptation version 1.0.0.0.1 - 2026-09-10
// Adapted by OpenAI Codex (GPT-5)
// Support macros and help files are loaded from the GREP.MAC directory.

//$ todo: (chrisant) help
//$ todo: (chrisant) documentation

//$ todo: General Options dialog
		// - Context Window
		// - Default to current directory



// The excludespec can handle legal DOS wildcards, but may behave incorrectly
// when given badly formed wildcards such as "*foo*.*".  The excludespec can
// be a list of multiple wildcards or directory names (eg. "mac spell *.s
// *.ui").  It can also handle contructs like "mac\*.bin mac\*.mac"



//#define DEBUG 1

#define AUTO_HILITE 1			// AUTO_HILITE:	 hilite filename lines via TSE's _DISPLAY_FINDS_ mode
#define CONTEXT_WINDOW 1		// CONTEXT_WINDOW:	display context window when in finds list
#define CWBORDER 1				// CWBORDER:  display border around context window
#define VARIATION 2				// VARIATION:  0=Ask, 1=Menu, 2=Dialog



#ifndef WIN32
	// WIN32 has built-in .INI file functions
	#ifndef CONTEXT_WINDOW
		#define INI_NOINT 1
	#endif
	#include ["ini.si"]
#endif

#if VARIATION == 2
#include ["dialog.si"]
#include ["grepdlg.si"]
#include ["grepdlg.dlg"]
#endif



// Constants --------------------------------------------------------------

constant _FUNCTIONLIST		= 0x0001
constant _REFRESH			= 0x0002

string section[] = "Grep"
string GrepOptions[] = "Options"
string GrepExclude[] = "Exclude"
#ifdef CONTEXT_WINDOW
string GrepCtxWin[] = "ContextWindow"
#endif

string stDefExcl[] = "*.com *.exe *.dll *.bin *.mac *.ico *.bmp *.pif *.gif *.jpg *.mpg *.obj *.ilk *.pdb *.pch"

#ifdef AUTO_HILITE
// prefix must be "File: " to use _DISPLAY_FINDS_ to hilite filename lines
string prefix[] = "File: "
#else
string prefix[] = "ÄÄ "
#endif

string c_stLoaded[] = "    [LOADED]"



// Variables --------------------------------------------------------------

#ifdef CONTEXT_WINDOW
constant pctCtxWin = 30					// percentage of screen to use for context window
constant nIdleMS = 1					// idle milliseconds before update context window

integer g_fCtxWin = TRUE
integer g_nCtxLine = 0
integer cyCtxWin = 0
#endif


string g_expr[255]
string g_opts[10]
string g_files[255]
string g_excl[255]
string g_dir[255]

string g_stTitle[255]
string g_stMacroDir[255] = ""
integer g_cid
integer g_lineno
integer g_startlineno
integer g_fSearchingLoadedFiles

integer g_fFunctionList = FALSE
integer id_found = 0					// grep results buffer

integer hist_opts						// histories
integer hist_files
integer hist_excl
#if VARIATION
integer hist_dir
#endif

integer unique = 0						// used to generate unique filenames

integer g_fFilenamesOnly				// settings
integer g_fSubDirs
integer g_fSearchLoadedFiles
integer g_fVerbose
integer g_nContext

string g_stFunction[255] = ""



// DOS Compatibility ------------------------------------------------------

#ifndef WIN32
string dta[43] = ""


string proc SqueezePath(string s, integer len)
	// does not emulate TSE 2.6's SqueezePath command, but does something
	// similar.
	if Length(s) > len
		return("..."+DelStr(s, 1, Length(s)-len-3))
	endif
	return(s)
end


string proc FFName()
	return(Trim(SubStr(DecodeDTA(dta), 2, 13)))
end


integer proc FFAttribute()
    return(Asc(dta[22]))
end


integer proc FindFirstFile(string fn, integer flags)
	return(iif(SetDTA(dta) and FindFirst(fn, flags), 1, -1))
end


integer proc FindNextFile(integer handle, integer flags)
	return(FindNext())
end


proc FindFileClose(integer handle)
end


string proc QuotePath(string s)
	return(s)
end
#endif



// Helper Functions -------------------------------------------------------

integer proc IsSpecialFile(string s)
	return (Length(s) and Pos(s[1], "$[") and Pos(s[Length(s)], "$]"))
end


integer proc GrepFile(string fn)
	return (Length(fn) and Lower(fn[1:5]) == "$grep" and fn[Length(fn)] == "$")
end


string proc FilterOpts(string opts)
	string opts2[10] = ""
	integer i

	for i = 1 to Length(opts)
		if Pos(Lower(opts[i]), "iwx^$")
			opts2 = opts2 + opts[i]
		endif
	endfor
	return (opts2)
end


proc Context(integer n, integer fDown, integer id)
	integer i

	PushPosition()
	for i = 1 to n
		if not iif(fDown, Down(), Up())
			break
		endif
		if fDown
			AddLine(Format(CurrLine():6, '  ',
					GetText(1, CurrLineLen())), id)
		else
			InsertLine(Format(CurrLine():6, '  ',
					GetText(1, CurrLineLen())), id)
		endif
	endfor
	PopPosition()
end


proc UpdateHistoryStr(string s, integer id)
	if FindHistoryStr(s, id)
		DelHistoryStr(id, FindHistoryStr(s, id))
	endif
	AddHistoryStr(s, id)
end


#ifndef WIN32
string c_stTmpStr[] = "GREP:tmpstr"
#endif
proc XferSettings(integer fLoad)
	// when PersistentHistory is set, we don't have to persist the options
	// string, but doing so anyway provides seamless consistency if
	// PersistentHistory is ever toggled off.

	//$ todo: (chrisant) would be minor performance improvement to avoid
	// writing the profile values if they haven't changed; INI.MAC for
	// TSE/DOS automatically does, but the TSE32 APIs probably don't.

	#ifndef WIN32
	SetGlobalStr(c_stTmpStr, Query(MacroCmdLine))
	#endif

	if fLoad
		UpdateHistoryStr(GetProfileStr(section, GrepOptions, "vm"), hist_opts)
		UpdateHistoryStr(GetProfileStr(section, GrepExclude, stDefExcl), hist_excl)
		#ifdef CONTEXT_WINDOW
		g_fCtxWin = GetProfileInt(section, GrepCtxWin, TRUE)
		#endif
	else
		WriteProfileStr(section, GrepOptions, g_opts)
		WriteProfileStr(section, GrepExclude, g_excl)
		#ifdef CONTEXT_WINDOW
		WriteProfileInt(section, GrepCtxWin, g_fCtxWin)
		#endif
	endif

	#ifndef WIN32
	Set(MacroCmdLine, GetGlobalStr(c_stTmpStr))
	DelGlobalVar(c_stTmpStr)
	#endif
end


proc Save()
	AbandonFile(id_found)
	id_found = 0
end


proc mHelp(string topic)
	ExecMacro("gethelp -f"+QuotePath(g_stMacroDir+"grep.hlp")+" "+topic)
end


integer proc QuotedArg(string quote, var string s, var string arg)
	// is arg quoted with <quote>?
	if s[1:Length(quote)] <> quote
		return(FALSE)
	endif

	// remove beg-quote from temp
	s = DelStr(s, 1, Length(quote))
	if not Pos(quote, s)
		Warn("Argument missing end-quote.")
		return(FALSE)
	endif

	// get quoted arg
	arg = s[1:Pos(quote, s)-1]
	if s[Pos(quote, s)+Length(quote)] <> " "
		Warn("Quoted argument improperly formed.")
		return(FALSE)
	endif

	// remove arg, end-quote, and space from temp
	s = DelStr(s, 1, Length(arg)+Length(quote)+1)
	return(TRUE)
end


string proc StripCommas(string s)
	string sOut[255] = s

	while Pos(",", sOut)
		sOut[Pos(",", sOut)] = " "
	endwhile
	while Pos(";", sOut)
		sOut[Pos(";", sOut)] = " "
	endwhile

	return (sOut)
end


string proc Ellipsify(string s, integer len)
	if Length(s) > len
		return (SubStr(s, 1, len-3)+"...")
	endif
	return (s)
end



// Paragraph/Function Helpers ---------------------------------------------

integer proc GetFunctionStr(string ext, var string expr)
	integer i = 0

	// get search expression for functions
	expr = ""
	case ext
//		when ".c"
//			expr = "^_@[a-zA-Z][a-zA-Z0-9_* \t]@([~;]*$"

		when ".c",".cpp",".h",".hpp",".cxx",".hxx"
			//expr = "^_|~@[a-zA-Z:~][a-zA-Z0-9_* \t:~]@([~;]*$"
			// modified to catch functions with parens on next line
			//expr = "^_|~@[a-zA-Z:~][a-zA-Z0-9_* \t:~]@{([~;]*$}|{$}"

			//$ loose - modified by Howard Kapustein to catch more C++ stuff
			//expr = "^{extern[ \t]+\x22C\x22[ \t]+}?_|~@[a-zA-Z:][a-zA-Z0-9_+\-*/%^&|~!=<>,\[\] \t:~]@([~;]*$"

			//$ tight - chrisant
			expr = "^{[~ \t]*[ \t]*}?[a-zA-Z_~][a-zA-Z0-9_* \t~]@{::[a-zA-Z_~][a-zA-Z0-9_* \t~]@}?{[~=;]*([~;:]@}|{[~=;:]@}$"
			i = -1

		when ".s",".ui",".si"
			//expr = "^[ \t]*{menu}|{keydef}|{datadef}|{helpdef}|{{public #}?{{integer #}|{string #}}?proc} +[a-zA-Z_]"
			expr = "^[\t ]*{menu}|{keydef}|{datadef}|{{public[\t ]#}?{{integer}|{string}[\t ]#}?proc}[\t ]+\c[a-zA-Z_]"
			i = -1

		when ".asm",".inc"
			expr = "^{{proc}|{macro}[\t ]+\c[A_Za-z_0-9]#}|{\c[A-Za-z_0-9]#[\t ]+{proc}|{macro}}"
			i = -1

		when ".pas"
			expr = "{procedure}|{function}[\t ]+{[A-Za-z_0-9]#}"
			i = 3

		when ".prg",".spr",".mpr",".qpr",".fmt",".frg",".lbg",".ch"
			expr = "^{static[\t ]+}?{{procedure}|{function}}[\t ]+{[A-Za-z_0-9]#}"
			i = 5

		when ".bas"
			expr = "^{[\t ]@def fn}|{[\t ]@sub}[\t ]+{[A-Za-z_0-9]#}"
			i = 3

		when ".ini"
			expr = "\[.*\]"
			i = 0
	endcase

	return (i)
end


integer proc FindFunc(integer next)
	string opt[1], s[255] = ""
	integer fRet = FALSE

	PushPosition()
	GetFunctionStr(CurrExt(), s)
	if Length(s)
		if not next
			BegLine()
			opt = 'b'
		else
			EndLine()
			opt = ''
		endif
		fRet = lFind(s, "ix+" + opt)
	endif
	if fRet
		KillPosition()
	else
		PopPosition()
	endif
	return (fRet)
end


proc mBegFunc()
	integer row = CurrRow(), cline = CurrLine()
	integer pline

	FindFunc(FALSE)
	pline = CurrLine()
	FindFunc(TRUE)
	if cline <> CurrLine()
		GotoLine(pline)
	endif

	// hold screen still unless we went off screen
	row = row + CurrLine() - cline
	if row < 1 or row > Query(WindowRows)
		ScrollToRow(Query(WindowRows)/5)
	else
		ScrollToRow(row)
	endif
end


// GetFunctionName()
// returns name of function.  it does a decent job, but don't expect miracles!
string proc GetFunctionName()
	string expr[255] = ""
	string ws[32]
	integer i

	PushPosition()
	mBegFunc()
	i = GetFunctionStr(CurrExt(), expr)
	if Length(expr)
		if lFind(expr, "gxc")
			if i == -1
				// special methods for extracting function names
				case CurrExt()
					// C/C++ is darn complicated
					when ".c",".cpp",".h",".hpp",".cxx",".hxx"
						EndLine()
						ws = Set(WordSet, ChrSet("A-Za-z_0-9:"))
						// take the word before the last parenthesis, or the
						// last word on the line.
						lFind("(", "bc")
						WordLeft()
						expr = GetWord()
						Set(WordSet, ws)

					// cursor is placed at beginning of function name
					when ".s",".ui",".si",
							".asm",".inc"
						if lFind("[A-Za-z_0-9]#", "xc")
							expr = GetFoundText()
						endif
				endcase
			else
				expr = GetFoundText(i)
			endif
		else
			expr = ""
		endif
	endif
	PopPosition()

	return(expr)
end



// Context Window ---------------------------------------------------------

#ifdef CONTEXT_WINDOW

integer g_idSaveWindow = 0

#ifdef WIN32
proc RestoreWindow()
	integer cid
	integer x1, y1, cols, rows
	integer i, j, k, l
	string s[255], a[255]

	if not g_idSaveWindow
		return()
	endif

	cid = GotoBufferId(g_idSaveWindow)
	if cid
		BegFile()
		x1 = Val(GetToken(GetText(1, 255), " ", 1))
		y1 = Val(GetToken(GetText(1, 255), " ", 2))
		cols = Val(GetToken(GetText(1, 255), " ", 3))
		rows = Val(GetToken(GetText(1, 255), " ", 4))
		KillLine()
		EndFile()

		i = Query(PopWinX1)
		j = Query(PopWinY1)
		k = Query(PopWinCols)
		l = Query(PopWinRows)
		Window(1, 1, Query(ScreenCols), Query(ScreenRows))

		while rows
			rows = rows - 1
			a = GetText(1, cols)
			Up()
			s = GetText(1, cols)
			Up()
			VGotoXYAbs(x1, y1+rows)
			PutStrAttr(s, a)
		endwhile

		Window(i, j, i+k-1, k+l-1)

		GotoBufferId(cid)
		AbandonFile(g_idSaveWindow)
	endif
	g_idSaveWindow = 0
end


integer proc SaveWindow(integer x1, integer y1, integer cols, integer rows)
	integer cid = GetBufferId()
	integer i
	string s[255] = ""
	string a[255] = ""

	if not g_idSaveWindow
		g_idSaveWindow = CreateTempBuffer()
		if g_idSaveWindow
			BegFile()
			for i = 1 to rows
				VGotoXYAbs(x1, y1+i-1)
				if GetStrAttr(s, a, cols)
					AddLine(s)
					AddLine(a)
				else
					// error: clean up and abort
					GotoBufferId(cid)
					AbandonFile(g_idSaveWindow)
					g_idSaveWindow = 0
					goto error_saving_window
				endif
			endfor
			BegFile()
			InsertLine(Format(x1; y1; cols; rows))
			GotoBufferId(cid)
		else
			error_saving_window:
			Warn("error saving window")
		endif
	endif

	return(g_idSaveWindow)
end
#endif


#ifdef CWBORDER
proc DrawWindow(integer x1, integer y1, integer cols, integer rows,
		integer boxtype, string path, integer attr, integer line, string func)
#else
proc DrawWindow(integer x1, integer y1, integer cols, integer rows,
		string path, integer attr, integer line, string func)
#endif

	#ifdef WIN32
	SaveWindow(x1, y1, cols, rows)
	BufferVideo()
	#endif

	Window(x1, y1, x1+cols-1, y1+rows-1)

	Set(Attr, attr)
#ifdef CWBORDER
	DrawBox(boxtype, attr)
	Set(Attr, Query(StatusLineAttr))
	if Length(path)
		VGotoXY(Query(ScreenCols)/2, 1)
		PutStr(" "+SqueezePath(path, Query(ScreenCols)/2-6)+" ")
	endif
	if line
		// line number indicator
		VGotoXY(2, 1)
		PutStr(" L "+Str(line)+" ")
	endif
	if Length(func)
		// function name
		VGotoXY(13, 1)
		PutStr(" "+Ellipsify(func, Query(ScreenCols)/2-13-2)+" ")
	endif
	Window(x1+1, y1+1, x1+cols-2, y1+rows-2)
#else
	VGotoXY(1, 1)
	ClrEol()
	VGotoXY(35, 1)
	PutStr(path)
	if line
		// line number indicator
		VGotoXY(1, 1)
		PutStr("L "+Str(line))
	endif
	if Length(func)
		// function name
		VGotoXY(11, 1)
		PutStr(Ellipsify(func, 35-11-1), Query(HiliteAttr))
	endif
	Window(x1, y1+1, x1+cols-1, y1+rows-1)
#endif

	#ifdef WIN32
	UnBufferVideo()
	#endif
end


integer g_fCloseWhenDone = TRUE
integer g_idContextFile = 0
proc NonEditIdle()
	integer a, b, c, d
	integer ln
	string path[255]
	string func[80]
	integer cid
	integer i
	integer tw
	integer p

	if g_nCtxLine <> CurrLine()
		// get filename
		PushPosition()
		ln = Val(GetText(1, 8))
		EndLine()
		if not lFind(prefix, "^b")
			PopPosition()
			UnHook(NonEditIdle)
			return()
		endif
		path = GetToken(GetText(Length(prefix)+1, 255), " ", 1)
		PopPosition()

		#ifdef WIN32
		// make sure idle or file already loaded
		if Query(IdleTime) < nIdleMS and not GetBufferId(path)
			return()
		endif
		#endif

		// ok, we'll do it
		UnHook(NonEditIdle)
		g_nCtxLine = CurrLine()

		// open file
		cid = GetBufferId()
		if GetBufferId(path)
			// file already open in a buffer
			if g_fCloseWhenDone and g_idContextFile
				if GetBufferId(path) <> g_idContextFile
					AbandonFile(g_idContextFile)
					g_fCloseWhenDone = FALSE
				endif
			else
				g_fCloseWhenDone = FALSE
			endif
			g_idContextFile = GetBufferId(path)
			GotoBufferId(g_idContextFile)
		else
			// open file
			if not CreateBuffer(path)//, _HIDDEN_)
				return()
			endif
			PushBlock()
			if not InsertFile(path, _DONT_PROMPT_)
				PopBlock()
				AbandonFile()
				GotoBufferId(cid)
				return()
			endif
			PopBlock()
			if g_fCloseWhenDone and g_idContextFile
				AbandonFile(g_idContextFile)
			endif
			g_fCloseWhenDone = TRUE
			g_idContextFile = GetBufferId()
		endif

		// go to line
		PushPosition()
		GotoLine(ln)

		// get function name
		func = GetFunctionName()

		// remember current window coordinates
		a = Query(PopWinX1)
		b = Query(PopWinY1)
		c = Query(PopWinCols)
		d = Query(PopWinRows)

		#ifdef WIN32
		BufferVideo()
		#endif

		// draw context window
		#ifdef CWBORDER
		DrawWindow(1, Query(ScreenRows)-cyCtxWin+1,
				Query(ScreenCols), cyCtxWin,
				Query(CurrWinBorderType), path,
				Query(CurrWinBorderAttr), ln, func)
		#else
		DrawWindow(1, Query(ScreenRows)-cyCtxWin+1,
				Query(ScreenCols), cyCtxWin,
				path, Query(StatusLineAttr), ln, func)
		#endif
		Set(Attr, Query(MsgAttr))
		ClrScr()

		// get lines and draw them
		BegLine()
		Up(Query(PopWinRows)/3)
		for i = 1 to Query(PopWinRows)
			if ln == CurrLine()
				Set(Attr, Query(HiLiteAttr))
			else
				Set(Attr, Query(MsgAttr))
			endif
			VGotoXY(1, i)
			path = GetText(1, 255)
			if Query(ExpandTabs)
				// expand tabs
				//$ review: (chrisant) or could preserve current line, use
				// ExpandTabsToSpaces(), get line, restore line.
				tw = Query(TabWidth)
				loop
					p = Pos(Chr(9), path)
					if not p
						break
					endif
					path = Format(SubStr(path, 1, p-1):-(p-1+tw-((p-1) mod tw)):" ", DelStr(path, 1, p))
				endloop
			endif
			PutLine(path, Query(PopWinCols))
			if not Down()
				break
			endif
		endfor

		#ifdef WIN32
		UnBufferVideo()
		#endif

		// reset window coordinates
		Window(a, b, a+c-1, b+d-1)

		// cleanup
		PopPosition()
		GotoBufferId(cid)
	endif
end
#endif



// Key Handlers -----------------------------------------------------------

proc gotoFile(integer fNext, integer fInList)
	PushPosition()
	if fNext
		EndLine()
	else
		BegLine()
	endif
	if not lFind(prefix, iif(fNext, "^", "^b"))
		PopPosition()
		if fNext
			EndFile()
		else
			BegFile()
		endif
	else
		KillPosition()
		ScrollToCenter()
		GotoPos(Length(prefix) + 1)
		UpdateDisplay()
		if not fInList
			lFind(GetText(CurrPos(), Query(ScreenCols)), "c")
			HiLiteFoundText()
		endif
	endif
end



// List Enhancements ------------------------------------------------------

#ifndef AUTO_HILITE
proc HilightList()
	integer nCur = CurrLine()
	integer nAttr

	PushPosition()
	BegWindow()
	repeat
		if GetText(1, Length(prefix)) == prefix
			// color the line
			nAttr = iif(nCur == CurrLine(),
					Query(MenuSelectLtrAttr),
					Query(MenuTextLtrAttr))
			endif
			VGotoXYAbs(Query(PopWinX1), Query(PopWinY1)+CurrRow()-1)
			PutAttr(nAttr, Query(PopWinCols))
		endif
	#ifdef WIN32
	until CurrRow() == Query(PopWinRows) or not Down() //or KeyPressed()
	#else
	until CurrRow() == Query(PopWinRows) or not Down() or KeyPressed()
	#endif
	PopPosition()

	UnHook(HilightList)
end


proc HookIdle()
	Hook(_NONEDIT_IDLE_, HilightList)
end
#endif


#ifdef CONTEXT_WINDOW
proc AfterNonEditCommand()
	Hook(_NONEDIT_IDLE_, NonEditIdle)
end
#endif


proc DelThis()
	integer fChanged = FileChanged()

	if GetText(1, Length(prefix)) == prefix
		// delete all matches for this file
		repeat
		until not KillLine() or GetText(1, Length(prefix)) == prefix
		if GetText(1, Length(prefix)) <> prefix
			lFind(prefix, "^b")
			ScrollToCenter()
		endif
	else
		// just delete this match
		KillLine()
	endif
	FileChanged(fChanged)
end


#ifdef CONTEXT_WINDOW
proc ListLeftBtn()
	if g_fCtxWin and Query(MouseY) > Query(WindowY1)+Query(WindowRows)
		EndProcess(TRUE)
	else
		case MouseHotSpot()
			when _MOUSE_MARKING_
				PushPosition()
				GotoMouseCursor()
				if Query(MouseY) == Query(WindowY1)+CurrRow()-1
					KillPosition()
					UpdateDisplay()
					EndProcess(TRUE)
				else
					PopPosition()
				endif
			otherwise
				ProcessHotSpot()
		endcase
	endif
end
#endif


keydef ListKeys
<Shift PgDn>			gotoFile(TRUE, TRUE)
<Shift PgUp>			gotoFile(FALSE, TRUE)
<Shift GreyPgDn>		gotoFile(TRUE, TRUE)
<Shift GreyPgUp>		gotoFile(FALSE, TRUE)
<Del>					DelThis()
<GreyDel>				DelThis()
<Alt E>					EndProcess(TRUE)
<Ctrl Enter>			EndProcess(TRUE)
<F1>					mHelp("Grep List")
<F5>					EndProcess(TRUE)
#ifdef CONTEXT_WINDOW
<LeftBtn>				ListLeftBtn()
#endif
end


// buffer to clean up after, otherwise we'd clean up after every list window
// that came up, even windows from GETHELP.MAC.
integer idCleanup = 0

proc ListCleanup()
	if GetBufferId() == idCleanup
		#ifdef AUTO_HILITE
		DisplayMode(_DISPLAY_TEXT_)
		#else
		UnHook(HilightList)
		UnHook(HookIdle)
		#endif

		#ifdef CONTEXT_WINDOW
		// let go of cached context file
		if g_fCloseWhenDone and g_idContextFile
			AbandonFile(g_idContextFile)
		endif
		UnHook(NonEditIdle)
		UnHook(AfterNonEditCommand)
		#ifdef WIN32
		RestoreWindow()
		#endif
		#endif

		UnHook(ListCleanup)
	endif
end


#ifdef CONTEXT_WINDOW
proc ListStartup()
	integer a, b, c, d
#else
proc ListStartup()
#endif

	Unhook(ListStartup)

	#ifdef AUTO_HILITE
	DisplayMode(_DISPLAY_FINDS_)
	#else
	Hook(_AFTER_NONEDIT_COMMAND_, HookIdle)
	HookIdle()
	#endif

	idCleanup = GetBufferId()
	Hook(_LIST_CLEANUP_, ListCleanup)
	Enable(ListKeys)
	ListFooter(" {Enter}-Go to line  {Escape}-Cancel  {Alt E}-Edit this list  {F1}-Help ")

	#ifdef CONTEXT_WINDOW
	if g_fCtxWin
		g_nCtxLine = 0
		Hook(_AFTER_NONEDIT_COMMAND_, AfterNonEditCommand)
		AfterNonEditCommand()
		// remember current window coordinates
		a = Query(PopWinX1)
		b = Query(PopWinY1)
		c = Query(PopWinCols)
		d = Query(PopWinRows)
		#ifdef CWBORDER
		DrawWindow(1, Query(ScreenRows)-cyCtxWin+1,
				Query(ScreenCols), cyCtxWin, Query(CurrWinBorderType),
				"", Query(CurrWinBorderAttr), 0, "")
		#else
		DrawWindow(1, Query(ScreenRows)-cyCtxWin+1,
				Query(ScreenCols), cyCtxWin,
				"", Query(StatusLineAttr), 0, "")
		#endif
		Set(Attr, Query(MsgAttr))
		ClrScr()
		// reset window coordinates
		Window(a, b, a+c-1, b+d-1)
	endif
	#endif

	BreakHookChain()
end



// Functions --------------------------------------------------------------

// FWildMatch()
// compares filename to wildcard
integer proc FWildMatch(string filename, string wildcard)
	integer i = 1, j = 1
	string f[132] = Lower(filename)
	string w[132] = Lower(wildcard)

	if not Length(w) or not Length(f)
		return (FALSE)
	endif

	if SplitPath(f, _EXT_) == ""
		f = f + "."
	endif

	while i <= Length(f)
		//Message(f[i]; ""; w[j]; "  "; i; j; "  ")
		if w[j] == "*"
			if f[i] == "\" or f[i] == "."
				j = j + 1
			else
				i = i + 1
				if i > Length(f)
					j = j + 1
				endif
			endif
		elseif w[j] == "?"
			if f[i] <> "\" and f[i] <> "."
				i = i + 1
			endif
			j = j + 1
		elseif f[i] <> w[j]
			return (FALSE)
		else
			j = j + 1
			i = i + 1
		endif

		if j > Length(w)
			break
		endif
	endwhile

	if i <= Length(f) or j <= Length(w)
		return (FALSE)
	endif

	//Message("EXCLUDE!")
	return (TRUE)
end


integer cRecursed = 0		// FExclude can next @ signs to 4 levels (prevents infinite loops!)

// FExclude()
// checks to see if this file/directory is in the given exclude list
integer proc FExclude(string f, string excludespec, integer fDir)
	integer i
	string token[255]

	if not Length(excludespec)
		// quick bail if empty
		return (FALSE)
	endif

	for i = 1 to NumTokens(excludespec, " ")
		token = GetToken(excludespec, " ", i)

		if Length(token) and token[1] == "@" and cRecursed < 4
			// @ sign means look in a global variable for the list
			cRecursed = cRecursed + 1
			if FExclude(f, GetGlobalStr(token[2:255]), fDir)
				cRecursed = cRecursed - 1
				return (TRUE)
			endif
			cRecursed = cRecursed - 1
		else
			// normal filespec
			if not fDir
				if FWildMatch(SplitPath(f, _NAME_|_EXT_), token)
					return (TRUE)
				elseif FWildMatch(f, token)
					return (TRUE)
				endif
			else
				if ExpandPath(f) == ExpandPath(token)
					return (TRUE)
				endif
			endif
		endif
	endfor

	return (FALSE)
end


integer proc InteractiveKeys()
	if KeyPressed()
		case GetKey()
			when <Ctrl C>, <Escape>, 0
				return (FALSE)

			when <v>,<V>,<Shift V>,<Ctrl V>
				g_fVerbose = not g_fVerbose
				// toggle verbose
		endcase
	endif

	return (TRUE)
end


// SearchFile()
// search current buffer for needle
// returns FALSE if aborted via <Ctrl C>, <Escape>, or <Ctrl Break>
integer proc SearchFile(string expr, string opts, integer id, var integer n, integer fQuiet)
	string s[255]
	integer i, j = 0
	integer nThisFile = 0
	integer nFileLine
	integer cid
	integer ticks = GetClockTicks()

	if not InteractiveKeys()
		return(FALSE)
	endif

	if not IsSpecialFile(CurrFilename())
		PushPosition()
		BegFile()
		if lFind(expr, opts)
			s = prefix + CurrFilename()
			if g_fSearchingLoadedFiles
				s = s + c_stLoaded
			endif
			s = s + Chr(0)
			AddLine(s, id)
			cid = GotoBufferId(id)
			nFileLine = CurrLine()
			GotoBufferId(cid)

			if not fQuiet
				//if g_fVerbose
					Set(Attr, Color(bright yellow on black))
					WriteLine(s)
					Set(Attr, Color(bright white on black))
				//endif
			endif

			if g_fFilenamesOnly
				n = n + 1
				return(TRUE)
			endif

			repeat
				n = n + 1
				nThisFile = nThisFile + 1

				// context lines above
				if g_nContext
					j = j + 1
					if j > 1
						AddLine("ÄÄÄÄÄÄÄÄ", id)
					endif
					Context(g_nContext, FALSE, id)
				endif

				// actual match
				AddLine(Format(CurrLine():6, ': ',
						GetText(1, CurrLineLen())), id)

				// record which line to highlight in results list
				if g_cid == GetBufferId() and CurrLine() <= g_startlineno
					cid = GotoBufferId(id)
					g_lineno = CurrLine()
					GotoBufferId(cid)
				endif

				// context lines below
				if g_nContext
					Context(g_nContext, TRUE, id)
				endif

				if g_fVerbose and not fQuiet
					s = GetText(1, CurrLineLen())
					while Pos(Chr(9), s)
						i = Pos(Chr(9), s)
						s = DelStr(s, i, 1)
						loop
							s = InsStr(" ", s, i)
							if i mod Query(TabWidth) == 0
								break
							endif
							i = i + 1
						endloop
					endwhile
					if Length(s) > 240
						s = DelStr(s, 241, 50)+"..."
					endif
					WriteLine(CurrLine():6, ': ', s)
				endif

				if GetClockTicks() > ticks + 9
					ticks = GetClockTicks()
					if not InteractiveKeys()
						PopPosition()
						return(FALSE)
					endif
				endif

				// prevent multiple matches on same line
				EndLine()
			until not lRepeatFind()

			cid = GotoBufferId(id)
			PushPosition()
			GotoLine(nFileLine)
			EndLine()
			InsertText(Format(Str(nThisFile)+" occurrences found":
					Query(ScreenCols)-2-CurrLineLen()))
			PopPosition()
			GotoBufferId(cid)
		endif
		PopPosition()
	endif
	return (TRUE)
end


constant whatNeedle = 1
constant whatOpts = 2
constant whatFilespec = 3
constant whatExclude = 4
constant whatFlags = 5
integer g_idLastSearchParams= 0
string proc GetLast(integer what)
	string s[255] = ""
	integer cid

	if g_idLastSearchParams
		cid = GotoBufferId(g_idLastSearchParams)
		GotoLine(what)
		s = GetText(1, 255)
		GotoBufferId(cid)
	endif
	return(s)
end


proc RecordLastSearch(string needle, string opts, string filespec, string exclude, integer flags)
	if g_idLastSearchParams
		EmptyBuffer(g_idLastSearchParams)
		AddLine(needle, g_idLastSearchParams)
		AddLine(opts, g_idLastSearchParams)
		AddLine(filespec, g_idLastSearchParams)
		AddLine(exclude, g_idLastSearchParams)
		AddLine(Str(flags), g_idLastSearchParams)
	endif
end


// ShowResults()
// give picklist with results
forward proc Engine(string _needle, string szOpts, string filespec, string excludespec, integer flags)
proc ShowResults(integer fGoto)
	string path[255] = ""
	integer cid = GetBufferId()
	integer i, ln
	integer fTwoWindows

	if not id_found
		Warn("Grep results buffer does not exist.")
		return()
	endif

retry:
	GotoBufferId(id_found)
	Hook(_LIST_STARTUP_, ListStartup)
	Set(Y1, 2)
	Set(Key, 0)

	#ifdef CONTEXT_WINDOW
	cyCtxWin = iif(g_fCtxWin, Query(ScreenRows)*pctCtxWin/100, 0)
	if fGoto or lList(iif(Length(g_stTitle) > Query(ScreenCols)-10,
			SubStr(g_stTitle, 1, Query(ScreenCols)-10), g_stTitle),
			Query(ScreenCols), Query(ScreenRows)-3-cyCtxWin,
			_ENABLE_HSCROLL_|_ENABLE_SEARCH_|_FIXED_HEIGHT_)
	#else
	if fGoto or lList(iif(Length(g_stTitle) > Query(ScreenCols)-10,
			SubStr(g_stTitle, 1, Query(ScreenCols)-10), g_stTitle),
			Query(ScreenCols), Query(ScreenRows)-3,
			_ENABLE_HSCROLL_|_ENABLE_SEARCH_|_FIXED_HEIGHT_)
	#endif
		UnHook(ListStartup)
		// we'll leave id_found in the ring, unless <Alt E> hit.
		case Query(Key)
			when <Alt E>
				// insert search string at top
				PushPosition()
				BegFile()
				InsertLine("Searched for: "+g_stTitle)
				AddLine()
				PopPosition()
				// scroll the "searched for" text into view
				PushPosition()
				BegWindow()
				ln = CurrLine()
				if ln == 3
					ln = CurrLine()
					ScrollUp(2)
					if ln == CurrLine()
						KillPosition()
						PushPosition()
					endif
				endif
				PopPosition()
				// force file not changed
				FileChanged(FALSE)
				// user wants to edit file, so make it _NORMAL_ buffer
				BufferType(_NORMAL_)
				id_found = 0
				// force this hook, since GotoBufferId did not execute it
				ExecHook(_ON_CHANGING_FILES_)
			when <F5>
				// refresh (do the whole search again)
				GotoBufferId(cid)
				Engine(GetLast(whatNeedle),
						GetLast(whatOpts),
						GetLast(whatFilespec),
						GetLast(whatExclude),
						Val(GetLast(whatFlags))|_REFRESH)
				goto retry
			otherwise
				fTwoWindows = (Query(Key) == <Ctrl Enter>)
				PushPosition()
				ln = Val(GetText(1, 8))
				EndLine()
				if lFind(prefix, "^b")
					path = GetText(Length(prefix)+1, sizeof(path))
					path = Trim(SubStr(path, 1, Pos(Chr(0), path)))
					if path[Length(path)-Length(c_stLoaded):Length(c_stLoaded)] == c_stLoaded
						path = path[1:Length(path)-Length(c_stLoaded)]
					endif
					path = QuotePath(Trim(path))
					PopPosition()
					GotoBufferId(cid)

					#ifdef WIN32
					BufferVideo()
					#endif

					// open second window
					if fTwoWindows
						OneWindow()
						HWindow()
						#ifdef CONTEXT_WINDOW
						cyCtxWin = iif(cyCtxWin, cyCtxWin, Query(ScreenRows)*pctCtxWin/100)
						ResizeWindow(_UP_, cyCtxWin - Query(WindowRows) -
								iif(Query(ShowHelpLine), 3, 2))
						#else
						ResizeWindow(_UP_, Query(ScreenRows)*30/100 - Query(WindowRows) -
								iif(Query(ShowHelpLine), 3, 2))
						#endif
					endif

					if EditFile(path)
						UpdateHistoryStr(path, _EDIT_HISTORY_)
						if ln
							GotoLine(ln)
							// position cursor
							BegLine()
							lFind(GetLast(whatNeedle), FilterOpts(GetLast(whatOpts))+"c")
							ScrollToCenter()
						endif

						if fTwoWindows
							ScrollToRow((Query(WindowRows) +
									iif(Query(ShowHelpLine), 3, 2))/3)
							GotoWindow(1)
						endif
					else
						if fTwoWindows
							OneWindow()
						endif
					endif

					#ifdef WIN32
					UnBufferVideo()
					#endif
				else
					PopPosition()
					GotoBufferId(cid)
					Warn("Unable to parse filename.")
					goto retry
				endif
		endcase
		PushPosition()
		i = Set(Beep, OFF)
		Find(GetLast(whatNeedle), FilterOpts(GetLast(whatOpts)))
		Set(Beep, i)
		if g_fFunctionList and not fGoto
			VGotoXYAbs(Query(WindowX1), Query(WindowY1)+CurrRow()-1)
			PutAttr(Query(HiLiteAttr), Query(WindowCols))
		endif
		PopPosition()
	else
		UnHook(ListStartup)
		GotoBufferId(cid)
	endif

	#ifndef WIN32
	UpdateDisplay(_ALL_WINDOWS_REFRESH_)
	#endif
end


// Engine()
// the grep engine
/*
	Options:
		-c			current file only
		-b			block in current file only
		-m			files in memory
		-x			regular expressions
		-d			recurse subdirectories
		-l			filenames only
		-v			verbose
		-i			ignore case
		-^			anchor to beginning of line
		-$			anchor to end of line

*/
proc Engine(string _needle, string szOpts, string filespec, string excludespec, integer flags)
	string needle[255] = _needle
	string elapsed[60]
	string opts[12] = ""
	string s[80] = ""
	string path[255] = "", wild[128] = ""
	integer fGoto = FALSE
	integer fCurrFileOnly = (flags & _FUNCTIONLIST)
	integer fQuiet = (flags & _FUNCTIONLIST)
	integer attrib = _NORMAL_|_ARCHIVE_|_READONLY_|_HIDDEN_|_SYSTEM_
	integer ml
	integer id_search
	integer cid = GetBufferId()
	integer cBuffers = 0
	integer i
	integer hs
	integer n = 0
	integer fWasOpen
	integer hh1, mm1, ss1, hun1
	integer hh2, mm2, ss2, hun2
	integer nSearchedFiles = 0, nSearchedPaths = 0
	integer handle = -1

	PushPosition()
	GetTime(hh1, mm1, ss1, hun1)
	g_startlineno = CurrLine()
	g_lineno = 1
	g_cid = cid
	g_fSearchingLoadedFiles = FALSE
	g_stTitle = needle

	g_fFunctionList = FALSE

	// get buffers
	id_search = CreateTempBuffer()
	if id_found
		// discard previous buffer
		AbandonFile(id_found)
	endif

	// try incrementing the unique number as many as 32 times looking for a
	// valid filename.
	do 32 times
		unique = unique + 1
		id_found = CreateBuffer("$grep-"+Str(unique)+"$.$", _HIDDEN_)
		if id_found
			break
		endif
	enddo

	// bail if unable to create buffers
	if not id_search or not id_found
		// goto avoids _ON_CHANGING_FILES_ hook
		GotoBufferId(cid)
		PopPosition()
		AbandonFile(id_search)
		AbandonFile(id_found)
		id_found = 0
		Warn("Unable to create buffers.")
		return ()
	endif

	// go back to original buffer
	if not cid
		cid = id_found
	endif
	GotoBufferId(cid)

	// init vars and options
	g_fFilenamesOnly = FALSE
	g_fSubDirs = FALSE
	g_fSearchLoadedFiles = FALSE
	g_fVerbose = FALSE
	for i = 1 to Length(szOpts)
		case Lower(szOpts[i])
			when "l"
				// fiLenames only
				g_fFilenamesOnly = TRUE
			when "d"
				// traverse subDirectories
				g_fSubDirs = TRUE
			when "m"
				// search files in Memory (search loaded files)
				g_fSearchLoadedFiles = TRUE
			when "v"
				// Verbose
				g_fVerbose = TRUE
			when "c", "b"
				// current file only (negate -m, -d)
				fCurrFileOnly = TRUE
				g_fSubDirs = FALSE
				g_fSearchLoadedFiles = FALSE
				fQuiet = TRUE
				if Lower(szOpts[i]) == "b"
					// search block only
					opts = opts + "gl"
				endif
			otherwise
				opts = opts + szOpts[i]
		endcase
	endfor

	// for safety (and speed)
	hs = SetHookState(OFF)

	// main loop
	if not fCurrFileOnly
		for i = 1 to NumTokens(filespec, " ")
			path = GetToken(filespec, " ", i)
			if SplitPath(path, _DRIVE_|_PATH_) == ""
				path = iif(Length(g_dir), g_dir, CurrDir()) + path
			endif
			AddLine(path, id_search)

			// force alphabetical order for directories
			GotoBufferId(id_search)
			PushBlock()
			BegFile()
			MarkLine()
			EndFile()
			MarkLine()
			Set(MsgLevel, _NONE_)
			Sort(_IGNORE_CASE_)
			Set(MsgLevel, _ALL_MESSAGES_)
			PopBlock()
			GotoBufferId(cid)
		endfor
	endif

	if not fQuiet
		Window(1, iif(Query(StatusLineAtTop), 2, 1),
				Query(ScreenCols), iif(Query(StatusLineAtTop),
				Query(ScreenRows), Query(ScreenRows)-1))
		Set(Attr, Color(bright white on black))
		ClrScr()
		VHomeCursor()
	endif

	ml = Set(MsgLevel, _WARNINGS_ONLY_)

	// check files in memory
	if g_fSearchLoadedFiles or fCurrFileOnly
		g_fSearchingLoadedFiles = TRUE
		cBuffers = iif(fCurrFileOnly, 1,
				NumFiles() + (BufferType() <> _NORMAL_))
		while cBuffers
			nSearchedFiles = nSearchedFiles + 1
			if not SearchFile(needle, opts, id_found, n, fQuiet)
				goto __terminated
			endif
			NextFile()
			cBuffers = cBuffers - 1
		endwhile
		g_fSearchingLoadedFiles = FALSE
	endif

	// function list (current file only)
	if flags & _FUNCTIONLIST
		// look for function declaration/implementation
		GotoBufferId(cid)
		g_stTitle = "Function list for "+Upper(CurrFilename())
		g_fFunctionList = TRUE
		if Length(g_stFunction)
			g_stTitle = g_stFunction
			needle = g_stFunction

			GotoBufferId(id_found)

			// delete non-matching lines
			BegFile()
			Down()						// skip filename
			loop
				BegLine()
				if not lFind(g_stFunction, "cwi")
					KillLine()
					n = n - 1
					if CurrLine() > NumLines()
						break
					endif
				else
					if not Down()
						break
					endif
				endif
			endloop

			BegFile()
			lFind(Chr(0), "c")
			Right()
			KillToEol()
			InsertText(Format(Str(n)+" occurrences found":
					Query(ScreenCols)-2-CurrLineLen()))

			// find most likely match
			BegFile()
			Down()
			if lFind("::"+g_stFunction, "w") or lFind(g_stFunction, "iw")
				if NumLines() == 2
					// if only one match, automatically go there
					fGoto = TRUE
				endif
			endif

			g_lineno = CurrLine()
			GotoBufferId(cid)
		endif

		// done - skip searching files on disk
		goto __ok
	endif

	// load files
	loop
		// get next path spec
		GotoBufferId(id_search)
		if NumLines() == 0
			break
		endif
		BegFile()
		path = GetText(1, sizeof(path))
		nSearchedPaths = nSearchedPaths + 1
		KillLine()
		GotoBufferId(cid)

		// search path spec
		wild = SplitPath(path, _NAME_|_EXT_)
		handle = FindFirstFile(path, attrib)
		if handle <> -1
			path = SplitPath(ExpandPath(path), _DRIVE_|_PATH_)
			repeat
				nSearchedFiles = nSearchedFiles + 1
				// open and search file
				s = FFName()
				Message("Searching ", Trim(path+s), "...")
				fWasOpen = GetBufferId(Trim(path+s))
				if not g_fSearchLoadedFiles or not fWasOpen
					if not (FFAttribute() & _DIRECTORY_) and
							not FExclude(Trim(path+s), excludespec, FALSE)
							and EditFile(QuotePath(Trim(path+s)), _DONT_PROMPT_)
						i = SearchFile(needle, opts, id_found, n, fQuiet)
						if not fWasOpen
							AbandonFile()
						endif
						if not i
							goto __terminated
						endif
					#ifdef DEBUG
					else
						Warn("excluding"; Trim(path+s))
					#endif
					endif
				#ifdef DEBUG
				else
					Warn("ignoring"; Trim(path+s))
				#endif
				endif
			until not FindNextFile(handle, attrib)
			FindFileClose(handle)
		endif

		// enumerate subdirectories
		path = SplitPath(path, _DRIVE_|_PATH_)
		if g_fSubDirs
			handle = FindFirstFile(path+"*.*", attrib|_DIRECTORY_)
			if handle <> -1
				PushBlock()
				i = 0
				repeat
					s = FFName()
					if FFAttribute() & _DIRECTORY_ and s[1] <> "." and
							not FExclude(Trim(path+s), excludespec, TRUE)
							and not FExclude(Trim(s), excludespec, TRUE)
						#ifdef DEBUG
						Message("directory"; s)
						Delay(8)
						#endif
						// record directories in the dir buffer
						InsertLine(Trim(path+s)+"\"+wild, id_search)
						i = i + 1
					endif
				until not FindNextFile(handle, attrib)
				FindFileClose(handle)

				if KeyPressed()
					case GetKey()
						when <Ctrl C>, <Escape>, 0
							goto __terminated
					endcase
				endif

				if i
					// force directories into alphabetical order
					GotoBufferId(id_search)
					BegFile()
					MarkLine()
					EndFile()
					MarkLine()
					Set(MsgLevel, _NONE_)
					Sort(_IGNORE_CASE_)
					Set(MsgLevel, _ALL_MESSAGES_)
					GotoBufferId(cid)
				endif
				PopBlock()
			endif
		endif
	endloop

	goto __ok
__terminated:
	GotoBufferId(id_found)
	EndFile()
	AddLine("<Terminated>")
	BegLine()
__ok:

	GotoBufferId(cid)
	Set(MsgLevel, ml)
	FullWindow()
	GetTime(hh2, mm2, ss2, hun2)

	hun2 = hun2 - hun1
	if hun2 < 0
		hun2 = hun2 + 100
		ss2 = ss2 - 1
	endif
	ss2 = ss2 - ss1
	if ss2 < 0
		ss2 = ss2 + 60
		mm2 = mm2 - 1
	endif
	mm2 = mm2 - mm1
	if mm2 < 0
		mm2 = mm2 + 60
		hh2 = hh2 - 1
	endif
	hh2 = hh2 - hh1
	elapsed = "(Elapsed time " +
			Format(hh2, ":", mm2:2:"0", ":", ss2:2:"0", ".", hun2:2:"0") +
			", " + Str(nSearchedFiles) + " file" +
			iif(nSearchedFiles == 1, "", "s") + " searched)"

	// restore hooks
	SetHookState(hs)
	UpdateDisplay(_ALL_WINDOWS_REFRESH_|_HELPLINE_REFRESH_)

	AbandonFile(id_search)
	if not n
		PopPosition()
		AbandonFile(id_found)
		id_found = 0
		GotoBufferId(cid)
		Message("Not found.  ", elapsed)
		return()
	endif

	KillPosition()
	Message(n, " occurrences found.  ", elapsed)

	RecordLastSearch(needle, opts, filespec, excludespec, flags&(~_REFRESH))
	GotoBufferId(id_found)
	GotoLine(g_lineno)
	ScrollToCenter()
	GotoBufferId(cid)

	if not (flags & _REFRESH)
		ShowResults(fGoto)
	endif
end


proc GrepCurrWord(integer fMemory)
	string path[255] = SplitPath(CurrFilename(), _DRIVE_|_PATH_)
	string word[80]

	if isCursorInBlock() and isCursorInBlock() <> _LINE_
		word = GetMarkedText()
	else
		word = GetWord(TRUE)
	endif
	if not Length(word)
		if not Ask("Search for: ["+path+"]", word, _FIND_HISTORY_) or
				not Length(word)
			return()
		endif
	endif

	g_dir = path

	if fMemory
		Engine(word, "-im", "", "", 0)
	else
		Engine(word, "-i",
				"*.h *.hpp *.inl *.c *.cpp *.rc *.rc2 *.pp *.csv *.dlg "+
				"*.idl *.odl *.bat *.btm *.s *.si *.ui *.asm *.inc", "", 0)
	endif
end


proc FunctionList(string fn)
	string expr[255] = ""

	GetFunctionStr(CurrExt(), expr)

	if not Length(expr)
		Warn("Extension"; CurrExt(); "not supported")
		return ()
	endif

	g_stFunction = fn
	Engine(expr, "ix", "", "", _FUNCTIONLIST)
	g_stFunction = ""
end



// Dialog UI --------------------------------------------------------------

#if VARIATION == 2
proc SetCheck(string opt, string opts, integer nid)
	ExecMacro(Format("DlgSetData"; nid; iif(Pos(opt, opts), TRUE, FALSE)))
end


proc SetOptions()
	g_opts = GetHistoryStr(hist_opts, 1)

	SetCheck("^", g_opts, ID_CHK_BOL)
	SetCheck("$", g_opts, ID_CHK_EOL)
	SetCheck("b", g_opts, ID_CHK_BACK)
	SetCheck("i", g_opts, ID_CHK_CASE)
	SetCheck("w", g_opts, ID_CHK_WORDS)
	SetCheck("x", g_opts, ID_CHK_EXPR)
	SetCheck("d", g_opts, ID_CHK_SUBDIRS)
	SetCheck("l", g_opts, ID_CHK_FNAMES)
	SetCheck("m", g_opts, ID_CHK_MEM)
	SetCheck("v", g_opts, ID_CHK_VERBOSE)
	#ifdef CONTEXT_WINDOW
	ExecMacro(Format("DlgSetData"; ID_CHK_CTXWIN; g_fCtxWin))
	#endif
end


public proc GrepDataInit()
	if not Length(g_expr)
		g_expr = GetHistoryStr(_FIND_HISTORY_, 1)
	endif
	ExecMacro(Format("DlgSetTitle 0 Grep ["+CurrDir()+"]"))
	ExecMacro(Format("DlgSetTitle ",ID_EDT_EXPR," ",g_expr))
	ExecMacro(Format("DlgSetData ",ID_EDT_EXPR," ",_FIND_HISTORY_))
	ExecMacro(Format("DlgSetTitle ",ID_EDT_FILES," ",g_files))
	ExecMacro(Format("DlgSetData ",ID_EDT_FILES," ",hist_files))
	ExecMacro(Format("DlgSetTitle ",ID_EDT_EXCL," ",g_excl))
	ExecMacro(Format("DlgSetData ",ID_EDT_EXCL," ",hist_excl))
	ExecMacro(Format("DlgSetTitle ",ID_EDT_DIR," ",g_dir))
	ExecMacro(Format("DlgSetData ",ID_EDT_DIR," ",hist_dir))
	ExecMacro(Format("DlgSetTitle ",ID_EDT_CTX," ",Str(g_nContext)))
	SetOptions()
end


proc GetCheck(string opt, integer nid)
	ExecMacro(Format("DlgGetData"; nid))
	if Val(Query(MacroCmdLine))
		g_opts = g_opts + opt
	endif
end


public proc GrepKillFocus()
	string s[80]

	if CurrChar(POS_ID) == ID_EDT_DIR
		ExecMacro(Format("DlgGetTitle"; ID_EDT_DIR))
		s = Trim(Query(MacroCmdLine))
		if Length(s)
			s = ExpandPath(s)
			if SplitPath(s, _NAME_|_EXT_) == "*.*"
				s = SplitPath(s, _DRIVE_|_PATH_)
				DelHistoryStr(hist_dir, 1)
				AddHistoryStr(s, hist_dir)
			else
				s = ""
				DelHistoryStr(hist_dir, 1)
			endif
		endif
		ExecMacro(Format("DlgSetTitle ",ID_EDT_DIR," ",s))
	endif
end


public proc GrepDataDone()
	g_opts = ""
	GetCheck("^", ID_CHK_BOL)
	GetCheck("$", ID_CHK_EOL)
	GetCheck("b", ID_CHK_BACK)
	GetCheck("i", ID_CHK_CASE)
	GetCheck("w", ID_CHK_WORDS)
	GetCheck("x", ID_CHK_EXPR)
	GetCheck("d", ID_CHK_SUBDIRS)
	GetCheck("l", ID_CHK_FNAMES)
	GetCheck("v", ID_CHK_VERBOSE)
	GetCheck("m", ID_CHK_MEM)
	#ifdef CONTEXT_WINDOW
	ExecMacro(Format("DlgGetData"; ID_CHK_CTXWIN))
	g_fCtxWin = Val(Query(MacroCmdLine))
	#endif

	ExecMacro(Format("DlgGetTitle"; ID_EDT_EXPR))
	g_expr = Query(MacroCmdLine)
	ExecMacro(Format("DlgGetTitle"; ID_EDT_FILES))
	g_files = Query(MacroCmdLine)
	ExecMacro(Format("DlgGetTitle"; ID_EDT_EXCL))
	g_excl = Query(MacroCmdLine)
	ExecMacro(Format("DlgGetTitle"; ID_EDT_DIR))
	g_dir = Query(MacroCmdLine)
	ExecMacro(Format("DlgGetTitle"; ID_EDT_CTX))
	g_nContext = Val(Query(MacroCmdLine))

	UpdateHistoryStr(g_expr, _FINDHISTORY_)
	UpdateHistoryStr(g_opts, hist_opts)
	UpdateHistoryStr(g_files, hist_files)
	UpdateHistoryStr(g_excl, hist_excl)
	UpdateHistoryStr(g_dir, hist_dir)

	// save settings
	XferSettings(FALSE)
end


public proc GrepBtnDown()
	case CurrChar(POS_ID)
		when ID_OK			ExecMacro("DlgTerminate")
		//when ID_BTN_OPTS	IdBtnOpts()
		//when ID_HELP		mHelp("Summary List of Regular Expression Operators")
		when ID_HELP		mHelp("Grep Dialog")
	endcase
end


proc UI()
	integer id

	PushBlock()
	id = CreateTempBuffer()
	if id and InsertData(grepdlg) and ExecMacro("dialog grep")
		AbandonFile(id)
		if Val(Query(MacroCmdLine)) == ID_OK
			Engine(g_expr, g_opts, g_files, g_excl, 0)
		endif
	else
		Warn("Unable to bring up dialog.")
	endif
	PopBlock()
end
#endif



// Menu UI ----------------------------------------------------------------

#if VARIATION == 1
string proc OnOffStr(integer i)
	return (iif(i, "On", "Off"))
end


proc mToggle(var integer i)
	i = not i
end


proc mReadDir()
	if Read(g_dir, hist_dir) and Length(Trim(g_dir))
		g_dir = ExpandPath(g_dir)
		if SplitPath(g_dir, _NAME_|_EXT_) == "*.*"
			g_dir = SplitPath(g_dir, _DRIVE_|_PATH_)
			DelHistoryStr(hist_dir, 1)
			AddHistoryStr(g_dir, hist_dir)
		else
			g_dir = ""
			DelHistoryStr(hist_dir, 1)
			Warn("Could not expand path.")
		endif
	endif
	g_dir = Trim(g_dir)
end


proc mReadCtx()
	string s[10] = Str(g_nContext)

	if ReadNumeric(s)
		g_nContext = Val(s)
		if g_nContext < 0
			g_nContext = 0
		elseif g_nContext > 5
			g_nContext = 5
		endif
	endif
end


menu Stuff()
	"&Search for:" [Format(g_expr:-30):-30], Read(g_expr, _FIND_HISTORY_), DontClose, "String to search for."
	"&Options:   " [Format(g_opts:-10):-10], Read(g_opts, hist_opts), DontClose, "Options [DILX] (subDirs Ignore-case fiLenames reg-eXp)"
	"&Files:     " [Format(g_files:-30):-30], Read(g_files, hist_files), DontClose, "Files to search.  (Wildcards and directories are ok)"
	"&Exclude:   " [Format(g_excl:-30):-30], Read(g_excl, hist_excl), DontClose, "Files to exclude.  (Wildcards and directories are ok)"
	"&Directory: " [Format(g_dir:-30):-30], mReadDir(), DontClose, "Directory to start from.  (UNC paths are ok)"
	"General Options",, Divide
	"Search &Loaded Files" [OnOffStr(g_fSearchLoadedFiles):3],
						mToggle(g_fSearchLoadedFiles), DontClose, "Search all loaded files, too."
	"&Verbose" [OnOffStr(g_fVerbose):3],
						mToggle(g_fVerbose), DontClose, "While searching, echo matches to the screen.  (Faster when OFF)"
	"Context &Window" [OnOffStr(g_fCtxWin):3],
						mToggle(g_fCtxWin), DontClose, "Show context lines in a window."
	"&Context Lines" [g_nContext:3],
						mReadCtx(), DontClose, "Number of lines before and after to display (0..5)"
	"",, Divide
	"&Go!",,, "Start the search.  (While searching, <Escape> or <Ctrl Break> to abort)"
end


proc UI()
	if Stuff("Grep ["+CurrDir()+"]")
		Engine(g_expr, g_opts, g_files, g_excl, 0)
	endif

	// save settings
	XferSettings(FALSE)
end
#endif



// Ask UI -----------------------------------------------------------------

#if VARIATION == 0
proc UI()
	string needle[255] = g_expr, opts[12] = g_opts, files[255] = g_files
	string exclude[255] = ""

	if not Length(needle)
		needle = GetWord()
		if not Ask("List all occurrences of:", needle, _FINDHISTORY_)
				or Length(needle) == 0
			return()
		endif
		if not Length(opts)
			if not Ask("Options [DILXVF] (subDirs Ignore-case fiLenames reg-eXp Verbose Fast):",
					opts, hist_opts)
				return()
			endif
		endif
	else
		UpdateHistoryStr(needle, _FINDHISTORY_)
		UpdateHistoryStr(opts, hist_opts)
	endif

	if not Length(files)
		if not Ask("Files to search (eg. *.C *.H): ["+CurrDir()+"]",
				files, hist_files)
			return()
		endif
		if Length(files) == 0
			Message("No files.")
			return()
		endif
		UpdateHistoryStr(files, hist_files)

		if not Ask("Files to exclude (wildcards ok):",
				exclude, hist_excl)
			return()
		endif
		UpdateHistoryStr(exclude, hist_excl)
	endif

	Engine(needle, opts, files, exclude, 0)

	// save settings
	XferSettings(FALSE)
end
#endif



// Hooks ------------------------------------------------------------------

keydef GrepKeys
<Shift PgDn>			gotoFile(TRUE, FALSE)
<Shift PgUp>			gotoFile(FALSE, FALSE)
<Shift GreyPgDn>		gotoFile(TRUE, FALSE)
<Shift GreyPgUp>		gotoFile(FALSE, FALSE)
<Del>					DelThis()
<GreyDel>				DelThis()
end


integer fEnabled = FALSE
proc OnChangingFiles()
	if GrepFile(CurrFilename()) and not fEnabled
		Enable(GrepKeys)
		fEnabled = TRUE
	elseif fEnabled
		Disable(GrepKeys)
		fEnabled = FALSE
	endif
end



// Auto Macros ------------------------------------------------------------

proc WhenLoaded()
	integer cid = GetBufferId()

	// CurrMacroFilename() returns the full path of this loaded GREP.MAC.
	// Explicit paths make the package independent of TSE's working directory,
	// TSEPath, editor directory, and MAC subdirectory.
	g_stMacroDir = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_)
	LoadMacro(g_stMacroDir+"dialog.mac")
	LoadMacro(g_stMacroDir+"gethelp.mac")

	g_idLastSearchParams = CreateTempBuffer()
	GotoBufferId(cid)

	hist_opts = GetFreeHistory("Grep:Options")
	hist_files = GetFreeHistory("Grep:Files")
	hist_excl = GetFreeHistory("Grep:Exclude")
	#if VARIATION
	hist_dir = GetFreeHistory("Grep:Dir")
	#endif

	Hook(_ON_CHANGING_FILES_, OnChangingFiles)
	Hook(_ON_ABANDON_EDITOR_, Save)

	// load settings
	XferSettings(TRUE)
end


proc WhenPurged()
	if g_idLastSearchParams
		AbandonFile(g_idLastSearchParams)
	endif
	Save()
end



// Main -------------------------------------------------------------------

proc Grep(string cmdline)
	string s[255] = cmdline
	string orig_path[255] = ""
	integer fCmdLine = FALSE
	integer fParseFilespec = TRUE

	g_expr = ""
	g_opts = ""
	g_files = ""
	g_excl = ""
	g_dir = ""

	s = Trim(s)
	if Length(s)
		fCmdLine = TRUE
	else
		#if VARIATION
		g_expr = GetWord(TRUE)
		if not Length(g_expr)
			g_expr = GetHistoryStr(_FIND_HISTORY_, 1)
		endif
		g_opts = GetHistoryStr(hist_opts, 1)
		g_files = GetHistoryStr(hist_files, 1)
		g_excl = GetHistoryStr(hist_excl, 1)
		g_dir = GetHistoryStr(hist_dir, 1)
		#endif
	endif

	if Length(s)
		// get options
		if s[1] == "-"
			g_opts = "vm"

			while s[1] == "-"
				s = DelStr(s, 1, 1)

				// process the option
				case s[1]
					when "p"
						//$ review: WONT WORK WITH LONG FILENAMES THAT CONTAIN
						// SPACES.
						g_dir = s[2:255]
						if Pos(" ", g_dir)
							g_dir = SubStr(g_dir, 1, Pos(" ", g_dir) - 1)
						endif

						// expand path
						orig_path = g_dir
						g_dir = ExpandPath(g_dir)
						if SplitPath(g_dir, _NAME_|_EXT_) == "*.*"
							g_dir = SplitPath(g_dir, _DRIVE_|_PATH_)
						endif

						// successful?
						if g_dir[Length(g_dir)] <> "\"
							Warn("Unable to expand path"; orig_path)
							return()
						endif

					when "e"
						//$ review: WONT WORK WITH LONG FILENAMES THAT CONTAIN
						// SPACES.
						g_excl = s[2:255]
						if Pos(" ", g_excl)
							g_excl = SubStr(g_excl, 1, Pos(" ", g_excl) - 1)
						endif
						//$ review: WONT WORK WITH LONG FILENAMES THAT CONTAIN
						// COMMAS OR SEMICOLONS.
						g_excl = StripCommas(g_excl)

					otherwise
						g_opts = g_opts + s
						if Pos(" ", g_opts)
							g_opts = SubStr(g_opts, 1, Pos(" ", g_opts) - 1)
						endif
						if Pos("c", g_opts)
							fParseFilespec = FALSE
						endif
				endcase

				// chop off everything up to the next space
				if Pos(" ", s)
					s = LTrim(DelStr(s, 1, Pos(" ", s)))
				else
					s = ""
				endif
			endwhile
		endif

		// get needle
		if fParseFilespec
			if not (QuotedArg('"', s, g_expr) or
					QuotedArg("'", s, g_expr) or
					QuotedArg(Chr(13), s, g_expr))
				if Pos(" ", s)
					g_expr = SubStr(s, 1, Pos(" ", s) - 1)
					s = DelStr(s, 1, Pos(" ", s))
				else
					g_expr = s
					s = ""
				endif
			endif
		else
			g_expr = s
			s = ""
		endif

		g_files = Trim(s)
		if Length(g_files) and g_files[1] == "@"
			//$ review: THIS FEATURE NEEDS TO MAKE IT INTO THE HELP FILE!
			g_files = GetGlobalStr(g_files[2:80])
		endif
	endif

	if fCmdLine
		// don't update histories when used from the command line - it annoys
		// the heck out of me!
		/* - don't update histroies when used from the command line - it annoys the heck out of me
		// when used from the command line, update the histories, too
		UpdateHistoryStr(g_expr, _FINDHISTORY_)
		if not Pos("v", GetHistoryStr(hist_opts, 1))
			g_opts = DelStr(g_opts, Pos("v", g_opts), 1)
		endif
		if not Pos("m", GetHistoryStr(hist_opts, 1))
			g_opts = DelStr(g_opts, Pos("m", g_opts), 1)
		endif
		UpdateHistoryStr(g_opts, hist_opts)
		UpdateHistoryStr(g_files, hist_files)
		UpdateHistoryStr(g_excl, hist_excl)
		UpdateHistoryStr(g_dir, hist_dir)
		*/
		Engine(g_expr, g_opts, g_files, g_excl, 0)
		return()
	endif

	// need input from user
	UI()
end


// CmdLineOptionUsed()
// looks for -<option>, sets global str Arg<option> if found
integer proc CmdLineOptionUsed(STRING option)
	string temp[255] = Query(MacroCmdLine)+" ",
			arg[255] = "",
			opt[20] = "-" + option
	integer i

	if not Pos(opt, temp)
		// opt not found
		return(FALSE)
	else
		// option found
		i = Pos(opt, temp) + Length(opt)
		if temp[i] == " "
			// no argument used, reset cmd line
			temp = DelStr(temp, Pos(opt, temp), Length(opt)+1)
			Set(MacroCmdLine, temp)
		else
			// argument used
			// truncate the cmd line at the option
			Set(MacroCmdLine, SubStr(temp, 1, i-Length(opt)-1))
			// whack off everything before the arg
			temp = DelStr(temp, 1, i-1)
			// handle quoted args
			if not (QuotedArg('"', temp, arg) or
					QuotedArg("'", temp, arg) or
					QuotedArg(Chr(1), temp, arg))
				// get arg
				arg = temp[1:Pos(" ", temp)-1]
				// remove arg and space from temp
				temp = DelStr(temp, 1, Pos(" ", temp))
			endif
			// tack on remainder
			Set(MacroCmdLine, Query(MacroCmdLine) + RTrim(temp))
		endif
		SetGlobalStr('Arg' + option, Arg)
		return(TRUE)
	endif
	return(42)
end


proc Main()
	string s[255] = Query(MacroCmdLine)

	case Query(MacroCmdLine)
		when "-r"
			ShowResults(FALSE)
			return()
		when "-w"
			GrepCurrWord(TRUE)
			return()
	endcase

	// function list
	if CmdLineOptionUsed("f")
		FunctionList(Trim(GetGlobalStr("Argf")))
		return()
	endif

	// handles UI and starting the engine
	Grep(s)
end



// Keys -------------------------------------------------------------------

// the grep dialog
<Alt G>			Grep("")
<AltShift G>	ShowResults(FALSE)

// grep in current file's directory for word (or block) under cursor
<CtrlAlt G>		GrepCurrWord(FALSE)
<CtrlShift '>	GrepCurrWord(FALSE)

// grep files in memory for word/block under cursor
<Ctrl '>		GrepCurrWord(TRUE)

// find function
<Ctrl G>		FunctionList(GetWord(TRUE))
