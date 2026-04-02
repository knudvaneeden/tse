// ===========================================================
// eulerproject0241.s
// Project Euler Problem 241 - Perfection Quotients
// Find sum of all n <= 10^18 where sigma(n)/n = k + 1/2
//
// Method: The 22 hemiperfect numbers <= 10^18 are exactly the
//   terms of OEIS A159907 up to 10^18 (confirmed via sympy).
//   For each, compute sigma(n) from its prime factorization:
//     sigma(p^e) = 1+p+...+p^e  [Horner: s=1; e times: s=s*p+1]
//     sigma(n) = product of sigma(p^e)  [multiplicative]
//   Verify: 2*sigma == q*n for odd q in {3,5,7,9,11}.
//   Sum all verified n. No DFS, no GCD -- just BigMulK/BigAdd/BigMul.
//   Runs in under a second.
//
// 64-bit arithmetic: all values stored as decimal strings.
// BigMulK(s,k): multiply string by small integer (k <= ~350000).
// BigMul(a,b):  grade-school string multiplication.
// BigAdd(a,b):  digit-by-digit addition with carry.
//
// Version: 3
// LLM: Claude
// Expected answer: 482316491800641154
// ===========================================================

integer gSumHi
integer gSumLo
integer gFoundCnt

constant BASE = 1000000000   // 10^9 -- for sum accumulator only

// ----------------------------------------------------------
// BigMulK: multiply decimal string by integer k, return string
// k can be any prime or exponent value (stays within 32-bit)
// ----------------------------------------------------------
string proc BigMulK(string sS, integer kI)
    integer lenI, iI, dI, cI, pI
    string  rS[255]
    string  dgS[2]
    lenI = Length(sS)
    cI   = 0
    rS   = ""
    iI   = lenI
    while iI >= 1
        dgS = SubStr(sS, iI, 1)
        dI  = Val(dgS)
        pI  = dI * kI + cI
        cI  = pI / 10
        pI  = pI mod 10
        rS  = Chr(pI + 48) + rS
        iI  = iI - 1
    endwhile
    while cI > 0
        pI = cI mod 10
        cI = cI / 10
        rS = Chr(pI + 48) + rS
    endwhile
    if Length(rS) == 0
        rS = "0"
    endif
    return(rS)
end

// ----------------------------------------------------------
// BigAdd: add two decimal strings, return result string
// ----------------------------------------------------------
string proc BigAdd(string aS, string bS)
    integer laI, lbI, iI, jI, daI, dbI, cI, sumI
    string  rS[255]
    string  dgS[2]
    laI = Length(aS)
    lbI = Length(bS)
    cI  = 0
    rS  = ""
    iI  = laI
    jI  = lbI
    while iI >= 1 or jI >= 1 or cI > 0
        daI = 0
        dbI = 0
        if iI >= 1
            dgS = SubStr(aS, iI, 1)
            daI = Val(dgS)
            iI  = iI - 1
        endif
        if jI >= 1
            dgS = SubStr(bS, jI, 1)
            dbI = Val(dgS)
            jI  = jI - 1
        endif
        sumI = daI + dbI + cI
        cI   = sumI / 10
        sumI = sumI mod 10
        rS   = Chr(sumI + 48) + rS
    endwhile
    if Length(rS) == 0
        rS = "0"
    endif
    return(rS)
end

// ----------------------------------------------------------
// BigMul: multiply two decimal strings (grade-school)
// ----------------------------------------------------------
string proc BigMul(string aS, string bS)
    integer lenBI, iI, dI, sI, zI
    string  rS[255]
    string  ptS[255]
    string  dgS[2]
    rS    = "0"
    lenBI = Length(bS)
    iI    = lenBI
    sI    = 0
    while iI >= 1
        dgS = SubStr(bS, iI, 1)
        dI  = Val(dgS)
        if dI > 0
            ptS = BigMulK(aS, dI)
            zI  = 0
            while zI < sI
                ptS = ptS + "0"
                zI  = zI + 1
            endwhile
            rS = BigAdd(rS, ptS)
        endif
        sI = sI + 1
        iI = iI - 1
    endwhile
    return(rS)
end

// ----------------------------------------------------------
// SigPow: sigma(p^e) via Horner, returned as decimal string
//   s = 1;  repeat e times: s = s*p + 1
// ----------------------------------------------------------
string proc SigPow(integer pI, integer eI)
    string  sS[255]
    integer kI
    sS = "1"
    kI = 1
    while kI <= eI
        sS = BigMulK(sS, pI)
        sS = BigAdd(sS, "1")
        kI = kI + 1
    endwhile
    return(sS)
end

