	%PAGESIZE 57, 132
	%TITLE	"Bit Set Support For Semware Editor Macros"
	%SUBTTL "Preliminaries"
	IDEAL
;******************************************************************************;
;									       ;
;			 CRAZY JACK'S BIT SET ROUTINES			       ;
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
; These are routines to convert bit strings to and from the character strings  ;
; used by WordSet and VarTabs.	SAL does not support this for variables.       ;
;									       ;
; The routines are defined by:						       ;
;   binary ["bitset.bin"]						       ;
;	integer proc WrdChrs2WrdSet( string LetterSet, var string Result ):  0 ;
;	integer proc TabSet2TabPosns( string VTabSet, var string TabStr ) :  3 ;
;	integer proc TabPosns2TabSet( string TabStr, var string VTabSet ) :  6 ;
;	integer proc WrdSet2WrdChrs( string BitSet, var string Result )	  :  9 ;
;   end									       ;
;									       ;
; Further details are given below with each routine.			       ;
;									       ;
; This assembles with the Turbo Assembler v 3.2 and better (and maybe worser). ;
;									       ;
; Some	attention has been paid to reducing the number of jumps along the most ;
; likely path in loops, which sometimes gives rise to odd sequences.	       ;
;									       ;
; Alas, the calling sequence used by SAL precludes our using  the  fancy  PROC ;
; parameter addressing features of the Turbo Assembler, which assumes that the ;
; BP has been pushed on the stack just after the call.			       ;
;									       ;
;******************************************************************************;

       SEGMENT _TEXT
       ASSUME  CS:_TEXT
       LOCALS
       %NEWPAGE
       %SUBTTL "The Entry Vector"
;...............................................................................
; The  following  macro aligns each jump on a 3 byte boundary.	That way, the
; "binary" declaration within the macro file can assume each function  starts
; on the next multiple of 3.

	MACRO	JUMP dest	;force a 3 byte jump
	DB	0E9H		;;jmp
	DW	OFFSET dest - $ - 2
	ENDM
;...............................................................................

	PROC	VECTORS

	JUMP	WC2WS		;WrdChrs2WrdSet()
	JUMP	TS2TP		;TabSet2TabPosns()
	JUMP	TP2TS		;TabPosns2TabSet()
;	JUMP	WS2WC		;WrdSet2WrdChrs() (not real jump; just falls in)

	ENDP	VECTORS
	%NEWPAGE
	%SUBTTL "Convert a WordSet Bit Set To A Character String"
;===============================================================================
;
;	integer proc WrdSet2WrdChrs( string BitSet, var string Result ) : 9
;
;	This  routine  examines	 the  bits  in	the bit set string given by
;	"BitSet" and  builds  a	 string	 in  "Result"  that  sepcifies	the
;	characters to be selected.  If the result string is not long enough
;	to hold the complete resulting string, WrdSet2WrdChrs returns zero,
;	otherwise it returns 1.
;
;-------------------------------------------------------------------------------

	PROC	WS2WC FAR

	;The stack:
@@BtSt	EQU	[DWORD BP+10]		;Bit set string to convert.
@@Rslt	EQU	[DWORD BP+6]		;A Character string to receive result.
@@MaxRL EQU	[BYTE BP+4]
; ret address	BP+0
	LOCAL	@@SWITCH : BYTE = @@VARSIZ
@@NEEDASH =	1

	MOV	BP, SP			;Address parameters.
	SUB	SP, @@VARSIZ		;Allocate local variable
	MOV	[@@SWITCH], 0		;Don't need a dash.
	CLD
	LES	DI, @@Rslt		;Point to start of result string.
	MOV	DL, @@MaxRL		;Get maximum result string size allowed.
	INC	DL			;Set up result size limit counter.
	LDS	SI, @@BtSt		;Point to bit set.
	LODSW				;Get its length.

	MOV	CL, AL			;Set byte count for bit set.
	INC	CL
	XOR	BX, BX			;Output length = 0.
	MOV	DH, BH			;Flag "we don't need a dash".
	MOV	CH, BH			;Initialize character value.
	MOV	DH, 1			;Set a testing bit.

	JMP	@@STATE0B		;Begin the processing.
