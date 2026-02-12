// CHGNOTIF.S

/*

Description ---------------------------------------------------------------

Detects when any file in the ring has been changed outside of TSE.  Works with
TSE 2.6 and higher on both Windows 95 and Windows NT.

Cannot work with TSE 2.5; only native Windows applications can get file change
notifications, and TSE 2.5 is a DOS app, not a Windows app.


Notes ---------------------------------------------------------------------

ù CHGNOTIF will alert you if you use the SaveAs or WriteBlock commands to save
  over a file that is currently loaded in TSE.  I think this is a valuable
  feature, which is lucky since it would be pretty difficult to prevent this.

ù Run "CHGNOTIF -o" to get the Options menu.  CHGNOTIF can optionally
  automatically reload a file that has not been changed in TSE (this is NOT
  the default setting).

ù When a file has been changed in TSE and also changed outside of TSE, you
  have the extra option of running CMPFILES to merge them by hand.


Wish List -----------------------------------------------------------------

ù Maybe every 10 minutes, run Sync in case the DLL has gotten out of sync with
  the ring.  I don't think this is necessary; just a precaution that could be
  added.


History -------------------------------------------------------------------

v1.4, 02/10/99
ù TSE 3.0 has added the _AFTER_FILE_SAVE_ hook!  This enables us to have much
  better control over things.

v1.5, 04/13/01
ù added public macro CHGNOTIF_DontWatch() to turn off change notifications 
  permanently (during the current editing session) for the current file.
ù added public macro CHGNOTIF_ForceChanged() to mark a file as changed.
ù added public macro CHGNOTIF_ForceGone() to mark a file as gone (deleted).
ù added public macro CHGNOTIF_ForceNotChanged() to mark a file as not changed.
ù added public macro CHGNOTIF_GetVersion() to return the version of CHGNOTIF; 
  note that the version is base-16 internally, but is returned as base-10.
ù since more than one macro can hook _AFTER_FILE_SAVE_, it is not that 
  helpful, has been replaced by _AFTER_COMMAND_ and _AFTER_NONEDIT_COMMAND_.
ù added public macro CHGNOTIF_ChangeExpectedReset() to reset whether a file 
  expects changes.  CHGNOTIF_ChangeExpectedYes and CHGNOTIF_ChangeExpectedNo 
  can be nested now, but are reset on idle or before a command.

v1.6, 09/09/01
ù Windows XP (or eTrust?) has an issue that fools Chgnotif into thinking the 
  file attributes have temporarily changed, and we work around this by simply 
  ignoring the file attributes.

*/


#ifndef WIN32
proc COMPILE_ERROR()
CHGNOTIF_needs_TSE_2_6_or_higher()
end
#endif



#ifdef EDITOR_VERSION

#if EDITOR_VERSION >= 0x3000
#endif

#else // !EDITOR_VERSION

#define EDITOR_VERSION 0x2800

proc UpdateBufferDaTmAttr()
end

#endif


// FULL_SCREEN_MODE - when defined, TSE-style message boxes are used; when not
// defined, Windows-style message boxes are used.
#define FULL_SCREEN_MODE 1



///////////////////////////////////////////////////////////////////////////
// DLLs

dll "chgnotif.dll"
	// initialization/deinitialization
	integer proc Init(integer hwnd)
	proc Goodbye()

	// sync DLL with files in the ring
	proc BeginSync()
	proc EndSync()

	// for tracking change notifications
	integer proc WatchFilename(string stPath:cstrval,
							   string stName:cstrval,
							   integer fWatch)
	proc ChangeExpected(string stFilename:cstrval,
						integer cExpected)

	// for forcing change notifications
	proc ForceChanged(string stFilename:cstrval,
					  integer fChanged,
					  integer fGone)

	// for retrieving change notifications
	integer proc FChanges()
	integer proc GetNextChange(var string stFilename)
end


dll "<user32.dll>"
	proc MessageBeep(integer beep)
	integer proc MessageBox(integer hwndOwner,			// handle of owner window
							string lpszText : cstrval,	// address of text in message box
							string lpszTitle: cstrval,	// address of title of message box
							integer fuStyle				// style of message box
							) : "MessageBoxA"
