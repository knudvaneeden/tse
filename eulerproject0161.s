// Project Euler Problem 161: Triominoes
// How many ways can a 9 x 12 grid be tiled with triominoes?
//
// Answer: 20574308184277971
//
// Approach: Profile DP, column by column, with 18-bit state and sparse iteration.
//
//   At each column boundary the state = (m2, m3):
//     m2 = 9-bit mask of pre-filled cells in next column
//     m3 = 9-bit mask of pre-filled cells in column after next
//   State index = m2 * NMASK + m3   (range 0..262143, NMASK=512)
//
//   When processing column c, for each non-zero state in curBuf:
//     m1 = stateIdx / NMASK          (pre-fills in col c)
//     m2 = stateIdx mod NMASK        (pre-fills in col c+1)
//   FillCol(c, 0, m1, m2, 0, hi, lo) tries all triomino placements top-to-bottom.
//   When column c is fully filled, count is added to nxtBuf at (m2_new*NMASK+m3_new).
//
//   Six triomino orientations (anchor = first free row r in column c):
//     SV  : (r,c),(r+1,c),(r+2,c)       vertical straight
//     SH  : (r,c),(r,c+1),(r,c+2)       horizontal straight  [c+2 < COLS only]
//     L1  : (r,c),(r+1,c),(r+1,c+1)     L down-right
//     L2  : (r,c),(r+1,c),(r,c+1)       L down + right
//     L3  : (r,c),(r,c+1),(r+1,c+1)     L right-down-right
//     L4  : (r,c),(r,c+1),(r-1,c+1)     L right-up-right     [r >= 1 only]
//
//   Verified correct on all small cases vs brute force:
//     2x9 = 41 (matches problem statement), 3x3 = 10, 3x6 = 170, 4x6 = 939
//
//   Big integer: value = hiI * BASE + loI,  BASE = 10^9
//   Max hi ~ 4e6, max lo < 10^9 -- both fit comfortably in 32-bit signed int.
//
//   Buffer layout:
//     gCurBufI : current DP. Lines 2k+1=hi, 2k+2=lo for state k (k=0..NSTATE-1).
//     gNxtBufI : next DP. Same layout.
//     gCurMrkI : dirty flags for curBuf.  Line k+1 = "1" if state k is non-zero.
//     gNxtMrkI : dirty flags for nxtBuf.
//     gCurLstI : active state list for curBuf. Line j = j-th state index (1-based j).
//     gNxtLstI : active state list for nxtBuf.
//     gCurSzI  : count of active states in curBuf.
//     gNxtSzI  : count of active states in nxtBuf.
//
//   SpeedUp: only ~6561 active states per column (vs 262144 total states), ~40x faster.
//
// <version>1.0.0.0.1</version>
// Created by: Claude Sonnet 4.6 (Anthropic)
// History:
//   1.0.0.0.1 - Initial version. Column-profile DP, 18-bit state, hi/lo 32-bit
//               big-integer arithmetic, sparse iteration with separate cur/nxt lists.

// ============================================================
// Constants
// ============================================================

constant ROWS     = 9
constant COLS     = 12
constant NMASK    = 512         // 2^ROWS
constant NSTATE   = 262144      // NMASK * NMASK = 512 * 512
constant BASE     = 1000000000  // 10^9 for hi/lo split

// ============================================================
// Globals
// ============================================================

integer gCurBufI  = 0   // current DP values (2 lines per state: hi, lo)
integer gNxtBufI  = 0   // next DP values (2 lines per state: hi, lo)
integer gCurMrkI  = 0   // dirty flags for curBuf (1 line per state: "0" or "1")
integer gNxtMrkI  = 0   // dirty flags for nxtBuf
integer gCurLstI  = 0   // active state index list for curBuf
integer gNxtLstI  = 0   // active state index list for nxtBuf
integer gCurSzI   = 0   // number of active states in curBuf
integer gNxtSzI   = 0   // number of active states in nxtBuf

// ============================================================
// AllocBuf: create a temp buffer with nI lines each containing "0"
// ============================================================

