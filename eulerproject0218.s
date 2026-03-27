// eulerproject0218.s
// Project Euler - Problem 218: Perfect Right-angled Triangles
//
// Question: How many perfect right-angled triangles with c <= 10^16
//           exist that are NOT super-perfect?
//
// Definitions:
//   Primitive RAT: gcd(a,b)=1, sides a=m^2-n^2, b=2mn, c=m^2+n^2,
//                  gcd(m,n)=1, m>n>0, m+n odd.
//   Perfect RAT:   also c is a perfect square.
//   Super-perfect: also area divisible by 6 AND 28.
//   area = (1/2)*a*b = mn(m^2-n^2) = mn(m-n)(m+n).
//   lcm(6,28) = 84.  Super-perfect <=> area mod 84 = 0.
//
// Key reduction:
//   c = m^2+n^2 is a perfect square iff (n,m,sqrt(c)) is a Pythagorean triple.
//   So m = p^2-q^2 (or 2pq) and n = 2pq (or p^2-q^2) for some inner
//   parameters p>q>0, gcd(p,q)=1, p+q odd.
//   c = (p^2+q^2)^2.  c <= 10^16 iff p^2+q^2 <= 10^8 iff p <= 10000.
//   Outer (m,n): m=max(A,B), n=min(A,B) with A=p^2-q^2, B=2pq.
//   gcd(m,n)=1 and m+n odd always hold for valid (p,q). Proven.
//
//   Count (p,q) with (p^2+q^2)^2 <= 10^16 AND area mod 84 != 0.
//   Expected answer: 0.
//
// Version  : 1.0
// Date     : 2026-03-28
// LLM      : Claude (Anthropic)

// ---------------------------------------------------------------
// GCD
// ---------------------------------------------------------------
integer proc GCD(integer a, integer b)
    integer tmp
    while b <> 0
        tmp = a mod b
        a = b
        b = tmp
    endwhile
    return( a )
end

// ---------------------------------------------------------------
// PROC Main
// ---------------------------------------------------------------
PROC Main()
    integer nP, nQ
    integer A, B, mV, nV
    integer pqSumSq
    integer notSuperCount
    integer aModR, bModR, sumModR, diffModR
    integer areaM84
    string sResult[255]

    notSuperCount = 0

    // Outer loop: p from 2 upward; stop when p^2 > 10^8
    nP = 2
    while nP * nP <= 100000000
        for nQ = 1 to nP - 1
            // p+q must be odd (different parity) for primitive triple
            if (nP + nQ) mod 2 == 1
                if GCD(nP, nQ) == 1
                    pqSumSq = nP * nP + nQ * nQ
                    if pqSumSq <= 100000000
                        // Outer triple: A=p^2-q^2, B=2pq; m=max, n=min
                        A = nP * nP - nQ * nQ
                        B = 2 * nP * nQ
                        if A > B
                            mV = A
                            nV = B
                        else
                            mV = B
                            nV = A
                        endif
                        // area = mV * nV * (mV-nV) * (mV+nV)
                        // super-perfect iff area mod 84 == 0
                        aModR    = mV mod 84
                        bModR    = nV mod 84
                        diffModR = (mV - nV) mod 84
                        sumModR  = (mV + nV) mod 84
                        areaM84  = (aModR * bModR) mod 84
                        areaM84  = (areaM84 * diffModR) mod 84
                        areaM84  = (areaM84 * sumModR) mod 84
                        if areaM84 <> 0
                            notSuperCount = notSuperCount + 1
                        endif
                    endif
                endif
            endif
        endfor
        nP = nP + 1
    endwhile

    sResult = Str(notSuperCount)
    CopyToWinClip(sResult)
    Warn("P218 Perfect Right-angled Triangles" + Chr(13) +
         "Not super-perfect with c <= 10^16:" + Chr(13) +
         sResult)
    CopyToWinClip(sResult)
END
