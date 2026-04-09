// eulerproject0261Claude.s
// Project Euler Problem 261: Pivotal Square Sums
//
// Find sum of all distinct square-pivots k <= 10^10.
// k is a square-pivot if there exist m>0, n>=k such that:
//   (k-m)^2+...+k^2 = (n+1)^2+...+(n+m)^2
//
// Algorithm:
//   For each m from 1 to 70710:
//     Factor m -> squarefree part s, square root p.
//     Factor m+1 -> squarefree part g, square root r.
//     D = s * g  (squarefree Pell discriminant).
//     Find fundamental Pell solution (x1,y1): x1^2 - D*y1^2 = 1.
//     Iterate (x,y) starting at (g*r, p) via:
//       x_new = x*x1 + y*y1*D,  y_new = x*y1 + y*x1.
//     Pivot candidate: k = s*p*(p+y)/2  (only if even).
//     Full pivot check:
//       - k even, k <= 10^10, k >= 2*m*(m+1)
//       - t = r*x  (since t=g*r*(x/g) and g|x always)
//       - (t-m-1) must be even; n=(t-m-1)/2 >= k.
//     Dedup via lFind: search buffer for ^k$ before adding.
//     Accumulate gSumS directly; no post-loop summation needed.
//     Break when k > 10^10 and y > p.
//
// Arithmetic: D up to ~5e9 stored as (D_hiX=D/100000, D_loX=D mod 100000).
// x,y,t as big-integer strings (max ~19 digits, within 30-char vars).
// BigMulSmall safe: all multipliers <2^17, digit*mult <2^21 <2^31.
// t = r*x: rval<267, x<5.66e15, product<1.51e18 (19 digits). Fine.
// CF (D-m2^2)/dCF: 2-level 32-bit long division, all <2^27.
//
// Version: 3
// Created by: Claude (Anthropic)
// History:
//   v1 - Claude (Anthropic): Initial solution
//   v2 - Claude (Anthropic): Fixed dedup (lFind instead of sort -k)
//   v3 - Claude (Anthropic): Fixed t computation: t=r*x not r*(x/g).
//        BigDivSmall(xS,gval) was wrong; g*r*(x/g)=r*x so use BigMulSmall(xS,rval).

// ================================================================
// Globals
// ================================================================
integer gD_hi4       // D / 10000   (for isqrt binary search)
integer gD_lo4       // D mod 10000
integer gD_hiX       // D / 100000  (for Pell convergent string check)
integer gD_loX       // D mod 100000
integer gX1          // Pell fundamental x1 (<141422, fits 32-bit)
integer gY1          // Pell fundamental y1 (<9101,  fits 32-bit)
integer gISqrtRes    // floor(sqrt(D))
string gSumS[30]     // running sum of distinct pivot k values

// ================================================================
// Forward declarations
// ================================================================
forward integer proc BigCmpStr(string s1, string s2)
forward string proc BigMulSmall(string s, integer n)
forward string proc BigAdd(string s1, string s2)
forward string proc BigDiv2(string s)
forward integer proc BigMod2(string s)
forward proc BigMulStr100000(var string s)
forward proc SolveISqrtD()
forward proc SquarefreeAndSqrt(integer n, var integer sf, var integer sq)
forward proc PellFundamental()

// ================================================================
// BigCmpStr: compare two non-negative decimal strings.
// Returns -1 / 0 / 1.
// ================================================================
integer proc BigCmpStr(string s1, string s2)
    integer l1, l2, i
    string c1[4], c2[4]
    l1 = Length(s1)
    l2 = Length(s2)
    if l1 < l2
        return(-1)
    endif
    if l1 > l2
        return(1)
    endif
    i = 1
    while i <= l1
        c1 = SubStr(s1, i, 1)
        c2 = SubStr(s2, i, 1)
        if Val(c1) < Val(c2)
            return(-1)
        endif
        if Val(c1) > Val(c2)
            return(1)
        endif
        i = i + 1
    endwhile
    return(0)
end

// ================================================================
// BigMulSmall: multiply decimal string s by integer n < 2^28.
// Each step: digit*n+carry < 2^21 < 2^31. Safe.
// ================================================================
string proc BigMulSmall(string s, integer n)
    integer ln, carry, dig, product, idx
    string res[60]
    string dch[4]
    if n == 0
        return("0")
    endif
    ln = Length(s)
    carry = 0
    res = ""
    idx = ln
    while idx >= 1
        dch = SubStr(s, idx, 1)
        dig = Val(dch)
        product = dig * n + carry
        carry = product / 10
        product = product mod 10
        res = Chr(product + 48) + res
        idx = idx - 1
    endwhile
    while carry > 0
        product = carry mod 10
        carry = carry / 10
        res = Chr(product + 48) + res
    endwhile
    if Length(res) == 0
        res = "0"
    endif
    return(res)
