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

integer id_list = 0					// temp buffer holding filename matches
integer fAutoEnter = TRUE			// see comment at top of file
integer fPicklistAlways = FALSE		// see comment at top of file

integer g_cChain = 0				// <Tab> just does ChainCmd() when > 0
integer g_cPrompts = 0

// ini stuff
string g_stSection[] = "FNEXP"



// Help -------------------------------------------------------------------

helpdef fnexp_help
title = "FNEXP"
width = 56
height = 30
x = 11
"FNEXP v1.05 ù 4DOS-like Filename Completion"
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

forward proc NextFilename(integer mode)

keydef PromptKeys
<Tab>				NextFilename(NEXT)
<Shift Tab>			NextFilename(PREV)
<Ctrl Tab>			NextFilename(PICKLIST)
<Ctrl Spacebar>		NextFilename(PICKLIST)
end



// Functions --------------------------------------------------------------

// FilenameBegin()
// goto beginning of filename
#ifdef WIN32
proc FilenameBegin()
	integer i, n

	i = 1
	while i < CurrPos()
		if CurrChar(i) in 9, 32
			i = i + 1
		elseif CurrChar(i) == 34
			n = i + 1 + Pos('"', GetText(i + 1, 255))
			if n < CurrPos()
				// skip to next whitespace
				n = n + 1
				while n < CurrPos() and not (CurrChar(n) in 9, 32)
					n = n + 1
				endwhile
				if n == CurrPos()
					GotoPos(i)
					#ifdef DEBUG
					Message("Starts:"; GetText(i, 255))
					Delay(8)
					#endif
					return()
				endif
			else
				GotoPos(i)
				#ifdef DEBUG
				Message("Starts:"; GetText(i, 255))
				Delay(8)
				#endif
				return()
			endif
		else
			// skip to next whitespace
			n = i
			while n < CurrPos() and not (CurrChar(n) in 9, 32)
				n = n + 1
			endwhile
			if n == CurrPos()
				GotoPos(i)
				#ifdef DEBUG
				Message("Starts:"; GetText(i, 255))
				Delay(8)
				#endif
				return()
			endif
			i = n
		endif
	endwhile
	#ifdef DEBUG
	Message("No start found.")
	Delay(8)
	#endif
end
#else
proc FilenameBegin()
	if Left()
		if not (CurrChar() in 9, 32)
			BegWord()
		else
			Right()
		endif
	endif
end
#endif


proc FilenameEnd()
	#ifdef WIN32
	if CurrChar() == 34
		lFind('"', '+c')
	endif
	#endif

	EndWord()
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
			endif
		until not FindNextFile(handle, flags)
		FindFileClose(handle)
	endif

	if NumLines() > 0
		PushBlock()

		// sort filenames
		UnMarkBlock()
		BegFile()
		MarkLine()
		EndFile()
		MarkLine()
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

		// remove Chr(0) which forced default extensions to sort first
		BegFile()
		repeat
			if not CurrChar(1)
				GotoPos(2)
				SplitLine()
				KillLine()
			endif
		until not Down()

		PopBlock()
	endif
end