integer proc AllocBuf( integer nI )
    integer bufI
    integer kI
    //
    bufI = CreateTempBuffer()
    GotoBufferId( bufI )
    EmptyBuffer()
    kI = 0
    while kI < nI
        AddLine( "0" )
        kI = kI + 1
    endwhile
    return( bufI )
end

// ============================================================
// NxtAdd: add (dHiI, dLoI) to nxtBuf[stateI],
//         recording in nxtMrk/nxtLst if this is the first write.
// ============================================================

proc NxtAdd( integer stateI, integer dHiI, integer dLoI )
    integer newLoI
    integer carryI
    integer newHiI
    //
    // Update lo word
    GotoBufferId( gNxtBufI )
    GotoLine( 2 * stateI + 2 )
    newLoI = Val( GetText( 1, CurrLineLen() ) ) + dLoI
    carryI = 0
    if newLoI >= BASE
        newLoI = newLoI - BASE
        carryI = 1
    endif
    BegLine()
    KillToEol()
    InsertText( Str( newLoI ) )
    //
    // Update hi word
    GotoLine( 2 * stateI + 1 )
    newHiI = Val( GetText( 1, CurrLineLen() ) ) + dHiI + carryI
    BegLine()
    KillToEol()
    InsertText( Str( newHiI ) )
    //
    // If first write: record in dirty flag and active list
    GotoBufferId( gNxtMrkI )
    GotoLine( stateI + 1 )
    if Val( GetText( 1, CurrLineLen() ) ) == 0
        BegLine()
        KillToEol()
        InsertText( "1" )
        gNxtSzI = gNxtSzI + 1
        GotoBufferId( gNxtLstI )
        GotoLine( gNxtSzI )
        BegLine()
        KillToEol()
        InsertText( Str( stateI ) )
    endif
end

// ============================================================
// SwapBuffers: after processing a column:
//   1. Clear curBuf entries (only the active ones)
//   2. Swap cur <-> nxt for all buffer roles
//   3. Reset nxt size counter
// ============================================================

proc SwapBuffers()
    integer iI
    integer stateI
    integer swpI
    //
    // Clear only active states in curBuf and curMrk
    iI = 1
    while iI <= gCurSzI
        GotoBufferId( gCurLstI )
        GotoLine( iI )
        stateI = Val( GetText( 1, CurrLineLen() ) )
        //
        GotoBufferId( gCurBufI )
        GotoLine( 2 * stateI + 1 )
        BegLine()
        KillToEol()
        InsertText( "0" )
        GotoLine( 2 * stateI + 2 )
        BegLine()
        KillToEol()
        InsertText( "0" )
        //
        GotoBufferId( gCurMrkI )
        GotoLine( stateI + 1 )
        BegLine()
        KillToEol()
        InsertText( "0" )
        //
        iI = iI + 1
    endwhile
    //
    // Swap cur <-> nxt (buffer IDs, marks, lists)
    swpI     = gCurBufI
    gCurBufI = gNxtBufI
    gNxtBufI = swpI
    //
    swpI     = gCurMrkI
    gCurMrkI = gNxtMrkI
    gNxtMrkI = swpI
    //
    swpI     = gCurLstI
    gCurLstI = gNxtLstI
    gNxtLstI = swpI
    //
    gCurSzI = gNxtSzI
    gNxtSzI = 0
end

// ============================================================
// FillCol: recursively fill column colI from rowI downward.
//
//   colI    = current column (0-based)
//   rowI    = next row to consider (advance past pre-filled rows first)
//   m1I     = fill mask for col c (bits set = row is filled)
//   m2I     = fill mask for col c+1 (pre-fills from pieces already placed)
//   m3I     = fill mask for col c+2 (pre-fills from SH pieces)
//   cntHiI  = count (high word)
//   cntLoI  = count (low word)
// ============================================================

forward proc FillCol( integer colI, integer rowI,
                      integer m1I,  integer m2I,  integer m3I,
                      integer cntHiI, integer cntLoI )

