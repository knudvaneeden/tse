// p035_circular_primes.s
// Project Euler - Problem 35: Circular Primes
//
// A circular prime has all digit-rotations also prime.
// e.g. 197 -> 971 -> 719 are all prime.
// How many circular primes are there below 1,000,000?
//
// Answer: 55
//
// Strategy:
//   - Build Sieve of Eratosthenes up to 1,000,000 in a temp buffer
//     (line n holds "1" if prime, "0" if not)
//   - For each prime p, rotate digits and verify all rotations are prime
//   - Count and display result
//
// SAL notes:
//   - No arrays; sieve stored line-by-line in a temp buffer
//   - String manipulation used for digit rotation
//   - Val() converts string->integer, Str() converts integer->string

// ---------------------------------------------------------------------------
// isPrime: look up line n in sieve buffer
//   Returns 1 if n is prime, 0 otherwise
// ---------------------------------------------------------------------------
integer proc isPrime(integer sieveBufId, integer n)
    integer result
    if n < 2
        return( 0 )
    endif
    GotoBufferId( sieveBufId )
    GotoLine( n + 1 )
    result = Val( GetText(1, 1) )
    return( result )
end

// ---------------------------------------------------------------------------
// getNumDigits: how many decimal digits does n have?
// ---------------------------------------------------------------------------
integer proc getNumDigits(integer n)
    integer digits
    digits = 0
    if n <= 0
        return( 1 )
    endif
    while n > 0
        digits = digits + 1
        n = n / 10
    endwhile
    return( digits )
end

// ---------------------------------------------------------------------------
// rotateRight: rotate digits of n right by one position
//   e.g. 197 -> 719  (last digit becomes first)
//   Uses: last = n mod 10; rest = n / 10; result = last * 10^(d-1) + rest
// ---------------------------------------------------------------------------
integer proc rotateRight(integer n, integer numDigits)
    integer lastDigit
    integer rest
    integer shift
    integer i
    lastDigit = n mod 10
    rest      = n / 10
    shift     = 1
    i         = 1
    while i < numDigits
        shift = shift * 10
        i = i + 1
    endwhile
    return( lastDigit * shift + rest )
end

// ---------------------------------------------------------------------------
// isCircularPrime: check all rotations of n are prime
// ---------------------------------------------------------------------------
integer proc isCircularPrime(integer sieveBufId, integer n)
    integer rotated
    integer numDigits
    integer i
    numDigits = getNumDigits(n)
    rotated   = n
    i         = 0
    while i < numDigits
        if not isPrime(sieveBufId, rotated)
            return( 0 )
        endif
        rotated = rotateRight(rotated, numDigits)
        i = i + 1
    endwhile
    return( 1 )
end

// ---------------------------------------------------------------------------
// Main macro
// ---------------------------------------------------------------------------
proc main()
    integer sieveBufId
    integer n
    integer p
    integer count
    integer limit
    string  resultStr[40]

    limit = 1000000

    // --- Build sieve buffer ---
    // Line n = "1" means n is prime; "0" means composite
    // We need lines 0..limit, so limit+1 lines
    // Line 1 = index 0 (unused), line 2 = index 2, etc.
    // We store line n directly for n=0..limit

    Message( "Building sieve..." )

    sieveBufId = CreateTempBuffer()
    if not sieveBufId
        Warn( "Could not create sieve buffer" )
        return()
    endif

    GotoBufferId( sieveBufId )

    // Add limit+1 lines, initially all "1"
    n = 0
    while n <= limit
        AddLine( "1" )
        n = n + 1
    endwhile

    // Mark 0 and 1 as not prime  (line = n+1)
    GotoLine( 1 )   // line 1 = n=0
    BegLine()
    InsertText( "0", _OVERWRITE_ )

    GotoLine( 2 )   // line 2 = n=1
    BegLine()
    InsertText( "0", _OVERWRITE_ )

    // (line 3 = n=2, which stays "1" = prime — correct)

    // Sieve: for each prime p, mark multiples composite
    p = 2
    while p * p <= limit
        GotoLine( p + 1 )
        if Val( GetText(1,1) ) == 1
            // p is prime; mark p*p, p*p+p, ... as composite
            n = p * p
            while n <= limit
                GotoLine( n + 1 )
                BegLine()
                InsertText( "0", _OVERWRITE_ )
                n = n + p
            endwhile
        endif
        p = p + 1
    endwhile

    Message( "Sieve built. Counting circular primes..." )

    // --- Count circular primes ---
    count = 0
    n = 2
    while n < limit
        if isPrime( sieveBufId, n )
            if isCircularPrime( sieveBufId, n )
                count = count + 1
            endif
        endif
        n = n + 1
    endwhile

    // --- Report ---
    resultStr = Str( count )

    Warn( "Project Euler #35 - Circular Primes below 1,000,000: " + resultStr )
    CopyToWinClip( resultStr )

    // Clean up
    AbandonFile( sieveBufId )
end
