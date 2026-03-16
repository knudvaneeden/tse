// Project Euler - Problem 34: Digit Factorials
// Find the sum of all numbers equal to the sum of the factorial of their digits.
// Note: 1! = 1 and 2! = 2 are not included (not sums).
// Answer: 40730  (145 + 40585)
//
// Upper bound: 7 * 9! = 2,540,160  (no 8-digit number can equal digit-factorial sum)
// Pre-computed factorials: 0!=1, 1!=1, 2!=2, 3!=6, 4!=24, 5!=120,
//                          6!=720, 7!=5040, 8!=40320, 9!=362880

proc Main()
    integer n
    integer digit
    integer factSum
    integer totalSum
    string  resultStr[40]

    totalSum = 0

    // Loop from 3 to 2540160 (upper bound = 7 * 9!)
    n = 3
    while n <= 2540160
        // Compute sum of factorials of digits of n
        factSum = 0
        digit   = n
        while digit > 0
            case digit mod 10
                when 0  factSum = factSum + 1
                when 1  factSum = factSum + 1
                when 2  factSum = factSum + 2
                when 3  factSum = factSum + 6
                when 4  factSum = factSum + 24
                when 5  factSum = factSum + 120
                when 6  factSum = factSum + 720
                when 7  factSum = factSum + 5040
                when 8  factSum = factSum + 40320
                when 9  factSum = factSum + 362880
            endcase
            digit = digit / 10
        endwhile
        if factSum == n
            totalSum = totalSum + n
        endif
        n = n + 1
    endwhile

    resultStr = Str(totalSum)
    CopyToWinClip(resultStr)
    Warn("Problem 34 - Sum of digit factorials: " + resultStr + " (copied to clipboard)")
end

