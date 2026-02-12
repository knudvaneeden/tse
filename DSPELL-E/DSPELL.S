// TSE/32

//
//	File$Id: dspell.s 0.12.0.1 1995/07/15 14:38:04 drm Exp $
//	$Source: C:/USR/TSE/RCS/dspell.s $
//
//	Alternative Spelling Checker for TSE by Dave Monksfield
//	(uses the TSE spell checking engine spellbin.bin)
//
//	Comments or suggestions to: drm@myob.demon.co.uk
//
//	Copyright (c) 1995	D.R.Monksfield
//
//	This program is free software; you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation; either version 2 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program; if not, write to the Free Software
//	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//

//	NOTE:  No key bindings.  Must bind to key in .UI file.

/*
	Revision History:

	DSPELL-E, Changed by Chris Antos, 11/05/96, chrisant@microsoft.com
		- Converted to work with both TSE 2.5 (DOS) and 2.6 (Win32).
		- Statusline indicator "S" when autospell is on.
		- <CtrlShift A> temporarily overrides the AutoSpell on/off setting.
		  (The statusline indicator is bright white on green when AutoSpell
          is forced on in this manner).
		- Tests on timing:  iterating thru file is 15%; checking words
		  against SEMWARE.LEX is 55%; checking words against custom
          dictionaries depends on the size of the dictionaries; FLAG.LEX,
          USER.LEX, and ignoring words is 11%; building the word list is 16%.
          All figures are approximate, based on spellchecking DSPELL.S.
          Therefore, 15+55+16% is absolutely necessary, which is 86%.  Not
          much room for speeding it up.
		- NOTE:  custom dictionary code may run slowly with large
		  dictionaries.
		- added help file, but is still very much under construction.

	DSPELL-D, Changed by Chris Antos, 03/01/96, chrisant@microsoft.com
		- Fixed bug where returning to DSpell after editing the document
		  could say "<word> not found.".  Now we remove words from the
          wordlist until we find a word we recognize.  If all words are
          corrected, DSpell automatically quits (and says "Finished.")
        - Reorganized the code for different "flavors":  File, Rest of File,
          Block, Word.  This fixed a couple bugs if you had a block marked in
          the file but selected some flavor other than Block.
        - Added FLAG.LEX to add words that should be flagged as misspelled
          (overrides SEMWARE.LEX and USER.LEX).  The FLAG.LEX word list can
          be edited via the Options menu.
        - Added support for custom dictionaries.  Use the Options menu to
          edit the list of custom dictionaries.  The words in the
          dictionaries can also be edited from here.
        - AutoSpell used to check as soon as you hit the key, but now it
          waits until after the command (eg, inserting the key you typed) has
          finished.  This helps prevent a problem with Template.Mac where
          AutoSpell could get confused and try to check the abbreviation
          (before it was expanded).  Now it waits until the template is
          expanded.  However, this can cause AutoSpell to sometimes
          accidentally check a word twice if you type <Space> and then <Tab>.
          Since this is not something that happens often, I don't think it
          will be a problem.  Or, alternatively, you can turn off <Tab> key
          AutoSpelling (use the Options menu).
        - The WordList is now a _HIDDEN_ buffer.  You can switch back and
          forth between the document and wordlist by using the mouse or by
          using <Alt [> and <Alt ]> (goto previous/next window).  Or you can
          use the old method of hitting <F7> or <Tab>.  To get back to the
          wordlist, just switch to the wordlist window (via mouse or
          keyboard).  (Or, just run the DSPELL macro with no parameters; for
          most people, you can just hit your DSPELL hotkey).
        - Enhanced mouse support.
        - Various other small bug fixes.

	DSPELL-C, Changed by Chris Antos, 11/27/95, chrisant@microsoft.com
		- Split into two macro files.
		- Fixed bug where adding word didn't go to the next word.
		- Updates # of misspellings when changing word.
		- Using -w on the command line causes DSpell to check only the
          current word.
		- Fixed bug where helpline shows up blank if you normally have it
		  turned off.
		- Added optional startup menu (File, Rest of file, Block, Word or
          just File, Rest of file, Word if no block is marked).
		- Settings are kept in TSEPRO.INI in the Main TSE directory.
          Settings that are saved include AutoSpell on/off, Beep Word, Flash
          Word, Ignore Non Alpha Words, etc.  The old #defines have been
          removed.
        - Added <O> = Options menu.  Or use ExecMacro("dspell -o").
        - Now via the Options menu, you can change the list of filename
          extensions that AutoSpell ignores.
        - When checking the current word (via the startup menu or
          ExecMacro("dspell -w")), DSpell presents a menu just like SemWare's
          SpellChk macro.  It lists the first 10 closest matches, plus
          Ignore, Edit, Add, and Cancel.  This saves keystrokes when checking
          the current word.
        - Fixed bug where DSpell sometimes forgot to restore the WordSet.
        - Workaround for Change All bug where it only changes first
          occurrence.  Seems to be a TSE bug in lReplace.

	DSPELL-B, Changed by Chris Antos, 11/17/95, chrisant@microsoft.com
		- AutoSpell handles hyphenated words.
		- Hyphenated word correction works.
		- Disables AutoSpell in files with certain extensions (Programming
          language files like .s, .h, .cpp, etc).
		- Turns on ShowHelpLine while in DSPELL, restores setting when done.
		- More optimization to shrink macro (ran out of space again).
		- Fixed problem where HelpLine didn't work if DSPELL was bound to a
		  shifted key.
		- Fixed AutoSpell problem when multiple macros bind to <Enter> or
		  <Spacebar>.  Was checking the word multiple times.
		- Fixed problem adding words to USER.LEX.

	DSPELL-A, Changed by Chris Antos, 11/14/95, chrisant@microsoft.com
		- Added foreign letter support (umlauts, accents, etc) for ignoring
		  non-alphabetic words.
		- Fixed so DocumentWindow has focus (WordListWindow used to have
          focus even though DocumentWindow was painted as having the focus;
          _IDLE_ macros that caused repaints would redraw the WordListWindow
          as having the focus).
		- Fixed word list buffer so it is never marked as changed, so
          autosave macros will not try to save it.
		- Auto spell checking while typing!	 (When <Spacebar>, <Enter>, or
		  <GreyEnter> is hit)  (Can be disabled by #define AUTO_SPELL 0)
		- Began work on checking hyphenated words:  currently checks the full
		  word and ignores correctly spelled words, but does not
          intelligently correct them yet.  (Can be disabled by #define
          HANDLE_HYPHENATED_WORDS 0)
		- Optimized tons of stuff b/c ran out of macro space!

	Changed by Chris Antos, 11/09/95, chrisant@microsoft.com
		- Added helplines
		- Added "change only this occurrence"
		- Verifies spelling of new word when correcting word (disable by
		  #define VERIFY_NEW_WORD 0)
		- Handles words like _beleive_ and *wwo!*
		- Handles words like ''brokenn'', 'qoute', 'spellgin
		- Fixed minor bugs
		- Changed UI (A=add, Enter/C=change all, Ctrl-Enter/Shift-C=change,
		  I=ignore, F7=edit document/resume spell)
		- Supports USER.LEX and adding words to USER.LEX
		- Supports PERSONAL.LEX (does not support adding words)
		- Returns back to where you were before starting DSpell (disable by
		  #define RETURN_TO_ORIGIN 0)
		- Ignores non-alphabetic words (disable by #define
		  IGNORE_NON_ALPHA_WORDS 0)
		- Show number of occurrences of each misspelled word
*/



/*
	To Do List:
		- help file.
		- color-picker for selecting word list window colors.
		- show real word in wordlist, have two wordlist files:  visible
		  wordlist file and internal wordlist, with more info.
*/



// Include Files ----------------------------------------------------------

#define INI_FORCESAVE 1
#include ["dspell.si"]

#ifndef WIN32
#include ["ini.si"]
#endif