;
; This routine is organized as a state machine, but it uses the program
; counter as the state variable.
;
; Register useage: AL - current byte of bit set being tested.
;		   BX - index into result string (and result length, thereby)
;		   CH - value of current character
;		   CL - bytes remaining to check in bit set string
;		   DH - Counts bits by shifting.
;		   DL - count to limit result size
;		   DS:SI - pointer to current byte in bit set string
;		   ES:DI - pointer to result string
;
; In state 0 we are looking for a character that is by itself, or starts
; a range.
;
@@STATE0A:
	OR	[@@SWITCH], @@NEEDASH	;Flag "we need a dash".
	JMP	@@STATE0
@@STATE0B:
	DEC	CL			;Any more bytes to process?
	JZ	@@DUN			;Jump if not
	LODSB				;else get next byte.
	OR	AL, AL			;Any bits in this byte at all?
	JNE	@@STATE0C		;Go process them if yes,
	ADD	CH, 8			;else count across all 8 bits
	JMP	@@STATE0B		;and try the next byte.
@@STATE0:
	INC	CH			;Value of next character.
	ROL	DH, 1			;Next bit to test.
	JC	@@STATE0B		;Jump if bits in byte exhausted.
@@STATE0C:
	SHR	AL, 1			;Is this bit on?
	JNC	@@STATE0		;Keep looking if not.

	CMP	CH, '-'                 ;This bit stand for dash?
	JE	@@STATE0A		;Jump if it does.
;
; In state 1 we have a character.  It may start a group, or it may be a
; stand-alone character.  We'll find out.
;
	DEC	DL			;Be sure we have room for a character.
	JZ	@@OFLO			;Jump if no more room.
	INC	BX			;Where new output character goes.
	MOV	[ES:DI+BX+1], CH	;Move character to output string.

	INC	CH			;Value of next character.
	ROL	DH, 1			;Next bit to test.
	JNC	@@STATE1A		;Jump if bits in byte not exhausted.

	DEC	CL			;Any more bytes to process?
	JZ	@@DUN			;Jump if not.
	LODSB				;Get next byte of bit set.
@@STATE1A:
	SHR	AL, 1			;Is this bit on?
	JNC	@@STATE0		;If not, there's no sequence.
					;We may have two in a row.
	CMP    CH, '-'                  ;This bit stand for dash?
	JE     @@STATE0A		;Sequence is broken if it does.
;
; In state 2 we've got two characters in a row and we're looking for three.
;
	DEC	DL			;Be sure we have room for a character.
	JZ	@@OFLO			;Jump if no more room.
	INC	BX			;Where new output character goes.
	MOV	[ES:DI+BX+1], CH	;Move character to output string.

	INC	CH			;Value of next character.
	ROL	DH, 1			;Next bit to test.
	JNC	@@STATE2A		;Jump if bits in byte not exhausted.

	DEC	CL			;Any more bytes to process?
	JZ	@@DUN			;Jump if not.
	LODSB				;Get next byte of bits.
@@STATE2A:
	SHR	AL, 1			;Is this bit on?
	JNC	@@STATE0		;If not, the sequence is just two long.

	DEC	DL			;Be sure we have room for 3rd character.
	JZ	@@OFLO			;Jump if no more room.
	INC	BX			;Where 3rd output character goes.
	MOV	[BYTE ES:DI+BX], "-"	;Overwrite 2nd character with dash.
	JMP	@@STATE3		;Go find last character of series.
;
; In state 3 we have a sequence three or more characters long and we are looking
; for the end of the sequence.
;
@@STATE3A:
	DEC	CL			;Any more bytes to process?
	JZ	@@STATE3C		;Jump if not.
	LODSB				;Get next byte of set.
	JMP	@@STATE3B
@@STATE3:
	ROL	DH, 1			;Next bit to test.
	JC	@@STATE3A		;Jump if bits in byte not exhausted.
@@STATE3B:
	INC	CH			;Value of next character.
	SHR	AL, 1			;Is this bit on?
	JC	@@STATE3		;If yes, we're still in sequence.

	DEC	CH			;Retrieve last character.
