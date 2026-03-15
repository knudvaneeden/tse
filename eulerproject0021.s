// euler021.s
// Project Euler - Problem 21: Amicable Numbers
// Let d(n) = sum of proper divisors of n (divisors less than n).
// If d(a) = b and d(b) = a, where a <> b, then a and b are an
// amicable pair. Find the sum of all amicable numbers under 10000.
// Answer: 31626
//
// SAL Notes:
//   - No arrays in SAL; divisor sums computed on the fly
//   - Variable declarations immediately after proc header
//   - Output via Warn() + CopyToWinClip()

// ---------------------------------------------------------------------------
// ProperDivisorSum(n) - returns sum of all proper divisors of n
// ---------------------------------------------------------------------------
integer proc ProperDivisorSum(integer n)
    integer i
    integer s
    integer q

    s = 1                       // 1 is always a proper divisor (for n > 1)
    i = 2
    while i * i <= n
        if n mod i == 0
            q = n / i
            s = s + i
            if q <> i
                s = s + q
            endif
        endif
        i = i + 1
    endwhile
    return(s)
end

// ---------------------------------------------------------------------------
// Main - iterate 2..9999, check amicability, accumulate sum
// ---------------------------------------------------------------------------
proc Main()
    integer n
    integer dn
    integer ddn
    integer total
    string  sResult[20]

    total = 0
    n = 2
    while n < 10000
        dn = ProperDivisorSum(n)
        if dn <> n              // exclude perfect numbers (d(n) == n)
            ddn = ProperDivisorSum(dn)
            if ddn == n
                total = total + n
            endif
        endif
        n = n + 1
    endwhile

    sResult = Str(total)
    CopyToWinClip(sResult)
    Warn("Project Euler #21 - Sum of amicable numbers < 10000: ", sResult,
         " (copied to clipboard)")
end
