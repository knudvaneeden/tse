
// ============================================================
// Euler151.s
//
// Project Euler - Problem 151
// "Paper sheets of standard sizes: an expected-value problem"
//
// Each Monday foreman picks a random sheet from envelope.
// Picking Ai (i<5): remove Ai, add +1 to each of A(i+1)..A5.
// Picking A5: remove A5 only (used directly).
//
// State (1,0,0,0,0) = first Monday  => do NOT count.
// State (0,0,0,0,1) = last Monday   => do NOT count.
// All other single-sheet states     => count (add prob).
//
// Method: pass prob as exact (pNum,pDen) 32-bit fraction.
// Accumulate E * DENOM10 as (acc_hi, acc_lo) with BASE=10000000.
// DENOM10 = 261382464000000 = 26138246 * 10000000 + 4000000
// At single-sheet leaf: contribution = pNum * (DENOM10 / pDen)
// Compute 7 decimal digits then round to 6.
// All intermediate values fit in 32-bit signed integers.
//
// Version   : 1.5
// Date      : 2026-03-21
// Language  : TSE SAL (The SemWare Editor Professional)
// LLM       : Perplexity AI (powered by Claude Sonnet 4.6)
// ============================================================
//
// History:
//  1.0  2026-03-21  Initial version. (Perplexity/Claude Sonnet 4.6)
//  1.1  2026-03-21  Fixed first/last batch exclusion flag.
//  1.2  2026-03-21  Fixed cutting model: picking Ai adds +1 to
//                   each of A(i+1)..A5 inclusive.
//  1.3  2026-03-21  Fixed overflow: use SCALE integer accumulator.
//  1.4  2026-03-21  Fixed precision: use DENOM hi/lo pair.
//  1.5  2026-03-21  Fixed rounding: compute 7 digits, round to 6.
//                   Fixed TSE SAL: all variable declarations at
//                   top of each function, no mid-function declarations.
//
// ============================================================

#define BASE      10000000
#define DENOM_HI  26138246
#define DENOM_LO  4000000

integer g_acc_hi
integer g_acc_lo
integer g_rNum
integer g_rDen

integer proc GCD(integer aa, integer bb)
    integer tmp
    aa = Abs(aa)
    bb = Abs(bb)
    while bb <> 0
        tmp = bb
        bb  = aa mod bb
        aa  = tmp
    endwhile
    return(aa)
end

proc MulProb(integer pNum, integer pDen, integer ni, integer numSheets)
    integer g, an, fd2, fn2, pd2
    g   = GCD(pNum, numSheets)
    an  = pNum / g
    fd2 = numSheets / g
    g   = GCD(ni, pDen)
    fn2 = ni / g
    pd2 = pDen / g
    g_rNum = an  * fn2
    g_rDen = pd2 * fd2
end

proc AddContrib(integer pNum, integer pDen)
    integer scale_hi, scale_lo, tempScale, r
    integer contrib_lo_full, contrib_carry, contrib_lo, contrib_hi

    // Compute scale = DENOM10 / pDen via long division digit-by-digit.
    // DENOM10 = DENOM_HI * BASE + DENOM_LO
    //         = 26138246 * 10000000 + 4000000
    // DENOM_LO = 4000000 has digits: 4,0,0,0,0,0,0 (7 digits)
    // Step 1: scale_hi = DENOM_HI / pDen, r = DENOM_HI mod pDen
    // Step 2: long-divide r|DENOM_LO by pDen digit by digit to get scale_lo
    scale_hi  = DENOM_HI / pDen
    r         = DENOM_HI mod pDen
    tempScale = 0
    r = r * 10 + 4
    tempScale = tempScale * 10 + r / pDen
    r = r mod pDen
    r = r * 10 + 0
    tempScale = tempScale * 10 + r / pDen
    r = r mod pDen
    r = r * 10 + 0
    tempScale = tempScale * 10 + r / pDen
    r = r mod pDen
    r = r * 10 + 0
    tempScale = tempScale * 10 + r / pDen
    r = r mod pDen
    r = r * 10 + 0
    tempScale = tempScale * 10 + r / pDen
    r = r mod pDen
    r = r * 10 + 0
    tempScale = tempScale * 10 + r / pDen
    r = r mod pDen
    r = r * 10 + 0
    tempScale = tempScale * 10 + r / pDen
    scale_lo  = tempScale mod BASE
    scale_hi  = scale_hi + tempScale / BASE

    contrib_lo_full = pNum * scale_lo
    contrib_carry   = contrib_lo_full / BASE
    contrib_lo      = contrib_lo_full mod BASE
    contrib_hi      = pNum * scale_hi + contrib_carry

    g_acc_lo      = g_acc_lo + contrib_lo
    contrib_carry = g_acc_lo / BASE
    g_acc_lo      = g_acc_lo mod BASE
    g_acc_hi      = g_acc_hi + contrib_hi + contrib_carry
