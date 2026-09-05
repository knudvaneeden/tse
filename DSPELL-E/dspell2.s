// TSE/32
// DSPELL2.S - Spelling Engine --------------------------------------------
// Portable package version 1.0.0.0.6 - 2026-09-05
// Uses TSE's built-in replacement history for suggestions.



// External spell checking engine -----------------------------------------

#ifdef WIN32
dll "spell.dll"
	integer proc OpenSpell(string fn) : "_OpenSpell"
	integer proc CloseSpell() : "_CloseSpell"
	integer proc SpellCheckWord(string word) : "_SpellCheckWord"
	integer proc SuggestWord(string word) : "_SuggestWord"
			proc GetSuggestion(var string word, integer n) : "_GetSuggestion"
			proc RemoveQuotes(var string word) : "_RemoveQuotes"
end
#else
binary ['spellbin.bin']
	integer proc OpenSpell(string fn) : 0
	integer proc CloseSpell() : 3
	integer proc SpellCheckWord(string word) : 6
	integer proc SuggestWord(string word) : 9
	proc GetSuggestion(var string word, integer n) : 12
	proc RemoveQuotes(var string word) : 15
end
#endif



// Include Files ----------------------------------------------------------

#include ["dspell.si"]



// Global constants -------------------------------------------------------

// optimized hyphenation code by making a hyphen at the end of a line a valid
// word character.
string WordPattern[] = "[A-Za-z'0-9\d128-\d165\d225][A-Za-z'0-9\d128-\d165\d225]#{-$}|{}"



// Global variables -------------------------------------------------------

integer fInit = FALSE
integer id_addl = 0, id_ignore = 0, id_flag = 0, id_dict = 0
integer g_fIgnoreNonAlphaWords

integer markln = 0, markpos = 0



// Functions --------------------------------------------------------------

proc Settings(string s)
	g_fIgnoreNonAlphaWords = Val(GetToken(s, " ", 1))
	markln = Val(GetToken(s, " ", 2))
	markpos = Val(GetToken(s, " ", 3))
end


proc GotoStart()
	GotoLine(markln)
	GotoPos(markpos)
end


#ifdef BLIND
integer fThisTime = TRUE
proc Click()
	if fThisTime
		// this might not work well with TSE32
		Sound(20)
		Delay(1)
		NoSound()
	endif
	fThisTime = not fThisTime
end
#endif


integer SPstartLine, SPlineCount, SPlastLine, SPticks
integer proc DisplayProgress()
	if CurrLine() > SPlastLine
		if GetClockTicks() - SPticks > 3
			SPticks = GetClockTicks()

			// done here b/c KeyPressed is so slow in TSE/32
			if KeyPressed() and GetKey() in 0,<Ctrl C>,<Escape>
				return(FALSE)
			endif

			#ifdef BLIND
			Click()
			#endif
			Message("Checking spelling: ",
					(100*(CurrLine()-SPstartLine))/SPlineCount, "% complete")
		endif

		SPlastLine = CurrLine()
	endif
	return(TRUE)
end


proc InitProgress()
	if isCursorInBlock()
		SPstartLine = Query(BlockBegLine)
		SPlineCount = Query(BlockEndLine) - SPstartLine + 1
	else
		PushPosition()
		GotoStart()
		SPstartLine = CurrLine()
		SPlineCount = NumLines() - SPstartLine + 1
		PopPosition()
	endif
	SPticks = 0
	SPlastLine = 0

	#ifdef BLIND
	fThisTime = TRUE
	#endif

	DisplayProgress()
end


integer proc FindWordIn(string word, integer id)
	integer ok = FALSE
	integer cid

	cid = GotoBufferId(id)
	if cid
		ok = lFind(word, "gwi^")
		GotoBufferId(cid)
	endif
	return (ok)
end


/*
// BFindWordIn
// uses binary search.
// assumes file is all lower case, sorted in ascending order.
integer proc BFindWordIn(string word, integer id)
	integer ok = FALSE
	integer cid
	integer nLo, nHi
	string line[MAXLONGWORD]

	cid = GotoBufferId(id)
	if cid
		if NumLines() <= 65000
			// binary search
			nLo = 1
			nHi = NumLines()
			while nHi >= nLo
				GotoLine((nHi+nLo)/2)
				line = GetText(1, MAXLONGWORD)
				if nHi == nLo
					ok = (word == line)
					break
				endif
				if word > line
					nLo = CurrLine() + 1
				else
					nHi = CurrLine()
				endif
			endwhile
		else
			ok = lFind(word, "gw^")
		endif
		GotoBufferId(cid)
	endif
	return (ok)
end
*/


