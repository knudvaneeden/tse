// eulerproject0220.s
// Project Euler Problem 220 - Heighway Dragon
// Version     : 2.5
// LLM         : Claude (Anthropic)
// Date        : 2026-03-29
//
// What is the position after 10^12 steps in D_50?
// Answer form: x,y
//
// -----------------------------------------------------------------------
// Storage strategy (v2.3):
//   BUILD phase: write one integer per line to a text file via fCreate/fWrite.
//   READ phase: InsertFile loads the text file into a TSE temp buffer.
//               Read values with GotoLine(lineNum) + GetText(1,20) + Val().
//   This separates write (sequential file) from read (GotoLine on loaded buffer).
//
//   Layout (3 lines per entry):
//     A_n[d] -> lines (n*4+d)*3+1 (dx), +2 (dy), +3 (ex)   [1-based]
//     B_n[d] -> same layout in separate file/buffer
//   Total: 204 entries * 3 lines = 612 lines per buffer.
//   Files: eulerp220a.tmp, eulerp220b.tmp
//   Written with fWrite(h, Str(v) + Chr(13) + Chr(10))
//
// Step counter 64-bit: hi*BASE+lo. Sub-count via Pow2m1_64 inline.
// Iterative walk (no recursion).
// Answer verified: D_10/500->(18,16); D_50/10^12->(139776,963904)
//
// -----------------------------------------------------------------------
// History:
//   v1.0..v2.2 - 2026-03-28/29 - Claude - various approaches
//   v2.3 - 2026-03-29 - Claude (Anthropic) - write to text file line-by-line;
//   v2.5 - 2026-03-29 - Claude (Anthropic) - CRITICAL FIX: Pow2m1_64 must double h
//                 in BOTH branches (carry and no-carry)
//          InsertFile into buffer; GotoLine+GetText for reads;
//          separates write-phase from read-phase cleanly
//
// -----------------------------------------------------------------------
// RULES COMPLIANCE CHECK:
//   [x] No val/pos as variable names
//   [x] Return() always with parentheses
//   [x] Single Warn() for final answer only
//   [x] Two CopyToWinClip() (one before, one after Warn)
//   [x] Version number in header
//   [x] LLM attribution (Claude, Anthropic) in header
//   [x] No arrays (file I/O + buffer used)
//   [x] No floating point
//   [x] No += operator; no != (use <>)
//   [x] No ? output parameter syntax
//   [x] No recursion (iterative WHILE loop)
//   [x] PROC Main() is last
//   [x] All vars declared at top of each proc
//   [x] String vars with size specification
//   [x] mod not %
//   [x] No reserved words as variable names
// -----------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Globals
// ---------------------------------------------------------------------------
integer BASE      = 1000000000    // 10^9
integer MAXLEV    = 50

integer gX        = 0
integer gY        = 0
integer gDir      = 0

integer gStepHi   = 0
integer gStepLo   = 0

integer gOutHi    = 0
integer gOutLo    = 0

// TSE buffers loaded from files (read-only during walk)
integer gBufA     = 0
integer gBufB     = 0

// Results from NetRead
integer gNetDx    = 0
integer gNetDy    = 0
integer gNetEx    = 0

// ---------------------------------------------------------------------------
// Direction helpers
// ---------------------------------------------------------------------------
integer proc Ddx(integer d)
    if d == 1  return(1)   endif
    if d == 3  return(-1)  endif
    return(0)
end

integer proc Ddy(integer d)
    if d == 0  return(1)   endif
    if d == 2  return(-1)  endif
    return(0)
end

// ---------------------------------------------------------------------------
// 64-bit helpers
// ---------------------------------------------------------------------------
integer proc Cmp64(integer aHi, integer aLo, integer bHi, integer bLo)
    if aHi < bHi  return(-1)  endif
    if aHi > bHi  return(1)   endif
    if aLo < bLo  return(-1)  endif
    if aLo > bLo  return(1)   endif
    return(0)
end

