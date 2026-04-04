// ============================================================
// eulerproject0253.s
// Project Euler Problem 253 - Tidying Up A
//
// A 40-piece caterpillar jigsaw puzzle. Pieces are placed one
// at a time in a random order. M = max number of segments seen
// during the placement process. Find E[M] rounded to 6 decimals.
//
// Method: DP on states (s=current segments, m=max segments seen).
// Exact averaged transition probabilities (derived analytically,
// independent of k, depending only on T=N-k and s):
//   prob_create = (T+1-s)(T-s) / [T(T+1)]
//   prob_extend = 2s(T+1-s)   / [T(T+1)]
//   prob_bridge = s(s-1)       / [T(T+1)]
// Probabilities scaled by SCALE=10^15 using BigInt string arithmetic.
//
// <version>1</version>
//
// History:
// 1.0.0.0.1 - 2026-04-05 - Claude (Anthropic, claude-sonnet-4-6) - initial
// ============================================================

// === Global variables ===
integer gBufCurI        // current step p[s][m] buffer
integer gBufNxtI        // next step p[s][m] buffer

// ==================== BigInt routines ====================
// All operate on non-negative decimal strings, no leading zeros.

// BigAdd: return sAS + sBS as decimal string
string proc BigAdd(string sAS, string sBS)
    string sResultS[255]
    integer carryI, iaI, ibI, daI, dbI, drI, lenAI, lenBI, irI
    lenAI = Length(sAS)
    lenBI = Length(sBS)
    sResultS = ""
    carryI = 0
    irI = 1
    while irI <= lenAI or irI <= lenBI or carryI > 0
        daI = 0
        dbI = 0
        iaI = lenAI - irI + 1
        ibI = lenBI - irI + 1
        if iaI >= 1
            daI = Asc(sAS[iaI:1]) - 48
        endif
        if ibI >= 1
            dbI = Asc(sBS[ibI:1]) - 48
        endif
        drI = daI + dbI + carryI
        carryI = drI / 10
        drI = drI mod 10
        sResultS = Chr(48 + drI) + sResultS
        irI = irI + 1
    endwhile
    if Length(sResultS) == 0
        sResultS = "0"
    endif
    return(sResultS)
end

// BigMulSmall: return sAS * nNI as decimal string (nNI >= 0, fits 32-bit)
// For our use: nNI <= 1640, so carry <= 1626, all fits in 32-bit SAL int.
string proc BigMulSmall(string sAS, integer nNI)
    string sResultS[255]
    integer carryI, iI, daI, drI, lenAI
    if nNI == 0
        return("0")
    endif
    if sAS == "0"
        return("0")
    endif
    lenAI = Length(sAS)
    sResultS = ""
    carryI = 0
    iI = lenAI
    while iI >= 1 or carryI > 0
        daI = 0
        if iI >= 1
            daI = Asc(sAS[iI:1]) - 48
            iI = iI - 1
        endif
        drI = daI * nNI + carryI
        carryI = drI / 10
        drI = drI mod 10
        sResultS = Chr(48 + drI) + sResultS
    endwhile
    if Length(sResultS) == 0
        sResultS = "0"
    endif
    return(sResultS)
end

// BigDivSmall: return floor(sAS / nNI) as decimal string (nNI > 0)
// For our use: nNI <= 1640, remainder*10+digit <= 16399, fits 32-bit.
string proc BigDivSmall(string sAS, integer nNI)
    string sResultS[255]
    integer remI, daI, dqI, iI, lenAI
    if sAS == "0"
        return("0")
    endif
    lenAI = Length(sAS)
    sResultS = ""
    remI = 0
    iI = 1
    while iI <= lenAI
        daI = Asc(sAS[iI:1]) - 48
        dqI = (remI * 10 + daI) / nNI
        remI = (remI * 10 + daI) mod nNI
        sResultS = sResultS + Chr(48 + dqI)
        iI = iI + 1
    endwhile
    while Length(sResultS) > 1 and sResultS[1:1] == "0"
        sResultS = sResultS[2:Length(sResultS)-1]
    endwhile
    if Length(sResultS) == 0
        sResultS = "0"
    endif
    return(sResultS)
end

// BigCmp: compare sAS and sBS; return -1 if sAS<sBS, 0 if equal, 1 if sAS>sBS
integer proc BigCmp(string sAS, string sBS)
    integer lenAI, lenBI, iI
    lenAI = Length(sAS)
    lenBI = Length(sBS)
    if lenAI < lenBI
        return(-1)
    endif
    if lenAI > lenBI
        return(1)
    endif
    iI = 1
    while iI <= lenAI
        if sAS[iI:1] < sBS[iI:1]
            return(-1)
        endif
        if sAS[iI:1] > sBS[iI:1]
            return(1)
        endif
        iI = iI + 1
    endwhile
    return(0)
end

