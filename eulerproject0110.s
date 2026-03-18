// Project Euler Problem 110 - Diophantine Reciprocals II
// <version>1.0.0.0.6</version>
//
// 1/x + 1/y = 1/n  =>  (x-n)(y-n) = n^2
// Number of distinct solutions = (d(n^2) + 1) / 2
// If n = p1^e1 * p2^e2 * ...  then  d(n^2) = product of (2*ei + 1)
// Need (d(n^2) + 1) / 2 > 4,000,000  =>  d(n^2) >= 8,000,000
//
// The minimum n is a product of the first k primes with non-increasing
// exponents.  We enumerate all such exponent sequences via recursion
// (max depth = 15, well within SAL's recursion limit of 100).
//
// VERSION HISTORY:
//   v1-v3: Explicit buffer-based DFS stack; push/pop/termination bugs.
//   v4:    Recursion with shared gPowBufId; child calls corrupted parent data.
//   v5:    CreateTempBuffer per recursion level; TSE SAL appears to return the
//          same buffer ID for recursive CreateTempBuffer calls, so each child
//          still overwrote the parent's power products -> wrong answer.
//   v6:    Single global scratch buffer gScratchBufId, pre-allocated to 240
//          lines.  Recursion level primeIdx uses lines (primeIdx-1)*16+1
//          through (primeIdx-1)*16+maxExp.  Different levels occupy different
//          non-overlapping regions -> no interference at all.
//
// No arrays; all multi-value data in temp buffers (one value per line).
// No val, pos, left, right, mark, find etc. used as variable names.
// return() always has parentheses.
// Warn() for output; CopyToWinClip() copies only the bare answer.

// ---------------------------------------------------------------------------
// Globals
// ---------------------------------------------------------------------------
integer gPrimeBufId     // first 15 primes, lines 1..15
integer gScratchBufId   // power-product scratch; level L uses lines (L-1)*16+1..(L-1)*16+15
integer gNPrimes        // 15
integer gNeedDiv        // 8000000
string  gBestStr[255]   // best (minimum) n found so far as decimal string

// ---------------------------------------------------------------------------
// BigMulSmall
// Multiply decimal big-integer string bigNum by small positive integer m.
// m <= 47, so d*m+carry <= 9*47+47 = 470: no 32-bit overflow possible.
// ---------------------------------------------------------------------------
string proc BigMulSmall(string bigNum, integer m)
    string  result[255]
    integer i, carry, nLen, d, prod
    result = ""
    carry  = 0
    nLen   = Length(bigNum)
    i      = nLen
    while i >= 1
        d      = Asc(SubStr(bigNum, i, 1)) - 48
        prod   = d * m + carry
        carry  = prod / 10
        result = Str(prod mod 10) + result
        i      = i - 1
    endwhile
    while carry > 0
        result = Str(carry mod 10) + result
        carry  = carry / 10
    endwhile
    if Length(result) == 0
        result = "0"
    endif
    return(result)
end

// ---------------------------------------------------------------------------
// BigCmp
// Compare decimal big-integer strings a and b.
// Returns -1 if a < b,  0 if a == b,  +1 if a > b.
// Shorter string (fewer digits) is always smaller.
// ---------------------------------------------------------------------------
integer proc BigCmp(string a, string b)
    integer la, lb, i, aChar, bChar
    la = Length(a)
    lb = Length(b)
    if la < lb
        return(-1)
    endif
    if la > lb
        return(+1)
    endif
    i = 1
    while i <= la
        aChar = Asc(SubStr(a, i, 1))
        bChar = Asc(SubStr(b, i, 1))
        if aChar < bChar
            return(-1)
        endif
        if aChar > bChar
            return(+1)
        endif
        i = i + 1
    endwhile
    return(0)
end

// ---------------------------------------------------------------------------
// GetPrime: return the k-th prime (1-indexed) from gPrimeBufId.
// ---------------------------------------------------------------------------
integer proc GetPrime(integer k)
    integer nVal
    GotoBufferId(gPrimeBufId)
    GotoLine(k)
    BegLine()
    nVal = Val(GetText(1, CurrLineLen()))
    return(nVal)
end

