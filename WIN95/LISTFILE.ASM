;****************************************************************************;
;                                                                            ;
;   W95Edit         filelist.asm                                             ;
;                                                                            ;
;   Version         v1.00/08.05.96                                           ;
;   Copyright       (c) 1996 by DiK                                          ;
;                                                                            ;
;   Purpose         build file list of current directory                     ;
;                                                                            ;
;****************************************************************************;

ideal
model   large
codeseg

;****************************************************************************;
;   constants                                                                ;
;****************************************************************************;

MAX_STR_LEN     EQU     254

;****************************************************************************;
;   data structures                                                          ;
;****************************************************************************;

struc   WIN32_FIND_DATA

        FileAttributes          DD      (0)
        CreationTime            DD      2 DUP (0)
        LastAccessTime          DD      2 DUP (0)
        LastWriteTime           DD      2 DUP (0)
        FileSizeHigh            DD      (0)
        FileSizeLow             DD      (0)
        Reserved0               DD      (0)
        Reserved1               DD      (0)
        FileName                DB      260 DUP(0)
        ShortFileName           DB      14 DUP(0)
ends

struc   PICK_BUFF_DATA

        TagCharacter            DB      (0)
        FileAttributes          DB      (0)
        LastWriteTime           DW      (0)
        LastWriteDate           DW      (0)
        FileSizeLow             DW      (0)
        FileSizeHigh            DW      (0)
        FileName                DB      10 DUP(0)
        FileExt                 DB      3 DUP(0)
ends

;****************************************************************************;
;   entry code                                                               ;
;****************************************************************************;

                JMP     NewFindFirst
ORG     3
                JMP     NewFindNext
ORG     6
                JMP     NewFindClose

;****************************************************************************;
;   data definition                                                          ;
;****************************************************************************;

                EVEN
FindHandle      DW                      0
FindData        WIN32_FIND_DATA         <>

;****************************************************************************;
;   DecodeData                                                               ;
;****************************************************************************;

proc    DecodeData NOLANGUAGE NEAR

OFS_DTA         =       10
OFS_FileName    =       6

; point data to code

                MOV     DX,CS
                MOV     DS,DX

; get address of pick buffer record and prepare string

                LES     DI,[BP+OFS_DTA]
                MOV     [WORD ES:DI],SIZE PICK_BUFF_DATA
                ADD     DI,2                    ; set and skip str length
                MOV     BX,DI                   ; save buffer pointer

; copy file attributes

                MOV     AL,[BYTE LOW WORD LOW FindData.FileAttributes]
                MOV     [ES:DI + PICK_BUFF_DATA.FileAttributes],AL

; copy file date and time

                MOV     AX,[WORD LOW FindData.LastWriteTime]
                MOV     [ES:DI + PICK_BUFF_DATA.LastWriteTime],AX
                MOV     AX,[WORD HIGH FindData.LastWriteTime]
                MOV     [ES:DI + PICK_BUFF_DATA.LastWriteDate],AX

; copy file size

                MOV     AX,[WORD LOW FindData.FileSizeLow]
                MOV     [ES:DI + PICK_BUFF_DATA.FileSizeLow],AX
                MOV     AX,[WORD HIGH FindData.FileSizeLow]
                MOV     [ES:DI + PICK_BUFF_DATA.FileSizeHigh],AX

; fill name field with blanks

                ADD     DI,10
                MOV     CX,13
                MOV     AL,' '
                REP STOSB

; set source pointer to alias or long file name

                MOV     SI,OFFSET FindData.ShortFileName
                CMP     [BYTE DS:SI],0
                JNE     @@GotAlias
                MOV     SI,OFFSET FindData.FileName
@@GotAlias:

; copy file name

                MOV     DI,BX                   ; restore buffer pointer
                ADD     DI,10

                MOV     AL,'.'                  ; handle parent entry
                CMP     [BYTE DS:SI],AL
                JNE     @@NameLoop
                STOSB
                STOSB
                JMP     @@CopyLong

@@NameLoop:     LODSB                           ; copy "normal" file names
                CMP     AL,0
                JE      @@CopyLong
                CMP     AL,'.'
                JE      @@CopyExt
                STOSB
                JMP     @@NameLoop

; copy file extension

@@CopyExt:      MOV     DI,BX                   ; restore buffer pointer
                ADD     DI,20

@@ExtLoop:      LODSB                           ; copy file extension
                CMP     AL,0
                JE      @@CopyLong
                STOSB
                JMP     @@ExtLoop

; copy long file name

@@CopyLong:     LES     DI,[BP+OFS_FileName]    ; get addresses of file name
                ADD     DI,2
                MOV     SI,OFFSET FindData.FileName
                XOR     CX,CX                   ; prepare character count

@@LongLoop:     LODSB
                CMP     AL,0
                JE      @@SetStrLen
                STOSB
                INC     CX
                CMP     CL,MAX_STR_LEN
                JB      @@LongLoop

@@SetStrLen:    LES     DI,[BP+OFS_FileName]    ; set length word of name str
                MOV     [ES:DI],CX

                RET
endp

;****************************************************************************;
;   NewFindFirst                                                             ;
;****************************************************************************;

proc    NewFindFirst PASCAL
arg     FindExpr:dword, FileAttr:word, DTA:dword, FileName:dword

                MOV     AX,714Eh                ; FindFirst
                MOV     CH,0                    ; old matching style
                MOV     CL,[BYTE LOW FileAttr]
                LDS     DX,[FindExpr]           ; FindExpr
                MOV     DI,CS                   ; point data to code
                MOV     ES,DI
                MOV     DI,OFFSET FindData      ; FindData
                MOV     SI,1                    ; old dos time format
                INT     21h
                JC      @@Error

                MOV     [FindHandle],AX         ; save handle

@@DecodeIt:     CALL    DecodeData

                MOV     AX,1
                XOR     DX,DX
                RET

@@Error:        XOR     AX,AX
                XOR     DX,DX
                RET
endp

;****************************************************************************;
;   NewFindNext                                                              ;
;****************************************************************************;

proc    NewFindNext PASCAL
arg     DTA:dword, FileName:dword

                MOV     AX,714Fh                ; FindNext
                MOV     BX,[FindHandle]
                MOV     DX,CS                   ; point data to code
                MOV     ES,DX
                MOV     DI,OFFSET FindData      ; FindData
                MOV     SI,1                    ; old dos time format
                INT     21h
                JC      @@Error

                CALL    DecodeData

                MOV     AX,1
                XOR     DX,DX
                RET

@@Error:        XOR     AX,AX
                XOR     DX,DX
                RET
endp

;****************************************************************************;
;   NewFindClose                                                             ;
;****************************************************************************;

proc    NewFindClose PASCAL

                MOV     AX,71A1h                ; FindClose
                MOV     BX,[FindHandle]
                INT     21h

                RET
endp

;****************************************************************************;
;   EndOfModule                                                              ;
;****************************************************************************;

end
