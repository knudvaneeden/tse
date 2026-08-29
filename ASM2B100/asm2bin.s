/*
  TSE Inline Assembler

  SOFTWARE:    asm2bin.s
  VERSION:     1.1.0.0.3
  DATE:        2026-08-29
  ORIGINAL:    Mike Chambers, version 1.00 (1995)
  UPDATED BY:  OpenAI Codex (GPT-5)

  Converts a marked line or character block of 16-bit x86 assembly source
  into hexadecimal values suitable for a SAL inline binary procedure.

  Version 1.1.0.0.0 replaces the obsolete DOS DEBUG.EXE dependency with
  NASM.EXE and NDISASM.EXE.
  Version 1.1.0.0.1 uses the user's explicit G:\CYGWIN\bin tool paths.
  Version 1.1.0.0.2 converts DEBUG-style bare hexadecimal operands to NASM.
  Version 1.1.0.0.3 correctly treats a nonzero Dos() result as success.
*/

string proc FConvertDebugLineToNasm(string debugLineS)
    string characterS[1] = ""
    string convertedLineS[255] = ""
    string tokenS[80] = ""
    integer characterI = 1
    integer operandsStartedB = FALSE
    integer tokenIsHexB = TRUE

    while characterI <= Length(debugLineS)
        characterS = debugLineS[characterI:1]

        if operandsStartedB == FALSE
            convertedLineS = convertedLineS + characterS
            if (characterS == " ") or (characterS == Chr(9))
                operandsStartedB = TRUE
            endif
        elseif characterS == ";"
            if Length(tokenS) > 0
                if tokenIsHexB
                    convertedLineS = convertedLineS + "0x" + tokenS
                else
                    convertedLineS = convertedLineS + tokenS
                endif
                tokenS = ""
            endif
            convertedLineS = convertedLineS +
                             debugLineS[characterI:255]
            return(convertedLineS)
        elseif Pos(characterS,
                   "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_") > 0
            tokenS = tokenS + characterS
            if Pos(characterS, "0123456789abcdefABCDEF") == 0
                tokenIsHexB = FALSE
            endif
        else
            if Length(tokenS) > 0
                if tokenIsHexB
                    convertedLineS = convertedLineS + "0x" + tokenS
                else
                    convertedLineS = convertedLineS + tokenS
                endif
                tokenS = ""
                tokenIsHexB = TRUE
            endif
            convertedLineS = convertedLineS + characterS
        endif

        characterI = characterI + 1
    endwhile

    if Length(tokenS) > 0
        if tokenIsHexB
            convertedLineS = convertedLineS + "0x" + tokenS
        else
            convertedLineS = convertedLineS + tokenS
        endif
    endif

    return(convertedLineS)
end

string proc FFormatDisassemblyLine(string disassemblyS)
    string addressS[16] = ""
    string bytesS[64] = ""
    string instructionS[160] = ""
    string outputS[255] = ""
    integer byteI = 1
    integer instructionStartI = 0

    addressS = GetToken(disassemblyS, " ", 1)
    bytesS = GetToken(disassemblyS, " ", 2)
    instructionStartI = Pos(bytesS, disassemblyS) + Length(bytesS)

    while (instructionStartI <= Length(disassemblyS)) and
          (disassemblyS[instructionStartI:1] == " ")
        instructionStartI = instructionStartI + 1
    endwhile

    if instructionStartI <= Length(disassemblyS)
        instructionS = disassemblyS[instructionStartI:160]
    endif

    while byteI < Length(bytesS)
        outputS = outputS + "  0x" + bytesS[byteI:2]
        byteI = byteI + 2
    endwhile

    if Length(addressS) > 4
        addressS = addressS[Length(addressS) - 3:4]
    endif

    return(Format(outputS:-38:" ", "// :", addressS:-5:" ",
                  Lower(instructionS)))
end

proc FDeleteTemporaryFiles(string sourceFileS,
                           string binaryFileS,
                           string errorFileS,
                           string disassemblyFileS)
    EraseDiskFile(sourceFileS)
    EraseDiskFile(binaryFileS)
    EraseDiskFile(errorFileS)
    EraseDiskFile(disassemblyFileS)
end