// ---------------------------------------------------------------------------
// CanReach
// Returns non-zero if curDiv * (2*maxExp+1)^remaining >= gNeedDiv.
// Overflow guard: product wrapping (<= previous) is treated as >= gNeedDiv.
// ---------------------------------------------------------------------------
integer proc CanReach(integer curDiv, integer maxExp, integer remaining)
    integer boundDiv, maxFactor, ri, prev
    boundDiv  = curDiv
    maxFactor = 2 * maxExp + 1
    ri        = remaining
    while ri > 0
        if boundDiv >= gNeedDiv
            return(1)
        endif
        prev     = boundDiv
        boundDiv = boundDiv * maxFactor
        if boundDiv <= prev
            return(1)       // 32-bit overflow; true product >= gNeedDiv
        endif
        ri = ri - 1
    endwhile
    return(boundDiv >= gNeedDiv)
end

// ---------------------------------------------------------------------------
// Search  (recursive DFS)
//
// primeIdx : prime being assigned this call (1..gNPrimes)
// maxExp   : maximum exponent allowed (non-increasing constraint)
// curDiv   : d(n^2) product so far
// nStr     : current partial n as decimal big-integer string
//
// Power products nStr*p^1 .. nStr*p^maxExp are written into gScratchBufId
// at lines (primeIdx-1)*16+1 .. (primeIdx-1)*16+maxExp.
// Each recursion level uses a DIFFERENT region of gScratchBufId (offset by
// primeIdx), so recursive child calls cannot overwrite the parent's values.
// Max lines used: 15*16 = 240, well within TSE's capacity.
// ---------------------------------------------------------------------------
proc Search(integer primeIdx, integer maxExp, integer curDiv, string nStr)
    integer p, k, expE, newDiv, lineBase
    string  newN[255], cur[255]

    // Prune entire subtree if target is unreachable
    if not CanReach(curDiv, maxExp, gNPrimes - primeIdx + 1)
        return()
    endif

    p        = GetPrime(primeIdx)
    lineBase = (primeIdx - 1) * 16    // lines lineBase+1 .. lineBase+maxExp are ours

    // Build power products upward: line lineBase+k = nStr * p^k
    GotoBufferId(gScratchBufId)
    cur = nStr
    k   = 1
    while k <= maxExp
        cur = BigMulSmall(cur, p)
        GotoLine(lineBase + k)
        BegLine()
        KillToEol()
        InsertText(cur)
        k = k + 1
    endwhile

    // Iterate exponents from maxExp DOWN to 1
    expE = maxExp
    while expE >= 1

        GotoBufferId(gScratchBufId)
        GotoLine(lineBase + expE)
        BegLine()
        newN = GetText(1, CurrLineLen())

        if Length(gBestStr) == 0 or BigCmp(newN, gBestStr) < 0

            newDiv = curDiv * (2 * expE + 1)

            if newDiv >= gNeedDiv
                gBestStr = newN
            else
                if primeIdx < gNPrimes
                    if CanReach(newDiv, expE, gNPrimes - primeIdx)
                        Search(primeIdx + 1, expE, newDiv, newN)
                    endif
                endif
            endif

        endif

        expE = expE - 1
    endwhile
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer saveBufId, k

    saveBufId = GetBufferId()
    gNPrimes  = 15
    gNeedDiv  = 8000000
    gBestStr  = ""

    // Prime buffer (first 15 primes, lines 1..15)
    gPrimeBufId = CreateTempBuffer()
    GotoBufferId(gPrimeBufId)
    AddLine("2")
    AddLine("3")
    AddLine("5")
    AddLine("7")
    AddLine("11")
    AddLine("13")
    AddLine("17")
    AddLine("19")
    AddLine("23")
    AddLine("29")
    AddLine("31")
    AddLine("37")
    AddLine("41")
    AddLine("43")
    AddLine("47")

    // Scratch buffer: pre-allocate 240 lines (15 levels * 16 lines each).
    // Line 1 already exists (blank from CreateTempBuffer); add 239 more.
    gScratchBufId = CreateTempBuffer()
    GotoBufferId(gScratchBufId)
    k = 1
    while k <= 239
        EndFile()
        AddLine("")
        k = k + 1
    endwhile
    // gScratchBufId now has 240 lines (1 original blank + 239 added).

    // Run recursive search
    Search(1, 15, 1, "1")

    if Length(gBestStr) == 0
        gBestStr = "No solution found"
    endif

    CopyToWinClip(gBestStr)
    Warn("Project Euler Problem 110"             + Chr(13) +
         "Least n with solutions > 4,000,000:"   + Chr(13) + Chr(13) +
         gBestStr)

    AbandonFile(gPrimeBufId)
    AbandonFile(gScratchBufId)

    GotoBufferId(saveBufId)
end