// string dspell2[] = "dspell2" // old [kn, ri, su, 11-12-2022 13:36:08]
#INCLUDE [ "dspell-e.inc" ]

#define DEBUG_TIME 1



// Global constants -------------------------------------------------------

// key to temporarily override the AutoSpell on/off setting.  to disable this
// feature, set to 0.  or set to whatever key you like.
constant TOGGLE_AUTOSPELL_KEY	= <CtrlShift A>

string bm_ORIGIN[] = "95"
string bm_BEGIN[] = "96"
string bm_END[] = "97"

string noautospellExt[128] = ".s.si.c.cpp.h.hpp.idl.rc.rc2.pp.mak.inc.pas.asm.ui."
string SpellWordSet[32] = ChrSet("A-Za-z'0-9\d128-\d165\d225")
string WordPattern[] = "[A-Za-z'0-9\d128-\d165\d225][A-Za-z'0-9\d128-\d165\d225]#"
string stCheck[] = "[þ] "
string stNoCheck[] = "[ ] "
string stWordlist[] = "*wl*"

// INI strings
string section[] = "DSpell"
string st_AutoSpell[] = "AutoSpell"
string st_BeepWord[] = "BeepWord"
string st_FlashWord[] = "FlashWord"
string st_TabKey[] = "TabKey"
string st_IgnoreNonAlphaWords[] = "IgnoreNonAlphaWords"
string st_VerifyNewWord[] = "VerifyNewWord"
string st_NoAutoSpellExts[] = "NoAutoSpellExts"
string st_Text[] = "WordListTextAttr"
string st_Hilite[] = "WordListHiLiteAttr"
#ifdef WIN32
string st_MisspelledSound[] = "MisspelledSound"
#endif

// error strings
string stERRDICT[] = "Unable to build list of custom dictionaries."



// Global variables -------------------------------------------------------

string FindScope[1]
string wordset[32]
integer beep
integer id_doc = 0, id_wl = 0
integer id_addl = 0, id_ignore = 0, id_flag = 0, id_dict = 0

integer markln = 0, markpos = 0

integer g_fBeepWord,
		g_fFlashWord,
		g_fIgnoreNonAlphaWords,
		g_fAutoSpell,
		g_fTabKey,
		g_fVerifyNewWord

integer g_nText,
		g_nHilite

#ifdef WIN32
string g_stMisspelled[80] = ""
#endif

string stNumDictionaries[] = "NumDictionaries"
string fn_main[PATHLEN] = "semware.lex"
string fn_addl[PATHLEN] = "user.lex"
string fn_flag[PATHLEN] = "flag.lex"



// DLL --------------------------------------------------------------------

#ifdef WIN32
constant SND_SYNC         = 0x0000  /* play synchronously (default) */
constant SND_ASYNC        = 0x0001  /* play asynchronously */
constant SND_NODEFAULT    = 0x0002  /* silence (!default) if sound not found */
constant SND_MEMORY       = 0x0004  /* pszSound points to a memory file */
constant SND_LOOP         = 0x0008  /* loop the sound until next sndPlaySound */
constant SND_NOSTOP       = 0x0010  /* don't stop any currently playing sound */
constant SND_NOWAIT   = 0x00002000  /* don't wait if the driver is busy */
constant SND_ALIAS    = 0x00010000  /* name is a registry alias */
constant SND_ALIAS_ID = 0x00110000  /* alias is a predefined ID */
constant SND_FILENAME = 0x00020000  /* name is file name */
constant SND_RESOURCE = 0x00040004  /* name is resource name or atom */
//#if(WINVER >= 0x0400)
constant SND_PURGE        = 0x0040  /* purge non-static events for task */
constant SND_APPLICATION  = 0x0080  /* look for application specific association */
//#endif /* WINVER >= 0x0400 */
dll "<winmm.dll>"
    integer proc PlaySound(string fn:CStrVal, integer hModule, integer fuSound) : "PlaySound"
end
#endif



// Functions --------------------------------------------------------------

// HelpMe()
proc HelpMe(string topic)
	ExecMacro("gethelp -fdspell.hlp "+topic)
end


// mPlaceMark()
// places bookmark, gives error message on fail
integer proc mPlaceMark(string s)
	integer n = 0

	// weed out multi-char strings, since PlaceMark only looks at first char,
	// and we'd end up doing something we didn't expect.
	if not (Length(s) > 1 and Lower(s[1]) in "a".."z")
		n = PlaceMark(s)
	endif
	if not n
		Set(Break, ON)
		Warn(CurrMacroFilename(), ": Error placing bookmark"; s)
	endif
	return(n)
end


proc mPutHelpLine(string s)
	if Query(ShowHelpLine)
		VGotoXYAbs(1, iif(Query(StatusLineAtTop) == ON, Query(ScreenRows), 1))
		PutHelpLine(Format(" ":-Query(ScreenCols)))
		VGotoXYAbs(1, iif(Query(StatusLineAtTop) == ON, Query(ScreenRows), 1))
		PutHelpLine(s)
	endif
end


proc GetExts()
	string s[127] = noautospellExt

	mPutHelpLine("Do not use spaces between extensions, extensions must begin with a period.")
	loop
		#ifdef BLIND
		Set(X1, 1)
		Set(Y1, 2)
		#endif
		if not Ask("AutoSpell should not work on files with these extensions:", s)
			break
		endif

		if Pos(" ", s)
			Warn("Don't use spaces:  .s.cpp.h.pas.")
		else
			noautospellExt = s
			if noautospellExt[Length(noautospellExt)] <> "."
				noautospellExt = noautospellExt + "."
			endif
			break
		endif
	endloop
	UpdateDisplay(_HELPLINE_REFRESH_)
end


integer proc FCanSpell(string ext)
	if ExistGlobalVar("DS:ForceAutoSpell")
		return(GetGlobalInt("DS:ForceAutoSpell") > 0)
	elseif not g_fAutoSpell
		return(FALSE)
	endif
	return(not Pos(Lower(iif(Length(ext), ext+".", "..")),
			Lower(noautospellExt)))
end


proc ToggleAutoSpell()
	if GetGlobalInt("DS:ForceAutoSpell") > 0
		DelGlobalVar("DS:ForceAutoSpell")
		if FCanSpell(CurrExt())
			SetGlobalInt("DS:ForceAutoSpell", -1)
		endif
	elseif GetGlobalInt("DS:ForceAutoSpell") < 0
		DelGlobalVar("DS:ForceAutoSpell")
		if not FCanSpell(CurrExt())
			SetGlobalInt("DS:ForceAutoSpell", 1)
		endif
	else
		SetGlobalInt("DS:ForceAutoSpell", iif(FCanSpell(CurrExt()), -1, 1))
	endif
	UpdateDisplay(_STATUSLINE_REFRESH_|_REFRESH_THIS_ONLY_)
end


proc Settings()
	ExecMacro(Format(dspell2; "-e"; g_fIgnoreNonAlphaWords; markln; markpos))
end


proc MarkStart()
	markln = CurrLine()
	markpos = CurrPos()

	// tell part 2
	Settings()
end


proc GotoStart()
	GotoXoffset(0)
	GotoLine(markln)
	GotoPos(markpos)
end


proc ToggleVar(var integer f)
	f = not f
end


string proc OnOffStr(integer i)
	return (iif(i, "On", "Off"))
end


proc ReadNum(var integer n)
	string s[10] = Str(n)

	if ReadNumeric(s) and Val(s) >= 0 and Val(s) < 256
		n = Val(s)
	endif
end


