;****************************************************************************\
;
;       WinClip
;
;       Binary functions for windows clipboard access.
;
;       þ GetString
;       þ PutString
;       þ PutNullChar
;       þ CheckForWindows
;       þ OpenClipboard
;       þ CloseClipboard
;       þ EmptyClipboard
;       þ GetClipboardDataSize
;       þ GetClipboardData
;       þ SetClipboardData
;
;       Version         v1.00/18.01.95
;
;****************************************************************************/

IDEAL
MODEL   LARGE, PASCAL

;****************************************************************************/
;
;       equates
;
;****************************************************************************/

DataSize        EQU     3000h                   ; size of clipboard buffer
cf_OemText      EQU     7                       ; windows clipboard format
DebugLevel      EQU     0                       ; c.f. macro debug below

;****************************************************************************/
;
;       macros
;
;****************************************************************************/

MACRO Jump Dest
                POS     = $
                JMP     Dest
                ORG     POS + 3
ENDM

MACRO LoadPtr Segment, Register, Start
                PUSH    CS
                POP     Segment
                LEA     Register,[Data]
    IFNB <Start>
                ADD     Register,Start
    ENDIF
ENDM

MACRO DEBUG Level
    IF DebugLevel GE Level
                INT     3
    ENDIF
ENDM

;****************************************************************************/
;
;       entry points
;
;****************************************************************************/

CODESEG

Start:          Jump    GetString
                Jump    PutString
                Jump    PutNullChar
                Jump    CheckForWindows
                Jump    OpenClipboard
                Jump    CloseClipboard
                Jump    EmptyClipboard
                Jump    GetClipboardDataSize
                Jump    GetClipboardData
                Jump    SetClipboardData

;****************************************************************************/
;
;       internal data
;
;****************************************************************************/

EVEN

Data    DB      (DataSize+2) DUP (?)            ; clipboard data buffer

;****************************************************************************/
;
;       integer proc GetString( var integer ofs, var string str )
;
;       returns     cr==0, null==1, error==2
;       ofs         ofs + length of string + 2
;
;       BX          return value
;       DX          old offset value
;
;       The string length added to the offset is the true size
;       of the string as stored in the clipboard and this can be
;       larger than the maximum length of the returned string.
;       The new offset is too large by 1, if the string is
;       terminated by a null character. But since a null means
;       "end of data", this offset is not used.
;
;****************************************************************************/

PROC    GetString
ARG     StrOfs:DWORD, StrPtr:DWORD, StrMax:WORD
DEBUG 1

                MOV     BX,2                    ; assume error
                CLD

                LES     DI,[StrOfs]             ; load offset
                MOV     DX,[ES:DI]

                LoadPtr DS,SI,DX                ; search next cr or null
                MOV     CX,DataSize             ; maximum scan length
                SUB     CX,DX
@@Scan:         LODSB
                CMP     AL,0Dh
                JE      @@FndCr
                AND     AL,AL
                LOOPNZ  @@Scan
                JZ      @@FndNull
                JMP     @@Failed                ; neither cr nor null

@@FndCr:        DEC     BX                      ; return 0, if cr
@@FndNull:      DEC     BX                      ; return 1, if null

                SUB     SI,DX                   ; compute length of string
                SUB     SI,OFFSET Data

                MOV     AX,SI                   ; compute new offset
                INC     AX                      ; account for lf
                ADD     AX,DX
                MOV     [ES:DI],AX              ; save it

                DEC     SI                      ; account for cr or null
                MOV     CX,SI                   ; limit length to maximum
                CMP     CX,[StrMax]
                JBE     @@CopyStr
                MOV     CX,[StrMax]

@@CopyStr:      LoadPtr DS,SI,DX                ; copy string
                LES     DI,[StrPtr]
                MOV     AX,CX                   ; save length of string
                STOSW
                REP MOVSB                       ; copy

@@Failed:       MOV     AX,BX
                XOR     DX,DX
                RET

ENDP

;****************************************************************************/
;
;       integer proc PutString( var integer ofs, string str: strval )
;
;       returns     true on failure
;       ofs         ofs + length of string + 2
;
;       BX          return value
;       DX          old offset value
;
;****************************************************************************/

PROC    PutString
ARG     StrOfs:DWORD, StrPtr:DWORD, StrLen:WORD
DEBUG 1

                CLD

                MOV     CX,[StrLen]             ; load length and offset
                LDS     SI,[StrOfs]
                MOV     DX,[DS:SI]

                MOV     AX,CX                   ; compute new offset
                INC     AX                      ; account for crlf
                INC     AX
                ADD     AX,DX
                MOV     [DS:SI],AX              ; save it

                CMP     AX,DataSize             ; test new offset
                MOV     BX,1
                JAE     @@Failed
                DEC     BX

                LDS     SI,[StrPtr]             ; copy string
                LoadPtr ES,DI,DX
                REP MOVSB
                MOV     AX,0A0Dh                ; append crlf
                STOSW

