// eulerproject0240.s
// Project Euler Problem 240 - Top Dice
// 20 twelve-sided dice, top 10 sum to 70: count ways
// Version: 2
// History: v1 - Created by Claude (Anthropic)
//          v2 - Fixed: no arrays in SAL; store comb+dp in TSE buffers
//
// Algorithm: DP over sorted placements of face values 1..12
// State dp[placed][top10sum] stored in TSE buffer
// C(n,k) stored in a buffer (line n*21+k+1)
// Big-integer arithmetic via strings (answer ~7.4e18, 19 digits)

// ---- Big integer helpers ----

string proc StrRev( string sInS )
    string sOutS[30]
    integer nI
    sOutS = ""
    for nI = Length(sInS) downto 1
        sOutS = sOutS + SubStr(sInS, nI, 1)
    endfor
    return( sOutS )
end

string proc BigAdd( string sAS, string sBBS )
    string sARevS[30], sBRevS[30], sResS[30]
    string sBB2S[30]
    integer nI, nDigA, nDigB, nSum, nCarry, nLenA, nLenB, nLenMax
    sBB2S  = sBBS
    sARevS = StrRev(sAS)
    sBRevS = StrRev(sBB2S)
    nLenA  = Length(sARevS)
    nLenB  = Length(sBRevS)
    nLenMax = nLenA
    if nLenB > nLenMax
        nLenMax = nLenB
    endif
    nCarry = 0
    sResS  = ""
    for nI = 1 to nLenMax
        nDigA = 0
        nDigB = 0
        if nI <= nLenA
            nDigA = Val(SubStr(sARevS, nI, 1))
        endif
        if nI <= nLenB
            nDigB = Val(SubStr(sBRevS, nI, 1))
        endif
        nSum   = nDigA + nDigB + nCarry
        nCarry = nSum / 10
        nSum   = nSum mod 10
        sResS  = sResS + Str(nSum)
    endfor
    if nCarry > 0
        sResS = sResS + Str(nCarry)
    endif
    if Length(sResS) == 0
        sResS = "0"
    endif
    return( StrRev(sResS) )
end

string proc BigMulSmall( string sAS, integer nMulI )
    string sARevS[30], sResS[30]
    integer nI, nDigA, nProd, nCarry, nLenA
    if nMulI == 0
        return( "0" )
    endif
    if sAS == "0"
        return( "0" )
    endif
    sARevS = StrRev(sAS)
    nLenA  = Length(sARevS)
    nCarry = 0
    sResS  = ""
    for nI = 1 to nLenA
        nDigA  = Val(SubStr(sARevS, nI, 1))
        nProd  = nDigA * nMulI + nCarry
        nCarry = nProd / 10
        nProd  = nProd mod 10
        sResS  = sResS + Str(nProd)
    endfor
    while nCarry > 0
        sResS  = sResS + Str(nCarry mod 10)
        nCarry = nCarry / 10
    endwhile
    return( StrRev(sResS) )
end

// ---- Buffer line read/write helpers ----

string proc BufGetLine( integer nBufI, integer nLineI )
    string sValS[30]
    GotoBufferId(nBufI)
    GotoLine(nLineI)
    sValS = GetText(1, 30)
    return( sValS )
end

proc BufSetLine( integer nBufI, integer nLineI, string sValS )
    GotoBufferId(nBufI)
    GotoLine(nLineI)
    BegLine()
    DelToEol()
    InsertText(sValS, _INSERT_)
end

// ---- Combinatorics buffer ----
// Line n*21+k+1 = Str(C(n,k)), for n,k in 0..20 => 441 lines

integer gBufCombI

