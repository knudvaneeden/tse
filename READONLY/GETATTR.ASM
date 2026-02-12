        locals

_TEXT   segment
        assume  cs:_TEXT
;
; integer GetFileAttr(string s)
;
; attr = GetFileAttr(CurrFilename() + Chr(0))
;
; long pascal GetFileAttr(uchar *far string);
;
;                       bp+06 seg string
;                       bp+04 ofs string
;                       bp+02 seg ret
;                       bp+00 ofs ret
;
GetFileAttr proc far
        mov     bp, sp
        lds     dx, [bp+4]              ; ofs string
        inc     dx                      ; move past the length
        inc     dx                      ;    word
        mov     ax, 4300h               ; get file attributes
        int     21h                     ; dos call
        mov     ax, cx                  ; assume success
        jnc     @@exit                  ; if so, go there
        xor     ax, ax                  ; otherwise, no attributes
@@exit:
        cwd                             ; and get answer in dx:ax
        retf
GetFileAttr endp

_TEXT   ends
        end
