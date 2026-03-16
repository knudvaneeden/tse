// Project Euler - Problem 50: Consecutive Prime Sum
// Which prime, below one-million, can be written as the
// sum of the most consecutive primes?
// Answer: 997651  (sum of 543 consecutive primes)

// Strategy:
//   1. Sieve of Eratosthenes using a TSE buffer as a boolean table.
//      CreateTempBuffer() starts with one blank line (line 1 = dummy).
//      We AddLine for n=0,1,2,...  so line (n+2) holds sieve value for n.
//   2. Collect all primes < LIMIT into a second buffer, one per line.
//      Same layout: line 1 = dummy, primes on lines 2..nPrimes+1.
//   3. For every starting index i, walk forward accumulating the sum.
//      Whenever sum < LIMIT and IsPrime(sum) and run-length > bestLen,
//      record bestLen and bestPrime.
//   4. Report result via Warn() and copy to clipboard.

constant LIMIT = 1000000

string g_version[20] = "v1.0.0.4"

// ---------- helpers --------------------------------------------------------

// Sieve buffer layout:
//   Line 1 = unused dummy (blank line CreateTempBuffer always starts with)
//   Line 2 = n=0, Line 3 = n=1, Line 4 = n=2, ...  =>  line (n+2) = n
integer g_sieveBufId = 0

integer proc IsPrime(integer n)
    if n < 2
        return( 0 )
    endif
    GotoBufferId(g_sieveBufId)
    GotoLine(n + 2)
    if GetText(1, 1) == "1"
        return( 1 )
    endif
    return( 0 )
end

// ---------- main -----------------------------------------------------------

proc Main()
    integer primeBufId
    integer curBufId
    integer i, j, nPrimes
    integer s, bestLen, bestPrime
    integer runLen
    integer pi          // current prime value from prime buffer
    integer sieveN      // loop var for sieve build
    integer sieveJ      // loop var for sieve marking
    integer sieveStep
    string  sLine[20]

    // ---------------------------------------------------------------
    // Step 1: Build sieve buffer
    //   line (n+2) = "1" means n is prime.
    // ---------------------------------------------------------------
    Message("Building sieve...")
    g_sieveBufId = CreateTempBuffer()
    GotoBufferId(g_sieveBufId)

    // Line 1 is the dummy blank from CreateTempBuffer().
    // AddLine appends after the current (last) line.
    AddLine("0")    // line 2 = n=0 (not prime)
    AddLine("0")    // line 3 = n=1 (not prime)
    sieveN = 2
    while sieveN < LIMIT
        AddLine("1")
        sieveN = sieveN + 1
    endwhile

    // Mark composites: for prime p, mark p*p, p*p+p, p*p+2p, ...
    sieveN = 2
    while sieveN * sieveN < LIMIT
        GotoLine(sieveN + 2)
        if GetText(1, 1) == "1"
            sieveJ    = sieveN * sieveN
            sieveStep = sieveN
            while sieveJ < LIMIT
                GotoLine(sieveJ + 2)
                BegLine()
                InsertText("0", _OVERWRITE_)
                sieveJ = sieveJ + sieveStep
            endwhile
        endif
        sieveN = sieveN + 1
    endwhile

    // ---------------------------------------------------------------
    // Step 2: Collect primes < LIMIT into primeBufId, one per line.
    //   Same dummy-line-1 layout: primes on lines 2..nPrimes+1.
    // ---------------------------------------------------------------
    Message("Collecting primes...")
    primeBufId = CreateTempBuffer()
    GotoBufferId(g_sieveBufId)
    nPrimes = 0
    sieveN = 2
    while sieveN < LIMIT
        GotoLine(sieveN + 2)
        if GetText(1, 1) == "1"
            GotoBufferId(primeBufId)
            AddLine(Str(sieveN))
            nPrimes = nPrimes + 1
            GotoBufferId(g_sieveBufId)
        endif
        sieveN = sieveN + 1
    endwhile

    // ---------------------------------------------------------------
    // Step 3: Find the longest consecutive-prime sum that is itself
    //   prime and < LIMIT.
    //   Primes are on lines 2..nPrimes+1 of primeBufId.
    // ---------------------------------------------------------------
    Message("Searching for best consecutive prime sum...")
    bestLen   = 0
    bestPrime = 0

    i = 2
    while i <= nPrimes + 1
        GotoBufferId(primeBufId)
        GotoLine(i)
        sLine = GetText(1, CurrLineLen())
        pi = Val(sLine)

        if pi >= LIMIT
            break
        endif

        s      = 0
        runLen = 0
        j      = i
        while j <= nPrimes + 1
            GotoBufferId(primeBufId)
            GotoLine(j)
            sLine = GetText(1, CurrLineLen())
            pi = Val(sLine)
            if s + pi >= LIMIT
                break
            endif
            s      = s + pi
            runLen = runLen + 1
            if IsPrime(s) and runLen > bestLen
                bestLen   = runLen
                bestPrime = s
            endif
            j = j + 1
        endwhile

        i = i + 1
    endwhile

    // ---------------------------------------------------------------
    // Step 4: Report result
    // ---------------------------------------------------------------
    AbandonFile(g_sieveBufId)
    AbandonFile(primeBufId)

    sLine = Str(bestPrime)

    curBufId = CreateTempBuffer()
    GotoBufferId(curBufId)
    AddLine(sLine)
    MarkLine()
    CopyToWinClip()
    AbandonFile(curBufId)

    Warn("Euler 50 " + g_version + ": " + sLine +
         "  (run of " + Str(bestLen) + " primes)  [copied to clipboard]")
end