integer proc CheckWord(string word)
	integer i, c
	integer fFound = FALSE
	integer cid

	if g_fIgnoreNonAlphaWords
		// handles foreign letters (accents, grave accents, umlauts, etc)
		for i = 1 to Length(word)
			if not GetBit(AlphaWordSet, Asc(word[i]))
				return(TRUE)
			endif
		endfor
	endif

	if FindWordIn(word, id_flag)
		return(FALSE)
	endif

	fFound = SpellCheckWord(word) or FindWordIn(word, id_addl) or
			FindWordIn(word, id_ignore)

	if not fFound
		// check custom dictionaries
		cid = GetBufferId()
		if id_dict and GotoBufferId(id_dict)
			c = NumLines()
			BegFile()
			for i = 1 to c
				if GetText(1, 1) == "*"
					fFound = FindWordIn(word, Val(GetText(2, 8)))
					if fFound
						// if found, short circuit
						break
					endif
				endif
				Down()
			endfor
		endif
		GotoBufferId(cid)
	endif

	return(fFound)
end


integer proc CreateWordList(integer id)
	integer i
	integer cid
	string raw_word[MAXLONGWORD]
	string word[MAXLONGWORD]
	string find_opt[8]

	PushPosition()
	find_opt = "wx"+GetGlobalStr(gstr_findscope)
	GotoStart()
	InitProgress()
	while lFind(WordPattern, find_opt)
		#if 0
		//$32 KeyPressed is *REALLY* slow in TSE/32
		// maybe abort
		if KeyPressed() and GetKey() in 0, <Ctrl c>, <Escape>
			PopPosition()
			Message("Aborted.")
			return(FALSE)
		endif
		#endif

		raw_word = GetFoundText()
		word = Lower(raw_word)

		// try to handle hyphenated words at the eol
		if word[Length(word)] == "-"
			EndLine()
			if WordRight() and isWord()
				raw_word = raw_word + "-"
				word = Lower(word+GetWord())
			endif
		endif

		// handle tex/latex constructions like ''mispelld''
		RemoveQuotes(word)

		if not CheckWord(word) and Length(word)
			cid = GotoBufferId(id)
			if not lFind(raw_word, "gw^")
				EndFile()
				AddLine(raw_word+" (1)")
			else
				if lFind(occurs, "gxc")
					i = Val(GetFoundText(1))+1
					lReplace(occurs, "("+Str(i)+")", "x1")
				endif
			endif
			GotoBufferId(cid)
		endif

		// so we don't get the same word multiple times (also fixes bug where
		// 'wrogn' showed up twice; as 'wrogn' and as wrogn'.
		Right(Length(raw_word))

		if not DisplayProgress()
			PopPosition()
			Message("Aborted.")
			return(FALSE)
		endif
	endwhile

	cid = GotoBufferId(id)
	BegFile()
	FileChanged(FALSE)
	GotoBufferId(cid)

	PopPosition()

	return(TRUE)
end


integer proc Init(string s)
	if not fInit
		// open dictionary
		if OpenSpell(GetToken(s, " ", 1))
			id_addl = Val(GetToken(s, " ", 2))
			id_ignore = Val(GetToken(s, " ", 3))
			id_flag = Val(GetToken(s, " ", 4))
			id_dict = Val(GetToken(s, " ", 5))
			fInit = TRUE
		else
			Warn("Can't find dictionary")
			PurgeMacro(CurrMacroFilename())
		endif
	endif
	return(fInit)
end


proc CleanUp()
	if fInit
		CloseSpell()
	endif
end


proc WhenLoaded()
	// since we're leaving the dictionary open as long as this macro is
	// loaded, we have to ensure the dictionary gets closed before exiting
	// the editor.  hence, we cleanup on abandoning the editor and on
	// purging the macro.  note:  macros are not automatically purged when
	// abandoning the editor.
	Hook(_ON_ABANDON_EDITOR_, CleanUp)
end


proc WhenPurged()
	CleanUp()
end


proc Main()
	string s[255] = Query(MacroCmdLine)
	string suggest[MAXLONGWORD] = ""
	integer hist, n

	if Length(s) > 1 and s[1] == "-"
		if not fInit and s[1:2] <> "-z"
			Warn("DSPELL2 not initialized yet.")
			return()
		endif

		case s[2]
			when "c"
				Set(MacroCmdLine, Str(CheckWord(s[3:255])))
			when "e"
				Settings(s[3:255])
			when "g"
				Set(MacroCmdLine, Str(SuggestWord(s[3:255])))
			when "h"
				hist = _REPLACE_HISTORY_
				n = SuggestWord(s[3:255])
				while n > 0
					GetSuggestion(suggest, n)
					AddHistoryStr(suggest, hist)
					n = n - 1
				endwhile
				Set(MacroCmdLine, Str(hist))
			when "n"
				GetSuggestion(suggest, Val(s[3:255]))
				Set(MacroCmdLine, suggest)
			when "q"
				s = DelStr(s, 1, 2)
				RemoveQuotes(s)
				Set(MacroCmdLine, s)
			when "w"
				Set(MacroCmdLine, Str(CreateWordList(Val(s[3:255]))))
			when "z"
				Set(MacroCmdLine, Str(Init(s[3:255])))
		endcase
	else
		Warn("DSPELL2.MAC should only be called by DSPELL.MAC")
	endif
end