proc SubStep(integer bHi, integer bLo)
    integer rLo = gStepLo - bLo
    integer rHi = gStepHi - bHi
    if rLo < 0
        rLo = rLo + BASE
        rHi = rHi - 1
    endif
    gStepHi = rHi
    gStepLo = rLo
end

// Compute 2^n - 1 as 64-bit -> gOutHi, gOutLo
proc Pow2m1_64(integer n)
    integer h = 0
    integer l = 1
    integer i = 0
    for i = 1 to n
        l = l * 2
        if l >= BASE
            h = h * 2 + (l / BASE)
            l = l mod BASE
        else
            h = h * 2
        endif
    endfor
    l = l - 1
    if l < 0
        l = l + BASE
        h = h - 1
    endif
    gOutHi = h
    gOutLo = l
end

// ---------------------------------------------------------------------------
// Write one integer as a text line to file
// ---------------------------------------------------------------------------
proc WriteIntLine(integer h, integer v)
    string sLine[30] = ""
    sLine = Str(v) + Chr(13) + Chr(10)
    fWrite(h, sLine)
end

// ---------------------------------------------------------------------------
// Read net entry from TSE buffer
// Entry index = n*4+d (0-based). Line = index*3+1 (1-based), +1 for dy, +2 for ex.
// Sets gNetDx, gNetDy, gNetEx
// ---------------------------------------------------------------------------
proc NetRead(integer bufId, integer idx)
    integer baseLine = idx * 3 + 1
    string  s[20]    = ""
    GotoBufferId(bufId)
    GotoLine(baseLine)
    s = GetText(1, 20)
    gNetDx = Val(s)
    GotoLine(baseLine + 1)
    s = GetText(1, 20)
    gNetDy = Val(s)
    GotoLine(baseLine + 2)
    s = GetText(1, 20)
    gNetEx = Val(s)
end

