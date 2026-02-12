
;support assembler file for QKEYS

locals
JUMP    MACRO   dest            ;force a 3 byte jump
        db      0e9h            ;jmp
        dw      offset dest - $ - 2
ENDM

_TEXT  segment
       assume  cs:_TEXT
begin:

JumpTable proc
    JUMP    IsKeyPressed
    JUMP    GetKeyTail
    JUMP    SpeedUpKeyboard
    JUMP    CheckVideoMode
    JUMP    PeekData
JumpTable endp

; Check to see if a key is pressed.  Functionally equivalent to SAL
; command KeyPressed(), but _much_ faster.
; Returns TRUE if a key is pressed, otherwise FALSE
;
IsKeyPressed proc far
        xor ax,ax                    ; low memory addresses
        mov ds,ax
        mov ax,ds:[41ah]             ; get the keyboard head
        sub ax,ds:[41ch]             ; cmp to the keyboard tail
        xor dx,dx
        retf
IsKeyPressed endp

; Returns the offset address of the keyboard tail
;
GetKeyTail proc far
        mov ax,40h                  ; point at the low memory addresses
        mov es,ax
        mov ax,es:[1ch]             ; get the keyboard tail address
        xor dx,dx
        retf
GetKeyTail endp

;------------------------------------------------------
;INT 16 - KEYBOARD - SET DELAYS (Jr,AT model 339,XT286,PS)
;	AH = 03h
;	AL = subfunction
;	    0 reset typematic (PCjr)
;	    1 increase initial delay (PCjr)
;	    2 increase continuing delay	(PCjr)
;	    3 increase both delays (PCjr)
;	    4 turn off typematic (PCjr)
;	    5 Set typematic rate (AT or	PS/2)
;	BH = 00	- 03 for delays	of 250ms, 500ms, 750ms,	or 1s
;	BL = 00	- 1F for typematic rates of 30cps down to 2cps
;------------------------------------------------------

; This call sets the typematic keyboard rates, including the initial delay
; and the keyboard repeat rate
;
;                       bp+06 int hiword
;                       bp+04 int loword
;                       bp+02 seg ret
;                       bp+00 ofs ret
;
SpeedUpKeyboard proc far
    mov bp,sp                       ; prepare to access stack parameters
    mov bx,[bp+4]                   ; get the speedups to bx
    mov al,5                        ; set typematic rate
    mov ah,3                        ; function-3
    int 16h                         ; keyboard interrupt
    retf
SpeedUpKeyboard endp

; This call returns the video mode
;
CheckVideoMode proc far
    mov ah,0fh                      ; get video mode
    int 10h                         ; video interrupt
    and ax,7fh                      ; don't want bit 8
    xor dx,dx
    retf
CheckVideoMode endp

; This call allows the user to peek at any real data address
;
;                       bp+06 int segment
;                       bp+04 int offset
;                       bp+02 seg ret
;                       bp+00 ofs ret
;
PeekData proc far
    mov bp,sp                       ; prepare to access stack parameters
    mov bx,[bp+4]                   ; get the offset
    mov es,[bp+6]                   ; get the segment
    mov ax,es:[bx]                  ; read the data word
    xor dx,dx
    retf
PeekData endp

_TEXT   ends
        end begin