proc Save(integer fForceSave)
	// save settings
	WriteProfileInt(section, st_AutoSpell, g_fAutoSpell, ".\dspell-e.ini" )
	WriteProfileInt(section, st_BeepWord, g_fBeepWord, ".\dspell-e.ini" )
	WriteProfileInt(section, st_FlashWord, g_fFlashWord, ".\dspell-e.ini" )
	WriteProfileInt(section, st_TabKey, g_fTabKey, ".\dspell-e.ini" )
	WriteProfileInt(section, st_IgnoreNonAlphaWords, g_fIgnoreNonAlphaWords, ".\dspell-e.ini" )
	WriteProfileInt(section, st_VerifyNewWord, g_fVerifyNewWord, ".\dspell-e.ini" )
	WriteProfileStr(section, st_NoAutoSpellExts, noautospellExt, ".\dspell-e.ini" )
	#ifdef WIN32
	WriteProfileStr(section, st_MisspelledSound, g_stMisspelled, ".\dspell-e.ini" )
	#endif

	WriteProfileInt(section, st_Text, g_nText, ".\dspell-e.ini" )
	WriteProfileInt(section, st_Hilite, g_nHilite, ".\dspell-e.ini" )

	if fForceSave
		// force immediate save to disk
		FlushProfile()
	endif
end


integer proc FindWordIn(string word, integer id)
	integer ok, cid

	cid = GotoBufferId(id)
	GotoStart()
	ok = lFind(word, "w")
	GotoBufferId(cid)
	return (ok)
end


integer proc CheckWord(string word)
	ExecMacro(dspell2+" -c"+word)
	return (Val(Query(MacroCmdLine)))
end


proc RemoveQuotes(var string word)
	ExecMacro(dspell2+" -q"+word)
	word = Query(MacroCmdLine)
end


integer proc GetSuggestions(string word)
	ExecMacro(dspell2+" -h"+word)
	return (Val(Query(MacroCmdLine)))
end


string proc GetSuggestion(integer n)
    ExecMacro(dspell2+" -n"+Str(n))
    return(Query(MacroCmdLine))
end


proc AddToUser(string word)
	integer cid, ml

	if Length(word) >= MIN_WORD_SIZE
		//AddLine(Lower(word), id_addl)
		cid = GotoBufferId(id_addl)
		if cid
			AddLine(Lower(word))
			// keep in sorted order
			PushBlock()
			BegFile()
			MarkLine()
			EndFile()
			MarkLine()
			ml = Set(MsgLevel, _NONE_)
			Sort()
			Set(MsgLevel, ml)
			PopBlock()
			GotoBufferId(cid)
		endif
	endif
end


proc AddToPersonal(string word)
	if Length(word) >= MIN_WORD_SIZE
		AddLine(word, id_ignore)
	endif
end


proc RemoveThisWord()
	if KillLine()
		FileChanged(FALSE)
		if NumLines() and CurrLine() > NumLines()
			Up()
		endif
	endif
end


proc SaveAddlWordList()
	integer cid
	integer i

	cid = GotoBufferId(id_addl)
	if FileChanged()
		SaveAs(fn_addl, _OVERWRITE_)
		FileChanged(FALSE)
	endif
	GotoBufferId(id_flag)
	if FileChanged()
		SaveAs(fn_flag, _OVERWRITE_)
		FileChanged(FALSE)
	endif
	if id_dict and GotoBufferId(id_dict) and FileChanged()
		WriteProfileInt(section, stNumDictionaries, NumLines(), ".\dspell-e.ini" )
		BegFile()
		for i = 1 to NumLines()
			BegLine()
			WriteProfileStr(section, "Dictionary"+Str(i), iif(CurrChar() == Asc("*"), "*", "") + GetToken(GetText(2, 255), " ", 2), ".\dspell-e.ini" )
			Down()
		endfor
		FileChanged(FALSE)
	endif
	GotoBufferId(cid)
end


integer proc CreateWordList()
	integer tmp, cid = GetBufferId()

	// abandon existing buffer
	AbandonFile(GetBufferId(stWordlist))
	// create new buffer
	tmp = CreateBuffer(stWordlist, _HIDDEN_)
	if tmp
		GotoBufferId(cid)
		SetGlobalStr(gstr_findscope, FindScope)
		ExecMacro(dspell2+" -w"+Str(tmp))
		if not Val(Query(MacroCmdLine))
			AbandonFile(tmp)
			tmp = 0
		endif
	else
		Warn("Unable to create buffer for word list.")
	endif
	return(tmp)
end


string proc mGetRawWord()
	lFind("{"+WordPattern+"-$?}|{"+WordPattern+"}", "wxc")
	return (GetFoundText())
end


string proc mGetWord()
	string word[MAXLONGWORD]

	word = mGetRawWord()

	if word[Length(word):1] == "-"
		GotoWindow(DocumentWindow)
		PushPosition()
		GotoPos(CurrPos() + Length(word) - 1)
		if CurrPos() == PosLastNonWhite() and CurrChar() == Asc('-')
			EndLine()
			if WordRight() and isWord()
				word = Lower(word[1:Length(word)-1]+GetWord())
			endif
		endif
		PopPosition()
		GotoWindow(WordListWindow)
	endif

	return(word)
end


integer proc Locate(string word)
	integer fRet = FALSE

	if Length(word)
		GotoWindow(DocumentWindow)
		GotoStart()
		fRet = lFind(word, "w" + FindScope)
		GotoWindow(WordListWindow)
	endif
	return(fRet)
end


integer proc LoadWordsFile(string fn, integer fRequired)
	integer id, cid = GetBufferId()

	if not fRequired and not Length(fn)
		return(0)
	endif

	PushBlock()
	id = CreateTempBuffer()
	if Length(Trim(fn)) and FileExists(fn)
		InsertFile(fn, _DONT_PROMPT_)
		FileChanged(FALSE)
	elseif not fRequired
		AbandonFile(id)
		id = 0
		Warn("Unable to load dictionary"; fn)
	endif
	PopBlock()
	GotoBufferId(cid)
	return (id)
end


integer proc FWordOk(string word)
	integer i

	// make sure word is at least halfway valid
	for i = 1 to Length(word)
		if not GetBit(AlphaWordSet, Asc(word[i]))
			return (FALSE)
		endif
	endfor
	return (TRUE)
end


proc AddWordToList()
	string word[MAXWORD] = ""

	#ifdef BLIND
	Set(X1, 1)
	Set(Y1, 2)
	#endif
	if Ask("Enter word to add:", word) and Length(word)
		word = Lower(Trim(word))
		if lFind(word, "gi")
			Warn('"', word, '" already exists in the list.')
		elseif FWordOk(word)
			AddLine(word)
			ScrollToCenter()
			BegLine()
		else
			Warn('"', word, '" is not a valid word.')
		endif
	endif
end


proc KillWord()
	if CurrLine() > 1
		KillLine()
	endif
end


string words_footer[] = " {F1}-Help  {Ins}-Insert word  {Del}-Delete word  {Esc}-Finished "
keydef EditWordsKeys
<Ins>		AddWordToList() EndProcess(-1)
<GreyIns>	AddWordToList() EndProcess(-1)
<Del>		KillWord()
<GreyDel>	KillWord()
<F1>		HelpMe("Edit Words")
end


proc WordsHelper()
    if Enable(EditWordsKeys)
        ListFooter(words_footer)
    endif
    Unhook(WordsHelper)
    BreakHookChain()
end


proc EditWords(integer id, string title)
	integer cid, fChanged

	cid = GotoBufferId(id)
	if cid
		// remember whether file was changed
		fChanged = FileChanged()
		// insert blank line at top
		BegFile()
		BegLine()
		InsertLine()
		// mark file as not changed
		FileChanged(FALSE)
		Hook(_LIST_STARTUP_, WordsHelper)
		repeat
		until List("Edit " + title, sizeof(words_footer)) <> -1
		UnHook(WordsHelper)
		// remove blank line at top
		BegFile()
		if FileChanged()
			// if file was changed, remove blank line and sort
			KillLine()
			PushBlock()
			UnMarkBlock()
			BegFile()
			MarkLine()
			EndFile()
			MarkLine()
			Sort()
			PopBlock()
		else
			// if file was not changed, remove blank line and restore whether
			// it had been changed before.
			KillLine()
			FileChanged(fChanged)
		endif
		GotoBufferId(cid)
	endif
