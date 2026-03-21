// P153.s
// Project Euler Problem 153: Investigating Gaussian Integers
//
// For n = 1 to 10^8, compute Sum s(n) where s(n) is the sum of the
// real parts of all Gaussian integer divisors a+bi (a>0) of n.
//
// Algorithm (Moebius inversion, no GCD needed in inner loops):
//   Total = S(N) + 2 * Sum_{d: mu(d)!=0, d<=sqrt(N)} mu(d)*d*f(floor(N/d^2))
//   f(M) = Sum_{a<b, a^2+b^2<=M} (a+b)*S(floor(M/(a^2+b^2)))
//         + Sum_{a=1}^{floor(sqrt(M/2))} a * S(floor(M/(2*a^2)))
//   S(K) = Sum_{n=1}^{K} sigma(n) computed via O(sqrt(K)) hyperbola:
//          S(K) = Sum_{a=1}^{U} a*floor(K/a) + Sum_{b=1}^{U} T(floor(K/b)) - U*T(U)
//          where U = floor(sqrt(K)), T(M) = M*(M+1)/2
//
// Precomputed lookup tables (to avoid per-pair computation):
//   gSmSBufI : S(K) for K = 0..SQRTN_C, one line per K: "loVal hiVal"
//   gLgSBufI : S(floor(N/t)) for t = 1..LP_MAX, one line per t: "loVal hiVal"
// Coverage: t_val = d^2*(a^2+b^2). If t_val <= LP_MAX: use gLgSBufI[t_val].
//           If t_val > LP_MAX: K = floor(M/m) < SQRTN_C, use gSmSBufI[K].
//
// 64-bit arithmetic: value = hi*BIL + lo, BIL = 10^9, lo in [0, BIL-1]
//
// <version>1.0.0.0.1</version>
// Created by: Claude Sonnet 4.6 (Anthropic)
// History:
//   1.0.0.0.1  2026-03-21  Initial version by Claude Sonnet 4.6 (Anthropic)
//===========================================================================

CONSTANT N_LIM   = 100000000   // N = 10^8
CONSTANT SQRTN_C = 10001       // ceil(sqrt(N)) + safety margin
CONSTANT BIL     = 1000000000  // 10^9 -- base for 64-bit hi/lo split
CONSTANT LP_MAX  = 10000       // large-S precompute threshold

integer gMuBufI  = 0  // Moebius mu(d): line d+1 = mu(d), d=1..10000
integer gSmSBufI = 0  // Small-S table: line K+1 = "lo hi", K=0..SQRTN_C
integer gLgSBufI = 0  // Large-S table: line t+1 = "lo hi", t=1..LP_MAX

// =========================================================================
// INTEGER SQUARE ROOT  floor(sqrt(n))
// =========================================================================
INTEGER PROC IntSqrt(INTEGER nArgI)
    INTEGER xI, xnI
    if nArgI <= 0
        return( 0 )
    endif
    xI  = 32768  // safe upper bound for sqrt(n) with n <= 10^9
    xnI = (xI + nArgI / xI) / 2
    while xnI < xI
        xI  = xnI
        xnI = (xI + nArgI / xI) / 2
    endwhile
    // Adjust down if overshoot (rare with Newton)
    while xI * xI > nArgI
        xI = xI - 1
    endwhile
    return( xI )
END

// =========================================================================
// 64-BIT ARITHMETIC  value = hi*BIL + lo
// =========================================================================

// (lo1,hi1) += (lo2,hi2)
PROC Add64(var INTEGER lo1I, var INTEGER hi1I, INTEGER lo2I, INTEGER hi2I)
    lo1I = lo1I + lo2I
    if lo1I >= BIL
        lo1I = lo1I - BIL
        hi1I = hi1I + 1
    endif
    hi1I = hi1I + hi2I
END

