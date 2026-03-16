// =============================================================================
// Euler Project - Problem 69 : Totient Maximum
// =============================================================================
//
// Problem statement:
//  Euler's Totient function, phi(n) [sometimes called the phi function], is
//  used to determine the number of numbers less than n which are relatively
//  prime to n.
//
//  For example, as 1, 2, 4, 5, 7, and 8, are all less than nine and
//  relatively prime to nine, phi(9) = 6.
//
//  n   Relatively Prime      phi(n)  n/phi(n)
//  2   1                     1       2
//  3   1,2                   2       1.5
//  4   1,3                   2       2
//  5   1,2,3,4               4       1.25
//  6   1,5                   2       3
//  7   1,2,3,4,5,6           6       1.1666...
//  8   1,3,5,7               4       2
//  9   1,2,4,5,7,8           6       1.5
//  10  1,3,7,9               4       2.5
//
//  It can be seen that n=6 produces a maximum n/phi(n) for n <= 10.
//  Find the value of n <= 1,000,000 for which n/phi(n) is a maximum.
//
// -----------------------------------------------------------------------------
// Mathematical insight:
//
//  phi(n) = n * PRODUCT( 1 - 1/p )  for each distinct prime p dividing n
//
//  Therefore:
//   n / phi(n) = PRODUCT( p / (p-1) )  for each distinct prime p dividing n
//
//  Since each factor p/(p-1) > 1, to maximise the ratio we want:
//   1. As many distinct prime factors as possible
//   2. The smallest primes (they give the largest p/(p-1) values)
//
//  The answer is the largest PRIMORIAL (product of consecutive primes
//  starting from 2) that does not exceed 1,000,000:
//
//   2 x 3 x 5 x 7 x 11 x 13 x 17         =   510510  <= 1,000,000
//   2 x 3 x 5 x 7 x 11 x 13 x 17 x 19    =  9699690  >  1,000,000
//
//  Answer: 510510
//
// -----------------------------------------------------------------------------
// Approach : Primorial method
//   Multiply consecutive primes (2, 3, 5, 7, ...) until the next
//   multiplication would exceed the limit.  Return the last product.
//   No arrays needed.  Runs instantly.
// =============================================================================

// ---------------------------------------------------------------------------
// IsPrime : trial-division primality test
// ---------------------------------------------------------------------------
integer proc IsPrime( integer n )
    integer i

    if n < 2
        return( FALSE )
    endif
    if n == 2
        return( TRUE )
    endif
    if ( n mod 2 ) == 0
        return( FALSE )
    endif

    i = 3
    while i * i <= n
        if ( n mod i ) == 0
            return( FALSE )
        endif
        i = i + 2
    endwhile

    return( TRUE )
end

// ---------------------------------------------------------------------------
// SolvePrimorial : return the largest primorial <= limit
// ---------------------------------------------------------------------------
integer proc SolvePrimorial( integer limit )
    integer product
    integer candidate

    product   = 1
    candidate = 2

    while candidate <= limit
        if IsPrime( candidate )
            if product * candidate > limit
                return( product )
            endif
            product = product * candidate
        endif
        candidate = candidate + 1
    endwhile

    return( product )
end

// ===========================================================================
// Main
// ===========================================================================
proc Main()
    integer answer
    string  s[ 255 ]

    answer = SolvePrimorial( 1000000 )

    s = "Project Euler - Problem 69 - Totient Maximum"   +
        Chr( 13 ) +
        "Answer : " + Str( answer )

    Warn( s )
end
