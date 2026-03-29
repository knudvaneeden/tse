// ============================================================
// eulerproject0227.s
// Project Euler Problem 227 - The Chase
// ============================================================
// Version   : 1.3
// Date      : 2026-03-29
// Author    : Claude (Anthropic)
// ============================================================
// History:
//   1.0  2026-03-29  Claude (Anthropic) - initial solution
//   1.1  2026-03-29  Claude (Anthropic) - fix FormatResult:
//                    carry propagation + rounding
//   1.2  2026-03-29  Claude (Anthropic) - fix InitBuf:
//                    TSE off-by-one: write index 0 via
//                    BegLine()+KillToEol()+InsertText()
//   1.3  2026-03-29  Claude (Anthropic) - fix SetVal:
//                    replace MarkLine()+InsertText()+DelLine()
//                    with BegLine()+KillToEol()+InsertText().
//                    Add PushPosition/PopPosition+PushBlock/
//                    PopBlock to GetVal and SetVal so they
//                    do not corrupt caller's buffer/position.
// ============================================================
//
// Problem:
//   100 players around table. 2 dice start at opposite positions
//   (gap=50). Each turn: roll 1 -> pass die left, roll 6 ->
//   pass die right, else keep. Game ends when both dice land on
//   same player. Find expected number of turns.
//
// Math:
//   State = gap between dice in [0..50] (100-player ring symmetry).
//   E[0] = 0 (absorbed). Answer = E[50].
//
//   Each die moves: -1 (prob 1/6), 0 (prob 4/6), +1 (prob 1/6).
//   Gap change delta = move1 - move2. Probabilities:
//     delta=-2: 1/36,  delta=-1: 8/36,  delta=0: 18/36,
//     delta=+1: 8/36,  delta=+2: 1/36
//   Reflection: gap > 50  ->  gap = 100 - gap.
//
//   Recurrence:
//     18*E[k] = 36 + E[r(k-2)] + 8*E[r(k-1)] + 8*E[r(k+1)] + E[r(k+2)]
//
//   3-pass integer Gauss-Seidel (32-bit safe, 12+ significant digits):
//   Pass 1  SCALE=10000: max sum ~680M < 2^31
//   Pass 2  SCALE=10000: RHS = R1[k]*10000, max sum ~2M
//   Pass 3  SCALE=10000: RHS = R2[k]*10000, max sum ~4M
//   Combined answer = E1[50]/10000 + F[50]/10^8 + G[50]/10^12
//                   = 3780.618621... -> 3780.618622 (10 sig figs)
//
//   Buffer layout: line (k+1) holds index k, k = 0..50.
//   Line 1 (index 0) = 0 (absorbed state, fixed).
//   InitBuf writes line 1 via BegLine()+KillToEol()+InsertText()
//   to overwrite the blank line that CreateTempBuffer() creates.
//   SetVal uses BegLine()+KillToEol()+InsertText() (NOT MarkLine/
//   InsertText/DelLine which corrupts the buffer).
//   GetVal and SetVal save/restore position+block with
//   PushPosition/PopPosition and PushBlock/PopBlock.
// ============================================================

integer gBufE  = 0
integer gBufF  = 0
integer gBufG  = 0
integer gBufR1 = 0
integer gBufR2 = 0

// ============================================================
// GetVal: read integer at line (k+1) of buffer bufId.
// Saves and restores caller's buffer/position/block.
// ============================================================
integer proc GetVal( integer bufId, integer k )
    string sLine[20] = ""
    PushPosition()
    PushBlock()
    GotoBufferId( bufId )
    GotoLine( k + 1 )
    BegLine()
    sLine = GetText( 1, CurrLineLen() )
    PopBlock()
    PopPosition()
    return( Val( sLine ) )
end

// ============================================================
// SetVal: write integer v at line (k+1) of buffer bufId.
// Uses BegLine()+KillToEol()+InsertText() to replace line
// content in place (correct TSE idiom for line replacement).
// Saves and restores caller's buffer/position/block.
// ============================================================
proc SetVal( integer bufId, integer k, integer v )
    PushPosition()
    PushBlock()
    GotoBufferId( bufId )
    GotoLine( k + 1 )
    BegLine()
    KillToEol()
    InsertText( Str( v ), _INSERT_ )
    PopBlock()
    PopPosition()
end

// ============================================================
// InitBuf: create temp buffer with 51 lines (indices 0..50).
//   Index 0 (line 1): always 0 (absorbed state).
//   Indices 1..50 (lines 2..51): initVal.
//
//   CreateTempBuffer() starts with 1 blank line already present.
//   Index 0 is written by overwriting that blank line via
//   BegLine()+KillToEol()+InsertText() (NOT AddLine() which
//   would shift everything by 1).
//   Indices 1..50 are appended with AddLine().
// ============================================================
integer proc InitBuf( integer initVal )
    integer newBuf, i
    newBuf = CreateTempBuffer()
    GotoBufferId( newBuf )
    // Overwrite the existing blank line 1 -> index 0 = 0
    BegLine()
    KillToEol()
    InsertText( "0", _INSERT_ )
    // Append indices 1..50
    i = 1
    while i <= 50
        AddLine( Str( initVal ) )
        i = i + 1
    endwhile
    return( newBuf )
end

// ============================================================
// Reflect: map gap g into [0..50] on 100-player ring
// ============================================================
integer proc Reflect( integer g )
    integer r
    r = g
    if r < 0
        r = -r
    endif
    r = r mod 100
    if r > 50
        r = 100 - r
    endif
    return( r )
end

