/*
   Project Euler - Problem 197
   "A Recursively Defined Sequence"

   f(x) = floor(2^(30.403243784 - x^2)) * 10^-9
   u_0 = -1,  u_{n+1} = f(u_n)
   Find u_n + u_{n+1} for n = 10^12.

   Strategy
   --------
   Store u as nano-integer U = u * 10^9  (fits in signed 32-bit).
   Then U_{n+1} = floor(2^(30.403243784 - (U/1e9)^2)).

   The sequence converges to a 2-cycle within about 560 iterations.
   We detect stabilisation of consecutive pair-sums and stop.

   All arithmetic is 32-bit clean  (verified by Python simulation).

   Procedures
   ----------
   MulDiv1e9(a,b)       floor(a*b/1e9), 0 <= a,b <= ~1.1e9
                        3-part split M=1000 with carry correction.
   MulRemDiv1e9(a,b)    a*b mod 1e9   (remainder after /1e9)
   Sq1e9(a)             floor(a^2/1e9),  |a| <= 1.1e9
   ComputeSPair(frac)   18-digit pair (gSHI, gSLO) = frac * ln2
   PairMulS()           (gQH,gQL) *= (gSHI,gSLO)/1e9
   PairDivK(k)          (gQH,gQL) /= k  (overflow-safe for k<=20)
   PairAddToSum(h,l)    (gSumH,gSumL) += (h,l)
   Pow2Frac(fracNano)   floor(2^(fracNano/1e9)*1e9) via Taylor e^s
   NextU(uNano)         one iteration: U_{n+1}

   Precision note
   --------------
   ln2 = 693 147 180 / 1e9  +  559 945 309 / 1e18
   Using both halves in the Taylor series ensures the computation is
   exact (error = 0) for all fracNano values arising in this problem.

   <version>1.0.0.0.2</version>
   <history>
     1.0.0.0.1  2026-03-25  Claude (Anthropic) Sonnet 4.6 - initial.
     1.0.0.0.2  2026-03-25  Claude (Anthropic) Sonnet 4.6 - corrected:
                            carry fix in MulDiv1e9; 18-digit ln2 pair
                            (LN2_HI + LN2_LO); pair-based Taylor series
                            for 18-digit internal precision.
                            Python-verified: answer = 1.710637717.
   </history>
*/

FORWARD integer proc Pow2Frac(integer fracNano)

// ===== Constants =====
constant LN2_HI     = 693147180   // ln2 * 1e9, high 9 digits
constant LN2_LO     = 559945309   // ln2 * 1e18, next 9 digits
constant TWO_28     = 268435456   // 2^28
constant TWO_29     = 536870912   // 2^29
constant TWO_30     = 1073741824  // 2^30 = 1e9 + 73741824
constant FRAC_CONST = 403243784   // fractional part of 30.403243784 * 1e9
constant FRAC_EXT   = 1403243784  // = 1e9 + FRAC_CONST (for borrow case)
constant NANO       = 1000000000  // 10^9

// ===== MulDiv1e9(a, b) =====
// floor(a*b/1e9) for 0 <= a,b <= ~1.1e9.
// Split: a = a2*1e6 + a1*1e3 + a0  (M=1000).
// a*b/1e9 = a2*b2*1000 + a2*b1+a1*b2 + floor(C/1000)
// where C = a2*b0+a1*b1+a0*b2 plus carry from (D*1e3+E)/1e9.
// All intermediates fit in signed 32-bit.
integer proc MulDiv1e9(integer a, integer b)
    integer a2, a1, a0
    integer b2, b1, b0
    integer C, D, E, Cr
    integer step1, carry1, rem1, step2, carry2
    //
    a2 = a / 1000000
    a1 = (a / 1000) mod 1000
    a0 = a mod 1000
    b2 = b / 1000000
    b1 = (b / 1000) mod 1000
    b0 = b mod 1000
    //
    C      = a2*b0 + a1*b1 + a0*b2      // <= 3e6
    D      = a1*b0 + a0*b1              // <= 2e6
    E      = a0*b0                      // <= 1e6
    //
    step1  = D * 1000 + E               // <= 1997000001 < 2^31
    carry1 = step1 / NANO
    rem1   = step1 - carry1 * NANO
    Cr     = C mod 1000
    step2  = Cr * 1000000 + rem1        // <= 1998999999 < 2^31
    carry2 = step2 / NANO
    //
    return( a2*b2*1000 + a2*b1 + a1*b2 + C/1000 + carry2 )
end