end



///////////////////////////////////////////////////////////////////////////
// Constants

#define cfNONE		0x0000
#define cfGONE		0x0001
#define cfCHANGED	0x0002

#define MB_OK						0x00000000
#define MB_OKCANCEL					0x00000001
#define MB_ABORTRETRYIGNORE			0x00000002
#define MB_YESNOCANCEL				0x00000003
#define MB_YESNO					0x00000004
#define MB_RETRYCANCEL				0x00000005

#define MB_ICONHAND					0x00000010
#define MB_ICONQUESTION				0x00000020
#define MB_ICONEXCLAMATION			0x00000030
#define MB_ICONASTERISK				0x00000040

#define MB_ICONWARNING				MB_ICONEXCLAMATION
#define MB_ICONERROR				MB_ICONHAND

#define MB_ICONINFORMATION			MB_ICONASTERISK
#define MB_ICONSTOP					MB_ICONHAND

#define IDOK						1
#define IDCANCEL					2
#define IDABORT						3
#define IDRETRY						4
#define IDIGNORE					5
#define IDYES						6
#define IDNO						7

string c_stIniSection[] = "ChgNotif"
string c_stIniVersion[] = "Version"
string c_stAutoReload[] = "AutoReload"

constant c_nVer = 0x0160



///////////////////////////////////////////////////////////////////////////
// Globals

//integer g_fFirstRun = FALSE

integer g_cReloading = 0
integer g_idChanges = 0

integer g_fAutoReload



///////////////////////////////////////////////////////////////////////////
// Help

helpdef WelcomeMessage
title = "Welcome to CHGNOTIF!"
x = 4
y = 4
"®B¯Description:®/B¯"
""
"If you ever use two editors (even two copies of TSE) to edit the same"
"file, this macro is for you."
""
"This macro will notify you if a file in TSE has been changed by some"
"other application.  If TSE is not active when the file is changed, it"
"will wait to notify you until TSE becomes active."
""
"If the file has been modified by both TSE and another application, this"
"macro will also give you the option to interactively merge the two sets"
"of changes."
""
""
"®B¯For example:®/B¯"
""
'Say you have "MyFile.Txt" open in TSE.  For one reason or another, you'
"use NotePad to edit the same file, make some changes, and save the file."
"If you forget to reload MyFile.Txt, when you go back to TSE you're going"
"to lose the changes you just made with NotePad.  However, if you have"
"CHGNOTIF loaded, then as soon as you go back to TSE, it will notify you"
"that MyFile.Txt was changed and ask you if you'd like to reload it."
""
""
"®B¯Options:®/B¯"
""
'To change the settings of CHGNOTIF, execute the macro as "CHGNOTIF -o".'
end


proc HelpHook()
	UnHook(HelpHook)
	DisplayMode(_DISPLAY_HELP_)
end


proc DoHelp(/*helpdef helptext {this would require compiling with the -i flag}*/)
	Hook(_LIST_STARTUP_, HelpHook)
	//QuickHelp(helptext)
	QuickHelp(WelcomeMessage)
	UnHook(HelpHook)
end



///////////////////////////////////////////////////////////////////////////
// Functions

integer proc PopUp(string title, string text, integer flags)
	#ifdef FULL_SCREEN_MODE

		#if EDITOR_VERSION >= 0x3000

		integer fYesNo = TRUE
		string buttons[48] = "[  &OK  ]"

		if flags & MB_YESNO
			buttons = "[  &Yes  ];[  &No  ]"
		elseif flags & MB_YESNOCANCEL
			buttons = "[  &Yes  ];[  &No  ];[ &Cancel ]"
		else
			fYesNo = FALSE
			if flags & MB_OKCANCEL
				buttons = "[  &OK  ];[ &Cancel ]"
			endif
		endif

		case MsgBoxEx(title, text, buttons)
			when 1
				return(iif(fYesNo, IDYES, IDOK))
			when 2
				return(iif(fYesNo, IDNO, IDCANCEL))
		endcase

		return(IDCANCEL)

		#else

		integer fYesNo = TRUE

		if flags & MB_YESNO
			flags = _YES_NO_
		elseif flags & MB_YESNOCANCEL
			flags = _YES_NO_CANCEL_
		else
			fYesNo = FALSE
			if flags & MB_OKCANCEL
				flags = _YES_NO_
			else
				flags = _OK_
			endif
		endif

		case MsgBox(title, text, flags)
			when 1
				return(iif(fYesNo, IDYES, IDOK))
			when 2
				return(iif(fYesNo, IDNO, IDCANCEL))
		endcase

		return(IDCANCEL)

		#endif

	#else

	return (MessageBox(GetWinHandle(), text, "The SemWare Editor Pro", flags))

	#endif