end

// ================================================================
// BigAdd: add two non-negative decimal strings.
// ================================================================
string proc BigAdd(string s1, string s2)
    integer l1, l2, i1, i2, carry, d1, d2, sumD
    string res[60]
    string c1[4], c2[4]
    l1 = Length(s1)
    l2 = Length(s2)
    i1 = l1
    i2 = l2
    carry = 0
    res = ""
    while i1 >= 1 OR i2 >= 1 OR carry > 0
        d1 = 0
        d2 = 0
        if i1 >= 1
            c1 = SubStr(s1, i1, 1)
            d1 = Val(c1)
            i1 = i1 - 1
        endif
        if i2 >= 1
            c2 = SubStr(s2, i2, 1)
            d2 = Val(c2)
            i2 = i2 - 1
        endif
        sumD = d1 + d2 + carry
        carry = sumD / 10
        sumD = sumD mod 10
        res = Chr(sumD + 48) + res
    endwhile
    if Length(res) == 0
        res = "0"
    endif
    return(res)
end

// ================================================================
// BigDiv2: divide decimal string by 2 (floor).
// ================================================================
string proc BigDiv2(string s)
    integer ln, i, rem, dig, quot
    string res[60]
    string dch[4]
    ln = Length(s)
    res = ""
    rem = 0
    i = 1
    while i <= ln
        dch = SubStr(s, i, 1)
        dig = Val(dch)
        quot = (rem * 10 + dig) / 2
        rem = (rem * 10 + dig) mod 2
        if Length(res) > 0 OR quot > 0
            res = res + Chr(quot + 48)
        endif
        i = i + 1
    endwhile
    if Length(res) == 0
        res = "0"
    endif
    return(res)
end

// ================================================================
// BigMod2: return 1 if string is odd, else 0.
// ================================================================
integer proc BigMod2(string s)
    string last[4]
    integer d
    if Length(s) == 0
        return(0)
    endif
    last = SubStr(s, Length(s), 1)
    d = Val(last)
    return(d mod 2)
end

// ================================================================
// BigMulStr100000: multiply string by 100000 (append 5 zeros).
// ================================================================
proc BigMulStr100000(var string s)
    if s == "0"
        return()
    endif
    s = s + "00000"
end

// ================================================================
// SolveISqrtD: binary search for floor(sqrt(D)).
// D from gD_hi4/gD_lo4. Result -> gISqrtRes.
// mid^2: T=2*m2a*m2b*100+m2b^2 <14170000<2^24; sq_hi4<502682<2^19.
// ================================================================
proc SolveISqrtD()
    integer lo, hi, mid
    integer sq_hi4, sq_lo4
    integer D_hi4save, D_lo4save
    integer m2a, m2b, T
    D_hi4save = gD_hi4
    D_lo4save = gD_lo4
    lo = 0
    hi = 70711
    while lo < hi
        mid = (lo + hi + 1) / 2
        m2a = mid / 100
        m2b = mid mod 100
        T = 2 * m2a * m2b * 100 + m2b * m2b
        sq_hi4 = m2a * m2a + T / 10000
        sq_lo4 = T mod 10000
        if sq_hi4 < gD_hi4
            lo = mid
        elseif sq_hi4 > gD_hi4
            hi = mid - 1
        elseif sq_lo4 <= gD_lo4
            lo = mid
        else
            hi = mid - 1
        endif
    endwhile
    gD_hi4 = D_hi4save
    gD_lo4 = D_lo4save
    gISqrtRes = lo
end

// ================================================================
// SquarefreeAndSqrt: trial-divide n (<=70711) into s*q^2.
// Returns squarefree sf, sqrt of square sq.
// ================================================================
proc SquarefreeAndSqrt(integer n, var integer sf, var integer sq)
    integer p, e
    sf = 1
    sq = 1
    p = 2
    while p * p <= n
        if n mod p == 0
            e = 0
            while n mod p == 0
                n = n / p
                e = e + 1
            endwhile
            if e mod 2 == 1
                sf = sf * p
            endif
            e = e / 2
            while e > 0
                sq = sq * p
                e = e - 1
            endwhile
        endif
        if p == 2
            p = 3
        else
            p = p + 2
        endif
    endwhile
    if n > 1
        sf = sf * n
    endif
end

