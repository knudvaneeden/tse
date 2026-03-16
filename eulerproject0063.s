// Project Euler - Problem 63: Powerful Digit Counts
// How many n-digit positive integers exist which are also an nth power?
//
// Key insight: only bases 1-9 can qualify, because 10^n always has n+1 digits.
// For each base b in 1..9, count exponents e where Length(b^e) == e.
// Since SAL has no floating point and integers overflow, we use string-based
// big integer multiplication to compute b^e exactly.
//
// Answer: 49

// ---------------------------------------------------------------------------
// BigMul: multiply big-integer string s by small integer m
// Returns result as string (up to 255 chars, safe for this problem: max 21 digits)
// ---------------------------------------------------------------------------
string proc BigMul(string s, integer m)
    integer i, digit, carry, sLen
    string result[255]

    result = ""
    carry  = 0
    sLen   = Length(s)

    // Multiply right-to-left
    i = sLen
    while i >= 1
        digit = Val(SubStr(s, i, 1)) * m + carry
        carry = digit / 10
        digit = digit mod 10
        result = Chr(digit + Asc("0")) + result
        i = i - 1
    endwhile

    // Flush any remaining carry
    while carry > 0
        digit  = carry mod 10
        carry  = carry / 10
        result = Chr(digit + Asc("0")) + result
    endwhile

    return( result )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer b, e, count
    string  power[255]
    string  resultStr[255]

    count = 0

    b = 1
    while b <= 9
        // Start with b^1 = b as a string
        power = Str(b)
        e = 1

        // Keep multiplying by b while Length(power) == e
        while Length(power) == e
            count = count + 1
            // Compute b^(e+1) = power * b
            power = BigMul(power, b)
            e = e + 1
        endwhile

        b = b + 1
    endwhile

    resultStr = Str(count)
    Warn("Project Euler #63 - Powerful Digit Counts" + Chr(13) +
         "Count of n-digit nth powers: " + resultStr)
    CopyToWinClip(resultStr)
end
