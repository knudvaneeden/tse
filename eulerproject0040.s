// p040.s  -  Project Euler Problem 40: Champernowne's Constant
//
// An irrational decimal fraction is created by concatenating the positive
// integers:  0.123456789101112131415161718192021...
//
// d_n = nth digit of the fractional part (1-based).
// Find: d1 x d10 x d100 x d1000 x d10000 x d100000 x d1000000
//
// Strategy:
//   Build the Champernowne string in a temp buffer, wrapping every
//   CHUNK (255) characters onto a new line.  This keeps every column
//   reference within 1..255, safely inside GetText()'s column range.
//
//   To find digit at 1-based index idx:
//     lineNum = (idx - 1) / CHUNK + 1        (integer division)
//     colNum  = (idx - 1) mod CHUNK + 1
//     GotoLine(lineNum), then GetText(colNum, 1)
//
//   Verified digit values:
//     d1=1  d10=1  d100=5  d1000=3  d10000=7  d100000=2  d1000000=1
//
// Expected answer: 210
//
// SAL constraints:
//   - No arrays; each position handled individually.
//   - String variables max 255 chars (hence the 255-char line chunks).
//   - GetText(col, len) reads len chars at column col on current line.
//   - 'pos' is a reserved word in SAL -- use 'idx' instead.
//   - Integer division: /    Modulo: mod
//   - Warn() for output; CopyToWinClip() copies the answer.

constant CHUNK = 255        // characters per buffer line

// Helper: return the digit (0-9) at 1-based index idx
//         in the Champernowne buffer bufId.
// NOTE: 'pos' is a SAL reserved word -- parameter named 'idx' instead.
integer proc GetChampDigit(integer bufId, integer idx)
    integer lineNum
    integer colNum
    lineNum = (idx - 1) / CHUNK + 1
    colNum  = (idx - 1) mod CHUNK + 1
    GotoBufferId(bufId)
    GotoLine(lineNum)
    BegLine()
    return( Val(GetText(colNum, 1)) )
end

proc Main()
    integer bufId           // temp buffer: Champernowne string, 255 chars/line
    integer clipBufId       // tiny buffer for CopyToWinClip
    integer n               // current integer being appended
    integer totalLen        // total characters written so far
    integer lineLen         // characters on the current (partial) line
    integer product         // running product of the 7 target digits
    integer d1              // digit at position       1
    integer d10             // digit at position      10
    integer d100            // digit at position     100
    integer d1000           // digit at position    1000
    integer d10000          // digit at position   10000
    integer d100000         // digit at position  100000
    integer d1000000        // digit at position 1000000
    integer remain          // chars left to write from numStr
    integer spaceOnLine     // chars that fit on the current line
    string  numStr[20]      // Str(n) workspace
    string  resultStr[255]  // answer message

    // ----------------------------------------------------------------
    // Phase 1: build the Champernowne string, CHUNK chars per line.
    //   We track lineLen (chars on the current line).  When appending
    //   a number would overflow the current line we split it: write
    //   as many chars as fit, start a new line, write the rest.
    // ----------------------------------------------------------------
    bufId = CreateTempBuffer()
    if bufId == 0
        Warn("ERROR: could not create temp buffer")
        return()
    endif

    GotoBufferId(bufId)
    AddLine("")       // first line
    BegFile()
    BegLine()

    n        = 1
    totalLen = 0
    lineLen  = 0

    while totalLen < 1000000
        numStr = Str(n)
        remain = Length(numStr)

        while remain > 0
            spaceOnLine = CHUNK - lineLen
            if remain <= spaceOnLine
                // whole (remaining) piece fits on current line
                InsertText(numStr, _INSERT_)
                lineLen  = lineLen  + remain
                totalLen = totalLen + remain
                remain   = 0
            else
                // fill current line to exactly CHUNK chars, then wrap
                InsertText(SubStr(numStr, 1, spaceOnLine), _INSERT_)
                totalLen = totalLen + spaceOnLine
                numStr   = SubStr(numStr, spaceOnLine + 1, remain - spaceOnLine)
                remain   = remain - spaceOnLine
                AddLine("")   // new line; cursor moves to it
                BegLine()
                lineLen  = 0
            endif
        endwhile

        n = n + 1
    endwhile

    // ----------------------------------------------------------------
    // Phase 2: extract the 7 target digits via the helper.
    // ----------------------------------------------------------------
    d1       = GetChampDigit(bufId, 1)
    d10      = GetChampDigit(bufId, 10)
    d100     = GetChampDigit(bufId, 100)
    d1000    = GetChampDigit(bufId, 1000)
    d10000   = GetChampDigit(bufId, 10000)
    d100000  = GetChampDigit(bufId, 100000)
    d1000000 = GetChampDigit(bufId, 1000000)

    // ----------------------------------------------------------------
    // Phase 3: compute product and discard the big buffer.
    // ----------------------------------------------------------------
    product = d1 * d10 * d100 * d1000 * d10000 * d100000 * d1000000

    AbandonFile(bufId)

    // ----------------------------------------------------------------
    // Phase 4: copy numeric answer to clipboard.
    // ----------------------------------------------------------------
    clipBufId = CreateTempBuffer()
    GotoBufferId(clipBufId)
    AddLine(Str(product))
    BegFile()
    BegLine()
    MarkLine()
    CopyToWinClip()
    AbandonFile(clipBufId)

    // ----------------------------------------------------------------
    // Phase 5: display result.
    // ----------------------------------------------------------------
    resultStr = "PE #40  Champernowne's Constant"
              + Chr(13)
              + "d1="         + Str(d1)
              + "  d10="      + Str(d10)
              + "  d100="     + Str(d100)
              + "  d1000="    + Str(d1000)
              + Chr(13)
              + "d10000="     + Str(d10000)
              + "  d100000="  + Str(d100000)
              + "  d1000000=" + Str(d1000000)
              + Chr(13)
              + Chr(13)
              + "Answer = "   + Str(product)

    Warn(resultStr)
end
