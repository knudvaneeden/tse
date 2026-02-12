	%PAGESIZE 57, 132
	%TITLE	"Additional String Support For Semware Editor Macros"
	%SUBTTL "Preliminaries"
	IDEAL
;******************************************************************************;
;									       ;
;		CRAZY JACK'S ADDITIONAL STRING SUPPORT ROUTINES		       ;
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
; These are routines that set and clear bits in bit sets and replace existing  ;
; characters in strings.  SAL is not good for doing stuff like that!	       ;
;									       ;
; The routines are defined by:						       ;
;   binary ["strstuff.bin"]						       ;
;	integer proc TestBitSetBit( var string BitSet, integer Which )	  :  0 ;
;	integer proc SetBitSetBit( var string BitSet, integer Which )	  :  2 ;
;	integer proc ClrBitSetBit( var string BitSet, integer Which )	  :  4 ;
;	integer proc FlipBitSetBit( var string BitSet, integer Which )	  :  6 ;
;	integer proc PlantChar( var string CharStr, integer Where,	       ;
;						    integer What )	  :  8 ;
;	proc ClearBitSet( var string BitSet )				  : 10 ;
;   end									       ;
;									       ;
; Further details are given below with each routine.			       ;
;									       ;
; This assembles with the Turbo Assembler v 3.2 and better (and maybe worser). ;
;									       ;
;******************************************************************************;

	SEGMENT _TEXT
	ASSUME	CS:_TEXT
	LOCALS
	%NEWPAGE
	%SUBTTL "The Entry Vector"

;
; These routines are so small that all can be reached with two-byte jumps!
;
	PROC	VECTORS

	JMP	SHORT TSTBTSTBT	      ;TestBitSetBit()
	JMP	SHORT STBTSTBT	      ;SetBitSetBit()
	JMP	SHORT CLBTSTBT	      ;ClrBitSetBit()
	JMP	SHORT FLBTSTBT	      ;FlipBitSetBit()
	JMP	SHORT PLNTCHR	      ;PlantChar()
;	JMP	SHORT CLRBTST	      ;ClearBitSet() (not real jump - just falls
;									     in)

	ENDP	VECTORS
	%NEWPAGE
	%SUBTTL "Routine To Clear A Bit Set"
;===============================================================================
;
;	proc ClearBitSet( var string BitSet )	: 6
;
;	Clears	all  bytes in the string given by the parameter "BitSet" to
;	all bits off and sets the length f the string equal to its  maximum
;	length.
;
;-------------------------------------------------------------------------------

	PROC	CLRBTST FAR

	; The stack:
@@Set	EQU    [DWORD BP+6]		;Pointer to the string.
@@MaxL	EQU    [WORD BP+4]		;Maximum length of the string.
; ret address	BP + 0

	MOV	BP, SP			;Address parameters.
	LES	DI, @@Set		;Address the set.
	MOV	AX, @@MaxL		;Get maximum length.
	XOR	AH, AH			;Enforce high-order zero.
	MOV	CX, AX			;Make copy for count.
	CLD
	STOSW				;Set length in set string.
	XOR	AL, AL			;We're gonna fill it with zeros.
	REP				;Fill it.
	STOSB

	RETF				;All done.

	ENDP	CLRBTST
	%NEWPAGE
	%SUBTTL "Routine To Test A Bit In A Bit Set"
;===============================================================================
;
;	integer proc TestBitSetBit( var string BitSet, integer Which ) : 0
;
;	This  test  the	 bit  number given by "Which" in the bit set string
;	"BitSet".  It returns 0 if the bit is NOT set, > 0 otherwise.
;
;	If the bit is outside the hit set, -1 is returned.
;
;-------------------------------------------------------------------------------

	PROC	TSTBTSTBT FAR

	;The stack:
