// Project Euler - Problem 64: Odd Period Square Roots
// How many continued fractions for N <= 10000 have an odd period?
//
// Algorithm: For sqrt(N), the continued fraction expansion is:
//   m0=0, d0=1, a0=floor(sqrt(N))
//   m(k+1) = d(k)*a(k) - m(k)
//   d(k+1) = (N - m(k+1)^2) / d(k)
//   a(k+1) = floor((a0 + m(k+1)) / d(k+1))
// The period ends when a(k) == 2*a0
// Perfect squares have period 0 and are skipped automatically.

// Integer square root: returns floor(sqrt(n))
integer proc IntSqrt(integer n)
    integer r
    if n <= 0
        return(0)
    endif
    r = 1
    while r * r <= n
        r = r + 1
    endwhile
    return(r - 1)
end

// Returns the period length of the continued fraction of sqrt(n)
// Returns 0 if n is a perfect square
integer proc CfPeriod(integer n)
    integer a0, m, d, a, period
    a0 = IntSqrt(n)
    if a0 * a0 == n
        return(0)    // perfect square, no period
    endif
    m = 0
    d = 1
    a = a0
    period = 0
    repeat
        m = d * a - m
        d = (n - m * m) / d
        a = (a0 + m) / d
        period = period + 1
    until a == 2 * a0
    return(period)
end

proc Main()
    integer n, count, period
    string result[255]
    count = 0
    for n = 2 to 10000
        period = CfPeriod(n)
        if period & 1    // odd period?
            count = count + 1
        endif
    endfor
    result = Format(count)
    Warn("Project Euler #64: Odd Period Square Roots" + Chr(13) +
         "N <= 10000, count of odd periods:" + Chr(13) +
         result)
    CopyToWinClip(result)
end