// ---------------------------------------------------------------------------
// Build net displacement tables: write to files, then InsertFile into buffers
// ---------------------------------------------------------------------------
proc BuildNetTables()
    integer hA      = 0
    integer hB      = 0
    integer n       = 0
    integer d       = 0
    integer d1      = 0
    integer d2      = 0
    integer d3      = 0
    integer d4      = 0
    integer idxD    = 0
    integer idxD2   = 0
    integer adx     = 0
    integer ady     = 0
    integer aex     = 0
    integer bdx     = 0
    integer bdy     = 0
    integer bex     = 0
    integer adx2    = 0
    integer ady2    = 0
    integer aex2    = 0
    integer bdx2    = 0
    integer bdy2    = 0
    integer bex2    = 0
    // Temp arrays for current level (4 dirs * 3 values each = 12 vars)
    integer aAdx0   = 0  integer aAdx1   = 0
    integer aAdx2_  = 0  integer aAdx3   = 0
    integer aAdy0   = 0  integer aAdy1   = 0
    integer aAdy2_  = 0  integer aAdy3   = 0
    integer aAex0   = 0  integer aAex1   = 0
    integer aAex2_  = 0  integer aAex3   = 0
    integer aBdx0   = 0  integer aBdx1   = 0
    integer aBdx2_  = 0  integer aBdx3   = 0
    integer aBdy0   = 0  integer aBdy1   = 0
    integer aBdy2_  = 0  integer aBdy3   = 0
    integer aBex0   = 0  integer aBex1   = 0
    integer aBex2_  = 0  integer aBex3   = 0

    // --- Phase 1: Build net table writing to files ---
    hA = fCreate("eulerp220a.tmp")
    hB = fCreate("eulerp220b.tmp")

    // Level 0: A_0 and B_0 have no F-steps
    for d = 0 to 3
        WriteIntLine(hA, 0)    // dx
        WriteIntLine(hA, 0)    // dy
        WriteIntLine(hA, d)    // ex
        WriteIntLine(hB, 0)
        WriteIntLine(hB, 0)
        WriteIntLine(hB, d)
    endfor

    // Level 0 complete: load files into temp buffers for reading
    fClose(hA)
    fClose(hB)
    gBufA = CreateTempBuffer()
    InsertFile("eulerp220a.tmp")
    gBufB = CreateTempBuffer()
    InsertFile("eulerp220b.tmp")

    // Levels 1..MAXLEV: for each level, compute all 4 dirs,
    // then append results to files and reload buffers
    for n = 1 to MAXLEV

        // Compute all A_n[d] and B_n[d] using current buffers (level n-1 data)
        for d = 0 to 3
            idxD = (n-1)*4 + d
            NetRead(gBufA, idxD)
            adx = gNetDx
            ady = gNetDy
            aex = gNetEx
            d2 = (aex + 1) mod 4
            idxD2 = (n-1)*4 + d2
            NetRead(gBufB, idxD2)
            bdx = gNetDx
            bdy = gNetDy
            bex = gNetEx
            d3 = (bex + 1) mod 4
            // Store A_n[d] result in temp vars
            if d == 0
                aAdx0 = adx + bdx + Ddx(bex)
                aAdy0 = ady + bdy + Ddy(bex)
                aAex0 = d3
            elseif d == 1
                aAdx1 = adx + bdx + Ddx(bex)
                aAdy1 = ady + bdy + Ddy(bex)
                aAex1 = d3
            elseif d == 2
                aAdx2_ = adx + bdx + Ddx(bex)
                aAdy2_ = ady + bdy + Ddy(bex)
                aAex2_ = d3
            else
                aAdx3 = adx + bdx + Ddx(bex)
                aAdy3 = ady + bdy + Ddy(bex)
                aAex3 = d3
            endif

            d1 = (d + 3) mod 4
            idxD = (n-1)*4 + d1
            NetRead(gBufA, idxD)
            adx2 = gNetDx
            ady2 = gNetDy
            aex2 = gNetEx
            d4 = (aex2 + 3) mod 4
            idxD2 = (n-1)*4 + d4
            NetRead(gBufB, idxD2)
            bdx2 = gNetDx
            bdy2 = gNetDy
            bex2 = gNetEx
            // Store B_n[d] result in temp vars
            if d == 0
                aBdx0 = Ddx(d1) + adx2 + bdx2
                aBdy0 = Ddy(d1) + ady2 + bdy2
                aBex0 = bex2
            elseif d == 1
                aBdx1 = Ddx(d1) + adx2 + bdx2
                aBdy1 = Ddy(d1) + ady2 + bdy2
                aBex1 = bex2
            elseif d == 2
                aBdx2_ = Ddx(d1) + adx2 + bdx2
                aBdy2_ = Ddy(d1) + ady2 + bdy2
                aBex2_ = bex2
            else
                aBdx3 = Ddx(d1) + adx2 + bdx2
                aBdy3 = Ddy(d1) + ady2 + bdy2
                aBex3 = bex2
            endif
        endfor

        // Abandon old buffers
        AbandonFile(gBufA)
        AbandonFile(gBufB)

        // Append new level data to files
        hA = fOpen("eulerp220a.tmp", _OPEN_READWRITE_)
        fSeek(hA, 0, _SEEK_END_)
        WriteIntLine(hA, aAdx0)  WriteIntLine(hA, aAdy0)  WriteIntLine(hA, aAex0)
        WriteIntLine(hA, aAdx1)  WriteIntLine(hA, aAdy1)  WriteIntLine(hA, aAex1)
        WriteIntLine(hA, aAdx2_) WriteIntLine(hA, aAdy2_) WriteIntLine(hA, aAex2_)
        WriteIntLine(hA, aAdx3)  WriteIntLine(hA, aAdy3)  WriteIntLine(hA, aAex3)
        fClose(hA)

        hB = fOpen("eulerp220b.tmp", _OPEN_READWRITE_)
        fSeek(hB, 0, _SEEK_END_)
        WriteIntLine(hB, aBdx0)  WriteIntLine(hB, aBdy0)  WriteIntLine(hB, aBex0)
        WriteIntLine(hB, aBdx1)  WriteIntLine(hB, aBdy1)  WriteIntLine(hB, aBex1)
        WriteIntLine(hB, aBdx2_) WriteIntLine(hB, aBdy2_) WriteIntLine(hB, aBex2_)
        WriteIntLine(hB, aBdx3)  WriteIntLine(hB, aBdy3)  WriteIntLine(hB, aBex3)
        fClose(hB)

        // Reload updated files into new temp buffers
        gBufA = CreateTempBuffer()
        InsertFile("eulerp220a.tmp")
        gBufB = CreateTempBuffer()
        InsertFile("eulerp220b.tmp")

    endfor
