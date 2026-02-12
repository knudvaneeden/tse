// FS.S ù File Settings Macro Package
// Christopher Antos



// This macro is provided AS-IS, with little or no documentation. I hope you
// find it useful, but I cannot afford the time right now to give it a
// user-friendly configuration UI; maybe someday. If you want to change the
// settings or colors it uses for certain file types, you will need to modify
// macro by hand.



constant HELP_SCREEN_KEY = 0

// colors used for _HIDDEN_ and _SYSTEM_ buffers
constant SYSTEMBUF_TEXTATTR = Color(bright white on green)
constant SYSTEMBUF_CURSORATTR = Color(bright white on white)

/*
	To add new settings to track, you will need to modify these functions:
		ù _InsertSettings() - store settings into the FS buffer
		ù _RestoreSettings() - use settings stored in the FS buffer
		ù FSDecideSettings() - decide settings for file
*/



// Help -------------------------------------------------------------------

helpdef FSHelp
	Title = "File Settings Package for TSE 2.5"
" Use this at your own risk!"
' This macro is supplied "as-is"!'
""
' NOTE:  The "factory installed" version will hopefully be'
"        sufficient for your needs, but you may need to"
"        tailor the FSDecideSettings routine to select"
"        settings that better fit your preferences."
""
" The File Settings package keeps track of certain settings "
" for each individual file in the ring.  The settings are"
" not saved between sessions of the editor."
""
" The settings that are tracked currently are:"
"   ù TabType"
"   ù TabWidth"
"   ù VarTabs"
"   ù ExpandTabs"
"   ù RemoveTrailingWhite"
"   ù WordWrap"
"   ù AutoIndent"
"   ù LeftMargin"
"   ù RightMargin"
"   ù TextAttr"
"   ù CursorAttr"
"   ù HiLiteAttr"
"   ù BlockAttr"
"   ù CursorInBlockAttr"
" Feel free to add your own."
""
" When FS.MAC is executed, this help is displayed.  When"
" FS is loaded, your settings are automatically maintained."
""
" NOTE:"
' Instead of using SaveSettings() or ExecMacro("iconfig"),'
' be sure to use ExecMacro("fs -s") or ExecMacro("fs -i"),'
" respectively, or the current settings will be saved as"
" your default settings."
""
" Command Line Parameters"
"   ù -c   show the Current Settings menu"
"   ù -m   show the Default Settings menu"
"   ù -s   replacement for SaveSettings()"
'            MacroCmdLine is "1" on success,'
'            or "0" on failure.'
'   ù -i   replacement for ExecMacro("iconfig")'
"   ù -d   list the contents of the tracking buffer (debug)"
end



// Binaries ---------------------------------------------------------------

binary ["bitset.bin"]
	integer proc WrdChrs2WrdSet(string LetterSet, var string Result) : 0
	integer proc TabSet2TabPosns(string VTabSet, var string TabStr) : 3
	integer proc TabPosns2TabSet(string TabStr, var string VTabSet) : 6
	integer proc WrdSet2WrdChrs(string BitSet, var string Result) : 9
end



// Variables --------------------------------------------------------------

integer fs_buffer = 0	// id of the settings buffer
string def_buf_name[] = "$FS-default$"



// Forwards ---------------------------------------------------------------

forward proc _InsertSettings(string fn)
forward integer proc _UpdateSettings()
forward proc _RestoreSettings()
forward proc UseDefSettings()



// Error Message Functions ------------------------------------------------

#if 0
proc ErrMessage(string s)
	Message(s)
	VGotoXYAbs(1, Query(StatusLineRow))
	PutAttr(Color(bright white on red), Query(ScreenCols))
end
#endif



// Public Functions -------------------------------------------------------

integer proc isOkBuffer()
	return (BufferType() == _NORMAL_)
end


proc debugFileSettings()
	integer cid = GetBufferId()

	if isOkBuffer() and GotoBufferId(fs_buffer)
		PushPosition()
		lList("Debug FileSettings List",
				1000, NumLines()+2, _ENABLE_HSCROLL_)
		PopPosition()
		GotoBufferId(cid)
	endif
end


public proc FSPreSaveSettings()
	UseDefSettings()
	SetHookState(OFF, _ON_CHANGING_FILES_)
end


public proc FSPostSaveSettings()
	integer cid = GetBufferId()

	if isOkBuffer() and GotoBufferId(fs_buffer)
		if PosFirstNonWhite() <> 0
			_RestoreSettings()
		endif
		GotoBufferId(cid)
	endif
	SetHookState(ON, _ON_CHANGING_FILES_)
end


