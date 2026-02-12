
;******** vid.asm **********************************************************
;
;	Video Routines - Binary inclusion file for TSE
;
;	Source Code (c) UK Rob Staveley 28-08-93
;
;***************************************************************************
IDEAL					; Using Borland's ideal mode syntax
MODEL	Huge,Pascal			; Pascal style parameters
CODESEG

;******** JUMP *************************************************************
; The following macro aligns each jump on a 3 byte boundary. That
; way, the "binary" declaration within the macro file can assume
; each function starts on the next multiple of 3. This is the mechanism
; suggested in BIN.DOC for having multiple macros in the binary file.
;
MACRO   JUMP	dest			;; Force a 3 byte jump
        db      0e9h			;; jmp opcode
        dw      offset dest - $ - 2
ENDM	JUMP

;******** VECTORS **********************************************************
; All public routines in Vid.Bin should be pointed to in this jump
; table. The ":n" at the end of each proc definition refers to a byte
; offset into this file. Each JUMP macro below occupies three bytes
; which mean that the ":n" values should go up in threes from zero.
;
	ORG	0			; This is the beginning of the code
					; Okay, superfluous!
PROC	VECTORS
	JUMP    SetMode			; [0] Sets video mode
	JUMP	SetPage			; [3] Selects video page
ENDP	VECTORS

;******** SetMode **********************************************************
; Set the video mode to the mode specified by the first argument
;
; Returns 1 on success
;
PROC	SetMode
	ARG	VidMode:DWORD
	mov	ax,[WORD PTR VidMode]
	xor	ah,ah
	int	10h
	mov	ah,0fh			; Check the current video mode
	int	10h
	cbw
	cmp	ax,[WORD PTR VidMode]	; Is the mode the same
	jz	@@ok
	xor	ax,ax
	jmp	short @@ex
@@ok:	mov	ax,1
@@ex:	xor	dx,dx
	ret
ENDP	SetMode

;******** SetPage **********************************************************
; Set active video page (prevent screen burn?)
;
PROC	SetPage
	ARG	PageNo:DWORD
	mov	ax,[WORD PTR PageNo]
	mov	ah,5			; Set Page function
	int	10h
	ret
ENDP	SetPage

END
