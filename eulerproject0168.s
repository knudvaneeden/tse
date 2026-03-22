//
// Filename   : euler168.s
// Version    : 1.0
// Description: Project Euler - Problem 168
//              "Number Rotations"
//              Find the last 5 digits of the sum of all integers n,
//              10 < n < 10^100, such that n divides its right-rotation.
// URL        : https://projecteuler.net/problem=168
// Answer     : 59206
// Author     : Perplexity Computer (LLM: Perplexity / Claude Sonnet 4.6)
// Date       : 2026-03-22
// History    :
//   1.0  2026-03-22  Created by Perplexity Computer (LLM: Perplexity / Claude Sonnet 4.6)
//
// ALGORITHM:
//   A number n = d[k-1] d[k-2] ... d[1] d[0]  (d[0] = last digit, d[k-1] = first digit)
//   has the right-rotation property if:
//      rotate(n) = d[0] d[k-1] ... d[1]  is a multiple of n.
//   Equivalently:  rotate(n) = x * n  for some integer x in {1, 2, ..., 9}.
//
//   Key recurrence (given multiplier x and last digit f = d[0]):
//      d[i+1] = (x * d[i] + carry_i) mod 10
//      carry_{i+1} = (x * d[i] + carry_i) / 10
//   The sequence terminates validly only when x * d[k-1] + carry_{k-1} = f,
//   and d[k-1] <> 0  (no leading zero).
//
//   We only need the last 5 digits of each valid n (mod 100000),
//   accumulated in a running total mod 100000.
//
//   n > 10  =>  at least 2 digits
//   n < 10^100  =>  at most 100 digits  (since 10^100 is a 101-digit number)
//   => numDigits loops from 2 to 100 inclusive.
//
//   All intermediate values stay well within 32-bit integer range:
//     - next = multiplier * current + carry  <=  9*9 + 8 = 89  (fits in int)
//     - result mod 100000  (5-digit number, fits in int)
//     - shiftVar capped at 100000 after reaching that value
//     - totalResult kept mod 100000 every iteration
//
// RULES APPLIED (see explicit check below before Main):
//   - '=' for assignment, '==' for comparison
//   - No '+=' or '!=' ; use 'not ( a == b )' instead of 'a != b'
//   - All variable declarations at top of each proc, before any executable code
//   - No val or pos as variable names
//   - Return() always has parentheses: return()
//   - Only INTEGER and STRING data types (no INT64, no arrays)
//   - Buffer technique not needed here (all arithmetic fits in 32-bit int)
//   - Procedures called by name, no CALL keyword
//   - One Warn() box at the end only
//   - CopyToWinClip() appears once before and once after the Warn() box
//   - Only the bare answer string is copied to clipboard
//   - String variables declared with size: String answerStr[32] = ""
//   - LLM name in history
//   - Version number in header
//   - No intermediate Warn() boxes

// ---------------------------------------------------------------------------
// Global variable: return value from Search()
// (TSE SAL does not have function return values; use a global)
// ---------------------------------------------------------------------------
integer gSearchRes

// ---------------------------------------------------------------------------
// Proc Search
//   Parameters : numDigitsP  - number of digits in the candidate number
//                multiplierP - the multiplier x (1..9)
//                lastDigitP  - the last digit f (1..9)
//   Sets gSearchRes to the last-5-digits value of the valid number,
//   or to 0 if no valid number exists for these parameters.
// ---------------------------------------------------------------------------
Proc Search(integer numDigitsP, integer multiplierP, integer lastDigitP)
    integer shiftVar
    integer carryVar
    integer currentVar
    integer resultVar
    integer nextVar
    integer firstVar
    integer stepsLeft

    shiftVar   = 10
    carryVar   = 0
    currentVar = lastDigitP
    resultVar  = lastDigitP
    stepsLeft  = numDigitsP - 1

    while stepsLeft > 0

        // Compute next digit going from right to left
        nextVar    = multiplierP * currentVar + carryVar
        carryVar   = nextVar / 10
        currentVar = nextVar - (carryVar * 10)   // = nextVar mod 10

        // Accumulate the last 5 digits of the result
        if shiftVar < 100000
            resultVar = resultVar + currentVar * shiftVar
        endif

        // Advance shift, cap at 100000 to stay in 32-bit range
        shiftVar = shiftVar * 10
        if shiftVar > 100000
            shiftVar = 100000
        endif

        stepsLeft = stepsLeft - 1

    endwhile

    // currentVar is now the leftmost digit d[k-1]
    // Validity check 1: no leading zero
    if currentVar == 0
        gSearchRes = 0
        return()
    endif

    // Validity check 2: x * d[k-1] + carry must equal the last digit f
    firstVar = multiplierP * currentVar + carryVar
    if not (firstVar == lastDigitP)
        gSearchRes = 0
        return()
    endif

    gSearchRes = resultVar
    return()
End

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
Proc Main()
    integer modulo
    integer totalResult
    integer numDigits
    integer multiplier
    integer lastDigit
    String  answerStr[32]

    modulo      = 100000
    totalResult = 0

    // Outer loop: number of digits from 2 to 100
    // (n > 10 means >= 2 digits; n < 10^100 means <= 100 digits)
    numDigits = 2
    while numDigits <= 100

        multiplier = 1
        while multiplier <= 9

            lastDigit = 1
            while lastDigit <= 9

                Search(numDigits, multiplier, lastDigit)

                if not (gSearchRes == 0)
                    totalResult = totalResult + gSearchRes
                    // Keep totalResult mod 100000
                    totalResult = totalResult - (totalResult / modulo) * modulo
                endif

                lastDigit = lastDigit + 1
            endwhile

            multiplier = multiplier + 1
        endwhile

        numDigits = numDigits + 1
    endwhile

    // Convert answer to string
    answerStr = Str(totalResult)

    // Copy only the bare answer to clipboard (before Warn so screenshot can be taken)
    CopyToWinClip(answerStr)

    // Show the final answer in one Warn() box
    Warn("Project Euler 168 - Number Rotations"              +
         Chr(13)                                              +
         "Sum of all n, 10 < n < 10^100,"                   +
         Chr(13)                                              +
         "where n divides its right-rotation."               +
         Chr(13)                                              +
         Chr(13)                                             +
         "Last 5 digits of the sum = " + answerStr)

    // Copy only the bare answer again after closing Warn (for easy paste)
    CopyToWinClip(answerStr)

    return()
End

