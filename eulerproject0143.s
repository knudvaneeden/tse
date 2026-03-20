// PE143.S  -  Project Euler Problem 143: Torricelli Triangles
// <version>1.0.0.0.3</version>
// Created by: Claude (Anthropic claude-sonnet-4-6)
// Date: 2026-03-20
//
// Problem:
//   A Torricelli triangle has integer sides a,b,c and integer distances
//   p,q,r from the Torricelli/Fermat point T to each vertex, satisfying
//   the 120-degree law of cosines at T:
//     a^2 = q^2 + q*r + r^2
//     b^2 = p^2 + p*r + r^2
//     c^2 = p^2 + p*q + q^2
//   Find the sum of all distinct p+q+r <= 120000.
//
// Approach:
//   x^2 + x*y + y^2 = z^2 has integer solutions exactly described by
//   the parametric family (gcd(m,n)=1, m>n>0, (m-n) not divisible by 3):
//     x0 = m^2 - n^2
//     y0 = 2*m*n + n^2
//     z0 = m^2 + m*n + n^2
//   and all multiples (k*x0, k*y0) for k=1,2,3,...
//   Maximum m needed: m*(m+2) <= 120000 => m <= 345.
//   No 32-bit overflow: x0,y0,z0 are all below 360000 for m<=346.
//
//   Step 1: Enumerate all valid pairs (x,y) via parametric formula.
//           Store in 3 lookup buffers (gLkp1BufI, gLkp2BufI, gLkp3BufI),
//           each with LIMIT+1 lines. Line x+1 holds 6-digit zero-padded
//           y-values concatenated (42 per line max, 126 total across 3 bufs).
//           Max observed partners per x at LIMIT=120000 is 116 < 126. OK.
//
//   Step 2: For every valid pair (p,q), iterate r over all partners of q.
//           If (p,r) is also a valid pair and p+q+r <= LIMIT, record the sum.
//
//   Step 3: Sum all distinct recorded values.
//
// Expected answer: 30758397
//
// SAL rules applied:
//   - No arrays; temp buffers used throughout
//   - No floats (integers only)
//   - return() always has parentheses
//   - Warn() for final display; CopyToWinClip() for result string only
//   - Reserved words not used as identifiers (val->nValI, pos->curI, etc.)
//   - All local declarations immediately after proc header
//   - shl/shr for bit shifts; ^, &, | for bitwise ops
//   - Format(n:width:"0") for zero-padding
//   - Chr(13) for line breaks inside Warn()
//   - BegLine()+KillToEol()+InsertText() for line replacement
//   - TRUE/FALSE for booleans
//   - Variable names: camelCase locals ending I/S/B; g-prefix globals
//   - AddLine() used to initialise buffers

// ============================================================
// Global buffer IDs
// ============================================================
integer gLkp1BufI  = 0  // lookup buffer 1: line x+1 holds 6-digit y-values (slots 1..42)
integer gLkp2BufI  = 0  // lookup buffer 2: continuation (slots 43..84)
integer gLkp3BufI  = 0  // lookup buffer 3: continuation (slots 85..126)
integer gResultBufI = 0  // one line per distinct p+q+r sum found

// ============================================================
// GCD (Euclidean)
// ============================================================
integer proc FNGcdI( integer aI, integer bI )
    integer tmpI = 0
    //
    while bI <> 0
        tmpI = bI
        bI   = aI mod bI
        aI   = tmpI
    endwhile
    return( aI )
end

// ============================================================
// Initialise a lookup buffer with LIMIT+1 empty lines
// ============================================================
proc PInitLookupBuf( integer bufI )
    integer kI = 0
    //
    GotoBufferId( bufI )
    EmptyBuffer()
    kI = 0
    while kI <= 120000
        AddLine( "" )
        kI = kI + 1
    endwhile
end

// ============================================================
// Append a 6-digit y-entry to the lookup chain for key xI.
// Tries buffer 1 first; if full (>=252 chars), uses buffer 2;
// if buffer 2 full, uses buffer 3.
// ============================================================
proc PAddLookupEntry( integer xI, integer yI )
    string  lineS[255] = ""
    string  entryS[6]  = ""
    integer lenI       = 0
    //
    entryS = Format( yI:6:"0" )
    //
    GotoBufferId( gLkp1BufI )
    GotoLine( xI + 1 )
    lineS = GetText( 1, CurrLineLen() )
    lenI  = Length( lineS )
    if lenI < 252
        BegLine()
        KillToEol()
        InsertText( lineS + entryS )
        return()
    endif
    //
    GotoBufferId( gLkp2BufI )
    GotoLine( xI + 1 )
    lineS = GetText( 1, CurrLineLen() )
    lenI  = Length( lineS )
    if lenI < 252
        BegLine()
        KillToEol()
        InsertText( lineS + entryS )
        return()
    endif
    //
    GotoBufferId( gLkp3BufI )
    GotoLine( xI + 1 )
    lineS = GetText( 1, CurrLineLen() )
    BegLine()
    KillToEol()
    InsertText( lineS + entryS )
