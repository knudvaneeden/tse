// Project Euler Problem 47
// Find the first four consecutive integers to have four distinct prime
// factors each. What is the first of these numbers?
// Answer: 134043

integer proc CountDistinctPrimeFactors(integer n)
    integer count, i, isqrt
    count = 0
    // Factor out 2
    if (n mod 2) == 0
        count = count + 1
        while (n mod 2) == 0
            n = n / 2
        endwhile
    endif
    // Factor out odd numbers from 3 upward
    i = 3
    // Integer square root: find largest i where i*i <= n
    isqrt = 1
    while (isqrt + 1) * (isqrt + 1) <= n
        isqrt = isqrt + 1
    endwhile
    while i <= isqrt
        if (n mod i) == 0
            count = count + 1
            while (n mod i) == 0
                n = n / i
            endwhile
            // Recompute isqrt after reducing n
            isqrt = 1
            while (isqrt + 1) * (isqrt + 1) <= n
                isqrt = isqrt + 1
            endwhile
        endif
        i = i + 2
    endwhile
    // Remaining factor > 1 is prime
    if n > 1
        count = count + 1
    endif
    return(count)
end

proc Main()
    integer n, run_len, answer
    string  result[64]

    answer  = 0
    run_len = 0
    n       = 2
    while n <= 150000
        if CountDistinctPrimeFactors(n) == 4
            run_len = run_len + 1
            if run_len >= 4
                answer = n - 3
                n      = 150001   // break
            endif
        else
            run_len = 0
        endif
        n = n + 1
    endwhile

    result = "PE47: " + Str(answer)
    CopyToWinClip(result)
    Warn(result)
end
