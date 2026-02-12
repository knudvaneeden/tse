;       tasm %1             Turbo Assembler
;       tlink %1
;       exe2bin %1
;       del %1.obj
;       del %1.exe
;
;       masm %1             Microsoft Assembler V < 6
;       link %1
;       exe2bin %1
;       del %1.obj
;       del %1.exe
;
;       ml %1               Microsoft Assembler V >= 6
;       link %1
;       exe2bin %1
;       del %1.obj
;       del %1.exe

_TEXT  segment
       assume  cs:_TEXT

;//  the following macro aligns each jump on a 3 byte boundary. That
;//  way, the "binary" declaration within the macro file can assume
;//  each function starts on the next multiple of 3

JUMP    MACRO   dest            ;force a 3 byte jump
        db      0e9h            ;jmp
        dw      offset dest - $ - 2
        ENDM

VECTORS proc
        JUMP    oScan       ;   set overscan color for VGA monitors
        JUMP    bright      ;   toggle blink/intense bit
VECTORS endp


;// **************************************************************************
;// proc oScan (integer color)
;//
;// By: Peter Birch             07/23/93
;//
;// Set the VGA overscan area to the specified color
;//
ATTR                equ     bp + 4

oScan   proc    far     ; procedure must be FAR routine
        ; remember: no need to save registers for functions
        ; which are called directly by macro language
        ; direction flag is clear

        mov     bp, sp                  ; set up standard stack frame
        push    ss                      ; point ds to stack for this function
        pop     ds

        mov     bh,byte ptr [ATTR]      ; color
        mov     ax,1001h                ; set border
        int     10h

        retf                            ; return to macro

oScan   endp

;// **************************************************************************
;// proc bright (integer ONorOFF)
;//
;// By: Peter Birch                 07/23/93
;//
;// Set the Bright background color attribute or the Blink background attrib.
;// Pass 1 to set bright.
;// Pass 0 to set blink.
;//
ONorOFF     equ     bp + 4

bright  proc    far     ; procedure must be FAR routine

        mov     bp, sp                  ;set up standard stack frame
        push    ss                      ;point ds to stack for this function
        pop     ds

        mov     dx,word ptr [ONorOFF]
        cmp     dx,1
        sbb     ax,ax
        neg     ax
        mov     bl,al

        mov     ax,1003h                ; set blink/intense
        int     10h

        retf                            ;return to macro

bright  endp

_TEXT   ends
        end