end


string proc OnOffStr(integer f)
	return (iif(f, "On", "Off"))
end


string proc Path(string fn)
	string path[_MAXPATH_] = RemoveTrailingSlash(SplitPath(fn, _DRIVE_|_PATH_))

	if Length(path) == 2 and path[2] == ":"
		path = AddTrailingSlash(path)
	endif
	return(path)
end


string proc Name(string fn)
	return (SplitPath(fn, _NAME_|_EXT_))
end


proc Sync()
	PushPosition()

	// sync DLL with currently loaded files
	BeginSync()
	do NumFiles() times
		NextFile(_DONT_LOAD_)
		if Query(BufferFlags) & _LOADED_
			WatchFilename(Path(CurrFilename()), Name(CurrFilename()), TRUE)
		endif
	enddo
	EndSync()

	PopPosition()
end


proc ResetOnIdle(string fn)
	integer cid

	// remember the filename and notify the DLL that the filename is finished
	// being saved, when the editor goes into an idle loop.  cleans up after
	// people who forget to balance calls to CHGNOTIF_ChangeExpectedYes and
	// CHGNOTIF_ChangeExpectedNo.  but more importantly, allows multiple
	// macros to hook _ON_FILE_SAVE_/_AFTER_FILE_SAVE_ and coexist because
	// they are no longer required to call CHGNOTIF_ChangeExpectedNo.
	cid = GotoBufferId(g_idChanges)
	if cid
		BegFile()
		InsertLine(fn)
		GotoBufferId(cid)
	endif
end


integer proc Merge()
	string stFn[_MAXPATH_] = CurrFilename()
	integer fOk
	integer cid
	integer id = 0

	if FileExists(SplitPath(stFn, _DRIVE_|_NAME_) + ".cbk")
		if Popup("Merge", "Overlay existing .CBK file?",
				 MB_OKCANCEL|MB_ICONQUESTION) <> IDOK
			return (FALSE)
		endif
	endif

	cid = GetBufferId()
	if CreateBuffer(SplitPath(stFn, _DRIVE_|_NAME_) + ".cbk", _NORMAL_)
		id = GetBufferId()
		PushBlock()
		fOk = InsertFile(stFn, _DONT_PROMPT_)
		FileChanged(FALSE)
		PopBlock()

		if fOk
			GotoBufferId(cid)
			if ExecMacro("cmpfiles")
				// don't abandon the CBK file, let CMPFILES handle that in
				// case user needs to momentarily quit CMPFILES and then wants
				// to reenter it again.
				return (TRUE)
			endif
		else
			GotoBufferId(cid)
			Warn("Error reading file"; stFn)
		endif
	else
		GotoBufferId(cid)
		Warn("Error creating merge buffer.")
	endif

	// no-op if id == 0
	AbandonFile(id)

	return (FALSE)
end



///////////////////////////////////////////////////////////////////////////
// TimeOutMessage

//integer g_fTimeoutHooked = FALSE
integer idle_timeout
constant ONE_SECOND = 18
constant DEF_TIMEOUT = 2
constant ERROR_TIMEOUT = 5

forward proc BeforeCommand_TimeOutMessage()


proc Idle_TimeOutMessage()
	if GetClockTicks() > idle_timeout
		BeforeCommand_TimeOutMessage()
		UpdateDisplay(_STATUSLINE_REFRESH_)
	endif
end


proc BeforeCommand_TimeOutMessage()
//	g_fTimeoutHooked = FALSE
	UnHook(BeforeCommand_TimeOutMessage)
	UnHook(Idle_TimeOutMessage)
