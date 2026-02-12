locals
MASM

; Macros ------------------------------------------------------------------
JUMP	MACRO	dest		;force a 3 byte jump
	db	0e9h		;jmp
	dw	offset dest - $ - 2
ENDM


; Text Segment ------------------------------------------------------------
_TEXT	segment
	assume	cs:_TEXT


;--------------------------------------------------------------------------
; entry point jump table for functions
JumpTable proc
	JUMP	ColorPicklist
JumpTable endp


;--------------------------------------------------------------------------
;
; proc ColorPicklist(integer X, integer Y, integer Cols, integer Rows,
;	string TagStr, integer HiAttr)
;
; highlights any lines in the given window area that begin with TagStr,
; using HiAttr as the new foreground color (background color is not changed).
;
ColorPicklist proc
	ARG	dummy:WORD, HiAttr:WORD, TagStr:DWORD, Rows:WORD, Cols:WORD, Y:WORD, X:WORD = ARGS
	LOCAL	ScreenCols:WORD = VARS

	; setup stack
	push	bp
	mov	bp,sp
	sub	sp,VARS

	; bail if empty tag string, cx == 0, or cy == 0
	lds	si,[TagStr]
	lodsw
	cmp	ax,0
	je	@@done
	cmp	[Cols],0
	je	@@done
	cmp	[Rows],0
	je	@@done

	; find cols
        xor     ax,ax
        mov     es,ax
        mov     ax,[WORD PTR es:44ah]
        mov	[ScreenCols],ax

	; find screen segment
	mov	ax,0b800h
	mov	es,ax
	mov	ah,0fh
	int	10h
	cmp	al,7
	jne	@@iscolor
	mov	ax,0b000h
	mov	es,ax
@@iscolor:

	; look for tag
@@loop:
	mov	cx,[ScreenCols]		; calc pointer to screen
	mov	ax,[Y]
	dec	al
	mul	cl
	add	ax,[X]
	dec	ax
	shl	ax,1
	mov	di,ax			; es:di points to screen now
	push	di			; save it (start of line)

	; get tag string
	lds	si,[TagStr]
	lodsw
	mov	cx,ax			; cx == length of tag string
@@findtag:
	cmpsb				; compare character
	jne	@@nope			; if not match goto next line
	inc	di			; inc past attr
	loop	@@findtag

	; matched!
	pop	di			; get start of line again
	push	di			; (or it'll crash later)
	mov	cx,[Cols]		; # of characters to hilight
	mov	bx,[HiAttr]		; new attr
	and	bx,0fh			; mask foreground
@@colorme:
	inc	di			; inc to attr
	mov	al,[es:di]		; get current attr from screen
	and	al,0f0h			; preserve background
	or	al,bl			; use hilight color
	mov	[es:di],al		; write new attr back to screen
	inc	di			; inc to next screen position
	loop	@@colorme

@@nope:
	pop	ax			; don't need start of line anymore
	inc	[Y]			; go down to next line
	dec	[Rows]			; dec # lines remaining
	jnz	@@loop			; any lines left?

	; restore stack
@@done:
	add	sp,VARS
	pop	bp
	retf
endp


; End of Text Segment -----------------------------------------------------
_TEXT	ends
	end

