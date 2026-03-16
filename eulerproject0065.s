// p065.s  -  Project Euler Problem 65: Convergents of e
//
// Find the sum of digits in the numerator of the 100th convergent
// of the continued fraction for e.
//
// e = [2; 1,2,1, 1,4,1, 1,6,1, ..., 1,2k,1, ...]
//
// Coefficient a(i) (1-indexed):
//   a(1) = 2
//   a(i) = 2*(i/3)  if i mod 3 == 0
//   a(i) = 1        otherwise
//
// Numerator recurrence:
//   n(0) = 1,  n(1) = 2
//   n(i) = a(i) * n(i-1) + n(i-2)
//
// Since the numerator reaches ~58 decimal digits at i=100,
// big-number string arithmetic is required.
//
// Result: 272

// ---------------------------------------------------------------------------
// BigNum string add:  returns  a + b  as decimal string
// Both a and b are decimal digit strings (no leading zeros except "0" itself).
// ---------------------------------------------------------------------------
string proc BigAdd(string a, string b)
    integer la, lb, lmax, ia, ib, carry, da, db, s
    string result[255]
    string ch[2]

    la = Length(a)
    lb = Length(b)
    lmax = la
    if lb > lmax
        lmax = lb
    endif

    result = ""
    carry  = 0
    ia = la
    ib = lb

    while ia >= 1 or ib >= 1 or carry
        da = 0
        db = 0
        if ia >= 1
            da = Asc(a[ia]) - 48
            ia = ia - 1
        endif
        if ib >= 1
            db = Asc(b[ib]) - 48
            ib = ib - 1
        endif
        s = da + db + carry
        carry = s / 10
        s = s mod 10
        ch = Chr(s + 48)
        result = ch + result
    endwhile

    if Length(result) == 0
        result = "0"
    endif
    return( result )
end

// ---------------------------------------------------------------------------
// BigNum scalar multiply:  returns  a * m  as decimal string
// a is a decimal digit string; m is a small integer (fits in INTEGER).
// ---------------------------------------------------------------------------
string proc BigMul(string a, integer m)
    integer la, ia, carry, d, p
    string result[255]
    string ch[2]

    if m == 0
        return( "0" )
    endif
    if m == 1
        return( a )
    endif

    la = Length(a)
    result = ""
    carry  = 0
    ia = la

    while ia >= 1 or carry
        d = 0
        if ia >= 1
            d = Asc(a[ia]) - 48
            ia = ia - 1
        endif
        p = d * m + carry
        carry = p / 10
        p = p mod 10
        ch = Chr(p + 48)
        result = ch + result
    endwhile

    if Length(result) == 0
        result = "0"
    endif
    return( result )
end

// ---------------------------------------------------------------------------
// Return the continued-fraction coefficient a(i) for e, 1-indexed.
// ---------------------------------------------------------------------------
integer proc CoeffE(integer i)
    if i == 1
        return( 2 )
    endif
    if i mod 3 == 0
        return( 2 * (i / 3) )
    endif
    return( 1 )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer i, coeff, digitSum, k
    string n_prev[255], n_curr[255], n_next[255]
    string result[255]
    string msg[255]

    // n(0) = 1,  n(1) = 2
    n_prev = "1"
    n_curr = "2"

    // Iterate from i=2 to i=100
    i = 2
    while i <= 100
        coeff  = CoeffE(i)
        // n_next = coeff * n_curr + n_prev
        n_next = BigAdd( BigMul(n_curr, coeff), n_prev )
        n_prev = n_curr
        n_curr = n_next
        i = i + 1
    endwhile

    // n_curr is now the numerator of the 100th convergent
    // Sum its digits
    digitSum = 0
    k = 1
    while k <= Length(n_curr)
        digitSum = digitSum + Asc(n_curr[k]) - 48
        k = k + 1
    endwhile

    result = Str(digitSum)
    msg    = "PE65: Sum of digits in numerator of 100th convergent of e" + Chr(13)
           + "Numerator: " + n_curr + Chr(13)
           + "Digit sum: " + result
    Warn(msg)
    CopyToWinClip(result)
end