end


proc AddDictionary()
	string fn[255] = ""
	integer cid, tmp
	integer i

	#ifdef BLIND
	Set(X1, 1)
	Set(Y1, 2)
	#endif
	if AskFilename("Enter filename of dictionary to use:", fn,
			_FULL_PATH_|_MUST_EXIST_) and Length(fn)
		fn = lower(fn)
		if lFind(fn, "gi$")
			Warn(fn, " is already being used.")
		else
			tmp = LoadWordsFile(fn, FALSE)
			if tmp
				i = CurrLine()
				AddLine(stCheck+fn)
				cid = GotoBufferId(id_dict)
				GotoLine(i)
				AddLine(Format("*", tmp; fn))
				GotoBufferId(cid)
			endif
		endif
	endif
end


proc ToggleDictionary()
	integer cid

	BegLine()
	InsertText(iif(GetText(1, sizeof(stCheck)) == stCheck, stNoCheck,
			stCheck), _OVERWRITE_)
	cid = GotoBufferId(id_dict)
	BegLine()
	InsertText(iif(CurrChar() == Asc("*"), " ", "*"), _OVERWRITE_)
	GotoBufferId(cid)
end


string manage_footer[] = " {F1}-Help  {Ins}-Add  {Del}-Remove  {Enter}-Edit Words  {Space}-On/Off  {Esc}-Finished "
keydef ManageKeys
<Enter>		if CurrLineLen()
				EndProcess(1)
			endif
<Spacebar>	ToggleDictionary()
<Ins>		AddDictionary()
			EndProcess(-1)
<GreyIns>	AddDictionary()
			EndProcess(-1)
<Del>		if CurrLine() > 1
				EndProcess(-2)
			endif
<GreyDel>	if CurrLine() > 1
				EndProcess(-2)
			endif
<F1>		HelpMe("Managing Custom Dictionaries")
end


proc ManageHelper()
    if Enable(ManageKeys)
        ListFooter(manage_footer)
    endif
    Unhook(ManageHelper)
    BreakHookChain()
end


proc ManageDictionaries()
	integer tmp, i
	integer cid = GetBufferId()
	integer km = Set(KillMax, 0)
	integer fChanged
	string fn[255]

	if not id_dict
		goto Error
	endif

	tmp = CreateTempBuffer()
	if tmp
		// copy list of dictionaries into tmp buffer
		GotoBufferId(id_dict)
		if NumLines()
			PushBlock()
			UnMarkBlock()
			BegFile()
			MarkLine()
			EndFile()
			MarkLine()
			GotoBufferId(tmp)
			CopyBlock()
			PopBlock()
		endif
		GotoBufferId(tmp)

		// remove buffer ids from tmp list, and show checkboxes
		if NumLines()
			BegFile()
			repeat
				BegLine()
				if CurrChar() == Asc("*")
					DelChar()
					DelRightWord()
					InsertText(stCheck, _INSERT_)
				else
					DelChar()
					DelRightWord()
					InsertText(stNoCheck, _INSERT_)
				endif
			until not Down()
		endif

		// list dictionaries
		// remember whether file was changed
		fChanged = FileChanged()
		// insert blank line at top
		BegFile()
		BegLine()
		InsertLine()
		// mark file as not changed
		FileChanged(FALSE)
		loop
			Hook(_LIST_STARTUP_, ManageHelper)
			case List("Custom Dictionaries", 73)
				when -2
					// remove dictionary
					i = CurrLine()
					KillLine()
					GotoBufferId(id_dict)
					GotoLine(i)
					AbandonFile(Val(GetText(2, 8)))
					KillLine()
					GotoBufferId(tmp)
				when 0
					// finished
					break
				when 1
					// edit words
					i = CurrLine()
					GotoBufferId(id_dict)
					GotoLine(i)
					i = Val(GetText(2, 8))
					fn = GetToken(GetText(2, 255), " ", 2)
					GotoBufferId(tmp)
					EditWords(i, GetText(1, 80))
					GotoBufferId(i)
					if FileChanged()
						SaveAs(fn, _OVERWRITE_)
					endif
					GotoBufferId(tmp)
			endcase
			UnHook(ManageHelper)
		endloop

		// remove blank line at top
		BegFile()
		if FileChanged()
			// if file was changed, just remove blank line
			KillLine()
		else
			// if file was not changed, remove blank line and restore whether
			// it had been changed before.
			KillLine()
			FileChanged(fChanged)
		endif

		GotoBufferId(cid)
		AbandonFile(tmp)

		// save changes
		SaveAddlWordList()
	else
Error:
		Warn(stERRDICT)
	endif

	Set(KillMax, km)
end


proc EditFlagWords()
	EditWords(id_flag, "words to flag")
	SaveAddlWordList()
end


menu ColorMenu()
title = "Word List Colors"
history
	"&Text Color" [g_nText:4], ReadNum(g_nText), DontClose, "Color for word list window."
	"&Current Word Color" [g_nHilite:4], ReadNum(g_nHilite), DontClose, "Color for current word in word list window."
end


#ifdef WIN32
menu Options()
title = "DSpell Options"
history

	//"AutoSpell",, Divide
	"&AutoSpell" [OnOffStr(g_fAutoSpell):3], ToggleVar(g_fAutoSpell), DontClose, "Turns AutoSpell on/off.  AutoSpell checks your spelling as you type."
	"  File E&xtensions...", GetExts(), DontClose, "Choose which file extensions AutoSpell will ignore."
	"  &Beep Misspelled Words" [OnOffStr(g_fBeepWord):3], ToggleVar(g_fBeepWord), DontClose, "AutoSpell beeps when you misspell a word."
	"  Wave File for Misspelled Words" [g_stMisspelled:20], Read(g_stMisspelled), DontClose, "TSE/32 will play this wave file when a misspelled word is typed in."
	"  &Flash Misspelled Words" [OnOffStr(g_fFlashWord):3], ToggleVar(g_fFlashWord), DontClose, "AutoSpell flashes misspelled words."
	"  <&Tab> Key Checking" [OnOffStr(g_fTabKey):3], ToggleVar(g_fTabKey), DontClose, "AutoSpell also checks when you hit <Tab> (as well as <Spacebar> or <Enter>)."
	//"Other Options",, Divide
	"&Ignore Non-Alphabetic Words" [OnOffStr(g_fIgnoreNonAlphaWords):3], ToggleVar(g_fIgnoreNonAlphaWords), DontClose, "DSpell ignores non-alphabetic words."
	"&Verify New Word" [OnOffStr(g_fVerifyNewWord):3], ToggleVar(g_fVerifyNewWord), DontClose, "Checks spelling of corrected word when you type in a new word."
	"Choose &Colors  ", ColorMenu(), DontClose, "Select colors (next version will have a nice UI for picking colors)."
	"&Edit Words to Flag...", EditFlagWords(), DontClose, "Edit the list of words to always flag as misspelled."
	"Custom &Dictionaries...", ManageDictionaries(), DontClose, "Select which custom dictionaries to use."
	"",, Divide
	"&Save Settings", Save(TRUE),, "Saves your settings.  Settings are automatically saved when you exit."
