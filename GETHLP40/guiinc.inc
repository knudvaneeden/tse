// GUIINC.SI - Compatibility layer for E/E32/G32


#ifdef WIN32
#if EDITOR_VERSION > 0x3000
#define GUI_AWARE_COMPILER 1
#endif
#endif // WIN32


#ifdef GUI_AWARE_COMPILER

constant USE_3D_CHARS = 0x0002	// _USE_3D_CHARS_ from TSE 4.00

integer proc IsGuiWindow()
	return(isGUI())
end

proc mPutOemChrXY(integer x, integer y, integer ch, integer attr, integer f3D)
	PutOemStrXY(x, y, Chr(ch), attr, iif(f3D, 1, 0))
end

proc mPutOemStrXY(integer x, integer y, string st, integer attr, integer f3D)
	PutOemStrXY(x, y, st, attr, iif(f3D, 1, 0))
end

integer proc FUse3D()
	return(Query(SpecialEffects) & USE_3D_CHARS)
end

#else // !GUI_AWARE_COMPILER

integer proc IsGuiWindow()
	return(FALSE)
end

proc mPutOemChrXY(integer x, integer y, integer ch, integer attr, integer f3D)
	PutStrXY(x, y, Chr(ch), attr)
end

proc mPutOemStrXY(integer x, integer y, string st, integer attr, integer f3D)
	PutStrXY(x, y, st, attr)
end

integer proc FUse3D()
	return(FALSE)
end

#endif // !GUI_AWARE_COMPILER


// make the compiler not complain
proc guiDummy()
	guiDummy()
	IsGuiWindow()
	FUse3D()
	mPutOemChrXY(0, 0, 0, 0, 0)
	mPutOemStrXY(0, 0, "", 0, 0)
end
