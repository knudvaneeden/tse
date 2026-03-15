// euler020.s
//
// Project Euler - Problem 20: Factorial Digit Sum
// https://projecteuler.net/problem=20
//
// n! means n * (n-1) * ... * 3 * 2 * 1
// For example, 10! = 3628800, digit sum = 3+6+2+8+8+0+0 = 27.
// Find the sum of the digits in the number 100!
//
// Answer: 648
//
// Approach: big-integer stored in a TSE edit buffer.
//   100! has 158 decimal digits -- far beyond any native SAL integer.
//   SAL has no arrays, so we use a scratch buffer as our digit store:
//     - Each line holds exactly one decimal digit (as a 1-char string).
//     - Line 1 = least-significant digit, line N = most-significant.
//   bigMultiply(m) walks lines 1..numDigits, reads each digit,
//   computes digit*m + carry, writes digit mod 10 back, carry /= 10.
//   Leftover carry is appended as new lines at the bottom.
//
// Version: 1.1.0

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
constant TARGET_N    = 100      // compute TARGET_N!

// ---------------------------------------------------------------------------
// Globals
// ---------------------------------------------------------------------------
integer gBufIdG         // id of scratch buffer holding digits
integer gNumDigitsG     // current count of significant digits

// ---------------------------------------------------------------------------
// bufGetDigit  -  return the digit stored on line lineNo (1-based)
// ---------------------------------------------------------------------------
integer proc bufGetDigit(integer lineNo)
    integer prevId
    integer d
    string  s[4]

    prevId = GotoBufferId(gBufIdG)
    GotoLine(lineNo)
    s = GetText(1, 1)
    d = Val(s)
    GotoBufferId(prevId)
    return(d)
end

// ---------------------------------------------------------------------------
// bufSetDigit  -  write digit d to line lineNo (1-based)
// ---------------------------------------------------------------------------
proc bufSetDigit(integer lineNo, integer d)
    integer prevId

    prevId = GotoBufferId(gBufIdG)
    GotoLine(lineNo)
    BegLine()
    KillToEol()
    InsertText(Str(d), _INSERT_)
    GotoBufferId(prevId)
end

// ---------------------------------------------------------------------------
// bufAppendDigit  -  append a new line at end of buffer with digit d
// ---------------------------------------------------------------------------
proc bufAppendDigit(integer d)
    integer prevId

    prevId = GotoBufferId(gBufIdG)
    EndFile()
    AddLine(Str(d))
    gNumDigitsG = gNumDigitsG + 1
    GotoBufferId(prevId)
end

// ---------------------------------------------------------------------------
// bigMultiply  -  multiply the big-number in the buffer by factor m
// ---------------------------------------------------------------------------
proc bigMultiply(integer m)
    integer i
    integer carry
    integer prod
    integer digit

    carry = 0
    i = 1
    while i <= gNumDigitsG
        digit = bufGetDigit(i)
        prod  = digit * m + carry
        bufSetDigit(i, prod mod 10)
        carry = prod / 10
        i = i + 1
    endwhile

    // absorb remaining carry into new high digits
    while carry > 0
        bufAppendDigit(carry mod 10)
        carry = carry / 10
    endwhile
end

// ---------------------------------------------------------------------------
// eulerProblem20  -  main entry point
// ---------------------------------------------------------------------------
proc eulerProblem20()
    integer prevId
    integer factor
    integer i
    integer digitSum
    integer d
    string  resultStr[16]
    string  msg[128]

    // Create scratch buffer (hidden, no file)
    gBufIdG = CreateTempBuffer()

    // Initialise big-number to 1: one line containing "1"
    prevId = GotoBufferId(gBufIdG)
    AddLine("1")
    GotoBufferId(prevId)
    gNumDigitsG = 1

    // Multiply by each factor 2..TARGET_N
    factor = 2
    while factor <= TARGET_N
        bigMultiply(factor)
        factor = factor + 1
    endwhile

    // Sum all digits
    digitSum = 0
    i = 1
    while i <= gNumDigitsG
        d = bufGetDigit(i)
        digitSum = digitSum + d
        i = i + 1
    endwhile

    // Clean up scratch buffer
    AbandonFile(gBufIdG)

    // Build result string and report
    resultStr = Str(digitSum)
    msg = "Project Euler #20: sum of digits in 100! = "
    msg = msg + resultStr
    msg = msg + "  (expected 648)"

    CopyToWinClip(resultStr)
    Warn(msg)
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    eulerProblem20()
end