end
#else
menu Options()
title = "DSpell Options"
history

	//"AutoSpell",, Divide
	"&AutoSpell" [OnOffStr(g_fAutoSpell):3], ToggleVar(g_fAutoSpell), DontClose, "Turns AutoSpell on/off.  AutoSpell checks your spelling as you type."
	"  File E&xtensions...", GetExts(), DontClose, "Choose which file extensions AutoSpell will ignore."
	"  &Beep Misspelled Words" [OnOffStr(g_fBeepWord):3], ToggleVar(g_fBeepWord), DontClose, "AutoSpell beeps when you misspell a word."
	"  &Flash Misspelled Words" [OnOffStr(g_fFlashWord):3], ToggleVar(g_fFlashWord), DontClose, "AutoSpell flashes misspelled words."
	"  <&Tab> Key Checking" [OnOffStr(g_fTabKey):3], ToggleVar(g_fTabKey), DontClose, "AutoSpell also checks when you hit <Tab> (as well as <Spacebar> or <Enter>)."
	//"Other Options",, Divide
	"&Ignore Non-Alphabetic Words" [OnOffStr(g_fIgnoreNonAlphaWords):3], ToggleVar(g_fIgnoreNonAlphaWords), DontClose, "DSpell ignores non-alphabetic words."
	"&Verify New Word" [OnOffStr(g_fVerifyNewWord):3], ToggleVar(g_fVerifyNewWord), DontClose, "Checks spelling of corrected word when you type in a new word."
	"Choose &Colors  ", ColorMenu(), DontClose, "Select colors (next version will have a nice UI for picking colors)."
	"&Edit Words to Flag...", EditFlagWords(), DontClose, "Edit the list of words to always flag as misspelled."
	"Custom &Dictionaries...", ManageDictionaries(), DontClose, "Select which custom dictionaries to use."
	"",, Divide
	"&Save Settings", Save(TRUE),, "Saves your settings.  Settings are automatically saved when you exit."
end
#endif


proc DoOptions()
	// allow user to select settings
	Options()
	//UpdateDisplay(_ALL_WINDOWS_REFRESH_)

	// tell part 2 the new settings
	Settings()
end


menu YesNoNew()
history
	"&Yes"
	"&No"
	"&Cancel"
end


menu YesNoAdd()
history = 2
	"&Yes"
	"&No"
	"&Cancel"
end


// ChangeWord
// changes word.
// if fAll == TRUE, changes all occurences.
// if fAll == FALSE, changes only this occurence.
// returns FALSE if cancelled, TRUE if successful.
integer proc ChangeWord(integer fAll)
	string raw_word[MAXLONGWORD]
	string curr_word[MAXLONGWORD]
	string word[MAXLONGWORD]
	string new_word[MAXLONGWORD]
	integer hist, n, km
	integer fRet = FALSE
	integer fHyphen = FALSE

	raw_word = mGetRawWord()
	curr_word = mGetWord()
	word = curr_word
	fHyphen = raw_word <> curr_word

	// handle tex/latex words like ''mispelld''
	RemoveQuotes(word)

	// put suggestions in history
	hist = GetSuggestions(curr_word)

	new_word = word

	tryagain:

	#ifdef BLIND
	Set(X1, 1)
	Set(Y1, 2)
	#endif
	if Ask('Change '+iif(fAll, 'all "', 'only this "') + curr_word +
			'" (<Up> for suggestions)', new_word, hist) and new_word <> word

		// check new word
		if g_fVerifyNewWord and not CheckWord(new_word)
			n = YesNoNew('"'+new_word+'" is not recognized.  Continue?')
			if n == 2
				goto tryagain
			endif
			if n
				n = YesNoAdd('Add "'+new_word+'" to dictionary?')
				if n == 1
					// add new word to dictionary
					AddToUser(new_word)
				endif
			endif
			if not n
				// cancel
				goto alldone
			endif
		endif

		// surround in single quotes for tex/latex
		if word <> curr_word
			n = Pos(word, curr_word)
			new_word = InsStr(new_word, DelStr(curr_word, n, Length(word)), n)
		endif

		// change word(s) in document
		GotoWindow(DocumentWindow)

		if fHyphen
			PushPosition()
			EndLine()
			WordRight()
			km = Set(KillMax, 0)
			DelRightWord()
			Set(KillMax, km)
			PopPosition()
		endif

		if fAll
			PushPosition()
			GotoStart()
			lReplace(raw_word, new_word, "wn"+FindScope)
			PopPosition()
		else
			lReplace(raw_word, new_word, "w1n"+FindScope)
		endif
		fRet = TRUE
		if not fAll
			PushPosition()
			GotoStart()
			if lFind(raw_word, "w"+FindScope)
				PopPosition()
				GotoWindow(WordListWindow)
				if lFind(raw_word, "gw")
					if lFind(occurs, "xc")
						n = Val(GetFoundText(1))-1
						lReplace(occurs, "("+Str(n)+")", "x1")
					endif
				endif
				GotoWindow(DocumentWindow)
				goto dontremove
			endif
			PopPosition()
		endif
		// remove word from word list
		GotoWindow(WordListWindow)
		lReplace(raw_word, new_word, "gwn")
		dontremove:
	endif

	alldone:

	DelHistory(hist)
	//GotoWindow(DocumentWindow)
	//UpdateDisplay(_ALL_WINDOWS_REFRESH_)
	GotoWindow(WordListWindow)
	return (fRet)
end


integer proc NeedToRemoveWord()
	string word[MAXLONGWORD]
	integer fRet = FALSE

	word = mGetRawWord()
	if Length(word)
		fRet = not Locate(word)
		fRet = not fRet and (Length(word) < MIN_WORD_SIZE or
				CheckWord(word) or not FindWordIn(word, id_doc))
	endif
	return(fRet)
end


integer blocktype
proc StoreBlock()
	blocktype = isBlockInCurrFile()
	if blocktype
		PushPosition()
		GotoBlockBegin()
		mPlaceMark(bm_BEGIN)
		GotoBlockEnd()
		mPlaceMark(bm_END)
		PopPosition()
	endif
end


proc RestoreBlock()
	if blocktype
		PushPosition()
		UnMarkBlock()
		GotoMark(bm_BEGIN)
		Mark(blocktype)
		GotoMark(bm_END)
		Mark(blocktype)
		PopPosition()
	endif
end


proc SetupWordListWindow()
	if WindowId() == WordListWindow and GetBufferId() == id_wl
		GotoWindow(DocumentWindow)
		if GetBufferId() == id_doc
			GotoWindow(WordListWindow)
			return()
		endif
	endif

	// setup windows
	OneWindow()
	VWindow()
	GotoBufferId(id_wl)
	ResizeWindow(_LEFT_, 18-Query(WindowCols))
end


integer hi_x, hi_y, hi_len
proc SetupHiLite()
	ScrollToCenter()
	PushBlock()
	MarkFoundText()

	// set x offset
	GotoBlockEnd()
	GotoBlockBegin()

	// get coordinates
	hi_x = Query(WindowX1)+CurrCol()-CurrXoffset()-1
	hi_y = Query(WindowY1)+CurrRow()-1
	hi_len = Min(Query(WindowCols)-CurrCol()+CurrXoffset(),
			Length(GetFoundText()))
	PopBlock()
end


proc NotFound(string s)
	hi_len = 0
	#ifdef WIN32
	Alarm()
	Message(s; "not found.")
	#else
	Message(s; "not found.")
	Sound(440)
	Delay(1)
	NoSound()
	#endif
end


