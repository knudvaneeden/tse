	%PAGESIZE 57, 132
	%TITLE	"Tab Conversion Support For Semware Editor Macros"
	%SUBTTL "Preliminaries"
	IDEAL
;******************************************************************************;
;									       ;
;			     CRAZY JACK'S TABOLATOR			       ;
;									       ;
; (c)Copyright 1993 by Jack Hazlehurst					       ;
; Author : Jack Hazlehurst						       ;
; Date	 : 07/01/93							       ;
;									       ;
; Use  the binary to your heart's content when you customize your copy of The  ;
; Semware Editor.  If you modify it (creating a	 derivative  work)  you	 MUST  ;
; retain the copyright notice, and add your own if you wish.  Just don't make  ;
; anyone pay any more for its use than I charge you (which is nothing).	       ;
;------------------------------------------------------------------------------;
; These	 routines support the conversion of tabs to spaces, and visa-versa, in ;
; text files.  The  conversion	proceeds  a  line  fragment  at	 a  time,  the ;
; individual  line  fragments being passed in from an SAL macro that reads the ;
; original data.  Before the first fragment is	processed,  an	initialization ;
; routine  must be called to provide the information necessary for controlling ;
; the operation, including key characters that change the processing, and  the ;
; size of the tabs.							       ;
;									       ;
; Use this declaration:							       ;
;   binary ["tabolate.bin"]						       ;
;	integer proc StartTabs( string SetupString, integer TabSize )  : 0     ;
;	integer proc EndALine( var string LineOut )		       : 3     ;
;	integer proc TabALine( var string LineIn, var string LineOut,	       ;
;						 integer StartState )  : 6     ;
;   end									       ;
;									       ;
; Borland's Turbo Assembler v 3.2 assembles this thing.			       ;
;									       ;
;******************************************************************************;

	SEGMENT _TEXT
	ASSUME	CS:_TEXT
	LOCALS
	%NEWPAGE
	%SUBTTL "State Table Entry Definition"
;...............................................................................
; The State Table determines what are key tokens and how they affect the
; expansion of tabs and the en-tabment of spaces.
;
	STRUC	CTLNTRY
CTLBTS	DB	0      ;Control bits (meaning if bit ON):
XPTBS	=	1		;Convert tabs to spaces.
SP2TBS	=	2		;Convert spaces to tabs.
EOLNDS	=	4		;This state ends at end of line.
END1	=	8		;This state ends after one character more.
; These next control bits never appear in the state table.  They are set,
; cleared and used internally by the routines:
CHK4BAK =	16		;Retest last char (after one-char state ends).
SP2TB	=	32		;Indicates spaces being converted to tabs.
NDTB	=	64		;Need 1-space tab replacement.
;
STATE	DB	0      ;State that this entry belongs to.
CHR	DB	SPACE  ;The character to look for.
NXTSTAT DB	0      ;State to go to when this token is found.
	ENDS	CTLNTRY

;
; Other Symbols
;
TAB	=	9
SPACE	=	32
	%NEWPAGE
	%SUBTTL "The Entry Vector"
;...............................................................................
; The  following macro aligns each jump on a 3 byte boundary.  That way, the
; "binary" declaration within the macro file can assume each function starts
; on the next multiple of 3

MACRO	JUMP	dest		;force a 3 byte jump
	DB	0E9H		;;jmp long
	DW	OFFSET dest - $ - 2
	ENDM
;...............................................................................

	PROC	VECTORS

	JUMP	STARTTABS	;StartTabs
	JUMP	ENDALINE	;EndALine