public proc FSIConfig()
	FSPreSaveSettings()
	ExecMacro("iconfig")
	FSPostSaveSettings()
end


public proc FSSaveSettings()
	FSPreSaveSettings()
	if YesNo("Overwrite existing config?") == 1
		if SaveSettings()
			FSPostSaveSettings()
			Set(MacroCmdLine, Str(TRUE))
			return()
		else
			Warn("Error updating executable")
		endif
	endif
	FSPostSaveSettings()
	Set(MacroCmdLine, Str(FALSE))
end



// Functions --------------------------------------------------------------

// FSDecideSettings
// pick tab width and other settings base on file extension or filename.
// if you add more settings, change this function to initialize them
// for each file base on filename or whatever.
proc FSDecideSettings(string fn)
	string name[10] = SplitPath(fn, _NAME_)
	string ext[5] = SplitPath(fn, _EXT_)

	// prep ext for easy comparison (NOTE: in the comparisons below, always
	// make sure there's a trailing period!)
	ext = iif(Length(ext), ext+".", "..")

	// init by using default settings.
	// rest of function overrides default settings as necessary.
	UseDefSettings()

	//$ if you add settings, update this function.

	// WordWrap/AutoIndent/LeftMargin/RightMargin
	if Pos(ext, ".doc.txt.")
		// doc settings
		Set(WordWrap, _AUTO_)
		Set(AutoIndent, OFF)
		Set(LeftMargin, 9)
		Set(RightMargin, 72)
	elseif Pos(ext, ".m.")
		// email file settings
		Set(WordWrap, _AUTO_)
		Set(AutoIndent, OFF)
		Set(LeftMargin, 0)
		Set(RightMargin, 60)
	elseif Pos(ext, ".pas.s.ui.si.c.h.cpp.hpp.rc.idl.mak.asm.inc.prg.bas.lst.")
		// programming settings
		Set(WordWrap, OFF)
		Set(AutoIndent, _STICKY_)
		Set(LeftMargin, 0)
		Set(RightMargin, 77)
	endif

	// TabWidth/TabType/TextAttr/CursorAttr
	if Pos(ext, ".pas.bas.")
		Set(TabWidth, 2)
		Set(TabType, _HARD_)
		Set(TextAttr, Color(bright cyan on blue))
		Set(CursorAttr, Color(bright yellow on blue))
	elseif Pos(ext, ".s.ui.si.")
		Set(TabWidth, 4)
		Set(TabType, _HARD_)
	elseif Pos(ext, ".c.h.cpp.hpp.rc.rc2.idl.pp.")
		Set(TabWidth, 4)
		Set(TabType, _HARD_)
	elseif Pos(ext, ".mak.") or name == "makefile"
		Set(TabWidth, 4)
		Set(TabType, _HARD_)
		Set(TextAttr, Color(bright cyan on blue))
		Set(CursorAttr, Color(black on white))
	elseif Pos(ext, ".asm.inc.prg.lst.")
		Set(TabWidth, 8)
		Set(TabType, _HARD_)
	elseif Pos(ext, ".doc.txt.m.")
		Set(TabWidth, 4)
		Set(TabType, _SOFT_)
		Set(TextAttr, Color(bright cyan on blue))
		Set(CursorAttr, Color(bright yellow on blue))
	endif

	// RemoveTrailingWhite
	if Pos(ext, ".uue.")
		Set(RemoveTrailingWhite, FALSE)
	elseif Pos(ext, ".s.ui.si.")
		Set(RemoveTrailingWhite, TRUE)
	elseif Pos(ext, ".c.h.cpp.hpp.rc.rc2.idl.mak.pp.")
		// this turns off RemoveTrailingWhite for files in the top secret
		// project I'm working on at some as yet undisclosed company name.
		// (gee whiz these NDA's).
		if Pos("\ren\", fn)
			Set(RemoveTrailingWhite, FALSE)
		else
			Set(RemoveTrailingWhite, TRUE)
		endif
	elseif Pos(ext, ".asm.inc.prg.pas.lst.")
		Set(RemoveTrailingWhite, TRUE)
	endif
end


#if 0
// FSRemoveFile
// removes file entry from FS buffer.
integer proc FSRemoveFile()
	integer cid = GetBufferId()

	// remove file from FileSettings list
	if isOkBuffer() and GotoBufferId(fs_buffer)
		if PosFirstNonWhite() <> 0
			KillLine()
		endif
		GotoBufferId(cid)
	endif

	return(TRUE)
end
#endif


// _InsertLine
// inserts new line in FS buffer.
// if you add more settings, change this to also add your settings.
proc _InsertSettings(string fn)
	BegLine()

	if Length(fn)
		// the filename ends up at the end of the line
		InsertLine()
		InsertText(" ³ "+fn, _INSERT_)
		BegLine()
	endif

	//$ if you add settings, update this function.

	// Format is used to make it pretty for viewing via debugFileSettings.
	// widths are chosen to be max width of field + 1 to ensure spaces
	// in between so GetToken works.
	InsertText(Query(VarTabs), _INSERT_)
	InsertText(Format(Query(TabType):2), _INSERT_)
	InsertText(Format(Query(TabWidth):3), _INSERT_)
	InsertText(Format(Query(ExpandTabs):2), _INSERT_)
	InsertText(Format(Query(RemoveTrailingWhite):2), _INSERT_)
	InsertText(Format(Query(WordWrap):2), _INSERT_)
	InsertText(Format(Query(AutoIndent):2), _INSERT_)
	InsertText(Format(Query(LeftMargin):5), _INSERT_)
	InsertText(Format(Query(RightMargin):5), _INSERT_)
	InsertText(Format(Query(TextAttr):5), _INSERT_)
	InsertText(Format(Query(CursorAttr):5), _INSERT_)
	InsertText(Format(Query(HiLiteAttr):5), _INSERT_)
	InsertText(Format(Query(BlockAttr):5), _INSERT_)
	InsertText(Format(Query(CursorInBlockAttr):5), _INSERT_)
end


// _UpdateSettings
// updates line in the FS buffer.
integer proc _UpdateSettings()
	PushBlock()
	BegLine()
	MarkChar()
	lFind(" ³ ", "c")
	MarkChar()
	KillBlock()
	PopBlock()
	_InsertSettings("")
	return (TRUE)
end


// _RestoreSettings
// restores saved settings from line in the FS buffer.
// if you add more settings, change this to also restore your new settings.
proc _RestoreSettings()
	string tok[200] = GetText(1, 200)

	//$ if you add settings, update this function.
	Set(VarTabs, tok[1:32])
	tok = DelStr(tok, 1, 32)
	Set(TabType, Val(GetToken(tok, " ", 1)))
	Set(TabWidth, Val(GetToken(tok, " ", 2)))
	Set(ExpandTabs, Val(GetToken(tok, " ", 3)))
	Set(RemoveTrailingWhite, Val(GetToken(tok, " ", 4)))
	Set(WordWrap, Val(GetToken(tok, " ", 5)))
	Set(AutoIndent, Val(GetToken(tok, " ", 6)))
	Set(LeftMargin, Val(GetToken(tok, " ", 7)))
	Set(RightMargin, Val(GetToken(tok, " ", 8)))
	Set(TextAttr, Val(GetToken(tok, " ", 9)))
	Set(CursorAttr, Val(GetToken(tok, " ", 10)))
	Set(HiLiteAttr, Val(GetToken(tok, " ", 11)))
	Set(BlockAttr, Val(GetToken(tok, " ", 12)))
	Set(CursorInBlockAttr, Val(GetToken(tok, " ", 13)))
end


// UseDefSettings
// uses the stored default settings.
proc UseDefSettings()
	integer cid = GetBufferId()

	if isOkBuffer() and GotoBufferId(fs_buffer)
		PushPosition()
 		if PosFirstNonWhite() <> 0 and _UpdateSettings() and
 				lFind(" ³ "+def_buf_name, "$g")
			_RestoreSettings()
		else
			Warn("Unable to find default settings in FileSettings buffer.")
		endif
		PopPosition()
		GotoBufferId(cid)
	endif
end


// FSInsertFile
// inserts new file entry into FS buffer.
integer proc FSInsertFile()
	string fn[100] = CurrFilename()
	integer cid = GetBufferId()

	// insert new entry into FileSettings list
	if isOkBuffer() and GotoBufferId(fs_buffer)
		_InsertSettings(fn)
		GotoBufferId(cid)
	endif

	return(TRUE)
end



// Hooks ------------------------------------------------------------------

string stCurrFilename[255] = ""
proc FSOnChangingFiles()
	integer cid = GetBufferId()

	if isOkBuffer()
		stCurrFilename = CurrFilename()
		if GotoBufferId(fs_buffer)
 			if PosFirstNonWhite() <> 0 and _UpdateSettings() and
	 				lFind(" ³ "+stCurrFilename, "$g")
				// file in list, use its settings
				_RestoreSettings()
				GotoBufferId(cid)
			else
				// if file not in list, decide settings and add it
				GotoBufferId(cid)
				FSDecideSettings(stCurrFilename)
				FSInsertFile()
			endif
		endif
	endif
end


proc OnIdle()
	if isOkBuffer() == _NORMAL_ and CurrFilename() <> stCurrFilename
		// this should help users running macros that are not careful about
		// calling GotoBufferId vs. PopPosition, etc, appropriately.
		FSOnChangingFiles()
	endif
end



// Menu Helpers -----------------------------------------------------------

string proc OnOffStr(integer i)
	return (iif(i, "On", "Off"))
end


integer proc ReadNum(integer n)
	string s[5] = str(n)

	return (iif(ReadNumeric(s), val(s), n))
end ReadNum


proc SetVarTabs()
	string s[255] = "", t[32] = ""

	TabSet2TabPosns(Query(VarTabs), s)
	if Ask("Variable Tab stops:", s)
		TabPosns2TabSet(s, t)
		Set(VarTabs, t)
	endif
end



// Menus ------------------------------------------------------------------

menu AutoIndentMenu()
	history = Query(AutoIndent) + 1
	command = Set(AutoIndent,MenuOption()-1)

	"O&ff"      ,, CloseBefore
	"O&n"       ,, CloseBefore
	"&Sticky"   ,, CloseBefore
end


menu WordWrapMenu()
	history = Query(WordWrap) + 1
	command = Set(WordWrap,MenuOption()-1)

	"O&ff"      ,, CloseBefore
	"O&n"       ,, CloseBefore
	"&Auto"     ,, CloseBefore
end


menu TabTypeMenu()
	history = Query(TabType) + 1
	command = Set(TabType,MenuOption()-1)

	"&Hard"     ,, CloseBefore
	"&Soft"     ,, CloseBefore
	"Smar&t"    ,, CloseBefore
	"&Variable" ,, CloseBefore
end


menu FSSettings()
	history

	"&AutoIndent" [MenuStr(AutoIndentMenu,Query(AutoIndent)+1) : 6],
							AutoIndentMenu(), DontClose
	"&WordWrap" [MenuStr(WordWrapMenu,Query(WordWrap)+1) : 4],
							WordWrapMenu(), DontClose
	"&Left Margin" [Str(Query(LeftMargin)) : 5],
							Set(LeftMargin, ReadNum(Query(LeftMargin))), DontClose
	"&Right Margin" [Str(Query(RightMargin)) : 5],
							Set(RightMargin, ReadNum(Query(RightMargin))), DontClose
	"",,Divide
	"Tab Ty&pe" [MenuStr(TabTypeMenu,Query(TabType)+1) : 8],
							TabTypeMenu(), DontClose
	"&Tab Width" [Str(Query(TabWidth)) : 5],
							ReadNum(Query(TabWidth)), DontClose
	"&Variable Tab Stops...", SetVarTabs(), DontClose
	"&Expand Tabs" [OnOffStr(Query(ExpandTabs)) : 3],
							Toggle(ExpandTabs), DontClose
	"",,Divide
	"Remove Trailing White" [OnOffStr(Query(RemoveTrailingWhite)) : 3],
							Toggle(RemoveTrailingWhite), DontClose
end



// Auto Macros ------------------------------------------------------------

proc WhenLoaded()
	integer cid = 0

	if NumFiles() > 0
		cid = GetBufferId()
	endif

	fs_buffer = CreateTempBuffer()
	if not fs_buffer
		Warn("Unable to create FileSettings buffer.")
		PurgeMacro(CurrMacroFilename())
		return()
	endif

	// grabs current settings and marks them as the defaults
	_InsertSettings(def_buf_name)

	if cid
		GotoBufferId(cid)
	endif

	Hook(_ON_CHANGING_FILES_, FSOnChangingFiles)
	// to reduce the errors other users will run into with macros that do not
	// correctly use GotoBufferId and/or PopPosition, etc, we check the
	// filename to see if it's different from what we expect, and forcibly
	// call FSOnChangingFiles.
	Hook(_IDLE_, OnIdle)
end


proc WhenPurged()
	// go back to default settings
	UseDefSettings()

	if fs_buffer
		AbandonFile(fs_buffer)
	endif

	UnHook(FSOnChangingFiles)
end



// Main -------------------------------------------------------------------

proc Main()
	case Lower(Trim(Query(MacroCmdLine)))
		when "-m"
			FSPreSaveSettings()
			FSSettings("Default Settings")
			FSPostSaveSettings()
		when "-c"
			FSSettings("Current Settings")
		when "-d"
			debugFileSettings()
		when "-i"
			FSIConfig()
		when "-s"
			FSSaveSettings()
		otherwise
			QuickHelp(FSHelp)
	endcase
end

<HELP_SCREEN_KEY>	QuickHelp(FSHelp)