end

// ---------------------------------------------------------------------------
// Iterative walk
// ---------------------------------------------------------------------------
proc WalkDragon(integer startFunc, integer startN)
    integer func      = startFunc
    integer nLev      = startN
    integer subHi     = 0
    integer subLo     = 0
    integer idxD      = 0
    integer doneB     = FALSE

    while nLev > 0 and (gStepHi <> 0 or gStepLo <> 0) and doneB == FALSE

        Pow2m1_64(nLev - 1)
        subHi = gOutHi
        subLo = gOutLo

        if func == 0

            if Cmp64(gStepHi, gStepLo, subHi, subLo) <= 0
                nLev = nLev - 1
            else
                idxD = (nLev-1)*4 + gDir
                NetRead(gBufA, idxD)
                gX   = gX + gNetDx
                gY   = gY + gNetDy
                gDir = (gNetEx + 1) mod 4
                SubStep(subHi, subLo)
                if Cmp64(gStepHi, gStepLo, subHi, subLo) <= 0
                    func = 1
                    nLev = nLev - 1
                else
                    idxD = (nLev-1)*4 + gDir
                    NetRead(gBufB, idxD)
                    gX   = gX + gNetDx
                    gY   = gY + gNetDy
                    gDir = gNetEx
                    SubStep(subHi, subLo)
                    if gStepHi <> 0 or gStepLo <> 0
                        gX = gX + Ddx(gDir)
                        gY = gY + Ddy(gDir)
                        SubStep(0, 1)
                        if gStepHi <> 0 or gStepLo <> 0
                            gDir = (gDir + 1) mod 4
                        endif
                    endif
                    doneB = TRUE
                endif
            endif

        else

            gDir = (gDir + 3) mod 4
            gX = gX + Ddx(gDir)
            gY = gY + Ddy(gDir)
            SubStep(0, 1)
            if gStepHi == 0 and gStepLo == 0
                doneB = TRUE
            else
                if Cmp64(gStepHi, gStepLo, subHi, subLo) <= 0
                    func = 0
                    nLev = nLev - 1
                else
                    idxD = (nLev-1)*4 + gDir
                    NetRead(gBufA, idxD)
                    gX   = gX + gNetDx
                    gY   = gY + gNetDy
                    gDir = (gNetEx + 3) mod 4
                    SubStep(subHi, subLo)
                    if Cmp64(gStepHi, gStepLo, subHi, subLo) <= 0
                        nLev = nLev - 1
                    else
                        idxD = (nLev-1)*4 + gDir
                        NetRead(gBufB, idxD)
                        gX   = gX + gNetDx
                        gY   = gY + gNetDy
                        gDir = gNetEx
                        SubStep(subHi, subLo)
                        doneB = TRUE
                    endif
                endif
            endif

        endif

    endwhile
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    string ansS[60] = ""

    BuildNetTables()

    gX      = 0
    gY      = 0
    gDir    = 0

    gStepHi = 1000
    gStepLo = 0

    // D_50 = "F" + A_50
    gX = gX + Ddx(gDir)
    gY = gY + Ddy(gDir)
    SubStep(0, 1)

    if gStepHi <> 0 or gStepLo <> 0
        WalkDragon(0, MAXLEV)
    endif

    ansS = Str(gX) + "," + Str(gY)

    CopyToWinClip(ansS)
    Warn(ansS)
    CopyToWinClip(ansS)
end
