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
	JUMP    writeaddr
	JUMP    writedata
ENDP	VECTORS


PROC writeaddr
    ARG  data:dword
    mov  dx, [word ptr data]
    mov  al, dl
    mov  dx,388h
    out  dx,al
    mov  cx,6
@@wait:
    in   al,dx
    loop @@wait
    ret
ENDP writeaddr

PROC writedata
    ARG  data:dword
    mov  dx, [word ptr data]
    mov  al,dl
    mov  dx,389h
    out  dx,al
    mov  cx,35h
    dec  dx
@@wait:
    in   al,dx
    loop @@wait
    ret
ENDP writedata

END
