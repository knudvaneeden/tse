// Project Euler Problem 131 Solution
// Prime Cube Partnership
// 
// Problem: Find primes p < 1,000,000 such that n^3 + n^2p is a perfect cube
// Solution: p = 3a^2 + 3a + 1, count primes of this form below 1,000,000
//
// Version: 1.5
// Created by: Claude (Anthropic LLM)
// Date: March 2026
//

// Function to calculate integer square root (floor)
INTEGER Proc IntegerSqrt( INTEGER x )
    INTEGER guess = x
    INTEGER prev

    IF x <= 1
        RETURN( x )
    ENDIF

    guess = x / 2
    WHILE TRUE
        prev = guess
        guess = ( prev + ( x / prev ) ) / 2
        IF guess >= prev
            RETURN( prev )
        ENDIF
    ENDWHILE
END

// Function to check if a number is prime
INTEGER Proc IsPrime( INTEGER num )
    INTEGER i
    INTEGER limit

    // Handle small cases
    IF num <= 1
        RETURN( FALSE )
    ENDIF
    IF num <= 3
        RETURN( TRUE )
    ENDIF
    IF ( num MOD 2 ) == 0
        RETURN( FALSE )
    ENDIF

    // Check divisibility up to square root
    limit = IntegerSqrt( num )
    i = 3
    WHILE i <= limit
        IF ( num MOD i ) == 0
            RETURN( FALSE )
        ENDIF
        i = i + 2
    ENDWHILE

    RETURN( TRUE )
END

Proc Main()
    INTEGER maxPrime = 1000000
    INTEGER a = 1
    INTEGER p
    INTEGER count = 0
    STRING sMessage[255] = ""

    // Warn user that calculation is starting
    WARN( "Calculating primes below 1,000,000 of form 3a^2+3a+1..." )

    // Loop through possible a values
    WHILE TRUE
        p = 3 * a * a + 3 * a + 1

        // Exit if p exceeds limit
        IF p >= maxPrime
            BREAK
        ENDIF

        // Check if p is prime
        IF IsPrime( p )
            count = count + 1
        ENDIF

        a = a + 1
    ENDWHILE

    // Format the result message
    sMessage = "Number of primes below 1,000,000 with the property: " + STR( count )

    // Show result in warning box
    WARN( sMessage )

    // Copy only the number to clipboard
    CopyToWinClip( STR( count ) )

    // Also show in status line
    MESSAGE( sMessage )

    RETURN()
END