@@BtSt	EQU	[DWORD BP+10]		;Address of set string containing bit.
; Max length word for BtSt is ignored.
; upper word of @@Which is ignored.
@@Which EQU	[WORD BP+4]		;Bit to test.
; ret address	BP + 0

	MOV	BP, SP			;Address parameters.
	LDS	SI, @@BtSt		;Get address of set.
	MOV	CX, @@Which		;Get bit number.

	CALL	CALCOBIT		;Get offset and bit.

	MOV	AL, CH
	AND	AL, [SI+BX]		;Leaves 0 if bit off, else non-zero.
	MOV	AH, DH			;Ready result for caller.

	RETF				;Done.

	ENDP	TSTBTSTBT
	%NEWPAGE
	%SUBTTL "Routine To Set A Bit In A Bit Set"
;===============================================================================
;
;	integer proc SetBitSetBit( var string BitSet, integer Which )	: 2
;
;	This routine turns ON the bit specified by "Which" in the  bit	set
;	string "BitSet".
;
;	It  returns  > 0  if the previous value of the bit selected was ON,
;	0 if it was OFF, and -1 if it was OUTSIDE the given string.
;
;-------------------------------------------------------------------------------

	PROC	STBTSTBT FAR

	;The stack:
@@BtSt	EQU	[DWORD BP+10]		;Address of set string where bit goes.
; Max length word for BtSt is ignored.
; upper word of @@Which is ignored.
@@Which EQU	[WORD BP+4]		;Bit to set.
; ret address	BP + 0

	MOV	BP, SP			;Address parameters.
	LDS	SI, @@BtSt		;Get address of set.
	MOV	CX, @@Which		;Get bit number.

	CALL	CALCOBIT		;Get offset and bit.

	MOV	AL, [SI+BX]		;Get original data.
	OR	CH, AL			;Set the bit.
	MOV	[SI+BX], CH		;Put back result.
	AND	AL, CL			;Mask off original bit value.
	MOV	AH, DH			;Ready return to caller.

	RETF				;Done.

	ENDP	STBTSTBT
	%NEWPAGE
	%SUBTTL "Routine To Clear A Bit In A Bit Set"
;===============================================================================
;
;	integer proc ClrBitSetBit( var string BitSet, integer Which )	: 2
;
;	This routine turns OFF the bit specified by "Which" in the bit	set
;	string "BitSet".
;
;	It  returns  > 0  if the previous value of the bit selected was ON,
;	0 if it was OFF, and -1 if it was OUTSIDE the given string.
;
;-------------------------------------------------------------------------------

	PROC	CLBTSTBT FAR

	;The stack:
@@BtSt	EQU	[DWORD BP+10]		;Address of set string where bit goes.
; Max length word for BtSt is ignored.
; upper word of @@Which is ignored.
@@Which EQU	[WORD BP+4]		;Bit to clear.
; ret address	BP + 0

	MOV	BP, SP			;Address parameters.
	LDS	SI, @@BtSt		;Get address of set.
	MOV	CX, @@Which		;Get bit number.

	CALL	CALCOBIT		;Get offset and bit.

	NOT	CH			;Make bit mask.
	MOV	AL, [SI+BX]		;Get original data.
	OR	CH, AL			;Clear the bit.
	MOV	[SI+BX], CH		;Put back result.
	AND	AL, CL			;Mask off original bit value.
	MOV	AH, DH			;Ready return to caller.

	RETF				;Done.

	ENDP	CLBTSTBT
	%NEWPAGE
	%SUBTTL "Routine To Flip A Bit In A Bit Set"
;===============================================================================
;
;	integer proc ClrBitSetBit( var string BitSet, integer Which )	: 2
;
;	This  routine turns inverts the bit specified by "Which" in the bit
;	set string "BitSet".
;
;	It  returns  > 0  if the previous value of the bit selected was ON,
;	0 if it was OFF, and -1 if it was OUTSIDE the given string.
;
;-------------------------------------------------------------------------------

	PROC	FLBTSTBT FAR

	;The stack:
@@BtSt	EQU	[DWORD BP+10]		;Address of set string where bit goes.
; Max length word for BtSt is ignored.
; upper word of @@Which is ignored.
@@Which EQU	[WORD BP+4]		;Bit to clear.
; ret address	BP + 0

	MOV	BP, SP			;Address parameters.
	LDS	SI, @@BtSt		;Get address of set.
	MOV	CX, @@Which		;Get bit number.

	CALL	CALCOBIT		;Get offset and bit.

	MOV	AL, [SI+BX]		;Get original data.
	XOR	CH, AL			;Flip the bit.
	MOV	[SI+BX], CH		;Put back result.
	AND	AL, CL			;Mask off original bit value.
	MOV	AH, DH			;Ready return to caller.

	RETF				;Done.

	ENDP	FLBTSTBT
	%NEWPAGE
	%SUBTTL "Routine To Replace A Character In A String"
;===============================================================================
;
;	integer proc PlantChar( var string CharStr, integer Where,
;						    integer What )     :  4
;
;	You  give  this routine a pointer to a string (that's what the "var"
;	does), the index to one of the characters (Where) and the  character
;	(as an integer) that you want stored there (What) and PlantChar puts
;	What into Where in the CharStr.	 It does:
;
;	CharStr[Where] = Chr(What)
;
;	--in other words.  This is something SAL doesn't support directly.
;
;	It  returns  the  previous contents of the byte being changed if the
;	byte specified is within the string, and -1 otherwise.
;
;-------------------------------------------------------------------------------

	PROC	PLNTCHR FAR

	; The stack:
@@Str	EQU    [DWORD BP+14]		;Pointer to the string.
; Max string length not used (word at BP+12)
; Upper word of Whr not used
@@Whr	EQU    [WORD BP+8]		;Index into string.
; Upper three bytes of Wht not used
@@Wht	EQU    [BYTE BP+4]		;Character to store.
; ret address	BP + 0

	MOV	BP, SP			;Address parameters.
	XOR	DX, DX			;Ready high-order word of return.
	MOV	BX, @@Whr		;Get index.
	OR	BX, BX			;It must be greater than zero.
	JZ	@@NDXBAD		;Jump if not.
	LDS	SI, @@Str		;Get address of string.
	LODSW				;Get string length.
	CMP	AX, BX			;Is index within string?
	JB	@@NDXBAD		;Jump if it's not.

	MOV	AL, @@Wht		;Get the data.
	MOV	[SI+BX-1], AL		;Store the data.
	MOV	AX, 1			;Return TRUE.
	RETF				;Back to caller.

@@NDXBAD:
	MOV	AX, DX			;Return FALSE to caller.
	RETF

	ENDP	PLNTCHR
	%NEWPAGE
	%SUBTTL "Additional Material"
;===============================================================================
;
;	Helper routine
;
;-------------------------------------------------------------------------------

;
; Calculate offset in string and create testing/setting bit
;	* Put bit number in CX before calling
;	* Put pointer to string in DS:SI.
;	* Returns offset to byte IN SET in BX, and bit in proper position in CH.
;	* Clears DX.
;	* Takes error exit if byte outside the string.
;	* Adjusts DS:SI to point at beginning of actual string data.
;

	PROC	CALCOBIT NEAR

	MOV	BX, CX			;We need to locate byte and bit.
	SHR	BX, 1			;<sigh> -- we must use only 8088
	SHR	BX, 1			;instructions.
	SHR	BX, 1			;Offset in string ready.

	AND	CL, 7			;Get bit number mod 8.
	MOV	CH, 1			;Use it to position a bit.
	SHL	CH, CL
	MOV	CL, CH			;Make an extra copy.

	XOR	DX, DX			;Clear DX (high-order word of return).
	LODSW				;Get string length.
	CMP	AX, BX			;Be sure bit is within the string.
	JBE	BADNDX			;Jump if not.

	RETN				;Stuff ready for user.

BADNDX:					;Bit is outside the string.
	POP	AX			;Toss return from CALCOBIT.
	DEC	DX
	MOV	AX, DX			;Return -1.
	RETF				;Short-cut back to caller.

	ENDP	CALCOBIT


	ENDS	_TEXT

	END
