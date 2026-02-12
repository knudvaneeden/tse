/*******************************************************************************
				CRAZY JACK'S TABOLATOR

Copyright 1993 by Jack Hazlehurst, All Rights Reserved
07/01/93 - First version

    These  macros, along with the binary "tabolate.bin", are used to replace
    spaces with tabs and/or tabs with spaces in a  file	 or  block.   Column
    blocks  are	 NOT  supported,  and all lines within a marked block of any
    other kind are converted in their entirety, even if the entire  line  is
    not	 within	 the  block.  If no block is marked in the current file, the
    entire file is processed.

    Conversion	is  controlled	by  parameter strings used to initialize the
    scanner.  A	 sampling  of  these  is  provided,  including	strings	 for
    converting	spaces	to tabs for C, SAL, Pascal and Assembler.	 In these,
    provision is made to convert any tabs within quoted strings	 to  spaces,
    even  while	 elsewhere spaces are converted to tabs.  To include tabs in
    quoted strings, use those languages' other facilities to indicate  their
    presence.


    "Tabolate1Line()" is an inner macro called by  "Tabolate()"	 to  process
    each line.

    See "tabolate.doc" for more details.
*******************************************************************************/

//
// Include the binary code:
//
binary ["tabolate.bin"]
    integer proc StartTabs( string SetupPoop, integer TabSize )	   : 0
    integer proc EndALine( var string LineOut )			   : 3
    integer proc TabALine( var string LineIn, var string LineOut,
							integer StartState )	: 6
end
//
// Sample initialization strings
//
string
    CTabsOut[] = "CA'D" + '.A"G.A/I' + "FD'A.D\FMF  "
						+ 'FG"A.G\FMI A.I/L.I*MGl ACM*NMN M.N/A',

    AsmTabsOut[] = 'CA;F.A"G' + ".A'H.A<I.A!JGF A" + 'FG"A' + "FI>AMJ  ",

    PscTabsOut[] = "CA{D.A(E.A'JCD}AME A.E*GCG*HMH G.H)AFJ'A",

    SALTabsOut[] = 'CA/D.A"K' + ".A'LMD A.D/G.D*HGG ACH*IMI H.I/A"
								     + 'FK"A' + "FL'A",

    AllTabsOut[] = "CA A",		// Convert all spaces to tabs.

    AllTabsIn[] = "BA A"		// Convert all tabs to spaces.

//
// Tabolate one line
//

integer proc Tabolate1Line( integer State1 )
    string InStr[128], OutStr[254] = "" // Working strings.
    integer State = State1,		// Current state of TabALine.
	    tns				// Tentative next state.

    BegLine()				// Always process entire line.

    while CurrPos() <= CurrLineLen()		// Process entire line.
	InStr = GetText( CurrPos(), 128 )	// Get next piece of line.
	repeat					// Try to process the piece of
	    tns = TabALine( InStr, OutStr, State ) //line.
	    if tns < 0				// If processing failed, we must
		if Length(InStr) < 2		// try a smaller piece.
		    Warn( "Line ",CurrLine()," can't be processed." )
		    return( -1 )		// Oops -- nothing left.
		endif
	    InStr = GetText( CurrPos(), Length(InStr) / 2 )
	    endif
	until tns >= 0				// When processing succeeds, we
	State = tns				// have a new state.  Insert
	MarkChar()				// Remove piece just extracted
	GotoPos( CurrPos() + Length( InStr ) )	// from the line.
	MarkChar()
	DelBlock()
	if  (Length(OutStr) > 0)		// converted piece back into
	and NOT InsertText( OutStr, _INSERT_ )	// line if we can.
		goto Line2Long
	endif
    endwhile

    State = EndALine( OutStr )		// Get end-of-line state and possible
    if	(Length(OutStr) > 0)		// trailing blanks.
    and NOT InsertText( OutStr, _INSERT_ )
Line2Long:
	Warn( "Line ",CurrLine()," has grown too long!" )
	return( -1 )
    endif
    return( State )			// Return end-of-line state to caller.
end Tabolate1Line

//
// Tabolate a block or file
//

integer proc Tabolate( var string SetupString, integer TabSize )
    string  What[6]
    integer State = 0,
	    cc, xt,			// For restoring cursor position.
	    ll,				// Last line to process.
	    kmx = Set(KillMax, 0),
	    bt = isCursorInBlock()

    xt = Set( ExpandTabs, ON )		// To help restore cursor
    cc = CurrCol()			// position later on.
    PushPosition()			// Save where we are.
    if bt				// Cursor in a block?
	if bt == _COLUMN_		// If yes, make sure it's not a
	    Warn( "The Machine refuses to Tabolate column blocks." )
	    goto OutaHere		// column block.
	endif
	GotoBlockEnd()			// Get # line of block end.
	if bt == _NONINCLUSIVE_		// For non-inclusive block we back
	    PrevChar()			// up one character.
	endif
	ll = CurrLine()			// Save the line number for loop.
	What = "block"			// Set for message.
	GotoBlockBegin()		// To starting point.
    else				// Process whole file:
	BegFile()			// To starting point.
	What = "file"			// For message.
	ll = NumLines()			// Get number of last line.
    endif

    PushBlock()				// We need to mark and delete blocks.
    UnMarkBlock()
    Message( "Tabolating ",What," -- please wait --" )
    State = StartTabs( SetupString, TabSize )	 // Initialize the Tabolator.

    if	(State == 0)			// Process all indicated lines.
    and (ll > 0)
	repeat
	    State = Tabolate1Line( State )
	until (State < 0)
	   or NOT Down()
	   or (CurrLine() > ll)
    endif

    PopBlock()				// Restore caller.
OutaHere:
    Set(KillMax, kmx)
    if State < 0
	Message( "The Tabolator could not finish this ",What,"." )
	Set( ExpandTabs, xt )
	KillPosition()			// If we have an error,
	return( FALSE )			// leave cursor on error,
    endif
    Message( "The Tabolator is finished with this ",What,"." )
    PopPosition()			// else return to original
    BegLine()				// cursor position.
    GotoColumn( cc )
    Set( ExpandTabs, xt )
    return( TRUE )
end Tabolate

/******************************************************************************/

proc main()
    Tabolate( CTabsOut, 8 )
end
