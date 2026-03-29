// eulerproject0228.s
//
// Project Euler - Problem 228 - Minkowski Sums
//
// How many sides does S_1864 + S_1865 + ... + S_1909 have?
//
// Mathematical approach:
//   For regular n-gon S_n, edge normals are at angles k*360/n for k=1..n.
//   Represented as reduced fractions k/n -> p/q (gcd(p,q)=1), p=0 if p==q.
//   Total sides = distinct reduced fractions p/q (0<=p<q) where q divides
//   any n in [1864..1909].
//   = 1 + sum of phi(q) for every divisor q>1 of any n in [1864..1909].
//
//   Implementation: use a 1909-line boolean buffer seenBuf.
//   Line d = "1" means d is a confirmed divisor. All divisors <= 1909.
//   No sorting needed - just mark then scan.
//
// Version : 1.4
// History : 1.0 - 2026-03-29 - Claude (Anthropic) - Initial version (wrong formula)
//           1.1 - 2026-03-29 - Claude (Anthropic) - Corrected: use totient/divisor method
//           1.2 - 2026-03-29 - Claude (Anthropic) - Fixed: mark block before sort -k
//           1.3 - 2026-03-29 - Claude (Anthropic) - Fixed: use MarkAll() before sort -k
//           1.4 - 2026-03-29 - Claude (Anthropic) - Fixed: avoid sort, use seen-buffer
//

// ---------------------------------------------------------------------------
// Forward declarations
// ---------------------------------------------------------------------------
forward integer proc PhiI( integer nI )

// ---------------------------------------------------------------------------
// Euler totient phi(n)
// ---------------------------------------------------------------------------
integer proc PhiI( integer nI )
    integer resultI
    integer pI
    integer tempI
    //
    resultI = nI
    tempI   = nI
    pI      = 2
    //
    while pI * pI <= tempI
        if tempI mod pI == 0
            while tempI mod pI == 0
                tempI = tempI / pI
            endwhile
            resultI = resultI - resultI / pI
        endif
        pI = pI + 1
    endwhile
    if tempI > 1
        resultI = resultI - resultI / tempI
    endif
    return( resultI )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer nI
    integer dI
    integer quotI
    integer totalI
    integer seenBufI
    integer lineI
    string  ansS[255]
    //
    // Step 1: create seen buffer with 1909 lines, all "0"
    seenBufI = CreateTempBuffer()
    //
    // First line (EmptyBuffer off-by-one: use BegLine+KillToEol+InsertText)
    BegLine()
    KillToEol()
    InsertText( "0" )
    //
    // Add lines 2..1909
    for lineI = 2 to 1909
        EndFile()
        AddLine()
        InsertText( "0" )
    endfor
    //
    // Step 2: for each n in [1864..1909], find divisors, mark them in seenBuf
    for nI = 1864 to 1909
        dI = 1
        while dI * dI <= nI
            if nI mod dI == 0
                // mark line dI as "1"
                GotoLine( dI )
                BegLine()
                KillToEol()
                InsertText( "1" )
                // mark line nI/dI as "1"
                quotI = nI / dI
                GotoLine( quotI )
                BegLine()
                KillToEol()
                InsertText( "1" )
            endif
            dI = dI + 1
        endwhile
    endfor
    //
    // Step 3: sum 1 + phi(q) for each q >= 2 where line q = "1"
    totalI = 1
    //
    for lineI = 2 to 1909
        GotoLine( lineI )
        BegLine()
        if GetText( 1, 1 ) == "1"
            totalI = totalI + PhiI( lineI )
        endif
    endfor
    //
    AbandonFile( seenBufI )
    //
    ansS = Str( totalI )
    //
    CopyToWinClip( ansS )
    Warn( "Euler 228 - Minkowski Sums answer: ", ansS )
    CopyToWinClip( ansS )
end