// ============================================================
// RunPass: Gauss-Seidel relaxation until convergence.
//   Pass 1 (rhsBuf==0):   rhs = 36*SCALE
//   Passes 2,3 (rhsBuf<>0): rhs = R[k]*rhsScale
// ============================================================
proc RunPass( integer vBuf, integer rhsBuf,
              integer rhsScale, integer SCALE )
    integer maxDelta, nIter, k
    integer e0, e1, e3, e4, newV, oldV, delta, rhs, curRhs

    maxDelta = 1
    nIter    = 0
    while maxDelta > 0 and nIter < 300000
        maxDelta = 0
        k = 1
        while k <= 50
            e0 = GetVal( vBuf, Reflect( k - 2 ) )
            e1 = GetVal( vBuf, Reflect( k - 1 ) )
            e3 = GetVal( vBuf, Reflect( k + 1 ) )
            e4 = GetVal( vBuf, Reflect( k + 2 ) )
            if rhsBuf == 0
                rhs = 36 * SCALE
            else
                curRhs = GetVal( rhsBuf, k )
                rhs = curRhs * rhsScale
            endif
            newV = ( rhs + e0 + 8 * e1 + 8 * e3 + e4 ) / 18
            oldV = GetVal( vBuf, k )
            delta = newV - oldV
            if delta < 0
                delta = -delta
            endif
            if delta > maxDelta
                maxDelta = delta
            endif
            SetVal( vBuf, k, newV )
            k = k + 1
        endwhile
        nIter = nIter + 1
    endwhile
end

// ============================================================
// ComputeRemainders: store (rhs + sum_of_neighbors) mod 18
// in outBuf[k] for each k in 1..50.
// ============================================================
proc ComputeRemainders( integer vBuf, integer rhsBuf,
                        integer rhsScale, integer SCALE,
                        integer outBuf )
    integer k, e0, e1, e3, e4, s, rhs, curRhs
    k = 1
    while k <= 50
        e0 = GetVal( vBuf, Reflect( k - 2 ) )
        e1 = GetVal( vBuf, Reflect( k - 1 ) )
        e3 = GetVal( vBuf, Reflect( k + 1 ) )
        e4 = GetVal( vBuf, Reflect( k + 2 ) )
        if rhsBuf == 0
            rhs = 36 * SCALE
        else
            curRhs = GetVal( rhsBuf, k )
            rhs = curRhs * rhsScale
        endif
        s = rhs + e0 + 8 * e1 + 8 * e3 + e4
        SetVal( outBuf, k, s mod 18 )
        k = k + 1
    endwhile
end

// ============================================================
// FormatResult: build 10-significant-digit string.
// Carries overflows from g50->f50->d1->intPart, then
// builds 12 fractional digits and rounds at the 7th.
// ============================================================
string proc FormatResult( integer e50, integer f50, integer g50 )
    integer S
    integer gCarry, gRem, fAdj, fCarry, fRem
    integer d1Adj, d1Carry, d1Rem, intAdj
    integer frac6, roundDigit
    string sInt[10]    = ""
    string sD1[4]      = ""
    string sFgr[4]     = ""
    string sGgr[4]     = ""
    string sFrac12[12] = ""
    string sF6[6]      = ""
    string sResult[20] = ""

    S = 10000

    gCarry  = g50 / S
    gRem    = g50 mod S

    fAdj    = f50 + gCarry
    fCarry  = fAdj / S
    fRem    = fAdj mod S

    d1Adj   = ( e50 mod S ) + fCarry
    d1Carry = d1Adj / S
    d1Rem   = d1Adj mod S

    intAdj  = e50 / S + d1Carry

    sD1   = Format( d1Rem:4:"0" )
    sFgr  = Format( fRem:4:"0" )
    sGgr  = Format( gRem:4:"0" )

    sFrac12 = sD1 + sFgr + sGgr

    frac6      = Val( SubStr( sFrac12, 1, 6 ) )
    roundDigit = Val( SubStr( sFrac12, 7, 1 ) )
    if roundDigit >= 5
        frac6 = frac6 + 1
        if frac6 >= 1000000
            frac6  = 0
            intAdj = intAdj + 1
        endif
    endif

    sInt    = Str( intAdj )
    sF6     = Format( frac6:6:"0" )
    sResult = sInt + "." + sF6
    return( sResult )
end

// ============================================================
proc Main()
    integer e50, f50, g50
    string sAnswer[20] = ""

    // Pass 1: SCALE=10000, initial guess=10000000
    gBufE  = InitBuf( 10000 * 1000 )
    RunPass( gBufE, 0, 0, 10000 )

    gBufR1 = InitBuf( 0 )
    ComputeRemainders( gBufE, 0, 0, 10000, gBufR1 )

    // Pass 2: SCALE=10000, RHS=R1[k]*10000, initial guess=1000
    gBufF  = InitBuf( 1000 )
    RunPass( gBufF, gBufR1, 10000, 10000 )

    gBufR2 = InitBuf( 0 )
    ComputeRemainders( gBufF, gBufR1, 10000, 10000, gBufR2 )

    // Pass 3: SCALE=10000, RHS=R2[k]*10000, initial guess=1000
    gBufG  = InitBuf( 1000 )
    RunPass( gBufG, gBufR2, 10000, 10000 )

    e50 = GetVal( gBufE, 50 )
    f50 = GetVal( gBufF, 50 )
    g50 = GetVal( gBufG, 50 )

    sAnswer = FormatResult( e50, f50, g50 )

    AbandonFile( gBufE  )
    AbandonFile( gBufF  )
    AbandonFile( gBufG  )
    AbandonFile( gBufR1 )
    AbandonFile( gBufR2 )

    CopyToWinClip( sAnswer )
    Warn( sAnswer )
    CopyToWinClip( sAnswer )
end