end

proc Solve(integer n1, integer n2, integer n3, integer n4, integer n5,
           integer pNum, integer pDen, integer isFirst)
    integer numSheets, isSingle, newPNum, newPDen

    numSheets = n1 + n2 + n3 + n4 + n5
    if numSheets == 0
        return()
    endif

    isSingle = 0
    if numSheets == 1
        if isFirst == 0
            if n5 == 1 and n1 == 0 and n2 == 0 and n3 == 0 and n4 == 0
                isSingle = 0
            else
                isSingle = 1
            endif
        endif
    endif

    if isSingle
        AddContrib(pNum, pDen)
    endif

    if n1 > 0
        MulProb(pNum, pDen, n1, numSheets)
        newPNum = g_rNum
        newPDen = g_rDen
        Solve(n1-1, n2+1, n3+1, n4+1, n5+1, newPNum, newPDen, 0)
    endif

    if n2 > 0
        MulProb(pNum, pDen, n2, numSheets)
        newPNum = g_rNum
        newPDen = g_rDen
        Solve(n1, n2-1, n3+1, n4+1, n5+1, newPNum, newPDen, 0)
    endif

    if n3 > 0
        MulProb(pNum, pDen, n3, numSheets)
        newPNum = g_rNum
        newPDen = g_rDen
        Solve(n1, n2, n3-1, n4+1, n5+1, newPNum, newPDen, 0)
    endif

    if n4 > 0
        MulProb(pNum, pDen, n4, numSheets)
        newPNum = g_rNum
        newPDen = g_rDen
        Solve(n1, n2, n3, n4-1, n5+1, newPNum, newPDen, 0)
    endif

    if n5 > 0
        MulProb(pNum, pDen, n5, numSheets)
        newPNum = g_rNum
        newPDen = g_rDen
        Solve(n1, n2, n3, n4, n5-1, newPNum, newPDen, 0)
    endif

end

string proc FormatResult()
    integer remHi, remLo, idx, d
    integer carry10, subLo, subHi, subCarry, cmp, fc
    integer d6, d7
    string  decimals[10]
    string  digit[2]
    string  result[30]

    decimals = ""
    digit    = ""
    result   = ""
    remHi    = g_acc_hi
    remLo    = g_acc_lo

    idx = 0
    while idx < 7
        remLo   = remLo * 10
        carry10 = remLo / BASE
        remLo   = remLo mod BASE
        remHi   = remHi * 10 + carry10

        d = remHi / DENOM_HI
        if d > 9
            d = 9
        endif

        subLo    = d * DENOM_LO
        subCarry = subLo / BASE
        subLo    = subLo mod BASE
        subHi    = d * DENOM_HI + subCarry

        remLo = remLo - subLo
        if remLo < 0
            remLo = remLo + BASE
            remHi = remHi - 1
        endif
        remHi = remHi - subHi

        while remHi < 0
            d     = d - 1
            remLo = remLo + DENOM_LO
            fc    = remLo / BASE
            remLo = remLo mod BASE
            remHi = remHi + DENOM_HI + fc
        endwhile

        cmp = 0
        if remHi > DENOM_HI
            cmp = 1
        elseif remHi == DENOM_HI
            if remLo >= DENOM_LO
                cmp = 1
            endif
        endif
        while cmp
            d     = d + 1
            remLo = remLo - DENOM_LO
            if remLo < 0
                remLo = remLo + BASE
                remHi = remHi - 1
            endif
            remHi = remHi - DENOM_HI
            cmp = 0
            if remHi > DENOM_HI
                cmp = 1
            elseif remHi == DENOM_HI
                if remLo >= DENOM_LO
                    cmp = 1
                endif
            endif
        endwhile

        digit    = Str(d)
        decimals = decimals + digit
        idx      = idx + 1
    endwhile

    // Round 6th decimal using 7th digit
    d6 = Val(SubStr(decimals, 6, 1))
    d7 = Val(SubStr(decimals, 7, 1))
    if d7 >= 5
        d6 = d6 + 1
    endif
    if d6 > 9
        d6 = 0
    endif
    decimals = SubStr(decimals, 1, 5) + Str(d6)

    result = "0." + decimals
    return(result)
end

proc Main()
    string answer[40]
    string clipText[40]
    answer   = ""
    clipText = ""
    g_acc_hi = 0
    g_acc_lo = 0
    Solve(1, 0, 0, 0, 0, 1, 1, 1)
    answer   = FormatResult()
    clipText = answer
    Warn("Project Euler Problem 151~Answer (expected single-sheet count):~~" + answer)
    CopyToWinClip(clipText)
    InsertText(answer, _INSERT_)
end
0.464399
