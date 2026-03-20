// =============================================================================
// Filename   : eulerproject0141.s
// Version    : 2.0
// Description: Project Euler - Problem 141
//              "Investigating progressive numbers, n, which are also square"
//              Find the sum of all progressive perfect squares below 1 trillion.
// URL        : https://projecteuler.net/problem=141
// Author     : Perplexity AI (LLM: Perplexity / Claude Sonnet 4.6)
// Date       : 2026-03-20
// History    :
//   1.0  2026-03-20  Created by Perplexity AI (LLM: Perplexity / Claude Sonnet 4.6)
//   1.1  2026-03-20  Fixed: all variable declarations moved to top of each proc
//   1.2  2026-03-20  Fixed: deduplicate found squares via buffer (too slow)
//   1.3  2026-03-20  Fixed: coprime gcd(k,m)=1 filter
//   1.4  2026-03-20  Fixed: rewrote MulSmall with p1/p2/p3 splitting
//   1.5  2026-03-20  Fixed: p2*10000 overflow; use AddLarge per partial piece
//   1.6  2026-03-20  Fixed: n>=LIMIT break moved outside gcd==1 block
//   2.0  2026-03-20  Rewrite: correct parametrization r=g*c, d=g*c*p/q reduced;
//                    iterate over divisor d of perfect square n, check r,d,q GP.
//                    n = d*q + r, d^2 = r*q, r < d, r,d,q positive integers.
//                    Parametrize: let ratio r:d:q = a^2 : a*b : b^2 scaled.
//                    Full correct form: r=c*a^2, d=c*a*b, q=c*b^2
//                    n = c*a*b * c*b^2 + c*a^2 = c^2*a*b^3 + c*a^2
//                    with gcd(a,b)=1, b>a>=1, c>=1.
// =============================================================================
//
// Correct parametrization (standard PE141 approach):
//   r, d, q in GP => d/r = q/d => d^2 = r*q
//   Let r = c*a^2, d = c*a*b, q = c*b^2  with gcd(a,b)=1, b>a, c>=1
//   Then n = d*q + r = c^2*a*b^3 + c*a^2
//   For n < 10^12 and n = perfect square.
//
// Note: r < d requires a < b (guaranteed). r >= 1, all positive integers.
// =============================================================================

integer gResHi
integer gResLo
integer gCmpResult
integer gOverflow
integer gMulHi
integer gMulLo
integer gB
integer gLimHi
integer gLimLo
integer gGcd
string  gNumStr[24]

// =============================================================================
proc CmpLarge(integer aHi, integer aLo, integer bHi, integer bLo)
    if aHi < bHi
        gCmpResult = -1
        return()
    endif
    if aHi > bHi
        gCmpResult = 1
        return()
    endif
    if aLo < bLo
        gCmpResult = -1
        return()
    endif
    if aLo > bLo
        gCmpResult = 1
        return()
    endif
    gCmpResult = 0
end

// =============================================================================
proc AddLarge(integer aHi, integer aLo, integer bHi, integer bLo)
    integer sumLo
    integer carry
    sumLo = aLo + bLo
    carry = 0
    if sumLo >= gB
        sumLo = sumLo - gB
        carry = 1
    endif
    gResHi = aHi + bHi + carry
    gResLo = sumLo
end

// =============================================================================
// MulSmall: (nHi, nLo) * kk, kk < 100000
// =============================================================================
proc MulSmall(integer nHi, integer nLo, integer kk)
    integer D2
    integer D1
    integer D0
    integer prod
    integer accHi
    integer accLo
    integer pieceHi
    integer pieceLo

    D2 = nLo / 1000000
    D1 = (nLo / 1000) - D2 * 1000
    D0 = nLo - (nLo / 1000) * 1000

    accHi = 0
    accLo = 0

    AddLarge(accHi, accLo, nHi * kk, 0)
    accHi = gResHi
    accLo = gResLo

    prod    = D2 * kk
    pieceHi = prod / 1000
    pieceLo = (prod - pieceHi * 1000) * 1000000
    AddLarge(accHi, accLo, pieceHi, pieceLo)
    accHi = gResHi
    accLo = gResLo

    prod    = D1 * kk
    pieceHi = prod / 1000000
    pieceLo = (prod - pieceHi * 1000000) * 1000
    AddLarge(accHi, accLo, pieceHi, pieceLo)
    accHi = gResHi
    accLo = gResLo

    AddLarge(accHi, accLo, 0, D0 * kk)
    accHi = gResHi
    accLo = gResLo

    CmpLarge(accHi, accLo, gLimHi, gLimLo)
    if gCmpResult >= 0
        gOverflow = 1
        gMulHi = 0
        gMulLo = 0
        return()
    endif
    gOverflow = 0
    gMulHi = accHi
    gMulLo = accLo
end

// =============================================================================
// SqrtLarge: Newton sqrt of (nHi,nLo) for n < 10^12 => gResLo
// =============================================================================
proc SqrtLarge(integer nHi, integer nLo)
    integer xr
    integer xnext
    integer quot
    integer rem1
    integer iter

    xr   = 1000000
    iter = 0
    while iter < 80
        if xr == 0
            break
        endif
        rem1  = nHi * (gB mod xr) + nLo
        quot  = nHi * (gB / xr) + rem1 / xr
        xnext = (xr + quot) / 2
        if xnext >= xr
            break
        endif
        xr   = xnext
        iter = iter + 1
    endwhile
    gResHi = 0
    gResLo = xr
