// Copyright 1992-1993 SemWare Corporation.  All Rights Reserved Worldwide.
//
// 03-20-93: RB - Rewritten, commented, and tested.
// 06/28/93: JH - UnTab extracted and modified.
//
// Macro to convert Tabs to Spaces.  Will limit the conversion to a marked
// block if the cursor is in the block when invoked.
//
// ASSUMPTIONS: Only works on the current file/block.
//
//

/***********************************************************************
   This procedure does the converting from tabs to spaces.  It will
   limit the conversion to a marked block, if the cursor is within the
   block.

   The method used to remove the Tab characters is:

	Set the TabType to _SOFT_, Insert to TRUE,
	    and TabWidth to caller-supplied value.
	Save our position.
	Check to see if we are in a block; if so, restrict search to block.
	Search for the ASCII 9 tab character.  If found get into a
	    loop deleting the 'HARD' tab, and then TabRight() to
	    insert a 'SOFT' tab.
	Restore our position.
	Restore the TabType, TabWidth and Insert configuration variables.
***********************************************************************/

proc DeTab( integer TabSize )
    string  options[1] = ''
    integer found = 0,
	    tabtyp = Set(TabType, _SOFT_),
	    ins = Set(Insert, TRUE),
	    twdth = Set( TabWidth, TabSize ),
	    ic = isChanged(),
	    btype = isCursorInBlock()


    Message("Converting tabs to spaces -- please wait --")
    PushPosition()

    if btype
	GotoBlockBegin()
	if btype == _LINE_
	    BegLine()
	endif
	options = 'l'
    else
	BegFile()
    endif

    if lFind(Chr(9),options)
	repeat
	    DelChar()
	    found = found + 1
	    if NOT TabRight()
		Warn( "Line ",CurrLine()," has grown too long!" )
		KillPosition()
		goto OutAHere
	    endif
	    PrevChar()
	until not lRepeatFind()
    endif

    PopPosition()
    Message("DeTab done, ", found, " tabs replaced")
    ForceChanged( ic )
OutAHere:
    Set( TabWidth, twdth )
    Set(TabType, tabtyp)
    Set(Insert, ins)
end DeTab

/***********************************************************************/
proc main()
    DeTab( 8 )
end