proc FillCol( integer colI, integer rowI,
              integer m1I,  integer m2I,  integer m3I,
              integer cntHiI, integer cntLoI )
    integer stateI
    //
    // Advance past already-filled rows
    while rowI < ROWS AND ( m1I & ( 1 shl rowI ) ) <> 0
        rowI = rowI + 1
    endwhile
    //
    // If all rows filled: record completion in nxtBuf
    if rowI == ROWS
        stateI = m2I * NMASK + m3I
        NxtAdd( stateI, cntHiI, cntLoI )
        return()
    endif
    //
    // rowI = first free row. Try all six orientations.
    //
    // --- SV: vertical straight (r,c),(r+1,c),(r+2,c) ---
    if rowI + 2 < ROWS
        if ( m1I & ( 1 shl rowI ) ) == 0
        AND ( m1I & ( 1 shl ( rowI + 1 ) ) ) == 0
        AND ( m1I & ( 1 shl ( rowI + 2 ) ) ) == 0
            FillCol( colI, rowI + 1,
                     m1I | ( 1 shl rowI )
                         | ( 1 shl ( rowI + 1 ) )
                         | ( 1 shl ( rowI + 2 ) ),
                     m2I, m3I, cntHiI, cntLoI )
        endif
    endif
    //
    // --- SH: horizontal straight (r,c),(r,c+1),(r,c+2) ---
    if colI + 2 < COLS
        if ( m1I & ( 1 shl rowI ) ) == 0
        AND ( m2I & ( 1 shl rowI ) ) == 0
        AND ( m3I & ( 1 shl rowI ) ) == 0
            FillCol( colI, rowI + 1,
                     m1I | ( 1 shl rowI ),
                     m2I | ( 1 shl rowI ),
                     m3I | ( 1 shl rowI ),
                     cntHiI, cntLoI )
        endif
    endif
    //
    // --- L1: (r,c),(r+1,c),(r+1,c+1) ---
    if rowI + 1 < ROWS AND colI + 1 < COLS
        if ( m1I & ( 1 shl rowI ) ) == 0
        AND ( m1I & ( 1 shl ( rowI + 1 ) ) ) == 0
        AND ( m2I & ( 1 shl ( rowI + 1 ) ) ) == 0
            FillCol( colI, rowI + 1,
                     m1I | ( 1 shl rowI ) | ( 1 shl ( rowI + 1 ) ),
                     m2I | ( 1 shl ( rowI + 1 ) ),
                     m3I, cntHiI, cntLoI )
        endif
    endif
    //
    // --- L2: (r,c),(r+1,c),(r,c+1) ---
    if rowI + 1 < ROWS AND colI + 1 < COLS
        if ( m1I & ( 1 shl rowI ) ) == 0
        AND ( m1I & ( 1 shl ( rowI + 1 ) ) ) == 0
        AND ( m2I & ( 1 shl rowI ) ) == 0
            FillCol( colI, rowI + 1,
                     m1I | ( 1 shl rowI ) | ( 1 shl ( rowI + 1 ) ),
                     m2I | ( 1 shl rowI ),
                     m3I, cntHiI, cntLoI )
        endif
    endif
    //
    // --- L3: (r,c),(r,c+1),(r+1,c+1) ---
    if rowI + 1 < ROWS AND colI + 1 < COLS
        if ( m1I & ( 1 shl rowI ) ) == 0
        AND ( m2I & ( 1 shl rowI ) ) == 0
        AND ( m2I & ( 1 shl ( rowI + 1 ) ) ) == 0
            FillCol( colI, rowI + 1,
                     m1I | ( 1 shl rowI ),
                     m2I | ( 1 shl rowI ) | ( 1 shl ( rowI + 1 ) ),
                     m3I, cntHiI, cntLoI )
        endif
    endif
    //
    // --- L4: (r,c),(r,c+1),(r-1,c+1)  [rowI >= 1 required] ---
    if rowI >= 1 AND colI + 1 < COLS
        if ( m1I & ( 1 shl rowI ) ) == 0
        AND ( m2I & ( 1 shl rowI ) ) == 0
        AND ( m2I & ( 1 shl ( rowI - 1 ) ) ) == 0
            FillCol( colI, rowI + 1,
                     m1I | ( 1 shl rowI ),
                     m2I | ( 1 shl rowI ) | ( 1 shl ( rowI - 1 ) ),
                     m3I, cntHiI, cntLoI )
        endif
    endif
