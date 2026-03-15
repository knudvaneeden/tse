// p028.s  -  Project Euler Problem 28: Number Spiral Diagonals
//
// Starting with the number 1 and moving to the right in a clockwise
// direction a 1001 x 1001 spiral is formed.  What is the sum of the
// numbers on both diagonals?
//
// Approach:
//   For each odd ring size n (3, 5, 7, ... 1001) the four corner values
//   of that ring sum to  4*n*n - 6*n + 6.
//   Adding the central 1 gives the total diagonal sum.
//
// Expected answer: 669171001
//
// Conventions: camelCase locals, g-prefixed globals (uppercase G suffix),
//              noun-verb proc names, ALL_CAPS constants, 4-space indent,
//              Warn() for output, CopyToWinClip() so result can be pasted.

constant SIZE = 1001            // spiral dimension

proc Main()
    integer n                   // current ring size (odd: 3, 5, ..., SIZE)
    integer diagonalSum         // running sum of all diagonal values
    string  resultStr[40]       // formatted result string

    diagonalSum = 1             // centre cell is always 1
    n           = 3

    while n <= SIZE
        // four corners of the n x n ring contribute: 4n^2 - 6n + 6
        diagonalSum = diagonalSum + 4 * n * n - 6 * n + 6
        n = n + 2
    endwhile

    resultStr = "PE28 answer: " + Str(diagonalSum)

    Warn(resultStr)
    CopyToWinClip(resultStr)
end