integer fProcessing = FALSE
string helpline[] = "{DSPELL }-Word {1}-Occurrence {A}-Add {C}-Change {I}-Ignore {O}-Options {F7}-Edit {Esc}-Done"
proc ProcessWordListWindow()
	integer ch
	integer fLocate = TRUE, fFinished = FALSE
	string word[MAXLONGWORD]
	string lastword[MAXLONGWORD]
	integer hl = Set(ShowHelpLine, TRUE)

	// set up wordlist window if necessary
	SetupWordListWindow()

	// restore block (if one was stored)
	RestoreBlock()

	// remove word if necessary
	while NeedToRemoveWord()
		RemoveThisWord()
	endwhile

	hi_len = 0
	wordset = Set(WordSet, SpellWordSet)
	beep = Set(Beep, OFF)
	fProcessing = TRUE
	loop
		// if no lines, we're finished
		if not NumLines()
			fFinished = TRUE
			goto finished
		endif

		// show helpline
		VGotoXYAbs(1, iif(Query(StatusLineAtTop) == ON, Query(ScreenRows), 1))
		PutHelpLine(helpline)

		// locate word
		if fLocate
			BegLine()
			lastword = mGetRawWord()
			if Length(lastword)
				GotoWindow(DocumentWindow)
				GotoStart()
				GotoXoffset(0)
				if lFind(lastword, "w" + FindScope)
					SetupHiLite()
				else
					NotFound(lastword)
				endif
				GotoWindow(WordListWindow)
			endif
			fLocate = FALSE
		endif

		// wait for key
		UpdateDisplay()
		ch = GetKey()

		// process key
		case ch
			when <LeftBtn>
				if MouseWindowId() == WordListWindow
					case MouseHotSpot()
						when _MOUSE_MARKING_
							fLocate = TRUE
							TrackMouseCursor()
							BegLine()
						when _MOUSE_UP_, _MOUSE_DOWN_, _MOUSE_PAGEUP_,
								_MOUSE_PAGEDOWN_, _MOUSE_VELEVATOR_
							ProcessHotSpot()
							fLocate = TRUE
							BegLine()
						when _MOUSE_CLOSE_
							goto finished
						when _MOUSE_HRESIZE_, _MOUSE_VRESIZE_
							ProcessHotSpot()
					endcase
				else
					GotoWindow(DocumentWindow)
					PushKey(<LeftBtn>)
					break
				endif
			when <CursorUp>, <GreyCursorUp>
				fLocate = Up()
			when <CursorDown>, <GreyCursorDown>
				fLocate = Down()
			when <PgUp>, <GreyPgUp>
				fLocate = PageUp()
			when <PgDn>, <GreyPgDn>
				fLocate = PageDown()
			when <Home>, <Ctrl PgUp>, <GreyHome>, <Ctrl GreyPgUp>
				fLocate = BegFile()
			when <End>, <Ctrl PgDn>, <GreyEnd>, <Ctrl GreyPgDn>
				fLocate = EndFile()
				BegLine()
			when <a>
				AddToUser(mGetWord())
				RemoveThisWord()
				fLocate = TRUE
			when <n>, <CursorRight>, <GreyCursorRight>
				GotoWindow(DocumentWindow)
				if lFind(lastword, "w+"+FindScope)
					SetupHiLite()
				else
					NotFound(lastword)
				endif
			when <p>, <CursorLeft>, <GreyCursorLeft>
				GotoWindow(DocumentWindow)
				PushPosition()
				if PrevChar() and lFind(lastword, "wb"+FindScope) and
						(CurrLine() > markln or (CurrLine() == markln and
						CurrPos() >= markpos))
					KillPosition()
					SetupHiLite()
				else
					PopPosition()
					NotFound(lastword)
				endif
			when <s>
				// sort word list
				fLocate = CurrRow()
				PushBlock()
				UnMarkBlock()
				BegFile()
				MarkLine()
				EndFile()
				MarkLine()
				Sort(_IGNORE_CASE_)
				FileChanged(FALSE)
				BegFile()
				PopBlock()
				ScrollToRow(fLocate)
				fLocate = TRUE
				Message("Sorted.")
			when <c>, <Enter>, <GreyEnter>
				word = mGetRawWord()
				if word[Length(word):1] == "-"
					goto only_this_occurrence
				endif
				// change all occurrences
				if ChangeWord(TRUE) and NeedToRemoveWord()
					RemoveThisWord()
				endif
				fLocate = TRUE
			when <C>, <Shift C>, <Ctrl Enter>, <Ctrl GreyEnter>
				only_this_occurrence:
				// change only this occurrence
				fLocate = FALSE
				if ChangeWord(FALSE)
					fLocate = TRUE
					if NeedToRemoveWord()
						RemoveThisWord()
					else
						fLocate = FALSE
						GotoWindow(DocumentWindow)
						if lFind(lastword, "w"+FindScope)
							SetupHiLite()
						else
							PushPosition()
							if PrevChar() and
									lFind(lastword, "wb"+FindScope) and
									(CurrLine() > markln or
									(CurrLine() == markln and
									CurrPos() >= markpos))
								KillPosition()
								SetupHiLite()
							else
								PopPosition()
								fLocate = TRUE
							endif
						endif
						GotoWindow(WordListWindow)
					endif
				endif
			when <i>, <Del>, <GreyDel>,
					// <d> key is added for blind users, since keypad is used
					// for reading portions of the screen, and <i> is very
					// inconvenient to reach.
					<d>
				AddToPersonal(mGetWord())
				RemoveThisWord()
				fLocate = TRUE
			when <1>, <f>
				fLocate = TRUE
			when <F1>
				HelpMe("Index")
			when <F7>, <Tab>
				GotoWindow(DocumentWindow)
				break
			when <Alt [>
				PrevWindow()
				break
			when <Alt ]>
				NextWindow()
				break
			when <Escape>, <Shift Escape>, <Ctrl F4>, 0
finished:
				CloseWindow()
				GotoWindow(DocumentWindow)
				#ifdef RETURN_TO_ORIGIN
				if ch <> <Shift Escape>
					// return to origin
					GotoMark(bm_ORIGIN)
				endif
				#endif
				AbandonFile(id_wl)
				id_wl = 0
				id_doc = 0
				SaveAddlWordList()
				break
			when <o>
				DoOptions()
		endcase
		GotoWindow(WordListWindow)
	endloop
	fProcessing = FALSE
	Set(Beep, beep)
	Set(WordSet, wordset)
	Set(ShowHelpLine, hl)
	UpdateDisplay(_WINDOW_REFRESH_|_HELPLINE_REFRESH_)

	if fFinished
		Message("Finished.")
	endif
end


integer proc Load2()
	integer f
	string cmdline[255] = Query(MacroCmdLine)

	// load if not already loaded
	f = isMacroLoaded(dspell2) or LoadMacro(dspell2)

	// if loaded, initialize
	f = f and ExecMacro(Format(dspell2; "-z"; fn_main; id_addl; id_ignore;
			id_flag; id_dict))
	f = f and Val(Query(MacroCmdLine))

	if f
		// tell part 2 what the settings are
		Settings()
	endif

	Set(MacroCmdLine, cmdline)
	return(f)
end


string wsAutoSpell[32] = ChrSet("A-Za-z'0-9\d128-\d165\d225"+'"`'+":;,.?!)]}")
proc AutoSpell(integer fBefore)
	integer	hla, rtw, ok = FALSE
	string ws[32]
	string raw_word[MAXLONGWORD]
	string word[MAXLONGWORD]

	if not FCanSpell(CurrExt()) or BufferType() <> _NORMAL_ or not Load2()
		return()
	endif

	ws = Set(WordSet, SpellWordSet)
	rtw = Set(RemoveTrailingWhite, OFF)
	PushBlock()
	PushPosition()
	UnMarkBlock()
	if fBefore
		InsertText(" ", _INSERT_)
	endif
	PushPosition()
	if Query(Key) == <Tab> and Query(TabType) <> _HARD_
		while DistanceToTab() > 1 and Left() and CurrChar() == 32
		endwhile
	endif
	ok = (Left() and Left() and GetBit(wsAutoSpell, CurrChar()))
	MarkStream()
	PopPosition()
	if ok
		WordLeft()
		MarkStream()
		if Pos(" ", GetMarkedText()) or Pos(Chr(9), GetMarkedText())
			goto recognized
		endif
		UnMarkBlock()

		raw_word = GetWord()
		word = Lower(raw_word)

		if Chr(CurrChar(CurrPos()+Length(raw_word))) == "-"
			goto recognized
		endif
		PushPosition()
		BegWord()
		if CurrPos() == PosFirstNonWhite() and Up() and
				Chr(CurrChar(PosLastNonWhite())) == '-'
			EndLine()
			Left()
			if Left() and isWord()
				word = Lower(GetWord())+word
			endif
		endif
		PopPosition()

		RemoveQuotes(word)

		// do something if word is misspelled
		if Length(word) >= MIN_WORD_SIZE and not CheckWord(word)
			if g_fFlashWord
				// flash word
				PopPosition()
				PushPosition()
				if lFind(raw_word, "b")
					PopBlock()
					PushBlock()
					hla = Set(HiLiteAttr, Color(Bright White on Red))
					HiliteFoundText()
					Set(HiLiteAttr, hla)
				endif
			endif

			if g_fBeepWord
				#ifdef WIN32
				PlaySound(g_stMisspelled, 0, SND_FILENAME|SND_ASYNC)
				#else
				// beep
				Sound(440)
				Delay(1)
				Sound(880)
				Delay(1)
				NoSound()
				#endif
			endif

			#ifdef WIN32
			if g_fFlashWord
				Delay(2)
			endif
			#endif
		endif
	endif

	recognized:
	PopPosition()
	PopBlock()
	Set(RemoveTrailingWhite, rtw)
	Set(WordSet, ws)

	if fBefore
		// remove the space we inserted
		Right()
		BackSpace()
	else
		// mark window as needing repaint (toggle to Hex mode and back)
		DisplayMode(DisplayMode(_DISPLAY_HEX_))
	endif