// ================================================================
// PellFundamental: find (x1,y1) with x1^2 - D*y1^2 = 1 via CF.
// D from gD_hi4/gD_lo4 (isqrt) and gD_hiX/gD_loX (convergent check).
// Result: gX1, gY1.
//
// CF step: m2' = dCF*aQ - m2; dCF' = (D-m2'^2)/dCF.
// m2^2 in hi3/lo6: m2=m2a*1000+m2b; T=2*m2a*m2b*1000+m2b^2<142956000<2^28.
//   m2sq_hi3=m2a^2+T/10^6<5185; m2sq_lo6=T mod 10^6.
// D in hi3/lo6: D_hi3=D_hiX/10; D_lo6=(D_hiX mod 10)*100000+D_loX.
// Division (D-m2^2)/dCF: diff_hi3<dCF always.
//   Level-1: comb=diff_hi3*1000+diff_lo6/1000 <5001000<2^23.
//   Level-2: remH*1000+diff_lo6 mod 1000 <70712000<2^27.
// Convergent check: nc^2==D*dc^2+1 via string big-int.
// ================================================================
proc PellFundamental()
    integer a0, m2, dCF, aQ, T
    integer num1, numC, den1, denC
    integer m2a, m2b
    integer m2sq_hi3, m2sq_lo6
    integer D_hi3, D_lo6
    integer diff_hi3, diff_lo6, borrow
    integer combined, remH, qpart, newDcf
    string nc_sq_str[20], dc_sq_str[20], Ddc2_str[30]
    string tmp1S[30], tmp2S[30], checkStr[30]
    string numC_str[10], denC_str[10]

    SolveISqrtD()
    a0 = gISqrtRes
    m2 = 0
    dCF = 1
    aQ = a0
    num1 = 1
    numC = a0
    den1 = 0
    denC = 1
    gX1 = 0
    gY1 = 0

    D_hi3 = gD_hiX / 10
    D_lo6 = (gD_hiX mod 10) * 100000 + gD_loX

    while gX1 == 0
        // Check: numC^2 - D*denC^2 == 1?
        numC_str = Str(numC)
        denC_str = Str(denC)
        nc_sq_str = BigMulSmall(numC_str, numC)
        dc_sq_str = BigMulSmall(denC_str, denC)
        tmp1S = BigMulSmall(dc_sq_str, gD_hiX)
        BigMulStr100000(tmp1S)
        tmp2S = BigMulSmall(dc_sq_str, gD_loX)
        Ddc2_str = BigAdd(tmp1S, tmp2S)
        checkStr = BigAdd(Ddc2_str, "1")
        if BigCmpStr(nc_sq_str, checkStr) == 0
            gX1 = numC
            gY1 = denC
        else
            // dCF*aQ <70711*531=37547541<2^26
            m2 = dCF * aQ - m2
            m2a = m2 / 1000
            m2b = m2 mod 1000
            T = 2 * m2a * m2b * 1000 + m2b * m2b
            m2sq_hi3 = m2a * m2a + T / 1000000
            m2sq_lo6 = T mod 1000000
            diff_lo6 = D_lo6 - m2sq_lo6
            borrow = 0
            if diff_lo6 < 0
                diff_lo6 = diff_lo6 + 1000000
                borrow = 1
            endif
            diff_hi3 = D_hi3 - m2sq_hi3 - borrow
            combined = diff_hi3 * 1000 + diff_lo6 / 1000
            remH = combined mod dCF
            qpart = (combined / dCF) * 1000
            combined = remH * 1000 + diff_lo6 mod 1000
            newDcf = qpart + combined / dCF
            dCF = newDcf
            // a0+m2 < 141422 < 2^17
            aQ = (a0 + m2) / dCF
            // aQ*numC < 531*141421 < 2^27
            T = aQ * numC + num1
            num1 = numC
            numC = T
            T = aQ * denC + den1
            den1 = denC
            denC = T
        endif
    endwhile
end