@@Failed:       MOV     AX,BX
                XOR     DX,DX
                RET

ENDP

;****************************************************************************/
;
;       proc PutNullChar( var integer ofs )
;
;       ofs         ofs + 1
;
;       the null character always fits in (c.f. definition of data block)
;
;****************************************************************************/

PROC    PutNullChar
ARG     StrOfs:DWORD
DEBUG 2

                LDS     SI,[StrOfs]             ; load offset
                MOV     DX,[DS:SI]

                LoadPtr ES,DI,DX                ; store a null character
                MOV     [BYTE ES:DI],0

                INC     DX                      ; increment offset
                MOV     [DS:SI],AX              ; save it

                RET

ENDP

;****************************************************************************/
;
;       integer proc CheckForWindows
;
;       returns     true, if Windows 3.1 is in enhanced mode
;
;       BX          return value
;
;****************************************************************************/


PROC    CheckForWindows
DEBUG 4

                XOR     BX,BX                   ; assume FALSE

                MOV     AX,1600h                ; call multiplexer
                INT     2Fh

                CMP     AL,00h                  ; check non-enhanced mode
                JE      @@False                 ; or version 2 of windows
                CMP     AL,80h
                JE      @@False
                CMP     AL,01h
                JE      @@False
                CMP     AL,0FFh
                JE      @@False

                CMP     AL,03h                  ; check version 3.10
                JA      @@Mode
                CMP     AH,0Ah
                JB      @@False

@@Mode:         MOV     AX,1700h                ; call multiplexer
                INT     2Fh

                CMP     AX,1700h                ; check non-enhanced mode
                JE      @@False

                INC     BX
@@False:        MOV     AX,BX                   ; wrong version or mode
                XOR     DX,DX
                RET

ENDP

;****************************************************************************/
;
;       integer proc OpenClipboard()
;
;       returns     true, if succesful
;
;****************************************************************************/

PROC    OpenClipboard
DEBUG 4

                MOV     AX,1701h                ; call multiplexer
                INT     2Fh
                XOR     DX,DX                   ; AX holds return code
                RET

ENDP

;****************************************************************************/
;
;       integer proc CloseClipboard()
;
;       returns     true, if succesful
;
;****************************************************************************/

PROC    CloseClipboard
DEBUG 4

                MOV     AX,1708h                ; call multiplexer
                INT     2Fh
                XOR     DX,DX                   ; AX holds return code
                RET

ENDP

;****************************************************************************/
;
;       integer proc EmptyClipboard()
;
;       returns     true, if succesful
;
;****************************************************************************/

PROC    EmptyClipboard
DEBUG 4

                MOV     AX,1702h                ; call multiplexer
                INT     2Fh
                XOR     DX,DX                   ; AX holds return code
                RET

ENDP

;****************************************************************************/
;
;       integer proc GetClipboardDataSize()
;
;       returns     length of text in clipboard
;
;****************************************************************************/

PROC    GetClipboardDataSize
DEBUG 4

                MOV     DX,cf_OemText           ; text-format only
                MOV     AX,1704h                ; call multiplexer
                INT     2Fh                     ; DX:AX holds size
                RET

ENDP

;****************************************************************************/
;
;       integer proc GetClipboardData()
;
;       returns     true, if succesful
;
;****************************************************************************/

PROC    GetClipboardData
DEBUG 3

                LoadPtr ES,BX                   ; address of data (ES:BX)
                MOV     DX,cf_OemText           ; text-format only

                MOV     AX,1705h                ; call multiplexer
                INT     2Fh
                XOR     DX,DX
                RET

ENDP

;****************************************************************************/
;
;       integer proc SetClipboardData( integer size: word )
;
;       returns     true, if succesful
;
;****************************************************************************/

PROC    SetClipboardData
ARG     DLen:WORD
DEBUG 3

                LoadPtr ES,BX                   ; address of data (ES:BX)
                MOV     CX,[DLen]               ; size of data (SI:CX)
                XOR     SI,SI
                MOV     DX,cf_OemText           ; text-format only

                MOV     AX,1703h                ; call multiplexer
                INT     2Fh
                XOR     DX,DX
                RET

ENDP

;****************************************************************************/
;
;       end of module
;
;****************************************************************************/

END Start
