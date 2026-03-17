// ===========================================================================
// Euler077.s  -  Project Euler Problem 77 : Prime Summations
//
// Problem:
//   It is possible to write 10 as the sum of primes in exactly 5 ways:
//     7+3, 5+5, 5+3+2, 3+3+2+2, 2+2+2+2+2
//   What is the first value which can be written as the sum of primes
//   in over 5000 different ways?
//
// Algorithm:
//   Classic "coin-change" dynamic programming partition count.
//   Primes play the role of coins.
//   ways[0] = 1  (one way to sum to 0: use nothing)
//   ways[i] = 0  for i > 0  initially
//   For each prime p:
//     For i = p to LIMIT:
//       ways[i] += ways[i-p]
//   Then scan for first ways[n] > 5000  (n >= 2, since n must have a prime sum)
//
// TSE SAL constraints respected:
//   - No integer arrays; all arrays simulated via editor buffers.
//   - Buffer "ways_buf"  : line k holds ways[k-1]  (1-based lines)
//   - Buffer "primes_buf": line k holds prime[k-1]
//   - No reserved keywords used as variable names.
//   - All integers are 32-bit.
//   - String variables stay well under 255 characters.
//   - Each function is self-contained and short.
// ===========================================================================

// ---------------------------------------------------------------------------
// Helper : read integer stored in line linenum of buffer bid
// ---------------------------------------------------------------------------
integer proc BufGetInt(integer bid, integer linenum)
    integer prev_bid
    integer result
    string  txt[20]
    prev_bid = GetBufferId()
    GotoBufferId(bid)
    GotoLine(linenum)
    txt = GetText(1, CurrLineLen())
    result = Val(txt)
    GotoBufferId(prev_bid)
    return (result)
end

// ---------------------------------------------------------------------------
// Helper : write integer num into line linenum of buffer bid
//          The buffer must already have at least linenum lines.
// ---------------------------------------------------------------------------
proc BufSetInt(integer bid, integer linenum, integer num)
    integer prev_bid
    string  txt[20]
    prev_bid = GetBufferId()
    GotoBufferId(bid)
    GotoLine(linenum)
    BegLine()
    KillToEol()
    txt = Str(num)
    InsertText(txt, _INSERT_)
    GotoBufferId(prev_bid)
end

// ---------------------------------------------------------------------------
// Build the primes buffer up to max_val using Sieve of Eratosthenes.
// Returns the buffer id of the primes buffer (caller must close when done).
// Uses a separate sieve buffer: line k = "0" (composite) or "1" (prime).
// ---------------------------------------------------------------------------
integer proc BuildPrimesBuf(integer max_val)
    integer sieve_bid
    integer primes_bid
    integer idx
    integer cur_prime
    integer multiple
    integer flag_prime
    string  txt[20]
    integer prev_bid

    prev_bid  = GetBufferId()

    // --- allocate sieve buffer, fill with "1" (all candidate prime) ---
    sieve_bid = CreateTempBuffer()
    GotoBufferId(sieve_bid)
    // lines 2..max_val represent numbers 2..max_val  (line 1 unused)
    // We store max_val+1 lines so line n directly represents n.
    idx = 0
    while idx <= max_val
        AddLine("1")
        idx = idx + 1
    endwhile
    // mark 0 and 1 as not prime
    GotoLine(1)  BegLine()  KillToEol()  InsertText("0", _INSERT_)
    GotoLine(2)  BegLine()  KillToEol()  InsertText("0", _INSERT_)

    // --- sieve ---
    cur_prime = 2
    while cur_prime * cur_prime <= max_val
        // check if cur_prime is still marked prime
        GotoLine(cur_prime + 1)
        txt = GetText(1, CurrLineLen())
        if Val(txt) == 1
            multiple = cur_prime * cur_prime
            while multiple <= max_val
                GotoLine(multiple + 1)
                BegLine()
                KillToEol()
                InsertText("0", _INSERT_)
                multiple = multiple + cur_prime
            endwhile
        endif
        cur_prime = cur_prime + 1
    endwhile

    // --- collect primes into primes_bid ---
    primes_bid = CreateTempBuffer()
    idx = 2
    while idx <= max_val
        GotoBufferId(sieve_bid)
        GotoLine(idx + 1)
        txt = GetText(1, CurrLineLen())
        flag_prime = Val(txt)
        if flag_prime == 1
            GotoBufferId(primes_bid)
            txt = Str(idx)
            AddLine(txt)
        endif
        idx = idx + 1
    endwhile

    // clean up sieve
    AbandonFile(sieve_bid)

    GotoBufferId(prev_bid)
    return (primes_bid)
end

// ---------------------------------------------------------------------------
// Main macro : Euler problem 77
// ---------------------------------------------------------------------------
proc Main()
    integer LIMIT
    integer TARGET
    integer ways_bid
    integer primes_bid
    integer num_primes
    integer pi
    integer cur_p
    integer ii
    integer ww
    integer answer
    string  msg[80]
    integer prev_bid

    LIMIT   = 1000   // search up to this value
    TARGET  = 5000   // we want first n with ways[n] > TARGET

    prev_bid = GetBufferId()

    // --- build ways buffer: lines 1..LIMIT+1 represent ways[0]..ways[LIMIT] ---
    ways_bid = CreateTempBuffer()
    GotoBufferId(ways_bid)
    ii = 0
    while ii <= LIMIT
        AddLine("0")
        ii = ii + 1
    endwhile
    // ways[0] = 1  (line 1)
    GotoLine(1)
    BegLine()
    KillToEol()
    InsertText("1", _INSERT_)

    // --- build primes buffer ---
    primes_bid = BuildPrimesBuf(LIMIT)

    // count primes
    GotoBufferId(primes_bid)
    num_primes = NumLines()

    // --- DP : for each prime p, update ways[p..LIMIT] ---
    pi = 1
    while pi <= num_primes
        cur_p = BufGetInt(primes_bid, pi)
        ii = cur_p
        while ii <= LIMIT
            ww = BufGetInt(ways_bid, ii - cur_p + 1) + BufGetInt(ways_bid, ii + 1)
            BufSetInt(ways_bid, ii + 1, ww)
            ii = ii + 1
        endwhile
        pi = pi + 1
    endwhile

    // --- find first n >= 2 with ways[n] > TARGET ---
    answer = -1
    ii = 2
    while ii <= LIMIT
        ww = BufGetInt(ways_bid, ii + 1)
        if ww > TARGET
            answer = ii
            ii = LIMIT + 1   // break
        endif
        ii = ii + 1
    endwhile

    // --- clean up temp buffers ---
    AbandonFile(ways_bid)
    AbandonFile(primes_bid)

    GotoBufferId(prev_bid)

    // --- report result ---
    if answer == -1
        Warn("No answer found within LIMIT = ", LIMIT)
    else
        msg = "Euler 077 answer: " + Str(answer)
        CopyToWinClip( Str( answer ) )
        Warn(msg)
    endif
end
