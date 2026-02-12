// TSE/32
// FNEXP ù 4DOS-like filename completion
// Chris Antos, chrisant@microsoft.com

/*

	<Tab> inserts next matching filename.
	<Shift Tab> inserts previous matching filename.
	<Ctrl Tab> pops up picklist of matching filenames.
	<Ctrl Spacebar> pops up picklist of matching filenames.


	Command Line Switches: ------------------------------------------------
	-o		Pop up menu to set options.
	-next	Insert next matching filename.
	-prev	Insert previous matching filename (must use -next first).
	-pick	Use picklist to select filename.
	-short	Convert long filename to short (8.3) filename equivalent.


	Notes: ----------------------------------------------------------------
	In TSEPRO.INI, FNEXP uses the [FNEXP] section, and the following ini
	settings apply:

	AutoEnter:		1 = selecting filename from picklist performs the command
						(this is the default TSE behavior).
					0 = selecting filename from picklist returns to the
						prompt and more filenames can be selected.

	PicklistAlways:	1 = picklist always comes up when <Tab> key is pressed.
						(this is the default TSE behavior).
					0 = <Tab> does 4DOS-like filename completion; <Ctrl Tab>
						pops up picklist.

*/


/*
	History:

	v1.00 ù 04/10/96
	ù original version.

	v1.01 ù 07/02/96
	ù sorts filenames by name.

	v1.02 ù 07/24/96
	ù -uniq added.

	v1.03 ù 08/07/96
	ù sorts filenames ascending, case-insensitive, by name.

	v1.04 ù 10/01/96
	ù removed -uniq.
	ù <Ctrl Spacebar> pops up picklist.
	ù when popping up picklist, pushes the filename part onto the keyboard
	  stack so filename completion is more usable.

	v1.05 ù 11/20/96
	ù filenames sorted by name, filenames with default extensions listed
	  first!

	v1.06 ù 01/27/97
	ù trailing quote not required.
	ù fixed problems (including hang!) with multiple quoted filenames.
	ù fixed technical problems with picklist filename completion - special
	  thanks to Sammy Mitchell for information on the internal workings of
	  filename completion in prompt boxes.
	ù several technical improvements and obscure bug fixes.
	ù sort directories before any filenames.
	ù <Ctrl A> converts filename to short filename.

*/



// Variables --------------------------------------------------------------

#ifndef WIN32
#include ["ini.si"]
#endif

//#define DEBUG 1
//#define DEBUG_WINDOW 1
#define DEBUG_LIST 1

#ifdef WIN32
constant MAXPATH = 255				// _MAXPATH_
constant MAXEXT = 12
#else
constant MAXPATH = 128
constant MAXEXT = 4
#endif

constant NEXT = 1
constant PREV = 2
constant PICKLIST = 3
constant SHORT = 4

integer g_idList = 0				// temp buffer holding filename matches
integer g_fAutoEnter = TRUE			// see comment at top of file
integer g_fPicklistAlways = FALSE	// see comment at top of file

integer g_cPrompts = 0
integer g_fChainKeys = FALSE

// filename completion picklist extras
constant BOGUSKEY = 0xaaaa			// this key should not match any keycode that can be returned from GetKey
integer g_fPick = FALSE
integer g_idPrompt = 0				// kind of scary that we need this, but we do
string g_stFn[MAXPATH]

// ini stuff
string g_stSection[] = "FNEXP"



// DLL/Binary -------------------------------------------------------------

#ifdef WIN32
dll "<kernel32.dll>"
	integer proc GetShortPathName(string long_fn:cstrval,
			var string short_fn:strptr, integer n) : "GetShortPathNameA"
end
#else
binary ["attrfns.bin"]
	integer proc GetNAttrXYAbs(integer x1:word, integer y1:word, var string buf, integer n:word) : 0
	integer proc PutNAttrXYAbs(integer x1:word, integer y1:word, string buf, integer n:word) : 3
	integer proc GetNCharAttrXYAbs(integer x1:word, integer y1:word, var string buf, integer n:word) : 6
end
#endif



// Help -------------------------------------------------------------------

