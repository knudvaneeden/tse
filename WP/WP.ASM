locals
JUMP    MACRO   dest            ;force a 3 byte jump
        db      0e9h            ;jmp
        dw      offset dest - $ - 2
ENDM

_TEXT  segment
       assume  cs:_TEXT

JumpTable proc
    JUMP    findfirst
    JUMP    findnext
    JUMP    setattrib
JumpTable endp

;
; integer proc findfirst(string path, var string ffblk, integer flags)
;
; long PASCAL findfirst(uchar *far path, uchar *far ffblk, int max_len, long flags);
;
;                       bp+16 seg path
;                       bp+14 ofs path
;                       bp+12 seg ffblk
;                       bp+10 ofs ffblk
;                       bp+08 max_len
;                       bp+06 hi flags
;                       bp+04 lo flags
;                       bp+02 seg ret
;                       bp+00 ofs ret
;
findfirst:

        mov     bp,sp

        mov     ah,2Fh                  ; get original DTA
        int     21h
        push    bx                      ; preserve it
        push    es

        mov     cx,[bp+04]              ; flags

        lds     dx,[bp+10]
        ; we need to put 43 where ds:dx points to.
        push    dx
        pop     di
        mov     word ptr ds:[di], 43
        inc     dx                      ; move past length word
        inc     dx

        mov     ah,1Ah                  ; set new DTA
        int     21h

        lds     dx,[bp+14]              ; seg/ofs of path
        inc     dx
        inc     dx

        mov     ah,4Eh                  ; findfirst
        int     21h
        mov     bx, 0                   ; mov doesn't change flags
        jc      ff_failed
        inc     bx

    ff_failed:
        pop     ds                      ; seg(oldDTA)
        pop     dx                      ; ofs(oldDTA)
        mov     ah,1Ah                  ; set original DTA
        int     21h

        mov     ax, bx
        xor     dx, dx

        retf

;
; integer findnext(var string ffblk)
;
; long PASCAL findfirst(uchar *far ffblk, int max_len);
;
;                       bp+08 seg ffblk
;                       bp+06 ofs ffblk
;                       bp+04 max_len
;                       bp+02 seg ret
;                       bp+00 ofs ret       bp+00 becuase we don't push bp
;
findnext:

        mov     bp, sp

        mov     ah, 2Fh                  ; get original DTA
        int     21h
        push    bx                      ; preserve it
        push    es

        lds     dx, [bp+06]             ; ffblk
        inc     dx                      ; dx += 2 to move past the length word
        inc     dx

        mov     ah, 1Ah                 ; set new DTA
        int     21h

        mov     ah, 4Fh                 ; findnext
        int     21h
        mov     bx, 0
        jc      fn_failed
        inc     bx

    fn_failed:
        pop     ds                      ; seg(oldDTA)
        pop     dx                      ; ofs(oldDTA)
        mov     ah, 1Ah                 ; set orig DTA
        int     21h

        mov     ax, bx
        xor     dx, dx

        retf

;
; integer proc SetAttrib(string s, integer attrib)
;
; long PASCAL SetAttrib(uchar *far string, long attrib);
;
;       seg string         10
;       ofs string          8
;       hi-word attrib      6
;       lo-word attrib      4
;       seg return          2
;       ofs return          0
;
SetAttrib proc
        mov     bp,sp
        mov     cx,word ptr [bp+4]      ; lo attrib
        lds     dx,[bp+8]               ; ofs string
        inc     dx
        inc     dx
        mov     ax,4301h                ; Set attribute
        int     21h                     ; Call DOS
        mov     ax, 0                   ; assume error...
        jc      @@exit
        inc     ax                      ; single success
@@exit:
        cwd
        retf
SetAttrib endp

_TEXT   ends
        end
