;
; integer cd(string s)
;
; cd('..' + Chr(0))
;
; long PASCAL cd(uchar *far string);
;
;                       bp+06 seg string
;                       bp+04 ofs string
;                       bp+02 seg ret
;                       bp+00 ofs ret
;
cd proc
        mov     bp,sp
        lds     dx,[bp+4]               ; ofs string
        inc     dx                      ; move past the length
        inc     dx                      ;    word
        mov     ah,3bh                  ; change dir
        int     21h                     ; dos call
        mov     ax, 0                   ; assume error...
        jc      @@exit
        inc     ax                      ; single success
@@exit:
        cwd
        retf
cd endp