// ================================================================
// Main
// ================================================================
proc Main()
    integer m, mmax
    integer sfM, sqM, sfM1, sqM1
    integer sval, pval, gval, rval
    integer D_hiX, D_loX, D_hi4, D_lo4
    integer sv_hi, sv_lo, carryD
    integer tParity, mParity, iterDone
    string kStr[20], limitStr[20], m2m1Str[20], pStr[10]
    string xS[30], yS[30], xnS[30], ynS[30]
    string tmpAS[60], tmpBS[60], tmpCS[60]
    string numeratorStr[20], tStr[30], threshStr[30]
    string searchPat[25]
    integer kBufId

    limitStr = "10000000000"   // 10^10
    mmax = 70710

    // Buffer stores k values for dedup via lFind
    kBufId = CreateTempBuffer()
    GotoBufferId(kBufId)
    EmptyBuffer()

    gSumS = "0"

    m = 1
    while m <= mmax

        // Factor m -> squarefree sval, sqrt pval
        SquarefreeAndSqrt(m, sfM, sqM)
        sval = sfM
        pval = sqM

        // Factor m+1 -> squarefree gval, sqrt rval
        SquarefreeAndSqrt(m + 1, sfM1, sqM1)
        gval = sfM1
        rval = sqM1

        // Compute D = sval*gval as (D_hiX, D_loX) base 100000.
        // sv_hi*gval < 71*70711 = 5020481 < 2^23  (no overflow)
        // sv_lo*gval < 1000*70711 = 70711000 < 2^27  (no overflow)
        // carryD < 100000; carryD+sv_lo*gval < 70811000 < 2^27
        sv_hi = sval / 1000
        sv_lo = sval mod 1000
        carryD = (sv_hi * gval mod 100) * 1000
        D_loX = (carryD + sv_lo * gval) mod 100000
        D_hiX = sv_hi * gval / 100 + (carryD + sv_lo * gval) / 100000
        gD_hiX = D_hiX
        gD_loX = D_loX
        D_hi4 = D_hiX * 10 + D_loX / 10000
        D_lo4 = D_loX mod 10000
        gD_hi4 = D_hi4
        gD_lo4 = D_lo4

        // Find Pell fundamental solution (x1, y1)
        PellFundamental()

        // Initial Pell point: (x,y) = (gval*rval, pval)
        // gval*rval <= 70711*267 = 18879837 < 2^25  (Str() safe)
        xS = Str(gval * rval)
        yS = Str(pval)
        pStr = Str(pval)

        // 2*m*(m+1) as string; m*(m+1) > 2^31 for large m
        m2m1Str = BigMulSmall(Str(m), m + 1)
        m2m1Str = BigMulSmall(m2m1Str, 2)

        iterDone = 0
        while iterDone == 0

            // numeratorStr = sval * pval * (pval + y)
            tmpAS = BigAdd(pStr, yS)
            tmpAS = BigMulSmall(tmpAS, pval)
            numeratorStr = BigMulSmall(tmpAS, sval)

            kStr = BigDiv2(numeratorStr)

            // Pivot check: even, k<=limit, k>=2*m*(m+1)
            if BigMod2(numeratorStr) == 0
                if BigCmpStr(kStr, limitStr) <= 0
                    if BigCmpStr(kStr, m2m1Str) >= 0
                        // Compute t = r * x.
                        // Derivation: t = g*r*(x/g) = r*x  (since g|x always).
                        // rval < 267 < 2^9; x < 5.66e15; rval*x < 1.51e18 (19 digits).
                        tStr = BigMulSmall(xS, rval)
                        // Check (t-m-1) even: t%2 must equal (m+1)%2
                        tParity = BigMod2(tStr)
                        mParity = (m + 1) mod 2
                        if tParity == mParity
                            // Check n=(t-m-1)/2 >= k, i.e., t >= 2k+m+1 = numerator+(m+1)
                            threshStr = BigAdd(numeratorStr, Str(m + 1))
                            if BigCmpStr(tStr, threshStr) >= 0
                                // Dedup: lFind searches buffer for exact line match
                                searchPat = "^" + kStr + "$"
                                GotoBufferId(kBufId)
                                BegFile()
                                if NOT lFind(searchPat, "gx")
                                    gSumS = BigAdd(gSumS, kStr)
                                    EndFile()
                                    AddLine(kStr)
                                endif
                            endif
                        endif
                    endif
                endif
            endif

            // Break: k > limit AND y > p
            if BigCmpStr(kStr, limitStr) > 0 AND BigCmpStr(yS, pStr) > 0
                iterDone = 1
            else
                // Advance Pell
                // y_new = x*y1 + y*x1
                tmpAS = BigMulSmall(xS, gY1)
                tmpBS = BigMulSmall(yS, gX1)
                ynS = BigAdd(tmpAS, tmpBS)
                // x_new = x*x1 + y*y1*D
                // Split D as D_hiX*100000 + D_loX; both <2^17, safe multipliers
                tmpAS = BigMulSmall(yS, gY1)          // y*y1
                tmpBS = BigMulSmall(tmpAS, gD_hiX)    // y*y1*D_hiX
                BigMulStr100000(tmpBS)                // *100000
                tmpCS = BigMulSmall(tmpAS, gD_loX)    // y*y1*D_loX
                tmpAS = BigAdd(tmpBS, tmpCS)           // y*y1*D
                tmpBS = BigMulSmall(xS, gX1)          // x*x1
                xnS = BigAdd(tmpAS, tmpBS)

                xS = xnS
                yS = ynS
            endif

        endwhile

        m = m + 1
    endwhile

    // gSumS holds the correct sum of all distinct pivot k values
    CopyToWinClip(gSumS)
    Warn("Project Euler 261 - Pivotal Square Sums" + Chr(13) +
         "Sum of all distinct square-pivots <= 10^10:" + Chr(13) +
         gSumS)
    CopyToWinClip(gSumS)

    AbandonFile(kBufId)
end
