// ============================================================
// Project Euler Problem 217 - Balanced Numbers
// ============================================================
// A k-digit positive integer is balanced if its first ceil(k/2)
// digits sum to the same as its last ceil(k/2) digits.
// Find T(47) mod 3^15, where T(n) = sum of all balanced numbers
// less than 10^n.
//
// Method: Digit DP split on left/right halves.
//   Even n=2m : left m digits (no leading zero) + right m digits.
//               Match on digit sum s.
//   Odd  n=2m-1: [left tail: m-1 digits][dMid][right tail: m-1 digits].
//               Condition: sum(left_tail) = sum(right_tail).
//               dMid starts at 1 when m=1 (single-digit numbers).
//
// DP state per half: cnt[s] = count of sequences with digit sum s
//                   val[s] = total positional value of those sequences
// Both stored mod M = 3^15 = 14348907.
//
// Combine: T_n = sum_s { val_L[s]*cnt_R[s] + cnt_L[s]*val_R[s] }
//          For odd: add dMid * midPlace * cnt_L[s] * cnt_R[s].
//
// Verification: T(1)=45, T(2)=540, T(5) mod M = 4771029.
// Answer: T(47) mod 3^15 = 6273134
//
// <version>1.0.0.0.4</version>
// <created_by>Claude (Anthropic)</created_by>
// <history>
//   1.0.0.0.1 - Initial draft by Claude (Anthropic)
//   1.0.0.0.2 - Fixed: declarations at proc top; dMid start for n=1
//   1.0.0.0.3 - Full rules check; final clean version
//   1.0.0.0.4 - Fixed: MOD renamed to MODULUS (MOD is SAL reserved keyword)
// </history>
// ============================================================

integer MODULUS           = 14348907   // 3^15
integer MAX_SUM       = 220        // max half digit-sum (9*24+spare)

// Global DP buffers (line s+1 holds value for digit sum s)
integer gCntBufI      = 0
integer gValBufI      = 0
integer gNewCntBufI   = 0
integer gNewValBufI   = 0

integer gTotLowI      = 0

// ============================================================
// MulMod: compute (aI * bI) mod MODULUS safely
// Uses Russian peasant to avoid 32-bit overflow.
// MODULUS = 14348907 < 2^24; direct multiply can reach ~2^48.
// ============================================================
integer proc MulMod( integer aI, integer bI )
    integer resultI
    integer aaI
    integer bbI
    //
    resultI = 0
    aaI     = aI mod MODULUS
    bbI     = bI mod MODULUS
    while bbI > 0
        if ( bbI & 1 ) == 1
            resultI = ( resultI + aaI ) mod MODULUS
        endif
        aaI = ( aaI + aaI ) mod MODULUS
        bbI = bbI shr 1
    endwhile
    return( resultI )
end

// ============================================================
// SetLine: write integer nI to line lineI of buffer bufI
// Uses BegLine + KillToEol + InsertText idiom.
// ============================================================
proc SetLine( integer bufI, integer lineI, integer nI )
    integer savedI
    //
    savedI = GotoBufferId( bufI )
    GotoLine( lineI )
    BegLine()
    KillToEol()
    InsertText( Str( nI ) )
    GotoBufferId( savedI )
end

// ============================================================
// GetLine: read integer from line lineI of buffer bufI
// ============================================================
integer proc GetLine( integer bufI, integer lineI )
    integer savedI
    integer nI
    //
    savedI = GotoBufferId( bufI )
    GotoLine( lineI )
    nI = Val( GetText( 1, CurrLineLen() ) )
    GotoBufferId( savedI )
    return( nI )
end

// ============================================================
// InitDPBuf: reset buffer to numLinesI lines each containing "0"
// ============================================================
proc InitDPBuf( integer bufI, integer numLinesI )
    integer iI
    integer savedI
    //
    savedI = GotoBufferId( bufI )
    EmptyBuffer()
    for iI = 1 to numLinesI
        AddLine( "0" )
    endfor
    GotoBufferId( savedI )
