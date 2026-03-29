// eulerproject0229.s
// Project Euler - Problem 229: Four Representations Using Squares
//
// Count numbers n <= 2*10^9 representable in ALL four forms:
//   n = a1^2 +   b1^2
//   n = a2^2 + 2*b2^2
//   n = a3^2 + 3*b3^2
//   n = a7^2 + 7*b7^2
// where a_k, b_k are positive integers.
//
// Version   : 1.1
// Date      : 2025-03-29
// Created by: Claude (Anthropic)
//
// History:
//  1.0 - 2025-03-29 - Initial version by Claude (Anthropic)
//                     Uses Python-via-DOS pattern (eulerproject0154.s style)
//                     for performance on the 2*10^9 sieve.
//  1.1 - 2025-03-29 - Fix: strip Chr(10) newline from result string

integer gPyBufId
integer gResultBufId
string  gPyFile[255]
string  gOutFile[255]

proc Main()
    integer lineIdx
    string  sAnswer[20]
    //
    gPyFile  = "euler229.py"
    gOutFile = "euler229_result.txt"
    //
    // --------------------------------------------------------
    // Build the Python script line by line
    // --------------------------------------------------------
    gPyBufId = CreateTempBuffer()
    GotoBufferId(gPyBufId)
    //
    // Line 1 (first line uses BegLine/KillToEol/InsertText)
    BegFile()
    BegLine()
    KillToEol()
    InsertText("import sys")
    //
    AddLine("import math")
    AddLine("")
    AddLine("LIMIT = 2_000_000_000")
    AddLine("")
    AddLine("# Bit-packed sieve: bytearray of size LIMIT+1 bits.")
    AddLine("# Use 4 bytearrays, one per form.")
    AddLine("# Each bytearray has (LIMIT // 8 + 1) bytes.")
    AddLine("# Bit i is set if number i+1 is representable.")
    AddLine("")
    AddLine("size = LIMIT // 8 + 1")
    AddLine("s1 = bytearray(size)  # a^2 +   b^2")
    AddLine("s2 = bytearray(size)  # a^2 + 2*b^2")
    AddLine("s3 = bytearray(size)  # a^2 + 3*b^2")
    AddLine("s7 = bytearray(size)  # a^2 + 7*b^2")
    AddLine("")
    AddLine("def sieve(arr, m):")
    AddLine("    bmax = int(math.isqrt(LIMIT // m))")
    AddLine("    for b in range(1, bmax + 1):")
    AddLine("        mb2 = m * b * b")
    AddLine("        if mb2 >= LIMIT:")
    AddLine("            break")
    AddLine("        amax = int(math.isqrt(LIMIT - mb2))")
    AddLine("        for a in range(1, amax + 1):")
    AddLine("            n = a * a + mb2")
    AddLine("            idx = n - 1")
    AddLine("            arr[idx >> 3] |= 1 << (idx & 7)")
    AddLine("")
    AddLine("sieve(s1, 1)")
    AddLine("sieve(s2, 2)")
    AddLine("sieve(s3, 3)")
    AddLine("sieve(s7, 7)")
    AddLine("")
    AddLine("# Count positions set in all 4 arrays")
    AddLine("total = 0")
    AddLine("for i in range(size):")
    AddLine("    b = s1[i] & s2[i] & s3[i] & s7[i]")
    AddLine("    if b:")
    AddLine("        total += bin(b).count('1')")
    AddLine("")
    AddLine("# The last chunk may contain bits beyond LIMIT")
    AddLine("# Numbers 1..LIMIT: idx 0..LIMIT-1")
    AddLine("# Last byte index: (LIMIT-1) >> 3")
    AddLine("# Bits in last byte beyond LIMIT-1 should not be counted.")
    AddLine("# Correction: re-examine last byte only.")
    AddLine("last_byte_idx = (LIMIT - 1) >> 3")
    AddLine("last_bit      = (LIMIT - 1) & 7")
    AddLine("# We already counted last byte; subtract any bits above last_bit")
    AddLine("full_last = s1[last_byte_idx] & s2[last_byte_idx] & s3[last_byte_idx] & s7[last_byte_idx]")
    AddLine("counted_last = bin(full_last).count('1')")
    AddLine("mask_valid = (1 << (last_bit + 1)) - 1")
    AddLine("valid_last = bin(full_last & mask_valid).count('1')")
    AddLine("total -= (counted_last - valid_last)")
    AddLine("")
    AddLine("with open('" + gOutFile + "', 'w') as f:")
    AddLine("    f.write(str(total) + '\\n')")
    //
    // --------------------------------------------------------
    // Add indentation where Python needs it
    // --------------------------------------------------------
    // "def sieve" body: lines with "    " already in AddLine strings above.
    // Python indentation is embedded in the string literals. Good.
    //
    // --------------------------------------------------------
    // Save Python script
    // --------------------------------------------------------
    SaveAs(gPyFile, _OVERWRITE_)
    //
    // --------------------------------------------------------
    // Run Python script
    // --------------------------------------------------------
    Message("P229: Running Python sieve (may take 1-3 minutes)...")
    DOS( "g:\language\computer\python\python\python.exe " + gPyFile, _DEFAULT_ | _DEFAULT_ | _DONT_CLEAR_ )
    //
    // --------------------------------------------------------
    // Read result
    // --------------------------------------------------------
    gResultBufId = CreateTempBuffer()
    GotoBufferId(gResultBufId)
    InsertFile(gOutFile)
    BegFile()
    sAnswer = GetText(1, 20)
    sAnswer = Trim(sAnswer)
    sAnswer = StrReplace(Chr(13), sAnswer, "", "g")
    sAnswer = StrReplace(Chr(10), sAnswer, "", "g")
    //
    CopyToWinClip(sAnswer)
    Warn("Project Euler 229" + Chr(13) + "Answer: " + sAnswer)
    CopyToWinClip(sAnswer)
end
