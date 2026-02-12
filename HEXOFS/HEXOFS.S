// HEXOFS ù Displays hex offset on statusline when editting in hex mode.

integer nBase = 10

proc mToggleBase()
	nBase = iif(nBase == 10, 16, 10)
	UpdateDisplay(_STATUSLINE_REFRESH_|_REFRESH_THIS_ONLY_)
end

proc mGotoOfs()
	string s[20] = ""
	integer n

	if Ask("Goto offset: "+iif(nBase == 10, "(dec)", "(hex)"), s) and
			Length(s)
		Message("Working...")
		n = Val(s, nBase)
		GotoLine((n/BinaryMode()) + 1)
		GotoColumn((n mod BinaryMode()) + 1)
		UpdateDisplay(_STATUSLINE_REFRESH_)
	endif
end

proc StatLine()
	integer r = BinaryMode()
	string s[20]

	// show offset on statusline if in binary mode
	if r
		s = "³Ofs:" + iif(nBase == 10, "", "0x") +
				Format(((CurrLine()-1) * r + CurrCol()-1):10:"0":nBase)
		VGotoXYAbs(Query(ScreenCols)-Length(s)+1, Query(StatusLineRow))
		Set(Attr, Query(StatusLineAttr))
		PutStr(s)
	endif
end

proc WhenLoaded()
	Hook(_AFTER_UPDATE_STATUSLINE_, StatLine)
end

proc WhenPurged()
	UnHook(StatLine)
end

<Ctrl Enter>		if BinaryMode() > 0 mGotoOfs() else ChainCmd() endif
<CtrlShift Enter>	if BinaryMode() > 0 mToggleBase() else ChainCmd() endif