@@STATE3C:
	MOV	[ES:DI+BX+1], CH	;Move 3rd character to output string.
	INC	CH			;Back to current character.  (Will wrap
					;to zero at end!)
	JNZ	@@STATE0		;Jump if more characters to go.
@@DUN:
	TEST	[@@SWITCH], @@NEEDASH	;Do we need a dash?
	JNZ	@@DODASH		;Jump if not.
@@OKAY:
	MOV	AX, 1			;Return "TRUE".
@@STRSIZ:
	MOV	[ES:DI], BX		;Store result string size in string.
	XOR	DX, DX			;Clear high-order word of return value.

	MOV	SP, BP			;Toss local variables.
	RETF				;Back to the caller.

@@OFLO:				;We have overflowed the Result area.
	XOR	AX, AX			;Return "FALSE".
	JMP	@@STRSIZ

@@DODASH:			;We need an explicit dash.
	DEC	DL			;Be sure we have room for it.
	JZ	@@OFLO			;Jump if we don't,
	INC	BX			;else add a dash to end of string.
	MOV	[BYTE ES:DI+BX+1], "-"	;Stash the dash.
	JMP	@@OKAY			;Go finish up.

	ENDP	WS2WC
	%NEWPAGE
	%SUBTTL "Convert A Character String To A WordSet Bit Set"
;===============================================================================
;
;	integer proc WrdChrs2WrdSet( string LetterSet, var string Result ) : 12
;
;	This procedure takes a string of letters specifying the contents of
;	a WordSet bit string and produces the bit string.   If	the  result
;	string	is  not EXACTLY 32 bytes long, it is forced to 32 bytes and
;	cleared; otherwise it is assumed to be a legit WordSet bit  string,
;	and  the  characters called for by the "LetterSet" string are ADDED
;	to it.	If this is not the effect you want, either  clear  the	bit
;	string	yourself  (using ClearBitSet()), or set it to "".  If there
;	are no	problems,  WrdChrs2WrdSet  returns  TRUE.   The	 only  real
;	problem	 it  can  have is if the Result string maximum size is less
;	than 32 bytes.	In this case, the Result string is not changed, and
;	WrdChrs2WrdSet returns FALSE.
;
;-------------------------------------------------------------------------------

	PROC	WC2WS FAR

	;The stack:
@@LtrSt EQU	[DWORD BP+10]		;String of letters to put in word set.
@@Rslt	EQU	[DWORD BP+6]		;Where to build the word set bit array.
@@MaxRL EQU	[WORD BP+4]		;There had BETTER be at least 32 bytes!
; ret address	BP+0

	MOV	BP, SP			;Address parameters.
	CLD
	XOR	DX, DX			;We'll need this later.
	LES	DI, @@Rslt		;Get pointer to result string.
	MOV	AX, 32
	CMP	[ES:DI], AX		;Is it EXACTLY 32 bytes long?
	JE	@@USEIT			;Yes, keep it as is.
	CMP	@@MaxRL, AX		;Can it be made 32 bytes long?
	JAE	@@FORCE			;Go do it if it can.

	MOV	AX, DX			;Can't use this string.
	RETF				;Return FALSE.

@@FORCE:
	STOSW				;Force 32-bit length.
	MOV	CX, 16			;Clear all bits in the string.
	MOV	AX, DX
	REP
	STOSW
	SUB	DI, 34
@@USEIT:
	INC	DI			;Simplify addressing of bit set.
	INC	DI
	LDS	SI, @@LtrSt		;Point to the spec string.
	LODSW				;Get string length.
	MOV	CH, AL			;Set up counter to say when we're done.
	INC	CH
	MOV	BH, DH			;Ensure high-order zero.

;
; As  before,  we use a kind of staste machine in which the program counter
; acts as the state variable.  There are only two states  involved  here  -
; processing single characters, and processing ranges.
;
; Register useage: AH - positioned bit for ORing into bit set string.
;		   AL - picking up characters, and counting in ranges.
;		   BX - pointer to byte where bit is to go.
;		   CH - count of chars left to process.
;		   CL - shift counter for positioning bit; temp holder.
;		   DX - zero for when we return; supplies zeros to load, too.
;		   DS:SI - points to character string.
;		   ES:DI - points to bit set.
;
; In state 0 we are just looking at single characters.
;

