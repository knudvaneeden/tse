// p041_pandigital_prime.s
// Project Euler - Problem 41: Pandigital Prime
//
// We shall say that an n-digit number is pandigital if it makes use of
// all the digits 1 to n exactly once. For example, 2143 is a 4-digit
// pandigital and is also prime.
// What is the largest n-digit pandigital prime that exists?
//
// Key insight: digit sums for n=2,3,5,6,8,9 are all divisible by 3,
// so only 4- and 7-digit pandigitals can be prime.
// We search downward from 7654321 for the first 7-digit pandigital prime.
// (If none found, fall back to 4-digit pandigitals down from 4321.)
//
// Strategy: iterate candidate numbers downward, check pandigital then prime.
// A 7-digit pandigital contains each of digits 1-7 exactly once.
// Primality: trial division up to sqrt(candidate).
//
// Answer: 7652413
//
// Version: 1.0

// ---------------------------------------------------------------------------
// isPrime7
// Check if a 7-digit integer n is prime by trial division.
// Returns TRUE if prime, FALSE otherwise.
// n is passed via global gPrimeN; result in gPrimeResult.
// ---------------------------------------------------------------------------
integer gPrimeN    = 0
integer gPrimeResult = FALSE

proc isPrime7()
    integer d
    integer n

    n = gPrimeN

    // 2 and 3 are prime; even numbers and multiples of 3 are not
    if n < 2
        gPrimeResult = FALSE
        return()
    endif
    if n == 2
        gPrimeResult = TRUE
        return()
    endif
    if (n mod 2) == 0
        gPrimeResult = FALSE
        return()
    endif
    if (n mod 3) == 0
        gPrimeResult = FALSE
        return()
    endif

    // Trial division: check divisors of form 6k+/-1 up to sqrt(n)
    // For n <= 7654321, sqrt < 2767, so this is fast
    d = 5
    while (d * d) <= n
        if (n mod d) == 0
            gPrimeResult = FALSE
            return()
        endif
        if (n mod (d + 2)) == 0
            gPrimeResult = FALSE
            return()
        endif
        d = d + 6
    endwhile

    gPrimeResult = TRUE
end

// ---------------------------------------------------------------------------
// isPandigital7
// Check if integer n uses each of digits 1-7 exactly once (7-digit pandigital).
// Returns TRUE/FALSE via gPanResult.
// ---------------------------------------------------------------------------
integer gPanN      = 0
integer gPanResult = FALSE