end


proc TimeOutMessage(integer cSeconds, string msg)
	integer attr = Query(MsgAttr)

	BeforeCommand_TimeOutMessage()
//	g_fTimeoutHooked = TRUE
	idle_timeout = GetClockTicks() + cSeconds*ONE_SECOND
	if cSeconds == ERROR_TIMEOUT
		Set(MsgAttr, Color(bright white on red))
	endif
	Message(msg)
	Set(MsgAttr, attr)
	Hook(_AFTER_UPDATE_STATUSLINE_, BeforeCommand_TimeOutMessage)
	Hook(_BEFORE_COMMAND_, BeforeCommand_TimeOutMessage)
	Hook(_IDLE_, Idle_TimeOutMessage)
end



///////////////////////////////////////////////////////////////////////////
// Version

string proc StVersion(integer n)
	return (Format(n/0x0100, ".", (n mod 0x100):2:"0":16))
end


proc ShowVersion(integer fTimeout)
	integer attr
	integer y
	integer i, j, k, l

	y = Query(StatusLineRow)

	i = Query(PopWinX1)
	j = Query(PopWinY1)
	k = Query(PopWinCols)
	l = Query(PopWinRows)
	Window(1, y, Query(ScreenCols), y)

	attr = Set(MsgAttr, Color(bright white on black))
	if fTimeout
		TimeOutMessage(3, "")
	else
		Message("")
	endif
	Set(MsgAttr, attr)

	VGotoXY(1, 1)
	PutStr("== ", Color(bright red on black))
	PutStr("CHGNOTIF", Color(bright yellow on black))
	PutStr("/", Color(bright white on black))
	PutStr(StVersion(c_nVer), Color(bright green on black))
	PutStr(" ==", Color(blue on black))

	//VGotoXY(24, 1)
	//PutStr("Other text here.", Color(bright white on black))

	PutStrXY(Query(ScreenCols)-14+1, 1, "by Chris Antos", Color(bright white on black))

	Window(i, j, i+k-1, j+l-1)
end


integer proc GetIniVersion()
	return(Val(GetProfileStr(c_stIniSection, c_stIniVersion, "0"), 16))
end


// HandleFirstRun()
// check for first run scenario and do setup
integer proc HandleFirstRun()
	integer cVer
	string st[_MAXPATH_]
	integer fAutoLoad
	integer cid, idTmp
	integer fWasFirstRun = FALSE

	// check for first run scenario
	cVer = GetIniVersion()
	if cVer < c_nVer
		#ifdef DEBUG
		if cVer
			MsgBox("", Format("CHGNOTIF v", cVer:4:"0":16;
					"is currently installed.  ",
					"Upgrading to v", c_nVer:4:"0":16, "."))
		else
			MsgBox("", Format("CHGNOTIF is not installed.  ",
					"Installing v", c_nVer:4:"0":16, "."))
		endif
		#endif

		#ifdef SETUP_NoSetupInPrompt
		if Length(Query(PromptString))
			#ifdef DEBUG
			Warn("Cannot do first run setup from a prompt!")
			#endif
			goto Error
		endif
		#endif

		//$ todo: check if we're just upgrading?

		// first run, do automatic setup
//		g_fFirstRun = TRUE
		fWasFirstRun = TRUE

		// welcome message
		DoHelp()

		// check if in autoload list
		fAutoLoad = FALSE
		cid = GetBufferId()
		idTmp = CreateTempBuffer()
		if idTmp
			PushBlock()
			BinaryMode(-1)
			InsertFile(LoadDir()+"tseload.dat", _DONT_PROMPT_)
			fAutoLoad = lFind(SplitPath(CurrMacroFilename(), _NAME_), "^$gi")
			GotoBufferId(cid)
			AbandonFile(idTmp)
		endif
		if not fAutoLoad
			// if not in autoload list, prompt to add it
			if MsgBox("",
					"Would you like to add CHGNOTIF to your AutoLoad macro " +
					"list?  (The recommended choice is Yes)",
					_YES_NO_) == 1
				st = SearchPath(SplitPath(CurrMacroFilename(), _NAME_|_EXT_),
						Query(TSEPath), "mac")
				if Lower(st) == Lower(CurrMacroFilename())
					// the proj macro was found in the mac\ directory, so just
					// add the name without the path.
					AddAutoLoadMacro(SplitPath(st, _NAME_))
				else
					// the proj macro is not in the mac\ directory, so add the
					// full pathname of the proj macro.
					AddAutoLoadMacro(CurrMacroFilename())
				endif
			endif
		endif

		WriteProfileStr(c_stIniSection, c_stIniVersion, Format(c_nVer:4:"0":16))
		FlushProfile()

		MsgBox("", "CHGNOTIF "+StVersion(c_nVer)+" is now installed.")
		ShowVersion(TRUE)
