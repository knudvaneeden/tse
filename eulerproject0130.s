// Version: 1.0.1
// Created by: Google Gemini
// Problem: Project Euler 130

// Returns the smallest k such that R(k) is divisible by n
integer proc GetRepunitDivisor(integer n)
    integer k = 1
    integer remainder = 1

    // R(k) mod n calculated iteratively to avoid big integer overflow
    // R(k) = (R(k-1) * 10 + 1) MOD n
    while NOT (remainder == 0)
        remainder = (remainder * 10 + 1) MOD n
        k = k + 1
    endwhile

    return(k)
end

// Basic Primality Test
integer proc IsPrime(integer n)
    integer i = 3
    if (n < 2) return(0) endif
    if (n == 2) return(1) endif
    if (n MOD 2 == 0) return(0) endif
    while (i * i <= n)
        if (n MOD i == 0)
            return(0)
        endif
        i = i + 2
    endwhile
    return(1)
end

proc Main()
    integer count = 0
    integer n = 7
    integer sum_n = 0
    integer k
    integer temp_buffer_id

    while (count < 25)
        n = n + 2 // Ensure GCD(n, 10) = 1 by skipping evens

        // GCD(n, 10) == 1 means n must not end in 5
        if (n MOD 5 == 0)
            continue
        endif

        // Euler 130 property: n must be composite
        if (IsPrime(n))
            continue
        endif

        k = GetRepunitDivisor(n)

        // Condition: (n - 1) is divisible by k
        if ((n - 1) MOD k == 0)
            count = count + 1
            sum_n = sum_n + n
        endif
    endwhile

    // Show the final answer in a Warn box
    Warn(Str(sum_n))

    // Copy ONLY the final answer to the Windows Clipboard
    temp_buffer_id = CreateBuffer("ResultTemp")
    InsertText(Str(sum_n))
    MarkLine(1, 1)
    CopyToWinClip()

    // Cleanup: AbandonFile() is the correct SAL function
    AbandonFile()
end