end

// ============================================================
// CopyBuf: duplicate MAX_SUM+1 lines from srcI into dstI
// ============================================================
proc CopyBuf( integer srcI, integer dstI )
    integer savedI
    integer iI
    integer nLinesI
    integer vI
    //
    nLinesI = MAX_SUM + 1
    savedI  = GotoBufferId( srcI )
    GotoLine( 1 )
    GotoBufferId( dstI )
    EmptyBuffer()
    GotoBufferId( srcI )
    GotoLine( 1 )
    for iI = 1 to nLinesI
        vI = Val( GetText( 1, CurrLineLen() ) )
        GotoBufferId( dstI )
        AddLine( Str( vI ) )
        GotoBufferId( srcI )
        Down()
    endfor
    GotoBufferId( savedI )
end

// ============================================================
// BuildHalf: Digit DP for one half of nDigitsI digits.
//
// firstNoZeroB: TRUE  -> first digit in 1..9 (leading digit of number)
//               FALSE -> first digit in 0..9
// placesBufI: line i holds 10^(place of i-th digit) mod MODULUS
//
// After return:
//   gCntBufI[s+1] = count of digit sequences with sum s  (mod M)
//   gValBufI[s+1] = sum of positional values of those sequences (mod M)
// ============================================================
proc BuildHalf( integer nDigitsI, integer firstNoZeroB, integer placesBufI )
    integer iI
    integer dI
    integer sI
    integer placeI
    integer oldCntI
    integer oldValI
    integer newCntI
    integer newValI
    integer dStartI
    //
    InitDPBuf( gCntBufI,    MAX_SUM + 1 )
    InitDPBuf( gValBufI,    MAX_SUM + 1 )
    InitDPBuf( gNewCntBufI, MAX_SUM + 1 )
    InitDPBuf( gNewValBufI, MAX_SUM + 1 )
    SetLine( gCntBufI, 1, 1 )    // sum=0: one empty sequence, val=0

    for iI = 1 to nDigitsI
        InitDPBuf( gNewCntBufI, MAX_SUM + 1 )
        InitDPBuf( gNewValBufI, MAX_SUM + 1 )
        placeI  = GetLine( placesBufI, iI )
        if iI == 1 and firstNoZeroB
            dStartI = 1
        else
            dStartI = 0
        endif
        for sI = 0 to MAX_SUM
            oldCntI = GetLine( gCntBufI, sI + 1 )
            if oldCntI > 0
                oldValI = GetLine( gValBufI, sI + 1 )
                for dI = dStartI to 9
                    if sI + dI <= MAX_SUM
                        newCntI = ( GetLine( gNewCntBufI, sI + dI + 1 ) + oldCntI ) mod MODULUS
                        SetLine( gNewCntBufI, sI + dI + 1, newCntI )
                        newValI = GetLine( gNewValBufI, sI + dI + 1 )
                        newValI = ( newValI + oldValI ) mod MODULUS
                        newValI = ( newValI + MulMod( MulMod( dI, placeI ), oldCntI ) ) mod MODULUS
                        SetLine( gNewValBufI, sI + dI + 1, newValI )
                    endif
                endfor
            endif
        endfor
        CopyBuf( gNewCntBufI, gCntBufI )
        CopyBuf( gNewValBufI, gValBufI )
    endfor
end