//		UpdateDisplay()

//		g_fFirstRun = FALSE
	endif

//Error:
	Set(Key, -1)
	return(fWasFirstRun)
end



///////////////////////////////////////////////////////////////////////////
// Public

public proc CHGNOTIF_GetVersion()
	Set(MacroCmdLine, Str(c_nVer, 16))
end


public proc CHGNOTIF_DontWatch()
	WatchFilename(Path(CurrFilename()), Name(CurrFilename()), FALSE)
end


public proc CHGNOTIF_ForceChanged()
	ForceChanged(CurrFilename(), TRUE, FALSE)
end


public proc CHGNOTIF_ForceGone()
	ForceChanged(CurrFilename(), FALSE, TRUE)
end


public proc CHGNOTIF_ForceNotChanged()
	ForceChanged(CurrFilename(), FALSE, FALSE)
end


public proc CHGNOTIF_ChangeExpectedYes()
	ChangeExpected(CurrFilename(), 1)
	ResetOnIdle(CurrFilename())
end


public proc CHGNOTIF_ChangeExpectedNo()
	ChangeExpected(CurrFilename(), -1)
end


public proc CHGNOTIF_ChangeExpectedReset()
	ChangeExpected(CurrFilename(), 0)
end



///////////////////////////////////////////////////////////////////////////
// Menus

proc ToggleIni(var integer f, string stIni)
	f = not f
	WriteProfileInt(c_stIniSection, stIni, f)
end


menu OptionsMenu()
history
"&Automatically reload files that have not been changed in TSE"
		[OnOffStr(g_fAutoReload):3], ToggleIni(g_fAutoReload, c_stAutoReload), DontClose
end


proc Options()
	OptionsMenu()
	FlushProfile()
end


menu ChangedMRC()
"&Merge changes"
"&Reload file (lose changes made in editor)"
"&Cancel"
end



///////////////////////////////////////////////////////////////////////////
// Hooks

proc OnFileLoad()
	if not g_cReloading
		WatchFilename(Path(CurrFilename()), Name(CurrFilename()), TRUE)
	endif
end


proc OnFileSave()
	//integer cid
	//string fn[_MAXPATH_] = CurrFilename()

	// make sure DLL knows about the file
	OnFileLoad()

	// notify DLL that file is expected to change
	//ChangeExpected(fn, TRUE)
	CHGNOTIF_ChangeExpectedYes()
end


proc OnFileQuit()
	if not g_cReloading
		WatchFilename(Path(CurrFilename()), Name(CurrFilename()), FALSE)
	endif
end


proc NonEditIdle()
	integer cid

	// notify the DLL that files are done being saved
	cid = GotoBufferId(g_idChanges)
	if cid
		while NumLines()
			BegFile()
			ChangeExpected(GetText(1, _MAXPATH_), 0)
			KillLine()
		endwhile
		GotoBufferId(cid)
	endif
end


