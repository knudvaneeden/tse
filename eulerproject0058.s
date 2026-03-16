// Project Euler - Problem 58: Spiral Primes
//
// Starting with 1 and spiralling anticlockwise, a square spiral
// is formed. At side length 7, 8 of the 13 diagonal numbers are
// prime (~62%). Find the side length where the ratio of primes
// on both diagonals first falls below 10%.
//
// Key insight:
//   For a layer of odd side length n (n = 3, 5, 7, ...):
//     bottom-right corner = n*n          (always a perfect square, skip)
//     bottom-left  corner = n*n - (n-1)
//     top-left     corner = n*n - 2*(n-1)
//     top-right    corner = n*n - 3*(n-1)
//   Total diagonal numbers after layer n: 2*n - 1
//   (centre = 1, plus 4 corners per layer)
//
// Primality: trial division up to integer sqrt.
// No floats: test ratio < 10% as: 10 * primes < total
//
// Version: 1.0

// ---------------------------------------------------------------------------
// IsPrime: trial division primality test (no floats, integer sqrt approach)
// Returns 1 if n is prime, 0 otherwise.
// ---------------------------------------------------------------------------
integer proc IsPrime(integer n)
    integer i
    if n < 2
        return(0)
    endif
    if n == 2
        return(1)
    endif
    if (n & 1) == 0      // even > 2
        return(0)
    endif
    if n < 9
        return(1)        // 3, 5, 7 are prime
    endif
    if (n mod 3) == 0
        return(0)
    endif
    // Trial division using 6k +/- 1 pattern up to sqrt(n)
    // We stop when i*i > n (integer check: i*i > n)
    i = 5
    while i * i <= n
        if (n mod i) == 0
            return(0)
        endif
        if (n mod (i + 2)) == 0
            return(0)
        endif
        i = i + 6
    endwhile
    return(1)
end

// ---------------------------------------------------------------------------
// Main: solve PE 58
// ---------------------------------------------------------------------------
proc Main()
    integer sideLen    // current spiral side length (odd: 3, 5, 7, ...)
    integer step       // step between corners = sideLen - 1
    integer corner     // current corner value
    integer primes     // count of prime diagonal numbers found so far
    integer total      // total diagonal numbers (= 2*sideLen - 1)
    integer found      // flag: solution found
    string  ans[255]   // result string for display

    primes  = 0
    total   = 1        // start with centre value 1 (not prime)
    sideLen = 1
    found   = 0

    // Outer loop: expand one layer at a time
    while not found
        sideLen = sideLen + 2
        step    = sideLen - 1
        // bottom-right corner = sideLen * sideLen (perfect square, never prime)
        // Compute the other three corners working backwards from it
        corner = sideLen * sideLen - step      // bottom-left
        if IsPrime(corner)
            primes = primes + 1
        endif
        corner = corner - step                 // top-left
        if IsPrime(corner)
            primes = primes + 1
        endif
        corner = corner - step                 // top-right
        if IsPrime(corner)
            primes = primes + 1
        endif
        total = 2 * sideLen - 1               // total diagonal numbers

        // Test: ratio < 10%  i.e.  10 * primes < total
        if 10 * primes < total
            found = 1
        endif
    endwhile

    ans = "PE 58 - Spiral Primes" + Chr(13) +
          "Side length : " + Str(sideLen) + Chr(13) +
          "Primes      : " + Str(primes)  + Chr(13) +
          "Total diags : " + Str(total)   + Chr(13) +
          "Ratio       : " + Str((100 * primes) / total) + "%"

    CopyToWinClip(Str(sideLen))
    Warn(ans)
end