helpdef fnexp_help
title = "FNEXP"
width = 56
height = 30
x = 11
"FNEXP v1.06 ù 4DOS-like Filename Completion"
"by Chris Antos, chrisant@microsoft.com"
""
""
"FNEXP changes how TSE prompts work."
"When in a prompt box, these keys become active:"
""
"<Tab>             Insert next matching filename."
"<Shift Tab>       Insert previous matching filename."
"<Ctrl Tab>        Use picklist to select a filename."
"                  (This is what TSE used to do when"
"                  <Tab> was pressed)."
"<Ctrl Spacebar>   Same as <Ctrl Tab>."
"<Ctrl A>          Converts long filename to its"
"                  short (8.3)filename equivalent."
""
"The FNEXP keys are active only in prompt boxes."
""
"Users of 4DOS will recognize this behavior."
"4DOS provides similar filename completion at the DOS"
"prompt."
""
""
"Command Line Switches:"
"-o                Pop up Options menu."
"-next             Insert next matching filename."
"-prev             Insert previous matching filename"
"                  (-next must be used first)."
"-pick             Use picklist to select a filename."
""
""
"Note: FNEXP makes filename completion work in all"
"prompt boxes.  FNEXP is compatible with the EDITFILE"
"macro when you press <Ctrl Tab> (and behaves as if"
"you pressed <Tab>, assuming you have the AutoEnter"
"option turned on)."
end



// Keys -------------------------------------------------------------------

forward proc NextFilename(integer mode, integer fForce)
forward proc NextFilename_MaybeChain(integer mode, integer fForce)

keydef PromptKeys
<Tab>				NextFilename(NEXT, FALSE)
<Shift Tab>			NextFilename(PREV, FALSE)
<Ctrl Tab>			NextFilename(PICKLIST, not g_fAutoEnter)
<Ctrl Spacebar>		NextFilename_MaybeChain(PICKLIST, not g_fAutoEnter)
<BOGUSKEY>			TabRight()			// triggers the CmdMap to do FilenameCompletion
<Ctrl A>			NextFilename(SHORT, FALSE)
end



// Functions --------------------------------------------------------------

// ExpandEnvVars()
// return string with environment variables expanded.  (use %@ to reference
// TSE global vars).
integer proc ExpandEnvVars(var string st)
	integer i, j
	string env[33]
	string s[MAXPATH]

	s = st
	st = ""
	for i = 1 to Length(s)
		if s[i:2] == "%%"
			i = i + 1								// inc extra time
			st = st + "%"							// append %
		elseif s[i] == "%"
			i = i + 1								// inc past %
			j = i
			while i <= Length(s) and (s[i] in 'A'..'Z', 'a'..'z', '0'..'9', '_')
				i = i + 1
			endwhile
			env = s[j:(i - j)]
			if s[i] <> "%"
				i = i - 1
			endif
			if Length(env)
				st = st + iif(env[1] == "@",
							  GetGlobalStr(env[2:sizeof(env)]), GetEnvStr(env))
			endif
		else
			st = st + s[i]							// copy char
		endif
	endfor

	#ifdef DEBUG
	Warn(st)
	#endif

	return(st <> s)
end