proc Idle()
	integer nType
	string stFilename[_MAXPATH_] = ""
	integer cid
	integer n
	integer fReload = FALSE
	integer fChanged = FALSE
	integer fBrowseMode
	integer x, y

	x = WhereXAbs()/2 + 1
	y = WhereYAbs() + 1
	if y+6 >= Query(ScreenRows)
		y = WhereYAbs() - 6
	endif

	//$ review: do this before or after checking for filechange notifications?
	NonEditIdle()

	// have any files changed?
	if FChanges()
		// prompt user for each file
		nType = GetNextChange(stFilename)
		case nType
			when cfCHANGED
				cid = GotoBufferId(GetBufferId(stFilename))
				if cid
					fChanged = FileChanged()
					if not fChanged and g_fAutoReload
						// if autoreload is on and the file is not dirty, set
						// the flag to reload it w/o prompting.
						fReload = TRUE
					endif
				endif

				if not fReload
					if fChanged
repeat_merge:
						repeat
							Set(X1, x)
							Set(Y1, y)
							n = ChangedMRC(SqueezePath(stFilename, Query(ScreenCols)-13-6)+" has changed:")
						until n or Query(Key) == <Escape>
						case n
							when 1
								if not Merge()
									goto repeat_merge
								endif
							when 2
								fReload = TRUE
						endcase
					else
						repeat
							Set(X1, x)
							Set(Y1, y)
							n = PopUp("File Changed", SqueezePath(stFilename, Query(ScreenCols)-25-6)+" has changed."+Chr(13)+Chr(13)+"Reload it?",
									  MB_YESNO|MB_ICONEXCLAMATION)
						until n in IDYES, IDNO
						fReload = (n == IDYES)

						/*
						fReload = (PopUp(stFilename + Chr(10) + Chr(10) +
								"This file has been changed outside the editor.  Do you want to reload it?",
								MB_YESNO|MB_ICONQUESTION) == IDYES)
						*/
					endif
				endif

				if fReload
					GotoBufferId(GetBufferId(stFilename))
					g_cReloading = g_cReloading + 1
					fBrowseMode = BrowseMode()
					ReplaceFile(stFilename, _OVERWRITE_)
					UpdateBufferDaTmAttr()
					BrowseMode(fBrowseMode)
					g_cReloading = g_cReloading - 1
				endif
				GotoBufferId(cid)
				UpdateDisplay()

			when cfGONE
				//$ todo: what to do in this case??
				PopUp("", "File "+Upper(stFilename)+" not found.",
					  MB_OK|MB_ICONEXCLAMATION)
				WatchFilename(Path(stFilename), Name(stFilename), FALSE)
		endcase
	endif
end



///////////////////////////////////////////////////////////////////////////
// Auto Procs

proc WhenPurged()
	Goodbye()

	if g_idChanges
		AbandonFile(g_idChanges)
	endif
end


proc WhenLoaded()
	integer cid = GetBufferId()
	integer fHooked = TRUE

	HandleFirstRun()

	g_idChanges = CreateTempBuffer()
	GotoBufferId(cid)

	g_fAutoReload = GetProfileInt(c_stIniSection, c_stAutoReload, FALSE)

	// hooks
	fHooked = g_idChanges and
			  Init(GetWinHandle()) and
			  Hook(_ON_FIRST_EDIT_, OnFileLoad) and
			  Hook(_ON_FILE_LOAD_, OnFileLoad) and
			  Hook(_ON_FILE_SAVE_, OnFileSave) and
			  Hook(_ON_FILE_QUIT_, OnFileQuit) and
			  Hook(_ON_ABANDON_EDITOR_, WhenPurged) and
			  //Hook(_BEFORE_COMMAND_, NonEditIdle) and
			  //Hook(_BEFORE_NONEDIT_COMMAND_, NonEditIdle) and
			  Hook(_AFTER_COMMAND_, NonEditIdle) and
			  Hook(_AFTER_NONEDIT_COMMAND_, NonEditIdle) and
			  Hook(_IDLE_, Idle)

	if fHooked
		// sync the DLL with the currently loaded files
		Sync()
	else
		// error initializing, purge the macro
		Warn("Unable to initialize";
				Upper(SplitPath(CurrMacroFilename(), _NAME_|_EXT_)))
		PurgeMacro(CurrMacroFilename())
	endif
end



///////////////////////////////////////////////////////////////////////////
// Main

proc Main()
	ShowVersion(FALSE)
	case Query(MacroCmdLine)
		when "-o"
			Options()
		when "-?"
			DoHelp()
	endcase
	ShowVersion(TRUE)
end