;	JUMP	TABALINE	;TabALine (not real jump - just falls in.

	ENDP	VECTORS
	%NEWPAGE
	%SUBTTL "Routine To Compress A Line"
;===============================================================================
;
;	integer proc TabALine( var string LineIn, var string LineOut,
;						  integer StartState )	 : 6
;
;	Enter  with  a pointer to the string to be processed, a pointer to a
;	string to receive the resulting string, and a starting state for the
;	string.	  Move	the  line  to  be processed into the string "LineIn"
;	before calling.	 Have a sufficiently large (but empty) string  ready
;	to  receive  the  results ("LineOut").	Place the starting state for
;	the line as "StartState", and call in.	Upon return, "LineOut"	will
;	contain	 the processed data, the contents of "LineIn" are unchanged,
;	and the new state will be returned as an integer.
;
;	If the return code is negative, an error has occurred.
;
;	This  routine  assumes	that you've called "StartTabs" to initialize
;	the tab system, and that you are supplying the state  returned	from
;	that call, or the state returned from the last call to "TabALine" or
;	"EndALine" as the "StartState".	 The value  will  be  in  the  range
;	0-15,  and represents one of the states in the control info supplied
;	in your call to "StartTabs".  This parameter  is  not  checked,	 and
;	wrong  values give stra-a-ange results.	 It does, however, allow you
;	to override or otherwise manipulate  the  way  in  which  "TabALine"
;	operates,  and	it lets you resubmit smaller pieces of a line if you
;	get "LineOut" overflows.
;
;	To make it possible to handle lines longer than 255 bytes,  TabALine
;	does  not  recognize end-of-line.  You pass the line to be processed
;	to "TabALine" one piece at a time until the  entire  line  has	been
;	processed,  then  call	"EndALine" to invoke the end-of-line proces-
;	sing.  Each call to "TabALine" must be provided with the state	code
;	returned  from the previous call to "TabALine".	 "EndALine" does NOT
;	get the state, but it DOES return one.	This returned state must  be
;	used in the next call to "TabALine".
;
;	IMPORTANT:  The way to get a negative (error) return code is to have
;	insufficient room in the  output  string  to  hold  the	 results  of
;	expanding  tabs in the input string.  This problem is most likely to
;	occur whenever you are replacing tabs with spaces.   When  expanding
;	tabs,  you  should  use	 smaller  chunks for your input strings, and
;	check the return code.	If it is negative, break your  input  string
;	into smaller chunks and resubmit, using the same state code to start
;	off the first piece of the string as the  state	 code  you  used  to
;	start  the  original  piece.   You can do this recursively until the
;	string gets correctly processed.
;
;	The  code in TabALine may seem oddly ordered.  This is the result of
;	trying to minimize jumps along frequently taken	 paths	through	 the
;	code  and  avoidance  of  Jcond -- JMP	constructs which jump either
;	way, thus introducing a pipeline delay into both branches.
;
;-------------------------------------------------------------------------------

	PROC	TABALINE FAR

	; The stack:
@@InStr EQU	[DWORD BP+16]		;Pointer to input string.
; Max length of input string ignored
@@OutSt EQU	BP+10			;Pointer to output string.
; Upper byte of output string max length ignored
@@OSMxL EQU	[BYTE BP+8]		;Maximum length of output string.
; Upper 3 bytes of requested state ignored
@@RStat EQU	[BYTE BP+4]		;Requested starting state.
; ret address	BP + 0

	LOCAL	@@SAVEAREA : BYTE : 4	=@@VARSIZ
;
; Initialize
;
	MOV	BP, SP			;Address the parameters.
	SUB	SP, @@VARSIZ		;Allocate local variables on stack.
	CLD

	MOV	AX, [WORD CS:CRNTST]
	MOV	[WORD @@SAVEAREA], AX

	LDS	SI, @@InStr		;Get pointer to input string.
	LODSW				;Get its length
	MOV	DH, AL			;and point to start of string.
	INC	DH			;Adjust length for counting.
	LES	DI, [DWORD @@OutSt]	;Get address of output string.
	ADD	DI, 2
	MOV	DL, @@OSMxL		;Get maximum size
	INC	DL			;and adjust for counting.
	JNZ	@@OSRDY			;Maximum size of output string is
	DEC	DL			;limited to 254 bytes.
@@OSRDY:
	MOV	[@@SAVEAREA+3], DL	;Save for return string size calc.
	MOV	CX,[WORD CS:NXTAB]	;Get distance to next tab & space count.
	MOV	AH, [CS:CTRLBTS]	;Get control bits.
	MOV	[@@SAVEAREA+2], AH	;Save 'em in case of error.
	MOV	AL, @@RStat		;Get starting state from caller.
	AND	AL, 0Fh
	MOV	BX, OFFSET XLATTBL	;Ready to go.

	CMP	AL, [CS:CRNTST]		;Does caller want state changed?
	JE	@@STRDY			;Jump if not.

	TEST	AH, SP2TB		;Need to put out some spaces?
	JZ	@@2NUST			;Just change states if not.
	SUB	DL, CH			;Enough room for spaces?
	JNA	@@ERRXIT		;Uh-oh, if not,
	PUSH	CX			;else get us some working registers.
	MOV	CL, CH			;Ready the count.
	XOR	CH, CH
	JCXZ	@@NOSP			;Jump if no spaces needed.
	PUSH	AX
	MOV	AL, SPACE		;Put out the spaces.
	REP
	STOSB
	POP	AX
@@NOSP:
	POP	CX			;Restore things.
@@2NUST:
	CALL	SWSTATS			;Change states.
@@STRDY:
	JMP	@@INTST			;Go to processing loop.
;
; Exit with error
;
@@ERRXIT:
	MOV	DI, [WORD @@OutSt]
	XOR	AX, AX			;Return zero-length output string.
	STOSW
	DEC	AX			;Return -1 error code.
	MOV	DX, AX
	ADD	SP, @@VARSIZ		;Deallocate local variables.
	RETF				;Back to caller.
;
; Register useage: AH - current state control bits
;		   AL - current character
;		   BX - pointer to translate table
;		   CH - count spaces during space-to-tab conversions
;		   CL - count to next tab position
;		   DH - input string counter
;		   DL - output string counter
;		   DS:SI - input string pointer
;		   ES:DI - output string pointer
;

;
; Process one-space interval
;
@@XTRATB:
	AND	AH, NOT NDTB		;Kill the flag.
	DEC	DL			;Plant tab for one-space interval
	JZ	@@OUTFUL		;now that we know there is more than
	STOSB				;one space.
	XOR	CH, CH			;Unprocessed spaces count starts over.
	JMP	@@CTTB			;Continue processing
;
; Process conversion of spaces to tabs
;
@@SPC2TBS:
	TEST	AH, SP2TBS		;Compress spaces?
	JZ	@@CHROUT		;Treat as non-special character.
	TEST	AH, SP2TB		;Are we processing spaces-to-tabs now?
	JZ	@@STSP2TB		;Go start it if not right now.
	MOV	AL, TAB
	TEST	AH, NDTB		;Do we need an extra tab?
	JNZ	@@XTRATB		;Yes, to complete last interval (which
@@CTTB:					;only had one space).
	INC	CH			;Count the space we have now.
	DEC	CL			;Time to put in a tab?
	JNZ	@@INTST			;Jump if not yet.
	DEC	DL			;Store the tab.
	JZ	@@OUTFUL
	STOSB
	MOV	CL, [CS:TABWDTH]	;Distance to next tab stop.
	XOR	CH, CH			;Reset the space counter.
	JMP	@@INTST
;
; Start new conversion interval
;
@@STSP2TB:
	OR	AH, SP2TB		;Flag "converting spaces to tabs".
	MOV	CH, 1			;Initialize space count.
	DEC	CL			;Right next to tab stop?
	JNZ	@@INTST			;To next character if not.

	OR	AH, NDTB		;If yes, note we might need a tab,
	MOV	CL, [CS:TABWDTH]	;and start next tab stop.
	JMP	@@INTST
;
; Spaces end before next tab stop
;
@@FNSHSC:
	SUB	DL, CH			;Enough room for spaces?
	JNA	@@OUTFUL
	PUSH	CX			;Okay, get us some working registers.
	MOV	CL, CH			;Ready the count.
	XOR	CH, CH
	JCXZ	@@NUN			;Jump if no spaces to plant.
	PUSH	AX
	MOV	AL, SPACE		;No tab, put out the
	REP				;original spaces.
	STOSB
	POP	AX
@@NUN:
	POP	CX			;Restore things.
	AND	AH, NOT (SP2TB OR NDTB) ;Not converting a space sequence.
	JMP	@@TBTST			;Go see what we've got.
;
; Output string overflows
;
@@OUTFUL:				;If the output string overflows,
	MOV	AL, [@@SAVEAREA]	;switch back to original entry state,
	CALL	SWSTATS
	MOV	AX, [WORD @@SAVEAREA+1] ;then restore other entry conditions.
	MOV	[WORD CS:NXTST], AX
	JMP	@@ERRXIT		;Go to return error code.
;
; Main processing loop
;
@@MORE:
	LODSB				;Get next byte.
	TEST	AH, END1		;Processing one-character state?
	JNZ	@@1SHOT			;Jump if yes.
	CMP	AL, SPACE		;Is it a space?
	JE	@@SPC2TBS		;See if compressing if yes.
	TEST	AH, SP2TB		;Doing space compression?
	JNZ	@@FNSHSC		;Need to put out some spaces if yes.
@@TBTST:
	CMP	AL, TAB			;Have we a tab?
	JE	@@XPNDTBS		;Yes, go expand it if that's needed.
@@CHROUT:
	DEC	DL			;Move character to output if there's
@@RELAY:				;enough room.  (also used as a relay
	JZ	@@OUTFUL		;from out-of-range jump.)
	STOSB
	DEC	CL			;Count distance to next tab point.
	JZ	@@2NXTTB		;Reset if we hit one.
@@XLT:
	XLAT	[CS:XLATTBL]		;Does this character flag state change?
	OR	AL, AL
	JNZ	@@SCHG			;Jump if it does.
@@INTST:
	DEC	DH			;Input string exhausted?
	JNZ	@@MORE			;Process next character if not.
;
; Normal exit
;
	MOV	[WORD CS:NXTAB], CX	;Save current status
	MOV	[CS:CTRLBTS], AH
	MOV	AL, [@@SAVEAREA+3]	;Calculate size of output string--
	SUB	AL, DL
	XOR	DX, DX
	MOV	AH, DH
	MOV	DI, [WORD @@OutSt]	;--and store it there.
	STOSW
	MOV	AL, [CS:CRNTST]		;Return current state as an integer.
	ADD	SP, @@VARSIZ		;Release space for local variables.
	RETF
;
; Start new tab interval
;
@@2NXTTB:
	MOV	CL, [CS:TABWDTH]
	JMP	@@XLT
;
; Expand tabs
;
@@XPNDTBS:
	TEST	AH, XPTBS		;Are we expanding tabs?
	JNZ	@@XTAB			;Expand it if yes, else
	MOV	CL, 1			;force next tab position alignment.
	JMP	@@CHROUT		;Copy the tab out.
@@XTAB:
	SUB	DL, CL			;Be sure there's enough room to hold
	JNA	@@OUTFUL		;spaces in the output string.
	XOR	CH, CH
	PUSH	AX
	MOV	AL, SPACE		;Move spaces to output string.
	REP
	STOSB
	POP	AX
	MOV	CL, [CS:TABWDTH]	;Reset count to next tab position.
	JMP	@@INTST			;Back to main processing.
;
; Change state
;
@@SCHG:
	DEC	AL			;Calculate new state value.
	CMP	AL, SPACE-1		;Use default state?
	JNE	@@SWST			;Jump if no,
	MOV	AL, [CS:NXTST]		;else get default state.
@@SWST:
	CALL	SWSTATS			;Switch to new state.
	JMP	@@INTST			;Process next character.
;
; Process one-character state
;
@@1SHOT:
	DEC	DL			;Move character to output if there's
	JZ	@@RELAY			;enough room.
	STOSB
	DEC	CL			;Count distance to next tab point.
	JZ	@@NUTB			;Reset if we hit one.
@@QBYPS:
	TEST	AH, CHK4BAK		;Bypass testing this character?
	JZ	@@SKIP1			;No, just skip it.
@@@XLT:
	XLAT	[CS:XLATTBL]		;Does this character flag state change?
	OR	AL, AL
	JNZ	@@SCHG			;Jump if it does.

	INC	DH			;Back up pointers to reprocess
	DEC	SI			;the last character.
	INC	DL
	DEC	DI
	INC	CL
@@SKIP1:
	MOV	AL, [CS:NXTST]		;Get default state.
@@SWP:
	CALL	SWSTATS			;Switch states.
	JMP	@@INTST			;Process next character.

@@NUTB:
	MOV	CL, [CS:TABWDTH]	;Start new tab interval.
	JMP	@@QBYPS

	ENDP	TABALINE
	%NEWPAGE
	%SUBTTL "End-Of-Line Processing"
;===============================================================================
;
;	integer proc EndALine( var string LineOut )			 : 3
;
;	You call this function whenever you reach an end of line.  Since TSE
;	allows for lines longer than 255 bytes, and the maximum length of  a
;	string	is  255	 bytes, you may have to send the line to TabALIne in
;	pieces.	 (See the notes for "TabALines", above.)   Thus	 we  need  a
;	separate function to signal an end-of-line condition.
;
;	Call  EndALine with a var string parameter.  Usually nothing will be
;	put in this string, but in the case  where  you	 are  NOT  stripping
;	trailing  spaces  from	each  line, the line ends in spaces, you are
;	converting spaces to tabs, and the  spaces  do	not  end  at  a	 tab
;	boundary,  you	will  find  some spaces here to tack onto the end of
;	your result line.  The size of this string need not exceed the	size
;	of the tab width.
;
;	The  return value is either -1 (in case your "LineOut" string is too
;	short to take spaces generated)	 or  the  state	 that  results	from
;	reaching end of line.  You must save the returned state value to use
;	in your next call to TabALine().
;
;-------------------------------------------------------------------------------

	PROC	ENDALINE FAR

	; The stack:
@@OutSt EQU    [DWORD BP+6]		;Pointer to result string.
@@OSMxL EQU    [WORD BP+4]		;Maximum length of result string.
; ret address	BP + 0

	MOV	BP, SP			;Address parameter.
	CLD

	LES	DI, @@OutSt		;Locate output string.
	XOR	AX, AX
	TEST	[CS:CTRLBTS], SP2TB	;Converting a string of spaces?
	JZ	@@SETSIZ		;Jump if not.
	MOV	AL, [CS:SPCCT]		;Get count of spaces needed.
@@SETSIZ:
	CMP	AX, @@OSMxL		;Is there enough room for the spaces?
	JA	@@BUBU			;Jump if not.
	STOSW				;Set output string size.
	MOV	CX, AX			;Zero length?
	JCXZ	@@SETTBW		;All done if it is,
	MOV	AL, SPACE		;else put spaces in output string.
	REP
	STOSB

@@SETTBW:
	MOV	AL, [CS:TABWDTH]	;Set first tab position for next line
	MOV	[WORD CS:NXTAB], AX	;and clear SPCCT.
@@AGAIN:
	MOV	AX, [WORD CS:CRNTST]	;Get current and default states.
	TEST	[CS:CTRLBTS], EOLNDS	;Does EOL end current state?
	JZ	@@RTN			;Jump if not.
	CMP	AH, AL			;To same state? (Protects against loops,
	JE	@@RTN			;though only immediate ones.)

	MOV	AL, AH			;Get new state.
	CALL	SWSTATS			;Set it.
	JMP	@@AGAIN			;See if we back out of this, too.
@@RTN:
	XOR	DX, DX			;Return what is now current state.
	MOV	AH, DH
	RETF				;Back to caller.
;
@@BUBU:
	XOR	AX, AX			;In case result string is too short,
	STOSW				;return zero-length string
	DEC	AX			;and a -1 return code.
	MOV	DX, AX
	RETF

	ENDP	ENDALINE
	%NEWPAGE
	%SUBTTL "Initialization Routine"
;===============================================================================
;
;	integer proc StartTabs( string SetupString, integer TabSize )	 : 0
;
;	You supply a setup string as described elsewhere, and the width of a
;	tab.  If everything is okay, StartTabs returns	the  starting  state
;	(0, if you must know).	It is this state value that you pass back in
;	when you call TabALine.	 If an error occurs, -1 is returned.
;
;	NOTE:  the  only error that is checked for is a setup string that is
;	NOT an integral number of four-character entries long, or  one	with
;	more  than  16	entries,  or  one  with	 NO entries.  You have to be
;	careful about preparing your entries, and you should test them	with
;	care.	You don't have to do this very often, so it should NOT be an
;	imposition.  If necessary, we can add more checks at another time.
;
;	If  TabSize  is zero, it will be assumed to be 8.  If TabSize is too
;	big, you'll get an error (-1) return.  Only the	 low-order  word  is
;	checked, and it must not exceed 64.
;
;	StartTabs  must	 always be called before the first call to TabALine,
;	and at any time that the scanning rules must be changed.
;
;-------------------------------------------------------------------------------

	PROC	STARTTABS FAR

	; The stack:
@@StpSt EQU    [DWORD BP+8]		;Pointer to the setup string.
@@TabSz EQU    [WORD BP+4]		;Tab width.
; ret address	BP + 0

	MOV	BP, SP			;To address the parameters.
	CLD

	XOR	DX, DX			;Handy zero.
	MOV	AX, @@TabSz		;Get tab width.
	CMP	AX, 64			;Check for excessive width.
	JA	@@BADNESS
	OR	AL, AL			;If zero, make it 8.
	JNZ	@@SVTB
	MOV	AL, 8
@@SVTB:
	MOV	[CS:TABWDTH], AL	;Save tab width.
	MOV	[WORD CS:NXTAB], AX	;Set up position of first tab.
					;(Also clears SPCCT.)
	LDS	SI, @@StpSt		;Point at the string
	LODSW				;and get its length.
	TEST	AL, 3			;There must be an integral number
	JNZ	@@BADNESS		;of 4-character entries.
	SHR	AL, 1
	SHR	AL, 1
	JZ	@@BADNESS		;There must be at least one entry--
	CMP	AX, 16			;--but not more than 16.
	JNA	@@OK2GO
@@BADNESS:
	DEC	DX
	MOV	AX, DX			;Set up -1.
	RETF				;Back to caller.

@@OK2GO:
	MOV	CX, AX			;Loop count ready.
	MOV	AX, CS			;Address the state table.
	MOV	ES, AX
	MOV	DI, OFFSET STATTBL
;
; Okay, we're ready to go.
;
; Register useage: AL - Entry character being processed.
;		   CX - Count of entries to process.
;		   DX - preset to zero for return value and handy constant.
;		   DS:SI - Pointer to next character in setup string.
;		   ES:DI - Pointer to next place in entry table.
;
@@NXTNTRY:
	LODSW				;Next entry: Get control bits and state.
	DEC	AH			;Suck 'em down by one, then
	DEC	AL			;mask off upper nybble.
	AND	AX, 0F0Fh
	STOSW				;Store results.
	LODSW				;Get next bytes.
	CMP	AH, SPACE		;Prepare "next state" byte.
	JE	@@RQDFLT		;Don't mask it if it requests default.
	DEC	AH			;This forces next state into the range
	AND	AH, 0Fh			;1 - 16.  We don't want a zero value
	INC	AH			;since it will go into the XLAT table.
@@RQDFLT:
	STOSW				;Store next state and character.
	LOOP	@@NXTNTRY		;Process all entries.

	MOV	AX,0FF00h		;Plant stopper.
	STOSW

	MOV	AX, DX			;Clear the translate table.
	MOV	CL, 128			;CH is already zero.
	MOV	DI, OFFSET XLATTBL
	REP
	STOSW
	MOV	[CS:NXTST], AL
	CALL	NEWSTATE		;Set up table for initial state (zero).

	MOV	AX, DX			;Return starting state to caller.
	RETF				;Done.

	ENDP	STARTTABS
	%NEWPAGE
	%SUBTTL "Helper Subroutines"
;===============================================================================
;
;	Helper subroutines
;
;-------------------------------------------------------------------------------

;
; Switch states
;
;	NOTE:  Enter with desired new state in AL
;
	PROC	SWSTATS NEAR

	CMP	AL, [CS:CRNTST]		;Is state REALLY changing?
	JE	@@GOBAK			;Skip processing if not.
;
; Register useage: AH - current state
;		   AL - new state being requested
;		   BH - handy zero value
;		   BX - index into XLAT table
;		   SI - pointer into STATTBL
;
	PUSH	SI			;These registers will be used,
	PUSH	BX			;so save them.

	MOV	AH, [CS:CRNTST]		;Get current state.
	MOV	[CS:NXTST], AH		;Save as next default state.
	MOV	SI, [CS:CEPTR]		;Get pointer to current state 1st entry.
	XOR	BH, BH
@@CLRNXT:
	MOV	BL, [CS:(STATTBL+SI).CHR] ;Get next control character.
	MOV	[CS:XLATTBL+BX], BH	;Clear its entry in translate table.
	ADD	SI, 4			;Bump to next state table entry.
	CMP	AH, [CS:(STATTBL+SI).STATE] ;Is it part of this state?
	JAE	@@CLRNXT		    ;Go clear it if yes.

	CALL	NEWSTATE		;Go set up the new state.

	POP	BX			;Restore caller.
	POP	SI
	MOV	AH, [CS:CTRLBTS]	;Get new control bits.
@@GOBAK:
	RETN

	ENDP	SWSTATS
	%NEWPAGE
;
; Set up new state
;
;	NOTE: This routine expects the desired new state to be in AL
;
	PROC	NEWSTATE NEAR

	XOR	BH, BH			;Need some zero values.
	MOV	AH, BH
	MOV	SI, AX
	SHL	SI, 1			;Calculate offset in STATTBL to
	SHL	SI, 1			;first entry for this state.
	MOV	[CS:CEPTR], SI		;Save for next clear-state.
	MOV	[CS:CRNTST], AL		;Plant new state value.
	MOV	BL, [CS:(STATTBL+SI).NXTSTAT]
	CMP	BL, SPACE		;If next state is not space,
	JE	@@GTDFLT		;save it as possible default.
	DEC	BL			;(Value is one higher than correct.)
	MOV	[CS:NXTST], BL
@@GTDFLT:
	MOV	BL, [CS:(STATTBL+SI).CTLBTS]
	CMP	[CS:(STATTBL+SI).CHR], SPACE
	JE	@@SAVNXT		;Space can't be found.	If not space,
	OR	BL, CHK4BAK		;then we may have to retest char.
@@SAVNXT:
	MOV	[CS:CTRLBTS], BL	;Make it easy to access control bits.
	JMP	@@1STNTRY
;
; Register useage: AH - used to store (next state + 1) in XLAT table
;		   AL - New state value
;		   BX - Index into translate table
;		   SI - Offset to current entry in state table
;
@@NXTNTRY:
	OR	[CS:CTRLBTS], CHK4BAK	    ;More than one entry for this state
					    ;means we may have to retest last
@@1STNTRY:				    ;character if others not found.
	MOV	BX, [WORD CS:(STATTBL+SI).CHR]
	MOV	AH, BH			    ;Get character and use as index
	XOR	BH, BH			    ;into translate table to store
	MOV	[CS:XLATTBL+BX], AH	    ;next state.
	ADD	SI, 4			    ;Bump to next state table entry.
	CMP	AL, [CS:(STATTBL+SI).STATE] ;Is it part of this state?
	JAE	@@NXTNTRY		    ;Include it if yes.

	MOV	[CS:XLATTBL+TAB], 0	    ;Space and tab have
	MOV	[CS:XLATTBL+SPACE], 0	    ;special meanings.

	RETN				    ;Back to caller.

	ENDP	NEWSTATE
	%NEWPAGE
	%SUBTTL "Constants and Work Areas"
;===============================================================================
;
;	The XLAT table, the State Table and other such things that can't be
;	allocated on the stack are kept here.
;
;-------------------------------------------------------------------------------

;
;  This is the state table that controls the operation of the Tabolator.
;  It can hold a MAXIMUM of 16 entries.
;
	EVENDATA
STATTBL CTLNTRY 16 DUP ({})		;Initialized to do-nothing.
	DW	0FF00h			;Stopper (high value in .STATE).
;
;  The XLAT table is used to determine the course of action to be taken when
;  a particular character is encountered while scanning a line.
;

XLATTBL DB	256 DUP (0)		;Initialized to zeros (do nothing).

;
;  Variables that have to be preserved between calls to Tabolator routines
;
;	WARNING! DO NOT CHANGE THE ORDER OR SIZE OF ANY OF THESE VARIABLES!
;		 They are, on occasion, picked up and deposited in pairs!
;
CEPTR	DW	0		;Direct offset to current entry in STATTBL.
NXTAB	DB	0		;Count to next tab stop.
SPCCT	DB	0		;Accumulated spaces to be converted to tab.
CRNTST	DB	0		;Current state.
NXTST	DB	0		;Possible default state to use.
CTRLBTS DB	0		;Control bits for this state.
TABWDTH DB	0		;The width of a tab with high-order zero.


	ENDS	_TEXT

	END