@@STATE0:
	DEC	CH			;Any more characters to process?
	JZ	@@DUN			;We're finished if not.
STATE0A:
	LODSB				;Get next character to set bit for.
	MOV	BL, AL			;Set its bit.
	SHR	BL, 1
	SHR	BL, 1
	SHR	BL, 1
	MOV	CL, AL
	AND	CL, 7
	MOV	AH, 1
	SHL	AH, CL
	OR	[ES:DI+BX], AH

	CMP	CH, 3			;Do we have AT LEAST two more characters
	JB	@@STATE0		;to process? Jump if not,

	CMP	[BYTE SI], '-'          ;else see if we might have a range.
	JNE	@@STATE0		;Jump if not.

	CMP	CH, [SI+1]		;It might be -- is end <= start?
	JA	@@STATE0		;If not, it isn't a range.

;
; In state 1 we are processing a range.
;
	DEC	CH			;Count next two xharacters as
	DEC	CH			;processed.
	MOV	CL, AL			;Save start char (still in AL).
	INC	SI			;Advance pointer past "-".
	LODSB				;Get end character.
	SUB	AL, CL			;Get difference.
	JZ	@@STATE0		;Jump if no more bits to set.

@@STATE1:
	ROL	AH, 1			;Shift to next bit.
	JC	@@STATE1B		;Jump if time to go to next byte.
@@STATE1A:
	OR	[ES:DI+BX], AH		;Set next bit.
	DEC	AL			;All bits in series set?
	JNZ	@@STATE1		;Jump if not.

	DEC	CH			;Any more characters to process?
	JNZ	STATE0A			;If yes, go do 'em.
@@DUN:
	MOV	AX, 1			;Return TRUE to caller.
	RETF				;All done.

@@STATE1B:				;Advance to next byte.
	INC	BX			;Bit in AH will be in the right place.
	JMP	@@STATE1A

	ENDP	WC2WS
	%NEWPAGE
	%SUBTTL "Convert A VarTabs Bit Set To An ASCII String Of Tab Positions"
;===============================================================================
;
;	integer proc TabSet2TabPosns( string VTabSet, var string TabStr ) : 12
;
;	This  procedure	 converts a VarTabs bit set into a character string
;	that lists the tab positions.  If  the	"TabStr"  provided  by	the
;	caller	isn't  big  enough to hold the entire list, TabSet2TabPosns
;	returns FALSE, otherwise it returns TRUE.
;
;-------------------------------------------------------------------------------

	PROC	TS2TP FAR

	;The stack:
@@VTSet EQU	[DWORD BP+10]
@@TbStr EQU	[DWORD BP+6]
@@MaxSL EQU	[BYTE BP+4]
; ret address	BP+0

	MOV	BP, SP			;Address parameters.
	CLD
	XOR	BX, BX			;Initial length of output string.
	LDS	SI, @@VTSet		;Point to tabs bit set.
	LODSW				;Get its length.
	OR	AL, AL			;Zero length bit set is poopoo.
	JZ	@@DUN
	MOV	CL, AL
	LES	DI, @@TbStr		;Get pointer to result string.
	MOV	DL, @@MaxSL		;Get max length of output string.
	INC	DL
	MOV	DH, 1			;Initialize bit counter.
	MOV	CH, BH			;Current character.
	JMP	@@NXTBYT
;
; Here	is the main loop of this program.  It checks bits to see which tab
; positions are set.  When it finds one it goes to a routine that converts
; the position into a character string.
;
; Register useage: AH - used for division
;		   AL - used for division; holds current byte from bit set.
;		   BX - index into and current length of result string.
;		   CH - current character value.
;		   CL - count number of bit set bytes processed.
;		   DH - bit-being-tested-in-this-byte counter
;		   DL - count to limit length of output string.
;		   DS:SI - pointer to VarTabs bit set
;		   ES:DI - pointer to character string being built.
;
;
@@NXTBIT:
	SHR	AL, 1			;Next bit on?
	JC	@@GOTATAB		;Yes, go convert position to number.