end

// ============================================================
// Returns TRUE if (xI, yI) is a stored valid pair.
// Checks all three lookup buffers.
// ============================================================
integer proc FNLookupI( integer xI, integer yI )
    string  lineS[255] = ""
    string  entryS[6]  = ""
    integer lenI       = 0
    integer curI       = 0
    //
    if xI < 1 or xI >= 120000
        return( FALSE )
    endif
    if yI < 1 or yI >= 120000
        return( FALSE )
    endif
    entryS = Format( yI:6:"0" )
    //
    GotoBufferId( gLkp1BufI )
    GotoLine( xI + 1 )
    lineS = GetText( 1, CurrLineLen() )
    lenI  = Length( lineS )
    curI  = 1
    while curI + 5 <= lenI
        if SubStr( lineS, curI, 6 ) == entryS
            return( TRUE )
        endif
        curI = curI + 6
    endwhile
    //
    GotoBufferId( gLkp2BufI )
    GotoLine( xI + 1 )
    lineS = GetText( 1, CurrLineLen() )
    lenI  = Length( lineS )
    curI  = 1
    while curI + 5 <= lenI
        if SubStr( lineS, curI, 6 ) == entryS
            return( TRUE )
        endif
        curI = curI + 6
    endwhile
    //
    GotoBufferId( gLkp3BufI )
    GotoLine( xI + 1 )
    lineS = GetText( 1, CurrLineLen() )
    lenI  = Length( lineS )
    curI  = 1
    while curI + 5 <= lenI
        if SubStr( lineS, curI, 6 ) == entryS
            return( TRUE )
        endif
        curI = curI + 6
    endwhile
    //
    return( FALSE )
end

// ============================================================
// Returns count of partners stored for xI (all 3 buffers)
// ============================================================
integer proc FNCountI( integer xI )
    integer cntI = 0
    //
    GotoBufferId( gLkp1BufI )
    GotoLine( xI + 1 )
    cntI = cntI + CurrLineLen() / 6
    GotoBufferId( gLkp2BufI )
    GotoLine( xI + 1 )
    cntI = cntI + CurrLineLen() / 6
    GotoBufferId( gLkp3BufI )
    GotoLine( xI + 1 )
    cntI = cntI + CurrLineLen() / 6
    return( cntI )
end

// ============================================================
// Returns the kI-th partner (1-based) of xI across all 3 buffers
// ============================================================
integer proc FNGetPartnerI( integer xI, integer kI )
    string  lineS[255] = ""
    integer offsetI    = 0
    integer slotsInBuf = 0
    integer localKI    = 0
    //
    // Buffer 1
    GotoBufferId( gLkp1BufI )
    GotoLine( xI + 1 )
    lineS      = GetText( 1, CurrLineLen() )
    slotsInBuf = Length( lineS ) / 6
    if kI <= slotsInBuf
        offsetI = ( kI - 1 ) * 6 + 1
        return( Val( SubStr( lineS, offsetI, 6 ) ) )
    endif
    kI = kI - slotsInBuf
    //
    // Buffer 2
    GotoBufferId( gLkp2BufI )
    GotoLine( xI + 1 )
    lineS      = GetText( 1, CurrLineLen() )
    slotsInBuf = Length( lineS ) / 6
    if kI <= slotsInBuf
        offsetI = ( kI - 1 ) * 6 + 1
        return( Val( SubStr( lineS, offsetI, 6 ) ) )
    endif
    kI = kI - slotsInBuf
    //
    // Buffer 3
    GotoBufferId( gLkp3BufI )
    GotoLine( xI + 1 )
    lineS   = GetText( 1, CurrLineLen() )
    offsetI = ( kI - 1 ) * 6 + 1
    if offsetI + 5 <= Length( lineS ) + 1
        return( Val( SubStr( lineS, offsetI, 6 ) ) )
    endif
    return( 0 )
end

// ============================================================
// Record a distinct sum in gResultBufI (linear dedup scan)
// ============================================================
proc PRecordSum( integer nI )
    integer numLI  = 0
    integer lineI  = 0
    integer nValI  = 0
    integer foundB = FALSE
    string  lineS[20] = ""
    //
    GotoBufferId( gResultBufI )
    numLI  = NumLines()
    lineI  = 1
    while lineI <= numLI and foundB == FALSE
        GotoLine( lineI )
        lineS = GetText( 1, CurrLineLen() )
        if Length( lineS ) > 0
            nValI = Val( lineS )
            if nValI == nI
                foundB = TRUE
            endif
        endif
        lineI = lineI + 1
    endwhile
    if foundB == FALSE
        GotoBufferId( gResultBufI )
        AddLine( Str( nI ) )
    endif
end

