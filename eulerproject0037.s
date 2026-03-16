// Project Euler - Problem 37: Truncatable Primes
// =================================================
// The number 3797 has an interesting property. Being prime itself, it is
// possible to continuously remove digits from left to right, and remain
// prime at each stage: 3797, 797, 97, and 7. Similarly from right to left:
// 3797, 379, 37, and 3.
// Find the sum of the only eleven primes that are both truncatable from
// left to right and right to left.
// NOTE: 2, 3, 5, and 7 are not considered truncatable primes.
//
// Answer: 748317
// Version: 1.0.0

// ---- constants ----
constant SIEVE_SIZE    = 1000000   // sieve up to 1,000,000
constant TARGET_COUNT  = 11        // exactly 11 truncatable primes exist

// ---- globals ----
integer gSieveBufId = 0            // buffer id for sieve data

// ------------------------------------------------------------
// IsPrime - check if n is prime using the sieve buffer
// The sieve buffer has one line per number; line n+1 holds "1"=prime "0"=composite
// We encode as text lines: "1" = prime, "0" = composite
// ------------------------------------------------------------
integer proc IsPrime(integer n)
    integer savedId
    string  ch[4]

    if n < 2
        return( FALSE )
    endif

    savedId = GotoBufferId(gSieveBufId)
    GotoLine(n + 1)
    ch = GetText(1, 1)
    GotoBufferId(savedId)

    return( ch == "1" )
end

// ------------------------------------------------------------
// BuildSieve - Sieve of Eratosthenes stored as text lines
// Line number = number+1 (1-based), content "1"=prime "0"=composite
// ------------------------------------------------------------
proc BuildSieve()
    integer i, j, savedId

    Message("Building prime sieve (this may take a moment)...")

    gSieveBufId = CreateTempBuffer()
    savedId     = GotoBufferId(gSieveBufId)

    // Insert SIEVE_SIZE+1 lines, all "1" initially
    BegFile()
    i = 0
    while i <= SIEVE_SIZE
        AddLine("1")
        i = i + 1
    endwhile

    // Mark 0 and 1 as not prime
    GotoLine(1)  // line 1 = number 0
    BegLine()
    InsertText("0", _OVERWRITE_)
    GotoLine(2)  // line 2 = number 1
    BegLine()
    InsertText("0", _OVERWRITE_)

    // Sieve
    i = 2
    while i * i <= SIEVE_SIZE
        GotoLine(i + 1)
        if GetText(1, 1) == "1"
            j = i * i
            while j <= SIEVE_SIZE
                GotoLine(j + 1)
                BegLine()
                InsertText("0", _OVERWRITE_)
                j = j + i
            endwhile
        endif
        i = i + 1
    endwhile

    GotoBufferId(savedId)
end

// ------------------------------------------------------------
// IsTruncatableRight - remove digits from the right, all must be prime
// e.g. 3797 -> 379 -> 37 -> 3
// ------------------------------------------------------------
integer proc IsTruncatableRight(integer n)
    integer t

    t = n / 10
    while t > 0
        if not IsPrime(t)
            return( FALSE )
        endif
        t = t / 10
    endwhile

    return( TRUE )
end

// ------------------------------------------------------------
// IsTruncatableLeft - remove digits from the left, all must be prime
// e.g. 3797 -> 797 -> 97 -> 7
// We find the leading power of 10, then take n mod that power
// ------------------------------------------------------------
integer proc IsTruncatableLeft(integer n)
    integer pow10
    integer t

    // Find largest power of 10 <= n (that still leaves a shorter number)
    pow10 = 10
    while pow10 <= n
        pow10 = pow10 * 10
    endwhile
    // pow10 is now > n; divide by 10 to get the first truncation divisor
    pow10 = pow10 / 10   // e.g. for 3797: pow10=1000, first t = 3797 mod 1000 = 797

    t = n mod pow10
    while t > 0
        if not IsPrime(t)
            return( FALSE )
        endif
        pow10 = pow10 / 10
        t = t mod pow10
    endwhile

    return( TRUE )
end

// ------------------------------------------------------------
// IsTruncatablePrime - must be truncatable both ways
// ------------------------------------------------------------
integer proc IsTruncatablePrime(integer n)
    if n < 10
        return( FALSE )   // single-digit primes excluded per problem statement
    endif
    if not IsPrime(n)
        return( FALSE )
    endif
    return( IsTruncatableRight(n) and IsTruncatableLeft(n) )
end

// ------------------------------------------------------------
// Main
// ------------------------------------------------------------
proc Main()
    integer n
    integer count
    integer total
    string  resultStr[80]
    string  listStr[200]

    BuildSieve()

    count     = 0
    total     = 0
    listStr   = ""
    n         = 10       // start at 10; single-digit primes excluded

    Message("Searching for truncatable primes...")

    while count < TARGET_COUNT
        if IsTruncatablePrime(n)
            count = count + 1
            total = total + n
            if Length(listStr) > 0
                listStr = listStr + ", "
            endif
            listStr = listStr + Str(n)
        endif
        n = n + 1
    endwhile

    // Clean up sieve buffer
    AbandonFile(gSieveBufId)
    gSieveBufId = 0

    resultStr = "Sum of 11 truncatable primes = " + Str(total)

    Warn(resultStr + Chr(13) + "Primes: " + listStr)
    CopyToWinClip(resultStr)
end