end


proc Idle()
	UpdateDisplay(_STATUSLINE_REFRESH_|_REFRESH_THIS_ONLY_)
	UnHook(Idle)
end
proc DelayUpdate()
	Hook(_IDLE_, Idle)
	UnHook(DelayUpdate)
end


integer fInUpdate = FALSE
integer ta, ca
proc BeforeUpdateDisplay()
	if WindowId() == WordListWindow and id_wl == GetBufferId()
		// color the word list window
		fInUpdate = TRUE
		ta = Set(TextAttr, g_nText)
		ca = Set(CursorAttr, g_nHilite)
	endif
end


proc AfterUpdateDisplay()
	if fInUpdate
		fInUpdate = FALSE
		Set(TextAttr, ta)
		Set(CursorAttr, ca)
	elseif fProcessing and hi_len and WindowId() == DocumentWindow and
			id_doc == GetBufferId()
		VGotoXYAbs(hi_x, hi_y)
		PutAttr(Query(HiLiteAttr), hi_len)
	endif
end


proc AfterUpdateStatusline()
	VGotoXYAbs(18, Query(StatusLineRow))
	if FCanSpell(CurrExt())
		Set(Attr, iif(GetGlobalInt("DS:ForceAutoSpell") > 0,
				Color(bright white on green), Query(StatusLineAttr)))
		PutChar("S")
	endif
end


integer fSpell = TRUE
proc BeforeCommand()
	if not fSpell or fProcessing
		return()
	endif

	if not g_fTabKey
		if Query(Key) in <Enter>, <GreyEnter>, <Spacebar>
			fSpell = FALSE
			AutoSpell(FALSE)
		endif
	elseif Query(Key) in <Enter>, <GreyEnter>, <Spacebar>, <Tab>
		fSpell = FALSE
		if Query(Key) in <Enter>, <GreyEnter>
			AutoSpell(TRUE)
		endif
	endif
end


proc AfterCommand()
	if not fSpell
		if g_fTabKey and Query(Key) in <Tab>, <Spacebar>
			AutoSpell(FALSE)
		endif
		fSpell = TRUE
	endif

	// if user goes back to WordList window while editing the document,
	// resume spell check (as though they hit the resume key).
	if not fProcessing and WindowId() == WordListWindow and
			GetBufferId() == id_wl
		if Query(Key) == <LeftBtn>
			PushKey(<LeftBtn>)
		endif
		ProcessWordListWindow()
	endif
end


proc CleanUp()
	SaveAddlWordList()
	Save(FALSE)
	PurgeMacro(dspell2)
	DelGlobalVar(gstr_findscope)
end


