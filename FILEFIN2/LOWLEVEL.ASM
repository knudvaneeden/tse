;   some low-level file routines for The SemWare Editor
;   by Peter Birch      08/11/94
;
;
seg_a       segment byte public
            assume  cs:seg_a, ds:seg_a


    org     0

lowlevel        proc    far

start::
        jmp     _open
        jmp     _seek
        jmp     _read
        jmp     _close

;//     int handle = _open(char *filename)
;//
;//     will open a file in readonly compatablitiy mode
;//
;//     bp+04 string_struct
;//     bp+00 word      ret
;//
_open::
        mov     bp,sp
        lds     dx,dword ptr [bp+4]
        inc     dx
        inc     dx
        mov     ax,3d40h        ;// open readonly, deny none
        int     21h
        jnc     NO_ERROR
        neg     ax              ;// error return value
NO_ERROR:
        xor     dx,dx                   ; Zero register
        retf                            ; Return far

;//     long    _seek(int handle, long offset, int method)
;//
;//     method = 0      seek (offset) bytes from beginning of file
;//     method = 1      seek (offset) bytes from current position in file
;//     method = 2      seek (offset) bytes from end of file
;//
;//     bp+12 dword     handle
;//     bp+08 dword     offset
;//     bp+04 dword     method or origin
;//     bp+00 dword     ret    new file offset
;//
_seek::
        mov     bp,sp
        mov     ah,42h
        mov     al,byte ptr [bp+04] ;// method
        mov     bx,word ptr [bp+12] ;// handle
        mov     dx,word ptr [bp+08] ;// noffset (low word)
        mov     cx,word ptr [bp+10] ;// noffset (high word)
        int     21h
        retf                            ; Return far

;//
;//
;//     int _read(int handle, char *buffer, int bytes2read)
;//
;//     bytes2read _MUST_ be LESS than 256
;//
;//     bp+14   dword   handle
;//     bp+10   string_struct
;//     bp+08   word    max_len
;//     bp+04   dword   bytes to read
;//     bp+00   dword   ret
;//
;//
_read::
        mov     bp,sp
        mov     ah,3fh                  ;// read from file handle
        mov     bx,word ptr  [bp+14]    ;// handle to read from
        mov     cx,word ptr  [bp+04]    ;// number of bytes to read
        lds     dx,dword ptr [bp+10]    ;// buffer to read into
        inc     dx
        inc     dx
        int     21h
        les     bx,dword ptr [bp+10]    ;// put the new string length back
        mov     byte ptr es:[bx], al    ;// into the structure
        xor     dx,dx                   ; Zero register
        retf                            ; Return far

;//     void _close(int handle);
;//
;//
;//     bp+04   dword   handle
;//     bp+00   dword   ret
;//
_close::
        mov     bp,sp
        mov     ah,3eh
        mov     bx,word ptr [bp+04]
        int     21h
        retf                            ; Return far

lowlevel    endp

seg_a           ends

                end     start