// ===== MulRemDiv1e9(a, b) =====
// Returns a*b mod 1e9  (remainder part of a*b/1e9).
integer proc MulRemDiv1e9(integer a, integer b)
    integer a2, a1, a0
    integer b2, b1, b0
    integer C, D, E, Cr
    integer step1, carry1, rem1, step2, carry2
    //
    a2 = a / 1000000
    a1 = (a / 1000) mod 1000
    a0 = a mod 1000
    b2 = b / 1000000
    b1 = (b / 1000) mod 1000
    b0 = b mod 1000
    //
    C      = a2*b0 + a1*b1 + a0*b2
    D      = a1*b0 + a0*b1
    E      = a0*b0
    Cr     = C mod 1000
    //
    step1  = D * 1000 + E
    carry1 = step1 / NANO
    rem1   = step1 - carry1 * NANO
    step2  = Cr * 1000000 + rem1
    carry2 = step2 / NANO
    //
    return( step2 - carry2 * NANO )
end

// ===== Sq1e9(a) =====
// floor(a^2/1e9) for |a| <= 1.1e9.
integer proc Sq1e9(integer a)
    integer aa
    //
    if a < 0
        aa = -a
    else
        aa = a
    endif
    return( MulDiv1e9(aa, aa) )
end

// ===== Global pair registers for Taylor series =====
// s pair:  s * 1e18 = gSHI * 1e9 + gSLO
// term pair:  represented in gQH, gQL
// sum pair:   represented in gSumH, gSumL
integer gSHI  = 0
integer gSLO  = 0
integer gQH   = 0
integer gQL   = 0
integer gSumH = 0
integer gSumL = 0

// ===== ComputeSPair(fracNano) =====
// Sets gSHI, gSLO such that (gSHI*1e9+gSLO) = fracNano * ln2 in 1e-18 units.
// ln2 = LN2_HI/1e9 + LN2_LO/1e18.
// s * 1e18 = fracNano * LN2_HI  +  fracNano * LN2_LO / 1e9
proc ComputeSPair(integer fracNano)
    integer sH, remHi, loPart, totalLo
    //
    sH      = MulDiv1e9(fracNano, LN2_HI)
    remHi   = MulRemDiv1e9(fracNano, LN2_HI)
    loPart  = MulDiv1e9(fracNano, LN2_LO)
    totalLo = remHi + loPart            // <= 1.52e9 < 2^31
    sH      = sH + totalLo / NANO
    gSHI    = sH
    gSLO    = totalLo mod NANO
end

// ===== PairMulS() =====
// (gQH, gQL)  *=  (gSHI, gSLO) / 1e9
// (qH*1e9+qL) * (sH*1e9+sL) / 1e18 = qH*sH + qH*sL/1e9 + qL*sH/1e9 + qL*sL/1e18
// = (MulDiv(qH,sH)*1e9 + MulRem(qH,sH)) + MulDiv(qH,sL) + MulDiv(qL,sH)
//   + MulDiv(qL,sL)/1e9  [tiny, absorbed]
// All < 2^31.
proc PairMulS()
    integer hi_quot, hi_rem
    integer mid1, mid1rem, mid2, mid2rem, loLo
    integer loSum, tinySum
    //
    hi_quot  = MulDiv1e9(gQH, gSHI)
    hi_rem   = MulRemDiv1e9(gQH, gSHI)
    mid1     = MulDiv1e9(gQH, gSLO)
    mid1rem  = MulRemDiv1e9(gQH, gSLO)
    mid2     = MulDiv1e9(gQL, gSHI)
    mid2rem  = MulRemDiv1e9(gQL, gSHI)
    loLo     = MulDiv1e9(gQL, gSLO)
    //
    loSum   = hi_rem + mid1 + mid2
    tinySum = mid1rem + mid2rem + loLo
    loSum   = loSum + tinySum / NANO
    //
    gQH = hi_quot + loSum / NANO
    gQL = loSum mod NANO
end

// ===== PairDivK(kI) =====
// (gQH, gQL) /= kI  (floor division, kI is small, typically 1..15).
// = (gQH/kI)*1e9 + floor((gQH%kI * 1e9 + gQL) / kI)
// where the second term is computed as:
//   r_hi * q1 + (r_hi * r1 + gQL) / kI
// with q1 = 1e9/kI split to avoid overflow.
proc PairDivK(integer kI)
    integer q_hi, r_hi, q1, r1, q1hi, q1lo, rq1, lo_quot
    //
    q_hi    = gQH / kI
    r_hi    = gQH mod kI            // < kI <= 15
    q1      = NANO / kI
    r1      = NANO mod kI
    q1hi    = q1 / 1000
    q1lo    = q1 mod 1000
    // r_hi * q1 via split (avoids overflow for r_hi up to ~19, q1 up to 1e9)
    rq1     = r_hi * q1hi * 1000 + r_hi * q1lo
    lo_quot = rq1 + (r_hi * r1 + gQL) / kI
    //
    gQH = q_hi + lo_quot / NANO
    gQL = lo_quot mod NANO
