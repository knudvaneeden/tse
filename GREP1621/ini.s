// INI.S ù IniFile macro
// Chris Antos ù chrisant@microsoft.com


/*

INI 1.10 ------------------------------------------------------------------
ù Fixed bug where settings might not get saved when exiting the editor.

INI 1.20 ------------------------------------------------------------------
ù Fixed bug where INI file could get corrupted.
ù Fixed bug where INI could hang TSE on exit.
ù Optimization: INI file only gets marked as changed when a value actually
  changes (it used to get marked as changed whenever a value was written,
  even if the value didn't actually change). This prevents INI from saving
  unless actually necessary (a great optimization for floppy drives or slow
  hard drives).

INI 1.30 ------------------------------------------------------------------
ù Changed commands from ..Ini.. to ..Profile.. for increased compatibility
  with the new TSE32.  Also, Set.. became Write.. for the same reason.
ù SaveIniSettings() was changed to FlushProfile().

*/


#ifdef WIN32
// TSE32 natively supports all functions that INI provides, so we
// intentionally don't allow INI to compile for TSE32 since that could cause
// problems.
"DO NOT COMPILE INI FOR WIN32!!"
#endif


//#define DEBUG 1
//#define DEBUG_WARN_ON_FORCESAVE 1
#define DEBUG_WARN_IF_CORRUPT 1


// Variables --------------------------------------------------------------

string ini_file[128] = "tsepro.ini"
string ini_buf_name[] = "+++tsepro.ini+++"
string stTagLine[] = "; TSE Pro macro settings file"
string stUnexpected[] = "Unexpected error: INI buffer exists, but cannot switch to it."
integer id_ini = 0


// Functions --------------------------------------------------------------

proc GotoLastNonBlank()
	while not PosFirstNonWhite()
		Up()
	endwhile
end


integer proc FindValue(string section, string keynm, integer fRequired)
	// look for value (cursor is at start of value)
	if lFind("["+section+"]", "^gi") and
			lFind("[\t ]*"+keynm+"=\c", "^ix")
		return(TRUE)
	endif

	// if not found, but required, create keyname (and section if necessary)
	if fRequired
		if lFind("["+section+"]", "^gi")
			Down()
		else
			EndFile()
			GotoLastNonBlank()
			AddLine()
			AddLine("["+section+"]")
			EndLine()	// so the lFind below doesn't match
		endif
		if lFind("\[[A-Za-z0-9_]+\]", "^x")
			Up()
		else
			EndFile()
		endif
		GotoLastNonBlank()
		AddLine(keynm+"=")
		EndLine()
		return(TRUE)
	endif

	return(FALSE)
end


string proc GetValue(string section, string keynm, string default)
	if FindValue(section, keynm, FALSE)
		return(GetText(CurrPos(), 255))
	endif
	return(default)
end


proc SetValue(string section, string keynm, string value)
	FindValue(section, keynm, TRUE)
	// if value has not changed, prevent file from being marked as changed.
	if value <> GetText(CurrPos(), 255)
		KillToEol()
		InsertText(value)
	endif
end


#ifdef DEBUG_WARN_IF_CORRUPT
proc CheckINI()
	PushPosition()
	BegFile()
	if GetText(1, 255) <> stTagLine
		PopPosition()
		Warn("Corrupted INI file!")
		List("CORRUPTED TSEPRO.INI", Query(ScreenCols))
		PushPosition()
		if YesNo("Don't complain until it gets corrupted again?") == 1
			BegFile()
			InsertLine(stTagLine)
		endif
	endif
	PopPosition()
end
#endif


proc Save()
	integer cid

	if id_ini
		#ifdef DEBUG
		if BufferType() <> _NORMAL_
			Warn("INI: Buffer is ", iif(BufferType() == _SYSTEM_, "_SYSTEM_", "_HIDDEN_"))
		endif
		#endif

		cid = GotoBufferId(id_ini)
		if cid
			if FileChanged()
				#ifdef DEBUG_WARN_IF_CORRUPT
				CheckINI()
				#endif

				#ifdef DEBUG
				Warn("INI: Saving"; ini_file)
				#endif

				SaveAs(ini_file, _OVERWRITE_|_DONT_PROMPT_)
			endif

			#ifdef DEBUG
			Warn("INI: BufferId =="; cid)
			#endif

			GotoBufferId(cid)
		else
			Warn(stUnexpected)
		endif
	endif
end


// Auto Functions ---------------------------------------------------------

proc WhenLoaded()
	integer cid = GetBufferId()

	id_ini = GetBufferId(ini_buf_name)
	if not id_ini
		id_ini = CreateBuffer(ini_buf_name, _SYSTEM_)
		if not id_ini
			Warn("Error creating buffer "+ini_buf_name)
			return()
		endif
	endif
	ini_file = LoadDir()+ini_file
	if FileExists(ini_file)
		PushBlock()
		#ifdef DEBUG
		Message("INI: Loading"; ini_file)
		#endif
		InsertFile(ini_file, _DONT_PROMPT_)
		UnMarkBlock()
		PopBlock()
		BegFile()
		#ifdef DEBUG_WARN_IF_CORRUPT
		CheckINI()
		#endif
	else
		InsertLine(stTagLine)
	endif
	BegFile()
	FileChanged(FALSE)
	GotoBufferId(cid)

	Hook(_ON_ABANDON_EDITOR_, Save)
end


proc WhenPurged()
	Save()
	AbandonFile(id_ini)
	id_ini = 0
end


// Main -------------------------------------------------------------------

proc Main()
	integer cid
	string section[80]
	string keynm[80]
	string value[80]
	string s[255] = Query(MacroCmdLine)

	if id_ini
		cid = GotoBufferId(id_ini)
		if cid
			section = GetToken(s, Chr(10), 2)
			keynm = GetToken(s, Chr(10), 3)
			value = GetToken(s, Chr(10), 4)
			case GetToken(s, Chr(10), 1)
				when "-x"
					#ifdef DEBUG_WARN_ON_FORCESAVE
					Warn("INI: FORCE SAVE!")
					#endif
					Save()
				when "-g"
					Set(MacroCmdLine, GetValue(section, keynm, value))
				when "-s"
					SetValue(section, keynm, value)
				otherwise
					Warn("INI.MAC should only be called by the functions in INI.SI")
			endcase
			GotoBufferId(cid)
		else
			Warn(stUnexpected)
		endif
	endif
end
