; Steve Watkins 09/10/92

_TEXT  segment
       assume  cs:_TEXT

JUMP    MACRO   dest            ;force a 3 byte jump
        db      0e9h            ;jmp
        dw      offset dest - $ - 2
        ENDM

SS_VECTORS      proc
        JUMP    ENHANCEDSHIFTSTATE
        JUMP    NORMALSHIFTSTATE
        JUMP    BIOSSHIFTSTATE
SS_VECTORS      endp


ENHANCEDSHIFTSTATE proc far
        mov     ah, 12h
        jmp     common
ENHANCEDSHIFTSTATE endp

NORMALSHIFTSTATE proc far
        mov     ah, 2h
        common:
        int     16h
        mov     ah, 0
        xor     dx,dx
        ret
NORMALSHIFTSTATE endp


BIOSSHIFTSTATE proc far
        mov     ax,40h
        mov     es,ax
        mov     bx,17h
        mov     al,[es:bx]
        xor     ah,ah
        xor     dx,dx
        ret
BIOSSHIFTSTATE endp



_TEXT   ends
        end