// ============================================================
// ProcessLengthOdd: sum contribution of all balanced n-digit numbers
//   where n is odd.
//
// Structure: [left_tail: m-1 digits][dMid][right_tail: m-1 digits]
//   m = ceil(n/2);  n = 2*m-1
// Condition: sum(left_tail) = sum(right_tail)  (dMid cancels)
// Value:     val(left_tail) + dMid*10^(m-1) + val(right_tail)
//
// Special case n=1 (m=1): no tails, dMid in 1..9 (no leading zero).
// ============================================================
proc ProcessLengthOdd( integer nI )
    integer mI
    integer dMidI
    integer sI
    integer cntLI
    integer valLI
    integer cntRI
    integer valRI
    integer contribI
    integer jI
    integer pI
    integer midPlaceI
    integer totalCntI
    integer termI
    integer dMidStartI
    integer placesBufAllI
    integer placesBufLI
    integer placesBufRI
    integer cntSaveBufI
    integer valSaveBufI
    //
    mI = ( nI + 1 ) / 2

    // Build place value table: line j+1 = 10^j mod MODULUS
    placesBufAllI = CreateTempBuffer()
    GotoBufferId( placesBufAllI )
    EmptyBuffer()
    pI = 1
    for jI = 0 to nI - 1
        AddLine( Str( pI ) )
        pI = MulMod( pI, 10 )
    endfor

    // Middle digit place value: 10^(m-1)
    midPlaceI = GetLine( placesBufAllI, mI )

    // Left tail places: 10^(n-1) downto 10^m  [m-1 entries]
    placesBufLI = CreateTempBuffer()
    GotoBufferId( placesBufLI )
    EmptyBuffer()
    for jI = nI - 1 downto nI - ( mI - 1 )
        AddLine( Str( GetLine( placesBufAllI, jI + 1 ) ) )
    endfor

    // Right tail places: 10^(m-2) downto 10^0  [m-1 entries]
    placesBufRI = CreateTempBuffer()
    GotoBufferId( placesBufRI )
    EmptyBuffer()
    for jI = mI - 2 downto 0
        AddLine( Str( GetLine( placesBufAllI, jI + 1 ) ) )
    endfor

    cntSaveBufI = CreateTempBuffer()
    valSaveBufI = CreateTempBuffer()

    // n=1 (m=1): dMid is the sole digit, must be non-zero
    if mI == 1
        dMidStartI = 1
    else
        dMidStartI = 0
    endif

    contribI = 0

    for dMidI = dMidStartI to 9
        // Left tail DP
        if mI - 1 > 0
            BuildHalf( mI - 1, TRUE, placesBufLI )
        else
            InitDPBuf( gCntBufI, MAX_SUM + 1 )
            InitDPBuf( gValBufI, MAX_SUM + 1 )
            SetLine( gCntBufI, 1, 1 )
        endif
        CopyBuf( gCntBufI, cntSaveBufI )
        CopyBuf( gValBufI, valSaveBufI )

        // Right tail DP
        if mI - 1 > 0
            BuildHalf( mI - 1, FALSE, placesBufRI )
        else
            InitDPBuf( gCntBufI, MAX_SUM + 1 )
            InitDPBuf( gValBufI, MAX_SUM + 1 )
            SetLine( gCntBufI, 1, 1 )
        endif

        // Combine matched sums
        for sI = 0 to MAX_SUM
            cntLI = GetLine( cntSaveBufI, sI + 1 )
            valLI = GetLine( valSaveBufI, sI + 1 )
            cntRI = GetLine( gCntBufI,    sI + 1 )
            valRI = GetLine( gValBufI,    sI + 1 )
            if cntLI > 0 and cntRI > 0
                totalCntI = MulMod( cntLI, cntRI )
                termI     = MulMod( valLI, cntRI )
                termI     = ( termI + MulMod( cntLI, valRI ) ) mod MODULUS
                termI     = ( termI + MulMod( MulMod( dMidI, midPlaceI ), totalCntI ) ) mod MODULUS
                contribI  = ( contribI + termI ) mod MODULUS
            endif
        endfor
    endfor

    AbandonFile( placesBufAllI )
    AbandonFile( placesBufLI )
    AbandonFile( placesBufRI )
    AbandonFile( cntSaveBufI )
    AbandonFile( valSaveBufI )

    gTotLowI = ( gTotLowI + contribI ) mod MODULUS
end

