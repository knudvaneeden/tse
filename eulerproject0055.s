// p055_lychrel.s
// Project Euler Problem 55 - Lychrel Numbers
//
// A Lychrel number never produces a palindrome via the reverse-and-add process.
// For this problem: assume Lychrel if no palindrome found in 50 iterations.
// Intermediate numbers can reach 28+ digits, so big-number arithmetic
// is implemented using strings (SAL integers are 32-bit only).
//
// Answer: 249
//
// NOTE: SAL max string length is 255 chars.
//       Numbers below 10000 reach at most ~28 digits in 50 iters - well within limit.

// ---------------------------------------------------------------------------
// ReverseStr: return the reverse of string s
// ---------------------------------------------------------------------------
string proc ReverseStr(string s)
    string rev[255]
    integer i, n
    rev = ""
    n = Length(s)
    i = n
    while i >= 1
        rev = rev + SubStr(s, i, 1)
        i = i - 1
    endwhile
    return( rev )
end

// ---------------------------------------------------------------------------
// IsPalindromeStr: return 1 if string s is a palindrome, else 0
// ---------------------------------------------------------------------------
integer proc IsPalindromeStr(string s)
    return( s == ReverseStr(s) )
end

// ---------------------------------------------------------------------------
// BigAddStr: add two non-negative integers represented as digit strings
// Returns the sum as a digit string.
// ---------------------------------------------------------------------------
string proc BigAddStr(string a, string b)
    string result[255]
    integer la, lb, i, da, db, carry, digitSum
    string ch[2]

    la = Length(a)
    lb = Length(b)
    carry = 0
    result = ""
    i = 0

    // Process digit by digit from the right
    while i < la or i < lb or carry > 0
        da = 0
        db = 0
        if i < la
            da = Asc(SubStr(a, la - i, 1)) - 48
        endif
        if i < lb
            db = Asc(SubStr(b, lb - i, 1)) - 48
        endif
        digitSum = da + db + carry
        carry = digitSum / 10
        digitSum = digitSum mod 10
        ch = Chr(digitSum + 48)
        result = ch + result
        i = i + 1
    endwhile

    if Length(result) == 0
        result = "0"
    endif
    return( result )
end

// ---------------------------------------------------------------------------
// IsLychrel: return 1 if n (given as string) is a Lychrel number
// Uses up to 50 reverse-and-add iterations.
// ---------------------------------------------------------------------------
integer proc IsLychrel(string startStr)
    string cur[255], rev[255]
    integer iter

    cur = startStr
    iter = 0
    while iter < 50
        rev = ReverseStr(cur)
        cur = BigAddStr(cur, rev)
        if IsPalindromeStr(cur)
            return( 0 )
        endif
        iter = iter + 1
    endwhile
    return( 1 )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer n, count
    string result[255]

    count = 0
    n = 1
    while n < 10000
        if IsLychrel(Str(n))
            count = count + 1
        endif
        n = n + 1
    endwhile

    result = "Euler 55: Lychrel numbers below 10000 = " + Str(count)
    Warn(result)
    CopyToWinClip(result)
end