string proc FindFile(string fn)
	return (SearchPath(fn, Query(TSEPATH), "SPELL\"))
end


proc WhenLoaded()
	string fn[PATHLEN]
	string cmdline[255] = Query(MacroCmdLine)
	integer cid, tmp
	integer i, c
	string ch[1]

	// load settings
	g_fAutoSpell = GetProfileInt(section, st_AutoSpell, TRUE, ".\dspell-e.ini" )
	g_fBeepWord = GetProfileInt(section, st_BeepWord, TRUE, ".\dspell-e.ini" )
	g_fFlashWord = GetProfileInt(section, st_FlashWord, TRUE, ".\dspell-e.ini" )
	g_fTabKey = GetProfileInt(section, st_TabKey, TRUE, ".\dspell-e.ini" )
	g_fIgnoreNonAlphaWords = GetProfileInt(section, st_IgnoreNonAlphaWords, TRUE, ".\dspell-e.ini" )
	g_fVerifyNewWord = GetProfileInt(section, st_VerifyNewWord, TRUE, ".\dspell-e.ini" )
	noautospellExt = GetProfileStr(section, st_NoAutoSpellExts, noautospellExt, ".\dspell-e.ini" )
	#ifdef WIN32
	g_stMisspelled = GetProfileStr(section, st_MisspelledSound, "", ".\dspell-e.ini" )
	#endif
	g_nText = GetProfileInt(section, st_Text, Query(MenuTextAttr), ".\dspell-e.ini" )
	g_nHilite = GetProfileInt(section, st_Hilite, Query(HiLiteAttr), ".\dspell-e.ini" )

	// find and load dictionaries
	fn_main = FindFile(fn_main)
	if not Length(fn_main)
		Warn("Unable to find SEMWARE.LEX")
		PurgeMacro(CurrMacroFilename())
		return()
	endif

	fn = FindFile(fn_addl)
	fn_addl = iif(Length(fn), fn, SplitPath(fn_main, _DRIVE_|_PATH_) + fn_addl)
	fn = FindFile(fn_flag)
	fn_flag = iif(Length(fn), fn, SplitPath(fn_main, _DRIVE_|_PATH_) + fn_flag)

	id_addl = LoadWordsFile(fn_addl, TRUE)
	id_ignore = LoadWordsFile(FindFile("personal.lex"), TRUE)
	id_flag = LoadWordsFile(fn_flag, TRUE)

	c = GetProfileInt(section, stNumDictionaries, 0, ".\dspell-e.ini" )
	cid = GetBufferId()
	id_dict = CreateTempBuffer()
	if id_dict
		for i = 1 to c
			fn = GetProfileStr(section, "Dictionary"+Str(i), "", ".\dspell-e.ini" )
			if fn[1] == "*"
				ch = fn[1]
				fn = fn[2:255]
			else
				ch = " "
			endif
			tmp = LoadWordsFile(fn, FALSE)
			AddLine(Format(ch, tmp; fn))
		endfor
		BegFile()
		FileChanged(FALSE)
		GotoBufferId(cid)
	else
		Warn(stERRDICT)
		PurgeMacro(CurrMacroFilename())
		return()
	endif

	// hooks
	Hook(_ON_ABANDON_EDITOR_, CleanUp)
	Hook(_BEFORE_UPDATE_DISPLAY_, BeforeUpdateDisplay)
	Hook(_AFTER_UPDATE_DISPLAY_, AfterUpdateDisplay)
	Hook(_AFTER_UPDATE_STATUSLINE_, AfterUpdateStatusline)
	Hook(_BEFORE_COMMAND_, BeforeCommand)
	Hook(_AFTER_COMMAND_, AfterCommand)

	Set(MacroCmdLine, cmdline)

	// update the AutoSpell indicator on the statusline (dont call
	// UpdateDisplay in WhenLoaded or the signon screen can get messed up).
	Hook(_BEFORE_UPDATE_DISPLAY_, DelayUpdate)
end


proc WhenPurged()
	integer cid = GetBufferId()

	CleanUp()

	// free dictionaries
	AbandonFile(id_addl)
	AbandonFile(id_ignore)
	AbandonFile(id_flag)
	AbandonFile(id_wl)
	if id_dict and GotoBufferId(id_dict)
		BegFile()
		while NumLines()
			// free dictionary buffer
			AbandonFile(Val(GetText(2, 8)))
			// remove entry
			KillLine()
		endwhile
		AbandonFile(id_dict)
		GotoBufferId(cid)
	endif
end


integer number_suggestion, suggestion
string proc GetNextSuggestion()
    string word[MAXWORD] = ""

    if number_suggestion
        number_suggestion = number_suggestion - 1
        suggestion = suggestion + 1
        word = GetSuggestion(suggestion)
        if Length(word) < sizeof(word)
            word = Format(' ', word:-MAXWORD)
        endif
    endif
    return (word)
end


constant IGNORE = 12, EDIT = 13, ADD = 14
menu WhatToDoMenu()
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    ""[GetNextSuggestion():MAXWORD]
    "",,DIVIDE
    "&Ignore for Rest of Session"
    "&Edit"
    "&Add to Word List"
    "&Cancel"
end


proc SpellWord()
	string raw_word[MAXWORD], curr_word[MAXWORD], word[MAXWORD],
			new_word[MAXWORD]
	integer n, km
	integer fHyphen = FALSE
	integer fEndOfWord = FALSE

	PushPosition()
	wordset = Set(WordSet, SpellWordSet)
	n = BegWord()
	if not n
		n = Left() and BegWord()
		fEndOfWord = TRUE
	endif
	if n
		raw_word = GetWord()
		curr_word = raw_word
		word = curr_word

		PushPosition()
		BegWord()
		if CurrPos() == PosFirstNonWhite() and Up() and
				Chr(CurrChar(PosLastNonWhite())) == '-'
			EndLine()
			Left()
			raw_word = GetWord(TRUE)
			curr_word = raw_word
			word = curr_word
			EndLine()
			if WordRight() and isWord()
				fHyphen = TRUE
				curr_word = curr_word[1:Length(curr_word)-1]+GetWord()
				word = curr_word
			endif
			KillPosition()
			PushPosition ()
		endif
		PopPosition()

		RemoveQuotes(word)

		// check spelling
		if Length(word) >= MIN_WORD_SIZE and not CheckWord(word)
			// menu to change word
			showmenu:
		    suggestion = 0
		    ExecMacro(dspell2+" -g"+word)
		    number_suggestion = Val(Query(MacroCmdLine))

		    case WhatToDoMenu('"'+word+'" not found')
		        when 1 .. 10
		            if MenuOption() <= suggestion
		            	new_word = GetSuggestion(MenuOption())
		            	goto changeword
		            else
		            	goto showmenu
		            endif
		        when IGNORE
		            AddToPersonal(word)
		        when EDIT
					tryagain:

					new_word = word
					#ifdef BLIND
					Set(X1, 1)
					Set(Y1, 2)
					#endif
					if Ask('Change "' + word + '"', new_word) and
							new_word <> word
						// check new word
						if g_fVerifyNewWord and not CheckWord(new_word)
							n = YesNoNew('"'+new_word+'" is not recognized.  Continue?')
							if n == 2
								goto tryagain
							endif
							if n
								n = YesNoAdd('Add "'+new_word+'" to dictionary?')
								if n == 1
									// add new word to dictionary
									AddToUser(new_word)
								endif
							endif
							if not n
								// cancel
								goto cancel
							endif
						endif

						changeword:
						// surround in single quotes for tex/latex
						if word <> curr_word
							n = Pos(word, curr_word)
							new_word = InsStr(new_word, DelStr(curr_word, n, Length(word)), n)
						endif

						if fHyphen
							PushPosition()
							EndLine()
							WordRight()
							km = Set(KillMax, 0)
							DelRightWord()
							Set(KillMax, km)
							PopPosition()
						endif

						lReplace(raw_word, new_word, "wn1")

						if fEndOfWord
							EndWord()
							KillPosition()
							PushPosition()
						endif
					endif
					cancel:
		        when ADD
		            AddToUser(word)
		    endcase
		else
			Message("Word is recognized.")
		endif
	else
		Message("No word.")
	endif
	Set(WordSet, wordset)
	PopPosition()
end


proc Spell(integer nFlavor)
	integer cid, n

	// sanity checks
	if WindowId() == WordListWindow and id_wl and
			id_wl == GetBufferId(stWordlist)
		Warn("Why are you trying to spellcheck the wordlist??!?")
		return()
	endif

	// end block marking mode, in case it was on
	Set(Marking, OFF)

	// if auto mode, decide which mode to use
	FindScope = ""
	if nFlavor == SPELL_AUTO
		if id_wl and id_wl == GetBufferId(stWordlist) and
				WindowId() <> WordListWindow
			n = WindowId()
			if GotoWindow(WordListWindow) and id_wl == GetBufferId()
				// resume spell check
				ProcessWordListWindow()
				return()
			endif
			GotoWindow(n)
		endif
		nFlavor = iif(isCursorInBlock(), SPELL_BLOCK, SPELL_FILE)
	endif

	// mark where to start spell check
	PushPosition()
	case nFlavor
		when SPELL_FILE
			BegFile()
		when SPELL_REST
			BegWord()
		when SPELL_BLOCK
			if isBlockInCurrFile()
				StoreBlock()
				GotoBlockBegin()
				FindScope = "l"
			else
				Warn("There is no block marked in this file.")
				PopPosition()
				return()
			endif
		when SPELL_WORD
			SpellWord()
			KillPosition()
			return()
	endcase
	MarkStart()
	PopPosition()

	#ifdef RETURN_TO_ORIGIN
	// mark origin
	mPlaceMark(bm_ORIGIN)
	#endif

	// setup word list, do the interactive spell check
	id_doc = GetBufferId()
	#ifndef DEBUG_TIME
	id_wl = CreateWordList()
	#else
	SetGlobalInt("Ticks", GetClockTicks())
	id_wl = CreateWordList()
	SetGlobalInt("Ticks", GetClockTicks() - GetGlobalInt("Ticks"))
	#endif

	if id_wl
		#ifdef BLIND
		Sound(660)
		Delay(2)
		NoSound()
		#endif

		cid = GotoBufferId(id_wl)
		n = NumLines()
		GotoBufferId(cid)
		if n
			#ifdef DEBUG_TIME
			Message(n; "unrecognized words found in"; GetGlobalInt("Ticks"); "clock ticks.")
			DelGlobalVar("Ticks")
			#else
			Message(n; "unrecognized words found.")
			#endif
			ProcessWordListWindow()
		else
			#ifdef DEBUG_TIME
			Message(n; "unrecognized words found in"; GetGlobalInt("Ticks"); "clock ticks.")
			DelGlobalVar("Ticks")
			#else
			Message("No unrecognized words found.")
			#endif
			AbandonFile(id_wl)
			id_wl = 0
			id_doc = 0
		endif
	endif
end


menu SpellMenu1()
title = "DSpell"
history
	"&File", Spell(SPELL_FILE)
	"&Rest of file", Spell(SPELL_REST)
	"&Word", Spell(SPELL_WORD)
end


menu SpellMenu2()
title = "DSpell"
history
	"&File", Spell(SPELL_FILE)
	"&Rest of file", Spell(SPELL_REST)
	"&Block", Spell(SPELL_BLOCK)
	"&Word", Spell(SPELL_WORD)
end


proc Main()
	if not Load2()
		return()
	endif

	case Query(MacroCmdLine)
		when "-f"
			Spell(SPELL_FILE)
		when "-b"
			Spell(SPELL_BLOCK)
		when "-w"
			Spell(SPELL_WORD)
		when "-r"
			Spell(SPELL_REST)
		when "-o"
			DoOptions()
		when "-m"
			if isBlockInCurrFile()
				SpellMenu2()
			else
				SpellMenu1()
			endif
		otherwise
			Spell(SPELL_AUTO)
	endcase
end


<TOGGLE_AUTOSPELL_KEY>		ToggleAutoSpell()

