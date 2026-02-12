// TSE/32
// GREP.S ù Grep Function
// Christopher Antos

//$ todo: (chrisant) help
//$ todo: (chrisant) documentation

//$ todo: General Options dialog
		// - Context Window
		// - Background Searching
		// - Default to current directory



// The excludespec can handle legal DOS wildcards, but may behave incorrectly
// when given badly formed wildcards such as "*foo*.*".  The excludespec can
// be a list of multiple wildcards or directory names (eg. "mac spell *.s
// *.ui").  It can also handle contructs like "mac\*.bin mac\*.mac"



///////////////////////////////////////////////////////////////////////////
// Definitions

STRING iniFileNameGS[255] = ".\grep3230.ini"

// these should either be defined to 1, or not defined at all
//#define DEBUG 1
#define AUTO_HILITE 1			// AUTO_HILITE:	 hilite filename lines via TSE's _DISPLAY_FINDS_ mode
#define CONTEXT_WINDOW 1		// CONTEXT_WINDOW:	display context window when in finds list
#define CWBORDER 1				// CWBORDER:  display border around context window


// these must be defined to some value
// #define VARIATION 2				// VARIATION:  0=Ask, 1=Menu, 2=Dialog // old [kn, ri, tu, 29-11-2022 18:14:36]
#define VARIATION 1				// VARIATION:  0=Ask, 1=Menu, 2=Dialog // new [kn, ri, tu, 29-11-2022 18:14:42]
#define BACKGROUNDSEARCH TRUE	// BACKGROUNDSEARCH:  TRUE=Always, FALSE=Never


// misc
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

#include ["guiinc.inc"]



///////////////////////////////////////////////////////////////////////////
// Constants

constant c_nVer				= 0x0300	// e.g., v2.2 == 0x0220

constant _FUNCTIONLIST		= 0x0001
constant _REFRESH			= 0x0002
constant MAXPATH			= 255

constant KBD_RESPONSE_TIME	= 4

constant _ATTRS = _NORMAL_|_ARCHIVE_|_READONLY_|_HIDDEN_|_SYSTEM_

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

string c_stGREP_MagicMarker[] = "<GREP Results File>"
string c_stSearchedFor[] = "Searched for: "
string c_stOptions[] = "Options: "



///////////////////////////////////////////////////////////////////////////
// Variables

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
integer g_idSearch = 0

string g_stTitle[255]
integer g_cid
integer g_lineno
integer g_startlineno

integer g_fFunctionList = FALSE
integer g_idFound = 0					// grep results buffer

integer g_fInShowResults = FALSE
integer g_fIdleSearching = FALSE

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



///////////////////////////////////////////////////////////////////////////
// Debugging

#ifdef DEBUG
proc Assert(integer f, string st)
	if not f
		Warn(st)
	endif
end
#endif



///////////////////////////////////////////////////////////////////////////
// DOS Compatibility

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


#if 0
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
	return(SetDTA(dta) and FindNext())
end


proc FindFileClose(integer handle)
end
#endif


string proc PBName()
	string name[8], ext[4]

	name = GetText(11 + ((PBAttribute() & _DIRECTORY_) <> 0), 8)
	name = Trim(name)
	ext = GetText(21, 3)
	ext = Trim(ext)
	if Length(ext)
		ext = "." + ext
	endif
	return (name + ext)
end


integer proc PBAttribute()
	return(CurrChar(2))
end


proc BuildPickBufferEx(string path, integer attrib)
	BuildPickBuffer(path, attrib)
end


string proc QuotePath(string s)
	return(s)
end