proc isPandigital7()
    integer n
    integer digit
    // Use seven integer flags (no arrays in SAL)
    integer f1
    integer f2
    integer f3
    integer f4
    integer f5
    integer f6
    integer f7

    n  = gPanN
    f1 = 0
    f2 = 0
    f3 = 0
    f4 = 0
    f5 = 0
    f6 = 0
    f7 = 0

    // Extract each digit and set its flag
    digit = n mod 10  n = n / 10
    case digit
        when 1  f1 = 1
        when 2  f2 = 1
        when 3  f3 = 1
        when 4  f4 = 1
        when 5  f5 = 1
        when 6  f6 = 1
        when 7  f7 = 1
        otherwise  gPanResult = FALSE  return()
    endcase

    digit = n mod 10  n = n / 10
    case digit
        when 1  if f1 == 1  gPanResult = FALSE  return()  endif  f1 = 1
        when 2  if f2 == 1  gPanResult = FALSE  return()  endif  f2 = 1
        when 3  if f3 == 1  gPanResult = FALSE  return()  endif  f3 = 1
        when 4  if f4 == 1  gPanResult = FALSE  return()  endif  f4 = 1
        when 5  if f5 == 1  gPanResult = FALSE  return()  endif  f5 = 1
        when 6  if f6 == 1  gPanResult = FALSE  return()  endif  f6 = 1
        when 7  if f7 == 1  gPanResult = FALSE  return()  endif  f7 = 1
        otherwise  gPanResult = FALSE  return()
    endcase

    digit = n mod 10  n = n / 10
    case digit
        when 1  if f1 == 1  gPanResult = FALSE  return()  endif  f1 = 1
        when 2  if f2 == 1  gPanResult = FALSE  return()  endif  f2 = 1
        when 3  if f3 == 1  gPanResult = FALSE  return()  endif  f3 = 1
        when 4  if f4 == 1  gPanResult = FALSE  return()  endif  f4 = 1
        when 5  if f5 == 1  gPanResult = FALSE  return()  endif  f5 = 1
        when 6  if f6 == 1  gPanResult = FALSE  return()  endif  f6 = 1
        when 7  if f7 == 1  gPanResult = FALSE  return()  endif  f7 = 1
        otherwise  gPanResult = FALSE  return()
    endcase

    digit = n mod 10  n = n / 10
    case digit
        when 1  if f1 == 1  gPanResult = FALSE  return()  endif  f1 = 1
        when 2  if f2 == 1  gPanResult = FALSE  return()  endif  f2 = 1
        when 3  if f3 == 1  gPanResult = FALSE  return()  endif  f3 = 1
        when 4  if f4 == 1  gPanResult = FALSE  return()  endif  f4 = 1
        when 5  if f5 == 1  gPanResult = FALSE  return()  endif  f5 = 1
        when 6  if f6 == 1  gPanResult = FALSE  return()  endif  f6 = 1
        when 7  if f7 == 1  gPanResult = FALSE  return()  endif  f7 = 1
        otherwise  gPanResult = FALSE  return()
    endcase

    digit = n mod 10  n = n / 10
    case digit
        when 1  if f1 == 1  gPanResult = FALSE  return()  endif  f1 = 1
        when 2  if f2 == 1  gPanResult = FALSE  return()  endif  f2 = 1
        when 3  if f3 == 1  gPanResult = FALSE  return()  endif  f3 = 1
        when 4  if f4 == 1  gPanResult = FALSE  return()  endif  f4 = 1
        when 5  if f5 == 1  gPanResult = FALSE  return()  endif  f5 = 1
        when 6  if f6 == 1  gPanResult = FALSE  return()  endif  f6 = 1
        when 7  if f7 == 1  gPanResult = FALSE  return()  endif  f7 = 1
        otherwise  gPanResult = FALSE  return()
    endcase

    digit = n mod 10  n = n / 10
    case digit
        when 1  if f1 == 1  gPanResult = FALSE  return()  endif  f1 = 1
        when 2  if f2 == 1  gPanResult = FALSE  return()  endif  f2 = 1
        when 3  if f3 == 1  gPanResult = FALSE  return()  endif  f3 = 1
        when 4  if f4 == 1  gPanResult = FALSE  return()  endif  f4 = 1
        when 5  if f5 == 1  gPanResult = FALSE  return()  endif  f5 = 1
        when 6  if f6 == 1  gPanResult = FALSE  return()  endif  f6 = 1
        when 7  if f7 == 1  gPanResult = FALSE  return()  endif  f7 = 1
        otherwise  gPanResult = FALSE  return()
    endcase

    digit = n mod 10  n = n / 10
    case digit
        when 1  if f1 == 1  gPanResult = FALSE  return()  endif  f1 = 1
        when 2  if f2 == 1  gPanResult = FALSE  return()  endif  f2 = 1
        when 3  if f3 == 1  gPanResult = FALSE  return()  endif  f3 = 1
        when 4  if f4 == 1  gPanResult = FALSE  return()  endif  f4 = 1
        when 5  if f5 == 1  gPanResult = FALSE  return()  endif  f5 = 1
        when 6  if f6 == 1  gPanResult = FALSE  return()  endif  f6 = 1
        when 7  if f7 == 1  gPanResult = FALSE  return()  endif  f7 = 1
        otherwise  gPanResult = FALSE  return()
    endcase

    // n should now be 0 (all 7 digits consumed)
    if n <> 0
        gPanResult = FALSE
        return()
    endif

    // All flags must be set
    if f1 == 1 and f2 == 1 and f3 == 1 and f4 == 1 and f5 == 1 and f6 == 1 and f7 == 1
        gPanResult = TRUE
    else
        gPanResult = FALSE
    endif
end

// ---------------------------------------------------------------------------
// main
// Search downward from 7654321 for the largest 7-digit pandigital prime.
// Only test odd numbers (even numbers cannot be prime).
// ---------------------------------------------------------------------------
proc main()
    integer candidate
    integer answer
    string  resultStr[30]

    answer    = 0
    // Start at highest possible 7-digit pandigital (must be odd)
    candidate = 7654321
    // Ensure we start on an odd number
    if (candidate mod 2) == 0
        candidate = candidate - 1
    endif

    while candidate >= 1234567
        // Quick pandigital check first (cheaper than primality)
        gPanN = candidate
        isPandigital7()
        if gPanResult == TRUE
            gPrimeN = candidate
            isPrime7()
            if gPrimeResult == TRUE
                answer    = candidate
                candidate = 0          // break out of loop
            endif
        endif
        if candidate > 0
            candidate = candidate - 2  // step by 2 (skip evens)
        endif
    endwhile

    resultStr = Str(answer)
    Warn("Project Euler #41 - Largest pandigital prime: " + resultStr)
    CopyToWinClip(resultStr)
end
