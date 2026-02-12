; File: CHKPRN.ASM

;----------------------------------------------------------------------;
; Procedure:    CheckPrinterStatus                                     ;
;                                                                      ;
; SAL binary procedure to check the status of a printer port.  Called  ;
; from SAL macro PrinterReady() with the hardware port number as an    ;
; integer parameter.  PrinterReady() procedure is in PRINTER.S.        ;
;                                                                      ;
; Revision history:                                                    ;
;                                                                      ;
;       1.0     8 JUN 93        Original                               ;
;----------------------------------------------------------------------;

READY   EQU     1
ERROR   EQU     0
OK      EQU     90h
PRINTER EQU     bp + 4

_TEXT   SEGMENT
        ASSUME  cs:_TEXT

        ORG     0                       ; .BIN file, IP = 0

CheckPrinterStatus      PROC    FAR
        mov     bp,sp                   ; set up stack frame
        mov     dx,[PRINTER]            ; get printer number in DX

        mov     ah,2                    ; function to get printer status
        int     17h                     ; status returned in AH
        mov     bl,ah                   ; transfer result to BL

        mov     ax,READY                ; assume success
        cmp     bl,OK                   ; if OK, return READY
        je      done
        xor     ax,ax                   ; otherwise, ERROR
done:
        cwd                             ; return result in DX:AX
        ret

        ENDP

_TEXT   ENDS
        END