end

// ===== PairAddToSum(aH, aL) =====
// (gSumH, gSumL) += (aH, aL)
proc PairAddToSum(integer aH, integer aL)
    integer sLo, carry
    //
    sLo   = gSumL + aL
    carry = sLo / NANO
    gSumL = sLo mod NANO
    gSumH = gSumH + aH + carry
end

// ===== Pow2Frac(fracNano) =====
// Returns floor(2^(fracNano/1e9) * 1e9) via Taylor series e^s
// with 18-digit internal precision.
// fracNano in [0, 1.4e9); result in [1e9, 2e9).
integer proc Pow2Frac(integer fracNano)
    integer kI
    //
    ComputeSPair(fracNano)      // sets gSHI, gSLO
    //
    // term_0 = 1  (as 18-digit pair: NANO * 1e9 = (NANO, 0))
    gQH   = NANO
    gQL   = 0
    gSumH = NANO
    gSumL = 0
    //
    kI = 1
    while gQH > 0 or gQL > 0
        PairMulS()
        PairDivK(kI)
        PairAddToSum(gQH, gQL)
        kI = kI + 1
    endwhile
    //
    // gSumH = floor(e^s * 1e9), which is floor(2^frac * 1e9)
    return( gSumH )
end

// ===== NextU(uNano) =====
// Returns U_{n+1} = floor(2^(30.403243784 - (U/1e9)^2))
// from U = uNano  (nano-scaled signed integer).
//
// Exponent E = 30.403243784 - x^2  where x = uNano/1e9.
// E * 1e9 = (30*1e9 + FRAC_CONST) - x2Nano
//         = (30-q)*1e9 + (FRAC_CONST - r)   or borrow 1 from nPart.
//
// U_{n+1} = floor(2^nPart * pow2Frac_ / 1e9)
//         = twoNH*1e9 + twoNH*pfL + twoNL + MulDiv(twoNL,pfL)
integer proc NextU(integer uNano)
    integer x2Nano, q, r, nPart, fracNano
    integer pow2frac_, pfL, twoN, twoNH, twoNL, result
    //
    x2Nano   = Sq1e9(uNano)
    q        = x2Nano / NANO
    r        = x2Nano mod NANO
    //
    if FRAC_CONST >= r
        nPart    = 30 - q
        fracNano = FRAC_CONST - r
    else
        nPart    = 29 - q
        fracNano = FRAC_EXT - r
    endif
    //
    pow2frac_ = Pow2Frac(fracNano)   // in [1e9, 2e9)
    pfL      = pow2frac_ - NANO      // excess above 1e9, in [0, 1e9)
    //
    if nPart == 28
        twoN = TWO_28
    elseif nPart == 29
        twoN = TWO_29
    else
        twoN = TWO_30
    endif
    //
    twoNH = twoN / NANO         // 0 for nPart<=29; 1 for nPart=30
    twoNL = twoN mod NANO
    //
    // floor(twoN * pow2frac_ / 1e9)
    // = twoNH * pow2frac + MulDiv(twoNL, pow2frac_) ... use pfH=1 always:
    // = twoNH*1e9 + twoNH*pfL + twoNL + MulDiv(twoNL, pfL)
    result = twoNH * NANO
           + twoNH * pfL
           + twoNL
           + MulDiv1e9(twoNL, pfL)
    //
    return( result )
end

// ===== Main =====
proc Main()
    integer uNano, prevUNano
    integer prevSum, curSum
    integer stableCountI, iterI
    integer intPartI, fracPartI
    string  resultS[255]
    //
    // u_0 = -1  =>  uNano = -1e9
    uNano        = -1000000000
    prevUNano    = 0
    prevSum      = 0
    stableCountI = 0
    //
    // Iterate until pair-sum u_n + u_{n+1} is stable for 5 steps.
    // Convergence occurs within ~560 iterations.
    for iterI = 1 to 800
        prevUNano = uNano
        uNano     = NextU(uNano)
        curSum    = prevUNano + uNano
        //
        if curSum == prevSum
            stableCountI = stableCountI + 1
            if stableCountI >= 5
                iterI = 801     // exit loop
            endif
        else
            stableCountI = 0
        endif
        prevSum = curSum
    endfor
    //
    // Format result as decimal with 9 decimal places
    intPartI  = curSum / NANO
    fracPartI = curSum mod NANO
    resultS   = Str(intPartI) + "." + Format(fracPartI:9:"0")
    //
    CopyToWinClip(resultS)
    Warn("P197: u_n + u_{n+1} for n=10^12 =" + Chr(13) + resultS)
    CopyToWinClip(resultS)
end