#if 0
// mSearchPath()
// behaves like SearchPath, but can deal with path string up to TSE maximum
// string length.  also expands environment variables.  a given path cannot
// exceed the TSE maximum string length, either.  environment variables are
// expanded before evaluating each path instead of once at the beginning.
string proc mSearchPath(string fn, string path, string sub)
	integer ich = 1, j = 1
	integer iSemi
	string s[MAXPATH] = ""
	string tmp[MAXPATH] = ""

	if Length(path)
		while Length(s) == 0 and ich <= Length(path)
			//$ todo: doesn't deal with ";" inside quotes
			//$ todo: doesn't deal with quotes, period
			j = Pos(";", SubStr(path, ich, Length(path)))
			if j == 0
				iSemi = (Length(path) - ich) + 2
			else
				iSemi = j
			endif

			tmp = SubStr(path, ich, iSemi - 1)
			ExpandEnvVars(tmp)
			s = ExpandPath(tmp + "\" + fn)
			if Length(s) == 0 and Length(sub) > 0
				s = ExpandPath(tmp + "\" + sub + "\" + fn)
			endif
			if not FileExists(s)
				s = ""
			endif

			ich = ich + iSemi
		endwhile
	else
		if Length(sub)
			s = SearchPath(fn, path, sub)
		else
			s = SearchPath(fn, path)
		endif
	endif

	return(s)
end
#endif


// GetShortFilename()
// convert long filename to 8.3 format.
#ifdef WIN32
string proc GetShortFilename(string long_fn)
	string short_fn[MAXPATH] = Format("":MAXPATH)

	return (iif(GetShortPathName(long_fn, short_fn, sizeof(short_fn)) > 0,
			SubStr(short_fn, 1, Pos(Chr(0), short_fn)-1), long_fn))
end
#else
string proc GetShortFilename(string long_fn)
	return (long_fn)
end
#endif


// FilenameBegin()
// goto beginning of filename
proc FilenameBegin()
	integer i, n
	string ws[32] = Query(WordSet)

	i = 1
	while i < CurrPos()
		if CurrChar(i) == 34
			if Pos('"', GetText(i + 1, MAXPATH))
				n = i + 1 + Pos('"', GetText(i + 1, MAXPATH))
			else
				n = CurrLineLen()
			endif
			if n < CurrPos()
				// skip to next whitespace
				while n < CurrPos() and GetBit(ws, CurrChar(n))
					n = n + 1
				endwhile
				if n == CurrPos()
					GotoPos(i)
					#ifdef DEBUG
					Message("Starts:"; GetText(i, MAXPATH))
					Delay(8)
					#endif
					return()
				else
					#ifdef DEBUG
					Message("nope, not that one...")
					Delay(8)
					#endif
					i = n + 1
				endif
			else
				GotoPos(i)
				#ifdef DEBUG
				Message("Starts:"; GetText(i, MAXPATH))
				Delay(8)
				#endif
				return()
			endif
		elseif GetBit(ws, CurrChar(i))
			// skip to next whitespace
			n = i
			while n < CurrPos() and GetBit(ws, CurrChar(n))
				n = n + 1
			endwhile
			if n == CurrPos()
				GotoPos(i)
				#ifdef DEBUG
				Message("Starts:"; GetText(i, MAXPATH))
				Delay(8)
				#endif
				return()
			endif
			i = n
		else
			i = i + 1
		endif
	endwhile
	#ifdef DEBUG
	Message("No start found.")
	Delay(8)
	#endif
end


proc FilenameEnd()
	if CurrChar() == 34
		if lFind('"', '+c')
			repeat
				Right()
			until not GetBit(Query(WordSet), CurrChar())
		else
			EndLine()
		endif
	else
		EndWord()
	endif
end


#ifndef WIN32
string dta[43] = ""


string proc FFName()
	return(Trim(SubStr(DecodeDTA(dta), 2, 13)))
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


proc BuildExpandList(string fn, integer flags)
	string s[MAXPATH]
	integer handle
	string ext[MAXEXT]
	integer i

	EmptyBuffer()
	handle = FindFirstFile(fn, flags)
	if handle <> -1
		repeat
			s = FFName()
			if s <> "." and s <> ".."
				AddLine(s)

				// force filenames with a default extension to sort first
				ext = Lower(Trim(SubStr(SplitPath(s, _EXT_), 2, SizeOf(ext))))
				if Length(ext) and
						Pos(" "+ext+" ", " "+Lower(Query(DefaultExt))+" ")
					BegLine()
					InsertText(Chr(0), _INSERT_)
				endif

				// force directories to sort first
				if FFAttribute() & _DIRECTORY_
					BegLine()
					InsertText(Chr(0)+Chr(0), _INSERT_)
				endif
			endif
		until not FindNextFile(handle, flags)
		FindFileClose(handle)
	endif

	if NumLines() > 0
		PushBlock()

		// sort filenames
		UnMarkBlock()
		MarkLine(1, NumLines())
		Set(MsgLevel, _NONE_)
		Sort(_IGNORE_CASE_)
		Set(MsgLevel, _ALL_MESSAGES_)

		// sort default exts based on order in DefaultExt
		EndFile()
		AddLine()

		// mark lines with default exts
		BegFile()
		InsertLine()
		Down()
		UnMarkBlock()
		MarkChar()
		while not CurrChar(1) and Down()
		endwhile
		MarkChar()

		// move default exts to head of list, maintaining sorted order for
		// each type of extension.
		if isBlockMarked()
			for i = NumTokens(Query(DefaultExt), " ") downto 1
				while isBlockMarked() and
						lFind("."+GetToken(Query(DefaultExt), " ", i), "glib$")
					s = GetText(1, CurrLineLen())
					KillLine()
					BegFile()
					InsertLine(s)
				endwhile
			endfor
		endif

		// remove blank lines
		while lFind("", "g^$")
			KillLine()
		endwhile

		// remove leading Chr(0)'s
		BegFile()
		loop
			if not CurrChar(1)
				GotoPos(2)
				SplitLine()
				KillLine()
			elseif not Down()
				break
			endif
		endloop

		PopBlock()
	endif
end


string proc GetNonWildName(string fn)
	string st[MAXPATH]
	integer iStar, iQues, i

	st = SplitPath(fn, _NAME_|_EXT_)
	iStar = Pos("*", st)
	iQues = Pos("?", st)
	if iStar and iQues
		i = min(iStar, iQues)
	else
		i = iif(iStar, iStar, iQues)
	endif
	if i
		st = DelStr(st, i, sizeof(st))
	endif
	return(st)
end


proc ClearFn()
	g_fPick = FALSE
end


proc NonEditIdle()
	integer cid
	string s[MAXPATH] = ""

	UnHook(NonEditIdle)
	if g_fPick
		// reset
		ClearFn()

		// get the statusline text...
		#ifdef WIN32
		VGotoXYAbs(1, Query(StatusLineRow))
		GetStr(s, Query(ScreenCols))
		#else
		GetNCharAttrXYAbs(1, Query(StatusLineRow), s, Query(ScreenCols))
		for cid = Length(s)/2 downto 1
			// strip the attrs out
			s = DelStr(s, cid*2, 1)
		enddo
		#endif

		// ...are we here because FilenameCompletion never got called, or was
		// there an error?
		if Pos(" Press <Escape>", s)
			// an error occurred with FilenameCompletion, so bail
			return()
		endif

		#ifdef DEBUG
		Message("FilenameCompletion fell thru; reverting to PickFile")
		Delay(16)
		#endif

		cid = GotoBufferId(g_idPrompt)	// kind of scary we have to do this...
		NextFilename(PICKLIST, TRUE)
		GotoBufferId(cid)				// kind of scary we have to do this...
		UpdateDisplay()
	endif
end


proc NextFilename(integer mode, integer fForce)
	string fn[MAXPATH]
	integer fFound = FALSE
	integer fReplace = FALSE
	integer fPicklist = FALSE
	integer cid
	string ws[32]

	ws = Set(WordSet, ChrSet("-!-*.-:?@A-z{}~\d127-\d255"))
	Set(Marking, OFF)
	PushBlock()
	UnMarkBlock()
	PushPosition()

	#ifdef DEBUG
	Message("text: [", GetText(1, MAXPATH), "]")
	Delay(8)
	#endif

	//$ todo: we probably don't handle nested quotes very well

	// mark filename
	FilenameBegin()
	MarkChar()
	FilenameEnd()
	MarkChar()
	fn = GetMarkedText()
	fReplace = ExpandEnvVars(fn)
	if fn[1] == '"'
		fn = DelStr(fn, 1, 1)
		if Pos('"', fn)
			fn = DelStr(fn, Pos('"', fn), 1)
		endif
	endif

	#ifdef DEBUG
	Message("filename:"; fn)
	Delay(8)
	#endif

	if g_fPicklistAlways
		mode = PICKLIST
	endif

	case mode
		when SHORT
			fn = GetShortFilename(fn)
			fFound = TRUE
		when PICKLIST
			if not fForce
				Hook(_NONEDIT_IDLE_, NonEditIdle)
				g_fPick = TRUE
				g_idPrompt = GetBufferId()
				g_stFn = fn
				PushKey(<boguskey>)
			else
				fPicklist = TRUE
				if Length(SplitPath(fn, _EXT_))
					fn = fn+"*"
				else
					fn = fn+"*.*"
				endif
				// we'll push this string onto the keyboard stack so filename
				// completion is more usable.
				PushKeyStr(GetNonWildName(fn))
				fn = PickFile(fn)
				fFound = (Length(fn) > 0)
			endif
		otherwise
			if mode == NEXT and Query(LastKey) <> Query(Key) and
					not (Query(LastKey) in <Tab>, <Shift Tab>)
				// start new completion list
				if Length(SplitPath(fn, _EXT_))
					fn = fn+"*"
				else
					fn = fn+"*.*"
				endif

				// build list of matching files/directories
				cid = GotoBufferId(g_idList)
				if cid
					BuildExpandList(fn, _READONLY_|_ARCHIVE_|_DIRECTORY_)
					fFound = NumLines() > 0
					BegFile()
					GotoBufferId(cid)
				endif
			else
				// use existing completion list
				cid = GotoBufferId(g_idList)
				if cid
					fFound = iif(mode == NEXT, Down(), Up())
					GotoBufferId(cid)
				endif
			endif
	endcase

	if fFound
		// get new filename
		if mode in NEXT, PREV
			cid = GotoBufferId(g_idList)
			fn = SplitPath(fn, _DRIVE_|_PATH_)
			fn = fn + GetText(1, CurrLineLen())
			#if 0
			if FileExists(fn) & _DIRECTORY_
				// add backslash if directory
				fn = fn + "\"
			endif
			#endif
			GotoBufferId(cid)
		endif
	endif

	if fFound or fReplace
		// remove what's there
		if isBlockMarked()
			#ifdef DEBUG
			Message("remove:"; GetMarkedText())
			Delay(8)
			#endif
			GotoBlockBegin()
			KillBlock()
		endif

		// add quotes
		fn = QuotePath(fn)

		// append space for convenience when picklist used
		if fPicklist
			fn = fn + " "
		endif

		// insert new filename
		#ifdef DEBUG
		Message("insert:"; fn)
		#endif
		InsertText(fn, _INSERT_)
		KillPosition()
		PushPosition()
	endif

	PopPosition()
	PopBlock()
	Set(WordSet, ws)
end


proc NextFilename_MaybeChain(integer mode, integer fForce)
	if g_fChainKeys
		ChainCmd()
	else
		NextFilename(mode, fForce)
	endif
end


#ifdef DEBUG_LIST
proc ListExpandList()
	integer cid

	cid = GotoBufferId(g_idList)
	if cid
		List("Debug ù Completion List", 50)
		GotoBufferId(cid)
	endif
end
#endif


proc PickFileStartup()
	UnHook(NonEditIdle)
	if g_fPick
		if Length(g_stFn)
			// we'll push this string onto the keyboard stack so filename
			// completion is more usable.
			PushKeyStr(GetNonWildName(g_stFn))
		endif

		// reset
		ClearFn()
	endif
end


proc PromptCleanup()
	UnHook(NonEditIdle)

	g_cPrompts = g_cPrompts - 1
	if not g_cPrompts
		Disable(PromptKeys)
		UnHook(PickFileStartup)
	endif

	// reset
	ClearFn()
end


proc PromptStartup()
	Enable(PromptKeys)
	if not g_cPrompts
		Hook(_PICKFILE_STARTUP_, PickFileStartup)
	endif
	g_cPrompts = g_cPrompts + 1

	// reset
	ClearFn()
end



// Menus ------------------------------------------------------------------

string proc OnOffStr(integer f)
	return(iif(f, "On", "Off"))
end


proc mToggle(var integer f)
	f = not f
end


menu Options()
title = "Filename Completion Options"
"&AutoEnter" [OnOffStr(g_fAutoEnter):3], mToggle(g_fAutoEnter), DontClose, "Toggle automatic execution of the command when filename selected from picklist."
"&Picklist Always" [OnOffStr(g_fPicklistAlways):3], mToggle(g_fPicklistAlways), DontClose, "Always use picklist."
end



// Auto Macros ------------------------------------------------------------

proc WhenLoaded()
	integer cid = GetBufferId()

	g_idList = CreateTempBuffer()
	if not g_idList
		Warn("Error creating temp buffer")
		PurgeMacro(CurrMacroFilename())
		return()
	endif

	Hook(_PROMPT_STARTUP_, PromptStartup)
	Hook(_PROMPT_CLEANUP_, PromptCleanup)

	GotoBufferId(cid)

	g_fAutoEnter = GetProfileInt(g_stSection, "AutoEnter", TRUE)
	g_fPicklistAlways = GetProfileInt(g_stSection, "PicklistAlways", FALSE)
end


proc WhenPurged()
	if g_idList
		AbandonFile(g_idList)
	endif
end


proc Main()
	case Lower(Query(MacroCmdLine))
		when "-o"
			Options()
			WriteProfileInt(g_stSection, "AutoEnter", g_fAutoEnter)
			WriteProfileInt(g_stSection, "PicklistAlways", g_fPicklistAlways)
		when "-short"
			NextFilename(SHORT, FALSE)
		when "-next"
			NextFilename(NEXT, FALSE)
		when "-prev"
			NextFilename(PREV, FALSE)
		when "-pick"
			NextFilename(PICKLIST, not g_fAutoEnter)

		// to allow other macros to force Ctrl-Space to chain to their keydef
		when "-chain"
			Set(MacroCmdLine, iif(g_fChainKeys, "-chain", "-nochain"))
			g_fChainKeys = TRUE
		when "-nochain"
			g_fChainKeys = FALSE

		// otherwise show help
		otherwise
			QuickHelp(fnexp_help)
	endcase
end


#ifdef DEBUG_LIST
<CtrlAlt Tab>		ListExpandList()
#endif

