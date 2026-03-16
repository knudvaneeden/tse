// p030_digit_fifth_powers.s
// Project Euler - Problem 30: Digit Fifth Powers
//
// Find the sum of all the numbers that can be written as the
// sum of fifth powers of their digits.
//
// Upper bound derivation:
//   9^5 = 59049 (max contribution per digit)
//   6 * 9^5 = 354294  (6-digit number all nines)
//   7 * 9^5 = 413343  (only 6 digits, so 7-digit numbers can never qualify)
//   => search range: 2 .. 354294
//
// Version: 1.0.0.0.1

// Pre-computed fifth powers of digits 0..9
integer gPow5_0G = 0        // 0^5 = 0
integer gPow5_1G = 1        // 1^5 = 1
integer gPow5_2G = 32       // 2^5 = 32
integer gPow5_3G = 243      // 3^5 = 243
integer gPow5_4G = 1024     // 4^5 = 1024
integer gPow5_5G = 3125     // 5^5 = 3125
integer gPow5_6G = 7776     // 6^5 = 7776
integer gPow5_7G = 16807    // 7^5 = 16807
integer gPow5_8G = 32768    // 8^5 = 32768
integer gPow5_9G = 59049    // 9^5 = 59049

// ---------------------------------------------------------------------------
// DigitPow5Sum
//   Returns sum of fifth powers of all digits of n.
// ---------------------------------------------------------------------------
integer proc DigitPow5Sum(integer n)
    integer rem
    integer total

    total = 0
    while n > 0
        rem = n mod 10
        n   = n / 10
        case rem
            when 0  total = total + gPow5_0G
            when 1  total = total + gPow5_1G
            when 2  total = total + gPow5_2G
            when 3  total = total + gPow5_3G
            when 4  total = total + gPow5_4G
            when 5  total = total + gPow5_5G
            when 6  total = total + gPow5_6G
            when 7  total = total + gPow5_7G
            when 8  total = total + gPow5_8G
            when 9  total = total + gPow5_9G
        endcase
    endwhile
    return( total )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer n
    integer total
    integer hits
    string  resultStr[80]
    string  hitsStr[200]

    total    = 0
    hits     = 0
    hitsStr  = ""

    // Search 2..354294  (1 is excluded: 1=1^5 is not a "sum")
    n = 2
    while n <= 354294
        if DigitPow5Sum(n) == n
            total = total + n
            hits  = hits + 1
            if Length(hitsStr) > 0
                hitsStr = hitsStr + " + "
            endif
            hitsStr = hitsStr + Str(n)
        endif
        n = n + 1
    endwhile

    resultStr = Str(total)

    Warn("PE30 Digit Fifth Powers" +
         Chr(13) +
         "Numbers found: " + hitsStr +
         Chr(13) +
         "Answer (sum): " + resultStr)

    CopyToWinClip(resultStr)
end