// (lo1,hi1) -= (lo2,hi2)
PROC Sub64(var INTEGER lo1I, var INTEGER hi1I, INTEGER lo2I, INTEGER hi2I)
    lo1I = lo1I - lo2I
    if lo1I < 0
        lo1I = lo1I + BIL
        hi1I = hi1I - 1
    endif
    hi1I = hi1I - hi2I
END

// (loI,hiI) *= kI   [kI <= 20000, result stays within 32-bit per problem bounds]
PROC Mul64Small(INTEGER kI, var INTEGER loI, var INTEGER hiI)
    INTEGER aI, bI, kaI, cAI, laI, kbI, slI, clI
    aI  = loI / 10000          // [0..99999]
    bI  = loI mod 10000        // [0..9999]
    kaI = kI * aI              // kI<=20000, aI<=99999: product<2^31 OK
    cAI = kaI / 100000         // [0..19999]
    laI = (kaI mod 100000) * 10000  // [0..999990000]
    kbI = kI * bI              // kI<=20000, bI<=9999: product<2^31 OK
    slI = laI + kbI            // [0..1199970000] < 2*10^9 < 2^31 OK
    clI = slI / BIL            // 0 or 1
    loI = slI mod BIL
    hiI = kI * hiI + cAI + clI // bounded by problem analysis (<=10^7)
END

// (fLoI,fHiI) += pI * (sLoI,sHiI)   [pI = a+b <= ~20000]
PROC AccumP(INTEGER pI, var INTEGER fLoI, var INTEGER fHiI,
            INTEGER sLoI, INTEGER sHiI)
    INTEGER aI, bI, paI, cAI, laI, pbI, slI, clI, hpI
    aI  = sLoI / 10000         // [0..99999]
    bI  = sLoI mod 10000       // [0..9999]
    paI = pI * aI              // pI<=20000, aI<=99999: product<=1999980000<2^31 OK
    cAI = paI / 100000         // [0..19999]
    laI = (paI mod 100000) * 10000  // [0..999990000]
    pbI = pI * bI              // pI<=20000, bI<=9999: product<=199980000<2^31 OK
    slI = laI + pbI            // [0..1199970000] < 2^31 OK
    clI = slI / BIL            // 0 or 1
    slI = slI mod BIL
    hpI = pI * sHiI + cAI + clI   // bounded per analysis (<=a few million)
    fLoI = fLoI + slI
    if fLoI >= BIL
        fLoI = fLoI - BIL
        hpI  = hpI + 1
    endif
    fHiI = fHiI + hpI
END

// =========================================================================
// T(M) = M*(M+1)/2  as 64-bit (tLoI, tHiI)   [M <= 10^8]
// =========================================================================
PROC CalcT64(INTEGER MI, var INTEGER tLoI, var INTEGER tHiI)
    INTEGER MhI, MlI, AI, BI, CI, BpI, CpI, BhI, BlI, loI, hiI
    if MI <= 0
        tLoI = 0
        tHiI = 0
        return()
    endif
    MhI = MI / 10000           // [0..10000]
    MlI = MI mod 10000         // [0..9999]
    AI  = MhI * MhI            // [0..10^8]  M^2 high coeff
    BI  = 2 * MhI * MlI        // [0..2*10^8] M^2 cross coeff
    CI  = MlI * MlI            // [0..10^8]  M^2 low coeff
    // M*(M+1) = M^2 + M = A*10^8 + (B+Mh)*10^4 + (C+Ml)
    BpI = BI + MhI             // [0..~2*10^8]
    CpI = CI + MlI             // [0..~10^8]
    loI = CpI
    hiI = 0
    // Add BpI * 10^4:
    BhI = BpI / 100000         // [0..2000]
    BlI = BpI mod 100000       // [0..99999]
    loI = loI + BlI * 10000    // BlI*10^4 <= 999990000; sum <= ~10^9
    hiI = hiI + BhI
    if loI >= BIL
        loI = loI - BIL
        hiI = hiI + 1
    endif
    // Add AI * 10^8:
    loI = loI + (AI mod 10) * 100000000   // <= 9*10^8
    hiI = hiI + AI / 10
    if loI >= BIL
        loI = loI - BIL
        hiI = hiI + 1
    endif
    // (loI,hiI) = M*(M+1)  -- always even. Divide by 2:
    tHiI = hiI / 2
    tLoI = loI / 2 + (hiI mod 2) * 500000000
