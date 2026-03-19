// TSE SAL: Project Euler Problem 114
// Counting Block Combinations I
// Row of 50 units, red blocks min length 3, separated by >= 1 grey.
//
// Recurrence (0-indexed, f(n) = ways to fill n cells):
//   f(-1) = 1  (sentinel: block fills row exactly)
//   f(0)  = 1
//   f(n)  = f(n-1)                          // first cell is grey
//           + sum_{L=3}^{n} f(n - L - 1)   // red block len L, then 1 grey gap
//   where f(-1) = 1 by convention (stored as f[0] with index shift +1)
//
// We store f(-1)..f(50) in a temp buffer, one big-integer string per line.
// Line k holds f(k-1), so line 1 = f(-1)=1, line 2 = f(0)=1, ...
// line k+2 = f(k).
//
// Answer = f(50), line 52.
//
// <version>1.0.0.0.1</version>

// ---------------------------------------------------------------------------
// BigAdd: add two non-negative big-integer strings
// ---------------------------------------------------------------------------
string proc BigAdd( string aS, string bS )
    string resultS[255]
    integer idxAI
    integer idxBI
    integer dAI
    integer dBI
    integer sumI
    integer carryI

    idxAI  = Length( aS )
    idxBI  = Length( bS )
    carryI = 0
    resultS = ""

    while idxAI > 0 or idxBI > 0 or carryI > 0
        if idxAI > 0
            dAI    = Asc( SubStr( aS, idxAI, 1 ) ) - 48
            idxAI  = idxAI - 1
        else
            dAI = 0
        endif
        if idxBI > 0
            dBI    = Asc( SubStr( bS, idxBI, 1 ) ) - 48
            idxBI  = idxBI - 1
        else
            dBI = 0
        endif
        sumI    = dAI + dBI + carryI
        carryI  = sumI / 10
        resultS = Chr( 48 + ( sumI mod 10 ) ) + resultS
    endwhile

    if Length( resultS ) == 0
        resultS = "0"
    endif
    return( resultS )
end

// ---------------------------------------------------------------------------
// GetF: return f(n) from the buffer (n >= -1)
//   stored at line (n + 2), i.e. n=-1 -> line 1, n=0 -> line 2, etc.
// ---------------------------------------------------------------------------
string proc GetF( integer nI )
    integer lineNrI
    lineNrI = nI + 2
    GotoLine( lineNrI )
    return( GetText( 1, CurrLineLen() ) )
end

// ---------------------------------------------------------------------------
// SetF: write f(n) into the buffer
// ---------------------------------------------------------------------------
proc SetF( integer nI, string valS )
    integer lineNrI
    lineNrI = nI + 2
    GotoLine( lineNrI )
    BegLine()
    KillToEol()
    InsertText( valS )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer memoIdI
    integer oldIdI
    integer nI
    integer lI
    integer remI
    string  accS[255]
    string  termS[255]
    string  answerS[255]

    oldIdI  = GetBufferId()
    memoIdI = CreateTempBuffer()

    // Pre-fill lines 1..52 (for f(-1)..f(50)) with "0"
    // We need 52 lines: indices -1..50 -> line 1..52
    nI = 1
    while nI <= 52
        AddLine( "0" )
        nI = nI + 1
    endwhile

    // Seed values
    SetF( -1, "1" )   // line 1
    SetF(  0, "1" )   // line 2

    // Fill f(1)..f(50)
    nI = 1
    while nI <= 50
        // Start with f(n-1)  (first cell grey)
        accS = GetF( nI - 1 )

        // Add f(n - L - 1) for L = 3..n
        lI = 3
        while lI <= nI
            remI  = nI - lI - 1    // >= -1
            termS = GetF( remI )
            accS  = BigAdd( accS, termS )
            lI = lI + 1
        endwhile

        SetF( nI, accS )
        nI = nI + 1
    endwhile

    answerS = GetF( 50 )

    GotoBufferId( oldIdI )
    AbandonFile( memoIdI )

    CopyToWinClip( answerS )
    Warn( "Euler 114 answer: " + Chr(13) + answerS )
end
