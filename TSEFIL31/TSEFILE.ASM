;****************************************************************************\
;
;       TseFile.ASM
;
;       Binary functions for file manager
;
;       þ MkDir
;       þ RmDir
;       þ ShowFile
;       þ HideFile
;
;       Version         V3.10/28.04.95
;
;****************************************************************************/

MODEL   LARGE, PASCAL
CODESEG

;****************************************************************************/
;
;       MkDir/RmDir
;
;****************************************************************************/

MkDir:          MOV     AH,39h                  ; dos function: MkDir
                JMP     SHORT xxDir

RmDir:          MOV     AH,3Ah                  ; dos function: RmDir

PROC    xxDir
ARG     Dir:DWORD

                LDS     DX,[Dir]                ; point DS:DX to dir name
                INT     21h                     ; doscall
                MOV     AX,1                    ; assume true
                JNC     @@ok                    ; no error occurred
                DEC     AX                      ; return false
@@ok:           CWD                             ; convert to long
                RET
ENDP

;****************************************************************************/
;
;       ShowFile/HideFile
;
;****************************************************************************/

ShowFile:       MOV     CX,0                    ; clear all attributes
                JMP     SHORT xxFile

HideFile:       MOV     CX,22h                  ; set archive and hidden

PROC    xxFile
ARG     File:DWORD

                MOV     AX,4301h                ; doscall: set file attribute
                LDS     DX,[File]               ; point DS:DX to file name
                INT     21h                     ; doscall
                MOV     AX,1                    ; assume true
                JNC     @@ok                    ; no error occurred
                DEC     AX                      ; return false
@@ok:           CWD                             ; convert to long
                RET

ENDP

;****************************************************************************/
;
;       end of module
;
;****************************************************************************/

END