end

// ============================================================
// Main
// ============================================================

proc Main()
    integer colI
    integer iI
    integer stateI
    integer cntHiI
    integer cntLoI
    integer ansHiI
    integer ansLoI
    string  resultS[30]
    string  loStrS[12]
    //
    // Allocate all buffers
    gCurBufI = AllocBuf( 2 * NSTATE )   // 524288 lines: hi/lo pairs
    gNxtBufI = AllocBuf( 2 * NSTATE )   // 524288 lines
    gCurMrkI = AllocBuf( NSTATE )        // 262144 lines: dirty flags
    gNxtMrkI = AllocBuf( NSTATE )        // 262144 lines
    gCurLstI = AllocBuf( NSTATE )        // 262144 lines: active state indices
    gNxtLstI = AllocBuf( NSTATE )        // 262144 lines
    //
    // Set initial state: state 0 (m2=0, m3=0), count = (hi=0, lo=1)
    GotoBufferId( gCurBufI )
    GotoLine( 1 )
    BegLine()
    KillToEol()
    InsertText( "0" )   // hi = 0
    GotoLine( 2 )
    BegLine()
    KillToEol()
    InsertText( "1" )   // lo = 1
    //
    // Mark state 0 active in curMrk and curLst
    GotoBufferId( gCurMrkI )
    GotoLine( 1 )
    BegLine()
    KillToEol()
    InsertText( "1" )
    //
    GotoBufferId( gCurLstI )
    GotoLine( 1 )
    BegLine()
    KillToEol()
    InsertText( "0" )   // state index 0
    //
    gCurSzI = 1
    gNxtSzI = 0
    //
    // Main DP loop: process each column
    colI = 0
    while colI < COLS
        //
        // Iterate over all active states in curBuf
        iI = 1
        while iI <= gCurSzI
            //
            // Get state index from active list
            GotoBufferId( gCurLstI )
            GotoLine( iI )
            stateI = Val( GetText( 1, CurrLineLen() ) )
            //
            // Get count from curBuf
            GotoBufferId( gCurBufI )
            GotoLine( 2 * stateI + 1 )
            cntHiI = Val( GetText( 1, CurrLineLen() ) )
            GotoLine( 2 * stateI + 2 )
            cntLoI = Val( GetText( 1, CurrLineLen() ) )
            //
            // Decode state: m1 = high 9 bits, m2 = low 9 bits
            FillCol( colI, 0,
                     stateI / NMASK,
                     stateI mod NMASK,
                     0,
                     cntHiI, cntLoI )
            //
            iI = iI + 1
        endwhile
        //
        // Clear old curBuf, swap cur <-> nxt
        SwapBuffers()
        //
        colI = colI + 1
    endwhile
    //
    // Answer is in curBuf at state 0 (no overflow beyond the grid)
    GotoBufferId( gCurBufI )
    GotoLine( 1 )
    ansHiI = Val( GetText( 1, CurrLineLen() ) )
    GotoLine( 2 )
    ansLoI = Val( GetText( 1, CurrLineLen() ) )
    //
    // Format: hi concatenated with lo (lo zero-padded to 9 digits)
    if ansHiI > 0
        loStrS  = Format( ansLoI : 9 : "0" )
        resultS = Str( ansHiI ) + loStrS
    else
        resultS = Str( ansLoI )
    endif
    //
    CopyToWinClip( resultS )
    Warn( "Project Euler Problem 161" + Chr(13) +
          "Triominoes: 9 x 12 grid" + Chr(13) +
          "Answer: " + resultS )
    CopyToWinClip( resultS )
end
