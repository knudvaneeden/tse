// eulerproject0236Claude.s
// Project Euler Problem 236 - Luxury Hampers
// Version 3
// Created by: Claude (claude-sonnet-4-6)
//
// History:
//   v1 - Claude - Initial implementation
//   v2 - Claude - Fixed: replaced goto NextK4 with bSkipK4 boolean flag
//   v3 - Claude - Fixed: goto labels need colon at END not beginning (FoundSol: not :FoundSol)
//
// Approach:
//   m = P/Q (reduced, P>Q). bi/ai: 5/41, 59/41, 59/41, 59/90, 59/41.
//   Step sizes e1=(Q*41)/gcd(Q*41,5P), e2=(Q*41)/gcd(Q*41,59P), e4=(Q*90)/gcd(Q*90,59P).
//   Constraint: K1*A1 + K2*A2 + K4*A4 = 0
//   where A1=e1*(181548*Q^2-26550*P^2), A2=e2*(181548*Q^2-313290*P^2),
//         A4=e4*(181548*Q^2-142721*P^2).
//   64-bit values stored as (sign, H, L): value = sign*(H*10^9 + L).
//   Search P,Q up to 5000. Answer: 123/59 (35 solutions).

integer proc GCD(integer nA, integer nB)
    integer nR
    while nB <> 0
        nR = nA mod nB
        nA = nB
        nB = nR
    endwhile
    return( nA )
end

// 64-bit multiply: nA * nB -> gM64H * 10^9 + gM64L
// Split by 10^4: nA=nAh*10^4+nAl, nB=nBh*10^4+nBl
// Product = p11*10^8 + mid*10^4 + p00, stored in B=10^9 format.
integer gM64H
integer gM64L

proc Mul32x32(integer nA, integer nB)
    integer nAh, nAl, nBh, nBl
    integer p11, p10, p01, p00, mid, Lsum
    nAh = nA / 10000
    nAl = nA mod 10000
    nBh = nB / 10000
    nBl = nB mod 10000
    p11 = nAh * nBh
    p10 = nAh * nBl
    p01 = nAl * nBh
    p00 = nAl * nBl
    mid = p10 + p01
    Lsum = (p11 mod 10) * 100000000 + (mid mod 100000) * 10000 + p00
    gM64H = p11 / 10 + mid / 100000 + Lsum / 1000000000
    gM64L = Lsum mod 1000000000
end

// 64-bit signed registers for A1,A2,A4 and accumulator
// Each stored as (S, H, L): value = S*(H*10^9 + L), S in {1,-1}
integer gA1S, gA1H, gA1L
integer gA2S, gA2H, gA2L
integer gA4S, gA4H, gA4L
integer gAccS, gAccH, gAccL

// Compute c1-c2 (both nonneg 64-bit), result sign+magnitude into gM64H,gM64L
integer proc Diff64(integer c1H, integer c1L, integer c2H, integer c2L)
    integer dH, dL, nS
    if c1H > c2H or (c1H == c2H and c1L >= c2L)
        nS = 1
        dL = c1L - c2L
        if dL < 0
            dL = dL + 1000000000
            dH = c1H - c2H - 1
        else
            dH = c1H - c2H
        endif
    else
        nS = -1
        dL = c2L - c1L
        if dL < 0
            dL = dL + 1000000000
            dH = c2H - c1H - 1
        else
            dH = c2H - c1H
        endif
    endif
    gM64H = dH
    gM64L = dL
    return( nS )
end

// Scale (aH,aL) by small int n -> result in gM64H,gM64L
proc Scale64(integer n, integer aH, integer aL)
    Mul32x32(n, aL)
    gM64H = n * aH + gM64H
end

// Compute A1,A2,A4 for given P,Q,e1,e2,e4
proc ComputeA(integer nP, integer nQ, integer ne1, integer ne2, integer ne4)
    integer Q2, P2, t1H, t1L, t2H, t2L, dS
    Q2 = nQ * nQ
    P2 = nP * nP
    // A1 = ne1*(181548*Q^2 - 26550*P^2)
    Mul32x32(181548, Q2)  t1H = gM64H  t1L = gM64L
    Mul32x32(26550,  P2)  t2H = gM64H  t2L = gM64L
    dS = Diff64(t1H, t1L, t2H, t2L)
    Scale64(ne1, gM64H, gM64L)
    gA1S = dS  gA1H = gM64H  gA1L = gM64L
    // A2 = ne2*(181548*Q^2 - 313290*P^2)
    Mul32x32(181548, Q2)  t1H = gM64H  t1L = gM64L
    Mul32x32(313290, P2)  t2H = gM64H  t2L = gM64L
    dS = Diff64(t1H, t1L, t2H, t2L)
    Scale64(ne2, gM64H, gM64L)
    gA2S = dS  gA2H = gM64H  gA2L = gM64L
    // A4 = ne4*(181548*Q^2 - 142721*P^2)
    Mul32x32(181548, Q2)  t1H = gM64H  t1L = gM64L
    Mul32x32(142721, P2)  t2H = gM64H  t2L = gM64L
    dS = Diff64(t1H, t1L, t2H, t2L)
    Scale64(ne4, gM64H, gM64L)
    gA4S = dS  gA4H = gM64H  gA4L = gM64L
