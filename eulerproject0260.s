// eulerproject0260.s
// Project Euler Problem 260 - Stone Game
// Version: 6
// Created by: Claude (Anthropic)
//
// History:
//   v1 - Claude (Anthropic): Naive DP O(N^5) - infeasible for N=1000
//   v2 - Claude (Anthropic): Per-z-slice buffers - still too slow
//   v3 - Claude (Anthropic): O(N^3) algorithm, row-string caching
//   v4 - Claude (Anthropic): Renamed reserved proc names (SetBit etc.)
//   v5 - Claude (Anthropic): BUG FIX: goto DoneZ when one[x][y] lost (178767226)
//   v6 - Claude (Anthropic): BUG FIX: rowX_one/rowX_twoT were loaded once per
//        x-loop but modified by inner y iterations -> stale cache -> wrong answer
//        167548541. Now reload all 6 rows at start of each y iteration.
//
// Algorithm (position (x,y,z) with x<=y<=z is P-pos/losing iff ALL):
//   one[y][z]     not lost  AND  one[x][z]    not lost  AND  one[x][y] not lost
//   two[y-x][z]   not lost  AND  two[z-y][x]  not lost  AND  two[z-x][y] not lost
//   all_piles[y-x][z-x]  not lost
// When P-pos found, mark all 7 entries as lost.
// Also maintain two_T (transposed two) so two[z-y][x] = two_T[x][z-y].

// ---- Globals ----
integer gLIMIT      // = 1000
integer gBufOne     // one[a][b]
integer gBufTwo     // two[a][b]
integer gBufTwoT    // two_T[b][a] = transposed of gBufTwo
integer gBufAll     // all_piles[a][b]
integer gBPC        // bits per char = 7
integer gCHAR       // chars per line = 143

// ---- Forward declarations ----
forward proc    PutLost(integer bufId, integer a, integer b)
forward string  proc FetchRow(integer bufId, integer a)
forward integer proc ChkRow(string rowS, integer b)
forward proc    FillBuf(integer bufId)

// ---- ChkRow: test bit b in a cached row string ----
// Returns 1 if set (lost), 0 if clear (won)
integer proc ChkRow(string rowS, integer b)
    integer charN, bitN, ch
    charN = (b / gBPC) + 1
    bitN  = b mod gBPC
    if charN > Length(rowS)
        return( 0 )
    endif
    ch = Asc(SubStr(rowS, charN, 1)) & 0x7F
    if ch & (1 shl bitN)
        return( 1 )
    endif
    return( 0 )
end

// ---- FetchRow: fetch row a from bufId into a string ----
string proc FetchRow(integer bufId, integer a)
    integer old
    string s[255]
    old = GotoBufferId(bufId)
    GotoLine(a + 1)
    s = GetText(1, CurrLineLen())
    GotoBufferId(old)
    return( s )
end

// ---- PutLost: mark bit (a,b) as lost in bufId ----
proc PutLost(integer bufId, integer a, integer b)
    integer old, charN, bitN, ch
    string s[255]
    charN = (b / gBPC) + 1
    bitN  = b mod gBPC
    old = GotoBufferId(bufId)
    GotoLine(a + 1)
    s = GetText(1, CurrLineLen())
    ch = (Asc(SubStr(s, charN, 1)) & 0x7F) | (1 shl bitN)
    s = SubStr(s, 1, charN - 1) + Chr(ch | 0x80) + SubStr(s, charN + 1, 255)
    BegLine()
    KillToEol()
    InsertText(s, _INSERT_)
    GotoBufferId(old)
end

// ---- FillBuf: fill buffer with gLIMIT+1 lines of 'won' chars ----
proc FillBuf(integer bufId)
    integer a, k
    string s[255]
    s = ""
    for k = 1 to gCHAR
        s = s + Chr(0x80)   // high bit set, data bits all zero = won
    endfor
    GotoBufferId(bufId)
    for a = 0 to gLIMIT
        AddLine(s)
    endfor
end