// ============================================================
// ProcessLengthEven: sum contribution of all balanced n-digit numbers
//   where n is even.
//
// Structure: [left: m digits (no leading zero)][right: m digits]
//   m = n/2
// Condition: sum(left) = sum(right)
// Value:     val(left) + val(right)   (place values are absolute)
// ============================================================
proc ProcessLengthEven( integer nI )
    integer mI
    integer sI
    integer cntLI
    integer valLI
    integer cntRI
    integer valRI
    integer contribI
    integer jI
    integer pI
    integer placesBufAllI
    integer placesBufLI
    integer placesBufRI
    integer cntSaveBufI
    integer valSaveBufI
    //
    mI = nI / 2

    placesBufAllI = CreateTempBuffer()
    GotoBufferId( placesBufAllI )
    EmptyBuffer()
    pI = 1
    for jI = 0 to nI - 1
        AddLine( Str( pI ) )
        pI = MulMod( pI, 10 )
    endfor

    // Left half places: 10^(n-1) downto 10^m  [m entries]
    placesBufLI = CreateTempBuffer()
    GotoBufferId( placesBufLI )
    EmptyBuffer()
    for jI = nI - 1 downto mI
        AddLine( Str( GetLine( placesBufAllI, jI + 1 ) ) )
    endfor

    // Right half places: 10^(m-1) downto 10^0  [m entries]
    placesBufRI = CreateTempBuffer()
    GotoBufferId( placesBufRI )
    EmptyBuffer()
    for jI = mI - 1 downto 0
        AddLine( Str( GetLine( placesBufAllI, jI + 1 ) ) )
    endfor

    cntSaveBufI = CreateTempBuffer()
    valSaveBufI = CreateTempBuffer()

    BuildHalf( mI, TRUE,  placesBufLI )
    CopyBuf( gCntBufI, cntSaveBufI )
    CopyBuf( gValBufI, valSaveBufI )

    BuildHalf( mI, FALSE, placesBufRI )

    contribI = 0
    for sI = 0 to MAX_SUM
        cntLI = GetLine( cntSaveBufI, sI + 1 )
        valLI = GetLine( valSaveBufI, sI + 1 )
        cntRI = GetLine( gCntBufI,    sI + 1 )
        valRI = GetLine( gValBufI,    sI + 1 )
        if cntLI > 0 and cntRI > 0
            contribI = ( contribI + MulMod( valLI, cntRI ) ) mod MODULUS
            contribI = ( contribI + MulMod( cntLI, valRI ) ) mod MODULUS
        endif
    endfor

    AbandonFile( placesBufAllI )
    AbandonFile( placesBufLI )
    AbandonFile( placesBufRI )
    AbandonFile( cntSaveBufI )
    AbandonFile( valSaveBufI )

    gTotLowI = ( gTotLowI + contribI ) mod MODULUS
end

// ============================================================
proc Main()
    integer nI
    integer ansI
    string  ansS[30]
    //
    gCntBufI    = CreateTempBuffer()
    gValBufI    = CreateTempBuffer()
    gNewCntBufI = CreateTempBuffer()
    gNewValBufI = CreateTempBuffer()

    InitDPBuf( gCntBufI,    MAX_SUM + 1 )
    InitDPBuf( gValBufI,    MAX_SUM + 1 )
    InitDPBuf( gNewCntBufI, MAX_SUM + 1 )
    InitDPBuf( gNewValBufI, MAX_SUM + 1 )

    gTotLowI = 0

    for nI = 1 to 47
        if ( nI mod 2 ) == 1
            ProcessLengthOdd( nI )
        else
            ProcessLengthEven( nI )
        endif
    endfor

    ansI = gTotLowI mod MODULUS
    ansS = Str( ansI )

    CopyToWinClip( ansS )
    Warn( "P217 T(47) mod 3^15 = ", ansS )
    CopyToWinClip( ansS )

    AbandonFile( gCntBufI )
    AbandonFile( gValBufI )
    AbandonFile( gNewCntBufI )
    AbandonFile( gNewValBufI )
end