integer proc MatchFilename(string fn, string mask)
	return(MatchFilenames(fn, mask)
end


/*
integer proc EditBuffer(string fn)
	integer id = 0

	if CreateBuffer("")
		PushBlock()
		if InsertFile(fn, _DONT_PROMPT_)
			id = GetBufferId()
		endif
		PopBlock()
	endif
	return(id)
end
*/
#endif



///////////////////////////////////////////////////////////////////////////
// Helper Functions

integer proc IsSpecialFile(string s)
	integer ii

	if not Length(s)
		return(FALSE)
	endif

	ii = Pos(s[1], "[$")
	if not ii
		return(FALSE)
	endif

	if ii <> Pos(s[Length(s)], "]$")
		return(FALSE)
	endif

	if ii == 1
		if s == "[<stdin>]"
			return(FALSE)
		endif
	endif

	return(TRUE)
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


integer proc OnOrOff(string st, var integer i)
	if (Length(st) > i) and (st[i+1] == "-")
		i = i + 1
		return (FALSE)
	endif
	return (TRUE)
end


proc ClearKey()
	#ifdef WIN32
	Set(Key, -1)
	#else
	Set(Key, 0)
	#endif
end


proc Context(integer n, integer fDown, integer id)
	integer i

	PushPosition()
	for i = 1 to n
		if not iif(fDown, Down(), Up())
			break
		endif
		if fDown
			// AddLine(Format(CurrLine():6, '  ',
			AddLine(Format(CurrLine():10, '  ',
					GetText(1, CurrLineLen())), id)
		else
			// InsertLine(Format(CurrLine():6, '  ',
			InsertLine(Format(CurrLine():10, '  ',
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
		UpdateHistoryStr(GetProfileStr(section, GrepOptions, "vm", iniFileNameGS ), hist_opts)
		UpdateHistoryStr(GetProfileStr(section, GrepExclude, stDefExcl, iniFileNameGS ), hist_excl)
		#ifdef CONTEXT_WINDOW
		g_fCtxWin = GetProfileInt(section, GrepCtxWin, TRUE, iniFileNameGS )
		#endif
	else
		WriteProfileStr(section, GrepOptions, g_opts, iniFileNameGS )
		WriteProfileStr(section, GrepExclude, g_excl, iniFileNameGS )
		#ifdef CONTEXT_WINDOW
		WriteProfileInt(section, GrepCtxWin, g_fCtxWin, iniFileNameGS )
		#endif
	endif

	#ifndef WIN32
	Set(Query(MacroCmdLine), GetGlobalStr(c_stTmpStr))
	DelGlobalVar(c_stTmpStr)
	#endif
end


proc mHelp(string topic)
	ExecMacro("gethelp -fgrep.hlp "+topic)
end


integer proc QuotedArg(string quote, var string s, var string arg)
	integer i
	integer j

	arg = ""
	// is arg quoted with <quote>?
	i = Pos(s[1], quote)
	if i
		// remove beg-quote from temp
		s = DelStr(s, 1, 1)
		j = Pos(quote[i], s)
		if j
			// get quoted arg
			arg = s[1:j-1]
			if j == Length(s) or (j < Length(s) and s[j+1] == " ")
				// remove arg, end-quote, and space from temp
				s = DelStr(s, 1, Length(arg)+2)
				return(TRUE)
			else
				Warn("Quoted argument improperly formed.")
			endif
		else
			Warn("Argument missing end-quote.")
		endif
	endif
	return(FALSE)
end


proc NormalArg(var string s, var string arg)
	integer iPos = Pos(' ', s)

	arg = s
	if iPos
		arg = SubStr(arg, 1, iPos - 1)
		s = SubStr(s, iPos + 1, Length(s) - iPos)
	else
		s = ""
	endif
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


// AppendToBuffer()
// appends st to buffer id, returns line number of newly appended line, or 0
// if id is not a valid buffer.
integer proc AppendToBuffer(integer id, string st)
	integer cid
	integer nLine = 0

	cid = GotoBufferId(id)
	if cid
		PushPosition()
		EndFile()
		AddLine(st)
		BegLine()
		nLine = CurrLine()
		PopPosition()
		GotoBufferId(cid)
	endif
	return(nLine)
end


proc SortBuffer(integer id, integer flag)
	integer cid = GetBufferId()

	if id
		GotoBufferId(id)
	endif
	if NumLines()
		PushBlock()
		MarkLine(1, NumLines())
		Set(MsgLevel, _NONE_)
		Sort(flag)
		Set(MsgLevel, _ALL_MESSAGES_)
		PopBlock()
	endif
	GotoBufferId(cid)
end


proc BuildList(integer id_files, string path, string wilds, integer pff)
	integer oldpff
	string oldpfso[10]
	string stFind[255] = path
	integer ii
	integer fMatch

	if Length(wilds)
		stFind = stFind + "*.*"
	endif

	GotoBufferId(id_files)
	EmptyBuffer()

#if 0
Message("build: [", stFind, "]")
if KeyPressed()
	return()
endif
Delay(18)
#endif
	oldpff = Set(PickFileFlags, pff)
	BuildPickBufferEx(stFind, _ATTRS)
	Set(PickFileFlags, oldpff)

	if Length(wilds)
		BegFile()
		do NumLines() times
			fMatch = FALSE
			for ii = 2 to NumTokens(wilds, Chr(1))
				if MatchFilename(PBName(), GetToken(wilds, Chr(1), ii))
					fMatch = TRUE
#if 0
Message("yes - ", PBName(), " - ", GetToken(wilds, Chr(1), ii))
if KeyPressed()
	BegFile()
	return()
endif
Delay(12)
#endif
					break
				endif
			endfor
			if fMatch
				Down()
			else
				KillLine()
			endif
		enddo
	endif

	oldpfso = Set(PickFileSortOrder, "f")
	SortBuffer(0, _PICKSORT_)
	Set(PickFileSortOrder, oldpfso)

	BegFile()
end



///////////////////////////////////////////////////////////////////////////
// Prompt Helpers

string s_stOpts[20]
integer s_idPrompt


string proc CheckBoxStr(integer f)
	return(iif(f, "þ", " "))
end


proc Footer_Opts()
	WindowFooter(Format(" {^I}-Ignore case [", CheckBoxStr(Pos("i", s_stOpts)),
			"]  {^X}-regExp [", CheckBoxStr(Pos("x", s_stOpts)),
			"]  {^W}-Word [", CheckBoxStr(Pos("w", s_stOpts)),
			"] "))
end


proc ToggleOpts(string opt, var string option)
	integer ich

	ich = Pos(opt, option)
	if ich
		option = DelStr(option, ich, 1)
	else
		option = opt + option
	endif
	Footer_Opts()
end


keydef PromptKeys
<Ctrl i>	ToggleOpts("i", s_stOpts)
<Ctrl x>	ToggleOpts("x", s_stOpts)
<Ctrl w>	ToggleOpts("w", s_stOpts)
end


proc DeferEnableKeys()
	if Enable(PromptKeys)
		Footer_Opts()
	endif
	UnHook(DeferEnableKeys)
end


proc OnPromptStartup()
	s_idPrompt = GetBufferId()
	// override keydefs by other macros (won't necessarily work against other
	// macros that also defer enabling keydefs, though).
	Hook(_NONEDIT_IDLE_, DeferEnableKeys)
end


proc OnPromptCleanup()
	if s_idPrompt == GetBufferId()
		Disable(PromptKeys)
		UnHook(DeferEnableKeys)
	endif
end


integer proc SearchFor(string path, var string word, var string opts)
	integer fOk = FALSE

	s_stOpts = opts
	Hook(_PROMPT_STARTUP_, OnPromptStartup)
	Hook(_PROMPT_CLEANUP_, OnPromptCleanup)
	fOk = Ask("Search for: ["+path+"]", word, _FIND_HISTORY_)
	UnHook(OnPromptCleanup)
	UnHook(OnPromptStartup)
	opts = s_stOpts
	return (fOk)
end



///////////////////////////////////////////////////////////////////////////
// Paragraph/Function Helpers

#ifdef WIN32
// mMatch
// matches (){}[]<> chars.
// NOTE:  gets confused by (){}[]<> inside of quotes
string match_chars[] = "(){}[]<>"   // pairs of chars to match
integer proc mMatch()
	integer p, level
	integer mc, ch
	integer start_line = CurrLine(), start_row = CurrRow()

	p = Pos(chr(CurrChar()), match_chars)
	// If we're not already on a match char, go forward to find one
	if p == 0 and lFind("[(){}[\]<>]", "x")
		ScrollToRow(CurrLine() - start_line + start_row)
		return (FALSE)
	endif

	PushPosition()
	if p
		ch = asc(match_chars[p])		// Get the character we're matching
		mc = asc(match_chars[iif(p&1, p+1, p-1)])	// And its reverse
		level = 1						// Start out at level 1

		while lFind("[\" + chr(ch) + "\" + chr(mc) + "]", iif(p & 1, "x+", "xb"))
			case CurrChar()				// And check out the current character
				when ch
					level = level + 1
				when mc
					level = level - 1
					if level == 0
						KillPosition()			// Found a match, remove position
						GotoXoffset(0)			// Fix up possible horizontal scrolling
						ScrollToRow(CurrLine() - start_line + start_row)
						return (TRUE)			// And return success
					endif
			endcase
		endwhile
	endif
	PopPosition()						// Restore position
	return (FALSE)
end
#endif


// IsSupportedFileType()
// used by GetFunctionName to decide whether to look for a function name
integer proc IsSupportedFileType(string ext)
	return (Length(ext) and
			Pos(ext+".", ".c.cpp.cxx.s.si.ui.asm.inc.pas.prg.bas.ini."))
end


// GetFunctionStr()
// gets regex search string based on file type, returns index of token that
// represents function name in search string, or returns -1 if the search
// string does not contain such a token.
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
			//expr = "^{[~ \t]*[ \t]*}?[a-zA-Z_~][a-zA-Z0-9_* \t~]@{::[a-zA-Z_~][a-zA-Z0-9_* \t~]@}?{[~=;/]*([~;:/]@}|{[~=;:/]@}{//.@}?$"
			expr = "{^STDMETHOD.*(.+)[ \t]+}|{^{[~ \t]*[ \t]*}?[a-zA-Z_~][a-zA-Z0-9_* \t~]@{::[a-zA-Z_~][a-zA-Z0-9_* \t~]@}?{[~=;/]*([~;:/]@}|{[~=;:/]@}{//.@}?$}"
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


#ifdef WIN32
proc FindBlankLine(integer dir)
	while iif(dir, Down(), Up()) and PosFirstNonWhite()
	endwhile
end


proc FindNonBlankLine(integer dir)
	while iif(dir, Down(), Up()) and not PosFirstNonWhite()
	endwhile
end
#endif


// FindFunc()
// find next/prev function beginning.  for performance reasons, it sets a 1000
// line range to search in.
integer proc FindFunc(integer next)
	string opt[1], s[255] = ""
	integer fRet = FALSE

	GetFunctionStr(CurrExt(), s)
	if Length(s)
		PushPosition()

		if not next
			BegLine()
			opt = 'b'
		else
			EndLine()
			opt = ''
		endif

		PushBlock()
		MarkLine(CurrLine(), iif(next, CurrLine()+1000, CurrLine()-1000))
		fRet = lFind(s, "ilx+" + opt)
		PopBlock()

		if fRet
			KillPosition()
		else
			PopPosition()
		endif
	endif
	return (fRet)
end


// mBegFunc()
// find beginning of function
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


#ifdef WIN32
// mEndFunc()
// find end of function
proc mEndFunc()
	integer row = CurrRow(), cline = CurrLine()
	string s[255] = ""
	integer fFound = FALSE

	PushPosition()
	GetFunctionStr(CurrExt(), s)

	if not FindFunc(TRUE)
		EndFile()
		repeat until CurrLine() <= cline or PosFirstNonWhite() or not Up()
	endif

	if Length(s)
		FindFunc(FALSE)
		BegLine()
		if Pos(CurrExt()+".", ".s.si.ui.inc.")
			fFound = lFind("proc", "wi") and lFind("[ \t]*end", "^xiw")
		elseif Pos(CurrExt()+".", ".asm.inc.")
			fFound = lFind("{proc}|{macro}", "wi") and
					lFind("[A-Za-z_0-9]*[ \t]*{endp}|{endm}", "^xiw")
		elseif Pos(CurrExt()+".", ".c.h.cpp.hpp.cxx.hxx.")
			fFound = lFind("{", "") and mMatch()
		else
			fFound = TRUE				// perhaps a bit optimistic, no?
			FindBlankLine(FALSE)
			FindNonBlankLine(FALSE)
		endif
	endif

	if fFound
		KillPosition()
	else
		PopPosition()
	endif

	// hold screen still unless we went off screen
	row = row + CurrLine() - cline
	if row < 1 or row > Query(WindowRows)
		ScrollToRow((Query(WindowRows)*4)/5)
	else
		ScrollToRow(row)
	endif
end
#endif


// ExtractFilename()
// return filename; must be called from a line that starts with the filename
// prefix (eg, "File: ").
string proc ExtractFilename()
	string path[MAXPATH]
#if 0
	integer ich
#endif

	path = GetFileToken(GetText(Length(prefix)+1, sizeof(path)), 1)
#if 0
	ich = Pos(Chr(0), path)
	if ich
		path = SubStr(path, 1, ich)
	endif
	path = Trim(path)
#endif
	if path[Length(path)-Length(c_stLoaded)+1:Length(c_stLoaded)] == c_stLoaded
		path = path[1:Length(path)-Length(c_stLoaded)]
	endif
#if 0
	path = Trim(path)
#endif
	return(path)
end


// GetFunctionName()
// returns name of function.  it does a decent job, but don't expect miracles!
string proc GetFunctionName()
	string expr[255] = ""
	string ws[32]
	integer i = CurrLine()

	PushPosition()

	// check if we support this file type
	if not IsSupportedFileType(CurrExt())
		// not a supported file extension
		goto Out
	endif

#ifdef WIN32
	// is the line in a function?
	mEndFunc()
	if CurrLine() < i
		goto Out
	endif
	mBegFunc()
	if CurrLine() > i
		goto Out
	endif
#else
	mBegFunc()
#endif

	// line is in a function; get name of function
	i = GetFunctionStr(CurrExt(), expr)
	if Length(expr)
		if lFind(expr, "gxc")
			if i == -1
				// special methods for extracting function names
				case CurrExt()
					// C/C++ is darn complicated
					when ".c",".cpp",".h",".hpp",".cxx",".hxx"
						EndLine()
						lFind("//", "bc")
						ws = Set(WordSet, ChrSet("A-Za-z_0-9<>:"))
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

Out:
	PopPosition()
	return(expr)
end



///////////////////////////////////////////////////////////////////////////
// Context Window

#ifdef CONTEXT_WINDOW

proc SetWindow(integer x1, integer y1, integer cols, integer rows)
#ifdef CWBORDER
	Window(x1+1, y1+1, x1+cols-2, y1+rows-2)
#else
	Window(x1, y1+1, x1+cols-1, y1+rows-1)
#endif
end


#ifdef CWBORDER
proc DrawWindow(integer x1, integer y1, integer cols, integer rows,
		integer boxtype, string path, integer attr, integer line, string func)
#else
proc DrawWindow(integer x1, integer y1, integer cols, integer rows,
		string path, integer attr, integer line, string func)
#endif

	#ifdef WIN32
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
#endif
	SetWindow(x1, y1, cols, rows)

	#ifdef WIN32
	UnBufferVideo()
	#endif
end


integer g_fCloseWhenDone = TRUE
integer g_idContextFile = 0
integer g_nColOfs = 0
integer g_nRowOfs = 0
integer g_nRowOfsFresh = 0
integer g_nColOfsPrev = 0
integer g_nRowOfsPrev = 0
proc NonEditIdle()
	integer a, b, c, d
	integer ln
	string path[255]
	string func[80]
	integer cid
	integer i
	integer rowofsprev = g_nRowOfsPrev
	integer colofsprev = g_nColOfsPrev
	integer fLnOK = FALSE
	integer fColOfsChanged = g_nColOfs <> g_nColOfsPrev
	integer fRowOfsChanged = g_nRowOfs <> g_nRowOfsPrev
	integer x, y
	integer ii

	if g_nCtxLine <> CurrLine() or fRowOfsChanged or fColOfsChanged
		if g_nCtxLine <> CurrLine()
			fLnOK = TRUE
			#ifdef CWBORDER
			g_nRowOfs = -(cyCtxWin-2)/3
			#else
			g_nRowOfs = -cyCtxWin/3
			#endif
			g_nRowOfsFresh = g_nRowOfs
			g_nColOfs = 0
		endif
		g_nRowOfsPrev = g_nRowOfs
		g_nColOfsPrev = g_nColOfs

		// get line number
		// ln = Val(GetText(1, 8))
		ln = Val(GetText(1, 20))

		// get filename
		PushPosition()
		EndLine()
		if not lFind(prefix, "^b")
			PopPosition()
			UnHook(NonEditIdle)
			return()
		endif
		path = ExtractFilename()
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
			if not CreateBuffer(path, _HIDDEN_)
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

		// verify row offset is within bounds
		if ln + g_nRowOfs < 1
			g_nRowOfs = 1 - ln
		elseif ln + g_nRowOfs > NumLines()
			g_nRowOfs = NumLines() - ln
		endif
		g_nRowOfsPrev = g_nRowOfs
		g_nColOfsPrev = g_nColOfs
		if not fLnOK and rowofsprev == g_nRowOfs and colofsprev == g_nColOfs
			// don't abandon file
			GotoBufferId(cid)
			return()
		endif

		// go to line
		PushPosition()
		GotoLine(ln)

		// remember current window coordinates
		a = Query(PopWinX1)
		b = Query(PopWinY1)
		c = Query(PopWinCols)
		d = Query(PopWinRows)

		#ifdef WIN32
		BufferVideo()
		#endif

		if fLnOK or fRowOfsChanged
			// get function name
			GotoLine(ln + g_nRowOfs - g_nRowOfsFresh)
			func = GetFunctionName()
			GotoLine(ln)

			// draw context window
			#ifdef CWBORDER
			DrawWindow(1, Query(ScreenRows)-cyCtxWin+1,
					Query(ScreenCols), cyCtxWin,
					//Query(CurrWinBorderType), path,
					1, path,
					Query(CurrWinBorderAttr), ln + g_nRowOfs - g_nRowOfsFresh, func)
			#else
			DrawWindow(1, Query(ScreenRows)-cyCtxWin+1,
					Query(ScreenCols), cyCtxWin,
					path, Query(StatusLineAttr), ln + g_nRowOfs - g_nRowOfsFresh, func)
			#endif
		else
			SetWindow(1, Query(ScreenRows)-cyCtxWin+1,
					Query(ScreenCols), cyCtxWin)
		endif

		Set(Attr, Query(MsgAttr))
		ClrScr()

		// get lines and draw them
		BegLine()
		GotoLine(ln + g_nRowOfs)
		for i = 1 to Query(PopWinRows)
			if ln == CurrLine()
				Set(Attr, Query(HiLiteAttr))
			else
				Set(Attr, Query(MsgAttr))
			endif
			VGotoXY(1, i)

			// draw line
			BegLine()
			if Query(ExpandTabs)
				// expand tabs
				path = ""
				GotoColumn(1 + g_nColOfs)
				if CurrChar() == 9 and CurrCol() < 1 + g_nColOfs
					path = Format("":(DistanceToTab(TRUE) - ((1+g_nColOfs)-CurrCol())):" ")
					Right()
				endif
				while CurrChar() >= 0 and Length(path) < Query(PopWinCols)
					if CurrChar() == 9
						path = path + Format("":DistanceToTab(TRUE):" ")
					else
						path = path + Chr(CurrChar())
					endif
					Right()
				endwhile
			else
				path = GetText(1 + g_nColOfs, 255)
			endif
			PutLine(path, Query(PopWinCols))
			if not Down()
				break
			endif
		endfor

		#ifdef CWBORDER
		// draw indicators
		i = Query(PopWinRows)
		x = Query(PopWinX1) + Query(PopWinCols)
		y = Query(PopWinY1)
		Window(1, 1, Query(ScreenCols), Query(ScreenRows))

		// draw indicator to show what line we'll jump to if user hits <Enter>
		Set(Attr, Query(CurrWinBorderAttr))
		#if 0
		VGotoXYAbs(1, y)
		PutCharV("³", i)	//$ review: what about other border types?
		VGotoXYAbs(1, y - g_nRowOfsFresh)
		PutChar("")
		#else
		for ii = y to y + i - 1
			mPutOemStrXY(1, ii, "³", Query(Attr), FUse3D())	//$ review: what about other border types?
		endfor
		mPutOemStrXY(1, y - g_nRowOfsFresh, "", Query(Attr), FALSE)
		#endif

		// draw "percentage meter"...

		// draw bar
		Set(Attr, Query(CurrWinBorderAttr))
		#if 0
		VGotoXYAbs(x, y)
		//PutCharV("°", i)
		PutCharV("³", i)
		#else
		for ii = y to y + i - 1
			mPutOemStrXY(x, ii, "³", Query(Attr), FUse3D())	//$ review: what about other border types?
		endfor
		#endif

		// draw thumb button
		Set(Attr, Query(StatusLineAttr))
		#if 0
		VGotoXYAbs(x, y - 1 + iif(NumLines() <= i, 1,
				(min(1 + ((ln+g_nRowOfs)*i-1) / (NumLines() - (i + 1)), i))))
		//PutChar(iif(fDragging, "", "Û"))
		//PutChar("Û")
		PutChar("þ")
		#else
		mPutOemStrXY(x, y - 1 + iif(NumLines() <= i, 1,
				(min(1 + ((ln+g_nRowOfs)*i-1) / (NumLines() - (i + 1)), i))), "þ", Query(Attr), FALSE)
		#endif
		#else // !CWBORDER
		// shut up the compiler
		x = 1
		y = 1
		x = x
		y = y
		#endif // !CWBORDER

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



///////////////////////////////////////////////////////////////////////////
// Key Handlers

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



///////////////////////////////////////////////////////////////////////////
// List Enhancements

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
		until (not KillLine() or
			   not (CurrChar(1) in Asc(' '), Asc('0')..Asc('9')) or
			   GetText(1, Length(prefix)) == prefix)
#if 0
		if GetText(1, Length(prefix)) <> prefix
			lFind(prefix, "^b")
			ScrollToCenter()
		endif
#endif
	elseif CurrChar(1) in Asc(' '), Asc('0')..Asc('9')
		// just delete this match
		KillLine()
	endif
	g_nCtxLine = 0
	FileChanged(fChanged)
end


#ifdef CONTEXT_WINDOW
proc Context_VScroll(integer fDown)
	if g_fCtxWin
		if fDown
			g_nRowOfs = g_nRowOfs - 1
		else
			g_nRowOfs = g_nRowOfs + 1
		endif
		NonEditIdle()
	endif
end
proc Context_HScroll(integer fLeft)
	if g_fCtxWin
		if fLeft
			g_nColOfs = g_nColOfs - 1
			if g_nColOfs < 0
				g_nColOfs = 0
			endif
		else
			g_nColOfs = g_nColOfs + 1
		endif
		NonEditIdle()
	endif
end
proc Context_BegLine()
	if g_fCtxWin
		g_nColOfs = 0
		NonEditIdle()
	endif
end
#endif


#define DBLCLK_TIME 5
integer dblclk_tick = 0

proc ListLeftBtn()
	#ifdef CONTEXT_WINDOW
	if g_fCtxWin and Query(MouseY) > Query(WindowY1)+Query(WindowRows)
		EndProcess(TRUE)
	else
	#endif
		case MouseHotSpot()
			when _MOUSE_MARKING_
				PushPosition()
				GotoMouseCursor()
				if Query(MouseY) == Query(WindowY1)+CurrRow()-1
					UpdateDisplay()
					KillPosition()
					if dblclk_tick and Query(LastMouseX) == Query(MouseX) and
							Query(LastMouseY) == Query(MouseY)
						if Abs(GetClockTicks() - dblclk_tick) <= DBLCLK_TIME
							EndProcess(TRUE)
						endif
						dblclk_tick = 0
					else
						dblclk_tick = GetClockTicks()
					endif
				else
					PopPosition()
				endif
			otherwise
				ProcessHotSpot()
		endcase
	#ifdef CONTEXT_WINDOW
	endif
	#endif
end


keydef ListKeys
<Shift PgDn>			gotoFile(TRUE, TRUE)
<Shift PgUp>			gotoFile(FALSE, TRUE)
//<Shift GreyPgDn>		gotoFile(TRUE, TRUE)
//<Shift GreyPgUp>		gotoFile(FALSE, TRUE)
<Del>					DelThis()
//<GreyDel>				DelThis()
<Alt E>					EndProcess(TRUE)
<Alt L>					EndProcess(TRUE)
<Ctrl Enter>			EndProcess(TRUE)
<F1>					mHelp("Grep List")
<F5>					EndProcess(TRUE)
<Alt ,>					EndProcess(TRUE)
<Alt .>					EndProcess(TRUE)
<Alt CursorLeft>		EndProcess(TRUE)
<Alt CursorRight>		EndProcess(TRUE)
<Alt GreyCursorLeft>	EndProcess(TRUE)
<Alt GreyCursorRight>	EndProcess(TRUE)
<Ctrl [>				EndProcess(TRUE)
<Ctrl ]>				EndProcess(TRUE)
<Ctrl C>				EndProcess(TRUE)
#ifdef CONTEXT_WINDOW
<Ctrl CursorUp>			Context_VScroll(TRUE)
<Ctrl CursorDown>		Context_VScroll(FALSE)
<Ctrl CursorLeft>		Context_HScroll(TRUE)
<Ctrl CursorRight>		Context_HScroll(FALSE)
<CtrlShift Home>		Context_BegLine()
#endif
<LeftBtn>				ListLeftBtn()
#ifdef DEBUG
<F12>					EndProcess(TRUE)
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



///////////////////////////////////////////////////////////////////////////
// Functions

// FWildMatch()
// compares filename to wildcard
integer proc FWildMatch(string filename, string wildcard)
	integer i = 1, j = 1
	string f[_MAXPATH_] = Lower(filename)
	string w[_MAXPATH_] = Lower(wildcard)

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


// FExclude can nest @ signs to 4 levels (prevents infinite loops!)
integer cRecursed = 0

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
				//if FWildMatch(SplitPath(f, _NAME_|_EXT_), token)
				if MatchFilename(SplitPath(f, _NAME_|_EXT_), token)
					return (TRUE)
				elseif (Pos("\", f) or Pos("/", f)) and FWildMatch(f, token)
					return (TRUE)
				endif
			else
				if Lower(ExpandPath(f)) == Lower(ExpandPath(token))
					return (TRUE)
				endif
			endif
		endif
	endfor

	return (FALSE)
end


integer lasttick = 0
integer proc InteractiveKeys()
	if not g_fIdleSearching
		if GetClockTicks() - lasttick > KBD_RESPONSE_TIME or
				GetClockTicks() < lasttick
			lasttick = GetClockTicks()
			if KeyPressed()
				case GetKey()
					when <Ctrl C>, <Escape>, 0
						return (FALSE)

					when <v>,<V>,<Shift V>,<Ctrl V>
						g_fVerbose = not g_fVerbose
						// toggle verbose
				endcase
			endif
		endif
	endif

	return (TRUE)
end


// SearchFile()
// search current buffer for needle
// returns FALSE if aborted via <Ctrl C>, <Escape>, or <Ctrl Break>
integer proc SearchFile(string expr, string opts, integer id, var integer n, integer fQuiet, integer fWasOpen)
	string s[255]
	integer i, j = 0
	integer nThisFile = 0
	integer nFileLine = 0
	integer cid
	integer fReturn = FALSE

	if not InteractiveKeys()
		goto LOut
	endif

	if not IsSpecialFile(CurrFilename())
		PushPosition()
		BegFile()
#if 0
if not GetGlobalInt("FooGrep")
	Message(opts, "³", expr, "³ ", CurrFilename())
	if GetKey() == <spacebar>
		SetGlobalInt("FooGrep", TRUE)
	endif
endif
#endif
		if lFind(expr, opts)
			s = CurrFilename()
			if fWasOpen
				// drat, in order for this to show up, we have to quote it as
				// part of the filename.  oh well!
				s = s + c_stLoaded
			endif

			// IMPORTANT -- function list looks for Chr(0) to update number of
			// occurrences.
			s = prefix + QuotePath(s) + Chr(0)

			cid = GotoBufferId(id)
			if cid
				PushPosition()
				EndFile()
				AddLine(s, id)
				nFileLine = CurrLine()
				PopPosition()
				GotoBufferId(cid)
			endif

			if not fQuiet
				//if g_fVerbose
					Set(Attr, Color(bright yellow on black))
					WriteLine(s)
					Set(Attr, Color(bright white on black))
				//endif
			endif

			if g_fFilenamesOnly
				n = n + 1
				goto LOut
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

				// add match to results buffer
				// i = AppendToBuffer(id, Format(CurrLine():6, ': ',
				i = AppendToBuffer(id, Format(CurrLine():10, ': ',
											  GetText(1, CurrLineLen())))

				// record which line to highlight in results list
				if g_cid == GetBufferId() and CurrLine() <= g_startlineno
					g_lineno = i
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
					// WriteLine(CurrLine():6, ': ', s)
					WriteLine(CurrLine():10, ': ', s)
				endif

				if not InteractiveKeys()
					PopPosition()
					goto LOut
				endif

				// prevent multiple matches on same line
				EndLine()
			until not lRepeatFind()

			cid = GotoBufferId(id)
			PushPosition()
			GotoLine(nFileLine)
			EndLine()
//			InsertText(Format(Str(nThisFile)+" occurrences found":
//					Query(ScreenCols)-2-CurrLineLen()))
			InsertText(" "+Str(nThisFile)+" occurrences found")
			PopPosition()
			GotoBufferId(cid)
		endif
		PopPosition()
	endif

	fReturn = TRUE

LOut:
	return (fReturn)
end



///////////////////////////////////////////////////////////////////////////
// Result History

constant whatID = 0						// must be 0
constant whatNeedle = 1
constant whatOpts = 2
constant whatFilespec = 3
constant whatExclude = 4
constant whatFlags = 5
constant whatMAX = 6

integer g_idHistory
integer g_iHistory						// 0 == current


string proc GetFromHistory(integer what)
	string s[255] = ""
	integer cid

	cid = GotoBufferId(g_idHistory)
	if cid
		GotoLine(1 + g_iHistory*whatMAX + what)
		s = GetText(1, 255)
		GotoBufferId(cid)
	endif
	return(s)
end


integer proc UseHistory(integer i)
	integer cid
	integer f = FALSE

	cid = GotoBufferId(g_idHistory)
	if cid
		if i >= 0 and i < NumLines()/whatMAX
			g_iHistory = i
			g_idFound = Val(GetFromHistory(whatID))
			g_stTitle = GetFromHistory(whatNeedle)
			f = TRUE
		endif
		GotoBufferId(cid)
	endif
	return(f)
end


integer proc KillHistory(integer i, integer fAbandon)
	integer cid
	integer f = FALSE

	cid = GotoBufferId(g_idHistory)
	if cid
		if NumLines()/whatMAX > i
			GotoLine(1 + i*whatMAX)
			if (fAbandon)
				AbandonFile(Val(GetText(1, 12)))
			endif
			KillLine(whatMAX)
			f = TRUE

			if i == g_iHistory
				UseHistory(g_iHistory - 1)
			endif
		endif
		GotoBufferId(cid)
	endif
	return(f)
end


proc AddHistory(integer id, string needle, string opts, string filespec, string exclude, integer flags)
	integer cid

	cid = GotoBufferId(g_idHistory)
	if cid
		if flags & _REFRESH
			// remove current history info
			GotoLine(1 + g_iHistory*whatMAX)
			KillLine(whatMAX)
			// don't kill associated buffer; we're refreshing into it!
		else
			// remove histories:  if user went Back a few, remove ones "forward"
			// from the current one, like Internet Explorer does when you use the
			// Back/Forward commands.
			GotoLine(1 + g_iHistory*whatMAX)
			PushBlock()
			UnMarkBlock()
			BegLine()
			MarkChar()
			BegFile()
			MarkChar()
			if isBlockMarked()
				KillBlock()
			endif
			PopBlock()

			// add new history at beginning
			g_iHistory = 0
			BegFile()
		endif

		// insert history info
		InsertLine(Str(id))
		AddLine(needle)
		AddLine(opts)
		AddLine(filespec)
		AddLine(exclude)
		AddLine(Str(flags & ~_REFRESH))

		// truncate list to 10 max
		while KillHistory(10, TRUE)
		endwhile

		GotoBufferId(cid)
	endif
end



///////////////////////////////////////////////////////////////////////////
// Idle Search

integer m_fSearchLoadedFiles
integer m_fSubDirs
integer m_fVerbose
integer m_idFound = 0
integer m_idSearch = 0
integer m_idFiles = 0
string m_stNeedle[255]
string m_stExclude[MAXPATH]
string m_stOpts[40]
string m_stPath[MAXPATH]

integer m_nSearchedFiles = 0
integer m_nFound = 0

integer m_fFoundCurrLine = FALSE

integer m_hh, m_mm, m_ss, m_hun

forward proc IdleSearch()
forward proc NonEditIdleSearch()


string proc GetElapsed()
	string s[60]
	integer hh, mm, ss, hun

	GetTime(hh, mm, ss, hun)

	hun = hun - m_hun
	if hun < 0
		hun = hun + 100
		ss = ss - 1
	endif
	ss = ss - m_ss
	if ss < 0
		ss = ss + 60
		mm = mm - 1
	endif
	mm = mm - m_mm
	if mm < 0
		mm = mm + 60
		hh = hh - 1
	endif
	hh = hh - m_hh
	s = Format("(Elapsed time";
			   hh, ":", mm:2:"0", ":", ss:2:"0", ".", hun:2:"0", ",";
			   m_nSearchedFiles;
			   "file", iif(m_nSearchedFiles == 1, "", "s");
			   "searched)")

	return (s)
end


#define sisNone				0
#define sisFinished			1
#define sisAbort			2
#define sisError			3
string c_stSIS[] = "<Finished>$<Terminated>$<Error>"
proc StopIdleSearch(integer sis)
	string s[32] = ""

	#ifdef DEBUG
	Assert((sis in sisFinished, sisAbort, sisError),
		   Format("StopIdleSearch: illegal value for sis (",sis,")"))
	#endif

	if g_fIdleSearching
		// stop any idle search in progress and clean up after it
		g_fIdleSearching = FALSE
		UnHook(IdleSearch)
		UnHook(NonEditIdleSearch)

		AppendToBuffer(m_idFound, GetToken(c_stSIS, "$", sis))
		if sis == sisFinished
			if not g_fInShowResults
				s = "GREP: "
			endif

			if Query(Beep)
				Alarm()
			endif

			if m_nFound
				Message(s, m_nFound; "occurrences found.  ", GetElapsed())
			else
				Message(s, "Not found.  ", GetElapsed())
			endif

			//$ review: delay for a moment to ensure visibility?
		endif

		AbandonFile(m_idSearch)
		AbandonFile(m_idFiles)

		m_idFound = 0
		m_idSearch = 0
		m_idFiles = 0

		UpdateDisplay()
	endif
end


// IdleSearch()
// does grep in _IDLE_
#define MAXSEARCHBYTES		(100*1024)
#define MAXSEARCHFILES		(10)
#define MAXPARSEDDIRS		(10)
proc IdleSearch()
	string s[MAXPATH]
	string stWild[MAXPATH]
	integer cid = GetBufferId()
	integer id
	integer idWasOpen
	integer i
	integer sis = sisNone
	integer cbSearched
	integer cFilesSearched
	integer cDirectoriesParsed
	integer idTmp = 0
	integer hs
	string wilds[255]

	// search at least one file each _IDLE_ event, or build list of files in
	// the next path being searched.
	repeat
		cid = GotoBufferId(m_idFiles)
		if not cid
			sis = sisError
			break
		endif

		cbSearched = 0
		cFilesSearched = 0
		cDirectoriesParsed = 0
		while NumLines() == 0 and cDirectoriesParsed < MAXPARSEDDIRS and sis == sisNone
			// no files to search, get next path
			GotoBufferId(m_idSearch)
			if NumLines()
//Message(NumLines())
				// get next path spec
				BegFile()
				m_stPath = GetText(1, sizeof(m_stPath))
				wilds = ""
				i = Pos(Chr(1), m_stPath)
				if i
					m_stPath = m_stPath[1 : i - 1]
					wilds = GetText(i, sizeof(wilds))
				endif
				//nSearchedPaths = nSearchedPaths + 1
				KillLine()

				// search path spec
				if Length(wilds)
					stWild = wilds
				else
					stWild = SplitPath(m_stPath, _NAME_|_EXT_)
				endif
				s = m_stPath
				m_stPath = SplitPath(ExpandPath(m_stPath), _DRIVE_|_PATH_)
				if g_fInShowResults and (m_fVerbose or not cDirectoriesParsed)
					Message("Searching ", SqueezePath(AddTrailingSlash(m_stPath), Query(ScreenCols)-10))
				endif
				cDirectoriesParsed = cDirectoriesParsed + 1
				BuildList(m_idFiles, s, wilds, _NONE_)

				//$ todo: THIS IS CURRENTLY VERY INEFFICIENT!  SHOULD GRAB ALL
				// WILDCARDS FOR THE CURRENT PATH AND ADD ALL FOR A GIVEN PATH
				// AT ONCE, INSTEAD OF N*M ITERATIONS THRU IT!

				// enumerate subdirectories
				if m_fSubDirs
#ifdef DEBUG
					Assert(not idTmp, "going to leak idTmp")
#endif
if idTmp
	Warn("IdleSearch: going to leak idTmp!")
endif
					idTmp = CreateTempBuffer()
					if idTmp
						GotoBufferId(m_idSearch)
						EndFile()
						GotoBufferId(idTmp)
						BuildList(idTmp, m_stPath+"dummyf.ile", "", _ADD_DIRS_)
						i = 0
						do NumLines() times
							s = PBName()
							if PBAttribute() & _DIRECTORY_ and
									s <> "." and s <> ".." and
									not FExclude(Trim(m_stPath+s), m_stExclude, TRUE)
									and not FExclude(Trim(s), m_stExclude, TRUE)
								#ifdef DEBUG
								Message("directory"; s)
								Delay(8)
								#endif
								// record directories in the dir buffer
								GotoBufferId(m_idSearch)
								AddLine(AddTrailingSlash(Trim(m_stPath+s)))
								EndLine()
								InsertText(stWild, _INSERT_)
#if 0
if not KeyPressed()
	Message(stWild)
	Delay(6)
endif
#endif
								GotoBufferId(idTmp)
								//InsertLine(Trim(m_stPath+s)+"\"+stWild, m_idSearch)
								i = i + 1
							endif
							Down()
						enddo

#if 0
						if i
							i = GotoBufferId(m_idSearch)
							SetHookState(off)
							list("m_idSearch", query(ScreenCols)-8)
							SetHookState(on)
							GotoBufferId(i)
						endif
#endif
#if 0
						if i
							// force directories into alphabetical order
							SortBuffer(m_idSearch, _IGNORE_CASE_)
						endif
#endif
						GotoBufferId(m_idFiles)
						AbandonFile(idTmp)
						idTmp = 0
					else
						sis = sisError
					endif
				endif
			else
				sis = sisFinished
			endif
			GotoBufferId(m_idFiles)
		endwhile

		if NumLines()
			// search at least one file each _IDLE_ event
			repeat
				s = PBName()
				m_nSearchedFiles = m_nSearchedFiles + 1
				cFilesSearched = cFilesSearched + 1

				// progress info (when in ShowResults list, if verbose or this
				// is the first file being searched during this _IDLE_ event).
				if g_fInShowResults and (m_fVerbose or not cbSearched)
//					Message("Searching ", Trim(m_stPath+s), "...")
					Message("Searching ", SqueezePath(m_stPath+s, Query(ScreenCols)-10))
				endif

				// allow up to <n> bytes worth of files to be searched during any
				// given _IDLE_ event.
				cbSearched = cbSearched + PBSize()

				// open and search file
				idWasOpen = GetBufferId(Trim(m_stPath+s))
				if not m_fSearchLoadedFiles or not idWasOpen
					if not (PBAttribute() & _DIRECTORY_) and
							not FExclude(Trim(m_stPath+s), m_stExclude, FALSE)
						if idWasOpen
							id = GotoBufferId(idWasOpen)
						else
							//hs = SetHookState(OFF, _ON_CHANGING_FILES_)
							hs = SetHookState(OFF)
							id = EditFile(QuotePath(Trim(m_stPath+s)), _DONT_PROMPT_)
							//SetHookState(hs, _ON_CHANGING_FILES_)
							SetHookState(hs)
						endif
						if id
							i = SearchFile(m_stNeedle, m_stOpts, m_idFound, m_nFound, TRUE, idWasOpen)
							if not idWasOpen
								GotoBufferId(m_idFiles)
								AbandonFile(id)
							endif
							if i
								if g_fInShowResults and cid == m_idFound
									GotoBufferId(m_idFound)
									//$ review: optimize when UpdateDisplay()
									// is called, if it's slowing things down.
									//hs = SetHookState(OFF, _ON_CHANGING_FILES_)
									hs = SetHookState(OFF)
									UpdateDisplay()
									//SetHookState(hs, _ON_CHANGING_FILES_)
									SetHookState(hs)

									if not m_fSearchLoadedFiles
										if CurrLine() <> 1
											m_fFoundCurrLine = TRUE
										endif
										if not m_fFoundCurrLine and g_lineno <> 1
											m_fFoundCurrLine = TRUE
											GotoLine(g_lineno)
											//$ review: this seems to scroll
											// to center of screen instead of
											// center of list window?
											ScrollToCenter()
										endif
									endif
								endif
							else
								sis = sisAbort
							endif
						endif
					#ifdef DEBUG
					else
						Warn("excluding"; Trim(m_stPath+s))
					#endif
					endif
				#ifdef DEBUG
				else
					Warn("ignoring"; Trim(m_stPath+s))
				#endif
				endif

				GotoBufferId(m_idFiles)
				KillLine()
			until sis or not NumLines() or
					(cbSearched + PBSize() >= MAXSEARCHBYTES) or
					(cFilesSearched >= MAXSEARCHFILES)

			if not sis and not NumLines()
				// finished searching the last file
			endif
		endif

		GotoBufferId(cid)
	until sis or KeyPressed()

#ifdef DEBUG
	Assert(not idTmp, "IdleSearch: exiting but, idTmp is not zero!")
#endif

	if sis <> sisNone
		StopIdleSearch(sis)
	endif
end


proc NonEditIdleSearch()
	// the only time we can be pretty sure it's safe is if we're inside the
	// List in ShowResults, and if there is no prompt box open.
	if g_fInShowResults and not Length(Query(PromptString))
		IdleSearch()
	endif
end


integer proc DoSearch(string stNeedle,
					  string stOpts,
					  var integer idSearch,
					  var integer idFiles,
					  string path,
					  var integer nSearchedFiles,
					  var integer nFound,
					  string stExclude,
					  integer fQuiet,
					  integer fDoIdle)
	string s[MAXPATH]
	string stPath[MAXPATH] = path
	integer cid = GetBufferId()
	string stWild[MAXPATH]
	integer id
	integer idWasOpen
	integer i
	integer fRet = FALSE
	integer hs
	string wilds[255]

	m_idFound = g_idFound
	m_idSearch = idSearch
	m_idFiles = idFiles
	m_nFound = nFound
	m_nSearchedFiles = nSearchedFiles

	if fDoIdle
		// hook it
		if Hook(_IDLE_, IdleSearch) and
				Hook(_NONEDIT_IDLE_, NonEditIdleSearch)
			// clear these so Engine() doesn't abandon the buffers
			idSearch = 0
			idFiles = 0

			// setup some globals for idle searching
			m_stNeedle = stNeedle
			m_stExclude = stExclude
			m_stOpts = stOpts
			m_fSearchLoadedFiles = g_fSearchLoadedFiles
			m_fSubDirs = g_fSubDirs
			m_fVerbose = g_fVerbose

			m_fFoundCurrLine = FALSE

			g_fIdleSearching = TRUE

			return (TRUE)
		else
			UnHook(IdleSearch)
			UnHook(NonEditIdleSearch)
		endif
		// if the hook failed, do normal search instead of idle search
	endif

	// load files
	loop
		// get next path spec
		GotoBufferId(idSearch)
		if NumLines() == 0
			break
		endif
		BegFile()
		stPath = GetText(1, sizeof(stPath))
		wilds = ""
		i = Pos(Chr(1), stPath)
		if i
			stPath = stPath[1 : i - 1]
			wilds = GetText(i, sizeof(wilds))
		endif
		//nSearchedPaths = nSearchedPaths + 1
		KillLine()
		GotoBufferId(cid)

		// search path spec
		if Length(wilds)
			stWild = wilds
		else
			stWild = SplitPath(stPath, _NAME_|_EXT_)
		endif
		BuildList(idFiles, stPath, wilds, _NONE_)
		stPath = SplitPath(ExpandPath(stPath), _DRIVE_|_PATH_)
		do NumLines() times
			nSearchedFiles = nSearchedFiles + 1
			s = PBName()

			// open and search file
			Message("Searching ", Trim(stPath+s), "...")
			idWasOpen = GetBufferId(Trim(stPath+s))
			if not g_fSearchLoadedFiles or not idWasOpen
				if not (PBAttribute() & _DIRECTORY_) and
						not FExclude(Trim(stPath+s), stExclude, FALSE)
					if idWasOpen
						id = GotoBufferId(idWasOpen)
					else
						hs = SetHookState(OFF)
						id = EditFile(QuotePath(Trim(stPath+s)), _DONT_PROMPT_)
						SetHookState(hs)
					endif
					if id
						i = SearchFile(stNeedle, stOpts, g_idFound, m_nFound, fQuiet, idWasOpen)
						if not idWasOpen
							GotoBufferId(idFiles)
							AbandonFile(id)
						endif
						if not i
							fRet = FALSE
							goto Out
						endif
					endif
				#ifdef DEBUG
				else
					Warn("excluding"; Trim(stPath+s))
				#endif
				endif
			#ifdef DEBUG
			else
				Warn("ignoring"; Trim(stPath+s))
			#endif
			endif

			GotoBufferId(idFiles)
			Down()
		enddo

		// enumerate subdirectories
		if g_fSubDirs
			BuildList(idFiles, stPath+"dummyf.ile", "", _ADD_DIRS_)
			i = 0
			do NumLines() times
				s = PBName()
				if PBAttribute() & _DIRECTORY_ and
						s <> "." and s <> ".." and
						not FExclude(Trim(stPath+s), stExclude, TRUE)
						and not FExclude(Trim(s), stExclude, TRUE)
					#ifdef DEBUG
					Message("directory"; s)
					Delay(8)
					#endif
					// record directories in the dir buffer
					GotoBufferId(idSearch)
					InsertLine(AddTrailingSlash(Trim(stPath+s)))
					EndLine()
					InsertText(stWild, _INSERT_)
					GotoBufferId(idFiles)
					i = i + 1
				endif
				Down()
			enddo

			if KeyPressed()
				case GetKey()
					when <Ctrl C>, <Escape>, 0
						fRet = FALSE
						goto Out
				endcase
			endif

			if i
				// force directories into alphabetical order
				SortBuffer(idSearch, _IGNORE_CASE_)
			endif
		endif
	endloop

	fRet = TRUE

Out:
	GotoBufferId(cid)
	return (fRet)
end



///////////////////////////////////////////////////////////////////////////
// Engine

forward integer proc Engine(string _needle, string szOpts, string filespec, string excludespec, integer flags)

#define SR_GOTO				0x0001
#define SR_NOREFRESH		0x0002


// ShowResults()
// give picklist with results
proc ShowResults(integer ulFlags)
	string path[255] = ""
	integer cid = GetBufferId()
	integer fExit = FALSE
	integer i, ln
	integer fTwoWindows
	integer fGoto = (ulFlags & SR_GOTO)
	integer x, y

	// call UseHistory first to avoid boolean short circuit when g_idFound is
	// non-null, since UseHistory must have been called for ShowResults to
	// work correctly.
	if not UseHistory(g_iHistory) and not g_idFound
		Warn("Grep results buffer does not exist.")
		return()
	endif

retry:
	GotoBufferId(g_idFound)
	Set(Y1, 2)
	ClearKey()

	x = Query(ScreenCols)
	y = Query(ScreenRows)-3
	#ifdef CONTEXT_WINDOW
	g_nColOfs = 0
	g_nRowOfs = 0
	g_nRowOfsFresh = 0
	cyCtxWin = iif(g_fCtxWin, Query(ScreenRows)*pctCtxWin/100, 0)
	y = y - cyCtxWin
	#endif

	// show the list
	Hook(_LIST_STARTUP_, ListStartup)
	#ifdef DEBUG
	Assert(not g_fInShowResults, "ASSERT: not g_fInShowResults")
	#endif
	g_fInShowResults = TRUE
	if not fGoto
		fExit = not lList(Ellipsify(g_stTitle, Query(ScreenCols)-10), x, y,
						  _ENABLE_HSCROLL_|_ENABLE_SEARCH_|_FIXED_HEIGHT_)
	endif
	g_fInShowResults = FALSE
	UnHook(ListStartup)

	GotoBufferId(cid)
	UpdateDisplay(_ALL_WINDOWS_REFRESH_)
	GotoBufferId(g_idFound)

	// handle keypresses
	#ifdef DEBUG
	Assert(not fGoto or (Query(Key) == 0xffff), "fGoto should imply Key == 0xffff (-1) but it is "+KeyName(Query(Key))+" ("+Str(Query(Key), 16)+")")
	#endif
	// NOTE: we'll leave g_idFound in the histories, unless <Alt E> hit.
	case Query(Key)
		when <Alt E>
			// insert search string at top
			PushPosition()
			BegFile()
			InsertLine(c_stGREP_MagicMarker)
			AddLine(c_stSearchedFor+g_stTitle)
			AddLine(c_stOptions+GetFromHistory(whatOpts))
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
			KillHistory(g_iHistory, FALSE)
			// force this hook, since GotoBufferId did not execute it
			ExecHook(_ON_CHANGING_FILES_)

		when <Alt L>
			PushPosition()
			BegFile()
			while lFind(prefix, "^")
				i = GetBufferId()
				AddFileToRing(QuotePath(ExtractFilename()))
				GotoBufferId(i)
				Down()
			endwhile
			PopPosition()
			fExit = TRUE

#ifdef DEBUG
		when <F12>
			if m_idSearch
				GotoBufferId(m_idSearch)
				PushPosition()
				List("m_idSearch", 78)
				PopPosition()
			endif
			if g_idSearch
				GotoBufferId(g_idSearch)
				PushPosition()
				List("g_idSearch", 78)
				PopPosition()
			endif
			if m_idFiles
				GotoBufferId(m_idFiles)
				PushPosition()
				List("m_idFiles", 78)
				PopPosition()
			endif
			GotoBufferId(g_idFound)
#endif

		when <F5>
			if not (ulFlags & SR_NOREFRESH)
				// refresh (do the whole search again)
				GotoBufferId(cid)
				if Engine(GetFromHistory(whatNeedle),
						GetFromHistory(whatOpts),
						GetFromHistory(whatFilespec),
						GetFromHistory(whatExclude),
						Val(GetFromHistory(whatFlags))|_REFRESH)
					goto retry
				endif
			endif

		when <Alt ,>, <Alt CursorLeft>, <Alt GreyCursorLeft>, <Ctrl [>
			// back
			UseHistory(g_iHistory + 1)
			goto retry

		when <Alt .>, <Alt CursorRight>, <Alt GreyCursorRight>, <Ctrl ]>
			// forward
			UseHistory(g_iHistory - 1)
			goto retry

		when <Ctrl C>, 0
			if g_fIdleSearching
				StopIdleSearch(sisAbort)
			endif
			goto retry

		otherwise
			if fExit
				// a key caused the List to exit, without being specifically
				// handled, so just exit.  (for instance <Escape>)
			else
				fTwoWindows = (Query(Key) == <Ctrl Enter>)
				PushPosition()
				// ln = Val(GetText(1, 8))
				ln = Val(GetText(1, 20))
				EndLine()
				if lFind(prefix, "^b")
					path = QuotePath(ExtractFilename())
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
							#ifdef CONTEXT_WINDOW
							GotoLine(ln+g_nRowOfs-g_nRowOfsFresh)
							#else
							GotoLine(ln)
							#endif
							// position cursor
							BegLine()
							lFind(GetFromHistory(whatNeedle), FilterOpts(GetFromHistory(whatOpts))+"c")
							//ScrollToCenter()
							ScrollToRow(Query(WindowRows)/4)
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

					if fGoto
						KillHistory(g_iHistory, TRUE)
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
			endif
	endcase

	// hilite found text if appropriate, otherwise return to original buffer
	if not fExit
		PushPosition()
		if g_fFunctionList
			if not fGoto
				VGotoXYAbs(Query(WindowX1), Query(WindowY1)+CurrRow()-1)
				PutAttr(Query(HiLiteAttr), Query(WindowCols))
			endif
		else
			i = Set(Beep, OFF)
			Find(GetFromHistory(whatNeedle), FilterOpts(GetFromHistory(whatOpts)))
			Set(Beep, i)
		endif
		PopPosition()
	else
		GotoBufferId(cid)
	endif

	g_idFound = 0
	g_fInShowResults = FALSE

	#ifndef WIN32
	UpdateDisplay(_ALL_WINDOWS_REFRESH_)
	#endif
end


integer proc GetNewResultsBuffer()
	integer id = 0

	// try incrementing the unique number as many as 32 times looking for a
	// filename not in the ring.
	do 32 times
		unique = unique + 1
		id = CreateBuffer("$grep-"+Str(unique)+"$.$", _HIDDEN_)
		if id
			break
		endif
	enddo
	return(id)
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
integer proc Engine(string _needle, string szOpts, string filespec, string excludespec, integer flags)
	string needle[255] = _needle
	string opts[12] = ""
	string path[255] = ""
	integer fGoto = FALSE
	integer fCurrFileOnly = (flags & _FUNCTIONLIST)
	integer fQuiet = (flags & _FUNCTIONLIST)
	integer ml
	integer idSearch
	integer idFiles
	integer cid = GetBufferId()
	integer cBuffers = 0
	integer i
	integer hs
	integer n = 0
	integer nSearchedFiles = 0
	string wilds[255] = ""

	#ifdef DEBUG
	Assert(not g_idFound or (flags & _REFRESH),
		   "g_idFound should be 0 when entering Engine unless doing a refresh")
	#endif

	StopIdleSearch(sisAbort)

	PushPosition()
	GetTime(m_hh, m_mm, m_ss, m_hun)
	g_startlineno = CurrLine()
	g_lineno = 1
	g_cid = cid
	g_stTitle = needle

	g_fFunctionList = FALSE

	// get buffers
	idSearch = CreateTempBuffer()
	idFiles = CreateTempBuffer()

	if not g_idFound
		g_idFound = GetNewResultsBuffer()
	endif

	// bail if unable to create buffers
	if not idSearch or not g_idFound or not idFiles
		// goto avoids _ON_CHANGING_FILES_ hook
		GotoBufferId(cid)
		PopPosition()
		AbandonFile(idSearch)
		AbandonFile(idFiles)
		AbandonFile(g_idFound)
		g_idFound = 0
		Warn("Unable to create buffers.")
		return (0)
	endif

	// go back to original buffer
	if not cid
		cid = g_idFound
	endif
	GotoBufferId(cid)

	// empty buffer
	EmptyBuffer(g_idFound)

	// init vars and options
	g_fFilenamesOnly = FALSE
	g_fSubDirs = FALSE
	g_fSearchLoadedFiles = FALSE
	g_fVerbose = FALSE
	for i = 1 to Length(szOpts)
		case Lower(szOpts[i])
			when "l"
				// fiLenames only
				g_fFilenamesOnly = OnOrOff(szOpts, i)
			when "d"
				// traverse subDirectories
				g_fSubDirs = OnOrOff(szOpts, i)
			when "m"
				// search files in Memory (search loaded files)
				g_fSearchLoadedFiles = OnOrOff(szOpts, i)
			when "v"
				// Verbose
				g_fVerbose = OnOrOff(szOpts, i)
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
		if g_idSearch
			if GotoBufferId(g_idSearch)
				// disable path recursing
				g_fSubDirs = FALSE
				// use g_idSearch as a list of files to search
				AbandonFile(idSearch)
				idSearch = g_idSearch
				g_idSearch = 0
				GotoBufferId(cid)
			endif
		else
			wilds = ""

			for i = 1 to NumTokens(filespec, " ")
				path = GetToken(filespec, " ", i)
				if SplitPath(path, _DRIVE_) == ""
					// no drive specified
					if SplitPath(path, _PATH_) == ""
						// no path specified; append to list of extensions
						wilds = wilds + Chr(1) + path
					else
						// relative path specified
						if not ((SubStr(SplitPath(path, _PATH_), 1, 1) in "\", "/"))
							path = iif(Length(g_dir), g_dir, CurrDir()) + path
						else
							path = SplitPath(iif(Length(g_dir), g_dir, CurrDir()), _DRIVE_) + path
						endif
						AddLine(path, idSearch)
					endif
				else
					AddLine(path, idSearch)
				endif
			endfor

			if Length(wilds)
				GotoBufferId(idSearch)
				AddLine(iif(Length(g_dir), AddTrailingSlash(g_dir), CurrDir()))
				EndLine()
				InsertText(wilds, _INSERT_)		// separately, to better accomodate long lists
				GotoBufferId(cid)
			endif

			// force alphabetical order for directories
			SortBuffer(idSearch, _IGNORE_CASE_)
		endif
	endif

	if not fQuiet and not BACKGROUNDSEARCH
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
		cBuffers = iif(fCurrFileOnly, 1,
				NumFiles() + (BufferType() <> _NORMAL_))
		while cBuffers
			nSearchedFiles = nSearchedFiles + 1

			//if not SearchFile(needle, opts, g_idFound, n, fQuiet, TRUE)
			//$ always use quiet mode for files in memory
			if not SearchFile(needle, opts, g_idFound, n, TRUE, TRUE)
				goto __terminated
			endif

			NextFile()
			cBuffers = cBuffers - 1
		endwhile
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

			GotoBufferId(g_idFound)

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
		endif

		// done - skip searching files on disk
		goto __ok
	endif

	// do the search (or hook it into _IDLE_ so it happens in ShowResults)
	GotoBufferId(cid)
	if not DoSearch(needle, opts, idSearch, idFiles, path, nSearchedFiles,
					n, excludespec, fQuiet, BACKGROUNDSEARCH)
__terminated:
		AppendToBuffer(g_idFound, GetToken(c_stSIS, "$", sisAbort))
	endif

__ok:
	GotoBufferId(cid)
	Set(MsgLevel, ml)
	FullWindow()

	// restore hooks
	SetHookState(hs)
    if not BACKGROUNDSEARCH
        UpdateDisplay(_ALL_WINDOWS_REFRESH_|_HELPLINE_REFRESH_)
    endif

	AbandonFile(idSearch)
	AbandonFile(idFiles)
	if not n and not g_fIdleSearching
		PopPosition()
		if g_idFound == Val(GetFromHistory(whatID))
			KillHistory(g_iHistory, TRUE)
		else
			AbandonFile(g_idFound)
		endif
		g_idFound = 0
		GotoBufferId(cid)

		if not (flags & _FUNCTIONLIST)
			Message("Not found.  ", GetElapsed())
		else
			Message("Not found.")
		endif
		return(0)
	endif

	KillPosition()
	if not g_fIdleSearching
		if not (flags & _FUNCTIONLIST)
			Message(n, " occurrences found.  ", GetElapsed())
		endif
	endif

	AddHistory(g_idFound, needle, szOpts, filespec, excludespec, flags)
	GotoBufferId(g_idFound)
	GotoLine(g_lineno)
	ScrollToCenter()
	GotoBufferId(cid)

	if not (flags & _REFRESH)
		ShowResults(iif(fGoto, SR_GOTO, 0))
	endif

	return(n)
end


proc GrepCurrWord(integer fMemory)
	string path[255] = SplitPath(CurrFilename(), _DRIVE_|_PATH_)
	string word[80]
	string opts[20] = iif(fMemory, "im", "i")

	if isCursorInBlock() and isCursorInBlock() <> _LINE_
		word = GetMarkedText()
	else
		word = GetWord(TRUE)
	endif
	if not Length(word)
		if not SearchFor(path, word, opts) or not Length(word)
			return()
		endif
	endif

	g_dir = path

	if fMemory
		Engine(word, "-"+opts, "", "", 0)
	else
		Engine(word, "-"+opts,
				"*.h *.hpp *.inl *.c *.cpp *.rc *.rc2 *.pp *.csv *.dlg "+
				"*.idl *.odl *.bat *.btm *.s *.si *.ui *.asm *.inc", "", 0)
	endif
end


proc FunctionList(string fn)
	string expr[255] = ""

	GetFunctionStr(CurrExt(), expr)

	if not Length(expr)
		Warn("GREP: Extension"; CurrExt(); "not supported")
		return ()
	endif

	g_stFunction = fn
	Engine(expr, "ix", "", "", _FUNCTIONLIST)
	g_stFunction = ""
end



///////////////////////////////////////////////////////////////////////////
// Dialog UI

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
	if not g_idSearch
		// normal search
		ExecMacro(Format("DlgSetTitle ",ID_EDT_FILES," ",g_files))
		ExecMacro(Format("DlgSetData ",ID_EDT_FILES," ",hist_files))
		ExecMacro(Format("DlgSetTitle ",ID_EDT_EXCL," ",g_excl))
		ExecMacro(Format("DlgSetData ",ID_EDT_EXCL," ",hist_excl))
		ExecMacro(Format("DlgSetTitle ",ID_EDT_DIR," ",g_dir))
		ExecMacro(Format("DlgSetData ",ID_EDT_DIR," ",hist_dir))
	else
		// g_idSearch contains list of files to search, so disable Files,
		// Exclude, and Directory.
		ExecMacro(Format("DlgSetEnable ",ID_EDT_FILES," ",FALSE))
		ExecMacro(Format("DlgSetEnable ",ID_EDT_EXCL," ",FALSE))
		ExecMacro(Format("DlgSetEnable ",ID_EDT_DIR," ",FALSE))
		ExecMacro(Format("DlgSetTitle ",ID_EDT_FILES," n/a"))
		ExecMacro(Format("DlgSetTitle ",ID_EDT_EXCL," n/a"))
		ExecMacro(Format("DlgSetTitle ",ID_EDT_DIR," n/a"))
	endif
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
//				DelHistoryStr(hist_dir, 1)
				AddHistoryStr(s, hist_dir)
			else
				s = ""
//				DelHistoryStr(hist_dir, 1)
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
	if not g_idSearch
		ExecMacro(Format("DlgGetTitle"; ID_EDT_FILES))
		g_files = Query(MacroCmdLine)
		ExecMacro(Format("DlgGetTitle"; ID_EDT_EXCL))
		g_excl = Query(MacroCmdLine)
		ExecMacro(Format("DlgGetTitle"; ID_EDT_DIR))
		g_dir = Query(MacroCmdLine)
	endif
	ExecMacro(Format("DlgGetTitle"; ID_EDT_CTX))
	g_nContext = Val(Query(MacroCmdLine))

	UpdateHistoryStr(g_expr, _FINDHISTORY_)
	UpdateHistoryStr(g_opts, hist_opts)
	if not g_idSearch
		UpdateHistoryStr(g_files, hist_files)
		UpdateHistoryStr(g_excl, hist_excl)
		UpdateHistoryStr(g_dir, hist_dir)
	endif

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



///////////////////////////////////////////////////////////////////////////
// Menu UI

#if VARIATION == 1
string proc OnOffStr(integer i)
	return (iif(i, "On", "Off"))
end


proc mToggle(var integer i)
	i = not i
end


string proc OnOffOpt(string opts, string opt)
	return (iif(Pos(opt, opts), "On", "Off"))
end


proc mToggleOpt(var string opts, string opt)
	integer i

	i = Pos(Lower(opt), Lower(opts))
	if i
		repeat
			opts = DelStr(opts, i, 1)
			i = Pos(Lower(opt), Lower(opts))
		until not i
	else
		opts = opts + opt
	endif
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


#ifdef WIN32CONSOLE
constant MF_GRAYED = 1
integer proc mfB()
	return (iif(g_idSearch, MF_GRAYED, 0))
end


menu Stuff()
	"&Search for:" [Format(g_expr:-30):-30], Read(g_expr, _FIND_HISTORY_), DontClose, "String to search for."
	"&Files:     " [Format(g_files:-30):-30], Read(g_files, hist_files), mfB(), "Files to search.  (Wildcards and directories are ok)"
	"&Exclude:   " [Format(g_excl:-30):-30], Read(g_excl, hist_excl), mfB(), "Files to exclude.  (Wildcards and directories are ok)"
	"Di&rectory: " [Format(g_dir:-30):-30], mReadDir(), mfB(), "Directory to start from.  (UNC paths are ok)"
	"Options",, Divide
	"&Ignore case" [OnOffOpt(g_opts, 'i'):3],
						mToggleOpt(g_opts, 'i'), DontClose
	"&Words" [OnOffOpt(g_opts, 'w'):3],
						mToggleOpt(g_opts, 'w'), DontClose
	"Regular e&xpression" [OnOffOpt(g_opts, 'x'):3],
						mToggleOpt(g_opts, 'x'), DontClose
	"Show fi&lenames" [OnOffOpt(g_opts, 'l'):3],
						mToggleOpt(g_opts, 'l'), DontClose
	"Search sub&directories" [OnOffOpt(g_opts, 'd'):3],
						mToggleOpt(g_opts, 'd'), DontClose
	"Beginning of line <&^>" [OnOffOpt(g_opts, '^'):3],
						mToggleOpt(g_opts, '^'), DontClose
	"End of line <&$>" [OnOffOpt(g_opts, '$'):3],
						mToggleOpt(g_opts, '$'), DontClose
	"Advanced Options",, Divide
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
#else
menu Stuff()
	"&Search for:" [Format(g_expr:-30):-30], Read(g_expr, _FIND_HISTORY_), DontClose, "String to search for."
	"&Options:   " [Format(g_opts:-10):-10], Read(g_opts, hist_opts), DontClose, "Options [DILX] (subDirs Ignore-case fiLenames reg-eXp)"
	"&Files:     " [Format(g_files:-30):-30], Read(g_files, hist_files), DontClose, "Files to search.  (Wildcards and directories are ok)"
	"&Exclude:   " [Format(g_excl:-30):-30], Read(g_excl, hist_excl), DontClose, "Files to exclude.  (Wildcards and directories are ok)"
	"&Directory: " [Format(g_dir:-30):-30], mReadDir(), DontClose, "Directory to start from.  (UNC paths are ok)"
	"Options",, Divide
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


menu Stuff2()
	"&Search for:" [Format(g_expr:-30):-30], Read(g_expr, _FIND_HISTORY_), DontClose, "String to search for."
	"&Options:   " [Format(g_opts:-10):-10], Read(g_opts, hist_opts), DontClose, "Options [DILX] (subDirs Ignore-case fiLenames reg-eXp)"
	"Options",, Divide
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
#endif


proc UI()
	integer fOk

	#ifdef WIN32CONSOLE
        // ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new [kn, ri, tu, 29-11-2022 18:15:58]
	fOk = Stuff("Grep ["+CurrDir()+"]")
	#else
	fOk = iif(not g_idSearch,
			Stuff("Grep ["+CurrDir()+"]")
			Stuff2("Grep ["+CurrDir()+"]"))
	#endif

	if fOk
		Engine(g_expr, g_opts, g_files, g_excl, 0)
	endif

	// save settings
	XferSettings(FALSE)
end
#endif



///////////////////////////////////////////////////////////////////////////
// Ask UI

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

	if not Length(files) and not g_idSearch
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



///////////////////////////////////////////////////////////////////////////
// Hooks

keydef GrepKeys
<Shift PgDn>			gotoFile(TRUE, FALSE)
<Shift PgUp>			gotoFile(FALSE, FALSE)
<Del>					DelThis()
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



///////////////////////////////////////////////////////////////////////////
// Auto Macros

proc WhenLoaded()
	integer cid = GetBufferId()

	g_idHistory = CreateTempBuffer()
	GotoBufferId(cid)

	if not g_idHistory
		Warn("Unable to create history buffer.")
		PurgeMacro(CurrMacroFilename())
		return()
	endif

	hist_opts = GetFreeHistory("Grep:Options")
	hist_files = GetFreeHistory("Grep:Files")
	hist_excl = GetFreeHistory("Grep:Exclude")
	#if VARIATION
	hist_dir = GetFreeHistory("Grep:Dir")
	#endif

	Hook(_ON_CHANGING_FILES_, OnChangingFiles)

	// load settings
	XferSettings(TRUE)
end


proc WhenPurged()
	StopIdleSearch(sisAbort)

	if g_idHistory
		while KillHistory(0, TRUE)
		endwhile
		AbandonFile(g_idHistory)
	endif
end



///////////////////////////////////////////////////////////////////////////
// Command Line Arguments

// CmdLineOptionUsed()
// looks for -<option>, sets global str Arg<option> if found
integer proc CmdLineOptionUsed(STRING option)
	string tmp[255]
	string stCmdline[255] = ""
	string arg[80] = ""
	string opt[20] = "-" + option
	integer fFound = FALSE
	integer ii

	for ii = 1 to NumFileTokens(Query(MacroCmdLine))
		// get token
		tmp = GetFileToken(Query(MacroCmdLine), ii)
		if not fFound
			if Pos(opt, tmp) == 1
				// option found
				if Length(opt) == Length(tmp)
					// no argument used
					arg = ""
				else
					// argument used
					tmp = DelStr(tmp, 1, Length(opt))
					if not QuotedArg(Chr(1)+Chr(34)+Chr(39), tmp, arg)
						arg = tmp
					endif
				endif
				// remove this from the cmd line
				tmp = ""
				// set arg variable
				SetGlobalStr('Arg' + option, arg)
				fFound = TRUE
			endif
		endif

		// build the updated cmd line
		if Length(tmp)
			if Length(stCmdline)
				stCmdline = stCmdline + " "
			endif
			stCmdline = stCmdline + tmp
		endif
	endfor

	// set the updated cmd line
	Set(MacroCmdLine, stCmdline)

	return(fFound)
end



///////////////////////////////////////////////////////////////////////////
// Main

/*
	Options:
		-w			search files in memory for word under cursor.
		-r...		reload saved search results, from file {...}.
		-f			search current file for function name under cursor.
		-p...		start search from directory {...}.
		-e...		exclude files matching {...}.
		-c			search current file only.
//$ todo: 		-F...		file {...} is a list of files to search.
		-Bn			bufferid {n} is a list of files to search (NOTE: grep
					takes ownership of the buffer, modifies it, and frees it).

*/
proc Grep(string cmdline)
	string s[255] = cmdline
	string orig_path[255] = ""
	integer fCmdLine = FALSE
	integer fParseFilespec = TRUE
	integer fMaybeTryAgain = TRUE
	integer fChop = FALSE

	g_idSearch = 0

	if cmdline == ""
		PushPosition()
		BegFile()
		if GetText(1, 255) == c_stGREP_MagicMarker
			case MsgBox("Grep", "Copy this file into the Grep Results list?", _YES_NO_CANCEL_)
				when 1
					KillPosition()
					ExecMacro(CurrMacroFilename() + " -r" + CurrFilename())
					return()
				when 0,3
					PopPosition()
					return()
			endcase
		endif
		PopPosition()
	endif

TryAgain:
	g_expr = ""
	g_opts = ""
	g_files = ""
	g_excl = ""
	g_dir = ""

	s = Trim(s)
	fCmdLine = Length(s)
	if not fCmdLine
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
				fChop = FALSE
				case s[1]
					when "p"
						s = DelStr(s, 1, 1)
						if not QuotedArg('"', s, g_dir)
							NormalArg(s, g_dir)
							if Length(g_dir) and g_dir[1] == '@'
								g_dir = GetGlobalStr(g_dir[2:255])
							endif
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
						s = DelStr(s, 1, 1)
						//$ review: WONT WORK WITH LONG FILENAMES THAT CONTAIN
						// SPACES.
						NormalArg(s, g_excl)
						//$ review: WONT WORK WITH LONG FILENAMES THAT CONTAIN
						// COMMAS OR SEMICOLONS.
						g_excl = StripCommas(g_excl)

					when "B"
						// given buffer id contains list of files to search
						//$ review: this feature needs to make it into the
						// help file!
						fChop = TRUE
						g_idSearch = Val(s[2:255])
						fParseFilespec = FALSE

					otherwise
						fChop = TRUE
						g_opts = g_opts + s
						if Pos(" ", g_opts)
							g_opts = SubStr(g_opts, 1, Pos(" ", g_opts) - 1)
						endif
						if Pos("c", g_opts)
							fParseFilespec = FALSE
						endif
				endcase

				if fChop
					// chop off everything up to the next space
					if Pos(" ", s)
						s = LTrim(DelStr(s, 1, Pos(" ", s)))
					else
						s = ""
					endif
				endif

				// allow grep dialog even if -B is specified
				if g_idSearch and fMaybeTryAgain
					fMaybeTryAgain = FALSE
					goto TryAgain
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
		/*
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


proc Main()
	string s[255] = Query(MacroCmdLine)
	integer fArgr = FALSE
	integer cid = GetBufferId()
	string needle[255] = ""
	string opts[32] = ""

	case Query(MacroCmdLine)
		when "-w"
			GrepCurrWord(TRUE)
			return()
	endcase

	// show results
	if CmdLineOptionUsed("r")
		fArgr = Length(GetGlobalStr("Argr"))
		if fArgr
			// filename specified, load file and use it as a results buffer
			if not g_idFound
				g_idFound = GetNewResultsBuffer()
			endif
			GotoBufferId(g_idFound)
			EmptyBuffer()
			PushBlock()
			InsertFile(GetGlobalStr("Argr"), _DONT_PROMPT_)
			PopBlock()
			// remove blank lines
			if lFind("", "^$g")
				repeat
					KillLine()
				until not lRepeatFind()
			endif

			BegFile()
			if lFind(c_stGREP_MagicMarker, "^$c")
				KillLine()
			endif
			BegLine()
			if lFind(c_stSearchedFor, "^c")
				GotoPos(Length(GetFoundText())+1)
				needle = GetText(CurrPos(), 255)
				KillLine()
			endif
			BegLine()
			if lFind(c_stOptions, "^c")
				GotoPos(Length(GetFoundText())+1)
				opts = GetText(CurrPos(), 255)
				KillLine()
			endif

			FileChanged(FALSE)
			GotoBufferId(cid)

			AddHistory(g_idFound, needle, opts, "", "", SR_NOREFRESH)
		endif
		// show grep results
		ShowResults(iif(fArgr, SR_NOREFRESH, 0))
		return()
	endif

	// function list
	if CmdLineOptionUsed("f")
		FunctionList(Trim(GetGlobalStr("Argf")))
		return()
	endif

	// handles UI and starting the engine
	Grep(s)
end


public proc GrepGetVersion()
	Set(MacroCmdLine, Format(c_nVer:4:"0":16))
end



// Keys -------------------------------------------------------------------

// the grep dialog
<Alt G>			Grep("")
<AltShift G>	ShowResults(0)

// grep in current file's directory for word (or block) under cursor
<CtrlAlt G>		GrepCurrWord(FALSE)
<CtrlShift '>	GrepCurrWord(FALSE)

// grep files in memory for word/block under cursor
<Ctrl '>		GrepCurrWord(TRUE)

// find function
<Ctrl G>		FunctionList(GetWord(TRUE))