END

// =========================================================================
// S(K) = Sum_{n=1}^{K} sigma(n)  [64-bit, O(sqrt(K)) hyperbola method]
// S(K) = Sum_{a=1}^{U} a*floor(K/a) + Sum_{b=1}^{U} T(floor(K/b)) - U*T(U)
// where U = floor(sqrt(K))
// =========================================================================
PROC CalcS64(INTEGER KI, var INTEGER sLoI, var INTEGER sHiI)
    INTEGER UI, aI, bI, MI, termI, tLoI, tHiI
    sLoI = 0
    sHiI = 0
    if KI <= 0
        return()
    endif
    UI = IntSqrt(KI)
    // First sum: each term a*floor(K/a) <= K <= 10^8, fits in 32-bit
    for aI = 1 to UI
        termI = aI * (KI / aI)
        sLoI = sLoI + termI
        if sLoI >= BIL
            sLoI = sLoI - BIL
            sHiI = sHiI + 1
        endif
    endfor
    // Second sum: T(floor(K/b)) added in 64-bit
    for bI = 1 to UI
        MI = KI / bI
        CalcT64(MI, tLoI, tHiI)
        Add64(sLoI, sHiI, tLoI, tHiI)
    endfor
    // Subtract U*T(U)
    CalcT64(UI, tLoI, tHiI)
    Mul64Small(UI, tLoI, tHiI)
    Sub64(sLoI, sHiI, tLoI, tHiI)
END

// =========================================================================
// BUFFER HELPERS: get S value from precomputed buffer
// Buffers store "loVal hiVal" on each line (space-separated)
// =========================================================================

// Get S(K) from small-S buffer (K <= SQRTN_C)
PROC GetSmallS(INTEGER KI, var INTEGER sLoI, var INTEGER sHiI)
    STRING lineS[40]
    GotoBufferId(gSmSBufI)
    GotoLine(KI + 1)
    lineS = GetText(1, CurrLineLen())
    sLoI = Val(GetToken(lineS, " ", 1))
    sHiI = Val(GetToken(lineS, " ", 2))
END

// Get S(floor(N/tI)) from large-S buffer (tI = 1..LP_MAX)
PROC GetLargeS(INTEGER tI, var INTEGER sLoI, var INTEGER sHiI)
    STRING lineS[40]
    GotoBufferId(gLgSBufI)
    GotoLine(tI + 1)
    lineS = GetText(1, CurrLineLen())
    sLoI = Val(GetToken(lineS, " ", 1))
    sHiI = Val(GetToken(lineS, " ", 2))
END

// =========================================================================
// PRECOMPUTE SMALL-S TABLE: S(K) for K = 0..SQRTN_C
// =========================================================================
PROC PrecomputeSmallS()
    INTEGER KI, sLoI, sHiI
    gSmSBufI = CreateTempBuffer()
    GotoBufferId(gSmSBufI)
    for KI = 0 to SQRTN_C
        CalcS64(KI, sLoI, sHiI)
        AddLine(Str(sLoI) + " " + Str(sHiI))
    endfor
END

// =========================================================================
// PRECOMPUTE LARGE-S TABLE: S(floor(N/t)) for t = 1..LP_MAX
// =========================================================================
PROC PrecomputeLargeS()
    INTEGER tI, KI, sLoI, sHiI
    gLgSBufI = CreateTempBuffer()
    GotoBufferId(gLgSBufI)
    AddLine("0 0")   // line 1 = placeholder (index 0 unused)
    for tI = 1 to LP_MAX
        KI = N_LIM / tI
        CalcS64(KI, sLoI, sHiI)
        AddLine(Str(sLoI) + " " + Str(sHiI))
    endfor