// ============================================================
// Main
// ============================================================
proc Main()
    integer mI       = 0
    integer nI       = 0
    integer x0I      = 0
    integer y0I      = 0
    integer kI       = 0
    integer xI       = 0
    integer yI       = 0
    integer pI       = 0
    integer qI       = 0
    integer rI       = 0
    integer kqI      = 0
    integer nqI      = 0
    integer krI      = 0
    integer nrI      = 0
    integer candI    = 0
    integer totalI   = 0
    integer lineI    = 0
    integer numLI    = 0
    integer nValI    = 0
    string  lineS[20] = ""
    string  resultS[30] = ""
    //
    // Allocate buffers
    gLkp1BufI  = CreateTempBuffer()
    gLkp2BufI  = CreateTempBuffer()
    gLkp3BufI  = CreateTempBuffer()
    gResultBufI = CreateTempBuffer()
    //
    // Initialise lookup buffers (120001 lines each)
    Warn( "PE143: Initialising lookup buffers..." + Chr(13) +
          "Please wait (this may take a minute)." )
    //
    PInitLookupBuf( gLkp1BufI )
    PInitLookupBuf( gLkp2BufI )
    PInitLookupBuf( gLkp3BufI )
    //
    // -------------------------------------------------------
    // Step 1: Enumerate all valid 120-degree pairs via
    // parametric formula. For gcd(m,n)=1, m>n>0,
    // (m-n) NOT divisible by 3:
    //   x0 = m^2 - n^2
    //   y0 = 2*m*n + n^2
    //   z0 = m^2 + m*n + n^2  (not needed)
    // Multiples: (k*x0, k*y0) for k=1,2,...
    // m*(m+2) must be <= 120000 => m <= 345
    // -------------------------------------------------------
    Warn( "PE143: Building valid pair lookup..." + Chr(13) +
          "Please wait (may take several minutes)." )
    //
    mI = 2
    while mI <= 345
        nI = 1
        while nI < mI
            if FNGcdI( mI, nI ) == 1
                if ( mI - nI ) mod 3 <> 0
                    x0I = mI * mI - nI * nI
                    y0I = 2 * mI * nI + nI * nI
                    kI  = 1
                    while kI * ( x0I + y0I ) <= 120000
                        xI = kI * x0I
                        yI = kI * y0I
                        // Store both (x,y) and (y,x)
                        PAddLookupEntry( xI, yI )
                        PAddLookupEntry( yI, xI )
                        // Also store (x,x) type? x0==y0 only when m^2-n^2 = 2mn+n^2
                        // i.e. m^2-2mn-2n^2=0 -- no positive integer solution, skip
                        kI = kI + 1
                    endwhile
                endif
            endif
            nI = nI + 1
        endwhile
        mI = mI + 1
    endwhile
    //
    // -------------------------------------------------------
    // Step 2: Find Torricelli triples.
    // For each p, iterate over all q in lookup(p).
    // For each q, iterate over all r in lookup(q).
    // Check (p,r) valid; if p+q+r <= 120000, record sum.
    // -------------------------------------------------------
    Warn( "PE143: Searching for Torricelli triples..." + Chr(13) +
          "Please wait." )
    //
    pI = 1
    while pI < 120000
        nqI = FNCountI( pI )
        if nqI > 0
            kqI = 1
            while kqI <= nqI
                qI = FNGetPartnerI( pI, kqI )
                if qI > 0 and pI + qI < 120000
                    nrI = FNCountI( qI )
                    if nrI > 0
                        krI = 1
                        while krI <= nrI
                            rI = FNGetPartnerI( qI, krI )
                            if rI > 0
                                candI = pI + qI + rI
                                if candI <= 120000
                                    if FNLookupI( pI, rI )
                                        PRecordSum( candI )
                                    endif
                                endif
                            endif
                            krI = krI + 1
                        endwhile
                    endif
                endif
                kqI = kqI + 1
            endwhile
        endif
        pI = pI + 1
    endwhile
    //
    // -------------------------------------------------------
    // Step 3: Sum all distinct results
    // -------------------------------------------------------
    totalI = 0
    GotoBufferId( gResultBufI )
    numLI  = NumLines()
    lineI  = 1
    while lineI <= numLI
        GotoLine( lineI )
        lineS = GetText( 1, CurrLineLen() )
        if Length( lineS ) > 0
            nValI  = Val( lineS )
            totalI = totalI + nValI
        endif
        lineI = lineI + 1
    endwhile
    //
    resultS = Str( totalI )
    //
    AbandonFile( gLkp1BufI )
    AbandonFile( gLkp2BufI )
    AbandonFile( gLkp3BufI )
    AbandonFile( gResultBufI )
    //
    CopyToWinClip( resultS )
    Warn( "PE143 - Torricelli Triangles" + Chr(13) +
          "Sum of all distinct p+q+r <= 120000:" + Chr(13) +
          resultS + Chr(13) +
          "(Result copied to clipboard)" )
end