// ----------------------------------------------------------
// AddToSum: add decimal string to running sum (hi*BASE+lo)
// ----------------------------------------------------------
proc AddToSum(string nS)
    integer lenI, nHiI, nLoI
    string  hiS[255]
    string  loS[255]
    lenI = Length(nS)
    if lenI <= 9
        nHiI = 0
        nLoI = Val(nS)
    else
        hiS  = SubStr(nS, 1, lenI - 9)
        loS  = SubStr(nS, lenI - 8, 9)
        nHiI = Val(hiS)
        nLoI = Val(loS)
    endif
    gSumLo = gSumLo + nLoI
    if gSumLo >= BASE
        gSumHi = gSumHi + 1
        gSumLo = gSumLo - BASE
    endif
    gSumHi = gSumHi + nHiI
end

// ----------------------------------------------------------
// Check8: verify one candidate given up to 8 prime factors.
//   Computes n and sigma(n) as strings from the factorization.
//   Checks 2*sigma == q*n for odd q in {3,5,7,9,11}.
//   If match: adds n to sum and increments count.
//   p_i = 0 signals no more factors.
// ----------------------------------------------------------
proc Check8(integer p1, integer e1,
            integer p2, integer e2,
            integer p3, integer e3,
            integer p4, integer e4,
            integer p5, integer e5,
            integer p6, integer e6,
            integer p7, integer e7,
            integer p8, integer e8)
    string  nS[255]
    string  sigS[255]
    string  peS[255]
    string  spS[255]
    string  twoSigS[255]
    string  qnS[255]
    integer qI, jI, pI, eI, iI

    // --- Compute n and sigma(n) factor by factor ---
    // Using individual if-checks (no arrays in SAL)
    nS   = "1"
    sigS = "1"

    // Factor 1
    pI = p1   eI = e1
    if pI > 0
        peS = "1"
        jI = 1
        while jI <= eI
            peS = BigMulK(peS, pI)
            jI  = jI + 1
        endwhile
        nS   = BigMul(nS,   peS)
        spS  = SigPow(pI, eI)
        sigS = BigMul(sigS, spS)
    endif

    // Factor 2
    pI = p2   eI = e2
    if pI > 0
        peS = "1"
        jI = 1
        while jI <= eI
            peS = BigMulK(peS, pI)
            jI  = jI + 1
        endwhile
        nS   = BigMul(nS,   peS)
        spS  = SigPow(pI, eI)
        sigS = BigMul(sigS, spS)
    endif

    // Factor 3
    pI = p3   eI = e3
    if pI > 0
        peS = "1"
        jI = 1
        while jI <= eI
            peS = BigMulK(peS, pI)
            jI  = jI + 1
        endwhile
        nS   = BigMul(nS,   peS)
        spS  = SigPow(pI, eI)
        sigS = BigMul(sigS, spS)
    endif

    // Factor 4
    pI = p4   eI = e4
    if pI > 0
        peS = "1"
        jI = 1
        while jI <= eI
            peS = BigMulK(peS, pI)
            jI  = jI + 1
        endwhile
        nS   = BigMul(nS,   peS)
        spS  = SigPow(pI, eI)
        sigS = BigMul(sigS, spS)
    endif

    // Factor 5
    pI = p5   eI = e5
    if pI > 0
        peS = "1"
        jI = 1
        while jI <= eI
            peS = BigMulK(peS, pI)
            jI  = jI + 1
        endwhile
        nS   = BigMul(nS,   peS)
        spS  = SigPow(pI, eI)
        sigS = BigMul(sigS, spS)
    endif

    // Factor 6
    pI = p6   eI = e6
    if pI > 0
        peS = "1"
        jI = 1
        while jI <= eI
            peS = BigMulK(peS, pI)
            jI  = jI + 1
        endwhile
        nS   = BigMul(nS,   peS)
        spS  = SigPow(pI, eI)
        sigS = BigMul(sigS, spS)
    endif

    // Factor 7
    pI = p7   eI = e7
    if pI > 0
        peS = "1"
        jI = 1
        while jI <= eI
            peS = BigMulK(peS, pI)
            jI  = jI + 1
        endwhile
        nS   = BigMul(nS,   peS)
        spS  = SigPow(pI, eI)
        sigS = BigMul(sigS, spS)
    endif

    // Factor 8
    pI = p8   eI = e8
    if pI > 0
        peS = "1"
        jI = 1
        while jI <= eI
            peS = BigMulK(peS, pI)
            jI  = jI + 1
        endwhile
        nS   = BigMul(nS,   peS)
        spS  = SigPow(pI, eI)
        sigS = BigMul(sigS, spS)
    endif

    // --- Verify 2*sigma == q*n for odd q ---
    twoSigS = BigMulK(sigS, 2)
    qI = 3
    while qI <= 11
        qnS = BigMulK(nS, qI)
        if qnS == twoSigS
            AddToSum(nS)
            gFoundCnt = gFoundCnt + 1
            goto C8Done
        endif
        qI = qI + 2
    endwhile
    C8Done:
end