proc InlineBinaryBlock()
    string sourceFileS[128] = MakeTempName(".\\")
    string binaryFileS[128] = MakeTempName(".\\")
    string errorFileS[128] = MakeTempName(".\\")
    string disassemblyFileS[128] = MakeTempName(".\\")
    string commandS[255] = ""
    string lineS[255] = ""
    string resultMessageS[255] = ""
    integer sourceBufferI = GetBufferId()
    integer temporaryBufferI = 0
    integer nasmSourceBufferI = 0
    integer disassemblyBufferI = 0
    integer oldUnmarkAfterPasteI = 0
    integer oldEofTypeI = 0
    integer commandResultI = 0
    integer outputLineCountI = 0

    Set(Break, _ON_)

    if IsCursorInBlock() == _COLUMN_
        Warn("Use a line or character block for this operation.")
        return()
    endif

    if IsBlockMarked() == FALSE
        Warn("Block the assembly source to be converted.")
        return()
    endif

    oldUnmarkAfterPasteI = Set(UnMarkAfterPaste, _OFF_)
    oldEofTypeI = Set(EoFType, 2)

    Copy()
    temporaryBufferI = CreateTempBuffer()
    Paste()

    nasmSourceBufferI = CreateBuffer(sourceFileS)
    AddLine("BITS 16", nasmSourceBufferI)
    AddLine("ORG 0x100", nasmSourceBufferI)

    GotoBufferId(temporaryBufferI)
    BegFile()
    repeat
        AddLine(FConvertDebugLineToNasm(GetText(1, CurrLineLen())),
                nasmSourceBufferI)
    until Down() == FALSE

    AbandonFile(temporaryBufferI)
    temporaryBufferI = 0
    GotoBufferId(nasmSourceBufferI)

    if SaveAs(sourceFileS, _OVERWRITE_) == FALSE
        resultMessageS = "Unable to create the temporary NASM source file."
    else
        AbandonFile(nasmSourceBufferI)
        nasmSourceBufferI = 0

        commandS = '"G:\CYGWIN\bin\nasm.exe" -f bin -o "' +
                   binaryFileS + '" "' + sourceFileS + '" 2> "' +
                   errorFileS + '"'
        commandResultI = Dos(commandS, _DONT_PROMPT_ | _DONT_CLEAR_)

        if commandResultI == FALSE
            resultMessageS = "NASM failed. Open " + errorFileS +
                             " to see the assembler diagnostics."
        else
            commandS = '"G:\CYGWIN\bin\ndisasm.exe" -b 16 -o 0x100 "' +
                       binaryFileS + '" > "' + disassemblyFileS +
                       '" 2>> "' + errorFileS + '"'
            commandResultI = Dos(commandS, _DONT_PROMPT_ | _DONT_CLEAR_)

            if commandResultI == FALSE
                resultMessageS = "NDISASM failed. Check G:\CYGWIN\bin\ndisasm.exe."
            else
                disassemblyBufferI = EditFile(disassemblyFileS)
                if disassemblyBufferI == 0
                    resultMessageS = "No disassembly output was produced."
                else
                    BegFile()
                    repeat
                        lineS = GetText(1, CurrLineLen())
                        if Length(GetToken(lineS, " ", 2)) > 0
                            AddLine(FFormatDisassemblyLine(lineS), sourceBufferI)
                            outputLineCountI = outputLineCountI + 1
                        endif
                    until Down() == FALSE
                endif
            endif
        endif
    endif

    if disassemblyBufferI <> 0
        AbandonFile(disassemblyBufferI)
    endif
    if temporaryBufferI <> 0
        AbandonFile(temporaryBufferI)
    endif
    if nasmSourceBufferI <> 0
        AbandonFile(nasmSourceBufferI)
    endif

    GotoBufferId(sourceBufferI)
    Set(EofType, oldEofTypeI)
    Set(UnMarkAfterPaste, oldUnmarkAfterPasteI)

    if resultMessageS == ""
        FDeleteTemporaryFiles(sourceFileS, binaryFileS, errorFileS,
                              disassemblyFileS)
        Warn(Str(outputLineCountI), " assembled instruction(s) inserted.")
    else
        EraseDiskFile(sourceFileS)
        EraseDiskFile(binaryFileS)
        EraseDiskFile(disassemblyFileS)
        Warn(resultMessageS)
    endif
end


<Alt F11> InlineBinaryBlock()

proc Main()
    InlineBinaryBlock()
end
