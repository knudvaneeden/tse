// eulerproject0234.s
// Project Euler Problem 234 - Semidivisible Numbers
// Version 4
// Created by: Claude (Anthropic)
//
// History:
//  v1 - Claude (Anthropic) - initial implementation
//  v2 - Claude (Anthropic) - cleaned overflow handling, verified vs Python
//  v3 - Claude (Anthropic) - fixed Mul64 for large nB inputs
//  v4 - Claude (Anthropic) - fixed Mul64 nTmpLo 32-bit overflow: split lo
//                            accumulation into two steps with carry check
//                            between them so no single addition exceeds 2^31
//
// Problem: Sum all semidivisible n <= 999966663333
// n is semidivisible if exactly one of lps(n) or ups(n) divides n
// lps(n)=largest prime<=sqrt(n), ups(n)=smallest prime>=sqrt(n)
//
// Strategy:
//   Sieve primes up to 999984
//   For each consecutive prime pair (p,q):
//     Semidivisible n in (p^2, min(q^2,LIMIT+1)) open interval:
//       = multiples of p + multiples of q - 2*multiples of p*q
//     Use AP sum formula; all large values via hi/lo 64-bit (BASE=10^9)
//
// Expected answer: 1259187438574927161

integer gBase        // 1000000000
integer gAccHi
integer gAccLo
integer gProdHi
integer gProdLo
integer gQuotient
integer gSieveBufId

// ---- AccAdd64 / AccSub64 ----

proc AccAdd64(integer nHi, integer nLo)
    gAccLo = gAccLo + nLo
    if gAccLo >= gBase
        gAccHi = gAccHi + 1
        gAccLo = gAccLo - gBase
    endif
    gAccHi = gAccHi + nHi
end

proc AccSub64(integer nHi, integer nLo)
    gAccLo = gAccLo - nLo
    if gAccLo < 0
        gAccHi = gAccHi - 1
        gAccLo = gAccLo + gBase
    endif
    gAccHi = gAccHi - nHi
end

// ---- Mul64: nA * nB -> (gProdHi, gProdLo) ----
// Works for nA <= 10^6 and nB < 10^9
// Split nB = nBH*10^6 + nBLL*10^3 + nBLR
//   nA*nBH  <= 999983*999  < 10^9  SAFE
//   nA*nBLL <= 999983*999  < 10^9  SAFE
//   nA*nBLR <= 999983*999  < 10^9  SAFE
// lo accumulated in TWO steps to stay under 2^31:
//   Step1: lo = (P1%1000)*10^6 + (P2%1000000)*10^3
//          max = 999*10^6 + 999999*10^3 = 1998999000 < 2^31  SAFE
//          carry check
//   Step2: lo += P3  (lo < BASE < 10^9, P3 < 10^9, sum < 2*10^9 < 2^31 SAFE)
//          carry check
proc Mul64(integer nA, integer nB)
    integer nBH
    integer nBLL
    integer nBLR
    integer nP1
    integer nP2
    integer nP3
    integer nLo
    nBH  = nB / 1000000
    nBLL = (nB mod 1000000) / 1000
    nBLR = nB mod 1000
    nP1  = nA * nBH
    nP2  = nA * nBLL
    nP3  = nA * nBLR
    gProdHi = nP1 / 1000 + nP2 / 1000000
    // Step 1: accumulate first two lo parts (max 1998999000 < 2^31)
    nLo = (nP1 mod 1000) * 1000000 + (nP2 mod 1000000) * 1000
    if nLo >= gBase
        gProdHi = gProdHi + 1
        nLo = nLo - gBase
    endif
    // Step 2: add P3 (nLo < BASE, P3 < 10^9, sum < 2*10^9 < 2^31)
    nLo = nLo + nP3
    if nLo >= gBase
        gProdHi = gProdHi + 1
        nLo = nLo - gBase
    endif
    gProdLo = nLo
end

