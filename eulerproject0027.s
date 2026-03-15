// p027.s  -  Project Euler Problem 27: Quadratic Primes
//
// Find the product of the coefficients a and b for the quadratic
// expression  n^2 + a*n + b  that produces the maximum number of
// primes for consecutive values of n starting with n = 0.
// Constraints: |a| < 1000, |b| <= 1000.
//
// Expected answer: -59231  (a=-61, b=971, 71 consecutive primes)
//
// Algorithm:
//   Pure trial division for primality - no sieve buffer needed.
//   The consecutive runs are short (<=71 steps) so trial division
//   is fast enough.  Optimisation: b must itself be prime (n=0
//   yields b), so we skip non-prime b values immediately.
//
// SAL notes:
//   - No arrays used.
//   - Variables declared immediately after each proc header.
//   - return() requires parentheses.
//   - Warn() + CopyToWinClip() for output per project conventions.
//   - Avoided SAL reserved words: val, str, asc, chr, pos, length,
//     upper, lower, find, min, max.

// ---------------------------------------------------------------------------
// IsPrime(n) -> integer
//   Returns 1 if n is prime, 0 otherwise.
//   Uses trial division.
// ---------------------------------------------------------------------------
integer proc IsPrime(integer n)
    integer divisor

    if n < 2
        return(0)
    endif
    if n == 2
        return(1)
    endif
    if n mod 2 == 0
        return(0)
    endif
    if n == 3
        return(1)
    endif
    divisor = 3
    while divisor * divisor <= n
        if n mod divisor == 0
            return(0)
        endif
        divisor = divisor + 2
    endwhile
    return(1)
end

// ---------------------------------------------------------------------------
// CountConsec(a, b) -> integer
//   Returns how many consecutive n = 0, 1, 2, ...
//   keep  n^2 + a*n + b  prime.
// ---------------------------------------------------------------------------
integer proc CountConsec(integer a, integer b)
    integer n
    integer quadratic

    n = 0
    while TRUE
        quadratic = n * n + a * n + b
        if quadratic < 2
            return(n)
        endif
        if not IsPrime(quadratic)
            return(n)
        endif
        n = n + 1
    endwhile
    return(0)       // unreachable; keeps compiler happy
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer a
    integer b
    integer cnt
    integer bestA
    integer bestB
    integer bestCnt
    string  resultStr[100]

    bestA   = 0
    bestB   = 0
    bestCnt = 0

    a = -999
    while a <= 999
        b = 2           // b must be >= 2 (prime) since formula(0) = b
        while b <= 1000
            if IsPrime(b)
                cnt = CountConsec(a, b)
                if cnt > bestCnt
                    bestCnt = cnt
                    bestA   = a
                    bestB   = b
                endif
            endif
            b = b + 1
        endwhile
        a = a + 1
    endwhile

    resultStr = Format("a=", bestA:5, "  b=", bestB:5,
                       "  run=", bestCnt:3,
                       "  a*b=", bestA * bestB)

    CopyToWinClip(Format(bestA * bestB))
    Warn("P027 Quadratic Primes: ", resultStr)
end