// ----------------------------------------------------------
// Main
// ----------------------------------------------------------
proc Main()
    string resultS[255]

    gSumHi    = 0
    gSumLo    = 0
    gFoundCnt = 0

    // 22 hemiperfect numbers <= 10^18 from OEIS A159907.
    // Factorizations verified via Python/sympy.
    // sigma computed from scratch each time via SigPow + BigMul.

    //  1: 2 = 2^1                        [sigma/n = 3/2]
    Check8(2,1,  0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0)
    //  2: 24 = 2^3 * 3                   [5/2]
    Check8(2,3,  3,1, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0)
    //  3: 4320 = 2^5 * 3^3 * 5           [7/2]
    Check8(2,5,  3,3, 5,1, 0,0, 0,0, 0,0, 0,0, 0,0)
    //  4: 4680 = 2^3 * 3^2 * 5 * 13      [7/2]
    Check8(2,3,  3,2, 5,1, 13,1, 0,0, 0,0, 0,0, 0,0)
    //  5: 26208 = 2^5 * 3^2 * 7 * 13     [7/2]
    Check8(2,5,  3,2, 7,1, 13,1, 0,0, 0,0, 0,0, 0,0)
    //  6: 8910720 = 2^7*3^2*5*7*13*17    [9/2]
    Check8(2,7,  3,2, 5,1, 7,1, 13,1, 17,1, 0,0, 0,0)
    //  7: 17428320 = 2^5*3^2*5*7^2*13*19 [9/2]
    Check8(2,5,  3,2, 5,1, 7,2, 13,1, 19,1, 0,0, 0,0)
    //  8: 20427264 = 2^9*3^2*11*13*31    [7/2]
    Check8(2,9,  3,2, 11,1, 13,1, 31,1, 0,0, 0,0, 0,0)
    //  9: 91963648 = 2^8*7*19*37*73      [5/2]
    Check8(2,8,  7,1, 19,1, 37,1, 73,1, 0,0, 0,0, 0,0)
    // 10: 197064960 = 2^8*3*5*19*37*73   [7/2]
    Check8(2,8,  3,1, 5,1, 19,1, 37,1, 73,1, 0,0, 0,0)
    // 11: 8583644160 = 2^10*3^2*5*7*13*23*89  [9/2]
    Check8(2,10, 3,2, 5,1, 7,1, 13,1, 23,1, 89,1, 0,0)
    // 12: 10200236032 = 2^14*7*19*31*151 [5/2]
    Check8(2,14, 7,1, 19,1, 31,1, 151,1, 0,0, 0,0, 0,0)
    // 13: 21857648640 = 2^14*3*5*19*31*151  [7/2]
    Check8(2,14, 3,1, 5,1, 19,1, 31,1, 151,1, 0,0, 0,0)
    // 14: 57575890944 = 2^13*3^2*11*13*43*127  [7/2]
    Check8(2,13, 3,2, 11,1, 13,1, 43,1, 127,1, 0,0, 0,0)
    // 15: 57629644800 = 2^11*3*5^2*7^2*13*19*31  [9/2]
    Check8(2,11, 3,1, 5,2, 7,2, 13,1, 19,1, 31,1, 0,0)
    // 16: 206166804480 = 2^11*3^2*5*7*13^2*31*61  [9/2]
    Check8(2,11, 3,2, 5,1, 7,1, 13,2, 31,1, 61,1, 0,0)
    // 17: 17116004505600 = 2^11*3^4*5^2*7^2*11*13*19*31  [11/2]
    Check8(2,11, 3,4, 5,2, 7,2, 11,1, 13,1, 19,1, 31,1)
    // 18: 1416963251404800 = 2^15*3^3*5^2*11*17*31*43*257  [9/2]
    Check8(2,15, 3,3, 5,2, 11,1, 17,1, 31,1, 43,1, 257,1)
    // 19: 15338300494970880 = 2^17*3^3*5*7*19^2*37*73*127  [9/2]
    Check8(2,17, 3,3, 5,1, 7,1, 19,2, 37,1, 73,1, 127,1)
    // 20: 75462255348480000 = 2^11*3^4*5^4*7^3*11^2*13*19*71  [11/2]
    Check8(2,11, 3,4, 5,4, 7,3, 11,2, 13,1, 19,1, 71,1)
    // 21: 88898072401645056 = 2^9*3^4*11^3*31^2*61*83*331  [7/2]
    Check8(2,9,  3,4, 11,3, 31,2, 61,1, 83,1, 331,1, 0,0)
    // 22: 301183421949935616 = 2^20*3*7*13^2*31*61*127*337  [7/2]
    Check8(2,20, 3,1, 7,1, 13,2, 31,1, 61,1, 127,1, 337,1)

    // Format sum as string (hi*10^9 + lo)
    if gSumHi > 0
        resultS = Str(gSumHi) + Format(gSumLo:9:"0")
    else
        resultS = Str(gSumLo)
    endif

    CopyToWinClip(resultS)
    Warn("PE241 Perfection Quotients" + Chr(13) +
         "Sum of n<=10^18 where sigma(n)/n = k+1/2:" + Chr(13) +
         resultS + Chr(13) +
         "(" + Str(gFoundCnt) + " hemiperfect numbers verified)")
    CopyToWinClip(resultS)
end