// ---- Div64: floor((nHi*BASE+nLo)/nD) -> gQuotient ----
// nHi<=999, nBmodD<10^6: nHi*nBmodD+nLo <= 999*(10^6-1)+10^9-1
//   = 998999001 + 999999999 = 1998999000 < 2^31  SAFE
proc Div64(integer nHi, integer nLo, integer nD)
    integer nBdivD
    integer nBmodD
    integer nRem
    nBdivD = gBase / nD
    nBmodD = gBase mod nD
    nRem   = nHi * nBmodD + nLo
    gQuotient = nHi * nBdivD + nRem / nD
end

// ---- AddAPSum: add nStep*(nK1+...+nK2) to gAcc ----
// = nStep * (nK1+nK2) * (nK2-nK1+1) / 2
// nK1,nK2 <= ~10^6; nStep <= ~10^6
// Two Mul64 steps:
//   tmp = Mul64(nStep, nSK)   nStep,nSK both <= 10^6
//   result += tmp_hi*nCT*BASE + Mul64(nCT, tmp_lo)
//   tmp_hi <= ~2000, nCT <= 227 -> tmp_hi*nCT <= ~164640 SAFE
proc AddAPSum(integer nStep, integer nK1, integer nK2)
    integer nCT
    integer nSK
    integer nTmpHi
    integer nTmpLo
    nCT = nK2 - nK1 + 1
    if nCT <= 0
        return()
    endif
    nSK = nK1 + nK2
    if (nSK mod 2) == 0
        nSK = nSK / 2
    else
        nCT = nCT / 2
    endif
    Mul64(nStep, nSK)
    nTmpHi = gProdHi
    nTmpLo = gProdLo
    // Add nTmpHi*nCT*BASE to accumulator
    AccAdd64(nTmpHi * nCT, 0)
    // Add nTmpLo*nCT to accumulator
    Mul64(nCT, nTmpLo)
    AccAdd64(gProdHi, gProdLo)
end

// ---- AddMultiplesSum: sum of multiples of nStep in open (nLo,nHi) ----
proc AddMultiplesSum(integer nStep, integer nLo_hi, integer nLo_lo,
                                   integer nHi_hi,  integer nHi_lo)
    integer nL_hi, nL_lo
    integer nH_hi, nH_lo
    integer nK1, nK2
    nL_hi = nLo_hi
    nL_lo = nLo_lo + 1
    if nL_lo >= gBase
        nL_hi = nL_hi + 1
        nL_lo = nL_lo - gBase
    endif
    nH_hi = nHi_hi
    nH_lo = nHi_lo - 1
    if nH_lo < 0
        nH_hi = nH_hi - 1
        nH_lo = nH_lo + gBase
    endif
    Div64(nL_hi, nL_lo, nStep)
    nK1 = gQuotient
    // Ceiling: if nK1*nStep < nL, increment
    Mul64(nK1, nStep)
    if gProdHi < nL_hi
        nK1 = nK1 + 1
    elseif gProdHi == nL_hi and gProdLo < nL_lo
        nK1 = nK1 + 1
    endif
    Div64(nH_hi, nH_lo, nStep)
    nK2 = gQuotient
    if nK2 >= nK1
        AddAPSum(nStep, nK1, nK2)
    endif
end

// ---- Sieve primes up to nLimit into gSieveBufId ----
proc BuildPrimeSieve(integer nLimit)
    integer nSieveId
    integer nI, nJ, nP
    string  sCh[1]
    nSieveId = CreateTempBuffer()
    nI = 0
    while nI <= nLimit
        AddLine("1")
        nI = nI + 1
    endwhile
    GotoLine(1) BegLine() InsertText("0", _OVERWRITE_)
    GotoLine(2) BegLine() InsertText("0", _OVERWRITE_)
    nP = 2
    while nP * nP <= nLimit
        GotoLine(nP + 1)
        sCh = GetText(1, 1)
        if sCh == "1"
            nJ = nP * nP
            while nJ <= nLimit
                GotoLine(nJ + 1)
                BegLine()
                InsertText("0", _OVERWRITE_)
                nJ = nJ + nP
            endwhile
        endif
        nP = nP + 1
    endwhile
    gSieveBufId = CreateTempBuffer()
    GotoBufferId(nSieveId)
    nI = 2
    while nI <= nLimit
        GotoLine(nI + 1)
        sCh = GetText(1, 1)
        if sCh == "1"
            GotoBufferId(gSieveBufId)
            AddLine(Str(nI))
            GotoBufferId(nSieveId)
        endif
        nI = nI + 1
    endwhile
    AbandonFile(nSieveId)
    GotoBufferId(gSieveBufId)
    BegFile()
