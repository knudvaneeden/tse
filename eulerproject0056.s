// Project Euler - Problem 56: Powerful Digit Sum
// Considering natural numbers of the form a^b, where a, b < 100,
// what is the maximum digital sum?
//
// Strategy: SAL has no big integers, so we represent a^b as a decimal
// string and implement big-integer multiply-by-integer and digit sum.
//
// Version: 1.0

// -----------------------------------------------------------------------
// BigMul: multiply a big-integer string by a small integer (< 100).
// The result is stored back in the same temp buffer.
// Parameters passed via globals: g_bm_num (the number string),
//                                g_bm_factor (the multiplier).
// Returns the result string in g_bm_result.
// -----------------------------------------------------------------------
string g_bm_num[255]    = ""
integer g_bm_factor     = 0
string g_bm_result[255] = ""

proc BigMul()
    integer nLen, idx, digit, carry, prod
    string  s[255]

    nLen  = Length(g_bm_num)
    carry = 0
    s     = ""

    // Multiply from least-significant (rightmost) digit to most-significant
    idx = nLen
    while idx >= 1
        digit = Asc(SubStr(g_bm_num, idx, 1)) - Asc("0")
        prod  = digit * g_bm_factor + carry
        carry = prod / 10
        prod  = prod mod 10
        s     = Chr(prod + Asc("0")) + s
        idx   = idx - 1
    endwhile

    // Prepend any remaining carry digits
    while carry > 0
        prod  = carry mod 10
        carry = carry / 10
        s     = Chr(prod + Asc("0")) + s
    endwhile

    g_bm_result = s
end

// -----------------------------------------------------------------------
// DigitSum: sum all digit characters in a decimal string.
// -----------------------------------------------------------------------
integer proc DigitSum(string numStr)
    integer total, idx, nLen
    total = 0
    nLen  = Length(numStr)
    idx   = 1
    while idx <= nLen
        total = total + Asc(SubStr(numStr, idx, 1)) - Asc("0")
        idx   = idx + 1
    endwhile
    return( total )
end

// -----------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------
proc Main()
    integer a, b, curSum, maxSum
    integer bestA, bestB
    string  power[255]
    string  resultMsg[255]

    maxSum = 0
    bestA  = 0
    bestB  = 0

    // a=1 always gives digit sum 1; start from a=2
    a = 2
    while a <= 99
        // Build a^b iteratively: start with "1", multiply by a, b times
        power = "1"
        b = 1
        while b <= 99
            // power = power * a
            g_bm_num    = power
            g_bm_factor = a
            BigMul()
            power = g_bm_result

            curSum = DigitSum(power)
            if curSum > maxSum
                maxSum = curSum
                bestA  = a
                bestB  = b
            endif
            b = b + 1
        endwhile
        a = a + 1
    endwhile

    resultMsg = Format("Max digit sum = ", maxSum:0,
                       "  (", bestA:0, "^", bestB:0, ")")
    CopyToWinClip(Str(maxSum))
    Warn(resultMsg)
end
