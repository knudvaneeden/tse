// PICKLITE.S -------------------------------------------------------------
// Christopher Antos
//
//
// This macro is an example to demonstrate the use of PICKLITE.BIN.
// Once you understand how this macro works, you can use a similar approach
// to use the ColorPicklist function to hilight just about whatever kind of
// TSE window you want.  (Personally, I wrote PickLite.Bin so my GREP macro
// could hilight certain lines when it displayed its list of matches.)
//
// This macro colors directories in a picklist.
//
// **NOTE:  Only works if PickFileFlags has _ADD_SLASH_ set.


// include the binary
binary ['picklite.bin']
	proc ColorPicklist(integer X:word, integer Y:word,
			integer Cols:word, integer Rows:word,
			string TagStr, integer HiAttr:word) : 0
end


// ColorPicklist(X, Y, Cols, Rows, TagStr, HiAttr)
// this binary function works by looking at the window whose upper left-hand
// corner is at X, Y (1..ScreenCols, 1..ScreenRows) and whose width is
// Cols columns wide and Rows rows high.  it checks the beginning of each
// line in the window for TagStr, and if it matches, then the entire line's
// foreground color is set to HiAttr.  it's a simple function and doesn't
// have a lot of fancy features, b/c it's intended to do a very simple job.


// HilightList
// hilights the current picklist
proc HilightList()
	ColorPicklist(Query(PopWinX1), Query(PopWinY1),
			Query(PopWinCols), Query(PopWinRows),
			" \", Color(bright yellow))
end


// ListCleanup
// unhooks stuff
proc ListCleanup()
	UnHook(ListCleanup)
	UnHook(HilightList)
end


// ListStartup
// hooks things up
proc ListStartup()
	// NOTE:  If you wanted to only hilight the picklist THIS TIME, then
	// uncomment the "UnHook..." line below.  For instance, I wrote a GREP
	// utility that only wants to hilight the grep list that it displays.
	// To accomplish that, you simply need to call UnHook(ListStartup) in
	// here, and remember to call Hook(_LIST_STARTUP_, ListStartup).
	// Yes, observant viewers will notice that the ColorPicklist function
	// can be used for both pickfile lists and also plain old list windows
	// (ie, lList() and List()).

	//Unhook(ListStartup)
	Hook(_PICKFILE_CLEANUP_, ListCleanup)
	Hook(_NONEDIT_IDLE_, HilightList)
end


// WhenLoaded
// hook it up
proc WhenLoaded()
	Hook(_PICKFILE_STARTUP_, ListStartup)
end


// Caveats
// help on PickLite.Mac and caveats to using it.
helpdef Caveats
title = "Introduction to PICKLITE.MAC"
x = 5
y = 5
""
" ù PickList.Mac is an example macro to demonstrate the use  "
"   of the PickLite.Bin binary I wrote.  See PickLite.S for"
"   comments and to see how to use PickLite.Bin yourself."
""
" ù PickLite.Bin is provided as-is.  I hope you find it"
"   useful.  It's free -- feel free to use it, modify it,"
"   etc.  Just don't charge people for it."
""
" ù Load PickLite.Mac to make your file picklists hilight"
"   subdirectories.  Note, this will only work if you have"
"   the 'Precede Directory Entries with Slash' option on."
"   (See Options->Full Configuration->System/File Options->"
"   File PickList Settings)."
""
end


// Main
proc Main()
	QuickHelp(Caveats)
end