// BigSub: return sAS - sBS as decimal string (requires sAS >= sBS >= 0)
string proc BigSub(string sAS, string sBS)
    string sResultS[255]
    integer borrowI, iaI, ibI, daI, dbI, drI, lenAI, lenBI, irI
    if sAS == sBS
        return("0")
    endif
    lenAI = Length(sAS)
    lenBI = Length(sBS)
    sResultS = ""
    borrowI = 0
    irI = 1
    while irI <= lenAI
        daI = Asc(sAS[lenAI - irI + 1:1]) - 48
        dbI = 0
        ibI = lenBI - irI + 1
        if ibI >= 1
            dbI = Asc(sBS[ibI:1]) - 48
        endif
        drI = daI - dbI - borrowI
        if drI < 0
            drI = drI + 10
            borrowI = 1
        else
            borrowI = 0
        endif
        sResultS = Chr(48 + drI) + sResultS
        irI = irI + 1
    endwhile
    while Length(sResultS) > 1 and sResultS[1:1] == "0"
        sResultS = sResultS[2:Length(sResultS)-1]
    endwhile
    if Length(sResultS) == 0
        sResultS = "0"
    endif
    return(sResultS)
end

// BigDivBig: return floor(sAS / sDivS) as decimal string
// Uses long division digit by digit.
string proc BigDivBig(string sAS, string sDivS)
    string sQuotS[100]
    string sRemS[255]
    string sTestS[255]
    integer iI, dI, cmpI, foundB, lenI
    sQuotS = ""
    sRemS = "0"
    lenI = Length(sAS)
    iI = 1
    while iI <= lenI
        // Bring down next digit of sAS
        if sRemS == "0"
            sRemS = sAS[iI:1]
        else
            sRemS = sRemS + sAS[iI:1]
        endif
        // Remove leading zeros
        while Length(sRemS) > 1 and sRemS[1:1] == "0"
            sRemS = sRemS[2:Length(sRemS)-1]
        endwhile
        // Find largest digit dI in 0..9 such that dI*sDivS <= sRemS
        dI = 9
        foundB = FALSE
        while dI >= 0 and foundB == FALSE
            sTestS = BigMulSmall(sDivS, dI)
            cmpI = BigCmp(sRemS, sTestS)
            if cmpI >= 0
                foundB = TRUE
            else
                dI = dI - 1
            endif
        endwhile
        sQuotS = sQuotS + Chr(48 + dI)
        // Subtract dI*sDivS from sRemS
        sTestS = BigMulSmall(sDivS, dI)
        sRemS = BigSub(sRemS, sTestS)
        iI = iI + 1
    endwhile
    // Remove leading zeros
    while Length(sQuotS) > 1 and sQuotS[1:1] == "0"
        sQuotS = sQuotS[2:Length(sQuotS)-1]
    endwhile
    if Length(sQuotS) == 0
        sQuotS = "0"
    endif
    return(sQuotS)
end

// ==================== Buffer helpers ====================
// State (s,m) stored at buffer line: s*21 + m + 1
// s: 0..20, m: 0..20 => 441 lines total

integer proc StateLineI(integer nSI, integer nMI)
    return(nSI * 21 + nMI + 1)
end

string proc GetP(integer nBufI, integer nSI, integer nMI)
    GotoBufferId(nBufI)
    GotoLine(StateLineI(nSI, nMI))
    return(GetText(1, 255))
end

proc SetP(integer nBufI, integer nSI, integer nMI, string sValS)
    GotoBufferId(nBufI)
    GotoLine(StateLineI(nSI, nMI))
    BegLine()
    KillToEol()
    InsertText(sValS)
end

proc AddToP(integer nBufI, integer nSI, integer nMI, string sAddS)
    string sCurS[255]
    if sAddS == "0"
        return()
    endif
    sCurS = GetP(nBufI, nSI, nMI)
    SetP(nBufI, nSI, nMI, BigAdd(sCurS, sAddS))
end

// InitBuf: set up buffer with exactly 441 lines all containing "0"
// Call once per buffer on a newly created temp buffer.
proc InitBuf(integer nBufI)
    integer nLI
    GotoBufferId(nBufI)
    EmptyBuffer()           // leaves one blank line
    GotoLine(1)
    BegLine()
    KillToEol()
    InsertText("0")         // line 1 = "0"
    nLI = 2
    while nLI <= 441
        AddLine("0")        // appends line after current, cursor moves to new line
        nLI = nLI + 1
    endwhile
end

// ClearBuf: reset all 441 lines to "0" (buffer already has 441 lines)
proc ClearBuf(integer nBufI)
    integer nLI
    GotoBufferId(nBufI)
    nLI = 1
    while nLI <= 441
        GotoLine(nLI)
        BegLine()
        KillToEol()
        InsertText("0")
        nLI = nLI + 1
    endwhile
end

// ==================== Main ====================