end

// =============================================================================
proc Gcd(integer aa, integer bb)
    integer tmp
    while bb <> 0
        tmp = bb
        bb  = aa mod bb
        aa  = tmp
    endwhile
    gGcd = aa
end

// =============================================================================
proc LargeToStr(integer nHi, integer nLo)
    string loStr[12]
    if nHi == 0
        gNumStr = Str(nLo)
        return()
    endif
    loStr = Str(nLo)
    while Length(loStr) < 9
        loStr = "0" + loStr
    endwhile
    gNumStr = Str(nHi) + loStr
end

// =============================================================================
// Main
// =============================================================================
proc Main()
    integer bb           // b (outer loop, >= 2)
    integer aa           // a (inner loop, 1 <= a < b, gcd(a,b)=1)
    integer cc           // c (innermost loop, >= 1)
    integer b3Hi, b3Lo   // b^3
    integer ab3Hi, ab3Lo // a * b^3
    integer nHi, nLo     // n = c^2*a*b^3 + c*a^2
    integer t1Hi, t1Lo   // c^2 * a*b^3  (first term)
    integer t2Hi, t2Lo   // c * a^2      (second term)
    integer a2           // a^2 (a < 100000 so a^2 < 10^10 -- use MulSmall)
    integer a2Hi, a2Lo
    integer srLo
    integer sr2Hi, sr2Lo
    integer sumHi, sumLo
    integer bDone
    integer aDone
    integer cDone
    integer b2
    string  answerStr[24]

    gB     = 1000000000
    gLimHi = 1000
    gLimLo = 0
    sumHi  = 0
    sumLo  = 0
    bDone  = FALSE

    bb = 2
    while not bDone

        // b^3
        b2 = bb * bb
        MulSmall(0, b2, bb)
        if gOverflow
            bDone = TRUE
        else
            b3Hi = gMulHi
            b3Lo = gMulLo

            aDone = FALSE
            aa = 1

            while not aDone and aa < bb

                Gcd(aa, bb)
                if gGcd == 1

                    // a*b^3
                    MulSmall(b3Hi, b3Lo, aa)
                    if gOverflow
                        aDone = TRUE
                    else
                        ab3Hi = gMulHi
                        ab3Lo = gMulLo

                        // a^2
                        MulSmall(0, aa, aa)
                        a2Hi = gMulHi
                        a2Lo = gMulLo

                        // inner c loop: n = c^2*ab3 + c*a2
                        cDone = FALSE
                        cc = 1

                        while not cDone

                            // t1 = c^2 * ab3
                            MulSmall(ab3Hi, ab3Lo, cc)
                            if gOverflow
                                cDone = TRUE
                            else
                                t1Hi = gMulHi
                                t1Lo = gMulLo
                                MulSmall(t1Hi, t1Lo, cc)
                                if gOverflow
                                    cDone = TRUE
                                else
                                    t1Hi = gMulHi
                                    t1Lo = gMulLo

                                    // t2 = c * a2
                                    MulSmall(a2Hi, a2Lo, cc)
                                    if gOverflow
                                        cDone = TRUE
                                    else
                                        t2Hi = gMulHi
                                        t2Lo = gMulLo

                                        // n = t1 + t2
                                        AddLarge(t1Hi, t1Lo, t2Hi, t2Lo)
                                        nHi = gResHi
                                        nLo = gResLo

                                        CmpLarge(nHi, nLo, gLimHi, gLimLo)
                                        if gCmpResult >= 0
                                            cDone = TRUE
                                        else
                                            // Check perfect square
                                            SqrtLarge(nHi, nLo)
                                            srLo = gResLo
                                            MulSmall(0, srLo, srLo)
                                            sr2Hi = gMulHi
                                            sr2Lo = gMulLo
                                            CmpLarge(sr2Hi, sr2Lo, nHi, nLo)
                                            if gCmpResult <> 0
                                                MulSmall(0, srLo + 1, srLo + 1)
                                                sr2Hi = gMulHi
                                                sr2Lo = gMulLo
                                                CmpLarge(sr2Hi, sr2Lo, nHi, nLo)
                                            endif
                                            if gCmpResult == 0
                                                AddLarge(sumHi, sumLo, nHi, nLo)
                                                sumHi = gResHi
                                                sumLo = gResLo
                                            endif
                                        endif
                                    endif
                                endif
                            endif

                            if not cDone
                                cc = cc + 1
                            endif

                        endwhile  // c loop

                    endif  // a*b^3 not overflow

                endif  // gcd(a,b)==1

                aa = aa + 1

            endwhile  // a loop

        endif  // b^3 not overflow

        bb = bb + 1

    endwhile  // b loop

    LargeToStr(sumHi, sumLo)
    answerStr = gNumStr

    CopyToWinClip(answerStr)

    Warn("Project Euler 141 - Progressive perfect squares below 1 trillion:|" +
         "|Answer = " + answerStr + "||(Answer copied to clipboard)")

end

