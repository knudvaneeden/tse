// TSE SAL                                                          // Language: The Semware Editor Professional SAL
//                                                                  // Blank comment line for readability
// LargestPrimeFactor.s                                             // Program name
//                                                                  // Blank comment line for readability
// Calculates the largest prime factor of 600851475143              // Purpose of this program
// while keeping the big number in a decimal string,                // Reason: number does not fit in 32-bit integer
// so it also works in 32-bit TSE SAL.                              // 32-bit-safe approach
//                                                                  // Blank comment line for readability
// Result for 600851475143:                                         // Known expected result
//   6857                                                           // Largest prime factor
                                                                    // Blank line
string numberS        [MAXSTRINGLEN] = "600851475143"               // Current remaining number, stored as decimal text
string quotientS      [MAXSTRINGLEN] = ""                           // Holds quotient after decimal-string division
string largestFactorS [MAXSTRINGLEN] = "1"                          // Holds largest factor found so far as text
                                                                    // Blank line
integer divisorI   = 0                                              // Current trial divisor for division/modulo
integer remainderI = 0                                              // Remainder from dividing numberS by divisorI
                                                                    // Blank line
                                                                    // Blank line
proc NormalizeNumber()                                              // Remove leading zeroes from numberS
    while Length(numberS) > 1 and SubStr(numberS, 1, 1) == "0"      // While number has more than one digit and starts with 0
        numberS = SubStr(numberS, 2, MAXSTRINGLEN)                  // Drop the first character
    endwhile                                                        // End of leading-zero removal loop
end                                                                 // End of NormalizeNumber
                                                                    // Blank line
                                                                    // Blank line
proc DivideNumberByDivisor()                                        // Divide decimal string numberS by integer divisorI
    integer i        = 0                                            // Loop index through digits of numberS
    integer digitI   = 0                                            // Current digit converted to integer
    integer valueI   = 0                                            // Partial dividend = previous remainder*10 + digit
    integer startedI = 0                                            // Flag: has quotient started yet
    string  chS[2]   = ""                                           // Single-character string holding current digit
                                                                    // Blank line
    quotientS  = ""                                                 // Clear previous quotient
    remainderI = 0                                                  // Start division with remainder 0
    startedI   = 0                                                  // No nonzero quotient digit emitted yet
                                                                    // Blank line
    for i = 1 to Length(numberS)                                    // Process each decimal digit from left to right
        chS    = SubStr(numberS, i, 1)                              // Extract digit i as a one-character string
        digitI = Val(chS)                                           // Convert that digit character to integer
        valueI = remainderI * 10 + digitI                           // Form next partial dividend
                                                                    // Blank line
        if startedI or (valueI / divisorI) > 0                      // Append quotient digit once quotient has started or current digit is nonzero
            quotientS = quotientS + Format(valueI / divisorI)       // Append next quotient digit
            startedI  = 1                                           // Remember that quotient has now started
        endif                                                       // End quotient-digit append test
                                                                    // Blank line
        remainderI = valueI mod divisorI                            // Update remainder after this division step
    endfor                                                          // End digit-by-digit long division
                                                                    // Blank line
    if startedI == 0                                                // If quotient never started, the quotient is zero
        quotientS = "0"                                             // Represent zero quotient explicitly
    endif                                                           // End zero-quotient handling
end                                                                 // End of DivideNumberByDivisor
                                                                    // Blank line
                                                                    // Blank line
proc RemoveFactor(integer factorI)                                  // Divide out one factor repeatedly while possible
    integer keepGoingI = 1                                          // Loop-control flag
                                                                    // Blank line
    while keepGoingI                                                // Keep trying to divide by the same factor
        divisorI = factorI                                          // Set global divisor used by DivideNumberByDivisor
        DivideNumberByDivisor()                                     // Compute quotientS and remainderI for numberS / factorI
                                                                    // Blank line
        if remainderI == 0                                          // If divisible exactly by factorI
            numberS        = quotientS                              // Replace numberS by the quotient, removing one factorI
            largestFactorS = Format(factorI)                        // Update largest factor found so far
            NormalizeNumber()                                       // Clean up possible leading zeroes
        else                                                        // Otherwise factorI no longer divides numberS
            keepGoingI = 0                                          // Stop the repeated-division loop
        endif                                                       // End divisibility test
    endwhile                                                        // End repeated factor removal
end                                                                 // End of RemoveFactor
                                                                    // Blank line
                                                                    // Blank line
 PROC Main()                                                        // Program entry point
    integer dI = 0                                                  // Trial divisor variable
                                                                    // Blank line
    RemoveFactor(2)                                                 // First remove factor 2 completely
                                                                    // Blank line
    // For this specific problem:                                   // Explanation of upper bound
    // sqrt(600851475143) is about 775146.                          // Any composite factor pair has one factor <= sqrt(N)
    // So it is sufficient to test odd divisors up to 775146.       // Therefore no need to test beyond this limit
    for dI = 3 to 775146 by 2                                       // Test only odd candidate divisors from 3 upward
        RemoveFactor(dI)                                            // Remove this factor completely if present
    endfor                                                          // End loop over odd divisors
                                                                    // Blank line
    // If anything > 1 remains, then that remainder itself          // Explanation of final primality logic
    // is the largest prime factor.                                 // Remaining unfactored part must be prime here
    if not (numberS == "1")                                         // If some number remains after removing all smaller factors
        largestFactorS = numberS                                    // That remaining number is the largest prime factor
    endif                                                           // End final remainder check
                                                                    // Blank line
    Warn("Largest prime factor of 600851475143 = "; largestFactorS) // Show the final answer to the user
END                                                                 // End of main program
