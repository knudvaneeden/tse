// Project Euler Problem 301
// LLM: Google Gemini (Pro mode)
// Title: Nim
// Result: 2178309

/*
  Mathematical Reduction:
  We need to find the number of positive integers n <= 2^30 such that
  n ^ 2n ^ 3n = 0.
  This is equivalent to n ^ 2n = 3n.
  Since 3n = n + 2n, we have n ^ 2n = n + 2n.
  This equation holds if and only if there are no carries in the binary addition
  of n and 2n. Because 2n is n shifted left by 1 bit, n and 2n have no overlapping
  1s if and only if the binary representation of n does not contain consecutive 1s.

  The number of binary strings of length k with no consecutive 1s is the Fibonacci
  number F_{k+2} (where F_1 = 1, F_2 = 1, F_3 = 2).
  The integers in [0, 2^30 - 1] correspond to all binary strings of length up to 30.
  The count of such integers with no consecutive 1s is F_{32}.
  The number 2^30 itself has no consecutive 1s (it is a 1 followed by 30 zeros).
  So the total non-negative integers <= 2^30 with no consecutive 1s is F_{32} + 1.
  Since the problem asks for positive integers, we exclude 0, giving exactly F_{32}.
*/

INTEGER PROC FNCalculateEuler301I()
    INTEGER prevI = 1
    INTEGER currI = 1
    INTEGER nextI = 0
    INTEGER I = 0

    // Calculate up to F_32
    FOR I = 3 TO 32
        nextI = prevI + currI
        prevI = currI
        currI = nextI
    ENDFOR

    RETURN(currI)
END

proc Main()
    STRING versionS[10] = "1"
    INTEGER answerI = 0
    STRING answerS[255] = ""

    answerI = FNCalculateEuler301I()
    answerS = Str(answerI)

    CopyToWinClip(answerS)
    Warn(answerS)
    CopyToWinClip(answerS)
end
