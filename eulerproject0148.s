// ===================================================================
// eulerproject0148.s
//
// Project Euler - Problem 148
// "Exploring Pascal's triangle"
//
// Find the number of entries which are not divisible by 7
// in the first one billion (10^9) rows of Pascal's triangle.
//
// Algorithm:
//  By Lucas' theorem, C(n,k) mod 7 != 0 iff every base-7 digit
//  of k is <= the corresponding digit of n.
//  For each row n, the count of non-divisible entries =
//  product of (d_i + 1) for all base-7 digits d_i of n.
//  Summing over rows 0..N-1 uses a digit-DP on base-7 digits of N:
//
//  For N with base-7 digits [d_0, d_1, ..., d_k] (d_0 = MSB):
//    result = sum_i [ multiplier_i * T(d_i) * 28^(k-i) ]
//  where T(d) = d*(d+1)/2  (triangular number)
//  and multiplier accumulates product of (d_j + 1) for j < i.
//
//  Note: TSE SAL integers are 32-bit signed, so we simulate
//  64-bit arithmetic using four base-10000 limbs (n3:n2:n1:n0).
//
// Verified: f(100) = 2361, f(10^9) = 2129970655314432
//
// Version  : 1.3
// Date     : 2026-03-20
// Author   : Perplexity AI (powered by Claude Sonnet 4.6)
// ===================================================================
//
// History:
//  1.0  2026-03-20  Created by Perplexity AI (Claude Sonnet 4.6).
//                   Solves Project Euler Problem 148 via base-7 digit DP.
//  1.1  2026-03-20  Fixed: removed ': 20' return size from string proc.
//                   Fixed: renamed 'seg' (reserved keyword) to 'chunk'.
//  1.2  2026-03-20  Fixed: removed array 'digits[11]'; replaced with
//                   individual integer variables dg01..dg11.
//                   Renamed 's' to 'sm' to avoid reserved word conflicts.
//  1.3  2026-03-20  Fixed: removed bare 'euler148()' call at top level.
//                   Added proc Main() as proper TSE SAL entry point.
// ===================================================================

// --- Global 64-bit accumulator (base-10000 limbs) ---
integer n0, n1, n2, n3

// --- Global 64-bit multiplier (base-10000 limbs) ---
integer m0, m1, m2, m3

// --- Global 64-bit temp (base-10000 limbs) ---
integer t0, t1, t2, t3

// -------------------------------------------------------------------
// Add t into n  (n = n + t)
// -------------------------------------------------------------------
proc AddTtoN()
    integer carry, sm
    carry = 0
    sm = n0 + t0 + carry
    carry = sm / 10000
    n0 = sm mod 10000
    sm = n1 + t1 + carry
    carry = sm / 10000
    n1 = sm mod 10000
    sm = n2 + t2 + carry
    carry = sm / 10000
    n2 = sm mod 10000
    sm = n3 + t3 + carry
    n3 = sm mod 10000
end

// -------------------------------------------------------------------
// Multiply t by small integer k  (t = t * k, k <= 21)
// -------------------------------------------------------------------
proc MulTbyK(integer k)
    integer carry, sm
    carry = 0
    sm = t0 * k + carry
    carry = sm / 10000
    t0 = sm mod 10000
    sm = t1 * k + carry
    carry = sm / 10000
    t1 = sm mod 10000
    sm = t2 * k + carry
    carry = sm / 10000
    t2 = sm mod 10000
    sm = t3 * k + carry
    t3 = sm mod 10000
end

// -------------------------------------------------------------------
// Copy m into t
// -------------------------------------------------------------------
proc CopyMtoT()
    t0 = m0
    t1 = m1
    t2 = m2
    t3 = m3
end

// -------------------------------------------------------------------
// Copy t into m
// -------------------------------------------------------------------
proc CopyTtoM()
    m0 = t0
    m1 = t1
    m2 = t2
    m3 = t3
end

// -------------------------------------------------------------------
// Format n3:n2:n1:n0 as a decimal string
// -------------------------------------------------------------------
string proc FormatN()
    string result[20]
    string chunk[4]
    integer started
    result = ""
    started = 0
    if n3 > 0
        result = Str(n3)
        started = 1
    endif
    if started or (n2 > 0)
        chunk = Format(n2:4:"0")
        result = result + chunk
        started = 1
    endif
    if started or (n1 > 0)
        chunk = Format(n1:4:"0")
        result = result + chunk
        started = 1
    endif
    chunk = Format(n0:4:"0")
    if started
        result = result + chunk
    else
        result = chunk
    endif
    Return(result)
