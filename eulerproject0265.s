// eulerproject0265.s
// Project Euler Problem 265 - Binary Circles - Find S(5)
// [v.3][by Claude, Anthropic]
//
// Find sum of all de Bruijn sequences of order 5, oriented at the all-zeros
// window. Circular binary sequences of length 32 where every 5-bit window
// appears exactly once.
// Answer: 209110240768
//
// Method: Pure SAL. DFS backtracking with bitmask of used 5-bit windows.
// Sequence stored as global string (32 chars). First 5 bits fixed as 00000.
// Each value fits in 32-bit (max 2^27-1). Sum via hi/lo with BASE=10^9.

integer gBaseI
integer gSumHiI
integer gSumLoI
integer gSeenMaskI
string gSeqS[255]

forward proc DFS(integer depthI, integer lastWinI)

integer proc SeqToVal()
    integer nvI
    integer iI
    //
    nvI = 0
    iI = 1
    while iI <= 32
        nvI = nvI shl 1
        if SubStr(gSeqS, iI, 1) == "1"
            nvI = nvI | 1
        endif
        iI = iI + 1
    endwhile
    return(nvI)
end

proc AddToSum(integer nvI)
    //
    gSumLoI = gSumLoI + nvI
    if gSumLoI >= gBaseI
        gSumLoI = gSumLoI - gBaseI
        gSumHiI = gSumHiI + 1
    endif
    //
end

proc DFS(integer depthI, integer lastWinI)
    integer bitI
    integer wI
    integer iI
    integer jI
    integer okB
    integer tempMaskI
    integer nvI
    integer oldMaskI
    string chBitS[4]
    //
    PushPosition()
    //
    if depthI > 31
        // check 4 wrap-around windows (0-indexed start positions 28..31)
        tempMaskI = gSeenMaskI
        okB = TRUE
        iI = 28
        while iI <= 31 and okB
            wI = 0
            jI = 0
            while jI < 5
                if SubStr(gSeqS, ((iI + jI) mod 32) + 1, 1) == "1"
                    wI = (wI shl 1) | 1
                else
                    wI = wI shl 1
                endif
                jI = jI + 1
            endwhile
            if (tempMaskI shr wI) & 1
                okB = FALSE
            else
                tempMaskI = tempMaskI | (1 shl wI)
            endif
            iI = iI + 1
        endwhile
        //
        if okB
            nvI = SeqToVal()
            AddToSum(nvI)
        endif
        //
        PopPosition()
        return()
    endif
    //
    bitI = 0
    while bitI <= 1
        //
        if bitI == 0
            chBitS = "0"
        else
            chBitS = "1"
        endif
        //
        // set bit at 0-indexed position depthI (SAL string position depthI+1)
        if depthI < 31
            gSeqS = SubStr(gSeqS, 1, depthI) + chBitS + SubStr(gSeqS, depthI + 2, 31 - depthI)
        else
            gSeqS = SubStr(gSeqS, 1, 31) + chBitS
        endif
        //
        wI = ((lastWinI shl 1) | bitI) & 31
        //
        if ((gSeenMaskI shr wI) & 1) == 0
            oldMaskI = gSeenMaskI
            gSeenMaskI = gSeenMaskI | (1 shl wI)
            DFS(depthI + 1, wI)
            gSeenMaskI = oldMaskI
        endif
        //
        bitI = bitI + 1
    endwhile
    //
    PopPosition()
    //
end

proc Main()
    string resultS[255]
    string hiS[255]
    string loS[255]
    //
    gBaseI = 1000000000
    gSumHiI = 0
    gSumLoI = 0
    gSeenMaskI = 1
    gSeqS = "00000000000000000000000000000000"
    //
    DFS(5, 0)
    //
    // format result as decimal string
    if gSumHiI > 0
        hiS = Str(gSumHiI)
        loS = Format(gSumLoI:9:"0")
        resultS = hiS + loS
    else
        resultS = Str(gSumLoI)
    endif
    //
    CopyToWinClip(resultS)
    Warn("Project Euler 265 - Binary Circles" + Chr(13) + "S(5) = " + resultS)
    CopyToWinClip(resultS)
    //
end
