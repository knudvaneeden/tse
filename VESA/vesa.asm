; **********************************************************************
;
; VESA.ASM
; copyright (c) 1994 by Klaus Hartnegg, Kleist-Str. 7,
; D-79331 Teningen, Germany
;
; this is the assembler source for the binary file vesa.bin
; part of a vesa utility for The Semware Editor
;
; **********************************************************************

_TEXT  segment
       assume  cs:_TEXT

JUMP   MACRO   dest            ;force a 3 byte jump
       db      0e9h            ;jmp
       dw      offset dest - $ - 2
       ENDM

vectors proc
       JUMP    GetMemW
       JUMP    GetMemP
       JUMP    GetBuf1Addr
       JUMP    GetBuf2Addr
       JUMP    VesaTest
       JUMP    VesaInfo
       JUMP    VesaSetMode
vectors endp


GetMemW proc far
; get a word from memory
;      get address from stack
       push    bp
       mov     bp,sp
       mov     ax,[bp+6]
       mov     es,[bp+8]
       pop     bp

;      read word from given memory address
       push    di
       mov     di,ax
       mov     ax,es:[di]
       pop     di

       mov     dx,0
       retf    4
GetMemW endp


GetMemP proc far
; get a double word (pointer) from memory
;      get address from stack
       push    bp
       mov     bp,sp
       mov     ax,[bp+6]
       mov     es,[bp+8]
       pop     bp

;      read word from given memory address
       push    di
       mov     di,ax
       mov     ax,es:[di]
       inc     di
       inc     di
       mov     dx,es:[di]
       pop     di

       retf    4
GetMemP endp


GetBuf1Addr proc far
; return buffer address
       mov     dx,cs
       call    Buf1S
Buf1C: add     ax,offset Buf1
       sub     ax,offset Buf1C
       retf
Buf1S: pop     ax
       push    ax
       retn
GetBuf1Addr endp


GetBuf2Addr proc far
; return buffer address
       mov     dx,cs
       call    Buf2S
Buf2C: add     ax,offset Buf2
       sub     ax,offset Buf2C
       retf
Buf2S: pop     ax
       push    ax
       retn
GetBuf2Addr endp


Buf1     db 'portions copyright (c) 1993,94 by Klaus Hartnegg, D-79331 Teningen, Germany'
         db 262 dup (?)

Buf2     db 255 dup (?)


VesaTest proc far
; detect presence of vesa interface (fills buffer1)
       mov     ax,04F00h
       mov     bx,cs
       push    bx
       pop     es
       mov     di,offset(Buf1)
       Int     010h
       mov     dx,0
       retf
VesaTest endp


VesaInfo proc far
; get more informations about a vesa mode (fills buffer2)
;      get mode from stack
       push    bp
       mov     bp,sp
       mov     cx,[bp+6]
       pop     bp

       mov     ax, 04F01h
       mov     bx, cs
       push    bx
       pop     es
       mov     di, offset (Buf2)
       int     010h
       mov     dx,0

       retf    8
VesaInfo endp


VesaSetMode proc far
; activate a vesa mode
;      get mode from stack
       push    bp
       mov     bp,sp
       mov     bx,[bp+6]
       pop     bp

       mov     ax, 04F02h
       int     010h
       mov     dx,0

       retf    8
VesaSetMode endp


_TEXT   ends
        end