proc BuildComb()
    integer nI, nK, nVal, nLineI
    string  sPrevA[20], sPrevB[20]
    gBufCombI = CreateTempBuffer()
    GotoBufferId(gBufCombI)
    EmptyBuffer()
    // Fill 441 lines with "0"
    for nI = 1 to 441
        AddLine("0")
    endfor
    // C(n,0)=1, C(n,n)=1
    for nI = 0 to 20
        BufSetLine(gBufCombI, nI*21 + 0 + 1, "1")
        BufSetLine(gBufCombI, nI*21 + nI + 1, "1")
    endfor
    // Pascal's triangle - values fit in 32-bit integer
    for nI = 2 to 20
        for nK = 1 to nI - 1
            sPrevA = BufGetLine(gBufCombI, (nI-1)*21 + (nK-1) + 1)
            sPrevB = BufGetLine(gBufCombI, (nI-1)*21 + nK + 1)
            nVal   = Val(sPrevA) + Val(sPrevB)
            nLineI = nI*21 + nK + 1
            BufSetLine(gBufCombI, nLineI, Str(nVal))
        endfor
    endfor
end

integer proc CombGet( integer nNI, integer nKI )
    return( Val(BufGetLine(gBufCombI, nNI*21 + nKI + 1)) )
end

// ---- DP buffers ----
// dp[placed][ts]: line = placed*71 + ts + 1, value = big-integer string
// placed: 0..20 (21), ts: 0..70 (71) => 1491 lines

proc InitDpBuf( integer nBufI )
    integer nI
    GotoBufferId(nBufI)
    EmptyBuffer()
    for nI = 1 to 1491
        AddLine("0")
    endfor
end

string proc DpGet( integer nBufI, integer nPlacedI, integer nTsI )
    return( BufGetLine(nBufI, nPlacedI*71 + nTsI + 1) )
end

proc DpSet( integer nBufI, integer nPlacedI, integer nTsI, string sValS )
    BufSetLine(nBufI, nPlacedI*71 + nTsI + 1, sValS)
end

proc DpAdd( integer nBufI, integer nPlacedI, integer nTsI, string sAddS )
    string sCurS[30]
    sCurS = DpGet(nBufI, nPlacedI, nTsI)
    DpSet(nBufI, nPlacedI, nTsI, BigAdd(sCurS, sAddS))
end

// ---- Main ----

proc Main()
    integer nBufCurI, nBufNxtI, nBufTmpI
    integer nV, nPlaced, nTs, nK, nRemain, nInTop, nNewPlaced, nNewTs
    integer nFactor
    string  sCurValS[30], sMulS[30], gResultS[30]

    BuildComb()

    nBufCurI = CreateTempBuffer()
    nBufNxtI = CreateTempBuffer()

    InitDpBuf(nBufCurI)
    InitDpBuf(nBufNxtI)

    // dp[0][0] = 1
    DpSet(nBufCurI, 0, 0, "1")

    // Process face values 1..12
    for nV = 1 to 12
        InitDpBuf(nBufNxtI)

        for nPlaced = 0 to 20
            for nTs = 0 to 70
                sCurValS = DpGet(nBufCurI, nPlaced, nTs)
                if sCurValS <> "0"
                    nRemain = 20 - nPlaced
                    for nK = 0 to nRemain
                        nNewPlaced = nPlaced + nK
                        // in_top = max(0, min(k, new_placed - 10))
                        nInTop = nNewPlaced - 10
                        if nInTop < 0
                            nInTop = 0
                        endif
                        if nInTop > nK
                            nInTop = nK
                        endif
                        nNewTs = nTs + nInTop * nV
                        if nNewTs <= 70
                            nFactor = CombGet(nRemain, nK)
                            sMulS   = BigMulSmall(sCurValS, nFactor)
                            DpAdd(nBufNxtI, nNewPlaced, nNewTs, sMulS)
                        endif
                    endfor
                endif
            endfor
        endfor

        // Swap buffers
        nBufTmpI = nBufCurI
        nBufCurI = nBufNxtI
        nBufNxtI = nBufTmpI
    endfor

    gResultS = DpGet(nBufCurI, 20, 70)

    AbandonFile(nBufCurI)
    AbandonFile(nBufNxtI)
    AbandonFile(gBufCombI)

    CopyToWinClip(gResultS)
    Warn("Project Euler 240 answer: " + gResultS)
    CopyToWinClip(gResultS)
end
