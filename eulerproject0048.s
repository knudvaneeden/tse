// p048_self_powers.s
//
// Project Euler - Problem 48: Self Powers
//
// The series 1^1 + 2^2 + 3^3 + ... + 1000^1000 — find last 10 digits.
//
// Strategy: work modulo 10^10 = 10,000,000,000.
// TSE SAL integers are 32-bit signed (max ~2,147,483,647).
// 10^10 > 2^32, so we split into high and low 16-bit halves:
//   number = hi * BASE + lo   where BASE = 100000 (10^5)
// so hi and lo are each < 100000, and products fit in 32-bit.
//
// ModMul(a_hi,a_lo, b_hi,b_lo) -> result (hi,lo) via global g_res_hi,g_res_lo
// ModAdd(a_hi,a_lo, b_hi,b_lo) -> same
// ModPow(base, exp)             -> same
//
// Version: 1.0

constant BASE       = 100000       // 10^5
constant MOD_HI     = 100000       // MOD = BASE * MOD_HI  (so MOD = 10^10)
// MOD_HI * BASE = 10^10, which is our modulus

integer g_res_hi = 0
integer g_res_lo = 0

// ---------------------------------------------------------------------------
// ModAdd: (a_hi,a_lo) + (b_hi,b_lo)  mod 10^10  -> g_res_hi, g_res_lo
// ---------------------------------------------------------------------------
proc ModAdd(integer a_hi, integer a_lo, integer b_hi, integer b_lo)
    integer s_lo, s_hi, carry

    s_lo = a_lo + b_lo
    carry = 0
    if s_lo >= BASE
        s_lo = s_lo - BASE
        carry = 1
    endif
    s_hi = a_hi + b_hi + carry
    if s_hi >= MOD_HI
        s_hi = s_hi - MOD_HI
    endif
    g_res_hi = s_hi
    g_res_lo = s_lo
end

// ---------------------------------------------------------------------------
// ModMul: (a_hi,a_lo) * (b_hi,b_lo)  mod 10^10  -> g_res_hi, g_res_lo
//
// Expand: (a_hi*BASE + a_lo) * (b_hi*BASE + b_lo)
//       = a_hi*b_hi*BASE^2 + (a_hi*b_lo + a_lo*b_hi)*BASE + a_lo*b_lo
// mod 10^10 = mod (BASE^2 * (MOD_HI/BASE ... wait, MOD = BASE*MOD_HI = BASE^2)
// Since BASE = 10^5, BASE^2 = 10^10 = MOD.
// So the a_hi*b_hi*BASE^2 term vanishes entirely mod MOD.
// Result = (a_hi*b_lo + a_lo*b_hi)*BASE + a_lo*b_lo   mod BASE^2
//
// Let mid = a_hi*b_lo + a_lo*b_hi   (fits 32-bit: each <= 99999*99999 ~ 10^10... no)
// a_hi <= 99999, b_lo <= 99999 -> product <= 9,999,800,001 > 2^32. Overflow!
//
// So we do multiplication by repeated doubling (binary method) on the
// cross terms to keep everything in range.
// Actually simpler: use ModMulSingle for a*b where both < BASE, giving < BASE^2 < 2^34.
// We split further: a_hi*b_lo mod BASE^2 computed carefully.
//
// Simpler approach: since BASE=10^5, mid = a_hi*b_lo + a_lo*b_hi.
// Each term a_hi*b_lo can be up to 99999*99999 ~ 10^10 which overflows 32-bit.
// Split: a_hi*b_lo = (a_hi * (b_lo / 10)) * 10 + a_hi*(b_lo mod 10)
// Too fiddly. Instead: represent in thirds with BASE2=1000 (10^3).
//
// REVISED: Use BASE = 10000 (10^4), MOD_HI = 1000000 (10^6)
// Then a*b where a,b < 10^4: product < 10^8 < 2^31 — fits!
// And mid terms: a_hi*b_lo < 10^6 * 10^4 = 10^10 — still overflows.
//
// BEST approach: simulate with BASE=31623 (sqrt(2^31)), but messy.
//
// CLEANEST: Use modular exponentiation via repeated squaring,
// where multiplication is done via repeated addition (schoolbook mod).
// For multiplying two numbers < MOD=10^10, use binary method:
// double-and-add in 32-bit using (hi,lo) pairs throughout.
// ---------------------------------------------------------------------------