proc Main()
    integer kI, nTI, nSI, nMI, nNewSI, nNewMI
    integer numCreateI, numExtendI, numBridgeI, nDenI
    integer nSwapI, mI, lenI, nIntI
    integer digit7I
    string sCurS[255], sContribS[255]
    string sSumS[255], sTotS[255]
    string sSum7S[255], sEMul7S[50]
    string sIntS[20], sDec7S[10], sDec6S[10]
    string sRoundS[10], sAnswerS[50]

    // Create and initialise both DP buffers
    gBufCurI = CreateTempBuffer()
    InitBuf(gBufCurI)
    SetP(gBufCurI, 0, 0, "1000000000000000")   // p[0][0] = 10^15

    gBufNxtI = CreateTempBuffer()
    InitBuf(gBufNxtI)

    // DP: place pieces k=0..39 (k = pieces already placed before this step)
    kI = 0
    while kI < 40
        nTI = 40 - kI           // remaining pieces (= N - k)
        nDenI = nTI * (nTI + 1) // denominator T*(T+1) <= 40*41 = 1640

        ClearBuf(gBufNxtI)

        // Process every state (s, m)
        nSI = 0
        while nSI <= 20
            nMI = 0
            while nMI <= 20
                sCurS = GetP(gBufCurI, nSI, nMI)
                if sCurS <> "0"

                    // --- Create: s+1, new max = max(m, s+1) ---
                    numCreateI = (nTI + 1 - nSI) * (nTI - nSI)
                    if numCreateI > 0 and nSI < 20
                        nNewSI = nSI + 1
                        nNewMI = nMI
                        if nNewSI > nNewMI
                            nNewMI = nNewSI
                        endif
                        sContribS = BigDivSmall(BigMulSmall(sCurS, numCreateI), nDenI)
                        AddToP(gBufNxtI, nNewSI, nNewMI, sContribS)
                    endif

                    // --- Extend: s unchanged, max unchanged (m >= s always) ---
                    numExtendI = 2 * nSI * (nTI + 1 - nSI)
                    if numExtendI > 0
                        nNewSI = nSI
                        nNewMI = nMI
                        sContribS = BigDivSmall(BigMulSmall(sCurS, numExtendI), nDenI)
                        AddToP(gBufNxtI, nNewSI, nNewMI, sContribS)
                    endif

                    // --- Bridge: s-1, max unchanged (m >= s > s-1) ---
                    numBridgeI = nSI * (nSI - 1)
                    if numBridgeI > 0
                        nNewSI = nSI - 1
                        nNewMI = nMI
                        sContribS = BigDivSmall(BigMulSmall(sCurS, numBridgeI), nDenI)
                        AddToP(gBufNxtI, nNewSI, nNewMI, sContribS)
                    endif

                endif
                nMI = nMI + 1
            endwhile
            nSI = nSI + 1
        endwhile

        // Swap cur <-> nxt
        nSwapI   = gBufCurI
        gBufCurI = gBufNxtI
        gBufNxtI = nSwapI

        kI = kI + 1
    endwhile

    // After 40 placements, all segments merge to s=1.
    // Compute E[M] = sum(m * p[1][m]) / sum(p[1][m])
    sSumS = "0"
    sTotS = "0"
    mI = 1
    while mI <= 20
        sCurS = GetP(gBufCurI, 1, mI)
        if sCurS <> "0"
            sTotS = BigAdd(sTotS, sCurS)
            sSumS = BigAdd(sSumS, BigMulSmall(sCurS, mI))
        endif
        mI = mI + 1
    endwhile

    // Compute E[M] * 10^7 = floor(sSumS * 10^7 / sTotS)
    sSum7S  = BigMulSmall(sSumS, 10000000)   // sSumS * 10^7
    sEMul7S = BigDivBig(sSum7S, sTotS)       // floor(E[M] * 10^7)

    // Pad sEMul7S to at least 9 digits (E[M]~11 => E[M]*10^7~1.15e8, 9 digits)
    while Length(sEMul7S) < 9
        sEMul7S = "0" + sEMul7S
    endwhile

    lenI  = Length(sEMul7S)
    nIntI = lenI - 7            // digits before decimal point

    // Integer part string
    if nIntI >= 1
        sIntS = sEMul7S[1:nIntI]
    else
        sIntS = "0"
    endif

    // 7 decimal digits (positions nIntI+1 .. nIntI+7)
    sDec7S = sEMul7S[nIntI + 1:7]

    // Round to 6 decimal places using 7th digit
    digit7I = Asc(sDec7S[7:1]) - 48
    sDec6S  = sDec7S[1:6]
    if digit7I >= 5
        sRoundS = BigAdd(sDec6S, "1")
        if Length(sRoundS) > 6
            // Carry into integer part
            sDec6S = "000000"
            sIntS  = BigAdd(sIntS, "1")
        else
            while Length(sRoundS) < 6
                sRoundS = "0" + sRoundS
            endwhile
            sDec6S = sRoundS
        endif
    endif

    sAnswerS = sIntS + "." + sDec6S

    CopyToWinClip(sAnswerS)
    Warn("Project Euler 253 - Tidying Up A" + Chr(13) +
         "E[M] = " + sAnswerS)
    CopyToWinClip(sAnswerS)

    AbandonFile(gBufCurI)
    AbandonFile(gBufNxtI)
end