proc Main()
    integer x, y, z
    integer isP
    integer ansS
    integer yx, zy, zx
    string ansSt[40]
    string rowX_one[255]    // gBufOne row x    (checks one[x][z])
    string rowY_one[255]    // gBufOne row y    (checks one[y][z])
    string rowYX_two[255]   // gBufTwo row y-x  (checks two[y-x][z])
    string rowX_twoT[255]   // gBufTwoT row x   (checks two[z-y][x])
    string rowY_twoT[255]   // gBufTwoT row y   (checks two[z-x][y])
    string rowYX_all[255]   // gBufAll row y-x  (checks all[y-x][z-x])
    integer needReload

    gLIMIT = 1000
    gBPC   = 7
    gCHAR  = (gLIMIT / gBPC) + 1   // = 143

    // Create and initialise the four marker buffers
    Message("Creating buffers...")
    gBufOne  = CreateTempBuffer()
    gBufTwo  = CreateTempBuffer()
    gBufTwoT = CreateTempBuffer()
    gBufAll  = CreateTempBuffer()
    if gBufOne == 0 or gBufTwo == 0 or gBufTwoT == 0 or gBufAll == 0
        Message("Cannot create buffers - aborting")
        return()
    endif

    FillBuf(gBufOne)
    FillBuf(gBufTwo)
    FillBuf(gBufTwoT)
    FillBuf(gBufAll)

    Message("Starting O(N^3) DP...")

    ansS = 0

    for x = 0 to gLIMIT

        for y = x to gLIMIT

            yx = y - x

            // Load ALL 6 rows fresh each y (rowX_one/rowX_twoT can be
            // modified by previous y iterations via PutLost, so must reload)
            rowX_one  = FetchRow(gBufOne,  x)
            rowX_twoT = FetchRow(gBufTwoT, x)

            // Skip entire z-loop if one[x][y] already lost
            if ChkRow(rowX_one, y) == 0

                // Load 4 more rows fixed for this (x,y) pair
                rowY_one  = FetchRow(gBufOne,  y)
                rowYX_two = FetchRow(gBufTwo,  yx)
                rowY_twoT = FetchRow(gBufTwoT, y)
                rowYX_all = FetchRow(gBufAll,  yx)

                needReload = FALSE

                for z = y to gLIMIT

                    // Reload cached rows after any P-pos marking
                    if needReload
                        rowX_one  = FetchRow(gBufOne,  x)
                        rowY_one  = FetchRow(gBufOne,  y)
                        rowYX_two = FetchRow(gBufTwo,  yx)
                        rowX_twoT = FetchRow(gBufTwoT, x)
                        rowY_twoT = FetchRow(gBufTwoT, y)
                        rowYX_all = FetchRow(gBufAll,  yx)
                        needReload = FALSE
                        // Python re-checks one[x][y] after each marking:
                        // if it became lost, exit z-loop immediately
                        if ChkRow(rowX_one, y)
                            goto DoneZ
                        endif
                    endif

                    zy = z - y
                    zx = z - x

                    // Check all 7 conditions - position is P iff all pass
                    isP = TRUE

                    // one[y][z]
                    if ChkRow(rowY_one, z)
                        isP = FALSE
                    endif

                    // one[x][z]
                    if isP and ChkRow(rowX_one, z)
                        isP = FALSE
                    endif

                    // two[y-x][z]
                    if isP and ChkRow(rowYX_two, z)
                        isP = FALSE
                    endif

                    // two[z-y][x] = two_T[x][z-y]
                    if isP and ChkRow(rowX_twoT, zy)
                        isP = FALSE
                    endif

                    // two[z-x][y] = two_T[y][z-x]
                    if isP and ChkRow(rowY_twoT, zx)
                        isP = FALSE
                    endif

                    // all_piles[y-x][z-x]
                    if isP and ChkRow(rowYX_all, zx)
                        isP = FALSE
                    endif

                    if isP
                        // P-position (losing for player to move)
                        ansS = ansS + x + y + z

                        // Mark one[y][z], one[x][z], one[x][y]
                        PutLost(gBufOne, y,  z)
                        PutLost(gBufOne, x,  z)
                        PutLost(gBufOne, x,  y)

                        // Mark two[y-x][z], two[z-y][x], two[z-x][y]
                        PutLost(gBufTwo,  yx, z)
                        PutLost(gBufTwo,  zy, x)
                        PutLost(gBufTwo,  zx, y)

                        // Mark two_T (transposed): two_T[z][y-x], two_T[x][z-y], two_T[y][z-x]
                        PutLost(gBufTwoT, z,  yx)
                        PutLost(gBufTwoT, x,  zy)
                        PutLost(gBufTwoT, y,  zx)

                        // Mark all_piles[y-x][z-x]
                        PutLost(gBufAll,  yx, zx)

                        needReload = TRUE
                    endif

                endfor  // z
                DoneZ:

            endif  // skip if one[x][y] lost

        endfor  // y

        if x mod 50 == 0
            Message("x=" + Str(x) + "/" + Str(gLIMIT) +
                    "  running sum=" + Str(ansS))
        endif

    endfor  // x

    // Cleanup
    GotoBufferId(gBufOne)
    AbandonFile()
    GotoBufferId(gBufTwo)
    AbandonFile()
    GotoBufferId(gBufTwoT)
    AbandonFile()
    GotoBufferId(gBufAll)
    AbandonFile()

    ansSt = Str(ansS)

    CopyToWinClip(ansSt)
    Warn("Project Euler P260 - Stone Game" + Chr(13) +
         "Sum of (x+y+z) for losing configs (x<=y<=z<=1000):" + Chr(13) +
         ansSt)
    CopyToWinClip(ansSt)
end
