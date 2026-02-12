;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;²²² Program:       IsDir.asm                                               ²²²
;²²²ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ²²²
;²²² Date:          07/25/94                                                ²²²
;²²²ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ²²²
;²²² Author:        RW Klein (Edmonton Alberta Canada)                      ²²²
;²²²                Compuserve ID = 73364,451                               ²²²
;²²²ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ²²²
;²²² Description:   TSE bin file to determine if passed string is the name  ²²²
;²²²                of a directory.                                         ²²²
;²²²ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ²²²
;²²² Compiler:      MASM 6.00                                               ²²²
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
.MODEL Huge,Pascal
.CODE

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±±± Align each jump on a 3 byte boundary. ±±±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
JUMP MACRO dest                 ;; Force a 3 byte jump
        db      0e9h            ;; jmp opcode
        dw      offset dest - $ - 2
ENDM    JUMP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±±± Create Jump Table                                ±±±
;±±±  - needed if more than one procedure in BIN file ±±±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
JUMP    IsDir      ;; [0] checks if filename is a directory

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛÛ module:        IsDir                                                   ÛÛÛ
;ÛÛÛÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÛÛÛ
;ÛÛÛ parameters:    DirName ÄÄ string                                       ÛÛÛ
;ÛÛÛÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÛÛÛ
;ÛÛÛ returns:       1 ÄÄ DirName is the name of a directory                 ÛÛÛ
;ÛÛÛ                0 ÄÄ DirName is NOT the name of a directory             ÛÛÛ
;ÛÛÛÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÛÛÛ
;ÛÛÛ description:   Determines if DirName is a directory.                   ÛÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
IsDir PROC DirName:dWord
;ßßßßßßßßßßßßßßßßßßßßßßß
lds si,DirName        ;; DS:SI = string structure
xor bx,bx
mov bl,Byte Ptr [si]  ;; BL = length of string
inc si
inc si                ;; DS:SI = string start (skip length byte & reserved byte)
mov dx,si             ;; DS:DX = start of string

;±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±±± Make DirName ASCIIz ±±±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±
add si,bx           ;; ds:si = last char of string + 1
mov bl,[si]         ;; save char after string (so it can be null terminated)
mov Byte Ptr [si],0 ;; null terminate the string (make it ASCIIz)

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±±± Get File Attribute of DS:DX ±±±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
mov ax,4300h
int 21h                 ;; get file attrib of ds:dx
.if carry?
    xor ax,ax           ;; error
.else
    xor ax,ax           ;; set return value (0=not a directory)
    test cx,00010000b   ;; is it a directory?
    .if !zero?
        inc ax          ;; set return value (1=directory)
    .endif
.endif

mov Byte Ptr [si],bl    ;; restore char after string (replace zero in ASCIIz)

xor dx,dx               ;; set high return word to zero (dx:ax is returned)
ret
;ÜÜÜÜÜÜÜÜÜÜÜÜ
IsDir ENDP ;Û
;ßßßßßßßßßßßß
END
