// Project Euler - Problem 46: Goldbach's Other Conjecture
//
// It was proposed by Christian Goldbach that every odd composite number
// can be written as the sum of a prime and twice a square.
//   9  = 7  + 2 * 1^2
//   15 = 7  + 2 * 2^2
//   21 = 3  + 2 * 3^2
//   25 = 7  + 2 * 3^2
//   27 = 19 + 2 * 2^2
//   33 = 31 + 2 * 1^2
//
// It turns out the conjecture was false.
// Find the smallest odd composite that CANNOT be written as prime + 2*k^2.
//
// Answer: 5777
//
// Strategy:
//   For each odd n starting at 9:
//     If n is prime, skip it.
//     Otherwise (odd composite): for k = 1, 2, 3, ... while 2*k*k < n,
//       check if (n - 2*k*k) is prime.
//     If no k satisfies the condition, n is our answer.
//
// Note: SAL has INTEGER only (no floats). IsPrime uses i*i <= n loop.
// Version: 1.0

// ---------------------------------------------------------------------------
// IsPrime(n) - returns TRUE if n is prime, FALSE otherwise
// ---------------------------------------------------------------------------
integer proc IsPrime(integer n)
    integer i

    if n < 2
        return( FALSE )
    endif
    if n == 2
        return( TRUE )
    endif
    if (n mod 2) == 0
        return( FALSE )
    endif

    i = 3
    while i * i <= n
        if (n mod i) == 0
            return( FALSE )
        endif
        i = i + 2
    endwhile

    return( TRUE )
end

// ---------------------------------------------------------------------------
// SatisfiesConjecture(n) - returns TRUE if n = prime + 2*k^2 for some k>=1
// ---------------------------------------------------------------------------
integer proc SatisfiesConjecture(integer n)
    integer k
    integer remainder

    k = 1
    while 2 * k * k < n
        remainder = n - 2 * k * k
        if IsPrime(remainder)
            return( TRUE )
        endif
        k = k + 1
    endwhile

    return( FALSE )
end

// ---------------------------------------------------------------------------
// Main procedure
// ---------------------------------------------------------------------------
proc main()
    integer n
    string  result[32]

    // Start at 9 (smallest odd composite)
    n = 9
    loop
        // Only process odd composites
        if (n mod 2) == 1 and not IsPrime(n)
            if not SatisfiesConjecture(n)
                // Found it!
                result = Str(n)
                Warn("Project Euler #46: Goldbach's Other Conjecture" +
                     Chr(13) + Chr(10) +
                     "Smallest odd composite not expressible as" +
                     Chr(13) + Chr(10) +
                     "prime + 2*k^2  ==>  " + result)
                CopyToWinClip(result)
                return()
            endif
        endif
        n = n + 2
    endloop
end