END

// =========================================================================
// MOEBIUS SIEVE: compute mu(d) for d = 1..10000
// gMuBufI: line d+1 = mu(d) as string, d = 1..10000
// Method: prime sieve + multiplicative Moebius update
// =========================================================================
PROC SieveMu()
    INTEGER dI, pI, kI, muVI, p2I
    INTEGER primBufI
    // --- Build prime sieve up to SQRTN_C ---
    primBufI = CreateTempBuffer()
    GotoBufferId(primBufI)
    // Lines 1..SQRTN_C+2: line n+1 = is_prime(n), n=0..SQRTN_C+1
    for dI = 0 to SQRTN_C + 1
        AddLine("1")
    endfor
    // 0 and 1 are not prime
    GotoLine(1) BegLine() KillToEol() InsertText("0")
    GotoLine(2) BegLine() KillToEol() InsertText("0")
    for pI = 2 to IntSqrt(SQRTN_C)
        GotoBufferId(primBufI)
        GotoLine(pI + 1)
        if Val(GetText(1, CurrLineLen())) == 1
            kI = pI * pI
            while kI <= SQRTN_C
                GotoLine(kI + 1)
                BegLine() KillToEol() InsertText("0")
                kI = kI + pI
            endwhile
        endif
    endfor
    // --- Build Moebius values in gMuBufI ---
    gMuBufI = CreateTempBuffer()
    GotoBufferId(gMuBufI)
    AddLine("0")   // line 1 = mu(0) placeholder
    for dI = 1 to SQRTN_C
        AddLine("1")   // mu(dI) = 1 initially
    endfor
    // For each prime p: flip sign of mu[kp] for all multiples,
    // then zero mu[k*p^2] for all multiples of p^2
    for pI = 2 to SQRTN_C
        GotoBufferId(primBufI)
        GotoLine(pI + 1)
        if Val(GetText(1, CurrLineLen())) == 1
            // Flip sign for all multiples of pI
            kI = pI
            while kI <= SQRTN_C
                GotoBufferId(gMuBufI)
                GotoLine(kI + 1)
                muVI = Val(GetText(1, CurrLineLen()))
                if muVI <> 0
                    BegLine() KillToEol() InsertText(Str(-muVI))
                endif
                kI = kI + pI
            endwhile
            // Zero all multiples of pI^2
            p2I = pI * pI
            if p2I <= SQRTN_C
                kI = p2I
                while kI <= SQRTN_C
                    GotoBufferId(gMuBufI)
                    GotoLine(kI + 1)
                    BegLine() KillToEol() InsertText("0")
                    kI = kI + p2I
                endwhile
            endif
        endif
    endfor
    AbandonFile(primBufI)
END

