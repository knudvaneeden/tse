// p036.s  --  Project Euler Problem 36: Double-base Palindromes
//
// Find the sum of all numbers less than 1,000,000 which are
// palindromic in both base 10 and base 2.
//
// Note: a base-2 palindrome cannot have a leading zero, so it must
// be odd.  Only odd numbers need be checked.
//
// Expected answer: 872187

// ---------------------------------------------------------------------------
// IsPalindromeStr
//   Returns TRUE if string s is a palindrome, FALSE otherwise.
// ---------------------------------------------------------------------------
integer proc IsPalindromeStr(string s)
    integer lo
    integer hi
    lo = 1
    hi = Length(s)
    while lo < hi
        if s[lo] <> s[hi]
            return( FALSE )
        endif
        lo = lo + 1
        hi = hi - 1
    endwhile
    return( TRUE )
end IsPalindromeStr

// ---------------------------------------------------------------------------
// IntToBase2Str
//   Converts integer n to its binary (base-2) string representation.
//   n must be >= 1.
// ---------------------------------------------------------------------------
string proc IntToBase2Str(integer n)
    string result[32]
    string tmp[32]
    integer rem
    result = ""
    while n > 0
        rem = n mod 2
        n = n / 2
        if rem == 0
            tmp = "0"
        else
            tmp = "1"
        endif
        result = tmp + result
    endwhile
    return( result )
end IntToBase2Str

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer n
    integer total
    string  dec10[10]
    string  bin2[20]

    total = 0
    n = 1
    while n < 1000000
        dec10 = Str(n)
        if IsPalindromeStr(dec10)
            bin2 = IntToBase2Str(n)
            if IsPalindromeStr(bin2)
                total = total + n
            endif
        endif
        n = n + 2   // only odd numbers can be base-2 palindromes
    endwhile

    Warn("Project Euler #36  --  Double-base Palindromes", Chr(13),
         "Sum of numbers < 1,000,000 palindromic in base 10 and base 2:", Chr(13),
         Str(total))
    CopyToWinClip(Str(total))
end Main