end

// ---- Main ----
PROC Main()
    integer nNumPrimes, nLineP
    integer nP, nQ
    integer nPsq_hi, nPsq_lo
    integer nQsq_hi, nQsq_lo
    integer nHi_hi,  nHi_lo
    integer nLim_hi, nLim_lo
    integer nLcm_hi, nLcm_lo
    integer nInRange
    string  sPrime[12]
    string  sResult[30]

    gBase  = 1000000000
    gAccHi = 0
    gAccLo = 0

    // LIMIT = 999966663333 = 999*10^9 + 966663333
    nLim_hi = 999
    nLim_lo = 966663333

    // Primes up to 999984 (> sqrt(999966663333) ~ 999983.3)
    BuildPrimeSieve(999984)
    GotoBufferId(gSieveBufId)
    nNumPrimes = NumLines()
    BegFile()

    nLineP = 1
    while nLineP < nNumPrimes
        GotoLine(nLineP)
        sPrime = GetText(1, 12)
        nP = Val(sPrime)
        GotoLine(nLineP + 1)
        sPrime = GetText(1, 12)
        nQ = Val(sPrime)

        // p^2
        Mul64(nP, nP)
        nPsq_hi = gProdHi
        nPsq_lo = gProdLo

        // Stop if p^2 > LIMIT
        if nPsq_hi > nLim_hi
            break
        endif
        if nPsq_hi == nLim_hi and nPsq_lo > nLim_lo
            break
        endif

        // q^2
        Mul64(nQ, nQ)
        nQsq_hi = gProdHi
        nQsq_lo = gProdLo

        // nHi = min(q^2, LIMIT+1) as exclusive upper bound
        if nQsq_hi > nLim_hi
            nHi_hi = nLim_hi
            nHi_lo = nLim_lo + 1
            if nHi_lo >= gBase
                nHi_hi = nHi_hi + 1
                nHi_lo = nHi_lo - gBase
            endif
        elseif nQsq_hi == nLim_hi and nQsq_lo > nLim_lo
            nHi_hi = nLim_hi
            nHi_lo = nLim_lo + 1
            if nHi_lo >= gBase
                nHi_hi = nHi_hi + 1
                nHi_lo = nHi_lo - gBase
            endif
        else
            nHi_hi = nQsq_hi
            nHi_lo = nQsq_lo
        endif

        // Sum multiples of p in open (p^2, nHi)
        AddMultiplesSum(nP, nPsq_hi, nPsq_lo, nHi_hi, nHi_lo)
        // Sum multiples of q in open (p^2, nHi)
        AddMultiplesSum(nQ, nPsq_hi, nPsq_lo, nHi_hi, nHi_lo)

        // Subtract 2*p*q if p*q strictly inside (p^2, nHi)
        Mul64(nP, nQ)
        nLcm_hi = gProdHi
        nLcm_lo = gProdLo
        nInRange = FALSE
        if nLcm_hi < nHi_hi
            nInRange = TRUE
        elseif nLcm_hi == nHi_hi and nLcm_lo < nHi_lo
            nInRange = TRUE
        endif
        if nInRange
            AccSub64(nLcm_hi, nLcm_lo)
            AccSub64(nLcm_hi, nLcm_lo)
        endif

        nLineP = nLineP + 1
    endwhile

    AbandonFile(gSieveBufId)

    if gAccHi > 0
        sResult = Str(gAccHi) + Format(gAccLo:9:"0")
    else
        sResult = Str(gAccLo)
    endif

    CopyToWinClip(sResult)
    Warn("P234 answer = " + sResult)
    CopyToWinClip(sResult)
end