@@CNTBIT:
	INC	CH			;Advance position value.
	ROL	DH, 1			;Done with this byte?
	JNC	@@NXTBIT		;No, go check next bit.

	DEC	CL			;Any more bytes to process?
	JZ	@@DUN			;We're finished if not.
@@NXTBYT:
	LODSB				;Get the next byte from bit set.
	OR	AL, AL			;Are there any bits?
	JNZ	@@NXTBIT		;Yes, go process this byte.

	ADD	CH, 8			;No, skip over these values.
	DEC	CL			;Any more bytes?
	JNZ	@@NXTBYT		;Yes, go check next one out.
@@DUN:
	MOV	AX, 1			;Set TRUE for caller.
	OR	BX, BX			;Any characters in result string?
	JZ	@@STRSIZ		;Jump if not,
	CMP	[BYTE ES:DI+BX+1], ' '  ;else see if trailing space.
	JNE	@@STRSIZ		;Jump if no trailing space,
	DEC	BX			;else remove it.
@@STRSIZ:
	MOV	[WORD ES:DI], BX	;Store length of result string.
	XOR	DX, DX			;Clear high word of return code.
	RETF				;Back to caller.

;
; This routine converts the current tab position (in CH) into a decimal
; number string.
;
@@GOTATAB:
	MOV	AH, ' '                 ;Prepare trailing blank.
	PUSH	AX			;This also saves byte being checked.
	MOV	AL, CH			;Get the position.
@@XTRACT:
	XOR	AH, AH			;Set up for divide.
	DIV	[BYTE CS:TEN]		;Divide by ten, remainder is in AH.
	OR	AH, '0'                 ;Convert to ASCII digit.
	PUSH	AX			;Save the digit.
	OR	AL, AL			;Any more original number left?
	JNZ	@@XTRACT		;Extract next digit if yes.
@@NXTDGT:				;
	POP	AX			;Get next digit for output.
	DEC	DL			;Room for another char in result string?
	JZ	@@OFLO			;Jump if not,
	INC	BX			;else add character to the end
	MOV	[ES:DI+BX+1], AH	;of the result string.
	CMP	AH, ' '                 ;Was it end-of-number trailing space?
	JNE	@@NXTDGT		;Go get next digit if not.

	JMP	@@CNTBIT		;Test byte restored, go check next bit.

@@OFLO:
	CMP	AH, ' '                 ;Just trailing blank?
	JNE	@@CNTBIT		;We can let it go if yes.

	MOV	SP, BP			;Bad stuff if not; restore the stack
	XOR	AX, AX			;and return FALSE.
	JMP	@@STRSIZ		;Back to caller.

	ENDP	TS2TP
	%NEWPAGE
	%SUBTTL "Convert An ASCII String Of Tab Positions To A VarTabs Bit Set"
;===============================================================================
;
;	integer proc TabPosns2TabSet( string TabStr, var string VTabSet ) : 15
;
;	This  is  the obverse of the previous routine: it converts a string
;	of tab positions into a bit set.  VTabSet MUST be AT LEAST 32 bytes
;	long.	If  it is, the tabs in the string will be ADDED to whatever
;	is already there, otherwise it will  be	 FORCED	 to  32	 bytes	and
;	cleared, then the new positions will be added.	If the result CAN'T
;	be forced to 32 bytes, it remain unchanged  and	 a  FALSE  will	 be
;	returned, otherwise TRUE is returned.
;
;	Only  spaces  and  decimal digits are acceptable.  If there are any
;	other characters found, they will be treated as spaces, but a FALSE
;	will be returned.
;
;	The  positions	may  range  from  zero	through 255, though zero is
;	meaningless and higher values are strange, too.	 Range checking	 is
;	NOT  performed; out-of-range numbers are reduced modulo 256 with no
;	error flagged.
;
;-------------------------------------------------------------------------------

	PROC	TP2TS FAR

	;The stack:
@@TbStr EQU	[DWORD BP+10]		;String of tab positions in ASCII.
@@VTSet EQU	[DWORD BP+6]		;Where to build the tab set bit array.
@@MaxSL EQU	[WORD BP+4]		;There had BETTER be at least 32 bytes!
; ret address	BP+0

	MOV	BP, SP			;Address parameters.
	CLD
	XOR	DX, DX
	LES	DI, @@VTSet		;Get pointer to result string.
	MOV	AX, 32
	CMP	[ES:DI], AX		;Is it EXACTLY 32 bytes long?
	JE	@@USEIT			;Yes, keep it as is.
	CMP	@@MaxSL, AX		;Can it be made 32 bytes long?
	JAE	@@FORCE			;Go do it if it can.

	MOV	AX, DX			;Can't use this string.
	RETF				;Return FALSE.

@@FORCE:
	STOSW				;Force 32-bit length.
	MOV	CX, 16			;Clear all bits in the string.
	MOV	AX, DX
	REP
	STOSW
	SUB	DI, 34
@@USEIT:
	INC	DI			;Simplify addressing of bit set.
	INC	DI
	LDS	SI, @@TbStr		;Point to the spec string.
	LODSW				;Get string length.
	MOV	CH, AL			;Set up counter to say when we're done.
	INC	CH
	MOV	BH, DH			;Ensure high-order zero.
	INC	DL			;No bad characters -- yet...
	JMP	@@NXTCHR		;Begin processing.

;
; Nothing tricky here, though the instruction ordering is aimed at reducing
; overall execution time on an 8088.
;
; Register useage: AH - positioned bit for ORing into bit set string.
;		   AL - picking up characters.
;		   BX - pointer to byte where bit is to go.
;		   CH - count of chars left to process.
;		   CL - shift counter for positioning bit; ASCII to binary conv.
;		   DH - handy zero.
;		   DL - 1 unless bad character found, then zero.
;		   DS:SI - points to ASCII tab position string.
;		   ES:DI - points to bit set.
;
@@QTAB:
	CMP	AL, 9			;Is it a tab?
	JE	@@NXTCHR		;Yes, is okay delimiter.

	MOV	DL, DH			;Not digit or whitespace, flag error.
	JMP	@@NXTCHR		;Get next character.

@@SEP:
	CMP	AL, ' '                 ;Separator a space?
	JNE	@@QTAB			;No, see if tab.
@@NXTCHR:
	DEC	CH			;Is there another character?
	JZ	@@DUN			;Jump if not,
	LODSB				;else get next character.
	CMP	AL, '0'                 ;Is it a digit?
	JB	@@SEP
	CMP	AL, '9'
	JA	@@SEP

@@GOTDGT:				;We've got a digit,
	MOV	CL, DH			;start accumulation of value.
@@NXTDGT:
	MOV	AH, CL			;Multiply accumulating value by ten.
	SHL	AH, 1			;(This way is quickler than
	SHL	AH, 1			;the MUL instruction.
	ADD	CL, AH
	SHL	CL, 1
	SUB	AL, '0'                 ;Digit to binary.
	ADD	CL, AL			;Accumulate.

	DEC	CH			;Any more characters?
	JZ	@@SETBIT		;Go set the bit if no,
	LODSB				;else get the next character.
	CMP	AL,'0'                  ;Is it a decimal digit?
	JB	@@SETBIT
	CMP	AL,'9'
	JNA	@@NXTDGT		;If it is, continue accululation.

@@SETBIT:
	MOV	BL, CL
	AND	CL, 7			;Get bit offset in byte.
	SHR	BL, 1			;Get byte offset in string.
	SHR	BL, 1
	SHR	BL, 1
	MOV	AH, 1
	SHL	AH, CL			;Position the bit.
	OR	[ES:DI+BX], AH		;Set the bit.

	OR	CH, CH			;Any more characters?
	JNZ	@@SEP			;Go check 'em if there are.

@@DUN:
	MOV	AX, DX			;Get result code.
	MOV	DL, DH			;Clear high-order word of result.
	RETF				;Back to the caller.

	ENDP	TP2TS
	%NEWPAGE
	%SUBTTL "Additional Material"
;
; Some constants
;
TEN:	DB	10			;Used in binary-to-ASCII conversion.


	ENDS	_TEXT

	END