// =========================================================================
// COMPUTE f(MI, dSqI):
//   f(M) = Sum_{a=1}^{sqrt(M/2)} a * S(floor(M/(2*a^2)))           [a=b case]
//        + Sum_{1<=a<b, a^2+b^2<=M} (a+b) * S(floor(M/(a^2+b^2))) [a<b case]
//
//   For S lookup: t_val = dSqI * m_ab
//     if t_val <= LP_MAX : K = floor(N/t_val), use gLgSBufI[t_val]
//     else               : K = floor(M/m_ab) <= SQRTN_C, use gSmSBufI[K]
//
//   dSqI = d*d (passed from caller so we can compute t_val without knowing d)
// =========================================================================
PROC FuncF(INTEGER MI, INTEGER dSqI, var INTEGER fLoI, var INTEGER fHiI)
    INTEGER aI, bI, sqHI, sqMaI, mAbI, tValI, KI, sLoI, sHiI
    fLoI = 0
    fHiI = 0
    if MI < 2
        return()
    endif
    sqHI = IntSqrt(MI / 2)
    // --- a = b terms: m_ab = 2*a^2 ---
    for aI = 1 to sqHI
        mAbI  = 2 * aI * aI
        tValI = dSqI * mAbI
        if tValI <= LP_MAX
            GetLargeS(tValI, sLoI, sHiI)
        else
            KI = MI / mAbI
            GetSmallS(KI, sLoI, sHiI)
        endif
        AccumP(aI, fLoI, fHiI, sLoI, sHiI)
    endfor
    // --- a < b terms: m_ab = a^2 + b^2 ---
    for aI = 1 to sqHI
        sqMaI = IntSqrt(MI - aI * aI)
        for bI = aI + 1 to sqMaI
            mAbI  = aI * aI + bI * bI
            tValI = dSqI * mAbI
            if tValI <= LP_MAX
                GetLargeS(tValI, sLoI, sHiI)
            else
                KI = MI / mAbI
                GetSmallS(KI, sLoI, sHiI)
            endif
            AccumP(aI + bI, fLoI, fHiI, sLoI, sHiI)
        endfor
    endfor
END

// =========================================================================
// MAIN
// =========================================================================
PROC Main()
    INTEGER dI, dSqI, muDI, MI
    INTEGER fLoI, fHiI, sLoI, sHiI
    INTEGER totLoI, totHiI
    STRING  resultS[255]
    STRING  lineS[40]
    //
    totLoI = 0
    totHiI = 0
    //
    // Step 1: Precompute S(K) for K = 0..SQRTN_C
    Message("P153: Precomputing small S table (K=0.." + Str(SQRTN_C) + ")...")
    PrecomputeSmallS()
    //
    // Step 2: Precompute S(floor(N/t)) for t = 1..LP_MAX
    Message("P153: Precomputing large S table (t=1.." + Str(LP_MAX) + ")...")
    PrecomputeLargeS()
    //
    // Step 3: Compute Moebius function mu(d) for d=1..10000
    Message("P153: Computing Moebius sieve...")
    SieveMu()
    //
    // Step 4: Add S(N) to total (the rational integer contribution)
    Message("P153: Computing S(N)...")
    CalcS64(N_LIM, sLoI, sHiI)
    Add64(totLoI, totHiI, sLoI, sHiI)
    //
    // Step 5: Moebius sum  Total += 2 * Sum_{d,mu(d)!=0} mu(d)*d * f(floor(N/d^2))
    Message("P153: Main computation (d=1..10000)...")
    for dI = 1 to 10000
        dSqI = dI * dI
        if dSqI <= N_LIM
            GotoBufferId(gMuBufI)
            GotoLine(dI + 1)
            lineS = GetText(1, CurrLineLen())
            muDI = Val(lineS)
            if muDI <> 0
                MI = N_LIM / dSqI
                FuncF(MI, dSqI, fLoI, fHiI)
                // Scale: (fLoI,fHiI) *= d, then *= 2
                Mul64Small(dI, fLoI, fHiI)
                Mul64Small(2, fLoI, fHiI)
                // Add or subtract based on mu(d)
                if muDI == 1
                    Add64(totLoI, totHiI, fLoI, fHiI)
                else
                    Sub64(totLoI, totHiI, fLoI, fHiI)
                endif
            endif
        endif
    endfor
    //
    // Step 6: Format and display result
    // Answer = totHiI * 10^9 + totLoI
    if totHiI > 0
        resultS = Str(totHiI) + Format(totLoI:9:"0")
    else
        resultS = Str(totLoI)
    endif
    //
    Warn("P153 - Investigating Gaussian Integers" + Chr(13) +
         "Sum of s(n) for n=1..10^8:" + Chr(13) + Chr(13) +
         resultS)
    CopyToWinClip(resultS)
END