// Multiply two (hi,lo) numbers mod (BASE*MOD_HI) using binary method.
// Each step: double (hi,lo) with ModAdd, conditionally add (b_hi,b_lo).
proc ModMul(integer a_hi, integer a_lo, integer b_hi, integer b_lo)
    integer r_hi, r_lo
    integer cur_hi, cur_lo
    integer bit

    r_hi = 0
    r_lo = 0
    cur_hi = a_hi
    cur_lo = a_lo

    // We iterate over bits of b (b = b_hi*BASE + b_lo, up to ~10^10 < 2^34)
    // Process low 17 bits from b_lo, then bits from b_hi

    // Process b_lo (up to BASE-1 = 99999, 17 bits)
    bit = b_lo
    while bit > 0
        if (bit & 1) <> 0
            ModAdd(r_hi, r_lo, cur_hi, cur_lo)
            r_hi = g_res_hi
            r_lo = g_res_lo
        endif
        ModAdd(cur_hi, cur_lo, cur_hi, cur_lo)
        cur_hi = g_res_hi
        cur_lo = g_res_lo
        bit = bit shr 1
    endwhile

    // Now cur represents a * BASE (we've shifted b_lo bits worth).
    // We need to also handle b_hi: b = b_hi*BASE + b_lo.
    // The bits above correspond to b_lo already processed.
    // Now multiply cur by remaining factor:
    // But we already shifted cur by (number of bits in b_lo).
    // The b_hi part contributes b_hi * BASE * a to the result.
    // So we need to add b_hi * BASE * a.
    // cur is now a * 2^(bits_in_b_lo). We want a * BASE.
    // Easier: restart cur for the b_hi part.
    cur_hi = a_hi
    cur_lo = a_lo
    // Multiply cur by BASE: cur = a * BASE
    // a * BASE = a_hi * BASE^2 + a_lo * BASE = a_lo*BASE (mod BASE^2)
    // So: new_hi = a_lo, new_lo = 0? No: a*BASE means
    //   (a_hi*BASE + a_lo) * BASE = a_hi*BASE^2 + a_lo*BASE
    //                             = a_lo*BASE   (mod BASE^2)
    // So: cur_hi = a_lo mod MOD_HI (after division), cur_lo = 0.
    // a_lo < BASE = 100000, and MOD_HI = 100000, so a_lo*BASE as (hi,lo):
    //   hi = a_lo, lo = 0  (since a_lo*BASE = a_lo * 100000 and MOD=100000*100000)
    cur_hi = a_lo
    cur_lo = 0

    bit = b_hi
    while bit > 0
        if (bit & 1) <> 0
            ModAdd(r_hi, r_lo, cur_hi, cur_lo)
            r_hi = g_res_hi
            r_lo = g_res_lo
        endif
        ModAdd(cur_hi, cur_lo, cur_hi, cur_lo)
        cur_hi = g_res_hi
        cur_lo = g_res_lo
        bit = bit shr 1
    endwhile

    g_res_hi = r_hi
    g_res_lo = r_lo
end

// ---------------------------------------------------------------------------
// ModPow: base^exp mod 10^10, base is a plain integer 1..1000
// Result -> g_res_hi, g_res_lo
// ---------------------------------------------------------------------------
proc ModPow(integer nBase, integer nExp)
    integer r_hi, r_lo
    integer b_hi, b_lo
    integer e

    r_hi = 0
    r_lo = 1         // result = 1

    // Convert base to (hi, lo)
    b_hi = nBase / BASE
    b_lo = nBase mod BASE

    e = nExp
    while e > 0
        if (e & 1) <> 0
            ModMul(r_hi, r_lo, b_hi, b_lo)
            r_hi = g_res_hi
            r_lo = g_res_lo
        endif
        ModMul(b_hi, b_lo, b_hi, b_lo)
        b_hi = g_res_hi
        b_lo = g_res_lo
        e = e shr 1
    endwhile

    g_res_hi = r_hi
    g_res_lo = r_lo
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer n
    integer sum_hi, sum_lo
    string  result[30]

    sum_hi = 0
    sum_lo = 0

    for n = 1 to 1000
        ModPow(n, n)
        ModAdd(sum_hi, sum_lo, g_res_hi, g_res_lo)
        sum_hi = g_res_hi
        sum_lo = g_res_lo
    endfor

    // Format: pad lo to 5 digits, hi to 5 digits -> 10 digits total
    result = Format(sum_hi:5:"0", sum_lo:5:"0")

    Warn("Euler 48 - Last 10 digits of sum(n^n, n=1..1000):", Chr(13),
         result)
    CopyToWinClip(result)
end
