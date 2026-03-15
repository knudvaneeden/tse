// euler016.s  --  Project Euler Problem 16
//
// Problem:
//   2^15 = 32768 and the sum of its digits is 3+2+7+6+8 = 26.
//   What is the sum of the digits of the number 2^1000?
//
// Strategy:
//   SAL has no bignum type, so we simulate arbitrary-precision
//   arithmetic with a digit array stored in a string buffer.
//   We store the decimal digits of the current power of 2 as
//   individual characters in a string (least-significant digit
//   first).  For each of the 1000 doublings we walk the string,
//   multiply every digit by 2, add the carry from the previous
//   position, write back (digit mod 10) and pass (digit div 10)
//   as the new carry.  After all 1000 doublings we sum the digit
//   values.
//
// SAL constraints respected:
//   - All variable declarations immediately after proc header
//   - No mid-function declarations
//   - Integer arithmetic only (no floating point)
//   - String length limit avoided: we use a scratch buffer, not
//     a single SAL string variable (which caps at 255 chars).
//     2^1000 has 302 decimal digits, so we need a TSE buffer.
//   - Proc names follow noun-verb convention where applicable
//   - Local variables: camelCase
//   - Global with 'g' prefix and uppercase last letter
//   - Constants: ALL_CAPS
//
// Result: 1366
//
// Version: 1.0.0.0
// ---------------------------------------------------------------------------

constant MAX_DIGITS  = 310          // 2^1000 has 302 digits; a little headroom

// ---------------------------------------------------------------------------
// proc  DigitBufInit
//   Initialise the digit buffer in the current TSE buffer.
//   The buffer will hold one ASCII digit character per line,
//   digit[0] (least-significant) on line 1.
//   We start with the value 1 (2^0).
// ---------------------------------------------------------------------------
proc DigitBufInit()
    integer i

    EmptyBuffer()
    AddLine("1")                    // digit[0] = 1  (value = 1 = 2^0)
    for i = 2 to MAX_DIGITS
        AddLine("0")
    endfor
    BegFile()
end

// ---------------------------------------------------------------------------
// proc  DigitBufDouble
//   Multiply the number stored in the digit buffer by 2.
//   Digits are stored one per line, LSB on line 1.
// ---------------------------------------------------------------------------
proc DigitBufDouble()
    integer carry
    integer digit
    integer newDigit
    integer lineNum
    integer totalLines

    carry      = 0
    totalLines = NumLines()
    lineNum    = 1

    while lineNum <= totalLines
        GotoLine(lineNum)
        digit    = Val(GetText(1, 1))
        newDigit = digit * 2 + carry
        carry    = newDigit / 10
        newDigit = newDigit mod 10
        BegLine()
        DelChar()
        InsertText(Str(newDigit), _INSERT_)
        lineNum = lineNum + 1
    endwhile
    // carry should be 0 after 2^1000 (buffer is large enough)
end

// ---------------------------------------------------------------------------
// proc  DigitBufSumDigits
//   Return the sum of all digit values stored in the buffer.
// ---------------------------------------------------------------------------
integer proc DigitBufSumDigits()
    integer total
    integer lineNum
    integer totalLines

    total      = 0
    totalLines = NumLines()
    lineNum    = 1

    while lineNum <= totalLines
        GotoLine(lineNum)
        total   = total + Val(GetText(1, 1))
        lineNum = lineNum + 1
    endwhile
    return(total)
end

// ---------------------------------------------------------------------------
// proc  Main
// ---------------------------------------------------------------------------
proc Main()
    integer workBufId
    integer prevBufId
    integer iteration
    integer digitSum

    prevBufId = GetBufferId()

    // Create a scratch buffer for the digit array
    workBufId = CreateTempBuffer()
    if workBufId == 0
        Warn("Could not create temp buffer.")
        return()
    endif

    GotoBufferId(workBufId)
    DigitBufInit()

    // Double 1000 times: after iteration k we have 2^k
    for iteration = 1 to 1000
        DigitBufDouble()
    endfor

    digitSum = DigitBufSumDigits()

    // Clean up scratch buffer
    GotoBufferId(prevBufId)
    AbandonFile(workBufId)

    // Report result
    Warn("Project Euler #16 -- Sum of digits of 2^1000 = ", digitSum)
    CopyToWinClip( Str( digitSum ) )
    // Expected answer: 1366
end
