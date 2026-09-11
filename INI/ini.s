// INI.S ù IniFile macro
// Chris Antos ù chrisant@microsoft.com


// Variables --------------------------------------------------------------

string ini_file[128] = "tsepro.ini"
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
	KillToEol()
	InsertText(value)
end


proc Save()
	integer cid

	if id_ini
		cid = GotoBufferId(id_ini)
		if FileChanged()
			SaveAs(ini_file, _OVERWRITE_|_DONT_PROMPT_)
		endif
		GotoBufferId(cid)
	endif
end


// Hooks ------------------------------------------------------------------

proc CleanUp()
	Save()
	AbandonFile(id_ini)
end


// Auto Functions ---------------------------------------------------------

proc WhenLoaded()
	integer cid = GetBufferId()

	id_ini = CreateBuffer("+++tsepro.ini+++", _SYSTEM_)
	ini_file = LoadDir()+ini_file
	if FileExists(ini_file)
		PushBlock()
		InsertFile(ini_file, _DONT_PROMPT_)
		UnMarkBlock()
		PopBlock()
	else
		InsertLine("; TSE Pro macro settings file")
	endif
	BegFile()
	FileChanged(FALSE)
	GotoBufferId(cid)

	Hook(_ON_ABANDON_EDITOR_, CleanUp)
end


proc WhenPurged()
	CleanUp()
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
		section = GetToken(s, Chr(10), 2)
		keynm = GetToken(s, Chr(10), 3)
		value = GetToken(s, Chr(10), 4)
		case GetToken(s, Chr(10), 1)
			when "-x"
				Save()
			when "-g"
				Set(MacroCmdLine, GetValue(section, keynm, value))
			when "-s"
				SetValue(section, keynm, value)
			otherwise
				Warn("INI.MAC should only be called by the functions in INI.SI")
		endcase
		GotoBufferId(cid)
	endif
end