end

// Add nK*(nAS,nAH,nAL) to accumulator (gAccS,gAccH,gAccL)
proc AccAdd(integer nK, integer nAS, integer nAH, integer nAL)
    integer termS, termH, termL
    integer newL, newH, cmp
    Scale64(nK, nAH, nAL)
    termS = nAS  termH = gM64H  termL = gM64L
    if termS == gAccS
        newL = gAccL + termL
        if newL >= 1000000000
            newL = newL - 1000000000
            newH = gAccH + termH + 1
        else
            newH = gAccH + termH
        endif
        gAccH = newH  gAccL = newL
    else
        if gAccH > termH
            cmp = 1
        elseif gAccH < termH
            cmp = -1
        elseif gAccL > termL
            cmp = 1
        elseif gAccL < termL
            cmp = -1
        else
            cmp = 0
        endif
        if cmp == 0
            gAccS = 1  gAccH = 0  gAccL = 0
        elseif cmp > 0
            newL = gAccL - termL
            if newL < 0
                newL = newL + 1000000000
                gAccH = gAccH - termH - 1
            else
                gAccH = gAccH - termH
            endif
            gAccL = newL
        else
            gAccS = termS
            newL = termL - gAccL
            if newL < 0
                newL = newL + 1000000000
                gAccH = termH - gAccH - 1
            else
                gAccH = termH - gAccH
            endif
            gAccL = newL
        endif
    endif
end

// Return TRUE if accumulator == -nK*(nAS,nAH,nAL)
integer proc CheckEqual(integer nK, integer nAS, integer nAH, integer nAL)
    integer termS, termH, termL
    Scale64(nK, nAH, nAL)
    termS = -nAS
    termH = gM64H  termL = gM64L
    if termH == 0 and termL == 0
        if gAccH == 0 and gAccL == 0
            return( TRUE )
        endif
        return( FALSE )
    endif
    if termS == gAccS and termH == gAccH and termL == gAccL
        return( TRUE )
    endif
    return( FALSE )
end

// Return TRUE if P1/Q1 > P2/Q2
integer proc FracGT(integer nP1, integer nQ1, integer nP2, integer nQ2)
    if nP1 * nQ2 > nP2 * nQ1
        return( TRUE )
    endif
    return( FALSE )
end

integer gBestP
integer gBestQ
integer gSolCount

proc Main()
    integer nP, nQ, nG
    integer ne1, ne2, ne4
    integer nK1max, nK2max, nK4max
    integer nK1, nK2, nK4
    integer nK2max_2, nK2max_3, nK2max_5
    integer bFound, bSkipK4
    string sResult[20]

    gBestP = 1
    gBestQ = 1
    gSolCount = 0

    for nP = 2 to 5000
        for nQ = 1 to nP - 1
            nG = GCD(nP, nQ)
            if nG <> 1
                goto NextQ
            endif

            ne1 = (nQ * 41) / GCD(nQ * 41, 5 * nP)
            nK1max = (5248 * nQ) / (nP * ne1)
            if nK1max < 1
                goto NextQ
            endif

            ne2 = (nQ * 41) / GCD(nQ * 41, 59 * nP)
            nK2max_2 = (1312 * nQ) / (nP * ne2)
            nK2max_3 = (2624 * nQ) / (nP * ne2)
            nK2max_5 = (3936 * nQ) / (nP * ne2)
            nK2max = nK2max_2 + nK2max_3 + nK2max_5
            if nK2max_2 < 1
                goto NextQ
            endif

            ne4 = (nQ * 90) / GCD(nQ * 90, 59 * nP)
            nK4max = (5760 * nQ) / (nP * ne4)
            if nK4max < 1
                goto NextQ
            endif

            ComputeA(nP, nQ, ne1, ne2, ne4)

            if gA2H == 0 and gA2L == 0
                goto NextQ
            endif

            bFound = FALSE
            for nK1 = 1 to nK1max
                for nK4 = 1 to nK4max
                    bSkipK4 = FALSE
                    gAccS = 1  gAccH = 0  gAccL = 0
                    AccAdd(nK1, gA1S, gA1H, gA1L)
                    AccAdd(nK4, gA4S, gA4H, gA4L)
                    if gAccH == 0 and gAccL == 0
                        bSkipK4 = TRUE
                    endif
                    if gAccS == -1
                        bSkipK4 = TRUE
                    endif
                    if bSkipK4 == FALSE
                        for nK2 = 3 to nK2max
                            if CheckEqual(nK2, gA2S, gA2H, gA2L)
                                bFound = TRUE
                            endif
                            if bFound
                                goto FoundSol
                            endif
                        endfor
                    endif
                endfor
                if bFound
                    goto FoundSol
                endif
            endfor
            goto NextQ

            FoundSol:
            gSolCount = gSolCount + 1
            if FracGT(nP, nQ, gBestP, gBestQ)
                gBestP = nP
                gBestQ = nQ
            endif

            NextQ:
        endfor
    endfor

    sResult = Str(gBestP) + "/" + Str(gBestQ)
    CopyToWinClip(sResult)
    Warn("Euler 236: " + sResult + " (" + Str(gSolCount) + " solutions)")
    CopyToWinClip(sResult)
end