proc NextFilename(integer mode)
	string fn[255]
	string fnStr[80]
	integer fFound = FALSE
	integer fPicklist = FALSE
	integer cid
	string ws[32]

	if g_cChain > 0
		#ifdef DEBUG
		Message("key: [", Query(Key), "]    lastkey: [", Query(LastKey), "]")
		Delay(8)
		#endif
		//g_cChain = g_cChain - 1
		ChainCmd()
		return()
	endif

	ws = Set(WordSet, ChrSet("-!-*.-:?@A-z{}~\d127-\d255"))
	Set(Marking, OFF)
	PushBlock()
	UnMarkBlock()
	PushPosition()

	#ifdef DEBUG
	Message("text: [", GetText(1, 255), "]")
	Delay(8)
	#endif

	// mark filename
	FilenameBegin()
	MarkChar()
	FilenameEnd()
	MarkChar()
	fn = GetMarkedText()
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

	if fPicklistAlways
		mode = PICKLIST
	endif

	if mode == PICKLIST
		// we'll push this string onto the keyboard stack so filename
		// completion is more usable.
		fnStr = SplitPath(fn, _NAME_)
		if Pos("*", fnStr) or Pos("?", fnStr)
			fnStr = SubStr(fnStr, 1, min(Pos("*", fnStr), Pos("?", fnStr))-1)
		endif

		fPicklist = not fAutoEnter
		lReplace(Chr(9), " ", "gcn")
		if fAutoEnter
			g_cChain = g_cChain + 1
			PushKeyStr(fnStr)
			PressKey(<Tab>)
			//PushKey(<Tab>)
			g_cChain = g_cChain - 1
		endif
		if (CurrPos() and CurrChar(CurrPos() - 1) == 9)
			fPicklist = TRUE
			BackSpace()
		endif
		if fPicklist
			if Length(SplitPath(fn, _EXT_))
				fn = fn+"*"
			else
				fn = fn+"*.*"
			endif
			PushKeyStr(fnStr)
			fn = PickFile(fn)
			fFound = (Length(fn) > 0)
		else
			fn = ""
		endif
	elseif mode == NEXT and Query(LastKey) <> Query(Key) and
			not (Query(LastKey) in <Tab>, <Shift Tab>)
		// start new completion list
		if Length(SplitPath(fn, _EXT_))
			fn = fn+"*"
		else
			fn = fn+"*.*"
		endif

		// build list of matching files/directories
		cid = GotoBufferId(id_list)
		if cid
			BuildExpandList(fn, _READONLY_|_ARCHIVE_|_DIRECTORY_)
			fFound = NumLines() > 0
			BegFile()
			GotoBufferId(cid)
		endif
	else
		// use existing completion list
		cid = GotoBufferId(id_list)
		if cid
			fFound = iif(mode == NEXT, Down(), Up())
			GotoBufferId(cid)
		endif
	endif

	if fFound
		// get new filename
		if mode in NEXT, PREV
			cid = GotoBufferId(id_list)
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


#ifdef DEBUG_LIST
proc ListExpandList()
	integer cid

	cid = GotoBufferId(id_list)
	if cid
		List("Debug ù Completion List", 50)
		GotoBufferId(cid)
	endif
end
#endif


proc PromptCleanup()
	g_cPrompts = g_cPrompts - 1
	if not g_cPrompts
		Disable(PromptKeys)
	endif
end


proc PromptStartup()
	g_cChain = 0
	Enable(PromptKeys)
	g_cPrompts = g_cPrompts + 1
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
"&AutoEnter" [OnOffStr(fAutoEnter):3], mToggle(fAutoEnter), DontClose, "Toggle automatic execution of the command when filename selected from picklist."
"&Picklist Always" [OnOffStr(fPicklistAlways):3], mToggle(fPicklistAlways), DontClose, "Always use picklist."
end



// Auto Macros ------------------------------------------------------------

proc WhenLoaded()
	integer cid = GetBufferId()

	id_list = CreateTempBuffer()
	if not id_list
		Warn("Error creating temp buffer")
		PurgeMacro(CurrMacroFilename())
		return()
	endif
	Hook(_PROMPT_STARTUP_, PromptStartup)
	Hook(_PROMPT_CLEANUP_, PromptCleanup)
	GotoBufferId(cid)

	fAutoEnter = GetProfileInt(g_stSection, "AutoEnter", TRUE)
	fPicklistAlways = GetProfileInt(g_stSection, "PicklistAlways", FALSE)
end


proc WhenPurged()
	if id_list
		AbandonFile(id_list)
	endif
end


proc Main()
	integer fTmp

	case Lower(Query(MacroCmdLine))
		when "-o"
			Options()
			WriteProfileInt(g_stSection, "AutoEnter", fAutoEnter)
			WriteProfileInt(g_stSection, "PicklistAlways", fPicklistAlways)
		when "-next"
			NextFilename(NEXT)
		when "-prev"
			NextFilename(PREV)
		when "-pick"
			fTmp = fPicklistAlways
			fPicklistAlways = TRUE
			NextFilename(PICKLIST)
			fPicklistAlways = fTmp
		otherwise
			QuickHelp(fnexp_help)
	endcase
end


#ifdef DEBUG_LIST
<CtrlAlt Tab>		ListExpandList()
#endif