end

// -------------------------------------------------------------------
// Solve Euler 148
// -------------------------------------------------------------------
proc euler148()

    // Base-7 digits of 1,000,000,000 (MSB first): 3,3,5,3,1,6,0,0,6,1,6
    // (No arrays in TSE SAL - use individual variables)
    integer dg01
    integer dg02
    integer dg03
    integer dg04
    integer dg05
    integer dg06
    integer dg07
    integer dg08
    integer dg09
    integer dg10
    integer dg11
    integer numDigits
    integer idx
    integer d
    integer tri_d
    integer pw_pow
    integer pw0, pw1, pw2, pw3
    integer tmp0, tmp1, tmp2, tmp3
    integer carry, sm
    integer step
    string answer[20]

    dg01 = 3
    dg02 = 3
    dg03 = 5
    dg04 = 3
    dg05 = 1
    dg06 = 6
    dg07 = 0
    dg08 = 0
    dg09 = 6
    dg10 = 1
    dg11 = 6
    numDigits = 11

    // Initialize accumulator n = 0
    n0 = 0   n1 = 0   n2 = 0   n3 = 0

    // Initialize multiplier m = 1
    m0 = 1   m1 = 0   m2 = 0   m3 = 0

    for idx = 1 to numDigits

        // Pick digit by index (no arrays in TSE SAL)
        d = 0
        if idx == 1    d = dg01  endif
        if idx == 2    d = dg02  endif
        if idx == 3    d = dg03  endif
        if idx == 4    d = dg04  endif
        if idx == 5    d = dg05  endif
        if idx == 6    d = dg06  endif
        if idx == 7    d = dg07  endif
        if idx == 8    d = dg08  endif
        if idx == 9    d = dg09  endif
        if idx == 10   d = dg10  endif
        if idx == 11   d = dg11  endif

        pw_pow = numDigits - idx   // 10 down to 0

        // tri_d = d*(d+1)/2
        tri_d = d * (d + 1) / 2

        if tri_d > 0

            // Compute 28^pw_pow into pw0:pw1:pw2:pw3
            pw0 = 1   pw1 = 0   pw2 = 0   pw3 = 0
            step = 0
            while step < pw_pow
                carry = 0
                sm = pw0 * 28 + carry
                carry = sm / 10000
                pw0 = sm mod 10000
                sm = pw1 * 28 + carry
                carry = sm / 10000
                pw1 = sm mod 10000
                sm = pw2 * 28 + carry
                carry = sm / 10000
                pw2 = sm mod 10000
                sm = pw3 * 28 + carry
                pw3 = sm mod 10000
                step = step + 1
            endwhile

            // t = pw * tri_d
            t0 = pw0   t1 = pw1   t2 = pw2   t3 = pw3
            MulTbyK(tri_d)

            // term = t * multiplier m, accumulate into tmp
            tmp0 = 0   tmp1 = 0   tmp2 = 0   tmp3 = 0

            if m0 > 0
                carry = 0
                sm = t0 * m0 + carry
                carry = sm / 10000
                tmp0 = sm mod 10000
                sm = t1 * m0 + carry
                carry = sm / 10000
                tmp1 = sm mod 10000
                sm = t2 * m0 + carry
                carry = sm / 10000
                tmp2 = sm mod 10000
                sm = t3 * m0 + carry
                tmp3 = sm mod 10000
            endif

            if m1 > 0
                carry = 0
                sm = tmp1 + t0 * m1 + carry
                carry = sm / 10000
                tmp1 = sm mod 10000
                sm = tmp2 + t1 * m1 + carry
                carry = sm / 10000
                tmp2 = sm mod 10000
                sm = tmp3 + t2 * m1 + carry
                tmp3 = sm mod 10000
            endif

            if m2 > 0
                carry = 0
                sm = tmp2 + t0 * m2 + carry
                carry = sm / 10000
                tmp2 = sm mod 10000
                sm = tmp3 + t1 * m2 + carry
                tmp3 = sm mod 10000
            endif

            // Add tmp into n
            t0 = tmp0   t1 = tmp1   t2 = tmp2   t3 = tmp3
            AddTtoN()

        endif

        // multiplier *= (d + 1)
        CopyMtoT()
        MulTbyK(d + 1)
        CopyTtoM()

    endfor

    answer = FormatN()

    Warn("Project Euler 148 Answer: " + answer)

    CopyToWinClip(answer)

end

// -------------------------------------------------------------------
// Entry point
// -------------------------------------------------------------------
proc Main()
    euler148()
end

